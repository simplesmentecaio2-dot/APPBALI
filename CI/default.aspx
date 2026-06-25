<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="ci_default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Comunica&ccedil;&atilde;o Interna - CI</title>
    <link href="ci.css?v=20260625-ci-print" rel="stylesheet" />
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
                </section>

                <section class="panel" id="consulta">
                    <div class="panel-header">
                        <div>
                            <span class="eyebrow">Consulta</span>
                            <h2>Localizar CIs</h2>
                            <p class="panel-subtitle"><asp:Literal ID="litResultadoConsulta" runat="server" Text="Use os filtros para localizar documentos internos."></asp:Literal></p>
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

                    <div class="table-wrap">
                        <asp:GridView ID="gvCis" runat="server" CssClass="ci-table" AutoGenerateColumns="false" EmptyDataText="Nenhuma CI encontrada." AllowPaging="true" PageSize="12" PagerStyle-CssClass="ci-pager" OnPageIndexChanging="gvCis_PageIndexChanging" OnRowCommand="gvCis_RowCommand" OnRowDataBound="gvCis_RowDataBound">
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
                                        <asp:LinkButton ID="lnkEditar" runat="server" CssClass="table-action" CommandName="EditarCI" CommandArgument='<%# Eval("id_ci") %>' OnClientClick="return solicitarSenhaCI('editar', this);">Editar</asp:LinkButton>
                                        <asp:LinkButton ID="lnkCancelar" runat="server" CssClass="table-action danger" CommandName="CancelarCI" CommandArgument='<%# Eval("id_ci") %>' OnClientClick="return confirmarCancelamentoCI(this);">Cancelar</asp:LinkButton>
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
                var postbackCIPendente = null;
                var modalSenhaCI = document.getElementById('modalSenhaCI');
                var campoSenhaCI = document.getElementById('txtSenhaCICliente');
                var textoSenhaCI = document.getElementById('textoSenhaCI');
                var salvandoCI = false;

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

                function valor(id) {
                    var item = campo(id);
                    return item ? item.value.trim() : '';
                }

                function atualizarPainelCI() {
                    var preenchidos = 0;
                    var progressoTexto = document.getElementById('ciProgressText');
                    var progressoBarra = document.getElementById('ciProgressBar');
                    var previaTitulo = document.getElementById('ciPreviewTitle');
                    var previaMeta = document.getElementById('ciPreviewMeta');
                    var contadorTexto = document.getElementById('ciTextCount');

                    for (var i = 0; i < camposObrigatorios.length; i++) {
                        if (valor(camposObrigatorios[i].id).length > 0) preenchidos++;
                    }

                    if (progressoTexto) progressoTexto.textContent = preenchidos + ' de ' + camposObrigatorios.length + ' campos';
                    if (progressoBarra) progressoBarra.style.width = Math.round((preenchidos / camposObrigatorios.length) * 100) + '%';

                    var marca = valor('<%= ddlMarca.ClientID %>') || 'Marca';
                    var data = valor('<%= txtData.ClientID %>') || 'sem data';
                    var destino = valor('<%= txtDestinatario.ClientID %>') || 'sem destinat\u00e1rio';
                    var assunto = valor('<%= txtAssunto.ClientID %>');
                    var corpo = valor('<%= txtCorpo.ClientID %>');

                    if (previaTitulo) previaTitulo.textContent = assunto || 'Sem assunto informado';
                    if (previaMeta) previaMeta.textContent = marca + ' | ' + data + ' | ' + destino;
                    if (contadorTexto) contadorTexto.textContent = corpo.length + ' caractere' + (corpo.length === 1 ? '' : 's');
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

                    if (salvandoCI) return false;
                    salvandoCI = true;
                    var botaoSalvar = campo('<%= btnSalvar.ClientID %>');
                    if (botaoSalvar) {
                        botaoSalvar.dataset.textoOriginal = botaoSalvar.value;
                        botaoSalvar.value = 'Salvando...';
                        botaoSalvar.disabled = true;
                        botaoSalvar.classList.add('is-loading');
                    }

                    return true;
                };

                var camposMonitorados = [];
                function adicionarMonitorado(id) {
                    if (camposMonitorados.indexOf(id) < 0) camposMonitorados.push(id);
                }

                for (var c = 0; c < camposObrigatorios.length; c++) adicionarMonitorado(camposObrigatorios[c].id);
                adicionarMonitorado('<%= ddlMarca.ClientID %>');
                adicionarMonitorado('<%= txtAssunto.ClientID %>');
                adicionarMonitorado('<%= txtCorpo.ClientID %>');

                for (var m = 0; m < camposMonitorados.length; m++) {
                    var monitorado = campo(camposMonitorados[m]);
                    if (!monitorado) continue;
                    monitorado.addEventListener('input', atualizarPainelCI);
                    monitorado.addEventListener('change', atualizarPainelCI);
                }

                atualizarPainelCI();
            })();
        </script>
    </form>
</body>
</html>
