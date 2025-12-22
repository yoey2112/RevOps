# Case Table - Columns

This document lists all columns (attributes) on the **Case** (incident) table.

**Last Generated**: 2025-12-15 08:25:18  
**Source**: revopstables_1_41_0_3 solution export

---

## Summary

- **Standard Dynamics Columns**: 24
- **Custom Columns**: 95
- **Total Columns**: 119

---

## Custom Columns

These are custom fields created specifically for RevOps business processes.

| Logical Name | Display Name | Type | Required | Description |
|--------------|--------------|------|----------|-------------|
| `adx_publishtoweb` | Publish to Web | `bit` | No | If set to Yes, the case will be visible and searchable on portals connected to this organization. |
| `adx_resolution` | Resolution | `ntext` | No |  |
| `adx_resolutiondate` | Resolution Date | `datetime` | No |  |
| `revops_3rdpartyescalationsupplier` |  | `picklist` | No |  |
| `revops_3rdpartyescalationticket` |  | `nvarchar` | No |  |
| `revops_account` |  | `lookup` | No |  |
| `revops_accountmrr` |  | `money` | No |  |
| `revops_accountmrr_base` | Account MRR (Base) | `money` | No | Value of the Account MRR in base currency. |
| `revops_aidescription` |  | `bit` | No |  |
| `revops_amount` |  | `money` | No |  |
| `revops_amount_base` | Amount (Base) | `money` | No | Value of the Amount in base currency. |
| `revops_competitorregion` |  | `lookup` | No |  |
| `revops_csatsurveycompleted` |  | `bit` | No |  |
| `revops_csptransferid` |  | `nvarchar` | No |  |
| `revops_cumulusaccount` |  | `lookup` | No |  |
| `revops_cumulusorganization` |  | `lookup` | No |  |
| `revops_cumulususer` |  | `lookup` | No |  |
| `revops_currentphoneinvoice` |  | `picklist` | No |  |
| `revops_customerescalationreason` |  | `picklist` | No |  |
| `revops_customerlanguage` |  | `picklist` | No |  |
| `revops_customertype` |  | `nvarchar` | No |  |
| `revops_cutoverdatetime` |  | `datetime` | No |  |
| `revops_datalocation` |  | `picklist` | No |  |
| `revops_datep2prequestsubmittedtolosingcsp` |  | `datetime` | No |  |
| `revops_doesakbexistforthisissue` |  | `bit` | No |  |
| `revops_domain` |  | `nvarchar` | No |  |
| `revops_endpointtomigrate` |  | `nvarchar` | No |  |
| `revops_escalationreductionopportunity` |  | `picklist` | No |  |
| `revops_escalationtype` |  | `picklist` | No |  |
| `revops_fdticketnumber` |  | `nvarchar` | No |  |
| `revops_firstcallrequiredinfocompleted` |  | `bit` | No |  |
| `revops_followupbykpi` |  | `lookup` | No |  |
| `revops_followupcreatedon` |  | `datetime` | No |  |
| `revops_followupsent` |  | `bit` | No |  |
| `revops_followupslastatus` |  | `picklist` | No |  |
| `revops_hostedexchangeplatform` |  | `picklist` | No |  |
| `revops_internalescalationprovider` |  | `picklist` | No |  |
| `revops_internalescalationurl` |  | `nvarchar` | No |  |
| `revops_ipphonesshipped` |  | `picklist` | No |  |
| `revops_kburl` |  | `nvarchar` | No |  |
| `revops_kickoffcall` |  | `picklist` | No |  |
| `revops_l3actiontaken` |  | `picklist` | No |  |
| `revops_l3reviewby` |  | `picklist` | No |  |
| `revops_lastemaildirection` |  | `picklist` | No |  |
| `revops_lastinteraction` |  | `picklist` | No |  |
| `revops_lastinteractiondate` |  | `datetime` | No |  |
| `revops_licensequantity` |  | `int` | No |  |
| `revops_losingcompetitor` |  | `lookup` | No |  |
| `revops_losingprovider` |  | `nvarchar` | No |  |
| `revops_m365service` |  | `picklist` | No |  |
| `revops_m365tenantname` |  | `nvarchar` | No |  |
| `revops_migrationdestination` |  | `picklist` | No |  |
| `revops_migrationmethod` |  | `picklist` | No |  |
| `revops_migrationsource` |  | `picklist` | No |  |
| `revops_mwhaccount` |  | `lookup` | No |  |
| `revops_nceenforcementpolicy` |  | `bit` | No |  |
| `revops_nerdioaccount` |  | `nvarchar` | No |  |
| `revops_nocservices` |  | `picklist` | No |  |
| `revops_oforganizations` |  | `int` | No |  |
| `revops_onboardingform` |  | `picklist` | No |  |
| `revops_opportunity` |  | `lookup` | No |  |
| `revops_ordervalidation` |  | `picklist` | No |  |
| `revops_outofscope` |  | `bit` | No |  |
| `revops_ownermodifiedby` |  | `lookup` | No |  |
| `revops_ownermodifiedon` |  | `datetime` | No |  |
| `revops_p2ptype` |  | `picklist` | No |  |
| `revops_pbxconfiguration` |  | `picklist` | No |  |
| `revops_phonenumbersported` |  | `picklist` | No |  |
| `revops_pleskserver` |  | `picklist` | No |  |
| `revops_portinformlnp` |  | `picklist` | No |  |
| `revops_practice` |  | `lookup` | No |  |
| `revops_previousqueue` |  | `nvarchar` | No |  |
| `revops_queue` |  | `lookup` | No |  |
| `revops_queuemodifiedon` |  | `datetime` | No |  |
| `revops_reassignedby` |  | `lookup` | No |  |
| `revops_recurringfees` |  | `picklist` | No |  |
| `revops_relatedcases` |  | `lookup` | No |  |
| `revops_s1transferstatus` |  | `picklist` | No |  |
| `revops_service` |  | `lookup` | No |  |
| `revops_servicestomigrate` |  | `multiselectpicklist` | No |  |
| `revops_setupfees` |  | `picklist` | No |  |
| `revops_shippingfees` |  | `picklist` | No |  |
| `revops_shoulditbeupdated` |  | `bit` | No |  |
| `revops_shouldtherebeakb` |  | `bit` | No |  |
| `revops_sitestomigrate` |  | `nvarchar` | No |  |
| `revops_solution` |  | `lookup` | No |  |
| `revops_subscriptionid` |  | `nvarchar` | No |  |
| `revops_subsolution` |  | `lookup` | No |  |
| `revops_tenanttype` |  | `picklist` | No |  |
| `revops_termsandconditions` |  | `picklist` | No |  |
| `revops_transferorgs` |  | `ntext` | No |  |
| `revops_transferworkload` |  | `multiselectpicklist` | No |  |
| `revops_unresponsivecounter` |  | `int` | No |  |
| `revops_urgency` |  | `picklist` | No |  |
| `revops_veeamusername` |  | `nvarchar` | No |  |

