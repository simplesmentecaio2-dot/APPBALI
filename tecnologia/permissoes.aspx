<%@ Page Language="C#" AutoEventWireup="true" CodeFile="permissoes.aspx.cs" Inherits="tecnologia_permissoes" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Permiss&otilde;es | Tecnologia</title>
    <link href="../css/bali-tecnologia.css?v=20260629-permissoes01" rel="stylesheet" />
</head>
<body class="bali-tech-page">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <header class="tech-topbar">
            <a class="tech-brand" href="Default.aspx" aria-label="Voltar para tecnologia">
                <img src="../img/logobali.png?v=20260624-logo2" alt="Bali" />
                <span>APP</span>
            </a>
            <div class="tech-user">
                <span>Tecnologia</span>
                <strong><asp:Label ID="lblUsuario" runat="server" /></strong>
                <small>C&oacute;digo: <asp:Label ID="lblCodigo" runat="server" /></small>
            </div>
            <nav class="tech-actions" aria-label="A&ccedil;&otilde;es r&aacute;pidas">
                <a href="Default.aspx">Voltar</a>
                <a href="../login.aspx?sair=1">Sair</a>
            </nav>
        </header>

        <main class="tech-main">
            <section class="tech-hero">
                <div>
                    <span class="tech-eyebrow">Acessos &middot; modo permissivo</span>
                    <h1>Gest&atilde;o de permiss&otilde;es</h1>
                    <p>Todos continuam com acesso normal. O sistema bloqueia somente usu&aacute;rios e recursos que tiverem regra ativa de bloqueio.</p>
                </div>
                <div class="permission-mode-card">
                    <span>Regra atual</span>
                    <strong>Libera por padr&atilde;o</strong>
                    <small>Use bloqueios pontuais para restringir p&aacute;ginas sem impactar os demais usu&aacute;rios.</small>
                </div>
            </section>

            <asp:Panel ID="pnlMensagem" runat="server" Visible="false" CssClass="tech-alert">
                <asp:Literal ID="litMensagem" runat="server" />
            </asp:Panel>

            <section class="tech-session-summary permission-summary">
                <article>
                    <span>Usu&aacute;rios locais</span>
                    <strong><asp:Literal ID="litUsuariosLocais" runat="server" /></strong>
                    <small>Espelho criado no login</small>
                </article>
                <article>
                    <span>Bloqueios ativos</span>
                    <strong><asp:Literal ID="litBloqueiosAtivos" runat="server" /></strong>
                    <small>Regras que restringem acesso</small>
                </article>
                <article>
                    <span>Libera&ccedil;&otilde;es registradas</span>
                    <strong><asp:Literal ID="litLiberacoesAtivas" runat="server" /></strong>
                    <small>Preparado para uso futuro</small>
                </article>
                <article>
                    <span>Acessos negados</span>
                    <strong><asp:Literal ID="litAcessosNegados" runat="server" /></strong>
                    <small>&Uacute;ltimos 7 dias</small>
                </article>
            </section>

            <section class="tech-panel">
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Nova regra</span>
                        <h2>Bloquear ou liberar acesso</h2>
                        <p>Escolha um usu&aacute;rio, recurso e a&ccedil;&atilde;o. Para a navega&ccedil;&atilde;o das p&aacute;ginas, use a a&ccedil;&atilde;o Visualizar.</p>
                    </div>
                </div>

                <div class="permission-form-grid">
                    <div class="tech-field is-full">
                        <span>Usu&aacute;rio</span>
                        <asp:DropDownList ID="ddlUsuarioLocal" runat="server"></asp:DropDownList>
                    </div>
                    <div class="tech-field">
                        <span>Recurso comum</span>
                        <asp:DropDownList ID="ddlRecurso" runat="server">
                            <asp:ListItem Value="/Default.aspx">P&aacute;gina inicial</asp:ListItem>
                            <asp:ListItem Value="/tecnologia/Default.aspx">Tecnologia - Central</asp:ListItem>
                            <asp:ListItem Value="/tecnologia/usuarios.aspx">Tecnologia - Usu&aacute;rios</asp:ListItem>
                            <asp:ListItem Value="/tecnologia/sistemas.aspx">Tecnologia - Sistemas</asp:ListItem>
                            <asp:ListItem Value="/tecnologia/sessoes.aspx">Tecnologia - Sess&otilde;es</asp:ListItem>
                            <asp:ListItem Value="/tecnologia/permissoes.aspx">Tecnologia - Permiss&otilde;es</asp:ListItem>
                            <asp:ListItem Value="/CI/default.aspx">CI - Comunica&ccedil;&atilde;o Interna</asp:ListItem>
                            <asp:ListItem Value="/RAMAIS/default.aspx">Ramais</asp:ListItem>
                            <asp:ListItem Value="/veiculos/Default.aspx">Fiat - Central</asp:ListItem>
                            <asp:ListItem Value="/jeep/principal.aspx">Jeep - Central</asp:ListItem>
                            <asp:ListItem Value="/byd/principal.aspx">BYD - Central</asp:ListItem>
                            <asp:ListItem Value="/veiculos/contrato.aspx">Fiat - Contratos</asp:ListItem>
                            <asp:ListItem Value="/jeep/contrato.aspx">Jeep - Contratos</asp:ListItem>
                            <asp:ListItem Value="/byd/contrato.aspx">BYD - Contratos</asp:ListItem>
                            <asp:ListItem Value="/minhas-vendas.aspx">Minhas vendas</asp:ListItem>
                            <asp:ListItem Value="/admfinanceiro/Default.aspx">Adm. Financeiro - Central</asp:ListItem>
                            <asp:ListItem Value="/admfinanceiro/Recibo/recibo.aspx">Adm. Financeiro - Recibo</asp:ListItem>
                            <asp:ListItem Value="/veiculos/*">Fiat - Toda a pasta</asp:ListItem>
                            <asp:ListItem Value="/jeep/*">Jeep - Toda a pasta</asp:ListItem>
                            <asp:ListItem Value="/byd/*">BYD - Toda a pasta</asp:ListItem>
                            <asp:ListItem Value="/tecnologia/*">Tecnologia - Toda a pasta</asp:ListItem>
                            <asp:ListItem Value="*">Todos os recursos</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="tech-field">
                        <span>Recurso manual opcional</span>
                        <asp:TextBox ID="txtRecursoManual" runat="server" MaxLength="260" placeholder="/pasta/pagina.aspx ou /pasta/*"></asp:TextBox>
                    </div>
                    <div class="tech-field">
                        <span>A&ccedil;&atilde;o</span>
                        <asp:DropDownList ID="ddlAcao" runat="server">
                            <asp:ListItem Value="VISUALIZAR">Visualizar</asp:ListItem>
                            <asp:ListItem Value="CRIAR">Criar</asp:ListItem>
                            <asp:ListItem Value="EDITAR">Editar</asp:ListItem>
                            <asp:ListItem Value="EXCLUIR">Excluir</asp:ListItem>
                            <asp:ListItem Value="IMPRIMIR">Imprimir</asp:ListItem>
                            <asp:ListItem Value="EXPORTAR">Exportar</asp:ListItem>
                            <asp:ListItem Value="ADMINISTRAR">Administrar</asp:ListItem>
                            <asp:ListItem Value="*">Todas</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="tech-field">
                        <span>Tipo de regra</span>
                        <asp:DropDownList ID="ddlTipoRegra" runat="server">
                            <asp:ListItem Value="bloquear">Bloquear</asp:ListItem>
                            <asp:ListItem Value="liberar">Liberar</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="tech-field is-full">
                        <span>Motivo / observa&ccedil;&atilde;o</span>
                        <asp:TextBox ID="txtMotivo" runat="server" MaxLength="300" placeholder="Ex.: bloqueio solicitado pelo gestor"></asp:TextBox>
                    </div>
                    <div class="tech-actions-row is-full">
                        <asp:Button ID="btnSalvarRegra" runat="server" Text="Salvar regra" OnClick="btnSalvarRegra_Click" />
                        <asp:Button ID="btnAtualizar" runat="server" Text="Atualizar tela" CssClass="tech-button-secondary" OnClick="btnAtualizar_Click" />
                    </div>
                </div>
            </section>

            <section class="tech-panel">
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Regras ativas</span>
                        <h2>Bloqueios e libera&ccedil;&otilde;es configuradas</h2>
                        <p>Remover uma regra volta o comportamento ao padr&atilde;o: acesso liberado.</p>
                    </div>
                </div>

                <div class="permission-table-wrap">
                    <asp:Repeater ID="rptPermissoes" runat="server" OnItemCommand="rptPermissoes_ItemCommand">
                        <HeaderTemplate>
                            <table class="tech-gridview permission-table">
                                <thead>
                                    <tr>
                                        <th>Situa&ccedil;&atilde;o</th>
                                        <th>Usu&aacute;rio</th>
                                        <th>Recurso</th>
                                        <th>A&ccedil;&atilde;o</th>
                                        <th>Motivo</th>
                                        <th>Atualizado</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td><span class='<%# CssRegra(Eval("bloqueado")) %>'><%# StatusRegra(Eval("bloqueado")) %></span></td>
                                <td><strong><%# Html(Eval("usuario_nome")) %></strong><small><%# Html(IdentificadorUsuario(Eval("usuario_codigo"), Eval("usuario_id"))) %></small></td>
                                <td><%# Html(Eval("recurso")) %></td>
                                <td><%# Html(Eval("acao")) %></td>
                                <td><%# Html(Eval("motivo")) %></td>
                                <td><%# DataHora(Eval("atualizado_em")) %><small><%# Html(Eval("atualizado_por")) %></small></td>
                                <td><asp:LinkButton ID="lnkRemover" runat="server" CommandName="remover" CommandArgument='<%# Eval("id_permissao") %>' OnClientClick="return confirm('Remover esta regra de permiss&atilde;o?');">Remover</asp:LinkButton></td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlSemPermissoes" runat="server" CssClass="tech-empty" Visible="false">Nenhuma regra ativa cadastrada.</asp:Panel>
                </div>
            </section>

            <section class="tech-panel">
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Auditoria</span>
                        <h2>&Uacute;ltimos eventos</h2>
                        <p>Mostra altera&ccedil;&otilde;es de regra e tentativas bloqueadas.</p>
                    </div>
                </div>

                <div class="permission-audit-list">
                    <asp:Repeater ID="rptAuditoria" runat="server">
                        <ItemTemplate>
                            <article class="permission-audit-item">
                                <span><%# Html(Eval("evento")) %></span>
                                <strong><%# Html(Eval("usuario_nome")) %></strong>
                                <p><%# Html(Eval("recurso")) %> &middot; <%# Html(Eval("acao")) %></p>
                                <small><%# DataHora(Eval("criado_em")) %> &middot; <%# Html(Eval("operador")) %> &middot; IP <%# Html(Eval("ip")) %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlSemAuditoria" runat="server" CssClass="tech-empty" Visible="false">Nenhum evento de auditoria registrado.</asp:Panel>
                </div>
            </section>
        </main>
    </form>
</body>
</html>
