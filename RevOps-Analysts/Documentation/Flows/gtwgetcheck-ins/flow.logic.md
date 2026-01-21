# Flow Logic: gtwgetcheck-ins

<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: Request
**Kind**: ApiConnection

## Actions (11 total)

### 1. Initialize_Webinar_Token
**Type**: InitializeVariable

### 2. Initialize_client_id
**Type**: InitializeVariable

### 3. Initialize_organizers
**Type**: InitializeVariable

### 4. Initialize_Webinar
**Type**: InitializeVariable

### 5. Get_Event_Details
**Type**: OpenApiConnection

### 6. Initialize_Session_Key
**Type**: InitializeVariable

### 7. HTTP_-_Get_session
**Type**: Http

### 8. Collection_of_SESSIONS_in_JSON_format
**Type**: ParseJson

### 9. HTTP_-_REFRESH_TOKEN
**Type**: Http

### 10. Parse_JSON
**Type**: ParseJson

### 11. Condition_3
**Type**: If

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->
