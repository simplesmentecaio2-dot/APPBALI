<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Seminovos-Painel-de-Controle.aspx.cs" Inherits="veiculos_Seminovos_Painel_de_Controle" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../css/estilo.css" rel="stylesheet" />
    <script src="../js/js.js"></script>
    <link href="DataTableCSS.css" rel="stylesheet" />
    <script src="jquery.js"></script>
    <script src="DataTables.js"></script>
    <style type="text/css">
        #tblSeminovos {
            width:100%;
            font-size:14px;
        }
        .filtro {
            display:none;
        }
        h1 {
            
        }
    </style>
    
    
    <script type="text/javascript">
        $(document).ready(function () {
            oTable = $('#tblSeminovos').dataTable({ //example é o ID da tabela
                "bPaginate": false,
                //"bJQueryUI": true,
                "ordering": false,
                "paging": true,
                "bFilter": true,
                //"scrollY": "500px",
                //"scrollCollapse": true,
                "sPaginationType": "full_numbers"
            });
        });
    </script>

    
</head>
<body style="background-color:white;">
    <form id="form1" runat="server" style="background-color:white;">
        <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo" ><font id="logo" style="font-family:Arial black; font-size:32px;  font-style:italic; color:white; margin-left:13px;"><a href="../Default.aspx" class="linkHome">BALI</a></font><font style="font-family:Calibri; font-size:14px; margin-left:5px;  font-style:italic; color:white;">APP</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
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
                <asp:Label ID="lblFrmID" runat="server" Text="Painel de Controle Estoque de Veículos Seminovos"></asp:Label>
            </div>
        </div>
        <img id="openMenu" src="../img/openMenu.png" style="height: 68px; width: 68px; position:absolute; z-index:200; top:60px; left:10px; display:none;" />
        <div id="menu-left">
            <div class="item-menu"  style="padding-left:80px; height:50px; line-height:60px;" onclick="escondeMenuLeft()">
                MENU <<
            </div>
            <div class="item-menu-select"><a class="links" href="Default.aspx">PASTAS</a></div>
            <div class="item-menu"><a class="links" href="Seminovos-Painel-de-Controle.aspx">Painel Estoque VU</a></div>
            <div class="item-menu"><a target="_blank" class="links" href="Seminovos.aspx">Estoque VU</a></div>
            <div id="completa-menu-left"></div>
            </div>
        
        <div id="Cont" onmouseover="esconderMenuLeftMouse()"  >
            <%--<div style=" font-size:22px; font-family:Arial; font-weight:bold;">Painel de Controle Estoque de Veículos Seminovos</div>--%>
            <asp:TextBox ID="txtCodVec" style="display:none;" MaxLength="7" Width="70px" runat="server"></asp:TextBox>
            
            <asp:FileUpload ID="FileUpload1" style="display:none;" runat="server" />
            
            
        </div>
        <div id="div-salvar" style="padding:0; margin:0 auto; position:fixed; visibility:hidden; z-index:1000; top:0; left:0; width:100%; height:100%; background-color:rgba(0, 0, 0, 0.75);">
            <div style="margin:auto; padding:20px;  border-radius:5px; width:260px; height:110px; position:fixed; z-index:1005; left:50%; margin-left:-100px; top:40%; margin-top:-75px; background-color:white;">
                <img src="../img/loading.gif" /> Aguardando confirmação...
                <div  style="width:100%;  height:1px; background-color:silver; margin-top:5px; margin-bottom:25px; text-align:center; "></div>
                <table align="center" style="width:100%;">
                    <tr>
                        <td style="width:50%;" align="center">
                            <asp:Button ID="Button1"  runat="server" Text="Salvar"  OnClick="Button1_Click" />
                        </td>
                        <td style="width:50%;" align="center">
                            <asp:Button ID="Button2"  runat="server" Text="Cancelar"  OnClick="Button2_Click" />
                        </td>
                    </tr>
                </table>
                
                
            </div>
            
        </div>
        <div style="width: 100%; height: 1px; background-color: silver;"></div>
        <br />
        <%=Lista_VU %>
    </form>
</body>
</html>

<script type="text/javascript">
   

    function GetCodigo(obj) {
        
        document.getElementById('txtCodVec').value = obj.name;
        document.getElementById('txtCodVec').focus();
        document.getElementById('div-salvar').style.visibility = 'visible';
        document.getElementById('FileUpload1').click();
        obj.style.border = '1px solid red';
        scroll(0, 0);
        
    }

</script>
