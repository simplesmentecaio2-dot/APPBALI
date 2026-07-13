using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

public abstract class PolimentoAvulsoBase : Page
{
    protected abstract string MarcaPolimento { get; }
    protected abstract string EmpresaDocumento { get; }
    protected abstract string LoginRetorno { get; }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["usuario"] == null || String.IsNullOrWhiteSpace(Convert.ToString(Session["usuario"])))
        {
            Response.Redirect(LoginRetorno);
            return;
        }

        Label("lblUsuario").Text = Convert.ToString(Session["usuario"]);
        Label("lblTipo").Text = Session["usuario_codigo"] == null ? "-" : Convert.ToString(Session["usuario_codigo"]);

        if (!IsPostBack)
        {
            Label("lblEmpresa").Text = EmpresaDocumento;
            Label("lblEmpresaAssinatura").Text = EmpresaDocumento;
            Label("lblData").Text = DataExtenso(DateTime.Today);
            Label("lblTipoPolimento").Text = TipoPolimentoSelecionado();
            TextBox("txtBIDataInicial").Text = PrimeiroDiaMes().ToString("dd/MM/yyyy");
            TextBox("txtBIDataFinal").Text = DateTime.Today.ToString("dd/MM/yyyy");
            CarregarBI(false);
        }
    }

    protected void btnGerar_Click(object sender, EventArgs e)
    {
        string busca = NormalizarBusca(TextBox("txtBusca").Text);
        TextBox("txtBusca").Text = busca;
        string tipoPolimento = TipoPolimentoSelecionado();

        if (!BuscaValida(busca))
        {
            Avisar("Informe uma placa ou chassi válido para gerar a autorização.", "error");
            return;
        }

        try
        {
            DataRow dados = ConsultarVeiculo(busca);
            if (dados == null)
            {
                Avisar("Nenhum veículo encontrado no estoque para a placa ou chassi informado.", "error");
                return;
            }

            string lojaCodigo = TextoOuTraco(Valor(dados, "Loja_Codigo"));
            string pedidoLog = "AVULSO-" + DateTime.Now.ToString("yyyyMMddHHmmss", CultureInfo.InvariantCulture);

            Label("lblPedidoPrint").Text = "AVULSO";
            Label("lblOrigemPrint").Text = busca;
            Label("lblCliente").Text = TextoOuTraco(Valor(dados, "Cliente"));
            Label("lblVeiculo").Text = TextoOuTraco(Valor(dados, "Veiculo"));
            Label("lblChassi").Text = TextoOuTraco(Valor(dados, "Chassi"));
            Label("lblCor").Text = TextoOuTraco(Valor(dados, "Cor"));
            Label("lblAno").Text = TextoOuTraco(Valor(dados, "Ano / Modelo"));
            Label("lblNota").Text = TextoOuTraco(Valor(dados, "Nota Fiscal"));
            Label("lblPlaca").Text = TextoOuTraco(Valor(dados, "Placa"));
            Label("lblVendedor").Text = TextoOuTraco(Valor(dados, "Vendedor"));
            Label("lblProposta").Text = TextoOuTraco(Valor(dados, "Proposta_Codigo"));
            Label("lblUnidade").Text = TextoOuTraco(Valor(dados, "Unidade"));
            Label("lblEstoque").Text = TextoOuTraco(Valor(dados, "Estoque"));
            Label("lblUnidadeAssinatura").Text = TextoOuTraco(Valor(dados, "Unidade"));
            Label("lblValor").Text = ValorMoeda(dados, "Valor");
            Label("lblEmpresa").Text = EmpresaDocumento;
            Label("lblEmpresaAssinatura").Text = EmpresaDocumento;
            Label("lblData").Text = DataExtenso(DateTime.Today);
            Label("lblTipoPolimento").Text = tipoPolimento;

            bool registrado = PolimentoAutorizacao.RegistrarGeracao(MarcaPolimento, pedidoLog, lojaCodigo, tipoPolimento, dados, Context);
            CarregarBI(false);
            if (!registrado)
            {
                Avisar("Autorização gerada, mas não foi possível registrar nos dados gerenciais agora.", "error");
            }
        }
        catch
        {
            Avisar("Não foi possível gerar a autorização agora. Confira a placa ou o chassi e tente novamente.", "error");
        }
    }

    protected void btnAtualizarBI_Click(object sender, EventArgs e)
    {
        Hidden("hdnPolimentoTab").Value = "dados";
        CarregarBI(true);
        ScriptManager.RegisterStartupScript(this, GetType(), "polimentoDados", "window.abrirPolimentoTab && window.abrirPolimentoTab('dados');", true);
    }

    private DataRow ConsultarVeiculo(string buscaNormalizada)
    {
        string connectionString = ConfigurationManager.ConnectionStrings["GrupoBali_DealernetWFConnectionString"].ConnectionString;
        using (SqlConnection connection = new SqlConnection(connectionString))
        using (SqlCommand command = new SqlCommand(QueryVeiculo(), connection))
        using (SqlDataAdapter adapter = new SqlDataAdapter(command))
        {
            command.CommandType = CommandType.Text;
            command.CommandTimeout = 60;
            command.Parameters.Add("@busca", SqlDbType.VarChar, 40).Value = buscaNormalizada;

            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
        }
    }

    private string QueryVeiculo()
    {
        return @"
SELECT TOP 1
    CASE VecEst.VeiculoEstoque_EmpresaCod
        WHEN '01' THEN 'JEEP SAAN'
        WHEN '02' THEN 'PARK SUL'
        WHEN '03' THEN 'BALI BYD'
        WHEN '04' THEN 'RAM'
        WHEN '05' THEN 'FIAT SIA'
        WHEN '06' THEN 'FIAT SCIA'
        WHEN '07' THEN 'FIAT SAAN'
        ELSE 'LOJA ' + CONVERT(varchar(10), VecEst.VeiculoEstoque_EmpresaCod)
    END AS [Unidade],
    VecEst.VeiculoEstoque_EmpresaCod AS [Loja_Codigo],
    dbo.Estoque.Estoque_Descricao AS [Estoque],
    COALESCE(NULLIF(LTRIM(RTRIM(ISNULL(Marca.Marca_Descricao, '') + ' ' + ISNULL(ModeloVeiculo.ModeloVeiculo_Descricao, ''))), ''), NULLIF(Veiculo.Veiculo_Descricao, ''), 'VEICULO') AS [Veiculo],
    Veiculo.Veiculo_Chassi AS [Chassi],
    ISNULL(Veiculo.Veiculo_Placa, '') AS [Placa],
    Cor.Cor_Descricao AS [Cor],
    VeiculoAno.VeiculoAno_Exibicao AS [Ano / Modelo],
    COALESCE(CONVERT(varchar(30), Venda.NotaFiscal_Numero), CONVERT(varchar(30), NFCompra.NotaFiscal_Numero), '') AS [Nota Fiscal],
    ISNULL(Venda.Cliente, '') AS [Cliente],
    ISNULL(Venda.Vendedor, '') AS [Vendedor],
    ISNULL(CONVERT(varchar(40), Venda.Proposta_Codigo), '') AS [Proposta_Codigo],
    COALESCE(PrecoUsado.VeiculoPrecoUsado_ValorVenda, PrecoEmpresa.ModeloVeiculoPrecoEmpresa_ValorVenda, PrecoGeral.ModeloVeiculoPreco_ValorVenda, 0) AS [Valor]
FROM dbo.fn_EstoqueVeiculos(GETDATE()) VecEst
JOIN dbo.Estoque
    ON dbo.Estoque.Estoque_Codigo = VecEst.VeiculoEstoque_EstoqueCod
JOIN dbo.Veiculo
    ON dbo.Veiculo.Veiculo_Codigo = VecEst.VeiculoEstoque_VeiculoCod
JOIN dbo.Cor
    ON dbo.Cor.Cor_Codigo = dbo.Veiculo.Veiculo_CorCodExterna
JOIN dbo.FamiliaVeiculo
    ON dbo.FamiliaVeiculo.FamiliaVeiculo_Codigo = VecEst.VeiculoEstoque_FamiliaVeiculoCod
JOIN dbo.ModeloVeiculo
    ON dbo.ModeloVeiculo.ModeloVeiculo_Codigo = dbo.Veiculo.Veiculo_ModeloVeiculoCod
JOIN dbo.VeiculoAno
    ON dbo.VeiculoAno.VeiculoAno_Codigo = dbo.Veiculo.VeiculoAno_Codigo
JOIN dbo.Marca
    ON dbo.Marca.Marca_Codigo = dbo.ModeloVeiculo.ModeloVeiculo_MarcaCod
JOIN dbo.NotaFiscalItem NFICompra
    ON NFICompra.NotaFiscal_Codigo = VecEst.VeiculoEstoque_NotaFiscalCodCompra
   AND NFICompra.NotaFiscalItem_VeiculoCod = VecEst.VeiculoEstoque_VeiculoCod
JOIN dbo.NotaFiscal NFCompra
    ON NFCompra.NotaFiscal_Codigo = NFICompra.NotaFiscal_Codigo
OUTER APPLY (
    SELECT TOP 1
        nf.NotaFiscal_Numero,
        p.Pessoa_Nome AS Cliente,
        usuario.Usuario_Nome AS Vendedor,
        prop.Proposta_Codigo
    FROM dbo.Proposta prop WITH (NOLOCK)
    INNER JOIN dbo.NotaFiscal nf WITH (NOLOCK)
        ON nf.NotaFiscal_Codigo = prop.Proposta_NotaFiscalCod
    LEFT JOIN dbo.Pessoa p WITH (NOLOCK)
        ON p.Pessoa_Codigo = nf.NotaFiscal_PessoaCod
    LEFT JOIN dbo.Atendimento atend WITH (NOLOCK)
        ON atend.Atendimento_Codigo = prop.Atendimento_Codigo
    LEFT JOIN dbo.Usuario usuario WITH (NOLOCK)
        ON usuario.Usuario_Codigo = atend.Atendimento_UsuarioCod
    WHERE prop.Proposta_VeiculoCod = dbo.Veiculo.Veiculo_Codigo
      AND nf.NotaFiscal_Status = 'emi'
    ORDER BY nf.NotaFiscal_DataEmissao DESC, prop.Proposta_Codigo DESC
) Venda
OUTER APPLY (
    SELECT TOP 1
        VPU.VeiculoPrecoUsado_ValorVenda
    FROM dbo.VeiculoPrecoUsado VPU WITH (NOLOCK)
    WHERE VPU.Veiculo_Codigo = dbo.Veiculo.Veiculo_Codigo
      AND VPU.VeiculoPrecoUsado_Status = 'AUT'
      AND VPU.VeiculoPrecoUsado_DataVigencia <= GETDATE()
      AND VPU.VeiculoPrecoUsado_ValorVenda <> 0
    ORDER BY VPU.VeiculoPrecoUsado_DataVigencia DESC
) PrecoUsado
OUTER APPLY (
    SELECT TOP 1
        MVPE.ModeloVeiculoPrecoEmpresa_ValorVenda
    FROM dbo.ModeloVeiculoPrecoEmpresa MVPE WITH (NOLOCK)
    WHERE MVPE.ModeloVeiculo_Codigo = dbo.Veiculo.Veiculo_ModeloVeiculoCod
      AND MVPE.ModeloVeiculoPrecoEmpresa_EmpresaCod = VecEst.VeiculoEstoque_EmpresaCod
      AND MVPE.ModeloVeiculoPrecoEmpresa_AnoModelo = VeiculoAno.VeiculoAno_Modelo
      AND MVPE.ModeloVeiculoPrecoEmpresa_Data <= GETDATE()
      AND MVPE.ModeloVeiculoPrecoEmpresa_ValorVenda <> 0
    ORDER BY MVPE.ModeloVeiculoPrecoEmpresa_Data DESC
) PrecoEmpresa
OUTER APPLY (
    SELECT TOP 1
        MVP.ModeloVeiculoPreco_ValorVenda
    FROM dbo.ModeloVeiculoPreco MVP WITH (NOLOCK)
    WHERE MVP.ModeloVeiculo_Codigo = dbo.Veiculo.Veiculo_ModeloVeiculoCod
      AND MVP.ModeloVeiculoPreco_AnoModelo = VeiculoAno.VeiculoAno_Modelo
      AND MVP.ModeloVeiculoPreco_Data <= GETDATE()
      AND MVP.ModeloVeiculoPreco_ValorVenda <> 0
    ORDER BY MVP.ModeloVeiculoPreco_Data DESC
) PrecoGeral
WHERE VecEst.Transito = 0
  AND (
        UPPER(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(Veiculo.Veiculo_Chassi, ''), ' ', ''), '-', ''), '.', ''), '/', '')) = @busca
        OR UPPER(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(Veiculo.Veiculo_Placa, ''), ' ', ''), '-', ''), '.', ''), '/', '')) = @busca
      )
