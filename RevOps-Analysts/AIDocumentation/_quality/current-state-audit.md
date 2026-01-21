# AIDocumentation Current-State Audit

## Executive Summary
- Repository inventory completed with file-type counts and size by top-level folder.
- Many folders have markdown, but structure/metadata consistency varies and front matter appears uncommon.
- Cross-linking exists but is uneven; identifiers are present yet not standardized for search optimization.
- RUNS, _registry, and _graph folders show characteristics of generated outputs; manual documentation appears in domain folders.

## Repo Structure Overview
| Folder | Total Size (KB) | .md | .yaml/.yml | .json | .txt | others |
|---|---:|---:|---:|---:|---:|---:|
| _graph | 71 | 2 | 2 | 1 | 1 | 0 |
| _quality | 962 | 11 | 1 | 1 | 1 | 0 |
| _registry | 95 | 1 | 2 |  | 1 | 0 |
| _shared | 6 | 3 |  |  | 1 | 0 |
| app-modules | 40 | 23 | 44 |  | 24 | 0 |
| business-process-flows | 29 | 20 | 32 |  | 20 | 0 |
| connection-references | 6 | 1 | 1 |  | 1 | 0 |
| environment-variables | 29 | 1 | 1 |  | 1 | 0 |
| flows | 125 | 107 | 106 |  | 108 | 0 |
| plugins | 10 | 4 | 6 |  | 5 | 0 |
| Power Pages | 426 | 92 |  |  | 5 | 0 |
| queues | 123 | 95 | 94 |  | 96 | 0 |
| README.md | 12 | 1 |  |  |  | 0 |
| README.txt | 1 |  |  |  | 1 | 0 |
| RUNS | 2689 | 36 | 21 | 14 | 1 | 0 |
| security-roles | 3865 | 24 | 46 |  | 25 | 0 |
| slas | 15 | 4 | 6 |  | 5 | 0 |
| tables | 6704 | 93 | 466 |  | 94 | 0 |
| web-resources | 34 | 28 | 27 |  | 28 | 0 |
| workstreams | 35 | 28 | 27 |  | 29 | 0 |

