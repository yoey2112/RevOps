# Generate-CaseRelationships.ps1
# Generates Relationships.md for Case table from customizations.xml

param(
    [string]$ExportPath = "C:\RevOps\RevOps-Analysts\Documentation\_Exports\revopstables_1_41_0_3\customizations.xml",
    [string]$OutputFile = "C:\RevOps\RevOps-Analysts\Documentation\Tables\Case\Relationships.md"
)

Write-Host "Loading customizations.xml..." -ForegroundColor Cyan
[xml]$xml = Get-Content $ExportPath

$incident = $xml.ImportExportXml.Entities.Entity | Where-Object { $_.Name.InnerText -eq "Incident" }

if (!$incident) {
    Write-Host "ERROR: Incident entity not found!" -ForegroundColor Red
    exit 1
}

# Get all lookup attributes (these create N:1 relationships FROM Case)
$lookups = $incident.EntityInfo.entity.attributes.attribute | Where-Object { $_.Type -eq "lookup" -or $_.Type -eq "owner" -or $_.Type -eq "customer" }

Write-Host "Found $($lookups.Count) lookup fields on Case" -ForegroundColor Green

# Build markdown
$markdown = @"
# Case Table - Relationships

This document maps all relationships between the **Case** (`incident`) table and other tables.

**Last Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Source**: revopstables_1_41_0_3 solution export

---

## Relationship Summary

### N:1 Relationships (Case → Other Tables)
Case table has **$($lookups.Count) lookup fields** that create N:1 relationships to other tables.

### 1:N Relationships (Other Tables → Case)
These are documented below based on common Dynamics patterns and observed system behavior.

---

## N:1 Relationships FROM Case

These are **lookup fields on the Case table** that reference other tables.

| Field Name | Related Table | Display Name | Relationship Type | Description |
|------------|---------------|--------------|-------------------|-------------|
"@

foreach ($lookup in $lookups | Sort-Object Name) {
    $fieldName = $lookup.Name
    $displayName = if ($lookup.displaynames.displayname) { $lookup.displaynames.displayname[0].description } else { "" }
    $type = $lookup.Type
    $description = if ($lookup.Descriptions.Description) { 
        ($lookup.Descriptions.Description[0].description -replace "`n", " " -replace "`r", "" -replace "\|", "&#124;").Trim()
    } else { "" }
    
    # Try to determine target entity
    $targetEntity = "*(Unknown)*"
    if ($lookup.LookupTypes.LookupType) {
        $targetEntity = $lookup.LookupTypes.LookupType
    }
    
    # Truncate description
    if ($description.Length -gt 80) {
        $description = $description.Substring(0, 77) + "..."
    }
    
    $markdown += "`n| ``$fieldName`` | ``$targetEntity`` | $displayName | $type | $description |"
}

$markdown += @"


---

## 1:N Relationships TO Case

These tables have **lookup fields that point to Case**.

### Activities Related to Case
<!-- AI:BEGIN AUTO -->
- **Email** (`activitypointer.regardingobjectid`)
  - Purpose: Emails sent/received about this case
  - Common Use: Customer correspondence, internal notes

- **Phone Call** (`phonecall.regardingobjectid`)
  - Purpose: Phone call activities logged to case
  - Common Use: Support call logging

- **Task** (`task.regardingobjectid`)
  - Purpose: Tasks related to resolving case
  - Common Use: Follow-up tasks, internal assignments

- **Appointment** (`appointment.regardingobjectid`)
  - Purpose: Scheduled meetings about case
  - Common Use: Customer calls, onboarding sessions
<!-- AI:END AUTO -->

### Case Escalations
<!-- AI:BEGIN AUTO -->
- **Case (Self-Referencing)** (`incident.parentcaseid`)
  - Purpose: Child escalation cases
  - Common Use: Escalating a case creates a child case linked to parent
  - Business Rule: Only one escalation per parent case
<!-- AI:END AUTO -->

