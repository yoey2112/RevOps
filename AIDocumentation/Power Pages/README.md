# Power Pages

## Purpose

This folder contains documentation for the **Microsoft Power Pages portal** used in the RevOps system. Power Pages is a low-code platform for building external-facing websites that integrate with Dynamics 365 Dataverse.

The RevOps Power Pages portal enables customers to:
- Submit support cases and track their status
- Request CSP (Cloud Solution Provider) transfers (P2P transfers)
- Escalate issues and complaints
- View and manage their Cumulus organizations
- Access self-service resources and knowledge base

---

## Folder Structure

```
Power Pages/
├── README.md (this file)
└── Site/
    ├── README.md (detailed portal documentation)
    ├── COMPONENT_TEMPLATE.md
    ├── DOCUMENTATION-SUMMARY.md
    ├── advanced-forms/
    ├── basic-forms/
    ├── content-snippets/
    ├── lists/
    ├── page-templates/
    ├── table-permissions/
    ├── ux-components/
    ├── web-files/
    ├── web-pages/
    ├── web-templates/
    ├── weblink-sets/
    └── _docs/
```

---

## Key Documentation

### Site Folder
The **`Site/`** folder contains comprehensive documentation for all Power Pages components:

- **Basic Forms** (16 documented): Portal forms for creating/editing Dataverse records
- **Advanced Forms** (2 documented): Multi-step wizards with complex logic
- **Lists** (5 documented): Grid views for displaying Dataverse data
- **Web Files** (17 documented): CSS, JavaScript, images, and other static assets
- **Web Templates** (16 documented): Liquid templates for rendering HTML
- **Table Permissions**: Security rules for portal access to Dataverse tables
- **Content Snippets**: Reusable text/HTML blocks for portal pages
- **Web Pages**: Portal page structure and navigation

For complete details, see **`Site/README.md`**.

---

## Portal Features

### Customer Self-Service
- **Case Management**: Create, view, and comment on support cases
- **P2P Transfers**: Submit CSP transfer requests with organization selection
- **Escalations**: Tier 1 and Tier 2 customers can escalate cases
- **Organization Management**: View and select Cumulus organizations for transfers

### Tier-Based Access
- **Tier 1 & Tier 2**: Full escalation and complaint features
- **Standard**: Basic case creation and viewing
- **Security**: Role-based table permissions control data access

### Custom Automation
- **JavaScript**: Custom form logic (contact filtering, region auto-population, etc.)
- **Liquid Templates**: Dynamic content rendering based on user context
- **Integration**: Omnichannel chat, Power Virtual Agents chatbot

---

## Technical Architecture

### Power Pages Portal
- **Portal Name**: (Document actual portal name from .paportal folder)
- **Website ID**: (Document from portal metadata)
- **Environment**: (Document DEV/UAT/PROD URLs)

### Dataverse Tables Used
See **`Tables/`** folder for detailed table documentation:
- `incident` (Case): Support tickets, P2P transfers, escalations
- `account`: Customer accounts
- `contact`: Portal users
- `revops_cumulusaccount`: Cumulus organizations
- `competitor`: CSP competitors
- `msdyn_region`: Geographic regions
- `revops_service`: Service types (Microsoft 365, etc.)

### Forms Integration
Power Pages forms use the same JavaScript web resources as model-driven apps:
- **`revops_p2ptransfercreate.js`**: P2P transfer automation (see `Tables/Case/Web_resources/`)
- **`revops_p2p_competitor_filter.js`**: Region-based competitor filtering

---

## Security Model

### Authentication
- **Azure AD B2C** (or local authentication, document actual provider)
- **Contact Records**: Portal users mapped to Dynamics Contact records

### Table Permissions
Documented in **`Site/table-permissions/`**:
- **Cases-where-contact-is-customer**: Users see their own cases
- **Cases-where-account-of-the-contact-is-customer**: Users see account's cases
- **Case-Create**: Authenticated users can create cases
- **Case-Notes-where-contact-is-customer**: Users can add notes to own cases

### Web Roles
- **Authenticated Users**: Basic portal access
- **Tier 1 Customers**: Enhanced features (escalation, complaints)
- **Tier 2 Customers**: Enhanced features
- **Administrators**: (Document if admin web role exists)

