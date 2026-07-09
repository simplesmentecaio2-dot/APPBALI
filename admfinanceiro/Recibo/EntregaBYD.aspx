<%@ page language="C#" autoeventwireup="true" codefile="EntregaBYD.aspx.cs" inherits="admfinanceiro_Recibo_Entrega" %>

<%@ register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>Entrega de Veículo - BYD</title>
    <link href="../../css/estilo.css" rel="stylesheet" />
    <link href="../../css/bali-utility.css?v=20260707-recibo13" rel="stylesheet" />
    <link href="../../css/entrega-veiculo.css?v=20260708-entrega08" rel="stylesheet" />
    <script src="../../js/jquery-1.10.2.js"></script>
    <script src="../../js/js.js"></script>
    <script src="../../js/bali-utility-print.js?v=20260708-entrega08"></script>

</head>

<body class="bali-utility-page utility-byd utility-no-sidebar delivery-receipt-page">
    <form id="form1" runat="server">
        <asp:scriptmanager id="ScriptManager1" enablescriptglobalization="true" runat="server">
                </asp:scriptmanager>
        <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo">
                        <font id="logo"
                            style="font-family: Arial black; font-size: 32px; font-style: italic; color: white; margin-left: 13px;">
                                    <a href="../../Default.aspx" class="linkHome">BYD</a></font>
                        <font
                            style="font-family: Calibri; font-size: 14px; margin-left: 5px; font-style: italic; color: white;">
                                    APP</font><%--<img src="img/logo4.png"
                                    style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%>
                    </td>
                    <td id="table-menu-usuario" class="idUser">Usuário:
                                <asp:label id="lblUsuario" cssclass="idUser" runat="server" text=""></asp:label>
                        C&oacute;digo:
                                <asp:label id="lblTipo" cssclass="idUser" runat="server" style="margin-right: 13px;"
                                    text=""></asp:label>
                    <a class="bali-logout-link" href="/logout.aspx?voltar=/byd/loginAppcontrato.aspx">Sair</a></td>
                </tr>
            </table>
        </div>
        <div id="linha-branca"></div>
        <div id="menu-topo">
        </div>
        <div id="menu">
            <button type="button" class="bali-back-button" onclick="if (window.history.length > 1) { window.history.back(); } else { window.location.href='../../byd/Principal.aspx'; }">&larr; Voltar</button>
            <div style="text-align: right; margin-right: 15px;">
                <asp:label id="lblFrmID" runat="server" text="Entrega de Veículo"></asp:label>
            </div>
        </div>


        <div id="Cont" onmouseover="esconderMenuLeftMouse()">
            <table style="width: 100%; padding: 13px; text-align: left;" align="center">
                <tr style="width: 100%;">
                    <td style="width: 100%;">

                        <asp:tabcontainer id="TabContainerProcesso" cssclass="tabPanelConsultar"
                            width="100%" runat="server" activetabindex="0">
                                        <asp:TabPanel Style="padding: 20px;" runat="server" HeaderText="TabPanel1"
                                            ID="TabPanelProcessos">
                                            <HeaderTemplate>
                                                Autorização de entrega