ORDER BY VecEst.VeiculoEstoque_EmpresaCod, dbo.Veiculo.Veiculo_Codigo DESC;";
    }

    private void CarregarBI(bool avisarErro)
    {
        try
        {
            DateTime inicio = DataInformada(TextBox("txtBIDataInicial").Text, PrimeiroDiaMes());
            DateTime fim = DataInformada(TextBox("txtBIDataFinal").Text, DateTime.Today);
            if (fim < inicio)
            {
                DateTime troca = inicio;
                inicio = fim;
                fim = troca;
            }

            TextBox("txtBIDataInicial").Text = inicio.ToString("dd/MM/yyyy");
            TextBox("txtBIDataFinal").Text = fim.ToString("dd/MM/yyyy");

            DataTable resumo = PolimentoAutorizacao.ResumoPorCor(MarcaPolimento, inicio, fim);
            DataTable detalhes = PolimentoAutorizacao.Detalhes(MarcaPolimento, inicio, fim);

            GridView("gvPolimentoResumo").DataSource = resumo;
            GridView("gvPolimentoResumo").DataBind();
            GridView("gvPolimentoDetalhes").DataSource = detalhes;
            GridView("gvPolimentoDetalhes").DataBind();

            Label("lblBITotal").Text = PolimentoAutorizacao.Total(resumo).ToString("N0", new CultureInfo("pt-BR"));
            Label("lblBICores").Text = ContarCores(resumo).ToString("N0", new CultureInfo("pt-BR"));
            Label("lblBITopCor").Text = PolimentoAutorizacao.TopCor(resumo);
        }
        catch
        {
            Label("lblBITotal").Text = "0";
            Label("lblBICores").Text = "0";
            Label("lblBITopCor").Text = "-";
            GridView("gvPolimentoResumo").DataSource = null;
            GridView("gvPolimentoResumo").DataBind();
            GridView("gvPolimentoDetalhes").DataSource = null;
            GridView("gvPolimentoDetalhes").DataBind();
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

    private string TipoPolimentoSelecionado()
    {
        DropDownList ddl = DropDown("ddlTipoPolimento");
        string tipo = ddl == null ? "" : (ddl.SelectedValue ?? "").Trim();
        if (tipo.Equals("Polimento do Black Piano", StringComparison.OrdinalIgnoreCase)) return "Polimento do Black Piano";
        return "Polimento completo do veículo";
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
        if (!Decimal.TryParse(Convert.ToString(row[coluna]), NumberStyles.Any, CultureInfo.InvariantCulture, out valor) &&
            !Decimal.TryParse(Convert.ToString(row[coluna]), NumberStyles.Any, new CultureInfo("pt-BR"), out valor))
        {
            valor = 0;
        }
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

    private string NormalizarBusca(string valor)
    {
        StringBuilder texto = new StringBuilder();
        foreach (char caractere in (valor ?? "").ToUpperInvariant())
        {
            if (Char.IsLetterOrDigit(caractere)) texto.Append(caractere);
        }
        return texto.ToString();
    }

    private bool BuscaValida(string busca)
    {
        return busca.Length == 7 || busca.Length == 17;
    }

    private void Avisar(string mensagem, string tipo)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"),
            "if (window.baliUtilityFeedback) { window.baliUtilityFeedback('" + mensagem.Replace("'", "\\'") + "', '" + tipo + "'); } else { alert('" + mensagem.Replace("'", "\\'") + "'); }", true);
    }

    private Label Label(string id)
    {
        return (Label)Controle(id);
    }

    private TextBox TextBox(string id)
    {
        return (TextBox)Controle(id);
    }

    private HiddenField Hidden(string id)
    {
        return (HiddenField)Controle(id);
    }

    private GridView GridView(string id)
    {
        return (GridView)Controle(id);
    }

    private DropDownList DropDown(string id)
    {
        return Controle(id) as DropDownList;
    }

    private Control Controle(string id)
    {
        Control controle = FindControl(id);
        if (controle != null) return controle;
        controle = BuscarControleRecursivo(this, id);
        if (controle == null) throw new InvalidOperationException("Controle não encontrado: " + id);
        return controle;
    }

    private Control BuscarControleRecursivo(Control raiz, string id)
    {
        if (raiz == null) return null;
        if (raiz.ID == id) return raiz;
        foreach (Control filho in raiz.Controls)
        {
            Control encontrado = BuscarControleRecursivo(filho, id);
            if (encontrado != null) return encontrado;
        }
        return null;
    }
}
