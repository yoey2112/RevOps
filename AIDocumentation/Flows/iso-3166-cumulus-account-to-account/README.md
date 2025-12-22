# ISO 3166 Cumulus Account to Account

## Overview
This flow synchronizes geographic data (country and subdivision) from Cumulus Accounts to their parent Dynamics 365 Account records by identifying the highest MRR (Monthly Recurring Revenue) Cumulus Account and copying its ISO 3166 country information to the parent Account.

## Business Impact
Ensures that Account records in Dynamics 365 have accurate geographic data for reporting, segmentation, and regional sales routing. By using the highest MRR Cumulus Account as the source of truth, the flow prioritizes the most valuable customer organization's location data.

**Key Users**:
- Sales teams (for territory management)
- Marketing teams (for regional campaigns)
- Support teams (for timezone-aware case routing)
- Reporting & Analytics (for regional revenue analysis)

## Trigger
- **Type**: Scheduled (or manual for ad-hoc synchronization)
- **Condition**: Runs periodically to update Account records with latest country data from Cumulus Accounts
- **Frequency**: Likely scheduled (hourly, daily, or on-demand)

## High-Level Logic
1. Initialize caching variables for country and subdivision lookups (performance optimization)
2. Retrieve batch of Accounts with associated Cumulus Accounts (up to 10 per run)
3. For each Account:
   - Get the Cumulus Account with highest MRR
   - Extract ISO 3166 country code (Alpha-2 format, e.g., "US", "CA", "GB")
   - Look up corresponding Dynamics country record (with caching)
   - Update Account's `revops_country` field with country GUID
4. Cache country lookups to avoid redundant queries in same batch

## Key Actions
- **Initialize Variables**: Create `varCountryCache` and `varSubdivisionCache` for in-memory lookups
- **List Accounts**: Retrieve Accounts with Cumulus Accounts
- **Apply to Each**: Loop through each Account
- **Get Cumulus Account**: Fetch highest MRR Cumulus Account for current Account
- **Condition Checks**: Verify Cumulus Account found, check cache, verify country record found
- **Cache Country**: Add country GUID to cache using `addProperty()` expression
- **Update Account**: Bind country lookup field to Dynamics country record

## Error Handling
- **Conditional Skipping**: If no Cumulus Account found, skip to next Account (no error thrown)
- **Null Handling**: If country not found in Dynamics, continue without updating
- **Batch Limitation**: Processes only 10 Accounts per run to avoid timeout (pagination may be needed for full sync)

## Dependencies
- **Tables**: 
  - `account` (parent Account record)
  - `revops_cumulusaccount` (child Cumulus Account with MRR and ISO codes)
  - `revops_countries` (lookup table for country GUIDs by ISO Alpha-2 code)
  - `revops_stateorprovince` (subdivision table, currently unused)
- **Connections**: 
  - Microsoft Dataverse (2-3 connection references)
- **Other Flows**: 
  - May be triggered by **account-created-in-cumulus** flow when new Accounts are created
  - Used by **Case** table automation (see `Tables/Case/README.md`)

## Documentation Files
- `flow.logic.md`: **âœ… Exists** as `ISO3166-cumulus-account-to-account-summary.md`
- `flow.schema.json`: **âœ… Exists** as `ISO3166CumulusAccounttoAccount-Manual-65AB024B-5C7F-F011-B4CC-7C1E52409AFE.json`
- `diagram.drawio`: **âœ… Exists** as `ISO3166CumulusAccounttoAccount-Manual-65AB024B-5C7F-F011-B4CC-7C1E52409AFE.drawio`

## Change History
- **2025-12-15**: Initial documentation created, files normalized to kebab-case folder structure
- **2025-12-03**: Original documentation created as summary markdown

## Known Issues / Limitations
- **Batch Size**: Limited to 10 Accounts per run (`$top=10`), may require scheduled runs to cover all Accounts
- **Subdivision Unused**: `varSubdivisionCache` is initialized but not used (future enhancement?)
- **No Retry**: If country lookup fails, Account is skipped without retry
- **Highest MRR Only**: Only the highest MRR Cumulus Account's country is used; other Cumulus Accounts ignored

## Performance Optimization
This flow implements **in-memory caching** to significantly improve performance:

### Caching Strategy
- **Country Cache**: Stores country GUIDs indexed by ISO Alpha-2 code
- **Cache Scope**: Persists only for the current flow run (10 Accounts)
- **Cache Hit**: Avoids redundant Dataverse queries when multiple Accounts share same country
- **Example**: If 5 Accounts all have US-based Cumulus Accounts, only 1 query to `revops_countries` is made

### Cache Implementation
```javascript
// Check if country code already cached
varCountryCache?['US']

// If not cached, query Dataverse
// Then add to cache:
addProperty(varCountryCache, 'US', '<country-guid>')
```

---

**Last Updated**: December 15, 2025  
**Owner**: RevOps Development Team



<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: Request (Button)

## Tables Touched
<!-- AI:BEGIN AUTO -->
- [Account](../../Tables/Account/README.md)
<!-- AI:END AUTO -->
- accounts

## Connectors Used
- commondataserviceforapps
- commondataserviceforapps

## Statistics
- Total Actions: 4
- Trigger Type: Request

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->

