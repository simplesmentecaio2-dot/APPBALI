<%@ Page Language="C#" AutoEventWireup="true" CodeFile="recibo-auditoria.aspx.cs" Inherits="ReciboAuditoria" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Auditoria de Recibos e Entregas</title>
    <link href="css/estilo.css" rel="stylesheet" />
    <link href="css/bali-utility.css?v=20260707-recibo09" rel="stylesheet" />
</head>
<body class="bali-utility-page utility-fiat utility-no-sidebar bali-audit-page">
    <form id="form1" runat="server">
        <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo">
                        <font id="logo" style="font-family: Arial black; font-size: 32px; font-style: italic; color: white; margin-left: 13px;">
                            <a href="/Default.aspx" class="linkHome">BALI</a>
                        </font>
                        <font style="font-family: Calibri; font-size: 14px; margin-left: 5px; font-style: italic; color: white;">APP</font>
                    </td>
                    <td id="table-menu-usuario" class="idUser">
                        Usuário: <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" />
                        Código: <asp:Label ID="lblCodigo" CssClass="idUser" runat="server" />
                        <a class="bali-logout-link" href="/logout.aspx?voltar=/login.aspx">Sair</a>
                    </td>
                </tr>
            </table>
        </div>
        <div id="linha-branca"></div>
        <div id="menu-topo"></div>
        <div id="menu">
            <button type="button" class="bali-back-button" onclick="if (window.history.length > 1) { window.history.back(); } else { window.location.href='/Default.aspx'; }">&larr; Voltar</button>
            <div style="text-align: right; margin-right: 15px;">
                <asp:Label ID="lblFrmID" runat="server" Text="Auditoria de Recibos e Entregas"></asp:Label>
            </div>
        </div>

        <main class="bali-audit-shell">
            <section class="bali-audit-hero">
                <small>Auditoria</small>
                <h1>Recibos e entregas gerados</h1>
                <p>Consulte quem gerou ou imprimiu documentos, por marca, pedido, loja e período.</p>
            </section>

            <section class="bali-audit-filters">
                <label>Data inicial
                    <asp:TextBox ID="txtDataInicial" runat="server" TextMode="Date"></asp:TextBox>
                </label>
                <label>Data final
                    <asp:TextBox ID="txtDataFinal" runat="server" TextMode="Date"></asp:TextBox>
                </label>
                <label>Marca
                    <asp:DropDownList ID="ddlMarca" runat="server">
                        <asp:ListItem Text="Todas" Value=""></asp:ListItem>
                        <asp:ListItem Text="Fiat" Value="Fiat"></asp:ListItem>
                        <asp:ListItem Text="Jeep" Value="Jeep"></asp:ListItem>
                        <asp:ListItem Text="BYD" Value="BYD"></asp:ListItem>
                    </asp:DropDownList>
                </label>
                <label>Ação
                    <asp:DropDownList ID="ddlAcao" runat="server">
                        <asp:ListItem Text="Todas" Value=""></asp:ListItem>
                        <asp:ListItem Text="Gerado" Value="gerado"></asp:ListItem>
                        <asp:ListItem Text="Impressão" Value="impressao"></asp:ListItem>
                        <asp:ListItem Text="Erro" Value="erro"></asp:ListItem>
                    </asp:DropDownList>
                </label>
                <label>Pedido
                    <asp:TextBox ID="txtPedido" runat="server" autocomplete="off"></asp:TextBox>
                </label>
                <label>Loja
                    <asp:TextBox ID="txtLoja" runat="server" autocomplete="off"></asp:TextBox>
                </label>
                <label>Usuário
                    <asp:TextBox ID="txtUsuario" runat="server" autocomplete="off"></asp:TextBox>
                </label>
                <label>Busca geral
                    <asp:TextBox ID="txtBusca" runat="server" autocomplete="off" placeholder="cliente, veículo, pedido, IP..."></asp:TextBox>
                </label>
                <div class="bali-audit-actions">
                    <asp:Button ID="btnFiltrar" runat="server" Text="Filtrar" CssClass="btns" OnClick="btnFiltrar_Click" />
                    <asp:Button ID="btnLimpar" runat="server" Text="Limpar" CssClass="bali-audit-secondary" OnClick="btnLimpar_Click" />
                    <asp:Button ID="btnExportar" runat="server" Text="Exportar CSV" CssClass="bali-audit-secondary" OnClick="btnExportar_Click" />
                    <asp:Button ID="btnHoje" runat="server" Text="Hoje" CssClass="bali-audit-secondary" OnClick="btnHoje_Click" />
                    <asp:Button ID="btnSeteDias" runat="server" Text="7 dias" CssClass="bali-audit-secondary" OnClick="btnSeteDias_Click" />
                    <asp:Button ID="btnMesAtual" runat="server" Text="Este mês" CssClass="bali-audit-secondary" OnClick="btnMesAtual_Click" />
                </div>
            </section>

            <section class="bali-audit-summary">
                <article><small>Total</small><strong><asp:Literal ID="litTotal" runat="server" /></strong></article>
                <article><small>Gerados</small><strong><asp:Literal ID="litGerados" runat="server" /></strong></article>
                <article><small>Impressões</small><strong><asp:Literal ID="litImpressoes" runat="server" /></strong></article>
                <article><small>Erros</small><strong><asp:Literal ID="litErros" runat="server" /></strong></article>
                <article><small>Usuários</small><strong><asp:Literal ID="litUsuarios" runat="server" /></strong></article>
                <article><small>Fiat</small><strong><asp:Literal ID="litFiat" runat="server" /></strong></article>
                <article><small>Jeep</small><strong><asp:Literal ID="litJeep" runat="server" /></strong></article>
                <article><small>BYD</small><strong><asp:Literal ID="litByd" runat="server" /></strong></article>
            </section>

            <asp:Panel ID="pnlMensagem" runat="server" CssClass="bali-audit-empty" Visible="false">
                Nenhum registro encontrado para os filtros selecionados.
            </asp:Panel>

            <section class="bali-audit-table">
                <asp:GridView ID="gvLogs" runat="server" AutoGenerateColumns="false" GridLines="None" CssClass="bali-data-table" AllowPaging="true" PageSize="30" OnPageIndexChanging="gvLogs_PageIndexChanging" OnRowDataBound="gvLogs_RowDataBound">
                    <Columns>
                        <asp:BoundField DataField="Data" HeaderText="Data" />
                        <asp:BoundField DataField="Acao" HeaderText="Ação" />
                        <asp:BoundField DataField="Marca" HeaderText="Marca" />
                        <asp:BoundField DataField="Tipo" HeaderText="Tipo" />
                        <asp:BoundField DataField="Pedido" HeaderText="Pedido" />
                        <asp:BoundField DataField="Loja" HeaderText="Loja" />
                        <asp:BoundField DataField="Usuario" HeaderText="Usuário" />
                        <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                        <asp:BoundField DataField="Veiculo" HeaderText="Veículo" />
                        <asp:BoundField DataField="Mensagem" HeaderText="Mensagem" />
                        <asp:BoundField DataField="Ip" HeaderText="IP" />
                    </Columns>
                    <PagerStyle CssClass="bali-audit-pager" />
                </asp:GridView>
            </section>
        </main>
    </form>
</body>
</html>
