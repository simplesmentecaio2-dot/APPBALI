<%@ Page Language="C#" AutoEventWireup="true" CodeFile="usuarios.aspx.cs" Inherits="tecnologia_usuarios" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Usuários | Tecnologia</title>
    <link href="../css/bali-tecnologia.css?v=20260627-tech01" rel="stylesheet" />
</head>
<body class="bali-tech-page">
    <form id="form1" runat="server" autocomplete="off">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <header class="tech-topbar">
            <a class="tech-brand" href="Default.aspx" aria-label="Voltar para tecnologia">
                <img src="../img/logobali.png?v=20260624-logo2" alt="Bali" />
                <span>APP</span>
            </a>
            <div class="tech-user">
                <span>Tecnologia</span>
                <strong><asp:Label ID="lblUsuario" runat="server" /></strong>
                <small>Perfil: <asp:Label ID="lblTipo" runat="server" /></small>
            </div>
            <nav class="tech-actions" aria-label="Ações rápidas">
                <a href="Default.aspx">Voltar</a>
                <a href="../login.aspx?sair=1">Sair</a>
            </nav>
        </header>

        <main class="tech-main">
            <section class="tech-hero">
                <div>
                    <span class="tech-eyebrow">Permissões</span>
                    <h1>Usuários</h1>
                    <p>Consulte usuários, cadastre novos acessos e ajuste sistemas/perfis em um fluxo mais seguro.</p>
                </div>
                <label class="tech-search" for="techSearchUsers">
                    <span>Buscar usuário</span>
                    <input id="techSearchUsers" type="search" autocomplete="off" autocapitalize="off" spellcheck="false" placeholder="Ex.: nome, e-mail, perfil, ativo" />
                </label>
            </section>

            <asp:TabContainer ID="TabContainerUsuarios" CssClass="tech-tabs" Width="100%" runat="server" ActiveTabIndex="0">
                <asp:TabPanel ID="TabPanelConsulta" runat="server" HeaderText="">
                    <HeaderTemplate>Consultar</HeaderTemplate>
                    <ContentTemplate>
                        <section class="tech-panel">
                            <div class="tech-panel-head">
                                <div>
                                    <span class="tech-panel-kicker">Consulta</span>
                                    <h2>Usuários cadastrados</h2>
                                    <p>Selecione um usuário para carregar edição, sistemas liberados e perfis vinculados.</p>
                                </div>
                            </div>

                            <asp:GridView ID="gvConsultaUsuarios" runat="server" AutoGenerateColumns="False" CssClass="tech-gridview" DataKeyNames="Login" DataSourceID="sqldsConsultaUsuarios" AllowPaging="True" PageSize="20" GridLines="None" OnSelectedIndexChanged="gvConsultaUsuarios_SelectedIndexChanged" EmptyDataText="Nenhum usuário encontrado.">
                                <Columns>
                                    <asp:CommandField ShowSelectButton="True" SelectText="Selecionar" />
                                    <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" />
                                    <asp:BoundField DataField="Login" HeaderText="Login" ReadOnly="True" SortExpression="Login" />
                                    <asp:BoundField DataField="tipo" HeaderText="Tipo" SortExpression="tipo" />
                                    <asp:BoundField DataField="Ativo" HeaderText="Ativo" ReadOnly="True" SortExpression="Ativo" />
                                </Columns>
                                <PagerStyle HorizontalAlign="Center" />
                            </asp:GridView>

                            <div id="techEmptyUsers" class="tech-empty" hidden>Nenhum usuário encontrado para a busca informada.</div>
                            <asp:SqlDataSource ID="sqldsConsultaUsuarios" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="app_select_usuarios" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
                        </section>
                    </ContentTemplate>
                </asp:TabPanel>

                <asp:TabPanel ID="TabPanelCadastro" runat="server" HeaderText="">
                    <HeaderTemplate>Cadastrar</HeaderTemplate>
                    <ContentTemplate>
                        <section class="tech-panel">
                            <div class="tech-panel-head">
                                <div>
                                    <span class="tech-panel-kicker">Novo acesso</span>
                                    <h2>Cadastrar usuário</h2>
                                    <p>Informe nome, e-mail, tipo de usuário, situação, senha inicial e sistemas liberados.</p>
                                </div>
                            </div>

                            <div class="tech-form-grid">
                                <div class="tech-field">
                                    <span>Nome</span>
                                    <asp:TextBox ID="txtNomeUsuario" runat="server" MaxLength="80"></asp:TextBox>
                                </div>
                                <div class="tech-field">
                                    <span>E-mail / login</span>
                                    <asp:TextBox ID="txtEmail" runat="server" MaxLength="80"></asp:TextBox>
                                </div>
                                <div class="tech-field">
                                    <span>Tipo</span>
                                    <asp:DropDownList ID="ddlTipo" runat="server">
                                        <asp:ListItem> -- Tipo -- </asp:ListItem>
                                        <asp:ListItem>ADMINISTRADOR</asp:ListItem>
                                        <asp:ListItem>SUPERVISOR</asp:ListItem>
                                        <asp:ListItem>USUÁRIO</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="tech-field">
                                    <span>Situação</span>
                                    <div class="tech-radio-row">
                                        <asp:RadioButton ID="rbtnAtivo" runat="server" Checked="True" GroupName="ativo" Text="Ativo" />
                                        <asp:RadioButton ID="rbtnInativo" runat="server" GroupName="ativo" Text="Inativo" />
                                    </div>
                                </div>
                                <div class="tech-field">
                                    <span>Senha</span>
                                    <asp:TextBox ID="txtSenha" runat="server" TextMode="Password" MaxLength="20"></asp:TextBox>
                                </div>
                                <div class="tech-field">
                                    <span>Confirmação</span>
                                    <asp:TextBox ID="txtConfirmacao" runat="server" TextMode="Password" MaxLength="20"></asp:TextBox>
                                </div>
                                <div class="tech-check-panel">
                                    <span class="tech-check-title">Sistemas liberados</span>
                                    <asp:CheckBoxList ID="CheckBoxListSistemas" runat="server" DataSourceID="sqldsSistemas" DataTextField="nome" DataValueField="id_sistema" RepeatColumns="2"></asp:CheckBoxList>
                                    <asp:SqlDataSource ID="sqldsSistemas" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="app_select_sistemas" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
                                </div>
                                <div class="tech-actions-row">
                                    <asp:Button ID="btnSalvar" runat="server" OnClick="btnSalvar_Click" Text="Salvar usuário" />
                                </div>
                            </div>
                        </section>
                    </ContentTemplate>
                </asp:TabPanel>

                <asp:TabPanel ID="TabPanelAlterar" runat="server" HeaderText="">
                    <HeaderTemplate>Alterar</HeaderTemplate>
                    <ContentTemplate>
                        <section class="tech-panel">
                            <div class="tech-panel-head">
                                <div>
                                    <span class="tech-panel-kicker">Manutenção</span>
                                    <h2>Alterar usuário</h2>
                                    <p>Selecione primeiro um usuário na aba consulta para editar dados, senha e sistemas.</p>
                                </div>
                            </div>

                            <div class="tech-form-grid">
                                <div class="tech-field">
                                    <span>Nome</span>
                                    <asp:TextBox ID="txtNomeAlterar" runat="server" MaxLength="80"></asp:TextBox>
                                </div>
                                <div class="tech-field">
                                    <span>E-mail / login</span>
                                    <asp:TextBox ID="txtEmailAlterar" ReadOnly="True" runat="server"></asp:TextBox>
                                </div>
                                <div class="tech-field">
                                    <span>Tipo</span>
                                    <asp:DropDownList ID="ddlTipoAlterar" runat="server">
                                        <asp:ListItem> -- Tipo -- </asp:ListItem>
                                        <asp:ListItem>ADMINISTRADOR</asp:ListItem>
                                        <asp:ListItem>SUPERVISOR</asp:ListItem>
                                        <asp:ListItem>USUÁRIO</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="tech-field">
                                    <span>Situação</span>
                                    <div class="tech-radio-row">
                                        <asp:RadioButton ID="rbtnAtivoAlterar" runat="server" Checked="True" GroupName="ativoAlterar" Text="Ativo" />
                                        <asp:RadioButton ID="rbtnInativoAlterar" runat="server" GroupName="ativoAlterar" Text="Inativo" />
                                    </div>
                                </div>
                                <div class="tech-field">
                                    <span>Nova senha</span>
                                    <asp:TextBox ID="txtSenhaAlterar" runat="server" TextMode="Password" MaxLength="20"></asp:TextBox>
                                </div>
                                <div class="tech-field">
                                    <span>Confirmação</span>
                                    <asp:TextBox ID="txtConfirmacaoAlterar" runat="server" TextMode="Password" MaxLength="20"></asp:TextBox>
                                </div>
                                <div class="tech-actions-row">
                                    <asp:Button ID="btnAlterarSenha" runat="server" Text="Alterar senha" OnClick="btnAlterarSenha_Click" />
                                </div>
                                <div class="tech-check-panel">
                                    <span class="tech-check-title">Sistemas liberados</span>
                                    <asp:CheckBoxList ID="CheckBoxListSistemasAlterar" runat="server" DataSourceID="sqldsSistemasAlterar" DataTextField="nome" DataValueField="id_sistema" RepeatColumns="2"></asp:CheckBoxList>
                                    <asp:SqlDataSource ID="sqldsSistemasAlterar" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="app_select_sistemas" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
                                </div>
                                <div class="tech-actions-row">
                                    <asp:Button ID="btnAlterar" runat="server" Text="Salvar alterações" OnClick="btnAlterar_Click" />
                                </div>
                            </div>
                        </section>
                    </ContentTemplate>
                </asp:TabPanel>

                <asp:TabPanel ID="TabPanelSistemaPerfil" runat="server" HeaderText="">
                    <HeaderTemplate>Perfil</HeaderTemplate>
                    <ContentTemplate>
                        <section class="tech-split">
                            <div class="tech-panel">
                                <div class="tech-panel-head">
                                    <div>
                                        <span class="tech-panel-kicker">Perfil por sistema</span>
                                        <h2>Ajustar perfil</h2>
                                        <p>Após selecionar o usuário, escolha o sistema e o perfil operacional permitido.</p>
                                    </div>
                                </div>

                                <div class="tech-form-grid is-narrow">
                                    <div class="tech-field is-full">
                                        <span>Nome</span>
                                        <asp:TextBox ID="txtNomePerfil" ReadOnly="True" runat="server"></asp:TextBox>
                                    </div>
                                    <div class="tech-field is-full">
                                        <span>E-mail / login</span>
                                        <asp:TextBox ID="txtEmailAlterarPerfil" ReadOnly="True" runat="server"></asp:TextBox>
                                    </div>
                                    <div class="tech-field">
                                        <span>Sistema</span>
                                        <asp:DropDownList ID="ddlUsuarioSistema" runat="server" DataSourceID="sqldsSistemaUsuario" DataTextField="nome" DataValueField="id_sistema" AutoPostBack="True"></asp:DropDownList>
                                        <asp:SqlDataSource ID="sqldsSistemaUsuario" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="app_select_usario_sistema_alterar" SelectCommandType="StoredProcedure">
                                            <SelectParameters>
                                                <asp:ControlParameter ControlID="txtEmailAlterarPerfil" Name="id_usuario" PropertyName="Text" Type="String" />
                                            </SelectParameters>
                                        </asp:SqlDataSource>
                                    </div>
                                    <div class="tech-field">
                                        <span>Perfil</span>
                                        <asp:DropDownList ID="ddlSistemaperfil" runat="server" DataSourceID="sqldsSistemaPerfil" DataTextField="id_perfil" DataValueField="id_perfil"></asp:DropDownList>
                                        <asp:SqlDataSource ID="sqldsSistemaPerfil" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="app_select_sistema_perfil" SelectCommandType="StoredProcedure">
                                            <SelectParameters>
                                                <asp:ControlParameter ControlID="ddlUsuarioSistema" Name="id_sistema" PropertyName="SelectedValue" Type="Int32" />
                                            </SelectParameters>
                                        </asp:SqlDataSource>
                                    </div>
                                    <div class="tech-actions-row">
                                        <asp:Button ID="btnAlterarPerfil" runat="server" Text="Alterar perfil" OnClick="btnAlterarPerfil_Click" />
                                    </div>
                                </div>
                            </div>

                            <div class="tech-panel">
                                <div class="tech-panel-head">
                                    <div>
                                        <span class="tech-panel-kicker">Permissões atuais</span>
                                        <h2>Sistemas vinculados</h2>
                                        <p>Resumo dos sistemas e perfis carregados para o usuário selecionado.</p>
                                    </div>
                                </div>

                                <asp:DataList ID="dlPerfilSistemas" runat="server" CssClass="tech-profile-list" DataSourceID="sqldsUsuarioSistemaPerfil" RepeatLayout="Flow">
                                    <ItemTemplate>
                                        <article class="tech-profile-row">
                                            <span>
                                                <span class="tech-row-kicker">ID</span>
                                                <strong class="tech-row-value"><%# Eval("id_sistema") %></strong>
                                            </span>
                                            <span>
                                                <span class="tech-row-kicker">Sistema</span>
                                                <strong class="tech-row-value"><%# Eval("nome") %></strong>
                                            </span>
                                            <span>
                                                <span class="tech-row-kicker">Perfil</span>
                                                <strong class="tech-row-value"><%# Eval("perfil") %></strong>
                                            </span>
                                        </article>
                                    </ItemTemplate>
                                </asp:DataList>
                                <asp:SqlDataSource ID="sqldsUsuarioSistemaPerfil" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="app_select_usario_sistema_perfil" SelectCommandType="StoredProcedure">
                                    <SelectParameters>
                                        <asp:ControlParameter ControlID="txtEmailAlterarPerfil" Name="id_usuario" PropertyName="Text" Type="String" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                            </div>
                        </section>
                    </ContentTemplate>
                </asp:TabPanel>
            </asp:TabContainer>
        </main>
    </form>
    <script src="../js/bali-tecnologia.js?v=20260627-tech01"></script>
</body>
</html>
