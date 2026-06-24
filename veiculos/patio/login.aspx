<%@ Page Language="C#" AutoEventWireup="true" CodeFile="login.aspx.cs" Inherits="login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login | Patio</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!--===============================================================================================-->
    <link rel="icon" type="image/png" href="./assets/images/icons/favicon.ico" />
    <!--===============================================================================================-->
    <link rel="stylesheet" type="text/css" href="./assets/vendor/bootstrap/css/bootstrap.min.css">
    <!--===============================================================================================-->
    <link rel="stylesheet" type="text/css" href="./assets/fonts/font-awesome-4.7.0/css/font-awesome.min.css">
    <!--===============================================================================================-->
    <link rel="stylesheet" type="text/css" href="./assets/fonts/Linearicons-Free-v1.0.0/icon-font.min.css">
    <!--===============================================================================================-->
    <link rel="stylesheet" type="text/css" href="./assets/vendor/animate/animate.css">
    <!--===============================================================================================-->
    <link rel="stylesheet" type="text/css" href="./assets/vendor/css-hamburgers/hamburgers.min.css">
    <!--===============================================================================================-->
    <link rel="stylesheet" type="text/css" href="./assets/vendor/animsition/css/animsition.min.css">
    <!--===============================================================================================-->
    <link rel="stylesheet" type="text/css" href="./assets/vendor/select2/select2.min.css">
    <!--===============================================================================================-->
    <link rel="stylesheet" type="text/css" href="./assets/vendor/daterangepicker/daterangepicker.css">
    <!--===============================================================================================-->
    <link rel="stylesheet" type="text/css" href="./assets/css/util.css">
    <link rel="stylesheet" type="text/css" href="./assets/css/main.css">
    <link rel="stylesheet" type="text/css" href="../../css/bali-login.css">
    <!--===============================================================================================-->
</head>
<body class="premium-login login-fiat">
    <div class="limiter">
		<div class="container-login100 bg-dark">
			<div class="wrap-login100 p-l-85 p-r-85 p-t-55 p-b-55">
				<form class="login100-form validate-form flex-sb flex-w" runat="server">
					<span class="login100-form-title p-b-32">
                        <img src="../../img/logobali.png" class="img-fluid"/> <strong>|</strong> <span class="badge badge-dark">PÁTIO</span>
					</span>

					<span class="txt1 p-b-11">
						Usu&aacute;rio
					</span>
					<div class="wrap-input100 validate-input m-b-36" data-validate = "Informe o usu&aacute;rio">
                        <input id="txtUsuario" runat="server" class="input100" type="text" name="username" placeholder="Usuário">
						<span class="focus-input100"></span>
					</div>
					
					<span class="txt1 p-b-11">
						Senha
					</span>
					<div class="wrap-input100 validate-input m-b-12" data-validate = "Informe a senha">
						<span class="btn-show-pass">
							<i class="fa fa-eye"></i>
						</span>
                        <input id="txtSenha" runat="server" class="input100" type="password" name="pass" placeholder="Senha">
						<span class="focus-input100"></span>
					</div>
					<div class="container-login100-form-btn">
						 <asp:Button ID="btnLogin1" runat="server" CssClass="login100-form-btn" OnClick="LinkButton1_Click" Text="Login" />
					</div>

                </form>
            </div>
        </div>
    </div>
    <footer class="fixed-bottom bg-dark">
        <div class="container text-center text-white mb-2 mt-2">
            <b>&copy;TECNOLOGIA</b> | Bali Brasília Automóveis - LTDA
        </div>
        <div class="row no-gutters social-container">
        </div>
    </footer>


    <div id="dropDownSelect1"></div>

    <!--===============================================================================================-->
    <script src="vendor/jquery/jquery-3.2.1.min.js"></script>
    <!--===============================================================================================-->
    <script src="vendor/animsition/js/animsition.min.js"></script>
    <!--===============================================================================================-->
    <script src="vendor/bootstrap/js/popper.js"></script>
    <script src="vendor/bootstrap/js/bootstrap.min.js"></script>
    <!--===============================================================================================-->
    <script src="vendor/select2/select2.min.js"></script>
    <!--===============================================================================================-->
    <script src="vendor/daterangepicker/moment.min.js"></script>
    <script src="vendor/daterangepicker/daterangepicker.js"></script>
    <!--===============================================================================================-->
    <script src="vendor/countdowntime/countdowntime.js"></script>
    <!--===============================================================================================-->
    <script src="js/main.js"></script>

</body>
</html>
