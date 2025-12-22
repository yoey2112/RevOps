# Footer Web Template

## Overview
The site footer template that provides copyright/legal information and dynamic accessibility links based on browser language settings.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\footer\`

## Configuration
- **Template ID**: `3f29d0cc-846a-473e-863b-268e258c7dec`
- **Template Name**: `Footer`

## Custom Code

### HTML Structure
```html
<footer role="contentinfo" class="footer">
  <div class="footer-bottom d-print-none">
    <div class="container">
      <div class="row">
        <div class="col-lg-9 col-md-9 col-sm-9 text-start">
          {% editable snippets 'Footer' type: 'html' %}
        </div>
        <div id="accessibilityLinkContainer" class="col-lg-3 col-md-3 col-sm-3 text-end"></div>
      </div>
    </div>
  </div>
</footer>
```

### JavaScript Functionality

**Dynamic Accessibility Link Injection:**
The footer uses JavaScript to detect the browser's language and dynamically inject language-specific accessibility compliance links.

**Supported Languages:**

1. **French (`fr`):**
   - Text: "Accessibilité : partiellement conforme"
   - Link: https://go.microsoft.com/fwlink/?linkid=2163806
   - Element ID: `frenchAccesssibleLink`

2. **Italian (`it`):**
   - Text: "Accessibilità: parzialmente conforme"
   - Link: https://go.microsoft.com/fwlink/?linkid=2208177
   - Element ID: `italianAccesssibleLink`

3. **Other Languages:**
   - Accessibility container is removed if language is not French or Italian

**Implementation:**
```javascript
window.onload = function() {
  const accessibilityLinkContainer = document.getElementById("accessibilityLinkContainer");
  switch(window.navigator.language) {
    case "fr":
      // Creates French accessibility link
      break;
    case "it":
      // Creates Italian accessibility link
      break;
    default:
      accessibilityLinkContainer.remove();
  }
};
```

### Key Features
1. **Editable Content**: Main footer content is editable via Content Snippets (`Footer`)
2. **Print-Friendly**: Footer hidden when printing (`d-print-none`)
3. **Responsive Layout**: Bootstrap grid system (col-lg-9/col-lg-3)
4. **Internationalization**: Browser language detection for accessibility links
5. **Accessibility**: Proper semantic HTML with `role="contentinfo"`

## Usage
This template is included in the page layout and renders at the bottom of every page. The footer provides:
- Editable static content (copyright, legal links, etc.)
- Dynamic accessibility compliance links based on browser language
- Responsive layout that adapts to screen size
- Print-optimized display (hidden when printing)

## Related Components
- **Content Snippets:**
  - `Footer` - Main footer content (editable)

- **External Resources:**
  - Microsoft accessibility compliance documentation
  - Language-specific accessibility statements

- **Bootstrap Classes:**
  - Responsive grid system
  - Text alignment utilities
  - Print utilities

## Change History
- Implemented dynamic accessibility link generation based on browser language
- Added support for French and Italian accessibility statements
- Configured responsive layout with Bootstrap grid
- Added print-friendly styling
- Integrated editable content snippet for footer text
