# Multi-Domain Account Matching Solution

**Proposal Date**: 2025-12-16  
**Author**: RevOps Analysts Team  
**Status**: Proposed Architecture

---

## Executive Summary

**Current Problem**: Accounts are matched to Leads/Contacts using a **1:1 domain relationship** stored on the Account record (`revops_domain` field). This breaks when:
- Companies have multiple domains (e.g., `sherweb.com`, `sherweb.ca`, `sherweb.fr`)
- Acquisitions/mergers create domain sprawl
- Regional offices use different domains
- Contacts use different email domains within the same organization

**Proposed Solution**: Implement a **many-to-many relationship** between Accounts and Domains using the `revops_domains` table as a junction table. This enables:
- One Account → Many Domains
- One Domain → One Account (enforced via unique constraint)
- Centralized domain management and validation
- Accurate Lead/Contact → Account matching across domain variations

**Impact**: 
- **Phase 1 Flows Modified**: 7 flows (domain extraction, account matching, domain creation)
- **Phase 2 Plugins Created**: 2-3 plugins for high-frequency operations
- **New Components**: Domain management UI, migration scripts, validation rules

---

## Current Architecture Analysis

### Existing Schema

#### Account Table
- **Current Field**: `revops_domain` (Single Line of Text)
- **Limitation**: Can only store ONE domain per account
- **Usage**: Direct field match in FetchXML queries

#### revops_domains Table
**Current Purpose**: Domain registry tracking known domains
**Current Fields** (inferred from flow analysis):
- `revops_domain` (text) - The domain name
- `revops_domaintype` (optionset) - Corporate vs Generic (gmail, hotmail, etc.)
- Additional metadata fields (TBD - needs schema review)

**Current Relationship**: None to Account (operates independently)

#### Contact/Lead Tables
- **Field**: `revops_domain` (Single Line of Text)
- **Populated By**: Domain extraction flows (split email by '@')
- **Used For**: FetchXML matching against Account.revops_domain

### Current Domain-Related Flows

| Flow Name | Trigger | Current Logic | Status |
|-----------|---------|---------------|--------|
| **contact-extractdomainfromemail** | Contact Create/Update | Extract domain from email → set Contact.revops_domain | Active |
| **lead-extractdomainfromemail** | Lead Create/Update | Extract domain from email → set Lead.revops_domain | Active |
| **contact-resolveaccountbydomain** | Contact Create/Update | FetchXML: find Account where revops_domain = Contact.revops_domain | Active |
| **lead-resolveaccountbydomain** | Lead Create/Update | FetchXML: find Account where revops_domain = Lead.revops_domain | Active |
| **fillparentaccountofcumulusaccount** | Scheduled | Match Cumulus accounts, create domains, handle generic domains | Active |
| **linkcumulusaccountstoparentaccounts** | Manual | Batch link Cumulus accounts by domain | Active |
| **accounts-manual-fixgenericdomainsformat** | Manual | Fix generic domain format to emailprefix.domain.com | Active |

---

## Proposed Architecture

### Schema Changes

#### 1. Modify `revops_domains` Table (Junction Table)
**Add New Fields**:
- `revops_accountid` (Lookup to Account) - **Required**
- `revops_isprimary` (Boolean) - Designates primary domain for the account
- `revops_isverified` (Boolean) - Domain ownership verified
- `revops_createdsource` (Optionset) - How domain was added (Manual, Flow, Cumulus, Import)
- `revops_notes` (Multiline Text) - Notes about this domain association

**Keep Existing Fields**:
- `revops_domain` (Single Line of Text) - **Unique constraint**
- `revops_domaintype` (Optionset) - Corporate | Generic | Franchise

**Add Relationships**:
- **1:N from Account to revops_domains** (`revops_account_domains`)
  - Cascade Delete: Restrict (cannot delete account with domains)
  - Cascade Share/Assign: Cascade

