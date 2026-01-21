# License Adjustment Details

## Overview
This form is the second step in the license adjustment workflow. It allows users to create Transfer records that contain the detailed specifications for license adjustments. The form is linked to a parent Case created via the "Create Case - License Adjustment" form.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\license-adjustment-details\`
- **Form ID**: 830c797e-7dc5-f011-bbd3-7c1e52530041
- **Form Name**: License Adjustment Details

## Configuration

### Entity Details
- **Entity Name**: `revops_transfer` (Transfer)
- **Form Name**: License Adjustment Details
- **Mode**: Insert (100000000)
- **Tab**: Transfer

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
- **On Success**: Display Success Message (756150000)
- **Hide Form**: Yes

### Security
- **CAPTCHA Required**: No
- **Show CAPTCHA for Authenticated Users**: No

### Reference Entity Configuration
This form creates records related to a parent Case:
- **Reference Entity**: incident (Case)
- **Reference Relationship**: revops_transfer_case_incident
- **Reference Source Type**: Query String (756150000)
- **Reference Query Attribute**: incidentid
- **Reference Query String Name**: caseid
- **Reference Target Lookup Attribute**: revops_case
- **Populate Reference Entity Lookup Field**: Yes
- **Set Entity Reference**: Yes

## Custom Code

### JavaScript
**No custom JavaScript** - The form uses standard Power Pages functionality without additional client-side code.

### Liquid
No custom Liquid templates are associated with this form.

## Usage

### Portal User Experience
1. User completes "Create Case - License Adjustment" form
2. After case creation, user is automatically redirected to this form with `?caseid={case-guid}` in URL
3. Form loads with the Case lookup pre-populated
4. User fills in transfer details:
   - Source organization/subscription
   - Destination organization/subscription
   - License quantities (current, requested)
   - SKUs (product identifiers)
   - Adjustment type (increase, decrease, transfer)
   - Dates and timing
   - Other transfer-specific fields
5. User submits the form
6. Transfer record is created and linked to the parent case
7. User can create additional transfer records if needed for complex adjustments

### URL Parameter
The form expects the following URL parameter:
- **caseid**: GUID of the parent case (from License Adjustment case creation)

Example URL: `https://portal.example.com/license-adjustment-details?caseid=12345678-1234-1234-1234-123456789abc`

### Multi-Record Scenario
Users can create multiple Transfer records for a single License Adjustment case:
- Example: Adjusting licenses across 3 different subscriptions
- User submits this form 3 times with different transfer details
- All transfers link to the same parent case

## Related Components

### Dependencies
- Standard Power Pages form rendering
- Entity permissions on the Transfer entity
- Parent case must exist (created via Create Case - License Adjustment form)

### Related Forms
- **Create Case - License Adjustment**: Creates the parent case
  - After submission, redirects to this form
  - Passes case ID via query string

### Related Entities
- **revops_transfer**: Primary entity (Transfer record)
- **incident**: Parent case entity
- **revops_cumulusorganization**: Source and destination organizations
- **product**: License SKUs

### Relationships
- **revops_transfer_case_incident**: Links transfer records to the parent case
  - Cardinality: Many Transfers to One Case
  - Allows multiple license adjustment details per case

## Change History

### Current Implementation
- Standard transfer record creation
- Automatic linking to parent case via query string
- Reference entity configuration auto-populates case lookup
- No custom JavaScript or Liquid logic
- Part of two-step license adjustment workflow

### Key Features
- **Multi-Record Support**: Can create multiple transfers per case
- **Automatic Parent Linking**: Case relationship established automatically
- **Query String Integration**: Seamless navigation from case creation
- **Entity Permissions**: Respects security model
- **Standard UX**: Uses out-of-the-box Power Pages form rendering
- **Related Record Pattern**: Standard Dataverse relationship handling
