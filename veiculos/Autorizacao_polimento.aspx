<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Autorizacao_polimento.aspx.cs" Inherits="veiculos_Autorizacao_polimento" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Autorização de Polimento - Fiat</title>
    <link href="../css/estilo.css" rel="stylesheet" />
    <link href="../css/bali-utility.css?v=20260707-polimento-bi01" rel="stylesheet" />
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
            <asp:HiddenField ID="hdnPolimentoTab" runat="server" ClientIDMode="Static" Value="autorizacao" />
            <div class="polimento-tabs" role="tablist" aria-label="Navegação da autorização de polimento">
                <button type="button" class="polimento-tab is-active" data-polimento-tab="autorizacao">Autorização</button>
                <button type="button" class="polimento-tab" data-polimento-tab="dados">Dados</button>
            </div>

            <div class="polimento-tab-panel is-active" data-polimento-panel="autorizacao">
                <fieldset>
                <legend>Autorização</legend>
                Pedido: <asp:TextBox ID="txtPedido" runat="server"></asp:TextBox>
                Cód. Loja: <asp:TextBox ID="txtLoja" runat="server"></asp:TextBox>
                Tipo: <asp:DropDownList ID="ddlTipoPolimento" runat="server">
                    <asp:ListItem Text="Polimento completo do veículo" Value="Polimento completo do veículo"></asp:ListItem>
                    <asp:ListItem Text="Polimento do Black Piano" Value="Polimento do Black Piano"></asp:ListItem>
                </asp:DropDownList>
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
                                <td style="border: 1px solid #444; padding: 4px 6px; font-size: 12.5px; font-weight: bold;"><asp:Label ID="lblCor" runat="server"></asp:Label></td>
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
                        <p style="text-align: center; margin: 4px 0 3px;">
                            <strong style="display: block; font-size: 24px; line-height: 1.05; text-transform: uppercase; letter-spacing: 0;">
                                Serviço autorizado: <asp:Label ID="lblTipoPolimento" runat="server" Text="Polimento completo do veículo"></asp:Label>.
                            </strong>
                        </p>

                        <div style="margin-top: 14px; font-size: 13px;"><asp:Label ID="lblData" runat="server"></asp:Label></div>

                        <div style="margin-top: 30px; text-align: center; font-size: 12.5px;">
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

            <div class="polimento-tab-panel" data-polimento-panel="dados">
                <div class="polimento-bi-shell">
                    <fieldset>
                        <legend>Dados da autorização</legend>
                        Data inicial: <asp:TextBox ID="txtBIDataInicial" runat="server"></asp:TextBox>
                        Data final: <asp:TextBox ID="txtBIDataFinal" runat="server"></asp:TextBox>
                        <asp:Button ID="btnAtualizarBI" runat="server" Text="Atualizar dados" CssClass="btns" OnClick="btnAtualizarBI_Click" OnClientClick="document.getElementById('hdnPolimentoTab').value='dados';" />
                    </fieldset>

                    <div class="polimento-bi-grid">
                        <article>
                            <small>Autorizações</small>
                            <strong><asp:Label ID="lblBITotal" runat="server" Text="0"></asp:Label></strong>
                        </article>
                        <article>
                            <small>Cores diferentes</small>
                            <strong><asp:Label ID="lblBICores" runat="server" Text="0"></asp:Label></strong>
                        </article>
                        <article>
                            <small>Cor mais frequente</small>
                            <strong><asp:Label ID="lblBITopCor" runat="server" Text="-"></asp:Label></strong>
                        </article>
                    </div>

                    <div class="polimento-bi-section">
                        <h3>Resumo por mês e cor</h3>
                        <asp:GridView ID="gvPolimentoResumo" runat="server" AutoGenerateColumns="False" CssClass="bali-data-table" GridLines="None" EmptyDataText="Nenhuma autorização encontrada neste período.">
                            <Columns>
                                <asp:BoundField DataField="Mes" HeaderText="Mês" />
                                <asp:BoundField DataField="TipoPolimento" HeaderText="Tipo" />
                                <asp:BoundField DataField="Cor" HeaderText="Cor" />
                                <asp:BoundField DataField="Quantidade" HeaderText="Quantidade" />
                                <asp:BoundField DataField="UltimaGeracao" HeaderText="Última geração" />
                            </Columns>
                        </asp:GridView>
                    </div>

                    <div class="polimento-bi-section">
                        <h3>Últimas autorizações do período</h3>
                        <asp:GridView ID="gvPolimentoDetalhes" runat="server" AutoGenerateColumns="False" CssClass="bali-data-table" GridLines="None" EmptyDataText="Nenhuma autorização encontrada neste período.">
                            <Columns>
                                <asp:BoundField DataField="GeradoEm" HeaderText="Gerado em" />
                                <asp:BoundField DataField="Pedido" HeaderText="Pedido" />
                                <asp:BoundField DataField="Loja" HeaderText="Loja" />
                                <asp:BoundField DataField="TipoPolimento" HeaderText="Tipo" />
                                <asp:BoundField DataField="Cor" HeaderText="Cor" />
                                <asp:BoundField DataField="Veiculo" HeaderText="Veículo" />
                                <asp:BoundField DataField="Chassi" HeaderText="Chassi" />
                                <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                                <asp:BoundField DataField="Usuario" HeaderText="Usuário" />
                                <asp:BoundField DataField="Geracoes" HeaderText="Gerações" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <div id="ag" style="position:fixed; z-index:1000; top:0; left:0; width:100%; height:100%; background-color:rgba(0, 0, 0, 0.75); visibility:hidden;">
        <div style="position:fixed; z-index:1001; top:50%; left:50%; width:300px; height:100px; margin-left:-150px; margin-top:-50px; background-color:white; border-radius:5px;">
            <img src="../../img/aguarde.gif" style="border-radius:5px;" />
        </div>
    </div>
    <script>
        (function () {
            window.abrirPolimentoTab = function (tab) {
                tab = tab || 'autorizacao';
                var hidden = document.getElementById('hdnPolimentoTab');
                if (hidden) hidden.value = tab;

                var botoes = document.querySelectorAll('[data-polimento-tab]');
                var paineis = document.querySelectorAll('[data-polimento-panel]');
                for (var i = 0; i < botoes.length; i++) {
                    botoes[i].classList.toggle('is-active', botoes[i].getAttribute('data-polimento-tab') === tab);
                }
                for (var j = 0; j < paineis.length; j++) {
                    paineis[j].classList.toggle('is-active', paineis[j].getAttribute('data-polimento-panel') === tab);
                }
            };

            document.addEventListener('click', function (event) {
                var botao = event.target.closest ? event.target.closest('[data-polimento-tab]') : null;
                if (!botao) return;
                window.abrirPolimentoTab(botao.getAttribute('data-polimento-tab'));
            });

            document.addEventListener('DOMContentLoaded', function () {
                var hidden = document.getElementById('hdnPolimentoTab');
                window.abrirPolimentoTab(hidden && hidden.value ? hidden.value : 'autorizacao');
            });
        })();
    </script>
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
