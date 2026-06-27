(function () {
  var systems = {
    '2': { title: 'ADM / Financeiro', subtitle: 'Administrativo, financeiro e recibos.' },
    '4': { title: 'Ve\u00edculos', subtitle: 'Centrais e rotinas comerciais.' },
    '7': { title: 'Pe\u00e7as e acess\u00f3rios', subtitle: 'Opera\u00e7\u00f5es de pe\u00e7as e acess\u00f3rios.' },
    '9': { title: 'Assist. t\u00e9cnica', subtitle: 'Atendimento t\u00e9cnico e p\u00f3s-venda.' },
    '10': { title: 'Lanternagem', subtitle: 'Acompanhamento de lanternagem.' },
    '12': { title: 'Entrega', subtitle: 'Entregas e autoriza\u00e7\u00e3o de sa\u00edda.' },
    '13': { title: 'Jur\u00eddico', subtitle: 'Documentos e consultas jur\u00eddicas.' },
    '14': { title: 'CRM', subtitle: 'Relacionamento e prospec\u00e7\u00e3o.' },
    '15': { title: 'Despachante', subtitle: 'Documenta\u00e7\u00e3o e processos externos.' },
    '16': { title: 'DP', subtitle: 'Rotinas de departamento pessoal.' },
    '17': { title: 'Tecnologia', subtitle: 'Suporte, usu\u00e1rios e sistemas.' },
    '18': { title: 'Diretoria', subtitle: 'Pain\u00e9is e indicadores gerenciais.' }
  };

  function normalize(text) {
    text = String(text || '').toLowerCase();
    if (text.normalize) {
      text = text.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }
    return text;
  }

  function enhanceCards() {
    var cards = Array.prototype.slice.call(document.querySelectorAll('.app-card'));
    cards.forEach(function (card) {
      var id = card.getAttribute('data-system-id') || '';
      var info = systems[id] || { title: 'Sistema ' + id, subtitle: 'Aplicativo interno.' };
      var title = card.querySelector('[data-app-title]');
      var subtitle = card.querySelector('[data-app-subtitle]');
      var action = card.querySelector('.app-card-action');
      var img = card.querySelector('img');
      var url = String(card.getAttribute('data-system-url') || card.getAttribute('href') || '').trim();

      if (title) title.textContent = info.title;
      if (subtitle) subtitle.textContent = info.subtitle;
      if (img) img.alt = info.title;
      card.setAttribute('data-search', normalize(info.title + ' ' + info.subtitle + ' ' + id));

      if (!url || url === '#') {
        card.className += card.className.indexOf('is-disabled') >= 0 ? '' : ' is-disabled';
        if (action) action.textContent = 'Sem acesso';
      }
    });
  }

  function bindSearch() {
    var input = document.getElementById('appSearch');
    var empty = document.getElementById('appEmptyState');
    if (!input) return;

    input.addEventListener('input', function () {
      var query = normalize(input.value);
      var visible = 0;
      Array.prototype.slice.call(document.querySelectorAll('.app-card')).forEach(function (card) {
        var match = !query || String(card.getAttribute('data-search') || '').indexOf(query) >= 0;
        card.className = String(card.className || '').replace(/\bis-hidden\b/g, '').replace(/\s+/g, ' ').trim();
        if (!match) {
          card.className += ' is-hidden';
        } else {
          visible++;
        }
      });
      if (empty) empty.hidden = visible > 0;
    });
  }

  function init() {
    enhanceCards();
    bindSearch();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
