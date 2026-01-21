Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Save-YamlDeterministic {
  param(
    [Parameter(Mandatory=$true)]$Data,
    [Parameter(Mandatory=$true)][string]$Path
  )

  $yaml = ConvertTo-DeterministicYaml -Data $Data
  $dir = Split-Path $Path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  Set-Content -Path $Path -Value $yaml -Encoding UTF8
}

# Save YAML only if content has changed (reduces unnecessary git diffs)
function Save-YamlIfChanged {
  param(
    [Parameter(Mandatory=$true)]$Data,
    [Parameter(Mandatory=$true)][string]$Path
  )

  $yaml = ConvertTo-DeterministicYaml -Data $Data
  $dir = Split-Path $Path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  
  # Compare with existing content
  if (Test-Path $Path) {
    $existing = Get-Content -Path $Path -Raw -ErrorAction SilentlyContinue
    if ($existing -eq $yaml) {
      return $false  # No change
    }
  }
  
  Set-Content -Path $Path -Value $yaml -Encoding UTF8
  return $true  # Changed
}

# Save text content only if changed
function Save-ContentIfChanged {
  param(
    [Parameter(Mandatory=$true)][string]$Content,
    [Parameter(Mandatory=$true)][string]$Path
  )

  $dir = Split-Path $Path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  
  # Normalize line endings for comparison
  $normalizedContent = $Content -replace "`r`n", "`n"
  
  if (Test-Path $Path) {
    $existing = (Get-Content -Path $Path -Raw -ErrorAction SilentlyContinue) -replace "`r`n", "`n"
    if ($existing -eq $normalizedContent) {
      return $false  # No change
    }
  }
  
  Set-Content -Path $Path -Value $Content -Encoding UTF8
  return $true  # Changed
}

function ConvertTo-DeterministicYaml {
  param([Parameter(Mandatory=$true)]$Data)

  # Minimal deterministic YAML emitter for our structures (ordered dictionaries + arrays + scalars).
  # Avoids dependency on external modules.
  $emitted = Emit-Yaml -Value $Data -Indent 0
  return ($emitted.TrimEnd() + "`n")
}

function Emit-Yaml {
  param(
    [Parameter(Mandatory=$true)][AllowNull()]$Value,
    [Parameter(Mandatory=$true)][int]$Indent
  )

  $pad = (' ' * $Indent)

  if ($null -eq $Value) {
    return ($pad + "null`n")
  }

  if ($Value -is [string]) {
    return ($pad + (Yaml-QuoteIfNeeded -Text $Value) + "`n")
  }

  if ($Value -is [bool]) {
    return ($pad + ($Value.ToString().ToLower()) + "`n")
  }

  if ($Value -is [int] -or $Value -is [long] -or $Value -is [double] -or $Value -is [decimal]) {
    return ($pad + $Value.ToString() + "`n")
  }

  if ($Value -is [System.Collections.IDictionary]) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($key in $Value.Keys) {
      $k = [string]$key
      $v = $Value[$key]

      $isComplex =
        ($v -is [System.Collections.IDictionary]) -or
        (($v -is [System.Collections.IEnumerable]) -and -not ($v -is [string]))

      if ($isComplex) {
        [void]$sb.AppendLine($pad + $k + ":")
        [void]$sb.Append($(Emit-Yaml -Value $v -Indent ($Indent + 2)))
      } else {
        $scalar = (Emit-Yaml -Value $v -Indent 0).Trim()
        [void]$sb.AppendLine($pad + $k + ": " + $scalar)
      }
    }
    return $sb.ToString()
  }

  if (($Value -is [System.Collections.IEnumerable]) -and -not ($Value -is [string])) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($item in $Value) {
      $isComplex =
        ($item -is [System.Collections.IDictionary]) -or
        (($item -is [System.Collections.IEnumerable]) -and -not ($item -is [string]))

      if ($isComplex) {
        [void]$sb.AppendLine($pad + "-")
        [void]$sb.Append($(Emit-Yaml -Value $item -Indent ($Indent + 2)))
      } else {
        $scalar = (Emit-Yaml -Value $item -Indent 0).Trim()
        [void]$sb.AppendLine($pad + "- " + $scalar)
      }
    }
    return $sb.ToString()
  }

  # Fallback to string
  return ($pad + (Yaml-QuoteIfNeeded -Text ($Value.ToString())) + "`n")
}

