<%@ Page Language="C#" AutoEventWireup="true" CodeFile="contrato.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Contrato de Venda - BYD</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/estilo.css" rel="stylesheet" />
    <script src="../js/jquery-1.10.2.js"></script>
    <script src="../js/js.js"></script>
    <script src="../js/jquery.maskMoney.js"></script>
    <script src="../js/maskMin.js"></script>
    <script src="../js/maskPhone.js"></script>

    <script src="../tables/js/jquery.dataTables.min.js"></script>
    <link href="../tables/estilo/table.css" rel="stylesheet" />
    <link href="../css/bali-contract.css?v=20260624-contratos63" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            oTable = $('#tblConsultaProcesso').dataTable({ //example é o ID da tabela
                "bPaginate": true,
                "bJQueryUI": false,
                "sPaginationType": "full_numbers",
                "iDisplayLength": 10,
                "oLanguage": {
                    "sLengthMenu": "Mostrar _MENU_ contratos",
                    "sZeroRecords": "Nenhum contrato encontrado",
                    "sInfo": "Mostrando _START_ a _END_ de _TOTAL_ contratos",
                    "sInfoEmpty": "Mostrando 0 contratos",
                    "sInfoFiltered": "(filtrado de _MAX_ contratos)",
                    "sSearch": "Filtrar",
                    "oPaginate": {
                        "sFirst": "Primeiro",
                        "sPrevious": "Anterior",
                        "sNext": "Próximo",
                        "sLast": "Último"
                    }
                }
            });
        });
    </script>

    <script type="text/javascript">
        $(document).ready(function () {
            oTable = $('#tblConsultaProcesso2').dataTable({ //example é o ID da tabela
                "bPaginate": true,
                "bJQueryUI": false,
                "sPaginationType": "full_numbers",
                "iDisplayLength": 10,
                "oLanguage": {
                    "sLengthMenu": "Mostrar _MENU_ contratos",
                    "sZeroRecords": "Nenhum contrato encontrado",
                    "sInfo": "Mostrando _START_ a _END_ de _TOTAL_ contratos",
                    "sInfoEmpty": "Mostrando 0 contratos",
                    "sInfoFiltered": "(filtrado de _MAX_ contratos)",
                    "sSearch": "Filtrar",
                    "oPaginate": {
                        "sFirst": "Primeiro",
                        "sPrevious": "Anterior",
                        "sNext": "Próximo",
                        "sLast": "Último"
                    }
                }
            });
        });
    </script>

    <script>
        function aguarde() {
            $("#ag").toggle();
            //document.getElementById('ag').style.visibility = 'visible';
        }

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

    <script src="../js/bali-contract.js?v=20260624-contratos63"></script>
