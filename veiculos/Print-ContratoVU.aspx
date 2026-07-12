<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Print-ContratoVU.aspx.cs" Inherits="veiculos_Pint_Contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../css/estilo.css" rel="stylesheet" />
    <link href="../css/bali-print-contract.css?v=20260712-despachante01" rel="stylesheet" />
    <script src="../js/bali-print-contract.js?v=20260712-despachante01"></script>
    <script src="../../js/jquery-1.10.2.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.min.js"></script>
    <script src="../../js/js.js"></script>
    <title></title>
    <script>
        function aguarde() {
            document.getElementById('ag').style.visibility = 'visible';
        }
    </script>
    <script language="javascript">
        meses = new Array("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro");
        semana = new Array("Domingo", "Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado");
        function DiaExtenso() {
            hoje = new Date();
            dia = hoje.getDate();
            dias = hoje.getDay();
            mes = hoje.getMonth();
            ano = hoje.getYear();
            if (navigator.appName == "Netscape")
                ano = ano + 1900;
            diaext = semana[dias] + ", " + dia + " de " + meses[mes]
            + " de " + ano;
            return diaext;
        }
    </script>


    <style>
        .form-contrato {
            border: none;
            width: 100%;
            font-family: Arial;
            font-size: 9px;
            text-transform: uppercase;
            font-weight: bold;
        }

         .form-despachante {
            border:none;
            width:100%;
            font-family:Arial;
            font-size:11px;
            text-transform: uppercase;
            font-weight:bold;
        }
	.form-contrata {
            border: none;
            width: 100%;
            font-family: Arial;
            font-size: 6px;
            text-transform: uppercase;
            font-weight: bold;
        }

        .form-aviso {
            border: none;
            width: 100%;
            font-family: Arial;
            font-size: 12px;
            text-transform: uppercase;
            font-weight: bold;
        }

        </style>

