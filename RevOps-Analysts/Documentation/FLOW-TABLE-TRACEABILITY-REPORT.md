# Flow-Table Traceability Report
**Date**: 2025-12-15  
**Agent**: Documentation Traceability Agent  
**Status**: ✅ COMPLETED

---

## Executive Summary

Successfully established **bidirectional traceability** between 86 Power Automate flows and 45 Dataverse tables by:
1. Extracting table references from flow documentation and schemas
2. Creating "Tables Touched" sections in Flow READMEs
3. Creating/updating "Used by Flows" sections in Table READMEs
4. Auto-creating stub documentation for 41 previously undocumented tables

All traceability links use relative paths and are maintained within AI-marked sections for safe, idempotent updates.

---

## Processing Statistics

| Metric | Count | Notes |
|--------|-------|-------|
| **Flows Scanned** | 111 | All flow folders in Documentation/Flows |
| **Flows Updated** | 86 | Added/updated "Tables Touched" AUTO sections |
| **Flows Skipped** | 25 | No README.md or no table references found |
| **Tables Referenced** | 45 | Unique tables touched by flows |
| **Table READMEs Updated** | 4 | Existing tables: Account, Contact, Lead, Opportunity |
| **Table READMEs Created** | 41 | New stub documentation for auto-discovered tables |

---

## Traceability Model

### Flow → Table Links
Each flow's README.md contains:
```markdown
## Tables Touched
<!-- AI:BEGIN AUTO -->
- [TableName](../../Tables/TableName/README.md)
- [AnotherTable](../../Tables/AnotherTable/README.md)
<!-- AI:END AUTO -->
```

**Source of Truth**:
1. **Primary**: Existing "Tables Touched" section in Flow README (if present and populated)
2. **Fallback**: Parse flow.schema.json to extract entity names from:
   - Trigger inputs (Dataverse triggers)
   - Action inputs (Dataverse operations)

### Table → Flow Links
Each table's README.md contains:
```markdown
## Used by Flows
<!-- AI:BEGIN AUTO -->
- [flow-name](../../Flows/flow-name/README.md) - Trigger: Automated
- [another-flow](../../Flows/another-flow/README.md) - Trigger: Manual (Button)
<!-- AI:END AUTO -->
```

**Metadata Extraction**:
- Flow name and link
- Trigger type extracted from Flow README "Trigger" section (if available)

---

## Auto-Discovered Tables (41 Created)

The following table folders were auto-created as stubs when referenced by flows but not yet documented:

### Standard Dynamics Tables (9)
1. `activitypointers` - Activity tracking
2. `annotations` - Notes and attachments
3. `appointments` - Calendar appointments
4. `campaigns` - Marketing campaigns
5. `competitors` - Competitor records
6. `emails` - Email activities
7. `incidents` - Case/ticket records (logical name)
8. `phonecalls` - Phone call activities
9. `queueitems` - Queue item records

### System/Platform Tables (7)
10. `environmentvariabledefinitions` - Environment variable definitions
11. `environmentvariablevalues` - Environment variable values
12. `processstages` - Business process flow stages
13. `queues` - Service queues
14. `subjects` - Subject tree (case categorization)
15. `systemusers` - User records
16. `transactioncurrencies` - Currency records

### Custom RevOps Tables (16)
17. `revops_accountpotentialtechstacks` - Technology stack tracking
18. `revops_accountproductsummaries` - Product summary rollups
19. `revops_accountsolutionsummaries` - Solution summary rollups
20. `revops_competitortransferids` - CSP transfer competitor IDs
21. `revops_cumulusaccounts` - Cumulus billing system accounts
22. `revops_cumulusorganizations` - Cumulus organizations
23. `revops_cumulussignups` - Cumulus signup tracking
24. `revops_cumulususers` - Cumulus user records
25. `revops_domains` - Domain tracking
26. `revops_opportunitysolutions` - Opportunity solution line items
27. `revops_platformsettingses` - Platform configuration settings
28. `revops_services` - Service catalog
29. `revops_solutionproviders` - Solution provider records
30. `revops_transfers` - CSP transfer records

