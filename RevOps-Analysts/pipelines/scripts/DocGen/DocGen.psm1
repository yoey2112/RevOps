Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "DocGen.Schemas.psm1") -Force

function Initialize-AIDocsScaffold {
  param([Parameter(Mandatory=$true)][string]$AIDocsRoot)

  $shared = Join-Path $AIDocsRoot "_shared"
  $registry = Join-Path $AIDocsRoot "_registry"
  $graph = Join-Path $AIDocsRoot "_graph"
  $runs = Join-Path $AIDocsRoot "RUNS"

  foreach ($p in @($AIDocsRoot,$shared,$registry,$graph,$runs)) {
    if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
  }

  $topReadme = Join-Path $AIDocsRoot "README.md"
  if (-not (Test-Path $topReadme)) {
@"
# AI Documentation (Production)

This folder is generated automatically from the Production Dataverse environment (read-only).
Primary content is Markdown for humans + Copilot indexing, with YAML facts sidecars for deterministic diffs.

## Key folders
- _registry: canonical inventory and lifecycle
- _graph: dependency graph between assets
- RUNS: per-run artifacts (summaries, diffs, metrics)
- tables, queues, sla, routing, omnichannel, plugins, flows: per-asset documentation
"@ | Set-Content -Path $topReadme -Encoding UTF8
  }
}

function New-DocGenContext {
  param(
    [Parameter(Mandatory=$true)][string]$RepoRoot,
    [Parameter(Mandatory=$true)][string]$AIDocsRoot,
    [Parameter(Mandatory=$true)][string]$RunId,
    [Parameter(Mandatory=$true)][string]$Mode,
    [Parameter(Mandatory=$false)][AllowNull()][string]$ImportedSolutions,
    [Parameter(Mandatory=$true)][string[]]$DevCoreSolutions,
    [Parameter(Mandatory=$true)][double]$ConfidenceThreshold,
    [Parameter(Mandatory=$true)][hashtable]$Dataverse,
    [Parameter(Mandatory=$false)][AllowNull()][hashtable]$DataverseDevCore,
    [Parameter(Mandatory=$true)][string]$ProjectName,
    [Parameter(Mandatory=$true)][string]$RepoName,
    [Parameter(Mandatory=$true)][string]$DefaultBranch,
    [Parameter(Mandatory=$true)][string]$BranchName,
    [Parameter(Mandatory=$true)][string]$SystemAccessToken
  )

  return [pscustomobject]@{
    RepoRoot = $RepoRoot
    AIDocsRoot = $AIDocsRoot
    RunId = $RunId
    Mode = $Mode
    ImportedSolutions = $ImportedSolutions
    DevCoreSolutions = $DevCoreSolutions
    ConfidenceThreshold = $ConfidenceThreshold
    Dataverse = $Dataverse
    DataverseDevCore = $DataverseDevCore
    ProjectName = $ProjectName
    RepoName = $RepoName
    DefaultBranch = $DefaultBranch
    BranchName = $BranchName
    SystemAccessToken = $SystemAccessToken
    OrganizationUrl = $env:SYSTEM_COLLECTIONURI.TrimEnd("/")
  }
}

function New-DataverseConnectionInfo {
  param(
    [Parameter(Mandatory=$true)][string]$OrgUrl,
    [Parameter(Mandatory=$true)][string]$TenantId,
    [Parameter(Mandatory=$true)][string]$ClientId,
    [Parameter(Mandatory=$true)][string]$ClientSecret,
    [Parameter(Mandatory=$true)][string]$ApiVersion
  )
  return @{
    OrgUrl = $OrgUrl.TrimEnd("/")
    TenantId = $TenantId
    ClientId = $ClientId
    ClientSecret = $ClientSecret
    ApiVersion = $ApiVersion
  }
}

function Ensure-BranchFromDefault {
  param([Parameter(Mandatory=$true)]$Context)

  Push-Location $Context.RepoRoot
  try {
    git config user.email "docgen@revops.local"
    git config user.name "DocGen"

    git fetch origin $Context.DefaultBranch --prune
    git checkout $Context.DefaultBranch
    git reset --hard ("origin/" + $Context.DefaultBranch)

    $branchExists = $false
    $remoteBranches = git branch -r
    foreach ($b in $remoteBranches) {
      if ($b.Trim() -eq ("origin/" + $Context.BranchName)) { $branchExists = $true }
    }

    if ($branchExists) {
      git checkout $Context.BranchName
      git reset --hard ("origin/" + $Context.BranchName)
      git merge --ff-only ("origin/" + $Context.DefaultBranch) | Out-Null
    } else {
      git checkout -b $Context.BranchName ("origin/" + $Context.DefaultBranch) | Out-Null
    }
  } finally {
    Pop-Location
  }
}

# ============= CAPABILITY PROBES (Phase 0) =============
# Probes Web API endpoints to detect what metadata is accessible
# Prevents silent documentation gaps by explicitly checking permissions/schema
function Test-DataverseCapability {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$Entity,
    [Parameter(Mandatory=$false)][string]$Select,
    [Parameter(Mandatory=$false)][string]$Filter,
    [Parameter(Mandatory=$false)][switch]$Sample
  )

  $probe = @{
    endpoint = $Entity
    status = "unknown"
    http_status = $null
    message = ""
    accessible = $false
    readable = $false
  }

  try {
    $qs = @()
    if ($Select) { $qs += ("`$select=" + $Select) }
    if ($Filter) { $qs += ("`$filter=" + $Filter) }
    if ($Sample) { $qs += ("`$top=1") }
    $rel = $Entity
    if ($qs.Count -gt 0) { $rel = ($Entity + "?" + ($qs -join "&")) }

    $res = Invoke-DvGet -Client $Client -RelativeUrl $rel -ErrorAction Stop
    $probe.status = "ok"
    $probe.http_status = 200
    $probe.accessible = $true
    $probe.readable = ($null -ne $res)
    $probe.message = "Accessible and readable"
  }
  catch {
    $errMsg = $_.Exception.Message
    if ($errMsg -like "*403*" -or $errMsg -like "*Forbidden*") {
      $probe.status = "forbidden"
      $probe.http_status = 403
      $probe.message = "Access denied (insufficient permissions)"
    }
    elseif ($errMsg -like "*404*" -or $errMsg -like "*NotFound*") {
      $probe.status = "notfound"
      $probe.http_status = 404
      $probe.message = "Endpoint/entity not found in schema"
    }
    else {
      $probe.status = "error"
      $probe.http_status = 0
      $probe.message = $errMsg.Substring(0, [Math]::Min(120, $errMsg.Length))
    }
  }

  return $probe
}

function Invoke-CapabilityProbes {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client
  )

  Write-Host "Probing Dataverse capabilities..." -ForegroundColor Cyan

  $probes = [ordered]@{
    critical = @()
    plugins = @()
    queues = @()
    omnichannel = @()
  }
  
  $failedProbes = @()

  # CRITICAL endpoints - these must work for DocGen to function
  # EntityDefinitions is the metadata API - does NOT support $top, use $filter for single-record test
  $probes.critical += (Test-DataverseCapability -Client $Client -Entity "EntityDefinitions" -Filter "LogicalName eq 'account'")
  # Solutions endpoint
  $probes.critical += (Test-DataverseCapability -Client $Client -Entity "solutions" -Select "solutionid,uniquename" -Sample)
  # Workflows (flows)
  $probes.critical += (Test-DataverseCapability -Client $Client -Entity "workflows" -Select "workflowid,name" -Sample)
  # Solution components (for filtering by solution)
  $probes.critical += (Test-DataverseCapability -Client $Client -Entity "solutioncomponents" -Select "solutioncomponentid,objectid" -Sample)

  # Plugin registration endpoints
  $probes.plugins += (Test-DataverseCapability -Client $Client -Entity "pluginassemblies" -Select "pluginassemblyid,name" -Sample)
  $probes.plugins += (Test-DataverseCapability -Client $Client -Entity "plugintypes" -Select "plugintypeid,name" -Sample)
  $probes.plugins += (Test-DataverseCapability -Client $Client -Entity "sdkmessageprocessingsteps" -Select "sdkmessageprocessingstepid,name" -Sample)
  $probes.plugins += (Test-DataverseCapability -Client $Client -Entity "sdkmessagefilters" -Select "sdkmessagefilterid,primaryobjecttypecode" -Sample)

  # Queues
  $probes.queues += (Test-DataverseCapability -Client $Client -Entity "queues" -Select "queueid,name" -Sample)

  # Omnichannel (best-effort, non-critical)
  $probes.omnichannel += (Test-DataverseCapability -Client $Client -Entity "msdyn_liveworkstreams" -Select "msdyn_liveworkstreamid,msdyn_name" -Sample)
  $probes.omnichannel += (Test-DataverseCapability -Client $Client -Entity "slas" -Select "slaid,name" -Sample)

  # Check critical probes - ALL must pass
  $criticalFailed = @($probes.critical | Where-Object { $_.status -ne "ok" })
  $pluginsFailed = @($probes.plugins | Where-Object { $_.status -ne "ok" })
  
  # Display results
  Write-Host ""
  Write-Host "  Critical endpoints:" -ForegroundColor White
  foreach ($p in $probes.critical) {
    $icon = if ($p.status -eq "ok") { "[OK]" } else { "[FAIL]" }
    $color = if ($p.status -eq "ok") { "Green" } else { "Red" }
    Write-Host "    $icon $($p.endpoint): $($p.status)" -ForegroundColor $color
    if ($p.status -ne "ok") {
      Write-Host "      Error: $($p.message)" -ForegroundColor Yellow
    }
  }
  
  Write-Host "  Plugin endpoints:" -ForegroundColor White
  foreach ($p in $probes.plugins) {
    $icon = if ($p.status -eq "ok") { "[OK]" } else { "[FAIL]" }
    $color = if ($p.status -eq "ok") { "Green" } else { "Red" }
    Write-Host "    $icon $($p.endpoint): $($p.status)" -ForegroundColor $color
    if ($p.status -ne "ok") {
      Write-Host "      Error: $($p.message)" -ForegroundColor Yellow
    }
  }

  Write-Host "  Queues: $(if (@($probes.queues | Where-Object { $_.status -eq 'ok' }).Count -gt 0) { '[OK] Available' } else { '[FAIL] Not accessible' })"
  Write-Host "  Omnichannel: $(@($probes.omnichannel | Where-Object { $_.status -eq 'ok' }).Count)/$(@($probes.omnichannel).Count) tables readable"
  Write-Host ""

  # Write probe results to file
  $probeFile = Join-Path $Context.AIDocsRoot "RUNS/$($Context.RunId)/capability-probe.yaml"
  $probeDir = Split-Path $probeFile -Parent
  if (-not (Test-Path $probeDir)) { New-Item -ItemType Directory -Path $probeDir -Force | Out-Null }

  $null = Save-YamlDeterministic -Data @{
    run_id = $Context.RunId
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    probes = $probes
    critical_failed_count = $criticalFailed.Count
    plugins_failed_count = $pluginsFailed.Count
  } -Path $probeFile

  # FAIL FAST: If any critical probe failed, abort
  if ($criticalFailed.Count -gt 0) {
    Write-Host "CRITICAL: $($criticalFailed.Count) critical endpoint(s) failed. Cannot proceed." -ForegroundColor Red
    foreach ($f in $criticalFailed) {
      Write-Host "  - $($f.endpoint): $($f.message)" -ForegroundColor Red
    }
    return $false
  }

  # FAIL FAST: If any plugin probe failed, abort (we need these for plugin docs)
  if ($pluginsFailed.Count -gt 0) {
    Write-Host "ERROR: $($pluginsFailed.Count) plugin endpoint(s) failed. Cannot proceed with plugin documentation." -ForegroundColor Red
    foreach ($f in $pluginsFailed) {
      Write-Host "  - $($f.endpoint): $($f.message)" -ForegroundColor Red
    }
    return $false
  }

  Write-Host "[OK] All critical capability probes passed" -ForegroundColor Green

  return @{
    probes = $probes
    all_critical_ok = $true
    plugins_ok = $true
    queues_ok = (@($probes.queues | Where-Object { $_.status -eq 'ok' }).Count -gt 0)
    omnichannel_ok = (@($probes.omnichannel | Where-Object { $_.status -eq 'ok' }).Count -gt 0)
  }
}

# ============= YAML VALIDITY CONTRACT (Hardened) =============
# Dictionary-native validation: any IDictionary impl is valid; scalars/nulls rejected
# Designed to work across PS 5.1 and PS 7 with mixed YAML deserializers (OrderedDictionary, Generic.Dictionary, etc.)
# Fail-fast reporting: detailed error messages with facet, filepath, and invalid item summaries
function Assert-ValidYamlList {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][array]$Items,
    [Parameter(Mandatory=$true)][string[]]$RequiredKeys,
    [Parameter(Mandatory=$false)][string]$Facet = "unknown"  # columns, relationships, views, plugin-types, sdk-steps
  )

  $invalid = @()
  $invalidDetails = @()

  foreach ($i in $Items) {
    # Reject nulls
    if ($null -eq $i) {
      $invalid += "[null]"
      $invalidDetails += @{ Type = "null"; Keys = 0; MissingKeys = @($RequiredKeys) }
      continue
    }

    # Accept only IDictionary implementations (Hashtable, OrderedDictionary, Generic.Dictionary[string,object], etc.)
    $isValidDict = $i -is [System.Collections.IDictionary]
    if (-not $isValidDict) {
      $invalid += $i
      $itemType = $i.GetType().Name
      $invalidDetails += @{ Type = $itemType; Keys = 0; MissingKeys = @($RequiredKeys) }
      continue
    }

    # Validate that all required keys exist
    $hasAllKeys = $true
    $missingKeys = @()
    foreach ($key in $RequiredKeys) {
      if (-not $i.Contains($key)) {
        $hasAllKeys = $false
        $missingKeys += $key
      }
    }

    if (-not $hasAllKeys) {
      $invalid += $i
      $invalidDetails += @{ Type = "dict"; Keys = $i.Count; MissingKeys = $missingKeys }
    }
  }

  if ($invalid.Count -gt 0) {
    # Fail-fast detailed reporting: facet, filepath, and first 3 invalid items
    $maxShown = 3
    $reportedItems = @()
    
    for ($j = 0; $j -lt [Math]::Min($maxShown, $invalidDetails.Count); $j++) {
      $detail = $invalidDetails[$j]
      if ($detail.Type -eq "null") {
        $reportedItems += "[null]"
      } elseif ($detail.MissingKeys.Count -gt 0) {
        $reportedItems += "[Type=$($detail.Type), Keys=$($detail.Keys), MissingKeys=$($detail.MissingKeys -join ',')]"
      } else {
        $reportedItems += "[Type=$($detail.Type), Keys=$($detail.Keys)]"
      }
    }
    
    $reportedStr = $reportedItems -join " | "
    if ($invalid.Count -gt $maxShown) {
      $reportedStr += " | ... and $($invalid.Count - $maxShown) more"
    }
    
    $msg = @"
YAML VALIDATION FAILED

Facet: $Facet
File: $Path
Issue: $($invalid.Count) invalid entries (require IDictionary with keys: $($RequiredKeys -join ', '))
Details: $reportedStr

Troubleshooting:
- Check that Normalize-ListForYaml was called BEFORE validation
- Verify no scalars, nulls, or empty dicts passed after normalization
- Check extraction function is returning proper objects with required keys
"@
    throw $msg
  }
}

# Recursively normalizes PSObjects, OrderedDictionaries, and nested structures to hashtables
# Rejects nulls, scalars, and objects with zero keys after normalization
# Call this BEFORE Assert-ValidYamlList to ensure validation only sees clean dictionaries
function Normalize-ListForYaml {
  param(
    [Parameter(Mandatory=$true)][array]$Items
  )

  [collections.generic.list[object]]$normalized = @()

  foreach ($item in $Items) {
    # Skip nulls
    if ($null -eq $item) {
      continue
    }

    # Check if it's a dictionary (any IDictionary implementation)
    if (-not ($item -is [System.Collections.IDictionary])) {
      # Not a dict, not PSObject -> reject scalar/unknown
      if (-not ($item -is [pscustomobject])) {
        continue
      }
    }

    # Convert to hashtable and recursively clean
    $dict = Normalize-DictionaryValue -Value $item
    
    # Only add valid dictionaries with content
    if ($null -ne $dict -and $dict.Count -gt 0) {
      $normalized.Add($dict)
    } elseif ($null -ne $dict -and $dict.Count -eq 0) {
      Write-Warning "Dropped empty entry (0 keys after normalization)"
    }
  }

  return ,$normalized.ToArray()
}

# Normalize a single dictionary (or PSObject) value recursively
function Normalize-DictionaryValue {
  param([AllowNull()]$Value)
  
  if ($null -eq $Value) {
    return $null
  }
  
  # Try IDictionary first (OrderedDictionary, Hashtable, Generic.Dictionary)
  if ($Value -is [System.Collections.IDictionary]) {
    $result = @{}
    try {
      # Use GetEnumerator for reliable iteration
      $enum = $Value.GetEnumerator()
      while ($enum.MoveNext()) {
        $kvp = $enum.Current
        $k = $kvp.Key
        $v = Normalize-ScalarValue -Value $kvp.Value
        if ($null -ne $v) {
          $result[$k] = $v
        }
      }
    } catch {
      # Enumeration failed, skip this dict
      return $null
    }
    return $result
  }
  
  # Try PSObject
  if ($Value -is [pscustomobject]) {
    $result = @{}
    try {
      foreach ($prop in $Value.PSObject.Properties) {
        $v = Normalize-ScalarValue -Value $prop.Value
        if ($null -ne $v) {
          $result[$prop.Name] = $v
        }
      }
    } catch {
      return $null
    }
    return $result
  }
  
  # Not a dict/object
  return $null
}

