<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Devolucoes.aspx.cs" Inherits="admfinanceiro_Devolucao_Devolucoes" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<title></title>
    <link href="../../css/estilo.css" rel="stylesheet" />
    <script src="../../js/jquery-1.10.2.js"></script>
    <script src="../../js/js.js"></script>
    
</head>
<body>
    <form id="form1" runat="server">
      
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
       
    <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo" ><font id="logo" style="font-family:Arial black; font-size:32px;  font-style:italic; color:white; margin-left:13px;"><a href="../../Default.aspx" class="linkHome">BALI</a></font><font style="font-family:Calibri; font-size:14px; margin-left:5px;  font-style:italic; color:white;">APP</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
                    <td id="table-menu-usuario" class="idUser">Usuário: <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text=""></asp:Label>   Perfil: <asp:Label ID="lblTipo" CssClass="idUser" runat="server" style="margin-right:13px;" Text=""></asp:Label></td>
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
            <div style="text-align:right; margin-right:15px;" >
                <asp:Label ID="lblFrmID" runat="server" Text="Devoluções"></asp:Label>
            </div>
        </div>
        <img id="openMenu" src="../../img/openMenu.png" style="height: 68px; width: 68px; position:absolute; z-index:200; top:60px; left:10px; display:none;" />
        <div id="menu-left">
            <div class="item-menu"  style="padding-left:80px; height:50px; line-height:60px;" onclick="escondeMenuLeft()">
                MENU <<
            </div>
            <div class="item-menu-select"><a class="links" href="../Default.aspx">PASTAS</a></div>
            <div class="item-menu"><a class="links" href="comissao.aspx">Devolução</a></div>
           
            <div id="completa-menu-left"></div>
            </div>

        <div id="Cont" onmouseover="esconderMenuLeftMouse()">
            <table style="width: 100%; padding: 13px; text-align: left;" align="center">
                <tr style="width: 100%;">
                    <td style="width: 100%;">
                        
                        <asp:TabContainer ID="TabContainerDevolucao" CssClass="tabPanelConsultar" Width="100%" runat="server" ActiveTabIndex="0">
                            <asp:TabPanel ID="TabPanelDevolucao" Style="padding: 20px;" runat="server" HeaderText="">
                                <HeaderTemplate>
                                    Devolução
                                
                                </HeaderTemplate>



                                <ContentTemplate>
                                    
                                    <table  >
                                        <tr>
                                            <td>Data Inicial:</td>
                                            <td>Data Final:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="txtDtInicial" runat="server"></asp:TextBox><asp:CalendarExtender ID="txtDtInicial_CalendarExtender" runat="server" Enabled="True" TargetControlID="txtDtInicial"></asp:CalendarExtender>
                                                

                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtDtFinal" runat="server"></asp:TextBox><asp:CalendarExtender ID="txtDtFinal_CalendarExtender" runat="server" Enabled="True" TargetControlID="txtDtFinal"></asp:CalendarExtender>



                                                <asp:Button ID="Button1" runat="server" OnClientClick="mostraresconderDiv('#gif-aguarde');"  OnClick="Button1_Click" Text="Gerar" ></asp:Button>


                                            </td>

                                        </tr>
                                    </table>
                                   <div style="width:100%; height:1px; margin-top:20px; margin-bottom:20px; background-color:silver;"></div>
                                   <div id="conteudo">
                                    <table id="dev" runat="server" cellspacing="10">
                                        <thead>
                                            <tr>
                                                <th>Venda</th>
                                                <th>Devolução</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td  valign="top" ><%=tabelaDevolucaoVenda %></td>
                                                <td valign="top" ><%=tabelaDevolucaoDevolucao %></td>
                                            </tr>
                                        </tbody>
                                       
                                    </table>
                                    </div>
                                                                    
                                    </ContentTemplate>
                                </asp:TabPanel>
                                
                            
                            
                            
                          
                            
                            
                            
                        </asp:TabContainer>
                    </td>
                </tr>
            </table>
        </div>
        
        <div id="gif-aguarde">
            <div>
                <img src="../../img/aguarde.gif"  style="height: 52px; width: 192px; position:fixed; top:50%; left:50%; margin-left:-96px; margin-top:-26px; border-radius:3px; " />
            </div>
            
    </div>
        <script language="javascript" type="text/jscript">
            function imprimePanel() {
                var printContent = document.getElementById("<%=dev.ClientID%>");
                // var windowUrl = 'http://localhost:55230/Ap/ExportExcel.aspx';
                // var uniqueName = new Date();
                // var windowName = 'Print' + uniqueName.getTime();
                // var printWindow = window.open('http://localhost:55230/Ap/ExportExcel.aspx', windowName, 'left=50000,top=50000,width=0,height=0');
                
                $('#exportar').html(printContent);
                
                
               //  printWindow.document.write(printContent.innerHTML);
                 //printWindow.document.write(printContent.document.getElementById('Exportar').innerHTML("rafael"));
                 //printWindow.document.write(printContent.innerHTML);
                 printWindow.document.close();
                 printWindow.focus();
                 //printWindow.print();
                 //printWindow.close();
             }

        </script>
               
    </form>
    
</body>
</html>
