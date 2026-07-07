using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;

public partial class veiculos_Autorizacao_polimento : System.Web.UI.Page
{
    private const string MarcaPolimento = "Fiat";
    private const string EmpresaDocumento = "BALI BRASILIA AUTOMOVEIS LTDA";
    private const string LoginRetorno = "./loginAppcontrato.aspx";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["usuario"] == null || Session["usuario"].ToString().Equals(""))
        {
            Response.Redirect(LoginRetorno);
            return;
        }

        lblUsuario.Text = Session["usuario"].ToString();
        lblTipo.Text = Session["usuario_codigo"] == null ? "-" : Session["usuario_codigo"].ToString();

        if (!IsPostBack)
        {
            lblEmpresa.Text = EmpresaDocumento;
            lblEmpresaAssinatura.Text = EmpresaDocumento;
            lblData.Text = DataExtenso(DateTime.Today);
            txtBIDataInicial.Text = PrimeiroDiaMes().ToString("dd/MM/yyyy");
            txtBIDataFinal.Text = DateTime.Today.ToString("dd/MM/yyyy");
            CarregarBI(false);
        }
    }

    protected void btnGerar_Click(object sender, EventArgs e)
    {
        string pedido = SomenteNumeros(txtPedido.Text, 12);
        string loja = SomenteNumeros(txtLoja.Text, 3);
        txtPedido.Text = pedido;
        txtLoja.Text = loja;

        if (String.IsNullOrWhiteSpace(pedido) || String.IsNullOrWhiteSpace(loja))
        {
            Avisar("Informe pedido e loja usando apenas números.", "error");
            return;
        }

        try
        {
            DataRow dados = ConsultarAutorizacaoPolimento(pedido, loja);
            if (dados == null)
            {
                Avisar("Pedido não encontrado para essa loja. Confira o número do pedido e o código da loja.", "error");
                return;
            }

            lblPedidoPrint.Text = pedido;
            lblCliente.Text = Valor(dados, "Cliente");
            lblVeiculo.Text = Valor(dados, "Veículo");
            lblChassi.Text = Valor(dados, "Chassi");
            lblCor.Text = Valor(dados, "Cor");
            lblAno.Text = Valor(dados, "Ano / Modelo");
            lblNota.Text = Valor(dados, "Nota Fiscal");
            lblPlaca.Text = TextoOuTraco(Valor(dados, "Placa"));
            lblVendedor.Text = Valor(dados, "Vendedor");
            lblProposta.Text = Valor(dados, "Proposta_Codigo");
            lblUnidade.Text = TextoOuTraco(Valor(dados, "Unidade"));
            lblUnidadeAssinatura.Text = TextoOuTraco(Valor(dados, "Unidade"));
            lblValor.Text = ValorMoeda(dados, "Valor");
            lblEmpresa.Text = EmpresaDocumento;
            lblEmpresaAssinatura.Text = EmpresaDocumento;
            lblData.Text = DataExtenso(DateTime.Today);

            bool registrado = PolimentoAutorizacao.RegistrarGeracao(MarcaPolimento, pedido, loja, dados, Context);
            CarregarBI(false);
            if (!registrado)
            {
                Avisar("Autorização gerada, mas não foi possível registrar nos dados gerenciais agora.", "error");
            }
        }
        catch
        {
            Avisar("Não foi possível gerar a autorização agora. Confira pedido e loja ou tente novamente.", "error");
        }
    }

    protected void btnAtualizarBI_Click(object sender, EventArgs e)
    {
        hdnPolimentoTab.Value = "dados";
        CarregarBI(true);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "polimentoDados", "window.abrirPolimentoTab && window.abrirPolimentoTab('dados');", true);
    }

    private DataRow ConsultarAutorizacaoPolimento(string pedido, string loja)
    {
        Dao2 banco = new Dao2();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"
SELECT
    SUM(ISNULL(propparc.PropostaParcela_Valor, 0)) AS [Valor],
    Proposta_ModeloVeiculoDes AS [Veículo],
    ve.Veiculo_Chassi AS [Chassi],
    cor.cor_descricao AS [Cor],
    veano.VeiculoAno_Exibicao AS [Ano / Modelo],
    NotaFiscal_Numero AS [Nota Fiscal],
    p.Pessoa_Nome AS [Cliente],
    ve.Veiculo_Placa AS [Placa],
    usuario.Usuario_Nome AS [Vendedor],
    prop.Proposta_Codigo,
    CASE nf.NotaFiscal_EmpresaCod
        WHEN '01' THEN 'JEEP SAAN'
        WHEN '02' THEN 'PARK SUL'
        WHEN '03' THEN 'BALI BYD'
        WHEN '04' THEN 'RAM'
        WHEN '05' THEN 'FIAT SIA'
        WHEN '06' THEN 'FIAT SCIA'
        WHEN '07' THEN 'FIAT SAAN'
        ELSE 'LOJA ' + CONVERT(varchar(10), nf.NotaFiscal_EmpresaCod)
    END AS [Unidade]
FROM GrupoBali_DealernetWF..notafiscal nf
INNER JOIN GrupoBali_DealernetWF..proposta prop
    ON prop.Proposta_NotaFiscalCod = nf.NotaFiscal_Codigo
INNER JOIN GrupoBali_DealernetWF..Atendimento atend
    ON atend.Atendimento_Codigo = prop.Atendimento_Codigo
INNER JOIN GrupoBali_DealernetWF..Usuario usuario
    ON usuario.Usuario_Codigo = atend.Atendimento_UsuarioCod
INNER JOIN GrupoBali_DealernetWF..PropostaParcela propparc
    ON propparc.Proposta_Codigo = prop.Proposta_Codigo
INNER JOIN GrupoBali_DealernetWF..Veiculo ve
    ON ve.Veiculo_Codigo = prop.Proposta_VeiculoCod
INNER JOIN GrupoBali_DealernetWF..VeiculoAno veano
    ON veano.VeiculoAno_Codigo = ve.VeiculoAno_Codigo
INNER JOIN GrupoBali_DealernetWF..Cor cor
    ON cor.cor_codigo = ve.Veiculo_CorCodExterna
INNER JOIN GrupoBali_DealernetWF..Pessoa p
    ON p.Pessoa_Codigo = nf.NotaFiscal_PessoaCod
WHERE NotaFiscal_NaturezaOperacaoCod IN (11, 19, 48, 74)
  AND NotaFiscal_Status = 'emi'
  AND prop.Proposta_Pedido = @pedido
  AND nf.NotaFiscal_EmpresaCod = @loja
GROUP BY
    Proposta_ModeloVeiculoDes,
    ve.Veiculo_Chassi,
    cor.cor_descricao,
    veano.VeiculoAno_Exibicao,
    NotaFiscal_Numero,
    p.Pessoa_Nome,
    ve.Veiculo_Placa,
    usuario.Usuario_Nome,
    prop.Proposta_Codigo,
    nf.NotaFiscal_EmpresaCod;", banco.oCon2);

            cmd.CommandType = CommandType.Text;
            cmd.Parameters.Add("@pedido", SqlDbType.VarChar, 12).Value = pedido;
            cmd.Parameters.Add("@loja", SqlDbType.VarChar, 3).Value = loja;

            DataTable tabela = new DataTable();
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            adapter.Fill(tabela);
            return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private void Avisar(string mensagem, string tipo)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), Guid.NewGuid().ToString("N"),
            "if (window.baliUtilityFeedback) { window.baliUtilityFeedback('" + mensagem.Replace("'", "\\'") + "', '" + tipo + "'); } else { alert('" + mensagem.Replace("'", "\\'") + "'); }", true);
    }

    private void CarregarBI(bool avisarErro)
    {
        try
        {
            DateTime inicio = DataInformada(txtBIDataInicial.Text, PrimeiroDiaMes());
            DateTime fim = DataInformada(txtBIDataFinal.Text, DateTime.Today);
            if (fim < inicio)
            {
                DateTime troca = inicio;
                inicio = fim;
                fim = troca;
            }

            txtBIDataInicial.Text = inicio.ToString("dd/MM/yyyy");
            txtBIDataFinal.Text = fim.ToString("dd/MM/yyyy");

            DataTable resumo = PolimentoAutorizacao.ResumoPorCor(MarcaPolimento, inicio, fim);
            DataTable detalhes = PolimentoAutorizacao.Detalhes(MarcaPolimento, inicio, fim);

            gvPolimentoResumo.DataSource = resumo;
            gvPolimentoResumo.DataBind();
            gvPolimentoDetalhes.DataSource = detalhes;
            gvPolimentoDetalhes.DataBind();

            lblBITotal.Text = PolimentoAutorizacao.Total(resumo).ToString("N0", new CultureInfo("pt-BR"));
            lblBICores.Text = ContarCores(resumo).ToString("N0", new CultureInfo("pt-BR"));
            lblBITopCor.Text = PolimentoAutorizacao.TopCor(resumo);
        }
        catch
        {
            lblBITotal.Text = "0";
            lblBICores.Text = "0";
            lblBITopCor.Text = "-";
            gvPolimentoResumo.DataSource = null;
            gvPolimentoResumo.DataBind();
            gvPolimentoDetalhes.DataSource = null;
            gvPolimentoDetalhes.DataBind();
            if (avisarErro) Avisar("Não foi possível carregar os dados de polimento agora.", "error");
        }
    }

    private int ContarCores(DataTable resumo)
    {
        DataTable cores = resumo == null ? null : resumo.DefaultView.ToTable(true, "Cor");
        return cores == null ? 0 : cores.Rows.Count;
    }

    private DateTime PrimeiroDiaMes()
    {
        DateTime hoje = DateTime.Today;
        return new DateTime(hoje.Year, hoje.Month, 1);
    }

    private DateTime DataInformada(string valor, DateTime padrao)
    {
        DateTime data;
        string texto = (valor ?? "").Trim();
        string[] formatos = { "dd/MM/yyyy", "d/M/yyyy", "yyyy-MM-dd" };
        if (DateTime.TryParseExact(texto, formatos, new CultureInfo("pt-BR"), DateTimeStyles.None, out data)) return data;
        if (DateTime.TryParse(texto, new CultureInfo("pt-BR"), DateTimeStyles.None, out data)) return data;
        return padrao;
    }

    private string SomenteNumeros(string valor, int maximo)
    {
        string entrada = valor ?? "";
        string retorno = "";
        foreach (char c in entrada)
        {
            if (Char.IsDigit(c)) retorno += c;
        }
        if (retorno.Length > maximo) retorno = retorno.Substring(0, maximo);
        return retorno;
    }

    private string Valor(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value) return "";
        return Convert.ToString(row[coluna]).Trim();
    }

    private string ValorMoeda(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value) return "R$ 0,00";
        decimal valor;
        if (!Decimal.TryParse(Convert.ToString(row[coluna]), out valor)) valor = 0;
        return valor.ToString("C", new CultureInfo("pt-BR"));
    }

    private string TextoOuTraco(string valor)
    {
        return String.IsNullOrWhiteSpace(valor) ? "-" : valor;
    }

    private string DataExtenso(DateTime data)
    {
        return "Brasília-DF, " + data.ToString("dd 'de' MMMM 'de' yyyy", new CultureInfo("pt-BR")) + ".";
    }
}
