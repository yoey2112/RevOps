# Flow Logic: enrichlead-oncreate

<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: OpenApiConnectionWebhook
**Kind**: N/A

## Actions (12 total)

### 1. Lookup_Lead_created
**Type**: OpenApiConnection

### 2. Update_Lead
**Type**: OpenApiConnection

### 3. Get_secret
**Type**: OpenApiConnection

### 4. HTTP
**Type**: Http

### 5. Terminate
**Type**: Terminate

### 6. Error_404_or_422
**Type**: If

### 7. countryCode_not_empty_or_null
**Type**: If

### 8. person
**Type**: InitializeVariable

### 9. company
**Type**: InitializeVariable

### 10. Clearbit_stateorprovince
**Type**: InitializeVariable

### 11. Update_Lead_stateorprovince
**Type**: OpenApiConnection

### 12. GICSCode_not_empty_or_null
**Type**: If

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->
