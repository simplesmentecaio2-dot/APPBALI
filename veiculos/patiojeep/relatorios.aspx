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

        .patio-sync-status {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            padding: .9rem 1rem;
            border: 1px solid #cfe8c7;
            border-radius: 16px;
            background: linear-gradient(135deg, #f7fbf4, #eef8e8);
            color: #203729;
            font-weight: 850;
            box-shadow: 0 12px 30px rgba(15, 23, 42, .06);
        }

        .patio-sync-status i {
            color: #587a3f;
            font-size: 1.05rem;
        }

        .patio-sync-status span {
            flex: 1;
            min-width: 0;
        }

        .patio-sync-status strong {
            color: #0f172a;
            white-space: nowrap;
        }

        .patio-sync-status.is-warning {
            border-color: #fde68a;
            background: #fffbeb;
            color: #92400e;
        }

        .patio-sync-status.is-idle {
            border-color: #dbe4ef;
            background: #f8fafc;
            color: #475569;
        }

        .patio-sync-status.is-idle i {
            color: #64748b;
        }

        .patio-bi-action.is-loading {
            pointer-events: none;
            opacity: .82;
            min-width: 122px;
        }

        .patio-bi-action .patio-bi-button-spinner {
            display: none;
            width: 14px;
            height: 14px;
            margin-right: .45rem;
            border: 2px solid rgba(15, 23, 42, .22);
            border-top-color: #203729;
            border-radius: 999px;
            vertical-align: -2px;
            animation: patioBiSpin .72s linear infinite;
        }

        .patio-bi-action.is-loading .patio-bi-button-spinner {
            display: inline-block;
        }

        .patio-bi-progress {
            position: fixed;
            right: 24px;
            bottom: 72px;
            z-index: 1200;
            display: flex;
            align-items: center;
            gap: .85rem;
            max-width: min(420px, calc(100vw - 32px));
            padding: .95rem 1.05rem;
            border: 1px solid rgba(111, 145, 81, .28);
            border-radius: 18px;
            background: rgba(255, 255, 255, .98);
            color: #203729;
            box-shadow: 0 18px 44px rgba(15, 23, 42, .18);
        }

        .patio-bi-progress-spinner {
            flex: 0 0 auto;
            width: 30px;
            height: 30px;
            border: 3px solid rgba(111, 145, 81, .24);
            border-top-color: #203729;
            border-radius: 999px;
            animation: patioBiSpin .72s linear infinite;
        }

        .patio-bi-progress strong,
        .patio-bi-progress small {
            display: block;
        }

        .patio-bi-progress strong {
            color: #0f172a;
            font-weight: 950;
        }

        .patio-bi-progress small {
            color: #64748b;
            font-weight: 800;
            line-height: 1.25;
        }

        .patio-bi-refreshing .patio-bi-shell {
            opacity: .72;
            transition: opacity .18s ease;
        }

        @keyframes patioBiSpin {
            to {
                transform: rotate(360deg);
            }
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

            .patio-sync-status {
                align-items: flex-start;
                flex-direction: column;
            }

            .patio-sync-status strong {
                white-space: normal;
            }

            .patio-bi-bar-row {
                grid-template-columns: 1fr;
                gap: .35rem;
            }

            .patio-bi-bar-value {
                text-align: left;
            }

            .patio-bi-progress {
                left: 16px;
                right: 16px;
                bottom: 68px;
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
                                            <asp:LinkButton ID="btnAtualizar" runat="server" CssClass="btn btn-light patio-bi-action" OnClick="btnAtualizar_Click" OnClientClick="if(window.PatioRelatoriosLoading){window.PatioRelatoriosLoading.start();}" ToolTip="Atualizar BI e sincronizar baixas por venda"><span class="patio-bi-button-spinner" aria-hidden="true"></span><i class="fa fa-sync-alt mr-1"></i><span class="patio-bi-action-text">Atualizar</span></asp:LinkButton>
                                        </div>
                                    </div>
                                </div>
                                <div class="patio-bi-shell">
                                    <asp:Literal ID="litBaixaVendaStatus" runat="server"></asp:Literal>
                                    <asp:Literal ID="litResumo" runat="server"></asp:Literal>
                                    <div class="patio-bi-grid">
                                        <div class="patio-bi-panel">
                                            <div class="patio-bi-panel-header">
                                                <strong><i class="fa fa-store mr-1"></i> Ve&iacute;culos por loja</strong>
                                                <small>posi&ccedil;&atilde;o atual</small>
                                            </div>
                                            <div class="patio-bi-panel-body">
                                                <asp:Literal ID="litEstoquePorLoja" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                        <div class="patio-bi-panel">
                                            <div class="patio-bi-panel-header">
                                                <strong><i class="fa fa-calendar-day mr-1"></i> Entradas por dia</strong>
                                                <small>&uacute;ltimos 14 dias</small>
                                            </div>
                                            <div class="patio-bi-panel-body">
                                                <asp:Literal ID="litEntradasDia" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="patio-bi-grid">
                                        <div class="patio-bi-panel">
                                            <div class="patio-bi-panel-header">
                                                <strong><i class="fa fa-random mr-1"></i> Movimenta&ccedil;&otilde;es por dia</strong>
                                                <small>&uacute;ltimos 14 dias</small>
                                            </div>
                                            <div class="patio-bi-panel-body">
                                                <asp:Literal ID="litMovimentacoesDia" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                        <div class="patio-bi-panel">
                                            <div class="patio-bi-panel-header">
                                                <strong><i class="fa fa-user-check mr-1"></i> Usu&aacute;rios com mais entradas</strong>
                                                <small>&uacute;ltimos 30 dias</small>
                                            </div>
                                            <div class="patio-bi-panel-body">
                                                <asp:Literal ID="litUsuarios" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="patio-bi-panel">
                                        <div class="patio-bi-panel-header">
                                            <strong><i class="fa fa-exchange-alt mr-1"></i> &Uacute;ltimas movimenta&ccedil;&otilde;es</strong>
                                            <small>transfer&ecirc;ncias recentes</small>
                                        </div>
                                        <div class="patio-bi-panel-body patio-bi-table-wrap">
                                            <asp:Literal ID="litUltimasMovimentacoes" runat="server"></asp:Literal>
                                        </div>
                                    </div>
                                    <div class="patio-bi-panel">
                                        <div class="patio-bi-panel-header">
                                            <strong><i class="fa fa-car mr-1"></i> &Uacute;ltimos ve&iacute;culos cadastrados</strong>
                                            <small>entradas recentes no p&aacute;tio</small>
                                        </div>
                                        <div class="patio-bi-panel-body patio-bi-table-wrap">
                                            <asp:Literal ID="litUltimosCadastros" runat="server"></asp:Literal>
                                        </div>
                                    </div>
                                    <div class="patio-bi-panel">
                                        <div class="patio-bi-panel-header">
                                            <strong><i class="fa fa-check-circle mr-1"></i> &Uacute;ltimas baixas por venda</strong>
                                            <small>sincroniza&ccedil;&atilde;o com vendas</small>
                                        </div>
                                        <div class="patio-bi-panel-body patio-bi-table-wrap">
                                            <asp:Literal ID="litUltimasBaixas" runat="server"></asp:Literal>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <asp:UpdateProgress ID="UpdateProgress1" DisplayAfter="120" DynamicLayout="true" runat="server" AssociatedUpdatePanelID="updatePanel">
                        <ProgressTemplate>
                            <div class="patio-bi-progress" role="status" aria-live="polite">
                                <span class="patio-bi-progress-spinner" aria-hidden="true"></span>
                                <div>
                                    <strong>Atualizando BI</strong>
                                    <small>Conferindo vendas e sincronizando baixas. Aguarde alguns instantes.</small>
                                </div>
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
    <script src="./assets/js/patio-jeep-ux.js?v=20260706-4"></script>
    <script>
        (function () {
            var buttonId = '<%= btnAtualizar.ClientID %>';

            function getButton() {
                return document.getElementById(buttonId);
            }

            function setLoading(active) {
                var button = getButton();
                if (!button) return true;

                var text = button.querySelector('.patio-bi-action-text');
                button.classList.toggle('is-loading', active);
                button.setAttribute('aria-busy', active ? 'true' : 'false');
                if (text) {
                    text.textContent = active ? 'Atualizando...' : 'Atualizar';
                }
                document.body.classList.toggle('patio-bi-refreshing', active);
                return true;
            }

            window.PatioRelatoriosLoading = {
                start: function () {
                    return setLoading(true);
                },
                stop: function () {
                    return setLoading(false);
                }
            };

            if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                var manager = Sys.WebForms.PageRequestManager.getInstance();
                manager.add_beginRequest(function () {
                    setLoading(true);
                });
                manager.add_endRequest(function () {
                    setLoading(false);
                });
            }
        })();
    </script>
</body>
</html>
