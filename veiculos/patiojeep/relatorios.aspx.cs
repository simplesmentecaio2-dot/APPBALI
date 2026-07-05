using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;

public partial class veiculos_patio_relatorios : System.Web.UI.Page
{
    private static readonly object EstruturaRelatorioLock = new object();
    private static bool EstruturaRelatorioVerificada = false;

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
            CarregarRelatorio(false);
        }
    }

    protected void btnAtualizar_Click(object sender, EventArgs e)
    {
        CarregarRelatorio(true);
    }

    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Session.Abandon();
        Response.Redirect("./login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void CarregarRelatorio(bool sincronizarBaixas)
    {
        GarantirEstruturaRelatorio();
        DataRow sincronizacao = sincronizarBaixas ? SincronizarBaixasVenda() : null;
        RenderizarStatusBaixa(sincronizacao, sincronizarBaixas);

        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();

            DataTable resumo = Consultar(banco.oCon2, @"
SELECT
    SUM(CASE WHEN baixado_venda = 0 THEN 1 ELSE 0 END) AS total_patio,
    COUNT(DISTINCT CASE WHEN baixado_venda = 0 THEN COALESCE(NULLIF(loja_atual_id, 0), loja_id) END) AS lojas_com_veiculos,
    SUM(CASE WHEN baixado_venda = 0 AND dt_cad >= CONVERT(date, GETDATE()) THEN 1 ELSE 0 END) AS entradas_hoje,
    SUM(CASE WHEN baixado_venda = 0 AND dt_cad >= DATEADD(day, -7, GETDATE()) THEN 1 ELSE 0 END) AS entradas_7_dias,
    MAX(CASE WHEN baixado_venda = 0 THEN dt_cad ELSE NULL END) AS ultima_entrada,
    SUM(CASE WHEN baixado_venda = 1 THEN 1 ELSE 0 END) AS baixados_venda,
    SUM(CASE WHEN baixado_venda = 1 AND dt_baixa_venda >= CONVERT(date, GETDATE()) THEN 1 ELSE 0 END) AS baixas_hoje
FROM dbo.veiculos_patio_locacao;");

            DataTable movimentosResumo = Consultar(banco.oCon2, @"
SELECT
    COUNT(1) AS movimentos_mes,
    MAX(t.dt_transf) AS ultima_movimentacao
FROM dbo.veiculos_patio_transferencia t
INNER JOIN dbo.veiculos_patio_locacao p
    ON p.ve_nr = t.ve_nr
   AND p.baixado_venda = 0
WHERE t.dt_transf >= DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0);");

            RenderizarResumo(resumo, movimentosResumo, sincronizacao);

            litEstoquePorLoja.Text = RenderizarBarras(Consultar(banco.oCon2, @"
SELECT TOP 12
    COALESCE(l.ds, 'Sem loja') AS label,
    COUNT(1) AS total
FROM dbo.veiculos_patio_locacao p
LEFT JOIN dbo.veiculos_patio_loja l
    ON l.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
WHERE p.baixado_venda = 0
GROUP BY COALESCE(l.ds, 'Sem loja')
ORDER BY COUNT(1) DESC, COALESCE(l.ds, 'Sem loja');"), "Nenhum ve&iacute;culo ativo no p&aacute;tio.");

            litEntradasDia.Text = RenderizarBarras(Consultar(banco.oCon2, @"
SELECT
    CONVERT(varchar(10), CONVERT(date, dt_cad), 103) AS label,
    COUNT(1) AS total
FROM dbo.veiculos_patio_locacao
WHERE baixado_venda = 0
  AND dt_cad >= DATEADD(day, -13, CONVERT(date, GETDATE()))
GROUP BY CONVERT(date, dt_cad)
ORDER BY CONVERT(date, dt_cad);"), "Nenhuma entrada ativa nos &uacute;ltimos 14 dias.");

            litMovimentacoesDia.Text = RenderizarBarras(Consultar(banco.oCon2, @"
SELECT
    CONVERT(varchar(10), CONVERT(date, t.dt_transf), 103) AS label,
    COUNT(1) AS total
FROM dbo.veiculos_patio_transferencia t
INNER JOIN dbo.veiculos_patio_locacao p
    ON p.ve_nr = t.ve_nr
   AND p.baixado_venda = 0
WHERE t.dt_transf >= DATEADD(day, -13, CONVERT(date, GETDATE()))
GROUP BY CONVERT(date, t.dt_transf)
ORDER BY CONVERT(date, t.dt_transf);"), "Nenhuma movimenta&ccedil;&atilde;o ativa nos &uacute;ltimos 14 dias.");

            litUsuarios.Text = RenderizarBarras(Consultar(banco.oCon2, @"
SELECT TOP 8
    COALESCE(NULLIF(LTRIM(RTRIM(fun_cad)), ''), 'Sem usuario') AS label,
    COUNT(1) AS total
FROM dbo.veiculos_patio_locacao
WHERE baixado_venda = 0
  AND dt_cad >= DATEADD(day, -30, GETDATE())
GROUP BY COALESCE(NULLIF(LTRIM(RTRIM(fun_cad)), ''), 'Sem usuario')
ORDER BY COUNT(1) DESC, COALESCE(NULLIF(LTRIM(RTRIM(fun_cad)), ''), 'Sem usuario');"), "Nenhuma entrada ativa nos &uacute;ltimos 30 dias.");

            litUltimasMovimentacoes.Text = RenderizarMovimentacoes(Consultar(banco.oCon2, @"
SELECT TOP 20
    t.dt_transf,
    t.ve_nr,
    COALESCE(orig.ds, '-') AS origem,
    COALESCE(dest.ds, '-') AS destino,
    COALESCE(NULLIF(LTRIM(RTRIM(t.fun_cad)), ''), '-') AS usuario
FROM dbo.veiculos_patio_transferencia t
INNER JOIN dbo.veiculos_patio_locacao p
    ON p.ve_nr = t.ve_nr
   AND p.baixado_venda = 0
LEFT JOIN dbo.veiculos_patio_loja orig ON orig.id = t.loja_orig
LEFT JOIN dbo.veiculos_patio_loja dest ON dest.id = t.loja_dest
ORDER BY t.dt_transf DESC, t.id DESC;"));

            litUltimosCadastros.Text = RenderizarCadastros(Consultar(banco.oCon2, @"
SELECT TOP 20
    p.dt_cad,
    p.ve_nr,
    COALESCE(l.ds, 'Sem loja') AS loja,
    COALESCE(NULLIF(LTRIM(RTRIM(p.fun_cad)), ''), '-') AS usuario
FROM dbo.veiculos_patio_locacao p
LEFT JOIN dbo.veiculos_patio_loja l
    ON l.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
WHERE p.baixado_venda = 0
ORDER BY p.dt_cad DESC, p.ve_nr DESC;"));

            litUltimasBaixas.Text = RenderizarBaixas(Consultar(banco.oCon2, @"
SELECT TOP 20
    p.dt_baixa_venda,
    p.ve_nr,
    p.chassi_baixa,
    COALESCE(l.ds, 'Sem loja') AS loja
FROM dbo.veiculos_patio_locacao p
LEFT JOIN dbo.veiculos_patio_loja l
    ON l.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
WHERE p.baixado_venda = 1
ORDER BY p.dt_baixa_venda DESC, p.ve_nr DESC;"));
        }
        catch (Exception ex)
        {
            PatioJeepAuditoria.Registrar("RELATORIO_BI_ERRO", Session["usuario"], "BI", ex.Message);
            RenderizarErroRelatorio();
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private DataTable Consultar(SqlConnection conexao, string sql)
    {
        DataTable tabela = new DataTable();
        SqlCommand cmd = new SqlCommand(sql, conexao);
        cmd.CommandTimeout = 30;
        SqlDataAdapter adapter = new SqlDataAdapter(cmd);
        adapter.Fill(tabela);

        return tabela;
    }

    private void RenderizarErroRelatorio()
    {
        litBaixaVendaStatus.Text = "<div class=\"patio-sync-status is-warning\"><i class=\"fa fa-exclamation-triangle\"></i><span>N&atilde;o foi poss&iacute;vel carregar o BI agora. Tente novamente em instantes.</span></div>";
        litResumo.Text = "";
        litEstoquePorLoja.Text = "<div class=\"patio-bi-empty\">Dados indispon&iacute;veis no momento.</div>";
        litEntradasDia.Text = "<div class=\"patio-bi-empty\">Dados indispon&iacute;veis no momento.</div>";
        litMovimentacoesDia.Text = "<div class=\"patio-bi-empty\">Dados indispon&iacute;veis no momento.</div>";
        litUsuarios.Text = "<div class=\"patio-bi-empty\">Dados indispon&iacute;veis no momento.</div>";
        litUltimasMovimentacoes.Text = "<div class=\"patio-bi-empty\">Dados indispon&iacute;veis no momento.</div>";
        litUltimosCadastros.Text = "<div class=\"patio-bi-empty\">Dados indispon&iacute;veis no momento.</div>";
        litUltimasBaixas.Text = "<div class=\"patio-bi-empty\">Dados indispon&iacute;veis no momento.</div>";
    }

    private DataRow SincronizarBaixasVenda()
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand("dbo.veiculos_patio_sincronizar_baixas_venda", banco.oCon2);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandTimeout = 60;
            cmd.Parameters.Add("@usuario", SqlDbType.VarChar, 100).Value = Convert.ToString(Session["usuario"]);
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            adapter.Fill(tabela);
        }
        catch (Exception ex)
        {
            PatioJeepAuditoria.Registrar("RELATORIO_BAIXA_VENDA_ERRO", Session["usuario"], "BI", ex.Message);
        }
        finally
        {
            banco.FecharConexao2();
        }

        return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
    }

    private void RenderizarResumo(DataTable resumo, DataTable movimentosResumo, DataRow sincronizacao)
    {
        DataRow r = resumo.Rows.Count > 0 ? resumo.Rows[0] : null;
        DataRow m = movimentosResumo.Rows.Count > 0 ? movimentosResumo.Rows[0] : null;

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"patio-bi-kpis\">");
        html.Append(CardKpi("Ve&iacute;culos no p&aacute;tio", Numero(r, "total_patio"), "ativos agora"));
        html.Append(CardKpi("Baixados por venda", Numero(r, "baixados_venda"), "fora do p&aacute;tio"));
        html.Append(CardKpi("Baixas hoje", Numero(r, "baixas_hoje"), "dados existentes"));
        html.Append(CardKpi("Lojas com ve&iacute;culos", Numero(r, "lojas_com_veiculos"), "lojas ativas ou usadas"));
        html.Append(CardKpi("Entradas hoje", Numero(r, "entradas_hoje"), "cadastros ativos"));
        html.Append(CardKpi("Entradas 7 dias", Numero(r, "entradas_7_dias"), "janela recente"));
        html.Append(CardKpi("Mov. no m&ecirc;s", Numero(m, "movimentos_mes"), "transfer&ecirc;ncias ativas"));
        html.Append(CardKpi("&Uacute;ltima entrada", DataCurta(r, "ultima_entrada"), "registro ativo mais recente"));
        if (sincronizacao != null)
        {
            html.Append(CardKpi("Baixados agora", Numero(sincronizacao, "baixados_agora"), "nesta atualiza&ccedil;&atilde;o"));
        }
        html.Append("</div>");
        litResumo.Text = html.ToString();
    }

    private void RenderizarStatusBaixa(DataRow sincronizacao, bool sincronizacaoSolicitada)
    {
        if (!sincronizacaoSolicitada)
        {
            litBaixaVendaStatus.Text = "<div class=\"patio-sync-status is-idle\"><i class=\"fa fa-info-circle\"></i><span>BI carregado com os dados existentes. Para conferir vendas e baixar ve&iacute;culos vendidos, clique em Atualizar.</span></div>";
            return;
        }

        if (sincronizacao == null)
        {
            litBaixaVendaStatus.Text = "<div class=\"patio-sync-status is-warning\"><i class=\"fa fa-exclamation-triangle\"></i><span>N&atilde;o foi poss&iacute;vel sincronizar baixas por venda agora. O BI permaneceu com os dados existentes.</span></div>";
            return;
        }

        int baixadosAgora = Inteiro(sincronizacao["baixados_agora"]);
        int ativos = Inteiro(sincronizacao["ativos_patio"]);
        int baixadosTotal = Inteiro(sincronizacao["baixados_total"]);
        string mensagem = baixadosAgora > 0
            ? baixadosAgora.ToString("N0") + " ve&iacute;culo(s) baixado(s) automaticamente por venda nesta atualiza&ccedil;&atilde;o."
            : "Vendas conferidas. Nenhuma baixa nova encontrada nesta atualiza&ccedil;&atilde;o.";

        litBaixaVendaStatus.Text = "<div class=\"patio-sync-status\"><i class=\"fa fa-check-circle\"></i><span>" + mensagem + "</span><strong>" + ativos.ToString("N0") + " ativos / " + baixadosTotal.ToString("N0") + " baixados</strong></div>";
    }

    private string CardKpi(string titulo, string valor, string legenda)
    {
        return "<div class=\"patio-bi-kpi\"><small>" + titulo + "</small><strong>" + Html(valor) + "</strong><span>" + legenda + "</span></div>";
    }

    private string RenderizarBarras(DataTable tabela, string vazio)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"patio-bi-empty\">" + vazio + "</div>";
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
            return "<div class=\"patio-bi-empty\">Nenhuma movimenta&ccedil;&atilde;o ativa registrada at&eacute; agora.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"table table-striped table-hover patio-bi-table\"><thead><tr>");
        html.Append("<th>Data</th><th>Ve&iacute;culo</th><th>Rota</th><th>Usu&aacute;rio</th>");
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
            return "<div class=\"patio-bi-empty\">Nenhum ve&iacute;culo ativo cadastrado no p&aacute;tio.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"table table-striped table-hover patio-bi-table\"><thead><tr>");
        html.Append("<th>Data</th><th>Ve&iacute;culo</th><th>Loja atual</th><th>Usu&aacute;rio</th>");
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

    private string RenderizarBaixas(DataTable tabela)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"patio-bi-empty\">Nenhuma baixa por venda registrada at&eacute; agora.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"table table-striped table-hover patio-bi-table\"><thead><tr>");
        html.Append("<th>Data da baixa</th><th>Ve&iacute;culo</th><th>Chassi</th><th>&Uacute;ltima loja</th>");
        html.Append("</tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td>" + Html(DataHora(row["dt_baixa_venda"])) + "</td>");
            html.Append("<td><span class=\"patio-bi-pill\">#" + Html(row["ve_nr"]) + "</span></td>");
            html.Append("<td>" + Html(row["chassi_baixa"]) + "</td>");
            html.Append("<td>" + Html(row["loja"]) + "</td>");
            html.Append("</tr>");
        }
        html.Append("</tbody></table>");
        return html.ToString();
    }

    private void GarantirEstruturaRelatorio()
    {
        if (EstruturaRelatorioVerificada)
        {
            return;
        }

        lock (EstruturaRelatorioLock)
        {
            if (EstruturaRelatorioVerificada)
            {
                return;
            }

            Jeep banco = new Jeep();
            try
            {
                banco.Conexao2();
                SqlCommand cmd = new SqlCommand(@"
IF COL_LENGTH('dbo.veiculos_patio_locacao', 'baixado_venda') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao ADD baixado_venda bit NOT NULL CONSTRAINT DF_veiculos_patio_locacao_baixado_venda DEFAULT (0) WITH VALUES;
END;

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'dt_baixa_venda') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao ADD dt_baixa_venda datetime NULL;
END;

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'chassi_baixa') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao ADD chassi_baixa varchar(30) NULL;
END;

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'baixa_origem') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao ADD baixa_origem varchar(50) NULL;
END;

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'baixa_observacao') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao ADD baixa_observacao varchar(200) NULL;
END;

IF OBJECT_ID('dbo.veiculos_patio_baixa_venda_log', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.veiculos_patio_baixa_venda_log
    (
        id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_veiculos_patio_baixa_venda_log PRIMARY KEY,
        ve_nr varchar(50) NOT NULL,
        chassi varchar(30) NULL,
        usuario varchar(100) NULL,
        origem varchar(50) NULL,
        observacao varchar(200) NULL,
        dt_baixa datetime NOT NULL CONSTRAINT DF_veiculos_patio_baixa_venda_log_dt DEFAULT (GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_dt_cad_bi' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_dt_cad_bi ON dbo.veiculos_patio_locacao(dt_cad) INCLUDE (ve_nr, loja_id, loja_atual_id, fun_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_loja_bi' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_loja_bi ON dbo.veiculos_patio_locacao(loja_atual_id, loja_id) INCLUDE (ve_nr, dt_cad, fun_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_baixa_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_baixa_dt ON dbo.veiculos_patio_locacao(baixado_venda, dt_cad) INCLUDE (ve_nr, loja_id, loja_atual_id, fun_cad, dt_baixa_venda, chassi_baixa);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_baixa_loja' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_baixa_loja ON dbo.veiculos_patio_locacao(baixado_venda, loja_atual_id, loja_id) INCLUDE (ve_nr, dt_cad, fun_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_transferencia_dt_bi' AND object_id = OBJECT_ID('dbo.veiculos_patio_transferencia'))
BEGIN
    CREATE INDEX IX_veiculos_patio_transferencia_dt_bi ON dbo.veiculos_patio_transferencia(dt_transf DESC) INCLUDE (ve_nr, loja_orig, loja_dest, fun_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_baixa_venda_log_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_baixa_venda_log'))
BEGIN
    CREATE INDEX IX_veiculos_patio_baixa_venda_log_dt ON dbo.veiculos_patio_baixa_venda_log(dt_baixa DESC) INCLUDE (ve_nr, chassi, usuario, origem);
END;", banco.oCon2);
                cmd.CommandTimeout = 30;
                cmd.ExecuteNonQuery();
                EstruturaRelatorioVerificada = true;
            }
            catch (Exception ex)
            {
                PatioJeepAuditoria.Registrar("RELATORIO_ESTRUTURA_ERRO", Session["usuario"], "BI", ex.Message);
            }
            finally
            {
                banco.FecharConexao2();
            }
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
