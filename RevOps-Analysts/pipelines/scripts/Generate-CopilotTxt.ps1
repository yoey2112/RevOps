param(
  [Parameter(Mandatory=$false)]
  [string]$DocsRoot = "AIDocumentation",
  
  [Parameter(Mandatory=$false)]
  [switch]$FailOnEmpty = $true
)

<#
.SYNOPSIS
  Generates Copilot-friendly .txt projection files from markdown documentation.

.DESCRIPTION
  Converts README.md files to structured .txt files that Copilot Studio can reliably retrieve from SharePoint.
  - Deterministic: Same input produces same output
  - Idempotent: Only updates files when content changes
  - Validates: Ensures all required files exist and have proper structure

.EXAMPLE
  .\Generate-CopilotTxt.ps1 -DocsRoot "AIDocumentation" -Verbose
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Statistics
$script:stats = @{
  Created = 0
  Updated = 0
  Skipped = 0
  Manual = 0
  Errors = @()
}

function Write-VerboseLog {
  param([string]$Message)
  Write-Verbose $Message
}

function Get-FileHashString {
  param([string]$Content)
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($Content)
  $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
  return [System.BitConverter]::ToString($hash).Replace('-','')
}

function Normalize-TextContent {
  param([string]$Content)
  
  # Normalize line endings to LF
  $normalized = $Content -replace "`r`n", "`n"
  
  # Trim trailing whitespace from each line
  $lines = $normalized -split "`n"
  $trimmed = $lines | ForEach-Object { $_.TrimEnd() }
  
  # Join and ensure single trailing newline
  return ($trimmed -join "`n").TrimEnd() + "`n"
}

function Read-MarkdownContent {
  param([string]$MdPath)
  
  if (!(Test-Path $MdPath)) {
    return $null
  }
  
  $content = Get-Content -Path $MdPath -Raw -Encoding UTF8
  return $content
}

function Extract-MarkdownSection {
  param(
    [string]$Content,
    [string]$SectionHeader
  )
  
  if (!$Content) { return "" }
  
  # Match section header (## or # followed by the section name)
  $pattern = "(?ms)^#{1,3}\s+$SectionHeader\s*`n(.+?)(?=^#{1,3}\s+|\z)"
  if ($Content -match $pattern) {
    $section = $Matches[1].Trim()
    # Remove markdown formatting
    $section = $section -replace '\[([^\]]+)\]\([^\)]+\)', '$1'  # Remove links
    $section = $section -replace '[`*_]', ''  # Remove formatting
    $section = $section -replace '```[^```]*```', ''  # Remove code blocks
    return $section
  }
  return ""
}

function Convert-MarkdownToPlainText {
  param([string]$Content)
  
  if (!$Content) { return "" }
  
  # Remove code blocks
  $plain = $Content -replace '(?s)```.*?```', ''
  
  # Convert headers to plain text
  $plain = $plain -replace '^#{1,6}\s+(.+)$', '$1'
  
  # Remove markdown links but keep text
  $plain = $plain -replace '\[([^\]]+)\]\([^\)]+\)', '$1'
  
  # Remove bold/italic
  $plain = $plain -replace '[*_]{1,2}([^*_]+)[*_]{1,2}', '$1'
  
  # Remove inline code
  $plain = $plain -replace '`([^`]+)`', '$1'
  
  # Clean up multiple blank lines
  $plain = $plain -replace '(?m)^\s*$\n', "`n"
  $plain = $plain -replace '\n{3,}', "`n`n"
  
  return $plain.Trim()
}

