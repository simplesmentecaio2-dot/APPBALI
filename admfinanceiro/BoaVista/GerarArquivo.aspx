<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GerarArquivo.aspx.cs" Inherits="admfinanceiro_Comissao_geral" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>



<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<title></title>
    
    <link href="../../css/estilo.css" rel="stylesheet" />
    <script src="../../js/jquery-1.10.2.js"></script>
    <script src="../../js/js.js"></script>
    <script>
        function aguarde() {
            document.getElementById('ag').style.visibility = 'visible';
        }
    </script>
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
                <asp:Label ID="lblFrmID" runat="server" Text="Boa Vista"></asp:Label>
            </div>
        </div>
        <img id="openMenu" src="../../img/openMenu.png" style="height: 68px; width: 68px; position:absolute; z-index:200; top:60px; left:10px; display:none;" />
        <div id="menu-left">
            <div class="item-menu"  style="padding-left:80px; height:50px; line-height:60px;" onclick="escondeMenuLeft()">
                MENU <<
            </div>
            <div class="item-menu-select"><a class="links" href="Default.aspx">PASTAS</a></div>
            <div class="item-menu"><a class="links" href="#">Sistemas</a></div>
           
            <div id="completa-menu-left"></div>
            </div>
        
        <div id="Cont" onmouseover="esconderMenuLeftMouse()">

             <table style="width:100%; padding:13px; text-align:left;" align="center">
                <tr style="width:100%;">
                    <td style="width:100%;">
                        <asp:TabContainer runat="server"></asp:TabContainer>
                        <asp:TabContainer runat="server"></asp:TabContainer>
                        <asp:TabContainer ID="TabContainercomissao" CssClass="tabPanelConsultar" Width="100%" runat="server" ActiveTabIndex="0">
                            <asp:TabPanel ID="TabPanelComissaoGeral" style="padding:20px;" runat="server" HeaderText="">
                                <HeaderTemplate>
                                    Arquivo
                                </HeaderTemplate>
                                <ContentTemplate>
                                    <table>
                                        <tr>
                                            <td>Data Inicial:</td>
                                            <td>Data Final</td>
                                            
                                        </tr>
                                        <tr>
                                            <td><asp:TextBox ID="txtDtInicial" runat="server"></asp:TextBox><asp:CalendarExtender ID="txtDtInicial_CalendarExtender" runat="server" Enabled="True" TargetControlID="txtDtInicial">
                                    </asp:CalendarExtender></td>
                                            <td><asp:TextBox ID="txtDtFinal" runat="server"></asp:TextBox>
                                    <asp:CalendarExtender ID="txtDtFinal_CalendarExtender" runat="server" Enabled="True" TargetControlID="txtDtFinal">
                                    </asp:CalendarExtender></td>
                                            <td><asp:Button ID="GerarArquivo" runat="server" Text="Gerar Arquivo" OnClientClick="aguarde();" OnClick="GerarArquivo_Click"  />
                                    </td>
                                        </tr>
                                    </table>
                              
                                   
                                </ContentTemplate>
                                </asp:TabPanel>
                           <%-- <asp:TabPanel ID="TabPanel1" style="padding:20px;" runat="server" HeaderText="">
                                <HeaderTemplate>
                                    Perfil
                                </HeaderTemplate>
                                <ContentTemplate>

                                </ContentTemplate>
                            </asp:TabPanel>
                            <asp:TabPanel ID="TabPanel2" style="padding:20px;" runat="server" HeaderText="">
                                <HeaderTemplate>
                                    Permissões
                                </HeaderTemplate>
                                <ContentTemplate>

                                </ContentTemplate>
                            </asp:TabPanel>--%>
                        </asp:TabContainer>
                      </td>
                    </tr>
                 </table>        
        </div>
        <div id="ag" style=" position:fixed;  z-index:1000; top:0; left:0; width:100%; height:100%; background-color:rgba(0, 0, 0, 0.75); visibility:hidden;">
            <div style="position:fixed; z-index:1001; top:50%; left:50%; width:300px; height:100px; margin-left:-150px; margin-top:-50px; background-color:white; border-radius:5px;">
               <img src="../../img/aguarde.gif" style=" border-radius:5px;" />
                
            </div>
        </div>
    </form>
</body>
</html>