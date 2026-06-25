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

        campo.style.height = 'auto';
        campo.style.height = Math.max(campo.scrollHeight, 14) + 'px';
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
        document.addEventListener('DOMContentLoaded', atualizarTextos);
    } else {
        atualizarTextos();
    }

    window.addEventListener('load', atualizarTextos);
    window.addEventListener('beforeprint', atualizarTextos);
})();
