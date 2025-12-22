# Flows Recommended for Plugin Conversion

**Analysis Date**: 2025-12-16  
**Total Flows Analyzed**: 111  
**Flows Recommended for Conversion**: 33

## Conversion Criteria

Flows should be converted to plugins when they meet these criteria:

1. **Synchronous Execution Required**: Business logic must execute immediately within the transaction
2. **Simple Field Operations**: Basic calculations, data transformations, or field updates
3. **No External Dependencies**: No calls to external APIs, services, or connectors (beyond Dataverse)
4. **Performance Critical**: Latency matters for user experience
5. **Data Integrity**: Must ensure atomic operations within the database transaction
6. **High Frequency**: Executes frequently (onCreate/onUpdate of common entities)

---

## HIGH PRIORITY - Simple Field Updates (17 flows)

These flows perform simple, synchronous field operations that should execute within the database transaction.

### Domain Extraction (2 flows)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **contact-extractdomainfromemail** | Contact Create/Update (emailaddress1) | Split email by '@', extract domain, update revops_domain | Simple string parsing, no external calls, should be synchronous |
| **lead-extractdomainfromemail** | Lead Create/Update (emailaddress1) | Split email by '@', extract domain, update revops_domain | Simple string parsing, no external calls, should be synchronous |

### Date Stamping (4 flows)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **activityemail-stampsqldate** | Email Create | Stamp SQL date on first activity for Lead | Simple date field update, should be synchronous |
| **activityphone-stampsqldate** | Phone Call Create | Stamp SQL date on first activity for Lead | Simple date field update, should be synchronous |
| **activitytasks-stampsqldate** | Task Create/Update | Stamp SQL date on first activity for Lead | Simple date field update, should be synchronous |
| **lead-mqldate** | Lead Update (salesready, status) | Set MQL date when lead becomes sales ready | Simple date stamp, critical for lead scoring |

### Lookup/Reference Updates (6 flows)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **accountproductsummary-copyaccountkey** | Account Product Summary Create | Copy accountkey to accountid lookup | Simple lookup field mapping, should be atomic |
| **accountsolutionssummary-copyaccountkey** | Account Solution Summary Create | Copy accountkey to accountid lookup | Simple lookup field mapping, should be atomic |
| **account-setcumulusaccountcreatedonopps** | Account Create/Update | Set flag when Cumulus account exists on Opps | Simple boolean flag update |
| **competitor-createcurrentproviderwhenacompetitorisc** | Competitor Create | Create Current Provider record when competitor added | Simple related record creation |
| **vendoraccount-createsolutionproviderfromvendor** | Vendor Account Create | Create Solution Provider from Vendor | Simple related record creation |
| **opportunityupdateprobabilitywhenwon** | Opportunity Update | Update probability when opportunity won | Simple field update based on status |

### Territory Assignment (2 flows)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **account-setterritoryonaccount** | Account Create/Update | Set territory based on country/state | Territory assignment should be synchronous for routing |
| **leadukcookiefallbackterritory** | Lead Create/Update | Set UK territory fallback based on cookie | Territory assignment should be synchronous |

### Queue Management (3 flows)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **queueitemreleasesetcaseowner** | Queue Item Create/Update | Set case owner when queue item released | Should be atomic with queue operation |
| **queueitemownershipchangebasedoncaseownership** | Queue Item Create/Update | Update queue item owner based on case owner | Should be synchronous with ownership change |
| **casequeueupdate-updatequeueitem** | Case Update (queue) | Update queue item when case queue changes | Should be atomic with queue assignment |

---

## MEDIUM PRIORITY - Moderate Complexity (10 flows)

These flows have slightly more complex logic but still suitable for plugin conversion.

### Account/Contact Matching (3 flows)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **lead-resolveaccountbydomain** | Lead Create/Update (revops_domain) | FetchXML to find accounts by domain, associate if 1 found, add note if multiple | Could benefit from synchronous execution, prevents duplicate work |
| **contact-resolveaccountbydomain** | Contact Create/Update (revops_domain) | FetchXML to find accounts by domain, associate if 1 found, add note if multiple | Could benefit from synchronous execution, prevents duplicate work |
| **lead-resolvecontactbyemail** | Lead Create/Update | Resolve contact by email address | Prevents duplicate contacts |

