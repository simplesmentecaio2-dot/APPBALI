(function () {
  var ajaxHooked = false;
  var dirtyHooked = false;
  var contractDirty = false;
  var contractAllowUnload = false;
  var draftTimer = null;
  var pageLoadedAt = new Date().getTime();
  var contractStepIndex = 0;
  var contractStepSignature = '';
  var wizardKeyboardBound = false;
  var qualityUpdateTimer = null;
  var editChangeTimer = null;
  var draftMaxAgeMs = 72 * 60 * 60 * 1000;
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

  var editTrackedFields = [
    { id: 'txtEdCliente', label: 'Cliente' },
    { id: 'txtEdEndereco', label: 'Endereço' },
    { id: 'txtEdCep', label: 'CEP' },
    { id: 'txtEdBairro', label: 'Bairro' },
    { id: 'txtEdCidade', label: 'Cidade' },
    { id: 'txtEdUF', label: 'UF' },
    { id: 'txtEdCPF', label: 'CPF/CNPJ' },
    { id: 'txtEdRG', label: 'RG/I.E.' },
    { id: 'txtEdNascimento', label: 'Data de nascimento' },
    { id: 'txtEdTelRes', label: 'Telefone residencial' },
    { id: 'txtEdComercial', label: 'Telefone comercial' },
    { id: 'txtEdCelular', label: 'Celular' },
    { id: 'txtEdEmail', label: 'E-mail' },
    { id: 'txtEdMarca', label: 'Marca' },
    { id: 'txtEdModelo', label: 'Modelo' },
    { id: 'txtEdCorExt', label: 'Cor externa' },
    { id: 'txtEdChassi', label: 'Chassi/placa' },
    { id: 'txtEdAnomodelo', label: 'Ano/modelo' },
    { id: 'txtEdOpcionais', label: 'Opcionais' },
    { id: 'txtEdFinanceira', label: 'Financeira' },
    { id: 'txtEdValorVeic', label: 'Valor do veículo' },
    { id: 'txtEdTAXAS', label: 'Taxas' },
    { id: 'txtEdEntrada', label: 'Entrada' },
    { id: 'txtEdFormasPagamento', label: 'Formas de pagamento' },
    { id: 'txtEdValorUSADO', label: 'Avaliação usado' },
    { id: 'txtEdModMarcaUSADO', label: 'Modelo/marca usado' },
    { id: 'txtEdAnoMOdUSADO', label: 'Ano/modelo usado' },
    { id: 'txtEdPlacaUSADO', label: 'Placa usado' },
    { id: 'txtEdVALORUSADOAVAILACAO', label: 'Valor utilizado avaliação' },
    { id: 'txtEdQuitacao', label: 'Quitação' },
    { id: 'txtEdSaldoAvaliacao', label: 'Saldo avaliação' },
    { id: 'txtEdFinanciamento', label: 'Financiamento' },
    { id: 'txtEdNumeroParcelas', label: 'Nº parcelas' },
    { id: 'txtEdValorParcela', label: 'Valor parcela' },
    { id: 'txtEdPlanoFinanciamento', label: 'Plano financiamento' },
    { id: 'txtEdCortesias', label: 'Cortesias' },
    { id: 'txtEdObs', label: 'Observações' },
    { id: 'txtEdPrevisao', label: 'Previsão' },
    { id: 'txtEdVendedor', label: 'Vendedor' },
    { id: 'rbtnEdAVISTA', label: 'Pagamento à vista', checked: true },
    { id: 'rbtnEdAprazo', label: 'Pagamento financiamento', checked: true }
  ];

  var sectionRequirements = {
    novo: {
      cliente: ['txtCliente', 'txtCPFCNPJ'],
      veiculo: ['txtMarca', 'txtModelo', 'txtChassiPlaca'],
      pagamento: ['txtValoVeiculo', 'ddlVendedor']
    },
    edicao: {
      cliente: ['txtEdCliente', 'txtEdCPF'],
      veiculo: ['txtEdMarca', 'txtEdModelo', 'txtEdChassi'],
      pagamento: ['txtEdValorVeic', 'txtEdVendedor']
    }
  };

  var paymentRules = {
    novo: {
      cash: 'rBtnModPagVista',
      finance: 'rBtnModPagFinanciamento',
      financeValue: 'txtVlFinanciamento',
      parcels: 'txtNrParcelas',
      parcelValue: 'txtVlParcelas'
    },
    edicao: {
      cash: 'rbtnEdAVISTA',
      finance: 'rbtnEdAprazo',
      financeValue: 'txtEdFinanciamento',
      parcels: 'txtEdNumeroParcelas',
      parcelValue: 'txtEdValorParcela'
    }
  };

  var checklistRequirements = {
    novo: ['chkConfereDocumento', 'chkConfereValores', 'chkConferePagamento'],
    edicao: ['chkConfereEdicao']
  };

  var formatRules = [
    {
      ids: ['txtCPFCNPJ', 'txtEdCPF'],
      placeholder: 'CPF ou CNPJ',
      inputmode: 'numeric',
      numericBlank: true,
      maxLength: 18,
      normalize: formatCpfCnpj,
      validate: function (value) {
        var digits = digitsOnly(value);
        return digits.length === 11 || digits.length === 14;
      },
      message: 'CPF/CNPJ deve ter 11 ou 14 n\u00fameros.'
    },
    {
      ids: ['txtChassiPlaca', 'txtEdChassi'],
      placeholder: 'Placa ou chassi',
      normalize: normalizePlateOrChassi,
      validate: function (value) {
        var length = lettersNumbersOnly(value).length;
        return length >= 7;
      },
      message: 'Placa ou chassi deve ter pelo menos 7 letras/números.'
    },
    {
      ids: ['txtPlacaVU', 'txtEdPlacaUSADO'],
      placeholder: 'Placa do usado',
      normalize: normalizePlateOrChassi,
      validate: function (value) {
        return lettersNumbersOnly(value).length >= 7;
      },
      message: 'Placa do usado deve ter pelo menos 7 letras/números quando preenchida.'
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
      ids: ['txtNrParcelas', 'txtEdNumeroParcelas'],
      placeholder: '1 a 120',
      inputmode: 'numeric',
      numericBlank: true,
      maxLength: 3,
      normalize: function (value) {
        return digitsOnly(value).slice(0, 3);
      },
      validate: validInstallments,
      message: 'Quantidade de parcelas deve ser um número entre 1 e 120.'
    },
    {
      ids: ['txtTelREsidencial', 'txtTelCom', 'txtCelular', 'txtEdTelRes', 'txtEdComercial', 'txtEdCelular'],
      placeholder: '(00) 00000-0000',
      inputmode: 'tel',
      numericBlank: true,
      maxLength: 15,
      normalize: formatPhone,
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

  function elementContains(parent, child) {
    if (!parent || !child) return false;
    if (parent.contains) return parent.contains(child);
    while (child) {
      if (child === parent) return true;
      child = child.parentNode;
    }
    return false;
  }

  function getWizardHost() {
    var current = document.querySelector('[data-contract-wizard-host="true"]');
    if (current && isVisible(current)) return current;

    Array.prototype.slice.call(document.querySelectorAll('[data-contract-wizard-host="true"]')).forEach(function (host) {
      host.removeAttribute('data-contract-wizard-host');
    });

    var buttons = ['btnEditareGravar', 'btnGravar'];
    for (var i = 0; i < buttons.length; i++) {
      var button = bySuffix(buttons[i]);
      if (button && button.parentNode && isVisible(button.parentNode)) {
        button.parentNode.setAttribute('data-contract-wizard-host', 'true');
        return button.parentNode;
      }
    }

    var section = Array.prototype.slice.call(document.querySelectorAll('table.contract-form-section')).filter(isVisible)[0];
    if (section && section.parentNode) {
      section.parentNode.setAttribute('data-contract-wizard-host', 'true');
      return section.parentNode;
    }

    return null;
  }

  function isRelevantContractField(field) {
    if (!field) return false;
    if (isVisible(field)) return true;
    var host = getWizardHost();
    return !!(host && elementContains(host, field));
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

  function removeClass(element, className) {
    if (!element) return;
    element.className = String(element.className || '').replace(new RegExp('\\b' + className + '\\b', 'g'), '').replace(/\s+/g, ' ').trim();
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
      } else if (dots === 1) {
        var parts = text.split('.');
        if (parts[1] && parts[1].length > 2) {
          text = parts[0] + parts[1];
        }
      }
    }

    text = text.replace(/[^0-9.-]/g, '');
    var parsed = parseFloat(text);
    return isNaN(parsed) ? 0 : parsed;
  }

  function digitsOnly(value) {
    return String(value || '').replace(/\D/g, '');
  }

  function lettersNumbersOnly(value) {
    return String(value || '').replace(/[^0-9a-zA-Z]/g, '');
  }

  function validInstallments(value) {
    var digits = digitsOnly(value);
    var number = parseInt(digits, 10);
    return digits.length > 0 && !isNaN(number) && number > 0 && number <= 120;
  }

  function validSelectedText(value) {
    var text = String(value || '').trim();
    if (!text || text === '0' || text === '-1') return false;
    return !/^selecion(e|ar)$/i.test(text);
  }

  function formatCep(value) {
    var digits = digitsOnly(value);
    if (digits.length !== 8) return String(value || '').trim();
    return digits.substr(0, 5) + '-' + digits.substr(5, 3);
  }

  function formatCpfCnpj(value) {
    var digits = digitsOnly(value);
    if (digits.length === 11) {
      return digits.substr(0, 3) + '.' + digits.substr(3, 3) + '.' + digits.substr(6, 3) + '-' + digits.substr(9, 2);
    }
    if (digits.length === 14) {
      return digits.substr(0, 2) + '.' + digits.substr(2, 3) + '.' + digits.substr(5, 3) + '/' + digits.substr(8, 4) + '-' + digits.substr(12, 2);
    }
    return String(value || '').trim();
  }

  function formatPhone(value) {
    var digits = digitsOnly(value);
    if (digits.length === 10) {
      return '(' + digits.substr(0, 2) + ') ' + digits.substr(2, 4) + '-' + digits.substr(6, 4);
    }
    if (digits.length === 11) {
      return '(' + digits.substr(0, 2) + ') ' + digits.substr(2, 5) + '-' + digits.substr(7, 4);
    }
    return String(value || '').trim();
  }

  function normalizePlateOrChassi(value) {
    return lettersNumbersOnly(value).toUpperCase();
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

  function sanitizeMoneyTyping(value) {
    var text = String(value || '').replace(/R\$/g, '').replace(/[^\d,.-]/g, '');
    var negative = text.charAt(0) === '-';
    text = text.replace(/-/g, '');

    var comma = text.indexOf(',');
    if (comma >= 0) {
      text = text.substr(0, comma + 1) + text.substr(comma + 1).replace(/,/g, '');
    }

    return (negative ? '-' : '') + text;
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
      button.setAttribute('aria-pressed', 'false');
      button.addEventListener('click', function () {
        var type = button.getAttribute('data-period');
        setPeriodFields(startField, endField, type);
        updatePeriodShortcutState(host, type);
        showPeriodMessage(host, '');
      });
    });

    [startField, endField].forEach(function (field) {
      if (!field || field.getAttribute('data-contract-period-manual') === 'true') return;
      field.setAttribute('data-contract-period-manual', 'true');
      field.addEventListener('input', function () { updatePeriodShortcutState(host, ''); });
      field.addEventListener('change', function () { updatePeriodShortcutState(host, ''); });
    });
  }

  function updatePeriodShortcutState(host, activeType) {
    if (!host || !host.querySelectorAll) return;
    Array.prototype.slice.call(host.querySelectorAll('[data-period]')).forEach(function (button) {
      var active = activeType && button.getAttribute('data-period') === activeType;
      if (active) addClass(button, 'is-active');
      else removeClass(button, 'is-active');
      button.setAttribute('aria-pressed', active ? 'true' : 'false');
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
      field.removeAttribute('aria-invalid');
      field.removeAttribute('aria-describedby');
      if (existing) existing.parentNode.removeChild(existing);
      return;
    }

    field.classList.add('contract-field-error');
    if (!existing) {
      existing = document.createElement('div');
      existing.className = 'contract-field-message';
      existing.id = 'contract-field-message-' + Math.random().toString(36).slice(2);
      host.appendChild(existing);
    }
    existing.textContent = message;
    field.setAttribute('aria-invalid', 'true');
    field.setAttribute('aria-describedby', existing.id);
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

    scheduleQualityPanelUpdate();
  }

  function scheduleQualityPanelUpdate() {
    window.clearTimeout(qualityUpdateTimer);
    qualityUpdateTimer = window.setTimeout(updateQualityPanel, 80);
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
          if (!field || !isRelevantContractField(field)) return;

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
      if (!field || !isRelevantContractField(field)) return;

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
    var chassi = bySuffix(isEdit ? 'txtEdChassi' : 'txtChassiPlaca');
    if (chassi && isRelevantContractField(chassi) && String(chassi.value || '').trim().length > 0 && lettersNumbersOnly(chassi.value).length < 7) {
      issues.push('Chassi/placa deve ter pelo menos 7 letras ou números.');
      if (showMessages) showFieldMessage(chassi, 'Use placa ou chassi com pelo menos 7 caracteres.');
    }
    if (vista && financiamento && !vista.checked && !financiamento.checked) {
      issues.push('Selecione a modalidade de pagamento.');
      if (showMessages) showFieldMessage(financiamento, 'Selecione à vista ou financiamento.');
    } else if (financiamento) {
      if (showMessages) showFieldMessage(financiamento, '');
    }

    if ((financiamento && financiamento.checked) || parseMoney(valueOf(isEdit ? 'txtEdFinanciamento' : 'txtVlFinanciamento')) > 0) {
      var parcels = bySuffix(isEdit ? 'txtEdNumeroParcelas' : 'txtNrParcelas');
      var parcelValue = bySuffix(isEdit ? 'txtEdValorParcela' : 'txtVlParcelas');
      if (parcels && isRelevantContractField(parcels) && !validInstallments(parcels.value)) {
        issues.push('Quantidade de parcelas deve ser um número entre 1 e 120.');
        if (showMessages) showFieldMessage(parcels, 'Use um número entre 1 e 120.');
      } else {
        if (showMessages) showFieldMessage(parcels, '');
      }
      if (parcelValue && isRelevantContractField(parcelValue) && parseMoney(parcelValue.value) <= 0) {
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
    var entryField = bySuffix(isEdit ? 'txtEdEntrada' : 'txtEntrada');
    var usedAppliedField = bySuffix(isEdit ? 'txtEdVALORUSADOAVAILACAO' : 'txtVlUtilzadoAvaliacao');
    var usedValueField = bySuffix(isEdit ? 'txtEdValorUSADO' : 'txtCarroUsado');
    var payoffField = bySuffix(isEdit ? 'txtEdQuitacao' : 'txtQuitacao');
    var entryValue = parseMoney(entryField ? entryField.value : '');
    var usedAppliedValue = parseMoney(usedAppliedField ? usedAppliedField.value : '');
    var usedValue = parseMoney(usedValueField ? usedValueField.value : '');
    var payoffValue = parseMoney(payoffField ? payoffField.value : '');

    if (showMessages) {
      var financeMessage = financeValue < 0 ? 'Entrada + avaliação utilizada não podem superar o valor do veículo.' : '';
      showFieldMessage(financeField, financeMessage);
      showFieldMessage(entryField, financeMessage && entryValue > 0 ? financeMessage : '');
      showFieldMessage(usedAppliedField, financeMessage && usedAppliedValue > 0 ? financeMessage : '');

      var balanceMessage = balanceValue < 0 ? 'Quitação + valor utilizado não podem superar a avaliação do usado.' : '';
      showFieldMessage(balanceField, balanceMessage);
      showFieldMessage(payoffField, balanceMessage && payoffValue > 0 ? balanceMessage : '');
      showFieldMessage(usedValueField, balanceMessage && usedValue > 0 ? balanceMessage : '');
    }
    if (financeValue < 0) issues.push('Financiamento ficou negativo: entrada + avaliação utilizada superam o valor do veículo.');
    if (balanceValue < 0) issues.push('Saldo da avaliação ficou negativo: quitação + valor utilizado superam a avaliação do usado.');

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
    panel.setAttribute('aria-live', 'assertive');
    panel.setAttribute('tabindex', '-1');
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
    if (panel.focus) {
      try {
        panel.focus({ preventScroll: true });
      } catch (ignore) {
        panel.focus();
      }
    }
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
      firstInvalid.classList.add('contract-field-attention');
      window.setTimeout(function () {
        firstInvalid.classList.remove('contract-field-attention');
      }, 1200);
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
    panel.setAttribute('role', 'status');
    panel.setAttribute('aria-live', 'polite');
    panel.innerHTML =
      '<div class="contract-quality-main">' +
      '<span class="contract-quality-label">Qualidade do contrato</span>' +
      '<strong id="contractQualityStatus">Atenção</strong>' +
      '<em id="contractQualityCount" class="contract-quality-count">Aguardando preenchimento</em>' +
      '<small id="contractQualityText">Preencha os campos principais para reduzir erros antes de gravar.</small>' +
      '</div>' +
      '<ul id="contractQualityList"></ul>';

    placeQualityPanel(panel, isEdit);
    return panel;
  }

  function contractHasAnyValue(isEdit) {
    var ids = isEdit
      ? ['txtEdCliente', 'txtEdCPF', 'txtEdMarca', 'txtEdModelo', 'txtEdChassi', 'txtEdValorVeic']
      : ['txtCliente', 'txtCPFCNPJ', 'txtMarca', 'txtModelo', 'txtChassiPlaca', 'txtValoVeiculo'];

    return ids.some(function (id) {
      var field = bySuffix(id);
      return field && isRelevantContractField(field) && String(field.value || '').trim().length > 0;
    });
  }

  function updateQualityPanel() {
    var isEdit = currentContractMode() === 'edicao';
    var isNew = currentContractMode() === 'novo' && !!getWizardHost();
    var panel = ensureQualityPanel(isEdit);
    if (!panel) return;

    if ((!isEdit && !isNew) || !contractHasAnyValue(isEdit)) {
      panel.classList.add('is-hidden');
      updateSectionProgress();
      return;
    }

    var issues = collectIssues(isEdit, false);
    var status = document.getElementById('contractQualityStatus');
    var count = document.getElementById('contractQualityCount');
    var text = document.getElementById('contractQualityText');
    var list = document.getElementById('contractQualityList');

    panel.classList.remove('is-hidden', 'is-good', 'is-attention', 'is-risk');
    if (issues.length === 0) {
      panel.classList.add('is-good');
      status.textContent = 'Completo';
      if (count) count.textContent = '0 pendências';
      text.textContent = 'Campos principais conferidos. Revise o checklist final antes de gravar.';
    } else if (issues.length <= 2) {
      panel.classList.add('is-attention');
      status.textContent = 'Atenção';
      if (count) count.textContent = issues.length + ' pendência(s)';
      text.textContent = 'Existem poucos pontos para conferir antes de gravar.';
    } else {
      panel.classList.add('is-risk');
      status.textContent = 'Risco de erro';
      if (count) count.textContent = issues.length + ' pendência(s)';
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

    updateSectionProgress();
  }

  function enhanceDateFilters() {
    [
      { start: 'txtDtInicialVN', end: 'txtDtFinalVN', button: 'Button1', title: 'Contratos novos' },
      { start: 'txtDtInicialVU', end: 'txtDtFinalVU', button: 'Button2', title: 'Contratos usados' },
      { start: 'txtDtInicialVD', end: 'txtDtFinalVD', button: 'Button3', title: 'Venda direta' }
    ].forEach(function (filter) {
      allBySuffix(filter.start).forEach(function (field) {
        var table = closestTag(field, 'table');
        if (!table) return;
        var endField = bySuffixIn(table, filter.end);
        var button = bySuffix(filter.button);

        if (table.getAttribute('data-contract-date-filter') !== 'true') {
          table.setAttribute('data-contract-date-filter', 'true');
          table.className = (table.className ? table.className + ' ' : '') + 'contract-date-filter';
          var filterCell = table.parentNode;
          var filterFrame = closestTag(filterCell, 'table');
          addClass(filterCell, 'contract-date-filter-cell');
          addClass(filterFrame, 'contract-date-filter-frame');
          if (filterCell && filterCell.style) {
            filterCell.style.background = 'transparent';
            filterCell.style.borderColor = 'transparent';
          }
          if (filterFrame && filterFrame.style) {
            filterFrame.style.background = 'transparent';
            filterFrame.style.borderColor = 'transparent';
          }

          if (!table.parentNode || !/(^|\s)contract-date-filter-shell(\s|$)/.test(table.parentNode.className || '')) {
            var shell = document.createElement('div');
            shell.className = 'contract-date-filter-shell';

            var header = document.createElement('div');
            header.className = 'contract-date-filter-head';
            header.innerHTML = '<div><span>Per&iacute;odo de consulta</span><strong>' + filter.title + '</strong></div><small>Escolha as datas e processe a listagem.</small>';

            table.parentNode.insertBefore(shell, table);
            shell.appendChild(header);
            shell.appendChild(table);
          }

          var rows = table.rows;
          if (rows && rows.length > 1 && rows[0].cells.length < 3) {
            rows[0].insertCell(-1).innerHTML = '&nbsp;';
          }

          if (button && rows && rows.length > 1) {
            var targetCell = rows[1].cells.length >= 3 ? rows[1].cells[2] : rows[1].insertCell(-1);
            addClass(targetCell, 'contract-date-filter-action-cell');
            if (targetCell.style) targetCell.style.background = 'transparent';
            if (button.parentNode !== targetCell) targetCell.appendChild(button);
          }

          if (rows && rows.length > 1) {
            var shortcutRow = table.insertRow(2);
            shortcutRow.className = 'contract-date-shortcut-row';
            var shortcutCell = shortcutRow.insertCell(0);
            addClass(shortcutCell, 'contract-date-filter-shortcuts-cell');
            if (shortcutCell.style) shortcutCell.style.background = 'transparent';
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

  function collectBiSummary(panel) {
    var lines = [];
    var title = panel.querySelector('.contract-bi-filter h2');
    var period = panel.querySelector('.contract-bi-period');
    if (title) lines.push(title.textContent.trim());
    if (period) lines.push(period.textContent.trim());

    Array.prototype.slice.call(panel.querySelectorAll('.contract-bi-cards article')).forEach(function (card) {
      var label = card.querySelector('span');
      var value = card.querySelector('strong');
      var caption = card.querySelector('small');
      var line = [];
      if (label) line.push(label.textContent.trim());
      if (value) line.push(value.textContent.trim());
      if (caption) line.push(caption.textContent.trim());
      if (line.length) lines.push(line.join(': '));
    });

    return lines.join('\n');
  }

  function exportBiCsv(panel) {
    var rows = [['Indicador', 'Valor', 'Descrição']];
    Array.prototype.slice.call(panel.querySelectorAll('.contract-bi-cards article')).forEach(function (card) {
      var label = card.querySelector('span');
      var value = card.querySelector('strong');
      var caption = card.querySelector('small');
      rows.push([
        label ? label.textContent.trim() : '',
        value ? value.textContent.trim() : '',
        caption ? caption.textContent.trim() : ''
      ]);
    });
    if (rows.length === 1) return 0;

    var escapeCsv = function (value) {
      return '"' + String(value || '').replace(/"/g, '""') + '"';
    };
    var brand = document.body.className.indexOf('contrato-jeep') >= 0 ? 'jeep' : (document.body.className.indexOf('contrato-byd') >= 0 ? 'byd' : 'fiat');
    var fileName = 'bi-contratos-' + brand + '-' + new Date().toISOString().slice(0, 10) + '.csv';
    var blob = new Blob(['\ufeff' + rows.map(function (row) { return row.map(escapeCsv).join(';'); }).join('\r\n')], { type: 'text/csv;charset=utf-8;' });
    var link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.setTimeout(function () {
      URL.revokeObjectURL(link.href);
    }, 1000);
    return rows.length - 1;
  }

  function copyText(text, done) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(done, function () {
        done(false);
      });
      return;
    }

    var area = document.createElement('textarea');
    area.value = text;
    area.style.position = 'fixed';
    area.style.left = '-9999px';
    document.body.appendChild(area);
    area.select();
    var ok = false;
    try {
      ok = document.execCommand('copy');
    } catch (ignore) {
      ok = false;
    }
    document.body.removeChild(area);
    done(ok);
  }

  function showBiActionStatus(status, message, success) {
    if (!status) return;
    status.textContent = message || '';
    if (success) addClass(status, 'is-success');
    else removeClass(status, 'is-success');
    window.clearTimeout(status._contractTimer);
    status._contractTimer = window.setTimeout(function () {
      status.textContent = '';
      removeClass(status, 'is-success');
    }, 2200);
  }

  function enhanceBiActions() {
    Array.prototype.slice.call(document.querySelectorAll('.contract-bi-panel')).forEach(function (panel) {
      if (panel.getAttribute('data-contract-bi-actions') === 'true') return;
      var filter = panel.querySelector('.contract-bi-filter');
      if (!filter) return;

      panel.setAttribute('data-contract-bi-actions', 'true');
      var actions = document.createElement('div');
      actions.className = 'contract-bi-actions';
      actions.innerHTML = '<button type="button" data-bi-copy="true">Copiar resumo</button><button type="button" data-bi-csv="true">CSV</button><small></small>';
      filter.appendChild(actions);

      var button = actions.querySelector('[data-bi-copy]');
      var csvButton = actions.querySelector('[data-bi-csv]');
      var status = actions.querySelector('small');
      status.setAttribute('role', 'status');
      button.setAttribute('title', 'Copiar resumo dos indicadores do BI');
      csvButton.setAttribute('title', 'Exportar indicadores do BI em CSV');
      button.addEventListener('click', function () {
        var text = collectBiSummary(panel);
        if (!text) return;
        showBiActionStatus(status, 'Copiando...', false);
        copyText(text, function (ok) {
          showBiActionStatus(status, ok === false ? 'Não foi possível copiar.' : 'Resumo copiado.', ok !== false);
        });
      });
      csvButton.addEventListener('click', function () {
        var total = exportBiCsv(panel);
        showBiActionStatus(status, total ? total + ' indicador(es) exportado(s).' : 'Nenhum indicador disponível.', !!total);
      });
    });
  }

  function enhanceAuditTools() {
    Array.prototype.slice.call(document.querySelectorAll('.contract-audit-panel')).forEach(function (panel) {
      if (panel.getAttribute('data-contract-audit-tools') === 'true') return;

      var items = Array.prototype.slice.call(panel.querySelectorAll('.contract-audit-list article, .contract-audit-history article'));
      if (!items.length) return;

      panel.setAttribute('data-contract-audit-tools', 'true');
      var actions = [];
      items.forEach(function (item) {
        var action = item.querySelector('strong');
        action = action ? String(action.textContent || '').trim() : '';
        item.setAttribute('data-audit-action', action);
        item.setAttribute('data-audit-search', normalizeText(item.textContent));
        if (action && actions.indexOf(action) < 0) actions.push(action);
      });
      actions.sort();

      var tools = document.createElement('div');
      tools.className = 'contract-audit-tools';
      tools.innerHTML = '<input type="text" placeholder="Filtrar por contrato, usu\u00e1rio ou texto" aria-label="Filtrar auditoria" /><select aria-label="Filtrar por ocorr\u00eancia"><option value="">Todas as ocorr\u00eancias</option></select><div class="contract-audit-presets"><button type="button" data-audit-preset="">Todos</button><button type="button" data-audit-preset="attention">Atenção</button><button type="button" data-audit-preset="success">Sucessos</button><button type="button" data-audit-preset="edit">Edições</button></div><button type="button" data-audit-copy="true">Copiar visíveis</button><button type="button" data-audit-csv="true">CSV visível</button><small></small>';

      var select = tools.querySelector('select');
      actions.forEach(function (action) {
        var option = document.createElement('option');
        option.value = action;
        option.textContent = action;
        select.appendChild(option);
      });

      var input = tools.querySelector('input');
      var status = tools.querySelector('small');
      var copyButton = tools.querySelector('[data-audit-copy]');
      var csvButton = tools.querySelector('[data-audit-csv]');
      var activePreset = '';
      var presetButtons = Array.prototype.slice.call(tools.querySelectorAll('[data-audit-preset]'));
      var matchPreset = function (action) {
        var upper = String(action || '').toUpperCase();
        if (!activePreset) return true;
        if (activePreset === 'attention') return upper.indexOf('ERRO') === 0 || upper.indexOf('VALIDACAO') === 0 || upper.indexOf('CHECKLIST') === 0 || upper.indexOf('DUPLICIDADE') >= 0;
        if (activePreset === 'success') return upper.indexOf('SUCESSO') >= 0 || upper.indexOf('GRAVACAO_SUCESSO') >= 0;
        if (activePreset === 'edit') return upper.indexOf('EDICAO') >= 0;
        return true;
      };
      var applyFilter = function () {
        var text = normalizeText(input.value);
        var actionValue = select.value;
        var visible = 0;

        items.forEach(function (item) {
          var itemAction = item.getAttribute('data-audit-action') || '';
          var matchAction = !actionValue || itemAction === actionValue;
          var matchQuick = matchPreset(itemAction);
          var matchText = !text || String(item.getAttribute('data-audit-search') || '').indexOf(text) >= 0;
          item.style.display = matchAction && matchQuick && matchText ? '' : 'none';
          if (matchAction && matchQuick && matchText) visible++;
        });

        status.textContent = visible + ' registro(s) vis\u00edvel(is)';
      };

      input.addEventListener('input', applyFilter);
      select.addEventListener('change', applyFilter);
      presetButtons.forEach(function (button) {
        button.addEventListener('click', function () {
          activePreset = button.getAttribute('data-audit-preset') || '';
          presetButtons.forEach(function (item) {
            removeClass(item, 'is-active');
          });
          addClass(button, 'is-active');
          applyFilter();
        });
      });
      if (presetButtons.length) addClass(presetButtons[0], 'is-active');
      copyButton.addEventListener('click', function () {
        var visibleItems = items.filter(function (item) {
          return item.style.display !== 'none';
        });
        var text = visibleItems.map(function (item) {
          return String(item.textContent || '').replace(/\s+/g, ' ').trim();
        }).filter(Boolean).join('\n');

        if (!text) {
          status.textContent = 'Nenhum registro visível para copiar.';
          return;
        }

        copyText(text, function (ok) {
          status.textContent = ok === false ? 'Não foi possível copiar.' : visibleItems.length + ' registro(s) copiado(s).';
          window.clearTimeout(status._contractTimer);
          status._contractTimer = window.setTimeout(function () {
            applyFilter();
          }, 1800);
        });
      });

      csvButton.addEventListener('click', function () {
        var visibleItems = items.filter(function (item) {
          return item.style.display !== 'none';
        });
        if (!visibleItems.length) {
          status.textContent = 'Nenhum registro visível para exportar.';
          return;
        }

        var escapeCsv = function (value) {
          return '"' + String(value || '').replace(/"/g, '""') + '"';
        };
        var lines = ['"Acao";"Registro"'];
        visibleItems.forEach(function (item) {
          lines.push(escapeCsv(item.getAttribute('data-audit-action') || '') + ';' + escapeCsv(String(item.textContent || '').replace(/\s+/g, ' ').trim()));
        });

        var brand = document.body.className.indexOf('contrato-jeep') >= 0 ? 'jeep' : (document.body.className.indexOf('contrato-byd') >= 0 ? 'byd' : 'fiat');
        var fileName = 'auditoria-contratos-' + brand + '-' + new Date().toISOString().slice(0, 10) + '.csv';
        var blob = new Blob(['\ufeff' + lines.join('\r\n')], { type: 'text/csv;charset=utf-8;' });
        var link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = fileName;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        window.setTimeout(function () {
          URL.revokeObjectURL(link.href);
        }, 1000);
        status.textContent = visibleItems.length + ' registro(s) exportado(s).';
      });

      var anchor = panel.querySelector('.contract-audit-cards') || panel.firstChild;
      panel.insertBefore(tools, anchor ? anchor.nextSibling : null);
      applyFilter();
    });
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

  function currentContractMode() {
    var host = getWizardHost();
    if (host && host.querySelector && host.querySelector('[id$="btnEditareGravar"]')) return 'edicao';
    return 'novo';
  }

  function hasFieldValue(id) {
    var field = bySuffix(id);
    if (!field || !isRelevantContractField(field)) return false;
    if (field.tagName === 'SELECT') {
      var value = String(field.value || '').trim();
      var text = field.options && field.selectedIndex >= 0 ? String(field.options[field.selectedIndex].text || '').trim() : '';
      return validSelectedText(value) && validSelectedText(text);
    }
    return String(field.value || '').trim().length > 0;
  }

  function hasPositiveMoney(id) {
    var field = bySuffix(id);
    return field && isRelevantContractField(field) && parseMoney(field.value) > 0;
  }

  function requiredFieldComplete(id) {
    if (id === 'txtValoVeiculo' || id === 'txtEdValorVeic' || id === 'txtVlParcelas' || id === 'txtEdValorParcela') {
      return hasPositiveMoney(id);
    }
    if (id === 'ddlVendedor' || id === 'txtEdVendedor') {
      return validSelectedText(valueOf(id));
    }
    return hasFieldValue(id);
  }

  function fieldsComplete(ids) {
    return ids.every(function (id) {
      return requiredFieldComplete(id);
    });
  }

  function paymentComplete(mode) {
    var rules = paymentRules[mode];
    if (!fieldsComplete(sectionRequirements[mode].pagamento)) return false;

    var cash = bySuffix(rules.cash);
    var finance = bySuffix(rules.finance);
    var hasMode = !!((cash && cash.checked) || (finance && finance.checked));
    if (!hasMode) return false;

    var financeValue = parseMoney(valueOf(rules.financeValue));
    if ((finance && finance.checked) || financeValue > 0) {
      if (!hasFieldValue(rules.parcels) || !hasPositiveMoney(rules.parcelValue)) return false;
    }

    return financeValue >= 0;
  }

  function checklistComplete(mode) {
    return checklistRequirements[mode].every(function (id) {
      var field = bySuffix(id);
      return !field || !isRelevantContractField(field) || field.checked;
    });
  }

  function stageComplete(stage, mode) {
    if (stage === 'cliente' || stage === 'veiculo') {
      return fieldsComplete(sectionRequirements[mode][stage]);
    }
    if (stage === 'pagamento') return paymentComplete(mode);
    if (stage === 'checklist') return checklistComplete(mode);
    return false;
  }

  function updateSectionProgress() {
    var nav = document.getElementById('contractSectionNav');
    if (!nav) return;

    var mode = currentContractMode();
    var completed = 0;
    var buttons = Array.prototype.slice.call(nav.querySelectorAll('[data-section-name]'));
    buttons.forEach(function (button) {
      var name = button.getAttribute('data-section-name');
      var complete = stageComplete(name, mode);
      removeClass(button, 'is-complete');
      removeClass(button, 'is-pending');
      addClass(button, complete ? 'is-complete' : 'is-pending');
      if (complete) completed++;

      var status = button.querySelector('small');
      if (status) status.textContent = complete ? 'Conferido' : 'Pendente';
    });

    var progress = nav.querySelector('.contract-section-progress span');
    if (progress && buttons.length) {
      progress.style.width = Math.round((completed / buttons.length) * 100) + '%';
    }

    var checklist = getWizardChecklist();
    if (checklist) {
      removeClass(checklist, 'is-complete');
      if (checklistComplete(mode)) addClass(checklist, 'is-complete');
    }
  }

  function getWizardSections() {
    var host = getWizardHost();
    if (!host || !host.querySelectorAll) return [];
    return Array.prototype.slice.call(host.querySelectorAll('table.contract-form-section'));
  }

  function getWizardChecklist() {
    var host = getWizardHost();
    return host && host.querySelector ? host.querySelector('.contract-checklist') : null;
  }

  function getWizardSubmitButton() {
    var host = getWizardHost();
    if (!host || !host.querySelector) return null;
    return host.querySelector('[id$="btnEditareGravar"], [id$="btnGravar"]');
  }

  function sectionStageName(section) {
    var match = /contract-section-([a-z]+)/.exec(section.className || '');
    return match ? match[1] : '';
  }

  function getStageNameByIndex(index) {
    var sections = getWizardSections();
    if (index < sections.length) {
      return sectionStageName(sections[index]);
    }
    return 'checklist';
  }

  function wizardSignature(sections, checklist) {
    var host = getWizardHost();
    return (host ? String(host.id || host.getAttribute('data-contract-wizard-host') || '') : '')
      + '|' + currentContractMode()
      + '|' + sections.map(sectionStageName).join('|')
      + '|' + (checklist ? 'checklist' : '');
  }

  function fieldLabelFor(id) {
    var labels = {
      txtCliente: 'Cliente',
      txtCPFCNPJ: 'CPF/CNPJ',
      txtMarca: 'Marca',
      txtModelo: 'Modelo',
      txtChassiPlaca: 'Chassi/placa',
      txtValoVeiculo: 'Valor do ve\u00edculo',
      ddlVendedor: 'Vendedor',
      txtEdCliente: 'Cliente',
      txtEdCPF: 'CPF/CNPJ',
      txtEdMarca: 'Marca',
      txtEdModelo: 'Modelo',
      txtEdChassi: 'Chassi/placa',
      txtEdValorVeic: 'Valor do ve\u00edculo',
      txtEdVendedor: 'Vendedor',
      txtNrParcelas: 'Quantidade de parcelas',
      txtVlParcelas: 'Valor da parcela',
      txtEdNumeroParcelas: 'Quantidade de parcelas',
      txtEdValorParcela: 'Valor da parcela'
    };
    return labels[id] || id;
  }

  function requiredMessageFor(id) {
    if (id === 'txtCliente' || id === 'txtEdCliente') return 'Informe o nome completo do cliente.';
    if (id === 'txtCPFCNPJ' || id === 'txtEdCPF') return 'Informe CPF/CNPJ do cliente. Exemplo: 000.000.000-00.';
    if (id === 'txtMarca' || id === 'txtEdMarca') return 'Informe a marca do veículo.';
    if (id === 'txtModelo' || id === 'txtEdModelo') return 'Informe o modelo do veículo.';
    if (id === 'txtChassiPlaca' || id === 'txtEdChassi') return 'Informe placa ou chassi com pelo menos 7 caracteres.';
    if (id === 'txtValoVeiculo' || id === 'txtEdValorVeic') return 'Informe o valor do veículo maior que zero. Exemplo: 150000,00.';
    if (id === 'ddlVendedor' || id === 'txtEdVendedor') return 'Selecione ou informe o vendedor responsável pelo contrato.';
    if (id === 'txtNrParcelas' || id === 'txtEdNumeroParcelas') return 'Informe a quantidade de parcelas entre 1 e 120.';
    if (id === 'txtVlParcelas' || id === 'txtEdValorParcela') return 'Informe o valor da parcela maior que zero. Exemplo: 2500,00.';
    return fieldLabelFor(id) + ' precisa ser preenchido corretamente.';
  }

  function validateRequiredIds(ids, showMessages) {
    var issues = [];
    ids.forEach(function (id) {
      var field = bySuffix(id);
      if (!field || !isRelevantContractField(field)) return;

      var ok = requiredFieldComplete(id);
      var message = ok ? '' : requiredMessageFor(id);
      if (!ok) issues.push(message);
      if (showMessages) showFieldMessage(field, message);
    });
    return issues;
  }

  function validatePaymentWizard(mode, showMessages) {
    var issues = validateRequiredIds(sectionRequirements[mode].pagamento, showMessages);
    var rules = paymentRules[mode];
    var cash = bySuffix(rules.cash);
    var finance = bySuffix(rules.finance);

    if (cash && finance && !cash.checked && !finance.checked) {
      issues.push('Selecione a modalidade de pagamento.');
      if (showMessages) showFieldMessage(finance, 'Selecione \u00e0 vista ou financiamento.');
    } else if (showMessages && finance) {
      showFieldMessage(finance, '');
    }

    var financeValue = parseMoney(valueOf(rules.financeValue));
    if ((finance && finance.checked) || financeValue > 0) {
      if (!validInstallments(valueOf(rules.parcels))) {
        issues.push('Quantidade de parcelas deve ser um número entre 1 e 120.');
        if (showMessages) showFieldMessage(bySuffix(rules.parcels), 'Use um número entre 1 e 120.');
      }
      if (!hasPositiveMoney(rules.parcelValue)) {
        issues.push('Valor da parcela deve ser maior que zero.');
        if (showMessages) showFieldMessage(bySuffix(rules.parcelValue), 'Use um valor maior que zero.');
      }
    }

    return issues;
  }

  function updatePaymentHint() {
    var mode = currentContractMode();
    var rules = paymentRules[mode];
    if (!rules) return;

    var cash = bySuffix(rules.cash);
    var finance = bySuffix(rules.finance);
    var anchor = finance || cash;
    if (!anchor) return;

    var cell = anchor.closest ? anchor.closest('td') : anchor.parentNode;
    if (!cell) return;

    var hint = cell.querySelector('.contract-payment-hint');
    if (!hint) {
      hint = document.createElement('div');
      hint.className = 'contract-payment-hint';
      cell.appendChild(hint);
    }

    removeClass(hint, 'is-financed');
    removeClass(hint, 'is-cash');
    if (finance && finance.checked) {
      addClass(hint, 'is-financed');
      hint.textContent = 'Financiamento: confira financeira, quantidade de parcelas e valor da parcela.';
    } else if (cash && cash.checked) {
      addClass(hint, 'is-cash');
      hint.textContent = 'À vista: confira entrada e formas de pagamento antes de gravar.';
    } else {
      hint.textContent = 'Selecione à vista ou financiamento para continuar.';
    }
  }

  function validateWizardStep(index, showMessages) {
    var mode = currentContractMode();
    var stage = getStageNameByIndex(index);
    var issues = [];

    if (stage === 'cliente' || stage === 'veiculo') {
      issues = validateRequiredIds(sectionRequirements[mode][stage], showMessages);
    } else if (stage === 'pagamento') {
      issues = validatePaymentWizard(mode, showMessages);
    } else if (stage === 'checklist') {
      issues = collectIssues(mode === 'edicao', showMessages);
      if (!checklistComplete(mode)) issues.push('Confirme o checklist final antes de gravar.');
    }

    return uniqueIssues(issues);
  }

  function showWizardMessage(message) {
    var actions = document.getElementById('contractStepActions');
    if (!actions) return;
    var target = actions.querySelector('.contract-step-message');
    if (!target) return;
    target.textContent = message || '';
    target.style.display = message ? 'block' : 'none';
  }

  function ensureWizardActions(host) {
    var actions = document.getElementById('contractStepActions');
    if (!actions) {
      actions = document.createElement('div');
      actions.id = 'contractStepActions';
      actions.className = 'contract-step-actions';
      actions.innerHTML = '<button type="button" data-step-action="prev">Voltar</button><button type="button" data-step-action="next">Pr\u00f3xima etapa</button><small class="contract-step-message"></small>';
    }

    if (actions.getAttribute('data-step-bound') !== 'true') {
      actions.setAttribute('data-step-bound', 'true');
      actions.querySelector('[data-step-action="prev"]').addEventListener('click', function () {
        setWizardStep(contractStepIndex - 1, false);
      });
      actions.querySelector('[data-step-action="next"]').addEventListener('click', function () {
        setWizardStep(contractStepIndex + 1, true);
      });
    }

    if (host && actions.parentNode !== host) host.appendChild(actions);
    return actions;
  }

  function setWizardStep(index, validateBeforeAdvance) {
    var sections = getWizardSections();
    var checklist = getWizardChecklist();
    var maxIndex = sections.length + (checklist ? 1 : 0) - 1;
    if (maxIndex < 0) return;

    index = Math.max(0, Math.min(index, maxIndex));
    if (validateBeforeAdvance && index > contractStepIndex) {
      var currentIssues = validateWizardStep(contractStepIndex, true);
      if (currentIssues.length) {
        showWizardMessage(currentIssues[0]);
        focusFirstInvalidField();
        updateQualityPanel();
        return;
      }
    }

    contractStepIndex = index;
    showWizardMessage('');
    applyWizardStep();
    scrollActiveWizardStep();
  }

  function scrollActiveWizardStep() {
    if (!window.matchMedia || !window.matchMedia('(max-width: 980px)').matches) return;

    var host = getWizardHost();
    if (!host) return;

    var target = host.querySelector('.contract-form-section.is-step-active');
    if (!target && (' ' + String(host.className || '') + ' ').indexOf(' contract-wizard-review ') >= 0) {
      target = getWizardChecklist() || document.getElementById('contractQualityPanel');
    }

    if (target && target.scrollIntoView) {
      window.setTimeout(function () {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }, 40);
    }
  }

  function applyWizardStep() {
    var host = getWizardHost();
    if (!host) return;

    var sections = getWizardSections();
    var checklist = getWizardChecklist();
    var submitButton = getWizardSubmitButton();
    var maxIndex = sections.length + (checklist ? 1 : 0) - 1;
    if (maxIndex < 0) return;
    if (contractStepIndex > maxIndex) contractStepIndex = maxIndex;

    var reviewActive = checklist && contractStepIndex === sections.length;
    addClass(host, 'contract-wizard-host');
    if (reviewActive) {
      addClass(host, 'contract-wizard-review');
    } else {
      removeClass(host, 'contract-wizard-review');
    }

    sections.forEach(function (section, index) {
      removeClass(section, 'is-step-active');
      removeClass(section, 'is-step-hidden');
      if (index === contractStepIndex && !reviewActive) {
        addClass(section, 'is-step-active');
      } else {
        addClass(section, 'is-step-hidden');
      }
    });

    [checklist, document.getElementById('contractQualityPanel'), document.getElementById('contractSubmitSummary'), submitButton].forEach(function (element) {
      if (!element) return;
      removeClass(element, 'is-step-hidden');
      if (!reviewActive) addClass(element, 'is-step-hidden');
    });

    var target = reviewActive ? (checklist || submitButton) : sections[contractStepIndex];
    var actions = ensureWizardActions(host);
    if (target && target.parentNode === host && actions.parentNode === host) {
      if (target.nextSibling !== actions) host.insertBefore(actions, target.nextSibling);
    }

    var prev = actions.querySelector('[data-step-action="prev"]');
    var next = actions.querySelector('[data-step-action="next"]');
    prev.disabled = contractStepIndex === 0;
    next.style.display = reviewActive ? 'none' : '';
    next.textContent = contractStepIndex === sections.length - 1 && checklist ? 'Ir para revis\u00e3o' : 'Pr\u00f3xima etapa';

    var nav = document.getElementById('contractSectionNav');
    if (nav) {
      Array.prototype.slice.call(nav.querySelectorAll('[data-section-index]')).forEach(function (button) {
        removeClass(button, 'is-active');
        if (parseInt(button.getAttribute('data-section-index'), 10) === contractStepIndex) addClass(button, 'is-active');
      });
    }

    updateSectionProgress();
  }

  function sectionLabel(section) {
    if (section === 'cliente') return 'Cliente';
    if (section === 'veiculo') return 'Veículo';
    if (section === 'pagamento') return 'Pagamento';
    if (section === 'checklist') return 'Checklist';
    return 'Etapa';
  }

  function enhanceSectionNavigator() {
    var sections = getWizardSections();
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

    var checklist = getWizardChecklist();
    var signature = wizardSignature(sections, checklist);

    if (nav.getAttribute('data-section-signature') !== signature) {
      nav.setAttribute('data-section-signature', signature);
      nav.innerHTML = '<div class="contract-section-nav-head"><span>Etapas do contrato</span><small>Acompanhe o preenchimento de cada bloco.</small><div class="contract-section-progress" aria-hidden="true"><span></span></div></div><div class="contract-section-nav-steps"></div>';
      var steps = nav.querySelector('.contract-section-nav-steps');
      sections.forEach(function (section, index) {
        var match = /contract-section-([a-z]+)/.exec(section.className || '');
        var name = match ? match[1] : '';
        var button = document.createElement('button');
        button.type = 'button';
        button.innerHTML = '<span class="contract-step-number">' + (index + 1) + '</span><span class="contract-step-copy"><strong>' + sectionLabel(name) + '</strong><small>Pendente</small></span>';
        button.setAttribute('data-section-name', name);
        button.setAttribute('data-section-index', index);
        button.addEventListener('click', function () {
          setWizardStep(parseInt(button.getAttribute('data-section-index'), 10), true);
        });
        steps.appendChild(button);
      });

      if (checklist) {
        var checklistButton = document.createElement('button');
        checklistButton.type = 'button';
        checklistButton.innerHTML = '<span class="contract-step-number">' + (sections.length + 1) + '</span><span class="contract-step-copy"><strong>' + sectionLabel('checklist') + '</strong><small>Pendente</small></span>';
        checklistButton.setAttribute('data-section-name', 'checklist');
        checklistButton.setAttribute('data-section-index', sections.length);
        checklistButton.addEventListener('click', function () {
          setWizardStep(sections.length, true);
        });
        steps.appendChild(checklistButton);
      }
    }

    nav.classList.remove('is-hidden');
    if (nav.parentNode !== sections[0].parentNode || nav.nextSibling !== sections[0]) {
      sections[0].parentNode.insertBefore(nav, sections[0]);
    }
    var currentSignature = wizardSignature(sections, checklist);
    if (contractStepSignature !== currentSignature) {
      contractStepSignature = currentSignature;
      contractStepIndex = 0;
    }
    applyWizardStep();
    updateSectionProgress();
  }

  function bindWizardKeyboard() {
    if (wizardKeyboardBound) return;
    document.addEventListener('keydown', function (event) {
      if (!event.ctrlKey || event.altKey || event.shiftKey) return;
      if (event.target && /textarea/i.test(event.target.tagName || '')) return;
      var key = event.key || '';
      if (key !== 'ArrowRight' && key !== 'ArrowLeft') return;
      if (!getWizardHost()) return;
      event.preventDefault();
      setWizardStep(contractStepIndex + (key === 'ArrowRight' ? 1 : -1), key === 'ArrowRight');
    });
    wizardKeyboardBound = true;
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
      removeClass(getChecklistForButton(button), 'is-warning');
      return true;
    }

    showChecklistMessage(button, isEditSubmit(button)
      ? 'Confirme o checklist da edição antes de gravar.'
      : 'Confirme o checklist final antes de gravar o contrato.');

    var checklist = getChecklistForButton(button);
    if (checklist) {
      addClass(checklist, 'is-warning');
      try {
        checklist.scrollIntoView({ block: 'center', behavior: 'smooth' });
      } catch (ignore) {
        checklist.scrollIntoView(true);
      }
    }

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
      warning.setAttribute('role', 'alert');
      checklist.appendChild(warning);
    }

    warning.textContent = message || '';
    warning.style.display = message ? 'block' : 'none';
  }

  function markSubmitting(button) {
    if (!button) return;
    button.setAttribute('data-contract-submitting', 'true');
    button.setAttribute('aria-busy', 'true');
    button.setAttribute('aria-disabled', 'true');
    if (!button.getAttribute('data-contract-label') && button.value) {
      button.setAttribute('data-contract-label', button.value);
      button.value = 'Gravando...';
    }
    if ((' ' + button.className + ' ').indexOf(' is-submitting ') < 0) {
      button.className = (button.className ? button.className + ' ' : '') + 'is-submitting';
    }
    window.clearTimeout(button._contractSubmittingTimer);
    button._contractSubmittingTimer = window.setTimeout(function () {
      resetSubmittingButtons();
    }, 20000);
  }

  function resetSubmittingButtons() {
    Array.prototype.slice.call(document.querySelectorAll('[data-contract-submitting="true"]')).forEach(function (button) {
      button.removeAttribute('data-contract-submitting');
      button.removeAttribute('aria-busy');
      button.removeAttribute('aria-disabled');
      window.clearTimeout(button._contractSubmittingTimer);
      if (button.getAttribute('data-contract-label')) {
        button.value = button.getAttribute('data-contract-label');
        button.removeAttribute('data-contract-label');
      }
      button.className = String(button.className || '').replace(/\bis-submitting\b/g, '').replace(/\s+/g, ' ').trim();
    });
    contractAllowUnload = false;
    hideSubmitSummary();
  }

  function markProcessingButton(button, label) {
    if (!button) return;
    button.setAttribute('data-contract-processing', 'true');
    button.setAttribute('aria-busy', 'true');
    if (!button.getAttribute('data-contract-label') && button.value) {
      button.setAttribute('data-contract-label', button.value);
    }
    if (label && button.value) button.value = label;
    addClass(button, 'is-submitting');
    window.clearTimeout(button._contractProcessingTimer);
    button._contractProcessingTimer = window.setTimeout(resetProcessingButtons, 20000);
  }

  function resetProcessingButtons() {
    Array.prototype.slice.call(document.querySelectorAll('[data-contract-processing="true"]')).forEach(function (button) {
      button.removeAttribute('data-contract-processing');
      button.removeAttribute('aria-busy');
      window.clearTimeout(button._contractProcessingTimer);
      if (button.getAttribute('data-contract-label')) {
        button.value = button.getAttribute('data-contract-label');
        button.removeAttribute('data-contract-label');
      }
      removeClass(button, 'is-submitting');
    });
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
    window.cancelarAguarde = function () {
      setLoadingVisible(false);
      resetProcessingButtons();
      return false;
    };
    setLoadingVisible(false);
  }

  function bindProcessingButtons() {
    [
      { id: 'btnAtualizarBI', label: 'Atualizando...' },
      { id: 'Button1', label: 'Processando...' },
      { id: 'Button2', label: 'Processando...' },
      { id: 'Button3', label: 'Processando...' }
    ].forEach(function (item) {
      allBySuffix(item.id).forEach(function (button) {
        if (button.getAttribute('data-contract-processing-bound') === 'true') return;
        button.setAttribute('data-contract-processing-bound', 'true');
        button.addEventListener('click', function (event) {
          if (button.getAttribute('data-contract-processing') === 'true') {
            event.preventDefault();
            return false;
          }
          markProcessingButton(button, item.label);
          return true;
        });
      });
    });
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
    if (currentContractMode() === 'edicao') {
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

  function readComparableField(field) {
    if (!field) return '';
    var type = String(field.type || '').toLowerCase();
    if (type === 'checkbox' || type === 'radio') return field.checked ? '1' : '0';
    return String(field.value || '').replace(/\s+/g, ' ').trim();
  }

  function getEditTrackedField(item) {
    var field = bySuffix(item.id);
    return field && isRelevantContractField(field) ? field : null;
  }

  function hasLoadedEditContract() {
    if (String(valueOf('txtContrato') || '').trim().length > 0) return true;
    return editTrackedFields.some(function (item) {
      var field = getEditTrackedField(item);
      return field && readComparableField(field).length > 0;
    });
  }

  function ensureEditChangePanel() {
    var host = getQualityHost(true);
    if (!host) return null;

    var panel = document.getElementById('contractEditChangePanel');
    if (!panel) {
      panel = document.createElement('div');
      panel.id = 'contractEditChangePanel';
      panel.className = 'contract-edit-change-panel is-hidden';
      panel.setAttribute('role', 'status');
      panel.innerHTML = '<div><span>Alterações da edição</span><strong>Nenhuma alteração detectada</strong><small>Após carregar o contrato, os campos modificados aparecem aqui antes de gravar.</small></div><ul></ul>';
    }

    if (panel.parentNode !== host) {
      var checklist = host.querySelector ? host.querySelector('.contract-checklist') : null;
      if (checklist) host.insertBefore(panel, checklist);
      else host.appendChild(panel);
    }

    return panel;
  }

  function markEditBaseline(force) {
    var contractId = String(valueOf('txtContrato') || '').trim();
    editTrackedFields.forEach(function (item) {
      var field = getEditTrackedField(item);
      if (!field) return;
      var previousId = field.getAttribute('data-contract-edit-id') || '';
      if (force || previousId !== contractId || !field.hasAttribute('data-contract-edit-initial')) {
        field.setAttribute('data-contract-edit-id', contractId);
        field.setAttribute('data-contract-edit-initial', readComparableField(field));
      }
    });
  }

  function collectEditChanges() {
    var changes = [];
    editTrackedFields.forEach(function (item) {
      var field = getEditTrackedField(item);
      if (!field) return;

      var initial = field.getAttribute('data-contract-edit-initial');
      if (initial === null) {
        field.setAttribute('data-contract-edit-initial', readComparableField(field));
        initial = field.getAttribute('data-contract-edit-initial') || '';
      }

      var current = readComparableField(field);
      var changed = initial !== current;
      if (changed) {
        addClass(field, 'contract-edited-field');
        changes.push(item.label);
      } else {
        removeClass(field, 'contract-edited-field');
      }
    });

    return changes;
  }

  function isSensitiveEditChange(label) {
    return /valor|entrada|avalia|quita|financiamento|parcela|pagamento|modalidade/i.test(String(label || ''));
  }

  function updateEditChangePanel() {
    if (currentContractMode() !== 'edicao') return;

    var panel = ensureEditChangePanel();
    if (!panel) return;

    if (!hasLoadedEditContract()) {
      panel.classList.add('is-hidden');
      return;
    }

    var changes = collectEditChanges();
    var title = panel.querySelector('strong');
    var text = panel.querySelector('small');
    var list = panel.querySelector('ul');

    panel.classList.remove('is-hidden', 'has-changes', 'has-sensitive-changes');
    if (changes.length > 0) {
      addClass(panel, 'has-changes');
      title.textContent = changes.length + ' campo(s) alterado(s)';
      if (changes.some(isSensitiveEditChange)) {
        addClass(panel, 'has-sensitive-changes');
        text.textContent = 'Atenção: há alteração em valores ou forma de pagamento. Confira antes de salvar.';
      } else {
        text.textContent = 'Confira as alterações abaixo e marque o checklist antes de salvar.';
      }
    } else {
      title.textContent = 'Nenhuma alteração detectada';
      text.textContent = 'Altere os campos necessários; o resumo será atualizado automaticamente.';
    }

    if (list) {
      list.innerHTML = '';
      changes.slice(0, 12).forEach(function (label) {
        var item = document.createElement('li');
        item.textContent = label;
        list.appendChild(item);
      });
      if (changes.length > 12) {
        var extra = document.createElement('li');
        extra.textContent = 'Mais ' + (changes.length - 12) + ' campo(s) alterado(s)';
        list.appendChild(extra);
      }
    }
  }

  function scheduleEditChangePanelUpdate() {
    window.clearTimeout(editChangeTimer);
    editChangeTimer = window.setTimeout(updateEditChangePanel, 120);
  }

  function enhanceEditChangeTracking() {
    if (currentContractMode() !== 'edicao') return;
    markEditBaseline(false);
    updateEditChangePanel();

    editTrackedFields.forEach(function (item) {
      var field = getEditTrackedField(item);
      if (!field || field.getAttribute('data-contract-edit-watch') === 'true') return;
      field.setAttribute('data-contract-edit-watch', 'true');
      field.addEventListener('input', scheduleEditChangePanelUpdate);
      field.addEventListener('change', updateEditChangePanel);
      field.addEventListener('click', updateEditChangePanel);
    });
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
      var draft = raw ? JSON.parse(raw) : null;
      if (draft && draft.savedAt && (new Date().getTime() - draft.savedAt > draftMaxAgeMs)) {
        window.localStorage.removeItem(draftKey());
        return null;
      }
      return draft;
    } catch (ignore) {
      return null;
    }
  }

  function draftAgeText(savedAt) {
    var minutes = Math.max(1, Math.round((new Date().getTime() - savedAt) / 60000));
    if (minutes < 60) return 'há ' + minutes + ' min';
    var hours = Math.round(minutes / 60);
    if (hours < 24) return 'há ' + hours + ' h';
    return 'há ' + Math.round(hours / 24) + ' dia(s)';
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
      '<div><strong>Rascunho encontrado</strong><small data-draft-age="true">Existe um preenchimento salvo neste navegador.</small></div>' +
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
    updateEditChangePanel();
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

    var panel = ensureDraftPanel(currentContractMode() === 'edicao');
    var age = panel && panel.querySelector ? panel.querySelector('[data-draft-age="true"]') : null;
    if (age) age.textContent = 'Preenchimento salvo ' + draftAgeText(draft.savedAt) + ' neste navegador.';
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
    updateEditChangePanel();
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

    if (isEditSubmit(button) && hasLoadedEditContract()) {
      var editChanges = collectEditChanges();
      if (!editChanges.length) {
        showSubmitSummary(button, ['Nenhuma alteração detectada. Altere pelo menos um campo antes de gravar a edição.']);
        updateEditChangePanel();
        event.preventDefault();
        return false;
      }
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
        field.setAttribute('placeholder', '0,00');
        addClass(field, 'contract-money-field');
        removeLegacyPostbacks(field);
        field.addEventListener('focus', function () {
          if (field.select && parseMoney(field.value) === 0) field.select();
        });
        field.addEventListener('blur', function () {
          normalizeMoneyField(field, false);
          showFieldMessage(field, '');
          calculateContracts();
        });
        field.addEventListener('input', function () {
          var sanitized = sanitizeMoneyTyping(field.value);
          if (field.value !== sanitized) field.value = sanitized;
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
          scheduleQualityPanelUpdate();
        });
      });
    });

    ['txtCliente', 'txtCPFCNPJ', 'txtMarca', 'txtModelo', 'txtChassiPlaca', 'ddlVendedor', 'txtEdCliente', 'txtEdCPF', 'txtEdMarca', 'txtEdModelo', 'txtEdChassi', 'txtEdVendedor'].forEach(function (id) {
      allBySuffix(id).forEach(function (field) {
        if (field.getAttribute('data-contract-watch') === 'true') return;
        field.setAttribute('data-contract-watch', 'true');
        field.addEventListener('input', scheduleQualityPanelUpdate);
        field.addEventListener('input', function () { showFieldMessage(field, ''); });
        field.addEventListener('change', function () {
          showFieldMessage(field, '');
          updateQualityPanel();
        });
      });
    });

    ['rBtnModPagVista', 'rBtnModPagFinanciamento', 'rbtnEdAVISTA', 'rbtnEdAprazo'].forEach(function (id) {
      allBySuffix(id).forEach(function (field) {
        if (field.getAttribute('data-contract-pay-watch') === 'true') return;
        field.setAttribute('data-contract-pay-watch', 'true');
        field.addEventListener('change', function () {
          updatePaymentHint();
          updateQualityPanel();
        });
        field.addEventListener('click', function () {
          updatePaymentHint();
          updateQualityPanel();
        });
      });
    });

    updatePaymentHint();
  }

  function enhanceFormatFields() {
    formatRules.forEach(function (rule) {
      rule.ids.forEach(function (id) {
        allBySuffix(id).forEach(function (field) {
          if (field.getAttribute('data-contract-format') === 'true') return;
          field.setAttribute('data-contract-format', 'true');
          if (rule.placeholder) field.setAttribute('placeholder', rule.placeholder);
          if (rule.inputmode) field.setAttribute('inputmode', rule.inputmode);
          if (rule.maxLength) field.setAttribute('maxlength', rule.maxLength);
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
            scheduleQualityPanelUpdate();
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
    var signature = table.tBodies[0].rows.length + ':' + normalizeText(table.tBodies[0].textContent).slice(0, 80);
    if (table.getAttribute('data-contract-id-ready') === signature) return;

    Array.prototype.slice.call(table.tBodies[0].rows).forEach(function (row) {
      if (!row.cells || !row.cells.length) return;
      var cell = row.cells[0];
      var url = contractUrlForCell(cell, table);
      if (!url) return;
      var id = getContractIdFromCell(cell);

      addClass(cell, 'contract-id-cell');
      cell.setAttribute('title', 'Abrir contrato para impressão');

      var link = cell.querySelector ? cell.querySelector('a[href]') : null;
      if (link) {
        addClass(link, 'contract-id-action');
        if (link.getAttribute('data-contract-action-label') !== 'true') {
          link.setAttribute('data-contract-action-label', 'true');
          link.setAttribute('title', 'Abrir contrato para impress\u00e3o');
          link.innerHTML = '<span>#' + escapeHtml(id) + '</span><small>Imprimir</small>';
        }
      } else {
        if (!cell.querySelector || !cell.querySelector('.contract-id-action')) {
          cell.innerHTML = '<button type="button" class="contract-id-action" data-contract-url="' + escapeHtml(url) + '"><span>#' + escapeHtml(id) + '</span><small>Imprimir</small></button>';
        }
      }
    });
    table.setAttribute('data-contract-id-ready', signature);
  }

  function openLookupCell(cell, table) {
    var action = cell && cell.querySelector ? cell.querySelector('[data-contract-url]') : null;
    var url = action ? action.getAttribute('data-contract-url') : contractUrlForCell(cell, table);
    if (url) window.location.href = url;
  }

  function countLookupRows(table) {
    if (!table || !table.tBodies || !table.tBodies.length) return 0;
    return Array.prototype.slice.call(table.tBodies[0].rows).filter(function (row) {
      if (!row.cells || !row.cells.length) return false;
      if ((row.className || '').match(/dataTables_empty/)) return false;
      if ((row.className || '').match(/contract-empty-row/)) return false;
      if ((row.cells[0].className || '').match(/dataTables_empty/)) return false;
      if (normalizeText(row.cells[0].textContent).indexOf('NENHUM CONTRATO') >= 0) return false;
      return true;
    }).length;
  }

  function exportLookupCsv(table, label) {
    if (!table || !table.tBodies || !table.tBodies.length) return 0;
    var headers = table.tHead && table.tHead.rows.length
      ? Array.prototype.slice.call(table.tHead.rows[0].cells).map(function (cell) { return String(cell.textContent || '').trim(); })
      : ['ID', 'Cliente', 'CPF/CNPJ', 'RG', 'Telefone 1', 'Telefone 2', 'Telefone 3', 'E-mail', 'Vendedor'];

    var escapeCsv = function (value) {
      return '"' + String(value || '').replace(/\s+/g, ' ').trim().replace(/"/g, '""') + '"';
    };
    var cellText = function (cell, index) {
      if (index === 0 && cell.querySelector) {
        var idText = cell.querySelector('.contract-id-action span');
        if (idText) return String(idText.textContent || '').replace(/^#/, '').trim();
      }
      return String(cell.textContent || '').replace(/\s+/g, ' ').trim();
    };
    var lines = [headers.map(escapeCsv).join(';')];
    Array.prototype.slice.call(table.tBodies[0].rows).forEach(function (row) {
      if (!row.cells || !row.cells.length || row.style.display === 'none' || (row.className || '').match(/contract-empty-row|dataTables_empty/)) return;
      lines.push(Array.prototype.slice.call(row.cells).map(function (cell, index) { return escapeCsv(cellText(cell, index)); }).join(';'));
    });

    if (lines.length === 1) return 0;
    var brand = document.body.className.indexOf('contrato-jeep') >= 0 ? 'jeep' : (document.body.className.indexOf('contrato-byd') >= 0 ? 'byd' : 'fiat');
    var name = 'consulta-' + normalizeText(label).toLowerCase().replace(/\s+/g, '-') + '-' + brand + '-' + new Date().toISOString().slice(0, 10) + '.csv';
    var blob = new Blob(['\ufeff' + lines.join('\r\n')], { type: 'text/csv;charset=utf-8;' });
    var link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = name;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.setTimeout(function () {
      URL.revokeObjectURL(link.href);
    }, 1000);
    return lines.length - 1;
  }

  function enhanceLookupSummary(table) {
    var wrapper = closestClass(table, 'dataTables_wrapper') || table.parentNode;
    if (!wrapper) return;

    var summary = wrapper.querySelector ? wrapper.querySelector('.contract-lookup-summary') : null;
    if (!summary) {
      summary = document.createElement('div');
      summary.className = 'contract-lookup-summary';
      wrapper.insertBefore(summary, wrapper.firstChild);
    }

    var label = closestIdContains(table, 'TabPanel4')
      ? 'Consulta Venda Direta'
      : (/tblConsultaProcesso2$/i.test(table.id || '') ? 'Consulta Usado' : 'Consulta Novo');
    var count = countLookupRows(table);
    var text = count > 0
      ? 'Use o filtro para localizar cliente, CPF ou vendedor. Clique em Imprimir para abrir o contrato.'
      : 'Nenhum contrato apareceu neste filtro. Revise as datas ou tente um período maior.';
    var signature = label + ':' + count + ':' + text;
    if (summary.getAttribute('data-contract-summary') === signature) return;
    summary.innerHTML = '<div><span>' + label + '</span><strong>' + count + ' contrato(s)</strong></div><small>' + text + '</small><button type="button" class="contract-lookup-export">CSV</button>';
    summary.setAttribute('data-contract-summary', signature);
    var button = summary.querySelector('.contract-lookup-export');
    button.addEventListener('click', function () {
      var total = exportLookupCsv(table, label);
      var info = summary.querySelector('small');
      if (info) info.textContent = total ? total + ' contrato(s) exportado(s).' : 'Nenhum contrato visível para exportar.';
    });
  }

  function triggerLookupSearch(input) {
    if (window.jQuery) {
      window.jQuery(input).trigger('keyup');
      return;
    }

    var event;
    if (typeof Event === 'function') {
      event = new Event('keyup', { bubbles: true });
    } else {
      event = document.createEvent('Event');
      event.initEvent('keyup', true, true);
    }
    input.dispatchEvent(event);
  }

  function enhanceLookupFilter(input) {
    if (input.getAttribute('data-contract-filter') !== 'true') {
      input.setAttribute('data-contract-filter', 'true');
      input.setAttribute('placeholder', 'Cliente, CPF/CNPJ, e-mail ou vendedor...');
      input.setAttribute('aria-label', 'Filtrar contratos por cliente, CPF, e-mail ou vendedor');
      input.setAttribute('title', 'Digite parte do cliente, CPF/CNPJ, e-mail ou vendedor.');
      input.setAttribute('autocomplete', 'off');
    }

    var filter = closestClass(input, 'dataTables_filter');
    if (!filter || filter.getAttribute('data-contract-filter-clear') === 'true') return;

    filter.setAttribute('data-contract-filter-clear', 'true');
    var button = document.createElement('button');
    button.type = 'button';
    button.className = 'contract-filter-clear';
    button.textContent = 'Limpar';
    button.addEventListener('click', function () {
      input.value = '';
      triggerLookupSearch(input);
      input.focus();
    });
    filter.appendChild(button);
  }

  function enhanceLookupPagination() {
    Array.prototype.slice.call(document.querySelectorAll('.dataTables_paginate a, .dataTables_paginate span, .fg-button')).forEach(function (button) {
      if (button.getAttribute('data-contract-pagination') === 'true') return;
      var text = normalizeText(button.textContent || button.getAttribute('title') || '');
      var label = '';
      if (text.indexOf('PRIMEIRO') >= 0 || text === 'FIRST') label = 'Primeira página';
      else if (text.indexOf('ULTIMO') >= 0 || text === 'LAST') label = 'Última página';
      else if (text.indexOf('ANTERIOR') >= 0 || text === 'PREVIOUS') label = 'Página anterior';
      else if (text.indexOf('PROXIMO') >= 0 || text === 'NEXT') label = 'Próxima página';
      else if (/^\d+$/.test(text)) label = 'Página ' + text;
      if (!label) return;
      button.setAttribute('data-contract-pagination', 'true');
      button.setAttribute('aria-label', label);
      button.setAttribute('title', label);
    });
  }

  function enhanceLookupTables() {
    Array.prototype.slice.call(document.querySelectorAll('#tblConsultaProcesso, #tblConsultaProcesso2, table.display, table.dataTable')).forEach(function (table) {
      if (!table || table.getAttribute('data-contract-lookup') === 'true') {
        prepareLookupIdCells(table);
        enhanceLookupSummary(table);
        return;
      }

      table.setAttribute('data-contract-lookup', 'true');
      table.setAttribute('aria-label', 'Listagem de contratos');
      addClass(table, 'contract-lookup-table');
      prepareLookupIdCells(table);
      enhanceLookupSummary(table);

      table.addEventListener('click', function (event) {
        var action = closestClass(event.target, 'contract-id-action');
        if (!action || !action.getAttribute('data-contract-url')) return;
        event.preventDefault();
        window.location.href = action.getAttribute('data-contract-url');
      });

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
      enhanceLookupFilter(input);
    });

    Array.prototype.slice.call(document.querySelectorAll('.dataTables_length select')).forEach(function (select) {
      if (select.getAttribute('data-contract-page-size') === 'true') return;
      select.setAttribute('data-contract-page-size', 'true');
      select.setAttribute('aria-label', 'Quantidade de contratos por página');
      select.setAttribute('title', 'Quantidade de contratos por página');
    });

    enhanceLookupPagination();
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
        removeClass(closestClass(field, 'contract-checklist'), 'is-warning');
        updateSectionProgress();
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

  function cleanIdentityValue(value, uppercase) {
    var cleaned = String(value || '').replace(/\s+/g, ' ').trim();
    return uppercase ? cleaned.toUpperCase() : cleaned;
  }

  function enhanceTextCleanupFields() {
    [
      'txtCliente', 'txtEndereco', 'txtBairro', 'txtCidade', 'txtMarca', 'txtModelo', 'txtCorExterna',
      'txtModMarca', 'txtAnoModelo', 'txtFinanceira', 'txtFormasPagamento', 'ddlVendedor',
      'txtEdCliente', 'txtEdEndereco', 'txtEdBairro', 'txtEdCidade', 'txtEdMarca', 'txtEdModelo',
      'txtEdCorExt', 'txtEdModMarcaUSADO', 'txtEdAnoMOdUSADO', 'txtEdFinanceira', 'txtEdFormasPagamento',
      'txtEdVendedor'
    ].forEach(function (id) {
      allBySuffix(id).forEach(function (field) {
        if (field.getAttribute('data-contract-clean-text') === 'true') return;
        field.setAttribute('data-contract-clean-text', 'true');
        field.addEventListener('blur', function () {
          if (field.tagName === 'SELECT') return;
          var cleaned = String(field.value || '').replace(/\s+/g, ' ').trim();
          if (field.value !== cleaned) field.value = cleaned;
          scheduleQualityPanelUpdate();
        });
      });
    });
  }

  function markRequiredLabels() {
    requiredNewFields.concat(requiredEditFields).forEach(function (item) {
      allBySuffix(item.id).forEach(function (field) {
        if (!field || field.getAttribute('data-contract-required-label') === 'true') return;
        field.setAttribute('data-contract-required-label', 'true');
        field.setAttribute('aria-required', 'true');
        var cell = field.closest ? field.closest('td') : null;
        var labelCell = cell && cell.previousElementSibling && cell.previousElementSibling.tagName === 'TD'
          ? cell.previousElementSibling
          : null;
        if (labelCell) {
          addClass(labelCell, 'contract-required-label');
          labelCell.setAttribute('title', 'Campo obrigatório');
        }
      });
    });
  }

  function enhanceIdentityFields() {
    [
      { id: 'txtCPFCNPJ', uppercase: false },
      { id: 'txtEdCPF', uppercase: false },
      { id: 'txtChassiPlaca', uppercase: true, placeholder: 'Placa ou chassi' },
      { id: 'txtPlacaVU', uppercase: true, placeholder: 'Placa do usado' },
      { id: 'txtEdChassi', uppercase: true, placeholder: 'Placa ou chassi' },
      { id: 'txtEdPlacaUSADO', uppercase: true, placeholder: 'Placa do usado' }
    ].forEach(function (config) {
      allBySuffix(config.id).forEach(function (field) {
        if (field.getAttribute('data-contract-identity') === 'true') return;
        field.setAttribute('data-contract-identity', 'true');
        field.setAttribute('autocomplete', 'off');
        if (config.placeholder) field.setAttribute('placeholder', config.placeholder);

        var normalize = function () {
          var cleaned = cleanIdentityValue(field.value, config.uppercase);
          if (field.value !== cleaned) field.value = cleaned;
        };

        field.addEventListener('blur', normalize);
        field.addEventListener('change', normalize);
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
    resetSubmittingButtons();
    resetProcessingButtons();
    enhanceLoadingIndicator();
    enhanceFields();
    enhanceFormatFields();
    enhanceIdentityFields();
    enhanceTextCleanupFields();
    markRequiredLabels();
    enhanceChecklist();
    enhanceDateFilters();
    enhanceBiPeriodShortcuts();
    enhanceBiActions();
    enhanceAuditTools();
    enhanceFormSections();
    enhanceSectionNavigator();
    bindWizardKeyboard();
    enhanceEditChangeTracking();
    enhanceUnsavedWarning();
    enhanceDraftRecovery();
    enhanceLookupTables();
    bindSubmitButtons();
    bindProcessingButtons();
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
