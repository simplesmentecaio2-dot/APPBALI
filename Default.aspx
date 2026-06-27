<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>APP Bali</title>
    <link href="css/bali-app-home.css?v=20260627-root01" rel="stylesheet" />
</head>
<body class="bali-app-home">
    <form id="form1" runat="server">
        <header class="app-topbar">
            <a class="app-brand" href="Default.aspx" aria-label="APP Bali">
                <img src="img/logobali.png?v=20260624-logo2" alt="Bali" />
                <span>APP</span>
            </a>
            <div class="app-user">
                <span>Usu&aacute;rio</span>
                <strong><asp:Label ID="lblUsuario" runat="server" Text=""></asp:Label></strong>
                <small>Perfil: <asp:Label ID="lblTipo" runat="server" Text=""></asp:Label></small>
            </div>
            <nav class="app-actions" aria-label="A&ccedil;&otilde;es">
                <a href="tecnologia/Suporte.aspx">Suporte</a>
                <a href="login.aspx?sair=1">Sair</a>
            </nav>
        </header>

        <main class="app-main">
            <section class="app-hero">
                <div>
                    <span class="app-eyebrow">Grupo Bali</span>
                    <h1>Central de aplicativos</h1>
                    <p>APP Bali</p>
                </div>
                <label class="app-search">
                    <span>Buscar</span>
                    <input id="appSearch" type="search" autocomplete="off" placeholder="Nome, &aacute;rea ou sistema" />
                </label>
            </section>

            <section class="app-section" aria-label="Aplicativos">
                <asp:DataList ID="dlSistemas" runat="server" CssClass="app-grid-list" RepeatDirection="Horizontal" DataSourceID="sqldsSistemas" RepeatLayout="Flow">
                    <ItemTemplate>
                        <a href='<%# Eval("url") %>' class="app-card links" data-system-id='<%# Eval("id_sistema") %>' data-system-url='<%# Eval("url") %>' onclick='<%# Eval("msn") %>'>
                            <span class="app-card-media">
                                <img src='<%# Eval("img_sistema") %>' alt="" />
                            </span>
                            <span class="app-card-body">
                                <span class="app-card-kicker">Aplicativo</span>
                                <strong data-app-title>Sistema</strong>
                                <small data-app-subtitle>Dispon&iacute;vel para o seu perfil</small>
                            </span>
                            <span class="app-card-action">Abrir</span>
                        </a>
                    </ItemTemplate>
                </asp:DataList>

                <div id="appEmptyState" class="app-empty" hidden>
                    Nenhum aplicativo encontrado.
                </div>

                <asp:SqlDataSource ID="sqldsSistemas" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="app_select_sistemas_usuario" SelectCommandType="StoredProcedure">
                    <SelectParameters>
                        <asp:SessionParameter Name="id" SessionField="id" Type="String" />
                    </SelectParameters>
                </asp:SqlDataSource>
            </section>
        </main>
    </form>
    <script src="js/bali-app-home.js?v=20260627-root01"></script>
</body>
</html>
