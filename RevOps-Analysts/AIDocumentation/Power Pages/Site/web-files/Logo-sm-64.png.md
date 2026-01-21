# Logo-sm-64.png - Small Sherweb Logo (64x64)

## Overview
Small square format Sherweb logo optimized for compact display areas. This 64x64 pixel version is designed for use in contexts where space is limited, such as mobile navigation, app icons, or small UI elements.

## Location
`/web-files/Logo-sm-64.png`
- **Web File ID**: ded68516-99e1-43d0-adf2-79774ff3ca93
- **Parent Page ID**: 60419c17-9d55-4eb3-b9d8-a0f182dc38e2
- **Partial URL**: Logo-sm-64.png
- **MIME Type**: image/png

## Configuration
- **Publishing State**: Published (81c6631c-ca6b-4b35-8228-8e759104c26e)
- **Excluded from Search**: No
- **Hidden from Sitemap**: No
- **Tracking Enabled**: No

## Image Specifications
- **Format**: PNG (supports transparency)
- **Dimensions**: 64px × 64px (square)
- **Size**: Small file size for fast loading
- **Purpose**: Compact logo display

## Usage Scenarios

### Mobile Navigation
- Mobile menu icon or header logo
- Limited screen space on small devices
- Quick loading for mobile users

### Profile/Avatar Areas
- User profile sections
- Account dropdowns
- Small branding elements

### Compact UI Elements
- Sidebar navigation
- Small cards or tiles
- Footer condensed sections

### List Items
- Directory listings with logos
- Navigation items with icons
- Compact branding indicators

## Comparison with Other Logo Sizes

| Logo Asset | Dimensions | Best Use |
|------------|------------|----------|
| Logo-sm-64.png | 64×64 | Mobile, compact spaces |
| Sherweb_Logo-Full_color_3000px_544px.png | 3000×544 | Desktop header, large displays |
| Sherweb_Logo-White&Blue_3000px_544px.png | 3000×544 | Dark backgrounds, large displays |
| favicon.ico | 16×16 / 32×32 | Browser tabs, bookmarks |

## Implementation Example
```html
<!-- Mobile navigation -->
<div class="navbar-brand-mobile">
  <img src="/Logo-sm-64.png" 
       alt="Sherweb" 
       width="64" 
       height="64">
</div>

<!-- Compact sidebar -->
<div class="sidebar-logo">
  <img src="/Logo-sm-64.png" 
       alt="Sherweb Logo" 
       class="logo-small">
</div>
```

## CSS Styling Example
```css
.logo-small {
  width: 64px;
  height: 64px;
  display: block;
}

@media (max-width: 767px) {
  .navbar-brand-mobile img {
    width: 48px;
    height: 48px;
  }
}
```

## Responsive Considerations
- Optimized size for mobile displays
- Fast loading due to small file size
- Square format works well in various contexts
- Can scale down further if needed (48px, 32px)

## Design Considerations
- **Square Format**: Likely contains icon/mark only (not full wordmark)
- **Simplified**: May be simplified version of full logo for clarity at small size
- **Recognizable**: Must maintain brand recognition at 64px

## Accessibility
- Include alt text: "Sherweb" or "Sherweb Logo"
- Ensure sufficient size for touch targets (minimum 44×44px)
- Maintain adequate contrast with background

## Performance
- **Small file size**: Fast loading
- **PNG format**: Good quality-to-size ratio
- **Single resolution**: Consider @2x version for retina displays

## When to Use

### ✅ Use Logo-sm-64.png
- Mobile navigation headers
- Compact UI components
- List items with logos
- Profile/account areas
- Space-constrained layouts

### ❌ Use Full-Size Logos
- Desktop main navigation
- Hero sections
- Large branding areas
- Print materials
- Marketing sections

## Related Components
- **Mobile web templates**: Responsive navigation
- **Navbar**: Mobile breakpoint styling
- **Sidebar components**: Compact navigation
- **theme.css**: Mobile-specific styles

## Brand Consistency
- Maintains Sherweb brand identity
- Scaled-down version of main logo
- Consistent with other branding assets

## File Optimization
- Already optimized at 64×64
- PNG format for quality
- Transparent background likely
- Small file size for performance

## Change History
- Small logo variant for compact displays
- 64×64 square format for flexibility
- Optimized for mobile and small UI elements
