# Case Table (incident)

## Business Purpose

The **Case** (technical name: `incident`) table is the core entity for tracking customer support requests, issues, and service tickets in the RevOps system. It manages:

- Customer support tickets
- CSP (Cloud Solution Provider) transfer requests
- Migration requests
- License adjustment requests
- Escalations and complaints

The Case table is heavily customized to support the RevOps business processes for managing cloud service transfers, migrations, and customer support workflows.

---

## Key Use Cases

### Primary Use Cases
1. **P2P (Peer-to-Peer) Transfers**: Track CSP transfers between providers
2. **Migration Requests**: Document customer migrations to new platforms/services
3. **License Adjustments**: Manage subscription and license modification requests
4. **Support Tickets**: Standard customer service request tracking
5. **Escalations**: Tier-based case escalation for priority customers

### Special Features
- **Tier-based access**: Tier 1 and Tier 2 customers can escalate cases
- **Multi-organization transfers**: Single case can manage transfers for multiple Cumulus organizations
- **Auto-routing**: Escalations and complaints auto-route to TSS Management queue
- **Region-based filtering**: Competitor selection filters by selected region

---

## Primary Relationships

### Lookups FROM Case
| Field | Related Table | Purpose |
|-------|---------------|---------|
| `customerid` | Account/Contact | Polymorphic customer reference (standard) |
| `primarycontactid` | Contact | Primary contact for the case |
| `revops_cumulusaccount` | revops_cumulusaccount | Cumulus organization related to case |
| `revops_account` | Account | Parent account (synced from Cumulus Account) |
| `revops_competitorregion` | msdyn_region | Region for CSP transfers |
| `revops_losingcompetitor` | competitor | Losing provider in transfer |
| `revops_queue` | queue | Assigned queue |
| `revops_service` | revops_service | Service type (e.g., Microsoft 365) |
| `subjectid` | subject | Case categorization |

### Lookups TO Case
- **Child Cases**: Escalation cases link back via `parentcaseid`
- **Activities**: Emails, phone calls, tasks related to case
- **Notes**: Case notes and attachments
- **Portal Comments**: Customer-submitted comments from Power Pages

---

## Automation Touchpoints

### Power Automate Flows
- **ISO3166 Cumulus Account to Account**: Auto-populates region based on Cumulus Account's ISO2 country code
- **Account Created in Cumulus**: (Related to account synchronization)
- *(Additional flows to be documented)*

### Plugins
- *(None documented yet - add when discovered)*

### Business Rules
- **Transfer Workload**: Set to required on P2P transfer forms
- **Tier Validation**: Escalation button only visible for Tier 1/2 customers
- **Single Escalation**: Cases can only be escalated once

### Form Scripts (Web Resources)
Located in `Web_resources/`:
1. **revops_p2ptransfercreate.js**: 
   - Auto-populates Account from Cumulus Account
   - Auto-fills Region by ISO2 country code
   - Filters Contact lookup by Account
   - Syncs Contact to Customer field
   - Ribbon command to open P2P transfer cases
   
2. **revops_p2p_competitor_filter.js**:
   - Dynamically filters Losing Competitor by selected Region
   - Creates custom FetchXML views
   - Ensures only Microsoft-transfer-eligible competitors show

---

## Forms

### Main Forms
- **Main Form** (`bb897864-d393-f011-b4cc-6045bdfa0630`): Standard case management
- **Web - Edit Case** (Power Pages): Portal case viewing/editing
- **P2P Transfer**: Specialized form for CSP transfers

### Quick Create
- Standard Case Quick Create

### Power Pages Forms
See: `Documentation/Power Pages Site/basic-forms/`
- `case---create-p2p-from-portal`: Complex P2P creation with organization modal
- `view---client-case`: Tier-based escalation view
- `create-case---support`: General support ticket creation
- Transfer-specific forms: CSP, GoDaddy, Google
- Escalation/complaint forms

---

## Security

### Model-Driven App Access
- **Security Roles**: Sales, Support, Administrators
- **Standard Privileges**: Create, Read, Write, Delete based on role

### Power Pages Access
**Table Permissions** (from Power Pages documentation):
- `Cases-where-contact-is-customer`: Contacts can access their own cases
- `Cases-where-account-of-the-contact-is-customer`: Access via account relationship
- `Case-Create`: Portal users can create cases
- `Case-Notes-where-contact-is-customer`: View/add notes on own cases
- `Email---Cases-where-contact-is-customer`: Email activities on cases
- `Portal-Comment-where-contact-is-customer`: Submit comments

**Tier-Based Features**:
- Only Tier 1 and Tier 2 customers can escalate cases (enforced via JavaScript)

---

## Reporting Considerations

