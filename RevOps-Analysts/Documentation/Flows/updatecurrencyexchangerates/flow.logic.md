# Flow Logic: updatecurrencyexchangerates

<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: Recurrence
**Kind**: N/A

## Actions (8 total)

### 1. Query_Currency_Exchange_Dataset
**Type**: OpenApiConnection

### 2. Parse_JSON
**Type**: ParseJson

### 3. Filter_array_-_USD
**Type**: Query

### 4. Update_USD_Exchange_Rate
**Type**: OpenApiConnection

### 5. Filter_array_-_EUR
**Type**: Query

### 6. Update_EUR_Exchange_Rate
**Type**: OpenApiConnection

### 7. Filter_array_-_GBP
**Type**: Query

### 8. Update_GBP_Exchange_Rate
**Type**: OpenApiConnection

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->
