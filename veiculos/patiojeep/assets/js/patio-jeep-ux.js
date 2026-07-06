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
    if (window.patioToast && window.patioNativeAlert) return;

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
    if (form._patioSubmitBound) return;
    form._patioSubmitBound = true;

    form.addEventListener('submit', function () {
      var active = document.activeElement;
      if (active && /^(A|BUTTON|INPUT)$/i.test(active.tagName)) {
        if (active.dataset && active.dataset.patioSubmitting === '1') {
          return false;
        }

        if (active.dataset) {
          active.dataset.patioSubmitting = '1';
          active.dataset.patioOriginalHtml = active.innerHTML || active.value || '';
        }

        active.classList.add('patio-action-loading');
        active.classList.add('aspNetDisabled');
        active.setAttribute('aria-disabled', 'true');
        active.style.pointerEvents = 'none';

        if (/^(A|BUTTON)$/i.test(active.tagName) && active.innerHTML) {
          active.innerHTML = '<i class="fa fa-spinner fa-spin mr-1"></i> Processando...';
        } else if (/^INPUT$/i.test(active.tagName) && active.type && /submit|button/i.test(active.type)) {
          active.value = 'Processando...';
        }
      }
    });
  }

  function restoreSubmitActions() {
    var locked = document.querySelectorAll('[data-patio-submitting="1"]');
    for (var i = 0; i < locked.length; i++) {
      var item = locked[i];
      var original = item.dataset ? item.dataset.patioOriginalHtml : '';

      item.classList.remove('patio-action-loading');
      item.classList.remove('aspNetDisabled');
      item.removeAttribute('aria-disabled');
      item.style.pointerEvents = '';

      if (original) {
        if (/^(A|BUTTON)$/i.test(item.tagName)) item.innerHTML = original;
        else if (/^INPUT$/i.test(item.tagName)) item.value = original;
      }

      if (item.dataset) {
        delete item.dataset.patioSubmitting;
        delete item.dataset.patioOriginalHtml;
      }
    }
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

  function ensureSidebarLinks() {
    var menus = document.querySelectorAll('.patio-modern-page .vertical-nav-menu');
    if (!menus.length) return;

    var currentPage = ((location.pathname || '').split('/').pop() || '').toLowerCase();
    var activeHref = './';
    if (/^(novos|registrar|transferir|historico|relatorios)\.aspx$/.test(currentPage)) {
      activeHref = './novos.aspx';
    } else if (currentPage === 'seminovos.aspx') {
      activeHref = './seminovos.aspx';
    } else if (currentPage === 'lojas.aspx') {
      activeHref = './lojas.aspx';
    } else if (currentPage === 'barcode-logs.aspx') {
      activeHref = './barcode-logs.aspx';
    }

    var links = [
      { href: './', icon: 'fas fa-home', label: 'In\u00edcio' },
      { href: './novos.aspx', icon: 'fas fa-car', label: 'Novos' },
      { href: './seminovos.aspx', icon: 'fas fa-car-side', label: 'Seminovos' },
      { href: './lojas.aspx', icon: 'fas fa-store', label: 'Lojas' },
      { href: './barcode-logs.aspx', icon: 'fas fa-clipboard-list', label: 'Logs do leitor' }
    ];

    for (var m = 0; m < menus.length; m++) {
      var menu = menus[m];
      menu.innerHTML = '';

      for (var i = 0; i < links.length; i++) {
        var item = links[i];
        if (i === 1) {
          var heading = document.createElement('li');
          heading.className = 'app-sidebar__heading';
          heading.textContent = 'Fun\u00e7\u00f5es';
          menu.appendChild(heading);
        }

        var li = document.createElement('li');
        var a = document.createElement('a');
        var icon = document.createElement('i');

        a.href = item.href;
        if (item.href === activeHref) {
          a.className = 'mm-active';
        }
        icon.className = 'metismenu-icon ' + item.icon;
        a.appendChild(icon);
        a.appendChild(document.createTextNode(item.label));
        li.appendChild(a);
        menu.appendChild(li);
      }
    }
  }

  function isEmbedMode() {
    return /(?:\?|&)embed=1(?:&|$)/.test(location.search || '');
  }

  function enhanceEmbedMode() {
    if (!isEmbedMode()) return;

    document.body.classList.add('patio-embed-mode');

    if (!document.getElementById('patioEmbedModeStyles')) {
      var style = document.createElement('style');
      style.id = 'patioEmbedModeStyles';
      style.textContent = [
        'html,body{background:transparent!important;}',
        'body.patio-embed-mode{overflow-x:hidden!important;padding:0!important;}',
        'body.patio-embed-mode .app-header,body.patio-embed-mode .app-sidebar,body.patio-embed-mode footer.fixed-bottom{display:none!important;}',
        'body.patio-embed-mode .app-container,body.patio-embed-mode .app-main,body.patio-embed-mode .app-main__outer,body.patio-embed-mode .app-main__inner{margin:0!important;padding:0!important;width:100%!important;max-width:none!important;min-height:0!important;background:transparent!important;}',
        'body.patio-embed-mode .app-main{display:block!important;}',
        'body.patio-embed-mode .app-page-title{display:none!important;}',
        'body.patio-embed-mode .card,body.patio-embed-mode .patio-bi-panel,body.patio-embed-mode .mb-3.card{box-shadow:none!important;}'
      ].join('');
      document.head.appendChild(style);
    }

    notifyEmbedHeight();
    setTimeout(notifyEmbedHeight, 300);
    setTimeout(notifyEmbedHeight, 900);

    if (window.MutationObserver && !document.body._patioEmbedObserver) {
      var observer = new MutationObserver(function () {
        clearTimeout(document.body._patioEmbedTimer);
        document.body._patioEmbedTimer = setTimeout(notifyEmbedHeight, 120);
      });
      observer.observe(document.body, { childList: true, subtree: true, attributes: true });
      document.body._patioEmbedObserver = observer;
    }
  }

  function notifyEmbedHeight() {
    if (!isEmbedMode() || !window.parent || window.parent === window) return;

    var height = Math.max(
      document.body ? document.body.scrollHeight : 0,
      document.documentElement ? document.documentElement.scrollHeight : 0,
      760
    );

    try {
      window.parent.postMessage({
        type: 'patio-embed-height',
        path: location.pathname,
        height: height
      }, location.origin);
    } catch (e) { }
  }

  function getField(suffix) {
    return document.querySelector('input[id$="' + suffix + '"], textarea[id$="' + suffix + '"]');
  }

  function getFieldValue(suffix) {
    var field = getField(suffix);
    return field ? (field.value || '').trim() : '';
  }

  function makePill(label, value) {
    var pill = document.createElement('span');
    pill.className = 'patio-summary-pill';

    var strong = document.createElement('b');
    strong.textContent = label;

    var text = document.createElement('span');
    text.textContent = value || '-';

    pill.appendChild(strong);
    pill.appendChild(text);
    return pill;
  }

  function enhanceVehicleSummary() {
    var firstField = getField('txtSerie') || getField('txtChassi') || getField('txtCodVec');
    if (!firstField || !firstField.closest) return;

    var card = firstField.closest('.card');
    if (!card) return;

    var serie = getFieldValue('txtSerie');
    var codigo = getFieldValue('txtCodVec');
    var chassi = getFieldValue('txtChassi');
    var modelo = getFieldValue('txtModelo');
    var cor = getFieldValue('txtCor');
    var hasData = serie || codigo || chassi || modelo || cor;
    var existing = card.querySelector('.patio-vehicle-summary');

    if (!hasData) {
      if (existing) existing.remove();
      return;
    }

    if (!existing) {
      existing = document.createElement('div');
      existing.className = 'patio-vehicle-summary';

      var header = card.querySelector('.card-header');
      if (header && header.parentNode) {
        header.parentNode.insertBefore(existing, header.nextSibling);
      } else {
        card.insertBefore(existing, card.firstChild);
      }
    }

    existing.innerHTML = '';

    var info = document.createElement('div');
    var title = document.createElement('strong');
    var meta = document.createElement('div');

    title.className = 'patio-vehicle-summary-title';
    title.textContent = modelo || 'Ve\u00edculo localizado';
    meta.className = 'patio-vehicle-summary-meta';

    meta.appendChild(makePill('S\u00e9rie', serie));
    meta.appendChild(makePill('C\u00f3digo', codigo));
    meta.appendChild(makePill('Chassi', chassi));
    meta.appendChild(makePill('Cor', cor));

    info.appendChild(title);
    info.appendChild(meta);

    var action = document.createElement('button');
    action.type = 'button';
    action.className = 'patio-summary-action';
    action.title = 'Copiar resumo do ve\u00edculo';
    action.setAttribute('aria-label', 'Copiar resumo do ve\u00edculo');
    action.innerHTML = '<i class="far fa-copy"></i>';
    action.addEventListener('click', function () {
      copyText([
        'S\u00e9rie: ' + (serie || '-'),
        'C\u00f3digo: ' + (codigo || '-'),
        'Chassi: ' + (chassi || '-'),
        'Modelo: ' + (modelo || '-'),
        'Cor: ' + (cor || '-')
      ].join(' | '));
    });

    existing.appendChild(info);
    existing.appendChild(action);
  }

  function runEnhancements() {
    enhanceEmbedMode();
    enhanceFields();
    enhanceCopyButtons();
    enhanceActions();
    enhanceCurrentPage();
    enhanceDashboardCards();
    ensureSidebarLinks();
    enhanceVehicleSummary();
  }

  function bindAjaxRefresh() {
    if (!window.Sys || !Sys.WebForms || !Sys.WebForms.PageRequestManager) return;

    var manager = Sys.WebForms.PageRequestManager.getInstance();
    if (!manager || manager._patioUxBound) return;

    manager.add_endRequest(function () {
      restoreSubmitActions();
      runEnhancements();
    });
    manager._patioUxBound = true;
  }

  ready(function () {
    if (!document.body.classList.contains('patio-modern-page')) return;
    enhanceAlerts();
    runEnhancements();
    bindAjaxRefresh();
  });
})();