---

## Development Workflow

### Portal Studio
- **Access**: Power Pages Studio (make.powerpages.microsoft.com)
- **Live Editing**: Direct editing in Portal Studio
- **Version Control**: Export via `.paportal` folder structure

### Source Control
- **Location**: `Power Page Site/.paportal/swdevportal/`
- **Files**: JSON configs, Liquid templates, CSS, JavaScript

### Deployment
- **DEV → UAT → PROD** pipeline (document actual process)
- **Solutions**: Include portal components in Dynamics solutions
- **Testing**: UAT environment for validating changes before production

---

## Related Documentation

### Tables Used by Portal
- **`Tables/Case/`**: Case table (support tickets, P2P transfers)
- **`Tables/Account/`**: (To be documented)
- **`Tables/Contact/`**: (To be documented)
- **`Tables/revops_cumulusaccount/`**: (To be documented)

### Flows Triggered by Portal
- **`Flows/iso-3166-cumulus-account-to-account/`**: Auto-populates region on cases

### Plugins (If Any)
- Check **`Plugins/`** folder for server-side logic triggered by portal actions

---

## Key Use Cases

### 1. P2P Transfer Submission
**User Flow**:
1. User logs into portal
2. Navigates to "Create P2P Transfer" page
3. Selects Cumulus organization(s) via modal
4. Form auto-populates Account, Region, Contact
5. User selects Losing Competitor (filtered by region)
6. Submits transfer request
7. Case created in Dynamics 365

**Documentation**:
- Form: `Site/basic-forms/case---create-p2p-from-portal.md`
- JavaScript: `Tables/Case/Web_resources/revops_p2ptransfercreate.js`

---

### 2. Case Escalation
**User Flow**:
1. Tier 1/2 user views their case
2. Clicks "Escalate" button (JavaScript checks tier and escalation status)
3. System creates child case linked to original
4. Routes to TSS Management queue
5. User sees confirmation

**Documentation**:
- Form: `Site/basic-forms/view---client-case.md`
- Business Rule: (To be documented)

---

### 3. Support Ticket Creation
**User Flow**:
1. User navigates to "Create Support Case" page
2. Fills out Subject, Description, Priority
3. Submits form
4. Case assigned to appropriate queue
5. User receives confirmation

**Documentation**:
- Form: `Site/basic-forms/create-case---support.md`

---

## Customization Patterns

### Common Patterns in Portal
1. **Tier-Based Features**: JavaScript checks Account tier via FetchXML
2. **Organization Selection**: Modal lists for multi-select Cumulus Accounts
3. **Filtered Lookups**: Region filters competitor lookup dynamically
4. **Auto-Population**: ISO2 codes map to regions via flows
5. **Contact Sync**: Contact selection syncs to Customer polymorphic field

---

## Testing Checklist

### Before Deploying Portal Changes
- [ ] Test in **Portal Studio Preview**
- [ ] Test with **different user roles** (Tier 1, Tier 2, Standard)
- [ ] Verify **table permissions** work correctly
- [ ] Test **JavaScript** functionality (filtering, auto-population)
- [ ] Check **responsive design** (mobile, tablet, desktop)
- [ ] Validate **form submissions** create records correctly
- [ ] Test **error handling** (invalid data, network errors)
- [ ] Verify **Liquid templates** render correctly
- [ ] Test **authentication** and **web roles**

---

## Known Issues / Limitations

(Document any known issues with the portal)

- [ ] (Issue 1)
- [ ] (Issue 2)

---

## TODO / Future Documentation

- [ ] Document actual portal name and environment URLs
- [ ] Document authentication provider (Azure AD B2C, local, etc.)
- [ ] Create visual sitemap of portal pages
- [ ] Document web roles and their permissions
- [ ] Add screenshots to form documentation
- [ ] Document content snippets in detail
- [ ] Create user guides for common workflows
- [ ] Document chatbot integration (if applicable)

---

## Change History

- **2025-12-15**: Initial Power Pages folder README created
- **2025-12-03**: Power Pages Site documentation created (135+ components)
- **2025-12-04**: Advanced forms and web templates documented

---

**Last Updated**: December 15, 2025  
**Maintained By**: RevOps Development Team