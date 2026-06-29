(function () {
  function normalize(text) {
    text = String(text || '').toLowerCase();
    if (text.normalize) {
      text = text.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }
    return text.replace(/\s+/g, ' ').trim();
  }

  function parseNumber(text) {
    var clean = String(text || '')
      .replace(/\s/g, '')
      .replace(/R\$/gi, '')
      .replace(/%/g, '')
      .replace(/\./g, '')
      .replace(',', '.');
    var number = parseFloat(clean);
    return isNaN(number) ? null : number;
  }

  function initSalesTable() {
    var table = document.querySelector('.sales-table');
    if (!table || !table.tBodies || !table.tBodies.length) return;

    var tbody = table.tBodies[0];
    var allRows = Array.prototype.slice.call(tbody.rows);
    var headers = Array.prototype.slice.call(table.querySelectorAll('th'));
    var search = document.getElementById('salesTableSearch');
    var pageSize = document.getElementById('salesPageSize');
    var counter = document.getElementById('salesTableCounter');
    var prev = document.getElementById('salesPrevPage');
    var next = document.getElementById('salesNextPage');
    var pageInfo = document.getElementById('salesPageInfo');
    var currentPage = 1;
    var sortIndex = -1;
    var sortDirection = 1;

    var dataRows = allRows.filter(function (row) {
      return row.cells && row.cells.length === headers.length;
    });

    dataRows.forEach(function (row) {
      row.setAttribute('data-search', normalize(row.textContent));
    });

    headers.forEach(function (header, index) {
      header.setAttribute('role', 'button');
      header.setAttribute('tabindex', '0');
      header.setAttribute('title', 'Ordenar por ' + header.textContent.trim());
      header.addEventListener('click', function () {
        sortBy(index);
      });
      header.addEventListener('keydown', function (event) {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          sortBy(index);
        }
      });
    });

    function filteredRows() {
      var query = normalize(search ? search.value : '');
      return dataRows.filter(function (row) {
        return !query || String(row.getAttribute('data-search') || '').indexOf(query) >= 0;
      });
    }

    function sortBy(index) {
      if (sortIndex === index) {
        sortDirection = sortDirection * -1;
      } else {
        sortIndex = index;
        sortDirection = 1;
      }

      dataRows.sort(function (a, b) {
        var aText = a.cells[index] ? a.cells[index].textContent.trim() : '';
        var bText = b.cells[index] ? b.cells[index].textContent.trim() : '';
        var aNumber = parseNumber(aText);
        var bNumber = parseNumber(bText);
        var result;

        if (aNumber !== null && bNumber !== null) {
          result = aNumber - bNumber;
        } else {
          result = aText.localeCompare(bText, 'pt-BR', { numeric: true, sensitivity: 'base' });
        }

        return result * sortDirection;
      });

      dataRows.forEach(function (row) {
        tbody.appendChild(row);
      });

      headers.forEach(function (header, i) {
        header.removeAttribute('data-sort');
        if (i === sortIndex) {
          header.setAttribute('data-sort', sortDirection > 0 ? 'asc' : 'desc');
        }
      });

      currentPage = 1;
      render();
    }

    function selectedPageSize() {
      if (!pageSize || pageSize.value === 'all') return Number.MAX_SAFE_INTEGER;
      var size = parseInt(pageSize.value, 10);
      return isNaN(size) || size <= 0 ? 25 : size;
    }

    function render() {
      var rows = filteredRows();
      var size = selectedPageSize();
      var totalPages = Math.max(1, Math.ceil(rows.length / size));
      if (currentPage > totalPages) currentPage = totalPages;

      var start = (currentPage - 1) * size;
      var end = start + size;

      dataRows.forEach(function (row) {
        row.hidden = true;
      });

      rows.slice(start, end).forEach(function (row) {
        row.hidden = false;
      });

      if (counter) {
        counter.textContent = rows.length + ' venda(s) exibida(s) de ' + dataRows.length;
      }
      if (pageInfo) {
        pageInfo.textContent = rows.length ? ('Pagina ' + currentPage + ' de ' + totalPages) : 'Sem resultados';
      }
      if (prev) {
        prev.disabled = currentPage <= 1 || rows.length === 0;
      }
      if (next) {
        next.disabled = currentPage >= totalPages || rows.length === 0;
      }
    }

    if (search) {
      search.addEventListener('input', function () {
        currentPage = 1;
        render();
      });
    }

    if (pageSize) {
      pageSize.addEventListener('change', function () {
        currentPage = 1;
        render();
      });
    }

    if (prev) {
      prev.addEventListener('click', function () {
        currentPage = Math.max(1, currentPage - 1);
        render();
      });
    }

    if (next) {
      next.addEventListener('click', function () {
        currentPage += 1;
        render();
      });
    }

    render();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initSalesTable);
  } else {
    initSalesTable();
  }
})();
