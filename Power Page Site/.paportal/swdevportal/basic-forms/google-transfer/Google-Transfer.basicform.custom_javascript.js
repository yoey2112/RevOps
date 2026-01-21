// Runs when the page is ready
$(document).ready(function () {
  'use strict';
  
  const CONFIG = {
    fields: {
      subject: "subjectid",
      service: "revops_service",
      origin: "caseorigincode",
      caseType: "casetypecode",
      queue: "revops_queue",
      contact: "primarycontactid",
      title: "title",
      customer: "customerid",
      cumulusOrg: "revops_cumulusorganization",
      cumulusAccount: "revops_cumulusaccount"
    },
    fieldsToHide: [
      "revops_cumulusaccount",
      "revops_queue",
      "title",
      "casetypecode",
      "subjectid",
      "revops_service",
      "caseorigincode",
      "customerid"
    ],
    defaultValues: {
      origin: "3", // Portal
      caseType: "234570012" // Manual Provisioning
    },
    lookupEntities: {
      subjectid: "subject",
      revops_service: "revops_service",
      revops_queue: "queue",
      revops_cumulusorganization: "revops_cumulusorganization",
      revops_cumulusaccount: "revops_cumulusaccount"
    }
  };
  
  // ===== HELPER FUNCTIONS =====
  
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
      return false;
    }
  }
  
  function setOptionSetField(logicalName, value) {
    const field = getAttribute(logicalName);
    if (field && field.tagName === 'SELECT') {
      field.value = '';
      setTimeout(() => {
        field.value = value || '';
        field.dispatchEvent(new Event('change', { bubbles: true }));
        field.dispatchEvent(new Event('input', { bubbles: true }));
        setTimeout(() => {
          if (field.value !== value) {
            field.value = value || '';
            field.dispatchEvent(new Event('change', { bubbles: true }));
          }
        }, 150);
      }, 100);
      return true;
    }
    return false;
  }
  
  // ===== DATA LOADING FUNCTIONS =====
  
  function loadConfigData() {
    const configScript = document.getElementById('google-config-data');
    if (!configScript) return null;
    try {
      return JSON.parse(configScript.textContent);
    } catch (error) {
      return null;
    }
  }
  
  function loadOrgsData() {
    const orgsScript = document.getElementById('google-orgs-data');
    if (!orgsScript) return [];
    try {
      return JSON.parse(orgsScript.textContent);
    } catch (error) {
      return [];
    }
  }
  
  function getOrgById(orgId) {
    const orgs = loadOrgsData();
    return orgs.find(org => stripGuid(org.id) === stripGuid(orgId));
  }
  
  function loadAccountsData() {
    const accountsScript = document.getElementById('google-accounts-data');
    if (!accountsScript) return [];
    try {
      return JSON.parse(accountsScript.textContent);
    } catch (error) {
      return [];
    }
  }
  
  function getAccountById(accountId) {
    const accounts = loadAccountsData();
    return accounts.find(acc => stripGuid(acc.id) === stripGuid(accountId));
  }
  
  function hideFields() {
    CONFIG.fieldsToHide.forEach(logicalName => {
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
  
  // ===== PREPOPULATION FUNCTIONS =====
  
  function attachOrgChangeHandlerForAccount() {
    const orgField = getLookupGuid(CONFIG.fields.cumulusOrg);
    if (!orgField) return;
    
    const observer = new MutationObserver(() => {
      const orgId = orgField.value;
      if (orgId) {
        const org = getOrgById(orgId);
        if (org && org.cumulusAccountId) {
          const account = getAccountById(org.cumulusAccountId);
          const accountName = account ? account.name : '';
          setLookupField(CONFIG.fields.cumulusAccount, org.cumulusAccountId, accountName);
        }
        updateCaseTitleFromOrg(orgId);
      }
    });
    
    observer.observe(orgField, {
      attributes: true,
      attributeFilter: ['value']
    });
    
    orgField.addEventListener('change', function() {
      const orgId = this.value;
      if (orgId) {
        const org = getOrgById(orgId);
        if (org && org.cumulusAccountId) {
          const account = getAccountById(org.cumulusAccountId);
          const accountName = account ? account.name : '';
          setLookupField(CONFIG.fields.cumulusAccount, org.cumulusAccountId, accountName);
        }
        updateCaseTitleFromOrg(orgId);
      }
    });
    
    if (orgField.value) {
      const orgId = orgField.value;
      const org = getOrgById(orgId);
      if (org && org.cumulusAccountId) {
        const account = getAccountById(org.cumulusAccountId);
        const accountName = account ? account.name : '';
        setLookupField(CONFIG.fields.cumulusAccount, org.cumulusAccountId, accountName);
      }
      updateCaseTitleFromOrg(orgId);
    }
  }
  
  function attachAccountChangeHandler() {
    const accountField = getLookupGuid(CONFIG.fields.cumulusAccount);
    if (!accountField) return;
    
    const observer = new MutationObserver(() => {
      const accountId = accountField.value;
      
      // Clear organization selection when account changes
      const orgField = getLookupGuid(CONFIG.fields.cumulusOrg);
      const orgNameField = getLookupName(CONFIG.fields.cumulusOrg);
      if (orgField && orgField.value) {
        const org = getOrgById(orgField.value);
        if (!org || (accountId && stripGuid(org.cumulusAccountId) !== stripGuid(accountId))) {
          orgField.value = '';
          if (orgNameField) orgNameField.value = '';
          setTextField(CONFIG.fields.title, '');
        }
      }
    });
    
    observer.observe(accountField, {
      attributes: true,
      attributeFilter: ['value']
    });
    
    accountField.addEventListener('change', function() {
      const accountId = this.value;
      
      // Clear organization selection
      const orgField = getLookupGuid(CONFIG.fields.cumulusOrg);
      const orgNameField = getLookupName(CONFIG.fields.cumulusOrg);
      if (orgField && orgField.value) {
        const org = getOrgById(orgField.value);
        if (!org || (accountId && stripGuid(org.cumulusAccountId) !== stripGuid(accountId))) {
          orgField.value = '';
          if (orgNameField) orgNameField.value = '';
          setTextField(CONFIG.fields.title, '');
        }
      }
    });
  }
  
  function attachOrgChangeHandler() {
    const orgField = getLookupGuid(CONFIG.fields.cumulusOrg);
    if (!orgField) return;
    
    const observer = new MutationObserver(() => {
      const orgId = orgField.value;
      if (orgId) {
        updateCaseTitleFromOrg(orgId);
      }
    });
    
    observer.observe(orgField, {
      attributes: true,
      attributeFilter: ['value']
    });
    
    orgField.addEventListener('change', function() {
      const orgId = this.value;
      if (orgId) {
        updateCaseTitleFromOrg(orgId);
      }
    });
    
    if (orgField.value) {
      updateCaseTitleFromOrg(orgField.value);
    }
  }
  
  function updateCaseTitleFromOrg(orgId) {
    if (!orgId) return;
    
    const org = getOrgById(orgId);
    if (org && org.name) {
      const caseTitle = `Google Workspace Transfer for ${org.name}`;
      setTextField(CONFIG.fields.title, caseTitle);
    }
  }
  
  function prepopulateStaticFields() {
    const config = loadConfigData();
    if (!config) return;
    
    if (config.queueId && config.queueName) {
      setLookupField(CONFIG.fields.queue, config.queueId, config.queueName);
    }
    
    if (config.subjectId && config.subjectName) {
      setLookupField(CONFIG.fields.subject, config.subjectId, config.subjectName);
    }
    
    if (config.serviceId && config.serviceName) {
      setLookupField(CONFIG.fields.service, config.serviceId, config.serviceName);
    }
    
    setOptionSetField(CONFIG.fields.origin, CONFIG.defaultValues.origin);
    setOptionSetField(CONFIG.fields.caseType, CONFIG.defaultValues.caseType);
  }
  
  // ===== MODAL CENTERING =====
  
  function injectModalStyles() {
    const styleId = 'google-modal-centering-styles';
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
      }
      
      const modal = modalDialog.closest('.modal');
      if (modal) {
        const modalTitle = modal.querySelector('.modal-title, h1, h2, h3, h4, h5, h6');
        if (modalTitle && modalTitle.textContent.trim() === 'Lookup records') {
          modalTitle.textContent = 'Cumulus Organizations';
        }
      }
    }
    
    function fixExistingModals() {
      const allModalDialogs = document.querySelectorAll('.modal-dialog');
      allModalDialogs.forEach(applyModalStyles);
    }
    
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType === 1) {
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
    
    fixExistingModals();
    setTimeout(fixExistingModals, 100);
    setTimeout(fixExistingModals, 500);
    setTimeout(fixExistingModals, 1000);
    
    document.addEventListener('shown.bs.modal', function(e) {
      const modalDialog = e.target.querySelector('.modal-dialog');
      applyModalStyles(modalDialog);
    });
    
    document.addEventListener('click', function() {
      setTimeout(fixExistingModals, 50);
      setTimeout(fixExistingModals, 200);
    }, true);
  }
  
  // ===== INITIALIZATION =====
  
  function initialize() {
    injectModalStyles();
    
    setTimeout(() => {
      hideFields();
      prepopulateStaticFields();
      attachOrgChangeHandlerForAccount();
      attachAccountChangeHandler();
      attachOrgChangeHandler();
      setTimeout(() => {
        prepopulateStaticFields();
      }, 1000);
    }, 2000);
  }
  
  // Run initialization
  initialize();
});