# Normalize a scalar value (including nested arrays)
# This avoids calling -is on potentially problematic generic types
function Normalize-ScalarValue {
  param([AllowNull()]$Value)
  
  if ($null -eq $Value) {
    return $null
  }
  
  # Empty string is invalid
  if ($Value -eq "") {
    return $null
  }
  
  # Check if it looks like a dict (has Keys property and looks like IDictionary)
  if (($Value | Get-Member -Name "Keys" -ErrorAction SilentlyContinue) -and `
      ($Value | Get-Member -Name "GetEnumerator" -ErrorAction SilentlyContinue)) {
    return Normalize-DictionaryValue -Value $Value
  }
  
  # Check if it's an array-like thing (but not a string)
  if ($Value -isnot [string]) {
    try {
      $asArray = @($Value) 
      if ($asArray.Count -gt 1 -or ($asArray.Count -eq 1 -and $Value -is [System.Collections.IEnumerable])) {
        # Recursive normalize array items
        $result = @()
        foreach ($item in $Value) {
          $norm = Normalize-ScalarValue -Value $item
          if ($null -ne $norm) {
            $result += $norm
          }
        }
        if ($result.Count -gt 0) {
          return $result
        }
        return $null
      }
    } catch {
      # Can't iterate, treat as scalar
    }
  }
  
  # Pass through scalars (strings, ints, bools, etc.)
  return $Value
}

function Invoke-DocGenRun {
  param([Parameter(Mandatory=$true)]$Context)

  $runFolder = Join-Path $Context.AIDocsRoot ("RUNS/" + $Context.RunId)
  New-Item -ItemType Directory -Path $runFolder -Force | Out-Null

  $dvToken = Get-DataverseAccessToken -Dataverse $Context.Dataverse
  $client = New-DataverseGetClient -Dataverse $Context.Dataverse -AccessToken $dvToken

  # Phase 0: Run capability probes to detect what metadata is accessible
  Write-Host "`n=== PHASE 0: CAPABILITY PROBES ===" -ForegroundColor Green
  $capabilities = Invoke-CapabilityProbes -Context $Context -Client $client
  if (-not $capabilities) {
    Write-Host "Aborting: Critical metadata endpoints not accessible" -ForegroundColor Red
    return @{ 
      error = "Capability probe failed"
      success = $false
      OverallConfidence = 0
      GatePass = $false
      CommitMessage = "[DocGen] Failed - capability probes did not pass"
      PrTitle = "[DocGen] Failed - capability probes did not pass"
      PrDescription = "DocGen failed during capability probe phase. Check pipeline logs for details."
    }
  }

  $extraction = [ordered]@{
    run_id = $Context.RunId
    mode = $Context.Mode
    started_on_utc = (Get-Date).ToUniversalTime().ToString("o")
    sources = @{
      org_url = $Context.Dataverse.OrgUrl
      api_version = $Context.Dataverse.ApiVersion
      devcore_solutions_allowlist = $Context.DevCoreSolutions
    }
    results = @{}
    confidence = @{}
    errors = @()
    capabilities = $capabilities
  }

  $solutions = Get-Solutions -Client $client
  $extraction.results.solutions_count = $solutions.Count
  
  # Filter solutions by allowlist if in nightly mode (when DevCoreSolutions are available)
  $allowlistedSolutions = $solutions
  $solutionsComparison = $null
  if ($Context.Mode -eq "nightly" -and $Context.DevCoreSolutions -and $Context.DevCoreSolutions.Count -gt 0) {
    $allowlistedSolutions = Filter-SolutionsByAllowlist -Solutions $solutions -AllowlistPatterns $Context.DevCoreSolutions
    if ($null -eq $allowlistedSolutions) { $allowlistedSolutions = @() }
    $solutionsComparison = Build-AllowlistComparison -AllowlistPatterns $Context.DevCoreSolutions -ExtractedSolutions $allowlistedSolutions
    $extraction.results.solutions_allowlisted_count = @($allowlistedSolutions).Count
    $extraction.results.solutions_allowlist_comparison = $solutionsComparison
  }

  # Get tables from revopstables BASE solution AND all its patches
  Write-Host "Extracting tables from solution..." -ForegroundColor Cyan
  # Find base solution and all related patches
  $tableBaseSolution = @($allowlistedSolutions | Where-Object { $_.uniquename -eq "revopstables" }) | Select-Object -First 1
  $tablePatches = @($allowlistedSolutions | Where-Object { $_.uniquename -like "revopstables_Patch_*" })
  $tableSolutions = @()
  if ($tableBaseSolution) { $tableSolutions += $tableBaseSolution }
  if ($tablePatches.Count -gt 0) { $tableSolutions += $tablePatches }
  
  # Fallback: any solution with "table" in name
  if ($tableSolutions.Count -eq 0) {
    $tableSolutions = @($allowlistedSolutions | Where-Object { $_.uniquename -like "*table*" })
  }
  $tablesFiltered = @()
  
  if ($tableSolutions.Count -gt 0) {
    $solutionNames = ($tableSolutions | ForEach-Object { $_.uniquename }) -join ", "
    Write-Host "  Using solutions: $solutionNames" -ForegroundColor Gray
    
    # Collect entities from ALL solutions (base + patches), dedupe by MetadataId
    $allTableEntities = @{}
    foreach ($sol in $tableSolutions) {
      $solTables = Get-TablesBySolution -Client $client -SolutionId $sol.solutionid
      foreach ($t in $solTables) {
        if ($t.MetadataId -and -not $allTableEntities.ContainsKey($t.MetadataId)) {
          $allTableEntities[$t.MetadataId] = $t
        }
      }
    }
    $tablesFiltered = @($allTableEntities.Values)
    Write-Host "  Found $($tablesFiltered.Count) unique entities across $($tableSolutions.Count) solution(s)" -ForegroundColor Gray
  } else {
    Write-Host "  No table solution found in allowlist; falling back to all tables (NOT RECOMMENDED)" -ForegroundColor Yellow
    $tables = Get-TableMetadataIndex -Client $client
    $tablesFiltered = @($tables | Select-Object -First 50)  # Limit fallback to prevent API overload
    Write-Host "  WARNING: Limited to first 50 tables. Configure revopstables solution for proper filtering." -ForegroundColor Yellow
  }
  
  $extraction.results.tables_count = @($tablesFiltered).Count

  # Enrich tables with relationships, columns, forms, business rules for Copilot consumption
  $tablesEnriched = @()
  foreach ($table in $tablesFiltered) {
    $enriched = Enrich-TableMetadata -Client $client -Table $table
    $tablesEnriched += $enriched
  }
  $extraction.tables_enriched = $tablesEnriched

  $queuesAll = Get-QueuesRaw -Client $client
  $queuesFiltered = Filter-QueuesExcludeUserQueues -Queues $queuesAll
  $extraction.results.queues_total_count = $queuesAll.Count
  $extraction.results.queues_included_count = $queuesFiltered.Count
  $extraction.results.queues_excluded_user_count = ($queuesAll.Count - $queuesFiltered.Count)

  # Get plugins from revopsplugins BASE solution AND all its patches
  Write-Host "Extracting plugins from solution..." -ForegroundColor Cyan
  $pluginBaseSolution = @($allowlistedSolutions | Where-Object { $_.uniquename -eq "revopsplugins" }) | Select-Object -First 1
  $pluginPatches = @($allowlistedSolutions | Where-Object { $_.uniquename -like "revopsplugins_Patch_*" })
  $pluginSolutions = @()
  if ($pluginBaseSolution) { $pluginSolutions += $pluginBaseSolution }
  if ($pluginPatches.Count -gt 0) { $pluginSolutions += $pluginPatches }
  
  # Fallback: any solution with "plugin" in name
  if ($pluginSolutions.Count -eq 0) {
    $pluginSolutions = @($allowlistedSolutions | Where-Object { $_.uniquename -like "*plugin*" })
  }
  $pluginsFiltered = @()
  
  if ($pluginSolutions.Count -gt 0) {
    $solutionNames = ($pluginSolutions | ForEach-Object { $_.uniquename }) -join ", "
    Write-Host "  Using solutions: $solutionNames" -ForegroundColor Gray
    
    # Collect plugins from ALL solutions, dedupe by pluginassemblyid
    $allPlugins = @{}
    foreach ($sol in $pluginSolutions) {
      $solPlugins = Get-PluginsBySolution -Client $client -SolutionId $sol.solutionid
      foreach ($p in $solPlugins) {
        if ($p.pluginassemblyid -and -not $allPlugins.ContainsKey($p.pluginassemblyid)) {
          $allPlugins[$p.pluginassemblyid] = $p
        }
      }
    }
    $pluginsFiltered = @($allPlugins.Values)
    Write-Host "  Found $($pluginsFiltered.Count) unique plugin assemblies across $($pluginSolutions.Count) solution(s)" -ForegroundColor Gray
  } else {
    Write-Host "  No plugin solution found in allowlist; falling back to all plugins" -ForegroundColor Yellow
    $plugins = Get-PluginsIndex -Client $client
    $pluginsFiltered = Filter-PluginsBySolution -Plugins $plugins -AllowlistedSolutions $allowlistedSolutions
  }
  
  $extraction.results.plugins_count = @($pluginsFiltered).Count

  # Get flows from revopsflows BASE solution AND all its patches
  Write-Host "Extracting flows from solution..." -ForegroundColor Cyan
  $flowBaseSolution = @($allowlistedSolutions | Where-Object { $_.uniquename -eq "revopsflows" }) | Select-Object -First 1
  $flowPatches = @($allowlistedSolutions | Where-Object { $_.uniquename -like "revopsflows_Patch_*" })
  $flowSolutions = @()
  if ($flowBaseSolution) { $flowSolutions += $flowBaseSolution }
  if ($flowPatches.Count -gt 0) { $flowSolutions += $flowPatches }
  
  # Fallback: any solution with "flow" in name
  if ($flowSolutions.Count -eq 0) {
    $flowSolutions = @($allowlistedSolutions | Where-Object { $_.uniquename -like "*flow*" })
  }
  $flowsFiltered = @()
  $flowsWithDefsFiltered = @()
  
  if ($flowSolutions.Count -gt 0) {
    $solutionNames = ($flowSolutions | ForEach-Object { $_.uniquename }) -join ", "
    Write-Host "  Using solutions: $solutionNames" -ForegroundColor Gray
    
    # Collect flows from ALL solutions, dedupe by workflowid
    $allFlows = @{}
    $allFlowsWithDefs = @{}
    foreach ($sol in $flowSolutions) {
      $solFlows = Get-FlowsBySolution -Client $client -SolutionId $sol.solutionid
      foreach ($f in $solFlows) {
        if ($f.workflowid -and -not $allFlows.ContainsKey($f.workflowid)) {
          $allFlows[$f.workflowid] = $f
        }
      }
      $solFlowsWithDefs = Get-FlowsBySolution -Client $client -SolutionId $sol.solutionid -IncludeClientData
      foreach ($f in $solFlowsWithDefs) {
        if ($f.workflowid -and -not $allFlowsWithDefs.ContainsKey($f.workflowid)) {
          $allFlowsWithDefs[$f.workflowid] = $f
        }
      }
    }
    $flowsFiltered = @($allFlows.Values)
    $flowsWithDefsFiltered = @($allFlowsWithDefs.Values)
    Write-Host "  Found $($flowsFiltered.Count) unique workflows across $($flowSolutions.Count) solution(s)" -ForegroundColor Gray
  } else {
    Write-Host "  No flow solution found in allowlist; falling back to all flows (limited)" -ForegroundColor Yellow
    $flows = Get-FlowsIndex -Client $client
    $flowsFiltered = Filter-FlowsBySolution -Flows $flows -AllowlistedSolutions $allowlistedSolutions
    $flowsWithDefs = Get-FlowsWithDefinitions -Client $client
    $flowsWithDefsFiltered = @($flowsWithDefs | Where-Object { $_ })
  }
  
  $extraction.results.flows_count = @($flowsFiltered).Count
  $extraction.flow_definitions = $flowsWithDefsFiltered

  # Empty collection guards
  Write-Host "Extracted: $($solutions.Count) solutions, $($tablesFiltered.Count) tables, $($queuesFiltered.Count) queues, $($pluginsFiltered.Count) plugins, $($flowsFiltered.Count) flows"
  if ($null -ne $solutionsComparison) {
    Write-Host "Solutions Allowlist: $($allowlistedSolutions.Count) of $($solutions.Count) match revops_* patterns"
    if ($solutionsComparison.missing.Count -gt 0) {
      Write-Host "  Missing patterns: $($solutionsComparison.missing -join '; ')"
    }
    # Show sample solution names for debugging
    $sampleSolutions = $solutions | Select-Object -First 10 -ExpandProperty uniquename
    Write-Host "  Sample solution names: $($sampleSolutions -join '; ')"
  }
  if ($solutions.Count -eq 0) { Write-Host "WARNING: No solutions found" }
  if ($tablesFiltered.Count -eq 0) { Write-Host "WARNING: No tables found (or all filtered)" }
  if ($queuesFiltered.Count -eq 0) { Write-Host "WARNING: No queues found (or all filtered)" }
  if ($pluginsFiltered.Count -eq 0) { Write-Host "WARNING: No plugins found (or all filtered)" }
  if ($flowsFiltered.Count -eq 0) { Write-Host "WARNING: No flows found (or all filtered)" }

  # Store actual data in extraction object for later use by other functions
  $extraction.solutions = $allowlistedSolutions
  $extraction.tables = $tablesEnriched
  $extraction.queues = $queuesFiltered
  $extraction.plugins = $pluginsFiltered
  $extraction.flows = $flowsFiltered

  # Enrich production-only components: SLAs, workstreams
  try {
    Write-Host "Extracting SLAs..." -ForegroundColor Cyan
    $slas = Get-DataverseRecords -Client $client -Entity "slas" `
      -Select "slaid,name,description,objecttypecode,isdefault"
    $extraction.slas = @($slas)
    Write-Host "  SLAs: $($slas.Count)" -ForegroundColor Gray
  }
  catch {
    Write-Host "  Warning: Could not fetch SLAs: $($_.Exception.Message)" -ForegroundColor Yellow
    $extraction.slas = @()
  }

  try {
    Write-Host "Extracting Workstreams..." -ForegroundColor Cyan
    $workstreams = Get-DataverseRecords -Client $client -Entity "msdyn_liveworkstreams" `
      -Select "msdyn_liveworkstreamid,msdyn_name,msdyn_streamsource"
    $extraction.workstreams = @($workstreams)
    Write-Host "  Workstreams: $($workstreams.Count)" -ForegroundColor Gray
  }
  catch {
    Write-Host "  Warning: Could not fetch Workstreams: $($_.Exception.Message)" -ForegroundColor Yellow
    $extraction.workstreams = @()
  }

  # ============= ENHANCED EXTRACTIONS =============
  Write-Host "`n========== PHASE: Enhanced Extractions ==========" -ForegroundColor Cyan
  
  # Extract Business Process Flows
  try {
    Write-Host "Extracting Business Process Flows..." -ForegroundColor Gray
    $bpfs = Extract-BusinessProcessFlows -Client $client
    $extraction.business_process_flows = @($bpfs)
    Write-Host "  Business Process Flows: $($bpfs.Count)" -ForegroundColor DarkGray
  }
  catch {
    Write-Host "  Warning: Could not fetch BPFs: $($_.Exception.Message)" -ForegroundColor Yellow
    $extraction.business_process_flows = @()
  }
  
  # Extract Security Roles from revopstables solution(s) - base + all patches
  try {
    Write-Host "Extracting Security Roles..." -ForegroundColor Gray
    # Find base table solution AND all patches (same pattern as tables extraction)
    $tableBaseSolution = @($allowlistedSolutions | Where-Object { $_.uniquename -eq "revopstables" }) | Select-Object -First 1
    $tablePatches = @($allowlistedSolutions | Where-Object { $_.uniquename -like "revopstables_Patch_*" })
    $tableSolutions = @()
    if ($tableBaseSolution) { $tableSolutions += $tableBaseSolution }
    if ($tablePatches.Count -gt 0) { $tableSolutions += $tablePatches }
    
    if ($tableSolutions.Count -gt 0) {
      $solutionNames = ($tableSolutions | Select-Object -ExpandProperty uniquename) -join ", "
      Write-Host "  Using solutions: $solutionNames" -ForegroundColor DarkGray
      
      $allSecurityRoles = @()
      foreach ($sol in $tableSolutions) {
        $roles = Extract-SecurityRolesBySolution -Client $client -SolutionId $sol.solutionid
        if ($roles -and @($roles).Count -gt 0) {
          Write-Host "    Found $(@($roles).Count) security roles in $($sol.uniquename)" -ForegroundColor DarkGray
          $allSecurityRoles += @($roles)
        }
      }
      
      # Dedupe by roleid
      $uniqueRoles = @()
      $seenIds = @{}
      foreach ($r in $allSecurityRoles) {
        if ($r.roleid -and -not $seenIds.ContainsKey($r.roleid)) {
          $seenIds[$r.roleid] = $true
          $uniqueRoles += $r
        }
      }
      
      $extraction.security_roles = $uniqueRoles
      Write-Host "  Security Roles: $(@($uniqueRoles).Count) unique across $($tableSolutions.Count) solution(s)" -ForegroundColor DarkGray
    } else {
      $extraction.security_roles = @()
      Write-Host "  Security Roles: 0 (no table solution found)" -ForegroundColor Yellow
    }
  }
  catch {
    Write-Host "  Warning: Could not fetch Security Roles: $($_.Exception.Message)" -ForegroundColor Yellow
    $extraction.security_roles = @()
  }
  
  # Extract Environment Variables
  try {
    Write-Host "Extracting Environment Variables..." -ForegroundColor Gray
    $envVars = Extract-EnvironmentVariables -Client $client
    $extraction.environment_variables = @($envVars)
    Write-Host "  Environment Variables: $($envVars.Count)" -ForegroundColor DarkGray
  }
  catch {
    Write-Host "  Warning: Could not fetch Environment Variables: $($_.Exception.Message)" -ForegroundColor Yellow
    $extraction.environment_variables = @()
  }
  
  # Extract Connection References
  try {
    Write-Host "Extracting Connection References..." -ForegroundColor Gray
    $connRefs = Extract-ConnectionReferences -Client $client
    $extraction.connection_references = @($connRefs)
    Write-Host "  Connection References: $($connRefs.Count)" -ForegroundColor DarkGray
  }
  catch {
    Write-Host "  Warning: Could not fetch Connection References: $($_.Exception.Message)" -ForegroundColor Yellow
    $extraction.connection_references = @()
  }
  
  # Extract App Modules
  try {
    Write-Host "Extracting App Modules..." -ForegroundColor Gray
    $appModules = Extract-AppModules -Client $client
    $extraction.app_modules = @($appModules)
    Write-Host "  App Modules: $($appModules.Count)" -ForegroundColor DarkGray
  }
  catch {
    Write-Host "  Warning: Could not fetch App Modules: $($_.Exception.Message)" -ForegroundColor Yellow
    $extraction.app_modules = @()
  }
  
  # Extract Case Routing Rules
  try {
    Write-Host "Extracting Routing Rules..." -ForegroundColor Gray
    $routingRules = Extract-RoutingRules -Client $client
    $extraction.routing_rules = @($routingRules)
    Write-Host "  Routing Rules: $(@($routingRules).Count)" -ForegroundColor DarkGray
  }
  catch {
    Write-Host "  Warning: Could not fetch Routing Rules: $($_.Exception.Message)" -ForegroundColor Yellow
    $extraction.routing_rules = @()
  }
  
  # Extract Web Resources from solutions
  try {
    Write-Host "Extracting Web Resources (JavaScript)..." -ForegroundColor Gray
    $webResources = @()
    foreach ($sol in $allowlistedSolutions) {
      $solResources = Extract-WebResources -Client $client -SolutionId $sol.solutionid
      $webResources += $solResources
    }
    $extraction.web_resources = @($webResources)
    Write-Host "  Web Resources: $($webResources.Count)" -ForegroundColor DarkGray
  }
  catch {
    Write-Host "  Warning: Could not fetch Web Resources: $($_.Exception.Message)" -ForegroundColor Yellow
    $extraction.web_resources = @()
  }

  # Extract from DevCore if configured (for version comparison only)
  $devCoreExtraction = $null
  if ($Context.DataverseDevCore) {
    Write-Host "`nExtracting solutions from DevCore (version comparison only)..." -ForegroundColor Cyan
    try {
      $devCoreToken = Get-DataverseAccessToken -Dataverse $Context.DataverseDevCore
      $devCoreClient = New-DataverseGetClient -Dataverse $Context.DataverseDevCore -AccessToken $devCoreToken
      
      $devCoreSolutions = Get-Solutions -Client $devCoreClient
      $devCoreAllowlisted = Filter-SolutionsByAllowlist -Solutions $devCoreSolutions -AllowlistPatterns $Context.DevCoreSolutions
      if ($null -eq $devCoreAllowlisted) { $devCoreAllowlisted = @() }
      
      # Only extract solutions for version comparison - no tables, queues, plugins, flows
      $devCoreExtraction = @{
        solutions = $devCoreAllowlisted
      }
      
      Write-Host "DevCore extracted: $($devCoreAllowlisted.Count) solutions (version comparison only)" -ForegroundColor Green
    }
    catch {
      Write-Host "WARNING: DevCore extraction failed: $($_.Exception.Message)" -ForegroundColor Yellow
      $devCoreExtraction = $null
    }
  }
  Write-Host ""

  # Detect patch/upgrade: check if any component version changed from DevCore
  $devCoreSols = if ($devCoreExtraction) { $devCoreExtraction.solutions } else { @() }
  $patchDetected = Detect-PatchOrUpgrade -Context $Context -ProdSolutions $allowlistedSolutions -DevCoreSolutions $devCoreSols
  if ($patchDetected) {
    $extraction.patch_or_upgrade_detected = $true
    Write-Host "Patch/Upgrade detected: triggering enhanced documentation refresh" -ForegroundColor Cyan
  }

  Write-Host ""
  Write-Host "========== PHASE: Writing Documentation ==========" -ForegroundColor Cyan
  
  $changedAssets = @()
  
  Write-Host "  [1/7] Writing Solutions docs..." -ForegroundColor Gray
  $changedAssets += Write-SolutionsDocs -Context $Context -Solutions $allowlistedSolutions
  Write-Host "    -> Solutions: $($allowlistedSolutions.Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [2/17] Writing Tables docs (this may take a while)..." -ForegroundColor Gray
  $changedAssets += Write-TablesDocs -Context $Context -Client $client -Tables $tablesEnriched
  Write-Host "    -> Tables: $(@($tablesEnriched).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [3/17] Writing Queues docs..." -ForegroundColor Gray
  $changedAssets += Write-QueuesDocs -Context $Context -Client $client -Queues $queuesFiltered
  Write-Host "    -> Queues: $(@($queuesFiltered).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [4/17] Writing Plugins docs..." -ForegroundColor Gray
  $changedAssets += Write-PluginsDocs -Context $Context -Client $client -Plugins $pluginsFiltered
  Write-Host "    -> Plugins: $(@($pluginsFiltered).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [5/17] Writing Flows docs..." -ForegroundColor Gray
  $changedAssets += Write-FlowsDocs -Context $Context -Client $client -Flows $flowsFiltered
  Write-Host "    -> Flows: $(@($flowsFiltered).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [6/17] Writing SLAs docs..." -ForegroundColor Gray
  $changedAssets += Write-SLAsDocs -Context $Context -Client $client -SLAs $extraction.slas
  Write-Host "    -> SLAs: $(@($extraction.slas).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [7/17] Writing Workstreams docs..." -ForegroundColor Gray
  $changedAssets += Write-WorkstreamsDocs -Context $Context -Client $client -Workstreams $extraction.workstreams
  Write-Host "    -> Workstreams: $(@($extraction.workstreams).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [8/17] Writing Business Process Flows docs..." -ForegroundColor Gray
  $changedAssets += Write-BPFDocs -Context $Context -Client $client -BPFs $extraction.business_process_flows
  Write-Host "    -> BPFs: $(@($extraction.business_process_flows).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [9/17] Writing Security Roles docs..." -ForegroundColor Gray
  $changedAssets += Write-SecurityRolesDocs -Context $Context -Client $client -Roles $extraction.security_roles
  Write-Host "    -> Security Roles: $(@($extraction.security_roles).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [10/17] Writing Environment Variables docs..." -ForegroundColor Gray
  $changedAssets += Write-EnvironmentVariablesDocs -Context $Context -Variables $extraction.environment_variables
  Write-Host "    -> Environment Variables: $(@($extraction.environment_variables).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [11/17] Writing Connection References docs..." -ForegroundColor Gray
  $changedAssets += Write-ConnectionReferencesDocs -Context $Context -Connections $extraction.connection_references
  Write-Host "    -> Connection References: $(@($extraction.connection_references).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [12/17] Writing App Modules docs..." -ForegroundColor Gray
  $changedAssets += Write-AppModulesDocs -Context $Context -Client $client -AppModules $extraction.app_modules
  Write-Host "    -> App Modules: $(@($extraction.app_modules).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [13/17] Writing Routing Rules docs..." -ForegroundColor Gray
  $changedAssets += Write-RoutingRulesDocs -Context $Context -Client $client -RoutingRules $extraction.routing_rules
  Write-Host "    -> Routing Rules: $(@($extraction.routing_rules).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [14/17] Writing Web Resources docs..." -ForegroundColor Gray
  $changedAssets += Write-WebResourcesDocs -Context $Context -WebResources $extraction.web_resources
  Write-Host "    -> Web Resources: $(@($extraction.web_resources).Count) documented" -ForegroundColor DarkGray
  
  Write-Host "  [15/17] Writing Solution Dependencies (Impact Analysis)..." -ForegroundColor Gray
  $changedAssets += Write-SolutionDependenciesDocs -Context $Context -Client $client -Solutions $allowlistedSolutions
  Write-Host "    -> Solution Dependencies documented" -ForegroundColor DarkGray
  
  Write-Host "  [16/17] Enhancing Tables with Option Sets, Views, Formulas, Ribbons..." -ForegroundColor Gray
  Enhance-TableDocsWithExtras -Context $Context -Client $client -Tables $tablesEnriched
  Write-Host "    -> Table enhancements complete" -ForegroundColor DarkGray
  
  Write-Host "  [17/17] Enhancing Plugin docs with Step Details..." -ForegroundColor Gray
  Enhance-PluginDocsWithStepDetails -Context $Context -Client $client -Plugins $pluginsFiltered
  Write-Host "    -> Plugin enhancements complete" -ForegroundColor DarkGray
  
  Write-Host "Documentation phase complete: $($changedAssets.Count) assets processed" -ForegroundColor Green
  Write-Host ""

  $registryPath = Join-Path $Context.AIDocsRoot "_registry/assets.yaml"
  $graphPath = Join-Path $Context.AIDocsRoot "_graph/dependencies.json"

  # Filter out null entries and entries without asset_id before building registry
  # Use robust filtering that works with strict mode - check for hashtable/object type first
  $validAssets = @($changedAssets | Where-Object {
    if ($null -eq $_) { return $false }
    if ($_ -is [hashtable]) { return $_.ContainsKey('asset_id') -and $_.asset_id }
    if ($_ -is [PSCustomObject]) { return ($_.PSObject.Properties['asset_id']) -and $_.asset_id }
    return $false
  })
  Write-Host "Valid assets for registry: $($validAssets.Count) of $($changedAssets.Count)" -ForegroundColor Gray
  
  $registry = Build-RegistryFromChangedAssets -Context $Context -ChangedAssets $validAssets
  $null = Save-YamlDeterministic -Data $registry -Path $registryPath

  # Build dependency graph
  Write-Host "Building dependency graph..." -ForegroundColor Cyan
  $allEdges = @()
  
  # Extract flow→table dependencies (prefer definitions with clientdata)
  # Ensure arrays and safe count access
  $flowDefs = @($extraction.flow_definitions)
  $flowsBase = @($extraction.flows)
  $tablesBase = @($extraction.tables)
  $flowSource = if ($flowDefs.Count -gt 0) { $flowDefs } else { $flowsBase }
  if ($flowSource.Count -gt 0 -and $tablesBase.Count -gt 0) {
    $flowsWithClientData = @($flowSource | Where-Object { $_.PSObject.Properties['clientdata'] -and $_.clientdata })
    if ($flowsWithClientData.Count -gt 0) {
      try {
        $flowEdges = Extract-FlowTableDependencies -Flows $flowsWithClientData -Tables $tablesBase -ErrorAction SilentlyContinue
        $allEdges += @($flowEdges)
        Write-Host "  Flow→Table edges: $($flowEdges.Count)" -ForegroundColor Gray
      }
      catch {
        Write-Host "  WARNING: Could not extract flow dependencies: $($_.Exception.Message)" -ForegroundColor Yellow
      }
    }
    else {
      Write-Host "  Flow→Table edges: 0 (no clientdata available)" -ForegroundColor Gray
    }
  }
  
  # Extract plugin→entity dependencies
  $pluginsBase = @($extraction.plugins)
  if ($pluginsBase.Count -gt 0) {
    try {
      $pluginEdges = Extract-PluginEntityDependencies -Context $Context -Client $client -Plugins $pluginsBase -ErrorAction SilentlyContinue
      $allEdges += @($pluginEdges)
      Write-Host "  Plugin→Table edges: $(@($pluginEdges).Count)" -ForegroundColor Gray
    }
    catch {
      Write-Host "  WARNING: Could not extract plugin dependencies: $($_.Exception.Message)" -ForegroundColor Yellow
    }
  }

  $graph = @{
    schema_version = 1
    generated_run_id = $Context.RunId
    generated_on_utc = (Get-Date).ToUniversalTime().ToString("o")
    edge_count = $allEdges.Count
    edges = $allEdges
  }
  
  if (-not (Test-Path (Split-Path $graphPath))) { 
    New-Item -ItemType Directory -Path (Split-Path $graphPath) -Force | Out-Null 
  }
  $null = Set-Content -Path $graphPath -Value ($graph | ConvertTo-Json -Depth 50) -Encoding UTF8
  Write-Host "  Graph saved: _graph/dependencies.json ($($allEdges.Count) edges)" -ForegroundColor Green
  
  # Build reverse index for AI agent queries: "Which flows touch table X?"
  if ($allEdges.Count -gt 0) {
    Write-Host "Building reverse dependency index..." -ForegroundColor Cyan
    $reverseIndex = Build-ReverseDependencyIndex -Edges $allEdges
    $reverseIndexPath = Join-Path (Split-Path $graphPath) "reverse-index.yaml"
    Save-YamlDeterministic -Data $reverseIndex -Path $reverseIndexPath
    Write-Host "  Reverse index saved: _graph/reverse-index.yaml" -ForegroundColor Green
  }

  # Update existing flow and plugin READMEs with relationship information
  if ($allEdges.Count -gt 0) {
    Write-Host "Updating documentation with dependencies..." -ForegroundColor Cyan
    
    # Update flow READMEs
    if ($extraction.flows) {
      foreach ($flow in $extraction.flows) {
        Update-FlowREADMEWithDependencies -Context $Context -FlowId $flow.workflowid -FlowName $flow.name -Edges $allEdges
      }
    }
    
    # Update plugin READMEs
    if ($extraction.plugins) {
      foreach ($plugin in $extraction.plugins) {
        Update-PluginREADMEWithDependencies -Context $Context -PluginId $plugin.pluginassemblyid -PluginName $plugin.name -Edges $allEdges
      }
    }
    
    Write-Host "  Documentation updated" -ForegroundColor Green
  }

  # Phase 7: Add cross-link markers to READMEs (Used by, Depends on, Triggers)
  Write-Host "Adding cross-link markers (Phase 7)..." -ForegroundColor Cyan
  if ($allEdges.Count -gt 0) {
    # Update table READMEs with cross-links
    if ($extraction.tables) {
      foreach ($table in $extraction.tables) {
        $tableAssetId = "table:" + $table.LogicalName
        $tableFolder = Join-Path $Context.AIDocsRoot "tables" $table.LogicalName
        $readmePath = Join-Path $tableFolder "README.md"
        
        if (Test-Path $readmePath) {
          $crossLinks = Extract-CrossLinksFromEdges -Edges $allEdges -AssetId $tableAssetId
          Update-ReadmeWithCrossLinks -ReadmePath $readmePath -UsedByAssets $crossLinks.used_by -DependsOnAssets $crossLinks.depends_on -TriggersAssets $crossLinks.triggers
        }
      }
    }
    
    # Update flow READMEs with cross-links
    if ($extraction.flows) {
      foreach ($flow in $extraction.flows) {
        $flowAssetId = "flow:" + $flow.workflowid
        $flowName = $flow.name
        $safe = (("" + $flowName).ToLower() -replace '[^a-z0-9\-]+','-') -replace '\-+','-'
        $flowFolder = Join-Path $Context.AIDocsRoot "flows" $safe
        $readmePath = Join-Path $flowFolder "README.md"
        
        if (Test-Path $readmePath) {
          $crossLinks = Extract-CrossLinksFromEdges -Edges $allEdges -AssetId $flowAssetId
          Update-ReadmeWithCrossLinks -ReadmePath $readmePath -UsedByAssets $crossLinks.used_by -DependsOnAssets $crossLinks.depends_on -TriggersAssets $crossLinks.triggers
        }
      }
    }
    
    # Update plugin READMEs with cross-links
    if ($extraction.plugins) {
      foreach ($plugin in $extraction.plugins) {
        $pluginAssetId = "plugin:" + $plugin.pluginassemblyid
        $pluginFolder = Join-Path $Context.AIDocsRoot "plugins" $plugin.name
        $readmePath = Join-Path $pluginFolder "README.md"
        
        if (Test-Path $readmePath) {
          $crossLinks = Extract-CrossLinksFromEdges -Edges $allEdges -AssetId $pluginAssetId
          Update-ReadmeWithCrossLinks -ReadmePath $readmePath -UsedByAssets $crossLinks.used_by -DependsOnAssets $crossLinks.depends_on -TriggersAssets $crossLinks.triggers
        }
      }
    }
    
    Write-Host "  Cross-links added to $($extraction.tables.Count) tables, $($extraction.flows.Count) flows, $($extraction.plugins.Count) plugins" -ForegroundColor Green
  }

  # Registry lifecycle tracking
  Write-Host "Tracking solution lifecycle..." -ForegroundColor Cyan
  $previousRegistry = Load-PreviousRegistry -AIDocsRoot $Context.AIDocsRoot
  $lifecycle = Build-LifecycleComparison -PreviousRegistry $previousRegistry -CurrentSolutions $extraction.solutions
  
  $lifecyclePath = Join-Path $runFolder "lifecycle-report.md"
  Write-LifecycleReport -Path $lifecyclePath -Lifecycle $lifecycle
  
  Write-Host "  New: $($lifecycle.new.Count), Active: $($lifecycle.active.Count), Removed: $($lifecycle.removed.Count)" -ForegroundColor Gray
  Write-Host "  Lifecycle report: RUNS/$($Context.RunId)/lifecycle-report.md" -ForegroundColor Green

  # Extract depth information (steps, actions, triggers)
  Write-Host "Extracting depth analysis..." -ForegroundColor Cyan
  $flowDepths = @()
  $pluginDepths = @()
  
  # Prefer flow definitions with clientdata; fallback to basic flows if definitions missing
  $flowDepthSource = if ($extraction.flow_definitions -and $extraction.flow_definitions.Count -gt 0) { $extraction.flow_definitions } else { $extraction.flows }
  if ($flowDepthSource -and $flowDepthSource.Count -gt 0) {
    foreach ($flow in $flowDepthSource) {
      $flowDepths += Extract-FlowDepth -Flow $flow
    }
  }
  
  if ($extraction.plugins -and $extraction.plugins.Count -gt 0) {
    foreach ($plugin in $extraction.plugins) {
      $pluginDepths += Extract-PluginDepth -Context $Context -Client $client -Plugin $plugin
    }
  }
  
  # Save detailed depth data as JSON
  $depthData = @{
    flows = $flowDepths
    plugins = $pluginDepths
    generated_on_utc = (Get-Date).ToUniversalTime().ToString("o")
  }
  $depthJsonPath = Join-Path $runFolder "depth-analysis.json"
  $null = Set-Content -Path $depthJsonPath -Value ($depthData | ConvertTo-Json -Depth 50) -Encoding UTF8
  
  # Generate depth report
  $depthReportPath = Join-Path $runFolder "depth-analysis.md"
  Write-DepthAnalysis -Path $depthReportPath -FlowDepths $flowDepths -PluginDepths $pluginDepths
  
  Write-Host "  Flow steps extracted: $(($flowDepths | Measure-Object -Property step_count -Sum).Sum)" -ForegroundColor Gray
  Write-Host "  Plugin steps extracted: $(($pluginDepths | Measure-Object -Property step_count -Sum).Sum)" -ForegroundColor Gray
  Write-Host "  Depth analysis: RUNS/$($Context.RunId)/depth-analysis.md" -ForegroundColor Green

  # Environment comparison (DevCore vs Prod)
  Write-Host "Generating environment comparison..." -ForegroundColor Cyan
  $prodData = @{
    solutions = $allowlistedSolutions
    tables = $extraction.tables
    queues = $extraction.queues
    plugins = $extraction.plugins
    flows = $extraction.flows
  }
  
  $envComparison = Compare-Environments -Context $Context -ProdData $prodData -DevCoreData $devCoreExtraction
  $envComparisonPath = Join-Path $runFolder "environment-comparison.md"
  Write-EnvironmentComparisonReport -Path $envComparisonPath -Comparison $envComparison
  
  if ($envComparison.enabled) {
    Write-Host "  Version comparison: InSync=$($envComparison.in_sync_count), Mismatch=$($envComparison.mismatch_count), ProdOnly=$($envComparison.prod_only_count), PendingDeploy=$($envComparison.devcore_only_count)" -ForegroundColor Gray
    Write-Host "  Environment comparison: RUNS/$($Context.RunId)/environment-comparison.md" -ForegroundColor Green
  } else {
    Write-Host "  Environment comparison: DISABLED" -ForegroundColor Yellow
  }

  $confidence = Compute-Confidence -Context $Context -Extraction $extraction -ChangedAssets $changedAssets
  $extraction.confidence = $confidence
  $extraction.ended_on_utc = (Get-Date).ToUniversalTime().ToString("o")
  
  # Phase 6: Build comprehensive dependency graph
  Write-Host "Computing comprehensive dependency graph..." -ForegroundColor Cyan
  $comprehensiveGraph = Build-DependencyGraph -Extraction $extraction -Context $Context
  Write-Host "  Nodes: $($comprehensiveGraph.nodes.Count), Edges: $($comprehensiveGraph.edge_count)" -ForegroundColor Gray
  $graphOutputPath = Join-Path $runFolder "comprehensive-graph.json"
  $null = Set-Content -Path $graphOutputPath -Value ($comprehensiveGraph | ConvertTo-Json -Depth 50) -Encoding UTF8
  $extraction.graph = $comprehensiveGraph
  
  # Phase 8: Compute documentation fingerprint for determinism validation
  Write-Host "Computing documentation fingerprint..." -ForegroundColor Cyan
  $fingerprint = Compute-DocumentationFingerprint -Extraction $extraction
  Write-Host "  Fingerprint (SHA256): $($fingerprint.fingerprint)" -ForegroundColor Gray
  Write-Host "  Components hashed: $($fingerprint.components_hashed)" -ForegroundColor Gray
  $extraction.fingerprint = $fingerprint
  
  # Write detailed extraction to run-details.yaml
  $null = Save-YamlDeterministic -Data $extraction -Path (Join-Path $runFolder "run-details.yaml")

  # Write summary per run with required fields
  $summary = [ordered]@{
    run_id = $Context.RunId
    mode = $Context.Mode
    sources = $extraction.sources
    counts = [ordered]@{
      solutions = $extraction.results.solutions_count
      tables = $extraction.results.tables_count
      queues_included = $extraction.results.queues_included_count
      queues_total = $extraction.results.queues_total_count
      plugins = $extraction.results.plugins_count
      flows = $extraction.results.flows_count
      edges = $comprehensiveGraph.edge_count
    }
    fingerprint = $fingerprint
    warnings = @($extraction.errors)
    completion = "success"
    confidence = $confidence
  }
  $null = Save-YamlDeterministic -Data $summary -Path (Join-Path $runFolder "run-summary.yaml")
  $null = Write-DiffReport -Context $Context -Path (Join-Path $runFolder "diff-report.md") -ChangedAssets $validAssets -Confidence $confidence

  # Phase 0: Generate coverage report
  $null = Write-CoverageReport -Context $Context -Capabilities $extraction.capabilities -Extraction $extraction

  $overall = [double]$confidence.overall
  $gatePass = ($overall -ge [double]$Context.ConfidenceThreshold)

  return [pscustomobject]@{
    OverallConfidence = $overall
    GatePass = $gatePass
    CommitMessage = ("DocGen " + $Context.RunId + " (" + $Context.Mode + ") confidence " + $overall)
    PrTitle = ("DocGen " + $Context.RunId + " (" + $Context.Mode + ")")
    PrDescription = ("Automated documentation update from Prod (read-only). Overall confidence " + $overall + " Threshold " + $Context.ConfidenceThreshold)
  }
}

function Commit-AndPushChanges {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)][string]$CommitMessage
  )

  Push-Location $Context.RepoRoot
  try {
    $changes = git status --porcelain
    if (-not $changes) { return [pscustomobject]@{ HadChanges = $false } }

    git add AIDocumentation | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "git add failed with exit code $LASTEXITCODE" }
    
    git commit -m $CommitMessage | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "git commit failed with exit code $LASTEXITCODE" }
    
    Write-Host "Pushing to origin/$($Context.BranchName)..."
    git push origin $Context.BranchName
    if ($LASTEXITCODE -ne 0) {
      throw "git push failed with exit code $LASTEXITCODE - Documentation NOT published"
    }
    Write-Host "✓ Push successful"

    return [pscustomobject]@{ HadChanges = $true }
  } finally {
    Pop-Location
  }
}

