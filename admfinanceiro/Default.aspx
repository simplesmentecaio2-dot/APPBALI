<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="admfinanceiro_Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Central Financeira | Grupo Bali</title>
    <link href="../css/central-links.css?v=20260629-sem-busca-centrais" rel="stylesheet" />
    <script src="../js/central-links-icons.js?v=20260627-maint01" defer="defer"></script>
    <script src="../js/central-links-maintenance.js?v=20260629-sem-busca-centrais" defer="defer"></script>
</head>
<body class="central-links-page brand-financeiro" data-brand-name="Financeiro" data-links-api="central-links.ashx?AspxAutoDetectCookieSupport=1" data-hide-shortcut-search="true">
    <form id="form1" runat="server">
        <div class="central-shell">
            <header class="central-topbar">
                <div class="central-topbar-inner">
                    <a class="central-brand" href="../Default.aspx" aria-label="Voltar para a p&aacute;gina inicial">
                        <img src="../img/logobali.png" alt="Bali" />
                        <span class="central-brand-copy">
                            <strong>Financeiro Bali</strong>
                            <span>Central de acesso</span>
                        </span>
                    </a>
                    <div class="central-user">
                        <div>Usu&aacute;rio: <span><asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text=""></asp:Label></span></div>
                        <div>C&oacute;digo: <span><asp:Label ID="lblPerfil" CssClass="idUser" runat="server" Text=""></asp:Label></span></div>
                        <a class="central-logout-button" href="/logout.aspx?voltar=/login.aspx">Sair</a>
                    </div>
                </div>
            </header>

            <main class="central-main">
                <section class="central-hero">
                    <div>
                        <span class="central-eyebrow">Administra&ccedil;&atilde;o financeira &middot; Grupo Bali</span>
                        <h1>Central financeira</h1>
                        <p>Acesse comiss&otilde;es, indicadores, recibos e ferramentas financeiras usadas na rotina administrativa.</p>
                    </div>
                    <div class="central-summary" aria-label="Resumo dos atalhos">
                        <div class="central-summary-item"><strong>3</strong><span>atalhos</span></div>
                        <div class="central-summary-item"><strong>ADM</strong><span>financeiro</span></div>
                    </div>
                </section>

                <section class="central-card-panel">
                    <div class="central-section-title">
                        <div>
                            <h2>Atalhos financeiros</h2>
                            <p>Links principais para acompanhamento financeiro e emiss&atilde;o de documentos.</p>
                        </div>
                    </div>

                    <div class="central-link-grid">
                        <a class="central-link-card" href="Comissao/comissaoWF.aspx" data-icon="commission">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Comiss&atilde;o WF</span><span class="central-link-caption">Comissionamento</span></span>
                        </a>
                        <a class="central-link-card" href="Financeiras/vendasdomes.aspx" data-icon="bi">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">BI</span><span class="central-link-caption">Indicadores</span></span>
                        </a>
                        <a class="central-link-card" href="Recibo/recibo.aspx" data-icon="receipt">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Recibo</span><span class="central-link-caption">Documento financeiro</span></span>
                        </a>
                    </div>
                </section>

                <footer class="central-footer">
                    <div class="central-footer-ip"><strong>IP:</strong> <asp:Label ID="lblIp" runat="server" Text=""></asp:Label></div>
                    <div class="central-footer-contact">TI - GRUPO BALI | (61) 3362-6208 | ti@bali.com.br</div>
                </footer>
            </main>
        </div>
    </form>
</body>
</html>
