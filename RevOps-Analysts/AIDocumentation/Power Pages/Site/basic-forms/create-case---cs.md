# Create Case - CS

## Overview
This is a basic case creation form for Customer Service (CS) cases. It provides a simple, straightforward interface for portal users to create support cases without any custom JavaScript logic or special automation.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\create-case---cs\`
- **Form ID**: abe3b98c-d546-f011-877a-002248ae15d3
- **Form Name**: Create Case - CS

## Configuration

### Entity Details
- **Entity Name**: `incident` (Case)
- **Form Name**: Create Case - CS
- **Mode**: Insert (100000000)
- **Tab**: General

### Entity Permissions
- **Enabled**: Yes (`adx_entitypermissionsenabled: true`)

### File Attachments
- **Enabled**: Yes
- **Allow Multiple**: No
- **Required**: No
- **Restrict Accept**: No
- **Save Option**: Notes (756150000)
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
- **On Success**: Redirect to Web Page (756150001)
- **Hide Form**: Yes
- **Redirect Page ID**: fae4d40d-9790-4e7e-067e-9a875b38f32b
- **Append Entity ID Query String**: No

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
1. Navigate to the CS case creation page
2. Fill in the case form fields as presented
3. Optionally attach a single file
4. Submit the form
5. Redirected to confirmation page

### Standard Fields
The form displays the standard "Create Case - CS" form fields from Dynamics 365, which typically includes:
- **Title**: Case subject
- **Description**: Case details
- **Customer**: Account or Contact
- **Subject**: Case classification
- **Other standard case fields** as configured in the model-driven form

## Related Components

### Dependencies
- Standard Power Pages form rendering
- Entity permissions on the Case entity
- Web page for redirect after success

### Related Forms
- **Create Case - Support**: Another basic case creation form
- **Create Case - Complain about a Case**: Form with complaint-specific logic
- **Create Case - Escalate a Case**: Form with escalation-specific logic

### Related Entities
- **incident** (Case): Primary entity
- **contact**: Portal user contact
- **account**: Customer account

## Change History

### Current Implementation
- Standard case creation form
- Single file attachment capability
- Redirects to confirmation page on success
- No custom JavaScript or Liquid logic

### Key Features
- **Simplicity**: Straightforward case creation without automation
- **File Attachment**: Supports single file upload
- **Entity Permissions**: Respects security model
- **Standard UX**: Uses out-of-the-box Power Pages form rendering
