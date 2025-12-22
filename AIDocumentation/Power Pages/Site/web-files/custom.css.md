# custom.css - Custom CSS Overrides

## Overview
Custom CSS file that provides targeted UI element hiding functionality for the Power Pages portal. This file implements specific visibility rules to control navigation and profile elements in both English and French languages.

## Location
`/web-files/custom.css`
- **Web File ID**: 037784a1-24e9-4ce2-835a-a45c0d77ca6c
- **Parent Page ID**: 60419c17-9d55-4eb3-b9d8-a0f182dc38e2
- **Display Order**: 3
- **MIME Type**: text/css

## Configuration
- **Publishing State**: Published (81c6631c-ca6b-4b35-8228-8e759104c26e)
- **Excluded from Search**: No
- **Hidden from Sitemap**: No
- **Tracking Enabled**: No

## Custom Code

### 1. Hide Redeem Invitation Links
```css
/* Hide Redeem invitation and Register */
li[role="none"] a[aria-label="Redeem invitation"],
li:has(a[aria-label="Redeem invitation"]),
li[role="none"] a[aria-label="Utiliser une invitation"],
li:has(a[aria-label="Utiliser une invitation"]),
```
**Purpose**: Hides the "Redeem invitation" menu items in both English and French
- Uses both direct attribute selector and `:has()` pseudo-class for comprehensive targeting
- Supports bilingual interface (English: "Redeem invitation", French: "Utiliser une invitation")

### 2. Hide Register Links
```css
li[role="none"] a[aria-label="Register"],
li:has(a[aria-label="Register"]),
li[role="none"] a[aria-label="S'inscrire"],
li:has(a[aria-label="S'inscrire"]) {
    display: none;
}
```
**Purpose**: Hides the "Register" menu items in both English and French
- Prevents user self-registration through the portal UI
- Supports bilingual interface (English: "Register", French: "S'inscrire")

### 3. Hide Profile Links
```css
/* Hide Profile */
a[aria-label="Profile"] {
    display: none;
}
li:has(> a[aria-label="Profile"]),
li:has(> a[aria-label="Profil"]),
li:has(> a[aria-label="Profile"]) + li.dropdown-divider,
li:has(> a[aria-label="Profil"]) + li.dropdown-divider {
    display: none;
}
```
**Purpose**: Completely hides profile-related navigation elements
- Hides the profile link itself
- Hides parent list items containing profile links
- Hides dropdown dividers that follow profile items
- Supports bilingual interface (English: "Profile", French: "Profil")

## CSS Selectors Used

### Attribute Selectors
- `[role="none"]` - Targets elements with role attribute set to "none"
- `[aria-label="value"]` - Targets elements by their ARIA label (accessibility label)

### Pseudo-classes
- `:has()` - Modern CSS selector for parent element selection
- `+` (Adjacent sibling combinator) - Selects elements immediately following specified elements

### Element Targeting Strategy
1. **Direct targeting**: Selects the element itself via attribute
2. **Parent targeting**: Uses `:has()` to hide container list items
3. **Sibling targeting**: Removes dividers adjacent to hidden elements

## Usage
This CSS file is automatically loaded on all portal pages and applies globally. The styles specifically target:

1. **User Account Menu**: Removes invitation redemption and registration options
2. **User Profile Menu**: Removes access to profile management
3. **Navigation Cleanup**: Removes orphaned dividers when menu items are hidden

## Business Rules Implemented
- **Controlled User Registration**: Users cannot self-register through the portal
- **Controlled Invitations**: Users cannot redeem invitations through the UI
- **Profile Access Control**: Profile management is hidden from end users
- **Bilingual Support**: All rules apply consistently in English and French

## Browser Compatibility Notes
- `:has()` pseudo-class is supported in modern browsers (Chrome 105+, Firefox 121+, Safari 15.4+)
- Fallback direct selectors are also included for broader compatibility

## Related Components
- **Navigation Templates**: Works with header navigation web templates
- **User Authentication**: Complements authentication and authorization settings
- **Language Settings**: Coordinates with bilingual portal configuration

## Change History
- Initial implementation includes bilingual support for English and French
- Uses modern CSS `:has()` selector for cleaner parent element targeting
- Implements comprehensive hiding strategy (element, parent, and sibling dividers)
