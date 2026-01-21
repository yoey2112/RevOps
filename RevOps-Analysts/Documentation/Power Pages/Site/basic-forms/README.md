# Basic Forms Documentation Summary

## Overview
This document provides a comprehensive summary of all 16 basic forms in the Power Pages site, highlighting key features, custom JavaScript implementations, and unique configurations.

**Documentation Location**: `c:\RevOps\RevOps-Analysts\Documentation\Power Pages\Site\basic-forms\`

---

## Forms with Custom JavaScript

### 1. **Case - Create P2P from Portal** ⭐ MOST COMPLEX
**File**: `case---create-p2p-from-portal.md`

**Purpose**: Creates Peer-to-Peer transfer cases with sophisticated organization selection

**Key Features**:
- **~1,200+ lines of custom JavaScript** - Most complex form in the site
- Interactive Bootstrap modal for selecting multiple Cumulus organizations
- Search and filter functionality with "Select All" option
- Real-time organization count display
- Automatic field hiding (9+ fields hidden)
- Dynamic case title generation: "{count} - P2P transfer for {account}"
- Auto-population of Competitor Region based on ISO2 country code
- **Conditional Required Fields**: When "Other" losing competitor selected:
  - CSP Transfer ID becomes required and visible
  - Losing Provider becomes required and visible
  - Form validation prevents submission without these fields
- MutationObserver patterns for field monitoring
- Multiple retry mechanisms and polling fallbacks
- Liquid data integration for orgs, accounts, and regions
- JSON serialization of organization selections

**Entity**: incident (Case)
**Mode**: Insert
**Attachments**: Yes (up to 5 files)

---

### 2. **Create Case - Complain about a Case**
**File**: `create-case---complain-about-a-case.md`

**Purpose**: File complaints about existing cases

**Key Features**:
- Liquid FetchXML for TSS Management queue lookup
- Liquid FetchXML for parent case details from URL parameter
- Auto-sets escalation reason to "234570001" (Complain about a Case)
- Auto-populates and hides Queue (TSS Management)
- Auto-populates and hides Parent Case from `?refid=` parameter
- jQuery-based implementation
- Retry pattern with setTimeout for field availability

**Entity**: incident (Case)
**Mode**: Insert
**Attachments**: No
**URL Parameter**: `refid` (parent case GUID)

---

### 3. **Create Case - Escalate a Case**
**File**: `create-case---escalate-a-case.md`

**Purpose**: Escalate existing cases to management

**Key Features**:
- Liquid FetchXML for TSS Management queue lookup
- Liquid FetchXML for parent case with Cumulus Account
- Auto-populates and hides Queue (TSS Management)
- Auto-populates and hides Parent Case from `?refid=` parameter
- Retrieves Cumulus Account from parent case
- jQuery-based implementation
- Retry pattern with setTimeout

**Entity**: incident (Case)
**Mode**: Insert
**Attachments**: No
**URL Parameter**: `refid` (parent case GUID)

---

### 4. **CSP GoDaddy Transfer**
**File**: `csp-godaddy-transfer.md`

**Purpose**: Create GoDaddy CSP migration cases

**Key Features**:
- **~600+ lines of custom JavaScript**
- Liquid data integration from script tags:
  - `#godaddy-config-data` (queue, subject, service)
  - `#godaddy-orgs-data` (organizations)
  - `#godaddy-accounts-data` (accounts)
- Auto-populates Cumulus Account when organization selected
- Dynamic case title: "CSP GoDaddy Transfer for {orgName}"
- Hides 9 configuration fields
- Sets Case Type to "234570011" (Migration)
- Sets Origin to "3" (Portal)
- MutationObserver for real-time updates
- 2-second initialization delay with multiple retries
- jQuery-based implementation

**Entity**: incident (Case)
**Mode**: Insert
**Attachments**: No

---

### 5. **CSP Transfer**
**File**: `csp-transfer.md`

**Purpose**: Create standard CSP transfer cases

**Key Features**:
- **~650+ lines of custom JavaScript**
- Liquid data integration from script tags:
  - `#csp-config-data`
  - `#csp-orgs-data`
  - `#csp-accounts-data`
- Auto-populates Cumulus Account when organization selected
- Dynamic case title: "CSP Transfer for {orgName}"
- Hides 8 configuration fields
- Sets Case Type to "234570011" (Migration)
- **Three separate change handlers** for robustness:
  1. attachOrgChangeHandlerForAccount() - org→account sync
  2. attachAccountChangeHandler() - validates account changes
  3. attachOrgChangeHandler() - additional title updates
