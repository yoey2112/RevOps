# Build-FlowTableTraceability.ps1
# Creates bidirectional traceability between Flows and Tables

$flowsPath = 'C:\RevOps\RevOps-Analysts\Documentation\Flows'
$tablesPath = 'C:\RevOps\RevOps-Analysts\Documentation\Tables'

# Statistics
$stats = @{
    FlowsScanned = 0
    FlowsUpdated = 0
    TablesUpdated = 0
    TablesCreated = 0
    SchemaFallbacks = @()
    UnmappedTables = @()
}

# Build table name mapping (case-insensitive lookup)
$tableMap = @{}
Get-ChildItem $tablesPath -Directory | ForEach-Object {
    $tableMap[$_.Name.ToLower()] = $_.Name
}

# Logical name to folder mapping
$logicalMap = @{
    'incident' = 'Case'
    'incidents' = 'Case'
    'account' = 'Account'
    'contact' = 'Contact'
    'lead' = 'Lead'
    'opportunity' = 'Opportunity'
    'competitor' = 'Competitor'
    'accounts' = 'Account'
    'contacts' = 'Contact'
    'leads' = 'Lead'
    'opportunities' = 'Opportunity'
}

# Flow to Tables mapping
$flowTableMap = @{}

Write-Host '=== Flow-Table Traceability Builder ===' -ForegroundColor Magenta
Write-Host ''

# Phase 1: Extract tables from each flow
$flowFolders = Get-ChildItem $flowsPath -Directory | Where-Object { $_.Name -ne '_archive' }
foreach ($flowFolder in $flowFolders) {
    $stats.FlowsScanned++
    $flowName = $flowFolder.Name
    $readmePath = Join-Path $flowFolder.FullName 'README.md'
    $schemaPath = Join-Path $flowFolder.FullName 'flow.schema.json'
    
    if (!(Test-Path $readmePath)) {
        Write-Host "SKIP: $flowName - no README.md" -ForegroundColor Yellow
        continue
    }
    
    # Extract tables from README
    $tables = @()
    $readme = Get-Content $readmePath -Raw -ErrorAction SilentlyContinue
    
    if ($readme -match '(?s)## Tables Touched.*?<!-- AI:BEGIN AUTO -->(.*?)<!-- AI:END AUTO -->') {
        $autoSection = $Matches[1]
        $tables = [regex]::Matches($autoSection, '\[([^\]]+)\]') | ForEach-Object { $_.Groups[1].Value }
    } elseif ($readme -match '(?s)## Tables Touched(.*?)(?=##|\z)') {
        # Parse any existing tables section
        $section = $Matches[1]
        $tables = [regex]::Matches($section, '-\s*([a-zA-Z_]+)') | ForEach-Object { $_.Groups[1].Value }
    }
    
    # Fallback to schema if no tables found
    if ($tables.Count -eq 0 -and (Test-Path $schemaPath)) {
        Write-Host "  Using schema fallback for $flowName" -ForegroundColor Cyan
        $stats.SchemaFallbacks += $flowName
        
        try {
            $schema = Get-Content $schemaPath -Raw | ConvertFrom-Json
            $def = $schema.properties.definition
            
            # Extract from actions
            if ($def.actions) {
                $def.actions.PSObject.Properties | ForEach-Object {
                    $action = $_.Value
                    if ($action.inputs.parameters.entityName) {
                        $tables += $action.inputs.parameters.entityName
                    }
                }
            }
            
            # Extract from trigger
            if ($def.triggers) {
                $def.triggers.PSObject.Properties | ForEach-Object {
                    $trigger = $_.Value
                    if ($trigger.inputs.parameters.entityName) {
                        $tables += $trigger.inputs.parameters.entityName
                    }
                }
            }
            
            $tables = $tables | Select-Object -Unique
        } catch {
            Write-Host "  ERROR parsing schema: $_" -ForegroundColor Red
        }
    }
    
    if ($tables.Count -gt 0) {
        $flowTableMap[$flowName] = $tables | Select-Object -Unique
        Write-Host "  $flowName -> $($tables.Count) tables" -ForegroundColor Green
    }
}

Write-Host ''
Write-Host '=== Phase 1 Complete: Extracted tables from flows ===' -ForegroundColor Magenta
Write-Host ''

