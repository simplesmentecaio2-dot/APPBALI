<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="veiculos_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../css/estilo.css" rel="stylesheet" />
    <script src="../scripts/jquery-1.10.2.js"></script>
    <script src="../scripts/js.js"></script>
</head>
<body>
    <form id="form1" style="height:100%;" runat="server">
        <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo" ><font style="font-family:Arial black; font-size:32px;  font-style:italic; color:white; margin-left:13px;"><a href="../Default.aspx" class="linkHome"><img src="../img/logobali.png" /></a></font><font style="font-family:Calibri; font-size:14px; margin-left:5px;  font-style:italic; color:white;">APP</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
                    <td id="table-menu-usuario" class="idUser">Usuário: <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text="" ></asp:Label>   Perfil: <asp:Label ID="lblPerfil" CssClass="idUser" runat="server" style="margin-right:13px;" Text=""></asp:Label></td>
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

                    <%--<td class="table-menu"><a class="links" href="contrato.aspx"><img src="../img/pastas.png" style="height: 38px; width: 38px; vertical-align:middle; border:none;" /> Contrato de Compra e Venda</a></td>		    
                    <td class="table-menu"><a class="links" href="Seminovos-Painel-de-Controle.aspx"><img src="../img/pastas.png" style="height: 38px; width: 38px; vertical-align:middle; border:none;" /> Site Bali VU</a></td>
                    <td class="table-menu"><a class="links" href="../Novos/GERAL.aspx"><img src="../img/pastas.png" style="height: 38px; width: 38px; vertical-align:middle; border:none;" /> Novos</a></td>--%>
                    <%--<td class="table-menu"><a class="links" href="patio/Default.aspx"> <img src="../img/pastas.png" style="height: 38px; width: 38px; vertical-align:middle; border:none;" /> Novos</a></td>--%>
                    <td class="table-menu"><a class="links" href="contrato.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Contrato</a></td>
                   <%-- <td class="table-menu"><a class="links" href="ESTOQUEVN.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Ranking  de Vendas</a></td>--%>
                    <td class="table-menu"><a class="links" href="http://129.13.146.87/ftp/GUIA2022.pdf"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" />Guia do Comprador</a></td>
                    <td class="table-menu"><a class="links" href="recibo_Desconto.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Recibo de Desconto</a></td>
                    <td class="table-menu"><a class="links" href="../admfinanceiro/Recibo/Entrega.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Entrega do Veículo</a></td>
                    <td class="table-menu"><a class="links" href="testdrive.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Termo Test Drive</a></td>                     
                     <%-- <td class="table-menu"><a class="links" href="ESTOQUEVN.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Estoque VN</a></td>--%>
                    <%--<td class="table-menu"><a class="links" href="guiadocomprador.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Guia do Comprador</a></td>--%>
                     <td class="table-menu"><a class="links" href="telfinanceiras.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Telefone das Financeiras</a></td>
                     <td class="table-menu"><a class="links" href="contasbali.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Contas Bali</a></td>
                    <td class="table-menu"><a class="links" href="infLOJAS.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Informações das Lojas</a></td> 
		    <td class="table-menu"><a class="links" href="prospeccao.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Prospecção</a></td>
		  <td class="table-menu"><a class="links" href="desempenho.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" />Desempenho por Vendedor</a></td>
         <td class="table-menu"><a class="links" href="http://129.13.146.87/ftp/4%20VENDAS/Documentos/comunica%c3%a7%c3%a3o%20interna%20NOVA.doc"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Comunicação Interna </a></td>
		    <%--<td class="table-menu"><a class="links" href="../gerencia/veiculos/veiculos.aspx"><img src="../img/pastas.png" style="height: 35px; width: 35px; vertical-align:middle; border:none;" /> Gerencia</a></td>--%>


		                             

                
                </tr>
            </table>

            <table style="width: 100%; padding: 13px; text-align: left;" align="center"> 
                <tr>
                    <td >
                        <h1 style="color:darkred;">IP: <asp:Label ID="lblIp" runat="server" Text="Label"></asp:Label></h1>
                        <hr />
                        TI - BALI Automóveis | (61) 3362-6208 | ti@bali.com.br
                    </td>
                </tr>
            </table>


                
            
        </div>
    </form>
</body>
</html>