### Marketing/Events Tables (9)
33. `msdyn_customerfeedbacksurveyresponses` - Survey responses
34. `msdyn_ocliveworkitems` - Omnichannel work items
35. `msdyn_regions` - Territory regions
36. `msdynmkt_createdentitylinks` - Marketing entity links
37. `msdynmkt_emails` - Marketing emails
38. `msdynmkt_marketingfieldsubmissions` - Marketing field submissions
39. `msdynmkt_marketingformsubmissions` - Marketing form submissions
40. `msdynmkt_marketingforms` - Marketing forms
41. `msevtmgt_events` - Event management events
42. `msevtmgt_eventregistrations` - Event registrations
43. `msfp_surveyresponses` - Forms Pro survey responses

---

## Flows Requiring Schema Fallback (24)

These flows had no "Tables Touched" section in their README, so tables were extracted from flow.schema.json:

1. account-backfillchannelrelationship
2. account-setterritoryonaccount
3. attachfiletoasana
4. bulkresolvecases
5. commitmentagreementform
6. createworkitem-approveenablemailbox
7. enrichaccount-manual
8. events-scannedimportconnectiontoeventandmore
9. gtwwebinariscreated
10. incompletecart
11. lead-checkparentaccountrelationshipfortradeshowlea
12. lead-extractdomainfromemail
13. lead-resolveaccountbydomain
14. lead-resolvecontactbyemail
15. lead-setterritoryonlead
16. organizationcreatedordeletedincumulus
17. p2pautomation
18. revopschangelog
19. selectorgsfromcumuluswhereclientuniquename
20. updatelastinteraction-email
21. updatelastinteraction-note
22. updatelastinteraction-portalcomment
23. veeam-contractrequest
24. vmware-contractrequest

**Action Taken**: 
- Extracted tables from schema
- Added "Tables Touched" AUTO section to README
- Marked with note: "*Derived from flow.schema.json*"

---

## Table Name Normalization

Table names found in flows were mapped to actual table folder names using:

### Exact Match (Case-Insensitive)
- Direct folder name match under `Documentation/Tables/`

### Logical Name Mapping
Standard Dynamics logical names → Display names:
- `incident` → `Case`
- `account` → `Account`
- `contact` → `Contact`
- `lead` → `Lead`
- `opportunity` → `Opportunity`
- `competitor` → `Competitor`

### Pluralization Handling
- `accounts` → `Account`
- `contacts` → `Contact`
- `leads` → `Lead`
- `opportunities` → `Opportunity`

### Unmapped Tables
41 tables had no existing folder and were auto-created (see list above)

---

## Quality Compliance

### ✅ Governance Rules Followed
- Only modified content within `<!-- AI:BEGIN AUTO -->` markers
- No deletion of human-authored content
- No folder renaming
- Preserved existing README structure
- Used relative links (../../Tables/..., ../../Flows/...)

### ✅ Idempotent Updates
- Running script multiple times produces identical results
- Alphabetized lists for consistency
- Removed duplicates
- Stable link format

### ✅ Fact-Based Only
- Tables extracted from actual flow.schema.json
- Trigger types extracted from actual Flow READMEs
- No invented business logic
- Stubs clearly marked as "TBD" and "Missing Info / Needs Review"

---

## Example Traceability Links

### Flow → Table
**account-created-in-cumulus/README.md**:
```markdown
## Tables Touched
<!-- AI:BEGIN AUTO -->
- [Account](../../Tables/Account/README.md)
- [Contact](../../Tables/Contact/README.md)
- [Lead](../../Tables/Lead/README.md)
- [Opportunity](../../Tables/Opportunity/README.md)
- [revops_cumulusaccounts](../../Tables/revops_cumulusaccounts/README.md)
- [revops_cumulussignups](../../Tables/revops_cumulussignups/README.md)
- [revops_cumulususers](../../Tables/revops_cumulususers/README.md)
- [revops_domains](../../Tables/revops_domains/README.md)
- [systemusers](../../Tables/systemusers/README.md)
<!-- AI:END AUTO -->
```

