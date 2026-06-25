const SHORTCUTS_API = 'manutencao-links.ashx?AspxAutoDetectCookieSupport=1';
const SESSION_KEY = 'centralBaliMaintenanceUnlocked';
const SHORTCUT_CACHE_KEY = 'centralBaliShortcutsCache';
const FAVORITES_KEY = 'centralBaliShortcutFavorites';
const RECENT_KEY = 'centralBaliRecentShortcuts';
const SECTION_STATE_KEY = 'centralBaliOpenSections';
const COMPACT_MODE_KEY = 'centralBaliCompactMode';
const MAX_RECENT_SHORTCUTS = 12;
const SHORTCUTS_FETCH_TIMEOUT = 10000;
const MAINTENANCE_PASSWORD = '@bali2025';
const DEFAULT_NOTICE_IMAGE = 'resources/imagens/AVISOIMPORTANTE2.jpg';
const NOTICE_FILE_LIMIT = 8 * 1024 * 1024;
const CURATED_ICONS = [
  { value: 'bi-grid-1x2-fill', label: 'Atalho geral' },
  { value: 'bi-car-front-fill', label: 'Veiculo / vendas' },
  { value: 'bi-file-earmark-text-fill', label: 'Contrato / documento' },
  { value: 'bi-receipt-cutoff', label: 'Recibo' },
  { value: 'bi-bank2', label: 'Banco / financeiro' },
  { value: 'bi-telephone-forward-fill', label: 'Telefone / ramal' },
  { value: 'bi-headset', label: 'Suporte / atendimento' },
  { value: 'bi-envelope-fill', label: 'E-mail' },
  { value: 'bi-whatsapp', label: 'WhatsApp / comunicacao' },
  { value: 'bi-cloud-arrow-up-fill', label: 'Nuvem / upload' },
  { value: 'bi-shield-lock-fill', label: 'Seguranca / senha' },
  { value: 'bi-graph-up-arrow', label: 'BI / indicadores' },
  { value: 'bi-building-fill', label: 'Loja / unidade' },
  { value: 'bi-tools', label: 'Ferramentas / manutencao' },
  { value: 'bi-mortarboard-fill', label: 'Treinamento / academia' },
  { value: 'bi-printer-fill', label: 'Impressora' }
];
const ICON_CATALOG = buildIconCatalog();

const SECTION_CONFIG = {
  bali: { label: 'Bali Fiat' },
  jeep: { label: 'Bali Jeep' },
  byd: { label: 'Bali BYD' },
  bancos: { label: 'Bancos' },
  tecnologia: { label: 'Tecnologia' }
};

const searchInput = document.getElementById('shortcutSearch');
const clearButton = document.getElementById('clearSearch');
const focusSearchButton = document.getElementById('focusSearch');
const shortcutLoadStatus = document.getElementById('shortcutLoadStatus');
const emptyState = document.getElementById('emptyState');
const filterButtons = Array.from(document.querySelectorAll('[data-filter-section]'));
const compactModeButton = document.getElementById('toggleCompactMode');
const navbarCollapse = document.getElementById('mainMenu');

const maintenanceSection = document.getElementById('manutencao');
const maintenanceLock = document.getElementById('maintenanceLock');
const maintenanceWorkspace = document.getElementById('maintenanceWorkspace');
const maintenanceLoginForm = document.getElementById('maintenanceLoginForm');
const maintenancePassword = document.getElementById('maintenancePassword');
const maintenanceLoginError = document.getElementById('maintenanceLoginError');
const maintenanceForm = document.getElementById('maintenanceForm');
const maintenanceShortcutId = document.getElementById('maintenanceShortcutId');
const maintenanceTitle = document.getElementById('maintenanceTitle');
const maintenanceUrl = document.getElementById('maintenanceUrl');
const maintenanceShortcutSection = document.getElementById('maintenanceSection');
const maintenanceBadge = document.getElementById('maintenanceBadge');
const maintenanceImage = document.getElementById('maintenanceImage');
const maintenanceIcon = document.getElementById('maintenanceIcon');
const maintenanceFormStatus = document.getElementById('maintenanceFormStatus');
const maintenanceIconPickerOpen = document.getElementById('maintenanceIconPickerOpen');
const maintenanceIconPicker = document.getElementById('maintenanceIconPicker');
const maintenanceIconSearch = document.getElementById('maintenanceIconSearch');
const maintenanceIconGrid = document.getElementById('maintenanceIconGrid');
const maintenanceIconCount = document.getElementById('maintenanceIconCount');
const maintenanceIconPreview = document.getElementById('maintenanceIconPreview');
const maintenanceIconPickerClose = Array.from(document.querySelectorAll('[data-maintenance-icon-close]'));
const maintenanceList = document.getElementById('maintenanceList');
const maintenanceListSummary = document.getElementById('maintenanceListSummary');
const maintenanceAudit = document.getElementById('maintenanceAudit');
const maintenanceSearch = document.getElementById('maintenanceSearch');
const maintenanceListSection = document.getElementById('maintenanceListSection');
const maintenanceNewShortcut = document.getElementById('maintenanceNewShortcut');
const maintenanceExportShortcuts = document.getElementById('maintenanceExportShortcuts');
const maintenanceImportShortcuts = document.getElementById('maintenanceImportShortcuts');
const maintenanceImportFile = document.getElementById('maintenanceImportFile');
const maintenanceResetDefaults = document.getElementById('maintenanceResetDefaults');
const maintenanceCancelEdit = document.getElementById('maintenanceCancelEdit');
const noticeModal = document.getElementById('noticeModal');
const noticeImage = document.getElementById('noticeImage');
const noticePreviewImage = document.getElementById('noticePreviewImage');
const noticeMaintenanceForm = document.getElementById('noticeMaintenanceForm');
const noticeImageFile = document.getElementById('noticeImageFile');
const noticeAutoOpen = document.getElementById('noticeAutoOpen');
const noticeConfigSummary = document.getElementById('noticeConfigSummary');
const noticeMaintenanceStatus = document.getElementById('noticeMaintenanceStatus');
const noticeResetPreview = document.getElementById('noticeResetPreview');

let activeSection = 'all';
let sections = [];
let allSections = [];
let cards = [];
let defaultShortcuts = [];
let shortcuts = [];
let noticeConfig = { image: DEFAULT_NOTICE_IMAGE, autoOpen: false };
let filterTimer = 0;
let maintenanceBusy = false;
let favoriteShortcuts = new Set();
let recentShortcuts = [];
let restoringSections = false;

function normalizeText(value) {
  return (value || '')
    .toString()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim();
}

function cloneShortcut(shortcut) {
  return {
    id: shortcut.id,
    section: shortcut.section,
    title: shortcut.title,
    badge: shortcut.badge,
    url: shortcut.url,
    image: shortcut.image,
    icon: shortcut.icon
  };
}

function createShortcutId() {
  if (window.crypto && typeof window.crypto.randomUUID === 'function') {
    return `atalho-${window.crypto.randomUUID()}`;
  }

  return `atalho-${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

function safeTrim(value) {
  return (value || '').toString().trim();
}

function normalizeShortcutUrl(value) {
  const url = safeTrim(value);
  if (!url || url === '#') return url;
  if (/^(https?:|mailto:|tel:|\/|\.\.\/|#)/i.test(url)) return url;
  if (/^[a-z0-9.-]+\.[a-z]{2,}(\/.*)?$/i.test(url)) return `https://${url}`;
  return url;
}

function setShortcutLoadStatus(message, type) {
  if (!shortcutLoadStatus) return;
  shortcutLoadStatus.textContent = message || '';
  shortcutLoadStatus.classList.toggle('is-ok', type === 'ok');
  shortcutLoadStatus.classList.toggle('is-error', type === 'error');
}

