<%@ Page Language="C#" AutoEventWireup="true" CodeFile="saude.aspx.cs" Inherits="veiculos_patiojeep_saude" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Sa&uacute;de do P&aacute;tio | Grupo Bali</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <script src="../assets/jquery-1.9.1.min.js"></script>
    <link href="./main.css" rel="stylesheet" />
    <link href="../../css/bali-patio.css?v=20260704-1" rel="stylesheet" />
    <link href="../assets/all.min.css" rel="stylesheet" />
    <style>
        .health-shell { display:grid; gap:1rem; }
        .health-grid { display:grid; grid-template-columns:repeat(12,minmax(0,1fr)); gap:1rem; }
        .health-card { grid-column:span 6; border:1px solid #dbe4ef; border-radius:18px; background:rgba(255,255,255,.97); box-shadow:0 16px 40px rgba(15,23,42,.08); overflow:hidden; }
        .health-card.is-full { grid-column:1/-1; }
        .health-header { display:flex; align-items:center; justify-content:space-between; gap:1rem; padding:1rem 1.15rem; border-bottom:1px solid #e2e8f0; background:linear-gradient(180deg,#fff,#f8fafc); }
        .health-header small { display:block; color:#64748b; font-weight:850; }
        .health-title { margin:0; color:#0f172a; font-size:1.08rem; font-weight:950; }
        .health-body { padding:1.15rem; }
        .health-kpis { display:grid; grid-template-columns:repeat(4,minmax(130px,1fr)); gap:.85rem; }
        .health-kpi { border:1px solid #dbe4ef; border-radius:16px; background:#fff; padding:1rem; }
        .health-kpi small { display:block; color:#64748b; font-size:.72rem; font-weight:950; letter-spacing:.04em; text-transform:uppercase; }
        .health-kpi strong { display:block; margin-top:.35rem; color:#0f172a; font-size:1.35rem; font-weight:950; line-height:1.1; }
        .health-list { display:grid; gap:.55rem; }
        .health-row { display:grid; grid-template-columns:minmax(0,1fr) auto; gap:.75rem; align-items:center; padding:.72rem .85rem; border:1px solid #e2e8f0; border-radius:12px; background:#fff; }
        .health-row strong { color:#1f2937; font-size:.88rem; font-weight:950; word-break:break-word; }
        .health-row small { display:block; color:#64748b; font-weight:750; }
        .health-badge { display:inline-flex; align-items:center; gap:.35rem; border-radius:999px; padding:.35rem .6rem; font-size:.74rem; font-weight:950; white-space:nowrap; }
        .health-badge.is-ok { background:#dcfce7; color:#166534; }
        .health-badge.is-warn { background:#fef3c7; color:#92400e; }
        .health-actions { display:flex; flex-wrap:wrap; gap:.7rem; align-items:center; }
        .health-btn { display:inline-flex; align-items:center; justify-content:center; gap:.5rem; min-height:44px; border-radius:12px; border:1px solid #cfd9e6; padding:.7rem 1rem; font-weight:950; text-decoration:none !important; background:#fff; color:#334155 !important; }
        .health-btn-primary { background:linear-gradient(135deg,#203729,#6f9151); border-color:transparent; color:#fff !important; box-shadow:0 12px 28px rgba(32,55,41,.22); }
        @media (max-width:991.98px) { .health-card { grid-column:1/-1; } .health-kpis { grid-template-columns:1fr 1fr; } }
        @media (max-width:575.98px) { .health-kpis { grid-template-columns:1fr; } .health-row { grid-template-columns:1fr; } .health-actions .health-btn { width:100%; } }
    </style>
</head>
<body class="patio-modern-page patio-brand-jeep">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="app-container app-theme-white body-tabs-shadow fixed-sidebar fixed-header">
            <div class="app-header header-shadow bg-dark">
                <div class="app-header__logo"><div class="logo-src"></div></div>
                <div class="app-header__content bg-dark">
                    <div class="app-header-left"></div>
                    <div class="app-header-right">
                        <div class="text-white"><b><i class="fa fa-user mr-1"></i><asp:Literal ID="usuarioLogado" runat="server"></asp:Literal></b>
                            <asp:LinkButton runat="server" ID="sair" CssClass="fa fa-arrow-alt-circle-right text-danger ml-2" OnClick="btnSair_Click" ToolTip="Sair"></asp:LinkButton>
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
                                <li><a href="./novos.aspx"><i class="metismenu-icon fas fa-car"></i>Novos</a></li>
                                <li><a href="./seminovos.aspx"><i class="metismenu-icon fas fa-car-side"></i>Seminovos</a></li>
                                <li><a href="./lojas.aspx"><i class="metismenu-icon fas fa-store"></i>Lojas</a></li>
                                <li><a href="./permissoes.aspx"><i class="metismenu-icon fas fa-user-shield"></i>Permiss&otilde;es</a></li>
                                <li><a href="./auditoria.aspx"><i class="metismenu-icon fas fa-shield-alt"></i>Auditoria</a></li>
                                <li><a href="./saude.aspx" class="mm-active"><i class="metismenu-icon fas fa-heartbeat"></i>Sa&uacute;de</a></li>
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
                                    <div class="page-title-icon" style="background-color:#495057;"><i class="fas fa-heartbeat text-white"></i></div>
                                    <div>
                                        <b>Sa&uacute;de do P&aacute;tio</b>
                                        <div class="page-title-subheading">Confer&ecirc;ncia t&eacute;cnica de tabelas, procedures, &iacute;ndices e sincroniza&ccedil;&otilde;es.</div>
                                    </div>
                                </div>
                                <div class="page-title-actions">
                                    <asp:LinkButton ID="btnAtualizar" runat="server" CssClass="health-btn health-btn-primary" OnClick="btnAtualizar_Click"><i class="fa fa-sync-alt"></i>Atualizar</asp:LinkButton>
                                </div>
                            </div>
                        </div>
                        <div class="health-shell">
                            <div class="health-card is-full">
                                <div class="health-header">
                                    <div>
                                        <small>Resumo</small>
                                        <h2 class="health-title">Estado geral</h2>
                                    </div>
                                    <span class="health-badge is-ok"><i class="fa fa-database"></i><asp:Literal ID="litBanco" runat="server"></asp:Literal></span>
                                </div>
                                <div class="health-body">
                                    <asp:Literal ID="litResumo" runat="server"></asp:Literal>
                                </div>
                            </div>
                            <div class="health-grid">
                                <div class="health-card">
                                    <div class="health-header"><div><small>Estrutura</small><h2 class="health-title">Tabelas esperadas</h2></div></div>
                                    <div class="health-body"><asp:Literal ID="litTabelas" runat="server"></asp:Literal></div>
                                </div>
                                <div class="health-card">
                                    <div class="health-header"><div><small>Execu&ccedil;&atilde;o</small><h2 class="health-title">Procedures esperadas</h2></div></div>
                                    <div class="health-body"><asp:Literal ID="litProcedures" runat="server"></asp:Literal></div>
                                </div>
                                <div class="health-card is-full">
                                    <div class="health-header"><div><small>Performance</small><h2 class="health-title">&Iacute;ndices principais</h2></div></div>
                                    <div class="health-body"><asp:Literal ID="litIndices" runat="server"></asp:Literal></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <footer class="fixed-bottom bg-dark">
                        <div class="container text-center text-white mb-2 mt-2"><b>TI - GRUPO BALI</b></div>
                    </footer>
                </div>
            </div>
        </div>
    </form>
    <script src="../assets/popper.min.js"></script>
    <script src="../assets/bootstrap.min.js"></script>
    <script src="../assets/scripts/main.js"></script>
    <script src="./assets/js/patio-jeep-ux.js?v=20260706-5"></script>
</body>
</html>
