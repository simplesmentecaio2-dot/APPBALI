using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;

public partial class ci_print : System.Web.UI.Page
{
    public string CodigoCI = "CI";
    public string MarcaClasse = "marca-fiat";

    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        int id;
        if (!Int32.TryParse(Request.QueryString["id"], out id) || id <= 0)
        {
            Response.Write("CI n&atilde;o informada.");
            Response.End();
            return;
        }

        DataTable dados = ObterCI(id);
        if (dados.Rows.Count == 0)
        {
            Response.Write("CI n&atilde;o encontrada.");
            Response.End();
            return;
        }

        Preencher(dados.Rows[0]);
    }

    private void Preencher(DataRow row)
    {
        string marca = row["origem_marca"].ToString();
        CodigoCI = row["codigo_ci"].ToString();
        MarcaClasse = ClasseMarca(marca);

        litCodigo.Text = Html(CodigoCI);
        litData.Text = Convert.ToDateTime(row["data_documento"]).ToString("dd/MM/yyyy");
        litMarca.Text = Html(marca);
        litCategoria.Text = Html(row["categoria"].ToString());
        litPrioridade.Text = Html(row["prioridade"].ToString());
        litOrigemArea.Text = Html(row["origem_area"].ToString());
        litOrigemResponsavel.Text = Html(row["origem_responsavel"].ToString());
        litDestinoArea.Text = Html(row["destino_area"].ToString());
        litDestinatario.Text = Html(row["destinatario"].ToString());
        litAssunto.Text = Html(row["assunto"].ToString());
        litCorpo.Text = TextoLongo(row["corpo"].ToString());
        litProvidencias.Text = TextoLongo(row["providencias"].ToString());
        litObservacoes.Text = TextoLongo(row["observacoes"].ToString());
        litCriadoPor.Text = Html(row["criado_por"].ToString());

        secProvidencias.Visible = row["providencias"].ToString().Trim().Length > 0;
        secObservacoes.Visible = row["observacoes"].ToString().Trim().Length > 0;

        ConfigurarLogo(marca);
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

    private DataTable ObterCI(int id)
    {
        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand("dbo.ci_comunicacao_obter", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@id_ci", SqlDbType.Int).Value = id;
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
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
