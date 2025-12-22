# KB Category Widget Top 5 Web Template

## Overview
A styled knowledge base widget displaying two columns: "Popular Articles" (sorted by view count) and "New Articles" (sorted by creation date). Each column shows the top 5 articles with custom styling and links to the full knowledge base.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\kbcategorywidgettop5\`

## Configuration
- **Template ID**: `7c501be7-6ba0-f011-bbd2-7ced8d654a73`
- **Template Name**: `KBCategoryWidgetTop5`
- **Language**: English (United States)
- **Language Locale ID**: `{56940b3e-300f-4070-a559-5a6a4d11a8a3}`

## Custom Code

### CSS Styling

**Custom Font Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;700&display=swap');
```

**Container Styling:**
```css
.kb-articles-container {
  font-family: 'Montserrat', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

**Article Card Design:**
```css
.kb-article-card {
  background: #dff0ff;  /* Light blue background */
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  padding: 24px 48px;
  height: 100%;
  transition: box-shadow 0.3s ease;
}

.kb-article-card:hover {
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}
```

**Typography:**
```css
.kb-article-card h2 {
  font-family: 'Montserrat', sans-serif;
  font-weight: 700;
  font-size: 32px;
  margin-bottom: 24px;
  color: #1a1a1a;
  text-align: center;
}
```

**List Items:**
```css
.kb-article-card .list-group-item {
  border: none;
  padding: 12px 0;
  background: transparent;
}

.kb-article-card .list-group-item a {
  color: #333;
  text-decoration: none;
  font-weight: 400;
  transition: color 0.2s ease;
}

.kb-article-card .list-group-item a:hover {
  color: #e74c3c;  /* Red hover state */
}
```

**View All Button:**
```css
.kb-view-all-btn {
  display: block;
  width: 100%;
  margin-top: 24px;
  padding: 12px 24px;
  font-family: 'Montserrat', sans-serif;
  font-weight: medium;
  font-size: 16px;
  color: #db4227;
  background-color: transparent;
  border: 1px solid #ed573c;
  border-radius: 8px;
  text-align: center;
  transition: all 0.3s ease;
}

.kb-view-all-btn:hover {
  color: #db4227;
  background-color: #fee6e2;  /* Light red/orange background on hover */
  border-color: #ed573c;
}
```

**Badge Visibility:**
```css
.kb-article-card .badge {
  visibility: hidden;  /* Hides view count/date badges */
}
```

### FetchXML Queries

**1. Popular Articles Query:**
```xml
<fetch top="5">
  <entity name="knowledgearticle">
    <attribute name="knowledgearticleid" />
    <attribute name="title" />
    <attribute name="articlepublicnumber" />
    <attribute name="knowledgearticleviews" />
    <filter type="and">
      <condition attribute="statecode" operator="eq" value="3" />  <!-- Published -->
      <condition attribute="isrootarticle" operator="eq" value="0" />
      <condition attribute="isinternal" operator="eq" value="0" />
      <condition attribute="languagelocaleid" operator="eq" value="{56940b3e-300f-4070-a559-5a6a4d11a8a3}" />
    </filter>
    <order attribute="knowledgearticleviews" descending="true" />
  </entity>
</fetch>
```

**2. New Articles Query:**
```xml
<fetch top="5">
  <entity name="knowledgearticle">
    <attribute name="knowledgearticleid" />
    <attribute name="title" />
    <attribute name="articlepublicnumber" />
    <attribute name="createdon" />
    <filter type="and">
      <condition attribute="statecode" operator="eq" value="3" />  <!-- Published -->
      <condition attribute="isrootarticle" operator="eq" value="0" />
      <condition attribute="isinternal" operator="eq" value="0" />
      <condition attribute="languagelocaleid" operator="eq" value="{56940b3e-300f-4070-a559-5a6a4d11a8a3}" />
    </filter>
    <order attribute="createdon" descending="true" />
  </entity>
</fetch>
```

### HTML Structure

**Two-Column Layout:**
```html
<div class="container mt-5 kb-articles-container">
  <div class="row g-4">
    <!-- Popular Articles Column -->
    <div class="col-md-6">
      <div class="kb-article-card">
        <h2>Popular Articles</h2>
        <ul class="list-group list-group-flush">
          {% for article in popular_articles limit:5 %}
            <li class="list-group-item">
              <a href="{{ article.url | escape }}">
                <i class="fa-light fa-file"></i>
                <span>{{ article.title }}</span>
                <span class="badge bg-secondary ms-auto">{{ article.knowledgearticleviews }}</span>
              </a>
            </li>
          {% endfor %}
        </ul>
        <a href="/knowledge-base/" class="kb-view-all-btn">See all articles</a>
      </div>
    </div>

    <!-- New Articles Column -->
    <div class="col-md-6">
      <div class="kb-article-card">
        <h2>New Articles</h2>
        <ul class="list-group list-group-flush">
          {% for article in top_articles limit:5 %}
            <li class="list-group-item">
              <a href="{{ article.url | escape }}">
                <i class="fa-light fa-file"></i>
                <span>{{ article.title }}</span>
                <span class="badge bg-secondary ms-auto">{{ article.createdon | date: "%Y-%m-%d" }}</span>
              </a>
            </li>
          {% endfor %}
        </ul>
        <a href="/knowledge-base/" class="kb-view-all-btn">See all articles</a>
      </div>
    </div>
  </div>
</div>
```

### Key Features

1. **Popular Articles:**
   - Sorted by `knowledgearticleviews` (descending)
   - Displays view count (hidden via CSS)
   - Top 5 most viewed articles

2. **New Articles:**
   - Sorted by `createdon` (descending)
   - Displays creation date in YYYY-MM-DD format (hidden via CSS)
   - Top 5 most recent articles

3. **Design Elements:**
   - Light blue card background (#dff0ff)
   - Rounded corners (16px border-radius)
   - Hover effects with enhanced shadow
   - Custom button with Sherweb brand colors

4. **Typography:**
   - Montserrat font family
   - Bold 32px headings
   - Medium weight body text
   - Font smoothing for better rendering

5. **Icons:**
   - FontAwesome Light file icons
   - Consistent spacing with gap utilities

6. **Responsive:**
   - Two-column layout on medium+ screens
   - Stacks to single column on mobile
   - Bootstrap gap utilities (g-4)

7. **Filtering:**
   - Published articles only (statecode = 3)
   - Excludes root articles
   - Excludes internal articles
   - English language only

## Usage

**Include in Page:**
```liquid
{% include 'KBCategoryWidgetTop5' %}
```

Typically used on:
- Homepage
- Knowledge base landing page
- Dashboard pages

## Related Components

- **Entities:**
  - `knowledgearticle` - KB articles with view tracking

- **URLs:**
  - `/knowledge-base/` - Main KB page link

- **External Resources:**
  - Google Fonts (Montserrat)
  - FontAwesome Light icons

- **Related Templates:**
  - `KBCategoryWidget` - Full category hierarchy view
  - `KBCategoryWidget - FR` - French language variant
  - `KBCategoryWidgetTop5 - FR` - French variant of this template

## Change History
- Implemented dual-column layout for Popular/New articles
- Custom card design with light blue background
- Montserrat font integration for consistent branding
- View count and date badge functionality (currently hidden)
- Hover effects on cards and links
- Custom "See all articles" button styling with Sherweb brand colors
- Limited to top 5 articles per category
- Bootstrap 5 responsive grid implementation
- FontAwesome Light icon integration
