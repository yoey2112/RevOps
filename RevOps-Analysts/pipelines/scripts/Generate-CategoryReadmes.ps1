param(
  [Parameter(Mandatory=$false)]
  [string]$DocsRoot = "AIDocumentation"
)

<#
.SYNOPSIS
  Generates or updates README.md files for root-level category folders.

.DESCRIPTION
  Creates comprehensive README.md files for major component categories (tables, flows, plugins, etc.)
  based on standardized templates. This ensures consistent structure and complete coverage
  before TXT generation.

.EXAMPLE
  .\Generate-CategoryReadmes.ps1 -DocsRoot "AIDocumentation"
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Write-Host "=== Category README Generation ===" -ForegroundColor Green
Write-Host "DocsRoot: $DocsRoot"

if (!(Test-Path $DocsRoot)) {
  throw "DocsRoot not found: $DocsRoot"
}

$DocsRoot = Resolve-Path -Path $DocsRoot

# Define category metadata
$categories = @(
  @{
    Name = "tables"
    DisplayName = "Tables"
    Purpose = "This folder contains comprehensive documentation for all Dataverse tables (entities) in the RevOps environment. Tables are the foundational data structures that store business information - from standard entities like Account and Contact to custom RevOps-specific tables."
    WhatsDocs = @"
Each table has its own subfolder containing:

- **README.md**: Narrative documentation explaining purpose, usage, and key relationships
- **_facts/columns.yaml**: Machine-readable column metadata (names, types, descriptions, required fields)
- **_facts/relationships.yaml**: All 1:N, N:1, and N:N relationships with other tables
- **_facts/forms.yaml**: Form configurations including fields, tabs, and sections (best-effort)
- **_facts/business_rules.yaml**: Business rules configured on the table (best-effort)
"@
    Navigation = @"
**To find a specific table:**
- Browse subfolders by logical name (e.g., ``account/``, ``revops_pricingrequest/``)
- Standard Dynamics 365 tables use lowercase names (account, contact, opportunity)
- Custom RevOps tables are prefixed with ``revops_``

**To understand table relationships:**
- Check the table's ``_facts/relationships.yaml`` for direct connections
- See [/_graph/dependencies.json](../_graph/dependencies.json) for full dependency graph
- Review [/_graph/reverse-index.yaml](../_graph/reverse-index.yaml) to find what components use a table
"@
  }
  @{
    Name = "flows"
    DisplayName = "Flows (Cloud Flows)"
    Purpose = "This folder contains comprehensive documentation for all Power Automate cloud flows in the RevOps environment. Flows are automated workflows that orchestrate business processes, integrate systems, and respond to events within and beyond the Power Platform ecosystem."
    WhatsDocs = @"
Each flow has its own subfolder containing:

- **README.md**: Narrative explanation of flow logic, purpose, and business context
- **_facts/flow-actions.yaml**: Action-by-action breakdown with inputs, outputs, and table operations
- **_facts/metadata.yaml**: Flow trigger type, state, owner, and solution membership
- **_facts/dependencies.yaml**: Extracted dependencies on tables, connection references, and child flows
"@
    Navigation = @"
**To find a specific flow:**
- Browse subfolders by display name (normalized with hyphens, lowercase)
- Flow folders may include prefix indicators for categorization

**To understand what a flow does:**
- Start with the README.md for business context and high-level logic
- Review ``_facts/flow-actions.yaml`` for step-by-step action breakdown
- Check ``_facts/dependencies.yaml`` for table and connection dependencies
"@
  }
  @{
    Name = "plugins"
    DisplayName = "Plugins"
    Purpose = "This folder contains documentation for all server-side .NET plugins registered in the RevOps environment. Plugins execute within the Dataverse event pipeline to implement custom business logic, validation, and data transformation."
    WhatsDocs = @"
Each plugin assembly has its own subfolder containing:

- **README.md**: Overview of plugin purpose and registered SDK steps
- **_facts/sdk-steps.yaml**: Detailed step configurations (table, message, stage, mode, rank)
- **_facts/images.yaml**: Pre-image and post-image configurations
- **_facts/dependencies.yaml**: Tables and fields accessed by the plugin
"@
    Navigation = @"
**To find a specific plugin:**
- Browse subfolders by assembly name (e.g., ``revops-emailplugins/``, ``revops-solutionplugins/``)

**To understand what triggers a plugin:**
- Check ``_facts/sdk-steps.yaml`` for table, message (Create, Update, etc.), and stage (PreValidation, PreOperation, PostOperation)
- Review [/_graph/dependencies.json](../_graph/dependencies.json) for impact analysis
"@
  }
  @{
    Name = "queues"
    DisplayName = "Queues"
    Purpose = "This folder contains documentation for all Dataverse queues used for work distribution and case routing in the RevOps environment. Queues organize work items and enable team-based assignment."
    WhatsDocs = @"
Each queue has its own subfolder containing:

- **README.md**: Queue purpose, membership, and routing configuration
- **_facts/queue-info.yaml**: Queue type (public/private), owner, email settings
- **_facts/members.yaml**: User and team memberships
"@
    Navigation = @"
**To find a specific queue:**
- Browse subfolders by queue name (normalized with hyphens, lowercase)

**To understand queue routing:**
- Check ``_facts/queue-info.yaml`` for queue type and configuration
- Review workstream associations in [/workstreams/](../workstreams/) folder
"@
  }
  @{
    Name = "slas"
    DisplayName = "SLAs (Service Level Agreements)"
    Purpose = "This folder contains documentation for all Service Level Agreements (SLAs) configured in the RevOps environment. SLAs define time-based performance targets and warning thresholds for case resolution."
    WhatsDocs = @"
Each SLA has its own subfolder containing:

- **README.md**: SLA purpose, target times, and applicability rules
- **_facts/sla-info.yaml**: SLA configuration, KPI targets, workflow associations
- **_facts/items.yaml**: SLA items with warning/failure times and conditions
"@
    Navigation = @"
**To find a specific SLA:**
- Browse subfolders by SLA name (normalized with hyphens, lowercase)

**To understand SLA rules:**
- Check ``_facts/sla-info.yaml`` for applicability conditions
- Review ``_facts/items.yaml`` for warning/failure thresholds
"@
  }
  @{
    Name = "workstreams"
    DisplayName = "Workstreams (Omnichannel)"
    Purpose = "This folder contains documentation for all Omnichannel workstreams in the RevOps environment. Workstreams define routing rules, assignment logic, and channel configurations for customer service interactions."
    WhatsDocs = @"
Each workstream has its own subfolder containing:

- **README.md**: Workstream purpose, channel type, and routing strategy
- **_facts/workstream-info.yaml**: Workstream configuration, capacity profiles, work distribution
- **_facts/routing-rules.yaml**: Priority-based routing rules and conditions
"@
    Navigation = @"
**To find a specific workstream:**
- Browse subfolders by workstream name (normalized with hyphens, lowercase)

**To understand routing logic:**
- Check ``_facts/routing-rules.yaml`` for rule priority and conditions
- Review queue associations in [/queues/](../queues/) folder
"@
  }
  @{
    Name = "security-roles"
    DisplayName = "Security Roles"
    Purpose = "This folder contains documentation for all security roles configured in the RevOps environment. Security roles define permissions, access levels, and privilege assignments for users and teams."
    WhatsDocs = @"
Each security role has its own subfolder containing:

- **README.md**: Role purpose, key privileges, and typical user assignments
- **_facts/privileges.yaml**: Detailed privilege assignments (CRUD + depth levels) per table
- **_facts/role-info.yaml**: Role metadata, description, and solution membership
"@
    Navigation = @"
**To find a specific role:**
- Browse subfolders by role name (normalized with hyphens, lowercase)

**To understand role permissions:**
- Check ``_facts/privileges.yaml`` for table-level permissions (Create, Read, Write, Delete, Append, AppendTo)
- Depth levels: None, User, Business Unit, Parent-Child BU, Organization
"@
  }
  @{
    Name = "app-modules"
    DisplayName = "App Modules"
    Purpose = "This folder contains documentation for all model-driven app modules in the RevOps environment. App modules define the user experience, including entities, dashboards, and business process flows."
    WhatsDocs = @"
Each app module has its own subfolder containing:

- **README.md**: App purpose, target audience, and key components
- **_facts/entities.yaml**: Tables included in the app with their views and forms
- **_facts/components.yaml**: Dashboards, business process flows, and other components
"@
    Navigation = @"
**To find a specific app:**
- Browse subfolders by app unique name (normalized with hyphens, lowercase)

**To understand app composition:**
- Check ``_facts/entities.yaml`` for included tables
- Review ``_facts/components.yaml`` for dashboards and BPFs
"@
  }
  @{
    Name = "business-process-flows"
    DisplayName = "Business Process Flows"
    Purpose = "This folder contains documentation for all Business Process Flows (BPFs) in the RevOps environment. BPFs guide users through defined business processes by presenting stages, steps, and required fields in a structured workflow."
    WhatsDocs = @"
Each business process flow has its own subfolder containing:

- **README.md**: BPF purpose, stages, and business context
- **_facts/bpf-info.yaml**: BPF metadata (name, category, primary entity, status)
- **_facts/stages.yaml**: Process stages with steps, fields, and transitions
- **_facts/entities.yaml**: Tables/entities participating in the BPF
"@
    Navigation = @"
**To find a specific BPF:**
- Browse subfolders by BPF name (normalized with hyphens, lowercase)

**To understand BPF stages:**
- Review ``_facts/stages.yaml`` for stage sequence, required fields, and transitions
- Check ``_facts/entities.yaml`` for participating tables
"@
  }
  @{
    Name = "web-resources"
    DisplayName = "Web Resources"
    Purpose = "This folder contains documentation for all web resources (JavaScript, CSS, HTML, images) used in the RevOps environment. Web resources extend model-driven app functionality with custom client-side logic."
    WhatsDocs = @"
Each web resource has its own subfolder containing:

- **README.md**: Web resource purpose, usage context, and form associations
- **_facts/resource-info.yaml**: Resource type, content type, and solution membership
"@
    Navigation = @"
**To find a specific web resource:**
- Browse subfolders by resource name (normalized with hyphens, lowercase)

**To understand web resource usage:**
- Check README.md for form/view associations
- Review ``_facts/resource-info.yaml`` for metadata
"@
  }
  @{
    Name = "connection-references"
    DisplayName = "Connection References"
    Purpose = "This folder contains documentation for all connection references in the RevOps environment. Connection references enable flows and other components to connect to external services (Dataverse, SharePoint, Teams, Azure, etc.)."
    WhatsDocs = @"
Each connection reference has its own subfolder containing:

- **README.md**: Connection reference purpose and connector type
- **_facts/connection-info.yaml**: Connection metadata, connector details, and solution membership
"@
    Navigation = @"
**To find a specific connection reference:**
- Browse subfolders by connection reference name (normalized with hyphens, lowercase)

**To understand connection usage:**
- Check which flows use the connection in [/flows/](../flows/) folder
- Review ``_facts/connection-info.yaml`` for connector details
"@
  }
  @{
    Name = "environment-variables"
    DisplayName = "Environment Variables"
    Purpose = "This folder contains documentation for all environment variables in the RevOps environment. Environment variables enable configuration management across environments without hard-coding values."
    WhatsDocs = @"
Each environment variable has its own subfolder containing:

- **README.md**: Variable purpose, expected values, and usage context
- **_facts/variable-info.yaml**: Variable type (string, number, JSON), default value, and current value
"@
    Navigation = @"
**To find a specific environment variable:**
- Browse subfolders by variable schema name (normalized with hyphens, lowercase)

**To understand variable usage:**
- Check which components reference the variable in dependency graph
- Review ``_facts/variable-info.yaml`` for type and values
"@
  }
  @{
    Name = "Power Pages"
    DisplayName = "Power Pages"
    Purpose = "This folder contains documentation for all Power Pages sites, web pages, and portal components in the RevOps environment."
    WhatsDocs = @"
Each Power Pages component has its own subfolder containing:

- **README.md**: Component purpose and configuration
- **_facts/**: Structured metadata specific to the component type
"@
    Navigation = @"
**To find specific Power Pages components:**
- Browse subfolders by component type and name

**To understand portal configuration:**
- Review component README.md files for context
- Check _facts/ folders for structured metadata
"@
  }
)

$standardSections = @{
  RevOpsStandard = @"
## RevOps Documentation Standard

All component documentation follows a consistent structure:

- **README.md**: Human-readable narrative documentation
- **_facts/*.yaml**: Machine-readable structured metadata
- **Dependencies**: Tracked in [/_graph/dependencies.json](../_graph/dependencies.json)
- **Registry**: All components cataloged in [/_registry/assets.yaml](../_registry/assets.yaml)
- **Quality**: Coverage metrics in [/_quality/coverage-report.yaml](../_quality/coverage-report.yaml)
"@

  Generation = @"
## How Documentation is Generated

This documentation is automatically generated from the Dataverse environment:

1. **Extraction**: Solution XML files exported from Dataverse
2. **Parsing**: Metadata APIs queried for schema details
3. **Analysis**: Dependencies extracted from configurations and code
4. **Generation**: Structured YAML + narrative Markdown created
5. **Validation**: Coverage and quality metrics calculated

**Generation Runs**: Stored in [/RUNS/](../RUNS/) with timestamps and diff reports
"@

  CopilotGuidance = @"
## For RevOps Copilot Agents

**Interpretation Guidance:**
- Start with the README.md for context and navigation
- Use ``_facts/*.yaml`` files for structured queries
- Cross-reference [/_graph/dependencies.json](../_graph/dependencies.json) for relationships
- Check [/_registry/assets.yaml](../_registry/assets.yaml) for component lifecycle (active/added/removed)

**Common Query Patterns:**
- "What components exist?" → Browse subfolders or check [/_registry/assets.yaml](../_registry/assets.yaml)
- "What does component X do?" → Read component's README.md
- "What depends on component X?" → Use [/_graph/reverse-index.yaml](../_graph/reverse-index.yaml)
- "What changed recently?" → Check [/RUNS/](../RUNS/) for latest diff report

**Confidence Levels:**
- **High (95-100%)**: Direct metadata extraction (names, types, relationships)
- **Moderate (70-90%)**: Parsed configurations (forms, business rules, flow actions)
- **Low (50-70%)**: Inferred logic and complex dependencies
"@

  Related = @"
## Related Documentation

- **[../Documentation/](../Documentation/)**: Human-focused how-to guides and architecture decisions
- **[../pipelines/](../pipelines/)**: Pipeline configurations and generation scripts
- **[/_graph/](./_graph/)**: Dependency graph and impact analysis
- **[/_registry/](./_registry/)**: Asset registry and lifecycle tracking
- **[/_quality/](./_quality/)**: Coverage reports and gap analysis
"@
}

function Generate-CategoryReadme {
  param(
    [Parameter(Mandatory=$true)]
    [hashtable]$Category,
    [Parameter(Mandatory=$true)]
    [string]$TargetPath
  )

  $content = @"
# $($Category.DisplayName) Documentation

## Purpose

$($Category.Purpose)

**Audience:**
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

## What's Documented Here

$($Category.WhatsDocs)

## How to Navigate

$($Category.Navigation)

$($standardSections.RevOpsStandard)

$($standardSections.Generation)

$($standardSections.CopilotGuidance)

$($standardSections.Related)

---

**Last Updated**: Auto-generated by documentation pipeline
**Category**: $($Category.DisplayName)
**Path**: ``/$($Category.Name)/``
"@

  # Normalize line endings and write
  $normalized = $content -replace "`r`n", "`n"
  $utf8NoBom = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllText($TargetPath, $normalized, $utf8NoBom)
}

# Process each category
$generated = 0
$skipped = 0
$updated = 0

foreach ($category in $categories) {
  $folderPath = Join-Path $DocsRoot $category.Name
  
  if (!(Test-Path $folderPath)) {
    Write-Verbose "Folder not found, skipping: $($category.Name)"
    $skipped++
    continue
  }

  $readmePath = Join-Path $folderPath "README.md"
  $exists = Test-Path $readmePath

  if ($exists) {
    # Check if it's manually maintained (has specific markers)
    $firstLines = Get-Content -Path $readmePath -First 5 -ErrorAction SilentlyContinue
    if ($firstLines -match "MANUAL-README:\s*TRUE") {
      Write-Verbose "Skipping manual README: $($category.Name)"
      $skipped++
      continue
    }
    Write-Verbose "Updating: $readmePath"
    $updated++
  }
  else {
    Write-Verbose "Creating: $readmePath"
    $generated++
  }

  Generate-CategoryReadme -Category $category -TargetPath $readmePath
  Write-Host "  [OK] $($category.Name)/README.md" -ForegroundColor Green
}

# Summary
Write-Host "`n=== Generation Statistics ===" -ForegroundColor Green
Write-Host "Created: $generated"
Write-Host "Updated: $updated"
Write-Host "Skipped: $skipped"

Write-Host "`n[SUCCESS] Category README generation complete" -ForegroundColor Green
