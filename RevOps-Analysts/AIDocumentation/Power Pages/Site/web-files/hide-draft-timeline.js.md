# hide-draft-timeline.js - Draft Timeline Items Hiding Script

## Overview
JavaScript file that dynamically hides draft timeline entries from the portal's case/incident timeline view. Uses MutationObserver to continuously monitor the DOM for draft items and hide them as they appear, ensuring draft content remains hidden from portal users.

## Location
`/web-files/hide-draft-timeline.js`
- **Web File ID**: 06f3c955-296e-f011-b4cb-002248b3648e
- **Parent Page ID**: fae4d40d-9790-4e7e-067e-9a875b38f32b
- **Display Name**: Hide Draft Timeline JS
- **MIME Type**: application/octet-stream

## Configuration
- **Publishing State**: Published (81c6631c-ca6b-4b35-8228-8e759104c26e)
- **Excluded from Search**: No
- **Hidden from Sitemap**: No
- **Content Disposition**: 756150000

## Custom Code

### Script Initialization
```javascript
console.log("✅ Draft hiding script loaded");
```
**Purpose**: Confirms script has loaded successfully in browser console

### Main Function: hideDraftTimelineItems()
```javascript
function hideDraftTimelineItems() {
  const drafts = document.querySelectorAll('div.note[data-state="draft"]');
  console.log(`Found ${drafts.length} draft items`);
  drafts.forEach(function (el) {
    el.style.display = "none";
  });
}
```
**Purpose**: Finds and hides all draft timeline items
- **Selector**: `div.note[data-state="draft"]` - Targets note divs with draft state
- **Action**: Sets display to "none" for each draft element
- **Logging**: Reports number of draft items found

### MutationObserver Setup
```javascript
const observer = new MutationObserver(hideDraftTimelineItems);
```
**Purpose**: Creates an observer to watch for DOM changes and auto-hide new draft items

### Observer Initialization Function
```javascript
function startDraftObserver() {
  const notesContainer = document.querySelector('div[data-parent-entitylogicalname="incident"]');
  if (notesContainer) {
    console.log("✅ Notes container found. Starting observer...");
    hideDraftTimelineItems();
    observer.observe(notesContainer, { childList: true, subtree: true });
  } else {
    console.warn("⚠️ Notes container not found.");
  }
}
```
**Purpose**: Locates the incident timeline container and starts monitoring
- **Target Container**: `div[data-parent-entitylogicalname="incident"]`
- **Initial Hide**: Calls `hideDraftTimelineItems()` immediately on existing items
- **Observer Config**:
  - `childList: true` - Watch for added/removed child nodes
  - `subtree: true` - Watch entire subtree, not just direct children
- **Error Handling**: Warns if container not found

### Event Listener: Document Load
```javascript
document.addEventListener('DOMContentLoaded', function () {
  console.log("⏳ DOM ready. Waiting to start observer...");
  setTimeout(startDraftObserver, 1000);
});
```
**Purpose**: Initiates the draft hiding process after page load
- **Trigger**: Fires when DOM content is fully loaded
- **Delay**: 1000ms (1 second) timeout to ensure timeline is fully rendered
- **Action**: Calls `startDraftObserver()`

## Technical Implementation

### DOM Selectors
1. **Draft Items**: `div.note[data-state="draft"]`
   - Class: `note` (timeline note elements)
   - Attribute: `data-state="draft"` (draft status indicator)

2. **Timeline Container**: `div[data-parent-entitylogicalname="incident"]`
   - Identifies the parent container for incident (case) timeline
   - Used as the observation root for the MutationObserver

### Observer Pattern
- **MutationObserver**: Watches for changes in the DOM tree
- **Benefits**:
  - Automatically detects dynamically loaded content
  - Handles AJAX-loaded timeline items
  - No polling required - event-driven
  - Efficient performance with targeted observations

### Timing Strategy
1. **DOMContentLoaded**: Wait for initial DOM to be ready
2. **1-second Delay**: Allow time for Power Pages timeline component to initialize
3. **Initial Hide**: Process existing draft items
4. **Continuous Monitoring**: Watch for new items added dynamically

## Usage
This script is designed to run on pages with incident/case timelines, specifically:
- Case detail pages
- Any page displaying the timeline control for incidents

### Script Flow
1. Script loads and logs confirmation
2. Waits for DOM to be ready
3. Waits additional 1 second for timeline to render
4. Finds timeline container
5. Hides all existing draft notes
6. Starts observing for new draft notes
7. Automatically hides any new draft notes that appear

## Console Logging
The script provides detailed console output for debugging:

| Message | Meaning |
|---------|---------|
| ✅ Draft hiding script loaded | Script file successfully loaded |
| ⏳ DOM ready. Waiting to start observer... | DOM loaded, starting timer |
| ✅ Notes container found. Starting observer... | Timeline found, observer active |
| Found X draft items | Number of draft items detected |
| ⚠️ Notes container not found. | Timeline container missing (wrong page or not loaded) |

## Business Logic
- **Privacy**: Prevents portal users from seeing internal draft notes
- **Workflow**: Draft notes are for internal review before publishing
- **User Experience**: Portal users only see published/approved timeline entries

## Performance Considerations
- Observer only watches the timeline container, not the entire document
- Uses efficient CSS selector for draft detection
- Minimizes DOM manipulation (only hides, doesn't remove elements)
- 1-second delay balances reliability with speed

## Browser Compatibility
- **MutationObserver**: Supported in all modern browsers (IE11+, Chrome, Firefox, Safari, Edge)
- **querySelector/querySelectorAll**: Universal support
- **Arrow Functions**: Avoided for broader compatibility (uses function expressions)

## Related Components
- **Timeline Control**: Power Pages timeline component for cases/incidents
- **Note/Activity Entities**: Dynamics 365 notes with state attributes
- **Case Detail Pages**: Pages displaying incident timelines
- **Web Templates**: Timeline rendering templates

## Change History
- Implements MutationObserver pattern for dynamic content handling
- Uses data attributes for reliable draft detection
- Includes comprehensive console logging for troubleshooting
- 1-second delay ensures timeline component initialization
