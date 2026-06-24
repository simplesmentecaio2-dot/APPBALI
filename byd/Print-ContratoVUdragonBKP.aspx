<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Print-ContratoVUdragon.aspx.cs" Inherits="veiculos_Pint_Contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../css/estilo.css" rel="stylesheet" />
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
        semana = new Array("Domingo", "Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "---ta-feira", "Sábado");
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
            font-size: 12px;
            text-transform: uppercase;
            font-weight: bold;
        }

	.form-contrata {
            border:none;
            width:100%;
            font-family:Arial;
            font-size:6px;
            text-transform: uppercase;
            font-weight:bold;
        }
        .form-aviso {
            border: none;
            width: 100%;
            font-family: Arial;
            font-size: 12px;
            text-transform: uppercase;
            font-weight: bold;
        }

        .auto-style1 {
            width: 734px;
            height: 924px;
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>

        </div>
        <asp:Panel ID="pnlImpressao" runat="server" Visible="true" Style="font-family: Arial; font-size: 9px; margin-top: 34px;" Width="100%" Height="50%">
            <div style="width: 19cm; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;" id="Div1">

                <table border="0" cellspacing="0" style="width: 18.2cm;">
                    <caption>
                        <tr>
                            <td>
                                <img src="../img/contratodragonvu.png" style="width: 18cm;" />
                            </td>
                        </tr>
                    </caption>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">


                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 14px; font-weight: bold; background-color: silver;">CONTRATO DE VENDA DE VEÍCULO USADO
                        </td>
                    </tr>
                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">DADOS DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 1.8cm;">CLIENTE:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtCliente" MaxLength="100" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENDEREÇO:
                        </td>
                        <td colspan="4">
                            <asp:TextBox ID="txtEndereco" MaxLength="100" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
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
                            <asp:TextBox ID="txtBairro" MaxLength="20" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>CIDADE:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCidade" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>UF:
                        </td>
                        <td>

                            <asp:TextBox ID="txtUF" MaxLength="2" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CPF/CNPJ:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCPFCNPJ" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>RG/I.E.
                        </td>
                        <td>
                            <asp:TextBox ID="txtRGIE" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>D.NASC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtNascimento" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                            <asp:CalendarExtender ID="txtNascimento_CalendarExtender" runat="server" Enabled="True" TargetControlID="txtNascimento">
                            </asp:CalendarExtender>
                        </td>
                    </tr>
                    <tr>
                        <td>TEL. RES.:
                        </td>
                        <td style="width: 3.6cm;">
                            <asp:TextBox ID="txtTelREsidencial" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">TEL COM.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtTelCom" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>CELULAR:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCelular" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>E-MAIL.:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtEmail" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="6" style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">DADOS DO VEÍCULO
                        </td>
                    </tr>
                    <tr>
                        <td>MARCA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtMarca" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>MODELO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtModelo" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>COR EXT.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCorExterna" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CHASSI/PLACA:
                        </td>
                        <td colspan="3">
                            <asp:TextBox ID="txtChassiPlaca" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="txtAnoMod" CssClass="form-contrato" Font-Bold="True" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OPCIONAIS:
                        </td>
                        <td colspan="5">
                            <asp:TextBox ID="txtOpcionais" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="9" style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">PREÇO E FORMAS DE PAGAMENTOS
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
                            <asp:TextBox ID="txtFinanceira" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 4.5cm;">VALOR DO VEÍCULO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtValoVeiculo" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td colspan="6">
                            <asp:Label ID="lblEmpTrans" runat="server"></asp:Label>
                            (SERVIÇOS DE DESPACHANTE + TAXAS OPERACIONAIS)
                        </td>
                        <td>
                            <asp:TextBox ID="txtEmplacamento" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENTRADA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtEntrada" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td colspan="2">FORMAS DE PAGAMENTO:
                        </td>
                        <td colspan="5">
                            <asp:TextBox ID="txtFormasPagamento" CssClass="form-contrata" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>AVALIAÇÃO USADO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCarroUsado" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>MOD/MARCA:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtModMarca" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="txtAnoModelo" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>PLACA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlacaVU" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>Valor Usado Avaliação:</td>
                        <td>
                            <asp:TextBox ID="txtVlusadoAvaliacao" CssClass="form-contrato" runat="server" Height="16px"></asp:TextBox></td>
                        <td>Quitação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtvlQuitacao" CssClass="form-contrato" runat="server" Height="16px"></asp:TextBox></td>
                        <td>Saldo da Avaliação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtSaldoAvaliacao" CssClass="form-contrato" runat="server" Height="16px"></asp:TextBox></td>

                    </tr>
                    <tr>
                        <td style="width: 3.5cm;">FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlFinanciamento" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>Nº PARC.:
                        </td>
                        <td style="width: 1cm;">
                            <asp:TextBox ID="txtNrParcelas" CssClass="form-contrato" Width="30px" runat="server"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">VL PARC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlParcelas" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td colspan="2">PLANO FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlano" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>


                    <tr>
                        <td>CORTESIAS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtCortesias" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OBS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtObs" CssClass="form-contrata" Font-Bold="True" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>PREVISÃO DE ENTREGA:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtPrevisao" CssClass="form-contrato" Font-Bold="True" Width="30px" runat="server"></asp:TextBox>
                            DIAS UTEIS A PARTIR DO PAGAMENTO TOTAL DO VEICULO.
                        </td>
                    </tr>
                    <tr>
                        <td colspan="9" style="text-align: center;">Este pedido só terá validade após a assinatura da Gerência.
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">AUTORIZAÇÃO DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td><span style="font-size: 11px;">Prezado cliente, favor ler com atenção os itens abaixo:</span>
                        </td>
                    </tr>
                    <tr>
                        <td><span style="font-size: 12px;">1) Autorizo a Dragon Motors a faturar em meu nome e CPF o (s) veiculo (s) objeto do presente contrato nas condições de preço e forma de pagamento acima descrito.<br />
                            2) Caso o objeto do presente contrato esteja sendo financiado por instituição financeira, as taxas de juros e parcelas poderão sofrer alterações conforme mercado financeiro e/ou política/ normativa da instituição financeira e/ ou do banco central. 
                     <br />
                            3) Estou ciente de que a previsão de entrega do veiculo poderá sofrer alteração sem prévio aviso.<br />

                            <span style="font-size: 11px; font-weight: bold;">4) Em caso de desistência ou cancelamento do contrato, será cobrado multa de 10% (DEZ POR CENTO)  sobre o valor total do contrato. Ass. do Cliente:__________________________________________________________________<br />
                            </span>
                            5) O Cliente compromete-se a entregar em Dação em Pagamento o veículo Placa
                     <asp:Label ID="lblPlaca" runat="server" CssClass="form-contrato" Text=""></asp:Label>
                            , conforme negociação descrita no contrato de compra e venda sob pena de não ser concretizada, nos termos, condições e benefícios negociados na compra.<br />
                            6) Garantia: 3 meses motor/câmbio, desde que sejam mantidas as características originais do veículo e não tenha sofrido danos provocados por uso
 indevido, imperícias, negligências e abuso do veículo, após  ter sido retirado da Concessionária.<br />
		           7) Estou ciente que a contratação do serviço de transferência e despachante oferecido pela Dragon Motors é opcional e que esse serviço poderá ser feito diretamente junto ao Detran/DF.	
                            <br />
			   8) O cliente pode adquirir um contrato com a empresa GESTAUTO BRASIL estendendo assim a garantia do veículo adquirido. <br /><br /><br /><br />
                        
                        </span>
                        </td>
                    </tr>
                </table>
                <br />
            <br />
            <br />
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    
                   
                    <tr>
                        <td >Vendedor:
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
                            <asp:Label ID="Label2" runat="server" CssClass="form-aviso" Text="DIRETOR COMERCIAL"></asp:Label>

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
            <br />
           
           
           


            <div style="width: 19cm; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;" id="Div2">

                <table border="0" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td>
                             <img src="../img/contratodragonvu.png" style="width: 18cm;" />
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 14px; font-weight: bold; background-color: silver;">CONTRATO DE VENDA DE VEÍCULO USADO
                        </td>
                    </tr>
                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">DADOS DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 1.8cm;">CLIENTE:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtCliente2" MaxLength="100" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENDEREÇO:
                        </td>
                        <td colspan="4">
                            <asp:TextBox ID="txtEndereco2" MaxLength="100" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>CEP:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCEP2" MaxLength="10" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>BAIRRO:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtBairro2" MaxLength="20" Font-Bold="True" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>CIDADE:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCidade2" CssClass="form-contrato" Font-Bold="True" runat="server"></asp:TextBox>
                        </td>
                        <td>UF:
                        </td>
                        <td>

                            <asp:TextBox ID="txtUF2" MaxLength="2" CssClass="form-contrato" Font-Bold="True" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CPF/CNPJ:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCPFCNPJ2" CssClass="form-contrato" Font-Bold="True" runat="server"></asp:TextBox>
                        </td>
                        <td>RG/I.E.
                        </td>
                        <td>
                            <asp:TextBox ID="txtRGIE2" CssClass="form-contrato" Font-Bold="True" runat="server"></asp:TextBox>
                        </td>
                        <td>D.NASC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtNascimento2" CssClass="form-contrato" runat="server"></asp:TextBox>
                            <asp:CalendarExtender ID="CalendarExtender1" runat="server" Enabled="True" TargetControlID="txtNascimento">
                            </asp:CalendarExtender>
                        </td>
                    </tr>
                    <tr>
                        <td>TEL. RES.:
                        </td>
                        <td style="width: 3.6cm;">
                            <asp:TextBox ID="txtTelResidencial2" CssClass="form-contrato" Font-Bold="True" runat="server"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">TEL COM.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtTelCom2" CssClass="form-contrato" Font-Bold="True" runat="server"></asp:TextBox>
                        </td>
                        <td>CELULAR:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCelular2" CssClass="form-contrato" Font-Bold="True" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>E-MAIL.:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtEmail2" CssClass="form-contrato" Font-Bold="True" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="6" style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">DADOS DO VEÍCULO
                        </td>
                    </tr>
                    <tr>
                        <td>MARCA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtMarca2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>MODELO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtModelo2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>COR EXT.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCorExterna2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CHASSI/PLACA:
                        </td>
                        <td colspan="3">
                            <asp:TextBox ID="txtChassiPlaca2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="txtAnoModelo2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OPCIONAIS:
                        </td>
                        <td colspan="5">
                            <asp:TextBox ID="txtOpcionais2" CssClass="form-contrato" Font-Bold="True" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="9" style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">PREÇO E FORMAS DE PAGAMENTOS
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
                            <asp:TextBox ID="txtFinanceira2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 4.5cm;">VALOR DO VEÍCULO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtValoVeiculo2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td colspan="6">
                            <asp:Label ID="Label1" runat="server"></asp:Label>
                            (SERVIÇOS DE DESPACHANTE + TAXAS OPERACIONAIS)
                        </td>
                        <td>
                            <asp:TextBox ID="txtEmplacamento2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENTRADA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtEntrada2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td colspan="2">FORMAS DE PAGAMENTO:
                        </td>
                        <td colspan="5">
                            <asp:TextBox ID="txtFormasPagamento2" CssClass="form-contrata" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>AVALIAÇÃO USADO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCarroUsado2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>MOD/MARCA:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtModMarca2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="txtAnoModelo4" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>PLACA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlacaVU2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>Valor Usado Avaliação:</td>
                        <td>
                            <asp:TextBox ID="txtVlAvaliacao2" CssClass="form-contrato" runat="server" Height="16px"></asp:TextBox></td>
                        <td>Quitação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtVlQuitacao2" CssClass="form-contrato" runat="server" Height="16px"></asp:TextBox></td>
                        <td>Saldo da Avaliação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtSaldoAvaliacao2" CssClass="form-contrato" runat="server" Height="16px"></asp:TextBox></td>

                    </tr>
                    <tr>
                        <td style="width: 3.5cm;">FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlFinanciamento2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>Nº PARC.:
                        </td>
                        <td style="width: 1cm;">
                            <asp:TextBox ID="txtNrParcelas2" CssClass="form-contrato" Width="30px" runat="server"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">VL PARC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlParcelas2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td colspan="2">PLANO FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlano2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>

                    <tr>
                        <td>CORTESIAS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtCortesias2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OBS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtObs2" CssClass="form-contrata" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>PREVISÃO DE ENTREGA:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtPrevisao2" CssClass="form-contrato" Width="30px" runat="server"></asp:TextBox>
                            DIAS UTEIS A PARTIR DO PAGAMENTO TOTAL DO VEÍCULO.
                        </td>
                    </tr>
                    <tr>
                        <td colspan="9" style="text-align: center;">Este pedido só terá validade após a assinatura da Gerência.
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">AUTORIZAÇÃO DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td>Prezado cliente, favor ler com atenção os itens abaixo:
                        </td>
                    </tr>
                    <tr>
                        <td><span style="font-size: 11px;">1) Autorizo a Dragon Motors a faturar em meu nome e CPF o (s) veiculo (s) objeto do presente contrato nas condições de preço e forma de pagamento acima descrito.<br />
                            2) Caso o objeto do presente contrato esteja sendo financiado por instituição financeira, as taxas de juros e parcelas poderão sofrer alterações conforme mercado financeiro e/ou política/ normativa da instituição financeira e/ ou do banco central. 
                     <br />
                            3) Estou ciente de que a previsão de entrega do veiculo poderá sofrer alteração sem prévio aviso.<br />

                            <span style="font-size: 12px; font-weight: bold;">4) Em caso de desistência ou cancelamento do contrato, será cobrado multa de 10% (DEZ POR CENTO)  sobre o valor total do contrato. Ass. do Cliente:__________________________________________________________________<br />
                            </span>
                            5) O Cliente compromete-se a entregar em Dação em Pagamento o veículo Placa
                     <asp:Label ID="lblPlaca2" CssClass="form-contrato" runat="server" Text=""></asp:Label>
                            , conforme negociação descrita no contrato de compra e venda sob pena de não ser concretizada, nos termos, condições e benefícios negociados na compra.<br />
                            6)  Garantia: 3 meses motor/câmbio, desde que sejam mantidas as características originais do veículo e não tenha sofrido danos provocados por uso
 indevido, imperícias, negligências e abuso do veículo, após  ter sido retirado da Concessionária.<br />
                            7) Estou ciente que a contratação do serviço de transferência e despachante oferecido pela Dragon Motors é opcional e que esse serviço poderá ser feito diretamente junto ao Detran/DF.	
                            <br />
			8) O cliente pode adquirir um contrato com a empresa GESTAUTO BRASIL estendendo assim a garantia do veículo adquirido. <br /><br /><br /><br />
                        
                        </span>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                   

                    
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
                            <asp:Label ID="Label3" runat="server" CssClass="form-aviso" Text="DIRETOR COMERCIAL"></asp:Label>
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
            <br />
            

            
            <div style="width: 19cm; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;" id="Div3">
                <table border="0" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td>
                             <img src="../img/contratodragonvu.png" style="width: 18cm;" />
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 14px; font-weight: bold; background-color: silver;">CONTRATO DE VENDA DE VEÍCULO USADO
                        </td>
                    </tr>
                    <tr>
                        <td colspan="7" style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">DADOS DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 1.8cm;">CLIENTE:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtCliente3" MaxLength="100" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENDEREÇO:
                        </td>
                        <td colspan="4">
                            <asp:TextBox ID="txtEndereco3" MaxLength="100" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>CEP:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCEP3" MaxLength="10" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>BAIRRO:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtBairro3" MaxLength="20" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>CIDADE:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCidade3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>UF:
                        </td>
                        <td>

                            <asp:TextBox ID="txtUF3" MaxLength="2" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CPF/CNPJ:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCPFCNPJ3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>RG/I.E.
                        </td>
                        <td>
                            <asp:TextBox ID="txtRGIE3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>D.NASC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtNascimento3" CssClass="form-contrato" runat="server"></asp:TextBox>
                            <asp:CalendarExtender ID="CalendarExtender2" runat="server" Enabled="True" TargetControlID="txtNascimento">
                            </asp:CalendarExtender>
                        </td>
                    </tr>
                    <tr>
                        <td>TEL. RES.:
                        </td>
                        <td style="width: 3.6cm;">
                            <asp:TextBox ID="txtTelResidencial3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">TEL COM.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtTelCom3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>CELULAR:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtCelular3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>E-MAIL.:
                        </td>
                        <td colspan="6">
                            <asp:TextBox ID="txtEmail3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="6" style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">DADOS DO VEÍCULO
                        </td>
                    </tr>
                    <tr>
                        <td>MARCA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtMarca3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>MODELO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtModelo3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>COR EXT.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCorExterna3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>CHASSI/PLACA:
                        </td>
                        <td colspan="3">
                            <asp:TextBox ID="txtChassiPlaca3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="txtAnoModelo3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OPCIONAIS:
                        </td>
                        <td colspan="5">
                            <asp:TextBox ID="txtOpcionais3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td colspan="9" style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">PREÇO E FORMAS DE PAGAMENTOS
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
                            <asp:TextBox ID="txtFinanceira3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 4.5cm;">VALOR DO VEÍCULO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtValoVeiculo3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td colspan="6">
                            <asp:Label ID="Label16" runat="server"></asp:Label>
                            (SERVIÇOS DE DESPACHANTE + TAXAS OPERACIONAIS)
                        </td>
                        <td>
                            <asp:TextBox ID="txtEmplacamento3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>ENTRADA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtEntrada3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td colspan="2">FORMAS DE PAGAMENTO:
                        </td>
                        <td colspan="5">
                            <asp:TextBox ID="txtFormasPagamento3" CssClass="form-contrata" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>AVALIAÇÃO USADO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtCarroUsado3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>MOD/MARCA:
                        </td>
                        <td colspan="2">
                            <asp:TextBox ID="txtModMarca3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>ANO/MOD:
                        </td>
                        <td>
                            <asp:TextBox ID="TextBox62" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>PLACA:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlacaVU3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>Valor Usado Avaliação:</td>
                        <td>
                            <asp:TextBox ID="txtVlAvaliacao3" CssClass="form-contrato" runat="server" Height="16px"></asp:TextBox></td>
                        <td>Quitação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtVlQuitacao3" CssClass="form-contrato" runat="server" Height="16px"></asp:TextBox></td>
                        <td>Saldo da Avaliação:</td>
                        <td colspan="2">
                            <asp:TextBox ID="txtSaldoAvaliacao3" CssClass="form-contrato" runat="server" Height="16px"></asp:TextBox></td>

                    </tr>
                    <tr>
                        <td style="width: 3.5cm;">FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlFinanciamento3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td>Nº PARC.:
                        </td>
                        <td style="width: 1cm;">
                            <asp:TextBox ID="txtNrParcelas3" CssClass="form-contrato" Width="30px" runat="server"></asp:TextBox>
                        </td>
                        <td style="width: 1.5cm;">VL PARC.:
                        </td>
                        <td>
                            <asp:TextBox ID="txtVlParcelas3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                        <td colspan="2">PLANO FINANCIAMENTO:
                        </td>
                        <td>
                            <asp:TextBox ID="txtPlano3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>

                    <tr>
                        <td>CORTESIAS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtCortesias3" CssClass="form-contrato" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>OBS:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtObs3" CssClass="form-contrata" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>PREVISÃO DE ENTREGA:
                        </td>
                        <td colspan="8">
                            <asp:TextBox ID="txtPrevisao3" CssClass="form-contrato" Width="30px" runat="server"></asp:TextBox>
                            DIAS UTEIS A PARTIR DO PAGAMENTO TOTAL DO VEICULO.
                        </td>
                    </tr>
                    <tr>
                        <td colspan="9" style="text-align: center;">Este pedido só terá validade após a assinatura da Gerência.
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    <tr>
                        <td style="text-align: center; font-size: 13px; font-weight: bold; background-color: silver;">AUTORIZAÇÃO DO CLIENTE
                        </td>
                    </tr>
                    <tr>
                        <td>Prezado cliente, favor ler com atenção os itens abaixo:
                        </td>
                    </tr>
                    <tr>
                        <td><span style="font-size: 12px;">1) Autorizo a Dragon Motors a faturar em meu nome e CPF o (s) veiculo (s) objeto do presente contrato nas condições de preço e forma de pagamento acima descrito.<br />
                            2) Caso o objeto do presente contrato esteja sendo financiado por instituição financeira, as taxas de juros e parcelas poderão sofrer alterações conforme mercado financeiro e/ou política/ normativa da instituição financeira e/ ou do banco central. 
                     <br />
                            3) Estou ciente de que a previsão de entrega do veiculo poderá sofrer alteração sem prévio aviso.<br />
                            <span style="font-size: 12px; font-weight: bold;">4) Em caso de desistência ou cancelamento do contrato, será cobrado multa de 10% (DEZ POR CENTO)  sobre o valor total do contrato. Ass. do Cliente:__________________________________________________________________<br />
                            </span>
                            5) O Cliente compromete-se a entregar em Dação em Pagamento o veículo Placa
                     <asp:Label ID="lblPlaca3" CssClass="form-contrato" runat="server" Text=""></asp:Label>
                            , conforme negociação descrita no contrato de compra e venda sob pena de não ser concretizada, nos termos, condições e benefícios negociados na compra.<br />
                            6) Garantia: 3 meses motor/câmbio, desde que sejam mantidas as características originais do veículo e não tenha sofrido danos provocados por uso
 indevido, imperícias, negligências e abuso do veículo, após  ter sido retirado da Concessionária.<br />
			    7) Estou ciente que a contratação do serviço de transferência e despachante oferecido pela Dragon Motors é opcional e que esse serviço poderá ser feito diretamente junto ao Detran/DF.	
                            <br />
			   8) O cliente pode adquirir um contrato com a empresa GESTAUTO BRASIL estendendo assim a garantia do veículo adquirido. <br /><br /><br /><br />
                        

                        </span>
                        </td>
                    </tr>
                </table>
                <table border="1" cellspacing="0" style="width: 18.2cm;">
                    
                    
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
                            <asp:Label ID="Label4" runat="server" CssClass="form-aviso" Text="DIRETOR COMERCIAL"></asp:Label>
                        </td>
                    </tr>
                </table>
                <br />
                <br />

            </div>
            </span>
        </asp:Panel>


        <asp:Panel ID="Panel1" runat="server" Width="100%" Height="100%">
            <br />
            <img alt="" class="auto-style1" src="../img/DESPACHANTE.png" />
            
           <br /> <br /> <br /> <br /> <br /> <br /> <br /> <br /> <br /> <br /> <br /> <br />
           <img src="../img/contratodragonvu.png" style="width: 18cm;" />
          <br /><br />
            <span style="font-size: 17px;">
                <div style="width: 19cm; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;  id="Declaracao">
                    Eu:
                <asp:Label ID="lblDeclacaraoNome" runat="server" CssClass="form-aviso" Text="Label"></asp:Label>
                    <br />
                    Portador do CPF:&nbsp; nº:<asp:Label ID="lblDeclaracaoCPF" CssClass="form-aviso" runat="server" Text="Label"></asp:Label>
                    <br />
                    declaro que , quando a aquisição do veículo:
                <asp:Label ID="lblDeclaracaoCarro" runat="server" CssClass="form-aviso" Text="Label"></asp:Label><br />
                    CHASSI/PLACA:<asp:Label ID="lblDeclaracaoChassiPlaca" CssClass="form-aviso" runat="server" Text="Label"></asp:Label>
                    &nbsp;a concessionária Dragon Motors Ltda, atentendo as disposições previstas na Lei nº 13.111/15 me informou previamente:<br />
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
                    <br />


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
            </span>
            </div>
        </asp:Panel>
