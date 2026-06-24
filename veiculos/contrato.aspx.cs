using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Data;
using System.Globalization;
using System.Text;

public partial class veiculos_contrato : System.Web.UI.Page
{
    private const string TabelaContratosBI = "dbo.veiculos_contrato_venda";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["usuario"] == null || Session["usuario"].ToString().Equals(""))
        {
            Response.Redirect("./loginAppcontrato.aspx");
        }
        else
        {
            lblUsuario.Text = Session["usuario"].ToString();
        }
        if (txtDtFinalVU.Text.Length == 0 && txtDtInicialVU.Text.Length == 0)
        {
            txtDtInicialVU.Text = DateTime.Now.AddDays(-2).ToShortDateString();
            txtDtFinalVU.Text = DateTime.Now.ToShortDateString();
        }
        if (txtDtFinalVN.Text.Length == 0 && txtDtInicialVN.Text.Length == 0)
        {
            txtDtInicialVN.Text = DateTime.Now.AddDays(-2).ToShortDateString();
            txtDtFinalVN.Text = DateTime.Now.ToShortDateString();
        }
        if (txtDtFinalVD.Text.Length == 0 && txtDtInicialVD.Text.Length == 0)
        {
            txtDtInicialVD.Text = DateTime.Now.AddDays(-2).ToShortDateString();
            txtDtFinalVD.Text = DateTime.Now.ToShortDateString();
        }

        InicializarPeriodoBI();
        if (!IsPostBack)
        {
            CarregarBI();
        }

    }
    public string tabela;
    public string tabelaVU;
    public string tabelaVD;
    public string biHtml;

    private static readonly CultureInfo CulturaBrasil = new CultureInfo("pt-BR");

    private void ExibirAlerta(string mensagem)
    {
        string script = "alert('" + HttpUtility.JavaScriptStringEncode(mensagem) + "');";
        ScriptManager.RegisterStartupScript(this, this.GetType(), Guid.NewGuid().ToString("N"), script, true);
    }

    private decimal LerMoeda(string valor)
    {
        string texto = (valor ?? "").Replace("R$", "").Trim().Replace(" ", "");
        if (texto.Length == 0) return 0M;

        decimal convertido;
        int ultimoPonto = texto.LastIndexOf(".");
        bool priorizarBrasil = texto.IndexOf(",") >= 0
            || (ultimoPonto >= 0 && texto.IndexOf(".") == ultimoPonto && texto.Length - ultimoPonto - 1 == 3);

        if (priorizarBrasil && decimal.TryParse(texto, NumberStyles.Number, CulturaBrasil, out convertido)) return convertido;
        if (decimal.TryParse(texto, NumberStyles.Number, CultureInfo.InvariantCulture, out convertido)) return convertido;
        if (decimal.TryParse(texto, NumberStyles.Number, CulturaBrasil, out convertido)) return convertido;

        throw new FormatException("Valor inválido: " + valor);
    }

    private string FormatarMoedaSistema(decimal valor)
    {
        return valor.ToString("0.00", CultureInfo.CurrentCulture);
    }

    private void NormalizarCampoMoeda(TextBox campo)
    {
        if (campo != null)
        {
            campo.Text = FormatarMoedaSistema(LerMoeda(campo.Text));
        }
    }

    private void NormalizarCamposMonetarios()
    {
        TextBox[] campos = new TextBox[]
        {
            txtValoVeiculo, txtEmplacamento, txtEntrada, txtCarroUsado, txtVlUtilzadoAvaliacao,
            txtQuitacao, txtSaldoAvaliacao, txtVlFinanciamento, txtVlParcelas, txtEdValorVeic,
            txtEdTAXAS, txtEdEntrada, txtEdValorUSADO, txtEdVALORUSADOAVAILACAO, txtEdQuitacao,
            txtEdSaldoAvaliacao, txtEdFinanciamento, txtEdValorParcela
        };

        foreach (TextBox campo in campos)
        {
            NormalizarCampoMoeda(campo);
        }
    }

    private bool CampoVazio(string valor)
    {
        return (valor ?? "").Trim().Length == 0;
    }

    private bool ValidarContratoNovo(string modalidadePagamento, string tipo, out string mensagem)
    {
        List<string> erros = new List<string>();

        if (CampoVazio(txtCliente.Text)) erros.Add("Informe o cliente.");
        if (CampoVazio(txtCPFCNPJ.Text)) erros.Add("Informe o CPF/CNPJ.");
        if (CampoVazio(txtMarca.Text)) erros.Add("Informe a marca.");
        if (CampoVazio(txtModelo.Text)) erros.Add("Informe o modelo.");
        if (CampoVazio(txtChassiPlaca.Text)) erros.Add("Informe chassi/placa.");
        if (CampoVazio(tipo)) erros.Add("Selecione se o contrato é novo, usado ou venda direta.");
        if (CampoVazio(ddlVendedor.Text)) erros.Add("Selecione o vendedor.");
        if (LerMoeda(txtValoVeiculo.Text) <= 0) erros.Add("Valor do veículo deve ser maior que zero. Exemplo: 150000,00.");

        if (modalidadePagamento == "F")
        {
            if (CampoVazio(txtNrParcelas.Text)) erros.Add("Informe a quantidade de parcelas do financiamento.");
            if (LerMoeda(txtVlParcelas.Text) <= 0) erros.Add("Valor da parcela deve ser maior que zero para financiamento.");
        }

        if (LerMoeda(txtVlFinanciamento.Text) < 0) erros.Add("Financiamento ficou negativo. Confira valor do veículo, entrada e avaliação utilizada.");
        if (LerMoeda(txtSaldoAvaliacao.Text) < 0) erros.Add("Saldo da avaliação ficou negativo. Confira avaliação, valor utilizado e quitação.");

        if (erros.Count > 0)
        {
            mensagem = "Revise o contrato antes de gravar:\n- " + String.Join("\n- ", erros.ToArray());
            return false;
        }

        mensagem = "";
        return true;
    }

    private bool ValidarContratoEdicao(string modalidadePagamento, out string mensagem)
    {
        List<string> erros = new List<string>();
        int contrato;

        if (!Int32.TryParse((txtContrato.Text ?? "").Trim(), out contrato) || contrato <= 0) erros.Add("Informe um número de contrato válido para edição.");
        if (CampoVazio(txtEdCliente.Text)) erros.Add("Informe o cliente.");
        if (CampoVazio(txtEdCPF.Text)) erros.Add("Informe o CPF/CNPJ.");
        if (CampoVazio(txtEdMarca.Text)) erros.Add("Informe a marca.");
        if (CampoVazio(txtEdModelo.Text)) erros.Add("Informe o modelo.");
        if (CampoVazio(txtEdChassi.Text)) erros.Add("Informe chassi/placa.");
        if (CampoVazio(modalidadePagamento)) erros.Add("Selecione a modalidade de pagamento.");
        if (CampoVazio(txtEdVendedor.Text)) erros.Add("Informe o vendedor.");
        if (LerMoeda(txtEdValorVeic.Text) <= 0) erros.Add("Valor do veículo deve ser maior que zero. Exemplo: 150000,00.");

        if (modalidadePagamento == "F")
        {
            if (CampoVazio(txtEdNumeroParcelas.Text)) erros.Add("Informe a quantidade de parcelas do financiamento.");
            if (LerMoeda(txtEdValorParcela.Text) <= 0) erros.Add("Valor da parcela deve ser maior que zero para financiamento.");
        }

        if (LerMoeda(txtEdFinanciamento.Text) < 0) erros.Add("Financiamento ficou negativo. Confira valor do veículo, entrada e avaliação utilizada.");
        if (LerMoeda(txtEdSaldoAvaliacao.Text) < 0) erros.Add("Saldo da avaliação ficou negativo. Confira avaliação, valor utilizado e quitação.");

        if (erros.Count > 0)
        {
            mensagem = "Revise a edição antes de gravar:\n- " + String.Join("\n- ", erros.ToArray());
            return false;
        }

        mensagem = "";
        return true;
    }

    protected void btnAtualizarBI_Click(object sender, EventArgs e)
    {
        InicializarPeriodoBI();
        CarregarBI();
        TabContainerProcesso.ActiveTabIndex = 0;
    }

    private void InicializarPeriodoBI()
    {
        DateTime inicioMes = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
        DateTime fimMes = inicioMes.AddMonths(1).AddDays(-1);

        if (txtBiDtInicial.Text.Length == 0)
        {
            txtBiDtInicial.Text = inicioMes.ToString("dd/MM/yyyy");
        }

        if (txtBiDtFinal.Text.Length == 0)
        {
            txtBiDtFinal.Text = fimMes.ToString("dd/MM/yyyy");
        }
    }

    private void CarregarBI()
    {
        DateTime inicio;
        DateTime fim;
        ObterPeriodoBI(out inicio, out fim);

        try
        {
            List<ContratoBIItem> contratos = BuscarContratosBI(inicio, fim);
            biHtml = MontarHtmlBI(contratos, inicio, fim);
        }
        catch (Exception ex)
        {
            biHtml = "<div class='contract-bi-empty'>Não foi possível carregar o BI agora. Detalhe: "
                + HttpUtility.HtmlEncode(ex.Message) + "</div>";
        }
    }

    private void ObterPeriodoBI(out DateTime inicio, out DateTime fim)
    {
        CultureInfo cultura = new CultureInfo("pt-BR");
        DateTime inicioPadrao = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
        DateTime fimPadrao = inicioPadrao.AddMonths(1).AddDays(-1);

        if (!DateTime.TryParse(txtBiDtInicial.Text, cultura, DateTimeStyles.None, out inicio))
        {
            inicio = inicioPadrao;
        }

        if (!DateTime.TryParse(txtBiDtFinal.Text, cultura, DateTimeStyles.None, out fim))
        {
            fim = fimPadrao;
        }

        if (fim < inicio)
        {
            DateTime troca = inicio;
            inicio = fim;
            fim = troca;
        }

        txtBiDtInicial.Text = inicio.ToString("dd/MM/yyyy");
        txtBiDtFinal.Text = fim.ToString("dd/MM/yyyy");
    }

    private List<ContratoBIItem> BuscarContratosBI(DateTime inicio, DateTime fim)
    {
        List<ContratoBIItem> contratos = new List<ContratoBIItem>();
        Veiculos vec = new Veiculos();

        try
        {
            vec.Conexao();
            using (SqlCommand oCmd = new SqlCommand())
            {
                oCmd.Connection = vec.oCon;
                oCmd.CommandText = @"select id,
                                            isnull(vendedor, '') vendedor,
                                            isnull(tipo, '') tipo,
                                            cast([data] as date) data,
                                            isnull(valorveiculo, 0) valorveiculo,
                                            isnull(modalidade_pagamento, '') modalidade_pagamento
                                     from " + TabelaContratosBI + @"
                                     where [data] >= @inicio
                                       and [data] < dateadd(day, 1, @fim)
                                       and tipo in ('VN', 'VU', 'VD')
                                     order by [data] asc, id asc";
                oCmd.CommandType = CommandType.Text;
                oCmd.Parameters.Add("@inicio", SqlDbType.Date).Value = inicio;
                oCmd.Parameters.Add("@fim", SqlDbType.Date).Value = fim;

                using (SqlDataReader odr = oCmd.ExecuteReader())
                {
                    while (odr.Read())
                    {
                        contratos.Add(new ContratoBIItem
                        {
                            Vendedor = odr["vendedor"].ToString(),
                            Tipo = odr["tipo"].ToString(),
                            Data = Convert.ToDateTime(odr["data"]),
                            Valor = ConverterDecimal(odr["valorveiculo"]),
                            Pagamento = odr["modalidade_pagamento"].ToString()
                        });
                    }
                }
            }
        }
        finally
        {
            vec.FecharConexao();
        }

        return contratos;
    }

    private string MontarHtmlBI(List<ContratoBIItem> contratos, DateTime inicio, DateTime fim)
    {
        int total = contratos.Count;
        int totalVN = contratos.Count(x => x.Tipo == "VN");
        int totalVU = contratos.Count(x => x.Tipo == "VU");
        int totalVD = contratos.Count(x => x.Tipo == "VD");
        decimal valorTotal = contratos.Sum(x => x.Valor);

        StringBuilder html = new StringBuilder();
        html.Append("<div class='contract-bi-period'>Período analisado: ");
        html.Append(HttpUtility.HtmlEncode(inicio.ToString("dd/MM/yyyy")));
        html.Append(" a ");
        html.Append(HttpUtility.HtmlEncode(fim.ToString("dd/MM/yyyy")));
        html.Append("</div>");

        html.Append("<div class='contract-bi-cards'>");
        html.Append(BiCard("Total", total.ToString(), "Contratos no período"));
        html.Append(BiCard("Novos", totalVN.ToString(), "Contratos VN"));
        html.Append(BiCard("Usados", totalVU.ToString(), "Contratos VU"));
        html.Append(BiCard("Venda direta", totalVD.ToString(), "Contratos VD"));
        html.Append(BiCard("Valor total", valorTotal.ToString("C0", new CultureInfo("pt-BR")), "Soma dos veículos"));
        html.Append("</div>");

        if (total == 0)
        {
            html.Append("<div class='contract-bi-empty'>Sem contratos encontrados no período selecionado.</div>");
            return html.ToString();
        }

        Dictionary<string, int> porVendedor = AgruparPorTexto(contratos, "vendedor");
        Dictionary<string, int> porTipo = AgruparPorTexto(contratos, "tipo");
        Dictionary<string, int> porPagamento = AgruparPorTexto(contratos, "pagamento");
        SortedDictionary<DateTime, int> porDia = AgruparPorDia(contratos, inicio, fim);

        html.Append("<div class='contract-bi-layout'>");
        html.Append("<section class='contract-bi-chart wide'><h3>Evolução diária</h3>");
        html.Append(MontarGraficoDias(porDia));
        html.Append("</section>");
        html.Append("<section class='contract-bi-chart'><h3>Contratos por vendedor</h3>");
        html.Append(MontarBarras(porVendedor, true));
        html.Append("</section>");
        html.Append("<section class='contract-bi-chart'><h3>Tipos de contrato</h3>");
        html.Append(MontarBarras(porTipo, false));
        html.Append("</section>");
        html.Append("<section class='contract-bi-chart'><h3>Forma de pagamento</h3>");
        html.Append(MontarBarras(porPagamento, false));
        html.Append("</section>");
        html.Append("</div>");

        return html.ToString();
    }

    private string BiCard(string label, string value, string caption)
    {
        return "<article><span>" + HttpUtility.HtmlEncode(label) + "</span><strong>"
            + HttpUtility.HtmlEncode(value) + "</strong><small>" + HttpUtility.HtmlEncode(caption) + "</small></article>";
    }

    private Dictionary<string, int> AgruparPorTexto(List<ContratoBIItem> contratos, string campo)
    {
        Dictionary<string, int> grupo = new Dictionary<string, int>();

        foreach (ContratoBIItem contrato in contratos)
        {
            string chave = "";
            if (campo == "vendedor") chave = contrato.Vendedor;
            if (campo == "tipo") chave = NomeTipo(contrato.Tipo);
            if (campo == "pagamento") chave = NomePagamento(contrato.Pagamento);
            if (chave.Trim().Length == 0) chave = "Não informado";

            if (!grupo.ContainsKey(chave)) grupo[chave] = 0;
            grupo[chave]++;
        }

        return grupo;
    }

    private SortedDictionary<DateTime, int> AgruparPorDia(List<ContratoBIItem> contratos, DateTime inicio, DateTime fim)
    {
        SortedDictionary<DateTime, int> grupo = new SortedDictionary<DateTime, int>();
        for (DateTime dia = inicio.Date; dia <= fim.Date; dia = dia.AddDays(1))
        {
            grupo[dia] = 0;
        }

        foreach (ContratoBIItem contrato in contratos)
        {
            DateTime dia = contrato.Data.Date;
            if (!grupo.ContainsKey(dia)) grupo[dia] = 0;
            grupo[dia]++;
        }

        return grupo;
    }

    private string MontarBarras(Dictionary<string, int> dados, bool limitar)
    {
        if (dados.Count == 0) return "<p class='contract-bi-muted'>Sem dados para exibir.</p>";
        List<KeyValuePair<string, int>> ordenados = dados.OrderByDescending(x => x.Value).ThenBy(x => x.Key).ToList();
        if (limitar) ordenados = ordenados.Take(12).ToList();

        int max = ordenados.Max(x => x.Value);
        StringBuilder html = new StringBuilder();
        html.Append("<div class='contract-bi-bars'>");

        foreach (KeyValuePair<string, int> item in ordenados)
        {
            int porcentagem = max == 0 ? 0 : Convert.ToInt32(Math.Round((item.Value * 100.0) / max));
            html.Append("<div class='contract-bi-bar'><div class='contract-bi-bar-head'><span>");
            html.Append(HttpUtility.HtmlEncode(item.Key));
            html.Append("</span><strong>");
            html.Append(item.Value);
            html.Append("</strong></div><div class='contract-bi-track'><span style='width:");
            html.Append(porcentagem);
            html.Append("%'></span></div></div>");
        }

        html.Append("</div>");
        return html.ToString();
    }

    private string MontarGraficoDias(SortedDictionary<DateTime, int> dados)
    {
        int max = dados.Count == 0 ? 0 : dados.Max(x => x.Value);
        StringBuilder html = new StringBuilder();
        html.Append("<div class='contract-bi-days'>");

        foreach (KeyValuePair<DateTime, int> item in dados)
        {
            int altura = max == 0 ? 0 : Convert.ToInt32(Math.Round((item.Value * 100.0) / max));
            if (item.Value > 0 && altura < 12) altura = 12;
            html.Append("<div class='contract-bi-day' title='");
            html.Append(HttpUtility.HtmlEncode(item.Key.ToString("dd/MM/yyyy") + " - " + item.Value + " contratos"));
            html.Append("'><span style='height:");
            html.Append(altura);
            html.Append("%'></span><small>");
            html.Append(HttpUtility.HtmlEncode(item.Key.ToString("dd/MM")));
            html.Append("</small></div>");
        }

        html.Append("</div>");
        return html.ToString();
    }

    private string NomeTipo(string tipo)
    {
        if (tipo == "VN") return "Novo";
        if (tipo == "VU") return "Usado";
        if (tipo == "VD") return "Venda direta";
        return "Não informado";
    }

    private string NomePagamento(string pagamento)
    {
        if (pagamento == "A") return "À vista";
        if (pagamento == "F") return "Financiamento";
        return "Não informado";
    }

    private decimal ConverterDecimal(object valor)
    {
        if (valor == null || valor == DBNull.Value) return 0;
        try
        {
            return Convert.ToDecimal(valor);
        }
        catch
        {
            decimal convertido;
            if (decimal.TryParse(valor.ToString(), NumberStyles.Any, new CultureInfo("pt-BR"), out convertido)) return convertido;
            if (decimal.TryParse(valor.ToString(), NumberStyles.Any, CultureInfo.InvariantCulture, out convertido)) return convertido;
            return 0;
        }
    }

    private class ContratoBIItem
    {
        public string Vendedor { get; set; }
        public string Tipo { get; set; }
        public DateTime Data { get; set; }
        public decimal Valor { get; set; }
        public string Pagamento { get; set; }
    }

    protected void rbtnVU_CheckedChanged(object sender, EventArgs e)
    {
        if (rbtnVU.Checked == true)
        {
            lblEmpTrans.Text = "TRANSFERÊNCIA:";
            Panel1.Visible = true;
        }
    }
    protected void rbtnVN_CheckedChanged(object sender, EventArgs e)
    {
        if (rbtnVN.Checked == true)
        {
            lblEmpTrans.Text = "EMPLACAMENTO:";
            Panel1.Visible = true;

        }
    }
    protected void rbtnVD_CheckedChanged(object sender, EventArgs e)
    {
        if (rbtnVD.Checked == true)
        {
            lblEmpTrans.Text = "EMPLACAMENTO:";
            Panel1.Visible = true;

        }
    }
    protected void btnGravar_Click(object sender, EventArgs e)
    {
        calcula();

        if (rBtnModPagFinanciamento.Checked || rBtnModPagVista.Checked)
        {

            string modpag = "";
            string tipo = "";
            if (rBtnModPagVista.Checked)
            {
                modpag = "A";
            }
            if (rBtnModPagFinanciamento.Checked)
            {
                modpag = "F";
            }

            if (rbtnVN.Checked)
            {
                tipo = "VN";
            }
            if (rbtnVU.Checked)
            {
                tipo = "VU";
            }
            if (rbtnVD.Checked)
            {
                tipo = "VD";
            }

            string mensagemValidacao;
            try
            {
                if (!ValidarContratoNovo(modpag, tipo, out mensagemValidacao))
                {
                    ExibirAlerta(mensagemValidacao);
                    return;
                }
            }
            catch (FormatException)
            {
                ExibirAlerta("Revise os campos de valor. Use apenas números no formato 150000,00.");
                return;
            }

            try
            {
                Veiculos vec = new Veiculos();
                string obs;
                string codigo;
                insert_contrato_venda
                (
                    txtCliente.Text, txtEndereco.Text, txtCEP.Text, txtBairro.Text, txtCidade.Text,
                    txtUF.Text, txtCPFCNPJ.Text, txtRGIE.Text, txtNascimento.Text, txtTelREsidencial.Text,
                    txtTelCom.Text, txtCelular.Text, txtEmail.Text, txtMarca.Text, txtModelo.Text, txtCorExterna.Text,
                    txtChassiPlaca.Text, txtAnoMod.Text, txtOpcionais.Text, modpag, txtFinanceira.Text, txtValoVeiculo.Text,
                    txtEmplacamento.Text, txtEntrada.Text, txtFormasPagamento.Text,
                    txtCarroUsado.Text, txtModMarca.Text, txtPlacaVU.Text, txtAnoModelo.Text, txtVlFinanciamento.Text,
                    txtNrParcelas.Text, txtVlParcelas.Text, txtPlano.Text, txtCortesias.Text,
                    txtObs.Text, txtPrevisao.Text, ddlVendedor.Text, tipo, txtVlUtilzadoAvaliacao.Text, txtQuitacao.Text, txtSaldoAvaliacao.Text, out codigo, out obs
                );
                if (obs.Equals("S"))
                {
                    if (tipo == "VN")
                    {
                        Response.Redirect("Print-ContratoVN.aspx?contrato=" + codigo);
                    }
                    else if (tipo == "VU")
                    {
                        Response.Redirect("Print-ContratoVU.aspx?contrato=" + codigo);
                    }
                    else if (tipo == "VD")
                    {
                        Response.Redirect("Print-ContratoVD.aspx?contrato=" + codigo);
                    }
                }
                else if (obs.Equals("N") && codigo != null)
                {
                    ExibirAlerta("Possível duplicidade: já existe um contrato com estes dados. Código: " + codigo + ". Confira antes de tentar gravar novamente.");
                }
                else
                {
                    ExibirAlerta("Não foi possível gravar o contrato. Confira os campos obrigatórios e os valores informados.");
                }
            }
            catch (Exception ex)
            {
                ExibirAlerta("Não foi possível gravar o contrato. Revise valores como valor do veículo, entrada, avaliação, quitação e parcelas.");
            }

        }
        else
        {
            ExibirAlerta("Selecione a modalidade de pagamento: à vista ou financiamento.");

        }
    }
    protected void ibtnDadosCliente_Click(object sender, ImageClickEventArgs e)
    {
        try

        {
            Veiculos oVeiculos = new Veiculos();
            string total; string total2;
            oVeiculos.select_financiamento(txtValoVeiculo.Text, txtEntrada.Text, txtVlUtilzadoAvaliacao.Text, txtCarroUsado.Text, txtQuitacao.Text, out total, out total2);
            txtVlFinanciamento.Text = total;
            txtSaldoAvaliacao.Text = total2;
        }
        catch
        {
            ExibirAlerta("Não foi possível calcular. Use valores no formato 150000,00 e confira entrada, avaliação utilizada e quitação.");

        }
    }
    protected void calcula()
    {


        try
        {
            NormalizarCamposMonetarios();

            decimal financiamento = LerMoeda(txtValoVeiculo.Text) - LerMoeda(txtEntrada.Text) - LerMoeda(txtVlUtilzadoAvaliacao.Text);
            decimal saldoAvaliacao = LerMoeda(txtCarroUsado.Text) - LerMoeda(txtVlUtilzadoAvaliacao.Text) - LerMoeda(txtQuitacao.Text);
            decimal financiamentoEdicao = LerMoeda(txtEdValorVeic.Text) - LerMoeda(txtEdEntrada.Text) - LerMoeda(txtEdVALORUSADOAVAILACAO.Text);
            decimal saldoAvaliacaoEdicao = LerMoeda(txtEdValorUSADO.Text) - LerMoeda(txtEdVALORUSADOAVAILACAO.Text) - LerMoeda(txtEdQuitacao.Text);

            txtVlFinanciamento.Text = FormatarMoedaSistema(financiamento);
            txtSaldoAvaliacao.Text = FormatarMoedaSistema(saldoAvaliacao);
            txtEdFinanciamento.Text = FormatarMoedaSistema(financiamentoEdicao);
            txtEdSaldoAvaliacao.Text = FormatarMoedaSistema(saldoAvaliacaoEdicao);
        }
        catch (Exception)
        {
            ExibirAlerta("Não consegui calcular os valores. Use números no formato 150000,00 e evite letras nos campos de valor.");
        }

    }

    protected void txtCarroUsado_TextChanged(object sender, EventArgs e)
    {
        calcula();
    }
    protected void ImageButton1_Click(object sender, ImageClickEventArgs e)
    {

        string contrato = txtContrato.Text; string cliente; string endereco; string cep; string bairro; string cidade; string UF;
        string cpfcnpj; string RGIE; string nascimento; string tel_residencial; string tel_comercial;
        string tel_celular; string email; string marca; string modelo; string cor_ext; string chassiplaca;
        string anomodelo; string opcinonais; string modalidade_pagamento; string financeira; string valorveiculo;
        string emp_trans; string entrada; string formaspagamento; string carrousado; string modmarcavu;
        string palcavu; string financiamento; string qtdeparcelas; string vlparcelas; string planofinanciamento;
        string cortesias; string obs; string previsaoentrega; string vendedor; string tipo; string data; string multa; string vlutilizadoavaliacao; string vlquitacao; string vlsaldoavaliacao; string anomodeloVU;
        Veiculos vec = new Veiculos();
        vec.select_contrato_venda2(contrato,
        out cliente, out endereco, out cep, out bairro, out cidade
        , out UF, out cpfcnpj, out RGIE, out nascimento, out tel_residencial
        , out tel_comercial, out tel_celular, out email, out marca, out modelo
        , out cor_ext, out chassiplaca, out anomodelo, out opcinonais, out modalidade_pagamento
        , out financeira, out valorveiculo, out emp_trans, out entrada
        , out formaspagamento, out carrousado, out modmarcavu, out palcavu, out anomodeloVU, out financiamento
        , out qtdeparcelas, out vlparcelas, out planofinanciamento, out cortesias
        , out obs, out previsaoentrega, out vendedor, out tipo, out data, out multa, out vlutilizadoavaliacao, out vlquitacao, out vlsaldoavaliacao);

        txtEdCliente.Text = cliente; txtEdEndereco.Text = endereco; txtEdCep.Text = cep; txtEdBairro.Text = bairro; txtEdCidade.Text = cidade; txtEdUF.Text = UF; txtEdCPF.Text = cpfcnpj; txtEdRG.Text = RGIE; txtEdNascimento.Text = nascimento;
        txtEdTelRes.Text = tel_residencial; txtEdComercial.Text = tel_comercial; txtEdCelular.Text = tel_celular; txtEdEmail.Text = email; txtEdMarca.Text = marca; txtEdModelo.Text = modelo; txtEdCorExt.Text = cor_ext; txtEdChassi.Text = chassiplaca;
        txtEdAnomodelo.Text = anomodelo; txtEdOpcionais.Text = opcinonais; txtEdFinanceira.Text = financeira; txtEdValorVeic.Text = valorveiculo; txtEdTAXAS.Text = emp_trans; txtEdEntrada.Text = entrada; txtEdFormasPagamento.Text = formaspagamento;
        txtEdValorUSADO.Text = carrousado; txtEdModMarcaUSADO.Text = modmarcavu; txtEdPlacaUSADO.Text = palcavu; txtEdFinanciamento.Text = financiamento; txtEdNumeroParcelas.Text = qtdeparcelas; txtEdValorParcela.Text = vlparcelas; txtEdPlanoFinanciamento.Text = planofinanciamento;
        txtEdCortesias.Text = cortesias; txtEdObs.Text = obs; txtEdPrevisao.Text = previsaoentrega; txtEdVendedor.Text = vendedor; txtEdVALORUSADOAVAILACAO.Text = vlutilizadoavaliacao; txtEdQuitacao.Text = vlquitacao; txtEdSaldoAvaliacao.Text = vlsaldoavaliacao; txtEdAnoMOdUSADO.Text = anomodeloVU;
        rbtnEdAVISTA.Checked = modalidade_pagamento == "A";
        rbtnEdAprazo.Checked = modalidade_pagamento == "F";

    }

    protected void btnEditareGravar_Click(object sender, EventArgs e)
    {

        try
        {
            calcula();
            string modpag = "";
            if (rbtnEdAVISTA.Checked)
            {
                modpag = "A";
            }
            if (rbtnEdAprazo.Checked)
            {
                modpag = "F";
            }

            string mensagemValidacao;
            try
            {
                if (!ValidarContratoEdicao(modpag, out mensagemValidacao))
                {
                    ExibirAlerta(mensagemValidacao);
                    return;
                }
            }
            catch (FormatException)
            {
                ExibirAlerta("Revise os campos de valor. Use apenas números no formato 150000,00.");
                return;
            }


            Veiculos vec = new Veiculos();
            string contrato = vec.update_contrato_venda(Convert.ToInt32(txtContrato.Text), txtEdCliente.Text, txtEdEndereco.Text, txtEdCep.Text, txtEdBairro.Text, txtEdCidade.Text,
                txtEdUF.Text, txtEdCPF.Text, txtEdRG.Text, txtEdNascimento.Text, txtEdTelRes.Text,
                txtEdComercial.Text, txtEdCelular.Text, txtEdEmail.Text, txtEdMarca.Text, txtEdModelo.Text, txtEdCorExt.Text,
                txtEdChassi.Text, txtEdAnomodelo.Text, txtEdOpcionais.Text, modpag, txtEdFinanceira.Text, Convert.ToString(txtEdValorVeic.Text),
                txtEdTAXAS.Text, txtEdEntrada.Text, txtEdFormasPagamento.Text,
                txtEdValorUSADO.Text, txtEdModMarcaUSADO.Text, txtEdPlacaUSADO.Text, txtEdAnoMOdUSADO.Text, txtEdFinanciamento.Text,
                txtEdNumeroParcelas.Text, txtEdValorParcela.Text, txtEdPlanoFinanciamento.Text, txtEdCortesias.Text,
                txtEdObs.Text, txtEdPrevisao.Text, txtEdVendedor.Text, txtEdVALORUSADOAVAILACAO.Text, txtEdQuitacao.Text, txtEdSaldoAvaliacao.Text);

            ExibirAlerta("Contrato alterado com sucesso.");



        }

        catch (Exception)
        {
            ExibirAlerta("Não foi possível alterar o contrato. Revise valores, modalidade de pagamento, parcelas e vendedor.");
        }

    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        string tabelaR;
        select_Tab_Consulta(txtDtInicialVN.Text,txtDtFinalVN.Text, out tabelaR);
        tabela = tabelaR;
    }
    protected void Button2_Click(object sender, EventArgs e)
    {
        string tabelaVUR;

        select_Tab_ConsultaVU(txtDtInicialVU.Text,txtDtFinalVU.Text, out tabelaVUR);

        tabelaVU = tabelaVUR;
    }
    protected void ButtonVD_Click(object sender, EventArgs e)
    {
        string tabelaVDR;
        select_Tab_ConsultaVD(txtDtInicialVD.Text, txtDtFinalVD.Text, out tabelaVDR);

        tabelaVD = tabelaVDR;
    }






    public void insert_contrato_venda
        (
              string cliente
            , string endereco
            , string cep
            , string bairro
            , string cidade
            , string UF
            , string cpfcnpj
            , string RGIE
            , string nascimento
            , string tel_residencial
            , string tel_comercial
            , string tel_celular
            , string email
            , string marca
            , string modelo
            , string cor_ext
            , string chassiplaca
            , string anomodelo
            , string opcinonais
            , string modalidade_pagamento
            , string financeira
            , string valorveiculo
            , string emp_trans
            , string entrada
            , string formaspagamento
            , string carrousado
            , string modmarcavu
            , string palcavu
            , string anomodeloVU
            , string financiamento
            , string qtdeparcelas
            , string vlparcelas
            , string planofinanciamento
            , string cortesias
            , string obs
            , string previsaoentrega
            , string vendedor
            , string tipo
            , string vlutilizadoavaliacao
            , string vlquitacao
            , string vlsaldoavaliacao
            , out string codigoResponse
            , out string obsResponse
        )
    {
        codigoResponse = "";
        obsResponse = "N";

        Veiculos vec = new Veiculos();
        if (valorveiculo == "") { valorveiculo = "0"; }
        if (emp_trans == "") { emp_trans = "0"; }
        if (entrada == "") { entrada = "0"; }
        if (carrousado == "") { carrousado = "0"; }
        if (financiamento == "") { financiamento = "0"; }
        if (vlparcelas == "") { vlparcelas = "0"; }
        try
        {
            vec.Conexao();

            SqlCommand oCmd = new SqlCommand();
            oCmd.Connection = vec.oCon;
            oCmd.CommandText = "APP..veiculos_insert_contrato_venda";
            oCmd.CommandType = CommandType.StoredProcedure;
            oCmd.Parameters.Add("@cliente", SqlDbType.VarChar).Value = cliente;
            oCmd.Parameters.Add("@endereco", SqlDbType.VarChar).Value = endereco;
            oCmd.Parameters.Add("@cep", SqlDbType.VarChar).Value = cep;
            oCmd.Parameters.Add("@bairro", SqlDbType.VarChar).Value = bairro;
            oCmd.Parameters.Add("@cidade", SqlDbType.VarChar).Value = cidade;
            oCmd.Parameters.Add("@UF", SqlDbType.VarChar).Value = UF;
            oCmd.Parameters.Add("@cpfcnpj", SqlDbType.VarChar).Value = cpfcnpj;
            oCmd.Parameters.Add("@RGIE", SqlDbType.VarChar).Value = RGIE;
            oCmd.Parameters.Add("@nascimento", SqlDbType.VarChar).Value = nascimento;
            oCmd.Parameters.Add("@tel_residencial", SqlDbType.VarChar).Value = tel_residencial;
            oCmd.Parameters.Add("@tel_comercial", SqlDbType.VarChar).Value = tel_comercial;
            oCmd.Parameters.Add("@tel_celular", SqlDbType.VarChar).Value = tel_celular;
            oCmd.Parameters.Add("@email", SqlDbType.VarChar).Value = email;
            oCmd.Parameters.Add("@marca", SqlDbType.VarChar).Value = marca;
            oCmd.Parameters.Add("@modelo", SqlDbType.VarChar).Value = modelo;
            oCmd.Parameters.Add("@cor_ext", SqlDbType.VarChar).Value = cor_ext;
            oCmd.Parameters.Add("@chassiplaca", SqlDbType.VarChar).Value = chassiplaca;
            oCmd.Parameters.Add("@anomodelo", SqlDbType.VarChar).Value = anomodelo;
            oCmd.Parameters.Add("@opcinonais", SqlDbType.VarChar).Value = opcinonais;
            oCmd.Parameters.Add("@modalidade_pagamento", SqlDbType.VarChar).Value = modalidade_pagamento;
            oCmd.Parameters.Add("@financeira", SqlDbType.VarChar).Value = financeira;
            oCmd.Parameters.Add("@valorveiculo", SqlDbType.Float).Value = Convert.ToDouble(valorveiculo);
            oCmd.Parameters.Add("@emp_trans", SqlDbType.Float).Value = Convert.ToDouble(emp_trans);
            oCmd.Parameters.Add("@entrada", SqlDbType.Float).Value = Convert.ToDouble(entrada);
            oCmd.Parameters.Add("@formaspagamento", SqlDbType.VarChar).Value = formaspagamento;
            oCmd.Parameters.Add("@carrousado", SqlDbType.Float).Value = Convert.ToDouble(carrousado);
            oCmd.Parameters.Add("@modmarcavu", SqlDbType.VarChar).Value = modmarcavu;
            oCmd.Parameters.Add("@palcavu", SqlDbType.VarChar).Value = palcavu;
            oCmd.Parameters.Add("@anomodeloVU", SqlDbType.VarChar).Value = anomodeloVU;
            oCmd.Parameters.Add("@financiamento", SqlDbType.Float).Value = Convert.ToDouble(financiamento);
            oCmd.Parameters.Add("@qtdeparcelas", SqlDbType.VarChar).Value = qtdeparcelas;
            oCmd.Parameters.Add("@vlparcelas", SqlDbType.Float).Value = Convert.ToDouble(vlparcelas);
            oCmd.Parameters.Add("@planofinanciamento", SqlDbType.VarChar).Value = planofinanciamento;
            oCmd.Parameters.Add("@cortesias", SqlDbType.VarChar).Value = cortesias;
            oCmd.Parameters.Add("@obs", SqlDbType.VarChar).Value = obs;
            oCmd.Parameters.Add("@previsaoentrega", SqlDbType.VarChar).Value = previsaoentrega;
            oCmd.Parameters.Add("@vendedor", SqlDbType.VarChar).Value = vendedor;
            oCmd.Parameters.Add("@tipo", SqlDbType.VarChar).Value = tipo;
            oCmd.Parameters.Add("@vlutilizadoavaliacao", SqlDbType.Float).Value = Convert.ToDouble(vlutilizadoavaliacao);
            oCmd.Parameters.Add("@vlquitacao", SqlDbType.Float).Value = Convert.ToDouble(vlquitacao);
            oCmd.Parameters.Add("@vlsaldoavaliacao", SqlDbType.Float).Value = Convert.ToDouble(vlsaldoavaliacao);

            SqlDataReader odr = oCmd.ExecuteReader();
            odr.Read();
            codigoResponse = odr["id"].ToString();
            obsResponse = odr["obs"].ToString();
        }
        catch
        {
            obsResponse = "E";
        }
        finally
        {
            vec.FecharConexao();
        }
    }
    public void select_Tab_ConsultaVU(string dtInicio, string dtFim, out string tabelaVU)
    {
        Veiculos vec = new Veiculos();
        vec.Conexao();

        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = "APP..veiculos_select_tab_consultaVU";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@dtInicio", SqlDbType.Date).Value = dtInicio;
        oCmd.Parameters.Add("@dtFim", SqlDbType.Date).Value = dtFim;
        SqlDataReader odr = oCmd.ExecuteReader();
        string head = @"<table cellpadding='0' cellspacing='0' border='0' id='tblConsultaProcesso2' class='display' style='font-family:arial;'>
                        <thead >
                            <tr>
                                <td style='text-align:center; font-size:12px;'>ID</td>
                                <td style='text-align:center; font-size:12px;'>Cliente</td>
                                <td style='text-align:center; font-size:12px;'>CPF</td>
                                <td style='text-align:center; font-size:12px;'>Telefone1</td>
                                <td style='text-align:center; font-size:12px;'>Telefone2</td>
                                <td style='text-align:center; font-size:12px;'>Telefone3</td>
                                <td style='text-align:center; font-size:12px;'>email</td>
                                <td style='text-align:center; font-size:12px;'>vendedor</td>
                                </tr>
                        </thead>";
        string body = "<tbody>";
        // a quantidade de colunas(tfoot) deve se a mesma quantidade de colunas da tabela do banco.
        string foot = @"</tbody></table>";
        while (odr.Read())
        {
            body = body + @"<tr>
                           <td style='text-align:center; font-size:12px;'>" + odr["id"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cliente"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cpfcnpj"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_residencial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_comercial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_celular"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["email"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["vendedor"].ToString() +
                           "</td></tr>";
        }

        tabelaVU = head + body + foot;
        vec.FecharConexao();
    }

    public void select_Tab_ConsultaVD(string dtInicio, string dtFim, out string tabelaVU)
    {
        Veiculos vec = new Veiculos();
        vec.Conexao();

        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = "APP..veiculos_select_tab_consulta_vd";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@dtInicio", SqlDbType.Date).Value = dtInicio;
        oCmd.Parameters.Add("@dtFim", SqlDbType.Date).Value = dtFim;
        SqlDataReader odr = oCmd.ExecuteReader();
        string head = @"<table cellpadding='0' cellspacing='0' border='0' id='tblConsultaProcesso2' class='display' style='font-family:arial;'>
                        <thead >
                            <tr>
                                <td style='text-align:center; font-size:12px;'>ID</td>
                                <td style='text-align:center; font-size:12px;'>Cliente</td>
                                <td style='text-align:center; font-size:12px;'>CPF</td>
                                <td style='text-align:center; font-size:12px;'>Telefone1</td>
                                <td style='text-align:center; font-size:12px;'>Telefone2</td>
                                <td style='text-align:center; font-size:12px;'>Telefone3</td>
                                <td style='text-align:center; font-size:12px;'>email</td>
                                <td style='text-align:center; font-size:12px;'>vendedor</td>
                                </tr>
                        </thead>";
        string body = "<tbody>";
        // a quantidade de colunas(tfoot) deve se a mesma quantidade de colunas da tabela do banco.
        string foot = @"</tbody></table>";
        while (odr.Read())
        {
            body = body + @"<tr>
                           <td style='text-align:center; font-size:12px;'>" + odr["id"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cliente"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cpfcnpj"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_residencial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_comercial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_celular"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["email"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["vendedor"].ToString() +
                           "</td></tr>";
        }

        tabelaVU = head + body + foot;
        vec.FecharConexao();
    }
    public void select_Tab_Consulta(string dtInicio, string dtFim,out string tabela)
    {
        Veiculos vec = new Veiculos();
        vec.Conexao();

        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = "APP..veiculos_select_tab_consulta";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@dtInicio", SqlDbType.Date).Value = dtInicio;
        oCmd.Parameters.Add("@dtFim", SqlDbType.Date).Value = dtFim;
        SqlDataReader odr = oCmd.ExecuteReader();
        string head = @"<table cellpadding='0' cellspacing='0' border='0' id='tblConsultaProcesso' class='display' style='font-family:arial;'>
                        <thead >
                            <tr>
                                <td style='text-align:center; font-size:12px;'>ID</td>
                                <td style='text-align:center; font-size:12px;'>Cliente</td>
                                <td style='text-align:center; font-size:12px;'>CPF</td>
                                <td style='text-align:center; font-size:12px;'>Telefone1</td>
                                <td style='text-align:center; font-size:12px;'>Telefone2</td>
                                <td style='text-align:center; font-size:12px;'>Telefone3</td>
                                <td style='text-align:center; font-size:12px;'>email</td>
                                <td style='text-align:center; font-size:12px;'>vendedor</td>
                                </tr>
                        </thead>";
        string body = "<tbody>";
        // a quantidade de colunas(tfoot) deve se a mesma quantidade de colunas da tabela do banco.
        string foot = @"</tbody></table>";
        while (odr.Read())
        {
            //valor = Convert.ToDouble(odr["Valor"]);
            //<span title="<%# Eval("Numero") %>" onclick="consultaChamadoAberto(this)"><%# Eval("Numero") %></span>
            body = body + @"<tr>
                           <td style='text-align:center; font-size:12px;'>" + odr["id"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cliente"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cpfcnpj"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_residencial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_comercial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_celular"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["email"].ToString() +
                          "</td><td style='text-align:center; font-size:12px;'>" + odr["vendedor"].ToString() +
                           "</td></tr>";
        }

        tabela = head + body + foot;
        vec.FecharConexao();
    }



}