**Add Validation**:
- **Unique Constraint**: `revops_domain` field must be unique across all records
- **Business Rule**: Each Account must have exactly one `revops_isprimary = true` domain
- **Business Rule**: Generic domains cannot be marked as primary

#### 2. Account Table Changes
**Deprecate (Phase 2)**:
- `revops_domain` field → Mark as deprecated, keep for backward compatibility during migration

**Add Calculated Field** (Optional):
- `revops_primarydomain` (Calculated) - Rollup from revops_domains where isprimary = true
- Use for reporting/views during transition period

#### 3. Contact/Lead Tables
**No Schema Changes** - Keep existing `revops_domain` field for extraction

---

## Solution Components

### Component 1: Domain Extraction (Enhanced)

**Technology**: Keep as Flows (simple string parsing, high frequency)

**Flow**: `contact-extractdomainfromemail` & `lead-extractdomainfromemail`

**Enhanced Logic**:
```
1. Extract domain from emailaddress1 (split by '@')
2. Set Contact/Lead.revops_domain = extracted domain
3. [NEW] Query revops_domains table for matching domain
4. [NEW] If found AND has Account lookup:
   - Validate domain type
   - If Generic domain → apply emailprefix.domain.com format
   - If Corporate domain → use as-is
5. [UNCHANGED] Trigger downstream matching flows
```

**Changes Required**:
- Add step: Query `revops_domains` by domain name
- Add conditional: Check for Generic domain type
- Add transformation: Apply generic domain format if needed

---

### Component 2: Account Matching (Enhanced)

**Technology**: Plugin (Phase 1) or Flow (initial implementation)

**Plugin**: `AccountDomainMatcher` 
**Triggers**: Lead/Contact Create or Update (revops_domain field change)
**Stage**: Post-Operation (Async)

**Enhanced Logic**:
```
1. Get Lead/Contact.revops_domain value
2. Query revops_domains WHERE revops_domain = {value}
3. Evaluate results:
   
   CASE: No domain found
   → No action (account will not be matched)
   
   CASE: One domain found with Account lookup
   → Get associated Account
   → Check if already linked to same account
   → If not linked: Update Lead/Contact with parentaccountid/parentcustomerid
   → Set revops_existingaccount = true
   
   CASE: Multiple domains found (should never happen - unique constraint)
   → Log error
   → Create alert/work item
   → No action on Lead/Contact
   
4. Handle Generic Domains:
   → If domain type = Generic
   → Use emailprefix.domain.com format for matching
   → Query again with transformed domain
```

**Affected Flows**:
- **lead-resolveaccountbydomain** - REPLACE with plugin or enhance
- **contact-resolveaccountbydomain** - REPLACE with plugin or enhance

**Flow Changes** (if keeping as flows):
```diff
- FetchXML: account WHERE revops_domain eq '{value}'
+ FetchXML: revops_domains WHERE revops_domain eq '{value}'
+ Get related Account via lookup
+ Validate Account exists and is active
```

---

### Component 3: Domain Management (New)

**Technology**: Flow (manual/scheduled) + Power Apps Canvas

#### 3A. Domain Registration Flow
**Flow**: `domain-registerdomaintoaccount` (New)
**Trigger**: Manual (Button) or Automated (Cumulus import)

**Logic**:
```
1. Input: Domain name, Account ID, Is Primary, Domain Type
2. Validate:
   - Account exists and is active
   - Domain format is valid (regex: ^[a-z0-9\-\.]+\.[a-z]{2,}$)
   - If Generic type → validate against known generic list
3. Check for existing domain in revops_domains:
   - If exists → check if linked to different account
   - If conflict → return error with account name
   - If same account → update metadata
4. Create revops_domains record:
   - Set revops_domain = {domain}
   - Set revops_accountid = {account}
   - Set revops_isprimary = {isprimary}
   - Set revops_domaintype = {type}
   - Set revops_createdsource = Manual/Flow/Cumulus
5. If isPrimary = true:
   - Find existing primary domains for this account
   - Set revops_isprimary = false on others
6. Return success with domain ID
```