### BPF Stage Updates (2 flows)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **opportunity-setcurrentbpfstage-sherweboppbpf** | Opportunity Create/Update | Set current BPF stage for Sherweb Opp BPF | BPF updates should be synchronous |
| **opportunity-setcurrentbpfstage-sherwebsalesbpf** | Opportunity Create/Update | Set current BPF stage for Sherweb Sales BPF | BPF updates should be synchronous |

### Solution Summary Management (2 flows)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **opportunitysolution-createsolutionsummary** | Opportunity Solution Create/Update | Create/update solution summary text field | Could be calculated field in plugin |
| **opportunity-updatesolutionsummary** | Opportunity Create/Update | Update solution summary when opportunity changes | Could be calculated field in plugin |

### Activity Notes (1 flow)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **phonecall-addnotestodescription** | Phone Call Create/Update | Append notes to description field | Simple text concatenation |

### Last Interaction Tracking (3 flows)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **updatelastinteraction-email** | Email Create | Update last interaction date on parent record | Activity tracking should be synchronous |
| **updatelastinteraction-note** | Note Create | Update last interaction date on parent record | Activity tracking should be synchronous |
| **updatelastinteraction-portalcomment** | Portal Comment Create | Update last interaction date on parent record | Activity tracking should be synchronous |

---

## LOW PRIORITY - Complex Logic (6 flows)

These flows are technically feasible for plugin conversion but have additional complexity to consider.

### Territory Logic (1 flow)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **lead-setterritoryonlead** | Lead Create/Update (country, state, parentaccount) | Complex territory lookup with FetchXML, multiple conditions for US/Canada vs other countries, fallback logic | Complex but deterministic, could improve performance as plugin |

### Customer Response Tracking (2 flows)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **incomingemailsetcustomerresponded** | Email Create (regarding Case) | Set customer responded flag when email direction is incoming | Simple flag update with conditional logic |
| **incomingportalcommentsetcustomerresponded** | Portal Comment Create | Set customer responded flag on Case | Simple flag update with conditional logic |

### Lookups and Associations (3 flows)
| Flow Name | Trigger | Logic | Reason |
|-----------|---------|-------|--------|
| **setcaselookupvalueoncustomerfeedbacksurveyresponse** | Survey Response Create/Update | Set case lookup from survey | Survey integration might have timing dependencies |
| **audienceimport-upsertcontactandassociate** | Audience Import Create/Update | Upsert contact and associate with marketing list | Batch import flow, might need to stay async |
| **lead-checkparentaccountrelationshipfortradeshowlea** | Lead Create/Update | Check and validate parent account for trade show leads | Business rule validation |

---

## NOT RECOMMENDED - Keep as Flows (78 flows)

These flows should remain as Power Automate flows for the following reasons:

### External API/Service Integrations (15 flows)
- **enrichaccount-oncreate**, **enrichaccount-scheduled**, **enrichaccount-manual**: Call external enrichment API
- **enrichcontact-oncreate**, **enrichcontact-scheduled**, **enrichcontact-manual**: Call external enrichment API  
- **enrichlead-oncreate**, **enrichlead-scheduled**: Call external enrichment API
- **casetonice**, **conversationstonice**: Integration with NICE system
- **calendlycreateandupdatealeadwhenacalendlyeventiscr**: Calendly integration
- **gtwregistrantadded**, **gtwgetcheck-ins**, **gtwwebinariscreated**: GoToWebinar integration
- **events-scannedimportconnectiontoeventandmore**: Event scanning integration
- **commitmentagreementform**: Form integration

### Email/Notification Flows (8 flows)
- **case-sendnotificationtoownerwhenacustomerreplies**: Sends email notifications
- **caseresolutionsurvey**: Sends survey emails
- **accountownershipchangenotification**: Email notification
- **leadnotifyuserwhenassigned**: Email notification
- **cs-notifymanagerofcustomerescalation**: Email notification
- **createworkitem-approveenablemailbox**: Approval workflow with emails
- **marketing-reportinactivecampaignowner**: Email reporting
- **p2ptransfernotifications**: Email notifications