function Yaml-QuoteIfNeeded {
  param([Parameter(Mandatory=$true)][AllowEmptyString()][string]$Text)

  if ($Text -eq "") { return "''" }

  $needs = $false

  # Characters that commonly require quoting in YAML scalars
  if ($Text -match '[:\[\]\{\},&\*\#\?\|\-\<\>\=\!\%]') { $needs = $true }

  # Whitespace edges
  if ($Text.StartsWith(" ") -or $Text.EndsWith(" ")) { $needs = $true }

  # YAML keywords
  if ($Text -match '^(true|false|null|~)$') { $needs = $true }

  # Numeric-looking
  if ($Text -match '^\d') { $needs = $true }

  # Newlines / tabs / carriage returns
  if ($Text -match "[`r`n`t]") { $needs = $true }

  if (-not $needs) { return $Text }

  $escaped = $Text.Replace("`r","").Replace("`n","\n").Replace("'","''")
  return ("'" + $escaped + "'")
}

# ---------------- Normalizers (POC) ----------------

function Normalize-Solutions {
  param([Parameter(Mandatory=$true)]$Solutions)

  $items = $Solutions | Sort-Object uniquename | ForEach-Object {
    [ordered]@{
      solutionid    = $_.solutionid
      uniquename    = $_.uniquename
      friendlyname  = $_.friendlyname
      version       = $_.version
      ismanaged     = $_.ismanaged
    }
  }

  return [ordered]@{
    schema_version = 1
    solutions      = @($items)
  }
}

function Normalize-TableFacts {
  param([Parameter(Mandatory=$true)]$Table)

  return [ordered]@{
    schema_version    = 1
    logical_name      = $Table.LogicalName
    schema_name       = $Table.SchemaName
    ownership_type    = $Table.OwnershipType
    is_custom         = $Table.IsCustomEntity
    is_audit_enabled  = $Table.IsAuditEnabled
    is_activity       = $Table.IsActivity
    display_name      = $Table.DisplayName
  }
}

function Normalize-QueueFacts {
  param([Parameter(Mandatory=$true)]$Queue)

  $facts = [ordered]@{
    schema_version = 1
    queueid        = $Queue.queueid
    name           = $Queue.name
    description    = $Queue.description
    emailaddress   = $Queue.emailaddress
    ownerid        = $Queue._ownerid_value
  }
  
  # Add optional properties if they exist
  if ($Queue | Get-Member -Name "queuetype" -ErrorAction SilentlyContinue) {
    $facts.queuetype = $Queue.queuetype
  }
  if ($Queue | Get-Member -Name "msdyn_queuetype" -ErrorAction SilentlyContinue) {
    $facts.msdyn_queuetype = $Queue.msdyn_queuetype
  }
  if ($Queue | Get-Member -Name "msdyn_priority" -ErrorAction SilentlyContinue) {
    $facts.msdyn_priority = $Queue.msdyn_priority
  }
  if ($Queue | Get-Member -Name "revops_emailqueue" -ErrorAction SilentlyContinue) {
    $facts.revops_emailqueue = $Queue.revops_emailqueue
  }
  
  return $facts
}

function Normalize-PluginAssemblyFacts {
  param([Parameter(Mandatory=$true)]$Assembly)

  return [ordered]@{
    schema_version   = 1
    pluginassemblyid = $Assembly.pluginassemblyid
    name             = $Assembly.name
    version          = $Assembly.version
    publickeytoken   = $Assembly.publickeytoken
  }
}

function Normalize-FlowFacts {
  param([Parameter(Mandatory=$true)]$Flow)

  return [ordered]@{
    schema_version = 1
    workflowid     = $Flow.workflowid
    name           = $Flow.name
    category       = $Flow.category
    type           = $Flow.type
    statecode      = $Flow.statecode
    statuscode     = $Flow.statuscode
    primaryentity  = $Flow.primaryentity
  }
}

Export-ModuleMember -Function * -Alias *