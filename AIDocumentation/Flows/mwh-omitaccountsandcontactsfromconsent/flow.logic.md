# Flow Logic: mwh-omitaccountsandcontactsfromconsent

<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: OpenApiConnectionWebhook
**Kind**: N/A

## Actions (6 total)

### 1. Delay
**Type**: Wait

### 2. list_contacts
**Type**: OpenApiConnection

### 3. get_account
**Type**: OpenApiConnection

### 4. Apply_to_each
**Type**: Foreach

### 5. update_account
**Type**: OpenApiConnection

### 6. Condition
**Type**: If

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->
