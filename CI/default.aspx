<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="ci_default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Comunica&ccedil;&atilde;o Interna - CI</title>
    <link href="ci.css?v=20260625-ci-anotacoes" rel="stylesheet" />
</head>
<body class="ci-page">
    <form id="form1" runat="server">
        <a class="skip-link" href="#conteudo">Ir para o conte&uacute;do</a>
        <div class="app-shell">
            <aside class="sidebar">
                <a class="brand" href="default.aspx">
                    <span class="brand-mark">CI</span>
                    <span>
                        <strong>Comunica&ccedil;&atilde;o Interna</strong>
                        <small>Grupo Bali</small>
                    </span>
                </a>
                <nav class="side-nav" aria-label="Navega&ccedil;&atilde;o da CI">
                    <a href="default.aspx?view=bi" data-nav-view="bi">BI</a>
                    <a href="default.aspx?view=consulta" data-nav-view="consulta">Consulta</a>
                    <a href="default.aspx?view=nova" data-nav-view="nova">Nova CI</a>
                    <a href="default.aspx?view=anotacoes" data-nav-view="anotacoes">Anota&ccedil;&otilde;es</a>
                    <a href="erros.aspx" data-nav-view="logs">Logs</a>
                    <a href="../Intranet/index.html">Intranet</a>
                </nav>
            </aside>

            <main class="content" id="conteudo" tabindex="-1">
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
                        <a class="primary-link" href="default.aspx?view=nova">Criar CI</a>
                    </div>
                </header>

                <asp:Panel ID="pnlMensagem" runat="server" CssClass="form-message" Visible="false">
                    <asp:Literal ID="litMensagem" runat="server"></asp:Literal>
                </asp:Panel>
                <asp:HiddenField ID="hfSenhaEdicao" runat="server" />

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
                    <article>
                        <span>Este m&ecirc;s</span>
                        <strong><asp:Literal ID="litMesAtual" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Canceladas</span>
                        <strong><asp:Literal ID="litCanceladas" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Rascunhos</span>
                        <strong><asp:Literal ID="litRascunhos" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Revisadas</span>
                        <strong><asp:Literal ID="litRevisadas" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Fiat ativas</span>
                        <strong><asp:Literal ID="litFiat" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>Jeep ativas</span>
                        <strong><asp:Literal ID="litJeep" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                    <article>
                        <span>BYD ativas</span>
                        <strong><asp:Literal ID="litByd" runat="server" Text="0"></asp:Literal></strong>
                    </article>
                </section>

                <asp:Panel ID="pnlBi" runat="server" CssClass="panel bi-panel">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">BI</span>
                            <h2>Indicadores de CI</h2>
                            <p class="panel-subtitle"><asp:Literal ID="litBiPeriodo" runat="server" Text="Selecione o per&iacute;odo para analisar as comunica&ccedil;&otilde;es."></asp:Literal></p>
                        </div>
                    </div>
                    <div class="filter-grid bi-filter-grid">
                        <label>Data inicial
                            <asp:TextBox ID="txtBiInicio" runat="server" CssClass="text-field" TextMode="Date"></asp:TextBox>
                        </label>
                        <label>Data final
                            <asp:TextBox ID="txtBiFim" runat="server" CssClass="text-field" TextMode="Date"></asp:TextBox>
                        </label>
                        <label>Marca
                            <asp:DropDownList ID="ddlBiMarca" runat="server" CssClass="select-field">
                                <asp:ListItem Value="">Todas</asp:ListItem>
                                <asp:ListItem>Bali Fiat</asp:ListItem>
                                <asp:ListItem>Bali Jeep</asp:ListItem>
                                <asp:ListItem>Bali BYD</asp:ListItem>
                            </asp:DropDownList>
                        </label>
                        <asp:Button ID="btnAtualizarBi" runat="server" Text="Atualizar BI" CssClass="primary-button" OnClick="btnAtualizarBi_Click" />
                    </div>
                    <section class="summary-grid bi-summary">
                        <article><span>Total</span><strong><asp:Literal ID="litBiTotal" runat="server" Text="0"></asp:Literal></strong></article>
                        <article><span>Emitidas</span><strong><asp:Literal ID="litBiEmitidas" runat="server" Text="0"></asp:Literal></strong></article>
                        <article><span>Rascunhos</span><strong><asp:Literal ID="litBiRascunhos" runat="server" Text="0"></asp:Literal></strong></article>
                        <article><span>Revisadas</span><strong><asp:Literal ID="litBiRevisadas" runat="server" Text="0"></asp:Literal></strong></article>
                        <article><span>Canceladas</span><strong><asp:Literal ID="litBiCanceladas" runat="server" Text="0"></asp:Literal></strong></article>
                        <article><span>Ci&ecirc;ncias</span><strong><asp:Literal ID="litBiCiencias" runat="server" Text="0"></asp:Literal></strong></article>
                    </section>
                    <div class="bi-grid">
                        <article class="bi-card">
                            <h3>Por marca</h3>
                            <asp:Literal ID="litBiMarcas" runat="server"></asp:Literal>
                        </article>
                        <article class="bi-card">
                            <h3>Por categoria</h3>
                            <asp:Literal ID="litBiCategorias" runat="server"></asp:Literal>
                        </article>
                        <article class="bi-card">
                            <h3>Por prioridade</h3>
                            <asp:Literal ID="litBiPrioridades" runat="server"></asp:Literal>
                        </article>
                        <article class="bi-card">
                            <h3>Evolu&ccedil;&atilde;o por dia</h3>
                            <asp:Literal ID="litBiDias" runat="server"></asp:Literal>
                        </article>
                        <article class="bi-card">
                            <h3>Top destinos</h3>
                            <asp:Literal ID="litBiDestinos" runat="server"></asp:Literal>
                        </article>
                        <article class="bi-card">
                            <h3>Criado por</h3>
                            <asp:Literal ID="litBiCriadores" runat="server"></asp:Literal>
                        </article>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlAnotacoes" runat="server" CssClass="panel notes-panel">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Textos padr&atilde;o</span>
                            <h2>Anota&ccedil;&otilde;es</h2>
                            <p class="panel-subtitle"><asp:Literal ID="litResultadoAnotacoes" runat="server" Text="Cadastre textos para consultar, copiar e reutilizar nas CIs."></asp:Literal></p>
                        </div>
                        <asp:Button ID="btnNovaAnotacao" runat="server" Text="Nova anota&ccedil;&atilde;o" CssClass="secondary-button" OnClick="btnNovaAnotacao_Click" />
                    </div>

                    <div class="notes-layout">
                        <section class="notes-list">
                            <div class="notes-filter">
                                <label>Buscar
                                    <asp:TextBox ID="txtAnotacaoBusca" runat="server" CssClass="text-field" MaxLength="160" placeholder="Nome, categoria ou trecho do texto"></asp:TextBox>
                                </label>
                                <label>Categoria
                                    <asp:DropDownList ID="ddlAnotacaoCategoriaFiltro" runat="server" CssClass="select-field"></asp:DropDownList>
                                </label>
                                <div class="notes-filter-actions">
                                    <asp:Button ID="btnFiltrarAnotacoes" runat="server" Text="Filtrar" CssClass="primary-button" OnClick="btnFiltrarAnotacoes_Click" />
                                    <asp:Button ID="btnLimparAnotacoes" runat="server" Text="Limpar" CssClass="secondary-button" OnClick="btnLimparAnotacoes_Click" />
                                </div>
                            </div>
                            <div class="table-wrap">
                                <asp:GridView ID="gvAnotacoes" runat="server" CssClass="ci-table notes-table" AutoGenerateColumns="false" EmptyDataText="Nenhuma anota&ccedil;&atilde;o encontrada." OnRowCommand="gvAnotacoes_RowCommand" OnRowDataBound="gvAnotacoes_RowDataBound">
                                    <Columns>
                                        <asp:BoundField DataField="titulo" HeaderText="Nome" />
                                        <asp:BoundField DataField="categoria" HeaderText="Categoria" />
                                        <asp:BoundField DataField="resumo" HeaderText="Resumo" />
                                        <asp:BoundField DataField="dt_referencia" HeaderText="Atualizada" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                                        <asp:TemplateField HeaderText="A&ccedil;&otilde;es">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkAbrirAnotacao" runat="server" CssClass="table-action" CommandName="AbrirAnotacao" CommandArgument='<%# Eval("id_anotacao") %>'>Abrir</asp:LinkButton>
                                                <asp:LinkButton ID="lnkExcluirAnotacao" runat="server" CssClass="table-action danger" CommandName="ExcluirAnotacao" CommandArgument='<%# Eval("id_anotacao") %>' OnClientClick="return confirm('Deseja excluir esta anota&ccedil;&atilde;o?');">Excluir</asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </section>

                        <section class="notes-editor">
                            <asp:HiddenField ID="hfAnotacaoId" runat="server" />
                            <div class="notes-editor-header">
                                <div>
                                    <span class="eyebrow">Bloco de notas</span>
                                    <h3><asp:Literal ID="litTituloAnotacao" runat="server" Text="Nova anota&ccedil;&atilde;o"></asp:Literal></h3>
                                </div>
                                <button type="button" class="secondary-button" onclick="copiarAnotacaoCI()">Copiar texto</button>
                            </div>
                            <div id="ciNotesCopyStatus" class="copy-status" aria-live="polite"></div>
                            <div class="notes-form-grid">
                                <label>Nome do texto
                                    <asp:TextBox ID="txtAnotacaoTitulo" runat="server" CssClass="text-field" MaxLength="160" placeholder="Ex.: Venda direta SIA"></asp:TextBox>
                                </label>
                                <label>Categoria
                                    <asp:TextBox ID="txtAnotacaoCategoria" runat="server" CssClass="text-field" MaxLength="80" placeholder="Ex.: Venda direta, Financeiro"></asp:TextBox>
                                </label>
                                <label>Criado por
                                    <asp:TextBox ID="txtAnotacaoCriadoPor" runat="server" CssClass="text-field" MaxLength="160"></asp:TextBox>
                                </label>
                                <label class="wide">Texto padr&atilde;o
                                    <asp:TextBox ID="txtAnotacaoConteudo" runat="server" CssClass="textarea-field notes-textarea" TextMode="MultiLine" Rows="16" placeholder="Cole ou digite aqui o texto padr&atilde;o que ser&aacute; consultado depois."></asp:TextBox>
                                </label>
                            </div>
                            <div class="form-actions notes-actions">
                                <asp:Button ID="btnSalvarAnotacao" runat="server" Text="Salvar anota&ccedil;&atilde;o" CssClass="primary-button" OnClick="btnSalvarAnotacao_Click" />
                                <asp:Button ID="btnCancelarAnotacao" runat="server" Text="Limpar bloco" CssClass="secondary-button" OnClick="btnNovaAnotacao_Click" />
                            </div>
                        </section>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlConsulta" runat="server" CssClass="panel">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Consulta</span>
                            <h2>Localizar CIs</h2>
                            <p class="panel-subtitle"><asp:Literal ID="litResultadoConsulta" runat="server" Text="Use os filtros para localizar documentos internos."></asp:Literal></p>
                        </div>
                        <div class="panel-tools">
                            <label class="compact-label">Linhas
                                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="select-field compact-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
                                    <asp:ListItem Value="12">12</asp:ListItem>
                                    <asp:ListItem Value="25">25</asp:ListItem>
                                    <asp:ListItem Value="50">50</asp:ListItem>
                                </asp:DropDownList>
                            </label>
                            <asp:Button ID="btnExportar" runat="server" Text="Exportar CSV" CssClass="secondary-button" OnClick="btnExportar_Click" />
                            <asp:Button ID="btnLimpar" runat="server" Text="Limpar filtros" CssClass="secondary-button" OnClick="btnLimpar_Click" />
                        </div>
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
                        <label>Status
                            <asp:DropDownList ID="ddlFiltroStatus" runat="server" CssClass="select-field">
                                <asp:ListItem Value="">Todos</asp:ListItem>
                                <asp:ListItem>Rascunho</asp:ListItem>
                                <asp:ListItem>Emitida</asp:ListItem>
                                <asp:ListItem>Revisada</asp:ListItem>
                                <asp:ListItem>Cancelada</asp:ListItem>
                            </asp:DropDownList>
                        </label>
                        <label>Categoria
                            <asp:DropDownList ID="ddlFiltroCategoria" runat="server" CssClass="select-field">
                                <asp:ListItem Value="">Todas</asp:ListItem>
                                <asp:ListItem>Comunicado</asp:ListItem>
                                <asp:ListItem>Solicita&ccedil;&atilde;o</asp:ListItem>
                                <asp:ListItem>Autoriza&ccedil;&atilde;o</asp:ListItem>
                                <asp:ListItem>Procedimento</asp:ListItem>
                                <asp:ListItem>Financeiro</asp:ListItem>
                                <asp:ListItem>Administrativo</asp:ListItem>
                            </asp:DropDownList>
                        </label>
                        <label>Prioridade
                            <asp:DropDownList ID="ddlFiltroPrioridade" runat="server" CssClass="select-field">
                                <asp:ListItem Value="">Todas</asp:ListItem>
                                <asp:ListItem>Normal</asp:ListItem>
                                <asp:ListItem>Alta</asp:ListItem>
                                <asp:ListItem>Urgente</asp:ListItem>
                            </asp:DropDownList>
                        </label>
                        <label>Origem
                            <asp:TextBox ID="txtFiltroOrigem" runat="server" CssClass="text-field" MaxLength="120" placeholder="&Aacute;rea de origem"></asp:TextBox>
                        </label>
                        <label>Destino
                            <asp:TextBox ID="txtFiltroDestino" runat="server" CssClass="text-field" MaxLength="120" placeholder="&Aacute;rea de destino"></asp:TextBox>
                        </label>
                        <label>Criado por
                            <asp:TextBox ID="txtFiltroCriadoPor" runat="server" CssClass="text-field" MaxLength="160" placeholder="Respons&aacute;vel pelo cadastro"></asp:TextBox>
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
                    <div class="filter-shortcuts" aria-label="Atalhos de per&iacute;odo">
                        <button type="button" onclick="aplicarPeriodoCI('mes')">Este m&ecirc;s</button>
                        <button type="button" onclick="aplicarPeriodoCI('30')">&Uacute;ltimos 30 dias</button>
                        <button type="button" onclick="aplicarPeriodoCI('hoje')">Hoje</button>
                        <button type="button" onclick="aplicarPeriodoCI('limpar')">Limpar per&iacute;odo</button>
                    </div>

                    <div class="table-wrap">
                        <asp:GridView ID="gvCis" runat="server" CssClass="ci-table" AutoGenerateColumns="false" EmptyDataText="Nenhuma CI encontrada." AllowPaging="true" AllowSorting="true" PageSize="12" PagerStyle-CssClass="ci-pager" OnPageIndexChanging="gvCis_PageIndexChanging" OnSorting="gvCis_Sorting" OnRowCommand="gvCis_RowCommand" OnRowDataBound="gvCis_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="codigo_ci" HeaderText="C&oacute;digo" SortExpression="codigo_ci" />
                                <asp:BoundField DataField="data_documento" HeaderText="Data" DataFormatString="{0:dd/MM/yyyy}" SortExpression="data_documento" />
                                <asp:BoundField DataField="origem_marca" HeaderText="Marca" SortExpression="origem_marca" />
                                <asp:BoundField DataField="destinatario" HeaderText="Destinat&aacute;rio" SortExpression="destinatario" />
                                <asp:BoundField DataField="assunto" HeaderText="Assunto" SortExpression="assunto" />
                                <asp:BoundField DataField="status" HeaderText="Status" SortExpression="status" />
                                <asp:TemplateField HeaderText="A&ccedil;&otilde;es">
                                    <ItemTemplate>
                                        <a class="table-action" href='print.aspx?id=<%# Eval("id_ci") %>' target="_blank" rel="noopener">Imprimir</a>
                                        <asp:LinkButton ID="lnkDuplicar" runat="server" CssClass="table-action" CommandName="DuplicarCI" CommandArgument='<%# Eval("id_ci") %>'>Duplicar</asp:LinkButton>
                                        <asp:LinkButton ID="lnkDuplicarFiat" runat="server" CssClass="table-action subtle-action" CommandName="DuplicarMarcaCI" CommandArgument='<%# Eval("id_ci", "{0}|Bali Fiat") %>'>Dup Fiat</asp:LinkButton>
                                        <asp:LinkButton ID="lnkDuplicarJeep" runat="server" CssClass="table-action subtle-action" CommandName="DuplicarMarcaCI" CommandArgument='<%# Eval("id_ci", "{0}|Bali Jeep") %>'>Dup Jeep</asp:LinkButton>
                                        <asp:LinkButton ID="lnkDuplicarByd" runat="server" CssClass="table-action subtle-action" CommandName="DuplicarMarcaCI" CommandArgument='<%# Eval("id_ci", "{0}|Bali BYD") %>'>Dup BYD</asp:LinkButton>
                                        <asp:LinkButton ID="lnkEditar" runat="server" CssClass="table-action" CommandName="EditarCI" CommandArgument='<%# Eval("id_ci") %>' OnClientClick="return solicitarSenhaCI('editar', this);">Editar</asp:LinkButton>
                                        <asp:LinkButton ID="lnkCancelar" runat="server" CssClass="table-action danger" CommandName="CancelarCI" CommandArgument='<%# Eval("id_ci") %>' OnClientClick="return confirmarCancelamentoCI(this);">Cancelar</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlCadastro" runat="server" CssClass="panel">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Cadastro</span>
                            <h2><asp:Literal ID="litTituloForm" runat="server" Text="Nova CI"></asp:Literal></h2>
                        </div>
                        <asp:Button ID="btnNova" runat="server" Text="Nova CI" CssClass="secondary-button" OnClick="btnNova_Click" />
                    </div>

                    <asp:HiddenField ID="hfCiId" runat="server" />
                    <div id="ciClientMessage" class="client-message" aria-live="polite"></div>
                    <div class="ci-form-insights" aria-live="polite">
                        <article>
                            <span>Preenchimento</span>
                            <strong id="ciProgressText">0 de 7 campos</strong>
                            <div class="ci-progress"><span id="ciProgressBar"></span></div>
                        </article>
                        <article>
                            <span>Pr&eacute;via r&aacute;pida</span>
                            <strong id="ciPreviewTitle">Sem assunto informado</strong>
                            <p id="ciPreviewMeta">Selecione a marca, data e destino.</p>
                        </article>
                        <article>
                            <span>Texto</span>
                            <strong id="ciTextCount">0 caracteres</strong>
                            <p>Use uma comunica&ccedil;&atilde;o objetiva para facilitar a impress&atilde;o.</p>
                        </article>
                    </div>
                    <div class="ci-assistant">
                        <div>
                            <span class="eyebrow">Apoio de preenchimento</span>
                            <strong>Modelos edit&aacute;veis e rascunho local</strong>
                            <p id="ciDraftStatus">Aplique um modelo cadastrado ou salve um rascunho neste navegador.</p>
                        </div>
                        <div class="model-manager">
                            <label>Modelo
                                <asp:DropDownList ID="ddlModelosCI" runat="server" CssClass="select-field"></asp:DropDownList>
                            </label>
                            <asp:Button ID="btnAplicarModeloBanco" runat="server" Text="Aplicar modelo" CssClass="secondary-button" OnClick="btnAplicarModeloBanco_Click" />
                            <label>Nome do modelo
                                <asp:TextBox ID="txtModeloNome" runat="server" CssClass="text-field" MaxLength="120" placeholder="Ex.: comunicado de procedimento"></asp:TextBox>
                            </label>
                            <asp:LinkButton ID="lnkSalvarModelo" runat="server" CssClass="secondary-button" OnClick="lnkSalvarModelo_Click" OnClientClick="return solicitarSenhaCI('salvar modelo', this);">Salvar modelo</asp:LinkButton>
                            <asp:LinkButton ID="lnkExcluirModelo" runat="server" CssClass="secondary-button danger-button" OnClick="lnkExcluirModelo_Click" OnClientClick="return solicitarSenhaCI('excluir modelo', this);">Excluir modelo</asp:LinkButton>
                        </div>
                        <div class="assistant-actions">
                            <button type="button" onclick="salvarRascunhoCI()">Salvar rascunho</button>
                            <button type="button" onclick="restaurarRascunhoCI()">Restaurar</button>
                            <button type="button" onclick="limparRascunhoCI()">Limpar rascunho</button>
                        </div>
                    </div>
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
                        <label>Status da CI
                            <asp:DropDownList ID="ddlStatusCI" runat="server" CssClass="select-field">
                                <asp:ListItem>Emitida</asp:ListItem>
                                <asp:ListItem>Rascunho</asp:ListItem>
                                <asp:ListItem>Revisada</asp:ListItem>
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
                        <a class="secondary-link" href="default.aspx?view=consulta">Voltar para consulta</a>
                    </div>

                    <asp:Panel ID="pnlCiencia" runat="server" CssClass="ack-panel" Visible="false">
                        <div class="panel-header compact-header">
                            <div>
                                <span class="eyebrow">Ci&ecirc;ncia</span>
                                <h3>Controle de ci&ecirc;ncia</h3>
                                <p class="panel-subtitle">Registre setores ou respons&aacute;veis que tomaram ci&ecirc;ncia desta comunica&ccedil;&atilde;o.</p>
                            </div>
                        </div>
                        <div class="ack-form">
                            <label>Setor
                                <asp:TextBox ID="txtCienciaSetor" runat="server" CssClass="text-field" MaxLength="120"></asp:TextBox>
                            </label>
                            <label>Respons&aacute;vel
                                <asp:TextBox ID="txtCienciaResponsavel" runat="server" CssClass="text-field" MaxLength="160"></asp:TextBox>
                            </label>
                            <label>Observa&ccedil;&atilde;o
                                <asp:TextBox ID="txtCienciaObservacao" runat="server" CssClass="text-field" MaxLength="500"></asp:TextBox>
                            </label>
                            <asp:Button ID="btnRegistrarCiencia" runat="server" Text="Registrar ci&ecirc;ncia" CssClass="secondary-button" OnClick="btnRegistrarCiencia_Click" />
                        </div>
                        <div class="table-wrap">
                            <asp:GridView ID="gvCiencias" runat="server" CssClass="ci-table compact-table" AutoGenerateColumns="false" EmptyDataText="Nenhuma ci&ecirc;ncia registrada para esta CI." OnRowCommand="gvCiencias_RowCommand" OnRowDataBound="gvCiencias_RowDataBound">
                                <Columns>
                                    <asp:BoundField DataField="dt_ciencia" HeaderText="Data/hora" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                                    <asp:BoundField DataField="setor" HeaderText="Setor" />
                                    <asp:BoundField DataField="responsavel" HeaderText="Respons&aacute;vel" />
                                    <asp:BoundField DataField="observacao" HeaderText="Observa&ccedil;&atilde;o" />
                                    <asp:TemplateField HeaderText="A&ccedil;&otilde;es">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkExcluirCiencia" runat="server" CssClass="table-action danger" CommandName="ExcluirCiencia" CommandArgument='<%# Eval("id_ciencia") %>' OnClientClick="return solicitarSenhaCI('excluir ci&ecirc;ncia', this);">Excluir</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlHistorico" runat="server" CssClass="history-panel" Visible="false">
                        <div class="panel-header compact-header">
                            <div>
                                <span class="eyebrow">Auditoria</span>
                                <h3>Hist&oacute;rico da CI</h3>
                                <p class="panel-subtitle">Registros anteriores de altera&ccedil;&atilde;o e cancelamento.</p>
                            </div>
                        </div>
                        <div class="table-wrap">
                            <asp:GridView ID="gvHistorico" runat="server" CssClass="ci-table compact-table" AutoGenerateColumns="false" EmptyDataText="Nenhum hist&oacute;rico registrado para esta CI." OnRowDataBound="gvHistorico_RowDataBound">
                                <Columns>
                                    <asp:BoundField DataField="dt_evento" HeaderText="Data/hora" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                                    <asp:BoundField DataField="acao" HeaderText="A&ccedil;&atilde;o" />
                                    <asp:BoundField DataField="origem_marca" HeaderText="Marca" />
                                    <asp:BoundField DataField="assunto" HeaderText="Assunto anterior" />
                                    <asp:BoundField DataField="criado_por" HeaderText="Criado por" />
                                </Columns>
                            </asp:GridView>
                        </div>
                        <div class="panel-header compact-header history-detail-title">
                            <div>
                                <span class="eyebrow">Campos alterados</span>
                                <h3>Detalhamento das mudan&ccedil;as</h3>
                                <p class="panel-subtitle">Mostra o valor anterior e o novo valor gravado em cada edi&ccedil;&atilde;o.</p>
                            </div>
                        </div>
                        <div class="table-wrap">
                            <asp:GridView ID="gvHistoricoCampos" runat="server" CssClass="ci-table compact-table field-history-table" AutoGenerateColumns="false" EmptyDataText="Nenhuma altera&ccedil;&atilde;o de campo registrada para esta CI." OnRowDataBound="gvHistoricoCampos_RowDataBound">
                                <Columns>
                                    <asp:BoundField DataField="dt_evento" HeaderText="Data/hora" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                                    <asp:BoundField DataField="campo" HeaderText="Campo" />
                                    <asp:BoundField DataField="valor_antigo" HeaderText="Valor anterior" />
                                    <asp:BoundField DataField="valor_novo" HeaderText="Novo valor" />
                                    <asp:BoundField DataField="usuario" HeaderText="Usu&aacute;rio" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </asp:Panel>
                </asp:Panel>
            </main>
        </div>

        <div class="password-modal" id="modalSenhaCI" aria-hidden="true">
            <div class="password-dialog" role="dialog" aria-modal="true" aria-labelledby="tituloSenhaCI">
                <span class="eyebrow">Acesso protegido</span>
                <h3 id="tituloSenhaCI">Confirmar a&ccedil;&atilde;o na CI</h3>
                <p id="textoSenhaCI">Informe a senha para continuar.</p>
                <label>Senha
                    <input id="txtSenhaCICliente" class="text-field" type="password" autocomplete="current-password" />
                </label>
                <div class="modal-actions">
                    <button type="button" class="secondary-button" onclick="fecharSenhaCI();">Cancelar</button>
                    <button type="button" class="primary-button" onclick="confirmarSenhaCI();">Continuar</button>
                </div>
            </div>
        </div>

        <script>
            (function () {
                function marcarNavegacaoAtivaCI() {
                    var parametros = new URLSearchParams(window.location.search || '');
                    var tela = parametros.get('view') || 'consulta';
                    var caminho = (window.location.pathname || '').toLowerCase();
                    if (caminho.indexOf('/ci/erros.aspx') >= 0) tela = 'logs';

                    var links = document.querySelectorAll('.side-nav a[data-nav-view]');
                    for (var i = 0; i < links.length; i++) {
                        var ativo = links[i].getAttribute('data-nav-view') === tela;
                        links[i].classList.toggle('is-active', ativo);
                        if (ativo) links[i].setAttribute('aria-current', 'page');
                        else links[i].removeAttribute('aria-current');
                    }
                }

                marcarNavegacaoAtivaCI();

                var postbackCIPendente = null;
                var modalSenhaCI = document.getElementById('modalSenhaCI');
                var campoSenhaCI = document.getElementById('txtSenhaCICliente');
                var textoSenhaCI = document.getElementById('textoSenhaCI');
                var salvandoCI = false;
                var formularioAlterado = false;
                var temporizadorRascunhoCI = null;

                function executarPostbackCI() {
                    if (!postbackCIPendente) return;

                    var href = postbackCIPendente;
                    postbackCIPendente = null;
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

                window.solicitarSenhaCI = function (acao, link) {
                    postbackCIPendente = link ? link.getAttribute('href') : null;
                    if (textoSenhaCI) textoSenhaCI.textContent = 'Informe a senha para ' + (acao || 'continuar') + ' esta CI.';
                    if (campoSenhaCI) campoSenhaCI.value = '';
                    if (modalSenhaCI) modalSenhaCI.classList.add('is-open');
                    if (campoSenhaCI) window.setTimeout(function () { campoSenhaCI.focus(); }, 80);
                    return false;
                };

                window.confirmarCancelamentoCI = function (link) {
                    if (!window.confirm('Deseja cancelar esta CI?')) return false;
                    return window.solicitarSenhaCI('cancelar', link);
                };

                window.fecharSenhaCI = function () {
                    postbackCIPendente = null;
                    if (modalSenhaCI) modalSenhaCI.classList.remove('is-open');
                    if (campoSenhaCI) campoSenhaCI.value = '';
                };

                window.confirmarSenhaCI = function () {
                    var campoServidor = document.getElementById('<%= hfSenhaEdicao.ClientID %>');
                    if (campoServidor && campoSenhaCI) campoServidor.value = campoSenhaCI.value;
                    if (modalSenhaCI) modalSenhaCI.classList.remove('is-open');
                    executarPostbackCI();
                };

                window.copiarAnotacaoCI = function () {
                    var campoTexto = document.getElementById('<%= txtAnotacaoConteudo.ClientID %>');
                    var status = document.getElementById('ciNotesCopyStatus');
                    if (!campoTexto || campoTexto.value.trim().length === 0) {
                        if (status) {
                            status.textContent = 'Abra ou preencha uma anota\u00e7\u00e3o antes de copiar.';
                            status.classList.add('is-visible');
                        }
                        return;
                    }

                    function avisar(texto) {
                        if (!status) return;
                        status.textContent = texto;
                        status.classList.add('is-visible');
                    }

                    if (navigator.clipboard && navigator.clipboard.writeText) {
                        navigator.clipboard.writeText(campoTexto.value).then(function () {
                            avisar('Texto copiado para a \u00e1rea de transfer\u00eancia.');
                        }).catch(function () {
                            campoTexto.focus();
                            campoTexto.select();
                            avisar('Texto selecionado. Use Ctrl+C para copiar.');
                        });
                    } else {
                        campoTexto.focus();
                        campoTexto.select();
                        avisar('Texto selecionado. Use Ctrl+C para copiar.');
                    }
                };

                document.addEventListener('keydown', function (event) {
                    if (!modalSenhaCI || !modalSenhaCI.classList.contains('is-open')) return;
                    if (event.key === 'Escape') window.fecharSenhaCI();
                    if (event.key === 'Enter') {
                        event.preventDefault();
                        window.confirmarSenhaCI();
                    }
                });

                var camposObrigatorios = [
                    { id: '<%= txtData.ClientID %>', mensagem: 'Informe a data da CI.' },
                    { id: '<%= txtOrigemArea.ClientID %>', mensagem: 'Informe a \u00e1rea de origem.' },
                    { id: '<%= txtOrigemResponsavel.ClientID %>', mensagem: 'Informe o respons\u00e1vel pela origem.' },
                    { id: '<%= txtDestinoArea.ClientID %>', mensagem: 'Informe a \u00e1rea de destino.' },
                    { id: '<%= txtDestinatario.ClientID %>', mensagem: 'Informe o destinat\u00e1rio.' },
                    { id: '<%= txtAssunto.ClientID %>', mensagem: 'Informe o assunto.' },
                    { id: '<%= txtCorpo.ClientID %>', mensagem: 'Informe o texto da comunica\u00e7\u00e3o.' }
                ];
                var camposComModelo = [
                    '<%= txtAssunto.ClientID %>',
                    '<%= txtCorpo.ClientID %>',
                    '<%= txtProvidencias.ClientID %>',
                    '<%= txtObservacoes.ClientID %>'
                ];
                var limitesTextoCI = [
                    { id: '<%= txtCorpo.ClientID %>', nome: 'texto da comunica\u00e7\u00e3o', max: 6000 },
                    { id: '<%= txtProvidencias.ClientID %>', nome: 'provid\u00eancias solicitadas', max: 2500 },
                    { id: '<%= txtObservacoes.ClientID %>', nome: 'observa\u00e7\u00f5es', max: 1800 }
                ];

                function campo(id) {
                    return document.getElementById(id);
                }

                function formatarDataCI(data) {
                    var ano = data.getFullYear();
                    var mes = String(data.getMonth() + 1).padStart(2, '0');
                    var dia = String(data.getDate()).padStart(2, '0');
                    return ano + '-' + mes + '-' + dia;
                }

                window.aplicarPeriodoCI = function (tipo) {
                    var inicio = campo('<%= txtFiltroInicio.ClientID %>');
                    var fim = campo('<%= txtFiltroFim.ClientID %>');
                    if (!inicio || !fim) return;

                    var hoje = new Date();
                    var dataInicio = new Date(hoje.getFullYear(), hoje.getMonth(), hoje.getDate());
                    var dataFim = new Date(hoje.getFullYear(), hoje.getMonth(), hoje.getDate());

                    if (tipo === 'limpar') {
                        inicio.value = '';
                        fim.value = '';
                        return;
                    }

                    if (tipo === 'mes') {
                        dataInicio = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
                    } else if (tipo === '30') {
                        dataInicio.setDate(dataInicio.getDate() - 30);
                    }

                    inicio.value = formatarDataCI(dataInicio);
                    fim.value = formatarDataCI(dataFim);
                    var botaoFiltro = campo('<%= btnFiltrar.ClientID %>');
                    if (botaoFiltro) botaoFiltro.focus();
                };

                function limparErros() {
                    var aviso = document.getElementById('ciClientMessage');
                    if (aviso) {
                        aviso.textContent = '';
                        aviso.classList.remove('is-visible');
                    }

                    var camposParaLimpar = camposObrigatorios.map(function (item) { return item.id; }).concat(camposComModelo);
                    for (var i = 0; i < camposParaLimpar.length; i++) {
                        var item = campo(camposParaLimpar[i]);
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

                function valor(id) {
                    var item = campo(id);
                    return item ? item.value.trim() : '';
                }

                function contemMarcadorModelo(texto) {
                    return /\[[^\]]+\]/.test(texto || '');
                }

                function atualizarPainelCI() {
                    var preenchidos = 0;
                    var progressoTexto = document.getElementById('ciProgressText');
                    var progressoBarra = document.getElementById('ciProgressBar');
                    var previaTitulo = document.getElementById('ciPreviewTitle');
                    var previaMeta = document.getElementById('ciPreviewMeta');
                    var contadorTexto = document.getElementById('ciTextCount');
                    var cardTexto = contadorTexto ? contadorTexto.closest('article') : null;

                    for (var i = 0; i < camposObrigatorios.length; i++) {
                        if (valor(camposObrigatorios[i].id).length > 0) preenchidos++;
                    }

                    if (progressoTexto) progressoTexto.textContent = preenchidos + ' de ' + camposObrigatorios.length + ' campos';
                    if (progressoBarra) progressoBarra.style.width = Math.round((preenchidos / camposObrigatorios.length) * 100) + '%';

                    var marca = valor('<%= ddlMarca.ClientID %>') || 'Marca';
                    var status = valor('<%= ddlStatusCI.ClientID %>') || 'Emitida';
                    var data = valor('<%= txtData.ClientID %>') || 'sem data';
                    var destino = valor('<%= txtDestinatario.ClientID %>') || 'sem destinat\u00e1rio';
                    var assunto = valor('<%= txtAssunto.ClientID %>');
                    var corpo = valor('<%= txtCorpo.ClientID %>');

                    if (previaTitulo) previaTitulo.textContent = assunto || 'Sem assunto informado';
                    if (previaMeta) previaMeta.textContent = marca + ' | ' + status + ' | ' + data + ' | ' + destino;
                    if (contadorTexto) {
                        contadorTexto.textContent = corpo.length + ' caractere' + (corpo.length === 1 ? '' : 's');
                        if (cardTexto) cardTexto.classList.toggle('is-warning', corpo.length > 3000);
                    }
                }

                function statusRascunhoCI(texto) {
                    var status = document.getElementById('ciDraftStatus');
                    if (status) status.textContent = texto;
                }

                function camposRascunhoCI() {
                    return {
                        marca: valor('<%= ddlMarca.ClientID %>'),
                        data: valor('<%= txtData.ClientID %>'),
                        categoria: valor('<%= ddlCategoria.ClientID %>'),
                        prioridade: valor('<%= ddlPrioridade.ClientID %>'),
                        status: valor('<%= ddlStatusCI.ClientID %>'),
                        origemArea: valor('<%= txtOrigemArea.ClientID %>'),
                        origemResponsavel: valor('<%= txtOrigemResponsavel.ClientID %>'),
                        destinoArea: valor('<%= txtDestinoArea.ClientID %>'),
                        destinatario: valor('<%= txtDestinatario.ClientID %>'),
                        assunto: valor('<%= txtAssunto.ClientID %>'),
                        corpo: valor('<%= txtCorpo.ClientID %>'),
                        providencias: valor('<%= txtProvidencias.ClientID %>'),
                        observacoes: valor('<%= txtObservacoes.ClientID %>'),
                        criadoPor: valor('<%= txtCriadoPor.ClientID %>')
                    };
                }

                function rascunhoTemConteudoCI(dados) {
                    var campos = dados || camposRascunhoCI();
                    return [
                        campos.origemArea,
                        campos.origemResponsavel,
                        campos.destinoArea,
                        campos.destinatario,
                        campos.assunto,
                        campos.corpo,
                        campos.providencias,
                        campos.observacoes,
                        campos.criadoPor
                    ].join('').trim().length > 0;
                }

                function agendarRascunhoAutomaticoCI() {
                    if (salvandoCI) return;
                    window.clearTimeout(temporizadorRascunhoCI);
                    temporizadorRascunhoCI = window.setTimeout(function () {
                        try {
                            var dados = camposRascunhoCI();
                            if (!rascunhoTemConteudoCI(dados)) return;
                            localStorage.setItem('bali-ci-rascunho', JSON.stringify(dados));
                            var agora = new Date();
                            var horario = String(agora.getHours()).padStart(2, '0') + ':' + String(agora.getMinutes()).padStart(2, '0');
                            statusRascunhoCI('Rascunho salvo automaticamente \u00e0s ' + horario + '.');
                        } catch (erro) {
                            statusRascunhoCI('N\u00e3o foi poss\u00edvel salvar o rascunho automaticamente.');
                        }
                    }, 1200);
                }

                function preencherCampoCI(id, valorCampo) {
                    var item = campo(id);
                    if (item) item.value = valorCampo || '';
                }

                function ajustarTextareaCI(item) {
                    if (!item || item.tagName !== 'TEXTAREA') return;
                    item.style.height = 'auto';
                    item.style.height = Math.max(item.scrollHeight, 92) + 'px';
                }

                function ajustarTextareasCI() {
                    ajustarTextareaCI(campo('<%= txtCorpo.ClientID %>'));
                    ajustarTextareaCI(campo('<%= txtProvidencias.ClientID %>'));
                    ajustarTextareaCI(campo('<%= txtObservacoes.ClientID %>'));
                }

                function preencherRascunhoCI(dados) {
                    if (!dados) return;
                    preencherCampoCI('<%= ddlMarca.ClientID %>', dados.marca);
                    preencherCampoCI('<%= txtData.ClientID %>', dados.data);
                    preencherCampoCI('<%= ddlCategoria.ClientID %>', dados.categoria);
                    preencherCampoCI('<%= ddlPrioridade.ClientID %>', dados.prioridade);
                    preencherCampoCI('<%= ddlStatusCI.ClientID %>', dados.status || 'Emitida');
                    preencherCampoCI('<%= txtOrigemArea.ClientID %>', dados.origemArea);
                    preencherCampoCI('<%= txtOrigemResponsavel.ClientID %>', dados.origemResponsavel);
                    preencherCampoCI('<%= txtDestinoArea.ClientID %>', dados.destinoArea);
                    preencherCampoCI('<%= txtDestinatario.ClientID %>', dados.destinatario);
                    preencherCampoCI('<%= txtAssunto.ClientID %>', dados.assunto);
                    preencherCampoCI('<%= txtCorpo.ClientID %>', dados.corpo);
                    preencherCampoCI('<%= txtProvidencias.ClientID %>', dados.providencias);
                    preencherCampoCI('<%= txtObservacoes.ClientID %>', dados.observacoes);
                    preencherCampoCI('<%= txtCriadoPor.ClientID %>', dados.criadoPor);
                    atualizarPainelCI();
                    ajustarTextareasCI();
                }

                window.salvarRascunhoCI = function () {
                    try {
                        localStorage.setItem('bali-ci-rascunho', JSON.stringify(camposRascunhoCI()));
                        statusRascunhoCI('Rascunho salvo neste navegador.');
                    } catch (erro) {
                        statusRascunhoCI('N\u00e3o foi poss\u00edvel salvar o rascunho neste navegador.');
                    }
                };

                window.restaurarRascunhoCI = function () {
                    try {
                        var texto = localStorage.getItem('bali-ci-rascunho');
                        if (!texto) {
                            statusRascunhoCI('Nenhum rascunho salvo neste navegador.');
                            return;
                        }

                        preencherRascunhoCI(JSON.parse(texto));
                        statusRascunhoCI('Rascunho restaurado. Revise os dados antes de salvar.');
                    } catch (erro) {
                        statusRascunhoCI('N\u00e3o foi poss\u00edvel restaurar o rascunho.');
                    }
                };

                window.limparRascunhoCI = function () {
                    try {
                        localStorage.removeItem('bali-ci-rascunho');
                        statusRascunhoCI('Rascunho removido deste navegador.');
                    } catch (erro) {
                        statusRascunhoCI('N\u00e3o foi poss\u00edvel remover o rascunho.');
                    }
                };

                window.validarCICliente = function () {
                    limparErros();

                    for (var i = 0; i < camposObrigatorios.length; i++) {
                        var item = campo(camposObrigatorios[i].id);
                        if (!item || item.value.trim().length === 0) {
                            mostrarErro(camposObrigatorios[i].mensagem, item);
                            return false;
                        }
                    }

                    for (var p = 0; p < camposComModelo.length; p++) {
                        var campoModelo = campo(camposComModelo[p]);
                        if (campoModelo && contemMarcadorModelo(campoModelo.value)) {
                            mostrarErro('Substitua os trechos entre colchetes antes de salvar a CI.', campoModelo);
                            return false;
                        }
                    }

                    for (var l = 0; l < limitesTextoCI.length; l++) {
                        var limite = limitesTextoCI[l];
                        var campoLimite = campo(limite.id);
                        if (campoLimite && campoLimite.value.length > limite.max) {
                            mostrarErro('Reduza o campo ' + limite.nome + ' para at\u00e9 ' + limite.max + ' caracteres.', campoLimite);
                            return false;
                        }
                    }

                    if (salvandoCI) return false;
                    salvandoCI = true;
                    var botaoSalvar = campo('<%= btnSalvar.ClientID %>');
                    if (botaoSalvar) {
                        botaoSalvar.dataset.textoOriginal = botaoSalvar.value;
                        botaoSalvar.value = 'Salvando...';
                        botaoSalvar.classList.add('is-loading');
                        botaoSalvar.setAttribute('aria-busy', 'true');
                    }

                    return true;
                };

                var camposMonitorados = [];
                function adicionarMonitorado(id) {
                    if (camposMonitorados.indexOf(id) < 0) camposMonitorados.push(id);
                }

                for (var c = 0; c < camposObrigatorios.length; c++) adicionarMonitorado(camposObrigatorios[c].id);
                for (var t = 0; t < limitesTextoCI.length; t++) adicionarMonitorado(limitesTextoCI[t].id);
                adicionarMonitorado('<%= ddlMarca.ClientID %>');
                adicionarMonitorado('<%= ddlStatusCI.ClientID %>');
                adicionarMonitorado('<%= txtAssunto.ClientID %>');
                adicionarMonitorado('<%= txtCorpo.ClientID %>');

                for (var m = 0; m < camposMonitorados.length; m++) {
                    var monitorado = campo(camposMonitorados[m]);
                    if (!monitorado) continue;
                    monitorado.addEventListener('input', atualizarPainelCI);
                    monitorado.addEventListener('change', atualizarPainelCI);
                    monitorado.addEventListener('input', function () { ajustarTextareaCI(this); });
                    monitorado.addEventListener('input', function () { formularioAlterado = true; });
                    monitorado.addEventListener('change', function () { formularioAlterado = true; });
                    monitorado.addEventListener('input', agendarRascunhoAutomaticoCI);
                    monitorado.addEventListener('change', agendarRascunhoAutomaticoCI);
                }

                window.addEventListener('beforeunload', function (event) {
                    if (!formularioAlterado || salvandoCI) return;
                    event.preventDefault();
                    event.returnValue = '';
                });

                atualizarPainelCI();
                ajustarTextareasCI();
            })();
        </script>
    </form>
</body>
</html>
