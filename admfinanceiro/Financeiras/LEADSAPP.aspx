<%@ Page Language="C#" AutoEventWireup="true" CodeFile="LEADSAPP.aspx.cs" Inherits="admfinanceiro_Financeiras_Financeiras" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Relat&oacute;rio Fiscal | Leads APP</title>
    <link href="../../css/estilo.css" rel="stylesheet" />
    <script src="../../js/jquery-1.10.2.js"></script>
    <script src="../../js/js.js"></script>
    <style type="text/css">
        :root {
            --bali-bg: #f3f6fb;
            --bali-card: #ffffff;
            --bali-border: #dbe4ef;
            --bali-text: #142033;
            --bali-muted: #64748b;
            --bali-primary: #263b5e;
            --bali-primary-2: #4f6f9f;
            --bali-success: #166534;
        }

        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            background: var(--bali-bg);
            color: var(--bali-text);
            font-family: Arial, Helvetica, sans-serif;
        }

        .leads-page {
            min-height: 100vh;
            padding: 18px;
        }

        .leads-topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 18px;
            padding: 16px 18px;
            border-radius: 18px;
            background: linear-gradient(135deg, #16243a, #2f4f7d);
            color: #fff;
            box-shadow: 0 20px 45px rgba(15, 23, 42, .18);
        }

        .leads-brand {
            display: flex;
            align-items: center;
            gap: 14px;
            min-width: 0;
        }

        .leads-brand-mark {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 46px;
            height: 46px;
            border-radius: 14px;
            background: rgba(255, 255, 255, .14);
            border: 1px solid rgba(255, 255, 255, .25);
            font-weight: 950;
            letter-spacing: .04em;
        }

        .leads-brand small {
            display: block;
            margin-bottom: 2px;
            color: rgba(255, 255, 255, .72);
            font-size: 11px;
            font-weight: 900;
            letter-spacing: .08em;
            text-transform: uppercase;
        }

        .leads-brand h1 {
            margin: 0;
            font-size: clamp(20px, 2.6vw, 30px);
            line-height: 1.05;
            letter-spacing: 0;
        }

        .leads-user {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: flex-end;
            font-size: 12px;
            font-weight: 850;
            color: rgba(255, 255, 255, .82);
        }

        .leads-user span {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            min-height: 30px;
            padding: 6px 10px;
            border-radius: 999px;
            background: rgba(255, 255, 255, .12);
            border: 1px solid rgba(255, 255, 255, .18);
        }

        .leads-shell {
            display: grid;
            gap: 16px;
        }

        .leads-card {
            border: 1px solid var(--bali-border);
            border-radius: 18px;
            background: var(--bali-card);
            box-shadow: 0 18px 45px rgba(15, 23, 42, .08);
            overflow: hidden;
        }

        .leads-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding: 18px 20px;
            border-bottom: 1px solid #e7edf5;
            background: linear-gradient(180deg, #fff, #f8fafc);
        }

        .leads-card-header small {
            display: block;
            margin-bottom: 4px;
            color: var(--bali-muted);
            font-size: 11px;
            font-weight: 950;
            letter-spacing: .08em;
            text-transform: uppercase;
        }

        .leads-card-header h2 {
            margin: 0;
            color: #0f172a;
            font-size: 18px;
            line-height: 1.15;
        }

        .leads-card-body { padding: 18px 20px 20px; }

        .leads-filter-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(180px, 220px)) minmax(260px, 1fr) auto auto;
            gap: 12px;
            align-items: end;
        }

        .leads-field {
            display: grid;
            gap: 6px;
            min-width: 0;
        }

        .leads-label {
            color: #52637a;
            font-size: 11px;
            font-weight: 950;
            letter-spacing: .08em;
            text-transform: uppercase;
        }

        .leads-input,
        .leads-field input[type="text"] {
            width: 100%;
            min-height: 44px;
            border: 1px solid #cfd9e6;
            border-radius: 12px;
            padding: 10px 12px;
            background: #fff;
            color: #0f172a;
            font-size: 14px;
            font-weight: 800;
            outline: none;
            transition: border-color .16s ease, box-shadow .16s ease;
        }

        .leads-input:focus,
        .leads-field input[type="text"]:focus {
            border-color: var(--bali-primary-2);
            box-shadow: 0 0 0 4px rgba(79, 111, 159, .14);
        }

        .leads-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            align-items: center;
        }

        .leads-btn,
        input.leads-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 44px;
            border: 1px solid transparent;
            border-radius: 12px;
            padding: 10px 16px;
            cursor: pointer;
            color: #fff;
            background: linear-gradient(135deg, var(--bali-primary), var(--bali-primary-2));
            font-size: 13px;
            font-weight: 950;
            text-decoration: none;
            box-shadow: 0 12px 28px rgba(38, 59, 94, .20);
        }

        .leads-btn-secondary,
        input.leads-btn-secondary {
            color: var(--bali-primary);
            background: #fff;
            border-color: #cfd9e6;
            box-shadow: none;
        }

        .leads-btn:hover { filter: brightness(.98); }

        .leads-helper {
            margin-top: 12px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            color: var(--bali-muted);
            font-size: 12px;
            font-weight: 800;
        }

        .leads-quick {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .leads-chip {
            border: 1px solid #dbe4ef;
            border-radius: 999px;
            background: #fff;
            color: #40516a;
            padding: 7px 10px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 900;
        }

        .leads-message {
            display: none;
            margin-top: 12px;
            border: 1px solid #fecaca;
            border-radius: 12px;
            background: #fff7f7;
            color: #991b1b;
            padding: 10px 12px;
            font-size: 13px;
            font-weight: 850;
        }

        .leads-summary {
            display: grid;
            grid-template-columns: repeat(3, minmax(160px, 1fr));
            gap: 12px;
        }

        .leads-kpi {
            border: 1px solid var(--bali-border);
            border-radius: 16px;
            background: #fff;
            padding: 14px 16px;
        }

        .leads-kpi small {
            display: block;
            color: var(--bali-muted);
            font-size: 11px;
            font-weight: 950;
            letter-spacing: .08em;
            text-transform: uppercase;
        }

        .leads-kpi strong {
            display: block;
            margin-top: 8px;
            color: #0f172a;
            font-size: 24px;
            line-height: 1;
        }

        .leads-kpi span {
            display: block;
            margin-top: 7px;
            color: var(--bali-muted);
            font-size: 12px;
            font-weight: 800;
        }

        .leads-table-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            padding: 14px 16px;
            border-bottom: 1px solid #e7edf5;
            background: #fbfdff;
        }

        .leads-table-toolbar h3 {
            margin: 0;
            color: #0f172a;
            font-size: 16px;
        }

        .leads-table-toolbar p {
            margin: 4px 0 0;
            color: var(--bali-muted);
            font-size: 12px;
            font-weight: 800;
        }

        .leads-search {
            width: min(360px, 100%);
            min-height: 40px;
            border: 1px solid #cfd9e6;
            border-radius: 999px;
            padding: 9px 14px;
            color: #0f172a;
            font-size: 13px;
            font-weight: 800;
            outline: none;
        }

        .leads-table-wrap {
            overflow: auto;
            max-height: calc(100vh - 360px);
            min-height: 260px;
            background: #fff;
        }

        .leads-grid {
            width: 100%;
            min-width: 2100px;
            border: 0;
            border-collapse: separate;
            border-spacing: 0;
        }

        .leads-grid th {
            position: sticky;
            top: 0;
            z-index: 2;
            border: 0;
            border-bottom: 1px solid #d9e2ef;
            background: #eef4fb;
            color: #334155;
            padding: 10px 12px;
            font-size: 11px;
            font-weight: 950;
            letter-spacing: .04em;
            text-transform: uppercase;
            white-space: nowrap;
            text-align: left;
        }

        .leads-grid th a {
            color: inherit;
            text-decoration: none;
        }

        .leads-grid td {
            border: 0;
            border-bottom: 1px solid #edf2f7;
            padding: 10px 12px;
            color: #1f2937;
            font-size: 12px;
            font-weight: 760;
            white-space: nowrap;
        }

        .leads-grid tr:nth-child(even) td { background: #fbfdff; }
        .leads-grid tr:hover td { background: #f2f7ff; }

        .leads-empty {
            padding: 28px;
            color: var(--bali-muted);
            font-weight: 850;
            text-align: center;
        }

        .leads-loading {
            position: fixed;
            inset: 0;
            z-index: 9999;
            display: none;
            place-items: center;
            background: rgba(15, 23, 42, .54);
        }

        .leads-loading-card {
            display: flex;
            align-items: center;
            gap: 12px;
            width: min(340px, calc(100vw - 32px));
            border-radius: 16px;
            background: #fff;
            padding: 18px;
            color: #0f172a;
            box-shadow: 0 24px 60px rgba(15, 23, 42, .28);
            font-weight: 900;
        }

        .leads-spinner {
            width: 24px;
            height: 24px;
            border-radius: 999px;
            border: 3px solid #dbe4ef;
            border-top-color: var(--bali-primary-2);
            animation: leads-spin .8s linear infinite;
        }

        @keyframes leads-spin { to { transform: rotate(360deg); } }

        .ti-footer {
            margin-top: 16px;
            padding: 14px;
            color: #52637a;
            text-align: center;
            font-size: 12px;
            font-weight: 900;
        }

        @media (max-width: 980px) {
            .leads-topbar,
            .leads-card-header { align-items: flex-start; flex-direction: column; }
            .leads-user { justify-content: flex-start; }
            .leads-filter-grid { grid-template-columns: 1fr; }
            .leads-actions { width: 100%; }
            .leads-actions input,
            .leads-actions .leads-btn { width: 100%; }
            .leads-summary { grid-template-columns: 1fr; }
            .leads-table-wrap { max-height: none; }
        }

        @media print {
            .leads-topbar,
            .leads-card:first-of-type,
            .leads-summary,
            .leads-table-toolbar,
            .ti-footer { display: none !important; }
            body, .leads-page { background: #fff; padding: 0; }
            .leads-card { border: 0; box-shadow: none; }
            .leads-table-wrap { max-height: none; overflow: visible; }
            .leads-grid { min-width: 0; font-size: 9px; }
            .leads-grid th, .leads-grid td { padding: 4px; white-space: normal; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>

        <main class="leads-page">
            <header class="leads-topbar">
                <div class="leads-brand">
                    <span class="leads-brand-mark">BALI</span>
                    <div>
                        <small>Adm. financeiro</small>
                        <h1>Relat&oacute;rio fiscal de notas e tributos</h1>
                    </div>
                </div>
                <div class="leads-user">
                    <span>Usu&aacute;rio: <asp:Label ID="lblUsuario" runat="server" Text="-"></asp:Label></span>
                    <span>C&oacute;digo: <asp:Label ID="lblTipo" runat="server" Text="-"></asp:Label></span>
                    <a class="leads-btn leads-btn-secondary" href="../Default.aspx">Voltar</a>
                </div>
            </header>

            <section class="leads-shell">
                <div class="leads-card">
                    <div class="leads-card-header">
                        <div>
                            <small>Per&iacute;odo de consulta</small>
                            <h2>Filtrar arquivo fiscal</h2>
                        </div>
                        <asp:Label ID="lblFrmID" runat="server" Text="LEADS APP" Style="display:none;"></asp:Label>
                    </div>
                    <div class="leads-card-body">
                        <div class="leads-filter-grid">
                            <label class="leads-field">
                                <span class="leads-label">Data inicial</span>
                                <asp:TextBox ID="txtDtInicial" runat="server" CssClass="leads-input" autocomplete="off" placeholder="AAAA-MM-DD"></asp:TextBox>
                                <asp:CalendarExtender ID="txtDtInicial_CalendarExtender" runat="server" Enabled="True" Format="yyyy-MM-dd" TargetControlID="txtDtInicial"></asp:CalendarExtender>
                            </label>
                            <label class="leads-field">
                                <span class="leads-label">Data final</span>
                                <asp:TextBox ID="txtDtFinal" runat="server" CssClass="leads-input" autocomplete="off" placeholder="AAAA-MM-DD"></asp:TextBox>
                                <asp:CalendarExtender ID="txtDtFinal_CalendarExtender" runat="server" Enabled="True" TargetControlID="txtDtFinal" Format="yyyy-MM-dd"></asp:CalendarExtender>
                            </label>
                            <label class="leads-field">
                                <span class="leads-label">Busca r&aacute;pida na tabela</span>
                                <input type="search" id="txtFiltroTabela" class="leads-input" placeholder="Filtrar por nota, fornecedor, loja, refer&ecirc;ncia..." autocomplete="off" />
                            </label>
                            <div class="leads-actions">
                                <asp:Button ID="GerarArquivo" runat="server" OnClick="GerarArquivo_Click" OnClientClick="return leadsValidarPeriodo('consulta');" Text="Consultar" CssClass="leads-btn" />
                                <asp:Button ID="BtnExcel" runat="server" OnClick="BtnExcel_Click" OnClientClick="return leadsValidarPeriodo('excel');" Text="Exportar Excel" CssClass="leads-btn leads-btn-secondary" />
                            </div>
                        </div>
                        <div class="leads-helper">
                            <span>Use per&iacute;odos menores para consultas mais r&aacute;pidas. A exporta&ccedil;&atilde;o respeita o per&iacute;odo informado.</span>
                            <div class="leads-quick">
                                <button type="button" class="leads-chip" data-range="mes">Este m&ecirc;s</button>
                                <button type="button" class="leads-chip" data-range="anterior">M&ecirc;s anterior</button>
                                <button type="button" class="leads-chip" data-range="7">&Uacute;ltimos 7 dias</button>
                                <button type="button" class="leads-chip" data-range="hoje">Hoje</button>
                            </div>
                        </div>
                        <asp:Label ID="lblMensagem" runat="server" CssClass="leads-message"></asp:Label>
                    </div>
                </div>

                <div class="leads-summary">
                    <div class="leads-kpi">
                        <small>Linhas carregadas</small>
                        <strong><asp:Label ID="lblTotalRegistros" runat="server" Text="0"></asp:Label></strong>
                        <span>Registros exibidos na grade</span>
                    </div>
                    <div class="leads-kpi">
                        <small>Per&iacute;odo</small>
                        <strong style="font-size:18px;"><asp:Label ID="lblResumoPeriodo" runat="server" Text="-"></asp:Label></strong>
                        <span>Data inicial at&eacute; data final</span>
                    </div>
                    <div class="leads-kpi">
                        <small>&Uacute;ltima atualiza&ccedil;&atilde;o</small>
                        <strong style="font-size:18px;"><asp:Label ID="lblUltimaAtualizacao" runat="server" Text="-"></asp:Label></strong>
                        <span>Consulta atual da p&aacute;gina</span>
                    </div>
                </div>

                <div class="leads-card">
                    <div class="leads-table-toolbar">
                        <div>
                            <h3>Dados fiscais retornados</h3>
                            <p>Role horizontalmente para ver todos os campos fiscais e tribut&aacute;rios.</p>
                        </div>
                        <input type="search" id="txtFiltroTabelaTopo" class="leads-search" placeholder="Buscar na grade..." autocomplete="off" />
                    </div>
                    <div class="leads-table-wrap">
                        <asp:GridView ID="GridView1" runat="server"
                            AutoGenerateColumns="False"
                            DataSourceID="SqlDsTalison"
                            CssClass="leads-grid"
                            GridLines="None"
                            AllowSorting="True"
                            AllowPaging="True"
                            PageSize="50"
                            OnDataBound="GridView1_DataBound"
                            EmptyDataText="Nenhum registro encontrado para o per&iacute;odo informado.">
                            <EmptyDataTemplate>
                                <div class="leads-empty">Nenhum registro encontrado para o per&iacute;odo informado.</div>
                            </EmptyDataTemplate>
                            <Columns>
                                <asp:BoundField DataField="notafiscal_numero" HeaderText="Nota fiscal" ReadOnly="True" SortExpression="notafiscal_numero" />
                                <asp:BoundField DataField="NotaFiscal_DataEmissao" HeaderText="Emiss&atilde;o" SortExpression="NotaFiscal_DataEmissao"></asp:BoundField>
                                <asp:BoundField DataField="NotaFiscal_DataMovimento" HeaderText="Movimento" SortExpression="NotaFiscal_DataMovimento" />
                                <asp:BoundField DataField="Estabelecimento_Nome" HeaderText="Loja" SortExpression="Estabelecimento_Nome" />
                                <asp:BoundField DataField="Fornecedor" HeaderText="Fornecedor" SortExpression="Fornecedor" />
                                <asp:BoundField DataField="CNPJ Forcenedor" HeaderText="CNPJ fornecedor" SortExpression="CNPJ Forcenedor" />
                                <asp:BoundField DataField="Natureza Op" HeaderText="Natureza op." SortExpression="Natureza Op"></asp:BoundField>
                                <asp:BoundField DataField="Item da NF" HeaderText="Item NF" SortExpression="Item da NF" ReadOnly="True"></asp:BoundField>
                                <asp:BoundField DataField="Cod do Prod. no WF" HeaderText="C&oacute;d. produto WF" SortExpression="Cod do Prod. no WF"></asp:BoundField>
                                <asp:BoundField DataField="Referencia" HeaderText="Refer&ecirc;ncia" SortExpression="Referencia"></asp:BoundField>
                                <asp:BoundField DataField="Valor Unitario" HeaderText="Valor unit&aacute;rio" SortExpression="Valor Unitario"></asp:BoundField>
                                <asp:BoundField DataField="Qtde" HeaderText="Qtde" SortExpression="Qtde"></asp:BoundField>
                                <asp:BoundField DataField="Valor Total" HeaderText="Valor total" SortExpression="Valor Total"></asp:BoundField>
                                <asp:BoundField DataField="CFOP" HeaderText="CFOP" SortExpression="CFOP"></asp:BoundField>
                                <asp:BoundField DataField="Procedencia" HeaderText="Proced&ecirc;ncia" SortExpression="Procedencia" ReadOnly="True"></asp:BoundField>
                                <asp:BoundField DataField="NCM" HeaderText="NCM" ReadOnly="True" SortExpression="NCM"></asp:BoundField>
                                <asp:BoundField DataField="ValorBaseICMS" HeaderText="Base ICMS" ReadOnly="True" SortExpression="ValorBaseICMS"></asp:BoundField>
                                <asp:BoundField DataField="ValorICMS" HeaderText="ICMS" ReadOnly="True" SortExpression="ValorICMS"></asp:BoundField>
                                <asp:BoundField DataField="aliquotaicmsnf" HeaderText="% ICMS" ReadOnly="True" SortExpression="aliquotaicmsnf"></asp:BoundField>
                                <asp:BoundField DataField="ValorBaseICMSST" HeaderText="Base ICMS ST" SortExpression="ValorBaseICMSST"></asp:BoundField>
                                <asp:BoundField DataField="ValorICMSST" HeaderText="ICMS ST" ReadOnly="True" SortExpression="ValorICMSST"></asp:BoundField>
                                <asp:BoundField DataField="AliquotaICMSST" HeaderText="% ICMS ST" ReadOnly="True" SortExpression="AliquotaICMSST"></asp:BoundField>
                                <asp:BoundField DataField="ValorBaseIPI" HeaderText="Base IPI" SortExpression="ValorBaseIPI"></asp:BoundField>
                                <asp:BoundField DataField="ValorIPI" HeaderText="IPI" ReadOnly="True" SortExpression="ValorIPI"></asp:BoundField>
                                <asp:BoundField DataField="AliquotaIPI" HeaderText="% IPI" SortExpression="AliquotaIPI"></asp:BoundField>
                                <asp:BoundField DataField="ValorBasePIS" HeaderText="Base PIS" SortExpression="ValorBasePIS"></asp:BoundField>
                                <asp:BoundField DataField="ValorPIS" HeaderText="PIS" SortExpression="ValorPIS"></asp:BoundField>
                                <asp:BoundField DataField="AliquotaPIS" HeaderText="% PIS" SortExpression="AliquotaPIS"></asp:BoundField>
                                <asp:BoundField DataField="ValorBasePISRetido" HeaderText="Base PIS retido" ReadOnly="True" SortExpression="ValorBasePISRetido"></asp:BoundField>
                                <asp:BoundField DataField="ValorPISRetido" HeaderText="PIS retido" ReadOnly="True" SortExpression="ValorPISRetido"></asp:BoundField>
                                <asp:BoundField DataField="AliquotaPISRetido" HeaderText="% PIS retido" ReadOnly="True" SortExpression="AliquotaPISRetido"></asp:BoundField>
                                <asp:BoundField DataField="ValorBaseIRRF" HeaderText="Base IRRF" SortExpression="ValorBaseIRRF"></asp:BoundField>
                                <asp:BoundField DataField="ValorIRRF" HeaderText="IRRF" SortExpression="ValorIRRF"></asp:BoundField>
                                <asp:BoundField DataField="AliquotaIRRF" HeaderText="% IRRF" SortExpression="AliquotaIRRF"></asp:BoundField>
                                <asp:BoundField DataField="ValorBaseCSLL" HeaderText="Base CSLL" SortExpression="ValorBaseCSLL"></asp:BoundField>
                                <asp:BoundField DataField="ValorCSLL" HeaderText="CSLL" SortExpression="ValorCSLL"></asp:BoundField>
                                <asp:BoundField DataField="AliquotaCSLL" HeaderText="% CSLL" SortExpression="AliquotaCSLL"></asp:BoundField>
                            </Columns>
                            <PagerStyle CssClass="leads-pager" />
                        </asp:GridView>
                    </div>

                    <asp:SqlDataSource ID="SqlDsTalison" runat="server"
                        ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>"
                        SelectCommand="Caio_NOTAFISCALITEMTRIBUTOS"
                        SelectCommandType="StoredProcedure">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="txtDtInicial" DbType="Date" Name="dtInicial" PropertyName="Text" />
                            <asp:ControlParameter ControlID="txtDtFinal" DbType="Date" Name="dtFinal" PropertyName="Text" />
                        </SelectParameters>
                    </asp:SqlDataSource>
                </div>
            </section>

            <footer class="ti-footer">TI - GRUPO BALI</footer>
        </main>

        <div id="ag" class="leads-loading" aria-live="polite" aria-label="Processando consulta">
            <div class="leads-loading-card">
                <span class="leads-spinner"></span>
                <div>
                    <strong>Processando consulta</strong><br />
                    <small>Aguarde alguns instantes.</small>
                </div>
            </div>
        </div>
    </form>

    <script type="text/javascript">
        function leadsMostrarLoading() {
            var ag = document.getElementById('ag');
            if (ag) ag.style.display = 'grid';
        }

        function leadsOcultarLoading() {
            var ag = document.getElementById('ag');
            if (ag) ag.style.display = 'none';
        }

        function leadsMensagem(texto) {
            var msg = document.getElementById('<%= lblMensagem.ClientID %>');
            if (!msg) return;
            msg.style.display = texto ? 'block' : 'none';
            msg.innerHTML = texto || '';
        }

        function leadsValidarPeriodo(acao) {
            var inicio = document.getElementById('<%= txtDtInicial.ClientID %>');
            var fim = document.getElementById('<%= txtDtFinal.ClientID %>');
            if (!inicio || !fim || !inicio.value || !fim.value) {
                leadsMensagem('Informe data inicial e data final antes de consultar.');
                leadsOcultarLoading();
                return false;
            }
            if (inicio.value > fim.value) {
                leadsMensagem('A data inicial n&atilde;o pode ser maior que a data final.');
                leadsOcultarLoading();
                return false;
            }
            leadsMensagem('');
            if (acao === 'excel') {
                leadsOcultarLoading();
                return true;
            }
            leadsMostrarLoading();
            return true;
        }

        function leadsFormatDate(date) {
            var month = String(date.getMonth() + 1);
            var day = String(date.getDate());
            if (month.length < 2) month = '0' + month;
            if (day.length < 2) day = '0' + day;
            return date.getFullYear() + '-' + month + '-' + day;
        }

        function leadsSetRange(type) {
            var inicio = document.getElementById('<%= txtDtInicial.ClientID %>');
            var fim = document.getElementById('<%= txtDtFinal.ClientID %>');
            if (!inicio || !fim) return;

            var today = new Date();
            var start = new Date(today.getFullYear(), today.getMonth(), 1);
            var end = new Date(today.getFullYear(), today.getMonth() + 1, 0);

            if (type === 'anterior') {
                start = new Date(today.getFullYear(), today.getMonth() - 1, 1);
                end = new Date(today.getFullYear(), today.getMonth(), 0);
            } else if (type === '7') {
                start = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 6);
                end = today;
            } else if (type === 'hoje') {
                start = today;
                end = today;
            }

            inicio.value = leadsFormatDate(start);
            fim.value = leadsFormatDate(end);
            leadsMensagem('');
        }

        function leadsBindBusca() {
            var inputs = [
                document.getElementById('txtFiltroTabela'),
                document.getElementById('txtFiltroTabelaTopo')
            ];
            var grid = document.getElementById('<%= GridView1.ClientID %>');
            if (!grid) return;

            function filtrar(valor) {
                valor = (valor || '').toLowerCase();
                var rows = grid.getElementsByTagName('tr');
                for (var i = 1; i < rows.length; i++) {
                    var text = (rows[i].textContent || rows[i].innerText || '').toLowerCase();
                    rows[i].style.display = text.indexOf(valor) >= 0 ? '' : 'none';
                }
                for (var j = 0; j < inputs.length; j++) {
                    if (inputs[j] && inputs[j].value !== valor) inputs[j].value = valor;
                }
            }

            for (var i = 0; i < inputs.length; i++) {
                if (!inputs[i]) continue;
                inputs[i].addEventListener('input', function () { filtrar(this.value); });
            }
        }

        document.addEventListener('click', function (event) {
            var chip = event.target.closest ? event.target.closest('[data-range]') : null;
            if (!chip) return;
            leadsSetRange(chip.getAttribute('data-range'));
        });

        document.addEventListener('DOMContentLoaded', leadsBindBusca);
    </script>
</body>
</html>