- Bi-directional validation (clears org if account changes)
- 2-second initialization delay with retries
- jQuery-based implementation

**Entity**: incident (Case)
**Mode**: Insert
**Attachments**: No

---

### 6. **Google Transfer**
**File**: `google-transfer.md`

**Purpose**: Create Google Workspace migration cases

**Key Features**:
- **~650+ lines of custom JavaScript**
- Liquid data integration from script tags:
  - `#google-config-data`
  - `#google-orgs-data`
  - `#google-accounts-data`
- Auto-populates Cumulus Account when organization selected
- Dynamic case title: "Google Workspace Transfer for {orgName}"
- Hides 8 configuration fields
- Sets Case Type to "234570012" (Manual Provisioning) ⚠️ Different from CSP
- **Three separate change handlers** for robustness
- Bi-directional validation
- 2-second initialization delay with retries
- jQuery-based implementation

**Entity**: incident (Case)
**Mode**: Insert
**Attachments**: Yes (multiple files supported)

---

### 7. **View - Client Case** ⭐ TIER LOGIC
**File**: `view---client-case.md`

**Purpose**: View and edit existing cases with tier-based escalation

**Key Features**:
- **Tier-Based Escalation Button** (JavaScript incomplete in source, but logic present):
  - Liquid FetchXML to get account tier
  - Liquid FetchXML to check escalation status
  - Button shows ONLY if:
    - Account tier is 1 or 2 (Tier 1 or Tier 2)
    - AND case has NOT been escalated (no escalation reason value)
- "Escalate Request" action button opens modal
- Creates child escalation case via incident_parent_incident relationship
- jQuery-based implementation
- File attachment support (up to 5 files)
- Comprehensive case management actions (close, resolve, reopen, cancel)
- Bilingual support (English/French)

**Entity**: incident (Case)
**Mode**: Edit (100000001)
**Attachments**: Yes (up to 5 files)
**URL Parameter**: `id` (case GUID)

---

## Forms WITHOUT Custom JavaScript (Standard Forms)

### 8. **Create Case - CS**
**File**: `create-case---cs.md`
- Basic CS case creation
- Single file attachment
- Standard form rendering
- Entity: incident | Mode: Insert

### 9. **Create Case - Support**
**File**: `create-case---support.md`
- Standard support case creation
- File attachments (up to 5)
- Comprehensive modal dialog configurations
- Contact auto-association via contactid
- Entity: incident | Mode: Insert

### 10. **Create Case - License Adjustment** (Step 1 of 2)
**File**: `create-case---license-adjustment.md`
- First step in license adjustment workflow
- Redirects to License Adjustment Details with `?caseid=` parameter
- No attachments
- Entity: incident | Mode: Insert

### 11. **License Adjustment Details** (Step 2 of 2)
**File**: `license-adjustment-details.md`
- Creates Transfer records linked to case
- Reference entity configuration
- Multi-record support (can create multiple transfers per case)
- Entity: revops_transfer | Mode: Insert
- URL Parameter: `caseid`

### 12. **Create Case - Migration Request** (Step 1 of 2)
**File**: `create-case---migration-request.md`
- First step in migration workflow
- Redirects to Migration Details with `?caseid=` parameter
- No attachments
- Entity: incident | Mode: Insert

### 13. **Migration Details** (Step 2 of 2)
**File**: `migration-details.md`
- Creates Transfer records linked to migration case
- **Includes Create Related Record action** - can create additional cases from within form
- Multi-record support
- Modal dialog support
- Bilingual configuration
- Entity: revops_transfer | Mode: Insert
- URL Parameter: `caseid`

### 14. **Knowledge Article - Portal**
**File**: `knowledge-article---portal.md`
- Read-only knowledge article display
- Query string-based article loading
- Entity: knowledgearticle | Mode: ReadOnly (100000002)
- URL Parameter: `id`

### 15. **Portal Category**
**File**: `portal-category.md`
- Category creation
- **CAPTCHA required for ALL users** (including authenticated)
- Entity: category | Mode: Insert

### 16. **Profile Web Form (Enhanced) - Test**
**File**: `profile-web-form-(enhanced)---test.md`
- Test form for Cumulus Account creation
- **CAPTCHA required for ALL users**
- Entity: revops_cumulusaccount | Mode: Insert

---

## Summary Statistics

### By Complexity
- **High Complexity (1000+ lines JS)**: 1 form
  - Case - Create P2P from Portal (~1,200 lines)
