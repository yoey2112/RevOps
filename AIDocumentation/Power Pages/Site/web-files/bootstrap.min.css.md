# bootstrap.min.css - Bootstrap Framework Base

## Overview
Minified Bootstrap CSS framework file providing the foundational styles and responsive grid system for the Power Pages portal. This is the core Bootstrap library that other stylesheets build upon.

## Location
`/web-files/bootstrap.min.css`
- **Web File ID**: eeb27ebc-a845-4887-9838-77054fb63c15
- **Parent Page ID**: 60419c17-9d55-4eb3-b9d8-a0f182dc38e2
- **Display Order**: 1 (loaded first)
- **MIME Type**: text/css

## Configuration
- **Publishing State**: Published (81c6631c-ca6b-4b35-8228-8e759104c26e)
- **Excluded from Search**: Yes
- **Hidden from Sitemap**: Yes
- **Tracking Enabled**: No

## Framework Details
- **Library**: Bootstrap
- **Version**: 3.x (implied by compatibility with theme.css references)
- **Format**: Minified (.min.css)
- **Purpose**: Base CSS framework

## Features Provided

### Grid System
- 12-column responsive grid
- Container and container-fluid layouts
- Row and column classes (col-xs, col-sm, col-md, col-lg)

### Typography
- Base heading styles (h1-h6)
- Paragraph and text utilities
- Text alignment and transformation classes

### Components
- **Navigation**: navbar, nav, breadcrumb
- **Buttons**: btn, btn-primary, btn-default, etc.
- **Forms**: form-control, input-group, form-group
- **Tables**: table, table-striped, table-hover
- **Alerts**: alert, alert-success, alert-danger, etc.
- **Cards/Panels**: card, card-header, card-body
- **Modals**: modal, modal-dialog, modal-content
- **Dropdowns**: dropdown, dropdown-menu, dropdown-toggle
- **Pagination**: pagination

### Utilities
- Display utilities (d-none, d-block, etc.)
- Spacing utilities (margin and padding)
- Float utilities (pull-left, pull-right)
- Text utilities (text-center, text-right, etc.)
- Visibility utilities (visible-xs, hidden-sm, etc.)

## Load Order
**Position**: First CSS file loaded (Display Order: 1)
**Followed by**:
1. theme.css (Display Order: 2)
2. custom.css (Display Order: 3)
3. portalbasictheme.css (Display Order: 10)

## Responsive Breakpoints
- **Extra Small (xs)**: <768px (mobile)
- **Small (sm)**: ≥768px (tablets)
- **Medium (md)**: ≥992px (desktops)
- **Large (lg)**: ≥1200px (large desktops)

## Usage
This file provides the foundation that all other portal styles build upon. It should not be modified directly as it's a third-party library.

### Why Minified?
- Reduced file size for faster page loads
- Removes whitespace and comments
- Single line format

### Customization Approach
Do not modify this file. Instead:
1. Override styles in `theme.css`
2. Add custom styles to `custom.css`
3. Use `portalbasictheme.css` for theme-specific changes

## Related Components
- **theme.css**: Extends Bootstrap with custom portal styles
- **portalbasictheme.css**: Microsoft-generated theme styles
- **custom.css**: Site-specific custom CSS overrides
- **All web templates**: Utilize Bootstrap classes

## Browser Support
- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- IE 11 (limited support)

## Change History
- Standard Bootstrap framework file
- Minified for production use
- Load order priority set to 1 (first CSS file)
- Hidden from sitemap and search
