<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Autorizacao_polimento.aspx.cs" Inherits="veiculos_Autorizacao_polimento" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Autorização de Polimento - Fiat</title>
    <link href="../css/estilo.css" rel="stylesheet" />
    <link href="../css/bali-utility.css?v=20260707-polimento01" rel="stylesheet" />
    <script src="../js/bali-utility-print.js?v=20260707-polimento01"></script>
</head>
<body class="bali-utility-page utility-fiat utility-no-sidebar">
    <script>
        function aguarde() {
            var ag = document.getElementById('ag');
            if (ag) ag.style.visibility = 'visible';
        }
    </script>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo"><font id="logo" style="font-family: Arial black; font-size: 32px; font-style: italic; color: white; margin-left: 13px;"><a href="../../Default.aspx" class="linkHome">BALI</a></font><font style="font-family: Calibri; font-size: 14px; margin-left: 5px; font-style: italic; color: white;">APP</font></td>
                    <td id="table-menu-usuario" class="idUser">Usuário:
                        <asp:Label ID="lblUsuario" CssClass="idUser" runat="server"></asp:Label>
                        C&oacute;digo:
                        <asp:Label ID="lblTipo" CssClass="idUser" runat="server" Style="margin-right: 13px;"></asp:Label><a class="bali-logout-link" href="/logout.aspx?voltar=/veiculos/loginAppcontrato.aspx">Sair</a></td>
                </tr>
            </table>
        </div>
        <div id="linha-branca"></div>
        <div id="menu-topo"></div>
        <div id="menu">
            <button type="button" class="bali-back-button" onclick="if (window.history.length > 1) { window.history.back(); } else { window.location.href='default.aspx'; }">&larr; Voltar</button>
            <div style="text-align: right; margin-right: 15px;">
                <asp:Label ID="lblFrmID" runat="server" Text="Autorização de Polimento"></asp:Label>
            </div>
        </div>

        <div id="TabRecibo">
            <fieldset>
                <legend>Autorização</legend>
                Pedido: <asp:TextBox ID="txtPedido" runat="server"></asp:TextBox>
                Cód. Loja: <asp:TextBox ID="txtLoja" runat="server"></asp:TextBox>
                <asp:Button ID="btnGerar" runat="server" OnClientClick="aguarde();" Text="Gerar" OnClick="btnGerar_Click" CssClass="btns" />
                <br /><br />
                <img src="../img/imprimir.png" style="width: 30px; cursor: pointer;" onclick="javascript: imprimePanel()" />
                <asp:Panel ID="pnlImpressao" runat="server" Width="100%" Height="100%">
                    <div style="width: 18.6cm; min-height: 0; height: 25.7cm; box-sizing: border-box; border: 1px solid #111; font-family: 'Times New Roman', serif; padding: .65cm; color: #111; background: #fff; overflow: hidden;" id="autorizacao-polimento">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px solid #111; padding-bottom: 8px; margin-bottom: 14px;">
                            <div>
                                <div style="font-family: Arial, Helvetica, sans-serif; font-size: 20px; font-weight: 900; letter-spacing: .04em;">GRUPO BALI</div>
                                <div style="font-size: 10px; text-transform: uppercase; margin-top: 2px;"><asp:Label ID="lblEmpresa" runat="server"></asp:Label></div>
                            </div>
                            <div style="font-size: 10.5px; text-align: right;">
                                Pedido: <strong><asp:Label ID="lblPedidoPrint" runat="server"></asp:Label></strong><br />
                                Nota Fiscal: <strong><asp:Label ID="lblNota" runat="server"></asp:Label></strong><br />
                                Proposta: <strong><asp:Label ID="lblProposta" runat="server"></asp:Label></strong>
                            </div>
                        </div>

                        <div style="text-align: center; font-size: 17px; font-weight: bold; text-transform: uppercase; margin: 10px 0 14px;">
                            Autorização Interna para Execução de Polimento Veicular
                        </div>

                        <p style="font-size: 13px; line-height: 1.28; text-align: justify; margin: 7px 0;">
                            Pelo presente documento, fica autorizada a execução do serviço de <strong>polimento veicular</strong> no veículo abaixo identificado, conforme dados extraídos do sistema interno da empresa.
                        </p>

                        <table style="width: 100%; border-collapse: collapse; margin: 12px 0 14px; font-size: 11.5px;">
                            <tr>
                                <td style="border: 1px solid #444; padding: 4px 6px; width: 25%; background: #f2f2f2;"><strong>Cliente</strong></td>
                                <td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblCliente" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Veículo</strong></td>
                                <td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblVeiculo" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Ano/Modelo</strong></td>
                                <td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblAno" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Cor</strong></td>
                                <td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblCor" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Chassi</strong></td>
                                <td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblChassi" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Placa</strong></td>
                                <td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblPlaca" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Unidade</strong></td>
                                <td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblUnidade" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Valor registrado</strong></td>
                                <td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblValor" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Vendedor</strong></td>
                                <td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblVendedor" runat="server"></asp:Label></td>
                            </tr>
                        </table>

                        <p style="font-size: 13px; line-height: 1.28; text-align: justify; margin: 7px 0;">
                            A presente autorização tem por finalidade permitir a realização do serviço necessário à adequada apresentação estética do veículo, visando sua preparação para exposição, comercialização, entrega ou demais finalidades operacionais da área de vendas.
                        </p>
                        <p style="font-size: 13px; line-height: 1.28; text-align: justify; margin: 7px 0;">
                            Declaro, na qualidade de gerente responsável, que tomei ciência da solicitação e <strong>autorizo expressamente</strong> a execução do polimento no veículo acima identificado, ficando registrado que o serviço somente deverá ser realizado após a assinatura desta autorização.
                        </p>
                        <p style="font-size: 13px; line-height: 1.28; text-align: justify; margin: 7px 0;">
                            Esta autorização deverá ser arquivada no sistema interno da empresa para fins de controle, rastreabilidade e comprovação da aprovação gerencial.
                        </p>

                        <div style="margin-top: 14px; font-size: 13px;"><asp:Label ID="lblData" runat="server"></asp:Label></div>

                        <div style="margin-top: 44px; text-align: center; font-size: 12.5px;">
                            <div style="width: 64%; margin: 0 auto; border-top: 1px solid #111; padding-top: 7px;">
                                <strong>GERÊNCIA DE VENDAS</strong><br />
                                Gerente de Vendas<br />
                                <asp:Label ID="lblUnidadeAssinatura" runat="server"></asp:Label> - <asp:Label ID="lblEmpresaAssinatura" runat="server"></asp:Label>
                            </div>
                        </div>
                    </div>
                </asp:Panel>
            </fieldset>
        </div>
    </form>
    <div id="ag" style="position:fixed; z-index:1000; top:0; left:0; width:100%; height:100%; background-color:rgba(0, 0, 0, 0.75); visibility:hidden;">
        <div style="position:fixed; z-index:1001; top:50%; left:50%; width:300px; height:100px; margin-left:-150px; margin-top:-50px; background-color:white; border-radius:5px;">
            <img src="../../img/aguarde.gif" style="border-radius:5px;" />
        </div>
    </div>
</body>
</html>

<script language="javascript" type="text/jscript">
    function imprimePanel() {
        var printContent = document.getElementById("<%=pnlImpressao.ClientID%>");
        var printWindow = window.open('formPadrao.aspx', 'AutorizacaoPolimento', 'left=50000,top=50000,width=0,height=0');
        printWindow.document.write(printContent.innerHTML);
        printWindow.document.close();
        printWindow.focus();
        printWindow.print();
        printWindow.close();
    }
</script>
