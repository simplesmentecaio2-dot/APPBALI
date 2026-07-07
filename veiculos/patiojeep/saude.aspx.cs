using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;

public partial class veiculos_patiojeep_saude : System.Web.UI.Page
{
    private readonly string[] tabelasEsperadas = {
        "veiculos_patio_locacao",
        "veiculos_patio_transferencia",
        "veiculos_patio_loja",
        "veiculos_patio_auditoria_geral",
        "veiculos_patio_baixa_venda_log",
        "veiculos_patio_seminovos_locacao",
        "veiculos_patio_seminovos_transferencia",
        "veiculos_patio_seminovos_auditoria"
    };

    private readonly string[] proceduresEsperadas = {
        "veiculos_patio_sincronizar_baixas_venda",
        "veiculos_patio_baixa_manual",
        "veiculos_patio_operacional_atualizar",
        "veiculos_patio_seminovos_historico",
        "veiculos_patio_seminovos_auditoria_registrar",
        "veiculos_patio_lojas_ativas"
    };

    private readonly string[] indicesEsperados = {
        "IX_veiculos_patio_locacao_dt_cad_bi",
        "IX_veiculos_patio_locacao_loja_bi",
        "IX_veiculos_patio_locacao_baixa_dt",
        "IX_veiculos_patio_locacao_baixa_loja",
        "IX_veiculos_patio_transferencia_dt_bi",
        "IX_veiculos_patio_baixa_venda_log_dt",
        "IX_veiculos_patio_seminovos_locacao_ativo_loja_dt",
        "IX_veiculos_patio_seminovos_transferencia_dt",
        "IX_veiculos_patio_seminovos_auditoria_ref_dt",
        "IX_veiculos_patio_auditoria_geral_veiculo_dt"
    };

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
            CarregarSaude();
        }
    }

    protected void btnAtualizar_Click(object sender, EventArgs e)
    {
        CarregarSaude();
    }

    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Session.Abandon();
        Response.Redirect("./login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void CarregarSaude()
    {
        try
        {
            DataTable banco = ExecutarSqlTabela("SELECT DB_NAME() AS banco, @@SERVERNAME AS servidor;");
            litBanco.Text = Html(Valor(banco.Rows.Count > 0 ? banco.Rows[0] : null, "banco"));

            DataTable tabelas = ExecutarSqlTabela(SqlObjetos("U", tabelasEsperadas));
            DataTable procedures = ExecutarSqlTabela(SqlObjetos("P", proceduresEsperadas));
            DataTable indices = ExecutarSqlTabela(SqlIndices(indicesEsperados));
            DataTable resumo = ExecutarSqlTabela(@"
SELECT
    (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE baixado_venda = 0) AS novos_ativos,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_seminovos_locacao WITH (NOLOCK) WHERE ativo = 1) AS seminovos_ativos,
    (SELECT MAX(dt_baixa) FROM dbo.veiculos_patio_baixa_venda_log WITH (NOLOCK)) AS ultima_baixa_venda,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_baixa_venda_log WITH (NOLOCK) WHERE dt_baixa >= CONVERT(date, GETDATE())) AS baixas_venda_hoje,
    (SELECT MAX(dt) FROM dbo.veiculos_patio_auditoria_geral WITH (NOLOCK)) AS ultima_auditoria,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_auditoria_geral WITH (NOLOCK) WHERE dt >= DATEADD(day, -7, GETDATE())) AS eventos_7_dias;");

            litResumo.Text = RenderResumo(resumo.Rows.Count > 0 ? resumo.Rows[0] : null, tabelas, procedures, indices);
            litTabelas.Text = RenderChecklist(tabelasEsperadas, tabelas, "Tabela");
            litProcedures.Text = RenderChecklist(proceduresEsperadas, procedures, "Procedure");
            litIndices.Text = RenderChecklist(indicesEsperados, indices, "&Iacute;ndice");
        }
        catch (Exception ex)
        {
            PatioJeepAuditoria.Registrar("PATIO_SAUDE_ERRO", Session["usuario"], "SAUDE", ex.Message);
            litResumo.Text = "<div class=\"health-row\"><strong>N&atilde;o foi poss&iacute;vel carregar a sa&uacute;de t&eacute;cnica agora.</strong><span class=\"health-badge is-warn\">Ver auditoria</span></div>";
            litTabelas.Text = "";
            litProcedures.Text = "";
            litIndices.Text = "";
        }
    }

    private string RenderResumo(DataRow row, DataTable tabelas, DataTable procedures, DataTable indices)
    {
        int totalTabelas = ContarEncontrados(tabelasEsperadas, tabelas);
        int totalProcedures = ContarEncontrados(proceduresEsperadas, procedures);
        int totalIndices = ContarEncontrados(indicesEsperados, indices);

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"health-kpis\">");
        html.Append(Kpi("Tabelas", totalTabelas + "/" + tabelasEsperadas.Length, "estrutura"));
        html.Append(Kpi("Procedures", totalProcedures + "/" + proceduresEsperadas.Length, "rotinas"));
        html.Append(Kpi("&Iacute;ndices", totalIndices + "/" + indicesEsperados.Length, "performance"));
        html.Append(Kpi("Novos ativos", Valor(row, "novos_ativos"), "p&aacute;tio"));
        html.Append(Kpi("Seminovos ativos", Valor(row, "seminovos_ativos"), "p&aacute;tio"));
        html.Append(Kpi("Baixas hoje", Valor(row, "baixas_venda_hoje"), "por venda"));
        html.Append(Kpi("&Uacute;ltima baixa", DataCurta(row, "ultima_baixa_venda"), "sincroniza&ccedil;&atilde;o"));
        html.Append(Kpi("&Uacute;ltima auditoria", DataCurta(row, "ultima_auditoria"), Valor(row, "eventos_7_dias") + " evento(s) em 7 dias"));
        html.Append("</div>");
        return html.ToString();
    }

    private string RenderChecklist(string[] esperados, DataTable encontrados, string tipo)
    {
        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"health-list\">");
        foreach (string nome in esperados)
        {
            bool ok = Existe(encontrados, nome);
            html.Append("<div class=\"health-row\"><span><strong>")
                .Append(Html(nome))
                .Append("</strong><small>")
                .Append(tipo)
                .Append("</small></span><span class=\"health-badge ")
                .Append(ok ? "is-ok" : "is-warn")
                .Append("\"><i class=\"fa ")
                .Append(ok ? "fa-check-circle" : "fa-exclamation-triangle")
                .Append("\"></i>")
                .Append(ok ? "OK" : "Aten&ccedil;&atilde;o")
                .Append("</span></div>");
        }
        html.Append("</div>");
        return html.ToString();
    }

    private string Kpi(string label, string valor, string detalhe)
    {
        return "<div class=\"health-kpi\"><small>" + label + "</small><strong>" + Html(valor) + "</strong><small>" + detalhe + "</small></div>";
    }

    private int ContarEncontrados(string[] esperados, DataTable encontrados)
    {
        int total = 0;
        foreach (string nome in esperados)
        {
            if (Existe(encontrados, nome)) total++;
        }
        return total;
    }

    private bool Existe(DataTable tabela, string nome)
    {
        foreach (DataRow row in tabela.Rows)
        {
            if (String.Equals(Valor(row, "name"), nome, StringComparison.OrdinalIgnoreCase)) return true;
        }
        return false;
    }

    private string SqlObjetos(string tipo, string[] nomes)
    {
        return "SELECT name FROM sys.objects WITH (NOLOCK) WHERE type = '" + tipo + "' AND name IN (" + ListaSql(nomes) + ") ORDER BY name;";
    }

    private string SqlIndices(string[] nomes)
    {
        return "SELECT name FROM sys.indexes WITH (NOLOCK) WHERE name IN (" + ListaSql(nomes) + ") ORDER BY name;";
    }

    private string ListaSql(string[] valores)
    {
        StringBuilder sql = new StringBuilder();
        for (int i = 0; i < valores.Length; i++)
        {
            if (i > 0) sql.Append(",");
            sql.Append("'").Append(valores[i].Replace("'", "''")).Append("'");
        }
        return sql.ToString();
    }

    private DataTable ExecutarSqlTabela(string sql)
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            using (SqlCommand cmd = new SqlCommand(sql, banco.oCon2))
            {
                cmd.CommandTimeout = 20;
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd)) adapter.Fill(tabela);
            }
        }
        finally
        {
            banco.FecharConexao2();
        }
        return tabela;
    }

    private string Valor(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value) return "0";
        return Convert.ToString(row[coluna]);
    }

    private string DataCurta(DataRow row, string coluna)
    {
        DateTime data;
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value || !DateTime.TryParse(Convert.ToString(row[coluna]), out data)) return "-";
        return data.ToString("dd/MM/yyyy HH:mm");
    }

    private string Html(string valor)
    {
        return HttpUtility.HtmlEncode(valor ?? "");
    }
}
