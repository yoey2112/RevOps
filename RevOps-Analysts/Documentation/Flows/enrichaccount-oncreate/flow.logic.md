# Flow Logic: enrichaccount-oncreate

<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: OpenApiConnectionWebhook
**Kind**: N/A

## Actions (7 total)

### 1. Get_secret
**Type**: OpenApiConnection

### 2. HTTP
**Type**: Http

### 3. Lookup_Account_created
**Type**: OpenApiConnection

### 4. company
**Type**: InitializeVariable

### 5. Error_404_or_422
**Type**: If

### 6. Terminate
**Type**: Terminate

### 7. geo
**Type**: InitializeVariable

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->
