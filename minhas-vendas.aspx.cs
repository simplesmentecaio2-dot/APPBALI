using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

public partial class minhas_vendas : System.Web.UI.Page
{
    private readonly CultureInfo ptBr = new CultureInfo("pt-BR");
    private const string DealernetConnectionString = "Data Source=129.13.144.8\\wf;Initial Catalog=GrupoBali_DealernetWF;User ID=caio;Password=D6d3h7g711;Connect Timeout=30;";
    private const int DiasMaximosPeriodoBI = 32;

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
            DataTable vendas = ConsultarVendas(dataInicial, dataFinal, codigoUsuario);
            ExportarExcel(vendas, dataInicial, dataFinal);
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
            e.Row.CssClass = "sales-return-row";
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
            DataTable vendas = ConsultarVendas(dataInicial, dataFinal, codigoUsuario);
            DateTime dataInicialAnterior;
            DateTime dataFinalAnterior;
            ObterPeriodoAnterior(dataInicial, dataFinal, out dataInicialAnterior, out dataFinalAnterior);
            DataTable vendasPeriodoAnterior = ConsultarVendas(dataInicialAnterior, dataFinalAnterior, codigoUsuario);

            PreencherResumo(vendas, dataInicial, dataFinal);
            PreencherComparativo(vendas, vendasPeriodoAnterior, dataInicialAnterior, dataFinalAnterior);
            PreencherGraficos(vendas, dataInicial, dataFinal);
            PreencherTabela(vendas);
        }
        catch (Exception ex)
        {
            pnlConteudo.Visible = false;
            ExibirAviso("N\u00e3o foi poss\u00edvel carregar suas vendas agora. Tente novamente em alguns instantes ou reduza o per\u00edodo pesquisado.");
            RegistrarErro("minhas-vendas", ex);
        }
    }

    private DataTable ConsultarVendas(DateTime dataInicial, DateTime dataFinal, int codigoUsuario)
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
ORDER BY notafiscal_dataemissao DESC, notafiscal_numero DESC;";
            comando.Parameters.Add("@datainicial", SqlDbType.DateTime).Value = dataInicial.Date;
            comando.Parameters.Add("@datafinal", SqlDbType.DateTime).Value = dataFinal.Date;
            comando.Parameters.Add("@codigo_usuario", SqlDbType.Int).Value = codigoUsuario;

            using (SqlDataAdapter adaptador = new SqlDataAdapter(comando))
            {
                adaptador.Fill(tabela);
            }
        }

        return tabela;
    }

    private void PreencherResumo(DataTable vendas, DateTime dataInicial, DateTime dataFinal)
    {
        IndicadoresVendas indicadores = CalcularIndicadores(vendas);

        lblPeriodo.Text = String.Format(ptBr, "Per\u00edodo analisado: {0:dd/MM/yyyy} a {1:dd/MM/yyyy}", dataInicial, dataFinal);
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

    private void ExportarExcel(DataTable vendas, DateTime dataInicial, DateTime dataFinal)
    {
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
            EscreverCelulaExcel(ToDecimal(row["Margem"]).ToString("N2", ptBr) + "%");
            EscreverCelulaExcel(row["chassi"]);
            EscreverCelulaExcel(row["placa"]);
            EscreverCelulaExcel(row["diasdeestoque"]);
            Response.Write("</tr>");
        }

        Response.Write("</tbody></table></body></html>");
        Response.Flush();
        Response.End();
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

    private void PreencherGraficos(DataTable vendas, DateTime dataInicial, DateTime dataFinal)
    {
        litGraficoDiario.Text = RenderizarGraficoDiario(vendas, dataInicial, dataFinal);
        litLojas.Text = RenderizarBarras(vendas, "loja", "qtde", "Nenhuma loja encontrada.");
        litTipos.Text = RenderizarBarras(vendas, "tipoestoque", "qtde", "Nenhum tipo de estoque encontrado.");
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

    private string RenderizarBarras(DataTable vendas, string campoGrupo, string campoValor, string mensagemVazio)
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
            html.Append(HttpUtility.HtmlEncode(valor.ToString("N0", ptBr)));
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
