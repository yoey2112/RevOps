# Cumulus Accounts - Portal Test List

## Overview
The "Cumulus Accounts - Portal Test" list displays custom Cumulus account records (`revops_cumulusaccount`) from Dataverse. This appears to be a test or development list for viewing Cumulus account data.

## Location
Power Pages Site: `.paportal\swdevportal\lists\Cumulus-Accounts---Portal-Test.list.yml`

## Configuration

### Basic Settings
- **Entity Name**: `revops_cumulusaccount` (Custom Entity)
- **Entity List ID**: `98f05f59-3ae1-4bdd-a731-0e5b7a72471f`
- **View ID**: `f43ca832-7fac-4d40-8127-b9f6a4ae93a3`
- **Page Size**: 10 records per page
- **Search Enabled**: Yes
- **Search Placeholder Text**: Empty (default)
- **Empty List Text**: Empty (default)

### Features
- **Calendar**: Not configured
- **Map**: Configuration present but likely disabled
  - Map Distance Values: 5, 10, 25, 50, 100
  - Map Rest URL: `https://dev.virtualearth.net/REST/v1/Locations`
  - Map Zoom: 12
  - Map Info Box Offset Y: 46
  - Map Pushpin Height: 39
- **Filter**: Disabled
- **Entity Permissions**: Not explicitly enabled (unlike other lists)

### Display Settings
- **Grid CSS Class**: `table-striped` (Bootstrap styling)
- **Grid Column Width Style**: 1 (Proportional)
- **ID Query String Parameter**: `id`

### Modal Dialogs Configured
- **Details Form Dialog**: For viewing Cumulus account details (Size: Large)
- **Edit Form Dialog**: For editing Cumulus accounts (Size: Large)
- **Create Form Dialog**: For creating new Cumulus accounts (Size: Large)
- **Create Related Record Dialog**: For creating related records (Size: Large)
- **Delete Dialog**: For confirming deletions (Size: Small)
- **Workflow Dialog**: For workflow actions (Size: Small)
- **Error Dialog**: For displaying errors (Size: Small)
- **Activate Dialog**: For activating records (Size: Small)
- **Deactivate Dialog**: For deactivating records (Size: Small)
- **Get Directions Dialog**: For map directions (Size: Large)

### Localization
Supports multiple languages:
- **LCID 1033**: English (United States)
- **LCID 1036**: French (France)

## Custom Code
No custom JavaScript is associated with this list (file is empty).

## Usage
This list is used for testing or viewing Cumulus account records in the portal. The name suggests it's a test/development component. Cumulus accounts are custom entities specific to the RevOps system, likely representing cloud service accounts or organizational accounts.

**Note**: Entity permissions are not explicitly enabled on this list, which may be intentional for testing purposes but should be reviewed for production use.

## Related Components
- Table Permission: `Cumulus-Account-of-the-Contact.tablepermission.yml`, `Cumulus-Account-of-Cumulus-User.tablepermission.yml`
- Entity: `revops_cumulusaccount` (Custom Dataverse Entity)
- May be related to other Cumulus-related web pages or forms

## Change History
- Created as a portal test component for Cumulus accounts
- Search functionality enabled
- Multiple language support configured (English and French)
- Grid styling with Bootstrap `table-striped` class

## Security Considerations
- Entity permissions are NOT explicitly enabled on this list
- This may be intentional for testing, but should be reviewed if used in production
- Ensure appropriate table permissions are configured for the `revops_cumulusaccount` entity