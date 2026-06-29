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

  function parseDateInput(value) {
    if (!value) return null;
    var parts = String(value).split('-');
    if (parts.length !== 3) return null;
    var date = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
    return isNaN(date.getTime()) ? null : date;
  }

  function initPeriodGuard() {
    var form = document.getElementById('form1');
    var start = document.getElementById('txtDataInicial');
    var end = document.getElementById('txtDataFinal');
    if (!form || !start || !end) return;

    form.addEventListener('submit', function (event) {
      var startDate = parseDateInput(start.value);
      var endDate = parseDateInput(end.value);
      if (!startDate || !endDate) return;

      var days = Math.round((endDate.getTime() - startDate.getTime()) / 86400000) + 1;
      if (days <= 0) {
        event.preventDefault();
        window.alert('A data final precisa ser maior ou igual \u00e0 data inicial.');
        return;
      }

      if (days > 32) {
        event.preventDefault();
        window.alert('Selecione um per\u00edodo de at\u00e9 32 dias para manter o BI r\u00e1pido.');
      }
    });
  }

  function initSalesTable() {
    var table = document.querySelector('.sales-table');
    if (!table || !table.tBodies || !table.tBodies.length) return;

    var tbody = table.tBodies[0];
    var allRows = Array.prototype.slice.call(tbody.rows);
    var headers = Array.prototype.slice.call(table.querySelectorAll('th'));
    var search = document.getElementById('salesTableSearch');
    var storeFilter = document.getElementById('salesStoreFilter');
    var typeFilter = document.getElementById('salesTypeFilter');
    var marginFilter = document.getElementById('salesMarginFilter');
    var positiveOnly = document.getElementById('salesPositiveOnly');
    var pageSize = document.getElementById('salesPageSize');
    var clearPrefs = document.getElementById('salesClearTablePrefs');
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
      row.setAttribute('data-store', normalize(row.cells[3] ? row.cells[3].textContent : ''));
      row.setAttribute('data-type', normalize(row.cells[6] ? row.cells[6].textContent : ''));
      row.setAttribute('data-quantity', String(parseNumber(row.cells[7] ? row.cells[7].textContent : '') || 0));
      row.setAttribute('data-margin', String(parseNumber(row.cells[9] ? row.cells[9].textContent : '') || 0));
    });

    headers.forEach(function (header, index) {
      if (index === headers.length - 1) return;
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

    populateFilter(storeFilter, dataRows, 'data-store', 3);
    populateFilter(typeFilter, dataRows, 'data-type', 6);
    restorePreferences();

    function filteredRows() {
      var query = normalize(search ? search.value : '');
      var store = normalize(storeFilter ? storeFilter.value : '');
      var type = normalize(typeFilter ? typeFilter.value : '');
      var margin = marginFilter ? marginFilter.value : '';
      var onlyPositive = !!(positiveOnly && positiveOnly.checked);
      return dataRows.filter(function (row) {
        var rowMargin = parseNumber(row.getAttribute('data-margin')) || 0;
        var matchQuery = !query || String(row.getAttribute('data-search') || '').indexOf(query) >= 0;
        var matchStore = !store || row.getAttribute('data-store') === store;
        var matchType = !type || row.getAttribute('data-type') === type;
        var matchMargin =
          !margin ||
          (margin === 'low' && rowMargin > 0 && rowMargin < 8) ||
          (margin === 'ok' && rowMargin >= 8) ||
          (margin === 'high' && rowMargin >= 15);
        var matchPositive = !onlyPositive || parseNumber(row.getAttribute('data-quantity')) >= 0;
        return matchQuery && matchStore && matchType && matchMargin && matchPositive;
      });
    }

    function preferenceKey() {
      return 'grupo-bali-minhas-vendas-table';
    }

    function savePreferences() {
      if (!window.localStorage) return;
      var prefs = {
        store: storeFilter ? storeFilter.value : '',
        type: typeFilter ? typeFilter.value : '',
        margin: marginFilter ? marginFilter.value : '',
        positiveOnly: !!(positiveOnly && positiveOnly.checked),
        pageSize: pageSize ? pageSize.value : '25'
      };
      try {
        window.localStorage.setItem(preferenceKey(), JSON.stringify(prefs));
      } catch (ignore) {}
    }

    function restorePreferences() {
      if (!window.localStorage) return;
      try {
        var raw = window.localStorage.getItem(preferenceKey());
        if (!raw) return;
        var prefs = JSON.parse(raw);
        setControlValue(storeFilter, prefs.store || '');
        setControlValue(typeFilter, prefs.type || '');
        setControlValue(marginFilter, prefs.margin || '');
        setControlValue(pageSize, prefs.pageSize || '25');
        if (positiveOnly) positiveOnly.checked = !!prefs.positiveOnly;
      } catch (ignore) {}
    }

    function setControlValue(control, value) {
      if (!control) return;
      var exists = Array.prototype.some.call(control.options || [], function (option) {
        return option.value === value;
      });
      if (exists) control.value = value;
    }

    function populateFilter(select, rows, attr, cellIndex) {
      if (!select) return;

      var values = {};
      rows.forEach(function (row) {
        var key = row.getAttribute(attr) || '';
        var label = row.cells[cellIndex] ? row.cells[cellIndex].textContent.trim() : '';
        if (key && label && !values[key]) {
          values[key] = label;
        }
      });

      Object.keys(values).sort(function (a, b) {
        return values[a].localeCompare(values[b], 'pt-BR', { sensitivity: 'base' });
      }).forEach(function (key) {
        var option = document.createElement('option');
        option.value = key;
        option.textContent = values[key];
        select.appendChild(option);
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
        savePreferences();
        render();
      });
    }

    [storeFilter, typeFilter, marginFilter, positiveOnly].forEach(function (control) {
      if (!control) return;
      control.addEventListener('change', function () {
        currentPage = 1;
        savePreferences();
        render();
      });
    });

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

    if (clearPrefs) {
      clearPrefs.addEventListener('click', function () {
        if (window.localStorage) {
          try {
            window.localStorage.removeItem(preferenceKey());
          } catch (ignore) {}
        }
        setControlValue(storeFilter, '');
        setControlValue(typeFilter, '');
        setControlValue(marginFilter, '');
        setControlValue(pageSize, '25');
        if (positiveOnly) positiveOnly.checked = false;
        if (search) search.value = '';
        currentPage = 1;
        render();
      });
    }

    render();
  }

  function initSalesActions() {
    var modal = document.getElementById('salesDetailModal');
    var body = document.getElementById('salesDetailBody');
    var title = document.getElementById('salesDetailTitle');

    function field(label, value) {
      value = String(value || '').trim() || '-';
      return '<div><span>' + label + '</span><strong>' + escapeHtml(value) + '</strong></div>';
    }

    function escapeHtml(value) {
      return String(value || '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
    }

    function closeModal() {
      if (modal) modal.hidden = true;
    }

    function openModal(button) {
      if (!modal || !body || !title) return;
      var data = button.dataset || {};
      title.textContent = data.cliente || 'Venda selecionada';
      body.innerHTML =
        field('Cliente', data.cliente) +
        field('CPF/CNPJ', data.cpf) +
        field('Telefone', data.telefone) +
        field('E-mail', data.email) +
        field('Modelo', [data.marca, data.modelo].filter(Boolean).join(' ')) +
        field('Cor', data.cor) +
        field('Chassi', data.chassi) +
        field('Placa', data.placa) +
        field('Nota fiscal', data.nota) +
        field('Pedido', data.pedido) +
        field('Loja', data.loja) +
        field('Valor', data.valor);
      modal.hidden = false;
    }

    function copyContact(button) {
      var data = button.dataset || {};
      var text = [
        data.cliente || '',
        data.telefone ? 'Telefone: ' + data.telefone : '',
        data.email ? 'E-mail: ' + data.email : ''
      ].filter(Boolean).join('\n');

      if (!text) return;

      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(function () {
          button.textContent = 'Copiado';
          window.setTimeout(function () { button.textContent = 'Copiar contato'; }, 1400);
        });
      } else {
        window.prompt('Copie o contato:', text);
      }
    }

    function registerPrint() {
      try {
        var data = new FormData();
        data.append('acao', 'impressao-pdf');
        data.append('marca', document.body.className || '');
        data.append('url', window.location.href);
        if (navigator.sendBeacon) {
          navigator.sendBeacon('/minhas-vendas-auditoria.ashx', data);
        } else {
          fetch('/minhas-vendas-auditoria.ashx', {
            method: 'POST',
            body: data,
            credentials: 'same-origin',
            keepalive: true
          });
        }
      } catch (ignore) {}
    }

    document.addEventListener('click', function (event) {
      var detail = event.target.closest('[data-sales-detail]');
      if (detail) {
        openModal(detail);
        return;
      }

      var copy = event.target.closest('[data-copy-contact]');
      if (copy) {
        copyContact(copy);
        return;
      }

      if (event.target.closest('[data-sales-print]')) {
        registerPrint();
        window.print();
        return;
      }

      if (event.target.closest('[data-close-sales-modal]')) {
        closeModal();
      }
    });

    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape') {
        closeModal();
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      initSalesTable();
      initSalesActions();
      initPeriodGuard();
    });
  } else {
    initSalesTable();
    initSalesActions();
    initPeriodGuard();
  }
})();
