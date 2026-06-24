<%@ Page Language="C#" AutoEventWireup="true" CodeFile="transferir_lead.aspx.cs" Inherits="veiculos_contrato" %>

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
        <asp:SqlDataSource ID="SqlDataSource2" runat="server"
            ConnectionString="<%$ ConnectionStrings:APPConnectionString %>"
            SelectCommand="prospeccao_evento_po" SelectCommandType="StoredProcedure">
            <SelectParameters>
                <asp:ControlParameter Name="usuario" ControlID="usuarioLogado" PropertyName="Text" 
                                      DefaultValue="" ConvertEmptyStringToNull="false" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource7" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="gerencia_vendedor2" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource3" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="prospeccao_select_nmguerra_geral" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource4" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="prospeccao_select_nmguerra" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource5" runat="server"
            ConnectionString="<%$ ConnectionStrings:APPConnectionString %>"
            SelectCommand="gerencia_vendedor2" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource8" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="gerencia_vendedor2" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <div class="app-container app-theme-white body-tabs-shadow fixed-sidebar fixed-header ">
            <div class="app-header header-shadow">
                <div class="app-header__logo ">
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

                                    <a href="./dashboard_resultado.aspx" >
                                        <i class="metismenu-icon fas fa-chalkboard"></i>
                                        Dashboard Resultado
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">__________________________________</li>
                                <li>

                                    <a href="./criar_fluxo.aspx">
                                        <i class="metismenu-icon fas fa-user-plus"></i>
                                        Criar Fluxo
                                    </a>
                                </li>
                                 <li>

                                    <a href="./transferir.aspx" class="mm-active">
                                        <i class="metismenu-icon fas fa-exchange-alt"></i>
                                        Tranferir
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
                    <asp:UpdatePanel ID="updatePanel" runat="server">
                        <ContentTemplate>
                            <div class="app-main__inner">
                                <div class="app-page-title">
                                    <div class="page-title-wrapper">
                                        <div class="page-title-heading">
                                            <div class="page-title-icon">
                                                <i class="fas fa-exchange-alt icon-gradient bg-dark"></i>
                                            </div>
                                            <div>
                                                <b>Tranferir</b>

                                                <div class="page-title-subheading">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12 col-lg-12">
                                        <div class="mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header">
                                                
                                                <ul class="nav ml-2 col-md-3 ">
                                                    <li class="nav-item ">
                                                        Evento:
                                                        <select id="ddlEvento2" runat="server" name="ddlEvento2" class="form-control" required="required" datasourceid="SqlDataSource2" datatextfield="nome" datavaluefield="nome">
                                                        </select>

                                                    </li>
                                                </ul>
                                                <ul class="nav ml-2 col-md-2">
                                                    <li class="nav-item">Loja:
                                                        <select id="ddlLoja" runat="server" name="ddlLojadashboard" class="form-control" required="required">
                                                            <option>SAAN</option>
                                                        </select></li>
                                                </ul>
                                                <ul class="nav ml-2 col-md-3">
                                                    <li class="nav-item ">Vend. Origem:
                                                        <asp:DropDownList ID="ddlVendOrigem"  runat="server"  OnSelectedIndexChanged="getQuantidadeDisponivel" AutoPostBack="true" Font-Names="ddlVendOrigem" CssClass="form-control" required="required" DataSourceID="SqlDataSource4" DataTextField="fun_nmguerra" DataValueField="fun_nmguerra">
                                                        </asp:DropDownList></li>
                                                </ul>
                                                <ul class="nav ml-2 ">
                                                    <li class="nav-item ">Vend. Destino:
                                                        <select id="ddlVendDestino" data-live-search="true" runat="server" name="ddlVendDestino" class="form-control" required="required" datasourceid="SqlDataSource3" datatextfield="fun_nmguerra" datavaluefield="fun_nmguerra">
                                                        </select></li>
                                                </ul>

                                                <ul class="nav ml-2">
                                                    <li class="nav-item ">Quantidade:
                                                        <input id="txtQuantidade" runat="server" required="required" class="form-control"/></li>
                                                </ul>
                                                <ul class="nav ml-2">
                                                    <li class="nav-item">
                                                        <asp:LinkButton CssClass="btn btn-primary ml-xl-0 ml-md-1 col-xl-12" ID="btnProcessar" runat="server" Text="Transferir" ToolTip="Transferir" OnClick="transferir"><i class="fas fa-exchange-alt"></i></asp:LinkButton>
                                                    </li>
                                                </ul>

                                            </div>
                                            <div class="card-body">
                                                <div class="row">
                                                    <div class="bg-dark col-md-8 text-center"><span class="h5 text-white p-2">Quantidade disponivel do vendedor de origem:</span></div><div class="bg-primary col-md-4 text-center"><span class="h4 text-white p-3"><asp:Literal ID="literalQtdeDisponivel" runat="server"></asp:Literal></span></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <asp:UpdateProgress ID="UpdateProgress" runat="server" AssociatedUpdatePanelID="UpdatePanel"
                                                        DisplayAfter="50">
                                                        <ProgressTemplate>
                                                            <div class="loader"></div>
                                                        </ProgressTemplate>
                                                    </asp:UpdateProgress>
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
     <script type="text/javascript" src="./assets/scripts/main.js"></script>

</body>

</html>
