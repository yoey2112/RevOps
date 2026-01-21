# Power Virtual Agents Web Template

## Overview
Embeds the Microsoft Power Virtual Agents (PVA) chatbot into Power Pages using the embedded web chat SDK. Provides a floating chat interface with customizable styling.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\power-virtual-agents\`

## Configuration
- **Template Name**: `Power Virtual Agents`
- **Version**: V2.0
- **Input Parameter**: `bot_consumer_id` - GUID of the bot consumer record

## Custom Code

### Liquid Data Retrieval

```liquid
{% assign botconsumer = entities.adx_botconsumer[bot_consumer_id] %}
{% assign env = environment %}
{% assign languageCode = website.selected_language.code %}
{% assign botConfig = botconsumer.adx_configjson %}
```

### HTML Structure

```html
<div class='pva-floating-style'>
    <div name='webChat'></div>
    <script type='text/javascript' id='pvaChatInlineScript'>
        <!-- Inline JavaScript -->
    </script>
</div>
```

### JavaScript Implementation

**Dynamic Script Loading:**
```javascript
var script = document.createElement('script');
script.onload = function() {
    var botConfig = {{botConfig}};

    // Configuration retrieval
    const webChatHeaderStyleOptions = botConfig?.webChatHeaderStyleOptions;
    const webChatCanvasStyleOptions = botConfig?.webChatCanvasStyleOptions;
    const webChatWidgetStyleOptions = botConfig?.webChatWidgetStyleOptions;
    const botTitle = botConfig?.headerText;
    
    // Dimensions
    let chatWidth = "320px";
    let chatHeight = "480px";
    
    // Render Web Chat
    window.PvaEmbeddedWebChat.renderWebChat({
        "container": document.getElementsByName('webChat')[0],
        "botSchemaName": "{{ botconsumer.adx_botschemaname }}",
        "environmentId": "{{ env.Id }}",
        "width": chatWidth,
        "height": chatHeight,
        "client": "msportals",
        "version": "v1",
        "headerText": botTitle,
        "webChatCanvasStyleOptions": webChatCanvasStyleOptions,
        "webChatHeaderStyleOptions": webChatHeaderStyleOptions,
        "webChatWidgetStyleOptions": webChatWidgetStyleOptions,
        "accessibilityLanguage": "{{languageCode}}"
    });
}

// Load PVA SDK
script.src = "https://embed.powerva.microsoft.com/webchat/embedded.js?client=msportals&version=v1";
document.getElementsByTagName('head')[0].appendChild(script);
```

### Configuration Options

**Bot Configuration (`botConfig`):**
- Retrieved from `adx_botconsumer.adx_configjson` field
- JSON object containing:
  - `webChatHeaderStyleOptions` - Header styling
  - `webChatCanvasStyleOptions` - Canvas styling
  - `webChatWidgetStyleOptions` - Widget styling
  - `headerText` - Chat window title

**Render Options:**
```javascript
{
  container: DOM element,          // Target container
  botSchemaName: string,           // Bot identifier
  environmentId: string,           // Dataverse environment ID
  width: "320px",                  // Chat width
  height: "480px",                 // Chat height
  client: "msportals",             // Client identifier
  version: "v1",                   // SDK version
  headerText: string,              // Title text
  webChatCanvasStyleOptions: {},   // Canvas styles
  webChatHeaderStyleOptions: {},   // Header styles
  webChatWidgetStyleOptions: {},   // Widget styles
  accessibilityLanguage: string    // Language code
}
```

### Key Features

1. **Dynamic Loading:**
   - PVA SDK loaded asynchronously
   - Doesn't block page rendering
   - Script injected into page head

2. **Configuration Management:**
   - Bot configuration stored in Dataverse
   - Retrieved from `adx_botconsumer` entity
   - JSON-based configuration

3. **Environment Integration:**
   - Uses Dataverse environment ID
   - Bot schema name from bot consumer
   - Site language integration

4. **Customizable Styling:**
   - Header, canvas, and widget style options
   - Configured via bot consumer record
   - CSS-based customization

5. **Fixed Dimensions:**
   - Width: 320px
   - Height: 480px
   - Could be made configurable

6. **Accessibility:**
   - Language code passed to SDK
   - Supports localization
   - ARIA-compliant (provided by SDK)

7. **Version Control:**
   - Client: "msportals"
   - Version: "v1"
   - Enables future updates/changes

## Usage

**Include in Page:**
```liquid
{% assign bot_id = '<bot-consumer-guid>' %}
{% include 'Power Virtual Agents', bot_consumer_id: bot_id %}
```

**Bot Consumer Setup:**
1. Create `adx_botconsumer` record in Dataverse
2. Configure bot schema name
3. Set configuration JSON with styling options
4. Reference GUID in template include

**Example Configuration JSON:**
```json
{
  "headerText": "Virtual Assistant",
  "webChatHeaderStyleOptions": {
    "backgroundColor": "#ed573c",
    "color": "#ffffff"
  },
  "webChatCanvasStyleOptions": {
    "backgroundColor": "#f5f5f5"
  },
  "webChatWidgetStyleOptions": {
    "borderRadius": "8px"
  }
}
```

## Related Components

- **Entities:**
  - `adx_botconsumer` - Bot configuration record
    - `adx_botschemaname` - Bot identifier
    - `adx_configjson` - Styling configuration

- **Power Platform:**
  - Power Virtual Agents
  - Dataverse environment
  - Bot schema/registration

- **External SDK:**
  - `https://embed.powerva.microsoft.com/webchat/embedded.js`
  - Microsoft PVA Embedded Web Chat SDK

- **CSS Classes:**
  - `.pva-floating-style` - Container styling

- **Language:**
  - Uses `website.selected_language.code`
  - Supports multi-language bots

## Change History
- Version 2.0 implementation
- Dynamic script loading
- JSON configuration support
- Environment integration
- Accessibility language support
- Customizable styling options
- Fixed dimensions (320x480px)

## Recommendations
- Make dimensions configurable via bot config JSON
- Consider responsive sizing for mobile
- Add error handling for missing bot consumer
- Consider fallback UI if SDK fails to load
- Document available style options in bot consumer
- Add configuration validation
