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
      var alvo = final.closest ? final.closest("table") : null;
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
      if (/atualizar|exibir|salvar|rec/i.test(botao.value || "")) {
        botao.addEventListener("click", function () {
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
      if (!texto) {
        link.textContent = "Selecionar";
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

  function prepararTela() {
    prepararDatas();
    prepararAtalhosPeriodo();
    prepararBotoes();
    prepararValores();
    melhorarCommandFields();
    prepararTabelas();
    prepararBuscaTabelas();
    hideLoading();
  }

  window.BaliComissao = {
    showLoading: showLoading,
    hideLoading: hideLoading,
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
}());
