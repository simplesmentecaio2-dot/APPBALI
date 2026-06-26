<%@ Page Language="C#" AutoEventWireup="true" CodeFile="alterarSenha.aspx.cs" Inherits="alterarSenha" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Alterar senha | Grupo Bali</title>
    <link rel="stylesheet" type="text/css" href="css/bali-login.css?v=20260626-password02" />
</head>
<body class="premium-login login-neutral password-page">
    <form id="form1" runat="server">
        <div class="limiter">
            <main class="container-login100 password-container">
                <section class="wrap-login100 password-card">
                    <div class="login100-form-title">
                        <span class="password-brand">Grupo Bali</span>
                    </div>

                    <div class="password-copy">
                        <span>Acesso seguro</span>
                        <h1>Alterar senha</h1>
                        <p>Valide sua senha atual e crie uma senha do APP Bali. A base original ser&aacute; usada somente para confirmar que o usu&aacute;rio continua ativo.</p>
                    </div>

                    <asp:Panel ID="pnlMensagem" runat="server" CssClass="password-message" Visible="false">
                        <asp:Literal ID="litMensagem" runat="server"></asp:Literal>
                    </asp:Panel>

                    <div class="password-form">
                        <label>Usu&aacute;rio
                            <asp:TextBox ID="txtUsuario" runat="server" CssClass="input100 password-input" MaxLength="120" autocomplete="username"></asp:TextBox>
                        </label>

                        <label>Senha atual
                            <asp:TextBox ID="txtSenhaAtual" runat="server" CssClass="input100 password-input" TextMode="Password" autocomplete="current-password"></asp:TextBox>
                        </label>

                        <label>Nova senha
                            <asp:TextBox ID="txtNovaSenha" runat="server" CssClass="input100 password-input" TextMode="Password" autocomplete="new-password"></asp:TextBox>
                        </label>

                        <label>Confirmar nova senha
                            <asp:TextBox ID="txtConfirmarSenha" runat="server" CssClass="input100 password-input" TextMode="Password" autocomplete="new-password"></asp:TextBox>
                        </label>

                        <asp:Button ID="btnAlterar" runat="server" CssClass="login100-form-btn" Text="Alterar senha" OnClick="btnAlterar_Click" />
                    </div>

                    <div class="password-actions">
                        <a id="lnkVoltar" runat="server" class="password-change-link" href="/">Voltar ao login</a>
                    </div>
                </section>
            </main>
        </div>
    </form>
</body>
</html>