function setMaintenanceStatus(message, type) {
  if (!maintenanceFormStatus) return;
  maintenanceFormStatus.textContent = message || '';
  maintenanceFormStatus.classList.toggle('is-ok', type === 'ok');
  maintenanceFormStatus.classList.toggle('is-error', type === 'error');
}

function setMaintenanceBusy(isBusy) {
  maintenanceBusy = isBusy;
  const controls = [];

  if (maintenanceForm) {
    controls.push(...maintenanceForm.querySelectorAll('input, select, button'));
  }

  if (maintenanceList) {
    controls.push(...maintenanceList.querySelectorAll('button'));
  }

  [maintenanceNewShortcut, maintenanceExportShortcuts, maintenanceImportShortcuts, maintenanceImportFile, maintenanceResetDefaults, maintenanceListSection, maintenanceSearch].forEach((control) => {
    if (control) controls.push(control);
  });

  controls.forEach((control) => {
    control.disabled = isBusy;
  });
}

function readShortcutCache() {
  try {
    const raw = window.localStorage.getItem(SHORTCUT_CACHE_KEY);
    if (!raw) return null;

    const cached = JSON.parse(raw);
    if (!cached || !Array.isArray(cached.shortcuts) || !cached.shortcuts.length) return null;
    return cached;
  } catch (error) {
    return null;
  }
}

function writeShortcutCache(shortcutList, notice) {
  try {
    window.localStorage.setItem(SHORTCUT_CACHE_KEY, JSON.stringify({
      shortcuts: shortcutList.map(cloneShortcut),
      notice: sanitizeNoticeConfig(notice || noticeConfig),
      savedAt: new Date().toISOString()
    }));
  } catch (error) {
    return;
  }
}

async function fetchWithTimeout(url, options = {}, timeoutMs = SHORTCUTS_FETCH_TIMEOUT) {
  if (typeof AbortController === 'undefined') {
    return fetch(url, options);
  }

  const controller = new AbortController();
  const timeout = window.setTimeout(() => controller.abort(), timeoutMs);

  try {
    return await fetch(url, Object.assign({}, options, { signal: controller.signal }));
  } finally {
    window.clearTimeout(timeout);
  }
}

function readFavoriteShortcuts() {
  try {
    const raw = window.localStorage.getItem(FAVORITES_KEY);
    const items = JSON.parse(raw || '[]');
    return new Set(Array.isArray(items) ? items.map(safeTrim).filter(Boolean) : []);
  } catch (error) {
    return new Set();
  }
}

function writeFavoriteShortcuts() {
  try {
    window.localStorage.setItem(FAVORITES_KEY, JSON.stringify(Array.from(favoriteShortcuts)));
  } catch (error) {
    return;
  }
}

function readRecentShortcuts() {
  try {
    const items = JSON.parse(window.localStorage.getItem(RECENT_KEY) || '[]');
    return Array.isArray(items) ? items.map(safeTrim).filter(Boolean).slice(0, MAX_RECENT_SHORTCUTS) : [];
  } catch (error) {
    return [];
  }
}

function writeRecentShortcuts() {
  try {
    window.localStorage.setItem(RECENT_KEY, JSON.stringify(recentShortcuts.slice(0, MAX_RECENT_SHORTCUTS)));
  } catch (error) {
    return;
  }
}

function setCompactMode(isCompact) {
  document.body.classList.toggle('is-compact', isCompact);
  if (compactModeButton) {
    compactModeButton.classList.toggle('active', isCompact);
    compactModeButton.setAttribute('aria-pressed', isCompact ? 'true' : 'false');
    const icon = compactModeButton.querySelector('i');
    if (icon) {
      icon.className = isCompact ? 'bi bi-arrows-expand' : 'bi bi-arrows-collapse';
    }
  }

  try {
    window.localStorage.setItem(COMPACT_MODE_KEY, isCompact ? 'true' : 'false');
  } catch (error) {
    return;
  }
}

function initializeCompactMode() {
  let isCompact = false;
  try {
    isCompact = window.localStorage.getItem(COMPACT_MODE_KEY) === 'true';
  } catch (error) {
    isCompact = false;
  }

  setCompactMode(isCompact);
  if (compactModeButton) {
    compactModeButton.addEventListener('click', () => {
      setCompactMode(!document.body.classList.contains('is-compact'));
    });
  }
}

function readOpenSections() {
  try {
    const items = JSON.parse(window.localStorage.getItem(SECTION_STATE_KEY) || '[]');
    return new Set(Array.isArray(items) ? items.map(safeTrim).filter(Boolean) : []);
  } catch (error) {
    return new Set();
  }
}

function writeOpenSections() {
  try {
    const openIds = allSections
      .filter((section) => section.classList.contains('is-open') && section.id)
      .map((section) => section.id);
    window.localStorage.setItem(SECTION_STATE_KEY, JSON.stringify(openIds));
  } catch (error) {
    return;
  }
}

function sanitizeNoticeConfig(raw) {
  const source = raw || {};
  return {
    image: safeTrim(source.image) || DEFAULT_NOTICE_IMAGE,
    autoOpen: source.autoOpen === true || source.autoOpen === 'true'
  };
}

function cacheBustUrl(url, shouldBust) {
  if (!shouldBust) return url;
  return `${url}${url.includes('?') ? '&' : '?'}v=${Date.now()}`;
}

function setNoticeStatus(message, type) {
  if (!noticeMaintenanceStatus) return;
  noticeMaintenanceStatus.textContent = message || '';
  noticeMaintenanceStatus.classList.toggle('is-ok', type === 'ok');
  noticeMaintenanceStatus.classList.toggle('is-error', type === 'error');
}

function updateNoticeSummary() {
  if (!noticeConfigSummary) return;
  noticeConfigSummary.textContent = noticeConfig.autoOpen
    ? 'O aviso está configurado para abrir automaticamente ao acessar a Intranet.'
    : 'O aviso aparece somente pelo botão lateral direito.';
}

function applyNoticeConfig(config, options = {}) {
  noticeConfig = sanitizeNoticeConfig(config);
  const imageUrl = cacheBustUrl(noticeConfig.image, Boolean(options.cacheBust));

  if (noticeImage) noticeImage.src = imageUrl;
  if (noticePreviewImage) noticePreviewImage.src = imageUrl;
  if (noticeAutoOpen) noticeAutoOpen.checked = noticeConfig.autoOpen;

  updateNoticeSummary();
}

function openNoticeAutomatically() {
  if (!noticeConfig.autoOpen || !noticeModal || typeof bootstrap === 'undefined') return;
  window.setTimeout(() => {
    bootstrap.Modal.getOrCreateInstance(noticeModal).show();
  }, 350);
}

function getShortcutSections() {
  return Array.from(document.querySelectorAll('.shortcut-section[data-section-block]'));
}

function extractDefaultShortcuts() {
  const extracted = [];

  getShortcutSections().forEach((section) => {
    const sectionName = section.dataset.sectionBlock;
    section.querySelectorAll('.shortcut-card').forEach((card, index) => {
      const title = safeTrim(card.querySelector('h3') ? card.querySelector('h3').textContent : card.dataset.title);
      const badge = safeTrim(card.querySelector('.shortcut-badge') ? card.querySelector('.shortcut-badge').textContent : card.dataset.badge) || 'Atalho';
      const link = card.querySelector('.shortcut-link');
      const image = card.querySelector('.shortcut-icon img');

      extracted.push({
        id: `${sectionName}-${index}-${normalizeText(title).replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')}`,
        section: sectionName,
        title: title,
        badge: badge,
        url: link ? safeTrim(link.getAttribute('href')) : '',
        image: image ? safeTrim(image.getAttribute('src')) : '',
        icon: inferIcon(`${title} ${badge} ${link ? link.getAttribute('href') : ''}`)
      });
    });
  });

  return extracted;
}

