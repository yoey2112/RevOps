# Site Name Content Snippet

## Overview
The Site Name snippet defines the name of the portal site displayed in the header and used for branding throughout the portal.

## Configuration

**Snippet ID:** `9ca759ef-ea98-10c8-3f82-000e98189949`  
**Display Name:** Site name  
**Name:** Site name  
**Type:** 756150000 (Text)  
**Language:** English (US) - `0b2ad1d3-1661-4df7-8d38-cef21d3a4b0f`

## Content

```html
Sherweb
```

## Purpose

This snippet provides:
- Portal site name for branding
- Text displayed alongside logo
- Brand identity
- Customizable site title

## Usage

The snippet is referenced in:
- Portal header navigation
- Mobile header
- Site title displays
- Branding components

## Display Location

Used in:
- Desktop header next to logo
- Mobile header
- Browser tab title (potentially)
- Site metadata

## Implementation

The snippet is used in the mobile-header template as:
```html
{% if snippets['Site name'] %}
  <div class="position-relative logo-wrapper">
    <span class="divisor"></span>
    <h1 class="siteTitle custom-sitetitle my-0">
      Helpdesk<span class="d-none">{{ snippets['Site name'] }}</span>
    </h1>
  </div>
{% endif %}
```

## Display Logic

Interesting implementation:
- Displays "Helpdesk" visibly in the header
- The snippet value "Sherweb" is hidden with `d-none` class
- Hidden content still accessible to screen readers
- Provides brand name for accessibility while showing "Helpdesk" visually

## Localization

The snippet supports multiple languages:
- English (en-US): "Sherweb"
- Additional languages as configured

## SEO Impact

The site name affects:
- Page titles
- Brand recognition
- Search engine indexing
- Social media sharing

## Customization

To modify:
1. Edit the content snippet in Power Pages
2. Update the site name text
3. Consider impact on branding
4. Update related metadata
5. Publish changes

## Related Components

- **Content Snippets:**
  - Logo-URL
  - Logo-Alt-Text
  - Mobile-Header
  
- **Usage Locations:**
  - Header template
  - Mobile header
  - Page titles
  - Metadata

## Branding Strategy

The current implementation shows:
- **Visual Brand:** "Helpdesk" (displayed to users)
- **Organizational Brand:** "Sherweb" (hidden but accessible)
- **Logo:** Sherweb logo image

This separates product branding (Helpdesk) from company branding (Sherweb).

## Accessibility

- Site name available to screen readers
- Provides context even when hidden visually
- Improves navigation for assistive technologies

## Related Documentation

- See `content-snippets/logo-url.md`
- See `content-snippets/logo-alt-text.md`
- See `content-snippets/mobile-header.md`
