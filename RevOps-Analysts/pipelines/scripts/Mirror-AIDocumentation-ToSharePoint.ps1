# Mirror-AIDocumentation-ToSharePoint.ps1
# (Obsolete: SharePoint sync replaced by Azure Blob sync)
# This script is no longer used and can be safely deleted.
param(
  [Parameter(Mandatory=$true)][string]$TenantId,
  [Parameter(Mandatory=$true)][string]$ClientId,
  [Parameter(Mandatory=$true)][string]$ClientSecret,
  [Parameter(Mandatory=$true)][string]$SiteHostname,
  [Parameter(Mandatory=$true)][string]$SitePath,
  [Parameter(Mandatory=$true)][string]$LibraryName,
  [Parameter(Mandatory=$true)][string]$DocsRoot
)

$ErrorActionPreference = 'Stop'

function New-GraphToken {
  param([string]$TenantId,[string]$ClientId,[string]$ClientSecret)

  $tokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
  $body = @{
    client_id     = $ClientId
    client_secret = $ClientSecret
    scope         = "https://graph.microsoft.com/.default"
    grant_type    = "client_credentials"
  }

  $resp = Invoke-RestMethod -Method POST -Uri $tokenUri -ContentType "application/x-www-form-urlencoded" -Body $body
  return $resp.access_token
}

function Invoke-Graph {
  param(
    [Parameter(Mandatory=$true)][string]$Method,
    [Parameter(Mandatory=$true)][string]$Uri,
    [Parameter(Mandatory=$true)][string]$Token,
    $Body = $null,
    [hashtable]$Headers = @{}
  )

  $h = @{ Authorization = "Bearer $Token" }
  foreach($k in $Headers.Keys){ $h[$k] = $Headers[$k] }

  if ($null -ne $Body) {
    return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $h -ContentType "application/json" -Body ($Body | ConvertTo-Json -Depth 20)
  } else {
    return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $h
  }
}

function Invoke-GraphUpload {
  param(
    [Parameter(Mandatory=$true)][string]$Uri,
    [Parameter(Mandatory=$true)][string]$Token,
    [Parameter(Mandatory=$true)][byte[]]$Bytes
  )
  $h = @{ Authorization = "Bearer $Token" }
  return Invoke-RestMethod -Method PUT -Uri $Uri -Headers $h -ContentType "application/octet-stream" -Body $Bytes
}

function Get-AllPages {
  param([string]$FirstUri,[string]$Token)

  $items = @()
  $uri = $FirstUri
  while ($true) {
    $resp = Invoke-Graph -Method GET -Uri $uri -Token $Token
    if ($resp.value) { $items += $resp.value }
    if ($resp.'@odata.nextLink') {
      $uri = $resp.'@odata.nextLink'
    } else {
      break
    }
  }
  return $items
}

function Normalize-RelPath {
  param([string]$p)
  $p = $p -replace '\\','/'
  $p = $p.TrimStart('/')
  return $p
}

# Returns both files and folders
function Get-RemoteItemsRecursive {
  param([string]$DriveId,[string]$Token)

  $files = @{}
  $folders = @{}   # path -> { id = "...", path = "..." }

  $stack = New-Object System.Collections.Stack
  $stack.Push(@{ path = ""; itemId = "root" })

  while ($stack.Count -gt 0) {
    $node = $stack.Pop()
    $itemId = $node.itemId
    $currentPath = $node.path

    $childrenUri = "https://graph.microsoft.com/v1.0/drives/$DriveId/items/$itemId/children?`$top=999"
    $children = Get-AllPages -FirstUri $childrenUri -Token $Token

    foreach ($c in $children) {
      $name = $c.name
      $childRel = if ([string]::IsNullOrEmpty($currentPath)) { $name } else { "$currentPath/$name" }
      $childRel = Normalize-RelPath $childRel

      if ($c.folder -ne $null) {
        # Record folder (skip root)
        $folders[$childRel] = @{ id = $c.id; path = $childRel }
        # Recurse
        $stack.Push(@{ path = $childRel; itemId = $c.id })
      } else {
        $files[$childRel] = @{
          id = $c.id
          eTag = $c.eTag
          size = $c.size
        }
      }
    }
  }

  return @{
    files = $files
    folders = $folders
  }
}

Write-Host "=== RevOps Docs Mirror ==="
Write-Host "DocsRoot: $DocsRoot"
Write-Host "SharePoint Site: https://$SiteHostname$SitePath"
Write-Host "Library: $LibraryName"