</head>
<body class="contrato-vu-print">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>

        </div>
        <asp:Panel ID="pnlImpressao" runat="server" Visible="true" Style="font-family: Arial; font-size: 9px; margin-top: 34px;" Width="100%" Height="50%">
            <div style="width: 19cm; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;" id="Div1">

                <table border="0" cellspacing="0" style="width: 18.2cm;">
                    <caption>
                        <tr>
                            <td>
                                <img src="../img/header-contrato.png" style="width: 18cm;" />
                                <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text="" visible="false"></asp:Label>
                            </td>
                        </tr>
                    </caption>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">


                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 14px; font-weight: bold; background-color: silver;">CONTRATO DE VENDA DE VEÍCULO SEMINOVO
                        </td>
                    </tr>
                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">DADOS DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 1.8cm;">CLIENTE:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtCliente" MaxLength="100" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENDEREÇO:
                        </td>
                        <td colspan="4">
                            <asp:TextBox ID="txtEndereco" MaxLength="100" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>CEP:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCEP" MaxLength="10" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>BAIRRO:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtBairro" MaxLength="20" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>CIDADE:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCidade" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>UF:
                        </td>
                        <td>

                            <asp:TextBox ID="txtUF" MaxLength="2" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CPF/CNPJ:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCPFCNPJ" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>RG/I.E.
                        </td>
                        <td>
                            <asp:TextBox ID="txtRGIE" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>D.NASC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtNascimento" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                            <asp:CalendarExtender ID="txtNascimento_CalendarExtender" runat="server" Enabled="True" TargetControlID="txtNascimento"></asp:CalendarExtender>
                        </td>
                    </tr>
                    <tr>
                        <td>TEL. RES.:
                        </td>
                        <td style="width: 3.6cm;">
                            <asp:TextBox ID="txtTelREsidencial" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">TEL COM.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtTelCom" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>CELULAR:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCelular" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>E-MAIL.:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtEmail" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="6" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">DADOS DO VEÍCULO
                        </td>
                    </tr>
                    <tr>
                        <td>MARCA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtMarca" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>MODELO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtModelo" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>COR EXT.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCorExterna" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CHASSI/PLACA:
                        </td>
                        <td colspan="3">
                            <asp:TextBox ID="txtChassiPlaca" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="txtAnoMod" CssClass="form-contrato" Font-Bold="True" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OPCIONAIS:
                        </td>
                        <td colspan="5">
                            <asp:TextBox ID="txtOpcionais" Font-Bold="True" CssClass="form-contrato contrato-texto-justificado" TextMode="MultiLine" Rows="2" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="9" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">PREÇO E FORMAS DE PAGAMENTOS
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">MODALIDADES DE PAGAMENTOS:
                        </td>
                        <td colspan="2">Á VISTA:
                     <asp:RadioButton ID="rBtnModPagVista" runat="server" />
                        </td>
                        <td colspan="2" style="width: 3.5cm;">FINANCIAMENTO:
                     <asp:RadioButton ID="rBtnModPagFinanciamento" runat="server" />
                        </td>
                        <td>FINANCEIRA:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtFinanceira" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 4.5cm;">VALOR DO VEÍCULO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtValoVeiculo" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td colspan="6">
                            <asp:Label ID="lblEmpTrans" runat="server"></asp:Label>
                            (SERVIÇOS DE DESPACHANTE + TAXAS OPERACIONAIS)
                        </td>
                        <td>
                            <asp:TextBox ID="txtEmplacamento" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENTRADA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtEntrada" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td colspan="3">FORMAS DE PAGAMENTO:
                        </td>
                        <td colspan="4">
                            <asp:TextBox ID="txtFormasPagamento" CssClass="form-contrato contrato-texto-justificado" TextMode="MultiLine" Rows="2" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>AVALIAÇÃO USADO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCarroUsado" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>MOD/MARCA:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtModMarca" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="txtAnoModelo" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>PLACA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlacaVU" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>Valor Usado Avaliação:</td>
                        <td>
                            <asp:TextBox ID="txtVlusadoAvaliacao" CssClass="form-contrato" runat="server" Height="16px" Enabled="False"></asp:TextBox></td>
                        <td>Quitação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtvlQuitacao" CssClass="form-contrato" runat="server" Height="16px" Enabled="False"></asp:TextBox></td>
                        <td>Saldo da Avaliação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtSaldoAvaliacao" CssClass="form-contrato" runat="server" Height="16px" Enabled="False"></asp:TextBox></td>

                    </tr>
                    <tr>
                        <td style="width: 3.5cm;">FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlFinanciamento" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>Nº PARC.:
                        </td>
                        <td style="width: 1cm;">
                            <asp:TextBox ID="txtNrParcelas" CssClass="form-contrato" Width="30px" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">VL PARC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlParcelas" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td colspan="2">PLANO FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlano" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>


                    <tr>
                        <td>CORTESIAS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtCortesias" Font-Bold="True" CssClass="form-contrato contrato-texto-justificado" TextMode="MultiLine" Rows="2" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OBS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtObs" CssClass="form-contrata contrato-texto-justificado" Font-Bold="True" TextMode="MultiLine" Rows="2" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>PREVISÃO DE ENTREGA:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtPrevisao" CssClass="form-contrato" Font-Bold="True" Width="30px" runat="server" Enabled="False"></asp:TextBox>
                            DIAS ÚTEIS A PARTIR DA CONFIRMAÇÃO DO PEDIDO.
                        </td>
                    </tr>
                    <tr>
                        <td colspan="9" style="text-align: center;">Este pedido só terá validade após a assinatura da Gerência.
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">AUTORIZAÇÃO DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td><span style="font-size: 11px;">Prezado cliente, favor ler com atenção os itens abaixo:</span>
                        </td>
                    </tr>
                    <tr>
                        <td><span style="font-size: 11px;">1) Autorizo a BALI AUTOMOVEIS a faturar, em meu nome e CPF/CNPJ, o(s) veículo(s) objeto deste contrato, conforme preço e forma de pagamento acima descritos.<br />
                            2) Se houver financiamento, taxas, prazos e parcelas poderão ser ajustados conforme aprovação, regras e política da instituição financeira e/ou do Banco Central.
                     <br />
                            3) Estou ciente de que a previsão de entrega é estimada e poderá sofrer alteração por motivo operacional, documental ou de faturamento.<br />

                            <span style="font-size: 11px; font-weight: bold;">4) Em caso de desistência ou cancelamento, será devida multa de 5% (CINCO POR CENTO) sobre o valor total do contrato, conforme nota promissória abaixo. Ass. do Cliente:__________________________________________________________________<br />
                            </span>
                            5) O Cliente compromete-se a entregar, em dação em pagamento, o veículo placa
                     <asp:Label ID="lblPlaca" runat="server" CssClass="form-contrato" Text=""></asp:Label>
                            , conforme negociação descrita neste contrato, sob pena de a compra não ser concretizada nos termos, condições e benefícios pactuados.<br />
                            6) Garantia: ano/modelo até 2022/2023: 3 meses para motor/câmbio. Fabricação a partir de 2023: 6 meses para motor/câmbio, desde que preservadas as características originais e não haja danos por uso indevido, imperícia, negligência ou abuso após a retirada da Concessionária.
                        
                        </span>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="2" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">NOTA PROMISSÓRIA
                        </td>

                    </tr>
                    <tr>
                        <td colspan="2"><span style="font-size: 11px;">Vencimento:
                     <asp:Label ID="lblVencimentoPromissoria" runat="server" CssClass="form-contrato" Text=""></asp:Label>
                            Valor:
                     <asp:Label ID="lblValorPromissoria" runat="server" CssClass="form-contrato" Text="Label"></asp:Label><br />
                            No dia
                     <asp:Label ID="lblDiaPromissoria" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                            pagarei por esta única via de Nota Promissória a Bali Automóveis LTDA CNPJ 72.624.521/0001-20 ou à sua ordem, a quantia de
                     <asp:Label ID="lblMulta" runat="server" CssClass="form-contrato" Text=""></asp:Label>
                            em moeda corrente deste País (Em caso de Cancelamento).<br />
                            Local de pagamento: Brasília-DF &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp  Data de Emissão:
                     <asp:Label ID="lblDataEmissao" runat="server" CssClass="form-contrato" Text=""></asp:Label><br />
                            Nome do Emitente:
                     <asp:Label ID="lblNomeEmitente" runat="server" CssClass="form-contrato" Text="Label"></asp:Label><br />
                            CPF/CNPJ:
                     <asp:Label ID="lblCPFEmitente" runat="server" CssClass="form-contrato" Text="Label"></asp:Label><br />
                            Endereço:
                     <asp:Label ID="lblEnderecoEmitente" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Bairro:
                     <asp:Label ID="lblBairroEmitente" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                            <br />
                            Cidade:
                     <asp:Label ID="lblCidadeEmitente" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Brasília-DF,
                     <asp:Label ID="lblDataEmitente" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                        </span>
                        </td>

                    </tr>
                    <tr>
                        <td style="text-align: center;" colspan="2">
                            <br />
                            <br />
                            <br />
                            <br />
                            ____________________________________________________________________________________________________<br />
                            <br />
                            <br />

                            <asp:Label ID="lblAssinatura4" runat="server" CssClass="form-aviso" Text="Label"></asp:Label>
                            <br />
                            <br />
                            <br />
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 50%;">Vendedor:
                     <asp:Label ID="lblVendedor" runat="server" Text=""></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="lblDataVendedor" runat="server" Text=""></asp:Label>

                        </td>
                    </tr>
                    <tr>
                        <td style="width: 50%; text-align: center; padding-bottom: 40px; border-right: none;" valign="middle">

                            <br />
                            <br />
                            <br />
                            <br />
                            <br />

                            __________________________________________________<br />
                            <br />
                            <asp:Label ID="lblAssinatura" runat="server" CssClass="form-aviso" Text="Label"></asp:Label>

                        </td>
                        <td style="width: 50%; text-align: center; padding-bottom: 40px; border-left: none;" valign="middle">

                            <br />
                            <br />
                            <br />
                            <br />
                            <br />

                            __________________________________________________<br />
                            <br />
                            <asp:Label ID="Label2" runat="server" CssClass="form-aviso" Text="GERÊNCIA DE VENDAS"></asp:Label>

                        </td>
                    </tr>
                </table>
            </div>




            <br />
            <br />
            <br />
            <br />


            <div style="width: 19cm; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;" id="Div2">

                <table border="0" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td>
                            <img src="../img/header-contrato.png" style="width: 18cm;" />
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 14px; font-weight: bold; background-color: silver;">CONTRATO DE VENDA DE VEÍCULO SEMINOVO
                        </td>
                    </tr>
                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">DADOS DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 1.8cm;">CLIENTE:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtCliente2" MaxLength="100" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENDEREÇO:
                        </td>
                        <td colspan="4">
                            <asp:TextBox ID="txtEndereco2" MaxLength="100" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>CEP:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCEP2" MaxLength="10" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>BAIRRO:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtBairro2" MaxLength="20" Font-Bold="True" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>CIDADE:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCidade2" CssClass="form-contrato" Font-Bold="True" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>UF:
                        </td>
                        <td>

                            <asp:TextBox ID="txtUF2" MaxLength="2" CssClass="form-contrato" Font-Bold="True" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CPF/CNPJ:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCPFCNPJ2" CssClass="form-contrato" Font-Bold="True" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>RG/I.E.
                        </td>
                        <td>
                            <asp:TextBox ID="txtRGIE2" CssClass="form-contrato" Font-Bold="True" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>D.NASC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtNascimento2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                            <asp:CalendarExtender ID="CalendarExtender1" runat="server" Enabled="True" TargetControlID="txtNascimento"></asp:CalendarExtender>
                        </td>
                    </tr>
                    <tr>
                        <td>TEL. RES.:
                        </td>
                        <td style="width: 3.6cm;">
                            <asp:TextBox ID="txtTelResidencial2" CssClass="form-contrato" Font-Bold="True" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">TEL COM.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtTelCom2" CssClass="form-contrato" Font-Bold="True" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>CELULAR:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCelular2" CssClass="form-contrato" Font-Bold="True" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>E-MAIL.:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtEmail2" CssClass="form-contrato" Font-Bold="True" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="6" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">DADOS DO VEÍCULO
                        </td>
                    </tr>
                    <tr>
                        <td>MARCA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtMarca2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>MODELO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtModelo2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>COR EXT.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCorExterna2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CHASSI/PLACA:
                        </td>
                        <td colspan="3">
                            <asp:TextBox ID="txtChassiPlaca2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="txtAnoModelo2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OPCIONAIS:
                        </td>
                        <td colspan="5">
                            <asp:TextBox ID="txtOpcionais2" CssClass="form-contrato contrato-texto-justificado" Font-Bold="True" TextMode="MultiLine" Rows="2" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="9" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">PREÇO E FORMAS DE PAGAMENTOS
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">MODALIDADES DE PAGAMENTOS:
                        </td>
                        <td colspan="2">Á VISTA:
                     <asp:RadioButton ID="rBtnModPagVista2" runat="server" />
                        </td>
                        <td colspan="2" style="width: 3.5cm;">FINANCIAMENTO:
                     <asp:RadioButton ID="rBtnModPagFinanciamento2" runat="server" />
                        </td>
                        <td>FINANCEIRA:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtFinanceira2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 4.5cm;">VALOR DO VEÍCULO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtValoVeiculo2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td colspan="6">
                            <asp:Label ID="Label1" runat="server"></asp:Label>
                            (SERVIÇOS DE DESPACHANTE + TAXAS OPERACIONAIS)
                        </td>
                        <td>
                            <asp:TextBox ID="txtEmplacamento2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENTRADA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtEntrada2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td colspan="3">FORMAS DE PAGAMENTO:
                        </td>
                        <td colspan="4">
                            <asp:TextBox ID="txtFormasPagamento2" CssClass="form-contrato contrato-texto-justificado" TextMode="MultiLine" Rows="2" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>AVALIAÇÃO USADO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCarroUsado2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>MOD/MARCA:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtModMarca2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="txtAnoModelo4" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>PLACA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlacaVU2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>Valor Usado Avaliação:</td>
                        <td>
                            <asp:TextBox ID="txtVlAvaliacao2" CssClass="form-contrato" runat="server" Height="16px" Enabled="False"></asp:TextBox></td>
                        <td>Quitação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtVlQuitacao2" CssClass="form-contrato" runat="server" Height="16px" Enabled="False"></asp:TextBox></td>
                        <td>Saldo da Avaliação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtSaldoAvaliacao2" CssClass="form-contrato" runat="server" Height="16px" Enabled="False"></asp:TextBox></td>

                    </tr>
                    <tr>
                        <td style="width: 3.5cm;">FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlFinanciamento2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>Nº PARC.:
                        </td>
                        <td style="width: 1cm;">
                            <asp:TextBox ID="txtNrParcelas2" CssClass="form-contrato" Width="30px" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">VL PARC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlParcelas2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td colspan="2">PLANO FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlano2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>

                    <tr>
                        <td>CORTESIAS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtCortesias2" CssClass="form-contrato contrato-texto-justificado" TextMode="MultiLine" Rows="2" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OBS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtObs2" CssClass="form-contrata contrato-texto-justificado" TextMode="MultiLine" Rows="2" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>PREVISÃO DE ENTREGA:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtPrevisao2" CssClass="form-contrato" Width="30px" runat="server"></asp:TextBox>
                            DIAS ÚTEIS A PARTIR DA CONFIRMAÇÃO DO PEDIDO.
                        </td>
                    </tr>
                    <tr>
                        <td colspan="9" style="text-align: center;">Este pedido só terá validade após a assinatura da Gerência.
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td style="text-align: center; font-size: 12px; font-weight: bold; background-color: silver;">AUTORIZAÇÃO DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td>Prezado cliente, favor ler com atenção os itens abaixo:
                        </td>
                    </tr>
                    <tr>
                        <td><span style="font-size: 11px;">1) Autorizo a BALI AUTOMOVEIS a faturar, em meu nome e CPF/CNPJ, o(s) veículo(s) objeto deste contrato, conforme preço e forma de pagamento acima descritos.<br />
                            2) Se houver financiamento, taxas, prazos e parcelas poderão ser ajustados conforme aprovação, regras e política da instituição financeira e/ou do Banco Central.
                     <br />
                            3) Estou ciente de que a previsão de entrega é estimada e poderá sofrer alteração por motivo operacional, documental ou de faturamento.<br />

                            <span style="font-size: 11px; font-weight: bold;">4) Em caso de desistência ou cancelamento, será devida multa de 5% (CINCO POR CENTO) sobre o valor total do contrato, conforme nota promissória abaixo. Ass. do Cliente:__________________________________________________________________<br />
                            </span>
                            5) O Cliente compromete-se a entregar, em dação em pagamento, o veículo placa
                     <asp:Label ID="lblPlaca2" CssClass="form-contrato" runat="server" Text=""></asp:Label>
                            , conforme negociação descrita neste contrato, sob pena de a compra não ser concretizada nos termos, condições e benefícios pactuados.<br />
                            6) Garantia: ano/modelo até 2022/2023: 3 meses para motor/câmbio. Fabricação a partir de 2023: 6 meses para motor/câmbio, desde que preservadas as características originais e não haja danos por uso indevido, imperícia, negligência ou abuso após a retirada da Concessionária.
                        </span>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="2" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">NOTA PROMISSÓRIA
                        </td>

                    </tr>
                    <tr>
                        <td colspan="2"><span style="font-size: 11px;">Vencimento:
                     <asp:Label ID="lblVencimentoPromissoria2" runat="server" CssClass="form-contrato" Text=""></asp:Label>
                            Valor:
                     <asp:Label ID="lblValorPromissoria2" runat="server" CssClass="form-contrato" Text="Label"></asp:Label><br />
                            No dia
                     <asp:Label ID="lblDiaPromissoria2" runat="server" CssClass="form-contrato" Text="label"></asp:Label>
                            pagarei por esta única via de Nota Promissória a Bali Automóveis LTDA CNPJ 72.624.521/0001-20 ou à sua ordem, a quantia de
                     <asp:Label ID="lblMulta2" runat="server" CssClass="form-contrato" Text=""></asp:Label>
                            em moeda corrente deste País (Em caso de Cancelamento).<br />
                            Local de pagamento: Brasília-DF &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp  Data de Emissão:
                     <asp:Label ID="lblDataEmissao2" runat="server" CssClass="form-contrato" Text=""></asp:Label><br />
                            Nome do Emitente:
                     <asp:Label ID="lblNomeEmitente2" runat="server" CssClass="form-contrato" Text="Label"></asp:Label><br />
                            CPF/CNPJ:
                     <asp:Label ID="lblCPFEmitente2" runat="server" CssClass="form-contrato" Text="Label"></asp:Label><br />
                            Endereço:
                     <asp:Label ID="lblEnderecoEmitente2" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Bairro:
                     <asp:Label ID="lblBairroEmitente2" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                            <br />
                            Cidade:
                     <asp:Label ID="lblCidadeEmitente2" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Brasília-DF,
                     <asp:Label ID="lblDataEmitente2" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                        </span>
                        </td>

                    </tr>
                    <tr>
                        <td style="text-align: center;" colspan="2">
                            <br />
                            <br />
                            <br />
                            <br />
                            ____________________________________________________________________________________________________<br />
                            <br />
                            <asp:Label ID="lblAssinatura5" runat="server" CssClass="form-aviso" Text="Label"></asp:Label>
                            <br />
                            <br />
                            <br />
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 50%;">Vendedor:
                     <asp:Label ID="lblVendedor2" runat="server" Text=""></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="lblDataVendedor2" runat="server" Text=""></asp:Label>

                        </td>

                    </tr>
                    <tr>
                        <td style="width: 50%; text-align: center; padding-bottom: 40px; border-right: none;" valign="middle">

                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />

                            __________________________________________________<br />
                            <br />
                            <asp:Label ID="lblAssinatura2" runat="server" CssClass="form-aviso" Text="Label"></asp:Label>

                        </td>
                        <td style="width: 50%; text-align: center; padding-bottom: 40px; border-left: none;" valign="middle">

                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />

                            __________________________________________________<br />
                            <br />
                            <asp:Label ID="Label3" runat="server" CssClass="form-aviso" Text="GERÊNCIA DE VENDAS"></asp:Label>
                        </td>
                    </tr>
                </table>
            </div>

            <br />
            <br />

            <br />

            <br />
            <br />
            <br />
            <br />
            <div style="width: 19cm; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;" id="Div3">
                <table border="0" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td>
                            <img src="../img/header-contrato.png" style="width: 18cm;" />
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 14px; font-weight: bold; background-color: silver;">CONTRATO DE VENDA DE VEÍCULO SEMINOVO
                        </td>
                    </tr>
                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">DADOS DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 1.8cm;">CLIENTE:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtCliente3" MaxLength="100" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENDEREÇO:
                        </td>
                        <td colspan="4">
                            <asp:TextBox ID="txtEndereco3" MaxLength="100" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>CEP:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCEP3" MaxLength="10" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>BAIRRO:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtBairro3" MaxLength="20" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>CIDADE:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCidade3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>UF:
                        </td>
                        <td>

                            <asp:TextBox ID="txtUF3" MaxLength="2" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CPF/CNPJ:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCPFCNPJ3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>RG/I.E.
                        </td>
                        <td>
                            <asp:TextBox ID="txtRGIE3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>D.NASC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtNascimento3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                            <asp:CalendarExtender ID="CalendarExtender2" runat="server" Enabled="True" TargetControlID="txtNascimento"></asp:CalendarExtender>
                        </td>
                    </tr>
                    <tr>
                        <td>TEL. RES.:
                        </td>
                        <td style="width: 3.6cm;">
                            <asp:TextBox ID="txtTelResidencial3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">TEL COM.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtTelCom3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>CELULAR:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCelular3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>E-MAIL.:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtEmail3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="6" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">DADOS DO VEÍCULO
                        </td>
                    </tr>
                    <tr>
                        <td>MARCA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtMarca3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>MODELO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtModelo3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>COR EXT.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCorExterna3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CHASSI/PLACA:
                        </td>
                        <td colspan="3">
                            <asp:TextBox ID="txtChassiPlaca3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="txtAnoModelo3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OPCIONAIS:
                        </td>
                        <td colspan="5">
                            <asp:TextBox ID="txtOpcionais3" CssClass="form-contrato contrato-texto-justificado" TextMode="MultiLine" Rows="2" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="9" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">PREÇO E FORMAS DE PAGAMENTOS
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">MODALIDADES DE PAGAMENTOS:
                        </td>
                        <td colspan="2">Á VISTA:
                     <asp:RadioButton ID="rBtnModPagVista3" GroupName="modpag" runat="server" />
                        </td>
                        <td colspan="2" style="width: 3.5cm;">FINANCIAMENTO:
                     <asp:RadioButton ID="rBtnModPagFinanciamento3" GroupName="modpag" runat="server" />
                        </td>
                        <td>FINANCEIRA:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtFinanceira3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 4.5cm;">VALOR DO VEÍCULO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtValoVeiculo3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td colspan="6">
                            <asp:Label ID="Label16" runat="server"></asp:Label>
                            (SERVIÇOS DE DESPACHANTE + TAXAS OPERACIONAIS)
                        </td>
                        <td>
                            <asp:TextBox ID="txtEmplacamento3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENTRADA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtEntrada3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td colspan="3">FORMAS DE PAGAMENTO:
                        </td>
                        <td colspan="4">
                            <asp:TextBox ID="txtFormasPagamento3" CssClass="form-contrato contrato-texto-justificado" TextMode="MultiLine" Rows="2" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>AVALIAÇÃO USADO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCarroUsado3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>MOD/MARCA:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtModMarca3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="TextBox62" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>PLACA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlacaVU3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>Valor Usado Avaliação:</td>
                        <td>
                            <asp:TextBox ID="txtVlAvaliacao3" CssClass="form-contrato" runat="server" Height="16px" Enabled="False"></asp:TextBox></td>
                        <td>Quitação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtVlQuitacao3" CssClass="form-contrato" runat="server" Height="16px" Enabled="False"></asp:TextBox></td>
                        <td>Saldo da Avaliação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtSaldoAvaliacao3" CssClass="form-contrato" runat="server" Height="16px" Enabled="False"></asp:TextBox></td>

                    </tr>
                    <tr>
                        <td style="width: 3.5cm;">FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlFinanciamento3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td>Nº PARC.:
                        </td>
                        <td style="width: 1cm;">
                            <asp:TextBox ID="txtNrParcelas3" CssClass="form-contrato" Width="30px" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">VL PARC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlParcelas3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                        <td colspan="2">PLANO FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlano3" CssClass="form-contrato" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>

                    <tr>
                        <td>CORTESIAS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtCortesias3" CssClass="form-contrato contrato-texto-justificado" TextMode="MultiLine" Rows="2" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OBS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtObs3" CssClass="form-contrata contrato-texto-justificado" TextMode="MultiLine" Rows="2" runat="server" Enabled="False"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>PREVISÃO DE ENTREGA:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtPrevisao3" CssClass="form-contrato" Width="30px" runat="server" Enabled="False"></asp:TextBox>
                            DIAS ÚTEIS A PARTIR DA CONFIRMAÇÃO DO PEDIDO.
                        </td>
                    </tr>
                    <tr>
                        <td colspan="9" style="text-align: center;">Este pedido só terá validade após a assinatura da Gerência.
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td style="text-align: center; font-size: 12px; font-weight: bold; background-color: silver;">AUTORIZAÇÃO DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td>Prezado cliente, favor ler com atenção os itens abaixo:
                        </td>
                    </tr>
                    <tr>
                        <td><span style="font-size: 11px;">1) Autorizo a BALI AUTOMOVEIS a faturar, em meu nome e CPF/CNPJ, o(s) veículo(s) objeto deste contrato, conforme preço e forma de pagamento acima descritos.<br />
                            2) Se houver financiamento, taxas, prazos e parcelas poderão ser ajustados conforme aprovação, regras e política da instituição financeira e/ou do Banco Central.
                     <br />
                            3) Estou ciente de que a previsão de entrega é estimada e poderá sofrer alteração por motivo operacional, documental ou de faturamento.<br />
                            <span style="font-size: 11px; font-weight: bold;">4) Em caso de desistência ou cancelamento, será devida multa de 5% (CINCO POR CENTO) sobre o valor total do contrato, conforme nota promissória abaixo. Ass. do Cliente:__________________________________________________________________<br />
                            </span>
                            5) O Cliente compromete-se a entregar, em dação em pagamento, o veículo placa
                     <asp:Label ID="lblPlaca3" CssClass="form-contrato" runat="server" Text=""></asp:Label>
                            , conforme negociação descrita neste contrato, sob pena de a compra não ser concretizada nos termos, condições e benefícios pactuados.<br />
                            6) Garantia: ano/modelo até 2022/2023: 3 meses para motor/câmbio. Fabricação a partir de 2023: 6 meses para motor/câmbio, desde que preservadas as características originais e não haja danos por uso indevido, imperícia, negligência ou abuso após a retirada da Concessionária.
                            <br />

                        </span>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="2" style="text-align: center; font-size: 10px; font-weight: bold; background-color: silver;">NOTA PROMISSÓRIA
                        </td>

                    </tr>
                    <tr>
                        <td colspan="2"><span style="font-size: 11px;">Vencimento:
                     <asp:Label ID="lblVencimentoPromissoria3" runat="server" CssClass="form-contrato" Text=""></asp:Label>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Valor:
                     <asp:Label ID="lblValorPromissoria3" runat="server" CssClass="form-contrato" Text="Label"></asp:Label><br />
                            No dia
                     <asp:Label ID="lblDiaPromissoria3" runat="server" Text="Label"></asp:Label>
                            pagarei por esta única via de Nota Promissória a Bali Automóveis LTDA CNPJ 72.624.521/0001-20 ou à sua ordem, a quantia de
                     <asp:Label ID="lblMulta3" runat="server" CssClass="form-contrato" Text=""></asp:Label>
                            em moeda corrente deste País (Em caso de Cancelamento).<br />
                            Local de pagamento: Brasília-DF &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp  Data de Emissão:
                     <asp:Label ID="lblDataEmissao3" runat="server" CssClass="form-contrato" Text=""></asp:Label><br />
                            Nome do Emitente:
                     <asp:Label ID="lblNomeEmitente3" runat="server" CssClass="form-contrato" Text="Label"></asp:Label><br />
                            CPF/CNPJ:
                     <asp:Label ID="lblCPFEmitente3" runat="server" CssClass="form-contrato" Text="Label"></asp:Label><br />
                            Endereço:
                     <asp:Label ID="lblEnderecoEmitente3" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Bairro:
                     <asp:Label ID="lblBairroEmitente3" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                            <br />
                            Cidade:
                     <asp:Label ID="lblCidadeEmitente3" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp Brasília-DF,
                     <asp:Label ID="lblDataEmitente3" runat="server" CssClass="form-contrato" Text="Label"></asp:Label>
                        </span>
                        </td>

                    </tr>
                    <tr>
                        <td style="text-align: center;" colspan="2">
                            <br />
                            <br />
                            <br />
                            <br />
                            ____________________________________________________________________________________________________<br />
                            <br />
                            <asp:Label ID="lblAssinatura6" runat="server" CssClass="form-aviso" Text="Label"></asp:Label>
                            <br />
                            <br />
                            <br />
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 50%;">Vendedor:
                     <asp:Label ID="lblVendedor3" runat="server" Text=""></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="lblDataVendedor3" Style="text-align: center;" runat="server" Text=""></asp:Label>

                        </td>
                    </tr>
                    <tr>
                        <td style="width: 50%; text-align: center; padding-bottom: 40px; border-right: none;" valign="middle">
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            __________________________________________________<br />
                            <br />
                            <asp:Label ID="lblAssinatura3" runat="server" CssClass="form-aviso" Text="Label"></asp:Label>

                        </td>
                        <td style="width: 50%; text-align: center; padding-bottom: 40px; border-left: none;" valign="middle">
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            __________________________________________________<br />
                            <br />
                            <asp:Label ID="Label4" runat="server" CssClass="form-aviso" Text="GERÊNCIA DE VENDAS"></asp:Label>
                        </td>
                    </tr>
                </table>
                <br />
                <br />
                <br />

            </div>
            </span>
        </asp:Panel>
        <br />

        <asp:Panel ID="Panel1" runat="server" Width="100%" Height="100%">
            <br />
            <div style="width: 19cm; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;" id="Div5">
            <img src="../img/DESPACHANTECABECALHO.png" style="height: 181px; width: 675px" />
            <table border="1" cellspacing="0" style="width: 18.2cm;">
                <tr>
                    <td colspan="5"align="center">SOLICITAÇÃO DO SERVIÇO</td>                    
                </tr>
                <tr>
                    <td colspan="2" class="auto-style4"> NOME: 
                      <asp:Label ID="txtdespachanteNOME" runat="server" Text="Label" CssClass="form-despachante" ></asp:Label>
                    </td>
                     
                     <td rowspan="2"> PROCURADOR:</td>
                     <td> SIM( )</td>
                    
                </tr>
                 <tr>
                    <td colspan="2" class="auto-style4"></td>
                                          
                     <td>NÃO( )</td>
                     
                </tr>
                <tr>
                    <td colspan="2" class="auto-style4">RG:<asp:Label ID="txtdespachanteRG" runat="server" Text="Label" CssClass="form-despachante" ></asp:Label>
                    </td>
                    <td colspan="3">CPF/CNPJ:<asp:Label ID="txtdespachanteCPF" runat="server" Text="Label" CssClass="form-despachante" ></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td colspan="5" class="auto-style4">ÓRGÃO EXPEDIDOR: </td>
                    
                </tr>
                <tr>
                    <td colspan="5">ENDEREÇO:<asp:Label ID="txtdespachanteENDERECO" runat="server" CssClass="form-despachante"  Text="Label"></asp:Label>
                    </td>                    
                </tr>
                <tr>
                    <td colspan="5">CEP:<asp:Label ID="txtdespachanteCEP" runat="server" Text="Label" CssClass="form-despachante" ></asp:Label>
                    </td>                    
                </tr>
                <tr>
                    <td colspan="2" class="auto-style4">E-MAIL:<asp:Label ID="txtdespachanteEMAIL" runat="server" CssClass="form-despachante"  Text="Label"></asp:Label>
                    </td>
                    <td colspan="3">FONE:<asp:Label ID="txtdespachanteFONE" runat="server" Text="Label" CssClass="form-despachante" ></asp:Label>
                    </td>
                </tr>
            </table>
            
            <table border="1" cellspacing="0" style="width: 18.2cm;">
                <tr>
                    <td colspan="5" align="center">DADOS DO VEÍCULO</td>                    
                </tr>
                <tr>
                    <td >CHASSI/PLACA:
                        <asp:Label ID="txtdespachanteCHASSI" runat="server" Text="Label" CssClass="form-despachante"></asp:Label>
                    </td>
                    
                    
                                      
                </tr>
                <tr>
                    <td >MARCA/MODELO:
                        <asp:Label ID="txtdespachanteMODELO" runat="server" Text="Label" CssClass="form-despachante"></asp:Label>
                    </td>
                    <td >ANO FAB:<asp:Label ID="txtdespachanteANOMODELO" runat="server" Text="Label" CssClass="form-despachante"></asp:Label></td>
                    
                </tr>
                <tr>
                    <td colspan="5">RENAVAM:<asp:TextBox runat="server" Width="198px"></asp:TextBox>&nbsp;PLACA:
                        <asp:TextBox ID="TextBox63" runat="server" Width="232px"></asp:TextBox>
                    </td>
                </tr>
                    </table>

            <img src="../img/DESPACHANTEFINALUSADO.png" style="height: 545px; width: 704px;"  />
                </div>
            
           <%-- <img src="../img/header-contrato.png" style="width: 20cm;" />--%>
          
          <%--  <span style="font-size: 17px;">
                <div style="width: 19cm; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;" id="Declaracao">
                    Eu:
                <asp:Label ID="lblDeclacaraoNome" runat="server" CssClass="form-aviso" Text="Label"></asp:Label>
                    <br />
                    Portador do CPF:&nbsp; nº:<asp:Label ID="lblDeclaracaoCPF" CssClass="form-aviso" runat="server" Text="Label"></asp:Label>
                    <br />
                    declaro que , quando a aquisição do veículo:
                <asp:Label ID="lblDeclaracaoCarro" runat="server" CssClass="form-aviso" Text="Label"></asp:Label><br />
                    CHASSI/PLACA:<asp:Label ID="lblDeclaracaoChassiPlaca" CssClass="form-aviso" runat="server" Text="Label"></asp:Label>
                    &nbsp;a concessionária Bali Automóveis Ltda, atentendo as disposições previstas na Lei nº 13.111/15 me informou previamente:<br />
                    <br />

                    I- O valor dos tributos incidentes sobre a comercialização do veículo;<br />
                    II- A situação de regularidade do veículo quanto a:
                    <br />
                    a) Furto;<br />
                    b) Multas e Taxas anuais legalmente devidas;<br />
                    c) Débitos de impostos;<br />
                    d) Alienação fiduciária; ou<br />
                    e) Quaisquer outros registros que limitem ou impeçam a circulação do veículo.<br />
                    <br />

                    De igual forma fui regularmente informado quanto a situação de regularidade do veículo juntos as autoridade, de trânsito e fazendária desta unidade da Federação onde o veículo foi registrado e comercialiaziado, relata a :<br />
                    I-&nbsp;&nbsp;&nbsp;&nbsp; Furto;<br />
                    II-&nbsp;&nbsp;&nbsp; Multas e Taxas anuais legalmente devidas;<br />
                    III-&nbsp;&nbsp; Débitos quanto ao pagamento de impostos;<br />
                    IV - Alienação Fiduciária; ou<br />
                    V-&nbsp;&nbsp; Quaisquer outros registros que limitem ou impeçam a circulação do veículo.<br />
                    <br />
                    <br />CLÁUSULA DE CONSENTIMENTO<br /><br />

		Autorizo a disponibilização de meus dados pessoais, mediante consentimento para armazenamento em banco de dados seguro no tocante ao dever de sigilo aplicados à coleta, divulgação e tratamento dessas informações, ciente e em concordância com a Política de Privacidade da LGPD.

