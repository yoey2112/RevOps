param(
  [Parameter(Mandatory=$true)][string]$FilePath,
  [Parameter(Mandatory=$true)][string]$DocsRoot
)

<#
.SYNOPSIS
  Transforms relative markdown links to library-relative paths for SharePoint/Copilot.

.DESCRIPTION
  Converts Git-style relative links (../folder/file.md) to library-relative paths (_graph/dependencies.json).
  This ensures cross-references work in SharePoint while remaining token-efficient for Copilot agents.

.EXAMPLE
  ./Transform-MarkdownLinks.ps1 -FilePath "temp/README.md" -DocsRoot "AIDocumentation"
#>

$ErrorActionPreference = 'Stop'

function ConvertTo-SharePointPath {
  param(
    [string]$RelativePath,
    [string]$CurrentFileDir
  )
  
  # Handle absolute paths from root (starting with /)
  if ($RelativePath.StartsWith('/')) {
    # Already absolute from docs root, just clean it up
    $RelativePath = $RelativePath.TrimStart('/')
    $resolved = $RelativePath
  }
  # Handle relative paths
  else {
    # Build the path segments from current directory
    $currentParts = if ($CurrentFileDir) { $CurrentFileDir -split '/' } else { @() }
    $relativeParts = $RelativePath -split '/'
    
    # Resolve .. and . in the path
    $resolvedParts = New-Object System.Collections.ArrayList
    foreach ($part in $currentParts) {
      [void]$resolvedParts.Add($part)
    }
    
    foreach ($part in $relativeParts) {
      if ($part -eq '..') {
        if ($resolvedParts.Count -gt 0) {
          $resolvedParts.RemoveAt($resolvedParts.Count - 1)
        }
      }
      elseif ($part -eq '.' -or $part -eq '') {
        # Skip current directory and empty parts
      }
      else {
        [void]$resolvedParts.Add($part)
      }
    }
    
    $resolved = $resolvedParts -join '/'
  }
  
  # Return library-relative path (no encoding, no base URL)
  # This is optimal for Copilot: concise, readable, and functional in SharePoint context
  return $resolved
}

function Transform-MarkdownLinks {
  param(
    [string]$Content,
    [string]$CurrentFileDir
  )
  
  # Regex pattern for markdown links: [text](url)
  # Matches relative links only (not http/https)
  $pattern = '\[([^\]]+)\]\((?!http)([^\)]+)\)'
  
  $transformed = [regex]::Replace($Content, $pattern, {
    param($match)
    
    $linkText = $match.Groups[1].Value
    $linkUrl = $match.Groups[2].Value
    
    # Remove anchor tags (SharePoint and Copilot don't handle them well)
    $linkUrl = $linkUrl -replace '#.*$', ''
    
    # Skip empty links
    if ([string]::IsNullOrWhiteSpace($linkUrl)) {
      return $match.Value
    }
    
    # Skip special protocols (flow:, plugin:, etc.)
    if ($linkUrl -match '^[a-z]+:') {
      return $match.Value
    }
    
    # Convert to library-relative path (optimal for Copilot in SharePoint)
    try {
      $sharePointPath = ConvertTo-SharePointPath -RelativePath $linkUrl -CurrentFileDir $CurrentFileDir
      return "[$linkText]($sharePointPath)"
    }
    catch {
      Write-Warning "Failed to convert link: $linkUrl in file context $CurrentFileDir. Error: $_"
      return $match.Value
    }
  })
  
  return $transformed
}

# Main execution
if (!(Test-Path -LiteralPath $FilePath)) {
  throw "File not found: $FilePath"
}

# Get the directory of the current file relative to DocsRoot
$fileFullPath = [System.IO.Path]::GetFullPath($FilePath)
$docsRootFull = [System.IO.Path]::GetFullPath($DocsRoot)
$currentFileDir = [System.IO.Path]::GetDirectoryName($fileFullPath)

# Make currentFileDir relative to DocsRoot for proper resolution
if ($currentFileDir.StartsWith($docsRootFull)) {
  $relativeDir = $currentFileDir.Substring($docsRootFull.Length).TrimStart('\', '/')
}
else {
  $relativeDir = ""
}

# Read file content
$content = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)

# Transform links to library-relative paths
$transformed = Transform-MarkdownLinks -Content $content -CurrentFileDir $relativeDir

# Write back transformed content
[System.IO.File]::WriteAllText($FilePath, $transformed, [System.Text.Encoding]::UTF8)

Write-Host "Transformed links in: $FilePath"
