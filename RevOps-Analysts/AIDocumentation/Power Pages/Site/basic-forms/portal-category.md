# Portal Category

## Overview
This basic form allows portal users to create new category records. It's a simple form with CAPTCHA protection enabled for all users, including authenticated users.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\portal-category\`
- **Form ID**: 49b01b57-5288-4365-972a-44a06d388676
- **Form Name**: Portal Category

## Configuration

### Entity Details
- **Entity Name**: `category` (Category)
- **Form Name**: Portal Category
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

**Important**: This form requires CAPTCHA verification even for authenticated users, providing an additional layer of security for category creation.

## Custom Code

### JavaScript
**No custom JavaScript** - The form uses standard Power Pages functionality without additional client-side code.

### Liquid
No custom Liquid templates are associated with this form.

## Usage

### Portal User Experience
1. Navigate to category creation page
2. Fill in category details:
   - **Title**: Category name
   - **Description**: Category description
   - Other standard category fields
3. Complete CAPTCHA verification (required for all users)
4. Submit the form
5. Success message displayed, form hides

### CAPTCHA Requirement
Unlike most other forms in the portal, this form requires CAPTCHA for **all users**, including:
- Anonymous users
- Authenticated/logged-in users

This provides additional security for category management operations.

## Related Components

### Dependencies
- Standard Power Pages form rendering
- Entity permissions on the Category entity
- CAPTCHA service configuration

### Related Entities
- **category**: Primary entity for categorization
- Potentially used for:
  - Knowledge article categories
  - Product categories
  - Service categories
  - Other classification systems

### Integration Points
Categories created via this form may be used in:
- Knowledge base article classification
- Product/service organization
- Support case categorization
- Content management systems

## Change History

### Current Implementation
- Standard category creation form
- CAPTCHA required for all users (authenticated and unauthenticated)
- No custom JavaScript or Liquid logic
- Basic entity permissions enforcement

### Key Features
- **Enhanced Security**: CAPTCHA for all users prevents automated category creation
- **Entity Permissions**: Respects security model
- **Standard UX**: Uses out-of-the-box Power Pages form rendering
- **Simple Interface**: Straightforward category creation without complexity
