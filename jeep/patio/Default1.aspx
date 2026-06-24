<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default1.aspx.cs" Inherits="veiculos_patio_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../css/estilo.css" rel="stylesheet" />
    <script src="../../scripts/jquery-1.10.2.js"></script>
    <script src="../../scripts/js.js"></script>
</head>
<body>
    <form id="form1" style="height:100%;" runat="server">
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
            
        </div>
       
        <div id="Cont">
            <table cellpadding="15">
                <tr>
                    <td class="table-menu"><a class="links" href="Registrar.aspx"><img src="../../img/pastas.png" style="height: 38px; width: 38px; vertical-align:middle; border:none;" /> Registrar</a></td>
                    <td class="table-menu"><a class="links" href="#"><img src="../../img/pastas.png" style="height: 38px; width: 38px; vertical-align:middle; border:none;" /> Consultar</a></td>
                    
                </tr>
            </table>
                
            
        </div>
    </form>
</body>
</html>
