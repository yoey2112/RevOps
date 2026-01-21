# Escalate Case Web Page

## Overview
The Escalate Case page provides functionality for users to escalate existing support cases when they require higher priority attention, additional resources, or management involvement.

## Configuration

**Page ID:** `0dfe949d-82a8-1efe-eb73-88ec9bc32855`  
**Name:** Escalate Case  
**Title:** Escalate Case  
**Partial URL:** `/Escalate-Case`  
**Display Order:** 23

## Page Template

- **Template ID:** `e30ca546-4857-40d8-b068-fad5a61ddd34`
- **Template Name:** Default studio template

## Properties

- **Root Page:** Yes (`adx_isroot: true`)
- **Hidden from Sitemap:** Yes
- **Exclude from Search:** No
- **Enable Rating:** No
- **Enable Tracking:** No
- **Feedback Policy:** 756150000
- **Publishing State:** 81c6631c-ca6b-4b35-8228-8e759104c26e (Published)
- **Parent Page ID:** `60419c17-9d55-4eb3-b9d8-a0f182dc38e2` (Home)

## Navigation

- Parent: Home (`/`)
- URL: `/Escalate-Case`
- Hidden from main sitemap navigation
- Typically accessed from View Case page

## Access Control

Access is controlled through:
- Web roles and authentication
- Case write permissions
- Contact-scoped access to cases
- Users can only escalate their own cases

## Purpose

The Escalate Case page provides:
- Form to request case escalation
- Capture escalation reason and justification
- Update case priority or status
- Notify support team of escalation
- Track escalation requests

## Functionality

The page allows users to:
- Select case to escalate
- Provide escalation reason
- Specify urgency level
- Add supporting details
- Submit escalation request
- Trigger escalation workflow

## Related Components

- **Basic Forms:**
  - Case escalation form
  
- **Table Permissions:**
  - Cases where contact is customer (Read, Write)
  - Cases where account of the contact is customer (Read, Write)
  - Case-Notes-where-contact-is-customer (Create)

- **Related Pages:**
  - View Case - Source page for escalation
  - My Tickets - View escalated cases

## Escalation Reasons

Common escalation scenarios:
- Service outage or critical impact
- Unresponsive support team
- Extended resolution time
- Business-critical issue
- Contractual SLA breach
- Request for management attention

## Workflow

1. User views case details
2. Accesses escalate case option
3. Completes escalation form
4. Provides reason and justification
5. Submits escalation request
6. Case priority updated
7. Support team notified
8. Management alerted if needed
9. Enhanced monitoring applied
10. Customer receives confirmation

## Escalation Process

The escalation triggers:
- Case priority increase
- Queue assignment changes
- Email notifications to support management
- SLA timer adjustments
- Enhanced case monitoring
- Follow-up scheduling

## Business Rules

Escalations may be subject to:
- Time-based criteria (case age)
- Priority level restrictions
- Support plan entitlements
- Escalation limits or quotas
- Manager approval requirements

## Related Documentation

- See `basic-forms/` for escalation form configurations
- See `web-pages/view-case.md` for case viewing
- See `table-permissions/table-permissions-summary.md` for permissions