#### 3B. Domain Validation Flow
**Flow**: `domain-validateownership` (New - Optional)
**Trigger**: Manual or Scheduled
**Logic**:
```
1. Get domains where revops_isverified = false
2. For each domain:
   - Perform DNS TXT record check (if configured)
   - Or send verification email to admin@{domain}
   - Update revops_isverified based on response
3. Log results
```

#### 3C. Domain Cleanup Flow
**Flow**: `domain-findorphaneddomains` (New)
**Trigger**: Scheduled (weekly)
**Logic**:
```
1. Find Contact/Lead domains not in revops_domains table
2. Group by domain and count occurrences
3. For domains with > threshold (e.g., 5 occurrences):
   - Attempt to match to existing Account
   - If no match → create work item for review
   - Suggest potential Account matches based on:
     - Company name similarity
     - Contact/Lead owner
     - Territory/country alignment
```

---

### Component 4: Cumulus Integration (Enhanced)

**Affected Flows**:
- `fillparentaccountofcumulusaccount`
- `linkcumulusaccountstoparentaccounts`
- `account-created-in-cumulus`
- `accountcreatedincumulus`

**Enhanced Logic for `fillparentaccountofcumulusaccount`**:
```diff
Current:
1. Get Cumulus Accounts where revops_account = null
2. For each: Query Account WHERE revops_domain = CumulusAccount.revops_domain
3. If 1 match: Link Cumulus to Account
4. If >1 match: Check generic domain format
5. Check revops_domains table for duplicates → create work item if found

Proposed:
1. Get Cumulus Accounts where revops_account = null
2. For each: Query revops_domains WHERE revops_domain = CumulusAccount.revops_domain
3. If found:
   - Get associated Account from revops_accountid lookup
   - Link Cumulus Account to Account
4. If not found:
   - Create new revops_domains record
   - Link to Account (if Account already exists with different domain)
   - OR create Account + domain record (if new customer)
5. Handle Generic Domains:
   - Check revops_domaintype
   - If Generic: transform domain to emailprefix.domain.com
   - Query again with transformed domain
   - If multiple Accounts with same generic domain → flag for review
```

**Changes Required**:
```diff
Line 117: 
- "$filter": "statecode eq 0 and revops_domain eq '@{variables('DomainValue')}'"
+ Query revops_domains first, then get Account via lookup

Line 236:
- "item/revops_domain": "@variables('DomainValue')",
+ Create revops_domains record separately with Account lookup

Lines 475-601: Domain table CRUD operations
+ Update to use Account lookup instead of standalone domain records
+ Add isPrimary logic
+ Add validation for existing domain conflicts
```

---

### Component 5: Generic Domain Handling (Enhanced)

**Current Logic** (from `fillparentaccountofcumulusaccount`):
- Detects generic domains (gmail, hotmail, etc.)
- Transforms format: `user@gmail.com` → `user.gmail.com`
- Stores transformed value in Account.revops_domain

**Proposed Enhancement**:
1. Maintain **Generic Domain Master List** in revops_domains:
   - Create records for known generic domains (gmail.com, hotmail.com, outlook.com, etc.)
   - Set revops_domaintype = Generic
   - Set revops_accountid = NULL (not associated with any account)
   - Use as lookup table for validation

2. When creating domain for Account with generic email:
   - Check if base domain (e.g., gmail.com) exists in master list
   - If yes and type = Generic:
     - Apply transformation: emailprefix.domain.com
     - Create revops_domains record with transformed domain
     - Link to specific Account
   - If no: Treat as corporate domain

3. Add Business Rule:
   - If revops_domaintype = Generic AND revops_accountid != NULL
   - Then domain value MUST contain "." before base domain (enforces emailprefix.domain.com format)

---

## Migration Strategy

### Phase 1: Schema & Foundation (Week 1-2)

**Tasks**:
1. Create/modify `revops_domains` table schema:
   - Add Account lookup field
   - Add isPrimary, isVerified, createdSource fields
   - Add unique constraint on revops_domain field
