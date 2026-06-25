<%@ Page Language="C#" AutoEventWireup="true" CodeFile="erros.aspx.cs" Inherits="ci_erros" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Logs da CI</title>
    <link href="ci.css?v=20260625-ci-logs-nav" rel="stylesheet" />
</head>
<body class="ci-page">
    <form id="form1" runat="server">
        <a class="skip-link" href="#conteudo">Ir para o conte&uacute;do</a>
        <div class="app-shell">
            <aside class="sidebar">
                <a class="brand" href="default.aspx">
                    <span class="brand-mark">CI</span>
                    <span>
                        <strong>Comunica&ccedil;&atilde;o Interna</strong>
                        <small>Logs</small>
                    </span>
                </a>
                <nav class="side-nav" aria-label="Navega&ccedil;&atilde;o da CI">
                    <a href="default.aspx?view=consulta" data-nav-view="consulta">Consulta</a>
                    <a href="default.aspx?view=nova" data-nav-view="nova">Nova CI</a>
                    <a href="erros.aspx" data-nav-view="logs" class="is-active" aria-current="page">Logs</a>
                    <a href="../Intranet/index.html">Intranet</a>
                </nav>
            </aside>

            <main class="content" id="conteudo" tabindex="-1">
                <header class="hero">
                    <div>
                        <span class="eyebrow">Monitoramento</span>
                        <h1>Logs da CI</h1>
                        <p>Consulte as falhas registradas pelo m&oacute;dulo de comunica&ccedil;&atilde;o interna.</p>
                    </div>
                    <a class="secondary-link" href="default.aspx">Voltar para CI</a>
                </header>

                <asp:Panel ID="pnlMensagem" runat="server" CssClass="form-message error" Visible="false">
                    <asp:Literal ID="litMensagem" runat="server"></asp:Literal>
                </asp:Panel>

                <asp:Panel ID="pnlLogin" runat="server" CssClass="panel">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Acesso protegido</span>
                            <h2>Informe a senha</h2>
                            <p class="panel-subtitle">Use a senha administrativa da CI para abrir os logs.</p>
                        </div>
                    </div>
                    <div class="filter-grid log-filter">
                        <label>Senha
                            <asp:TextBox ID="txtSenha" runat="server" CssClass="text-field" TextMode="Password"></asp:TextBox>
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
                        <asp:Button ID="btnAtualizar" runat="server" Text="Atualizar" CssClass="secondary-button" OnClick="btnAtualizar_Click" />
                    </div>
                    <div class="table-wrap">
                        <asp:GridView ID="gvErros" runat="server" CssClass="ci-table compact-table" AutoGenerateColumns="false" EmptyDataText="Nenhum erro registrado." OnRowDataBound="gvErros_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="data_hora" HeaderText="Data/hora" />
                                <asp:BoundField DataField="origem" HeaderText="Origem" />
                                <asp:BoundField DataField="usuario" HeaderText="Usu&aacute;rio" />
                                <asp:BoundField DataField="url" HeaderText="URL" />
                                <asp:BoundField DataField="erro" HeaderText="Erro" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>
            </main>
        </div>
    </form>
</body>
</html>
