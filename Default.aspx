<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>APP Bali | Central de aplicativos</title>
    <link href="css/central-links.css?v=20260628-home-footer" rel="stylesheet" />
    <script src="js/bali-app-home.js?v=20260627-maint01" defer="defer"></script>
    <script src="js/central-links-icons.js?v=20260627-maint01" defer="defer"></script>
    <script src="js/central-links-maintenance.js?v=20260627-maint01" defer="defer"></script>
</head>
<body class="central-links-page brand-app" data-brand-name="APP Bali" data-links-api="central-links.ashx?AspxAutoDetectCookieSupport=1" data-icon-base="img/central-icons/">
    <form id="form1" runat="server">
        <div class="central-shell">
            <header class="central-topbar">
                <div class="central-topbar-inner">
                    <a class="central-brand" href="Default.aspx" aria-label="APP Bali">
                        <img src="img/logobali.png?v=20260624-logo2" alt="Bali" />
                        <span class="central-brand-copy">
                            <strong>APP Bali</strong>
                            <span>Central de aplicativos</span>
                        </span>
                    </a>
                    <div class="central-user">
                        <div>Usu&aacute;rio: <span><asp:Label ID="lblUsuario" runat="server" Text=""></asp:Label></span></div>
                        <div>C&oacute;digo: <span><asp:Label ID="lblTipo" runat="server" Text=""></asp:Label></span></div>
                        <a class="central-logout-button" href="/logout.aspx?voltar=/login.aspx">Sair</a>
                    </div>
                </div>
            </header>

            <main class="central-main">
                <section class="central-hero">
                    <div>
                        <span class="central-eyebrow">Grupo Bali</span>
                        <h1>Central de aplicativos</h1>
                        <p>Acesse os sistemas internos liberados para o seu perfil e organize os atalhos principais da opera&ccedil;&atilde;o.</p>
                    </div>
                    <div class="central-summary" aria-label="Resumo dos atalhos">
                        <div class="central-summary-item"><strong>0</strong><span>atalhos</span></div>
                        <div class="central-summary-item"><strong>APP</strong><span>Bali</span></div>
                    </div>
                </section>

                <section class="central-card-panel">
                    <div class="central-section-title">
                        <div>
                            <h2>Aplicativos</h2>
                            <p>Sistemas dispon&iacute;veis para o usu&aacute;rio logado.</p>
                        </div>
                    </div>

                    <asp:DataList ID="dlSistemas" runat="server" CssClass="central-link-grid" RepeatDirection="Horizontal" DataSourceID="sqldsSistemas" RepeatLayout="Flow">
                        <ItemTemplate>
                            <a href='<%# Eval("url") %>' class="central-link-card links" data-system-id='<%# Eval("id_sistema") %>' data-system-url='<%# Eval("url") %>' data-icon="default" onclick='<%# Eval("msn") %>'>
                                <span class="central-link-icon"></span>
                                <span>
                                    <span class="central-link-title">Sistema</span>
                                    <span class="central-link-caption">Dispon&iacute;vel para o seu perfil</span>
                                </span>
                            </a>
                        </ItemTemplate>
                    </asp:DataList>

                    <asp:SqlDataSource ID="sqldsSistemas" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="app_select_sistemas_usuario" SelectCommandType="StoredProcedure">
                        <SelectParameters>
                            <asp:SessionParameter Name="id" SessionField="id" Type="String" />
                        </SelectParameters>
                    </asp:SqlDataSource>
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