2. Create generic domain master list:
   - Populate known generic domains (gmail, hotmail, yahoo, etc.)
   - Set type = Generic, accountid = NULL
3. Deploy domain registration flow (`domain-registerdomaintoaccount`)
4. Create Power Apps canvas app for domain management (optional)

**Validation**:
- Test domain creation manually
- Verify unique constraint works
- Validate isPrimary business rule

---

### Phase 2: Data Migration (Week 3-4)

**Migration Flow**: `migration-accountdomainstojunctiontable` (One-time)

**Logic**:
```
1. Get all Accounts WHERE revops_domain != NULL
2. For each Account:
   a. Check if domain already exists in revops_domains:
      - Query: WHERE revops_domain = Account.revops_domain
      
   b. If exists:
      - Check if already linked to THIS account
      - If YES: Skip (already migrated)
      - If NO (linked to different account):
         → Flag as CONFLICT
         → Log: Account A and Account B both claim domain X
         → Create work item for manual resolution
         → Skip automated migration
      
   c. If not exists:
      - Create new revops_domains record:
        * revops_domain = Account.revops_domain
        * revops_accountid = Account.accountid
        * revops_isprimary = true (first domain is primary)
        * revops_domaintype = Corporate (default, review later)
        * revops_createdsource = Migration
      
3. Generate migration report:
   - Total accounts processed
   - Domains created
   - Conflicts detected (manual review needed)
   - Accounts skipped (null domain)
```

**Post-Migration Validation**:
```sql
-- Check migration completeness
SELECT COUNT(*) FROM Account WHERE revops_domain IS NOT NULL
AND accountid NOT IN (
  SELECT revops_accountid FROM revops_domains WHERE revops_accountid IS NOT NULL
)
-- Should return 0 (all migrated) or only conflict accounts

-- Check for orphaned domains
SELECT COUNT(*) FROM revops_domains 
WHERE revops_accountid IS NULL 
AND revops_domaintype != 'Generic'
-- Should return 0 or very few (investigate)

-- Check primary domain counts
SELECT revops_accountid, COUNT(*) as PrimaryCount
FROM revops_domains
WHERE revops_isprimary = true
GROUP BY revops_accountid
HAVING COUNT(*) > 1
-- Should return 0 (only one primary per account)
```

---

### Phase 3: Flow Updates (Week 5-6)

**Update Existing Flows**:

#### 3A. Domain Extraction Flows (Minor Changes)
- `contact-extractdomainfromemail` - Add domain lookup validation
- `lead-extractdomainfromemail` - Add domain lookup validation

**Change Summary**: Add step to query revops_domains for validation/type checking

#### 3B. Account Matching Flows (Major Changes)
- `lead-resolveaccountbydomain` - Change FetchXML to query revops_domains → get Account
- `contact-resolveaccountbydomain` - Change FetchXML to query revops_domains → get Account

**Detailed Changes** (`lead-resolveaccountbydomain`):
```diff
Current FetchXML:
<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="account">
    <attribute name="name" />
    <attribute name="accountid" />
-   <filter type="and">
-     <condition attribute="revops_domain" operator="eq" value="{domain}" />
-     <condition attribute="statecode" operator="eq" value="0" />
-   </filter>
  </entity>
</fetch>

New FetchXML:
<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="revops_domain">
    <attribute name="revops_domainid" />
    <attribute name="revops_domain" />
    <attribute name="revops_accountid" />
    <attribute name="revops_domaintype" />
+   <filter type="and">
+     <condition attribute="revops_domain" operator="eq" value="{domain}" />
+     <condition attribute="statecode" operator="eq" value="0" />
+   </filter>
+   <link-entity name="account" from="accountid" to="revops_accountid" link-type="inner" alias="account">
+     <attribute name="name" />
+     <attribute name="accountid" />
+     <filter type="and">
+       <condition attribute="statecode" operator="eq" value="0" />
+     </filter>
+   </link-entity>
  </entity>
</fetch>

Post-Query Logic:
+ Get Account from linked entity: outputs('List_Domains')?['body/value'][0]?['account.accountid']
+ Validate Account exists (handle null case)
+ Check domain type for generic handling
```

