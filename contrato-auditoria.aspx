<%@ Page Language="C#" AutoEventWireup="true" CodeFile="contrato-auditoria.aspx.cs" Inherits="contrato_auditoria" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title><%=TituloPagina%></title>
    <link href="css/bali-contract.css?v=20260627-contrato-log01" rel="stylesheet" />
</head>
<body class="bali-contract-page <%=ClasseMarca%> contract-audit-detail-page">
    <form id="form1" runat="server">
        <main class="contract-audit-detail-shell">
            <header class="contract-audit-detail-hero">
                <div>
                    <span class="contract-bi-kicker">Auditoria do contrato</span>
                    <h1><asp:Literal ID="litTitulo" runat="server" Text="Logs do contrato"></asp:Literal></h1>
                    <p><asp:Literal ID="litSubtitulo" runat="server" Text="Cria&ccedil;&atilde;o, edi&ccedil;&otilde;es, impress&otilde;es, valida&ccedil;&otilde;es e ocorr&ecirc;ncias registradas."></asp:Literal></p>
                </div>
                <div class="contract-audit-detail-actions">
                    <asp:HyperLink ID="lnkImprimir" runat="server" CssClass="contract-audit-detail-link" Target="_blank">Imprimir contrato</asp:HyperLink>
                    <asp:HyperLink ID="lnkVoltar" runat="server" CssClass="contract-audit-detail-link primary">Voltar</asp:HyperLink>
                </div>
            </header>

            <asp:Panel ID="pnlMensagem" runat="server" CssClass="contract-audit-detail-message" Visible="false">
                <asp:Literal ID="litMensagem" runat="server"></asp:Literal>
            </asp:Panel>

            <asp:Panel ID="pnlConteudo" runat="server" Visible="false">
                <section class="contract-audit-detail-cards">
                    <article>
                        <span>Contrato</span>
                        <strong><asp:Literal ID="litContrato" runat="server"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Marca</span>
                        <strong><asp:Literal ID="litMarca" runat="server"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Tipo</span>
                        <strong><asp:Literal ID="litTipo" runat="server"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Eventos</span>
                        <strong><asp:Literal ID="litEventos" runat="server"></asp:Literal></strong>
                    </article>
                </section>

                <section class="contract-audit-detail-current">
                    <div class="contract-audit-detail-section-title">
                        <span class="contract-bi-kicker">Dados atuais</span>
                        <h2>Resumo do contrato</h2>
                    </div>
                    <asp:Literal ID="litDadosContrato" runat="server"></asp:Literal>
                </section>

                <section class="contract-audit-detail-timeline">
                    <div class="contract-audit-detail-section-title">
                        <span class="contract-bi-kicker">Linha do tempo</span>
                        <h2>Eventos registrados</h2>
                        <p><asp:Literal ID="litResumoTimeline" runat="server"></asp:Literal></p>
                    </div>
                    <div class="contract-audit-detail-table-wrap">
                        <asp:GridView ID="gvAuditoria" runat="server" CssClass="contract-audit-detail-table" AutoGenerateColumns="false" EmptyDataText="Nenhum evento encontrado para este contrato." OnRowDataBound="gvAuditoria_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="data_hora" HeaderText="Data/hora" />
                                <asp:BoundField DataField="origem" HeaderText="Origem" />
                                <asp:BoundField DataField="acao" HeaderText="A&ccedil;&atilde;o" />
                                <asp:BoundField DataField="usuario" HeaderText="Usu&aacute;rio" />
                                <asp:BoundField DataField="detalhe" HeaderText="Detalhe" />
                                <asp:BoundField DataField="antes" HeaderText="Antes" />
                                <asp:BoundField DataField="depois" HeaderText="Depois" />
                                <asp:BoundField DataField="ip" HeaderText="IP" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </section>
            </asp:Panel>
        </main>
    </form>
</body>
</html>
