<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Autorizacao_polimento_avulsoBYD.aspx.cs" Inherits="byd_Autorizacao_polimento_avulso" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Autoriza&ccedil;&atilde;o de Polimento - Avulso - BYD</title>
    <link href="../css/estilo.css" rel="stylesheet" />
    <link href="../css/bali-utility.css?v=20260713-polimento-avulso01" rel="stylesheet" />
    <script src="../js/bali-utility-print.js?v=20260707-polimento01"></script>
    <style>
        .polimento-avulso-grid { display: grid; grid-template-columns: minmax(220px, 1.3fr) minmax(220px, 1fr) auto; gap: 14px; align-items: end; }
        .polimento-avulso-field span { display: block; font-size: 11px; font-weight: 900; letter-spacing: .08em; text-transform: uppercase; color: #5f6f8a; margin-bottom: 6px; }
        .polimento-avulso-note { margin: 14px 0 0; padding: 12px 14px; border: 1px solid #dbe4f0; border-radius: 8px; background: #f8fafc; color: #46566f; font-size: 12px; line-height: 1.45; }
        @media (max-width: 760px) { .polimento-avulso-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body class="bali-utility-page utility-byd utility-no-sidebar">
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
                        <asp:Label ID="lblTipo" CssClass="idUser" runat="server" Style="margin-right: 13px;"></asp:Label><a class="bali-logout-link" href="/logout.aspx?voltar=/byd/loginAppcontrato.aspx">Sair</a></td>
                </tr>
            </table>
        </div>
        <div id="linha-branca"></div>
        <div id="menu-topo"></div>
        <div id="menu">
            <button type="button" class="bali-back-button" onclick="if (window.history.length > 1) { window.history.back(); } else { window.location.href='principal.aspx'; }">&larr; Voltar</button>
            <div style="text-align: right; margin-right: 15px;">
                <asp:Label ID="lblFrmID" runat="server" Text="Autorização de Polimento - Avulso"></asp:Label>
            </div>
        </div>

        <div id="TabRecibo">
            <asp:HiddenField ID="hdnPolimentoTab" runat="server" ClientIDMode="Static" Value="autorizacao" />
            <div class="polimento-tabs" role="tablist" aria-label="Navega&ccedil;&atilde;o da autoriza&ccedil;&atilde;o de polimento avulsa">
                <button type="button" class="polimento-tab is-active" data-polimento-tab="autorizacao">Autoriza&ccedil;&atilde;o</button>
                <button type="button" class="polimento-tab" data-polimento-tab="dados">Dados</button>
            </div>

            <div class="polimento-tab-panel is-active" data-polimento-panel="autorizacao">
                <fieldset>
                    <legend>Autoriza&ccedil;&atilde;o avulsa</legend>
                    <div class="polimento-avulso-grid">
                        <label class="polimento-avulso-field">
                            <span>Chassi ou placa</span>
                            <asp:TextBox ID="txtBusca" runat="server" MaxLength="20" autocomplete="off" placeholder="Ex.: 9BD... ou ABC1D23"></asp:TextBox>
                        </label>
                        <label class="polimento-avulso-field">
                            <span>Tipo de polimento</span>
                            <asp:DropDownList ID="ddlTipoPolimento" runat="server">
                                <asp:ListItem Text="Polimento completo do veículo" Value="Polimento completo do veículo"></asp:ListItem>
                                <asp:ListItem Text="Polimento do Black Piano" Value="Polimento do Black Piano"></asp:ListItem>
                            </asp:DropDownList>
                        </label>
                        <asp:Button ID="btnGerar" runat="server" OnClientClick="aguarde();" Text="Gerar autorização" OnClick="btnGerar_Click" CssClass="btns" />
                    </div>
                    <div class="polimento-avulso-note">Informe a placa ou o chassi completo. O sistema localizar&aacute; o ve&iacute;culo em estoque e preencher&aacute; a autoriza&ccedil;&atilde;o automaticamente.</div>
                    <br />
                    <button type="button" class="bali-print-action" onclick="javascript: imprimePanel()">Imprimir autoriza&ccedil;&atilde;o</button>
                    <asp:Panel ID="pnlImpressao" runat="server" Width="100%" Height="100%">
                        <div style="width: 18.6cm; min-height: 0; height: 25.7cm; box-sizing: border-box; border: 1px solid #111; font-family: 'Times New Roman', serif; padding: .65cm; color: #111; background: #fff; overflow: hidden;" id="autorizacao-polimento">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px solid #111; padding-bottom: 8px; margin-bottom: 14px;">
                                <div>
                                    <div style="font-family: Arial, Helvetica, sans-serif; font-size: 20px; font-weight: 900; letter-spacing: .04em;">GRUPO BALI</div>
                                    <div style="font-size: 10px; text-transform: uppercase; margin-top: 2px;"><asp:Label ID="lblEmpresa" runat="server"></asp:Label></div>
                                </div>
                                <div style="font-size: 10.5px; text-align: right;">
                                    Identifica&ccedil;&atilde;o: <strong><asp:Label ID="lblPedidoPrint" runat="server" Text="AVULSO"></asp:Label></strong><br />
                                    Busca: <strong><asp:Label ID="lblOrigemPrint" runat="server"></asp:Label></strong><br />
                                    Nota Fiscal: <strong><asp:Label ID="lblNota" runat="server"></asp:Label></strong><br />
                                    Proposta: <strong><asp:Label ID="lblProposta" runat="server"></asp:Label></strong>
                                </div>
                            </div>

                            <div style="text-align: center; font-size: 17px; font-weight: bold; text-transform: uppercase; margin: 10px 0 14px;">
                                Autoriza&ccedil;&atilde;o Interna para Execu&ccedil;&atilde;o de Polimento Veicular
                            </div>

                            <p style="font-size: 13px; line-height: 1.28; text-align: justify; margin: 7px 0;">
                                Pelo presente documento, fica autorizada a execu&ccedil;&atilde;o do servi&ccedil;o de <strong>polimento veicular</strong> no ve&iacute;culo abaixo identificado, conforme dados extra&iacute;dos do sistema interno da empresa por placa ou chassi.
                            </p>

                            <table style="width: 100%; border-collapse: collapse; margin: 12px 0 14px; font-size: 11.5px;">
                                <tr><td style="border: 1px solid #444; padding: 4px 6px; width: 25%; background: #f2f2f2;"><strong>Cliente</strong></td><td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblCliente" runat="server"></asp:Label></td></tr>
                                <tr><td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Ve&iacute;culo</strong></td><td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblVeiculo" runat="server"></asp:Label></td></tr>
                                <tr><td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Ano/Modelo</strong></td><td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblAno" runat="server"></asp:Label></td></tr>
                                <tr><td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Cor</strong></td><td style="border: 1px solid #444; padding: 4px 6px; font-size: 12.5px; font-weight: bold;"><asp:Label ID="lblCor" runat="server"></asp:Label></td></tr>
                                <tr><td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Chassi</strong></td><td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblChassi" runat="server"></asp:Label></td></tr>
                                <tr><td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Placa</strong></td><td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblPlaca" runat="server"></asp:Label></td></tr>
                                <tr><td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Unidade</strong></td><td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblUnidade" runat="server"></asp:Label></td></tr>
                                <tr><td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Estoque</strong></td><td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblEstoque" runat="server"></asp:Label></td></tr>
                                <tr><td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Valor registrado</strong></td><td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblValor" runat="server"></asp:Label></td></tr>
                                <tr><td style="border: 1px solid #444; padding: 4px 6px; background: #f2f2f2;"><strong>Vendedor</strong></td><td style="border: 1px solid #444; padding: 4px 6px;"><asp:Label ID="lblVendedor" runat="server"></asp:Label></td></tr>
                            </table>

                            <p style="font-size: 13px; line-height: 1.28; text-align: justify; margin: 7px 0;">A presente autoriza&ccedil;&atilde;o tem por finalidade permitir a realiza&ccedil;&atilde;o do servi&ccedil;o necess&aacute;rio &agrave; adequada apresenta&ccedil;&atilde;o est&eacute;tica do ve&iacute;culo, visando sua prepara&ccedil;&atilde;o para exposi&ccedil;&atilde;o, comercializa&ccedil;&atilde;o, entrega ou demais finalidades operacionais da &aacute;rea de vendas.</p>
                            <p style="font-size: 13px; line-height: 1.28; text-align: justify; margin: 7px 0;">Declaro, na qualidade de gerente respons&aacute;vel, que tomei ci&ecirc;ncia da solicita&ccedil;&atilde;o e <strong>autorizo expressamente</strong> a execu&ccedil;&atilde;o do polimento no ve&iacute;culo acima identificado, ficando registrado que o servi&ccedil;o somente dever&aacute; ser realizado ap&oacute;s a assinatura desta autoriza&ccedil;&atilde;o.</p>
                            <p style="font-size: 13px; line-height: 1.28; text-align: justify; margin: 7px 0;">Esta autoriza&ccedil;&atilde;o dever&aacute; ser arquivada no sistema interno da empresa para fins de controle, rastreabilidade e comprova&ccedil;&atilde;o da aprova&ccedil;&atilde;o gerencial.</p>
                            <p style="text-align: center; margin: 4px 0 3px;"><strong style="display: block; font-size: 24px; line-height: 1.05; text-transform: uppercase; letter-spacing: 0;">Servi&ccedil;o autorizado: <asp:Label ID="lblTipoPolimento" runat="server" Text="Polimento completo do veículo"></asp:Label>.</strong></p>
                            <div style="margin-top: 14px; font-size: 13px;"><asp:Label ID="lblData" runat="server"></asp:Label></div>
                            <div style="margin-top: 30px; text-align: center; font-size: 12.5px;">
                                <div style="width: 64%; margin: 0 auto; border-top: 1px solid #111; padding-top: 7px;">
                                    <strong>GER&Ecirc;NCIA DE VENDAS</strong><br />
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
                        <legend>Dados da autoriza&ccedil;&atilde;o</legend>
                        Data inicial: <asp:TextBox ID="txtBIDataInicial" runat="server"></asp:TextBox>
                        Data final: <asp:TextBox ID="txtBIDataFinal" runat="server"></asp:TextBox>
                        <asp:Button ID="btnAtualizarBI" runat="server" Text="Atualizar dados" CssClass="btns" OnClick="btnAtualizarBI_Click" OnClientClick="document.getElementById('hdnPolimentoTab').value='dados';" />
                    </fieldset>
                    <div class="polimento-bi-grid">
                        <article><small>Autorizações</small><strong><asp:Label ID="lblBITotal" runat="server" Text="0"></asp:Label></strong></article>
                        <article><small>Cores diferentes</small><strong><asp:Label ID="lblBICores" runat="server" Text="0"></asp:Label></strong></article>
                        <article><small>Cor mais frequente</small><strong><asp:Label ID="lblBITopCor" runat="server" Text="-"></asp:Label></strong></article>
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
                for (var i = 0; i < botoes.length; i++) botoes[i].classList.toggle('is-active', botoes[i].getAttribute('data-polimento-tab') === tab);
                for (var j = 0; j < paineis.length; j++) paineis[j].classList.toggle('is-active', paineis[j].getAttribute('data-polimento-panel') === tab);
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
        var printWindow = window.open('formPadrao.aspx', 'AutorizacaoPolimentoAvulso', 'left=50000,top=50000,width=0,height=0');
        printWindow.document.write(printContent.innerHTML);
        printWindow.document.close();
        printWindow.focus();
        printWindow.print();
        printWindow.close();
    }
</script>