# Validate docs root exists locally
if (!(Test-Path -LiteralPath $DocsRoot)) {
  throw "DocsRoot folder not found in repo workspace: $DocsRoot"
}

# Get token
$token = New-GraphToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret

# Resolve site
$siteUri = "https://graph.microsoft.com/v1.0/sites/${SiteHostname}:${SitePath}"
$site = Invoke-Graph -Method GET -Uri $siteUri -Token $token
$siteId = $site.id
Write-Host "Resolved siteId: $siteId"

# Resolve drive (document library)
$drivesUri = "https://graph.microsoft.com/v1.0/sites/$siteId/drives"
$drives = Invoke-Graph -Method GET -Uri $drivesUri -Token $token
$drive = $drives.value | Where-Object { $_.name -eq $LibraryName } | Select-Object -First 1
if ($null -eq $drive) {
  $available = ($drives.value | ForEach-Object { $_.name }) -join ", "
  throw "Drive/Library '$LibraryName' not found. Available drives: $available"
}
$driveId = $drive.id
Write-Host "Resolved driveId: $driveId"

# Build local file list
$localBase = (Resolve-Path -LiteralPath $DocsRoot).Path
$localFiles = Get-ChildItem -LiteralPath $localBase -Recurse -File

# Map: relativePath -> fullPath
$localMap = @{}
foreach ($f in $localFiles) {
  $rel = $f.FullName.Substring($localBase.Length).TrimStart('\','/')
  $rel = Normalize-RelPath $rel
  $localMap[$rel] = $f.FullName
}

Write-Host ("Local files found: {0}" -f $localMap.Count)

# Transform markdown files to use library-relative paths (optimal for Copilot in SharePoint)
$transformScriptPath = Join-Path $PSScriptRoot "Transform-MarkdownLinks.ps1"

if (Test-Path -LiteralPath $transformScriptPath) {
  Write-Host "Transforming markdown links for SharePoint/Copilot compatibility..."
  $mdCount = 0
  
  # Create temp directory for transformed files
  $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "RevOps-Docs-Transform"
  if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
  New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
  
  # Create new map for transformed files (to avoid modifying collection during enumeration)
  $transformedMap = @{}
  
  # Copy all files to temp directory and transform markdown files
  foreach ($rel in @($localMap.Keys)) {
    $sourcePath = $localMap[$rel]
    $tempPath = Join-Path $tempDir $rel
    $tempPathDir = [System.IO.Path]::GetDirectoryName($tempPath)
    
    # Ensure directory exists
    if (!(Test-Path $tempPathDir)) {
      New-Item -ItemType Directory -Path $tempPathDir -Force | Out-Null
    }
    
    # Copy file
    Copy-Item -LiteralPath $sourcePath -Destination $tempPath -Force
    
    # Transform markdown files to use library-relative paths
    if ($sourcePath -match '\.md$') {
      & $transformScriptPath -FilePath $tempPath -DocsRoot $localBase
      $mdCount++
    }
    
    # Add to transformed map
    $transformedMap[$rel] = $tempPath
  }
  
  # Replace localMap with transformed map
  $localMap = $transformedMap
  
  Write-Host "Transformed $mdCount markdown files to use library-relative paths"
}
else {
  Write-Warning "Transform-MarkdownLinks.ps1 not found at $transformScriptPath. Skipping link transformation."
}

# Build remote file/folder list (entire library, recursive)
$remote = Get-RemoteItemsRecursive -DriveId $driveId -Token $token
$remoteFiles = $remote.files
$remoteFolders = $remote.folders

Write-Host ("Remote files found: {0}" -f $remoteFiles.Count)
Write-Host ("Remote folders found: {0}" -f $remoteFolders.Count)

# Pre-create missing folder structure to avoid conflicts
$neededFolders = New-Object System.Collections.Generic.HashSet[string]
foreach ($rel in $localMap.Keys) {
  $parts = $rel -split '/'
  for ($i = 0; $i -lt ($parts.Length - 1); $i++) {
    $folderPath = ($parts[0..$i] -join '/')
    if ($folderPath -and !$remoteFolders.ContainsKey($folderPath)) {
      [void]$neededFolders.Add($folderPath)
    }
  }
}

if ($neededFolders.Count -gt 0) {
  Write-Host ("Creating missing folders: {0}" -f $neededFolders.Count)
  $sortedFolders = $neededFolders | Sort-Object { $_.Length }
  foreach ($fp in $sortedFolders) {
    $pathSegments = $fp -split '/'
    $encodedSegments = $pathSegments | ForEach-Object { [System.Uri]::EscapeDataString($_) }
    $encodedPath = $encodedSegments -join '/'
    $folderUri = "https://graph.microsoft.com/v1.0/drives/${driveId}/root:/${encodedPath}"
    
    try {
      # Try to create folder (will fail gracefully if exists)
      $parentPath = ($pathSegments[0..($pathSegments.Length-2)] -join '/')
      $folderName = $pathSegments[-1]
      
      if ($parentPath) {
        $parentEncoded = ($parentPath -split '/' | ForEach-Object { [System.Uri]::EscapeDataString($_) }) -join '/'
        $createUri = "https://graph.microsoft.com/v1.0/drives/${driveId}/root:/${parentEncoded}:/children"
      } else {
        $createUri = "https://graph.microsoft.com/v1.0/drives/${driveId}/root/children"
      }
      
      $body = @{
        name = $folderName
        folder = @{}
        "@microsoft.graph.conflictBehavior" = "fail"
      }
      Invoke-Graph -Method POST -Uri $createUri -Token $token -Body $body | Out-Null
      $remoteFolders[$fp] = @{ path = $fp }
    } catch {
      # Folder might already exist, that's OK
      Write-Host "Folder may already exist: $fp"
    }
  }
}

# Upload/update all local files
$uploaded = 0
foreach ($rel in $localMap.Keys) {
  $full = $localMap[$rel]
  $bytes = [System.IO.File]::ReadAllBytes($full)

  # Upload to: /root:/<path>:/content
  # Split path into segments and encode each individually, then rejoin with /
  $pathSegments = $rel -split '/'
  $encodedSegments = $pathSegments | ForEach-Object { [System.Uri]::EscapeDataString($_) }
  $encodedPath = $encodedSegments -join '/'
  $uploadUri = "https://graph.microsoft.com/v1.0/drives/${driveId}/root:/${encodedPath}:/content"

  # PUT overwrites/creates - wrap in try/catch to provide better error context
  try {
    Invoke-GraphUpload -Uri $uploadUri -Token $token -Bytes $bytes | Out-Null
    $uploaded++
    if (($uploaded % 50) -eq 0) { Write-Host "Uploaded/updated $uploaded / $($localMap.Count)..." }
  } catch {
    Write-Host "##[error]Failed to upload: $rel"
    Write-Host "##[error]Error: $_"
    throw
  }
}
Write-Host "Uploaded/updated: $uploaded"

# Delete remote files not present locally (true mirror)
$toDelete = @()
foreach ($r in $remoteFiles.Keys) {
  if (!$localMap.ContainsKey($r)) { $toDelete += $r }
}
Write-Host ("Remote files to delete (not in repo): {0}" -f $toDelete.Count)

$deleted = 0
foreach ($r in $toDelete) {
  $itemId = $remoteFiles[$r].id
  $delUri = "https://graph.microsoft.com/v1.0/drives/$driveId/items/$itemId"
  Invoke-Graph -Method DELETE -Uri $delUri -Token $token | Out-Null
  $deleted++
  if (($deleted % 50) -eq 0) { Write-Host "Deleted $deleted / $($toDelete.Count)..." }
}
Write-Host "Deleted: $deleted"

# Delete folders bottom-up (deepest first)
$folderPaths = $remoteFolders.Keys | Sort-Object { $_.Length } -Descending
Write-Host ("Remote folders to attempt delete: {0}" -f $folderPaths.Count)

$foldersDeleted = 0
foreach ($fp in $folderPaths) {
  # Keep folder if any local file lives under it
  $hasLocalUnder = $false
  foreach ($k in $localMap.Keys) {
    if ($k.StartsWith($fp + "/")) { $hasLocalUnder = $true; break }
  }
  if ($hasLocalUnder) { continue }

  $folderId = $remoteFolders[$fp].id
  $delFolderUri = "https://graph.microsoft.com/v1.0/drives/$driveId/items/$folderId"

  try {
    Invoke-Graph -Method DELETE -Uri $delFolderUri -Token $token | Out-Null
    $foldersDeleted++
    if (($foldersDeleted % 25) -eq 0) { Write-Host "Deleted folders $foldersDeleted..." }
  } catch {
    # Likely not empty or cannot delete
    Write-Host "Skipped folder delete (likely not empty): $fp"
  }
}
Write-Host "Folders deleted: $foldersDeleted"

# Cleanup temp directory if it was created
if ($tempDir -and (Test-Path $tempDir)) {
  Write-Host "Cleaning up temporary files..."
  Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "=== Mirror complete ==="
