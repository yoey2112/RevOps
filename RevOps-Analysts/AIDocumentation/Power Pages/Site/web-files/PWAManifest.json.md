# PWAManifest.json - Progressive Web App Configuration

## Overview
Web app manifest file that configures the Power Pages portal as a Progressive Web App (PWA), enabling installation on devices and defining the app's appearance when launched as a standalone application.

## Location
`/web-files/PWAManifest.json`
- **Web File ID**: 1a0234f5-9dfb-4d59-adb8-f4fb3a25e6ab
- **Parent Page ID**: 60419c17-9d55-4eb3-b9d8-a0f182dc38e2
- **MIME Type**: application/json

## Configuration
- **Publishing State**: Published (81c6631c-ca6b-4b35-8228-8e759104c26e)
- **Excluded from Search**: No
- **Hidden from Sitemap**: No
- **Tracking Enabled**: No

## Manifest Properties

```json
{
  "name": "clientportal",
  "short_name": "clientportal",
  "description": "clientportal",
  "display": "standalone",
  "start_url": "/",
  "scope": "/",
  "orientation": "any",
  "theme_color": "#000000",
  "background_color": "#ED573C",
  "icons": [
    {
      "src": "/PWALogo.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### Property Details

#### App Identity
- **name**: `"clientportal"` - Full application name displayed during installation
- **short_name**: `"clientportal"` - Short name displayed on home screen/launcher
- **description**: `"clientportal"` - App description for app stores and installation prompts

#### Display Configuration
- **display**: `"standalone"` 
  - Launches without browser UI (address bar, navigation buttons)
  - Appears as native application
  - Alternative values: `fullscreen`, `minimal-ui`, `browser`

#### Navigation Settings
- **start_url**: `"/"` - URL loaded when app launches (portal root)
- **scope**: `"/"` - Navigation scope; URLs outside this scope open in browser

#### Device Orientation
- **orientation**: `"any"` 
  - Allows all orientations (portrait, landscape, portrait-inverted, landscape-inverted)
  - Does not lock screen orientation

#### Theming
- **theme_color**: `"#000000"` (Black)
  - Colors the browser's UI elements (address bar on mobile)
  - Provides visual continuity with app theme
  
- **background_color**: `"#ED573C"` (Sherweb Orange/Red)
  - Splash screen background color during app launch
  - Matches primary brand color
  - Hex color: Orange-red (#ED573C)

#### App Icons
```json
"icons": [
  {
    "src": "/PWALogo.png",
    "sizes": "512x512",
    "type": "image/png"
  }
]
```
- **Single Icon Configuration**:
  - **Source**: `/PWALogo.png`
  - **Size**: 512x512 pixels (high resolution)
  - **Format**: PNG
  - **Usage**: Home screen icon, splash screen, app switcher

## PWA Features Enabled

### Installation
- Portal can be installed on:
  - Desktop (Windows, macOS, Linux)
  - Mobile (iOS, Android)
  - Chrome OS
- "Add to Home Screen" / "Install App" prompts available

### Standalone Experience
- Launches in dedicated window without browser chrome
- Full-screen application feel
- Native app-like experience

### App Launcher Integration
- Appears in device app launcher/drawer
- Searchable from system search
- Can be pinned to taskbar/dock

## Browser Support

### Desktop Browsers
- **Chrome/Edge**: Full support
- **Firefox**: Partial support (desktop installation available)
- **Safari**: Limited (iOS has better support)

### Mobile Browsers
- **Chrome Android**: Full support
- **Safari iOS**: Full support (Add to Home Screen)
- **Edge Mobile**: Full support
- **Firefox Android**: Partial support

## Color Scheme Analysis

### Theme Color: #000000 (Black)
- **Usage**: System UI theming
- **Effect**: Black status bar on mobile devices
- **Brand Alignment**: Professional, clean appearance

### Background Color: #ED573C (Sherweb Orange/Red)
- **RGB**: (237, 87, 60)
- **HSL**: (10°, 83%, 58%)
- **Usage**: Splash screen background
- **Brand Alignment**: Matches Sherweb primary brand color

## Installation Behavior

### Desktop Installation
1. User visits portal in Chrome/Edge
2. Browser shows install icon in address bar
3. User clicks to install
4. App installs and opens in standalone window
5. Icon appears on desktop/start menu

### Mobile Installation
1. User visits portal in mobile browser
2. Browser prompts "Add to Home Screen"
3. User confirms installation
4. Icon added to home screen
5. Tapping icon launches in standalone mode

## Technical Notes

### Minimum PWA Requirements Met
- ✅ Manifest file present
- ✅ HTTPS connection (required for PWA)
- ✅ Service worker (implied - separate configuration)
- ✅ Valid icons
- ✅ Start URL defined

### Icon Optimization Recommendations
Current configuration uses single 512x512 icon. Consider adding:
```json
"icons": [
  { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
  { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" },
  { "src": "/icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
]
```

## Usage
This manifest file is referenced in the portal's HTML `<head>` section:
```html
<link rel="manifest" href="/PWAManifest.json">
```

### Effect on User Experience
- **Discoverability**: Users can install the portal as an app
- **Engagement**: Standalone apps feel more native and professional
- **Access**: Quick access from home screen/app launcher
- **Branding**: Consistent brand colors during launch

## Related Components
- **PWALogo.png**: 512x512 app icon image (referenced in manifest)
- **Service Worker**: Enables offline functionality and caching
- **favicon.ico**: Browser tab icon (separate from PWA icons)
- **HTML Head Section**: Includes manifest link tag

## Change History
- Configured as standalone PWA application
- Single icon configuration (512x512)
- Sherweb brand colors applied (orange/red background, black theme)
- Allows any device orientation
- Root scope for full portal access
