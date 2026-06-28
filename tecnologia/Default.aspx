<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="tecnologia_Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Tecnologia | Bali App</title>
    <link href="../css/central-links.css?v=20260627-maint01" rel="stylesheet" />
    <script src="../js/central-links-icons.js?v=20260627-maint01" defer="defer"></script>
    <script src="../js/central-links-maintenance.js?v=20260627-maint01" defer="defer"></script>
</head>
<body class="central-links-page brand-tecnologia" data-brand-name="Tecnologia" data-links-api="central-links.ashx?AspxAutoDetectCookieSupport=1">
    <form id="form1" runat="server">
        <div class="central-shell">
            <header class="central-topbar">
                <div class="central-topbar-inner">
                    <a class="central-brand" href="../Default.aspx" aria-label="Voltar para a p&aacute;gina inicial">
                        <img src="../img/logobali.png?v=20260624-logo2" alt="Bali" />
                        <span class="central-brand-copy">
                            <strong>Tecnologia</strong>
                            <span>Central de acesso</span>
                        </span>
                    </a>
                    <div class="central-user">
                        <div>Usu&aacute;rio: <span><asp:Label ID="lblUsuario" runat="server" /></span></div>
                        <div>C&oacute;digo: <span><asp:Label ID="lblTipo" runat="server" /></span></div>
                        <a class="central-logout-button" href="/logout.aspx?voltar=/login.aspx">Sair</a>
                    </div>
                </div>
            </header>

            <main class="central-main">
                <section class="central-hero">
                    <div>
                        <span class="central-eyebrow">Tecnologia &middot; Grupo Bali</span>
                        <h1>Central de tecnologia</h1>
                        <p>Administre sistemas, usu&aacute;rios, permiss&otilde;es e arquivos t&eacute;cnicos em um &uacute;nico painel.</p>
                    </div>
                    <div class="central-summary" aria-label="Resumo dos atalhos">
                        <div class="central-summary-item"><strong>3</strong><span>atalhos</span></div>
                        <div class="central-summary-item"><strong>TI</strong><span>suporte</span></div>
                    </div>
                </section>

                <section class="central-card-panel">
                    <div class="central-section-title">
                        <div>
                            <h2>Atalhos de tecnologia</h2>
                            <p>Links principais para gest&atilde;o de acessos, sistemas e materiais de apoio.</p>
                        </div>
                    </div>

                    <div class="central-link-grid">
                        <a class="central-link-card" href="sistemas.aspx" data-icon="technology">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Sistemas</span><span class="central-link-caption">Cat&aacute;logo t&eacute;cnico</span></span>
                        </a>
                        <a class="central-link-card" href="usuarios.aspx" data-icon="users">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Usu&aacute;rios</span><span class="central-link-caption">Permiss&otilde;es</span></span>
                        </a>
                        <a class="central-link-card" href="download.aspx" data-icon="files">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Arquivos importantes</span><span class="central-link-caption">Downloads</span></span>
                        </a>
                    </div>
                </section>
            </main>
        </div>
    </form>
</body>
</html>
