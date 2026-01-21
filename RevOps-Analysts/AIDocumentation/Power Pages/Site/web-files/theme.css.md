# theme.css - Extended Portal Theme Customizations

## Overview
Comprehensive theme customization file extending the Bootstrap v3.3.6 framework with custom Sherweb portal styling. This file contains extensive customizations for layout, navigation, typography, components, and responsive design patterns specific to the Sherweb client portal implementation.

## Location
`/web-files/theme.css`
- **Web File ID**: 782ea4e5-6036-46d9-ad14-d6a1a47d7a81
- **Parent Page ID**: 60419c17-9d55-4eb3-b9d8-a0f182dc38e2
- **Display Order**: 2
- **MIME Type**: text/css

## Configuration
- **Publishing State**: Published (81c6631c-ca6b-4b35-8228-8e759104c26e)
- **Excluded from Search**: Yes
- **Hidden from Sitemap**: No
- **Tracking Enabled**: No

## Foundation
**Based on**: Bootstrap v3.3.6 (http://getbootstrap.com)
**License**: MIT License
**Copyright**: 2011-2015 Twitter, Inc.

## Major Style Categories

### 1. Typography Enhancements

#### Underlined Headers
```css
h1.underline, h4.underline {
  border-bottom: 1px solid #bcbcbc;
  padding-bottom: 21px;
}
```

#### Body & Base Styles
```css
body {
  padding-top: 0px;
  margin: 0;
  height: 100%;
  color: #000000;
}
```

#### Heading Styles
- **H1**: 36px, bold, no left/right margin
- **H2**: 28px, font-weight 600
- **H3**: 24px, font-weight 600
- **Color**: Unset (inherits from parent)

#### Paragraph Styles
- **Base**: 16px font size
- Consistent with page design system

### 2. Navigation Components

#### Fixed Top Navbar
```css
.fixed-top {
  border-width: 0;
}
.fixed-top.navbar {
  min-height: 67px;
}
.fixed-top.navbar .navbar-collapse {
  max-height: 510px;
  box-shadow: none;
  border-top: none;
  padding-top: 8px;
}
```

#### Static Top Navbar
```css
.static-top {
  border-width: 0;
  margin-bottom: 0;
  position: sticky;
  top: 0;
  z-index: 9;
}
```
**Features**: Sticky positioning, no border, z-index 9

#### Navbar Dark Theme
```css
.static-top.navbar-dark {
  background-color: #ffffff;
  border-color: transparent;
}
```
**Note**: White background despite "dark" class name

#### Navigation Link Styles
```css
.navbar-dark .navbar-nav > li > a {
  color: #000;
}
.navbar-dark .navbar-nav > li > a:hover {
  color: #fff;
  background-color: #302ce1;  /* Purple-blue on hover */
}
.navbar-dark .navbar-nav > li > a:focus {
  color: #fff;
  background-color: #302ce1;
  border: 1px dashed black !important;
  outline: 1px dashed #ffffff;
}
```
**Hover Color**: #302ce1 (Purple-blue)
**Focus Styling**: Dashed border for accessibility

#### Logo Container
```css
.logo-container {
  height: 51px;
  width: 187px;
  margin-left: 9px;
}
```

### 3. Button Styles

#### Large Home Buttons
```css
.btn-lg-home {
  padding: 20px 40px;
  font-size: 15px;
}
```

#### Info Style Home Buttons
```css
.btn-info-home {
  color: #fff;
  border-color: #fff;
  background: transparent;
}
.btn-info-home:hover {
  color: #000;
  border-color: #000;
  background: #fff;
}
```
**Behavior**: Transparent → White fill on hover

#### Default/Secondary Buttons
```css
.btn-default, .btn-secondary {
  color: #302ce1;  /* Purple-blue */
  background-color: white;
  border-color: #302ce1;
}
.btn-default:hover {
  color: #302ce1;
  background-color: #f2f2f2;  /* Light gray on hover */
  border-color: #302ce1;
}
```

#### Primary Buttons
```css
.btn-primary {
  color: white;
  background-color: #302ce1;  /* Purple-blue */
  border-color: #302ce1;
}
.btn-primary:hover {
  color: white;
  background-color: #5c59e7;  /* Lighter purple-blue */
  border-color: #5c59e7;
}
```

### 4. Breadcrumb Styling
```css
.breadcrumb > li a {
  color: #302ce1;  /* Purple-blue links */
  padding: 2px 4px;
}
.breadcrumb > li a:hover {
  color: #302ce1;
}
```

### 5. Pagination Styles
```css
.pagination > li > a,
.pagination > li > span {
  background-color: transparent;
  border: 0px;
  margin-left: 10px;
  width: 40px;
  height: 40px;
  text-align: center;
}
.pagination > .active > a {
  border-color: transparent;
  border-radius: 50%;  /* Circular active page */
  border: solid 1px;
}
```
**Design**: Transparent background, circular active indicator

### 6. Complex Page Sections

#### Landing Sections
```css
.section-landing {
  background: linear-gradient(transparent, transparent);
  background-size: cover;
}
.section-landing .row > div {
  margin-top: 80px;
}
.section-landing .row > div .section-landing-heading {
  font-size: 4rem;
  color: #fff;
}
```
**Responsive**: Font size scales to 16vw on screens <600px

#### Diagonal Sections
```css
.section-diagonal-left {
  -webkit-transform: skew(0deg, -1.3deg);
  transform: skew(0deg, -1.3deg);
  overflow: hidden;
  margin-top: -60px;
  margin-bottom: -20px;
}
.section-diagonal-left .section-diagonal-left-content {
  -webkit-transform: skew(0deg, 1.3deg);
  transform: skew(0deg, 1.3deg);
}
```
**Effect**: 1.3-degree skew for diagonal section edges

#### Search Section Header
```css
.section-search .header-search {
  padding-top: 40px;
  padding-bottom: 40px;
  margin-bottom: 40px;
  background-color: #eeeeee;
}
.section-search input {
  border-style: none;
  padding-left: 10px;
  height: 60px;
}
```

### 7. Card & Content Components

#### Card Styling
```css
.card {
  -webkit-box-shadow: 0 0px 0px transparent;
  box-shadow: 0 0px 0px transparent;
}
```
**Note**: Shadow disabled (0px transparent)

#### Content Home Lists
```css
.content-home .list-group-item {
  padding: 20px 0;
  font-size: 20px;
  background-color: transparent;
  border: 0;
  border-top: 1px solid #ddd;
}
.content-home .list-group-item img {
  margin-right: 25px;
}
```

#### Sidebar Home
```css
.sidebar-home {
  background-color: #eeeeee;
  border-top: 7px solid #0b80d0;  /* Blue accent border */
  margin-top: 36px;
  position: relative;
}
```

### 8. Poll Component
```css
.poll {
  background-color: #eeeeee;
  border-top: 7px solid #0b80d0;  /* Blue accent border */
  position: relative;
  padding-left: 15px;
  padding-right: 15px;
}
.poll .poll-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid #bcbcbc;
  padding-bottom: 5px;
}
```

### 9. Footer Styles
```css
footer {
  position: relative;
  color: #22221e;
}
footer .footer-top {
  width: 100%;
  min-height: 130px;
  background-color: #232222;  /* Dark gray */
  display: flex;
  align-items: center;
}
footer .footer-bottom {
  width: 100%;
  min-height: 68px;
  background-color: #d2d2ce;  /* Light gray */
  font-size: 14px;
  display: flex;
  align-items: center;
}
```

### 10. Navigation Sidebar
```css
.nav-sidebar .nav > li > a {
  padding: 4px 20px;
  color: #2f5fef;  /* Blue links */
  border-right: 2px solid #eeeeee;
}
.nav-sidebar .nav > li > a:hover,
.nav-sidebar .nav > li > a:focus {
  color: #232222;
  border-right: 2px solid #555555;
  background-color: transparent;
}
```
**Icons**: Uses Glyphicons for expand/collapse indicators

### 11. Tables
```css
.table.table-forms td {
  padding: 15px 8px;
}
.table.table-forms tbody tr:first-child td {
  border-top: none;
}
```

### 12. Color System

#### Primary Colors
- **#302ce1**: Purple-blue (primary interactive color)
- **#2f5fef**: Bright blue (links)
- **#0b80d0**: Accent blue (borders, highlights)
- **#232222**: Dark gray (footer, text)
- **#eeeeee**: Light gray (backgrounds)

#### Theme-Specific Classes
```css
.pr-color {
  color: #2f5fef;
}
.blue_border {
  padding-bottom: 10px;
  border-bottom: 7px solid #0b80d0;
}
```

#### Section Primary Color
```css
.sectionPrimaryColor {
  background-color: #302ce1;
  color: #ffffff;
}
```

### 13. Form Elements

#### CRM Entity Forms
```css
.crmEntityFormView,
.entitylist {
  background-color: #ffffff;
  color: #000000;
  border: 1px solid #f2f2f2;
}
```

#### Error Styling
```css
.help-block.error,
label.col-form-label.required:before {
  color: #a94442;  /* Red for errors */
}
```

### 14. Responsive Design

#### Mobile-Specific (<767px)
```css
@media (max-width: 767px) {
  body {
    padding-top: 0px;
  }
  .text_center-mobile {
    text-align: center;
  }
  .fixed-top.navbar > .container > .row > div {
    display: block;
  }
}
```

#### Tablet Breakpoint (<993px)
```css
@media screen and (max-width: 993px) {
  .section-landing h1 {
    font-size: 65px;
  }
  .article-title {
    margin-left: 0;
    text-align: center;
  }
}
```

#### Desktop Breakpoint (≥992px)
```css
@media (min-width: 992px) {
  .fix-navbar .register-bar {
    display: none;
  }
}
```

### 15. Accessibility Features

#### Skip to Content
```css
.skip-to-content a {
  padding: 10px 20px;
  position: absolute;
  top: -43px;
  left: 0px;
  color: #ffffff;
  border-radius: 2px;
  background: #742774;  /* Purple */
  transition: top 1s ease-out;
  z-index: 100;
}
.skip-to-content a:focus {
  top: 0px;
  transition: top 0.1s ease-in;
}
```
**Behavior**: Hidden above viewport, slides down on focus

#### High Contrast Mode Support
```css
@media screen and (-ms-high-contrast: active) {
  .navbar-default .navbar-toggler .navbar-toggler-icon {
    background-color: #888;
  }
  .navbar-dark .navbar-toggler .navbar-toggler-icon {
    background-color: #fff;
  }
}
```

### 16. Special Components

#### Carousel Customization
```css
.carousel-custom .carousel-indicators li {
  border-color: #232222;
}
.carousel-custom .carousel-inner > .carousel-item .carousel-caption {
  display: flex;
  align-items: center;
  top: 5%;
  left: 5%;
  right: 5%;
}
```

#### Article Styling
```css
.article-title-container {
  border-top: solid 1px #bcbcbc;
  border-bottom: solid 1px #bcbcbc;
  padding-left: 15px;
  padding-top: 28px;
  padding-bottom: 28px;
}
.article-content > p {
  text-align: justify;
}
```

#### User Icon
```css
.user-icon {
  width: 16px;
  height: 16px;
  display: inline-block;
  margin-right: 7px;
}
```

### 17. Custom Layout Classes

#### Wrapper & Body Structure
```css
.wrapper-body {
  min-height: calc(100% - 132px);
  margin-bottom: 0px;
}
.footer .push {
  height: 43px;
}
```

#### Flex Container Customizations
```css
.custom-container {
  flex-wrap: wrap !important;
}
.custom-sitetitle {
  text-wrap: wrap;
}
.custom-navbar-toggler {
  margin-left: auto;
}
```

### 18. Nav Tabs
```css
.nav-tabs > li > a:hover,
.nav-tabs > li > a:focus {
  background-color: #f2f2f2;
  color: #302ce1;  /* Purple-blue */
}
```

### 19. Dropdown Menu Enhancements
```css
#navbar .dropdown-menu {
  margin-top: 8px;
}
#navbar .dropdown-search {
  padding-top: 0;
  background: transparent;
  border: 0;
  box-shadow: none;
  margin: 9px;
}
```

### 20. French Accessibility Link
```css
.frenchAccessibilityLink {
  float: right;
  width: 297px;
  height: 24px;
  font-family: Segoe UI;
  font-size: 18px;
  line-height: 21px;
  text-decoration-line: underline;
  color: #2c33d8;
}
```

### 21. Power Virtual Agent Styling
```css
.pva-floating-style {
  position: fixed;
  bottom: 0px;
  right: 0px;
  margin-right: 16px;
  margin-bottom: 18px;
  z-index: 9999;
}
```

## Key Design Patterns

### Interactive States
1. **Normal**: Base styling
2. **Hover**: Color/background changes (typically purple-blue #302ce1)
3. **Focus**: Dashed borders for keyboard navigation
4. **Active**: Maintained hover styles

### Spacing System
- **Sections**: 21px base unit
- **Large Margins**: 40px, 60px, 80px, 100px
- **Component Padding**: 15px, 20px, 25px

### Border System
- **Standard**: 1px solid #bcbcbc
- **Accent**: 7px solid #0b80d0 (blue accent borders)
- **Transparent**: 0px or transparent for borderless components

## Usage
This file works in conjunction with:
1. **bootstrap.min.css**: Base Bootstrap framework
2. **portalbasictheme.css**: Auto-generated theme styles
3. **custom.css**: Additional custom overrides

## Browser Compatibility
- Modern browsers (Chrome, Firefox, Safari, Edge)
- IE11 support via vendor prefixes (-webkit-, -moz-, -ms-)
- High contrast mode support for accessibility

## Related Components
- **bootstrap.min.css**: Base Bootstrap v3.3.6 framework
- **portalbasictheme.css**: Microsoft-generated theme
- **custom.css**: Targeted custom overrides
- **Navigation web templates**: Uses navbar classes
- **Layout web templates**: Uses section and wrapper classes

## Change History
- Based on Bootstrap v3.3.6 (MIT License)
- Custom Sherweb portal implementation
- Purple-blue accent color (#302ce1) as primary interactive color
- Extensive responsive design patterns
- Accessibility features (skip-to-content, high contrast support)
- French language support
- Power Virtual Agent integration styling
