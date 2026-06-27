<%@ Page Language="C#" AutoEventWireup="true" CodeFile="login.aspx.cs" Inherits="login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Login | APP Bali</title>
    <link rel="stylesheet" type="text/css" href="css/bali-login.css?v=20260627-root01" />
</head>
<body class="premium-login login-neutral login-root">
    <div class="limiter">
        <div class="container-login100">
            <div class="wrap-login100 p-t-30 p-b-50">
                <span class="login100-form-title p-b-41">
                    <img src="img/logobali.png?v=20260624-logo2" class="img-fluid" alt="Bali" />
                </span>
                <form id="form1" class="login100-form validate-form p-b-33 p-t-5" runat="server">
                    <div class="login-root-copy">
                        <span>Grupo Bali</span>
                        <h1>APP Bali</h1>
                    </div>

                    <label class="wrap-input100 validate-input" for="txtUsuario">
                        <input id="txtUsuario" runat="server" class="input100" type="text" name="username" placeholder="Usu&aacute;rio" autocomplete="username" />
                    </label>

                    <label class="wrap-input100 validate-input" for="txtSenha">
                        <input id="txtSenha" runat="server" class="input100" type="password" name="password" placeholder="Senha" autocomplete="current-password" />
                    </label>

                    <div class="container-login100-form-btn m-t-32">
                        <asp:Button ID="btnLogin1" runat="server" CssClass="login100-form-btn" OnClick="LinkButton1_Click" Text="Entrar" />
                    </div>

                    <a class="password-change-link" href="/alterarSenha.aspx?voltar=/login.aspx">Alterar senha</a>
                    <a class="password-change-link login-help-link" href="mailto:ti@bali.com.br">Solicitar suporte</a>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