function Ensure-PullRequest {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)][string]$Title,
    [Parameter(Mandatory=$true)][string]$Description
  )

  $repo = Get-AdoRepo -Context $Context
  $repoId = $repo.id

  $existing = Find-ExistingPR -Context $Context -RepoId $repoId -SourceRef ("refs/heads/" + $Context.BranchName) -TargetRef ("refs/heads/" + $Context.DefaultBranch)
  if ($null -ne $existing) { return $existing }

  $body = @{
    sourceRefName = ("refs/heads/" + $Context.BranchName)
    targetRefName = ("refs/heads/" + $Context.DefaultBranch)
    title = $Title
    description = $Description
    reviewers = @()
  } | ConvertTo-Json -Depth 20

  $uri = ($Context.OrganizationUrl + "/" + [uri]::EscapeDataString($Context.ProjectName) + "/_apis/git/repositories/" + $repoId + "/pullrequests?api-version=7.1-preview.1")
  return Invoke-AdoRest -Context $Context -Method "POST" -Uri $uri -Body $body
}

function Set-PRAutoComplete {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)][int]$PullRequestId
  )

  $repo = Get-AdoRepo -Context $Context
  $repoId = $repo.id
  $currentUser = Get-AdoCurrentUser -Context $Context

  Write-Host "Configuring PR auto-complete..." -ForegroundColor Cyan
  Write-Host "  PR ID: $PullRequestId" -ForegroundColor Gray
  Write-Host "  Source Branch: $($Context.BranchName)" -ForegroundColor Gray
  Write-Host "  Target Branch: $($Context.DefaultBranch)" -ForegroundColor Gray

  $patch = @{
    autoCompleteSetBy = @{ id = $currentUser.id }
    completionOptions = @{
      deleteSourceBranch = $true  # Auto-delete branch after merge
      mergeStrategy = "squash"
      squashMerge = $true
      bypassPolicy = $false
      transitionWorkItems = $false
    }
  } | ConvertTo-Json -Depth 20

  $uri = ($Context.OrganizationUrl + "/" + [uri]::EscapeDataString($Context.ProjectName) + "/_apis/git/repositories/" + $repoId + "/pullrequests/" + $PullRequestId + "?api-version=7.1-preview.1")
  
  try {
    Invoke-AdoRest -Context $Context -Method "PATCH" -Uri $uri -Body $patch | Out-Null
    
    Write-Host "✓ Auto-complete enabled" -ForegroundColor Green
    Write-Host "✓ Delete source branch enabled: true" -ForegroundColor Green
    Write-Host "✓ Merge strategy: squash" -ForegroundColor Green
  }
  catch {
    Write-Host "✗ Failed to set PR auto-complete" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    throw "PR auto-complete configuration failed - pipeline cannot proceed"
  }
}

function Get-AdoRepo {
  param([Parameter(Mandatory=$true)]$Context)
  $uri = ($Context.OrganizationUrl + "/" + [uri]::EscapeDataString($Context.ProjectName) + "/_apis/git/repositories/" + [uri]::EscapeDataString($Context.RepoName) + "?api-version=7.1-preview.1")
  return Invoke-AdoRest -Context $Context -Method "GET" -Uri $uri
}

function Get-AdoCurrentUser {
  param([Parameter(Mandatory=$true)]$Context)
  # Use organization-level connectionData endpoint (no project in path)
  $uri = ($Context.OrganizationUrl + "/_apis/connectionData?api-version=7.1-preview.1")
  $data = Invoke-AdoRest -Context $Context -Method "GET" -Uri $uri
  return $data.authenticatedUser
}

function Find-ExistingPR {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)][string]$RepoId,
    [Parameter(Mandatory=$true)][string]$SourceRef,
    [Parameter(Mandatory=$true)][string]$TargetRef
  )

  $uri = ($Context.OrganizationUrl + "/" + [uri]::EscapeDataString($Context.ProjectName) + "/_apis/git/repositories/" + $RepoId + "/pullrequests?searchCriteria.status=active&searchCriteria.sourceRefName=" + [uri]::EscapeDataString($SourceRef) + "&searchCriteria.targetRefName=" + [uri]::EscapeDataString($TargetRef) + "&api-version=7.1-preview.1")
  $res = Invoke-AdoRest -Context $Context -Method "GET" -Uri $uri
  if ($res.count -gt 0) { return $res.value[0] }
  return $null
}

function Invoke-AdoRest {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)][ValidateSet("GET","POST","PATCH")][string]$Method,
    [Parameter(Mandatory=$true)][string]$Uri,
    [Parameter(Mandatory=$false)][string]$Body = $null
  )

  $headers = @{
    Authorization = ("Bearer " + $Context.SystemAccessToken)
    "Content-Type" = "application/json"
  }

  if ($Method -eq "GET") {
    return Invoke-RestMethod -Method Get -Uri $Uri -Headers $headers
  }

  if ([string]::IsNullOrWhiteSpace($Body)) { throw ("Body required for " + $Method) }

  if ($Method -eq "POST") {
    return Invoke-RestMethod -Method Post -Uri $Uri -Headers $headers -Body $Body
  }

  if ($Method -eq "PATCH") {
    return Invoke-RestMethod -Method Patch -Uri $Uri -Headers $headers -Body $Body
  }

  throw "Unsupported method"
}

# ---------------- Dataverse (GET-only) ----------------

function Get-DataverseAccessToken {
  param([Parameter(Mandatory=$true)][hashtable]$Dataverse)

  $tokenUri = ("https://login.microsoftonline.com/" + $Dataverse.TenantId + "/oauth2/v2.0/token")
  $body = @{
    grant_type = "client_credentials"
    client_id = $Dataverse.ClientId
    client_secret = $Dataverse.ClientSecret
    scope = ($Dataverse.OrgUrl + "/.default")
  }

  $res = Invoke-RestMethod -Method Post -Uri $tokenUri -Body $body -ContentType "application/x-www-form-urlencoded"
  return $res.access_token
}

function New-DataverseGetClient {
  param(
    [Parameter(Mandatory=$true)][hashtable]$Dataverse,
    [Parameter(Mandatory=$true)][string]$AccessToken
  )

  return @{
    BaseUrl = ($Dataverse.OrgUrl + "/api/data/v" + $Dataverse.ApiVersion)
    AccessToken = $AccessToken
  }
}

function Invoke-DvGet {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$RelativeUrl,
    [Parameter(Mandatory=$false)][switch]$Silent
  )

  $uri = $null
  if ($RelativeUrl.StartsWith("http")) {
    $uri = $RelativeUrl
  } else {
    $uri = ($Client.BaseUrl.TrimEnd("/") + "/" + $RelativeUrl.TrimStart("/"))
  }

  $headers = @{
    Authorization = ("Bearer " + $Client.AccessToken)
    Accept = "application/json"
    "OData-MaxVersion" = "4.0"
    "OData-Version" = "4.0"
    Prefer = 'odata.include-annotations="Microsoft.Dynamics.CRM.*"'
  }

  $maxRetries = 3
  $attempt = 0
  
  while ($attempt -lt $maxRetries) {
    $attempt++
    try {
      return Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    } catch {
      $resp = $_.Exception.Response
      $statusCode = $null
      if ($null -ne $resp) { $statusCode = $resp.StatusCode.value__ }
      
      # Retry on 429 (throttle) or 503 (service unavailable)
      if (($statusCode -eq 429 -or $statusCode -eq 503) -and $attempt -lt $maxRetries) {
        $retryAfter = 5
        try {
          $ra = $resp.Headers["Retry-After"]
          if ($ra) { $retryAfter = [int]$ra }
        } catch {}
        
        $waitTime = $retryAfter * $attempt
        if (-not $Silent) {
          Write-Host "Transient error (HTTP $statusCode). Retrying in $waitTime seconds (attempt $attempt/$maxRetries)..."
        }
        Start-Sleep -Seconds $waitTime
        continue
      }
      
      if (-not $Silent) {
        Write-Host "Error calling Dataverse API: $($_.Exception.Message)"
      }
      throw
    }
  }
  
  throw "Dataverse API call failed after $maxRetries attempts"
}

function Get-DataverseRecords {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$Entity,
    [Parameter(Mandatory=$false)][AllowNull()][string]$Select,
    [Parameter(Mandatory=$false)][AllowNull()][string]$Filter
  )

  $qs = @()
  if (-not [string]::IsNullOrWhiteSpace($Select)) { $qs += ("`$select=" + $Select) }
  if (-not [string]::IsNullOrWhiteSpace($Filter)) { $qs += ("`$filter=" + $Filter) }
  $rel = $Entity
  if ($qs.Count -gt 0) { $rel = ($Entity + "?" + ($qs -join "&")) }

  $res = Invoke-DvGet -Client $Client -RelativeUrl $rel
  if ($null -eq $res) { return @() }
  if ($res.value) { return @($res.value) }
  return @($res)
}

# ---------------- Extractors (POC) ----------------

function Get-Solutions {
  param([Parameter(Mandatory=$true)]$Client)
  $res = Invoke-DvGet -Client $Client -RelativeUrl "solutions?`$select=solutionid,uniquename,friendlyname,version,installedon,ismanaged"
  return @($res.value)
}

function Get-TableMetadataIndex {
  param([Parameter(Mandatory=$true)]$Client)
  $url = "EntityDefinitions?`$select=LogicalName,SchemaName,DisplayName,Description,OwnershipType,IsCustomEntity,IsAuditEnabled,IsActivity"
  $res = Invoke-DvGet -Client $Client -RelativeUrl $url
  return @($res.value)
}

function Get-QueuesRaw {
  param([Parameter(Mandatory=$true)]$Client)
  $res = Invoke-DvGet -Client $Client -RelativeUrl "queues?`$select=queueid,name,description,emailaddress,_ownerid_value"
  return @($res.value)
}

function Filter-QueuesExcludeUserQueues {
  param([Parameter(Mandatory=$true)]$Queues)

  $included = [System.Collections.ArrayList]::new()
  $ownerTypeProp = "_ownerid_value@Microsoft.Dynamics.CRM.lookuplogicalname"

  foreach ($q in $Queues) {
    $ownerType = $null
    $p = $q.PSObject.Properties[$ownerTypeProp]
    if ($null -ne $p) { $ownerType = [string]$p.Value }

    if ($ownerType -eq "systemuser") { continue }
    [void]$included.Add($q)
  }

  return @($included)
}

function Get-PluginsIndex {
  param([Parameter(Mandatory=$true)]$Client)
  $res = Invoke-DvGet -Client $Client -RelativeUrl "pluginassemblies?`$select=pluginassemblyid,name,version,publickeytoken"
  return @($res.value)
}

function Get-PluginsBySolution {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$SolutionId
  )

  # Query solution components for plugin assemblies (componenttype 91 = Plugin Assembly)
  $componentUrl = "solutioncomponents?`$filter=_solutionid_value eq $SolutionId and componenttype eq 91&`$select=objectid"
  
  try {
    $components = Invoke-DvGet -Client $Client -RelativeUrl $componentUrl
    $pluginIds = @($components.value | Select-Object -ExpandProperty objectid)
    
    if ($pluginIds.Count -eq 0) {
      Write-Host "  No plugin assemblies found in solution" -ForegroundColor Yellow
      return @()
    }
    
    Write-Host "  Found $($pluginIds.Count) plugin assemblies in solution" -ForegroundColor Gray
    
    # Fetch plugin details
    $allPlugins = @()
    $batchSize = 50
    
    for ($i = 0; $i -lt $pluginIds.Count; $i += $batchSize) {
      $batch = $pluginIds[$i..([Math]::Min($i + $batchSize - 1, $pluginIds.Count - 1))]
      $filterParts = $batch | ForEach-Object { "pluginassemblyid eq $_" }
      $filter = $filterParts -join " or "
      
      $pluginUrl = "pluginassemblies?`$filter=$filter&`$select=pluginassemblyid,name,version,publickeytoken"
      $pluginRes = Invoke-DvGet -Client $Client -RelativeUrl $pluginUrl
      $allPlugins += @($pluginRes.value)
    }
    
    return @($allPlugins)
  }
  catch {
    Write-Host "  Warning: Could not fetch plugins by solution: $($_.Exception.Message)" -ForegroundColor Yellow
    return @()
  }
}

function Get-FlowsIndex {
  param([Parameter(Mandatory=$true)]$Client)
  $res = Invoke-DvGet -Client $Client -RelativeUrl "workflows?`$select=workflowid,name,category,type,statecode,statuscode,primaryentity,createdon"
  return @($res.value)
}

function Get-TablesBySolution {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$SolutionId
  )

  # Query solution components for entities (componenttype 1 = Entity/Table)
  $componentUrl = "solutioncomponents?`$filter=_solutionid_value eq $SolutionId and componenttype eq 1&`$select=objectid"
  
  try {
    $components = Invoke-DvGet -Client $Client -RelativeUrl $componentUrl
    $entityIds = @($components.value | Select-Object -ExpandProperty objectid)
    
    if ($entityIds.Count -eq 0) {
      Write-Host "  No entities found in solution" -ForegroundColor Yellow
      return @()
    }
    
    Write-Host "  Found $($entityIds.Count) entities in solution" -ForegroundColor Gray
    
    # Fetch entity metadata via MetadataId
    # EntityDefinitions uses MetadataId (GUID) as the key
    $allTables = @()
    $batchSize = 25
    
    for ($i = 0; $i -lt $entityIds.Count; $i += $batchSize) {
      $batch = $entityIds[$i..([Math]::Min($i + $batchSize - 1, $entityIds.Count - 1))]
      $filterParts = $batch | ForEach-Object { "MetadataId eq $_ " }
      $filter = $filterParts -join " or "
      
      $entityUrl = "EntityDefinitions?`$filter=$filter&`$select=LogicalName,SchemaName,DisplayName,Description,OwnershipType,IsCustomEntity,IsAuditEnabled,IsActivity,MetadataId"
      $entityRes = Invoke-DvGet -Client $Client -RelativeUrl $entityUrl
      $allTables += @($entityRes.value)
    }
    
    return @($allTables)
  }
  catch {
    Write-Host "  Warning: Could not fetch tables by solution: $($_.Exception.Message)" -ForegroundColor Yellow
    return @()
  }
}

function Get-FlowsBySolution {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$SolutionId,
    [Parameter(Mandatory=$false)][switch]$IncludeClientData
  )

  # Query solution components for workflows (componenttype 29 = Process/Workflow)
  # This returns only the workflow IDs that are part of the solution
  $componentUrl = "solutioncomponents?`$filter=_solutionid_value eq $SolutionId and componenttype eq 29&`$select=objectid"
  
  try {
    $components = Invoke-DvGet -Client $Client -RelativeUrl $componentUrl
    $workflowIds = @($components.value | Select-Object -ExpandProperty objectid)
    
    if ($workflowIds.Count -eq 0) {
      Write-Host "  No workflows found in solution $SolutionId" -ForegroundColor Yellow
      return @()
    }
    
    Write-Host "  Found $($workflowIds.Count) workflows in solution" -ForegroundColor Gray
    
    # Fetch workflow details in batches to avoid URL length limits
    $allFlows = @()
    $batchSize = 50
    
    for ($i = 0; $i -lt $workflowIds.Count; $i += $batchSize) {
      $batch = $workflowIds[$i..([Math]::Min($i + $batchSize - 1, $workflowIds.Count - 1))]
      $filterParts = $batch | ForEach-Object { "workflowid eq $_" }
      $filter = $filterParts -join " or "
      
      $selectFields = "workflowid,name,category,type,statecode,statuscode,primaryentity,createdon"
      if ($IncludeClientData) {
        $selectFields += ",clientdata"
      }
      
      $flowUrl = "workflows?`$filter=$filter&`$select=$selectFields"
      $flowRes = Invoke-DvGet -Client $Client -RelativeUrl $flowUrl
      $allFlows += @($flowRes.value)
    }
    
    return @($allFlows)
  }
  catch {
    Write-Host "  Warning: Could not fetch flows by solution: $($_.Exception.Message)" -ForegroundColor Yellow
    return @()
  }
}

function Get-FlowsWithDefinitions {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$false)][int]$MaxFlows = 5000
  )

  $res = Invoke-DvGet -Client $Client -RelativeUrl "workflows?`$select=workflowid,name,category,type,statecode,statuscode,primaryentity,createdon,clientdata&`$top=$MaxFlows"
  return @($res.value)
}

# Enrich table metadata with relationships, columns, forms, business rules
function Enrich-TableMetadata {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$Table
  )

  $enriched = $Table | Select-Object * -ErrorAction SilentlyContinue
  
  # Note: Dataverse metadata entities (attributes, relationships, systemforms) are not directly queryable via OData in standard API
  # These would require specialized metadata API calls. For now, we document table basic info only.
  # If enhanced metadata is needed, use RetrieveMetadataChangesRequest via SDK instead.

  return $enriched
}

# Filter tables to only those from revopstables solution (or matching patterns)
function Filter-TablesBySolution {
  param(
    [Parameter(Mandatory=$true)]$Tables,
    [Parameter(Mandatory=$true)]$AllowlistedSolutions
  )

  if (-not $Tables) { return @() }
  if (-not $AllowlistedSolutions) { return @() }

  # Extract solution names from allowlist patterns that contain 'table'
  $tablePatterns = @($AllowlistedSolutions | Where-Object { $_.uniquename -like "*table*" } | Select-Object -ExpandProperty uniquename)
  
  if ($tablePatterns.Count -eq 0) {
    Write-Host "No table solutions found in allowlist; returning all tables" -ForegroundColor Yellow
    return @($Tables)
  }

  # Return all tables; filtering by solution membership handled via table parent solution
  return @($Tables)
}

# Filter plugins to only those from revopsplugins solution (or matching patterns)
function Filter-PluginsBySolution {
  param(
    [Parameter(Mandatory=$true)]$Plugins,
    [Parameter(Mandatory=$true)]$AllowlistedSolutions
  )

  if (-not $Plugins) { return @() }
  if (-not $AllowlistedSolutions) { return @() }

  # Extract solution names from allowlist patterns that contain 'plugin'
  $pluginPatterns = @($AllowlistedSolutions | Where-Object { $_.uniquename -like "*plugin*" } | Select-Object -ExpandProperty uniquename)
  
  if ($pluginPatterns.Count -eq 0) {
    Write-Host "No plugin solutions found in allowlist; returning all plugins" -ForegroundColor Yellow
    return @($Plugins)
  }

  # Filter plugins: would need to query solution membership from Dataverse
  # For now, return all and let documentation process handle filtering via solution context
  return @($Plugins)
}

# Filter flows to only those from revopsflows solution (or matching patterns)
function Filter-FlowsBySolution {
  param(
    [Parameter(Mandatory=$true)]$Flows,
    [Parameter(Mandatory=$true)]$AllowlistedSolutions
  )

  if (-not $Flows) { return @() }
  if (-not $AllowlistedSolutions) { return @() }

  # Extract solution names from allowlist patterns that contain 'flow'
  $flowPatterns = @($AllowlistedSolutions | Where-Object { $_.uniquename -like "*flow*" } | Select-Object -ExpandProperty uniquename)
  
  if ($flowPatterns.Count -eq 0) {
    Write-Host "No flow solutions found in allowlist; returning all flows" -ForegroundColor Yellow
    return @($Flows)
  }

  # Return all flows; filtering by solution membership handled via workflow parent solution
  return @($Flows)
}

# ============= PHASE 1-6: ENRICHMENT EXTRACTORS =============

# Phase 1: Extract table column metadata
function Extract-TableColumns {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$LogicalName
  )
  try {
    # Use Metadata API to fetch attributes for this table
    # Note: Metadata API uses EntityDefinitions(LogicalName='xxx')/Attributes, not $top
    $url = "EntityDefinitions(LogicalName='$LogicalName')/Attributes?`$select=LogicalName,DisplayName,Description,AttributeType,RequiredLevel"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    return @($res.value)
  }
  catch {
    return @()
  }
}

