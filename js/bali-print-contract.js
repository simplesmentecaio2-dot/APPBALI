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

    function camposFormulario() {
        return document.querySelectorAll('input.form-contrato, input.form-contrata, input.form-despachante, input.form-aviso, textarea.form-contrato, textarea.form-contrata, textarea.form-despachante, textarea.form-aviso');
    }

    function deveIgnorarCampo(campo) {
        var tipo = (campo.getAttribute('type') || '').toLowerCase();
        return tipo === 'hidden' || tipo === 'button' || tipo === 'submit' || tipo === 'image' || tipo === 'checkbox' || tipo === 'radio';
    }

    function prepararCampoFormulario(campo) {
        if (!campo || deveIgnorarCampo(campo)) return;

        var valor = typeof campo.value === 'string' ? campo.value : '';
        if (!campo.getAttribute('data-print-font-size')) {
            campo.setAttribute('data-print-font-size', campo.style.fontSize || '');
        }

        if (/^\s*$/.test(valor)) {
            if (!campo.getAttribute('data-print-original-value')) {
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
        prepararCamposFormulario();
        removerBarraImpressao();
    });
    window.addEventListener('afterprint', function () {
        restaurarCamposFormulario();
        criarBarraImpressao();
    });
})();
