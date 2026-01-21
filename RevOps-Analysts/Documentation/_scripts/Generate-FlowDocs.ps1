param([int]$MaxFlows = 0)
$flows = Get-ChildItem "C:\RevOps\RevOps-Analysts\Documentation\_Exports\revopsflows_1_28_0_1\Workflows" -Filter "*.json"
if ($MaxFlows -gt 0) { $flows = $flows | Select -First $MaxFlows }
$count = 0
foreach ($f in $flows) {
  $json = Get-Content $f.FullName -Raw | ConvertFrom-Json
  $name = $f.BaseName -replace '-[A-F0-9]{8}.*$', '' | % { $_.ToLower() -replace '[^a-z0-9]+', '-' }
  $folder = "C:\RevOps\RevOps-Analysts\Documentation\Flows\$name"
  if (!(Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
  "# $name" | Set-Content "$folder\README.md"
  Copy-Item $f.FullName "$folder\flow.schema.json"
  "Logic file" | Set-Content "$folder\flow.logic.md"
  "Diagram" | Set-Content "$folder\diagram.mmd"
  $count++
  Write-Host "Created: $name"
}
Write-Host "`nDone: $count flows"
