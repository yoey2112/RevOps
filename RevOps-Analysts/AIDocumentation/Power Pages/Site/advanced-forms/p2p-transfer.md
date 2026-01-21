# P2P Transfer - Advanced Form

## Overview
The "P2P Transfer" advanced form is a multistep wizard that guides users through the process of creating and submitting a peer-to-peer (P2P) transfer request. This form provides a structured workflow for CSP transfer requests, with progress indicators to show users where they are in the process.

## Location
Power Pages Site: `.paportal\swdevportal\advanced-forms\p2p-transfer\P2P-Transfer.advancedform.yml`

## Configuration

### Basic Settings
- **Web Form ID**: `c300505a-2287-49ef-98be-51bee83f9677`
- **Name**: P2P Transfer
- **Start Step ID**: `5b0b0111-2242-4042-b10d-66a36d307844`

### Form Behavior
- **Edit Existing Record Permitted**: Yes
- **Multiple Records Per User Permitted**: Yes (users can have multiple concurrent P2P transfer requests)
- **Progress Indicator Enabled**: Yes
- **Progress Indicator Position**: Top (756150000)

## Custom Code
No custom JavaScript files are directly associated with this advanced form configuration. However, the related basic form "Case - Create P2P from Portal" contains extensive custom JavaScript (~1,200 lines) for:
- Organization selection modal
- Conditional required fields
- Form validation
- Dynamic title generation
- Region auto-population

## Workflow

This advanced form orchestrates a multistep workflow for P2P transfer requests. The form starts at step `5b0b0111-2242-4042-b10d-66a36d307844` and includes a progress indicator to guide users through the process.

### Expected Step Flow
Based on the related basic forms and typical P2P transfer workflows:

1. **Step 1: Create Case** (Start Step: `5b0b0111-2242-4042-b10d-66a36d307844`)
   - Use basic form: "Case - Create P2P from Portal"
   - Collect initial case information
   - Select organizations involved in transfer
   - Specify competitor/losing provider
   - Set CSP Transfer ID (if applicable)

2. **Step 2: Transfer Details** (Subsequent Steps)
   - May include additional transfer-specific information
   - Potentially collect billing or technical details
   - Confirmation and submission

### Progress Indicator
The form displays a progress indicator at the top of the page, showing users:
- Current step they're on
- Total number of steps
- Steps completed vs remaining

## Usage
This multistep form is used for CSP P2P transfer requests where customers want to transfer cloud services from one provider/partner to another. Users can:
- Have multiple concurrent transfer requests in progress
- Edit existing transfer requests before submission
- Track their progress through the workflow via the progress indicator
- Return to previous steps if needed (edit existing record permitted)

## Related Components
- **Start Step**: Form step with ID `5b0b0111-2242-4042-b10d-66a36d307844`
- **Basic Form**: `case---create-p2p-from-portal` (Step 1 - most complex form with ~1,200 lines of JS)
- **Entity**: `incident` (case)
- **Web Pages**: 
  - `p2p-transfer` web page
  - `p2p-transfer-deleted` web page (for cancelled transfers)
- **Related Entities**: 
  - `revops_cumulusaccount` (organizations)
  - `account` (Dataverse accounts)
  - `competitor` (losing provider)

## Business Rules
1. **Multiple Transfers Allowed**: Unlike the simple case creation form, users can have multiple P2P transfers in progress simultaneously
2. **Edit Capability**: Users can edit transfer requests before final submission
3. **Organization Validation**: The form validates selected organizations and syncs with Dataverse accounts
4. **Conditional Required Fields**: 
   - CSP Transfer ID required for specific competitor selections
   - Losing Provider required when "Other" is selected as competitor
5. **Auto-Population**: Region field is automatically populated based on country selection

## Change History
- Configured as a multi-session form (multiple records per user permitted)
- Progress indicator enabled for better user experience
- Edit permissions enabled for in-progress modifications
- Complex organization selection logic implemented in Step 1 basic form

## Security Considerations
- Entity permissions should be configured to ensure users can only see/edit their own P2P transfer requests
- Table permissions for `incident`, `revops_cumulusaccount`, and related entities must be properly configured