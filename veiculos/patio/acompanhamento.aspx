<%@ Page Language="C#" AutoEventWireup="true" CodeFile="acompanhamento.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <title>ACOMPANHAMENTO | Pátio</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <!-- STYLE MARCIO       ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
    <script src="../assets/jquery-1.9.1.min.js"></script>
    <script src="./assets/jquery.dataTables.min.js"></script>
    <link href="./assets/dataTables.bootstrap4.min.css" rel="stylesheet" />
    <script src="./assets/dataTables.bootstrap4.min.js"></script>
    <script src="./assets/dataTables.responsive.min.js"></script>
    <link href="./main.css" rel="stylesheet" />
    <link href="../../css/bali-patio.css?v=20260624-1" rel="stylesheet" />
    <script src="../ChartJS.js"></script>
    <link href="../assets/all.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../assets/toastr.min.js"></script>
    <link href="./assets/css/bootstrap-datetimepicker.css" rel="stylesheet" />
    <link href="./assets/css/bootstrap-datetimepicker.min.css" rel="stylesheet" />

    <script>
        function ocultarCamposPesquisa() {
            var objeto = document.getElementById("ddlTipoPesquisa");
            var tipo = objeto.options[objeto.selectedIndex].text;
            if (tipo == 'Serie') {
                document.getElementById("divData").style.visibility = 'hidden';
                document.getElementById("divLoja").style.visibility = 'hidden';
                document.getElementById("divSerie").style.visibility = 'visible';
            }
            else if (tipo == 'Data')
            {
                document.getElementById("divSerie").style.visibility = 'hidden';
                document.getElementById("divData").style.visibility = 'visible';
                document.getElementById("divLoja").style.visibility = 'visible';
            }
            else
            {
                alert('Tipo de pesquisa inválido');
            }
        }
    </script>
</head>

