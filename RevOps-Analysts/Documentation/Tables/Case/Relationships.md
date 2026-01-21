# Case Table - Relationships

This document maps all relationships between the **Case** (incident) table and other tables.

**Last Generated**: 2025-12-15 08:27:38  
**Source**: revopstables_1_41_0_3 solution export

---

## Relationship Summary

### N:1 Relationships (Case â†’ Other Tables)
Case table has **25 lookup fields** that create N:1 relationships to other tables.

### 1:N Relationships (Other Tables â†’ Case)
These are documented below based on common Dynamics patterns and observed system behavior.

---

## N:1 Relationships FROM Case

These are **lookup fields on the Case table** that reference other tables.

| Field Name | Related Table | Display Name | Relationship Type | Description |
|------------|---------------|--------------|-------------------|-------------|
| `customerid` | `*(Unknown)*` | Customer | customer | Select the customer account or contact to provide a quick link to additional ... |
| `entitlementid` | `System.Xml.XmlElement` | Entitlement | lookup | Choose the entitlement that is applicable for the case. |
| `ownerid` | `LookupType LookupType` | Owner | owner | Owner Id |
| `primarycontactid` | `System.Xml.XmlElement` | Contact | lookup | Select a primary contact for this case. |
| `productid` | `System.Xml.XmlElement` | Product | lookup | Choose the product associated with the case to identify warranty, service, or... |
| `responsiblecontactid` | `System.Xml.XmlElement` | Responsible Contact (Deprecated) | lookup | Choose an additional customer contact who can also help resolve the case. |
| `revops_account` | `*(Unknown)*` |  | lookup |  |
| `revops_competitorregion` | `*(Unknown)*` |  | lookup |  |
| `revops_cumulusaccount` | `*(Unknown)*` |  | lookup |  |
| `revops_cumulusorganization` | `*(Unknown)*` |  | lookup |  |
| `revops_cumulususer` | `*(Unknown)*` |  | lookup |  |
| `revops_followupbykpi` | `*(Unknown)*` |  | lookup |  |
| `revops_losingcompetitor` | `*(Unknown)*` |  | lookup |  |
| `revops_mwhaccount` | `*(Unknown)*` |  | lookup |  |
| `revops_opportunity` | `*(Unknown)*` |  | lookup |  |
| `revops_ownermodifiedby` | `*(Unknown)*` |  | lookup |  |
| `revops_practice` | `*(Unknown)*` |  | lookup |  |
| `revops_queue` | `*(Unknown)*` |  | lookup |  |
| `revops_reassignedby` | `*(Unknown)*` |  | lookup |  |
| `revops_relatedcases` | `*(Unknown)*` |  | lookup |  |
| `revops_service` | `*(Unknown)*` |  | lookup |  |
| `revops_solution` | `*(Unknown)*` |  | lookup |  |
| `revops_subsolution` | `*(Unknown)*` |  | lookup |  |
| `slaid` | `System.Xml.XmlElement` | SLA | lookup | Choose the service level agreement (SLA) that you want to apply to the case r... |
| `subjectid` | `System.Xml.XmlElement` | Sujet | lookup | Choisissez le sujet de l'incident, comme une demande de catalogue ou une plai... |

---

## 1:N Relationships TO Case

These tables have **lookup fields that point to Case**.

### Activities Related to Case
<!-- AI:BEGIN AUTO -->
- **Email** (ctivitypointer.regardingobjectid)
  - Purpose: Emails sent/received about this case
  - Common Use: Customer correspondence, internal notes

- **Phone Call** (phonecall.regardingobjectid)
  - Purpose: Phone call activities logged to case
  - Common Use: Support call logging

- **Task** (	ask.regardingobjectid)
  - Purpose: Tasks related to resolving case
  - Common Use: Follow-up tasks, internal assignments

- **Appointment** (ppointment.regardingobjectid)
  - Purpose: Scheduled meetings about case
  - Common Use: Customer calls, onboarding sessions
<!-- AI:END AUTO -->

### Case Escalations
<!-- AI:BEGIN AUTO -->
- **Case (Self-Referencing)** (incident.parentcaseid)
  - Purpose: Child escalation cases
  - Common Use: Escalating a case creates a child case linked to parent
  - Business Rule: Only one escalation per parent case
<!-- AI:END AUTO -->

### Portal Interactions
<!-- AI:BEGIN AUTO -->
- **Portal Comment** (dx_portalcomment.regardingobjectid)
  - Purpose: Comments from Power Pages portal
  - Common Use: Customer updates from support portal

- **Annotation (Note)** (nnotation.objectid)
  - Purpose: Notes and attachments on case
  - Common Use: Internal documentation, file uploads
<!-- AI:END AUTO -->

### Custom Related Tables
<!-- AI:BEGIN AUTO -->
- **Transfer** (evops_transfer.revops_case)
  - Purpose: P2P transfers associated with this case
  - Common Use: Linking technical onboarding transfers to support case

*(Additional custom relationships to be documented as discovered)*
<!-- AI:END AUTO -->

---

## Polymorphic Relationships

