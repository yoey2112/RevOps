# Logo URL Content Snippet

## Overview
The Logo URL snippet defines the path to the portal logo image file used in the header and mobile navigation.

## Configuration

**Snippet ID:** `14c1a962-f0ef-426a-8bc0-fbdb93e6c43d`  
**Display Name:** Logo URL  
**Name:** Logo URL  
**Type:** 756150000 (Text)  
**Language:** English (US) - `0b2ad1d3-1661-4df7-8d38-cef21d3a4b0f`

## Content

```html
/SherwebLogo-WhiteBlue3000px544px.png
```

## Purpose

This snippet provides:
- Path to the logo image file
- Reference for logo display
- Centralized logo management
- Easy logo updates across the portal

## Usage

The snippet is referenced in:
- Portal header navigation
- Mobile header
- Logo image src attribute
- Branding components

## Image Details

Based on the filename:
- **File:** SherwebLogo-WhiteBlue3000px544px.png
- **Dimensions:** 3000px × 544px (original)
- **Display Size:** Scaled to 40px height in header
- **Colors:** White and blue color scheme
- **Format:** PNG (supports transparency)

## Display Location

Used in:
- Desktop header navigation
- Mobile header
- Any location displaying the logo

## Implementation

The snippet is used in templates as:
```html
{% if snippets['Logo URL'] %}
  <img src="https://images.sherweb.com/logo-sherweb-freshdesk.png" 
       alt="{{ snippets['Logo alt text'] }}" 
       height="40px">
{% endif %}
```

**Note:** In the actual implementation (mobile-header), the hardcoded URL `https://images.sherweb.com/logo-sherweb-freshdesk.png` is used instead of the snippet value, which points to `/SherwebLogo-WhiteBlue3000px544px.png`.

## Logo Sources

There appears to be two logo references:
1. **Snippet Value:** `/SherwebLogo-WhiteBlue3000px544px.png` (relative path)
2. **Actual Usage:** `https://images.sherweb.com/logo-sherweb-freshdesk.png` (absolute URL)

## Recommendation

For consistency:
- Update the snippet to match the actual logo URL being used
- Or update templates to use the snippet value
- Ensure all references point to the same logo source

## Customization

To update the logo:
1. Upload new logo to web files or external CDN
2. Update the Logo URL snippet value
3. Ensure templates reference the snippet
4. Test display across devices
5. Clear cache if needed
6. Publish changes

## Performance Considerations

- **External CDN:** Using `images.sherweb.com` provides CDN benefits
- **Relative Path:** Using `/SherwebLogo-WhiteBlue3000px544px.png` uses portal storage
- **Image Size:** Large original (3000px) should be optimized
- **Caching:** CDN provides better caching

## Best Practices

Logo images should:
- Be optimized for web (compressed)
- Support retina displays (2x resolution)
- Include transparency if needed
- Be hosted on CDN for performance
- Have appropriate dimensions

## Related Components

- **Content Snippets:**
  - Logo-Alt-Text
  - Site-Name
  - Mobile-Header
  
- **Web Files:**
  - Logo image files
  - Branding assets

## Related Documentation

- See `content-snippets/logo-alt-text.md`
- See `content-snippets/site-name.md`
- See `content-snippets/mobile-header.md`
- See web files documentation