#### 3C. Cumulus Integration Flows (Major Changes)
- `fillparentaccountofcumulusaccount` - Query domains table, create domain records
- `linkcumulusaccountstoparentaccounts` - Query domains table instead of Account.revops_domain
- `account-created-in-cumulus` - Add domain registration on Account creation
- `accountcreatedincumulus` - Add domain registration on Account creation

**See Component 4 above for detailed changes**

---

### Phase 4: Plugin Development (Week 7-8) [Optional]

**Convert to Plugins** (Performance optimization):

#### Plugin 1: `DomainExtractionPlugin`
**Replaces**: contact-extractdomainfromemail, lead-extractdomainfromemail
**Entity**: Contact, Lead
**Stage**: Pre-Operation (Synchronous)
**Attributes**: emailaddress1

```csharp
public class DomainExtractionPlugin : IPlugin
{
    public void Execute(IServiceProvider serviceProvider)
    {
        // Get context, service, tracing
        var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
        var service = serviceProvider.GetOrganizationService(context.UserId);
        var trace = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
        
        // Only proceed if emailaddress1 changed
        if (!context.InputParameters.Contains("Target")) return;
        var entity = (Entity)context.InputParameters["Target"];
        
        if (entity.Contains("emailaddress1"))
        {
            string email = entity.GetAttributeValue<string>("emailaddress1");
            if (!string.IsNullOrEmpty(email) && email.Contains("@"))
            {
                // Extract domain
                string domain = email.Split('@')[1].ToLower();
                
                // Query revops_domains for validation
                var query = new QueryExpression("revops_domain")
                {
                    ColumnSet = new ColumnSet("revops_domaintype", "revops_accountid"),
                    Criteria = new FilterExpression
                    {
                        Conditions = 
                        {
                            new ConditionExpression("revops_domain", ConditionOperator.Equal, domain),
                            new ConditionExpression("statecode", ConditionOperator.Equal, 0)
                        }
                    }
                };
                
                var results = service.RetrieveMultiple(query);
                
                // Check if generic domain
                if (results.Entities.Count > 0)
                {
                    var domainRecord = results.Entities[0];
                    if (domainRecord.Contains("revops_domaintype") && 
                        domainRecord.GetAttributeValue<OptionSetValue>("revops_domaintype").Value == 100000001) // Generic
                    {
                        // Apply generic domain transformation
                        string emailPrefix = email.Split('@')[0];
                        domain = $"{emailPrefix}.{domain}";
                    }
                }
                
                // Set domain on entity
                entity["revops_domain"] = domain;
            }
        }
    }
}
```

#### Plugin 2: `AccountDomainMatcherPlugin`
**Replaces**: lead-resolveaccountbydomain, contact-resolveaccountbydomain
**Entity**: Contact, Lead  
**Stage**: Post-Operation (Async)
**Attributes**: revops_domain

