# ============================================================================
# Pre-DocGen-Validation.ps1
# ============================================================================
# Purpose: Pipeline Gate - Run contract tests BEFORE DocGen writes any outputs
# 
# This script ensures code quality by validating YAML normalization and validation
# logic across all scenarios before any documentation generation occurs.
#
# Exit Codes:
#   0 = All production tests passed (proceed with DocGen)
#   1 = Production test failed (BLOCK DocGen, fix code)
#   2 = Script error (check logs, contact DevOps)
#
# Usage:
#   ./Pre-DocGen-Validation.ps1
#   if ($LASTEXITCODE -eq 0) { ./Start-DocGen.ps1 }
# ============================================================================

param(
  [Parameter(Mandatory=$false)][switch]$Verbose = $false,
  [Parameter(Mandatory=$false)][string]$TestFilePath = "$PSScriptRoot/Test-YamlNormalization.ps1"
)

# Ensure we're using full error handling
$ErrorActionPreference = 'Stop'
$VerbosePreference = if ($Verbose) { 'Continue' } else { 'SilentlyContinue' }

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "PRE-DOCGEN VALIDATION GATE (Contract Tests)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Verify test file exists
if (-not (Test-Path $TestFilePath)) {
  Write-Host "ERROR: Test file not found: $TestFilePath" -ForegroundColor Red
  exit 2
}

Write-Host "Running Contract Tests: $TestFilePath" -ForegroundColor Yellow

# Run tests and capture exit code
& powershell -NoProfile -File $TestFilePath
$testExitCode = $LASTEXITCODE

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

if ($testExitCode -eq 0) {
  Write-Host "✓ ALL PRODUCTION TESTS PASSED" -ForegroundColor Green
  Write-Host "✓ Pipeline Gate: APPROVED" -ForegroundColor Green
  Write-Host "✓ DocGen can proceed safely" -ForegroundColor Green
  Write-Host ""
  exit 0
} else {
  Write-Host "✗ PRODUCTION TESTS FAILED" -ForegroundColor Red
  Write-Host "✗ Pipeline Gate: BLOCKED" -ForegroundColor Red
  Write-Host "✗ Fix failures above before DocGen" -ForegroundColor Red
  Write-Host ""
  Write-Host "Troubleshooting:" -ForegroundColor Yellow
  Write-Host "  - Review test output above for specific failure details"
  Write-Host "  - Ensure Assert-ValidYamlList and Normalize-ListForYaml are correct"
  Write-Host "  - Check that all extraction functions return valid objects"
  Write-Host "  - Verify YAML deserializer handling (OrderedDictionary, Generic.Dictionary)"
  Write-Host ""
  exit 1
}
