# Generate-CaseColumns.ps1
# Generates Columns.md for Case table from customizations.xml

param(
    [string]$ExportPath = "C:\RevOps\RevOps-Analysts\Documentation\_Exports\revopstables_1_41_0_3\customizations.xml",
    [string]$OutputFile = "C:\RevOps\RevOps-Analysts\Documentation\Tables\Case\Columns.md"
)

Write-Host "Loading customizations.xml..." -ForegroundColor Cyan
[xml]$xml = Get-Content $ExportPath

$incident = $xml.ImportExportXml.Entities.Entity | Where-Object { $_.Name.InnerText -eq "Incident" }

if (!$incident) {
    Write-Host "ERROR: Incident entity not found!" -ForegroundColor Red
    exit 1
}

$attributes = $incident.EntityInfo.entity.attributes.attribute
$customAttrs = $attributes | Where-Object { $_.IsCustomField -eq "1" }
$standardAttrs = $attributes | Where-Object { $_.IsCustomField -ne "1" }

Write-Host "Found $($standardAttrs.Count) standard attributes" -ForegroundColor Yellow
Write-Host "Found $($customAttrs.Count) custom attributes" -ForegroundColor Green

# Build markdown content
$markdown = @"
# Case Table - Columns

This document lists all columns (attributes) on the **Case** (`incident`) table.

**Last Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Source**: revopstables_1_41_0_3 solution export

---

## Summary

- **Standard Dynamics Columns**: $($standardAttrs.Count)
- **Custom Columns**: $($customAttrs.Count)
- **Total Columns**: $($attributes.Count)

---

## Custom Columns

These are custom fields created specifically for RevOps business processes.

| Logical Name | Display Name | Type | Required | Description |
|--------------|--------------|------|----------|-------------|
"@

foreach ($attr in $customAttrs | Sort-Object Name) {
    $logicalName = $attr.Name
    $displayName = if ($attr.displaynames.displayname) { $attr.displaynames.displayname[0].description } else { "" }
    $type = $attr.Type
    $required = if ($attr.RequiredLevel -eq "SystemRequired" -or $attr.RequiredLevel -eq "ApplicationRequired") { "Yes" } else { "No" }
    $description = if ($attr.Descriptions.Description) { 
        ($attr.Descriptions.Description[0].description -replace "`n", " " -replace "`r", "" -replace "\|", "&#124;").Trim()
    } else { "" }
    
    # Truncate long descriptions
    if ($description.Length -gt 100) {
        $description = $description.Substring(0, 97) + "..."
    }
    
    $markdown += "`n| ``$logicalName`` | $displayName | ``$type`` | $required | $description |"
}

$markdown += @"


---

## Standard Dynamics Columns (Key Fields)

These are out-of-the-box Dynamics 365 Case fields with special significance.

| Logical Name | Display Name | Type | Required | Description |
|--------------|--------------|------|----------|-------------|
"@

# Only include key standard fields
$keyStandardFields = @(
    "ticketnumber", "title", "description", "casetypecode", "caseorigincode",
    "customerid", "primarycontactid", "prioritycode", "severitycode",
    "statuscode", "statecode", "ownerid", "subjectid", "createdon", "modifiedon"
)

foreach ($fieldName in $keyStandardFields) {
    $attr = $standardAttrs | Where-Object { $_.Name -eq $fieldName }
    if ($attr) {
        $logicalName = $attr.Name
        $displayName = if ($attr.displaynames.displayname) { $attr.displaynames.displayname[0].description } else { "" }
        $type = $attr.Type
        $required = if ($attr.RequiredLevel -eq "SystemRequired" -or $attr.RequiredLevel -eq "ApplicationRequired") { "Yes" } else { "No" }
        $description = if ($attr.Descriptions.Description) { 
            ($attr.Descriptions.Description[0].description -replace "`n", " " -replace "`r", "" -replace "\|", "&#124;").Trim()
        } else { "" }
        
        if ($description.Length -gt 100) {
            $description = $description.Substring(0, 97) + "..."
        }
        
        $markdown += "`n| ``$logicalName`` | $displayName | ``$type`` | $required | $description |"
    }
}

$markdown += @"


---

## Column Type Reference

| Type | Description |
|------|-------------|
| ``nvarchar`` | Single Line of Text |
| ``ntext`` | Multiple Lines of Text |
| ``bit`` | Two Options (Yes/No) |
| ``int``, ``decimal``, ``money`` | Number/Currency |
| ``datetime`` | Date and Time |
| ``uniqueidentifier`` | GUID |
| ``lookup`` | Lookup (relationship to another table) |
| ``picklist`` | Choice (option set) |
| ``owner`` | Owner (User or Team) |
| ``customer`` | Customer (polymorphic: Account or Contact) |

---

## Key Field Groups

### P2P Transfer Fields
<!-- AI:BEGIN AUTO -->
- ``revops_transferworkload``: Transfer workload type
- ``revops_competitorregion``: Region for CSP transfer
- ``revops_losingcompetitor``: Losing provider
- ``revops_cumulusaccount``: Cumulus organization
- ``revops_account``: Parent Account
- ``revops_transferorgs``: JSON array of org IDs
- ``revops_oforganizations``: Count of organizations
- ``revops_selectedorgs``: Selected org data
- ``revops_p2pautocreate``: Auto-created flag
<!-- AI:END AUTO -->

### Escalation Fields
<!-- AI:BEGIN AUTO -->
- ``revops_customerescalationreason``: Escalation reason
- ``revops_customerescalationdescription``: Escalation details
- ``parentcaseid``: Parent case (for child escalations)
<!-- AI:END AUTO -->

### Service Fields
<!-- AI:BEGIN AUTO -->
- ``revops_service``: Service type (Microsoft 365, Google Workspace, etc.)
- ``revops_servicestomigrate``: Services to migrate
- ``revops_migrationtype``: Migration type
<!-- AI:END AUTO -->

### Queue/Routing Fields
<!-- AI:BEGIN AUTO -->
- ``revops_queue``: Assigned queue
- ``ownerid``: Case owner (standard)
<!-- AI:END AUTO -->

---

## Calculated/Rollup Fields

<!-- AI:BEGIN AUTO -->
*(None identified yet - document when discovered)*
<!-- AI:END AUTO -->

---

## Related Documentation

- [Case README.md](./README.md) - Business purpose and use cases
- [Case Relationships.md](./Relationships.md) - All table relationships
- [Web_resources/](./Web_resources/) - Form scripts affecting field behavior

---

**Maintained By**: RevOps Development Team  
**Auto-Generated**: Use ``_scripts/Generate-CaseColumns.ps1`` to regenerate
"@

# Write to file
$markdown | Set-Content $OutputFile -Encoding UTF8
Write-Host "`nColumns.md generated successfully!" -ForegroundColor Green
Write-Host "Output: $OutputFile" -ForegroundColor Cyan
Write-Host "`nKey statistics:" -ForegroundColor Yellow
Write-Host "  - Custom columns: $($customAttrs.Count)" -ForegroundColor White
Write-Host "  - Standard columns: $($standardAttrs.Count)" -ForegroundColor White
Write-Host "  - Total columns: $($attributes.Count)" -ForegroundColor White
