<%@ Page Language="C#" AutoEventWireup="true" CodeFile="prospeccaoBKP16-07-21.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">

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
    <script type="text/javascript" src="./assets/scripts/index.js"></script>
    <script type="text/javascript" src="./assets/jspdf.min.js"></script>
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
                    $('#labelCliente').html('<i class="badge badge-info text-justify container text-center">'+response.d.Cliente+'</i>');
                    $('#qr').html('<img class="img-fluid" src="' + response.d.QrCode + '" />');
                    $('#modalVendedor').html('<br/><br/> <b>' + response.d.Vendedor + '</b>');
                    $('#modalLoja').html('Loja / Equipe: <b>' + response.d.Loja / Equipe + '</b>');
                    $('#modalEquipe').html('Equipe: <b>' + response.d.Equipe + '</b>');
                    $('#modalEvento').html('<b>' + response.d.Evento + '</b>');
                    $('#modalData').html('<b>' + response.d.Data + '</b>');

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
    <script src="https://rawgit.com/dabeng/OrgChart/master/demo/js/jspdf.min.js"></script>
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
                                                <img width="42" class="rounded-circle" src="assets/images/avatars/1.jpg" alt="" />
                                                <i class="">
                                                    <asp:Literal ID="usuarioLogado" runat="server"></asp:Literal>
                                                    <asp:LinkButton runat="server" ID="sair" CssClass="btn btn-danger mt-1" OnClick="btnSair_Click" Text="sair"></asp:LinkButton>
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
                                    <a href="dashboard_equipes.aspx" >
                                        <i class="metismenu-icon pe-7s-bookmarks "></i>
                                        Dashboard Equipes
                                    </a>
                                </li>
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

                                    <a href="./criar_fluxo.aspx">
                                        <i class="metismenu-icon fas fa-user-plus"></i>
                                        Criar Fluxo Sem QrCode
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

                                    <a href="./criar_avaliacao.aspx">
                                        <i class="metismenu-icon fas fa-dollar-sign"></i>
                                        Criar Avaliação
                                    </a>
                                </li>
                                <li>

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
                    <div class="app-main__inner">
                        <ul class="body-tabs body-tabs-layout tabs-animated body-tabs-animated nav mb-3">
                            <li class="nav-item">
                                <a role="tab" class="nav-link show active" id="A5" data-toggle="tab" href="#tab-content-4">
                                    <span>Gerar Prospecção</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a role="tab" class="nav-link" id="A1" data-toggle="tab" href="#tab-content-0" aria-selected="true">
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

                        </ul>
                        <div class="tab-content">
                            <div class="tab-pane tabs-animation fade" id="tab-content-0" role="tabpanel">
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
                                                    <span aria-hidden="true"><i class="fas fa-times-circle"></i></span>
                                                </button>
                                            </div>
                                            <div id="Div2" style="letter-spacing: 1px;" class="modal-body">
                                                <asp:UpdatePanel ID="upDescarte" runat="server">
                                                    <ContentTemplate>
                                                        <div class="mb-3">
                                                            <label for="ddlVendedorDescarte" class="">Prospector:</label>

                                                            <input type="text" class="form-control" id="ddlVendedorDescarte" runat="server" name="prospector" required="required" disabled="disabled" />
                                                        </div>
                                                        <div class=" mb-3">
                                                            <label for="ddlLoja" class="">Loja / Equipe:</label>
                                                            <select id="ddlLojaDescarte" runat="server" name="ddlLojaDescarte" class="form-control" required="required">
                                                                <option disabled="disabled" selected="selected"></option>
                                                                <option>SIA</option>
                                                                <option>SAAN</option>
                                                                <option>SCIA</option>
                                                            </select>
                                                        </div>
                                                        <div class=" mb-3">
                                                            <label for="ddlEquipeConviteDescarte" class="">Equipe:</label>
                                                            <select id="ddlEquipeConviteDescarte" runat="server" name="ddlEquipeConviteDescarte" class="form-control" required="required">
                                                                <option>SEM EQUIPE</option>
                                                            </select>
                                                        </div>
                                                        <div class=" mb-3">
                                                            <label for="ddlEventoDescarte" class="">Evento:</label>
                                                            <select id="ddlEventoDescarte" runat="server" name="ddlEventoDescarte" class="form-control" required="required" datasourceid="SqlDataSource2" datatextfield="nome" datavaluefield="nome">
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
                                                                            <input type="text" id="txtCliente" class="form-control" runat="server" placeholder="Nome do Cliente..." required="required" />
                                                                            <div class="valid-feedback">
                                                                                Ok!
                                                                            </div>
                                                                        </div>
                                                                        <div class="col-md-2 mb-3">
                                                                            <label for="ddlClassificacao" class="">Classificação:</label>
                                                                            <select id="ddlClassificacao" runat="server" name="ddlClassificacao" class="form-control" required="required">
                                                                                <option disabled="disabled" selected="selected"></option>
                                                                                <option>Quente</option>
                                                                                <option>Frio</option>
                                                                            </select>
                                                                        </div>
                                                                        <div class="col-md-4 mb-3">
                                                                            <label for="ddlVendedor" class="">Prospector:</label>

                                                                            <input type="text" class="form-control" id="ddlVendedor" runat="server" name="prospector" required="required" disabled="disabled" />
                                                                        </div>

                                                                        <div class="col-md-4 mb-3">
                                                                            <label for="txtTelefone">Telefone:</label>
                                                                            <input type="text" class="form-control" id="txtTelefone" runat="server" name="phone" required="required" />
                                                                            <div class="valid-feedback">
                                                                                Ok!
                                                                            </div>
                                                                        </div>
                                                                        <div class="col-md-4 mb-3">
                                                                            <label for="ddlEvento" class="">Evento:</label>
                                                                            <select id="ddlEvento" runat="server" name="ddlEvento" class="form-control" required="required" datasourceid="SqlDataSource2" datatextfield="nome" datavaluefield="nome">
                                                                            </select>
                                                                        </div>
                                                                        <div class="col-md-4 mb-3">
                                                                            <label for="ddlLoja" class="">Loja / Equipe:</label>
                                                                            <select id="ddlLoja" runat="server" name="ddlEvento" class="form-control" required="required">
                                                                                <option disabled="disabled" selected="selected"></option>
                                                                                <option>SAAN</option>
                                                                                <option>SIA</option>
                                                                                <option>SCIA</option>
                                                                            </select>
                                                                        </div>
                                                                    </div>
                                                                    <div class="form-row">
                                                                        <div class="col-md-6 mb-3">
                                                                            <label for="txtEmail">Email</label>
                                                                            <input type="email" class="form-control" id="txtEmail" runat="server" placeholder="exemplo@exemplo.com.br" />
                                                                        </div>
                                                                        <div class="col-md-4 mb-3">
                                                                            <label for="ddlequipe" class="">Equipe:</label>
                                                                            <select id="ddlequipe" runat="server" name="ddlequipe" class="form-control" required="required">
                                                                                <option>SEM EQUIPE</option>
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
                                                        <strong>Ranking Confirmados</strong>
                                                        <div class="page-title-subheading">
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="page-title-actions">
                                                    <div class="container">
                                                        <div class="row">
                                                            <div class="col-lg-10">
                                                                <div class="row">
                                                                    <div class="col-lg-6">
                                                                        Dt Inicial:
                                                                    <asp:TextBox ID="txtDtInicialRanking" CssClass="txts col-lg-8 form-control" runat="server">

                                                                    </asp:TextBox>
                                                                        <asp:CalendarExtender ID="CalendarExtender3" runat="server" Animated="true" PopupPosition="TopLeft" Enabled="True" TargetControlID="txtDtInicialRanking">
                                                                        </asp:CalendarExtender>
                                                                    </div>
                                                                    <div class="col-lg-6">
                                                                        Dt Final:
                                                                    <asp:TextBox ID="txtDtFinalRanking" CssClass="txts col-lg-8 form-control" runat="server">

                                                                    </asp:TextBox>
                                                                        <asp:CalendarExtender ID="CalendarExtender4" runat="server" Animated="true" PopupPosition="TopLeft" Enabled="True" TargetControlID="txtDtFinalRanking">
                                                                        </asp:CalendarExtender>
                                                                    </div>
                                                                    <div class="col-lg-6">
                                                                        Evento:
                                                                        <select id="ddlEventoRanking" class="form-control" runat="server" datasourceid="SqlDataSource2" datatextfield="nome" datavaluefield="nome">
                                                                        </select>
                                                                    </div>
                                                                    <!--<div class="col-lg-6">
                                                                        Loja / Equipe:
                                                                        <select id="ddlLojaRanking" class="form-control" runat="server">
                                                                            <option>SAAN</option>
                                                                            <option>SCIA</option>
                                                                            <option>SIA</option>
                                                                        </select>
                                                                    </div>-->
                                                                </div>
                                                            </div>
                                                            <asp:LinkButton ID="showData" class="btn mt-2 btn-lg fa-2x btn-primary pe-7s-search col-lg-2" OnClick="btnShowData" runat="server"></asp:LinkButton>
                                                        </div>
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
                                                            <asp:SqlDataSource ID="SqlDataSource6" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="SELECT loja,equipe,count(*) as qtde FROM [APP].[dbo].[veiculos_prospeccao]  where nome_evento = 'Lapis Vermelho' group by loja,equipe  order by loja desc"></asp:SqlDataSource>
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
                                                <div class="badge badge-light container">
                                                    <div class="text-center">
                                                        <b>
                                                            <div id="labelCliente" class="h6 text-center">
                                                            </div>
                                                        </b>
                                                    </div>
                                                    <br />
                                                    <div class="text-center">
                                                        <label>Com esse QRCODE você é o nosso convidado especial para as Ofertas Bali!</label>
                                                    </div>
                                                    <div class="text-center">
                                                        <label class="badge badge-secondary font-size-lg">
                                                            <div id="modalEvento"></div>
                                                        </label>
                                                    </div>
                                                    <div class="text-center">
                                                        <label class="badge badge-secondary font-size-lg">
                                                        </label>
                                                    </div>
                                                            <div id="modalData"></div>
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
                                                <button type="button" onclick="DownloadAsImageQr()" class="btn btn-success"><i class="fas fa-file-download fa-2x"></i></button>


                                                <script>

                                                    function downloadURI(uri, name) {
                                                        var link = document.createElement("a");

                                                        link.download = name;
                                                        link.href = uri;
                                                        document.body.appendChild(link);
                                                        link.click();
                                                    }
                                                    function DownloadAsImageQr() {
                                                        var element = $("#conviteQrCode")[0];
                                                        html2canvas(element).then(function (canvas) {
                                                            var myImage = canvas.toDataURL();
                                                            downloadURI(myImage, document.querySelector('#labelCliente').textContent);
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
                                <asp:UpdatePanel ID="upFluxo" runat="server">
                                    <ContentTemplate>
                                        <!----------------------------------------------------------------------------->
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
                                                <div class="page-title-actions">
                                                    <div class="container">
                                                        <div class="row">
                                                            <div class="col-lg-9">
                                                                <div class="row">
                                                                    <div class="col-lg-6">
                                                                        Dt Inicial:
                                                                    <asp:TextBox ID="txtDtInicial" CssClass="txts col-lg-8 form-control" runat="server">

                                                                    </asp:TextBox>
                                                                    <asp:CalendarExtender ID="CalendarExtender1" runat="server" Animated="true" PopupPosition="TopLeft"  Enabled="True" TargetControlID="txtDtInicial">
                                                                    </asp:CalendarExtender>
                                                                    </div>
                                                                    <div class="col-lg-6">
                                                                        Dt Final:
                                                                    <asp:TextBox ID="txtDtFinal" CssClass="txts col-lg-8 form-control" runat="server">

                                                                    </asp:TextBox>
                                                                        <asp:CalendarExtender ID="CalendarExtender2" runat="server" Enabled="True" TargetControlID="txtDtFinal" PopupPosition="TopLeft">
                                                                        </asp:CalendarExtender>
                                                                    </div>
                                                                    <div class="col-lg-6">
                                                                        Evento:
                                                                    <select id="ddlEvento2" runat="server" name="ddlEvento2" class="form-control col-lg-8" required="required" datasourceid="SqlDataSource2" datatextfield="nome" datavaluefield="nome">
                                                                    </select>

                                                                    </div>
                                                                    <div class="col-lg-6">
                                                                        Loja / Equipe:
                                                                        <select id="ddlLojadashboard" runat="server" name="ddlLojadashboard col-lg-8" class="form-control" required="required">
                                                                            <option>SIA</option>
                                                                            <option>SAAN</option>
                                                                            <option>SCIA</option>
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-lg-3">
                                                                <asp:LinkButton CssClass="btn btn-lg btn-primary mt-5 ml-xl-0 ml-md-1 col-lg-8" ID="btnProcessar" runat="server" OnClick="btnProcessar_Click"><i class="fas fa-sync fa-2x"></i></asp:LinkButton>

                                                            </div>
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
                                                            <li class="nav-item"></li>
                                                        </ul>
                                                    </div>
                                                    <div class="container-fluid mb-3 ">

                                                        <button class="mb-2 mr-2 col-7 btn btn-dark  font-size-lg">
                                                            Total Realizado:</button>
                                                        <button class="mb-2 mr-2 col-4 btn btn-dark text-right font-size-lg">
                                                            <asp:Label ID="lblQtdeLigacoes" runat="server" Text="0"></asp:Label>
                                                        </button>
                                                        <br />
                                                        <button class="mb-2 mr-2 col-7 btn btn-primary  font-size-lg">
                                                            Ligações Confirmadas(Quente+Frio+Sem Int):</button>
                                                        <button class="mb-2 mr-2 col-4 btn btn-dark text-right font-size-lg">
                                                            <asp:Label ID="lblqtde" runat="server" Text="0"></asp:Label>
                                                            <asp:Label ID="lblPercConfirmado" CssClass="ml-2 badge badge-light col-md-4" runat="server" Text="0%" data-toggle="tooltip" data-placement="top" title="(Confirmados * 100)/Total Realizados"></asp:Label>
                                                        </button>
                                                        <br />
                                                        <button class="mb-2 mr-2 col-7  btn btn-danger font-size-lg">Quentes:</button>
                                                        <button class="mb-2 mr-2 col-4 btn btn-dark text-right  font-size-lg">
                                                            <asp:Label ID="lblquentes" runat="server" Text="0"></asp:Label>
                                                            <asp:Label ID="lblPercQuentes" CssClass="ml-2 badge badge-light col-md-4" runat="server" Text="0%" data-toggle="tooltip" data-placement="top" title="(Quentes * 100)/Total Realizados"></asp:Label>
                                                        </button>
                                                        <br />
                                                        <button class="mb-2 mr-2 col-7  btn btn-success font-size-lg">Frios:</button>
                                                        <button class="mb-2 mr-2 col-4 btn btn-dark text-right font-size-lg">
                                                            <asp:Label ID="lblfrios" runat="server" Text="0"></asp:Label>
                                                            <asp:Label ID="lblPercFrios" CssClass="ml-2 badge badge-light col-md-4" runat="server" Text="0%" data-toggle="tooltip" data-placement="top" title="(Frios * 100)/Total Realizados"></asp:Label>
                                                        </button>
                                                        <br />
                                                        <button class="mb-2 mr-2 col-7 btn btn-primary  font-size-lg">
                                                            Descarte:</button>
                                                        <button class="mb-2 mr-2 col-4 btn btn-dark text-right  font-size-lg">
                                                            <asp:Label ID="lblDescarte" runat="server" Text="0"></asp:Label>
                                                            <asp:Label ID="lblPercDescarte" CssClass="ml-2 badge badge-light col-md-4" runat="server" Text="0%" data-toggle="tooltip" data-placement="top" title="(Descartes * 100)/Total Realizados"></asp:Label>
                                                        </button>
                                                        <br />
                                                        <button class="mb-2 mr-2 col-7  btn btn-warning font-size-lg">Projeção de Fluxo:</button>
                                                        <button class="mb-2 mr-2 col-4 btn btn-dark text-right  font-size-lg">
                                                            <asp:Label ID="lblFluxo" runat="server" Text="00"></asp:Label>
                                                        </button>
                                                        <br />
                                                        <button class="mb-2 mr-2 col-7  btn btn-secondary font-size-lg">Projeção de Venda de Veículo:</button>
                                                        <button class="mb-2 mr-2 col-4 btn btn-dark text-right  font-size-lg">
                                                            <asp:Label ID="lblvendacarro" runat="server" Text="0"></asp:Label>
                                                        </button>

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
                                                        <button class="mb-2 mr-2 btn btn-success font-size-lg mb-2">SAAN<span class="badge badge-light font-size-lg">190</span></button>
                                                        <button class="mb-2 mr-2 btn btn-primary font-size-lg mb-2">SIA<span class="badge badge-light font-size-lg">190</span></button>
                                                        <button class="mb-2 mr-2 btn btn-danger font-size-lg mb-2">SCIA<span class="badge badge-light font-size-lg">190</span></button>
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
                                                            Prospecção por Prospector
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
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="btnProcessar" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>
                                <!----------------------------------------------------------------------------->
                            </div>
                            <div class="tab-pane tabs-animation fade show active" id="tab-content-4" role="tabpanel">
                                <div class="app-page-title mt-3">
                                    <div class="page-title-wrapper">
                                        <div class="page-title-heading">
                                            <div class="page-title-icon">
                                                <i class="fas fa-chart-bar icon-gradient bg-danger"></i>
                                            </div>
                                            <div>
                                                <strong>Prospecção</strong>
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
                                                    <b>Prospectar</b>
                                                </div>
                                                <ul class="nav">
                                                    <li class="nav-item">
                                                        <select class="custom-select text-uppercase ml-2" runat="server" name="ddlVendedor"
                                                            id="ddlEventoGeraLead" datasourceid="SqlDataSource2"
                                                            datatextfield="nome" datavaluefield="nome">
                                                        </select>
                                                    </li>
                                                    <li class="nav-item text-right">
                                                        <asp:LinkButton ID="btnAtualizaLeadTop" class="btn btn-lg btn-primary fas fa-sync-alt mr-1" OnClick="btnAtualizaLead_Click" runat="server"></asp:LinkButton>
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
                                                                <div class="text-center">
                                                                    <b>
                                                                        <div id="labelClienteLead" class="h6 text-center">
                                                                        </div>
                                                                    </b>
                                                                </div>
                                                                <div class="text-center">
                                                                    <label>Com esse QRCODE você é o nosso convidado especial para as Ofertas Bali!</label>
                                                                </div>
                                                                <div class="text-center">
                                                                    <label class="badge badge-secondary font-size-lg">LÁPIS VERMELHO</label>
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
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-danger" data-dismiss="modal"><i class="fas fa-times"></i></button>
                                                            <button id="Button2" type="button" class="btn btn-primary"><i class="fas fa-print fa-2x"></i></button>
                                                            <button type="button" onclick="DownloadAsImage()" class="btn btn-success"><i class="fas fa-file-download fa-2x"></i></button>



                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                                                <ContentTemplate>
                                                    <div id="campoLead" class="container mr-n3" runat="server">
                                                        <div class="container-fluid mb-3 ">


                                                            <ul class="list-group">
                                                                <label id="campoNomeLead" runat="server" class="row active list-group-item-action list-group-item text-uppercase mb-1">
                                                                    <i class="far fa-user mr-1 fa-2x"></i>
                                                                    <b class="mb-3">
                                                                        <asp:Label runat="server" ID="txtIdLead"></asp:Label>
                                                                        <asp:Label runat="server" ID="txtNomeLead"></asp:Label>
                                                                    </b>
                                                                </label>
                                                                <label id="contador" runat="server" class="row list-group-item-action list-group-item text-uppercase mb-1">
                                                                    <b class="mb-3">
                                                                        <asp:Label runat="server" ID="labelContadorLigacaoLead"></asp:Label>
                                                                    </b>
                                                                </label>
                                                                <div id="campoTelefoneLead1" runat="server" class="row">
                                                                    <div class="col-12 row mb-1">
                                                                        <label class="list-group-item col-8">
                                                                            <i class="fas fa-phone mr-1 fa-2x">1</i>
                                                                            <b class="mb-3 h6">
                                                                                <asp:Label runat="server" ID="txtTelLead"></asp:Label></b>
                                                                        </label>
                                                                        <div class="col-2 text-center p-0 m-0 btn-secondary">
                                                                            <a id="linkTel" runat="server">
                                                                                <label class="border-0">
                                                                                    <i class="fas fa-phone-alt fa-2x text-light m-3"></i>
                                                                                </label>
                                                                            </a>
                                                                        </div>

                                                                        <asp:LinkButton ID="btnWhats" runat="server" CssClass="btn-success col-2 text-center p-0 m-0" OnClick="btnWhats_Click">
                                                                            <i class="fab fa-whatsapp fa-2x text-light m-3"></i>
                                                                        </asp:LinkButton>

                                                                    </div>
                                                                </div>
                                                                <div id="campoTelefoneLead2" runat="server" class="row">
                                                                    <div class="col-12 row mb-1">
                                                                        <label class="list-group-item col-8">
                                                                            <i class="fas fa-phone mr-1 fa-2x">2</i>
                                                                            <b class="mb-3 h6">
                                                                                <asp:Label runat="server" ID="txtTelLead2"></asp:Label></b>
                                                                        </label>
                                                                        <div class="col-2 text-center p-0 m-0 btn-secondary">
                                                                            <a id="linkTel2" runat="server">
                                                                                <label class="border-0">
                                                                                    <i class="fas fa-phone-alt fa-2x text-light m-3"></i>
                                                                                </label>
                                                                            </a>
                                                                        </div>

                                                                        <asp:LinkButton ID="btnWhats2" runat="server" CssClass="btn-success col-2 text-center p-0 m-0" OnClick="btnWhats_Click2">
                                                                            <i class="fab fa-whatsapp fa-2x text-light m-3"></i>
                                                                        </asp:LinkButton>

                                                                    </div>
                                                                </div>
                                                                <div id="campoTelefoneLead3" runat="server" class="row">
                                                                    <div class="col-12 row mb-1">
                                                                        <label class="list-group-item col-8">
                                                                            <i class="fas fa-phone mr-1 fa-2x">3</i>
                                                                            <b class="mb-3 h6">
                                                                                <asp:Label runat="server" ID="txtTelLead3"></asp:Label></b>
                                                                        </label>
                                                                        <div class="col-2 text-center p-0 m-0 btn-secondary">
                                                                            <a id="linkTel3" runat="server">
                                                                                <label class="border-0">
                                                                                    <i class="fas fa-phone-alt fa-2x text-light m-3"></i>
                                                                                </label>
                                                                            </a>
                                                                        </div>

                                                                        <asp:LinkButton ID="btnWhats3" runat="server" CssClass="btn-success col-2 text-center p-0 m-0" OnClick="btnWhats_Click3">
                                                                            <i class="fab fa-whatsapp fa-2x text-light m-3"></i>
                                                                        </asp:LinkButton>

                                                                    </div>
                                                                </div>
                                                                <label class="list-group-item-action list-group-item text-uppercase row mb-1">
                                                                    <a id="linkEmailLead" runat="server">
                                                                        <i class="far fa-envelope mr-1 fa-2x"></i>
                                                                        <b class="mb-3">
                                                                            <asp:Label CssClass="mb-3" runat="server" ID="txtEmailLead"></asp:Label>
                                                                        </b>
                                                                    </a>
                                                                </label>
                                                                <label class="list-group-item-action list-group-item text-uppercase row">
                                                                    <i class="fas fa-car mr-1 fa-2x"></i>
                                                                    <b class="mb-3">
                                                                        <asp:Label runat="server" ID="txtCarroLead"></asp:Label>

                                                                    </b>
                                                                </label>

                                                                <div class="input-group row">
                                                                    <div class="input-group-prepend">
                                                                        <label class="input-group-text" for="ddlClassificacaoLead">Classificação:</label>
                                                                    </div>
                                                                    <select class="custom-select text-uppercase" runat="server" id="ddlClassificacaoLead">
                                                                        <option value="QUENTE"></option>
                                                                        <option value="FRIO"></option>
                                                                        <option value="CLIENTE NÃO TEM INTERESSE"></option>
                                                                        <option value="TELEFONE INEXISTENTE"></option>
                                                                        <option value="TELEFONE DE OUTRO DDD"></option>
                                                                        <option value="NÃO É O CLIENTE"></option>
                                                                        <option value="CLIENTE FALECIDO"></option>

                                                                    </select>
                                                                </div>
                                                                <div id="divEquipeLead" runat="server" class="input-group row">
                                                                    <div class="input-group-prepend">
                                                                        <label class="input-group-text" for="ddlEquipeLead">Equipe:</label>
                                                                    </div>
                                                                    <select class="custom-select text-uppercase" runat="server" id="ddlEquipeLead" required="required">

                                                                        <option value="SEM EQUIPE"></option>

                                                                    </select>
                                                                </div>
                                                            </ul>

                                                        </div>

                                                        <div class="card-footer">
                                                            <div class="col-12 text-center ml-n3">
                                                                <asp:LinkButton ID="btnSalvarLead" runat="server" OnClick="btnSalvarLead_Click" CssClass="btn btn-lg btn-success  mr-2 " data-toggle="tooltip" data-placement="top" title="Confirmado"><i class="fas fa-thumbs-up fa-2x"></i></asp:LinkButton>
                                                                <asp:LinkButton ID="btnDescartarLead" runat="server" OnClick="btnDescartaLead_Click" CssClass="btn btn-lg btn-warning mr-2" data-toggle="tooltip" data-placement="top" title="À confirmar"><i class="fas fa-retweet fa-2x"></i></asp:LinkButton>
                                                                <asp:LinkButton ID="btnDescartarLeadLixo" runat="server" OnClick="btnDescartaLeadLixo_Click" CssClass="btn btn-lg btn-danger mr-2" data-toggle="tooltip" data-placement="top" title="Descartar"><i class="fas fa-trash-alt fa-2x"></i></asp:LinkButton>
                                                            </div>
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
                                                                <i class='fas fa-comment-slash'></i>Não há Leads disponíveis!
                                                            <asp:LinkButton runat="server" ID="LinkButton2" OnClick="btnAtualizaLead_Click"><i class="fas fa-sync-alt"></i></asp:LinkButton>
                                                            </div>
                                                        </div>
                                                        <asp:Literal ID="erroMessage" runat="server"></asp:Literal>
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
                                                                        <div class="text-center">
                                                                            <b>
                                                                                <label id="txtClienteQrLead" runat="server" class="badge badge-info">
                                                                                </label>
                                                                            </b>
                                                                        </div>
                                                                        <div class="text-center">
                                                                            <label>Com esse QRCODE você é o nosso convidado especial para as Ofertas Bali!</label>
                                                                        </div>
                                                                        <div class="text-center">
                                                                            <label id="txtEventoQrLead" runat="server" class="badge badge-secondary font-size-lg"></label>
                                                                        </div>
                                                                        <div class="text-center">
                                                                            <label id="txtDataQrLead" runat="server" class="badge badge-secondary font-size-lg"></label>
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
                                                                        <br />
                                                                        <img src="../img/logobali.png" />
                                                                    </div>
                                                                </div>

                                                                <div class="modal-footer">
                                                                    <button type="button" class="btn btn-danger" data-dismiss="modal"><i class="fas fa-times"></i></button>
                                                                    <button id="printConviteLead" type="button" class="btn btn-primary" visible="false"><i class="fas fa-print fa-2x"></i></button>
                                                                    <button type="button" onclick="DownloadAsImage()" class="btn btn-success"><i class="fas fa-file-download fa-2x"></i></button>
                                                                    <script src="https://rawgit.com/dabeng/OrgChart/master/demo/js/jspdf.min.js"></script>
                                                                    <script>
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

                                                                        async function testWebShare(file) {
                                                                            if (navigator.share === undefined) {
                                                                                logError('Error: Unsupported feature: navigator.share()');
                                                                                return;
                                                                            }

          

                                                                            if (file && file.length > 0) {
                                                                                if (!navigator.canShare || !navigator.canShare({file})) {
                                                                                    logError('Error: Unsupported feature: navigator.canShare()');
                                                                                    return;
                                                                                }
                                                                            }

                                                                            try {
                                                                                await navigator.share({file, 'title', 'text', 'url'});
                                                                                logText('Successfully sent share');
                                                                            } catch (error) {
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
                                                                    </script>
                                                                    <script>
                                                                        function changeLabel(cod) {
                                                                            lbl = document.getElementById('cod');
                                                                            // Assign HTML codes along with text values using innerHTML.
                                                                            lbl.innerHTML = cod;
                                                                        }
                                                                    </script>
                                                                    <script>

                                                                        document.getElementById('printConviteLead').onclick = function () {
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
                                                                        }
                                                                        function DownloadAsImage(nomeArquivo) {
                                                                            var element = $("#conviteQrCodeLead")[0];
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
                                                    <asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="UpdatePanel2"
                                                        DisplayAfter="50">
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
                <script src="http://maps.google.com/maps/api/js?sensor=true"></script>
            </div>
        </div>
        <script type="text/javascript" src="./assets/scripts/main.js"></script>




    </form>

    <script src="./assets/popper.min.js"></script>
    <script src="./assets/bootstrap.min.js"></script>
</body>

</html>
