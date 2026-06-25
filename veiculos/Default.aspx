<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="veiculos_Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Central Fiat | Grupo Bali</title>
    <link href="../css/central-links.css?v=20260624-central" rel="stylesheet" />
    <script src="../js/central-links-icons.js?v=20260624-central" defer="defer"></script>
    <script src="../js/central-links-maintenance.js?v=20260625-noautofill" defer="defer"></script>
</head>
<body class="central-links-page brand-fiat" data-brand-name="Fiat" data-links-api="central-links.ashx?AspxAutoDetectCookieSupport=1">
    <form id="form1" runat="server">
        <div class="central-shell">
            <header class="central-topbar">
                <div class="central-topbar-inner">
                    <a class="central-brand" href="../Default.aspx" aria-label="Voltar para a p&aacute;gina inicial">
                        <img src="../img/logobali.png" alt="Bali Fiat" />
                        <span class="central-brand-copy">
                            <strong>Bali Fiat</strong>
                            <span>Central de acesso</span>
                        </span>
                    </a>
                    <div class="central-user">
                        <div>Usu&aacute;rio: <span><asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text=""></asp:Label></span></div>
                        <div>Perfil: <span><asp:Label ID="lblPerfil" CssClass="idUser" runat="server" Text=""></asp:Label></span></div>
                    </div>
                </div>
            </header>

            <main class="central-main">
                <section class="central-hero">
                    <div>
                        <span class="central-eyebrow">Fiat &middot; Grupo Bali</span>
                        <h1>Central de acesso Fiat</h1>
                        <p>Acesse contratos, recibos, entregas, test drive, financeiro, lojas e ferramentas operacionais da Bali Fiat.</p>
                    </div>
                    <div class="central-summary" aria-label="Resumo dos atalhos">
                        <div class="central-summary-item"><strong>9</strong><span>atalhos</span></div>
                        <div class="central-summary-item"><strong>Fiat</strong><span>vendas</span></div>
                    </div>
                </section>

                <section class="central-card-panel">
                    <div class="central-section-title">
                        <div>
                            <h2>Atalhos Fiat</h2>
                            <p>Links principais para a rotina comercial e administrativa.</p>
                        </div>
                    </div>

                    <div class="central-link-grid">
                        <a class="central-link-card" href="contrato.aspx" data-icon="contract">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Contrato</span><span class="central-link-caption">Compra e venda</span></span>
                        </a>
                        <a class="central-link-card" href="recibo_Desconto.aspx" data-icon="receipt">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Recibo de Desconto</span><span class="central-link-caption">Financeiro</span></span>
                        </a>
                        <a class="central-link-card" href="../admfinanceiro/Recibo/Entrega.aspx" data-icon="delivery">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Entrega do Ve&iacute;culo</span><span class="central-link-caption">Entrega</span></span>
                        </a>
                        <a class="central-link-card" href="testdrive.aspx" data-icon="test-drive">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Termo Test Drive</span><span class="central-link-caption">Experi&ecirc;ncia</span></span>
                        </a>
                        <a class="central-link-card" href="telfinanceiras.aspx" data-icon="phone">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Telefone das Financeiras</span><span class="central-link-caption">Contatos</span></span>
                        </a>
                        <a class="central-link-card" href="contasbali.aspx" data-icon="accounts">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Contas Bali</span><span class="central-link-caption">Financeiro</span></span>
                        </a>
                        <a class="central-link-card" href="infLOJAS.aspx" data-icon="store">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Informa&ccedil;&otilde;es das Lojas</span><span class="central-link-caption">Unidades</span></span>
                        </a>
                        <a class="central-link-card" href="https://app.bali.com.br/ci/default.aspx" data-icon="communication">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Comunica&ccedil;&atilde;o Interna</span><span class="central-link-caption">Documento</span></span>
                        </a>
                        <a class="central-link-card" href="https://prospeccao.grupobali.com.br/" data-icon="prospecting">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Prospec&ccedil;&atilde;o</span><span class="central-link-caption">Vendas</span></span>
                        </a>
                    </div>
                </section>

                <footer class="central-footer">
                    <strong>IP:</strong> <asp:Label ID="lblIp" runat="server" Text="Label"></asp:Label>
                    <br />
                    TI - BALI Autom&oacute;veis | (61) 3362-6208 | ti@bali.com.br
                </footer>
            </main>
        </div>
    </form>
</body>
</html>
