<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="ci_default" ValidateRequest="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Comunica&ccedil;&atilde;o Interna - CI</title>
    <link href="ci.css?v=20260626-ci-consulta02" rel="stylesheet" />
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

                <asp:Panel ID="pnlResumoBi" runat="server" CssClass="summary-grid">
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
                </asp:Panel>

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
                        <asp:Button ID="btnExportarBi" runat="server" Text="Exportar BI" CssClass="secondary-button" OnClick="btnExportarBi_Click" />
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
                        <article class="bi-card bi-card-wide">
                            <h3>Relat&oacute;rio por setor e destino</h3>
                            <asp:Literal ID="litBiSetorDestino" runat="server"></asp:Literal>
                        </article>
                        <article class="bi-card">
                            <h3>Criado por</h3>
                            <asp:Literal ID="litBiCriadores" runat="server"></asp:Literal>
                        </article>
                        <article class="bi-card">
                            <h3>Por status</h3>
                            <asp:Literal ID="litBiStatus" runat="server"></asp:Literal>
                        </article>
                        <article class="bi-card">
                            <h3>&Aacute;reas de origem</h3>
                            <asp:Literal ID="litBiOrigens" runat="server"></asp:Literal>
                        </article>
                        <article class="bi-card">
                            <h3>Sem ci&ecirc;ncia registrada</h3>
                            <asp:Literal ID="litBiSemCiencia" runat="server"></asp:Literal>
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
                                    <button type="button" class="secondary-button" onclick="filtrarFavoritasAnotacoesCI(true)">Somente favoritas</button>
                                    <button type="button" class="secondary-button" onclick="filtrarFavoritasAnotacoesCI(false)">Mostrar todas</button>
                                </div>
                            </div>
                            <div class="table-wrap">
                                <asp:GridView ID="gvAnotacoes" runat="server" CssClass="ci-table notes-table" AutoGenerateColumns="false" EmptyDataText="Nenhuma anota&ccedil;&atilde;o encontrada." OnRowCommand="gvAnotacoes_RowCommand" OnRowDataBound="gvAnotacoes_RowDataBound">
                                    <Columns>
                                        <asp:BoundField DataField="titulo" HeaderText="Nome" />
                                        <asp:TemplateField HeaderText="A&ccedil;&otilde;es">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkAbrirAnotacao" runat="server" CssClass="table-action" CommandName="AbrirAnotacao" CommandArgument='<%# Eval("id_anotacao") %>'>Abrir</asp:LinkButton>
                                                <asp:LinkButton ID="lnkUsarAnotacao" runat="server" CssClass="table-action" CommandName="UsarAnotacaoCI" CommandArgument='<%# Eval("id_anotacao") %>'>Usar na CI</asp:LinkButton>
                                                <asp:LinkButton ID="lnkDuplicarAnotacao" runat="server" CssClass="table-action subtle-action" CommandName="DuplicarAnotacao" CommandArgument='<%# Eval("id_anotacao") %>'>Duplicar</asp:LinkButton>
                                                <asp:LinkButton ID="lnkFavoritarAnotacao" runat="server" CssClass="table-action subtle-action" CommandName="FavoritarAnotacao" CommandArgument='<%# Eval("id_anotacao") %>'>Favorito</asp:LinkButton>
                                                <asp:LinkButton ID="lnkExcluirAnotacao" runat="server" CssClass="table-action danger" CommandName="ExcluirAnotacao" CommandArgument='<%# Eval("id_anotacao") %>' OnClientClick="return confirm('Deseja excluir esta anota&ccedil;&atilde;o?');">Excluir</asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="categoria" HeaderText="Categoria" />
                                        <asp:BoundField DataField="tags" HeaderText="Tags" />
                                        <asp:BoundField DataField="qtde_usos" HeaderText="Usos" />
                                        <asp:BoundField DataField="resumo" HeaderText="Resumo" />
                                        <asp:BoundField DataField="dt_referencia" HeaderText="Atualizada" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
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
                                <label>Tags
                                    <asp:TextBox ID="txtAnotacaoTags" runat="server" CssClass="text-field" MaxLength="300" placeholder="Ex.: SIA, BYD, pagamento"></asp:TextBox>
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
                                <asp:Literal ID="litAnotacaoUso" runat="server"></asp:Literal>
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

                    <div class="quick-open">
                        <label>Ir direto para uma CI
                            <asp:TextBox ID="txtCodigoRapido" runat="server" CssClass="text-field" MaxLength="60" placeholder="Ex.: CI-2026-0010, 2026-0010 ou 10"></asp:TextBox>
                        </label>
                        <asp:Button ID="btnAbrirCodigoRapido" runat="server" Text="Abrir CI" CssClass="primary-button" OnClick="btnAbrirCodigoRapido_Click" />
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
                            <asp:TextBox ID="txtBusca" runat="server" CssClass="text-field" placeholder="Assunto, &aacute;rea, destinat&aacute;rio ou texto" autocomplete="off"></asp:TextBox>
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
                        <button type="button" onclick="aplicarFiltroRapidoCI('emitidas')">Emitidas</button>
                        <button type="button" onclick="aplicarFiltroRapidoCI('minhas')">Minhas CIs</button>
                        <button type="button" onclick="aplicarFiltroRapidoCI('canceladas')">Canceladas</button>
                        <button type="button" onclick="aplicarFiltroRapidoCI('rascunhos')">Rascunhos</button>
                        <button type="button" onclick="aplicarFiltroRapidoCI('fiat')">Fiat</button>
                        <button type="button" onclick="aplicarFiltroRapidoCI('jeep')">Jeep</button>
                        <button type="button" onclick="aplicarFiltroRapidoCI('byd')">BYD</button>
                        <button type="button" onclick="aplicarPeriodoCI('limpar')">Limpar per&iacute;odo</button>
                    </div>
                    <asp:Literal ID="litResumoStatusConsulta" runat="server"></asp:Literal>

                    <div class="table-wrap">
                        <asp:GridView ID="gvCis" runat="server" CssClass="ci-table" AutoGenerateColumns="false" EmptyDataText="Nenhuma CI encontrada." AllowPaging="false" AllowSorting="true" PageSize="12" OnPageIndexChanging="gvCis_PageIndexChanging" OnSorting="gvCis_Sorting" OnRowCommand="gvCis_RowCommand" OnRowDataBound="gvCis_RowDataBound">
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
                                        <button type="button" class="table-action copy-action" data-ci-code='<%# Atributo(Eval("codigo_ci")) %>' onclick="copiarCodigoCI(this)">Copiar c&oacute;digo</button>
                                        <button type="button" class="table-action copy-action" data-ci-code='<%# Atributo(Eval("codigo_ci")) %>' data-ci-data='<%# Atributo(Eval("data_documento", "{0:dd/MM/yyyy}")) %>' data-ci-marca='<%# Atributo(Eval("origem_marca")) %>' data-ci-destino='<%# Atributo(Eval("destinatario")) %>' data-ci-assunto='<%# Atributo(Eval("assunto")) %>' onclick="copiarResumoCI(this)">Copiar resumo</button>
                                        <asp:LinkButton ID="lnkDuplicar" runat="server" CssClass="table-action duplicate-action" CommandName="DuplicarCI" CommandArgument='<%# Eval("id_ci") %>'>Duplicar CI</asp:LinkButton>
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
                    <div class="ci-custom-pager" aria-label="Paginação da consulta">
                        <asp:LinkButton ID="lnkPaginaPrimeira" runat="server" CssClass="secondary-button" CommandArgument="first" OnClick="lnkPagerConsulta_Click">Primeira</asp:LinkButton>
                        <asp:LinkButton ID="lnkPaginaAnterior" runat="server" CssClass="secondary-button" CommandArgument="prev" OnClick="lnkPagerConsulta_Click">Anterior</asp:LinkButton>
                        <asp:Literal ID="litPagerConsulta" runat="server"></asp:Literal>
                        <asp:LinkButton ID="lnkPaginaProxima" runat="server" CssClass="secondary-button" CommandArgument="next" OnClick="lnkPagerConsulta_Click">Pr&oacute;xima</asp:LinkButton>
                        <asp:LinkButton ID="lnkPaginaUltima" runat="server" CssClass="secondary-button" CommandArgument="last" OnClick="lnkPagerConsulta_Click">&Uacute;ltima</asp:LinkButton>
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
                    <asp:HiddenField ID="hfDataAlteradaPeloUsuario" runat="server" />
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
                        <article id="ciQualityCard">
                            <span>Qualidade</span>
                            <strong id="ciQualityText">Aten&ccedil;&atilde;o</strong>
                            <p id="ciQualityHint">Preencha os campos para avaliar a CI.</p>
                        </article>
                        <article>
                            <span>Sugest&atilde;o</span>
                            <strong id="ciCategorySuggestion">Categoria atual</strong>
                            <p id="ciCategoryHint">A categoria sugerida aparece conforme o texto digitado.</p>
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
                        <label class="wide rich-text-field">Texto da comunica&ccedil;&atilde;o
                            <asp:TextBox ID="txtCorpo" runat="server" CssClass="textarea-field rich-text-source" TextMode="MultiLine" Rows="9"></asp:TextBox>
                            <span class="rich-editor" data-source-id="<%= txtCorpo.ClientID %>" data-placeholder="Digite o texto da comunica&ccedil;&atilde;o">
                                <span class="rich-toolbar" aria-label="Formata&ccedil;&atilde;o do texto da comunica&ccedil;&atilde;o">
                                    <button type="button" data-rich-command="bold" title="Negrito"><strong>B</strong></button>
                                    <button type="button" data-rich-command="italic" title="It&aacute;lico"><em>I</em></button>
                                    <button type="button" data-rich-command="removeFormat" title="Limpar formata&ccedil;&atilde;o">Limpar</button>
                                    <button type="button" data-rich-color="#111827" title="Fonte preta"><span class="color-dot" style="background:#111827"></span></button>
                                    <button type="button" data-rich-color="#c9333a" title="Fonte vermelha"><span class="color-dot" style="background:#c9333a"></span></button>
                                    <button type="button" data-rich-color="#1969b3" title="Fonte azul"><span class="color-dot" style="background:#1969b3"></span></button>
                                    <button type="button" data-rich-color="#287246" title="Fonte verde"><span class="color-dot" style="background:#287246"></span></button>
                                    <button type="button" data-rich-highlight="#fff3bf" title="Destacar em amarelo"><span class="highlight-dot" style="background:#fff3bf"></span></button>
                                    <button type="button" data-rich-highlight="#dbeafe" title="Destacar em azul"><span class="highlight-dot" style="background:#dbeafe"></span></button>
                                </span>
                                <span class="rich-surface" contenteditable="true" role="textbox" aria-multiline="true" aria-label="Texto da comunica&ccedil;&atilde;o"></span>
                            </span>
                        </label>
                        <label class="wide rich-text-field">Provid&ecirc;ncias solicitadas
                            <asp:TextBox ID="txtProvidencias" runat="server" CssClass="textarea-field rich-text-source" TextMode="MultiLine" Rows="4"></asp:TextBox>
                            <span class="rich-editor" data-source-id="<%= txtProvidencias.ClientID %>" data-placeholder="Digite as provid&ecirc;ncias solicitadas">
                                <span class="rich-toolbar" aria-label="Formata&ccedil;&atilde;o das provid&ecirc;ncias">
                                    <button type="button" data-rich-command="bold" title="Negrito"><strong>B</strong></button>
                                    <button type="button" data-rich-command="italic" title="It&aacute;lico"><em>I</em></button>
                                    <button type="button" data-rich-command="removeFormat" title="Limpar formata&ccedil;&atilde;o">Limpar</button>
                                    <button type="button" data-rich-color="#111827" title="Fonte preta"><span class="color-dot" style="background:#111827"></span></button>
                                    <button type="button" data-rich-color="#c9333a" title="Fonte vermelha"><span class="color-dot" style="background:#c9333a"></span></button>
                                    <button type="button" data-rich-color="#1969b3" title="Fonte azul"><span class="color-dot" style="background:#1969b3"></span></button>
                                    <button type="button" data-rich-color="#287246" title="Fonte verde"><span class="color-dot" style="background:#287246"></span></button>
                                    <button type="button" data-rich-highlight="#fff3bf" title="Destacar em amarelo"><span class="highlight-dot" style="background:#fff3bf"></span></button>
                                    <button type="button" data-rich-highlight="#dbeafe" title="Destacar em azul"><span class="highlight-dot" style="background:#dbeafe"></span></button>
                                </span>
                                <span class="rich-surface" contenteditable="true" role="textbox" aria-multiline="true" aria-label="Provid&ecirc;ncias solicitadas"></span>
                            </span>
                        </label>
                        <label class="wide rich-text-field">Observa&ccedil;&otilde;es
                            <asp:TextBox ID="txtObservacoes" runat="server" CssClass="textarea-field rich-text-source" TextMode="MultiLine" Rows="3"></asp:TextBox>
                            <span class="rich-editor" data-source-id="<%= txtObservacoes.ClientID %>" data-placeholder="Digite observa&ccedil;&otilde;es complementares">
                                <span class="rich-toolbar" aria-label="Formata&ccedil;&atilde;o das observa&ccedil;&otilde;es">
                                    <button type="button" data-rich-command="bold" title="Negrito"><strong>B</strong></button>
                                    <button type="button" data-rich-command="italic" title="It&aacute;lico"><em>I</em></button>
                                    <button type="button" data-rich-command="removeFormat" title="Limpar formata&ccedil;&atilde;o">Limpar</button>
                                    <button type="button" data-rich-color="#111827" title="Fonte preta"><span class="color-dot" style="background:#111827"></span></button>
                                    <button type="button" data-rich-color="#c9333a" title="Fonte vermelha"><span class="color-dot" style="background:#c9333a"></span></button>
                                    <button type="button" data-rich-color="#1969b3" title="Fonte azul"><span class="color-dot" style="background:#1969b3"></span></button>
                                    <button type="button" data-rich-color="#287246" title="Fonte verde"><span class="color-dot" style="background:#287246"></span></button>
                                    <button type="button" data-rich-highlight="#fff3bf" title="Destacar em amarelo"><span class="highlight-dot" style="background:#fff3bf"></span></button>
                                    <button type="button" data-rich-highlight="#dbeafe" title="Destacar em azul"><span class="highlight-dot" style="background:#dbeafe"></span></button>
                                </span>
                                <span class="rich-surface" contenteditable="true" role="textbox" aria-multiline="true" aria-label="Observa&ccedil;&otilde;es"></span>
                            </span>
                        </label>
                        <label><span class="field-label-line">Criado por <span class="required-mark">obrigat&oacute;rio</span></span>
                            <asp:TextBox ID="txtCriadoPor" runat="server" CssClass="text-field" MaxLength="160" placeholder="Nome de quem est&aacute; criando a CI"></asp:TextBox>
                        </label>
                    </div>

                    <div class="ci-checklist" aria-label="Checklist final da CI">
                        <div>
                            <span class="eyebrow">Checklist final</span>
                            <strong>Confer&ecirc;ncia antes de emitir</strong>
                            <p>Obrigat&oacute;rio para CI emitida ou revisada. Rascunhos podem ser salvos incompletos.</p>
                        </div>
                        <label class="check-option">
                            <asp:CheckBox ID="chkChecklistDocumento" runat="server" />
                            <span>Documento, data e marca conferidos</span>
                        </label>
                        <label class="check-option">
                            <asp:CheckBox ID="chkChecklistDestino" runat="server" />
                            <span>Origem, destino e destinat&aacute;rio conferidos</span>
                        </label>
                        <label class="check-option">
                            <asp:CheckBox ID="chkChecklistTexto" runat="server" />
                            <span>Texto revisado, sem campos de modelo pendentes</span>
                        </label>
                    </div>

                    <div class="form-actions">
                        <asp:Button ID="btnSalvar" runat="server" Text="Salvar CI" CssClass="primary-button" OnClick="btnSalvar_Click" OnClientClick="return validarCICliente();" />
                        <asp:Button ID="btnSalvarRascunhoBanco" runat="server" Text="Salvar rascunho no banco" CssClass="secondary-button" OnClick="btnSalvarRascunhoBanco_Click" OnClientClick="return validarCriadoPorCI();" />
                        <button type="button" class="secondary-button" onclick="abrirPreviaImpressaoCI()">Pr&eacute;via de impress&atilde;o</button>
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
                            <asp:GridView ID="gvHistorico" runat="server" CssClass="ci-table compact-table" AutoGenerateColumns="false" EmptyDataText="Nenhum hist&oacute;rico registrado para esta CI." OnRowCommand="gvHistorico_RowCommand" OnRowDataBound="gvHistorico_RowDataBound">
                                <Columns>
                                    <asp:BoundField DataField="dt_evento" HeaderText="Data/hora" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                                    <asp:BoundField DataField="acao" HeaderText="A&ccedil;&atilde;o" />
                                    <asp:BoundField DataField="origem_marca" HeaderText="Marca" />
                                    <asp:BoundField DataField="status_ci" HeaderText="Status anterior" />
                                    <asp:BoundField DataField="assunto" HeaderText="Assunto anterior" />
                                    <asp:BoundField DataField="criado_por" HeaderText="Criado por" />
                                    <asp:TemplateField HeaderText="A&ccedil;&otilde;es">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkRestaurarHistorico" runat="server" CssClass="table-action" CommandName="RestaurarHistorico" CommandArgument='<%# Eval("id_historico") %>' OnClientClick="return solicitarSenhaCI('restaurar vers&atilde;o anterior', this);">Restaurar</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
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

                window.copiarCodigoCI = function (botao) {
                    var codigo = botao ? (botao.getAttribute('data-ci-code') || '') : '';
                    if (!codigo) return;

                    function avisarCopiado() {
                        var textoOriginal = botao.textContent;
                        botao.textContent = 'Copiado';
                        botao.classList.add('is-copied');
                        window.setTimeout(function () {
                            botao.textContent = textoOriginal;
                            botao.classList.remove('is-copied');
                        }, 1400);
                    }

                    if (navigator.clipboard && navigator.clipboard.writeText) {
                        navigator.clipboard.writeText(codigo).then(avisarCopiado).catch(function () {
                            window.prompt('Copie o c\u00f3digo da CI:', codigo);
                        });
                    } else {
                        window.prompt('Copie o c\u00f3digo da CI:', codigo);
                    }
                };

                window.copiarResumoCI = function (botao) {
                    if (!botao) return;

                    var codigo = botao.getAttribute('data-ci-code') || '';
                    var data = botao.getAttribute('data-ci-data') || '';
                    var marca = botao.getAttribute('data-ci-marca') || '';
                    var destino = botao.getAttribute('data-ci-destino') || '';
                    var assunto = botao.getAttribute('data-ci-assunto') || '';
                    var resumo = [
                        'CI: ' + codigo,
                        'Data: ' + data,
                        'Marca: ' + marca,
                        'Destino: ' + destino,
                        'Assunto: ' + assunto
                    ].join('\n');

                    function avisarCopiado() {
                        var textoOriginal = botao.textContent;
                        botao.textContent = 'Resumo copiado';
                        botao.classList.add('is-copied');
                        window.setTimeout(function () {
                            botao.textContent = textoOriginal;
                            botao.classList.remove('is-copied');
                        }, 1600);
                    }

                    if (navigator.clipboard && navigator.clipboard.writeText) {
                        navigator.clipboard.writeText(resumo).then(avisarCopiado).catch(function () {
                            window.prompt('Copie o resumo da CI:', resumo);
                        });
                    } else {
                        window.prompt('Copie o resumo da CI:', resumo);
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
                    { id: '<%= txtCorpo.ClientID %>', mensagem: 'Informe o texto da comunica\u00e7\u00e3o.' },
                    { id: '<%= txtCriadoPor.ClientID %>', mensagem: 'Informe quem est\u00e1 criando a CI no campo Criado por.', sempre: true }
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
                var camposRichTextCI = [
                    '<%= txtCorpo.ClientID %>',
                    '<%= txtProvidencias.ClientID %>',
                    '<%= txtObservacoes.ClientID %>'
                ];
                var dataInicialCI = valor('<%= txtData.ClientID %>');
                var checklistFinalCI = [
                    { id: '<%= chkChecklistDocumento.ClientID %>', mensagem: 'Confirme que documento, data e marca foram conferidos.' },
                    { id: '<%= chkChecklistDestino.ClientID %>', mensagem: 'Confirme que origem, destino e destinat\u00e1rio foram conferidos.' },
                    { id: '<%= chkChecklistTexto.ClientID %>', mensagem: 'Confirme que o texto foi revisado e n\u00e3o possui campos pendentes.' }
                ];

                function campo(id) {
                    return document.getElementById(id);
                }

                function lembrarCriadoPorCI() {
                    var criadoPor = campo('<%= txtCriadoPor.ClientID %>');
                    if (!criadoPor) return;

                    try {
                        var salvo = (localStorage.getItem('bali-ci-criado-por') || '').trim();
                        if (criadoPor.value.trim().length === 0 && salvo.length > 0) {
                            criadoPor.value = salvo;
                            formularioAlterado = false;
                            atualizarPainelCI();
                        }

                        criadoPor.addEventListener('change', function () {
                            var nome = criadoPor.value.trim();
                            if (nome.length > 0) localStorage.setItem('bali-ci-criado-por', nome);
                        });
                    } catch (erroLocalStorage) {
                    }
                }

                function formatarDataCI(data) {
                    var ano = data.getFullYear();
                    var mes = String(data.getMonth() + 1).padStart(2, '0');
                    var dia = String(data.getDate()).padStart(2, '0');
                    return ano + '-' + mes + '-' + dia;
                }

                function clicarBotaoFiltrarCI() {
                    var botaoFiltro = campo('<%= btnFiltrar.ClientID %>');
                    if (botaoFiltro) botaoFiltro.click();
                }

                function selecionarFiltroCI(id, valorSelecionado) {
                    var lista = campo(id);
                    if (!lista) return;
                    for (var i = 0; i < lista.options.length; i++) {
                        if (lista.options[i].value === valorSelecionado || lista.options[i].text === valorSelecionado) {
                            lista.selectedIndex = i;
                            return;
                        }
                    }
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
                        clicarBotaoFiltrarCI();
                        return;
                    }

                    if (tipo === 'mes') {
                        dataInicio = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
                    } else if (tipo === '30') {
                        dataInicio.setDate(dataInicio.getDate() - 30);
                    }

                    inicio.value = formatarDataCI(dataInicio);
                    fim.value = formatarDataCI(dataFim);
                    clicarBotaoFiltrarCI();
                };

                window.aplicarFiltroRapidoCI = function (tipo) {
                    var status = '<%= ddlFiltroStatus.ClientID %>';
                    var marca = '<%= ddlFiltroMarca.ClientID %>';
                    var somenteAtivas = campo('<%= chkSomenteAtivas.ClientID %>');
                    if (tipo === 'emitidas') {
                        selecionarFiltroCI(status, 'Emitida');
                        if (somenteAtivas) somenteAtivas.checked = true;
                        clicarBotaoFiltrarCI();
                        return;
                    }

                    if (tipo === 'canceladas') {
                        selecionarFiltroCI(status, 'Cancelada');
                        if (somenteAtivas) somenteAtivas.checked = false;
                        clicarBotaoFiltrarCI();
                        return;
                    }

                    if (tipo === 'rascunhos') {
                        selecionarFiltroCI(status, 'Rascunho');
                        if (somenteAtivas) somenteAtivas.checked = true;
                        clicarBotaoFiltrarCI();
                        return;
                    }

                    if (tipo === 'fiat' || tipo === 'jeep' || tipo === 'byd') {
                        var marcas = {
                            fiat: 'Bali Fiat',
                            jeep: 'Bali Jeep',
                            byd: 'Bali BYD'
                        };
                        selecionarFiltroCI(marca, marcas[tipo]);
                        clicarBotaoFiltrarCI();
                        return;
                    }

                    if (tipo === 'minhas') {
                        var filtroCriadoPor = campo('<%= txtFiltroCriadoPor.ClientID %>');
                        var origemCriadoPor = campo('<%= txtCriadoPor.ClientID %>');
                        var nome = filtroCriadoPor && filtroCriadoPor.value ? filtroCriadoPor.value.trim() : '';
                        if (!nome && origemCriadoPor && origemCriadoPor.value) nome = origemCriadoPor.value.trim();
                        try {
                            if (!nome) nome = (localStorage.getItem('bali-ci-criado-por') || '').trim();
                        } catch (erroLocalStorage) {
                            nome = nome || '';
                        }

                        if (!nome) {
                            nome = window.prompt('Informe o nome usado no campo Criado por:') || '';
                            nome = nome.trim();
                        }

                        if (!nome) return;
                        if (filtroCriadoPor) filtroCriadoPor.value = nome;
                        try { localStorage.setItem('bali-ci-criado-por', nome); } catch (erroSalvarNome) {}
                        clicarBotaoFiltrarCI();
                    }
                };

                window.filtrarFavoritasAnotacoesCI = function (somenteFavoritas) {
                    var linhas = document.querySelectorAll('#<%= gvAnotacoes.ClientID %> tr');
                    for (var i = 0; i < linhas.length; i++) {
                        if (linhas[i].querySelector('th')) continue;
                        var favorita = linhas[i].classList.contains('is-favorite-row');
                        linhas[i].style.display = somenteFavoritas && !favorita ? 'none' : '';
                    }
                };

                function limparErros() {
                    var aviso = document.getElementById('ciClientMessage');
                    if (aviso) {
                        aviso.textContent = '';
                        aviso.classList.remove('is-visible');
                    }

                    var camposParaLimpar = camposObrigatorios.map(function (item) { return item.id; }).concat(camposComModelo);
                    for (var c = 0; c < checklistFinalCI.length; c++) camposParaLimpar.push(checklistFinalCI[c].id);
                    for (var i = 0; i < camposParaLimpar.length; i++) {
                        var item = campo(camposParaLimpar[i]);
                        if (item) item.classList.remove('field-error');
                        var editor = editorDoCampoRichCI(camposParaLimpar[i]);
                        if (editor) editor.classList.remove('field-error');
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
                        var alvoFoco = elemento;
                        if (ehCampoRichTextCI(elemento.id)) {
                            var editor = editorDoCampoRichCI(elemento.id);
                            if (editor) {
                                editor.classList.add('field-error');
                                alvoFoco = editor.querySelector('.rich-surface') || editor;
                            }
                        }
                        if (alvoFoco && typeof alvoFoco.focus === 'function') alvoFoco.focus();
                    }
                }

                function valor(id) {
                    var item = campo(id);
                    if (item && ehCampoRichTextCI(id)) return textoPlanoRichCI(item.value).trim();
                    return item ? item.value.trim() : '';
                }

                function valorBrutoCI(id) {
                    var item = campo(id);
                    return item ? item.value.trim() : '';
                }

                function ehCampoRichTextCI(id) {
                    return camposRichTextCI && camposRichTextCI.indexOf(id) >= 0;
                }

                function editorDoCampoRichCI(id) {
                    var editores = document.querySelectorAll('.rich-editor[data-source-id]');
                    for (var i = 0; i < editores.length; i++) {
                        if (editores[i].getAttribute('data-source-id') === id) return editores[i];
                    }
                    return null;
                }

                function textoPlanoRichCI(html) {
                    var div = document.createElement('div');
                    div.innerHTML = String(html || '').replace(/<br\s*\/?>/gi, '\n').replace(/<\/p>|<\/div>/gi, '\n');
                    return (div.textContent || div.innerText || '').replace(/\u00a0/g, ' ');
                }

                function htmlParaEditorCI(valorCampo) {
                    var texto = String(valorCampo || '');
                    if (/<[a-z][\s\S]*>/i.test(texto)) return sanitizarHtmlRichCI(texto);
                    var partes = texto.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split(/\n+/);
                    var html = '';
                    for (var i = 0; i < partes.length; i++) {
                        if (partes[i].trim().length === 0) continue;
                        html += '<p>' + htmlSeguroCI(partes[i]) + '</p>';
                    }
                    return html || '';
                }

                function sanitizarHtmlRichCI(html) {
                    var raiz = document.createElement('div');
                    raiz.innerHTML = String(html || '');
                    var permitidas = {
                        STRONG: true,
                        B: true,
                        EM: true,
                        I: true,
                        U: true,
                        SPAN: true,
                        MARK: true,
                        P: true,
                        DIV: true,
                        BR: true
                    };
                    var coresSeguras = /^#([0-9a-f]{3}|[0-9a-f]{6})$/i;

                    function limpar(no) {
                        if (no.nodeType === 3) return document.createTextNode(no.nodeValue || '');
                        if (no.nodeType !== 1) return document.createTextNode('');

                        var nome = no.nodeName.toUpperCase();
                        if (!permitidas[nome]) {
                            var fragmento = document.createDocumentFragment();
                            while (no.firstChild) fragmento.appendChild(limpar(no.firstChild));
                            return fragmento;
                        }

                        var tag = nome === 'B' ? 'strong' : (nome === 'I' ? 'em' : (nome === 'DIV' ? 'p' : nome.toLowerCase()));
                        var novo = document.createElement(tag);
                        if (tag === 'span') {
                            var cor = (no.style && no.style.color) ? normalizarCorRichCI(no.style.color) : '';
                            var fundo = (no.style && no.style.backgroundColor) ? normalizarCorRichCI(no.style.backgroundColor) : '';
                            if (cor) novo.style.color = cor;
                            if (fundo) novo.style.backgroundColor = fundo;
                        }

                        while (no.firstChild) novo.appendChild(limpar(no.firstChild));
                        return novo;
                    }

                    function normalizarCorRichCI(cor) {
                        cor = String(cor || '').trim();
                        var mapa = {
                            'rgb(17, 24, 39)': '#111827',
                            'rgb(201, 51, 58)': '#c9333a',
                            'rgb(25, 105, 179)': '#1969b3',
                            'rgb(40, 114, 70)': '#287246',
                            'rgb(255, 243, 191)': '#fff3bf',
                            'rgb(219, 234, 254)': '#dbeafe'
                        };
                        if (mapa[cor]) return mapa[cor];
                        return coresSeguras.test(cor) ? cor : '';
                    }

                    var saida = document.createElement('div');
                    while (raiz.firstChild) saida.appendChild(limpar(raiz.firstChild));
                    return saida.innerHTML;
                }

                function sincronizarEditorRichCI(editor) {
                    if (!editor) return;
                    var source = campo(editor.getAttribute('data-source-id'));
                    var surface = editor.querySelector('.rich-surface');
                    if (!source || !surface) return;
                    source.value = sanitizarHtmlRichCI(surface.innerHTML).trim();
                    source.dispatchEvent(new Event('input', { bubbles: true }));
                }

                function sincronizarEditoresRichCI() {
                    var editores = document.querySelectorAll('.rich-editor[data-source-id]');
                    for (var i = 0; i < editores.length; i++) sincronizarEditorRichCI(editores[i]);
                }

                function atualizarEditorRichCI(id) {
                    var editor = editorDoCampoRichCI(id);
                    if (!editor) return;
                    var source = campo(id);
                    var surface = editor.querySelector('.rich-surface');
                    if (!source || !surface) return;
                    surface.innerHTML = htmlParaEditorCI(source.value);
                }

                function inicializarEditoresRichCI() {
                    var editores = document.querySelectorAll('.rich-editor[data-source-id]');
                    for (var i = 0; i < editores.length; i++) {
                        (function (editor) {
                            var source = campo(editor.getAttribute('data-source-id'));
                            var surface = editor.querySelector('.rich-surface');
                            if (!source || !surface) return;

                            surface.setAttribute('data-placeholder', editor.getAttribute('data-placeholder') || '');
                            surface.innerHTML = htmlParaEditorCI(source.value);

                            surface.addEventListener('input', function () {
                                sincronizarEditorRichCI(editor);
                                formularioAlterado = true;
                                atualizarPainelCI();
                                agendarRascunhoAutomaticoCI();
                            });

                            surface.addEventListener('paste', function (event) {
                                event.preventDefault();
                                var texto = (event.clipboardData || window.clipboardData).getData('text/plain');
                                document.execCommand('insertText', false, texto);
                            });

                            var botoes = editor.querySelectorAll('.rich-toolbar button');
                            for (var b = 0; b < botoes.length; b++) {
                                botoes[b].addEventListener('click', function () {
                                    surface.focus();
                                    document.execCommand('styleWithCSS', false, true);
                                    var comando = this.getAttribute('data-rich-command');
                                    var cor = this.getAttribute('data-rich-color');
                                    var destaque = this.getAttribute('data-rich-highlight');

                                    if (comando) document.execCommand(comando, false, null);
                                    if (cor) document.execCommand('foreColor', false, cor);
                                    if (destaque) document.execCommand('hiliteColor', false, destaque);
                                    sincronizarEditorRichCI(editor);
                                    atualizarPainelCI();
                                });
                            }
                        })(editores[i]);
                    }
                }

                function contemMarcadorModelo(texto) {
                    return /\[[^\]]+\]/.test(texto || '');
                }

                function sugerirCategoriaCI(texto) {
                    var base = (texto || '').toLowerCase();
                    if (/financeir|pagamento|boleto|nota fiscal|nf|desconto|reembolso|credito|cr\u00e9dito/.test(base)) return 'Financeiro';
                    if (/autoriza|aprovacao|aprova\u00e7\u00e3o|permissao|permiss\u00e3o/.test(base)) return 'Autoriza\u00e7\u00e3o';
                    if (/solicita|solicito|pedido|precisamos|necessario|necess\u00e1rio/.test(base)) return 'Solicita\u00e7\u00e3o';
                    if (/procedimento|processo|fluxo|regra|orientacao|orienta\u00e7\u00e3o/.test(base)) return 'Procedimento';
                    if (/administrativ|documento|arquivo|cadastro|setor/.test(base)) return 'Administrativo';
                    return 'Comunicado';
                }

                function avaliarQualidadeCI(preenchidos, corpo, assunto) {
                    var status = valor('<%= ddlStatusCI.ClientID %>');
                    var score = 100;
                    var pendencias = [];
                    var faltantes = camposObrigatorios.length - preenchidos;
                    if (faltantes > 0) {
                        score -= faltantes * 10;
                        pendencias.push('campos obrigat\u00f3rios pendentes');
                    }
                    if ((assunto || '').length < 8) {
                        score -= 10;
                        pendencias.push('assunto muito curto');
                    }
                    if ((corpo || '').length > 0 && corpo.length < 40) {
                        score -= 12;
                        pendencias.push('texto muito curto');
                    }
                    if (corpo.length > 3200) {
                        score -= 8;
                        pendencias.push('texto longo para impress\u00e3o');
                    }
                    if (contemMarcadorModelo(assunto) || contemMarcadorModelo(corpo)) {
                        score -= 25;
                        pendencias.push('trechos de modelo pendentes');
                    }
                    if (status !== 'Rascunho') {
                        for (var q = 0; q < checklistFinalCI.length; q++) {
                            var check = campo(checklistFinalCI[q].id);
                            if (!check || !check.checked) {
                                score -= 8;
                                if (pendencias.indexOf('checklist final pendente') < 0) pendencias.push('checklist final pendente');
                            }
                        }
                    }

                    if (score >= 85) return { texto: 'Completa', classe: 'is-success', dica: 'CI pronta para emiss\u00e3o.' };
                    if (score >= 60) return { texto: 'Aten\u00e7\u00e3o', classe: 'is-warning', dica: 'Revise: ' + pendencias.slice(0, 2).join(' e ') + '.' };
                    return { texto: 'Risco de erro', classe: 'is-danger', dica: 'Corrija antes de emitir: ' + pendencias.slice(0, 2).join(' e ') + '.' };
                }

                function atualizarPainelCI() {
                    var preenchidos = 0;
                    var progressoTexto = document.getElementById('ciProgressText');
                    var progressoBarra = document.getElementById('ciProgressBar');
                    var previaTitulo = document.getElementById('ciPreviewTitle');
                    var previaMeta = document.getElementById('ciPreviewMeta');
                    var contadorTexto = document.getElementById('ciTextCount');
                    var cardTexto = contadorTexto ? contadorTexto.closest('article') : null;
                    var cardQualidade = document.getElementById('ciQualityCard');
                    var textoQualidade = document.getElementById('ciQualityText');
                    var dicaQualidade = document.getElementById('ciQualityHint');
                    var sugestaoCategoria = document.getElementById('ciCategorySuggestion');
                    var dicaCategoria = document.getElementById('ciCategoryHint');

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

                    var qualidade = avaliarQualidadeCI(preenchidos, corpo, assunto);
                    if (cardQualidade) {
                        cardQualidade.classList.remove('is-success', 'is-warning', 'is-danger');
                        cardQualidade.classList.add(qualidade.classe);
                    }
                    if (textoQualidade) textoQualidade.textContent = qualidade.texto;
                    if (dicaQualidade) dicaQualidade.textContent = qualidade.dica;

                    var textoParaSugestao = [assunto, corpo, valor('<%= txtProvidencias.ClientID %>'), valor('<%= txtObservacoes.ClientID %>')].join(' ');
                    var sugerida = sugerirCategoriaCI(textoParaSugestao);
                    var atual = valor('<%= ddlCategoria.ClientID %>') || 'Comunicado';
                    if (sugestaoCategoria) sugestaoCategoria.textContent = sugerida;
                    if (dicaCategoria) {
                        dicaCategoria.textContent = sugerida === atual
                            ? 'Categoria coerente com o texto.'
                            : 'Considere trocar de ' + atual + ' para ' + sugerida + '.';
                    }
                }

                function statusRascunhoCI(texto) {
                    var status = document.getElementById('ciDraftStatus');
                    if (status) status.textContent = texto;
                }

                function camposRascunhoCI() {
                    sincronizarEditoresRichCI();
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
                        corpo: valorBrutoCI('<%= txtCorpo.ClientID %>'),
                        providencias: valorBrutoCI('<%= txtProvidencias.ClientID %>'),
                        observacoes: valorBrutoCI('<%= txtObservacoes.ClientID %>'),
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
                    if (item) {
                        item.value = valorCampo || '';
                        if (ehCampoRichTextCI(id)) atualizarEditorRichCI(id);
                    }
                }

                function dataLocalHojeCI() {
                    return formatarDataCI(new Date());
                }

                function sincronizarDataNovaCI() {
                    var idCI = campo('<%= hfCiId.ClientID %>');
                    var dataCI = campo('<%= txtData.ClientID %>');
                    var dataAlterada = campo('<%= hfDataAlteradaPeloUsuario.ClientID %>');
                    if (!idCI || !dataCI || !dataAlterada) return;
                    if ((idCI.value || '').trim().length > 0) return;
                    if (dataAlterada.value === '1') return;

                    var hoje = dataLocalHojeCI();
                    if (!dataCI.value || dataCI.value < hoje) {
                        dataCI.value = hoje;
                    }
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

                function htmlSeguroCI(texto) {
                    return String(texto || '')
                        .replace(/&/g, '&amp;')
                        .replace(/</g, '&lt;')
                        .replace(/>/g, '&gt;')
                        .replace(/"/g, '&quot;')
                        .replace(/'/g, '&#039;');
                }

                function textoParagrafosCI(texto) {
                    var bruto = String(texto || '');
                    if (/<[a-z][\s\S]*>/i.test(bruto)) {
                        var html = sanitizarHtmlRichCI(bruto);
                        return html.trim().length > 0 ? html : '<p>A definir.</p>';
                    }

                    var partes = bruto.replace(/\r\n/g, '\n').split(/\n+/);
                    var html = '';
                    for (var i = 0; i < partes.length; i++) {
                        if (partes[i].trim().length === 0) continue;
                        html += '<p>' + htmlSeguroCI(partes[i]) + '</p>';
                    }
                    return html || '<p>A definir.</p>';
                }

                function formatarDataPreviaCI(valorData) {
                    if (!/^\d{4}-\d{2}-\d{2}$/.test(valorData || '')) return valorData || 'sem data';
                    return valorData.substring(8, 10) + '/' + valorData.substring(5, 7) + '/' + valorData.substring(0, 4);
                }

                window.abrirPreviaImpressaoCI = function () {
                    var dados = camposRascunhoCI();
                    var janela = window.open('', '_blank', 'noopener,noreferrer');
                    if (!janela) {
                        mostrarErro('N\u00e3o foi poss\u00edvel abrir a pr\u00e9via. Verifique o bloqueador de pop-ups.', null);
                        return;
                    }

                    var marca = dados.marca || 'Grupo Bali';
                    var cor = marca.indexOf('Jeep') >= 0 ? '#287246' : (marca.indexOf('BYD') >= 0 ? '#1969b3' : '#c9333a');
                    var documento = '<!doctype html><html lang="pt-br"><head><meta charset="utf-8"><title>Pr\u00e9via da CI</title>' +
                        '<style>@page{size:A4;margin:10mm}body{margin:0;background:#dfe6ef;font-family:Arial,Helvetica,sans-serif;color:#172033}.sheet{width:210mm;min-height:297mm;margin:18px auto;padding:14mm;background:#fff;box-shadow:0 20px 60px rgba(15,23,42,.18)}header{display:flex;justify-content:space-between;gap:18px;border-bottom:3px solid ' + cor + ';padding-bottom:12px}.brand{display:grid;place-items:center;min-width:180px;min-height:64px;border-radius:10px;padding:12px 18px;color:#fff;background:' + cor + ';font-weight:900}.title{text-align:right}.title span,.meta>div>span,.grid>div>span,.block>span,footer span{color:#64748b;font-size:11px;font-weight:900;text-transform:uppercase}.title h1{margin:5px 0 0;color:' + cor + ';font-size:24px}.meta,.grid{display:grid;gap:10px;margin-top:14px}.meta{grid-template-columns:repeat(5,1fr)}.grid{grid-template-columns:repeat(2,1fr)}.meta div,.grid div,.block{border:1px solid #d9e1ed;border-radius:8px;padding:10px}.meta strong,.grid strong,.grid small{display:block;margin-top:4px}.block{margin-top:12px}.block h2{margin:5px 0 0;font-size:18px}.block p{margin:8px 0 0;line-height:1.45}.block mark,.block span[style*=background-color]{border-radius:3px;padding:0 2px;-webkit-print-color-adjust:exact;print-color-adjust:exact}footer{display:grid;grid-template-columns:1fr 1fr;gap:22px;margin-top:22px}.sig{border-top:1px solid #94a3b8;padding-top:8px;text-align:center}@media print{body{background:#fff}.sheet{width:auto;min-height:auto;margin:0;padding:0;box-shadow:none}.meta{grid-template-columns:repeat(5,1fr)!important}.grid,footer{grid-template-columns:repeat(2,1fr)!important}}</style></head><body><main class="sheet">' +
                        '<header><div class="brand">' + htmlSeguroCI(marca) + '</div><div class="title"><span>Comunica\u00e7\u00e3o Interna</span><h1>Pr\u00e9via</h1></div></header>' +
                        '<section class="meta"><div><span>Data</span><strong>' + htmlSeguroCI(formatarDataPreviaCI(dados.data)) + '</strong></div><div><span>Marca</span><strong>' + htmlSeguroCI(marca) + '</strong></div><div><span>Categoria</span><strong>' + htmlSeguroCI(dados.categoria) + '</strong></div><div><span>Prioridade</span><strong>' + htmlSeguroCI(dados.prioridade) + '</strong></div><div><span>Status</span><strong>' + htmlSeguroCI(dados.status) + '</strong></div></section>' +
                        '<section class="grid"><div><span>Origem</span><strong>' + htmlSeguroCI(dados.origemArea || 'A definir') + '</strong><small>' + htmlSeguroCI(dados.origemResponsavel || 'A definir') + '</small></div><div><span>Destino</span><strong>' + htmlSeguroCI(dados.destinoArea || 'A definir') + '</strong><small>' + htmlSeguroCI(dados.destinatario || 'A definir') + '</small></div></section>' +
                        '<section class="block"><span>Assunto</span><h2>' + htmlSeguroCI(dados.assunto || 'Sem assunto informado') + '</h2></section>' +
                        '<section class="block"><span>Comunica\u00e7\u00e3o</span>' + textoParagrafosCI(dados.corpo) + '</section>';

                    if ((dados.providencias || '').trim().length > 0) documento += '<section class="block"><span>Provid\u00eancias solicitadas</span>' + textoParagrafosCI(dados.providencias) + '</section>';
                    if ((dados.observacoes || '').trim().length > 0) documento += '<section class="block"><span>Observa\u00e7\u00f5es</span>' + textoParagrafosCI(dados.observacoes) + '</section>';
                    documento += '<footer><div><span>Emitido por</span><strong>' + htmlSeguroCI(dados.criadoPor || 'A definir') + '</strong><small>Pr\u00e9via sem grava\u00e7\u00e3o</small></div><div class="sig"><span>Assinatura / ci\u00eancia</span></div></footer></main></body></html>';

                    janela.document.open();
                    janela.document.write(documento);
                    janela.document.close();
                    janela.focus();
                };

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

                function revisarTextoAntesDeSalvarCI() {
                    var avisos = [];
                    var camposTexto = [
                        { nome: 'Assunto', id: '<%= txtAssunto.ClientID %>' },
                        { nome: 'Texto da comunica\u00e7\u00e3o', id: '<%= txtCorpo.ClientID %>' },
                        { nome: 'Provid\u00eancias', id: '<%= txtProvidencias.ClientID %>' },
                        { nome: 'Observa\u00e7\u00f5es', id: '<%= txtObservacoes.ClientID %>' }
                    ];

                    for (var i = 0; i < camposTexto.length; i++) {
                        var item = camposTexto[i];
                        var textoCampo = valor(item.id);
                        if (!textoCampo) continue;

                        if (/\s{3,}/.test(textoCampo)) avisos.push(item.nome + ': existem espa\u00e7os repetidos.');
                        if (/[!?.,;:]{2,}/.test(textoCampo)) avisos.push(item.nome + ': existe pontua\u00e7\u00e3o repetida.');
                        if (/\b(vc|vcs|pq|qdo|tbm|tb|blz)\b/i.test(textoCampo)) avisos.push(item.nome + ': h\u00e1 abrevia\u00e7\u00f5es informais.');
                        if (/\b(nao|voce|sera|area|atencao|autorizacao|comunicacao|informacao)\b/i.test(textoCampo)) avisos.push(item.nome + ': revise palavras sem acento.');
                    }

                    if (avisos.length === 0) return true;
                    return window.confirm('Revis\u00e3o r\u00e1pida encontrou pontos de aten\u00e7\u00e3o:\\n\\n- ' + avisos.slice(0, 6).join('\\n- ') + '\\n\\nDeseja salvar mesmo assim?');
                }

                window.validarCICliente = function () {
                    limparErros();
                    sincronizarEditoresRichCI();
                    sincronizarDataNovaCI();

                    var ehRascunho = valor('<%= ddlStatusCI.ClientID %>') === 'Rascunho';
                    for (var i = 0; i < camposObrigatorios.length; i++) {
                        var item = campo(camposObrigatorios[i].id);
                        var campoData = camposObrigatorios[i].id === '<%= txtData.ClientID %>';
                        var sempreObrigatorio = campoData || camposObrigatorios[i].sempre;
                        var preenchido = ehCampoRichTextCI(camposObrigatorios[i].id) ? valor(camposObrigatorios[i].id).length > 0 : (item && item.value.trim().length > 0);
                        if ((!ehRascunho || sempreObrigatorio) && !preenchido) {
                            mostrarErro(camposObrigatorios[i].mensagem, item);
                            return false;
                        }
                    }

                    if (!ehRascunho) {
                        for (var p = 0; p < camposComModelo.length; p++) {
                            var campoModelo = campo(camposComModelo[p]);
                            if (campoModelo && contemMarcadorModelo(valor(camposComModelo[p]))) {
                                mostrarErro('Substitua os trechos entre colchetes antes de salvar a CI.', campoModelo);
                                return false;
                            }
                        }

                        for (var q = 0; q < checklistFinalCI.length; q++) {
                            var check = campo(checklistFinalCI[q].id);
                            if (!check || !check.checked) {
                                mostrarErro(checklistFinalCI[q].mensagem, check);
                                return false;
                            }
                        }
                    }

                    for (var l = 0; l < limitesTextoCI.length; l++) {
                        var limite = limitesTextoCI[l];
                        var campoLimite = campo(limite.id);
                        var tamanhoCampo = ehCampoRichTextCI(limite.id) ? valor(limite.id).length : (campoLimite ? campoLimite.value.length : 0);
                        if (campoLimite && tamanhoCampo > limite.max) {
                            mostrarErro('Reduza o campo ' + limite.nome + ' para at\u00e9 ' + limite.max + ' caracteres.', campoLimite);
                            return false;
                        }
                    }

                    if (!revisarTextoAntesDeSalvarCI()) {
                        return false;
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

                window.validarCriadoPorCI = function () {
                    limparErros();
                    var criadoPor = campo('<%= txtCriadoPor.ClientID %>');
                    if (!criadoPor || criadoPor.value.trim().length === 0) {
                        mostrarErro('Informe quem est\u00e1 criando a CI no campo Criado por.', criadoPor);
                        return false;
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
                adicionarMonitorado('<%= ddlCategoria.ClientID %>');
                adicionarMonitorado('<%= ddlPrioridade.ClientID %>');
                adicionarMonitorado('<%= ddlStatusCI.ClientID %>');
                adicionarMonitorado('<%= txtAssunto.ClientID %>');
                adicionarMonitorado('<%= txtCorpo.ClientID %>');
                for (var k = 0; k < checklistFinalCI.length; k++) adicionarMonitorado(checklistFinalCI[k].id);

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

                var campoDataCI = campo('<%= txtData.ClientID %>');
                var marcadorDataAlteradaCI = campo('<%= hfDataAlteradaPeloUsuario.ClientID %>');
                if (campoDataCI && marcadorDataAlteradaCI) {
                    campoDataCI.addEventListener('input', function () {
                        marcadorDataAlteradaCI.value = campoDataCI.value === dataInicialCI ? '' : '1';
                    });
                    campoDataCI.addEventListener('change', function () {
                        marcadorDataAlteradaCI.value = campoDataCI.value === dataInicialCI ? '' : '1';
                    });
                }

                window.addEventListener('beforeunload', function (event) {
                    if (!formularioAlterado || salvandoCI) return;
                    event.preventDefault();
                    event.returnValue = '';
                });

                inicializarEditoresRichCI();
                atualizarPainelCI();
                ajustarTextareasCI();
                lembrarCriadoPorCI();
            })();
        </script>
    </form>
</body>
</html>