</head>
<body class="bali-contract-page contrato-byd">
    <form id="form1" style="height: 100%;" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo"><font style="font-family: Arial black; font-size: 32px; font-style: italic; color: white; margin-left: 13px;"><a href="../Default.aspx" class="linkHome"><img src="../img/bydbranco.png" style="height: 34px; width: 149px" /></a></font><font style="font-family: Calibri; font-size: 14px; margin-left: 5px; font-style: italic; color: white;">APP</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
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

                        <asp:TabContainer ID="TabContainerProcesso" CssClass="tabPanelConsultar" Width="100%" runat="server" ActiveTabIndex="0">
                            <asp:TabPanel ID="TabPanelBI" Style="padding: 20px;" runat="server" HeaderText="TabPanel1">
                                <HeaderTemplate>
                                    BI
                                </HeaderTemplate>
                                <ContentTemplate>
                                    <div class="contract-bi-panel">
                                        <div class="contract-bi-filter">
                                            <div>
                                                <span class="contract-bi-kicker">Indicadores</span>
                                                <h2>BI de contratos BYD</h2>
                                                <p>Resumo do período por tipo, vendedor, forma de pagamento e evolução diária.</p>
                                            </div>
                                            <div class="contract-bi-controls">
                                                <label>Data inicial
                                                    <asp:TextBox ID="txtBiDtInicial" CssClass="txts" runat="server"></asp:TextBox>
                                                    <asp:CalendarExtender ID="CalendarExtenderBI1" runat="server" Enabled="True" Format="dd/MM/yyyy" TargetControlID="txtBiDtInicial"></asp:CalendarExtender>
                                                </label>
                                                <label>Data final
                                                    <asp:TextBox ID="txtBiDtFinal" CssClass="txts" runat="server"></asp:TextBox>
                                                    <asp:CalendarExtender ID="CalendarExtenderBI2" runat="server" Enabled="True" Format="dd/MM/yyyy" TargetControlID="txtBiDtFinal"></asp:CalendarExtender>
                                                </label>
                                                <asp:Button ID="btnAtualizarBI" runat="server" Text="Atualizar BI" CssClass="btns" OnClick="btnAtualizarBI_Click" />
                                            </div>
                                        </div>
                                        <%=biHtml %>
                                    </div>
                                </ContentTemplate>
                            </asp:TabPanel>
                            <asp:TabPanel ID="TabPanelAuditoria" Style="padding: 20px;" runat="server" HeaderText="TabPanel1">
                                <HeaderTemplate>
                                    Auditoria
                                </HeaderTemplate>
                                <ContentTemplate>
                                    <div class="contract-audit-panel">
                                        <div class="contract-audit-filter">
                                            <div>
                                                <span class="contract-bi-kicker">Auditoria</span>
                                                <h2>Ocorrências dos contratos</h2>
                                                <p>Resumo de validações, erros, duplicidades, gravações e edições registradas.</p>
                                            </div>
                                            <div class="contract-audit-search">
                                                <label>ID do contrato
                                                    <asp:TextBox ID="txtAuditoriaContrato" CssClass="txts" runat="server"></asp:TextBox>
                                                </label>
                                                <asp:Button ID="btnConsultarHistoricoContrato" runat="server" Text="Consultar histórico" CssClass="btns" OnClick="btnConsultarHistoricoContrato_Click" />
                                            </div>
                                        </div>
                                        <%=auditoriaHtml %>
                                        <%=historicoHtml %>
                                    </div>
                                </ContentTemplate>
                            </asp:TabPanel>
                            <asp:TabPanel ID="TabPanelProcessos" Style="padding: 20px;" runat="server" HeaderText="TabPanel1">
                                <HeaderTemplate>
                                    Novo (+)
                                
</HeaderTemplate>
                                

<ContentTemplate>
<asp:RadioButton ID="rbtnVN" GroupName="tipo" Text="NOVO" runat="server" AutoPostBack="True" OnCheckedChanged="rbtnVN_CheckedChanged" />

&#160;&#160;&#160; <asp:RadioButton ID="rbtnVU" GroupName="tipo" Text="USADO" runat="server" AutoPostBack="True" OnCheckedChanged="rbtnVU_CheckedChanged" />

