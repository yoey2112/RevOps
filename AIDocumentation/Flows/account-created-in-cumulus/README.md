# Account Created in Cumulus

## Overview
This Power Automate flow triggers when a new organization (Cumulus Account) is created in the external Cumulus system and synchronizes it to create or update corresponding Account records in Dynamics 365.

## Business Impact
This flow ensures that Cumulus organizations are automatically reflected in the Dynamics 365 CRM system, enabling sales and support teams to manage customer relationships without manual data entry. It supports the RevOps process for tracking cloud service providers, subscriptions, and revenue.

## Trigger
- **Type**: Automated (Service Bus message or HTTP webhook)
- **Condition**: When a new Cumulus Account is created in the external Cumulus system
- **Frequency**: Real-time (triggered by external system events)

## High-Level Logic
1. Receive Cumulus Account creation event from external system
2. Map Cumulus organization data to Dynamics 365 Account schema
3. Check if Account already exists (by external ID or other unique identifier)
4. Create new Account if not found, or update existing Account
5. Log success/failure for audit trail

## Key Actions
- **Parse JSON**: Extract Cumulus Account details from incoming message
- **List Accounts**: Check for existing Account records by unique identifier
- **Condition**: Determine if Account exists
- **Create/Update Account**: Insert new record or update existing with latest data
- **Error Handling**: Log failures to Azure DevOps or send notifications

## Error Handling
- Uses **Scope** actions to wrap critical sections
- **Run After** configuration on error branches
- Failures may trigger notifications to DevOps team or log to Application Insights
- Service Bus messages may be dead-lettered on repeated failures

## Dependencies
- **Tables**: 
  - `account` (Dynamics 365 Account)
  - `revops_cumulusaccount` (Cumulus Account lookup)
- **Connections**: 
  - Microsoft Dataverse
  - Azure Service Bus (for message queue)
  - Visual Studio Team Services (for error logging)
- **Other Flows**: 
  - May trigger **iso-3166-cumulus-account-to-account** flow indirectly via Account updates

## Documentation Files
- `flow.logic.md`: Detailed step-by-step logic (to be created)
- `flow.schema.json`: Exported flow definition from Power Automate
- `diagram.mmd`: Visual workflow diagram (to be created)

## Change History
- **2025-12-15**: Initial documentation created from existing JSON export

## Known Issues / Limitations
- Batch size limited by Service Bus message processing capacity
- No retry logic for failed Account creation (relies on Service Bus retry)
- Requires manual intervention if Cumulus Account data is malformed

---

**Last Updated**: December 15, 2025  
**Owner**: RevOps Development Team



<!-- AI:BEGIN AUTO -->
## Trigger
**Type**: Request (Http)

## Tables Touched
<!-- AI:BEGIN AUTO -->
- [Account](../../Tables/Account/README.md)
- [Contact](../../Tables/Contact/README.md)
- [Lead](../../Tables/Lead/README.md)
- [Opportunity](../../Tables/Opportunity/README.md)
- [revops_cumulusaccounts](../../Tables/revops_cumulusaccounts/README.md)
- [revops_cumulussignups](../../Tables/revops_cumulussignups/README.md)
- [revops_cumulususers](../../Tables/revops_cumulususers/README.md)
- [revops_domains](../../Tables/revops_domains/README.md)
- [systemusers](../../Tables/systemusers/README.md)
<!-- AI:END AUTO -->
- accounts
- revops_cumulusaccounts
- contacts
- revops_cumulususers
- leads
- revops_domains
- systemusers
- revops_cumulussignups
- opportunities

## Connectors Used
- commondataserviceforapps
- commondataserviceforapps
- visualstudioteamservices
- servicebus
- servicebus
- commondataserviceforapps

## Statistics
- Total Actions: 36
- Trigger Type: Request

---
Last Updated By: AI
Source: flow.schema.json
Date: 2025-12-15
Confidence: Medium
<!-- AI:END AUTO -->

