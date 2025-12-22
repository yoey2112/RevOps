# Profile Web Form (Enhanced) - Test

## Overview
This is a test form for creating or editing Cumulus Account profiles in the portal. It features CAPTCHA protection for all users and appears to be used for testing enhanced profile functionality.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\profile-web-form-(enhanced)---test\`
- **Form ID**: a6c5b3f9-d996-4132-a128-6364410e3879
- **Form Name**: Information

## Configuration

### Entity Details
- **Entity Name**: `revops_cumulusaccount` (Cumulus Account)
- **Form Name**: Information
- **Mode**: Insert (100000000)

### Entity Permissions
- **Enabled**: Yes (`adx_entitypermissionsenabled: true`)

### File Attachments
- **Enabled**: No
- **Maximum Files**: 5 (default)
- **Storage Location**: Azure Blob Storage (756150000)

### Form Behavior
- Standard form rendering
- No special configurations

### Success Behavior
- **On Success**: Display Success Message (756150000)
- **Hide Form**: Yes
- **No Redirect**: Form hides after successful submission

### Security
- **CAPTCHA Required**: Yes
- **Show CAPTCHA for Authenticated Users**: Yes (enabled)

**Important**: This form requires CAPTCHA verification even for authenticated users.

## Custom Code

### JavaScript
**No custom JavaScript** - The form uses standard Power Pages functionality without additional client-side code.

### Liquid
No custom Liquid templates are associated with this form.

## Usage

### Portal User Experience
1. Navigate to the test profile form page
2. Fill in Cumulus Account information fields (as defined in the "Information" form):
   - Account name
   - Account details
   - Contact information
   - Other account-specific fields
3. Complete CAPTCHA verification (required for all users)
4. Submit the form
5. Success message displayed, form hides

### Test Form Purpose
As indicated by the "Test" suffix in the name, this form is likely used for:
- Testing enhanced profile functionality
- Validating Cumulus Account creation workflows
- Development and QA purposes
- Prototyping new profile features

## Related Components

### Dependencies
- Standard Power Pages form rendering
- Entity permissions on the Cumulus Account entity
- CAPTCHA service configuration

### Related Entities
- **revops_cumulusaccount**: Primary entity (Cumulus Account)
- **account**: May be related to standard Dynamics account
- **contact**: Account contacts
- **revops_cumulusorganization**: Organizations under the account

### Integration Points
Cumulus Accounts created via this form may be used in:
- P2P transfer forms (Case - Create P2P from Portal)
- CSP transfer forms
- Google transfer forms
- Organization management
- Customer hierarchies

## Change History

### Current Implementation
- Test form for Cumulus Account creation
- CAPTCHA required for all users (authenticated and unauthenticated)
- No custom JavaScript or Liquid logic
- Basic entity permissions enforcement
- Uses "Information" form from model-driven app

### Key Features
- **Enhanced Security**: CAPTCHA for all users
- **Test Environment**: Designated as test form for validation
- **Entity Permissions**: Respects security model
- **Standard UX**: Uses out-of-the-box Power Pages form rendering
- **Profile Management**: Enables Cumulus Account profile creation
