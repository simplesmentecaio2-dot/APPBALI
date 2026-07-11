(function () {
  "use strict";

  function byId(id) {
    return document.getElementById(id);
  }

  function showLoading() {
    var loading = byId("ag");
    if (!loading) return true;
    loading.className = loading.className.replace(/\bis-visible\b/g, "").trim() + " is-visible";
    loading.setAttribute("aria-hidden", "false");
    return true;
  }

  function hideLoading() {
    var loading = byId("ag");
    if (!loading) return;
    loading.className = loading.className.replace(/\bis-visible\b/g, "").trim();
    loading.setAttribute("aria-hidden", "true");
    liberarBotoesOcupados();
  }

  function liberarBotoesOcupados() {
    var botoes = document.querySelectorAll("[data-comissao-busy='1']");
    Array.prototype.forEach.call(botoes, function (botao) {
      botao.setAttribute("data-comissao-busy", "0");
      botao.className = botao.className.replace(/\bis-processing\b/g, "").trim();
      if (botao.getAttribute("data-comissao-original-value")) {
        botao.value = botao.getAttribute("data-comissao-original-value");
      }
    });
  }

  function toast(mensagem, tipo) {
    var raiz = byId("comissao-toast-root");
    if (!raiz) {
      raiz = document.createElement("div");
      raiz.id = "comissao-toast-root";
      raiz.className = "comissao-toast-root";
      raiz.setAttribute("aria-live", "polite");
      document.body.appendChild(raiz);
    }

    var item = document.createElement("div");
    item.className = "comissao-toast " + (tipo || "info");
    item.textContent = mensagem || "";
    raiz.appendChild(item);

    window.setTimeout(function () {
      item.className += " is-visible";
    }, 20);

    window.setTimeout(function () {
      item.className = item.className.replace(/\bis-visible\b/g, "").trim();
      window.setTimeout(function () {
        if (item.parentNode) item.parentNode.removeChild(item);
      }, 260);
    }, 5200);
  }

  function normalizarData(valor) {
    valor = (valor || "").replace(/\D/g, "").slice(0, 8);
    if (valor.length >= 5) return valor.slice(0, 2) + "/" + valor.slice(2, 4) + "/" + valor.slice(4);
    if (valor.length >= 3) return valor.slice(0, 2) + "/" + valor.slice(2);
    return valor;
  }

  function prepararDatas() {
    var campos = document.querySelectorAll("input[id*='Dt'], input[id*='dt'], input[id*='TextBox1'], input[id*='TextBox2'], input[id*='TextBox3'], input[id*='TextBox4'], input[id*='TextBox5'], input[id*='TextBox6']");
    Array.prototype.forEach.call(campos, function (campo) {
      if (campo.getAttribute("data-comissao-date") === "1") return;
      campo.setAttribute("data-comissao-date", "1");
      campo.setAttribute("inputmode", "numeric");
      campo.setAttribute("placeholder", "dd/mm/aaaa");
      campo.setAttribute("autocomplete", "off");
      campo.addEventListener("input", function () {
        campo.value = normalizarData(campo.value);
      });
    });
  }

  function doisDigitos(valor) {
    valor = String(valor);
    return valor.length === 1 ? "0" + valor : valor;
  }

  function formatarData(data) {
    var dia = doisDigitos(data.getDate());
    var mes = doisDigitos(data.getMonth() + 1);
    return dia + "/" + mes + "/" + data.getFullYear();
  }

  function inicioMes(data) {
    return new Date(data.getFullYear(), data.getMonth(), 1);
  }

  function fimMes(data) {
    return new Date(data.getFullYear(), data.getMonth() + 1, 0);
  }

  function aplicarPeriodo(inicial, final, tipo) {
    var hoje = new Date();
    var ini = hoje;
    var fim = hoje;

    if (tipo === "mes") {
      ini = inicioMes(hoje);
      fim = fimMes(hoje);
    } else if (tipo === "anterior") {
      var anterior = new Date(hoje.getFullYear(), hoje.getMonth() - 1, 1);
      ini = inicioMes(anterior);
      fim = fimMes(anterior);
    } else if (tipo === "sete") {
      ini = new Date(hoje.getFullYear(), hoje.getMonth(), hoje.getDate() - 6);
    }

    inicial.value = formatarData(ini);
    final.value = formatarData(fim);
    dispararAlteracao(inicial);
    dispararAlteracao(final);
  }

  function dispararAlteracao(campo) {
    if (typeof Event === "function") {
      campo.dispatchEvent(new Event("change", { bubbles: true }));
      return;
    }

    var evento = document.createEvent("HTMLEvents");
    evento.initEvent("change", true, false);
    campo.dispatchEvent(evento);
  }

  function encontrarCampoPorSufixo(sufixo) {
    return document.querySelector("input[id$='" + sufixo + "']");
  }

  function prepararAtalhosPeriodo() {
    var pares = [
      ["txtDtInicial", "txtDtFinal"],
      ["txtDtinicialPrem", "txtDtfinalPrem"],
      ["txtDtinicialEmpl", "txtDtfinalEmpl"],
      ["txtdtInicialPremiacao", "txtdtFinalPremiacao"],
      ["TextBox1", "TextBox2"],
      ["TextBox3", "TextBox4"],
      ["TextBox5", "TextBox6"]
    ];

    pares.forEach(function (par) {
      var inicial = encontrarCampoPorSufixo(par[0]);
      var final = encontrarCampoPorSufixo(par[1]);
      if (!inicial || !final || inicial.getAttribute("data-comissao-periodo") === "1") return;

      inicial.setAttribute("data-comissao-periodo", "1");
      var alvo = final.closest ? (final.closest("table") || final.closest(".comissao-report-filter")) : null;
      if (!alvo || !alvo.parentNode) return;

      var barra = document.createElement("div");
      barra.className = "comissao-period-shortcuts";
      [
        ["mes", "Este m\u00eas"],
        ["anterior", "M\u00eas anterior"],
        ["sete", "\u00daltimos 7 dias"],
        ["hoje", "Hoje"]
      ].forEach(function (item) {
        var botao = document.createElement("button");
        botao.type = "button";
        botao.textContent = item[1];
        botao.addEventListener("click", function () {
          aplicarPeriodo(inicial, final, item[0]);
        });
        barra.appendChild(botao);
      });

      alvo.parentNode.insertBefore(barra, alvo.nextSibling);
    });
  }

  function prepararBotoes() {
    var botoes = document.querySelectorAll("input[type='submit'], input[type='button']");
    Array.prototype.forEach.call(botoes, function (botao) {
      if (botao.getAttribute("data-comissao-button") === "1") return;
      botao.setAttribute("data-comissao-button", "1");
      var valor = (botao.value || "").trim();
      if (valor === "Rec...") {
        botao.value = "Recalcular";
        botao.title = "Recalcular comissao do vendedor selecionado";
      } else if (valor === "Atualizar") {
        botao.title = "Atualizar dados do periodo selecionado";
      } else if (valor === "Salvar") {
        botao.title = "Salvar os valores revisados";
      }

      if (/atualizar|exibir|salvar|rec/i.test(botao.value || "")) {
        botao.addEventListener("click", function (event) {
          if (botao.getAttribute("data-comissao-busy") === "1") {
            event.preventDefault();
            toast("Aguarde o processamento atual terminar.", "warning");
            return false;
          }

          botao.setAttribute("data-comissao-busy", "1");
          botao.setAttribute("data-comissao-original-value", botao.value || "");
          botao.className = (botao.className ? botao.className + " " : "") + "is-processing";
          if (/salvar/i.test(botao.value || "")) {
            botao.value = "Salvando...";
          } else if (/gerar|exibir|atualizar|rec/i.test(botao.value || "")) {
            botao.value = "Processando...";
          }

          window.setTimeout(showLoading, 80);
        });
      }
    });
  }

  function prepararValores() {
    var campos = document.querySelectorAll("input.moeda, input[id*='Comissao'], input[id*='Premio'], input[id*='Retorno'], input[id*='Cheque'], input[id*='Emplacamento'], input[id*='avulsos'], input[id*='mvp']");
    Array.prototype.forEach.call(campos, function (campo) {
      if (campo.getAttribute("data-comissao-money") === "1") return;
      campo.setAttribute("data-comissao-money", "1");
      campo.setAttribute("inputmode", "decimal");
      campo.setAttribute("autocomplete", "off");
      if ((" " + campo.className + " ").indexOf(" moeda ") < 0) {
        campo.className = (campo.className ? campo.className + " " : "") + "moeda";
      }

      campo.addEventListener("focus", function () {
        window.setTimeout(function () {
          try {
            campo.select();
          } catch (e) {
            // Sem acao: alguns campos podem nao permitir selecao programatica.
          }
        }, 0);
      });

      campo.addEventListener("blur", function () {
        if (window.moeda && campo.value) {
          window.moeda();
        }
      });
    });
  }

  function melhorarCommandFields() {
    var links = document.querySelectorAll("table[id*='gView'] a, table[id*='gViewer'] a");
    Array.prototype.forEach.call(links, function (link) {
      var texto = (link.textContent || "").replace(/>/g, "").trim();
      if (!texto || /^>+$/.test(texto)) {
        link.textContent = "Selecionar";
      }
    });

    var icones = document.querySelectorAll(".comissao-print-icon");
    Array.prototype.forEach.call(icones, function (icone) {
      if (icone.getAttribute("data-comissao-print-icon") === "1") return;
      icone.setAttribute("data-comissao-print-icon", "1");
      icone.setAttribute("role", "button");
      icone.setAttribute("tabindex", "0");
      icone.setAttribute("title", icone.getAttribute("alt") || "Imprimir");
      icone.addEventListener("keydown", function (event) {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          icone.click();
        }
      });
    });
  }

  function textoPorSufixo(sufixo) {
    var elemento = document.querySelector("[id$='" + sufixo + "']");
    if (!elemento) return "";
    return ((elemento.value || elemento.textContent || "") + "").replace(/\s+/g, " ").trim();
  }

  function prepararResumoSelecionado() {
    var grupos = [
      ["print-comissao", "lblLoja", "lblCodVend", "lblNomeVendedor", "Comissao"],
      ["print-venda-direta", "lblLojaVD", "lblcodVD", "lblVendVD", "Venda direta"],
      ["print-emplacamento", "lblLojaempl", "lblCodempl", "lblVendempl", "Emplacamento"],
      ["print-premiacao", "lblLojaPrem", "lblCodPrem", "lblVendedorPrem", "Premiacao"]
    ];

    grupos.forEach(function (grupo) {
      var area = byId(grupo[0]);
      if (!area || !area.parentNode) return;

      var existente = area.parentNode.querySelector(".comissao-selection-summary[data-area='" + grupo[0] + "']");
      var loja = textoPorSufixo(grupo[1]);
      var codigo = textoPorSufixo(grupo[2]);
      var vendedor = textoPorSufixo(grupo[3]);

      if (!codigo && !vendedor) {
        if (existente) existente.parentNode.removeChild(existente);
        return;
      }

      var resumo = existente || document.createElement("div");
      resumo.className = "comissao-selection-summary";
      resumo.setAttribute("data-area", grupo[0]);
      resumo.textContent = "";
      [["strong", grupo[4]], ["span", "Loja: " + (loja || "-")], ["span", "Codigo: " + (codigo || "-")], ["span", vendedor || "Vendedor selecionado"]].forEach(function (item) {
        var filho = document.createElement(item[0]);
        filho.textContent = item[1];
        resumo.appendChild(filho);
      });

      if (!existente) {
        area.parentNode.insertBefore(resumo, area);
      }
    });
  }

  function prepararTabelas() {
    var tabelas = document.querySelectorAll("table[id*='gView'], table[id*='gViewer']");
    Array.prototype.forEach.call(tabelas, function (tabela) {
      if (tabela.parentNode && tabela.parentNode.className && tabela.parentNode.className.indexOf("comissao-table-scroll") >= 0) return;
      var wrapper = document.createElement("div");
      wrapper.className = "comissao-table-scroll";
      tabela.parentNode.insertBefore(wrapper, tabela);
      wrapper.appendChild(tabela);
    });
  }

  function prepararBuscaTabelas() {
    var wrappers = document.querySelectorAll(".comissao-table-scroll");
    Array.prototype.forEach.call(wrappers, function (wrapper) {
      var tabela = wrapper.querySelector("table[id*='gView'], table[id*='gViewer']");
      if (!tabela || wrapper.getAttribute("data-comissao-search") === "1") return;

      wrapper.setAttribute("data-comissao-search", "1");
      var busca = document.createElement("input");
      busca.type = "search";
      busca.className = "comissao-grid-search";
      busca.placeholder = "Filtrar por loja, c\u00f3digo ou vendedor";
      busca.autocomplete = "off";
      var contador = document.createElement("div");
      contador.className = "comissao-grid-count";

      function atualizarFiltro() {
        var termo = (busca.value || "").toLowerCase();
        var total = 0;
        var visiveis = 0;
        var linhas = tabela.querySelectorAll("tr");
        Array.prototype.forEach.call(linhas, function (linha, indice) {
          if (indice === 0 || linha.querySelector("th")) return;
          total += 1;
          var texto = (linha.textContent || "").toLowerCase();
          var mostrar = texto.indexOf(termo) >= 0;
          linha.style.display = mostrar ? "" : "none";
          if (mostrar) visiveis += 1;
        });
        contador.textContent = visiveis + " de " + total + " registro(s)";
      }

      wrapper.parentNode.insertBefore(busca, wrapper);
      wrapper.parentNode.insertBefore(contador, wrapper);
      busca.addEventListener("input", atualizarFiltro);
      atualizarFiltro();
    });
  }

  function prepararRelatorios() {
    var botoes = document.querySelectorAll(".comissao-report-expand");
    Array.prototype.forEach.call(botoes, function (botao) {
      if (botao.getAttribute("data-comissao-expand") === "1") return;
      botao.setAttribute("data-comissao-expand", "1");
      botao.addEventListener("click", function () {
        var painel = botao.closest ? botao.closest(".comissao-report-panel") : null;
        if (!painel) return;
        var ativo = painel.className.indexOf("is-expanded") >= 0;
        painel.className = ativo ? painel.className.replace(/\bis-expanded\b/g, "").trim() : painel.className + " is-expanded";
        botao.textContent = ativo ? "Tela cheia" : "Fechar tela cheia";
      });
    });
  }

  function fecharRelatoriosExpandidos() {
    var paineis = document.querySelectorAll(".comissao-report-panel.is-expanded");
    Array.prototype.forEach.call(paineis, function (painel) {
      painel.className = painel.className.replace(/\bis-expanded\b/g, "").trim();
      var botao = painel.querySelector(".comissao-report-expand");
      if (botao) botao.textContent = "Tela cheia";
    });
  }

  function prepararTela() {
    prepararDatas();
    prepararAtalhosPeriodo();
    prepararBotoes();
    prepararValores();
    melhorarCommandFields();
    prepararResumoSelecionado();
    prepararTabelas();
    prepararBuscaTabelas();
    prepararRelatorios();
    hideLoading();
  }

  window.BaliComissao = {
    showLoading: showLoading,
    hideLoading: hideLoading,
    toast: toast,
    refresh: prepararTela
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", prepararTela);
  } else {
    prepararTela();
  }

  if (window.Sys && window.Sys.WebForms && window.Sys.WebForms.PageRequestManager) {
    window.Sys.WebForms.PageRequestManager.getInstance().add_endRequest(prepararTela);
  }

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
      fecharRelatoriosExpandidos();
    }
  });
}());