&#160;&#160;&#160; <br />
                                    <br />
                                    <asp:Panel ID="Panel1" runat="server" Visible="False"><table border="1" cellspacing="0" style="width: 30cm;"><tr><td colspan="7" style="text-align: center; background-color: silver;">DADOS DO CLIENTE </td></tr><tr><td style="width: 1.8cm;">CLIENTE: </td><td colspan="6"><asp:TextBox ID="txtCliente" runat="server" CssClass="form-contrato" MaxLength="100"></asp:TextBox></td></tr><tr><td>ENDEREÇO: </td><td colspan="4"><asp:TextBox ID="txtEndereco" runat="server" CssClass="form-contrato" MaxLength="100"></asp:TextBox></td><td>CEP: </td><td><asp:TextBox ID="txtCEP" runat="server" CssClass="form-contrato" MaxLength="10"></asp:TextBox></td></tr><tr><td>BAIRRO: </td><td colspan="2"><asp:TextBox ID="txtBairro" runat="server" CssClass="form-contrato" MaxLength="20"></asp:TextBox></td><td>CIDADE: </td><td><asp:TextBox ID="txtCidade" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>UF: </td><td><asp:TextBox ID="txtUF" runat="server" CssClass="form-contrato" MaxLength="2"></asp:TextBox></td></tr><tr><td>CPF/CNPJ: </td><td colspan="2"><asp:TextBox ID="txtCPFCNPJ" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>RG/I.E. </td><td><asp:TextBox ID="txtRGIE" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>D.NASC.: </td><td><asp:TextBox ID="txtNascimento" runat="server" CssClass="date form-contrato"></asp:TextBox></td></tr><tr><td>TEL. RES.: </td><td style="width: 3.6cm;"><asp:TextBox ID="txtTelREsidencial" runat="server" CssClass="phone form-contrato"></asp:TextBox></td><td>TEL COM.: </td><td><asp:TextBox ID="txtTelCom" runat="server" CssClass="phone form-contrato"></asp:TextBox></td><td>CELULAR: </td><td colspan="2"><asp:TextBox ID="txtCelular" runat="server" CssClass="phone form-contrato"></asp:TextBox></td></tr><tr><td>E-MAIL.: </td><td colspan="6"><asp:TextBox ID="txtEmail" runat="server" CssClass="form-contrato"></asp:TextBox></td></tr></table><table border="1" cellspacing="0" style="width: 30cm;"><tr><td colspan="6" style="text-align: center; background-color: silver;">DADOS DO VEÍCULO </td></tr><tr><td>MARCA: </td><td><asp:TextBox ID="txtMarca" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>MODELO: </td><td><asp:TextBox ID="txtModelo" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>COR EXT.: </td><td><asp:TextBox ID="txtCorExterna" runat="server" CssClass="form-contrato"></asp:TextBox></td></tr><tr><td>CHASSI/PLACA: </td><td colspan="3"><asp:TextBox ID="txtChassiPlaca" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>ANO/MOD: </td><td><asp:TextBox ID="txtAnoMod" runat="server" CssClass="form-contrato"></asp:TextBox></td></tr><tr><td>OPCIONAIS: </td><td colspan="5"><asp:TextBox ID="txtOpcionais" runat="server" CssClass="form-contrato"></asp:TextBox></td></tr></table><table border="1" cellspacing="0" style="width: 30cm;"><tr><td colspan="9" style="text-align: center; background-color: silver;">PREÇO E FORMAS DE PAGAMENTOS </td></tr><tr><td colspan="2">MODALIDADES DE PAGAMENTOS: </td><td colspan="2">Á VISTA: <asp:RadioButton ID="rBtnModPagVista" runat="server" GroupName="modpag"></asp:RadioButton>


                                                </td>
                                                <td colspan="2">FINANCIAMENTO: <asp:RadioButton ID="rBtnModPagFinanciamento" runat="server" GroupName="modpag"></asp:RadioButton>


                                                </td>
                                                <td>FINANCEIRA: </td><td colspan="2"><asp:TextBox ID="txtFinanceira" CssClass="form-contrato" runat="server"></asp:TextBox></td></tr><tr><td style="width: 4.5cm;">VALOR DO VEÍCULO: </td><td><asp:TextBox ID="txtValoVeiculo" runat="server" CssClass="form-contrato"></asp:TextBox></td><td colspan="6"><asp:Label ID="lblEmpTrans" runat="server"></asp:Label>(SERVIÇOS DE DESPACHANTE + TAXAS OPERACIONAIS) </td><td><asp:TextBox ID="txtEmplacamento" runat="server" CssClass="form-contrato"></asp:TextBox></td></tr><tr><td>ENTRADA: </td><td><asp:TextBox ID="txtEntrada" runat="server" CssClass="real form-contrato"></asp:TextBox></td><td colspan="2">FORMAS DE PAGAMENTO: </td><td colspan="5"><asp:TextBox ID="txtFormasPagamento" CssClass="form-contrato" runat="server"></asp:TextBox></td></tr><tr><td>AVALIAÇÃO USADO: </td><td><asp:TextBox ID="txtCarroUsado" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>MOD/MARCA: </td><td colspan="2"><asp:TextBox ID="txtModMarca" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>ANO/MOD: </td><td><asp:TextBox ID="txtAnoModelo" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>PLACA: </td><td><asp:TextBox ID="txtPlacaVU" runat="server" CssClass="form-contrato"></asp:TextBox></td></tr><tr><td>VALOR UTILIZADO NA AVALIAÇÃO: </td><td><asp:TextBox ID="txtVlUtilzadoAvaliacao" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>QUITAÇÃO:</td><td><asp:TextBox ID="txtQuitacao" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>SALDO AVALIAÇÃO:</td><td><asp:TextBox ID="txtSaldoAvaliacao" runat="server" CssClass="form-contrato" Enabled="False"></asp:TextBox></td></tr><tr><td style="width: 3.5cm;">FINANCIAMENTO: </td><td><asp:TextBox ID="txtVlFinanciamento" runat="server" CssClass="real form-contrato" Enabled="False"></asp:TextBox></td><td>Nº PARC.: </td><td><asp:TextBox ID="txtNrParcelas" runat="server" CssClass="form-contrato"></asp:TextBox></td><td>VL PARC.: </td><td><asp:TextBox ID="txtVlParcelas" runat="server" CssClass="real form-contrato"></asp:TextBox></td><td colspan="2">PLANO FINANCIAMENTO: </td><td><asp:TextBox ID="txtPlano" runat="server" CssClass="form-contrato"></asp:TextBox></td></tr><tr><td>CORTESIAS: </td><td colspan="8"><asp:TextBox ID="txtCortesias" runat="server" CssClass="form-contrato"></asp:TextBox></td></tr><tr><td>OBS: </td><td colspan="8"><asp:TextBox ID="txtObs" runat="server" CssClass="form-contrato"></asp:TextBox></td></tr><tr><td>PREVISÃO DE ENTREGA: </td><td colspan="8"><asp:TextBox ID="txtPrevisao" runat="server" CssClass="form-contrato" Width="30px"></asp:TextBox>DIAS ÚTEIS A PARTIR DA CONFIRMAÇÃO DO PEDIDO. </td></tr><tr><td>VENDEDOR: </td><td colspan="8"><asp:DropDownList runat="server" id="ddlVendedor" CssClass="form-contrato" DataSourceID="SqlDataSource1" DataTextField="vend" DataValueField="vend"></asp:DropDownList>



                                                <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:WF %>" SelectCommand="select usuario_nome as vend  from [GrupoBali_DealernetWF]..Usuario where Usuario_DataDemissao is null

