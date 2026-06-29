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
    item.innerHTML = '<strong>' + (kind === 'error' ? 'Aten\u00e7\u00e3o' : 'P\u00e1tio') + '</strong><span></span><button type="button" aria-label="Fechar">&times;</button>';
    item.querySelector('span').textContent = normalized || 'Opera\u00e7\u00e3o conclu\u00edda.';
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
    hint.textContent = 'Digite os 7 \u00faltimos caracteres do chassi ou use o leitor.';

    if (input.parentNode && !input.parentNode.querySelector('.patio-field-hint')) {
      input.parentNode.appendChild(hint);
    }

    input.addEventListener('input', function () {
      var cursor = input.selectionStart || 0;
      var clean = input.value.toUpperCase().replace(/\s+/g, '').replace(/[^A-Z0-9]/g, '');

      if (clean.length > 7) {
        clean = clean.slice(-7);
        cursor = clean.length;
      }

      input.value = clean;
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

  function copyText(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(function () {
        toast('Copiado para a \u00e1rea de transfer\u00eancia.', 'info');
      }).catch(function () {
        toast('N\u00e3o foi poss\u00edvel copiar automaticamente.', 'error');
      });
      return;
    }

    var helper = document.createElement('textarea');
    helper.value = text;
    helper.setAttribute('readonly', 'readonly');
    helper.style.position = 'fixed';
    helper.style.opacity = '0';
    document.body.appendChild(helper);
    helper.select();
    try {
      document.execCommand('copy');
      toast('Copiado para a \u00e1rea de transfer\u00eancia.', 'info');
    } catch (e) {
      toast('N\u00e3o foi poss\u00edvel copiar automaticamente.', 'error');
    }
    helper.remove();
  }

  function enhanceCopyButtons() {
    var fields = document.querySelectorAll('input[id$="txtChassi"], input[id$="txtCodVec"], input[id$="txtModelo"], input[id$="txtCor"]');
    for (var i = 0; i < fields.length; i++) {
      var input = fields[i];
      var group = input.closest ? input.closest('.input-group') : input.parentNode;
      if (!group || group.querySelector('.patio-copy-field')) continue;

      var wrapper = document.createElement('div');
      wrapper.className = 'input-group-append patio-copy-field';

      var button = document.createElement('button');
      button.type = 'button';
      button.className = 'btn btn-light';
      button.title = 'Copiar';
      button.setAttribute('aria-label', 'Copiar campo');
      button.innerHTML = '<i class="far fa-copy"></i>';
      button.addEventListener('click', function () {
        var target = this.closest('.input-group').querySelector('input');
        var value = target ? target.value.trim() : '';
        if (!value) {
          toast('Nada para copiar neste campo.', 'error');
          return;
        }
        copyText(value);
      });

      wrapper.appendChild(button);
      group.appendChild(wrapper);
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
    enhanceCopyButtons();
    enhanceActions();
    enhanceCurrentPage();
    enhanceDashboardCards();
  });
})();
