document.addEventListener("DOMContentLoaded", function () {
  var consentPanel = document.getElementById("p2p-consent-panel");
  var formPanel = document.getElementById("p2p-form-panel");
  var consentCheckbox = document.getElementById("p2p-consent-checkbox");
  var continueBtn = document.getElementById("p2p-consent-continue");

  if (!consentPanel || !formPanel || !consentCheckbox || !continueBtn) {
    return;
  }

  // Check if form has been submitted (look for success/error messages within the form area)
  var formArea = formPanel || document.body;
  var hasSubmitMessage = formArea.querySelector('.notification.success, .notification.error, .alert-success, .alert-danger, .form-success, .form-error');
  
  // Only bypass consent if there's a visible submit message
  if (hasSubmitMessage && hasSubmitMessage.offsetParent !== null) {
    consentPanel.style.display = "none";
    formPanel.style.display = "block";
    return; // Exit early - don't set up consent handlers
  }

  // Function to check if checkbox is checked and update button state
  function updateContinueButton() {
    var isChecked = consentCheckbox.checked;
    continueBtn.disabled = !isChecked;
    
    // Update button styling based on validation
    if (isChecked) {
      continueBtn.style.backgroundColor = "#f9a825"; // Orange color
      continueBtn.style.cursor = "pointer";
      continueBtn.style.opacity = "1";
    } else {
      continueBtn.style.backgroundColor = "#cccccc"; // Grey color
      continueBtn.style.cursor = "not-allowed";
      continueBtn.style.opacity = "0.6";
    }
    
    // Hide error message if checked
    var errorMsg = document.getElementById("p2p-consent-error");
    if (errorMsg && isChecked) {
      errorMsg.style.display = "none";
    }
  }

  // Add change listener to checkbox
  consentCheckbox.addEventListener("change", updateContinueButton);
  
  // Initialize button state on page load
  updateContinueButton();

  // When user clicks Continue, validate and show form
  continueBtn.addEventListener("click", function (e) {
    e.preventDefault();

    // Check if checkbox is checked
    if (!consentCheckbox.checked) {
      // Show error message
      var errorMsg = document.getElementById("p2p-consent-error");
      if (!errorMsg) {
        errorMsg = document.createElement("span");
        errorMsg.id = "p2p-consent-error";
        errorMsg.style.cssText = "color: #d9534f; font-size: 14px; display: block; margin-top: 8px;";
        errorMsg.textContent = "Please confirm the requirement above before continuing.";
        continueBtn.parentNode.appendChild(errorMsg);
      }
      errorMsg.style.display = "block";
      return;
    }

    // Hide error message if it exists
    var errorMsg = document.getElementById("p2p-consent-error");
    if (errorMsg) {
      errorMsg.style.display = "none";
    }

    consentPanel.style.display = "none";
    formPanel.style.display = "block";

    // Scroll to top of page
    try {
      window.scrollTo({ top: 0, behavior: "smooth" });
    } catch (err) {
      // Fallback if smooth scroll not supported
      window.scrollTo(0, 0);
    }
  });
});
