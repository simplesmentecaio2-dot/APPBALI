const SHORTCUTS_API = 'manutencao-links.ashx?AspxAutoDetectCookieSupport=1';
const SESSION_KEY = 'centralBaliMaintenanceUnlocked';
const MAINTENANCE_PASSWORD = '@bali2025';
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
const emptyState = document.getElementById('emptyState');
const filterButtons = Array.from(document.querySelectorAll('[data-filter-section]'));
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
const maintenanceIconPickerOpen = document.getElementById('maintenanceIconPickerOpen');
const maintenanceIconPicker = document.getElementById('maintenanceIconPicker');
const maintenanceIconSearch = document.getElementById('maintenanceIconSearch');
const maintenanceIconGrid = document.getElementById('maintenanceIconGrid');
const maintenanceIconCount = document.getElementById('maintenanceIconCount');
const maintenanceIconPreview = document.getElementById('maintenanceIconPreview');
const maintenanceIconPickerClose = Array.from(document.querySelectorAll('[data-maintenance-icon-close]'));
const maintenanceList = document.getElementById('maintenanceList');
const maintenanceListSummary = document.getElementById('maintenanceListSummary');
const maintenanceSearch = document.getElementById('maintenanceSearch');
const maintenanceListSection = document.getElementById('maintenanceListSection');
const maintenanceNewShortcut = document.getElementById('maintenanceNewShortcut');
const maintenanceResetDefaults = document.getElementById('maintenanceResetDefaults');
const maintenanceCancelEdit = document.getElementById('maintenanceCancelEdit');

let activeSection = 'all';
let sections = [];
let allSections = [];
let cards = [];
let defaultShortcuts = [];
let shortcuts = [];

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
    const response = await fetch(`${SHORTCUTS_API}&v=${Date.now()}`, {
      cache: 'no-store',
      credentials: 'same-origin'
    });

    if (!response.ok) return defaultShortcuts.map(cloneShortcut);

    const payload = await response.json();
    const source = Array.isArray(payload) ? payload : payload.shortcuts;

    if (!Array.isArray(source) || !source.length) {
      return defaultShortcuts.map(cloneShortcut);
    }

    return source.map(sanitizeShortcut).filter((shortcut) => shortcut.title && shortcut.section);
  } catch (error) {
    return defaultShortcuts.map(cloneShortcut);
  }
}

async function saveShortcuts() {
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

    return true;
  } catch (error) {
    alert('Nao foi possivel salvar os atalhos no servidor.');
    return false;
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

function setSectionOpen(section, isOpen) {
  if (!section) return;
  const heading = section.querySelector('.section-heading');
  section.classList.toggle('is-open', isOpen);
  if (heading) {
    heading.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
  }
}

function toggleSection(section) {
  setSectionOpen(section, !section.classList.contains('is-open'));
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
    image.addEventListener('error', () => {
      image.classList.add('d-none');
      fallback.classList.remove('d-none');
    });
    icon.appendChild(image);
  }

  icon.appendChild(fallback);

  const content = document.createElement('div');
  content.className = 'shortcut-content';

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
  link.target = '_blank';
  link.rel = 'noopener noreferrer';
  link.setAttribute('aria-label', `Abrir ${shortcut.title}`);

  const label = document.createElement('span');
  label.textContent = shortcut.url ? 'Acessar' : 'Sem link';
  const linkIcon = document.createElement('i');
  linkIcon.className = 'bi bi-box-arrow-up-right';

  link.appendChild(label);
  link.appendChild(linkIcon);

  article.appendChild(icon);
  article.appendChild(content);
  article.appendChild(link);

  return article;
}

