# Enrich-AllFlows.ps1
# Processes all flow.schema.json files and enriches documentation

$flowsPath = 'C:\RevOps\RevOps-Analysts\Documentation\Flows'
$flowFolders = Get-ChildItem $flowsPath -Directory
$processed = 0
$updated = 0
$skipped = 0
$errors = @()

Write-Host '=== Flow Documentation Enrichment ===' -ForegroundColor Magenta
Write-Host "Processing $($flowFolders.Count) flow folders..." -ForegroundColor Cyan
Write-Host ''

foreach ($folder in $flowFolders) {
    $schemaPath = Join-Path $folder.FullName 'flow.schema.json'
    
    if (!(Test-Path $schemaPath)) {
        Write-Host "SKIP: $($folder.Name) - no schema file" -ForegroundColor Yellow
        $skipped++
        continue
    }
    
    try {
        Write-Host "Processing: $($folder.Name)" -ForegroundColor Cyan
        
        # Parse schema
        $schema = Get-Content $schemaPath -Raw | ConvertFrom-Json
        $def = $schema.properties.definition
        
        # Extract metadata
        $trigger = $def.triggers.PSObject.Properties | Select-Object -First 1
        $triggerType = if ($trigger) { $trigger.Value.type } else { 'Unknown' }
        $triggerKind = if ($trigger.Value.kind) { $trigger.Value.kind } else { '' }
        
        $actions = $def.actions.PSObject.Properties
        $actionCount = 0
        if ($actions) { 
            $actionCount = @($actions).Count 
        }
        
        # Detect tables
        $tables = @()
        if ($actions) {
            foreach ($action in $actions) {
                $inputs = $action.Value.inputs
                if ($inputs.parameters.entityName) {
                    $tables += $inputs.parameters.entityName
                }
            }
        }
        $tables = $tables | Select-Object -Unique
        
        # Detect connectors
        $connectors = @()
        if ($schema.properties.connectionReferences) {
            $connectors = $schema.properties.connectionReferences.PSObject.Properties | 
                ForEach-Object { $_.Value.api.name -replace '^shared_', '' }
        }
        
        # Build README update
        $readmePath = Join-Path $folder.FullName 'README.md'
        $readme = Get-Content $readmePath -Raw -ErrorAction SilentlyContinue
        
        if (!$readme) {
            $readme = "# $($folder.Name)`r`n`r`n"
        }
        
        # Check for AI markers
        if ($readme -notmatch '<!-- AI:BEGIN AUTO -->') {
            # Build AI section using array
            $aiLines = @()
            $aiLines += ''
            $aiLines += '<!-- AI:BEGIN AUTO -->'
            $aiLines += '## Trigger'
            if ($triggerKind) {
                $aiLines += "**Type**: $triggerType ($triggerKind)"
            } else {
                $aiLines += "**Type**: $triggerType"
            }
            $aiLines += ''
            $aiLines += '## Tables Touched'
            if ($tables.Count -gt 0) {
                foreach ($table in $tables) {
                    $aiLines += "- $table"
                }
            } else {
                $aiLines += 'None detected'
            }
            $aiLines += ''
            $aiLines += '## Connectors Used'
            if ($connectors.Count -gt 0) {
                foreach ($conn in $connectors) {
                    $aiLines += "- $conn"
                }
            } else {
                $aiLines += 'Built-in actions only'
            }
            $aiLines += ''
            $aiLines += '## Statistics'
            $aiLines += "- Total Actions: $actionCount"
            $aiLines += "- Trigger Type: $triggerType"
            $aiLines += ''
            $aiLines += '---'
            $aiLines += 'Last Updated By: AI'
            $aiLines += 'Source: flow.schema.json'
            $aiLines += "Date: $(Get-Date -Format 'yyyy-MM-dd')"
            $aiLines += 'Confidence: Medium'
            $aiLines += '<!-- AI:END AUTO -->'
            
            $readme += ($aiLines -join "`r`n")
            $readme | Set-Content $readmePath -Encoding UTF8
            Write-Host '  ✓ Updated README.md' -ForegroundColor Green
        }
        
        # Build flow.logic.md using array
        $logicLines = @()
        $logicLines += "# Flow Logic: $($folder.Name)"
        $logicLines += ''
        $logicLines += '<!-- AI:BEGIN AUTO -->'
        $logicLines += '## Trigger'
        $logicLines += "**Type**: $triggerType"
        if ($triggerKind) {
            $logicLines += "**Kind**: $triggerKind"
        } else {
            $logicLines += '**Kind**: N/A'
        }
        $logicLines += ''
        $logicLines += "## Actions ($actionCount total)"
        $logicLines += ''
        
        $step = 1
        if ($actions) {
            foreach ($action in ($actions | Select-Object -First 20)) {
                $actionName = $action.Name
                $actionType = $action.Value.type
                $logicLines += "### $step. $actionName"
                $logicLines += "**Type**: $actionType"
                $logicLines += ''
                $step++
            }
            
            if ($actionCount -gt 20) {
                $remaining = $actionCount - 20
                $logicLines += "*(Plus $remaining more actions - see flow.schema.json for complete list)*"
                $logicLines += ''
            }
        }
        
        $logicLines += '---'
        $logicLines += 'Last Updated By: AI'
        $logicLines += 'Source: flow.schema.json'
        $logicLines += "Date: $(Get-Date -Format 'yyyy-MM-dd')"
        $logicLines += 'Confidence: Medium'
        $logicLines += '<!-- AI:END AUTO -->'
        
        $logicPath = Join-Path $folder.FullName 'flow.logic.md'
        ($logicLines -join "`r`n") | Set-Content $logicPath -Encoding UTF8
        Write-Host '  ✓ Updated flow.logic.md' -ForegroundColor Green
        
        $processed++
        $updated++
        
    } catch {
        Write-Host "  ERROR: $_" -ForegroundColor Red
        $errors += $folder.Name
    }
}

Write-Host ''
Write-Host '=== Summary ===' -ForegroundColor Magenta
Write-Host "Total folders: $($flowFolders.Count)" -ForegroundColor White
Write-Host "Processed: $processed" -ForegroundColor Green
Write-Host "Updated: $updated" -ForegroundColor Green
Write-Host "Skipped: $skipped" -ForegroundColor Yellow
Write-Host "Errors: $($errors.Count)" -ForegroundColor $(if ($errors.Count -gt 0) { 'Red' } else { 'Green' })

if ($errors.Count -gt 0) {
    Write-Host ''
    Write-Host 'Flows with errors:' -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

Write-Host ''
Write-Host 'Done!' -ForegroundColor Green