### Key Metrics
- Open vs Closed cases
- Cases by type (P2P, Migration, License Adjustment, Support)
- Cases by queue/owner
- Escalation rate
- Time to resolution
- Customer satisfaction (if tracked)

### Dashboards
- *(Document which dashboards use Case data)*

### Reports
- *(Document which reports query this table)*

---

## Custom Fields (Key Highlights)

| Field | Type | Purpose |
|-------|------|---------|
| `revops_p2pautocreate` | Two Options | Flag for auto-created P2P cases |
| `revops_transferorgs` | Multiple Lines | JSON array of organization IDs |
| `revops_oforganizations` | Whole Number | Count of organizations in transfer |
| `revops_selectedorgs` | Multiple Lines | JSON of selected orgs |
| `revops_transferworkload` | Choice | Type of transfer workload |
| `revops_customerescalationreason` | Choice | Reason for escalation |
| `casetypecode` | Choice | Case type (Migration, etc.) |

*For full column list, see `Columns.md` (to be created)*

---

## Integration Points

### External Systems
- **Microsoft Omnichannel**: Chat integration on portal
- **Power Virtual Agents**: Chatbot case creation
- **Email**: Incoming emails can create cases

### Internal Systems
- **Cumulus Account System**: Syncs organization data
- **Account/Contact**: Customer relationship management
- **Queue**: Work distribution and routing

---

## Known Patterns & Best Practices

### P2P Transfer Pattern
1. User selects Cumulus Account
2. Script fetches parent Account and ISO2 code
3. Region auto-populates based on ISO2 → Region Code match
4. Competitor lookup filters by region
5. Contact filtered by Account
6. Contact selection syncs to Customer field

### Escalation Pattern
1. Check customer tier (FetchXML on Account)
2. Check if case already escalated
3. Show "Escalate" button only if Tier 1/2 AND not already escalated
4. Create child case linked to parent
5. Route to TSS Management queue

---

## Change History

- **2025-12-15**: Initial documentation created
- **2025-12-03**: Power Pages documentation created
- **2025-12-04**: Web resources (p2ptransfercreate, competitor_filter) analyzed

---

## TODO / Future Documentation

- [ ] Create `Columns.md` with full column list and descriptions
- [ ] Create `Relationships.md` with detailed relationship diagrams
- [ ] Document all flows that trigger on Case
- [ ] Document plugins (if any) registered on Case
- [ ] Add form screenshots to `Forms/` folder
- [ ] Document all choice field values
- [ ] Create Mermaid diagram of P2P transfer workflow

---

## Used by Flows
<!-- AI:BEGIN AUTO -->
- [case-sendnotificationtoownerwhenacustomerreplies](../../Flows/case-sendnotificationtoownerwhenacustomerreplies/README.md) - Trigger: OpenApiConnectionWebhook
- [createcasefrommigrationrequest](../../Flows/createcasefrommigrationrequest/README.md) - Trigger: OpenApiConnectionWebhook
- [createcasefromzabbixalert](../../Flows/createcasefromzabbixalert/README.md) - Trigger: Request (Http)
- [cs-automatedunresponsiveprocess](../../Flows/cs-automatedunresponsiveprocess/README.md) - Trigger: Recurrence
- [cs-casecreateformanualaccountcreationforukpartners](../../Flows/cs-casecreateformanualaccountcreationforukpartners/README.md) - Trigger: OpenApiConnectionWebhook
- [cs-notifymanagerofcustomerescalation](../../Flows/cs-notifymanagerofcustomerescalation/README.md) - Trigger: OpenApiConnectionWebhook
- [incomingemailsetcustomerresponded](../../Flows/incomingemailsetcustomerresponded/README.md) - Trigger: OpenApiConnectionWebhook
- [incomingportalcommentsetcustomerresponded](../../Flows/incomingportalcommentsetcustomerresponded/README.md) - Trigger: OpenApiConnectionWebhook
- [p2ptransferpopulationfromcase](../../Flows/p2ptransferpopulationfromcase/README.md) - Trigger: OpenApiConnectionWebhook
- [sendp2ptransfer](../../Flows/sendp2ptransfer/README.md) - Trigger: OpenApiConnectionWebhook
- [setcaselookupvalueoncustomerfeedbacksurveyresponse](../../Flows/setcaselookupvalueoncustomerfeedbacksurveyresponse/README.md) - Trigger: OpenApiConnectionWebhook
- [setsupportedservicecolumn-emailchannel](../../Flows/setsupportedservicecolumn-emailchannel/README.md) - Trigger: OpenApiConnectionWebhook
<!-- AI:END AUTO -->

---

**Last Updated**: December 15, 2025  
**Maintained By**: RevOps Development Team