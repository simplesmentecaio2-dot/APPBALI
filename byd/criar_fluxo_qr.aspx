<%@ Page Language="C#" AutoEventWireup="true" CodeFile="criar_fluxo_qr.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <title></title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <!-- STYLE MARCIO       ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
    <script src="./assets/jquery-1.9.1.min.js"></script>
    <script src="./assets/jquery.dataTables.min.js"></script>
    <link href="./assets/dataTables.bootstrap4.min.css" rel="stylesheet" />
    <script src="./assets/dataTables.bootstrap4.min.js"></script>
    <script src="./assets/dataTables.responsive.min.js"></script>
    <link href="./main.css" rel="stylesheet" />
    <script src="./ChartJS.js"></script>
    <link href="./assets/all.min.css" rel="stylesheet" />
    <script type="text/javascript" src="./assets/toastr.min.js"></script>

</head>

<body>
    <form id="form1" class="needs-validation" runat="server" novalidate="novalidate">
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="gerencia_vendedor2" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="prospeccao_evento" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource7" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="gerencia_vendedor2" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <div class="app-container app-theme-white body-tabs-shadow fixed-sidebar fixed-header">
            <div class="app-header header-shadow">
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
                <div class="app-header__content">
                    <div class="app-header-left">
                    </div>
                    <div class="app-header-right">
                        <div class="header-btn-lg pr-0">
                            <div class="widget-content p-0">
                                <div class="widget-content-wrapper">
                                    <div class="widget-content-left">
                                        <div class="btn-group">
                                            <a data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" class="p-0 btn">
                                                <img width="42" class="rounded-circle" src="assets/images/avatars/1.jpg" alt="">
                                                <i class="">
                                                    <asp:Literal ID="usuarioLogado" runat="server"></asp:Literal>
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
            <div class="app-main">
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
                    <div class="scrollbar-sidebar">
                        <div class="app-sidebar__inner">
                             <ul class="vertical-nav-menu">
                                <li class="app-sidebar__heading"></li>
                                <li>
                                    <a href="./prospeccao.aspx">
                                        <i class="metismenu-icon fas fa-home"></i>
                                        Prospecção
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">Dashboards</li>
                                <li>
                                    <a href="./dashboard_lojas.aspx">
                                        <i class="metismenu-icon pe-7s-bookmarks "></i>
                                        Dashboard Lojas
                                    </a>
                                </li>
                                <li>

                                    <a href="./dashboard_evento.aspx">
                                        <i class="metismenu-icon fas fa-chart-bar"></i>
                                        Dashboard Evento
                                    </a>
                                </li>
                                <li>

                                    <a href="./dashboard_resultado.aspx">
                                        <i class="metismenu-icon fas fa-chalkboard"></i>
                                        Dashboard Resultado
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">__________________________________</li>
                                <li>

                                    <a href="./criar_fluxo.aspx" >
                                        <i class="metismenu-icon fas fa-user-plus"></i>
                                        Criar Fluxo Sem QrCode
                                    </a>
                                </li>
                                 <li>

                                    <a href="./criar_fluxo_qr.aspx" class="mm-active">
                                        <i class="metismenu-icon fas fa-user-plus"></i>
                                        Criar Fluxo Com QrCode
                                    </a>
                                </li>
                                 <li>

                                    <a href="./criar_venda.aspx">
                                        <i class="metismenu-icon fas fa-plus"></i>
                                        Criar Venda
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">__________________________________</li>
                                 <li>

                                    <a href="./criar_avaliacao.aspx" >
                                        <i class="metismenu-icon fas fa-dollar-sign"></i>
                                        Criar Avaliação
                                    </a>
                                </li><li>

                                    <a href="./consultar_avaliacao.aspx">
                                        <i class="metismenu-icon fas fa-search-dollar"></i>
                                        Consultar Avaliaçao
                                    </a>
                                </li>
                                 <li class="app-sidebar__heading">__________________________________</li>
                                <li>
                                    <a href="./Default.aspx">
                                        <i class="metismenu-icon fas fa-car-alt"></i>
                                        Veículos
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="app-main__outer">
                    <asp:UpdatePanel ID="updatePanelEvt" runat="server">
                        <ContentTemplate>
                            <div class="app-main__inner">
                                <div class="app-page-title">
                                    <div class="page-title-wrapper">
                                        <div class="page-title-heading">
                                            <div class="page-title-icon">
                                                <i class="pe-7s-users icon-gradient bg-dark"></i>
                                            </div>
                                            <div>
                                                <b>Criar Fluxo</b>

                                                <div class="page-title-subheading">
                                                </div>
                                            </div>
                                        </div>
                                        <div class="page-title-actions">
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-12">
                                        <div class="mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header">
                                                <div class="card-header-title">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    DADOS                                       
                                                </div>
                                            </div>
                                            <div class="card-body bg-light">
                                                <div class="form-row">
                                                    <div class="col-md-4 mb-3">
                                                        <label for="ddlLoja" class="text-uppercase ml-2"><strong>Evento</strong></label>
                                                        <select id="ddlEvento" runat="server" name="ddlEvento" class="form-control" required="required" datasourceid="SqlDataSource2" datatextfield="nome" datavaluefield="nome">
                                                        </select>
                                                    </div>
                                                    <div class="col-md-5 mb-3">
                                                        <label for="txtCliente" class="text-uppercase ml-2"><strong>Cliente</strong></label>
                                                       
                                                        <input id="txtCliente" class="form-control" runat="server" placeholder="Nome do Cliente..." />
                                                    </div>
                                                    <div class="col-md-3 mb-3 mt-4">
                                                        <asp:LinkButton ID="btnSalvarPassante" runat="server" CssClass="btn btn-success fa fa-search form-control" OnClick="buscarCliente"></asp:LinkButton>
                                                    </div>

                                                </div>
                                            </div>
                                            <div class="card-footer">
                                                <div class="col-12">
                                                   <asp:Literal ID="tabelaPesquisa" runat="server"></asp:Literal>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <div class="app-wrapper-footer">
                        <div class="app-footer">
                            <div class="app-footer__inner">
                                <div class="app-footer-left">
                                    <ul class="nav">
                                        <li class="nav-item"></li>
                                    </ul>
                                </div>
                                <div class="app-footer-right">
                                    <ul class="nav">
                                        <li class="nav-item"></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
    </form>

   
    <script src="./assets/popper.min.js"></script>
    <script src="./assets/bootstrap.min.js"></script>
    <script src="./assets/jspdf.min.js"></script>
    <script src="./assets/scripts/main.js"></script>
</body>

</html>