order by usuario_nome "></asp:SqlDataSource>
</td>
                                            </tr>

                                        </table>
                                        <div class="contract-checklist">
                                            <strong>Checklist final</strong>
                                            <div class="contract-checklist-grid">
                                                <label class="contract-check"><asp:CheckBox ID="chkConfereDocumento" runat="server" /> Documento do cliente conferido</label>
                                                <label class="contract-check"><asp:CheckBox ID="chkConfereValores" runat="server" /> Valores conferidos</label>
                                                <label class="contract-check"><asp:CheckBox ID="chkConferePagamento" runat="server" /> Forma de pagamento conferida</label>
                                                <label class="contract-check contract-check-duplicate"><asp:CheckBox ID="chkConfirmarDuplicidade" runat="server" /> Estou ciente caso exista contrato semelhante recente</label>
                                            </div>
                                        </div>
                                        <asp:Button ID="btnGravar" runat="server" Text="Gravar" OnClick="btnGravar_Click" CssClass="btns" />


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
                                                    <table>
                                                        <tr>
                                                            <td>Data Inicial:</td>
                                                            <td>Data Final:</td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:TextBox ID="txtDtInicialVN" CssClass="txts" runat="server"></asp:TextBox>
                                                                <asp:CalendarExtender Format="dd/MM/yyyy" ID="CalendarExtender1" runat="server" Enabled="True" TargetControlID="txtDtInicialVN">
                                                                </asp:CalendarExtender>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtDtFinalVN" CssClass="txts" runat="server"></asp:TextBox>
                                                                <asp:CalendarExtender Format="dd/MM/yyyy" ID="CalendarExtender2" runat="server" Enabled="True" TargetControlID="txtDtFinalVN">
                                                                </asp:CalendarExtender>

                                                                <asp:Button ID="Button1" runat="server" Text="Processar VN" CssClass="btns" OnClick="Button1_Click" OnClientClick="aguarde();" />

                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <%=tabela %>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                
</ContentTemplate>


                            

</asp:TabPanel>

                            <asp:TabPanel ID="TabPanel1" Style="padding: 20px;" runat="server" HeaderText="TabPanel1">
                                <HeaderTemplate>
                                    Consulta Usado
                                
</HeaderTemplate>
                                