function sanitizeShortcut(raw, index) {
  const section = SECTION_CONFIG[raw.section] ? raw.section : 'bali';
  return {
    id: safeTrim(raw.id) || `atalho-importado-${index}`,
    section: section,
    title: safeTrim(raw.title) || 'Novo atalho',
    badge: safeTrim(raw.badge) || 'Atalho',
    url: safeTrim(raw.url),
    image: safeTrim(raw.image),
    icon: sanitizeIcon(raw.icon) || inferIcon(`${raw.title} ${raw.badge} ${raw.url}`)
  };
}

async function loadShortcuts() {
  try {
    setShortcutLoadStatus('Atualizando atalhos salvos...', '');
    const response = await fetchWithTimeout(`${SHORTCUTS_API}&v=${Date.now()}`, {
      cache: 'no-store',
      credentials: 'same-origin'
    });

    if (!response.ok) {
      throw new Error('Falha ao carregar atalhos.');
    }

    const payload = await response.json();
    const source = Array.isArray(payload) ? payload : payload.shortcuts;
    if (!Array.isArray(payload)) {
      applyNoticeConfig(payload.notice);
    }

    if (!Array.isArray(source) || !source.length) {
      setShortcutLoadStatus('Usando atalhos padrão da página.', '');
      return defaultShortcuts.map(cloneShortcut);
    }

    const loaded = source.map(sanitizeShortcut).filter((shortcut) => shortcut.title && shortcut.section);
    writeShortcutCache(loaded, Array.isArray(payload) ? noticeConfig : payload.notice);
    setShortcutLoadStatus('Atalhos atualizados.', 'ok');
    return loaded;
  } catch (error) {
    setShortcutLoadStatus('Não foi possível atualizar agora. Exibindo última lista carregada.', 'error');
    return shortcuts.length ? shortcuts.map(cloneShortcut) : defaultShortcuts.map(cloneShortcut);
  }
}

async function saveNoticeConfig(event) {
  event.preventDefault();
  const file = noticeImageFile && noticeImageFile.files ? noticeImageFile.files[0] : null;

  if (file && file.size > NOTICE_FILE_LIMIT) {
    setNoticeStatus('Imagem muito grande. Use um arquivo de até 8 MB.', 'error');
    return;
  }

  const formData = new FormData();
  formData.append('mode', 'notice');
  formData.append('password', MAINTENANCE_PASSWORD);
  formData.append('autoOpen', noticeAutoOpen && noticeAutoOpen.checked ? 'true' : 'false');
  if (file) formData.append('noticeImageFile', file);

  setNoticeStatus('Salvando aviso...', '');

  try {
    const response = await fetch(SHORTCUTS_API, {
      method: 'POST',
      credentials: 'same-origin',
      body: formData
    });

    const payload = await response.json().catch(() => ({}));

    if (!response.ok || payload.ok === false) {
      throw new Error(payload.message || 'Falha ao salvar aviso.');
    }

    applyNoticeConfig(payload.notice || {
      image: noticeConfig.image,
      autoOpen: noticeAutoOpen && noticeAutoOpen.checked
    }, { cacheBust: true });

    if (noticeImageFile) noticeImageFile.value = '';
    setNoticeStatus('Aviso salvo com sucesso.', 'ok');
  } catch (error) {
    setNoticeStatus(error.message || 'Não foi possível salvar o aviso.', 'error');
  }
}

async function saveShortcuts() {
  if (maintenanceBusy) {
    setMaintenanceStatus('Aguarde o salvamento atual terminar.', 'error');
    return false;
  }

  setMaintenanceBusy(true);
  setMaintenanceStatus('Salvando alterações...', '');

  try {
    const response = await fetch(SHORTCUTS_API, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        password: MAINTENANCE_PASSWORD,
        shortcuts: shortcuts
      })
    });

    const payload = await response.json().catch(() => ({}));

    if (!response.ok || payload.ok === false) {
      throw new Error(payload.message || 'Falha ao salvar.');
    }

    writeShortcutCache(shortcuts, noticeConfig);
    setShortcutLoadStatus('Atalhos salvos com sucesso.', 'ok');
    setMaintenanceStatus('Alterações salvas com sucesso.', 'ok');
    return true;
  } catch (error) {
    setShortcutLoadStatus('Não foi possível salvar os atalhos no servidor.', 'error');
    setMaintenanceStatus(error.message || 'Não foi possível salvar os atalhos no servidor.', 'error');
    return false;
  } finally {
    setMaintenanceBusy(false);
  }
}

function setMaintenanceSession(isUnlocked) {
  try {
    if (isUnlocked) {
      window.sessionStorage.setItem(SESSION_KEY, 'true');
    } else {
      window.sessionStorage.removeItem(SESSION_KEY);
    }
  } catch (error) {
    return;
  }
}

function isMaintenanceUnlocked() {
  try {
    return window.sessionStorage.getItem(SESSION_KEY) === 'true';
  } catch (error) {
    return false;
  }
}

function setSectionOpen(section, isOpen, options = {}) {
  if (!section) return;
  const heading = section.querySelector('.section-heading');
  const grid = section.querySelector('.shortcut-grid');
  section.classList.toggle('is-open', isOpen);
  if (heading) {
    heading.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
  }
  if (grid) {
    grid.setAttribute('aria-hidden', isOpen ? 'false' : 'true');
  }
  if (options.persist && !restoringSections) {
    writeOpenSections();
  }
}

function toggleSection(section) {
  setSectionOpen(section, !section.classList.contains('is-open'), { persist: true });
}

function restoreOpenSections() {
  const openIds = readOpenSections();
  if (!openIds.size) return;

  restoringSections = true;
  allSections.forEach((section) => {
    setSectionOpen(section, openIds.has(section.id));
  });
  restoringSections = false;
}

function setClearButtonState() {
  if (!clearButton || !searchInput) return;
  clearButton.classList.toggle('is-hidden', searchInput.value.length === 0);
}

function buildShortcutCard(shortcut) {
  const article = document.createElement('article');
  article.className = 'shortcut-card';
  article.dataset.id = shortcut.id;
  article.dataset.section = shortcut.section;
  article.dataset.title = normalizeText(shortcut.title);
  article.dataset.badge = normalizeText(shortcut.badge);
  const sectionLabel = SECTION_CONFIG[shortcut.section] ? SECTION_CONFIG[shortcut.section].label : shortcut.section;
  article.dataset.search = normalizeText(`${shortcut.title} ${shortcut.badge} ${shortcut.section} ${sectionLabel} ${shortcut.url} ${shortcut.icon}`);
  article.classList.toggle('is-favorite', favoriteShortcuts.has(shortcut.id));

  const icon = document.createElement('div');
  icon.className = 'shortcut-icon';

  const selectedIcon = sanitizeIcon(shortcut.icon) || 'bi-grid-1x2-fill';
  const fallback = document.createElement('i');
  fallback.className = shortcut.image ? `bi ${selectedIcon} fallback-icon d-none` : `bi ${selectedIcon} fallback-icon`;

  if (shortcut.image) {
    const image = document.createElement('img');
    image.src = shortcut.image;
    image.alt = '';
    image.loading = 'lazy';
    image.decoding = 'async';
    image.addEventListener('error', () => {
      image.classList.add('d-none');
      fallback.classList.remove('d-none');
    });
    icon.appendChild(image);
  }

  icon.appendChild(fallback);

  const content = document.createElement('div');
  content.className = 'shortcut-content';

  const favoriteButton = document.createElement('button');
  favoriteButton.type = 'button';
  favoriteButton.className = 'shortcut-favorite';
  favoriteButton.setAttribute('aria-label', favoriteShortcuts.has(shortcut.id) ? `Remover ${shortcut.title} dos favoritos` : `Favoritar ${shortcut.title}`);
  favoriteButton.setAttribute('aria-pressed', favoriteShortcuts.has(shortcut.id) ? 'true' : 'false');
  favoriteButton.innerHTML = `<i class="bi ${favoriteShortcuts.has(shortcut.id) ? 'bi-star-fill' : 'bi-star'}"></i>`;
  favoriteButton.addEventListener('click', () => toggleFavorite(shortcut.id));

  const badge = document.createElement('span');
  badge.className = 'shortcut-badge';
  badge.textContent = shortcut.badge;

  const title = document.createElement('h3');
  title.textContent = shortcut.title;

  content.appendChild(badge);
  content.appendChild(title);

  const link = document.createElement('a');
  link.className = shortcut.url ? 'shortcut-link' : 'shortcut-link disabled';
  link.href = shortcut.url || '#';
  if (shortcut.url) {
    link.target = '_blank';
    link.rel = 'noopener noreferrer';
  } else {
    link.setAttribute('aria-disabled', 'true');
  }
  link.setAttribute('aria-label', `Abrir ${shortcut.title}`);

  const label = document.createElement('span');
  label.textContent = shortcut.url ? 'Acessar' : 'Sem link';
  const linkIcon = document.createElement('i');
  linkIcon.className = 'bi bi-box-arrow-up-right';

  link.appendChild(label);
  link.appendChild(linkIcon);
  if (shortcut.url) {
    link.addEventListener('click', () => rememberRecentShortcut(shortcut.id));
  }

  article.appendChild(icon);
  article.appendChild(content);
  article.appendChild(favoriteButton);
  article.appendChild(link);

  return article;
}

