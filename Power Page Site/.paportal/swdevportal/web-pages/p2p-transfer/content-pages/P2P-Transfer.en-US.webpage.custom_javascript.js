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

  // Robustly update button state
  function updateContinueButton() {
    var consentCheckbox = document.getElementById("p2p-consent-checkbox");
    var continueBtn = document.getElementById("p2p-consent-continue");
    if (!consentCheckbox || !continueBtn) return;
    var isChecked = consentCheckbox.checked;
    continueBtn.disabled = !isChecked;
    if (isChecked) {
      continueBtn.style.backgroundColor = "#f9a825";
      continueBtn.style.cursor = "pointer";
      continueBtn.style.opacity = "1";
    } else {
      continueBtn.style.backgroundColor = "#cccccc";
      continueBtn.style.cursor = "not-allowed";
      continueBtn.style.opacity = "0.6";
    }
    var errorMsg = document.getElementById("p2p-consent-error");
    if (errorMsg && isChecked) {
      errorMsg.style.display = "none";
    }
  }

  // Listen for changes on the checkbox (event delegation for robustness)
  document.addEventListener("change", function (e) {
    if (e.target && e.target.id === "p2p-consent-checkbox") {
      updateContinueButton();
    }
  });

  // Initialize button state on page load
  updateContinueButton();

  // When user clicks Continue, validate and show form
  document.addEventListener("click", function (e) {
    if (e.target && e.target.id === "p2p-consent-continue") {
      e.preventDefault();
      var consentCheckbox = document.getElementById("p2p-consent-checkbox");
      var continueBtn = document.getElementById("p2p-consent-continue");
      if (!consentCheckbox.checked) {
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
      var errorMsg = document.getElementById("p2p-consent-error");
      if (errorMsg) {
        errorMsg.style.display = "none";
      }
      if (consentPanel && formPanel) {
        consentPanel.style.display = "none";
        formPanel.style.display = "block";
      }
      try {
        window.scrollTo({ top: 0, behavior: "smooth" });
      } catch (err) {
        window.scrollTo(0, 0);
      }
    }
  });
});