```csharp
public class AccountDomainMatcherPlugin : IPlugin
{
    public void Execute(IServiceProvider serviceProvider)
    {
        var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
        var service = serviceProvider.GetOrganizationService(context.UserId);
        var trace = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
        
        var entity = (Entity)context.InputParameters["Target"];
        var recordId = entity.Id;
        var entityName = context.PrimaryEntityName;
        
        // Get full record with domain
        var record = service.Retrieve(entityName, recordId, new ColumnSet("revops_domain", "parentaccountid", "parentcustomerid", "emailaddress1"));
        
        if (!record.Contains("revops_domain")) return;
        string domain = record.GetAttributeValue<string>("revops_domain");
        
        // Query revops_domains table
        var fetchXml = $@"
            <fetch top='50'>
              <entity name='revops_domain'>
                <attribute name='revops_domainid' />
                <attribute name='revops_accountid' />
                <filter>
                  <condition attribute='revops_domain' operator='eq' value='{domain}' />
                  <condition attribute='statecode' operator='eq' value='0' />
                </filter>
                <link-entity name='account' from='accountid' to='revops_accountid' link-type='inner'>
                  <attribute name='accountid' />
                  <attribute name='name' />
                  <filter>
                    <condition attribute='statecode' operator='eq' value='0' />
                  </filter>
                </link-entity>
              </entity>
            </fetch>";
        
        var results = service.RetrieveMultiple(new FetchExpression(fetchXml));
        
        if (results.Entities.Count == 1)
        {
            // One account found - link it
            var domainRecord = results.Entities[0];
            var accountId = domainRecord.GetAttributeValue<EntityReference>("revops_accountid");
            
            var updateEntity = new Entity(entityName) { Id = recordId };
            
            if (entityName == "lead")
            {
                updateEntity["parentaccountid"] = accountId;
                updateEntity["revops_existingaccount"] = true;
            }
            else if (entityName == "contact")
            {
                updateEntity["parentcustomerid"] = accountId;
            }
            
            service.Update(updateEntity);
        }
        else if (results.Entities.Count > 1)
        {
            // Multiple accounts - should never happen with unique constraint
            trace.Trace($"ERROR: Multiple accounts found for domain {domain}");
            // Create note or work item
        }
        // If 0 results: no action (account not matched)
    }
}
```

---

### Phase 5: Testing & Validation (Week 9-10)

**Test Scenarios**:

1. **Single Domain Account** (Current behavior)
   - Create Contact with email: `john@sherweb.com`
   - Verify: Domain extracted → `sherweb.com`
   - Verify: Account matched if `sherweb.com` exists in revops_domains
   - Verify: Contact.parentcustomerid set correctly

2. **Multi-Domain Account** (New behavior)
   - Setup: Account "Sherweb" with domains: `sherweb.com`, `sherweb.ca`, `sherweb.fr`
   - Create Contact 1: `john@sherweb.com`
   - Create Contact 2: `marie@sherweb.fr`
   - Create Contact 3: `jane@sherweb.ca`
   - Verify: All 3 contacts linked to same Account "Sherweb"

3. **Generic Domain Handling**
   - Setup: `gmail.com` in domain master list (type=Generic)
   - Create Contact: `john.doe@gmail.com`
   - Verify: Domain transformed to `john.doe.gmail.com`
   - Create Account "John Doe Personal" with domain `john.doe.gmail.com`
   - Create Contact: `john.doe@gmail.com` again
   - Verify: Contact matches to "John Doe Personal" account

4. **Primary Domain Designation**
   - Account has 3 domains
   - Verify: Only 1 marked as isPrimary
   - Change primary domain
   - Verify: Previous primary set to false, new one set to true

5. **Domain Conflict Resolution**
   - Try to add domain `sherweb.com` to Account A
   - Domain already exists linked to Account B
   - Verify: Error message with conflict details
   - Verify: Domain not created/updated

6. **Cumulus Integration**
   - Cumulus Account with domain `newcustomer.com`
   - No existing CRM Account
   - Verify: New domain record created
   - Verify: Cumulus Account linked to CRM Account
   - Verify: Domain linked to Account

**Performance Testing**:
- Bulk import 1000 contacts with various domains
- Measure processing time (Flow vs Plugin)
- Verify: No timeouts, all contacts matched correctly
- Benchmark: Flow = 2-5s per contact, Plugin = 50-200ms per contact

---

## Rollout Plan

### Week 1-2: Foundation
- ✅ Create schema changes
- ✅ Deploy domain registration flow
- ✅ Create generic domain master list
- ✅ Test domain creation manually

### Week 3-4: Migration
- ✅ Run migration flow in DEV
- ✅ Validate migration results
- ✅ Resolve conflicts manually
- ✅ Run migration in TEST/UAT
- ✅ User acceptance testing

### Week 5-6: Flow Updates
- ✅ Update domain extraction flows
- ✅ Update account matching flows
- ✅ Update Cumulus integration flows
- ✅ Deploy to DEV → TEST → UAT
- ✅ Regression testing

