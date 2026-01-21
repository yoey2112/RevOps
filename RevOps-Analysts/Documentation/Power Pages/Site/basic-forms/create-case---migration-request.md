# Create Case - Migration Request

## Overview
This basic form allows portal users to request data migration services. Upon successful submission, the form redirects to a Migration Details page where the user can specify transfer details and migration requirements.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\create-case---migration-request\`
- **Form ID**: ead2d143-74ba-f011-bbd3-7c1e52530041
- **Form Name**: Create Case - Migration Request

## Configuration

### Entity Details
- **Entity Name**: `incident` (Case)
- **Form Name**: Create Case - Migration Request
- **Mode**: Insert (100000000)
- **Tab**: General

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
- **Redirect Page ID**: 76a41bec-beab-0af0-7292-dc9293f013e3
- **Append Entity ID Query String**: Yes
- **Query String Parameter Name**: caseid

### Security
- **CAPTCHA Required**: No
- **Show CAPTCHA for Authenticated Users**: No
- **Associate Current Portal User**: No
- **Portal User Lookup Attribute is Activity Party**: No

### Geolocation
- **Enabled**: No
- **Display Map**: No
- **Map Type**: Bing (756150000)

## Custom Code

### JavaScript
**No custom JavaScript** - The form uses standard Power Pages functionality without additional client-side code.

### Liquid
No custom Liquid templates are associated with this form.

## Usage

### Portal User Experience
1. Navigate to the Migration Request page
2. Fill in case details:
   - Case title/subject
   - Description of migration requirements
   - Source and destination information
   - Cumulus Organization
   - Other relevant fields
3. Submit the form
4. Automatically redirected to Migration Details page with the new case ID in the query string
5. On the details page, user can add Transfer records with specific migration specifications

### Multi-Step Process
This form is the first step in a two-part process:
1. **Step 1**: Create Case - Migration Request (this form)
2. **Step 2**: Migration Details form (automatically opens via redirect)

The case ID is passed to the details page via query string parameter `caseid`.

### Redirect URL Pattern
After successful submission:
```
https://portal.example.com/migration-details?caseid={new-case-guid}
```

## Related Components

### Dependencies
- Standard Power Pages form rendering
- Entity permissions on the Case entity
- Web page for Migration Details (ID: 76a41bec-beab-0af0-7292-dc9293f013e3)

### Related Forms
- **Migration Details**: The second step form that loads after this form submits
  - Entity: `revops_transfer`
  - Creates related transfer records linked to the case
  - Uses the caseid parameter to establish relationship
  - Allows adding multiple transfer records for complex migrations

### Related Entities
- **incident** (Case): Primary entity for the migration request
- **revops_transfer**: Related entity for migration transfer details (created in step 2)
- **revops_cumulusorganization**: Organization being migrated
- **contact**: Portal user contact
- **account**: Customer account

### Relationships
- **revops_transfer_case_incident**: Links transfer records to the case (created in step 2)

## Change History

### Current Implementation
- Standard case creation form
- No file attachments
- Redirects to details page with case ID
- No custom JavaScript or automation
- Part of multi-step migration workflow

### Key Features
- **Multi-Step Workflow**: Seamlessly transitions to details form
- **Case ID Propagation**: Passes created case ID to next form
- **Entity Permissions**: Respects security model
- **Standard UX**: Uses out-of-the-box Power Pages form rendering
- **Redirect with Context**: Maintains context by passing case ID
- **Related Records**: Enables creation of multiple transfer records per migration case