### Scheduled/Batch Operations (13 flows)
- **fillparentaccountofcumulusaccount**: Scheduled batch update of parent accounts
- **linkcumulusaccountstoparentaccounts**: Manual batch linking operation
- **iso3166cumulusaccounttoaccount-scheduled**: Scheduled ISO mapping
- **dailytierupdatepermrr**: Daily scheduled tier updates
- **day0-cumulusces**: Daily Day 0 processing
- **cs-automatedunresponsiveprocess**: Scheduled unresponsive case processing
- **marketing-reviewproposedenddate**: Scheduled campaign review
- **updatecurrencyexchangerates**: Scheduled currency updates
- **revopschangelog**: Scheduled changelog generation
- **account-created-in-cumulus**: Complex batch processing from Cumulus
- **accountcreatedincumulus**: Complex batch processing from Cumulus
- **p2pautomation**: P2P automation batch processing
- **selectorgsfromcumuluswhereclientuniquename**: Power BI query flow

### Manual/On-Demand Operations (12 flows)
- **account-backfillchannelrelationship**: Manual backfill operation
- **accounts-manual-fixgenericdomainsformat**: Manual domain format fixes
- **fixaccountswithoutname**: Manual data cleanup
- **fixprimarycontactonaccount**: Manual data cleanup
- **contact-extractdomainfromemailselectingrows**: Manual batch domain extraction
- **contact-resolveaccountbydomainselectrow**: Manual account resolution
- **bulkresolvecases**: Bulk case resolution
- **globalpittier**: Manual tier assignment
- **incompletecart**: Manual cart processing
- **iso-3166-cumulus-account-to-account**: Manual ISO mapping
- **iso3166cumulusaccounttoaccount-manual**: Manual ISO mapping
- **formsubmission-manualparsingutmvalues**: Manual UTM parsing

### Complex Multi-Step Workflows (10 flows)
- **formsubmission-parsingutmvalues**: Complex UTM parsing with multiple steps
- **formsubmission-utmshenanigansenrichmentconsentproc**: Complex form processing with enrichment
- **createcasefrommigrationrequest**: Multi-step case creation workflow
- **createcasefromzabbixalert**: Multi-step alerting workflow
- **cs-casecreateformanualaccountcreationforukpartners**: Complex UK partner case creation
- **p2ptransferpopulationfromcase**: Complex P2P transfer logic
- **sendp2ptransfer**: Complex P2P transfer sending
- **vmware-contractrequest**: Contract request workflow
- **veeam-contractrequest**: Contract request workflow
- **marketing-closeassetfromcampaign**: Multi-step campaign closure

### Cumulus Integration Flows (6 flows)
- **cumulususercreated**: Cumulus user sync
- **cumulusaccountmanagerupdate**: Cumulus account manager sync
- **cumulusaccountmanager-usercreatedorupdated**: Cumulus user/manager sync
- **cumulusaccountmanager-teamcreatedorupdated**: Cumulus team sync
- **linkcumulususercontacttoaccount**: Cumulus user-contact linking
- **linkcumulususerstocontact**: Cumulus user-contact linking

### Supported Service/Channel Tracking (2 flows)
- **setsupportedservicecolumn-emailchannel**: Email channel tracking
- **assignsmeengagementtoobjectowner**: SME engagement assignment

### Journey/Marketing Automation (3 flows)
- **journey-customtriggerforlead**: Custom journey trigger
- **journeydcij-websitecontactformsubmitted**: Journey form submission
- **zremovejourneymanualdcij-websitecontactformsubmitt**: Journey removal

### Other Complex Flows (9 flows)
- **attachfiletoasana**: Asana file attachment integration
- **opportunity-createopportunitiesfromaccountpotentia**: Complex opportunity creation from potential
- **lead-disqualifyhoneypotfieldcontainsdata**: Honeypot spam detection
- **account-setcumulusaccountcreatedonopps**: Cumulus flag setting (already in HIGH priority)
- **organizationcreatedordeletedincumulus**: Cumulus org sync
- **setcustomerverifiedresolutionvalue**: Customer verification workflow
- **mwh-omitaccountsandcontactsfromconsent**: Consent management

---

## Implementation Priority

### Phase 1 (Immediate) - 8 Flows
High-value, simple conversions with immediate performance benefits:
1. contact-extractdomainfromemail
2. lead-extractdomainfromemail
3. activityemail-stampsqldate
4. activityphone-stampsqldate
5. activitytasks-stampsqldate
6. lead-mqldate
7. accountproductsummary-copyaccountkey
8. accountsolutionssummary-copyaccountkey

