# Flow Logic: enrichcontact-oncreate

<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: OpenApiConnectionWebhook
**Kind**: N/A

## Actions (9 total)

### 1. Get_secret
**Type**: OpenApiConnection

### 2. HTTP
**Type**: Http

### 3. Lookup_Contact_created
**Type**: OpenApiConnection

### 4. person
**Type**: InitializeVariable

### 5. company
**Type**: InitializeVariable

### 6. Error_404_or_422
**Type**: If

### 7. Enrich_Contact
**Type**: OpenApiConnection

### 8. Terminate
**Type**: Terminate

### 9. GICSCode_not_empty_or_null
**Type**: If

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->
