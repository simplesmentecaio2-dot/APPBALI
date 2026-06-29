<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="veiculos_Pint_Contrato" %>

    <%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

        <!DOCTYPE html>

        <html xmlns="http://www.w3.org/1999/xhtml">

        <head runat="server">
            <title>GERADOR de Assinatura | APP Bali</title>
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


         
            </style>
            <!-- /adicionado 12/11/2024 -->
        </head>

        <body>
            
            <div class="limiter">
                <div class="container-login100">
                    <div class="p-t-30 p-b-50" style="width=100%">
                        <form runat="server" class="login100-form validate-form p-b-33 p-t-5 p-5">
                            <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server">
                            </asp:ScriptManager>

                            <div id="containerForm" class="container">
                                <div class="wrap-input100">
                                    <h3 class="card-title text-center">GERADOR DE ASSINATURA por <b>TECNOLOGIA</b> |
                                        Bali</h3>
                                </div>
                                <div class="row">
                                   

                                    <div class="col-md-6">
                                        <div class="input-group m-2">
                                            <span class="input-group-addon" id="basic-addon"><b>Empresa</b></span>
                                            <select class="form-control bg-light custom-select" id="ddlEmpresa"
                                                runat="server">
                                                <option value="compartilhada">BYD</option>
                                                <option value="fiat">BALI Fiat</option>
                                                <option value="jeep">BALI Jeep</option>
                                                <option value="grupobali">Grupo Bali</option>
                                            </select>
                                            <!-- vallue="grupobali" adicionado 12/11/2024 -->
                                        </div>
                                        <div class="input-group m-2">
                                            <span class="input-group-addon" id="basic-addon1"><b>Nome<i
                                                        class="text-danger">*</i></b></span>
                                            <input runat="server" id="txtNome" type="text" class="form-control"
                                                placeholder="Informe seu nome!" aria-describedby="basic-addon1"
                                                style="font-weight: bold;" maxlength="40" required="required" />
                                        </div>
                                        <div class="input-group m-2">
                                            <span class="input-group-addon" id="basic-addon2"><b>Função<i
                                                        class="text-danger">*</i></b></span>
                                            <input runat="server" id="txtFuncao" type="text" class="form-control"
                                                placeholder="Informe sua função!" aria-describedby="basic-addon1"
                                                required="required" />
                                        </div>
                                        <div class="input-group m-2 d-none" id="divDDD">
                                            <span class="input-group-addon">
                                                <b>DDD</b>
                                            </span>
                                            <input runat="server" id="txtDDD" type="number" class="form-control"
                                                placeholder="Informe o ddd!" aria-describedby="basic-addonddd" />
                                        </div>
                                        <div class="input-group m-2">
                                            <span class="input-group-addon" id="basic-addon3"><b>Telefone</b></span>
                                            <input runat="server" id="txtTel" type="text" class="form-control"
                                                placeholder="Informe o telefone!" aria-describedby="basic-addon1" />
                                        </div>

                                      

                                    </div>
                                    <div class="col-md-6" id="containerAssinatura">
                                        <div class="m-2">
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
                                                        Função</div>

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
                                                    Cargo/Função
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
                                    </div>
                                    <div class="col-12 text-center m-3">
                                        <asp:Button ID="btnGerar" runat="server"
                                            CssClass="btnGerar btn btn-lg btn-primary" OnClick="btnConvert_Click"
                                            Text="Gerar Assinatura" />
                                    </div>
                                </div>
                            </div>
                            <div class="container" id="containerSuccess" style="display:none;">
                                <div class="wrap-input100">
                                    <h3 class="card-title text-center">GERADOR DE ASSINATURA por
                                        <b>TECNOLOGIA</b> | Bali
                                    </h3>
                                </div>
                                <div class="alert alert-success text-center" role="alert">
                                    <h4 class="alert-heading">Muito bem!</h4>
                                    <h6>Estamos trabalhando para criar sua Assinatura!</h6>
                                    <p class="mb-0">Em poucos segundos o download iniciará.</p>
                                    <p class="mb-0">Após o download, clique no link abaixo para retornar ao
                                        gerador.</p>
                                    <hr>
                                    <asp:LinkButton ID="btnAtualiza" runat="server" CssClass="btn-link"
                                        Text="Voltar ao Gerador" />
                                </div>
                            </div>
                            <div class="row text mt-5">
                                <div class="col-4"></div>

                            </div>
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


                txtNome.addEventListener('keyup', (e) => preencherAssinatura()) // Dispara quando digitado no campo
                txtNome.addEventListener('change', (e) => preencherAssinatura()) // Dispara quando autocompletado o campo

                txtFuncao.addEventListener('keyup', (e) => preencherAssinatura()) // Dispara quando digitado no campo
                txtFuncao.addEventListener('change', (e) => preencherAssinatura()) // Dispara quando autocompletado o campo

                const preencherAssinatura = () => {
                    //  bloco "if" adicionado 12/11/2024
                    if (ddlEmpresa.value === 'grupobali') {
                        nomeGrupoBaliImp.innerHTML = txtNome.value // Insere o(s) valor(es) no campo
                        cargoGrupoBaliImp.innerHTML = txtFuncao.value // Insere o(s) valor(es) no campo
                        dddGrupoBaliImp.innerHTML = txtDDD.value // Insere o(s) valor(es) no campo
                        telefoneGrupoBaliImp.innerHTML = tel.value // Insere o(s) valor(es) no campo
                    } else {
                        // /bloco "if" adicionado 12/11/2024

                        nomeImp.innerHTML = txtNome.value // Insere o(s) valor(es) no campo
                        funcaoImp.innerHTML = txtFuncao.value // Insere o(s) valor(es) no campo
                        if (tel.value != null && tel.value != '') {
                            telImp.innerHTML = 'Tel.:' + tel.value // Insere o(s) valor(es) no campo
                        } else { telImp.innerHTML = '' }
                        
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
                }

                //on load
                changeLogo();
                preencherAssinatura();

               




            </script>
        </body>

        </html>