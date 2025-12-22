# Case - Create P2P from Portal

## Overview
This basic form enables portal users to create Peer-to-Peer (P2P) transfer cases for transferring Cumulus organizations between accounts. It features a sophisticated organization selection modal, automatic field population, dynamic validation, and handles transfers from "losing competitors" with conditional required fields.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\case---create-p2p-from-portal\`
- **Form ID**: 53b2dff0-4cec-4931-a3a3-9eed343edc16
- **Form Name**: Case - Create Portal P2P

## Configuration

### Entity Details
- **Entity Name**: `incident` (Case)
- **Form Name**: Case - Create Portal P2P
- **Mode**: Insert (100000000)
- **Tab**: general

### Entity Permissions
- **Enabled**: Yes (`adx_entitypermissionsenabled: true`)

### File Attachments
- **Enabled**: Yes
- **Accept Types**: */* (all file types)
- **Maximum Files**: 5
- **Storage Location**: Azure Blob Storage (756150000)
- **Save Option**: Notes (756150000)

### Success Behavior
- **On Success**: Redirect to Web Page (756150001)
- **Hide Form**: Yes
- **Redirect Page ID**: fae4d40d-9790-4e7e-067e-9a875b38f32b
- **Target Lookup Attribute**: primarycontactid

### Security
- **CAPTCHA Required**: No
- **Show CAPTCHA for Authenticated Users**: No

## Custom Code

### JavaScript Overview
The form includes extensive custom JavaScript (~1,200+ lines) that provides:
1. **Organization Selection Modal** - Interactive Bootstrap modal for selecting multiple Cumulus organizations
2. **Field Management** - Automated hiding and prepopulation of fields
3. **Data Loading** - Integration with Liquid-injected data for organizations, accounts, and regions
4. **Validation** - Form submission validation for conditional required fields
5. **Dynamic Updates** - Real-time field updates based on user selections

### Key JavaScript Functions

#### 1. Configuration Object
```javascript
const CONFIG = {
  fields: {
    cumulusAccount: "revops_cumulusaccount",
    transferOrgs: "revops_transferorgs",
    subject: "subjectid",
    service: "revops_service",
    title: "title",
    numberOfOrgs: "revops_oforganizations",
    origin: "caseorigincode",
    account: "customerid",
    competitorRegion: "revops_competitorregion",
    caseType: "casetypecode",
    revopsAccount: "revops_account",
    queue: "revops_queue",
    losingCompetitor: "revops_losingcompetitor",
    cspTransferId: "revops_csptransferid",
    losingProvider: "revops_losingprovider"
  },
  defaultValues: {
    origin: "3" // Portal
  }
}
```

#### 2. Organization Selection Modal
- **createOrgModal()**: Creates a Bootstrap modal with searchable checkbox list
- **showOrgModal()**: Opens modal and loads organizations for selected account
- **renderOrgList()**: Renders organization checkboxes with search and select-all functionality
- **confirmOrgSelection()**: Saves selected organizations as JSON array and updates related fields

#### 3. Field Population Functions
- **prepopulateFields()**: Sets default values for Subject, Service, Queue, and Origin from Liquid data
- **updateCaseTitle()**: Automatically generates case title: "{count} - P2P transfer for {account}"
- **populateRegionFromAccount()**: Auto-populates Competitor Region based on account's ISO2 country code

#### 4. Conditional Field Logic - "Other" Losing Competitor
When "Other" is selected as the Losing Competitor:
- **Shows and requires**: CSP Transfer ID field
- **Shows and requires**: Losing Provider field
- **Adds validation**: Prevents form submission if these fields are empty
- **Visual indicators**: Adds red asterisks and red borders for required fields

**Key Implementation**:
```javascript
function attachLosingCompetitorHandler() {
  // Monitors losing competitor selection
  // If "Other" is selected:
  //   - Shows CSP Transfer ID and Losing Provider fields
  //   - Makes them required
  //   - Adds visual indicators (red asterisk)
  // Otherwise:
  //   - Hides both fields
  //   - Removes required attribute
  //   - Clears field values
}
```

#### 5. Form Submission Validation
- **attachFormSubmitValidation()**: Intercepts form submission
- Validates that CSP Transfer ID and Losing Provider are filled when "Other" is selected
- Displays alert with missing fields if validation fails
- Prevents submission until all conditional required fields are completed

#### 6. Data Loading Functions
- **loadOrgsData()**: Loads organizations from `#p2p-orgs-data` script tag
- **loadAccountsData()**: Loads accounts from `#p2p-accounts-data` script tag
- **loadRegionsData()**: Loads regions from `#p2p-regions-data` script tag
- **loadConfigData()**: Loads configuration (Subject, Service, Queue) from `#p2p-config-data` script tag

