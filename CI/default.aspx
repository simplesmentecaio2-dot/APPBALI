<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="ci_default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Comunica&ccedil;&atilde;o Interna - CI</title>
    <link href="ci.css?v=20260624-ci-ramais2" rel="stylesheet" />
</head>
<body class="ci-page">
    <form id="form1" runat="server">
        <div class="app-shell">
            <aside class="sidebar">
                <a class="brand" href="default.aspx">
                    <span class="brand-mark">CI</span>
                    <span>
                        <strong>Comunica&ccedil;&atilde;o Interna</strong>
                        <small>Grupo Bali</small>
                    </span>
                </a>
                <nav class="side-nav">
                    <a href="#consulta">Consulta</a>
                    <a href="#cadastro">Nova CI</a>
                    <a href="../Intranet/index.html">Intranet</a>
                </nav>
            </aside>

            <main class="content">
                <header class="hero">
                    <div>
                        <span class="eyebrow">Documento interno</span>
                        <h1>Comunica&ccedil;&atilde;o Interna</h1>
                        <p>Cadastre, consulte e imprima comunica&ccedil;&otilde;es internas padronizadas por marca.</p>
                    </div>
                    <div class="hero-side">
                        <div class="brand-strip" aria-label="Marcas atendidas">
                            <span class="brand-chip fiat"><img src="../img/logobali.png" alt="Bali Fiat" /></span>
                            <span class="brand-chip jeep"><img src="../img/logojeep.png" alt="Bali Jeep" /></span>
                            <span class="brand-chip byd"><img src="../img/bydbranco.png" alt="Bali BYD" /></span>
                        </div>
                        <a class="primary-link" href="#cadastro">Criar CI</a>
                    </div>
                </header>

                <asp:Panel ID="pnlMensagem" runat="server" CssClass="form-message" Visible="false">
                    <asp:Literal ID="litMensagem" runat="server"></asp:Literal>
                </asp:Panel>

                <section class="summary-grid">
                    <article>
                        <span>Total de CIs</span>
                        <strong><asp:Literal ID="litTotal" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Ativas</span>
                        <strong><asp:Literal ID="litAtivas" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>&Uacute;ltimos 30 dias</span>
                        <strong><asp:Literal ID="litRecentes" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                </section>

                <section class="panel" id="consulta">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Consulta</span>
                            <h2>Localizar CIs</h2>
                        </div>
                        <asp:Button ID="btnLimpar" runat="server" Text="Limpar filtros" CssClass="secondary-button" OnClick="btnLimpar_Click" />
                    </div>

                    <div class="filter-grid">
                        <label>Data inicial
                            <asp:TextBox ID="txtFiltroInicio" runat="server" CssClass="text-field" TextMode="Date"></asp:TextBox>
                        </label>
                        <label>Data final
                            <asp:TextBox ID="txtFiltroFim" runat="server" CssClass="text-field" TextMode="Date"></asp:TextBox>
                        </label>
                        <label>Marca
                            <asp:DropDownList ID="ddlFiltroMarca" runat="server" CssClass="select-field">
                                <asp:ListItem Value="">Todas</asp:ListItem>
                                <asp:ListItem>Bali Fiat</asp:ListItem>
                                <asp:ListItem>Bali Jeep</asp:ListItem>
                                <asp:ListItem>Bali BYD</asp:ListItem>
                            </asp:DropDownList>
                        </label>
                        <label>Busca
                            <asp:TextBox ID="txtBusca" runat="server" CssClass="text-field" placeholder="Assunto, &aacute;rea, destinat&aacute;rio ou texto"></asp:TextBox>
                        </label>
                        <label class="checkbox-row">
                            <asp:CheckBox ID="chkSomenteAtivas" runat="server" Checked="true" />
                            Somente ativas
                        </label>
                        <asp:Button ID="btnFiltrar" runat="server" Text="Filtrar" CssClass="primary-button" OnClick="btnFiltrar_Click" />
                    </div>

                    <div class="edit-password">
                        <label>Senha para editar ou cancelar
                            <asp:TextBox ID="txtSenhaEdicao" runat="server" CssClass="text-field" TextMode="Password" autocomplete="current-password"></asp:TextBox>
                        </label>
                        <small>Informe a senha para editar ou cancelar uma CI. Depois da libera&ccedil;&atilde;o, voc&ecirc; pode salvar a altera&ccedil;&atilde;o nessa mesma sess&atilde;o.</small>
                    </div>

                    <div class="table-wrap">
                        <asp:GridView ID="gvCis" runat="server" CssClass="ci-table" AutoGenerateColumns="false" EmptyDataText="Nenhuma CI encontrada." OnRowCommand="gvCis_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="codigo_ci" HeaderText="C&oacute;digo" />
                                <asp:BoundField DataField="data_documento" HeaderText="Data" DataFormatString="{0:dd/MM/yyyy}" />
                                <asp:BoundField DataField="origem_marca" HeaderText="Marca" />
                                <asp:BoundField DataField="destinatario" HeaderText="Destinat&aacute;rio" />
                                <asp:BoundField DataField="assunto" HeaderText="Assunto" />
                                <asp:BoundField DataField="status" HeaderText="Status" />
                                <asp:TemplateField HeaderText="A&ccedil;&otilde;es">
                                    <ItemTemplate>
                                        <a class="table-action" href='print.aspx?id=<%# Eval("id_ci") %>' target="_blank">Imprimir</a>
                                        <asp:LinkButton ID="lnkEditar" runat="server" CssClass="table-action" CommandName="EditarCI" CommandArgument='<%# Eval("id_ci") %>'>Editar</asp:LinkButton>
                                        <asp:LinkButton ID="lnkCancelar" runat="server" CssClass="table-action danger" CommandName="CancelarCI" CommandArgument='<%# Eval("id_ci") %>' OnClientClick="return confirm('Deseja cancelar esta CI?');">Cancelar</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </section>

                <section class="panel" id="cadastro">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Cadastro</span>
                            <h2><asp:Literal ID="litTituloForm" runat="server" Text="Nova CI"></asp:Literal></h2>
                        </div>
                        <asp:Button ID="btnNova" runat="server" Text="Nova CI" CssClass="secondary-button" OnClick="btnNova_Click" />
                    </div>

                    <asp:HiddenField ID="hfCiId" runat="server" />
                    <div id="ciClientMessage" class="client-message" aria-live="polite"></div>
                    <div class="form-grid">
                        <label>Marca
                            <asp:DropDownList ID="ddlMarca" runat="server" CssClass="select-field">
                                <asp:ListItem>Bali Fiat</asp:ListItem>
                                <asp:ListItem>Bali Jeep</asp:ListItem>
                                <asp:ListItem>Bali BYD</asp:ListItem>
                            </asp:DropDownList>
                        </label>
                        <label>Data da CI
                            <asp:TextBox ID="txtData" runat="server" CssClass="text-field" TextMode="Date"></asp:TextBox>
                        </label>
                        <label>Categoria
                            <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="select-field">
                                <asp:ListItem>Comunicado</asp:ListItem>
                                <asp:ListItem>Solicita&ccedil;&atilde;o</asp:ListItem>
                                <asp:ListItem>Autoriza&ccedil;&atilde;o</asp:ListItem>
                                <asp:ListItem>Procedimento</asp:ListItem>
                                <asp:ListItem>Financeiro</asp:ListItem>
                                <asp:ListItem>Administrativo</asp:ListItem>
                            </asp:DropDownList>
                        </label>
                        <label>Prioridade
                            <asp:DropDownList ID="ddlPrioridade" runat="server" CssClass="select-field">
                                <asp:ListItem>Normal</asp:ListItem>
                                <asp:ListItem>Alta</asp:ListItem>
                                <asp:ListItem>Urgente</asp:ListItem>
                            </asp:DropDownList>
                        </label>
                        <label>&Aacute;rea de origem
                            <asp:TextBox ID="txtOrigemArea" runat="server" CssClass="text-field" MaxLength="120"></asp:TextBox>
                        </label>
                        <label>Respons&aacute;vel
                            <asp:TextBox ID="txtOrigemResponsavel" runat="server" CssClass="text-field" MaxLength="160"></asp:TextBox>
                        </label>
                        <label>&Aacute;rea de destino
                            <asp:TextBox ID="txtDestinoArea" runat="server" CssClass="text-field" MaxLength="120"></asp:TextBox>
                        </label>
                        <label>Destinat&aacute;rio
                            <asp:TextBox ID="txtDestinatario" runat="server" CssClass="text-field" MaxLength="160"></asp:TextBox>
                        </label>
                        <label class="wide">Assunto
                            <asp:TextBox ID="txtAssunto" runat="server" CssClass="text-field" MaxLength="200"></asp:TextBox>
                        </label>
                        <label class="wide">Texto da comunica&ccedil;&atilde;o
                            <asp:TextBox ID="txtCorpo" runat="server" CssClass="textarea-field" TextMode="MultiLine" Rows="9"></asp:TextBox>
                        </label>
                        <label class="wide">Provid&ecirc;ncias solicitadas
                            <asp:TextBox ID="txtProvidencias" runat="server" CssClass="textarea-field" TextMode="MultiLine" Rows="4"></asp:TextBox>
                        </label>
                        <label class="wide">Observa&ccedil;&otilde;es
                            <asp:TextBox ID="txtObservacoes" runat="server" CssClass="textarea-field" TextMode="MultiLine" Rows="3"></asp:TextBox>
                        </label>
                        <label>Criado por
                            <asp:TextBox ID="txtCriadoPor" runat="server" CssClass="text-field" MaxLength="160"></asp:TextBox>
                        </label>
                    </div>

                    <div class="form-actions">
                        <asp:Button ID="btnSalvar" runat="server" Text="Salvar CI" CssClass="primary-button" OnClick="btnSalvar_Click" OnClientClick="return validarCICliente();" />
                        <a class="secondary-link" href="#consulta">Voltar para consulta</a>
                    </div>
                </section>
            </main>
        </div>
        <script>
            (function () {
                var camposObrigatorios = [
                    { id: '<%= txtData.ClientID %>', mensagem: 'Informe a data da CI.' },
                    { id: '<%= txtOrigemArea.ClientID %>', mensagem: 'Informe a \u00e1rea de origem.' },
                    { id: '<%= txtOrigemResponsavel.ClientID %>', mensagem: 'Informe o respons\u00e1vel pela origem.' },
                    { id: '<%= txtDestinoArea.ClientID %>', mensagem: 'Informe a \u00e1rea de destino.' },
                    { id: '<%= txtDestinatario.ClientID %>', mensagem: 'Informe o destinat\u00e1rio.' },
                    { id: '<%= txtAssunto.ClientID %>', mensagem: 'Informe o assunto.' },
                    { id: '<%= txtCorpo.ClientID %>', mensagem: 'Informe o texto da comunica\u00e7\u00e3o.' }
                ];

                function campo(id) {
                    return document.getElementById(id);
                }

                function limparErros() {
                    var aviso = document.getElementById('ciClientMessage');
                    if (aviso) {
                        aviso.textContent = '';
                        aviso.classList.remove('is-visible');
                    }

                    for (var i = 0; i < camposObrigatorios.length; i++) {
                        var item = campo(camposObrigatorios[i].id);
                        if (item) item.classList.remove('field-error');
                    }
                }

                function mostrarErro(mensagem, elemento) {
                    var aviso = document.getElementById('ciClientMessage');
                    if (aviso) {
                        aviso.textContent = mensagem;
                        aviso.classList.add('is-visible');
                    }

                    if (elemento) {
                        elemento.classList.add('field-error');
                        elemento.focus();
                    }
                }

                window.validarCICliente = function () {
                    limparErros();

                    for (var i = 0; i < camposObrigatorios.length; i++) {
                        var item = campo(camposObrigatorios[i].id);
                        if (!item || item.value.trim().length === 0) {
                            mostrarErro(camposObrigatorios[i].mensagem, item);
                            return false;
                        }
                    }

                    return true;
                };
            })();
        </script>
    </form>
</body>
</html>
