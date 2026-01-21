# Mobile Header Content Snippet

## Overview
The Mobile Header snippet defines the HTML structure and styling for the mobile navigation header, including the logo, site branding, and layout.

## Configuration

**Snippet ID:** `9be082fc-1123-4add-9a00-d61d6932bbdb`  
**Display Name:** Mobile Header  
**Name:** Mobile Header  
**Type:** 756150001 (HTML)  
**Language:** English (US) - `0b2ad1d3-1661-4df7-8d38-cef21d3a4b0f`

## Content

```html
<style>
  .logo-wrapper > .divisor {
    width: 1px;
    height: 100%;
    position: absolute;
    background: #000;
    left: -.7rem;
    opacity: .55;
  }

</style>

<a href="~/" class="d-flex align-items-center gap-4" >
  {% if snippets['Logo URL'] %}
    <img src="https://images.sherweb.com/logo-sherweb-freshdesk.png" alt="{{ snippets['Logo alt text'] }}" height="40px">
  {% endif %}
  {% if snippets['Site name'] %}
  <div class="position-relative logo-wrapper">
      <span class="divisor"></span>
      <h1 class="siteTitle custom-sitetitle my-0" >Helpdesk<span class="d-none">{{ snippets['Site name'] }}</span></h1>
    </div>
  {% endif %}
</a>
```

## Purpose

This snippet provides:
- Complete mobile header structure
- Logo and branding display
- Responsive header layout
- Custom styling for mobile view
- Navigation to home page

## Features

### CSS Styling
- **Divisor Line:** Vertical separator between logo and title
- **Width:** 1px
- **Color:** Black (#000)
- **Opacity:** 0.55 (semi-transparent)
- **Position:** Absolute positioning, -0.7rem left offset

### HTML Structure
- **Container:** Flexbox layout with gap-4 spacing
- **Logo Image:** Conditional display if Logo URL exists
- **Site Title:** Conditional display if Site name exists
- **Home Link:** Wrapper links to home page (~/)

### Logo Display
- **Source:** `https://images.sherweb.com/logo-sherweb-freshdesk.png`
- **Alt Text:** Uses `Logo alt text` snippet
- **Height:** Fixed 40px height
- **Aspect Ratio:** Maintained automatically

### Branding Display
- **Visible Title:** "Helpdesk"
- **Hidden Brand:** "Sherweb" (via Site name snippet, hidden with d-none)
- **Visual Separator:** Divisor line between logo and title
- **Heading Level:** H1 for SEO and accessibility

## Usage

The snippet is referenced in:
- Mobile navigation header
- Responsive header template
- Mobile-specific layouts

## Liquid Templating

Uses Liquid syntax:
- `{% if snippets['Logo URL'] %}` - Conditional logo display
- `{% if snippets['Site name'] %}` - Conditional site name display
- `{{ snippets['Logo alt text'] }}` - Logo alt text output
- `{{ snippets['Site name'] }}` - Site name output (hidden)
- `~/` - Portal home URL

## Bootstrap Classes

Utilizes Bootstrap 4/5 classes:
- `d-flex` - Display flex
- `align-items-center` - Vertical centering
- `gap-4` - Spacing between elements
- `position-relative` - Relative positioning
- `my-0` - Margin-y zero
- `d-none` - Display none (hidden)

## Responsive Design

Optimized for:
- Mobile devices
- Tablet portrait mode
- Small screen widths
- Touch interfaces

## Customization

To modify:
1. Edit the content snippet in Power Pages
2. Update CSS styling
3. Modify HTML structure
4. Test on various devices
5. Ensure accessibility
6. Publish changes

## Design Elements

**Visual Hierarchy:**
1. Sherweb logo (left)
2. Vertical divisor line
3. "Helpdesk" title (right)

**Spacing:**
- Gap-4 (1.5rem) between logo and title
- -0.7rem offset for divisor
- 40px logo height

**Colors:**
- Black divisor line
- 55% opacity for subtle effect

## Accessibility

- H1 heading for page title
- Alt text for logo image
- Hidden brand name still available to screen readers
- Semantic HTML structure
- Keyboard-accessible link

## Related Components

- **Content Snippets:**
  - Logo-URL (referenced but overridden with hardcoded URL)
  - Logo-Alt-Text
  - Site-Name
  
- **Usage Locations:**
  - Mobile navigation
  - Responsive header

## Issues/Improvements

1. **Logo URL Inconsistency:** Snippet references `Logo URL` but uses hardcoded URL
2. **Recommendation:** Update to use snippet value or update snippet to match
3. **Responsive Testing:** Ensure proper display across all mobile devices

## Related Documentation

- See `content-snippets/logo-url.md`
- See `content-snippets/logo-alt-text.md`
- See `content-snippets/site-name.md`
- See responsive design guidelines