### Week 7-8: Plugin Development (Optional)
- ✅ Develop DomainExtraction plugin
- ✅ Develop AccountMatcher plugin
- ✅ Unit testing
- ✅ Deploy to DEV
- ✅ Performance comparison testing

### Week 9-10: Production Rollout
- ✅ Final UAT signoff
- ✅ Production migration (off-hours)
- ✅ Monitor for 48 hours
- ✅ Deactivate old flows (keep as backup)
- ✅ Update documentation

---

## Flows Requiring Modification

### High Priority - Core Matching Logic

| Flow Name | Change Type | Complexity | Estimated Effort |
|-----------|-------------|------------|------------------|
| **lead-resolveaccountbydomain** | Major | High | 8-16 hours |
| **contact-resolveaccountbydomain** | Major | High | 8-16 hours |
| **lead-extractdomainfromemail** | Minor | Low | 2-4 hours |
| **contact-extractdomainfromemail** | Minor | Low | 2-4 hours |

**Total**: 20-40 hours

### Medium Priority - Cumulus Integration

| Flow Name | Change Type | Complexity | Estimated Effort |
|-----------|-------------|------------|------------------|
| **fillparentaccountofcumulusaccount** | Major | Very High | 16-24 hours |
| **linkcumulusaccountstoparentaccounts** | Major | High | 8-16 hours |
| **account-created-in-cumulus** | Moderate | Medium | 4-8 hours |
| **accountcreatedincumulus** | Moderate | Medium | 4-8 hours |

**Total**: 32-56 hours

### Low Priority - Manual Operations

| Flow Name | Change Type | Complexity | Estimated Effort |
|-----------|-------------|------------|------------------|
| **accounts-manual-fixgenericdomainsformat** | Moderate | Medium | 4-8 hours |
| **contact-extractdomainfromemailselectingrows** | Minor | Low | 2-4 hours |
| **contact-resolveaccountbydomainselectrow** | Moderate | Medium | 4-8 hours |

**Total**: 10-20 hours

---

## New Components to Build

| Component | Type | Estimated Effort |
|-----------|------|------------------|
| **migration-accountdomainstojunctiontable** | Flow (One-time) | 8-16 hours |
| **domain-registerdomaintoaccount** | Flow | 8-12 hours |
| **domain-validateownership** | Flow (Optional) | 8-16 hours |
| **domain-findorphaneddomains** | Flow | 8-12 hours |
| **DomainExtractionPlugin** | Plugin (Optional) | 16-24 hours |
| **AccountDomainMatcherPlugin** | Plugin (Optional) | 16-24 hours |
| **Domain Management Canvas App** | Power App (Optional) | 24-40 hours |

**Total New Development**: 88-144 hours (without optional components: 24-40 hours)

---

## Total Effort Estimate

| Phase | Effort (Hours) |
|-------|----------------|
| Schema Changes & Foundation | 8-16 |
| Data Migration | 16-24 |
| Flow Modifications | 62-116 |
| New Flow Development | 24-40 |
| Plugin Development (Optional) | 32-48 |
| Testing & Validation | 40-60 |
| Documentation & Training | 16-24 |

**Total (without plugins)**: 166-280 hours (4-7 weeks for 1 developer)  
**Total (with plugins)**: 198-328 hours (5-8 weeks for 1 developer)

---

## Risks & Mitigation

### Risk 1: Data Migration Conflicts
**Risk**: Multiple Accounts claim the same domain during migration  
**Impact**: High - Prevents automated migration  
**Mitigation**:
- Run conflict detection report BEFORE migration
- Manual review and resolution of conflicts
- Create clear conflict resolution procedures
- Consider domain ownership verification

### Risk 2: Performance Degradation
**Risk**: Additional FetchXML queries slow down Lead/Contact creation  
**Impact**: Medium - User experience suffers  
**Mitigation**:
- Implement as async plugin (Post-Operation)
- Add caching for frequently queried domains
- Monitor performance metrics before/after
- Optimize FetchXML with proper indexes

