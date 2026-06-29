<%@ Page Language="C#" AutoEventWireup="true" CodeFile="minhas-vendas.aspx.cs" Inherits="minhas_vendas" Culture="pt-BR" UICulture="pt-BR" EnableViewState="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Minhas vendas | Grupo Bali</title>
    <link href="css/minhas-vendas.css?v=20260629-tabela01" rel="stylesheet" />
    <script src="js/minhas-vendas.js?v=20260629-tabela01" defer="defer"></script>
</head>
<body id="pageBody" runat="server" class="sales-bi-page brand-fiat">
    <form id="form1" runat="server">
        <div class="sales-shell">
            <header class="sales-topbar">
                <div class="sales-brand-block">
                    <a id="lnkVoltarTopo" runat="server" class="sales-brand-link">
                        <asp:Image ID="imgLogo" runat="server" AlternateText="Grupo Bali" />
                        <span>
                            <strong><asp:Literal ID="litMarcaTopo" runat="server" /></strong>
                            <small>Minhas vendas</small>
                        </span>
                    </a>
                </div>
                <div class="sales-user-block">
                    <span>Usu&aacute;rio: <strong><asp:Label ID="lblUsuario" runat="server" /></strong></span>
                    <asp:HyperLink ID="lnkVoltar" runat="server" CssClass="sales-light-button">Voltar</asp:HyperLink>
                    <asp:HyperLink ID="lnkSair" runat="server" CssClass="sales-logout-button">Sair</asp:HyperLink>
                </div>
            </header>

            <main class="sales-main">
                <section class="sales-hero">
                    <div>
                        <span class="sales-eyebrow"><asp:Literal ID="litEyebrow" runat="server" /></span>
                        <h1>Minhas vendas</h1>
                        <p>Acompanhe sua performance por per&iacute;odo com vendas, devolu&ccedil;&otilde;es, ticket m&eacute;dio, margem e detalhes dos ve&iacute;culos faturados.</p>
                    </div>
                    <div class="sales-hero-meta">
                        <span>C&oacute;digo do vendedor</span>
                        <strong><asp:Label ID="lblCodigoVendedor" runat="server" Text="-" /></strong>
                    </div>
                </section>

                <asp:Panel ID="pnlAviso" runat="server" Visible="false" CssClass="sales-alert">
                    <strong>Aten&ccedil;&atilde;o</strong>
                    <asp:Literal ID="litAviso" runat="server" />
                </asp:Panel>

                <section class="sales-filter-card">
                    <div class="sales-section-heading">
                        <span>Filtros</span>
                        <h2>Per&iacute;odo da consulta</h2>
                    </div>
                    <div class="sales-filter-grid">
                        <label>
                            <span>Data inicial</span>
                            <asp:TextBox ID="txtDataInicial" runat="server" TextMode="Date" CssClass="sales-input" />
                        </label>
                        <label>
                            <span>Data final</span>
                            <asp:TextBox ID="txtDataFinal" runat="server" TextMode="Date" CssClass="sales-input" />
                        </label>
                        <asp:Button ID="btnFiltrar" runat="server" Text="Atualizar BI" CssClass="sales-primary-button" OnClick="btnFiltrar_Click" />
                    </div>
                    <div class="sales-filter-actions">
                        <asp:LinkButton ID="lnkMesAtual" runat="server" CssClass="sales-chip" CommandArgument="mes" OnCommand="PeriodoRapido_Command">Este m&ecirc;s</asp:LinkButton>
                        <asp:LinkButton ID="lnkMesAnterior" runat="server" CssClass="sales-chip" CommandArgument="mesAnterior" OnCommand="PeriodoRapido_Command">M&ecirc;s anterior</asp:LinkButton>
                        <asp:LinkButton ID="lnkUltimos30" runat="server" CssClass="sales-chip" CommandArgument="ultimos30" OnCommand="PeriodoRapido_Command">&Uacute;ltimos 30 dias</asp:LinkButton>
                        <asp:LinkButton ID="lnkHoje" runat="server" CssClass="sales-chip" CommandArgument="hoje" OnCommand="PeriodoRapido_Command">Hoje</asp:LinkButton>
                    </div>
                </section>

                <asp:Panel ID="pnlConteudo" runat="server" CssClass="sales-content">
                    <div class="sales-period-line">
                        <asp:Label ID="lblPeriodo" runat="server" />
                    </div>

                    <section class="sales-comparison-grid" aria-label="Comparativo com per&iacute;odo anterior">
                        <asp:Literal ID="litComparativo" runat="server" />
                    </section>

                    <section class="sales-kpi-grid" aria-label="Resumo de vendas">
                        <article class="sales-kpi-card">
                            <span>Unidades l&iacute;quidas</span>
                            <strong><asp:Label ID="lblTotalUnidades" runat="server" /></strong>
                            <small>Vendas menos devolu&ccedil;&otilde;es</small>
                        </article>
                        <article class="sales-kpi-card">
                            <span>Valor l&iacute;quido</span>
                            <strong><asp:Label ID="lblValorTotal" runat="server" /></strong>
                            <small>Total faturado no per&iacute;odo</small>
                        </article>
                        <article class="sales-kpi-card">
                            <span>Ticket m&eacute;dio</span>
                            <strong><asp:Label ID="lblTicketMedio" runat="server" /></strong>
                            <small>Valor m&eacute;dio por unidade</small>
                        </article>
                        <article class="sales-kpi-card">
                            <span>Margem m&eacute;dia</span>
                            <strong><asp:Label ID="lblMargemMedia" runat="server" /></strong>
                            <small>M&eacute;dia das notas exibidas</small>
                        </article>
                        <article class="sales-kpi-card">
                            <span>Notas</span>
                            <strong><asp:Label ID="lblQtdNotas" runat="server" /></strong>
                            <small>Registros encontrados</small>
                        </article>
                        <article class="sales-kpi-card">
                            <span>Dias com venda</span>
                            <strong><asp:Label ID="lblDiasAtivos" runat="server" /></strong>
                            <small>Atividade no per&iacute;odo</small>
                        </article>
                        <article class="sales-kpi-card">
                            <span>Vendas brutas</span>
                            <strong><asp:Label ID="lblVendasBrutas" runat="server" /></strong>
                            <small>Antes de devolu&ccedil;&otilde;es</small>
                        </article>
                        <article class="sales-kpi-card">
                            <span>Devolu&ccedil;&otilde;es</span>
                            <strong><asp:Label ID="lblDevolucoes" runat="server" /></strong>
                            <small>Notas de retorno</small>
                        </article>
                        <article class="sales-kpi-card">
                            <span>Clientes</span>
                            <strong><asp:Label ID="lblClientesUnicos" runat="server" /></strong>
                            <small>Clientes diferentes no per&iacute;odo</small>
                        </article>
                        <article class="sales-kpi-card">
                            <span>Melhor dia</span>
                            <strong><asp:Label ID="lblMelhorDia" runat="server" /></strong>
                            <small>Maior volume l&iacute;quido</small>
                        </article>
                        <article class="sales-kpi-card sales-kpi-card-wide">
                            <span>Maior venda</span>
                            <strong><asp:Label ID="lblMaiorVenda" runat="server" /></strong>
                            <small><asp:Label ID="lblMaiorVendaDetalhe" runat="server" /></small>
                        </article>
                    </section>

                    <section class="sales-dashboard-grid">
                        <article class="sales-chart-card sales-chart-wide">
                            <div class="sales-card-heading">
                                <span>Evolu&ccedil;&atilde;o</span>
                                <h2>Vendas por dia</h2>
                            </div>
                            <asp:Literal ID="litGraficoDiario" runat="server" />
                        </article>
                        <article class="sales-chart-card">
                            <div class="sales-card-heading">
                                <span>Unidades</span>
                                <h2>Por loja</h2>
                            </div>
                            <asp:Literal ID="litLojas" runat="server" />
                        </article>
                        <article class="sales-chart-card">
                            <div class="sales-card-heading">
                                <span>Estoque</span>
                                <h2>Por tipo</h2>
                            </div>
                            <asp:Literal ID="litTipos" runat="server" />
                        </article>
                    </section>

                    <section class="sales-table-card">
                        <div class="sales-table-header">
                            <div class="sales-card-heading">
                                <span>Detalhamento</span>
                                <h2>Vendas encontradas</h2>
                            </div>
                            <div class="sales-table-tools" aria-label="Ferramentas da tabela">
                                <label>
                                    <span>Buscar</span>
                                    <input id="salesTableSearch" type="search" autocomplete="off" autocapitalize="off" spellcheck="false" placeholder="Cliente, chassi, placa, nota ou pedido" />
                                </label>
                                <label>
                                    <span>Linhas</span>
                                    <select id="salesPageSize">
                                        <option value="10">10</option>
                                        <option value="25" selected="selected">25</option>
                                        <option value="50">50</option>
                                        <option value="all">Todas</option>
                                    </select>
                                </label>
                            </div>
                        </div>
                        <div class="sales-table-wrap">
                            <asp:GridView ID="gvVendas" runat="server" AutoGenerateColumns="false" CssClass="sales-table" GridLines="None" OnRowDataBound="gvVendas_RowDataBound" EmptyDataText="Nenhuma venda encontrada para este vendedor no per&iacute;odo selecionado.">
                                <Columns>
                                    <asp:BoundField DataField="datavenda" HeaderText="Data" DataFormatString="{0:dd/MM/yyyy}" />
                                    <asp:BoundField DataField="notafiscal" HeaderText="Nota fiscal" />
                                    <asp:BoundField DataField="pedidodoveiculo" HeaderText="Pedido" />
                                    <asp:BoundField DataField="loja" HeaderText="Loja" />
                                    <asp:BoundField DataField="NomeCliente" HeaderText="Cliente" />
                                    <asp:BoundField DataField="modeloveiculo" HeaderText="Modelo" />
                                    <asp:BoundField DataField="tipoestoque" HeaderText="Tipo" />
                                    <asp:BoundField DataField="qtde" HeaderText="Qtde" DataFormatString="{0:N0}" />
                                    <asp:BoundField DataField="ValordeVenda" HeaderText="Valor" DataFormatString="{0:C}" />
                                    <asp:BoundField DataField="Margem" HeaderText="Margem" DataFormatString="{0:N2}%" />
                                    <asp:BoundField DataField="chassi" HeaderText="Chassi" />
                                    <asp:BoundField DataField="placa" HeaderText="Placa" />
                                </Columns>
                            </asp:GridView>
                        </div>
                        <div class="sales-table-footer">
                            <span id="salesTableCounter">Carregando tabela...</span>
                            <div class="sales-pagination" aria-label="Pagina&ccedil;&atilde;o da tabela">
                                <button id="salesPrevPage" type="button">Anterior</button>
                                <span id="salesPageInfo">-</span>
                                <button id="salesNextPage" type="button">Pr&oacute;xima</button>
                            </div>
                        </div>
                    </section>
                </asp:Panel>
            </main>
        </div>
    </form>
</body>
</html>