function updateDashboardTotals() {
  const total = shortcuts.length;
  const validIds = new Set(shortcuts.map((shortcut) => shortcut.id));
  const favoriteCount = Array.from(favoriteShortcuts).filter((id) => validIds.has(id)).length;
  const recentCount = recentShortcuts.filter((id) => validIds.has(id)).length;
  const usedSections = Object.keys(SECTION_CONFIG).filter((section) => shortcuts.some((shortcut) => shortcut.section === section)).length;
  const metricValues = document.querySelectorAll('.metric-grid strong');

  if (metricValues[0]) metricValues[0].textContent = total;
  if (metricValues[1]) metricValues[1].textContent = usedSections;

  filterButtons.forEach((button) => {
    const section = button.dataset.filterSection;
    const counter = button.querySelector('span');
    if (!counter) return;

    const count = section === 'all'
      ? total
      : section === 'favorites'
        ? favoriteCount
        : section === 'recent'
          ? recentCount
          : shortcuts.filter((shortcut) => shortcut.section === section).length;
    counter.textContent = count;
  });
}

function updateSectionCounts() {
  sections.forEach((section) => {
    const count = section.querySelectorAll('.shortcut-card:not(.is-hidden)').length;
    const counter = section.querySelector('.section-count');
    if (!counter) return;
    counter.textContent = `${count} ${count === 1 ? 'atalho' : 'atalhos'}`;
  });
}

function bindDisabledLinks() {
  document.querySelectorAll('.shortcut-link.disabled').forEach((link) => {
    link.addEventListener('click', (event) => event.preventDefault());
  });
}

function pruneFavoriteShortcuts() {
  const validIds = new Set(shortcuts.map((shortcut) => shortcut.id));
  const previousSize = favoriteShortcuts.size;
  favoriteShortcuts = new Set(Array.from(favoriteShortcuts).filter((id) => validIds.has(id)));
  if (favoriteShortcuts.size !== previousSize) {
    writeFavoriteShortcuts();
  }
}

function pruneRecentShortcuts() {
  const validIds = new Set(shortcuts.map((shortcut) => shortcut.id));
  const previous = recentShortcuts.join('|');
  recentShortcuts = recentShortcuts.filter((id, index, list) => validIds.has(id) && list.indexOf(id) === index).slice(0, MAX_RECENT_SHORTCUTS);
  if (recentShortcuts.join('|') !== previous) {
    writeRecentShortcuts();
  }
}

function rememberRecentShortcut(id) {
  if (!id) return;
  recentShortcuts = [id].concat(recentShortcuts.filter((item) => item !== id)).slice(0, MAX_RECENT_SHORTCUTS);
  writeRecentShortcuts();
  updateDashboardTotals();
}

function toggleFavorite(id) {
  if (!id) return;
  if (favoriteShortcuts.has(id)) {
    favoriteShortcuts.delete(id);
  } else {
    favoriteShortcuts.add(id);
  }

  writeFavoriteShortcuts();
  renderShortcuts();
}

function renderShortcuts() {
  sections = getShortcutSections();
  pruneFavoriteShortcuts();
  pruneRecentShortcuts();

  sections.forEach((section) => {
    const grid = section.querySelector('.shortcut-grid');
    if (!grid) return;

    grid.innerHTML = '';
    shortcuts
      .filter((shortcut) => shortcut.section === section.dataset.sectionBlock)
      .forEach((shortcut) => grid.appendChild(buildShortcutCard(shortcut)));
  });

  cards = Array.from(document.querySelectorAll('.shortcut-card'));
  bindDisabledLinks();
  updateDashboardTotals();
  applyFilters();
  renderMaintenanceList();
}

function applyFilters() {
  const term = normalizeText(searchInput ? searchInput.value : '');
  let visibleCards = 0;

  cards.forEach((card) => {
    const haystack = card.dataset.search || normalizeText(`${card.dataset.title} ${card.dataset.badge} ${card.dataset.section} ${card.textContent}`);
    const matchesText = !term || haystack.includes(term);
    const matchesSection = activeSection === 'all'
      || (activeSection === 'favorites' && favoriteShortcuts.has(card.dataset.id))
      || (activeSection === 'recent' && recentShortcuts.includes(card.dataset.id))
      || card.dataset.section === activeSection;
    const visible = matchesText && matchesSection;

    card.classList.toggle('is-hidden', !visible);
    if (visible) visibleCards += 1;
  });

  sections.forEach((section) => {
    const hasVisibleCard = Boolean(section.querySelector('.shortcut-card:not(.is-hidden)'));
    section.classList.toggle('is-hidden', !hasVisibleCard);
    if (hasVisibleCard && (term || activeSection !== 'all')) {
      setSectionOpen(section, true);
    }
  });

  if (emptyState) {
    emptyState.classList.toggle('d-none', visibleCards !== 0);
  }

  updateSectionCounts();
  setClearButtonState();
}

function scheduleApplyFilters() {
  window.clearTimeout(filterTimer);
  filterTimer = window.setTimeout(applyFilters, 80);
}

function closeMobileMenu() {
  if (!navbarCollapse || typeof bootstrap === 'undefined') return;
  const instance = bootstrap.Collapse.getInstance(navbarCollapse);
  if (instance) instance.hide();
}

function focusSearch() {
  const toolbar = document.getElementById('atalhos');
  if (toolbar) toolbar.scrollIntoView({ behavior: 'smooth', block: 'start' });
  window.setTimeout(() => {
    if (searchInput) searchInput.focus();
  }, 220);
}

function initializeSectionToggles() {
  allSections = Array.from(document.querySelectorAll('.shortcut-section'));

  allSections.forEach((section) => {
    const heading = section.querySelector('.section-heading');
    if (!heading || heading.dataset.toggleReady === 'true') return;
    const grid = section.querySelector('.shortcut-grid');
    if (grid && !grid.id && section.id) {
      grid.id = `${section.id}-atalhos`;
    }

    heading.dataset.toggleReady = 'true';
    heading.setAttribute('role', 'button');
    heading.setAttribute('tabindex', '0');
    heading.setAttribute('aria-expanded', 'false');
    if (grid && grid.id) {
      heading.setAttribute('aria-controls', grid.id);
      grid.setAttribute('aria-hidden', 'true');
    }

    heading.addEventListener('click', () => {
      toggleSection(section);
    });

    heading.addEventListener('keydown', (event) => {
      if (event.key !== 'Enter' && event.key !== ' ') return;
      event.preventDefault();
      toggleSection(section);
    });
  });
}