### Risk 3: Generic Domain False Positives
**Risk**: Corporate domains incorrectly flagged as generic  
**Impact**: Medium - Wrong domain format applied  
**Mitigation**:
- Maintain curated list of known generic domains
- Manual review workflow for edge cases
- Allow manual override of domain type
- Monitor transformation errors

### Risk 4: Cumulus Integration Breaking Changes
**Risk**: Flow changes break existing Cumulus sync  
**Impact**: High - New accounts not created  
**Mitigation**:
- Extensive testing in DEV with Cumulus test data
- Parallel run: Keep old flow active, run new flow in monitoring mode
- Rollback plan: Deactivate new flows, reactivate old flows
- Cumulus team involvement in UAT

### Risk 5: Orphaned Domains Post-Migration
**Risk**: Domains created without Account association  
**Impact**: Low - Data quality issue  
**Mitigation**:
- Post-migration validation queries
- Scheduled cleanup flow to detect orphans
- Business rule to enforce Account lookup requirement

---

## Success Metrics

### Functional Metrics
- ✅ 100% of existing Account domains migrated to junction table
- ✅ <1% domain conflicts requiring manual resolution
- ✅ Multi-domain accounts correctly match Leads/Contacts across all domains
- ✅ Generic domain transformation works for 100% of known generic domains

### Performance Metrics
- ✅ Account matching completes in <3 seconds (Flow) or <500ms (Plugin)
- ✅ Domain extraction completes in <1 second
- ✅ No timeout errors during bulk contact imports

### Adoption Metrics
- ✅ 80% of Accounts with multiple domains have all domains registered within 3 months
- ✅ <5% of Leads/Contacts fail to match due to domain issues (down from current baseline)
- ✅ Zero production incidents related to domain matching after 30 days

---

## Recommendations

### Phase 1 (Immediate - Weeks 1-6)
**Use Flows** for all components:
- Lower development complexity
- Faster time to value
- Easier for business users to understand and maintain
- Sufficient performance for current volume

**Deliverables**:
1. Schema changes and migration
2. Updated domain extraction flows
3. Updated account matching flows (using revops_domains table)
4. Updated Cumulus integration flows
5. Domain registration flow for manual additions

### Phase 2 (Future - Weeks 7-10) [Optional]
**Convert to Plugins** if:
- Performance becomes an issue (>5s matching time)
- Volume increases significantly (>10k contacts/month)
- Need tighter transaction control
- Want to reduce Power Automate license consumption

**Candidates for Plugin Conversion**:
1. Domain extraction (contact-extractdomainfromemail, lead-extractdomainfromemail)
2. Account matching (contact-resolveaccountbydomain, lead-resolveaccountbydomain)

### Phase 3 (Long-term - Month 4+) [Optional]
**Additional Enhancements**:
1. Domain ownership verification (DNS TXT records)
2. Automatic domain discovery from Contact/Lead imports
3. Domain reputation scoring (enrichment data)
4. Account merge logic considering domain consolidation
5. Power BI reporting on domain distribution and coverage

---

## Conclusion

The multi-domain solution leverages the existing `revops_domains` table as a **many-to-many junction table** between Accounts and Domains. This provides:

✅ **Flexibility**: One Account can have multiple domains  
✅ **Data Integrity**: One Domain can only belong to one Account (unique constraint)  
✅ **Scalability**: Easy to add/remove domains without schema changes  
✅ **Maintainability**: Centralized domain management and validation  
✅ **Compatibility**: Existing revops_domain fields remain functional during transition  

**Recommended Approach**: Start with **Flow-based implementation** for faster delivery and easier maintenance. Convert to **plugins in Phase 2** only if performance becomes a bottleneck.

**Next Steps**:
1. Review and approve schema changes
2. Create DEV environment for testing
3. Begin Phase 1 implementation (schema + migration)
4. Schedule weekly checkpoints for progress review
