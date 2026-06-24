<%@ Page Language="C#" AutoEventWireup="true" CodeFile="qrcodegenerator.aspx.cs" Inherits="veiculos_contrato" %>

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
            /*background-color: #D8E6ED;*/
            text-transform: uppercase;
            font-weight: bold;
        }

        </style>

    <style type="text/css">
        
    img{border-radius: 20px;}
       
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
                    <td id="table-menu-logo"><font style="font-family: Arial black; font-size: 32px; font-style: italic; color: white; margin-left: 13px;"><a href="../default.aspx" class="linkHome">BALI</a></font><font style="font-family: Calibri; font-size: 14px; margin-left: 5px; font-style: italic; color: white;">APP</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
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


            <div class="item-menu"><a class="links" href="prospeccao.aspx">Prospeccao</a></div>

            <div id="completa-menu-left"></div>
        </div>

        <div id="Cont" onmouseover="esconderMenuLeftMouse()">
            <table style="width: 100%; padding: 13px; text-align: left;" align="center">
                <tr style="width: 100%;">
                    <td style="width: 100%;">

                        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="gerencia_vendedor2" SelectCommandType="StoredProcedure"></asp:SqlDataSource>

                        <asp:TabContainer ID="TabContainerProcesso" CssClass="tabPanelConsultar" Width="100%" runat="server" ActiveTabIndex="0">
                           
                            <asp:TabPanel ID="TabPanel2" Style="padding: 20px;" runat="server" HeaderText="TabPanel1">
                                <HeaderTemplate>
                                    QrCode
                                </HeaderTemplate>
                                <ContentTemplate>
                                    <table border="1" align="left">
                                        <tr>
                                            <td align="center"> <asp:Label ID="lblCliente" runat="server" CssClass="form-contrato" ></asp:Label><br /><br /> VOCÊ FOI CONVIDADO(A) PARA O EVENTO !!<br />
                                                <asp:Label ID="lblevento" runat="server" Text="Label" CssClass="form-contrato" Visible="False"></asp:Label>
                                                <br /><img src="../img/SEU%20FIAT%20EM%20DIA.png" style="height: 77px; width: 234px"/>
                                                <br /><br /> TRAGA O QRCODE <br /><br />
                                                

                                    
                                    <asp:PlaceHolder ID="PHQRCode" runat="server"></asp:PlaceHolder><br />
                                                Vendedor:&nbsp; <asp:Label ID="lblvendedor" runat="server" Text="Label" CssClass="form-contrato"></asp:Label><br />
                                                Loja:&nbsp; <asp:Label ID="lblloja" runat="server" Text="Label" CssClass="form-contrato"></asp:Label><br />
                                                Equipe:&nbsp;<asp:Label ID="lblequipe" runat="server" Text="Label" CssClass="form-contrato"></asp:Label><br />
                                                <br />
                                                <img src="../img/logobali.png" />
                                                <br />
                                                
                                               
                                            </td>
                                        </tr>
                                    </table>
                                    
                                    </ContentTemplate>
                                </asp:TabPanel>

                        </asp:TabContainer>
                </tr>
            </table>
            <%--<script>
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
