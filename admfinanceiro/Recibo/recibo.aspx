<%@ Page Language="C#" AutoEventWireup="true" CodeFile="recibo.aspx.cs" Inherits="admfinanceiro_Comissao_geral" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Recibo Financeiro | Grupo Bali</title>
    <link href="../../css/recibo-financeiro.css?v=20260627-recibo01" rel="stylesheet" />
    <script src="../../js/recibo-financeiro.js?v=20260627-recibo01" defer="defer"></script>
</head>
<body class="receipt-page">
    <form id="form1" runat="server" autocomplete="off">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <header class="receipt-topbar no-print">
            <a class="receipt-brand" href="../Default.aspx" aria-label="Voltar para a central financeira">
                <img src="../../img/logobali.png" alt="Bali" />
                <span>
                    <strong>Financeiro Bali</strong>
                    <small>Gerador de recibos</small>
                </span>
            </a>
            <div class="receipt-user">
                <div>Usu&aacute;rio: <strong><asp:Label ID="lblUsuario" runat="server" Text="-"></asp:Label></strong></div>
                <div>C&oacute;digo: <strong><asp:Label ID="lblTipo" runat="server" Text="-"></asp:Label></strong></div>
                <a href="/logout.aspx?voltar=/login.aspx">Sair</a>
            </div>
        </header>

        <main class="receipt-shell">
            <section class="receipt-hero no-print">
                <div>
                    <span class="receipt-eyebrow">Administra&ccedil;&atilde;o financeira</span>
                    <h1>Recibo financeiro</h1>
                    <p>Preencha os dados, ajuste o texto livremente, reutilize modelos padr&atilde;o e gere uma impress&atilde;o limpa em uma folha.</p>
                </div>
                <div class="receipt-quick-actions">
                    <button type="button" data-action="reset-form">Limpar</button>
                    <button type="button" data-action="print" disabled="disabled">Imprimir recibo</button>
                </div>
            </section>

            <section class="receipt-workspace">
                <div class="receipt-card receipt-form-panel no-print">
                    <div class="receipt-card-head">
                        <div>
                            <span>Dados do recibo</span>
                            <h2>Informa&ccedil;&otilde;es principais</h2>
                        </div>
                    </div>

                    <div class="receipt-form-grid">
                        <div class="receipt-field receipt-field-full">
                            <span>Tipo</span>
                            <div class="receipt-segmented">
                                <div class="receipt-choice">
                                    <asp:RadioButton ID="rBtnVendas" GroupName="tipo" Checked="True" runat="server" Text="Vendas" />
                                </div>
                                <div class="receipt-choice">
                                    <asp:RadioButton ID="rBtnSupervisao" GroupName="tipo" runat="server" Text="Supervis&atilde;o" />
                                </div>
                            </div>
                        </div>

                        <label class="receipt-field" for="<%=ddListMes.ClientID%>">
                            <span>M&ecirc;s de refer&ecirc;ncia</span>
                            <asp:DropDownList ID="ddListMes" runat="server">
                                <asp:ListItem Value="1">JANEIRO</asp:ListItem>
                                <asp:ListItem Value="2">FEVEREIRO</asp:ListItem>
                                <asp:ListItem Value="3">MAR&Ccedil;O</asp:ListItem>
                                <asp:ListItem Value="4">ABRIL</asp:ListItem>
                                <asp:ListItem Value="5">MAIO</asp:ListItem>
                                <asp:ListItem Value="6">JUNHO</asp:ListItem>
                                <asp:ListItem Value="7">JULHO</asp:ListItem>
                                <asp:ListItem Value="8">AGOSTO</asp:ListItem>
                                <asp:ListItem Value="9">SETEMBRO</asp:ListItem>
                                <asp:ListItem Value="10">OUTUBRO</asp:ListItem>
                                <asp:ListItem Value="11">NOVEMBRO</asp:ListItem>
                                <asp:ListItem Value="12">DEZEMBRO</asp:ListItem>
                            </asp:DropDownList>
                        </label>

                        <label class="receipt-field" for="<%=txtValor.ClientID%>">
                            <span>Valor</span>
                            <asp:TextBox ID="txtValor" CssClass="receipt-money" runat="server" Text="R$ 0,00" inputmode="numeric"></asp:TextBox>
                        </label>

                        <label class="receipt-field receipt-field-full" for="<%=txtFavorecido.ClientID%>">
                            <span>Favorecido</span>
                            <asp:TextBox ID="txtFavorecido" runat="server" MaxLength="120" placeholder="Digite o nome completo do favorecido"></asp:TextBox>
                        </label>
                    </div>

                    <div class="receipt-card-head receipt-template-head">
                        <div>
                            <span>Modelos padr&atilde;o</span>
                            <h2>Texto do recibo</h2>
                        </div>
                    </div>

                    <div class="receipt-template-grid">
                        <label class="receipt-field">
                            <span>Selecionar modelo</span>
                            <select id="receiptTemplateSelect"></select>
                        </label>
                        <label class="receipt-field">
                            <span>Nome do modelo</span>
                            <input id="receiptTemplateName" type="text" maxlength="80" placeholder="Ex.: premia&ccedil;&atilde;o vendas" />
                        </label>
                        <div class="receipt-template-actions">
                            <button type="button" data-template="apply">Aplicar</button>
                            <button type="button" data-template="save">Salvar modelo</button>
                            <button type="button" data-template="delete">Excluir</button>
                        </div>
                    </div>

                    <label class="receipt-field receipt-field-full receipt-editor" for="<%=txtTextoRecibo.ClientID%>">
                        <span>Texto edit&aacute;vel</span>
                        <asp:TextBox ID="txtTextoRecibo" runat="server" TextMode="MultiLine" Rows="8"></asp:TextBox>
                    </label>

                    <div class="receipt-hints">
                        <strong>Vari&aacute;veis dispon&iacute;veis:</strong>
                        <code>{empresa}</code>
                        <code>{valor}</code>
                        <code>{valor_extenso}</code>
                        <code>{mes}</code>
                        <code>{tipo}</code>
                        <code>{favorecido}</code>
                        <code>{data}</code>
                    </div>

                    <asp:Label ID="lblMensagem" runat="server" CssClass="receipt-message" EnableViewState="false"></asp:Label>

                    <div class="receipt-actions">
                        <button type="button" data-action="rebuild-text">Recriar texto autom&aacute;tico</button>
                        <asp:Button ID="btnGerarRecibo" runat="server" Text="Gerar pr&eacute;via" OnClick="btnGerarRecibo_Click" CssClass="receipt-primary-button" />
                    </div>
                </div>

                <aside class="receipt-card receipt-preview-panel">
                    <div class="receipt-card-head no-print">
                        <div>
                            <span>Pr&eacute;via</span>
                            <h2>Recibo para impress&atilde;o</h2>
                        </div>
                    </div>

                    <asp:Panel ID="pnlImpressao" Visible="false" runat="server" CssClass="receipt-print-area">
                        <article class="receipt-document" id="recibo">
                            <header class="receipt-document-header">
                                <div>
                                    <img src="../../img/logobali.png" alt="Bali" />
                                    <span>Grupo Bali</span>
                                </div>
                                <strong><asp:Label ID="lblValorRecibo" runat="server"></asp:Label></strong>
                            </header>

                            <h2>Recibo</h2>

                            <section class="receipt-document-text">
                                <asp:Literal ID="litTextoRecibo" runat="server" Mode="Encode"></asp:Literal>
                            </section>

                            <p class="receipt-document-closing">Por ser a express&atilde;o da verdade, firmo o presente recibo.</p>

                            <p class="receipt-document-date">Bras&iacute;lia-DF, <asp:Label ID="lbldtAtual" runat="server"></asp:Label>.</p>

                            <section class="receipt-signature">
                                <span></span>
                                <strong><asp:Label ID="lblFavorecido" runat="server"></asp:Label></strong>
                            </section>
                        </article>
                    </asp:Panel>

                    <div id="receiptEmptyPreview" class="receipt-empty-preview no-print" runat="server">
                        Preencha os dados e clique em <strong>Gerar pr&eacute;via</strong> para visualizar o recibo.
                    </div>
                </aside>
            </section>
        </main>
    </form>
</body>
</html>
