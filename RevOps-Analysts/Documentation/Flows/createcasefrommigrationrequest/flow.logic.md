# Flow Logic: createcasefrommigrationrequest

<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: OpenApiConnectionWebhook
**Kind**: N/A

## Actions (12 total)

### 1. Get_Queue
**Type**: OpenApiConnection

### 2. Update_Transfer
**Type**: OpenApiConnection

### 3. For_each_queue
**Type**: Foreach

### 4. Initialize_variable_-_queue
**Type**: InitializeVariable

### 5. Initialize_variable_-_subject
**Type**: InitializeVariable

### 6. Get_Subject_-_Migration
**Type**: OpenApiConnection

### 7. For_each_subject
**Type**: Foreach

### 8. Get_Cumulus_Account
**Type**: OpenApiConnection

### 9. For_each_Cumulus_Account
**Type**: Foreach

### 10. Initialize_variable_-_account
**Type**: InitializeVariable

### 11. Initialize_variable_-_cumulus_account
**Type**: InitializeVariable

### 12. Create_Case
**Type**: OpenApiConnection

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->
