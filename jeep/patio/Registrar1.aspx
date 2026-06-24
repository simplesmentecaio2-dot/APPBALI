<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Registrar1.aspx.cs" Inherits="veiculos_patio_Registrar" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../css/estilo.css" rel="stylesheet" />
    <script src="../../scripts/jquery-1.10.2.js"></script>
    <script src="../../scripts/js.js"></script>
    <style type="text/css">
        .auto-style4 {
            width: 357px;
        }
        .auto-style5 {
            width: 90px;
        }
        .auto-style7 {
            width: 309px;
        }
    </style>
</head>
<body>
    <form id="form1" style="height:100%;" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo" ><font style="font-family:Arial black; font-size:32px;  font-style:italic; color:white; margin-left:13px;"><a href="../Default.aspx" class="linkHome">BALI</a></font><font style="font-family:Calibri; font-size:14px; margin-left:5px;  font-style:italic; color:white;">APP</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
                    <td id="table-menu-usuario" class="idUser">Usuário: <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text="RAFAEL NAVES"></asp:Label>   Perfil: <asp:Label ID="lblPerfil" CssClass="idUser" runat="server" style="margin-right:13px;" Text="ADMINISTRADOR"></asp:Label></td>
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
                <asp:Label ID="lblFrmID" runat="server" Text="Novo Processo"></asp:Label>
            </div>
        </div>
        <img id="openMenu" src="../../img/openMenu.png" style="height: 68px; width: 68px; position:absolute; z-index:200; top:60px; left:10px; display:none;" />
        <div id="menu-left">
            <div class="item-menu"  style="padding-left:80px; height:50px; line-height:60px;" onclick="escondeMenuLeft()">
                MENU <<
            </div>
            <div class="item-menu-select"><a class="links" href="../Default.aspx">Consultar</a></div>
            <div class="item-menu-select"><a class="links" href="../Default.aspx">Transferência</a></div>
            <div class="item-menu-select"><a class="links" href="../Default.aspx">Relatórios</a></div>
         
            <div id="completa-menu-left"></div>
            </div>
        <div id="Cont">
            <table style="width: 100%; padding: 13px; text-align: left;" align="center">
                <tr style="width: 100%;">
                    <td style="width: 100%;">

                        <asp:TabContainer ID="TabContainerDefault" CssClass="tabPanelConsultar" Width="100%" runat="server" ActiveTabIndex="0">
                            <asp:TabPanel ID="TabPanelRegistar" Style="padding: 20px;" runat="server" HeaderText="">
                                <HeaderTemplate>
                                    Registrar
                                </HeaderTemplate>
                                <ContentTemplate>
                                    <table border ="3" align="center">
                                        <tr>
                                            <td>
                                                

                                    <table cellpadding="5">
                                        <tr>
                                            <td valign="middle"> <asp:TextBox ID="txtChassiRegistrar" Font-Size="50px" Width="210px" MaxLength="7" runat="server"></asp:TextBox></td>
                                            <td valign="middle"> <asp:Button ID="btnBuscar" Height="63px" runat="server" Text="Buscar" OnClick="btnBuscar_Click1" /></td>
                                            <td> <asp:DropDownList ID="ddlLoja" Font-Size="50px" runat="server">

                                                 <asp:ListItem>-- LOJA --</asp:ListItem>
                                                 <asp:ListItem>SIA</asp:ListItem>
                                                 <asp:ListItem>SCIA</asp:ListItem>
                                                 <asp:ListItem>SAAN</asp:ListItem>
                                                 <asp:ListItem>AERO</asp:ListItem>
                                                 <asp:ListItem>ITAMBE</asp:ListItem>

                                                 </asp:DropDownList></td>
                                            <td valign="middle"> <asp:Button ID="btnRegistrar" Height="63px" runat="server" Text="Registrar" OnClick="btnRegistrar_Click" /></td>
                                        </tr>

                                    </table>
                                   <br />
                                   
                                    <table cellspacing="6" border="1" align="center">
                                        
                                            <tr>
                                                <td class="auto-style5">
                                                    <asp:Label ID="Label4" runat="server" Font-Size="30px" Text="Cód: "></asp:Label><td class="auto-style7"> <asp:TextBox ID="txtCodigo" Font-Size="30px" CssClass="txts"  Width="300px" MaxLength="7" runat="server" ></asp:TextBox>
                                                         </td>
                                                    
                                                </td>                                               
                                            </tr>
                                        <tr> 
                                            <td class="auto-style5">
                                                <asp:Label ID="Label3" runat="server" Font-Size="30px" Text="Carro: "></asp:Label><td class="auto-style7"> <asp:TextBox ID="txtVeiculo" CssClass="txts" Font-Size="30px" Width="300px" MaxLength="7" runat="server" ></asp:TextBox> </td> 
                                            </td>
                                        </tr>
                                         <tr>
                                            <td class="auto-style5">
                                                <asp:Label ID="Label2" runat="server" Font-Size="30px" Text="Chassi: "></asp:Label><td class="auto-style7"><asp:TextBox ID="txtChassi" CssClass="txts" Font-Size="30px"  Width="300px" MaxLength="7" runat="server" ></asp:TextBox> </td> 
                                            </td>
                                        </tr>
                                         <tr>
                                            <td class="auto-style5">
                                                <asp:Label ID="Label1" runat="server" Font-Size="30px" Text="Cor: "></asp:Label><td class="auto-style7"><asp:TextBox ID="txtCor" CssClass="txts" Font-Size="30px" Width="300px" MaxLength="7" runat="server" ></asp:TextBox> </td>
                                                 
                                            </td>
                                        </tr>
                                    </table>
<br />

                                                </tr>
                                        </td>
                                        </table>
                                    <br />
                                    
                                </ContentTemplate>
                            </asp:TabPanel>
                        </asp:TabContainer>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
