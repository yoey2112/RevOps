# RevOps Pipelines

This directory contains pipeline scripts used by the single active Azure DevOps pipeline.

## Active Pipeline

- [../azure-pipelines.yml](../azure-pipelines.yml)

This pipeline performs two stages:
1. **DocGeneration** (Ubuntu): Generates documentation under `AIDocumentation/`
2. **SharePointSync** (Windows): Mirrors `AIDocumentation/` to SharePoint

Note: legacy pipeline YAMLs in this folder were removed to avoid confusion.

## Scripts

All pipeline scripts are located in `./scripts/`:

- **Mirror-AIDocumentation-ToSharePoint.ps1** - Syncs AIDocumentation folder to SharePoint
  - Automatically transforms relative markdown links to library-relative paths
  - Optimized for Copilot agents using SharePoint as knowledge source
  - Creates temporary transformed copies before upload
  - Handles path encoding for special characters
- **Transform-MarkdownLinks.ps1** - Converts Git-style relative links to library-relative paths
  - Called automatically by Mirror script
  - Transforms `../_graph/dependencies.json` → `_graph/dependencies.json`
  - Preserves special protocol links (flow:, plugin:, etc.)
  - Removes anchor tags (not well-supported in SharePoint/Copilot)
- **Run-DocUpdate.ps1** - Main DocGen orchestrator
- **DocGen/** - DocGen module and schemas

## Link Transformation for Copilot

The SharePoint sync process automatically transforms relative markdown links to be **Copilot-optimized**:

**Problem:** 
- Git relative links like `../_graph/dependencies.json` don't work in SharePoint
- Full URLs like `https://sharepoint.com/.../file.md` work but waste tokens for Copilot agents

**Solution:** Transform to **library-relative paths** that are both functional and token-efficient.

**Example transformations:**
- `[Dependencies](../_graph/dependencies.json)` → `[Dependencies](_graph/dependencies.json)`
- `[Flows](../flows/README.md)` → `[Flows](flows/README.md)`
- `[/RUNS/](../RUNS/)` → `[/RUNS/](RUNS/)`

**Benefits for Copilot:**
- ✅ **Token-efficient**: Short paths save context window space
- ✅ **Readable**: Clean paths like `_graph/dependencies.json` vs encoded URLs
- ✅ **Functional**: Works in SharePoint document library context
- ✅ **Contextual**: Path structure conveys document relationships

**What's preserved:**
- Special protocol links (flow:, plugin:) remain unchanged
- External links (http://, https://) remain unchanged

**What's removed:**
- Anchor tags (#section) - not supported well in SharePoint/Copilot context

## Configuration

### Required Variable Groups

- **DocGen-Prod**: DocGen and Dataverse connection settings
- **Service Principal RevOps-ADO-DocSync-1**: SharePoint service principal credentials

### Environment Variables

Refer to [../azure-pipelines.yml](../azure-pipelines.yml) for the environment variables required at runtime.
