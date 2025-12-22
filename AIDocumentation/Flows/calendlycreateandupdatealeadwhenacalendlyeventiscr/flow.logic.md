# Flow Logic: calendlycreateandupdatealeadwhenacalendlyeventiscr

<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: OpenApiConnectionWebhook
**Kind**: N/A

## Actions (19 total)

### 1. Find_lead_by_email
**Type**: OpenApiConnection

### 2. Does_owner_exist
**Type**: If

### 3. Initialize_Lead_ID
**Type**: InitializeVariable

### 4. Initialize_Invitee_First_Name
**Type**: InitializeVariable

### 5. Initialize_Invitee_Last_Name
**Type**: InitializeVariable

### 6. Was_first_name_and_last_name_provided
**Type**: If

### 7. Initialize_Owner_ID
**Type**: InitializeVariable

### 8. Find_Owner_by_email
**Type**: OpenApiConnection

### 9. Create_Appointment
**Type**: OpenApiConnection

### 10. Initialize_Answers
**Type**: InitializeVariable

### 11. Initialize_Calendly_Slug
**Type**: InitializeVariable

### 12. Apply_to_each_(answers)
**Type**: Foreach

### 13. For_each_API
**Type**: Foreach

### 14. Get_Event_Type
**Type**: OpenApiConnection

### 15. Compose_event_type
**Type**: Compose

### 16. Initialize_event_type
**Type**: InitializeVariable

### 17. Set_variable_event_type
**Type**: SetVariable

### 18. Lead_update_or_create
**Type**: If

### 19. Is_Managed_or_secret_Calendly_event
**Type**: If

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->
