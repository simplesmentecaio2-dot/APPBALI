<%@ Page Language="C#" AutoEventWireup="true" CodeFile="print.aspx.cs" Inherits="ci_print" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title><%=CodigoCI%> - Impressão</title>
    <link href="ci.css?v=20260624-ci-ramais2" rel="stylesheet" />
</head>
<body class="ci-print-page <%=MarcaClasse%>">
    <form id="form1" runat="server">
        <main class="print-sheet">
            <header class="print-header">
                <div class="print-logo-wrap">
                    <asp:Image ID="imgLogo" runat="server" CssClass="print-logo" Visible="false" />
                    <asp:Literal ID="litLogoTexto" runat="server"></asp:Literal>
                </div>
                <div class="print-title">
                    <span>Comunicação Interna</span>
                    <h1><asp:Literal ID="litCodigo" runat="server"></asp:Literal></h1>
                </div>
            </header>

            <section class="print-meta">
                <div><span>Data</span><strong><asp:Literal ID="litData" runat="server"></asp:Literal></strong></div>
                <div><span>Marca</span><strong><asp:Literal ID="litMarca" runat="server"></asp:Literal></strong></div>
                <div><span>Categoria</span><strong><asp:Literal ID="litCategoria" runat="server"></asp:Literal></strong></div>
                <div><span>Prioridade</span><strong><asp:Literal ID="litPrioridade" runat="server"></asp:Literal></strong></div>
            </section>

            <section class="print-grid">
                <div>
                    <span>Origem</span>
                    <strong><asp:Literal ID="litOrigemArea" runat="server"></asp:Literal></strong>
                    <small><asp:Literal ID="litOrigemResponsavel" runat="server"></asp:Literal></small>
                </div>
                <div>
                    <span>Destino</span>
                    <strong><asp:Literal ID="litDestinoArea" runat="server"></asp:Literal></strong>
                    <small><asp:Literal ID="litDestinatario" runat="server"></asp:Literal></small>
                </div>
            </section>

            <section class="print-block">
                <span>Assunto</span>
                <h2><asp:Literal ID="litAssunto" runat="server"></asp:Literal></h2>
            </section>

            <section class="print-block">
                <span>Comunicação</span>
                <asp:Literal ID="litCorpo" runat="server"></asp:Literal>
            </section>

            <section class="print-block" id="secProvidencias" runat="server">
                <span>Providências solicitadas</span>
                <asp:Literal ID="litProvidencias" runat="server"></asp:Literal>
            </section>

            <section class="print-block" id="secObservacoes" runat="server">
                <span>Observações</span>
                <asp:Literal ID="litObservacoes" runat="server"></asp:Literal>
            </section>

            <footer class="print-footer">
                <div>
                    <span>Emitido por</span>
                    <strong><asp:Literal ID="litCriadoPor" runat="server"></asp:Literal></strong>
                </div>
                <div class="signature">
                    <span>Assinatura / ciência</span>
                </div>
            </footer>
        </main>
        <div class="print-actions">
            <button type="button" onclick="window.print()">Imprimir</button>
            <a href="default.aspx">Voltar</a>
        </div>
    </form>
</body>
</html>
