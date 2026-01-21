# Current-State Samples

## tables

**Path:** tables/list/README.md

**Why:** small/medium/large file sample

**Excerpt:** Table list Overview Dataverse table with metadata for knowledge consumption Metadata Display Name LocalizedLabels System Object UserLocalizedLabel Type UserOwned Custom Entity False Audit Enabled Value False CanBeChanged True ManagedPropertyLogicalName canmodifyauditsettings Activity False Coverage Columns 66 Relationships 33 Forms 46 Business Rules 0 Facts _facts table yaml Table metadata _facts columns yaml Column definitions _facts relationships yaml Relationships 1 N N N _facts forms yaml Form configurations _facts business_rules yaml Business rules Description LocalizedLabels System Object UserLocalizedLabel

**Path:** tables/revops_practice/README.md

**Why:** small/medium/large file sample

**Excerpt:** Table revops_practice Overview Dataverse table with metadata for knowledge consumption Metadata Display Name LocalizedLabels System Object UserLocalizedLabel Type OrganizationOwned Custom Entity True Audit Enabled Value True CanBeChanged True ManagedPropertyLogicalName canmodifyauditsettings Activity False Coverage Columns 30 Relationships 25 Forms 15 Business Rules 0 Facts _facts table yaml Table metadata _facts columns yaml Column definitions _facts relationships yaml Relationships 1 N N N _facts forms yaml Form configurations _facts business_rules yaml Business rules Description LocalizedLabels System Object UserLocalizedLabel

**Path:** tables/README.md

**Why:** shows inline metadata or schema naming

**Excerpt:** Tables Documentation Purpose This folder contains comprehensive documentation for all Dataverse tables entities in the RevOps environment Tables are the foundational data structures that store business information from standard entities like Account and Contact to custom RevOps specific tables Audience RevOps developers and solution architects Copilot agents performing analysis and impact assessment Business analysts understanding system capabilities What s Documented Here Each table has its own subfolder containing README md Narrative documentation explaining purpose usage and key relationships _facts columns yaml Machine readable column metadata names types descriptions required fields _facts relationships yaml All 1 N N 1 and N N relationships with other tables _facts forms yaml Form configurations including fields tabs and sections best effort _facts business_rules yaml Business rules configured on the table best effort How to Navigate To find a specific table Browse subfolders by logical name e g account revops_pricingrequest Standard Dynamics 365 tables use



## plugins

**Path:** plugins/RevOps.EmailPlugins/README.md

**Why:** small/medium/large file sample

**Excerpt:** Plugin Assembly RevOps EmailPlugins Overview Plugin assembly with enriched metadata for knowledge consumption Details Version 1 0 0 0 Public Key Token 7d35e700d390c80a Plugin Types 2 SDK Message Processing Steps 0 Facts _facts assembly yaml Assembly metadata _facts plugin types yaml Plugin types and workflow activities _facts sdk steps yaml SDK message processing step registrations Purpose Generated Plugin assembly inventory and registration details

**Path:** plugins/sherweb.plugin/README.md

**Why:** small/medium/large file sample

**Excerpt:** Plugin Assembly sherweb plugin Overview Plugin assembly with enriched metadata for knowledge consumption Details Version 1 0 0 0 Public Key Token c4e5b1924e6ff2df Plugin Types 1 SDK Message Processing Steps 0 Facts _facts assembly yaml Assembly metadata _facts plugin types yaml Plugin types and workflow activities _facts sdk steps yaml SDK message processing step registrations Purpose Generated Plugin assembly inventory and registration details Registered Entities AI BEGIN AUTO phonecall tables phonecall README md AI END AUTO

**Path:** plugins/README.md

**Why:** shows inline metadata or schema naming

