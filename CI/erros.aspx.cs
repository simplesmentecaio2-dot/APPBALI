using System;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ci_erros : System.Web.UI.Page
{
    private const string SenhaLogs = "@ci*2026";
    private const int LimiteLinhas = 200;

    protected void Page_Init(object sender, EventArgs e)
    {
        if (Session != null)
        {
            ViewStateUserKey = Session.SessionID;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && LogsAutorizados())
        {
            AbrirConteudo();
        }
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
}
