# Create Case - Support

## Overview
This is a standard support case creation form for portal users. It provides a straightforward interface for users to submit general support requests with optional file attachments.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\create-case---support\`
- **Form ID**: 9fd81bdb-3b42-f011-877a-002248ae15d3
- **Form Name**: Create Case - Support

## Configuration

### Entity Details
- **Entity Name**: `incident` (Case)
- **Form Name**: Create Case - Support
- **Mode**: Insert (100000000)
- **Tab**: General
- **Target Lookup Attribute**: contactid

### Entity Permissions
- **Enabled**: Yes (`adx_entitypermissionsenabled: true`)

### File Attachments
- **Enabled**: Yes
- **Accept Types**: */* (all file types)
- **Allow Multiple**: No
- **Required**: No
- **Restrict Accept**: No
- **Maximum Files**: 5
- **Storage Location**: Azure Blob Storage (756150000)
- **Save Option**: Notes (756150000)

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

### Advanced Settings
The form includes comprehensive modal dialog configurations for:
- Delete dialogs
- Workflow dialogs
- Close incident dialogs
- Resolve case dialogs
- Reopen case dialogs
- Cancel case dialogs
- Create related record dialogs

All dialog configurations support localization for English (LCID 1033) and French (LCID 1036).

## Custom Code

### JavaScript
**No custom JavaScript** - The form uses standard Power Pages functionality without additional client-side code.

### Liquid
No custom Liquid templates are associated with this form.

## Usage

### Portal User Experience
1. Navigate to the support case creation page
2. Fill in case details:
   - **Title**: Brief description of the issue
   - **Description**: Detailed explanation of the problem
   - **Priority**: Urgency level
   - **Subject**: Case category/classification
   - Other visible fields as configured
3. Optionally attach files (up to 5 files)
4. Submit the form
5. Redirected to confirmation page

### Standard Fields
The form displays the standard "Create Case - Support" form fields from Dynamics 365, which typically includes:
- **Title**: Case subject
- **Description**: Detailed case information
- **Customer**: Account or Contact (auto-populated from portal user)
- **Contact**: Portal user contact (linked via contactid)
- **Priority**: Case priority level
- **Subject**: Case classification
- **Other standard case fields** as configured in the model-driven form

## Related Components

### Dependencies
- Standard Power Pages form rendering
- Entity permissions on the Case entity
- Web page for redirect after success
- Azure Blob Storage for file attachments

### Related Forms
- **Create Case - CS**: Another basic case creation form
- **View - Client Case**: Form for viewing and managing submitted cases
- **Create Case - Escalate a Case**: For escalating support cases

### Related Entities
- **incident** (Case): Primary entity
- **contact**: Portal user contact (auto-associated via contactid)
- **account**: Customer account
- **subject**: Case subject/category
- **annotation**: File attachments stored as notes

### Action Configurations
The form settings include configurations for various case management actions:
- **Close Incident**: Allows closing cases with resolution information
- **Resolve Case**: Mark case as resolved with details
- **Reopen Case**: Reopen a closed case
- **Cancel Case**: Cancel a case in progress
- **Workflows**: Execute workflows on the case
- **Delete**: Remove case records
- **Create Related Records**: Create child or related records

All actions support bilingual labels (English/French).

## Change History

### Current Implementation
- Standard support case creation form
- File attachment support (up to 5 files)
- Redirects to confirmation page on success
- No custom JavaScript or Liquid logic
- Contact auto-association via contactid
- Comprehensive modal dialog configurations
- Bilingual support (English/French)

### Key Features
- **File Attachments**: Supports multiple file uploads (up to 5)
- **Entity Permissions**: Respects security model
- **Standard UX**: Uses out-of-the-box Power Pages form rendering
- **Contact Association**: Automatically links case to portal user's contact
- **Modal Dialogs**: Configured for various case management actions
- **Localization**: Supports English and French languages
