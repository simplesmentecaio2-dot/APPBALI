(function () {
  'use strict';

  function ready(callback) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', callback);
    } else {
      callback();
    }
  }

  function bySuffix(suffix) {
    var items = document.querySelectorAll('[id$="' + suffix + '"]');
    return items.length ? items[0] : null;
  }

  function pedidoField() {
    return bySuffix('txtPedido') || bySuffix('txtpedido');
  }

  function lojaField() {
    return bySuffix('txtLoja');
  }

  function gerarButton() {
    return bySuffix('btnGerar');
  }

  function painelImpressao() {
    return bySuffix('pnlImpressao');
  }

  function marcaPagina() {
    if (document.body.classList.contains('utility-jeep')) return 'Jeep';
    if (document.body.classList.contains('utility-byd')) return 'BYD';
    return 'Fiat';
  }

  function tipoDocumento() {
    var titulo = (document.title || '').toLowerCase();
    return titulo.indexOf('entrega') >= 0 ? 'Entrega de veiculo' : 'Recibo de desconto';
  }

  function somenteDigitos(valor) {
    return (valor || '').replace(/\D/g, '');
  }

  function textoDoElemento(el) {
    return el ? (el.textContent || el.innerText || '').replace(/\s+/g, ' ').trim() : '';
  }

  function textoPorSufixos(sufixos) {
    for (var i = 0; i < sufixos.length; i++) {
      var el = bySuffix(sufixos[i]);
      var texto = textoDoElemento(el);
      if (texto) return texto;
    }
    return '';
  }

  function clientePreview() {
    return textoPorSufixos(['lblCliente', 'lblClienteEntreg']);
  }

  function veiculoPreview() {
    return textoPorSufixos(['lblVeiculo', 'lblVe\u00edculo', 'lblVeiculoEntreg']);
  }

  function previewGerada() {
    return !!(clientePreview() || veiculoPreview());
  }

  function mensagemAmigavel(message) {
    var texto = String(message || '').replace(/\s+/g, ' ').trim();
    var lower = texto.toLowerCase();

    if (!texto) return 'N\u00e3o foi poss\u00edvel concluir a opera\u00e7\u00e3o agora.';
    if (lower.indexOf('n\u00e3o existe recibo') >= 0) return 'Pedido n\u00e3o encontrado para essa loja. Confira o n\u00famero do pedido e o c\u00f3digo da loja.';
    if (lower.indexOf('n\u00e3o existe autoriza') >= 0) return 'Autoriza\u00e7\u00e3o de entrega n\u00e3o encontrada para esse pedido e loja.';

    return texto;
  }

  function toast(message, type) {
    var root = document.querySelector('.bali-utility-toast-root');
    if (!root) {
      root = document.createElement('div');
      root.className = 'bali-utility-toast-root';
      root.setAttribute('aria-live', 'polite');
      document.body.appendChild(root);
    }

    var item = document.createElement('div');
    item.className = 'bali-utility-toast ' + (type === 'error' ? 'is-error' : 'is-info');
    item.innerHTML = '<strong></strong><span></span><button type="button" aria-label="Fechar">&times;</button>';
    item.querySelector('strong').textContent = type === 'error' ? 'Aten\u00e7\u00e3o' : 'Recibo';
    item.querySelector('span').textContent = message;
    item.querySelector('button').addEventListener('click', function () {
      item.classList.add('is-leaving');
      setTimeout(function () { item.remove(); }, 180);
    });
    root.appendChild(item);
    setTimeout(function () {
      if (!item.parentNode) return;
      item.classList.add('is-leaving');
      setTimeout(function () { item.remove(); }, 180);
    }, type === 'error' ? 6500 : 4200);
  }

  window.baliUtilityFeedback = function (message, type) {
    toast(mensagemAmigavel(message), type || 'info');
    esconderCarregando();
  };

  var alertOriginal = window.alert;
  window.alert = function (message) {
    if (document.body && document.body.classList && document.body.classList.contains('bali-utility-page')) {
      window.baliUtilityFeedback(message, 'error');
      return;
    }

    alertOriginal(message);
  };

  function mostrarCarregando() {
    var overlay = document.getElementById('baliUtilityLoading');
    if (!overlay) {
      overlay = document.createElement('div');
      overlay.id = 'baliUtilityLoading';
      overlay.className = 'bali-utility-loading';
      overlay.innerHTML = '<div><span></span><strong>Consultando pedido</strong><small>Aguarde enquanto buscamos os dados.</small></div>';
      document.body.appendChild(overlay);
    }
    overlay.classList.add('is-visible');
  }

  function esconderCarregando() {
    var overlay = document.getElementById('baliUtilityLoading');
    if (overlay) overlay.classList.remove('is-visible');
  }

  function validarConsulta() {
    var pedido = pedidoField();
    var loja = lojaField();
    var mensagens = [];
    var pedidoValor = pedido ? pedido.value.trim() : '';
    var lojaValor = loja ? loja.value.trim() : '';

    if (pedido) {
      if (!pedidoValor) mensagens.push('Informe o pedido.');
      else if (pedidoValor !== somenteDigitos(pedidoValor)) mensagens.push('O pedido deve conter apenas n\u00fameros.');
      else if (pedidoValor.length > 12) mensagens.push('O pedido parece longo demais. Confira o n\u00famero informado.');
    }

    if (loja) {
      if (!lojaValor) mensagens.push('Informe o c\u00f3digo da loja.');
      else if (lojaValor !== somenteDigitos(lojaValor)) mensagens.push('O c\u00f3digo da loja deve conter apenas n\u00fameros.');
      else if (lojaValor.length > 3) mensagens.push('O c\u00f3digo da loja deve ter at\u00e9 3 d\u00edgitos.');
    }

    if (mensagens.length) {
      toast(mensagens.join(' '), 'error');
      if (pedido && (!pedidoValor || pedidoValor !== somenteDigitos(pedidoValor))) pedido.focus();
      else if (loja) loja.focus();
      return false;
    }

    document.body.classList.remove('bali-preview-ready');
    mostrarCarregando();
    return true;
  }

  function decorarCampos() {
    var pedido = pedidoField();
    var loja = lojaField();

    if (pedido) {
      pedido.setAttribute('autocomplete', 'off');
      pedido.setAttribute('inputmode', 'numeric');
      pedido.setAttribute('pattern', '[0-9]*');
      if (!pedido.getAttribute('placeholder')) pedido.setAttribute('placeholder', 'Ex.: 12345');
      if (pedido.getAttribute('data-bali-digits-bound') !== '1') {
        pedido.setAttribute('data-bali-digits-bound', '1');
        pedido.addEventListener('input', function () {
          var limpo = somenteDigitos(pedido.value).slice(0, 12);
          if (pedido.value !== limpo) pedido.value = limpo;
        });
      }
    }

    if (loja) {
      loja.setAttribute('autocomplete', 'off');
      loja.setAttribute('inputmode', 'numeric');
      loja.setAttribute('pattern', '[0-9]*');
      if (!loja.getAttribute('placeholder')) loja.setAttribute('placeholder', 'Ex.: 01');
      if (loja.getAttribute('data-bali-digits-bound') !== '1') {
        loja.setAttribute('data-bali-digits-bound', '1');
        loja.addEventListener('input', function () {
          var limpo = somenteDigitos(loja.value).slice(0, 3);
          if (loja.value !== limpo) loja.value = limpo;
        });
      }
    }
  }

  function decorarCardConsulta() {
    var fieldset = document.querySelector('.bali-utility-page fieldset');
    if (!fieldset || fieldset.getAttribute('data-bali-receipt-card') === '1') return;

    fieldset.setAttribute('data-bali-receipt-card', '1');
    fieldset.classList.add('bali-receipt-card');

    var pedido = pedidoField();
    var loja = lojaField();
    var gerar = gerarButton();
    var painel = painelImpressao();
    if (!pedido || !loja || !gerar || fieldset.querySelector('.bali-query-row')) return;

    var row = document.createElement('div');
    row.className = 'bali-query-row';

    function grupo(rotulo, controle) {
      var item = document.createElement('label');
      item.className = 'bali-query-field';
      item.innerHTML = '<span></span>';
      item.querySelector('span').textContent = rotulo;
      item.appendChild(controle);
      return item;
    }

    var actions = document.createElement('div');
    actions.className = 'bali-query-actions';
    actions.appendChild(gerar);

    row.appendChild(grupo('Pedido', pedido));
    row.appendChild(grupo('C\u00f3d. Loja', loja));
    row.appendChild(actions);

    var legend = fieldset.querySelector('legend');
    fieldset.insertBefore(row, legend && legend.nextSibling ? legend.nextSibling : fieldset.firstChild);

    var nodes = Array.prototype.slice.call(fieldset.childNodes);
    nodes.forEach(function (node) {
      if (node === row || node === painel) return;
      if (node.nodeType === 3 && /pedido|c[o\u00f3]d/i.test(node.nodeValue || '')) node.parentNode.removeChild(node);
    });
  }

  function decorarBotaoImpressao() {
    var imagem = document.querySelector('img[onclick*="imprimePanel"]');
    if (!imagem || imagem.getAttribute('data-bali-print-decorated') === '1') return;

    imagem.setAttribute('data-bali-print-decorated', '1');
    imagem.style.display = 'none';

    var barra = document.createElement('div');
    barra.className = 'bali-print-toolbar';

    var botao = document.createElement('button');
    botao.type = 'button';
    botao.className = 'bali-print-action';
    botao.innerHTML = '<img src="' + imagem.getAttribute('src') + '" alt="" aria-hidden="true"><span>Imprimir</span>';
    botao.addEventListener('click', function () {
      if (typeof window.imprimePanel === 'function') window.imprimePanel();
    });

    barra.appendChild(botao);

    var actions = document.querySelector('.bali-query-actions');
    if (actions) actions.appendChild(barra);
    else imagem.parentNode.insertBefore(barra, imagem);
  }

  function logEvento(acao) {
    var pedido = pedidoField();
    var loja = lojaField();
    var dados = {
      acao: acao,
      pedido: pedido ? pedido.value.trim() : '',
      loja: loja ? loja.value.trim() : '',
      marca: marcaPagina(),
      tipo: tipoDocumento(),
      cliente: clientePreview(),
      veiculo: veiculoPreview(),
      pagina: window.location.pathname
    };

    var body = Object.keys(dados).map(function (key) {
      return encodeURIComponent(key) + '=' + encodeURIComponent(dados[key] || '');
    }).join('&');

    if (navigator.sendBeacon) {
      try {
        var blob = new Blob([body], { type: 'application/x-www-form-urlencoded;charset=UTF-8' });
        navigator.sendBeacon('/recibo-log.ashx', blob);
        return;
      } catch (ignore) {}
    }

    if (window.fetch) {
      fetch('/recibo-log.ashx', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
        credentials: 'same-origin',
        body: body
      }).catch(function () {});
    }
  }

  function atualizarEstadoPrevia() {
    var pronta = previewGerada();
    document.body.classList.toggle('bali-preview-ready', pronta);

    var printButton = document.querySelector('.bali-print-action');
    if (printButton) {
      printButton.disabled = !pronta;
      printButton.setAttribute('aria-disabled', pronta ? 'false' : 'true');
      printButton.title = pronta ? 'Imprimir documento gerado' : 'Gere a pr\u00e9via antes de imprimir';
    }

    if (pronta) {
      esconderCarregando();

      var pedido = pedidoField();
      var loja = lojaField();
      var chave = [
        'recibo-gerado',
        window.location.pathname,
        pedido ? pedido.value.trim() : '',
        loja ? loja.value.trim() : '',
        clientePreview(),
        veiculoPreview()
      ].join('|');

      if (window.sessionStorage && sessionStorage.getItem(chave) !== '1') {
        sessionStorage.setItem(chave, '1');
        logEvento('gerado');
        toast('Pr\u00e9via pronta para impress\u00e3o.', 'info');
      }
    }
  }

  function esperarImagens(printWindow, callback) {
    var imagens = printWindow.document.images || [];
    var pendentes = 0;
    var finalizado = false;

    function terminar() {
      if (finalizado) return;
      finalizado = true;
      callback();
    }

    for (var i = 0; i < imagens.length; i++) {
      if (!imagens[i].complete) {
        pendentes++;
        imagens[i].onload = imagens[i].onerror = function () {
          pendentes--;
          if (pendentes <= 0) terminar();
        };
      }
    }

    if (pendentes === 0) terminar();
    else setTimeout(terminar, 1200);
  }

  function imprimirPainel() {
    var painel = painelImpressao();
    if (!painel) {
      toast('N\u00e3o encontrei a \u00e1rea de impress\u00e3o nesta tela.', 'error');
      return;
    }

    var html = painel.innerHTML || '';
    if (!html.trim() || !previewGerada()) {
      toast('Gere a pr\u00e9via antes de imprimir.', 'error');
      return;
    }

    var printWindow = window.open('formPadrao.aspx', 'ReciboBaliPrint', 'left=50000,top=50000,width=0,height=0');
    if (!printWindow) {
      toast('O navegador bloqueou a janela de impress\u00e3o. Permita pop-ups para continuar.', 'error');
      return;
    }

    printWindow.document.open();
    printWindow.document.write(html);
    printWindow.document.close();

    esperarImagens(printWindow, function () {
      try {
        logEvento('impressao');
        printWindow.focus();
        printWindow.print();
      } finally {
        setTimeout(function () { printWindow.close(); }, 250);
      }
    });
  }

  function vincularGerar() {
    var botao = gerarButton();
    if (!botao || botao.getAttribute('data-bali-generate-bound') === '1') return;
    botao.setAttribute('data-bali-generate-bound', '1');

    botao.addEventListener('click', function (event) {
      if (!validarConsulta()) {
        event.preventDefault();
        if (event.stopImmediatePropagation) event.stopImmediatePropagation();
        event.stopPropagation();
        return false;
      }
      return true;
    }, true);
  }

  function aplicarMelhorias() {
    if (!document.body || !document.body.classList.contains('bali-utility-page')) return;
    decorarCampos();
    decorarCardConsulta();
    decorarBotaoImpressao();
    vincularGerar();
    window.imprimePanel = imprimirPainel;
    window.aguarde = mostrarCarregando;
    atualizarEstadoPrevia();
  }

  ready(function () {
    aplicarMelhorias();

    if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
      Sys.WebForms.PageRequestManager.getInstance().add_endRequest(aplicarMelhorias);
    }
  });
})();
