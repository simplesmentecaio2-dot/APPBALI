(function () {
  var ajaxHooked = false;
  var dirtyHooked = false;
  var contractDirty = false;
  var contractAllowUnload = false;
  var draftTimer = null;
  var pageLoadedAt = new Date().getTime();
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

  var formatRules = [
    {
      ids: ['txtCPFCNPJ', 'txtEdCPF'],
      placeholder: 'CPF ou CNPJ',
      inputmode: 'numeric',
      numericBlank: true,
      validate: function (value) {
        var digits = digitsOnly(value);
        return digits.length === 11 || digits.length === 14;
      },
      message: 'CPF/CNPJ deve ter 11 ou 14 n\u00fameros.'
    },
    {
      ids: ['txtCEP', 'txtEdCep'],
      placeholder: '00000-000',
      inputmode: 'numeric',
      numericBlank: true,
      normalize: formatCep,
      validate: function (value) {
        return digitsOnly(value).length === 8;
      },
      message: 'CEP deve ter 8 n\u00fameros. Exemplo: 01001-000.'
    },
    {
      ids: ['txtUF', 'txtEdUF'],
      placeholder: 'UF',
      normalize: function (value) {
        return String(value || '').trim().toUpperCase();
      },
      validate: function (value) {
        return /^[A-Z]{2}$/.test(String(value || '').trim().toUpperCase());
      },
      message: 'UF deve ter 2 letras. Exemplo: SP.'
    },
    {
      ids: ['txtEmail', 'txtEdEmail'],
      placeholder: 'email@dominio.com',
      inputmode: 'email',
      normalize: function (value) {
        return String(value || '').trim().toLowerCase();
      },
      validate: function (value) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(value || '').trim());
      },
      message: 'Informe um e-mail v\u00e1lido. Exemplo: cliente@email.com.'
    },
    {
      ids: ['txtNascimento', 'txtEdNascimento'],
      placeholder: 'dd/mm/aaaa',
      inputmode: 'numeric',
      numericBlank: true,
      validate: function (value) {
        return !!parseDate(value);
      },
      message: 'Data deve estar no formato dd/mm/aaaa.'
    },
    {
      ids: ['txtTelREsidencial', 'txtTelCom', 'txtCelular', 'txtEdTelRes', 'txtEdComercial', 'txtEdCelular'],
      placeholder: '(00) 00000-0000',
      inputmode: 'tel',
      numericBlank: true,
      validate: function (value) {
        var digits = digitsOnly(value);
        return digits.length >= 10 && digits.length <= 11;
      },
      message: 'Telefone deve ter DDD + n\u00famero. Exemplo: (11) 99999-9999.'
    }
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

  function escapeHtml(value) {
    return String(value || '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function isVisible(field) {
    if (!field) return false;
    return !!(field.offsetWidth || field.offsetHeight || field.getClientRects().length);
  }

  function closestTag(element, tagName) {
    tagName = String(tagName || '').toUpperCase();
    while (element && element.nodeType === 1) {
      if (element.tagName === tagName) return element;
      element = element.parentNode;
    }
    return null;
  }

  function closestIdContains(element, text) {
    while (element && element.nodeType === 1) {
      if ((element.id || '').indexOf(text) >= 0) return true;
      element = element.parentNode;
    }
    return false;
  }

  function normalizeText(text) {
    text = String(text || '').toUpperCase();
    if (text.normalize) {
      text = text.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }
    return text.replace(/\s+/g, ' ').trim();
  }

  function addClass(element, className) {
    if (!element) return;
    var current = ' ' + String(element.className || '') + ' ';
    if (current.indexOf(' ' + className + ' ') < 0) {
      element.className = (element.className ? element.className + ' ' : '') + className;
    }
  }

  function closestClass(element, className) {
    while (element && element.nodeType === 1) {
      var current = ' ' + String(element.className || '') + ' ';
      if (current.indexOf(' ' + className + ' ') >= 0) return element;
      element = element.parentNode;
    }
    return null;
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

  function digitsOnly(value) {
    return String(value || '').replace(/\D/g, '');
  }

  function formatCep(value) {
    var digits = digitsOnly(value);
    if (digits.length !== 8) return String(value || '').trim();
    return digits.substr(0, 5) + '-' + digits.substr(5, 3);
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

  function padDatePart(value) {
    return value < 10 ? '0' + value : String(value);
  }

  function formatDate(value) {
    return padDatePart(value.getDate()) + '/' + padDatePart(value.getMonth() + 1) + '/' + value.getFullYear();
  }

  function parseDate(value) {
    var match = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(String(value || '').trim());
    if (!match) return null;

    var day = parseInt(match[1], 10);
    var month = parseInt(match[2], 10) - 1;
    var year = parseInt(match[3], 10);
    var date = new Date(year, month, day);

    if (date.getFullYear() !== year || date.getMonth() !== month || date.getDate() !== day) return null;
    return date;
  }

  function periodRange(type) {
    var now = new Date();
    var start;
    var end;

    if (type === 'today') {
      start = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      end = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    } else if (type === 'last7') {
      end = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      start = new Date(end.getFullYear(), end.getMonth(), end.getDate() - 6);
    } else if (type === 'previousMonth') {
      start = new Date(now.getFullYear(), now.getMonth() - 1, 1);
      end = new Date(now.getFullYear(), now.getMonth(), 0);
    } else {
      start = new Date(now.getFullYear(), now.getMonth(), 1);
      end = new Date(now.getFullYear(), now.getMonth() + 1, 0);
    }

    return { start: start, end: end };
  }

  function bySuffixIn(root, id) {
    return root && root.querySelector ? root.querySelector('[id$="' + id + '"]') : bySuffix(id);
  }

  function setPeriodFields(startField, endField, type) {
    if (!startField || !endField) return;
    if (type === 'clear') {
      startField.value = '';
      endField.value = '';
    } else {
      var range = periodRange(type);
      startField.value = formatDate(range.start);
      endField.value = formatDate(range.end);
    }

    [startField, endField].forEach(function (field) {
      field.classList.remove('contract-field-error');
      if (document.createEvent) {
        var event = document.createEvent('HTMLEvents');
        event.initEvent('change', true, false);
        field.dispatchEvent(event);
      }
    });
  }

  function validatePeriodFields(startField, endField) {
    var startText = startField ? String(startField.value || '').trim() : '';
    var endText = endField ? String(endField.value || '').trim() : '';

    if (!startText && !endText) return '';
    if (!startText || !endText) return 'Informe a data inicial e final para consultar.';

    var start = parseDate(startText);
    var end = parseDate(endText);
    if (!start || !end) return 'Use datas no formato dd/mm/aaaa.';
    if (start.getTime() > end.getTime()) return 'A data inicial não pode ser maior que a data final.';

    return '';
  }

  function periodShortcutHtml() {
    return [
      { type: 'currentMonth', label: 'Este mês' },
      { type: 'previousMonth', label: 'Mês anterior' },
      { type: 'last7', label: 'Últimos 7 dias' },
      { type: 'today', label: 'Hoje' },
      { type: 'clear', label: 'Limpar' }
    ].map(function (item) {
      return '<button type="button" class="contract-period-chip" data-period="' + item.type + '">' + item.label + '</button>';
    }).join('');
  }

  function bindPeriodShortcuts(host, startField, endField) {
    if (!host || host.getAttribute('data-contract-period-bound') === 'true') return;
    host.setAttribute('data-contract-period-bound', 'true');

    Array.prototype.slice.call(host.querySelectorAll('[data-period]')).forEach(function (button) {
      button.addEventListener('click', function () {
        setPeriodFields(startField, endField, button.getAttribute('data-period'));
        showPeriodMessage(host, '');
      });
    });
  }

  function showPeriodMessage(host, message) {
    if (!host || !host.querySelector) return;
    var target = host.querySelector('.contract-period-shortcuts') || host;
    var warning = target.querySelector('.contract-period-warning');
    if (!warning) {
      warning = document.createElement('small');
      warning.className = 'contract-period-warning';
      target.appendChild(warning);
    }

    warning.textContent = message || '';
    warning.style.display = message ? 'block' : 'none';
  }

  function bindPeriodValidation(host, button, startField, endField) {
    if (!button || button.getAttribute('data-contract-period-validation') === 'true') return;
    button.setAttribute('data-contract-period-validation', 'true');
    button.addEventListener('click', function (event) {
      var message = validatePeriodFields(startField, endField);
      if (!message) {
        [startField, endField].forEach(function (field) {
          if (field) field.classList.remove('contract-field-error');
        });
        showPeriodMessage(host, '');
        return true;
      }

      event.preventDefault();
      if (event.stopImmediatePropagation) event.stopImmediatePropagation();
      [startField, endField].forEach(function (field) {
        if (field) field.classList.add('contract-field-error');
      });
      showPeriodMessage(host, message);
      if (startField && startField.focus) startField.focus();
      return false;
    }, true);
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

  function isFormatBlank(rule, value) {
    if (rule.numericBlank) return digitsOnly(value).length === 0;
    return String(value || '').trim().length === 0;
  }

  function pushUniqueIssue(issues, message) {
    if (issues.indexOf(message) < 0) issues.push(message);
  }

  function collectFormatIssues(showMessages) {
    var issues = [];
    formatRules.forEach(function (rule) {
      rule.ids.forEach(function (id) {
        allBySuffix(id).forEach(function (field) {
          if (!field || !isVisible(field)) return;

          var value = String(field.value || '').trim();
          if (isFormatBlank(rule, value)) return;

          if (rule.normalize) {
            value = rule.normalize(value);
            field.value = value;
          }

          if (!rule.validate(value)) {
            pushUniqueIssue(issues, rule.message);
            if (showMessages) showFieldMessage(field, rule.message);
          } else if (showMessages) {
            showFieldMessage(field, '');
          }
        });
      });
    });
    return issues;
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

    issues = issues.concat(collectFormatIssues(showMessages));

    var financeField = bySuffix(isEdit ? 'txtEdFinanciamento' : 'txtVlFinanciamento');
    var financeValue = parseMoney(financeField ? financeField.value : '');
    var balanceField = bySuffix(isEdit ? 'txtEdSaldoAvaliacao' : 'txtSaldoAvaliacao');
    var balanceValue = parseMoney(balanceField ? balanceField.value : '');
    if (showMessages) {
      showFieldMessage(financeField, financeValue < 0 ? 'Valor calculado ficou negativo.' : '');
      showFieldMessage(balanceField, balanceValue < 0 ? 'Valor calculado ficou negativo.' : '');
    }
    if (financeValue < 0) issues.push('Financiamento ficou negativo. Confira valor, entrada e avaliação utilizada.');
    if (balanceValue < 0) issues.push('Saldo da avaliação ficou negativo. Confira avaliação, valor utilizado e quitação.');

    return issues;
  }

  function getQualityHost(isEdit) {
    var button = bySuffix(isEdit ? 'btnEditareGravar' : 'btnGravar');
    if (button && button.parentNode) return button.parentNode;
    return bySuffix(isEdit ? 'txtEdCliente' : 'Panel1');
  }

  function placeQualityPanel(panel, isEdit) {
    var host = getQualityHost(isEdit);
    if (!host) return false;

    var checklist = host.querySelector ? host.querySelector('.contract-checklist') : null;
    if (checklist && panel.nextSibling !== checklist) {
      host.insertBefore(panel, checklist);
    } else if (!checklist && panel.parentNode !== host) {
      host.appendChild(panel);
    }

    return true;
  }

  function hideSubmitSummary() {
    var existing = document.getElementById('contractSubmitSummary');
    if (existing) existing.classList.add('is-hidden');
  }

  function placeSubmitSummary(panel, isEdit) {
    var host = getQualityHost(isEdit);
    if (!host) return false;

    var quality = document.getElementById('contractQualityPanel');
    if (quality && quality.parentNode === host) {
      host.insertBefore(panel, quality);
    } else if (panel.parentNode !== host) {
      host.appendChild(panel);
    }

    return true;
  }

  function ensureSubmitSummary(isEdit) {
    var existing = document.getElementById('contractSubmitSummary');
    if (existing) {
      placeSubmitSummary(existing, isEdit);
      return existing;
    }

    var panel = document.createElement('div');
    panel.id = 'contractSubmitSummary';
    panel.className = 'contract-submit-summary is-hidden';
    panel.setAttribute('role', 'alert');
    placeSubmitSummary(panel, isEdit);
    return panel;
  }

  function uniqueIssues(issues) {
    var result = [];
    issues.forEach(function (issue) {
      if (issue && result.indexOf(issue) < 0) result.push(issue);
    });
    return result;
  }

  function showSubmitSummary(button, issues) {
    var list = uniqueIssues(issues);
    var panel = ensureSubmitSummary(isEditSubmit(button));
    if (!panel) return;

    var html = '<strong>Revise antes de gravar</strong><small>Corrija os campos marcados em vermelho e tente novamente.</small><ul>';
    list.slice(0, 8).forEach(function (issue) {
      html += '<li>' + escapeHtml(issue) + '</li>';
    });
    if (list.length > 8) {
      html += '<li>Mais ' + (list.length - 8) + ' pendência(s) no formulário.</li>';
    }
    html += '</ul>';

    panel.innerHTML = html;
    panel.classList.remove('is-hidden');
  }

  function focusFirstInvalidField() {
    var firstInvalid = document.querySelector('.contract-field-error');
    if (!firstInvalid) return;
    if (firstInvalid.scrollIntoView) {
      try {
        firstInvalid.scrollIntoView({ block: 'center', behavior: 'smooth' });
      } catch (ignore) {
        firstInvalid.scrollIntoView(true);
      }
    }
    window.setTimeout(function () {
      if (firstInvalid.focus) firstInvalid.focus();
    }, 220);
  }

  function ensureQualityPanel(isEdit) {
    var existing = document.getElementById('contractQualityPanel');
    if (existing) {
      placeQualityPanel(existing, isEdit);
      return existing;
    }

    var panel = document.createElement('div');
    panel.id = 'contractQualityPanel';
    panel.className = 'contract-quality-panel is-attention is-hidden';
    panel.innerHTML =
      '<div class="contract-quality-main">' +
      '<span class="contract-quality-label">Qualidade do contrato</span>' +
      '<strong id="contractQualityStatus">Atenção</strong>' +
      '<small id="contractQualityText">Preencha os campos principais para reduzir erros antes de gravar.</small>' +
      '</div>' +
      '<ul id="contractQualityList"></ul>';

    placeQualityPanel(panel, isEdit);
    return panel;
  }

  function updateQualityPanel() {
    var isEdit = !!(bySuffix('txtEdCliente') && isVisible(bySuffix('txtEdCliente')));
    var isNew = !!(bySuffix('txtCliente') && isVisible(bySuffix('txtCliente')));
    var panel = ensureQualityPanel(isEdit);
    if (!panel) return;

    if (!isEdit && !isNew) {
      panel.classList.add('is-hidden');
      return;
    }

    var issues = collectIssues(isEdit, false);
    var status = document.getElementById('contractQualityStatus');
    var text = document.getElementById('contractQualityText');
    var list = document.getElementById('contractQualityList');

    panel.classList.remove('is-hidden', 'is-good', 'is-attention', 'is-risk');
    if (issues.length === 0) {
      panel.classList.add('is-hidden');
      return;
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

  function enhanceDateFilters() {
    [
      { start: 'txtDtInicialVN', end: 'txtDtFinalVN', button: 'Button1' },
      { start: 'txtDtInicialVU', end: 'txtDtFinalVU', button: 'Button2' },
      { start: 'txtDtInicialVD', end: 'txtDtFinalVD', button: 'Button3' }
    ].forEach(function (filter) {
      allBySuffix(filter.start).forEach(function (field) {
        var table = closestTag(field, 'table');
        if (!table) return;
        var endField = bySuffixIn(table, filter.end);
        var button = bySuffix(filter.button);

        if (table.getAttribute('data-contract-date-filter') !== 'true') {
          table.setAttribute('data-contract-date-filter', 'true');
          table.className = (table.className ? table.className + ' ' : '') + 'contract-date-filter';

          var rows = table.rows;
          if (rows && rows.length > 1 && rows[0].cells.length < 3) {
            rows[0].insertCell(-1).innerHTML = '&nbsp;';
          }

          if (button && rows && rows.length > 1) {
            var targetCell = rows[1].cells.length >= 3 ? rows[1].cells[2] : rows[1].insertCell(-1);
            if (button.parentNode !== targetCell) targetCell.appendChild(button);
          }

          if (rows && rows.length > 1) {
            var shortcutRow = table.insertRow(2);
            shortcutRow.className = 'contract-date-shortcut-row';
            var shortcutCell = shortcutRow.insertCell(0);
            shortcutCell.colSpan = 3;
            shortcutCell.innerHTML = '<div class="contract-period-shortcuts">' + periodShortcutHtml() + '</div>';
          }
        }

        bindPeriodShortcuts(table, field, endField);
        bindPeriodValidation(table, button, field, endField);
      });
    });
  }

  function enhanceBiPeriodShortcuts() {
    var startField = bySuffix('txtBiDtInicial');
    var endField = bySuffix('txtBiDtFinal');
    var button = bySuffix('btnAtualizarBI');
    if (!startField || !endField || !button) return;

    var controls = closestTag(button, 'div');
    if (!controls || controls.getAttribute('data-contract-bi-period') === 'true') {
      bindPeriodValidation(controls, button, startField, endField);
      return;
    }

    controls.setAttribute('data-contract-bi-period', 'true');
    var shortcuts = document.createElement('div');
    shortcuts.className = 'contract-period-shortcuts contract-bi-shortcuts';
    shortcuts.innerHTML = periodShortcutHtml();
    controls.appendChild(shortcuts);

    bindPeriodShortcuts(shortcuts, startField, endField);
    bindPeriodValidation(controls, button, startField, endField);
  }

  function enhanceFormSections() {
    Array.prototype.slice.call(document.querySelectorAll('.ajax__tab_body table')).forEach(function (table) {
      if (table.getAttribute('data-contract-section') === 'true') return;
      if (table.className && /contract-date-filter|display|dataTable/.test(table.className)) return;
      if (!table.rows || !table.rows.length || !table.rows[0].cells || !table.rows[0].cells.length) return;

      var title = normalizeText(table.rows[0].cells[0].textContent);
      var section = '';
      if (title.indexOf('DADOS DO CLIENTE') >= 0) section = 'cliente';
      if (title.indexOf('DADOS DO VEICULO') >= 0) section = 'veiculo';
      if (title.indexOf('PRECO E FORMAS') >= 0 || title.indexOf('PREÇO E FORMAS') >= 0) section = 'pagamento';
      if (!section) return;

      table.setAttribute('data-contract-section', 'true');
      table.className = (table.className ? table.className + ' ' : '') + 'contract-form-section contract-section-' + section;
    });
  }

  function sectionLabel(section) {
    if (section === 'cliente') return 'Cliente';
    if (section === 'veiculo') return 'Veículo';
    if (section === 'pagamento') return 'Pagamento';
    return 'Etapa';
  }

  function enhanceSectionNavigator() {
    var sections = Array.prototype.slice.call(document.querySelectorAll('table.contract-form-section')).filter(isVisible);
    var nav = document.getElementById('contractSectionNav');

    if (sections.length < 2) {
      if (nav) nav.classList.add('is-hidden');
      return;
    }

    if (!nav) {
      nav = document.createElement('div');
      nav.id = 'contractSectionNav';
      nav.className = 'contract-section-nav';
    }

    var signature = sections.map(function (section) {
      return section.className;
    }).join('|');

    if (nav.getAttribute('data-section-signature') !== signature) {
      nav.setAttribute('data-section-signature', signature);
      nav.innerHTML = '<span>Ir para</span>';
      sections.forEach(function (section, index) {
        var match = /contract-section-([a-z]+)/.exec(section.className || '');
        var name = match ? match[1] : '';
        var button = document.createElement('button');
        button.type = 'button';
        button.textContent = sectionLabel(name);
        button.setAttribute('data-section-index', index);
        button.addEventListener('click', function () {
          var target = sections[parseInt(button.getAttribute('data-section-index'), 10)];
          if (!target) return;
          try {
            target.scrollIntoView({ block: 'start', behavior: 'smooth' });
          } catch (ignore) {
            target.scrollIntoView(true);
          }
        });
        nav.appendChild(button);
      });
    }

    nav.classList.remove('is-hidden');
    if (nav.parentNode !== sections[0].parentNode || nav.nextSibling !== sections[0]) {
      sections[0].parentNode.insertBefore(nav, sections[0]);
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

    if (!missing) {
      showChecklistMessage(button, '');
      return true;
    }

    showChecklistMessage(button, isEditSubmit(button)
      ? 'Confirme o checklist da edição antes de gravar.'
      : 'Confirme o checklist final antes de gravar o contrato.');

    var first = ids.map(bySuffix).filter(Boolean)[0];
    if (first && first.focus) first.focus();
    return false;
  }

  function getChecklistForButton(button) {
    var host = button && button.parentNode;
    if (host && host.querySelector) {
      var local = host.querySelector('.contract-checklist');
      if (local) return local;
    }
    return null;
  }

  function showChecklistMessage(button, message) {
    var checklist = getChecklistForButton(button);
    if (!checklist) return;

    var warning = checklist.querySelector('.contract-checklist-warning');
    if (!warning) {
      warning = document.createElement('small');
      warning.className = 'contract-checklist-warning';
      checklist.appendChild(warning);
    }

    warning.textContent = message || '';
    warning.style.display = message ? 'block' : 'none';
  }

  function markSubmitting(button) {
    if (!button) return;
    button.setAttribute('data-contract-submitting', 'true');
    button.setAttribute('aria-busy', 'true');
    if (!button.getAttribute('data-contract-label') && button.value) {
      button.setAttribute('data-contract-label', button.value);
      button.value = 'Gravando...';
    }
    if ((' ' + button.className + ' ').indexOf(' is-submitting ') < 0) {
      button.className = (button.className ? button.className + ' ' : '') + 'is-submitting';
    }
  }

  function resetSubmittingButtons() {
    Array.prototype.slice.call(document.querySelectorAll('[data-contract-submitting="true"]')).forEach(function (button) {
      button.removeAttribute('data-contract-submitting');
      button.removeAttribute('aria-busy');
      if (button.getAttribute('data-contract-label')) {
        button.value = button.getAttribute('data-contract-label');
        button.removeAttribute('data-contract-label');
      }
      button.className = String(button.className || '').replace(/\bis-submitting\b/g, '').replace(/\s+/g, ' ').trim();
    });
    contractAllowUnload = false;
    hideSubmitSummary();
  }

  function setLoadingVisible(visible) {
    var indicator = document.getElementById('ag');
    if (!indicator) return;
    indicator.style.display = visible ? 'inline-flex' : 'none';
  }

  function enhanceLoadingIndicator() {
    window.aguarde = function () {
      setLoadingVisible(true);
      return true;
    };
    setLoadingVisible(false);
  }

  function ensureDirtyNotice() {
    var notice = document.getElementById('contractDirtyNotice');
    if (notice) return notice;

    notice = document.createElement('div');
    notice.id = 'contractDirtyNotice';
    notice.className = 'contract-dirty-notice is-hidden';
    notice.setAttribute('role', 'status');
    notice.textContent = 'Alterações não salvas';
    document.body.appendChild(notice);
    return notice;
  }

  function updateDirtyNotice() {
    var notice = ensureDirtyNotice();
    if (!notice) return;
    if (contractDirty) {
      notice.classList.remove('is-hidden');
    } else {
      notice.classList.add('is-hidden');
    }
  }

  function isDirtyTrackedField(field) {
    if (!field || field.disabled || field.readOnly) return false;
    var type = String(field.type || '').toLowerCase();
    if (type === 'hidden' || type === 'submit' || type === 'button' || type === 'image') return false;
    return !!(closestClass(field, 'contract-form-section') || closestClass(field, 'contract-checklist'));
  }

  function canUseStorage() {
    try {
      var key = '__bali_contract_storage__';
      window.localStorage.setItem(key, '1');
      window.localStorage.removeItem(key);
      return true;
    } catch (ignore) {
      return false;
    }
  }

  function draftKey() {
    var path = String(window.location.pathname || '').toLowerCase();
    var editVisible = !!(bySuffix('txtEdCliente') && isVisible(bySuffix('txtEdCliente')));
    if (editVisible) {
      return 'bali-contract-draft:' + path + ':editar:' + (valueOf('txtContrato') || 'sem-id');
    }
    return 'bali-contract-draft:' + path + ':novo';
  }

  function draftFields() {
    return Array.prototype.slice.call(document.querySelectorAll('input, select, textarea')).filter(isDirtyTrackedField);
  }

  function fieldDraftKey(field) {
    return field.id || field.name || '';
  }

  function readDraftField(field) {
    var type = String(field.type || '').toLowerCase();
    if (type === 'checkbox' || type === 'radio') return field.checked;
    return field.value;
  }

  function writeDraftField(field, value) {
    var type = String(field.type || '').toLowerCase();
    if (type === 'checkbox' || type === 'radio') {
      field.checked = value === true || value === 'true';
    } else {
      field.value = value == null ? '' : String(value);
    }
  }

  function collectDraft() {
    var fields = {};
    var hasValue = false;
    draftFields().forEach(function (field) {
      var key = fieldDraftKey(field);
      if (!key) return;
      var value = readDraftField(field);
      fields[key] = value;
      if (value === true || String(value || '').trim().length > 0) hasValue = true;
    });

    if (!hasValue) return null;
    return {
      version: 1,
      savedAt: new Date().getTime(),
      path: window.location.pathname,
      fields: fields
    };
  }

  function saveContractDraft() {
    if (!canUseStorage()) return;
    var draft = collectDraft();
    try {
      if (!draft) {
        window.localStorage.removeItem(draftKey());
      } else {
        window.localStorage.setItem(draftKey(), JSON.stringify(draft));
      }
    } catch (ignore) {
    }
  }

  function scheduleDraftSave() {
    window.clearTimeout(draftTimer);
    draftTimer = window.setTimeout(saveContractDraft, 350);
  }

  function readContractDraft() {
    if (!canUseStorage()) return null;
    try {
      var raw = window.localStorage.getItem(draftKey());
      return raw ? JSON.parse(raw) : null;
    } catch (ignore) {
      return null;
    }
  }

  function clearContractDraft() {
    window.clearTimeout(draftTimer);
    if (!canUseStorage()) return;
    try {
      window.localStorage.removeItem(draftKey());
    } catch (ignore) {
    }
  }

  function hideDraftPanel() {
    var panel = document.getElementById('contractDraftPanel');
    if (panel) panel.classList.add('is-hidden');
  }

  function ensureDraftPanel(isEdit) {
    var existing = document.getElementById('contractDraftPanel');
    var host = getQualityHost(isEdit);
    if (!host) return null;

    if (existing) {
      if (existing.parentNode !== host) host.insertBefore(existing, host.firstChild);
      return existing;
    }

    var panel = document.createElement('div');
    panel.id = 'contractDraftPanel';
    panel.className = 'contract-draft-panel is-hidden';
    panel.innerHTML =
      '<div><strong>Rascunho encontrado</strong><small>Existe um preenchimento salvo neste navegador.</small></div>' +
      '<div class="contract-draft-actions">' +
      '<button type="button" data-draft-action="restore">Recuperar</button>' +
      '<button type="button" data-draft-action="discard">Descartar</button>' +
      '</div>';
    host.insertBefore(panel, host.firstChild);
    return panel;
  }

  function restoreContractDraft(draft) {
    if (!draft || !draft.fields) return;
    draftFields().forEach(function (field) {
      var key = fieldDraftKey(field);
      if (key && Object.prototype.hasOwnProperty.call(draft.fields, key)) {
        writeDraftField(field, draft.fields[key]);
        showFieldMessage(field, '');
      }
    });
    calculateContracts();
    contractDirty = true;
    updateDirtyNotice();
    hideDraftPanel();
    updateQualityPanel();
  }

  function enhanceDraftRecovery() {
    var fields = draftFields();
    if (!fields.length) {
      hideDraftPanel();
      return;
    }

    var draft = readContractDraft();
    if (!draft || !draft.fields || !draft.savedAt || draft.savedAt >= pageLoadedAt) {
      hideDraftPanel();
      return;
    }

    var panel = ensureDraftPanel(!!(bySuffix('txtEdCliente') && isVisible(bySuffix('txtEdCliente'))));
    if (!panel || panel.getAttribute('data-draft-bound') === 'true') {
      if (panel) panel.classList.remove('is-hidden');
      return;
    }

    panel.setAttribute('data-draft-bound', 'true');
    Array.prototype.slice.call(panel.querySelectorAll('[data-draft-action]')).forEach(function (button) {
      button.addEventListener('click', function () {
        if (button.getAttribute('data-draft-action') === 'restore') {
          restoreContractDraft(readContractDraft());
        } else {
          clearContractDraft();
          hideDraftPanel();
        }
      });
    });
    panel.classList.remove('is-hidden');
  }

  function markContractDirty(event) {
    if (!isDirtyTrackedField(event.currentTarget)) return;
    contractDirty = true;
    updateDirtyNotice();
    hideSubmitSummary();
    scheduleDraftSave();
  }

  function enhanceUnsavedWarning() {
    Array.prototype.slice.call(document.querySelectorAll('input, select, textarea')).forEach(function (field) {
      if (field.getAttribute('data-contract-dirty') === 'true') return;
      if (!isDirtyTrackedField(field)) return;
      field.setAttribute('data-contract-dirty', 'true');
      field.addEventListener('input', markContractDirty);
      field.addEventListener('change', markContractDirty);
    });

    if (!dirtyHooked) {
      window.addEventListener('beforeunload', function (event) {
        if (!contractDirty || contractAllowUnload) return;
        event.preventDefault();
        event.returnValue = '';
        return '';
      });
      dirtyHooked = true;
    }

    updateDirtyNotice();
  }

  function handleSubmit(event) {
    var button = event.currentTarget;
    if (button.getAttribute('data-contract-submitting') === 'true') {
      event.preventDefault();
      return false;
    }

    if (button.getAttribute('data-contract-confirmed') === 'true') {
      button.removeAttribute('data-contract-confirmed');
      prepareMoneyFields(true);
      contractAllowUnload = true;
      markSubmitting(button);
      return true;
    }

    prepareMoneyFields(true);
    var issues = collectIssues(isEditSubmit(button), true);
    if (issues.length) {
      showSubmitSummary(button, issues);
      focusFirstInvalidField();
      event.preventDefault();
      updateQualityPanel();
      return false;
    }

    if (!validateInlineChecklist(button)) {
      showSubmitSummary(button, ['Confirme o checklist final antes de gravar.']);
      event.preventDefault();
      return false;
    }

    hideSubmitSummary();
    contractAllowUnload = true;
    markSubmitting(button);
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

  function enhanceFormatFields() {
    formatRules.forEach(function (rule) {
      rule.ids.forEach(function (id) {
        allBySuffix(id).forEach(function (field) {
          if (field.getAttribute('data-contract-format') === 'true') return;
          field.setAttribute('data-contract-format', 'true');
          if (rule.placeholder) field.setAttribute('placeholder', rule.placeholder);
          if (rule.inputmode) field.setAttribute('inputmode', rule.inputmode);
          field.setAttribute('autocomplete', rule.inputmode === 'email' ? 'email' : 'off');

          field.addEventListener('blur', function () {
            if (rule.normalize && !isFormatBlank(rule, field.value)) {
              field.value = rule.normalize(field.value);
            }
            collectFormatIssues(true);
            updateQualityPanel();
          });

          field.addEventListener('input', function () {
            showFieldMessage(field, '');
            updateQualityPanel();
          });
        });
      });
    });
  }

  function inferPrintPage(table) {
    var className = ' ' + (document.body ? document.body.className : '') + ' ';
    var isUsedTable = /tblConsultaProcesso2$/i.test(table.id || '') || closestIdContains(table, 'TabPanel1');
    var isDirectSale = closestIdContains(table, 'TabPanel4');

    if (className.indexOf(' contrato-jeep ') >= 0) {
      return isUsedTable ? 'Print-ContratoVUJEEP.aspx' : 'Print-ContratoVNJEEP.aspx';
    }

    if (className.indexOf(' contrato-byd ') >= 0) {
      return isUsedTable ? 'Print-ContratoVUBYD.aspx' : 'Print-ContratoVNBYD.aspx';
    }

    if (isDirectSale) return 'Print-ContratoVD.aspx';
    if (isUsedTable) return 'Print-ContratoVU.aspx';
    return 'Print-ContratoVN.aspx';
  }

  function getContractIdFromCell(cell) {
    var text = normalizeText(cell ? cell.textContent : '').replace(/[^0-9]/g, '');
    return text || '';
  }

  function contractUrlForCell(cell, table) {
    if (!cell || !table) return '';

    var link = cell.querySelector ? cell.querySelector('a[href]') : null;
    if (link) return link.getAttribute('href') || '';

    var id = getContractIdFromCell(cell);
    if (!id) return '';

    return inferPrintPage(table) + '?contrato=' + encodeURIComponent(id);
  }

  function prepareLookupIdCells(table) {
    if (!table || !table.tBodies || !table.tBodies.length) return;

    Array.prototype.slice.call(table.tBodies[0].rows).forEach(function (row) {
      if (!row.cells || !row.cells.length) return;
      var cell = row.cells[0];
      var url = contractUrlForCell(cell, table);
      if (!url) return;

      addClass(cell, 'contract-id-cell');
      cell.setAttribute('title', 'Abrir contrato para impressão');

      var link = cell.querySelector ? cell.querySelector('a[href]') : null;
      if (link) {
        addClass(link, 'contract-id-action');
      } else {
        cell.setAttribute('role', 'button');
        cell.setAttribute('tabindex', '0');
        cell.setAttribute('data-contract-url', url);
      }
    });
  }

  function openLookupCell(cell, table) {
    var url = contractUrlForCell(cell, table);
    if (url) window.location.href = url;
  }

  function enhanceLookupTables() {
    Array.prototype.slice.call(document.querySelectorAll('#tblConsultaProcesso, #tblConsultaProcesso2, table.display, table.dataTable')).forEach(function (table) {
      if (!table || table.getAttribute('data-contract-lookup') === 'true') {
        prepareLookupIdCells(table);
        return;
      }

      table.setAttribute('data-contract-lookup', 'true');
      addClass(table, 'contract-lookup-table');
      prepareLookupIdCells(table);

      table.addEventListener('dblclick', function (event) {
        var cell = closestTag(event.target, 'td');
        if (!cell || cell.cellIndex !== 0 || cell.querySelector('a[href]')) return;
        openLookupCell(cell, table);
      });

      table.addEventListener('keydown', function (event) {
        var cell = closestTag(event.target, 'td');
        if (!cell || cell.cellIndex !== 0 || cell.querySelector('a[href]')) return;
        if (event.key === 'Enter' || event.keyCode === 13) {
          event.preventDefault();
          openLookupCell(cell, table);
        }
      });
    });

    Array.prototype.slice.call(document.querySelectorAll('.dataTables_filter input')).forEach(function (input) {
      if (input.getAttribute('data-contract-filter') === 'true') return;
      input.setAttribute('data-contract-filter', 'true');
      input.setAttribute('placeholder', 'Cliente, CPF, vendedor...');
      input.setAttribute('aria-label', 'Filtrar contratos');
    });
  }

  function enhanceChecklist() {
    Array.prototype.slice.call(document.querySelectorAll('.contract-check input')).forEach(function (field) {
      if (field.getAttribute('data-contract-check-enhanced') === 'true') return;
      field.setAttribute('data-contract-check-enhanced', 'true');

      var label = closestTag(field, 'label');
      var toggle = function () {
        if (!label) return;
        var currentClass = ' ' + String(label.className || '') + ' ';
        if (field.checked) {
          if (currentClass.indexOf(' is-checked ') < 0) {
            label.className = (label.className ? label.className + ' ' : '') + 'is-checked';
          }
        } else {
          label.className = String(label.className || '').replace(/\bis-checked\b/g, '').replace(/\s+/g, ' ').trim();
        }
      };

      field.addEventListener('change', function () {
        toggle();
        var checklist = closestTag(field, 'div');
        var warning = checklist && checklist.parentNode ? checklist.parentNode.querySelector('.contract-checklist-warning') : null;
        if (warning) {
          warning.textContent = '';
          warning.style.display = 'none';
        }
      });
      toggle();
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
    resetSubmittingButtons();
    enhanceLoadingIndicator();
    enhanceFields();
    enhanceFormatFields();
    enhanceChecklist();
    enhanceDateFilters();
    enhanceBiPeriodShortcuts();
    enhanceFormSections();
    enhanceSectionNavigator();
    enhanceUnsavedWarning();
    enhanceDraftRecovery();
    enhanceLookupTables();
    bindSubmitButtons();
    prepareMoneyFields(false);
    updateQualityPanel();
    bindAjaxEndRequest();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
