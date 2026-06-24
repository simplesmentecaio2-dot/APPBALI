<%@ Page Language="C#" AutoEventWireup="true" CodeFile="10.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <title></title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <link rel="manifest" href="./manifest.json" />
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
    <script type="text/javascript" src="./assets/scripts/index.js"></script>
    <script type="text/javascript">
        function avisoAguarde() {
            if (document.getElementById('divProcessando')) {
                document.getElementById('divProcessando').style.display = '';
                return;
            }
            oDiv = document.createElement("div");
            with(oDiv) {
                id = "divProcessando";
            }
            document.body.appendChild(oDiv);
        }

        function GetConviteQrCode(id) {

            $.ajax({
                method: "post",
                url: 'prospeccao.aspx/GetConviteQrCode',
                data: '{id: ' + id + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                beforeSend: function() {

                },
                success: function(response) {
                    $('#labelCliente').html(response.d.Cliente);
                    $('#qr').html('<img class="img-fluid" src="' + response.d.QrCode + '" />');
                    $('#modalVendedor').html('Vendedor:<br/><br/> <b>' + response.d.Vendedor + '</b>');
                    $('#modalLoja').html('Loja: <b>' + response.d.Loja + '</b>');
                    $('#modalEquipe').html('Equipe: <b>' + response.d.Equipe + '</b>');
                },
                complete: function() {},
                error: function(error) {
                    alert("Error Text: " + error); // Display error message  
                }
            });
        }

    </script>

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
                                    <a href="#" class="mm-active">
                                        <i class="metismenu-icon fas fa-home"></i>
                                        Prospecção
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">Dashboards</li>
                                <li>
                                    <a href="./dashboard_evento.aspx">
                                        <i class="metismenu-icon fas fa-chart-bar"></i>
                                        Dashboard Evento
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
                    <div class="app-main__inner">
                        <ul class="body-tabs body-tabs-layout tabs-animated body-tabs-animated nav mb-3">
                            <li class="nav-item">
                                <a role="tab" class="nav-link show active" id="A1" data-toggle="tab" href="#tab-content-0" aria-selected="true">
                                    <span>Criar Convite</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a role="tab" class="nav-link" id="A2" data-toggle="tab" href="#tab-content-1" aria-selected="false">
                                    <span>Ranking</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a role="tab" class="nav-link" id="A3" data-toggle="tab" href="#tab-content-2">
                                    <span>QRCode</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a role="tab" class="nav-link" id="A4" data-toggle="tab" href="#tab-content-3">
                                    <span>Dashboard</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a role="tab" class="nav-link" id="A5" data-toggle="tab" href="#tab-content-4">
                                    <span>Auto Lead</span>
                                </a>
                            </li>
                        </ul>
                        <div class="tab-content">
                            <div class="tab-pane tabs-animation fade show active" id="tab-content-0" role="tabpanel">
                                <div class="app-page-title mt-3">
                                    <div class="page-title-wrapper">
                                        <div class="page-title-heading">
                                            <div class="page-title-icon">
                                                <i class="pe-7s-add-user icon-gradient bg-danger"></i>
                                            </div>
                                            <div>
                                                <strong>Criar Convite</strong>
                                                <div class="page-title-subheading">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal fade mt-5" id="descarte" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" style="display: none;" aria-hidden="true">
                                    <div class="modal-dialog" role="document">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title" id="H1">Descarte</h5>
                                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                    <span aria-hidden="true"><i class="far fa-times-circle"></i></span>
                                                </button>
                                            </div>
                                            <div id="Div2" style="letter-spacing: 1px;" class="modal-body">
                                                <asp:UpdatePanel ID="upDescarte" runat="server">
                                                    <ContentTemplate>
                                                        <div class="mb-3">
                                                            <label for="ddlVendedorDescarte" class="">Prospector:</label>
                                                            <select runat="server" name="ddlVendedor" id="ddlVendedorDescarte" runat="server" datasourceid="SqlDataSource1" datatextfield="fun_nm" datavaluefield="fun_nm" class="form-control" required="required">
                                                            </select>
                                                            <div class="valid-feedback">
                                                                Ok!
                                                            </div>
                                                        </div>
                                                        <div class=" mb-3">
                                                            <label for="ddlLoja" class="">Loja:</label>
                                                            <select id="ddlLojaDescarte" runat="server" name="ddlLojaDescarte" class="form-control" required="required">
                                                                <option disabled selected></option>
                                                                <option>AERO</option>
                                                                <option>SAAN</option>
                                                                <option>SIA</option>
                                                                <option>SCIA</option>
                                                            </select>
                                                        </div>
                                                        <div class=" mb-3">
                                                            <label for="ddlEventoDescarte" class="">Evento:</label>
                                                            <select id="ddlEventoDescarte" runat="server" name="ddlEventoDescarte" class="form-control" required="required">
                                                                <option>Campanha Argo Trekking</option>
                                                                <option>VD Campanha Argo Trekking</option>
                                                                <option selected>CAMPANHA TORO</option>
                                                            </select>
                                                        </div>
                                                    </ContentTemplate>
                                                    <Triggers>
                                                        <asp:AsyncPostBackTrigger ControlID="btnGravarDescarte" EventName="Click" />
                                                    </Triggers>
                                                </asp:UpdatePanel>

                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-danger" data-dismiss="modal"><i class="fas fa-times"></i></button>
                                                <asp:LinkButton ID="btnGravarDescarte" CssClass="btn btn-success" runat="server" OnClick="btnGravarDescarte_Click">Gravar Descarte</asp:LinkButton>

                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <asp:UpdatePanel ID="convite" runat="server">
                                    <ContentTemplate>
                                        <div class="row">
                                            <div class="col-md-12">
                                                <div class="main-card mb-3 card">
                                                    <div class="card-header-tab card-header-tab-animation card-header mb-3">
                                                        <div class="card-header-title">
                                                            <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                            Dados do Cliente
                                                        </div>
                                                    </div>
                                                    <div class="container-fluid">
                                                        <div class="row">
                                                            <div class="main-card">

                                                                <div class="card-body">

                                                                    <div class="form-row">
                                                                        <div class="col-md-6 mb-3">
                                                                            <label for="txtCliente">Cliente:</label>
                                                                            <input type="text" id="txtCliente" class="form-control" runat="server" placeholder="Nome do Cliente..." required="true">
                                                                            <div class="valid-feedback">
                                                                                Ok!
                                                                            </div>
                                                                        </div>
                                                                        <div class="col-md-2 mb-3">
                                                                            <label for="ddlClassificacao" class="">Classificação:</label>
                                                                            <select id="ddlClassificacao" runat="server" name="ddlClassificacao" class="form-control" required="required">
                                                                                <option disabled selected></option>
                                                                                <option>Quente</option>
                                                                                <option>Frio</option>
                                                                                <option>Sem Interesse</option>
                                                                            </select>
                                                                        </div>
                                                                        <div class="col-md-4 mb-3">
                                                                            <label for="ddlVendedor" class="">Prospector:</label>
                                                                            <select runat="server" name="ddlVendedor" id="ddlVendedor" runat="server" datasourceid="SqlDataSource1" datatextfield="fun_nm" datavaluefield="fun_nm" class="form-control" required="required">
                                                                            </select>
                                                                            <div class="valid-feedback">
                                                                                Ok!
                                                                            </div>
                                                                        </div>

                                                                        <div class="col-md-4 mb-3">
                                                                            <label for="txtTelefone">Telefone:</label>
                                                                            <input type="text" class="form-control" id="txtTelefone" runat="server" name="phone" required="required">
                                                                            <div class="valid-feedback">
                                                                                Ok!
                                                                            </div>
                                                                        </div>
                                                                        <div class="col-md-4 mb-3">
                                                                            <label for="ddlEvento" class="">Evento:</label>
                                                                            <select id="ddlEvento" runat="server" name="ddlEvento" class="form-control" required="required">
                                                                                <option>Campanha Argo Trekking</option>
                                                                                <option>VD Campanha Argo Trekking</option>
                                                                                <option selected>CAMPANHA TORO</option>
                                                                            </select>
                                                                        </div>
                                                                        <div class="col-md-4 mb-3">
                                                                            <label for="ddlLoja" class="">Loja:</label>
                                                                            <select id="ddlLoja" runat="server" name="ddlEvento" class="form-control" required="required">
                                                                                <option disabled selected></option>
                                                                                <option>AERO</option>
                                                                                <option>SAAN</option>
                                                                                <option>SIA</option>
                                                                                <option>SCIA</option>
                                                                            </select>
                                                                        </div>
                                                                    </div>
                                                                    <div class="form-row">
                                                                        <div class="col-md-6 mb-3">
                                                                            <label for="txtEmail">Email</label>
                                                                            <input type="email" class="form-control" id="txtEmail" runat="server" placeholder="exemplo@exemplo.com.br">
                                                                        </div>
                                                                        <div class="col-md-4 mb-3">
                                                                            <label for="ddlequipe" class="">Equipe:</label>
                                                                            <select id="ddlequipe" runat="server" name="ddlequipe" class="form-control" required="required">
                                                                                <option disabled selected></option>
                                                                                <option>AMARELA</option>
                                                                                <option>AZUL</option>
                                                                                <option>BRANCA</option>
                                                                                <option>VERDE</option>
                                                                            </select>
                                                                        </div>
                                                                    </div>
                                                                    <script>
                                                                        // Example starter JavaScript for disabling form submissions if there are invalid fields
                                                                        (function () {
                                                                            'use strict';
                                                                            window.addEventListener('load', function () {
                                                                                // Fetch all the forms we want to apply custom Bootstrap validation styles to
                                                                                var forms = document.getElementsByClassName('needs-validation');
                                                                                // Loop over them and prevent submission
                                                                                var validation = Array.prototype.filter.call(forms, function (form) {
                                                                                    form.addEventListener('submit', function (event) {
                                                                                        if (form.checkValidity() === false) {
                                                                                            event.preventDefault();
                                                                                            event.stopPropagation();
                                                                                        }
                                                                                        form.classList.add('was-validated');
                                                                                    }, false);
                                                                                });
                                                                            }, false);
                                                                        })();
                                                                    </script>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="d-block text-center card-footer">
                                                        <asp:Button ID="btnGravar" CssClass="btn-lg btn btn-success fa-save" runat="server" Text="Gravar" OnClick="btnGravar_Click" />
                                                        <button class="btn btn-warning" data-toggle='modal' data-target='#descarte'><i class="fas fa-trash"></i>Descarte</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                            <div class="tab-pane tabs-animation fade show" id="tab-content-1" role="tabpanel">
                                <asp:UpdatePanel ID="ranking" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                    <ContentTemplate>
                                        <div class="app-page-title mt-3">
                                            <div class="page-title-wrapper">
                                                <div class="page-title-heading">
                                                    <div class="page-title-icon">
                                                        <i class="pe-7s-graph1 icon-gradient bg-danger"></i>
                                                    </div>
                                                    <div>
                                                        <strong>Ranking</strong>
                                                        <div class="page-title-subheading">
                                                        </div>
                                                    </div>
                                                </div>

                                            </div>
                                        </div>

                                        <div class="row">
                                            <div class="col-md-12">
                                                <div class="main-card mb-3 card">
                                                    <div class="card-header-tab card-header-tab-animation card-header">
                                                        <div class="card-header-title">
                                                            <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                            Evento
                                                        </div>
                                                        <ul class="nav mb-2">
                                                            <li class="nav-item">Nome:
                                                            </li>
                                                            <li class="nav-item">
                                                                <select id="ddlEventoRanking" class="form-control" runat="server">
                                                                    <option>Campanha Argo Trekking</option>
                                                                    <option>VD Campanha Argo Trekking</option>
                                                                    <option selected>CAMPANHA TORO</option>
                                                                </select>
                                                            </li>
                                                        </ul>
                                                        <ul class="nav mb-2">
                                                            <li class="nav-item">Loja:
                                                            </li>
                                                            <li class="nav-item">
                                                                <select id="ddlLojaRanking" class="form-control" runat="server">
                                                                    <option selected="selected"></option>
                                                                    <option>AERO</option>
                                                                    <option>SAAN</option>
                                                                    <option>SCIA</option>
                                                                    <option>SIA</option>
                                                                </select>
                                                            </li>
                                                            <li class="nav-item">
                                                                <asp:LinkButton ID="showData" class="btn btn-lg btn-primary pe-7s-search" OnClick="btnShowData" runat="server"></asp:LinkButton>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-5">
                                                <div class="main-card mb-3 card">
                                                    <div class="card-header-tab card-header-tab-animation card-header mb-3">
                                                        <div class="card-header-title">
                                                            <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                            Equipes
                                                        </div>
                                                    </div>
                                                    <div class="container">
                                                        <div class="row">
                                                            <asp:Literal ID="equipesRanking" runat="server"></asp:Literal>
                                                            <asp:SqlDataSource ID="SqlDataSource6" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="SELECT loja,equipe,count(*) as qtde FROM [APP].[dbo].[veiculos_prospeccao]  where nome_evento = 'SEU FIAT EM DIA' group by loja,equipe  order by loja desc"></asp:SqlDataSource>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-7">
                                                <div class="main-card mb-3 card">
                                                    <div class="card-header-tab card-header-tab-animation card-header">
                                                        <div class="card-header-title">
                                                            <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                            Gráfico
                                                        </div>
                                                        <ul class="nav">
                                                            <li class="nav-item">Tipo de gráfico:</li>
                                                            <li class="nav-item">
                                                                <select id="tipoGrafico" class="badge badge-dot " runat="server">
                                                                    <option>bar</option>
                                                                    <option>pie</option>
                                                                </select>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                    <div class="container">
                                                        <div class="row">
                                                            <div class="container">
                                                                <canvas id="bar" width="100%" responsive="true"></canvas>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="showData" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                            <div class="tab-pane tabs-animation fade show" id="tab-content-2" role="tabpanel">

                                <div class="modal fade mt-5" id="qrcode" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" style="display: none;" aria-hidden="true">
                                    <div class="modal-dialog" role="document">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title" id="exampleModalLabel">Convite</h5>
                                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                    <span aria-hidden="true"><i class="far fa-times-circle"></i></span>
                                                </button>
                                            </div>
                                            <div id="conviteQrCode" style="letter-spacing: 1px;" class="modal-body">
                                                <div class="badge badge-light">
                                                    <div class="text-center h3">
                                                        <b>
                                                            <label id="labelCliente" class="badge badge-info">
                                                        </b></label>
                                                    </div>
                                                    <div class="text-center">
                                                        <label>VOCÊ FOI CONVIDADO(A) PARA O EVENTO !!</label>
                                                    </div>
                                                    <div class="text-center">
                                                        <label class="badge badge-secondary font-size-lg">CAMPANHA TORO</label>
                                                    </div>
                                                    <br />
                                                    <div class="text-center">
                                                        <label>TRAGA O QRCode</label>
                                                    </div>
                                                    <div class="text-center col-md-8 col-8 offset-2">
                                                        <div id="qr"></div>
                                                    </div>
                                                    <br />
                                                    <div class="text-center col-md-8 col-8 offset-2">
                                                        <div id="modalVendedor"></div>
                                                    </div>
                                                    <br />
                                                    <div class="text-center col-md-8 col-8 offset-2">
                                                        <div id="modalLoja"></div>
                                                    </div>
                                                    <br />
                                                    <div class="text-center col-md-8 col-8 offset-2">
                                                        <div id="modalEquipe"></div>
                                                    </div>
                                                    <br />
                                                    <img src="../img/logobali.png" />
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-danger" data-dismiss="modal"><i class="fas fa-times"></i></button>
                                                <button id="printConvite" type="button" class="btn btn-primary"><i class="fas fa-print fa-2x"></i></button>
                                                <button type="button" onclick="DownloadAsImage()" class="btn btn-success"><i class="fas fa-file-download fa-2x"></i></button>
                                                <script src="https://rawgit.com/dabeng/OrgChart/master/demo/js/jspdf.min.js"></script>

                                                <script>

                                                    document.getElementById('printConvite').onclick = function () {
                                                        var conteudo = '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"><link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous"><title>Print</title></head><body>' + document.getElementById('conviteQrCode').innerHTML + '</body></html>',
                                                        tela_impressao = window.open('about:blank');

                                                        tela_impressao.document.write(conteudo);
                                                    };
                                                    function downloadURI(uri, name) {
                                                        var link = document.createElement("a");

                                                        link.download = name;
                                                        link.href = uri;
                                                        document.body.appendChild(link);
                                                        link.click();
                                                        document.body.appendChild(link).removeChild;
                                                    }
                                                    function DownloadAsImage(nomeArquivo) {
                                                        var element = $("#conviteQrCode")[0];
                                                        html2canvas(element).then(function (canvas) {
                                                            var myImage = canvas.toDataURL();
                                                            downloadURI(myImage, "cartao-virtual.png");
                                                        });
                                                    }
                                                </script>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                    <ContentTemplate>
                                        <div class="app-page-title mt-3">
                                            <div class="page-title-wrapper">
                                                <div class="page-title-heading">
                                                    <div class="page-title-icon">
                                                        <i class="fas fa-qrcode icon-gradient bg-danger"></i>
                                                    </div>
                                                    <div>
                                                        <strong>QRCode</strong>
                                                        <div class="page-title-subheading">
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-12">
                                                <div class="main-card mb-3 card">
                                                    <div class="card-header-tab card-header-tab-animation card-header mb-3">
                                                        <div class="card-header-title">
                                                            <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                            <asp:LinkButton ID="Button3" CssClass="btn btn-lg btn-success pe-7s-refresh font-size-lg font-weight-bold" runat="server" Text="Processar Tabela" OnClick="Button1_Click" />
                                                        </div>
                                                    </div>
                                                    <div class="container-fluid mb-3">
                                                        <%=tabela2 %>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <asp:UpdateProgress ID="UpdateProgress2" runat="server" AssociatedUpdatePanelID="UpdatePanel1" DisplayAfter="50">
                                            <ProgressTemplate>
                                                <div class="loader"></div>
                                            </ProgressTemplate>
                                        </asp:UpdateProgress>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="Button3" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                            <div class="tab-pane tabs-animation fade show" id="tab-content-3" role="tabpanel">
                                <div class="app-page-title mt-3">
                                    <div class="page-title-wrapper">
                                        <div class="page-title-heading">
                                            <div class="page-title-icon">
                                                <i class="fas fa-chart-bar icon-gradient bg-danger"></i>
                                            </div>
                                            <div>
                                                <strong>Dashboard</strong>
                                                <div class="page-title-subheading">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="main-card mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header mb-3">
                                                <div class="card-header-title font-size-lg mr-2">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    <b>Projeção</b>
                                                </div>
                                                <ul class="nav">
                                                    <li class="nav-item mr-1">Evento:
                                                        <select id="ddlEvento2" runat="server" name="ddlEvento2" class="form-control" required="required">
                                                            <option>Campanha Argo Trekking</option>
                                                            <option>VD Campanha Argo Trekking</option>
                                                            <option>CAMPANHA TORO</option>
                                                            <option>FIAT D</option>
                                                            <option>SEU FIAT EM DIA</option>
                                                        </select></li>
                                                </ul>
                                                <ul class="nav">
                                                    <li class="nav-item">Loja:
                                                        <select id="ddlLojadashboard" runat="server" name="ddlLojadashboard" class="form-control" required="required">
                                                            <option disabled selected></option>
                                                            <option>SIA</option>
                                                            <option>SAAN</option>
                                                            <option>SCIA</option>
                                                            <option>AERO</option>
                                                        </select></li>
                                                </ul>
                                                <ul class="nav">
                                                    <li class="nav-item">
                                                        <asp:LinkButton CssClass="btn btn-primary ml-xl-0 ml-md-1 col-xl-12" ID="btnProcessar" runat="server" OnClick="btnProcessar_Click"><i class="fas fa-sync"></i></asp:LinkButton>
                                                    </li>
                                                </ul>
                                            </div>
                                            <div class="container-fluid mb-3 ">
                                                <asp:UpdatePanel ID="upFluxo" runat="server">
                                                    <ContentTemplate>
                                                        <button class="mb-2 mr-2 col-6 btn btn-primary  font-size-lg">
                                                            Quantidade Total:</button>
                                                        <button class="mb-2 mr-2 col-3 btn btn-dark  font-size-lg">
                                                            <asp:Label ID="lblqtde" runat="server" Text="0"></asp:Label>
                                                        </button><br />
                                                        <button class="mb-2 mr-2 col-6  btn btn-danger font-size-lg">Quentes:</button>
                                                        <button class="mb-2 mr-2 col-3 btn btn-dark  font-size-lg">
                                                            <asp:Label ID="lblquentes" runat="server" Text="0"></asp:Label>
                                                        </button><br />
                                                        <button class="mb-2 mr-2 col-6  btn btn-success font-size-lg">Frios:</button>
                                                        <button class="mb-2 mr-2 col-3 btn btn-dark  font-size-lg">
                                                            <asp:Label ID="lblfrios" runat="server" Text="0"></asp:Label>
                                                        </button><br />
                                                        <button class="mb-2 mr-2 col-6  btn btn-alternate font-size-lg">Sem Interesse:</button>
                                                        <button class="mb-2 mr-2 col-3 btn btn-dark  font-size-lg">
                                                            <asp:Label ID="lblseminteresse" runat="server" Text="0"></asp:Label>
                                                        </button><br />
                                                        <button class="mb-2 mr-2 col-6  btn btn-warning font-size-lg">Projeção de Fluxo:</button>
                                                        <button class="mb-2 mr-2 col-3 btn btn-dark  font-size-lg">
                                                            <asp:Label ID="lblFluxo" runat="server" Text="00"></asp:Label>
                                                        </button><br />
                                                        <button class="mb-2 mr-2 col-6  btn btn-secondary font-size-lg">Projeção de Venda de Veículo:</button>
                                                        <button class="mb-2 mr-2 col-3 btn btn-dark  font-size-lg">
                                                            <asp:Label ID="lblvendacarro" runat="server" Text="0"></asp:Label>
                                                        </button>
                                                    </ContentTemplate>
                                                    <Triggers>
                                                        <asp:AsyncPostBackTrigger ControlID="btnProcessar" EventName="Click" />
                                                    </Triggers>
                                                </asp:UpdatePanel>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="main-card mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header mb-3">
                                                <div class="card-header-title">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    <b>Meta de Fluxo</b>
                                                </div>
                                            </div>
                                            <div class="container-fluid mb-3 ">
                                                <button class="mb-2 mr-2 btn btn-primary font-size-lg mb-2">SIA<span class="badge badge-light font-size-lg">200</span></button>
                                                <button class="mb-2 mr-2 btn btn-danger font-size-lg mb-2">SAAN<span class="badge badge-light font-size-lg">60</span></button>
                                                <button class="mb-2 mr-2 btn btn-success font-size-lg mb-2">SCIA<span class="badge badge-light font-size-lg">45</span></button>
                                                <button class="mb-2 mr-2 btn btn-secondary font-size-lg mb-2">AERO<span class="badge badge-light font-size-lg">45</span></button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                    </div>
                                    <div class="col-md-12">
                                        <div class="main-card mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header mb-3">
                                                <div class="card-header-title">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    Leads por Prospector
                                                </div>
                                            </div>
                                            <div class="container-fluid mb-3">
                                                <asp:UpdatePanel runat="server" ID="upTableLeadsVendedor">
                                                    <ContentTemplate>
                                                        <asp:Literal ID="tableLeadsVendedor" runat="server"></asp:Literal>
                                                    </ContentTemplate>
                                                    <Triggers>
                                                        <asp:AsyncPostBackTrigger ControlID="btnProcessar" EventName="Click" />
                                                    </Triggers>
                                                </asp:UpdatePanel>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="tab-pane tabs-animation fade show" id="tab-content-4" role="tabpanel">
                                <div class="app-page-title mt-3">
                                    <div class="page-title-wrapper">
                                        <div class="page-title-heading">
                                            <div class="page-title-icon">
                                                <i class="fas fa-chart-bar icon-gradient bg-danger"></i>
                                            </div>
                                            <div>
                                                <strong>Leads</strong>
                                                <div class="page-title-subheading">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="main-card mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header mb-3">
                                                <div class="card-header-title font-size-lg mr-2">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    <b>Lead</b>
                                                </div>
                                                <ul class="nav">
                                                    <li class="nav-item">
                                                        <select class="custom-select text-uppercase" runat="server" name="ddlVendedor" id="ddlEventoGeraLead" runat="server" datasourceid="SqlDataSource2" datatextfield="nome" datavaluefield="nome">
                                                        </select>
                                                    </li>
                                                    <li class="nav-item">
                                                        <asp:LinkButton ID="btnAtualizaLeadTop" class="btn btn-lg btn-primary fas fa-sync-alt" OnClick="btnAtualizaLead_Click" runat="server"></asp:LinkButton>
                                                    </li>
                                                </ul>
                                            </div>
                                            <div class="modal fade mt-5" runat="server" id="qrcodeLead" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" style="display: none;" aria-hidden="true">
                                                <div class="modal-dialog" role="document">
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title" id="H2">Convite</h5>
                                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                <span aria-hidden="true"><i class="far fa-times-circle"></i></span>
                                                            </button>
                                                        </div>
                                                        <div id="Div3" style="letter-spacing: 1px;" class="modal-body">
                                                            <div class="badge badge-light">
                                                                <div class="text-center h3">
                                                                    <b>
                                                                        <label id="labelClienteLead" class="badge badge-info">
                                                                    </b></label>
                                                                </div>
                                                                <div class="text-center">
                                                                    <label>VOCÊ FOI CONVIDADO(A) PARA O EVENTO !!</label>
                                                                </div>
                                                                <div class="text-center">
                                                                    <label class="badge badge-secondary font-size-lg">CAMPANHA TORO</label>
                                                                </div>
                                                                <br />
                                                                <div class="text-center">
                                                                    <label>TRAGA O QRCode</label>
                                                                </div>
                                                                <div class="text-center col-md-8 col-8 offset-2">
                                                                    <div id="qrLead"></div>
                                                                </div>
                                                                <br />
                                                                <div class="text-center col-md-8 col-8 offset-2">
                                                                    <div id="vendedorLeadModal"></div>
                                                                </div>
                                                                <br />
                                                                <div class="text-center col-md-8 col-8 offset-2">
                                                                    <div id="lojaLeadModal"></div>
                                                                </div>
                                                                <br />
                                                                <div class="text-center col-md-8 col-8 offset-2">
                                                                    <div id="equipeLeadModal"></div>
                                                                </div>
                                                                <br />
                                                                <img src="../img/logobali.png" />
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-danger" data-dismiss="modal"><i class="fas fa-times"></i></button>
                                                            <button id="Button2" type="button" class="btn btn-primary"><i class="fas fa-print fa-2x"></i></button>
                                                            <button type="button" onclick="DownloadAsImage()" class="btn btn-success"><i class="fas fa-file-download fa-2x"></i></button>

                                                            <script>

                                                                document.getElementById('printConvite').onclick = function () {
                                                                    var conteudo = '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"><link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous"><title>Print</title></head><body>' + document.getElementById('conviteQrCode').innerHTML + '</body></html>',
                                                                    tela_impressao = window.open('about:blank');

                                                                    tela_impressao.document.write(conteudo);
                                                                };
                                                                function downloadURI(uri, name) {
                                                                    var link = document.createElement("a");

                                                                    link.download = name;
                                                                    link.href = uri;
                                                                    document.body.appendChild(link);
                                                                    link.click();
                                                                    clearDynamicLink(link);
                                                                }
                                                                function DownloadAsImage(nomeArquivo) {
                                                                    var element = $("#conviteQrCode")[0];
                                                                    html2canvas(element).then(function (canvas) {
                                                                        var myImage = canvas.toDataURL();
                                                                        downloadURI(myImage, "cartao-virtual.png");
                                                                    });
                                                                }
                                                            </script>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                                                <ContentTemplate>
                                                    <div id="campoLead" class="container" runat="server">
                                                        <div class="container-fluid mb-3 ">


                                                            <ul class="list-group">
                                                                <button class="active list-group-item-action list-group-item text-uppercase ">
                                                                    <i class="far fa-user mr-1 fa-2x"></i>
                                                                    <b class="mb-3">
                                                                        <asp:Label runat="server" ID="txtIdLead"></asp:Label>
                                                                        <asp:Label runat="server" ID="txtNomeLead"></asp:Label>
                                                                    </b>
                                                                </button>

                                                                <button class="list-group-item-action list-group-item">
                                                                    <i class="fas fa-phone-alt mr-1 fa-2x"></i>
                                                                    <b class="mb-3">
                                                                        <asp:Label runat="server" ID="txtTelLead"></asp:Label>
                                                                    </b>
                                                                </button>
                                                                <button class="list-group-item-action list-group-item text-uppercase">
                                                                    <i class="fas fa-car mr-1 fa-2x"></i>
                                                                    <b class="mb-3">
                                                                        <asp:Label runat="server" ID="txtCarroLead"></asp:Label>
                                                                    </b></button>
                                                                <div class="input-group">
                                                                    <div class="input-group-prepend">
                                                                        <label class="input-group-text" for="ddlClassificacaoLead">Classificação:</label>
                                                                    </div>
                                                                    <select class="custom-select text-uppercase" runat="server" id="ddlClassificacaoLead">
                                                                        <option value="Quente"></option>
                                                                        <option value="Frio"></option>
                                                                        <option value="Sem Interesse"></option>
                                                                    </select>
                                                                </div>
                                                                <div id="divEquipeLead" runat="server" class="input-group ">
                                                                    <div class="input-group-prepend">
                                                                        <label class="input-group-text" for="ddlEquipeLead">Equipe:</label>
                                                                    </div>
                                                                    <select class="custom-select text-uppercase" runat="server" id="ddlEquipeLead">
                                                                        <option selected value="SEM EQUIPE"></option>
                                                                        <option value="AZUL"></option>
                                                                        <option value="AMARELA"></option>
                                                                        <option value="BRANCA"></option>
                                                                        <option value="VERDE"></option>
                                                                    </select>
                                                                </div>
                                                            </ul>

                                                        </div>

                                                        <div class="card-footer">
                                                            <asp:LinkButton ID="btnSalvarLead" runat="server" OnClick="btnSalvarLead_Click" CssClass="btn btn-lg btn-success offset-4 mr-2 "><i class="far fa-thumbs-up fa-2x"></i></asp:LinkButton>

                                                            <asp:LinkButton ID="btnDescartarLead" runat="server" OnClick="btnDescartaLead_Click" CssClass="btn btn-lg btn-danger"><i class="far fa-trash-alt fa-2x"></i></asp:LinkButton>
                                                        </div>
                                                    </div>
                                                    <div class="container">
                                                        <div runat="server" id="no_logado" visible="false">
                                                            <div class='alert alert-danger fade show' role='alert'>
                                                                <i class='fas fa-user-shield fa-2x'></i>É necessário estar logado para utilizar esta funcionalidade! <a href="../Login.aspx">
                                                                    <link id='Button1' runat='server' class='offset-4 mr-2 '>login <i class="fas fa-sign-out-alt"></i></link>
                                                                </a>
                                                            </div>
                                                        </div>
                                                        <div runat="server" id="no_lead" visible="false">
                                                            <div class='alert alert-danger fade show' role='alert'>
                                                                <i class='fas fa-comment-slash'></i>Não há Leads disponíveis!
                                                                <asp:LinkButton runat="server" ID="LinkButton1" OnClick="btnAtualizaLead_Click"><i class="fas fa-sync-alt"></i></asp:LinkButton>
                                                            </div>
                                                        </div>
                                                        <div runat="server" id="error_lead" visible="false">
                                                            <div class='alert alert-danger fade show' role='alert'>
                                                                <i class='fas fa-comment-slash'></i>Erro ao carregar Lead!
                                                                <asp:LinkButton runat="server" ID="LinkButton2" OnClick="btnAtualizaLead_Click"><i class="fas fa-sync-alt"></i></asp:LinkButton>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <!-- Modal -->
                                                    <div class="modal fade mt-5" id="myModal" role="dialog">
                                                        <div class="modal-dialog">

                                                            <!-- Modal content-->
                                                            <div class="modal-content">
                                                                <div class="modal-header">
                                                                    <h4 class="modal-title">QRCode</h4>
                                                                    <button type="button" class="close" data-dismiss="modal">&times;</button>

                                                                </div>
                                                                <div id="conviteQrCodeLead" style="letter-spacing: 1px;" class="modal-body text-center">
                                                                    <div class="badge badge-light">
                                                                        <div class="text-center h3">
                                                                            <b>
                                                                                <label id="txtClienteQrLead" runat="server" class="badge badge-info">
                                                                            </b></label>
                                                                        </div>
                                                                        <div class="text-center">
                                                                            <label>VOCÊ FOI CONVIDADO(A) PARA O EVENTO !!</label>
                                                                        </div>
                                                                        <div class="text-center">
                                                                            <label id="txtEventoQrLead" runat="server" class="badge badge-secondary font-size-lg"></label>
                                                                        </div>
                                                                        <br />
                                                                        <div class="text-center">
                                                                            <label>TRAGA O QRCode</label>
                                                                        </div>
                                                                        <div class="text-center col-md-8 col-8 offset-2">
                                                                            <div id="imgQrLead" runat="server"></div>
                                                                        </div>
                                                                        <br />
                                                                        <div class="text-center col-md-8 col-8 offset-2">
                                                                            <div id="txtVendedorQrLead" runat="server"></div>
                                                                        </div>
                                                                        <br />
                                                                        <div class="text-center col-md-8 col-8 offset-2">
                                                                            <div id="txtLojaQrLead" runat="server"></div>
                                                                        </div>
                                                                        <br />
                                                                        <div class="text-center col-md-8 col-8 offset-2">
                                                                            <div id="txtEquipeQrLead" runat="server"></div>
                                                                        </div>
                                                                        <input id="filesShare" type="file" />
                                                                        <br />
                                                                        <img src="../img/logobali.png" />
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <button type="button" class="btn btn-danger" data-dismiss="modal"><i class="fas fa-times"></i></button>
                                                                    <button id="printConviteLead" type="button" class="btn btn-primary"><i class="fas fa-print fa-2x"></i></button>
                                                                    <button id="share" type="button" onclick="testWebShare()" class="btn btn-success"><i class="fas fa-file-download fa-2x"></i></button>

                                                                </div>
                                                            </div>

                                                        </div>
                                                    </div>
                                                    <asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="UpdatePanel2" DisplayAfter="50">
                                                        <ProgressTemplate>
                                                            <div class="loader"></div>
                                                        </ProgressTemplate>
                                                    </asp:UpdateProgress>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="main-card mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header mb-3">
                                                <div class="card-header-title">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    <b>Acompanhamento</b>
                                                </div>
                                            </div>
                                            <asp:UpdatePanel ID="updateAcompanhamento" runat="server">
                                                <ContentTemplate>
                                                    <div class="container-fluid mb-3 ">
                                                        <div class="col-md-12 col-xl-12">
                                                            <div class="card mb-3 widget-content bg-animation bg-danger">
                                                                <div class="widget-content-wrapper text-white">
                                                                    <div class="widget-content-left">
                                                                        <div class="widget-heading">Pendentes</div>
                                                                        <div class="widget-subheading">Quantidade</div>
                                                                    </div>
                                                                    <div class="widget-content-right">
                                                                        <div class="widget-numbers text-white"><span id="txtQtdePendentes" runat="server"></span></div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-12 col-xl-12">
                                                            <div class="card mb-3 widget-content bg-primary">
                                                                <div class="widget-content-wrapper text-white">
                                                                    <div class="widget-content-left">
                                                                        <div class="widget-heading">Realizados</div>
                                                                        <div class="widget-subheading">Quantidade</div>
                                                                    </div>
                                                                    <div class="widget-content-right">
                                                                        <div class="widget-numbers text-white"><span id="txtQtdeRealizados" runat="server"></span></div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>

                                                    </div>
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="btnSalvarLead" EventName="Click" />
                                                    <asp:AsyncPostBackTrigger ControlID="btnDescartarLead" EventName="Click" />
                                                    <asp:AsyncPostBackTrigger ControlID="btnAtualizaLeadTop" EventName="Click" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <script src="./assets/AuthenticationService.js"></script>
                <script src="./assets/common.js"></script>
                <script src="./assets/js.js"></script>
            </div>
        </div>
        <script type="text/javascript" src="./assets/scripts/main.js"></script>




    </form>

    <script>
        function changeLabel(cod) {
            lbl = document.getElementById('cod');
            // Assign HTML codes along with text values using innerHTML.
            lbl.innerHTML = cod;
        }

    </script>
    <script src="./assets/popper.min.js"></script>
    <script src="./assets/bootstrap.min.js"></script>
    <script src="./assets/jspdf.min.js"></script>
    <script>
        function convertBase64ToFile(image) {
            const byteString = atob(image.split(',')[1]);
            const ab = new ArrayBuffer(byteString.length);
            const ia = new Uint8Array(ab);
            for (let i = 0; i < byteString.length; i += 1) {
                ia[i] = byteString.charCodeAt(i);
            }
            const newBlob = new Blob([ab], {
                type: 'image/jpeg',
            });
        return newBlob;
        }

        function downloadURI(uri, name) {
            var link = document.createElement("a");

            link.download = name;
            link.href = uri;
            document.body.appendChild(link);
            link.click();
            document.body.appendChild(link).removeChild;
        }

        function DownloadAsImage(nomeArquivo) {
            var element = $("#conviteQrCodeLead")[0];
            html2canvas(element).then(function(canvas) {
                var myImage = canvas.toDataURL();
                downloadURI(myImage, nomeArquivo + '.png');
            });
        }

        function htmlToBase64Image(nameFile, idElement) {
            var element = $("#" + idElement)[0];
            var stringBase64 = html2canvas(element).then(function(canvas) {
                return canvas.toDataURL();

            });
            return stringBase64;
        }
        'use strict';

        function sleep(delay) {
            return new Promise(resolve => {
                setTimeout(resolve, delay);
        });
        }

        function logText(message, isError) {
            if (isError)
                console.error(message);
            else
                console.log(message);

            const p = document.createElement('p');
            if (isError)
                p.setAttribute('class', 'error');
            document.querySelector('#output').appendChild(p);
            p.appendChild(document.createTextNode(message));
        }

        function logError(message) {
            logText(message, true);
        }

        function checkboxChanged(e) {
            const checkbox = e.target;
            const textfield = document.querySelector('#' + checkbox.id.split('_')[0]);

            textfield.disabled = !checkbox.checked;
            if (!checkbox.checked)
                textfield.value = '';
        }

        async function testWebShare() {


            if (navigator.share === undefined) {
                DownloadAsImage(document.querySelector('#txtClienteQrLead').textContent);
                return;
            }


            try {
                if (window.navigator.canShare && window.navigator.canShare({
                    files: [new File([convertBase64ToFile(document.querySelector('#qrLeadImg').src)], "invoice.png", {
                    type: "image/png",
                    mimeType: 'image/png'
                })]
                })) {
                    window.navigator.share({
                        files: [new File([convertBase64ToFile(document.querySelector('#qrLeadImg').src)], "invoice.png", {
                            type: "image/png"
                        })],
                    }).then(() => console.log('Share was successful.'))
                        .catch((error) => console.log(error, error));
                } else {

                }
            } catch (error) {
                alert('Erro: ' + error);
                logError('Error sharing: ' + error);
            }
        }


        async function testWebShareDelay() {
            await sleep(6000);
            testWebShare();
        }

        function onLoad() {
            document.querySelector('#share').addEventListener('click', testWebShare);
            document.querySelector('#share-no-gesture').addEventListener('click',
                testWebShareDelay);

            if (navigator.share === undefined) {
                if (window.location.protocol === 'http:') {
                    // navigator.share() is only available in secure contexts.
                    window.location.replace(window.location.href.replace(/^http:/, 'https:'));
                } else {
                    logError('Error: You need to use a browser that supports this draft ' +
                        'proposal.');
                }
            }
        }




        window.addEventListener('load', onLoad);

        function dataURLtoFile(dataurl, filename) {
            var arr = dataurl.split(','),
                mime = arr[0].match(/:(.*?);/)[1],
                bstr = atob(arr[1]),
                n = bstr.length,
                u8arr = new Uint8Array(n);
            while (n--) {
                u8arr[n] = bstr.charCodeAt(n);
            }
            return new File([u8arr], filename, {
                type: mime
            });
        }

        //Usage example:
        var file = dataURLtoFile('data:text/plain;base64,aGVsbG8gd29ybGQ=', 'hello.txt');

    </script>
</body>

</html>
