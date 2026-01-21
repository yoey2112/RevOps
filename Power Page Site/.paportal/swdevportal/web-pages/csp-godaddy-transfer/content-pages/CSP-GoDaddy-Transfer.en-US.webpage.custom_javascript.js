document.addEventListener("DOMContentLoaded", function () {
  var consentPanel = document.getElementById("csp-consent-panel");
  var formPanel = document.getElementById("csp-form-panel");
  var ncePolicyCheckbox = document.getElementById("csp-nce-policy-checkbox");
  var consentCheckbox = document.getElementById("csp-consent-checkbox");
  var continueBtn = document.getElementById("csp-consent-continue");

  if (!consentPanel || !formPanel || !ncePolicyCheckbox || !consentCheckbox || !continueBtn) {
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

  // Function to check if all checkboxes are checked
  function updateContinueButton() {
    var allChecked = ncePolicyCheckbox.checked && consentCheckbox.checked;
    continueBtn.disabled = !allChecked;
    
    // Update button styling based on validation
    if (allChecked) {
      continueBtn.style.backgroundColor = "#f9a825"; // Orange color
      continueBtn.style.cursor = "pointer";
      continueBtn.style.opacity = "1";
    } else {
      continueBtn.style.backgroundColor = "#cccccc"; // Grey color
      continueBtn.style.cursor = "not-allowed";
      continueBtn.style.opacity = "0.6";
    }
    
    // Hide error message if all checked
    var errorMsg = document.getElementById("csp-consent-error");
    if (errorMsg && allChecked) {
      errorMsg.style.display = "none";
    }
  }

  // Add change listeners to both checkboxes
  ncePolicyCheckbox.addEventListener("change", updateContinueButton);
  consentCheckbox.addEventListener("change", updateContinueButton);
  
  // Initialize button state on page load
  updateContinueButton();

  // When user clicks Continue, validate and show form
  continueBtn.addEventListener("click", function (e) {
    e.preventDefault();

    // Check if both checkboxes are checked
    if (!ncePolicyCheckbox.checked || !consentCheckbox.checked) {
      // Show error message
      var errorMsg = document.getElementById("csp-consent-error");
      if (!errorMsg) {
        errorMsg = document.createElement("span");
        errorMsg.id = "csp-consent-error";
        errorMsg.style.cssText = "color: #d9534f; font-size: 14px; display: block; margin-top: 8px;";
        errorMsg.textContent = "Please confirm all requirements above before continuing.";
        continueBtn.parentNode.appendChild(errorMsg);
      }
      errorMsg.style.display = "block";
      return;
    }

    // Hide error message if it exists
    var errorMsg = document.getElementById("csp-consent-error");
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
