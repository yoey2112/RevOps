# View - Client Case

## Overview
This is a comprehensive case viewing and management form that allows portal users to view and edit their submitted cases. It features tier-based conditional display of the "Escalate Request" button, file attachment capabilities, and includes Liquid FetchXML logic to determine escalation button visibility based on account tier and existing escalation status.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\view---client-case\`
- **Form ID**: b3225fea-7199-4dba-9ed5-baa1a46ada02
- **Form Name**: Web - Edit Case

## Configuration

### Entity Details
- **Entity Name**: `incident` (Case)
- **Form Name**: Web - Edit Case
- **Mode**: Edit (100000001)

### Entity Source
- **Source Type**: Query String (756150001)
- **Record ID Query String Parameter**: id

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
- Edit mode for existing case records
- No auto-generation of steps
- Standard field behavior

### Success Behavior
- **On Success**: Display Success Message (756150000)
- **Hide Form**: Yes

### Security
- **CAPTCHA Required**: Yes
- **Show CAPTCHA for Authenticated Users**: No

### Form Actions
The form includes a **Create Related Record Action** for escalations:
- **Action Type**: CreateRelatedRecordAction
- **Target Entity**: incident (Case)
- **Entity Form ID**: 5e155499-1dca-f011-8544-002248b10b49 (Create Case - Escalate a Case)
- **Relationship**: incident_parent_incident
- **Show Modal**: Yes (opens in modal dialog)
- **Button Label**: "Escalate Request" (English), "Escalader cette Requète" (French)
- **Action Button Style**: Standard (0)
- **Action Button Placement**: Bottom (1)
- **Action Button Alignment**: Left (0)

### Modal Dialog Configurations
The form includes comprehensive modal configurations for:
- **Delete Dialog**: For removing cases
- **Workflow Dialog**: For triggering workflows
- **Close Incident Dialog**: For closing cases
- **Resolve Case Dialog**: For marking cases as resolved
- **Reopen Case Dialog**: For reopening closed cases
- **Cancel Case Dialog**: For canceling cases
- **Create Related Record Dialog**: For escalation modal

All dialogs support bilingual labels (English - LCID 1033, French - LCID 1036).

## Custom Code

### Liquid FetchXML Queries

#### 1. Account Tier Lookup
```liquid
{% fetchxml account_tier %}
<fetch top="1">
  <entity name="account">
    <attribute name="revops_tier" />
    <link-entity name="contact" from="parentcustomerid" to="accountid" alias="c">
      <filter>
        <condition attribute="contactid" operator="eq" value="{{ user.id }}" />
      </filter>
    </link-entity>
  </entity>
</fetch>
{% endfetchxml %}
```
Retrieves the tier level of the account associated with the current portal user's contact.

#### 2. Current Case Lookup
```liquid
{% fetchxml current_case %}
<fetch top="1">
  <entity name="incident">
    <attribute name="incidentid" />
    <attribute name="revops_customerescalationreason" />
    <filter>
      <condition attribute="incidentid" operator="eq" value="{{ params.id }}" />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}
```
Retrieves the current case including the escalation reason field.

#### 3. Case with Escalation Check
```liquid
{% fetchxml case_with_escalation %}
<fetch top="1">
  <entity name="incident">
    <attribute name="incidentid" />
    <filter type="and">
      <condition attribute="incidentid" operator="eq" value="{{ params.id }}" />
      <condition attribute="revops_customerescalationreason" operator="not-null" />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}
