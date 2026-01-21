# New License Adjustment Request Web Page

## Overview
The New License Adjustment Request page provides a form interface for users to request changes to their service licenses, such as adding or removing licenses, upgrading plans, or modifying subscription quantities.

## Configuration

**Page ID:** `2c4539ef-3c52-d96a-8f55-b99e2ce82240`  
**Name:** New License Adjustment Request  
**Title:** New License Adjustment Request  
**Partial URL:** `/new-license-adjustment`  
**Display Order:** 27

## Page Template

- **Template ID:** `e30ca546-4857-40d8-b068-fad5a61ddd34`
- **Template Name:** Default studio template

## Properties

- **Root Page:** Yes (`adx_isroot: true`)
- **Hidden from Sitemap:** Yes
- **Exclude from Search:** No
- **Enable Rating:** No
- **Enable Tracking:** No
- **Publishing State:** 81c6631c-ca6b-4b35-8228-8e759104c26e (Published)
- **Parent Page ID:** `60419c17-9d55-4eb3-b9d8-a0f182dc38e2` (Home)

## Navigation

- Parent: Home (`/`)
- URL: `/new-license-adjustment`
- Hidden from main sitemap navigation
- Accessed through specific workflows or direct links

## Access Control

Access is controlled through:
- Web roles and authentication
- Case creation permissions
- Account-scoped access for license information

## Purpose

The New License Adjustment Request page provides:
- Form to request license modifications
- Capture license adjustment details
- Specify services and quantity changes
- Create tracking case for the request
- Submit requests to support team

## Functionality

The page allows users to:
- Select services/products for adjustment
- Specify quantity increases or decreases
- Request license upgrades or downgrades
- Provide effective date for changes
- Enter justification or notes
- Submit request for processing

## Related Components

- **Basic Forms:**
  - License adjustment request form
  
- **Table Permissions:**
  - Case Create permissions
  - Account read permissions
  - Service/Product read permissions

- **Related Pages:**
  - My Tickets - To view submitted requests
  - View Case - To track request progress
  - License Adjustment Details - To view request details

## Use Cases

Common license adjustment scenarios:
- Adding new user licenses
- Removing unused licenses
- Upgrading service plans
- Downgrading subscriptions
- Seasonal capacity adjustments
- License consolidation

## Workflow

1. User accesses the page
2. Completes license adjustment form
3. Specifies services and quantities
4. Submits request
5. Case is created and routed
6. User receives confirmation
7. Support team processes request

## Related Documentation

- See `basic-forms/` for license adjustment form configurations
- See `web-pages/license-adjustment-details.md` for detail view
- See `table-permissions/table-permissions-summary.md` for permissions
