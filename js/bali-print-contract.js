(function () {
    function camposDeTexto() {
        return document.querySelectorAll('.contrato-texto-justificado');
    }

    function obterTexto(campo) {
        if (!campo) return '';

        if (campo.getAttribute) {
            var textoServidor = campo.getAttribute('data-print-text');
            if (textoServidor) return textoServidor;
        }

        if (typeof campo.value === 'string' && campo.value) {
            return campo.value;
        }

        if (typeof campo.defaultValue === 'string' && campo.defaultValue) {
            return campo.defaultValue;
        }

        if (typeof campo.textContent === 'string') {
            return campo.textContent;
        }

        return '';
    }

    function normalizarClasse(valor) {
        return (valor || '').replace(/\s+/g, ' ').replace(/^\s+|\s+$/g, '');
    }

    function temClasse(elemento, classe) {
        return elemento && (' ' + elemento.className + ' ').indexOf(' ' + classe + ' ') >= 0;
    }

    function adicionarClasse(elemento, classe) {
        if (elemento && !temClasse(elemento, classe)) {
            elemento.className = normalizarClasse((elemento.className || '') + ' ' + classe);
        }
    }

    function temAtributo(elemento, nome) {
        if (!elemento) return false;
        if (elemento.hasAttribute) return elemento.hasAttribute(nome);
        return elemento.getAttribute(nome) !== null;
    }

    function proximoElemento(campo) {
        var elemento = campo.nextSibling;
        while (elemento && elemento.nodeType !== 1) {
            elemento = elemento.nextSibling;
        }
        return elemento;
    }

    function criarRender(campo) {
        var proximo = proximoElemento(campo);
        if (temClasse(proximo, 'contrato-texto-renderizado')) {
            return proximo;
        }

        var render = document.createElement('div');
        render.className = normalizarClasse((campo.className || '') + ' contrato-texto-renderizado');
        campo.parentNode.insertBefore(render, campo.nextSibling);
        return render;
    }

    function ajustarCampo(campo) {
        if (!campo) return;
        var texto = obterTexto(campo);
        var render = criarRender(campo);
        if ('textContent' in render) {
            render.textContent = texto;
        } else {
            render.innerText = texto;
        }

        campo.style.height = '0px';
        campo.style.minHeight = '0px';
        campo.style.maxHeight = '0px';
        campo.setAttribute('aria-hidden', 'true');
    }

    function camposFormulario() {
        return document.querySelectorAll('input.form-contrato, input.form-contrata, input.form-despachante, input.form-aviso, textarea.form-contrato, textarea.form-contrata, textarea.form-despachante, textarea.form-aviso');
    }

    function camposTextoSimples() {
        return document.querySelectorAll('span.form-contrato, span.form-contrata, span.form-despachante, span.form-aviso, label.form-contrato, label.form-contrata, label.form-despachante, label.form-aviso');
    }

    function deveIgnorarCampo(campo) {
        var tipo = (campo.getAttribute('type') || '').toLowerCase();
        return tipo === 'hidden' || tipo === 'button' || tipo === 'submit' || tipo === 'image' || tipo === 'checkbox' || tipo === 'radio';
    }

    function prepararCampoFormulario(campo) {
        if (!campo || deveIgnorarCampo(campo)) return;

        var valor = typeof campo.value === 'string' ? campo.value : '';
        if (!temAtributo(campo, 'data-print-font-size')) {
            campo.setAttribute('data-print-font-size', campo.style.fontSize || '');
        }

        if (/^\s*$/.test(valor)) {
            if (!temAtributo(campo, 'data-print-original-value')) {
                campo.setAttribute('data-print-original-value', valor);
            }
            campo.setAttribute('data-print-empty-value', '1');
            campo.value = '-';
            valor = '-';
        }

        var tamanho = valor.replace(/\s+/g, ' ').length;
        if (tamanho > 52) {
            campo.style.fontSize = '7px';
        } else if (tamanho > 42) {
            campo.style.fontSize = '7.5px';
        } else if (tamanho > 32) {
            campo.style.fontSize = '8px';
        }
    }

    function prepararCamposFormulario() {
        var campos = camposFormulario();
        for (var i = 0; i < campos.length; i++) {
            prepararCampoFormulario(campos[i]);
        }
    }

    function restaurarCamposFormulario() {
        var campos = camposFormulario();
        for (var i = 0; i < campos.length; i++) {
            var campo = campos[i];
            if (campo.getAttribute('data-print-empty-value') === '1') {
                campo.value = campo.getAttribute('data-print-original-value') || '';
                campo.removeAttribute('data-print-empty-value');
                campo.removeAttribute('data-print-original-value');
            }

            var fonteOriginal = campo.getAttribute('data-print-font-size');
            if (fonteOriginal !== null) {
                campo.style.fontSize = fonteOriginal;
                campo.removeAttribute('data-print-font-size');
            }
        }
    }

    function obterTextoElemento(elemento) {
        if (!elemento) return '';
        if (typeof elemento.textContent === 'string') return elemento.textContent;
        if (typeof elemento.innerText === 'string') return elemento.innerText;
        return '';
    }

    function definirTextoElemento(elemento, texto) {
        if (!elemento) return;
        if ('textContent' in elemento) {
            elemento.textContent = texto;
        } else {
            elemento.innerText = texto;
        }
    }

    function prepararTextoSimples(elemento) {
        if (!elemento) return;

        var texto = obterTextoElemento(elemento);
        var textoLimpo = texto.replace(/\s+/g, ' ').replace(/^\s+|\s+$/g, '');

        if (!temAtributo(elemento, 'data-print-font-size')) {
            elemento.setAttribute('data-print-font-size', elemento.style.fontSize || '');
        }

        if (!temAtributo(elemento, 'data-print-original-text')) {
            elemento.setAttribute('data-print-original-text', texto);
        }

        if (!textoLimpo || textoLimpo.toLowerCase() === 'label') {
            elemento.setAttribute('data-print-empty-text', '1');
            definirTextoElemento(elemento, '-');
            textoLimpo = '-';
        }

        if (textoLimpo.length > 64) {
            elemento.style.fontSize = '8px';
        } else if (textoLimpo.length > 48) {
            elemento.style.fontSize = '8.5px';
        }
    }

    function prepararTextosSimples() {
        var campos = camposTextoSimples();
        for (var i = 0; i < campos.length; i++) {
            prepararTextoSimples(campos[i]);
        }
    }

    function restaurarTextosSimples() {
        var campos = camposTextoSimples();
        for (var i = 0; i < campos.length; i++) {
            var campo = campos[i];

            if (campo.getAttribute('data-print-empty-text') === '1') {
                definirTextoElemento(campo, campo.getAttribute('data-print-original-text') || '');
                campo.removeAttribute('data-print-empty-text');
            }

            if (campo.getAttribute('data-print-original-text') !== null) {
                campo.removeAttribute('data-print-original-text');
            }

            var fonteOriginal = campo.getAttribute('data-print-font-size');
            if (fonteOriginal !== null) {
                campo.style.fontSize = fonteOriginal;
                campo.removeAttribute('data-print-font-size');
            }
        }
    }

    function textoNormalizado(elemento) {
        return obterTextoElemento(elemento).replace(/\s+/g, ' ').replace(/^\s+|\s+$/g, '').toUpperCase();
    }

    function contem(texto, trecho) {
        return texto.indexOf(trecho) >= 0;
    }

    function ehTituloSecao(texto) {
        if (texto === 'DADOS DO CLIENTE') return true;
        if (contem(texto, 'DADOS DO VE')) return true;
        if (contem(texto, 'PRE') && contem(texto, 'FORMAS DE PAGAMENTOS')) return true;
        if (contem(texto, 'AUTORIZA') && contem(texto, 'CLIENTE')) return true;
        if (contem(texto, 'NOTA PROMISS')) return true;
        return false;
    }

    function estiloInline(elemento) {
        return (elemento.getAttribute('style') || '').toLowerCase();
    }

    function classificarEstruturaContrato() {
        var escopo = document.getElementById('pnlImpressao');
        if (!escopo) return;

        var celulas = escopo.getElementsByTagName('td');
        for (var i = 0; i < celulas.length; i++) {
            var celula = celulas[i];
            var texto = textoNormalizado(celula);
            var estilo = estiloInline(celula);

            if (texto.indexOf('CONTRATO DE VENDA') === 0) {
                adicionarClasse(celula, 'bali-contract-main-title');
            }

            if (ehTituloSecao(texto)) {
                adicionarClasse(celula, 'bali-contract-section-title');
            }

            if (estilo.indexOf('padding-bottom: 40px') >= 0) {
                adicionarClasse(celula, 'bali-contract-signature-cell');
            }
        }
    }

    function paginasPrincipaisContrato() {
        return document.querySelectorAll('#pnlImpressao > #Div1, #pnlImpressao > #Div2, #pnlImpressao > #Div3');
    }

    function ajustarEscalaPaginasContrato() {
        var paginas = paginasPrincipaisContrato();
        if (!paginas.length) return;

        var formulario = document.getElementById('form1') || document.forms[0] || document.body;
        var larguraFormulario = formulario.getBoundingClientRect().width || 770;
        var alturaUtilA4 = 1088;
        var escalaMaxima = 1.035;

        for (var i = 0; i < paginas.length; i++) {
            var pagina = paginas[i];
            var medidas = pagina.getBoundingClientRect();
            var escalaLargura = medidas.width > 0 ? larguraFormulario / medidas.width : escalaMaxima;
            var escalaAltura = medidas.height > 0 ? alturaUtilA4 / medidas.height : escalaMaxima;
            var escala = Math.min(escalaMaxima, escalaLargura, escalaAltura);

            if (escala > 1.006) {
                pagina.style.setProperty('--bali-contract-page-scale', escala.toFixed(3));
                adicionarClasse(pagina, 'bali-contract-page-fit');
            }
        }
    }

    function restaurarEscalaPaginasContrato() {
        var paginas = paginasPrincipaisContrato();
        for (var i = 0; i < paginas.length; i++) {
            paginas[i].style.removeProperty('--bali-contract-page-scale');
        }
    }

    function criarElemento(tag, classe, texto) {
        var elemento = document.createElement(tag);
        if (classe) elemento.className = classe;
        if (texto) {
            if ('textContent' in elemento) {
                elemento.textContent = texto;
            } else {
                elemento.innerText = texto;
            }
        }
        return elemento;
    }

    function destinoFallback() {
        var caminho = (window.location.pathname || '').toLowerCase();
        if (caminho.indexOf('/jeep/') >= 0) return '../jeep/contrato.aspx';
        if (caminho.indexOf('/byd/') >= 0) return '../byd/contrato.aspx';
        return '../veiculos/contrato.aspx';
    }

    function voltarPagina() {
        if (window.history && window.history.length > 1) {
            window.history.back();
            return;
        }
        window.location.href = destinoFallback();
    }

    function criarBarraImpressao() {
        if (document.getElementById('baliPrintToolbar')) return;

        var barra = criarElemento('div', 'bali-print-toolbar');
        barra.id = 'baliPrintToolbar';
        barra.setAttribute('role', 'region');
        barra.setAttribute('aria-label', 'Acoes da impressao do contrato');

        var titulo = criarElemento('div', 'bali-print-toolbar-title');
        titulo.appendChild(criarElemento('strong', '', 'Contrato'));
        titulo.appendChild(criarElemento('span', '', 'Visualizacao de impressao'));

        var acoes = criarElemento('div', 'bali-print-toolbar-actions');
        var voltar = criarElemento('button', 'bali-print-button bali-print-button-secondary', 'Voltar');
        voltar.type = 'button';
        voltar.onclick = voltarPagina;

        var botao = criarElemento('button', 'bali-print-button', 'Imprimir');
        botao.type = 'button';
        botao.onclick = function () {
            atualizarTextos();
            prepararCamposFormulario();
            prepararTextosSimples();
            ajustarEscalaPaginasContrato();
            window.print();
        };

        acoes.appendChild(voltar);
        acoes.appendChild(botao);
        barra.appendChild(titulo);
        barra.appendChild(acoes);
        document.body.insertBefore(barra, document.body.firstChild);
        adicionarClasse(document.body, 'bali-print-page');
    }

    function removerBarraImpressao() {
        var barra = document.getElementById('baliPrintToolbar');
        if (barra && barra.parentNode) {
            barra.parentNode.removeChild(barra);
        }
    }

    function atualizarTextos() {
        classificarEstruturaContrato();

        var campos = camposDeTexto();
        for (var i = 0; i < campos.length; i++) {
            ajustarCampo(campos[i]);
        }

        if (campos.length > 0) {
            adicionarClasse(document.body, 'contrato-texto-renderizado-ativo');
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function () {
            criarBarraImpressao();
            atualizarTextos();
        });
    } else {
        criarBarraImpressao();
        atualizarTextos();
    }

    window.addEventListener('load', function () {
        criarBarraImpressao();
        atualizarTextos();
    });
    window.addEventListener('beforeprint', function () {
        atualizarTextos();
        prepararCamposFormulario();
        prepararTextosSimples();
        ajustarEscalaPaginasContrato();
        removerBarraImpressao();
    });
    window.addEventListener('afterprint', function () {
        restaurarEscalaPaginasContrato();
        restaurarCamposFormulario();
        restaurarTextosSimples();
        criarBarraImpressao();
    });
})();
