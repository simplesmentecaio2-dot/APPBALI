<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ControleAcessorios.aspx.cs" Inherits="tecnologia_ControleAcessorios" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Controle de acess&oacute;rios | Tecnologia</title>
    <link href="../css/bali-tecnologia.css?v=20260628-sessoes01" rel="stylesheet" />
    <style>
        .accessory-summary {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 12px;
            margin-bottom: 14px;
        }

        .accessory-summary article {
            border: 1px solid var(--tech-line);
            border-radius: var(--tech-radius);
            background: #fff;
            box-shadow: 0 12px 26px rgba(15, 23, 42, .06);
            padding: 14px;
        }

        .accessory-summary span,
        .accessory-table small {
            display: block;
            color: var(--tech-muted);
            font-size: 11px;
            font-weight: 900;
            line-height: 1.35;
        }

        .accessory-summary strong {
            display: block;
            color: var(--tech-ink);
            font-size: 24px;
            font-weight: 950;
            line-height: 1;
            margin-top: 8px;
        }

        .accessory-alert {
            border: 1px solid var(--tech-line);
            border-radius: var(--tech-radius);
            margin: 0 0 12px;
            padding: 12px 14px;
            font-size: 13px;
            font-weight: 850;
        }

        .accessory-alert.is-success {
            border-color: rgba(25, 169, 116, .26);
            background: #ecfdf3;
            color: #047857;
        }

        .accessory-alert.is-error {
            border-color: rgba(220, 38, 38, .20);
            background: #fff1f2;
            color: #9f1239;
        }

        .accessory-tools {
            display: grid;
            grid-template-columns: minmax(150px, 190px) minmax(190px, 250px) minmax(170px, 220px) minmax(260px, 1fr);
            align-items: end;
            gap: 14px;
            margin-bottom: 14px;
        }

        .accessory-buttons {
            display: flex;
            flex-wrap: wrap;
            justify-content: flex-end;
            gap: 8px;
        }

        .accessory-table-wrap {
            overflow-x: auto;
            border-radius: var(--tech-radius);
        }

        .accessory-table {
            min-width: 1280px;
        }

        .accessory-table td {
            vertical-align: top;
        }

        .accessory-table strong {
            display: block;
            color: var(--tech-ink);
            font-size: 12px;
            font-weight: 950;
        }

        .accessory-table code {
            color: var(--tech-brand-strong);
            font-size: 11px;
            font-weight: 900;
        }

        .accessory-row.is-issued td {
            background: #eefaf2 !important;
        }

        .accessory-row.is-issued:hover td {
            background: #e5f6eb !important;
        }

        .accessory-row.is-overdue td {
            background: #fff1f2 !important;
        }

        .accessory-row.is-due-soon td {
            background: #fffbeb !important;
        }

        .accessory-check {
            width: 46px;
            text-align: center !important;
        }

        .accessory-check input {
            width: 17px;
            height: 17px;
            accent-color: var(--tech-brand);
            cursor: pointer;
        }

        .accessory-status {
            display: inline-flex;
            align-items: center;
            min-height: 26px;
            padding: 0 9px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 950;
            white-space: nowrap;
        }

        .accessory-status.is-issued {
            background: #dcfce7;
            color: #047857;
        }

        .accessory-status.is-pending {
            background: #fff7ed;
            color: #c2410c;
        }

        .accessory-mark small {
            margin-top: 4px;
        }

        .accessory-due {
            display: inline-flex;
            align-items: center;
            min-height: 22px;
            margin-top: 5px;
            padding: 0 8px;
            border-radius: 999px;
            font-size: 10px;
            font-weight: 950;
        }

        .accessory-due.is-overdue {
            background: #ffe4e6;
            color: #be123c;
        }

        .accessory-due.is-today,
        .accessory-due.is-soon {
            background: #fef3c7;
            color: #b45309;
        }

        .accessory-operation-fields {
            display: grid;
            grid-template-columns: minmax(220px, 1fr) minmax(160px, 240px);
            gap: 10px;
            margin-bottom: 14px;
        }

        .accessory-mini-link {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 28px;
            border: 1px solid rgba(47, 111, 189, .18);
            border-radius: var(--tech-radius);
            background: rgba(47, 111, 189, .08);
            color: var(--tech-brand);
            font-size: 11px;
            font-weight: 950;
            padding: 0 9px;
            text-decoration: none;
            white-space: nowrap;
        }

        .accessory-mini-link.is-copy {
            border-color: rgba(15, 23, 42, .12);
            background: #fff;
            color: var(--tech-ink);
            cursor: pointer;
        }

        .accessory-quick-filters,
        .accessory-pager {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 8px;
            margin: 0 0 14px;
        }

        .accessory-quick-filters button,
        .accessory-pager button,
        .accessory-pager select {
            min-height: 32px;
            border: 1px solid var(--tech-line);
            border-radius: var(--tech-radius);
            background: #fff;
            color: var(--tech-muted);
            cursor: pointer;
            font-size: 11px;
            font-weight: 950;
            padding: 0 10px;
        }

        .accessory-pager {
            justify-content: space-between;
            border: 1px solid var(--tech-line);
            border-radius: var(--tech-radius);
            background: #fbfdff;
            padding: 8px 10px;
        }

        .accessory-pager-info {
            color: var(--tech-muted);
            font-size: 11px;
            font-weight: 900;
        }

        .accessory-dashboard-grid,
        .accessory-dashboard-list {
            display: grid;
            gap: 12px;
        }

        .accessory-dashboard-grid {
            grid-template-columns: repeat(4, minmax(0, 1fr));
            margin-bottom: 14px;
        }

        .accessory-dashboard-card,
        .accessory-list-card {
            border: 1px solid var(--tech-line);
            border-radius: var(--tech-radius);
            background: #fff;
            box-shadow: 0 12px 24px rgba(15, 23, 42, .05);
            padding: 14px;
        }

        .accessory-dashboard-card span,
        .accessory-list-card span,
        .accessory-list-card small {
            display: block;
            color: var(--tech-muted);
            font-size: 11px;
            font-weight: 900;
            line-height: 1.35;
        }

        .accessory-dashboard-card strong {
            display: block;
            color: var(--tech-ink);
            font-size: 24px;
            font-weight: 950;
            margin-top: 8px;
        }

        .accessory-dashboard-list {
            grid-template-columns: repeat(2, minmax(0, 1fr));
            margin-top: 12px;
        }

        .accessory-list-card {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: 12px;
            align-items: center;
        }

        .accessory-list-card strong {
            color: var(--tech-ink);
            font-size: 14px;
            font-weight: 950;
        }

        .accessory-list-card code {
            color: var(--tech-brand-strong);
            font-size: 11px;
            font-weight: 900;
        }

        .accessory-history {
            border: 1px solid var(--tech-line);
            border-radius: var(--tech-radius);
            background: #fff;
            margin: 0 0 14px;
            padding: 14px;
        }

        .accessory-history h3 {
            margin: 0;
            color: var(--tech-ink);
            font-size: 17px;
            font-weight: 950;
        }

        .accessory-history-list {
            display: grid;
            gap: 8px;
            margin-top: 10px;
        }

        .accessory-history-item {
            border: 1px solid #edf2f7;
            border-radius: var(--tech-radius);
            background: #fbfdff;
            padding: 10px;
        }

        .accessory-history-item strong,
        .accessory-history-item span,
        .accessory-history-item small {
            display: block;
        }

        .accessory-history-item strong {
            color: var(--tech-ink);
            font-size: 13px;
            font-weight: 950;
        }

        .accessory-history-item span,
        .accessory-history-item small {
            color: var(--tech-muted);
            font-size: 11px;
            font-weight: 800;
            margin-top: 3px;
        }

        .accessory-tabs {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin: 0 0 14px;
        }

        .accessory-section-title {
            color: var(--tech-ink);
            font-size: 16px;
            font-weight: 950;
            margin: 18px 0 10px;
        }

        .accessory-tab-button {
            min-height: 38px;
            border: 1px solid var(--tech-line);
            border-radius: var(--tech-radius);
            background: #fff;
            color: var(--tech-muted);
            cursor: pointer;
            font-size: 12px;
            font-weight: 950;
            padding: 0 14px;
        }

        .accessory-tab-button.is-active {
            border-color: rgba(47, 111, 189, .30);
            background: var(--tech-brand);
            color: #fff;
        }

        .accessory-tab-panel[hidden] {
            display: none !important;
        }

        .accessory-report {
            border: 1px solid var(--tech-line);
            border-radius: var(--tech-radius);
            background: #fff;
            margin-top: 16px;
            overflow: hidden;
        }

        .accessory-report-head {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: 14px;
            align-items: start;
            border-bottom: 1px solid #edf2f7;
            padding: 16px;
        }

        .accessory-report-head h3 {
            margin: 0;
            color: var(--tech-ink);
            font-size: 20px;
            font-weight: 950;
        }

        .accessory-report-head p {
            margin: 6px 0 0;
            color: var(--tech-muted);
            font-size: 12px;
            font-weight: 780;
            line-height: 1.4;
        }

        .accessory-report-total {
            min-width: 190px;
            border: 1px solid rgba(25, 169, 116, .22);
            border-radius: var(--tech-radius);
            background: #ecfdf3;
            padding: 12px;
            text-align: right;
        }

        .accessory-report-total span {
            display: block;
            color: #047857;
            font-size: 10px;
            font-weight: 950;
            letter-spacing: .06em;
            text-transform: uppercase;
        }

        .accessory-report-total strong {
            display: block;
            color: #065f46;
            font-size: 24px;
            font-weight: 950;
            margin-top: 5px;
        }

        .accessory-report-meta {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 8px;
            padding: 12px 16px;
            border-bottom: 1px solid #edf2f7;
            background: #fbfdff;
        }

        .accessory-report-meta span {
            display: block;
            color: var(--tech-muted);
            font-size: 10px;
            font-weight: 950;
            letter-spacing: .06em;
            text-transform: uppercase;
        }

        .accessory-report-meta strong {
            display: block;
            color: var(--tech-ink);
            font-size: 12px;
            font-weight: 950;
            margin-top: 4px;
            overflow-wrap: anywhere;
        }

        .accessory-report-body {
            padding: 16px;
        }

        .accessory-report-table {
            width: 100%;
            border-collapse: collapse;
        }

        .accessory-report-table th,
        .accessory-report-table td {
            border-bottom: 1px solid #e5edf5;
            padding: 8px 7px;
            color: var(--tech-ink);
            font-size: 12px;
            text-align: left;
        }

        .accessory-report-table th {
            background: #f6f9fc;
            color: var(--tech-muted);
            font-size: 10px;
            font-weight: 950;
            letter-spacing: .04em;
            text-transform: uppercase;
        }

        .accessory-report-actions {
            display: flex;
            flex-wrap: wrap;
            justify-content: flex-end;
            gap: 8px;
            padding: 0 16px 16px;
        }

        .accessory-report-filters {
            display: grid;
            grid-template-columns: minmax(170px, 220px) minmax(170px, 220px) auto auto auto;
            gap: 10px;
            align-items: end;
            margin-bottom: 14px;
        }

        .accessory-lot-list {
            display: grid;
            gap: 8px;
            margin-bottom: 14px;
        }

        .accessory-lot-item {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: 10px;
            border: 1px solid var(--tech-line);
            border-radius: var(--tech-radius);
            background: #fff;
            padding: 10px 12px;
        }

        .accessory-lot-item strong,
        .accessory-lot-item span {
            display: block;
        }

        .accessory-lot-item strong {
            color: var(--tech-ink);
            font-size: 13px;
            font-weight: 950;
        }

        .accessory-lot-item span,
        .accessory-lot-item small {
            color: var(--tech-muted);
            font-size: 11px;
            font-weight: 800;
        }

        .accessory-busy {
            position: fixed;
            inset: 0;
            z-index: 9999;
            display: none;
            place-items: center;
            background: rgba(15, 23, 42, .38);
            backdrop-filter: blur(2px);
        }

        .accessory-busy.is-visible {
            display: grid;
        }

        .accessory-busy-box {
            border: 1px solid rgba(255, 255, 255, .45);
            border-radius: var(--tech-radius);
            background: #fff;
            box-shadow: 0 24px 60px rgba(15, 23, 42, .22);
            color: var(--tech-ink);
            font-size: 14px;
            font-weight: 950;
            padding: 18px 22px;
        }

        @media (max-width: 980px) {
            .accessory-summary {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .accessory-dashboard-grid,
            .accessory-dashboard-list {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .accessory-tools {
                grid-template-columns: 1fr;
            }

            .accessory-buttons {
                justify-content: stretch;
            }

            .accessory-buttons input {
                flex: 1 1 180px;
            }

            .accessory-operation-fields,
            .accessory-report-head,
            .accessory-report-meta,
            .accessory-report-filters,
            .accessory-lot-item {
                grid-template-columns: 1fr;
            }

            .accessory-report-total {
                text-align: left;
            }
        }

        @media (max-width: 560px) {
            .accessory-summary,
            .accessory-dashboard-grid,
            .accessory-dashboard-list {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body class="bali-tech-page">
    <form id="form1" runat="server" autocomplete="off">
        <header class="tech-topbar">
            <a class="tech-brand" href="Default.aspx" aria-label="Voltar para tecnologia">
                <img src="../img/logobali.png?v=20260624-logo2" alt="Bali" />
                <span>APP</span>
            </a>
            <div class="tech-user">
                <span>Tecnologia</span>
                <strong><asp:Label ID="lblUsuario" runat="server" /></strong>
                <small>C&oacute;digo: <asp:Label ID="lblCodigo" runat="server" /></small>
            </div>
            <nav class="tech-actions" aria-label="A&ccedil;&otilde;es r&aacute;pidas">
                <a href="Default.aspx">Voltar</a>
                <a href="../login.aspx?sair=1">Sair</a>
            </nav>
        </header>

        <main class="tech-main">
            <section class="tech-hero">
                <div>
                    <span class="tech-eyebrow">Acess&oacute;rios &middot; Notas fiscais</span>
                    <h1>Controle de acess&oacute;rios</h1>
                    <p>Acompanhe os lan&ccedil;amentos em aberto do fornecedor de acess&oacute;rios e marque as linhas em que as NFs j&aacute; foram emitidas.</p>
                </div>
                <label class="tech-search" for="accessorySearch">
                    <span>Buscar na listagem</span>
                    <input id="accessorySearch" type="search" autocomplete="off" autocapitalize="off" spellcheck="false" placeholder="Ex.: chassi, loja, fornecedor, ve&iacute;culo" />
                </label>
            </section>

            <section class="accessory-summary" aria-label="Resumo do controle">
                <article>
                    <span>Total em aberto</span>
                    <strong><asp:Literal ID="litTotal" runat="server" /></strong>
                    <small>Retorno atual da query</small>
                </article>
                <article>
                    <span>NFs emitidas</span>
                    <strong><asp:Literal ID="litEmitidos" runat="server" /></strong>
                    <small>J&aacute; marcadas no controle</small>
                </article>
                <article>
                    <span>Pendentes</span>
                    <strong><asp:Literal ID="litPendentes" runat="server" /></strong>
                    <small>Ainda sem marca&ccedil;&atilde;o</small>
                </article>
                <article>
                    <span>Saldo pendente</span>
                    <strong><asp:Literal ID="litSaldoPendente" runat="server" /></strong>
                    <small>Somente linhas pendentes</small>
                </article>
                <article>
                    <span>Primeiro vencimento</span>
                    <strong><asp:Literal ID="litPrimeiroVencimento" runat="server" /></strong>
                    <small><asp:Literal ID="litAtualizacao" runat="server" /></small>
                </article>
            </section>

            <div class="accessory-tabs" role="tablist" aria-label="Controle de acess&oacute;rios">
                <button type="button" class="accessory-tab-button is-active" data-accessory-tab="operacao">Opera&ccedil;&atilde;o</button>
                <button type="button" class="accessory-tab-button" data-accessory-tab="dashboard">Dashboard</button>
                <button type="button" class="accessory-tab-button" data-accessory-tab="pendencias">Pend&ecirc;ncias</button>
                <button type="button" class="accessory-tab-button" data-accessory-tab="conciliacao">Concilia&ccedil;&atilde;o</button>
                <button type="button" class="accessory-tab-button" data-accessory-tab="auditoria">Auditoria</button>
                <button type="button" class="accessory-tab-button" data-accessory-tab="reimpressao">Reimpress&atilde;o</button>
            </div>

            <section class="tech-panel accessory-tab-panel" id="tab-dashboard" data-accessory-tab-panel="dashboard" hidden>
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">BI operacional</span>
                        <h2>Resumo do controle</h2>
                        <p>Vis&atilde;o r&aacute;pida de pend&ecirc;ncias, vencimentos, valores e lojas com maior volume para priorizar o trabalho.</p>
                    </div>
                </div>

                <div class="accessory-dashboard-grid">
                    <article class="accessory-dashboard-card"><span>Total aberto</span><strong><asp:Literal ID="litDashboardTotal" runat="server" /></strong></article>
                    <article class="accessory-dashboard-card"><span>Pendentes</span><strong><asp:Literal ID="litDashboardPendentes" runat="server" /></strong></article>
                    <article class="accessory-dashboard-card"><span>Vencidos</span><strong><asp:Literal ID="litDashboardVencidos" runat="server" /></strong></article>
                    <article class="accessory-dashboard-card"><span>Vence hoje</span><strong><asp:Literal ID="litDashboardHoje" runat="server" /></strong></article>
                    <article class="accessory-dashboard-card"><span>Pr&oacute;ximos 7 dias</span><strong><asp:Literal ID="litDashboardSemana" runat="server" /></strong></article>
                    <article class="accessory-dashboard-card"><span>Valor pendente</span><strong><asp:Literal ID="litDashboardValorPendente" runat="server" /></strong></article>
                    <article class="accessory-dashboard-card"><span>Valor emitido</span><strong><asp:Literal ID="litDashboardValorEmitido" runat="server" /></strong></article>
                    <article class="accessory-dashboard-card"><span>Conciliados</span><strong><asp:Literal ID="litDashboardResolvidos" runat="server" /></strong></article>
                </div>

                <div class="accessory-dashboard-list">
                    <asp:Repeater ID="rptResumoLojas" runat="server" EnableViewState="false">
                        <ItemTemplate>
                            <article class="accessory-list-card">
                                <div>
                                    <span>Loja</span>
                                    <strong><%# Html(Eval("Loja")) %></strong>
                                    <small><%# Html(Eval("Pendentes")) %> pendente(s) de <%# Html(Eval("Total")) %> lan&ccedil;amento(s)</small>
                                </div>
                                <div>
                                    <span>Valor pendente</span>
                                    <strong><%# Moeda(Eval("ValorPendente")) %></strong>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <h3 class="accessory-section-title">Aten&ccedil;&atilde;o</h3>
                <div class="accessory-dashboard-list">
                    <asp:Repeater ID="rptAtencao" runat="server" EnableViewState="false">
                        <ItemTemplate>
                            <article class="accessory-list-card">
                                <div>
                                    <span><%# Html(Eval("Loja")) %> &middot; vencimento <%# Html(Eval("DataVencimento")) %></span>
                                    <strong><%# Html(Eval("Fornecedor")) %></strong>
                                    <code><%# Html(Eval("Veiculo_Chassi")) %></code>
                                    <%# DiasEmAbertoTexto(Eval("Emitido"), Eval("DiasEmAberto")) %>
                                </div>
                                <strong><%# Moeda(Eval("Saldo")) %></strong>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <asp:Panel ID="pnlSemAtencao" runat="server" CssClass="tech-empty" Visible="false">
                    Nenhuma pend&ecirc;ncia cr&iacute;tica encontrada.
                </asp:Panel>
            </section>

            <section class="tech-panel accessory-tab-panel" id="tab-pendencias" data-accessory-tab-panel="pendencias" hidden>
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Relat&oacute;rio de pend&ecirc;ncias</span>
                        <h2>Itens ainda sem NF emitida</h2>
                        <p>Lista focada somente no que falta resolver, ordenada pelo vencimento mais antigo.</p>
                    </div>
                </div>

                <div class="accessory-table-wrap">
                    <asp:Repeater ID="rptPendencias" runat="server" EnableViewState="false">
                        <HeaderTemplate>
                            <table class="tech-table accessory-table">
                                <thead><tr><th>Vencimento</th><th>Loja</th><th>Lan&ccedil;amento</th><th>Fornecedor</th><th>Ve&iacute;culo</th><th>Valor</th><th>A&ccedil;&otilde;es</th></tr></thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                                    <tr>
                                        <td><strong><%# Html(Eval("DataVencimento")) %></strong><%# DiasEmAbertoTexto(Eval("Emitido"), Eval("DiasEmAberto")) %></td>
                                        <td><%# Html(Eval("Loja")) %></td>
                                        <td><strong><%# Html(Eval("Lancamento")) %></strong><small>T&iacute;tulo <%# Html(Eval("NumeroTitulo")) %></small></td>
                                        <td><%# Html(Eval("Fornecedor")) %></td>
                                        <td><strong><%# Html(Eval("Veiculo")) %></strong><code><%# Html(Eval("Veiculo_Chassi")) %></code></td>
                                        <td><strong><%# Moeda(Eval("Saldo")) %></strong></td>
                                        <td>
                                            <button type="button" class="accessory-mini-link is-copy" data-copy="<%# Chave(Eval("Veiculo_Chassi")) %>">copiar chassi</button>
                                            <a class="accessory-mini-link" href="<%# UrlHistorico(Eval("ChaveControle")) %>">hist&oacute;rico</a>
                                        </td>
                                    </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
                <asp:Panel ID="pnlSemPendencias" runat="server" CssClass="tech-empty" Visible="false">
                    Nenhuma pend&ecirc;ncia encontrada.
                </asp:Panel>
            </section>

            <section class="tech-panel accessory-tab-panel" id="tab-conciliacao" data-accessory-tab-panel="conciliacao" hidden>
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Concilia&ccedil;&atilde;o</span>
                        <h2>Itens marcados que sa&iacute;ram da query</h2>
                        <p>Quando uma linha marcada como NF emitida deixa de aparecer no sistema, ela entra aqui como prov&aacute;vel baixa/resolu&ccedil;&atilde;o.</p>
                    </div>
                </div>

                <div class="accessory-table-wrap">
                    <asp:Repeater ID="rptConciliados" runat="server" EnableViewState="false">
                        <HeaderTemplate>
                            <table class="tech-table accessory-table">
                                <thead><tr><th>Atualizado</th><th>Loja</th><th>Lan&ccedil;amento</th><th>Fornecedor</th><th>Ve&iacute;culo</th><th>Valor</th><th>Marcado por</th></tr></thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                                    <tr>
                                        <td><%# DataHora(Eval("AtualizadoEm")) %></td>
                                        <td><%# Html(Eval("Loja")) %></td>
                                        <td><strong><%# Html(Eval("Lancamento")) %></strong><small>T&iacute;tulo <%# Html(Eval("NumeroTitulo")) %></small></td>
                                        <td><%# Html(Eval("Fornecedor")) %></td>
                                        <td><strong><%# Html(Eval("Veiculo")) %></strong><code><%# Html(Eval("VeiculoChassi")) %></code></td>
                                        <td><strong><%# Moeda(Eval("ValorNF")) %></strong></td>
                                        <td><%# Html(Eval("UsuarioNome")) %><small><%# DataHora(Eval("MarcadoEm")) %></small></td>
                                    </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
                <asp:Panel ID="pnlSemConciliacao" runat="server" CssClass="tech-empty" Visible="false">
                    Nenhum item conciliado encontrado agora.
                </asp:Panel>
            </section>

            <section class="tech-panel accessory-tab-panel" id="tab-auditoria" data-accessory-tab-panel="auditoria" hidden>
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Auditoria</span>
                        <h2>&Uacute;ltimos eventos</h2>
                        <p>Registro recente de marca&ccedil;&otilde;es, desmarca&ccedil;&otilde;es, tentativas com senha incorreta e consultas de lote.</p>
                    </div>
                </div>

                <div class="accessory-history-list">
                    <asp:Repeater ID="rptUltimosEventos" runat="server" EnableViewState="false">
                        <ItemTemplate>
                            <div class="accessory-history-item">
                                <strong><%# AcaoHistorico(Eval("Acao")) %></strong>
                                <span><%# DataHora(Eval("DataHora")) %> &middot; <%# Html(Eval("UsuarioNome")) %> &middot; lan&ccedil;amento <%# Html(Eval("Lancamento")) %></span>
                                <small><%# Html(Eval("Observacao")) %></small>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <asp:Panel ID="pnlSemAuditoria" runat="server" CssClass="tech-empty" Visible="false">
                    Nenhum evento registrado ainda.
                </asp:Panel>
            </section>

            <section class="tech-panel accessory-tab-panel" id="tab-operacao" data-accessory-tab-panel="operacao">
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Listagem online</span>
                        <h2>Lan&ccedil;amentos de acess&oacute;rios</h2>
                        <p>Ao atualizar, a tela consulta novamente o sistema. Se um registro j&aacute; foi marcado antes e continuar aparecendo, ele volta em verde automaticamente.</p>
                    </div>
                </div>

                <asp:Literal ID="litMensagem" runat="server" />

                <div class="accessory-quick-filters" aria-label="Filtros r&aacute;pidos">
                    <button type="button" data-accessory-fast="pendentes">Somente pendentes</button>
                    <button type="button" data-accessory-fast="vencidos">Vencidos</button>
                    <button type="button" data-accessory-fast="hoje">Vence hoje</button>
                    <button type="button" data-accessory-fast="semana">Pr&oacute;ximos 7 dias</button>
                    <button type="button" data-accessory-fast="todos">Limpar filtros</button>
                </div>

                <div class="accessory-tools">
                    <label class="tech-search" for="accessoryStatus">
                        <span>Status</span>
                        <select id="accessoryStatus">
                            <option value="todos">Todos</option>
                            <option value="pendentes">Somente pendentes</option>
                            <option value="emitidos">Somente emitidos</option>
                        </select>
                    </label>
                    <label class="tech-search" for="accessoryStore">
                        <span>Loja</span>
                        <select id="accessoryStore">
                            <option value="todas">Todas as lojas</option>
                        </select>
                    </label>
                    <label class="tech-search" for="accessoryDue">
                        <span>Vencimento</span>
                        <select id="accessoryDue">
                            <option value="todos">Todos</option>
                            <option value="vencidos">Vencidos</option>
                            <option value="hoje">Vence hoje</option>
                            <option value="proximos">Hoje e amanh&atilde;</option>
                            <option value="semana">Pr&oacute;ximos 7 dias</option>
                        </select>
                    </label>
                    <div class="accessory-buttons">
                        <asp:Button ID="btnAtualizar" runat="server" Text="Atualizar listagem" CssClass="tech-button-secondary" OnClientClick="acionarCarregando('Consultando sistema...');" OnClick="btnAtualizar_Click" />
                        <button type="button" class="tech-button-secondary" id="btnSelectPendingVisible">Selecionar pendentes vis&iacute;veis</button>
                        <asp:Button ID="btnExportarLista" runat="server" Text="Exportar Excel" CssClass="tech-button-secondary" OnClick="btnExportarLista_Click" />
                        <asp:Button ID="btnMarcarEmitidas" runat="server" Text="Marcar NFs emitidas" CssClass="tech-button" OnClientClick="return confirmarSelecionados('Marcar as linhas selecionadas como NFs emitidas?', 'Registrando NFs emitidas...');" OnClick="btnMarcarEmitidas_Click" />
                        <asp:Button ID="btnDesmarcarEmitidas" runat="server" Text="Desmarcar selecionadas" CssClass="tech-danger-button" OnClientClick="return confirmarSelecionados('Desmarcar as linhas selecionadas? O motivo deve estar preenchido.', 'Desmarcando registros...');" OnClick="btnDesmarcarEmitidas_Click" />
                    </div>
                </div>

                <div class="accessory-operation-fields">
                    <label class="tech-field" for="<%= txtObservacao.ClientID %>">
                        <span>Observa&ccedil;&atilde;o da opera&ccedil;&atilde;o</span>
                        <asp:TextBox ID="txtObservacao" runat="server" MaxLength="300" autocomplete="off" placeholder="Ex.: conferido com financeiro" />
                    </label>
                    <label class="tech-field" for="<%= txtSenhaDesmarcar.ClientID %>">
                        <span>Senha para desmarcar</span>
                        <asp:TextBox ID="txtSenhaDesmarcar" runat="server" TextMode="Password" autocomplete="new-password" placeholder="Digite a senha" />
                    </label>
                </div>

                <asp:Panel ID="pnlHistorico" runat="server" CssClass="accessory-history" Visible="false">
                    <h3>Hist&oacute;rico do lan&ccedil;amento</h3>
                    <small>Chave: <asp:Literal ID="litHistoricoChave" runat="server" /></small>
                    <div class="accessory-history-list">
                        <asp:Repeater ID="rptHistorico" runat="server" EnableViewState="false">
                            <ItemTemplate>
                                <div class="accessory-history-item">
                                    <strong><%# AcaoHistorico(Eval("Acao")) %></strong>
                                    <span><%# DataHora(Eval("DataHora")) %> &middot; <%# Html(Eval("UsuarioNome")) %></span>
                                    <small><%# Html(Eval("Observacao")) %></small>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    <asp:Panel ID="pnlSemHistorico" runat="server" CssClass="tech-empty" Visible="false">
                        Nenhum hist&oacute;rico encontrado para este lan&ccedil;amento.
                    </asp:Panel>
                </asp:Panel>

                <div class="accessory-pager" id="accessoryPager" hidden>
                    <span class="accessory-pager-info" id="accessoryPagerInfo">0 registros</span>
                    <div class="accessory-buttons">
                        <select id="accessoryPageSize" aria-label="Itens por p&aacute;gina">
                            <option value="25">25 por p&aacute;gina</option>
                            <option value="50" selected="selected">50 por p&aacute;gina</option>
                            <option value="100">100 por p&aacute;gina</option>
                            <option value="9999">Todos</option>
                        </select>
                        <button type="button" id="accessoryPrevPage">Anterior</button>
                        <button type="button" id="accessoryNextPage">Pr&oacute;xima</button>
                    </div>
                </div>

                <div class="accessory-table-wrap">
                    <asp:Repeater ID="rptAcessorios" runat="server" EnableViewState="false">
                        <HeaderTemplate>
                            <table class="tech-table accessory-table">
                                <thead>
                                    <tr>
                                        <th class="accessory-check"><input id="accessorySelectAll" type="checkbox" aria-label="Selecionar todos" /></th>
                                        <th>Status</th>
                                        <th>Lan&ccedil;amento</th>
                                        <th>Loja</th>
                                        <th>Fornecedor</th>
                                        <th>Datas</th>
                                        <th>Valores</th>
                                        <th>Ve&iacute;culo</th>
                                        <th>Marca&ccedil;&atilde;o</th>
                                        <th>A&ccedil;&otilde;es</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                                    <tr class="<%# LinhaClasse(Eval("Emitido"), Eval("DataVencimentoValor")) %>" data-accessory-row data-issued="<%# EstaEmitido(Eval("Emitido")) ? "1" : "0" %>" data-store="<%# Chave(Eval("Loja")) %>" data-due="<%# DataIso(Eval("DataVencimentoValor")) %>" data-value="<%# NumeroData(Eval("Saldo")) %>" data-search="<%# Chave(String.Concat(Eval("Lancamento"), " ", Eval("NumeroTitulo"), " ", Eval("Loja"), " ", Eval("Fornecedor"), " ", Eval("Veiculo_Chassi"), " ", Eval("Veiculo"))) %>">
                                        <td class="accessory-check">
                                            <input type="checkbox" name="acessorioSelecionado" value="<%# Chave(Eval("ChaveControle")) %>" aria-label="Selecionar lan&ccedil;amento <%# Html(Eval("Lancamento")) %>" />
                                        </td>
                                        <td><span class="<%# StatusClasse(Eval("Emitido")) %>"><%# StatusTexto(Eval("Emitido")) %></span></td>
                                        <td>
                                            <strong><%# Html(Eval("Lancamento")) %></strong>
                                            <small>T&iacute;tulo <%# Html(Eval("NumeroTitulo")) %></small>
                                        </td>
                                        <td><strong><%# Html(Eval("Loja")) %></strong></td>
                                        <td><%# Html(Eval("Fornecedor")) %></td>
                                        <td>
                                            <strong>Emiss&atilde;o: <%# Html(Eval("DataEmissao")) %></strong>
                                            <small>Vencimento: <%# Html(Eval("DataVencimento")) %></small>
                                            <%# DiasEmAbertoTexto(Eval("Emitido"), Eval("DiasEmAberto")) %>
                                            <%# VencimentoTexto(Eval("Emitido"), Eval("DataVencimentoValor")) %>
                                        </td>
                                        <td>
                                            <strong><%# Moeda(Eval("Saldo")) %></strong>
                                            <small>Valor original: <%# Moeda(Eval("TituloValor")) %></small>
                                        </td>
                                        <td>
                                            <strong><%# Html(Eval("Veiculo")) %></strong>
                                            <code><%# Html(Eval("Veiculo_Chassi")) %></code>
                                        </td>
                                        <td class="accessory-mark">
                                            <%# Marcacao(Eval("Emitido"), Eval("MarcadoUsuario"), Eval("MarcadoEm")) %>
                                            <small><%# Html(Eval("Observacao")) %></small>
                                        </td>
                                        <td>
                                            <button type="button" class="accessory-mini-link is-copy" data-copy="<%# Chave(Eval("Veiculo_Chassi")) %>">chassi</button>
                                            <button type="button" class="accessory-mini-link is-copy" data-copy="<%# Chave(Eval("NumeroTitulo")) %>">t&iacute;tulo</button>
                                            <a class="accessory-mini-link" href="<%# UrlHistorico(Eval("ChaveControle")) %>">hist&oacute;rico</a>
                                        </td>
                                    </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>

                <asp:Panel ID="pnlSemDados" runat="server" CssClass="tech-empty" Visible="false">
                    Nenhum lan&ccedil;amento em aberto encontrado agora.
                </asp:Panel>
                <div id="accessoryEmptyFilter" class="tech-empty" hidden>Nenhuma linha encontrada para os filtros atuais.</div>

                <asp:Panel ID="pnlRelatorioAtual" runat="server" CssClass="accessory-report" Visible="false">
                    <div id="relatorioAtual">
                        <div class="accessory-report-head">
                            <div>
                                <h3>Relat&oacute;rio de NF emitida</h3>
                                <p>Rela&ccedil;&atilde;o dos lan&ccedil;amentos selecionados nesta marca&ccedil;&atilde;o.</p>
                            </div>
                            <div class="accessory-report-total">
                                <span>Valor total da NF</span>
                                <strong><asp:Literal ID="litRelatorioAtualTotal" runat="server" /></strong>
                            </div>
                        </div>
                        <div class="accessory-report-meta">
                            <div><span>Relat&oacute;rio</span><strong><asp:Literal ID="litRelatorioAtualId" runat="server" /></strong></div>
                            <div><span>Gerado em</span><strong><asp:Literal ID="litRelatorioAtualData" runat="server" /></strong></div>
                            <div><span>Usu&aacute;rio</span><strong><asp:Literal ID="litRelatorioAtualUsuario" runat="server" /></strong></div>
                            <div><span>Itens</span><strong><asp:Literal ID="litRelatorioAtualItens" runat="server" /></strong></div>
                        </div>
                        <div class="accessory-report-body">
                            <asp:Repeater ID="rptSubtotaisAtual" runat="server" EnableViewState="false">
                                <HeaderTemplate>
                                    <table class="accessory-report-table" style="margin-bottom:12px">
                                        <thead><tr><th>Loja</th><th>Itens</th><th>Subtotal</th></tr></thead>
                                        <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                            <tr>
                                                <td><%# Html(Eval("Loja")) %></td>
                                                <td><%# Html(Eval("Itens")) %></td>
                                                <td><%# Moeda(Eval("ValorTotal")) %></td>
                                            </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                        </tbody>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                            <asp:Repeater ID="rptRelatorioAtual" runat="server" EnableViewState="false">
                                <HeaderTemplate>
                                    <table class="accessory-report-table">
                                        <thead>
                                            <tr>
                                                <th>Loja</th>
                                                <th>Lan&ccedil;amento</th>
                                                <th>T&iacute;tulo</th>
                                                <th>Chassi</th>
                                                <th>Valor</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                            <tr>
                                                <td><%# Html(Eval("Loja")) %></td>
                                                <td><%# Html(Eval("Lancamento")) %></td>
                                                <td><%# Html(Eval("NumeroTitulo")) %></td>
                                                <td><%# Html(Eval("VeiculoChassi")) %></td>
                                                <td><%# Moeda(Eval("ValorNF")) %></td>
                                            </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                        </tbody>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                            <h3 class="accessory-section-title">Auditoria do lote</h3>
                            <div class="accessory-history-list">
                                <asp:Repeater ID="rptAuditoriaLoteAtual" runat="server" EnableViewState="false">
                                    <ItemTemplate>
                                        <div class="accessory-history-item">
                                            <strong><%# AcaoHistorico(Eval("Acao")) %></strong>
                                            <span><%# DataHora(Eval("DataHora")) %> &middot; <%# Html(Eval("UsuarioNome")) %></span>
                                            <small><%# Html(Eval("Observacao")) %></small>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                    <div class="accessory-report-actions">
                        <button type="button" class="tech-button" onclick="imprimirRelatorioAcessorios('relatorioAtual')">Imprimir relat&oacute;rio</button>
                    </div>
                </asp:Panel>
            </section>

            <section class="tech-panel accessory-tab-panel" id="tab-reimpressao" data-accessory-tab-panel="reimpressao" hidden>
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Reimpress&atilde;o</span>
                        <h2>Relat&oacute;rio do dia</h2>
                        <p>Carregue novamente a rela&ccedil;&atilde;o marcada como NF emitida por voc&ecirc; em uma data espec&iacute;fica.</p>
                    </div>
                </div>

                <asp:Literal ID="litMensagemRelatorio" runat="server" />

                <div class="accessory-report-filters">
                    <label class="tech-field" for="<%= txtRelatorioData.ClientID %>">
                        <span>Data da marca&ccedil;&atilde;o</span>
                        <asp:TextBox ID="txtRelatorioData" runat="server" autocomplete="off" />
                    </label>
                    <label class="tech-field" for="<%= txtRelatorioId.ClientID %>">
                        <span>N&uacute;mero do relat&oacute;rio</span>
                        <asp:TextBox ID="txtRelatorioId" runat="server" autocomplete="off" placeholder="Ex.: 123" />
                    </label>
                    <asp:Button ID="btnBuscarRelatorioDia" runat="server" Text="Carregar relat&#243;rio do dia" CssClass="tech-button" OnClientClick="acionarCarregando('Carregando relatório...');" OnClick="btnBuscarRelatorioDia_Click" />
                    <asp:Button ID="btnBuscarRelatorioId" runat="server" Text="Abrir pelo n&#250;mero" CssClass="tech-button-secondary" OnClientClick="acionarCarregando('Abrindo relatório...');" OnClick="btnBuscarRelatorioId_Click" />
                    <asp:Button ID="btnExportarRelatorioDia" runat="server" Text="Exportar Excel" CssClass="tech-button-secondary" OnClick="btnExportarRelatorioDia_Click" />
                </div>

                <asp:Panel ID="pnlLotesDia" runat="server" Visible="false">
                    <div class="accessory-lot-list">
                        <asp:Repeater ID="rptLotesDia" runat="server" EnableViewState="false">
                            <ItemTemplate>
                                <div class="accessory-lot-item">
                                    <div>
                                        <strong>Relat&oacute;rio #<%# Html(Eval("IdRelatorio")) %></strong>
                                        <span><%# DataHora(Eval("GeradoEm")) %> &middot; <%# Html(Eval("UsuarioNome")) %></span>
                                    </div>
                                    <small><%# Html(Eval("TotalItens")) %> itens &middot; <%# Moeda(Eval("ValorTotal")) %> &middot; <a href="<%# UrlRelatorio(Eval("IdRelatorio")) %>">abrir lote</a></small>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlRelatorioDia" runat="server" CssClass="accessory-report" Visible="false">
                    <div id="relatorioDia">
                        <div class="accessory-report-head">
                            <div>
                                <h3>Relat&oacute;rio di&aacute;rio de NF emitida</h3>
                                <p>Consolida&ccedil;&atilde;o dos lan&ccedil;amentos marcados no dia selecionado.</p>
                            </div>
                            <div class="accessory-report-total">
                                <span>Valor total da NF</span>
                                <strong><asp:Literal ID="litRelatorioDiaTotal" runat="server" /></strong>
                            </div>
                        </div>
                        <div class="accessory-report-meta">
                            <div><span>Data</span><strong><asp:Literal ID="litRelatorioDiaData" runat="server" /></strong></div>
                            <div><span>Usu&aacute;rio</span><strong><asp:Literal ID="litRelatorioDiaUsuario" runat="server" /></strong></div>
                            <div><span>Itens</span><strong><asp:Literal ID="litRelatorioDiaItens" runat="server" /></strong></div>
                            <div><span>Origem</span><strong>Marca&ccedil;&otilde;es do dia</strong></div>
                        </div>
                        <div class="accessory-report-body">
                            <asp:Repeater ID="rptSubtotaisDia" runat="server" EnableViewState="false">
                                <HeaderTemplate>
                                    <table class="accessory-report-table" style="margin-bottom:12px">
                                        <thead><tr><th>Loja</th><th>Itens</th><th>Subtotal</th></tr></thead>
                                        <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                            <tr>
                                                <td><%# Html(Eval("Loja")) %></td>
                                                <td><%# Html(Eval("Itens")) %></td>
                                                <td><%# Moeda(Eval("ValorTotal")) %></td>
                                            </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                        </tbody>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                            <asp:Repeater ID="rptRelatorioDia" runat="server" EnableViewState="false">
                                <HeaderTemplate>
                                    <table class="accessory-report-table">
                                        <thead>
                                            <tr>
                                                <th>Loja</th>
                                                <th>Lan&ccedil;amento</th>
                                                <th>T&iacute;tulo</th>
                                                <th>Chassi</th>
                                                <th>Valor</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                            <tr>
                                                <td><%# Html(Eval("Loja")) %></td>
                                                <td><%# Html(Eval("Lancamento")) %></td>
                                                <td><%# Html(Eval("NumeroTitulo")) %></td>
                                                <td><%# Html(Eval("VeiculoChassi")) %></td>
                                                <td><%# Moeda(Eval("ValorNF")) %></td>
                                            </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                        </tbody>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                    <div class="accessory-report-actions">
                        <button type="button" class="tech-button" onclick="imprimirRelatorioAcessorios('relatorioDia')">Imprimir relat&oacute;rio do dia</button>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlSemRelatorioDia" runat="server" CssClass="tech-empty" Visible="false">
                    Nenhuma NF emitida encontrada para essa data.
                </asp:Panel>
            </section>
        </main>
    </form>
    <div class="accessory-busy" id="accessoryBusy" aria-live="polite" aria-hidden="true">
        <div class="accessory-busy-box" id="accessoryBusyText">Processando...</div>
    </div>

    <script src="../js/bali-tecnologia.js?v=20260627-tech01"></script>
    <script>
        (function () {
            var search = document.getElementById('accessorySearch');
            var status = document.getElementById('accessoryStatus');
            var store = document.getElementById('accessoryStore');
            var due = document.getElementById('accessoryDue');
            var empty = document.getElementById('accessoryEmptyFilter');
            var selectAll = document.getElementById('accessorySelectAll');
            var selectPendingVisible = document.getElementById('btnSelectPendingVisible');
            var pager = document.getElementById('accessoryPager');
            var pageSize = document.getElementById('accessoryPageSize');
            var prevPage = document.getElementById('accessoryPrevPage');
            var nextPage = document.getElementById('accessoryNextPage');
            var pagerInfo = document.getElementById('accessoryPagerInfo');
            var busy = document.getElementById('accessoryBusy');
            var busyText = document.getElementById('accessoryBusyText');
            var tabButtons = document.querySelectorAll('[data-accessory-tab]');
            var tabPanels = document.querySelectorAll('[data-accessory-tab-panel]');
            var currentPage = 1;

            function rows() {
                return document.querySelectorAll('[data-accessory-row]');
            }

            function two(value) {
                return value < 10 ? '0' + value : '' + value;
            }

            function dateIso(offset) {
                var data = new Date();
                data.setHours(0, 0, 0, 0);
                data.setDate(data.getDate() + offset);
                return data.getFullYear() + '-' + two(data.getMonth() + 1) + '-' + two(data.getDate());
            }

            function dueOk(row, filter) {
                if (filter === 'todos') return true;
                if (row.getAttribute('data-issued') === '1') return false;

                var value = row.getAttribute('data-due') || '';
                if (!value) return false;

                var today = dateIso(0);
                var tomorrow = dateIso(1);

                if (filter === 'vencidos') return value < today;
                if (filter === 'hoje') return value === today;
                if (filter === 'proximos') return value <= tomorrow;
                if (filter === 'semana') return value <= dateIso(7);
                return true;
            }

            function fillStores() {
                if (!store) return;
                var list = rows();
                var seen = {};

                for (var i = 0; i < list.length; i++) {
                    var value = list[i].getAttribute('data-store') || '';
                    if (!value || seen[value]) continue;
                    seen[value] = true;
                }

                var names = [];
                for (var key in seen) {
                    if (Object.prototype.hasOwnProperty.call(seen, key)) names.push(key);
                }

                names.sort();
                for (var n = 0; n < names.length; n++) {
                    var option = document.createElement('option');
                    option.value = names[n];
                    option.textContent = names[n];
                    store.appendChild(option);
                }
            }

            function renderPage() {
                var list = rows();
                var visibleRows = [];
                var size = pageSize ? parseInt(pageSize.value, 10) : 50;
                if (!size || size <= 0) size = 50;

                for (var i = 0; i < list.length; i++) {
                    if (list[i].getAttribute('data-filtered') === '1') {
                        visibleRows.push(list[i]);
                    }
                }

                var pages = Math.max(1, Math.ceil(visibleRows.length / size));
                if (currentPage > pages) currentPage = pages;
                if (currentPage < 1) currentPage = 1;

                for (var r = 0; r < list.length; r++) {
                    list[r].style.display = 'none';
                }

                var start = (currentPage - 1) * size;
                var end = size >= 9999 ? visibleRows.length : Math.min(start + size, visibleRows.length);
                for (var v = start; v < end; v++) {
                    visibleRows[v].style.display = '';
                }

                if (pager) pager.hidden = visibleRows.length === 0;
                if (pagerInfo) {
                    pagerInfo.textContent = visibleRows.length + ' registro(s) filtrado(s) · página ' + currentPage + ' de ' + pages;
                }
                if (prevPage) prevPage.disabled = currentPage <= 1;
                if (nextPage) nextPage.disabled = currentPage >= pages;

                if (empty) {
                    empty.hidden = visibleRows.length > 0 || list.length === 0;
                }
            }

            function applyFilters(resetPage) {
                if (resetPage) currentPage = 1;
                var query = search ? search.value.toLowerCase().trim() : '';
                var filter = status ? status.value : 'todos';
                var storeFilter = store ? store.value : 'todas';
                var dueFilter = due ? due.value : 'todos';
                var list = rows();

                for (var i = 0; i < list.length; i++) {
                    var row = list[i];
                    var haystack = (row.getAttribute('data-search') || row.textContent || '').toLowerCase();
                    var issued = row.getAttribute('data-issued') === '1';
                    var statusOk = filter === 'todos' || (filter === 'emitidos' && issued) || (filter === 'pendentes' && !issued);
                    var storeOk = storeFilter === 'todas' || row.getAttribute('data-store') === storeFilter;
                    var dueFilterOk = dueOk(row, dueFilter);
                    var searchOk = !query || haystack.indexOf(query) >= 0;
                    var show = statusOk && storeOk && dueFilterOk && searchOk;
                    row.setAttribute('data-filtered', show ? '1' : '0');
                }

                renderPage();
            }

            function selectedRows() {
                var checked = document.querySelectorAll('input[name="acessorioSelecionado"]:checked');
                var selected = [];
                for (var i = 0; i < checked.length; i++) {
                    var row = checked[i].closest ? checked[i].closest('tr') : checked[i].parentNode.parentNode;
                    selected.push(row);
                }
                return selected;
            }

            function formatMoney(value) {
                var number = parseFloat(value || '0');
                if (isNaN(number)) number = 0;
                return number.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
            }

            window.acionarCarregando = function (message) {
                if (busyText) busyText.textContent = message || 'Processando...';
                if (busy) {
                    busy.className = 'accessory-busy is-visible';
                    busy.setAttribute('aria-hidden', 'false');
                }

                setTimeout(function () {
                    var buttons = document.querySelectorAll('input[type="submit"], button');
                    for (var i = 0; i < buttons.length; i++) {
                        if (buttons[i].type === 'button') continue;
                        buttons[i].disabled = true;
                    }
                }, 0);
                return true;
            };

            window.confirmarSelecionados = function (message, loadingMessage) {
                var selected = selectedRows();
                if (!selected.length) {
                    alert('Selecione pelo menos uma linha.');
                    return false;
                }

                var total = 0;
                for (var i = 0; i < selected.length; i++) {
                    total += parseFloat(selected[i].getAttribute('data-value') || '0') || 0;
                }

                var fullMessage = message + '\\n\\nItens selecionados: ' + selected.length + '\\nValor total: ' + formatMoney(total);
                if (!confirm(fullMessage)) return false;

                window.acionarCarregando(loadingMessage || 'Processando...');
                return true;
            };

            function bindCopyButtons() {
                var buttons = document.querySelectorAll('[data-copy]');
                for (var i = 0; i < buttons.length; i++) {
                    buttons[i].addEventListener('click', function () {
                        var value = this.getAttribute('data-copy') || '';
                        if (!value) return;

                        if (navigator.clipboard && navigator.clipboard.writeText) {
                            navigator.clipboard.writeText(value);
                        } else {
                            var input = document.createElement('input');
                            input.value = value;
                            document.body.appendChild(input);
                            input.select();
                            document.execCommand('copy');
                            document.body.removeChild(input);
                        }
                    });
                }
            }

            window.confirmarSelecionadosAntigo = function (message) {
                var checked = document.querySelectorAll('input[name="acessorioSelecionado"]:checked');
                if (!checked.length) {
                    alert('Selecione pelo menos uma linha.');
                    return false;
                }
                return confirm(message);
            };

            if (search) search.addEventListener('input', function () { applyFilters(true); });
            if (status) status.addEventListener('change', function () { applyFilters(true); });
            if (store) store.addEventListener('change', function () { applyFilters(true); });
            if (due) due.addEventListener('change', function () { applyFilters(true); });
            if (pageSize) pageSize.addEventListener('change', function () { currentPage = 1; renderPage(); });
            if (prevPage) prevPage.addEventListener('click', function () { currentPage--; renderPage(); });
            if (nextPage) nextPage.addEventListener('click', function () { currentPage++; renderPage(); });

            var fastFilters = document.querySelectorAll('[data-accessory-fast]');
            for (var f = 0; f < fastFilters.length; f++) {
                fastFilters[f].addEventListener('click', function () {
                    var fast = this.getAttribute('data-accessory-fast');
                    if (fast === 'todos') {
                        if (status) status.value = 'todos';
                        if (due) due.value = 'todos';
                        if (search) search.value = '';
                    }
                    if (fast === 'pendentes' && status) status.value = 'pendentes';
                    if ((fast === 'vencidos' || fast === 'hoje' || fast === 'semana') && due) due.value = fast;
                    applyFilters(true);
                });
            }

            if (selectAll) {
                selectAll.addEventListener('change', function () {
                    var list = rows();
                    for (var i = 0; i < list.length; i++) {
                        if (list[i].style.display === 'none') continue;
                        var check = list[i].querySelector('input[name="acessorioSelecionado"]');
                        if (check) check.checked = selectAll.checked;
                    }
                });
            }

            if (selectPendingVisible) {
                selectPendingVisible.addEventListener('click', function () {
                    var list = rows();
                    for (var i = 0; i < list.length; i++) {
                        if (list[i].style.display === 'none') continue;
                        if (list[i].getAttribute('data-issued') === '1') continue;
                        var check = list[i].querySelector('input[name="acessorioSelecionado"]');
                        if (check) check.checked = true;
                    }
                });
            }

            window.abrirAbaAcessorios = function (tab) {
                for (var i = 0; i < tabButtons.length; i++) {
                    var active = tabButtons[i].getAttribute('data-accessory-tab') === tab;
                    tabButtons[i].className = active ? 'accessory-tab-button is-active' : 'accessory-tab-button';
                }

                for (var j = 0; j < tabPanels.length; j++) {
                    tabPanels[j].hidden = tabPanels[j].getAttribute('data-accessory-tab-panel') !== tab;
                }
            };

            for (var t = 0; t < tabButtons.length; t++) {
                tabButtons[t].addEventListener('click', function () {
                    window.abrirAbaAcessorios(this.getAttribute('data-accessory-tab'));
                });
            }

            if (window.__accessoryInitialTab) {
                window.abrirAbaAcessorios(window.__accessoryInitialTab);
            }

            fillStores();
            bindCopyButtons();
            applyFilters(true);

            window.imprimirRelatorioAcessorios = function (id) {
                var area = document.getElementById(id);
                if (!area) return;

                var janela = window.open('', '_blank', 'width=980,height=720');
                if (!janela) {
                    alert('Permita pop-ups para imprimir o relat\\u00f3rio.');
                    return;
                }

                janela.document.open();
                janela.document.write('<!doctype html><html><head><meta charset="utf-8"><title>Relat\\u00f3rio de NF</title>');
                janela.document.write('<style>body{font-family:Arial,Helvetica,sans-serif;margin:24px;color:#111827}h3{margin:0;font-size:22px}.accessory-report{border:0}.accessory-report-head{display:grid;grid-template-columns:1fr auto;gap:18px;border-bottom:1px solid #d1d5db;padding-bottom:12px}.accessory-report-head p{margin:6px 0 0;color:#4b5563;font-size:12px}.accessory-report-total{border:1px solid #d1fae5;background:#ecfdf3;padding:12px;min-width:190px;text-align:right}.accessory-report-total span,.accessory-report-meta span{display:block;color:#047857;font-size:10px;font-weight:900;text-transform:uppercase;letter-spacing:.04em}.accessory-report-total strong{display:block;color:#065f46;font-size:24px;margin-top:5px}.accessory-report-meta{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;border-bottom:1px solid #e5e7eb;background:#f9fafb;padding:10px 0;margin-bottom:12px}.accessory-report-meta div{padding:0 8px}.accessory-report-meta strong{display:block;font-size:12px;margin-top:4px}.accessory-report-body{padding-top:4px}.accessory-report-table{width:100%;border-collapse:collapse}.accessory-report-table th,.accessory-report-table td{border-bottom:1px solid #e5e7eb;padding:7px 6px;font-size:12px;text-align:left}.accessory-report-table th{background:#f3f4f6;color:#4b5563;font-size:10px;text-transform:uppercase;letter-spacing:.04em}@page{size:A4 portrait;margin:12mm}@media print{body{margin:0}}</style>');
                janela.document.write('</head><body>');
                janela.document.write(area.innerHTML);
                janela.document.write('</body></html>');
                janela.document.close();
                janela.focus();
                setTimeout(function () {
                    janela.print();
                }, 300);
            };
        })();
    </script>
</body>
</html>
