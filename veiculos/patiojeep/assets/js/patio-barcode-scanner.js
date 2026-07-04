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
            el.result.textContent = serie ? 'Série detectada: ' + serie : '';
        }

        if (el.lastRaw) {
            el.lastRaw.textContent = raw ? 'Código lido: ' + raw : '';
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
            } catch (ignore) {
                // O Quagga pode lançar erro caso já esteja parado.
            }
        }

        quaggaRunning = false;

        if (el.quaggaContainer) {
            el.quaggaContainer.innerHTML = '';
        }
    }

    function stopScanner() {
        running = false;
        locked = false;
        nativeDetector = null;

        if (nativeTimer) {
            window.clearTimeout(nativeTimer);
            nativeTimer = null;
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
    }

    function triggerSearch() {
        if (el.input) {
            try {
                el.input.dispatchEvent(new Event('input', { bubbles: true }));
                el.input.dispatchEvent(new Event('change', { bubbles: true }));
            } catch (ignore) {
                // Fallback abaixo cobre navegadores antigos.
            }
        }

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

        if (window.navigator && window.navigator.vibrate) {
            window.navigator.vibrate(80);
        }

        if (el.input) {
            el.input.value = serie;
        }

        stopScanner();

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

    function startQuaggaScanner() {
        return new Promise(function (resolve, reject) {
            if (!window.Quagga) {
                reject(new Error('Biblioteca do leitor não encontrada.'));
                return;
            }

            setVisible(el.video, false);
            setVisible(el.quaggaContainer, true);
            setEngine('Leitor compatível');
            setStatus('Abrindo câmera. Se solicitado, permita o acesso.', 'info');

            window.Quagga.init({
                inputStream: {
                    name: 'Live',
                    type: 'LiveStream',
                    target: el.quaggaContainer,
                    constraints: {
                        facingMode: 'environment',
                        width: { ideal: 1280 },
                        height: { ideal: 720 }
                    },
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
                    setStatus('Aponte a câmera para o código de barras. Centralize na linha clara.', 'info');
                    resolve();
                } catch (startError) {
                    reject(startError);
                }
            });
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

        setVisible(el.quaggaContainer, false);
        setVisible(el.video, true);
        setEngine('Leitor do navegador');
        setStatus('Abrindo câmera. Se solicitado, permita o acesso.', 'info');

        return getSupportedNativeFormats().then(function (formats) {
            nativeDetector = new window.BarcodeDetector({ formats: formats });

            return navigator.mediaDevices.getUserMedia({
                video: {
                    facingMode: { ideal: 'environment' },
                    width: { ideal: 1280 },
                    height: { ideal: 720 }
                },
                audio: false
            });
        }).then(function (mediaStream) {
            stream = mediaStream;
            activeTrack = stream.getVideoTracks()[0] || null;

            if (el.video) {
                el.video.srcObject = stream;
                return el.video.play();
            }
        }).then(function () {
            refreshTorchButton();
            setStatus('Aponte a câmera para o código de barras. Centralize na linha clara.', 'info');
            nativeScanLoop();
        });
    }

    function startScanner() {
        cacheElements();
        stopScanner();
        resetCandidate();
        locked = false;
        running = true;
        torchEnabled = false;

        setResult('', '');
        setEngine('Câmera');

        if (el.manual) {
            el.manual.value = '';
        }

        if (!isSecureCameraContext()) {
            running = false;
            setStatus('A câmera só funciona em HTTPS. Acesse pelo endereço seguro do sistema.', 'error');
            return;
        }

        startNativeScanner().catch(function () {
            if (!running) return;

            stopMediaStream();
            startQuaggaScanner().catch(function () {
                running = false;
                setStatus('Não foi possível abrir a câmera. Verifique a permissão do navegador ou digite a série manualmente.', 'error');
                setVisible(el.video, false);
                setVisible(el.quaggaContainer, false);
            });
        });
    }

    function applyManualSerie() {
        var serie = onlyDigits(el.manual && el.manual.value);

        if (serie.length !== 7) {
            setStatus('Digite exatamente os 7 dígitos da série para consultar.', 'error');
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
        }).catch(function () {
            torchEnabled = false;
            refreshTorchButton();
            setStatus('Não foi possível alterar o flash neste aparelho.', 'warning');
        });
    }

    function bindEvents() {
        if (window.jQuery) {
            window.jQuery(modalSelector)
                .off('shown.bs.modal.patioScanner hidden.bs.modal.patioScanner')
                .on('shown.bs.modal.patioScanner', startScanner)
                .on('hidden.bs.modal.patioScanner', stopScanner);
        }

        if (el.retry) {
            el.retry.addEventListener('click', function () {
                startScanner();
            });
        }

        if (el.torch) {
            el.torch.addEventListener('click', toggleTorch);
        }

        if (el.applyManual) {
            el.applyManual.addEventListener('click', applyManualSerie);
        }

        if (el.manual) {
            el.manual.addEventListener('keydown', function (event) {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    applyManualSerie();
                }
            });

            el.manual.addEventListener('input', function () {
                el.manual.value = onlyDigits(el.manual.value).substring(0, 7);
            });
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