**Excerpt:** Plugins Documentation Purpose This folder contains documentation for all server side NET plugins registered in the RevOps environment Plugins execute within the Dataverse event pipeline to implement custom business logic validation and data transformation Audience RevOps developers and solution architects Copilot agents performing analysis and impact assessment Business analysts understanding system capabilities What s Documented Here Each plugin assembly has its own subfolder containing README md Overview of plugin purpose and registered SDK steps _facts sdk steps yaml Detailed step configurations table message stage mode rank _facts images yaml Pre image and post image configurations _facts dependencies yaml Tables and fields accessed by the plugin How to Navigate To find a specific plugin Browse subfolders by assembly name e g revops emailplugins revops solutionplugins To understand what triggers a plugin Check _facts sdk steps yaml for table message Create Update etc and stage PreValidation PreOperation PostOperation Review _graph dependencies json



## flows

**Path:** flows/resolvecase/README.md

**Why:** small/medium/large file sample

**Excerpt:** Flow Inventory ResolveCase Purpose Generated Workflow Flow inventory entry Analysis Actions 0 Confidence low Facts _facts flow yaml _facts flow actions yaml Dataverse operations within flow

**Path:** flows/update-last-interaction-portal-comment/README.md

**Why:** small/medium/large file sample

**Excerpt:** Flow Inventory Update Last Interaction Portal Comment Purpose Generated Workflow Flow inventory entry Analysis Actions 0 Confidence low Facts _facts flow yaml _facts flow actions yaml Dataverse operations within flow

**Path:** flows/README.md

**Why:** shows inline metadata or schema naming

**Excerpt:** Flows Cloud Flows Documentation Purpose This folder contains comprehensive documentation for all Power Automate cloud flows in the RevOps environment Flows are automated workflows that orchestrate business processes integrate systems and respond to events within and beyond the Power Platform ecosystem Audience RevOps developers and solution architects Copilot agents performing analysis and impact assessment Business analysts understanding system capabilities What s Documented Here Each flow has its own subfolder containing README md Narrative explanation of flow logic purpose and business context _facts flow actions yaml Action by action breakdown with inputs outputs and table operations _facts metadata yaml Flow trigger type state owner and solution membership _facts dependencies yaml Extracted dependencies on tables connection references and child flows How to Navigate To find a specific flow Browse subfolders by display name normalized with hyphens lowercase Flow folders may include prefix indicators for categorization To understand what a flow does Start



## workstreams

**Path:** workstreams/mwh-csp/README.md

**Why:** small/medium/large file sample

**Excerpt:** Workstream MWH CSP Purpose Omnichannel workstream for knowledge consumption and queue mapping Details Stream Source 192440000 Associated Queues 0 Facts _facts workstream yaml Workstream metadata _facts associated queues yaml Queue associations routing rules queue mappings

**Path:** workstreams/support-voice-eng/README.md

**Why:** small/medium/large file sample

**Excerpt:** Workstream Support Voice ENG Purpose Omnichannel workstream for knowledge consumption and queue mapping Details Stream Source 192440000 Associated Queues 0 Facts _facts workstream yaml Workstream metadata _facts associated queues yaml Queue associations routing rules queue mappings

**Path:** workstreams/README.md

**Why:** shows inline metadata or schema naming

**Excerpt:** Workstreams Omnichannel Documentation Purpose This folder contains documentation for all Omnichannel workstreams in the RevOps environment Workstreams define routing rules assignment logic and channel configurations for customer service interactions Audience RevOps developers and solution architects Copilot agents performing analysis and impact assessment Business analysts understanding system capabilities What s Documented Here Each workstream has its own subfolder containing README md Workstream purpose channel type and routing strategy _facts workstream info yaml Workstream configuration capacity profiles work distribution _facts routing rules yaml Priority based routing rules and conditions How to Navigate To find a specific workstream Browse subfolders by workstream name normalized with hyphens lowercase To understand routing logic Check _facts routing rules yaml for rule priority and conditions Review queue associations in queues queues folder RevOps Documentation Standard All component documentation follows a consistent structure README md Human readable narrative documentation _facts yaml Machine readable structured metadata Dependencies Tracked in



## queues

**Path:** queues/-us-/README.md

**Why:** small/medium/large file sample

