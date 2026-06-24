(function () {
  function initGerencialTable() {
    if (!window.jQuery || !jQuery.fn || !jQuery.fn.dataTable) return;

    var table = jQuery('#GridViewcontagerencial');
    if (!table.length || table.data('gerencial-ready')) return;

    table.data('gerencial-ready', true);
    table.dataTable({
      bJQueryUI: false,
      bPaginate: true,
      bFilter: true,
      bInfo: true,
      bAutoWidth: false,
      iDisplayLength: 10,
      sPaginationType: 'full_numbers',
      aaSorting: [[0, 'asc']],
      oLanguage: {
        sProcessing: 'Processando...',
        sLengthMenu: 'Mostrar _MENU_ registros',
        sZeroRecords: 'Nenhum registro encontrado',
        sInfo: 'Mostrando _START_ a _END_ de _TOTAL_ registros',
        sInfoEmpty: 'Mostrando 0 registros',
        sInfoFiltered: '(filtrado de _MAX_ registros)',
        sSearch: 'Filtrar',
        oPaginate: {
          sFirst: 'Primeiro',
          sPrevious: 'Anterior',
          sNext: 'Próximo',
          sLast: 'Último'
        }
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initGerencialTable);
  } else {
    initGerencialTable();
  }
})();
