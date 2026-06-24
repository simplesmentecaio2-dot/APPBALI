<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default1.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>APP BALI</title>
    <link href="~/css/estilo.css" rel="stylesheet" />
    

</head>
<body>
    <form id="form1" runat="server">
       <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo" ><font style="font-family:Arial black; font-size:32px;  font-style:italic; color:white; margin-left:13px;"><a href="Default.aspx" class="linkHome">BALI</a></font><font style="font-family:Calibri; font-size:14px; margin-left:5px;  font-style:italic; color:white;">APP</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
                    <td id="table-menu-usuario" class="idUser">Usuário: <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text=""></asp:Label>   Perfil: <asp:Label ID="lblTipo" CssClass="idUser" runat="server" style="margin-right:13px;" Text=""></asp:Label></td>
                </tr>
            </table>
        </div>
        <div id="linha-branca"></div>
        <div id="menu-topo">
            
        </div>
        <div id="menu">
           <a href="tecnologia/Suporte.aspx"> <img src="img/help.png" style="width:40px; right:25px; position:absolute; cursor:pointer; text-decoration:none;" title="Suporte" /></a>
            
        </div>
        <div id="conteudo-default">
            <div id="contBtn">
                <asp:DataList ID="dlSistemas" runat="server"  RepeatDirection="Horizontal" DataSourceID="sqldsSistemas" RepeatLayout="Flow">
                    <ItemTemplate>
                        <a href='<%# Eval("url") %>' class="links"><img src='<%# Eval("img_sistema") %>' class="btn-default links" onclick='<%# Eval("msn") %>' /></a>
                    </ItemTemplate>

                </asp:DataList>
                <asp:SqlDataSource ID="sqldsSistemas" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="app_select_sistemas_usuario" SelectCommandType="StoredProcedure">
                    <SelectParameters>
                        <asp:SessionParameter Name="id" SessionField="id" Type="String" />
                    </SelectParameters>
                </asp:SqlDataSource>
                
            </div>
        </div>
    </form>
</body>
</html>