**Excerpt:** Queue US Purpose Queue for routing and managing work items cases conversations etc Details Queue ID 268feac2 3f3e ef11 a316 6045bd619d89 Routing No routing rules Exclusions User queues are excluded when owner logical name is systemuser Facts _facts queue yaml Queue configuration _facts routing yaml Routing rules if configured

**Path:** queues/-team-sales-longueuil-/README.md

**Why:** small/medium/large file sample

**Excerpt:** Queue Team Sales Longueuil Purpose Queue for routing and managing work items cases conversations etc Details Queue ID bc8eeac2 3f3e ef11 a316 6045bd619d89 Routing No routing rules Exclusions User queues are excluded when owner logical name is systemuser Facts _facts queue yaml Queue configuration _facts routing yaml Routing rules if configured

**Path:** queues/README.md

**Why:** shows inline metadata or schema naming

**Excerpt:** Queues Documentation Purpose This folder contains documentation for all Dataverse queues used for work distribution and case routing in the RevOps environment Queues organize work items and enable team based assignment Audience RevOps developers and solution architects Copilot agents performing analysis and impact assessment Business analysts understanding system capabilities What s Documented Here Each queue has its own subfolder containing README md Queue purpose membership and routing configuration _facts queue info yaml Queue type public private owner email settings _facts members yaml User and team memberships How to Navigate To find a specific queue Browse subfolders by queue name normalized with hyphens lowercase To understand queue routing Check _facts queue info yaml for queue type and configuration Review workstream associations in workstreams workstreams folder RevOps Documentation Standard All component documentation follows a consistent structure README md Human readable narrative documentation _facts yaml Machine readable structured metadata Dependencies Tracked in _graph



## slas

**Path:** slas/case/README.md

**Why:** small/medium/large file sample

**Excerpt:** SLA Case Purpose Service Level Agreement for 112 records Details Applicable Table 112 Is Default False SLA Items KPIs 14 SLA Items Billing Tier 1 2 First Response Warn after 90min Fail after 120min Billing Tier 3 4 First Response Warn after 210min Fail after 240min First Response Default Warn after 90min Fail after 120min Billing Tier 1 2 Resolution Warn after 1440min Fail after 2880min Billing Tier 3 4 Resolution Warn after 4320min Fail after 5760min Sales Tier 3 4 Resolution Warn after 6480min Fail after 7200min Support Tier 1 2 Resolution Warn after 2160min Fail after 2880min Support Tier 3 4 Resolution Warn after 6480min Fail after 7200min Billing Follow up Warn after 90min Fail after 120min Sales Follow up Warn after 90min Fail after 120min Support Follow up Warn after 90min Fail after 120min Sales Tier 3 4 First Response Warn after 180min Fail after 240min Support

**Path:** slas/README.md

**Why:** shows inline metadata or schema naming

**Excerpt:** SLAs Service Level Agreements Documentation Purpose This folder contains documentation for all Service Level Agreements SLAs configured in the RevOps environment SLAs define time based performance targets and warning thresholds for case resolution Audience RevOps developers and solution architects Copilot agents performing analysis and impact assessment Business analysts understanding system capabilities What s Documented Here Each SLA has its own subfolder containing README md SLA purpose target times and applicability rules _facts sla info yaml SLA configuration KPI targets workflow associations _facts items yaml SLA items with warning failure times and conditions How to Navigate To find a specific SLA Browse subfolders by SLA name normalized with hyphens lowercase To understand SLA rules Check _facts sla info yaml for applicability conditions Review _facts items yaml for warning failure thresholds RevOps Documentation Standard All component documentation follows a consistent structure README md Human readable narrative documentation _facts yaml Machine readable structured

**Path:** slas/6-tier-slo-for-cases/README.md

**Why:** small/medium/large file sample

