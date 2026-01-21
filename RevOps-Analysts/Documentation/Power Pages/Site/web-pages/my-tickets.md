# My Tickets Web Page

## Overview
The My Tickets page displays a list of support tickets/cases belonging to the currently authenticated user. It provides a personalized view of all cases where the user is the customer.

## Configuration

**Page ID:** `fae4d40d-9790-4e7e-067e-9a875b38f32b`  
**Name:** My Tickets  
**Title:** My Tickets  
**Partial URL:** `/my-tickets`  
**Display Order:** 2

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
- **Parent Page ID:** `49f3485e-3e08-7685-8b43-d81653a4b21f` (Tickets)

## Custom Assets

The page includes custom assets for enhanced functionality:
- `My-Tickets.webpage.custom_css.css` - Custom styling
- `My-Tickets.webpage.custom_javascript.js` - Custom JavaScript functionality
- `My-Tickets.webpage.copy.html` - Custom HTML content
- `My-Tickets.webpage.summary.html` - Summary section HTML

## Navigation

- Parent: Tickets (`/tickets`)
- URL: `/my-tickets`
- Hidden from main sitemap navigation

## Access Control

Access is controlled through:
- Web roles and authentication
- Contact-scoped table permissions
- Users can only view their own tickets

## Purpose

The My Tickets page provides:
- Filtered list view of user's support cases
- Quick access to ticket status and details
- Navigation to individual ticket details
- Overview of all open and closed cases

## Related Components

- **Lists:** 
  - Web - All Cases (filtered by contact)
- **Table Permissions:**
  - Cases where contact is customer (Read)
  - Cases where account of the contact is customer (Read)
- **Related Pages:**
  - View Case - For viewing individual ticket details
  - Tickets - Parent page for creating new tickets

## Functionality

The page displays:
- Case number and title
- Case status and priority
- Creation date and last modified date
- Links to view full case details
- Filtering and sorting options

## Related Documentation

- See `lists/Web---All-Cases.md` for list configuration
- See `web-pages/view-case.md` for individual ticket viewing
- See `table-permissions/table-permissions-summary.md` for access details
