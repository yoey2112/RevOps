# Create Case - Escalate a Case

## Overview
This basic form allows portal users to escalate an existing case to management. It automatically routes escalations to the TSS Management queue and links the escalation to the original case as a parent-child relationship.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\create-case---escalate-a-case\`
- **Form ID**: 5e155499-1dca-f011-8544-002248b10b49
- **Form Name**: Create Case - CS - Escalate a Case

## Configuration

### Entity Details
- **Entity Name**: `incident` (Case)
- **Form Name**: Create Case - CS - Escalate a Case
- **Mode**: Insert (100000000)

### Entity Permissions
- **Enabled**: Yes (`adx_entitypermissionsenabled: true`)

### File Attachments
- **Enabled**: No

### Success Behavior
- **On Success**: Display Success Message (756150000)
- **Hide Form**: Yes

### Security
- **CAPTCHA Required**: No
- **Show CAPTCHA for Authenticated Users**: No

## Custom Code

### Liquid FetchXML Queries

#### 1. Escalation Queue Lookup
```liquid
{% fetchxml escalate_queue_lookup %}
<fetch top="1">
  <entity name="queue">
    <attribute name="queueid" />
    <attribute name="name" />
    <filter>
      <condition attribute="name" operator="eq" value="TSS Management" />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}
```
Retrieves the TSS Management queue for automatic escalation routing.

#### 2. Parent Case Lookup
```liquid
{% if request.params.refid %}
{% fetchxml parent_case_lookup %}
<fetch top="1">
  <entity name="incident">
    <attribute name="incidentid" />
    <attribute name="title" />
    <attribute name="ticketnumber" />
    <attribute name="revops_cumulusaccountId" />
    <filter>
      <condition attribute="incidentid" operator="eq" value="{{ request.params.refid }}" />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}
{% endif %}
```
Retrieves the parent case details including Cumulus Account from the URL parameter `refid`.

### JavaScript Functions

#### 1. Queue Prepopulation and Hiding
```javascript
function fillAndHideQueue() {
  var $lookup = $("#revops_queue");
  if (!$lookup.length) {
    return setTimeout(fillAndHideQueue, 200);
  }

  $lookup.val(queueId).trigger("change");
  $("#revops_queue_name").val(queueName);
  $("#revops_queue_entityname").val("queue");

  var $row = $lookup.closest("tr");
  if ($row.length) {
    $row.css('display', 'none');
  } else {
    $lookup.closest("td, div.form-group, div.control").css('display', 'none');
  }
}
```
Populates the queue with TSS Management and hides the field from the user.

#### 2. Parent Case Prepopulation
```javascript
function fillParentCase() {
  if (!parentCaseId) {
    return;
  }

  var $parentCaseId = $("#parentcaseid, #ParentCaseId, input[name='parentcaseid']");
  var $parentCaseNameField = $("#parentcaseid_name, #ParentCaseId_name, input[name='parentcaseid_name']");
  var $parentCaseEntityName = $("#parentcaseid_entityname, #ParentCaseId_entityname, input[name='parentcaseid_entityname']");
  
  if (!$parentCaseId.length) {
    return setTimeout(fillParentCase, 200);
  }

  $parentCaseId.val(parentCaseId).trigger("change");
  if ($parentCaseNameField.length && parentCaseName) {
    $parentCaseNameField.val(parentCaseName);
  }
  if ($parentCaseEntityName.length) {
    $parentCaseEntityName.val("incident");
  }

  var $row = $parentCaseId.closest("tr");
  if ($row.length) {
    $row.css('display', 'none');
  } else {
    $parentCaseId.closest("td, div.form-group, div.control").css('display', 'none');
  }
}
```
Populates the parent case from URL parameter `refid` and hides the field. Also retrieves the Cumulus Account from the parent case.

### Hidden Fields
- `revops_queue` - Auto-set to TSS Management
- `parentcaseid` - Auto-set from URL parameter

### Automatically Populated Fields
1. **Queue**: TSS Management (from FetchXML)
2. **Parent Case ID**: From URL parameter `refid`

## Usage

### Portal User Experience
1. User is viewing an existing case
2. User clicks "Escalate" button/link that includes `?refid={case-guid}` in the URL
3. Escalation form loads
4. User fills in escalation reason and description
5. Submits the form
6. New escalation case is created with:
   - Parent Case linked to original case
   - Queue set to TSS Management
   - Cumulus Account from parent case

### URL Parameter
The form expects the following URL parameter:
- **refid**: GUID of the parent case being escalated

Example URL: `https://portal.example.com/escalate?refid=12345678-1234-1234-1234-123456789abc`

### Data Flow
1. Page loads with `refid` parameter
2. Liquid FetchXML queries execute server-side
3. Parent case details (including Cumulus Account) and TSS Management queue loaded
4. JavaScript executes after DOM ready
5. Fields are populated and hidden
6. User only sees relevant input fields (reason, description)
7. Form submission creates child case with all relationships

## Related Components

### Dependencies
- **jQuery**: Used for DOM manipulation and selectors
- **Liquid Templates**: For FetchXML and data injection
- **FetchXML**: Server-side queries for queue and parent case

### Related Forms
- **Create Case - Complain about a Case**: Similar pattern for complaints
- **View - Client Case**: Contains "Escalate Request" button to trigger this form

### Related Entities
- **incident** (Case): Primary entity and parent case
- **queue**: TSS Management queue for routing
- **revops_cumulusaccount**: Account association from parent case

### Relationships
- **incident_parent_incident**: Links the escalation case to the original case

## Change History

### Current Implementation
- Auto-populates TSS Management queue
- Links to parent case via URL parameter
- Retrieves Cumulus Account from parent case
- Hides all auto-populated fields
- Uses retry pattern with setTimeout for field availability
- Triggered from "Escalate Request" button on View - Client Case form

### Key Features
- **Simplified UX**: Users only see fields they need to fill
- **Automatic Routing**: Ensures escalations go to TSS Management
- **Case Relationship**: Maintains parent-child relationship for tracking
- **Account Preservation**: Carries forward Cumulus Account from parent case
- **No Manual Configuration**: All routing is automatic
