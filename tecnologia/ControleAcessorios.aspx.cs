using System;
using System.Data;
using System.Globalization;
using System.Web;

public partial class tecnologia_ControleAcessorios : System.Web.UI.Page
{
    private const string SenhaDesmarcar = "@bali2025";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        lblUsuario.Text = Convert.ToString(Session["usuario"]);
        lblCodigo.Text = Session["usuario_codigo"] == null ? "-" : Convert.ToString(Session["usuario_codigo"]);

        if (!IsPostBack)
        {
            txtRelatorioData.Text = DateTime.Today.ToString("dd/MM/yyyy");
            txtRelatorioId.Text = "";
            CarregarDados("", false);
            CarregarRelatorioDia(DateTime.Today, false);
            CarregarConciliacao();
            CarregarAuditoria();
            CarregarRelatorioQueryString();
            CarregarHistoricoQueryString();
        }
    }

    protected void btnAtualizar_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;
        CarregarDados("Listagem atualizada com os dados em aberto do sistema.", true);
        CarregarRelatorioDia(DataRelatorioSelecionada(), false);
        CarregarConciliacao();
        CarregarAuditoria();
    }

    protected void btnMarcarEmitidas_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;

        string[] chaves = Request.Form.GetValues("acessorioSelecionado");
        ControleAcessoriosDados.ControleAcessoriosRelatorioResumo relatorio = ControleAcessoriosDados.MarcarEmitidas(chaves, UsuarioCodigo(), UsuarioNome(), ObservacaoOperacao(), Context);

        if (relatorio.TotalItens == 0)
        {
            CarregarDados("Selecione pelo menos uma linha para marcar como NF emitida.", false);
            return;
        }

        CarregarDados(relatorio.TotalItens.ToString() + " registro(s) marcado(s) como NF emitida. Relat\u00f3rio pronto para impress\u00e3o.", true);
        CarregarRelatorioAtual(relatorio.IdRelatorio);
        CarregarRelatorioDia(DateTime.Today, false);
        CarregarConciliacao();
        CarregarAuditoria();
    }

    protected void btnDesmarcarEmitidas_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;

        string[] chaves = Request.Form.GetValues("acessorioSelecionado");
        if (chaves == null || chaves.Length == 0)
        {
            CarregarDados("Selecione pelo menos uma linha para desmarcar.", false);
            CarregarRelatorioDia(DataRelatorioSelecionada(), false);
            CarregarConciliacao();
            CarregarAuditoria();
            return;
        }

        string observacao = ObservacaoOperacao();
        if (String.IsNullOrWhiteSpace(observacao))
        {
            CarregarDados("Informe o motivo no campo de observação antes de desmarcar uma NF emitida.", false);
            CarregarRelatorioDia(DataRelatorioSelecionada(), false);
            CarregarConciliacao();
            CarregarAuditoria();
            return;
        }

        if (!SenhaDesmarcar.Equals((txtSenhaDesmarcar.Text ?? "").Trim()))
        {
            ControleAcessoriosDados.RegistrarEventoOperacao(chaves, "SENHA_INVALIDA_DESMARCAR", UsuarioCodigo(), UsuarioNome(), "Tentativa de desmarcação com senha inválida. Motivo informado: " + observacao, Context);
            CarregarDados("Informe a senha correta para desmarcar NFs emitidas.", false);
            CarregarRelatorioDia(DataRelatorioSelecionada(), false);
            CarregarConciliacao();
            CarregarAuditoria();
            return;
        }

        int total = ControleAcessoriosDados.DesmarcarEmitidas(chaves, UsuarioCodigo(), UsuarioNome(), observacao, Context);

        if (total == 0)
        {
            CarregarDados("Selecione pelo menos uma linha para desmarcar.", false);
            CarregarRelatorioDia(DataRelatorioSelecionada(), false);
            CarregarConciliacao();
            CarregarAuditoria();
            return;
        }

        CarregarDados(total.ToString() + " registro(s) desmarcado(s).", true);
        CarregarRelatorioDia(DataRelatorioSelecionada(), false);
        CarregarConciliacao();
        CarregarAuditoria();
    }

    protected void btnExportarLista_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;
        DataTable dados = ControleAcessoriosDados.ListarAbertos();
        ExportarExcel("controle-acessorios-listagem.xls", "Listagem atual", dados, false);
    }

    protected void btnExportarRelatorioDia_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;
        DateTime data = DataRelatorioSelecionada();
        DataTable dados = ControleAcessoriosDados.ListarItensMarcadosNoDia(UsuarioCodigo(), UsuarioNome(), data);
        ExportarExcel("controle-acessorios-relatorio-dia.xls", "Relat\u00f3rio do dia " + data.ToString("dd/MM/yyyy"), dados, true);
    }

    protected void btnBuscarRelatorioDia_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;
        CarregarDados("", false);
        CarregarRelatorioDia(DataRelatorioSelecionada(), true);
        CarregarConciliacao();
        CarregarAuditoria();
    }

    protected void btnBuscarRelatorioId_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;

        CarregarDados("", false);
        CarregarRelatorioDia(DataRelatorioSelecionada(), false);
        CarregarConciliacao();
        CarregarAuditoria();

        long idRelatorio;
        string texto = (txtRelatorioId.Text ?? "").Trim().Replace("#", "");
        if (!Int64.TryParse(texto, out idRelatorio) || idRelatorio <= 0)
        {
            litMensagemRelatorio.Text = "<div class=\"accessory-alert is-error\">Informe um número de relatório válido.</div>";
            ClientScript.RegisterStartupScript(GetType(), "abrirReimpressaoIdInvalido", "window.__accessoryInitialTab='reimpressao';", true);
            return;
        }

        CarregarRelatorioAtual(idRelatorio);
        litMensagemRelatorio.Text = pnlRelatorioAtual.Visible
            ? "<div class=\"accessory-alert is-success\">Relatório #" + Html(idRelatorio) + " carregado para impressão.</div>"
            : "<div class=\"accessory-alert is-error\">Relatório não encontrado.</div>";
        ClientScript.RegisterStartupScript(GetType(), "abrirOperacaoRelatorioId", "window.__accessoryInitialTab='operacao';", true);
    }

    private void CarregarDados(string mensagem, bool sucesso)
    {
        try
        {
            DataTable dados = ControleAcessoriosDados.ListarAbertos();
            rptAcessorios.DataSource = dados;
            rptAcessorios.DataBind();
            pnlSemDados.Visible = dados.Rows.Count == 0;

            int emitidos = 0;
            int pendentes = 0;
            decimal saldoPendente = 0;
            DateTime menorVencimento = DateTime.MinValue;

            foreach (DataRow row in dados.Rows)
            {
                bool emitido = EstaEmitido(row["Emitido"]);
                if (emitido)
                {
                    emitidos++;
                }
                else
                {
                    pendentes++;
                    saldoPendente += DecimalValor(row["Saldo"]);

                    DateTime vencimento;
                    if (DateTime.TryParse(Convert.ToString(row["DataVencimentoValor"]), out vencimento))
                    {
                        if (menorVencimento == DateTime.MinValue || vencimento < menorVencimento)
                        {
                            menorVencimento = vencimento;
                        }
                    }
                }
            }

            litTotal.Text = dados.Rows.Count.ToString();
            litEmitidos.Text = emitidos.ToString();
            litPendentes.Text = pendentes.ToString();
            litSaldoPendente.Text = Moeda(saldoPendente);
            litPrimeiroVencimento.Text = menorVencimento == DateTime.MinValue ? "-" : menorVencimento.ToString("dd/MM/yyyy");
            litAtualizacao.Text = "Atualizado em " + DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");

            CarregarDashboard(dados, emitidos, pendentes, saldoPendente);
            CarregarPendencias(dados);
            CarregarAtencao(dados);

            MostrarMensagem(mensagem, sucesso);
        }
        catch
        {
            rptAcessorios.DataSource = null;
            rptAcessorios.DataBind();
            pnlSemDados.Visible = true;
            litTotal.Text = "0";
            litEmitidos.Text = "0";
            litPendentes.Text = "0";
            litSaldoPendente.Text = "R$ 0,00";
            litPrimeiroVencimento.Text = "-";
            litAtualizacao.Text = "Falha ao atualizar";
            LimparComplementos();
            MostrarMensagem("N\u00e3o foi poss\u00edvel carregar o controle de acess\u00f3rios agora. Tente novamente em alguns instantes.", false);
        }
    }

    private void MostrarMensagem(string mensagem, bool sucesso)
    {
        if (String.IsNullOrWhiteSpace(mensagem))
        {
            litMensagem.Text = "";
            return;
        }

        string classe = sucesso ? "accessory-alert is-success" : "accessory-alert is-error";
        litMensagem.Text = "<div class=\"" + classe + "\">" + HttpUtility.HtmlEncode(mensagem) + "</div>";
    }

    private void CarregarDashboard(DataTable dados, int emitidos, int pendentes, decimal saldoPendente)
    {
        int vencidos = 0;
        int vencemHoje = 0;
        int vencemSemana = 0;
        decimal saldoEmitido = 0;

        foreach (DataRow row in dados.Rows)
        {
            bool emitido = EstaEmitido(row["Emitido"]);
            DateTime vencimento;
            bool temVencimento = DateTime.TryParse(Convert.ToString(row["DataVencimentoValor"]), out vencimento);

            if (emitido)
            {
                saldoEmitido += DecimalValor(row["Saldo"]);
                continue;
            }

            if (!temVencimento) continue;
            if (vencimento.Date < DateTime.Today) vencidos++;
            if (vencimento.Date == DateTime.Today) vencemHoje++;
            if (vencimento.Date >= DateTime.Today && vencimento.Date <= DateTime.Today.AddDays(7)) vencemSemana++;
        }

        litDashboardTotal.Text = dados.Rows.Count.ToString();
        litDashboardPendentes.Text = pendentes.ToString();
        litDashboardVencidos.Text = vencidos.ToString();
        litDashboardHoje.Text = vencemHoje.ToString();
        litDashboardSemana.Text = vencemSemana.ToString();
        litDashboardValorPendente.Text = Moeda(saldoPendente);
        litDashboardValorEmitido.Text = Moeda(saldoEmitido);
        litDashboardResolvidos.Text = "-";

        rptResumoLojas.DataSource = ResumoPorLoja(dados);
        rptResumoLojas.DataBind();
    }

    private void CarregarPendencias(DataTable dados)
    {
        DataTable pendencias = FiltrarPendentes(dados);
        rptPendencias.DataSource = pendencias;
        rptPendencias.DataBind();
        pnlSemPendencias.Visible = pendencias.Rows.Count == 0;
    }

    private void CarregarAtencao(DataTable dados)
    {
        DataTable atencao = TopPendencias(dados, 5);
        rptAtencao.DataSource = atencao;
        rptAtencao.DataBind();
        pnlSemAtencao.Visible = atencao.Rows.Count == 0;
    }

    private void CarregarConciliacao()
    {
        try
        {
            DataTable conciliados = ControleAcessoriosDados.ListarConciliadosResolvidos();
            rptConciliados.DataSource = conciliados;
            rptConciliados.DataBind();
            pnlSemConciliacao.Visible = conciliados.Rows.Count == 0;
            litDashboardResolvidos.Text = conciliados.Rows.Count.ToString();
        }
        catch
        {
            rptConciliados.DataSource = null;
            rptConciliados.DataBind();
            pnlSemConciliacao.Visible = true;
        }
    }

    private void CarregarAuditoria()
    {
        try
        {
            DataTable eventos = ControleAcessoriosDados.ListarUltimosEventos(30);
            rptUltimosEventos.DataSource = eventos;
            rptUltimosEventos.DataBind();
            pnlSemAuditoria.Visible = eventos.Rows.Count == 0;
        }
        catch
        {
            rptUltimosEventos.DataSource = null;
            rptUltimosEventos.DataBind();
            pnlSemAuditoria.Visible = true;
        }
    }

    private void LimparComplementos()
    {
        litDashboardTotal.Text = "0";
        litDashboardPendentes.Text = "0";
        litDashboardVencidos.Text = "0";
        litDashboardHoje.Text = "0";
        litDashboardSemana.Text = "0";
        litDashboardValorPendente.Text = "R$ 0,00";
        litDashboardValorEmitido.Text = "R$ 0,00";
        litDashboardResolvidos.Text = "-";

        rptResumoLojas.DataSource = null;
        rptResumoLojas.DataBind();
        rptPendencias.DataSource = null;
        rptPendencias.DataBind();
        rptAtencao.DataSource = null;
        rptAtencao.DataBind();
        pnlSemPendencias.Visible = true;
        pnlSemAtencao.Visible = true;
    }

    private void CarregarRelatorioAtual(long idRelatorio)
    {
        if (idRelatorio <= 0)
        {
            pnlRelatorioAtual.Visible = false;
            return;
        }

        DataRow cabecalho = ControleAcessoriosDados.ObterRelatorio(idRelatorio);
        DataTable itens = ControleAcessoriosDados.ListarItensRelatorio(idRelatorio);

        if (cabecalho == null || itens.Rows.Count == 0)
        {
            pnlRelatorioAtual.Visible = false;
            return;
        }

        litRelatorioAtualId.Text = "#" + Html(cabecalho["IdRelatorio"]);
        litRelatorioAtualData.Text = DataHora(cabecalho["GeradoEm"]);
        litRelatorioAtualUsuario.Text = Html(cabecalho["UsuarioNome"]);
        litRelatorioAtualItens.Text = Convert.ToString(itens.Rows.Count);
        litRelatorioAtualTotal.Text = Moeda(SomarValor(itens));
        rptRelatorioAtual.DataSource = itens;
        rptRelatorioAtual.DataBind();
        rptSubtotaisAtual.DataSource = SubtotaisPorLoja(itens);
        rptSubtotaisAtual.DataBind();
        rptAuditoriaLoteAtual.DataSource = ControleAcessoriosDados.ListarAuditoriaRelatorio(idRelatorio);
        rptAuditoriaLoteAtual.DataBind();
        pnlRelatorioAtual.Visible = true;
    }

    private void CarregarRelatorioDia(DateTime data, bool mostrarMensagem)
    {
        txtRelatorioData.Text = data.ToString("dd/MM/yyyy");

        DataTable itens = ControleAcessoriosDados.ListarItensMarcadosNoDia(UsuarioCodigo(), UsuarioNome(), data);
        DataTable lotes = ControleAcessoriosDados.ListarRelatoriosDoDia(UsuarioCodigo(), UsuarioNome(), data);

        rptRelatorioDia.DataSource = itens;
        rptRelatorioDia.DataBind();
        rptLotesDia.DataSource = lotes;
        rptLotesDia.DataBind();

        pnlRelatorioDia.Visible = itens.Rows.Count > 0;
        pnlSemRelatorioDia.Visible = itens.Rows.Count == 0;
        pnlLotesDia.Visible = lotes.Rows.Count > 0;

        litRelatorioDiaData.Text = data.ToString("dd/MM/yyyy");
        litRelatorioDiaUsuario.Text = Html(UsuarioNome());
        litRelatorioDiaItens.Text = itens.Rows.Count.ToString();
        litRelatorioDiaTotal.Text = Moeda(SomarValor(itens));
        rptSubtotaisDia.DataSource = SubtotaisPorLoja(itens);
        rptSubtotaisDia.DataBind();

        if (mostrarMensagem)
        {
            litMensagemRelatorio.Text = itens.Rows.Count == 0
                ? "<div class=\"accessory-alert is-error\">Nenhuma NF emitida encontrada para essa data.</div>"
                : "<div class=\"accessory-alert is-success\">Relat\u00f3rio do dia carregado para reimpress\u00e3o.</div>";
            ClientScript.RegisterStartupScript(GetType(), "abrirReimpressao", "window.__accessoryInitialTab='reimpressao';", true);
        }
        else
        {
            litMensagemRelatorio.Text = "";
        }
    }

    private void CarregarRelatorioQueryString()
    {
        long idRelatorio;
        if (!Int64.TryParse(Request.QueryString["relatorio"], out idRelatorio) || idRelatorio <= 0) return;
        CarregarRelatorioAtual(idRelatorio);
        ClientScript.RegisterStartupScript(GetType(), "abrirOperacaoRelatorio", "window.__accessoryInitialTab='operacao';", true);
    }

    private void CarregarHistoricoQueryString()
    {
        string chave = (Request.QueryString["historico"] ?? "").Trim();
        if (chave.Length == 0 || chave.Length > 180)
        {
            pnlHistorico.Visible = false;
            return;
        }

        DataTable historico = ControleAcessoriosDados.ListarHistorico(chave);
        rptHistorico.DataSource = historico;
        rptHistorico.DataBind();
        pnlHistorico.Visible = true;
        pnlSemHistorico.Visible = historico.Rows.Count == 0;
        litHistoricoChave.Text = Html(chave);
        ClientScript.RegisterStartupScript(GetType(), "abrirOperacaoHistorico", "window.__accessoryInitialTab='operacao';", true);
    }

    private DateTime DataRelatorioSelecionada()
    {
        DateTime data;
        if (DateTime.TryParseExact((txtRelatorioData.Text ?? "").Trim(), "dd/MM/yyyy", new CultureInfo("pt-BR"), DateTimeStyles.None, out data))
        {
            return data.Date;
        }

        if (DateTime.TryParse((txtRelatorioData.Text ?? "").Trim(), new CultureInfo("pt-BR"), DateTimeStyles.None, out data))
        {
            return data.Date;
        }

        return DateTime.Today;
    }

    private decimal SomarValor(DataTable tabela)
    {
        decimal total = 0;
        if (tabela == null || !tabela.Columns.Contains("ValorNF")) return total;

        foreach (DataRow row in tabela.Rows)
        {
            total += DecimalValor(row["ValorNF"]);
        }

        return total;
    }

    private decimal SomarColuna(DataTable tabela, string coluna)
    {
        decimal total = 0;
        if (tabela == null || !tabela.Columns.Contains(coluna)) return total;

        foreach (DataRow row in tabela.Rows)
        {
            total += DecimalValor(row[coluna]);
        }

        return total;
    }

    private DataTable SubtotaisPorLoja(DataTable itens)
    {
        DataTable subtotais = new DataTable();
        subtotais.Columns.Add("Loja", typeof(string));
        subtotais.Columns.Add("Itens", typeof(int));
        subtotais.Columns.Add("ValorTotal", typeof(decimal));

        if (itens == null || !itens.Columns.Contains("Loja")) return subtotais;

        DataView view = new DataView(itens);
        DataTable lojas = view.ToTable(true, "Loja");
        foreach (DataRow lojaRow in lojas.Rows)
        {
            string loja = Convert.ToString(lojaRow["Loja"]).Trim();
            decimal total = 0;
            int quantidade = 0;

            foreach (DataRow item in itens.Rows)
            {
                if (!String.Equals(Convert.ToString(item["Loja"]).Trim(), loja, StringComparison.OrdinalIgnoreCase)) continue;
                total += DecimalValor(item["ValorNF"]);
                quantidade++;
            }

            DataRow subtotal = subtotais.NewRow();
            subtotal["Loja"] = String.IsNullOrWhiteSpace(loja) ? "-" : loja;
            subtotal["Itens"] = quantidade;
            subtotal["ValorTotal"] = total;
            subtotais.Rows.Add(subtotal);
        }

        return subtotais;
    }

    private DataTable ResumoPorLoja(DataTable dados)
    {
        DataTable resumo = new DataTable();
        resumo.Columns.Add("Loja", typeof(string));
        resumo.Columns.Add("Total", typeof(int));
        resumo.Columns.Add("Pendentes", typeof(int));
        resumo.Columns.Add("Emitidos", typeof(int));
        resumo.Columns.Add("ValorPendente", typeof(decimal));

        if (dados == null || !dados.Columns.Contains("Loja")) return resumo;

        DataView view = new DataView(dados);
        DataTable lojas = view.ToTable(true, "Loja");
        foreach (DataRow lojaRow in lojas.Rows)
        {
            string loja = Convert.ToString(lojaRow["Loja"]).Trim();
            int total = 0;
            int pendentes = 0;
            int emitidos = 0;
            decimal valorPendente = 0;

            foreach (DataRow row in dados.Rows)
            {
                if (!String.Equals(Convert.ToString(row["Loja"]).Trim(), loja, StringComparison.OrdinalIgnoreCase)) continue;

                total++;
                if (EstaEmitido(row["Emitido"]))
                {
                    emitidos++;
                }
                else
                {
                    pendentes++;
                    valorPendente += DecimalValor(row["Saldo"]);
                }
            }

            DataRow item = resumo.NewRow();
            item["Loja"] = String.IsNullOrWhiteSpace(loja) ? "-" : loja;
            item["Total"] = total;
            item["Pendentes"] = pendentes;
            item["Emitidos"] = emitidos;
            item["ValorPendente"] = valorPendente;
            resumo.Rows.Add(item);
        }

        resumo.DefaultView.Sort = "Pendentes DESC, Loja ASC";
        return resumo.DefaultView.ToTable();
    }

    private DataTable FiltrarPendentes(DataTable dados)
    {
        DataTable pendencias = dados == null ? new DataTable() : dados.Clone();
        if (dados == null) return pendencias;

        foreach (DataRow row in dados.Rows)
        {
            if (!EstaEmitido(row["Emitido"]))
            {
                pendencias.ImportRow(row);
            }
        }

        pendencias.DefaultView.Sort = "DataVencimentoValor ASC, Loja ASC, Lancamento ASC";
        return pendencias.DefaultView.ToTable();
    }

    private DataTable TopPendencias(DataTable dados, int total)
    {
        DataTable pendencias = FiltrarPendentes(dados);
        DataTable retorno = pendencias.Clone();

        int limite = Math.Max(0, total);
        for (int i = 0; i < pendencias.Rows.Count && i < limite; i++)
        {
            retorno.ImportRow(pendencias.Rows[i]);
        }

        return retorno;
    }

    private string ObservacaoOperacao()
    {
        string texto = (txtObservacao.Text ?? "").Trim();
        if (texto.Length > 300) texto = texto.Substring(0, 300);
        return texto;
    }

    protected string Html(object valor)
    {
        string texto = Convert.ToString(valor);
        return HttpUtility.HtmlEncode(String.IsNullOrWhiteSpace(texto) ? "-" : texto.Trim());
    }

    protected string Chave(object valor)
    {
        string texto = Convert.ToString(valor);
        return HttpUtility.HtmlAttributeEncode(String.IsNullOrWhiteSpace(texto) ? "" : texto.Trim());
    }

    protected string LinhaClasse(object emitido, object vencimento)
    {
        if (EstaEmitido(emitido)) return "accessory-row is-issued";

        DateTime data;
        if (DateTime.TryParse(Convert.ToString(vencimento), out data))
        {
            if (data.Date < DateTime.Today) return "accessory-row is-overdue";
            if (data.Date <= DateTime.Today.AddDays(1)) return "accessory-row is-due-soon";
        }

        return "accessory-row";
    }

    protected string StatusClasse(object emitido)
    {
        return EstaEmitido(emitido) ? "accessory-status is-issued" : "accessory-status is-pending";
    }

    protected string StatusTexto(object emitido)
    {
        return EstaEmitido(emitido) ? "NF emitida" : "Pendente";
    }

    protected string VencimentoTexto(object emitido, object vencimento)
    {
        if (EstaEmitido(emitido)) return "";

        DateTime data;
        if (!DateTime.TryParse(Convert.ToString(vencimento), out data)) return "";
        if (data.Date < DateTime.Today) return "<span class=\"accessory-due is-overdue\">Vencido</span>";
        if (data.Date == DateTime.Today) return "<span class=\"accessory-due is-today\">Vence hoje</span>";
        if (data.Date == DateTime.Today.AddDays(1)) return "<span class=\"accessory-due is-soon\">Vence amanh\u00e3</span>";
        return "";
    }

    protected string DiasEmAbertoTexto(object emitido, object dias)
    {
        if (EstaEmitido(emitido)) return "";

        int total;
        if (!Int32.TryParse(Convert.ToString(dias), out total) || total <= 0) return "";
        return "<small>" + total.ToString() + " dia(s) em aberto</small>";
    }

    protected string DataIso(object valor)
    {
        DateTime data;
        if (!DateTime.TryParse(Convert.ToString(valor), out data)) return "";
        return data.ToString("yyyy-MM-dd");
    }

    protected string NumeroData(object valor)
    {
        return DecimalValor(valor).ToString("0.00", CultureInfo.InvariantCulture);
    }

    protected string UrlHistorico(object chave)
    {
        return "ControleAcessorios.aspx?historico=" + Server.UrlEncode(Convert.ToString(chave));
    }

    protected string UrlRelatorio(object id)
    {
        return "ControleAcessorios.aspx?relatorio=" + Server.UrlEncode(Convert.ToString(id));
    }

    protected string Moeda(object valor)
    {
        decimal numero = DecimalValor(valor);
        return numero.ToString("C", new CultureInfo("pt-BR"));
    }

    protected string DataHora(object valor)
    {
        if (valor == null || valor == DBNull.Value) return "-";
        DateTime data;
        if (!DateTime.TryParse(Convert.ToString(valor), out data)) return "-";
        return data.ToString("dd/MM/yyyy HH:mm:ss");
    }

    protected string AcaoHistorico(object valor)
    {
        string acao = Convert.ToString(valor);
        if (acao == "MARCAR_NF_EMITIDA") return "NF emitida";
        if (acao == "DESMARCAR_NF_EMITIDA") return "NF desmarcada";
        if (acao == "SENHA_INVALIDA_DESMARCAR") return "Senha incorreta";
        if (acao == "RELATORIO_GERADO") return "Relat\u00f3rio gerado";
        if (acao == "ITEM_RELATORIO") return "Item do lote";
        return Html(acao);
    }

    protected string Marcacao(object emitido, object usuario, object data)
    {
        if (!EstaEmitido(emitido)) return "-";

        string usuarioTexto = Convert.ToString(usuario);
        string dataTexto = Convert.ToString(data);

        if (String.IsNullOrWhiteSpace(usuarioTexto)) usuarioTexto = "Usu\u00e1rio n\u00e3o identificado";
        if (String.IsNullOrWhiteSpace(dataTexto)) return HttpUtility.HtmlEncode(usuarioTexto);

        return HttpUtility.HtmlEncode(usuarioTexto.Trim()) + "<small>" + HttpUtility.HtmlEncode(dataTexto.Trim()) + "</small>";
    }

    protected bool EstaEmitido(object valor)
    {
        if (valor == null || valor == DBNull.Value) return false;
        bool booleano;
        if (Boolean.TryParse(Convert.ToString(valor), out booleano)) return booleano;
        return Convert.ToString(valor) == "1";
    }

    private void ExportarExcel(string nomeArquivo, string titulo, DataTable dados, bool relatorio)
    {
        Response.Clear();
        Response.Buffer = true;
        Response.ContentEncoding = System.Text.Encoding.UTF8;
        Response.Charset = "utf-8";
        Response.ContentType = "application/vnd.ms-excel";
        Response.AddHeader("Content-Disposition", "attachment; filename=" + nomeArquivo);
        Response.Write("<html><head><meta charset='utf-8'></head><body>");
        Response.Write("<h2>" + HttpUtility.HtmlEncode(titulo) + "</h2>");
        Response.Write("<p><strong>Usuário:</strong> " + Html(UsuarioNome()) + " &nbsp; <strong>Gerado em:</strong> " + DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss") + "</p>");

        decimal total = relatorio ? SomarValor(dados) : SomarColuna(dados, "Saldo");
        Response.Write("<table border='1'>");
        Response.Write("<tr><th>Resumo</th><th>Quantidade</th><th>Valor total</th></tr>");
        Response.Write("<tr><td>" + HttpUtility.HtmlEncode(titulo) + "</td><td>" + dados.Rows.Count.ToString() + "</td><td>" + Moeda(total) + "</td></tr>");
        Response.Write("</table><br/>");

        DataTable subtotais = relatorio ? SubtotaisPorLoja(dados) : ResumoPorLoja(dados);
        if (subtotais.Rows.Count > 0)
        {
            Response.Write("<table border='1'>");
            Response.Write(relatorio
                ? "<tr><th>Loja</th><th>Itens</th><th>Subtotal</th></tr>"
                : "<tr><th>Loja</th><th>Total</th><th>Pendentes</th><th>Emitidos</th><th>Valor pendente</th></tr>");

            foreach (DataRow row in subtotais.Rows)
            {
                Response.Write("<tr>");
                Response.Write("<td>" + Html(row["Loja"]) + "</td>");
                if (relatorio)
                {
                    Response.Write("<td>" + Html(row["Itens"]) + "</td>");
                    Response.Write("<td>" + Moeda(row["ValorTotal"]) + "</td>");
                }
                else
                {
                    Response.Write("<td>" + Html(row["Total"]) + "</td>");
                    Response.Write("<td>" + Html(row["Pendentes"]) + "</td>");
                    Response.Write("<td>" + Html(row["Emitidos"]) + "</td>");
                    Response.Write("<td>" + Moeda(row["ValorPendente"]) + "</td>");
                }
                Response.Write("</tr>");
            }

            Response.Write("</table><br/>");
        }

        Response.Write("<table border='1'>");

        if (relatorio)
        {
            Response.Write("<tr><th>Loja</th><th>Lan\u00e7amento</th><th>T\u00edtulo</th><th>Chassi</th><th>Valor</th></tr>");
            foreach (DataRow row in dados.Rows)
            {
                Response.Write("<tr>");
                Response.Write("<td>" + Html(row["Loja"]) + "</td>");
                Response.Write("<td>" + Html(row["Lancamento"]) + "</td>");
                Response.Write("<td>" + Html(row["NumeroTitulo"]) + "</td>");
                Response.Write("<td>" + Html(row["VeiculoChassi"]) + "</td>");
                Response.Write("<td>" + Moeda(row["ValorNF"]) + "</td>");
                Response.Write("</tr>");
            }
        }
        else
        {
            Response.Write("<tr><th>Status</th><th>Loja</th><th>Lan\u00e7amento</th><th>T\u00edtulo</th><th>Fornecedor</th><th>Vencimento</th><th>Saldo</th><th>Chassi</th><th>Ve\u00edculo</th></tr>");
            foreach (DataRow row in dados.Rows)
            {
                Response.Write("<tr>");
                Response.Write("<td>" + StatusTexto(row["Emitido"]) + "</td>");
                Response.Write("<td>" + Html(row["Loja"]) + "</td>");
                Response.Write("<td>" + Html(row["Lancamento"]) + "</td>");
                Response.Write("<td>" + Html(row["NumeroTitulo"]) + "</td>");
                Response.Write("<td>" + Html(row["Fornecedor"]) + "</td>");
                Response.Write("<td>" + Html(row["DataVencimento"]) + "</td>");
                Response.Write("<td>" + Moeda(row["Saldo"]) + "</td>");
                Response.Write("<td>" + Html(row["Veiculo_Chassi"]) + "</td>");
                Response.Write("<td>" + Html(row["Veiculo"]) + "</td>");
                Response.Write("</tr>");
            }
        }

        Response.Write("</table></body></html>");
        Response.Flush();
        Response.End();
    }

    private decimal DecimalValor(object valor)
    {
        if (valor == null || valor == DBNull.Value) return 0;

        if (valor is decimal) return (decimal)valor;
        if (valor is int || valor is long || valor is short || valor is byte)
        {
            return Convert.ToDecimal(valor, CultureInfo.InvariantCulture);
        }

        if (valor is double || valor is float)
        {
            return Convert.ToDecimal(valor, CultureInfo.InvariantCulture);
        }

        string texto = Convert.ToString(valor).Trim();
        if (texto.Length == 0) return 0;

        decimal numero;
        CultureInfo ptBr = new CultureInfo("pt-BR");

        bool temVirgula = texto.IndexOf(',') >= 0;
        bool temPonto = texto.IndexOf('.') >= 0;

        if (temVirgula && (!temPonto || texto.LastIndexOf(',') > texto.LastIndexOf('.')))
        {
            if (Decimal.TryParse(texto, NumberStyles.Any, ptBr, out numero)) return numero;
        }

        if (Decimal.TryParse(texto, NumberStyles.Any, CultureInfo.InvariantCulture, out numero)) return numero;
        if (Decimal.TryParse(texto, NumberStyles.Any, ptBr, out numero)) return numero;
        return 0;
    }

    private string UsuarioCodigo()
    {
        return Session["usuario_codigo"] == null ? "" : Convert.ToString(Session["usuario_codigo"]).Trim();
    }

    private string UsuarioNome()
    {
        return Session["usuario"] == null ? "" : Convert.ToString(Session["usuario"]).Trim();
    }

    private bool UsuarioTecnologiaValido()
    {
        if (Session["id"] == null)
        {
            RedirecionarLogin();
            return false;
        }

        App oApp = new App();
        int permissao = oApp.verificaPermissaoSistema(Convert.ToString(Session["id"]), "TECNOLOGIA");
        if (permissao != 1)
        {
            RedirecionarLogin();
            return false;
        }

        return true;
    }

    private void RedirecionarLogin()
    {
        Response.Redirect("../Login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }
}
