# New Migration Request Web Page

## Overview
The New Migration Request page provides a form interface for users to submit migration requests for transferring services or data between systems.

## Configuration

**Page ID:** `76a41bec-beab-0af0-7292-dc9293f013e3`  
**Name:** New Migration Request  
**Title:** Migration Details  
**Partial URL:** `/new-migration-request`  
**Display Order:** 24

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
- URL: `/new-migration-request`
- Hidden from main sitemap navigation
- Accessed through specific workflows or direct links

## Access Control

Access is controlled through:
- Web roles
- Authenticated users only
- Potential case creation permissions

## Purpose

The New Migration Request page provides:
- Form to submit migration requests
- Capture migration details and requirements
- Create a case/request record in Dynamics 365
- Track migration request through the support system

## Functionality

The page allows users to:
- Enter migration details
- Specify source and destination information
- Provide timeline requirements
- Submit migration request
- Create associated case for tracking

## Related Components

- **Basic Forms:**
  - Migration request creation form
  
- **Table Permissions:**
  - Case Create permissions
  - Transfer entity permissions (if applicable)

- **Related Pages:**
  - My Tickets - To view submitted migration requests
  - View Case - To track migration progress

## Use Cases

Common migration scenarios:
- Email migration between platforms
- Service provider transitions
- Data center migrations
- License transfers

## Related Documentation

- See `basic-forms/` for migration form configurations
- See `web-pages/p2p-transfer.md` for P2P transfer functionality
- See `table-permissions/table-permissions-summary.md` for permissions
