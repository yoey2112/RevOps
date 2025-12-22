# All Categories List

## Overview
The "All Categories" list displays category records from Dataverse. This is similar to the "All Categories - web" list but may be used in different contexts or pages within the portal.

## Location
Power Pages Site: `.paportal\swdevportal\lists\All-Categories.list.yml`

## Configuration

### Basic Settings
- **Entity Name**: `category`
- **Entity List ID**: `5988fa1b-0b99-4e40-8fae-0f74ac4dea6a`
- **View ID**: `d9f3c7f5-7e80-4dce-b889-4d46e9ce9931` (same view as All Categories - web)
- **Page Size**: 10 records per page
- **Entity Permissions Enabled**: Yes

### Features
- **Calendar**: Disabled
- **Map**: Disabled
- **Filter**: Disabled
- **Search**: Default configuration

### Display Settings
- **Grid CSS Class**: `table-striped` (Bootstrap styling)
- **Grid Column Width Style**: 1 (Proportional)
- **ID Query String Parameter**: `id`

### Modal Dialogs Configured
- **Details Form Dialog**: For viewing category details (Size: Large)
- **Edit Form Dialog**: For editing categories (Size: Large)
- **Create Form Dialog**: For creating new categories (Size: Large)
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
This list displays knowledge base categories in the portal. It shares the same view configuration as "All Categories - web" but has a different entity list ID, suggesting it may be used in a different page or context. Entity permissions control access to category records.

## Related Components
- Table Permission: `Category-Global-Permission.tablepermission.yml`
- Entity: `category` (Dataverse)
- Related List: `All-Categories---web.list.yml` (similar configuration)
- Web Templates: May be referenced in category browsing pages

## Change History
- Configured with entity permissions for secure access
- Multiple language support (English and French)
- Grid styling with Bootstrap `table-striped` class
- Uses the same Dataverse view as the "All Categories - web" list