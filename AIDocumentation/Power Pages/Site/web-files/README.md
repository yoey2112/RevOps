# Web Files - Complete Documentation Summary

## Overview
This document provides a comprehensive summary of all custom web files (CSS, JavaScript, images, and configuration files) documented for the Power Pages portal at `c:\RevOps\Power Page Site\.paportal\swdevportal\web-files\`.

---

## 📋 Complete File Inventory

### CSS Files (4 files)
1. **bootstrap.min.css** - Bootstrap framework base
2. **theme.css** - Extended theme customizations
3. **custom.css** - Custom CSS overrides
4. **portalbasictheme.css** - Auto-generated theme styles

### JavaScript Files (1 file)
5. **hide-draft-timeline.js** - Draft timeline hiding functionality

### Configuration Files (1 file)
6. **PWAManifest.json** - Progressive Web App configuration

### Logo Images (3 files)
7. **Sherweb_Logo-Full_color_3000px_544px.png** - Primary full-color logo
8. **Sherweb_Logo-White&Blue_3000px_544px.png** - Alternative dark background logo
9. **Logo-sm-64.png** - Small logo (64×64)

### Knowledge Base Images (4 files)
10. **Knowledge-Base.jpg** - Primary KB image
11. **Knowledge-Base-2.jpg** - KB category image
12. **Knowledge-Base-3.jpg** - KB category image
13. **Knowledge-Base-4.jpg** - KB category image

### Other Images (3 files)
14. **favicon.ico** - Browser favicon
15. **freshdesk-home-photo-2.png** - Homepage support image
16. **Cat-PC.png** - Decorative/error page image

### Miscellaneous Files (1 file)
17. **GREY-(1)** - Gray color reference file (SCSS/design asset)

**Total Files Documented: 17**

---

## 🎨 CSS Architecture & Styling

### Load Order (Critical)
1. **bootstrap.min.css** (Order: 1) - Base framework
2. **theme.css** (Order: 2) - Custom extensions
3. **custom.css** (Order: 3) - Targeted overrides
4. **portalbasictheme.css** (Order: 10) - Generated theme

### Color Palette System

#### Primary Brand Colors
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Sherweb Orange** | #ED573C | Primary CTA, buttons, links |
| **Purple-Blue** | #302ce1 | Interactive elements (hover) |
| **Bright Blue** | #00b4ff | Links, accents |
| **Dark Navy** | #1C1C45 | Headers, dark sections |
| **Near Black** | #191817 | Footer, dark text |
| **White** | #FFFFFF | Backgrounds, light text |
| **Black** | #000000 | Primary text |

#### Gray Palette
| Shade | Hex Code | Usage |
|-------|----------|-------|
| Very Light Gray | #f8f8f8 | Background sections |
| Light Gray | #e3e3e3 | Borders, dividers |
| Medium Gray | #bcbcbc | Secondary borders |
| Dark Gray | #5C5A58 | Text, icons |
| Footer Gray | #d2d2ce | Footer background |

### Typography System

#### Font Family
**Primary**: Montserrat (400, 600, 700 weights)
- Regular (400) - body text
- Semi-Bold (600) - buttons, emphasis
- Bold (700) - headings, important text

#### Font Sizes
- **H1**: 40px (36px in some contexts)
- **H2**: 36px (28px in some contexts)
- **H3**: 24px
- **H4**: 24px (bold)
- **H5**: 14px (bold)
- **Body**: 20px (16px for secondary text)
- **Buttons**: 14px
- **Links**: 14px
- **Footer**: 16px

### Button Styles

#### Primary Button (.btn-primary, .button1)
```
Color: White on Sherweb Orange (#ED573C)
Hover: White on Near Black (#191817)
Border Radius: 2px
Font: Montserrat 600, 14px
Padding: 6px 20px
```

#### Secondary Button (.btn-secondary, .button2)
```
Color: Orange text on transparent (#ED573C)
Hover: White on Orange (#ED573C)
Border: 1.6px solid Orange
Font: Montserrat 600, 14px
```

---

## 🔧 Custom JavaScript Functionality

### hide-draft-timeline.js - Key Features

#### Purpose
Automatically hides draft timeline items from case/incident views to prevent portal users from seeing internal draft notes.

#### Implementation
- **Technology**: MutationObserver API
- **Target**: `div.note[data-state="draft"]`
- **Container**: `div[data-parent-entitylogicalname="incident"]`
- **Timing**: 1-second delay after DOMContentLoaded

#### Functionality
1. Waits for DOM to load
2. Locates incident timeline container
3. Hides existing draft notes
4. Continuously monitors for new draft notes
5. Auto-hides new drafts as they appear

#### Console Logging
- ✅ Script loaded confirmation
- ⏳ DOM ready notification
- ✅ Container found / ⚠️ Container not found
- Count of draft items found

---

## 📱 Progressive Web App Configuration

### PWAManifest.json Details

#### App Identity
- **Name**: clientportal
- **Short Name**: clientportal
- **Description**: clientportal

#### Display Configuration
- **Mode**: Standalone (no browser UI)
- **Start URL**: / (portal root)
- **Scope**: / (entire portal)
- **Orientation**: Any

#### Theming
- **Theme Color**: #000000 (Black) - System UI
- **Background Color**: #ED573C (Sherweb Orange) - Splash screen

#### App Icon
- **Source**: /PWALogo.png
- **Size**: 512×512 pixels
- **Format**: PNG

#### Benefits
✅ Installable on desktop and mobile devices
✅ Standalone app experience without browser chrome
✅ App launcher integration
✅ Splash screen during launch
✅ Native app-like feel

---

## 🖼️ Image Asset Inventory

### Logo Assets

#### Full-Color Logo (3000×544px)
- **Usage**: Primary desktop navigation, large displays
- **Format**: PNG with transparency
- **Brand**: Full Sherweb brand colors

#### White & Blue Logo (3000×544px)
- **Usage**: Dark backgrounds (footer, dark sections)
- **Format**: PNG with transparency
- **Contrast**: Optimized for #191817, #232222 backgrounds

#### Small Logo (64×64px)
- **Usage**: Mobile navigation, compact spaces
- **Format**: Square PNG
- **Performance**: Optimized for fast loading

#### Favicon (16×16 / 32×32)
- **Usage**: Browser tabs, bookmarks, history
- **Format**: PNG (listed as .ico)
- **Title**: Sherweb

### Content Images

#### Knowledge Base Series (4 JPGs)
- **Knowledge-Base.jpg** - Primary KB landing
- **Knowledge-Base-2.jpg** - Category/article preview
- **Knowledge-Base-3.jpg** - Category/article preview
- **Knowledge-Base-4.jpg** - Category/article preview
- **Usage**: KB homepage, category grids, article previews
- **Layout**: 2×2 grid or 4-column layouts

#### Support/Feature Images

##### freshdesk-home-photo-2.png
- **Usage**: Homepage support section, help center
- **Context**: Customer support feature showcase
- **Format**: PNG

##### Cat-PC.png
- **Usage**: Error pages (404), empty states, decorative
- **Purpose**: Friendly UX, soften error messages
- **Format**: PNG with transparency

---

## 🎯 Key Custom CSS Rules Documented

### From custom.css (Targeted Overrides)

#### Hidden Navigation Elements
```css
/* Hides in both English and French */
- Redeem invitation links
- Register links  
- Profile links
- Associated dropdown dividers
```

**Languages Supported**: English and French
**Selectors Used**: `[aria-label]`, `:has()`, `+` (adjacent sibling)

### From theme.css (Major Customizations)

#### Navigation Styling
- **Purple-blue hover** (#302ce1) on nav links
- **Sticky positioning** on static-top navbar
- **White background** on navbar-dark (despite name)
- **Dashed border focus** states for accessibility

#### Section Layouts
- **Diagonal sections** with 1.3° skew transforms
- **Landing sections** with 4rem headings (responsive to 16vw)
- **Sidebar components** with blue accent border (#0b80d0)

#### Responsive Breakpoints
- **<767px**: Mobile optimizations
- **<993px**: Tablet adjustments  
- **≥992px**: Desktop features
- **≥1199px**: Large desktop

#### Special Components
- **Skip-to-content** link for accessibility
- **High contrast mode** support
- **French accessibility** link styling
- **Power Virtual Agent** floating position

### From portalbasictheme.css (Generated Theme)

#### CSS Custom Properties (12 Colors)
```
--portalThemeColor1 through --portalThemeColor12
--portalThemeOnColor1 through --portalThemeOnColor12
```

#### Component Theme Classes
```css
[data-component-theme="portalThemeColor1"]
[data-component-theme="portalThemeColor2"]
/* etc. */
```

#### Responsive Container Widths
- 540px @ 576px breakpoint
- 720px @ 768px breakpoint
- 960px @ 992px breakpoint
- 1140px @ 1200px breakpoint
- 1320px @ 1400px breakpoint

---

## 🔍 Critical Implementation Notes

### CSS Cascade Understanding
1. **Bootstrap** provides foundation
2. **theme.css** extends with custom Sherweb styles
3. **portalbasictheme.css** adds generated theme from Site Styling panel
4. **custom.css** makes final targeted overrides

### JavaScript Best Practices
- **MutationObserver** for dynamic content (hide-draft-timeline.js)
- **Console logging** for debugging
- **Timing considerations** (1s delay for initialization)
- **Error handling** (warns if container not found)

### PWA Features
- Portal installable as standalone app
- Sherweb brand colors in splash screen
- Works on desktop and mobile platforms
- Requires HTTPS and service worker

### Image Optimization
- **PNGs** for logos (transparency needed)
- **JPGs** for photographs (KB images)
- **High-res logos** (3000px) for scalability
- **Small versions** (64px) for performance

### Responsive Design
- Mobile-first Bootstrap grid
- Responsive images with `.img-responsive`
- Viewport-based font sizing (vw units)
- Media queries for 4-5 breakpoints

---

## 🚀 Performance Considerations

### CSS Optimization
- ✅ Bootstrap minified
- ⚠️ Multiple CSS files (consider bundling)
- ✅ CSS variables for theming
- ✅ Specific selectors (good performance)

### Image Optimization
- ✅ Appropriate formats (PNG/JPG)
- ⚠️ Large logo files (3000px - consider responsive images)
- ✅ Small favicon
- ⚠️ Consider lazy loading for below-fold images

### JavaScript Performance
- ✅ Single small JS file
- ✅ Efficient DOM queries
- ✅ MutationObserver (event-driven, not polling)
- ✅ Minimal DOM manipulation

---

## ♿ Accessibility Features

### Keyboard Navigation
- **Focus states** clearly defined with dashed borders
- **Skip-to-content** link for keyboard users
- **Tab order** maintained through proper HTML structure

### Screen Readers
- **ARIA labels** used in custom.css targeting
- **Alt text** emphasized in image documentation
- **Semantic HTML** supported by CSS

### Visual Accessibility
- **High contrast mode** support in theme.css
- **Color contrast** ratios considered in palette
- **Focus indicators** visible and distinct

### Bilingual Support
- **English and French** support in custom.css
- **ARIA labels** for both languages
- **Consistent UX** across languages

---

## 🔗 Component Relationships

### CSS Dependencies
```
bootstrap.min.css (foundation)
    ↓
theme.css (extends)
    ↓
portalbasictheme.css (generated theme)
    ↓
custom.css (overrides)
```

### Image Usage
```
Navigation → Logo files
Homepage → freshdesk-home-photo-2.png, Knowledge-Base images
Knowledge Base → Knowledge-Base series (4 images)
Errors → Cat-PC.png
Browser → favicon.ico
App Icon → PWALogo.png (referenced in manifest)
```

### JavaScript Integration
```
Timeline pages → hide-draft-timeline.js
Case/Incident views → Monitors draft notes
Dynamic content → MutationObserver
```

---

## 📊 File Statistics

### By Type
- **CSS**: 4 files
- **JavaScript**: 1 file
- **JSON**: 1 file
- **PNG Images**: 7 files
- **JPG Images**: 4 files
- **ICO/Favicon**: 1 file
- **Other**: 1 file (GREY)

### By Purpose
- **Styling**: 4 files (CSS)
- **Functionality**: 1 file (JS)
- **Configuration**: 1 file (JSON)
- **Branding**: 4 files (logos + favicon)
- **Content**: 8 files (KB + support images)
- **UX**: 1 file (Cat-PC)
- **Design Assets**: 1 file (GREY)

### By Size Category (Estimated)
- **Large**: Logo files (3000px width)
- **Medium**: Knowledge Base JPGs, theme CSS files
- **Small**: favicon, small logo, custom.css, JS file
- **Tiny**: PWAManifest.json

---

## 🎓 Key Takeaways

### Custom CSS Highlights
1. **Bilingual UI hiding** (English/French) for invitation redemption, registration, profile
2. **Purple-blue accent color** (#302ce1) as primary interactive color
3. **Sherweb orange** (#ED573C) as brand primary
4. **12-color palette system** with CSS variables
5. **Extensive responsive design** with 5 breakpoints

### JavaScript Functionality
1. **Draft hiding** on case timelines using MutationObserver
2. **Automatic detection** of dynamically loaded content
3. **Bilingual console logging** for debugging
4. **1-second initialization delay** for reliability

### PWA Implementation
1. **Standalone app** capability on desktop and mobile
2. **Sherweb branding** in splash screen (orange background)
3. **512×512 icon** for all platforms
4. **Full portal scope** for complete app experience

### Design System
1. **Montserrat font family** across all typography
2. **Consistent button styling** with hover states
3. **Accessible focus states** with dashed borders
4. **High contrast mode** support for accessibility

---

## 📁 Documentation Files Created

All documentation saved to:
`c:\RevOps\RevOps-Analysts\Documentation\Power Pages\Site\web-files\`

### Complete List
1. ✅ `bootstrap.min.css.md`
2. ✅ `custom.css.md`
3. ✅ `theme.css.md`
4. ✅ `portalbasictheme.css.md`
5. ✅ `hide-draft-timeline.js.md`
6. ✅ `PWAManifest.json.md`
7. ✅ `favicon.ico.md`
8. ✅ `Sherweb_Logo-Full_color_3000px_544px.png.md`
9. ✅ `Sherweb_Logo-White&Blue_3000px_544px.png.md`
10. ✅ `Logo-sm-64.png.md`
11. ✅ `knowledge-base-images.md` (covers all 4 KB images)
12. ✅ `freshdesk-home-photo-2.png.md`
13. ✅ `Cat-PC.png.md`
14. ✅ `GREY-(1).md`
15. ✅ `README.md` (this file)

**Total Documentation Files: 15**

---

## 🔮 Recommendations

### Performance
1. Consider bundling CSS files for production
2. Implement lazy loading for below-fold images
3. Create responsive image sets (srcset) for large logos
4. Enable caching for static assets

### Maintenance
1. **Do not manually edit** portalbasictheme.css (auto-generated)
2. Document changes to custom.css and theme.css
3. Keep JavaScript console logging for troubleshooting
4. Update PWA manifest when branding changes

### Accessibility
1. Continue supporting bilingual interface
2. Maintain high contrast mode support
3. Test focus states regularly
4. Verify WCAG AA compliance for new colors

### Future Enhancements
1. Consider additional icon sizes for PWA (192px, maskable)
2. Add service worker for offline functionality
3. Implement dark mode using CSS variables
4. Create component library documentation

---

## 📞 Support & Maintenance

### When Making Changes

#### To CSS
1. Use `custom.css` for new overrides
2. Update `theme.css` for major feature additions
3. Never edit `portalbasictheme.css` manually
4. Test across all breakpoints

#### To JavaScript
1. Maintain console logging for debugging
2. Test with dynamic content loading
3. Verify MutationObserver performance
4. Consider edge cases (missing containers)

#### To Images
1. Maintain aspect ratios
2. Optimize file sizes
3. Update alt text in templates
4. Test on various devices

#### To PWA Manifest
1. Update icon files first
2. Clear browser cache after changes
3. Test installation on multiple platforms
4. Verify splash screen appearance

---

**Documentation Completed**: December 3, 2025
**Total Files Documented**: 17 web files
**Total Documentation Pages**: 15 markdown files
**Portal**: Sherweb Client Portal (Power Pages)
