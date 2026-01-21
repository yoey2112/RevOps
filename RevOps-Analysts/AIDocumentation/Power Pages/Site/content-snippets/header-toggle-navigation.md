# Header Toggle Navigation Content Snippet

## Overview
The Header Toggle Navigation snippet defines the accessible text for the mobile navigation menu toggle button in the portal header.

## Configuration

**Snippet ID:** `e9b34815-b1f1-4004-9f6d-196e9a8716ca`  
**Display Name:** Header/Toggle Navigation  
**Name:** Header/Toggle Navigation  
**Type:** 756150001 (HTML)  
**Language:** English (US) - `0b2ad1d3-1661-4df7-8d38-cef21d3a4b0f`

## Content

```html
Toggle navigation
```

## Purpose

This snippet provides:
- Accessible text for mobile menu button
- Screen reader description
- Toggle button label
- Navigation control text

## Usage

The snippet is referenced in:
- Mobile header navigation
- Hamburger menu button
- Navigation toggle control
- Responsive menu implementation

## Localization

The snippet supports multiple languages:
- English (en-US): "Toggle navigation"
- Additional languages as configured

## Display Location

Appears as:
- Hidden text for screen readers
- ARIA label for toggle button
- Mobile menu button description

## Mobile Navigation

Used in responsive design:
- Visible on mobile/tablet views
- Hidden text, visible functionality
- Accessibility compliance

## Customization

To modify:
1. Edit the content snippet value in Power Pages
2. Update the HTML content
3. Ensure accessibility compliance
4. Test on mobile devices
5. Publish changes

## Related Components

- **Content Snippets:**
  - Mobile-Header
  - Header navigation snippets
  
- **Navigation:**
  - Mobile navigation menu
  - Responsive header

## Accessibility

- Critical for screen reader users
- WCAG compliance
- Keyboard navigation support
- Mobile accessibility

## Technical Implementation

The snippet is typically used as:
```html
<button aria-label="{{ snippets['Header/Toggle Navigation'] }}">
  <span class="sr-only">{{ snippets['Header/Toggle Navigation'] }}</span>
  <i class="icon-menu"></i>
</button>
```

## Related Documentation

- See `content-snippets/mobile-header.md`
- See accessibility guidelines
