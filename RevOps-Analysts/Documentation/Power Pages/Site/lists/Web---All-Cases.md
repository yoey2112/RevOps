# Web - All Cases List

## Overview
The "Web - All Cases" list displays incident (case) records from Dataverse to portal users. This is the main list for viewing support tickets/cases on the web portal, with multiple view options for filtering cases.

## Location
Power Pages Site: `.paportal\swdevportal\lists\Web---All-Cases.list.yml`

## Configuration

### Basic Settings
- **Entity Name**: `incident`
- **Entity List ID**: `70ca805b-c07d-4a33-b1f7-bbb7d60745ef`
- **Page Size**: 25 records per page
- **Search Enabled**: Yes
- **Entity Permissions Enabled**: Yes
- **OData Enabled**: No

### Multiple Views Available
The list supports three different views that users can switch between:

1. **All requests** (`9f9aa5dc-a537-e511-947e-00155d038c01`)
   - English: "All requests"
   - French: "Tous les demandes"

2. **Open requests** (`2bfe75da-ce0e-e511-9461-00155d038c01`)
   - English: "Open requests"
   - French: "Demandes en cours"

3. **Closed requests** (`700aa010-cf0e-e511-9461-00155d038c01`)
   - English: "Closed requests"
   - French: "Demandes fermées"

### Features
- **Calendar**: Disabled
- **Map**: Disabled
- **Filter**: Disabled

### Display Settings
- **Grid CSS Class**: `table-striped` (Bootstrap styling)
- **Grid Column Width Style**: 1 (Proportional)
- **ID Query String Parameter**: `id`

### Custom Item Actions

#### View Ticket Action
- **Type**: Details Action (CrmEntityFormView-DetailsAction)
- **Button Label** (English): "View Ticket"
- **Record ID Parameter**: `id`
- **Entity Form ID**: `b3225fea-7199-4dba-9ed5-baa1a46ada02`
- **Target Type**: 0 (Current window)
- **Show Modal**: 0 (No)
- **Action Index**: 0

This action allows users to view the full details of a case/ticket by clicking a "View Ticket" button.

### Modal Dialogs Configured
- **Details Form Dialog**: For viewing case details (Size: Large)
- **Edit Form Dialog**: For editing cases (Size: Large)
- **Create Form Dialog**: For creating new cases (Size: Large)
- **Create Related Record Dialog**: For creating related records (Size: Large)
- **Delete Dialog**: For confirming deletions (Size: Small)
- **Workflow Dialog**: For workflow actions (Size: Small)
- **Error Dialog**: For displaying errors (Size: Small)
- **Close Incident Dialog**: For closing cases (Size: Small)
- **Resolve Case Dialog**: For resolving cases (Size: Small)
- **Reopen Case Dialog**: For reopening cases (Size: Small)
- **Cancel Case Dialog**: For canceling cases (Size: Small)
- **Get Directions Dialog**: For map directions (Size: Large)

### Localization
Supports multiple languages:
- **LCID 1033**: English (United States)
- **LCID 1036**: French (France)

## Custom Code
No custom JavaScript is associated with this list (file is empty).

## Usage
This is the primary list for displaying support cases/tickets on the web portal. Users can:
- View all their cases, open cases, or closed cases using the view selector
- Search for specific cases
- Click "View Ticket" to see full case details
- Page through cases with 25 records per page

Entity permissions control which cases each user can see based on their relationship to the case (e.g., customer, account contact).

## Related Components
- **Table Permissions**:
  - `Cases-where-contact-is-customer.tablepermission.yml`
  - `Cases-where-account-of-the-contact-is-customer.tablepermission.yml`
  - `Case-Create.tablepermission.yml`
- **Entity Form**: `b3225fea-7199-4dba-9ed5-baa1a46ada02` (View Ticket form)
- **Entity**: `incident` (Dataverse)
- **Web Pages**: Likely used on `my-tickets`, `tickets`, or `view-case` pages
- **Related Lists**: Case-related activity, notes, and attachments

## Change History
- Configured with entity permissions for secure access
- Multiple views for filtering (All, Open, Closed requests)
- Custom "View Ticket" action button configured
- Bilingual support (English and French)
- Larger page size (25) compared to other lists for better case browsing
- Case-specific dialogs configured (Close, Resolve, Reopen, Cancel)

## Security Considerations
- Entity permissions are enabled to ensure users only see their own cases
- Table permissions should be configured to restrict case access by customer/account
- The "View Ticket" action navigates to a form with ID `b3225fea-7199-4dba-9ed5-baa1a46ada02` - ensure this form also has proper security