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

  function painelImpressao() {
    return bySuffix('pnlImpressao');
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

  function mostrarCarregando() {
    var overlay = document.getElementById('baliUtilityLoading');
    if (!overlay) {
      overlay = document.createElement('div');
      overlay.id = 'baliUtilityLoading';
      overlay.className = 'bali-utility-loading';
      overlay.innerHTML = '<div><span></span><strong>Gerando recibo</strong><small>Consultando os dados do pedido.</small></div>';
      document.body.appendChild(overlay);
    }
    overlay.classList.add('is-visible');
  }

  function validarConsulta() {
    var pedido = pedidoField();
    var loja = lojaField();
    var mensagens = [];

    if (pedido && !pedido.value.trim()) mensagens.push('Informe o pedido.');
    if (loja && !loja.value.trim()) mensagens.push('Informe o c\u00f3digo da loja.');

    if (mensagens.length) {
      toast(mensagens.join(' '), 'error');
      if (pedido && !pedido.value.trim()) pedido.focus();
      else if (loja) loja.focus();
      return false;
    }

    mostrarCarregando();
    return true;
  }

  function decorarCampos() {
    var pedido = pedidoField();
    var loja = lojaField();

    if (pedido) {
      pedido.setAttribute('autocomplete', 'off');
      pedido.setAttribute('inputmode', 'numeric');
      if (!pedido.getAttribute('placeholder')) pedido.setAttribute('placeholder', 'Ex.: 12345');
    }

    if (loja) {
      loja.setAttribute('autocomplete', 'off');
      loja.setAttribute('inputmode', 'numeric');
      if (!loja.getAttribute('placeholder')) loja.setAttribute('placeholder', 'Ex.: 01');
    }
  }

  function decorarCardConsulta() {
    var fieldset = document.querySelector('.bali-utility-page fieldset');
    if (!fieldset || fieldset.getAttribute('data-bali-receipt-card') === '1') return;

    fieldset.setAttribute('data-bali-receipt-card', '1');
    fieldset.classList.add('bali-receipt-card');
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
    imagem.parentNode.insertBefore(barra, imagem);
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
    if (!html.trim()) {
      toast('Gere o recibo antes de imprimir.', 'error');
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
        printWindow.focus();
        printWindow.print();
      } finally {
        setTimeout(function () { printWindow.close(); }, 250);
      }
    });
  }

  function vincularGerar() {
    var botao = bySuffix('btnGerar');
    if (!botao || botao.getAttribute('data-bali-generate-bound') === '1') return;
    botao.setAttribute('data-bali-generate-bound', '1');

    botao.addEventListener('click', function (event) {
      if (!validarConsulta()) {
        event.preventDefault();
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
  }

  ready(function () {
    aplicarMelhorias();

    if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
      Sys.WebForms.PageRequestManager.getInstance().add_endRequest(aplicarMelhorias);
    }
  });
})();
