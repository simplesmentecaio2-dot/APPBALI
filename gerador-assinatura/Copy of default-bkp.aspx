<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Copy of default-bkp.aspx.cs" Inherits="veiculos_Pint_Contrato" %>

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
</head>
<body>
    <div class="limiter">
        <div class="container-login100">
            <div class="p-t-30 p-b-50" style="width=100%">
                <form runat="server" class="login100-form validate-form p-b-33 p-t-5 p-5">
                    <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>

                    <div id="containerForm" class="container">
                        <div class="wrap-input100">
                            <h3 class="card-title text-center">GERADOR DE ASSINATURA por <b>TECNOLOGIA</b> | Bali</h3>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="input-group m-2">
                                    <span class="input-group-addon" id="basic-addon"><b>Empresa</b></span>
                                    <select class="form-control bg-light custom-select" id="ddlEmpresa" runat="server">
                                        <option value="compartilhada">Compatilhado(BALI Fiat/Jeep)</option>
                                        <option value="fiat">BALI Fiat</option>
                                        <option value="jeep">BALI Jeep</option>
                                    </select>
                                </div>
                                <div class="input-group m-2">
                                    <span class="input-group-addon" id="basic-addon1"><b>Nome<i class="text-danger">*</i></b></span>
                                    <input runat="server" id="txtNome" type="text" class="form-control"
                                        placeholder="Informe seu nome!" aria-describedby="basic-addon1" style="text-transform: uppercase; font-weight: bold;" maxlength="40" required="required" />
                                </div>
                                <div class="input-group m-2">
                                    <span class="input-group-addon" id="basic-addon2"><b>Função<i class="text-danger">*</i></b></span>
                                    <input runat="server" id="txtFuncao" type="text" class="form-control"
                                        placeholder="Informe sua função!" aria-describedby="basic-addon1" required="required" />
                                </div>
                                <div class="input-group m-2">
                                    <span class="input-group-addon" id="basic-addon3"><b>Telefone</b></span>
                                    <input runat="server" id="txtTel" type="text" class="form-control"
                                        placeholder="Informe o telefone!" aria-describedby="basic-addon1" />
                                </div>
                                <div class="input-group m-2">
                                    <span class="input-group-addon" id="basic-addon3"><b>Celular</b></span>
                                    <input runat="server" id="txtCel" type="text" class="form-control"
                                        placeholder="Informe o Celular!" aria-describedby="basic-addon1" />
                                </div>

                            </div>
                            <div class="col-md-6">
                                <div class="m-2">
                                    <div style="width: 280px; height: 150px;">
                                        <div id="assinatura" style="width: 280px; height: 150px;">

                                            <div style="width: 100%; height: 55px;">
                                                <img id="imgLogo" src="./resources/headers/compartilhada.png" />
                                            </div>
                                            <strong>
                                                <div runat="server" id="nomeImp" style="font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif; font-size: 12px; text-transform: uppercase;">NOME</div>
                                            </strong>
                                            <div style="width: 100%; height: 8px;"></div>
                                            <div runat="server" id="funcaoImp" style="font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif; font-size: 12px;">Função</div>

                                            <div style="width: 194px; display: flex; vertical-align:bottom;">

                                                <div style="width: 80%">
                                                    <div runat="server" id="telImp" style="font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif; font-size: 12px;">Telefone</div>

                                                    <div runat="server" id="celImp" style="font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif; font-size: 12px;">Celular</div>
                                                </div>
                                                <div style="width: 20%">
                                                    <img style="display: none" id="imgJeepRodape" src="resources/headers/jeepRodape.png" />
                                                </div>
                                            </div>

                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12 text-center m-3">
                                <asp:Button ID="btnGerar" runat="server" CssClass="btnGerar btn btn-lg btn-primary" OnClick="btnConvert_Click" Text="Gerar Assinatura" />
                            </div>
                        </div>
                    </div>
                    <div class="container" id="containerSuccess" style="display:none;">
                        <div class="wrap-input100">
                            <h3 class="card-title text-center">GERADOR DE ASSINATURA por <b>TECNOLOGIA</b> | Bali</h3>
                        </div>
                        <div class="alert alert-success text-center" role="alert">
                            <h4 class="alert-heading">Muito bem!</h4>
                            <h6>Estamos trabalhando para criar sua Assinatura!</h6>
                            <p class="mb-0">Em poucos segundos o download iniciará.</p>
                            <p class="mb-0">Após o download, clique no link abaixo para retornar ao gerador.</p>
                            <hr>
                            <asp:LinkButton ID="btnAtualiza" runat="server" CssClass="btn-link" Text="Voltar ao Gerador"/>
                        </div>
                    </div>
                    <div class="row text mt-5">
                        <div class="col-4"></div>
                        <div class="col-2">
                            <img src="../img/logoBaliFiat.png" class="img-fluid" />
                        </div>
                        <div class="col-2">
                            <img src="../img/logojeep.png" class="img-fluid" />
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <!--===============================================================================================-->

    <script> 
        const txtNome = document.getElementById('txtNome') 
        const cel = document.getElementById('txtCel') // Seletor do campo de telefone
        const tel = document.getElementById('txtTel') // Seletor do campo de telefone
        const txtFuncao = document.getElementById('txtFuncao')  
        const ddlEmpresa = document.getElementById('ddlEmpresa')  
        const imgLogo = document.getElementById('imgLogo')  
        const btnAtualiza = document.getElementById('btnAtualiza')  
        const btnGerar = document.getElementById('btnGerar')  
        const containerForm = document.getElementById('containerForm')  
        const containerSuccess = document.getElementById('containerSuccess')  
        const imgJeepRodape = document.getElementById('imgJeepRodape')  

        tel.addEventListener('keyup', (e) => mascaraCelular(e.target.value)) // Dispara quando digitado no campo
        tel.addEventListener('change', (e) => mascaraCelular(e.target.value)) // Dispara quando autocompletado o campo
        btnGerar.addEventListener('click', (e) => clickBtn()) // Dispara quando autocompletado o campo

        const clickBtn = () => {
            if(txtNome.value.length != 0 && txtFuncao.value.length != 0){
                containerForm.style.display='none';
                containerSuccess.style.display='block';
            }   
        }

        const mascaraCelular = (valor) => {
            valor = valor.replace(/\D/g, "")
            valor = valor.replace(/^(\d{2})(\d)/g, "($1) $2")
            valor = valor.replace(/(\d)(\d{4})$/, "$1-$2")
            tel.value = valor // Insere o(s) valor(es) no campo
            preencherAssinatura()
        }


        cel.addEventListener('keyup', (e) => mascaraTelefone(e.target.value)) // Dispara quando digitado no campo
        cel.addEventListener('change', (e) => mascaraTelefone(e.target.value)) // Dispara quando autocompletado o campo

        const mascaraTelefone = (valor) => {
            valor = valor.replace(/\D/g, "")
            valor = valor.replace(/^(\d{2})(\d)/g, "($1) $2")
            valor = valor.replace(/(\d)(\d{4})$/, "$1-$2")
            cel.value = valor // Insere o(s) valor(es) no campo
            preencherAssinatura()
        }
        
        //preencher automatico assinatura
        const nomeImp = document.getElementById('nomeImp') 
        const funcaoImp = document.getElementById('funcaoImp') 
        const telImp = document.getElementById('telImp') 
        const celImp = document.getElementById('celImp') 

        txtNome.addEventListener('keyup', (e) => preencherAssinatura()) // Dispara quando digitado no campo
        txtNome.addEventListener('change', (e) => preencherAssinatura()) // Dispara quando autocompletado o campo
            
        txtFuncao.addEventListener('keyup', (e) => preencherAssinatura()) // Dispara quando digitado no campo
        txtFuncao.addEventListener('change', (e) => preencherAssinatura()) // Dispara quando autocompletado o campo

        const preencherAssinatura = () => {
            nomeImp.innerHTML = txtNome.value // Insere o(s) valor(es) no campo
            funcaoImp.innerHTML =  txtFuncao.value // Insere o(s) valor(es) no campo
            if(tel.value != null &&  tel.value != ''){
                telImp.innerHTML =  'Tel.:' + tel.value // Insere o(s) valor(es) no campo
            }else{telImp.innerHTML = ''}
            if(cel.value != null &&  cel.value != ''){
                celImp.innerHTML =  'Cel.:' + cel.value // Insere o(s) valor(es) no campo
            }else{celImp.innerHTML = ''}

        }

        ddlEmpresa.addEventListener('change', (e) => changeLogo()) // Dispara quando autocompletado o campo
        const changeLogo = () => {
            imgLogo.src = './resources/headers/' + ddlEmpresa.value + '.png'
            if(ddlEmpresa.value === 'jeep'){
                imgJeepRodape.style.display='block';                
            }else{
                imgJeepRodape.style.display='none';                
            }
        }
    </script>
</body>
</html>
