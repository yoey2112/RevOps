# RevOps AI Documentation Repository

## Purpose
This repository contains comprehensive, structured documentation of the RevOps Dataverse/Dynamics 365 solution, optimized for AI agent consumption. It provides navigation, metadata, dependency graphs, and quality metrics to support automated analysis, impact assessment, and knowledge retrieval by RevOps Copilot agents and developers.

## Repository Structure

### Core Components
Component-level documentation for Dataverse entities, automation, and business logic:

- **[tables/](tables/)** - Dataverse tables (entities), columns, relationships, forms, views, business rules
- **[flows/](flows/)** - Cloud flows (Power Automate), actions, triggers, read/write operations
- **[plugins/](plugins/)** - .NET plugin assemblies, SDK steps, event pipeline registrations
- **[queues/](queues/)** - Case routing queues, public/private memberships, SLA associations
- **[slas/](slas/)** - Service Level Agreements, KPI targets, applicability conditions
- **[workstreams/](workstreams/)** - Omnichannel workstreams, routing rules, channel configurations

### Power Platform Configuration
Application and configuration component documentation:

- **[app-modules/](app-modules/)** - Model-driven app modules (Customer Service Hub, Sales Hub, etc.), entity/component associations
- **[business-process-flows/](business-process-flows/)** - Business process flows, stage definitions, required fields
- **[connection-references/](connection-references/)** - 148 connection references for external services (Dataverse, SharePoint, Teams, Azure)
- **[environment-variables/](environment-variables/)** - 65 environment variables for configuration management
- **[security-roles/](security-roles/)** - Security roles, privilege assignments, CRUD + depth levels
- **[web-resources/](web-resources/)** - JavaScript, CSS, HTML, image resources used in forms/views

### Power Pages
Portal/website component documentation:

- **[Power Pages/](Power%20Pages/)** - Power Pages sites, web pages, web templates, content snippets

### Documentation Infrastructure
Quality, tracking, and reference data:

