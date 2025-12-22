# Migration Details

## Overview
This form is the second step in the migration request workflow. It allows users to create Transfer records that contain detailed migration specifications. The form is linked to a parent Case created via the "Create Case - Migration Request" form and includes an action button to create additional related cases.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\migration-details\`
- **Form ID**: a52f7e6b-74ba-f011-bbd3-7c1e52530041
- **Form Name**: Migration Details

## Configuration

### Entity Details
- **Entity Name**: `revops_transfer` (Transfer)
- **Form Name**: Migration Details
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

### Form Actions
The form includes a **Create Related Record Action**:
- **Action Type**: CreateRelatedRecordAction
- **Target Entity**: incident (Case)
- **Entity Form ID**: ead2d143-74ba-f011-bbd3-7c1e52530041 (Create Case - Migration Request)
- **Relationship**: revops_transfer_case_incident
- **Show Modal**: Yes (opens in modal dialog)
- **Action Button Style**: Standard (0)
- **Action Button Placement**: Bottom (1)
- **Action Button Alignment**: Left (0)
- **Success Message**: "The record has been saved."

This action allows users to create additional migration case records from within the transfer details form.

### Modal Dialog Configurations
The form includes comprehensive modal configurations for:
- **Delete Dialog**: For removing transfer records
- **Workflow Dialog**: For triggering workflows
- **Activate/Deactivate Dialogs**: For record state management
- **Create Related Record Dialog**: For creating additional cases

All dialogs support bilingual labels (English - LCID 1033, French - LCID 1036).

## Custom Code

### JavaScript
**No custom JavaScript** - The form uses standard Power Pages functionality without additional client-side code.

### Liquid
No custom Liquid templates are associated with this form.

## Usage

### Portal User Experience
1. User completes "Create Case - Migration Request" form
2. After case creation, user is automatically redirected to this form with `?caseid={case-guid}` in URL
3. Form loads with the Case lookup pre-populated
4. User fills in migration transfer details:
   - Source system/organization
   - Destination system/organization
   - Data types to migrate (email, files, calendar, contacts, etc.)
   - Migration date/schedule
   - Volume estimates
   - Special requirements
   - Other migration-specific fields
5. User can optionally click the action button to create an additional related case
6. User submits the form
7. Transfer record is created and linked to the parent case
8. User can create additional transfer records if needed for complex multi-phase migrations

### URL Parameter
The form expects the following URL parameter:
- **caseid**: GUID of the parent case (from Migration Request case creation)

Example URL: `https://portal.example.com/migration-details?caseid=12345678-1234-1234-1234-123456789abc`

### Multi-Record Scenario
Users can create multiple Transfer records for a single Migration case:
- Example: Migrating 5 different mailboxes in phases
- User submits this form 5 times with different transfer details
- All transfers link to the same parent case
- Each transfer can have different timelines and specifications

### Create Related Case Action
From within the migration details form, users can:
1. Click the "Create Related Record" action button
2. Modal opens with a new case creation form
3. Create an additional migration case
4. New case is automatically related to the current transfer record
5. Modal closes and user returns to the transfer form

## Related Components

### Dependencies
- Standard Power Pages form rendering
- Entity permissions on the Transfer entity
- Parent case must exist (created via Create Case - Migration Request form)
- Modal dialog support (Bootstrap-based)

### Related Forms
- **Create Case - Migration Request**: Creates the parent case
  - After submission, redirects to this form
  - Passes case ID via query string
  - Can also be opened from this form via Create Related Record action

### Related Entities
- **revops_transfer**: Primary entity (Transfer record)
- **incident**: Parent case entity
- **revops_cumulusorganization**: Source and destination organizations
- **contact**: Portal user contact
- **account**: Customer account

### Relationships
- **revops_transfer_case_incident**: Links transfer records to the parent case
  - Cardinality: Many Transfers to One Case
  - Allows multiple migration phases per case
  - Also supports creating additional related cases

## Change History

### Current Implementation
- Standard transfer record creation
- Automatic linking to parent case via query string
- Reference entity configuration auto-populates case lookup
- Create Related Record action for additional cases
- Modal dialog support
- Bilingual configuration (English/French)
- No custom JavaScript or Liquid logic
- Part of two-step migration workflow

### Key Features
- **Multi-Record Support**: Can create multiple transfers per case
- **Automatic Parent Linking**: Case relationship established automatically
- **Query String Integration**: Seamless navigation from case creation
- **Create Related Case Action**: Ability to spawn additional migration cases
- **Modal Dialogs**: In-form creation of related records
- **Entity Permissions**: Respects security model
- **Standard UX**: Uses out-of-the-box Power Pages form rendering
- **Complex Migration Support**: Handles multi-phase, multi-system migrations
- **Bilingual Support**: English and French localization
