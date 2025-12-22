# View Case Web Page

## Overview
The View Case page displays detailed information about a specific support ticket/case. It allows users to view case details, add notes, upload attachments, and track case progress.

## Configuration

**Page ID:** `41173efe-f763-f4b9-63e3-076608339a76`  
**Name:** View Case  
**Title:** View Case  
**Partial URL:** `/view-ticket`  
**Display Order:** 6

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

## Custom Assets

The page includes custom assets:
- `View-Case.webpage.custom_css.css` - Custom styling
- `View-Case.webpage.custom_javascript.js` - Custom JavaScript functionality
- `View-Case.webpage.copy.html` - Custom HTML content

## Navigation

- Parent: Home (`/`)
- URL: `/view-ticket`
- Hidden from main sitemap navigation
- Typically accessed via links from My Tickets list

## Access Control

Access is controlled through:
- Contact-scoped permissions - Users can only view cases where they are the customer
- Web roles
- Relationship-based access (contact_customer_contacts)

## Purpose

The View Case page provides:
- Detailed case information display
- Case history and timeline
- Ability to add notes/comments
- File attachment upload/download
- Case status tracking
- Related case activities

## Functionality

The page displays:
- **Case Header:**
  - Case number and title
  - Status and priority
  - Creation date and owner
  
- **Case Details:**
  - Description and resolution
  - Product/service information
  - Category and subject
  
- **Activity Timeline:**
  - Notes and comments
  - Email correspondence
  - Status changes
  
- **Attachments:**
  - File uploads
  - Document downloads

## Related Components

- **Basic Forms:**
  - Case detail view form
  - Case note creation form
  
- **Table Permissions:**
  - Cases where contact is customer (Read, Write)
  - Case-Notes-where-contact-is-customer (Read, Write, Create)
  - Attachments-where-contact-is-customer (Read, Create)
  - Email---Cases-where-contact-is-customer (Read)
  - Portal-Comment-where-contact-is-customer (Read, Write, Create)

- **Related Pages:**
  - Escalate Case - For case escalation
  - My Tickets - Return to ticket list

## Security

- Users can only view cases where they are listed as the customer contact
- Account-based permissions allow viewing cases for the user's account
- All data modifications are logged and audited

## Related Documentation

- See `basic-forms/case-*.md` for form configurations
- See `table-permissions/table-permissions-summary.md` for detailed permissions
- See `web-pages/escalate-case.md` for escalation process
