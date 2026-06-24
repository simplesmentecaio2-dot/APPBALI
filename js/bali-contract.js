(function () {
  var ajaxHooked = false;
  var submitButton = null;
  var moneyFields = [
    'txtValoVeiculo',
    'txtEmplacamento',
    'txtEntrada',
    'txtCarroUsado',
    'txtVlUtilzadoAvaliacao',
    'txtQuitacao',
    'txtSaldoAvaliacao',
    'txtVlFinanciamento',
    'txtVlParcelas',
    'txtEdValorVeic',
    'txtEdTAXAS',
    'txtEdEntrada',
    'txtEdValorUSADO',
    'txtEdVALORUSADOAVAILACAO',
    'txtEdQuitacao',
    'txtEdSaldoAvaliacao',
    'txtEdFinanciamento',
    'txtEdValorParcela'
  ];

  var calcGroups = [
    {
      value: 'txtValoVeiculo',
      entry: 'txtEntrada',
      usedApplied: 'txtVlUtilzadoAvaliacao',
      usedValue: 'txtCarroUsado',
      payoff: 'txtQuitacao',
      finance: 'txtVlFinanciamento',
      balance: 'txtSaldoAvaliacao'
    },
    {
      value: 'txtEdValorVeic',
      entry: 'txtEdEntrada',
      usedApplied: 'txtEdVALORUSADOAVAILACAO',
      usedValue: 'txtEdValorUSADO',
      payoff: 'txtEdQuitacao',
      finance: 'txtEdFinanciamento',
      balance: 'txtEdSaldoAvaliacao'
    }
  ];

  var requiredNewFields = [
    { id: 'txtCliente', label: 'Cliente' },
    { id: 'txtCPFCNPJ', label: 'CPF/CNPJ' },
    { id: 'txtMarca', label: 'Marca' },
    { id: 'txtModelo', label: 'Modelo' },
    { id: 'txtChassiPlaca', label: 'Chassi/placa' },
    { id: 'txtValoVeiculo', label: 'Valor do veículo', money: true },
    { id: 'ddlVendedor', label: 'Vendedor' }
  ];

  var requiredEditFields = [
    { id: 'txtEdCliente', label: 'Cliente' },
    { id: 'txtEdCPF', label: 'CPF/CNPJ' },
    { id: 'txtEdMarca', label: 'Marca' },
    { id: 'txtEdModelo', label: 'Modelo' },
    { id: 'txtEdChassi', label: 'Chassi/placa' },
    { id: 'txtEdValorVeic', label: 'Valor do veículo', money: true },
    { id: 'txtEdVendedor', label: 'Vendedor' }
  ];

  function bySuffix(id) {
    return document.querySelector('[id$="' + id + '"]');
  }

  function allBySuffix(id) {
    return Array.prototype.slice.call(document.querySelectorAll('[id$="' + id + '"]'));
  }

  function valueOf(id) {
    var field = bySuffix(id);
    return field ? String(field.value || '').trim() : '';
  }

  function setValue(id, value) {
    var field = bySuffix(id);
    if (field) field.value = value;
  }

  function isVisible(field) {
    if (!field) return false;
    return !!(field.offsetWidth || field.offsetHeight || field.getClientRects().length);
  }

  function parseMoney(value) {
    var text = String(value || '').replace(/R\$/g, '').replace(/\s/g, '').trim();
    if (!text) return 0;

    var hasComma = text.indexOf(',') >= 0;
    if (hasComma) {
      text = text.replace(/\./g, '').replace(',', '.');
    } else {
      var dots = (text.match(/\./g) || []).length;
      if (dots > 1) {
        text = text.replace(/\./g, '');
      }
    }

    text = text.replace(/[^0-9.-]/g, '');
    var parsed = parseFloat(text);
    return isNaN(parsed) ? 0 : parsed;
  }

  function formatMoney(value) {
    var number = Number(value);
    if (!isFinite(number)) number = 0;
    return number.toLocaleString('pt-BR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });
  }

  function normalizeMoneyField(field, forceZero) {
    if (!field) return;
    var current = String(field.value || '').trim();
    if (!current && !forceZero) return;
    field.value = formatMoney(parseMoney(current));
  }

  function showFieldMessage(field, message) {
    if (!field) return;
    var cell = field.closest ? field.closest('td') : null;
    var host = cell || field.parentNode;
    if (!host) return;

    var existing = host.querySelector('.contract-field-message');
    if (!message) {
      field.classList.remove('contract-field-error');
      if (existing) existing.parentNode.removeChild(existing);
      return;
    }

    field.classList.add('contract-field-error');
    if (!existing) {
      existing = document.createElement('div');
      existing.className = 'contract-field-message';
      host.appendChild(existing);
    }
    existing.textContent = message;
  }

  function calculateContracts() {
    calcGroups.forEach(function (group) {
      var vehicleValue = parseMoney(valueOf(group.value));
      var entry = parseMoney(valueOf(group.entry));
      var usedApplied = parseMoney(valueOf(group.usedApplied));
      var usedValue = parseMoney(valueOf(group.usedValue));
      var payoff = parseMoney(valueOf(group.payoff));
      var finance = vehicleValue - entry - usedApplied;
      var balance = usedValue - usedApplied - payoff;

      setValue(group.finance, formatMoney(finance));
      setValue(group.balance, formatMoney(balance));
    });

    updateQualityPanel();
  }

  function currentRequiredFields(isEdit) {
    return isEdit ? requiredEditFields : requiredNewFields;
  }

  function isEditSubmit(button) {
    return button && /btnEditareGravar$/i.test(button.id || '');
  }

  function collectIssues(isEdit, showMessages) {
    var issues = [];
    currentRequiredFields(isEdit).forEach(function (item) {
      var field = bySuffix(item.id);
      if (!field || !isVisible(field)) return;

      var value = String(field.value || '').trim();
      var invalid = item.money ? parseMoney(value) <= 0 : value.length === 0;
      var message = invalid
        ? (item.money ? item.label + ' deve ser maior que zero.' : item.label + ' precisa ser preenchido.')
        : '';

      if (showMessages) showFieldMessage(field, message);
      if (message) issues.push(message);
    });

    var vista = bySuffix(isEdit ? 'rbtnEdAVISTA' : 'rBtnModPagVista');
    var financiamento = bySuffix(isEdit ? 'rbtnEdAprazo' : 'rBtnModPagFinanciamento');
    if (vista && financiamento && !vista.checked && !financiamento.checked) {
      issues.push('Selecione a modalidade de pagamento.');
      if (showMessages) showFieldMessage(financiamento, 'Selecione à vista ou financiamento.');
    } else if (financiamento) {
      if (showMessages) showFieldMessage(financiamento, '');
    }

    if ((financiamento && financiamento.checked) || parseMoney(valueOf(isEdit ? 'txtEdFinanciamento' : 'txtVlFinanciamento')) > 0) {
      var parcels = bySuffix(isEdit ? 'txtEdNumeroParcelas' : 'txtNrParcelas');
      var parcelValue = bySuffix(isEdit ? 'txtEdValorParcela' : 'txtVlParcelas');
      if (parcels && isVisible(parcels) && String(parcels.value || '').trim().length === 0) {
        issues.push('Informe a quantidade de parcelas do financiamento.');
        if (showMessages) showFieldMessage(parcels, 'Informe a quantidade de parcelas.');
      } else {
        if (showMessages) showFieldMessage(parcels, '');
      }
      if (parcelValue && isVisible(parcelValue) && parseMoney(parcelValue.value) <= 0) {
        issues.push('Valor da parcela deve ser maior que zero para financiamento.');
        if (showMessages) showFieldMessage(parcelValue, 'Use um valor maior que zero.');
      } else {
        if (showMessages) showFieldMessage(parcelValue, '');
      }
    }

    var financeValue = parseMoney(valueOf(isEdit ? 'txtEdFinanciamento' : 'txtVlFinanciamento'));
    var balanceValue = parseMoney(valueOf(isEdit ? 'txtEdSaldoAvaliacao' : 'txtSaldoAvaliacao'));
    if (financeValue < 0) issues.push('Financiamento ficou negativo. Confira valor, entrada e avaliação utilizada.');
    if (balanceValue < 0) issues.push('Saldo da avaliação ficou negativo. Confira avaliação, valor utilizado e quitação.');

    return issues;
  }

  function ensureQualityPanel() {
    if (document.getElementById('contractQualityPanel')) return;
    var firstPanel = bySuffix('Panel1') || document.querySelector('.ajax__tab_body table');
    if (!firstPanel || !firstPanel.parentNode) return;

    var panel = document.createElement('div');
    panel.id = 'contractQualityPanel';
    panel.className = 'contract-quality-panel is-attention';
    panel.innerHTML =
      '<div class="contract-quality-main">' +
      '<span class="contract-quality-label">Qualidade do contrato</span>' +
      '<strong id="contractQualityStatus">Atenção</strong>' +
      '<small id="contractQualityText">Preencha os campos principais para reduzir erros antes de gravar.</small>' +
      '</div>' +
      '<ul id="contractQualityList"></ul>';

    firstPanel.parentNode.insertBefore(panel, firstPanel);
  }

  function updateQualityPanel() {
    ensureQualityPanel();
    var panel = document.getElementById('contractQualityPanel');
    if (!panel) return;

    var isEdit = !!(bySuffix('txtEdCliente') && isVisible(bySuffix('txtEdCliente')));
    var issues = collectIssues(isEdit, false);
    var status = document.getElementById('contractQualityStatus');
    var text = document.getElementById('contractQualityText');
    var list = document.getElementById('contractQualityList');

    panel.classList.remove('is-good', 'is-attention', 'is-risk');
    if (issues.length === 0) {
      panel.classList.add('is-good');
      status.textContent = 'Completo';
      text.textContent = 'Campos principais conferidos. Revise os dados antes de gravar.';
    } else if (issues.length <= 2) {
      panel.classList.add('is-attention');
      status.textContent = 'Atenção';
      text.textContent = 'Existem poucos pontos para conferir antes de gravar.';
    } else {
      panel.classList.add('is-risk');
      status.textContent = 'Risco de erro';
      text.textContent = 'Revise os campos sinalizados para evitar retorno do sistema.';
    }

    if (list) {
      list.innerHTML = '';
      issues.slice(0, 5).forEach(function (issue) {
        var item = document.createElement('li');
        item.textContent = issue;
        list.appendChild(item);
      });
    }
  }

  function ensureChecklistModal() {
    var existing = document.getElementById('contractChecklistModal');
    if (existing) return existing;

    var modal = document.createElement('div');
    modal.id = 'contractChecklistModal';
    modal.className = 'contract-checklist-modal is-hidden';
    modal.innerHTML =
      '<div class="contract-checklist-dialog" role="dialog" aria-modal="true" aria-labelledby="contractChecklistTitle">' +
      '<h2 id="contractChecklistTitle">Checklist final</h2>' +
      '<p>Confirme os pontos abaixo antes de gravar o contrato.</p>' +
      '<label><input type="checkbox" data-contract-check> Documento do cliente conferido</label>' +
      '<label><input type="checkbox" data-contract-check> Valores e forma de pagamento conferidos</label>' +
      '<label><input type="checkbox" data-contract-check> Veículo, chassi/placa e vendedor conferidos</label>' +
      '<div class="contract-checklist-actions">' +
      '<button type="button" class="secondary" id="contractChecklistCancel">Voltar</button>' +
      '<button type="button" id="contractChecklistConfirm">Confirmar e gravar</button>' +
      '</div>' +
      '<small id="contractChecklistWarning"></small>' +
      '</div>';

    document.body.appendChild(modal);
    document.getElementById('contractChecklistCancel').addEventListener('click', closeChecklist);
    document.getElementById('contractChecklistConfirm').addEventListener('click', confirmChecklist);
    return modal;
  }

  function openChecklist(button) {
    submitButton = button;
    var modal = ensureChecklistModal();
    Array.prototype.slice.call(modal.querySelectorAll('[data-contract-check]')).forEach(function (checkbox) {
      checkbox.checked = false;
    });
    var warning = document.getElementById('contractChecklistWarning');
    if (warning) warning.textContent = '';
    modal.classList.remove('is-hidden');
  }

  function closeChecklist() {
    var modal = document.getElementById('contractChecklistModal');
    if (modal) modal.classList.add('is-hidden');
    submitButton = null;
  }

  function confirmChecklist() {
    var modal = document.getElementById('contractChecklistModal');
    var checks = modal ? Array.prototype.slice.call(modal.querySelectorAll('[data-contract-check]')) : [];
    var warning = document.getElementById('contractChecklistWarning');
    var allChecked = checks.every(function (checkbox) { return checkbox.checked; });

    if (!allChecked) {
      if (warning) warning.textContent = 'Marque todos os itens para liberar a gravação.';
      return;
    }

    if (submitButton) {
      submitButton.setAttribute('data-contract-confirmed', 'true');
      closeChecklist();
      submitButton.click();
    }
  }

  function prepareMoneyFields(forceZero) {
    moneyFields.forEach(function (id) {
      allBySuffix(id).forEach(function (field) {
        normalizeMoneyField(field, forceZero);
      });
    });
    calculateContracts();
  }

  function validateInlineChecklist(button) {
    var ids = isEditSubmit(button)
      ? ['chkConfereEdicao']
      : ['chkConfereDocumento', 'chkConfereValores', 'chkConferePagamento'];

    var missing = ids.some(function (id) {
      var field = bySuffix(id);
      return field && !field.checked;
    });

    if (!missing) return true;

    alert(isEditSubmit(button)
      ? 'Confirme o checklist da edição antes de gravar.'
      : 'Confirme o checklist final antes de gravar o contrato.');

    var first = ids.map(bySuffix).filter(Boolean)[0];
    if (first && first.focus) first.focus();
    return false;
  }

  function handleSubmit(event) {
    var button = event.currentTarget;
    if (button.getAttribute('data-contract-confirmed') === 'true') {
      button.removeAttribute('data-contract-confirmed');
      prepareMoneyFields(true);
      return true;
    }

    prepareMoneyFields(true);
    var issues = collectIssues(isEditSubmit(button), true);
    if (issues.length) {
      var firstInvalid = document.querySelector('.contract-field-error');
      if (firstInvalid && firstInvalid.focus) firstInvalid.focus();
      event.preventDefault();
      updateQualityPanel();
      return false;
    }

    if (!validateInlineChecklist(button)) {
      event.preventDefault();
      return false;
    }

    return true;
  }

  function removeLegacyPostbacks(field) {
    if (!field) return;
    field.removeAttribute('onkeypress');
    field.onkeypress = null;

    var onchange = field.getAttribute('onchange') || '';
    if (onchange.indexOf('__doPostBack') >= 0) {
      field.setAttribute('data-original-onchange', onchange);
      field.removeAttribute('onchange');
      field.onchange = null;
    }
  }

  function enhanceFields() {
    moneyFields.forEach(function (id) {
      allBySuffix(id).forEach(function (field) {
        if (field.getAttribute('data-contract-enhanced') === 'true') return;
        field.setAttribute('data-contract-enhanced', 'true');
        field.setAttribute('inputmode', 'decimal');
        field.setAttribute('autocomplete', 'off');
        removeLegacyPostbacks(field);
        field.addEventListener('blur', function () {
          normalizeMoneyField(field, false);
          showFieldMessage(field, '');
          calculateContracts();
        });
        field.addEventListener('input', function () {
          showFieldMessage(field, '');
          window.clearTimeout(field._contractTimer);
          field._contractTimer = window.setTimeout(calculateContracts, 120);
        });
      });
    });

    ['txtCPFCNPJ', 'txtEdCPF', 'txtChassiPlaca', 'txtEdChassi', 'txtPlacaVU', 'txtEdPlacaUSADO', 'txtUF', 'txtEdUF'].forEach(function (id) {
      allBySuffix(id).forEach(function (field) {
        if (field.getAttribute('data-contract-upper') === 'true') return;
        field.setAttribute('data-contract-upper', 'true');
        field.addEventListener('blur', function () {
          field.value = String(field.value || '').trim().toUpperCase();
          updateQualityPanel();
        });
      });
    });

    ['txtCliente', 'txtCPFCNPJ', 'txtMarca', 'txtModelo', 'txtChassiPlaca', 'ddlVendedor', 'txtEdCliente', 'txtEdCPF', 'txtEdMarca', 'txtEdModelo', 'txtEdChassi', 'txtEdVendedor'].forEach(function (id) {
      allBySuffix(id).forEach(function (field) {
        if (field.getAttribute('data-contract-watch') === 'true') return;
        field.setAttribute('data-contract-watch', 'true');
        field.addEventListener('input', updateQualityPanel);
        field.addEventListener('input', function () { showFieldMessage(field, ''); });
        field.addEventListener('change', function () {
          showFieldMessage(field, '');
          updateQualityPanel();
        });
      });
    });
  }

  function bindSubmitButtons() {
    ['btnGravar', 'btnEditareGravar'].forEach(function (id) {
      allBySuffix(id).forEach(function (button) {
        if (button.getAttribute('data-contract-submit') === 'true') return;
        button.setAttribute('data-contract-submit', 'true');
        button.addEventListener('click', handleSubmit);
      });
    });
  }

  function isContractPage() {
    return document.body && (' ' + document.body.className + ' ').indexOf(' bali-contract-page ') >= 0;
  }

  function bindAjaxEndRequest() {
    if (ajaxHooked) return;
    if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
      Sys.WebForms.PageRequestManager.getInstance().add_endRequest(init);
      ajaxHooked = true;
    }
  }

  function init() {
    if (!isContractPage()) return;
    enhanceFields();
    bindSubmitButtons();
    ensureQualityPanel();
    prepareMoneyFields(false);
    bindAjaxEndRequest();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