# Phase 2: Build reverse mapping (Table -> Flows)
$tableFlowMap = @{}
foreach ($flow in $flowTableMap.Keys) {
    $tables = $flowTableMap[$flow]
    foreach ($table in $tables) {
        if (!$tableFlowMap.ContainsKey($table)) {
            $tableFlowMap[$table] = @()
        }
        $tableFlowMap[$table] += $flow
    }
}

Write-Host '=== Phase 2 Complete: Built reverse mapping ===' -ForegroundColor Magenta
Write-Host "Tables referenced by flows: $($tableFlowMap.Keys.Count)" -ForegroundColor Cyan
Write-Host ''

# Phase 3: Update Flow READMEs
Write-Host '=== Phase 3: Updating Flow READMEs ===' -ForegroundColor Magenta
foreach ($flowName in $flowTableMap.Keys) {
    $readmePath = Join-Path $flowsPath "$flowName\README.md"
    $readme = Get-Content $readmePath -Raw
    
    $tables = $flowTableMap[$flowName] | Sort-Object
    
    # Map tables to actual folder names
    $mappedTables = @()
    foreach ($table in $tables) {
        $tableLower = $table.ToLower()
        if ($tableMap.ContainsKey($tableLower)) {
            $mappedTables += $tableMap[$tableLower]
        } elseif ($logicalMap.ContainsKey($tableLower)) {
            $mappedTables += $logicalMap[$tableLower]
        } else {
            # Create stub for unmapped table
            $mappedTables += $table
            if ($stats.UnmappedTables -notcontains $table) {
                $stats.UnmappedTables += $table
            }
        }
    }
    $mappedTables = $mappedTables | Select-Object -Unique | Sort-Object
    
    # Build AUTO section
    $autoLines = @()
    $autoLines += '<!-- AI:BEGIN AUTO -->'
    foreach ($table in $mappedTables) {
        $autoLines += "- [$table](../../Tables/$table/README.md)"
    }
    if ($stats.SchemaFallbacks -contains $flowName) {
        $autoLines += ''
        $autoLines += '*Derived from flow.schema.json*'
    }
    $autoLines += '<!-- AI:END AUTO -->'
    $autoContent = $autoLines -join "`r`n"
    
    # Update README
    if ($readme -match '(?s)## Tables Touched.*?<!-- AI:BEGIN AUTO -->.*?<!-- AI:END AUTO -->') {
        # Replace existing AUTO section
        $readme = $readme -replace '(?s)(## Tables Touched.*?)<!-- AI:BEGIN AUTO -->.*?<!-- AI:END AUTO -->', "`$1$autoContent"
    } elseif ($readme -match '## Tables Touched') {
        # Add AUTO section after existing header
        $readme = $readme -replace '(## Tables Touched)', "`$1`r`n$autoContent"
    } else {
        # Add new section before AI:BEGIN AUTO (if exists) or at end
        if ($readme -match '<!-- AI:BEGIN AUTO -->') {
            $readme = $readme -replace '(<!-- AI:BEGIN AUTO -->)', "## Tables Touched`r`n$autoContent`r`n`r`n`$1"
        } else {
            $readme += "`r`n`r`n## Tables Touched`r`n$autoContent`r`n"
        }
    }
    
    $readme | Set-Content $readmePath -Encoding UTF8
    $stats.FlowsUpdated++
}

Write-Host "Updated $($stats.FlowsUpdated) flow READMEs" -ForegroundColor Green
Write-Host ''

