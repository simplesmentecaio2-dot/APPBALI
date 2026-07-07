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
using System.Text;
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
            litBuscaMensagem.Text = "<div class=\"patio-home-message is-warning\"><i class=\"fa fa-info-circle\"></i><span>Digite s&eacute;rie, chassi, placa, Renavam ou c&oacute;digo antes de buscar.</span></div>";
            RenderizarIndicadores();
            return;
        }

        Response.Redirect("./novos.aspx?buscar=" + Server.UrlEncode(busca), false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void RenderizarIndicadores()
    {
        string cacheKey = "patio_home_indicadores_v4";
        object cache = HttpRuntime.Cache[cacheKey];
        if (cache != null)
        {
            litHomeIndicadores.Text = Convert.ToString(cache);
            return;
        }

        try
        {
            DataTable resumo = ConsultarTabela(@"
WITH ativos AS
(
    SELECT
        'NOVO' AS tipo,
        p.ve_nr AS referencia,
        COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) AS loja_id,
        COALESCE(t.ultima_transferencia, p.dt_cad) AS ultima_movimentacao
    FROM dbo.veiculos_patio_locacao p WITH (NOLOCK)
    OUTER APPLY
    (
        SELECT MAX(dt_transf) AS ultima_transferencia
        FROM dbo.veiculos_patio_transferencia WITH (NOLOCK)
        WHERE ve_nr = p.ve_nr
    ) t
    WHERE p.baixado_venda = 0

    UNION ALL

    SELECT
        'SEMINOVO' AS tipo,
        CONVERT(varchar(30), s.id) AS referencia,
        COALESCE(NULLIF(s.loja_atual_id, 0), s.loja_id) AS loja_id,
        COALESCE(t.ultima_transferencia, s.dt_cad) AS ultima_movimentacao
    FROM dbo.veiculos_patio_seminovos_locacao s WITH (NOLOCK)
    OUTER APPLY
    (
        SELECT MAX(dt_transf) AS ultima_transferencia
        FROM dbo.veiculos_patio_seminovos_transferencia WITH (NOLOCK)
        WHERE seminovo_id = s.id
    ) t
    WHERE s.ativo = 1
)
SELECT
    (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE baixado_venda = 0) AS novos_ativos,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_seminovos_locacao WITH (NOLOCK) WHERE ativo = 1) AS seminovos_ativos,
    (SELECT COUNT(1) FROM ativos WHERE DATEDIFF(day, ultima_movimentacao, GETDATE()) >= 15) AS parados_15,
    (SELECT COUNT(1) FROM ativos WHERE DATEDIFF(day, ultima_movimentacao, GETDATE()) >= 30) AS parados_30,
    (SELECT COUNT(1) FROM ativos WHERE ISNULL(loja_id, 0) = 0) AS sem_loja,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE baixado_venda = 0 AND dt_cad >= CONVERT(date, GETDATE())) +
    (SELECT COUNT(1) FROM dbo.veiculos_patio_seminovos_locacao WITH (NOLOCK) WHERE ativo = 1 AND dt_cad >= CONVERT(date, GETDATE())) AS entradas_hoje,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_transferencia WITH (NOLOCK) WHERE dt_transf >= CONVERT(date, GETDATE())) +
    (SELECT COUNT(1) FROM dbo.veiculos_patio_seminovos_transferencia WITH (NOLOCK) WHERE dt_transf >= CONVERT(date, GETDATE())) AS transferencias_hoje,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE dt_baixa_manual >= CONVERT(date, GETDATE()) OR dt_baixa_venda >= CONVERT(date, GETDATE())) +
    (SELECT COUNT(1) FROM dbo.veiculos_patio_seminovos_locacao WITH (NOLOCK) WHERE dt_baixa_manual >= CONVERT(date, GETDATE())) AS baixas_hoje,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_auditoria_geral WITH (NOLOCK) WHERE dt >= CONVERT(date, GETDATE())) AS eventos_hoje;");

            DataTable atividades = ConsultarTabela(@"
SELECT TOP 8
    dt,
    ISNULL(usuario, '-') AS usuario,
    ISNULL(acao, '-') AS acao,
    ISNULL(origem, '-') AS origem,
    ISNULL(ve_nr, '-') AS referencia
FROM dbo.veiculos_patio_auditoria_geral WITH (NOLOCK)
ORDER BY dt DESC;");

            DataRow row = resumo.Rows.Count > 0 ? resumo.Rows[0] : null;
            string html = RenderResumo(row) + RenderAlertas(row) + RenderAtividades(atividades);
            litHomeIndicadores.Text = html;
            HttpRuntime.Cache.Insert(cacheKey, html, null, DateTime.Now.AddSeconds(60), System.Web.Caching.Cache.NoSlidingExpiration);
        }
        catch
        {
            litHomeIndicadores.Text = "<div class=\"patio-home-message is-warning\"><i class=\"fa fa-exclamation-triangle\"></i><span>N&atilde;o foi poss&iacute;vel carregar o resumo agora. Use as fun&ccedil;&otilde;es abaixo normalmente.</span></div>";
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

    private string RenderResumo(DataRow row)
    {
        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"patio-home-insights\">");
        html.Append("<div class=\"patio-section-heading\"><span><small>Resumo operacional</small><strong>Vis&atilde;o geral do p&aacute;tio</strong></span><em>Atualizado automaticamente por per&iacute;odo curto.</em></div>");
        html.Append("<div class=\"patio-home-dashboard\">");
        html.Append(CardResumo("Novos ativos", Valor(row, "novos_ativos"), "Ve&iacute;culos novos no p&aacute;tio", "fa-car", "is-main"));
        html.Append(CardResumo("Seminovos ativos", Valor(row, "seminovos_ativos"), "Seminovos no p&aacute;tio", "fa-car-side", "is-main"));
        html.Append(CardResumo("Parados 15+", Valor(row, "parados_15"), "Aten&ccedil;&atilde;o operacional", "fa-hourglass-half", "is-warning"));
        html.Append(CardResumo("Transfer&ecirc;ncias hoje", Valor(row, "transferencias_hoje"), "Movimenta&ccedil;&otilde;es do dia", "fa-exchange-alt", "is-info"));
        html.Append(CardResumo("Baixas hoje", Valor(row, "baixas_hoje"), "Manuais ou por venda", "fa-check-circle", "is-ok"));
        html.Append(CardResumo("Eventos hoje", Valor(row, "eventos_hoje"), "Auditoria registrada", "fa-shield-alt", "is-muted"));
        html.Append("</div>");
        html.Append("</div>");
        return html.ToString();
    }

    private string CardResumo(string titulo, string valor, string detalhe, string icone, string classe)
    {
        return "<div class=\"patio-dashboard-card " + classe + "\"><span class=\"patio-dashboard-icon\"><i class=\"fa " + icone + "\"></i></span><div class=\"patio-dashboard-content\"><small>" + titulo + "</small><strong>" + Html(valor) + "</strong><em>" + detalhe + "</em></div></div>";
    }

    private string RenderAlertas(DataRow row)
    {
        int parados30 = Inteiro(row, "parados_30");
        int semLoja = Inteiro(row, "sem_loja");
        int parados15 = Inteiro(row, "parados_15");

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"patio-attention-panel\"><div class=\"patio-section-heading is-compact\"><span><small>Aten&ccedil;&atilde;o</small><strong>Pontos para conferir</strong></span><em>Alertas gerados pelos dados atuais do p&aacute;tio.</em></div><div class=\"patio-attention-list\">");
        bool possuiAlerta = false;

        if (parados30 > 0)
        {
            possuiAlerta = true;
            html.Append(Alerta("Parados 30+", parados30.ToString(), "Priorize confer&ecirc;ncia de loja e movimenta&ccedil;&atilde;o.", "is-danger"));
        }
        if (parados15 > 0)
        {
            possuiAlerta = true;
            html.Append(Alerta("Parados 15+", parados15.ToString(), "Acompanhe ve&iacute;culos sem movimenta&ccedil;&atilde;o recente.", "is-warning"));
        }
        if (semLoja > 0)
        {
            possuiAlerta = true;
            html.Append(Alerta("Sem loja", semLoja.ToString(), "Corrija a localiza&ccedil;&atilde;o para evitar perda operacional.", "is-warning"));
        }
        if (!possuiAlerta)
        {
            html.Append("<span class=\"patio-alert-card is-ok\"><i class=\"fa fa-check-circle\"></i><span><strong>Tudo certo</strong><small>Nenhum alerta cr&iacute;tico agora.</small></span></span>");
        }

        html.Append("</div></div>");
        return html.ToString();
    }

    private string Alerta(string titulo, string valor, string detalhe, string classe)
    {
        return "<span class=\"patio-alert-card " + classe + "\"><b>" + Html(valor) + "</b><span><strong>" + titulo + "</strong><small>" + detalhe + "</small></span></span>";
    }

    private string RenderAtividades(DataTable tabela)
    {
        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"patio-home-activity\"><div class=\"patio-home-activity-title\"><span><small>&Uacute;ltimas a&ccedil;&otilde;es</small><strong>Auditoria recente do p&aacute;tio</strong></span><a href=\"auditoria.aspx\"><i class=\"fa fa-shield-alt\"></i>Ver auditoria</a></div>");
        if (tabela == null || tabela.Rows.Count == 0)
        {
            html.Append("<div class=\"patio-home-empty\"><i class=\"fa fa-inbox\"></i><span><strong>Nenhuma movimenta&ccedil;&atilde;o recente encontrada.</strong><small>Assim que houver uma a&ccedil;&atilde;o auditada, ela aparecer&aacute; aqui.</small></span></div>");
        }
        else
        {
            html.Append("<div class=\"patio-home-activity-list\">");
            foreach (DataRow row in tabela.Rows)
            {
                html.Append("<div class=\"patio-home-activity-item\"><i class=\"fa fa-history\"></i><span><b>")
                    .Append(Html(Valor(row, "acao")))
                    .Append("</b><small>")
                    .Append(Html(Valor(row, "origem")))
                    .Append(" &middot; Ref. ")
                    .Append(Html(Valor(row, "referencia")))
                    .Append(" &middot; ")
                    .Append(Html(Valor(row, "usuario")))
                    .Append("</small></span><time>")
                    .Append(Html(DataHora(row, "dt")))
                    .Append("</time></div>");
            }
            html.Append("</div>");
        }
        html.Append("</div>");
        return html.ToString();
    }

    private string Valor(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value)
        {
            return "0";
        }

        return Convert.ToString(row[coluna]);
    }

    private int Inteiro(DataRow row, string coluna)
    {
        int valor;
        return Int32.TryParse(Valor(row, coluna), out valor) ? valor : 0;
    }

    private string DataHora(DataRow row, string coluna)
    {
        DateTime data;
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value || !DateTime.TryParse(Convert.ToString(row[coluna]), out data))
        {
            return "-";
        }
        return data.ToString("dd/MM HH:mm");
    }

    private string Html(string valor)
    {
        return HttpUtility.HtmlEncode(valor ?? "");
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