---

## Standard Dynamics Columns (Key Fields)

These are out-of-the-box Dynamics 365 Case fields with special significance.

| Logical Name | Display Name | Type | Required | Description |
|--------------|--------------|------|----------|-------------|
| `ticketnumber` | NumÃ©ro de l'incident | `nvarchar` | No | Affiche le numÃ©ro d'incident pour servir de rÃ©fÃ©rence client et permettre les recherches. Vous... |
| `title` | Titre de l'incident | `nvarchar` | No | Tapez un sujet ou un nom descriptif, comme la requÃªte, la demande ou le nom de la sociÃ©tÃ©, pou... |
| `description` | Description | `ntext` | No | Description de l'activitÃ©. |
| `casetypecode` | Type d'incident | `picklist` | No | SÃ©lectionnez le type d'incident pour identifier l'incident Ã  utiliser dans la gÃ©nÃ©ration de r... |
| `caseorigincode` | Origin | `picklist` | No | Select how contact about the case was originated, such as email, phone, or web, for use in report... |
| `customerid` | Customer | `customer` | Yes | Select the customer account or contact to provide a quick link to additional customer details, su... |
| `primarycontactid` | Contact | `lookup` | No | Select a primary contact for this case. |
| `prioritycode` | Priority | `picklist` | No | Select the priority so that preferred customers or critical issues are handled quickly. |
| `severitycode` | Severity | `picklist` | No | Select the severity of this case to indicate the incident's impact on the customer's business. |
| `statuscode` | Raison du statut | `status` | No | Raison du statut de l'Ã©lÃ©ment {0} |
| `statecode` | Status | `state` | Yes | Shows whether the case is active, resolved, or canceled. Resolved and canceled cases are read-onl... |
| `ownerid` | Owner | `owner` | Yes | Owner Id |
| `subjectid` | Sujet | `lookup` | No | Choisissez le sujet de l'incident, comme une demande de catalogue ou une plainte concernant un pr... |
| `createdon` | Created On | `datetime` | No | Date and time when the record was created. |
| `modifiedon` | Modified On | `datetime` | No | Date and time when the record was modified. |

---

## Column Type Reference

| Type | Description |
|------|-------------|
| `nvarchar` | Single Line of Text |
| `ntext` | Multiple Lines of Text |
| `bit` | Two Options (Yes/No) |
| `int`, `decimal`, `money` | Number/Currency |
| `datetime` | Date and Time |
| `uniqueidentifier` | GUID |
| `lookup` | Lookup (relationship to another table) |
| `picklist` | Choice (option set) |
| `owner` | Owner (User or Team) |
| `customer` | Customer (polymorphic: Account or Contact) |

---

## Key Field Groups

### P2P Transfer Fields
<!-- AI:BEGIN AUTO -->
- `revops_transferworkload`: Transfer workload type
- `revops_competitorregion`: Region for CSP transfer
- `revops_losingcompetitor`: Losing provider
- `revops_cumulusaccount`: Cumulus organization
- `revops_account`: Parent Account
- `revops_transferorgs`: JSON array of org IDs
- `revops_oforganizations`: Count of organizations
- `revops_selectedorgs`: Selected org data
- `revops_p2pautocreate`: Auto-created flag
<!-- AI:END AUTO -->

### Escalation Fields
<!-- AI:BEGIN AUTO -->
- `revops_customerescalationreason`: Escalation reason
- `revops_customerescalationdescription`: Escalation details
- `parentcaseid`: Parent case (for child escalations)
<!-- AI:END AUTO -->

### Service Fields
<!-- AI:BEGIN AUTO -->
- `revops_service`: Service type (Microsoft 365, Google Workspace, etc.)
- `revops_servicestomigrate`: Services to migrate
- `revops_migrationtype`: Migration type
<!-- AI:END AUTO -->

### Queue/Routing Fields
<!-- AI:BEGIN AUTO -->
- `revops_queue`: Assigned queue
- `ownerid`: Case owner (standard)
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
**Auto-Generated**: Use `_scripts/Generate-CaseColumns.ps1` to regenerate