# Phase 4: Update/Create Table READMEs
Write-Host '=== Phase 4: Updating Table READMEs ===' -ForegroundColor Magenta
foreach ($table in $tableFlowMap.Keys) {
    # Map to folder name
    $tableLower = $table.ToLower()
    $tableFolder = $null
    if ($tableMap.ContainsKey($tableLower)) {
        $tableFolder = $tableMap[$tableLower]
    } elseif ($logicalMap.ContainsKey($tableLower)) {
        $tableFolder = $logicalMap[$tableLower]
    } else {
        $tableFolder = $table
    }
    
    $tablePath = Join-Path $tablesPath $tableFolder
    $readmePath = Join-Path $tablePath 'README.md'
    
    # Create folder if needed
    if (!(Test-Path $tablePath)) {
        New-Item -ItemType Directory -Path $tablePath | Out-Null
        Write-Host "  Created folder: $tableFolder" -ForegroundColor Cyan
    }
    
    # Create or update README
    $flows = $tableFlowMap[$table] | Sort-Object
    
    # Build AUTO section
    $autoLines = @()
    $autoLines += '<!-- AI:BEGIN AUTO -->'
    foreach ($flow in $flows) {
        # Try to extract trigger from flow README
        $flowReadmePath = Join-Path $flowsPath "$flow\README.md"
        $trigger = ''
        if (Test-Path $flowReadmePath) {
            $flowReadme = Get-Content $flowReadmePath -Raw
            if ($flowReadme -match '\*\*Type\*\*:\s*([^\r\n]+)') {
                $trigger = ' - Trigger: ' + $Matches[1]
            }
        }
        $autoLines += "- [$flow](../../Flows/$flow/README.md)$trigger"
    }
    $autoLines += '<!-- AI:END AUTO -->'
    $autoContent = $autoLines -join "`r`n"
    
    if (Test-Path $readmePath) {
        # Update existing README
        $readme = Get-Content $readmePath -Raw
        
        if ($readme -match '(?s)## Used by Flows.*?<!-- AI:BEGIN AUTO -->.*?<!-- AI:END AUTO -->') {
            # Replace existing AUTO section
            $readme = $readme -replace '(?s)(## Used by Flows.*?)<!-- AI:BEGIN AUTO -->.*?<!-- AI:END AUTO -->', "`$1$autoContent"
        } elseif ($readme -match '## Used by Flows') {
            # Add AUTO section after existing header
            $readme = $readme -replace '(## Used by Flows)', "`$1`r`n$autoContent"
        } else {
            # Add new section at end
            $readme += "`r`n`r`n## Used by Flows`r`n$autoContent`r`n"
        }
        
        $readme | Set-Content $readmePath -Encoding UTF8
        $stats.TablesUpdated++
        Write-Host "  Updated: $tableFolder" -ForegroundColor Green
    } else {
        # Create stub README
        $stubLines = @()
        $stubLines += "# $tableFolder"
        $stubLines += ''
        $stubLines += '## Purpose'
        $stubLines += 'TBD - This table was auto-discovered from flow references.'
        $stubLines += ''
        $stubLines += '## Missing Info / Needs Review'
        $stubLines += '- Business purpose and context'
        $stubLines += '- Key columns and relationships'
        $stubLines += '- Who owns/maintains this table'
        $stubLines += ''
        $stubLines += '## Used by Flows'
        $stubLines += $autoContent
        $stubLines += ''
        $stubLines += '---'
        $stubLines += 'Last Updated By: AI (Traceability Agent)'
        $stubLines += "Date: $(Get-Date -Format 'yyyy-MM-dd')"
        
        ($stubLines -join "`r`n") | Set-Content $readmePath -Encoding UTF8
        $stats.TablesCreated++
        Write-Host "  Created stub: $tableFolder" -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host '=== FINAL REPORT ===' -ForegroundColor Magenta
Write-Host "Flows scanned: $($stats.FlowsScanned)" -ForegroundColor White
Write-Host "Flows updated: $($stats.FlowsUpdated)" -ForegroundColor Green
Write-Host "Table READMEs updated: $($stats.TablesUpdated)" -ForegroundColor Green
Write-Host "Table READMEs created: $($stats.TablesCreated)" -ForegroundColor Yellow

if ($stats.SchemaFallbacks.Count -gt 0) {
    Write-Host ''
    Write-Host "Flows requiring schema fallback ($($stats.SchemaFallbacks.Count)):" -ForegroundColor Cyan
    $stats.SchemaFallbacks | ForEach-Object { Write-Host "  - $_" -ForegroundColor Cyan }
}

if ($stats.UnmappedTables.Count -gt 0) {
    Write-Host ''
    Write-Host "Tables that could not be cleanly mapped ($($stats.UnmappedTables.Count)):" -ForegroundColor Yellow
    $stats.UnmappedTables | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}

Write-Host ''
Write-Host 'Done!' -ForegroundColor Green