</HeaderTemplate>
<ContentTemplate>
<fieldset class="delivery-query-card"><legend>Consulta da entrega</legend>Pedido: <button type="button" class="delivery-inline-back" onclick="if (window.history.length > 1) { window.history.back(); } else { window.location.href='../../byd/Principal.aspx'; }">Voltar</button><asp:TextBox ID="txtpedido" runat="server" MaxLength="12"></asp:TextBox>Cód. Loja: <asp:TextBox ID="txtLoja" runat="server" MaxLength="3"></asp:TextBox><asp:Button ID="btnGerar" runat="server" Text="Gerar" OnClick="btnGerar_Click" CssClass="btns" /><asp:Button ID="btnLimpar" runat="server" Text="Limpar" OnClick="btnLimpar_Click" CausesValidation="false" CssClass="btns" />





                                     <br />
                                                    <img src="../../img/imprimir.png" style="width: 30px; cursor: pointer;" onclick="javascript: imprimePanel()" /> <br />
                                                    <asp:Panel ID="pnlImpressao" runat="server" Width="100%" Height="100%">
                                                        <div class="delivery-print">
                                                            <section class="delivery-part">
                                                                <div class="delivery-header">
                                                                    <img src="../../img/entrega_saida_byd.png?v=20260708-entrega-header" alt="BALI BYD" />
                                                                </div>
                                                                <div class="delivery-main-grid">
                                                                    <div class="delivery-card">
                                                                        <div class="delivery-section-label">Dados do veículo</div>
                                                                        <div><span>Cliente:</span> <b><asp:Label ID="lblCliente" runat="server"></asp:Label></b></div>
                                                                        <div><span>Veículo:</span> <b><asp:Label ID="lblVeiculo" runat="server"></asp:Label></b></div>
                                                                        <div><span>Chassi:</span> <b><asp:Label ID="lblChassi" runat="server"></asp:Label></b> <span>Placa:</span> <b><asp:Label ID="lblPlaca" runat="server"></asp:Label></b></div>
                                                                        <div><span>Cor:</span> <b><asp:Label ID="lblCor" runat="server"></asp:Label></b></div>
                                                                        <div><span>Vendedor:</span> <b><asp:Label ID="lblVendedor" runat="server"></asp:Label></b></div>
                                                                    </div>
                                                                    <div class="delivery-portaria">
                                                                        <h2>Portaria</h2>
                                                                        <div class="delivery-date">Brasília-DF, <asp:Label ID="lblDataPortaria" runat="server"></asp:Label></div>
                                                                        <div class="delivery-line"></div>
                                                                        <strong>Visto Portaria / BALI BYD</strong>
                                                                    </div>
                                                                </div>
                                                                <div class="delivery-sign-grid">
                                                                    <div class="delivery-section-label delivery-sign-heading">Assinaturas internas</div>
                                                                    <div class="delivery-sign-box">
                                                                        <div class="delivery-date">Brasília-DF, <asp:Label ID="lblDataGerencia" runat="server"></asp:Label></div>
                                                                        <div class="delivery-line"></div>
                                                                        <strong>Gerente Novos/Seminovos / BALI BYD</strong>
                                                                        <div class="delivery-line"></div>
                                                                        <strong>Gerente Financeiro</strong>
                                                                    </div>
                                                                    <div class="delivery-sign-box">
                                                                        <div class="delivery-date">Conferência da portaria</div>
                                                                        <div class="delivery-line"></div>
                                                                        <strong>Visto Portaria / BALI BYD</strong>
                                                                    </div>
                                                                </div>
                                                                <div class="delivery-observation-grid">
                                                                    <div>Observação:</div>
                                                                    <div>Observação:</div>
                                                                </div>
                                                            </section>

                                                            <div class="delivery-cut"><span>Cortar aqui</span></div>

                                                            <section class="delivery-finance">
                                                                <div class="delivery-finance-heading">Autorização Financeira</div>
                                                                <div class="delivery-note">
                                                                    * Em caso de recebimento de veículo usado, a liberação concedida está vinculada ao recebimento do mesmo, em total conformidade com as normas exigidas.<br />
                                                                    * Somente liberar com o recibo de desconto assinado pelo cliente, quando aplicável.
                                                                </div>
                                                                <div class="delivery-part">
                                                                    <div class="delivery-title">Autorização do financeiro - Serviços adicionais</div>
                                                                    <div class="delivery-table-wrap">
                                                                        <asp:GridView ID="GridView2" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDsEntregaAdicional" CssClass="delivery-grid delivery-additional-grid" Width="100%">
                                                                            <Columns>
                                                                                <asp:BoundField DataField="Serviço Adicional" HeaderText="Serviço adicional" SortExpression="Serviço Adicional"></asp:BoundField>
                                                                                <asp:BoundField DataField="Valor" HeaderText="Valor" ReadOnly="True" SortExpression="Valor"></asp:BoundField>
                                                                                <asp:BoundField DataField="Assinatura" HeaderText="Assinatura" ReadOnly="True" SortExpression="Assinatura"></asp:BoundField>
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                        <asp:SqlDataSource ID="SqlDsEntregaAdicional" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" SelectCommand="jeep_select_autorizacao_saida2" SelectCommandType="StoredProcedure">
                                                                            <SelectParameters>
                                                                                <asp:ControlParameter ControlID="txtpedido" Name="pedido" PropertyName="Text" Type="String"></asp:ControlParameter>
                                                                                <asp:ControlParameter ControlID="txtLoja" Name="loja" PropertyName="Text" Type="String" />
                                                                            </SelectParameters>
                                                                        </asp:SqlDataSource>
                                                                    </div>
                                                                    <div class="delivery-title">Pendências e pagamentos</div>
                                                                    <div class="delivery-table-wrap">
                                                                        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDsEntrega" CssClass="delivery-grid delivery-payment-grid" Width="100%">
                                                                            <Columns>
                                                                                <asp:BoundField DataField="Pendencias" HeaderText="Pendências" SortExpression="Pendencias"></asp:BoundField>
                                                                                <asp:BoundField DataField="Valor" HeaderText="Valor" ReadOnly="True" SortExpression="Valor"></asp:BoundField>
                                                                                <asp:BoundField DataField="Data Pagamento" HeaderText="Data pagamento" ReadOnly="True" SortExpression="Data Pagamento"></asp:BoundField>
                                                                                <asp:BoundField DataField="Banco" HeaderText="Banco" ReadOnly="True" SortExpression="Banco"></asp:BoundField>
                                                                                <asp:BoundField HeaderText="Assinatura"></asp:BoundField>
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                        <asp:SqlDataSource ID="SqlDsEntrega" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" SelectCommand="jeep_select_autorizacao_saida" SelectCommandType="StoredProcedure">
                                                                            <SelectParameters>
                                                                                <asp:ControlParameter ControlID="txtpedido" Name="pedido" PropertyName="Text" Type="String" />
                                                                                <asp:ControlParameter ControlID="txtLoja" Name="loja" PropertyName="Text" Type="String" />
                                                                            </SelectParameters>
                                                                        </asp:SqlDataSource>
                                                                    </div>
                                                                </div>
                                                                <div class="delivery-mini">
                                                                    <div class="delivery-mini-head"><img src="../../img/entrega_saida_byd.png?v=20260708-entrega-header" alt="BALI BYD" /></div>
                                                                    <div class="delivery-mini-data">
                                                                        <span>Cliente:</span> <b><asp:Label ID="lblClienteEntreg" runat="server"></asp:Label></b>
                                                                        <span>Chassi:</span> <b><asp:Label ID="lblChassiEntreg" runat="server"></asp:Label></b><br />
                                                                        <span>Veículo:</span> <b><asp:Label ID="lblVeiculoEntreg" runat="server"></asp:Label></b>
                                                                        <span>Vendedor:</span> <b><asp:Label ID="lblVendedorEntreg" runat="server"></asp:Label></b>
                                                                    </div>
                                                                </div>
                                                                <div class="delivery-release-grid">
                                                                    <div class="delivery-release-field"><strong>Liberado:</strong><span class="delivery-release-line"></span></div>
                                                                    <div class="delivery-release-field"><strong>Brasília-DF:</strong><span><asp:Label ID="lblDataFinal" runat="server"></asp:Label></span></div>
                                                                    <div class="delivery-release-field"><strong>Acessórios:</strong><span class="delivery-release-line"></span></div>
                                                                    <div class="delivery-release-field"><strong>Acessórios Externos:</strong><span class="delivery-release-line"></span></div>
                                                                </div>
                                                                <div class="delivery-footnote">
                                                                    Documento interno. Conferir dados antes da liberação.
                                                                    <span class="delivery-footnote-meta">Via interna | Pedido: <asp:Label ID="lblPedidoPrint" runat="server"></asp:Label> | Loja: <asp:Label ID="lblLojaPrint" runat="server"></asp:Label></span>
                                                                </div>
                                                            </section>
                                                        </div>
                                                    </asp:Panel>


                                                </fieldset>
   <br />

</ContentTemplate>


</asp:TabPanel>
</asp:tabcontainer>
                    </td>
                </tr>
            </table>
        </div>

    </form>
</body>

</html>
<script language="javascript" type="text/jscript">
    function imprimePanel() {
        var printContent = document.getElementById("<%=pnlImpressao.ClientID%>");
        var windowUrl = 'formPadrao.aspx';
        var uniqueName = new Date();
        var windowName = 'Processos Enviados ao Despachante';//'Print' + uniqueName.getTime();
        var printWindow = window.open(windowUrl, windowName, 'left=50000,top=50000,width=0,height=0');

        printWindow.document.write(printContent.innerHTML);
        printWindow.document.close();
        printWindow.focus();
        printWindow.print();
        printWindow.close();
    }

</script>