function setMaintenanceState(isUnlocked) {
  if (!maintenanceLock || !maintenanceWorkspace) return;
  maintenanceLock.classList.toggle('d-none', isUnlocked);
  maintenanceWorkspace.classList.toggle('d-none', !isUnlocked);
  if (isUnlocked) renderMaintenanceList();
}

function resetMaintenanceForm() {
  if (!maintenanceForm) return;
  maintenanceShortcutId.value = '';
  maintenanceTitle.value = '';
  maintenanceUrl.value = '';
  maintenanceShortcutSection.value = 'bali';
  maintenanceBadge.value = 'Atalho';
  maintenanceImage.value = '';
  if (maintenanceIcon) maintenanceIcon.value = 'bi-grid-1x2-fill';
  updateMaintenanceIconPreview();
  setMaintenanceStatus('Pronto para cadastrar um novo atalho.', '');
  maintenanceTitle.focus();
}

function exportShortcutsBackup() {
  const payload = {
    ok: true,
    exportedAt: new Date().toISOString(),
    shortcuts: shortcuts.map(cloneShortcut),
    notice: sanitizeNoticeConfig(noticeConfig)
  };
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  const stamp = new Date().toISOString().slice(0, 10);

  link.href = url;
  link.download = `intranet-atalhos-${stamp}.json`;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
  setMaintenanceStatus('Backup JSON gerado.', 'ok');
}

function normalizedUrlKey(value) {
  return safeTrim(value)
    .replace(/\/+$/, '')
    .toLowerCase();
}

function getShortcutAudit() {
  const titleMap = new Map();
  const urlMap = new Map();
  const emptyLinks = [];

  shortcuts.forEach((shortcut) => {
    const section = shortcut.section || 'bali';
    const titleKey = `${section}|${normalizeText(shortcut.title)}`;
    const urlKey = `${section}|${normalizedUrlKey(shortcut.url)}`;

    if (normalizeText(shortcut.title)) {
      titleMap.set(titleKey, (titleMap.get(titleKey) || 0) + 1);
    }

    if (normalizedUrlKey(shortcut.url) && shortcut.url !== '#') {
      urlMap.set(urlKey, (urlMap.get(urlKey) || 0) + 1);
    } else {
      emptyLinks.push(shortcut);
    }
  });

  return {
    duplicateTitles: Array.from(titleMap.values()).filter((count) => count > 1).length,
    duplicateUrls: Array.from(urlMap.values()).filter((count) => count > 1).length,
    emptyLinks: emptyLinks.length
  };
}

function renderMaintenanceAudit() {
  if (!maintenanceAudit || !isMaintenanceUnlocked()) return;

  const audit = getShortcutAudit();
  const hasIssue = audit.duplicateTitles || audit.duplicateUrls || audit.emptyLinks;
  maintenanceAudit.classList.toggle('is-ok', !hasIssue);
  maintenanceAudit.classList.toggle('is-warning', Boolean(hasIssue));
  maintenanceAudit.innerHTML = '';

  const title = document.createElement('strong');
  title.textContent = hasIssue ? 'Atenção na lista' : 'Lista consistente';
  maintenanceAudit.appendChild(title);

  const items = [
    { label: 'nomes repetidos no mesmo grupo', count: audit.duplicateTitles },
    { label: 'links repetidos no mesmo grupo', count: audit.duplicateUrls },
    { label: 'atalhos sem link', count: audit.emptyLinks }
  ];

  items.forEach((item) => {
    const badge = document.createElement('span');
    badge.textContent = `${item.count} ${item.label}`;
    badge.className = item.count ? 'has-issue' : '';
    maintenanceAudit.appendChild(badge);
  });
}

function readFileText(file) {
  if (file && typeof file.text === 'function') {
    return file.text();
  }

  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result || '');
    reader.onerror = () => reject(reader.error || new Error('Falha ao ler arquivo.'));
    reader.readAsText(file, 'utf-8');
  });
}

function normalizeImportedShortcuts(payload) {
  const source = Array.isArray(payload) ? payload : payload && payload.shortcuts;
  if (!Array.isArray(source)) return [];

  return source
    .map((shortcut, index) => sanitizeShortcut(shortcut || {}, index))
    .filter((shortcut) => shortcut.title && shortcut.url && SECTION_CONFIG[shortcut.section]);
}

async function importShortcutsBackup(event) {
  const file = event && event.target && event.target.files ? event.target.files[0] : null;
  if (!file) return;

  try {
    setMaintenanceStatus('Lendo backup JSON...', '');
    const text = await readFileText(file);
    const payload = JSON.parse(text);
    const importedShortcuts = normalizeImportedShortcuts(payload);

    if (!importedShortcuts.length) {
      throw new Error('O arquivo não possui atalhos válidos para importar.');
    }

    const confirmed = window.confirm(`Importar ${importedShortcuts.length} atalhos do backup? A lista atual será substituída após salvar no servidor.`);
    if (!confirmed) {
      setMaintenanceStatus('Importação cancelada.', '');
      return;
    }

    const previousShortcuts = shortcuts.map(cloneShortcut);
    shortcuts = importedShortcuts;
    setMaintenanceStatus(`Importando ${importedShortcuts.length} atalhos...`, '');

    const saved = await saveShortcuts();
    if (!saved) {
      shortcuts = previousShortcuts;
      renderShortcuts();
      setMaintenanceStatus('A lista anterior foi restaurada porque o servidor não salvou a importação.', 'error');
      return;
    }

    renderShortcuts();
    resetMaintenanceForm();
    setMaintenanceStatus(`${importedShortcuts.length} atalhos importados com sucesso.`, 'ok');
  } catch (error) {
    setMaintenanceStatus(error.message || 'Não foi possível importar o backup.', 'error');
  } finally {
    if (maintenanceImportFile) maintenanceImportFile.value = '';
  }
}

function getMaintenanceFilters() {
  return {
    term: normalizeText(maintenanceSearch ? maintenanceSearch.value : ''),
    section: maintenanceListSection ? maintenanceListSection.value : 'all'
  };
}

