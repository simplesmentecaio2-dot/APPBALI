<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Recibo_descontoJEEP.aspx.cs" Inherits="veiculos_Recibo_desconto" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Recibo de Desconto - Jeep</title>
    <link href="../css/estilo.css" rel="stylesheet" />
    <link href="../css/bali-utility.css?v=20260707-recibo04" rel="stylesheet" />
    <script src="../../js/jquery-1.10.2.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.min.js"></script>
    <script src="../../js/js.js"></script>
    <script src="../js/bali-utility-print.js?v=20260707-recibo04"></script>
</head>
<body class="bali-utility-page utility-jeep utility-no-sidebar">
  <script>
         function aguarde() {
             document.getElementById('ag').style.visibility = 'visible';
         }
    </script>

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
        function MascaraMoeda(objTextBox, SeparadorMilesimo, SeparadorDecimal, e) {
            var sep = 0;
            var key = '';
            var i = j = 0;
            var len = len2 = 0;
            var strCheck = '0123456789';
            var aux = aux2 = '';
            var whichCode = (window.Event) ? e.which : e.keyCode;
            if (whichCode == 13) return true;
            key = String.fromCharCode(whichCode); // Valor para o código da Chave
            if (strCheck.indexOf(key) == -1) return false; // Chave inválida
            len = objTextBox.value.length;
            for (i = 0; i < len; i++)
                if ((objTextBox.value.charAt(i) != '0') && (objTextBox.value.charAt(i) != SeparadorDecimal)) break;
            aux = '';
            for (; i < len; i++)
                if (strCheck.indexOf(objTextBox.value.charAt(i)) != -1) aux += objTextBox.value.charAt(i);
            aux += key;
            len = aux.length;
            if (len == 0) objTextBox.value = '';
            if (len == 1) objTextBox.value = '0' + SeparadorDecimal + '0' + aux;
            if (len == 2) objTextBox.value = '0' + SeparadorDecimal + aux;
            if (len > 2) {
                aux2 = '';
                for (j = 0, i = len - 3; i >= 0; i--) {
                    if (j == 3) {
                        aux2 += SeparadorMilesimo;
                        j = 0;
                    }
                    aux2 += aux.charAt(i);
                    j++;
                }
                objTextBox.value = '';
                len2 = aux2.length;
                for (i = len2 - 1; i >= 0; i--)
                    objTextBox.value += aux2.charAt(i);
                objTextBox.value += SeparadorDecimal + aux.substr(len - 2, len);
            }
            return false;
        }
    </script>
    <form id="form1" runat="server">
        <div>
            <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
            <div id="topo">
                <table id="table-menu">
                    <tr>
                        <td id="table-menu-logo"><font id="logo" style="font-family: Arial black; font-size: 32px; font-style: italic; color: white; margin-left: 13px;"><a href="../../Default.aspx" class="linkHome">BALI</a></font><font style="font-family: Calibri; font-size: 14px; margin-left: 5px; font-style: italic; color: white;">APP</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
                        <td id="table-menu-usuario" class="idUser">Usuário:
                        <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text=""></asp:Label>
                            C&oacute;digo:
                        <asp:Label ID="lblTipo" CssClass="idUser" runat="server" Style="margin-right: 13px;" Text=""></asp:Label><a class="bali-logout-link" href="/logout.aspx?voltar=/jeep/loginAppcontrato.aspx">Sair</a></td>
                    </tr>
                </table>
            </div>

            <div id="linha-branca"></div>
            <div id="menu-topo">
            </div>
            <div id="menu">
                <button type="button" class="bali-back-button" onclick="if (window.history.length > 1) { window.history.back(); } else { window.location.href='principal.aspx'; }">&larr; Voltar</button>
                <div style="text-align: right; margin-right: 15px;">
                    <asp:Label ID="lblFrmID" runat="server" Text="Recibo de Desconto"></asp:Label>
                </div>
            </div>

            <asp:TabContainer ID="TabRecibo" runat="server" CssClass="tabPanelConsultar" Width="100%" ActiveTabIndex="0">
                <asp:TabPanel ID="TabPanel1" runat="server" HeaderText="TabPanel1">
                    <HeaderTemplate>
                        Recibo