function Generate-TxtFromMarkdown {
  param(
    [string]$MdPath,
    [string]$ComponentName,
    [string]$FolderContext
  )
  
  $mdContent = Read-MarkdownContent -MdPath $MdPath
  if (!$mdContent) {
    Write-VerboseLog "No markdown found at $MdPath, will synthesize"
    return Generate-SynthesizedTxt -ComponentName $ComponentName -FolderContext $FolderContext
  }
  
  # Extract key sections
  $purpose = Extract-MarkdownSection -Content $mdContent -SectionHeader "Purpose"
  if (!$purpose) {
    # Try alternate headers
    $purpose = Extract-MarkdownSection -Content $mdContent -SectionHeader "Overview"
    if (!$purpose) {
      $purpose = ($mdContent -split "`n")[0..3] -join "`n"
      $purpose = Convert-MarkdownToPlainText -Content $purpose
    }
  }
  
  $scope = Extract-MarkdownSection -Content $mdContent -SectionHeader "What's Documented Here"
  if (!$scope) {
    $scope = Extract-MarkdownSection -Content $mdContent -SectionHeader "Scope"
  }
  
  $navigation = Extract-MarkdownSection -Content $mdContent -SectionHeader "How to Navigate"
  $guidance = Extract-MarkdownSection -Content $mdContent -SectionHeader "Guidance for Copilot Agents"
  $limitations = Extract-MarkdownSection -Content $mdContent -SectionHeader "Limitations"
  
  # Build the TXT content
  $txt = @"
TITLE
=====
RevOps - $ComponentName Overview

PURPOSE
-------
$($purpose.Trim())

SCOPE
-----
$($scope.Trim())

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
$($navigation.Trim())

COMMON QUESTIONS THIS ANSWERS
-----------------------------
$($guidance.Trim())

LIMITATIONS
-----------
$($limitations.Trim())
"@
  
  return $txt
}

