using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.Caching;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

public partial class minhas_vendas : System.Web.UI.Page
{
    private readonly CultureInfo ptBr = new CultureInfo("pt-BR");
    private const string DealernetConnectionString = "Data Source=129.13.144.8\\wf;Initial Catalog=GrupoBali_DealernetWF;User ID=caio;Password=D6d3h7g711;Connect Timeout=30;";
    private const int DiasMaximosPeriodoBI = 32;
    private const int MinhasVendasCacheMinutos = 3;

    private string marcaAtual = "fiat";

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();

        marcaAtual = NormalizarMarca(Request.QueryString["marca"]);
        AplicarMarca();

        if (!UsuarioLogado())
        {
            Response.Redirect(UrlLogin(marcaAtual), true);
            return;
        }

        lblUsuario.Text = Convert.ToString(Session["usuario"]);

        int codigoUsuario = ObterCodigoUsuarioLogado();
        lblCodigoVendedor.Text = codigoUsuario > 0 ? codigoUsuario.ToString(ptBr) : "-";

        if (codigoUsuario <= 0)
        {
            ExibirAviso("N\u00e3o foi poss\u00edvel identificar o c\u00f3digo do vendedor na sess\u00e3o. Saia do sistema e entre novamente para atualizar o acesso.");
            pnlConteudo.Visible = false;
            return;
        }

