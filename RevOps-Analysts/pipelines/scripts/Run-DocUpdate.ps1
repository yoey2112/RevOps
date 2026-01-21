param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("nightly", "postImport", "patchUpgrade")]
  [string]$Mode,

  [Parameter(Mandatory = $false)]
  [AllowNull()]
  [string]$ImportedSolutions
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-Env {
  param([Parameter(Mandatory = $true)][string]$Name)

  $v = [System.Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($v)) {
    throw ("Missing required environment variable: " + $Name)
  }
  return $v
}

function Require-EnvAny {
  param([Parameter(Mandatory = $true)][string[]]$Names)

  foreach ($n in $Names) {
    $v = [System.Environment]::GetEnvironmentVariable($n)
    if (-not [string]::IsNullOrWhiteSpace($v)) { return $v }
  }
  throw ("Missing required environment variable (any of): " + ($Names -join ", "))
}

# Normalize empty string -> $null
if ([string]::IsNullOrWhiteSpace($ImportedSolutions)) {
  $ImportedSolutions = $null
}

$repoRoot            = Require-Env "REPO_ROOT"
$projectName         = Require-Env "ADO_PROJECT_NAME"
$repoName            = Require-Env "ADO_REPO_NAME"
$defaultBranch       = Require-Env "ADO_DEFAULT_BRANCH"
$branchPrefix        = Require-Env "DOC_BRANCH_PREFIX"
# Accept legacy or simplified variable names for confidence/devcore solutions
$confidenceThreshold = Require-EnvAny @("DOC_CONFIDENCE_THRESHOLD", "CONFIDENCE_THRESHOLD")
$devCoreSolutions    = Require-EnvAny @("DOC_DEVCORE_SOLUTIONS", "DEVCORE_SOLUTIONS")

$dvOrgUrl       = Require-Env "DV_ORG_URL"
$dvTenantId     = Require-Env "DV_TENANT_ID"
$dvClientId     = Require-Env "DV_CLIENT_ID"
$dvClientSecret = Require-Env "DV_CLIENT_SECRET"
$dvApiVersion   = Require-Env "DV_API_VERSION"

# Optional DevCore environment (for comparison)
# If not configured separately, uses same credentials as Production
$dvDevCoreOrgUrl       = [System.Environment]::GetEnvironmentVariable("DV_DEVCORE_ORG_URL")
$dvDevCoreTenantId     = [System.Environment]::GetEnvironmentVariable("DV_DEVCORE_TENANT_ID")
$dvDevCoreClientId     = [System.Environment]::GetEnvironmentVariable("DV_DEVCORE_CLIENT_ID")
$dvDevCoreClientSecret = [System.Environment]::GetEnvironmentVariable("DV_DEVCORE_CLIENT_SECRET")
$dvDevCoreApiVersion   = [System.Environment]::GetEnvironmentVariable("DV_DEVCORE_API_VERSION")

# If any DevCore variable is specified, all must be specified. Otherwise, use Prod credentials.
$hasExplicitDevCore = -not [string]::IsNullOrWhiteSpace($dvDevCoreOrgUrl)

if (-not $hasExplicitDevCore) {
  # Use Production credentials for DevCore (same environment)
  $dvDevCoreOrgUrl = $dvOrgUrl
  $dvDevCoreTenantId = $dvTenantId
  $dvDevCoreClientId = $dvClientId
  $dvDevCoreClientSecret = $dvClientSecret
  $dvDevCoreApiVersion = $dvApiVersion
} else {
  # If only DV_DEVCORE_ORG_URL is specified, fill missing values from Production
  if ([string]::IsNullOrWhiteSpace($dvDevCoreTenantId)) { $dvDevCoreTenantId = $dvTenantId }
  if ([string]::IsNullOrWhiteSpace($dvDevCoreClientId)) { $dvDevCoreClientId = $dvClientId }
  if ([string]::IsNullOrWhiteSpace($dvDevCoreClientSecret)) { $dvDevCoreClientSecret = $dvClientSecret }
  if ([string]::IsNullOrWhiteSpace($dvDevCoreApiVersion)) { $dvDevCoreApiVersion = $dvApiVersion }
}

$hasDevCore = $true  # Always enable comparison since we have credentials

$modulePath = Join-Path $repoRoot "pipelines/scripts/DocGen/DocGen.psm1"
Import-Module $modulePath -Force

$runDate   = (Get-Date).ToString("yyyyMMdd")
$runId     = (Get-Date).ToString("yyyyMMdd-HHmmss")
# Use unique per-run branch to avoid race conditions and ensure push failures are visible
$branchName = "$branchPrefix/$runId"

Write-Host "Mode: $Mode"
Write-Host "RunId: $runId"
Write-Host "Branch: $branchName"
Write-Host ""
Write-Host "=== PREFLIGHT CHECKS ==="

# Log all required env vars
Write-Host "REPO_ROOT: $repoRoot"
Write-Host "ADO_PROJECT_NAME: $projectName"
Write-Host "ADO_REPO_NAME: $repoName"
Write-Host "ADO_DEFAULT_BRANCH: $defaultBranch"
Write-Host "DOC_BRANCH_PREFIX: $branchPrefix"
Write-Host "DOC_CONFIDENCE_THRESHOLD: $confidenceThreshold"
Write-Host "DV_ORG_URL: $dvOrgUrl"
Write-Host "DV_TENANT_ID: [set]"
Write-Host "DV_CLIENT_ID: [set]"
Write-Host "DV_API_VERSION: $dvApiVersion"

