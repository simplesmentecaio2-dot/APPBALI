using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ci_erros : System.Web.UI.Page
{
    private const string SenhaLogs = "@bali2025";
    private const string ViewStateCookieName = "BaliViewStateKey";
    private const int LimiteLinhas = 200;

    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString; }
    }

    protected void Page_Init(object sender, EventArgs e)
    {
        ViewStateUserKey = ObterChaveViewState();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UsuarioCIAutenticado())
        {
            RedirecionarLoginCI();
            return;
        }

        if (!IsPostBack && LogsAutorizados())
        {
            AbrirConteudo();
        }
    }

    private bool UsuarioCIAutenticado()
    {
        return Session["ci_autenticado"] != null
            && Session["usuario"] != null
            && Convert.ToString(Session["usuario"]).Trim().Length > 0;
    }

    private void RedirecionarLoginCI()
    {
        string voltar = Request.RawUrl ?? "erros.aspx";
        if (voltar.StartsWith("/CI/", StringComparison.OrdinalIgnoreCase))
        {
            voltar = voltar.Substring(4);
        }

        Response.Redirect("login.aspx?voltar=" + HttpUtility.UrlEncode(voltar), false);
        Context.ApplicationInstance.CompleteRequest();
    }

    protected void btnEntrar_Click(object sender, EventArgs e)
    {
        if (!String.Equals((txtSenha.Text ?? "").Trim(), SenhaLogs, StringComparison.Ordinal))
        {
            MostrarMensagem("Senha incorreta para abrir os logs da CI.");
            return;
        }

        Session["ci_logs_autorizado"] = true;
        AbrirConteudo();
    }

    protected void btnAtualizar_Click(object sender, EventArgs e)
    {
        if (!LogsAutorizados())
        {
            MostrarMensagem("Informe a senha para atualizar os logs.");
            pnlLogin.Visible = true;
            pnlConteudo.Visible = false;
            return;
        }

        CarregarLogs();
    }

    protected void btnFiltrarLogs_Click(object sender, EventArgs e)
    {
        gvErros.PageIndex = 0;
        CarregarLogs();
    }

    protected void btnLimparLogs_Click(object sender, EventArgs e)
    {
        txtBuscaLogs.Text = "";
        gvErros.PageIndex = 0;
        CarregarLogs();
    }

    protected void ddlLogsPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        int tamanho;
        if (!Int32.TryParse(ddlLogsPageSize.SelectedValue, out tamanho) || tamanho <= 0)
        {
            tamanho = 20;
        }

        gvErros.PageSize = tamanho;
        gvErros.PageIndex = 0;
        CarregarLogs();
    }

    protected void gvErros_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvErros.PageIndex = e.NewPageIndex;
        CarregarLogs();
    }

    protected void gvErros_Sorting(object sender, GridViewSortEventArgs e)
    {
        string direcaoAtual = Convert.ToString(ViewState["LogSortDirection"]);
        string campoAtual = Convert.ToString(ViewState["LogSortExpression"]);
        string novaDirecao = String.Equals(campoAtual, e.SortExpression, StringComparison.OrdinalIgnoreCase) &&
            String.Equals(direcaoAtual, "ASC", StringComparison.OrdinalIgnoreCase) ? "DESC" : "ASC";

        ViewState["LogSortExpression"] = e.SortExpression;
        ViewState["LogSortDirection"] = novaDirecao;
        gvErros.PageIndex = 0;
        CarregarLogs();
    }

    protected void gvErros_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;

        int limite = Math.Min(gvErros.Columns.Count, e.Row.Cells.Count);
        for (int i = 0; i < limite; i++)
        {
            e.Row.Cells[i].Attributes["data-label"] = Server.HtmlDecode(gvErros.Columns[i].HeaderText);
        }
    }

    protected void gvAuditoria_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;

        int limite = Math.Min(gvAuditoria.Columns.Count, e.Row.Cells.Count);
        for (int i = 0; i < limite; i++)
        {
            e.Row.Cells[i].Attributes["data-label"] = Server.HtmlDecode(gvAuditoria.Columns[i].HeaderText);
        }
    }

    private bool LogsAutorizados()
    {
        return Session["ci_logs_autorizado"] != null;
    }

    private void AbrirConteudo()
    {
        pnlMensagem.Visible = false;
        pnlLogin.Visible = false;
        pnlConteudo.Visible = true;
        CarregarLogs();
    }

    private void CarregarLogs()
    {
        AjustarTamanhoPaginaLogs();

        DataTable tabela = CriarTabela();
        string caminho = Server.MapPath("~/App_Data/ci-erros.log");

        if (File.Exists(caminho))
        {
            string[] linhas = File.ReadAllLines(caminho, Encoding.UTF8);
            foreach (string linha in linhas.Reverse().Take(LimiteLinhas))
            {
                AdicionarLinha(tabela, linha);
            }
        }

        DataTable filtrada = FiltrarLogs(tabela);
        DataTable ordenada = OrdenarLogs(filtrada);
        AjustarPaginaGrid(ordenada.Rows.Count);

        gvErros.DataSource = ordenada;
        gvErros.DataBind();
        litResumo.Text = MontarResumoLogs(tabela.Rows.Count, ordenada.Rows.Count);
        CarregarAuditoria();
    }

    private void CarregarAuditoria()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 300
                    dt_evento,
                    ISNULL(usuario_nome, '') AS usuario_nome,
                    acao,
                    ISNULL(codigo_ci, '') AS codigo_ci,
                    ISNULL(detalhe, '') AS detalhe,
                    ISNULL(ip, '') AS ip
                FROM dbo.ci_auditoria
                WHERE (@busca IS NULL
                    OR usuario_nome LIKE '%' + @busca + '%'
                    OR acao LIKE '%' + @busca + '%'
                    OR codigo_ci LIKE '%' + @busca + '%'
                    OR detalhe LIKE '%' + @busca + '%'
                    OR ip LIKE '%' + @busca + '%')
                ORDER BY dt_evento DESC, id_auditoria DESC;", con))
            using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
            {
                string busca = (txtBuscaLogs.Text ?? "").Trim();
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 60;
                cmd.Parameters.Add("@busca", SqlDbType.NVarChar, 160).Value = busca.Length == 0 ? (object)DBNull.Value : busca;
                DataTable auditoria = new DataTable();
                adapter.Fill(auditoria);
                gvAuditoria.DataSource = auditoria;
                gvAuditoria.DataBind();
                litResumoAuditoria.Text = auditoria.Rows.Count == 0
                    ? "Nenhuma a\u00e7\u00e3o encontrada no filtro atual."
                    : "Exibindo as " + auditoria.Rows.Count.ToString() + " a\u00e7\u00f5es mais recentes no filtro atual.";
            }
        }
        catch
        {
            gvAuditoria.DataSource = null;
            gvAuditoria.DataBind();
            litResumoAuditoria.Text = "N\u00e3o foi poss\u00edvel carregar a auditoria agora.";
        }
    }

    private DataTable CriarTabela()
    {
        DataTable tabela = new DataTable();
        tabela.Columns.Add("data_hora");
        tabela.Columns.Add("origem");
        tabela.Columns.Add("usuario");
        tabela.Columns.Add("url");
        tabela.Columns.Add("erro");
        return tabela;
    }

    private void AdicionarLinha(DataTable tabela, string linha)
    {
        string[] partes = (linha ?? "").Split('|');
        DataRow row = tabela.NewRow();
        row["data_hora"] = partes.Length > 0 ? partes[0].Trim() : "";
        row["origem"] = partes.Length > 1 ? partes[1].Trim() : "";
        row["usuario"] = ExtrairValor(partes, "usuario=");
        row["url"] = ExtrairValor(partes, "url=");
        row["erro"] = ExtrairValor(partes, "erro=");
        tabela.Rows.Add(row);
    }

    private DataTable FiltrarLogs(DataTable tabela)
    {
        string busca = (txtBuscaLogs.Text ?? "").Trim();
        if (busca.Length == 0) return tabela;

        DataTable filtrada = tabela.Clone();
        foreach (DataRow row in tabela.Rows)
        {
            foreach (DataColumn coluna in tabela.Columns)
            {
                string valor = Convert.ToString(row[coluna]) ?? "";
                if (valor.IndexOf(busca, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    filtrada.ImportRow(row);
                    break;
                }
            }
        }

        return filtrada;
    }

    private DataTable OrdenarLogs(DataTable tabela)
    {
        string campo = Convert.ToString(ViewState["LogSortExpression"]);
        if (String.IsNullOrWhiteSpace(campo) || !tabela.Columns.Contains(campo))
        {
            return tabela;
        }

        string direcao = String.Equals(Convert.ToString(ViewState["LogSortDirection"]), "DESC", StringComparison.OrdinalIgnoreCase) ? "DESC" : "ASC";
        DataView view = tabela.DefaultView;
        view.Sort = campo + " " + direcao;
        return view.ToTable();
    }

    private void AjustarTamanhoPaginaLogs()
    {
        int tamanho;
        if (!Int32.TryParse(ddlLogsPageSize.SelectedValue, out tamanho) || tamanho <= 0)
        {
            tamanho = 20;
        }

        gvErros.PageSize = tamanho;
    }

    private void AjustarPaginaGrid(int total)
    {
        if (total <= 0)
        {
            gvErros.PageIndex = 0;
            return;
        }

        int ultimaPagina = (total - 1) / gvErros.PageSize;
        if (gvErros.PageIndex > ultimaPagina)
        {
            gvErros.PageIndex = ultimaPagina;
        }
    }

    private string MontarResumoLogs(int total, int exibidos)
    {
        string resumo = exibidos.ToString() + " ocorr" + (exibidos == 1 ? "\u00eancia" : "\u00eancias") + " exibida" + (exibidos == 1 ? "" : "s");
        if (exibidos != total)
        {
            resumo += " de " + total.ToString() + " registro" + (total == 1 ? "" : "s") + " lido" + (total == 1 ? "" : "s");
        }

        resumo += ".";
        return resumo;
    }

    private string ExtrairValor(string[] partes, string prefixo)
    {
        foreach (string parte in partes)
        {
            string texto = (parte ?? "").Trim();
            if (texto.StartsWith(prefixo, StringComparison.OrdinalIgnoreCase))
            {
                return texto.Substring(prefixo.Length);
            }
        }

        return "";
    }

    private void MostrarMensagem(string mensagem)
    {
        pnlMensagem.Visible = true;
        litMensagem.Text = Server.HtmlEncode(mensagem);
    }

    private string ObterChaveViewState()
    {
        HttpCookie cookie = Request.Cookies[ViewStateCookieName];
        string chave = cookie != null ? (cookie.Value ?? "").Trim() : "";
        if (!ChaveViewStateValida(chave))
        {
            chave = Guid.NewGuid().ToString("N");
        }

        HttpCookie resposta = new HttpCookie(ViewStateCookieName, chave);
        resposta.HttpOnly = true;
        resposta.Secure = Request.IsSecureConnection;
        resposta.Path = "/";
        resposta.Expires = DateTime.UtcNow.AddYears(2);
        Response.Cookies.Set(resposta);
        return chave;
    }

    private bool ChaveViewStateValida(string chave)
    {
        if (chave == null || chave.Length != 32) return false;
        for (int i = 0; i < chave.Length; i++)
        {
            char c = chave[i];
            bool hexadecimal = (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
            if (!hexadecimal) return false;
        }

        return true;
    }
}
