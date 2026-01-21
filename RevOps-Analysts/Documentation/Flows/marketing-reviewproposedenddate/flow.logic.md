# Flow Logic: marketing-reviewproposedenddate

<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: Recurrence
**Kind**: N/A

## Actions (23 total)

### 1. CheckCampaignForProposedEndDate
**Type**: OpenApiConnection

### 2. Apply_to_each
**Type**: Foreach

### 3. Initialize_variable_-_StartOfWeek
**Type**: InitializeVariable

### 4. Initialize_variable_30days
**Type**: InitializeVariable

### 5. EndingSoon
**Type**: InitializeVariable

### 6. Expired
**Type**: InitializeVariable

### 7. createTableEndingSoon
**Type**: Table

### 8. createTableExpired
**Type**: Table

### 9. Initialize_null
**Type**: InitializeVariable

### 10. Create_TableNull
**Type**: Table

### 11. ExpiredNoOwner
**Type**: InitializeVariable

### 12. EndingSoonNoOwner
**Type**: InitializeVariable

### 13. createTableExpiredNoOwner
**Type**: Table

### 14. createTableEndingSoonNoOwner
**Type**: Table

### 15. Select_-_owners_of_the_array_expired
**Type**: Select

### 16. Compose_-_unique_owner_expired
**Type**: Compose

### 17. aeach_expired
**Type**: Foreach

### 18. aeach_ending_soon
**Type**: Foreach

### 19. Select_-_owner_of_the_array_ending_soon
**Type**: Select

### 20. Compose_-_unique_owner_ending_soon
**Type**: Compose

*(Plus 3 more actions - see flow.schema.json for complete list)*

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->
