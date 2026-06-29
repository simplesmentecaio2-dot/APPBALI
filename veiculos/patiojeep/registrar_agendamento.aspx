<%@ Page Language="C#" AutoEventWireup="true" CodeFile="registrar_agendamento.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <title>REGISTRAR AGENDAMENTO | Pátio</title>
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
    <link href="./assets/css/bootstrap-datetimepicker.css" rel="stylesheet" />
    <link href="./assets/css/bootstrap-datetimepicker.min.css" rel="stylesheet" />



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
                                    <a href="./">
                                        <i class="metismenu-icon fas fa-home"></i>
                                        Início
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">Pátio</li>
                                <li>
                                    <a href="./registrar.aspx">
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
                                <li class="app-sidebar__heading">Entrega</li>
                                <li>
                                    <a href="./registrar_agendamento.aspx" class="mm-active">
                                        <i class="metismenu-icon fa fa-calendar-plus"></i>
                                        Registrar Agendamento
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
                                                <i class="fas fa-calendar-plus text-white"></i>
                                            </div>
                                            <div>
                                                <b>Registrar Agendamento</b>

                                                <div class="page-title-subheading">
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
                                                        <asp:TextBox ID="txtSerie" CssClass="form-control" runat="server" required="true" OnTextChanged="serieOnTextChanged" AutoPostBack="true"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="divider"></div>
                                                <div class="card-header-title">
                                                    Info do Veículo                                      
                                                </div>
                                                <div class="divider"></div>
                                                <div class="form-row">
                                                     <div class="input-group col-sm-12 col-md-6 col-lg-6 col-xl-3 mb-3">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text" id="Span7"><b>Localização</b></span>
                                                        </div>
                                                        <asp:TextBox type="text" ID="txtLocal" CssClass="form-control bg-white  " runat="server" OnTextChanged="serieOnTextChanged"></asp:TextBox>

                                                    </div>
                                                    <div class="input-group col-sm-12 col-md-6 col-lg-6 col-xl-3 mb-3">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text" id="Span8"><b>Pedido</b></span>
                                                        </div>
                                                        <asp:TextBox type="text" ID="txtPedido" CssClass="form-control bg-white  " runat="server" OnTextChanged="serieOnTextChanged"></asp:TextBox>

                                                    </div>
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
                                                </div>
                                                <div class="divider"></div>
                                                <div class="card-header-title">
                                                    Agendar                                       
                                                </div>
                                                <div class="divider"></div>
                                                <div class="form-row">
                                                    <div class="input-group col-sm-12 col-md-6 col-lg-6 col-xl-5 mb-3">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text" id="Span6"><b>DT Agendamento</b></span>
                                                        </div>
                                                        <asp:TextBox type="text" ID="dtAgendamento" CssClass="form-control bg-white" runat="server" ReadOnly="true"></asp:TextBox>


                                                    </div>
                                                    <div class="input-group col-sm-12 col-md-5 col-lg-3 mb-3">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text" id="Span5"><b>Loja</b></span>
                                                        </div>
                                                        <select id="ddlLoja" runat="server" class="form-control" required="required" datasourceid="SqlDataSource2" datatextfield="ds" datavaluefield="id">
                                                        </select>
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
                            <b>&copy;TECNOLOGIA</b> | Bali Brasília Automóveis - LTDA
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
    <!-- Bootstrap -->
    <!-- Bootstrap DatePicker -->
    <script src="./assets/js/moment.js"></script>
    <script src="./assets/js/bootstrap-datetimepicker.js"></script>
    <script src="assets/js/locales/bootstrap-datetimepicker.pt-BR.js"></script>
    <script type="text/javascript">
        $("#dtAgendamento").datetimepicker({ format: 'yyyy-mm-dd hh:ii', autoclose: true });
    </script>
    <script src="./assets/js/patio-jeep-ux.js?v=20260629-1"></script>


</body>

</html>