### README Entry Points
- _graph: _graph/README.md, _graph/README.txt
- _quality: _quality/README.md, _quality/README.txt
- _registry: _registry/README.md, _registry/README.txt
- _shared: _shared/README.md, _shared/README.txt
- app-modules: app-modules/README.md, app-modules/README.txt, app-modules/channel-integration-framework/README.md, app-modules/channel-integration-framework/README.txt, app-modules/copilot-service-admin-center/README.md, app-modules/copilot-service-admin-center/README.txt, app-modules/customer-insights-journeys/README.md, app-modules/customer-insights-journeys/README.txt, app-modules/customer-service-hub/README.md, app-modules/customer-service-hub/README.txt, app-modules/customer-service-team-member/README.md, app-modules/customer-service-team-member/README.txt, app-modules/customer-service-workspace/README.md, app-modules/customer-service-workspace/README.txt, app-modules/dataverse-accelerator-app/README.md, app-modules/dataverse-accelerator-app/README.txt, app-modules/dynamics-365-app-for-outlook/README.md, app-modules/dynamics-365-app-for-outlook/README.txt, app-modules/omnichannel-admin-center/README.md, app-modules/omnichannel-admin-center/README.txt, app-modules/omnichannel-administration/README.md, app-modules/omnichannel-administration/README.txt, app-modules/omnichannel-for-customer-service/README.md, app-modules/omnichannel-for-customer-service/README.txt, app-modules/portal-management/README.md, app-modules/portal-management/README.txt, app-modules/power-pages-management/README.md, app-modules/power-pages-management/README.txt, app-modules/power-platform-environment-settings/README.md, app-modules/power-platform-environment-settings/README.txt, app-modules/project/README.md, app-modules/project/README.txt, app-modules/project-operations/README.md, app-modules/project-operations/README.txt, app-modules/project-operations-team-member/README.md, app-modules/project-operations-team-member/README.txt, app-modules/resource-scheduling/README.md, app-modules/resource-scheduling/README.txt, app-modules/sales-hub/README.md, app-modules/sales-hub/README.txt, app-modules/sales-team-member/README.md, app-modules/sales-team-member/README.txt, app-modules/solution-health-hub/README.md, app-modules/solution-health-hub/README.txt, app-modules/teams-virtual-events/README.md, app-modules/teams-virtual-events/README.txt
- business-process-flows: business-process-flows/README.md, business-process-flows/README.txt, business-process-flows/after-meeting/README.md, business-process-flows/after-meeting/README.txt, business-process-flows/change-password-for-portals-contact/README.md, business-process-flows/change-password-for-portals-contact/README.txt, business-process-flows/eventmainbusinessprocessflow/README.md, business-process-flows/eventmainbusinessprocessflow/README.txt, business-process-flows/expired-process/README.md, business-process-flows/expired-process/README.txt, business-process-flows/follow-up-with-opportunity/README.md, business-process-flows/follow-up-with-opportunity/README.txt, business-process-flows/iot-alert-to-case-process/README.md, business-process-flows/iot-alert-to-case-process/README.txt, business-process-flows/lead-to-opportunity-marketing-sales-process/README.md, business-process-flows/lead-to-opportunity-marketing-sales-process/README.txt, business-process-flows/new-process/README.md, business-process-flows/new-process/README.txt, business-process-flows/phone-to-case-process/README.md, business-process-flows/phone-to-case-process/README.txt, business-process-flows/project-service-invoice-process/README.md, business-process-flows/project-service-invoice-process/README.txt, business-process-flows/project-service-project-stages/README.md, business-process-flows/project-service-project-stages/README.txt, business-process-flows/project-service-subcontract-stages/README.md, business-process-flows/project-service-subcontract-stages/README.txt, business-process-flows/project-service-time-entry-edit/README.md, business-process-flows/project-service-time-entry-edit/README.txt, business-process-flows/project-service-time-entry-row-edit/README.md, business-process-flows/project-service-time-entry-row-edit/README.txt, business-process-flows/project-service-vendor-invoice-business-process/README.md, business-process-flows/project-service-vendor-invoice-business-process/README.txt, business-process-flows/sherweb-opportunity-bpf/README.md, business-process-flows/sherweb-opportunity-bpf/README.txt, business-process-flows/sherweb-sales-bpf/README.md, business-process-flows/sherweb-sales-bpf/README.txt, business-process-flows/translation-process/README.md, business-process-flows/translation-process/README.txt, business-process-flows/update-contact/README.md, business-process-flows/update-contact/README.txt
- connection-references: connection-references/README.md, connection-references/README.txt
- environment-variables: environment-variables/README.md, environment-variables/README.txt
- flows: flows/README.md, flows/README.txt, flows/-activity-email-stamp-sql-date/README.md, flows/-activity-email-stamp-sql-date/README.txt, flows/-activity-phone-stamp-sql-date/README.md, flows/-activity-phone-stamp-sql-date/README.txt, flows/-activity-tasks-stamp-sql-date/README.md, flows/-activity-tasks-stamp-sql-date/README.txt, flows/-audience-import-upsert-contact-and-associate/README.md, flows/-audience-import-upsert-contact-and-associate/README.txt, flows/-calendly-create-and-update-a-lead-when-a-calendly-event-is-created/README.md, flows/-calendly-create-and-update-a-lead-when-a-calendly-event-is-created/README.txt, flows/-events-scanned-import-connection-to-event-and-more/README.md, flows/-events-scanned-import-connection-to-event-and-more/README.txt, flows/-form-submission-utm-shenanigans-enrichment-consent-processing/README.md, flows/-form-submission-utm-shenanigans-enrichment-consent-processing/README.txt, flows/-global-pit-tier/README.md, flows/-global-pit-tier/README.txt, flows/-journey-custom-trigger-for-lead/README.md, flows/-journey-custom-trigger-for-lead/README.txt, flows/-journey-dcij-website-contact-form-submitted/README.md, flows/-journey-dcij-website-contact-form-submitted/README.txt, flows/-lead-check-parent-account-relationship-for-trade-show-lead/README.md, flows/-lead-check-parent-account-relationship-for-trade-show-lead/README.txt, flows/-lead-disqualify-honeypot-field-contains-data/README.md, flows/-lead-disqualify-honeypot-field-contains-data/README.txt, flows/-lead-mql-date/README.md, flows/-lead-mql-date/README.txt, flows/-lead-notify-user-when-assigned/README.md, flows/-lead-notify-user-when-assigned/README.txt, flows/-lead-uk-cookie-fallback-territory/README.md, flows/-lead-uk-cookie-fallback-territory/README.txt, flows/-mwh-omit-accounts-and-contacts-from-consent/README.md, flows/-mwh-omit-accounts-and-contacts-from-consent/README.txt, flows/-phone-call-add-notes-to-description/README.md, flows/-phone-call-add-notes-to-description/README.txt, flows/account-backfill-channel-relationship/README.md, flows/account-backfill-channel-relationship/README.txt, flows/account-created-in-cumulus/README.md, flows/account-created-in-cumulus/README.txt, flows/account-ownership-change-notification/README.md, flows/account-ownership-change-notification/README.txt, flows/account-product-summary-copy-account-key/README.md, flows/account-product-summary-copy-account-key/README.txt, flows/account-set-cumulus-account-created-on-opps/README.md, flows/account-set-cumulus-account-created-on-opps/README.txt, flows/account-set-territory-on-account/README.md, flows/account-set-territory-on-account/README.txt, flows/account-solutions-summary-copy-account-key/README.md, flows/account-solutions-summary-copy-account-key/README.txt, flows/accounts-manual-fix-generic-domains-format/README.md, flows/accounts-manual-fix-generic-domains-format/README.txt, flows/assign-sme-engagement-to-object-owner/README.md, flows/assign-sme-engagement-to-object-owner/README.txt, flows/attach-file-to-asana/README.md, flows/attach-file-to-asana/README.txt, flows/bulk-resolve-cases/README.md, flows/bulk-resolve-cases/README.txt, flows/case-queue-update-update-queue-item/README.md, flows/case-queue-update-update-queue-item/README.txt, flows/case-resolution-survey/README.md, flows/case-resolution-survey/README.txt, flows/case-send-notification-to-owner-when-a-customer-replies/README.md, flows/case-send-notification-to-owner-when-a-customer-replies/README.txt, flows/case-to-nice/README.md, flows/case-to-nice/README.txt, flows/commitment-agreement-form/README.md, flows/commitment-agreement-form/README.txt, flows/competitor-create-current-provider-when-a-competitor-is-created/README.md, flows/competitor-create-current-provider-when-a-competitor-is-created/README.txt, flows/contact-extract-domain-from-email/README.md, flows/contact-extract-domain-from-email/README.txt, flows/contact-extract-domain-from-email-selecting-rows-/README.md, flows/contact-extract-domain-from-email-selecting-rows-/README.txt, flows/contact-resolve-account-by-domain/README.md, flows/contact-resolve-account-by-domain/README.txt, flows/contact-resolve-account-by-domain-select-row-/README.md, flows/contact-resolve-account-by-domain-select-row-/README.txt, flows/conversations-to-nice/README.md, flows/conversations-to-nice/README.txt, flows/create-case-from-migration-request/README.md, flows/create-case-from-migration-request/README.txt, flows/create-case-from-zabbix-alert/README.md, flows/create-case-from-zabbix-alert/README.txt, flows/create-work-item-approve-enable-mailbox/README.md, flows/create-work-item-approve-enable-mailbox/README.txt, flows/cs-case-create-for-manual-account-creation-for-uk-partners/README.md, flows/cs-case-create-for-manual-account-creation-for-uk-partners/README.txt, flows/cs-notify-manager-of-customer-escalation/README.md, flows/cs-notify-manager-of-customer-escalation/README.txt, flows/cumulus-account-manager-team-created-or-updated/README.md, flows/cumulus-account-manager-team-created-or-updated/README.txt, flows/cumulus-account-manager-update/README.md, flows/cumulus-account-manager-update/README.txt, flows/cumulus-account-manager-user-created-or-updated/README.md, flows/cumulus-account-manager-user-created-or-updated/README.txt, flows/cumulus-user-created/README.md, flows/cumulus-user-created/README.txt, flows/daily-tier-update-per-mrr-/README.md, flows/daily-tier-update-per-mrr-/README.txt, flows/day-0-cumulus-ces/README.md, flows/day-0-cumulus-ces/README.txt, flows/enrich-account-manual/README.md, flows/enrich-account-manual/README.txt, flows/enrich-account-oncreate/README.md, flows/enrich-account-oncreate/README.txt, flows/enrich-account-scheduled/README.md, flows/enrich-account-scheduled/README.txt, flows/enrich-contact-manual/README.md, flows/enrich-contact-manual/README.txt, flows/enrich-contact-oncreate/README.md, flows/enrich-contact-oncreate/README.txt, flows/enrich-contact-scheduled/README.md, flows/enrich-contact-scheduled/README.txt, flows/enrich-lead-oncreate/README.md, flows/enrich-lead-oncreate/README.txt, flows/enrich-lead-scheduled/README.md, flows/enrich-lead-scheduled/README.txt, flows/fill-parent-account-of-cumulus-account/README.md, flows/fill-parent-account-of-cumulus-account/README.txt, flows/fix-accounts-without-name/README.md, flows/fix-accounts-without-name/README.txt, flows/fix-primary-contact-on-account/README.md, flows/fix-primary-contact-on-account/README.txt, flows/gtw-get-check-ins/README.md, flows/gtw-get-check-ins/README.txt, flows/gtw-registrant-added/README.md, flows/gtw-registrant-added/README.txt, flows/gtw-webinar-is-created/README.md, flows/gtw-webinar-is-created/README.txt, flows/incoming-email-set-customer-responded/README.md, flows/incoming-email-set-customer-responded/README.txt, flows/incoming-portal-comment-set-customer-responded/README.md, flows/incoming-portal-comment-set-customer-responded/README.txt, flows/incomplete-cart/README.md, flows/incomplete-cart/README.txt, flows/iso-3166-cumulus-account-to-account-manual/README.md, flows/iso-3166-cumulus-account-to-account-manual/README.txt, flows/iso-3166-cumulus-account-to-account-scheduled/README.md, flows/iso-3166-cumulus-account-to-account-scheduled/README.txt, flows/lead-extract-domain-from-email/README.md, flows/lead-extract-domain-from-email/README.txt, flows/lead-resolve-account-by-domain/README.md, flows/lead-resolve-account-by-domain/README.txt, flows/lead-resolve-contact-by-email/README.md, flows/lead-resolve-contact-by-email/README.txt, flows/lead-set-territory-on-lead/README.md, flows/lead-set-territory-on-lead/README.txt, flows/link-cumulus-accounts-to-parent-accounts/README.md, flows/link-cumulus-accounts-to-parent-accounts/README.txt, flows/link-cumulus-user-contact-to-account/README.md, flows/link-cumulus-user-contact-to-account/README.txt, flows/link-cumulus-users-to-contact/README.md, flows/link-cumulus-users-to-contact/README.txt, flows/marketing-close-asset-from-campaign/README.md, flows/marketing-close-asset-from-campaign/README.txt, flows/marketing-report-inactive-campaign-owner/README.md, flows/marketing-report-inactive-campaign-owner/README.txt, flows/marketing-review-proposed-end-date/README.md, flows/marketing-review-proposed-end-date/README.txt, flows/opportunity-create-opportunities-from-account-potential/README.md, flows/opportunity-create-opportunities-from-account-potential/README.txt, flows/opportunity-set-current-bpf-stage-sherweb-opp-bpf/README.md, flows/opportunity-set-current-bpf-stage-sherweb-opp-bpf/README.txt, flows/opportunity-set-current-bpf-stage-sherweb-sales-bpf/README.md, flows/opportunity-set-current-bpf-stage-sherweb-sales-bpf/README.txt, flows/opportunity-solution-create-solution-summary/README.md, flows/opportunity-solution-create-solution-summary/README.txt, flows/opportunity-update-probability-when-won/README.md, flows/opportunity-update-probability-when-won/README.txt, flows/opportunity-update-solution-summary/README.md, flows/opportunity-update-solution-summary/README.txt, flows/organization-created-or-deleted-in-cumulus/README.md, flows/organization-created-or-deleted-in-cumulus/README.txt, flows/p2p-automation/README.md, flows/p2p-automation/README.txt, flows/p2p-transfer-notifications/README.md, flows/p2p-transfer-notifications/README.txt, flows/p2p-transfer-population-from-case/README.md, flows/p2p-transfer-population-from-case/README.txt, flows/queue-item-ownership-change-based-on-case-ownership/README.md, flows/queue-item-ownership-change-based-on-case-ownership/README.txt, flows/queue-item-release-set-case-owner/README.md, flows/queue-item-release-set-case-owner/README.txt, flows/resolvecase/README.md, flows/resolvecase/README.txt, flows/revops-change-log/README.md, flows/revops-change-log/README.txt, flows/select-orgs-from-cumulus-where-clientuniquename/README.md, flows/select-orgs-from-cumulus-where-clientuniquename/README.txt, flows/send-p2p-transfer/README.md, flows/send-p2p-transfer/README.txt, flows/set-case-lookup-value-on-customer-feedback-survey-response/README.md, flows/set-case-lookup-value-on-customer-feedback-survey-response/README.txt, flows/set-customer-verified-resolution-value/README.md, flows/set-customer-verified-resolution-value/README.txt, flows/set-supported-service-column-email-channel/README.md, flows/set-supported-service-column-email-channel/README.txt, flows/update-currency-exchange-rates/README.md, flows/update-currency-exchange-rates/README.txt, flows/update-last-interaction-email/README.md, flows/update-last-interaction-email/README.txt, flows/update-last-interaction-note/README.md, flows/update-last-interaction-note/README.txt, flows/update-last-interaction-portal-comment/README.md, flows/update-last-interaction-portal-comment/README.txt, flows/veeam-contractrequest/README.md, flows/veeam-contractrequest/README.txt, flows/vendor-account-create-solution-provider-from-vendor/README.md, flows/vendor-account-create-solution-provider-from-vendor/README.txt, flows/vmware-contractrequest/README.md, flows/vmware-contractrequest/README.txt, flows/zremove-journeymanual-dcij-website-contact-form-submitted/README.md, flows/zremove-journeymanual-dcij-website-contact-form-submitted/README.txt
- plugins: plugins/README.md, plugins/README.txt, plugins/RevOps.EmailPlugins/README.md, plugins/RevOps.EmailPlugins/README.txt, plugins/RevOps.SolutionPlugins/README.md, plugins/RevOps.SolutionPlugins/README.txt, plugins/sherweb.plugin/README.md, plugins/sherweb.plugin/README.txt
- Power Pages: Power Pages/README.md, Power Pages/README.txt, Power Pages/Site/README.md, Power Pages/Site/README.txt, Power Pages/Site/basic-forms/README.md, Power Pages/Site/basic-forms/README.txt, Power Pages/Site/web-files/README.md, Power Pages/Site/web-files/README.txt, Power Pages/Site/web-templates/README.md, Power Pages/Site/web-templates/README.txt
- queues: queues/README.md, queues/README.txt, queues/-01fd31ba265e4d82a61829c93d5b4eca-1-/README.md, queues/-01fd31ba265e4d82a61829c93d5b4eca-1-/README.txt, queues/-06b3487241954cda8393d3c970544f13-1-/README.md, queues/-06b3487241954cda8393d3c970544f13-1-/README.txt, queues/-0b4b99ff67e845db99df046d028d32a4-1-/README.md, queues/-0b4b99ff67e845db99df046d028d32a4-1-/README.txt, queues/-0bacc33ebe844b85a72e05b86f8fed21-1-/README.md, queues/-0bacc33ebe844b85a72e05b86f8fed21-1-/README.txt, queues/-167b4f324df242ddbfa32d04ba9355a9-1-/README.md, queues/-167b4f324df242ddbfa32d04ba9355a9-1-/README.txt, queues/-1e7960d3570d4105be9e9698908e57bf-1-/README.md, queues/-1e7960d3570d4105be9e9698908e57bf-1-/README.txt, queues/-24ef7cf2b498f011b41c002248b081f9-1-/README.md, queues/-24ef7cf2b498f011b41c002248b081f9-1-/README.txt, queues/-26e5dd400d074b4d987e67b8386c963c-1-/README.md, queues/-26e5dd400d074b4d987e67b8386c963c-1-/README.txt, queues/-28a698ab538140259f9f748ab25bd150-1-/README.md, queues/-28a698ab538140259f9f748ab25bd150-1-/README.txt, queues/-3eb6ce5fe12f4c6bbe4cd34789e2a7ad-1-/README.md, queues/-3eb6ce5fe12f4c6bbe4cd34789e2a7ad-1-/README.txt, queues/-3ebcb28158e840d594e78dabd4dab93b-1-/README.md, queues/-3ebcb28158e840d594e78dabd4dab93b-1-/README.txt, queues/-4cfb7bca768542298b6586b9803c2c8f-1-/README.md, queues/-4cfb7bca768542298b6586b9803c2c8f-1-/README.txt, queues/-51ccbc28b7bd4a6b94eae81b1541083d-1-/README.md, queues/-51ccbc28b7bd4a6b94eae81b1541083d-1-/README.txt, queues/-5dd00fa390f2402e87017894c508a9a7-1-/README.md, queues/-5dd00fa390f2402e87017894c508a9a7-1-/README.txt, queues/-6f87ac140fcbf01185447ced8d3654cb-1-/README.md, queues/-6f87ac140fcbf01185447ced8d3654cb-1-/README.txt, queues/-712282464520f011998a002248b1d6cf-1-/README.md, queues/-712282464520f011998a002248b1d6cf-1-/README.txt, queues/-8edaadf90800f011bae36045bd605559-1-/README.md, queues/-8edaadf90800f011bae36045bd605559-1-/README.txt, queues/-94a034358e86490eb5bfe1e7bdfb6ea2-1-/README.md, queues/-94a034358e86490eb5bfe1e7bdfb6ea2-1-/README.txt, queues/-995a90413eb6431e8067bd2a72ec7c77-1-/README.md, queues/-995a90413eb6431e8067bd2a72ec7c77-1-/README.txt, queues/-9c942d2eb2dd4e38a7d621a3b1503ac2-1-/README.md, queues/-9c942d2eb2dd4e38a7d621a3b1503ac2-1-/README.txt, queues/-9ce42f69bd484a62a630963d8e50221c-1-/README.md, queues/-9ce42f69bd484a62a630963d8e50221c-1-/README.txt, queues/-aab5ac628320410a90cbc5a55f6b3b8b-1-/README.md, queues/-aab5ac628320410a90cbc5a55f6b3b8b-1-/README.txt, queues/-ade72ef964e04307aaee678565a4a16b-1-/README.md, queues/-ade72ef964e04307aaee678565a4a16b-1-/README.txt, queues/-advisors-isv-/README.md, queues/-advisors-isv-/README.txt, queues/-afa11375edd44be79c7efba89217c9d7-1-/README.md, queues/-afa11375edd44be79c7efba89217c9d7-1-/README.txt, queues/-b3415a98b91ff01199890022483dedd6-1-/README.md, queues/-b3415a98b91ff01199890022483dedd6-1-/README.txt, queues/-b4c89ad2f4caf01185447ced8d3654cb-1-/README.md, queues/-b4c89ad2f4caf01185447ced8d3654cb-1-/README.txt, queues/-ba-pod-/README.md, queues/-ba-pod-/README.txt, queues/-bizdev-/README.md, queues/-bizdev-/README.txt, queues/-c0c5d3a7e6b6456da40de5bb800a57c3-1-/README.md, queues/-c0c5d3a7e6b6456da40de5bb800a57c3-1-/README.txt, queues/-c2-/README.md, queues/-c2-/README.txt, queues/-canada-/README.md, queues/-canada-/README.txt, queues/-cb34a52deb33456b9015e320f1302ff3-1-/README.md, queues/-cb34a52deb33456b9015e320f1302ff3-1-/README.txt, queues/-ce1004038fca4d2da4d6d273fa8427f4-1-/README.md, queues/-ce1004038fca4d2da4d6d273fa8427f4-1-/README.txt, queues/-cfd2ff947e3a4383b78ba134ed93d386-1-/README.md, queues/-cfd2ff947e3a4383b78ba134ed93d386-1-/README.txt, queues/-cloud-infrastructure-services-/README.md, queues/-cloud-infrastructure-services-/README.txt, queues/-cloud-support-/README.md, queues/-cloud-support-/README.txt, queues/-cloudpbx-pod-/README.md, queues/-cloudpbx-pod-/README.txt, queues/-cst-/README.md, queues/-cst-/README.txt, queues/-d0505ed83703f011bae30022483cf35f-1-/README.md, queues/-d0505ed83703f011bae30022483cf35f-1-/README.txt, queues/-d36c9d9bdfd9467dabbcbdbd8ba4cd63-1-/README.md, queues/-d36c9d9bdfd9467dabbcbdbd8ba4cd63-1-/README.txt, queues/-d514df595ed3484b9d41572976dac638-1-/README.md, queues/-d514df595ed3484b9d41572976dac638-1-/README.txt, queues/-ddb58302677947668d9cd3a358d70d37-1-/README.md, queues/-ddb58302677947668d9cd3a358d70d37-1-/README.txt, queues/-development-/README.md, queues/-development-/README.txt, queues/-direct-/README.md, queues/-direct-/README.txt, queues/-f4e36f57cb5d4712a4da716563aff7c1-1-/README.md, queues/-f4e36f57cb5d4712a4da716563aff7c1-1-/README.txt, queues/-fb410c26d0804309a602d0d827a4fcec-1-/README.md, queues/-fb410c26d0804309a602d0d827a4fcec-1-/README.txt, queues/-finance-/README.md, queues/-finance-/README.txt, queues/-human-resources-/README.md, queues/-human-resources-/README.txt, queues/-level-3s-/README.md, queues/-level-3s-/README.txt, queues/-m365-hex-pod-/README.md, queues/-m365-hex-pod-/README.txt, queues/-marketing-/README.md, queues/-marketing-/README.txt, queues/-mwh-/README.md, queues/-mwh-/README.txt, queues/-mwh-cloud-/README.md, queues/-mwh-cloud-/README.txt, queues/-online-backup-/README.md, queues/-online-backup-/README.txt, queues/-operations-/README.md, queues/-operations-/README.txt, queues/-pod-chargers-/README.md, queues/-pod-chargers-/README.txt, queues/-products-/README.md, queues/-products-/README.txt, queues/-s-curit-/README.md, queues/-s-curit-/README.txt, queues/-sales-/README.md, queues/-sales-/README.txt, queues/-sbc-pod-/README.md, queues/-sbc-pod-/README.txt, queues/-sdrs-/README.md, queues/-sdrs-/README.txt, queues/-sherweb-/README.md, queues/-sherweb-/README.txt, queues/-sherweb-prod-/README.md, queues/-sherweb-prod-/README.txt, queues/-sherweb-uk-/README.md, queues/-sherweb-uk-/README.txt, queues/-sme-bdm-/README.md, queues/-sme-bdm-/README.txt, queues/-sw-assignaccount-/README.md, queues/-sw-assignaccount-/README.txt, queues/-sw-crmadministration-/README.md, queues/-sw-crmadministration-/README.txt, queues/-sw-export-/README.md, queues/-sw-export-/README.txt, queues/-sw-gdc-pa-/README.md, queues/-sw-gdc-pa-/README.txt, queues/-sw-marketingcreative-/README.md, queues/-sw-marketingcreative-/README.txt, queues/-sw-marketingevents-/README.md, queues/-sw-marketingevents-/README.txt, queues/-sw-marketinggtm-/README.md, queues/-sw-marketinggtm-/README.txt, queues/-sw-partnersalesmanager-/README.md, queues/-sw-partnersalesmanager-/README.txt, queues/-sw-presales-/README.md, queues/-sw-presales-/README.txt, queues/-sw-presalesmanager-/README.md, queues/-sw-presalesmanager-/README.txt, queues/-sw-productspecialist-/README.md, queues/-sw-productspecialist-/README.txt, queues/-sw-rc-bd-/README.md, queues/-sw-rc-bd-/README.txt, queues/-sw-rc-p-/README.md, queues/-sw-rc-p-/README.txt, queues/-sw-salesoperations-/README.md, queues/-sw-salesoperations-/README.txt, queues/-team-executives-/README.md, queues/-team-executives-/README.txt, queues/-team-marketing-/README.md, queues/-team-marketing-/README.txt, queues/-team-product-/README.md, queues/-team-product-/README.txt, queues/-team-sales-longueuil-/README.md, queues/-team-sales-longueuil-/README.txt, queues/-team-voip-/README.md, queues/-team-voip-/README.txt, queues/-technical-support-/README.md, queues/-technical-support-/README.txt, queues/-us-/README.md, queues/-us-/README.txt, queues/-z-old-pod-council-b-/README.md, queues/-z-old-pod-council-b-/README.txt, queues/-z-old-pod-council-e-/README.md, queues/-z-old-pod-council-e-/README.txt, queues/-z-old-pod-council-n-/README.md, queues/-z-old-pod-council-n-/README.txt, queues/-z-old-pod-council-o-/README.md, queues/-z-old-pod-council-o-/README.txt, queues/-z-old-pod-council-s-/README.md, queues/-z-old-pod-council-s-/README.txt, queues/-z-old-pod-council-w-/README.md, queues/-z-old-pod-council-w-/README.txt, queues/-z-old-sw-gdc-ep-/README.md, queues/-z-old-sw-gdc-ep-/README.txt
- README.md: README.md
- README.txt: README.txt
- RUNS: RUNS/README.md, RUNS/README.txt
- security-roles: security-roles/README.md, security-roles/README.txt, security-roles/csr-manager/README.md, security-roles/csr-manager/README.txt, security-roles/customer-service-representative/README.md, security-roles/customer-service-representative/README.txt, security-roles/marketing-services-user-extensible-role/README.md, security-roles/marketing-services-user-extensible-role/README.txt, security-roles/sherweb-6sense-integration/README.md, security-roles/sherweb-6sense-integration/README.txt, security-roles/sherweb-audience-import/README.md, security-roles/sherweb-audience-import/README.txt, security-roles/sherweb-business-development-rep/README.md, security-roles/sherweb-business-development-rep/README.txt, security-roles/sherweb-cs-agent/README.md, security-roles/sherweb-cs-agent/README.txt, security-roles/sherweb-cs-enablement/README.md, security-roles/sherweb-cs-enablement/README.txt, security-roles/sherweb-cs-kb-editor/README.md, security-roles/sherweb-cs-kb-editor/README.txt, security-roles/sherweb-cs-manager/README.md, security-roles/sherweb-cs-manager/README.txt, security-roles/sherweb-cs-technical-onboarding/README.md, security-roles/sherweb-cs-technical-onboarding/README.txt, security-roles/sherweb-cs-technical-onboarding-l3/README.md, security-roles/sherweb-cs-technical-onboarding-l3/README.txt, security-roles/sherweb-event-administrator/README.md, security-roles/sherweb-event-administrator/README.txt, security-roles/sherweb-marketing/README.md, security-roles/sherweb-marketing/README.txt, security-roles/sherweb-omnichannel-queue-manager/README.md, security-roles/sherweb-omnichannel-queue-manager/README.txt, security-roles/sherweb-pre-sales/README.md, security-roles/sherweb-pre-sales/README.txt, security-roles/sherweb-products/README.md, security-roles/sherweb-products/README.txt, security-roles/sherweb-project/README.md, security-roles/sherweb-project/README.txt, security-roles/sherweb-sales-admin/README.md, security-roles/sherweb-sales-admin/README.txt, security-roles/sherweb-sales-manager/README.md, security-roles/sherweb-sales-manager/README.txt, security-roles/sherweb-sales-person/README.md, security-roles/sherweb-sales-person/README.txt, security-roles/sherweb-salesops/README.md, security-roles/sherweb-salesops/README.txt, security-roles/system-customizer-admin-add-on/README.md, security-roles/system-customizer-admin-add-on/README.txt
- slas: slas/README.md, slas/README.txt, slas/6-tier-slo-for-cases/README.md, slas/6-tier-slo-for-cases/README.txt, slas/case/README.md, slas/case/README.txt, slas/sla-for-cases/README.md, slas/sla-for-cases/README.txt
- tables: tables/README.md, tables/README.txt, tables/account/README.md, tables/account/README.txt, tables/activitypointer/README.md, tables/activitypointer/README.txt, tables/annotation/README.md, tables/annotation/README.txt, tables/appointment/README.md, tables/appointment/README.txt, tables/campaign/README.md, tables/campaign/README.txt, tables/category/README.md, tables/category/README.txt, tables/competitor/README.md, tables/competitor/README.txt, tables/contact/README.md, tables/contact/README.txt, tables/email/README.md, tables/email/README.txt, tables/goal/README.md, tables/goal/README.txt, tables/incident/README.md, tables/incident/README.txt, tables/incidentresolution/README.md, tables/incidentresolution/README.txt, tables/knowledgearticle/README.md, tables/knowledgearticle/README.txt, tables/lead/README.md, tables/lead/README.txt, tables/list/README.md, tables/list/README.txt, tables/msdynmkt_brandsender/README.md, tables/msdynmkt_brandsender/README.txt, tables/msdynmkt_email/README.md, tables/msdynmkt_email/README.txt, tables/msdynmkt_eventmetadata/README.md, tables/msdynmkt_eventmetadata/README.txt, tables/msdynmkt_fragment/README.md, tables/msdynmkt_fragment/README.txt, tables/msdynmkt_journey/README.md, tables/msdynmkt_journey/README.txt, tables/msdynmkt_marketingform/README.md, tables/msdynmkt_marketingform/README.txt, tables/msdynmkt_marketingformsubmission/README.md, tables/msdynmkt_marketingformsubmission/README.txt, tables/msdynmkt_segment/README.md, tables/msdynmkt_segment/README.txt, tables/msdyn_conversationsuggestionrequestpayload/README.md, tables/msdyn_conversationsuggestionrequestpayload/README.txt, tables/msdyn_customerfeedbacksurveyresponse/README.md, tables/msdyn_customerfeedbacksurveyresponse/README.txt, tables/msdyn_operatinghour/README.md, tables/msdyn_operatinghour/README.txt, tables/msdyn_project/README.md, tables/msdyn_project/README.txt, tables/msevtmgt_checkin/README.md, tables/msevtmgt_checkin/README.txt, tables/msevtmgt_event/README.md, tables/msevtmgt_event/README.txt, tables/msevtmgt_eventregistration/README.md, tables/msevtmgt_eventregistration/README.txt, tables/msevtmgt_session/README.md, tables/msevtmgt_session/README.txt, tables/msevtmgt_sessionregistration/README.md, tables/msevtmgt_sessionregistration/README.txt, tables/msfp_surveyresponse/README.md, tables/msfp_surveyresponse/README.txt, tables/opportunity/README.md, tables/opportunity/README.txt, tables/phonecall/README.md, tables/phonecall/README.txt, tables/processsession/README.md, tables/processsession/README.txt, tables/product/README.md, tables/product/README.txt, tables/queue/README.md, tables/queue/README.txt, tables/revops_accountpotentialtechstack/README.md, tables/revops_accountpotentialtechstack/README.txt, tables/revops_accountproductsummary/README.md, tables/revops_accountproductsummary/README.txt, tables/revops_accountreassignment/README.md, tables/revops_accountreassignment/README.txt, tables/revops_accountsoftwaretool/README.md, tables/revops_accountsoftwaretool/README.txt, tables/revops_accountsolutionsummary/README.md, tables/revops_accountsolutionsummary/README.txt, tables/revops_audienceimport/README.md, tables/revops_audienceimport/README.txt, tables/revops_businessreview/README.md, tables/revops_businessreview/README.txt, tables/revops_cadencecall/README.md, tables/revops_cadencecall/README.txt, tables/revops_changelog/README.md, tables/revops_changelog/README.txt, tables/revops_churn/README.md, tables/revops_churn/README.txt, tables/revops_competitortransferid/README.md, tables/revops_competitortransferid/README.txt, tables/revops_country/README.md, tables/revops_country/README.txt, tables/revops_cumulusaccount/README.md, tables/revops_cumulusaccount/README.txt, tables/revops_cumulusorganization/README.md, tables/revops_cumulusorganization/README.txt, tables/revops_cumulussignup/README.md, tables/revops_cumulussignup/README.txt, tables/revops_cumulususer/README.md, tables/revops_cumulususer/README.txt, tables/revops_demo/README.md, tables/revops_demo/README.txt, tables/revops_domain/README.md, tables/revops_domain/README.txt, tables/revops_gicsmapping/README.md, tables/revops_gicsmapping/README.txt, tables/revops_inpersonmeeting/README.md, tables/revops_inpersonmeeting/README.txt, tables/revops_lateralmove/README.md, tables/revops_lateralmove/README.txt, tables/revops_mwhaccount/README.md, tables/revops_mwhaccount/README.txt, tables/revops_onboardingcall/README.md, tables/revops_onboardingcall/README.txt, tables/revops_opportunitiessnapshots/README.md, tables/revops_opportunitiessnapshots/README.txt, tables/revops_opportunitysolution/README.md, tables/revops_opportunitysolution/README.txt, tables/revops_partnerinvestment/README.md, tables/revops_partnerinvestment/README.txt, tables/revops_platformsettings/README.md, tables/revops_platformsettings/README.txt, tables/revops_practice/README.md, tables/revops_practice/README.txt, tables/revops_pricingrequest/README.md, tables/revops_pricingrequest/README.txt, tables/revops_productsummary/README.md, tables/revops_productsummary/README.txt, tables/revops_psaintegration/README.md, tables/revops_psaintegration/README.txt, tables/revops_relatedsolutionssnapshots/README.md, tables/revops_relatedsolutionssnapshots/README.txt, tables/revops_service/README.md, tables/revops_service/README.txt, tables/revops_sherwebopportunitybpf/README.md, tables/revops_sherwebopportunitybpf/README.txt, tables/revops_sherwebsalesbpf/README.md, tables/revops_sherwebsalesbpf/README.txt, tables/revops_smeengagement/README.md, tables/revops_smeengagement/README.txt, tables/revops_solution/README.md, tables/revops_solution/README.txt, tables/revops_solutioncategory/README.md, tables/revops_solutioncategory/README.txt, tables/revops_solutiondetails/README.md, tables/revops_solutiondetails/README.txt, tables/revops_solutionprovider/README.md, tables/revops_solutionprovider/README.txt, tables/revops_solutionsummary/README.md, tables/revops_solutionsummary/README.txt, tables/revops_stateorprovince/README.md, tables/revops_stateorprovince/README.txt, tables/revops_subsolution/README.md, tables/revops_subsolution/README.txt, tables/revops_techstacksnapshots/README.md, tables/revops_techstacksnapshots/README.txt, tables/revops_territoryregion/README.md, tables/revops_territoryregion/README.txt, tables/revops_transfer/README.md, tables/revops_transfer/README.txt, tables/revops_utmlink/README.md, tables/revops_utmlink/README.txt, tables/syncerror/README.md, tables/syncerror/README.txt, tables/systemuser/README.md, tables/systemuser/README.txt, tables/task/README.md, tables/task/README.txt, tables/team/README.md, tables/team/README.txt, tables/template/README.md, tables/template/README.txt, tables/territory/README.md, tables/territory/README.txt, tables/transactioncurrency/README.md, tables/transactioncurrency/README.txt
- web-resources: web-resources/README.md, web-resources/README.txt, web-resources/crdd4-hide-other-accountprofile/README.md, web-resources/crdd4-hide-other-accountprofile/README.txt, web-resources/crdd4-pricingrequestfieldvisibility/README.md, web-resources/crdd4-pricingrequestfieldvisibility/README.txt, web-resources/crdd4-totalestrevenue-rollup/README.md, web-resources/crdd4-totalestrevenue-rollup/README.txt, web-resources/crdd4-utmlink/README.md, web-resources/crdd4-utmlink/README.txt, web-resources/crfdb-hidedraftactivities/README.md, web-resources/crfdb-hidedraftactivities/README.txt, web-resources/revops-accounttieroverridesecurity/README.md, web-resources/revops-accounttieroverridesecurity/README.txt, web-resources/revops-churn/README.md, web-resources/revops-churn/README.txt, web-resources/revops-email-case-subject.js/README.md, web-resources/revops-email-case-subject.js/README.txt, web-resources/revops-emaildefaultsenderscrubber/README.md, web-resources/revops-emaildefaultsenderscrubber/README.txt, web-resources/revops-emailhidefromfield/README.md, web-resources/revops-emailhidefromfield/README.txt, web-resources/revops-fillaccountandcumulusaccountprojectform/README.md, web-resources/revops-fillaccountandcumulusaccountprojectform/README.txt, web-resources/revops-filtercumulusorgs/README.md, web-resources/revops-filtercumulusorgs/README.txt, web-resources/revops-filterfromfield/README.md, web-resources/revops-filterfromfield/README.txt, web-resources/revops-filtergainingprg/README.md, web-resources/revops-filtergainingprg/README.txt, web-resources/revops-filterlosingorg/README.md, web-resources/revops-filterlosingorg/README.txt, web-resources/revops-filterpartylisttocontacts/README.md, web-resources/revops-filterpartylisttocontacts/README.txt, web-resources/revops-openp2ptransfer/README.md, web-resources/revops-openp2ptransfer/README.txt, web-resources/revops-p2p-competitor-filter/README.md, web-resources/revops-p2p-competitor-filter/README.txt, web-resources/revops-p2ptransfercreate/README.md, web-resources/revops-p2ptransfercreate/README.txt, web-resources/revops-p2ptransferemail/README.md, web-resources/revops-p2ptransferemail/README.txt, web-resources/revops-probabilityoverride/README.md, web-resources/revops-probabilityoverride/README.txt, web-resources/revops-resolvecasesbutton/README.md, web-resources/revops-resolvecasesbutton/README.txt, web-resources/revops-servicestomigrate/README.md, web-resources/revops-servicestomigrate/README.txt, web-resources/revops-setcumulusaccount/README.md, web-resources/revops-setcumulusaccount/README.txt, web-resources/revops-solutionfilter/README.md, web-resources/revops-solutionfilter/README.txt, web-resources/revops-togglemwhtab/README.md, web-resources/revops-togglemwhtab/README.txt, web-resources/revops-triggertransfercase/README.md, web-resources/revops-triggertransfercase/README.txt
- workstreams: workstreams/README.md, workstreams/README.txt, workstreams/billing-outbound/README.md, workstreams/billing-outbound/README.txt, workstreams/billing-voice-english/README.md, workstreams/billing-voice-english/README.txt, workstreams/billing-voice-french/README.md, workstreams/billing-voice-french/README.txt, workstreams/c2-overflow/README.md, workstreams/c2-overflow/README.txt, workstreams/default-group-voicemail-workstream/README.md, workstreams/default-group-voicemail-workstream/README.txt, workstreams/default-individual-voicemail-workstream/README.md, workstreams/default-individual-voicemail-workstream/README.txt, workstreams/live-chat-workstream/README.md, workstreams/live-chat-workstream/README.txt, workstreams/microsoft-teams-workstream/README.md, workstreams/microsoft-teams-workstream/README.txt, workstreams/mwh-cloud/README.md, workstreams/mwh-cloud/README.txt, workstreams/mwh-csp/README.md, workstreams/mwh-csp/README.txt, workstreams/mwh-csp-outbound/README.md, workstreams/mwh-csp-outbound/README.txt, workstreams/mwh-main-ivr/README.md, workstreams/mwh-main-ivr/README.txt, workstreams/mwh-security/README.md, workstreams/mwh-security/README.txt, workstreams/phone-call-workstream/README.md, workstreams/phone-call-workstream/README.txt, workstreams/redirect-to-main-ivr/README.md, workstreams/redirect-to-main-ivr/README.txt, workstreams/sales-outbound/README.md, workstreams/sales-outbound/README.txt, workstreams/sales-voice-english/README.md, workstreams/sales-voice-english/README.txt, workstreams/sales-voice-french/README.md, workstreams/sales-voice-french/README.txt, workstreams/support-and-sales-chat-eng/README.md, workstreams/support-and-sales-chat-eng/README.txt, workstreams/support-and-sales-chat-fr/README.md, workstreams/support-and-sales-chat-fr/README.txt, workstreams/support-outbound/README.md, workstreams/support-outbound/README.txt, workstreams/support-outbound-2/README.md, workstreams/support-outbound-2/README.txt, workstreams/support-outbound-3/README.md, workstreams/support-outbound-3/README.txt, workstreams/support-voice-eng/README.md, workstreams/support-voice-eng/README.txt, workstreams/support-voice-fr/README.md, workstreams/support-voice-fr/README.txt, workstreams/uk-to-m365/README.md, workstreams/uk-to-m365/README.txt, workstreams/voicemails/README.md, workstreams/voicemails/README.txt
- Missing folder-level READMEs: README.md, README.txt

