(function () {
    'use strict';

    var MAX_SIDE = 900;
    var JPEG_QUALITY = 0.42;
    var MAX_FILE_SIZE = 12 * 1024 * 1024;
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
            preview.removeAttribute('src');
            preview.classList.remove('is-ready');
        }
        box.classList.remove('has-photo', 'is-loading');
        box.removeAttribute('data-photo-uploading');
        setText(status, 'Opcional: tire uma foto ou escolha da galeria.');
    }

    function readImage(file) {
        return new Promise(function (resolve, reject) {
            var reader = new FileReader();
            reader.onload = function () {
                var img = new Image();
                img.onload = function () { resolve(img); };
                img.onerror = reject;
                img.src = reader.result;
            };
            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    }

    function compressImage(img) {
        var width = img.naturalWidth || img.width;
        var height = img.naturalHeight || img.height;
        var scale = Math.min(1, MAX_SIDE / Math.max(width, height));
        var targetWidth = Math.max(1, Math.round(width * scale));
        var targetHeight = Math.max(1, Math.round(height * scale));
        var canvas = document.createElement('canvas');
        canvas.width = targetWidth;
        canvas.height = targetHeight;
        var ctx = canvas.getContext('2d');
        ctx.fillStyle = '#fff';
        ctx.fillRect(0, 0, targetWidth, targetHeight);
        ctx.drawImage(img, 0, 0, targetWidth, targetHeight);
        return canvas.toDataURL('image/jpeg', JPEG_QUALITY);
    }

    function uploadTemp(dataUrl, fileName) {
        if (!window.fetch || !window.FormData) {
            return Promise.reject(new Error('upload indisponivel'));
        }

        var form = new FormData();
        form.append('foto', dataUrl);
        form.append('nome', fileName || 'foto.jpg');

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
        setText(status, 'Comprimindo foto no celular...');

        readImage(file)
            .then(compressImage)
            .then(function (dataUrl) {
                if (nameHidden) nameHidden.value = file.name || 'foto.jpg';
                if (sizeHidden) sizeHidden.value = String(file.size || 0);
                if (preview) {
                    preview.src = dataUrl;
                    preview.classList.add('is-ready');
                }
                box.classList.add('has-photo');
                setText(status, 'Enviando foto comprimida para o servidor...');

                return uploadTemp(dataUrl, file.name).then(function (result) {
                    if (hidden) hidden.value = result.url;
                    box.classList.remove('is-loading');
                    box.removeAttribute('data-photo-uploading');
                    setText(status, 'Foto pronta no servidor (' + humanSize(result.bytes || Math.round(dataUrl.length * 0.75)) + ').');
                }).catch(function () {
                    if (hidden) hidden.value = dataUrl;
                    box.classList.remove('is-loading');
                    box.removeAttribute('data-photo-uploading');
                    setText(status, 'Foto pronta localmente (' + humanSize(Math.round(dataUrl.length * 0.75)) + '). Se a conexao estiver lenta, aguarde antes de salvar.');
                });
            })
            .catch(function () {
                box.classList.remove('is-loading');
                box.removeAttribute('data-photo-uploading');
                setText(status, 'Nao consegui preparar esta foto. Tente outra imagem.');
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
