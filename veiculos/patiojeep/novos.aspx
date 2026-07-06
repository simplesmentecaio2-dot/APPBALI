<%@ Page Language="C#" AutoEventWireup="true" CodeFile="novos.aspx.cs" Inherits="veiculos_patio_novos" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>NOVOS | P&aacute;tio</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <script src="../assets/jquery-1.9.1.min.js"></script>
    <link href="./main.css" rel="stylesheet" />
    <link href="../../css/bali-patio.css?v=20260704-1" rel="stylesheet" />
    <link href="../assets/all.min.css" rel="stylesheet" />
    <style>
        .novos-shell {
            display: grid;
            gap: 1rem;
        }

        .novos-tabs {
            display: flex;
            flex-wrap: wrap;
            gap: .65rem;
        }

        .novos-tab {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: .5rem;
            border: 1px solid #dbe4ef;
            border-radius: 999px;
            padding: .72rem 1rem;
            background: #fff;
            color: #334155;
            font-weight: 900;
            box-shadow: 0 10px 24px rgba(15, 23, 42, .07);
            text-decoration: none !important;
            transition: transform .18s ease, border-color .18s ease, box-shadow .18s ease, background .18s ease;
        }

        .novos-tab:hover {
            transform: translateY(-1px);
            border-color: #8aa36f;
            color: #203729;
        }

        .novos-tab.is-active {
            background: linear-gradient(135deg, #203729, #6f9151);
            border-color: transparent;
            color: #fff;
            box-shadow: 0 16px 34px rgba(32, 55, 41, .22);
        }

        .novos-frame-card {
            border: 1px solid #dbe4ef;
            border-radius: 18px;
            background: rgba(255,255,255,.97);
            box-shadow: 0 16px 40px rgba(15,23,42,.08);
            overflow: hidden;
        }

        .novos-frame-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            padding: 1rem 1.15rem;
            border-bottom: 1px solid #e2e8f0;
            background: linear-gradient(180deg, #fff, #f8fafc);
        }

        .novos-frame-header small {
            display: block;
            color: #64748b;
            font-weight: 850;
        }

        .novos-frame-title {
            margin: 0;
            color: #0f172a;
            font-size: 1.05rem;
            font-weight: 950;
        }

        .novos-frame-status {
            display: inline-flex;
            align-items: center;
            gap: .45rem;
            border-radius: 999px;
            padding: .42rem .72rem;
            background: #eef6e9;
            color: #203729;
            font-size: .78rem;
            font-weight: 950;
            white-space: nowrap;
        }

        .novos-frame-wrap {
            position: relative;
            min-height: 720px;
            background: #f8fafc;
        }

        .novos-frame {
            display: block;
            width: 100%;
            min-height: 820px;
            border: 0;
            background: transparent;
        }

        .novos-frame-loader {
            position: absolute;
            inset: 0;
            z-index: 2;
            display: none;
            align-items: flex-start;
            justify-content: center;
            padding-top: 3rem;
            background: rgba(248,250,252,.78);
            pointer-events: none;
        }

        .novos-frame-loader.is-active {
            display: flex;
        }

        .novos-loader-card {
            display: inline-flex;
            align-items: center;
            gap: .75rem;
            border: 1px solid #dbe4ef;
            border-radius: 16px;
            background: #fff;
            padding: .85rem 1rem;
            color: #334155;
            font-weight: 900;
            box-shadow: 0 14px 34px rgba(15,23,42,.12);
        }

        .novos-spinner {
            width: 24px;
            height: 24px;
            border-radius: 999px;
            border: 3px solid #dbe4ef;
            border-top-color: #6f9151;
            animation: novosSpin .85s linear infinite;
        }

        @keyframes novosSpin {
            to { transform: rotate(360deg); }
        }

        @media (max-width: 767.98px) {
            .novos-tabs {
                display: grid;
                grid-template-columns: 1fr 1fr;
            }

            .novos-tab {
                border-radius: 14px;
            }

            .novos-frame-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .novos-frame {
                min-height: 980px;
            }
        }

        @media (max-width: 480px) {
            .novos-tabs {
                grid-template-columns: 1fr;
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
                    <div class="header__pane ml-auto">
                        <button type="button" class="hamburger close-sidebar-btn hamburger--elastic" data-class="closed-sidebar">
                            <span class="hamburger-box"><span class="hamburger-inner"></span></span>
                        </button>
                    </div>
                </div>
                <div class="app-header__mobile-menu">
                    <button type="button" class="hamburger hamburger--elastic mobile-toggle-nav">
                        <span class="hamburger-box"><span class="hamburger-inner"></span></span>
                    </button>
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
                                            <asp:LinkButton runat="server" ID="sair" CssClass="fa fa-arrow-alt-circle-right text-danger" OnClick="btnSair_Click" ToolTip="Sair"></asp:LinkButton>
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
                    <div class="app-header__logo">
                        <div class="logo-src"></div>
                        <div class="header__pane ml-auto">
                            <button type="button" class="hamburger close-sidebar-btn hamburger--elastic" data-class="closed-sidebar">
                                <span class="hamburger-box"><span class="hamburger-inner"></span></span>
                            </button>
                        </div>
                    </div>
                    <div class="app-header__mobile-menu">
                        <button type="button" class="hamburger hamburger--elastic mobile-toggle-nav">
                            <span class="hamburger-box"><span class="hamburger-inner"></span></span>
                        </button>
                    </div>
                    <div class="scrollbar-sidebar bg-dark">
                        <div class="app-sidebar__inner">
                            <ul class="vertical-nav-menu">
                                <li><a href="./"><i class="metismenu-icon fas fa-home"></i>In&iacute;cio</a></li>
                                <li class="app-sidebar__heading">Fun&ccedil;&otilde;es</li>
                                <li><a href="./novos.aspx" class="mm-active"><i class="metismenu-icon fas fa-car"></i>Novos</a></li>
                                <li><a href="./seminovos.aspx"><i class="metismenu-icon fas fa-car-side"></i>Seminovos</a></li>
                                <li><a href="./lojas.aspx"><i class="metismenu-icon fas fa-store"></i>Lojas</a></li>
                                <li><a href="./barcode-logs.aspx"><i class="metismenu-icon fas fa-clipboard-list"></i>Logs do leitor</a></li>
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
                                        <i class="fas fa-car text-white"></i>
                                    </div>
                                    <div>
                                        <b>Novos</b>
                                        <div class="page-title-subheading">Registro, consulta, transfer&ecirc;ncia e BI dos ve&iacute;culos novos em uma tela &uacute;nica.</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="novos-shell">
                            <div class="novos-tabs" role="tablist" aria-label="Fun&ccedil;&otilde;es de ve&iacute;culos novos">
                                <button type="button" class="novos-tab" data-novos-tab="registrar" data-src="./registrar.aspx?embed=1"><i class="fa fa-folder-plus"></i>Registrar</button>
                                <button type="button" class="novos-tab" data-novos-tab="transferir" data-src="./transferir.aspx?embed=1"><i class="fa fa-exchange-alt"></i>Transferir</button>
                                <button type="button" class="novos-tab" data-novos-tab="consultar" data-src="./historico.aspx?embed=1"><i class="fa fa-search"></i>Consultar</button>
                                <button type="button" class="novos-tab" data-novos-tab="relatorios" data-src="./relatorios.aspx?embed=1"><i class="fa fa-chart-line"></i>Relat&oacute;rios</button>
                            </div>

                            <div class="novos-frame-card">
                                <div class="novos-frame-header">
                                    <div>
                                        <small id="novosFrameEyebrow">P&aacute;tio de novos</small>
                                        <h2 class="novos-frame-title" id="novosFrameTitle">Registrar ve&iacute;culo</h2>
                                    </div>
                                    <span class="novos-frame-status"><i class="fa fa-shield-alt"></i> Regras originais preservadas</span>
                                </div>
                                <div class="novos-frame-wrap">
                                    <div class="novos-frame-loader is-active" id="novosFrameLoader">
                                        <div class="novos-loader-card"><span class="novos-spinner" aria-hidden="true"></span>Carregando tela...</div>
                                    </div>
                                    <iframe id="novosFrame" class="novos-frame" src="./registrar.aspx?embed=1" title="Fun&ccedil;&atilde;o selecionada de ve&iacute;culos novos"></iframe>
                                </div>
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
    <script src="./assets/js/patio-jeep-ux.js?v=20260706-3"></script>
    <script>
        (function () {
            var tabs = document.querySelectorAll('[data-novos-tab]');
            var frame = document.getElementById('novosFrame');
            var loader = document.getElementById('novosFrameLoader');
            var title = document.getElementById('novosFrameTitle');
            var titles = {
                registrar: 'Registrar ve\u00edculo',
                transferir: 'Transferir ve\u00edculo',
                consultar: 'Consultar hist\u00f3rico',
                relatorios: 'Relat\u00f3rios'
            };

            function setLoading(active) {
                if (loader) loader.classList.toggle('is-active', active);
            }

            function activate(key, pushState) {
                var selected = null;
                for (var i = 0; i < tabs.length; i++) {
                    var tab = tabs[i];
                    var isActive = tab.getAttribute('data-novos-tab') === key;
                    tab.classList.toggle('is-active', isActive);
                    tab.setAttribute('aria-selected', isActive ? 'true' : 'false');
                    if (isActive) selected = tab;
                }

                if (!selected) {
                    activate('registrar', false);
                    return;
                }

                if (title) title.textContent = titles[key] || 'Novos';
                if (frame && frame.getAttribute('src') !== selected.getAttribute('data-src')) {
                    setLoading(true);
                    frame.setAttribute('src', selected.getAttribute('data-src'));
                } else {
                    setLoading(false);
                }

                if (pushState && window.history && window.history.replaceState) {
                    window.history.replaceState(null, '', 'novos.aspx?aba=' + encodeURIComponent(key));
                }
            }

            for (var i = 0; i < tabs.length; i++) {
                tabs[i].addEventListener('click', function () {
                    activate(this.getAttribute('data-novos-tab'), true);
                });
            }

            if (frame) {
                frame.addEventListener('load', function () {
                    setLoading(false);
                });
            }

            window.addEventListener('message', function (event) {
                if (event.origin !== location.origin || !event.data || event.data.type !== 'patio-embed-height' || !frame) return;
                var height = parseInt(event.data.height, 10);
                if (!height || height < 720) height = 720;
                frame.style.height = Math.min(height + 28, 2800) + 'px';
            });

            var params = new URLSearchParams(location.search || '');
            activate(params.get('aba') || 'registrar', false);
        })();
    </script>
</body>
</html>
