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

    function removerClasse(elemento, classe) {
        if (elemento && temClasse(elemento, classe)) {
            elemento.className = normalizarClasse((' ' + elemento.className + ' ').replace(' ' + classe + ' ', ' '));
        }
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
        removerBarraImpressao();
    });
    window.addEventListener('afterprint', criarBarraImpressao);
})();