**Excerpt:** SLA 6 Tier SLO for cases Purpose Service Level Agreement for 112 records Details Applicable Table 112 Is Default True SLA Items KPIs 46 SLA Items Support Tier 2 First Response Warn after 90min Fail after 120min Support Tier 3 First Response Warn after 210min Fail after 240min Support Tier 4 First Response Warn after 210min Fail after 240min Support Tier 6 First Response Warn after 210min Fail after 240min Support Tier 1 Resolution Warn after 2160min Fail after 2880min Support Tier 2 Resolution Warn after 2160min Fail after 2880min Support Tier 3 Resolution Warn after 5760min Fail after 7200min Support Tier 4 Resolution Warn after 5760min Fail after 7200min Support Tier 6 Resolution Warn after 8640min Fail after 11520min Support Tier 1 Follow up Warn after 90min Fail after 120min Support Tier 2 Follow up Warn after 90min Fail after 120min Support Tier 3 Follow Up Warn after 90min



## security-roles

**Path:** security-roles/csr-manager/README.md

**Why:** small/medium/large file sample

**Excerpt:** Security Role CSR Manager Overview Defines permissions for users assigned this role Details Is Managed True Privileges 0 Facts _facts role yaml Role metadata _facts privileges yaml Role privileges entity permissions Common Use Cases Check privileges yaml to understand what Create Read Write Delete Append AppendTo permissions this role grants on each entity

**Path:** security-roles/sherweb-cs-enablement/README.md

**Why:** small/medium/large file sample

**Excerpt:** Security Role Sherweb CS Enablement Overview Defines permissions for users assigned this role Details Is Managed True Privileges 0 Facts _facts role yaml Role metadata _facts privileges yaml Role privileges entity permissions Common Use Cases Check privileges yaml to understand what Create Read Write Delete Append AppendTo permissions this role grants on each entity

**Path:** security-roles/README.md

**Why:** shows inline metadata or schema naming

**Excerpt:** Security Roles Documentation Purpose This folder contains documentation for all security roles configured in the RevOps environment Security roles define permissions access levels and privilege assignments for users and teams Audience RevOps developers and solution architects Copilot agents performing analysis and impact assessment Business analysts understanding system capabilities What s Documented Here Each security role has its own subfolder containing README md Role purpose key privileges and typical user assignments _facts privileges yaml Detailed privilege assignments CRUD depth levels per table _facts role info yaml Role metadata description and solution membership How to Navigate To find a specific role Browse subfolders by role name normalized with hyphens lowercase To understand role permissions Check _facts privileges yaml for table level permissions Create Read Write Delete Append AppendTo Depth levels None User Business Unit Parent Child BU Organization RevOps Documentation Standard All component documentation follows a consistent structure README md Human readable



## environment-variables

**Path:** environment-variables/README.md

**Why:** shows inline metadata or schema naming

**Excerpt:** Environment Variables Documentation Purpose This folder contains documentation for all environment variables in the RevOps environment Environment variables enable configuration management across environments without hard coding values Audience RevOps developers and solution architects Copilot agents performing analysis and impact assessment Business analysts understanding system capabilities What s Documented Here Each environment variable has its own subfolder containing README md Variable purpose expected values and usage context _facts variable info yaml Variable type string number JSON default value and current value How to Navigate To find a specific environment variable Browse subfolders by variable schema name normalized with hyphens lowercase To understand variable usage Check which components reference the variable in dependency graph Review _facts variable info yaml for type and values RevOps Documentation Standard All component documentation follows a consistent structure README md Human readable narrative documentation _facts yaml Machine readable structured metadata Dependencies Tracked in _graph dependencies json _graph



## connection-references

**Path:** connection-references/README.md

**Why:** shows inline metadata or schema naming

**Excerpt:** Connection References Documentation Purpose This folder contains documentation for all connection references in the RevOps environment Connection references enable flows and other components to connect to external services Dataverse SharePoint Teams Azure etc Audience RevOps developers and solution architects Copilot agents performing analysis and impact assessment Business analysts understanding system capabilities What s Documented Here Each connection reference has its own subfolder containing README md Connection reference purpose and connector type _facts connection info yaml Connection metadata connector details and solution membership How to Navigate To find a specific connection reference Browse subfolders by connection reference name normalized with hyphens lowercase To understand connection usage Check which flows use the connection in flows flows folder Review _facts connection info yaml for connector details RevOps Documentation Standard All component documentation follows a consistent structure README md Human readable narrative documentation _facts yaml Machine readable structured metadata Dependencies Tracked in _graph dependencies



