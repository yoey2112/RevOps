# CSP GoDaddy Transfer

## Overview
This basic form enables portal users to create CSP (Cloud Solution Provider) transfer cases specifically for GoDaddy migrations. It features intelligent automation that hides configuration fields, auto-populates system values, and dynamically generates case titles based on the selected Cumulus organization.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\csp-godaddy-transfer\`
- **Form ID**: 848ebec3-44c6-f011-8543-002248afdabb
- **Form Name**: Case - Create Portal GoDaddy

## Configuration

### Entity Details
- **Entity Name**: `incident` (Case)
- **Form Name**: Case - Create Portal GoDaddy
- **Mode**: Insert (100000000)
- **Tab**: general

### Entity Permissions
- **Enabled**: Yes (`adx_entitypermissionsenabled: true`)

### File Attachments
- **Enabled**: No

### Form Behavior
- **Auto Generate Steps**: No
- **Force All Fields Required**: No
- **Show Owner Fields**: No
- **Show Unsupported Fields**: No
- **Recommended Fields Required**: No
- **Tooltip Enabled**: No
- **Validation Summary Links Enabled**: Yes

### Success Behavior
- **On Success**: Redirect to Web Page (756150001)
- **Hide Form**: Yes
- **Append Entity ID Query String**: No

### Security
- **CAPTCHA Required**: No
- **Show CAPTCHA for Authenticated Users**: No

## Custom Code

### JavaScript Overview
The form includes substantial custom JavaScript (~600+ lines) that provides:
1. **Field Management** - Automated hiding of configuration fields
2. **Data Loading** - Integration with Liquid-injected data for organizations, accounts, and configuration
3. **Dynamic Updates** - Real-time field updates based on Cumulus Organization selection
4. **Automatic Title Generation** - Creates descriptive case titles based on organization

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
    "revops_queue",
    "casetypecode",
    "subjectid",
    "revops_service",
    "caseorigincode",
    "customerid",
    "revops_cumulusaccount",
    "primarycontactid",
    "title"
  ],
  defaultValues: {
    origin: "3",        // Portal
    caseType: "234570011"  // Migration
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

### Key JavaScript Functions

#### 1. Data Loading Functions
```javascript
function loadConfigData()
// Loads configuration from #godaddy-config-data script tag
// Returns: { queueId, queueName, subjectId, subjectName, serviceId, serviceName }

function loadOrgsData()
// Loads organizations from #godaddy-orgs-data script tag
// Returns: Array of { id, name, cumulusAccountId }

function loadAccountsData()
// Loads accounts from #godaddy-accounts-data script tag
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
// Generates title: "CSP GoDaddy Transfer for {orgName}"
```

#### 3. Organization Change Handler
```javascript
function attachOrgChangeHandlerForAccount()
// When user selects a Cumulus Organization:
//   1. Gets organization details
//   2. Auto-populates Cumulus Account (parent account)
//   3. Updates case title
// Uses MutationObserver for real-time updates
```

#### 4. Account Change Handler
```javascript
function attachAccountChangeHandler()
// When Cumulus Account changes:
//   - Clears organization selection if it doesn't match the account
//   - Clears case title
// Ensures data consistency
```

#### 5. Field Helper Functions
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
- revops_queue
- casetypecode
- subjectid
- revops_service
- caseorigincode
- customerid
- revops_cumulusaccount
- primarycontactid
- title

### Automatically Populated Fields
1. **Queue**: From Liquid config data
2. **Subject**: From Liquid config data
3. **Service**: From Liquid config data
4. **Origin**: Set to "3" (Portal)
5. **Case Type**: Set to "234570011" (Migration)
6. **Cumulus Account**: Auto-populated when organization is selected
7. **Title**: Auto-generated as "CSP GoDaddy Transfer for {orgName}"

### User Interactions

#### Form Fill Flow
1. User selects a **Cumulus Organization** from the lookup
2. JavaScript automatically:
   - Retrieves the organization details
   - Sets the Cumulus Account field to the org's parent account
   - Generates and sets the case title
3. User fills in any remaining visible fields (description, dates, etc.)
4. User submits the form
5. Case is created with all hidden fields pre-populated

#### Title Generation
When user selects organization "Contoso":
- **Generated Title**: "CSP GoDaddy Transfer for Contoso"

## Usage

### Portal User Experience
1. Navigate to CSP GoDaddy Transfer page
2. Select **Cumulus Organization** (the only required user selection)
3. Fill in **Description** or other visible fields
4. Submit the form
5. Redirected to confirmation page

### Expected Data Flow
The form expects the following data to be injected via Liquid templates:
- **#godaddy-config-data**: Queue, Subject, and Service lookup details
- **#godaddy-orgs-data**: Array of Cumulus organizations with parent account references
- **#godaddy-accounts-data**: Array of accounts

### Initialization Timing
The JavaScript initializes with a 2-second delay and includes multiple retry mechanisms:
```javascript
setTimeout(() => {
  hideFields();
  prepopulateStaticFields();
  attachOrgChangeHandlerForAccount();
  attachAccountChangeHandler();
  setTimeout(() => {
    prepopulateStaticFields();
  }, 1000);
}, 2000);
```

## Related Components

### Dependencies
- **jQuery**: Required for DOM manipulation
- **Liquid Templates**: For data injection
- **FetchXML Queries**: Server-side data loading for configuration, organizations, and accounts

### Related Forms
- **CSP Transfer**: Similar form for standard CSP transfers
- **Google Transfer**: Similar form for Google Workspace transfers
- Both share similar architectural patterns

### Related Entities
- **incident** (Case): Primary entity
- **revops_cumulusorganization**: Organization being transferred
- **revops_cumulusaccount**: Account owning the organization
- **subject**: Case subject classification
- **revops_service**: Service type
- **queue**: Assignment queue
- **contact**: Portal user contact

## Change History

### Current Implementation
- Automatic organization-to-account population
- Dynamic case title generation
- Comprehensive field hiding
- Liquid data integration
- Multiple retry mechanisms for field updates
- MutationObserver for real-time change detection
- setTimeout fallbacks for robust initialization

### Key Features
- **Simplified UX**: Users only see essential fields
- **Automatic Classification**: Case type, origin, queue pre-set
- **Data Consistency**: Ensures organization matches account
- **Descriptive Titles**: Auto-generated meaningful case titles
- **Robust Initialization**: Multiple timing strategies to ensure fields load
- **GoDaddy-Specific**: Tailored for GoDaddy CSP migration workflows
