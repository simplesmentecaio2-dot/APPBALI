using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;

public partial class veiculos_patio_relatorios : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] == null)
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        usuarioLogado.Text = Convert.ToString(Session["usuario"]);

        if (!IsPostBack)
        {
            CarregarRelatorio();
        }
    }

    protected void btnAtualizar_Click(object sender, EventArgs e)
    {
        CarregarRelatorio();
    }

    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Session.Abandon();
        Response.Redirect("./login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void CarregarRelatorio()
    {
        GarantirIndicesRelatorio();

        DataTable resumo = Consultar(@"
SELECT
    COUNT(1) AS total_patio,
    COUNT(DISTINCT COALESCE(NULLIF(loja_atual_id, 0), loja_id)) AS lojas_com_veiculos,
    SUM(CASE WHEN dt_cad >= CONVERT(date, GETDATE()) THEN 1 ELSE 0 END) AS entradas_hoje,
    SUM(CASE WHEN dt_cad >= DATEADD(day, -7, GETDATE()) THEN 1 ELSE 0 END) AS entradas_7_dias,
    MAX(dt_cad) AS ultima_entrada
FROM dbo.veiculos_patio_locacao;");

        DataTable movimentosResumo = Consultar(@"
SELECT
    COUNT(1) AS movimentos_mes,
    MAX(dt_transf) AS ultima_movimentacao
FROM dbo.veiculos_patio_transferencia
WHERE dt_transf >= DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0);");

        RenderizarResumo(resumo, movimentosResumo);

        litEstoquePorLoja.Text = RenderizarBarras(Consultar(@"
SELECT TOP 12
    COALESCE(l.ds, 'Sem loja') AS label,
    COUNT(1) AS total
FROM dbo.veiculos_patio_locacao p
LEFT JOIN dbo.veiculos_patio_loja l
    ON l.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
GROUP BY COALESCE(l.ds, 'Sem loja')
ORDER BY COUNT(1) DESC, COALESCE(l.ds, 'Sem loja');"), "Nenhum veículo cadastrado no pátio.");

        litEntradasDia.Text = RenderizarBarras(Consultar(@"
SELECT
    CONVERT(varchar(10), CONVERT(date, dt_cad), 103) AS label,
    COUNT(1) AS total
FROM dbo.veiculos_patio_locacao
WHERE dt_cad >= DATEADD(day, -13, CONVERT(date, GETDATE()))
GROUP BY CONVERT(date, dt_cad)
ORDER BY CONVERT(date, dt_cad);"), "Nenhuma entrada nos últimos 14 dias.");

        litMovimentacoesDia.Text = RenderizarBarras(Consultar(@"
SELECT
    CONVERT(varchar(10), CONVERT(date, dt_transf), 103) AS label,
    COUNT(1) AS total
FROM dbo.veiculos_patio_transferencia
WHERE dt_transf >= DATEADD(day, -13, CONVERT(date, GETDATE()))
GROUP BY CONVERT(date, dt_transf)
ORDER BY CONVERT(date, dt_transf);"), "Nenhuma movimentação nos últimos 14 dias.");

        litUsuarios.Text = RenderizarBarras(Consultar(@"
SELECT TOP 8
    COALESCE(NULLIF(LTRIM(RTRIM(fun_cad)), ''), 'Sem usuário') AS label,
    COUNT(1) AS total
FROM dbo.veiculos_patio_locacao
WHERE dt_cad >= DATEADD(day, -30, GETDATE())
GROUP BY COALESCE(NULLIF(LTRIM(RTRIM(fun_cad)), ''), 'Sem usuário')
ORDER BY COUNT(1) DESC, COALESCE(NULLIF(LTRIM(RTRIM(fun_cad)), ''), 'Sem usuário');"), "Nenhuma entrada nos últimos 30 dias.");

        litUltimasMovimentacoes.Text = RenderizarMovimentacoes(Consultar(@"
SELECT TOP 20
    t.dt_transf,
    t.ve_nr,
    COALESCE(orig.ds, '-') AS origem,
    COALESCE(dest.ds, '-') AS destino,
    COALESCE(NULLIF(LTRIM(RTRIM(t.fun_cad)), ''), '-') AS usuario
FROM dbo.veiculos_patio_transferencia t
LEFT JOIN dbo.veiculos_patio_loja orig ON orig.id = t.loja_orig
LEFT JOIN dbo.veiculos_patio_loja dest ON dest.id = t.loja_dest
ORDER BY t.dt_transf DESC, t.id DESC;"));

        litUltimosCadastros.Text = RenderizarCadastros(Consultar(@"
SELECT TOP 20
    p.dt_cad,
    p.ve_nr,
    COALESCE(l.ds, 'Sem loja') AS loja,
    COALESCE(NULLIF(LTRIM(RTRIM(p.fun_cad)), ''), '-') AS usuario
FROM dbo.veiculos_patio_locacao p
LEFT JOIN dbo.veiculos_patio_loja l
    ON l.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
ORDER BY p.dt_cad DESC, p.ve_nr DESC;"));
    }

    private DataTable Consultar(string sql)
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(sql, banco.oCon2);
            cmd.CommandTimeout = 25;
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            adapter.Fill(tabela);
        }
        finally
        {
            banco.FecharConexao2();
        }

        return tabela;
    }

    private void RenderizarResumo(DataTable resumo, DataTable movimentosResumo)
    {
        DataRow r = resumo.Rows.Count > 0 ? resumo.Rows[0] : null;
        DataRow m = movimentosResumo.Rows.Count > 0 ? movimentosResumo.Rows[0] : null;

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"patio-bi-kpis\">");
        html.Append(CardKpi("Veículos no pátio", Numero(r, "total_patio"), "posição atual"));
        html.Append(CardKpi("Lojas com veículos", Numero(r, "lojas_com_veiculos"), "lojas ativas ou usadas"));
        html.Append(CardKpi("Entradas hoje", Numero(r, "entradas_hoje"), "cadastros do dia"));
        html.Append(CardKpi("Entradas 7 dias", Numero(r, "entradas_7_dias"), "janela recente"));
        html.Append(CardKpi("Mov. no mês", Numero(m, "movimentos_mes"), "transferências"));
        html.Append(CardKpi("Última entrada", DataCurta(r, "ultima_entrada"), "registro mais recente"));
        html.Append("</div>");
        litResumo.Text = html.ToString();
    }

    private string CardKpi(string titulo, string valor, string legenda)
    {
        return "<div class=\"patio-bi-kpi\"><small>" + Html(titulo) + "</small><strong>" + Html(valor) + "</strong><span>" + Html(legenda) + "</span></div>";
    }

    private string RenderizarBarras(DataTable tabela, string vazio)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"patio-bi-empty\">" + Html(vazio) + "</div>";
        }

        int maximo = 0;
        foreach (DataRow row in tabela.Rows)
        {
            int total = Inteiro(row["total"]);
            if (total > maximo)
            {
                maximo = total;
            }
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"patio-bi-bar-list\">");
        foreach (DataRow row in tabela.Rows)
        {
            int total = Inteiro(row["total"]);
            int largura = maximo <= 0 ? 0 : Math.Max(4, Convert.ToInt32(Math.Round((total * 100.0) / maximo)));
            html.Append("<div class=\"patio-bi-bar-row\">");
            html.Append("<div class=\"patio-bi-bar-label\" title=\"" + Html(row["label"]) + "\">" + Html(row["label"]) + "</div>");
            html.Append("<div class=\"patio-bi-bar-track\"><span style=\"width:" + largura.ToString() + "%\"></span></div>");
            html.Append("<div class=\"patio-bi-bar-value\">" + total.ToString("N0") + "</div>");
            html.Append("</div>");
        }
        html.Append("</div>");
        return html.ToString();
    }

    private string RenderizarMovimentacoes(DataTable tabela)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"patio-bi-empty\">Nenhuma movimentação registrada até agora.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"table table-striped table-hover patio-bi-table\"><thead><tr>");
        html.Append("<th>Data</th><th>Veículo</th><th>Rota</th><th>Usuário</th>");
        html.Append("</tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td>" + Html(DataHora(row["dt_transf"])) + "</td>");
            html.Append("<td><span class=\"patio-bi-pill\">#" + Html(row["ve_nr"]) + "</span></td>");
            html.Append("<td><span class=\"patio-bi-route\"><span class=\"patio-bi-pill\">" + Html(row["origem"]) + "</span><i class=\"fa fa-arrow-right text-muted\"></i><span class=\"patio-bi-pill\">" + Html(row["destino"]) + "</span></span></td>");
            html.Append("<td>" + Html(row["usuario"]) + "</td>");
            html.Append("</tr>");
        }
        html.Append("</tbody></table>");
        return html.ToString();
    }

    private string RenderizarCadastros(DataTable tabela)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"patio-bi-empty\">Nenhum veículo cadastrado no pátio.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"table table-striped table-hover patio-bi-table\"><thead><tr>");
        html.Append("<th>Data</th><th>Veículo</th><th>Loja atual</th><th>Usuário</th>");
        html.Append("</tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td>" + Html(DataHora(row["dt_cad"])) + "</td>");
            html.Append("<td><span class=\"patio-bi-pill\">#" + Html(row["ve_nr"]) + "</span></td>");
            html.Append("<td>" + Html(row["loja"]) + "</td>");
            html.Append("<td>" + Html(row["usuario"]) + "</td>");
            html.Append("</tr>");
        }
        html.Append("</tbody></table>");
        return html.ToString();
    }

    private void GarantirIndicesRelatorio()
    {
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_dt_cad_bi' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_dt_cad_bi ON dbo.veiculos_patio_locacao(dt_cad) INCLUDE (ve_nr, loja_id, loja_atual_id, fun_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_loja_bi' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_loja_bi ON dbo.veiculos_patio_locacao(loja_atual_id, loja_id) INCLUDE (ve_nr, dt_cad, fun_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_transferencia_dt_bi' AND object_id = OBJECT_ID('dbo.veiculos_patio_transferencia'))
BEGIN
    CREATE INDEX IX_veiculos_patio_transferencia_dt_bi ON dbo.veiculos_patio_transferencia(dt_transf DESC) INCLUDE (ve_nr, loja_orig, loja_dest, fun_cad);
END;", banco.oCon2);
            cmd.CommandTimeout = 20;
            cmd.ExecuteNonQuery();
        }
        catch (Exception ex)
        {
            PatioJeepAuditoria.Registrar("RELATORIO_INDICE_ERRO", Session["usuario"], "BI", ex.Message);
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private string Numero(DataRow row, string coluna)
    {
        if (row == null || row[coluna] == DBNull.Value)
        {
            return "0";
        }

        return Inteiro(row[coluna]).ToString("N0");
    }

    private int Inteiro(object valor)
    {
        if (valor == null || valor == DBNull.Value)
        {
            return 0;
        }

        int numero;
        return Int32.TryParse(valor.ToString(), out numero) ? numero : 0;
    }

    private string DataCurta(DataRow row, string coluna)
    {
        if (row == null || row[coluna] == DBNull.Value)
        {
            return "-";
        }

        DateTime data;
        return DateTime.TryParse(row[coluna].ToString(), out data) ? data.ToString("dd/MM HH:mm") : Convert.ToString(row[coluna]);
    }

    private string DataHora(object valor)
    {
        if (valor == null || valor == DBNull.Value)
        {
            return "-";
        }

        DateTime data;
        return DateTime.TryParse(valor.ToString(), out data) ? data.ToString("dd/MM/yyyy HH:mm") : Convert.ToString(valor);
    }

    private string Html(object valor)
    {
        return HttpUtility.HtmlEncode(Convert.ToString(valor));
    }
}
