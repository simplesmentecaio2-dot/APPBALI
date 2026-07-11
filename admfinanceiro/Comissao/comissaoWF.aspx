<%@ page language="C#" autoeventwireup="true" codefile="~/admfinanceiro/Comissao/comissaoWF.aspx.cs" inherits="admfinanceiro_Comissao_comissao" %>

<%@ register assembly="Microsoft.ReportViewer.WebForms, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" namespace="Microsoft.Reporting.WebForms" tagprefix="rsweb" %>

<%@ register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Comiss&otilde;es WF | Grupo Bali</title>
    <link href="../../css/estilo.css" rel="stylesheet" />
    <link href="../../css/comissao-wf.css?v=20260711-03" rel="stylesheet" />
    <script src="../../js/jquery-1.10.2.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.min.js"></script>
    <script src="../../js/js.js"></script>
    <script src="../../js/comissao-wf.js?v=20260711-03" defer="defer"></script>
    <script type="text/javascript">
        function aguarde() {
            if (window.BaliComissao && window.BaliComissao.showLoading) {
                window.BaliComissao.showLoading();
            } else if (window.jQuery) {
                $("#ag").show();
            }
            return true;
        }

        function fecharAguarde() {
            if (window.BaliComissao && window.BaliComissao.hideLoading) {
                window.BaliComissao.hideLoading();
            } else if (window.jQuery) {
                $("#ag").hide();
            }
        }

        function moeda() {
            $('.moeda').priceFormat({
                prefix: false,
                centsSeparator: ',',
                thousandsSeparator: '.'
            });
        }

        function printDiv(divID) {
            var alvo = document.getElementById(divID);
            if (!alvo) {
                alert('Selecione um vendedor antes de imprimir.');
                return false;
            }

            var conteudo = alvo.innerHTML;
            var win = window.open('', '_blank');
            win.document.write('<!doctype html><html lang="pt-BR"><he' + 'ad><meta charset="utf-8"><style>body{font-family:Arial,Helvetica,sans-serif;color:#111827;margin:18px}table{border-collapse:collapse}td,th{padding:4px 6px}fieldset{border:1px solid #cbd5e1;border-radius:8px;margin:0 0 14px;padding:12px}input,select{border:0;background:transparent;font-weight:700}.venda{color:#111827}.devolucao{color:#a52828}.sessenta{color:#2f6b3c}.zerotrinta{color:#7c3f98}@media print{body{margin:8mm}.no-print{display:none!important}}</style></he' + 'ad><body>');
            win.document.write(conteudo);
            win.document.write('</body></html>');
            win.document.close();
            win.focus();
            win.print();
            win.close();
            return false;
        }
    </script>
    <style type="text/css">
        .moeda {
        }

        .venda {
            color: black;
        }

        .devolucao {
            color: red;
        }

        .zerotrinta{
            color: mediumvioletred;
        }

        .sessenta {
            color: green;
        }
    </style>