Write-Host "DV_DEVCORE_ORG_URL: $dvDevCoreOrgUrl"
Write-Host "DV_DEVCORE_TENANT_ID: [set]"
Write-Host "DV_DEVCORE_CLIENT_ID: [set]"
Write-Host "DV_DEVCORE_API_VERSION: $dvDevCoreApiVersion"
if ($hasExplicitDevCore) {
  Write-Host "DevCore: Separate credentials configured" -ForegroundColor Cyan
} else {
  Write-Host "DevCore: Using Production credentials (same environment)" -ForegroundColor Cyan
}

$token = $env:SYSTEM_ACCESSTOKEN
if ([string]::IsNullOrWhiteSpace($token)) {
  throw "SYSTEM_ACCESSTOKEN is not available. Ensure 'Allow scripts to access the OAuth token' is enabled."
}
Write-Host "SYSTEM_ACCESSTOKEN: [set]"
Write-Host ""
Write-Host "=== PREFLIGHT COMPLETE ==="
Write-Host ""

$aidocsRoot = Join-Path $repoRoot "AIDocumentation"
Initialize-AIDocsScaffold -AIDocsRoot $aidocsRoot

$dv = New-DataverseConnectionInfo `
  -OrgUrl $dvOrgUrl `
  -TenantId $dvTenantId `
  -ClientId $dvClientId `
  -ClientSecret $dvClientSecret `
  -ApiVersion $dvApiVersion

# Validate Dataverse connectivity BEFORE expensive operations
Write-Host "Validating Dataverse connectivity..."
try {
  $dvToken = Get-DataverseAccessToken -Dataverse $dv
  Write-Host "✓ Dataverse authentication successful"
} catch {
  Write-Host "✗ FAILED to authenticate to Dataverse"
  Write-Host "Error: $($_.Exception.Message)"
  throw "Cannot proceed without Dataverse access"
}

$devCoreList = $devCoreSolutions.Split(",") |
  ForEach-Object { $_.Trim() } |
  Where-Object { $_ }

$threshold = [double]$confidenceThreshold

# Build context args safely
$contextArgs = @{
  RepoRoot            = $repoRoot
  AIDocsRoot          = $aidocsRoot
  RunId               = $runId
  Mode                = $Mode
  DevCoreSolutions    = $devCoreList
  ConfidenceThreshold = $threshold
  Dataverse           = $dv
  ProjectName         = $projectName
  RepoName            = $repoName
  DefaultBranch       = $defaultBranch
  BranchName          = $branchName
  SystemAccessToken   = $token
}

# Add DevCore connection if configured
if ($hasDevCore) {
  $dvDevCore = New-DataverseConnectionInfo `
    -OrgUrl $dvDevCoreOrgUrl `
    -TenantId $dvDevCoreTenantId `
    -ClientId $dvDevCoreClientId `
    -ClientSecret $dvDevCoreClientSecret `
    -ApiVersion $dvDevCoreApiVersion
  
  $contextArgs.DataverseDevCore = $dvDevCore
  Write-Host "✓ DevCore environment configured for comparison"
}

# Only include when meaningful
if ($ImportedSolutions) {
  $contextArgs.ImportedSolutions = $ImportedSolutions
}

$context = New-DocGenContext @contextArgs

Write-Host "Ensuring branch exists and is up to date..."
Ensure-BranchFromDefault -Context $context

Write-Host "Running DocGen..."
$rawResult = Invoke-DocGenRun -Context $context

# Handle case where pipeline pollution causes $result to be an array
# The actual return object is always the last item
$result = if ($rawResult -is [array]) { $rawResult[-1] } else { $rawResult }

Write-Host "DocGen complete. Overall confidence: $($result.OverallConfidence)"
Write-Host "Gate pass: $($result.GatePass)"

Write-Host "Generating category README.md files..."
$categoryReadmeScript = Join-Path $PSScriptRoot "Generate-CategoryReadmes.ps1"
if (Test-Path $categoryReadmeScript) {
  try {
    & $categoryReadmeScript -DocsRoot $aidocsRoot
    Write-Host "[SUCCESS] Category README generation complete" -ForegroundColor Green
  }
  catch {
    Write-Host "##[error]Category README generation failed: $_" -ForegroundColor Red
    throw
  }
}
else {
  Write-Warning "Category README generation script not found at: $categoryReadmeScript"
}

Write-Host "Generating Copilot-friendly TXT files..."
$txtGenScript = Join-Path $PSScriptRoot "Generate-CopilotTxt.ps1"
if (Test-Path $txtGenScript) {
  try {
    & $txtGenScript -DocsRoot $aidocsRoot -FailOnEmpty -Verbose:$VerbosePreference
    Write-Host "[SUCCESS] Copilot TXT generation complete" -ForegroundColor Green
  }
  catch {
    Write-Host "##[error]Copilot TXT generation failed: $_" -ForegroundColor Red
    throw
  }
}
else {
  Write-Warning "Copilot TXT generation script not found at: $txtGenScript"
}

Write-Host "Committing changes..."
$commitResult = Commit-AndPushChanges `
  -Context $context `
  -CommitMessage $result.CommitMessage

if (-not $commitResult.HadChanges) {
  Write-Host "No changes detected. Exiting."
  exit 0
}

Write-Host "Creating or updating PR..."
$pr = Ensure-PullRequest `
  -Context $context `
  -Title $result.PrTitle `
  -Description $result.PrDescription

if ($result.GatePass) {
  Write-Host "Gate passed. Setting PR to auto-complete..."
  Set-PRAutoComplete `
    -Context $context `
    -PullRequestId $pr.pullRequestId
  Write-Host "PR set to auto-complete."
}
else {
  Write-Host "Gate did not pass. PR will remain open for review."
}

Write-Host "Done."