## Deep Nesting Hotspots (depth >= 4)
- app-modules/channel-integration-framework/_facts/app.yaml
- app-modules/channel-integration-framework/_facts/sitemap.yaml
- app-modules/copilot-service-admin-center/_facts/app.yaml
- app-modules/copilot-service-admin-center/_facts/sitemap.yaml
- app-modules/customer-insights-journeys/_facts/app.yaml
- app-modules/customer-insights-journeys/_facts/sitemap.yaml
- app-modules/customer-service-hub/_facts/app.yaml
- app-modules/customer-service-hub/_facts/sitemap.yaml
- app-modules/customer-service-team-member/_facts/app.yaml
- app-modules/customer-service-team-member/_facts/sitemap.yaml
- app-modules/customer-service-workspace/_facts/app.yaml
- app-modules/customer-service-workspace/_facts/sitemap.yaml
- app-modules/dataverse-accelerator-app/_facts/app.yaml
- app-modules/dataverse-accelerator-app/_facts/sitemap.yaml
- app-modules/dynamics-365-app-for-outlook/_facts/app.yaml
- app-modules/dynamics-365-app-for-outlook/_facts/sitemap.yaml
- app-modules/omnichannel-admin-center/_facts/app.yaml
- app-modules/omnichannel-admin-center/_facts/sitemap.yaml
- app-modules/omnichannel-administration/_facts/app.yaml
- app-modules/omnichannel-administration/_facts/sitemap.yaml
- app-modules/omnichannel-for-customer-service/_facts/app.yaml
- app-modules/omnichannel-for-customer-service/_facts/sitemap.yaml
- app-modules/portal-management/_facts/app.yaml
- app-modules/portal-management/_facts/sitemap.yaml
- app-modules/power-pages-management/_facts/app.yaml
- app-modules/power-pages-management/_facts/sitemap.yaml
- app-modules/power-platform-environment-settings/_facts/app.yaml
- app-modules/power-platform-environment-settings/_facts/sitemap.yaml
- app-modules/project/_facts/app.yaml
- app-modules/project/_facts/sitemap.yaml
- app-modules/project-operations/_facts/app.yaml
- app-modules/project-operations/_facts/sitemap.yaml
- app-modules/project-operations-team-member/_facts/app.yaml
- app-modules/project-operations-team-member/_facts/sitemap.yaml
- app-modules/resource-scheduling/_facts/app.yaml
- app-modules/resource-scheduling/_facts/sitemap.yaml
- app-modules/sales-hub/_facts/app.yaml
- app-modules/sales-hub/_facts/sitemap.yaml
- app-modules/sales-team-member/_facts/app.yaml
- app-modules/sales-team-member/_facts/sitemap.yaml
- app-modules/solution-health-hub/_facts/app.yaml
- app-modules/solution-health-hub/_facts/sitemap.yaml
- app-modules/teams-virtual-events/_facts/app.yaml
- app-modules/teams-virtual-events/_facts/sitemap.yaml
- business-process-flows/after-meeting/_facts/bpf.yaml
- business-process-flows/change-password-for-portals-contact/_facts/bpf.yaml
- business-process-flows/eventmainbusinessprocessflow/_facts/bpf.yaml
- business-process-flows/eventmainbusinessprocessflow/_facts/stages.yaml
- business-process-flows/expired-process/_facts/bpf.yaml
- business-process-flows/expired-process/_facts/stages.yaml
- business-process-flows/follow-up-with-opportunity/_facts/bpf.yaml
- business-process-flows/iot-alert-to-case-process/_facts/bpf.yaml
- business-process-flows/iot-alert-to-case-process/_facts/stages.yaml
- business-process-flows/lead-to-opportunity-marketing-sales-process/_facts/bpf.yaml
- business-process-flows/lead-to-opportunity-marketing-sales-process/_facts/stages.yaml
- business-process-flows/new-process/_facts/bpf.yaml
- business-process-flows/new-process/_facts/stages.yaml
- business-process-flows/phone-to-case-process/_facts/bpf.yaml
- business-process-flows/phone-to-case-process/_facts/stages.yaml
- business-process-flows/project-service-invoice-process/_facts/bpf.yaml
- business-process-flows/project-service-invoice-process/_facts/stages.yaml
- business-process-flows/project-service-project-stages/_facts/bpf.yaml
- business-process-flows/project-service-project-stages/_facts/stages.yaml
- business-process-flows/project-service-subcontract-stages/_facts/bpf.yaml
- business-process-flows/project-service-subcontract-stages/_facts/stages.yaml
- business-process-flows/project-service-time-entry-edit/_facts/bpf.yaml
- business-process-flows/project-service-time-entry-row-edit/_facts/bpf.yaml
- business-process-flows/project-service-vendor-invoice-business-process/_facts/bpf.yaml
- business-process-flows/project-service-vendor-invoice-business-process/_facts/stages.yaml
- business-process-flows/sherweb-opportunity-bpf/_facts/bpf.yaml
- business-process-flows/sherweb-opportunity-bpf/_facts/stages.yaml
- business-process-flows/sherweb-sales-bpf/_facts/bpf.yaml
- business-process-flows/sherweb-sales-bpf/_facts/stages.yaml
- business-process-flows/translation-process/_facts/bpf.yaml
- business-process-flows/translation-process/_facts/stages.yaml
- business-process-flows/update-contact/_facts/bpf.yaml
- flows/-activity-email-stamp-sql-date/_facts/flow.yaml
- flows/-activity-phone-stamp-sql-date/_facts/flow.yaml
- flows/-activity-tasks-stamp-sql-date/_facts/flow.yaml
- flows/-audience-import-upsert-contact-and-associate/_facts/flow.yaml
- flows/-calendly-create-and-update-a-lead-when-a-calendly-event-is-created/_facts/flow.yaml
- flows/-events-scanned-import-connection-to-event-and-more/_facts/flow.yaml
- flows/-form-submission-utm-shenanigans-enrichment-consent-processing/_facts/flow.yaml
- flows/-global-pit-tier/_facts/flow.yaml
- flows/-journey-custom-trigger-for-lead/_facts/flow.yaml
- flows/-journey-dcij-website-contact-form-submitted/_facts/flow.yaml
- flows/-lead-check-parent-account-relationship-for-trade-show-lead/_facts/flow.yaml
- flows/-lead-disqualify-honeypot-field-contains-data/_facts/flow.yaml
- flows/-lead-mql-date/_facts/flow.yaml
- flows/-lead-notify-user-when-assigned/_facts/flow.yaml
- flows/-lead-uk-cookie-fallback-territory/_facts/flow.yaml
- flows/-mwh-omit-accounts-and-contacts-from-consent/_facts/flow.yaml
- flows/-phone-call-add-notes-to-description/_facts/flow.yaml
- flows/account-backfill-channel-relationship/_facts/flow.yaml
- flows/account-created-in-cumulus/_facts/flow.yaml
- flows/account-ownership-change-notification/_facts/flow.yaml
- flows/account-product-summary-copy-account-key/_facts/flow.yaml
- flows/account-set-cumulus-account-created-on-opps/_facts/flow.yaml
- flows/account-set-territory-on-account/_facts/flow.yaml
- flows/account-solutions-summary-copy-account-key/_facts/flow.yaml
- flows/accounts-manual-fix-generic-domains-format/_facts/flow.yaml
- flows/assign-sme-engagement-to-object-owner/_facts/flow.yaml
- flows/attach-file-to-asana/_facts/flow.yaml
- flows/bulk-resolve-cases/_facts/flow.yaml
- flows/case-queue-update-update-queue-item/_facts/flow.yaml
- flows/case-resolution-survey/_facts/flow.yaml
- flows/case-send-notification-to-owner-when-a-customer-replies/_facts/flow.yaml
- flows/case-to-nice/_facts/flow.yaml
- flows/commitment-agreement-form/_facts/flow.yaml
- flows/competitor-create-current-provider-when-a-competitor-is-created/_facts/flow.yaml
- flows/contact-extract-domain-from-email/_facts/flow.yaml
- flows/contact-extract-domain-from-email-selecting-rows-/_facts/flow.yaml
- flows/contact-resolve-account-by-domain/_facts/flow.yaml
- flows/contact-resolve-account-by-domain-select-row-/_facts/flow.yaml
- flows/conversations-to-nice/_facts/flow.yaml
- flows/create-case-from-migration-request/_facts/flow.yaml
- flows/create-case-from-zabbix-alert/_facts/flow.yaml
- flows/create-work-item-approve-enable-mailbox/_facts/flow.yaml
- flows/cs-case-create-for-manual-account-creation-for-uk-partners/_facts/flow.yaml
- flows/cs-notify-manager-of-customer-escalation/_facts/flow.yaml
- flows/cumulus-account-manager-team-created-or-updated/_facts/flow.yaml
- flows/cumulus-account-manager-update/_facts/flow.yaml
- flows/cumulus-account-manager-user-created-or-updated/_facts/flow.yaml
- flows/cumulus-user-created/_facts/flow.yaml
- flows/daily-tier-update-per-mrr-/_facts/flow.yaml
- flows/day-0-cumulus-ces/_facts/flow.yaml
- flows/enrich-account-manual/_facts/flow.yaml
- flows/enrich-account-oncreate/_facts/flow.yaml
- flows/enrich-account-scheduled/_facts/flow.yaml
- flows/enrich-contact-manual/_facts/flow.yaml
- flows/enrich-contact-oncreate/_facts/flow.yaml
- flows/enrich-contact-scheduled/_facts/flow.yaml
- flows/enrich-lead-oncreate/_facts/flow.yaml
- flows/enrich-lead-scheduled/_facts/flow.yaml
- flows/fill-parent-account-of-cumulus-account/_facts/flow.yaml
- flows/fix-accounts-without-name/_facts/flow.yaml
- flows/fix-primary-contact-on-account/_facts/flow.yaml
- flows/gtw-get-check-ins/_facts/flow.yaml
- flows/gtw-registrant-added/_facts/flow.yaml
- flows/gtw-webinar-is-created/_facts/flow.yaml
- flows/incoming-email-set-customer-responded/_facts/flow.yaml
- flows/incoming-portal-comment-set-customer-responded/_facts/flow.yaml
- flows/incomplete-cart/_facts/flow.yaml
- flows/iso-3166-cumulus-account-to-account-manual/_facts/flow.yaml
- flows/iso-3166-cumulus-account-to-account-scheduled/_facts/flow.yaml
- flows/lead-extract-domain-from-email/_facts/flow.yaml
- flows/lead-resolve-account-by-domain/_facts/flow.yaml
- flows/lead-resolve-contact-by-email/_facts/flow.yaml
- flows/lead-set-territory-on-lead/_facts/flow.yaml
- flows/link-cumulus-accounts-to-parent-accounts/_facts/flow.yaml
- flows/link-cumulus-user-contact-to-account/_facts/flow.yaml
- flows/link-cumulus-users-to-contact/_facts/flow.yaml
- flows/marketing-close-asset-from-campaign/_facts/flow.yaml
- flows/marketing-report-inactive-campaign-owner/_facts/flow.yaml
- flows/marketing-review-proposed-end-date/_facts/flow.yaml
- flows/opportunity-create-opportunities-from-account-potential/_facts/flow.yaml
- flows/opportunity-set-current-bpf-stage-sherweb-opp-bpf/_facts/flow.yaml
- flows/opportunity-set-current-bpf-stage-sherweb-sales-bpf/_facts/flow.yaml
- flows/opportunity-solution-create-solution-summary/_facts/flow.yaml
- flows/opportunity-update-probability-when-won/_facts/flow.yaml
- flows/opportunity-update-solution-summary/_facts/flow.yaml
- flows/organization-created-or-deleted-in-cumulus/_facts/flow.yaml
- flows/p2p-automation/_facts/flow.yaml
- flows/p2p-transfer-notifications/_facts/flow.yaml
- flows/p2p-transfer-population-from-case/_facts/flow.yaml
- flows/queue-item-ownership-change-based-on-case-ownership/_facts/flow.yaml
- flows/queue-item-release-set-case-owner/_facts/flow.yaml
- flows/resolvecase/_facts/flow.yaml
- flows/revops-change-log/_facts/flow.yaml
- flows/select-orgs-from-cumulus-where-clientuniquename/_facts/flow.yaml
- flows/send-p2p-transfer/_facts/flow.yaml
- flows/set-case-lookup-value-on-customer-feedback-survey-response/_facts/flow.yaml
- flows/set-customer-verified-resolution-value/_facts/flow.yaml
- flows/set-supported-service-column-email-channel/_facts/flow.yaml
- flows/update-currency-exchange-rates/_facts/flow.yaml
- flows/update-last-interaction-email/_facts/flow.yaml
- flows/update-last-interaction-note/_facts/flow.yaml
- flows/update-last-interaction-portal-comment/_facts/flow.yaml
- flows/veeam-contractrequest/_facts/flow.yaml
- flows/vendor-account-create-solution-provider-from-vendor/_facts/flow.yaml
- flows/vmware-contractrequest/_facts/flow.yaml
- flows/zremove-journeymanual-dcij-website-contact-form-submitted/_facts/flow.yaml
- plugins/RevOps.EmailPlugins/_facts/assembly.yaml
- plugins/RevOps.EmailPlugins/_facts/plugin-types.yaml
- plugins/RevOps.SolutionPlugins/_facts/assembly.yaml
- plugins/RevOps.SolutionPlugins/_facts/plugin-types.yaml
- plugins/sherweb.plugin/_facts/assembly.yaml
- plugins/sherweb.plugin/_facts/plugin-types.yaml
- Power Pages/Site/advanced-forms/advanced-forms.md
- Power Pages/Site/advanced-forms/multistep-case-creation.md
- Power Pages/Site/advanced-forms/p2p-transfer.md
- Power Pages/Site/basic-forms/basic-forms.md
- Power Pages/Site/basic-forms/case---create-p2p-from-portal.md
- Power Pages/Site/basic-forms/create-case---complain-about-a-case.md
- Power Pages/Site/basic-forms/create-case---cs.md
- Power Pages/Site/basic-forms/create-case---escalate-a-case.md
- Power Pages/Site/basic-forms/create-case---license-adjustment.md
- Power Pages/Site/basic-forms/create-case---migration-request.md
- Power Pages/Site/basic-forms/create-case---support.md
- Power Pages/Site/basic-forms/csp-godaddy-transfer.md
- ...and 745 more

