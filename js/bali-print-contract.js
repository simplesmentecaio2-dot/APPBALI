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

    function textoPorId(id) {
        return obterTextoElemento(document.getElementById(id)).replace(/\s+/g, ' ').replace(/^\s+|\s+$/g, '');
    }

    function primeiroTexto(ids) {
        for (var i = 0; i < ids.length; i++) {
            var texto = textoPorId(ids[i]);
            if (texto && texto.toLowerCase() !== 'label') return texto;
        }
        return '-';
    }

    function escaparHtml(texto) {
        return String(texto || '-')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function linhaChecklist(texto, classeExtra) {
        var classe = 'bali-guide3-row' + (classeExtra ? ' ' + classeExtra : '');
        return '<div class="' + classe + '"><span class="bali-guide3-check"></span><span>' + texto + '</span></div>';
    }

    function atualizarAnoAtual() {
        var ano = String(new Date().getFullYear());
        var campos = document.querySelectorAll('.bali-current-year');
        for (var i = 0; i < campos.length; i++) {
            definirTextoElemento(campos[i], ano);
        }
    }

    function criarGuiaCompradorHtml() {
        if (document.getElementById('guiadocomprador3')) return;

        var caminho = (window.location.pathname || '').toLowerCase();
        var guiaMarca = caminho.indexOf('/jeep/') >= 0 ? {
            slug: 'jeep',
            nome: 'JEEP',
            logo: 'BALI JEEP',
            empresa: 'Bali Motors Ltda.',
            empresaAlta: 'BALI MOTORS',
            cnpj: '36.444.055/0001-38',
            cor: '#1f3f2d'
        } : (caminho.indexOf('/byd/') >= 0 ? {
            slug: 'byd',
            nome: 'BYD',
            logo: 'BALI BYD',
            empresa: 'Bali Eletrics Ltda.',
            empresaAlta: 'BALI ELETRICS',
            cnpj: '54.168.855/0001-55',
            cor: '#1d4f8f'
        } : {
            slug: 'fiat',
            nome: 'FIAT',
            logo: 'BALI FIAT',
            empresa: 'Bali Bras&iacute;lia Autom&oacute;veis Ltda.',
            empresaAlta: 'BALI BRAS&Iacute;LIA AUTOM&Oacute;VEIS',
            cnpj: '72.624.521/0001-20',
            cor: '#b21f3a'
        });

        var guiaBase = document.getElementById('guiadocomprador2') || document.getElementById('guiadocomprador');
        var guiaOriginal = document.getElementById('guiadocomprador');
        var guiaOriginal2 = document.getElementById('guiadocomprador2');
        if (!guiaBase) return;

        var cliente = primeiroTexto(['lbldeclaracaocliente', 'lbldeclaracaocliente2']);
        var cpf = primeiroTexto(['lbldeclaracaocpf2', 'lbldeclaracaocpf22']);
        var data = primeiroTexto(['lbldeclaracaodata', 'lbldeclaracaodata2']);
        var veiculo = primeiroTexto(['lbldeclaracaoveiculo', 'lbldeclaracaoveiculo2']);
        var placa = primeiroTexto(['lbleclaracaoplaca', 'lbleclaracaoplaca2']);
        var anoAtual = new Date().getFullYear();

        function cabecalhoGuia() {
            if (guiaMarca.slug === 'fiat') {
                return [
                    '<div class="bali-guide3-header">',
                        '<div class="bali-guide3-logo"><span class="bali-guide3-slashes">////</span><strong>BALI</strong><small>FIAT</small></div>',
                        '<div class="bali-guide3-phones">',
                            '<span>SIA (MATRIZ)<strong>(61) 3362-6200</strong></span>',
                            '<span>CIDADE DO AUTOM&Oacute;VEL<strong>(61) 3363-9099</strong></span>',
                            '<span>SAAN<strong>(61) 3213-7800</strong></span>',
                        '</div>',
                        '<div class="bali-guide3-brand">FIAT</div>',
                    '</div>'
                ].join('');
            }

            return [
                '<div class="bali-guide3-header bali-guide3-header-simple">',
                    '<div class="bali-guide3-logo"><strong>' + guiaMarca.logo + '</strong></div>',
                    '<div class="bali-guide3-brand">' + guiaMarca.nome + '</div>',
                '</div>'
            ].join('');
        }

        function documentosGuia() {
            return [
                '<div class="bali-guide3-docs">',
                    '<div class="bali-guide3-title">DOCUMENTA&Ccedil;&Atilde;O NECESS&Aacute;RIA DO CLIENTE</div>',
                    linhaChecklist('C&Oacute;PIA CNH (CARTEIRA DE HABILITA&Ccedil;&Atilde;O)'),
                    linhaChecklist('COMPROVANTE DE RESID&Ecirc;NCIA atualizado, preferencialmente com consumo recente e em nome do cliente ou com v&iacute;nculo comprovado.'),
                    linhaChecklist('CPF/CNPJ, contrato social, procura&ccedil;&atilde;o ou documento de representa&ccedil;&atilde;o, quando aplic&aacute;vel.'),
                    linhaChecklist('COMPROVANTE DE RENDA, IR ou documentos complementares quando exigidos pela financeira, pela concession&aacute;ria ou pelo procedimento interno.'),
                    '<div class="bali-guide3-title">DOCUMENTA&Ccedil;&Atilde;O FINANCEIRA / OPERACIONAL</div>',
                    linhaChecklist('CONTRATO DO BANCO assinado, quando houver financiamento, cons&oacute;rcio, leasing ou opera&ccedil;&atilde;o equivalente.'),
                    linhaChecklist('Comprovantes de pagamento, quita&ccedil;&atilde;o, aprova&ccedil;&atilde;o financeira e demais documentos devem estar leg&iacute;veis e compat&iacute;veis com a negocia&ccedil;&atilde;o.'),
                '</div>'
            ].join('');
        }

        function dadosGuia() {
            if (veiculo || placa) {
                return '<table class="bali-guide3-data"><tr><td><strong>Cliente:</strong> <strong>' + escaparHtml(cliente) + '</strong></td><td><strong>CPF/CNPJ:</strong> <strong>' + escaparHtml(cpf) + '</strong></td></tr><tr><td><strong>Ve&iacute;culo seminovo:</strong> <strong>' + escaparHtml(veiculo) + '</strong></td><td><strong>Placa:</strong> <strong>' + escaparHtml(placa) + '</strong></td></tr></table>';
            }

            return '<table class="bali-guide3-data"><tr><td><strong>Cliente:</strong> <strong>' + escaparHtml(cliente) + '</strong></td><td><strong>CPF/CNPJ:</strong> <strong>' + escaparHtml(cpf) + '</strong></td></tr></table>';
        }

        function montarGuia(viaTexto) {
            return [
            '<div class="bali-guide3-page bali-guide3-page-' + guiaMarca.slug + '" style="--bali-guide-brand:' + guiaMarca.cor + '">',
                cabecalhoGuia(),
                '<div class="bali-guide3-copy">' + viaTexto + '</div>',
                documentosGuia(),
                '<div class="bali-guide3-alert">',
                    '<span class="bali-guide3-check"></span>',
                    '<span>Todo ve&iacute;culo usado entregue como parte de pagamento deve passar por confer&ecirc;ncia documental e vistoria cautelar pr&eacute;via. O custo, quando aplic&aacute;vel, &eacute; de responsabilidade do cliente.</span>',
                '</div>',
                '<div class="bali-guide3-subtitle">RECEBIMENTO DO VE&Iacute;CULO USADO INCLUSO COMO PARTE DE PAGAMENTO <span>PLACA: ' + escaparHtml(placa) + '</span></div>',
                '<div class="bali-guide3-list">',
                    linhaChecklist('VE&Iacute;CULO SEM RESERVA OU CDC: DUT/CRV em branco, 2 vias da procura&ccedil;&atilde;o p&uacute;blica para ' + guiaMarca.empresa + ', CNPJ ' + guiaMarca.cnpj + ', sem vedar substabelecimento e sem data de vencimento.'),
                    linhaChecklist('VE&Iacute;CULO COM LEASING: DUT/CRV em branco, 2 vias da procura&ccedil;&atilde;o p&uacute;blica para ' + guiaMarca.empresa + ', sem vedar substabelecimento, sem data de vencimento e com reconhecimento de firma quando exigido.'),
                    linhaChecklist('LEASING BANCO FIAT/ITA&Uacute;: a procura&ccedil;&atilde;o deve ser emitida conforme exig&ecirc;ncia do banco/cart&oacute;rio, dentro do prazo de validade e acompanhada do DUT/CRV em branco.'),
                    linhaChecklist('LEASING FINASA/BRADESCO OU OUTROS BANCOS: apresentar DUT/CRV em branco, procura&ccedil;&atilde;o p&uacute;blica, termo de repasse quando houver e reconhecimento de firma da assinatura do cliente.'),
                    linhaChecklist('<strong>LICENCIAMENTO (DOCUMENTO F&Iacute;SICO)</strong> - IPVA <strong class="bali-guide3-year">' + anoAtual + '</strong>, licenciamento, seguro obrigat&oacute;rio e demais encargos devem estar pagos ou regularizados. Parcelamentos e d&iacute;vidas ativas s&atilde;o de responsabilidade do cliente.'),
                    linhaChecklist('MULTAS, AUTUA&Ccedil;&Otilde;ES, NOTIFICA&Ccedil;&Otilde;ES, DEFESA PR&Eacute;VIA, SUB JUDICE OU QUALQUER RESTRI&Ccedil;&Atilde;O devem ser regularizadas antes da entrega do ve&iacute;culo &agrave; Bali.'),
                    linhaChecklist('QUITAR D&Eacute;BITOS junto ao DETRAN, DNIT, DPRF, DER, AGETOP-GO e demais &oacute;rg&atilde;os de tr&acirc;nsito em n&iacute;vel municipal, estadual ou nacional.'),
                    linhaChecklist('VE&Iacute;CULOS DE OUTRA UF dever&atilde;o estar aptos para transfer&ecirc;ncia e poder&atilde;o exigir regulariza&ccedil;&atilde;o adicional antes do recebimento pela Bali.'),
                    linhaChecklist('VE&Iacute;CULO COM ALIENA&Ccedil;&Atilde;O FIDUCI&Aacute;RIA somente ser&aacute; recebido ap&oacute;s quita&ccedil;&atilde;o e baixa do gravame, quando financiado ou quitado pelo propriet&aacute;rio/cliente.'),
                    linhaChecklist('VE&Iacute;CULO COM GNV ser&aacute; recebido somente com certificado dentro da validade e documenta&ccedil;&atilde;o compat&iacute;vel com o cadastro do DETRAN.'),
                    linhaChecklist('PESSOA JUR&Iacute;DICA com valor de venda acima de R$ 50.000,00 dever&aacute; apresentar certid&atilde;o negativa ou comprova&ccedil;&atilde;o exigida pelos &oacute;rg&atilde;os competentes, quando aplic&aacute;vel.'),
                    linhaChecklist('VE&Iacute;CULO ENCOMENDADO OU SEM ESTOQUE IMEDIATO: se houver seminovo como parte de pagamento, o IPVA <strong class="bali-guide3-year">' + anoAtual + '</strong> dever&aacute; estar pago ou regularizado conforme vencimento das cotas.'),
                    linhaChecklist('Diverg&ecirc;ncias de chassi, placa, quilometragem, motor, cor, avarias, acess&oacute;rios ou qualquer dado relevante poder&atilde;o suspender o recebimento at&eacute; nova confer&ecirc;ncia.'),
                    linhaChecklist('O cliente declara que os documentos apresentados e as informa&ccedil;&otilde;es prestadas s&atilde;o verdadeiros, completos e compat&iacute;veis com a negocia&ccedil;&atilde;o.'),
                    linhaChecklist('A Bali poder&aacute; recusar ou suspender o recebimento do ve&iacute;culo usado se houver diverg&ecirc;ncia documental, restri&ccedil;&atilde;o cadastral, d&eacute;bito pendente, avaria n&atilde;o informada ou aus&ecirc;ncia de item obrigat&oacute;rio.'),
                '</div>',
                '<div class="bali-guide3-title bali-guide3-title-required">ITENS OBRIGAT&Oacute;RIOS DO VE&Iacute;CULO.</div>',
                '<div class="bali-guide3-required">',
                    '<div class="bali-guide3-required-list">',
                        linhaChecklist('MANUAL') + linhaChecklist('CHAVE SIMPLES/RESERVA') + linhaChecklist('CART&Atilde;O CODE, QUANDO HOUVER') + linhaChecklist('CHAVE CANIVETE OU CHAVE PRESENCIAL') + linhaChecklist('MACACO, CHAVE DE RODA, TRI&Acirc;NGULO E ESTEPE/KIT REPARO'),
                    '</div>',
                    '<div class="bali-guide3-values">',
                        '<strong>NA FALTA DE ALGUNS ITENS, OS VALORES S&Atilde;O:</strong>',
                        '<span>MANUAL, CONSULTAR.</span>',
                        '<span>CHAVE SIMPLES RESERVA, CONSULTAR.</span>',
                        '<span>CART&Atilde;O CODE, CONSULTAR.</span>',
                        '<span>CHAVE CANIVETE OU PRESENCIAL, CONSULTAR.</span>',
                    '</div>',
                '</div>',
                '<div class="bali-guide3-title bali-guide3-title-small">TAXAS</div>',
                '<div class="bali-guide3-fees">',
                    linhaChecklist('2&ordf; VIA DO DUT R$ 450,00 (QUATROCENTOS E CINQUENTA REAIS)'),
                    linhaChecklist('1&ordf; TRANSFER&Ecirc;NCIA R$ 1.200,00'),
                    linhaChecklist('2&ordf; VIA DE LICENCIAMENTO R$ 250,00 (DUZENTOS E CINQUENTA REAIS)'),
                    linhaChecklist('<strong>VALOR CAUTELAR R$ 350,00</strong>'),
                    linhaChecklist('<strong>TRANSFER&Ecirc;NCIA DE UF: R$ 1.200,00</strong>'),
                '</div>',
                '<div class="bali-guide3-title bali-guide3-title-small">IDENTIFICA&Ccedil;&Atilde;O DO CLIENTE E VE&Iacute;CULO SEMINOVO</div>',
                dadosGuia(),
                '<div class="bali-guide3-warning"><strong>ATEN&Ccedil;&Atilde;O:</strong> a entrega ou retirada do ve&iacute;culo usado e/ou do CRLV ser&aacute; realizada somente ao propriet&aacute;rio. No caso de retirada por terceiro, &eacute; obrigat&oacute;ria autoriza&ccedil;&atilde;o do propriet&aacute;rio com firma reconhecida em cart&oacute;rio, acompanhada de documento oficial de identifica&ccedil;&atilde;o.</div>',
                '<div class="bali-guide3-signature"><div class="bali-guide3-sign-date">Bras&iacute;lia, <strong>' + escaparHtml(data) + '</strong></div><span></span><strong class="bali-guide3-sign-name">' + escaparHtml(String(cliente || '-').toUpperCase()) + '</strong><small>Cliente/Propriet&aacute;rio</small></div>',
            '</div>'
            ].join('');
        }

        if (guiaBase.parentNode) {
            var parent = guiaBase.parentNode;
            var secao = criarElemento('section', 'bali-guide3');
            var secao2 = criarElemento('section', 'bali-guide3');
            secao.id = 'guiadocomprador3';
            secao2.id = 'guiadocomprador3b';
            secao.innerHTML = montarGuia('1&ordf; VIA - CLIENTE/PROPRIET&Aacute;RIO');
            secao2.innerHTML = montarGuia('2&ordf; VIA - ARQUIVO INTERNO');
            parent.insertBefore(secao, guiaBase.nextSibling);
            parent.insertBefore(secao2, secao.nextSibling);

            if (guiaOriginal && guiaOriginal.parentNode) guiaOriginal.parentNode.removeChild(guiaOriginal);
            if (guiaOriginal2 && guiaOriginal2.parentNode) guiaOriginal2.parentNode.removeChild(guiaOriginal2);
        }
    }

    function criarDespachanteHtml() {
        var painel = document.getElementById('Panel1');
        var pagina = document.getElementById('Div5');
        if (!painel || !pagina || pagina.getAttribute('data-despachante-html') === '1') return;

        var imagemFinal = pagina.querySelector('img[src*="DESPACHANTEFINAL"]');
        var usado = !!(imagemFinal && /FINALUSADO/i.test(imagemFinal.getAttribute('src') || ''));
        var caminho = (window.location.pathname || '').toLowerCase();
        var marca = caminho.indexOf('/jeep/') >= 0 ? 'JEEP' : (caminho.indexOf('/byd/') >= 0 ? 'BYD' : 'FIAT');

        var nome = primeiroTexto(['txtdespachanteNOME']);
        var rg = primeiroTexto(['txtdespachanteRG']);
        var cpf = primeiroTexto(['txtdespachanteCPF']);
        var endereco = primeiroTexto(['txtdespachanteENDERECO']);
        var cep = primeiroTexto(['txtdespachanteCEP']);
        var email = primeiroTexto(['txtdespachanteEMAIL']);
        var fone = primeiroTexto(['txtdespachanteFONE']);
        var chassi = primeiroTexto(['txtdespachanteCHASSI', 'txtdespachantePLACA']);
        var modelo = primeiroTexto(['txtdespachanteMODELO']);
        var anoModelo = primeiroTexto(['txtdespachanteANOMODELO']);
        var modeloCompleto = (usado ? '' : marca + '- ') + modelo;

        function valor(texto) {
            return escaparHtml(texto || '');
        }

        function item(marcado, texto, destaque) {
            return '<div class="bali-despachante-option"><span>(' + (marcado ? 'X' : '&nbsp;') + ')</span><strong class="' + (destaque ? 'is-strong' : '') + '">' + texto + '</strong></div>';
        }

        function dataAtualNumerica() {
            var hoje = new Date();
            var dia = ('0' + hoje.getDate()).slice(-2);
            var mes = ('0' + (hoje.getMonth() + 1)).slice(-2);
            return dia + '/' + mes + '/' + hoje.getFullYear();
        }

        pagina.className = normalizarClasse((pagina.className || '') + ' bali-despachante-page');
        pagina.setAttribute('data-despachante-html', '1');
        pagina.removeAttribute('style');
        pagina.innerHTML = [
            '<img class="bali-despachante-header-img" src="../img/DESPACHANTECABECALHO.png" alt="Governo do Distrito Federal - Detran DF - VE 15" />',
            '<table class="bali-despachante-table bali-despachante-service">',
                '<tr><th colspan="4">SOLICITA&Ccedil;&Atilde;O DO SERVI&Ccedil;O</th></tr>',
                '<tr>',
                    '<td colspan="2" class="wide"><span>NOME:</span> <strong>' + valor(nome) + '</strong></td>',
                    '<td rowspan="2" class="label-center">PROCURADOR:</td>',
                    '<td class="checkline">SIM( )</td>',
                '</tr>',
                '<tr><td colspan="2">&nbsp;</td><td class="checkline">N&Atilde;O( )</td></tr>',
                '<tr><td colspan="2"><span>RG:</span> <strong>' + valor(rg) + '</strong></td><td colspan="2"><span>CPF/CNPJ:</span> <strong>' + valor(cpf) + '</strong></td></tr>',
                '<tr><td colspan="4"><span>&Oacute;RG&Atilde;O EXPEDIDOR:</span></td></tr>',
                '<tr><td colspan="4"><span>ENDERE&Ccedil;O:</span> <strong>' + valor(endereco) + '</strong></td></tr>',
                '<tr><td colspan="4"><span>CEP:</span> <strong>' + valor(cep) + '</strong></td></tr>',
                '<tr><td colspan="2"><span>E-MAIL:</span> <strong>' + valor(email) + '</strong></td><td colspan="2"><span>FONE:</span> <strong>' + valor(fone) + '</strong></td></tr>',
                '<tr><th colspan="4">DADOS DO VE&Iacute;CULO</th></tr>',
                '<tr><td colspan="2"><span>CHASSI:</span> <strong>' + valor(chassi) + '</strong></td><td colspan="2"><span>PLACA:</span></td></tr>',
                '<tr><td colspan="2"><span>MARCA/MODELO:</span> <strong>' + valor(modeloCompleto) + '</strong></td><td colspan="2"><span>ANO FAB:</span> <strong>' + valor(anoModelo) + '</strong></td></tr>',
                '<tr><td colspan="4"><span>RENAVAM:</span><span class="bali-despachante-line"></span></td></tr>',
            '</table>',
            '<div class="bali-despachante-request">',
                '<div class="bali-despachante-request-title">OBJETO DO REQUERIMENTO</div>',
                '<p>Autorizo os despachantes <span class="under">WILLIAN WASTON DA SILVA</span> e <span class="under">FERNANDO ALVES RAFAEL DE SOUZA</span></p>',
                '<p><strong>RG.:</strong> <span class="under small">611451 DF</span> e <span class="under small">2222922 DF</span> <strong>CPF:</strong> <span class="under small">226.954.001-87</span> e <span class="under small">010.613.891-03</span> <strong>CREDENCIAL N&ordm;:</strong> <span class="under tiny">63</span> e <span class="under tiny">476</span></p>',
                '<p>a representar-me junto ao DETRAN-DF para atualiza&ccedil;&atilde;o do meu endere&ccedil;o, conforme artigos 241 e 242 do CTB e Lei Distrital n&ordm; 4.225, de 24/10/2008, conforme dados descritos acima do ve&iacute;culo de minha propriedade.</p>',
                item(!usado, 'Primeiro emplacamento/registrar o ve&iacute;culo', false),
                item(usado, 'Promover a transfer&ecirc;ncia da propriedade', false),
                item(false, 'Emitir CRV e/ou CRLV', false),
                item(false, 'Realizar vistorias e/ou inspe&ccedil;&atilde;o', false),
                item(false, 'Outros servi&ccedil;os:', true),
            '</div>',
            '<p class="bali-despachante-declaration">Declaro sob as penas da lei que o contido acima &eacute; a express&atilde;o da verdade, assumindo todos e quaisquer &ocirc;nus decorrentes deste ato, isentando o <strong>DETRAN-DF</strong> e seus prepostos das responsabilidades de natureza <strong>C&Iacute;VIL, PENAL E/OU ADMINISTRATIVA</strong>, resultante desta solicita&ccedil;&atilde;o.</p>',
            '<div class="bali-despachante-date"><span>Bras&iacute;lia &ndash; DF,</span><strong>' + dataAtualNumerica() + '</strong></div>',
            '<div class="bali-despachante-sign"><span></span><p>Assinatura do Propriet&aacute;rio/Representante legal</p></div>',
            '<p class="bali-despachante-presence"><strong>Declaro que este documento foi assinado em minha presen&ccedil;a pelo propriet&aacute;rio acima identificado.</strong></p>',
            '<div class="bali-despachante-sign bali-despachante-sign-final"><span></span><p>Carimbo e assinatura do despachante</p></div>'
        ].join('');
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
        atualizarAnoAtual();
        criarGuiaCompradorHtml();
        criarDespachanteHtml();
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
