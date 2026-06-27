<%@ Page Language="C#" AutoEventWireup="true" CodeFile="auditoria.aspx.cs" Inherits="ci_auditoria" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title><%=TituloPagina%> - Auditoria</title>
    <link href="ci.css?v=20260627-ci-auditoria01" rel="stylesheet" />
</head>
<body class="ci-page audit-page">
    <form id="form1" runat="server">
        <a class="skip-link" href="#conteudo">Ir para o conte&uacute;do</a>
        <div class="app-shell">
            <aside class="sidebar">
                <a class="brand" href="default.aspx">
                    <span class="brand-mark">CI</span>
                    <span>
                        <strong>Comunica&ccedil;&atilde;o Interna</strong>
                        <small>Auditoria</small>
                    </span>
                </a>
                <nav class="side-nav" aria-label="Navega&ccedil;&atilde;o da CI">
                    <a href="default.aspx?view=consulta" data-nav-view="consulta">Consulta</a>
                    <a href="default.aspx?view=nova" data-nav-view="nova">Nova CI</a>
                    <a href="default.aspx?view=bi" data-nav-view="bi">BI</a>
                    <a href="erros.aspx" data-nav-view="logs">Logs</a>
                    <a href="../Intranet/index.html">Intranet</a>
                    <a href="/logout.aspx?voltar=/CI/login.aspx">Sair</a>
                </nav>
            </aside>

            <main class="content" id="conteudo" tabindex="-1">
                <header class="hero">
                    <div>
                        <span class="eyebrow">Auditoria da CI</span>
                        <h1><asp:Literal ID="litTitulo" runat="server" Text="Logs da CI"></asp:Literal></h1>
                        <p><asp:Literal ID="litSubtitulo" runat="server" Text="Acompanhe cria&ccedil;&atilde;o, edi&ccedil;&otilde;es, impress&otilde;es, cancelamentos e demais a&ccedil;&otilde;es registradas."></asp:Literal></p>
                    </div>
                    <div class="hero-actions">
                        <asp:HyperLink ID="lnkImprimir" runat="server" CssClass="secondary-link" Target="_blank">Imprimir CI</asp:HyperLink>
                        <a class="primary-link" href="default.aspx?view=consulta">Voltar para consulta</a>
                    </div>
                </header>

                <asp:Panel ID="pnlMensagem" runat="server" CssClass="form-message error" Visible="false">
                    <asp:Literal ID="litMensagem" runat="server"></asp:Literal>
                </asp:Panel>

                <asp:Panel ID="pnlConteudo" runat="server" CssClass="panel" Visible="false">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Resumo</span>
                            <h2>Dados atuais da CI</h2>
                            <p class="panel-subtitle"><asp:Literal ID="litResumo" runat="server"></asp:Literal></p>
                        </div>
                    </div>

                    <div class="audit-summary-grid">
                        <div class="audit-card">
                            <span>C&oacute;digo</span>
                            <strong><asp:Literal ID="litCodigo" runat="server"></asp:Literal></strong>
                        </div>
                        <div class="audit-card">
                            <span>Status</span>
                            <strong><asp:Literal ID="litStatus" runat="server"></asp:Literal></strong>
                        </div>
                        <div class="audit-card">
                            <span>Criada em</span>
                            <strong><asp:Literal ID="litCriadaEm" runat="server"></asp:Literal></strong>
                        </div>
                        <div class="audit-card">
                            <span>&Uacute;ltima altera&ccedil;&atilde;o</span>
                            <strong><asp:Literal ID="litAlteradaEm" runat="server"></asp:Literal></strong>
                        </div>
                        <div class="audit-card">
                            <span>Criado por</span>
                            <strong><asp:Literal ID="litCriadoPor" runat="server"></asp:Literal></strong>
                        </div>
                    </div>

                    <div class="audit-current-data">
                        <asp:Literal ID="litDadosAtuais" runat="server"></asp:Literal>
                    </div>

                    <div class="panel-header compact-header">
                        <div>
                            <span class="eyebrow">Linha do tempo</span>
                            <h3>Eventos registrados</h3>
                            <p class="panel-subtitle"><asp:Literal ID="litResumoTimeline" runat="server"></asp:Literal></p>
                        </div>
                    </div>
                    <div class="table-wrap">
                        <asp:GridView ID="gvLinhaTempo" runat="server" CssClass="ci-table compact-table audit-table" AutoGenerateColumns="false" EmptyDataText="Nenhum evento registrado para esta CI." OnRowDataBound="gvLinhaTempo_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="data_hora" HeaderText="Data/hora" />
                                <asp:BoundField DataField="fonte" HeaderText="Origem" />
                                <asp:BoundField DataField="acao" HeaderText="A&ccedil;&atilde;o" />
                                <asp:BoundField DataField="usuario" HeaderText="Usu&aacute;rio" />
                                <asp:BoundField DataField="detalhe" HeaderText="Detalhe" />
                                <asp:BoundField DataField="dados_antes" HeaderText="Antes" />
                                <asp:BoundField DataField="dados_depois" HeaderText="Depois" />
                                <asp:BoundField DataField="ip" HeaderText="IP" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>
            </main>
        </div>
    </form>
</body>
</html>
