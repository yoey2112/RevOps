# API Cumulus Orgs Web Template

## Overview
This web template provides a JSON API endpoint that returns Cumulus Organizations associated with a given Cumulus Account. It's designed to be consumed by JavaScript/AJAX calls for dynamic data retrieval.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\api-cumulus-orgs\`

## Configuration
- **Template ID**: `a43ba45f-1ebf-f011-bbd3-7ced8da6729f`
- **Template Name**: `api-cumulus-orgs`
- **Response Type**: `application/json`
- **Layout**: None (API endpoint)

## Custom Code

### Liquid Template Logic

**Input Parameters:**
- `accountid` (query parameter) - GUID of the Cumulus Account

**FetchXML Query:**
```liquid
{% fetchxml cumulus_orgs %}
<fetch no-lock='true' top='500'>
  <entity name='revops_cumulusorganization'>
    <attribute name='revops_cumulusorganizationid' />
    <attribute name='revops_name' />
    <filter>
      <condition attribute='revops_cumulusaccount' operator='eq' value='{{ accountid }}' />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}
```

**Key Features:**
1. **GUID Validation**: Uses regex pattern to validate accountid format before querying
   - Pattern: `^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`
   
2. **Security**: Requires table permissions on `revops_cumulusorganization` entity
   - Site Setting "Enable Table Permissions" must be `true`
   - Read permission must be assigned to user's web role

3. **JSON Response Format**:
   ```json
   {
     "value": [
       {
         "revops_cumulusorganizationid": "guid",
         "revops_name": "Organization Name"
       }
     ]
   }
   ```

4. **Error Handling**: Returns error object if accountid is invalid or missing:
   ```json
   { "value": [], "error": "invalid_or_missing_accountid" }
   ```

5. **Performance**: 
   - `no-lock='true'` for read consistency
   - Limited to top 500 records
   - Downcase conversion for accountid parameter

## Usage
This API endpoint is called via AJAX/fetch to populate dropdowns or lists of Cumulus Organizations filtered by parent Account.

**Example JavaScript Usage:**
```javascript
const accountId = 'a43ba45f-1ebf-f011-bbd3-7ced8da6729f';
fetch(`/api-cumulus-orgs?accountid=${accountId}`)
  .then(response => response.json())
  .then(data => {
    if (data.error) {
      console.error('Error:', data.error);
    } else {
      // Process organizations in data.value
    }
  });
```

## Related Components
- Custom table: `revops_cumulusorganization`
- Custom table: `revops_cumulusaccount` (lookup relationship)
- Table Permissions for `revops_cumulusorganization`
- Web Roles with appropriate permissions

## Change History
- Initial implementation for Cumulus Account/Organization hierarchy
- Implements security via table permissions
- Returns data as JSON for client-side consumption
