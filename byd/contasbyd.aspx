<%@ Page Language="C#" AutoEventWireup="true" CodeFile="contasbyd.aspx.cs" Inherits="veiculos_Recibo_desconto" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../css/estilo.css" rel="stylesheet" />
    <script src="../../js/jquery-1.10.2.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.min.js"></script>
    <script src="../../js/js.js"></script>
    <style type="text/css">
        .auto-style6 {
            width: 714px;
        }

        
    </style>
</head>
<body>
  <script>
         function aguarde() {
             document.getElementById('ag').style.visibility = 'visible';
         }
    </script>



   
    <form id="form1" runat="server">
        <div>
            <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
            <div id="topo">
                <table id="table-menu">
                    <tr>
                        <td id="table-menu-logo"><font id="logo" style="font-family: Arial black; font-size: 32px; font-style: italic; color: white; margin-left: 13px;"><a href="/principal.aspx" class="linkHome"><img src="../img/bydbranco.png" style="height: 36px; width: 141px" /></a></font><font style="font-family: Calibri; font-size: 14px; margin-left: 5px; font-style: italic; color: white;">APP</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
                        <td id="table-menu-usuario" class="idUser">Usuário:
                        <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text=""></asp:Label>
                            Perfil:
                        <asp:Label ID="lblTipo" CssClass="idUser" runat="server" Style="margin-right: 13px;" Text=""></asp:Label></td>
                    </tr>
                </table>
            </div>

            <div id="linha-branca"></div>
            <div id="menu-topo">
            </div>
            <div id="menu">
                <div id="openMenuUp" class="menu-top" onmouseover="escondeMenuLeft()" onclick="escondeMenuLeft()">
                    MENU >>
                </div>
                <div style="text-align: right; margin-right: 15px;">
                    <asp:Label ID="lblFrmID" runat="server" Text="Sistemas"></asp:Label>
                </div>
            </div>
            <img id="openMenu" src="../../img/openMenu.png" style="height: 68px; width: 68px; position: absolute; z-index: 200; top: 60px; left: 10px; display: none;" />
            <div id="menu-left">
                <div class="item-menu" style="padding-left: 80px; height: 50px; line-height: 60px;" onclick="escondeMenuLeft()">
                    MENU <<
                </div>
                
                <div class="item-menu"><a class="links" href="default.aspx">Inicio</a></div>

                <div id="completa-menu-left"></div>
            </div>

            <asp:TabContainer ID="TabRecibo" runat="server" CssClass="tabPanelConsultar" Width="100%" ActiveTabIndex="0">
                <asp:TabPanel ID="TabPanel1" runat="server" HeaderText="TabPanel1">
                    <HeaderTemplate>
                        Contas Bali
                    </HeaderTemplate>














                    <ContentTemplate>
                        <fieldset>
                            <legend>Contas Bali </legend>


                            <br />
                            <img src="../img/imprimir.png" style="width: 30px; cursor: pointer;" onclick="javascript: imprimePanel()" />
                            <asp:Panel ID="pnlImpressao" runat="server" Width="100%" Height="100%">
                                <style>
                                    table, th, td {
                                        border: 1px solid black;
                                        border-collapse: collapse;
                                    }
                                </style>
                                <div style="width: 19cm; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;" id="recibo">
                                    <div style="text-align: center; height: 108px;">
                                        <img src="../img/header-contratoBYD.png" style="height: 44px; width: 712px" />
                                    </div>
								<br />
                                    <div style="text-align: center; font-size: large; height: 654px;">
                                        <h1><strong>BALI AUTO ELETRICS LTDA<br /> </strong></h1>
                                        <br />
                                        CNPJ: 54.168.855/0001-55<br />
                                        <br />
                                        SAAN Quadra 3 Conj. C- Parte B<br /> CEP-70632-300<br />
                                        <br />
                                        <br />
                                        <table style="width: 714px">
                                            <tr style="text-align: center;">
                                                <td><strong>BANCO</strong></td>
                                                <td><strong>AGÊNCIA</strong></td>
                                                <td><strong>CONTA</strong></td>
                                                <td><strong>PIX</strong></td>
                                            </tr>
                                            <tr style="text-align: center;">
                                                <td>SANTANDER(033)</td>
                                                <td>3437</td>
                                                <td>130036978</td>
                                                <td>54.168.855/0001-55</td>
                                            </tr>
                                           <%-- <tr style="text-align: center;">
                                                <td>BRASIL(001)</td>
                                                <td>3307-3</td>
                                                <td>6738-5</td>
                                                <td>36.444.055/0001-38</td>
                                            </tr>--%>
                                        </table>
                                        
                                    </div>
                                   
                                    

                                  
                                </div>
                            </asp:Panel>
                        </fieldset>
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