### Table → Flows
**Account/README.md**:
```markdown
## Used by Flows
<!-- AI:BEGIN AUTO -->
- [accountcreatedincumulus](../../Flows/accountcreatedincumulus/README.md) - Trigger: Request (Http)
- [account-created-in-cumulus](../../Flows/account-created-in-cumulus/README.md) - Trigger: Automated (Service Bus message or HTTP webhook)
- [accounts-manual-fixgenericdomainsformat](../../Flows/accounts-manual-fixgenericdomainsformat/README.md) - Trigger: Request (Button)
- [dailytierupdatepermrr](../../Flows/dailytierupdatepermrr/README.md) - Trigger: Recurrence
- [enrichaccount-oncreate](../../Flows/enrichaccount-oncreate/README.md) - Trigger: OpenApiConnectionWebhook
- [enrichaccount-scheduled](../../Flows/enrichaccount-scheduled/README.md) - Trigger: Recurrence
<!-- AI:END AUTO -->
```

---

## Stub Table README Template

Auto-created table stubs follow this structure:

```markdown
# TableName

## Purpose
TBD - This table was auto-discovered from flow references.

## Missing Info / Needs Review
- Business purpose and context
- Key columns and relationships
- Who owns/maintains this table

## Used by Flows
<!-- AI:BEGIN AUTO -->
- [flow-name](../../Flows/flow-name/README.md) - Trigger: Type
<!-- AI:END AUTO -->

---
Last Updated By: AI (Traceability Agent)
Date: 2025-12-15
```

**Next Steps for Stubs**:
Human reviewers should:
1. Fill in Purpose section
2. Add Columns.md and Relationships.md if needed
3. Document business context
4. Remove "Missing Info / Needs Review" section when complete

---

## Automation Script

**Location**: `Documentation/_scripts/Build-FlowTableTraceability.ps1`

**Capabilities**:
- Scans all flow folders for README.md
- Extracts tables from README or falls back to schema
- Maps table names to folder names (case-insensitive, logical name handling)
- Creates stub table READMEs for unmapped tables
- Updates Flow READMEs with "Tables Touched" AUTO section
- Updates Table READMEs with "Used by Flows" AUTO section
- Idempotent: can be re-run safely

**Usage**:
```powershell
cd Documentation\_scripts
.\Build-FlowTableTraceability.ps1
```

---

## Known Limitations

### 1. Dynamic Table References
- Cannot detect tables accessed via dynamic expressions or variables
- Only captures hardcoded entity names in schema

### 2. Nested Actions
- Tables used inside scopes/loops/conditions are captured
- But nested complexity is not reflected in traceability links

### 3. Trigger Metadata
- Trigger type extraction depends on Flow README having "Type" field
- Missing trigger types are omitted rather than guessed

### 4. External Systems
- External API endpoints or non-Dataverse connections not tracked
- Only Dataverse table references captured

---

## Next Steps

### Immediate
1. **Review stub tables**: Prioritize filling in Purpose sections for custom `revops_` tables
2. **Add Columns.md**: For tables with many flows, document key columns
3. **Validate links**: Spot-check that all relative links work correctly

### Short-term
1. **Diagram generation**: Create Mermaid diagrams showing flow → table relationships
2. **Reverse engineer**: Use table references to infer business processes
3. **Security mapping**: Link security roles to tables and flows

### Long-term
1. **Automated refresh**: Run traceability script on every solution export
2. **Impact analysis**: Show which flows break when table schema changes
3. **Dependency graph**: Visualize entire flow-table network

---

## Impact Analysis

### Documentation Coverage
- **Before**: 53 tables documented
- **After**: 94 tables documented (+77% increase)
- **Total Documentation Files**: ~805 (was ~680)

### Traceability Network
- **Flow → Table links**: 86 flows × avg 2-3 tables = ~200 links
- **Table → Flow links**: 45 tables × avg 1-5 flows = ~150 links
- **Total bidirectional references**: ~350+ relationships documented

### Discoverability
- Developers can now answer:
  - "Which flows will break if I modify this table?"
  - "Which tables does this flow touch?"
  - "What flows use this table?"
- Reduces tribal knowledge dependency

---

## Script Location & Reusability

**Script**: `Documentation/_scripts/Build-FlowTableTraceability.ps1`

**Idempotent**: ✅ Can be re-run safely  
**Destructive**: ❌ Never deletes content  
**Safe**: ✅ Only modifies AI-marked sections  

**Re-run Scenarios**:
- After adding new flows
- After updating flow.schema.json exports
- After renaming table folders
- To refresh trigger metadata

---

**Generated by**: AI Documentation Traceability Agent  
**Methodology**: Schema-first table extraction + bidirectional link maintenance  
**Compliance**: Full adherence to Documentation/README.md governance rules
