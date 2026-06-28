<%@ Page Language="C#" AutoEventWireup="true" CodeFile="sessoes.aspx.cs" Inherits="tecnologia_sessoes" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Sess&otilde;es ativas | Tecnologia</title>
    <link href="../css/bali-tecnologia.css?v=20260628-sessoes01" rel="stylesheet" />
</head>
<body class="bali-tech-page">
    <form id="form1" runat="server" autocomplete="off">
        <header class="tech-topbar">
            <a class="tech-brand" href="Default.aspx" aria-label="Voltar para tecnologia">
                <img src="../img/logobali.png?v=20260624-logo2" alt="Bali" />
                <span>APP</span>
            </a>
            <div class="tech-user">
                <span>Tecnologia</span>
                <strong><asp:Label ID="lblUsuario" runat="server" /></strong>
                <small>C&oacute;digo: <asp:Label ID="lblTipo" runat="server" /></small>
            </div>
            <nav class="tech-actions" aria-label="A&ccedil;&otilde;es r&aacute;pidas">
                <a href="Default.aspx">Voltar</a>
                <a href="../login.aspx?sair=1">Sair</a>
            </nav>
        </header>

        <main class="tech-main">
            <section class="tech-hero">
                <div>
                    <span class="tech-eyebrow">Sess&otilde;es &middot; Monitoramento</span>
                    <h1>Usu&aacute;rios ativos</h1>
                    <p>Veja quem est&aacute; logado, origem do acesso, tempo de login e &uacute;ltima atividade registrada pela regra de sess&atilde;o &uacute;nica.</p>
                </div>
                <label class="tech-search" for="techSearchSessions">
                    <span>Buscar sess&atilde;o</span>
                    <input id="techSearchSessions" type="search" autocomplete="off" autocapitalize="off" spellcheck="false" placeholder="Ex.: usu&aacute;rio, IP, loja, tela de login" />
                </label>
            </section>

            <section class="tech-session-summary" aria-label="Resumo das sess&otilde;es">
                <article>
                    <span>Sess&otilde;es ativas</span>
                    <strong><asp:Literal ID="litTotalAtivas" runat="server" /></strong>
                    <small>Registros ativos no APPWF</small>
                </article>
                <article>
                    <span>Usu&aacute;rios distintos</span>
                    <strong><asp:Literal ID="litUsuariosDistintos" runat="server" /></strong>
                    <small>Sem duplicidade ativa</small>
                </article>
                <article>
                    <span>Maior tempo logado</span>
                    <strong><asp:Literal ID="litMaiorTempo" runat="server" /></strong>
                    <small>Sess&atilde;o ativa mais antiga</small>
                </article>
                <article>
                    <span>&Uacute;ltima atividade</span>
                    <strong><asp:Literal ID="litUltimaAtividade" runat="server" /></strong>
                    <small><asp:Literal ID="litAtualizadoEm" runat="server" /></small>
                </article>
            </section>

            <section class="tech-panel">
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Controle de acesso</span>
                        <h2>Lista de sess&otilde;es ativas</h2>
                        <p>Quando o mesmo usu&aacute;rio entra em outro navegador ou dispositivo, a sess&atilde;o anterior &eacute; encerrada automaticamente.</p>
                    </div>
                    <asp:Button ID="btnAtualizar" runat="server" Text="Atualizar agora" CssClass="tech-button" OnClick="btnAtualizar_Click" />
                </div>

                <div class="tech-session-table-wrap">
                    <asp:Repeater ID="rptSessoes" runat="server">
                        <HeaderTemplate>
                            <table class="tech-table tech-session-table">
                                <thead>
                                    <tr>
                                        <th>Usu&aacute;rio</th>
                                        <th>C&oacute;digo</th>
                                        <th>Login em</th>
                                        <th>Tempo logado</th>
                                        <th>&Uacute;ltima atividade</th>
                                        <th>Inatividade</th>
                                        <th>Tempo restante</th>
                                        <th>IP</th>
                                        <th>Origem</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                                    <tr data-session-row data-search='<%# Html(String.Concat(Eval("usuario_nome"), " ", Eval("usuario_id"), " ", Eval("usuario_codigo"), " ", Eval("usuario_tipo"), " ", Eval("empresa"), " ", Eval("ip"), " ", Eval("url_login"))) %>'>
                                        <td>
                                            <strong class="tech-session-user"><%# Html(Eval("usuario_nome")) %></strong>
                                            <span class="tech-session-login"><%# Html(Eval("usuario_id")) %></span>
                                            <span class="tech-session-status">Ativa</span>
                                        </td>
                                        <td><%# Html(Eval("usuario_codigo")) %></td>
                                        <td><%# DataHora(Eval("data_login")) %></td>
                                        <td><strong><%# Duracao(Eval("segundos_logado")) %></strong></td>
                                        <td><%# DataHora(Eval("ultimo_acesso")) %></td>
                                        <td><%# Duracao(Eval("segundos_inativo")) %></td>
                                        <td><strong><%# Duracao(Eval("segundos_restantes")) %></strong></td>
                                        <td><code><%# Html(Eval("ip")) %></code></td>
                                        <td>
                                            <span class="tech-session-origin"><%# Origem(Eval("url_login")) %></span>
                                            <small><%# Html(Eval("empresa")) %></small>
                                        </td>
                                    </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>

                <asp:Panel ID="pnlSemSessoes" runat="server" CssClass="tech-empty" Visible="false">
                    Nenhuma sess&atilde;o ativa encontrada agora.
                </asp:Panel>
                <div id="techEmptySessions" class="tech-empty" hidden>Nenhuma sess&atilde;o encontrada para a busca informada.</div>
            </section>
        </main>
    </form>

    <script src="../js/bali-tecnologia.js?v=20260627-tech01"></script>
    <script>
        (function () {
            var input = document.getElementById('techSearchSessions');
            var empty = document.getElementById('techEmptySessions');
            if (!input) return;

            input.addEventListener('input', function () {
                var query = input.value.toLowerCase().trim();
                var rows = document.querySelectorAll('[data-session-row]');
                var visible = 0;

                for (var i = 0; i < rows.length; i++) {
                    var haystack = (rows[i].getAttribute('data-search') || rows[i].textContent || '').toLowerCase();
                    var show = !query || haystack.indexOf(query) >= 0;
                    rows[i].style.display = show ? '' : 'none';
                    if (show) visible++;
                }

                if (empty) {
                    empty.hidden = visible > 0 || rows.length === 0;
                }
            });
        })();
    </script>
</body>
</html>
