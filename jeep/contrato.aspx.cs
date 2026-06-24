using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows.Forms;
using System.Drawing;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;

public partial class veiculos_contrato : System.Web.UI.Page
{
    private const string TabelaContratosBI = "dbo.veiculos_contrato_vendaJEEP";

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



            try
            {
                Veiculos vec = new Veiculos();
                string obs;
                string codigo;
                vec.insert_contrato_vendajeep(txtCliente.Text, txtEndereco.Text, txtCEP.Text, txtBairro.Text, txtCidade.Text,
                    txtUF.Text, txtCPFCNPJ.Text, txtRGIE.Text, txtNascimento.Text, txtTelREsidencial.Text,
                    txtTelCom.Text, txtCelular.Text, txtEmail.Text, txtMarca.Text, txtModelo.Text, txtCorExterna.Text,
                    txtChassiPlaca.Text, txtAnoMod.Text, txtOpcionais.Text, modpag, txtFinanceira.Text, txtValoVeiculo.Text,
                    txtEmplacamento.Text, txtEntrada.Text, txtFormasPagamento.Text,
                    txtCarroUsado.Text, txtModMarca.Text, txtPlacaVU.Text, txtAnoModelo.Text, txtVlFinanciamento.Text,
                    txtNrParcelas.Text, txtVlParcelas.Text, txtPlano.Text, txtCortesias.Text,
                    txtObs.Text, txtPrevisao.Text, ddlVendedor.Text, tipo, txtVlUtilzadoAvaliacao.Text, txtQuitacao.Text, txtSaldoAvaliacao.Text, out codigo, out obs);

                if (obs.Equals("S"))
                {
                    if (tipo == "VN")
                    {
                        Response.Redirect("Print-ContratoVNJEEP.aspx?contrato=" + codigo);
                    }
                    if (tipo == "VU")
                    {
                        Response.Redirect("Print-ContratoVUJEEP.aspx?contrato=" + codigo);
                    }
                }
                else if (obs.Equals("N") && codigo != null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Duplicidade! O contrato já existe. Código: " + codigo + "');", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Preencha todos os campos corretamente!!¹');", true);

                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                   "alert('Preencha todos os campos corretamente!!³');", true);
            }

        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                   "alert('Informe a modalidade de pagamento!');", true);
        
        }
    }
    protected void ibtnDadosCliente_Click(object sender, ImageClickEventArgs e)
    {
       try 
                      
           {
           Veiculos oVeiculos = new Veiculos();
           string total; string total2;
        oVeiculos.select_financiamento(txtValoVeiculo.Text, txtEntrada.Text, txtVlUtilzadoAvaliacao.Text,txtCarroUsado.Text,txtQuitacao.Text, out total, out total2);
        txtVlFinanciamento.Text = total;
        txtSaldoAvaliacao.Text = total2;
          }
         catch
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                   "alert('Informe os valores CORRETOS!!');", true);
        
        }
    }
    protected void calcula()
    {


        try
        {
            if (txtValoVeiculo.Text == "") { txtValoVeiculo.Text = "0"; }
            if (txtEntrada.Text == "") { txtEntrada.Text = "0"; }
            if (txtVlUtilzadoAvaliacao.Text == "") { txtVlUtilzadoAvaliacao.Text = "0"; }
            if (txtQuitacao.Text == "") { txtQuitacao.Text = "0"; }
            if (txtCarroUsado.Text == "") { txtCarroUsado.Text = "0"; }
            if (txtEdValorVeic.Text == "") { txtEdValorVeic.Text = "0"; }
            if (txtEdEntrada.Text == "") { txtEdEntrada.Text = "0"; }
            if (txtEdVALORUSADOAVAILACAO.Text == "") { txtEdVALORUSADOAVAILACAO.Text = "0"; }
            if (txtEdValorUSADO.Text == "") { txtEdValorUSADO.Text = "0"; }
            if (txtEdQuitacao.Text == "") { txtEdQuitacao.Text = "0"; }



            txtVlFinanciamento.Text = (
                Convert.ToDouble(txtValoVeiculo.Text.Replace("R$", "")) -
                Convert.ToDouble(txtEntrada.Text.Replace("R$", "")) -
                Convert.ToDouble(txtVlUtilzadoAvaliacao.Text.Replace("R$", ""))
                ).ToString();
            txtSaldoAvaliacao.Text = (
                Convert.ToDouble(txtCarroUsado.Text.Replace("R$", "")) -
                Convert.ToDouble(txtVlUtilzadoAvaliacao.Text) -
                Convert.ToDouble(txtQuitacao.Text)).ToString();
            txtEdFinanciamento.Text = (
                Convert.ToDouble(txtEdValorVeic.Text.Replace("R$", "")) - 
                Convert.ToDouble(txtEdEntrada.Text.Replace("R$", "")) - 
                Convert.ToDouble(txtEdVALORUSADOAVAILACAO.Text.Replace("R$", ""))
                ).ToString();
            txtEdSaldoAvaliacao.Text = (
                Convert.ToDouble(txtEdValorUSADO.Text.Replace("R$", "")) - 
                Convert.ToDouble(txtEdVALORUSADOAVAILACAO.Text.Replace("R$", "")) - 
                Convert.ToDouble(txtEdQuitacao.Text.Replace("R$", ""))
                ).ToString();
        }
        catch (Exception)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                  "alert('Informe os valores CORRETOS!!');", true);
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
        vec.select_contrato_vendajeep(contrato,
        out  cliente, out endereco, out cep, out bairro, out cidade
        , out UF, out cpfcnpj, out RGIE, out nascimento, out tel_residencial
        , out tel_comercial, out tel_celular, out email, out marca, out modelo
        , out cor_ext, out chassiplaca, out anomodelo, out opcinonais, out modalidade_pagamento
        , out financeira, out valorveiculo, out emp_trans, out entrada
        , out formaspagamento, out carrousado, out modmarcavu, out palcavu, out anomodeloVU, out financiamento
        , out qtdeparcelas, out vlparcelas, out planofinanciamento, out cortesias
        , out obs, out previsaoentrega, out vendedor, out tipo, out data, out multa, out vlutilizadoavaliacao, out vlquitacao, out vlsaldoavaliacao);

        txtEdCliente.Text = cliente; txtEdEndereco.Text = endereco; txtEdCep.Text = cep; txtEdBairro.Text = bairro; txtEdCidade.Text = cidade; txtEdUF.Text = UF; txtEdCPF.Text = cpfcnpj; txtEdRG.Text = RGIE; txtEdNascimento.Text = nascimento;
        txtEdTelRes.Text = tel_residencial; txtEdComercial.Text = tel_comercial; txtEdCelular.Text = tel_celular; txtEdEmail.Text = email; txtEdMarca.Text = marca; txtEdModelo.Text = modelo; txtEdCorExt.Text = cor_ext; txtEdChassi.Text = chassiplaca;
        txtAnoModelo.Text = anomodelo; txtEdOpcionais.Text = opcinonais; txtEdFinanceira.Text = financeira; txtEdValorVeic.Text = valorveiculo; txtEdTAXAS.Text = emp_trans; txtEdEntrada.Text = entrada; txtEdFormasPagamento.Text = formaspagamento;
        txtEdValorUSADO.Text = carrousado; txtEdAnoMOdUSADO.Text = modmarcavu; txtEdPlacaUSADO.Text = palcavu; txtEdFinanciamento.Text = financiamento; txtEdNumeroParcelas.Text = qtdeparcelas; txtEdValorParcela.Text = vlparcelas; txtEdPlanoFinanciamento.Text = planofinanciamento;
        txtEdCortesias.Text = cortesias; txtEdObs.Text = obs; txtEdPrevisao.Text = previsaoentrega; txtEdVendedor.Text = vendedor; txtEdVALORUSADOAVAILACAO.Text = vlutilizadoavaliacao; txtEdQuitacao.Text = vlquitacao; txtEdSaldoAvaliacao.Text = vlsaldoavaliacao; txtEdAnoMOdUSADO.Text = anomodeloVU;

    }

  protected void btnEditareGravar_Click(object sender, EventArgs e)
  {

      try
        {
      calcula();

      string modpag = "";
      string tipo = "";
       
      Veiculos vec = new Veiculos();
           string contrato = vec.update_contrato_vendajeep(Convert.ToInt16(txtContrato.Text), txtEdCliente.Text, txtEdEndereco.Text, txtEdCep.Text, txtEdBairro.Text, txtEdCidade.Text,
                txtEdUF.Text, txtEdCPF.Text, txtEdRG.Text, txtEdNascimento.Text, txtEdTelRes.Text,
                txtEdComercial.Text, txtEdCelular.Text, txtEdEmail.Text, txtEdMarca.Text, txtEdModelo.Text, txtEdCorExt.Text,
                txtEdChassi.Text, txtEdAnomodelo.Text, txtEdOpcionais.Text, modpag, txtEdFinanceira.Text, Convert.ToString(txtEdValorVeic.Text),
                txtEdTAXAS.Text, txtEdEntrada.Text, txtEdFormasPagamento.Text,
                txtEdValorUSADO.Text, txtEdModMarcaUSADO.Text, txtEdPlacaUSADO.Text, txtEdAnoMOdUSADO.Text, txtEdFinanciamento.Text,
                txtEdNumeroParcelas.Text, txtEdValorParcela.Text, txtEdPlanoFinanciamento.Text, txtEdCortesias.Text,
                txtEdObs.Text, txtEdPrevisao.Text, txtEdVendedor.Text, txtEdVALORUSADOAVAILACAO.Text, txtEdQuitacao.Text, txtEdSaldoAvaliacao.Text);

        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                  "alert('Contrato Alterado');", true);
          
		
          
        }  
     
       catch (Exception)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                  "alert('Informe os valores CORRETOS!!');", true);
        }  
     
  }

  protected void Button1_Click(object sender, EventArgs e)
  {
      Veiculos ovec = new Veiculos();
      string tabelaR;
      string tabelaVUR;
      ovec.select_Tab_Consultajeep(txtDtInicialVN.Text, txtDtFinalVN.Text, out tabelaR);
      //ovec.select_Tab_ConsultaVU(out tabelaVUR);

      tabela = tabelaR;
     // tabelaVU = tabelaVUR;
  }
  protected void Button2_Click(object sender, EventArgs e)
  {
      Veiculos ovec = new Veiculos();
      string tabelaR;
      string tabelaVUR;
      //ovec.select_Tab_Consulta(out tabelaR);
      ovec.select_Tab_ConsultaVUjeep(out tabelaVUR);

      //tabela = tabelaR;
      tabelaVU = tabelaVUR;
  }

   
    
}

    


