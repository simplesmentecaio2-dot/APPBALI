(function () {
  var iconBasePath = '../img/central-icons/';

  var rules = [
    { key: 'contract', terms: ['contrato', 'compra e venda'] },
    { key: 'guide', terms: ['guia do comprador', 'guia'] },
    { key: 'receipt', terms: ['recibo', 'desconto'] },
    { key: 'commission', terms: ['comissao', 'comissionamento'] },
    { key: 'delivery', terms: ['entrega', 'veiculo entregue'] },
    { key: 'test-drive', terms: ['test drive', 'experiencia'] },
    { key: 'phone', terms: ['telefone', 'contatos', 'financeiras'] },
    { key: 'accounts', terms: ['contas', 'bancarias', 'financeiro'] },
    { key: 'store', terms: ['lojas', 'unidades', 'informacoes das lojas'] },
    { key: 'ranking', terms: ['ranking'] },
    { key: 'prospecting', terms: ['prospeccao', 'vendas'] },
    { key: 'workflow', terms: ['workflow', 'processos'] },
    { key: 'bi', terms: ['bi'] },
    { key: 'direct-sale', terms: ['pedido de vd', 'venda direta', 'vd'] },
    { key: 'domicile', terms: ['domicilio', 'cadastro'] },
    { key: 'communication', terms: ['comunicacao', 'documento'] },
    { key: 'performance', terms: ['desempenho', 'performance'] }
  ];

  function normalize(value) {
    return (value || '')
      .toString()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .trim();
  }

  function inferIcon(card) {
    var explicit = normalize(card.getAttribute('data-icon'));
    if (explicit) {
      return explicit;
    }

    var text = normalize(card.textContent + ' ' + (card.getAttribute('href') || ''));

    for (var i = 0; i < rules.length; i++) {
      for (var j = 0; j < rules[i].terms.length; j++) {
        if (text.indexOf(normalize(rules[i].terms[j])) >= 0) {
          return rules[i].key;
        }
      }
    }

    return 'default';
  }

  function inferIconFromText(text) {
    var fakeCard = {
      getAttribute: function () { return ''; },
      textContent: text || ''
    };
    return inferIcon(fakeCard);
  }

  function applyIcon(card) {
    var iconBox = card.querySelector('.central-link-icon');
    if (!iconBox) {
      return;
    }

    var iconKey = inferIcon(card);
    var icon = document.createElement('img');
    icon.src = iconBasePath + iconKey + '.svg';
    icon.alt = '';
    icon.loading = 'lazy';
    icon.className = 'central-auto-icon-img';
    icon.setAttribute('aria-hidden', 'true');
    icon.addEventListener('error', function () {
      if (iconKey !== 'default') {
        icon.src = iconBasePath + 'default.svg';
      }
    });

    iconBox.innerHTML = '';
    iconBox.appendChild(icon);
    card.setAttribute('data-icon-resolved', iconKey);
  }

  function initializeIcons() {
    var cards = document.querySelectorAll('.central-link-card');
    for (var i = 0; i < cards.length; i++) {
      applyIcon(cards[i]);
    }
  }

  window.centralLinksApplyIcons = initializeIcons;
  window.centralLinksInferIcon = inferIconFromText;

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeIcons);
  } else {
    initializeIcons();
  }
})();
