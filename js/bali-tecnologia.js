(function () {
  function normalize(text) {
    text = String(text || '').toLowerCase();
    if (text.normalize) {
      text = text.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }
    return text.replace(/\s+/g, ' ').trim();
  }

  function bindSearch(inputId, selector, emptyId) {
    var input = document.getElementById(inputId);
    if (!input) return;

    var empty = document.getElementById(emptyId);
    input.addEventListener('input', function () {
      var query = normalize(input.value);
      var visible = 0;
      Array.prototype.slice.call(document.querySelectorAll(selector)).forEach(function (item) {
        var text = normalize(item.getAttribute('data-search') || item.textContent || '');
        var match = !query || text.indexOf(query) >= 0;
        item.className = String(item.className || '').replace(/\btech-filter-hidden\b/g, '').replace(/\s+/g, ' ').trim();
        if (!match) {
          item.className += ' tech-filter-hidden';
        } else {
          visible++;
        }
      });
      if (empty) empty.hidden = visible > 0;
    });
  }

  function enhanceTables() {
    Array.prototype.slice.call(document.querySelectorAll('.tech-gridview')).forEach(function (table) {
      table.setAttribute('cellspacing', '0');
    });
  }

  function init() {
    bindSearch('techSearchCards', '.tech-card', 'techEmptyCards');
    bindSearch('techSearchSystems', '.tech-system-row', 'techEmptySystems');
    bindSearch('techSearchUsers', '.tech-gridview tr:not(:first-child)', 'techEmptyUsers');
    bindSearch('techSearchFiles', '.tech-file', 'techEmptyFiles');
    enhanceTables();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
