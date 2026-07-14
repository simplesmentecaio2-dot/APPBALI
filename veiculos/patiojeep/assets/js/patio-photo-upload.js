(function () {
    'use strict';

    var MAX_FILE_SIZE = 16 * 1024 * 1024;
    var UPLOAD_ENDPOINT = './patio-photo-temp.ashx';

    function $(root, selector) {
        return root.querySelector(selector);
    }

    function setText(el, text) {
        if (el) el.textContent = text || '';
    }

    function humanSize(bytes) {
        if (!bytes) return '';
        if (bytes < 1024 * 1024) return Math.round(bytes / 1024) + ' KB';
        return (bytes / 1024 / 1024).toFixed(1).replace('.', ',') + ' MB';
    }

    function resetUploader(box) {
        var input = $('[data-photo-input]', box);
        var hidden = document.getElementById(box.getAttribute('data-photo-hidden'));
        var nameHidden = document.getElementById(box.getAttribute('data-photo-name'));
        var sizeHidden = document.getElementById(box.getAttribute('data-photo-size'));
        var preview = $('[data-photo-preview]', box);
        var status = $('[data-photo-status]', box);

        if (input) input.value = '';
        if (hidden) hidden.value = '';
        if (nameHidden) nameHidden.value = '';
        if (sizeHidden) sizeHidden.value = '';
        if (preview) {
            if (preview.getAttribute('data-object-url')) {
                try { URL.revokeObjectURL(preview.getAttribute('data-object-url')); } catch (ignore) { }
                preview.removeAttribute('data-object-url');
            }
            preview.removeAttribute('src');
            preview.classList.remove('is-ready');
        }
        box.classList.remove('has-photo', 'is-loading');
        box.removeAttribute('data-photo-uploading');
        setText(status, 'Opcional: tire uma foto ou escolha da galeria.');
    }

    function uploadTemp(file) {
        if (!window.fetch || !window.FormData) {
            return Promise.reject(new Error('upload indisponivel'));
        }

        var form = new FormData();
        form.append('arquivo', file, file.name || 'foto.jpg');
        form.append('nome', file.name || 'foto.jpg');

        return fetch(UPLOAD_ENDPOINT, {
            method: 'POST',
            body: form,
            credentials: 'same-origin'
        }).then(function (response) {
            if (!response.ok) throw new Error('upload falhou');
            return response.json();
        }).then(function (json) {
            if (!json || !json.ok || !json.url) throw new Error((json && json.message) || 'upload falhou');
            return json;
        });
    }

    function handleFile(box, file) {
        var hidden = document.getElementById(box.getAttribute('data-photo-hidden'));
        var nameHidden = document.getElementById(box.getAttribute('data-photo-name'));
        var sizeHidden = document.getElementById(box.getAttribute('data-photo-size'));
        var preview = $('[data-photo-preview]', box);
        var status = $('[data-photo-status]', box);

        if (!file) return;
        if (!/^image\//i.test(file.type || '')) {
            setText(status, 'Escolha um arquivo de imagem.');
            return;
        }
        if (file.size > MAX_FILE_SIZE) {
            setText(status, 'Foto muito grande. Escolha uma imagem menor.');
            return;
        }

        box.classList.add('is-loading');
        box.setAttribute('data-photo-uploading', '1');
        if (hidden) hidden.value = '';
        if (nameHidden) nameHidden.value = file.name || 'foto.jpg';
        if (sizeHidden) sizeHidden.value = String(file.size || 0);
        if (preview && window.URL && URL.createObjectURL) {
            var objectUrl = URL.createObjectURL(file);
            preview.src = objectUrl;
            preview.setAttribute('data-object-url', objectUrl);
            preview.classList.add('is-ready');
        }
        box.classList.add('has-photo');
        setText(status, 'Enviando foto para o servidor. Voce pode continuar preenchendo.');

        uploadTemp(file)
            .then(function (result) {
                if (hidden) hidden.value = result.url;
                box.classList.remove('is-loading');
                box.removeAttribute('data-photo-uploading');
                setText(status, 'Foto pronta no servidor (' + humanSize(result.bytes || file.size) + ').');
            })
            .catch(function () {
                box.classList.remove('is-loading');
                box.removeAttribute('data-photo-uploading');
                setText(status, 'Nao consegui enviar a foto. Tente novamente ou salve sem foto.');
            });
    }

    function bindUploader(box) {
        if (!box || box.getAttribute('data-photo-bound') === '1') return;
        box.setAttribute('data-photo-bound', '1');

        var input = $('[data-photo-input]', box);
        var clear = $('[data-photo-clear]', box);
        if (input) {
            input.addEventListener('change', function () {
                handleFile(box, input.files && input.files[0]);
            });
        }
        if (clear) {
            clear.addEventListener('click', function (event) {
                event.preventDefault();
                resetUploader(box);
            });
        }
    }

    function bindAll() {
        var boxes = document.querySelectorAll('[data-patio-photo]');
        for (var i = 0; i < boxes.length; i++) bindUploader(boxes[i]);
    }

    function hasPendingUpload() {
        return !!document.querySelector('[data-patio-photo][data-photo-uploading="1"]');
    }

    document.addEventListener('click', function (event) {
        var button = event.target && event.target.closest ? event.target.closest('.js-safe-submit') : null;
        if (!button || !hasPendingUpload()) return;
        event.preventDefault();
        event.stopPropagation();
        if (event.stopImmediatePropagation) event.stopImmediatePropagation();
        if (window.patioToast) {
            window.patioToast('Aguarde a foto terminar de enviar antes de salvar.', 'warning');
        } else {
            alert('Aguarde a foto terminar de enviar antes de salvar.');
        }
    }, true);

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', bindAll);
    } else {
        bindAll();
    }

    if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(bindAll);
    }

    window.PatioPhotoUpload = {
        bindAll: bindAll,
        reset: resetUploader,
        hasPending: hasPendingUpload
    };
})();