<br /><br /><br />


                    Por ser expressão da verdade firmo o presente documento.<br />
                    <br />
                    <br />


                    Brasília - DF
                    <br />
                    <br />
                    <br />




                    ______________________________________________________
                <br />
                    <br />

                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                
                <asp:Label ID="lblCliente4" runat="server" CssClass="form-aviso" Text="Label"></asp:Label>

                    <br />
            </span>--%>
            </div>
        </asp:Panel>
<asp:Panel ID="guiadocomprador" runat="server" Width="100%" Height="100%" visible="false" >
             <span style="font-size: 17px;">
                <div style="width: 19cm; text-align:center; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;" id="Div4">
            <img src="../img/header-contrato.png" style="width: 18cm;" />
            <br />
                    <span style="font-size: 17px;">
                    <img src="../img/GUIDADOCOMPRADOR.PNG" style="height: 695px; width: 628px;" />
                    </span>
                    
                    <br />
                    <div style="width: 17.2cm; margin: 8px auto 6px; text-align: left;">
                        <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                            <tr>
                                <td style="width: 38%; border: 1px solid #666; padding: 4px 6px;"><strong>Data:</strong> Brasília, <asp:Label ID="lbldeclaracaodata" CssClass="form-aviso" runat="server" Text="Label"></asp:Label></td>
                                <td style="border: 1px solid #666; padding: 4px 6px;"><strong>Cliente:</strong> <asp:Label ID="lbldeclaracaocliente" CssClass="form-aviso" runat="server" Text="Label"></asp:Label></td>
                            </tr>
                            <tr>
                                <td colspan="2" style="border: 1px solid #666; padding: 4px 6px;"><strong>CPF/CNPJ:</strong> <asp:Label ID="lbldeclaracaocpf2" CssClass="form-aviso" runat="server" Text="Label"></asp:Label></td>
                            </tr>
                        </table>
                    </div>
                    <div style="width: 17.2cm; margin: 7px auto 0; padding: 7px 9px; border: 1px solid #777; text-align: justify; font-size: 12.5px; line-height: 1.22;">
                        <strong>ATENÇÃO:</strong> a entrega ou retirada do veículo e/ou do CRLV será realizada somente ao proprietário. No caso de retirada por terceiro, é obrigatória autorização do proprietário com firma reconhecida em cartório, acompanhada de documento oficial de identificação.
                    </div>
                    <div style="margin-top: 22px; text-align: center;">
                        <div style="width: 10.5cm; margin: 0 auto; border-top: 1px solid #000;"></div>
                        <div style="margin-top: 5px; font-weight: bold;">
                            <asp:Label ID="lbldeclaracaocliente1" runat="server" CssClass="form-aviso" Text="Label"></asp:Label>
                        </div>
                        <div style="font-size: 11px;">Cliente/Proprietário</div>
                    </div>

                 </div>
                 </span>
            </asp:Panel>


    </form>

</body>
</html>
