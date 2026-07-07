<%@ Page Language="C#" AutoEventWireup="true" CodeFile="novos.aspx.cs" Inherits="veiculos_patio_novos" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>NOVOS | P&aacute;tio</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <script src="../assets/jquery-1.9.1.min.js"></script>
    <link href="./main.css" rel="stylesheet" />
    <link href="../../css/bali-patio.css?v=20260704-1" rel="stylesheet" />
    <link href="../assets/all.min.css" rel="stylesheet" />
    <script type="text/javascript" src="./assets/js/quagga.min.js"></script>
    <style>
        .novos-shell { display: grid; gap: 1rem; }
        .novos-tabs { display: flex; flex-wrap: wrap; gap: .65rem; }
        .novos-tab {
            display: inline-flex; align-items: center; justify-content: center; gap: .5rem;
            border: 1px solid #dbe4ef; border-radius: 999px; padding: .72rem 1rem;
            background: #fff; color: #334155; font-weight: 900; box-shadow: 0 10px 24px rgba(15,23,42,.07);
            text-decoration: none !important; transition: transform .18s ease, border-color .18s ease, background .18s ease;
        }
        .novos-tab:hover { transform: translateY(-1px); border-color: #8aa36f; color: #203729; }
        .novos-tab.is-active { background: linear-gradient(135deg,#203729,#6f9151); border-color: transparent; color: #fff; box-shadow: 0 16px 34px rgba(32,55,41,.22); }
        .novos-card {
            border: 1px solid #dbe4ef; border-radius: 18px; background: rgba(255,255,255,.97);
            box-shadow: 0 16px 40px rgba(15,23,42,.08); overflow: hidden;
        }
        .novos-card-header {
            display: flex; align-items: center; justify-content: space-between; gap: 1rem;
            padding: 1rem 1.15rem; border-bottom: 1px solid #e2e8f0; background: linear-gradient(180deg,#fff,#f8fafc);
        }
        .novos-card-header small { display:block; color:#64748b; font-weight:850; }
        .novos-card-title { margin:0; color:#0f172a; font-size:1.05rem; font-weight:950; }
        .novos-card-body { padding:1.15rem; }
        .novos-grid { display:grid; grid-template-columns:repeat(12,minmax(0,1fr)); gap:.9rem; }
        .novos-field { grid-column:span 4; display:grid; gap:.35rem; }
        .novos-field.is-wide { grid-column:span 8; }
        .novos-field.is-full { grid-column:1/-1; }
        .novos-label { color:#475569; font-size:.74rem; font-weight:950; letter-spacing:.04em; text-transform:uppercase; }
        .novos-input, .novos-select, .novos-textarea {
            width:100%; min-height:46px; border:1px solid #cfd9e6; border-radius:12px; padding:.72rem .85rem;
            background:#fff; color:#0f172a; font-weight:800; outline:none; transition:border-color .16s ease, box-shadow .16s ease;
        }
        .novos-textarea { min-height:88px; resize:vertical; }
        .novos-input:focus, .novos-select:focus, .novos-textarea:focus { border-color:#6f9151; box-shadow:0 0 0 4px rgba(111,145,81,.14); }
        .novos-actions { display:flex; flex-wrap:wrap; gap:.7rem; align-items:center; margin-top:1rem; }
        .novos-btn {
            display:inline-flex; align-items:center; justify-content:center; gap:.5rem; min-height:44px; border-radius:12px;
            border:1px solid transparent; padding:.7rem 1rem; font-weight:950; text-decoration:none !important;
        }
        .novos-btn-primary { background:linear-gradient(135deg,#203729,#6f9151); color:#fff !important; box-shadow:0 12px 28px rgba(32,55,41,.22); }
        .novos-btn-light { background:#fff; border-color:#cfd9e6; color:#334155 !important; }
        .novos-btn-danger { background:#fff5f5; border-color:#fecaca; color:#991b1b !important; }
        .novos-btn[disabled], .novos-btn.aspNetDisabled { opacity:.55; pointer-events:none; }
        .novos-alert {
            display:flex; align-items:flex-start; gap:.75rem; border-radius:16px; padding:.9rem 1rem; margin-bottom:1rem;
            border:1px solid #dbe4ef; background:#f8fafc; color:#334155; font-weight:800;
        }
        .novos-alert strong { display:block; color:#0f172a; font-weight:950; }
        .novos-alert span { display:block; }
        .novos-alert.is-success { border-color:#bbf7d0; background:#f0fdf4; color:#166534; }
        .novos-alert.is-warning { border-color:#fde68a; background:#fffbeb; color:#92400e; }
        .novos-alert.is-error { border-color:#fecaca; background:#fef2f2; color:#991b1b; }
        .novos-kpis { display:grid; grid-template-columns:repeat(4,minmax(140px,1fr)); gap:.85rem; }
        .novos-kpi { border:1px solid #dbe4ef; border-radius:16px; background:#fff; padding:.95rem; box-shadow:0 12px 26px rgba(15,23,42,.07); }
        .novos-kpi small { display:block; color:#64748b; font-size:.72rem; font-weight:950; letter-spacing:.04em; text-transform:uppercase; }
        .novos-kpi strong { display:block; margin-top:.35rem; color:#0f172a; font-size:clamp(1.35rem,2.8vw,2rem); line-height:1; font-weight:950; }
        .novos-kpi span { display:block; margin-top:.45rem; color:#667085; font-size:.78rem; font-weight:800; }
        .novos-stepper { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:.7rem; margin-bottom:1rem; }
        .novos-step {
            display:flex; align-items:center; gap:.65rem; border:1px solid #dbe4ef; border-radius:14px; padding:.75rem; background:#fff;
            color:#64748b; font-weight:900;
        }
        .novos-step b { display:inline-flex; align-items:center; justify-content:center; width:28px; height:28px; border-radius:999px; background:#edf2f7; color:#334155; }
        .novos-step.is-done { border-color:#bbf7d0; background:#f0fdf4; color:#166534; }
        .novos-step.is-done b { background:#22c55e; color:#fff; }
        .novos-step.is-current { border-color:#8aa36f; background:#f8fff5; color:#203729; box-shadow:0 12px 24px rgba(111,145,81,.12); }
        .novos-vehicle-card {
            border:1px solid #cfe2c3; border-radius:18px; background:linear-gradient(135deg,#f8fff5,#fff);
            padding:1rem; margin-top:1rem;
        }
        .novos-vehicle-main { display:grid; grid-template-columns:minmax(0,1fr) auto; gap:1rem; align-items:start; }
        .novos-vehicle-main strong { display:block; color:#0f172a; font-size:1.15rem; font-weight:950; }
        .novos-vehicle-main small { display:block; color:#64748b; font-weight:800; margin-top:.2rem; }
        .novos-pill-list { display:flex; flex-wrap:wrap; gap:.55rem; margin-top:.85rem; }
        .novos-pill {
            display:inline-flex; align-items:center; gap:.4rem; border-radius:999px; padding:.42rem .65rem;
            background:#eef6e9; color:#203729; font-size:.78rem; font-weight:950;
        }
        .novos-location-pill {
            display:inline-flex; align-items:center; gap:.45rem; border-radius:999px; padding:.5rem .75rem;
            background:#203729; color:#fff; font-size:.8rem; font-weight:950; white-space:nowrap;
        }
        .novos-detail-panel {
            margin-top:1rem; border:1px solid #cfe2c3; border-radius:18px;
            background:linear-gradient(135deg,#f8fff5,#fff); padding:1rem;
        }
        .novos-detail-header { display:grid; grid-template-columns:minmax(0,1fr) auto; gap:1rem; align-items:start; }
        .novos-detail-header small {
            display:block; color:#64748b; font-weight:900; letter-spacing:.04em; text-transform:uppercase;
        }
        .novos-detail-header strong { display:block; color:#0f172a; font-size:1.2rem; font-weight:950; }
        .novos-detail-header span { color:#64748b; font-weight:800; }
        .novos-history-title {
            display:flex; align-items:center; justify-content:space-between; gap:.75rem;
            margin:1rem 0 .65rem; color:#203729; font-weight:950;
        }
        .novos-global { border-left:4px solid #6f9151; }
        .novos-sticky-summary {
            position:sticky; top:78px; z-index:10; border:1px solid #cfe2c3; border-radius:16px;
            background:rgba(255,255,255,.96); box-shadow:0 12px 26px rgba(15,23,42,.08); padding:.85rem 1rem;
        }
        .novos-sticky-summary:empty { display:none; }
        .novos-table-wrap { overflow-x:auto; }
        .novos-table { width:100%; min-width:900px; margin:0; border-collapse:separate; border-spacing:0; }
        .novos-table th {
            background:#f8fafc; color:#475569; font-size:.73rem; font-weight:950; letter-spacing:.04em;
            text-transform:uppercase; white-space:nowrap; border-bottom:1px solid #e2e8f0; padding:.75rem;
        }
        .novos-table td { color:#1f2937; font-weight:750; vertical-align:middle; border-bottom:1px solid #edf2f7; padding:.78rem; }
        .novos-table td small { display:block; color:#64748b; font-weight:750; }
        .novos-row-actions { display:inline-flex; gap:.45rem; flex-wrap:wrap; }
        .novos-mini-action {
            display:inline-flex; align-items:center; gap:.35rem; border-radius:999px; border:1px solid #cfd9e6;
            background:#fff; color:#334155 !important; padding:.38rem .62rem; font-size:.76rem; font-weight:950; text-decoration:none !important;
        }
        .novos-bar-list { display:grid; gap:.75rem; }
        .novos-bar-row { display:grid; grid-template-columns:minmax(120px,.35fr) minmax(0,1fr) 52px; gap:.7rem; align-items:center; }
        .novos-bar-label { color:#334155; font-weight:900; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .novos-bar-track { height:12px; border-radius:999px; background:#edf2f7; overflow:hidden; }
        .novos-bar-track span { display:block; height:100%; min-width:3px; border-radius:inherit; background:linear-gradient(90deg,#6f9151,#203729); }
        .novos-bi-grid { display:grid; grid-template-columns:minmax(0,1fr) minmax(0,1fr); gap:1rem; }
        .novos-empty { border:1px dashed #cfd9e6; border-radius:16px; padding:1.2rem; background:#f8fafc; color:#64748b; font-weight:850; text-align:center; }
        .novos-status { display:inline-flex; align-items:center; gap:.35rem; border-radius:999px; padding:.35rem .6rem; font-size:.72rem; font-weight:950; background:#eef2ff; color:#3730a3; }
        .novos-status.is-baixado { background:#fef2f2; color:#991b1b; }
        .novos-status.is-alerta { background:#fffbeb; color:#92400e; }
        .novos-status.is-ok { background:#f0fdf4; color:#166534; }
        .novos-print-toolbar { display:flex; flex-wrap:wrap; gap:.6rem; align-items:center; justify-content:flex-end; }
        .novos-pager { display:flex; flex-wrap:wrap; gap:.65rem; align-items:center; justify-content:space-between; margin-top:1rem; padding:.85rem 1rem; border:1px solid #dbe4ef; border-radius:16px; background:#f8fafc; }
        .novos-pager-info { color:#475569; font-weight:900; }
        .novos-suggestion-panel { display:none; margin-top:.55rem; border:1px solid #dbe4ef; border-radius:14px; background:#fff; box-shadow:0 16px 34px rgba(15,23,42,.12); overflow:hidden; }
        .novos-suggestion-panel.is-open { display:block; }
        .novos-suggestion-panel a { display:flex; justify-content:space-between; gap:.75rem; padding:.7rem .85rem; color:#334155; font-weight:850; text-decoration:none !important; border-bottom:1px solid #edf2f7; }
        .novos-suggestion-panel a:hover { background:#f8fafc; color:#203729; }
        .novos-suggestion-panel small { color:#64748b; font-weight:800; }
        .novos-compact-note { color:#64748b; font-size:.78rem; font-weight:850; }
        .barcode-modal .modal-dialog { max-width:720px; }
        .barcode-modal .modal-content { border:0; border-radius:18px; overflow:hidden; box-shadow:0 24px 70px rgba(0,0,0,.32); }
        .barcode-modal .modal-header { align-items:center; background:linear-gradient(135deg,#10271b,#215c3d); color:#fff; border:0; }
        .barcode-modal .modal-title { display:flex; align-items:center; gap:.55rem; font-weight:900; }
        .scanner-stage { position:relative; width:100%; min-height:420px; overflow:hidden; border-radius:18px; background:#0f172a; }
        #scanner-video, #scanner-container, #scanner-container video, #scanner-container canvas { position:absolute; inset:0; width:100% !important; height:100% !important; object-fit:cover; }
        #scanner-video, #scanner-container { display:block; }
        #scanner-video.is-hidden, #scanner-container.is-hidden, .barcode-modal .is-hidden { display:none !important; }
        .scanner-reticle { position:absolute; left:50%; top:50%; width:min(88%,560px); height:132px; transform:translate(-50%,-50%); border:2px solid rgba(255,255,255,.84); border-radius:20px; box-shadow:0 0 0 999px rgba(2,6,23,.42); pointer-events:none; }
        .scanner-reticle::before { content:""; position:absolute; left:18px; right:18px; top:50%; height:2px; transform:translateY(-50%); background:linear-gradient(90deg,transparent,#22c55e,transparent); box-shadow:0 0 18px rgba(34,197,94,.85); }
        .scanner-hint { position:absolute; left:1rem; right:1rem; bottom:1rem; display:flex; justify-content:space-between; gap:.75rem; flex-wrap:wrap; color:#fff; font-weight:800; text-shadow:0 2px 12px rgba(0,0,0,.6); pointer-events:none; }
        .scanner-pill { display:inline-flex; align-items:center; gap:.4rem; padding:.38rem .65rem; border-radius:999px; background:rgba(15,23,42,.74); backdrop-filter:blur(7px); }
        .scanner-status { min-height:42px; margin:.85rem 0 0; padding:.75rem .9rem; border-radius:14px; background:#f8fafc; color:#334155; font-weight:800; }
        .scanner-status--success { color:#14532d; background:#dcfce7; }
        .scanner-status--error { color:#7f1d1d; background:#fee2e2; }
        .scanner-status--warning { color:#713f12; background:#fef3c7; }
        .scanner-status--info { color:#1e3a8a; background:#dbeafe; }
        .scanner-tools { display:grid; grid-template-columns:minmax(0,1fr) auto; gap:.65rem; margin-top:.85rem; }
        .scanner-tools select, .scanner-tools button { min-height:42px; border-radius:12px; font-weight:850; }
        .scanner-zoom { display:grid; grid-template-columns:auto minmax(150px,1fr); align-items:center; gap:.75rem; margin-top:.75rem; padding:.75rem .9rem; border:1px solid #dbe4ef; border-radius:14px; background:#f8fafc; color:#334155; font-weight:850; }
        .scanner-zoom input { width:100%; }
        .scanner-help { margin-top:.75rem; padding:.75rem .9rem; border:1px solid #dbe4ef; border-radius:14px; background:#fff; color:#334155; }
        .scanner-help summary { cursor:pointer; font-weight:950; }
        .scanner-help ul { margin:.65rem 0 0; padding-left:1.1rem; }
        .scanner-manual { display:grid; grid-template-columns:1fr auto; gap:.6rem; margin-top:.85rem; }
        .scanner-manual input { min-height:46px; border-radius:14px; font-size:1.12rem; font-weight:900; letter-spacing:.08em; text-align:center; }
        .scanner-actions { display:flex; align-items:center; justify-content:space-between; gap:.6rem; flex-wrap:wrap; margin-top:.85rem; }
        .novos-modal {
            position:fixed; inset:0; z-index:1050; display:grid; place-items:center; padding:1rem;
            background:rgba(15,23,42,.56);
        }
        .novos-modal-card { width:min(920px,100%); max-height:88vh; overflow:auto; border-radius:20px; background:#fff; box-shadow:0 24px 70px rgba(15,23,42,.28); }
        .novos-modal-header { display:flex; align-items:center; justify-content:space-between; gap:1rem; padding:1rem 1.15rem; border-bottom:1px solid #e2e8f0; }
        .novos-modal-body { padding:1rem; }
        .novos-quick-filters { display:flex; flex-wrap:wrap; gap:.55rem; margin-top:.75rem; }
        .novos-mobile-actions { display:none; }
        @media (max-width:1199.98px) { .novos-kpis { grid-template-columns:repeat(2,minmax(140px,1fr)); } }
        @media (max-width:991.98px) {
            .novos-field, .novos-field.is-wide { grid-column:span 6; }
            .novos-bi-grid { grid-template-columns:1fr; }
            .novos-stepper { grid-template-columns:repeat(2,minmax(0,1fr)); }
        }
        @media (max-width:767.98px) {
            .novos-tabs { display:grid; grid-template-columns:1fr 1fr; }
            .novos-tab { border-radius:14px; }
            .novos-card-header, .novos-vehicle-main, .novos-detail-header { display:grid; grid-template-columns:1fr; align-items:start; }
            .novos-field, .novos-field.is-wide { grid-column:1/-1; }
            .novos-kpis, .novos-stepper { grid-template-columns:1fr; }
            .novos-actions .novos-btn { flex:1 1 100%; }
            .novos-table, .novos-table thead, .novos-table tbody, .novos-table th, .novos-table td, .novos-table tr { display:block; min-width:0; width:100%; }
            .novos-table thead { display:none; }
            .novos-table tr { border:1px solid #dbe4ef; border-radius:16px; margin-bottom:.85rem; background:#fff; overflow:hidden; }
            .novos-table td { display:grid; grid-template-columns:112px minmax(0,1fr); gap:.65rem; border-bottom:1px solid #edf2f7; }
            .novos-table td:before { content:attr(data-label); color:#64748b; font-size:.72rem; font-weight:950; letter-spacing:.04em; text-transform:uppercase; }
            .novos-mobile-actions { display:flex; position:fixed; left:0; right:0; bottom:0; z-index:1035; gap:.5rem; padding:.7rem; background:#fff; border-top:1px solid #dbe4ef; box-shadow:0 -10px 26px rgba(15,23,42,.12); }
            .novos-mobile-actions .novos-btn { flex:1; }
            body[data-patio-page="novos.aspx"] { padding-bottom:76px; }
            .barcode-modal .modal-dialog { width:100%; max-width:none; height:100%; margin:0; }
            .barcode-modal .modal-content { min-height:100%; border-radius:0; }
            .scanner-stage { min-height:min(64vh,560px); border-radius:16px; }
            .scanner-reticle { height:112px; }
            .scanner-manual, .scanner-tools, .scanner-zoom { grid-template-columns:1fr; }
        }
        @media (max-width:480px) { .novos-tabs { grid-template-columns:1fr; } }
        @media print {
            .app-header, .app-sidebar, .novos-tabs, .novos-global, .novos-sticky-summary, .novos-print-toolbar, .novos-mobile-actions, footer { display:none !important; }
            .app-main, .app-main__outer, .app-main__inner { margin:0 !important; padding:0 !important; background:#fff !important; }
            .novos-card { box-shadow:none !important; border-color:#cfd9e6 !important; break-inside:avoid; }
            .novos-table { min-width:0 !important; font-size:10px; }
            .novos-table th, .novos-table td { padding:.35rem !important; }
            @page { size:A4 portrait; margin:10mm; }
        }
    </style>
</head>
<body class="patio-modern-page patio-brand-jeep" data-patio-page="novos.aspx">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <asp:HiddenField ID="hfAbaAtual" runat="server" />
        <asp:HiddenField ID="hfRegistroVeNr" runat="server" />
        <asp:HiddenField ID="hfRegistroSerie" runat="server" />
        <asp:HiddenField ID="hfRegistroNf" runat="server" />
        <asp:HiddenField ID="hfTransferenciaVeNr" runat="server" />
        <asp:HiddenField ID="hfTransferenciaOrigem" runat="server" />
        <asp:HiddenField ID="hfTransferenciaSerie" runat="server" />
        <asp:HiddenField ID="hfHistoricoVeNr" runat="server" />
        <asp:HiddenField ID="hfOperTipo" runat="server" />
        <asp:HiddenField ID="hfOperVeNr" runat="server" />
        <asp:HiddenField ID="hfTodosPagina" runat="server" Value="1" />
        <asp:HiddenField ID="hfConsultaPagina" runat="server" Value="1" />

        <div class="app-container app-theme-white body-tabs-shadow fixed-sidebar fixed-header">
            <div class="app-header header-shadow bg-dark">
                <div class="app-header__logo">
                    <div class="logo-src"></div>
                    <div class="header__pane ml-auto">
                        <button type="button" class="hamburger close-sidebar-btn hamburger--elastic" data-class="closed-sidebar">
                            <span class="hamburger-box"><span class="hamburger-inner"></span></span>
                        </button>
                    </div>
                </div>
                <div class="app-header__mobile-menu">
                    <button type="button" class="hamburger hamburger--elastic mobile-toggle-nav">
                        <span class="hamburger-box"><span class="hamburger-inner"></span></span>
                    </button>
                </div>
                <div class="app-header__content bg-dark">
                    <div class="app-header-left"></div>
                    <div class="app-header-right">
                        <div class="header-btn-lg pr-0">
                            <div class="widget-content p-0">
                                <div class="widget-content-wrapper">
                                    <div class="widget-content-left">
                                        <i class="text-white mr-1">
                                            <b><i class="fa fa-user mr-1"></i><asp:Literal ID="usuarioLogado" runat="server"></asp:Literal></b>
                                            <asp:LinkButton runat="server" ID="sair" CssClass="fa fa-arrow-alt-circle-right text-danger" OnClick="btnSair_Click" ToolTip="Sair"></asp:LinkButton>
                                        </i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="app-main" style="background-color:#495057;">
                <div class="app-sidebar sidebar-shadow">
                    <div class="app-header__logo">
                        <div class="logo-src"></div>
                        <div class="header__pane ml-auto">
                            <button type="button" class="hamburger close-sidebar-btn hamburger--elastic" data-class="closed-sidebar">
                                <span class="hamburger-box"><span class="hamburger-inner"></span></span>
                            </button>
                        </div>
                    </div>
                    <div class="app-header__mobile-menu">
                        <button type="button" class="hamburger hamburger--elastic mobile-toggle-nav">
                            <span class="hamburger-box"><span class="hamburger-inner"></span></span>
                        </button>
                    </div>
                    <div class="scrollbar-sidebar bg-dark">
                        <div class="app-sidebar__inner">
                            <ul class="vertical-nav-menu">
                                <li><a href="./"><i class="metismenu-icon fas fa-home"></i>In&iacute;cio</a></li>
                                <li class="app-sidebar__heading">Fun&ccedil;&otilde;es</li>
                                <li><a href="./novos.aspx" class="mm-active"><i class="metismenu-icon fas fa-car"></i>Novos</a></li>
                                <li><a href="./seminovos.aspx"><i class="metismenu-icon fas fa-car-side"></i>Seminovos</a></li>
                                <li><a href="./lojas.aspx"><i class="metismenu-icon fas fa-store"></i>Lojas</a></li>
                                <li><a href="./barcode-logs.aspx"><i class="metismenu-icon fas fa-clipboard-list"></i>Logs do leitor</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="app-main__outer">
                    <asp:UpdatePanel ID="updatePanel" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="app-main__inner mb-3">
                                <div class="app-page-title text-white" style="background-color:#495057;">
                                    <div class="page-title-wrapper">
                                        <div class="page-title-heading">
                                            <div class="page-title-icon" style="background-color:#495057;">
                                                <i class="fas fa-car text-white"></i>
                                            </div>
                                            <div>
                                                <b>Novos</b>
                                                <div class="page-title-subheading">Registro, consulta, transfer&ecirc;ncia e BI dos ve&iacute;culos novos em uma tela &uacute;nica.</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="novos-shell">
                                    <asp:Literal ID="litIndicadores" runat="server"></asp:Literal>

                                    <div class="novos-card novos-global">
                                        <div class="novos-card-header">
                                            <div>
                                                <small>Busca global do p&aacute;tio</small>
                                                <h2 class="novos-card-title">Localizar ve&iacute;culo</h2>
                                            </div>
                                            <span class="novos-pill"><i class="fa fa-search"></i> Novos e seminovos</span>
                                        </div>
                                        <div class="novos-card-body">
                                            <div class="novos-grid">
                                                <div class="novos-field is-wide">
                                                    <label class="novos-label" for="<%= txtGlobalBusca.ClientID %>">Digite s&eacute;rie, chassi, placa, Renavam ou c&oacute;digo</label>
                                                    <asp:TextBox ID="txtGlobalBusca" runat="server" CssClass="novos-input" MaxLength="40" autocomplete="off" placeholder="Ex.: 397665, 8AP..., ABC1D23, Renavam ou c&oacute;digo"></asp:TextBox>
                                                    <div id="novosGlobalSuggestions" class="novos-suggestion-panel" aria-live="polite"></div>
                                                </div>
                                                <div class="novos-field">
                                                    <label class="novos-label">&nbsp;</label>
                                                    <asp:LinkButton ID="btnGlobalBuscar" runat="server" CssClass="novos-btn novos-btn-primary js-safe-submit" OnClick="btnGlobalBuscar_Click"><i class="fa fa-search"></i>Buscar no p&aacute;tio</asp:LinkButton>
                                                </div>
                                            </div>
                                            <asp:Literal ID="litGlobalResultado" runat="server"></asp:Literal>
                                        </div>
                                    </div>

                                    <asp:Literal ID="litResumoFixo" runat="server"></asp:Literal>

                                    <div class="novos-tabs" role="tablist" aria-label="Fun&ccedil;&otilde;es de ve&iacute;culos novos">
                                        <asp:LinkButton ID="tabRegistrar" runat="server" CssClass="novos-tab" CommandArgument="registrar" OnClick="Aba_Click"><i class="fa fa-folder-plus"></i>Registrar</asp:LinkButton>
                                        <asp:LinkButton ID="tabTransferir" runat="server" CssClass="novos-tab" CommandArgument="transferir" OnClick="Aba_Click"><i class="fa fa-exchange-alt"></i>Transferir</asp:LinkButton>
                                        <asp:LinkButton ID="tabConsultar" runat="server" CssClass="novos-tab" CommandArgument="consultar" OnClick="Aba_Click"><i class="fa fa-search"></i>Consultar</asp:LinkButton>
                                        <asp:LinkButton ID="tabRelatorios" runat="server" CssClass="novos-tab" CommandArgument="relatorios" OnClick="Aba_Click"><i class="fa fa-chart-line"></i>Relat&oacute;rios</asp:LinkButton>
                                        <asp:LinkButton ID="tabTodos" runat="server" CssClass="novos-tab" CommandArgument="todos" OnClick="Aba_Click"><i class="fa fa-layer-group"></i>Todos</asp:LinkButton>
                                    </div>

                                    <asp:Panel ID="pnlMensagem" runat="server" CssClass="novos-alert" Visible="false">
                                        <i class="fa fa-info-circle mt-1"></i>
                                        <div><asp:Literal ID="litMensagem" runat="server"></asp:Literal></div>
                                    </asp:Panel>

                                    <asp:Panel ID="pnlTodos" runat="server">
                                        <div class="novos-card">
                                            <div class="novos-card-header">
                                                <div>
                                                    <small>Vis&atilde;o unificada</small>
                                                    <h2 class="novos-card-title">Novos e seminovos no p&aacute;tio</h2>
                                                </div>
                                                <div class="novos-print-toolbar">
                                                    <asp:LinkButton ID="btnTodosExportar" runat="server" CssClass="novos-btn novos-btn-light" OnClick="btnTodosExportar_Click"><i class="fa fa-file-excel"></i>Exportar</asp:LinkButton>
                                                    <button type="button" class="novos-btn novos-btn-light" onclick="window.print();"><i class="fa fa-print"></i>Imprimir</button>
                                                    <a class="novos-btn novos-btn-light" href="auditoria.aspx"><i class="fa fa-shield-alt"></i>Auditoria</a>
                                                </div>
                                            </div>
                                            <div class="novos-card-body">
                                                <div class="novos-grid">
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlTodosTipo.ClientID %>">Tipo</label>
                                                        <asp:DropDownList ID="ddlTodosTipo" runat="server" CssClass="novos-select">
                                                            <asp:ListItem Value="">Todos</asp:ListItem>
                                                            <asp:ListItem Value="NOVO">Novos</asp:ListItem>
                                                            <asp:ListItem Value="SEMINOVO">Seminovos</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlTodosLoja.ClientID %>">Loja</label>
                                                        <asp:DropDownList ID="ddlTodosLoja" runat="server" CssClass="novos-select"></asp:DropDownList>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlTodosStatus.ClientID %>">Status</label>
                                                        <asp:DropDownList ID="ddlTodosStatus" runat="server" CssClass="novos-select">
                                                            <asp:ListItem Value="">Todos ativos</asp:ListItem>
                                                            <asp:ListItem Value="NO_PATIO">No p&aacute;tio</asp:ListItem>
                                                            <asp:ListItem Value="PREPARACAO">Prepara&ccedil;&atilde;o</asp:ListItem>
                                                            <asp:ListItem Value="AGUARDANDO_DOCUMENTACAO">Aguardando documenta&ccedil;&atilde;o</asp:ListItem>
                                                            <asp:ListItem Value="AGUARDANDO_RETIRADA">Aguardando retirada</asp:ListItem>
                                                            <asp:ListItem Value="PENDENTE">Pendente</asp:ListItem>
                                                            <asp:ListItem Value="VENDIDO">Vendido</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlTodosParados.ClientID %>">Parados</label>
                                                        <asp:DropDownList ID="ddlTodosParados" runat="server" CssClass="novos-select">
                                                            <asp:ListItem Value="0">Todos</asp:ListItem>
                                                            <asp:ListItem Value="15">15 dias ou mais</asp:ListItem>
                                                            <asp:ListItem Value="30">30 dias ou mais</asp:ListItem>
                                                            <asp:ListItem Value="60">60 dias ou mais</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlTodosTamanho.ClientID %>">Linhas por p&aacute;gina</label>
                                                        <asp:DropDownList ID="ddlTodosTamanho" runat="server" CssClass="novos-select">
                                                            <asp:ListItem Value="25">25</asp:ListItem>
                                                            <asp:ListItem Value="50" Selected="True">50</asp:ListItem>
                                                            <asp:ListItem Value="100">100</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="novos-field is-wide">
                                                        <label class="novos-label" for="<%= txtTodosBusca.ClientID %>">Busca</label>
                                                        <asp:TextBox ID="txtTodosBusca" runat="server" CssClass="novos-input" MaxLength="60" autocomplete="off" placeholder="Modelo, c&oacute;digo, chassi, placa, Renavam ou usu&aacute;rio"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="novos-actions">
                                                    <asp:LinkButton ID="btnTodosConsultar" runat="server" CssClass="novos-btn novos-btn-primary js-safe-submit" OnClick="btnTodosConsultar_Click"><i class="fa fa-filter"></i>Aplicar filtros</asp:LinkButton>
                                                    <asp:LinkButton ID="btnTodosLimpar" runat="server" CssClass="novos-btn novos-btn-light" OnClick="btnTodosLimpar_Click"><i class="fa fa-eraser"></i>Limpar</asp:LinkButton>
                                                </div>
                                                <asp:Literal ID="litTodosHoje" runat="server"></asp:Literal>
                                                <asp:Literal ID="litTodosAlertas" runat="server"></asp:Literal>
                                                <div class="mt-3 novos-table-wrap">
                                                    <asp:Literal ID="litTodosTabela" runat="server"></asp:Literal>
                                                </div>
                                                <div class="novos-pager">
                                                    <asp:LinkButton ID="btnTodosAnterior" runat="server" CssClass="novos-btn novos-btn-light" OnClick="btnTodosAnterior_Click"><i class="fa fa-chevron-left"></i>Anterior</asp:LinkButton>
                                                    <asp:Literal ID="litTodosPaginacao" runat="server"></asp:Literal>
                                                    <asp:LinkButton ID="btnTodosProxima" runat="server" CssClass="novos-btn novos-btn-light" OnClick="btnTodosProxima_Click">Pr&oacute;xima<i class="fa fa-chevron-right"></i></asp:LinkButton>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="novos-card">
                                            <div class="novos-card-header">
                                                <div>
                                                    <small>Status, observa&ccedil;&atilde;o e baixa manual</small>
                                                    <h2 class="novos-card-title">Manuten&ccedil;&atilde;o operacional</h2>
                                                </div>
                                                <span class="novos-pill"><i class="fa fa-lock"></i> Baixa manual exige senha</span>
                                            </div>
                                            <div class="novos-card-body">
                                                <div class="novos-grid">
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlOperTipo.ClientID %>">Tipo</label>
                                                        <asp:DropDownList ID="ddlOperTipo" runat="server" CssClass="novos-select">
                                                            <asp:ListItem Value="NOVO">Novo</asp:ListItem>
                                                            <asp:ListItem Value="SEMINOVO">Seminovo</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="novos-field is-wide">
                                                        <label class="novos-label" for="<%= txtOperBusca.ClientID %>">Ve&iacute;culo</label>
                                                        <asp:TextBox ID="txtOperBusca" runat="server" CssClass="novos-input" MaxLength="60" autocomplete="off" placeholder="C&oacute;digo, chassi, placa ou Renavam"></asp:TextBox>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label">&nbsp;</label>
                                                        <asp:LinkButton ID="btnOperBuscar" runat="server" CssClass="novos-btn novos-btn-light js-safe-submit" OnClick="btnOperBuscar_Click"><i class="fa fa-search"></i>Localizar</asp:LinkButton>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlOperStatus.ClientID %>">Status</label>
                                                        <asp:DropDownList ID="ddlOperStatus" runat="server" CssClass="novos-select">
                                                            <asp:ListItem Value="NO_PATIO">No p&aacute;tio</asp:ListItem>
                                                            <asp:ListItem Value="PREPARACAO">Prepara&ccedil;&atilde;o</asp:ListItem>
                                                            <asp:ListItem Value="AGUARDANDO_DOCUMENTACAO">Aguardando documenta&ccedil;&atilde;o</asp:ListItem>
                                                            <asp:ListItem Value="AGUARDANDO_RETIRADA">Aguardando retirada</asp:ListItem>
                                                            <asp:ListItem Value="PENDENTE">Pendente</asp:ListItem>
                                                            <asp:ListItem Value="VENDIDO">Vendido</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="novos-field is-wide">
                                                        <label class="novos-label" for="<%= txtOperObservacao.ClientID %>">Observa&ccedil;&atilde;o</label>
                                                        <asp:TextBox ID="txtOperObservacao" runat="server" CssClass="novos-textarea" TextMode="MultiLine" MaxLength="500" placeholder="Observa&ccedil;&atilde;o curta para a opera&ccedil;&atilde;o"></asp:TextBox>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= txtOperSenha.ClientID %>">Senha para baixa</label>
                                                        <asp:TextBox ID="txtOperSenha" runat="server" CssClass="novos-input" TextMode="Password" autocomplete="new-password" placeholder="@bali2025"></asp:TextBox>
                                                    </div>
                                                    <div class="novos-field is-wide">
                                                        <label class="novos-label" for="<%= txtOperMotivoBaixa.ClientID %>">Motivo da baixa manual</label>
                                                        <asp:TextBox ID="txtOperMotivoBaixa" runat="server" CssClass="novos-input" MaxLength="500" autocomplete="off" placeholder="Ex.: baixa conferida manualmente"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="novos-actions">
                                                    <asp:LinkButton ID="btnOperAtualizar" runat="server" CssClass="novos-btn novos-btn-primary js-safe-submit" OnClick="btnOperAtualizar_Click"><i class="far fa-save"></i>Salvar status</asp:LinkButton>
                                                    <asp:LinkButton ID="btnOperBaixar" runat="server" CssClass="novos-btn novos-btn-danger js-safe-submit" OnClick="btnOperBaixar_Click" OnClientClick="return patioConfirmBaixa();"><i class="fa fa-check-circle"></i>Dar baixa manual</asp:LinkButton>
                                                </div>
                                                <asp:Literal ID="litOperVeiculo" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <asp:Panel ID="pnlRegistrar" runat="server">
                                        <div class="novos-card">
                                            <div class="novos-card-header">
                                                <div>
                                                    <small>Entrada de ve&iacute;culo novo</small>
                                                    <h2 class="novos-card-title">Registrar no p&aacute;tio</h2>
                                                </div>
                                                <span class="novos-pill"><i class="fa fa-route"></i> Fluxo guiado</span>
                                            </div>
                                            <div class="novos-card-body">
                                                <asp:Literal ID="litRegistroStepper" runat="server"></asp:Literal>
                                                <div class="novos-grid">
                                                    <div class="novos-field is-wide">
                                                        <label class="novos-label" for="<%= txtRegistroSerie.ClientID %>">S&eacute;rie do chassi</label>
                                                        <asp:TextBox ID="txtRegistroSerie" runat="server" CssClass="novos-input" MaxLength="17" autocomplete="off" placeholder="Digite os 7 &uacute;ltimos caracteres ou cole o chassi completo"></asp:TextBox>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlRegistroLoja.ClientID %>">Loja inicial</label>
                                                        <asp:DropDownList ID="ddlRegistroLoja" runat="server" CssClass="novos-select"></asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="novos-actions">
                                                    <button type="button" id="openBarcodeScanner" data-toggle="modal" data-target="#myModal" class="novos-btn novos-btn-light"><i class="fa fa-barcode"></i>Ler pela c&acirc;mera</button>
                                                    <asp:LinkButton ID="btnPesquisarRegistro" runat="server" CssClass="novos-btn novos-btn-light js-safe-submit" OnClick="btnPesquisarRegistro_Click"><i class="fa fa-search-location"></i>Buscar ve&iacute;culo</asp:LinkButton>
                                                    <asp:LinkButton ID="btnSalvarRegistro" runat="server" CssClass="novos-btn novos-btn-primary js-safe-submit" OnClick="btnSalvarRegistro_Click"><i class="far fa-save"></i>Salvar registro</asp:LinkButton>
                                                </div>
                                                <asp:Literal ID="litRegistroVeiculo" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <asp:Panel ID="pnlTransferir" runat="server">
                                        <div class="novos-card">
                                            <div class="novos-card-header">
                                                <div>
                                                    <small>Movimenta&ccedil;&atilde;o de ve&iacute;culo novo</small>
                                                    <h2 class="novos-card-title">Transferir loja</h2>
                                                </div>
                                                <span class="novos-pill"><i class="fa fa-check-double"></i> Confirma&ccedil;&atilde;o obrigat&oacute;ria</span>
                                            </div>
                                            <div class="novos-card-body">
                                                <div class="novos-grid">
                                                    <div class="novos-field is-wide">
                                                        <label class="novos-label" for="<%= txtTransferenciaSerie.ClientID %>">S&eacute;rie, chassi, placa, Renavam ou c&oacute;digo</label>
                                                        <asp:TextBox ID="txtTransferenciaSerie" runat="server" CssClass="novos-input" MaxLength="40" autocomplete="off" placeholder="Digite para localizar o ve&iacute;culo no p&aacute;tio"></asp:TextBox>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlTransferenciaDestino.ClientID %>">Loja destino</label>
                                                        <asp:DropDownList ID="ddlTransferenciaDestino" runat="server" CssClass="novos-select"></asp:DropDownList>
                                                    </div>
                                                    <div class="novos-field is-full">
                                                        <label class="novos-pill" style="justify-content:flex-start;">
                                                            <asp:CheckBox ID="chkConfirmarTransferencia" runat="server" />
                                                            <span><asp:Literal ID="litConfirmacaoTransferencia" runat="server" Text="Pesquise um ve&iacute;culo para gerar a confirma&ccedil;&atilde;o."></asp:Literal></span>
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="novos-actions">
                                                    <asp:LinkButton ID="btnBuscarTransferencia" runat="server" CssClass="novos-btn novos-btn-light js-safe-submit" OnClick="btnBuscarTransferencia_Click"><i class="fa fa-search"></i>Localizar</asp:LinkButton>
                                                    <asp:LinkButton ID="btnTransferir" runat="server" CssClass="novos-btn novos-btn-primary js-safe-submit" OnClick="btnTransferir_Click"><i class="fa fa-exchange-alt"></i>Transferir</asp:LinkButton>
                                                </div>
                                                <asp:Literal ID="litTransferenciaVeiculo" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <asp:Panel ID="pnlConsultar" runat="server">
                                        <div class="novos-card">
                                            <div class="novos-card-header">
                                                <div>
                                                    <small>Consulta operacional</small>
                                                    <h2 class="novos-card-title">Ve&iacute;culos novos no p&aacute;tio</h2>
                                                </div>
                                            </div>
                                            <div class="novos-card-body">
                                                <div class="novos-grid">
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlConsultaLoja.ClientID %>">Loja</label>
                                                        <asp:DropDownList ID="ddlConsultaLoja" runat="server" CssClass="novos-select"></asp:DropDownList>
                                                    </div>
                                                    <div class="novos-field is-wide">
                                                        <label class="novos-label" for="<%= txtConsultaBusca.ClientID %>">Busca</label>
                                                        <asp:TextBox ID="txtConsultaBusca" runat="server" CssClass="novos-input" MaxLength="40" autocomplete="off" placeholder="Modelo, c&oacute;digo, s&eacute;rie, chassi, placa ou Renavam"></asp:TextBox>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlConsultaTamanho.ClientID %>">Linhas</label>
                                                        <asp:DropDownList ID="ddlConsultaTamanho" runat="server" CssClass="novos-select">
                                                            <asp:ListItem Value="25">25</asp:ListItem>
                                                            <asp:ListItem Value="50" Selected="True">50</asp:ListItem>
                                                            <asp:ListItem Value="100">100</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="novos-actions">
                                                    <asp:LinkButton ID="btnConsultar" runat="server" CssClass="novos-btn novos-btn-primary js-safe-submit" OnClick="btnConsultar_Click"><i class="fa fa-filter"></i>Consultar</asp:LinkButton>
                                                    <asp:LinkButton ID="btnLimparConsulta" runat="server" CssClass="novos-btn novos-btn-light" OnClick="btnLimparConsulta_Click"><i class="fa fa-eraser"></i>Limpar</asp:LinkButton>
                                                </div>
                                                <asp:Literal ID="litConsultaDetalhe" runat="server"></asp:Literal>
                                                <div class="mt-3 novos-table-wrap">
                                                    <asp:Literal ID="litConsultaTabela" runat="server"></asp:Literal>
                                                </div>
                                                <div class="novos-pager">
                                                    <asp:LinkButton ID="btnConsultaAnterior" runat="server" CssClass="novos-btn novos-btn-light" OnClick="btnConsultaAnterior_Click"><i class="fa fa-chevron-left"></i>Anterior</asp:LinkButton>
                                                    <asp:Literal ID="litConsultaPaginacao" runat="server"></asp:Literal>
                                                    <asp:LinkButton ID="btnConsultaProxima" runat="server" CssClass="novos-btn novos-btn-light" OnClick="btnConsultaProxima_Click">Pr&oacute;xima<i class="fa fa-chevron-right"></i></asp:LinkButton>
                                                </div>
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <asp:Panel ID="pnlRelatorios" runat="server">
                                        <div class="novos-card">
                                            <div class="novos-card-header">
                                                <div>
                                                    <small>BI de ve&iacute;culos novos</small>
                                                    <h2 class="novos-card-title">Relat&oacute;rios</h2>
                                                </div>
                                                <asp:LinkButton ID="btnAtualizarRelatorio" runat="server" CssClass="novos-btn novos-btn-light js-safe-submit" OnClick="btnAtualizarRelatorio_Click"><i class="fa fa-sync-alt"></i>Atualizar</asp:LinkButton>
                                            </div>
                                            <div class="novos-card-body">
                                                <div class="novos-grid">
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= ddlRelatorioLoja.ClientID %>">Loja</label>
                                                        <asp:DropDownList ID="ddlRelatorioLoja" runat="server" CssClass="novos-select"></asp:DropDownList>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label" for="<%= txtRelatorioUsuario.ClientID %>">Usu&aacute;rio</label>
                                                        <asp:TextBox ID="txtRelatorioUsuario" runat="server" CssClass="novos-input" MaxLength="60" autocomplete="off" placeholder="Opcional"></asp:TextBox>
                                                    </div>
                                                    <div class="novos-field">
                                                        <label class="novos-label">Per&iacute;odo</label>
                                                        <asp:Literal ID="litRelatorioPeriodo" runat="server"></asp:Literal>
                                                    </div>
                                                </div>
                                                <div class="novos-quick-filters">
                                                    <asp:LinkButton ID="btnFiltroHoje" runat="server" CssClass="novos-mini-action" CommandArgument="hoje" OnClick="FiltroRelatorio_Click"><i class="fa fa-calendar-day"></i>Hoje</asp:LinkButton>
                                                    <asp:LinkButton ID="btnFiltro7Dias" runat="server" CssClass="novos-mini-action" CommandArgument="7dias" OnClick="FiltroRelatorio_Click"><i class="fa fa-calendar-week"></i>&Uacute;ltimos 7 dias</asp:LinkButton>
                                                    <asp:LinkButton ID="btnFiltroMes" runat="server" CssClass="novos-mini-action" CommandArgument="mes" OnClick="FiltroRelatorio_Click"><i class="fa fa-calendar-alt"></i>Este m&ecirc;s</asp:LinkButton>
                                                    <asp:LinkButton ID="btnFiltroTodos" runat="server" CssClass="novos-mini-action" CommandArgument="todos" OnClick="FiltroRelatorio_Click"><i class="fa fa-layer-group"></i>Todos ativos</asp:LinkButton>
                                                </div>
                                                <asp:Literal ID="litResumoRelatorio" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                        <div class="novos-bi-grid">
                                            <div class="novos-card">
                                                <div class="novos-card-header"><div><small>Posi&ccedil;&atilde;o atual</small><h2 class="novos-card-title">Novos por loja</h2></div></div>
                                                <div class="novos-card-body"><asp:Literal ID="litEstoquePorLoja" runat="server"></asp:Literal></div>
                                            </div>
                                            <div class="novos-card">
                                                <div class="novos-card-header"><div><small>Entradas</small><h2 class="novos-card-title">Registros por dia</h2></div></div>
                                                <div class="novos-card-body"><asp:Literal ID="litEntradasDia" runat="server"></asp:Literal></div>
                                            </div>
                                        </div>
                                        <div class="novos-card">
                                            <div class="novos-card-header"><div><small>Movimenta&ccedil;&otilde;es</small><h2 class="novos-card-title">&Uacute;ltimas transfer&ecirc;ncias</h2></div></div>
                                            <div class="novos-card-body novos-table-wrap"><asp:Literal ID="litUltimasTransferencias" runat="server"></asp:Literal></div>
                                        </div>
                                        <div class="novos-bi-grid">
                                            <div class="novos-card">
                                                <div class="novos-card-header"><div><small>Usu&aacute;rios</small><h2 class="novos-card-title">Opera&ccedil;&atilde;o por usu&aacute;rio</h2></div></div>
                                                <div class="novos-card-body"><asp:Literal ID="litDashboardUsuarios" runat="server"></asp:Literal></div>
                                            </div>
                                            <div class="novos-card">
                                                <div class="novos-card-header"><div><small>Confer&ecirc;ncia</small><h2 class="novos-card-title">Diverg&ecirc;ncias</h2></div></div>
                                                <div class="novos-card-body"><asp:Literal ID="litDivergencias" runat="server"></asp:Literal></div>
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <div class="novos-card">
                                        <div class="novos-card-header">
                                            <div>
                                                <small>Sess&atilde;o atual</small>
                                                <h2 class="novos-card-title">&Uacute;ltimos acessados</h2>
                                            </div>
                                        </div>
                                        <div class="novos-card-body">
                                            <asp:Literal ID="litUltimosAcessados" runat="server"></asp:Literal>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <asp:Panel ID="pnlHistoricoModal" runat="server" CssClass="novos-modal" Visible="false">
                                <div class="novos-modal-card">
                                    <div class="novos-modal-header">
                                        <div>
                                            <small>Log vis&iacute;vel por ve&iacute;culo</small>
                                            <h2 class="novos-card-title">Hist&oacute;rico do ve&iacute;culo</h2>
                                        </div>
                                        <asp:LinkButton ID="btnFecharHistorico" runat="server" CssClass="novos-mini-action" OnClick="btnFecharHistorico_Click"><i class="fa fa-times"></i>Fechar</asp:LinkButton>
                                    </div>
                                    <div class="novos-modal-body novos-table-wrap">
                                        <asp:Literal ID="litHistoricoModal" runat="server"></asp:Literal>
                                    </div>
                                </div>
                            </asp:Panel>

                            <div class="novos-mobile-actions">
                                <asp:LinkButton ID="btnMobileGlobal" runat="server" CssClass="novos-btn novos-btn-light" OnClick="btnGlobalBuscar_Click"><i class="fa fa-search"></i>Buscar</asp:LinkButton>
                                <asp:LinkButton ID="btnMobileSalvar" runat="server" CssClass="novos-btn novos-btn-primary js-safe-submit" OnClick="btnSalvarRegistro_Click"><i class="far fa-save"></i>Salvar</asp:LinkButton>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <asp:UpdateProgress ID="UpdateProgress1" DisplayAfter="120" DynamicLayout="true" runat="server" AssociatedUpdatePanelID="updatePanel">
                        <ProgressTemplate>
                            <div class="novos-alert" style="position:fixed;right:1rem;bottom:4rem;z-index:1055;background:#fff;box-shadow:0 18px 44px rgba(15,23,42,.18);">
                                <i class="fa fa-spinner fa-spin mt-1"></i><div><strong>Processando</strong><span>Aguarde alguns instantes.</span></div>
                            </div>
                        </ProgressTemplate>
                    </asp:UpdateProgress>
                    <footer class="fixed-bottom bg-dark">
                        <div class="container text-center text-white mb-2 mt-2">
                            <b>TI - GRUPO BALI</b>
                        </div>
                    </footer>
                </div>
            </div>
        </div>
    </form>

    <div class="modal barcode-modal" id="myModal" tabindex="-1" role="dialog" aria-labelledby="barcodeModalTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="barcodeModalTitle"><i class="fa fa-barcode"></i> Leitor de c&oacute;digo pela c&acirc;mera</h4>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Fechar">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="scanner-stage">
                        <video id="scanner-video" class="is-hidden" muted autoplay playsinline></video>
                        <div id="scanner-container" class="is-hidden"></div>
                        <div class="scanner-reticle"></div>
                        <div class="scanner-hint">
                            <span class="scanner-pill"><i class="fa fa-mobile-alt"></i> Aproxime o c&oacute;digo da faixa central</span>
                            <span class="scanner-pill" id="scannerEngine">Preparando c&acirc;mera</span>
                        </div>
                    </div>
                    <div class="scanner-tools">
                        <select id="scannerCameraSelect" class="form-control is-hidden" aria-label="Selecionar c&acirc;mera"></select>
                        <button type="button" id="scannerSwitchCamera" class="btn btn-outline-dark is-hidden"><i class="fa fa-sync-alt mr-1"></i> Trocar c&acirc;mera</button>
                    </div>
                    <label id="scannerZoomGroup" class="scanner-zoom is-hidden">
                        <span>Zoom da c&acirc;mera</span>
                        <input type="range" id="scannerZoom" min="1" max="1" step="0.1" value="1" />
                    </label>
                    <div id="scannerStatus" class="scanner-status" aria-live="polite">Ao permitir a c&acirc;mera, a leitura come&ccedil;a automaticamente.</div>
                    <div class="scanner-manual">
                        <input type="text" id="scannerManualSerie" class="form-control" inputmode="text" pattern="[A-Za-z0-9]*" maxlength="7" placeholder="Digitar s&eacute;rie manualmente" autocomplete="off" autocapitalize="characters" spellcheck="false" />
                        <button type="button" id="scannerApplyManual" class="btn btn-success"><i class="fa fa-check mr-1"></i> Usar s&eacute;rie</button>
                    </div>
                    <details class="scanner-help">
                        <summary>N&atilde;o conseguiu ler?</summary>
                        <ul>
                            <li>Limpe a lente da c&acirc;mera e evite reflexo direto no c&oacute;digo.</li>
                            <li>Aproxime devagar at&eacute; o c&oacute;digo preencher a faixa central.</li>
                            <li>Se o celular abrir a c&acirc;mera errada, use Trocar c&acirc;mera.</li>
                            <li>Se ainda falhar, digite manualmente os 7 caracteres da s&eacute;rie.</li>
                        </ul>
                    </details>
                    <div class="scanner-actions">
                        <div>
                            <small class="text-muted">Resultado: <strong id="result">aguardando leitura</strong></small>
                            <small class="text-muted d-block">C&oacute;digo lido: <span id="scannerLastRaw">-</span></small>
                        </div>
                        <div>
                            <button type="button" id="scannerTorch" class="btn btn-outline-secondary is-hidden"><i class="fa fa-lightbulb mr-1"></i> Luz</button>
                            <button type="button" id="scannerRetry" class="btn btn-outline-dark"><i class="fa fa-redo mr-1"></i> Reiniciar</button>
                            <button type="button" id="scannerDiagnostics" class="btn btn-outline-info"><i class="fa fa-stethoscope mr-1"></i> Enviar diagn&oacute;stico</button>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-lg btn-danger" data-dismiss="modal">Cancelar leitura</button>
                </div>
            </div>
        </div>
    </div>

    <script src="../assets/popper.min.js"></script>
    <script src="../assets/bootstrap.min.js"></script>
    <script src="../assets/scripts/main.js"></script>
    <script>
        window.PatioBarcodeScannerConfig = {
            serieInputId: '<%= txtRegistroSerie.ClientID %>',
            searchButtonId: '<%= btnPesquisarRegistro.ClientID %>',
            postBackTarget: '<%= btnPesquisarRegistro.UniqueID %>',
            logEndpoint: './barcode-log.ashx'
        };
    </script>
    <script src="./assets/js/patio-barcode-scanner.js?v=20260706-1" charset="utf-8"></script>
    <script src="./assets/js/patio-jeep-ux.js?v=20260706-5"></script>
    <script>
        (function () {
            function textOf(el) { return el ? (el.textContent || '').trim() : ''; }
            window.patioConfirmBaixa = function () {
                var veiculo = document.getElementById('<%= hfOperVeNr.ClientID %>');
                var tipo = document.getElementById('<%= hfOperTipo.ClientID %>');
                var motivo = document.getElementById('<%= txtOperMotivoBaixa.ClientID %>');
                var valor = motivo ? (motivo.value || '').trim() : '';
                if (!veiculo || !veiculo.value) {
                    alert('Localize o veiculo antes de registrar uma baixa manual.');
                    return false;
                }
                if (!valor) {
                    alert('Informe o motivo da baixa manual antes de continuar.');
                    if (motivo) motivo.focus();
                    return false;
                }
                return confirm('Confirmar baixa manual do veiculo ' + veiculo.value + ' (' + (tipo ? tipo.value : 'PATIO') + ')? Esta acao ficara registrada em auditoria.');
            };

            var globalInput = document.getElementById('<%= txtGlobalBusca.ClientID %>');
            var globalPanel = document.getElementById('novosGlobalSuggestions');
            var globalTimer = null;
            function escapeHtml(value) {
                return String(value || '').replace(/[&<>"']/g, function (char) {
                    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[char];
                });
            }
            function closeSuggestions() {
                if (!globalPanel) return;
                globalPanel.classList.remove('is-open');
                globalPanel.innerHTML = '';
            }
            function renderSuggestions(items) {
                if (!globalPanel) return;
                if (!items || !items.length) {
                    closeSuggestions();
                    return;
                }
                globalPanel.innerHTML = items.map(function (item) {
                    var veiculo = String(item.veNr || '');
                    var tipo = String(item.tipo || '');
                    var modelo = escapeHtml(item.modelo || '-');
                    var loja = escapeHtml(item.loja || '-');
                    var chassi = escapeHtml(item.chassi || '-');
                    var tipoSeguro = escapeHtml(tipo);
                    var veiculoSeguro = escapeHtml(veiculo);
                    return '<a href="novos.aspx?aba=todos&amp;operTipo=' + encodeURIComponent(tipo.toUpperCase()) + '&amp;operBusca=' + encodeURIComponent(veiculo) + '">' +
                        '<span>' + modelo + '<small>' + tipoSeguro + ' #' + veiculoSeguro + ' &middot; ' + chassi + '</small></span>' +
                        '<small>' + loja + '</small>' +
                        '</a>';
                }).join('');
                globalPanel.classList.add('is-open');
            }
            if (globalInput && globalPanel && window.fetch) {
                globalInput.addEventListener('input', function () {
                    var value = (globalInput.value || '').trim();
                    clearTimeout(globalTimer);
                    if (value.length < 3) {
                        closeSuggestions();
                        return;
                    }
                    globalTimer = setTimeout(function () {
                        fetch('./patio-sugestoes.ashx?q=' + encodeURIComponent(value), { credentials: 'same-origin' })
                            .then(function (response) { return response.ok ? response.json() : []; })
                            .then(renderSuggestions)
                            .catch(closeSuggestions);
                    }, 260);
                });
                document.addEventListener('click', function (event) {
                    if (!globalPanel.contains(event.target) && event.target !== globalInput) closeSuggestions();
                });
            }

            document.addEventListener('click', function (event) {
                var copyButton = event.target.closest ? event.target.closest('[data-copy]') : null;
                if (copyButton) {
                    event.preventDefault();
                    var value = copyButton.getAttribute('data-copy') || '';
                    var label = copyButton.getAttribute('data-copy-label') || 'Informa\u00e7\u00e3o';
                    if (navigator.clipboard && navigator.clipboard.writeText) {
                        navigator.clipboard.writeText(value);
                    }
                    if (window.patioToast) window.patioToast(label + ' copiado.', 'info');
                }
            });

            if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                var manager = Sys.WebForms.PageRequestManager.getInstance();
                manager.add_beginRequest(function () {
                    var active = document.activeElement;
                    if (active && active.classList && active.classList.contains('js-safe-submit')) {
                        active.setAttribute('data-original-text', textOf(active));
                        active.classList.add('aspNetDisabled');
                        active.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Processando...';
                    }
                });
                manager.add_endRequest(function () {
                    var buttons = document.querySelectorAll('.js-safe-submit[data-original-text]');
                    for (var i = 0; i < buttons.length; i++) {
                        buttons[i].innerHTML = buttons[i].getAttribute('data-original-text');
                        buttons[i].removeAttribute('data-original-text');
                        buttons[i].classList.remove('aspNetDisabled');
                    }
                });
            }
        })();
    </script>
</body>
</html>