</HeaderTemplate>



















<ContentTemplate>
<fieldset><legend>Recibo </legend>Pedido: <asp:TextBox ID="txtPedido" runat="server"></asp:TextBox>Cód. Loja: <asp:TextBox ID="txtLoja" runat="server"></asp:TextBox><asp:Button ID="btnGerar" runat="server" OnClientClick="aguarde();" Text="Gerar" OnClick="btnGerar_Click" CssClass="btns"/>




<br />
                            <br />
                            <img src="../img/imprimir.png" style="width: 30px; cursor: pointer;" onclick="javascript: imprimePanel()" /> <asp:Panel ID="pnlImpressao" runat="server" Width="100%" Height="100%"><div style="width: 19cm; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;" id="recibo"><div style="text-align: center"><img src="../img/header-contratoJEEP.png" style="width: 671px" /></div>

                                    <br /><br /><br /><div style="text-align: center; font-size: 26px; font-weight: bold;">Recibo de Desconto</div><br /><br /><br /><div style="font-size: large; text-align: center">Recebi da <asp:Label ID="Label1" Font-Bold="True" runat="server" Text="BALI MOTORS LTDA"></asp:Label>, como desconto incondicional, <br />o valor de <asp:Label ID="Label3" runat="server" Font-Bold="True"  Text="R$"></asp:Label><asp:Label ID="lblValor" Font-Bold="True" runat="server" onKeyPress="return(MascaraMoeda(this,'.',',',event))"></asp:Label>(<asp:Label ID="lblextenso" Font-Bold="True" runat="server"></asp:Label>)

referente à compra do veículo: <asp:Label ID="lblVeículo" Font-Bold="True" runat="server" ></asp:Label>,
                                        chassi : <asp:Label ID="lblChassi" Font-Bold="True" runat="server" ></asp:Label>,
                                        cor: <asp:Label ID="lblCor" runat="server" Font-Bold="True" ></asp:Label>,

                                        ano/modelo: <asp:Label ID="lblAno" runat="server" Font-Bold="True" ></asp:Label>,
                                        faturado por meio de nota Fiscal nº: <asp:Label ID="lblNota" Font-Bold="True" runat="server" ></asp:Label>.<br /> <br /><br /><br />Declaro que estou ciente que haverá incidência de percentual em relação à cobrança <br />do valor do IPVA do veículo zero quilometro acima descriminado e neste ato, dou pena <br />e total quitação desse valor para <asp:Label ID="Label2" Font-Bold="True" runat="server" Text="BALI MOTORS   LTDA"></asp:Label></div><br /><br /><br /><br /><div style="text-align: center; font-size: large;">Por ser a expressão de verdade firmo o presente recibo.</div><br /><br /><br /><div style="font-size: large; text-align: center">Brasília&#160;DF&#160;-&#160; <script language="javascript">
                                                        document.write(DiaExtenso());
                                        </script></div><br /><br /><br /><br /><br /><br /><br /><div style="text-align: center; align-items: center; width: 100%;"><div>_____________________________________</div><br /><div style="font-size: large"><asp:Label ID="lblCliente" runat="server" style="font-size: large"  Font-Bold="True"></asp:Label></div></div></div></asp:Panel></fieldset>
</ContentTemplate>















</asp:TabPanel>
            </asp:TabContainer>
        </div>
    </form>
    <div id="ag" style=" position:fixed;  z-index:1000; top:0; left:0; width:100%; height:100%; background-color:rgba(0, 0, 0, 0.75); visibility:hidden;">
            <div style="position:fixed; z-index:1001; top:50%; left:50%; width:300px; height:100px; margin-left:-150px; margin-top:-50px; background-color:white; border-radius:5px;">
               <img src="../../img/aguarde.gif" style=" border-radius:5px;" />

            </div>
        </div>
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
