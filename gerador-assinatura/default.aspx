<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="veiculos_Pint_Contrato" %>

    <%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

        <!DOCTYPE html>

        <html xmlns="http://www.w3.org/1999/xhtml">

        <head runat="server">
            <title>Gerador de Assinatura | APP Bali</title>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <!--===============================================================================================-->
            <link rel="icon" type="image/png" href="" />
            <!--===============================================================================================-->
            <link rel="stylesheet" type="text/css" href="../veiculos/vendor/bootstrap/css/bootstrap.min.css">
            <!--===============================================================================================-->
            <link rel="stylesheet" type="text/css" href="../veiculos/fonts/font-awesome-4.7.0/css/font-awesome.min.css">
            <!--===============================================================================================-->
            <link rel="stylesheet" type="text/css" href="../veiculos/css/util.css">
            <link rel="stylesheet" type="text/css" href="../veiculos/css/main.css">
            <!--===============================================================================================-->


            <!-- adicionado 12/11/2024 -->
            <style>
                /*DINNextLTPro-Bold.ttf*/
                @font-face {
                    font-family: din-bold;
                    src: url('https://app.bali.com.br/gerador-assinatura/resources/fonts/DINNextLTPro-Bold.ttf');
                }

                /*DINNextLTPro-Medium.ttf*/
                @font-face {
                    font-family: din-medium;
                    src: url('https://app.bali.com.br/gerador-assinatura/resources/fonts/fonnts.com-DINNextLTPro-Medium.ttf') format('truetype');
                }

                /*DINNextLTPro-Regular.ttf*/
                @font-face {
                    font-family: din-regular;
                    src: url('https://app.bali.com.br/gerador-assinatura/resources/fonts/fonnts.com-DINNextLTPro-Regular.ttf') format('truetype');
                }

                .assinatura-grupo-bali {
                    background-image: url('https://app.bali.com.br/gerador-assinatura/resources/headers/grupobali.jpg');
                    background-size: cover;
                    background-position: center;
                    background-repeat: no-repeat;
                    height: 110px;
                    width: 600px;
                    padding: 0;
                    margin: 0;
                    position: relative;

                    /*sombra*/
                    box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
                }

                .nome-grupo-bali {

                    position: absolute;
                    left: 266px;
                    top: 15px;
                    font-size: 15.7px;
                    font-weight: bolder;
                    font-family: din-medium;

                    /*não deixa o texto quebrar a linha*/
                    white-space: nowrap;
                    letter-spacing: 0.5;
                    /*estica o texto verticalmente*/
                    transform: scaleY(1.0);

                }

                .cargo-grupo-bali {
                    text-transform: uppercase;
                    position: absolute;
                    left: 266px;
                    top: 34px;
                    font-size: 10px;
                    font-family: din-medium;
                    color: gray;
                    /*espaço entre as letras*/
                    letter-spacing: 2px;

                    white-space: nowrap;

                }

                .ddd-grupo-bali {
                    position: absolute;
                    left: 481px;
                    top: 25px;
                    font-size: 10px;
                    font-weight: bold;
                    font-family: din-bold;

                    white-space: nowrap;
                }

                .telefone-grupo-bali {
                    position: absolute;
                    left: 493px;
                    top: 21px;
                    font-size: 17px;
                    font-weight: bold;
                    font-family: din-bold;

                    white-space: nowrap;
                }


                :root {
                    --assinatura-bg: #f4f7fb;
                    --assinatura-card: #ffffff;
                    --assinatura-text: #172033;
                    --assinatura-muted: #64748b;
                    --assinatura-line: #dbe4f0;
                    --assinatura-primary: #233b68;
                    --assinatura-primary-soft: #e8eef8;
                    --assinatura-accent: #0f9f6e;
                    --assinatura-shadow: 0 18px 45px rgba(15, 23, 42, 0.10);
                }

                body.signature-page {
                    min-height: 100vh;
                    background:
                        radial-gradient(circle at top left, rgba(35, 59, 104, 0.13), transparent 34%),
                        linear-gradient(135deg, #f7f9fc 0%, #edf2f8 100%);
                    color: var(--assinatura-text);
                    font-family: Arial, Helvetica, sans-serif;
                }

                .signature-page .limiter,
                .signature-page .container-login100 {
                    width: 100%;
                    min-height: 100vh;
                    background: transparent;
                }

                .signature-page .container-login100 {
                    padding: 32px 18px;
                    align-items: flex-start;
                }

                .signature-page .container-login100::before {
                    display: none;
                }

                .signature-page-shell {
                    width: min(1180px, 100%);
                    margin: 0 auto;
                }

                .signature-form-shell {
                    width: 100%;
                    border: 0;
                    border-radius: 22px;
                    background: transparent;
                    box-shadow: none;
                }

                .signature-hero {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    gap: 18px;
                    margin-bottom: 18px;
                    padding: 26px 28px;
                    color: #fff;
                    border-radius: 24px;
                    background:
                        linear-gradient(135deg, rgba(18, 31, 55, 0.96), rgba(35, 59, 104, 0.94)),
                        radial-gradient(circle at 82% 22%, rgba(255, 255, 255, 0.18), transparent 28%);
                    box-shadow: var(--assinatura-shadow);
                }

                .signature-eyebrow {
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    margin-bottom: 8px;
                    font-size: 11px;
                    font-weight: 800;
                    letter-spacing: 0.12em;
                    text-transform: uppercase;
                    color: rgba(255, 255, 255, 0.72);
                }

                .signature-hero h1 {
                    margin: 0;
                    font-size: clamp(26px, 3vw, 40px);
                    line-height: 1.05;
                    font-weight: 900;
                    letter-spacing: 0;
                }

                .signature-hero p {
                    max-width: 680px;
                    margin: 10px 0 0;
                    color: rgba(255, 255, 255, 0.76);
                    font-size: 15px;
                    line-height: 1.6;
                }

                .signature-back-link {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    min-height: 42px;
                    padding: 0 18px;
                    color: #fff;
                    border: 1px solid rgba(255, 255, 255, 0.25);
                    border-radius: 999px;
                    background: rgba(255, 255, 255, 0.10);
                    font-size: 13px;
                    font-weight: 800;
                    text-decoration: none;
                    white-space: nowrap;
                    transition: transform .18s ease, background .18s ease;
                }

                .signature-back-link:hover,
                .signature-back-link:focus {
                    color: #fff;
                    background: rgba(255, 255, 255, 0.18);
                    text-decoration: none;
                    transform: translateY(-1px);
                }

                .signature-generator {
                    width: 100%;
                    max-width: none;
                    padding: 0;
                }

                .signature-grid {
                    display: grid;
                    grid-template-columns: minmax(320px, 0.92fr) minmax(360px, 1.08fr);
                    gap: 18px;
                    margin: 0;
                }

                .signature-grid > .col-md-6,
                .signature-grid > .col-md-12 {
                    width: auto;
                    max-width: none;
                    flex: initial;
                    float: none;
                    position: static;
                    padding-right: 0;
                    padding-left: 0;
                }

                .signature-page .d-none {
                    display: none !important;
                }

                .signature-panel {
                    min-width: 0;
                    padding: 24px;
                    border: 1px solid var(--assinatura-line);
                    border-radius: 20px;
                    background: rgba(255, 255, 255, 0.92);
                    box-shadow: 0 12px 34px rgba(15, 23, 42, 0.08);
                }

                .signature-panel-title {
                    display: flex;
                    align-items: flex-start;
                    justify-content: space-between;
                    gap: 16px;
                    margin-bottom: 22px;
                    padding-bottom: 16px;
                    border-bottom: 1px solid var(--assinatura-line);
                }

                .signature-panel-title h2 {
                    margin: 0;
                    color: var(--assinatura-text);
                    font-size: 22px;
                    font-weight: 900;
                    letter-spacing: 0;
                }

                .signature-panel-title span,
                .signature-panel-title p {
                    margin: 5px 0 0;
                    color: var(--assinatura-muted);
                    font-size: 13px;
                    line-height: 1.4;
                }

                .signature-step-badge {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    height: 32px;
                    min-width: 32px;
                    padding: 0 12px;
                    border-radius: 999px;
                    background: var(--assinatura-primary-soft);
                    color: var(--assinatura-primary);
                    font-size: 12px;
                    font-weight: 900;
                }

                .signature-panel-title .signature-step-badge {
                    margin: 0;
                    color: var(--assinatura-primary);
                }

                .signature-field-grid {
                    display: grid;
                    grid-template-columns: repeat(2, minmax(0, 1fr));
                    gap: 14px;
                }

                .signature-field {
                    min-width: 0;
                }

                .signature-field-full {
                    grid-column: 1 / -1;
                }

                .signature-label {
                    display: block;
                    margin: 0 0 7px;
                    color: #53617a;
                    font-size: 11px;
                    font-weight: 900;
                    letter-spacing: 0.08em;
                    text-transform: uppercase;
                }

                .signature-required {
                    color: #c4313b;
                    font-style: normal;
                }

                .signature-page .signature-control {
                    width: 100%;
                    height: 46px;
                    padding: 0 14px;
                    border: 1px solid #cfd9e8;
                    border-radius: 12px;
                    background-color: #fff;
                    color: var(--assinatura-text);
                    font-size: 15px;
                    font-weight: 700;
                    box-shadow: none;
                    transition: border-color .16s ease, box-shadow .16s ease;
                }

                .signature-page .signature-control:focus {
                    border-color: var(--assinatura-primary);
                    box-shadow: 0 0 0 4px rgba(35, 59, 104, 0.12);
                    outline: none;
                }

                .signature-help {
                    margin: 12px 0 0;
                    padding: 13px 14px;
                    color: #5a6680;
                    border: 1px solid #dce5f2;
                    border-radius: 14px;
                    background: #f8fafc;
                    font-size: 13px;
                    line-height: 1.45;
                }

                .signature-actions {
                    display: flex;
                    align-items: center;
                    justify-content: flex-end;
                    gap: 12px;
                    margin-top: 18px;
                }

                .signature-page .btnGerar {
                    min-height: 48px;
                    padding: 0 24px;
                    border: 0;
                    border-radius: 14px;
                    background: linear-gradient(135deg, #233b68, #0f9f6e);
                    color: #fff;
                    font-size: 15px;
                    font-weight: 900;
                    letter-spacing: 0;
                    box-shadow: 0 14px 30px rgba(15, 159, 110, 0.20);
                    transition: transform .18s ease, box-shadow .18s ease;
                }

                .signature-page .btnGerar:hover,
                .signature-page .btnGerar:focus {
                    color: #fff;
                    transform: translateY(-1px);
                    box-shadow: 0 18px 36px rgba(35, 59, 104, 0.22);
                }

                .signature-preview-panel {
                    display: flex;
                    flex-direction: column;
                }

                .signature-preview-panel.col-md-12 {
                    grid-column: 1 / -1;
                }

                .signature-preview-frame {
                    display: flex;
                    flex: 1;
                    align-items: center;
                    justify-content: center;
                    min-height: 258px;
                    padding: 24px;
                    overflow-x: auto;
                    border: 1px dashed #c9d5e6;
                    border-radius: 18px;
                    background:
                        linear-gradient(45deg, rgba(148, 163, 184, 0.08) 25%, transparent 25%),
                        linear-gradient(-45deg, rgba(148, 163, 184, 0.08) 25%, transparent 25%),
                        linear-gradient(45deg, transparent 75%, rgba(148, 163, 184, 0.08) 75%),
                        linear-gradient(-45deg, transparent 75%, rgba(148, 163, 184, 0.08) 75%),
                        #fff;
                    background-position: 0 0, 0 10px, 10px -10px, -10px 0;
                    background-size: 20px 20px;
                }

                .signature-preview-frame > div {
                    flex: 0 0 auto;
                }

                .signature-preview-note {
                    margin: 14px 0 0;
                    color: var(--assinatura-muted);
                    font-size: 12px;
                    line-height: 1.45;
                    text-align: center;
                }

                .signature-success {
                    width: min(760px, 100%);
                    margin: 0 auto;
                    padding: 28px;
                    border: 1px solid var(--assinatura-line);
                    border-radius: 22px;
                    background: #fff;
                    box-shadow: var(--assinatura-shadow);
                }

                .signature-success .alert {
                    margin: 0;
                    border: 0;
                    border-radius: 18px;
                    background: #ecfdf5;
                    color: #0f5132;
                }

                .signature-page-footer {
                    margin-top: 18px;
                    padding: 18px;
                    color: #64748b;
                    border: 1px solid #dce5f2;
                    border-radius: 18px;
                    background: rgba(255, 255, 255, 0.78);
                    font-size: 13px;
                    text-align: center;
                }

                @media (max-width: 900px) {
                    .signature-hero {
                        align-items: flex-start;
                        flex-direction: column;
                    }

                    .signature-grid {
                        grid-template-columns: 1fr;
                    }

                    .signature-preview-panel.col-md-12 {
                        grid-column: auto;
                    }
                }

                @media (max-width: 560px) {
                    .signature-page .container-login100 {
                        padding: 16px 10px;
                    }

                    .signature-hero,
                    .signature-panel,
                    .signature-success {
                        border-radius: 18px;
                        padding: 18px;
                    }

                    .signature-field-grid {
                        grid-template-columns: 1fr;
                    }

                    .signature-actions {
                        justify-content: stretch;
                    }

                    .signature-page .btnGerar {
                        width: 100%;
                    }
                }
            </style>
            <!-- /adicionado 12/11/2024 -->
        </head>

        <body class="signature-page">

            <div class="limiter">
                <div class="container-login100">
                    <div class="signature-page-shell">
                        <header class="signature-hero">
                            <div>
                                <span class="signature-eyebrow">Tecnologia | Grupo Bali</span>
                                <h1>Gerador de assinatura</h1>
                                <p>Preencha os dados, confira a pr&eacute;via e gere a imagem final para usar no e-mail corporativo.</p>
                            </div>
                            <a class="signature-back-link" href="../Intranet/index.html">Voltar</a>
                        </header>

                        <form runat="server" class="signature-form-shell" autocomplete="off">
                            <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server">
                            </asp:ScriptManager>

                            <div id="containerForm" class="signature-generator">
                                <div class="signature-grid">
                                    <section class="signature-panel">
                                        <div class="signature-panel-title">
                                            <div>
                                                <span>Dados da assinatura</span>
                                                <h2>Informa&ccedil;&otilde;es principais</h2>
                                            </div>
                                            <span class="signature-step-badge">1</span>
                                        </div>

                                        <div class="signature-field-grid">
                                            <div class="signature-field signature-field-full">
                                                <label class="signature-label" for="ddlEmpresa">Empresa</label>
                                                <select class="form-control custom-select signature-control" id="ddlEmpresa" runat="server">
                                                    <option value="compartilhada">BYD</option>
                                                    <option value="fiat">BALI Fiat</option>
                                                    <option value="jeep">BALI Jeep</option>
                                                    <option value="grupobali">Grupo Bali</option>
                                                </select>
                                            </div>

                                            <div class="signature-field signature-field-full">
                                                <label class="signature-label" for="txtNome">Nome <i class="signature-required">*</i></label>
                                                <input runat="server" id="txtNome" type="text" class="form-control signature-control"
                                                    placeholder="Informe seu nome" maxlength="40" required="required" autocomplete="off" />
                                            </div>

                                            <div class="signature-field signature-field-full">
                                                <label class="signature-label" for="txtFuncao">Fun&ccedil;&atilde;o <i class="signature-required">*</i></label>
                                                <input runat="server" id="txtFuncao" type="text" class="form-control signature-control"
                                                    placeholder="Informe sua fun&ccedil;&atilde;o" required="required" autocomplete="off" />
                                            </div>

                                            <div class="signature-field d-none" id="divDDD">
                                                <label class="signature-label" for="txtDDD">DDD</label>
                                                <input runat="server" id="txtDDD" type="number" class="form-control signature-control"
                                                    placeholder="61" autocomplete="off" />
                                            </div>

                                            <div class="signature-field">
                                                <label class="signature-label" for="txtTel">Telefone</label>
                                                <input runat="server" id="txtTel" type="text" class="form-control signature-control"
                                                    placeholder="(61) 00000-0000" autocomplete="off" />
                                            </div>
                                        </div>

                                        <p class="signature-help">
                                            O arquivo ser&aacute; gerado em PNG. Confira a pr&eacute;via antes de baixar para evitar ajustes manuais no e-mail.
                                        </p>

                                        <div class="signature-actions">
                                            <asp:Button ID="btnGerar" runat="server"
                                                CssClass="btnGerar btn btn-lg btn-primary" OnClick="btnConvert_Click"
                                                Text="Gerar assinatura" />
                                        </div>
                                    </section>

                                    <section class="signature-panel signature-preview-panel col-md-6" id="containerAssinatura">
                                        <div class="signature-panel-title">
                                            <div>
                                                <span>Pr&eacute;via</span>
                                                <h2>Resultado visual</h2>
                                            </div>
                                            <span class="signature-step-badge">2</span>
                                        </div>

                                        <div class="signature-preview-frame">
                                            <!-- id="divAssinaturaGeral"  adicionado 12/11/2024 -->
                                            <div id="divAssinaturaGeral" style="width: 280px; height: 150px;">
                                                <div id="assinatura" style="width: 280px; height: 150px;">

                                                    <div style="width: 100%; height: 55px;">
                                                        <img id="imgLogo" src="./resources/headers/compartilhada.png" />
                                                    </div>
                                                    <strong>
                                                        <div runat="server" id="nomeImp"
                                                            style="font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif; font-size: 12px; text-transform: uppercase;">
                                                            NOME</div>
                                                    </strong>
                                                    <div style="width: 100%; height: 8px;"></div>
                                                    <div runat="server" id="funcaoImp"
                                                        style="font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif; font-size: 12px;">
                                                        Fun&ccedil;&atilde;o</div>

                                                    <div style="width: 194px; display: flex; vertical-align:bottom;">

                                                        <div style="width: 80%">
                                                            <div runat="server" id="telImp"
                                                                style="font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif; font-size: 12px;">
                                                                Telefone</div>

                                                        </div>
                                                        <div style="width: 20%">
                                                            <img style="display: none" id="imgJeepRodape"
                                                                src="resources/headers/jeepRodape.png" />
                                                        </div>
                                                    </div>

                                                </div>
                                            </div>
                                            <!-- adicionado 12/11/2024 -->
                                            <div id="divAssinaturaGrupoBali" class="assinatura-grupo-bali d-none">
                                                <span class="nome-grupo-bali" id="nomeGrupoBaliImp">
                                                    Nome
                                                </span>
                                                <span class="cargo-grupo-bali" id="cargoGrupoBaliImp">
                                                    Cargo/Fun&ccedil;&atilde;o
                                                </span>
                                                <span class="ddd-grupo-bali" id="dddGrupoBaliImp">
                                                    ddd
                                                </span>
                                                <span class="telefone-grupo-bali" id="telefoneGrupoBaliImp">
                                                    TELEFONE
                                                </span>

                                            </div>
                                            <!-- /adicionado 12/11/2024 -->
                                        </div>
                                        <p class="signature-preview-note">
                                            A pr&eacute;via mant&eacute;m as medidas originais usadas na imagem final da assinatura.
                                        </p>
                                    </section>
                                </div>
                            </div>
                            <div class="signature-success" id="containerSuccess" style="display:none;">
                                <div class="alert alert-success text-center" role="alert">
                                    <h4 class="alert-heading">Muito bem!</h4>
                                    <h6>Estamos criando sua assinatura.</h6>
                                    <p class="mb-0">Em poucos segundos o download iniciar&aacute;.</p>
                                    <p class="mb-0">Ap&oacute;s o download, clique no link abaixo para retornar ao
                                        gerador.</p>
                                    <hr>
                                    <asp:LinkButton ID="btnAtualiza" runat="server" CssClass="btn-link"
                                        Text="Voltar ao Gerador" />
                                </div>
                            </div>
                            <footer class="signature-page-footer">
                                TI - GRUPO BALI | (61) 3362-6208 | ti@bali.com.br
                            </footer>
                        </form>
                    </div>
                </div>
            </div>
            <!--===============================================================================================-->

            <script>
                const txtNome = document.getElementById('txtNome')
                //  adicionado 12/11/2024 campo DDD
                const txtDDD = document.getElementById('txtDDD')
                const divDDD = document.getElementById('divDDD')
              
                const containerAssinatura = document.getElementById('containerAssinatura')
                // /adicionado 12/11/2024
                const tel = document.getElementById('txtTel') // Seletor do campo de telefone
                const txtFuncao = document.getElementById('txtFuncao')
                const ddlEmpresa = document.getElementById('ddlEmpresa')
                const imgLogo = document.getElementById('imgLogo')
                const btnAtualiza = document.getElementById('btnAtualiza')
                const btnGerar = document.getElementById('btnGerar')
                const containerForm = document.getElementById('containerForm')
                const containerSuccess = document.getElementById('containerSuccess')
                const imgJeepRodape = document.getElementById('imgJeepRodape')
                const divAssinaturaGeral = document.getElementById('divAssinaturaGeral')
                const divAssinaturaGrupoBali = document.getElementById('divAssinaturaGrupoBali')


                tel.addEventListener('input', (e) => mascaraTelefone(e.target.value)) // Dispara quando digitado no campo
                tel.addEventListener('keyup', (e) => mascaraTelefone(e.target.value)) // Dispara quando digitado no campo
                tel.addEventListener('change', (e) => mascaraTelefone(e.target.value)) // Dispara quando autocompletado o campo
                btnGerar.addEventListener('click', (e) => clickBtn()) // Dispara quando autocompletado o campo

                const clickBtn = () => {
                    if (txtNome.value.length != 0 && txtFuncao.value.length != 0) {
                        containerForm.style.display = 'none';
                        containerSuccess.style.display = 'block';
                    }
                }

                const mascaraTelefone = (valor) => {
                    //  bloco "if" adicionado 12/11/2024 caso seja grupo bali não formata o telefone, pois o ddd é separado
                    if (ddlEmpresa.value != 'grupobali') {

                        valor = valor.replace(/\D/g, "")
                        valor = valor.replace(/^(\d{2})(\d)/g, "($1) $2")
                        valor = valor.replace(/(\d)(\d{4})$/, "$1-$2")
                        tel.value = valor // Insere o(s) valor(es) no campo
                    }
                    preencherAssinatura()
                }


               

                //preencher automatico assinatura
                const nomeImp = document.getElementById('nomeImp')
                const funcaoImp = document.getElementById('funcaoImp')
                const telImp = document.getElementById('telImp')

                //  adicionado 12/11/2024
                const nomeGrupoBaliImp = document.getElementById('nomeGrupoBaliImp')
                const cargoGrupoBaliImp = document.getElementById('cargoGrupoBaliImp')
                const dddGrupoBaliImp = document.getElementById('dddGrupoBaliImp')
                const telefoneGrupoBaliImp = document.getElementById('telefoneGrupoBaliImp')
                // /adicionado 12/11/2024


                txtNome.addEventListener('input', (e) => preencherAssinatura()) // Dispara quando digitado no campo
                txtNome.addEventListener('keyup', (e) => preencherAssinatura()) // Dispara quando digitado no campo
                txtNome.addEventListener('change', (e) => preencherAssinatura()) // Dispara quando autocompletado o campo

                txtFuncao.addEventListener('input', (e) => preencherAssinatura()) // Dispara quando digitado no campo
                txtFuncao.addEventListener('keyup', (e) => preencherAssinatura()) // Dispara quando digitado no campo
                txtFuncao.addEventListener('change', (e) => preencherAssinatura()) // Dispara quando autocompletado o campo

                txtDDD.addEventListener('input', (e) => preencherAssinatura())
                txtDDD.addEventListener('keyup', (e) => preencherAssinatura())
                txtDDD.addEventListener('change', (e) => preencherAssinatura())

                const preencherAssinatura = () => {
                    //  bloco "if" adicionado 12/11/2024
                    if (ddlEmpresa.value === 'grupobali') {
                        nomeGrupoBaliImp.textContent = txtNome.value // Insere o(s) valor(es) no campo
                        cargoGrupoBaliImp.textContent = txtFuncao.value // Insere o(s) valor(es) no campo
                        dddGrupoBaliImp.textContent = txtDDD.value // Insere o(s) valor(es) no campo
                        telefoneGrupoBaliImp.textContent = tel.value // Insere o(s) valor(es) no campo
                    } else {
                        // /bloco "if" adicionado 12/11/2024

                        nomeImp.textContent = txtNome.value // Insere o(s) valor(es) no campo
                        funcaoImp.textContent = txtFuncao.value // Insere o(s) valor(es) no campo
                        if (tel.value != null && tel.value != '') {
                            telImp.textContent = 'Tel.:' + tel.value // Insere o(s) valor(es) no campo
                        } else { telImp.textContent = '' }

                    }
                }

                ddlEmpresa.addEventListener('change', (e) => changeLogo()) // Dispara quando autocompletado o campo

                const changeLogo = () => {
                    // adicionado 12/11/2024
                    if (ddlEmpresa.value === 'grupobali') {
                        //trocar col-md-6 por col-md-12
                        containerAssinatura.classList.remove('col-md-6')
                        containerAssinatura.classList.add('col-md-12')
                        divDDD.classList.remove('d-none')
                        divAssinaturaGeral.classList.add('d-none');
                        divAssinaturaGrupoBali.classList.remove('d-none');
                    } else {
                        //trocar col-md-12 por col-md-6
                        containerAssinatura.classList.remove('col-md-12')
                        containerAssinatura.classList.add('col-md-6')
                        divDDD.classList.add('d-none')
                        divAssinaturaGeral.classList.remove('d-none');
                        divAssinaturaGrupoBali.classList.add('d-none');

                    }


                    imgLogo.src = './resources/headers/' + ddlEmpresa.value + '.png'
                    if (ddlEmpresa.value === 'jeep') {
                        imgJeepRodape.style.display = 'block';
                    } else {
                        imgJeepRodape.style.display = 'none';
                    }
                    preencherAssinatura();
                }

                //on load
                changeLogo();
                preencherAssinatura();

               




            </script>
        </body>

        </html>