- **[_graph/](_graph/)** - Dependency graph (nodes, edges, confidence scores), impact analysis, cross-component relationships
- **[_registry/](_registry/)** - Asset and solution registry, lifecycle tracking (active/added/removed)
- **_quality/** - Coverage reports, gap analysis, error tracking, enrichment roadmaps
- **[_shared/](_shared/)** - Shared standards, normalization rules, formatting conventions
- **[RUNS/](RUNS/)** - Documentation generation runs, diff reports, coverage metrics, lifecycle reports

## Documentation Standard

Each component folder follows a consistent structure:

### Folder Layout
```
component-name/
├── README.md                    # Navigation + interpretation guide (this file)
├── _facts/                      # Structured data (YAML)
│   ├── component-info.yaml      # Core metadata
│   ├── additional-facts.yaml    # Component-specific structured data
│   └── ...
└── component-subfolders/        # Individual component documentation
    ├── component-1/
    │   ├── _facts/              # Structured data for this component
    │   └── *.md                 # Generated documentation
    └── component-2/
```

### README.md Structure
Each component folder README contains:

1. **Purpose** - What this component type represents in Dataverse/Power Platform
2. **What's Documented Here** - Scope, counts, key characteristics
3. **Navigation** - How to find specific components and interpret folder structure
4. **Generation** - How documentation is extracted (sources, methods, confidence)
5. **Dependencies** - What other components this depends on or is used by
6. **Coverage** - What aspects are documented vs. what has gaps
7. **For RevOps Copilot Agents** - Specific guidance for AI interpretation, confidence levels, common patterns

### _facts/ YAML Files
Structured data for programmatic consumption:
- **High confidence**: Direct extraction from solution XML, metadata APIs
- **Moderate confidence**: Parsed from clientdata, inferred from configurations
- **Low confidence**: Complex logic analysis, indirect relationships

## Using This Repository as a Knowledge Source

### Copilot TXT Projection Layer

**For Copilot Studio Integration:**

This repository includes a Copilot-friendly text projection layer that mirrors the markdown documentation in plain .txt format. Copilot Studio can reliably retrieve .txt files from SharePoint, while .md and .yaml files may have retrieval limitations.

**What Gets Generated:**
- `README.txt` files alongside every `README.md` (auto-generated)
- `copilot-index.txt` files in major component folders (tables, flows, plugins, etc.)
- Plain text format with consistent structure: TITLE, PURPOSE, SCOPE, NAVIGATION, LIMITATIONS

**TXT File Structure:**
Each .txt file follows this format:
```
TITLE
=====
RevOps - <Component Name> Overview

PURPOSE
-------
<1-3 sentences describing what this component is>

SCOPE
-----
Covers: ...
Does NOT cover: ...

REVOPS STANDARD
---------------
<Documentation standards and conventions>

HOW TO NAVIGATE
---------------
<Where to find metadata, dependencies, detailed docs>

COMMON QUESTIONS THIS ANSWERS
-----------------------------
<Key questions this component answers>

LIMITATIONS
-----------
<What's not captured, confidence levels, caveats>
```

**Manual TXT Files:**
To prevent auto-generation from overwriting a human-authored .txt file, add this header as the first line:
```
MANUAL-TXT: TRUE
```

**Generation Process:**
- TXT files are auto-generated during every documentation pipeline run
- Content is extracted from corresponding README.md files
- Files are only updated when content changes (deterministic, hash-based)
- TXT files are automatically mirrored to SharePoint along with other documentation

**For Copilot Agents:**
When using this repository as a knowledge source in Copilot Studio:
- Prefer .txt files for overview and navigation information
- Use .yaml files for structured metadata (when retrieval is possible)
- Cross-reference between .txt and source .md/.yaml files as needed

### For Copilot Agents

**Starting Point:**
1. Read this README to understand the repository structure
2. Identify the component type relevant to your query (table? flow? plugin?)
3. Navigate to the component folder and read its README for interpretation guidance
4. Access _facts/*.yaml files for structured data
5. Use [_graph/dependencies.json](_graph/dependencies.json) for cross-component relationships

**Common Query Patterns:**

**"What tables does flow X use?"**
- Start at [flows/](flows/) → find flow folder → read `_facts/flow-actions.yaml` for actions
- OR use [_graph/dependencies.json](_graph/dependencies.json) → find flow node → follow edges to table nodes

**"What triggers plugin Y?"**
- Start at [plugins/](plugins/) → find plugin folder → read `_facts/sdk-steps.yaml` for table+message+stage
- OR use [_graph/dependencies.json](_graph/dependencies.json) → find plugin node → follow edges from triggering tables

**"What components are in app module Z?"**
- Start at [app-modules/](app-modules/) → find app folder → read `_facts/entities.yaml` and `_facts/components.yaml`

**"What's the impact of changing table field A?"**
- Use [_graph/dependencies.json](_graph/dependencies.json) → find table node → follow outgoing edges to flows, plugins, forms
- Check [_graph/IMPACT-ANALYSIS.md](_graph/IMPACT-ANALYSIS.md) for impact analysis methodology

**"What's the quality coverage of flows?"**
- Check [_quality/coverage-report.yaml](_quality/coverage-report.yaml) for component-level metrics
- Check [_quality/gap-matrix.md](_quality/gap-matrix.md) for missing documentation

**Key Files for Cross-Component Analysis:**
- [_graph/dependencies.json](_graph/dependencies.json) - Full dependency graph (nodes + edges)
- [_graph/reverse-index.yaml](_graph/reverse-index.yaml) - Reverse lookup (what uses component X?)
- [_graph/solution-dependencies.yaml](_graph/solution-dependencies.yaml) - Solution-level dependencies
- [_registry/assets.yaml](_registry/assets.yaml) - All tracked assets with lifecycle state
- [_registry/solutions.yaml](_registry/solutions.yaml) - All solutions in the environment
- [_quality/coverage-report.yaml](_quality/coverage-report.yaml) - Documentation completeness metrics

### For Developers

**Navigation:**
- Start with component folder READMEs to understand what's documented
- Use _facts/*.yaml for quick structured lookups
- Refer to [_shared/standards.md](_shared/standards.md) for formatting conventions
- Check [RUNS/](RUNS/) for recent documentation generation history

**Contributing:**
- Follow standards in [_shared/standards.md](_shared/standards.md) and [_shared/normalization.md](_shared/normalization.md)
- Update _facts/*.yaml files for metadata changes
- Regenerate documentation by running the Azure DevOps pipeline in [../azure-pipelines.yml](../azure-pipelines.yml)
- Review [_quality/gap-matrix.md](_quality/gap-matrix.md) for enrichment opportunities

## Documentation Generation

This documentation is automatically generated by:
- **Pipeline**: [../azure-pipelines.yml](../azure-pipelines.yml)
- **Scripts**: PowerShell scripts in [../pipelines/scripts/](../pipelines/scripts/)

**Generation Process:**
1. Export solutions from Dataverse environment
2. Parse solution XML files for metadata
3. Extract clientdata from flows, parse action definitions
4. Query Dataverse metadata APIs for schema details
5. Build dependency graph from relationships, triggers, actions
6. Generate YAML _facts files and Markdown documentation
7. Calculate coverage metrics and quality scores
8. Store run artifacts in [RUNS/](RUNS/)

## Confidence Levels

Documentation confidence varies by component and extraction method:

**High Confidence (95-100%):**
- Table schemas (columns, data types, relationships) - from metadata APIs
- Plugin SDK steps (table, message, stage) - from plugin registration XML
- Queue definitions (names, types, memberships) - from queue entity records
- Connection references (names, connector types) - from solution XML
- Environment variables (names, types, values) - from solution XML

**Moderate Confidence (70-90%):**
- Flow actions and triggers - from clientdata parsing (complex JSON structure)
- Form configurations - from FormXML parsing (layout can be complex)
- Business rules - from JSON definition parsing (condition logic)
- Security role privileges - from XML parsing (many privilege types)

**Low Confidence (50-70%):**
- Plugin code logic analysis - not performed (would require .NET decompilation)
- Flow conditional logic - limited parsing of complex expressions
- JavaScript web resource behavior - not analyzed (would require JS parsing)

**See component folder READMEs for specific confidence levels per data type.**

## Versioning and Change Tracking

- **Asset Lifecycle**: Tracked in [_registry/assets.yaml](_registry/assets.yaml) (active, added, removed)
- **Run History**: Each generation run creates a folder in [RUNS/](RUNS/) with timestamp
- **Diff Reports**: [RUNS/<timestamp>/diff-report.md](RUNS/) shows changes between runs
- **Lifecycle Reports**: [RUNS/<timestamp>/lifecycle-report.md](RUNS/) tracks component additions/removals

## Related Documentation

- **[../Documentation/](../Documentation/)** - Human-focused documentation, how-to guides, architecture decisions
- **[../pipelines/](../pipelines/)** - Pipeline configurations and generation scripts
- **[../Plugins/](../Plugins/)** - Plugin source code (.NET projects)

## Support and Feedback

For questions, issues, or suggestions about this documentation:
- File issues in Azure DevOps repository
- Contact RevOps development team
- Review [_quality/enrichment-roadmap.md](_quality/enrichment-roadmap.md) for planned improvements

---

**Last Updated**: Auto-generated by documentation pipeline  
**Repository**: RevOps-Analysts  
**Environment**: Production Dataverse instance
