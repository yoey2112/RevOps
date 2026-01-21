# DocGen Pipeline Variables

This pipeline supports both legacy and simplified variable names. Configure these in your Azure DevOps variable group.

## Required
- REPO_ROOT: Absolute path of the repo working directory
- ADO_PROJECT_NAME: Azure DevOps project name
- ADO_REPO_NAME: Repository name
- ADO_DEFAULT_BRANCH: Default branch (e.g., `main`)
- DOC_BRANCH_PREFIX: Branch prefix for DocGen runs (e.g., `docs/nightly`)

## Confidence and Allowlist
- DOC_CONFIDENCE_THRESHOLD or CONFIDENCE_THRESHOLD: e.g., `0.80`
- DOC_DEVCORE_SOLUTIONS or DEVCORE_SOLUTIONS: Comma-separated solution names or patterns
  - Examples: `revopstables,revopsflows,revopsplugins` (exact/prefix)
  - Wildcards also supported: `revops*`, `revopsflows_*`

## Dataverse (Production)
- DV_ORG_URL: e.g., `https://sherweb-prod.crm3.dynamics.com`
- DV_TENANT_ID: Azure AD tenant GUID
- DV_CLIENT_ID: App registration client ID
- DV_CLIENT_SECRET: Client secret
- DV_API_VERSION: e.g., `9.2` (used as `.../api/data/v9.2`)

## Dataverse (DevCore)
- DV_DEVCORE_ORG_URL: e.g., `https://sherweb-dev.crm3.dynamics.com`
- Optional overrides (if omitted, Prod values are used):
  - DV_DEVCORE_TENANT_ID
  - DV_DEVCORE_CLIENT_ID
  - DV_DEVCORE_CLIENT_SECRET
  - DV_DEVCORE_API_VERSION

## Notes
- If only `DV_DEVCORE_ORG_URL` is provided, the pipeline uses Production Tenant/Client/Secret/API version for DevCore.
- Allowlist patterns without wildcards match exact solution names and prefix variations (e.g., `revopsflows` will match `revopsflows_*`).