function renderMaintenanceList() {
  if (!maintenanceList || !isMaintenanceUnlocked()) return;
  renderMaintenanceAudit();

  const filters = getMaintenanceFilters();
  const isSearchFiltered = Boolean(filters.term);
  const visibleShortcuts = shortcuts.filter((shortcut) => {
    const matchesSection = filters.section === 'all' || shortcut.section === filters.section;
    const haystack = normalizeText(`${shortcut.title} ${shortcut.badge} ${shortcut.url} ${shortcut.icon} ${SECTION_CONFIG[shortcut.section].label}`);
    const matchesTerm = !filters.term || haystack.includes(filters.term);
    return matchesSection && matchesTerm;
  });

  maintenanceList.innerHTML = '';

  if (maintenanceListSummary) {
    maintenanceListSummary.textContent = `${visibleShortcuts.length} de ${shortcuts.length} atalhos exibidos`;
  }

  if (!visibleShortcuts.length) {
    const empty = document.createElement('div');
    empty.className = 'empty-state';
    empty.innerHTML = '<i class="bi bi-search-heart"></i><h2>Nenhum atalho encontrado</h2><p>Ajuste a busca ou o filtro da manutencao.</p>';
    maintenanceList.appendChild(empty);
    return;
  }

  visibleShortcuts.forEach((shortcut) => {
    const sectionShortcuts = shortcuts.filter((item) => item.section === shortcut.section);
    const sectionPosition = sectionShortcuts.findIndex((item) => item.id === shortcut.id);
    const isFirstInSection = sectionPosition <= 0;
    const isLastInSection = sectionPosition < 0 || sectionPosition >= sectionShortcuts.length - 1;

    const item = document.createElement('div');
    item.className = 'maintenance-item';

    const itemIcon = document.createElement('div');
    itemIcon.className = 'maintenance-item-icon';
    if (shortcut.image) {
      const image = document.createElement('img');
      image.src = shortcut.image;
      image.alt = '';
      image.loading = 'lazy';
      image.decoding = 'async';
      image.addEventListener('error', () => {
        image.remove();
        itemIcon.innerHTML = `<i class="bi ${sanitizeIcon(shortcut.icon) || 'bi-grid-1x2-fill'}"></i>`;
      });
      itemIcon.appendChild(image);
    } else {
      itemIcon.innerHTML = `<i class="bi ${sanitizeIcon(shortcut.icon) || 'bi-grid-1x2-fill'}"></i>`;
    }

    const info = document.createElement('div');
    const title = document.createElement('div');
    title.className = 'maintenance-item-title';

    const strong = document.createElement('strong');
    strong.textContent = shortcut.title;

    const category = document.createElement('span');
    category.textContent = SECTION_CONFIG[shortcut.section] ? SECTION_CONFIG[shortcut.section].label : shortcut.section;

    const badge = document.createElement('span');
    badge.textContent = shortcut.badge;

    const order = document.createElement('span');
    order.className = 'maintenance-order-badge';
    order.textContent = `Ordem ${sectionPosition + 1}/${sectionShortcuts.length}`;

    const url = document.createElement('p');
    url.textContent = shortcut.url || 'Sem link cadastrado';

    title.appendChild(strong);
    title.appendChild(category);
    title.appendChild(badge);
    title.appendChild(order);
    info.appendChild(title);
    info.appendChild(url);

    const actions = document.createElement('div');
    actions.className = 'maintenance-item-actions';

    const moveUp = document.createElement('button');
    moveUp.type = 'button';
    moveUp.className = 'secondary icon-only';
    moveUp.innerHTML = '<i class="bi bi-arrow-up"></i><span>Subir</span>';
    moveUp.title = isSearchFiltered ? 'Limpe a busca para reordenar.' : 'Mover para cima dentro da categoria';
    moveUp.disabled = isSearchFiltered || isFirstInSection;
    moveUp.addEventListener('click', () => moveShortcut(shortcut.id, -1));

    const moveDown = document.createElement('button');
    moveDown.type = 'button';
    moveDown.className = 'secondary icon-only';
    moveDown.innerHTML = '<i class="bi bi-arrow-down"></i><span>Descer</span>';
    moveDown.title = isSearchFiltered ? 'Limpe a busca para reordenar.' : 'Mover para baixo dentro da categoria';
    moveDown.disabled = isSearchFiltered || isLastInSection;
    moveDown.addEventListener('click', () => moveShortcut(shortcut.id, 1));

    const edit = document.createElement('button');
    edit.type = 'button';
    edit.className = 'secondary';
    edit.innerHTML = '<i class="bi bi-pencil-square"></i> Editar';
    edit.addEventListener('click', () => editShortcut(shortcut.id));

    const remove = document.createElement('button');
    remove.type = 'button';
    remove.className = 'danger';
    remove.innerHTML = '<i class="bi bi-trash3"></i> Excluir';
    remove.addEventListener('click', () => deleteShortcut(shortcut.id));

    actions.appendChild(moveUp);
    actions.appendChild(moveDown);
    actions.appendChild(edit);
    actions.appendChild(remove);
    item.appendChild(itemIcon);
    item.appendChild(info);
    item.appendChild(actions);
    maintenanceList.appendChild(item);
  });
}

function editShortcut(id) {
  const shortcut = shortcuts.find((item) => item.id === id);
  if (!shortcut) return;

  maintenanceShortcutId.value = shortcut.id;
  maintenanceTitle.value = shortcut.title;
  maintenanceUrl.value = shortcut.url;
  maintenanceShortcutSection.value = shortcut.section;
  maintenanceBadge.value = shortcut.badge;
  maintenanceImage.value = shortcut.image;
  if (maintenanceIcon) maintenanceIcon.value = sanitizeIcon(shortcut.icon) || inferIcon(`${shortcut.title} ${shortcut.badge} ${shortcut.url}`);
  updateMaintenanceIconPreview();
  setMaintenanceStatus(`Editando "${shortcut.title}".`, '');

  maintenanceForm.scrollIntoView({ behavior: 'smooth', block: 'center' });
  maintenanceTitle.focus();
}

async function deleteShortcut(id) {
  const shortcut = shortcuts.find((item) => item.id === id);
  if (!shortcut) return;

  const confirmed = window.confirm(`Excluir o atalho "${shortcut.title}"?`);
  if (!confirmed) return;

  const previousShortcuts = shortcuts.map(cloneShortcut);
  setMaintenanceStatus(`Excluindo "${shortcut.title}"...`, '');
  shortcuts = shortcuts.filter((item) => item.id !== id);
  const saved = await saveShortcuts();
  if (!saved) {
    shortcuts = previousShortcuts;
    setMaintenanceStatus('Exclusão cancelada porque o servidor não salvou a alteração.', 'error');
  } else {
    setMaintenanceStatus(`Atalho "${shortcut.title}" excluído.`, 'ok');
  }
  renderShortcuts();
}

async function moveShortcut(id, direction) {
  const currentIndex = shortcuts.findIndex((item) => item.id === id);
  if (currentIndex < 0) return;

  const shortcut = shortcuts[currentIndex];
  const sectionIndexes = shortcuts
    .map((item, index) => item.section === shortcut.section ? index : -1)
    .filter((index) => index >= 0);
  const currentSectionPosition = sectionIndexes.indexOf(currentIndex);
  const targetSectionPosition = currentSectionPosition + direction;

  if (targetSectionPosition < 0 || targetSectionPosition >= sectionIndexes.length) return;

  const targetIndex = sectionIndexes[targetSectionPosition];
  const previousShortcuts = shortcuts.map(cloneShortcut);
  const moved = shortcuts[currentIndex];
  shortcuts[currentIndex] = shortcuts[targetIndex];
  shortcuts[targetIndex] = moved;

  setMaintenanceStatus(`Reordenando "${shortcut.title}"...`, '');
  const saved = await saveShortcuts();
  if (!saved) {
    shortcuts = previousShortcuts;
    setMaintenanceStatus('A ordem anterior foi restaurada porque o servidor não salvou a alteração.', 'error');
  } else {
    setMaintenanceStatus(`Ordem de "${shortcut.title}" atualizada.`, 'ok');
  }

  renderShortcuts();

  const targetSection = document.querySelector(`.shortcut-section[data-section-block="${shortcut.section}"]`);
  setSectionOpen(targetSection, true);
  setSectionOpen(maintenanceSection, true);
}

