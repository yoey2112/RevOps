# Flow Logic: formsubmission-utmshenanigansenrichmentconsentproc

<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: OpenApiConnectionWebhook
**Kind**: N/A

## Actions (23 total)

### 1. Initialize_variable_-_UTM_Campaign
**Type**: InitializeVariable

### 2. Initialize_variable_-_UTM_Medium
**Type**: InitializeVariable

### 3. Initialize_variable_-_UTM_Source
**Type**: InitializeVariable

### 4. Compose_-_utms
**Type**: Compose

### 5. Compose_-_split_utm_strings
**Type**: Compose

### 6. Apply_to_each
**Type**: Foreach

### 7. Compose_#
**Type**: Compose

### 8. Initialize_variable_-_GCLID
**Type**: InitializeVariable

### 9. Initialize_variable_-_GAD_Source
**Type**: InitializeVariable

### 10. Initialize_variable_-_UTM_Content
**Type**: InitializeVariable

### 11. Initialize_variable_-_UTM_Keyword
**Type**: InitializeVariable

### 12. Initialize_variable_-_li_fat_id
**Type**: InitializeVariable

### 13. Initialize_variable_-_Reddit_CID
**Type**: InitializeVariable

### 14. Initialize_variable_-__gl
**Type**: InitializeVariable

### 15. Delay
**Type**: Wait

### 16. Get_form_sub
**Type**: OpenApiConnection

### 17. Get_created_entity
**Type**: OpenApiConnection

### 18. Linked_to_contact
**Type**: If

### 19. Linked_to_lead
**Type**: If

### 20. List_field_submissions
**Type**: OpenApiConnection

*(Plus 3 more actions - see flow.schema.json for complete list)*

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->
