using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

public partial class ci_print : System.Web.UI.Page
{
    public string CodigoCI = "CI";
    public string MarcaClasse = "marca-fiat";
    private const int TimeoutSqlSegundos = 60;
    private static readonly CultureInfo CulturaBrasil = new CultureInfo("pt-BR");

    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UsuarioCIAutenticado())
        {
            RedirecionarLoginCI();
            return;
        }

        int id;
        if (!Int32.TryParse(Request.QueryString["id"], out id) || id <= 0)
        {
            MostrarErro("CI n\u00e3o informada", "Informe uma CI v\u00e1lida para abrir a impress\u00e3o.");
            return;
        }

        DataTable dados = ObterCI(id);
        if (dados.Rows.Count == 0)
        {
            MostrarErro("CI n\u00e3o encontrada", "N\u00e3o localizamos uma comunica\u00e7\u00e3o interna com o ID informado.");
            return;
        }

        Preencher(dados.Rows[0]);
    }

    private bool UsuarioCIAutenticado()
    {
        return Session["ci_autenticado"] != null
            && Session["usuario"] != null
            && Convert.ToString(Session["usuario"]).Trim().Length > 0;
    }

    private void RedirecionarLoginCI()
    {
        string voltar = Request.RawUrl ?? "print.aspx";
        if (voltar.StartsWith("/CI/", StringComparison.OrdinalIgnoreCase))
        {
            voltar = voltar.Substring(4);
        }

        Response.Redirect("login.aspx?voltar=" + HttpUtility.UrlEncode(voltar), false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void Preencher(DataRow row)
    {
        string marca = row["origem_marca"].ToString();
        string status = row["status"].ToString();
        string categoria = row["categoria"].ToString();
        string prioridade = row["prioridade"].ToString();
        CodigoCI = row["codigo_ci"].ToString();
        MarcaClasse = ClasseMarca(marca) + " " + ClasseCategoria(categoria) + " " + ClassePrioridade(prioridade);
        MarcaClasse += ClasseTamanhoDocumento(row);
        if (status.Equals("Cancelada", StringComparison.OrdinalIgnoreCase))
        {
            MarcaClasse += " ci-cancelada";
        }

        litCodigo.Text = Html(CodigoCI);
        litData.Text = Convert.ToDateTime(row["data_documento"]).ToString("dd/MM/yyyy");
        litMarca.Text = Html(marca);
        litCategoria.Text = Html(categoria);
        litPrioridade.Text = Html(prioridade);
        litStatus.Text = Html(status);
        litOrigemArea.Text = Html(row["origem_area"].ToString());
        litOrigemResponsavel.Text = Html(row["origem_responsavel"].ToString());
        litDestinoArea.Text = Html(row["destino_area"].ToString());
        litDestinatario.Text = Html(row["destinatario"].ToString());
        litAssunto.Text = HtmlCaixaAlta(row["assunto"].ToString());
        litCorpo.Text = TextoLongo(row["corpo"].ToString());
        litProvidencias.Text = TextoLongo(row["providencias"].ToString());
        litObservacoes.Text = TextoLongo(row["observacoes"].ToString());
        litCriadoPor.Text = Html(row["criado_por"].ToString());
        litEmitidaEm.Text = DateTime.Now.ToString("dd/MM/yyyy HH:mm");

        secProvidencias.Visible = TextoPlanoRich(row["providencias"].ToString()).Length > 0;
        secObservacoes.Visible = TextoPlanoRich(row["observacoes"].ToString()).Length > 0;

        ConfigurarLogo(marca);
        CarregarRelacionados(Convert.ToInt32(row["id_ci"]));
    }

    private void MostrarErro(string titulo, string mensagem)
    {
        Response.StatusCode = 200;
        pnlDocumento.Visible = false;
        pnlAcoes.Visible = false;
        pnlErro.Visible = true;
        litErroTitulo.Text = Html(titulo);
        litErroMensagem.Text = Html(mensagem);
    }

    private void ConfigurarLogo(string marca)
    {
        imgLogo.Visible = false;
        litLogoTexto.Text = "";

        if (marca.IndexOf("Fiat", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            imgLogo.ImageUrl = "../img/logobali.png";
            imgLogo.AlternateText = "Bali Fiat";
            imgLogo.Visible = true;
            return;
        }

        if (marca.IndexOf("Jeep", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            imgLogo.ImageUrl = "../img/logojeep.png";
            imgLogo.AlternateText = "Bali Jeep";
            imgLogo.Visible = true;
            return;
        }

        if (marca.IndexOf("BYD", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            imgLogo.ImageUrl = "../img/bydbranco.png";
            imgLogo.AlternateText = "Bali BYD";
            imgLogo.Visible = true;
            return;
        }

        litLogoTexto.Text = "<strong>Grupo Bali</strong>";
    }

    private string ClasseMarca(string marca)
    {
        if (marca.IndexOf("Jeep", StringComparison.OrdinalIgnoreCase) >= 0) return "marca-jeep";
        if (marca.IndexOf("BYD", StringComparison.OrdinalIgnoreCase) >= 0) return "marca-byd";
        return "marca-fiat";
    }

    private string ClasseCategoria(string categoria)
    {
        string valor = (categoria ?? "").ToLowerInvariant();
        if (valor.IndexOf("solicita") >= 0) return "print-tipo-solicitacao";
        if (valor.IndexOf("autoriza") >= 0) return "print-tipo-autorizacao";
        if (valor.IndexOf("procedimento") >= 0) return "print-tipo-procedimento";
        if (valor.IndexOf("financeiro") >= 0) return "print-tipo-financeiro";
        return "print-tipo-comunicado";
    }

    private string ClassePrioridade(string prioridade)
    {
        string valor = (prioridade ?? "").ToLowerInvariant();
        if (valor.IndexOf("urgente") >= 0) return "print-prioridade-urgente";
        if (valor.IndexOf("alta") >= 0) return "print-prioridade-alta";
        return "print-prioridade-normal";
    }

    private string ClasseTamanhoDocumento(DataRow row)
    {
        int tamanho =
            row["assunto"].ToString().Length +
            TextoPlanoRich(row["corpo"].ToString()).Length +
            TextoPlanoRich(row["providencias"].ToString()).Length +
            TextoPlanoRich(row["observacoes"].ToString()).Length;

        if (tamanho > 5200) return " ci-print-muito-longa";
        if (tamanho > 3200) return " ci-print-longa";
        return "";
    }

    private DataTable ObterCI(int id)
    {
        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand("dbo.ci_comunicacao_obter", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add("@id_ci", SqlDbType.Int).Value = id;
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    private void CarregarRelacionados(int id)
    {
        DataTable ciencias = ObterTabelaRelacionada("dbo.ci_ciencia_listar", "@id_ci", id);

        secCiencias.Visible = ciencias.Rows.Count > 0;
        litCiencias.Text = RenderizarCiencias(ciencias);
    }

    private DataTable ObterTabelaRelacionada(string procedure, string parametro, int id)
    {
        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(procedure, con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add(parametro, SqlDbType.Int).Value = id;
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    private string RenderizarCiencias(DataTable dados)
    {
        if (dados.Rows.Count == 0) return "";

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"print-ack-table\"><thead><tr><th>Setor</th><th>Respons&aacute;vel</th><th>Data/hora</th><th>Observa&ccedil;&atilde;o</th></tr></thead><tbody>");
        foreach (DataRow row in dados.Rows)
        {
            html.Append("<tr><td>");
            html.Append(Html(row["setor"].ToString()));
            html.Append("</td><td>");
            html.Append(Html(row["responsavel"].ToString()));
            html.Append("</td><td>");
            html.Append(Convert.ToDateTime(row["dt_ciencia"]).ToString("dd/MM/yyyy HH:mm"));
            html.Append("</td><td>");
            string observacao = row["observacao"].ToString();
            if (observacao.Trim().Length > 0)
            {
                html.Append(Html(observacao));
            }
            html.Append("</td></tr>");
        }
        html.Append("</tbody></table>");
        return html.ToString();
    }

    private string Html(string valor)
    {
        return HttpUtility.HtmlEncode(valor);
    }

    private string HtmlCaixaAlta(string valor)
    {
        return HttpUtility.HtmlEncode((valor ?? "").ToUpper(CulturaBrasil));
    }

    private string TextoLongo(string valor)
    {
        string texto = valor ?? "";
        if (ContemHtml(texto))
        {
            string seguro = SanitizarHtmlRich(texto);
            return seguro.Length > 0 ? seguro : "<p></p>";
        }

        string seguroTexto = HttpUtility.HtmlEncode(texto);
        return "<p>" + seguroTexto.Replace("\r\n", "\n").Replace("\n", "</p><p>") + "</p>";
    }

    private string TextoPlanoRich(string valor)
    {
        string texto = valor ?? "";
        texto = Regex.Replace(texto, @"<\s*br\s*/?\s*>", "\n", RegexOptions.IgnoreCase);
        texto = Regex.Replace(texto, @"</\s*(p|div)\s*>", "\n", RegexOptions.IgnoreCase);
        texto = Regex.Replace(texto, @"<[^>]+>", "");
        texto = HttpUtility.HtmlDecode(texto);
        return (texto ?? "").Replace('\u00a0', ' ').Trim();
    }

    private bool ContemHtml(string valor)
    {
        return Regex.IsMatch(valor ?? "", @"<[a-zA-Z][\s\S]*>");
    }

    private string SanitizarHtmlRich(string valor)
    {
        string html = (valor ?? "").Replace("\r\n", "\n").Replace("\r", "\n");
        html = Regex.Replace(html, @"<\s*(script|style)[^>]*>[\s\S]*?<\s*/\s*\1\s*>", "", RegexOptions.IgnoreCase);

        StringBuilder saida = new StringBuilder();
        int posicao = 0;
        foreach (Match tag in Regex.Matches(html, @"<[^>]+>"))
        {
            if (tag.Index > posicao)
            {
                saida.Append(HtmlSeguroSegmento(html.Substring(posicao, tag.Index - posicao)));
            }

            saida.Append(TagRichPermitida(tag.Value));
            posicao = tag.Index + tag.Length;
        }

        if (posicao < html.Length)
        {
            saida.Append(HtmlSeguroSegmento(html.Substring(posicao)));
        }

        return saida.ToString().Trim();
    }

    private string HtmlSeguroSegmento(string texto)
    {
        return HttpUtility.HtmlEncode(HttpUtility.HtmlDecode(texto ?? ""));
    }

    private string TagRichPermitida(string tag)
    {
        Match match = Regex.Match(tag ?? "", @"^<\s*(/?)\s*([a-zA-Z0-9]+)([^>]*)/?\s*>$", RegexOptions.IgnoreCase);
        if (!match.Success) return "";

        bool fechamento = match.Groups[1].Value == "/";
        string nome = match.Groups[2].Value.ToLowerInvariant();
        string atributos = match.Groups[3].Value ?? "";

        if (nome == "br") return fechamento ? "" : "<br />";
        if (nome == "b") nome = "strong";
        if (nome == "i") nome = "em";
        if (nome == "div") nome = "p";

        if (nome == "strong" || nome == "em" || nome == "u" || nome == "p" || nome == "mark")
        {
            return fechamento ? "</" + nome + ">" : "<" + nome + ">";
        }

        if (nome == "span")
        {
            if (fechamento) return "</span>";
            string estilo = EstiloRichPermitido(atributos);
            return estilo.Length > 0 ? "<span style=\"" + estilo + "\">" : "<span>";
        }

        return "";
    }

    private string EstiloRichPermitido(string atributos)
    {
        Match match = Regex.Match(atributos ?? "", @"style\s*=\s*[""']([^""']*)[""']", RegexOptions.IgnoreCase);
        if (!match.Success) return "";

        string[] declaracoes = match.Groups[1].Value.Split(';');
        StringBuilder estilo = new StringBuilder();
        foreach (string declaracao in declaracoes)
        {
            string[] partes = declaracao.Split(new char[] { ':' }, 2);
            if (partes.Length != 2) continue;

            string propriedade = partes[0].Trim().ToLowerInvariant();
            if (propriedade == "color" || propriedade == "background-color")
            {
                string cor = NormalizarCorRich(partes[1]);
                if (cor.Length == 0) continue;
                if (estilo.Length > 0) estilo.Append(" ");
                estilo.Append(propriedade).Append(":").Append(cor).Append(";");
                continue;
            }

            if (propriedade == "font-weight")
            {
                string peso = NormalizarPesoRich(partes[1]);
                if (peso.Length == 0) continue;
                if (estilo.Length > 0) estilo.Append(" ");
                estilo.Append("font-weight:").Append(peso).Append(";");
                continue;
            }

            if (propriedade == "font-style")
            {
                string estiloFonte = NormalizarEstiloFonteRich(partes[1]);
                if (estiloFonte.Length == 0) continue;
                if (estilo.Length > 0) estilo.Append(" ");
                estilo.Append("font-style:").Append(estiloFonte).Append(";");
            }
        }

        return estilo.ToString();
    }

    private string NormalizarCorRich(string valor)
    {
        string cor = (valor ?? "").Trim().ToLowerInvariant();
        switch (cor)
        {
            case "rgb(17, 24, 39)": return "#111827";
            case "rgb(201, 51, 58)": return "#c9333a";
            case "rgb(25, 105, 179)": return "#1969b3";
            case "rgb(40, 114, 70)": return "#287246";
            case "rgb(255, 243, 191)": return "#fff3bf";
            case "rgb(219, 234, 254)": return "#dbeafe";
        }

        return Regex.IsMatch(cor, @"^#([0-9a-f]{3}|[0-9a-f]{6})$") ? cor : "";
    }

    private string NormalizarPesoRich(string valor)
    {
        string peso = (valor ?? "").Trim().ToLowerInvariant();
        return peso == "bold" || peso == "700" || peso == "800" || peso == "900" ? "bold" : "";
    }

    private string NormalizarEstiloFonteRich(string valor)
    {
        string estilo = (valor ?? "").Trim().ToLowerInvariant();
        return estilo == "italic" ? "italic" : "";
    }
}
