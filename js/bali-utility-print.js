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

  function limparButton() {
    return bySuffix('btnLimpar');
  }

  function painelImpressao() {
    return bySuffix('pnlImpressao');
  }

  var previewZoom = 1;

  function marcaPagina() {
    if (document.body.classList.contains('utility-jeep')) return 'Jeep';
    if (document.body.classList.contains('utility-byd')) return 'BYD';
    return 'Fiat';
  }

  function tipoDocumento() {
    var titulo = (document.title || '').toLowerCase();
    if (titulo.indexOf('polimento') >= 0) return 'Autorizacao de polimento';
    return titulo.indexOf('entrega') >= 0 ? 'Entrega de veiculo' : 'Recibo de desconto';
  }

  function ehEntrega() {
    return !!(document.body && document.body.classList && document.body.classList.contains('delivery-receipt-page'));
  }

  function somenteDigitos(valor) {
    return (valor || '').replace(/\D/g, '');
  }

  function escaparHtml(valor) {
    return String(valor || '').replace(/[&<>"']/g, function (char) {
      return {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;'
      }[char];
    });
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

  function historicoKey() {
    return 'bali-utility-history:' + window.location.pathname;
  }

  function lerHistoricoLocal() {
    if (!window.localStorage) return [];
    try {
      var itens = JSON.parse(localStorage.getItem(historicoKey()) || '[]');
      return Array.isArray(itens) ? itens : [];
    } catch (ignore) {
      return [];
    }
  }

  function salvarHistoricoLocal(itens) {
    if (!window.localStorage) return;
    try {
      localStorage.setItem(historicoKey(), JSON.stringify(itens.slice(0, 6)));
    } catch (ignore) {}
  }

  function clientePreview() {
    return textoPorSufixos(['lblCliente', 'lblClienteEntreg']);
  }

  function veiculoPreview() {
    return textoPorSufixos(['lblVeiculo', 'lblVe\u00edculo', 'lblVeiculoEntreg']);
  }

  function dadosPreview() {
    return {
      cliente: clientePreview(),
      veiculo: veiculoPreview(),
      chassi: textoPorSufixos(['lblChassi', 'lblChassiEntreg']),
      placa: textoPorSufixos(['lblPlaca']),
      valor: textoPorSufixos(['lblValor']),
      vendedor: textoPorSufixos(['lblVendedor', 'lblVendedorEntreg']),
      cor: textoPorSufixos(['lblCor']),
      nota: textoPorSufixos(['lblNota'])
    };
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
    var texto = mensagemAmigavel(message);
    toast(texto, type || 'info');
    if ((type || '').toLowerCase() === 'error') {
      logEvento('erro', texto);
    }
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

  function setGerarProcessando(processando) {
    var botao = gerarButton();
    if (!botao) return;

    if (!botao.getAttribute('data-bali-original-text')) {
      botao.setAttribute('data-bali-original-text', botao.value || botao.textContent || 'Gerar');
    }

    if (processando) {
      botao.classList.add('is-processing');
      botao.setAttribute('aria-disabled', 'true');
      botao.value = 'Consultando...';
      setTimeout(function () { botao.disabled = true; }, 0);
    } else {
      botao.classList.remove('is-processing');
      botao.removeAttribute('aria-disabled');
      botao.disabled = false;
      botao.value = botao.getAttribute('data-bali-original-text') || 'Gerar';
    }
  }

  function validarConsulta() {
    normalizarCamposConsulta();

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
      window.baliUtilityFeedback(mensagens.join(' '), 'error');
      if (pedido && (!pedidoValor || pedidoValor !== somenteDigitos(pedidoValor))) pedido.focus();
      else if (loja) loja.focus();
      return false;
    }

    if (previewGerada() && document.body.getAttribute('data-bali-preview-key') === consultaKeyAtual()) {
      window.baliUtilityFeedback('A prévia desse pedido e loja já está carregada. Confira os dados ou imprima o documento.', 'info');
      return false;
    }

    document.body.classList.remove('bali-preview-ready');
    setGerarProcessando(true);
    mostrarCarregando();
    return true;
  }

  function invalidarPrevia() {
    document.body.classList.remove('bali-preview-ready');
    document.body.classList.remove('bali-print-confirmed');
    document.body.removeAttribute('data-bali-preview-key');
    atualizarResumoPrevia(false);

    var confirmButton = document.querySelector('.bali-confirm-print-action');
    if (confirmButton) {
      confirmButton.disabled = true;
      confirmButton.setAttribute('aria-disabled', 'true');
      confirmButton.textContent = 'Conferi os dados';
    }

    var printButton = document.querySelector('.bali-print-action');
    if (printButton) {
      printButton.disabled = true;
      printButton.setAttribute('aria-disabled', 'true');
      printButton.title = 'Gere a prévia antes de imprimir';
    }
  }

  function normalizarCamposConsulta() {
    var pedido = pedidoField();
    var loja = lojaField();

    if (pedido) pedido.value = somenteDigitos(pedido.value).slice(0, 12);
    if (loja) {
      var lojaLimpa = somenteDigitos(loja.value).slice(0, 3);
      if (lojaLimpa.length === 1) lojaLimpa = '0' + lojaLimpa;
      loja.value = lojaLimpa;
    }
  }

  function consultaKeyAtual() {
    var pedido = pedidoField();
    var loja = lojaField();
    return [
      window.location.pathname,
      pedido ? pedido.value.trim() : '',
      loja ? loja.value.trim() : ''
    ].join('|');
  }

  function parametroConsulta(nome) {
    var query = window.location.search || '';
    if (!query) return '';

    if (window.URLSearchParams) {
      return new URLSearchParams(query).get(nome) || '';
    }

    var partes = query.replace(/^\?/, '').split('&');
    for (var i = 0; i < partes.length; i++) {
      var par = partes[i].split('=');
      if (decodeURIComponent(par[0] || '') === nome) {
        return decodeURIComponent((par[1] || '').replace(/\+/g, ' '));
      }
    }
    return '';
  }

  function preencherConsultaPorUrl() {
    if (document.documentElement.getAttribute('data-bali-query-prefilled') === '1') return;
    document.documentElement.setAttribute('data-bali-query-prefilled', '1');

    var pedidoParam = somenteDigitos(parametroConsulta('pedido')).slice(0, 12);
    var lojaParam = somenteDigitos(parametroConsulta('loja')).slice(0, 3);
    if (!pedidoParam && !lojaParam) return;

    var pedido = pedidoField();
    var loja = lojaField();
    if (pedido && pedidoParam) pedido.value = pedidoParam;
    if (loja && lojaParam) loja.value = lojaParam;
    normalizarCamposConsulta();
    invalidarPrevia();
    toast('Consulta preenchida pela auditoria. Clique em Gerar para carregar a prévia.', 'info');
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
          invalidarPrevia();
        });
        pedido.addEventListener('blur', normalizarCamposConsulta);
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
          invalidarPrevia();
        });
        loja.addEventListener('blur', normalizarCamposConsulta);
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
    var limpar = limparButton();
    var voltar = fieldset.querySelector('.delivery-inline-back');
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
    if (voltar) actions.appendChild(voltar);
    actions.appendChild(gerar);
    if (limpar) actions.appendChild(limpar);

    row.appendChild(grupo('Pedido', pedido));
    row.appendChild(grupo('C\u00f3d. Loja', loja));
    row.appendChild(actions);

    var legend = fieldset.querySelector('legend');
    fieldset.insertBefore(row, legend && legend.nextSibling ? legend.nextSibling : fieldset.firstChild);

    if (ehEntrega()) {
      var hero = document.createElement('div');
      hero.className = 'delivery-screen-hero';
      hero.innerHTML = '<small>Autorização interna</small><strong>Entrega de veículo</strong><span>Consulte o pedido, confira cliente, chassi e pagamentos, depois libere a impressão.</span>';
      fieldset.insertBefore(hero, row);
    }

    var state = document.createElement('div');
    state.className = 'bali-preview-state';
    state.innerHTML = '<strong>Prévia ainda não gerada</strong><span>Informe pedido e loja, clique em Gerar e confira os dados antes de imprimir.</span>';
    fieldset.insertBefore(state, painel || row.nextSibling);

    if (ehEntrega()) {
      var warning = document.createElement('div');
      warning.className = 'delivery-print-warning';
      warning.innerHTML = '<div><strong>Conferência obrigatória</strong><span>Imprima somente após conferir cliente, chassi e pagamentos.</span></div>';
      fieldset.insertBefore(warning, painel || state.nextSibling);
    }

    var history = document.createElement('div');
    history.className = 'bali-local-history';
    history.innerHTML = '<div class="bali-local-history-head"><strong>Últimas consultas</strong><button type="button" class="bali-history-clear">Limpar</button></div><div class="bali-local-history-list"></div>';
    fieldset.insertBefore(history, painel || state.nextSibling);

    var summary = document.createElement('div');
    summary.className = 'bali-preview-summary';
    summary.innerHTML = '<div class="bali-preview-summary-grid"></div><div class="bali-preview-summary-actions"><button type="button" class="bali-copy-action">Copiar dados</button></div>';
    fieldset.insertBefore(summary, painel || state.nextSibling);

    var tools = document.createElement('div');
    tools.className = 'bali-preview-tools';
    if (ehEntrega()) {
      tools.innerHTML = '<strong>Visualização</strong><div><button type="button" data-zoom="fit">A4 inteiro</button><button type="button" data-zoom="compact">Compacto</button><button type="button" data-zoom="reset">Normal</button><span>100%</span><button type="button" data-zoom="-0.1">-</button><button type="button" data-zoom="0.1">+</button></div>';
    } else {
      tools.innerHTML = '<strong>Visualização</strong><div><button type="button" data-zoom="-0.1">-</button><span>100%</span><button type="button" data-zoom="0.1">+</button><button type="button" data-zoom="reset">Resetar</button></div>';
    }
    fieldset.insertBefore(tools, painel || summary.nextSibling);

    var nodes = Array.prototype.slice.call(fieldset.childNodes);
    nodes.forEach(function (node) {
      if (node === row || node === painel) return;
      if (node.nodeType === 3 && /pedido|c[o\u00f3]d/i.test(node.nodeValue || '')) node.parentNode.removeChild(node);
    });

    vincularHistoricoLocal();
    renderizarHistoricoLocal();
  }

  function registrarHistoricoLocal(acao) {
    var pedido = pedidoField();
    var loja = lojaField();
    if (!pedido || !loja || !pedido.value || !loja.value) return;

    var dados = dadosPreview();
    var item = {
      pedido: pedido.value.trim(),
      loja: loja.value.trim(),
      cliente: dados.cliente,
      veiculo: dados.veiculo,
      acao: acao || 'Gerado',
      data: new Date().toLocaleString('pt-BR', { dateStyle: 'short', timeStyle: 'short' })
    };

    var itens = lerHistoricoLocal().filter(function (atual) {
      return !(atual.pedido === item.pedido && atual.loja === item.loja);
    });
    itens.unshift(item);
    salvarHistoricoLocal(itens);
    renderizarHistoricoLocal();
  }

  function renderizarHistoricoLocal() {
    var root = document.querySelector('.bali-local-history');
    var list = document.querySelector('.bali-local-history-list');
    if (!root || !list) return;

    var itens = lerHistoricoLocal();
    root.style.display = itens.length ? 'grid' : 'none';
    if (!itens.length) {
      list.innerHTML = '';
      return;
    }

    list.innerHTML = itens.map(function (item, index) {
      var titulo = (item.cliente || item.veiculo || 'Pedido ' + item.pedido);
      var detalhe = ['Pedido ' + item.pedido, 'Loja ' + item.loja, item.data].filter(Boolean).join(' · ');
      return '<button type="button" data-history-index="' + index + '"><strong>' + escaparHtml(titulo) + '</strong><span>' + escaparHtml(detalhe) + '</span></button>';
    }).join('');
  }

  function vincularHistoricoLocal() {
    var root = document.querySelector('.bali-local-history');
    if (!root || root.getAttribute('data-bali-history-bound') === '1') return;
    root.setAttribute('data-bali-history-bound', '1');

    root.addEventListener('click', function (event) {
      var limpar = event.target.closest ? event.target.closest('.bali-history-clear') : null;
      if (limpar) {
        salvarHistoricoLocal([]);
        renderizarHistoricoLocal();
        toast('Histórico local limpo.', 'info');
        return;
      }

      var botao = event.target.closest ? event.target.closest('button[data-history-index]') : null;
      if (!botao) return;

      var item = lerHistoricoLocal()[parseInt(botao.getAttribute('data-history-index'), 10)];
      if (!item) return;

      var pedido = pedidoField();
      var loja = lojaField();
      if (pedido) pedido.value = item.pedido || '';
      if (loja) loja.value = item.loja || '';
      normalizarCamposConsulta();
      invalidarPrevia();
      toast('Consulta carregada. Clique em Gerar para atualizar a prévia.', 'info');
    });
  }

  function decorarMenuAuditoria() {
    var menu = document.getElementById('menu');
    if (!menu || menu.querySelector('.bali-audit-link')) return;

    var backButton = menu.querySelector('.bali-back-button');
    var actions = menu.querySelector('.bali-menu-actions');
    if (!actions) {
      actions = document.createElement('div');
      actions.className = 'bali-menu-actions';
      if (backButton) {
        menu.insertBefore(actions, backButton);
        actions.appendChild(backButton);
      } else {
        menu.insertBefore(actions, menu.firstChild);
      }
    }

    var link = document.createElement('a');
    link.className = 'bali-audit-link';
    link.href = '/recibo-auditoria.aspx';
    link.textContent = 'Auditoria';
    actions.appendChild(link);
  }

  function decorarBotaoImpressao() {
    var imagem = document.querySelector('img[onclick*="imprimePanel"]');
    if (!imagem || imagem.getAttribute('data-bali-print-decorated') === '1') return;

    imagem.setAttribute('data-bali-print-decorated', '1');
    imagem.style.display = 'none';

    var barra = document.createElement('div');
    barra.className = 'bali-print-toolbar';

    if (ehEntrega()) {
      var confirmar = document.createElement('button');
      confirmar.type = 'button';
      confirmar.className = 'bali-confirm-print-action';
      confirmar.disabled = true;
      confirmar.setAttribute('aria-disabled', 'true');
      confirmar.textContent = 'Conferi os dados';
      confirmar.addEventListener('click', function () {
        if (!previewGerada()) {
          toast('Gere a prévia antes de confirmar a conferência.', 'error');
          return;
        }

        document.body.classList.add('bali-print-confirmed');
        confirmar.disabled = false;
        confirmar.setAttribute('aria-disabled', 'false');
        confirmar.textContent = 'Dados conferidos';
        atualizarEstadoPrevia();
        toast('Conferência registrada nesta tela. Impressão liberada.', 'info');
      });
      barra.appendChild(confirmar);
    }

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

  function logEvento(acao, mensagem) {
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
      pagina: window.location.pathname,
      mensagem: mensagem || ''
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

  function textoResumoParaCopiar() {
    var pedido = pedidoField();
    var loja = lojaField();
    var dados = dadosPreview();
    var linhas = [
      'Tipo: ' + tipoDocumento(),
      'Marca: ' + marcaPagina(),
      'Pedido: ' + (pedido ? pedido.value.trim() : ''),
      'Loja: ' + (loja ? loja.value.trim() : ''),
      'Cliente: ' + dados.cliente,
      'Ve\u00edculo: ' + dados.veiculo,
      'Chassi: ' + dados.chassi,
      'Placa: ' + dados.placa,
      'Valor: ' + dados.valor,
      'Vendedor: ' + dados.vendedor
    ];

    return linhas.filter(function (linha) {
      return !/:\s*$/.test(linha);
    }).join('\n');
  }

  function copiarResumo() {
    var texto = textoResumoParaCopiar();
    if (!texto) {
      toast('Gere a pr\u00e9via antes de copiar os dados.', 'error');
      return;
    }

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(texto).then(function () {
        toast('Dados copiados para a \u00e1rea de transfer\u00eancia.', 'info');
      }).catch(function () {
        toast('N\u00e3o foi poss\u00edvel copiar automaticamente.', 'error');
      });
      return;
    }

    var temp = document.createElement('textarea');
    temp.value = texto;
    temp.style.position = 'fixed';
    temp.style.left = '-9999px';
    document.body.appendChild(temp);
    temp.select();
    try {
      document.execCommand('copy');
      toast('Dados copiados para a \u00e1rea de transfer\u00eancia.', 'info');
    } catch (ignore) {
      toast('N\u00e3o foi poss\u00edvel copiar automaticamente.', 'error');
    }
    temp.remove();
  }

  function aplicarZoomPrevia() {
    var painel = painelImpressao();
    var label = document.querySelector('.bali-preview-tools span');
    if (!painel) return;

    painel.style.setProperty('--bali-preview-zoom', previewZoom.toFixed(2));
    if (label) label.textContent = Math.round(previewZoom * 100) + '%';
  }

  function ajustarZoomA4Inteiro() {
    var painel = painelImpressao();
    var folha = painel ? painel.querySelector('.delivery-print') : null;
    if (!painel || !folha) {
      previewZoom = 0.82;
      return;
    }

    var larguraFolha = folha.offsetWidth || folha.scrollWidth || 760;
    var larguraDisponivel = Math.max(260, painel.clientWidth - 44);
    previewZoom = Math.max(0.48, Math.min(1, larguraDisponivel / larguraFolha));
  }

  function vincularFerramentasPrevia() {
    var tools = document.querySelector('.bali-preview-tools');
    if (!tools || tools.getAttribute('data-bali-tools-bound') === '1') return;
    tools.setAttribute('data-bali-tools-bound', '1');

    tools.addEventListener('click', function (event) {
      var button = event.target.closest ? event.target.closest('button[data-zoom]') : null;
      if (!button) return;

      var acao = button.getAttribute('data-zoom');
      if (acao === 'fit') ajustarZoomA4Inteiro();
      else if (acao === 'compact') previewZoom = 0.82;
      else if (acao === 'reset') previewZoom = 1;
      else previewZoom = Math.max(0.7, Math.min(1.2, previewZoom + parseFloat(acao)));

      aplicarZoomPrevia();
    });
  }

  function atualizarResumoPrevia(pronta) {
    var state = document.querySelector('.bali-preview-state');
    var summary = document.querySelector('.bali-preview-summary');
    var tools = document.querySelector('.bali-preview-tools');
    var grid = document.querySelector('.bali-preview-summary-grid');
    var copyButton = document.querySelector('.bali-copy-action');

    if (state) state.style.display = pronta ? 'none' : 'grid';
    if (summary) summary.style.display = pronta ? 'grid' : 'none';
    if (tools) tools.style.display = pronta ? 'flex' : 'none';
    vincularFerramentasPrevia();
    aplicarZoomPrevia();
    if (copyButton && copyButton.getAttribute('data-bali-copy-bound') !== '1') {
      copyButton.setAttribute('data-bali-copy-bound', '1');
      copyButton.addEventListener('click', copiarResumo);
    }

    if (!pronta || !grid) return;

    var dados = dadosPreview();
    var itens = [
      ['Cliente', dados.cliente],
      ['Ve\u00edculo', dados.veiculo],
      ['Chassi', dados.chassi],
      ['Placa', dados.placa],
      ['Valor', dados.valor],
      ['Vendedor', dados.vendedor],
      ['Cor', dados.cor],
      ['Nota', dados.nota]
    ];

    grid.innerHTML = itens.filter(function (item) {
      return item[1];
    }).slice(0, 6).map(function (item) {
      return '<article><small>' + escaparHtml(item[0]) + '</small><strong>' + escaparHtml(item[1]) + '</strong></article>';
    }).join('');
  }

  function atualizarEstadoPrevia() {
    var pronta = previewGerada();
    document.body.classList.toggle('bali-preview-ready', pronta);
    setGerarProcessando(false);
    atualizarResumoPrevia(pronta);

    var confirmButton = document.querySelector('.bali-confirm-print-action');
    var confirmado = document.body.classList.contains('bali-print-confirmed');
    if (confirmButton) {
      confirmButton.disabled = !pronta;
      confirmButton.setAttribute('aria-disabled', pronta ? 'false' : 'true');
      if (!pronta) {
        confirmButton.textContent = 'Conferi os dados';
      } else if (confirmado) {
        confirmButton.textContent = 'Dados conferidos';
      }
      confirmButton.title = pronta ? 'Confirme que cliente, chassi e pagamentos foram conferidos' : 'Gere a prévia antes de conferir';
    }

    var printButton = document.querySelector('.bali-print-action');
    if (printButton) {
      var podeImprimir = pronta && (!ehEntrega() || confirmado);
      printButton.disabled = !podeImprimir;
      printButton.setAttribute('aria-disabled', podeImprimir ? 'false' : 'true');
      printButton.title = !pronta ? 'Gere a prévia antes de imprimir' : (podeImprimir ? 'Imprimir documento gerado' : 'Confirme a conferência dos dados antes de imprimir');
    }

    if (pronta) {
      esconderCarregando();

      var pedido = pedidoField();
      var loja = lojaField();
      var chave = [
        'recibo-gerado',
        consultaKeyAtual(),
        clientePreview(),
        veiculoPreview()
      ].join('|');
      document.body.setAttribute('data-bali-preview-key', consultaKeyAtual());

      if (window.sessionStorage && sessionStorage.getItem(chave) !== '1') {
        sessionStorage.setItem(chave, '1');
        logEvento('gerado');
        registrarHistoricoLocal('Gerado');
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

    if (ehEntrega() && !document.body.classList.contains('bali-print-confirmed')) {
      toast('Confirme que cliente, chassi e pagamentos foram conferidos antes de imprimir.', 'error');
      return;
    }

    var printWindow = window.open('formPadrao.aspx', 'ReciboBaliPrint', 'left=50000,top=50000,width=0,height=0');
    if (!printWindow) {
      toast('O navegador bloqueou a janela de impress\u00e3o. Permita pop-ups para continuar.', 'error');
      return;
    }

    var isEntrega = html.indexOf('delivery-print') >= 0;
    var printHtml = html;
    if (isEntrega) {
      printHtml = '<!doctype html><html><head><meta charset="utf-8"><title>Entrega de veiculo</title>' +
        '<link rel="stylesheet" href="/css/entrega-veiculo.css?v=20260708-entrega06">' +
        '</head><body class="delivery-print-popup">' + html + '</body></html>';
    }

    printWindow.document.open();
    printWindow.document.write(printHtml);
    printWindow.document.close();

    esperarImagens(printWindow, function () {
      setTimeout(function () {
        try {
          logEvento('impressao');
          printWindow.focus();
          printWindow.print();
        } finally {
          setTimeout(function () { printWindow.close(); }, 250);
        }
      }, isEntrega ? 300 : 0);
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

  function vincularAtalhosTeclado() {
    if (document.documentElement.getAttribute('data-bali-utility-keys') === '1') return;
    document.documentElement.setAttribute('data-bali-utility-keys', '1');

    document.addEventListener('keydown', function (event) {
      var key = (event.key || '').toLowerCase();
      var alvo = event.target || event.srcElement;

      if ((event.ctrlKey || event.metaKey) && key === 'p') {
        if (previewGerada()) {
          event.preventDefault();
          imprimirPainel();
        }
        return;
      }

      if (key !== 'enter') return;
      if (alvo !== pedidoField() && alvo !== lojaField()) return;

      event.preventDefault();
      var botao = gerarButton();
      if (botao && validarConsulta()) botao.click();
    }, true);
  }

  function aplicarMelhorias() {
    if (!document.body || !document.body.classList.contains('bali-utility-page')) return;
    decorarCampos();
    decorarCardConsulta();
    preencherConsultaPorUrl();
    decorarMenuAuditoria();
    decorarBotaoImpressao();
    vincularFerramentasPrevia();
    vincularGerar();
    vincularAtalhosTeclado();
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