- **Medium Complexity (600-700 lines JS)**: 3 forms
  - CSP GoDaddy Transfer, CSP Transfer, Google Transfer
- **Low Complexity (<300 lines JS)**: 3 forms
  - Complain about Case, Escalate Case, View Client Case
- **No Custom JS**: 9 forms

### By Custom JavaScript
- **With Custom JS**: 7 forms (44%)
- **Without Custom JS**: 9 forms (56%)

### By Liquid Templates
- **With Liquid FetchXML**: 4 forms
  - Complain about Case (2 queries)
  - Escalate Case (2 queries)
  - View Client Case (3 queries + conditional logic)
  - CSP GoDaddy/CSP/Google Transfer (data injection via script tags)

### By Entity
- **incident (Case)**: 10 forms
- **revops_transfer (Transfer)**: 2 forms
- **knowledgearticle**: 1 form
- **category**: 1 form
- **revops_cumulusaccount**: 1 form

### By File Attachments
- **Attachments Enabled**: 6 forms
- **No Attachments**: 10 forms

### By Form Mode
- **Insert**: 14 forms
- **Edit**: 1 form (View - Client Case)
- **ReadOnly**: 1 form (Knowledge Article)

---

## Key Patterns & Architectures

### 1. **Multi-Step Workflows**
- License Adjustment: Case Creation → Transfer Details
- Migration Request: Case Creation → Migration Details

### 2. **Parent-Child Case Relationships**
- Complain about Case: Links to parent via URL parameter
- Escalate Case: Links to parent via URL parameter
- View Client Case: Creates child escalation cases

### 3. **Liquid Data Injection Pattern**
Used by CSP GoDaddy, CSP, and Google Transfer forms:
```html
<script id="config-data" type="application/json">
  { "queueId": "...", "subjectId": "...", ... }
</script>
```
JavaScript reads from these script tags for configuration.

### 4. **Conditional Field Visibility**
- P2P Transfer: Shows CSP Transfer ID and Losing Provider when "Other" selected
- View Client Case: Shows Escalate button based on tier and escalation status

### 5. **Automatic Title Generation**
- P2P Transfer: "{count} - P2P transfer for {account}"
- CSP GoDaddy: "CSP GoDaddy Transfer for {orgName}"
- CSP Transfer: "CSP Transfer for {orgName}"
- Google Transfer: "Google Workspace Transfer for {orgName}"

### 6. **Field Helper Functions**
Common pattern across all forms with custom JS:
- `getAttribute()` - Robust field locator
- `setLookupField()` - Sets lookup values with retry logic
- `setTextField()` - Sets text values with events
- `setOptionSetField()` - Sets dropdowns with retry logic
- `hideFields()` - Hides configuration fields

### 7. **Retry Mechanisms**
All forms with custom JS use retry patterns:
- setTimeout delays (200ms, 400ms, 1000ms, 2000ms)
- MutationObserver for real-time change detection
- Polling with setInterval as fallback

---

## Business Rules Implemented

### Tier-Based Access Control
**View - Client Case**: Only Tier 1 and Tier 2 customers can escalate cases.

### Single Escalation Rule
**View - Client Case**: Each case can only be escalated once (checked via revops_customerescalationreason field).

### Conditional Required Fields
**P2P Transfer**: When "Other" losing competitor selected, CSP Transfer ID and Losing Provider become required.

### Case Type Classification
- **CSP/GoDaddy Transfer**: Case Type = Migration (234570011)
- **Google Transfer**: Case Type = Manual Provisioning (234570012)
- **All Portal Cases**: Origin = Portal (3)

### Queue Routing
- **Escalations & Complaints**: Automatically route to TSS Management queue
- **Transfers**: Route to configured queue from Liquid data

---

## Recommendations

### For Maintenance
1. **P2P Transfer Form**: Most complex - requires careful testing when modifying
2. **Liquid Data**: Ensure script tag data is properly formatted JSON
3. **Retry Timing**: Test on slow connections to validate timeout values
4. **MutationObserver**: Monitor for browser compatibility

### For Enhancement
1. Consider consolidating CSP Transfer forms (GoDaddy, Standard, Google) into single form with type selector
2. Add more detailed validation error messages
3. Implement loading indicators for Liquid FetchXML queries
4. Add analytics tracking for form usage and abandonment

### For Documentation
1. Document expected Liquid data structure for each form
2. Create troubleshooting guide for common field population issues
3. Document browser compatibility requirements
4. Create user guides for tier-based features

---

## Change Log
- **December 3, 2025**: Initial comprehensive documentation of all 16 basic forms
