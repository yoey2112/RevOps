# Active Queues List

## Overview
The Active Queues list displays queue records from Dataverse, allowing portal users to view available support queues.

## Location
Power Pages Site: `.paportal\swdevportal\lists\Active-Queues.list.yml`

## Configuration

### Basic Settings
- **Entity Name**: `queue`
- **Entity List ID**: `490552f7-b040-f011-877a-002248b3648e`
- **View ID**: `240b4abc-99b6-499c-87e2-5c70829ff273`
- **Page Size**: 10 records per page
- **Search Enabled**: Yes
- **Entity Permissions Enabled**: Yes

### Features
- **Calendar**: Disabled
- **Map**: Disabled
- **Filter**: Disabled
- **OData**: Disabled

### Display Settings
- **Grid CSS Class**: Default Power Pages styling
- **ID Query String Parameter**: `id`

## Custom Code
No custom JavaScript is associated with this list (file is empty).

## Usage
This list is used to display active queues to portal users. Entity permissions control which queue records are visible to each user based on their web roles and table permissions.

## Related Components
- Table Permission: `Queue.tablepermission.yml`
- Entity: `queue` (Dataverse)

## Change History
- Initial configuration with entity permissions enabled
- Search functionality enabled for users to find specific queues