## Generated vs Hand-Authored Patterns
- Likely generated: RUNS (run outputs), _registry (assets/solutions), _graph (dependency index/graph).
- No highly repeated templated blocks detected at threshold >=10.

## Content Format & Chunk Readiness (Samples)
### tables
- Sample count: 3
- Heading counts (samples): h1=3, h2=0, h3=0
- Avg section length (words): 36.1
- Long paragraphs (>=200 words): 0
- Code blocks (samples): 0
- Weak-heading large files (samples): 0

### plugins
- Sample count: 3
- Heading counts (samples): h1=3, h2=0, h3=0
- Avg section length (words): 34.3
- Long paragraphs (>=200 words): 0
- Code blocks (samples): 0
- Weak-heading large files (samples): 0

### flows
- Sample count: 3
- Heading counts (samples): h1=3, h2=0, h3=0
- Avg section length (words): 37.9
- Long paragraphs (>=200 words): 0
- Code blocks (samples): 0
- Weak-heading large files (samples): 0

### workstreams
- Sample count: 3
- Heading counts (samples): h1=3, h2=0, h3=0
- Avg section length (words): 35
- Long paragraphs (>=200 words): 0
- Code blocks (samples): 0
- Weak-heading large files (samples): 0

### queues
- Sample count: 3
- Heading counts (samples): h1=3, h2=0, h3=0
- Avg section length (words): 32.1
- Long paragraphs (>=200 words): 0
- Code blocks (samples): 0
- Weak-heading large files (samples): 0

