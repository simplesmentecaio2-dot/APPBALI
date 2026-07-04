<%@ Page Language="C#" AutoEventWireup="true" CodeFile="registrar.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <title>REGISTRAR | Pátio</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <!-- STYLE MARCIO       ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
    <script src="../assets/jquery-1.9.1.min.js"></script>
    <script src="../assets/jquery.dataTables.min.js"></script>
    <link href="../assets/dataTables.bootstrap4.min.css" rel="stylesheet" />
    <script src="../assets/dataTables.bootstrap4.min.js"></script>
    <script src="../assets/dataTables.responsive.min.js"></script>
    <link href="./main.css" rel="stylesheet" />
    <link href="../../css/bali-patio.css?v=20260624-1" rel="stylesheet" />
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

        .is-hidden {
            display: none !important;
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
                                        Início
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">Funções</li>
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
                                    <a href="./acompanhamento.aspx">
                                        <i class="metismenu-icon fas fa-tasks"></i>
                                        Acompanhamento
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
                                                    Digite a série, confira os dados retornados e selecione a loja.
                                                </div>
                                            </div>
                                        </div>
                                        <div class="page-title-actions">
                                        </div>
                                    </div>
                                </div>
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
                                                            <span class="input-group-text" id="basic-addon1"><b>Série</b></span>
                                                        </div>
                                                        <asp:TextBox ID="txtSerie" CssClass="form-control" runat="server" required="true" MaxLength="7" inputmode="numeric" pattern="[0-9]*" placeholder="Digite ou leia a série" OnTextChanged="serieOnTextChanged" AutoPostBack="true"></asp:TextBox>
                                                        <div class="input-group-append">
                                                            <asp:LinkButton runat="server" ID="btnSearch" OnClick="serieOnTextChanged" CssClass="btn btn-primary"><i class="fa fa-search-location"></i></asp:LinkButton>
                                                        </div>
                                                        <div class="input-group-append">
                                                            <a href="#" id="openBarcodeScanner" data-toggle="modal" data-target="#myModal" class="text-decoration-none btn btn-dark" aria-label="Ler código de barras pela câmera"><i class="fa fa-barcode fa-2x"></i></a>
                                                            
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
                                            <div class="form-row">
                                                <div class="input-group col-sm-12 col-md-6 col-lg-6 col-xl-3 mb-3">
                                                    <div class="input-group-prepend">
                                                        <span class="input-group-text" id="Span4"><b>Cód. Veíc.</b></span>
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
                                                            <span class="input-group-text" id="Span3"><b>Número NF</b></span>
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
                                    </div>

                                </div>
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
                            <b>&copy;Caio Augusto</b> | Bali Brasília Automóveis - LTDA
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
        <h4 class="modal-title" id="barcodeModalTitle"><i class="fa fa-barcode"></i> Leitor de código de barras</h4>
        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Fechar">&times;</button>
      </div>

      <!-- Modal body -->
      <div class="modal-body">
        <div class="scanner-stage">
            <video id="scanner-video" class="is-hidden" muted autoplay playsinline></video>
            <div id="scanner-container" class="is-hidden"></div>
            <div class="scanner-reticle"></div>
            <div class="scanner-hint">
                <span class="scanner-pill"><i class="fa fa-mobile-alt"></i> Aproxime o código da faixa central</span>
                <span class="scanner-pill" id="scannerEngine">Preparando câmera</span>
            </div>
        </div>
        <div id="scannerStatus" class="scanner-status" aria-live="polite">Ao permitir a câmera, a leitura começa automaticamente.</div>
        <div class="scanner-manual">
            <input type="text" id="scannerManualSerie" class="form-control" inputmode="numeric" pattern="[0-9]*" maxlength="7" placeholder="Digitar série manualmente" autocomplete="off" />
            <button type="button" id="scannerApplyManual" class="btn btn-success"><i class="fa fa-check mr-1"></i> Usar série</button>
        </div>
        <div class="scanner-actions">
            <div>
                <small class="text-muted">Resultado: <strong id="result">aguardando leitura</strong></small>
                <small class="text-muted d-block">Código lido: <span id="scannerLastRaw">-</span></small>
            </div>
            <div>
                <button type="button" id="scannerTorch" class="btn btn-outline-secondary is-hidden"><i class="fa fa-lightbulb mr-1"></i> Luz</button>
                <button type="button" id="scannerRetry" class="btn btn-outline-dark"><i class="fa fa-redo mr-1"></i> Reiniciar</button>
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
            postBackTarget: '<%= btnSearch.UniqueID %>'
        };
    </script>
    <script src="./assets/js/patio-barcode-scanner.js?v=20260704-1" charset="utf-8"></script>
    <script src="./assets/js/patio-jeep-ux.js?v=20260629-1"></script>

</body>

</html>