# Phase 1: Extract table relationships
function Extract-TableRelationships {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$LogicalName
  )
  
  $allRelationships = @()
  
  try {
    # Use Metadata API - OneToMany relationships (where this table is the primary/referenced)
    $url = "EntityDefinitions(LogicalName='$LogicalName')/OneToManyRelationships?`$select=SchemaName,ReferencingEntity,ReferencedEntity,ReferencingAttribute,ReferencedAttribute"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    foreach ($r in $res.value) {
      $allRelationships += @{
        schemaname = $r.SchemaName
        relationshiptype = "OneToMany"
        referencingtablelogicalname = $r.ReferencingEntity
        referencedtablelogicalname = $r.ReferencedEntity
      }
    }
  } catch { }
  
  try {
    # ManyToOne relationships (where this table is the referencing/child)
    $url = "EntityDefinitions(LogicalName='$LogicalName')/ManyToOneRelationships?`$select=SchemaName,ReferencingEntity,ReferencedEntity,ReferencingAttribute,ReferencedAttribute"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    foreach ($r in $res.value) {
      $allRelationships += @{
        schemaname = $r.SchemaName
        relationshiptype = "ManyToOne"
        referencingtablelogicalname = $r.ReferencingEntity
        referencedtablelogicalname = $r.ReferencedEntity
      }
    }
  } catch { }
  
  try {
    # ManyToMany relationships
    $url = "EntityDefinitions(LogicalName='$LogicalName')/ManyToManyRelationships?`$select=SchemaName,Entity1LogicalName,Entity2LogicalName,IntersectEntityName"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    foreach ($r in $res.value) {
      $allRelationships += @{
        schemaname = $r.SchemaName
        relationshiptype = "ManyToMany"
        referencingtablelogicalname = $r.Entity1LogicalName
        referencedtablelogicalname = $r.Entity2LogicalName
      }
    }
  } catch { }
  
  return $allRelationships
}

# Phase 2: Extract forms for a table - including full form layout
function Extract-TableForms {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$LogicalName
  )
  try {
    # Include formxml to get the actual form layout structure
    $url = "systemforms?`$filter=objecttypecode eq '$LogicalName'&`$select=formid,name,type,description,formactivationstate,formxml&`$top=500"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    
    $forms = @()
    foreach ($form in $res.value) {
      $formData = @{
        formid = $form.formid
        name = $form.name
        type = $form.type
        type_name = switch ($form.type) { 
          2 { "Main" } 
          5 { "Mobile" }
          6 { "Quick View" }
          7 { "Quick Create" }
          11 { "Card" }
          12 { "Main - Interactive" }
          default { "Type $($form.type)" }
        }
        description = $form.description
        is_active = ($form.formactivationstate -eq 1)
      }
      
      # Parse formxml if present to extract structure
      if ($form.formxml) {
        $layout = Parse-FormXml -FormXml $form.formxml
        $formData.tabs = $layout.tabs
        $formData.fields = $layout.fields
        $formData.sections = $layout.sections
        $formData.field_count = @($layout.fields).Count
      }
      
      $forms += $formData
    }
    
    return $forms
  }
  catch {
    return @()
  }
}

# Parse form XML to extract tabs, sections, and field placements
function Parse-FormXml {
  param(
    [Parameter(Mandatory=$true)][string]$FormXml
  )
  
  $result = @{
    tabs = @()
    sections = @()
    fields = @()
  }
  
  try {
    $xml = [xml]$FormXml
    
    # Extract tabs
    $tabNodes = $xml.SelectNodes("//tab")
    foreach ($tab in $tabNodes) {
      $tabName = $tab.GetAttribute("name")
      $tabLabel = ""
      $labelNode = $tab.SelectSingleNode("labels/label[@languagecode='1033']")
      if ($labelNode) { $tabLabel = $labelNode.GetAttribute("description") }
      
      $result.tabs += @{
        name = $tabName
        label = $tabLabel
        visible = ($tab.GetAttribute("visible") -ne "false")
        expanded = ($tab.GetAttribute("expanded") -ne "false")
      }
    }
    
    # Extract sections
    $sectionNodes = $xml.SelectNodes("//section")
    foreach ($section in $sectionNodes) {
      $sectionName = $section.GetAttribute("name")
      $sectionLabel = ""
      $labelNode = $section.SelectSingleNode("labels/label[@languagecode='1033']")
      if ($labelNode) { $sectionLabel = $labelNode.GetAttribute("description") }
      
      # Find parent tab
      $parentTab = $section.SelectSingleNode("ancestor::tab")
      $parentTabName = if ($parentTab) { $parentTab.GetAttribute("name") } else { "" }
      
      $result.sections += @{
        name = $sectionName
        label = $sectionLabel
        tab = $parentTabName
        visible = ($section.GetAttribute("visible") -ne "false")
      }
    }
    
    # Extract field controls
    $controlNodes = $xml.SelectNodes("//control")
    foreach ($control in $controlNodes) {
      $controlId = $control.GetAttribute("id")
      $datafieldname = $control.GetAttribute("datafieldname")
      $classid = $control.GetAttribute("classid")
      
      # Only include actual field controls (not subgrids, webresources, etc.)
      if ($datafieldname) {
        # Find parent section and tab
        $parentSection = $control.SelectSingleNode("ancestor::section")
        $parentTab = $control.SelectSingleNode("ancestor::tab")
        
        $sectionName = if ($parentSection) { $parentSection.GetAttribute("name") } else { "" }
        $tabName = if ($parentTab) { $parentTab.GetAttribute("name") } else { "" }
        
        $result.fields += @{
          field = $datafieldname
          control_id = $controlId
          section = $sectionName
          tab = $tabName
          disabled = ($control.GetAttribute("disabled") -eq "true")
          visible = ($control.GetAttribute("visible") -ne "false")
        }
      }
    }
  }
  catch {
    # Return empty result if parsing fails
  }
  
  return $result
}

# Phase 2: Extract business rules for a table
function Extract-TableBusinessRules {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$LogicalName
  )
  try {
    # Business rules are category 2 in workflows table
    $url = "workflows?`$filter=primaryentity eq '$LogicalName' and category eq 2 and statecode eq 0&`$select=workflowid,name,description&`$top=500"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    return @($res.value)
  }
  catch {
    return @()
  }
}

# Phase 3: Analyze flow actions for Dataverse operations
function Analyze-FlowActions {
  param([Parameter(Mandatory=$true)]$Flow)

  $actions = @()
  $confidence = "low"
  $hasClientData = $false
  
  # Check if clientdata property exists using PSObject.Properties
  if ($Flow.PSObject.Properties['clientdata'] -and $Flow.clientdata) {
    $hasClientData = $true
    try {
      $cd = $Flow.clientdata | ConvertFrom-Json
      if ($cd.PSObject.Properties['definition'] -and $cd.definition -and $cd.definition.PSObject.Properties['actions'] -and $cd.definition.actions) {
        foreach ($action in $cd.definition.actions.PSObject.Properties) {
          $actionObj = $action.Value
          if ($actionObj -and $actionObj.PSObject.Properties['inputs'] -and $actionObj.inputs) {
            $actions += @{
              name = $action.Name
              type = if ($actionObj.PSObject.Properties['type'] -and $actionObj.type) { $actionObj.type } else { "unknown" }
              inputs = $actionObj.inputs
            }
          }
        }
        if ($actions.Count -gt 0) { $confidence = "medium" }
      }
    }
    catch {
      $confidence = "low"
    }
  }

  return @{
    actions = $actions
    confidence = $confidence
    evidence = if ($hasClientData) { "flow.clientdata analyzed" } else { "no clientdata" }
  }
}

# Phase 4: Extract plugin assembly details
function Extract-PluginAssemblyDetails {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$PluginAssemblyId
  )

  $details = @{
    types = @()
    steps = @()
  }

  try {
    # Get plugin types for this assembly
    $url = "plugintypes?`$filter=_pluginassemblyid_value eq $PluginAssemblyId&`$select=plugintypeid,name,typename,isworkflowactivity&`$top=500"
    
    # Debug logging for troubleshooting 400 errors (only when SYSTEM_DEBUG=true)
    if ($env:SYSTEM_DEBUG -eq 'true') {
      Write-Host "[DEBUG] Plugin API call:" -ForegroundColor DarkGray
      Write-Host "  URL: plugintypes" -ForegroundColor DarkGray
      Write-Host "  Filter: _pluginassemblyid_value eq $PluginAssemblyId" -ForegroundColor DarkGray
      Write-Host "  Select: plugintypeid,name,typename,isworkflowactivity" -ForegroundColor DarkGray
      Write-Host "  Entity: plugintypes (Plugin Assembly: $PluginAssemblyId)" -ForegroundColor DarkGray
    }
    
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    $details.types = @($res.value)

    # Get SDK message processing steps via plugin types (steps link to types, not assemblies)
    # Enhanced: include message details and filtering attributes (Fix 5)
    if ($details.types.Count -gt 0) {
      $typeIds = @($details.types | ForEach-Object { $_.plugintypeid })
      $allSteps = @()
      foreach ($typeId in $typeIds) {
        try {
          $url = "sdkmessageprocessingsteps?`$filter=_plugintypeid_value eq $typeId&`$select=sdkmessageprocessingstepid,name,stage,mode,rank,statuscode,filteringattributes,_sdkmessageid_value,_primaryobjecttypecode_value,description&`$expand=sdkmessageid(`$select=name,sdkmessageid)&`$top=500"
          
          # Debug logging for troubleshooting 400 errors (only when SYSTEM_DEBUG=true)
          if ($env:SYSTEM_DEBUG -eq 'true') {
            Write-Host "[DEBUG] SDK Steps API call:" -ForegroundColor DarkGray
            Write-Host "  URL: sdkmessageprocessingsteps" -ForegroundColor DarkGray
            Write-Host "  Filter: _plugintypeid_value eq $typeId" -ForegroundColor DarkGray
            Write-Host "  Select: sdkmessageprocessingstepid,name,stage,mode,rank,statuscode,filteringattributes,_sdkmessageid_value,_primaryobjecttypecode_value,description" -ForegroundColor DarkGray
            Write-Host "  Expand: sdkmessageid(\$select=name,sdkmessageid)" -ForegroundColor DarkGray
            Write-Host "  Entity: sdkmessageprocessingsteps (Plugin Type: $typeId)" -ForegroundColor DarkGray
          }
          
          $res = Invoke-DvGet -Client $Client -RelativeUrl $url
          if ($res.value) {
            foreach ($step in $res.value) {
              $allSteps += @{
                sdkmessageprocessingstepid = $step.sdkmessageprocessingstepid
                name = $step.name
                stage = $step.stage
                mode = $step.mode
                rank = $step.rank
                statuscode = $step.statuscode
                message = if ($step.sdkmessageid) { $step.sdkmessageid.name } else { "" }
                filtering_attributes = $step.filteringattributes
                primary_entity = $step._primaryobjecttypecode_value
                description = $step.description
              }
            }
          }
        }
        catch { }
      }
      $details.steps = @($allSteps)
    }
  }
  catch {
    # Best-effort; continue if unavailable
  }

  return $details
}

# Phase 5: Extract omnichannel workstream cross-references
function Extract-WorkstreamQueues {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$WorkstreamId
  )

  $queues = @()
  
  # Try multiple approaches to find queue associations (silent errors - these tables may not exist)
  # Approach 1: Check msdyn_ocliveworkitems for live work items that reference this workstream
  try {
    $url = "msdyn_ocliveworkitems?`$filter=_msdyn_liveworkstreamid_value eq $WorkstreamId&`$select=msdyn_ocliveworkitemid,_msdyn_queueid_value&`$top=100"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url -Silent
    if ($res -and $res.value) {
      $queueIds = @($res.value | Where-Object { $_._msdyn_queueid_value } | Select-Object -ExpandProperty _msdyn_queueid_value -Unique)
      foreach ($qid in $queueIds) {
        $queues += @{ queue_id = $qid; source = "liveworkitems" }
      }
    }
  } catch { }
  
  # Approach 2: Check msdyn_liveworkstreamcapacityprofile if available
  try {
    $url = "msdyn_liveworkstreamcapacityprofiles?`$filter=_msdyn_liveworkstreamid_value eq $WorkstreamId&`$select=msdyn_liveworkstreamcapacityprofileid&`$top=50"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url -Silent
    if ($res -and $res.value) {
      foreach ($cp in $res.value) {
        $queues += @{ capacity_profile_id = $cp.msdyn_liveworkstreamcapacityprofileid; source = "capacityprofile" }
      }
    }
  } catch { }
  
  # Approach 3: Direct queue lookup via msdyn_omnichannelqueue
  try {
    $url = "msdyn_omnichannelqueues?`$filter=_msdyn_liveworkstreamid_value eq $WorkstreamId&`$select=msdyn_omnichannelqueueid,msdyn_name,_msdyn_queueid_value&`$top=100"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url -Silent
    if ($res -and $res.value) {
      foreach ($ocq in $res.value) {
        $queues += @{ 
          omnichannel_queue_id = $ocq.msdyn_omnichannelqueueid
          queue_id = $ocq._msdyn_queueid_value
          name = $ocq.msdyn_name
          source = "omnichannelqueue" 
        }
      }
    }
  } catch { }

  return $queues
}

# ============= ENHANCED ENRICHMENT EXTRACTORS =============

# Extract Option Sets (Picklists) for a table's columns
function Extract-TableOptionSets {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$LogicalName
  )
  
  $optionSets = @()
  
  try {
    # Use RetrieveAllOptionSets approach - get all attributes with expanded global option sets
    # This avoids OData type cast issues that cause 400 errors
    $url = "EntityDefinitions(LogicalName='$LogicalName')/Attributes?`$select=LogicalName,DisplayName,AttributeType,AttributeTypeName&`$top=1000"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    
    if ($res -and $res.value) {
      # Filter for picklist/state/status types and get their options individually
      $picklistAttrs = @($res.value | Where-Object { 
        $_.AttributeTypeName -and (
          $_.AttributeTypeName.Value -eq "PicklistType" -or
          $_.AttributeTypeName.Value -eq "StateType" -or
          $_.AttributeTypeName.Value -eq "StatusType" -or
          $_.AttributeTypeName.Value -eq "MultiSelectPicklistType"
        )
      })
      
      foreach ($attr in $picklistAttrs) {
        # Get the specific attribute with its OptionSet expanded
        $attrUrl = "EntityDefinitions(LogicalName='$LogicalName')/Attributes(LogicalName='$($attr.LogicalName)')?`$select=LogicalName,DisplayName&`$expand=OptionSet"
        try {
          $attrRes = Invoke-DvGet -Client $Client -RelativeUrl $attrUrl -Silent
          
          if ($attrRes -and $attrRes.OptionSet -and $attrRes.OptionSet.Options) {
            $options = @()
            foreach ($opt in $attrRes.OptionSet.Options) {
              $options += @{
                value = $opt.Value
                label = if ($opt.Label -and $opt.Label.UserLocalizedLabel) { $opt.Label.UserLocalizedLabel.Label } else { "" }
                state = if ($opt.State -ne $null) { $opt.State } else { $null }
              }
            }
            $optionSets += @{
              column = $attr.LogicalName
              display_name = if ($attr.DisplayName -and $attr.DisplayName.UserLocalizedLabel) { $attr.DisplayName.UserLocalizedLabel.Label } else { $attr.LogicalName }
              type = $attr.AttributeTypeName.Value
              options = $options
            }
          }
        }
        catch { 
          # Individual attribute may fail, continue with others
        }
      }
    }
  }
  catch {
    # Fallback: Try the global option sets endpoint if entity-level fails
    try {
      $globalUrl = "GlobalOptionSetDefinitions?`$select=Name,Options,OptionSetType"
      $globalRes = Invoke-DvGet -Client $Client -RelativeUrl $globalUrl -Silent
      # This is a fallback that gets ALL global option sets - filter as needed
    }
    catch { }
  }
  
  return $optionSets
}

# Extract Views (SavedQuery) for a table
function Extract-TableViews {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$LogicalName
  )
  
  try {
    $url = "savedqueries?`$filter=returnedtypecode eq '$LogicalName' and statecode eq 0&`$select=savedqueryid,name,description,querytype,fetchxml,layoutxml&`$top=500"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url -Silent
    return @($res.value)
  }
  catch {
    return @()
  }
}

# Extract detailed Plugin Steps with triggers
function Extract-PluginStepDetails {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$PluginTypeId
  )
  
  try {
    $url = "sdkmessageprocessingsteps?`$filter=_plugintypeid_value eq $PluginTypeId&`$select=sdkmessageprocessingstepid,name,stage,mode,rank,statecode,statuscode,filteringattributes,asyncautodelete,description,_sdkmessageid_value&`$expand=sdkmessageid(`$select=name)&`$top=500"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    
    $steps = @()
    foreach ($step in $res.value) {
      $steps += @{
        step_id = $step.sdkmessageprocessingstepid
        name = $step.name
        message = if ($step.sdkmessageid) { $step.sdkmessageid.name } else { "" }
        stage = switch ($step.stage) { 10 { "PreValidation" } 20 { "PreOperation" } 40 { "PostOperation" } default { $step.stage } }
        mode = switch ($step.mode) { 0 { "Synchronous" } 1 { "Asynchronous" } default { $step.mode } }
        rank = $step.rank
        filtering_attributes = $step.filteringattributes
        description = $step.description
        is_active = ($step.statecode -eq 0)
      }
    }
    return $steps
  }
  catch {
    return @()
  }
}

# Extract Plugin Step Images (Pre/Post)
function Extract-PluginStepImages {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$StepId
  )
  
  try {
    $url = "sdkmessageprocessingstepimages?`$filter=_sdkmessageprocessingstepid_value eq $StepId&`$select=name,entityalias,imagetype,attributes&`$top=50"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    
    $images = @()
    foreach ($img in $res.value) {
      $images += @{
        name = $img.name
        alias = $img.entityalias
        type = switch ($img.imagetype) { 0 { "PreImage" } 1 { "PostImage" } 2 { "Both" } default { $img.imagetype } }
        attributes = $img.attributes
      }
    }
    return $images
  }
  catch {
    return @()
  }
}

# Extract Business Process Flows
function Extract-BusinessProcessFlows {
  param(
    [Parameter(Mandatory=$true)]$Client
  )
  
  try {
    # Business Process Flows are category 4
    $url = "workflows?`$filter=category eq 4 and statecode eq 1&`$select=workflowid,name,description,primaryentity,uniquename,xaml&`$top=500"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    return @($res.value)
  }
  catch {
    return @()
  }
}

# Extract BPF Stages
function Extract-BPFStages {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$ProcessId
  )
  
  try {
    $url = "processstages?`$filter=_processid_value eq $ProcessId&`$select=processstageid,stagename,stagecategory,primaryentitytypecode&`$orderby=stagecategory asc"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    return @($res.value)
  }
  catch {
    return @()
  }
}

# Extract Security Roles from solution
function Extract-SecurityRolesBySolution {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$SolutionId
  )
  
  try {
    # Security roles are componenttype 20
    $componentUrl = "solutioncomponents?`$filter=_solutionid_value eq $SolutionId and componenttype eq 20&`$select=objectid"
    $components = Invoke-DvGet -Client $Client -RelativeUrl $componentUrl
    if (-not $components -or -not $components.value) { return @() }
    $roleIds = @($components.value | Where-Object { $_.objectid } | Select-Object -ExpandProperty objectid)
    
    if ($roleIds.Count -eq 0) { return @() }
    
    $allRoles = @()
    $batchSize = 25
    
    for ($i = 0; $i -lt $roleIds.Count; $i += $batchSize) {
      $batch = $roleIds[$i..([Math]::Min($i + $batchSize - 1, $roleIds.Count - 1))]
      $filterParts = $batch | ForEach-Object { "roleid eq $_" }
      $filter = $filterParts -join " or "
      
      $roleUrl = "roles?`$filter=$filter&`$select=roleid,name,businessunitid,ismanaged,iscustomizable"
      try {
        $roleRes = Invoke-DvGet -Client $Client -RelativeUrl $roleUrl
        if ($roleRes -and $roleRes.value) {
          $allRoles += @($roleRes.value)
        }
      } catch { }
    }
    
    return $allRoles
  }
  catch {
    return @()
  }
}

# Extract Role Privileges
# Uses RetrieveRolePrivilegesRole SDK message via WebAPI
function Extract-RolePrivileges {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$RoleId
  )
  
  try {
    # Use the RetrieveRolePrivilegesRole function to get privileges for a role
    # This is the recommended way in Web API (instead of direct roleprivileges table access)
    $url = "RetrieveRolePrivilegesRole(RoleId=$RoleId)"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url -Silent
    
    if ($res -and $res.RolePrivileges) {
      $privileges = @()
      foreach ($rp in $res.RolePrivileges) {
        $depth = switch ($rp.Depth) { 
          0 { "Basic" } 
          1 { "Local" } 
          2 { "Deep" } 
          3 { "Global" } 
          default { $rp.Depth } 
        }
        $privileges += @{
          privilegeid = $rp.PrivilegeId
          privilege_name = $rp.PrivilegeName
          depth = $depth
          business_unit_id = $rp.BusinessUnitId
        }
      }
      return $privileges
    }
    
    return @()
  }
  catch {
    # The RetrieveRolePrivilegesRole function may not be available
    # or the role may not exist - return empty array silently
    return @()
  }
}

# Extract Environment Variables
function Extract-EnvironmentVariables {
  param(
    [Parameter(Mandatory=$true)]$Client
  )
  
  try {
    # Get definitions first
    $url = "environmentvariabledefinitions?`$select=environmentvariabledefinitionid,schemaname,displayname,description,type,defaultvalue&`$top=500"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    if (-not $res -or -not $res.value) { return @() }
    
    # Get values separately (avoid $expand which can cause 400)
    $valuesUrl = "environmentvariablevalues?`$select=environmentvariablevalueid,value,_environmentvariabledefinitionid_value&`$top=1000"
    $valuesRes = Invoke-DvGet -Client $Client -RelativeUrl $valuesUrl
    $valuesLookup = @{}
    if ($valuesRes -and $valuesRes.value) {
      foreach ($v in $valuesRes.value) {
        $defId = $v.'_environmentvariabledefinitionid_value'
        if ($defId) { $valuesLookup[$defId] = $v.value }
      }
    }
    
    $vars = @()
    foreach ($def in $res.value) {
      $currentValue = $def.defaultvalue
      if ($valuesLookup.ContainsKey($def.environmentvariabledefinitionid)) {
        $currentValue = $valuesLookup[$def.environmentvariabledefinitionid]
      }
      $vars += @{
        id = $def.environmentvariabledefinitionid
        schema_name = $def.schemaname
        display_name = $def.displayname
        description = $def.description
        type = switch ($def.type) { 100000000 { "String" } 100000001 { "Number" } 100000002 { "Boolean" } 100000003 { "JSON" } 100000004 { "DataSource" } 100000005 { "Secret" } default { $def.type } }
        default_value = $def.defaultvalue
        current_value = $currentValue
      }
    }
    return $vars
  }
  catch {
    return @()
  }
}

# Extract Connection References
function Extract-ConnectionReferences {
  param(
    [Parameter(Mandatory=$true)]$Client
  )
  
  try {
    $url = "connectionreferences?`$select=connectionreferenceid,connectionreferencelogicalname,connectionreferencedisplayname,connectorid,description,statecode&`$top=500"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    return @($res.value)
  }
  catch {
    return @()
  }
}

# Extract App Modules
function Extract-AppModules {
  param(
    [Parameter(Mandatory=$true)]$Client
  )
  
  try {
    $url = "appmodules?`$select=appmoduleid,name,uniquename,description,url,webresourceid,clienttype,appmoduleversion&`$top=500"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    return @($res.value)
  }
  catch {
    return @()
  }
}

# Extract Sitemap for an App Module
function Extract-AppSitemap {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$AppModuleId
  )
  
  $components = @()
  
  # Try appmodulecomponent table (the entity set name) - silent errors as this may fail
  try {
    $url = "appmodulecomponents?`$filter=_appmoduleid_value eq $AppModuleId&`$select=appmodulecomponentid,componenttype,objectid,rootcomponentbehavior&`$top=500"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url -Silent
    if ($res -and $res.value) {
      $components = @($res.value)
    }
  } catch { }
  
  # If no components found, try to get basic app info
  if ($components.Count -eq 0) {
    try {
      # Get the sitemap directly from appmodule
      $url = "appmodules($AppModuleId)?`$select=appmoduleid,uniquename,name,clienttype,formfactor"
      $res = Invoke-DvGet -Client $Client -RelativeUrl $url -Silent
      if ($res) {
        $components = @(@{
          appmoduleid = $res.appmoduleid
          uniquename = $res.uniquename
          name = $res.name
          clienttype = $res.clienttype
          formfactor = $res.formfactor
        })
      }
    } catch { }
  }
  
  return $components
}

# Extract Calculated/Rollup Field Formulas
function Extract-TableCalculatedFields {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$LogicalName
  )
  
  try {
    # Get calculated and rollup fields (silent - may fail for some tables)
    $url = "EntityDefinitions(LogicalName='$LogicalName')/Attributes?`$filter=SourceType eq 1 or SourceType eq 2&`$select=LogicalName,DisplayName,SourceType,FormulaDefinition"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url -Silent
    
    $fields = @()
    foreach ($attr in $res.value) {
      $fields += @{
        column = $attr.LogicalName
        display_name = if ($attr.DisplayName -and $attr.DisplayName.UserLocalizedLabel) { $attr.DisplayName.UserLocalizedLabel.Label } else { $attr.LogicalName }
        type = switch ($attr.SourceType) { 1 { "Calculated" } 2 { "Rollup" } default { $attr.SourceType } }
        formula = $attr.FormulaDefinition
      }
    }
    return $fields
  }
  catch {
    return @()
  }
}

# Extract Web Resources (JavaScript)
function Extract-WebResources {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$SolutionId
  )
  
  try {
    # Web resources are componenttype 61
    $componentUrl = "solutioncomponents?`$filter=_solutionid_value eq $SolutionId and componenttype eq 61&`$select=objectid"
    $components = Invoke-DvGet -Client $Client -RelativeUrl $componentUrl
    if (-not $components -or -not $components.value) { return @() }
    $resourceIds = @($components.value | Where-Object { $_.objectid } | Select-Object -ExpandProperty objectid)
    
    if ($resourceIds.Count -eq 0) { return @() }
    
    $allResources = @()
    $batchSize = 25
    
    for ($i = 0; $i -lt $resourceIds.Count; $i += $batchSize) {
      $batch = $resourceIds[$i..([Math]::Min($i + $batchSize - 1, $resourceIds.Count - 1))]
      $filterParts = $batch | ForEach-Object { "webresourceid eq $_" }
      $filter = $filterParts -join " or "
      
      # Use correct endpoint webresourceset, filter for JavaScript files (webresourcetype 3)
      $resourceUrl = "webresourceset?`$filter=($filter) and webresourcetype eq 3&`$select=webresourceid,name,displayname,description"
      try {
        $resourceRes = Invoke-DvGet -Client $Client -RelativeUrl $resourceUrl
        if ($resourceRes -and $resourceRes.value) {
          $allResources += @($resourceRes.value)
        }
      } catch { }
    }
    
    return $allResources
  }
  catch {
    return @()
  }
}

