# ============================================================================
# Acceptance-Checklist-FirstNightly.ps1
# ============================================================================
# Purpose: Diff-only verification for first nightly DocGen run
#
# This script validates that the new hardened YAML normalization doesn't
# introduce empty dicts (`- ''`) or other malformed entries in output.
#
# Checks:
#   1. No empty entries in 5 critical YAML files
#   2. Spot-check 2-3 tables for valid structure
#   3. Verify plugins/steps have proper objects
#
# Output: Generates Acceptance-Results.md with findings
# ============================================================================

param(
  [Parameter(Mandatory=$false)][string]$AIDocsRoot = "c:/RevOps/RevOps-Analysts/AIDocumentation",
  [Parameter(Mandatory=$false)][string]$ResultsFile = "$PSScriptRoot/Acceptance-Results.md"
)

$ErrorActionPreference = 'Stop'

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "ACCEPTANCE CHECKLIST - First Nightly Run" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

$results = @()
$allPassed = $true

# ============================================================================
# CHECK 1: No `- ''` entries in 5 critical YAML files
# ============================================================================
Write-Host "CHECK 1: Scanning for empty entries in YAML files..." -ForegroundColor Yellow

$criticalYamlFiles = @(
  "tables/_facts/columns.yaml",
  "tables/_facts/relationships.yaml",
  "tables/_facts/views.yaml",
  "plugins/_facts/plugin-types.yaml",
  "plugins/_facts/sdk-steps.yaml"
)

$yamlCheckPassed = $true
foreach ($relPath in $criticalYamlFiles) {
  $fullPath = Join-Path $AIDocsRoot $relPath
  
  if (-not (Test-Path $fullPath)) {
    Write-Host "  ⚠ SKIPPED: $relPath (file not found)" -ForegroundColor Gray
    continue
  }
  
  $content = Get-Content -Path $fullPath -Raw
  
  # Check for empty entries: `- ''` or `- ""`
  if ($content -match '^\s*-\s+[''"][\''"]' -or $content -match '^\s*-\s+$') {
    Write-Host "  ✗ FAILED: $relPath contains empty entries" -ForegroundColor Red
    $yamlCheckPassed = $false
    $allPassed = $false
    $results += "✗ FAILED: $relPath contains empty list items"
  } else {
    Write-Host "  ✓ PASS: $relPath (no empty entries)" -ForegroundColor Green
    $results += "✓ PASS: $relPath (no empty entries)"
  }
}

Write-Host ""

# ============================================================================
# CHECK 2: Spot-check 2-3 tables for valid structure
# ============================================================================
Write-Host "CHECK 2: Spot-checking table structures..." -ForegroundColor Yellow

$spotCheckTables = @("revops_pricingrequest", "incident", "opportunity")
$tableFacets = @("columns", "relationships", "views")

foreach ($table in $spotCheckTables) {
  $tablePath = Join-Path $AIDocsRoot "tables/$table/_facts"
  
  if (-not (Test-Path $tablePath)) {
    Write-Host "  ⚠ SKIPPED: Table '$table' not found" -ForegroundColor Gray
    continue
  }
  
  $tableCheckPassed = $true
  Write-Host "  Checking table: $table" -ForegroundColor Cyan
  
  foreach ($facet in $tableFacets) {
    $facetFile = Join-Path $tablePath "$facet.yaml"
    
    if (-not (Test-Path $facetFile)) {
      Write-Host "    ⊘ $facet.yaml (not present)" -ForegroundColor Gray
      continue
    }
    
    $content = Get-Content -Path $facetFile -Raw
    
    # Simple heuristic: valid YAML should have at least one key= value pair
    if ($content -match '\w+:\s*[^\s]' -or $content -match '- ') {
      Write-Host "    ✓ $facet.yaml (valid structure)" -ForegroundColor Green
    } else {
      Write-Host "    ✗ $facet.yaml (suspicious - may be malformed)" -ForegroundColor Red
      $tableCheckPassed = $false
      $allPassed = $false
    }
  }
  
  if ($tableCheckPassed) {
    $results += "✓ PASS: Table '$table' has valid facet files"
  } else {
    $results += "✗ FAILED: Table '$table' has malformed facet files"
  }
}

