<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Principal.aspx.cs" Inherits="veiculos_Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Central BYD | Grupo Bali</title>
    <link href="../css/central-links.css?v=20260624-central" rel="stylesheet" />
    <script src="../js/central-links-icons.js?v=20260624-central" defer="defer"></script>
    <script src="../js/central-links-maintenance.js?v=20260624-central" defer="defer"></script>
</head>
<body class="central-links-page brand-byd" data-brand-name="BYD" data-links-api="central-links.ashx?AspxAutoDetectCookieSupport=1">
    <form id="form1" runat="server">
        <div class="central-shell">
            <header class="central-topbar">
                <div class="central-topbar-inner">
                    <a class="central-brand" href="../Default.aspx" aria-label="Voltar para a p&aacute;gina inicial">
                        <img src="../img/bydbranco.png" alt="Bali BYD" />
                        <span class="central-brand-copy">
                            <strong>Bali BYD</strong>
                            <span>Central de acesso</span>
                        </span>
                    </a>
                    <div class="central-user">
                        <div>Usu&aacute;rio: <span><asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text="CAIO AUGUSTO"></asp:Label></span></div>
                        <div>Perfil: <span><asp:Label ID="lblPerfil" CssClass="idUser" runat="server" Text=""></asp:Label></span></div>
                    </div>
                </div>
            </header>

            <main class="central-main">
                <section class="central-hero">
                    <div>
                        <span class="central-eyebrow">BYD &middot; Grupo Bali</span>
                        <h1>Central de acesso BYD</h1>
                        <p>Acesse workflow, contratos, recibos, pedido de venda direta, test drive e informa&ccedil;&otilde;es operacionais da Bali BYD.</p>
                    </div>
                    <div class="central-summary" aria-label="Resumo dos atalhos">
                        <div class="central-summary-item"><strong>9</strong><span>atalhos</span></div>
                        <div class="central-summary-item"><strong>BYD</strong><span>opera&ccedil;&atilde;o</span></div>
                    </div>
                </section>

                <section class="central-card-panel">
                    <div class="central-section-title">
                        <div>
                            <h2>Atalhos BYD</h2>
                            <p>Links principais para a rotina comercial e administrativa.</p>
                        </div>
                    </div>

                    <div class="central-link-grid">
                        <a class="central-link-card" href="http://129.13.147.54/workflow/Portal/default.html" data-icon="workflow">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Workflow</span><span class="central-link-caption">Processos</span></span>
                        </a>
                        <a class="central-link-card" href="contrato.aspx" data-icon="contract">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Contrato</span><span class="central-link-caption">Compra e venda</span></span>
                        </a>
                        <a class="central-link-card" href="http://129.13.147.127/intranet/formbyd/" data-icon="direct-sale">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Pedido de VD</span><span class="central-link-caption">Venda direta</span></span>
                        </a>
                        <a class="central-link-card" href="recibo_DescontoBYD.aspx" data-icon="receipt">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Recibo de Desconto</span><span class="central-link-caption">Financeiro</span></span>
                        </a>
                        <a class="central-link-card" href="../admfinanceiro/Recibo/EntregaBYD.aspx" data-icon="delivery">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Entrega do Ve&iacute;culo</span><span class="central-link-caption">Entrega</span></span>
                        </a>
                        <a class="central-link-card" href="testdrive.aspx" data-icon="test-drive">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Termo Test Drive</span><span class="central-link-caption">Experi&ecirc;ncia</span></span>
                        </a>
                        <a class="central-link-card" href="contasbyd.aspx" data-icon="accounts">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Contas Banc&aacute;rias BYD</span><span class="central-link-caption">Financeiro</span></span>
                        </a>
                        <a class="central-link-card" href="domicilio.aspx" data-icon="domicile">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Atualiza&ccedil;&atilde;o de Domic&iacute;lio</span><span class="central-link-caption">Cadastro</span></span>
                        </a>
                        <a class="central-link-card" href="prospeccao.aspx" data-icon="prospecting">
                            <span class="central-link-icon"></span>
                            <span><span class="central-link-title">Prospec&ccedil;&atilde;o</span><span class="central-link-caption">Vendas</span></span>
                        </a>
                    </div>
                </section>

                <footer class="central-footer">
                    <strong>IP:</strong> <asp:Label ID="lblIp" runat="server" Text="Label"></asp:Label>
                    <br />
                    TI - BALI Motors | (61) 3362-6208 | ti@bali.com.br
                </footer>
            </main>
        </div>
    </form>
</body>
</html>