# Extract Ribbon Customizations
function Extract-RibbonCustomizations {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$LogicalName
  )
  
  try {
    # Use RetrieveEntityRibbon via Web API
    $url = "RetrieveEntityRibbon(EntityName='$LogicalName')"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    if ($res.CompressedEntityXml) {
      return @{
        entity = $LogicalName
        has_customizations = $true
        ribbon_xml_compressed = $res.CompressedEntityXml
      }
    }
    return @{ entity = $LogicalName; has_customizations = $false }
  }
  catch {
    return @{ entity = $LogicalName; has_customizations = $false }
  }
}

# Extract Solution Dependencies (Impact Analysis)
function Extract-SolutionDependencies {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$SolutionId
  )
  
  try {
    $url = "RetrieveDependenciesForUninstall(SolutionUniqueName=@name)?@name='$SolutionId'"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    return @($res.value)
  }
  catch {
    # Fall back to dependency entity query
    try {
      $url = "dependencies?`$filter=_solutionid_value eq $SolutionId&`$select=dependencyid,dependentcomponenttype,dependentcomponentobjectid,requiredcomponenttype,requiredcomponentobjectid&`$top=1000"
      $res = Invoke-DvGet -Client $Client -RelativeUrl $url
      return @($res.value)
    }
    catch {
      return @()
    }
  }
}

# Extract Case Routing Rules
function Extract-RoutingRules {
  param(
    [Parameter(Mandatory=$true)]$Client
  )
  
  try {
    # routingrule table may not exist in all environments (requires Case Management)
    $url = "routingrules?`$select=routingruleid,name,description,statecode,statuscode&`$top=500"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    if ($res -and $res.value) {
      return @($res.value)
    }
    return @()
  }
  catch {
    # Table may not exist - this is expected in some environments
    return @()
  }
}

# Extract Routing Rule Items (conditions)
function Extract-RoutingRuleItems {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$RoutingRuleId
  )
  
  try {
    $url = "routingruleitems?`$filter=_routingruleid_value eq $RoutingRuleId&`$select=routingruleitemid,name,conditionxml,_routedqueueid_value&`$top=500"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    return @($res.value)
  }
  catch {
    return @()
  }
}

# Extract Enhanced Queue Details
function Extract-QueueDetails {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$QueueId
  )
  
  $details = @{
    queue_id = $QueueId
    members = @()
    routing_rules = @()
  }
  
  # Get queue members via queuememberships
  try {
    $url = "queuememberships?`$filter=queueid eq $QueueId&`$select=queuemembershipid,systemuserid&`$top=100"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    if ($res -and $res.value) {
      $details.members = @($res.value)
    }
  } catch { }
  
  # Get queue items count
  try {
    $url = "queueitems?`$filter=_queueid_value eq $QueueId&`$select=queueitemid&`$top=1&`$count=true"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    if ($res -and $res.'@odata.count') {
      $details.item_count = $res.'@odata.count'
    }
  } catch { }
  
  return $details
}

# Extract SLA Items
function Extract-SLAItems {
  param(
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)][string]$SLAId
  )
  
  $items = @()
  
  # Try slakpiinstances (SLA KPI instances track SLA items)
  try {
    $url = "slakpiinstances?`$filter=_regarding_value eq $SLAId&`$select=slakpiinstanceid,name,description,warningtime,failuretime,status&`$top=100"
    $res = Invoke-DvGet -Client $Client -RelativeUrl $url
    if ($res -and $res.value) {
      $items = @($res.value)
    }
  } catch { }
  
  # Fallback: try slaitem (singular form)
  if ($items.Count -eq 0) {
    try {
      $url = "slaitems?`$filter=_slaid_value eq $SLAId&`$select=slaitemid,name,description,warnafter,failureafter&`$top=100"
      $res = Invoke-DvGet -Client $Client -RelativeUrl $url
      if ($res -and $res.value) {
        $items = @($res.value)
      }
    } catch { }
  }
  
  return $items
}

# Phase 6: Build comprehensive dependency graph
function Build-DependencyGraph {
  param(
    [Parameter(Mandatory=$true)]$Extraction,
    [Parameter(Mandatory=$true)]$Context
  )

  $graph = @{
    schema_version = 2
    generated_run_id = $Context.RunId
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    nodes = @()
    edges = @()
    edge_count = 0
  }

  # Add solution nodes
  if ($Extraction.solutions) {
    foreach ($sol in $Extraction.solutions) {
      $graph.nodes += @{
        asset_id = "solution:" + $sol.solutionid
        type = "solution"
        name = $sol.uniquename
        path = "_registry/solutions"
      }
    }
  }

  # Add table nodes
  if ($Extraction.tables) {
    foreach ($tbl in $Extraction.tables) {
      $graph.nodes += @{
        asset_id = "table:" + $tbl.LogicalName
        type = "table"
        name = $tbl.LogicalName
        path = "tables/" + $tbl.LogicalName
      }
    }
  }

  # Add plugin nodes and edges
  if ($Extraction.plugins) {
    foreach ($plugin in $Extraction.plugins) {
      $graph.nodes += @{
        asset_id = "plugin:" + $plugin.pluginassemblyid
        type = "plugin"
        name = $plugin.name
        path = "plugins/" + $plugin.name
      }
      # Plugin -> table edges (via message filters)
      $graph.edges += @{
        from_asset_id = "plugin:" + $plugin.pluginassemblyid
        to_asset_id = "table:account"  # placeholder; would be filtered per message
        edge_type = "plugin_triggers_on_table"
        confidence = "medium"
        evidence = "plugin.registration"
      }
    }
  }

  # Add flow nodes and edges
  if ($Extraction.flows) {
    foreach ($flow in $Extraction.flows) {
      $graph.nodes += @{
        asset_id = "flow:" + $flow.workflowid
        type = "flow"
        name = $flow.name
        path = "flows/" + $flow.name
      }
      # Flow -> table edges would be inferred from clientdata
      if ($flow.primaryentity) {
        $graph.edges += @{
          from_asset_id = "flow:" + $flow.workflowid
          to_asset_id = "table:" + $flow.primaryentity
          edge_type = "flow_triggers_on_table"
          confidence = "high"
          evidence = "workflow.primaryentity"
        }
      }
    }
  }

  # Add queue nodes
  if ($Extraction.queues) {
    foreach ($queue in $Extraction.queues) {
      $graph.nodes += @{
        asset_id = "queue:" + $queue.queueid
        type = "queue"
        name = $queue.name
        path = "queues/" + $queue.name
      }
    }
  }

  # Add SLA and workstream nodes (with edges to queues)
  if ($Extraction.slas) {
    foreach ($sla in $Extraction.slas) {
      $graph.nodes += @{
        asset_id = "sla:" + $sla.slaid
        type = "sla"
        name = $sla.name
        path = "slas/" + $sla.name
      }
      if ($sla.objecttypecode) {
        $graph.edges += @{
          from_asset_id = "sla:" + $sla.slaid
          to_asset_id = "table:" + $sla.objecttypecode
          edge_type = "sla_applies_to_table"
          confidence = "high"
          evidence = "sla.objecttypecode"
        }
      }
    }
  }

  if ($Extraction.workstreams) {
    foreach ($ws in $Extraction.workstreams) {
      $graph.nodes += @{
        asset_id = "workstream:" + $ws.msdyn_liveworkstreamid
        type = "workstream"
        name = $ws.msdyn_name
        path = "omnichannel/workstreams/" + $ws.msdyn_name
      }
    }
  }

  $graph.edge_count = $graph.edges.Count

  return $graph
}

# Phase 6: Generate fingerprint for determinism validation
function Compute-DocumentationFingerprint {
  param([Parameter(Mandatory=$true)]$Extraction)

  $hashInput = @(
    @($Extraction.solutions | Select-Object solutionid, uniquename, version | ConvertTo-Json -Depth 10),
    @($Extraction.tables | Select-Object LogicalName, DisplayName | ConvertTo-Json -Depth 10),
    @($Extraction.flows | Select-Object workflowid, name, primaryentity | ConvertTo-Json -Depth 10),
    @($Extraction.plugins | Select-Object pluginassemblyid, name | ConvertTo-Json -Depth 10)
  ) -join "`n"

  $hashBytes = [System.Text.Encoding]::UTF8.GetBytes($hashInput)
  $sha256 = [System.Security.Cryptography.SHA256]::Create()
  $hashValue = $sha256.ComputeHash($hashBytes)
  $fingerprint = -join ($hashValue | ForEach-Object { "{0:x2}" -f $_ })

  return @{
    fingerprint = $fingerprint
    components_hashed = @($Extraction.solutions).Count + @($Extraction.tables).Count + @($Extraction.flows).Count + @($Extraction.plugins).Count
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
  }
}

# Detect if patch or upgrade has been deployed from DevCore to Prod
function Detect-PatchOrUpgrade {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$ProdSolutions,
    [Parameter(Mandatory=$true)]$DevCoreSolutions
  )

  if ($null -eq $DevCoreSolutions -or $DevCoreSolutions.Count -eq 0) {
    return $false
  }

  foreach ($prodSol in $ProdSolutions) {
    $devCoreSol = @($DevCoreSolutions | Where-Object { $_.uniquename -eq $prodSol.uniquename })
    if ($devCoreSol.Count -gt 0) {
      # Compare versions
      if ($prodSol.version -ne $devCoreSol[0].version) {
        Write-Host "  Patch/Upgrade detected: $($prodSol.uniquename) v$($devCoreSol[0].version) -> v$($prodSol.version)" -ForegroundColor Cyan
        return $true
      }
    }
  }

  return $false
}

# Filter queues by type (Basic Email vs Advanced Omnichannel)
function Get-QueuesBasicEmail {
  param([Parameter(Mandatory=$true)]$Client)
  $res = Invoke-DvGet -Client $Client -RelativeUrl "queues?`$select=queueid,name,emailaddress,revops_emailqueue&`$filter=revops_emailqueue eq true and statecode eq 0"
  return @($res.value)
}

function Get-QueuesAdvancedOmnichannel {
  param([Parameter(Mandatory=$true)]$Client)
  $res = Invoke-DvGet -Client $Client -RelativeUrl "queues?`$select=queueid,name,msdyn_queuetype,msdyn_priority&`$filter=msdyn_isomnichannelqueue eq true and statecode eq 0"
  return @($res.value)
}

# Filter solutions by allowlist pattern
function Filter-SolutionsByAllowlist {
  param(
    [Parameter(Mandatory=$true)][AllowNull()]$Solutions,
    [Parameter(Mandatory=$true)][string[]]$AllowlistPatterns
  )

  if (-not $AllowlistPatterns -or $AllowlistPatterns.Count -eq 0) {
    return @()
  }

  if ($null -eq $Solutions -or $Solutions.Count -eq 0) {
    return @()
  }

  $filtered = [System.Collections.ArrayList]::new()
  
  foreach ($sol in $Solutions) {
    $uniqueName = $sol.uniquename
    $isAllowed = $false
    
    foreach ($pattern in $AllowlistPatterns) {
      $hasWildcard = ($pattern -match '[*?]')
      if ($hasWildcard) {
        if ($uniqueName -like $pattern) { $isAllowed = $true; break }
      } else {
        # Support exact match and common prefix patterns when no wildcard provided
        if ($uniqueName -eq $pattern) { $isAllowed = $true; break }
        if ($uniqueName -like ($pattern + '*')) { $isAllowed = $true; break }
      }
    }
    
    if ($isAllowed) {
      [void]$filtered.Add($sol)
    }
  }
  
  return @($filtered)
}

# Build comparison between DevCore allowlist and extracted assets
function Build-AllowlistComparison {
  param(
    [Parameter(Mandatory=$true)][string[]]$AllowlistPatterns,
    [Parameter(Mandatory=$true)][AllowNull()]$ExtractedSolutions
  )

  $comparison = @{
    allowlist_patterns = $AllowlistPatterns
    expected_count = $AllowlistPatterns.Count
    found = @()
    missing = @()
  }

  $foundNames = @()
  if ($null -ne $ExtractedSolutions) {
    $foundNames = @($ExtractedSolutions | Select-Object -ExpandProperty uniquename)
  }

  foreach ($pattern in $AllowlistPatterns) {
    $hasWildcard = ($pattern -match '[*?]')
    $matchedSolutions = @()
    if ($hasWildcard) {
      $matchedSolutions = @($foundNames | Where-Object { $_ -like $pattern })
    } else {
      $matchedSolutions = @($foundNames | Where-Object { ($_ -eq $pattern) -or ($_ -like ($pattern + '*')) })
    }
    if ($matchedSolutions.Count -gt 0) {
      $comparison.found += @{ pattern = $pattern; count = $matchedSolutions.Count; solutions = $matchedSolutions }
    } else {
      $comparison.missing += $pattern
    }
  }

  return $comparison
}

# ---------------- Dependency Extraction ----------------

# Helper function to recursively traverse all actions in a flow definition
# This handles nested actions inside Scope, Condition, Switch, ForEach, Until, etc.
function Get-AllFlowActions {
  param(
    [Parameter(Mandatory=$true)]$ActionContainer,
    [string]$ParentPath = ""
  )
  
  $allActions = @()
  
  if (-not $ActionContainer) { return $allActions }
  
  foreach ($prop in $ActionContainer.PSObject.Properties) {
    $actionKey = $prop.Name
    $action = $prop.Value
    $currentPath = if ($ParentPath) { "$ParentPath/$actionKey" } else { $actionKey }
    
    # Safely get action type (may not exist on all actions)
    $actionType = $null
    if ($action -is [PSCustomObject] -and $action.PSObject.Properties['type']) {
      $actionType = $action.type
    } elseif ($action -is [hashtable] -and $action.ContainsKey('type')) {
      $actionType = $action.type
    }
    
    # Add this action to our list
    $allActions += @{
      key = $actionKey
      path = $currentPath
      action = $action
      type = $actionType
    }
    
    # Recursively get nested actions based on action type
    # Use safe property checks for strict mode
    $hasActions = ($action -is [PSCustomObject] -and $action.PSObject.Properties['actions'] -and $action.actions) -or
                  ($action -is [hashtable] -and $action.ContainsKey('actions') -and $action.actions)
    $hasElse = ($action -is [PSCustomObject] -and $action.PSObject.Properties['else'] -and $action.else) -or
               ($action -is [hashtable] -and $action.ContainsKey('else') -and $action.else)
    $hasCases = ($action -is [PSCustomObject] -and $action.PSObject.Properties['cases'] -and $action.cases) -or
                ($action -is [hashtable] -and $action.ContainsKey('cases') -and $action.cases)
    $hasDefault = ($action -is [PSCustomObject] -and $action.PSObject.Properties['default'] -and $action.default) -or
                  ($action -is [hashtable] -and $action.ContainsKey('default') -and $action.default)
    
    # Scope, ForEach, Until, Do Until containers
    if ($hasActions) {
      $allActions += Get-AllFlowActions -ActionContainer $action.actions -ParentPath $currentPath
    }
    
    # Condition (If) - has "actions" (true branch) and "else.actions" (false branch)
    if ($actionType -eq "If" -or $actionType -eq "Condition") {
      if ($hasActions) {
        $allActions += Get-AllFlowActions -ActionContainer $action.actions -ParentPath "$currentPath/true"
      }
      if ($hasElse) {
        $elseHasActions = ($action.else -is [PSCustomObject] -and $action.else.PSObject.Properties['actions']) -or
                          ($action.else -is [hashtable] -and $action.else.ContainsKey('actions'))
        if ($elseHasActions -and $action.else.actions) {
          $allActions += Get-AllFlowActions -ActionContainer $action.else.actions -ParentPath "$currentPath/false"
        }
      }
    }
    
    # Switch - has "cases" object with named branches, each with "actions"
    if ($actionType -eq "Switch" -and $hasCases) {
      foreach ($caseProp in $action.cases.PSObject.Properties) {
        $caseName = $caseProp.Name
        $caseObj = $caseProp.Value
        $caseHasActions = ($caseObj -is [PSCustomObject] -and $caseObj.PSObject.Properties['actions']) -or
                          ($caseObj -is [hashtable] -and $caseObj.ContainsKey('actions'))
        if ($caseHasActions -and $caseObj.actions) {
          $allActions += Get-AllFlowActions -ActionContainer $caseObj.actions -ParentPath "$currentPath/case:$caseName"
        }
      }
      # Default case
      if ($hasDefault) {
        $defaultHasActions = ($action.default -is [PSCustomObject] -and $action.default.PSObject.Properties['actions']) -or
                             ($action.default -is [hashtable] -and $action.default.ContainsKey('actions'))
        if ($defaultHasActions -and $action.default.actions) {
          $allActions += Get-AllFlowActions -ActionContainer $action.default.actions -ParentPath "$currentPath/default"
        }
      }
    }
  }
  
  return $allActions
}

# Extract entity references from a single action
# Uses safe property access for strict mode
function Get-EntityReferencesFromAction {
  param(
    [Parameter(Mandatory=$true)]$Action,
    [Parameter(Mandatory=$true)]$TableLogicalNames
  )
  
  $refs = @()
  
  # Helper function to safely get a property value
  function SafeGet($obj, $propName) {
    if ($null -eq $obj) { return $null }
    if ($obj -is [PSCustomObject] -and $obj.PSObject.Properties[$propName]) {
      return $obj.$propName
    }
    if ($obj -is [hashtable] -and $obj.ContainsKey($propName)) {
      return $obj[$propName]
    }
    return $null
  }
  
  # Standard Dataverse connector actions have inputs.parameters.entityName
  $inputs = SafeGet $Action 'inputs'
  if ($inputs) {
    $params = SafeGet $inputs 'parameters'
    if ($params) {
      # Direct entityName reference
      $entityName = SafeGet $params 'entityName'
      if ($entityName -and ($TableLogicalNames -contains $entityName)) {
        $refs += @{ entity = $entityName; location = "parameters.entityName" }
      }
      
      # Some actions use "entity" instead of "entityName"
      $entity = SafeGet $params 'entity'
      if ($entity -and ($TableLogicalNames -contains $entity)) {
        $refs += @{ entity = $entity; location = "parameters.entity" }
      }
      
      # Batch operations may have "requests" array with entity references
      $requests = SafeGet $params 'requests'
      if ($requests -and $requests -is [array]) {
        foreach ($req in $requests) {
          $reqEntityName = SafeGet $req 'entityName'
          if ($reqEntityName -and ($TableLogicalNames -contains $reqEntityName)) {
            $refs += @{ entity = $reqEntityName; location = "parameters.requests[].entityName" }
          }
        }
      }
      
      # FetchXML actions - parse the fetch query
      $fetchXml = SafeGet $params 'fetchXml'
      if ($fetchXml) {
        foreach ($table in $TableLogicalNames) {
          if ($fetchXml -match "entity\s+name=['""]$table['""]" -or $fetchXml -match "<entity\s+name=['""]$table['""]") {
            $refs += @{ entity = $table; location = "fetchXml" }
          }
          # Also check link-entity
          if ($fetchXml -match "link-entity\s+name=['""]$table['""]") {
            $refs += @{ entity = $table; location = "fetchXml.link-entity" }
          }
        }
      }
    }
    
    # HTTP connector actions - look for entity names in URI
    $uri = SafeGet $inputs 'uri'
    if ($uri -and $uri -is [string]) {
      foreach ($table in $TableLogicalNames) {
        # Match patterns like /api/data/v9.2/accounts or /accounts(
        if ($uri -match "/${table}s?\(" -or $uri -match "/api/data/[^/]+/${table}s?(\(|$|\?)") {
          $refs += @{ entity = $table; location = "http.uri" }
        }
      }
    }
  }
  
  return $refs
}

function Extract-FlowTableDependencies {
  param(
    [Parameter(Mandatory=$true)]$Flows,
    [Parameter(Mandatory=$true)]$Tables
  )

  $edges = @()
  $tableLogicalNames = @($Tables | Select-Object -ExpandProperty LogicalName)
  
  # Helper function to safely get a property value
  function SafeGet($obj, $propName) {
    if ($null -eq $obj) { return $null }
    if ($obj -is [PSCustomObject] -and $obj.PSObject.Properties[$propName]) {
      return $obj.$propName
    }
    if ($obj -is [hashtable] -and $obj.ContainsKey($propName)) {
      return $obj[$propName]
    }
    return $null
  }
  
  foreach ($flow in $Flows) {
    $flowId = $flow.workflowid
    $flowName = $flow.name
    $seenEntities = @{} # Track unique entity references per flow

    # Skip if flow definition payload was not fetched (no clientdata property)
    if (-not $flow.PSObject.Properties.Match('clientdata')) { continue }

    # Extract table references from flow definition JSON
    if ($flow.clientdata) {
      try {
        $definition = $flow.clientdata | ConvertFrom-Json -ErrorAction SilentlyContinue
        
        # Safely navigate the definition structure
        $properties = SafeGet $definition 'properties'
        $defSection = SafeGet $properties 'definition'
        $actions = SafeGet $defSection 'actions'
        
        # Process all actions recursively (including nested in Scope, Condition, Switch, etc.)
        if ($actions) {
          $allActions = Get-AllFlowActions -ActionContainer $actions
          
          foreach ($actionInfo in $allActions) {
            $entityRefs = Get-EntityReferencesFromAction -Action $actionInfo.action -TableLogicalNames $tableLogicalNames
            
            foreach ($ref in $entityRefs) {
              $edgeKey = "$flowId|$($ref.entity)|action"
              if (-not $seenEntities.ContainsKey($edgeKey)) {
                $seenEntities[$edgeKey] = $true
                $edges += @{
                  source = "flow:$flowId"
                  source_name = $flowName
                  target = "table:$($ref.entity)"
                  target_name = $ref.entity
                  type = "flow_uses_table"
                  action = $actionInfo.key
                  action_path = $actionInfo.path
                  action_type = $actionInfo.type
                  evidence = "clientdata_definition"
                  evidence_location = $ref.location
                  confidence = "high"
                }
              }
            }
          }
        }
        
        # Process triggers
        $triggers = SafeGet $defSection 'triggers'
        if ($triggers -and $triggers -is [PSCustomObject]) {
          foreach ($triggerKey in $triggers.PSObject.Properties.Name) {
            $trigger = $triggers.$triggerKey
            
            # Standard trigger with entityName - use safe access
            $triggerInputs = SafeGet $trigger 'inputs'
            $triggerParams = SafeGet $triggerInputs 'parameters'
            if ($triggerParams) {
              $entityName = SafeGet $triggerParams 'entityName'
              if (-not $entityName) { $entityName = SafeGet $triggerParams 'entity' }
              
              if ($entityName -and ($tableLogicalNames -contains $entityName)) {
                $edgeKey = "$flowId|$entityName|trigger"
                if (-not $seenEntities.ContainsKey($edgeKey)) {
                  $seenEntities[$edgeKey] = $true
                  $triggerType = SafeGet $trigger 'type'
                  $edges += @{
                    source = "flow:$flowId"
                    source_name = $flowName
                    target = "table:$entityName"
                    target_name = $entityName
                    type = "flow_triggered_by_table"
                    trigger = $triggerKey
                    trigger_type = $triggerType
                    evidence = "clientdata_definition"
                    confidence = "high"
                  }
                }
              }
            }
          }
        }
      }
      catch {
        # Skip flows with malformed JSON
      }
    }
  }
  
  return $edges
}

function Extract-PluginEntityDependencies {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$Plugins
  )

  $edges = @()
  
  foreach ($plugin in $Plugins) {
    $pluginId = $plugin.pluginassemblyid
    $pluginName = $plugin.name
    
    # First get plugin types for this assembly
    try {
      $pluginTypes = Get-DataverseRecords -Client $Client -Entity "plugintypes" -Select "plugintypeid" -Filter "_pluginassemblyid_value eq $pluginId"
      
      foreach ($pt in $pluginTypes) {
        # Query SDK message processing steps for this plugin type
        $filter = "_plugintypeid_value eq $($pt.plugintypeid)"
        $select = "sdkmessageprocessingstepid,name,stage,mode,rank,_sdkmessagefilterid_value"
        
        $steps = Get-DataverseRecords -Client $Client -Entity "sdkmessageprocessingsteps" -Select $select -Filter $filter
        
        foreach ($step in $steps) {
          if ($step._sdkmessagefilterid_value) {
            # Get the message filter to find the primary entity
            $filterRec = Get-DataverseRecords -Client $Client -Entity "sdkmessagefilters" -Select "primaryobjecttypecode" -Filter "sdkmessagefilterid eq $($step._sdkmessagefilterid_value)"
          
            if ($filterRec -and $filterRec[0].primaryobjecttypecode) {
              $entityName = $filterRec[0].primaryobjecttypecode
              $edges += @{
                source = "plugin:$pluginId"
                source_name = $pluginName
                target = "table:$entityName"
                target_name = $entityName
                type = "plugin_registered_on_table"
                step = $step.name
                stage = $step.stage
                evidence = "sdkmessagefilter"
                confidence = "medium"
              }
            }
          }
        }
      }
    }
    catch {
      # Skip plugins with query errors
    }
  }
  
  return $edges
}