### slas
- Sample count: 3
- Heading counts (samples): h1=3, h2=0, h3=0
- Avg section length (words): 65.5
- Long paragraphs (>=200 words): 1
- Code blocks (samples): 0
- Weak-heading large files (samples): 0

### security-roles
- Sample count: 3
- Heading counts (samples): h1=3, h2=0, h3=0
- Avg section length (words): 33
- Long paragraphs (>=200 words): 0
- Code blocks (samples): 0
- Weak-heading large files (samples): 0

### environment-variables
- Sample count: 1
- Heading counts (samples): h1=1, h2=0, h3=0
- Avg section length (words): 56.3
- Long paragraphs (>=200 words): 0
- Code blocks (samples): 0
- Weak-heading large files (samples): 0

### connection-references
- Sample count: 1
- Heading counts (samples): h1=1, h2=0, h3=0
- Avg section length (words): 56.6
- Long paragraphs (>=200 words): 0
- Code blocks (samples): 0
- Weak-heading large files (samples): 0

### Power Pages
- Sample count: 3
- Heading counts (samples): h1=3, h2=0, h3=0
- Avg section length (words): 36.2
- Long paragraphs (>=200 words): 0
- Code blocks (samples): 6
- Weak-heading large files (samples): 1

### web-resources
- Sample count: 3
- Heading counts (samples): h1=3, h2=0, h3=0
- Avg section length (words): 34.2
- Long paragraphs (>=200 words): 0
- Code blocks (samples): 0
- Weak-heading large files (samples): 0


