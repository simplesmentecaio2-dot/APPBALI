(function () {
  'use strict';

  function ready(callback) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', callback);
    } else {
      callback();
    }
  }

  function ensureToastRoot() {
    var root = document.querySelector('.patio-toast-root');
    if (!root) {
      root = document.createElement('div');
      root.className = 'patio-toast-root';
      root.setAttribute('aria-live', 'polite');
      document.body.appendChild(root);
    }
    return root;
  }

  function toast(message, type) {
    var root = ensureToastRoot();
    var item = document.createElement('div');
    var normalized = (message || '').toString().trim();
    var lower = normalized.toLowerCase();
    var kind = type || (lower.indexOf('erro') >= 0 || lower.indexOf('inv') >= 0 || lower.indexOf('obrig') >= 0 ? 'error' : 'info');

    item.className = 'patio-toast patio-toast-' + kind;
    item.innerHTML = '<strong>' + (kind === 'error' ? 'Atenção' : 'Pátio') + '</strong><span></span><button type="button" aria-label="Fechar">&times;</button>';
    item.querySelector('span').textContent = normalized || 'Operação concluída.';
    item.querySelector('button').addEventListener('click', function () {
      item.classList.add('is-leaving');
      setTimeout(function () { item.remove(); }, 180);
    });
    root.appendChild(item);
    setTimeout(function () {
      if (item.parentNode) {
        item.classList.add('is-leaving');
        setTimeout(function () { item.remove(); }, 180);
      }
    }, kind === 'error' ? 6500 : 4200);
  }

  function enhanceAlerts() {
    var nativeAlert = window.alert;
    window.alert = function (message) {
      toast(message, null);
      if (window.console && window.console.info) {
        window.console.info('Patio:', message);
      }
    };
    window.patioToast = toast;
    window.patioNativeAlert = nativeAlert;
  }

  function normalizeSeriesInput(input) {
    input.setAttribute('autocomplete', 'off');
    input.setAttribute('autocapitalize', 'characters');
    input.setAttribute('spellcheck', 'false');
    input.setAttribute('inputmode', 'text');

    var hint = document.createElement('small');
    hint.className = 'patio-field-hint';
    hint.textContent = 'Digite os 7 últimos caracteres do chassi ou use o leitor.';

    if (input.parentNode && !input.parentNode.querySelector('.patio-field-hint')) {
      input.parentNode.appendChild(hint);
    }

    input.addEventListener('input', function () {
      var cursor = input.selectionStart;
      input.value = input.value.toUpperCase().replace(/\s+/g, '').slice(0, 17);
      var clean = input.value.replace(/[^A-Z0-9]/g, '');
      input.classList.toggle('is-valid', clean.length === 7);
      input.classList.toggle('is-warning', clean.length > 0 && clean.length !== 7);
      try { input.setSelectionRange(cursor, cursor); } catch (e) { }
    });
  }

  function enhanceFields() {
    var seriesFields = document.querySelectorAll('input[id$="txtSerie"], input[name$="txtSerie"]');
    for (var i = 0; i < seriesFields.length; i++) {
      normalizeSeriesInput(seriesFields[i]);
    }

    var readonlyFields = document.querySelectorAll('input[disabled], input[readonly], .bg-white[disabled]');
    for (var j = 0; j < readonlyFields.length; j++) {
      readonlyFields[j].classList.add('patio-readonly-field');
    }
  }

  function enhanceActions() {
    var form = document.querySelector('form');
    if (!form) return;

    form.addEventListener('submit', function () {
      var active = document.activeElement;
      if (active && /^(A|BUTTON|INPUT)$/i.test(active.tagName)) {
        active.classList.add('patio-action-loading');
      }
    });
  }

  function enhanceCurrentPage() {
    var path = (location.pathname || '').toLowerCase();
    document.body.setAttribute('data-patio-page', path.split('/').pop() || 'default.aspx');
  }

  function enhanceDashboardCards() {
    var cardLinks = document.querySelectorAll('.patio-modern-page a[href$="registrar.aspx"] .btn-secondary, .patio-modern-page a[href$="transferir.aspx"] .btn-secondary, .patio-modern-page a[href$="historico.aspx"] .btn-secondary');
    for (var i = 0; i < cardLinks.length; i++) {
      cardLinks[i].classList.add('patio-home-action');
    }
  }

  ready(function () {
    if (!document.body.classList.contains('patio-modern-page')) return;
    enhanceAlerts();
    enhanceFields();
    enhanceActions();
    enhanceCurrentPage();
    enhanceDashboardCards();
  });
})();
