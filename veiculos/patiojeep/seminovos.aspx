<%@ Page Language="C#" AutoEventWireup="true" CodeFile="seminovos.aspx.cs" Inherits="veiculos_patio_seminovos" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>SEMINOVOS | P&aacute;tio</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <script src="../assets/jquery-1.9.1.min.js"></script>
    <script src="../assets/jquery.dataTables.min.js"></script>
    <link href="../assets/dataTables.bootstrap4.min.css" rel="stylesheet" />
    <script src="../assets/dataTables.bootstrap4.min.js"></script>
    <link href="./main.css" rel="stylesheet" />
    <link href="../../css/bali-patio.css?v=20260704-1" rel="stylesheet" />
    <link href="../assets/all.min.css" rel="stylesheet" />
    <style>
        .semi-shell {
            display: grid;
            gap: 1rem;
        }

        .semi-tabs {
            display: flex;
            flex-wrap: wrap;
            gap: .65rem;
            margin-bottom: 1rem;
        }

        .semi-tab {
            display: inline-flex;
            align-items: center;
            gap: .5rem;
            border: 1px solid #dbe4ef;
            border-radius: 999px;
            padding: .72rem 1rem;
            background: #fff;
            color: #334155;
            font-weight: 900;
            box-shadow: 0 10px 24px rgba(15, 23, 42, .07);
            text-decoration: none !important;
            transition: transform .18s ease, border-color .18s ease, box-shadow .18s ease, background .18s ease;
        }

        .semi-tab:hover {
            transform: translateY(-1px);
            border-color: #8aa36f;
            color: #203729;
        }

        .semi-tab.is-active {
            background: linear-gradient(135deg, #203729, #6f9151);
            border-color: transparent;
            color: #fff;
            box-shadow: 0 16px 34px rgba(32, 55, 41, .22);
        }

        .semi-card {
            border: 1px solid #dbe4ef;
            border-radius: 18px;
            background: rgba(255, 255, 255, .97);
            box-shadow: 0 16px 40px rgba(15, 23, 42, .08);
            overflow: hidden;
        }

        .semi-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            padding: 1rem 1.15rem;
            border-bottom: 1px solid #e2e8f0;
            background: linear-gradient(180deg, #fff, #f8fafc);
        }

        .semi-card-header small {
            display: block;
            color: #64748b;
            font-weight: 850;
        }

        .semi-card-title {
            margin: 0;
            color: #0f172a;
            font-size: 1.05rem;
            font-weight: 950;
        }

        .semi-card-body {
            padding: 1.15rem;
        }

        .semi-form-grid {
            display: grid;
            grid-template-columns: repeat(12, minmax(0, 1fr));
            gap: .9rem;
        }

        .semi-field {
            grid-column: span 4;
            display: grid;
            gap: .35rem;
        }

        .semi-field.is-wide {
            grid-column: span 8;
        }

        .semi-field.is-full {
            grid-column: 1 / -1;
        }

        .semi-label {
            color: #475569;
            font-size: .74rem;
            font-weight: 950;
            letter-spacing: .04em;
            text-transform: uppercase;
        }

        .semi-input,
        .semi-select,
        .semi-textarea {
            width: 100%;
            min-height: 46px;
            border: 1px solid #cfd9e6;
            border-radius: 12px;
            padding: .72rem .85rem;
            background: #fff;
            color: #0f172a;
            font-weight: 800;
            outline: none;
            transition: border-color .16s ease, box-shadow .16s ease;
        }

        .semi-textarea {
            min-height: 92px;
            resize: vertical;
        }

        .semi-input:focus,
        .semi-select:focus,
        .semi-textarea:focus {
            border-color: #6f9151;
            box-shadow: 0 0 0 4px rgba(111, 145, 81, .14);
        }

        .semi-search-control {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: .65rem;
            align-items: stretch;
        }

        .semi-search-control .semi-btn {
            min-width: 132px;
        }

        .semi-actions {
            display: flex;
            flex-wrap: wrap;
            gap: .7rem;
            align-items: center;
            margin-top: 1rem;
        }

        .semi-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: .5rem;
            min-height: 44px;
            border-radius: 12px;
            border: 1px solid transparent;
            padding: .7rem 1rem;
            font-weight: 950;
            text-decoration: none !important;
        }

        .semi-pager {
            display: flex;
            flex-wrap: wrap;
            gap: .65rem;
            align-items: center;
            justify-content: space-between;
            margin-top: 1rem;
            padding: .85rem 1rem;
            border: 1px solid #dbe4ef;
            border-radius: 16px;
            background: #f8fafc;
        }

        .semi-pager-info {
            color: #475569;
            font-weight: 900;
        }

        .semi-btn-primary {
            background: linear-gradient(135deg, #203729, #6f9151);
            color: #fff !important;
            box-shadow: 0 12px 28px rgba(32, 55, 41, .22);
        }

        .semi-btn-light {
            background: #fff;
            border-color: #cfd9e6;
            color: #334155 !important;
        }

        .semi-btn[disabled],
        .semi-btn.aspNetDisabled {
            opacity: .55;
            pointer-events: none;
        }

        .semi-alert {
            display: flex;
            align-items: flex-start;
            gap: .75rem;
            border-radius: 16px;
            padding: .9rem 1rem;
            margin-bottom: 1rem;
            border: 1px solid #dbe4ef;
            background: #f8fafc;
            color: #334155;
            font-weight: 800;
        }

        .semi-alert strong {
            display: block;
            color: #0f172a;
            font-weight: 950;
        }

        .semi-alert.is-success {
            border-color: #bbf7d0;
            background: #f0fdf4;
            color: #166534;
        }

        .semi-alert.is-warning {
            border-color: #fde68a;
            background: #fffbeb;
            color: #92400e;
        }

        .semi-alert.is-error {
            border-color: #fecaca;
            background: #fef2f2;
            color: #991b1b;
        }

        .semi-vehicle-card {
            border: 1px solid #cfe2c3;
            border-radius: 18px;
            background: linear-gradient(135deg, #f8fff5, #ffffff);
            padding: 1rem;
            margin-top: 1rem;
        }

        .semi-vehicle-main {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: 1rem;
            align-items: start;
        }

        .semi-vehicle-main strong {
            display: block;
            color: #0f172a;
            font-size: 1.15rem;
            font-weight: 950;
        }

        .semi-vehicle-main small {
            display: block;
            color: #64748b;
            font-weight: 800;
            margin-top: .2rem;
        }

        .semi-pill-list {
            display: flex;
            flex-wrap: wrap;
            gap: .55rem;
            margin-top: .85rem;
        }

        .semi-pill {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            border-radius: 999px;
            padding: .42rem .65rem;
            background: #eef6e9;
            color: #203729;
            font-size: .78rem;
            font-weight: 950;
        }

        .semi-location-pill {
            display: inline-flex;
            align-items: center;
            gap: .45rem;
            border-radius: 999px;
            padding: .5rem .75rem;
            background: #203729;
            color: #fff;
            font-size: .8rem;
            font-weight: 950;
            white-space: nowrap;
        }

        .semi-detail-panel {
            margin-top: 1rem;
            border: 1px solid #cfe2c3;
            border-radius: 18px;
            background: linear-gradient(135deg, #f8fff5, #ffffff);
            padding: 1rem;
        }

        .semi-detail-header {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: 1rem;
            align-items: start;
        }

        .semi-detail-header small {
            display: block;
            color: #64748b;
            font-weight: 900;
            letter-spacing: .04em;
            text-transform: uppercase;
        }

        .semi-detail-header strong {
            display: block;
            color: #0f172a;
            font-size: 1.2rem;
            font-weight: 950;
        }

        .semi-detail-header span {
            color: #64748b;
            font-weight: 800;
        }

        .semi-history-title {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            margin: 1rem 0 .65rem;
            color: #203729;
            font-weight: 950;
        }

        .semi-table-wrap {
            overflow-x: auto;
        }

        .semi-table {
            width: 100%;
            min-width: 860px;
            margin: 0;
            border-collapse: separate;
            border-spacing: 0;
        }

        .semi-table th {
            background: #f8fafc;
            color: #475569;
            font-size: .73rem;
            font-weight: 950;
            letter-spacing: .04em;
            text-transform: uppercase;
            white-space: nowrap;
            border-bottom: 1px solid #e2e8f0;
            padding: .75rem;
        }

        .semi-table td {
            color: #1f2937;
            font-weight: 750;
            vertical-align: middle;
            border-bottom: 1px solid #edf2f7;
            padding: .78rem;
        }

        .semi-table td small {
            display: block;
            color: #64748b;
            font-weight: 750;
        }

        .semi-row-actions {
            display: inline-flex;
            gap: .45rem;
            flex-wrap: wrap;
        }

        .semi-mini-action {
            display: inline-flex;
            align-items: center;
            gap: .35rem;
            border-radius: 999px;
            border: 1px solid #cfd9e6;
            background: #fff;
            color: #334155 !important;
            padding: .38rem .62rem;
            font-size: .76rem;
            font-weight: 950;
            text-decoration: none !important;
        }

        .semi-kpis {
            display: grid;
            grid-template-columns: repeat(5, minmax(140px, 1fr));
            gap: .85rem;
        }

        .semi-kpi {
            border: 1px solid #dbe4ef;
            border-radius: 16px;
            background: #fff;
            padding: .95rem;
            box-shadow: 0 12px 26px rgba(15, 23, 42, .07);
        }

        .semi-kpi small {
            display: block;
            color: #64748b;
            font-size: .72rem;
            font-weight: 950;
            letter-spacing: .04em;
            text-transform: uppercase;
        }

        .semi-kpi strong {
            display: block;
            margin-top: .35rem;
            color: #0f172a;
            font-size: clamp(1.35rem, 2.8vw, 2rem);
            line-height: 1;
            font-weight: 950;
        }

        .semi-bi-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            gap: 1rem;
        }

        .semi-bar-list {
            display: grid;
            gap: .75rem;
        }

        .semi-bar-row {
            display: grid;
            grid-template-columns: minmax(110px, .35fr) minmax(0, 1fr) 52px;
            gap: .7rem;
            align-items: center;
        }

        .semi-bar-label {
            color: #334155;
            font-weight: 900;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .semi-bar-track {
            height: 12px;
            border-radius: 999px;
            background: #edf2f7;
            overflow: hidden;
        }

        .semi-bar-track span {
            display: block;
            height: 100%;
            min-width: 3px;
            border-radius: inherit;
            background: linear-gradient(90deg, #6f9151, #203729);
        }

        .semi-empty {
            border: 1px dashed #cfd9e6;
            border-radius: 16px;
            padding: 1.2rem;
            background: #f8fafc;
            color: #64748b;
            font-weight: 850;
            text-align: center;
        }

        .semi-progress {
            position: fixed;
            right: 1rem;
            bottom: 4rem;
            z-index: 1040;
            display: flex;
            align-items: center;
            gap: .75rem;
            max-width: 360px;
            border: 1px solid #cfd9e6;
            border-radius: 18px;
            background: #fff;
            padding: .85rem 1rem;
            box-shadow: 0 18px 44px rgba(15, 23, 42, .18);
        }

        .semi-progress-spinner {
            width: 24px;
            height: 24px;
            border-radius: 999px;
            border: 3px solid #dbe4ef;
            border-top-color: #6f9151;
            animation: semiSpin .85s linear infinite;
        }

        .semi-quick-filters {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: .55rem;
            margin: .85rem 0 1rem;
        }

        .semi-period-pill {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            border-radius: 999px;
            padding: .42rem .72rem;
            background: #f8fafc;
            border: 1px solid #dbe4ef;
            color: #475569;
            font-weight: 900;
            font-size: .78rem;
        }

        .semi-filter-select {
            width: auto;
            min-width: 220px;
            min-height: 38px;
            border-radius: 999px;
            padding: .45rem .75rem;
            font-size: .82rem;
        }

        @keyframes semiSpin {
            to { transform: rotate(360deg); }
        }

        @media (max-width: 1199.98px) {
            .semi-kpis {
                grid-template-columns: repeat(3, minmax(140px, 1fr));
            }
        }

        @media (max-width: 991.98px) {
            .semi-field,
            .semi-field.is-wide {
                grid-column: span 6;
            }

            .semi-bi-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 767.98px) {
            .semi-card-header,
            .semi-vehicle-main,
            .semi-detail-header {
                grid-template-columns: 1fr;
                display: grid;
            }

            .semi-field,
            .semi-field.is-wide {
                grid-column: 1 / -1;
            }

            .semi-tabs {
                display: grid;
                grid-template-columns: 1fr 1fr;
            }

            .semi-tab {
                justify-content: center;
                border-radius: 14px;
            }

            .semi-kpis {
                grid-template-columns: 1fr 1fr;
            }

            .semi-search-control {
                grid-template-columns: 1fr;
            }

            .semi-search-control .semi-btn {
                width: 100%;
            }

            .semi-table,
            .semi-table thead,
            .semi-table tbody,
            .semi-table th,
            .semi-table td,
            .semi-table tr {
                display: block;
                min-width: 0;
                width: 100%;
            }

            .semi-table thead {
                display: none;
            }

            .semi-table tr {
                border: 1px solid #dbe4ef;
                border-radius: 16px;
                margin-bottom: .85rem;
                background: #fff;
                overflow: hidden;
            }

            .semi-table td {
                display: grid;
                grid-template-columns: 112px minmax(0, 1fr);
                gap: .65rem;
                border-bottom: 1px solid #edf2f7;
            }

            .semi-table td:before {
                content: attr(data-label);
                color: #64748b;
                font-size: .72rem;
                font-weight: 950;
                letter-spacing: .04em;
                text-transform: uppercase;
            }
        }

        @media (max-width: 480px) {
            .semi-tabs,
            .semi-kpis {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body class="patio-modern-page patio-brand-jeep" data-patio-page="seminovos.aspx">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <asp:HiddenField ID="hfAbaAtual" runat="server" />
        <asp:HiddenField ID="hfRegistroVeNr" runat="server" />
        <asp:HiddenField ID="hfRegistroReferencia" runat="server" />
        <asp:HiddenField ID="hfTransferenciaId" runat="server" />
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
                                <li><a href="./novos.aspx"><i class="metismenu-icon fas fa-car"></i>Novos</a></li>
                                <li><a href="./seminovos.aspx" class="mm-active"><i class="metismenu-icon fas fa-car-side"></i>Seminovos</a></li>
                                <li><a href="./lojas.aspx"><i class="metismenu-icon fas fa-store"></i>Lojas</a></li>
                                <li><a href="./barcode-logs.aspx"><i class="metismenu-icon fas fa-clipboard-list"></i>Logs do leitor</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="app-main__outer">
                    <asp:UpdatePanel ID="updatePanel" runat="server">
                        <ContentTemplate>
                            <div class="app-main__inner mb-3">
                                <div class="app-page-title text-white" style="background-color:#495057;">
                                    <div class="page-title-wrapper">
                                        <div class="page-title-heading">
                                            <div class="page-title-icon" style="background-color:#495057;">
                                                <i class="fas fa-car-side text-white"></i>
                                            </div>
                                            <div>
                                                <b>Seminovos</b>
                                                <div class="page-title-subheading">Registro, consulta, transfer&ecirc;ncia e BI de ve&iacute;culos seminovos no p&aacute;tio.</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="semi-shell">
                                    <div class="semi-tabs">
                                        <asp:LinkButton ID="tabRegistrar" runat="server" CssClass="semi-tab" CommandArgument="registrar" OnClick="Aba_Click"><i class="fa fa-folder-plus"></i>Registrar</asp:LinkButton>
                                        <asp:LinkButton ID="tabConsultar" runat="server" CssClass="semi-tab" CommandArgument="consultar" OnClick="Aba_Click"><i class="fa fa-search"></i>Consultar</asp:LinkButton>
                                        <asp:LinkButton ID="tabTransferir" runat="server" CssClass="semi-tab" CommandArgument="transferir" OnClick="Aba_Click"><i class="fa fa-exchange-alt"></i>Transferir</asp:LinkButton>
                                        <asp:LinkButton ID="tabRelatorios" runat="server" CssClass="semi-tab" CommandArgument="relatorios" OnClick="Aba_Click"><i class="fa fa-chart-line"></i>Relat&oacute;rios</asp:LinkButton>
                                    </div>

                                    <asp:Panel ID="pnlMensagem" runat="server" CssClass="semi-alert" Visible="false">
                                        <i class="fa fa-info-circle mt-1"></i>
                                        <div><asp:Literal ID="litMensagem" runat="server"></asp:Literal></div>
                                    </asp:Panel>

                                    <asp:Panel ID="pnlRegistrar" runat="server">
                                        <div class="semi-card">
                                            <div class="semi-card-header">
                                                <div>
                                                    <small>Entrada de seminovo</small>
                                                    <h2 class="semi-card-title">Registrar ve&iacute;culo</h2>
                                                </div>
                                                <span class="semi-pill"><i class="fa fa-keyboard"></i> Chassi, placa ou Renavam</span>
                                            </div>
                                            <div class="semi-card-body">
                                                <div class="semi-form-grid">
                                                    <div class="semi-field is-wide">
                                                        <label class="semi-label" for="<%= txtRegistroBusca.ClientID %>">Identifica&ccedil;&atilde;o do ve&iacute;culo</label>
                                                        <div class="semi-search-control">
                                                            <asp:TextBox ID="txtRegistroBusca" runat="server" CssClass="semi-input" MaxLength="40" autocomplete="off" placeholder="Digite chassi completo, placa ou Renavam"></asp:TextBox>
                                                            <asp:LinkButton ID="btnPesquisarRegistro" runat="server" CssClass="semi-btn semi-btn-light js-safe-submit" OnClick="btnPesquisarRegistro_Click"><i class="fa fa-search"></i>Pesquisar</asp:LinkButton>
                                                        </div>
                                                    </div>
                                                    <div class="semi-field">
                                                        <label class="semi-label" for="<%= ddlRegistroLoja.ClientID %>">Loja inicial</label>
                                                        <asp:DropDownList ID="ddlRegistroLoja" runat="server" CssClass="semi-select"></asp:DropDownList>
                                                    </div>
                                                    <div class="semi-field is-full">
                                                        <label class="semi-label" for="<%= txtRegistroObservacao.ClientID %>">Observa&ccedil;&atilde;o</label>
                                                        <asp:TextBox ID="txtRegistroObservacao" runat="server" CssClass="semi-textarea" TextMode="MultiLine" MaxLength="250" placeholder="Opcional: informe algum detalhe operacional do registro"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="semi-actions">
                                                    <asp:LinkButton ID="btnSalvarRegistro" runat="server" CssClass="semi-btn semi-btn-primary js-safe-submit" OnClick="btnSalvarRegistro_Click"><i class="far fa-save"></i>Salvar registro</asp:LinkButton>
                                                </div>
                                                <asp:Literal ID="litRegistroVeiculo" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <asp:Panel ID="pnlConsultar" runat="server">
                                        <div class="semi-card">
                                            <div class="semi-card-header">
                                                <div>
                                                    <small>Consulta operacional</small>
                                                    <h2 class="semi-card-title">Ve&iacute;culos seminovos registrados</h2>
                                                </div>
                                            </div>
                                            <div class="semi-card-body">
                                                <div class="semi-form-grid">
                                                    <div class="semi-field">
                                                        <label class="semi-label" for="<%= ddlConsultaLoja.ClientID %>">Loja</label>
                                                        <asp:DropDownList ID="ddlConsultaLoja" runat="server" CssClass="semi-select"></asp:DropDownList>
                                                    </div>
                                                    <div class="semi-field is-wide">
                                                        <label class="semi-label" for="<%= txtConsultaBusca.ClientID %>">Busca</label>
                                                        <asp:TextBox ID="txtConsultaBusca" runat="server" CssClass="semi-input" MaxLength="40" autocomplete="off" placeholder="Modelo, c&oacute;digo, chassi, placa ou Renavam"></asp:TextBox>
                                                    </div>
                                                    <div class="semi-field">
                                                        <label class="semi-label" for="<%= ddlConsultaTamanho.ClientID %>">Linhas</label>
                                                        <asp:DropDownList ID="ddlConsultaTamanho" runat="server" CssClass="semi-select">
                                                            <asp:ListItem Value="25">25</asp:ListItem>
                                                            <asp:ListItem Value="50" Selected="True">50</asp:ListItem>
                                                            <asp:ListItem Value="100">100</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="semi-actions">
                                                    <asp:LinkButton ID="btnConsultar" runat="server" CssClass="semi-btn semi-btn-primary js-safe-submit" OnClick="btnConsultar_Click"><i class="fa fa-filter"></i>Consultar</asp:LinkButton>
                                                    <asp:LinkButton ID="btnLimparConsulta" runat="server" CssClass="semi-btn semi-btn-light" OnClick="btnLimparConsulta_Click"><i class="fa fa-eraser"></i>Limpar</asp:LinkButton>
                                                    <asp:LinkButton ID="btnExportarConsulta" runat="server" CssClass="semi-btn semi-btn-light" OnClick="btnExportarConsulta_Click"><i class="fa fa-file-export"></i>Exportar CSV</asp:LinkButton>
                                                </div>
                                                <asp:Literal ID="litConsultaDetalhe" runat="server"></asp:Literal>
                                                <div class="mt-3 semi-table-wrap">
                                                    <asp:Literal ID="litConsultaTabela" runat="server"></asp:Literal>
                                                </div>
                                                <div class="semi-pager">
                                                    <asp:LinkButton ID="btnConsultaAnterior" runat="server" CssClass="semi-btn semi-btn-light" OnClick="btnConsultaAnterior_Click"><i class="fa fa-chevron-left"></i>Anterior</asp:LinkButton>
                                                    <asp:Literal ID="litConsultaPaginacao" runat="server"></asp:Literal>
                                                    <asp:LinkButton ID="btnConsultaProxima" runat="server" CssClass="semi-btn semi-btn-light" OnClick="btnConsultaProxima_Click">Pr&oacute;xima<i class="fa fa-chevron-right"></i></asp:LinkButton>
                                                </div>
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <asp:Panel ID="pnlTransferir" runat="server">
                                        <div class="semi-card">
                                            <div class="semi-card-header">
                                                <div>
                                                    <small>Movimenta&ccedil;&atilde;o</small>
                                                    <h2 class="semi-card-title">Transferir seminovo</h2>
                                                </div>
                                            </div>
                                            <div class="semi-card-body">
                                                <div class="semi-form-grid">
                                                    <div class="semi-field is-wide">
                                                        <label class="semi-label" for="<%= txtTransferenciaBusca.ClientID %>">Localizar ve&iacute;culo</label>
                                                        <asp:TextBox ID="txtTransferenciaBusca" runat="server" CssClass="semi-input" MaxLength="40" autocomplete="off" placeholder="C&oacute;digo, chassi, placa ou Renavam"></asp:TextBox>
                                                    </div>
                                                    <div class="semi-field">
                                                        <label class="semi-label" for="<%= ddlTransferenciaDestino.ClientID %>">Loja destino</label>
                                                        <asp:DropDownList ID="ddlTransferenciaDestino" runat="server" CssClass="semi-select"></asp:DropDownList>
                                                    </div>
                                                    <div class="semi-field is-full">
                                                        <label class="semi-pill" style="justify-content:flex-start;">
                                                            <asp:CheckBox ID="chkConfirmarTransferencia" runat="server" />
                                                            <span><asp:Literal ID="litConfirmacaoTransferencia" runat="server" Text="Pesquise um seminovo para gerar a confirma&ccedil;&atilde;o."></asp:Literal></span>
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="semi-actions">
                                                    <asp:LinkButton ID="btnBuscarTransferencia" runat="server" CssClass="semi-btn semi-btn-light js-safe-submit" OnClick="btnBuscarTransferencia_Click"><i class="fa fa-search-location"></i>Pesquisar</asp:LinkButton>
                                                    <asp:LinkButton ID="btnTransferir" runat="server" CssClass="semi-btn semi-btn-primary js-safe-submit" OnClick="btnTransferir_Click"><i class="fa fa-exchange-alt"></i>Transferir</asp:LinkButton>
                                                </div>
                                                <asp:Literal ID="litTransferenciaVeiculo" runat="server"></asp:Literal>
                                                <div class="mt-3 semi-table-wrap">
                                                    <asp:Literal ID="litTransferenciaHistorico" runat="server"></asp:Literal>
                                                </div>
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <asp:Panel ID="pnlRelatorios" runat="server">
                                        <div class="semi-card">
                                            <div class="semi-card-header">
                                                <div>
                                                    <small>BI de seminovos</small>
                                                    <h2 class="semi-card-title">Relat&oacute;rios</h2>
                                                </div>
                                                <asp:LinkButton ID="btnAtualizarRelatorio" runat="server" CssClass="semi-btn semi-btn-light js-safe-submit" OnClick="btnAtualizarRelatorio_Click"><i class="fa fa-sync-alt"></i>Atualizar</asp:LinkButton>
                                            </div>
                                            <div class="semi-card-body">
                                                <div class="semi-quick-filters">
                                                    <asp:DropDownList ID="ddlRelatorioLoja" runat="server" CssClass="semi-select semi-filter-select"></asp:DropDownList>
                                                    <span class="semi-period-pill"><i class="fa fa-calendar-alt"></i><asp:Literal ID="litRelatorioPeriodo" runat="server"></asp:Literal></span>
                                                    <asp:LinkButton ID="btnFiltroHoje" runat="server" CssClass="semi-mini-action" CommandArgument="hoje" OnClick="FiltroRelatorio_Click"><i class="fa fa-calendar-day"></i>Hoje</asp:LinkButton>
                                                    <asp:LinkButton ID="btnFiltro7Dias" runat="server" CssClass="semi-mini-action" CommandArgument="7dias" OnClick="FiltroRelatorio_Click"><i class="fa fa-calendar-week"></i>&Uacute;ltimos 7 dias</asp:LinkButton>
                                                    <asp:LinkButton ID="btnFiltroMes" runat="server" CssClass="semi-mini-action" CommandArgument="mes" OnClick="FiltroRelatorio_Click"><i class="fa fa-calendar-alt"></i>Este m&ecirc;s</asp:LinkButton>
                                                </div>
                                                <asp:Literal ID="litResumo" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                        <div class="semi-bi-grid">
                                            <div class="semi-card">
                                                <div class="semi-card-header">
                                                    <div>
                                                        <small>Posi&ccedil;&atilde;o atual</small>
                                                        <h2 class="semi-card-title">Seminovos por loja</h2>
                                                    </div>
                                                </div>
                                                <div class="semi-card-body">
                                                    <asp:Literal ID="litEstoquePorLoja" runat="server"></asp:Literal>
                                                </div>
                                            </div>
                                            <div class="semi-card">
                                                <div class="semi-card-header">
                                                    <div>
                                                        <small>Per&iacute;odo selecionado</small>
                                                        <h2 class="semi-card-title">Entradas por dia</h2>
                                                    </div>
                                                </div>
                                                <div class="semi-card-body">
                                                    <asp:Literal ID="litEntradasDia" runat="server"></asp:Literal>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="semi-bi-grid">
                                            <div class="semi-card">
                                                <div class="semi-card-header">
                                                    <div>
                                                        <small>Per&iacute;odo selecionado</small>
                                                        <h2 class="semi-card-title">Transfer&ecirc;ncias por dia</h2>
                                                    </div>
                                                </div>
                                                <div class="semi-card-body">
                                                    <asp:Literal ID="litMovimentacoesDia" runat="server"></asp:Literal>
                                                </div>
                                            </div>
                                            <div class="semi-card">
                                                <div class="semi-card-header">
                                                    <div>
                                                        <small>Auditoria</small>
                                                        <h2 class="semi-card-title">&Uacute;ltimas a&ccedil;&otilde;es</h2>
                                                    </div>
                                                </div>
                                                <div class="semi-card-body semi-table-wrap">
                                                    <asp:Literal ID="litAuditoria" runat="server"></asp:Literal>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="semi-card">
                                            <div class="semi-card-header">
                                                <div>
                                                    <small>Entradas recentes</small>
                                                    <h2 class="semi-card-title">&Uacute;ltimos seminovos cadastrados</h2>
                                                </div>
                                            </div>
                                            <div class="semi-card-body semi-table-wrap">
                                                <asp:Literal ID="litUltimosCadastros" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                    </asp:Panel>
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <asp:UpdateProgress ID="UpdateProgress1" DisplayAfter="120" DynamicLayout="true" runat="server" AssociatedUpdatePanelID="updatePanel">
                        <ProgressTemplate>
                            <div class="semi-progress" role="status" aria-live="polite">
                                <span class="semi-progress-spinner" aria-hidden="true"></span>
                                <div>
                                    <strong>Processando</strong>
                                    <small>Atualizando dados de seminovos.</small>
                                </div>
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
    <script src="../assets/popper.min.js"></script>
    <script src="../assets/bootstrap.min.js"></script>
    <script src="../assets/scripts/main.js"></script>
    <script src="./assets/js/patio-jeep-ux.js?v=20260706-5"></script>
    <script>
        (function () {
            function textOf(el) { return el ? (el.textContent || '').trim() : ''; }
            function normalize(value) {
                return String(value || '').toUpperCase().replace(/[^A-Z0-9]/g, '');
            }

            var lastAutoSearch = '';

            function bindRegistroAutoSearch() {
                var registroInput = document.getElementById('<%= txtRegistroBusca.ClientID %>');
                var registroHidden = document.getElementById('<%= hfRegistroVeNr.ClientID %>');
                var registroReferencia = document.getElementById('<%= hfRegistroReferencia.ClientID %>');
                var registroSearch = document.getElementById('<%= btnPesquisarRegistro.ClientID %>');
                if (!registroInput || !registroSearch || registroInput.getAttribute('data-auto-search-bound') === '1') return;
                lastAutoSearch = registroReferencia ? normalize(registroReferencia.value) : lastAutoSearch;
                registroInput.setAttribute('data-auto-search-bound', '1');

                function autoSearchRegistro() {
                    var value = normalize(registroInput.value);
                    var loadedReference = registroReferencia ? normalize(registroReferencia.value) : '';
                    var hasLoadedVehicle = registroHidden && registroHidden.value;
                    if (value.length < 4) return;
                    if (hasLoadedVehicle && loadedReference === value) return;
                    if (lastAutoSearch === value) return;
                    lastAutoSearch = value;
                    registroSearch.click();
                }

                registroInput.addEventListener('blur', function () {
                    window.setTimeout(autoSearchRegistro, 120);
                });
                registroInput.addEventListener('keydown', function (event) {
                    if (event.key === 'Enter') {
                        event.preventDefault();
                        autoSearchRegistro();
                    }
                });
                registroInput.addEventListener('input', function () {
                    if (registroHidden) registroHidden.value = '';
                });
            }

            function bindCopyButtons() {
                if (document.documentElement.getAttribute('data-semi-copy-bound') === '1') return;
                document.documentElement.setAttribute('data-semi-copy-bound', '1');
                document.addEventListener('click', function (event) {
                    var button = event.target.closest ? event.target.closest('[data-copy]') : null;
                    if (!button) return;
                    event.preventDefault();

                    var value = button.getAttribute('data-copy') || '';
                    var label = button.getAttribute('data-copy-label') || 'Informa\u00e7\u00e3o';
                    if (!value) return;

                    function notify() {
                        if (window.patioToast) {
                            window.patioToast(label + ' copiado.', 'info');
                        } else {
                            button.setAttribute('title', label + ' copiado');
                        }
                    }

                    if (navigator.clipboard && navigator.clipboard.writeText) {
                        navigator.clipboard.writeText(value).then(notify, notify);
                    } else {
                        var temp = document.createElement('textarea');
                        temp.value = value;
                        temp.setAttribute('readonly', 'readonly');
                        temp.style.position = 'fixed';
                        temp.style.left = '-9999px';
                        document.body.appendChild(temp);
                        temp.select();
                        try { document.execCommand('copy'); } catch (ignore) { }
                        document.body.removeChild(temp);
                        notify();
                    }
                });
            }

            bindRegistroAutoSearch();
            bindCopyButtons();

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
                    bindRegistroAutoSearch();
                    bindCopyButtons();
                });
            }
        })();
    </script>
</body>
</html>
