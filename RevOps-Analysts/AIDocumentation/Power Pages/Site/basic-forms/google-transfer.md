# Google Transfer

## Overview
This basic form enables portal users to create Google Workspace transfer cases. It features intelligent automation that hides configuration fields, auto-populates system values, dynamically generates case titles, and supports multiple file attachments for transfer documentation.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\google-transfer\`
- **Form ID**: 988b6d04-edc6-f011-bbd3-002248b10704
- **Form Name**: Case - Create Portal Google

## Configuration

### Entity Details
- **Entity Name**: `incident` (Case)
- **Form Name**: Case - Create Portal Google
- **Mode**: Insert (100000000)
- **Tab**: general

### Entity Permissions
- **Enabled**: Yes (`adx_entitypermissionsenabled: true`)

### File Attachments
- **Enabled**: Yes
- **Allow Multiple**: Yes
- **Required**: No
- **Restrict Accept**: No
- **Storage Location**: Azure Blob Storage (756150000)

### Form Behavior
- **Auto Generate Steps**: No
- **Force All Fields Required**: No
- **Show Owner Fields**: No
- **Show Unsupported Fields**: No
- **Recommended Fields Required**: No
- **Tooltip Enabled**: No
- **Validation Summary Links Enabled**: Yes

### Success Behavior
- **On Success**: Display Success Message (756150000)
- **Hide Form**: Yes
- **Append Entity ID Query String**: No

### Security
- **CAPTCHA Required**: No
- **Show CAPTCHA for Authenticated Users**: No

## Custom Code

### JavaScript Overview
The form includes substantial custom JavaScript (~650+ lines) that provides:
1. **Field Management** - Automated hiding of configuration fields
2. **Data Loading** - Integration with Liquid-injected data for organizations, accounts, and configuration
3. **Dynamic Updates** - Real-time field updates based on Cumulus Organization selection
4. **Automatic Title Generation** - Creates Google Workspace-specific case titles
5. **Bi-directional Synchronization** - Keeps organization and account fields in sync

### Configuration Object
```javascript
const CONFIG = {
  fields: {
    subject: "subjectid",
    service: "revops_service",
    origin: "caseorigincode",
    caseType: "casetypecode",
    queue: "revops_queue",
    contact: "primarycontactid",
    title: "title",
    customer: "customerid",
    cumulusOrg: "revops_cumulusorganization",
    cumulusAccount: "revops_cumulusaccount"
  },
  fieldsToHide: [
    "revops_cumulusaccount",
    "revops_queue",
    "title",
    "casetypecode",
    "subjectid",
    "revops_service",
    "caseorigincode",
    "customerid"
  ],
  defaultValues: {
    origin: "3",        // Portal
    caseType: "234570012"  // Manual Provisioning
  },
  lookupEntities: {
    subjectid: "subject",
    revops_service: "revops_service",
    revops_queue: "queue",
    revops_cumulusorganization: "revops_cumulusorganization",
    revops_cumulusaccount: "revops_cumulusaccount"
  }
}
```

**Note**: Case Type is set to "234570012" (Manual Provisioning) which differs from CSP transfers that use "234570011" (Migration).

### Key JavaScript Functions

#### 1. Data Loading Functions
```javascript
function loadConfigData()
// Loads configuration from #google-config-data script tag
// Returns: { queueId, queueName, subjectId, subjectName, serviceId, serviceName }

function loadOrgsData()
// Loads organizations from #google-orgs-data script tag
// Returns: Array of { id, name, cumulusAccountId }

function loadAccountsData()
// Loads accounts from #google-accounts-data script tag
// Returns: Array of { id, name }

function getOrgById(orgId)
// Retrieves specific organization by ID

function getAccountById(accountId)
// Retrieves specific account by ID
```

#### 2. Field Population Functions
```javascript
function prepopulateStaticFields()
// Populates queue, subject, service, origin, and case type
// Values come from Liquid-injected config data

function updateCaseTitleFromOrg(orgId)
// Generates title: "Google Workspace Transfer for {orgName}"
// Google-specific title format
```

#### 3. Organization Change Handler
```javascript
function attachOrgChangeHandlerForAccount()
// When user selects a Cumulus Organization:
//   1. Gets organization details
//   2. Auto-populates Cumulus Account (parent account)
//   3. Updates case title with Google-specific format
// Uses MutationObserver for real-time updates
```

#### 4. Account Change Handler
```javascript
function attachAccountChangeHandler()
// When Cumulus Account changes:
//   - Validates that selected organization belongs to the account
//   - Clears organization selection if mismatch detected
//   - Clears case title when organization is cleared
// Ensures data consistency between account and organization
```

#### 5. Additional Organization Change Handler
```javascript
function attachOrgChangeHandler()
// Dedicated handler for organization changes
// Ensures case title updates whenever organization is selected
// Provides redundancy with attachOrgChangeHandlerForAccount()
```

#### 6. Field Helper Functions
```javascript
function getAttribute(logicalName)
// Robust field locator using multiple selector strategies

