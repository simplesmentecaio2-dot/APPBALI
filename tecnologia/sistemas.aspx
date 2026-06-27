<%@ Page Language="C#" AutoEventWireup="true" CodeFile="sistemas.aspx.cs" Inherits="tecnologia_sistemas" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Sistemas | Tecnologia</title>
    <link href="../css/bali-tecnologia.css?v=20260627-tech01" rel="stylesheet" />
</head>
<body class="bali-tech-page">
    <form id="form1" runat="server" autocomplete="off">
        <header class="tech-topbar">
            <a class="tech-brand" href="Default.aspx" aria-label="Voltar para tecnologia">
                <img src="../img/logobali.png?v=20260624-logo2" alt="Bali" />
                <span>APP</span>
            </a>
            <div class="tech-user">
                <span>Tecnologia</span>
                <strong><asp:Label ID="lblUsuario" runat="server" /></strong>
                <small>Perfil: <asp:Label ID="lblTipo" runat="server" /></small>
            </div>
            <nav class="tech-actions" aria-label="A&ccedil;&otilde;es r&aacute;pidas">
                <a href="Default.aspx">Voltar</a>
                <a href="../login.aspx?sair=1">Sair</a>
            </nav>
        </header>

        <main class="tech-main">
            <section class="tech-hero">
                <div>
                    <span class="tech-eyebrow">Cat&aacute;logo t&eacute;cnico</span>
                    <h1>Sistemas</h1>
                    <p>Consulte os sistemas usados nas regras de acesso e confira nome, imagem e URL configurada.</p>
                </div>
                <label class="tech-search" for="techSearchSystems">
                    <span>Buscar sistema</span>
                    <input id="techSearchSystems" type="search" autocomplete="off" autocapitalize="off" spellcheck="false" placeholder="Ex.: tecnologia, contrato, intranet" />
                </label>
            </section>

            <section class="tech-panel">
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Sistemas cadastrados</span>
                        <h2>Mapa de acessos</h2>
                        <p>Esses registros s&atilde;o usados pelas permiss&otilde;es de usu&aacute;rios. Altera&ccedil;&otilde;es estruturais devem ser feitas com cautela.</p>
                    </div>
                </div>

                <asp:DataList ID="dlSistemas" runat="server" CssClass="tech-system-list" DataKeyField="id_sistema" DataSourceID="sqldsSistemas" RepeatLayout="Flow">
                    <ItemTemplate>
                        <article class="tech-system-row" data-search='<%# String.Concat(Eval("id_sistema"), " ", Eval("nome"), " ", Eval("img_sistema"), " ", Eval("url_sistema")) %>'>
                            <span>
                                <span class="tech-row-kicker">ID</span>
                                <strong class="tech-row-value"><%# Eval("id_sistema") %></strong>
                            </span>
                            <span>
                                <span class="tech-row-kicker">Sistema</span>
                                <strong class="tech-row-value"><%# Eval("nome") %></strong>
                            </span>
                            <span>
                                <span class="tech-row-kicker">Imagem</span>
                                <code class="tech-row-value"><%# Eval("img_sistema") %></code>
                            </span>
                            <span>
                                <span class="tech-row-kicker">URL</span>
                                <code class="tech-row-value"><%# Eval("url_sistema") %></code>
                            </span>
                        </article>
                    </ItemTemplate>
                </asp:DataList>

                <div id="techEmptySystems" class="tech-empty" hidden>Nenhum sistema encontrado para a busca informada.</div>
                <asp:SqlDataSource ID="sqldsSistemas" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="app_select_sistemas" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
            </section>
        </main>
    </form>
    <script src="../js/bali-tecnologia.js?v=20260627-tech01"></script>
</body>
</html>