async function handleMaintenanceSubmit(event) {
  event.preventDefault();

  const id = safeTrim(maintenanceShortcutId.value) || createShortcutId();
  const shortcut = {
    id: id,
    section: maintenanceShortcutSection.value,
    title: safeTrim(maintenanceTitle.value),
    badge: safeTrim(maintenanceBadge.value) || 'Atalho',
    url: normalizeShortcutUrl(maintenanceUrl.value),
    image: safeTrim(maintenanceImage.value),
    icon: sanitizeIcon(maintenanceIcon ? maintenanceIcon.value : '') || inferIcon(`${maintenanceTitle.value} ${maintenanceBadge.value} ${maintenanceUrl.value}`)
  };

  if (!shortcut.title || !shortcut.url || !SECTION_CONFIG[shortcut.section]) {
    setMaintenanceStatus('Preencha nome, link e categoria do atalho antes de salvar.', 'error');
    if (!shortcut.title && maintenanceTitle) maintenanceTitle.focus();
    else if (!shortcut.url && maintenanceUrl) maintenanceUrl.focus();
    else if (maintenanceShortcutSection) maintenanceShortcutSection.focus();
    return;
  }

  const previousShortcuts = shortcuts.map(cloneShortcut);
  const index = shortcuts.findIndex((item) => item.id === id);
  const isEditing = index >= 0;
  if (index >= 0) {
    shortcuts[index] = shortcut;
  } else {
    shortcuts.push(shortcut);
  }

  setMaintenanceStatus(isEditing ? `Salvando alterações de "${shortcut.title}"...` : `Criando "${shortcut.title}"...`, '');
  const saved = await saveShortcuts();
  if (!saved) {
    shortcuts = previousShortcuts;
    renderShortcuts();
    return;
  }

  renderShortcuts();
  resetMaintenanceForm();
  setMaintenanceStatus(isEditing ? `Atalho "${shortcut.title}" atualizado.` : `Atalho "${shortcut.title}" criado.`, 'ok');

  const targetSection = document.querySelector(`.shortcut-section[data-section-block="${shortcut.section}"]`);
  setSectionOpen(targetSection, true);
  setSectionOpen(maintenanceSection, true);
}

async function restoreDefaults() {
  const confirmed = window.confirm('Restaurar a lista padrão de atalhos? As alterações salvas no servidor serão substituídas.');
  if (!confirmed) return;

  const previousShortcuts = shortcuts.map(cloneShortcut);
  shortcuts = defaultShortcuts.map(cloneShortcut);
  setMaintenanceStatus('Restaurando lista padrão...', '');
  const saved = await saveShortcuts();
  if (!saved) {
    shortcuts = previousShortcuts;
  }

  renderShortcuts();
  resetMaintenanceForm();
  setMaintenanceStatus(
    saved ? 'Lista padrão restaurada.' : 'A lista anterior foi restaurada porque o servidor não salvou a alteração.',
    saved ? 'ok' : 'error'
  );
}

function openMaintenanceIconPicker() {
  if (!maintenanceIconPicker) return;
  maintenanceIconPicker.classList.remove('d-none');
  maintenanceIconPicker.setAttribute('aria-hidden', 'false');
  if (maintenanceIconSearch) maintenanceIconSearch.value = '';
  renderMaintenanceIconGrid('');
  window.setTimeout(() => {
    if (maintenanceIconSearch) maintenanceIconSearch.focus();
  }, 40);
}

function closeMaintenanceIconPicker() {
  if (!maintenanceIconPicker) return;
  maintenanceIconPicker.classList.add('d-none');
  maintenanceIconPicker.setAttribute('aria-hidden', 'true');
  if (maintenanceIconPickerOpen) maintenanceIconPickerOpen.focus();
}

function chooseMaintenanceIcon(icon) {
  const selectedIcon = sanitizeIcon(icon);
  if (!selectedIcon || !maintenanceIcon) return;

  maintenanceIcon.value = selectedIcon;
  if (maintenanceImage) maintenanceImage.value = '';
  updateMaintenanceIconPreview();
  closeMaintenanceIconPicker();
}

function renderMaintenanceIconGrid(filter) {
  if (!maintenanceIconGrid) return;

  const term = normalizeText(filter);
  const visibleIcons = ICON_CATALOG.filter((icon) => {
    if (!term) return true;
    return normalizeText(`${icon.value} ${icon.label}`).includes(term);
  });

  maintenanceIconGrid.innerHTML = '';
  if (maintenanceIconCount) {
    maintenanceIconCount.textContent = `${visibleIcons.length} de ${ICON_CATALOG.length} icones disponiveis no servidor.`;
  }

  visibleIcons.forEach((icon) => {
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'maintenance-icon-option';
    button.dataset.iconOption = icon.value;
    button.title = icon.label;
    button.setAttribute('aria-label', icon.label);

    const symbol = document.createElement('i');
    symbol.className = `bi ${icon.value}`;
    button.appendChild(symbol);

    if (maintenanceIcon && icon.value === maintenanceIcon.value) {
      button.classList.add('is-selected');
    }

    maintenanceIconGrid.appendChild(button);
  });
}

function updateMaintenanceIconPreview() {
  const selectedIcon = sanitizeIcon(maintenanceIcon ? maintenanceIcon.value : '') || 'bi-grid-1x2-fill';
  const imagePath = safeTrim(maintenanceImage ? maintenanceImage.value : '');
  const label = imagePath ? 'Imagem personalizada' : getIconLabel(selectedIcon);

  if (maintenanceIcon) maintenanceIcon.value = selectedIcon;

  if (maintenanceIconPreview) {
    maintenanceIconPreview.innerHTML = '';
    if (imagePath) {
      const image = document.createElement('img');
      image.src = imagePath;
      image.alt = '';
      image.loading = 'lazy';
      image.decoding = 'async';
      image.addEventListener('error', () => {
        image.remove();
        const fallback = document.createElement('i');
        fallback.className = `bi ${selectedIcon}`;
        maintenanceIconPreview.prepend(fallback);
      });
      maintenanceIconPreview.appendChild(image);
    } else {
      const symbol = document.createElement('i');
      symbol.className = `bi ${selectedIcon}`;
      maintenanceIconPreview.appendChild(symbol);
    }

    const text = document.createElement('span');
    text.textContent = label;
    maintenanceIconPreview.appendChild(text);
  }

  if (maintenanceIconPickerOpen) {
    maintenanceIconPickerOpen.innerHTML = '';
    const symbol = document.createElement('i');
    symbol.className = `bi ${selectedIcon}`;
    const text = document.createElement('span');
    text.textContent = 'Escolher icone';
    maintenanceIconPickerOpen.appendChild(symbol);
    maintenanceIconPickerOpen.appendChild(text);
  }

  if (maintenanceIconGrid) {
    maintenanceIconGrid.querySelectorAll('.maintenance-icon-option').forEach((button) => {
      button.classList.toggle('is-selected', button.dataset.iconOption === selectedIcon);
    });
  }
}

function buildIconCatalog() {
  const map = {};
  const catalog = [];

  CURATED_ICONS.forEach((icon) => {
    if (!map[icon.value]) {
      map[icon.value] = true;
      catalog.push(icon);
    }
  });

  (window.CENTRAL_BOOTSTRAP_ICONS || []).forEach((icon) => {
    const value = sanitizeIcon(icon);
    if (!value || map[value]) return;
    map[value] = true;
    catalog.push({
      value: value,
      label: prettifyIconName(value)
    });
  });

  return catalog.length ? catalog : CURATED_ICONS.slice(0);
}

function getIconLabel(icon) {
  const selectedIcon = sanitizeIcon(icon) || 'bi-grid-1x2-fill';
  const found = ICON_CATALOG.find((item) => item.value === selectedIcon);
  return found ? found.label : prettifyIconName(selectedIcon);
}

function inferIcon(text) {
  const key = normalizeText(text);
  if (key.includes('contrato') || key.includes('documento')) return 'bi-file-earmark-text-fill';
  if (key.includes('recibo')) return 'bi-receipt-cutoff';
  if (key.includes('nfe') || key.includes('nota')) return 'bi-file-earmark-pdf-fill';
  if (key.includes('banco') || key.includes('conta') || key.includes('financeiro') || key.includes('fandi')) return 'bi-bank2';
  if (key.includes('telefone') || key.includes('ramal') || key.includes('voip')) return 'bi-telephone-forward-fill';
  if (key.includes('carro') || key.includes('veiculo') || key.includes('vendas') || key.includes('patio')) return 'bi-car-front-fill';
  if (key.includes('suporte') || key.includes('chamado') || key.includes('anydesk') || key.includes('teamviewer')) return 'bi-headset';
  if (key.includes('email') || key.includes('e-mail') || key.includes('webmail')) return 'bi-envelope-fill';
  if (key.includes('whatsapp') || key.includes('zenvia') || key.includes('comunicacao')) return 'bi-whatsapp';
  if (key.includes('nuvem') || key.includes('cloud') || key.includes('storage')) return 'bi-cloud-arrow-up-fill';
  if (key.includes('senha') || key.includes('firewall') || key.includes('seguranca')) return 'bi-shield-lock-fill';
  if (key.includes('bi') || key.includes('indicador') || key.includes('dashboard')) return 'bi-graph-up-arrow';
  if (key.includes('loja') || key.includes('unidade')) return 'bi-building-fill';
  if (key.includes('curso') || key.includes('treinamento') || key.includes('academia')) return 'bi-mortarboard-fill';
  if (key.includes('impressora')) return 'bi-printer-fill';
  return 'bi-grid-1x2-fill';
}