<br />
	 <asp:Panel ID="guiadocomprador" runat="server" Width="100%" Height="100%" visible="false" >
             <span style="font-size: 17px;">
                <div style="width: 19cm; text-align:center; border: 1px solid black; font-family: 'Times New Roman'; padding: 20px;  id="Div4">
            <img src="../img/contratodragonvu.png" style="width: 18cm;" />
            <br />
                    <span style="font-size: 17px;">
                    <img src="../img/guiadocompradorDRAGON.PNG" style="height: 695px; width: 628px;" />
                    </span>
                    
                    <br />
                    <br />
                    Brasília, <asp:Label ID="lbldeclaracaodata"  CssClass="form-aviso" runat="server" Text="Label"></asp:Label>  <br />
                    Cliente:  <asp:Label ID="lbldeclaracaocliente" CssClass="form-aviso" runat="server" Text="Label"></asp:Label> <br />
                    CPF:  <asp:Label ID="lbldeclaracaocpf2" CssClass="form-aviso" runat="server" Text="Label"></asp:Label> <br /><br />
                    <asp:Label ID="lbltexto" CssClass="form-aviso" runat="server" Text=" ATENÇÃO! O VEÍCULO SOMENTE SERÁ ENTREGUE PARA O PROPRIETÁRIO. NO CASO DE TERCEIROS, DEVE TER EM MÃOS UMA AUTORIZAÇÃO DO PROPRIETÁRIO DO VEÍCULO REGISTRADA EM CARTÓRIO E O DOCUMENTO DE IDENTIFICAÇÃO,
                     O MESMO OCORRE PARA RETIRADA DO CRLV (DOCUMENTO). "></asp:Label>
                   	   <br /><br /><br /><br />
                    
                    
                    _______________________________________		   <br />
                    								
                    <asp:Label ID="lbldeclaracaocliente1" runat="server" CssClass="form-aviso" Text="Label"></asp:Label>			

                 </div>
                 </span>
            </asp:Panel>

    </form>

    <script language="javascript" type="text/jscript">
        function imprimePanel() {
            var printContent = document.getElementById("<%=pnlImpressao.ClientID%>");
            var windowUrl = 'formPadrao.aspx';
            var uniqueName = new Date();
            var windowName = 'Processos Enviados ao Despachante';//'Print' + uniqueName.getTime();
            var printWindow = window.open(windowUrl, windowName, 'left=50000,top=50000,width=0,height=0');

            printWindow.document.write(printContent.innerHTML);
            printWindow.document.close();
            printWindow.focus();
            printWindow.print();
            printWindow.close();
        }

    </script>


</body>
</html>
