# Default Studio Template Web Template

## Overview
A minimal, standard page template used as the default layout for Power Pages Studio. Provides a simple wrapper for editable page content with Liquid support.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\default-studio-template\`

## Configuration
- **Template ID**: `d9b27d0b-9cf3-4ece-889c-c8d81f437fa1`
- **Template Name**: `Default studio template`
- **Warning**: "Please do not modify" - This is a system template

## Custom Code

### HTML Structure
```html
<!-- Default studio template. Please do not modify -->
<div id="mainContent" class="wrapper-body" role="main">
    <div class="page-copy">
      {% editable page 'adx_copy' type: 'html', liquid: true %}
    </div>
</div>
```

### Key Features

1. **Main Content Container:**
   - `id="mainContent"` - Used as skip-to-content target
   - `role="main"` - ARIA landmark for main content area
   - `.wrapper-body` - Wrapper styling class

2. **Editable Content:**
   - Uses `{% editable %}` tag for content management
   - Targets `page.adx_copy` field
   - Type: `html` - Rich text editing
   - `liquid: true` - Allows Liquid code in content

3. **Accessibility:**
   - Semantic HTML with ARIA role
   - Main content region clearly defined
   - Compatible with skip-to-content links

4. **Studio Integration:**
   - Default template in Power Pages Studio
   - Simple, unopinionated structure
   - Easy to customize per-page

## Usage

This template is automatically used by Power Pages Studio for new pages unless a different template is specified. It provides the basic structure for page content while allowing full editing capabilities.

**Content Editing:**
- Editors can modify page content via Studio or portal management
- Liquid code can be embedded within the page content
- HTML formatting is preserved

**Skip-to-Content:**
Referenced by the Header template:
```html
<a href="#mainContent">Skip to main content</a>
```

## Related Components

- **Web Templates:**
  - `Header` - References `#mainContent` for skip link
  - Custom page templates - May use similar structure

- **Page Fields:**
  - `adx_copy` - Main content field
  
- **ARIA Landmarks:**
  - `role="main"` - Main content region

- **Power Pages Studio:**
  - Default template for new pages
  - Content editing interface

## Change History
- System-provided template
- Marked as "do not modify" to preserve Studio functionality
- Implements editable content with Liquid support
- ARIA accessibility for main content region

## Recommendations
- Do not modify this template directly
- Create custom page templates for specific layouts
- Use this as reference for custom template structure
- Maintain the `#mainContent` ID for skip-to-content functionality
