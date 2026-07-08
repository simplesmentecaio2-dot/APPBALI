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
            CarregarDados("", false);
            CarregarRelatorioDia(DateTime.Today, false);
            CarregarRelatorioQueryString();
            CarregarHistoricoQueryString();
        }
    }

    protected void btnAtualizar_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;
        CarregarDados("Listagem atualizada com os dados em aberto do sistema.", true);
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
    }

    protected void btnDesmarcarEmitidas_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;

        if (!SenhaDesmarcar.Equals((txtSenhaDesmarcar.Text ?? "").Trim()))
        {
            CarregarDados("Informe a senha correta para desmarcar NFs emitidas.", false);
            CarregarRelatorioDia(DataRelatorioSelecionada(), false);
            return;
        }

        string[] chaves = Request.Form.GetValues("acessorioSelecionado");
        int total = ControleAcessoriosDados.DesmarcarEmitidas(chaves, UsuarioCodigo(), UsuarioNome(), ObservacaoOperacao(), Context);

        if (total == 0)
        {
            CarregarDados("Selecione pelo menos uma linha para desmarcar.", false);
            return;
        }

        CarregarDados(total.ToString() + " registro(s) desmarcado(s).", true);
        CarregarRelatorioDia(DataRelatorioSelecionada(), false);
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

    protected string DataIso(object valor)
    {
        DateTime data;
        if (!DateTime.TryParse(Convert.ToString(valor), out data)) return "";
        return data.ToString("yyyy-MM-dd");
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
        if (acao == "RELATORIO_GERADO") return "Relat\u00f3rio gerado";
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
