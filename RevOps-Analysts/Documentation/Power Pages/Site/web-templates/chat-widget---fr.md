# Chat Widget - FR Web Template

## Overview
French language implementation of the Microsoft Dynamics 365 Omnichannel Chat Widget. Identical functionality to the English version with configuration for French-speaking users.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\chat-widget---fr\`

## Configuration
- **Template ID**: `c0a44f72-c326-f011-8c4d-7c1e5206727f`
- **Template Name**: `Chat Widget - FR`

## Custom Code

### External Dependencies
```html
<script src="https://kit.fontawesome.com/824c7bc1b6.js"></script>
```

### Omnichannel Configuration

**Active Configuration:**
```javascript
<script 
    v2 
    id="Microsoft_Omnichannel_LCWidget" 
    src="https://oc-cdn-public.azureedge.net/livechatwidget/scripts/LiveChatBootstrapper.js" 
    data-app-id="2b027e25-455d-4931-9819-901d480291d4" 
    data-lcw-version="prod" 
    data-org-id="536d3c28-6123-ef11-8406-6045bd5bd4f3" 
    data-org-url="https://m-536d3c28-6123-ef11-8406-6045bd5bd4f3.ca.omnichannelengagementhub.com"
    data-customization-callback="style"
    data-color-override="#ed573c"
    data-font-family-override="Montserrat, Arial">
</script>
```

**Previous Configuration (Commented Out):**
```javascript
<!-- Alternative configuration with different org-id -->
<!-- data-org-id="5bd79da4-af21-ef11-8407-0022486dacf1" -->
```

### Customization Function

**Chat Button Styling:**
```javascript
function style() {
    return {
        chatButtonProps: {
            controlProps: {
                hideChatTextContainer: true,
                id: "customChatButton"
            },
            styleProps: {
                generalStyleProps: {
                    minWidth: "60px",
                    width: "60px",
                    height: "60px"
                }
            },
            iconStyleProps: {
                width: "50px",
                height: "50px",
                cursor: "pointer",
                backgroundColor: "transparent",
                borderStyle: "none",
                margin: "0px"
            },
            headerProps: {
                headerTitleProps: {
                    text: "Chat with us"
                }
            }
        },
        loadingPaneProps: {
            controlProps: {
                titleText: "",
                subtitleText: "",
                hideSpinnerText: true,
                spinnerSize: 3
            }
        }
    };
}
```

**Icon Replacement:**
```javascript
setTimeout(() => {
    let chatButton = document.querySelector("#customChatButton");
    if (chatButton) {
        chatButton.innerHTML = '<i class="fas fa-comment" style="color: white; font-size: 40px;"></i>';
    }
}, 1000);
```

### Key Differences from English Version

**Configuration Differences:**
- **App ID**: `2b027e25-455d-4931-9819-901d480291d4` (FR) vs `12495120-70a5-49bb-908d-3f9eb30f72f4` (EN)
- **Organization ID**: `536d3c28-6123-ef11-8406-6045bd5bd4f3` (FR) vs `5bd79da4-af21-ef11-8407-0022486dacf1` (EN)

**Note:** The header text "Chat with us" is currently in English in both versions. This may be intentional or could be updated to "Chattez avec nous" for full French localization.

### Key Features

1. **Custom Button Design:**
   - 60x60px button size
   - Transparent background
   - FontAwesome comment icon (white, 40px)
   - Hidden text container (icon-only)

2. **Branding:**
   - Primary color override: `#ed573c` (Sherweb orange)
   - Font family: Montserrat, Arial

3. **Loading State:**
   - Custom loading pane with hidden spinner text
   - Spinner size: 3

4. **Integration:**
   - Microsoft Omnichannel v2
   - Production environment
   - Canada region engagement hub
   - French-language routing configuration

## Usage
This template is included in the Header template for authenticated and unauthenticated users when the site language is set to French (fr-FR).

**Header Integration:**
```liquid
{% assign locale = website.selected_language.code | downcase %}
{% if locale == "fr-fr" %}
  {% include 'Chat Widget - FR' %}
{% else %}
  {% include 'Chat Widget - EN' %}
{% endif %}
```

**Programmatic Trigger:**
```javascript
// From Header template
window.Microsoft.Omnichannel.LiveChatWidget.SDK.startChat()
```

## Related Components
- **Web Templates:**
  - `Header` (includes this template)
  - `Chat Widget - EN` (English language variant)

- **External Services:**
  - Microsoft Dynamics 365 Omnichannel for Customer Service
  - FontAwesome Kit

- **Configuration:**
  - App ID: `2b027e25-455d-4931-9819-901d480291d4`
  - Organization ID: `536d3c28-6123-ef11-8406-6045bd5bd4f3`
  - Engagement Hub: Canada region

## Change History
- Initial implementation with Omnichannel v2 for French language support
- Custom button styling with FontAwesome icons
- Organization configuration aligned with French support requirements
- Brand color customization (#ed573c)
- Font family override to match site design (Montserrat)
- Separate app configuration for French routing/agents
- 1-second delay for icon replacement to ensure DOM ready

## Recommendations
- Consider localizing the header text from "Chat with us" to "Chattez avec nous" for full French language support
- Ensure French-speaking agents are properly configured in the Omnichannel organization
