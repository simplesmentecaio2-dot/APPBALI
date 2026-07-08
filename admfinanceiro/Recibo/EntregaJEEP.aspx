<%@ page language="C#" autoeventwireup="true" codefile="EntregaJEEP.aspx.cs" inherits="admfinanceiro_Recibo_Entrega" %>

<%@ register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>Entrega de Veículo - Jeep</title>
    <link href="../../css/estilo.css" rel="stylesheet" />
    <link href="../../css/bali-utility.css?v=20260707-recibo13" rel="stylesheet" />
    <script src="../../js/jquery-1.10.2.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.min.js"></script>
    <script src="../../js/js.js"></script>
    <script src="../../js/bali-utility-print.js?v=20260707-recibo13"></script>
    <script language="javascript">
        meses = new Array("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro");
        semana = new Array("Domingo", "Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado");
        function DiaExtenso() {
            hoje = new Date();
            dia = hoje.getDate();
            dias = hoje.getDay();
            mes = hoje.getMonth();
            ano = hoje.getYear();
            if (navigator.appName == "Netscape")
                ano = ano + 1900;
            diaext = semana[dias] + ", " + dia + " de " + meses[mes]
                + " de " + ano;
            return diaext;
        }
    </script>

    <script type="text/jscript">
        function moeda() {
            $('.moeda').priceFormat({
                prefix: 'R$ ',
                centsSeparator: ',',
                thousandsSeparator: '.'
            });
        }
    </script>

    <style type="text/css">
        .auto-style1 {
            height: 100px;
        }

        .auto-style2 {
            width: 50cm;
            height: 170px;
        }
    </style>

</head>

