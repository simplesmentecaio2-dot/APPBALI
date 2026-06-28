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
            PreencherResumo(vendas, dataInicial, dataFinal);
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
        decimal totalUnidades = 0;
        decimal valorTotal = 0;
        decimal margemSoma = 0;
        int margemQtde = 0;
        HashSet<DateTime> diasAtivos = new HashSet<DateTime>();

        for (int i = 0; i < vendas.Rows.Count; i++)
        {
            DataRow linha = vendas.Rows[i];
            totalUnidades += ToDecimal(linha["qtde"]);
            valorTotal += ToDecimal(linha["ValordeVenda"]);

            decimal margem = ToDecimal(linha["Margem"]);
            if (linha["Margem"] != DBNull.Value)
            {
                margemSoma += margem;
                margemQtde++;
            }

            if (linha["datavenda"] != DBNull.Value)
            {
                diasAtivos.Add(Convert.ToDateTime(linha["datavenda"]).Date);
            }
        }

        decimal ticketMedio = totalUnidades == 0 ? 0 : valorTotal / Math.Abs(totalUnidades);
        decimal margemMedia = margemQtde == 0 ? 0 : margemSoma / margemQtde;

        lblPeriodo.Text = String.Format(ptBr, "Per\u00edodo analisado: {0:dd/MM/yyyy} a {1:dd/MM/yyyy}", dataInicial, dataFinal);
        lblTotalUnidades.Text = totalUnidades.ToString("N0", ptBr);
        lblValorTotal.Text = valorTotal.ToString("C0", ptBr);
        lblTicketMedio.Text = ticketMedio.ToString("C0", ptBr);
        lblMargemMedia.Text = margemMedia.ToString("N1", ptBr) + "%";
        lblQtdNotas.Text = vendas.Rows.Count.ToString("N0", ptBr);
        lblDiasAtivos.Text = diasAtivos.Count.ToString("N0", ptBr);
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
}