        if (!IsPostBack)
        {
            DefinirPeriodoMesAtual();
            CarregarDados();
        }
    }

    protected void btnFiltrar_Click(object sender, EventArgs e)
    {
        CarregarDados();
    }

    protected void btnExportarExcel_Click(object sender, EventArgs e)
    {
        if (!UsuarioLogado())
        {
            Response.Redirect(UrlLogin(marcaAtual), true);
            return;
        }

        DateTime dataInicial;
        DateTime dataFinal;
        if (!TentarLerPeriodo(out dataInicial, out dataFinal))
        {
            pnlConteudo.Visible = false;
            return;
        }

        int codigoUsuario = ObterCodigoUsuarioLogado();
        if (codigoUsuario <= 0)
        {
            ExibirAviso("Sess\u00e3o sem c\u00f3digo de vendedor. Entre novamente para exportar suas vendas.");
            pnlConteudo.Visible = false;
            return;
        }

        try
        {
            string tipoFiltro = ObterTipoFiltroSelecionado();
            string lojaFiltro = ObterLojaFiltroSelecionada();
            DataTable vendas = ConsultarVendasComCache(dataInicial, dataFinal, codigoUsuario, tipoFiltro, lojaFiltro);
            RegistrarAuditoria("exportacao-excel", dataInicial, dataFinal, codigoUsuario, tipoFiltro, lojaFiltro, vendas.Rows.Count);
            ExportarExcel(vendas, dataInicial, dataFinal, tipoFiltro, lojaFiltro);
        }
        catch (System.Threading.ThreadAbortException)
        {
            throw;
        }
        catch (Exception ex)
        {
            ExibirAviso("N\u00e3o foi poss\u00edvel exportar suas vendas agora. Tente novamente em alguns instantes.");
            RegistrarErro("exportar-minhas-vendas", ex);
        }
    }

    protected void PeriodoRapido_Command(object sender, CommandEventArgs e)
    {
        string comando = Convert.ToString(e.CommandArgument);
        DateTime hoje = DateTime.Today;

        if (comando == "hoje")
        {
            txtDataInicial.Text = hoje.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            txtDataFinal.Text = hoje.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        }
        else if (comando == "ultimos30")
        {
            txtDataInicial.Text = hoje.AddDays(-29).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            txtDataFinal.Text = hoje.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        }
        else if (comando == "ultimos7")
        {
            txtDataInicial.Text = hoje.AddDays(-6).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            txtDataFinal.Text = hoje.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        }
        else if (comando == "mesAnterior")
        {
            DateTime primeiroMesAtual = new DateTime(hoje.Year, hoje.Month, 1);
            DateTime primeiroMesAnterior = primeiroMesAtual.AddMonths(-1);
            txtDataInicial.Text = primeiroMesAnterior.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            txtDataFinal.Text = primeiroMesAtual.AddDays(-1).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        }
        else
        {
            DefinirPeriodoMesAtual();
        }

        CarregarDados();
    }

    protected void gvVendas_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow)
        {
            return;
        }

        decimal qtde = ToDecimal(DataBinder.Eval(e.Row.DataItem, "qtde"));
        if (qtde < 0)
        {
            AdicionarClasseLinha(e.Row, "sales-return-row");
        }

        decimal margem = ToDecimal(DataBinder.Eval(e.Row.DataItem, "Margem"));
        if (qtde > 0 && margem > 0 && margem < 8)
        {
            AdicionarClasseLinha(e.Row, "sales-low-margin-row");
        }
        else if (qtde > 0 && margem >= 15)
        {
            AdicionarClasseLinha(e.Row, "sales-high-margin-row");
        }
    }

    private void AdicionarClasseLinha(TableRow linha, string classe)
    {
        if (String.IsNullOrWhiteSpace(linha.CssClass))
        {
            linha.CssClass = classe;
        }
        else if ((" " + linha.CssClass + " ").IndexOf(" " + classe + " ", StringComparison.Ordinal) < 0)
        {
            linha.CssClass += " " + classe;
        }
    }

    private void CarregarDados()
    {
        pnlAviso.Visible = false;
        pnlConteudo.Visible = true;

        DateTime dataInicial;
        DateTime dataFinal;
        if (!TentarLerPeriodo(out dataInicial, out dataFinal))
        {
            pnlConteudo.Visible = false;
            return;
        }

        int codigoUsuario = ObterCodigoUsuarioLogado();
        if (codigoUsuario <= 0)
        {
            ExibirAviso("Sess\u00e3o sem c\u00f3digo de vendedor. Entre novamente para consultar suas vendas.");
            pnlConteudo.Visible = false;
            return;
        }

        try
        {
            string tipoFiltro = ObterTipoFiltroSelecionado();
            string lojaFiltro = ObterLojaFiltroSelecionada();
            DataTable vendasBase = ConsultarVendasComCache(dataInicial, dataFinal, codigoUsuario, tipoFiltro, "");
            PreencherFiltroLojas(vendasBase, lojaFiltro);
            DataTable vendas = FiltrarVendasPorLoja(vendasBase, lojaFiltro);
            DateTime dataInicialAnterior;
            DateTime dataFinalAnterior;
            ObterPeriodoAnterior(dataInicial, dataFinal, out dataInicialAnterior, out dataFinalAnterior);
            DataTable vendasPeriodoAnterior = ConsultarVendasComCache(dataInicialAnterior, dataFinalAnterior, codigoUsuario, tipoFiltro, lojaFiltro);
            DataTable ranking = ConsultarRankingComCache(dataInicial, dataFinal, tipoFiltro, lojaFiltro);

            PreencherResumo(vendas, dataInicial, dataFinal, tipoFiltro, lojaFiltro);
            PreencherComparativo(vendas, vendasPeriodoAnterior, dataInicialAnterior, dataFinalAnterior);
            PreencherInteligencia(vendas, ranking, dataInicial, dataFinal, codigoUsuario);
            PreencherGraficos(vendas, dataInicial, dataFinal);
            PreencherTabela(vendas);
            RegistrarAuditoria("consulta", dataInicial, dataFinal, codigoUsuario, tipoFiltro, lojaFiltro, vendas.Rows.Count);
        }
        catch (Exception ex)
        {
            pnlConteudo.Visible = false;
            ExibirAviso("N\u00e3o foi poss\u00edvel carregar suas vendas agora. Tente novamente em alguns instantes ou reduza o per\u00edodo pesquisado.");
            RegistrarErro("minhas-vendas", ex);
        }
    }

    private DataTable ConsultarVendasComCache(DateTime dataInicial, DateTime dataFinal, int codigoUsuario, string tipoFiltro, string lojaFiltro)
    {
        string chave = String.Format(
            CultureInfo.InvariantCulture,
            "minhas-vendas:{0}:{1:yyyyMMdd}:{2:yyyyMMdd}:{3}:{4}:{5}",
            marcaAtual,
            dataInicial.Date,
            dataFinal.Date,
            codigoUsuario,
            NormalizarTipoFiltro(tipoFiltro),
            NormalizarTextoFiltro(lojaFiltro));

        DataTable cached = HttpRuntime.Cache[chave] as DataTable;
        if (cached != null)
        {
            return cached.Copy();
        }

        DataTable tabela = ConsultarVendas(dataInicial, dataFinal, codigoUsuario, tipoFiltro, lojaFiltro);
        HttpRuntime.Cache.Insert(
            chave,
            tabela.Copy(),
            null,
            DateTime.Now.AddMinutes(MinhasVendasCacheMinutos),
            Cache.NoSlidingExpiration,
            CacheItemPriority.Normal,
            null);

        return tabela;
    }

    private DataTable ConsultarVendas(DateTime dataInicial, DateTime dataFinal, int codigoUsuario, string tipoFiltro, string lojaFiltro)
    {
        DataTable tabela = new DataTable();

        using (SqlConnection conexao = new SqlConnection(DealernetConnectionString))
        using (SqlCommand comando = conexao.CreateCommand())
        {
            comando.CommandTimeout = 45;
            comando.CommandText = @"
SELECT
    CASE v.notafiscal_grupomovimento
        WHEN 'VEN' THEN 1
        WHEN 'DVE' THEN -1
    END AS qtde,
    CASE
        WHEN v.notafiscal_grupomovimento = 'DVE' THEN (-Valor_Venda)
        WHEN v.notafiscal_grupomovimento = 'VEN' THEN (Valor_Venda)
    END AS ValordeVenda,
    (ISNULL(v.NotaFiscalItem_ValorLucroBruto, 0) * 100 / NULLIF(v.Valor_venda, 0)) AS Margem,
    NotaFiscal_EmpresaNom AS loja,
    notafiscal_numero AS notafiscal,
    Proposta_Pedido AS pedidodoveiculo,
    notafiscal_dataemissao AS datavenda,
    notafiscal_estoquetipo AS tipoestoque,
    notafiscal_estoquedes AS estoqueveiculo,
    Notafiscal_usunomvendedor AS vendedor,
    NotaFiscal_UsuCodVendedor AS codigo,
    veiculo_codigo AS codigoveiculo,
    Veiculo_chassi AS chassi,
    veiculo_placaUF AS placa,
    veiculomarca_descricao AS marcaveiculo,
    VeiculoFamiliaVeiculo_Descricao AS familiaveiculo,
    veiculomodeloveiculo_descricao AS modeloveiculo,
    veiculocor_descricao AS corveiculo,
    veiculo_diasemestoque AS diasdeestoque,
    p.Pessoa_telefone AS TelefoneCliente,
    NotaFiscal_PessoaCod AS CodigoPessoa,
    NotaFiscal_PessoaNom AS NomeCliente,
    pessoa_email AS emailcliente,
    NotaFiscal_Pessoa_DocIdentificador AS CPFCliente,
    CASE NotaFiscal_PessoaTipo
        WHEN 'J' THEN N'Jur' + NCHAR(237) + N'dica'
        WHEN 'F' THEN N'F' + NCHAR(237) + N'sica'
    END AS Tipopessoa
FROM VendasVeiculos v
INNER JOIN Pessoa p ON p.Pessoa_Codigo = v.NotaFiscal_PessoaCod
INNER JOIN usuario u ON u.usuario_codigo = v.NotaFiscal_UsuCodVendedor
WHERE v.NotaFiscal_DataEmissao >= @datainicial
  AND v.NotaFiscal_DataEmissao < DATEADD(DAY, 1, @datafinal)
  AND v.NotaFiscal_UsuCodVendedor = @codigo_usuario
  AND (@tipo_estoque = '' OR UPPER(LTRIM(RTRIM(ISNULL(v.notafiscal_estoquetipo, '')))) = @tipo_estoque)
  AND (@loja = '' OR UPPER(LTRIM(RTRIM(ISNULL(v.NotaFiscal_EmpresaNom, '')))) = @loja)
ORDER BY notafiscal_dataemissao DESC, notafiscal_numero DESC;";
            comando.Parameters.Add("@datainicial", SqlDbType.DateTime).Value = dataInicial.Date;
            comando.Parameters.Add("@datafinal", SqlDbType.DateTime).Value = dataFinal.Date;
            comando.Parameters.Add("@codigo_usuario", SqlDbType.Int).Value = codigoUsuario;
            comando.Parameters.Add("@tipo_estoque", SqlDbType.VarChar, 12).Value = NormalizarTipoFiltro(tipoFiltro);
            comando.Parameters.Add("@loja", SqlDbType.VarChar, 120).Value = NormalizarTextoFiltro(lojaFiltro);

            using (SqlDataAdapter adaptador = new SqlDataAdapter(comando))
            {
                adaptador.Fill(tabela);
            }
        }

        return tabela;
    }

    private DataTable ConsultarRankingComCache(DateTime dataInicial, DateTime dataFinal, string tipoFiltro, string lojaFiltro)
    {
        string chave = String.Format(
            CultureInfo.InvariantCulture,
            "minhas-vendas-ranking:{0}:{1:yyyyMMdd}:{2:yyyyMMdd}:{3}:{4}",
            marcaAtual,
            dataInicial.Date,
            dataFinal.Date,
            NormalizarTipoFiltro(tipoFiltro),
            NormalizarTextoFiltro(lojaFiltro));

        DataTable cached = HttpRuntime.Cache[chave] as DataTable;
        if (cached != null)
        {
            return cached.Copy();
        }

        DataTable tabela = ConsultarRanking(dataInicial, dataFinal, tipoFiltro, lojaFiltro);
        HttpRuntime.Cache.Insert(
            chave,
            tabela.Copy(),
            null,
            DateTime.Now.AddMinutes(MinhasVendasCacheMinutos),
            Cache.NoSlidingExpiration,
            CacheItemPriority.Normal,
            null);

        return tabela;
    }

    private DataTable ConsultarRanking(DateTime dataInicial, DateTime dataFinal, string tipoFiltro, string lojaFiltro)
    {
        DataTable tabela = new DataTable();

        using (SqlConnection conexao = new SqlConnection(DealernetConnectionString))
        using (SqlCommand comando = conexao.CreateCommand())
        {
            comando.CommandTimeout = 45;
            comando.CommandText = @"
SELECT TOP 50
    NotaFiscal_UsuCodVendedor AS codigo,
    MAX(Notafiscal_usunomvendedor) AS vendedor,
    SUM(CASE v.notafiscal_grupomovimento WHEN 'VEN' THEN 1 WHEN 'DVE' THEN -1 ELSE 0 END) AS unidades,
    SUM(CASE WHEN v.notafiscal_grupomovimento = 'DVE' THEN (-Valor_Venda) WHEN v.notafiscal_grupomovimento = 'VEN' THEN Valor_Venda ELSE 0 END) AS valor
FROM VendasVeiculos v
WHERE v.NotaFiscal_DataEmissao >= @datainicial
  AND v.NotaFiscal_DataEmissao < DATEADD(DAY, 1, @datafinal)
  AND (@tipo_estoque = '' OR UPPER(LTRIM(RTRIM(ISNULL(v.notafiscal_estoquetipo, '')))) = @tipo_estoque)
  AND (@loja = '' OR UPPER(LTRIM(RTRIM(ISNULL(v.NotaFiscal_EmpresaNom, '')))) = @loja)
  AND ISNULL(NotaFiscal_UsuCodVendedor, 0) > 0
GROUP BY NotaFiscal_UsuCodVendedor
ORDER BY unidades DESC, valor DESC;";
            comando.Parameters.Add("@datainicial", SqlDbType.DateTime).Value = dataInicial.Date;
            comando.Parameters.Add("@datafinal", SqlDbType.DateTime).Value = dataFinal.Date;
            comando.Parameters.Add("@tipo_estoque", SqlDbType.VarChar, 12).Value = NormalizarTipoFiltro(tipoFiltro);
            comando.Parameters.Add("@loja", SqlDbType.VarChar, 120).Value = NormalizarTextoFiltro(lojaFiltro);

            using (SqlDataAdapter adaptador = new SqlDataAdapter(comando))
            {
                adaptador.Fill(tabela);
            }
        }

        return tabela;
    }

    private DataTable FiltrarVendasPorLoja(DataTable vendas, string lojaFiltro)
    {
        string lojaNormalizada = NormalizarTextoFiltro(lojaFiltro);
        if (String.IsNullOrEmpty(lojaNormalizada))
        {
            return vendas.Copy();
        }

        DataTable filtrada = vendas.Clone();
        for (int i = 0; i < vendas.Rows.Count; i++)
        {
            string lojaLinha = NormalizarTextoFiltro(Convert.ToString(vendas.Rows[i]["loja"]));
            if (lojaLinha == lojaNormalizada)
            {
                filtrada.ImportRow(vendas.Rows[i]);
            }
        }

        return filtrada;
    }

    private void PreencherFiltroLojas(DataTable vendas, string lojaSelecionada)
    {
        string lojaSelecionadaNormalizada = NormalizarTextoFiltro(lojaSelecionada);
        Dictionary<string, string> lojas = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        for (int i = 0; i < vendas.Rows.Count; i++)
        {
            string loja = Convert.ToString(vendas.Rows[i]["loja"]).Trim();
            string chave = NormalizarTextoFiltro(loja);
            if (loja.Length > 0 && !lojas.ContainsKey(chave))
            {
                lojas[chave] = loja;
            }
        }

        ddlLojaFiltro.Items.Clear();
        ddlLojaFiltro.Items.Add(new ListItem("Todas as lojas", ""));

        List<string> chaves = new List<string>(lojas.Keys);
        chaves.Sort(delegate(string a, string b)
        {
            return String.Compare(lojas[a], lojas[b], true, ptBr);
        });

        bool selecionadaExiste = String.IsNullOrEmpty(lojaSelecionadaNormalizada);
        for (int i = 0; i < chaves.Count; i++)
        {
            ListItem item = new ListItem(lojas[chaves[i]], lojas[chaves[i]]);
            if (chaves[i] == lojaSelecionadaNormalizada)
            {
                item.Selected = true;
                selecionadaExiste = true;
            }
            ddlLojaFiltro.Items.Add(item);
        }

        if (!selecionadaExiste && lojaSelecionada.Length > 0)
        {
            ddlLojaFiltro.Items.Add(new ListItem(lojaSelecionada, lojaSelecionada) { Selected = true });
        }
    }

    private void PreencherResumo(DataTable vendas, DateTime dataInicial, DateTime dataFinal, string tipoFiltro, string lojaFiltro)
    {
        IndicadoresVendas indicadores = CalcularIndicadores(vendas);

        lblPeriodo.Text = String.Format(ptBr, "Per\u00edodo analisado: {0:dd/MM/yyyy} a {1:dd/MM/yyyy} | Tipo: {2} | Loja: {3}", dataInicial, dataFinal, DescreverTipoFiltro(tipoFiltro), DescreverLojaFiltro(lojaFiltro));
        lblTotalUnidades.Text = indicadores.UnidadesLiquidas.ToString("N0", ptBr);
        lblValorTotal.Text = indicadores.ValorLiquido.ToString("C0", ptBr);
        lblTicketMedio.Text = indicadores.TicketMedio.ToString("C0", ptBr);
        lblMargemMedia.Text = indicadores.MargemMedia.ToString("N1", ptBr) + "%";
        lblQtdNotas.Text = indicadores.Notas.ToString("N0", ptBr);
        lblDiasAtivos.Text = indicadores.DiasAtivos.ToString("N0", ptBr);
        lblVendasBrutas.Text = indicadores.VendasBrutas.ToString("N0", ptBr);
        lblDevolucoes.Text = indicadores.Devolucoes.ToString("N0", ptBr);
        lblClientesUnicos.Text = indicadores.ClientesUnicos.ToString("N0", ptBr);
        lblMelhorDia.Text = indicadores.TemMelhorDia ? String.Format(ptBr, "{0:dd/MM}", indicadores.MelhorDia) : "-";
        lblMaiorVenda.Text = indicadores.TemMaiorVenda ? indicadores.MaiorVenda.ToString("C0", ptBr) : "-";
        lblMaiorVendaDetalhe.Text = indicadores.TemMaiorVenda ? indicadores.MaiorVendaDetalhe : "Sem venda positiva no per\u00edodo";
    }

    private void PreencherComparativo(DataTable vendas, DataTable vendasPeriodoAnterior, DateTime dataInicialAnterior, DateTime dataFinalAnterior)
    {
        IndicadoresVendas atual = CalcularIndicadores(vendas);
        IndicadoresVendas anterior = CalcularIndicadores(vendasPeriodoAnterior);

        StringBuilder html = new StringBuilder();
        html.Append("<article class=\"sales-comparison-card sales-comparison-info\">");
        html.Append("<span>Comparativo</span>");
        html.Append("<strong>Per\u00edodo anterior</strong>");
        html.Append("<small>");
        html.Append(HttpUtility.HtmlEncode(String.Format(ptBr, "{0:dd/MM/yyyy} a {1:dd/MM/yyyy}", dataInicialAnterior, dataFinalAnterior)));
        html.Append("</small></article>");
        html.Append(RenderizarComparativo("Unidades", atual.UnidadesLiquidas, anterior.UnidadesLiquidas, "N0", ""));
        html.Append(RenderizarComparativo("Valor l\u00edquido", atual.ValorLiquido, anterior.ValorLiquido, "C0", ""));
        html.Append(RenderizarComparativo("Ticket m\u00e9dio", atual.TicketMedio, anterior.TicketMedio, "C0", ""));
        html.Append(RenderizarComparativo("Margem m\u00e9dia", atual.MargemMedia, anterior.MargemMedia, "N1", "%"));
        litComparativo.Text = html.ToString();
    }

    private void PreencherInteligencia(DataTable vendas, DataTable ranking, DateTime dataInicial, DateTime dataFinal, int codigoUsuario)
    {
        IndicadoresVendas indicadores = CalcularIndicadores(vendas);
        litMetaMensal.Text = RenderizarMetaMensal(indicadores, dataInicial, dataFinal);
        litRanking.Text = RenderizarRanking(ranking, codigoUsuario);
        litAlertas.Text = RenderizarAlertas(vendas, indicadores);
    }

    private string RenderizarMetaMensal(IndicadoresVendas indicadores, DateTime dataInicial, DateTime dataFinal)
    {
        int metaMesReferencia = ObterMetaReferenciaMensal();
        int diasPeriodo = (dataFinal.Date - dataInicial.Date).Days + 1;
        int diasMes = DateTime.DaysInMonth(dataInicial.Year, dataInicial.Month);
        decimal metaPeriodo = Math.Max(1, Math.Round(metaMesReferencia * (diasPeriodo / (decimal)diasMes), 0));
        decimal realizado = indicadores.VendasBrutas;
        decimal percentual = Math.Min(100, metaPeriodo == 0 ? 0 : (realizado / metaPeriodo) * 100);

        StringBuilder html = new StringBuilder();
        html.Append("<article class=\"sales-intelligence-card\"><span>Meta referencial</span><strong>");
        html.Append(HttpUtility.HtmlEncode(realizado.ToString("N0", ptBr)));
        html.Append(" / ");
        html.Append(HttpUtility.HtmlEncode(metaPeriodo.ToString("N0", ptBr)));
        html.Append("</strong><div class=\"sales-progress\"><i style=\"width:");
        html.Append(percentual.ToString("0.##", CultureInfo.InvariantCulture));
        html.Append("%\"></i></div><small>");
        html.Append(HttpUtility.HtmlEncode(percentual.ToString("N0", ptBr)));
        html.Append("% do ritmo esperado para o per\u00edodo</small></article>");
        return html.ToString();
    }

    private int ObterMetaReferenciaMensal()
    {
        if (marcaAtual == "byd")
        {
            return 15;
        }
        if (marcaAtual == "jeep")
        {
            return 18;
        }
        return 20;
    }

    private string RenderizarRanking(DataTable ranking, int codigoUsuario)
    {
        if (ranking.Rows.Count == 0)
        {
            return "<article class=\"sales-intelligence-card\"><span>Ranking</span><strong>-</strong><small>Sem vendas no per&iacute;odo filtrado.</small></article>";
        }

        int posicao = 0;
        DataRow linhaUsuario = null;
        for (int i = 0; i < ranking.Rows.Count; i++)
        {
            if (Convert.ToInt32(ranking.Rows[i]["codigo"]) == codigoUsuario)
            {
                posicao = i + 1;
                linhaUsuario = ranking.Rows[i];
                break;
            }
        }

        if (linhaUsuario == null)
        {
            return "<article class=\"sales-intelligence-card\"><span>Ranking</span><strong>Fora do top 50</strong><small>Sem volume suficiente no filtro atual.</small></article>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<article class=\"sales-intelligence-card\"><span>Ranking no per&iacute;odo</span><strong>");
        html.Append(HttpUtility.HtmlEncode(posicao.ToString(ptBr)));
        html.Append("&ordm; lugar</strong><small>");
        html.Append(HttpUtility.HtmlEncode(ToDecimal(linhaUsuario["unidades"]).ToString("N0", ptBr)));
        html.Append(" unidade(s) | ");
        html.Append(HttpUtility.HtmlEncode(ToDecimal(linhaUsuario["valor"]).ToString("C0", ptBr)));
        html.Append("</small></article>");
        return html.ToString();
    }

    private string RenderizarAlertas(DataTable vendas, IndicadoresVendas indicadores)
    {
        List<string> alertas = new List<string>();
        if (indicadores.Devolucoes > 0)
        {
            alertas.Add(indicadores.Devolucoes.ToString("N0", ptBr) + " devolu\u00e7\u00e3o(\u00f5es) no per\u00edodo.");
        }
        if (indicadores.MargemMedia > 0 && indicadores.MargemMedia < 8)
        {
            alertas.Add("Margem m\u00e9dia abaixo de 8%.");
        }
        int contatosIncompletos = ContarContatosIncompletos(vendas);
        if (contatosIncompletos > 0)
        {
            alertas.Add(contatosIncompletos.ToString("N0", ptBr) + " venda(s) com contato incompleto.");
        }
        if (indicadores.VendasBrutas == 0)
        {
            alertas.Add("Nenhuma venda positiva no filtro atual.");
        }

        StringBuilder html = new StringBuilder();
        html.Append("<article class=\"sales-intelligence-card sales-alert-card\"><span>Alertas</span>");
        if (alertas.Count == 0)
        {
            html.Append("<strong>Sem pontos cr&iacute;ticos</strong><small>Dados consistentes para o filtro atual.</small>");
        }
        else
        {
            html.Append("<strong>");
            html.Append(HttpUtility.HtmlEncode(alertas.Count.ToString(ptBr)));
            html.Append(" ponto(s) de aten&ccedil;&atilde;o</strong><ul>");
            for (int i = 0; i < alertas.Count; i++)
            {
                html.Append("<li>");
                html.Append(HttpUtility.HtmlEncode(alertas[i]));
                html.Append("</li>");
            }
            html.Append("</ul>");
        }
        html.Append("</article>");
        return html.ToString();
    }

    private int ContarContatosIncompletos(DataTable vendas)
    {
        int total = 0;
        for (int i = 0; i < vendas.Rows.Count; i++)
        {
            string telefone = Convert.ToString(vendas.Rows[i]["TelefoneCliente"]).Trim();
            string email = Convert.ToString(vendas.Rows[i]["emailcliente"]).Trim();
            if (ToDecimal(vendas.Rows[i]["qtde"]) > 0 && telefone.Length == 0 && email.Length == 0)
            {
                total++;
            }
        }
        return total;
    }

    private string RenderizarComparativo(string titulo, decimal atual, decimal anterior, string formato, string sufixo)
    {
        decimal diferenca = atual - anterior;
        string classe = diferenca > 0 ? " is-positive" : diferenca < 0 ? " is-negative" : " is-neutral";
        string sinal = diferenca > 0 ? "+" : "";
        string percentual = "";

        if (anterior != 0)
        {
            decimal variacao = (diferenca / Math.Abs(anterior)) * 100;
            percentual = " (" + sinal + variacao.ToString("N1", ptBr) + "%)";
        }
        else if (atual != 0)
        {
            percentual = " (novo)";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<article class=\"sales-comparison-card");
        html.Append(classe);
        html.Append("\"><span>");
        html.Append(HttpUtility.HtmlEncode(titulo));
        html.Append("</span><strong>");
        html.Append(HttpUtility.HtmlEncode(atual.ToString(formato, ptBr) + sufixo));
        html.Append("</strong><small>");
        html.Append(HttpUtility.HtmlEncode(sinal + diferenca.ToString(formato, ptBr) + sufixo + percentual));
        html.Append("</small></article>");
        return html.ToString();
    }

    private IndicadoresVendas CalcularIndicadores(DataTable vendas)
    {
        IndicadoresVendas indicadores = new IndicadoresVendas();
        decimal margemSoma = 0;
        int margemQtde = 0;
        Dictionary<DateTime, decimal> porDia = new Dictionary<DateTime, decimal>();
        HashSet<string> clientes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        indicadores.Notas = vendas.Rows.Count;

        for (int i = 0; i < vendas.Rows.Count; i++)
        {
            DataRow linha = vendas.Rows[i];
            decimal qtde = ToDecimal(linha["qtde"]);
            decimal valor = ToDecimal(linha["ValordeVenda"]);
            indicadores.UnidadesLiquidas += qtde;
            indicadores.ValorLiquido += valor;

            if (qtde > 0)
            {
                indicadores.VendasBrutas += qtde;
            }
            else if (qtde < 0)
            {
                indicadores.Devolucoes += Math.Abs(qtde);
            }

            decimal margem = ToDecimal(linha["Margem"]);
            if (linha["Margem"] != DBNull.Value)
            {
                margemSoma += margem;
                margemQtde++;
            }

            if (linha["datavenda"] != DBNull.Value)
            {
                DateTime dia = Convert.ToDateTime(linha["datavenda"]).Date;
                if (!porDia.ContainsKey(dia))
                {
                    porDia[dia] = 0;
                }
                porDia[dia] += qtde;
            }

            string clienteChave = Convert.ToString(linha["CodigoPessoa"]).Trim();
            if (clienteChave.Length == 0)
            {
                clienteChave = Convert.ToString(linha["CPFCliente"]).Trim();
            }
            if (clienteChave.Length == 0)
            {
                clienteChave = Convert.ToString(linha["NomeCliente"]).Trim();
            }
            if (clienteChave.Length > 0)
            {
                clientes.Add(clienteChave);
            }

            if (valor > indicadores.MaiorVenda)
            {
                indicadores.MaiorVenda = valor;
                indicadores.TemMaiorVenda = true;
                indicadores.MaiorVendaDetalhe = MontarDetalheMaiorVenda(linha);
            }
        }

        indicadores.DiasAtivos = porDia.Count;
        indicadores.ClientesUnicos = clientes.Count;
        indicadores.TicketMedio = indicadores.UnidadesLiquidas == 0 ? 0 : indicadores.ValorLiquido / Math.Abs(indicadores.UnidadesLiquidas);
        indicadores.MargemMedia = margemQtde == 0 ? 0 : margemSoma / margemQtde;

        foreach (KeyValuePair<DateTime, decimal> item in porDia)
        {
            if (!indicadores.TemMelhorDia || item.Value > indicadores.MelhorDiaQtde)
            {
                indicadores.TemMelhorDia = true;
                indicadores.MelhorDia = item.Key;
                indicadores.MelhorDiaQtde = item.Value;
            }
        }

        return indicadores;
    }

    private string MontarDetalheMaiorVenda(DataRow linha)
    {
        string cliente = Convert.ToString(linha["NomeCliente"]).Trim();
        string modelo = Convert.ToString(linha["modeloveiculo"]).Trim();
        DateTime data;
        string dataTexto = linha["datavenda"] != DBNull.Value && DateTime.TryParse(Convert.ToString(linha["datavenda"]), out data)
            ? data.ToString("dd/MM/yyyy", ptBr)
            : "";

        List<string> partes = new List<string>();
        if (cliente.Length > 0) partes.Add(cliente);
        if (modelo.Length > 0) partes.Add(modelo);
        if (dataTexto.Length > 0) partes.Add(dataTexto);
        return partes.Count == 0 ? "Detalhe n\u00e3o informado" : String.Join(" | ", partes.ToArray());
    }

    private void ObterPeriodoAnterior(DateTime dataInicial, DateTime dataFinal, out DateTime dataInicialAnterior, out DateTime dataFinalAnterior)
    {
        int dias = (dataFinal.Date - dataInicial.Date).Days + 1;
        dataFinalAnterior = dataInicial.Date.AddDays(-1);
        dataInicialAnterior = dataFinalAnterior.AddDays(-(dias - 1));
    }

    private string ObterTipoFiltroSelecionado()
    {
        string valorPostado = Request.Form[ddlTipoFiltro.UniqueID];
        return NormalizarTipoFiltro(String.IsNullOrEmpty(valorPostado) ? ddlTipoFiltro.SelectedValue : valorPostado);
    }

    private string ObterLojaFiltroSelecionada()
    {
        string valorPostado = Request.Form[ddlLojaFiltro.UniqueID];
        return String.IsNullOrEmpty(valorPostado) ? Convert.ToString(ddlLojaFiltro.SelectedValue).Trim() : valorPostado.Trim();
    }

    private string NormalizarTipoFiltro(string tipo)
    {
        tipo = (tipo ?? "").Trim().ToUpperInvariant();
        if (tipo == "VN" || tipo == "VU" || tipo == "VD")
        {
            return tipo;
        }

        return "";
    }

    private string DescreverTipoFiltro(string tipo)
    {
        tipo = NormalizarTipoFiltro(tipo);
        if (tipo == "VN") return "Novo";
        if (tipo == "VU") return "Usado";
        if (tipo == "VD") return "Venda direta";
        return "Todos os tipos";
    }

    private string NormalizarTextoFiltro(string texto)
    {
        return (texto ?? "").Trim().ToUpperInvariant();
    }

    private string DescreverLojaFiltro(string loja)
    {
        loja = (loja ?? "").Trim();
        return loja.Length == 0 ? "Todas as lojas" : loja;
    }

    private void ExportarExcel(DataTable vendas, DateTime dataInicial, DateTime dataFinal, string tipoFiltro, string lojaFiltro)
    {
        IndicadoresVendas indicadores = CalcularIndicadores(vendas);
        string nomeArquivo = String.Format(
            CultureInfo.InvariantCulture,
            "minhas-vendas-{0}-{1:yyyyMMdd}-{2:yyyyMMdd}.xls",
            marcaAtual,
            dataInicial,
            dataFinal);

        Response.Clear();
        Response.Buffer = true;
        Response.ContentEncoding = Encoding.UTF8;
        Response.ContentType = "application/vnd.ms-excel";
        Response.AddHeader("Content-Disposition", "attachment; filename=" + nomeArquivo);
        Response.Write("\uFEFF");
        Response.Write("<html><head><meta charset=\"utf-8\" /></head><body>");
        Response.Write("<h2>Minhas vendas - ");
        Response.Write(HttpUtility.HtmlEncode(marcaAtual.ToUpperInvariant()));
        Response.Write("</h2>");
        Response.Write("<p>Periodo: ");
        Response.Write(HttpUtility.HtmlEncode(String.Format(ptBr, "{0:dd/MM/yyyy} a {1:dd/MM/yyyy}", dataInicial, dataFinal)));
        Response.Write("</p>");
        Response.Write("<p>Tipo: ");
        Response.Write(HttpUtility.HtmlEncode(DescreverTipoFiltro(tipoFiltro)));
        Response.Write("</p>");
        Response.Write("<p>Loja: ");
        Response.Write(HttpUtility.HtmlEncode(DescreverLojaFiltro(lojaFiltro)));
        Response.Write("</p>");

        Response.Write("<table border=\"1\"><tbody>");
        Response.Write("<tr><th>Vendedor</th><td>");
        Response.Write(HttpUtility.HtmlEncode(Convert.ToString(Session["usuario"])));
        Response.Write("</td><th>Codigo</th><td>");
        Response.Write(HttpUtility.HtmlEncode(Convert.ToString(Session["usuario_codigo"])));
        Response.Write("</td></tr>");
        Response.Write("<tr><th>Unidades liquidas</th><td>");
        Response.Write(HttpUtility.HtmlEncode(indicadores.UnidadesLiquidas.ToString("N0", ptBr)));
        Response.Write("</td><th>Valor liquido</th><td>");
        Response.Write(HttpUtility.HtmlEncode(indicadores.ValorLiquido.ToString("C2", ptBr)));
        Response.Write("</td></tr>");
        Response.Write("<tr><th>Ticket medio</th><td>");
        Response.Write(HttpUtility.HtmlEncode(indicadores.TicketMedio.ToString("C2", ptBr)));
        Response.Write("</td><th>Margem media</th><td>");
        Response.Write(HttpUtility.HtmlEncode(indicadores.MargemMedia.ToString("N2", ptBr) + "%"));
        Response.Write("</td></tr>");
        Response.Write("<tr><th>Vendas brutas</th><td>");
        Response.Write(HttpUtility.HtmlEncode(indicadores.VendasBrutas.ToString("N0", ptBr)));
        Response.Write("</td><th>Devolucoes</th><td>");
        Response.Write(HttpUtility.HtmlEncode(indicadores.Devolucoes.ToString("N0", ptBr)));
        Response.Write("</td></tr>");
        Response.Write("<tr><th>Clientes unicos</th><td>");
        Response.Write(HttpUtility.HtmlEncode(indicadores.ClientesUnicos.ToString("N0", ptBr)));
        Response.Write("</td><th>Melhor dia</th><td>");
        Response.Write(HttpUtility.HtmlEncode(indicadores.TemMelhorDia ? indicadores.MelhorDia.ToString("dd/MM/yyyy", ptBr) : "-"));
        Response.Write("</td></tr>");
        Response.Write("<tr><th>Maior venda</th><td colspan=\"3\">");
        Response.Write(HttpUtility.HtmlEncode(indicadores.TemMaiorVenda ? indicadores.MaiorVenda.ToString("C2", ptBr) + " - " + indicadores.MaiorVendaDetalhe : "-"));
        Response.Write("</td></tr>");
        Response.Write("<tr><th>Meta referencial</th><td>");
        Response.Write(HttpUtility.HtmlEncode(MontarResumoMetaExcel(indicadores, dataInicial, dataFinal)));
        Response.Write("</td><th>Top modelo</th><td>");
        Response.Write(HttpUtility.HtmlEncode(ObterTopGrupo(vendas, "modeloveiculo", "qtde", "N0")));
        Response.Write("</td></tr>");
        Response.Write("<tr><th>Top cliente</th><td>");
        Response.Write(HttpUtility.HtmlEncode(ObterTopGrupo(vendas, "NomeCliente", "ValordeVenda", "C2")));
        Response.Write("</td><th>Alertas</th><td>");
        Response.Write(HttpUtility.HtmlEncode(MontarResumoAlertasExcel(vendas, indicadores)));
        Response.Write("</td></tr>");
        Response.Write("</tbody></table><br />");

        Response.Write("<table border=\"1\"><thead><tr>");

        string[] titulos = {
            "Data",
            "Nota fiscal",
            "Pedido",
            "Loja",
            "Cliente",
            "CPF/CNPJ",
            "Telefone",
            "E-mail",
            "Modelo",
            "Marca",
            "Fam\u00edlia",
            "Cor",
            "Tipo estoque",
            "Estoque",
            "Qtde",
            "Valor de venda",
            "Margem %",
            "Classificacao margem",
            "Chassi",
            "Placa",
            "Dias em estoque"
        };

        for (int i = 0; i < titulos.Length; i++)
        {
            Response.Write("<th>");
            Response.Write(HttpUtility.HtmlEncode(titulos[i]));
            Response.Write("</th>");
        }

        Response.Write("</tr></thead><tbody>");
        for (int i = 0; i < vendas.Rows.Count; i++)
        {
            DataRow row = vendas.Rows[i];
            Response.Write("<tr>");
            EscreverCelulaExcel(FormatarDataExcel(row["datavenda"]));
            EscreverCelulaExcel(row["notafiscal"]);
            EscreverCelulaExcel(row["pedidodoveiculo"]);
            EscreverCelulaExcel(row["loja"]);
            EscreverCelulaExcel(row["NomeCliente"]);
            EscreverCelulaExcel(row["CPFCliente"]);
            EscreverCelulaExcel(row["TelefoneCliente"]);
            EscreverCelulaExcel(row["emailcliente"]);
            EscreverCelulaExcel(row["modeloveiculo"]);
            EscreverCelulaExcel(row["marcaveiculo"]);
            EscreverCelulaExcel(row["familiaveiculo"]);
            EscreverCelulaExcel(row["corveiculo"]);
            EscreverCelulaExcel(row["tipoestoque"]);
            EscreverCelulaExcel(row["estoqueveiculo"]);
            EscreverCelulaExcel(ToDecimal(row["qtde"]).ToString("N0", ptBr));
            EscreverCelulaExcel(ToDecimal(row["ValordeVenda"]).ToString("C2", ptBr));
            decimal margem = ToDecimal(row["Margem"]);
            EscreverCelulaExcel(margem.ToString("N2", ptBr) + "%");
            EscreverCelulaExcel(ClassificarMargem(margem));
            EscreverCelulaExcel(row["chassi"]);
            EscreverCelulaExcel(row["placa"]);
            EscreverCelulaExcel(row["diasdeestoque"]);
            Response.Write("</tr>");
        }

        Response.Write("</tbody></table></body></html>");
        Response.Flush();
        Response.End();
    }

    private string MontarResumoMetaExcel(IndicadoresVendas indicadores, DateTime dataInicial, DateTime dataFinal)
    {
        int metaMesReferencia = ObterMetaReferenciaMensal();
        int diasPeriodo = (dataFinal.Date - dataInicial.Date).Days + 1;
        int diasMes = DateTime.DaysInMonth(dataInicial.Year, dataInicial.Month);
        decimal metaPeriodo = Math.Max(1, Math.Round(metaMesReferencia * (diasPeriodo / (decimal)diasMes), 0));
        decimal percentual = metaPeriodo == 0 ? 0 : (indicadores.VendasBrutas / metaPeriodo) * 100;
        return String.Format(ptBr, "{0:N0}/{1:N0} ({2:N0}%)", indicadores.VendasBrutas, metaPeriodo, percentual);
    }

    private string MontarResumoAlertasExcel(DataTable vendas, IndicadoresVendas indicadores)
    {
        List<string> alertas = new List<string>();
        if (indicadores.Devolucoes > 0) alertas.Add(indicadores.Devolucoes.ToString("N0", ptBr) + " devolu\u00e7\u00e3o(\u00f5es)");
        if (indicadores.MargemMedia > 0 && indicadores.MargemMedia < 8) alertas.Add("margem m\u00e9dia abaixo de 8%");
        int contatosIncompletos = ContarContatosIncompletos(vendas);
        if (contatosIncompletos > 0) alertas.Add(contatosIncompletos.ToString("N0", ptBr) + " contato(s) incompleto(s)");
        if (indicadores.VendasBrutas == 0) alertas.Add("sem venda positiva");
        return alertas.Count == 0 ? "Sem pontos cr\u00edticos" : String.Join("; ", alertas.ToArray());
    }

    private string ObterTopGrupo(DataTable vendas, string campoGrupo, string campoValor, string formatoValor)
    {
        Dictionary<string, decimal> grupos = new Dictionary<string, decimal>(StringComparer.OrdinalIgnoreCase);
        for (int i = 0; i < vendas.Rows.Count; i++)
        {
            string chave = Convert.ToString(vendas.Rows[i][campoGrupo]).Trim();
            if (chave.Length == 0)
            {
                chave = "N\u00e3o informado";
            }

            if (!grupos.ContainsKey(chave))
            {
                grupos[chave] = 0;
            }
            grupos[chave] += ToDecimal(vendas.Rows[i][campoValor]);
        }

        string melhorGrupo = "";
        decimal melhorValor = 0;
        foreach (KeyValuePair<string, decimal> item in grupos)
        {
            if (melhorGrupo.Length == 0 || Math.Abs(item.Value) > Math.Abs(melhorValor))
            {
                melhorGrupo = item.Key;
                melhorValor = item.Value;
            }
        }

        return melhorGrupo.Length == 0 ? "-" : melhorGrupo + " - " + melhorValor.ToString(formatoValor, ptBr);
    }

    private string ClassificarMargem(decimal margem)
    {
        if (margem <= 0)
        {
            return "N\u00e3o informada";
        }
        if (margem < 8)
        {
            return "Aten\u00e7\u00e3o";
        }
        if (margem >= 15)
        {
            return "Alta";
        }
        return "Saud\u00e1vel";
    }

    private void EscreverCelulaExcel(object valor)
    {
        Response.Write("<td>");
        Response.Write(HttpUtility.HtmlEncode(Convert.ToString(valor)));
        Response.Write("</td>");
    }

    private string FormatarDataExcel(object valor)
    {
        if (valor == null || valor == DBNull.Value)
        {
            return "";
        }

        DateTime data;
        if (!DateTime.TryParse(Convert.ToString(valor), out data))
        {
            return Convert.ToString(valor);
        }

        return data.ToString("dd/MM/yyyy", ptBr);
    }

    protected string Atributo(object valor)
    {
        string texto = Convert.ToString(valor);
        texto = HttpUtility.HtmlAttributeEncode(String.IsNullOrWhiteSpace(texto) ? "" : texto.Trim());
        return texto.Replace("'", "&#39;");
    }

    private void PreencherGraficos(DataTable vendas, DateTime dataInicial, DateTime dataFinal)
    {
        litGraficoDiario.Text = RenderizarGraficoDiario(vendas, dataInicial, dataFinal);
        litGraficoValorDiario.Text = RenderizarGraficoValorDiario(vendas, dataInicial, dataFinal);
        litLojas.Text = RenderizarBarras(vendas, "loja", "qtde", "Nenhuma loja encontrada.");
        litTipos.Text = RenderizarBarras(vendas, "tipoestoque", "qtde", "Nenhum tipo de estoque encontrado.");
        litTopModelos.Text = RenderizarBarras(vendas, "modeloveiculo", "qtde", "Nenhum modelo encontrado.");
        litTopClientes.Text = RenderizarBarras(vendas, "NomeCliente", "ValordeVenda", "Nenhum cliente encontrado.", "C0");
        litFollowUp.Text = RenderizarFollowUp(vendas);
    }

    private void PreencherTabela(DataTable vendas)
    {
        gvVendas.DataSource = vendas;
        gvVendas.DataBind();

        if (gvVendas.HeaderRow != null)
        {
            gvVendas.HeaderRow.TableSection = TableRowSection.TableHeader;
        }
    }

    private string RenderizarGraficoDiario(DataTable vendas, DateTime dataInicial, DateTime dataFinal)
    {
        SortedDictionary<DateTime, decimal> porDia = new SortedDictionary<DateTime, decimal>();
        DateTime cursor = dataInicial.Date;
        while (cursor <= dataFinal.Date)
        {
            porDia[cursor] = 0;
            cursor = cursor.AddDays(1);
        }

        for (int i = 0; i < vendas.Rows.Count; i++)
        {
            DataRow linha = vendas.Rows[i];
            if (linha["datavenda"] == DBNull.Value)
            {
                continue;
            }

            DateTime dia = Convert.ToDateTime(linha["datavenda"]).Date;
            if (!porDia.ContainsKey(dia))
            {
                porDia[dia] = 0;
            }
            porDia[dia] += ToDecimal(linha["qtde"]);
        }

        if (porDia.Count == 0)
        {
            return "<div class=\"sales-empty-chart\">Sem dados para montar o gr&aacute;fico.</div>";
        }

        decimal maximo = 0;
        foreach (KeyValuePair<DateTime, decimal> item in porDia)
        {
            decimal valorAbsoluto = Math.Abs(item.Value);
            if (valorAbsoluto > maximo)
            {
                maximo = valorAbsoluto;
            }
        }
        if (maximo <= 0)
        {
            maximo = 1;
        }

        int largura = 920;
        int altura = 260;
        int esquerda = 52;
        int direita = 24;
        int topo = 28;
        int baixo = 48;
        decimal areaLargura = largura - esquerda - direita;
        decimal areaAltura = altura - topo - baixo;
        int quantidade = porDia.Count;
        int indice = 0;
        int passoLegenda = Math.Max(1, (int)Math.Ceiling(quantidade / 6.0));
        StringBuilder pontos = new StringBuilder();
        StringBuilder circulos = new StringBuilder();
        StringBuilder legendas = new StringBuilder();

        foreach (KeyValuePair<DateTime, decimal> item in porDia)
        {
            decimal x = quantidade == 1 ? esquerda + (areaLargura / 2) : esquerda + (areaLargura * indice / (quantidade - 1));
            decimal y = topo + areaAltura - ((Math.Abs(item.Value) / maximo) * areaAltura);
            pontos.AppendFormat(CultureInfo.InvariantCulture, "{0:0.##},{1:0.##} ", x, y);
            circulos.AppendFormat(CultureInfo.InvariantCulture, "<circle cx=\"{0:0.##}\" cy=\"{1:0.##}\" r=\"3.5\"><title>{2}: {3}</title></circle>", x, y, item.Key.ToString("dd/MM/yyyy", ptBr), item.Value.ToString("N0", ptBr));

            if (indice == 0 || indice == quantidade - 1 || indice % passoLegenda == 0)
            {
                legendas.AppendFormat(CultureInfo.InvariantCulture, "<text x=\"{0:0.##}\" y=\"235\">{1}</text>", x, HttpUtility.HtmlEncode(item.Key.ToString("dd/MM", ptBr)));
            }

            indice++;
        }

        StringBuilder svg = new StringBuilder();
        svg.Append("<div class=\"sales-line-chart\" role=\"img\" aria-label=\"Evolu&#231;&#227;o di&#225;ria de vendas\">");
        svg.AppendFormat(CultureInfo.InvariantCulture, "<svg viewBox=\"0 0 {0} {1}\" preserveAspectRatio=\"none\">", largura, altura);
        svg.Append("<line class=\"sales-axis\" x1=\"52\" y1=\"212\" x2=\"896\" y2=\"212\"></line>");
        svg.Append("<line class=\"sales-grid\" x1=\"52\" y1=\"28\" x2=\"896\" y2=\"28\"></line>");
        svg.Append("<line class=\"sales-grid\" x1=\"52\" y1=\"120\" x2=\"896\" y2=\"120\"></line>");
        svg.Append("<text class=\"sales-y-label\" x=\"12\" y=\"32\">");
        svg.Append(HttpUtility.HtmlEncode(maximo.ToString("N0", ptBr)));
        svg.Append("</text>");
        svg.Append("<text class=\"sales-y-label\" x=\"18\" y=\"124\">");
        svg.Append(HttpUtility.HtmlEncode((maximo / 2).ToString("N0", ptBr)));
        svg.Append("</text>");
        svg.Append("<text class=\"sales-y-label\" x=\"36\" y=\"216\">0</text>");
        svg.AppendFormat(CultureInfo.InvariantCulture, "<polyline class=\"sales-line\" points=\"{0}\"></polyline>", pontos.ToString().Trim());
        svg.Append("<g class=\"sales-points\">");
        svg.Append(circulos.ToString());
        svg.Append("</g><g class=\"sales-x-labels\">");
        svg.Append(legendas.ToString());
        svg.Append("</g></svg></div>");
        return svg.ToString();
    }

    private string RenderizarGraficoValorDiario(DataTable vendas, DateTime dataInicial, DateTime dataFinal)
    {
        SortedDictionary<DateTime, decimal> porDia = new SortedDictionary<DateTime, decimal>();
        DateTime cursor = dataInicial.Date;
        while (cursor <= dataFinal.Date)
        {
            porDia[cursor] = 0;
            cursor = cursor.AddDays(1);
        }

        for (int i = 0; i < vendas.Rows.Count; i++)
        {
            DataRow linha = vendas.Rows[i];
            if (linha["datavenda"] == DBNull.Value)
            {
                continue;
            }

            DateTime dia = Convert.ToDateTime(linha["datavenda"]).Date;
            if (!porDia.ContainsKey(dia))
            {
                porDia[dia] = 0;
            }
            porDia[dia] += ToDecimal(linha["ValordeVenda"]);
        }

        if (porDia.Count == 0)
        {
            return "<div class=\"sales-empty-chart\">Sem dados para montar o gr&aacute;fico.</div>";
        }

        decimal maximo = 0;
        foreach (KeyValuePair<DateTime, decimal> item in porDia)
        {
            decimal valorAbsoluto = Math.Abs(item.Value);
            if (valorAbsoluto > maximo)
            {
                maximo = valorAbsoluto;
            }
        }
        if (maximo <= 0)
        {
            maximo = 1;
        }

        int largura = 920;
        int altura = 260;
        int esquerda = 72;
        int direita = 24;
        int topo = 28;
        int baixo = 48;
        decimal areaLargura = largura - esquerda - direita;
        decimal areaAltura = altura - topo - baixo;
        int quantidade = porDia.Count;
        int indice = 0;
        int passoLegenda = Math.Max(1, (int)Math.Ceiling(quantidade / 6.0));
        StringBuilder pontos = new StringBuilder();
        StringBuilder circulos = new StringBuilder();
        StringBuilder legendas = new StringBuilder();

        foreach (KeyValuePair<DateTime, decimal> item in porDia)
        {
            decimal x = quantidade == 1 ? esquerda + (areaLargura / 2) : esquerda + (areaLargura * indice / (quantidade - 1));
            decimal y = topo + areaAltura - ((Math.Abs(item.Value) / maximo) * areaAltura);
            pontos.AppendFormat(CultureInfo.InvariantCulture, "{0:0.##},{1:0.##} ", x, y);
            circulos.AppendFormat(CultureInfo.InvariantCulture, "<circle cx=\"{0:0.##}\" cy=\"{1:0.##}\" r=\"3.5\"><title>{2}: {3}</title></circle>", x, y, item.Key.ToString("dd/MM/yyyy", ptBr), item.Value.ToString("C0", ptBr));

            if (indice == 0 || indice == quantidade - 1 || indice % passoLegenda == 0)
            {
                legendas.AppendFormat(CultureInfo.InvariantCulture, "<text x=\"{0:0.##}\" y=\"235\">{1}</text>", x, HttpUtility.HtmlEncode(item.Key.ToString("dd/MM", ptBr)));
            }

            indice++;
        }

        StringBuilder svg = new StringBuilder();
        svg.Append("<div class=\"sales-line-chart sales-value-line-chart\" role=\"img\" aria-label=\"Evolu&#231;&#227;o di&#225;ria de valor vendido\">");
        svg.AppendFormat(CultureInfo.InvariantCulture, "<svg viewBox=\"0 0 {0} {1}\" preserveAspectRatio=\"none\">", largura, altura);
        svg.Append("<line class=\"sales-axis\" x1=\"72\" y1=\"212\" x2=\"896\" y2=\"212\"></line>");
        svg.Append("<line class=\"sales-grid\" x1=\"72\" y1=\"28\" x2=\"896\" y2=\"28\"></line>");
        svg.Append("<line class=\"sales-grid\" x1=\"72\" y1=\"120\" x2=\"896\" y2=\"120\"></line>");
        svg.Append("<text class=\"sales-y-label\" x=\"8\" y=\"32\">");
        svg.Append(HttpUtility.HtmlEncode(maximo.ToString("C0", ptBr)));
        svg.Append("</text>");
        svg.Append("<text class=\"sales-y-label\" x=\"8\" y=\"124\">");
        svg.Append(HttpUtility.HtmlEncode((maximo / 2).ToString("C0", ptBr)));
        svg.Append("</text>");
        svg.Append("<text class=\"sales-y-label\" x=\"52\" y=\"216\">0</text>");
        svg.AppendFormat(CultureInfo.InvariantCulture, "<polyline class=\"sales-line\" points=\"{0}\"></polyline>", pontos.ToString().Trim());
        svg.Append("<g class=\"sales-points\">");
        svg.Append(circulos.ToString());
        svg.Append("</g><g class=\"sales-x-labels\">");
        svg.Append(legendas.ToString());
        svg.Append("</g></svg></div>");
        return svg.ToString();
    }

    private string RenderizarBarras(DataTable vendas, string campoGrupo, string campoValor, string mensagemVazio)
    {
        return RenderizarBarras(vendas, campoGrupo, campoValor, mensagemVazio, "N0");
    }

    private string RenderizarBarras(DataTable vendas, string campoGrupo, string campoValor, string mensagemVazio, string formatoValor)
    {
        Dictionary<string, decimal> grupos = new Dictionary<string, decimal>(StringComparer.OrdinalIgnoreCase);

        for (int i = 0; i < vendas.Rows.Count; i++)
        {
            string chave = Convert.ToString(vendas.Rows[i][campoGrupo]).Trim();
            if (chave.Length == 0)
            {
                chave = "N\u00e3o informado";
            }

            if (!grupos.ContainsKey(chave))
            {
                grupos[chave] = 0;
            }

            grupos[chave] += ToDecimal(vendas.Rows[i][campoValor]);
        }

        if (grupos.Count == 0)
        {
            return "<div class=\"sales-empty-chart\">" + HttpUtility.HtmlEncode(mensagemVazio) + "</div>";
        }

        List<KeyValuePair<string, decimal>> itens = new List<KeyValuePair<string, decimal>>(grupos);
        itens.Sort(delegate(KeyValuePair<string, decimal> a, KeyValuePair<string, decimal> b)
        {
            return Math.Abs(b.Value).CompareTo(Math.Abs(a.Value));
        });

        decimal maximo = 0;
        for (int i = 0; i < itens.Count && i < 7; i++)
        {
            decimal valorAbsoluto = Math.Abs(itens[i].Value);
            if (valorAbsoluto > maximo)
            {
                maximo = valorAbsoluto;
            }
        }
        if (maximo <= 0)
        {
            maximo = 1;
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"sales-bar-list\">");
        for (int i = 0; i < itens.Count && i < 7; i++)
        {
            decimal valor = itens[i].Value;
            decimal percentual = Math.Min(100, (Math.Abs(valor) / maximo) * 100);
            string classe = valor < 0 ? " sales-bar-negative" : "";
            html.Append("<div class=\"sales-bar-row\">");
            html.Append("<div class=\"sales-bar-label\"><span>");
            html.Append(HttpUtility.HtmlEncode(itens[i].Key));
            html.Append("</span><strong>");
            html.Append(HttpUtility.HtmlEncode(valor.ToString(formatoValor, ptBr)));
            html.Append("</strong></div>");
            html.Append("<div class=\"sales-bar-track\"><span class=\"sales-bar-fill");
            html.Append(classe);
            html.Append("\" style=\"width:");
            html.Append(percentual.ToString("0.##", CultureInfo.InvariantCulture));
            html.Append("%\"></span></div></div>");
        }
        html.Append("</div>");
        return html.ToString();
    }

    private string RenderizarFollowUp(DataTable vendas)
    {
        if (vendas.Rows.Count == 0)
        {
            return "<div class=\"sales-empty-chart\">Nenhuma venda para follow-up neste filtro.</div>";
        }

        StringBuilder html = new StringBuilder();
        int adicionados = 0;
        html.Append("<div class=\"sales-followup-list\">");

        for (int i = 0; i < vendas.Rows.Count && adicionados < 6; i++)
        {
            DataRow linha = vendas.Rows[i];
            if (ToDecimal(linha["qtde"]) <= 0)
            {
                continue;
            }

            string cliente = Convert.ToString(linha["NomeCliente"]).Trim();
            string telefone = Convert.ToString(linha["TelefoneCliente"]).Trim();
            string email = Convert.ToString(linha["emailcliente"]).Trim();
            string modelo = Convert.ToString(linha["modeloveiculo"]).Trim();
            string loja = Convert.ToString(linha["loja"]).Trim();
            string data = FormatarDataExcel(linha["datavenda"]);

            html.Append("<article class=\"sales-followup-item\">");
            html.Append("<div><span>");
            html.Append(HttpUtility.HtmlEncode(data));
            html.Append("</span><strong>");
            html.Append(HttpUtility.HtmlEncode(cliente.Length == 0 ? "Cliente sem nome" : cliente));
            html.Append("</strong><small>");
            html.Append(HttpUtility.HtmlEncode(String.Join(" | ", new string[] { modelo, loja }).Trim(' ', '|')));
            html.Append("</small></div>");
            html.Append("<button type=\"button\" class=\"sales-row-action is-secondary\" data-copy-contact=\"true\" data-cliente=\"");
            html.Append(Atributo(cliente));
            html.Append("\" data-telefone=\"");
            html.Append(Atributo(telefone));
            html.Append("\" data-email=\"");
            html.Append(Atributo(email));
            html.Append("\">Copiar contato</button>");
            html.Append("</article>");
            adicionados++;
        }

        html.Append("</div>");

        if (adicionados == 0)
        {
            return "<div class=\"sales-empty-chart\">Nenhuma venda positiva para follow-up neste filtro.</div>";
        }

        return html.ToString();
    }

    private bool TentarLerPeriodo(out DateTime dataInicial, out DateTime dataFinal)
    {
        if (!TentarLerData(txtDataInicial.Text, out dataInicial))
        {
            ExibirAviso("Informe uma data inicial v\u00e1lida.");
            dataFinal = DateTime.Today;
            return false;
        }

        if (!TentarLerData(txtDataFinal.Text, out dataFinal))
        {
            ExibirAviso("Informe uma data final v\u00e1lida.");
            return false;
        }

        if (dataFinal.Date < dataInicial.Date)
        {
            ExibirAviso("A data final precisa ser maior ou igual \u00e0 data inicial.");
            return false;
        }

        if ((dataFinal.Date - dataInicial.Date).Days + 1 > DiasMaximosPeriodoBI)
        {
            ExibirAviso("Selecione um per\u00edodo de at\u00e9 32 dias para manter o BI r\u00e1pido e confi\u00e1vel.");
            return false;
        }

        return true;
    }

    private bool TentarLerData(string valor, out DateTime data)
    {
        valor = (valor ?? "").Trim();
        if (DateTime.TryParseExact(valor, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out data))
        {
            return true;
        }

        return DateTime.TryParse(valor, ptBr, DateTimeStyles.None, out data);
    }

    private void DefinirPeriodoMesAtual()
    {
        DateTime hoje = DateTime.Today;
        DateTime primeiroDia = new DateTime(hoje.Year, hoje.Month, 1);
        DateTime ultimoDia = primeiroDia.AddMonths(1).AddDays(-1);
        txtDataInicial.Text = primeiroDia.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        txtDataFinal.Text = ultimoDia.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
    }

    private int ObterCodigoUsuarioLogado()
    {
        int codigo;
        if (Int32.TryParse(Convert.ToString(Session["usuario_codigo"]), out codigo) && codigo > 0)
        {
            return codigo;
        }

        codigo = BuscarCodigoUsuarioAtual();
        if (codigo > 0)
        {
            Session["usuario_codigo"] = codigo.ToString(CultureInfo.InvariantCulture);
        }

        return codigo;
    }

    private int BuscarCodigoUsuarioAtual()
    {
        string id = Convert.ToString(Session["id"]);
        string usuario = Convert.ToString(Session["usuario"]);
        string email = Convert.ToString(Session["email"]);

        try
        {
            using (SqlConnection conexao = new SqlConnection(DealernetConnectionString))
            using (SqlCommand comando = conexao.CreateCommand())
            {
                comando.CommandText = @"
SELECT TOP 1 ISNULL(Usuario_Codigo, 0)
FROM Usuario
WHERE Usuario_Ativo = 1
  AND Usuario_DataDemissao IS NULL
  AND (
        (@id <> '' AND UPPER(LTRIM(RTRIM(Usuario_Identificador))) = UPPER(LTRIM(RTRIM(@id))))
     OR (@usuario <> '' AND UPPER(LTRIM(RTRIM(Usuario_Identificador))) = UPPER(LTRIM(RTRIM(@usuario))))
     OR (@email <> '' AND LOWER(LTRIM(RTRIM(Usuario_Email))) = LOWER(LTRIM(RTRIM(@email))))
      )
ORDER BY
    CASE
        WHEN @id <> '' AND UPPER(LTRIM(RTRIM(Usuario_Identificador))) = UPPER(LTRIM(RTRIM(@id))) THEN 1
        WHEN @usuario <> '' AND UPPER(LTRIM(RTRIM(Usuario_Identificador))) = UPPER(LTRIM(RTRIM(@usuario))) THEN 2
        ELSE 3
    END;";
                comando.Parameters.Add("@id", SqlDbType.VarChar, 80).Value = id ?? "";
                comando.Parameters.Add("@usuario", SqlDbType.VarChar, 120).Value = usuario ?? "";
                comando.Parameters.Add("@email", SqlDbType.VarChar, 160).Value = email ?? "";

                conexao.Open();
                object resultado = comando.ExecuteScalar();
                int codigo;
                if (resultado != null && resultado != DBNull.Value && Int32.TryParse(resultado.ToString(), out codigo))
                {
                    return codigo;
                }
            }
        }
        catch (Exception ex)
        {
            RegistrarErro("recuperar-codigo-vendedor", ex);
        }

        return 0;
    }

    private void AplicarMarca()
    {
        string nome = "Bali Fiat";
        string logo = "img/logobali.png";
        string voltar = "/veiculos/Default.aspx";

        if (marcaAtual == "jeep")
        {
            nome = "Bali Jeep";
            logo = "img/logojeep.png";
            voltar = "/jeep/principal.aspx";
        }
        else if (marcaAtual == "byd")
        {
            nome = "Bali BYD";
            logo = "img/bydbranco.png";
            voltar = "/byd/principal.aspx";
        }

        pageBody.Attributes["class"] = "sales-bi-page brand-" + marcaAtual;
        imgLogo.ImageUrl = logo;
        imgLogo.AlternateText = nome;
        litMarcaTopo.Text = HttpUtility.HtmlEncode(nome);
        litEyebrow.Text = HttpUtility.HtmlEncode(nome) + " &middot; desempenho comercial";
        lnkVoltar.NavigateUrl = voltar;
        lnkVoltarTopo.HRef = voltar;
        lnkSair.NavigateUrl = "/logout.aspx?voltar=" + HttpUtility.UrlEncode(UrlLogin(marcaAtual));
    }

    private bool UsuarioLogado()
    {
        string usuario = Convert.ToString(Session["usuario"]);
        return !String.IsNullOrWhiteSpace(usuario);
    }

    private string NormalizarMarca(string marca)
    {
        marca = (marca ?? "").Trim().ToLowerInvariant();
        if (marca == "jeep" || marca == "byd")
        {
            return marca;
        }
        return "fiat";
    }

    private string UrlLogin(string marca)
    {
        if (marca == "jeep")
        {
            return "/jeep/loginAppcontrato.aspx";
        }
        if (marca == "byd")
        {
            return "/byd/loginAppcontrato.aspx";
        }
        return "/veiculos/loginAppcontrato.aspx";
    }

    private decimal ToDecimal(object valor)
    {
        if (valor == null || valor == DBNull.Value)
        {
            return 0;
        }

        if (!(valor is string))
        {
            try
            {
                return Convert.ToDecimal(valor, CultureInfo.InvariantCulture);
            }
            catch
            {
            }
        }

        string texto = Convert.ToString(valor).Trim();
        decimal convertido;
        if (texto.IndexOf(',') >= 0 && Decimal.TryParse(texto, NumberStyles.Any, ptBr, out convertido))
        {
            return convertido;
        }

        if (Decimal.TryParse(texto, NumberStyles.Any, CultureInfo.InvariantCulture, out convertido))
        {
            return convertido;
        }

        if (Decimal.TryParse(texto, NumberStyles.Any, ptBr, out convertido))
        {
            return convertido;
        }

        return 0;
    }

    private void ExibirAviso(string mensagem)
    {
        pnlAviso.Visible = true;
        litAviso.Text = HttpUtility.HtmlEncode(mensagem);
    }

    private void RegistrarErro(string origem, Exception ex)
    {
        try
        {
            string caminho = Server.MapPath("~/App_Data/minhas-vendas-erros.log");
            string linha = String.Format(CultureInfo.InvariantCulture, "{0:yyyy-MM-dd HH:mm:ss} | {1} | {2} | {3}{4}", DateTime.Now, origem, Convert.ToString(Session["usuario"]), ex.Message, Environment.NewLine);
            System.IO.File.AppendAllText(caminho, linha, Encoding.UTF8);
        }
        catch
        {
        }
    }

    private void RegistrarAuditoria(string acao, DateTime dataInicial, DateTime dataFinal, int codigoUsuario, string tipoFiltro, string lojaFiltro, int registros)
    {
        try
        {
            string caminho = Server.MapPath("~/App_Data/minhas-vendas-auditoria.log");
            string linha = String.Format(
                CultureInfo.InvariantCulture,
                "{0:yyyy-MM-dd HH:mm:ss} | acao={1} | usuario={2} | codigo={3} | marca={4} | periodo={5:yyyy-MM-dd}:{6:yyyy-MM-dd} | tipo={7} | loja={8} | registros={9} | ip={10}{11}",
                DateTime.Now,
                acao,
                Convert.ToString(Session["usuario"]),
                codigoUsuario,
                marcaAtual,
                dataInicial.Date,
                dataFinal.Date,
                NormalizarTipoFiltro(tipoFiltro),
                DescreverLojaFiltro(lojaFiltro),
                registros,
                ObterIpCliente(),
                Environment.NewLine);
            System.IO.File.AppendAllText(caminho, linha, Encoding.UTF8);
        }
        catch
        {
        }
    }

    private string ObterIpCliente()
    {
        string encaminhado = Convert.ToString(Request.ServerVariables["HTTP_X_FORWARDED_FOR"]);
        if (!String.IsNullOrWhiteSpace(encaminhado))
        {
            string[] partes = encaminhado.Split(',');
            if (partes.Length > 0)
            {
                return partes[0].Trim();
            }
        }

        return Convert.ToString(Request.ServerVariables["REMOTE_ADDR"]);
    }

    private class IndicadoresVendas
    {
        public decimal UnidadesLiquidas;
        public decimal ValorLiquido;
        public decimal TicketMedio;
        public decimal MargemMedia;
        public decimal VendasBrutas;
        public decimal Devolucoes;
        public int Notas;
        public int DiasAtivos;
        public int ClientesUnicos;
        public bool TemMelhorDia;
        public DateTime MelhorDia;
        public decimal MelhorDiaQtde;
        public bool TemMaiorVenda;
        public decimal MaiorVenda;
        public string MaiorVendaDetalhe = "";
    }
}
