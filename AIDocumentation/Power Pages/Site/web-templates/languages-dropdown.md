# Languages Dropdown Web Template

## Overview
A simple dropdown menu template that displays available language options for the current page, ordered alphabetically by language name.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\languages-dropdown\`

## Configuration
- **Template Name**: `Languages Dropdown`
- **Used In**: Header navigation

## Custom Code

### Liquid Template

```liquid
<ul class="dropdown-menu" role="menu">
  {% assign ordered_languages = page.languages | order_by: "name" %}
  {% for language in ordered_languages %}
    <li role="menuitem">
      <a class="dropdown-item" 
         href="/{{ language.url_substitution }}" 
         title="{{ language.name }}" 
         data-code="{{ language.code }}">
        {{ language.name }}
      </a>
    </li>
  {% endfor %}
</ul>
```

### Key Features

1. **Alphabetical Ordering:**
   - Languages sorted by name using `order_by` filter
   - Consistent display across all pages

2. **URL Substitution:**
   - Uses `language.url_substitution` for language-specific URLs
   - Maintains current page context in different language
   - Format: `/{{ language.url_substitution }}`

3. **Language Properties:**
   - `language.name` - Display name (e.g., "English", "Français")
   - `language.code` - Language code (e.g., "en-US", "fr-FR")
   - `language.url_substitution` - URL path for language

4. **Data Attributes:**
   - `data-code="{{ language.code }}"` - Stored for JavaScript access

5. **Accessibility:**
   - `role="menu"` on list
   - `role="menuitem"` on items
   - Title attribute for tooltips

6. **Bootstrap Integration:**
   - `.dropdown-menu` class for styling
   - `.dropdown-item` class for links

## Usage

**Header Integration:**
```liquid
{% if website.languages.size > 1 %}
  <li class="nav-item dropdown">
    <a class="nav-link dropdown-toggle" 
       href="#" 
       data-bs-toggle="dropdown">
      <span class="drop_language">{{ website.selected_language.name }}</span>
    </a>
    {% include 'Languages Dropdown' %}
  </li>
{% endif %}
```

### Example Output

**HTML:**
```html
<ul class="dropdown-menu" role="menu">
  <li role="menuitem">
    <a class="dropdown-item" 
       href="/en-US" 
       title="English" 
       data-code="en-US">
      English
    </a>
  </li>
  <li role="menuitem">
    <a class="dropdown-item" 
       href="/fr-FR" 
       title="Français" 
       data-code="fr-FR">
      Français
    </a>
  </li>
</ul>
```

## Related Components

- **Web Templates:**
  - `Header` - Includes this template

- **Page Properties:**
  - `page.languages` - Available languages for page
  - `website.selected_language` - Current language
  - `website.languages` - All site languages

- **Bootstrap:**
  - Dropdown menu styling
  - Dropdown item styling

## Change History
- Alphabetical sorting by language name
- URL substitution for language switching
- Data attribute for language code
- Accessibility roles (menu/menuitem)
- Bootstrap 5 compatible styling

## Recommendations
- Consider adding language flag icons
- Could cache ordered languages for performance
- Consider adding active state for current language