## Metadata & Cross-Linking
- YAML front matter detected in a minority of markdown files (see inventory JSON for per-file flag).
- Relative markdown links detected; cross-linking density varies by folder.
- Top referenced identifiers (best-effort):
  - b: u
  - 94: 
  - r: e
  - 21: 
  - r: e
  - 21: 
  - a: d
  - 16: 
  - r: e
  - 15: 
  - r: e
  - 14: 
  - r: e
  - 13: 
  - a: d
  - 13: 
  - r: e
  - 11: 
  - r: e
  - 11: 
  - r: e
  - 11: 
  - r: e
  - 11: 
  - r: e
  - 10: 
  - m: s
  - 10: 
  - r: e
  - 10: 
  - r: e
  - 10: 
  - m: s
  - 10: 
  - m: s
  - 9: 
  - r: e
  - 9: 
  - m: s
  - 9: 
  - r: e
  - 9: 
  - m: s
  - 9: 
  - m: s
  - 9: 
  - m: s
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 
  - m: s
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 
  - m: s
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 
  - m: s
  - 9: 
  - r: e
  - 9: 
  - m: s
  - 9: 
  - m: s
  - 9: 
  - r: e
  - 9: 
  - m: s
  - 9: 
  - r: e
  - 9: 
  - m: s
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 
  - r: e
  - 9: 