<ContentTemplate>
                                    <div id="Div2" onmouseover="esconderMenuLeftMouse()">
                                        <table style="width: 100%; padding: 13px;" align="center" onmouseover="esconderMenuLeftMouse()">
                                            <tr style="width: 100%;">
                                                <td style="width: 100%;">
                                                    <table style="width: 100%; max-width: 720px; margin-bottom: 16px;">
                                                        <tr>
                                                            <td>Data Inicial:</td>
                                                            <td>Data Final:</td>
                                                            <td></td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:TextBox ID="txtDtInicialVU" CssClass="txts" runat="server"></asp:TextBox>
                                                                <asp:CalendarExtender Format="dd/MM/yyyy" ID="CalendarExtenderVU1" runat="server" Enabled="True" TargetControlID="txtDtInicialVU"></asp:CalendarExtender>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtDtFinalVU" CssClass="txts" runat="server"></asp:TextBox>
                                                                <asp:CalendarExtender Format="dd/MM/yyyy" ID="CalendarExtenderVU2" runat="server" Enabled="True" TargetControlID="txtDtFinalVU"></asp:CalendarExtender>
                                                            </td>
                                                            <td>
                                                                <asp:Button ID="Button2" runat="server" Text="Processar VU" CssClass="btns" OnClick="Button2_Click" OnClientClick="aguarde();" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <%=tabelaVU %>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                
</ContentTemplate>
                            

</asp:TabPanel>

                             

 <asp:TabPanel ID="TabPanel3" Style="padding: 20px;" runat="server" HeaderText="TabPanel1" >
                                <HeaderTemplate>
                                    Editar Contrato
                                
</HeaderTemplate>
                                

