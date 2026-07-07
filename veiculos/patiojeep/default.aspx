<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <title>IN&Iacute;CIO | P&aacute;tio</title>
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


</head>

<body class="patio-modern-page patio-brand-jeep">
    <form id="form1" runat="server">
        <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="veiculos_patio_lojas_ativas" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
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
                                    <a href="./" class="mm-active">
                                        <i class="metismenu-icon fas fa-home"></i>
                                        In&iacute;cio
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">Fun&ccedil;&otilde;es</li>
                                <li>
                                    <a href="./novos.aspx">
                                        <i class="metismenu-icon fas fa-car"></i>
                                        Novos
                                    </a>
                                </li>
                                <li>
                                    <a href="./seminovos.aspx">
                                        <i class="metismenu-icon fas fa-car-side"></i>
                                        Seminovos
                                    </a>
                                </li>
                                <li>
                                    <a href="./lojas.aspx">
                                        <i class="metismenu-icon fas fa-store"></i>
                                        Lojas
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
                                                <i class="fas fa-home text-white"></i>
                                            </div>
                                            <div>
                                                <b>In&iacute;cio</b>

                                                <div class="page-title-subheading">
                                                    Opera&ccedil;&otilde;es de p&aacute;tio e consulta de ve&iacute;culos.
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
                                                    <i class="header-icon fa fa-search icon-gradient bg-love-kiss"></i>
                                                    Busca global do p&aacute;tio
                                                </div>
                                            </div>
                                            <div class="card-body">
                                                <asp:Literal ID="litBuscaMensagem" runat="server"></asp:Literal>
                                                <div class="row align-items-end">
                                                    <div class="col-md-8 col-12 mb-2">
                                                        <label class="font-weight-bold text-muted text-uppercase" style="font-size:.75rem;">S&eacute;rie, chassi, placa, Renavam ou c&oacute;digo</label>
                                                        <asp:TextBox ID="txtBuscaGlobal" runat="server" CssClass="form-control" MaxLength="40" autocomplete="off" placeholder="Digite para localizar em Novos ou Seminovos"></asp:TextBox>
                                                    </div>
                                                    <div class="col-md-4 col-12 mb-2">
                                                        <asp:LinkButton ID="btnBuscaGlobal" runat="server" CssClass="btn btn-success btn-block" OnClick="btnBuscaGlobal_Click"><i class="fa fa-search mr-1"></i>Buscar no p&aacute;tio</asp:LinkButton>
                                                    </div>
                                                </div>
                                                <asp:Literal ID="litHomeIndicadores" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                        <div class="mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header">
                                                <div class="card-header-title">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    Fun&ccedil;&otilde;es                                       
                                                </div>
                                            </div>
                                            <div class="card-body">
                                                <div class="patio-home-grid">
                                                    <a class="patio-home-card" href="./novos.aspx">
                                                        <span class="patio-home-icon"><i class="fa fa-car"></i></span>
                                                        <strong>Novos</strong>
                                                        <small>Registre, consulte, transfira e acompanhe o p&aacute;tio de ve&iacute;culos novos em abas.</small>
                                                    </a>
                                                    <a class="patio-home-card" href="./seminovos.aspx">
                                                        <span class="patio-home-icon"><i class="fa fa-car-side"></i></span>
                                                        <strong>Seminovos</strong>
                                                        <small>Registre, consulte, transfira e acompanhe o p&aacute;tio de seminovos.</small>
                                                    </a>
                                                    <a class="patio-home-card" href="./lojas.aspx">
                                                        <span class="patio-home-icon"><i class="fa fa-store"></i></span>
                                                        <strong>Lojas</strong>
                                                        <small>Cadastre, edite, ative e desative lojas do p&aacute;tio.</small>
                                                    </a>
                                                    <a class="patio-home-card" href="./barcode-logs.aspx">
                                                        <span class="patio-home-icon"><i class="fa fa-clipboard-list"></i></span>
                                                        <strong>Logs do leitor</strong>
                                                        <small>Audite leituras por c&acirc;mera, digita&ccedil;&atilde;o manual e diagn&oacute;sticos.</small>
                                                    </a>
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
                            <b>TI - GRUPO BALI</b>
                        </div>
                        <div class="row no-gutters social-container">
                        </div>
                    </footer>
                </div>
            </div>
    </form>

    <script src="../assets/popper.min.js"></script>
    <script src="../assets/bootstrap.min.js"></script>
    <script src="../assets/jspdf.min.js"></script>
    <script src="../assets/scripts/main.js"></script>
    <script src="./assets/js/patio-jeep-ux.js?v=20260706-5"></script>

</body>

</html>