Write-Host ""

# ============================================================================
# CHECK 3: Verify plugins/steps have proper structure
# ============================================================================
Write-Host "CHECK 3: Verifying plugin facet structures..." -ForegroundColor Yellow

$pluginsPath = Join-Path $AIDocsRoot "plugins"
if (Test-Path $pluginsPath) {
  $pluginFolders = @(Get-ChildItem -Path $pluginsPath -Directory | Select-Object -First 2)
  
  if ($pluginFolders.Count -gt 0) {
    $pluginCheckPassed = $true
    foreach ($pluginFolder in $pluginFolders) {
      $factsPath = Join-Path $pluginFolder.FullName "_facts"
      
      if (Test-Path $factsPath) {
        $typeFile = Join-Path $factsPath "plugin-types.yaml"
        $stepsFile = Join-Path $factsPath "sdk-steps.yaml"
        
        $typesValid = $false
        $stepsValid = $false
        
        if (Test-Path $typeFile) {
          $content = Get-Content $typeFile -Raw
          if ($content -match 'types:' -and -not ($content -match '- [''"]')) {
            $typesValid = $true
            Write-Host "  ✓ $($pluginFolder.Name)/plugin-types.yaml (valid)" -ForegroundColor Green
          } else {
            Write-Host "  ✗ $($pluginFolder.Name)/plugin-types.yaml (malformed)" -ForegroundColor Red
            $pluginCheckPassed = $false
            $allPassed = $false
          }
        }
        
        if (Test-Path $stepsFile) {
          $content = Get-Content $stepsFile -Raw
          if ($content -match 'steps:' -and -not ($content -match '- [''"]')) {
            $stepsValid = $true
            Write-Host "  ✓ $($pluginFolder.Name)/sdk-steps.yaml (valid)" -ForegroundColor Green
          } else {
            Write-Host "  ✗ $($pluginFolder.Name)/sdk-steps.yaml (malformed)" -ForegroundColor Red
            $pluginCheckPassed = $false
            $allPassed = $false
          }
        }
      }
    }
    
    if ($pluginCheckPassed) {
      $results += "✓ PASS: Plugin facets have valid structures"
    } else {
      $results += "✗ FAILED: Some plugin facets are malformed"
    }
  } else {
    Write-Host "  ⚠ No plugins found (skipping)" -ForegroundColor Gray
  }
} else {
  Write-Host "  ⚠ Plugins directory not found (skipping)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# Generate results file
$reportContent = @"
# DocGen Acceptance Checklist - First Nightly Run

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Summary
$(if ($allPassed) { "✓ All checks PASSED - Output is valid" } else { "✗ Some checks FAILED - Review items below" })

## Details

$($results -join "`n")

## Recommendations

$(if ($allPassed) {
  "- Output is ready for manual spot-check in Git diff"
  "- Compare before/after for any unexpected structural changes"
  "- Verify no data loss in migration to hardened YAML normalization"
} else {
  "- Fix failing checks before accepting this nightly run"
  "- Review DocGen logs for detailed error messages"
  "- Ensure all extraction functions return valid objects"
  "- Run Pre-DocGen-Validation.ps1 to verify contract tests"
})

## Next Steps

1. Review this checklist in the nightly build logs
2. Check Git diff for actual YAML structure changes
3. Spot-check 3-5 tables manually in the diff view
4. Monitor for `- ''` entries in any YAML files
5. Verify table columns, relationships, and views have proper keys
"@

$reportContent | Set-Content -Path $ResultsFile -Encoding UTF8
Write-Host "Results saved to: $ResultsFile" -ForegroundColor Yellow
Write-Host ""

if ($allPassed) {
  Write-Host "✓ ACCEPTANCE CHECKLIST: PASSED" -ForegroundColor Green
  exit 0
} else {
  Write-Host "✗ ACCEPTANCE CHECKLIST: FAILED" -ForegroundColor Red
  exit 1
}