function updateDashboardTotals() {
  const total = shortcuts.length;
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

function renderShortcuts() {
  sections = getShortcutSections();

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
    const haystack = normalizeText(`${card.dataset.title} ${card.dataset.badge} ${card.dataset.section} ${card.textContent}`);
    const matchesText = !term || haystack.includes(term);
    const matchesSection = activeSection === 'all' || card.dataset.section === activeSection;
    const visible = matchesText && matchesSection;

    card.classList.toggle('is-hidden', !visible);
    if (visible) visibleCards += 1;
  });

  sections.forEach((section) => {
    const hasVisibleCard = Boolean(section.querySelector('.shortcut-card:not(.is-hidden)'));
    section.classList.toggle('is-hidden', !hasVisibleCard);
  });

  if (emptyState) {
    emptyState.classList.toggle('d-none', visibleCards !== 0);
  }

  updateSectionCounts();
  setClearButtonState();
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

    heading.dataset.toggleReady = 'true';
    heading.setAttribute('role', 'button');
    heading.setAttribute('tabindex', '0');
    heading.setAttribute('aria-expanded', 'false');

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
  maintenanceTitle.focus();
}

function getMaintenanceFilters() {
  return {
    term: normalizeText(maintenanceSearch ? maintenanceSearch.value : ''),
    section: maintenanceListSection ? maintenanceListSection.value : 'all'
  };
}

function renderMaintenanceList() {
  if (!maintenanceList || !isMaintenanceUnlocked()) return;

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
    category.textContent = SECTION_CONFIG[shortcut.section].label;

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

  maintenanceForm.scrollIntoView({ behavior: 'smooth', block: 'center' });
  maintenanceTitle.focus();
}

async function deleteShortcut(id) {
  const shortcut = shortcuts.find((item) => item.id === id);
  if (!shortcut) return;

  const confirmed = window.confirm(`Excluir o atalho "${shortcut.title}"?`);
  if (!confirmed) return;

  const previousShortcuts = shortcuts.map(cloneShortcut);
  shortcuts = shortcuts.filter((item) => item.id !== id);
  const saved = await saveShortcuts();
  if (!saved) {
    shortcuts = previousShortcuts;
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

  const saved = await saveShortcuts();
  if (!saved) {
    shortcuts = previousShortcuts;
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
    url: safeTrim(maintenanceUrl.value),
    image: safeTrim(maintenanceImage.value),
    icon: sanitizeIcon(maintenanceIcon ? maintenanceIcon.value : '') || inferIcon(`${maintenanceTitle.value} ${maintenanceBadge.value} ${maintenanceUrl.value}`)
  };

  if (!shortcut.title || !shortcut.url || !SECTION_CONFIG[shortcut.section]) {
    alert('Preencha nome, link e categoria do atalho.');
    return;
  }

  const previousShortcuts = shortcuts.map(cloneShortcut);
  const index = shortcuts.findIndex((item) => item.id === id);
  if (index >= 0) {
    shortcuts[index] = shortcut;
  } else {
    shortcuts.push(shortcut);
  }

  const saved = await saveShortcuts();
  if (!saved) {
    shortcuts = previousShortcuts;
    renderShortcuts();
    return;
  }

  renderShortcuts();
  resetMaintenanceForm();

  const targetSection = document.querySelector(`.shortcut-section[data-section-block="${shortcut.section}"]`);
  setSectionOpen(targetSection, true);
  setSectionOpen(maintenanceSection, true);
}

async function restoreDefaults() {
  const confirmed = window.confirm('Restaurar a lista padrao de atalhos? As alteracoes salvas no servidor serao substituidas.');
  if (!confirmed) return;

  const previousShortcuts = shortcuts.map(cloneShortcut);
  shortcuts = defaultShortcuts.map(cloneShortcut);
  const saved = await saveShortcuts();
  if (!saved) {
    shortcuts = previousShortcuts;
  }

  renderShortcuts();
  resetMaintenanceForm();
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

  if (maintenanceCancelEdit) {
    maintenanceCancelEdit.addEventListener('click', resetMaintenanceForm);
  }

  if (maintenanceResetDefaults) {
    maintenanceResetDefaults.addEventListener('click', restoreDefaults);
  }

  renderMaintenanceIconGrid('');
  updateMaintenanceIconPreview();
}

if (searchInput) {
  searchInput.addEventListener('input', applyFilters);
  searchInput.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
      searchInput.value = '';
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
  shortcuts = defaultShortcuts.map(cloneShortcut);
  initializeSectionToggles();
  initializeMaintenance();
  renderShortcuts();

  shortcuts = await loadShortcuts();
  renderShortcuts();
}

initializePage();
