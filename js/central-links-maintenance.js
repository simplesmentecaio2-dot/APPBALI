(function () {
  var password = '@bali2025';
  var iconKeys = [
    'default',
    'contract',
    'guide',
    'receipt',
    'delivery',
    'test-drive',
    'phone',
    'accounts',
    'store',
    'prospecting',
    'performance',
    'communication',
    'workflow',
    'ranking',
    'bi',
    'direct-sale',
    'domicile'
  ];

  var state = {
    shortcuts: [],
    defaults: [],
    editingId: '',
    unlocked: false,
    selectedIcon: 'default'
  };

  var elements = {};

  function normalize(value) {
    return (value || '')
      .toString()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .trim();
  }

  function safeTrim(value) {
    return (value || '').toString().trim();
  }

  function createId() {
    if (window.crypto && typeof window.crypto.randomUUID === 'function') {
      return 'atalho-' + window.crypto.randomUUID();
    }

    return 'atalho-' + Date.now() + '-' + Math.random().toString(16).slice(2);
  }

  function cloneShortcut(shortcut) {
    return {
      id: shortcut.id,
      title: shortcut.title,
      caption: shortcut.caption,
      url: shortcut.url,
      icon: shortcut.icon || ''
    };
  }

  function sanitizeIcon(icon) {
    var value = safeTrim(icon);
    return iconKeys.indexOf(value) >= 0 ? value : '';
  }

  function inferIcon(shortcut) {
    if (sanitizeIcon(shortcut.icon)) {
      return shortcut.icon;
    }

    if (typeof window.centralLinksInferIcon === 'function') {
      return window.centralLinksInferIcon(shortcut.title + ' ' + shortcut.caption + ' ' + shortcut.url);
    }

    return 'default';
  }

  function extractDefaults() {
    var cards = document.querySelectorAll('.central-link-grid .central-link-card');
    var extracted = [];

    for (var i = 0; i < cards.length; i++) {
      var card = cards[i];
      var title = safeTrim(card.querySelector('.central-link-title') ? card.querySelector('.central-link-title').textContent : card.textContent);
      var caption = safeTrim(card.querySelector('.central-link-caption') ? card.querySelector('.central-link-caption').textContent : 'Atalho');

      extracted.push({
        id: 'padrao-' + i + '-' + normalize(title).replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, ''),
        title: title || 'Novo atalho',
        caption: caption || 'Atalho',
        url: safeTrim(card.getAttribute('href')),
        icon: safeTrim(card.getAttribute('data-icon'))
      });
    }

    return extracted;
  }

  function sanitizeShortcut(raw, index) {
    var item = raw || {};
    var title = safeTrim(item.title);
    var url = safeTrim(item.url);

    if (!title || !url) {
      return null;
    }

    return {
      id: safeTrim(item.id) || 'atalho-importado-' + index,
      title: title,
      caption: safeTrim(item.caption || item.badge) || 'Atalho',
      url: url,
      icon: sanitizeIcon(item.icon)
    };
  }

  function getApiUrl() {
    return document.body.getAttribute('data-links-api') || 'central-links.ashx';
  }

  function addQueryParam(url, key, value) {
    return url + (url.indexOf('?') >= 0 ? '&' : '?') + encodeURIComponent(key) + '=' + encodeURIComponent(value);
  }

  function getBrandName() {
    return document.body.getAttribute('data-brand-name') || 'Central';
  }

  async function loadShortcuts() {
    try {
      var response = await fetch(addQueryParam(getApiUrl(), 'v', Date.now()), {
        cache: 'no-store',
        credentials: 'same-origin'
      });

      if (!response.ok) {
        return state.defaults.map(cloneShortcut);
      }

      var payload = await response.json();
      var source = Array.isArray(payload) ? payload : payload.shortcuts;

      if (!Array.isArray(source) || !source.length) {
        return state.defaults.map(cloneShortcut);
      }

      var sanitized = [];
      for (var i = 0; i < source.length; i++) {
        var shortcut = sanitizeShortcut(source[i], i);
        if (shortcut) {
          sanitized.push(shortcut);
        }
      }

      return sanitized.length ? sanitized : state.defaults.map(cloneShortcut);
    } catch (error) {
      return state.defaults.map(cloneShortcut);
    }
  }

  async function saveShortcuts() {
    try {
      var response = await fetch(getApiUrl(), {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          password: password,
          shortcuts: state.shortcuts
        })
      });

      var payload = await response.json().catch(function () { return {}; });

      if (!response.ok || payload.ok === false) {
        throw new Error(payload.message || 'Falha ao salvar.');
      }

      setFeedback('Atalhos salvos com sucesso.', false);
      return true;
    } catch (error) {
      setFeedback('Nao foi possivel salvar os atalhos no servidor.', true);
      return false;
    }
  }

  function createMaintenancePanel() {
    var main = document.querySelector('.central-main');
    var cardPanel = document.querySelector('.central-card-panel');
    if (!main || !cardPanel || document.getElementById('centralMaintenance')) {
      return;
    }

    var button = document.createElement('button');
    button.type = 'button';
    button.className = 'central-maintenance-button';
    button.setAttribute('data-open-maintenance', 'true');
    button.innerHTML = 'Manuten&ccedil;&atilde;o';

    var sectionTitle = cardPanel.querySelector('.central-section-title');
    if (sectionTitle) {
      sectionTitle.appendChild(button);
    }

    var panel = document.createElement('section');
    panel.className = 'central-card-panel central-maintenance-panel';
    panel.id = 'centralMaintenance';
    panel.hidden = true;
    panel.innerHTML =
      '<div class="central-section-title">' +
        '<div><h2>Manuten&ccedil;&atilde;o de atalhos</h2><p>Inclua, edite, exclua ou reordene os atalhos da central ' + getBrandName() + '.</p></div>' +
        '<button type="button" class="central-maintenance-close" data-close-maintenance>Fechar</button>' +
      '</div>' +
      '<div class="central-maintenance-lock" data-maintenance-lock>' +
        '<label for="centralMaintenancePassword">Senha de manuten&ccedil;&atilde;o</label>' +
        '<div class="central-maintenance-password-row">' +
          '<input id="centralMaintenancePassword" type="password" autocomplete="current-password" placeholder="Digite a senha" />' +
          '<button type="button" data-unlock-maintenance>Entrar</button>' +
        '</div>' +
        '<p class="central-maintenance-error" data-maintenance-error hidden>Senha incorreta.</p>' +
      '</div>' +
      '<div class="central-maintenance-workspace" data-maintenance-workspace hidden>' +
        '<form class="central-maintenance-form" data-maintenance-form autocomplete="off">' +
          '<input type="hidden" data-field-id />' +
          '<div class="central-maintenance-fields">' +
            '<label>T&iacute;tulo<input type="text" data-field-title required /></label>' +
            '<label>Legenda<input type="text" data-field-caption required /></label>' +
            '<label class="central-maintenance-url">Link<input type="url" data-field-url required /></label>' +
          '</div>' +
          '<div class="central-icon-picker" data-icon-picker></div>' +
          '<div class="central-maintenance-actions">' +
            '<button type="submit">Salvar atalho</button>' +
            '<button type="button" data-new-shortcut>Novo</button>' +
            '<button type="button" data-restore-defaults>Restaurar padr&atilde;o</button>' +
          '</div>' +
        '</form>' +
        '<div class="central-maintenance-feedback" data-maintenance-feedback hidden></div>' +
        '<div class="central-maintenance-list" data-maintenance-list></div>' +
      '</div>';

    main.insertBefore(panel, cardPanel.nextSibling);
  }

  function cacheElements() {
    elements.panel = document.getElementById('centralMaintenance');
    elements.lock = document.querySelector('[data-maintenance-lock]');
    elements.workspace = document.querySelector('[data-maintenance-workspace]');
    elements.password = document.getElementById('centralMaintenancePassword');
    elements.error = document.querySelector('[data-maintenance-error]');
    elements.form = document.querySelector('[data-maintenance-form]');
    elements.fieldId = document.querySelector('[data-field-id]');
    elements.fieldTitle = document.querySelector('[data-field-title]');
    elements.fieldCaption = document.querySelector('[data-field-caption]');
    elements.fieldUrl = document.querySelector('[data-field-url]');
    elements.iconPicker = document.querySelector('[data-icon-picker]');
    elements.list = document.querySelector('[data-maintenance-list]');
    elements.feedback = document.querySelector('[data-maintenance-feedback]');
  }

  function setFeedback(message, isError) {
    if (!elements.feedback) {
      return;
    }

    elements.feedback.textContent = message;
    elements.feedback.hidden = !message;
    elements.feedback.classList.toggle('is-error', !!isError);
  }

  function openPanel() {
    if (!elements.panel) {
      return;
    }

    elements.panel.hidden = false;
    elements.panel.scrollIntoView({ behavior: 'smooth', block: 'start' });

    if (!state.unlocked && elements.password) {
      window.setTimeout(function () { elements.password.focus(); }, 120);
    }
  }

  function closePanel() {
    if (elements.panel) {
      elements.panel.hidden = true;
    }
  }

  function unlockMaintenance() {
    if (!elements.password || elements.password.value !== password) {
      if (elements.error) {
        elements.error.hidden = false;
      }
      if (elements.password) {
        elements.password.value = '';
        elements.password.focus();
      }
      return;
    }

    state.unlocked = true;
    if (elements.error) {
      elements.error.hidden = true;
    }
    if (elements.lock) {
      elements.lock.hidden = true;
    }
    if (elements.workspace) {
      elements.workspace.hidden = false;
    }
    renderIconPicker();
    resetForm();
    renderMaintenanceList();
  }

  function renderShortcuts() {
    var grid = document.querySelector('.central-link-grid');
    if (!grid) {
      return;
    }

    grid.innerHTML = '';

    for (var i = 0; i < state.shortcuts.length; i++) {
      var shortcut = state.shortcuts[i];
      var card = document.createElement('a');
      card.className = 'central-link-card';
      card.href = shortcut.url;
      card.setAttribute('data-shortcut-id', shortcut.id);
      card.setAttribute('data-icon', inferIcon(shortcut));
      card.innerHTML =
        '<span class="central-link-icon"></span>' +
        '<span><span class="central-link-title"></span><span class="central-link-caption"></span></span>';
      card.querySelector('.central-link-title').textContent = shortcut.title;
      card.querySelector('.central-link-caption').textContent = shortcut.caption;
      grid.appendChild(card);
    }

    if (typeof window.centralLinksApplyIcons === 'function') {
      window.centralLinksApplyIcons();
    }
  }

  function renderIconPicker() {
    if (!elements.iconPicker) {
      return;
    }

    elements.iconPicker.innerHTML = '<p>&Iacute;cone do atalho</p>';

    for (var i = 0; i < iconKeys.length; i++) {
      var icon = iconKeys[i];
      var button = document.createElement('button');
      button.type = 'button';
      button.className = 'central-icon-option';
      button.setAttribute('data-icon-key', icon);
      button.setAttribute('aria-label', 'Selecionar ícone ' + icon);
      button.innerHTML = '<img src="../img/central-icons/' + icon + '.svg" alt="" />';
      if (icon === state.selectedIcon) {
        button.classList.add('is-selected');
      }
      elements.iconPicker.appendChild(button);
    }
  }

  function renderMaintenanceList() {
    if (!elements.list) {
      return;
    }

    elements.list.innerHTML = '';

    for (var i = 0; i < state.shortcuts.length; i++) {
      var shortcut = state.shortcuts[i];
      var item = document.createElement('div');
      item.className = 'central-maintenance-item';
      item.setAttribute('data-shortcut-id', shortcut.id);
      item.innerHTML =
        '<div class="central-maintenance-item-main">' +
          '<span class="central-maintenance-item-icon"><img src="../img/central-icons/' + inferIcon(shortcut) + '.svg" alt="" /></span>' +
          '<span><strong></strong><small></small></span>' +
        '</div>' +
        '<div class="central-maintenance-item-actions">' +
          '<button type="button" data-move-up>Subir</button>' +
          '<button type="button" data-move-down>Descer</button>' +
          '<button type="button" data-edit-shortcut>Editar</button>' +
          '<button type="button" data-delete-shortcut>Excluir</button>' +
        '</div>';
      item.querySelector('strong').textContent = shortcut.title;
      item.querySelector('small').textContent = shortcut.caption + ' - ' + shortcut.url;
      elements.list.appendChild(item);
    }
  }

  function resetForm() {
    state.editingId = '';
    state.selectedIcon = 'default';
    if (elements.fieldId) elements.fieldId.value = '';
    if (elements.fieldTitle) elements.fieldTitle.value = '';
    if (elements.fieldCaption) elements.fieldCaption.value = 'Atalho';
    if (elements.fieldUrl) elements.fieldUrl.value = '';
    renderIconPicker();
    setFeedback('', false);
  }

  function editShortcut(id) {
    var shortcut = state.shortcuts.filter(function (item) { return item.id === id; })[0];
    if (!shortcut) {
      return;
    }

    state.editingId = id;
    state.selectedIcon = inferIcon(shortcut);
    if (elements.fieldId) elements.fieldId.value = id;
    if (elements.fieldTitle) elements.fieldTitle.value = shortcut.title;
    if (elements.fieldCaption) elements.fieldCaption.value = shortcut.caption;
    if (elements.fieldUrl) elements.fieldUrl.value = shortcut.url;
    renderIconPicker();
    if (elements.fieldTitle) elements.fieldTitle.focus();
  }

  async function deleteShortcut(id) {
    if (!window.confirm('Excluir este atalho?')) {
      return;
    }

    state.shortcuts = state.shortcuts.filter(function (item) { return item.id !== id; });
    renderShortcuts();
    renderMaintenanceList();
    await saveShortcuts();
  }

  async function moveShortcut(id, direction) {
    var index = state.shortcuts.findIndex(function (item) { return item.id === id; });
    var target = index + direction;
    if (index < 0 || target < 0 || target >= state.shortcuts.length) {
      return;
    }

    var item = state.shortcuts[index];
    state.shortcuts.splice(index, 1);
    state.shortcuts.splice(target, 0, item);
    renderShortcuts();
    renderMaintenanceList();
    await saveShortcuts();
  }

  async function handleSubmit(event) {
    event.preventDefault();

    var shortcut = {
      id: state.editingId || createId(),
      title: safeTrim(elements.fieldTitle ? elements.fieldTitle.value : ''),
      caption: safeTrim(elements.fieldCaption ? elements.fieldCaption.value : ''),
      url: safeTrim(elements.fieldUrl ? elements.fieldUrl.value : ''),
      icon: state.selectedIcon === 'default' ? '' : state.selectedIcon
    };

    if (!shortcut.title || !shortcut.caption || !shortcut.url) {
      setFeedback('Preencha título, legenda e link.', true);
      return;
    }

    if (state.editingId) {
      state.shortcuts = state.shortcuts.map(function (item) {
        return item.id === state.editingId ? shortcut : item;
      });
    } else {
      state.shortcuts.push(shortcut);
    }

    renderShortcuts();
    renderMaintenanceList();

    if (await saveShortcuts()) {
      resetForm();
    }
  }

  async function restoreDefaults() {
    if (!window.confirm('Restaurar os atalhos padrao desta central?')) {
      return;
    }

    state.shortcuts = state.defaults.map(cloneShortcut);
    renderShortcuts();
    renderMaintenanceList();
    await saveShortcuts();
    resetForm();
  }

  function bindEvents() {
    document.addEventListener('click', function (event) {
      var openButton = event.target.closest('[data-open-maintenance]');
      if (openButton) {
        event.preventDefault();
        openPanel();
        return;
      }

      if (event.target.closest('[data-close-maintenance]')) {
        closePanel();
        return;
      }

      if (event.target.closest('[data-unlock-maintenance]')) {
        unlockMaintenance();
        return;
      }

      var iconButton = event.target.closest('[data-icon-key]');
      if (iconButton) {
        state.selectedIcon = iconButton.getAttribute('data-icon-key');
        renderIconPicker();
        return;
      }

      var row = event.target.closest('.central-maintenance-item');
      if (!row) {
        return;
      }

      var id = row.getAttribute('data-shortcut-id');
      if (event.target.closest('[data-move-up]')) {
        moveShortcut(id, -1);
      } else if (event.target.closest('[data-move-down]')) {
        moveShortcut(id, 1);
      } else if (event.target.closest('[data-edit-shortcut]')) {
        editShortcut(id);
      } else if (event.target.closest('[data-delete-shortcut]')) {
        deleteShortcut(id);
      }
    });

    document.addEventListener('keydown', function (event) {
      if (event.key === 'Enter' && event.target === elements.password) {
        event.preventDefault();
        unlockMaintenance();
      }
    });

    if (elements.form) {
      elements.form.addEventListener('submit', handleSubmit);
    }

    var newButton = document.querySelector('[data-new-shortcut]');
    if (newButton) {
      newButton.addEventListener('click', resetForm);
    }

    var restoreButton = document.querySelector('[data-restore-defaults]');
    if (restoreButton) {
      restoreButton.addEventListener('click', restoreDefaults);
    }
  }

  async function initialize() {
    state.defaults = extractDefaults();
    state.shortcuts = state.defaults.map(cloneShortcut);
    createMaintenancePanel();
    cacheElements();
    bindEvents();

    state.shortcuts = await loadShortcuts();
    renderShortcuts();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initialize);
  } else {
    initialize();
  }
})();
