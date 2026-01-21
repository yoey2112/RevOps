# P2P Transfer Web Page

## Overview
The P2P Transfer (Peer-to-Peer Transfer) page provides functionality for users to transfer services or resources between accounts. This page facilitates the transfer process with appropriate validation and permissions.

## Configuration

**Page ID:** `65eb99ba-a128-7f6e-9b2b-ee6f35a46c73`  
**Name:** P2P Transfer  
**Title:** Transfer  
**Partial URL:** `/P2PTransfer`  
**Display Order:** 26

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
- URL: `/P2PTransfer`
- Hidden from main sitemap navigation
- Accessed through specific workflows or direct links

## Access Control

Access is controlled through:
- Web roles and authentication
- Transfer entity permissions (Create, Read, Write, Append)
- Account-scoped access controls
- Validation rules for transfer eligibility

## Purpose

The P2P Transfer page provides:
- Interface to initiate service transfers
- Form to capture transfer details
- Source and destination account selection
- Transfer validation and verification
- Create transfer request records

## Functionality

The page allows users to:
- Select services to transfer
- Specify source account
- Specify destination account
- Provide transfer justification
- Submit transfer request
- Track transfer status

## Related Components

- **Basic Forms:**
  - P2P Transfer creation form (see `case---create-p2p-from-portal.md`)
  
- **Table Permissions:**
  - Transfer - Create, Read, Update, Append, Append to (Global scope)
  - Account read permissions
  - Contact permissions

- **Related Pages:**
  - My Tickets - To view transfer requests
  - View Case - To track transfer progress

## Transfer Entity

The page interacts with the `revops_transfer` entity:
- **Entity Logical Name:** revops_transfer
- **Permissions:** Create, Read, Write, Append, AppendTo
- **Scope:** Global (756150000)

## Use Cases

Common P2P transfer scenarios:
- Transferring services between customer accounts
- Moving licenses to different organizations
- Consolidating services during mergers
- Restructuring account hierarchies
- Billing responsibility transfers

## Validation Rules

Transfers may require validation for:
- Account ownership verification
- Service eligibility
- Transfer authorization
- Billing status
- Contract compliance

## Workflow

1. User accesses P2P Transfer page
2. Selects services for transfer
3. Specifies source and destination
4. Provides transfer details
5. Submits transfer request
6. System validates eligibility
7. Transfer request created
8. Approval workflow initiated
9. Transfer executed upon approval

## Related Documentation

- See `basic-forms/case---create-p2p-from-portal.md` for form configuration
- See `table-permissions/table-permissions-summary.md` for transfer permissions
- See `advanced-forms/` for potential advanced form configurations
