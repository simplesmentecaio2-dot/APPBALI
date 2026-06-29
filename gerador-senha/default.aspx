<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="gerador_senha_default" EnableViewState="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Gerador de senha | Tecnologia</title>
    <link href="../css/bali-tecnologia.css?v=20260629-gerador-senha01" rel="stylesheet" />
</head>
<body class="bali-tech-page password-generator-page">
    <form id="form1" runat="server">
        <header class="tech-topbar">
            <a class="tech-brand" href="../Intranet/index.html" aria-label="Voltar para intranet">
                <img src="../img/logobali.png?v=20260624-logo2" alt="Bali" />
                <span>APP</span>
            </a>
            <div class="tech-user">
                <span>Tecnologia</span>
                <strong><asp:Label ID="lblUsuario" runat="server" /></strong>
                <small>C&oacute;digo: <asp:Label ID="lblCodigo" runat="server" /></small>
            </div>
            <nav class="tech-actions" aria-label="A&ccedil;&otilde;es r&aacute;pidas">
                <a href="../Intranet/index.html">Voltar</a>
                <a href="../logout.aspx?voltar=/login.aspx">Sair</a>
            </nav>
        </header>

        <main class="tech-main password-generator-main">
            <section class="tech-hero password-generator-hero">
                <div>
                    <span class="tech-eyebrow">Tecnologia &middot; acesso interno</span>
                    <h1>Gerador de senha</h1>
                    <p>Gere uma senha tempor&aacute;ria forte e envie diretamente para o e-mail informado. A senha n&atilde;o fica vis&iacute;vel na tela.</p>
                </div>
                <div class="password-generator-score">
                    <span>Pol&iacute;tica atual</span>
                    <strong>12 caracteres</strong>
                    <small>Com letras, n&uacute;meros e caractere especial.</small>
                </div>
            </section>

            <asp:Panel ID="pnlMensagem" runat="server" Visible="false" CssClass="tech-alert password-generator-alert">
                <asp:Literal ID="litMensagem" runat="server" />
            </asp:Panel>

            <section class="tech-panel password-generator-card">
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Envio seguro</span>
                        <h2>Enviar senha por e-mail</h2>
                        <p>Informe o e-mail do destinat&aacute;rio. O sistema gera a senha no servidor e envia sem mostrar o conte&uacute;do para o operador.</p>
                    </div>
                </div>

                <div class="password-generator-form">
                    <label class="tech-field is-full">
                        <span>E-mail do destinat&aacute;rio</span>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="180" autocomplete="off" placeholder="nome@bali.com.br"></asp:TextBox>
                    </label>

                    <div class="password-generator-note is-full">
                        <strong>Boas pr&aacute;ticas</strong>
                        <p>Use esta ferramenta apenas para gerar senhas tempor&aacute;rias. Ap&oacute;s o primeiro acesso, oriente o usu&aacute;rio a trocar a senha.</p>
                    </div>

                    <div class="tech-actions-row is-full">
                        <asp:Button ID="btnGerar" runat="server" Text="Gerar e enviar senha" OnClick="GerarSenha_Click" />
                    </div>
                </div>
            </section>
        </main>
    </form>
</body>
</html>
