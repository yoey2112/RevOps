(function() {
  'use strict';
  
  const CONFIG = {
    fields: {
      cumulusAccount: "revops_cumulusaccount",
      transferOrgs: "revops_transferorgs",
      subject: "subjectid",
      service: "revops_service",
      title: "title",
      numberOfOrgs: "revops_oforganizations",
      origin: "caseorigincode",
      account: "customerid",
      competitorRegion: "revops_competitorregion",
      caseType: "casetypecode",
      revopsAccount: "revops_account",
      queue: "revops_queue",
      losingCompetitor: "revops_losingcompetitor",
      cspTransferId: "revops_csptransferid",
      losingProvider: "revops_losingprovider"
    },
    defaultValues: {
      origin: "3"
    },
    lookupEntities: {
      revops_competitorregion: "msdyn_region",
      revops_cumulusaccount: "revops_cumulusaccount",
      revops_account: "account",
      customerid: "account",
      subjectid: "subject",
      revops_service: "revops_service",
      revops_queue: "queue"
    }
  };
  
  function stripGuid(s) {
    return (s || "").replace(/[{}]/g, "");
  }
  
  function getAttribute(logicalName) {
    const selectors = [
      `[name="${logicalName}"]`,
      `#${logicalName}`,
      `[name$="${logicalName}"]`,
      `[id$="${logicalName}"]`,
      `input[name="${logicalName}"]`,
      `select[name="${logicalName}"]`,
      `textarea[name="${logicalName}"]`
    ];
    
    for (const selector of selectors) {
      const element = document.querySelector(selector);
      if (element) return element;
    }
    return null;
  }
  
  function getLookupGuid(logicalName) {
    const hidden = getAttribute(logicalName);
    if (hidden) {
      if (hidden.type === "hidden") return hidden;
      
      const possibleHiddenSelectors = [
        `input[type="hidden"][name="${logicalName}"]`,
        `input[type="hidden"][id="${logicalName}"]`,
        `#${logicalName}_id`,
        `[name="${logicalName}_id"]`
      ];
      
      for (const selector of possibleHiddenSelectors) {
        const hiddenField = document.querySelector(selector);
        if (hiddenField) return hiddenField;
      }
      
      if (hidden.tagName === 'SELECT' || hidden.tagName === 'INPUT') return hidden;
    }
    return null;
  }
  
  function getLookupName(logicalName) {
    const nameField = getAttribute(`${logicalName}_name`);
    if (nameField) return nameField;
    
    const alternativeSelectors = [
      `[name="${logicalName}_name"]`,
      `#${logicalName}_name`,
      `input[id*="${logicalName}"][id*="name"]`,
      `input[name*="${logicalName}"][name*="name"]`
    ];
    
    for (const selector of alternativeSelectors) {
      const field = document.querySelector(selector);
      if (field) return field;
    }
    return null;
  }
  
  function getLookupEntityInput(logicalName) {
    const candidates = [
      `input[type="hidden"][name="${logicalName}_entityname"]`,
      `input[type="hidden"][id="${logicalName}_entityname"]`,
      `input[type="hidden"][name="${logicalName}_type"]`,
      `input[type="hidden"][id="${logicalName}_type"]`,
      `[name="${logicalName}.EntityLogicalName"]`,
      `[id="${logicalName}.EntityLogicalName"]`
    ];
    
    for (const sel of candidates) {
      const el = document.querySelector(sel);
      if (el) return el;
    }
    return null;
  }
  
  function setTextField(logicalName, value) {
    const field = getAttribute(logicalName);
    if (field && (field.tagName === 'TEXTAREA' || field.tagName === 'INPUT')) {
      field.value = value || '';
      field.dispatchEvent(new Event('change', { bubbles: true }));
      return true;
    }
    return false;
  }
  
  function setLookupField(logicalName, id, name) {
    const hiddenField = getLookupGuid(logicalName);
    const nameField = getLookupName(logicalName);
    const entityField = getLookupEntityInput(logicalName);
    
    if (!hiddenField) return false;
    
    try {
      hiddenField.value = '';
      if (nameField) {
        nameField.value = '';
        nameField.removeAttribute('data-selected');
      }
      if (entityField) {
        entityField.value = '';
      }
      
      setTimeout(() => {
        hiddenField.value = id || '';
        hiddenField.setAttribute('value', id || '');
        hiddenField.dispatchEvent(new Event('change', { bubbles: true }));
        hiddenField.dispatchEvent(new Event('input', { bubbles: true }));
        
        if (nameField) {
          nameField.value = name || '';
          nameField.setAttribute('value', name || '');
          nameField.setAttribute('data-selected', 'true');
          nameField.dispatchEvent(new Event('input', { bubbles: true }));
          nameField.dispatchEvent(new Event('change', { bubbles: true }));
        }
        
        const entityLogical = (CONFIG.lookupEntities && CONFIG.lookupEntities[logicalName]) || null;
        if (entityField && entityLogical) {
          entityField.value = entityLogical;
          entityField.setAttribute('value', entityLogical);
          entityField.dispatchEvent(new Event('change', { bubbles: true }));
        }
        
        setTimeout(() => {
          if (hiddenField.value !== (id || '')) {
            hiddenField.value = id || '';
            hiddenField.setAttribute('value', id || '');
          }
          if (entityField && entityLogical && entityField.value !== entityLogical) {
            entityField.value = entityLogical;
            entityField.setAttribute('value', entityLogical);
          }
        }, 150);
      }, 100);
      
      return true;
    } catch (error) {
      console.warn('[P2P] setLookupField error for', logicalName, error);
      return false;
    }
  }
  
  function setOptionSetField(logicalName, value) {
    const field = getAttribute(logicalName);
    if (field && field.tagName === 'SELECT') {
      field.value = value || '';
      field.dispatchEvent(new Event('change', { bubbles: true }));
      return true;
    }
    return false;
  }
  
  function setNumberField(logicalName, value) {
    const field = getAttribute(logicalName);
    if (field) {
      field.value = value || 0;
      field.dispatchEvent(new Event('change', { bubbles: true }));
      field.dispatchEvent(new Event('input', { bubbles: true }));
      field.dispatchEvent(new Event('blur', { bubbles: true }));
      return true;
    }
    return false;
  }
  
  function loadOrgsData() {
    const dataScript = document.getElementById('p2p-orgs-data');
    if (!dataScript) return [];
    try {
      return JSON.parse(dataScript.textContent);
    } catch (error) {
      return [];
    }
  }
  
  function loadAccountsData() {
    const accountsScript = document.getElementById('p2p-accounts-data');
    if (!accountsScript) return [];
    try {
      return JSON.parse(accountsScript.textContent);
    } catch (error) {
      return [];
    }
  }
  
  function loadRegionsData() {
    const regionsScript = document.getElementById('p2p-regions-data');
    if (!regionsScript) return [];
    try {
      return JSON.parse(regionsScript.textContent);
    } catch (error) {
      return [];
    }
  }
  
  function loadConfigData() {
    const configScript = document.getElementById('p2p-config-data');
    if (!configScript) return null;
    try {
      return JSON.parse(configScript.textContent);
    } catch (error) {
      return null;
    }
  }
  
  function getOrgsByAccount(accountGuid) {
    const cleanGuid = stripGuid(accountGuid).toLowerCase();
    const allOrgs = loadOrgsData();
    return allOrgs.filter(org => {
      const orgAccountGuid = stripGuid(org.accountGuid || '').toLowerCase();
      return orgAccountGuid === cleanGuid;
    });
  }
  
  let modalInstance = null;
  let selectedOrgGuids = [];
  let currentAccountGuid = null;
  let currentParentAccountGuid = null;
  let currentParentAccountName = null;
  let currentRegionCode = null;
  
  function createOrgModal() {
    const existingModal = document.getElementById('p2p-org-modal');
    if (existingModal) {
      existingModal.remove();
      modalInstance = null;
    }
    
    const modalHtml = `
      <div class="modal fade" id="p2p-org-modal" tabindex="-1" aria-labelledby="p2pModalLabel">
        <div class="modal-dialog modal-lg modal-dialog-centered" style="margin: 3rem auto; max-height: calc(100vh - 6rem);">
          <div class="modal-content" style="max-height: calc(100vh - 6rem); display: flex; flex-direction: column;">
            <div class="modal-header" style="flex-shrink: 0;">
              <h5 class="modal-title" id="p2pModalLabel">Select Cumulus Organizations</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 0; display: flex; flex-direction: column; flex: 1; min-height: 0; overflow: hidden;">
              <div style="height: 1px; background-color: #dee2e6; flex-shrink: 0;"></div>
              <div id="p2p-org-loading" class="text-center py-4" style="flex: 1; display: flex; flex-direction: column; justify-content: center; align-items: center;">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Loading...</span>
                </div>
                <p class="mt-2 text-muted">Loading organizations...</p>
              </div>
              <div id="p2p-org-list" class="d-none" style="display: flex; flex-direction: column; flex: 1; overflow: hidden;">
                <div class="p-3 pb-2 border-bottom" style="flex-shrink: 0;">
                  <input type="text" class="form-control" id="p2p-org-search" placeholder="Search organizations..." aria-label="Search organizations">
                </div>
                <div class="d-flex align-items-center px-3 py-2 border-bottom" style="flex-shrink: 0;">
                  <input class="form-check-input me-2" type="checkbox" id="p2p-select-all" aria-label="Select all organizations">
                  <label class="form-check-label fw-bold mb-0" for="p2p-select-all">Select All</label>
                </div>
                <div id="p2p-org-checkboxes" style="flex: 1; overflow-y: auto; padding: 0.5rem 1rem;"></div>
              </div>
              <div id="p2p-org-empty" class="d-none alert alert-info m-3">
                No organizations available for transfer for this account.
              </div>
            </div>
            <div class="modal-footer">
              <span id="p2p-org-count" class="me-auto text-muted" role="status" aria-live="polite">0 selected</span>
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
              <button type="button" class="btn btn-primary" id="p2p-org-confirm">Confirm Selection</button>
            </div>
          </div>
        </div>
      </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', modalHtml);
    
    const modalElement = document.getElementById('p2p-org-modal');
    if (!modalElement || typeof bootstrap === 'undefined' || !bootstrap.Modal) {
      return null;
    }
    
    modalInstance = new bootstrap.Modal(modalElement, {
      backdrop: 'static',
      keyboard: true
    });
    
    const confirmBtn = document.getElementById('p2p-org-confirm');
    if (confirmBtn) {
      confirmBtn.addEventListener('click', confirmOrgSelection);
    }
    
    const selectAllCheckbox = document.getElementById('p2p-select-all');
    if (selectAllCheckbox) {
      selectAllCheckbox.addEventListener('change', handleSelectAll);
    }
    
    const searchInput = document.getElementById('p2p-org-search');
    if (searchInput) {
      searchInput.addEventListener('input', handleSearch);
    }
    
    return modalElement;
  }
  
  function showOrgModal(accountGuid, accountName) {
    if (!modalInstance) {
      const modalElement = createOrgModal();
      if (!modalElement || !modalInstance) {
        alert("Error: Could not create modal. Please refresh the page.");
        return;
      }
    }
    
    selectedOrgGuids = [];
    currentAccountGuid = accountGuid;
    updateOrgCount();
    
    const loadingDiv = document.getElementById('p2p-org-loading');
    const listDiv = document.getElementById('p2p-org-list');
    const emptyDiv = document.getElementById('p2p-org-empty');
    
    if (!loadingDiv || !listDiv || !emptyDiv) return;
    
    loadingDiv.classList.remove('d-none');
    listDiv.classList.add('d-none');
    emptyDiv.classList.add('d-none');
    
    modalInstance.show();
    
    setTimeout(() => {
      const orgs = getOrgsByAccount(accountGuid);
      if (orgs.length > 0) {
        currentParentAccountGuid = orgs[0].parentAccountGuid;
        currentParentAccountName = orgs[0].parentAccountName;
      }
      renderOrgList(orgs);
    }, 100);
  }
  
  function renderOrgList(orgs) {
    document.getElementById('p2p-org-loading').classList.add('d-none');
    
    if (!orgs || orgs.length === 0) {
      document.getElementById('p2p-org-empty').classList.remove('d-none');
      return;
    }
    
    const listContainer = document.getElementById('p2p-org-list');
    listContainer.classList.remove('d-none');
    
    const checkboxesContainer = document.getElementById('p2p-org-checkboxes');
    let html = '<div class="list-group" role="group" aria-label="Select organizations to transfer">';
    
    orgs.forEach(org => {
      const orgId = org.id || org.revops_cumulusorganizationid;
      const orgName = org.name || org.revops_name || 'Unnamed Organization';
      const escapedName = orgName.replace(/"/g, '&quot;');
      
      html += `
        <label class="list-group-item list-group-item-action">
          <input class="form-check-input me-2 org-checkbox" type="checkbox" value="${orgId}" data-name="${escapedName}" aria-label="Select ${escapedName}">
          ${orgName}
        </label>
      `;
    });
    html += '</div>';
    
    checkboxesContainer.innerHTML = html;
    
    checkboxesContainer.querySelectorAll('.org-checkbox').forEach(checkbox => {
      checkbox.addEventListener('change', handleOrgCheckboxChange);
    });
    
    const selectAllCheckbox = document.getElementById('p2p-select-all');
    if (selectAllCheckbox) {
      selectAllCheckbox.checked = false;
    }
    
    const searchInput = document.getElementById('p2p-org-search');
    if (searchInput) {
      searchInput.value = '';
    }
  }
  
  function handleSelectAll(event) {
    const isChecked = event.target.checked;
    const visibleCheckboxes = Array.from(document.querySelectorAll('.org-checkbox')).filter(cb => {
      const label = cb.closest('label');
      return label && label.style.display !== 'none';
    });
    
    visibleCheckboxes.forEach(checkbox => {
      const orgId = checkbox.value;
      checkbox.checked = isChecked;
      
      if (isChecked) {
        if (!selectedOrgGuids.includes(orgId)) {
          selectedOrgGuids.push(orgId);
        }
      } else {
        selectedOrgGuids = selectedOrgGuids.filter(id => id !== orgId);
      }
    });
    
    updateOrgCount();
  }
  
  function handleOrgCheckboxChange(event) {
    const checkbox = event.target;
    const orgId = checkbox.value;
    
    if (checkbox.checked) {
      if (!selectedOrgGuids.includes(orgId)) {
        selectedOrgGuids.push(orgId);
      }
    } else {
      selectedOrgGuids = selectedOrgGuids.filter(id => id !== orgId);
    }
    
    updateOrgCount();
    updateSelectAllState();
  }
  
  function updateSelectAllState() {
    const selectAllCheckbox = document.getElementById('p2p-select-all');
    const visibleCheckboxes = Array.from(document.querySelectorAll('.org-checkbox')).filter(cb => {
      const label = cb.closest('label');
      return label && label.style.display !== 'none';
    });
    
    if (selectAllCheckbox && visibleCheckboxes.length > 0) {
      const visibleCheckedCount = visibleCheckboxes.filter(cb => cb.checked).length;
      selectAllCheckbox.checked = visibleCheckedCount === visibleCheckboxes.length;
      selectAllCheckbox.indeterminate = visibleCheckedCount > 0 && visibleCheckedCount < visibleCheckboxes.length;
    } else if (selectAllCheckbox) {
      selectAllCheckbox.checked = false;
      selectAllCheckbox.indeterminate = false;
    }
  }
  
  function updateOrgCount() {
    const countElement = document.getElementById('p2p-org-count');
    if (countElement) {
      countElement.textContent = `${selectedOrgGuids.length} selected`;
    }
  }
  
  function handleSearch(event) {
    const searchTerm = event.target.value.toLowerCase().trim();
    const orgCheckboxes = document.querySelectorAll('.org-checkbox');
    
    orgCheckboxes.forEach(checkbox => {
      const label = checkbox.closest('label');
      const orgName = checkbox.getAttribute('data-name').toLowerCase();
      
      if (searchTerm === '' || orgName.includes(searchTerm)) {
        label.style.display = '';
      } else {
        label.style.display = 'none';
      }
    });
    
    updateSelectAllState();
  }
  
  function confirmOrgSelection() {
    const jsonValue = JSON.stringify(selectedOrgGuids);
    setTextField(CONFIG.fields.transferOrgs, jsonValue);
    setNumberField(CONFIG.fields.numberOfOrgs, selectedOrgGuids.length);
    
    if (currentParentAccountGuid && currentParentAccountName) {
      setLookupField(CONFIG.fields.revopsAccount, currentParentAccountGuid, currentParentAccountName);
    }
    
    const allAccounts = loadAccountsData();
    const allRegions = loadRegionsData();
    const firstOrg = loadOrgsData().find(org => selectedOrgGuids.includes(org.id));
    
    if (firstOrg && firstOrg.accountGuid) {
      const cleanAccountGuid = stripGuid(firstOrg.accountGuid).toLowerCase();
      const account = allAccounts.find(acc => stripGuid(acc.id || '').toLowerCase() === cleanAccountGuid);
      
      if (account && account.iso2Code) {
        const iso2Upper = account.iso2Code.toUpperCase();
        const matchingRegion = allRegions.find(region => region.code && region.code.toUpperCase() === iso2Upper);
        
        if (matchingRegion) {
          setLookupField(CONFIG.fields.competitorRegion, matchingRegion.id, matchingRegion.name);
        }
      }
    }
    
    updateSelectionIndicator();
    updateCaseTitle();
    
    if (modalInstance) {
      modalInstance.hide();
    }
  }
  
  function updateCaseTitle() {
    const accountName = getLookupName(CONFIG.fields.cumulusAccount);
    const accountNameValue = accountName ? accountName.value : '';
    const orgCount = selectedOrgGuids.length;
    
    const title = `${orgCount} - P2P transfer for ${accountNameValue}`;
    setTextField(CONFIG.fields.title, title);
  }
  
  function updateSelectionIndicator() {
    const indicator = document.getElementById('p2p-org-indicator');
    if (!indicator) return;
    
    if (selectedOrgGuids.length > 0) {
      indicator.textContent = `✓ ${selectedOrgGuids.length} org(s) selected`;
      indicator.className = 'text-success fw-bold';
    } else {
      indicator.textContent = 'Please Select at least 1 Organization';
      indicator.className = 'text-danger fw-bold';
    }
  }
  
  function populateRegionFromAccount(accountGuid) {
    const allAccounts = loadAccountsData();
    const allRegions = loadRegionsData();
    const cleanGuid = stripGuid(accountGuid).toLowerCase();
    
    const account = allAccounts.find(acc => {
      const accGuid = stripGuid(acc.id || '').toLowerCase();
      return accGuid === cleanGuid;
    });
    
    if (!account || !account.iso2Code) {
      return;
    }
    
    const iso2Upper = account.iso2Code.toUpperCase();
    const matchingRegion = allRegions.find(region => region.code && region.code.toUpperCase() === iso2Upper);
    
    if (matchingRegion) {
      const regionHidden = getLookupGuid(CONFIG.fields.competitorRegion);
      const regionName = getLookupName(CONFIG.fields.competitorRegion);
      
      if (regionHidden) {
        regionHidden.setAttribute('required', 'required');
        regionHidden.setAttribute('aria-required', 'true');
      }
      if (regionName) {
        regionName.setAttribute('required', 'required');
        regionName.setAttribute('aria-required', 'true');
      }
      
      setLookupField(CONFIG.fields.competitorRegion, matchingRegion.id, matchingRegion.name);
      currentRegionCode = matchingRegion.code;
    }
  }
  
  function hideFieldsWithCSS() {
    const fieldsToHide = [
      'title', 'revops_transferorgs',
      'revops_oforganizations', 'subjectid', 'revops_service',
      'caseorigincode', 'revops_account', 'revops_queue', 'casetypecode', 'customerid', 'primarycontactid',
      'revops_csptransferid', 'revops_losingprovider', 'revops_competitorregion'
    ];
    
    fieldsToHide.forEach(logicalName => {
      const field = getAttribute(logicalName);
      if (field) {
        let container = field.closest('tr');
        if (!container) container = field.closest('.form-group');
        if (!container) container = field.closest('.field-wrapper');
        if (!container) container = field.closest('section');
        if (!container) container = field.closest('div[class*="field"]');
        if (!container) container = field.closest('td')?.parentElement;
        
        if (container) {
          container.style.display = 'none';
          container.style.visibility = 'hidden';
        } else {
          field.style.display = 'none';
          field.style.visibility = 'hidden';
        }
      }
    });
  }
  
  function prepopulateFields() {
    const configData = loadConfigData();
    
    if (configData) {
      if (configData.subjectId && configData.subjectName) {
        setTimeout(() => setLookupField(CONFIG.fields.subject, configData.subjectId, configData.subjectName), 100);
      }
      
      if (configData.serviceId && configData.serviceName) {
        setTimeout(() => setLookupField(CONFIG.fields.service, configData.serviceId, configData.serviceName), 100);
      }
      
      if (configData.queueId && configData.queueName) {
        setTimeout(() => setLookupField(CONFIG.fields.queue, configData.queueId, configData.queueName), 100);
      }
    }
    
    setTimeout(() => {
      setOptionSetField(CONFIG.fields.origin, CONFIG.defaultValues.origin);
      setTimeout(hideFieldsWithCSS, 500);
    }, 100);
  }
  
  function attachAccountChangeHandler() {
    const accountHidden = getLookupGuid(CONFIG.fields.cumulusAccount);
    const accountName = getLookupName(CONFIG.fields.cumulusAccount);
    
    if (!accountHidden || !accountName) {
      setTimeout(attachAccountChangeHandler, 300);
      return;
    }
    
    let container = accountName.closest('.control, .form-group, .field-wrapper, td');
    if (!container || container.tagName === 'TD') {
      container = accountName.closest('tr, .row, section, div[class*="field"]');
    }
    if (!container) {
      container = accountName.parentElement;
    }
    
    if (container && !document.getElementById('p2p-select-orgs-btn')) {
      const buttonWrapper = document.createElement('div');
      buttonWrapper.id = 'p2p-button-wrapper';
      buttonWrapper.className = 'mt-4 mb-2 d-flex align-items-center gap-2';
      buttonWrapper.style.cssText = 'clear: both; display: none; width: 100%;';
      
      const button = document.createElement('button');
      button.id = 'p2p-select-orgs-btn';
      button.type = 'button';
      button.className = 'btn btn-sm btn-primary';
      button.textContent = 'Select Organizations to Transfer';
      button.disabled = true;
      
      button.onclick = function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        const accountGuid = accountHidden.value;
        const accountNameValue = accountName.value;
        
        if (accountGuid) {
          showOrgModal(accountGuid, accountNameValue);
        } else {
          alert("Please select a Cumulus Account first");
        }
        return false;
      };
      
      const indicator = document.createElement('small');
      indicator.id = 'p2p-org-indicator';
      indicator.className = 'text-danger fw-bold';
      indicator.textContent = 'Please Select at least 1 Organization';
      
      buttonWrapper.appendChild(button);
      buttonWrapper.appendChild(indicator);
      
      if (container.nextSibling) {
        container.parentNode.insertBefore(buttonWrapper, container.nextSibling);
      } else {
        container.parentNode.appendChild(buttonWrapper);
      }
    }
    
    function updateButtonState() {
      const button = document.getElementById('p2p-select-orgs-btn');
      const wrapper = document.getElementById('p2p-button-wrapper');
      if (button && wrapper) {
        const hasAccount = !!accountHidden.value;
        button.disabled = !hasAccount;
        wrapper.style.display = hasAccount ? 'flex' : 'none';
      }
    }
    
    const observer = new MutationObserver(updateButtonState);
    observer.observe(accountHidden, {
      attributes: true,
      attributeFilter: ['value']
    });
    
    let lastKnownValue = accountHidden.value;
    setInterval(function() {
      if (accountHidden.value !== lastKnownValue) {
        lastKnownValue = accountHidden.value;
        updateButtonState();
        selectedOrgGuids = [];
        setTextField(CONFIG.fields.transferOrgs, '[]');
        updateSelectionIndicator();
        if (accountHidden.value) {
          populateRegionFromAccount(accountHidden.value);
        }
      }
    }, 200);
    
    accountHidden.addEventListener('change', function() {
      selectedOrgGuids = [];
      setTextField(CONFIG.fields.transferOrgs, '[]');
      updateButtonState();
      updateSelectionIndicator();
      if (accountHidden.value) {
        populateRegionFromAccount(accountHidden.value);
      }
    });
    
    accountName.addEventListener('change', function() {
      setTimeout(updateButtonState, 100);
    });
    
    updateButtonState();
    setTimeout(updateButtonState, 1000);
  }
  
  function attachLosingCompetitorHandler() {
    const losingCompetitorField = getAttribute(CONFIG.fields.losingCompetitor);
    
    if (!losingCompetitorField) {
      setTimeout(attachLosingCompetitorHandler, 300);
      return;
    }
    
    function toggleOtherFields() {
      const losingCompetitorHidden = getLookupGuid(CONFIG.fields.losingCompetitor);
      const losingCompetitorName = getLookupName(CONFIG.fields.losingCompetitor);
      const cspField = getAttribute(CONFIG.fields.cspTransferId);
      const providerField = getAttribute(CONFIG.fields.losingProvider);
      
      // Find containers for both fields
      let cspContainer = null;
      let providerContainer = null;
      
      if (cspField) {
        cspContainer = cspField.closest('tr');
        if (!cspContainer) cspContainer = cspField.closest('.form-group, .field-wrapper, section, div[class*="field"]');
        if (!cspContainer) cspContainer = cspField.closest('td')?.parentElement;
      }
      
      if (providerField) {
        providerContainer = providerField.closest('tr');
        if (!providerContainer) providerContainer = providerField.closest('.form-group, .field-wrapper, section, div[class*="field"]');
        if (!providerContainer) providerContainer = providerField.closest('td')?.parentElement;
      }
      
      // Check if "Other" is selected
      const nameValue = losingCompetitorName ? losingCompetitorName.value.toLowerCase().trim() : '';
      const isOther = nameValue === 'other' || nameValue.includes('other');
      
      // Show/hide containers and toggle required attribute
      if (cspContainer) {
        cspContainer.style.display = isOther ? '' : 'none';
        cspContainer.style.visibility = isOther ? 'visible' : 'hidden';
        
        if (cspField) {
          if (isOther) {
            cspField.setAttribute('required', 'required');
            cspField.setAttribute('aria-required', 'true');
            
            // Add red asterisk for required field
            const label = cspContainer.querySelector('label');
            if (label && !label.querySelector('.required-asterisk')) {
              const asterisk = document.createElement('span');
              asterisk.className = 'required-asterisk';
              asterisk.style.cssText = 'color: red; margin-left: 4px;';
              asterisk.textContent = '*';
              label.appendChild(asterisk);
            }
          } else {
            cspField.removeAttribute('required');
            cspField.removeAttribute('aria-required');
            cspField.value = '';
            
            // Remove asterisk
            const asterisk = cspContainer.querySelector('.required-asterisk');
            if (asterisk) asterisk.remove();
          }
        }
      }
      
      if (providerContainer) {
        providerContainer.style.display = isOther ? '' : 'none';
        providerContainer.style.visibility = isOther ? 'visible' : 'hidden';
        
        if (providerField) {
          if (isOther) {
            providerField.setAttribute('required', 'required');
            providerField.setAttribute('aria-required', 'true');
            
            // Add red asterisk for required field
            const label = providerContainer.querySelector('label');
            if (label && !label.querySelector('.required-asterisk')) {
              const asterisk = document.createElement('span');
              asterisk.className = 'required-asterisk';
              asterisk.style.cssText = 'color: red; margin-left: 4px;';
              asterisk.textContent = '*';
              label.appendChild(asterisk);
            }
          } else {
            providerField.removeAttribute('required');
            providerField.removeAttribute('aria-required');
            providerField.value = '';
            
            // Remove asterisk
            const asterisk = providerContainer.querySelector('.required-asterisk');
            if (asterisk) asterisk.remove();
          }
        }
      }
    }
    
    // Initial check
    setTimeout(toggleOtherFields, 500);
    setTimeout(toggleOtherFields, 1500);
    setTimeout(toggleOtherFields, 3000);
    
    // Watch for changes on hidden field
    losingCompetitorField.addEventListener('change', toggleOtherFields);
    
    // Watch for changes on name field
    const losingCompetitorNameField = getLookupName(CONFIG.fields.losingCompetitor);
    if (losingCompetitorNameField) {
      losingCompetitorNameField.addEventListener('change', toggleOtherFields);
      losingCompetitorNameField.addEventListener('input', function() {
        setTimeout(toggleOtherFields, 100);
      });
      losingCompetitorNameField.addEventListener('blur', function() {
        setTimeout(toggleOtherFields, 100);
      });
      
      // Use MutationObserver to catch any value changes
      const observer = new MutationObserver(toggleOtherFields);
      observer.observe(losingCompetitorNameField, {
        attributes: true,
        attributeFilter: ['value']
      });
      
      // Poll for changes
      let lastValue = losingCompetitorNameField.value;
      setInterval(function() {
        if (losingCompetitorNameField.value !== lastValue) {
          lastValue = losingCompetitorNameField.value;
          toggleOtherFields();
        }
      }, 500);
    }
  }
  
  function attachFormSubmitValidation() {
    const form = document.querySelector('form');
    if (!form) {
      setTimeout(attachFormSubmitValidation, 300);
      return;
    }
    
    console.log('[P2P VALIDATION] Form found, attaching validation');
    
    // Add validation to form submit
    form.addEventListener('submit', function(e) {
      console.log('[P2P VALIDATION] Form submit event fired');
      
      const losingCompetitorName = getLookupName(CONFIG.fields.losingCompetitor);
      const nameValue = losingCompetitorName ? losingCompetitorName.value.toLowerCase().trim() : '';
      
      console.log('[P2P VALIDATION] Losing Competitor value:', nameValue);
      
      if (nameValue === 'other' || nameValue.includes('other')) {
        console.log('[P2P VALIDATION] "Other" detected, checking required fields');
        
        const cspField = getAttribute(CONFIG.fields.cspTransferId);
        const providerField = getAttribute(CONFIG.fields.losingProvider);
        
        console.log('[P2P VALIDATION] CSP Field:', cspField);
        console.log('[P2P VALIDATION] CSP Field value:', cspField ? cspField.value : 'FIELD NOT FOUND');
        console.log('[P2P VALIDATION] Provider Field:', providerField);
        console.log('[P2P VALIDATION] Provider Field value:', providerField ? providerField.value : 'FIELD NOT FOUND');
        
        let isValid = true;
        let errorMessage = 'The following fields are required when "Other" is selected:\n\n';
        
        if (!cspField || !cspField.value || cspField.value.trim() === '') {
          isValid = false;
          errorMessage += '• CSP Transfer ID\n';
          console.log('[P2P VALIDATION] CSP Transfer ID is EMPTY');
          if (cspField) {
            cspField.style.borderColor = 'red';
            cspField.style.borderWidth = '2px';
          }
        }
        
        if (!providerField || !providerField.value || providerField.value.trim() === '') {
          isValid = false;
          errorMessage += '• Losing Provider\n';
          console.log('[P2P VALIDATION] Losing Provider is EMPTY');
          if (providerField) {
            providerField.style.borderColor = 'red';
            providerField.style.borderWidth = '2px';
          }
        }
        
        if (!isValid) {
          console.log('[P2P VALIDATION] VALIDATION FAILED - Preventing submission');
          e.preventDefault();
          e.stopPropagation();
          e.stopImmediatePropagation();
          alert(errorMessage);
          return false;
        } else {
          console.log('[P2P VALIDATION] Validation passed');
        }
      } else {
        console.log('[P2P VALIDATION] "Other" not selected, skipping validation');
      }
    }, true); // Use capture phase to catch submit early
    
    console.log('[P2P VALIDATION] Looking for submit buttons');
    
    // Also intercept button clicks
    const submitButtons = form.querySelectorAll('button[type="submit"], input[type="submit"]');
    console.log('[P2P VALIDATION] Found submit buttons:', submitButtons.length);
    
    submitButtons.forEach((button, index) => {
      console.log('[P2P VALIDATION] Attaching to submit button', index, ':', button);
      
      button.addEventListener('click', function(e) {
        console.log('[P2P VALIDATION] Submit button clicked:', index);
        
        const losingCompetitorName = getLookupName(CONFIG.fields.losingCompetitor);
        const nameValue = losingCompetitorName ? losingCompetitorName.value.toLowerCase().trim() : '';
        
        console.log('[P2P VALIDATION] [BUTTON CLICK] Losing Competitor value:', nameValue);
        
        if (nameValue === 'other' || nameValue.includes('other')) {
          console.log('[P2P VALIDATION] [BUTTON CLICK] "Other" detected, checking required fields');
          
          const cspField = getAttribute(CONFIG.fields.cspTransferId);
          const providerField = getAttribute(CONFIG.fields.losingProvider);
          
          console.log('[P2P VALIDATION] [BUTTON CLICK] CSP Field value:', cspField ? cspField.value : 'FIELD NOT FOUND');
          console.log('[P2P VALIDATION] [BUTTON CLICK] Provider Field value:', providerField ? providerField.value : 'FIELD NOT FOUND');
          
          let isValid = true;
          let errorMessage = 'The following fields are required when "Other" is selected:\n\n';
          
          if (!cspField || !cspField.value || cspField.value.trim() === '') {
            isValid = false;
            errorMessage += '• CSP Transfer ID\n';
            console.log('[P2P VALIDATION] [BUTTON CLICK] CSP Transfer ID is EMPTY');
            if (cspField) {
              cspField.style.borderColor = 'red';
              cspField.style.borderWidth = '2px';
            }
          }
          
          if (!providerField || !providerField.value || providerField.value.trim() === '') {
            isValid = false;
            errorMessage += '• Losing Provider\n';
            console.log('[P2P VALIDATION] [BUTTON CLICK] Losing Provider is EMPTY');
            if (providerField) {
              providerField.style.borderColor = 'red';
              providerField.style.borderWidth = '2px';
            }
          }
          
          if (!isValid) {
            console.log('[P2P VALIDATION] [BUTTON CLICK] VALIDATION FAILED - Preventing submission');
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();
            alert(errorMessage);
            return false;
          } else {
            console.log('[P2P VALIDATION] [BUTTON CLICK] Validation passed');
          }
        } else {
          console.log('[P2P VALIDATION] [BUTTON CLICK] "Other" not selected, skipping validation');
        }
      }, true);
    });
    
    // Clear red borders on input
    const cspField = getAttribute(CONFIG.fields.cspTransferId);
    const providerField = getAttribute(CONFIG.fields.losingProvider);
    
    if (cspField) {
      cspField.addEventListener('input', function() {
        if (this.value && this.value.trim() !== '') {
          this.style.borderColor = '';
          this.style.borderWidth = '';
        }
      });
    }
    
    if (providerField) {
      providerField.addEventListener('input', function() {
        if (this.value && this.value.trim() !== '') {
          this.style.borderColor = '';
          this.style.borderWidth = '';
        }
      });
    }
    
    console.log('[P2P VALIDATION] Validation setup complete');
  }
  
  function injectModalStyles() {
    // Add global styles to ensure all modals are properly centered
    const styleId = 'p2p-modal-centering-styles';
    if (document.getElementById(styleId)) return;
    
    const style = document.createElement('style');
    style.id = styleId;
    style.textContent = `
      /* Apply to ALL modals regardless of class */
      .modal .modal-dialog,
      div[role="dialog"] .modal-dialog,
      .modal-dialog {
        margin: 1.5rem auto !important;
        max-height: calc(100vh - 3rem) !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        min-height: calc(100vh - 3rem) !important;
      }
      
      .modal.fade .modal-dialog,
      .modal.show .modal-dialog {
        transform: translate(0, 0) !important;
      }
      
      .modal-content {
        max-height: calc(100vh - 3rem) !important;
        overflow: hidden !important;
        margin: auto !important;
      }
      
      .modal-body {
        overflow-y: auto !important;
        max-height: calc(100vh - 12rem) !important;
      }
      
      /* Override any Bootstrap default positioning */
      .modal.fade .modal-dialog {
        transition: transform 0.3s ease-out !important;
        transform: translate(0, -25px) !important;
      }
      
      .modal.show .modal-dialog {
        transform: translate(0, 0) !important;
      }
    `;
    document.head.appendChild(style);
    
    // Function to apply styles to a modal
    function applyModalStyles(modalDialog) {
      if (!modalDialog) return;
      
      modalDialog.style.margin = '1.5rem auto';
      modalDialog.style.maxHeight = 'calc(100vh - 3rem)';
      modalDialog.style.display = 'flex';
      modalDialog.style.alignItems = 'center';
      modalDialog.style.justifyContent = 'center';
      modalDialog.style.minHeight = 'calc(100vh - 3rem)';
      modalDialog.style.transform = 'translate(0, 0)';
      
      const modalContent = modalDialog.querySelector('.modal-content');
      if (modalContent) {
        modalContent.style.maxHeight = 'calc(100vh - 3rem)';
        modalContent.style.overflow = 'hidden';
        modalContent.style.margin = 'auto';
      }
      
      const modalBody = modalDialog.querySelector('.modal-body');
      if (modalBody) {
        modalBody.style.overflowY = 'auto';
        modalBody.style.maxHeight = 'calc(100vh - 12rem)';
        
        // Update "Lookup records" text for different modals
        const modal = modalDialog.closest('.modal');
        if (modal) {
          const modalTitle = modal.querySelector('.modal-title, h1, h2, h3, h4, h5, h6');
          if (modalTitle && modalTitle.textContent.trim() === 'Lookup records') {
            // Check if this is the Cumulus Account modal by looking for specific column headers
            const bodyText = modalBody.textContent || '';
            // Check for column headers that indicate this is the Cumulus Account modal
            if (bodyText.includes('Company Name') && bodyText.includes('Domain') && bodyText.includes('Client Unique Name')) {
              modalTitle.textContent = 'Cumulus Accounts';
            } else if (bodyText.includes('Name') && (bodyText.includes('IT Cloud') || bodyText.includes('PAX 8') || bodyText.includes('Other'))) {
              // This appears to be the Source CSP (Losing Provider) modal
              modalTitle.textContent = 'Source CSP';
              
              // Add a note after "Choose one record and click Select to continue"
              if (!modalBody.querySelector('.source-csp-note')) {
                // Find the text that says "Choose one record and click Select to continue"
                const textNodes = [];
                const walker = document.createTreeWalker(modalBody, NodeFilter.SHOW_TEXT, null, false);
                let node;
                while (node = walker.nextNode()) {
                  if (node.textContent.includes('Choose one record and click Select to continue')) {
                    textNodes.push(node);
                  }
                }
                
                if (textNodes.length > 0) {
                  const targetNode = textNodes[0];
                  const note = document.createElement('div');
                  note.className = 'source-csp-note';
                  note.style.cssText = 'font-size: 0.875rem; color: #dc3545; margin-top: 0.5rem; margin-bottom: 0.5rem; padding: 0 1rem; font-weight: normal;';
                  note.textContent = '** If CSP not listed, select "Other"';
                  
                  // Insert after the parent element of the text node
                  const parentElement = targetNode.parentElement;
                  if (parentElement && parentElement.nextSibling) {
                    parentElement.parentNode.insertBefore(note, parentElement.nextSibling);
                  } else if (parentElement) {
                    parentElement.parentNode.appendChild(note);
                  }
                }
              }
            }
          }
        }
      }
    }
    
    // Apply to existing modals on page
    function fixExistingModals() {
      const allModalDialogs = document.querySelectorAll('.modal-dialog');
      allModalDialogs.forEach(applyModalStyles);
    }
    
    // Watch for new modals being added to the DOM
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType === 1) {
            // Check if it's a modal or contains a modal
            let modalDialogs = [];
            
            if (node.classList && node.classList.contains('modal-dialog')) {
              modalDialogs.push(node);
            } else if (node.classList && node.classList.contains('modal')) {
              const dialog = node.querySelector('.modal-dialog');
              if (dialog) modalDialogs.push(dialog);
            } else if (node.querySelector) {
              const dialogs = node.querySelectorAll('.modal-dialog');
              modalDialogs.push(...Array.from(dialogs));
            }
            
            modalDialogs.forEach(applyModalStyles);
          }
        });
      });
    });
    
    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
    
    // Fix existing modals immediately and periodically
    fixExistingModals();
    setTimeout(fixExistingModals, 100);
    setTimeout(fixExistingModals, 500);
    setTimeout(fixExistingModals, 1000);
    
    // Also watch for modal show events
    document.addEventListener('shown.bs.modal', function(e) {
      const modalDialog = e.target.querySelector('.modal-dialog');
      applyModalStyles(modalDialog);
    });
    
    // Watch for any clicks that might open a modal
    document.addEventListener('click', function() {
      setTimeout(fixExistingModals, 50);
      setTimeout(fixExistingModals, 200);
    }, true);
  }
  
  function initialize() {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', initialize);
      return;
    }
    
    // Inject modal centering styles first
    injectModalStyles();
    
    setTimeout(() => {
      prepopulateFields();
      attachAccountChangeHandler();
      attachLosingCompetitorHandler();
      attachFormSubmitValidation();
    }, 500);
  }
  
  initialize();
  
})();