## Relationship Coverage (mentions of depends_on / used_by / triggers / outputs)
- tables: 11 of 93 files mention relationship terms (ratio 0.12).
- plugins: 1 of 4 files mention relationship terms (ratio 0.25).
- flows: 21 of 107 files mention relationship terms (ratio 0.2).
- workstreams: 1 of 28 files mention relationship terms (ratio 0.04).

## Azure AI Search / Blob Readiness Scorecard
| Folder | Structure | Completeness | Cross-linking | Metadata | Chunk readiness | Noise |
|---|---:|---:|---:|---:|---:|---:|
| tables | 0 | 0 | 0 | 0 | 5 | 5 |
| plugins | 0 | 0 | 4 | 0 | 5 | 1 |
| flows | 0 | 0 | 0 | 0 | 5 | 0 |
| workstreams | 0 | 0 | 1 | 0 | 5 | 0 |
| queues | 0 | 5 | 0 | 0 | 5 | 5 |
| slas | 0 | 4 | 4 | 0 | 5 | 1 |
| security-roles | 0 | 0 | 1 | 0 | 5 | 0 |
| environment-variables | 0 | 0 | 5 | 0 | 5 | 5 |
| connection-references | 0 | 0 | 5 | 0 | 5 | 5 |
| Power Pages | 0 | 1 | 0 | 0 | 4 | 3 |
| web-resources | 0 | 0 | 0 | 0 | 5 | 5 |

