# All Categories - Web List

## Overview
The "All Categories - web" list displays category records from Dataverse for the web portal interface. This list enables users to browse and view knowledge base categories.

## Location
Power Pages Site: `.paportal\swdevportal\lists\All-Categories---web.list.yml`

## Configuration

### Basic Settings
- **Entity Name**: `category`
- **Entity List ID**: `56449953-e463-47ae-a5c1-a8ad30ffefe1`
- **View ID**: `d9f3c7f5-7e80-4dce-b889-4d46e9ce9931`
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
This list is used on the web portal to display knowledge base categories. Users can interact with categories through the configured modal dialogs for viewing, creating, and editing. Entity permissions control which category records are visible and editable for each user.

## Related Components
- Table Permission: `Category-Global-Permission.tablepermission.yml`
- Entity: `category` (Dataverse)
- Web Templates: May be referenced in category browsing pages

## Change History
- Configured with entity permissions for secure access
- Multiple language support (English and French)
- Grid styling with Bootstrap `table-striped` class