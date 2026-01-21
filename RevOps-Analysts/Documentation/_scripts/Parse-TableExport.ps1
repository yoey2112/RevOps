# Parse-TableExport.ps1
# Extracts table metadata from customizations.xml and generates documentation

param(
    [string]$ExportPath = "C:\RevOps\RevOps-Analysts\Documentation\_Exports\revopstables_1_41_0_3\customizations.xml",
    [string]$OutputPath = "C:\RevOps\RevOps-Analysts\Documentation\Tables"
)

# Load XML
Write-Host "Loading customizations.xml..." -ForegroundColor Cyan
[xml]$customizations = Get-Content $ExportPath

# Extract all entities
$entities = $customizations.ImportExportXml.Entities.Entity

Write-Host "Found $($entities.Count) entities in export" -ForegroundColor Green

# Filter to custom revops_ tables only
$revopsTables = $entities | Where-Object { $_.Name.InnerText -like "revops_*" }

Write-Host "Found $($revopsTables.Count) custom revops_ tables" -ForegroundColor Yellow

# Create summary object
$tableSummary = @()

foreach ($entity in $revopsTables) {
    $logicalName = $entity.Name.InnerText
    $displayName = $entity.Name.LocalizedName
    $description = ""
    
    # Try to get description
    $descNode = $entity.EntityInfo.entity.Descriptions.Description | Where-Object { $_.languagecode -eq "1033" }
    if ($descNode) {
        $description = $descNode.description
    }
    
    # Count attributes (columns)
    $attributes = $entity.EntityInfo.entity.attributes.attribute
    $columnCount = if ($attributes) { $attributes.Count } else { 0 }
    
    # Folder name in PascalCase (remove revops_ prefix and convert)
    $folderName = ($logicalName -replace "^revops_", "") -replace "_", "" | ForEach-Object {
        $_.Substring(0,1).ToUpper() + $_.Substring(1)
    }
    
    $tableSummary += [PSCustomObject]@{
        LogicalName = $logicalName
        DisplayName = $displayName
        FolderName = $folderName
        Description = $description
        ColumnCount = $columnCount
    }
    
    Write-Host "  - $displayName ($logicalName) -> $folderName/ - $columnCount columns" -ForegroundColor Gray
}

# Export to JSON for machine-readable schema
$schemaPath = Join-Path (Split-Path $OutputPath -Parent) "_schemas"
if (!(Test-Path $schemaPath)) {
    New-Item -ItemType Directory -Path $schemaPath | Out-Null
}

$tableSummary | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $schemaPath "tables.json")
Write-Host "`nTable inventory saved to _schemas/tables.json" -ForegroundColor Green

# Display summary
Write-Host "`n=== CUSTOM TABLES SUMMARY ===" -ForegroundColor Magenta
$tableSummary | Format-Table -AutoSize

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Review tables.json" -ForegroundColor White
Write-Host "2. Run document generation for each table" -ForegroundColor White
Write-Host "3. Focus on tables with existing Web_resources/ first (Case, Account, Contact, Lead, Opportunity)" -ForegroundColor White
