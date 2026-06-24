<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="ramais_default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Sistema de Ramais</title>
    <link href="ramais.css?v=20260624" rel="stylesheet" />
</head>
<body class="ramais-page">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <div class="app-shell">
            <aside class="sidebar">
                <a class="brand" href="default.aspx">
                    <span class="brand-mark">B</span>
                    <span>
                        <strong>Ramais</strong>
                        <small>Grupo Bali</small>
                    </span>
                </a>

                <nav class="side-nav" aria-label="Menu principal">
                    <a href="#consulta">Consulta</a>
                    <a href="#ramais">Ramais</a>
                    <a href="#lojas">Lojas</a>
                    <a href="#setores">Setores</a>
                    <a href="../Intranet/index.html">Intranet</a>
                </nav>

                <asp:Button ID="btnSair" runat="server" Text="Sair" CssClass="secondary-button" OnClick="btnSair_Click" />
            </aside>

            <main class="content">
                <header class="hero">
                    <div>
                        <span class="eyebrow">Comunicação interna</span>
                        <h1>Sistema de Ramais</h1>
                        <p>Consulta e manutenção dos contatos por loja, setor e colaborador.</p>
                    </div>
                    <div class="hero-actions">
                        <a class="secondary-link" href="../Intranet/index.html">Voltar</a>
                        <a class="primary-link" href="#ramais">Novo ramal</a>
                    </div>
                </header>

                <asp:Panel ID="pnlMensagem" runat="server" CssClass="form-message" Visible="false">
                    <asp:Literal ID="litMensagem" runat="server"></asp:Literal>
                </asp:Panel>

                <section class="summary-grid" aria-label="Resumo">
                    <article>
                        <span>Ramais ativos</span>
                        <strong><asp:Literal ID="litTotalRamais" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Lojas cadastradas</span>
                        <strong><asp:Literal ID="litTotalLojas" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Setores cadastrados</span>
                        <strong><asp:Literal ID="litTotalSetores" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                </section>

                <section class="panel" id="consulta">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Consulta</span>
                            <h2>Localizar ramais</h2>
                        </div>
                        <asp:Button ID="btnLimparFiltros" runat="server" Text="Limpar filtros" CssClass="secondary-button" OnClick="btnLimparFiltros_Click" />
                    </div>

                    <div class="filter-grid">
                        <label>Loja
                            <asp:DropDownList ID="ddlFiltroLoja" runat="server" CssClass="select-field"></asp:DropDownList>
                        </label>
                        <label>Setor
                            <asp:DropDownList ID="ddlFiltroSetor" runat="server" CssClass="select-field"></asp:DropDownList>
                        </label>
                        <label>Buscar
                            <asp:TextBox ID="txtBusca" runat="server" CssClass="text-field" placeholder="Nome, ramal, loja ou setor"></asp:TextBox>
                        </label>
                        <label class="checkbox-row">
                            <asp:CheckBox ID="chkSomenteAtivos" runat="server" Checked="true" />
                            Somente ativos
                        </label>
                        <asp:Button ID="btnFiltrar" runat="server" Text="Filtrar" CssClass="primary-button" OnClick="btnFiltrar_Click" />
                    </div>

                    <div class="table-wrap">
                        <asp:GridView ID="gvConsulta" runat="server" CssClass="ramais-table" AutoGenerateColumns="false" EmptyDataText="Nenhum ramal encontrado para os filtros informados." OnRowCommand="gvRamais_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="nome" HeaderText="Nome" />
                                <asp:BoundField DataField="ramal" HeaderText="Ramal" />
                                <asp:BoundField DataField="loja" HeaderText="Loja" />
                                <asp:BoundField DataField="setor" HeaderText="Setor" />
                                <asp:BoundField DataField="status" HeaderText="Status" />
                                <asp:TemplateField HeaderText="Ação">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkEditarConsulta" runat="server" CssClass="table-action" CommandName="EditarRamal" CommandArgument='<%# Eval("id_ramal") %>'>Editar</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </section>

                <section class="panel" id="ramais">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Cadastro</span>
                            <h2>Ramais</h2>
                        </div>
                        <asp:Button ID="btnNovoRamal" runat="server" Text="Novo ramal" CssClass="secondary-button" OnClick="btnNovoRamal_Click" />
                    </div>

                    <asp:HiddenField ID="hfRamalId" runat="server" />
                    <div class="form-grid">
                        <label>Nome
                            <asp:TextBox ID="txtNome" runat="server" CssClass="text-field" MaxLength="160"></asp:TextBox>
                        </label>
                        <label>Ramal
                            <asp:TextBox ID="txtRamal" runat="server" CssClass="text-field" MaxLength="30"></asp:TextBox>
                        </label>
                        <label>Loja
                            <asp:DropDownList ID="ddlRamalLoja" runat="server" CssClass="select-field"></asp:DropDownList>
                        </label>
                        <label>Setor
                            <asp:DropDownList ID="ddlRamalSetor" runat="server" CssClass="select-field"></asp:DropDownList>
                        </label>
                        <label class="checkbox-row">
                            <asp:CheckBox ID="chkRamalAtivo" runat="server" Checked="true" />
                            Ativo
                        </label>
                        <asp:Button ID="btnSalvarRamal" runat="server" Text="Salvar ramal" CssClass="primary-button" OnClick="btnSalvarRamal_Click" />
                    </div>

                    <div class="table-wrap">
                        <asp:GridView ID="gvRamais" runat="server" CssClass="ramais-table" AutoGenerateColumns="false" EmptyDataText="Nenhum ramal cadastrado." OnRowCommand="gvRamais_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="nome" HeaderText="Nome" />
                                <asp:BoundField DataField="ramal" HeaderText="Ramal" />
                                <asp:BoundField DataField="loja" HeaderText="Loja" />
                                <asp:BoundField DataField="setor" HeaderText="Setor" />
                                <asp:BoundField DataField="status" HeaderText="Status" />
                                <asp:TemplateField HeaderText="Ações">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkEditarRamal" runat="server" CssClass="table-action" CommandName="EditarRamal" CommandArgument='<%# Eval("id_ramal") %>'>Editar</asp:LinkButton>
                                        <asp:LinkButton ID="lnkExcluirRamal" runat="server" CssClass="table-action danger" CommandName="ExcluirRamal" CommandArgument='<%# Eval("id_ramal") %>' OnClientClick="return confirm('Deseja inativar este ramal?');">Excluir</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </section>

                <section class="two-column">
                    <section class="panel" id="lojas">
                        <div class="panel-header">
                            <div>
                                <span class="eyebrow">Cadastro</span>
                                <h2>Lojas</h2>
                            </div>
                                    <asp:Button ID="btnNovaLoja" runat="server" Text="Nova loja" CssClass="secondary-button" OnClick="btnNovaLoja_Click" />
                        </div>

                        <asp:HiddenField ID="hfLojaId" runat="server" />
                        <div class="compact-form">
                            <label>Nome da loja
                                <asp:TextBox ID="txtLojaNome" runat="server" CssClass="text-field" MaxLength="120"></asp:TextBox>
                            </label>
                            <label class="checkbox-row">
                                <asp:CheckBox ID="chkLojaAtiva" runat="server" Checked="true" />
                                Ativa
                            </label>
                            <asp:Button ID="btnSalvarLoja" runat="server" Text="Salvar loja" CssClass="primary-button" OnClick="btnSalvarLoja_Click" />
                        </div>

                        <div class="table-wrap">
                            <asp:GridView ID="gvLojas" runat="server" CssClass="ramais-table compact" AutoGenerateColumns="false" EmptyDataText="Nenhuma loja cadastrada." OnRowCommand="gvLojas_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="nome" HeaderText="Loja" />
                                    <asp:BoundField DataField="status" HeaderText="Status" />
                                    <asp:TemplateField HeaderText="Ações">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkEditarLoja" runat="server" CssClass="table-action" CommandName="EditarLoja" CommandArgument='<%# Eval("id_loja") %>'>Editar</asp:LinkButton>
                                            <asp:LinkButton ID="lnkExcluirLoja" runat="server" CssClass="table-action danger" CommandName="ExcluirLoja" CommandArgument='<%# Eval("id_loja") %>' OnClientClick="return confirm('Deseja inativar esta loja?');">Excluir</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </section>

                    <section class="panel" id="setores">
                        <div class="panel-header">
                            <div>
                                <span class="eyebrow">Cadastro</span>
                                <h2>Setores</h2>
                            </div>
                            <asp:Button ID="btnNovoSetor" runat="server" Text="Novo setor" CssClass="secondary-button" OnClick="btnNovoSetor_Click" />
                        </div>

                        <asp:HiddenField ID="hfSetorId" runat="server" />
                        <div class="compact-form">
                            <label>Nome do setor
                                <asp:TextBox ID="txtSetorNome" runat="server" CssClass="text-field" MaxLength="120"></asp:TextBox>
                            </label>
                            <label class="checkbox-row">
                                <asp:CheckBox ID="chkSetorAtivo" runat="server" Checked="true" />
                                Ativo
                            </label>
                            <asp:Button ID="btnSalvarSetor" runat="server" Text="Salvar setor" CssClass="primary-button" OnClick="btnSalvarSetor_Click" />
                        </div>

                        <div class="table-wrap">
                            <asp:GridView ID="gvSetores" runat="server" CssClass="ramais-table compact" AutoGenerateColumns="false" EmptyDataText="Nenhum setor cadastrado." OnRowCommand="gvSetores_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="nome" HeaderText="Setor" />
                                    <asp:BoundField DataField="status" HeaderText="Status" />
                                    <asp:TemplateField HeaderText="Ações">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkEditarSetor" runat="server" CssClass="table-action" CommandName="EditarSetor" CommandArgument='<%# Eval("id_setor") %>'>Editar</asp:LinkButton>
                                            <asp:LinkButton ID="lnkExcluirSetor" runat="server" CssClass="table-action danger" CommandName="ExcluirSetor" CommandArgument='<%# Eval("id_setor") %>' OnClientClick="return confirm('Deseja inativar este setor?');">Excluir</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </section>
                </section>
            </main>
        </div>
    </form>
</body>
</html>