function setLookupField(logicalName, id, name)
// Sets lookup field with GUID, name, and entity type
// Includes retry logic and event dispatching

function setTextField(logicalName, value)
// Sets text field values with change events

function setOptionSetField(logicalName, value)
// Sets option set dropdown values with retry logic

function hideFields()
// Hides all fields in fieldsToHide array
```

### Hidden Fields
The following fields are automatically hidden from the user:
- revops_cumulusaccount (auto-populated, but hidden)
- revops_queue
- title
- casetypecode
- subjectid
- revops_service
- caseorigincode
- customerid

### Automatically Populated Fields
1. **Queue**: From Liquid config data
2. **Subject**: From Liquid config data
3. **Service**: From Liquid config data
4. **Origin**: Set to "3" (Portal)
5. **Case Type**: Set to "234570012" (Manual Provisioning)
6. **Cumulus Account**: Auto-populated when organization is selected
7. **Title**: Auto-generated as "Google Workspace Transfer for {orgName}"

### User Interactions

#### Form Fill Flow
1. User selects a **Cumulus Organization** from the lookup
2. JavaScript automatically:
   - Retrieves the organization details
   - Sets the Cumulus Account field to the org's parent account
   - Generates and sets the case title: "Google Workspace Transfer for {orgName}"
3. User fills in any remaining visible fields (description, dates, requirements, etc.)
4. User attaches documentation files (optional, supports multiple files)
5. User submits the form
6. Case is created with all hidden fields pre-populated

#### Title Generation Examples
- Organization: "Contoso" → Title: "Google Workspace Transfer for Contoso"
- Organization: "Fabrikam Inc." → Title: "Google Workspace Transfer for Fabrikam Inc."

## Usage

### Portal User Experience
1. Navigate to Google Transfer page
2. Select **Cumulus Organization** (the primary user input)
3. Fill in **Description** or other visible fields
4. Attach relevant files (transfer documentation, CSV files, etc.)
   - Multiple files supported
   - All file types accepted
5. Submit the form
6. Case is created and success message displayed

### Expected Data Flow
The form expects the following data to be injected via Liquid templates:
- **#google-config-data**: Queue, Subject, and Service lookup details (JSON)
- **#google-orgs-data**: Array of Cumulus organizations with parent account references (JSON)
- **#google-accounts-data**: Array of accounts (JSON)

### Initialization Timing
The JavaScript initializes with a 2-second delay and includes multiple retry mechanisms:
```javascript
setTimeout(() => {
  hideFields();
  prepopulateStaticFields();
  attachOrgChangeHandlerForAccount();
  attachAccountChangeHandler();
  attachOrgChangeHandler();  // Additional handler for redundancy
  setTimeout(() => {
    prepopulateStaticFields();  // Retry after 1 second
  }, 1000);
}, 2000);
```

## Related Components

### Dependencies
- **jQuery**: Required for DOM manipulation
- **Liquid Templates**: For data injection
- **FetchXML Queries**: Server-side data loading for configuration, organizations, and accounts
- **Azure Blob Storage**: For file attachment storage

### Related Forms
- **CSP Transfer**: Standard CSP transfer form with similar architecture
- **CSP GoDaddy Transfer**: GoDaddy-specific CSP transfer form
- All three share the same field management and automation approach
- **Key Difference**: Google Transfer uses case type "Manual Provisioning" instead of "Migration"

### Related Entities
- **incident** (Case): Primary entity
- **revops_cumulusorganization**: Organization being transferred to Google Workspace
- **revops_cumulusaccount**: Account owning the organization (hidden but synced)
- **subject**: Case subject classification
- **revops_service**: Service type
- **queue**: Assignment queue
- **contact**: Portal user contact
- **annotation**: File attachments

## Change History

### Current Implementation
- Automatic organization-to-account population
- Dynamic case title generation with "Google Workspace Transfer" branding
- Comprehensive field hiding
- Multiple file attachment support
- Liquid data integration
- Multiple retry mechanisms for field updates
- Three separate change handlers for robustness
- MutationObserver for real-time change detection
- setTimeout fallbacks for robust initialization
- Case type set to "Manual Provisioning" (234570012)

### Key Features
- **Simplified UX**: Users only see essential fields
- **File Attachments**: Support for multiple documentation files
- **Automatic Classification**: Case type set to Manual Provisioning, origin to Portal, queue pre-set
- **Data Consistency**: Ensures organization matches account via validation
- **Google-Specific Titles**: Auto-generated titles clearly identify Google Workspace transfers
- **Robust Initialization**: Multiple timing strategies and retry mechanisms
- **Redundant Handlers**: Three change handlers ensure updates never missed
- **Google Workspace Focus**: Tailored specifically for Google Workspace migration workflows
