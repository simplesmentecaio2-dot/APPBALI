using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

public partial class veiculos_patiojeep_auditoria : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] == null)
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        usuarioLogado.Text = Html(Convert.ToString(Session["usuario"]));

        if (!IsPostBack)
        {
            string origem = (Request.QueryString["origem"] ?? "").ToUpperInvariant();
            if (ddlOrigem.Items.FindByValue(origem) != null)
            {
                ddlOrigem.SelectedValue = origem;
            }

            txtVeiculo.Text = LimparBusca(Request.QueryString["veiculo"]);
            CarregarAuditoria();
        }
    }

    protected void btnFiltrar_Click(object sender, EventArgs e)
    {
        CarregarAuditoria();
    }

    protected void btnLimpar_Click(object sender, EventArgs e)
    {
        ddlOrigem.SelectedValue = "";
        ddlPeriodo.SelectedValue = "30";
        txtVeiculo.Text = "";
        txtBusca.Text = "";
        CarregarAuditoria();
    }

    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Session.Abandon();
        Response.Redirect("./login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void CarregarAuditoria()
    {
        int dias;
        if (!Int32.TryParse(ddlPeriodo.SelectedValue, out dias) || dias <= 0) dias = 30;

        DataTable tabela = ExecutarSqlTabela(@"
SELECT TOP 300
    id,
    dt,
    origem,
    ve_nr,
    acao,
    usuario,
    detalhe,
    ip,
    url
FROM dbo.veiculos_patio_auditoria_geral WITH (NOLOCK)
WHERE dt >= DATEADD(day, -@dias, GETDATE())
  AND (@origem = '' OR origem = @origem)
  AND (@veiculo = '' OR ve_nr = @veiculo)
  AND (
        @busca = ''
     OR acao LIKE @buscaLike
     OR usuario LIKE @buscaLike
     OR detalhe LIKE @buscaLike
     OR ip LIKE @buscaLike
     OR url LIKE @buscaLike
  )
ORDER BY dt DESC, id DESC;",
            Param("@dias", SqlDbType.Int, dias),
            Param("@origem", SqlDbType.VarChar, ddlOrigem.SelectedValue),
            Param("@veiculo", SqlDbType.VarChar, LimparBusca(txtVeiculo.Text)),
            Param("@busca", SqlDbType.VarChar, (txtBusca.Text ?? "").Trim()),
            Param("@buscaLike", SqlDbType.VarChar, "%" + (txtBusca.Text ?? "").Trim() + "%"));

        litResumo.Text = "<span class=\"audit-pill\"><i class=\"fa fa-list\"></i>" + tabela.Rows.Count + " evento(s)</span>";
        litTabela.Text = RenderTabela(tabela);
    }

    private string RenderTabela(DataTable tabela)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"audit-empty\">Nenhum evento encontrado para este filtro.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"audit-table\"><thead><tr>");
        html.Append("<th>Data</th><th>Origem</th><th>Ve&iacute;culo</th><th>A&ccedil;&atilde;o</th><th>Usu&aacute;rio</th><th>Detalhe</th><th>IP / URL</th>");
        html.Append("</tr></thead><tbody>");

        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td data-label=\"Data\">").Append(DataCurta(row, "dt")).Append("<small>#").Append(Html(Valor(row, "id"))).Append("</small></td>");
            html.Append("<td data-label=\"Origem\"><span class=\"audit-pill\">").Append(Html(Valor(row, "origem"))).Append("</span></td>");
            html.Append("<td data-label=\"Ve&iacute;culo\">").Append(Html(Valor(row, "ve_nr"))).Append("</td>");
            html.Append("<td data-label=\"A&ccedil;&atilde;o\"><strong>").Append(Html(Valor(row, "acao"))).Append("</strong></td>");
            html.Append("<td data-label=\"Usu&aacute;rio\">").Append(Html(Valor(row, "usuario"))).Append("</td>");
            html.Append("<td data-label=\"Detalhe\">").Append(Html(Valor(row, "detalhe"))).Append("</td>");
            html.Append("<td data-label=\"IP / URL\">").Append(Html(Valor(row, "ip"))).Append("<small>").Append(Html(Valor(row, "url"))).Append("</small></td>");
            html.Append("</tr>");
        }

        html.Append("</tbody></table>");
        return html.ToString();
    }

    private DataTable ExecutarSqlTabela(string sql, params SqlParameter[] parametros)
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            using (SqlCommand cmd = new SqlCommand(sql, banco.oCon2))
            {
                cmd.CommandTimeout = 20;
                foreach (SqlParameter parametro in parametros) cmd.Parameters.Add(parametro);
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd)) adapter.Fill(tabela);
            }
        }
        finally
        {
            banco.FecharConexao2();
        }
        return tabela;
    }

    private SqlParameter Param(string nome, SqlDbType tipo, object valor)
    {
        SqlParameter parametro = new SqlParameter(nome, tipo);
        if (tipo == SqlDbType.VarChar) parametro.Size = 500;
        parametro.Value = valor ?? DBNull.Value;
        return parametro;
    }

    private string LimparBusca(string valor)
    {
        valor = (valor ?? "").Trim().ToUpperInvariant();
        StringBuilder limpo = new StringBuilder();
        foreach (char caractere in valor)
        {
            if (Char.IsLetterOrDigit(caractere) || caractere == '-' || caractere == '_') limpo.Append(caractere);
        }
        return limpo.ToString();
    }

    private string Valor(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value) return "";
        return Convert.ToString(row[coluna]);
    }

    private string DataCurta(DataRow row, string coluna)
    {
        DateTime data;
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value || !DateTime.TryParse(Convert.ToString(row[coluna]), out data)) return "-";
        return data.ToString("dd/MM/yyyy HH:mm:ss");
    }

    private string Html(string valor)
    {
        return HttpUtility.HtmlEncode(valor ?? "");
    }
}
