<%@ Page Language="C#" AutoEventWireup="true" CodeFile="registrar.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <title>REGISTRAR | P&aacute;tio</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <!-- STYLE MARCIO       ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
    <script src="../assets/jquery-1.9.1.min.js"></script>
    <script src="../assets/jquery.dataTables.min.js"></script>
    <link href="../assets/dataTables.bootstrap4.min.css" rel="stylesheet" />
    <script src="../assets/dataTables.bootstrap4.min.js"></script>
    <script src="../assets/dataTables.responsive.min.js"></script>
    <link href="./main.css" rel="stylesheet" />
    <link href="../../css/bali-patio.css?v=20260704-1" rel="stylesheet" />
    <script src="../ChartJS.js"></script>
    <link href="../assets/all.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../assets/toastr.min.js"></script>
    <script type="text/javascript" src="./assets/js/quagga.min.js"></script>

    <style>
        .barcode-modal .modal-dialog {
            max-width: 720px;
        }

        .barcode-modal .modal-content {
            border: 0;
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 24px 70px rgba(0, 0, 0, .32);
        }

        .barcode-modal .modal-header {
            align-items: center;
            background: linear-gradient(135deg, #10271b, #215c3d);
            color: #fff;
            border: 0;
        }

        .barcode-modal .modal-title {
            display: flex;
            align-items: center;
            gap: .55rem;
            font-weight: 800;
        }

        .scanner-stage {
            position: relative;
            width: 100%;
            min-height: 420px;
            overflow: hidden;
            border-radius: 18px;
            background: #0f172a;
        }

        #scanner-video,
        #scanner-container,
        #scanner-container video,
        #scanner-container canvas {
            position: absolute;
            inset: 0;
            width: 100% !important;
            height: 100% !important;
            object-fit: cover;
        }

        #scanner-video,
        #scanner-container {
            display: block;
        }

        #scanner-video.is-hidden,
        #scanner-container.is-hidden {
            display: none;
        }

        .scanner-reticle {
            position: absolute;
            left: 50%;
            top: 50%;
            width: min(88%, 560px);
            height: 132px;
            transform: translate(-50%, -50%);
            border: 2px solid rgba(255, 255, 255, .84);
            border-radius: 20px;
            box-shadow: 0 0 0 999px rgba(2, 6, 23, .42);
            pointer-events: none;
        }

        .scanner-reticle::before {
            content: "";
            position: absolute;
            left: 18px;
            right: 18px;
            top: 50%;
            height: 2px;
            transform: translateY(-50%);
            background: linear-gradient(90deg, transparent, #22c55e, transparent);
            box-shadow: 0 0 18px rgba(34, 197, 94, .85);
        }

        .scanner-hint {
            position: absolute;
            left: 1rem;
            right: 1rem;
            bottom: 1rem;
            display: flex;
            justify-content: space-between;
            gap: .75rem;
            flex-wrap: wrap;
            color: #fff;
            font-weight: 700;
            text-shadow: 0 2px 12px rgba(0, 0, 0, .6);
            pointer-events: none;
        }

        .scanner-pill {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            padding: .38rem .65rem;
            border-radius: 999px;
            background: rgba(15, 23, 42, .74);
            backdrop-filter: blur(7px);
        }

        .scanner-status {
            min-height: 42px;
            margin: .85rem 0 0;
            padding: .75rem .9rem;
            border-radius: 14px;
            background: #f8fafc;
            color: #334155;
            font-weight: 700;
        }

        .scanner-status--success {
            color: #14532d;
            background: #dcfce7;
        }

        .scanner-status--error {
            color: #7f1d1d;
            background: #fee2e2;
        }

        .scanner-status--warning {
            color: #713f12;
            background: #fef3c7;
        }

        .scanner-status--info {
            color: #1e3a8a;
            background: #dbeafe;
        }

        .barcode-modal .is-hidden {
            display: none !important;
        }

        .scanner-tools {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: .65rem;
            margin-top: .85rem;
        }

        .scanner-tools select,
        .scanner-tools button {
            min-height: 42px;
            border-radius: 12px;
            font-weight: 800;
        }

        .scanner-zoom {
            display: grid;
            grid-template-columns: auto minmax(150px, 1fr);
            align-items: center;
            gap: .75rem;
            margin-top: .75rem;
            padding: .75rem .9rem;
            border: 1px solid #dbe4ef;
            border-radius: 14px;
            background: #f8fafc;
            color: #334155;
            font-weight: 800;
        }

        .scanner-zoom input {
            width: 100%;
        }

        .scanner-help {
            margin-top: .75rem;
            padding: .75rem .9rem;
            border: 1px solid #dbe4ef;
            border-radius: 14px;
            background: #fff;
            color: #334155;
        }

        .scanner-help summary {
            cursor: pointer;
            font-weight: 900;
        }

        .scanner-help ul {
            margin: .65rem 0 0;
            padding-left: 1.1rem;
        }

        .scanner-manual {
            display: grid;
            grid-template-columns: 1fr auto;
            gap: .6rem;
            margin-top: .85rem;
        }

        .scanner-manual input {
            min-height: 46px;
            border-radius: 14px;
            font-size: 1.12rem;
            font-weight: 800;
            letter-spacing: .08em;
            text-align: center;
        }

        .scanner-actions {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .6rem;
            flex-wrap: wrap;
            margin-top: .85rem;
        }

        .patio-operation-alert {
            display: grid;
            grid-template-columns: auto minmax(0, 1fr);
            gap: .85rem;
            align-items: center;
            margin-bottom: 1rem;
            padding: .9rem 1rem;
            border-radius: 16px;
            border: 1px solid #dbe4ef;
            background: #fff;
            box-shadow: 0 12px 28px rgba(15, 23, 42, .08);
        }

        .patio-operation-alert i {
            width: 42px;
            height: 42px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 14px;
            background: #eef2ff;
            color: #1e3a8a;
            font-size: 1.2rem;
        }

        .patio-operation-alert strong {
            display: block;
            color: #0f172a;
            font-size: 1rem;
        }

        .patio-operation-alert span {
            display: block;
            color: #475569;
            font-weight: 700;
        }

        .patio-operation-alert-success {
            border-color: #bbf7d0;
            background: #f0fdf4;
        }

        .patio-operation-alert-success i {
            background: #dcfce7;
            color: #15803d;
        }

        .patio-operation-alert-warning {
            border-color: #fde68a;
            background: #fffbeb;
        }

        .patio-operation-alert-warning i {
            background: #fef3c7;
            color: #92400e;
        }

        .patio-operation-alert-error {
            border-color: #fecaca;
            background: #fef2f2;
        }

        .patio-operation-alert-error i {
            background: #fee2e2;
            color: #991b1b;
        }

        .patio-found-card {
            position: relative;
            margin: .25rem 0 1.1rem;
            padding: 1rem;
            border: 1px solid #bbf7d0;
            border-radius: 18px;
            background: linear-gradient(135deg, #f0fdf4, #ffffff);
            box-shadow: 0 16px 36px rgba(22, 101, 52, .10);
        }

        .patio-found-card.is-warning {
            border-color: #fde68a;
            background: linear-gradient(135deg, #fffbeb, #ffffff);
        }

        .patio-found-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            flex-wrap: wrap;
            margin-bottom: .9rem;
        }

        .patio-found-title {
            display: flex;
            align-items: center;
            gap: .7rem;
            color: #0f172a;
        }

        .patio-found-title i {
            width: 44px;
            height: 44px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 14px;
            background: #dcfce7;
            color: #15803d;
        }

        .patio-found-badge {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            padding: .45rem .7rem;
            border-radius: 999px;
            background: #dcfce7;
            color: #14532d;
            font-weight: 900;
            font-size: .82rem;
            text-transform: uppercase;
            letter-spacing: .04em;
        }

        .patio-found-grid {
            display: grid;
            grid-template-columns: repeat(5, minmax(120px, 1fr));
            gap: .7rem;
        }

        .patio-found-item {
            padding: .72rem .8rem;
            border-radius: 14px;
            background: #fff;
            border: 1px solid #e2e8f0;
        }

        .patio-found-item small {
            display: block;
            color: #64748b;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: .04em;
            font-size: .72rem;
        }

        .patio-found-item span {
            display: block;
            margin-top: .2rem;
            color: #0f172a;
            font-weight: 900;
            overflow-wrap: anywhere;
        }

        .patio-field-error {
            border-color: #ef4444 !important;
            box-shadow: 0 0 0 .2rem rgba(239, 68, 68, .16) !important;
        }

        .patio-recent-card {
            margin-top: 1rem;
            border: 1px solid #dbe4ef;
            border-radius: 18px;
            background: #fff;
            overflow: hidden;
            box-shadow: 0 14px 34px rgba(15, 23, 42, .08);
        }

        .patio-recent-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            padding: .85rem 1rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .patio-recent-header strong {
            color: #0f172a;
        }

        .patio-recent-list {
            list-style: none;
            margin: 0;
            padding: 0;
        }

        .patio-recent-list li {
            display: grid;
            grid-template-columns: minmax(110px, .8fr) minmax(0, 1.4fr) minmax(90px, .6fr) auto;
            gap: .75rem;
            align-items: center;
            padding: .75rem 1rem;
            border-bottom: 1px solid #f1f5f9;
            color: #334155;
            font-weight: 800;
        }

        .patio-recent-list li:last-child {
            border-bottom: 0;
        }

        .patio-recent-list small {
            color: #64748b;
            font-weight: 800;
        }

        .patio-mobile-action {
            display: none;
        }

        @media (max-width: 767.98px) {
            .barcode-modal .modal-dialog {
                width: 100%;
                max-width: none;
                height: 100%;
                margin: 0;
            }

            .barcode-modal .modal-content {
                min-height: 100%;
                border-radius: 0;
            }

            .scanner-stage {
                min-height: min(64vh, 560px);
                border-radius: 16px;
            }

            .scanner-reticle {
                height: 112px;
            }

            .scanner-manual {
                grid-template-columns: 1fr;
            }

            .scanner-tools {
                grid-template-columns: 1fr;
            }

            .scanner-zoom {
                grid-template-columns: 1fr;
            }

            .patio-found-grid {
                grid-template-columns: 1fr;
            }

            .patio-recent-list li {
                grid-template-columns: 1fr;
                gap: .25rem;
            }

            .patio-mobile-action {
                position: fixed;
                left: 0;
                right: 0;
                bottom: 0;
                z-index: 1030;
                display: block;
                padding: .75rem;
                background: rgba(255, 255, 255, .94);
                border-top: 1px solid #dbe4ef;
                box-shadow: 0 -16px 40px rgba(15, 23, 42, .18);
                backdrop-filter: blur(12px);
            }

            .patio-mobile-action .btn {
                width: 100%;
                min-height: 50px;
                border-radius: 14px;
                font-weight: 900;
            }

            body[data-patio-page="registrar.aspx"] {
                padding-bottom: 86px;
            }
        }
    </style>
</head>

<body class="patio-modern-page patio-brand-jeep">
    <form id="form1" runat="server">
        <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString2 %>" SelectCommand="veiculos_patio_lojas_ativas" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <div class="app-container app-theme-white body-tabs-shadow fixed-sidebar fixed-header">
            <div class="app-header header-shadow bg-dark">
                <div class="app-header__logo">
                    <div class="logo-src"></div>
                    <div class="header__pane ml-auto">
                        <div>
                            <button type="button" class="hamburger close-sidebar-btn hamburger--elastic" data-class="closed-sidebar">
                                <span class="hamburger-box">
                                    <span class="hamburger-inner"></span>
                                </span>
                            </button>
                        </div>
                    </div>
                </div>
                <div class="app-header__mobile-menu">

                    <div>
                        <button type="button" class="hamburger hamburger--elastic mobile-toggle-nav">
                            <span class="hamburger-box">
                                <span class="hamburger-inner"></span>
                            </span>
                        </button>
                    </div>
                </div>
                <div class="app-header__menu">
                    <span>
                        <button type="button" class="btn-icon btn-icon-only  btn btn-primary btn-sm mobile-toggle-header-nav">
                            <span class="btn-icon-wrapper">
                                <i class="fa fa-ellipsis-v fa-w-6"></i>
                            </span>
                        </button>
                    </span>
                </div>
                <div class="app-header__content bg-dark">
                    <div class="app-header-left">
                    </div>
                    <div class="app-header-right">
                        <div class="header-btn-lg pr-0">
                            <div class="widget-content p-0">
                                <div class="widget-content-wrapper">
                                    <div class="widget-content-left">
                                        <div class="btn-group">
                                            <a data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" class="p-0 btn">
                                                <i class="text-white mr-1">
                                                    <b><i class="fa fa-user mr-1"></i><asp:Literal ID="usuarioLogado" runat="server"></asp:Literal></b>
                                                    <asp:LinkButton runat="server" ID="sair" CssClass="fa fa-arrow-alt-circle-right text-danger" OnClick="btnSair_Click"></asp:LinkButton>
                                                </i>

                                            </a>

                                        </div>
                                    </div>
                                    <div class="widget-content-left  ml-3 header-user-info">
                                    </div>
                                    <div class="widget-content-right header-user-info ml-3">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="app-main" style="background-color: #495057;">
                <div class="app-sidebar sidebar-shadow">
                    <div class="app-header__logo">
                        <div class="logo-src"></div>
                        <div class="header__pane ml-auto">
                            <div>
                                <button type="button" class="hamburger close-sidebar-btn hamburger--elastic" data-class="closed-sidebar">
                                    <span class="hamburger-box">
                                        <span class="hamburger-inner"></span>
                                    </span>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="app-header__mobile-menu">
                        <div>
                            <button type="button" class="hamburger hamburger--elastic mobile-toggle-nav">
                                <span class="hamburger-box">
                                    <span class="hamburger-inner"></span>
                                </span>
                            </button>
                        </div>
                    </div>
                    <div class="app-header__menu">
                        <span>
                            <button type="button" class="btn-icon btn-icon-only btn btn-primary btn-sm mobile-toggle-header-nav">
                                <span class="btn-icon-wrapper">
                                    <i class="fa fa-ellipsis-v fa-w-6"></i>
                                </span>
                            </button>
                        </span>
                    </div>
                    <div class="scrollbar-sidebar bg-dark">
                        <div class="app-sidebar__inner">
                            <ul class="vertical-nav-menu">
                                <li>
                                    <a href="./">
                                        <i class="metismenu-icon fas fa-home"></i>
                                        In&iacute;cio
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">Fun&ccedil;&otilde;es</li>
                                <li>
                                    <a href="./registrar.aspx" class="mm-active">
                                        <i class="metismenu-icon fa fa-folder-plus"></i>
                                        Registrar
                                    </a>
                                </li>
                                <li>

                                    <a href="./transferir.aspx">
                                        <i class="metismenu-icon fas fa-exchange-alt"></i>
                                        Transferir
                                    </a>
                                </li>
                                <li>

                                    <a href="./historico.aspx">
                                        <i class="metismenu-icon fas fa-history"></i>
                                        Consultar
                                    </a>
                                </li>
                                <li>
                                    <a href="./relatorios.aspx">
                                        <i class="metismenu-icon fas fa-chart-line"></i>
                                        Relat&oacute;rios
                                    </a>
                                </li>
                                <li>
                                    <a href="./lojas.aspx">
                                        <i class="metismenu-icon fas fa-store"></i>
                                        Lojas
                                    </a>
                                </li>
                                <li>
                                    <a href="./permissoes.aspx">
                                        <i class="metismenu-icon fas fa-user-shield"></i>
                                        Permiss&otilde;es
                                    </a>
                                </li>
                                <li>
                                    <a href="./barcode-logs.aspx">
                                        <i class="metismenu-icon fas fa-clipboard-list"></i>
                                        Logs do leitor
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="app-main__outer" >
                    <asp:UpdatePanel ID="updatePanel" runat="server">
                        <ContentTemplate>
                            <div class="app-main__inner mb-3">
                                <div class="app-page-title text-white" style="background-color:#495057;">
                                    <div class="page-title-wrapper">
                                        <div class="page-title-heading">
                                            <div class="page-title-icon" style="background-color:#495057;">
                                                <i class="fas fa-folder-plus text-white"></i>
                                            </div>
                                            <div>
                                                <b>Registrar</b>

                                                <div class="page-title-subheading">
                                                    Digite a s&eacute;rie, confira os dados retornados e selecione a loja.
                                                </div>
                                            </div>
                                        </div>
                                        <div class="page-title-actions">
                                        </div>
                                    </div>
                                </div>
                                <asp:Panel ID="pnlFeedback" runat="server" CssClass="patio-operation-alert patio-operation-alert-info" Visible="false">
                                    <i id="feedbackIcon" runat="server" class="fa fa-info-circle"></i>
                                    <div>
                                        <strong><asp:Literal ID="litFeedbackTitulo" runat="server"></asp:Literal></strong>
                                        <span><asp:Literal ID="litFeedbackMensagem" runat="server"></asp:Literal></span>
                                    </div>
                                </asp:Panel>
                                <asp:Panel ID="pnlNovaLeitura" runat="server" CssClass="patio-operation-alert patio-operation-alert-success" Visible="false">
                                    <i class="fa fa-check-circle"></i>
                                    <div>
                                        <strong>Registro conclu&iacute;do</strong>
                                        <span><asp:Literal ID="litNovaLeitura" runat="server"></asp:Literal></span>
                                        <button type="button" class="btn btn-success mt-2" data-toggle="modal" data-target="#myModal"><i class="fa fa-barcode mr-1"></i> Nova leitura</button>
                                    </div>
                                </asp:Panel>
                                <div class="row">
                                    <div class="col-12 mb-2">
                                        <div class="mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header">
                                                <div class="card-header-title">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    DADOS                                       
                                                </div>
                                            </div>
                                            <div class="card-body">
                                                <div class="form-row">

                                                    <div class="input-group col-sm-12 col-md-5 col-lg-3 mb-3">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text" id="basic-addon1"><b>S&eacute;rie</b></span>
                                                        </div>
                                                        <asp:TextBox ID="txtSerie" CssClass="form-control" runat="server" required="true" MaxLength="7" inputmode="text" pattern="[A-Za-z0-9]*" placeholder="Digite ou leia a s&eacute;rie" OnTextChanged="serieOnTextChanged" AutoPostBack="true"></asp:TextBox>
                                                        <div class="input-group-append">
                                                            <asp:LinkButton runat="server" ID="btnSearch" OnClick="serieOnTextChanged" CssClass="btn btn-primary"><i class="fa fa-search-location"></i></asp:LinkButton>
                                                        </div>
                                                        <div class="input-group-append">
                                                            <a href="#" id="openBarcodeScanner" data-toggle="modal" data-target="#myModal" class="text-decoration-none btn btn-dark" aria-label="Ler c&oacute;digo de barras pela c&acirc;mera"><i class="fa fa-barcode fa-2x"></i></a>
                                                            
                                                        </div>
                                                    </div>
                                                    <div class="input-group col-sm-12 col-md-5 col-lg-3 mb-3">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text" id="Span5"><b>Loja</b></span>
                                                        </div>
                                                        <select id="ddlLoja" runat="server" class="form-control" required="required" datasourceid="SqlDataSource2" datatextfield="ds" datavaluefield="id">
                                                        </select>
                                                    </div>
                                                </div>
                                            <asp:Panel ID="pnlVeiculoEncontrado" runat="server" CssClass="patio-found-card" Visible="false">
                                                <div class="patio-found-header">
                                                    <div class="patio-found-title">
                                                        <i class="fa fa-car"></i>
                                                        <div>
                                                            <strong><asp:Literal ID="litVeiculoTitulo" runat="server"></asp:Literal></strong>
                                                            <div class="text-muted"><asp:Literal ID="litVeiculoSubtitulo" runat="server"></asp:Literal></div>
                                                        </div>
                                                    </div>
                                                    <span class="patio-found-badge"><i class="fa fa-check-circle"></i><asp:Literal ID="litVeiculoStatus" runat="server"></asp:Literal></span>
                                                </div>
                                                <div class="patio-found-grid">
                                                    <div class="patio-found-item">
                                                        <small>S&eacute;rie</small>
                                                        <span><asp:Literal ID="litResumoSerie" runat="server"></asp:Literal></span>
                                                    </div>
                                                    <div class="patio-found-item">
                                                        <small>Chassi</small>
                                                        <span><asp:Literal ID="litResumoChassi" runat="server"></asp:Literal></span>
                                                    </div>
                                                    <div class="patio-found-item">
                                                        <small>Modelo</small>
                                                        <span><asp:Literal ID="litResumoModelo" runat="server"></asp:Literal></span>
                                                    </div>
                                                    <div class="patio-found-item">
                                                        <small>Cor</small>
                                                        <span><asp:Literal ID="litResumoCor" runat="server"></asp:Literal></span>
                                                    </div>
                                                    <div class="patio-found-item">
                                                        <small>N&uacute;mero NF</small>
                                                        <span><asp:Literal ID="litResumoNf" runat="server"></asp:Literal></span>
                                                    </div>
                                                </div>
                                            </asp:Panel>
                                            <div class="form-row">
                                                <div class="input-group col-sm-12 col-md-6 col-lg-6 col-xl-3 mb-3">
                                                    <div class="input-group-prepend">
                                                        <span class="input-group-text" id="Span4"><b>C&oacute;d. Ve&iacute;c.</b></span>
                                                    </div>
                                                    <asp:TextBox type="text" ID="txtCodVec" CssClass="form-control bg-white  " runat="server" OnTextChanged="serieOnTextChanged"></asp:TextBox>

                                                </div>
                                                <div class="input-group col-sm-12 col-md-6 col-lg-6 col-xl-3 mb-3">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text" id="Span1"><b>Chassi</b></span>
                                                        </div>
                                                        <asp:TextBox type="text" ID="txtChassi" CssClass="form-control bg-white  " runat="server" OnTextChanged="serieOnTextChanged"></asp:TextBox>

                                                    </div>
                                                    <div class="input-group col-sm-12 col-md-6 col-lg-6 col-xl-3 mb-3">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text" id="Span2"><b>Modelo</b></span>
                                                        </div>
                                                        <asp:TextBox type="text" ID="txtModelo" CssClass="form-control bg-white  " runat="server" OnTextChanged="serieOnTextChanged"></asp:TextBox>

                                                    </div>
                                                    <div class="input-group col-sm-12 col-md-6 col-lg-6 col-xl-3 mb-3">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text" id="Span3"><b>Cor</b></span>
                                                        </div>
                                                        <asp:TextBox type="text" ID="txtCor" CssClass="form-control bg-white  " runat="server" OnTextChanged="serieOnTextChanged"></asp:TextBox>

                                                    </div>
                                                <div class="input-group col-sm-12 col-md-6 col-lg-6 col-xl-3 mb-3">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text" id="Span3"><b>N&uacute;mero NF</b></span>
                                                        </div>
                                                        <asp:TextBox type="text" ID="txtNUMERONF" CssClass="form-control bg-white  " runat="server" OnTextChanged="serieOnTextChanged"></asp:TextBox>

                                                    </div>
                                                </div>
                                            </div>
                                            <div class="card-footer">
                                                <div class="col-12">
                                                    <asp:LinkButton ID="btnRegistrar" runat="server" CssClass="btn btn-lg btn-success col-6 offset-3 fa-1x" OnClick="btnRegistrar_Click" Text="SALVAR">SALVAR<i class="far fa-save ml-1"></i></asp:LinkButton>
                                                </div>
                                            </div>
                                        </div>
                                        <asp:Panel ID="pnlHistoricoRecente" runat="server" CssClass="patio-recent-card" Visible="false">
                                            <div class="patio-recent-header">
                                                <strong><i class="fa fa-clock mr-1"></i> &Uacute;ltimos registros desta sess&atilde;o</strong>
                                                <small>Confer&ecirc;ncia r&aacute;pida</small>
                                            </div>
                                            <asp:Literal ID="litHistoricoRecente" runat="server"></asp:Literal>
                                        </asp:Panel>
                                    </div>

                                </div>
                                <asp:Panel ID="pnlMobileAction" runat="server" CssClass="patio-mobile-action" Visible="false">
                                    <asp:LinkButton ID="btnRegistrarMobile" runat="server" CssClass="btn btn-success" OnClick="btnRegistrar_Click"><i class="far fa-save mr-1"></i> Salvar registro</asp:LinkButton>
                                </asp:Panel>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>

                    <asp:UpdateProgress ID="UpdateProgress1" DynamicLayout="true" runat="server" AssociatedUpdatePanelID="updatePanel">
                        <ProgressTemplate>
                            <div class="progress container text-center">
                                <div class="loader"></div>
                               
                            </div>
                        </ProgressTemplate>
                    </asp:UpdateProgress>
                    <footer class="fixed-bottom bg-dark">
                        
                        <div class="container text-center text-white mb-2 mt-2">
                            <b>TI - GRUPO BALI</b>
                        </div>
                        <div class="row no-gutters social-container">
                        </div>
                    </footer>
                </div>
            </div>
    </form>

    <!-- The Modal -->
<div class="modal barcode-modal" id="myModal" tabindex="-1" role="dialog" aria-labelledby="barcodeModalTitle" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
    <div class="modal-content">

      <!-- Modal Header -->
      <div class="modal-header">
        <h4 class="modal-title" id="barcodeModalTitle"><i class="fa fa-barcode"></i> Leitor de c&oacute;digo de barras</h4>
        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Fechar">&times;</button>
      </div>

      <!-- Modal body -->
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

      <!-- Modal footer -->
      <div class="modal-footer">
        <button type="button" class="btn btn-lg btn-danger" data-dismiss="modal">Cancelar leitura</button>
      </div>

    </div>
  </div>
</div>
    <script src="../assets/popper.min.js"></script>
    <script src="../assets/bootstrap.min.js"></script>
    <script src="../assets/jspdf.min.js"></script>
    <script src="../assets/scripts/main.js"></script>


    

    <script>
        window.PatioBarcodeScannerConfig = {
            serieInputId: '<%= txtSerie.ClientID %>',
            searchButtonId: '<%= btnSearch.ClientID %>',
            postBackTarget: '<%= btnSearch.UniqueID %>',
            logEndpoint: './barcode-log.ashx'
        };
    </script>
    <script src="./assets/js/patio-barcode-scanner.js?v=20260706-1" charset="utf-8"></script>
    <script src="./assets/js/patio-jeep-ux.js?v=20260706-4"></script>

</body>

</html>