function prettifyIconName(icon) {
  return safeTrim(icon)
    .replace(/^bi-/, '')
    .replace(/-/g, ' ')
    .replace(/\b\w/g, (letter) => letter.toUpperCase());
}

function sanitizeIcon(value) {
  const icon = safeTrim(value).replace(/\s+/g, '');
  return /^bi-[a-z0-9-]+$/.test(icon) ? icon : '';
}

function initializeMaintenance() {
  setMaintenanceState(isMaintenanceUnlocked());

  if (maintenanceLoginForm) {
    maintenanceLoginForm.addEventListener('submit', (event) => {
      event.preventDefault();
      const isValid = maintenancePassword && maintenancePassword.value === MAINTENANCE_PASSWORD;

      if (!isValid) {
        if (maintenanceLoginError) maintenanceLoginError.classList.remove('d-none');
        if (maintenancePassword) {
          maintenancePassword.value = '';
          maintenancePassword.focus();
        }
        return;
      }

      if (maintenanceLoginError) maintenanceLoginError.classList.add('d-none');
      setMaintenanceSession(true);
      setMaintenanceState(true);
      setSectionOpen(maintenanceSection, true);
      resetMaintenanceForm();
    });
  }

  if (maintenanceForm) {
    maintenanceForm.addEventListener('submit', handleMaintenanceSubmit);
  }

  if (maintenanceImage) {
    maintenanceImage.addEventListener('input', updateMaintenanceIconPreview);
  }

  if (maintenanceIconPickerOpen) {
    maintenanceIconPickerOpen.addEventListener('click', openMaintenanceIconPicker);
  }

  if (maintenanceIconSearch) {
    maintenanceIconSearch.addEventListener('input', () => renderMaintenanceIconGrid(maintenanceIconSearch.value));
  }

  if (maintenanceIconGrid) {
    maintenanceIconGrid.addEventListener('click', (event) => {
      const button = event.target.closest('[data-icon-option]');
      if (!button) return;
      chooseMaintenanceIcon(button.dataset.iconOption);
    });
  }

  maintenanceIconPickerClose.forEach((button) => {
    button.addEventListener('click', closeMaintenanceIconPicker);
  });

  if (maintenanceSearch) {
    maintenanceSearch.addEventListener('input', renderMaintenanceList);
  }

  if (maintenanceListSection) {
    maintenanceListSection.addEventListener('change', renderMaintenanceList);
  }

  if (maintenanceNewShortcut) {
    maintenanceNewShortcut.addEventListener('click', resetMaintenanceForm);
  }

  if (maintenanceExportShortcuts) {
    maintenanceExportShortcuts.addEventListener('click', exportShortcutsBackup);
  }

  if (maintenanceImportShortcuts && maintenanceImportFile) {
    maintenanceImportShortcuts.addEventListener('click', () => maintenanceImportFile.click());
    maintenanceImportFile.addEventListener('change', importShortcutsBackup);
  }

  if (maintenanceCancelEdit) {
    maintenanceCancelEdit.addEventListener('click', resetMaintenanceForm);
  }

  if (maintenanceResetDefaults) {
    maintenanceResetDefaults.addEventListener('click', restoreDefaults);
  }

  if (noticeMaintenanceForm) {
    noticeMaintenanceForm.addEventListener('submit', saveNoticeConfig);
  }

  if (noticeImageFile) {
    noticeImageFile.addEventListener('change', () => {
      const file = noticeImageFile.files ? noticeImageFile.files[0] : null;
      if (!file) {
        if (noticePreviewImage) noticePreviewImage.src = noticeConfig.image;
        setNoticeStatus('', '');
        return;
      }

      if (file.size > NOTICE_FILE_LIMIT) {
        setNoticeStatus('Imagem muito grande. Use um arquivo de até 8 MB.', 'error');
        noticeImageFile.value = '';
        if (noticePreviewImage) noticePreviewImage.src = noticeConfig.image;
        return;
      }

      if (noticePreviewImage) noticePreviewImage.src = URL.createObjectURL(file);
      setNoticeStatus('Prévia carregada. Clique em salvar aviso para gravar.', '');
    });
  }

  if (noticeResetPreview) {
    noticeResetPreview.addEventListener('click', () => {
      if (noticeImageFile) noticeImageFile.value = '';
      applyNoticeConfig(noticeConfig, { cacheBust: true });
      setNoticeStatus('Configuração recarregada.', 'ok');
    });
  }

  renderMaintenanceIconGrid('');
  updateMaintenanceIconPreview();
  applyNoticeConfig(noticeConfig);
}

if (searchInput) {
  searchInput.addEventListener('input', scheduleApplyFilters);
  searchInput.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
      searchInput.value = '';
      window.clearTimeout(filterTimer);
      applyFilters();
    }
  });
}

if (clearButton) {
  clearButton.addEventListener('click', () => {
    if (!searchInput) return;
    searchInput.value = '';
    searchInput.focus();
    applyFilters();
  });
}

if (focusSearchButton) {
  focusSearchButton.addEventListener('click', focusSearch);
}

filterButtons.forEach((button) => {
  button.addEventListener('click', (event) => {
    activeSection = button.dataset.filterSection;
    filterButtons.forEach((item) => item.classList.toggle('active', item === button));
    applyFilters();
    closeMobileMenu();

    if (activeSection === 'all') {
      event.preventDefault();
      const toolbar = document.getElementById('atalhos');
      if (toolbar) toolbar.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
});

document.querySelectorAll('a[href="#manutencao"]').forEach((link) => {
  link.addEventListener('click', () => {
    closeMobileMenu();
    window.setTimeout(() => setSectionOpen(maintenanceSection, true), 120);
  });
});

document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape' && maintenanceIconPicker && !maintenanceIconPicker.classList.contains('d-none')) {
    closeMaintenanceIconPicker();
    return;
  }

  const isSearchShortcut = (event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k';
  if (!isSearchShortcut) return;
  event.preventDefault();
  focusSearch();
});

async function initializePage() {
  defaultShortcuts = extractDefaultShortcuts();
  favoriteShortcuts = readFavoriteShortcuts();
  recentShortcuts = readRecentShortcuts();
  initializeCompactMode();
  const cached = readShortcutCache();
  if (cached) {
    shortcuts = cached.shortcuts.map(sanitizeShortcut).filter((shortcut) => shortcut.title && shortcut.section);
    if (!shortcuts.length) {
      shortcuts = defaultShortcuts.map(cloneShortcut);
    }
    applyNoticeConfig(cached.notice);
    setShortcutLoadStatus('Última lista salva carregada. Atualizando em segundo plano...', '');
  } else {
    shortcuts = defaultShortcuts.map(cloneShortcut);
  }

  initializeSectionToggles();
  restoreOpenSections();
  initializeMaintenance();
  renderShortcuts();

  shortcuts = await loadShortcuts();
  renderShortcuts();
  openNoticeAutomatically();
}

initializePage();
