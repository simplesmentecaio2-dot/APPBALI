<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ControleAcessorios.aspx.cs" Inherits="tecnologia_ControleAcessorios" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Controle de acess&oacute;rios | Tecnologia</title>
    <link href="../css/bali-tecnologia.css?v=20260628-sessoes01" rel="stylesheet" />
    <style>
        .accessory-summary {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 12px;
            margin-bottom: 14px;
        }

        .accessory-summary article {
            border: 1px solid var(--tech-line);
            border-radius: var(--tech-radius);
            background: #fff;
            box-shadow: 0 12px 26px rgba(15, 23, 42, .06);
            padding: 14px;
        }

        .accessory-summary span,
        .accessory-table small {
            display: block;
            color: var(--tech-muted);
            font-size: 11px;
            font-weight: 900;
            line-height: 1.35;
        }

        .accessory-summary strong {
            display: block;
            color: var(--tech-ink);
            font-size: 24px;
            font-weight: 950;
            line-height: 1;
            margin-top: 8px;
        }

        .accessory-alert {
            border: 1px solid var(--tech-line);
            border-radius: var(--tech-radius);
            margin: 0 0 12px;
            padding: 12px 14px;
            font-size: 13px;
            font-weight: 850;
        }

        .accessory-alert.is-success {
            border-color: rgba(25, 169, 116, .26);
            background: #ecfdf3;
            color: #047857;
        }

        .accessory-alert.is-error {
            border-color: rgba(220, 38, 38, .20);
            background: #fff1f2;
            color: #9f1239;
        }

        .accessory-tools {
            display: grid;
            grid-template-columns: minmax(240px, 420px) auto;
            align-items: end;
            gap: 14px;
            margin-bottom: 14px;
        }

        .accessory-buttons {
            display: flex;
            flex-wrap: wrap;
            justify-content: flex-end;
            gap: 8px;
        }

        .accessory-table-wrap {
            overflow-x: auto;
            border-radius: var(--tech-radius);
        }

        .accessory-table {
            min-width: 1280px;
        }

        .accessory-table td {
            vertical-align: top;
        }

        .accessory-table strong {
            display: block;
            color: var(--tech-ink);
            font-size: 12px;
            font-weight: 950;
        }

        .accessory-table code {
            color: var(--tech-brand-strong);
            font-size: 11px;
            font-weight: 900;
        }

        .accessory-row.is-issued td {
            background: #eefaf2 !important;
        }

        .accessory-row.is-issued:hover td {
            background: #e5f6eb !important;
        }

        .accessory-check {
            width: 46px;
            text-align: center !important;
        }

        .accessory-check input {
            width: 17px;
            height: 17px;
            accent-color: var(--tech-brand);
            cursor: pointer;
        }

        .accessory-status {
            display: inline-flex;
            align-items: center;
            min-height: 26px;
            padding: 0 9px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 950;
            white-space: nowrap;
        }

        .accessory-status.is-issued {
            background: #dcfce7;
            color: #047857;
        }

        .accessory-status.is-pending {
            background: #fff7ed;
            color: #c2410c;
        }

        .accessory-mark small {
            margin-top: 4px;
        }

        @media (max-width: 980px) {
            .accessory-summary {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .accessory-tools {
                grid-template-columns: 1fr;
            }

            .accessory-buttons {
                justify-content: stretch;
            }

            .accessory-buttons input {
                flex: 1 1 180px;
            }
        }

        @media (max-width: 560px) {
            .accessory-summary {
                grid-template-columns: 1fr;
            }
        }
    </style>
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
                    <span class="tech-eyebrow">Acess&oacute;rios &middot; Notas fiscais</span>
                    <h1>Controle de acess&oacute;rios</h1>
                    <p>Acompanhe os lan&ccedil;amentos em aberto do fornecedor de acess&oacute;rios e marque as linhas em que as NFs j&aacute; foram emitidas.</p>
                </div>
                <label class="tech-search" for="accessorySearch">
                    <span>Buscar na listagem</span>
                    <input id="accessorySearch" type="search" autocomplete="off" autocapitalize="off" spellcheck="false" placeholder="Ex.: chassi, loja, fornecedor, ve&iacute;culo" />
                </label>
            </section>

            <section class="accessory-summary" aria-label="Resumo do controle">
                <article>
                    <span>Total em aberto</span>
                    <strong><asp:Literal ID="litTotal" runat="server" /></strong>
                    <small>Retorno atual da query</small>
                </article>
                <article>
                    <span>NFs emitidas</span>
                    <strong><asp:Literal ID="litEmitidos" runat="server" /></strong>
                    <small>J&aacute; marcadas no controle</small>
                </article>
                <article>
                    <span>Pendentes</span>
                    <strong><asp:Literal ID="litPendentes" runat="server" /></strong>
                    <small>Ainda sem marca&ccedil;&atilde;o</small>
                </article>
                <article>
                    <span>Saldo pendente</span>
                    <strong><asp:Literal ID="litSaldoPendente" runat="server" /></strong>
                    <small>Somente linhas pendentes</small>
                </article>
                <article>
                    <span>Primeiro vencimento</span>
                    <strong><asp:Literal ID="litPrimeiroVencimento" runat="server" /></strong>
                    <small><asp:Literal ID="litAtualizacao" runat="server" /></small>
                </article>
            </section>

            <section class="tech-panel">
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Listagem online</span>
                        <h2>Lan&ccedil;amentos de acess&oacute;rios</h2>
                        <p>Ao atualizar, a tela consulta novamente o sistema. Se um registro j&aacute; foi marcado antes e continuar aparecendo, ele volta em verde automaticamente.</p>
                    </div>
                </div>

                <asp:Literal ID="litMensagem" runat="server" />

                <div class="accessory-tools">
                    <label class="tech-search" for="accessoryStatus">
                        <span>Visualizar</span>
                        <select id="accessoryStatus">
                            <option value="todos">Todos</option>
                            <option value="pendentes">Somente pendentes</option>
                            <option value="emitidos">Somente emitidos</option>
                        </select>
                    </label>
                    <div class="accessory-buttons">
                        <asp:Button ID="btnAtualizar" runat="server" Text="Atualizar listagem" CssClass="tech-button-secondary" OnClick="btnAtualizar_Click" />
                        <asp:Button ID="btnMarcarEmitidas" runat="server" Text="Marcar NFs emitidas" CssClass="tech-button" OnClientClick="return confirmarSelecionados('Marcar as linhas selecionadas como NFs emitidas?');" OnClick="btnMarcarEmitidas_Click" />
                        <asp:Button ID="btnDesmarcarEmitidas" runat="server" Text="Desmarcar selecionadas" CssClass="tech-danger-button" OnClientClick="return confirmarSelecionados('Desmarcar as linhas selecionadas?');" OnClick="btnDesmarcarEmitidas_Click" />
                    </div>
                </div>

                <div class="accessory-table-wrap">
                    <asp:Repeater ID="rptAcessorios" runat="server" EnableViewState="false">
                        <HeaderTemplate>
                            <table class="tech-table accessory-table">
                                <thead>
                                    <tr>
                                        <th class="accessory-check"><input id="accessorySelectAll" type="checkbox" aria-label="Selecionar todos" /></th>
                                        <th>Status</th>
                                        <th>Lan&ccedil;amento</th>
                                        <th>Loja</th>
                                        <th>Fornecedor</th>
                                        <th>Datas</th>
                                        <th>Valores</th>
                                        <th>Ve&iacute;culo</th>
                                        <th>Marca&ccedil;&atilde;o</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                                    <tr class="<%# LinhaClasse(Eval("Emitido")) %>" data-accessory-row data-search="<%# Chave(String.Concat(Eval("Lancamento"), " ", Eval("NumeroTitulo"), " ", Eval("Loja"), " ", Eval("Fornecedor"), " ", Eval("Veiculo_Chassi"), " ", Eval("Veiculo"))) %>">
                                        <td class="accessory-check">
                                            <input type="checkbox" name="acessorioSelecionado" value="<%# Chave(Eval("ChaveControle")) %>" aria-label="Selecionar lan&ccedil;amento <%# Html(Eval("Lancamento")) %>" />
                                        </td>
                                        <td><span class="<%# StatusClasse(Eval("Emitido")) %>"><%# StatusTexto(Eval("Emitido")) %></span></td>
                                        <td>
                                            <strong><%# Html(Eval("Lancamento")) %></strong>
                                            <small>T&iacute;tulo <%# Html(Eval("NumeroTitulo")) %></small>
                                        </td>
                                        <td><strong><%# Html(Eval("Loja")) %></strong></td>
                                        <td><%# Html(Eval("Fornecedor")) %></td>
                                        <td>
                                            <strong>Emiss&atilde;o: <%# Html(Eval("DataEmissao")) %></strong>
                                            <small>Vencimento: <%# Html(Eval("DataVencimento")) %></small>
                                        </td>
                                        <td>
                                            <strong><%# Moeda(Eval("Saldo")) %></strong>
                                            <small>Valor original: <%# Moeda(Eval("TituloValor")) %></small>
                                        </td>
                                        <td>
                                            <strong><%# Html(Eval("Veiculo")) %></strong>
                                            <code><%# Html(Eval("Veiculo_Chassi")) %></code>
                                        </td>
                                        <td class="accessory-mark"><%# Marcacao(Eval("Emitido"), Eval("MarcadoUsuario"), Eval("MarcadoEm")) %></td>
                                    </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>

                <asp:Panel ID="pnlSemDados" runat="server" CssClass="tech-empty" Visible="false">
                    Nenhum lan&ccedil;amento em aberto encontrado agora.
                </asp:Panel>
                <div id="accessoryEmptyFilter" class="tech-empty" hidden>Nenhuma linha encontrada para os filtros atuais.</div>
            </section>
        </main>
    </form>

    <script src="../js/bali-tecnologia.js?v=20260627-tech01"></script>
    <script>
        (function () {
            var search = document.getElementById('accessorySearch');
            var status = document.getElementById('accessoryStatus');
            var empty = document.getElementById('accessoryEmptyFilter');
            var selectAll = document.getElementById('accessorySelectAll');

            function rows() {
                return document.querySelectorAll('[data-accessory-row]');
            }

            function applyFilters() {
                var query = search ? search.value.toLowerCase().trim() : '';
                var filter = status ? status.value : 'todos';
                var list = rows();
                var visible = 0;

                for (var i = 0; i < list.length; i++) {
                    var row = list[i];
                    var haystack = (row.getAttribute('data-search') || row.textContent || '').toLowerCase();
                    var issued = row.className.indexOf('is-issued') >= 0;
                    var statusOk = filter === 'todos' || (filter === 'emitidos' && issued) || (filter === 'pendentes' && !issued);
                    var searchOk = !query || haystack.indexOf(query) >= 0;
                    var show = statusOk && searchOk;
                    row.style.display = show ? '' : 'none';
                    if (show) visible++;
                }

                if (empty) {
                    empty.hidden = visible > 0 || list.length === 0;
                }
            }

            window.confirmarSelecionados = function (message) {
                var checked = document.querySelectorAll('input[name="acessorioSelecionado"]:checked');
                if (!checked.length) {
                    alert('Selecione pelo menos uma linha.');
                    return false;
                }
                return confirm(message);
            };

            if (search) search.addEventListener('input', applyFilters);
            if (status) status.addEventListener('change', applyFilters);

            if (selectAll) {
                selectAll.addEventListener('change', function () {
                    var list = rows();
                    for (var i = 0; i < list.length; i++) {
                        if (list[i].style.display === 'none') continue;
                        var check = list[i].querySelector('input[name="acessorioSelecionado"]');
                        if (check) check.checked = selectAll.checked;
                    }
                });
            }
        })();
    </script>
</body>
</html>
