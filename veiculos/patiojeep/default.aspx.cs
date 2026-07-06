using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows.Forms;
using System.Drawing;
using System.Data;
using QRCoder;
using System.IO;
using System.Data.SqlClient;
using System.Threading;

public partial class veiculos_contrato : System.Web.UI.Page
{
    private Veiculos vec = new Veiculos();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] != null)
        {
            usuarioLogado.Text = Session["usuario"].ToString();
            if (!IsPostBack)
            {
                RenderizarIndicadores();
            }
        }
        else
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
        }

        
        
       
    }
    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Session.Abandon();
        Response.Redirect("./login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    protected void btnBuscaGlobal_Click(object sender, EventArgs e)
    {
        string busca = NormalizarBusca(txtBuscaGlobal.Text);
        if (busca.Equals(""))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "buscaPatio", "alert('Digite s\\u00e9rie, chassi, placa, Renavam ou c\\u00f3digo antes de buscar.');", true);
            return;
        }

        Response.Redirect("./novos.aspx?buscar=" + Server.UrlEncode(busca), false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void RenderizarIndicadores()
    {
        string cacheKey = "patio_home_indicadores_v2";
        object cache = HttpRuntime.Cache[cacheKey];
        if (cache != null)
        {
            litHomeIndicadores.Text = Convert.ToString(cache);
            return;
        }

        try
        {
            DataTable tabela = ConsultarTabela(@"
SELECT
    (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE baixado_venda = 0) AS novos_ativos,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_seminovos_locacao WITH (NOLOCK) WHERE ativo = 1) AS seminovos_ativos,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_transferencia WITH (NOLOCK) WHERE dt_transf >= CONVERT(date, GETDATE())) +
    (SELECT COUNT(1) FROM dbo.veiculos_patio_seminovos_transferencia WITH (NOLOCK) WHERE dt_transf >= CONVERT(date, GETDATE())) AS transferencias_hoje;");

            DataRow row = tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
            string html =
                "<div class=\"d-flex flex-wrap mt-2\" style=\"gap:.5rem;\">" +
                Indicador("Novos", Valor(row, "novos_ativos"), "ativos") +
                Indicador("Seminovos", Valor(row, "seminovos_ativos"), "ativos") +
                Indicador("Transfer&ecirc;ncias hoje", Valor(row, "transferencias_hoje"), "movimentos") +
                "</div>";
            litHomeIndicadores.Text = html;
            HttpRuntime.Cache.Insert(cacheKey, html, null, DateTime.Now.AddSeconds(60), System.Web.Caching.Cache.NoSlidingExpiration);
        }
        catch
        {
            litHomeIndicadores.Text = "";
        }
    }

    private DataTable ConsultarTabela(string sql)
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(sql, banco.oCon2);
            cmd.CommandTimeout = 20;
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            adapter.Fill(tabela);
        }
        finally
        {
            banco.FecharConexao2();
        }
        return tabela;
    }

    private string Indicador(string titulo, string valor, string detalhe)
    {
        return "<span class=\"badge badge-light border\" style=\"font-size:.9rem;padding:.65rem .8rem;\"><b>" + titulo + ":</b> " + HttpUtility.HtmlEncode(valor) + " <small class=\"text-muted\">" + detalhe + "</small></span>";
    }

    private string Valor(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value)
        {
            return "0";
        }

        return Convert.ToString(row[coluna]);
    }

    private string NormalizarBusca(string valor)
    {
        valor = (valor ?? "").Trim().ToUpperInvariant();
        System.Text.StringBuilder limpo = new System.Text.StringBuilder();
        foreach (char caractere in valor)
        {
            if (Char.IsLetterOrDigit(caractere))
            {
                limpo.Append(caractere);
            }
        }
        return limpo.ToString();
    }

}