## Top Issues Hurting Azure AI Search Retrieval
- Inconsistent headings and low semantic structure in some large files (weak chunk boundaries).
- Sparse or inconsistent metadata fields; front matter is rare.
- Boilerplate or run-log content increases noise in some folders.
- Cross-linking is uneven, reducing traversal quality between related artifacts.

## Quick Wins (No New Extraction Required)
- Add consistent H2/H3 sections for purpose, inputs, outputs, and verification in existing docs.
- Introduce lightweight YAML front matter across markdown to standardize metadata (owner, system, schema, type).
- Normalize naming conventions for identifiers across files to improve cross-linking and search hits.

## Gaps Requiring New Extraction
- Dataverse metadata (tables/columns/relationships) for authoritative schema and dependency mapping.
- ADO pipeline metadata and run histories for pipeline-to-artifact traceability.
- Flow/Plugin runtime telemetry and triggers/outputs for structured dependency extraction.

## What We Can Extract Automatically
### Extractable now (existing docs)
- Document titles, headings, and section-level summaries.
- Inline metadata such as Schema Name, Logical Name, Owner (where present).
- Relative cross-links between markdown files.
### Extractable from adjacent artifacts
- _registry assets/solutions YAML, _graph dependencies.json, reverse-index.yaml.
- RUNS folder logs for recent execution summaries.
- Pipelines/scripts configuration in Documentation/_scripts and pipelines folders.
### Requires new extraction
- Dataverse entity metadata and relationships.
- ADO pipeline definitions and run relationships not represented in docs.
- Power Platform environment configuration not captured in markdown.

## Recommendations: What to Measure Next (Instrumentation)
- Coverage metrics: % of files with required metadata fields.
- Cross-link density per folder and identifier coverage rate.
- Chunk size distribution (words per section) and heading depth consistency.
- Noise ratio: proportion of run-log vs authored content per folder.
