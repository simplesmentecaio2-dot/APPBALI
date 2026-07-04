<%@ Page Language="C#" AutoEventWireup="true" CodeFile="lojas.aspx.cs" Inherits="veiculos_patio_lojas" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>LOJAS | Pátio</title>
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
        .lojas-shell {
            display: grid;
            gap: 1rem;
        }

        .lojas-summary {
            display: grid;
            grid-template-columns: repeat(3, minmax(150px, 1fr));
            gap: .9rem;
        }

        .lojas-card {
            padding: 1rem;
            border: 1px solid #dbe4ef;
            border-radius: 18px;
            background: #fff;
            box-shadow: 0 14px 34px rgba(15, 23, 42, .08);
        }

        .lojas-card small {
            display: block;
            color: #64748b;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: .04em;
        }

        .lojas-card strong {
            display: block;
            margin-top: .25rem;
            color: #0f172a;
            font-size: 1.7rem;
            line-height: 1;
        }

        .lojas-panel {
            border: 1px solid #dbe4ef;
            border-radius: 20px;
            background: #fff;
            box-shadow: 0 14px 34px rgba(15, 23, 42, .08);
            overflow: hidden;
        }

        .lojas-panel-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            padding: 1rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .lojas-panel-header strong {
            color: #0f172a;
            font-size: 1.05rem;
        }

        .lojas-form {
            display: grid;
            grid-template-columns: minmax(0, 1.2fr) minmax(220px, .7fr) auto auto;
            gap: .75rem;
            align-items: end;
            padding: 1rem;
        }

        .lojas-form label,
        .lojas-filter label {
            display: block;
            margin-bottom: .35rem;
            color: #475569;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: .04em;
            font-size: .75rem;
        }

        .lojas-form .form-control,
        .lojas-filter .form-control {
            min-height: 44px;
            border-radius: 12px;
            font-weight: 800;
        }

        .lojas-filter {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto auto;
            gap: .75rem;
            align-items: end;
            padding: 1rem;
            border-top: 1px solid #eef2f7;
            background: #f8fafc;
        }

        .lojas-table-wrap {
            padding: 0 1rem 1rem;
            overflow-x: auto;
        }

        .lojas-table {
            width: 100%;
            min-width: 720px;
        }

        .lojas-table th {
            white-space: nowrap;
            color: #475569;
            font-size: .76rem;
            text-transform: uppercase;
            letter-spacing: .04em;
        }

        .lojas-badge {
            display: inline-flex;
            align-items: center;
            padding: .32rem .62rem;
            border-radius: 999px;
            font-weight: 900;
            font-size: .78rem;
            text-transform: uppercase;
        }

        .lojas-badge-active {
            background: #dcfce7;
            color: #166534;
        }

        .lojas-badge-inactive {
            background: #fee2e2;
            color: #991b1b;
        }

        .lojas-actions {
            display: flex;
            gap: .4rem;
            flex-wrap: wrap;
        }

        .lojas-message {
            display: grid;
            grid-template-columns: auto minmax(0, 1fr);
            gap: .85rem;
            align-items: center;
            padding: .9rem 1rem;
            border-radius: 16px;
            border: 1px solid #dbe4ef;
            background: #fff;
        }

        .lojas-message i {
            width: 42px;
            height: 42px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 14px;
            background: #eef2ff;
            color: #1e3a8a;
        }

        .lojas-message-success {
            border-color: #bbf7d0;
            background: #f0fdf4;
        }

        .lojas-message-success i {
            background: #dcfce7;
            color: #15803d;
        }

        .lojas-message-error {
            border-color: #fecaca;
            background: #fef2f2;
        }

        .lojas-message-error i {
            background: #fee2e2;
            color: #991b1b;
        }

        @media (max-width: 900px) {
            .lojas-summary,
            .lojas-form,
            .lojas-filter {
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
                                <li><a href="./"><i class="metismenu-icon fas fa-home"></i>Início</a></li>
                                <li class="app-sidebar__heading">Funções</li>
                                <li><a href="./registrar.aspx"><i class="metismenu-icon fa fa-folder-plus"></i>Registrar</a></li>
                                <li><a href="./transferir.aspx"><i class="metismenu-icon fas fa-exchange-alt"></i>Transferir</a></li>
                                <li><a href="./historico.aspx"><i class="metismenu-icon fas fa-history"></i>Consultar</a></li>
                                <li><a href="./relatorios.aspx"><i class="metismenu-icon fas fa-chart-line"></i>Relatórios</a></li>
                                <li><a href="./lojas.aspx" class="mm-active"><i class="metismenu-icon fas fa-store"></i>Lojas</a></li>
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
                                                <i class="fas fa-store text-white"></i>
                                            </div>
                                            <div>
                                                <b>Cadastro de lojas</b>
                                                <div class="page-title-subheading">Inclua lojas do pátio, edite descrições e controle lojas ativas.</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <asp:Panel ID="pnlMensagem" runat="server" CssClass="lojas-message" Visible="false">
                                    <i id="iconeMensagem" runat="server" class="fa fa-info-circle"></i>
                                    <div>
                                        <strong><asp:Literal ID="litMensagemTitulo" runat="server"></asp:Literal></strong>
                                        <div><asp:Literal ID="litMensagemTexto" runat="server"></asp:Literal></div>
                                    </div>
                                </asp:Panel>
                                <div class="lojas-shell">
                                    <asp:Literal ID="litResumo" runat="server"></asp:Literal>
                                    <div class="lojas-panel">
                                        <div class="lojas-panel-header">
                                            <strong><i class="fa fa-store mr-1"></i> Manutenção de lojas</strong>
                                            <asp:LinkButton ID="btnNovo" runat="server" CssClass="btn btn-light" OnClick="btnNovo_Click"><i class="fa fa-plus mr-1"></i> Novo</asp:LinkButton>
                                        </div>
                                        <asp:HiddenField ID="hfLojaId" runat="server" />
                                        <div class="lojas-form">
                                            <div>
                                                <label>Nome da loja</label>
                                                <asp:TextBox ID="txtDescricao" runat="server" CssClass="form-control" MaxLength="50" placeholder="Ex.: Park Sul"></asp:TextBox>
                                            </div>
                                            <div>
                                                <label>Senha de manutenção</label>
                                                <asp:TextBox ID="txtSenha" runat="server" CssClass="form-control" TextMode="Password" placeholder="Obrigatória para editar/ativar/desativar"></asp:TextBox>
                                            </div>
                                            <asp:LinkButton ID="btnSalvar" runat="server" CssClass="btn btn-success" OnClick="btnSalvar_Click"><i class="fa fa-save mr-1"></i> Salvar</asp:LinkButton>
                                            <asp:LinkButton ID="btnCancelar" runat="server" CssClass="btn btn-outline-secondary" OnClick="btnCancelar_Click"><i class="fa fa-times mr-1"></i> Cancelar</asp:LinkButton>
                                        </div>
                                        <div class="lojas-filter">
                                            <div>
                                                <label>Filtro</label>
                                                <asp:TextBox ID="txtFiltro" runat="server" CssClass="form-control" placeholder="Buscar por nome ou código"></asp:TextBox>
                                            </div>
                                            <label class="mb-0">
                                                <asp:CheckBox ID="chkInativas" runat="server" />
                                                Mostrar inativas
                                            </label>
                                            <asp:LinkButton ID="btnFiltrar" runat="server" CssClass="btn btn-dark" OnClick="btnFiltrar_Click"><i class="fa fa-search mr-1"></i> Filtrar</asp:LinkButton>
                                        </div>
                                        <div class="lojas-table-wrap">
                                            <asp:GridView ID="gridLojas" runat="server" AutoGenerateColumns="false" CssClass="table table-striped table-hover lojas-table" GridLines="None" OnRowCommand="gridLojas_RowCommand">
                                                <Columns>
                                                    <asp:BoundField DataField="id" HeaderText="Código" />
                                                    <asp:BoundField DataField="ds" HeaderText="Loja" />
                                                    <asp:TemplateField HeaderText="Situação">
                                                        <ItemTemplate>
                                                            <span class='<%# Convert.ToBoolean(Eval("ativo")) ? "lojas-badge lojas-badge-active" : "lojas-badge lojas-badge-inactive" %>'>
                                                                <%# Convert.ToBoolean(Eval("ativo")) ? "Ativa" : "Inativa" %>
                                                            </span>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Ações">
                                                        <ItemTemplate>
                                                            <div class="lojas-actions">
                                                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-primary" CommandName="EditarLoja" CommandArgument='<%# Eval("id") %>'><i class="fa fa-pen mr-1"></i>Editar</asp:LinkButton>
                                                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-success" CommandName="AtivarLoja" CommandArgument='<%# Eval("id") %>' Visible='<%# !Convert.ToBoolean(Eval("ativo")) %>'><i class="fa fa-check mr-1"></i>Ativar</asp:LinkButton>
                                                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DesativarLoja" CommandArgument='<%# Eval("id") %>' Visible='<%# Convert.ToBoolean(Eval("ativo")) %>'><i class="fa fa-ban mr-1"></i>Desativar</asp:LinkButton>
                                                            </div>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                                <EmptyDataTemplate>
                                                    <div class="alert alert-light mb-0">Nenhuma loja encontrada para o filtro informado.</div>
                                                </EmptyDataTemplate>
                                            </asp:GridView>
                                        </div>
                                    </div>
                                    <div class="lojas-panel">
                                        <div class="lojas-panel-header">
                                            <strong><i class="fa fa-history mr-1"></i> Últimas alterações</strong>
                                        </div>
                                        <div class="lojas-table-wrap">
                                            <asp:Literal ID="litLogs" runat="server"></asp:Literal>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
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
