<%@ Page Language="C#" AutoEventWireup="true" CodeFile="relatorios.aspx.cs" Inherits="veiculos_patio_relatorios" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>RELAT&Oacute;RIOS | P&aacute;tio</title>
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
        .patio-bi-shell {
            display: grid;
            gap: 1rem;
        }

        .patio-bi-kpis {
            display: grid;
            grid-template-columns: repeat(6, minmax(140px, 1fr));
            gap: .85rem;
        }

        .patio-bi-kpi,
        .patio-bi-panel {
            border: 1px solid #dbe4ef;
            border-radius: 18px;
            background: rgba(255, 255, 255, .96);
            box-shadow: 0 14px 34px rgba(15, 23, 42, .08);
        }

        .patio-bi-kpi {
            padding: 1rem;
            min-height: 112px;
        }

        .patio-bi-kpi small {
            display: block;
            color: #64748b;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: .04em;
            font-size: .72rem;
        }

        .patio-bi-kpi strong {
            display: block;
            margin-top: .35rem;
            color: #0f172a;
            font-size: clamp(1.45rem, 3vw, 2rem);
            line-height: 1;
            word-break: break-word;
        }

        .patio-bi-kpi span {
            display: block;
            margin-top: .5rem;
            color: #667085;
            font-size: .78rem;
            font-weight: 800;
        }

        .patio-bi-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            gap: 1rem;
        }

        .patio-bi-panel-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            padding: 1rem 1rem .75rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .patio-bi-panel-header strong {
            color: #0f172a;
            font-size: 1rem;
            font-weight: 950;
        }

        .patio-bi-panel-header small {
            color: #64748b;
            font-weight: 800;
        }

        .patio-bi-panel-body {
            padding: 1rem;
        }

        .patio-bi-bar-list {
            display: grid;
            gap: .8rem;
        }

        .patio-bi-bar-row {
            display: grid;
            grid-template-columns: minmax(120px, .42fr) minmax(0, 1fr) 54px;
            gap: .75rem;
            align-items: center;
        }

        .patio-bi-bar-label {
            min-width: 0;
            color: #334155;
            font-weight: 900;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .patio-bi-bar-track {
            height: 13px;
            border-radius: 999px;
            background: #edf2f7;
            overflow: hidden;
        }

        .patio-bi-bar-track span {
            display: block;
            height: 100%;
            min-width: 3px;
            border-radius: inherit;
            background: linear-gradient(90deg, #6f9151, #203729);
        }

        .patio-bi-bar-value {
            color: #0f172a;
            font-weight: 950;
            text-align: right;
        }

        .patio-bi-table-wrap {
            overflow-x: auto;
        }

        .patio-bi-table {
            width: 100%;
            min-width: 720px;
            margin-bottom: 0;
        }

        .patio-bi-table th {
            color: #475569;
            font-size: .74rem;
            text-transform: uppercase;
            letter-spacing: .04em;
            white-space: nowrap;
        }

        .patio-bi-table td {
            color: #1f2937;
            font-weight: 700;
            vertical-align: middle;
        }

        .patio-bi-route {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            flex-wrap: wrap;
        }

        .patio-bi-pill {
            display: inline-flex;
            align-items: center;
            padding: .28rem .55rem;
            border-radius: 999px;
            background: #eef6e9;
            color: #203729;
            font-size: .76rem;
            font-weight: 950;
        }

        .patio-bi-empty {
            padding: 1rem;
            border: 1px dashed #cbd5e1;
            border-radius: 14px;
            background: #f8fafc;
            color: #64748b;
            font-weight: 800;
            text-align: center;
        }

        @media (max-width: 1200px) {
            .patio-bi-kpis {
                grid-template-columns: repeat(3, minmax(150px, 1fr));
            }
        }

        @media (max-width: 900px) {
            .patio-bi-grid,
            .patio-bi-kpis {
                grid-template-columns: 1fr;
            }

            .patio-bi-bar-row {
                grid-template-columns: 1fr;
                gap: .35rem;
            }

            .patio-bi-bar-value {
                text-align: left;
            }
        }
    </style>
</head>
<body class="patio-modern-page patio-brand-jeep">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <div class="app-container app-theme-white body-tabs-shadow fixed-sidebar fixed-header">
            <div class="app-header header-shadow bg-dark">
                <div class="app-header__logo">
                    <div class="logo-src"></div>
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
                                            <asp:LinkButton runat="server" ID="sair" CssClass="fa fa-arrow-alt-circle-right text-danger" OnClick="btnSair_Click"></asp:LinkButton>
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
                    <div class="scrollbar-sidebar bg-dark">
                        <div class="app-sidebar__inner">
                            <ul class="vertical-nav-menu">
                                <li><a href="./"><i class="metismenu-icon fas fa-home"></i>In&iacute;cio</a></li>
                                <li class="app-sidebar__heading">Fun&ccedil;&otilde;es</li>
                                <li><a href="./registrar.aspx"><i class="metismenu-icon fa fa-folder-plus"></i>Registrar</a></li>
                                <li><a href="./transferir.aspx"><i class="metismenu-icon fas fa-exchange-alt"></i>Transferir</a></li>
                                <li><a href="./historico.aspx"><i class="metismenu-icon fas fa-history"></i>Consultar</a></li>
                                <li><a href="./relatorios.aspx" class="mm-active"><i class="metismenu-icon fas fa-chart-line"></i>Relat&oacute;rios</a></li>
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
                                                <i class="fas fa-chart-line text-white"></i>
                                            </div>
                                            <div>
                                                <b>Relat&oacute;rios</b>
                                                <div class="page-title-subheading">BI operacional do p&aacute;tio: estoque por loja, entradas e movimenta&ccedil;&otilde;es recentes.</div>
                                            </div>
                                        </div>
                                        <div class="page-title-actions">
                                            <asp:LinkButton ID="btnAtualizar" runat="server" CssClass="btn btn-light" OnClick="btnAtualizar_Click"><i class="fa fa-sync-alt mr-1"></i> Atualizar</asp:LinkButton>
                                        </div>
                                    </div>
                                </div>
                                <div class="patio-bi-shell">
                                    <asp:Literal ID="litResumo" runat="server"></asp:Literal>
                                    <div class="patio-bi-grid">
                                        <div class="patio-bi-panel">
                                            <div class="patio-bi-panel-header">
                                                <strong><i class="fa fa-store mr-1"></i> Ve&iacute;culos por loja</strong>
                                                <small>posição atual</small>
                                            </div>
                                            <div class="patio-bi-panel-body">
                                                <asp:Literal ID="litEstoquePorLoja" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                        <div class="patio-bi-panel">
                                            <div class="patio-bi-panel-header">
                                                <strong><i class="fa fa-calendar-day mr-1"></i> Entradas por dia</strong>
                                                <small>últimos 14 dias</small>
                                            </div>
                                            <div class="patio-bi-panel-body">
                                                <asp:Literal ID="litEntradasDia" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="patio-bi-grid">
                                        <div class="patio-bi-panel">
                                            <div class="patio-bi-panel-header">
                                                <strong><i class="fa fa-random mr-1"></i> Movimentações por dia</strong>
                                                <small>últimos 14 dias</small>
                                            </div>
                                            <div class="patio-bi-panel-body">
                                                <asp:Literal ID="litMovimentacoesDia" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                        <div class="patio-bi-panel">
                                            <div class="patio-bi-panel-header">
                                                <strong><i class="fa fa-user-check mr-1"></i> Usuários com mais entradas</strong>
                                                <small>últimos 30 dias</small>
                                            </div>
                                            <div class="patio-bi-panel-body">
                                                <asp:Literal ID="litUsuarios" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="patio-bi-panel">
                                        <div class="patio-bi-panel-header">
                                            <strong><i class="fa fa-exchange-alt mr-1"></i> &Uacute;ltimas movimenta&ccedil;&otilde;es</strong>
                                            <small>transferências recentes</small>
                                        </div>
                                        <div class="patio-bi-panel-body patio-bi-table-wrap">
                                            <asp:Literal ID="litUltimasMovimentacoes" runat="server"></asp:Literal>
                                        </div>
                                    </div>
                                    <div class="patio-bi-panel">
                                        <div class="patio-bi-panel-header">
                                            <strong><i class="fa fa-car mr-1"></i> Últimos ve&iacute;culos cadastrados</strong>
                                            <small>entradas recentes no p&aacute;tio</small>
                                        </div>
                                        <div class="patio-bi-panel-body patio-bi-table-wrap">
                                            <asp:Literal ID="litUltimosCadastros" runat="server"></asp:Literal>
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
                    </footer>
                </div>
            </div>
        </div>
    </form>
    <script src="../assets/popper.min.js"></script>
    <script src="../assets/bootstrap.min.js"></script>
    <script src="../assets/scripts/main.js"></script>
    <script src="./assets/js/patio-jeep-ux.js?v=20260704-2"></script>
</body>
</html>
