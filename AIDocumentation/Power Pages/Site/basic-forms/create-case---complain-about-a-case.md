# Create Case - Complain about a Case

## Overview
This basic form allows portal users to file a complaint about an existing case. It automatically routes the complaint to the TSS Management queue and links it to the original case as a parent-child relationship. The escalation reason is automatically set to "Complain about a Case".

## Location
- **Path**: `.paportal\swdevportal\basic-forms\create-case---complain-about-a-case\`
- **Form ID**: e8c77cbe-e5b2-44c6-aa2d-2353a16eeffc
- **Form Name**: Create Case - CS - Complain about a Case

## Configuration

### Entity Details
- **Entity Name**: `incident` (Case)
- **Form Name**: Create Case - CS - Complain about a Case
- **Mode**: Insert (100000000)

### Entity Permissions
- **Enabled**: Yes (`adx_entitypermissionsenabled: true`)

### File Attachments
- **Enabled**: No (not configured)
- **Maximum Files**: 5 (default)
- **Storage Location**: Azure Blob Storage (756150000)

### Success Behavior
- **On Success**: Display Success Message (756150000)
- **Hide Form**: Yes
- **Redirect Page ID**: fae4d40d-9790-4e7e-067e-9a875b38f32b

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
Retrieves the TSS Management queue for automatic case routing.

#### 2. Parent Case Lookup
```liquid
{% if request.params.refid %}
{% fetchxml parent_case_lookup %}
<fetch top="1">
  <entity name="incident">
    <attribute name="incidentid" />
    <attribute name="title" />
    <attribute name="ticketnumber" />
    <filter>
      <condition attribute="incidentid" operator="eq" value="{{ request.params.refid }}" />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}
{% endif %}
```
Retrieves the parent case details from the URL parameter `refid`.

### JavaScript Functions

#### 1. Hide Escalation Reason Field
```javascript
function hideField(logicalName) {
  var $field = $("#" + logicalName + ", [name='" + logicalName + "']");
  if ($field.length) {
    var $container = $field.closest('tr, .form-group, .field-wrapper, section, div[class*="field"], td').first();
    if ($container.length) {
      $container.css('display', 'none').css('visibility', 'hidden');
    } else {
      $field.css('display', 'none').css('visibility', 'hidden');
    }
  }
}
hideField('revops_customerescalationreason');
```
Hides the escalation reason field since it's automatically set.

#### 2. Set Escalation Reason
```javascript
var $reasonField = $("#revops_customerescalationreason");
if ($reasonField.length) {
  $reasonField.val('234570001').trigger('change');
}
```
Automatically sets the escalation reason to value `234570001` (Complain about a Case).

#### 3. Queue Prepopulation and Hiding
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

#### 4. Parent Case Prepopulation
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
Populates the parent case from URL parameter `refid` and hides the field.

### Hidden Fields
- `revops_customerescalationreason` - Auto-set to "Complain about a Case"
- `revops_queue` - Auto-set to TSS Management
- `parentcaseid` - Auto-set from URL parameter

### Automatically Populated Fields
1. **Queue**: TSS Management (from FetchXML)
2. **Parent Case ID**: From URL parameter `refid`
3. **Escalation Reason**: Set to `234570001` (Complain about a Case)

## Usage

### Portal User Experience
1. User is viewing an existing case
2. User clicks a link/button that includes `?refid={case-guid}` in the URL
3. Form loads with complaint form
4. User fills in visible fields (Description, etc.)
5. Submits the form
6. New case is created with:
   - Parent Case linked to original case
   - Queue set to TSS Management
   - Escalation Reason set to "Complain about a Case"

### URL Parameter
The form expects the following URL parameter:
- **refid**: GUID of the parent case being complained about

Example URL: `https://portal.example.com/complaint?refid=12345678-1234-1234-1234-123456789abc`

### Data Flow
1. Page loads with `refid` parameter
2. Liquid FetchXML queries execute server-side
3. Parent case details and TSS Management queue loaded
4. JavaScript executes after DOM ready
5. Fields are populated and hidden
6. User only sees relevant input fields
7. Form submission creates child case with all relationships

## Related Components

### Dependencies
- **jQuery**: Used for DOM manipulation and selectors
- **Liquid Templates**: For FetchXML and data injection
- **FetchXML**: Server-side queries for queue and parent case

### Related Forms
- **Create Case - Escalate a Case**: Similar pattern for escalations
- **View - Client Case**: May contain link to this form

### Related Entities
- **incident** (Case): Primary entity and parent case
- **queue**: TSS Management queue for routing

### Relationships
- **incident_parent_incident**: Links the complaint case to the original case

## Change History

### Current Implementation
- Auto-populates TSS Management queue
- Auto-sets escalation reason to "Complain about a Case"
- Links to parent case via URL parameter
- Hides all auto-populated fields
- Uses retry pattern with setTimeout for field availability

### Key Features
- **Simplified UX**: Users only see fields they need to fill
- **Automatic Routing**: Ensures complaints go to TSS Management
- **Case Relationship**: Maintains parent-child relationship for tracking
- **No Manual Configuration**: All routing and classification is automatic
