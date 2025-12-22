# Header Web Template

## Overview
The main header navigation template for the Power Pages site. Provides responsive navigation, language switching, search functionality, user authentication controls, and a quick-access navigation bar with integrated chat widget.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\header\`

## Configuration
- **Template ID**: `8071a657-cc14-4e8b-83e1-e1b1c0e9a154`
- **Template Name**: `Header`

## Custom Code

### CSS Styling

**Quick Access Navigation Bar:**
- Sticky positioning at `top: 106.5px`
- Custom hover states with orangered accent color
- Responsive design with gap spacing
- Contact tooltip with arrow indicator
- Button styling for orange ghost buttons

**Key Style Classes:**
- `.quick-access` - Sticky navigation bar
- `.contact-tooltip` - Modal-style contact information display
- `.btn__orange_ghost` - Custom button styling
- Search results and pagination styling

### Liquid Template Components

**1. Navigation System:**
- Primary navigation from weblinks collection "Default"
- Dropdown menus with 2-level depth support
- Skip-to-content accessibility link
- Mobile responsive navbar toggle

**2. Search Integration:**
```liquid
{% assign search_enabled = settings['Search/Enabled'] | boolean | default:true %}
{% if search_enabled %}
  <!-- Search dropdown with icon -->
  {% include 'Search', search_id:'q' %}
{% endif %}
```

**3. Language Selector:**
```liquid
{% if website.languages.size > 1 %}
  <!-- Language dropdown -->
  {% include 'Languages Dropdown' %}
{% endif %}
```

**4. User Profile & Authentication:**
```liquid
{% if user %}
  <!-- Logged-in user dropdown with profile links -->
  {% assign show_profile_nav = settings["Header/ShowAllProfileNavigationLinks"] | boolean %}
  {% assign profile_nav = weblinks["Profile Navigation"] %}
{% else %}
  <!-- Sign-in link -->
{% endif %}
```

**5. Quick Access Bar (Authenticated & Unauthenticated):**

**For Authenticated Users:**
- Home
- Knowledge Base
- Create a new request
- View active requests
- Network Status (external link)
- Chat Widget (language-specific)

**For Unauthenticated Users:**
- Home
- Knowledge Base
- Open a new request
- Network Status (external link)
- Chat Widget (language-specific)

**Bilingual Support (EN/FR):**
```liquid
{% assign locale = website.selected_language.code | downcase %}
{% if locale == "fr-fr" %}
  <!-- French navigation items -->
  {% include 'Chat Widget - FR' %}
{% else %}
  <!-- English navigation items -->
  {% include 'Chat Widget - EN' %}
{% endif %}
```

### JavaScript Functionality

**1. Ticket Options Menu:**
```javascript
const handleTicketOptionsMenu = (e) => {
  e.preventDefault()
  e.currentTarget.classList.toggle('is-active')
}
```

**2. Chat Modal Trigger:**
```javascript
const handleTriggerChatModal = (e) => {
  e.preventDefault()
  window.Microsoft.Omnichannel.LiveChatWidget.SDK.startChat()
}
```

**3. Navbar Height Management:**
```javascript
function setHeight() {
  var windowHeight = window.innerHeight - 140;
  var navbar = document.getElementById("navbar");
  if (navbar) {
    navbar.style.maxHeight = windowHeight + "px";
  }
}
```

**4. Navigation Menu Reordering:**
- Removes first menu item
- Reorders navigation items programmatically
- Moves items to last/before-last positions

**5. IE Compatibility:**
```javascript
if (window.navigator.appName == "Microsoft Internet Explorer" 
    || window.navigator.userAgent.indexOf("Trident") > 0) {
  // IE-specific search element handling
}
```

### Search Section Substitution
```liquid
{% substitution %}
  <!-- Dynamic search section for Search and Forums pages -->
  {% if current_page == sr_page or current_page == forum_page %}
    <section class="page_section">
      {% include 'Search' search_id:'search_control' %}
    </section>
  {% endif %}
{% endsubstitution %}
```

## Usage
This template is included in the main page template/layout and renders on every page of the site. It provides:
- Site-wide navigation structure
- User authentication state management
- Language selection
- Search functionality
- Quick access to key features (KB, Tickets, Chat, Network Status)

## Related Components
- **Web Templates:**
  - `Chat Widget - EN`
  - `Chat Widget - FR`
  - `Search`
  - `Languages Dropdown`
  
- **Weblink Sets:**
  - `Default` (primary navigation)
  - `Profile Navigation`

- **Site Markers:**
  - `Search`
  - `Forums`
  - `Profile`

- **Site Settings:**
  - `Search/Enabled`
  - `Header/ShowAllProfileNavigationLinks`
  - `LanguageLocale/Code`

- **External Integration:**
  - Microsoft Omnichannel Chat Widget SDK
  - Network Status page (https://status.sherweb.com)

## Change History
- Quick access bar implementation with sticky positioning
- Bilingual support for English and French
- Chat widget integration with language-specific variants
- Custom styling for search results and navigation
- JavaScript menu reordering functionality
- Mobile-responsive navbar implementation
- Accessibility improvements with ARIA labels and skip-to-content
