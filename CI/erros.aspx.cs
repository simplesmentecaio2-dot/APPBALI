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

        gvErros.DataSource = tabela;
        gvErros.DataBind();
        litResumo.Text = tabela.Rows.Count.ToString() + " ocorr" + (tabela.Rows.Count == 1 ? "\u00eancia" : "\u00eancias") + " exibida" + (tabela.Rows.Count == 1 ? "." : "s.");
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
