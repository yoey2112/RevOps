# Logo Alt Text Content Snippet

## Overview
The Logo Alt Text snippet defines the alternative text for the portal logo image, used for accessibility and when images cannot be displayed.

## Configuration

**Snippet ID:** `f8f242c0-928e-db66-3b0d-15728e967324`  
**Display Name:** Logo alt text  
**Name:** Logo alt text  
**Type:** 756150000 (Text)  
**Language:** English (US) - `0b2ad1d3-1661-4df7-8d38-cef21d3a4b0f`

## Content

```html
(Empty - no alt text configured)
```

## Purpose

This snippet provides:
- Alternative text for logo image
- Accessibility support for screen readers
- Text description when image fails to load
- SEO benefit for image content

## Usage

The snippet is referenced in:
- Portal header logo
- Mobile header logo
- Logo image alt attribute

## Localization

The snippet supports multiple languages:
- English (en-US): Current configuration (empty)
- Additional languages as configured

## Display Location

Used in:
- Header navigation
- Mobile header
- Logo wrapper components

## Implementation

Typical usage in templates:
```html
<img src="{{ snippets['Logo URL'] }}" 
     alt="{{ snippets['Logo alt text'] }}" 
     height="40px">
```

## Accessibility

**Important:** The alt text is currently empty, which may impact:
- Screen reader users
- Accessibility compliance
- WCAG standards
- SEO optimization

## Best Practices

Alt text should:
- Describe the logo/brand
- Be concise (e.g., "Sherweb Logo")
- Be meaningful for screen readers
- Not include "image of" or "picture of"
- Match the brand name

## Recommended Content

Suggested alt text:
```html
Sherweb Logo
```
or
```html
Sherweb Helpdesk
```

## Customization

To configure:
1. Edit the content snippet in Power Pages
2. Add descriptive alt text
3. Keep it brief and meaningful
4. Test with screen readers
5. Publish changes

## Related Components

- **Content Snippets:**
  - Logo-URL
  - Site-Name
  - Mobile-Header
  
- **Usage Locations:**
  - Header template
  - Mobile header

## Compliance

Proper alt text helps meet:
- WCAG 2.1 Level AA
- Section 508 compliance
- ADA requirements
- Accessibility standards

## Related Documentation

- See `content-snippets/logo-url.md`
- See `content-snippets/site-name.md`
- See `content-snippets/mobile-header.md`
- See accessibility guidelines
