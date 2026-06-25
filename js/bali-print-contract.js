(function () {
    function camposDeTexto() {
        return document.querySelectorAll('.contrato-texto-justificado');
    }

    function obterTexto(campo) {
        return (campo && typeof campo.value === 'string') ? campo.value : '';
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

    function criarBarraImpressao() {
        if (document.getElementById('baliPrintToolbar')) return;

        var barra = criarElemento('div', 'bali-print-toolbar');
        barra.id = 'baliPrintToolbar';
        barra.setAttribute('role', 'region');
        barra.setAttribute('aria-label', 'Acoes da impressao do contrato');

        var titulo = criarElemento('div', 'bali-print-toolbar-title');
        titulo.appendChild(criarElemento('strong', '', 'Contrato'));
        titulo.appendChild(criarElemento('span', '', 'Visualizacao de impressao'));

        var botao = criarElemento('button', 'bali-print-button', 'Imprimir');
        botao.type = 'button';
        botao.onclick = function () {
            atualizarTextos();
            window.print();
        };

        barra.appendChild(titulo);
        barra.appendChild(botao);
        document.body.insertBefore(barra, document.body.firstChild);
        adicionarClasse(document.body, 'bali-print-page');
    }

    function removerBarraImpressao() {
        var barra = document.getElementById('baliPrintToolbar');
        if (barra && barra.parentNode) {
            barra.parentNode.removeChild(barra);
        }
        removerClasse(document.body, 'bali-print-page');
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