<ContentTemplate>
                                    Número do Contrato <asp:TextBox ID="txtContrato" runat="server" Width="40px"></asp:TextBox>
                                     &nbsp;&nbsp;&nbsp;
                                     <asp:ImageButton ID="ImageButton1" ImageUrl="~/img/ok.png" Width="22px" runat="server" OnClick="ImageButton1_Click"  />
                                    <br />
                                    <div id="Div3" onmouseover="esconderMenuLeftMouse()">                                        
                                         <table border="1" cellspacing="0" style="width: 30cm;">
                                            <tr>
                                                <td colspan="7" style="text-align: center; background-color: silver;">DADOS DO CLIENTE
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="width: 1.8cm;">CLIENTE:
                                                </td>
                                                <td colspan="6">
                                                    <asp:TextBox ID="txtEdCliente" MaxLength="100" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>ENDEREÇO:
                                                </td>
                                                <td colspan="4">
                                                    <asp:TextBox ID="txtEdEndereco" MaxLength="100" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>CEP:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdCep" MaxLength="10" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>BAIRRO:
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtEdBairro" MaxLength="20" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>CIDADE:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdCidade" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>UF:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdUF" MaxLength="2" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>CPF/CNPJ:
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtEdCPF" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>RG/I.E.
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdRG" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>D.NASC.:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdNascimento" CssClass="date form-contrato" runat="server"></asp:TextBox>


                                                </td>
                                            </tr>
                                            <tr>
                                                <td>TEL. RES.:
                                                </td>
                                                <td style="width: 3.6cm;">
                                                    <asp:TextBox ID="txtEdTelRes" CssClass="phone form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>TEL COM.:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdComercial" CssClass="phone form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>CELULAR:
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtEdCelular" CssClass="phone form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>E-MAIL.:
                                                </td>
                                                <td colspan="6">
                                                    <asp:TextBox ID="txtEdEmail" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                        <table border="1" cellspacing="0" style="width: 30cm;">
                                            <tr>
                                                <td colspan="6" style="text-align: center; background-color: silver;">DADOS DO VEÍCULO
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>MARCA:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdMarca" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>MODELO:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdModelo" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>COR EXT.:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdCorExt" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>CHASSI/PLACA:
                                                </td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtEdChassi" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>ANO/MOD:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdAnomodelo" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>OPCIONAIS:
                                                </td>
                                                <td colspan="5">
                                                    <asp:TextBox ID="txtEdOpcionais" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                        <table border="1" cellspacing="0" style="width: 30cm;">
                                            <tr>
                                                <td colspan="9" style="text-align: center; background-color: silver;">PREÇO E FORMAS DE PAGAMENTOS
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">MODALIDADES DE PAGAMENTOS:
                                                </td>
                                                <td colspan="2">Á VISTA:
                                                    <asp:RadioButton ID="rbtnEdAVISTA" GroupName="modpag" runat="server" />
                                                </td>
                                                <td colspan="2">FINANCIAMENTO:
                                                    <asp:RadioButton ID="rbtnEdAprazo" GroupName="modpag" runat="server" />
                                                </td>
                                                <td>FINANCEIRA:
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtEdFinanceira" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="width: 4.5cm;">VALOR DO VEÍCULO:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdValorVeic" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td colspan="6">
                                                    <asp:Label ID="Label1" runat="server"></asp:Label>
                                                    (SERVIÇOS DE DESPACHANTE + TAXAS OPERACIONAIS)
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdTAXAS" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>ENTRADA:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdEntrada" CssClass="real form-contrato" runat="server"></asp:TextBox>

                                                </td>
                                                <td colspan="2">FORMAS DE PAGAMENTO:
                                                </td>
                                                <td colspan="5">
                                                    <asp:TextBox ID="txtEdFormasPagamento" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>AVALIAÇÃO USADO:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdValorUSADO" CssClass="form-contrato" runat="server"></asp:TextBox>


                                                </td>
                                                <td>MOD/MARCA:
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtEdModMarcaUSADO" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>ANO/MOD:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdAnoMOdUSADO" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>PLACA:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdPlacaUSADO" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>VALOR UTILIZADO NA AVALIAÇÃO:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdVALORUSADOAVAILACAO" CssClass="form-contrato" runat="server"></asp:TextBox>



                                                </td>
                                                <td>QUITAÇÃO:</td>
                                                <td>
                                                    <asp:TextBox ID="txtEdQuitacao" CssClass="form-contrato" runat="server"></asp:TextBox></td>
                                                <td>SALDO AVALIAÇÃO:</td>
                                                <td>
                                                    <asp:TextBox ID="txtEdSaldoAvaliacao" CssClass="form-contrato" Enabled="False" runat="server"></asp:TextBox></td>

                                            </tr>
                                            <tr>
                                                <td style="width: 3.5cm;">FINANCIAMENTO:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdFinanciamento" CssClass="real form-contrato" runat="server" Enabled="False"></asp:TextBox>


                                                </td>
                                                <td>Nº PARC.:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdNumeroParcelas" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td>VL PARC.:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdValorParcela" CssClass="real form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                                <td colspan="2">PLANO FINANCIAMENTO:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtEdPlanoFinanciamento" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>CORTESIAS:
                                                </td>
                                                <td colspan="8">
                                                    <asp:TextBox ID="txtEdCortesias" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>OBS:
                                                </td>
                                                <td colspan="8">
                                                    <asp:TextBox ID="txtEdObs" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>PREVISÃO DE ENTREGA:
                                                </td>
                                                <td colspan="8">
                                                    <asp:TextBox ID="txtEdPrevisao" CssClass="form-contrato" Width="30px" runat="server"></asp:TextBox>
                                                    DIAS ÚTEIS A PARTIR DA CONFIRMAÇÃO DO PEDIDO.
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>VENDEDOR:
                                                </td>
                                                <td colspan="8">
                                                    <asp:TextBox ID="txtEdVendedor" CssClass="form-contrato" runat="server"></asp:TextBox>
                                                 
                                                </td>
                                            </tr>

                                        </table>
                                    </div>
                                    <div class="contract-checklist">
                                        <strong>Checklist da edição</strong>
                                        <div class="contract-checklist-grid">
                                            <label class="contract-check"><asp:CheckBox ID="chkConfereEdicao" runat="server" /> Conferi as alterações antes de gravar</label>
                                        </div>
                                    </div>
                                    <asp:Button ID="btnEditareGravar" runat="server" Text="Editar e Gravar" OnClick="btnEditareGravar_Click" CssClass="btns" />
                                
</ContentTemplate>

                                


                            

</asp:TabPanel>


                        </asp:TabContainer>

                        <div id="ag" style=" position:fixed;  z-index:1000; top:0; left:0; width:100%; height:100%; background-color:rgba(0, 0, 0, 0.75); display:none;">
            <div style="position:fixed; z-index:1001; top:50%; left:50%; width:300px; height:100px; margin-left:-150px; margin-top:-50px; background-color:white; border-radius:5px; text-align:center;">
               <img src="../img/aguarde.gif" style=" border-radius:5px;" /><br />
                <span onclick="aguarde();" style="text-decoration:none; cursor:pointer; color:white; text-decoration:underline;">Cancelar...</span>
                
            </div>
        </div>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
