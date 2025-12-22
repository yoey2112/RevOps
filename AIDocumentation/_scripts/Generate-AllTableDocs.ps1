[xml]$xml = Get-Content "C:\RevOps\RevOps-Analysts\Documentation\_Exports\revopstables_1_41_0_3\customizations.xml"
$entities = $xml.ImportExportXml.Entities.Entity
$customTables = $entities | Where-Object { $_.Name.InnerText -like "revops_*" }
$standardTables = $entities | Where-Object { $_.Name.InnerText -in @("Account", "Contact", "Lead", "Opportunity", "Competitor") }
$allTables = $customTables + $standardTables
$outputPath = "C:\RevOps\RevOps-Analysts\Documentation\Tables"
$count = 0

foreach ($entity in $allTables) {
  $logicalName = $entity.Name.InnerText
  $displayName = $entity.Name.LocalizedName
  
  if ($logicalName -like "revops_*") {
    $folderName = ($logicalName -replace "^revops_", "") -replace "_", "" | % { $_.Substring(0,1).ToUpper() + $_.Substring(1) }
  } else {
    $folderName = $logicalName.Substring(0,1).ToUpper() + $logicalName.Substring(1)
  }
  
  if ($folderName -eq "Incident") { $folderName = "Case" }
  if ($folderName -eq "Case" -and (Test-Path "$outputPath\Case\Columns.md")) { continue }
  
  $tableFolder = Join-Path $outputPath $folderName
  if (!(Test-Path $tableFolder)) { New-Item -ItemType Directory -Path $tableFolder | Out-Null }
  
  $attributes = $entity.EntityInfo.entity.attributes.attribute
  $customAttrs = $attributes | Where-Object { $_.IsCustomField -eq "1" }
  $lookups = $attributes | Where-Object { $_.Type -in @("lookup", "owner", "customer") }
  
  $descNode = $entity.EntityInfo.entity.Descriptions.Description | Where-Object { $_.languagecode -eq "1033" }
  $description = if ($descNode) { $descNode.description } else { "" }
  
  Write-Host "Creating: $folderName/" -ForegroundColor Cyan
  
  # README
  $readme = "# $displayName`n`n**Logical Name**: $logicalName`n**Custom Columns**: $($customAttrs.Count)`n**Lookups**: $($lookups.Count)`n`n"
  $readme += "## Business Purpose`n`n$description`n`n"
  $readme += "## Related Documentation`n`n- [Columns.md](./Columns.md)`n- [Relationships.md](./Relationships.md)`n"
  $readme | Set-Content (Join-Path $tableFolder "README.md") -Encoding UTF8
  
  # Columns
  $cols = "# $displayName - Columns`n`n**Total**: $($attributes.Count) ($($customAttrs.Count) custom)`n`n"
  $cols += "| Name | Display | Type |`n|------|---------|------|`n"
  foreach ($a in ($customAttrs | Select -First 50)) {
    $n = $a.Name
    $d = if ($a.displaynames.displayname) { $a.displaynames.displayname[0].description } else { "" }
    $t = $a.Type
    $cols += "| $n | $d | $t |`n"
  }
  $cols | Set-Content (Join-Path $tableFolder "Columns.md") -Encoding UTF8
  
  # Relationships
  $rels = "# $displayName - Relationships`n`n**Lookups**: $($lookups.Count)`n`n"
  $rels += "| Field | Type |`n|-------|------|`n"
  foreach ($l in ($lookups | Select -First 30)) {
    $fn = $l.Name
    $ft = $l.Type
    $rels += "| $fn | $ft |`n"
  }
  $rels | Set-Content (Join-Path $tableFolder "Relationships.md") -Encoding UTF8
  
  $count++
}

Write-Host "`nComplete: $count tables documented" -ForegroundColor Green