### Portal Interactions
<!-- AI:BEGIN AUTO -->
- **Portal Comment** (`adx_portalcomment.regardingobjectid`)
  - Purpose: Comments from Power Pages portal
  - Common Use: Customer updates from support portal

- **Annotation (Note)** (`annotation.objectid`)
  - Purpose: Notes and attachments on case
  - Common Use: Internal documentation, file uploads
<!-- AI:END AUTO -->

### Custom Related Tables
<!-- AI:BEGIN AUTO -->
- **Transfer** (`revops_transfer.revops_case`)
  - Purpose: P2P transfers associated with this case
  - Common Use: Linking technical onboarding transfers to support case

*(Additional custom relationships to be documented as discovered)*
<!-- AI:END AUTO -->

---

## Polymorphic Relationships

### Customer (N:1)
<!-- AI:BEGIN AUTO -->
- **Field**: `customerid`
- **Target Tables**: Account OR Contact
- **Purpose**: Primary customer for the case
- **Usage**: Can be either an Account (organization) or Contact (individual)
<!-- AI:END AUTO -->

### Regarding (N:1)
<!-- AI:BEGIN AUTO -->
- **Field**: `regardingobjectid`
- **Target Tables**: Multiple entity types
- **Purpose**: Case can be "regarding" various records (less common for Case, more for Activities)
- **Usage**: Rarely used on Case itself
<!-- AI:END AUTO -->

---

## Key Relationship Patterns

### P2P Transfer Pattern
<!-- AI:BEGIN AUTO -->
```
Case (P2P Transfer Type)
  ├─ revops_cumulusaccount → Cumulus Account (losing org)
  ├─ revops_account → Account (parent account)
  ├─ primarycontactid → Contact (primary contact)
  ├─ customerid → Account (customer reference)
  └─ revops_losingcompetitor → Competitor (current provider)
```
<!-- AI:END AUTO -->

### Escalation Pattern
<!-- AI:BEGIN AUTO -->
```
Parent Case
  └─ Child Case (parentcaseid → Parent Case)
      └─ Routed to TSS Management queue
```
<!-- AI:END AUTO -->

### Service Request Pattern
<!-- AI:BEGIN AUTO -->
```
Case
  ├─ customerid → Account/Contact
  ├─ revops_service → Service (Microsoft 365, etc.)
  ├─ revops_queue → Queue (routing)
  └─ Activities (Email, Phone Call, Task)
```
<!-- AI:END AUTO -->

---

## Relationship Diagrams

### Mermaid: Case Core Relationships

\`\`\`mermaid
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
\`\`\`

### Mermaid: P2P Transfer Relationships

\`\`\`mermaid
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
\`\`\`

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
- **Trigger**: When `revops_cumulusaccount` is set on Case
- **Action**: Auto-populates `revops_account` and `revops_competitorregion` based on Cumulus Account's parent and ISO2 code
<!-- AI:END AUTO -->

### Email-to-Case
<!-- AI:BEGIN AUTO -->
- Incoming emails can create cases or update existing cases
- Relationship: Email → Case (via `regardingobjectid`)
<!-- AI:END AUTO -->

---

## Related Documentation

- [Case README.md](./README.md) - Business purpose and use cases
- [Case Columns.md](./Columns.md) - All column definitions
- [Web_resources/](./Web_resources/) - Scripts that manipulate relationships (e.g., filtering Contact by Account)

---

**Maintained By**: RevOps Development Team  
**Auto-Generated**: Use ``_scripts/Generate-CaseRelationships.ps1`` to regenerate
"@

# Write to file
$markdown | Set-Content $OutputFile -Encoding UTF8
Write-Host "`nRelationships.md generated successfully!" -ForegroundColor Green
Write-Host "Output: $OutputFile" -ForegroundColor Cyan
Write-Host "`nFound $($lookups.Count) N:1 relationships (lookup fields)" -ForegroundColor Yellow