```
Checks if the current case already has an escalation reason value (indicating it's already escalated).

#### 4. Liquid Variable Assignment
```liquid
{% assign has_escalation_value = false %}
{% if case_with_escalation.results.entities.size > 0 %}
  {% assign has_escalation_value = true %}
{% endif %}
```
Sets a boolean flag indicating whether the case already has an escalation.

### JavaScript Logic (Partial)

The JavaScript is incomplete in the source file, but the beginning shows the intended logic:

```javascript
(function() {
  'use strict';

  $(function() {
    // Get tier from account
    var tier = '{{ account_tier.results.entities[0].revops_tier | default: "" | downcase | strip | replace: " ", "" }}';
    
    // Check if escalation reason field has a value
    var hasEscalationValue = {{ has_escalation_value }};
    
    // Check if tier is 1 or 2 AND escalation reason is empty
    var isTier1or2 = ["tier1", "tier2", "1", "2"].includes(tier);
    var hasNoEscalation = !hasEscalationValue;
    var shouldShowButton = isTier1or2 && hasNoEscalation;
```

### Escalation Button Visibility Logic
The "Escalate Request" button is shown only when:
1. **Account Tier is 1 or 2** (Tier 1 or Tier 2 customers)
2. **AND Case has NOT been escalated** (revops_customerescalationreason is empty)

**Business Rule**: Only Tier 1 and Tier 2 customers can escalate cases, and each case can only be escalated once.

## Usage

### Portal User Experience

#### Viewing a Case
1. User navigates to case list and clicks on a case
2. URL includes case ID: `/view-case?id={case-guid}`
3. Form loads in edit mode with case details
4. User can view:
   - Case title and description
   - Case status and priority
   - Assigned owner/queue
   - Creation and modification dates
   - Case history and notes
   - File attachments

#### Editing a Case
1. User modifies editable fields (description, priority, etc.)
2. Optionally attaches files (up to 5 files)
3. Completes CAPTCHA if required
4. Submits changes
5. Case is updated in Dataverse

#### Escalating a Case (Tier 1 & 2 Only)
1. If user's account is Tier 1 or 2 AND case hasn't been escalated:
   - "Escalate Request" button is visible
2. User clicks "Escalate Request" button
3. Modal opens with escalation form (Create Case - Escalate a Case)
4. User fills in escalation reason and details
5. Submits escalation
6. Child escalation case is created and linked to parent case
7. Case is routed to TSS Management queue
8. Modal closes

#### Escalation Button Not Shown When:
- Account tier is 3, 4, 5, or other (not Tier 1 or 2)
- Case already has an escalation reason value
- User has already escalated this case

### URL Parameter
The form requires the following URL parameter:
- **id**: GUID of the case to view/edit

Example URL: `https://portal.example.com/view-case?id=12345678-1234-1234-1234-123456789abc`

## Related Components

### Dependencies
- **jQuery**: Used for DOM manipulation
- **Liquid Templates**: For FetchXML and conditional logic
- **FetchXML**: Server-side queries for tier and escalation checks
- **Bootstrap Modals**: For escalation form dialog
- **CAPTCHA Service**: For form submission security

### Related Forms
- **Create Case - Escalate a Case**: Opened in modal when escalate button clicked
  - Creates child escalation case
  - Links to parent case via incident_parent_incident relationship
  - Routes to TSS Management queue

### Related Entities
- **incident** (Case): Primary entity
- **account**: Customer account with tier information
- **contact**: Portal user contact (linked to account)
- **revops_customerescalationreason**: Option set field indicating escalation status
- **annotation**: File attachments
- **queue**: Case assignment (TSS Management for escalations)

### Relationships
- **incident_parent_incident**: Links escalation cases to original cases
- **account → contact**: Determines user's account tier
- **contact → case**: Links portal user to their cases

## Change History

### Current Implementation
- Edit mode for case viewing and updates
- Tier-based escalation button visibility (Tier 1 & 2 only)
- Single escalation per case (checked via revops_customerescalationreason)
- File attachment support (up to 5 files)
- Modal-based escalation workflow
- Bilingual support (English/French)
- FetchXML-based tier and escalation status checks
- Comprehensive case management actions (close, resolve, reopen, cancel)

### Key Features
- **Tier-Based Access Control**: Only Tier 1 and 2 customers see escalate button
- **Single Escalation Rule**: Each case can only be escalated once
- **Modal Escalation**: Escalate without leaving the case view
- **File Attachments**: Add documentation and evidence to cases
- **Case Management Actions**: Full lifecycle management (close, resolve, reopen, cancel)
- **Bilingual Support**: English and French localization
- **Entity Permissions**: Respects security model
- **CAPTCHA Protection**: Prevents automated case updates
- **Related Record Creation**: Creates child escalation cases via relationship
