<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="ramais_default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Sistema de Ramais</title>
    <link href="ramais.css?v=20260626-ux02" rel="stylesheet" />
</head>
<body class="ramais-page">
    <form id="form1" runat="server">
        <a class="skip-link" href="#conteudo">Ir para o conte&uacute;do</a>
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <asp:HiddenField ID="hfSenhaManutencao" runat="server" />

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
                    <a href="default.aspx?view=consulta">Consulta</a>
                    <a href="default.aspx?view=impressao">Impress&atilde;o</a>
                    <a href="default.aspx?view=ramais">Ramais</a>
                    <a href="default.aspx?view=lojas">Lojas</a>
                    <a href="default.aspx?view=setores">Setores</a>
                    <a href="../Intranet/index.html">Intranet</a>
                </nav>

                <asp:Button ID="btnSair" runat="server" Text="Voltar" CssClass="secondary-button" OnClick="btnSair_Click" />
            </aside>

            <main class="content" id="conteudo" tabindex="-1">
                <header class="hero">
                    <div>
                        <span class="eyebrow">Comunica&ccedil;&atilde;o interna</span>
                        <h1>Sistema de Ramais</h1>
                        <p>Consulta e manuten&ccedil;&atilde;o dos contatos por loja, setor e colaborador.</p>
                    </div>
                    <div class="hero-actions">
                        <div class="brand-strip" aria-label="Marcas atendidas">
                            <span class="brand-chip fiat"><img src="../img/logobali.png" alt="Bali Fiat" /></span>
                            <span class="brand-chip jeep"><img src="../img/logojeep.png" alt="Bali Jeep" /></span>
                            <span class="brand-chip byd"><img src="../img/bydbranco.png" alt="Bali BYD" /></span>
                        </div>
                        <a class="secondary-link" href="../Intranet/index.html">Voltar</a>
                        <a class="secondary-link" href="default.aspx?view=impressao">Impress&atilde;o</a>
                        <a class="primary-link" href="default.aspx?view=ramais">Novo ramal</a>
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
                    <article>
                        <span>Ramais inativos</span>
                        <strong><asp:Literal ID="litRamaisInativos" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Lojas com ramais</span>
                        <strong><asp:Literal ID="litLojasComRamais" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                </section>

                <asp:Panel ID="pnlImpressao" runat="server" CssClass="panel print-panel">
                    <div class="panel-header print-screen-header">
                        <div>
                            <span class="eyebrow">Impress&atilde;o</span>
                            <h2>Grade de ramais</h2>
                            <p class="panel-subtitle">Gere uma lista para impress&atilde;o em retrato, agrupada por setor.</p>
                        </div>
                    </div>

                    <div class="filter-grid print-controls">
                        <label>Loja
                            <asp:DropDownList ID="ddlImpressaoLoja" runat="server" CssClass="select-field"></asp:DropDownList>
                        </label>
                        <asp:Button ID="btnGerarImpressao" runat="server" Text="Atualizar grade" CssClass="primary-button" OnClick="btnGerarImpressao_Click" />
                        <button type="button" class="secondary-button" onclick="window.print();">Imprimir</button>
                    </div>

                    <p class="print-summary"><asp:Literal ID="litImpressaoResumo" runat="server"></asp:Literal></p>
                    <asp:Literal ID="litGradeImpressao" runat="server"></asp:Literal>
                </asp:Panel>

                <asp:Panel ID="pnlConsulta" runat="server" CssClass="panel">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Consulta</span>
                            <h2>Localizar ramais</h2>
                        </div>
                        <div class="panel-tools">
                            <a class="secondary-link" href="default.aspx?view=impressao">Imprimir/PDF</a>
                            <asp:Button ID="btnExportar" runat="server" Text="Exportar Excel" CssClass="secondary-button" OnClick="btnExportar_Click" />
                            <asp:Button ID="btnLimparFiltros" runat="server" Text="Limpar filtros" CssClass="secondary-button" OnClick="btnLimparFiltros_Click" />
                        </div>
                    </div>

                    <div class="filter-grid">
                        <label>Loja
                            <asp:DropDownList ID="ddlFiltroLoja" runat="server" CssClass="select-field"></asp:DropDownList>
                        </label>
                        <label>Setor
                            <asp:DropDownList ID="ddlFiltroSetor" runat="server" CssClass="select-field"></asp:DropDownList>
                        </label>
                        <label>Buscar
                            <asp:TextBox ID="txtBusca" runat="server" CssClass="text-field" placeholder="Nome, ramal, loja ou setor" autocomplete="off"></asp:TextBox>
                        </label>
                        <label class="checkbox-row">
                            <asp:CheckBox ID="chkSomenteAtivos" runat="server" Checked="true" />
                            Somente ativos
                        </label>
                        <asp:Button ID="btnFiltrar" runat="server" Text="Filtrar" CssClass="primary-button" OnClick="btnFiltrar_Click" />
                    </div>
                    <asp:Literal ID="litResumoConsultaRamais" runat="server"></asp:Literal>

                    <div class="table-wrap">
                        <asp:GridView ID="gvConsulta" runat="server" CssClass="ramais-table" AutoGenerateColumns="false" EmptyDataText="Nenhum ramal encontrado para os filtros informados." AllowPaging="true" AllowSorting="true" PageSize="15" PagerStyle-CssClass="ramais-pager" OnPageIndexChanging="Grid_PageIndexChanging" OnSorting="Grid_Sorting" OnRowCommand="gvRamais_RowCommand" OnRowDataBound="Grid_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="nome" HeaderText="Nome" SortExpression="nome" />
                                <asp:BoundField DataField="ramal" HeaderText="Ramal" SortExpression="ramal" />
                                <asp:BoundField DataField="loja" HeaderText="Loja" SortExpression="loja" />
                                <asp:BoundField DataField="setor" HeaderText="Setor" SortExpression="setor" />
                                <asp:BoundField DataField="status" HeaderText="Status" SortExpression="status" />
                                <asp:TemplateField HeaderText="A&ccedil;&atilde;o">
                                    <ItemTemplate>
                                        <button type="button" class="table-action copy-action" data-ramal='<%# Atributo(Eval("ramal")) %>' data-nome='<%# Atributo(Eval("nome")) %>' onclick="copiarRamalConsulta(this)">Copiar</button>
                                        <asp:LinkButton ID="lnkEditarConsulta" runat="server" CssClass="table-action" CommandName="EditarRamal" CommandArgument='<%# Eval("id_ramal") %>' OnClientClick="return solicitarSenhaRamal('editar', this);">Editar</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlRamais" runat="server" CssClass="panel">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Cadastro</span>
                            <h2>Ramais</h2>
                        </div>
                        <asp:Button ID="btnNovoRamal" runat="server" Text="Novo ramal" CssClass="secondary-button" OnClick="btnNovoRamal_Click" />
                    </div>

                    <asp:HiddenField ID="hfRamalId" runat="server" />
                    <div id="ramalClientMessage" class="client-message" aria-live="polite"></div>
                    <div class="import-box">
                        <div>
                            <span class="eyebrow">Importa&ccedil;&atilde;o em massa</span>
                            <strong>CSV ou Excel salvo como CSV</strong>
                            <p>Colunas esperadas: Nome; Ramal; Loja; Setor; Ativo. Novos ramais n&atilde;o pedem senha; altera&ccedil;&otilde;es continuam protegidas.</p>
                        </div>
                        <asp:FileUpload ID="fuImportarRamais" runat="server" CssClass="file-field" />
                        <asp:Button ID="btnImportarRamais" runat="server" Text="Importar lista" CssClass="secondary-button" OnClick="btnImportarRamais_Click" />
                        <asp:Button ID="btnBaixarModeloImportacao" runat="server" Text="Baixar modelo CSV" CssClass="secondary-button" OnClick="btnBaixarModeloImportacao_Click" />
                    </div>
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
                        <asp:Button ID="btnSalvarRamal" runat="server" Text="Salvar ramal" CssClass="primary-button" OnClick="btnSalvarRamal_Click" OnClientClick="return validarRamalCliente();" />
                    </div>

                    <div class="table-wrap">
                        <asp:GridView ID="gvRamais" runat="server" CssClass="ramais-table" AutoGenerateColumns="false" EmptyDataText="Nenhum ramal cadastrado." AllowPaging="true" AllowSorting="true" PageSize="15" PagerStyle-CssClass="ramais-pager" OnPageIndexChanging="Grid_PageIndexChanging" OnSorting="Grid_Sorting" OnRowCommand="gvRamais_RowCommand" OnRowDataBound="Grid_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="nome" HeaderText="Nome" SortExpression="nome" />
                                <asp:BoundField DataField="ramal" HeaderText="Ramal" SortExpression="ramal" />
                                <asp:BoundField DataField="loja" HeaderText="Loja" SortExpression="loja" />
                                <asp:BoundField DataField="setor" HeaderText="Setor" SortExpression="setor" />
                                <asp:BoundField DataField="status" HeaderText="Status" SortExpression="status" />
                                <asp:TemplateField HeaderText="A&ccedil;&otilde;es">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkEditarRamal" runat="server" CssClass="table-action" CommandName="EditarRamal" CommandArgument='<%# Eval("id_ramal") %>' OnClientClick="return solicitarSenhaRamal('editar', this);">Editar</asp:LinkButton>
                                        <asp:LinkButton ID="lnkExcluirRamal" runat="server" CssClass="table-action danger" CommandName="ExcluirRamal" CommandArgument='<%# Eval("id_ramal") %>' OnClientClick="return confirmarExclusaoRamal(this);">Excluir</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                    <asp:Panel ID="pnlHistoricoRamais" runat="server" CssClass="history-card">
                        <div class="panel-header compact-header">
                            <div>
                                <span class="eyebrow">Auditoria</span>
                                <h3>&Uacute;ltimas altera&ccedil;&otilde;es</h3>
                            </div>
                        </div>
                        <asp:Literal ID="litHistoricoRamais" runat="server"></asp:Literal>
                    </asp:Panel>
                </asp:Panel>

                <asp:Panel ID="pnlCadastrosAuxiliares" runat="server" CssClass="two-column">
                    <asp:Panel ID="pnlLojas" runat="server" CssClass="panel">
                        <div class="panel-header">
                            <div>
                                <span class="eyebrow">Cadastro</span>
                                <h2>Lojas</h2>
                            </div>
                            <asp:Button ID="btnNovaLoja" runat="server" Text="Nova loja" CssClass="secondary-button" OnClick="btnNovaLoja_Click" />
                        </div>

                        <asp:HiddenField ID="hfLojaId" runat="server" />
                        <div id="lojaClientMessage" class="client-message" aria-live="polite"></div>
                        <div class="compact-form">
                            <label>Nome da loja
                                <asp:TextBox ID="txtLojaNome" runat="server" CssClass="text-field" MaxLength="120"></asp:TextBox>
                            </label>
                            <label class="checkbox-row">
                                <asp:CheckBox ID="chkLojaAtiva" runat="server" Checked="true" />
                                Ativa
                            </label>
                            <asp:Button ID="btnSalvarLoja" runat="server" Text="Salvar loja" CssClass="primary-button" OnClick="btnSalvarLoja_Click" OnClientClick="return validarCampoObrigatorio('txtLojaNome', 'lojaClientMessage', 'Informe o nome da loja.');" />
                        </div>

                        <div class="table-wrap">
                            <asp:GridView ID="gvLojas" runat="server" CssClass="ramais-table compact" AutoGenerateColumns="false" EmptyDataText="Nenhuma loja cadastrada." AllowPaging="true" AllowSorting="true" PageSize="10" PagerStyle-CssClass="ramais-pager" OnPageIndexChanging="Grid_PageIndexChanging" OnSorting="Grid_Sorting" OnRowCommand="gvLojas_RowCommand" OnRowDataBound="Grid_RowDataBound">
                                <Columns>
                                    <asp:BoundField DataField="nome" HeaderText="Loja" SortExpression="nome" />
                                    <asp:BoundField DataField="status" HeaderText="Status" SortExpression="status" />
                                    <asp:TemplateField HeaderText="A&ccedil;&otilde;es">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkEditarLoja" runat="server" CssClass="table-action" CommandName="EditarLoja" CommandArgument='<%# Eval("id_loja") %>'>Editar</asp:LinkButton>
                                            <asp:LinkButton ID="lnkExcluirLoja" runat="server" CssClass="table-action danger" CommandName="ExcluirLoja" CommandArgument='<%# Eval("id_loja") %>' OnClientClick="return confirm('Deseja inativar esta loja?');">Excluir</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlSetores" runat="server" CssClass="panel">
                        <div class="panel-header">
                            <div>
                                <span class="eyebrow">Cadastro</span>
                                <h2>Setores</h2>
                            </div>
                            <asp:Button ID="btnNovoSetor" runat="server" Text="Novo setor" CssClass="secondary-button" OnClick="btnNovoSetor_Click" />
                        </div>

                        <asp:HiddenField ID="hfSetorId" runat="server" />
                        <div id="setorClientMessage" class="client-message" aria-live="polite"></div>
                        <div class="compact-form">
                            <label>Nome do setor
                                <asp:TextBox ID="txtSetorNome" runat="server" CssClass="text-field" MaxLength="120"></asp:TextBox>
                            </label>
                            <label class="checkbox-row">
                                <asp:CheckBox ID="chkSetorAtivo" runat="server" Checked="true" />
                                Ativo
                            </label>
                            <asp:Button ID="btnSalvarSetor" runat="server" Text="Salvar setor" CssClass="primary-button" OnClick="btnSalvarSetor_Click" OnClientClick="return validarCampoObrigatorio('txtSetorNome', 'setorClientMessage', 'Informe o nome do setor.');" />
                        </div>

                        <div class="table-wrap">
                            <asp:GridView ID="gvSetores" runat="server" CssClass="ramais-table compact" AutoGenerateColumns="false" EmptyDataText="Nenhum setor cadastrado." AllowPaging="true" AllowSorting="true" PageSize="10" PagerStyle-CssClass="ramais-pager" OnPageIndexChanging="Grid_PageIndexChanging" OnSorting="Grid_Sorting" OnRowCommand="gvSetores_RowCommand" OnRowDataBound="Grid_RowDataBound">
                                <Columns>
                                    <asp:BoundField DataField="nome" HeaderText="Setor" SortExpression="nome" />
                                    <asp:BoundField DataField="status" HeaderText="Status" SortExpression="status" />
                                    <asp:TemplateField HeaderText="A&ccedil;&otilde;es">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkEditarSetor" runat="server" CssClass="table-action" CommandName="EditarSetor" CommandArgument='<%# Eval("id_setor") %>'>Editar</asp:LinkButton>
                                            <asp:LinkButton ID="lnkExcluirSetor" runat="server" CssClass="table-action danger" CommandName="ExcluirSetor" CommandArgument='<%# Eval("id_setor") %>' OnClientClick="return confirm('Deseja inativar este setor?');">Excluir</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </asp:Panel>
                </asp:Panel>
            </main>
        </div>

        <div class="password-modal" id="modalSenhaRamal" aria-hidden="true">
            <div class="password-dialog" role="dialog" aria-modal="true" aria-labelledby="tituloSenhaRamal">
                <span class="eyebrow">Manuten&ccedil;&atilde;o protegida</span>
                <h3 id="tituloSenhaRamal">Confirmar a&ccedil;&atilde;o no ramal</h3>
                <p id="textoSenhaRamal">Informe a senha para continuar.</p>
                <label>Senha
                    <input id="txtSenhaRamalCliente" class="text-field" type="password" autocomplete="current-password" />
                </label>
                <div class="modal-actions">
                    <button type="button" class="secondary-button" onclick="fecharSenhaRamal();">Cancelar</button>
                    <button type="button" class="primary-button" onclick="confirmarSenhaRamal();">Continuar</button>
                </div>
            </div>
        </div>

        <script>
            (function () {
                var postbackPendente = null;
                var modal = document.getElementById('modalSenhaRamal');
                var campoSenha = document.getElementById('txtSenhaRamalCliente');
                var textoSenha = document.getElementById('textoSenhaRamal');

                function executarPostbackPendente() {
                    if (!postbackPendente) return;

                    var href = postbackPendente;
                    postbackPendente = null;
                    href = href.replace(/&#39;/g, "'").replace(/&quot;/g, '"');

                    if (href.indexOf('javascript:') === 0) {
                        href = href.replace(/^javascript:/i, '');
                    }

                    var postback = href.match(/__doPostBack\('([^']*)','([^']*)'\)/);
                    if (postback && typeof window.__doPostBack === 'function') {
                        window.setTimeout(function () {
                            window.__doPostBack(postback[1], postback[2] || '');
                        }, 0);
                        return;
                    }

                    window.alert('N\u00e3o foi poss\u00edvel processar esta a\u00e7\u00e3o agora. Atualize a p\u00e1gina e tente novamente.');
                }

                window.solicitarSenhaRamal = function (acao, link) {
                    postbackPendente = link ? link.getAttribute('href') : null;
                    if (textoSenha) textoSenha.textContent = 'Informe a senha de manuten\u00e7\u00e3o para ' + (acao || 'alterar') + ' este ramal.';
                    if (campoSenha) campoSenha.value = '';
                    if (modal) modal.classList.add('is-open');
                    if (campoSenha) window.setTimeout(function () { campoSenha.focus(); }, 80);
                    return false;
                };

                window.confirmarExclusaoRamal = function (link) {
                    if (!window.confirm('Deseja inativar este ramal?')) return false;
                    return window.solicitarSenhaRamal('excluir', link);
                };

                window.fecharSenhaRamal = function () {
                    postbackPendente = null;
                    if (modal) modal.classList.remove('is-open');
                    if (campoSenha) campoSenha.value = '';
                };

                window.confirmarSenhaRamal = function () {
                    var campoServidor = document.getElementById('<%= hfSenhaManutencao.ClientID %>');
                    if (campoServidor && campoSenha) campoServidor.value = campoSenha.value;
                    if (modal) modal.classList.remove('is-open');
                    executarPostbackPendente();
                };

                document.addEventListener('keydown', function (event) {
                    if (!modal || !modal.classList.contains('is-open')) return;
                    if (event.key === 'Escape') window.fecharSenhaRamal();
                    if (event.key === 'Enter') {
                        event.preventDefault();
                        window.confirmarSenhaRamal();
                    }
                });

                function campo(id) {
                    return document.getElementById(id);
                }

                window.copiarRamalConsulta = function (botao) {
                    var ramal = botao ? (botao.getAttribute('data-ramal') || '') : '';
                    var nome = botao ? (botao.getAttribute('data-nome') || '') : '';
                    var texto = ramal;
                    if (!texto) return;

                    function avisar() {
                        var original = botao.textContent;
                        botao.textContent = 'Copiado';
                        botao.classList.add('is-copied');
                        window.setTimeout(function () {
                            botao.textContent = original;
                            botao.classList.remove('is-copied');
                        }, 1400);
                    }

                    if (navigator.clipboard && navigator.clipboard.writeText) {
                        navigator.clipboard.writeText(texto).then(avisar).catch(function () {
                            window.prompt('Copie o ramal de ' + nome + ':', texto);
                        });
                    } else {
                        window.prompt('Copie o ramal de ' + nome + ':', texto);
                    }
                };

                function filtrarTabelaCarregada() {
                    var busca = campo('<%= txtBusca.ClientID %>');
                    var tabela = document.getElementById('<%= gvConsulta.ClientID %>');
                    if (!busca || !tabela) return;

                    var termo = busca.value.trim().toLowerCase();
                    var linhas = tabela.querySelectorAll('tr');
                    for (var i = 0; i < linhas.length; i++) {
                        if (linhas[i].querySelector('th')) continue;
                        var texto = linhas[i].textContent.toLowerCase();
                        linhas[i].style.display = termo.length > 0 && texto.indexOf(termo) < 0 ? 'none' : '';
                    }
                }

                function mostrarErroCliente(messageId, mensagem, elemento) {
                    var aviso = document.getElementById(messageId);
                    if (aviso) {
                        aviso.textContent = mensagem;
                        aviso.classList.add('is-visible');
                    }

                    if (elemento) {
                        elemento.classList.add('field-error');
                        elemento.focus();
                    }
                }

                function limparErroCliente(messageId, ids) {
                    var aviso = document.getElementById(messageId);
                    if (aviso) {
                        aviso.textContent = '';
                        aviso.classList.remove('is-visible');
                    }

                    for (var i = 0; i < ids.length; i++) {
                        var item = campo(ids[i]);
                        if (item) item.classList.remove('field-error');
                    }
                }

                window.validarCampoObrigatorio = function (id, messageId, mensagem) {
                    var item = campo(id);
                    limparErroCliente(messageId, [id]);

                    if (!item || item.value.trim().length === 0) {
                        mostrarErroCliente(messageId, mensagem, item);
                        return false;
                    }

                    return true;
                };

                window.validarRamalCliente = function () {
                    var ids = [
                        '<%= txtNome.ClientID %>',
                        '<%= txtRamal.ClientID %>',
                        '<%= ddlRamalLoja.ClientID %>',
                        '<%= ddlRamalSetor.ClientID %>'
                    ];

                    limparErroCliente('ramalClientMessage', ids);

                    var nome = campo(ids[0]);
                    var ramal = campo(ids[1]);
                    var loja = campo(ids[2]);
                    var setor = campo(ids[3]);

                    if (!nome || nome.value.trim().length === 0) {
                        mostrarErroCliente('ramalClientMessage', 'Informe o nome do colaborador.', nome);
                        return false;
                    }

                    if (!ramal || ramal.value.trim().length === 0) {
                        mostrarErroCliente('ramalClientMessage', 'Informe o n\u00famero do ramal.', ramal);
                        return false;
                    }

                    if (!loja || loja.value === '0') {
                        mostrarErroCliente('ramalClientMessage', 'Selecione a loja do ramal.', loja);
                        return false;
                    }

                    if (!setor || setor.value === '0') {
                        mostrarErroCliente('ramalClientMessage', 'Selecione o setor do ramal.', setor);
                        return false;
                    }

                    return true;
                };

                var params = new URLSearchParams(window.location.search);
                var viewAtual = params.get('view') || 'consulta';
                var linkAtivo = document.querySelector('.side-nav a[href*="view=' + viewAtual + '"]');
                if (linkAtivo) linkAtivo.classList.add('is-active');

                var buscaRapida = campo('<%= txtBusca.ClientID %>');
                if (buscaRapida) buscaRapida.addEventListener('input', filtrarTabelaCarregada);
            })();
        </script>
    </form>
</body>
</html>