<body class="patio-modern-page patio-brand-fiat">
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
                                                    <b><i class="fa fa-user mr-1"></i>
                                                        <asp:Literal ID="usuarioLogado" runat="server"></asp:Literal></b>
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
                                    <a href="./registrar_agendamento.aspx">
                                        <i class="metismenu-icon fa fa-calendar-plus"></i>
                                        Registrar Agendamento
                                    </a>
                                </li>
                                <li>
                                    <a href="./consultar_agendamento.aspx">
                                        <i class="metismenu-icon fa fa-calendar-alt"></i>
                                        Consultar Agendamento
                                    </a>
                                </li>
                                <li>
                                    <a href="./acompanhamento.aspx" class="mm-active">
                                        <i class="metismenu-icon fa fa-tasks"></i>
                                        Acompanhamento
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="app-main__outer">
                    <asp:UpdatePanel ID="updatePanel" runat="server">
                        <ContentTemplate>
                            <div class="app-main__inner mb-3">
                                <div class="app-page-title text-white" style="background-color: #495057;">
                                    <div class="page-title-wrapper">
                                        <div class="page-title-heading">
                                            <div class="page-title-icon" style="background-color: #495057;">
                                                <i class="fas fa-tasks text-white"></i>
                                            </div>
                                            <div>
                                                <b>Acompanhamento</b>

                                                <div class="page-title-subheading">
                                                </div>
                                            </div>
                                        </div>
                                        <div class="page-title-actions">
                                            <div class="row">
                                                <!-- Button trigger modal -->
                                                <button type="button" class="btn btn-lg btn-dark  form-control col-5 offset-1" data-toggle="modal" data-target="#exampleModalCenter" onclick="ocultarCamposPesquisa()">
                                                    <i class="fas fa-filter"></i>
                                                </button>

                                                <!-- Modal -->
                                                <div class="modal fade mt-5 p-3" id="exampleModalCenter" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
                                                    <div class="modal-dialog" role="document">
                                                        <div class="modal-content">
                                                            <div class="modal-header">
                                                                <h5 class="modal-title text-dark" id="exampleModalLongTitle">Filtros <i class="fas fa-filter"></i></h5>
                                                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                    <span aria-hidden="true">&times;</span>
                                                                </button>
                                                            </div>
                                                            <div class="modal-body">
                                                                <div class="form-row">
                                                                    <div class="input-group  mb-3">
                                                                        <div class="input-group-prepend">
                                                                            <span class="input-group-text" id="Span1"><b>Pesquisar por:</b></span>
                                                                        </div>
                                                                        <select id="ddlTipoPesquisa" runat="server" class="form-control" required="required" onchange="ocultarCamposPesquisa()">
                                                                            <option value="Data"></option>
                                                                            <option value="Serie"></option>
                                                                        </select>
                                                                    </div>
                                                                    <div id="divSerie" runat="server" class="input-group  mb-3">
                                                                        <div class="input-group-prepend">
                                                                            <span class="input-group-text" id="basic-addon1"><b>Série</b></span>
                                                                        </div>
                                                                        <asp:TextBox ID="txtSerie" CssClass="form-control" runat="server" required="true" OnTextChanged="btnProcessar_Click" AutoPostBack="true"></asp:TextBox>
                                                                    </div>
                                                                    <div id="divData" runat="server" class="input-group  mb-3">
                                                                        <div class="input-group-prepend">
                                                                            <span class="input-group-text" id="Span6"><b>DT Agendamento</b></span>
                                                                        </div>

                                                                        <asp:TextBox ID="dtAgendamento" CssClass="form-control bg-white" runat="server" ReadOnly="true"></asp:TextBox>


                                                                    </div>
                                                                    <div id="divLoja" runat="server" class="input-group  mb-3">
                                                                        <div class="input-group-prepend">
                                                                            <span class="input-group-text" id="Span5"><b>Loja</b></span>
                                                                        </div>
                                                                        <select id="ddlLoja" runat="server" class="form-control" required="required" datasourceid="SqlDataSource2" datatextfield="ds" datavaluefield="id">
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer">
                                                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <asp:LinkButton CssClass="btn btn-lg btn-primary  form-control col-5 ml-2" runat="server" ID="btnAtualizaDash" OnClick="btnProcessar_Click">
                                                    <i class="fas fa-sync-alt"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-12 mb-2">
                                        <div class="mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header">
                                                <div class="card-header-title">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    RESULTADO                                     
                                                </div>
                                            </div>
                                            <div class="card-body">
                                                <div class="form-row">
                                                    <div class="container-fluid mb-3">
                                                        <div class="row" id="divVeiculoAgendado" runat="server">
                                                            <div id="divAgendamento" runat="server" class="card text-center col-lg-3 border border-alternate">
                                                                <div class="card-header">
                                                                    Agendamento
                                                                </div>
                                                                <div class="card-body">
                                                                    <p class="card-text">
                                                                        Veículo está agendado para 
                                                                        <h5 class="card-title">
                                                                            <asp:Literal ID="literalDataAgendamento" runat="server"></asp:Literal></h5>
                                                                        para o 
                                                                        <h5 class="card-title">
                                                                            <asp:Literal ID="literalLojaAgendamento" runat="server"></asp:Literal></h5>
                                                                    </p>
                                                                </div>
                                                                <div class="card-footer text-muted">
                                                                    <div class="col-8">
                                                                        <div id="Div5" runat="server" class="badge badge-success">concluído</div>
                                                                    </div>
                                                                    <div class="col-4">
                                                                        <div class="btn btn-primary"><i class="fas fa-search"></i></div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div id="divLocalizacao" runat="server" class="card text-center col-lg-3 border border-alternate">
                                                                <div class="card-header">
                                                                    Localização
                                                                </div>
                                                                <div class="card-body">
                                                                    <p class="card-text">Veículo está localizado no:</p>
                                                                    <h5 class="card-title">
                                                                        <asp:Literal ID="literaLocalizacao" runat="server"></asp:Literal></h5>
                                                                </div>
                                                                <div class="card-footer text-muted">
                                                                    <div class="col-8">
                                                                        <div id="statusLocalizacaoConcluido" runat="server" class="badge badge-success">concluído</div>
                                                                        <div id="statusLocalizacaoPendante" runat="server" class="badge badge-warning">pendente</div>
                                                                    </div>
                                                                    <div class="col-4">
                                                                        <div class="btn btn-primary"><i class="fas fa-search"></i></div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div id="divRevisao" runat="server" class="card text-center col-lg-3 border border-alternate">
                                                                <div class="card-header">
                                                                    Revisão
                                                                </div>
                                                                <div class="card-body">
                                                                    <div id="divRevisaoIniciada" runat="server">
                                                                        <p class="card-text">
                                                                            <i class="fas fa-calendar"></i>Início:
                                                                            <asp:Literal ID="literalRevisaoInicio" runat="server"></asp:Literal>
                                                                        </p>
                                                                        <p class="card-text">
                                                                            <i class="fas fa-calendar"></i>Fim:
                                                                                <asp:Literal ID="literalRevisaoFim" runat="server"></asp:Literal>
                                                                        </p>
                                                                    </div>
                                                                    <div id="divRevisaoNãoIniciada" runat="server">
                                                                        <h5 class="card-title">Não iniciado</h5>
                                                                    </div>
                                                                </div>
                                                                <div class="card-footer text-muted">
                                                                    <div class="col-8">
                                                                        <div id="statusRevisaoConcluido" runat="server" class="badge badge-success">concluído</div>
                                                                        <div id="statusRevisaoEmAndamento" runat="server" class="badge badge-danger">em andamento</div>
                                                                        <div id="statusRevisaoPendente" runat="server" class="badge badge-warning">pendente</div>
                                                                    </div>
                                                                    <div class="col-4">
                                                                        <div class="btn btn-primary"><i class="fas fa-search"></i></div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div id="divRequisicaoAcessorio" runat="server" class="card text-center col-lg-3 border border-alternate">
                                                                <div class="card-header">
                                                                    Requisição de Acessório
                                                                </div>
                                                                <div class="card-body">
                                                                    <div id="divAcessorioRequisitado" runat="server">
                                                                        <p class="card-text">Acessórios requisitados:</p>
                                                                        <h5 class="card-title">
                                                                            <asp:Literal ID="literalAcessoriosRequisitados" runat="server"></asp:Literal></h5>
                                                                    </div>
                                                                    <div id="divAcessorioNaoRequisitado" runat="server">
                                                                        <h5 class="card-title">Sem requisições</h5>
                                                                    </div>
                                                                </div>
                                                                <div class="card-footer text-muted">
                                                                    <div class="col-8">
                                                                        <div id="statusRequisicaoAcessorioConcluido" runat="server" class="badge badge-success">concluído</div>
                                                                        <div id="statusRequisicaoAcessorioPendente" runat="server" class="badge badge-warning">pendente</div>
                                                                    </div>
                                                                    <div class="col-4">
                                                                        <div class="btn btn-primary"><i class="fas fa-search"></i></div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div id="divInstalAcessorios" runat="server" class="card text-center col-lg-3 border border-alternate">
                                                                <div class="card-header">
                                                                    Instalação de acessório
                                                                </div>

                                                                <div id="divInstalAcessorioIniciado" runat="server">
                                                                    <p class="card-text">

                                                                        <i class="fas fa-calendar"></i>Início:
                                                                                <asp:Literal ID="literalInicioInstalAcessorio" runat="server"></asp:Literal>
                                                                    </p>
                                                                    <p class="card-text">
                                                                        <i class="fas fa-calendar"></i>Fim:
                                                                                <asp:Literal ID="literalFimInstalAcessorio" runat="server"></asp:Literal>
                                                                    </p>
                                                                </div>
                                                                <div id="divInstalAcessorioNaoIniciado" runat="server">
                                                                    <h5 class="card-title">Não iniciado</h5>
                                                                </div>
                                                                <div class="card-footer text-muted">
                                                                    <div class="col-8">
                                                                        <div id="statusInstalAcessorioConcluido" runat="server" class="badge badge-success">concluído</div>
                                                                        <div id="statusInstalAcessorioEmAmdamento" runat="server" class="badge badge-danger">
                                                                            em andamento
                                                                        </div>
                                                                        <div id="statusInstalAcessorioPendente" runat="server" class="badge badge-warning">pendente</div>
                                                                    </div>
                                                                    <div class="col-4">
                                                                        <div class="btn btn-primary"><i class="fas fa-search"></i></div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div id="divServicoTerceiros" runat="server" class="card text-center col-lg-3 border border-alternate">
                                                                <div class="card-header">
                                                                    Serviços de Terceiros
                                                                </div>


                                                                <div id="divServicoTerceiroIniciado" runat="server">
                                                                    <p class="card-text">
                                                                        <i class="fas fa-calendar"></i>Início:
                                                                                <asp:Literal ID="literalServicoTerceiroInicio" runat="server"></asp:Literal>
                                                                    </p>
                                                                    <p class="card-text">
                                                                        <i class="fas fa-calendar"></i>Fim:
                                                                                <asp:Literal ID="literalServicoTerceiroFim" runat="server"></asp:Literal>
                                                                    </p>
                                                                </div>
                                                                <div id="divServicoTerceiroNaoIniciado" runat="server">
                                                                    <h5 class="card-title">Não iniciado</h5>
                                                                </div>
                                                                <div class="card-footer text-muted">
                                                                    <div class="col-8">
                                                                        <div id="Div4" runat="server" class="badge badge-success">concluído</div>
                                                                        <div id="Div6" runat="server" class="badge badge-danger">em andamento</div>
                                                                        <div id="Div7" runat="server" class="badge badge-warning">pendente    </div>
                                                                    </div>
                                                                    <div class="col-4">
                                                                        <div class="btn btn-primary"><i class="fas fa-search"></i></div>
                                                                    </div>

                                                                </div>
                                                            </div>
                                                            <div id="divEntregador" runat="server" class="card text-center col-lg-3 border border-alternate">
                                                                <div class="card-header">
                                                                    Entregador
                                                                </div>
                                                                <div class="card-body">
                                                                    <div id="divEntregadorAtribuido" runat="server">
                                                                        <p class="card-text"><i class="fas fa-user"></i>Entregador: </p>
                                                                        <h5 class="card-title">
                                                                            <asp:Literal ID="literalEntregadorAtribuido" runat="server"></asp:Literal></h5>
                                                                    </div>
                                                                    <div id="divEntregadorNaoAtribuido" runat="server">
                                                                        <h5 class="card-title">Não apontado</h5>
                                                                    </div>
                                                                </div>
                                                                <div class="card-footer text-muted">
                                                                    <div class="col-8">
                                                                        <div id="statusEntregadorConcluido" runat="server" class="badge badge-success">concluído</div>
                                                                        <div id="statusEntregadorPendente" runat="server" class="badge badge-warning">pendente</div>
                                                                    </div>
                                                                    <div class="col-4">
                                                                        <div class="btn btn-primary"><i class="fas fa-search"></i></div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="row" id="divVeiculoNaoAgendado" runat="server">
                                                            <div class="col-12 text-center h3"> SEM DADOS <i class="far fa fa-calendar-times"></i></div>
                                                        </div>
                                                    </div>

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
        $("#dtAgendamento").datetimepicker({ format: 'yyyy-mm-dd', autoclose: true, language: 'pt-BR', todayBtn: true, todayHighlight: true});
    </script>


</body>

</html>
