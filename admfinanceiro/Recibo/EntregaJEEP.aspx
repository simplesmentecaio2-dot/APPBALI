<%@ page language="C#" autoeventwireup="true" codefile="EntregaJEEP.aspx.cs" inherits="admfinanceiro_Recibo_Entrega" %>

<%@ register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>Entrega de Veículo - Jeep</title>
    <link href="../../css/estilo.css" rel="stylesheet" />
    <link href="../../css/bali-utility.css?v=20260707-recibo01" rel="stylesheet" />
    <script src="../../js/jquery-1.10.2.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.min.js"></script>
    <script src="../../js/js.js"></script>
    <script src="../../js/bali-utility-print.js?v=20260707-recibo01"></script>
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
                                            <table border="1" cellspacing="0" style="width: 20cm;"></table>
                                            <br />
                                            <table border="1" cellspacing="0" style="width: 20cm;">
                                                <tr style="width: 10cm; text-align: center;">
                                                    <caption>
                                                        &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;<img src="../../img/entrega_saida_jeep.png" style="width: 652px; height: 49px" />
                                                    </caption>
                                                </tr>
                                                <tr>
                                                    <td style="width: 10cm; text-align: center;"><b>Cliente:
                                                        <asp:Label ID="lblCliente" runat="server"></asp:Label>
                                                        <br />
                                                        Veículo:
                                                        <asp:Label ID="lblVeiculo" runat="server"></asp:Label>
                                                        <br />
                                                        Chassi:
                                                        <asp:Label ID="lblChassi" runat="server"></asp:Label>
                                                        Placa:
                                                        <asp:Label ID="lblPlaca" runat="server"></asp:Label>
                                                        <br />
                                                        Cor:
                                                        <asp:Label ID="lblCor" runat="server"></asp:Label>
                                                        <br />
                                                        Vendedor:
                                                        <asp:Label ID="lblVendedor" runat="server"></asp:Label>
                                                    </b></td>
                                                    <td style="text-align: center;"><b>PORTARIA</b>
                                                        <br />
                                                        <br />
                                                        <br />
                                                        <br />
                                                        <br />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: center;" colspan="2">&#160; </td>
                                                </tr>
                                                <tr>
                                                    <td class="auto-style5" style="text-align: center;"><b>
                                                        <br />
                                                        Brasília, ___/___/___<br />
                                                        <br />
                                                        <br />
                                                        ________________________<br />
                                                        Gerente Novos/Seminovos/ BALI Jeep<br />
                                                        <br />
                                                        ________________________<br />
                                                        Gerente
                                                                        Financeiro </b></td>
                                                    <td style="text-align: center;"><b>Brasília,___/___/___.<br />
                                                        <br />
                                                        <br />
                                                        <br />
                                                        ________________________<br />
                                                        Visto
                                                                        Portaria/ BALI Jeep</b></td>
                                                    </b>
                                                </tr>
                                                <tr>
                                                    <td class="auto-style1"><b>OBSERVAÇÃO:</b>
                                                        <br />
                                                        <br />
                                                    </td>
                                                    <td class="auto-style1"><b>OBSERVAÇÃO:</b>
                                                        <br />
                                                        <br />
                                                    </td>
                                                </tr>
                                                </caption><table border="1" cellspacing="0" style="width: 20cm;">
                                                    <caption>
                                                        <br />
                                                        <br />
                                                        <br />
                                                        <tr>
                                                            <td><b>*Em caso de recebimento de veículo usado, a liberação concedida está vinculada ao recebimento do mesmo, em total conformidade com as normas exigidas.
                                                                <br />
                                                                *Somente com o RECIBO DE DESCONTO assinado pelo cliente. </b></td>
                                                        </tr>
                                                    </caption>
                                                </table>
                                                <table border="1" cellspacing="0" style="width: 20cm; text-align: center;">
                                                    <tr>
                                                        <td style="width: 50cm; text-align: center;">
                                                            <asp:GridView ID="GridView2" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDsEntregaAdicional" Width="762px">
                                                                <columns>
                                                                    <asp:BoundField DataField="Serviço Adicional" HeaderText="Serviço Adicional" SortExpression="Serviço Adicional"></asp:BoundField>
                                                                    <asp:BoundField DataField="Valor" HeaderText="Valor" ReadOnly="True" SortExpression="Valor"></asp:BoundField>
                                                                    <asp:BoundField DataField="Assinatura" HeaderText="Assinatura" ReadOnly="True" SortExpression="Assinatura"></asp:BoundField>
                                                                </columns>
                                                            </asp:GridView>




                                                            <asp:SqlDataSource ID="SqlDsEntregaAdicional" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" SelectCommand="jeep_select_autorizacao_saida2" SelectCommandType="StoredProcedure">
                                                                <selectparameters>
                                                                    <asp:ControlParameter ControlID="txtpedido" Name="pedido" PropertyName="Text" Type="String"></asp:ControlParameter>
                                                                    <asp:ControlParameter ControlID="txtLoja" Name="loja" PropertyName="Text" Type="String" />
                                                                </selectparameters>
                                                            </asp:SqlDataSource>




                                                        </td>
                                                    </tr>
                                                    <caption>
                                                        <br />
                                                        <tr>
                                                            <td style="width: 50cm; text-align: center;">
                                                                <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDsEntrega">
                                                                    <columns>
                                                                        <asp:BoundField DataField="Pendencias" HeaderText="Pendencias" SortExpression="Pendencias"></asp:BoundField>
                                                                        <asp:BoundField DataField="Valor" HeaderText="___Valor___" ReadOnly="True" SortExpression="Valor"></asp:BoundField>
                                                                        <asp:BoundField DataField="Data Pagamento" HeaderText="Data Pagamento" ReadOnly="True" SortExpression="Data Pagamento"></asp:BoundField>
                                                                        <asp:BoundField DataField="Banco" HeaderText="___Banco___" ReadOnly="True" SortExpression="Banco"></asp:BoundField>
                                                                        <asp:BoundField HeaderText="_________Assinatura_________"></asp:BoundField>
                                                                    </columns>
                                                                </asp:GridView>


                                                                <asp:SqlDataSource ID="SqlDsEntrega" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" SelectCommand="jeep_select_autorizacao_saida" SelectCommandType="StoredProcedure">
                                                                    <selectparameters>
                                                                        <asp:ControlParameter ControlID="txtPedido" Name="pedido" PropertyName="Text" Type="String" />
                                                                        <asp:ControlParameter ControlID="txtLoja" Name="loja" PropertyName="Text" Type="String" />
                                                                    </selectparameters>
                                                                </asp:SqlDataSource>


                                                            </td>
                                                        </tr>
                                                    </caption>
                                                </table>
                                                <br />
                                                <table border="1" cellspacing="0" style="width: 20cm;">
                                                    <tr>
                                                        <td style="text-align: center;">
                                                            <img src="../../img/entrega_saida_jeep.png" /></td>
                                                    </tr>
                                                    <caption>
                                                        <tr>
                                                            <td style="width: 10cm; text-align: center;"><b>Cliente:</b>
                                                                <asp:Label ID="lblClienteEntreg" runat="server"></asp:Label>
                                                                <b>Chassi:</b>
                                                                <asp:Label ID="lblChassiEntreg" runat="server"></asp:Label>
                                                                <br />
                                                                <b>Veículo:</b>
                                                                <asp:Label ID="lblVeiculoEntreg" runat="server"></asp:Label>
                                                                <b>Vendedor:</b>
                                                                <asp:Label ID="lblVendedorEntreg" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </caption>
                                                </table>
                                                <br />
                                                <table border="1" cellspacing="0" style="width: 20cm;"></table>
                                                </caption><br />
                                                <br />
                                                Liberado: ________________________________&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
                                                        Brasília, ___/___/___ .
                                                <br />
                                                <br />
                                                <br />
                                                Acessórios:_______________________________&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
                                                        CleanWell:_____________________________<br />
                                                <div style="width: 100%; height: 3px; margin-top: 20px; margin-bottom: 20px; background-color: silver;"></div>
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
