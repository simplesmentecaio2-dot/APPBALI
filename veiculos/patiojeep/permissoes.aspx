<%@ Page Language="C#" AutoEventWireup="true" CodeFile="permissoes.aspx.cs" Inherits="veiculos_patio_permissoes" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>PERMISS&Otilde;ES | P&aacute;tio</title>
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
        .perm-shell {
            display: grid;
            gap: 1rem;
        }

        .perm-panel {
            border: 1px solid #dbe4ef;
            border-radius: 20px;
            background: #fff;
            box-shadow: 0 14px 34px rgba(15, 23, 42, .08);
            overflow: hidden;
        }

        .perm-panel-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            padding: 1rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .perm-panel-header strong {
            color: #0f172a;
            font-size: 1.05rem;
        }

        .perm-lock {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(220px, 320px) auto;
            gap: .8rem;
            align-items: end;
            padding: 1.1rem;
        }

        .perm-lock-intro {
            color: #475569;
            font-weight: 700;
            line-height: 1.35;
        }

        .perm-form {
            display: grid;
            grid-template-columns: minmax(240px, 1fr) repeat(2, minmax(150px, auto)) auto auto;
            gap: .85rem;
            align-items: end;
            padding: 1rem;
        }

        .perm-filter {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: .75rem;
            align-items: end;
            padding: 1rem;
            border-top: 1px solid #eef2f7;
            background: #f8fafc;
        }

        .perm-form label,
        .perm-filter label,
        .perm-lock label {
            display: block;
            margin-bottom: .35rem;
            color: #475569;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: .04em;
            font-size: .75rem;
        }

        .perm-form .form-control,
        .perm-filter .form-control,
        .perm-lock .form-control {
            min-height: 44px;
            border-radius: 12px;
            font-weight: 800;
        }

        .perm-check {
            min-height: 44px;
            display: flex;
            align-items: center;
            gap: .5rem;
            padding: .5rem .75rem;
            border: 1px solid #dbe4ef;
            border-radius: 12px;
            background: #fff;
            font-weight: 900;
            color: #334155;
            white-space: nowrap;
        }

        .perm-check input {
            width: 18px;
            height: 18px;
            accent-color: #166534;
        }

        .perm-summary {
            display: grid;
            grid-template-columns: repeat(3, minmax(150px, 1fr));
            gap: .9rem;
        }

        .perm-card {
            padding: 1rem;
            border: 1px solid #dbe4ef;
            border-radius: 18px;
            background: #fff;
            box-shadow: 0 14px 34px rgba(15, 23, 42, .08);
        }

        .perm-card small {
            display: block;
            color: #64748b;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: .04em;
        }

        .perm-card strong {
            display: block;
            margin-top: .25rem;
            color: #0f172a;
            font-size: 1.7rem;
            line-height: 1;
        }

        .perm-table-wrap {
            padding: 0 1rem 1rem;
            overflow-x: auto;
        }

        .perm-table {
            width: 100%;
            min-width: 820px;
        }

        .perm-table th {
            white-space: nowrap;
            color: #475569;
            font-size: .76rem;
            text-transform: uppercase;
            letter-spacing: .04em;
        }

        .perm-badge {
            display: inline-flex;
            align-items: center;
            gap: .35rem;
            padding: .32rem .62rem;
            border-radius: 999px;
            font-weight: 900;
            font-size: .78rem;
            text-transform: uppercase;
        }

        .perm-badge-on {
            background: #dcfce7;
            color: #166534;
        }

        .perm-badge-off {
            background: #f1f5f9;
            color: #64748b;
        }

        .perm-actions {
            display: flex;
            gap: .4rem;
            flex-wrap: wrap;
        }

        .perm-message {
            display: grid;
            grid-template-columns: auto minmax(0, 1fr);
            gap: .85rem;
            align-items: center;
            padding: .9rem 1rem;
            margin-bottom: 1rem;
            border-radius: 16px;
            border: 1px solid #dbe4ef;
            background: #fff;
        }

        .perm-message i {
            width: 42px;
            height: 42px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 14px;
            background: #eef2ff;
            color: #1e3a8a;
        }

        .perm-message-success {
            border-color: #bbf7d0;
            background: #f0fdf4;
        }

        .perm-message-success i {
            background: #dcfce7;
            color: #15803d;
        }

        .perm-message-error {
            border-color: #fecaca;
            background: #fef2f2;
        }

        .perm-message-error i {
            background: #fee2e2;
            color: #991b1b;
        }

        @media (max-width: 980px) {
            .perm-lock,
            .perm-form,
            .perm-filter,
            .perm-summary {
                grid-template-columns: 1fr;
            }

            .perm-check {
                justify-content: flex-start;
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
                                <li><a href="./novos.aspx"><i class="metismenu-icon fas fa-car"></i>Novos</a></li>
                                <li><a href="./seminovos.aspx"><i class="metismenu-icon fas fa-car-side"></i>Seminovos</a></li>
                                <li><a href="./lojas.aspx"><i class="metismenu-icon fas fa-store"></i>Lojas</a></li>
                                <li><a href="./permissoes.aspx" class="mm-active"><i class="metismenu-icon fas fa-user-shield"></i>Permiss&otilde;es</a></li>
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
                                                <i class="fas fa-user-shield text-white"></i>
                                            </div>
                                            <div>
                                                <b>Permiss&otilde;es do p&aacute;tio</b>
                                                <div class="page-title-subheading">Controle simples para liberar registro e transfer&ecirc;ncia de ve&iacute;culos.</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <asp:Panel ID="pnlMensagem" runat="server" CssClass="perm-message" Visible="false">
                                    <i id="iconeMensagem" runat="server" class="fa fa-info-circle"></i>
                                    <div>
                                        <strong><asp:Literal ID="litMensagemTitulo" runat="server"></asp:Literal></strong>
                                        <div><asp:Literal ID="litMensagemTexto" runat="server"></asp:Literal></div>
                                    </div>
                                </asp:Panel>

                                <asp:Panel ID="pnlBloqueio" runat="server" CssClass="perm-panel">
                                    <div class="perm-panel-header">
                                        <strong><i class="fa fa-lock mr-1"></i> &Aacute;rea protegida</strong>
                                    </div>
                                    <div class="perm-lock">
                                        <div class="perm-lock-intro">
                                            Esta tela altera quem pode registrar e transferir ve&iacute;culos no p&aacute;tio. Informe a senha de libera&ccedil;&atilde;o para continuar.
                                        </div>
                                        <div>
                                            <label>Senha de libera&ccedil;&atilde;o</label>
                                            <asp:TextBox ID="txtSenhaAcesso" runat="server" CssClass="form-control" TextMode="Password" autocomplete="new-password" placeholder="Digite a senha"></asp:TextBox>
                                        </div>
                                        <asp:LinkButton ID="btnDesbloquear" runat="server" CssClass="btn btn-success" OnClick="btnDesbloquear_Click"><i class="fa fa-unlock mr-1"></i> Liberar</asp:LinkButton>
                                    </div>
                                </asp:Panel>

                                <asp:Panel ID="pnlConteudo" runat="server" CssClass="perm-shell" Visible="false">
                                    <asp:Literal ID="litResumo" runat="server"></asp:Literal>

                                    <div class="perm-panel">
                                        <div class="perm-panel-header">
                                            <strong><i class="fa fa-user-cog mr-1"></i> Usu&aacute;rio e permiss&otilde;es</strong>
                                            <asp:LinkButton ID="btnBloquearTela" runat="server" CssClass="btn btn-outline-secondary" OnClick="btnBloquearTela_Click" CausesValidation="false"><i class="fa fa-lock mr-1"></i> Bloquear tela</asp:LinkButton>
                                        </div>
                                        <asp:HiddenField ID="hfUsuarioOriginal" runat="server" />
                                        <div class="perm-form">
                                            <div>
                                                <label>Usu&aacute;rio</label>
                                                <asp:TextBox ID="txtUsuario" runat="server" CssClass="form-control" MaxLength="100" autocomplete="off" placeholder="Ex.: MARCIO"></asp:TextBox>
                                            </div>
                                            <label class="perm-check">
                                                <asp:CheckBox ID="chkRegistrar" runat="server" />
                                                Registrar
                                            </label>
                                            <label class="perm-check">
                                                <asp:CheckBox ID="chkTransferir" runat="server" />
                                                Transferir
                                            </label>
                                            <asp:LinkButton ID="btnSalvar" runat="server" CssClass="btn btn-success" OnClick="btnSalvar_Click"><i class="fa fa-save mr-1"></i> Salvar</asp:LinkButton>
                                            <asp:LinkButton ID="btnLimpar" runat="server" CssClass="btn btn-outline-secondary" OnClick="btnLimpar_Click" CausesValidation="false"><i class="fa fa-eraser mr-1"></i> Limpar</asp:LinkButton>
                                        </div>
                                        <div class="perm-filter">
                                            <div>
                                                <label>Filtro</label>
                                                <asp:TextBox ID="txtFiltro" runat="server" CssClass="form-control" autocomplete="off" placeholder="Buscar usu&aacute;rio"></asp:TextBox>
                                            </div>
                                            <asp:LinkButton ID="btnFiltrar" runat="server" CssClass="btn btn-dark" OnClick="btnFiltrar_Click"><i class="fa fa-search mr-1"></i> Filtrar</asp:LinkButton>
                                        </div>
                                        <div class="perm-table-wrap">
                                            <asp:GridView ID="gridPermissoes" runat="server" AutoGenerateColumns="false" CssClass="table table-striped table-hover perm-table" GridLines="None" OnRowCommand="gridPermissoes_RowCommand">
                                                <Columns>
                                                    <asp:BoundField DataField="fun_cad" HeaderText="Usu&aacute;rio" />
                                                    <asp:TemplateField HeaderText="Registrar">
                                                        <ItemTemplate>
                                                            <span class='<%# Convert.ToBoolean(Eval("registrar")) ? "perm-badge perm-badge-on" : "perm-badge perm-badge-off" %>'>
                                                                <i class='<%# Convert.ToBoolean(Eval("registrar")) ? "fa fa-check" : "fa fa-minus" %>'></i>
                                                                <%# Convert.ToBoolean(Eval("registrar")) ? "Liberado" : "Sem acesso" %>
                                                            </span>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Transferir">
                                                        <ItemTemplate>
                                                            <span class='<%# Convert.ToBoolean(Eval("transferir")) ? "perm-badge perm-badge-on" : "perm-badge perm-badge-off" %>'>
                                                                <i class='<%# Convert.ToBoolean(Eval("transferir")) ? "fa fa-check" : "fa fa-minus" %>'></i>
                                                                <%# Convert.ToBoolean(Eval("transferir")) ? "Liberado" : "Sem acesso" %>
                                                            </span>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="A&ccedil;&otilde;es">
                                                        <ItemTemplate>
                                                            <div class="perm-actions">
                                                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-primary" CommandName="EditarUsuario" CommandArgument='<%# Eval("fun_cad") %>'><i class="fa fa-pen mr-1"></i>Editar</asp:LinkButton>
                                                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="RevogarUsuario" CommandArgument='<%# Eval("fun_cad") %>' OnClientClick="return confirm('Revogar todas as permissões deste usuário?');"><i class="fa fa-ban mr-1"></i>Revogar</asp:LinkButton>
                                                            </div>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                                <EmptyDataTemplate>
                                                    <div class="alert alert-light mb-0">Nenhum usu&aacute;rio encontrado.</div>
                                                </EmptyDataTemplate>
                                            </asp:GridView>
                                        </div>
                                    </div>

                                    <div class="perm-panel">
                                        <div class="perm-panel-header">
                                            <strong><i class="fa fa-history mr-1"></i> &Uacute;ltimas altera&ccedil;&otilde;es</strong>
                                        </div>
                                        <div class="perm-table-wrap">
                                            <asp:Literal ID="litLogs" runat="server"></asp:Literal>
                                        </div>
                                    </div>
                                </asp:Panel>
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
    <script src="./assets/js/patio-jeep-ux.js?v=20260709-1"></script>
</body>
</html>
