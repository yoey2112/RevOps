# favicon.ico - Site Favicon

## Overview
Favicon (favorite icon) image file displayed in browser tabs, bookmarks, and browser history for the Sherweb client portal. This small icon provides brand recognition and helps users identify the portal among multiple open tabs.

## Location
`/web-files/favicon.ico`
- **Web File ID**: b468ad5b-fa45-f011-877a-002248ae15d3
- **Parent Page ID**: 60419c17-9d55-4eb3-b9d8-a0f182dc38e2
- **Partial URL**: favicon.ico
- **Display Title**: Sherweb

## Configuration
- **Publishing State**: Published (81c6631c-ca6b-4b35-8228-8e759104c26e)
- **Excluded from Search**: No
- **Hidden from Sitemap**: No
- **Content Disposition**: 756150000
- **Actual Filename**: favicon.png
- **MIME Type**: image/png

## Technical Details
- **Format**: PNG (despite .ico extension in partial URL)
- **Purpose**: Browser tab icon, bookmark icon, browser history icon
- **Brand**: Sherweb branding

## Usage Locations

### Browser Tabs
- Appears in browser tab next to page title
- Helps users identify the portal among multiple tabs
- Size typically 16x16 or 32x32 pixels

### Bookmarks/Favorites
- Displayed next to bookmark title in favorites bar
- Shows in bookmark manager

### Browser History
- Appears in browser history listings
- Visible in address bar dropdown suggestions

### Mobile Home Screen
- May be used as app icon on some mobile devices
- Falls back when other icons not specified

## Implementation
Referenced in HTML `<head>` section:
```html
<link rel="icon" type="image/png" href="/favicon.ico">
```
or
```html
<link rel="shortcut icon" href="/favicon.ico">
```

## Brand Representation
- Represents Sherweb brand
- Provides visual consistency across browser UI
- Quick visual identification for users

## Related Components
- **Logo-sm-64.png**: Small logo (64x64)
- **Sherweb_Logo-Full_color_3000px_544px.png**: Full-size logo
- **PWAManifest.json**: References PWALogo.png for app icon
- **Page title tags**: Displayed alongside favicon in tabs

## Best Practices
- Keep file size small (<10KB)
- Use simple, recognizable design
- Ensure visibility at small sizes (16x16px)
- Maintain brand colors

## Change History
- Configured as Sherweb favicon
- PNG format for better quality than traditional .ico
- Published and accessible site-wide
