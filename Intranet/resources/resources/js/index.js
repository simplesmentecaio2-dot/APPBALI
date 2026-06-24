const searchInput = document.getElementById('shortcutSearch');
const clearButton = document.getElementById('clearSearch');
const focusSearchButton = document.getElementById('focusSearch');
const cards = Array.from(document.querySelectorAll('.shortcut-card'));
const sections = Array.from(document.querySelectorAll('.shortcut-section'));
const emptyState = document.getElementById('emptyState');
const filterButtons = Array.from(document.querySelectorAll('[data-filter-section]'));
let activeSection = 'all';

function normalizeText(value) {
  return (value || '')
    .toString()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim();
}

function applyFilters() {
  const term = normalizeText(searchInput.value);
  let visibleCards = 0;

  cards.forEach((card) => {
    const haystack = normalizeText(`${card.dataset.title} ${card.dataset.badge} ${card.dataset.section}`);
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

  emptyState.classList.toggle('d-none', visibleCards !== 0);
}

searchInput.addEventListener('input', applyFilters);
clearButton.addEventListener('click', () => {
  searchInput.value = '';
  searchInput.focus();
  applyFilters();
});
focusSearchButton.addEventListener('click', () => {
  document.getElementById('atalhos').scrollIntoView({ behavior: 'smooth', block: 'start' });
  setTimeout(() => searchInput.focus(), 250);
});
filterButtons.forEach((button) => {
  button.addEventListener('click', (event) => {
    activeSection = button.dataset.filterSection;
    filterButtons.forEach((item) => item.classList.toggle('active', item === button));
    applyFilters();
    if (activeSection === 'all') {
      event.preventDefault();
      document.getElementById('atalhos').scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
});

window.addEventListener('load', () => {
  const modalElement = document.getElementById('noticeModal');
  if (!modalElement || typeof bootstrap === 'undefined') return;
  const modal = new bootstrap.Modal(modalElement);
  window.setTimeout(() => modal.show(), 1200);
});