## Power Pages

**Path:** Power Pages/Site/weblink-sets/weblink-sets.md

**Why:** small/medium/large file sample

**Excerpt:** Weblink Sets This section documents all weblink sets in the Power Pages site List of Weblink Sets default profile navigation For each set details on configuration and usage will be provided

**Path:** Power Pages/Site/web-templates/breadcrumbs.md

**Why:** shows inline metadata or schema naming

**Excerpt:** Breadcrumbs Web Template Overview A simple breadcrumb navigation template that displays the hierarchical path to the current page using the site s page structure Location c RevOps Power Page Site paportal swdevportal web templates breadcrumbs Configuration Template Name Breadcrumbs Input Parameter title optional Custom title for active breadcrumb defaults to page title Custom Code Liquid Template Key Features 1 Hierarchical Navigation Loops through page breadcrumbs collection Displays parent pages in order Current page shown as active non clickable 2 Title Truncation Breadcrumb titles truncated to 24 characters Prevents overflow on long page names Full title shown in title attribute tooltip 3 Active Breadcrumb Last item marked with active class Not a link semantic HTML Uses Liquid block for extensibility 4 HTML Encoding All output escaped with h filter Prevents XSS vulnerabilities Titles and URLs sanitized 5 Customizable Title Accepts title parameter Falls back to page title Allows override for special

**Path:** Power Pages/Site/web-templates/README.md

**Why:** large file with weak headings

**Excerpt:** Web Templates Documentation Summary Overview This document provides a comprehensive summary of all documented web templates in the Power Pages site highlighting their complexity functionality and key features Documentation Location c RevOps RevOps Analysts Documentation Power Pages Site web templates High Complexity Templates Custom Logic Integrations 1 API Cumulus Orgs â â â â â File api cumulus orgs md Complexity Level Very High Key Features FetchXML Query with table permissions security JSON API endpoint no layout returns application json GUID validation with regex pattern matching Custom entity integration revops_cumulusorganization Error handling with structured JSON responses Security Requires table permissions and web role assignment Use Case AJAX fetch calls to populate organization dropdowns based on parent Cumulus Account Notable Code Validates accountid parameter before querying Returns up to 500 organizations Uses no lock true for read consistency 2 Header â â â â â File header md Complexity Level Very



## web-resources

**Path:** web-resources/revops-churn/README.md

**Why:** small/medium/large file sample

**Excerpt:** Web Resource Churn JS Overview JavaScript file used for form customizations and client side logic File Name revops_churn Description Facts _facts webresource yaml Web resource metadata _facts code js JavaScript source code if available

**Path:** web-resources/revops-filtercumulusorgs/README.md

**Why:** small/medium/large file sample

**Excerpt:** Web Resource Filter Cumulus Organizations Overview JavaScript file used for form customizations and client side logic File Name revops_filtercumulusorgs Description Facts _facts webresource yaml Web resource metadata _facts code js JavaScript source code if available

**Path:** web-resources/README.md

**Why:** shows inline metadata or schema naming

**Excerpt:** Web Resources Documentation Purpose This folder contains documentation for all web resources JavaScript CSS HTML images used in the RevOps environment Web resources extend model driven app functionality with custom client side logic Audience RevOps developers and solution architects Copilot agents performing analysis and impact assessment Business analysts understanding system capabilities What s Documented Here Each web resource has its own subfolder containing README md Web resource purpose usage context and form associations _facts resource info yaml Resource type content type and solution membership How to Navigate To find a specific web resource Browse subfolders by resource name normalized with hyphens lowercase To understand web resource usage Check README md for form view associations Review _facts resource info yaml for metadata RevOps Documentation Standard All component documentation follows a consistent structure README md Human readable narrative documentation _facts yaml Machine readable structured metadata Dependencies Tracked in _graph dependencies json _graph