</head>
<body class="comissao-wf-page" onload="moeda()">
    <form id="form1" runat="server" autocomplete="off">

        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>

        <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo"><font id="logo" style="font-family: Arial black; font-size: 32px; font-style: italic; color: white; margin-left: 13px;"><a href="../../Default.aspx" class="linkHome">GRUPO BALI</a></font><font style="font-family: Calibri; font-size: 14px; margin-left: 5px; font-style: italic; color: white;">Financeiro</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
                    <td id="table-menu-usuario" class="idUser">Usu&aacute;rio:
                        <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text=""></asp:Label>
                        C&oacute;digo:
                        <asp:Label ID="lblTipo" CssClass="idUser" runat="server" style="margin-right: 13px;" Text=""></asp:Label>
                        <a class="comissao-logout" href="/logout.aspx?voltar=/login.aspx">Sair</a>
                    </td>
                </tr>
            </table>
        </div>

        <div id="linha-branca"></div>
        <div id="menu-topo">
        </div>
        <div id="menu">
            <div id="openMenuUp" class="menu-top" onclick="window.location.href='../Default.aspx'">
                Voltar
            </div>
            <div style="text-align: right; margin-right: 15px;">
                <asp:Label ID="lblFrmID" runat="server" Text="Comissão"></asp:Label>
            </div>
        </div>
        <img id="openMenu" src="../../img/openMenu.png" style="height: 68px; width: 68px; position: absolute; z-index: 200; top: 60px; left: 10px; display: none;" />
        <div id="menu-left">
            <div class="item-menu" style="padding-left: 80px; height: 50px; line-height: 60px;" onclick="escondeMenuLeft()">
                MENU <<
            </div>
            <div class="item-menu-select"><a class="links" href="../Default.aspx">PASTAS</a></div>
            <div class="item-menu"><a class="links" href="comissao.aspx">Comissão</a></div>

            <div id="completa-menu-left"></div>
        </div>

        <div id="Cont" onmouseover="esconderMenuLeftMouse()">
            <div class="comissao-shell">
                <section class="comissao-hero no-print">
                    <div>
                        <span class="comissao-eyebrow">Administra&ccedil;&atilde;o financeira &middot; Workflow</span>
                        <h1>Gest&atilde;o de comiss&otilde;es</h1>
                        <p>Consulte vendedores por per&iacute;odo, revise valores calculados, grave comiss&otilde;es e acesse os relat&oacute;rios sem sair da tela.</p>
                    </div>
                    <div class="comissao-hero-actions">
                        <a href="../Default.aspx">Central financeira</a>
                        <button type="button" onclick="window.print()">Imprimir tela</button>
                    </div>
                </section>
            <table class="comissao-root-table" style="width: 100%; padding: 13px; text-align: left;" align="center">
                <tr style="width: 100%;">
                    <td style="width: 100%;">

                        <asp:TabContainer ID="TabContainercomissao" CssClass="tabPanelConsultar" Width="100%" runat="server" ActiveTabIndex="0">
                            <asp:TabPanel ID="TabPanelComissaoGeral" Style="padding: 20px;" runat="server" HeaderText="">
                                <headertemplate>
                                    Comissão
                                </headertemplate>
                                <contenttemplate>
                                    <table>
                                        <tr>
                                            <td>Data Inicial:</td>
                                            <td>Data Final:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="txtDtInicial" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="txtDtInicial_CalendarExtender" runat="server" Enabled="True" TargetControlID="txtDtInicial" Format="dd/MM/yyyy"></asp:CalendarExtender>



                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtDtFinal" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="txtDtFinal_CalendarExtender" runat="server" Enabled="True" TargetControlID="txtDtFinal" Format="dd/MM/yyyy"></asp:CalendarExtender>



                                                <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" OnClientClick="aguarde();" Text="Atualizar"></asp:Button>


                                            </td><td>
                                                <asp:Label ID="lblpreto" runat="server" text="Preto: Venda/" style=" height: 25px; text-align: center; color: black; font-weight: bold;"></asp:Label>
                                                <asp:Label ID="lblvermelho" runat="server" text="Vermelho: Devolução/" style=" height: 25px; text-align: center; color: red; font-weight: bold;"></asp:Label>
                                                <asp:Label ID="Label2" runat="server" text="Verde: Comissão 0,6%/" style=" height: 25px; text-align: center; color: green; font-weight: bold;"></asp:Label>
                                                <asp:Label ID="Label3" runat="server" text="Roxo: Comissão 0,3%" style=" height: 25px; text-align: center; color: purple; font-weight: bold;"></asp:Label>
                                                 
                                                
                                                 </td>
                                        </tr>
                                    </table>
                                    <div style="width: 100%; height: 1px; margin-top: 20px; margin-bottom: 20px; background-color: silver;"></div>
                                    <table>
                                        <tr>
                                            <td colspan="3" align="right">
                                                <img src="../../img/imprimir.png" class="comissao-print-icon" width="30px" onclick="printDiv('print-comissao');" alt="Imprimir comissão" />
                                                Imprimir
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top">

                                                <asp:GridView ID="gViewListarVendedores" DataSourceID="sqldsListarVendedores" runat="server" AutoGenerateColumns="False" BackColor="White" BorderColor="#CCCCCC" BorderStyle="None" BorderWidth="1px" CellPadding="4" Font-Size="12px" ForeColor="Black" GridLines="Horizontal" OnSelectedIndexChanged="gViewListarVendedores_SelectedIndexChanged" onclick="aguarde();">

                                                    <columns>

                                                        <asp:BoundField DataField="loja" HeaderText="Loja" ReadOnly="True" SortExpression="id_perfil" />
                                                        <asp:BoundField DataField="fun_cd" HeaderText="Cód." ReadOnly="True" SortExpression="id_perfil" />
                                                        <asp:BoundField DataField="vendedor" HeaderText="VENDEDOR" ReadOnly="True" SortExpression="id_sistema" />
                                                        <asp:CommandField ShowSelectButton="True" HeaderText="&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;" SelectText="&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;" />
                                                    </columns>

                                                    <emptydatatemplate>
                                                        Nenhum item encontrado.
                                                    </emptydatatemplate>

                                                    <footerstyle backcolor="#CCCC99" forecolor="Black" />

                                                    <headerstyle backcolor="#333333" font-bold="True" forecolor="White" />

                                                    <pagerstyle backcolor="White" forecolor="Black" horizontalalign="Right" />

                                                    <selectedrowstyle backcolor="#CC3333" font-bold="True" forecolor="White" />

                                                    <sortedascendingcellstyle backcolor="#F7F7F7" />

                                                    <sortedascendingheaderstyle backcolor="#4B4B4B" />

                                                    <sorteddescendingcellstyle backcolor="#E5E5E5" />

                                                    <sorteddescendingheaderstyle backcolor="#242121" />

                                                </asp:GridView>




                                            </td>
                                            <td valign="top" style="width: 30px;" align="center">
                                                <div style="width: 1px; height: 2000px; background-color: silver;"></div>
                                            </td>
                                            <td valign="top">

                                                <div id="print-comissao" class="comissao-print-area">
                                                    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                                                        <contenttemplate>

                                                            <fieldset>

                                                                <table cellspacing="5">
                                                                    <tr>
                                                                        <td colspan="6" style="background-color: #333333; height: 25px; text-align: center; color: white; font-weight: bold;">Loja: 
                                                                            <asp:Label ID="lblLoja" runat="server"></asp:Label>
                                                                            Vendedor:
                                                                            <asp:Label ID="lblNomeVendedor" runat="server"></asp:Label>
                                                                            <asp:Label ID="lblCodVend" runat="server" Text=""></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td></td>
                                                                        <td></td>
                                                                        <td align="right" style="text-align: right;"></td>
                                                                        <td colspan="3"></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>Qtde VN:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtQtdeVN" CssClass="txts" Style="direction: rtl;" runat="server" Width="20px"></asp:TextBox>
                                                                        </td>
                                                                        <td>Comissão VN:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtComissaoVN" runat="server" CssClass="moeda txts" onkeyup="moeda()" Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>
                                                                        <td>Líq Total VN:</td>
                                                                        <td align="right">
                                                                            <asp:TextBox ID="txtTotalLiquido" runat="server" CssClass="moeda txts" onkeyup="moeda()" Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>Qtde VU:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtQtdeVU" Style="direction: rtl;" CssClass="txts" runat="server" Width="20px"></asp:TextBox>
                                                                        </td>
                                                                        <td>Comissão VU:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtComissaoVU" runat="server" CssClass="moeda txts" onkeyup="moeda()" Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>
                                                                        <td>Em Branco</td>
                                                                        <td align="right">
                                                                            <asp:TextBox ID="txtLb2" runat="server" CssClass="moeda txts" onkeyup="moeda()" Style="direction: rtl;" Width="80px"></asp:TextBox>


                                                                            <%--  <select id="margem" onchange="RecalcularComissao()">
                                                                <option>Margem</option>
                                                                <option value="5">0,5</option>
                                                                <option value="6">0,6</option>
                                                                <option value="7">0,7</option>

                                                            </select>   --%>                                                         
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>Qtde VD</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtQtdeVD" CssClass="txts" Style="direction: rtl;" runat="server" Width="20px"></asp:TextBox>

                                                                        </td>
                                                                        <td>Comissão VD:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtComissaoVD" runat="server" onkeyup="moeda()" CssClass="moeda txts" Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>
                                                                        <td>Atualiza Comis:
                                                                        </td>
                                                                        <td align="right">
                                                                            <asp:DropDownList ID="ddlistMargem" runat="server" CssClass="txts" AutoPostBack="True" OnSelectedIndexChanged="ddlistMargem_SelectedIndexChanged">

                                                                                <asp:ListItem Value="0">0</asp:ListItem>
                                                                                <asp:ListItem Value="0.4">0.4</asp:ListItem>
                                                                                <asp:ListItem Value="0.5">0.5</asp:ListItem>
                                                                                <asp:ListItem Value="0.6">0.6</asp:ListItem>

                                                                            </asp:DropDownList>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>Qtde Total:
                                                                        </td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtQtdeTotal" CssClass="txts" Style="direction: rtl;" runat="server" Width="20px"></asp:TextBox>
                                                                        </td>
                                                                        <td> Cálculo Dif.1%
                                                                        </td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtComissaoLB" runat="server" Style="direction: rtl;" onkeyup="moeda()" Width="80px" CssClass="moeda txts"  ></asp:TextBox>
                                                                        </td>
                                                                        <td>Dif. 1%:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtDif1" runat="server" Style="direction: rtl;" onkeyup="moeda()" Width="80px" CssClass="moeda txts"></asp:TextBox>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>Emplacamento</td>
                                                                        <td><asp:TextBox ID="txtlb" runat="server" CssClass="moeda txts" onkeyup="moeda()" Style="direction: rtl;" Width="45px"  ></asp:TextBox></td>
                                                                        <td>Comissão Total:
                                                                        </td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtComissaoTotal" CssClass="moeda txts" onkeyup="moeda()" runat="server" Style="direction: rtl; font-weight: bold;" Width="80px" Font-Bold="True"></asp:TextBox>
                                                                        </td>

                                                                        <td align="right" colspan="2">
                                                                            <asp:Button ID="btnREcalcularTotal" style="background-color: #dc1f1f; color: white; height: 25px; line-height: 25px; cursor: pointer; border-radius: 3px; font-weight: bold; border: none;" runat="server" Text="Rec..." ToolTip="Recalcular" OnClick="btnREcalcularTotal_Click" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="6" align="right">
                                                                            <div style="width: 100%; height: 1px; background-color: silver; margin-top: 3px; margin-bottom: 12px;"></div>


                                                                            <asp:Button ID="btnSalvar" CssClass="btns" runat="server" Text="Salvar" OnClick="btnSalvar_Click" />
                                                                        </td>
                                                                    </tr>

                                                                </table>
                                                            </fieldset>

                                                        </contenttemplate>
                                                    </asp:UpdatePanel>
                                                    <br />
                                                    <br />
                                                    NOVOS <%=tabelaVN %><br />
                                                    <br />
                                                    SEMINOVOS<br />
                                                    <%=tabelaVU %><br />
                                                    EMPLACAMENTO<br />
                                                    <%=tabelaEMPL %>
                                                </div>

                                            </td>

                                        </tr>

                                    </table>
                                    <asp:SqlDataSource ID="sqldsListarVendedores" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" SelectCommand="gerencia_comissao_listar_vendedores_do_mes" SelectCommandType="StoredProcedure">
                                        <selectparameters>
                                            <asp:ControlParameter ControlID="txtDtInicial" DbType="Date" Name="dtInicial" PropertyName="Text" />
                                            <asp:ControlParameter ControlID="txtDtFinal" DbType="Date" Name="dtFinal" PropertyName="Text" />
                                        </selectparameters>
                                    </asp:SqlDataSource>
                                </contenttemplate>
                            </asp:TabPanel>


                            <asp:TabPanel ID="TabPanel3" Style="padding: 20px;" runat="server" HeaderText="">
                                <headertemplate>
                                    Venda Direta
                                </headertemplate>
                                <contenttemplate>

                                    <table>
                                        <tr>
                                            <td>Data Inicial:</td>
                                            <td>Data Final:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="txtDtinicialPrem" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="CalendarExtender1" runat="server" Enabled="True" TargetControlID="txtDtinicialPrem" Format="dd/MM/yyyy"></asp:CalendarExtender>

                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtDtfinalPrem" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="CalendarExtender2" runat="server" Enabled="True" TargetControlID="txtDtfinalPrem" Format="dd/MM/yyyy"></asp:CalendarExtender>
                                                <asp:Button ID="Button4" runat="server" OnClick="Button5_Click" OnClientClick="aguarde();" Text="Atualizar"></asp:Button>

                                            </td>
                                        </tr>
                                    </table>

                                    <div style="width: 100%; height: 1px; margin-top: 20px; margin-bottom: 20px; background-color: silver;"></div>
                                    <table>
                                        <tr>
                                            <td colspan="3" align="right">
                                                <img src="../../img/imprimir.png" class="comissao-print-icon" width="30px" onclick="printDiv('print-venda-direta');" alt="Imprimir venda direta" />
                                                Imprimir
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top">

                                                <asp:GridView ID="gViewListarVendedoresVD" DataSourceID="sqldsListarVendedoresPrem" runat="server" AutoGenerateColumns="False" BackColor="White" BorderColor="#CCCCCC" BorderStyle="None" BorderWidth="1px" CellPadding="4" Font-Size="12px" ForeColor="Black" GridLines="Horizontal" OnSelectedIndexChanged="gViewListarVendedores_SelectedIndexChangedVD" onclick="aguarde();">

                                                    <columns>

                                                        <asp:BoundField DataField="loja" HeaderText="Loja" ReadOnly="True" SortExpression="id_perfil" />
                                                        <asp:BoundField DataField="fun_cd" HeaderText="Cód." ReadOnly="True" SortExpression="id_perfil" />
                                                        <asp:BoundField DataField="vendedor" HeaderText="VENDEDOR" ReadOnly="True" SortExpression="id_sistema" />
                                                        <asp:CommandField ShowSelectButton="True" HeaderText="&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;" SelectText="&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;" />
                                                    </columns>

                                                    <emptydatatemplate>
                                                        Nenhum item encontrado.
                                                    </emptydatatemplate>

                                                    <footerstyle backcolor="#CCCC99" forecolor="Black" />

                                                    <headerstyle backcolor="#333333" font-bold="True" forecolor="White" />

                                                    <pagerstyle backcolor="White" forecolor="Black" horizontalalign="Right" />

                                                    <selectedrowstyle backcolor="#CC3333" font-bold="True" forecolor="White" />

                                                    <sortedascendingcellstyle backcolor="#F7F7F7" />

                                                    <sortedascendingheaderstyle backcolor="#4B4B4B" />

                                                    <sorteddescendingcellstyle backcolor="#E5E5E5" />

                                                    <sorteddescendingheaderstyle backcolor="#242121" />

                                                </asp:GridView>




                                            </td>
                                            <td valign="top" style="width: 30px;" align="center">
                                                <div style="width: 1px; height: 1000px; background-color: silver;"></div>
                                            </td>
                                            <td valign="top">

                                                <div id="print-venda-direta" class="comissao-print-area">
                                                    <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
                                                        <contenttemplate>

                                                            <fieldset>

                                                                <table cellspacing="5">
                                                                    <tr>
                                                                        <td colspan="6" style="background-color: #333333; height: 25px; text-align: center; color: white; font-weight: bold;">Loja: 
                                                                            <asp:Label ID="lblLojaVD" runat="server"></asp:Label>
                                                                            Vendedor:
                                                                            <asp:Label ID="lblVendVD" runat="server"></asp:Label>
                                                                            <asp:Label ID="lblcodVD" runat="server" Text="Cód."></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td></td>
                                                                        <td></td>
                                                                        <td align="right" style="text-align: right;"></td>
                                                                        <td colspan="3"></td>
                                                                    </tr>


                                                                    <tr>

                                                                        <td>Comissão VD:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtcomissaoVD2" runat="server" onkeyup="moeda()" CssClass="moeda txts" Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>

                                                                    </tr>

                                                                    <tr>
                                                                        <td></td>
                                                                        <td></td>


                                                                        <td align="right" colspan="2"></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="6" align="right">
                                                                            <div style="width: 100%; height: 1px; background-color: silver; margin-top: 3px; margin-bottom: 12px;"></div>


                                                                            <asp:Button ID="btnSalvarVD" CssClass="btns" runat="server" Text="Salvar" OnClick="btnSalvarVD_Click" />
                                                                        </td>
                                                                    </tr>

                                                                </table>
                                                            </fieldset>

                                                        </contenttemplate>
                                                    </asp:UpdatePanel>
                                                    <br />
                                                    <br />
                                                    <%-- NOVOS <%=tabelaVN %><br />
                                                <br />
                                                SEMINOVOS<br />
                                                <%=tabelaVU %><br />
                                                EMPLACAMENTO<br />
                                                 <%=tabelaEMPL %>--%>
                                                </div>

                                            </td>

                                        </tr>

                                    </table>
                                    <asp:SqlDataSource ID="sqldsListarVendedoresPrem" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" SelectCommand="gerencia_comissao_listar_vendedores_do_mesVD" SelectCommandType="StoredProcedure">
                                        <selectparameters>
                                            <asp:ControlParameter ControlID="txtDtinicialPrem" DbType="Date" Name="dtInicial" PropertyName="Text" />
                                            <asp:ControlParameter ControlID="txtDtfinalPrem" DbType="Date" Name="dtFinal" PropertyName="Text" />
                                        </selectparameters>
                                    </asp:SqlDataSource>

                                </contenttemplate>
                            </asp:TabPanel>


                             <asp:TabPanel ID="TabPanel7" Style="padding: 20px;" runat="server" HeaderText="">
                                <headertemplate>
                                    Emplacamento
                                </headertemplate>
                                <contenttemplate>

                                    <table>
                                        <tr>
                                            <td>Data Inicial:</td>
                                            <td>Data Final:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="txtDtinicialEmpl" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="CalendarExtender9" runat="server" Enabled="True" TargetControlID="txtDtinicialEmpl" Format="dd/MM/yyyy"></asp:CalendarExtender>

                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtDtfinalEmpl" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="CalendarExtender10" runat="server" Enabled="True" TargetControlID="txtDtfinalEmpl" Format="dd/MM/yyyy"></asp:CalendarExtender>
                                                <asp:Button ID="Button8" runat="server" OnClick="Button8_Click" OnClientClick="aguarde();" Text="Atualizar"></asp:Button>

                                            </td>
                                        </tr>
                                    </table>

                                    <div style="width: 100%; height: 1px; margin-top: 20px; margin-bottom: 20px; background-color: silver;"></div>
                                    <table>
                                        <tr>
                                            <td colspan="3" align="right">
                                                <img src="../../img/imprimir.png" class="comissao-print-icon" width="30px" onclick="printDiv('print-emplacamento');" alt="Imprimir emplacamento" />
                                                Imprimir
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top">

                                                <asp:GridView ID="gViewListarVendedoresEMPLACAMENTO" DataSourceID="sqldsListarVendedoresEmplac" runat="server" AutoGenerateColumns="False" BackColor="White" BorderColor="#CCCCCC" BorderStyle="None" BorderWidth="1px" CellPadding="4" Font-Size="12px" ForeColor="Black" GridLines="Horizontal" OnSelectedIndexChanged="gViewListarVendedores_SelectedIndexChangedEMPL" onclick="aguarde();">

                                                    <columns>

                                                        <asp:BoundField DataField="loja" HeaderText="Loja" ReadOnly="True" SortExpression="id_perfil" />
                                                        <asp:BoundField DataField="fun_cd" HeaderText="Cód." ReadOnly="True" SortExpression="id_perfil" />
                                                        <asp:BoundField DataField="vendedor" HeaderText="VENDEDOR" ReadOnly="True" SortExpression="id_sistema" />
                                                        <asp:CommandField ShowSelectButton="True" HeaderText="&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;" SelectText="&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;" />
                                                    </columns>

                                                    <emptydatatemplate>
                                                        Nenhum item encontrado.
                                                    </emptydatatemplate>

                                                    <footerstyle backcolor="#CCCC99" forecolor="Black" />

                                                    <headerstyle backcolor="#333333" font-bold="True" forecolor="White" />

                                                    <pagerstyle backcolor="White" forecolor="Black" horizontalalign="Right" />

                                                    <selectedrowstyle backcolor="#CC3333" font-bold="True" forecolor="White" />

                                                    <sortedascendingcellstyle backcolor="#F7F7F7" />

                                                    <sortedascendingheaderstyle backcolor="#4B4B4B" />

                                                    <sorteddescendingcellstyle backcolor="#E5E5E5" />

                                                    <sorteddescendingheaderstyle backcolor="#242121" />

                                                </asp:GridView>




                                            </td>
                                            <td valign="top" style="width: 30px;" align="center">
                                                <div style="width: 1px; height: 1000px; background-color: silver;"></div>
                                            </td>
                                            <td valign="top">

                                                <div id="print-emplacamento" class="comissao-print-area">
                                                    <asp:UpdatePanel ID="UpdatePanel4" runat="server" UpdateMode="Conditional">
                                                        <contenttemplate>

                                                            <fieldset>

                                                                <table cellspacing="5">
                                                                    <tr>
                                                                        <td colspan="6" style="background-color: #333333; height: 25px; text-align: center; color: white; font-weight: bold;">
                                                                            Loja: 
                                                                            <asp:Label ID="lblLojaempl" runat="server"></asp:Label>
                                                                            Vendedor:
                                                                            <asp:Label ID="lblVendempl" runat="server"></asp:Label>
                                                                            <asp:Label ID="lblCodempl" runat="server" Text="Cód."></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td></td>
                                                                        <td></td>
                                                                        <td align="right" style="text-align: right;"></td>
                                                                        <td colspan="3"></td>
                                                                    </tr>


                                                                    <tr>

                                                                        <td>Emplacamento:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtEmplacamento" runat="server" onkeyup="moeda()" CssClass="moeda txts" Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>

                                                                    </tr>

                                                                    <tr>
                                                                        <td></td>
                                                                        <td></td>


                                                                        <td align="right" colspan="2"></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="6" align="right">
                                                                            <div style="width: 100%; height: 1px; background-color: silver; margin-top: 3px; margin-bottom: 12px;"></div>


                                                                            <asp:Button ID="btnSalvarEmpl" CssClass="btns" runat="server" Text="Salvar" OnClick="btnSalvarEmpl_Click" />
                                                                        </td>
                                                                    </tr>

                                                                </table>
                                                            </fieldset>

                                                        </contenttemplate>
                                                    </asp:UpdatePanel>
                                                    <br />
                                                    <br />
                                                    <%-- NOVOS <%=tabelaVN %><br />
                                                <br />
                                                SEMINOVOS<br />
                                                <%=tabelaVU %><br />--%>
                                                EMPLACAMENTO<br />
                                                 <%=tabelaEMPL %>
                                                </div>

                                            </td>

                                        </tr>

                                    </table>
                                    <asp:SqlDataSource ID="sqldsListarVendedoresEmplac" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" SelectCommand="gerencia_comissao_listar_vendedores_do_mes" SelectCommandType="StoredProcedure">
                                        <selectparameters>
                                            <asp:ControlParameter ControlID="txtDtinicialEmpl" DbType="Date" Name="dtInicial" PropertyName="Text" />
                                            <asp:ControlParameter ControlID="txtDtfinalEmpl" DbType="Date" Name="dtFinal" PropertyName="Text" />
                                        </selectparameters>
                                    </asp:SqlDataSource>

                                </contenttemplate>
                            </asp:TabPanel>

                            <asp:TabPanel ID="TabPanel4" Style="padding: 20px;" runat="server" HeaderText="">
                                <headertemplate>
                                    Premiação
                                </headertemplate>
                                <contenttemplate>
                                    <table>
                                        <tr>
                                            <td>Data Inicial:</td>
                                            <td>Data Final:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="txtdtInicialPremiacao" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="CalendarExtender5" runat="server" Enabled="True" TargetControlID="txtdtInicialPremiacao" Format="dd/MM/yyyy"></asp:CalendarExtender>

                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtdtFinalPremiacao" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="CalendarExtender6" runat="server" Enabled="True" TargetControlID="txtdtFinalPremiacao" Format="dd/MM/yyyy"></asp:CalendarExtender>
                                                <asp:Button ID="Button5" runat="server" OnClick="Button6_Click" OnClientClick="aguarde();" Text="Atualizar"></asp:Button>

                                            </td>
                                        </tr>
                                    </table>

                                    <div style="width: 100%; height: 1px; margin-top: 20px; margin-bottom: 20px; background-color: silver;"></div>
                                    <table>
                                        <tr>
                                            <td colspan="3" align="right">
                                                <img src="../../img/imprimir.png" class="comissao-print-icon" width="30px" onclick="printDiv('print-premiacao');" alt="Imprimir premiação" />
                                                Imprimir
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top">

                                                <asp:GridView ID="gViewListarVendedoresPREMIACAO" DataSourceID="sqldsListarVendedoresPremiacao" runat="server" AutoGenerateColumns="False" BackColor="White" BorderColor="#CCCCCC" BorderStyle="None" BorderWidth="1px" CellPadding="4" Font-Size="12px" ForeColor="Black" GridLines="Horizontal" OnSelectedIndexChanged="gViewListarVendedores_SelectedIndexChangedPREM" onclick="aguarde();">

                                                    <columns>
                                                        <asp:BoundField DataField="loja" HeaderText="Loja" ReadOnly="True" SortExpression="id_perfil" />
                                                        <asp:BoundField DataField="fun_cd" HeaderText="Cód." ReadOnly="True" SortExpression="id_perfil" />
                                                        <asp:BoundField DataField="vendedor" HeaderText="VENDEDOR" ReadOnly="True" SortExpression="id_sistema" />
                                                        <asp:CommandField ShowSelectButton="True" HeaderText="&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;" SelectText="&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;" />
                                                    </columns>

                                                    <emptydatatemplate>
                                                        Nenhum item encontrado.
                                                    </emptydatatemplate>

                                                    <footerstyle backcolor="#CCCC99" forecolor="Black" />

                                                    <headerstyle backcolor="#333333" font-bold="True" forecolor="White" />

                                                    <pagerstyle backcolor="White" forecolor="Black" horizontalalign="Right" />

                                                    <selectedrowstyle backcolor="#CC3333" font-bold="True" forecolor="White" />

                                                    <sortedascendingcellstyle backcolor="#F7F7F7" />

                                                    <sortedascendingheaderstyle backcolor="#4B4B4B" />

                                                    <sorteddescendingcellstyle backcolor="#E5E5E5" />

                                                    <sorteddescendingheaderstyle backcolor="#242121" />

                                                </asp:GridView>




                                            </td>
                                            <td valign="top" style="width: 30px;" align="center">
                                                <div style="width: 1px; height: 1000px; background-color: silver;"></div>
                                            </td>
                                            <td valign="top">

                                                <div id="print-premiacao" class="comissao-print-area">
                                                    <asp:UpdatePanel ID="UpdatePanel3" runat="server" UpdateMode="Conditional">
                                                        <contenttemplate>

                                                            <fieldset>

                                                                <table cellspacing="5">
                                                                    <tr>
                                                                        <td colspan="6" style="background-color: #333333; height: 25px; text-align: center; color: white; font-weight: bold;">Loja: 
                                                                            <asp:Label ID="lblLojaPrem" runat="server"></asp:Label>
                                                                            Vendedor:
                                                                            <asp:Label ID="lblVendedorPrem" runat="server"></asp:Label>
                                                                            <asp:Label ID="lblCodPrem" runat="server" Text="Cód."></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td></td>
                                                                        <td></td>
                                                                        <td align="right" style="text-align: right;"></td>
                                                                        <td colspan="3"></td>
                                                                    </tr>


                                                                    <tr>

                                                                        <td>Retorno:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtRetorno" runat="server" onkeyup="moeda()"  Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>
                                                                        <td>Cheque Bônus:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtCheque" runat="server" onkeyup="moeda()"  Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>

                                                                        <td>Prêmio Prod:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtPremioProd" runat="server" onkeyup="moeda()"  Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>
                                                                        <td>Prêmio Meta:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtPremioMeta" runat="server" onkeyup="moeda()" Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>

                                                                        <td>MVP:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtmvp" runat="server" onkeyup="moeda()"  Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>
                                                                        <td>Avulsos:</td>
                                                                        <td>
                                                                            <asp:TextBox ID="txtavulsos" runat="server" onkeyup="moeda()" Style="direction: rtl;" Width="80px"></asp:TextBox>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td></td>
                                                                        <td align="right">
                                                                            

                                                                        </td>
                                                                        <td></td>
                                                                    </tr>


                                                                    <tr>
                                                                        <td></td>
                                                                        <td></td>


                                                                        <td align="right" colspan="2"></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="6" align="right">
                                                                            <div style="width: 100%; height: 1px; background-color: silver; margin-top: 3px; margin-bottom: 12px;"></div>


                                                                            <asp:Button ID="Button6" CssClass="btns" runat="server" Text="Salvar" OnClick="btnSalvarPREM_Click" />
                                                                        </td>
                                                                    </tr>



                                                                </table>
                                                            </fieldset>

                                                        </contenttemplate>
                                                    </asp:UpdatePanel>
                                                    <br />
                                                    <br />
                                                    
                                                </div>

                                            </td>

                                        </tr>

                                    </table>

                                    <asp:SqlDataSource ID="sqldsListarVendedoresPremiacao" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" SelectCommand="gerencia_comissao_listar_vendedores_do_mesPREM" SelectCommandType="StoredProcedure">
                                        <selectparameters>
                                            <asp:ControlParameter ControlID="txtdtInicialPremiacao" DbType="Date" Name="dtInicial" PropertyName="Text" />
                                            <asp:ControlParameter ControlID="txtdtFinalPremiacao" DbType="Date" Name="dtFinal" PropertyName="Text" />
                                        </selectparameters>
                                    </asp:SqlDataSource>

                                </contenttemplate>
                            </asp:TabPanel>

                            <asp:TabPanel ID="TabPanel1" Style="padding: 20px;" runat="server" HeaderText="">
                                <headertemplate>
                                    Arq.Comissões
                                
                                </headertemplate>
                                <contenttemplate>
                                    <table cellspacing="8">
                                        <tr>
                                            <td>Data Inicial:</td>
                                            <td>Data Final:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="TextBox1" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="TextBox1_CalendarExtender" runat="server" Enabled="True" TargetControlID="TextBox1" Format="dd/MM/yyyy">
                                                </asp:CalendarExtender>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="TextBox2" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="TextBox2_CalendarExtender" runat="server" Enabled="True" TargetControlID="TextBox2" Format="dd/MM/yyyy">
                                                </asp:CalendarExtender>
                                                <asp:Button ID="Button2" runat="server" Text="Exibir" OnClick="Button2_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                    <br />
                                    <rsweb:reportviewer id="ReportViewer1" width="100%" runat="server" font-names="Verdana" font-size="8pt" waitmessagefont-names="Verdana" waitmessagefont-size="14pt">
                                        <localreport reportpath="admfinanceiro\Comissao\Report2.rdlc">
                                            <datasources>
                                                <rsweb:reportdatasource datasourceid="sqldsComissaoRV" name="dsComissaoRV" />
                                            </datasources>
                                        </localreport>
                                    </rsweb:reportviewer>



                                    <asp:SqlDataSource ID="sqldsComissaoRV" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" SelectCommand="admfinanceiro_select_comissao" SelectCommandType="StoredProcedure">
                                        <selectparameters>
                                            <asp:ControlParameter ControlID="TextBox1" DbType="Date" DefaultValue="01/09/2014" Name="dtInicial" PropertyName="Text" />
                                            <asp:ControlParameter ControlID="TextBox2" DbType="Date" DefaultValue="01/09/2014" Name="dtFinal" PropertyName="Text" />
                                        </selectparameters>
                                    </asp:SqlDataSource>



                                </contenttemplate>
                            </asp:TabPanel>

                            <asp:TabPanel ID="TabPanel5" Style="padding: 20px;" runat="server" HeaderText="">
                                <headertemplate>
                                    Arq.Premiações
       
                                </headertemplate>
                                <contenttemplate>
                                    <table cellspacing="8">
                                        <tr>
                                            <td>Data Inicial:</td>
                                            <td>Data Final:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="TextBox5" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="CalendarExtender7" runat="server" Enabled="True" TargetControlID="TextBox5" Format="dd/MM/yyyy">
                                                </asp:CalendarExtender>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="TextBox6" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="CalendarExtender8" runat="server" Enabled="True" TargetControlID="TextBox6" Format="dd/MM/yyyy">
                                                </asp:CalendarExtender>
                                                <asp:Button ID="Button7" runat="server" Text="Exibir" OnClick="Button3_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                    <br />
                                    <rsweb:reportviewer id="ReportViewer2" width="100%" runat="server" font-names="Verdana" font-size="8pt" waitmessagefont-names="Verdana" waitmessagefont-size="14pt">
                                        <localreport reportpath="admfinanceiro\Comissao\Report3.rdlc">
                                            <datasources>
                                                <rsweb:reportdatasource datasourceid="sqldsComissaoRV2" name="dsComissaoRV2" />
                                            </datasources>
                                        </localreport>
                                    </rsweb:reportviewer>


                                    <asp:SqlDataSource ID="sqldsComissaoRV2" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" SelectCommand="admfinanceiro_select_comissao" SelectCommandType="StoredProcedure">
                                        <selectparameters>
                                            <asp:ControlParameter ControlID="TextBox5" DbType="Date" DefaultValue="01/09/2014" Name="dtInicial" PropertyName="Text" />
                                            <asp:ControlParameter ControlID="TextBox6" DbType="Date" DefaultValue="01/09/2014" Name="dtFinal" PropertyName="Text" />
                                        </selectparameters>
                                    </asp:SqlDataSource>


                                </contenttemplate>
                            </asp:TabPanel>



                            <asp:TabPanel ID="TabPanel2" Style="padding: 20px;" runat="server" HeaderText="">
                                <headertemplate>
                                    Revisar
                                
                                </headertemplate>
                                <contenttemplate>
                                    <table cellspacing="8">
                                        <tr>
                                            <td>Data Inicial:</td>
                                            <td>Data Final:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="TextBox3" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="CalendarExtender3" runat="server" Enabled="True" TargetControlID="TextBox3" Format="dd/MM/yyyy">
                                                </asp:CalendarExtender>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="TextBox4" CssClass="txts" runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="CalendarExtender4" runat="server" Enabled="True" TargetControlID="TextBox4" Format="dd/MM/yyyy">
                                                </asp:CalendarExtender>
                                                <asp:Button ID="Button3" runat="server" Text="Exibir" />
                                            </td>
                                        </tr>
                                    </table>
                                    <br />
                                    <asp:GridView ID="gViewerRevisar" runat="server" AutoGenerateColumns="False" BackColor="White" BorderColor="#CCCCCC" BorderStyle="None" BorderWidth="1px" CellPadding="4" DataKeyNames="dtInicial,dtFinal,cod_vend" DataSourceID="SqlDsRevisar" ForeColor="Black" GridLines="Horizontal">
                                        <columns>
                                            <asp:CommandField ShowDeleteButton="True" />
                                            <asp:BoundField DataField="id" HeaderText="id" InsertVisible="False" ReadOnly="True" SortExpression="id" />
                                            <asp:BoundField DataField="dtInicial" HeaderText="dtInicial" ReadOnly="True" SortExpression="dtInicial" />
                                            <asp:BoundField DataField="dtFinal" HeaderText="dtFinal" ReadOnly="True" SortExpression="dtFinal" />
                                            <asp:BoundField DataField="vendedor" HeaderText="vendedor" SortExpression="vendedor" />
                                            <asp:BoundField DataField="cod_vend" HeaderText="cod_vend" ReadOnly="True" SortExpression="cod_vend" />
                                            <asp:BoundField DataField="comissaoVN" HeaderText="comissaoVN" SortExpression="comissaoVN" />
                                            <asp:BoundField DataField="comissaoVU" HeaderText="comissaoVU" SortExpression="comissaoVU" />
                                            <asp:BoundField DataField="comissaoVD" HeaderText="comissaoVD" SortExpression="comissaoVD" />
                                            <asp:BoundField DataField="qtde" HeaderText="qtde" SortExpression="qtde" />
                                        </columns>
                                        <footerstyle backcolor="#CCCC99" forecolor="Black" />
                                        <headerstyle backcolor="#333333" font-bold="True" forecolor="White" />
                                        <pagerstyle backcolor="White" forecolor="Black" horizontalalign="Right" />
                                        <selectedrowstyle backcolor="#CC3333" font-bold="True" forecolor="White" />
                                        <sortedascendingcellstyle backcolor="#F7F7F7" />
                                        <sortedascendingheaderstyle backcolor="#4B4B4B" />
                                        <sorteddescendingcellstyle backcolor="#E5E5E5" />
                                        <sorteddescendingheaderstyle backcolor="#242121" />
                                    </asp:GridView>
                                    <asp:SqlDataSource ID="SqlDsRevisar" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" DeleteCommand="DELETE FROM [admfinanceiro_comissao_veiculos] WHERE [dtInicial] = @dtInicial AND [dtFinal] = @dtFinal AND [cod_vend] = @cod_vend" InsertCommand="INSERT INTO [admfinanceiro_comissao_veiculos] ([dtInicial], [dtFinal], [vendedor], [cod_vend], [comissaoVN], [comissaoVU], [comissaoVD], [qtde]) VALUES (@dtInicial, @dtFinal, @vendedor, @cod_vend, @comissaoVN, @comissaoVU, @comissaoVD, @qtde)" SelectCommand="SELECT [id], [dtInicial], [dtFinal], [vendedor], [cod_vend], [comissaoVN], [comissaoVU], [comissaoVD], [qtde] FROM [admfinanceiro_comissao_veiculos] WHERE (([dtInicial] = @dtInicial) AND ([dtFinal] = @dtFinal)) ORDER BY [vendedor]" UpdateCommand="UPDATE [admfinanceiro_comissao_veiculos] SET [id] = @id, [vendedor] = @vendedor, [comissaoVN] = @comissaoVN, [comissaoVU] = @comissaoVU, [comissaoVD] = @comissaoVD, [qtde] = @qtde WHERE [dtInicial] = @dtInicial AND [dtFinal] = @dtFinal AND [cod_vend] = @cod_vend">
                                        <deleteparameters>
                                            <asp:Parameter DbType="Date" Name="dtInicial" />
                                            <asp:Parameter DbType="Date" Name="dtFinal" />
                                            <asp:Parameter Name="cod_vend" Type="String" />
                                        </deleteparameters>
                                        <insertparameters>
                                            <asp:Parameter DbType="Date" Name="dtInicial" />
                                            <asp:Parameter DbType="Date" Name="dtFinal" />
                                            <asp:Parameter Name="vendedor" Type="String" />
                                            <asp:Parameter Name="cod_vend" Type="String" />
                                            <asp:Parameter Name="comissaoVN" Type="Double" />
                                            <asp:Parameter Name="comissaoVU" Type="Double" />
                                            <asp:Parameter Name="comissaoVD" Type="Double" />
                                            <asp:Parameter Name="qtde" Type="Int32" />
                                        </insertparameters>
                                        <selectparameters>
                                            <asp:ControlParameter ControlID="TextBox3" DbType="Date" Name="dtInicial" PropertyName="Text" />
                                            <asp:ControlParameter ControlID="TextBox4" DbType="Date" Name="dtFinal" PropertyName="Text" />
                                        </selectparameters>
                                        <updateparameters>
                                            <asp:Parameter Name="id" Type="Int32" />
                                            <asp:Parameter Name="vendedor" Type="String" />
                                            <asp:Parameter Name="comissaoVN" Type="Double" />
                                            <asp:Parameter Name="comissaoVU" Type="Double" />
                                            <asp:Parameter Name="comissaoVD" Type="Double" />
                                            <asp:Parameter Name="qtde" Type="Int32" />
                                            <asp:Parameter DbType="Date" Name="dtInicial" />
                                            <asp:Parameter DbType="Date" Name="dtFinal" />
                                            <asp:Parameter Name="cod_vend" Type="String" />
                                        </updateparameters>
                                    </asp:SqlDataSource>
                                </contenttemplate>
                            </asp:TabPanel>

                            <asp:TabPanel ID="TabPanel6" Style="padding: 20px;" runat="server" HeaderText="">
                                <headertemplate>
                                    Regras
     
                                </headertemplate>
                                <contenttemplate>
                                    <div style="width: 100%; height: 1px; margin-top: 20px; margin-bottom: 20px; background-color: silver;"></div>

                                    <table cellspacing="5">
                                        <tr>
                                            <td colspan="6" style="background-color: #333333; height: 25px; text-align: center; color: white; font-weight: bold;">REGRAS
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Margem MÍNIMA NOVOS:<br />
                                                0.4 para todos<br />
                                                <br />

                                                <div style="width: 100%; height: 1px; background-color: silver; margin-top: 3px; margin-bottom: 12px;"></div>
                                                ALTERAÇÕES PARA MAIS.<br />
                                                <br />
                                                FIAT SIA: 0.5 se for maior ou igual a 8.<br />
                                                FIAT SCIA: 0.5 se for maior ou igual a 6.<br />
                                                FIAT SAAN: 0.5 se for maior ou igual a 8.<br />
                                                RICARDO TIROU A SOMA DO VU NA COMISSÃO GERAL DIA 20-05-2025.<br />
                                                <br />

                                                JEEP SAAN/PARK SUL: 0.5 pra todo mundo.<br />
                                                Entre 0 a 5 carros : GANHA 0,6 se vender com margem superior a 5,5.
                                                Maior que 6 carros : Ganha 0,6 se vender com margem superior a 5.
                                                
                                                <br />

                                                BALI BYD: 0.5 se for maior ou igual a 13.<br />
                                                <br />
                                                <div style="width: 100%; height: 1px; background-color: silver; margin-top: 3px; margin-bottom: 12px;"></div>
                                                COMISSÕES FIXAS:<br />
                                                <br />
                                                FIAT TORO : 0.6<br />
                                                FIAT TITANO: 0.6<br />
                                                RAM: 0.5<br />
                                                <br />
                                                <div style="width: 100%; height: 1px; background-color: silver; margin-top: 3px; margin-bottom: 12px;"></div>
                                                EMPLACAMENTOS:<br />
                                                <br />

                                                JEEP SAAN, PARK SUL E RAM.( Essa regra existe apenas para essas empresas)
                                                                      <br />
                                                Entre 790 e 979: Ganha 100 reais.<br />
                                                <br />

                                                TODAS OUTRAS EMPRESAS.<br />
                                                <br />
                                                Entre 980 e 1289: Ganha 150 reais.<br />
                                                Maior que 1290: Ganha 200 reais.<br />
                                                <br />
                                                <div style="width: 100%; height: 1px; background-color: silver; margin-top: 3px; margin-bottom: 12px;"></div>
                                                CÁLCULO DE SEMINOVOS.<br />
                                                <br />
                                                Valorliquido = (ValorVenda - Duplicata - Recibo)<br />
                                                Margem = (1-((Precopublico - Liquido)/Precopublico*10))<br />
                                                Comissao = Liquido * Margem/100<br />
                                                <br />

                                                Limite máximo de margem: 1%<br />
                                                Limite mínimo de margem: 0.35%<br /><br />
                                                <div style="width: 100%; height: 1px; background-color: silver; margin-top: 3px; margin-bottom: 12px;"></div>
                                                DIA 18-09-2025 RICARDO DEFINIU COMISSÃO DE 0,3 PARA TODOS VEÍCULOS COM MARGEM ABAIXO DE 3% NA BYD<br /><br /> 
                                                DIA 18/12/2025 Ricardo DEFINIU PARA COMISSÃO JEEP:<br />
                                                0 A 5 CARROS VENDIDOS: COMISSÃO 0,5. SE A MARGEM FOR IGUAL OU SUPERIOR A 5,5% GANHA 0,6.<br /> 
                                                A PARTIR DE 6 CARROS VENDIDOS : COMISSÃO 0,5. SE A MARGEM FOR IGUAL OU SUPERIOR A 5% GANHA 0,6
                                                
                                            </td>
                                        </tr>
                                        <tr>
                                            <td></td>
                                            <td></td>
                                            <td align="right" colspan="2"></td>
                                        </tr>
                                        <tr>
                                            <td colspan="6" align="right">
                                                <div style="width: 100%; height: 1px; background-color: silver; margin-top: 3px; margin-bottom: 12px;"></div>
                                            </td>
                                        </tr>
                                    </table>
                                </contenttemplate>
                            </asp:TabPanel>
                        </asp:TabContainer>
                    </td>
                </tr>
            </table>
            </div>
        </div>
        <div id="ag" class="comissao-loading" aria-live="polite" aria-hidden="true">
            <div class="comissao-loading-card">
                <span class="comissao-spinner"></span>
                <strong>Processando informa&ccedil;&otilde;es</strong>
                <small>Aguarde enquanto a tela atualiza os dados.</small>
                <button type="button" onclick="fecharAguarde();">Cancelar</button>

            </div>
        </div>

    </form>
</body>
</html>

<script type="text/javascript">
    function RecalcularComissao() {
        var m = document.getElementById('margem').value;
        var liquido = parseFloat(document.getElementById('TabContainercomissao_TabPanelComissaoGeral_txtTotalLiquido').value);
        if (m == 5) {
            //var m = document.form.margem.selectedIndex;
            var r = parseFloat(liquido) * 5 / 1000;
        }
        if (m == 6) {
            //var m = document.form.margem.selectedIndex;
            var r = parseFloat(liquido) * 6 / 1000;
        }
        if (m == 7) {
            //var m = document.form.margem.selectedIndex;
            var r = (parseFloat(liquido) * 7 / 1000).toFixed(2);
        }
        alert(r);
    }



</script>

<%--<script language="javascript" type="text/jscript">
    function imprimePanel() {
        var printContent = document.getElementById("<%=print.ClientID%>");
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

</script>--%>