<body class="bali-utility-page utility-jeep utility-no-sidebar">
    <form id="form1" runat="server">
        <asp:scriptmanager id="ScriptManager1" enablescriptglobalization="true" runat="server">
        </asp:scriptmanager>
        <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo">
                        <font id="logo"
                            style="font-family: Arial black; font-size: 32px; font-style: italic; color: white; margin-left: 13px;">
                            <a href="../../Default.aspx" class="linkHome">BALI</a></font>
                        <font
                            style="font-family: Calibri; font-size: 14px; margin-left: 5px; font-style: italic; color: white;">APP</font><%--<img src="img/logo4.png"
                                    style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%>
                    </td>
                    <td id="table-menu-usuario" class="idUser">Usuário:
                                <asp:label id="lblUsuario" cssclass="idUser" runat="server" text=""></asp:label>
                        C&oacute;digo:
                                <asp:label id="lblTipo" cssclass="idUser" runat="server" style="margin-right: 13px;"
                                    text=""></asp:label>
                    <a class="bali-logout-link" href="/logout.aspx?voltar=/jeep/loginAppcontrato.aspx">Sair</a></td>
                </tr>
            </table>
        </div>
        <div id="linha-branca"></div>
        <div id="menu-topo">
        </div>
        <div id="menu">
            <button type="button" class="bali-back-button" onclick="if (window.history.length > 1) { window.history.back(); } else { window.location.href='../../jeep/Principal.aspx'; }">&larr; Voltar</button>
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
                                <headertemplate>
                                    Recibo

                                </headertemplate>
                                <contenttemplate>
                                    <fieldset>
                                        <legend>Dados do Recibo</legend>Pedido:
                                        <asp:TextBox ID="txtpedido" runat="server"></asp:TextBox>
                                        Cód. Loja:
                                        <asp:TextBox ID="txtLoja" runat="server"></asp:TextBox>
                                        <asp:Button ID="btnGerar" runat="server" Text="Gerar" OnClick="btnGerar_Click" CssClass="btns" />




                                        <br />
                                        <img src="../../img/imprimir.png" style="width: 30px; cursor: pointer;" onclick="javascript: imprimePanel()" />
                                        <br />
                                        <asp:Panel ID="pnlImpressao" runat="server" Width="100%" Height="100%">
                                            <style type="text/css">
                                                .delivery-print { width: 19.2cm; margin: 0 auto; color: #111; font-family: 'Times New Roman', serif; font-size: 12.5px; line-height: 1.2; }
                                                .delivery-print * { box-sizing: border-box; }
                                                .delivery-part { border: 1px solid #222; background: #fff; }
                                                .delivery-header { display: flex; align-items: center; justify-content: center; min-height: 52px; padding: 6px 10px; border-bottom: 1px solid #222; }
                                                .delivery-header img { width: 100%; max-width: 652px; max-height: 49px; object-fit: contain; }
                                                .delivery-main-grid { display: grid; grid-template-columns: 1.2fr .8fr; border-bottom: 1px solid #222; }
                                                .delivery-card, .delivery-portaria { min-height: 104px; padding: 8px 10px; }
                                                .delivery-card { border-right: 1px solid #222; }
                                                .delivery-card div { margin-bottom: 3px; }
                                                .delivery-card span, .delivery-mini span { font-weight: bold; text-transform: uppercase; }
                                                .delivery-card b, .delivery-mini b { font-size: 13px; }
                                                .delivery-portaria { display: grid; align-content: start; text-align: center; }
                                                .delivery-portaria h2 { margin: 0 0 18px; font-size: 17px; text-transform: uppercase; }
                                                .delivery-date { margin-bottom: 24px; font-size: 13px; font-weight: bold; text-align: center; }
                                                .delivery-sign-grid { display: grid; grid-template-columns: 1fr 1fr; border-bottom: 1px solid #222; }
                                                .delivery-sign-box { min-height: 152px; padding: 13px 16px 10px; text-align: center; }
                                                .delivery-sign-box:first-child { border-right: 1px solid #222; }
                                                .delivery-line { width: 84%; height: 1px; margin: 29px auto 6px; border-top: 1px solid #111; }
                                                .delivery-sign-box strong { display: block; font-size: 12.5px; }
                                                .delivery-observation-grid { display: grid; grid-template-columns: 1fr 1fr; min-height: 62px; }
                                                .delivery-observation-grid div { padding: 6px 8px; font-weight: bold; text-transform: uppercase; }
                                                .delivery-observation-grid div:first-child { border-right: 1px solid #222; }
                                                .delivery-cut { position: relative; margin: 12px 0; border-top: 1px dashed #b42318; color: #b42318; font-family: Arial, sans-serif; font-size: 9px; font-weight: bold; letter-spacing: .08em; text-align: center; text-transform: uppercase; }
                                                .delivery-cut span { position: relative; top: -7px; padding: 0 8px; background: #fff; }
                                                .delivery-note { margin-bottom: 8px; padding: 6px 8px; border: 1px solid #222; font-weight: bold; }
                                                .delivery-title { padding: 5px 8px; border-bottom: 1px solid #222; background: #eee; font-weight: bold; text-align: center; text-transform: uppercase; }
                                                .delivery-table-wrap { padding: 0; }
                                                .delivery-grid { width: 100% !important; border-collapse: collapse !important; font-size: 12px; }
                                                .delivery-grid th, .delivery-grid td { padding: 3px 5px !important; border: 1px solid #222 !important; }
                                                .delivery-grid th { background: #f0f0f0; text-align: center; font-weight: bold; }
                                                .delivery-grid td { min-height: 22px; }
                                                .delivery-additional-grid th:nth-child(1), .delivery-additional-grid td:nth-child(1) { width: 62%; text-align: left; }
                                                .delivery-additional-grid th:nth-child(2), .delivery-additional-grid td:nth-child(2) { width: 18%; white-space: nowrap; text-align: right; }
                                                .delivery-additional-grid th:nth-child(3), .delivery-additional-grid td:nth-child(3) { width: 20%; }
                                                .delivery-payment-grid th:nth-child(1), .delivery-payment-grid td:nth-child(1) { width: 34%; text-align: left; }
                                                .delivery-payment-grid th:nth-child(2), .delivery-payment-grid td:nth-child(2) { width: 14%; white-space: nowrap; text-align: right; }
                                                .delivery-payment-grid th:nth-child(3), .delivery-payment-grid td:nth-child(3) { width: 16%; text-align: center; }
                                                .delivery-payment-grid th:nth-child(4), .delivery-payment-grid td:nth-child(4) { width: 14%; text-align: center; }
                                                .delivery-payment-grid th:nth-child(5), .delivery-payment-grid td:nth-child(5) { width: 22%; }
                                                .delivery-mini { margin-top: 8px; border: 1px solid #222; }
                                                .delivery-mini-head { padding: 5px 8px; border-bottom: 1px solid #222; text-align: center; }
                                                .delivery-mini-head img { max-width: 410px; max-height: 42px; object-fit: contain; }
                                                .delivery-mini-data { padding: 5px 8px; text-align: center; font-size: 12.5px; }
                                                .delivery-release-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 28px 42px; margin-top: 28px; padding: 0 8px 8px; font-size: 14px; }
                                                .delivery-release-field { display: grid; grid-template-columns: auto 1fr; gap: 8px; align-items: end; }
                                                .delivery-release-field strong { white-space: nowrap; }
                                                .delivery-release-line { border-bottom: 1px solid #111; min-height: 26px; }
                                                @media print {
                                                    @page { size: A4 portrait; margin: 7mm; }
                                                    body { margin: 0; background: #fff; }
                                                    .delivery-print { width: 19cm; }
                                                    .delivery-cut { break-inside: avoid; page-break-inside: avoid; }
                                                }
                                            </style>
                                            <div class="delivery-print">
                                                <section class="delivery-part">
                                                    <div class="delivery-header">
                                                        <img src="../../img/entrega_saida_jeep.png?v=20260708-entrega-header" alt="BALI JEEP" />
                                                    </div>
                                                    <div class="delivery-main-grid">
                                                        <div class="delivery-card">
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
                                                            <strong>Visto Portaria / BALI JEEP</strong>
                                                        </div>
                                                    </div>
                                                    <div class="delivery-sign-grid">
                                                        <div class="delivery-sign-box">
                                                            <div class="delivery-date">Brasília-DF, <asp:Label ID="lblDataGerencia" runat="server"></asp:Label></div>
                                                            <div class="delivery-line"></div>
                                                            <strong>Gerente Novos/Seminovos / BALI JEEP</strong>
                                                            <div class="delivery-line"></div>
                                                            <strong>Gerente Financeiro</strong>
                                                        </div>
                                                        <div class="delivery-sign-box">
                                                            <div class="delivery-date">Conferência da portaria</div>
                                                            <div class="delivery-line"></div>
                                                            <strong>Visto Portaria / BALI JEEP</strong>
                                                        </div>
                                                    </div>
                                                    <div class="delivery-observation-grid">
                                                        <div>Observação:</div>
                                                        <div>Observação:</div>
                                                    </div>
                                                </section>

                                                <div class="delivery-cut"><span>Cortar aqui</span></div>

                                                <section class="delivery-finance">
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
                                                        <div class="delivery-mini-head"><img src="../../img/entrega_saida_jeep.png?v=20260708-entrega-header" alt="BALI JEEP" /></div>
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
                                                </section>
                                            </div>
                                        </asp:Panel>

                                    </fieldset>
                                    <br />

                                </contenttemplate>

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
