<%@ Page Language="C#" AutoEventWireup="true" CodeFile="prospeccao.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../css/estilo.css" rel="stylesheet" />
    <script src="../js/jquery-1.10.2.js"></script>
    <script src="../js/js.js"></script>
    <script src="../js/jquery.maskMoney.js"></script>
    <script src="../js/maskMin.js"></script>
    <script src="../js/maskPhone.js"></script>

    <script src="http://code.jquery.com/jquery-1.9.1.min.js" type="text/javascript"></script>
    <script src="http://code.highcharts.com/highcharts.js" type="text/javascript"></script>
    <script src="http://code.highcharts.com/modules/exporting.js"></script>


    <%--<script src="tables/js/jquery.mim.js"></script>--%>
    <script src="../tables/js/jquery.dataTables.min.js"></script>
    <link href="../tables/estilo/jquery-ui-1.8.4.custom.css" rel="stylesheet" />
    <link href="../tables/estilo/table.css" rel="stylesheet" />
    <link href="../tables/estilo/table_jui.css" rel="stylesheet" />


    <script type="text/javascript">
        $(document).ready(function () {
            oTable = $('#tblprospeccao').dataTable({ //example é o ID da tabela
                "bPaginate": true,
                "bJQueryUI": true,
                "sPaginationType": "full_numbers"
            });
        });
    </script>

   

    <style>
        .real {
        }

        .form-contrato {
            border: none;
            width: 100%;
            background-color: #D8E6ED;
            text-transform: uppercase;
        }

        .auto-style2 {
            width: 213px;
        }

        .auto-style3 {
            width: 187px;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            $("#currency").maskMoney();
            $(".real").maskMoney({ showSymbol: true, symbol: "R$ ", decimal: ",", thousands: ".", allowZero: true });
            $("#precision").maskMoney({ precision: 3 })

        });
        jQuery(function ($) {
            $.mask.definitions['~'] = '[+-]';
            $('.date').mask('99/99/9999');
            $('.phone').mask('(99) 9999-9999');
           
        });
    </script>
    <script type="text/javascript">
        function dataAtualFormatada(){
            var data = new Date(),
                dia  = data.getDate().toString().padStart(2, '0'),
                mes  = (data.getMonth()+1).toString().padStart(2, '0'), //+1 pois no getMonth Janeiro começa com zero.
                ano  = data.getFullYear();
            return dia+"/"+mes+"/"+ano;
        }
    </script>


    <script language="javascript">   
        function moeda(a, e, r, t) {
            let n = ""
              , h = j = 0
              , u = tamanho2 = 0
              , l = ajd2 = ""
              , o = window.Event ? t.which : t.keyCode;
            if (13 == o || 8 == o)
                return !0;
            if (n = String.fromCharCode(o),
            -1 == "0123456789".indexOf(n))
                return !1;
            for (u = a.value.length,
            h = 0; h < u && ("0" == a.value.charAt(h) || a.value.charAt(h) == r); h++)
                ;
            for (l = ""; h < u; h++)
                -1 != "0123456789".indexOf(a.value.charAt(h)) && (l += a.value.charAt(h));
            if (l += n,
            0 == (u = l.length) && (a.value = ""),
            1 == u && (a.value = "0" + r + "0" + l),
            2 == u && (a.value = "0" + r + l),
            u > 2) {
                for (ajd2 = "",
                j = 0,
                h = u - 3; h >= 0; h--)
                    3 == j && (ajd2 += e,
                    j = 0),
                    ajd2 += l.charAt(h),
                    j++;
                for (a.value = "",
                tamanho2 = ajd2.length,
                h = tamanho2 - 1; h >= 0; h--)
                    a.value += ajd2.charAt(h);
                a.value += r + l.substr(u - 2, u)
            }
            return !1
        }
    </script>

