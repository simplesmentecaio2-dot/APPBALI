<%@ Page Language="C#" AutoEventWireup="true" CodeFile="login.aspx.cs" Inherits="ramais_login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Ramais - Login</title>
    <link href="ramais.css?v=20260624" rel="stylesheet" />
</head>
<body class="ramais-login-page">
    <form id="form1" runat="server">
        <main class="login-shell">
            <section class="login-panel">
                <div class="login-brand">
                    <span class="brand-mark">B</span>
                    <div>
                        <strong>Grupo Bali</strong>
                        <small>Sistema de ramais</small>
                    </div>
                </div>

                <div class="login-copy">
                    <span class="eyebrow">Acesso interno</span>
                    <h1>Ramais das lojas</h1>
                    <p>Consulte, cadastre e mantenha os contatos internos por loja e setor.</p>
                </div>

                <asp:Panel ID="pnlMensagem" runat="server" CssClass="form-message error" Visible="false">
                    <asp:Literal ID="litMensagem" runat="server"></asp:Literal>
                </asp:Panel>

                <label class="field-label" for="<%=txtSenha.ClientID%>">Senha</label>
                <asp:TextBox ID="txtSenha" runat="server" CssClass="text-field" TextMode="Password" autocomplete="current-password"></asp:TextBox>
                <asp:Button ID="btnEntrar" runat="server" Text="Entrar" CssClass="primary-button full" OnClick="btnEntrar_Click" />
                <a class="ghost-link" href="../Intranet/index.html">Voltar para a Intranet</a>
            </section>
        </main>
    </form>
</body>
</html>