#### 7. Field Helper Functions
- **getAttribute()**: Robust field locator using multiple selector strategies
- **setLookupField()**: Sets lookup field values (GUID, name, entity type)
- **setTextField()**: Sets text field values with event dispatch
- **setOptionSetField()**: Sets option set (dropdown) values
- **setNumberField()**: Sets number field values
- **hideFieldsWithCSS()**: Hides specified fields using CSS display/visibility

### Hidden Fields
The following fields are automatically hidden:
- title
- revops_transferorgs
- revops_oforganizations
- subjectid
- revops_service
- caseorigincode
- revops_account
- revops_queue
- casetypecode
- customerid
- primarycontactid
- revops_csptransferid (conditionally shown)
- revops_losingprovider (conditionally shown)

### Automatically Populated Fields
1. **Subject**: From Liquid config data
2. **Service**: From Liquid config data
3. **Queue**: From Liquid config data
4. **Origin**: Set to "3" (Portal)
5. **Transfer Orgs**: JSON array of selected organization IDs
6. **Number of Organizations**: Count of selected organizations
7. **RevOps Account**: Parent account from first selected organization
8. **Competitor Region**: Based on account's ISO2 country code
9. **Title**: Auto-generated as "{count} - P2P transfer for {account}"

### User Interactions

#### Organization Selection Flow
1. User selects a Cumulus Account
2. "Select Organizations to Transfer" button appears below the account field
3. User clicks button → Modal opens with all transferable orgs for that account
4. User can:
   - Search organizations by name
   - Select individual organizations via checkboxes
   - Use "Select All" to select all visible (filtered) organizations
5. Selected count displayed in modal footer
6. User clicks "Confirm Selection"
7. Modal closes and form updates:
   - Transfer Orgs field populated with JSON array
   - Number of Organizations updated
   - RevOps Account set to parent account
   - Competitor Region auto-populated
   - Case Title auto-generated

#### Losing Competitor Conditional Fields
1. User selects a value from the Losing Competitor lookup
2. If "Other" is selected:
   - CSP Transfer ID field becomes visible with red asterisk
   - Losing Provider field becomes visible with red asterisk
   - Both fields become required for form submission
3. If user attempts to submit without filling these fields:
   - Alert displays: "The following fields are required when 'Other' is selected: • CSP Transfer ID • Losing Provider"
   - Form submission is prevented
   - Fields show red borders
4. Once both fields are filled, form can submit successfully

## Usage

### Portal User Experience
1. Navigate to P2P transfer case creation page
2. Select the **Cumulus Account** (required)
3. Click **Select Organizations to Transfer** button
4. In the modal:
   - Search/filter organizations if needed
   - Select one or more organizations
   - Review selection count
   - Click **Confirm Selection**
5. Select **Losing Competitor**
6. If "Other" selected, fill in:
   - CSP Transfer ID
   - Losing Provider
7. Fill in any other visible required fields
8. Attach files if needed (up to 5 files)
9. Submit the form
10. Redirected to confirmation page

### Expected Data Flow
The form expects the following data to be injected via Liquid templates:
- **#p2p-config-data**: Subject ID/Name, Service ID/Name, Queue ID/Name
- **#p2p-orgs-data**: Array of Cumulus organizations with: id, name, accountGuid, parentAccountGuid, parentAccountName
- **#p2p-accounts-data**: Array of accounts with: id, name, iso2Code
- **#p2p-regions-data**: Array of regions with: id, name, code (ISO2)

## Related Components

### Dependencies
- **Bootstrap 5**: Required for modal functionality
- **jQuery**: Not used - pure JavaScript implementation
- **Liquid Templates**: For data injection
- **FetchXML Queries**: Server-side data loading for orgs, accounts, regions, and config

### Related Forms
- Uses same redirect page as other case creation forms
- Similar pattern to CSP Transfer and Google Transfer forms (but more complex)

### Related Entities
- **incident** (Case): Primary entity
- **revops_cumulusorganization**: Organizations being transferred
- **revops_cumulusaccount**: Account owning the organizations
- **account**: Customer account and parent account
- **msdyn_region**: Competitor region lookup
- **subject**: Case subject classification
- **revops_service**: Service type
- **queue**: Assignment queue

## Change History

### Current Implementation
- Complex organization selection modal with search and select-all
- Automatic title generation based on organization count and account
- Regional auto-population based on account country
- Conditional field logic for "Other" losing competitor
- Comprehensive form validation
- Multiple retry mechanisms for field updates
- Extensive error handling and console logging
- MutationObserver patterns for field monitoring
- Polling fallbacks for change detection

### Key Features
- **Accessibility**: ARIA labels, roles, and live regions
- **Responsive Design**: Mobile-friendly modal
- **User Feedback**: Real-time selection count, validation messages, loading indicators
- **Data Integrity**: JSON serialization of organization selections
- **Error Handling**: Try-catch blocks, fallback mechanisms
- **Performance**: Debounced searches, efficient DOM queries
