# Profile Web Page

## Overview
The Profile page allows authenticated users to view and manage their personal information, contact details, preferences, and account settings within the Power Pages portal.

## Configuration

**Page ID:** `c5f8c9b7-6157-488d-a357-7d4865ac7c23`  
**Name:** Profile  
**Title:** Profile  
**Partial URL:** `/profile`  
**Display Order:** Not specified

## Page Template

- **Template ID:** `3ab5b388-1c8f-447b-a629-b0f050355c63`
- **Template Name:** Profile page template (specialized template)

## Properties

- **Root Page:** Yes (`adx_isroot: true`)
- **Hidden from Sitemap:** Yes
- **Exclude from Search:** Yes (sensitive user data)
- **Enable Rating:** No
- **Enable Tracking:** No
- **Feedback Policy:** 756150000
- **Publishing State:** 0a3b218c-724a-4d78-b046-d238cd085b9f (Published)
- **Parent Page ID:** `60419c17-9d55-4eb3-b9d8-a0f182dc38e2` (Home)

## Navigation

- Parent: Home (`/`)
- URL: `/profile`
- Hidden from main sitemap navigation
- Typically accessed via user menu/account dropdown

## Access Control

Access is controlled through:
- User authentication (must be logged in)
- Self-service access only (users access their own profile)
- Contact-scoped permissions
- Web roles

## Purpose

The Profile page provides:
- View and edit personal information
- Update contact details
- Manage communication preferences
- View account associations
- Update password or security settings
- Manage notification preferences

## Functionality

The page allows users to:
- View contact information
- Edit personal details (name, email, phone)
- Update business information
- Manage preferences
- View associated accounts
- Update security settings
- Change password

## Profile Information

Typical profile sections include:
- **Personal Information:**
  - First name, last name
  - Email address
  - Phone number
  - Job title
  
- **Account Information:**
  - Associated accounts
  - Primary account
  - Account relationships
  
- **Preferences:**
  - Communication preferences
  - Notification settings
  - Language preference
  
- **Security:**
  - Password change
  - Two-factor authentication
  - Security questions

## Related Components

- **Table Permissions:**
  - Contact of the Contact (Read, Write)
  - Contact of the User (Read, Write)
  - Account of the Contact (Read)

- **Entity Forms:**
  - Contact profile edit form
  - Preference management form

- **Related Pages:**
  - Home - Return to portal home

## Security Considerations

- Users can only access their own profile
- Sensitive fields may be read-only
- Email verification required for changes
- Password changes require current password
- Audit logging for profile modifications

## Validation Rules

Profile updates may require:
- Email format validation
- Phone number formatting
- Required field validation
- Unique email address
- Business rule compliance

## User Experience

The page provides:
- Clean, organized profile layout
- Sectioned information display
- Inline editing or form-based editing
- Save/cancel actions
- Success/error messaging
- Mobile-responsive design

## Related Documentation

- See `table-permissions/table-permissions-summary.md` for contact permissions
- See authentication documentation for security settings