### Phase 2 (Near-term) - 11 Flows
Territory, queue, and lookup operations:
1. account-setterritoryonaccount
2. leadukcookiefallbackterritory
3. queueitemreleasesetcaseowner
4. queueitemownershipchangebasedoncaseownership
5. casequeueupdate-updatequeueitem
6. account-setcumulusaccountcreatedonopps
7. competitor-createcurrentproviderwhenacompetitorisc
8. vendoraccount-createsolutionproviderfromvendor
9. opportunityupdateprobabilitywhenwon
10. updatelastinteraction-email
11. updatelastinteraction-note

### Phase 3 (Future) - 14 Flows
More complex logic requiring thorough testing:
1. lead-resolveaccountbydomain
2. contact-resolveaccountbydomain
3. lead-resolvecontactbyemail
4. lead-setterritoryonlead
5. opportunity-setcurrentbpfstage-sherweboppbpf
6. opportunity-setcurrentbpfstage-sherwebsalesbpf
7. opportunitysolution-createsolutionsummary
8. opportunity-updatesolutionsummary
9. phonecall-addnotestodescription
10. updatelastinteraction-portalcomment
11. incomingemailsetcustomerresponded
12. incomingportalcommentsetcustomerresponded
13. setcaselookupvalueoncustomerfeedbacksurveyresponse
14. lead-checkparentaccountrelationshipfortradeshowlea

---

## Plugin Development Guidelines

### Performance Considerations
- **Pre-Validation vs Post-Operation**: Most simple field updates should run in Post-Operation (async) unless they affect validation
- **Synchronous Mode**: Only use synchronous execution when necessary (territory assignment, queue operations)
- **Error Handling**: Implement robust try-catch blocks; flow failures are more visible than plugin failures
- **Logging**: Add comprehensive logging for debugging (ITracingService)

### Testing Requirements
- Unit tests for all plugin logic
- Integration tests with real Dataverse environment
- Performance testing (compare flow vs plugin execution time)
- User acceptance testing for business logic validation

### Migration Strategy
1. Build plugin with equivalent logic
2. Deploy to DEV environment
3. Deactivate flow in DEV
4. Test for 1-2 weeks
5. Compare execution logs and performance
6. Deploy to TEST → UAT → PROD
7. Archive flow (do not delete immediately)

### Rollback Plan
- Keep flows deactivated (not deleted) for 30 days post-deployment
- Document any edge cases discovered during plugin execution
- Maintain ability to reactivate flow if plugin issues arise

---

## Benefits of Conversion

### Performance Improvements
- **Reduced Latency**: Plugin execution ~50-200ms vs Flow execution ~2-10 seconds
- **Synchronous Execution**: No async delays for critical operations
- **Database Transaction**: Atomic operations ensure data consistency

### Operational Benefits
- **Solution Packaging**: Plugins deploy as part of solution (no separate flow activation)
- **Version Control**: C# code in source control vs Flow JSON exports
- **ALM Friendly**: Better CI/CD integration
- **Licensing**: Plugins don't consume Power Automate run quota

### Maintenance Benefits
- **Unit Testing**: Traditional software testing practices
- **Debugging**: Visual Studio debugging vs Flow run history
- **Code Reuse**: Shared libraries and helper classes
- **Type Safety**: Compile-time error checking

---

## Risks and Considerations

### Development Complexity
- Requires .NET development skills (C#)
- More complex deployment process than flows
- Harder to modify for business users (no low-code editing)

### Maintenance Overhead
- Requires developer expertise to maintain
- Changes require code deployment (vs flow editing in UI)
- Debugging requires access to plugin trace logs

### Business Continuity
- Plugin failures less visible than flow failures
- No built-in retry mechanism (flows auto-retry)
- Must implement custom error handling and logging

---

## Conclusion

**33 flows** are suitable candidates for plugin conversion, representing **30% of total flows**. The recommended approach is a **phased migration** starting with the simplest, highest-value conversions (Phase 1) to validate the approach and build team expertise before tackling more complex flows.

The remaining **78 flows (70%)** should stay as Power Automate flows due to external integrations, email/notifications, scheduled operations, or complex multi-step workflows that benefit from the visual design and maintainability of flows.
