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
      busca.placeholder = "Filtrar por loja, codigo ou vendedor";
      busca.autocomplete = "off";

      wrapper.parentNode.insertBefore(busca, wrapper);
      busca.addEventListener("input", function () {
        var termo = (busca.value || "").toLowerCase();
        var linhas = tabela.querySelectorAll("tr");
        Array.prototype.forEach.call(linhas, function (linha, indice) {
          if (indice === 0 || linha.querySelector("th")) return;
          var texto = (linha.textContent || "").toLowerCase();
          linha.style.display = texto.indexOf(termo) >= 0 ? "" : "none";
        });
      });
    });
  }

  function prepararTela() {
    prepararDatas();
    prepararBotoes();
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
