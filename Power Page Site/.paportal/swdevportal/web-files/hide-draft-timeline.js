console.log("✅ Draft hiding script loaded");

function hideDraftTimelineItems() {
  const drafts = document.querySelectorAll('div.note[data-state="draft"]');
  console.log(`Found ${drafts.length} draft items`);
  drafts.forEach(function (el) {
    el.style.display = "none";
  });
}

const observer = new MutationObserver(hideDraftTimelineItems);

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

document.addEventListener('DOMContentLoaded', function () {
  console.log("⏳ DOM ready. Waiting to start observer...");
  setTimeout(startDraftObserver, 1000);
});