### Customer (N:1)
<!-- AI:BEGIN AUTO -->
- **Field**: customerid
- **Target Tables**: Account OR Contact
- **Purpose**: Primary customer for the case
- **Usage**: Can be either an Account (organization) or Contact (individual)
<!-- AI:END AUTO -->

### Regarding (N:1)
<!-- AI:BEGIN AUTO -->
- **Field**: egardingobjectid
- **Target Tables**: Multiple entity types
- **Purpose**: Case can be "regarding" various records (less common for Case, more for Activities)
- **Usage**: Rarely used on Case itself
<!-- AI:END AUTO -->

---

## Key Relationship Patterns

### P2P Transfer Pattern
<!-- AI:BEGIN AUTO -->
`
Case (P2P Transfer Type)
  â”œâ”€ revops_cumulusaccount â†’ Cumulus Account (losing org)
  â”œâ”€ revops_account â†’ Account (parent account)
  â”œâ”€ primarycontactid â†’ Contact (primary contact)
  â”œâ”€ customerid â†’ Account (customer reference)
  â””â”€ revops_losingcompetitor â†’ Competitor (current provider)
`
<!-- AI:END AUTO -->

### Escalation Pattern
<!-- AI:BEGIN AUTO -->
`
Parent Case
  â””â”€ Child Case (parentcaseid â†’ Parent Case)
      â””â”€ Routed to TSS Management queue
`
<!-- AI:END AUTO -->

### Service Request Pattern
<!-- AI:BEGIN AUTO -->
`
Case
  â”œâ”€ customerid â†’ Account/Contact
  â”œâ”€ revops_service â†’ Service (Microsoft 365, etc.)
  â”œâ”€ revops_queue â†’ Queue (routing)
  â””â”€ Activities (Email, Phone Call, Task)
`
<!-- AI:END AUTO -->

---

## Relationship Diagrams

### Mermaid: Case Core Relationships

\\\mermaid
erDiagram
    CASE ||--o{ EMAIL : "has"
    CASE ||--o{ PHONE-CALL : "has"
    CASE ||--o{ TASK : "has"
    CASE ||--o{ NOTE : "has"
    CASE ||--o{ PORTAL-COMMENT : "has"
    CASE }o--|| ACCOUNT : "customer (polymorphic)"
    CASE }o--|| CONTACT : "customer (polymorphic)"
    CASE }o--|| CONTACT : "primary contact"
    CASE }o--|| CUMULUS-ACCOUNT : "cumulus account"
    CASE }o--|| ACCOUNT : "account (revops)"
    CASE }o--|| QUEUE : "queue"
    CASE }o--|| SERVICE : "service"
    CASE }o--|| COMPETITOR : "losing competitor"
    CASE ||--o{ CASE : "escalations (parent-child)"
\\\

### Mermaid: P2P Transfer Relationships

\\\mermaid
graph TD
    Case[Case - P2P Transfer]
    CumAcct[Cumulus Account]
    Acct[Account - Parent]
    Contact[Contact]
    Competitor[Competitor - Losing]
    Region[Territory Region]
    Service[Service]
    
    Case -->|revops_cumulusaccount| CumAcct
    Case -->|revops_account| Acct
    Case -->|primarycontactid| Contact
    Case -->|customerid| Acct
    Case -->|revops_losingcompetitor| Competitor
    Case -->|revops_competitorregion| Region
    Case -->|revops_service| Service
    
    CumAcct -.->|synced to| Acct
    Acct -.->|contains| Contact
\\\

---

## Cascade Behavior

### Delete Cascades
<!-- AI:BEGIN AUTO -->
- **Activities**: When Case is deleted, related activities are typically retained (orphaned) or deleted based on settings
- **Notes/Attachments**: Cascade delete (notes deleted with case)
- **Portal Comments**: Cascade delete
- **Child Cases**: **No cascade** - parent case deletion does not auto-delete escalations
<!-- AI:END AUTO -->

### Share Cascades
<!-- AI:BEGIN AUTO -->
- When a Case is shared with a user/team, related activities inherit the share
<!-- AI:END AUTO -->

---

## Integration Touchpoints

### Cumulus Account Sync
<!-- AI:BEGIN AUTO -->
- **Flow**: "ISO3166 Cumulus Account to Account"
- **Trigger**: When evops_cumulusaccount is set on Case
- **Action**: Auto-populates evops_account and evops_competitorregion based on Cumulus Account's parent and ISO2 code
<!-- AI:END AUTO -->

### Email-to-Case
<!-- AI:BEGIN AUTO -->
- Incoming emails can create cases or update existing cases
- Relationship: Email â†’ Case (via egardingobjectid)
<!-- AI:END AUTO -->

---

## Related Documentation

- [Case README.md](./README.md) - Business purpose and use cases
- [Case Columns.md](./Columns.md) - All column definitions
- [Web_resources/](./Web_resources/) - Scripts that manipulate relationships (e.g., filtering Contact by Account)

---

**Maintained By**: RevOps Development Team  
**Auto-Generated**: Use `_scripts/Generate-CaseRelationships.ps1` to regenerate
