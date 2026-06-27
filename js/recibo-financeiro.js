(function () {
  var endpoint = 'recibo-modelos.ashx?AspxAutoDetectCookieSupport=1';
  var defaults = [
    {
      id: 'premiacao-vendas',
      name: 'Premia\u00e7\u00e3o de vendas',
      content: 'Recebi da {empresa}, a quantia de {valor} ({valor_extenso}), referente \u00e0 PREMIA\u00c7\u00c3O DE VENDAS do m\u00eas de {mes}.'
    },
    {
      id: 'supervisao-vendas',
      name: 'Supervis\u00e3o de vendas',
      content: 'Recebi da {empresa}, a quantia de {valor} ({valor_extenso}), referente \u00e0 SUPERVIS\u00c3O DE VENDAS do m\u00eas de {mes}.'
    },
    {
      id: 'ajuda-custo',
      name: 'Ajuda de custo',
      content: 'Recebi da {empresa}, a quantia de {valor} ({valor_extenso}), referente \u00e0 ajuda de custo do m\u00eas de {mes}.'
    }
  ];

  var state = {
    templates: [],
    textTouched: false,
    saving: false
  };

  function bySuffix(suffix) {
    return document.querySelector('[id$="' + suffix + '"]');
  }

  function normalize(text) {
    text = String(text || '').toLowerCase();
    if (text.normalize) {
      text = text.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }
    return text.replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  }

  function moneyToNumber(value) {
    var digits = String(value || '').replace(/\D/g, '');
    if (!digits) return 0;
    return Number(digits) / 100;
  }

  function formatMoney(value) {
    var number = typeof value === 'number' ? value : moneyToNumber(value);
    return number.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
  }

  function bindMoneyMask() {
    var input = bySuffix('txtValor');
    if (!input) return;

    input.addEventListener('input', function () {
      input.value = formatMoney(input.value);
      updateTextIfAutomatic();
    });

    input.addEventListener('focus', function () {
      input.select();
    });

    input.value = formatMoney(input.value);
  }

  function getMonthText() {
    var select = bySuffix('ddListMes');
    if (!select || select.selectedIndex < 0) return '';
    return select.options[select.selectedIndex].text;
  }

  function getReceiptType() {
    var vendas = bySuffix('rBtnVendas');
    return vendas && vendas.checked ? 'PREMIA\u00c7\u00c3O DE VENDAS' : 'SUPERVIS\u00c3O DE VENDAS';
  }

  function defaultTemplate() {
    return getReceiptType() === 'PREMIA\u00c7\u00c3O DE VENDAS' ? defaults[0].content : defaults[1].content;
  }

  function selectedTemplate() {
    var select = document.getElementById('receiptTemplateSelect');
    if (!select) return null;
    var id = select.value;
    for (var i = 0; i < state.templates.length; i++) {
      if (state.templates[i].id === id) return state.templates[i];
    }
    return null;
  }

  function replaceVariables(text) {
    var value = bySuffix('txtValor');
    var favored = bySuffix('txtFavorecido');
    var now = new Date();
    var data = now.toLocaleDateString('pt-BR', { day: '2-digit', month: 'long', year: 'numeric' });

    return String(text || '')
      .replace(/\{empresa\}/gi, 'BALI BRAS\u00cdLIA AUTOM\u00d3VEIS LTDA')
      .replace(/\{valor\}/gi, value ? value.value : '')
      .replace(/\{valor_extenso\}/gi, 'valor por extenso gerado na pr\u00e9via')
      .replace(/\{mes\}/gi, getMonthText())
      .replace(/\{tipo\}/gi, getReceiptType())
      .replace(/\{favorecido\}/gi, favored ? favored.value : '')
      .replace(/\{data\}/gi, data);
  }

  function rebuildText(forceTemplate) {
    var text = bySuffix('txtTextoRecibo');
    if (!text) return;

    var template = forceTemplate || (selectedTemplate() ? selectedTemplate().content : defaultTemplate());
    text.value = template;
    state.textTouched = false;
  }

  function updateTextIfAutomatic() {
    if (state.textTouched) return;
    rebuildText();
  }

  function renderTemplates() {
    var select = document.getElementById('receiptTemplateSelect');
    if (!select) return;

    select.innerHTML = '';
    state.templates.forEach(function (template) {
      var option = document.createElement('option');
      option.value = template.id;
      option.textContent = template.name;
      select.appendChild(option);
    });
  }

  async function loadTemplates() {
    try {
      var response = await fetch(endpoint + '&v=' + Date.now(), { cache: 'no-store', credentials: 'same-origin' });
      if (response.ok) {
        var payload = await response.json();
        if (payload && Array.isArray(payload.templates) && payload.templates.length) {
          state.templates = payload.templates;
          renderTemplates();
          return;
        }
      }
    } catch (error) {
    }

    state.templates = defaults.slice();
    renderTemplates();
  }

  async function saveTemplates() {
    if (state.saving) return false;
    state.saving = true;
    try {
      var response = await fetch(endpoint, {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ templates: state.templates })
      });
      return response.ok;
    } catch (error) {
      return false;
    } finally {
      state.saving = false;
    }
  }

  async function saveCurrentTemplate() {
    var name = document.getElementById('receiptTemplateName');
    var text = bySuffix('txtTextoRecibo');
    if (!name || !text) return;

    var templateName = String(name.value || '').trim();
    var content = String(text.value || '').trim();
    if (!templateName || !content) {
      window.alert('Informe o nome do modelo e o texto antes de salvar.');
      return;
    }

    var id = normalize(templateName) || 'modelo-' + Date.now();
    var existing = state.templates.filter(function (item) { return item.id === id; })[0];
    if (existing) {
      existing.name = templateName;
      existing.content = content;
    } else {
      state.templates.push({ id: id, name: templateName, content: content });
    }

    renderTemplates();
    document.getElementById('receiptTemplateSelect').value = id;
    if (await saveTemplates()) {
      window.alert('Modelo salvo com sucesso.');
    } else {
      window.alert('N\u00e3o foi poss\u00edvel salvar o modelo no servidor.');
    }
  }

  async function deleteCurrentTemplate() {
    var template = selectedTemplate();
    if (!template) return;
    if (!window.confirm('Excluir o modelo "' + template.name + '"?')) return;

    state.templates = state.templates.filter(function (item) { return item.id !== template.id; });
    if (!state.templates.length) state.templates = defaults.slice();
    renderTemplates();
    rebuildText();
    await saveTemplates();
  }

  function printReceipt() {
    var printArea = document.querySelector('.receipt-print-area');
    if (!printArea) return;
    window.print();
  }

  function setPrintAvailability() {
    var button = document.querySelector('[data-action="print"]');
    if (button) {
      button.disabled = !document.querySelector('.receipt-print-area');
    }
  }

  function bindActions() {
    var text = bySuffix('txtTextoRecibo');
    if (text) {
      text.addEventListener('input', function () {
        state.textTouched = true;
      });
    }

    ['txtFavorecido', 'ddListMes', 'rBtnVendas', 'rBtnSupervisao'].forEach(function (suffix) {
      var item = bySuffix(suffix);
      if (!item) return;
      item.addEventListener('change', updateTextIfAutomatic);
      item.addEventListener('input', updateTextIfAutomatic);
    });

    document.addEventListener('click', function (event) {
      var action = event.target.getAttribute('data-action');
      var templateAction = event.target.getAttribute('data-template');
      var choice = event.target.closest ? event.target.closest('.receipt-choice') : null;

      if (choice && event.target.tagName !== 'INPUT') {
        var radio = choice.querySelector('input[type="radio"]');
        if (radio && !radio.checked) {
          radio.checked = true;
          radio.dispatchEvent(new Event('change', { bubbles: true }));
        }
        return;
      }

      if (action === 'rebuild-text') {
        state.textTouched = false;
        rebuildText();
      } else if (action === 'reset-form') {
        var favored = bySuffix('txtFavorecido');
        var value = bySuffix('txtValor');
        if (favored) favored.value = '';
        if (value) value.value = formatMoney(0);
        state.textTouched = false;
        rebuildText();
      } else if (action === 'print') {
        printReceipt();
      } else if (templateAction === 'apply') {
        var template = selectedTemplate();
        if (template) rebuildText(template.content);
      } else if (templateAction === 'save') {
        saveCurrentTemplate();
      } else if (templateAction === 'delete') {
        deleteCurrentTemplate();
      }
    });

    var select = document.getElementById('receiptTemplateSelect');
    if (select) {
      select.addEventListener('change', function () {
        var template = selectedTemplate();
        var name = document.getElementById('receiptTemplateName');
        if (name && template) name.value = template.name;
      });
    }
  }

  window.reciboFinanceiroAfterGenerate = function () {
    setPrintAvailability();
    var preview = document.querySelector('.receipt-preview-panel');
    if (preview) preview.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  async function init() {
    bindMoneyMask();
    await loadTemplates();
    bindActions();
    setPrintAvailability();

    var text = bySuffix('txtTextoRecibo');
    if (text && text.value.indexOf('{') >= 0) {
      rebuildText(text.value);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