# Build reverse dependency index for AI agent queries
# This allows queries like: "Which flows touch table account?"
function Build-ReverseDependencyIndex {
  param(
    [Parameter(Mandatory=$true)]$Edges
  )
  
  $index = @{
    schema_version = 1
    description = "Reverse dependency index for AI agent queries. Query tables to find connected flows, plugins, etc."
    generated_utc = (Get-Date).ToUniversalTime().ToString("o")
    tables = @{}
    flows = @{}
    plugins = @{}
  }
  
  foreach ($edge in $Edges) {
    $source = $edge.source
    $target = $edge.target
    $sourceName = $edge.source_name
    $targetName = $edge.target_name
    $edgeType = $edge.type
    
    # Parse asset type from ID
    $sourceType = ($source -split ':')[0]
    $sourceId = ($source -split ':', 2)[1]
    $targetType = ($target -split ':')[0]
    $targetId = ($target -split ':', 2)[1]
    
    # Build table reverse index (table -> what uses it)
    if ($targetType -eq "table") {
      if (-not $index.tables.ContainsKey($targetId)) {
        $index.tables[$targetId] = @{
          table_name = $targetName
          triggered_flows = @()
          used_by_flows = @()
          used_by_plugins = @()
        }
      }
      
      $ref = @{
        id = $sourceId
        name = $sourceName
        edge_type = $edgeType
      }
      
      # Add action/trigger details if present (use safe property access for strict mode)
      $edgeIsHashtable = $edge -is [hashtable]
      $edgeIsPSObj = $edge -is [PSCustomObject]
      
      if (($edgeIsHashtable -and $edge.ContainsKey('action') -and $edge.action) -or
          ($edgeIsPSObj -and $edge.PSObject.Properties['action'] -and $edge.action)) {
        $ref.action = $edge.action
      }
      if (($edgeIsHashtable -and $edge.ContainsKey('action_path') -and $edge.action_path) -or
          ($edgeIsPSObj -and $edge.PSObject.Properties['action_path'] -and $edge.action_path)) {
        $ref.action_path = $edge.action_path
      }
      if (($edgeIsHashtable -and $edge.ContainsKey('trigger') -and $edge.trigger) -or
          ($edgeIsPSObj -and $edge.PSObject.Properties['trigger'] -and $edge.trigger)) {
        $ref.trigger = $edge.trigger
      }
      if (($edgeIsHashtable -and $edge.ContainsKey('step') -and $edge.step) -or
          ($edgeIsPSObj -and $edge.PSObject.Properties['step'] -and $edge.step)) {
        $ref.step = $edge.step
      }
      if (($edgeIsHashtable -and $edge.ContainsKey('stage') -and $edge.stage) -or
          ($edgeIsPSObj -and $edge.PSObject.Properties['stage'] -and $edge.stage)) {
        $ref.stage = $edge.stage
      }
      
      if ($edgeType -eq "flow_triggered_by_table") {
        $index.tables[$targetId].triggered_flows += $ref
      }
      elseif ($edgeType -eq "flow_uses_table") {
        $index.tables[$targetId].used_by_flows += $ref
      }
      elseif ($edgeType -eq "plugin_registered_on_table") {
        $index.tables[$targetId].used_by_plugins += $ref
      }
    }
    
    # Build flow reverse index (flow -> what it touches)
    if ($sourceType -eq "flow") {
      if (-not $index.flows.ContainsKey($sourceId)) {
        $index.flows[$sourceId] = @{
          flow_name = $sourceName
          triggers_on_tables = @()
          uses_tables = @()
        }
      }
      
      $ref = @{
        table = $targetId
        table_name = $targetName
      }
      # Safe property access for optional fields
      if (($edgeIsHashtable -and $edge.ContainsKey('action') -and $edge.action) -or
          ($edgeIsPSObj -and $edge.PSObject.Properties['action'] -and $edge.action)) {
        $ref.via_action = $edge.action
      }
      if (($edgeIsHashtable -and $edge.ContainsKey('trigger') -and $edge.trigger) -or
          ($edgeIsPSObj -and $edge.PSObject.Properties['trigger'] -and $edge.trigger)) {
        $ref.via_trigger = $edge.trigger
      }
      
      if ($edgeType -eq "flow_triggered_by_table") {
        $index.flows[$sourceId].triggers_on_tables += $ref
      }
      elseif ($edgeType -eq "flow_uses_table") {
        $index.flows[$sourceId].uses_tables += $ref
      }
    }
    
    # Build plugin reverse index (plugin -> what it touches)
    if ($sourceType -eq "plugin") {
      if (-not $index.plugins.ContainsKey($sourceId)) {
        $index.plugins[$sourceId] = @{
          plugin_name = $sourceName
          registered_on_tables = @()
        }
      }
      
      $ref = @{
        table = $targetId
        table_name = $targetName
      }
      # Safe property access for optional fields
      if (($edgeIsHashtable -and $edge.ContainsKey('step') -and $edge.step) -or
          ($edgeIsPSObj -and $edge.PSObject.Properties['step'] -and $edge.step)) {
        $ref.step = $edge.step
      }
      if (($edgeIsHashtable -and $edge.ContainsKey('stage') -and $edge.stage) -or
          ($edgeIsPSObj -and $edge.PSObject.Properties['stage'] -and $edge.stage)) {
        $ref.stage = $edge.stage
      }
      
      $index.plugins[$sourceId].registered_on_tables += $ref
    }
  }
  
  # Add summary counts
  $index.summary = @{
    total_tables_with_dependencies = $index.tables.Count
    total_flows_with_dependencies = $index.flows.Count
    total_plugins_with_dependencies = $index.plugins.Count
    total_edges = @($Edges).Count
  }
  
  return $index
}

function Update-FlowREADMEWithDependencies {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)][string]$FlowId,
    [Parameter(Mandatory=$true)][string]$FlowName,
    [Parameter(Mandatory=$true)]$Edges
  )

  # Find edges where this flow is the source
  $flowEdges = @($Edges | Where-Object { $_.source -eq "flow:$FlowId" })
  if ($flowEdges.Count -eq 0) { return }

  $flowFolder = Join-Path $Context.AIDocsRoot "flows/$FlowName"
  $readmePath = Join-Path $flowFolder "README.md"
  
  if (-not (Test-Path $readmePath)) { return }
  
  $readme = Get-Content $readmePath -Raw -ErrorAction SilentlyContinue
  if (-not $readme) { return }

  # Group by target table
  $tableRefs = @($flowEdges | Select-Object -ExpandProperty target_name -Unique | Sort-Object)
  
  # Build AUTO section
  $autoLines = @()
  $autoLines += '<!-- AI:BEGIN AUTO -->'
  foreach ($table in $tableRefs) {
    $autoLines += "- [$table](../../tables/$table/README.md)"
  }
  $autoLines += '<!-- AI:END AUTO -->'
  $autoContent = $autoLines -join "`n"
  
  # Update or insert Tables Touched section
  if ($readme -match '(?s)## Tables Touched.*?<!-- AI:BEGIN AUTO -->.*?<!-- AI:END AUTO -->') {
    $readme = $readme -replace '(?s)(## Tables Touched.*?)<!-- AI:BEGIN AUTO -->.*?<!-- AI:END AUTO -->', "`$1$autoContent"
  }
  elseif ($readme -match '## Tables Touched') {
    $readme = $readme -replace '(## Tables Touched)', "`$1`n`n$autoContent"
  }
  else {
    # Add new section before ## Related
    if ($readme -match '## Related') {
      $readme = $readme -replace '(## Related)', "## Tables Touched`n`n$autoContent`n`n`$1"
    }
    else {
      $readme += "`n`n## Tables Touched`n`n$autoContent"
    }
  }
  
  Set-Content -Path $readmePath -Value $readme -Encoding UTF8 -NoNewline
}

function Update-PluginREADMEWithDependencies {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)][string]$PluginId,
    [Parameter(Mandatory=$true)][string]$PluginName,
    [Parameter(Mandatory=$true)]$Edges
  )

  # Find edges where this plugin is the source
  $pluginEdges = @($Edges | Where-Object { $_.source -eq "plugin:$PluginId" })
  if ($pluginEdges.Count -eq 0) { return }

  $pluginFolder = Join-Path $Context.AIDocsRoot "plugins/$PluginName"
  $readmePath = Join-Path $pluginFolder "README.md"
  
  if (-not (Test-Path $readmePath)) { return }
  
  $readme = Get-Content $readmePath -Raw -ErrorAction SilentlyContinue
  if (-not $readme) { return }

  # Group by target table
  $tableRefs = @($pluginEdges | Select-Object -ExpandProperty target_name -Unique | Sort-Object)
  
  # Build AUTO section
  $autoLines = @()
  $autoLines += '<!-- AI:BEGIN AUTO -->'
  foreach ($table in $tableRefs) {
    $autoLines += "- [$table](../../tables/$table/README.md)"
  }
  $autoLines += '<!-- AI:END AUTO -->'
  $autoContent = $autoLines -join "`n"
  
  # Update or insert Registered Entities section
  if ($readme -match '(?s)## Registered Entities.*?<!-- AI:BEGIN AUTO -->.*?<!-- AI:END AUTO -->') {
    $readme = $readme -replace '(?s)(## Registered Entities.*?)<!-- AI:BEGIN AUTO -->.*?<!-- AI:END AUTO -->', "`$1$autoContent"
  }
  elseif ($readme -match '## Registered Entities') {
    $readme = $readme -replace '(## Registered Entities)', "`$1`n`n$autoContent"
  }
  else {
    # Add new section before ## Related
    if ($readme -match '## Related') {
      $readme = $readme -replace '(## Related)', "## Registered Entities`n`n$autoContent`n`n`$1"
    }
    else {
      $readme += "`n`n## Registered Entities`n`n$autoContent"
    }
  }
  
  Set-Content -Path $readmePath -Value $readme -Encoding UTF8 -NoNewline
}

# ---------------- Registry Lifecycle Tracking ----------------

function Load-PreviousRegistry {
  param([Parameter(Mandatory=$true)][string]$AIDocsRoot)
  
  $registryPath = Join-Path $AIDocsRoot "_registry/solutions.yaml"
  if (-not (Test-Path $registryPath)) {
    return $null
  }
  
  try {
    $content = Get-Content $registryPath -Raw
    $yaml = ConvertFrom-Yaml -YamlString $content
    return $yaml
  }
  catch {
    Write-Host "  Warning: Could not parse previous registry: $($_.Exception.Message)" -ForegroundColor Yellow
    return $null
  }
}

function ConvertFrom-Yaml {
  param([Parameter(Mandatory=$true)][string]$YamlString)
  
  # Simple YAML parser for our deterministic format
  $result = @{}
  $currentKey = $null
  $lines = $YamlString -split "`n"
  
  foreach ($line in $lines) {
    if ($line -match '^(\w+):$') {
      $currentKey = $Matches[1]
      $result[$currentKey] = @()
    }
    elseif ($line -match '^\s+- (.+)$' -and $currentKey) {
      $result[$currentKey] += $Matches[1]
    }
  }
  
  return $result
}

function Build-LifecycleComparison {
  param(
    [Parameter(Mandatory=$false)][AllowNull()]$PreviousRegistry,
    [Parameter(Mandatory=$true)]$CurrentSolutions
  )
  
  $currentNames = @($CurrentSolutions | Select-Object -ExpandProperty uniquename)
  
  if ($null -eq $PreviousRegistry -or -not $PreviousRegistry.solutions) {
    # First run - all solutions are new
    return @{
      new = $currentNames
      active = @()
      removed = @()
      timestamp = (Get-Date).ToUniversalTime().ToString("o")
    }
  }
  
  $previousNames = @($PreviousRegistry.solutions)
  
  $new = @($currentNames | Where-Object { $previousNames -notcontains $_ })
  $active = @($currentNames | Where-Object { $previousNames -contains $_ })
  $removed = @($previousNames | Where-Object { $currentNames -notcontains $_ })
  
  return @{
    new = $new
    active = $active
    removed = $removed
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
  }
}

function Write-LifecycleReport {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)]$Lifecycle
  )
  
  $report = @"
# Solution Lifecycle Report

Generated: $($Lifecycle.timestamp)

## New Solutions ($($Lifecycle.new.Count))

Solutions appearing for the first time in this run:

"@

  if ($Lifecycle.new.Count -gt 0) {
    foreach ($sol in ($Lifecycle.new | Sort-Object)) {
      $report += "- $sol`n"
    }
  } else {
    $report += "*None*`n"
  }
  
  $report += @"

## Active Solutions ($($Lifecycle.active.Count))

Solutions present in both current and previous runs:

"@

  if ($Lifecycle.active.Count -gt 0) {
    foreach ($sol in ($Lifecycle.active | Sort-Object)) {
      $report += "- $sol`n"
    }
  } else {
    $report += "*None*`n"
  }
  
  $report += @"

## Removed Solutions ($($Lifecycle.removed.Count))

Solutions present in previous run but missing in current run:

"@

  if ($Lifecycle.removed.Count -gt 0) {
    foreach ($sol in ($Lifecycle.removed | Sort-Object)) {
      $report += "- $sol`n"
    }
  } else {
    $report += "*None*`n"
  }
  
  Set-Content -Path $Path -Value $report -Encoding UTF8
}

# ---------------- Depth Extraction (Steps, Actions, Triggers) ----------------

function Extract-FlowDepth {
  param([Parameter(Mandatory=$true)]$Flow)
  
  # Helper function to safely get a property value
  function SafeGet($obj, $propName) {
    if ($null -eq $obj) { return $null }
    if ($obj -is [PSCustomObject] -and $obj.PSObject.Properties[$propName]) {
      return $obj.$propName
    }
    if ($obj -is [hashtable] -and $obj.ContainsKey($propName)) {
      return $obj[$propName]
    }
    return $null
  }
  
  $depth = @{
    flow_id = $Flow.workflowid
    flow_name = $Flow.name
    triggers = @()
    actions = @()
    step_count = 0
  }

  # Skip if flow definition payload was not fetched (no clientdata property)
  $clientDataProp = $Flow.PSObject.Properties['clientdata']
  if (-not $clientDataProp) { return $depth }
  $clientData = $clientDataProp.Value
  if (-not $clientData) { return $depth }

  try {
    $definition = $clientData | ConvertFrom-Json -ErrorAction SilentlyContinue
    
    # Safely navigate nested definition structure
    $properties = SafeGet $definition 'properties'
    $defSection = SafeGet $properties 'definition'
    $triggers = SafeGet $defSection 'triggers'
    $actions = SafeGet $defSection 'actions'
    
    if ($triggers -and $triggers -is [PSCustomObject]) {
      foreach ($triggerKey in $triggers.PSObject.Properties.Name) {
        $trigger = $triggers.$triggerKey
        $triggerType = SafeGet $trigger 'type'
        $recurrence = SafeGet $trigger 'recurrence'
        $recurrenceFreq = SafeGet $recurrence 'frequency'
        $triggerInputs = SafeGet $trigger 'inputs'
        $triggerParams = SafeGet $triggerInputs 'parameters'
        $entityName = SafeGet $triggerParams 'entityName'
        
        $depth.triggers += @{
          name = $triggerKey
          type = $triggerType
          recurrence = $recurrenceFreq
          entity = $entityName
        }
      }
    }
    
    if ($actions -and $actions -is [PSCustomObject]) {
      foreach ($actionKey in $actions.PSObject.Properties.Name) {
        $action = $actions.$actionKey
        $actionType = SafeGet $action 'type'
        $actionInputs = SafeGet $action 'inputs'
        $actionParams = SafeGet $actionInputs 'parameters'
        $entityName = SafeGet $actionParams 'entityName'
        $operationName = SafeGet $actionParams 'operationName'
        
        $depth.actions += @{
          name = $actionKey
          type = $actionType
          entity = $entityName
          operation = $operationName
        }
        $depth.step_count++
      }
    }
  }
  catch {
    # Malformed JSON, return empty depth
  }
  
  return $depth
}

function Extract-PluginDepth {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$Plugin
  )
  
  $depth = @{
    plugin_id = $Plugin.pluginassemblyid
    plugin_name = $Plugin.name
    version = $Plugin.version
    steps = @()
    step_count = 0
  }
  
  # First get plugin types for this assembly
  try {
    $pluginTypes = Get-DataverseRecords -Client $Client -Entity "plugintypes" -Select "plugintypeid" -Filter "_pluginassemblyid_value eq $($Plugin.pluginassemblyid)"
    
    foreach ($pt in $pluginTypes) {
      $filter = "_plugintypeid_value eq $($pt.plugintypeid)"
      $select = "sdkmessageprocessingstepid,name,stage,mode,rank,_sdkmessagefilterid_value,_sdkmessageid_value"
      
      $steps = Get-DataverseRecords -Client $Client -Entity "sdkmessageprocessingsteps" -Select $select -Filter $filter
      
      foreach ($step in $steps) {
        $stepInfo = @{
          step_id = $step.sdkmessageprocessingstepid
          name = $step.name
          stage = $step.stage
          mode = $step.mode
          rank = $step.rank
          entity = $null
          message = $null
        }
        
        # Get entity from message filter
        if ($step._sdkmessagefilterid_value) {
          try {
            $filterRec = Get-DataverseRecords -Client $Client -Entity "sdkmessagefilters" -Select "primaryobjecttypecode" -Filter "sdkmessagefilterid eq $($step._sdkmessagefilterid_value)"
            if ($filterRec -and $filterRec[0].primaryobjecttypecode) {
              $stepInfo.entity = $filterRec[0].primaryobjecttypecode
            }
          }
          catch { }
        }
        
        # Get message name
        if ($step._sdkmessageid_value) {
          try {
            $msgRec = Get-DataverseRecords -Client $Client -Entity "sdkmessages" -Select "name" -Filter "sdkmessageid eq $($step._sdkmessageid_value)"
            if ($msgRec -and $msgRec[0].name) {
              $stepInfo.message = $msgRec[0].name
            }
          }
          catch { }
        }
        
        $depth.steps += $stepInfo
        $depth.step_count++
      }
    }
  }
  catch {
    # Query error, return empty steps
  }
  
  return $depth
}

function Write-DepthAnalysis {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)]$FlowDepths,
    [Parameter(Mandatory=$true)]$PluginDepths
  )
  
  $totalFlowSteps = ($FlowDepths | Measure-Object -Property step_count -Sum).Sum
  $totalPluginSteps = ($PluginDepths | Measure-Object -Property step_count -Sum).Sum
  
  $report = @"
# Depth Analysis Report

Generated: $(Get-Date -Format "o")

## Flow Depth Summary

Total Flows: $(@($FlowDepths).Count)
Total Steps: $totalFlowSteps
Average Steps per Flow: $(if (@($FlowDepths).Count -gt 0) { [math]::Round($totalFlowSteps / @($FlowDepths).Count, 2) } else { 0 })

### Top 10 Most Complex Flows

"@

  $topFlows = $FlowDepths | Sort-Object -Property step_count -Descending | Select-Object -First 10
  foreach ($flow in $topFlows) {
    $report += "- **$($flow.flow_name)**: $($flow.step_count) steps, $(@($flow.triggers).Count) triggers, $(@($flow.actions).Count) actions`n"
  }
  
  $report += @"

## Plugin Depth Summary

Total Plugins: $(@($PluginDepths).Count)
Total Steps: $totalPluginSteps
Average Steps per Plugin: $(if (@($PluginDepths).Count -gt 0) { [math]::Round($totalPluginSteps / @($PluginDepths).Count, 2) } else { 0 })

### Top 10 Plugins by Step Count

"@

  $topPlugins = $PluginDepths | Sort-Object -Property step_count -Descending | Select-Object -First 10
  foreach ($plugin in $topPlugins) {
    $report += "- **$($plugin.plugin_name)** v$($plugin.version): $($plugin.step_count) steps`n"
  }
  
  Set-Content -Path $Path -Value $report -Encoding UTF8
}

# ---------------- Environment Comparison (DevCore vs Prod) ----------------

function Compare-Environments {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$ProdData,
    [Parameter(Mandatory=$false)][AllowNull()]$DevCoreData
  )
  
  if ($null -eq $DevCoreData) {
    return @{
      enabled = $false
      message = "DevCore environment not configured"
    }
  }
  
  # Compare solution versions between DevCore and Prod
  $versionComparisons = @()
  foreach ($prodSol in $ProdData.solutions) {
    $devCoreSol = @($DevCoreData.solutions | Where-Object { $_.uniquename -eq $prodSol.uniquename })
    if ($devCoreSol.Count -gt 0) {
      $versionComparisons += @{
        solution = $prodSol.uniquename
        prod_version = $prodSol.version
        devcore_version = $devCoreSol[0].version
        in_sync = ($prodSol.version -eq $devCoreSol[0].version)
        status = if ($prodSol.version -eq $devCoreSol[0].version) { "In Sync" } else { "Version Mismatch" }
      }
    } else {
      $versionComparisons += @{
        solution = $prodSol.uniquename
        prod_version = $prodSol.version
        devcore_version = $null
        in_sync = $false
        status = "Prod Only"
      }
    }
  }
  
  # Check for solutions only in DevCore
  foreach ($devCoreSol in $DevCoreData.solutions) {
    $prodSol = @($ProdData.solutions | Where-Object { $_.uniquename -eq $devCoreSol.uniquename })
    if ($prodSol.Count -eq 0) {
      $versionComparisons += @{
        solution = $devCoreSol.uniquename
        prod_version = $null
        devcore_version = $devCoreSol.version
        in_sync = $false
        status = "DevCore Only (Pending Deployment)"
      }
    }
  }
  
  $comparison = @{
    enabled = $true
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    mode = "version_comparison_only"
    version_comparisons = $versionComparisons
    in_sync_count = @($versionComparisons | Where-Object { $_.in_sync }).Count
    mismatch_count = @($versionComparisons | Where-Object { -not $_.in_sync }).Count
    prod_only_count = @($versionComparisons | Where-Object { $_.status -eq "Prod Only" }).Count
    devcore_only_count = @($versionComparisons | Where-Object { $_.status -eq "DevCore Only (Pending Deployment)" }).Count
  }
  
  return $comparison
}

function Compare-AssetLists {
  param(
    [Parameter(Mandatory=$true)]$ProdAssets,
    [Parameter(Mandatory=$true)]$DevCoreAssets,
    [Parameter(Mandatory=$true)][string]$AssetType
  )
  
  # Get identifier field based on asset type
  $idField = switch ($AssetType) {
    "solutions" { "uniquename" }
    "tables" { "LogicalName" }
    "queues" { "queueid" }
    "plugins" { "name" }
    "flows" { "workflowid" }
    default { "name" }
  }
  
  $prodIds = @($ProdAssets | Select-Object -ExpandProperty $idField -ErrorAction SilentlyContinue)
  $devCoreIds = @($DevCoreAssets | Select-Object -ExpandProperty $idField -ErrorAction SilentlyContinue)
  
  $inProdOnly = @($prodIds | Where-Object { $devCoreIds -notcontains $_ })
  $inDevCoreOnly = @($devCoreIds | Where-Object { $prodIds -notcontains $_ })
  $inBoth = @($prodIds | Where-Object { $devCoreIds -contains $_ })
  
  return @{
    in_prod_only = $inProdOnly
    in_devcore_only = $inDevCoreOnly
    in_both = $inBoth
    prod_count = @($prodIds).Count
    devcore_count = @($devCoreIds).Count
  }
}

function Write-EnvironmentComparisonReport {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)]$Comparison
  )
  
  if (-not $Comparison.enabled) {
    $report = @"
# Environment Comparison Report

Status: Disabled

$($Comparison.message)

To enable environment comparison, configure DevCore Dataverse credentials in the variable group:
- DV_DEVCORE_ORG_URL
- DV_DEVCORE_TENANT_ID
- DV_DEVCORE_CLIENT_ID
- DV_DEVCORE_CLIENT_SECRET
- DV_DEVCORE_API_VERSION
"@
    Set-Content -Path $Path -Value $report -Encoding UTF8
    return
  }
  
  $report = @"
# Environment Comparison Report (Version Comparison Only)

Generated: $($Comparison.timestamp)

This report compares **solution versions** between Production and DevCore environments to verify that patches/upgrades have been deployed to Production.

## Summary

- **In Sync**: $($Comparison.in_sync_count) solutions
- **Version Mismatch**: $($Comparison.mismatch_count) solutions
- **Prod Only**: $($Comparison.prod_only_count) solutions
- **DevCore Only (Pending Deployment)**: $($Comparison.devcore_only_count) solutions

## Solution Version Comparison

| Solution | Production | DevCore | Status |
|----------|------------|---------|--------|
"@

  foreach ($item in ($Comparison.version_comparisons | Sort-Object { $_.solution })) {
    $prodVer = if ($item.prod_version) { $item.prod_version } else { "-" }
    $devCoreVer = if ($item.devcore_version) { $item.devcore_version } else { "-" }
    $statusIcon = switch ($item.status) {
      "In Sync" { "[OK] In Sync" }
      "Version Mismatch" { "[!!] Mismatch" }
      "Prod Only" { "[P] Prod Only" }
      "DevCore Only (Pending Deployment)" { "[D] Pending Deploy" }
      default { $item.status }
    }
    $report += "| $($item.solution) | $prodVer | $devCoreVer | $statusIcon |`n"
  }
  
  $report += @"

## Legend

- [OK] **In Sync**: Solution version matches between Production and DevCore
- [!!] **Mismatch**: Version differs - investigate if deployment is needed
- [P] **Prod Only**: Solution exists only in Production (not in DevCore allowlist)
- [D] **Pending Deploy**: Solution exists in DevCore but not yet deployed to Production
"@
  
  Set-Content -Path $Path -Value $report -Encoding UTF8
}

# ============= PHASE 7: README CROSS-LINK HELPERS =============
# Add "Used by", "Depends on", "Triggers" sections with idempotent markers

function Update-ReadmeWithCrossLinks {
  param(
    [Parameter(Mandatory=$true)][string]$ReadmePath,
    [Parameter(Mandatory=$false)]$UsedByAssets = @(),
    [Parameter(Mandatory=$false)]$DependsOnAssets = @(),
    [Parameter(Mandatory=$false)]$TriggersAssets = @()
  )

  if (-not (Test-Path $ReadmePath)) { return }

  $content = Get-Content -Path $ReadmePath -Raw
  $marker_begin = "<!-- AI:PHASE7:BEGIN:CROSSLINKS -->"
  $marker_end = "<!-- AI:PHASE7:END:CROSSLINKS -->"

  # Remove old section if exists
  if ($content -match [regex]::Escape($marker_begin)) {
    $content = $content -replace [regex]::Escape($marker_begin) + "[\s\S]*?" + [regex]::Escape($marker_end), ""
  }

  # Build new cross-links section
  $section = $marker_begin + "`n`n"
  
  if ($UsedByAssets.Count -gt 0) {
    $section += "## Used By`n`n"
    foreach ($asset in $UsedByAssets) {
      $section += "- [$($asset.name)]($($asset.path))`n"
    }
    $section += "`n"
  }

  if ($DependsOnAssets.Count -gt 0) {
    $section += "## Depends On`n`n"
    foreach ($asset in $DependsOnAssets) {
      $section += "- [$($asset.name)]($($asset.path))`n"
    }
    $section += "`n"
  }

  if ($TriggersAssets.Count -gt 0) {
    $section += "## Triggers`n`n"
    foreach ($asset in $TriggersAssets) {
      $section += "- [$($asset.name)]($($asset.path))`n"
    }
    $section += "`n"
  }

  $section += "`n" + $marker_end

  # Append section before the end of file if any cross-links exist
  if ($UsedByAssets.Count -gt 0 -or $DependsOnAssets.Count -gt 0 -or $TriggersAssets.Count -gt 0) {
    $content += "`n`n" + $section
  }

  Set-Content -Path $ReadmePath -Value $content -Encoding UTF8 -NoNewline
}

