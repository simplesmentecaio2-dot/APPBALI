using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;

public partial class ci_print : System.Web.UI.Page
{
    public string CodigoCI = "CI";
    public string MarcaClasse = "marca-fiat";
    private const int TimeoutSqlSegundos = 60;

    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
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
        litAssunto.Text = Html(row["assunto"].ToString());
        litCorpo.Text = TextoLongo(row["corpo"].ToString());
        litProvidencias.Text = TextoLongo(row["providencias"].ToString());
        litObservacoes.Text = TextoLongo(row["observacoes"].ToString());
        litCriadoPor.Text = Html(row["criado_por"].ToString());
        litEmitidaEm.Text = DateTime.Now.ToString("dd/MM/yyyy HH:mm");

        secProvidencias.Visible = row["providencias"].ToString().Trim().Length > 0;
        secObservacoes.Visible = row["observacoes"].ToString().Trim().Length > 0;

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
            row["corpo"].ToString().Length +
            row["providencias"].ToString().Length +
            row["observacoes"].ToString().Length;

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

    private string TextoLongo(string valor)
    {
        string seguro = HttpUtility.HtmlEncode(valor ?? "");
        return "<p>" + seguro.Replace("\r\n", "\n").Replace("\n", "</p><p>") + "</p>";
    }
}
