(function () {
    'use strict';

    var config = window.PatioBarcodeScannerConfig || {};
    var modalSelector = '#myModal';
    var barcodeFormats = ['code_128', 'code_39', 'ean_13', 'ean_8', 'upc_a'];
    var running = false;
    var locked = false;
    var stream = null;
    var activeTrack = null;
    var nativeDetector = null;
    var nativeTimer = null;
    var quaggaRunning = false;
    var torchEnabled = false;
    var selectedDeviceId = '';
    var availableCameras = [];
    var currentEngine = 'camera';
    var startedAt = 0;
    var manualAutoTimer = null;
    var mainInputTimer = null;
    var suppressMainAutoSearch = false;
    var lastInvalidLog = 0;

    var candidate = {
        serie: '',
        count: 0,
        timestamp: 0
    };

    var el = {};

    function byId(id) {
        return id ? document.getElementById(id) : null;
    }

    function cacheElements() {
        el.input = byId(config.serieInputId);
        el.searchButton = byId(config.searchButtonId);
        el.video = byId('scanner-video');
        el.quaggaContainer = byId('scanner-container');
        el.status = byId('scannerStatus');
        el.result = byId('result');
        el.lastRaw = byId('scannerLastRaw');
        el.engine = byId('scannerEngine');
        el.manual = byId('scannerManualSerie');
        el.applyManual = byId('scannerApplyManual');
        el.retry = byId('scannerRetry');
        el.torch = byId('scannerTorch');
        el.cameraSelect = byId('scannerCameraSelect');
        el.switchCamera = byId('scannerSwitchCamera');
        el.zoomGroup = byId('scannerZoomGroup');
        el.zoom = byId('scannerZoom');
    }

    function setVisible(node, visible) {
        if (!node) return;
        node.classList.toggle('is-hidden', !visible);
    }

    function setStatus(message, type) {
        if (!el.status) return;
        el.status.textContent = message || '';
        el.status.className = 'scanner-status';
        if (type) {
            el.status.classList.add('scanner-status--' + type);
        }
    }

    function setEngine(message) {
        if (!el.engine) return;
        el.engine.textContent = message || 'Câmera';
    }

    function setResult(serie, raw) {
        if (el.result) {
            el.result.textContent = serie ? 'Série detectada: ' + serie : 'aguardando leitura';
        }

        if (el.lastRaw) {
            el.lastRaw.textContent = raw || '-';
        }
    }

    function onlyDigits(value) {
        return (value || '').toString().replace(/\D/g, '');
    }

    function extractSerie(rawValue) {
        var digits = onlyDigits(rawValue);

        if (digits.length === 7) {
            return digits;
        }

        if (digits.length >= 17) {
            return digits.substring(10, 17);
        }

        return '';
    }

    function getElapsedMs() {
        return startedAt ? String(Date.now() - startedAt) : '0';
    }

    function truncate(value, maxLength) {
        var text = (value || '').toString();
        if (text.length <= maxLength) return text;
        return text.substring(0, maxLength);
    }

    function encodeForm(data) {
        var pairs = [];
        Object.keys(data).forEach(function (key) {
            var value = data[key];
            if (value === undefined || value === null) {
                value = '';
            }
            pairs.push(encodeURIComponent(key) + '=' + encodeURIComponent(value));
        });
        return pairs.join('&');
    }

    function getCameraName() {
        if (el.cameraSelect && el.cameraSelect.selectedIndex >= 0) {
            return el.cameraSelect.options[el.cameraSelect.selectedIndex].text;
        }

        if (activeTrack && activeTrack.label) {
            return activeTrack.label;
        }

        return selectedDeviceId ? 'camera selecionada' : 'camera padrao';
    }

    function logEvent(eventName, details) {
        if (!config.logEndpoint) return;

        details = details || {};
        var payload = {
            evento: truncate(eventName, 80),
            serie: truncate(details.serie || (el.input && el.input.value) || '', 40),
            origem: truncate(details.source || currentEngine || '', 40),
            motor: truncate(currentEngine || '', 40),
            camera: truncate(details.camera || getCameraName(), 140),
            tempoMs: truncate(details.elapsedMs || getElapsedMs(), 20),
            detalhe: truncate(details.detail || '', 260),
            url: truncate(window.location.pathname + window.location.search, 180)
        };

        var body = encodeForm(payload);

        try {
            if (navigator.sendBeacon) {
                var blob = new Blob([body], { type: 'application/x-www-form-urlencoded;charset=UTF-8' });
                navigator.sendBeacon(config.logEndpoint, blob);
                return;
            }
        } catch (ignore) {
        }

        try {
            window.fetch(config.logEndpoint, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                body: body,
                credentials: 'same-origin',
                keepalive: true
            });
        } catch (ignoreFetch) {
        }
    }

    function isSecureCameraContext() {
        return window.isSecureContext || location.hostname === 'localhost' || location.hostname === '127.0.0.1';
    }

    function resetCandidate() {
        candidate.serie = '';
        candidate.count = 0;
        candidate.timestamp = 0;
    }

    function stopMediaStream() {
        if (!stream) return;

        stream.getTracks().forEach(function (track) {
            try {
                track.stop();
            } catch (ignore) {
                // Nada a fazer se o navegador já encerrou a câmera.
            }
        });

        stream = null;
        activeTrack = null;
        torchEnabled = false;
    }

    function stopQuagga() {
        if (!window.Quagga) return;

        try {
            if (window.Quagga.offDetected) {
                window.Quagga.offDetected(onQuaggaDetected);
            }
        } catch (ignore) {
            // Versões antigas do Quagga podem não remover handlers com segurança.
        }

        if (quaggaRunning) {
            try {
                window.Quagga.stop();
            } catch (ignoreStop) {
                // O Quagga pode lançar erro caso já esteja parado.
            }
        }

        quaggaRunning = false;

        if (el.quaggaContainer) {
            el.quaggaContainer.innerHTML = '';
        }
    }

    function stopScanner(options) {
        options = options || {};

        if (running && !options.silent) {
            logEvent('scanner_fechado', { detail: 'modal fechado antes de concluir leitura' });
        }

        running = false;
        locked = false;
        nativeDetector = null;

        if (nativeTimer) {
            window.clearTimeout(nativeTimer);
            nativeTimer = null;
        }

        if (manualAutoTimer) {
            window.clearTimeout(manualAutoTimer);
            manualAutoTimer = null;
        }

        stopMediaStream();
        stopQuagga();

        if (el.video) {
            el.video.pause();
            el.video.removeAttribute('src');
            el.video.srcObject = null;
        }

        setVisible(el.video, false);
        setVisible(el.quaggaContainer, false);
        setVisible(el.torch, false);
        setVisible(el.zoomGroup, false);
    }

    function triggerSearch() {
        suppressMainAutoSearch = true;

        if (el.input) {
            try {
                el.input.dispatchEvent(new Event('input', { bubbles: true }));
                el.input.dispatchEvent(new Event('change', { bubbles: true }));
            } catch (ignore) {
                // Fallback abaixo cobre navegadores antigos.
            }
        }

        window.setTimeout(function () {
            suppressMainAutoSearch = false;
        }, 800);

        if (el.searchButton && typeof el.searchButton.click === 'function') {
            el.searchButton.click();
            return;
        }

        if (window.__doPostBack && config.postBackTarget) {
            window.__doPostBack(config.postBackTarget, '');
        }
    }

    function acceptSerie(serie, rawValue, source) {
        if (locked || !serie) return;

        locked = true;
        setResult(serie, rawValue);
        setStatus('Série ' + serie + ' encontrada. Consultando o veículo...', 'success');
        logEvent('serie_aceita', {
            serie: serie,
            source: source,
            detail: rawValue ? 'codigo=' + rawValue : ''
        });

        if (window.navigator && window.navigator.vibrate) {
            window.navigator.vibrate(80);
        }

        if (el.input) {
            el.input.value = serie;
        }

        stopScanner({ silent: true });

        try {
            if (window.jQuery) {
                window.jQuery(modalSelector).modal('hide');
            }
        } catch (ignore) {
            // Se o Bootstrap não estiver disponível, ainda seguimos com a consulta.
        }

        window.setTimeout(triggerSearch, source === 'manual' ? 80 : 250);
    }

    function registerCandidate(rawValue, source) {
        var serie = extractSerie(rawValue);
        var now = Date.now();

        if (!serie) {
            setStatus('Código lido, mas não foi possível identificar a série de 7 dígitos. Aproxime ou digite manualmente.', 'warning');
            setResult('', rawValue);

            if (now - lastInvalidLog > 3000) {
                lastInvalidLog = now;
                logEvent('codigo_sem_serie', {
                    source: source,
                    detail: rawValue || ''
                });
            }
            return;
        }

        if (candidate.serie === serie && (now - candidate.timestamp) < 1800) {
            candidate.count += 1;
        } else {
            candidate.serie = serie;
            candidate.count = 1;
        }

        candidate.timestamp = now;
        setResult(serie, rawValue);

        var requiredReads = source === 'native' || source === 'manual' ? 1 : 2;
        if (candidate.count >= requiredReads) {
            acceptSerie(serie, rawValue, source);
            return;
        }

        setStatus('Série ' + serie + ' localizada. Mantenha a câmera parada para confirmar a leitura.', 'info');
    }

    function getAverageDecodeError(result) {
        if (!result || !result.codeResult || !result.codeResult.decodedCodes) {
            return 0;
        }

        var errors = result.codeResult.decodedCodes
            .filter(function (code) {
                return typeof code.error === 'number';
            })
            .map(function (code) {
                return code.error;
            });

        if (!errors.length) {
            return 0;
        }

        var total = errors.reduce(function (sum, error) {
            return sum + error;
        }, 0);

        return total / errors.length;
    }

    function onQuaggaDetected(data) {
        if (!running || locked || !data || !data.codeResult || !data.codeResult.code) {
            return;
        }

        var averageError = getAverageDecodeError(data);
        if (averageError && averageError > 0.35) {
            setStatus('Leitura instável. Aproxime o código e evite reflexos.', 'warning');
            return;
        }

        registerCandidate(data.codeResult.code, 'quagga');
    }

    function buildVideoConstraints() {
        var constraints = {
            width: { ideal: 1280 },
            height: { ideal: 720 }
        };

        if (selectedDeviceId) {
            constraints.deviceId = { exact: selectedDeviceId };
        } else {
            constraints.facingMode = { ideal: 'environment' };
        }

        return constraints;
    }

    function refreshCameraList() {
        if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
            setVisible(el.cameraSelect, false);
            setVisible(el.switchCamera, false);
            return Promise.resolve();
        }

        return navigator.mediaDevices.enumerateDevices().then(function (devices) {
            availableCameras = devices.filter(function (device) {
                return device.kind === 'videoinput';
            });

            if (activeTrack && activeTrack.getSettings) {
                selectedDeviceId = activeTrack.getSettings().deviceId || selectedDeviceId;
            }

            if (!availableCameras.length || !el.cameraSelect) {
                setVisible(el.cameraSelect, false);
                setVisible(el.switchCamera, false);
                return;
            }

            el.cameraSelect.innerHTML = '';
            availableCameras.forEach(function (camera, index) {
                var option = document.createElement('option');
                option.value = camera.deviceId;
                option.textContent = camera.label || ('Câmera ' + (index + 1));
                option.selected = camera.deviceId === selectedDeviceId;
                el.cameraSelect.appendChild(option);
            });

            setVisible(el.cameraSelect, availableCameras.length > 1);
            setVisible(el.switchCamera, availableCameras.length > 1);
        }).catch(function () {
            setVisible(el.cameraSelect, false);
            setVisible(el.switchCamera, false);
        });
    }

    function supportsTorch(track) {
        if (!track || typeof track.getCapabilities !== 'function') {
            return false;
        }

        var capabilities = track.getCapabilities();
        return !!(capabilities && capabilities.torch);
    }

    function refreshTorchButton() {
        var canUseTorch = supportsTorch(activeTrack);
        setVisible(el.torch, canUseTorch);

        if (el.torch) {
            el.torch.textContent = torchEnabled ? 'Desligar flash' : 'Ligar flash';
        }
    }

    function refreshZoomControl() {
        if (!activeTrack || !activeTrack.getCapabilities || !el.zoom || !el.zoomGroup) {
            setVisible(el.zoomGroup, false);
            return;
        }

        var capabilities = activeTrack.getCapabilities();
        if (!capabilities || capabilities.zoom === undefined) {
            setVisible(el.zoomGroup, false);
            return;
        }

        var settings = activeTrack.getSettings ? activeTrack.getSettings() : {};
        el.zoom.min = capabilities.zoom.min || 1;
        el.zoom.max = capabilities.zoom.max || 1;
        el.zoom.step = capabilities.zoom.step || 0.1;
        el.zoom.value = settings.zoom || el.zoom.min;
        setVisible(el.zoomGroup, Number(el.zoom.max) > Number(el.zoom.min));
    }

    function applyZoom() {
        if (!activeTrack || !el.zoom) return;

        var zoom = parseFloat(el.zoom.value);
        if (isNaN(zoom)) return;

        activeTrack.applyConstraints({
            advanced: [{ zoom: zoom }]
        }).then(function () {
            logEvent('zoom_alterado', { detail: 'zoom=' + zoom });
        }).catch(function () {
            setStatus('Não foi possível alterar o zoom neste aparelho.', 'warning');
        });
    }

    function startQuaggaScanner() {
        return new Promise(function (resolve, reject) {
            if (!window.Quagga) {
                reject(new Error('Biblioteca do leitor não encontrada.'));
                return;
            }

            currentEngine = 'quagga';
            setVisible(el.video, false);
            setVisible(el.quaggaContainer, true);
            setVisible(el.zoomGroup, false);
            setEngine('Leitor compatível');
            setStatus('Abrindo câmera. Se solicitado, permita o acesso.', 'info');

            window.Quagga.init({
                inputStream: {
                    name: 'Live',
                    type: 'LiveStream',
                    target: el.quaggaContainer,
                    constraints: buildVideoConstraints(),
                    area: {
                        top: '22%',
                        right: '5%',
                        left: '5%',
                        bottom: '22%'
                    }
                },
                locator: {
                    patchSize: 'medium',
                    halfSample: true
                },
                numOfWorkers: Math.min(2, Math.max(1, window.navigator.hardwareConcurrency || 1)),
                frequency: 8,
                decoder: {
                    readers: ['code_128_reader', 'code_39_reader', 'ean_reader', 'ean_8_reader']
                },
                locate: true
            }, function (error) {
                if (error) {
                    reject(error);
                    return;
                }

                try {
                    window.Quagga.start();
                    quaggaRunning = true;
                    window.Quagga.onDetected(onQuaggaDetected);
                    refreshCameraList();
                    logEvent('camera_aberta', { source: 'quagga' });
                    setStatus('Aponte a câmera para o código de barras. Centralize na linha clara.', 'info');
                    resolve();
                } catch (startError) {
                    reject(startError);
                }
            });
        });
    }

    function nativeScanLoop() {
        if (!running || locked || !nativeDetector || !el.video) {
            return;
        }

        nativeDetector.detect(el.video).then(function (barcodes) {
            if (!running || locked) return;

            if (barcodes && barcodes.length) {
                registerCandidate(barcodes[0].rawValue, 'native');
            } else {
                nativeTimer = window.setTimeout(nativeScanLoop, 180);
            }
        }).catch(function () {
            nativeTimer = window.setTimeout(nativeScanLoop, 350);
        });
    }

    function getSupportedNativeFormats() {
        if (!window.BarcodeDetector || !window.BarcodeDetector.getSupportedFormats) {
            return Promise.resolve(barcodeFormats);
        }

        return window.BarcodeDetector.getSupportedFormats().then(function (formats) {
            var supported = barcodeFormats.filter(function (format) {
                return formats.indexOf(format) !== -1;
            });

            return supported.length ? supported : barcodeFormats;
        }).catch(function () {
            return barcodeFormats;
        });
    }

    function startNativeScanner() {
        if (!window.BarcodeDetector || !navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
            return Promise.reject(new Error('Leitor nativo indisponível.'));
        }

        currentEngine = 'native';
        setVisible(el.quaggaContainer, false);
        setVisible(el.video, true);
        setEngine('Leitor do navegador');
        setStatus('Abrindo câmera. Se solicitado, permita o acesso.', 'info');

        return getSupportedNativeFormats().then(function (formats) {
            nativeDetector = new window.BarcodeDetector({ formats: formats });

            return navigator.mediaDevices.getUserMedia({
                video: buildVideoConstraints(),
                audio: false
            });
        }).then(function (mediaStream) {
            stream = mediaStream;
            activeTrack = stream.getVideoTracks()[0] || null;

            if (activeTrack && activeTrack.getSettings) {
                selectedDeviceId = activeTrack.getSettings().deviceId || selectedDeviceId;
            }

            if (el.video) {
                el.video.srcObject = stream;
                return el.video.play();
            }
        }).then(function () {
            refreshTorchButton();
            refreshZoomControl();
            refreshCameraList();
            logEvent('camera_aberta', { source: 'native' });
            setStatus('Aponte a câmera para o código de barras. Centralize na linha clara.', 'info');
            nativeScanLoop();
        });
    }

    function startScanner() {
        cacheElements();
        stopScanner({ silent: true });
        resetCandidate();
        locked = false;
        running = true;
        torchEnabled = false;
        currentEngine = 'camera';
        startedAt = Date.now();

        setResult('', '');
        setEngine('Câmera');
        setVisible(el.cameraSelect, false);
        setVisible(el.switchCamera, false);
        setVisible(el.zoomGroup, false);

        if (el.manual) {
            el.manual.value = '';
        }

        logEvent('scanner_aberto', { detail: 'modal iniciado' });

        if (!isSecureCameraContext()) {
            running = false;
            setStatus('A câmera só funciona em HTTPS. Acesse pelo endereço seguro do sistema.', 'error');
            logEvent('camera_contexto_inseguro', { detail: location.href });
            return;
        }

        startNativeScanner().catch(function (nativeError) {
            if (!running) return;

            logEvent('camera_nativa_falhou', {
                source: 'native',
                detail: nativeError && nativeError.message ? nativeError.message : 'erro ao abrir nativo'
            });

            stopMediaStream();
            startQuaggaScanner().catch(function (fallbackError) {
                running = false;
                setStatus('Não foi possível abrir a câmera. Verifique a permissão do navegador ou digite a série manualmente.', 'error');
                setVisible(el.video, false);
                setVisible(el.quaggaContainer, false);
                logEvent('camera_falhou', {
                    source: 'quagga',
                    detail: fallbackError && fallbackError.message ? fallbackError.message : 'erro ao abrir fallback'
                });
            });
        });
    }

    function applyManualSerie() {
        var serie = onlyDigits(el.manual && el.manual.value);

        if (serie.length !== 7) {
            setStatus('Digite exatamente os 7 dígitos da série para consultar.', 'error');
            logEvent('serie_manual_invalida', { source: 'manual', serie: serie });
            if (el.manual) {
                el.manual.focus();
            }
            return;
        }

        registerCandidate(serie, 'manual');
    }

    function toggleTorch() {
        if (!supportsTorch(activeTrack)) {
            setStatus('Flash indisponível neste aparelho ou navegador.', 'warning');
            return;
        }

        torchEnabled = !torchEnabled;

        activeTrack.applyConstraints({
            advanced: [{ torch: torchEnabled }]
        }).then(function () {
            refreshTorchButton();
            logEvent('flash_alterado', { detail: torchEnabled ? 'ligado' : 'desligado' });
        }).catch(function () {
            torchEnabled = false;
            refreshTorchButton();
            setStatus('Não foi possível alterar o flash neste aparelho.', 'warning');
        });
    }

    function switchToCamera(deviceId) {
        if (!deviceId || deviceId === selectedDeviceId) return;

        selectedDeviceId = deviceId;
        if (el.cameraSelect) {
            el.cameraSelect.value = selectedDeviceId;
        }

        logEvent('camera_trocada', { detail: 'deviceId alterado' });
        startScanner();
    }

    function switchCamera() {
        if (!availableCameras.length) return;

        var currentIndex = -1;
        availableCameras.forEach(function (camera, index) {
            if (camera.deviceId === selectedDeviceId) {
                currentIndex = index;
            }
        });
        var nextIndex = currentIndex < 0 ? 0 : (currentIndex + 1) % availableCameras.length;
        switchToCamera(availableCameras[nextIndex].deviceId);
    }

    function bindModalEvents() {
        if (window.jQuery) {
            window.jQuery(modalSelector)
                .off('shown.bs.modal.patioScanner hidden.bs.modal.patioScanner')
                .on('shown.bs.modal.patioScanner', startScanner)
                .on('hidden.bs.modal.patioScanner', function () {
                    stopScanner();
                });
        }

        if (el.retry && !el.retry.getAttribute('data-scanner-bound')) {
            el.retry.setAttribute('data-scanner-bound', '1');
            el.retry.addEventListener('click', function () {
                logEvent('scanner_reiniciado', { detail: 'botao reiniciar' });
                startScanner();
            });
        }

        if (el.torch && !el.torch.getAttribute('data-scanner-bound')) {
            el.torch.setAttribute('data-scanner-bound', '1');
            el.torch.addEventListener('click', toggleTorch);
        }

        if (el.switchCamera && !el.switchCamera.getAttribute('data-scanner-bound')) {
            el.switchCamera.setAttribute('data-scanner-bound', '1');
            el.switchCamera.addEventListener('click', switchCamera);
        }

        if (el.cameraSelect && !el.cameraSelect.getAttribute('data-scanner-bound')) {
            el.cameraSelect.setAttribute('data-scanner-bound', '1');
            el.cameraSelect.addEventListener('change', function () {
                switchToCamera(el.cameraSelect.value);
            });
        }

        if (el.zoom && !el.zoom.getAttribute('data-scanner-bound')) {
            el.zoom.setAttribute('data-scanner-bound', '1');
            el.zoom.addEventListener('change', applyZoom);
        }

        if (el.applyManual && !el.applyManual.getAttribute('data-scanner-bound')) {
            el.applyManual.setAttribute('data-scanner-bound', '1');
            el.applyManual.addEventListener('click', applyManualSerie);
        }

        if (el.manual && !el.manual.getAttribute('data-scanner-bound')) {
            el.manual.setAttribute('data-scanner-bound', '1');
            el.manual.addEventListener('keydown', function (event) {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    applyManualSerie();
                }
            });

            el.manual.addEventListener('input', function () {
                el.manual.value = onlyDigits(el.manual.value).substring(0, 7);

                if (manualAutoTimer) {
                    window.clearTimeout(manualAutoTimer);
                }

                if (el.manual.value.length === 7) {
                    setStatus('Série completa. Consultando automaticamente...', 'info');
                    manualAutoTimer = window.setTimeout(applyManualSerie, 450);
                }
            });
        }
    }

    function bindMainInput() {
        if (!el.input || el.input.getAttribute('data-scanner-main-bound')) {
            return;
        }

        el.input.setAttribute('data-scanner-main-bound', '1');
        el.input.setAttribute('autocomplete', 'off');

        el.input.addEventListener('input', function () {
            if (suppressMainAutoSearch) return;

            var cleaned = onlyDigits(el.input.value).substring(0, 7);
            if (el.input.value !== cleaned) {
                el.input.value = cleaned;
            }

            if (mainInputTimer) {
                window.clearTimeout(mainInputTimer);
            }

            if (cleaned.length === 7) {
                mainInputTimer = window.setTimeout(function () {
                    logEvent('serie_digitada_auto', { source: 'digitacao', serie: cleaned });
                    triggerSearch();
                }, 550);
            }
        });
    }

    function bindEvents() {
        bindModalEvents();
        bindMainInput();

        if (window.Sys && window.Sys.WebForms && window.Sys.WebForms.PageRequestManager) {
            var prm = window.Sys.WebForms.PageRequestManager.getInstance();
            if (prm && !window.__patioScannerEndRequestBound) {
                window.__patioScannerEndRequestBound = true;
                prm.add_endRequest(function () {
                    cacheElements();
                    bindMainInput();
                });
            }
        }
    }

    function init() {
        cacheElements();
        bindEvents();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