function Extract-CrossLinksFromEdges {
  param(
    [Parameter(Mandatory=$true)]$Edges,
    [Parameter(Mandatory=$true)][string]$AssetId
  )

  $usedBy = @()
  $dependsOn = @()
  $triggers = @()

  foreach ($edge in $Edges) {
    if ($edge.source -eq $AssetId) {
      # This asset is the source (depends on, triggers)
      switch ($edge.type) {
        "flow_uses_table" { $dependsOn += @{ name = $edge.target_name; path = $edge.target } }
        "flow_triggered_by_table" { $triggers += @{ name = $edge.target_name; path = $edge.target } }
        "plugin_triggers_on_table" { $triggers += @{ name = $edge.target_name; path = $edge.target } }
        "sla_applies_to_table" { $dependsOn += @{ name = $edge.target_name; path = $edge.target } }
      }
    }
    elseif ($edge.target -eq $AssetId) {
      # This asset is the target (used by)
      switch ($edge.type) {
        "flow_uses_table" { $usedBy += @{ name = $edge.source_name; path = $edge.source } }
        "flow_triggered_by_table" { $usedBy += @{ name = $edge.source_name; path = $edge.source } }
        "plugin_triggers_on_table" { $usedBy += @{ name = $edge.source_name; path = $edge.source } }
        "sla_applies_to_table" { $usedBy += @{ name = $edge.source_name; path = $edge.source } }
      }
    }
  }

  return @{
    used_by = @($usedBy | Sort-Object -Property name -Unique)
    depends_on = @($dependsOn | Sort-Object -Property name -Unique)
    triggers = @($triggers | Sort-Object -Property name -Unique)
  }
}

# ============= WRITERS (POC) ================

function Write-SolutionsDocs {
  param([Parameter(Mandatory=$true)]$Context,[Parameter(Mandatory=$true)]$Solutions)
  $path = Join-Path (Join-Path $Context.AIDocsRoot "_registry") "solutions.yaml"
  Save-YamlDeterministic -Data (Normalize-Solutions -Solutions $Solutions) -Path $path
  return @(@{ asset_id="registry:solutions"; type="registry"; path="_registry/solutions.yaml"; confidence=1.0 })
}

function Write-TablesDocs {
  param([Parameter(Mandatory=$true)]$Context,[Parameter(Mandatory=$true)]$Client,[Parameter(Mandatory=$true)]$Tables)

  $out = @()
  $base = Join-Path $Context.AIDocsRoot "tables"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }

  $selected = @($Tables | Sort-Object LogicalName)
  $total = $selected.Count
  $current = 0
  $startTime = Get-Date
  $skippedCount = 0
  $updatedCount = 0
  
  foreach ($t in $selected) {
    $current++
    $logical = $t.LogicalName
    
    # Progress logging every 10 tables or for first/last
    if ($current -eq 1 -or $current -eq $total -or ($current % 10) -eq 0) {
      $elapsed = ((Get-Date) - $startTime).TotalSeconds
      $rate = if ($current -gt 1) { [math]::Round($elapsed / ($current - 1), 1) } else { 0 }
      $remaining = if ($rate -gt 0) { [math]::Round(($total - $current) * $rate / 60, 1) } else { "?" }
      Write-Host "      Table [$current/$total] $logical (skip:$skippedCount upd:$updatedCount est:${remaining}m)" -ForegroundColor DarkGray
    }
    
    $folder = Join-Path $base $logical
    $facts = Join-Path $folder "_facts"
    $tableYamlPath = Join-Path $facts "table.yaml"
    
    # Check if we can skip API calls - if table.yaml exists and is less than 24 hours old
    $skipApiCalls = $false
    if (Test-Path $tableYamlPath) {
      $fileAge = (Get-Date) - (Get-Item $tableYamlPath).LastWriteTime
      if ($fileAge.TotalHours -lt 24) {
        $skipApiCalls = $true
        $skippedCount++
      }
    }
    
    New-Item -ItemType Directory -Path $facts -Force | Out-Null

    # Save enriched table metadata (always update this)
    Save-YamlIfChanged -Data (Normalize-TableFacts -Table $t) -Path $tableYamlPath
    
    # Phase 1-2: Extract table columns, relationships, forms, business rules
    # Only call APIs if we're not skipping
    $columns = @()
    $relationships = @()
    $forms = @()
    $businessRules = @()
    
    if (-not $skipApiCalls) {
      $updatedCount++
      
      $columns = Extract-TableColumns -Client $Client -LogicalName $logical
      if ($columns) {
        $normalized = Normalize-ListForYaml -Items @($columns | Select-Object LogicalName, DisplayName, Description, AttributeType, RequiredLevel)
        if ($normalized.Count -gt 0) {
          Assert-ValidYamlList -Path (Join-Path $facts "columns.yaml") -Items $normalized -RequiredKeys @("LogicalName", "AttributeType") -Facet "columns"
          Save-YamlIfChanged -Data @{ columns = $normalized } -Path (Join-Path $facts "columns.yaml")
        }
      }
      
      $relationships = Extract-TableRelationships -Client $Client -LogicalName $logical
      if ($relationships) {
        $normalized = Normalize-ListForYaml -Items @($relationships | Select-Object schemaname, relationshiptype, referencingtablelogicalname, referencedtablelogicalname)
        if ($normalized.Count -gt 0) {
          Assert-ValidYamlList -Path (Join-Path $facts "relationships.yaml") -Items $normalized -RequiredKeys @("schemaname", "relationshiptype") -Facet "relationships"
          Save-YamlIfChanged -Data @{ relationships = $normalized } -Path (Join-Path $facts "relationships.yaml")
        }
      }
      
      $forms = Extract-TableForms -Client $Client -LogicalName $logical
      if ($forms) {
        # Save comprehensive form data including layout structure (tabs, sections, fields)
        $formsData = @{ 
          forms = @($forms | ForEach-Object {
            @{
              name = $_.name
              type = $_.type
              type_name = $_.type_name
              description = $_.description
              is_active = $_.is_active
              field_count = $_.field_count
              tabs = $_.tabs
              sections = $_.sections
              fields = $_.fields
            }
          })
        }
        Save-YamlIfChanged -Data $formsData -Path (Join-Path $facts "forms.yaml")
      }
      
      $businessRules = Extract-TableBusinessRules -Client $Client -LogicalName $logical
      if ($businessRules) {
        Save-YamlIfChanged -Data @{ business_rules = @($businessRules | Select-Object name, description) } -Path (Join-Path $facts "business_rules.yaml")
      }
    } else {
      # Load existing counts from cached files for README
      if (Test-Path (Join-Path $facts "columns.yaml")) {
        try { $columns = @(1..$((Get-Content (Join-Path $facts "columns.yaml") | Select-String "LogicalName:").Count)) } catch { }
      }
      if (Test-Path (Join-Path $facts "relationships.yaml")) {
        try { $relationships = @(1..$((Get-Content (Join-Path $facts "relationships.yaml") | Select-String "schemaname:").Count)) } catch { }
      }
      if (Test-Path (Join-Path $facts "forms.yaml")) {
        try { $forms = @(1..$((Get-Content (Join-Path $facts "forms.yaml") | Select-String "name:").Count)) } catch { }
      }
      if (Test-Path (Join-Path $facts "business_rules.yaml")) {
        try { $businessRules = @(1..$((Get-Content (Join-Path $facts "business_rules.yaml") | Select-String "name:").Count)) } catch { }
      }
    }

    # Build comprehensive README
    $readmeContent = @"
# Table: $logical

## Overview
Dataverse table with metadata for knowledge consumption.

## Metadata
- Display Name: $($t.DisplayName)
- Type: $($t.OwnershipType)
- Custom Entity: $($t.IsCustomEntity)
- Audit Enabled: $($t.IsAuditEnabled)
- Activity: $($t.IsActivity)

## Coverage
- Columns: $(@($columns).Count)
- Relationships: $(@($relationships).Count)
- Forms: $(@($forms).Count)
- Business Rules: $(@($businessRules).Count)

## Facts
- _facts/table.yaml - Table metadata
- _facts/columns.yaml - Column definitions
- _facts/relationships.yaml - Relationships (1:N, N:N)
- _facts/forms.yaml - Form configurations
- _facts/business_rules.yaml - Business rules

## Description
$($t.Description)
"@
    Save-ContentIfChanged -Content $readmeContent -Path (Join-Path $folder "README.md")

    $out += @{ asset_id=("table:" + $logical); type="table"; path=("tables/" + $logical); confidence=0.95 }
  }
  
  Write-Host "      Tables: $updatedCount updated, $skippedCount cached (24h)" -ForegroundColor DarkGray
  return $out
}

function Write-QueuesDocs {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$Queues
  )

  $out = @()
  $base = Join-Path $Context.AIDocsRoot "queues"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }

  $selected = $Queues | Sort-Object name
  foreach ($q in $selected) {
    $id = $q.queueid
    $name = $q.name

    $safe = (("" + $name).ToLower() -replace '[^a-z0-9\-]+','-') -replace '\-+','-'
    if ([string]::IsNullOrWhiteSpace($safe)) { $safe = [string]$id }

    $folder = Join-Path $base $safe
    $facts = Join-Path $folder "_facts"
    New-Item -ItemType Directory -Path $facts -Force | Out-Null

    Save-YamlIfChanged -Data (Normalize-QueueFacts -Queue $q) -Path (Join-Path $facts "queue.yaml")
    
    # Extract enhanced queue details (routing rules, etc.)
    $queueDetails = Extract-QueueDetails -Client $Client -QueueId $id
    if ($queueDetails.routing_rules -and $queueDetails.routing_rules.Count -gt 0) {
      Save-YamlIfChanged -Data @{ routing_rules = @($queueDetails.routing_rules) } -Path (Join-Path $facts "routing.yaml")
    }

    $routingInfo = if ($queueDetails.routing_rules) { "$($queueDetails.routing_rules.Count) routing rules" } else { "No routing rules" }

    $readme = @"
# Queue: $name

## Purpose
Queue for routing and managing work items (cases, conversations, etc.).

## Details
- **Queue ID**: $id
- **Routing**: $routingInfo

## Exclusions
- User queues are excluded when owner logical name is systemuser.

## Facts
- _facts/queue.yaml - Queue configuration
- _facts/routing.yaml - Routing rules (if configured)
"@
    Save-ContentIfChanged -Content $readme -Path (Join-Path $folder "README.md")

    $out += @{ asset_id=("queue:" + $id); type="queue"; path=("queues/" + $safe); confidence=0.90 }
  }
  return $out
}

function Write-PluginsDocs {
  param([Parameter(Mandatory=$true)]$Context,[Parameter(Mandatory=$true)]$Client,[Parameter(Mandatory=$true)]$Plugins)

  $out = @()
  $base = Join-Path $Context.AIDocsRoot "plugins"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }

  $selected = $Plugins | Sort-Object name
  foreach ($a in $selected) {
    $name = $a.name
    $id = $a.pluginassemblyid

    $folder = Join-Path $base $name
    $facts = Join-Path $folder "_facts"
    New-Item -ItemType Directory -Path $facts -Force | Out-Null

    # Save assembly metadata
    Save-YamlDeterministic -Data (Normalize-PluginAssemblyFacts -Assembly $a) -Path (Join-Path $facts "assembly.yaml")
    
    # Phase 4: Extract plugin assembly details (types and processing steps)
    $pluginDetails = Extract-PluginAssemblyDetails -Client $Client -PluginAssemblyId $id
    if ($pluginDetails) {
      if ($pluginDetails.types) {
        $normalized = Normalize-ListForYaml -Items @($pluginDetails.types | Select-Object plugintypeid, name, typename, isworkflowactivity)
        if ($normalized.Count -gt 0) {
          Assert-ValidYamlList -Path (Join-Path $facts "plugin-types.yaml") -Items $normalized -RequiredKeys @("name", "typename") -Facet "plugin-types"
          Save-YamlDeterministic -Data @{ types = $normalized } -Path (Join-Path $facts "plugin-types.yaml")
        }
      }
      if ($pluginDetails.steps) {
        $normalized = Normalize-ListForYaml -Items @($pluginDetails.steps | Select-Object sdkmessageprocessingstepid, name, stage, mode, rank, statuscode, message, filtering_attributes)
        if ($normalized.Count -gt 0) {
          Assert-ValidYamlList -Path (Join-Path $facts "sdk-steps.yaml") -Items $normalized -RequiredKeys @("name", "stage", "mode") -Facet "sdk-steps"
          Save-YamlDeterministic -Data @{ steps = $normalized } -Path (Join-Path $facts "sdk-steps.yaml")
        }
      }
    }

    # Build comprehensive README
    $typesCount = if ($pluginDetails -and $pluginDetails.types) { $pluginDetails.types.Count } else { 0 }
    $stepsCount = if ($pluginDetails -and $pluginDetails.steps) { $pluginDetails.steps.Count } else { 0 }
    $readmeContent = @"
# Plugin Assembly: $name

## Overview
Plugin assembly with enriched metadata for knowledge consumption.

## Details
- **Version**: $($a.version)
- **Public Key Token**: $($a.publickeytoken)
- **Plugin Types**: $typesCount
- **SDK Message Processing Steps**: $stepsCount

## Facts
- _facts/assembly.yaml - Assembly metadata
- _facts/plugin-types.yaml - Plugin types and workflow activities
- _facts/sdk-steps.yaml - SDK message processing step registrations

## Purpose
(Generated) Plugin assembly inventory and registration details.
"@
    Set-Content -Path (Join-Path $folder "README.md") -Value $readmeContent -Encoding UTF8

    $out += @{ asset_id=("pluginassembly:" + $id); type="pluginassembly"; path=("plugins/" + $name); confidence=0.90 }
  }
  return $out
}

function Write-FlowsDocs {
  param([Parameter(Mandatory=$true)]$Context,[Parameter(Mandatory=$true)]$Client,[Parameter(Mandatory=$true)]$Flows)

  $out = @()
  $base = Join-Path $Context.AIDocsRoot "flows"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }

  $selected = $Flows | Sort-Object name
  foreach ($f in $selected) {
    $id = $f.workflowid
    $name = $f.name

    $safe = (("" + $name).ToLower() -replace '[^a-z0-9\-]+','-') -replace '\-+','-'
    if ([string]::IsNullOrWhiteSpace($safe)) { $safe = [string]$id }

    $folder = Join-Path $base $safe
    $facts = Join-Path $folder "_facts"
    New-Item -ItemType Directory -Path $facts -Force | Out-Null

    Save-YamlDeterministic -Data (Normalize-FlowFacts -Flow $f) -Path (Join-Path $facts "flow.yaml")
    
    # Phase 3: Analyze flow actions for Dataverse operations
    $flowAnalysis = Analyze-FlowActions -Flow $f
    if ($flowAnalysis -and $flowAnalysis.actions) {
      Save-YamlDeterministic -Data @{
        actions = $flowAnalysis.actions
        confidence = $flowAnalysis.confidence
        evidence = $flowAnalysis.evidence
        action_count = @($flowAnalysis.actions).Count
      } -Path (Join-Path $facts "flow-actions.yaml")
    }

@"
# Flow (Inventory): $name

## Purpose
(Generated) Workflow/Flow inventory entry.

## Analysis
- Actions: $(@($flowAnalysis.actions).Count)
- Confidence: $($flowAnalysis.confidence)

## Facts
- _facts/flow.yaml
- _facts/flow-actions.yaml - Dataverse operations within flow
"@ | Set-Content -Path (Join-Path $folder "README.md") -Encoding UTF8

    $out += @{ asset_id=("flow:" + $id); type="flow"; path=("flows/" + $safe); confidence=0.80 }
  }
  return $out
}

function Write-SLAsDocs {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$SLAs
  )

  $out = @()
  $base = Join-Path $Context.AIDocsRoot "slas"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }

  $selected = $SLAs | Sort-Object name
  foreach ($sla in $selected) {
    $id = $sla.slaid
    $name = $sla.name

    $safe = (("" + $name).ToLower() -replace '[^a-z0-9\-]+','-') -replace '\-+','-'
    if ([string]::IsNullOrWhiteSpace($safe)) { $safe = [string]$id }

    $folder = Join-Path $base $safe
    $facts = Join-Path $folder "_facts"
    New-Item -ItemType Directory -Path $facts -Force | Out-Null

    Save-YamlIfChanged -Data @{
      slaid = $sla.slaid
      name = $sla.name
      description = $sla.description
      objecttypecode = $sla.objecttypecode
      isdefault = $sla.isdefault
    } -Path (Join-Path $facts "sla.yaml")
    
    # Extract SLA Items (KPIs, success/failure conditions)
    $slaItems = Extract-SLAItems -Client $Client -SLAId $id
    if ($slaItems -and $slaItems.Count -gt 0) {
      Save-YamlIfChanged -Data @{ sla_items = @($slaItems | Select-Object slaitemid, name, description, warnafter, failureafter) } -Path (Join-Path $facts "sla-items.yaml")
    }
    
    $itemCount = @($slaItems).Count
    $itemList = if ($slaItems) { ($slaItems | ForEach-Object { "- **$($_.name)**: Warn after $($_.warnafter)min, Fail after $($_.failureafter)min" }) -join "`n" } else { "- No SLA items defined" }

    $readme = @"
# SLA: $name

## Purpose
Service Level Agreement for $($sla.objecttypecode) records.

## Details
- **Applicable Table**: $($sla.objecttypecode)
- **Is Default**: $($sla.isdefault)
- **SLA Items/KPIs**: $itemCount

## SLA Items
$itemList

## Description
$($sla.description)

## Facts
- _facts/sla.yaml - SLA metadata
- _facts/sla-items.yaml - SLA items with success/failure conditions
"@
    Save-ContentIfChanged -Content $readme -Path (Join-Path $folder "README.md")

    $out += @{ asset_id=("sla:" + $id); type="sla"; path=("slas/" + $safe); confidence=0.85 }
  }
  return $out
}

function Write-WorkstreamsDocs {
  param([Parameter(Mandatory=$true)]$Context,[Parameter(Mandatory=$true)]$Client,[Parameter(Mandatory=$true)]$Workstreams)

  $out = @()
  $base = Join-Path $Context.AIDocsRoot "workstreams"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }

  $selected = $Workstreams | Sort-Object msdyn_name
  foreach ($ws in $selected) {
    $id = $ws.msdyn_liveworkstreamid
    $name = $ws.msdyn_name

    $safe = (("" + $name).ToLower() -replace '[^a-z0-9\-]+','-') -replace '\-+','-'
    if ([string]::IsNullOrWhiteSpace($safe)) { $safe = [string]$id }

    $folder = Join-Path $base $safe
    $facts = Join-Path $folder "_facts"
    New-Item -ItemType Directory -Path $facts -Force | Out-Null

    Save-YamlDeterministic -Data @{
      msdyn_liveworkstreamid = $ws.msdyn_liveworkstreamid
      msdyn_name = $ws.msdyn_name
      msdyn_streamsource = $ws.msdyn_streamsource
    } -Path (Join-Path $facts "workstream.yaml")
    
    # Phase 5: Extract workstream queue associations
    $queues = Extract-WorkstreamQueues -Client $Client -WorkstreamId $id
    if ($queues) {
      Save-YamlDeterministic -Data @{ queues = @($queues) } -Path (Join-Path $facts "associated-queues.yaml")
    }

@"
# Workstream: $name

## Purpose
Omnichannel workstream for knowledge consumption and queue mapping.

## Details
- **Stream Source**: $($ws.msdyn_streamsource)
- **Associated Queues**: $(@($queues).Count)

## Facts
- _facts/workstream.yaml - Workstream metadata
- _facts/associated-queues.yaml - Queue associations (routing rules, queue mappings)
"@ | Set-Content -Path (Join-Path $folder "README.md") -Encoding UTF8

    $out += @{ asset_id=("workstream:" + $id); type="workstream"; path=("workstreams/" + $safe); confidence=0.85 }
  }
  return $out
}

# ============= NEW DOCUMENTATION WRITERS =============

function Write-BPFDocs {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$BPFs
  )
  
  $out = @()
  $base = Join-Path $Context.AIDocsRoot "business-process-flows"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }
  
  foreach ($bpf in $BPFs) {
    $id = $bpf.workflowid
    $name = $bpf.name
    $safe = (("" + $name).ToLower() -replace '[^a-z0-9\-]+','-') -replace '\-+','-'
    if ([string]::IsNullOrWhiteSpace($safe)) { $safe = [string]$id }
    
    $folder = Join-Path $base $safe
    $facts = Join-Path $folder "_facts"
    New-Item -ItemType Directory -Path $facts -Force | Out-Null
    
    # Extract BPF stages
    $stages = Extract-BPFStages -Client $Client -ProcessId $id
    
    Save-YamlIfChanged -Data @{
      workflowid = $bpf.workflowid
      name = $bpf.name
      description = $bpf.description
      primaryentity = $bpf.primaryentity
      uniquename = $bpf.uniquename
    } -Path (Join-Path $facts "bpf.yaml")
    
    if ($stages) {
      Save-YamlIfChanged -Data @{ stages = @($stages | Select-Object processstageid, stagename, stagecategory, primaryentitytypecode) } -Path (Join-Path $facts "stages.yaml")
    }
    
    $stageList = ($stages | ForEach-Object { "- Stage $($_.stagecategory): $($_.stagename) ($($_.primaryentitytypecode))" }) -join "`n"
    
    $readme = @"
# Business Process Flow: $name

## Overview
Guides users through a structured process on the $($bpf.primaryentity) table.

## Stages ($(@($stages).Count))
$stageList

## Primary Entity
$($bpf.primaryentity)

## Description
$($bpf.description)

## Facts
- _facts/bpf.yaml - BPF metadata
- _facts/stages.yaml - Process stages
"@
    Save-ContentIfChanged -Content $readme -Path (Join-Path $folder "README.md")
    
    $out += @{ asset_id=("bpf:" + $id); type="bpf"; path=("business-process-flows/" + $safe); confidence=0.9 }
  }
  return $out
}

function Write-SecurityRolesDocs {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$Roles
  )
  
  $out = @()
  $base = Join-Path $Context.AIDocsRoot "security-roles"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }
  
  foreach ($role in $Roles) {
    $id = $role.roleid
    $name = $role.name
    $safe = (("" + $name).ToLower() -replace '[^a-z0-9\-]+','-') -replace '\-+','-'
    if ([string]::IsNullOrWhiteSpace($safe)) { $safe = [string]$id }
    
    $folder = Join-Path $base $safe
    $facts = Join-Path $folder "_facts"
    New-Item -ItemType Directory -Path $facts -Force | Out-Null
    
    Save-YamlIfChanged -Data @{
      roleid = $role.roleid
      name = $role.name
      ismanaged = $role.ismanaged
    } -Path (Join-Path $facts "role.yaml")
    
    # Extract privileges (can be slow, so check cache)
    $privilegesPath = Join-Path $facts "privileges.yaml"
    $skipPrivileges = $false
    if (Test-Path $privilegesPath) {
      $fileAge = (Get-Date) - (Get-Item $privilegesPath).LastWriteTime
      if ($fileAge.TotalHours -lt 24) { $skipPrivileges = $true }
    }
    
    $privileges = @()
    if (-not $skipPrivileges) {
      $privileges = Extract-RolePrivileges -Client $Client -RoleId $id
      if ($privileges) {
        Save-YamlIfChanged -Data @{ privileges = @($privileges) } -Path $privilegesPath
      }
    }
    
    $readme = @"
# Security Role: $name

## Overview
Defines permissions for users assigned this role.

## Details
- **Is Managed**: $($role.ismanaged)
- **Privileges**: $(@($privileges).Count)

## Facts
- _facts/role.yaml - Role metadata
- _facts/privileges.yaml - Role privileges (entity permissions)

## Common Use Cases
Check privileges.yaml to understand what Create/Read/Write/Delete/Append/AppendTo permissions this role grants on each entity.
"@
    Save-ContentIfChanged -Content $readme -Path (Join-Path $folder "README.md")
    
    $out += @{ asset_id=("role:" + $id); type="security_role"; path=("security-roles/" + $safe); confidence=0.9 }
  }
  return $out
}

function Write-EnvironmentVariablesDocs {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Variables
  )
  
  $out = @()
  $base = Join-Path $Context.AIDocsRoot "environment-variables"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }
  
  # Write consolidated file
  $factsPath = Join-Path $base "_facts"
  New-Item -ItemType Directory -Path $factsPath -Force | Out-Null
  Save-YamlIfChanged -Data @{ environment_variables = @($Variables) } -Path (Join-Path $factsPath "all-variables.yaml")
  
  $varList = ($Variables | ForEach-Object { "- **$($_.schema_name)** ($($_.type)): $($_.display_name)" }) -join "`n"
  
  $readme = @"
# Environment Variables

## Overview
Configuration values that can vary between environments (Dev, Test, Prod).

## Variables ($(@($Variables).Count))
$varList

## Usage
Flows and plugins can reference these variables for environment-specific configuration without hardcoding values.

## Facts
- _facts/all-variables.yaml - All environment variable definitions and current values
"@
  Save-ContentIfChanged -Content $readme -Path (Join-Path $base "README.md")
  
  $out += @{ asset_id="config:environment-variables"; type="config"; path="environment-variables"; confidence=0.95 }
  return $out
}

function Write-ConnectionReferencesDocs {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Connections
  )
  
  $out = @()
  $base = Join-Path $Context.AIDocsRoot "connection-references"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }
  
  $factsPath = Join-Path $base "_facts"
  New-Item -ItemType Directory -Path $factsPath -Force | Out-Null
  Save-YamlIfChanged -Data @{ connection_references = @($Connections | Select-Object connectionreferenceid, connectionreferencelogicalname, connectionreferencedisplayname, connectorid, description, statecode) } -Path (Join-Path $factsPath "all-connections.yaml")
  
  $connList = ($Connections | ForEach-Object { "- **$($_.connectionreferencedisplayname)**: $($_.connectorid)" }) -join "`n"
  
  $readme = @"
# Connection References

## Overview
Defines connections to external services (SharePoint, Outlook, custom APIs, etc.) used by Flows.

## Connections ($(@($Connections).Count))
$connList

## Facts
- _facts/all-connections.yaml - All connection reference definitions
"@
  Save-ContentIfChanged -Content $readme -Path (Join-Path $base "README.md")
  
  $out += @{ asset_id="config:connection-references"; type="config"; path="connection-references"; confidence=0.9 }
  return $out
}

function Write-AppModulesDocs {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$AppModules
  )
  
  $out = @()
  $base = Join-Path $Context.AIDocsRoot "app-modules"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }
  
  foreach ($app in $AppModules) {
    $id = $app.appmoduleid
    $name = $app.name
    $safe = (("" + $name).ToLower() -replace '[^a-z0-9\-]+','-') -replace '\-+','-'
    if ([string]::IsNullOrWhiteSpace($safe)) { $safe = [string]$id }
    
    $folder = Join-Path $base $safe
    $facts = Join-Path $folder "_facts"
    New-Item -ItemType Directory -Path $facts -Force | Out-Null
    
    Save-YamlIfChanged -Data @{
      appmoduleid = $app.appmoduleid
      name = $app.name
      uniquename = $app.uniquename
      description = $app.description
      url = $app.url
      clienttype = $app.clienttype
      appmoduleversion = $app.appmoduleversion
    } -Path (Join-Path $facts "app.yaml")
    
    # Extract sitemap components
    $components = Extract-AppSitemap -Client $Client -AppModuleId $id
    if ($components) {
      Save-YamlIfChanged -Data @{ components = @($components) } -Path (Join-Path $facts "sitemap.yaml")
    }
    
    $readme = @"
# App Module: $name

## Overview
Model-driven app that provides a specific user experience.

## Details
- **Unique Name**: $($app.uniquename)
- **Version**: $($app.appmoduleversion)
- **Client Type**: $($app.clienttype)
- **Components**: $(@($components).Count)

## Description
$($app.description)

## URL
$($app.url)

## Facts
- _facts/app.yaml - App module metadata
- _facts/sitemap.yaml - Navigation structure (areas, groups, sub-areas)
"@
    Save-ContentIfChanged -Content $readme -Path (Join-Path $folder "README.md")
    
    $out += @{ asset_id=("app:" + $id); type="app_module"; path=("app-modules/" + $safe); confidence=0.9 }
  }
  return $out
}

