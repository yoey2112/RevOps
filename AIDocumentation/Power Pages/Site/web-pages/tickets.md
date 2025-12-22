# Tickets Web Page

## Overview
The Tickets page serves as the main support ticket management interface for the portal. It provides access to create and view support cases.

## Configuration

**Page ID:** `49f3485e-3e08-7685-8b43-d81653a4b21f`  
**Name:** Tickets  
**Title:** Support  
**Partial URL:** `/tickets`  
**Display Order:** 8

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

## Entity Form

- **Entity Form ID:** `9fd81bdb-3b42-f011-877a-002248ae15d3`
- The page includes an entity form for ticket/case creation or management

## Child Pages

- **My Tickets** - Lists user's existing tickets

## Navigation

- Parent: Home (`/`)
- URL: `/tickets`
- Hidden from main sitemap navigation

## Access Control

Access is controlled through:
- Web roles
- Table permissions for Case entity
- Contact-scoped permissions

## Purpose

The Tickets page provides:
- Interface to create new support cases
- Access to ticket management features
- Entity form for case data entry
- Navigation to user's existing tickets

## Related Components

- **Entity Form:** Case creation/management form
- **Basic Forms:** Case forms
- **Table Permissions:** 
  - Cases where contact is customer
  - Case Create
- **Child Pages:** My Tickets

## Related Documentation

- See `basic-forms/case-*.md` for form configurations
- See `table-permissions/table-permissions-summary.md` for access details
