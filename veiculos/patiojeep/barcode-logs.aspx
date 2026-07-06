<%@ Page Language="C#" AutoEventWireup="true" CodeFile="barcode-logs.aspx.cs" Inherits="veiculos_patio_barcode_logs" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>LOGS DO LEITOR | P&aacute;tio</title>
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
        .barcode-log-shell {
            display: grid;
            gap: 1rem;
        }

        .barcode-log-summary {
            display: grid;
            grid-template-columns: repeat(4, minmax(150px, 1fr));
            gap: .9rem;
        }

        .barcode-log-card {
            padding: 1rem;
            border: 1px solid #dbe4ef;
            border-radius: 18px;
            background: #fff;
            box-shadow: 0 14px 34px rgba(15, 23, 42, .08);
        }

        .barcode-log-card small {
            display: block;
            color: #64748b;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: .04em;
        }

        .barcode-log-card strong {
            display: block;
            margin-top: .25rem;
            color: #0f172a;
            font-size: 1.7rem;
            line-height: 1;
        }

        .barcode-log-table-wrap {
            padding: 1rem;
            border: 1px solid #dbe4ef;
            border-radius: 18px;
            background: #fff;
            box-shadow: 0 14px 34px rgba(15, 23, 42, .08);
            overflow-x: auto;
        }

        .barcode-log-table {
            width: 100%;
            min-width: 980px;
        }

        .barcode-log-table th {
            white-space: nowrap;
            color: #475569;
            font-size: .76rem;
            text-transform: uppercase;
            letter-spacing: .04em;
        }

        .barcode-log-event {
            display: inline-flex;
            align-items: center;
            padding: .28rem .55rem;
            border-radius: 999px;
            background: #eef2ff;
            color: #1e3a8a;
            font-weight: 900;
            font-size: .78rem;
        }

        .barcode-log-event.is-error {
            background: #fee2e2;
            color: #991b1b;
        }

        .barcode-log-event.is-success {
            background: #dcfce7;
            color: #166534;
        }

        @media (max-width: 767.98px) {
            .barcode-log-summary {
                grid-template-columns: 1fr 1fr;
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
                                <li><a href="./relatorios.aspx"><i class="metismenu-icon fas fa-chart-line"></i>Relat&oacute;rios</a></li>
                                <li><a href="./lojas.aspx"><i class="metismenu-icon fas fa-store"></i>Lojas</a></li>
                                <li><a href="./barcode-logs.aspx" class="mm-active"><i class="metismenu-icon fas fa-clipboard-list"></i>Logs do leitor</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="app-main__outer">
                    <div class="app-main__inner mb-3">
                        <div class="app-page-title text-white" style="background-color:#495057;">
                            <div class="page-title-wrapper">
                                <div class="page-title-heading">
                                    <div class="page-title-icon" style="background-color:#495057;">
                                        <i class="fas fa-clipboard-list text-white"></i>
                                    </div>
                                    <div>
                                        <b>Logs do leitor</b>
                                        <div class="page-title-subheading">Auditoria de leituras, c&acirc;mera, diagn&oacute;stico e falhas no celular.</div>
                                    </div>
                                </div>
                                <div class="page-title-actions">
                                    <asp:LinkButton ID="btnAtualizar" runat="server" CssClass="btn btn-light" OnClick="btnAtualizar_Click"><i class="fa fa-sync-alt mr-1"></i> Atualizar</asp:LinkButton>
                                </div>
                            </div>
                        </div>
                        <div class="barcode-log-shell">
                            <asp:Literal ID="litResumo" runat="server"></asp:Literal>
                            <div class="barcode-log-table-wrap">
                                <asp:Literal ID="litTabela" runat="server"></asp:Literal>
                            </div>
                        </div>
                    </div>
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
    <script src="./assets/js/patio-jeep-ux.js?v=20260706-5"></script>
    <script>
        $(function () {
            if ($('#barcodeLogTable').length) {
                $('#barcodeLogTable').DataTable({
                    pageLength: 25,
                    order: [[0, 'desc']]
                });
            }
        });
    </script>
</body>
</html>