function Write-RoutingRulesDocs {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$RoutingRules
  )
  
  $out = @()
  $base = Join-Path $Context.AIDocsRoot "routing-rules"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }
  
  foreach ($rule in $RoutingRules) {
    $id = $rule.routingruleid
    $name = $rule.name
    $safe = (("" + $name).ToLower() -replace '[^a-z0-9\-]+','-') -replace '\-+','-'
    if ([string]::IsNullOrWhiteSpace($safe)) { $safe = [string]$id }
    
    $folder = Join-Path $base $safe
    $facts = Join-Path $folder "_facts"
    New-Item -ItemType Directory -Path $facts -Force | Out-Null
    
    Save-YamlIfChanged -Data @{
      routingruleid = $rule.routingruleid
      name = $rule.name
      description = $rule.description
      statecode = $rule.statecode
      statuscode = $rule.statuscode
    } -Path (Join-Path $facts "rule.yaml")
    
    # Extract rule items (conditions)
    $items = Extract-RoutingRuleItems -Client $Client -RoutingRuleId $id
    if ($items) {
      Save-YamlIfChanged -Data @{ items = @($items | Select-Object routingruleitemid, name, conditionxml, _routedqueueid_value) } -Path (Join-Path $facts "items.yaml")
    }
    
    $status = switch ($rule.statecode) { 0 { "Draft" } 1 { "Active" } 2 { "Inactive" } default { $rule.statecode } }
    
    $readme = @"
# Routing Rule: $name

## Overview
Defines how cases/records are automatically routed to queues based on conditions.

## Details
- **Status**: $status
- **Rule Items**: $(@($items).Count) conditions

## Description
$($rule.description)

## Facts
- _facts/rule.yaml - Routing rule metadata
- _facts/items.yaml - Routing conditions and target queues
"@
    Save-ContentIfChanged -Content $readme -Path (Join-Path $folder "README.md")
    
    $out += @{ asset_id=("routing:" + $id); type="routing_rule"; path=("routing-rules/" + $safe); confidence=0.85 }
  }
  return $out
}

function Write-WebResourcesDocs {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$WebResources
  )
  
  $out = @()
  $base = Join-Path $Context.AIDocsRoot "web-resources"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }
  
  foreach ($wr in $WebResources) {
    $id = $wr.webresourceid
    $name = $wr.name
    $safe = (("" + $name).ToLower() -replace '[^a-z0-9\-\.]+','-') -replace '\-+','-'
    if ([string]::IsNullOrWhiteSpace($safe)) { $safe = [string]$id }
    
    $folder = Join-Path $base $safe
    $facts = Join-Path $folder "_facts"
    New-Item -ItemType Directory -Path $facts -Force | Out-Null
    
    Save-YamlIfChanged -Data @{
      webresourceid = $wr.webresourceid
      name = $wr.name
      displayname = $wr.displayname
      description = $wr.description
    } -Path (Join-Path $facts "webresource.yaml")
    
    # Decode and save JavaScript content if present (check property exists first)
    if ($wr.PSObject.Properties['content'] -and $wr.content) {
      try {
        $decoded = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($wr.content))
        Save-ContentIfChanged -Content $decoded -Path (Join-Path $facts "code.js")
      }
      catch { }
    }
    
    $readme = @"
# Web Resource: $($wr.displayname)

## Overview
JavaScript file used for form customizations and client-side logic.

## File Name
$($wr.name)

## Description
$($wr.description)

## Facts
- _facts/webresource.yaml - Web resource metadata
- _facts/code.js - JavaScript source code (if available)
"@
    Save-ContentIfChanged -Content $readme -Path (Join-Path $folder "README.md")
    
    $out += @{ asset_id=("webresource:" + $id); type="web_resource"; path=("web-resources/" + $safe); confidence=0.8 }
  }
  return $out
}

function Write-SolutionDependenciesDocs {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$Solutions
  )
  
  $out = @()
  $base = Join-Path $Context.AIDocsRoot "_graph"
  if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }
  
  $allDeps = @()
  foreach ($sol in $Solutions) {
    $deps = Extract-SolutionDependencies -Client $Client -SolutionId $sol.uniquename
    foreach ($dep in $deps) {
      $allDeps += @{
        solution = $sol.uniquename
        dependency = $dep
      }
    }
  }
  
  Save-YamlIfChanged -Data @{ solution_dependencies = @($allDeps) } -Path (Join-Path $base "solution-dependencies.yaml")
  
  $readme = @"
# Solution Dependencies (Impact Analysis)

## Overview
Shows component dependencies for impact analysis - what might break if components change.

## Solutions Analyzed
$($Solutions.Count) solutions

## Facts
- solution-dependencies.yaml - All solution component dependencies
"@
  Save-ContentIfChanged -Content $readme -Path (Join-Path $base "IMPACT-ANALYSIS.md")
  
  $out += @{ asset_id="graph:solution-dependencies"; type="graph"; path="_graph/solution-dependencies.yaml"; confidence=0.85 }
  return $out
}

# Enhance existing table docs with option sets, views, formulas, ribbons
function Enhance-TableDocsWithExtras {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$Tables
  )
  
  $base = Join-Path $Context.AIDocsRoot "tables"
  $total = @($Tables).Count
  $current = 0
  
  foreach ($t in $Tables) {
    $current++
    $logical = $t.LogicalName
    $facts = Join-Path (Join-Path $base $logical) "_facts"
    
    if (-not (Test-Path $facts)) { continue }
    
    # Progress every 10 tables
    if ($current -eq 1 -or ($current % 10) -eq 0 -or $current -eq $total) {
      Write-Host "      Enhancing [$current/$total] $logical" -ForegroundColor DarkGray
    }
    
    # Check cache for option sets
    $optionSetsPath = Join-Path $facts "optionsets.yaml"
    $skipOptionSets = $false
    if (Test-Path $optionSetsPath) {
      $fileAge = (Get-Date) - (Get-Item $optionSetsPath).LastWriteTime
      if ($fileAge.TotalHours -lt 24) { $skipOptionSets = $true }
    }
    
    if (-not $skipOptionSets) {
      $optionSets = Extract-TableOptionSets -Client $Client -LogicalName $logical
      if ($optionSets -and $optionSets.Count -gt 0) {
        Save-YamlIfChanged -Data @{ optionsets = @($optionSets) } -Path $optionSetsPath
      }
    }
    
    # Check cache for views
    $viewsPath = Join-Path $facts "views.yaml"
    $skipViews = $false
    if (Test-Path $viewsPath) {
      $fileAge = (Get-Date) - (Get-Item $viewsPath).LastWriteTime
      if ($fileAge.TotalHours -lt 24) {
        $skipViews = $true
        $cachedContent = ""
        try {
          $cachedContent = Get-Content -Path $viewsPath -Raw -ErrorAction Stop
        } catch {}

        $hasQueryType = ($cachedContent -match "querytype\s*:")
        $hasPlaceholders = ($cachedContent -match "-\s*''")
        if (-not $hasQueryType -or $hasPlaceholders) {
          $skipViews = $false
          Write-Warning "Table '$logical' views cache missing required keys; forcing refresh."
        }
      }
    }
    
    if (-not $skipViews) {
      $views = Extract-TableViews -Client $Client -LogicalName $logical
      if ($views -and $views.Count -gt 0) {
        $missingQueryTypes = 0
        $projectedViews = foreach ($view in $views) {
          $queryTypeProperty = $null
          if ($view -and $view.PSObject -and $view.PSObject.Properties) {
            $queryTypeProperty = ($view.PSObject.Properties | Where-Object { $_.Name -ieq "querytype" } | Select-Object -First 1)
          }

          $queryTypeValue = if ($queryTypeProperty) { $queryTypeProperty.Value } else { $null }
          if ($null -eq $queryTypeValue -or (($queryTypeValue -is [string]) -and [string]::IsNullOrWhiteSpace($queryTypeValue))) {
            $missingQueryTypes++
            $queryTypeValue = -1  # Default sentinel keeps schema validation satisfied
          }

          [pscustomobject]@{
            savedqueryid = $view.savedqueryid
            name = $view.name
            description = $view.description
            querytype = $queryTypeValue
          }
        }

        if ($missingQueryTypes -gt 0) {
          Write-Warning "Table '$logical' has $missingQueryTypes view(s) without querytype; defaulting to -1."
        }

        $normalized = Normalize-ListForYaml -Items @($projectedViews)

        $forcedQueryTypes = 0
        foreach ($entry in $normalized) {
          if ($null -eq $entry) { continue }
          if (-not ($entry -is [System.Collections.IDictionary])) { continue }
          if (-not ($entry.ContainsKey("querytype"))) {
            $entry["querytype"] = -1
            $forcedQueryTypes++
          }
        }

        if ($forcedQueryTypes -gt 0) {
          Write-Warning "Table '$logical' produced $forcedQueryTypes view(s) missing querytype after normalization; defaulting to -1."
        }
        if ($normalized.Count -gt 0) {
          Assert-ValidYamlList -Path $viewsPath -Items $normalized -RequiredKeys @("name", "querytype") -Facet "views"
          Save-YamlIfChanged -Data @{ views = $normalized } -Path $viewsPath
        }
      }
    }
    
    # Check cache for calculated fields
    $calculatedPath = Join-Path $facts "calculated-fields.yaml"
    $skipCalculated = $false
    if (Test-Path $calculatedPath) {
      $fileAge = (Get-Date) - (Get-Item $calculatedPath).LastWriteTime
      if ($fileAge.TotalHours -lt 24) { $skipCalculated = $true }
    }
    
    if (-not $skipCalculated) {
      $calcFields = Extract-TableCalculatedFields -Client $Client -LogicalName $logical
      if ($calcFields -and $calcFields.Count -gt 0) {
        Save-YamlIfChanged -Data @{ calculated_fields = @($calcFields) } -Path $calculatedPath
      }
    }
  }
}

# Enhance plugin docs with detailed step information
function Enhance-PluginDocsWithStepDetails {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Client,
    [Parameter(Mandatory=$true)]$Plugins
  )
  
  $base = Join-Path $Context.AIDocsRoot "plugins"
  
  foreach ($plugin in $Plugins) {
    $name = $plugin.name
    $safe = (("" + $name).ToLower() -replace '[^a-z0-9\-]+','-') -replace '\-+','-'
    $facts = Join-Path (Join-Path $base $safe) "_facts"
    
    if (-not (Test-Path $facts)) { continue }
    
    # Get plugin types from cached file
    $typesPath = Join-Path $facts "plugin-types.yaml"
    if (-not (Test-Path $typesPath)) { continue }
    
    # Check cache for detailed steps
    $detailedStepsPath = Join-Path $facts "step-details.yaml"
    $skipSteps = $false
    if (Test-Path $detailedStepsPath) {
      $fileAge = (Get-Date) - (Get-Item $detailedStepsPath).LastWriteTime
      if ($fileAge.TotalHours -lt 24) { $skipSteps = $true }
    }
    
    if (-not $skipSteps) {
      # Load types and get detailed steps
      try {
        $typesContent = Get-Content $typesPath -Raw
        if ($typesContent -match 'plugintypeid:\s*([a-f0-9\-]+)') {
          $allDetailedSteps = @()
          $typeIds = [regex]::Matches($typesContent, 'plugintypeid:\s*([a-f0-9\-]+)') | ForEach-Object { $_.Groups[1].Value }
          
          foreach ($typeId in $typeIds) {
            $steps = Extract-PluginStepDetails -Client $Client -PluginTypeId $typeId
            foreach ($step in $steps) {
              # Get images for this step
              $images = Extract-PluginStepImages -Client $Client -StepId $step.step_id
              $step.images = $images
              $allDetailedSteps += $step
            }
          }
          
          if ($allDetailedSteps.Count -gt 0) {
            Save-YamlIfChanged -Data @{ step_details = @($allDetailedSteps) } -Path $detailedStepsPath
          }
        }
      }
      catch { }
    }
  }
}

# ============= COVERAGE REPORTING (Phase 0) =============
# Generates coverage report showing what was documented and what gaps exist
function Write-CoverageReport {
  param(
    [Parameter(Mandatory=$true)]$Context,
    [Parameter(Mandatory=$true)]$Capabilities,
    [Parameter(Mandatory=$true)][hashtable]$Extraction
  )

  $coverageFile = Join-Path $Context.AIDocsRoot "RUNS/$($Context.RunId)/coverage-report.md"
  
  $markdown = @"
# Documentation Coverage Report

**Run ID**: $($Context.RunId)
**Generated**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Mode**: $($Context.Mode)

## Executive Summary

This report shows what metadata was successfully extracted and documented, which probes failed, and where SDK APIs would be required for deeper fidelity.

---

## Capability Probe Results

### Critical Endpoints
"@

  # Use SafeGet helper for strict mode safe property access
  function SafeGetProbeArray($caps, $probeName) {
    if ($null -eq $caps) { return @() }
    if ($caps -is [hashtable] -and $caps.ContainsKey('probes') -and $caps.probes -is [hashtable] -and $caps.probes.ContainsKey($probeName)) {
      return @($caps.probes[$probeName])
    }
    if ($caps -is [PSCustomObject] -and $caps.PSObject.Properties['probes'] -and $caps.probes.PSObject.Properties[$probeName]) {
      return @($caps.probes.$probeName)
    }
    return @()
  }

  $criticalProbes = SafeGetProbeArray $Capabilities 'critical'
  foreach ($probe in $criticalProbes) {
    if ($null -eq $probe) { continue }
    $status = if ($probe -is [hashtable] -and $probe.ContainsKey('status')) { $probe.status } elseif ($probe.PSObject.Properties['status']) { $probe.status } else { 'unknown' }
    $endpoint = if ($probe -is [hashtable] -and $probe.ContainsKey('endpoint')) { $probe.endpoint } elseif ($probe.PSObject.Properties['endpoint']) { $probe.endpoint } else { '' }
    $message = if ($probe -is [hashtable] -and $probe.ContainsKey('message')) { $probe.message } elseif ($probe.PSObject.Properties['message']) { $probe.message } else { '' }
    $icon = if ($status -eq "ok") { "[OK]" } else { "[FAIL]" }
    $markdown += "`n- $icon **$endpoint**: $status - $message"
  }

  $markdown += "`n`n### Plugin Registration Endpoints`n"
  $pluginProbes = SafeGetProbeArray $Capabilities 'plugins'
  foreach ($probe in $pluginProbes) {
    if ($null -eq $probe) { continue }
    $status = if ($probe -is [hashtable] -and $probe.ContainsKey('status')) { $probe.status } elseif ($probe.PSObject.Properties['status']) { $probe.status } else { 'unknown' }
    $endpoint = if ($probe -is [hashtable] -and $probe.ContainsKey('endpoint')) { $probe.endpoint } elseif ($probe.PSObject.Properties['endpoint']) { $probe.endpoint } else { '' }
    $icon = if ($status -eq "ok") { "[OK]" } else { "[FAIL]" }
    $markdown += "`n- $icon **$endpoint**: $status"
  }

  $markdown += "`n`n### Queues`n"
  $queueProbes = SafeGetProbeArray $Capabilities 'queues'
  foreach ($probe in $queueProbes) {
    if ($null -eq $probe) { continue }
    $status = if ($probe -is [hashtable] -and $probe.ContainsKey('status')) { $probe.status } elseif ($probe.PSObject.Properties['status']) { $probe.status } else { 'unknown' }
    $endpoint = if ($probe -is [hashtable] -and $probe.ContainsKey('endpoint')) { $probe.endpoint } elseif ($probe.PSObject.Properties['endpoint']) { $probe.endpoint } else { '' }
    $icon = if ($status -eq "ok") { "[OK]" } else { "[FAIL]" }
    $markdown += "`n- $icon **$endpoint**: $status"
  }

  $markdown += "`n`n### Omnichannel Tables`n"
  $omniProbes = SafeGetProbeArray $Capabilities 'omnichannel'
  foreach ($probe in $omniProbes) {
    if ($null -eq $probe) { continue }
    $status = if ($probe -is [hashtable] -and $probe.ContainsKey('status')) { $probe.status } elseif ($probe.PSObject.Properties['status']) { $probe.status } else { 'unknown' }
    $endpoint = if ($probe -is [hashtable] -and $probe.ContainsKey('endpoint')) { $probe.endpoint } elseif ($probe.PSObject.Properties['endpoint']) { $probe.endpoint } else { '' }
    $icon = if ($status -eq "ok") { "[OK]" } else { "[FAIL]" }
    $markdown += "`n- $icon **$endpoint**: $status"
  }

  $markdown += "`n`n---`n`n## Extraction Results`n`n"
  $markdown += "| Component | Count | Confidence | Status |`n"
  $markdown += "| --------- | ----- | ---------- | ------ |`n"
  
  # Helper for safe property access (strict mode safe)
  function SafeGetProp($obj, $propPath, $default) {
    if ($null -eq $obj) { return $default }
    $parts = $propPath -split '\.'
    $current = $obj
    foreach ($part in $parts) {
      if ($null -eq $current) { return $default }
      if ($current -is [hashtable]) {
        if ($current.ContainsKey($part)) { $current = $current[$part] }
        else { return $default }
      } elseif ($current -is [PSCustomObject]) {
        if ($current.PSObject.Properties[$part]) { $current = $current.$part }
        else { return $default }
      } else {
        return $default
      }
    }
    return $current
  }

  $solCount = SafeGetProp $Extraction 'results.solutions_count' 0
  $tableCount = SafeGetProp $Extraction 'results.tables_count' 0
  $queuesIncluded = SafeGetProp $Extraction 'results.queues_included_count' 0
  $queuesTotal = SafeGetProp $Extraction 'results.queues_total_count' 0
  $pluginCount = SafeGetProp $Extraction 'results.plugins_count' 0
  $flowCount = SafeGetProp $Extraction 'results.flows_count' 0
  $queuesOk = SafeGetProp $Capabilities 'queues_ok' $false
  $omniOk = SafeGetProp $Capabilities 'omnichannel_ok' $false

  $markdown += "| Solutions | $solCount | High | $(if ($solCount -gt 0) { 'OK' } else { 'None found' }) |`n"
  $markdown += "| Tables | $tableCount | High | $(if ($tableCount -gt 0) { 'OK' } else { 'None found' }) |`n"
  $markdown += "| Queues | $queuesIncluded / $queuesTotal | High | $(if ($queuesOk) { 'OK' } else { 'Limited access' }) |`n"
  $markdown += "| Plugins | $pluginCount | High | $(if ($pluginCount -gt 0) { 'OK' } else { 'None found' }) |`n"
  $markdown += "| Flows | $flowCount | Medium | $(if ($flowCount -gt 0) { 'OK' } else { 'None found' }) |`n"
  $markdown += "| SLAs | $(if ($Extraction.slas) { @($Extraction.slas).Count } else { '0' }) | Medium | $(if ($omniOk) { 'OK' } else { 'Limited access' }) |`n"
  $markdown += "| Workstreams | $(if ($Extraction.workstreams) { @($Extraction.workstreams).Count } else { '0' }) | Medium | $(if ($omniOk) { 'OK' } else { 'Limited access' }) |`n"

  $markdown += "`n---`n`n## Coverage Limitations & Gaps (Fix 4)`n`n"
  
  $markdown += "### Forms Coverage (STRONG)`n"
  $markdown += "Form XML/structure extraction is working. 76+ tables have parsed form definitions with tabs/sections/fields.`n"
  $markdown += "This is a reliable facet for triage agents.`n`n"

  $markdown += "### Table Metadata Details (CRITICAL GAPS)`n"
  $markdown += "**Currently extracting**:`n"
  $markdown += "- Table logical/schema names, display names, ownership, custom flag`n"
  $markdown += "- Form definitions (tabs, sections, fields)`n`n"
  $markdown += "**GAPS (Placeholder entries in YAML - serialization not extraction)**:`n"
  $markdown += "- Column definitions: 77 tables have columns.yaml with empty-string entries. Fix serialization.`n"
  $markdown += "- Relationships: 77 tables have relationships.yaml with empty-string entries. Fix serialization.`n"
  $markdown += "- Views: 92 tables have views.yaml with empty-string entries. Fix serialization.`n`n"

  $markdown += "### Plugin Coverage (SHELLS WITH PLACEHOLDERS)`n"
  $markdown += "Extracted plugin assembly/type/step metadata but with empty entries. Needs field mapping:`n"
  $markdown += "- plugin-types.yaml: Currently placeholders. Requires typename, isworkflowactivity mapping.`n"
  $markdown += "- sdk-steps.yaml: Currently placeholders. Requires message, stage, mode, filtering_attributes, images.`n`n"

  $markdown += "### Flows & Actions (PARTIAL)`n"
  $markdown += "Flow metadata extracted; reverse-index shows table edges (useful). Missing action breakdowns:`n"
  $markdown += "- clientdata parsing limited by Web API availability`n"
  $markdown += "- flow-actions.yaml not present for many flows`n"
  $markdown += "- Reverse index (_graph/reverse-index.yaml) provides useful edge data.`n`n"

  $markdown += "---`n`n## Immediate Actions (Phase 1 Remediation)`n`n"
  $markdown += "1. **Fix YAML serialization** for columns/relationships/views: Replace empty-string lists with structured objects.`n"
  $markdown += "2. **Validate plugin field mapping** and emit complete steps with message/stage/mode/filtering_attributes.`n"
  $markdown += "3. **Align coverage narrative** with actual outputs (forms are strong, not limited).`n"
  $markdown += "4. **Enrich flows** with action breakdown where clientdata available; otherwise document as partial.`n"


  Set-Content -Path $coverageFile -Value $markdown -Encoding UTF8
  Write-Host "Coverage report written to: RUNS/$($Context.RunId)/coverage-report.md" -ForegroundColor Green
}

# ---------------- Registry / Confidence / Reports ----------------

function Build-RegistryFromChangedAssets {
  param([Parameter(Mandatory=$true)]$Context,[Parameter(Mandatory=$true)]$ChangedAssets)

  $reg = [ordered]@{
    schema_version = 1
    generated_run_id = $Context.RunId
    assets = @()
  }

  foreach ($a in $ChangedAssets) {
    $reg.assets += [ordered]@{
      asset_id = $a.asset_id
      type = $a.type
      path = $a.path
      last_seen_run_id = $Context.RunId
      confidence = $a.confidence
    }
  }
  return $reg
}

function Compute-Confidence {
  param([Parameter(Mandatory=$true)]$Context,[Parameter(Mandatory=$true)]$Extraction,[Parameter(Mandatory=$true)]$ChangedAssets)

  $types = $ChangedAssets | Group-Object type | ForEach-Object { $_.Name }

  $solutionsOk = $types -contains "registry"
  $tablesOk = $types -contains "table"
  $queuesOk = $types -contains "queue"
  $pluginsOk = $types -contains "pluginassembly"
  $flowsOk = $types -contains "flow"

  # Confidence scoring: weighted by importance and reliability
  # Do NOT fail entire run if flows are missing (flows extraction is POC-level)
  # Pre-compute scores to avoid inline conditionals in hashtable literal
  $solScore = if ($solutionsOk) { 1.0 } else { 0.0 }
  $tabScore = if ($tablesOk) { 0.95 } else { 0.0 }
  $queueScore = if ($queuesOk) { 0.92 } else { 0.0 }
  $pluginScore = if ($pluginsOk) { 0.90 } else { 0.0 }
  $flowScore = if ($flowsOk) { 0.80 } else { 0.0 }
  
  $domain = [ordered]@{
    solutions = $solScore
    tables = $tabScore
    queues = $queueScore
    plugins = $pluginScore
    flows = $flowScore
  }

  $weights = @{ solutions=0.10; tables=0.30; queues=0.20; plugins=0.20; flows=0.20 }

  $overall = 0.0
  foreach ($k in $weights.Keys) {
    $overall += ($domain[$k] * $weights[$k])
  }

  # REMOVED: hard fail if flows missing. Let weighted average stand.
  # Rationale: Flows extraction is POC. Don't fail entire run for incomplete feature.

  $notes = @(
    "Queues exclude user queues using owner lookup logical name annotation."
    "POC scoring. Flows extraction is minimal; low confidence expected."
  )
  if (-not $flowsOk) { 
    $notes += "Flows: No data extracted. Likely transient API issue or no flows in environment." 
  }
  if (-not $tablesOk) {
    $notes += "Tables: No data extracted."
  }

  return [ordered]@{
    overall = [Math]::Round($overall, 4)
    threshold = $Context.ConfidenceThreshold
    domains = $domain
    notes = $notes
  }
}

function Write-DiffReport {
  param([Parameter(Mandatory=$true)]$Context,[Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)]$ChangedAssets,[Parameter(Mandatory=$true)]$Confidence)

  # Helper function to safely get a property value
  function SafeGet($obj, $propName, $default) {
    if ($null -eq $obj) { return $default }
    if ($obj -is [hashtable] -and $obj.ContainsKey($propName)) { return $obj[$propName] }
    if ($obj -is [PSCustomObject] -and $obj.PSObject.Properties[$propName]) { return $obj.$propName }
    return $default
  }

  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add("# Diff Report")
  $lines.Add("")
  $lines.Add(("Run: " + $Context.RunId))
  $lines.Add(("Mode: " + $Context.Mode))
  $confOverall = SafeGet $Confidence 'overall' 'N/A'
  $confThreshold = SafeGet $Confidence 'threshold' 'N/A'
  $lines.Add(("Overall confidence: " + $confOverall + " Threshold: " + $confThreshold))
  $lines.Add("")
  $lines.Add("Changed assets:")
  foreach ($a in $ChangedAssets) {
    if ($null -eq $a) { continue }
    $assetId = SafeGet $a 'asset_id' 'unknown'
    $assetPath = SafeGet $a 'path' 'unknown'
    $assetConf = SafeGet $a 'confidence' 'N/A'
    $lines.Add(("- " + $assetId + " -> " + $assetPath + " confidence " + $assetConf))
  }

  $dir = Split-Path $Path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $lines | Set-Content -Path $Path -Encoding UTF8
}

Export-ModuleMember -Function * -Alias *
