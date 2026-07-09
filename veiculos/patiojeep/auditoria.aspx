<%@ Page Language="C#" AutoEventWireup="true" CodeFile="auditoria.aspx.cs" Inherits="veiculos_patiojeep_auditoria" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Auditoria do P&aacute;tio | Grupo Bali</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <script src="../assets/jquery-1.9.1.min.js"></script>
    <link href="./main.css" rel="stylesheet" />
    <link href="../../css/bali-patio.css?v=20260704-1" rel="stylesheet" />
    <link href="../assets/all.min.css" rel="stylesheet" />
    <style>
        .audit-shell { display:grid; gap:1rem; }
        .audit-card { border:1px solid #dbe4ef; border-radius:18px; background:rgba(255,255,255,.97); box-shadow:0 16px 40px rgba(15,23,42,.08); overflow:hidden; }
        .audit-header { display:flex; align-items:center; justify-content:space-between; gap:1rem; padding:1rem 1.15rem; border-bottom:1px solid #e2e8f0; background:linear-gradient(180deg,#fff,#f8fafc); }
        .audit-header small { display:block; color:#64748b; font-weight:850; }
        .audit-title { margin:0; color:#0f172a; font-size:1.08rem; font-weight:950; }
        .audit-body { padding:1.15rem; }
        .audit-grid { display:grid; grid-template-columns:repeat(12,minmax(0,1fr)); gap:.9rem; }
        .audit-field { grid-column:span 3; display:grid; gap:.35rem; }
        .audit-field.is-wide { grid-column:span 6; }
        .audit-label { color:#475569; font-size:.74rem; font-weight:950; letter-spacing:.04em; text-transform:uppercase; }
        .audit-input, .audit-select { width:100%; min-height:46px; border:1px solid #cfd9e6; border-radius:12px; padding:.72rem .85rem; background:#fff; color:#0f172a; font-weight:800; outline:none; }
        .audit-input:focus, .audit-select:focus { border-color:#6f9151; box-shadow:0 0 0 4px rgba(111,145,81,.14); }
        .audit-actions { display:flex; flex-wrap:wrap; gap:.7rem; align-items:center; margin-top:1rem; }
        .audit-btn { display:inline-flex; align-items:center; justify-content:center; gap:.5rem; min-height:44px; border-radius:12px; border:1px solid #cfd9e6; padding:.7rem 1rem; font-weight:950; text-decoration:none !important; background:#fff; color:#334155 !important; }
        .audit-btn-primary { background:linear-gradient(135deg,#203729,#6f9151); border-color:transparent; color:#fff !important; box-shadow:0 12px 28px rgba(32,55,41,.22); }
        .audit-table-wrap { overflow-x:auto; }
        .audit-table { width:100%; min-width:980px; border-collapse:separate; border-spacing:0; }
        .audit-table th { background:#f8fafc; color:#475569; font-size:.73rem; font-weight:950; letter-spacing:.04em; text-transform:uppercase; white-space:nowrap; border-bottom:1px solid #e2e8f0; padding:.75rem; }
        .audit-table td { color:#1f2937; font-weight:750; vertical-align:top; border-bottom:1px solid #edf2f7; padding:.78rem; }
        .audit-table small { display:block; color:#64748b; font-weight:750; margin-top:.2rem; }
        .audit-pill { display:inline-flex; align-items:center; gap:.4rem; border-radius:999px; padding:.38rem .62rem; background:#eef6e9; color:#203729; font-size:.76rem; font-weight:950; }
        .audit-empty { border:1px dashed #cfd9e6; border-radius:16px; padding:1.2rem; background:#f8fafc; color:#64748b; font-weight:850; text-align:center; }
        .audit-quick { display:flex; flex-wrap:wrap; gap:.55rem; margin-top:.85rem; }
        .audit-chip { display:inline-flex; align-items:center; gap:.4rem; border:1px solid #dbe4ef; border-radius:999px; padding:.45rem .75rem; background:#fff; color:#334155 !important; font-weight:900; text-decoration:none !important; }
        .audit-chip:hover { border-color:#8aa36f; color:#203729 !important; }
        .audit-summary-grid { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:1rem; }
        .audit-bar-list { display:grid; gap:.75rem; }
        .audit-bar-row { display:grid; grid-template-columns:minmax(110px,.42fr) minmax(0,1fr) 56px; gap:.65rem; align-items:center; }
        .audit-bar-label { color:#334155; font-weight:900; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .audit-bar-track { height:12px; border-radius:999px; background:#edf2f7; overflow:hidden; }
        .audit-bar-track span { display:block; height:100%; min-width:3px; border-radius:inherit; background:linear-gradient(90deg,#6f9151,#203729); }
        .audit-bar-value { color:#64748b; font-weight:950; text-align:right; }
        @media (max-width:991.98px) { .audit-field, .audit-field.is-wide { grid-column:span 6; } }
        @media (max-width:767.98px) {
            .audit-header { display:grid; grid-template-columns:1fr; }
            .audit-field, .audit-field.is-wide { grid-column:1/-1; }
            .audit-summary-grid { grid-template-columns:1fr; }
            .audit-bar-row { grid-template-columns:1fr; }
            .audit-actions .audit-btn { flex:1 1 100%; }
            .audit-table, .audit-table thead, .audit-table tbody, .audit-table th, .audit-table td, .audit-table tr { display:block; min-width:0; width:100%; }
            .audit-table thead { display:none; }
            .audit-table tr { border:1px solid #dbe4ef; border-radius:16px; margin-bottom:.85rem; background:#fff; overflow:hidden; }
            .audit-table td { display:grid; grid-template-columns:112px minmax(0,1fr); gap:.65rem; border-bottom:1px solid #edf2f7; }
            .audit-table td:before { content:attr(data-label); color:#64748b; font-size:.72rem; font-weight:950; letter-spacing:.04em; text-transform:uppercase; }
        }
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
                                <li><a href="./auditoria.aspx" class="mm-active"><i class="metismenu-icon fas fa-shield-alt"></i>Auditoria</a></li>
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
                                    <div class="page-title-icon" style="background-color:#495057;"><i class="fas fa-shield-alt text-white"></i></div>
                                    <div>
                                        <b>Auditoria do P&aacute;tio</b>
                                        <div class="page-title-subheading">Consulta de eventos operacionais, baixas, transfer&ecirc;ncias e manuten&ccedil;&otilde;es.</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="audit-shell">
                            <div class="audit-card">
                                <div class="audit-header">
                                    <div>
                                        <small>Filtros</small>
                                        <h2 class="audit-title">Localizar eventos</h2>
                                    </div>
                                    <a class="audit-btn" href="novos.aspx?aba=todos"><i class="fa fa-layer-group"></i>Voltar para Todos</a>
                                </div>
                                <div class="audit-body">
                                    <div class="audit-grid">
                                        <div class="audit-field">
                                            <label class="audit-label" for="<%= ddlOrigem.ClientID %>">Origem</label>
                                            <asp:DropDownList ID="ddlOrigem" runat="server" CssClass="audit-select">
                                                <asp:ListItem Value="">Todas</asp:ListItem>
                                                <asp:ListItem Value="NOVO">Novos</asp:ListItem>
                                                <asp:ListItem Value="SEMINOVO">Seminovos</asp:ListItem>
                                                <asp:ListItem Value="LOJA">Lojas</asp:ListItem>
                                                <asp:ListItem Value="GERAL">Geral</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                        <div class="audit-field">
                                            <label class="audit-label" for="<%= txtVeiculo.ClientID %>">Ve&iacute;culo</label>
                                            <asp:TextBox ID="txtVeiculo" runat="server" CssClass="audit-input" MaxLength="50" autocomplete="off" placeholder="C&oacute;digo/id/chassi"></asp:TextBox>
                                        </div>
                                        <div class="audit-field">
                                            <label class="audit-label" for="<%= ddlPeriodo.ClientID %>">Per&iacute;odo</label>
                                            <asp:DropDownList ID="ddlPeriodo" runat="server" CssClass="audit-select">
                                                <asp:ListItem Value="7">&Uacute;ltimos 7 dias</asp:ListItem>
                                                <asp:ListItem Value="30" Selected="True">&Uacute;ltimos 30 dias</asp:ListItem>
                                                <asp:ListItem Value="90">&Uacute;ltimos 90 dias</asp:ListItem>
                                                <asp:ListItem Value="365">&Uacute;ltimo ano</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                        <div class="audit-field is-wide">
                                            <label class="audit-label" for="<%= txtBusca.ClientID %>">Busca</label>
                                            <asp:TextBox ID="txtBusca" runat="server" CssClass="audit-input" MaxLength="80" autocomplete="off" placeholder="A&ccedil;&atilde;o, usu&aacute;rio, detalhe, IP ou URL"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="audit-quick">
                                        <asp:LinkButton ID="btnHoje" runat="server" CssClass="audit-chip" CommandArgument="1" OnClick="FiltroRapido_Click"><i class="fa fa-calendar-day"></i>Hoje</asp:LinkButton>
                                        <asp:LinkButton ID="btnSete" runat="server" CssClass="audit-chip" CommandArgument="7" OnClick="FiltroRapido_Click"><i class="fa fa-calendar-week"></i>7 dias</asp:LinkButton>
                                        <asp:LinkButton ID="btnTrinta" runat="server" CssClass="audit-chip" CommandArgument="30" OnClick="FiltroRapido_Click"><i class="fa fa-calendar-alt"></i>30 dias</asp:LinkButton>
                                        <asp:LinkButton ID="btnNoventa" runat="server" CssClass="audit-chip" CommandArgument="90" OnClick="FiltroRapido_Click"><i class="fa fa-history"></i>90 dias</asp:LinkButton>
                                    </div>
                                    <div class="audit-actions">
                                        <asp:LinkButton ID="btnFiltrar" runat="server" CssClass="audit-btn audit-btn-primary" OnClick="btnFiltrar_Click"><i class="fa fa-filter"></i>Filtrar</asp:LinkButton>
                                        <asp:LinkButton ID="btnLimpar" runat="server" CssClass="audit-btn" OnClick="btnLimpar_Click"><i class="fa fa-eraser"></i>Limpar</asp:LinkButton>
                                        <asp:LinkButton ID="btnExportar" runat="server" CssClass="audit-btn" OnClick="btnExportar_Click"><i class="fa fa-file-export"></i>Exportar CSV</asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                            <div class="audit-card">
                                <div class="audit-header">
                                    <div>
                                        <small>Resumo</small>
                                        <h2 class="audit-title">Agrupamentos do filtro</h2>
                                    </div>
                                </div>
                                <div class="audit-body">
                                    <asp:Literal ID="litAgrupamentos" runat="server"></asp:Literal>
                                </div>
                            </div>
                            <div class="audit-card">
                                <div class="audit-header">
                                    <div>
                                        <small>Resultado</small>
                                        <h2 class="audit-title">Eventos encontrados</h2>
                                    </div>
                                    <asp:Literal ID="litResumo" runat="server"></asp:Literal>
                                </div>
                                <div class="audit-body audit-table-wrap">
                                    <asp:Literal ID="litTabela" runat="server"></asp:Literal>
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
