# Create Case - License Adjustment

## Overview
This basic form allows portal users to request license adjustments for their subscriptions. Upon successful submission, the form redirects to a License Adjustment Details page where additional transfer details can be entered.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\create-case---license-adjustment\`
- **Form ID**: 338186eb-7cc5-f011-bbd3-7c1e52530041
- **Form Name**: Create Case - License Adjustment

## Configuration

### Entity Details
- **Entity Name**: `incident` (Case)
- **Form Name**: Create Case - License Adjustment
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
- **Redirect Page ID**: 41962b14-4da8-858a-c6b4-480ccfe0de69
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
1. Navigate to the License Adjustment request page
2. Fill in case details:
   - Case title/subject
   - Description of license adjustment needed
   - Cumulus Organization
   - Other relevant fields
3. Submit the form
4. Automatically redirected to License Adjustment Details page with the new case ID in the query string
5. On the details page, user can add Transfer records with specific license adjustment information

### Multi-Step Process
This form is the first step in a two-part process:
1. **Step 1**: Create Case - License Adjustment (this form)
2. **Step 2**: License Adjustment Details form (automatically opens via redirect)

The case ID is passed to the details page via query string parameter `caseid`.

### Redirect URL Pattern
After successful submission:
```
https://portal.example.com/license-adjustment-details?caseid={new-case-guid}
```

## Related Components

### Dependencies
- Standard Power Pages form rendering
- Entity permissions on the Case entity
- Web page for License Adjustment Details (ID: 41962b14-4da8-858a-c6b4-480ccfe0de69)

### Related Forms
- **License Adjustment Details**: The second step form that loads after this form submits
  - Entity: `revops_transfer`
  - Creates related transfer records linked to the case
  - Uses the caseid parameter to establish relationship

### Related Entities
- **incident** (Case): Primary entity for the license adjustment request
- **revops_transfer**: Related entity for license adjustment details (created in step 2)
- **revops_cumulusorganization**: Organization requiring license adjustment
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
- Part of multi-step license adjustment workflow

### Key Features
- **Multi-Step Workflow**: Seamlessly transitions to details form
- **Case ID Propagation**: Passes created case ID to next form
- **Entity Permissions**: Respects security model
- **Standard UX**: Uses out-of-the-box Power Pages form rendering
- **Redirect with Context**: Maintains context by passing case ID
