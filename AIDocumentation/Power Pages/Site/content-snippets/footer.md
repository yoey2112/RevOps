# Footer Content Snippet

## Overview
The Footer snippet defines the HTML content displayed in the portal footer, including copyright information and external script references.

## Configuration

**Snippet ID:** `e7829595-5db9-4054-a70c-fca1211ee09b`  
**Display Name:** Footer  
**Name:** Footer  
**Type:** 756150001 (HTML)  
**Language:** English (US) - `0b2ad1d3-1661-4df7-8d38-cef21d3a4b0f`

## Content

```html
<p class="small"><span>Copyright © </span>{{ now | date: 'yyyy' }}<span>. All rights reserved.</span></p>
<script src="https://kit.fontawesome.com/824c7bc1b6.js" crossorigin="anonymous"></script>
```

## Purpose

This snippet provides:
- Copyright notice with dynamic year
- Font Awesome icon library integration
- Standard footer content
- Legal information

## Features

### Copyright Notice
- **Dynamic Year:** Uses Liquid templating `{{ now | date: 'yyyy' }}` to automatically update the year
- **Text:** "Copyright © [YEAR]. All rights reserved."
- **Styling:** Small text class applied

### Font Awesome Integration
- **Library:** Font Awesome v5/6 Kit
- **Kit ID:** 824c7bc1b6
- **Loading:** Asynchronous script loading
- **CORS:** Cross-origin enabled

## Usage

The snippet is referenced in:
- Portal footer template
- All pages across the portal
- Site-wide layout

## Localization

The snippet supports multiple languages:
- English (en-US): Default content
- Additional languages with translated copyright text

## Display Location

Appears at:
- Bottom of every portal page
- Footer section
- Below main content

## Liquid Templating

Uses Liquid syntax:
- `{{ now }}` - Current datetime object
- `| date: 'yyyy'` - Format filter for year only

## External Dependencies

**Font Awesome Kit:**
- Provides icon fonts
- Loaded from CDN
- Used throughout portal for icons
- Performance impact: ~100KB

## Customization

To modify:
1. Edit the content snippet value in Power Pages
2. Update HTML/script references
3. Change copyright text if needed
4. Update Font Awesome kit ID if changing accounts
5. Publish changes

## Best Practices

- Keep copyright year dynamic using Liquid
- Use async/defer for external scripts
- Minimize footer content for performance
- Ensure CORS attributes for external resources

## Performance Considerations

- Font Awesome loaded on every page
- Consider self-hosting for better performance
- Use specific icons instead of full kit if possible
- Monitor loading time impact

## Related Components

- **Page Templates:** All page templates reference footer
- **Web Templates:** Footer web template
- **Content Snippets:** Other footer-related snippets

## Legal Compliance

The footer should include:
- Copyright notice
- Year of copyright
- Rights statement
- Company/organization name (if needed)

## Related Documentation

- See page templates for footer implementation
- See web templates for layout structure
