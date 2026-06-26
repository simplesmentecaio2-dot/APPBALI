<%@ Page Language="C#" AutoEventWireup="true" CodeFile="logs.aspx.cs" Inherits="ramais_logs" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Logs | Ramais</title>
    <link href="ramais.css?v=20260626-logs01" rel="stylesheet" />
</head>
<body class="ramais-page">
    <form id="form1" runat="server">
        <a class="skip-link" href="#conteudo">Ir para o conte&uacute;do</a>
        <div class="app-shell">
            <aside class="sidebar">
                <a class="brand" href="default.aspx">
                    <span class="brand-mark">R</span>
                    <span>
                        <strong>Ramais</strong>
                        <small>Logs</small>
                    </span>
                </a>

                <nav class="side-nav" aria-label="Menu de logs dos ramais">
                    <a href="default.aspx?view=consulta">Consulta</a>
                    <a href="default.aspx?view=impressao">Impress&atilde;o</a>
                    <a href="default.aspx?view=ramais">Ramais</a>
                    <a href="default.aspx?view=lojas">Lojas</a>
                    <a href="default.aspx?view=setores">Setores</a>
                    <a href="logs.aspx" class="is-active" aria-current="page">Logs</a>
                    <a href="../Intranet/index.html">Intranet</a>
                    <a href="/logout.aspx?voltar=/RAMAIS/login.aspx">Sair</a>
                </nav>
            </aside>

            <main class="content" id="conteudo" tabindex="-1">
                <header class="hero">
                    <div>
                        <span class="eyebrow">Monitoramento</span>
                        <h1>Logs dos Ramais</h1>
                        <p>Consulte erros, acessos e altera&ccedil;&otilde;es realizadas no sistema de ramais.</p>
                    </div>
                    <div class="hero-actions">
                        <a class="secondary-link" href="default.aspx?view=consulta">Voltar para consulta</a>
                    </div>
                </header>

                <asp:Panel ID="pnlMensagem" runat="server" CssClass="form-message error" Visible="false">
                    <asp:Literal ID="litMensagem" runat="server"></asp:Literal>
                </asp:Panel>

                <asp:Panel ID="pnlLogin" runat="server" CssClass="panel">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Acesso protegido</span>
                            <h2>Informe a senha de manuten&ccedil;&atilde;o</h2>
                            <p class="panel-subtitle">Use a senha administrativa para abrir os logs dos Ramais.</p>
                        </div>
                    </div>
                    <div class="filter-grid">
                        <label>Senha
                            <asp:TextBox ID="txtSenha" runat="server" CssClass="text-field" TextMode="Password" autocomplete="current-password"></asp:TextBox>
                        </label>
                        <asp:Button ID="btnEntrar" runat="server" Text="Entrar" CssClass="primary-button" OnClick="btnEntrar_Click" />
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlConteudo" runat="server" CssClass="panel" Visible="false">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Erros recentes</span>
                            <h2>Ocorr&ecirc;ncias registradas</h2>
                            <p class="panel-subtitle"><asp:Literal ID="litResumo" runat="server"></asp:Literal></p>
                        </div>
                        <div class="panel-tools">
                            <label>Linhas
                                <asp:DropDownList ID="ddlLogsPageSize" runat="server" CssClass="select-field" AutoPostBack="true" OnSelectedIndexChanged="ddlLogsPageSize_SelectedIndexChanged">
                                    <asp:ListItem Value="20">20</asp:ListItem>
                                    <asp:ListItem Value="50">50</asp:ListItem>
                                    <asp:ListItem Value="100">100</asp:ListItem>
                                </asp:DropDownList>
                            </label>
                            <asp:Button ID="btnAtualizar" runat="server" Text="Atualizar" CssClass="secondary-button" OnClick="btnAtualizar_Click" />
                        </div>
                    </div>

                    <div class="filter-grid">
                        <label>Buscar
                            <asp:TextBox ID="txtBuscaLogs" runat="server" CssClass="text-field" MaxLength="120" placeholder="Origem, usu&aacute;rio, ramal, IP ou erro" autocomplete="off"></asp:TextBox>
                        </label>
                        <asp:Button ID="btnFiltrarLogs" runat="server" Text="Filtrar" CssClass="primary-button" OnClick="btnFiltrarLogs_Click" />
                        <asp:Button ID="btnLimparLogs" runat="server" Text="Limpar" CssClass="secondary-button" OnClick="btnLimparLogs_Click" />
                    </div>

                    <div class="table-wrap">
                        <asp:GridView ID="gvErros" runat="server" CssClass="ramais-table" AutoGenerateColumns="false" EmptyDataText="Nenhum erro registrado." AllowPaging="true" AllowSorting="true" PageSize="20" PagerStyle-CssClass="ramais-pager" OnPageIndexChanging="gvErros_PageIndexChanging" OnSorting="gvErros_Sorting" OnRowDataBound="gvErros_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="data_hora" HeaderText="Data/hora" SortExpression="data_hora" />
                                <asp:BoundField DataField="origem" HeaderText="Origem" SortExpression="origem" />
                                <asp:BoundField DataField="usuario" HeaderText="Usu&aacute;rio" SortExpression="usuario" />
                                <asp:BoundField DataField="url" HeaderText="URL" SortExpression="url" />
                                <asp:BoundField DataField="erro" HeaderText="Erro" SortExpression="erro" />
                            </Columns>
                        </asp:GridView>
                    </div>

                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Auditoria</span>
                            <h2>A&ccedil;&otilde;es dos usu&aacute;rios</h2>
                            <p class="panel-subtitle"><asp:Literal ID="litResumoAuditoria" runat="server"></asp:Literal></p>
                        </div>
                    </div>

                    <div class="table-wrap">
                        <asp:GridView ID="gvAuditoria" runat="server" CssClass="ramais-table" AutoGenerateColumns="false" EmptyDataText="Nenhuma auditoria registrada." OnRowDataBound="gvAuditoria_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="dt_evento" HeaderText="Data/hora" DataFormatString="{0:dd/MM/yyyy HH:mm:ss}" />
                                <asp:BoundField DataField="usuario_nome" HeaderText="Usu&aacute;rio" />
                                <asp:BoundField DataField="acao" HeaderText="A&ccedil;&atilde;o" />
                                <asp:BoundField DataField="ramal" HeaderText="Ramal" />
                                <asp:BoundField DataField="detalhe" HeaderText="Detalhe" />
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