</head>
<body>
    <form id="form1" style="height: 100%;" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo"><font style="font-family: Arial black; font-size: 32px; font-style: italic; color: white; margin-left: 13px;"><a href="../Default.aspx" class="linkHome">BALI</a></font><font style="font-family: Calibri; font-size: 14px; margin-left: 5px; font-style: italic; color: white;">APP</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
                    <td id="table-menu-usuario" class="idUser">Usuário:
                        <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text=""></asp:Label>
                        Perfil:
                        <asp:Label ID="lblPerfil" CssClass="idUser" runat="server" Style="margin-right: 13px;" Text=""></asp:Label></td>
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
                <asp:Label ID="lblFrmID" runat="server" Text="Contrato de Venda"></asp:Label>
            </div>
        </div>
        <img id="openMenu" src="../img/openMenu.png" style="height: 68px; width: 68px; position: absolute; z-index: 200; top: 60px; left: 10px; display: none;" />
        <div id="menu-left">
            <div class="item-menu" style="padding-left: 80px; height: 50px; line-height: 60px;" onclick="escondeMenuLeft()">
                MENU <<
            </div>


            <div class="item-menu"><a class="links" href="default.aspx">Inicio</a></div>

            <div id="completa-menu-left"></div>
        </div>

        <div id="Cont" onmouseover="esconderMenuLeftMouse()">
            <table style="width: 100%; padding: 13px; text-align: left;" align="center">
                <tr style="width: 100%;">
                    <td style="width: 100%;">

                        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="gerencia_vendedor2" SelectCommandType="StoredProcedure"></asp:SqlDataSource>

                        <asp:TabContainer ID="TabContainerProcesso" CssClass="tabPanelConsultar" Width="100%" runat="server" ActiveTabIndex="0">
                            <asp:TabPanel ID="TabPanelProcessos" Style="padding: 20px;" runat="server" HeaderText="TabPanel1">
                                <HeaderTemplate>
                                    Novo (+)
                                </HeaderTemplate>
                                <ContentTemplate>
                                    <br />
                                    <br />
                                    <asp:Panel ID="Panel1" runat="server">
                                        <table border="1" cellspacing="0" style="width: 30cm;">
                                            <tr>
                                                <td colspan="6" style="text-align: center; background-color: silver;">DADOS DO CLIENTE
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="width: 1.8cm;">CLIENTE:
                                                </td>
                                                <td colspan="5">
                                                    <asp:TextBox ID="txtCliente" MaxLength="100" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td>PROSPECTOR
                                                </td>
                                                <td colspan="2">

                                                    <asp:DropDownList ID="ddlVendedor" runat="server" CssClass="phone form-contrato" DataSourceID="SqlDataSource1" DataTextField="fun_nm" DataValueField="fun_nm"></asp:DropDownList>
                                                </td>
                                                <td colspan="2">CLASSIFICAÇÃO:
                                                </td>
                                                <td>

                                                    <asp:DropDownList ID="ddlClassificacao" runat="server" CssClass="form-contrato">
                                                        <asp:ListItem>Quente</asp:ListItem>
                                                        <asp:ListItem>Frio</asp:ListItem>
                                                        <asp:ListItem>Sem Interesse</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>


                                            </tr>
                                            <tr>
                                                <td>TELEFONE.:
                                                </td>
                                                <td style="width: 3.6cm;">
                                                    <asp:TextBox ID="txtTelefone" CssClass="phone form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>EVENTO:
                                                </td>
                                                <td>

                                                    <asp:DropDownList ID="ddlEvento" runat="server" CssClass="form-contrato">
                                                        <asp:ListItem>Campanha Argo Trekking</asp:ListItem>
                                                        
                                                        
                                                    </asp:DropDownList>
                                                </td>
                                                <td>LOJA:
                                                </td>
                                                <td>

                                                    <asp:DropDownList ID="ddlLoja" runat="server" CssClass="phone form-contrato">
                                                        <asp:ListItem>SIA</asp:ListItem>
                                                        <asp:ListItem>SAAN</asp:ListItem>
                                                        <asp:ListItem>SCIA</asp:ListItem>
                                                        <asp:ListItem>AERO</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>E-MAIL.:
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtEmail" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>EQUIPE:</td>
                                                <td colspan="2">
                                                    <asp:DropDownList ID="ddlequipe" runat="server" CssClass="phone form-contrato">
                                                        <asp:ListItem>BRANCA</asp:ListItem>
                                                        <asp:ListItem>AMARELA</asp:ListItem>
                                                        <asp:ListItem>VERDE</asp:ListItem>
                                                        <asp:ListItem>AZUL</asp:ListItem>
                                                    </asp:DropDownList></td>
                                            </tr>
                                        </table>
                                        <table border="1" cellspacing="0" style="width: 30cm;">
                                        </table>
                                        <asp:Button ID="btnGravar" runat="server" Text="Gravar" OnClick="btnGravar_Click" CssClass="btns"/>
                                        <asp:ImageButton ID="ibtnDadosCliente" ImageUrl="~/img/ok.png" Width="22px" runat="server" Visible="False" />

                                    </asp:Panel>
                                </ContentTemplate>

                            </asp:TabPanel>
                            <asp:TabPanel ID="TabPanel1" Style="padding: 20px;" runat="server" HeaderText="TabPanel1">
                                <HeaderTemplate>
                                    Ranking
                                </HeaderTemplate>
                                <ContentTemplate>
                                   Evento: Campanha Argo Trekking
                                    <table border="1" cellspacing="0">
                                        <tr>
                                            <td align="center">
                                                <asp:GridView ID="GridView4" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource6" BackColor="White" BorderColor="#999999" BorderStyle="Solid" BorderWidth="1px" CellPadding="3" ForeColor="Black" GridLines="Vertical">
                                                    <AlternatingRowStyle BackColor="#CCCCCC" />
                                                    <Columns>
                                                        <asp:BoundField DataField="loja" HeaderText="loja" SortExpression="loja" />
                                                        <asp:BoundField DataField="equipe" HeaderText="equipe" SortExpression="equipe" />
                                                        <asp:BoundField DataField="qtde" HeaderText="qtde" ReadOnly="True" SortExpression="qtde" />
                                                    </Columns>
                                                    <FooterStyle BackColor="#CCCCCC" />
                                                    <HeaderStyle BackColor="Black" Font-Bold="True" ForeColor="White" />
                                                    <PagerStyle BackColor="#999999" ForeColor="Black" HorizontalAlign="Center" />
                                                    <SelectedRowStyle BackColor="#000099" Font-Bold="True" ForeColor="White" />
                                                    <SortedAscendingCellStyle BackColor="#F1F1F1" />
                                                    <SortedAscendingHeaderStyle BackColor="Gray" />
                                                    <SortedDescendingCellStyle BackColor="#CAC9C9" />
                                                    <SortedDescendingHeaderStyle BackColor="#383838" />
                                                </asp:GridView>
                                                <asp:SqlDataSource ID="SqlDataSource6" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="SELECT loja,equipe,count(*) as qtde
  FROM [APP].[dbo].[veiculos_prospeccao]  where nome_evento = 'Campanha Argo Trekking'
  group by loja,equipe
  order by loja desc"></asp:SqlDataSource>

                                            </td>
                                        </tr>
                                    </table>

                                </ContentTemplate>
                            </asp:TabPanel>

                              <asp:TabPanel ID="TabPanel3" Style="padding: 20px;" runat="server" HeaderText="TabPanel1">
                                <HeaderTemplate>
                                    QRCODE
                                </HeaderTemplate>
                                <ContentTemplate>
                                    <asp:Button ID="Button1" runat="server" Text="Processar Tabela" OnClick="Button1_Click" CssClass="btns" />
                                    <div id="Div3" onmouseover="esconderMenuLeftMouse()">
                                        <table style="width: 100%; padding: 13px;" align="center" onmouseover="esconderMenuLeftMouse()">
                                            <tr style="width: 100%;">
                                                <td style="width: 100%;">
                                                    <%=tabela2 %>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>

                                </ContentTemplate>
                            </asp:TabPanel>

                           

                            <asp:TabPanel ID="TabPanel2" Style="padding: 20px;" runat="server" HeaderText="TabPanel1">
                                <HeaderTemplate>
                                    Dashboard
                                </HeaderTemplate>
                                <ContentTemplate>
                                    <div id="Div1" onmouseover="esconderMenuLeftMouse()">
                                        <table style="width: 100%; padding: 13px;" align="center" onmouseover="esconderMenuLeftMouse()">
                                            <tr style="width: 100%;">
                                                <td style="width: 100%;">
                                                    <table border="1" cellspacing="0">
                                                        <tr>
                                                            <td>Selecione o Evento:</td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlEvento2" runat="server">
                                                                    <asp:ListItem>Campanha Argo Trekking</asp:ListItem>
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td></td>
                                                            <td>Selecione a Loja:</td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlLojadashboard" runat="server">
                                                                    <asp:ListItem>SIA</asp:ListItem>
                                                                    <asp:ListItem>SCIA</asp:ListItem>
                                                                    <asp:ListItem>AERO</asp:ListItem>
                                                                    <asp:ListItem>SAAN</asp:ListItem>
                                                                </asp:DropDownList></td>
                                                            <td></td>
                                                            <td>
                                                                <asp:Button ID="btnProcessar" runat="server" Text="Processar" OnClick="btnProcessar_Click" CssClass="btns"/></td>
                                                        </tr>
                                                    </table>
                                                    <br />
                                                    <br />


                                                    <table border="1" cellspacing="0">
                                                        <tr>
                                                            <td>Quantidade Total: </td>
                                                            <td>
                                                                <asp:Label ID="lblqtde" runat="server" Text="0"></asp:Label></td>
                                                        </tr>
                                                        <tr>
                                                            <td>Quentes:</td>
                                                            <td>
                                                                <asp:Label ID="lblquentes" runat="server" Text="0"></asp:Label>&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td>Frios:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="lblfrios" runat="server" Text="0"></asp:Label></td>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Sem Interesse:</td>
                                                <td>
                                                    <asp:Label ID="lblseminteresse" runat="server" Text="0"></asp:Label></td>

                                            </tr>
                                            <tr>
                                                <td>Projeção de Fluxo:
                                            
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblFluxo" runat="server" Text="00"></asp:Label></td>
                                            </tr>
                                            <tr>
                                                <td>Projeção de Venda de Veículo:</td>
                                                <td>
                                                    <asp:Label ID="lblvendacarro" runat="server" Text="0"></asp:Label></td>
                                            </tr>
                                        </table>
                                        <br />
                                        <table border="1" cellspacing="0">
                                            <tr>
                                                <td align="center">Meta de Fluxo:</td>

                                            </tr>
                                            <tr>
                                                <td align="center">SIA: 200</td>

                                            </tr>
                                            <tr>
                                                <td align="center">SAAN: 60</td>

                                            </tr>
                                            <tr>
                                                <td align="center">SCIA: 45</td>

                                            </tr>
                                            <tr>
                                                <td align="center">AERO: 45</td>

                                            </tr>

                                        </table>
                                        <br />





                                    </div>
                                    <table border="1" cellspacing="0" visible="true">
                                        <tr>
                                            <td>Evento:
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="ddlEvento3" runat="server">
                                                    <asp:ListItem>Campanha Argo Trekking</asp:ListItem>
                                                </asp:DropDownList></td>
                                            <td>Loja:</td>
                                            <td></td>
                                            <td>
                                                <asp:DropDownList ID="ddlloja4" runat="server">
                                                    <asp:ListItem>SIA</asp:ListItem>
                                                    <asp:ListItem>SCIA</asp:ListItem>
                                                    <asp:ListItem>SAAN</asp:ListItem>
                                                    <asp:ListItem>AERO</asp:ListItem>
                                                </asp:DropDownList></td>
                                            <td></td>
                                            <td>EQUIPE:</td>
                                            <td>
                                                <asp:DropDownList ID="ddlequipe4" runat="server">
                                                    <asp:ListItem>BRANCA</asp:ListItem>
                                                    <asp:ListItem>AMARELA</asp:ListItem>
                                                    <asp:ListItem>VERDE</asp:ListItem>
                                                    <asp:ListItem>AZUL</asp:ListItem>
                                                </asp:DropDownList></td>
                                            <td>
                                                <asp:Button ID="btnProcessar4" runat="server" Text="Processar" OnClick="btnProcessar4_Click" CssClass="btns" /></td>

                                        </tr>
                                    </table>
                                   
                                    <br />
                                    <table border="1" cellspacing="0">
                                        <tr>
                                            <td align="center">Total:
                                                <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource2" BackColor="White" BorderColor="#999999" BorderStyle="Solid" BorderWidth="1px" CellPadding="3" ForeColor="Black" GridLines="Vertical">
                                                    <AlternatingRowStyle BackColor="#CCCCCC" />
                                                    <Columns>
                                                        <asp:BoundField DataField="vendedor" HeaderText="vendedor" SortExpression="vendedor" />
                                                        <asp:BoundField DataField="qtde" HeaderText="qtde" ReadOnly="True" SortExpression="qtde" />
                                                    </Columns>
                                                    <FooterStyle BackColor="#CCCCCC" />
                                                    <HeaderStyle BackColor="Black" Font-Bold="True" ForeColor="White" />
                                                    <PagerStyle BackColor="#999999" ForeColor="Black" HorizontalAlign="Center" />
                                                    <SelectedRowStyle BackColor="#000099" Font-Bold="True" ForeColor="White" />
                                                    <SortedAscendingCellStyle BackColor="#F1F1F1" />
                                                    <SortedAscendingHeaderStyle BackColor="Gray" />
                                                    <SortedDescendingCellStyle BackColor="#CAC9C9" />
                                                    <SortedDescendingHeaderStyle BackColor="#383838" />
                                                </asp:GridView>
                                                <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="prospeccao_relatoriototalequipes" SelectCommandType="StoredProcedure">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="ddlEvento3" DefaultValue="FIAT D" Name="evento" PropertyName="SelectedValue" Type="String" />
                                                        <asp:ControlParameter ControlID="ddlloja4" DefaultValue="SIA" Name="loja" PropertyName="SelectedValue" Type="String" />
                                                        <asp:ControlParameter ControlID="ddlequipe4" DefaultValue="AMARELA" Name="equipe" PropertyName="SelectedValue" Type="String" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource>
                                            </td>
                                            <td align="center">Quentes:
                                                    <asp:GridView ID="grdviewQuente" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource3" BackColor="White" BorderColor="#999999" BorderStyle="Solid" BorderWidth="1px" CellPadding="3" ForeColor="Black" GridLines="Vertical">
                                                        <AlternatingRowStyle BackColor="#CCCCCC" />
                                                        <Columns>
                                                            <asp:BoundField DataField="vendedor" HeaderText="vendedor" SortExpression="vendedor" />
                                                            <asp:BoundField DataField="qtde" HeaderText="qtde" ReadOnly="True" SortExpression="qtde" />
                                                        </Columns>
                                                        <FooterStyle BackColor="#CCCCCC" />
                                                        <HeaderStyle BackColor="Black" Font-Bold="True" ForeColor="White" />
                                                        <PagerStyle BackColor="#999999" ForeColor="Black" HorizontalAlign="Center" />
                                                        <SelectedRowStyle BackColor="#000099" Font-Bold="True" ForeColor="White" />
                                                        <SortedAscendingCellStyle BackColor="#F1F1F1" />
                                                        <SortedAscendingHeaderStyle BackColor="Gray" />
                                                        <SortedDescendingCellStyle BackColor="#CAC9C9" />
                                                        <SortedDescendingHeaderStyle BackColor="#383838" />
                                                    </asp:GridView>
                                                <asp:SqlDataSource ID="SqlDataSource3" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="prospeccao_relatoriototalequipesquente" SelectCommandType="StoredProcedure">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="ddlEvento3" DefaultValue="FIAT D" Name="evento" PropertyName="SelectedValue" Type="String" />
                                                        <asp:ControlParameter ControlID="ddlloja4" DefaultValue="SIA" Name="loja" PropertyName="SelectedValue" Type="String" />
                                                        <asp:ControlParameter ControlID="ddlequipe4" DefaultValue="AMARELA" Name="equipe" PropertyName="SelectedValue" Type="String" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource></td>
                                            <td align="center">Frios:
                                                    <asp:GridView ID="GridView2" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource4" BackColor="White" BorderColor="#999999" BorderStyle="Solid" BorderWidth="1px" CellPadding="3" ForeColor="Black" GridLines="Vertical">
                                                        <AlternatingRowStyle BackColor="#CCCCCC" />
                                                        <Columns>
                                                            <asp:BoundField DataField="vendedor" HeaderText="vendedor" SortExpression="vendedor" />
                                                            <asp:BoundField DataField="qtde" HeaderText="qtde" ReadOnly="True" SortExpression="qtde" />
                                                        </Columns>
                                                        <FooterStyle BackColor="#CCCCCC" />
                                                        <HeaderStyle BackColor="Black" Font-Bold="True" ForeColor="White" />
                                                        <PagerStyle BackColor="#999999" ForeColor="Black" HorizontalAlign="Center" />
                                                        <SelectedRowStyle BackColor="#000099" Font-Bold="True" ForeColor="White" />
                                                        <SortedAscendingCellStyle BackColor="#F1F1F1" />
                                                        <SortedAscendingHeaderStyle BackColor="Gray" />
                                                        <SortedDescendingCellStyle BackColor="#CAC9C9" />
                                                        <SortedDescendingHeaderStyle BackColor="#383838" />
                                                    </asp:GridView>
                                                <asp:SqlDataSource ID="SqlDataSource4" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="prospeccao_relatoriototalequipesfrio" SelectCommandType="StoredProcedure">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="ddlEvento3" DefaultValue="FIAT D" Name="evento" PropertyName="SelectedValue" Type="String" />
                                                        <asp:ControlParameter ControlID="ddlloja4" DefaultValue="SIA" Name="loja" PropertyName="SelectedValue" Type="String" />
                                                        <asp:ControlParameter ControlID="ddlequipe4" DefaultValue="AMARELA" Name="equipe" PropertyName="SelectedValue" Type="String" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource></td>
                                            <td align="center">Sem Interesse:
                                                    <asp:GridView ID="GridView3" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource5" BackColor="White" BorderColor="#999999" BorderStyle="Solid" BorderWidth="1px" CellPadding="3" ForeColor="Black" GridLines="Vertical">
                                                        <AlternatingRowStyle BackColor="#CCCCCC" />
                                                        <Columns>
                                                            <asp:BoundField DataField="vendedor" HeaderText="vendedor" SortExpression="vendedor" />
                                                            <asp:BoundField DataField="qtde" HeaderText="qtde" ReadOnly="True" SortExpression="qtde" />
                                                        </Columns>
                                                        <FooterStyle BackColor="#CCCCCC" />
                                                        <HeaderStyle BackColor="Black" Font-Bold="True" ForeColor="White" />
                                                        <PagerStyle BackColor="#999999" ForeColor="Black" HorizontalAlign="Center" />
                                                        <SelectedRowStyle BackColor="#000099" Font-Bold="True" ForeColor="White" />
                                                        <SortedAscendingCellStyle BackColor="#F1F1F1" />
                                                        <SortedAscendingHeaderStyle BackColor="Gray" />
                                                        <SortedDescendingCellStyle BackColor="#CAC9C9" />
                                                        <SortedDescendingHeaderStyle BackColor="#383838" />
                                                    </asp:GridView>
                                                <asp:SqlDataSource ID="SqlDataSource5" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="prospeccao_relatoriototalequipessemint" SelectCommandType="StoredProcedure">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="ddlEvento3" DefaultValue="FIAT D" Name="evento" PropertyName="SelectedValue" Type="String" />
                                                        <asp:ControlParameter ControlID="ddlloja4" DefaultValue="SIA" Name="loja" PropertyName="SelectedValue" Type="String" />
                                                        <asp:ControlParameter ControlID="ddlequipe4" DefaultValue="AMARELA" Name="equipe" PropertyName="SelectedValue" Type="String" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource></td>
                                            
                                        </tr>

                                    </table>
                                    <br />
                                    


                                </ContentTemplate>


                            </asp:TabPanel>
                            >
                            

                             <asp:TabPanel ID="TabPanel7" Style="padding: 20px;" runat="server" HeaderText="TabPanel1" Visible="false">
                                 <HeaderTemplate>
                                     Desativado
                                 </HeaderTemplate>
                                 <ContentTemplate>
                                     <div id="Div2" onmouseover="esconderMenuLeftMouse()">
                                         <table style="width: 100%; padding: 13px;" align="center" onmouseover="esconderMenuLeftMouse()">
                                             <tr>
                                                 <td>
                                             </tr>
                                         </table>
                                     </div>


                                 </ContentTemplate>
                             </asp:TabPanel>


                        </asp:TabContainer>
                </tr>
            </table>
           <%-- <script>
                $(function () {
                    
                    $('#chartqtdediv').highcharts({
                        chart: {
                            type: 'line'
                        },
                        credits: {
                            enabled: 0
                        },
                        title: {
                            text: '<b>Quantidade de Clientes Confirmados por dia.</b>'
                        },
                        subtitle: {
                            //text: 'Source: <a href="http://en.wikipedia.org/wiki/List_of_cities_proper_by_population">Wikipedia</a>'
                        },
                        xAxis: {
                            type: 'category',
                            labels: {
                                rotation: -45,
                                align: 'right',
                                style: {
                                    fontSize: '10px',
                                    fontFamily: 'Verdana, sans-serif'
                                    
                                }
                            
                            }
                        },
                        yAxis: {
                            min: 0,
                            title: {
                                text: 'Quantidade'
                            }
                        },
                        legend: {
                            enabled: false
                        },
                        tooltip: {
                            pointFormat: 'Quantidade: <b>{point.y:.1f}</b>',
                        },
                        //legend: {
                        //    layout: 'vertical',
                        //    align: 'center',
                        //    verticalAlign: 'bottom',
                        //    borderWidth: 0
                        //},


                        series: [{
                            //color: 'blue',
                            name: 'Dia',
                            data: [
                        <%=chartqtdediv%>
                            ],
                            
                            dataLabels: {
                                enabled: true,
                                //rotation: -90,
                                color: 'black',
                                //align: 'right',
                                align: 'center',
                                x: 0,
                                y: -10,
                                style: {
                                    fontSize: '10px',
                                    fontFamily: 'Verdana, sans-serif',
                                    // textShadow: '0 0 3px black'
                                }
                            }
                        }]
                    });
                });
    </script>--%>
        </div>
    </form>
</body>
</html>