function Generate-SynthesizedTxt {
  param(
    [string]$ComponentName,
    [string]$FolderContext
  )
  
  # Synthesize content based on folder structure and naming
  $purpose = switch -Wildcard ($ComponentName) {
    "*Tables*" { "Documentation for all Dataverse tables (entities) in the RevOps solution. Tables represent core data structures." }
    "*Flows*" { "Documentation for all Power Automate cloud flows. Flows represent automated workflows and business processes." }
    "*Plugins*" { "Documentation for all server-side plugins (custom assemblies). Plugins execute within the Dataverse event pipeline." }
    "*Queues*" { "Documentation for all Dataverse queues used for work distribution and routing." }
    "*SLAs*" { "Documentation for all Service Level Agreements (SLAs) defining time-based performance targets." }
    "*Workstreams*" { "Documentation for all Omnichannel workstreams defining routing and assignment logic." }
    "*App Modules*" { "Documentation for application modules and their configurations." }
    "*Security*" { "Documentation for security roles, permissions, and access control configurations." }
    default { "Documentation for $ComponentName components in the RevOps solution." }
  }
  
  $txt = @"
TITLE
=====
RevOps - $ComponentName Overview

PURPOSE
-------
$purpose

SCOPE
-----
Covers:
- Component definitions and configurations
- Metadata and structured data in _facts folders
- Relationships and dependencies

Does NOT cover:
- Runtime data or performance metrics
- User-specific customizations
- Environment-specific configurations

REVOPS STANDARD
---------------
- Structured YAML files in _facts subfolders contain detailed metadata
- README.md files provide narrative documentation
- Dependencies tracked in /_graph/dependencies.json
- All components registered in /_registry/assets.yaml

HOW TO NAVIGATE
---------------
- Metadata: Check _facts/*.yaml files for structured component data
- Dependencies: See /_graph/dependencies.json for relationships
- Registry: Browse /_registry/assets.yaml for component catalog
- Latest run: Check /RUNS/ folder for extraction reports

COMMON QUESTIONS THIS ANSWERS
-----------------------------
- What components exist in this category?
- Where can I find detailed metadata for a specific component?
- How do I trace dependencies and relationships?
- What documentation standards are followed?

LIMITATIONS
-----------
- Documentation is extracted via API and may have gaps where metadata is incomplete
- Some configurations may require direct environment inspection
- Generated documentation reflects point-in-time snapshots from extraction runs
"@
  
  return $txt
}

function Test-ManualTxtFile {
  param([string]$TxtPath)
  
  if (!(Test-Path $TxtPath)) {
    return $false
  }
  
  $firstLine = Get-Content -Path $TxtPath -First 1 -ErrorAction SilentlyContinue
  return ($firstLine -match 'MANUAL-TXT:\s*TRUE')
}

function Write-TxtFile {
  param(
    [string]$TxtPath,
    [string]$Content,
    [string]$ComponentName
  )
  
  # Check if manual file
  if (Test-ManualTxtFile -TxtPath $TxtPath) {
    Write-VerboseLog "Skipping manual file: $TxtPath"
    $script:stats.Manual++
    return
  }
  
  # Normalize content
  $normalized = Normalize-TextContent -Content $Content
  $newHash = Get-FileHashString -Content $normalized
  
  # Check if file exists and compare
  if (Test-Path $TxtPath) {
    $existing = Get-Content -Path $TxtPath -Raw -Encoding UTF8
    $existingHash = Get-FileHashString -Content $existing
    
    if ($newHash -eq $existingHash) {
      Write-VerboseLog "No changes for: $TxtPath"
      $script:stats.Skipped++
      return
    }
    
    Write-VerboseLog "Updating: $TxtPath"
    $script:stats.Updated++
  }
  else {
    Write-VerboseLog "Creating: $TxtPath"
    $script:stats.Created++
  }
  
  # Write file with UTF-8 no BOM
  $utf8NoBom = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllText($TxtPath, $normalized, $utf8NoBom)
}

function Validate-TxtFile {
  param([string]$TxtPath)
  
  if (!(Test-Path $TxtPath)) {
    return "File does not exist"
  }
  
  $content = Get-Content -Path $TxtPath -Raw -Encoding UTF8
  
  if ($content.Length -lt 100) {
    return "File is suspiciously small (< 100 chars)"
  }
  
  if ($content -notmatch 'TITLE\s*\n\s*=+') {
    return "Missing TITLE section"
  }
  
  if ($content -notmatch 'PURPOSE\s*\n\s*-+') {
    return "Missing PURPOSE section"
  }
  
  return $null
}

function Generate-CopilotIndexTxt {
  param(
    [string]$FolderPath,
    [string]$ComponentName
  )
  
  $indexPath = Join-Path $FolderPath "copilot-index.txt"
  
  # Get subfolders
  $subfolders = Get-ChildItem -Path $FolderPath -Directory | 
    Where-Object { $_.Name -notmatch '^(_|RUNS)' } |
    Sort-Object Name
  
  if ($subfolders.Count -eq 0) {
    return
  }
  
  $indexContent = @"
TITLE
=====
RevOps - $ComponentName Component Index

PURPOSE
-------
Quick reference index of all $ComponentName components in this folder.

COMPONENTS
----------
"@
  
  foreach ($folder in $subfolders) {
    $folderName = $folder.Name
    $readmePath = Join-Path $folder.FullName "README.md"
    
    if (Test-Path $readmePath) {
      $mdContent = Get-Content -Path $readmePath -Raw -Encoding UTF8
      $firstLine = ($mdContent -split "`n" | Where-Object { $_.Trim() -ne '' } | Select-Object -First 1)
      $firstLine = $firstLine -replace '^#+ ', '' -replace '[`*]', ''
      $indexContent += "`n- $folderName : $firstLine"
    }
    else {
      $indexContent += "`n- $folderName"
    }
  }
  
  $indexContent += @"


HOW TO USE
----------
Each component has its own subfolder containing:
- README.md and README.txt for overview
- _facts/*.yaml for structured metadata
- Additional documentation files as needed

For detailed information about a specific component, navigate to its subfolder.
"@
  
  Write-TxtFile -TxtPath $indexPath -Content $indexContent -ComponentName "$ComponentName Index"
}

# Main execution
Write-Host "=== Copilot TXT Generation ===" -ForegroundColor Green
Write-Host "DocsRoot: $DocsRoot"

if (!(Test-Path $DocsRoot)) {
  throw "DocsRoot not found: $DocsRoot"
}

$DocsRoot = Resolve-Path -Path $DocsRoot
Write-VerboseLog "Resolved DocsRoot: $DocsRoot"

# Define minimum required TXT files
$requiredTxtFiles = @(
  @{ Path = "README.txt"; Component = "AI Documentation Repository" }
  @{ Path = "tables\README.txt"; Component = "Tables" }
  @{ Path = "flows\README.txt"; Component = "Flows" }
  @{ Path = "plugins\README.txt"; Component = "Plugins" }
  @{ Path = "slas\README.txt"; Component = "SLAs" }
  @{ Path = "queues\README.txt"; Component = "Queues" }
  @{ Path = "workstreams\README.txt"; Component = "Workstreams" }
  @{ Path = "app-modules\README.txt"; Component = "App Modules" }
  @{ Path = "security-roles\README.txt"; Component = "Security Roles" }
)

# Generate all required TXT files
Write-Host "Generating required TXT files..."
foreach ($file in $requiredTxtFiles) {
  $mdPath = Join-Path $DocsRoot ($file.Path -replace '\.txt$', '.md')
  $txtPath = Join-Path $DocsRoot $file.Path
  
  $txtDir = Split-Path -Parent $txtPath
  if (!(Test-Path $txtDir)) {
    New-Item -ItemType Directory -Path $txtDir -Force | Out-Null
  }
  
  $content = Generate-TxtFromMarkdown -MdPath $mdPath -ComponentName $file.Component -FolderContext (Split-Path -Parent $file.Path)
  Write-TxtFile -TxtPath $txtPath -Content $content -ComponentName $file.Component
}

# Find and process all other README.md files
Write-Host "Discovering additional README.md files..."
$allReadmes = Get-ChildItem -Path $DocsRoot -Filter "README.md" -Recurse | 
  Where-Object { 
    $_.FullName -notmatch '\\RUNS\\' -and 
    $_.FullName -notmatch '\\node_modules\\' 
  }

foreach ($readme in $allReadmes) {
  $txtPath = $readme.FullName -replace '\.md$', '.txt'
  
  # Skip if already processed in required files
  $relPath = $txtPath.Substring($DocsRoot.Length + 1)
  if ($requiredTxtFiles.Path -contains $relPath) {
    continue
  }
  
  $relativePath = $readme.FullName.Substring($DocsRoot.Length + 1)
  $folderName = Split-Path -Leaf (Split-Path -Parent $readme.FullName)
  $componentName = $folderName -replace '_', ' ' -replace '-', ' '
  $componentName = (Get-Culture).TextInfo.ToTitleCase($componentName)
  
  Write-VerboseLog "Processing: $relativePath"
  
  $content = Generate-TxtFromMarkdown -MdPath $readme.FullName -ComponentName $componentName -FolderContext (Split-Path -Parent $relativePath)
  Write-TxtFile -TxtPath $txtPath -Content $content -ComponentName $componentName
}

# Generate index files for major component folders
Write-Host "Generating component indexes..."
$componentFolders = @("tables", "flows", "plugins", "queues", "slas", "workstreams", "app-modules", "security-roles")
foreach ($folder in $componentFolders) {
  $folderPath = Join-Path $DocsRoot $folder
  if (Test-Path $folderPath) {
    $componentName = $folder -replace '-', ' '
    $componentName = (Get-Culture).TextInfo.ToTitleCase($componentName)
    Generate-CopilotIndexTxt -FolderPath $folderPath -ComponentName $componentName
  }
}

# Validation
Write-Host "`nValidating generated TXT files..." -ForegroundColor Yellow
$validationErrors = @()

foreach ($file in $requiredTxtFiles) {
  $txtPath = Join-Path $DocsRoot $file.Path
  $validationError = Validate-TxtFile -TxtPath $txtPath
  
  if ($validationError) {
    $validationErrors += "[$($file.Path)] $validationError"
    Write-Host "  [FAIL] $($file.Path): $validationError" -ForegroundColor Red
  }
  else {
    Write-Host "  [OK] $($file.Path)" -ForegroundColor Green
  }
}

# Report statistics
Write-Host "`n=== Generation Statistics ===" -ForegroundColor Green
Write-Host "Created: $($script:stats.Created)"
Write-Host "Updated: $($script:stats.Updated)"
Write-Host "Skipped (no changes): $($script:stats.Skipped)"
Write-Host "Skipped (manual): $($script:stats.Manual)"

if ($validationErrors.Count -gt 0) {
  Write-Host "`n=== Validation Errors ===" -ForegroundColor Red
  foreach ($err in $validationErrors) {
    Write-Host "  $err" -ForegroundColor Red
  }
  
  if ($FailOnEmpty) {
    throw "TXT generation validation failed with $($validationErrors.Count) errors"
  }
}

Write-Host "`n[SUCCESS] Copilot TXT generation complete" -ForegroundColor Green
