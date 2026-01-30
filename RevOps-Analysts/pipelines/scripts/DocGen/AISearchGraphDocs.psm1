function Export-AISearchGraphDocs {
    param (
        [Parameter(Mandatory)]
        [object]$Context
    )
    $outputRoot = Join-Path $Context.AIDocsRoot 'AIDocsSearch'
    $docsRoot = Join-Path $outputRoot 'docs'
    $graphRoot = Join-Path $outputRoot 'graph'
    $registryRoot = Join-Path $outputRoot 'registry'
    foreach ($dir in @($outputRoot, $docsRoot, $graphRoot, $registryRoot)) {
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    }

    $allAssets = @()
    $allEdges = @()
    $allRegistry = @()

    # Example: process tables
    foreach ($table in $Context.tables_enriched) {
        $doc = Get-AISearchAssetDoc -Asset $table -AssetType 'table' -Env $Context.ProjectName
        $typeDir = Join-Path $docsRoot 'table'
        if (-not (Test-Path $typeDir)) { New-Item -ItemType Directory -Path $typeDir -Force | Out-Null }
        $docPath = Join-Path $typeDir ("$($doc.id).json")
        $doc | ConvertTo-Json -Depth 10 | Set-Content $docPath -Encoding UTF8
        $allRegistry += ,(Get-AISearchRegistryEntry -Doc $doc)
        foreach ($rel in $doc.relations) {
            $allEdges += ,(Get-AISearchEdgeList -FromId $doc.id -Relation $rel)
        }
        $allAssets += ,$doc
    }
    # TODO: Repeat for flows, plugins, etc.

    # Write edge list
    $edgesPath = Join-Path $graphRoot 'edges.jsonl'
    $allEdges | ForEach-Object { $_ | ConvertTo-Json -Depth 5 } | Set-Content $edgesPath -Encoding UTF8

    # Write registry
    $registryPath = Join-Path $registryRoot 'assets.jsonl'
    $allRegistry | ForEach-Object { $_ | ConvertTo-Json -Depth 5 } | Set-Content $registryPath -Encoding UTF8
}

function Get-AISearchAssetDoc {
    param (
        [Parameter(Mandatory)]$Asset,
        [Parameter(Mandatory)][string]$AssetType,
        [Parameter(Mandatory)][string]$Env
    )
    $doc = @{
        id = $Asset.Id
        asset_type = $AssetType
        key = $Asset.Key
        name = $Asset.Name
        env = $Env
        solution = $Asset.Solution
        tags = $Asset.Tags
        criticality = $Asset.Criticality
        text = $Asset.Brief
        facts = $Asset.Facts
        relations = $Asset.Relations
        refs = @{
            fingerprint = $Asset.Fingerprint
            generated_utc = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
            source = $Asset.Source
        }
    }
    return $doc
}

function Get-AISearchEdgeList {
    param (
        [Parameter(Mandatory)]$FromId,
        [Parameter(Mandatory)]$Relation
    )
    return @{
        from = $FromId
        rel = $Relation.rel
        to = $Relation.to
        strength = $Relation.strength
    }
}

function Get-AISearchRegistryEntry {
    param (
        [Parameter(Mandatory)]$Doc
    )
    return @{
        id = $Doc.id
        asset_type = $Doc.asset_type
        name = $Doc.name
        key = $Doc.key
        primary_path = "AIDocsSearch/docs/$($Doc.asset_type)/$($Doc.id).json"
        tags = $Doc.tags
        solution = $Doc.solution
        criticality = $Doc.criticality
    }
}
