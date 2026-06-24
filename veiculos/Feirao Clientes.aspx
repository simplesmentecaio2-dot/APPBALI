<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Feirao Clientes.aspx.cs" Inherits="veiculos_contrato" %>

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

    <script src="../tables/js/jquery.dataTables.min.js"></script>
    <link href="../tables/estilo/jquery-ui-1.8.4.custom.css" rel="stylesheet" />
    <link href="../tables/estilo/table.css" rel="stylesheet" />
    <link href="../tables/estilo/table_jui.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            oTable = $('#tblConsultaProcesso').dataTable({ //example é o ID da tabela
                "bPaginate": true,
                "bJQueryUI": true,
                "sPaginationType": "full_numbers"
            });
        });
    </script>

    <script type="text/javascript">
        $(document).ready(function () {
            oTable = $('#tblConsultaProcesso2m').dataTable({ //example é o ID da tabela
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

            <div class="item-menu"><a class="links" <a href="contrato.aspx">contrato.aspx</a>>Novo</a></div>
            <div class="item-menu"><a class="links" href="preConsulta.aspx">Consulta</a></div>

            <div id="completa-menu-left"></div>
        </div>

        <div id="Cont" onmouseover="esconderMenuLeftMouse()">
            <table style="width: 100%; padding: 13px; text-align: left;" align="center">
                <tr style="width: 100%;">
                    <td style="width: 100%;">

                        <asp:TabContainer ID="TabContainerProcesso" CssClass="tabPanelConsultar" Width="100%" runat="server" ActiveTabIndex="0">
                            <asp:TabPanel ID="TabPanelProcessos" Style="padding: 20px;" runat="server" HeaderText="TabPanel1">
                                <HeaderTemplate>
                                    Novo (+)
                                </HeaderTemplate>
                                <ContentTemplate>
                                    <%--<asp:RadioButton ID="rbtnVN" GroupName="tipo" Text="NOVO" runat="server" AutoPostBack="True" OnCheckedChanged="rbtnVN_CheckedChanged" />&nbsp&nbsp&nbsp
                                    <asp:RadioButton ID="rbtnVU" GroupName="tipo" Text="USADO" runat="server" AutoPostBack="True" OnCheckedChanged="rbtnVU_CheckedChanged" />--%>
                                    <br />
                                    <br />
                                    <asp:Panel ID="Panel1" runat="server" Visible="True">
                                        <table border="1" cellspacing="0" style="width: 30cm;">
                                            <tr>
                                                <td colspan="7" style="text-align: center; background-color: silver;">DADOS DO CLIENTE
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="width: 1.8cm;">CLIENTE:
                                                </td>
                                                <td colspan="6">
                                                    <asp:TextBox ID="txtCliente" MaxLength="100" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>ENDEREÇO:
                                                </td>
                                                <td colspan="4">
                                                    <asp:TextBox ID="txtEndereco" MaxLength="100" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>CEP:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtCEP" MaxLength="10" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>BAIRRO:
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtBairro" MaxLength="20" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>CIDADE:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtCidade" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>UF:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtUF" MaxLength="2" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>CPF/CNPJ:
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtCPFCNPJ" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>RG/I.E.
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtRGIE" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>D.NASC.:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtNascimento" CssClass="date form-contrato" runat="server"></asp:TextBox>


                                                </td>
                                            </tr>
                                            <tr>
                                                <td>TEL. RES.:
                                                </td>
                                                <td style="width: 3.6cm;">
                                                    <asp:TextBox ID="txtTelREsidencial" CssClass="phone form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>TEL COM.:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtTelCom" CssClass="phone form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>CELULAR:
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtCelular" CssClass="phone form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>E-MAIL.:
                                                </td>
                                                <td colspan="6">
                                                    <asp:TextBox ID="txtEmail" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                        <table border="1" cellspacing="0" style="width: 30cm;">
                                          

                                        </table>
                                        <asp:Button ID="btnGravar" runat="server" Text="Gravar" OnClick="btnGravar_Click" />
                                        <asp:ImageButton ID="ibtnDadosCliente" ImageUrl="~/img/ok.png" Width="22px" runat="server" Visible="False" />

                                    </asp:Panel>
                                </ContentTemplate>

                            </asp:TabPanel>
                            <asp:TabPanel ID="TabPanel2" Style="padding: 20px;" runat="server" HeaderText="TabPanel1">
                                <HeaderTemplate>
                                    Consulta Novo
                                </HeaderTemplate>
                                <ContentTemplate>
                                    <div id="Div1" onmouseover="esconderMenuLeftMouse()">
                                        <table style="width: 100%; padding: 13px;" align="center" onmouseover="esconderMenuLeftMouse()">
                                            <tr style="width: 100%;">
                                                <td style="width: 100%;">
                                                    <%=tabela %>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </ContentTemplate>


                            </asp:TabPanel>

                           
                        </asp:TabContainer>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
