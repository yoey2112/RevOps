# Knowledge Base Image Series - Homepage and Category Images

## Overview
Series of four JPG images used throughout the Knowledge Base sections of the Power Pages portal. These images provide visual context for knowledge base articles, categories, and homepage elements.

---

## Knowledge-Base.jpg

### Location
`/web-files/Knowledge-Base.jpg`
- **Web File ID**: 74addde7-a489-4640-abac-6669ae4a0f84
- **Parent Page ID**: 60419c17-9d55-4eb3-b9d8-a0f182dc38e2
- **Partial URL**: Knowledge-Base.jpg
- **MIME Type**: image/jpeg

### Configuration
- **Publishing State**: Published
- **Excluded from Search**: No
- **Hidden from Sitemap**: No
- **Tracking Enabled**: No

---

## Knowledge-Base-2.jpg

### Location
`/web-files/Knowledge-Base-2.jpg`
- **Web File ID**: 157145f6-5845-4434-933c-e9d46bef2480
- **Parent Page ID**: 60419c17-9d55-4eb3-b9d8-a0f182dc38e2
- **Partial URL**: Knowledge-Base-2.jpg
- **MIME Type**: image/jpeg

### Configuration
- **Publishing State**: Published
- **Excluded from Search**: No
- **Hidden from Sitemap**: No
- **Tracking Enabled**: No

---

## Knowledge-Base-3.jpg

### Location
`/web-files/Knowledge-Base-3.jpg`
- **Web File ID**: 8ba73a17-acf2-4a7c-8113-5f28d7663df7
- **Parent Page ID**: 60419c17-9d55-4eb3-b9d8-a0f182dc38e2
- **Partial URL**: Knowledge-Base-3.jpg
- **MIME Type**: image/jpeg

### Configuration
- **Publishing State**: Published
- **Excluded from Search**: No
- **Hidden from Sitemap**: No
- **Tracking Enabled**: No

---

## Knowledge-Base-4.jpg

### Location
`/web-files/Knowledge-Base-4.jpg`
- **Web File ID**: 1519f796-ef08-4043-908a-1289c88f7d5f
- **Parent Page ID**: 60419c17-9d55-4eb3-b9d8-a0f182dc38e2
- **Partial URL**: Knowledge-Base-4.jpg
- **MIME Type**: image/jpeg

### Configuration
- **Publishing State**: Published
- **Excluded from Search**: No
- **Hidden from Sitemap**: No
- **Tracking Enabled**: No

---

## Common Usage Patterns

### Knowledge Base Homepage
```html
<div class="section-knowledge">
  <img src="/Knowledge-Base.jpg" alt="Knowledge Base" class="img-responsive">
</div>
```

### Category Grid/Cards
```html
<div class="cards-container">
  <div class="card">
    <img src="/Knowledge-Base-2.jpg" alt="Category 1">
    <div class="card-body">
      <h3>Category Title</h3>
    </div>
  </div>
  <div class="card">
    <img src="/Knowledge-Base-3.jpg" alt="Category 2">
    <div class="card-body">
      <h3>Category Title</h3>
    </div>
  </div>
</div>
```

### Media Objects
```css
.section-search .media .media-left > img {
  max-width: 240px;
}
```

## Image Series Purpose

### Knowledge-Base.jpg
- Primary knowledge base landing image
- Hero section or main banner
- Homepage knowledge base section

### Knowledge-Base-2.jpg
- Category or article preview image
- Secondary sections
- Grid/card layouts

### Knowledge-Base-3.jpg
- Additional category or article image
- Multi-column layouts
- Visual variety in listings

### Knowledge-Base-4.jpg
- Fourth category or article image
- Completing grid layouts (2×2, 4-column)
- Visual diversity

## Technical Specifications
- **Format**: JPEG (optimized for photographs)
- **Purpose**: Visual content for knowledge base
- **Responsive**: Used with Bootstrap responsive image classes
- **Loading**: Consider lazy loading for below-fold images

## CSS Classes Applied

### Responsive Images
```css
.img-responsive {
  max-width: 100%;
  height: auto;
  display: block;
}
```

### Section-Specific Styling
```css
.section-knowledge {
  margin-bottom: 40px;
}

.section-search .header-search img {
  max-width: 350px;
}
```

## Usage Locations

### Homepage Sections
- Knowledge base section preview
- Feature highlights
- Category navigation

### Search Results
- Visual accompaniment to search results
- Article previews
- Media objects in listings

### Category Pages
- Category headers
- Navigation tiles
- Visual organization

### Article Lists
- Article thumbnails
- Preview images
- Grid layouts

## Implementation Example
```html
<!-- Homepage knowledge base section -->
<section class="section-knowledge">
  <div class="container">
    <div class="row">
      <div class="col-md-3">
        <a href="/kb/category1">
          <img src="/Knowledge-Base.jpg" alt="Getting Started">
          <h4>Getting Started</h4>
        </a>
      </div>
      <div class="col-md-3">
        <a href="/kb/category2">
          <img src="/Knowledge-Base-2.jpg" alt="Account Management">
          <h4>Account Management</h4>
        </a>
      </div>
      <div class="col-md-3">
        <a href="/kb/category3">
          <img src="/Knowledge-Base-3.jpg" alt="Billing & Payments">
          <h4>Billing & Payments</h4>
        </a>
      </div>
      <div class="col-md-3">
        <a href="/kb/category4">
          <img src="/Knowledge-Base-4.jpg" alt="Technical Support">
          <h4>Technical Support</h4>
        </a>
      </div>
    </div>
  </div>
</section>
```

## Responsive Behavior

### Desktop (≥992px)
- Full-size images in grid layouts
- 4-column layouts possible
- Max-width constraints maintained

### Tablet (768px-991px)
- 2-column or 3-column grids
- Images scale proportionally
- Maintain aspect ratios

### Mobile (<768px)
- Single column stacking
- Full-width images
- Vertical scrolling

## Accessibility Considerations
- Always include descriptive alt text
- Alt text should describe image content or purpose
- Consider using figure/figcaption for context
- Ensure images are not sole conveyors of information

## Performance Optimization
- **Format**: JPEG for photographs (good compression)
- **Lazy Loading**: Use for images below the fold
- **Responsive Images**: Consider srcset for different resolutions
- **Compression**: Ensure images are optimized

### Example Optimization
```html
<img src="/Knowledge-Base.jpg" 
     srcset="/Knowledge-Base-small.jpg 480w,
             /Knowledge-Base.jpg 1024w"
     sizes="(max-width: 768px) 100vw, 350px"
     alt="Knowledge Base"
     loading="lazy">
```

## Related Components
- **Knowledge base web pages**: KB article and category pages
- **Search templates**: Search result display
- **Homepage templates**: KB section on homepage
- **theme.css**: Image sizing and responsive rules

## SEO Considerations
- Use descriptive file names (already done: Knowledge-Base-X.jpg)
- Include alt text for image search
- Optimize file size for page speed
- Use structured data for articles if applicable

## Content Management
- 4-image series provides visual variety
- Consistent naming convention (Knowledge-Base-X.jpg)
- All published and searchable
- Part of knowledge base content strategy

## Change History
- Series of 4 images for knowledge base
- JPEG format for photographic content
- Published and accessible for search
- Consistent configuration across all 4 images
