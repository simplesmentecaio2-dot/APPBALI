<%@ WebHandler Language="C#" Class="SeminovosHistoricoHandler" %>

using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.SessionState;

public class SeminovosHistoricoHandler : IHttpHandler, IRequiresSessionState
{
    public bool IsReusable
    {
        get { return false; }
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/html; charset=utf-8";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        context.Response.Cache.SetNoStore();

        if (context.Session == null || context.Session["id"] == null)
        {
            context.Response.StatusCode = 401;
            context.Response.Write("<div class=\"semi-empty\">Sess&atilde;o expirada. Entre novamente para consultar o hist&oacute;rico.</div>");
            return;
        }

        int id;
        if (!Int32.TryParse(context.Request.QueryString["id"], out id) || id <= 0)
        {
            context.Response.StatusCode = 400;
            context.Response.Write("<div class=\"semi-empty\">Seminovo inv&aacute;lido para consulta.</div>");
            return;
        }

        try
        {
            context.Response.Write(RenderHistorico(id));
        }
        catch
        {
            context.Response.StatusCode = 500;
            context.Response.Write("<div class=\"semi-empty\">N&atilde;o foi poss&iacute;vel carregar o hist&oacute;rico agora.</div>");
        }
    }

    private string RenderHistorico(int id)
    {
        DataRow veiculo = LocalizarSeminovo(id);
        if (veiculo == null)
        {
            return "<div class=\"semi-empty\">Seminovo n&atilde;o encontrado ou inativo.</div>";
        }

        DataTable historico = ExecutarProcedureTabela("dbo.veiculos_patio_seminovos_historico", Param("@seminovo_id", SqlDbType.Int, id));
        DataTable auditoria = ListarAuditoria(veiculo);

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"semi-detail-panel\" style=\"margin-top:0;\">");
        html.Append("<div class=\"semi-detail-header\"><div><small>Localiza&ccedil;&atilde;o atual</small><strong>")
            .Append(Html(Valor(veiculo, "ve_ds")))
            .Append("</strong><span>Cadastro em ")
            .Append(Html(DataCurta(veiculo, "dt_cad")))
            .Append(" por ")
            .Append(Html(Valor(veiculo, "fun_cad")))
            .Append("</span></div><span class=\"semi-location-pill\"><i class=\"fa fa-map-marker-alt\"></i>")
            .Append(Html(Valor(veiculo, "loja_atual")))
            .Append("</span></div>");

        html.Append("<div class=\"semi-pill-list\">");
        html.Append(Pill("C&oacute;digo", Valor(veiculo, "ve_nr")));
        html.Append(Pill("Chassi", Valor(veiculo, "ve_chassi")));
        html.Append(Pill("Placa", Valor(veiculo, "ve_placa")));
        html.Append(Pill("Renavam", Valor(veiculo, "ve_renavam")));
        html.Append(Pill("Cor", Valor(veiculo, "cor_ds")));
        html.Append(StatusBadge(Valor(veiculo, "status_operacional")));
        html.Append(Pill("Parado", Valor(veiculo, "dias_parado") + " dia(s)"));
        html.Append(Pill("&Uacute;ltima mov.", DataCurta(veiculo, "ultima_movimentacao")));
        html.Append("</div>");

        html.Append("<div class=\"semi-actions\">");
        html.Append("<a class=\"semi-btn semi-btn-light\" href=\"seminovos.aspx?aba=transferir&amp;busca=")
            .Append(HttpUtility.UrlEncode(Valor(veiculo, "ve_chassi")))
            .Append("\"><i class=\"fa fa-exchange-alt\"></i>Transferir este carro</a>");
        html.Append("<a class=\"semi-btn semi-btn-light\" href=\"seminovos.aspx?aba=operacional&amp;operBusca=")
            .Append(HttpUtility.UrlEncode(Valor(veiculo, "id")))
            .Append("\"><i class=\"fa fa-tools\"></i>Operar</a>");
        html.Append("</div>");

        html.Append("<div class=\"semi-history-title\"><span><i class=\"fa fa-route\"></i> Hist&oacute;rico de transfer&ecirc;ncias</span></div>");
        html.Append(RenderTabelaHistorico(historico));
        html.Append("<div class=\"semi-history-title\"><span><i class=\"fa fa-shield-alt\"></i> Auditoria recente</span></div>");
        html.Append(RenderTabelaAuditoria(auditoria));
        html.Append("</div>");
        return html.ToString();
    }

    private DataRow LocalizarSeminovo(int id)
    {
        DataTable tabela = ExecutarSqlTabela(@"
SELECT TOP 1
    p.id,
    p.ve_nr,
    p.ve_ds,
    p.ve_chassi,
    p.ve_placa,
    p.ve_renavam,
    p.cor_ds,
    p.numeronf,
    COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) AS loja_atual_id,
    COALESCE(l.ds, 'Sem loja') AS loja_atual,
    p.fun_cad,
    p.dt_cad,
    p.observacao,
    ISNULL(p.status_operacional, 'NO_PATIO') AS status_operacional,
    COALESCE((SELECT MAX(t.dt_transf) FROM dbo.veiculos_patio_seminovos_transferencia t WITH (NOLOCK) WHERE t.seminovo_id = p.id), p.dt_cad) AS ultima_movimentacao,
    DATEDIFF(day, COALESCE((SELECT MAX(t.dt_transf) FROM dbo.veiculos_patio_seminovos_transferencia t WITH (NOLOCK) WHERE t.seminovo_id = p.id), p.dt_cad), GETDATE()) AS dias_parado
FROM dbo.veiculos_patio_seminovos_locacao p WITH (NOLOCK)
LEFT JOIN dbo.veiculos_patio_loja l WITH (NOLOCK)
    ON l.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
WHERE p.ativo = 1
  AND p.id = @id;",
            Param("@id", SqlDbType.Int, id));

        return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
    }

    private DataTable ListarAuditoria(DataRow row)
    {
        string id = Valor(row, "id");
        string veNr = Valor(row, "ve_nr");
        string chassi = Valor(row, "ve_chassi");
        string placa = Valor(row, "ve_placa");
        string renavam = Valor(row, "ve_renavam");

        return ExecutarSqlTabela(@"
SELECT TOP 20 dt, acao, usuario, ve_nr, referencia, detalhe, ip
FROM dbo.veiculos_patio_seminovos_auditoria WITH (NOLOCK)
WHERE CONVERT(varchar(20), ISNULL(ve_nr, 0)) = @ve_nr
   OR referencia IN (@id, @ve_nr, @chassi, @placa, @renavam)
   OR detalhe LIKE @seminovoIdLike
ORDER BY dt DESC, id DESC;",
            Param("@id", SqlDbType.VarChar, id),
            Param("@ve_nr", SqlDbType.VarChar, veNr),
            Param("@chassi", SqlDbType.VarChar, chassi),
            Param("@placa", SqlDbType.VarChar, placa),
            Param("@renavam", SqlDbType.VarChar, renavam),
            Param("@seminovoIdLike", SqlDbType.VarChar, "%SeminovoId=" + id + "%"));
    }

    private string RenderTabelaHistorico(DataTable tabela)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"semi-empty\">Nenhuma movimenta&ccedil;&atilde;o registrada para este seminovo.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"semi-table-wrap\"><table class=\"semi-table\"><thead><tr><th>Data</th><th>Movimento</th><th>Origem</th><th>Destino</th><th>Usu&aacute;rio</th></tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td data-label=\"Data\">").Append(Html(DataCurta(row, "data_movimento"))).Append("</td>");
            html.Append("<td data-label=\"Movimento\">").Append(Html(Valor(row, "movimento"))).Append("</td>");
            html.Append("<td data-label=\"Origem\">").Append(Html(String.IsNullOrWhiteSpace(Valor(row, "origem")) ? "-" : Valor(row, "origem"))).Append("</td>");
            html.Append("<td data-label=\"Destino\"><span class=\"semi-location-pill\"><i class=\"fa fa-map-marker-alt\"></i>").Append(Html(Valor(row, "destino"))).Append("</span></td>");
            html.Append("<td data-label=\"Usu&aacute;rio\">").Append(Html(Valor(row, "fun_cad"))).Append("</td>");
            html.Append("</tr>");
        }
        html.Append("</tbody></table></div>");
        return html.ToString();
    }

    private string RenderTabelaAuditoria(DataTable tabela)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"semi-empty\">Nenhum evento de auditoria registrado para este seminovo.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"semi-table-wrap\"><table class=\"semi-table\"><thead><tr><th>Data</th><th>A&ccedil;&atilde;o</th><th>Usu&aacute;rio</th><th>Detalhe</th></tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td data-label=\"Data\">").Append(Html(DataCurta(row, "dt"))).Append("</td>");
            html.Append("<td data-label=\"A&ccedil;&atilde;o\">").Append(Html(Valor(row, "acao"))).Append("</td>");
            html.Append("<td data-label=\"Usu&aacute;rio\">").Append(Html(Valor(row, "usuario"))).Append("</td>");
            html.Append("<td data-label=\"Detalhe\">").Append(Html(Valor(row, "detalhe"))).Append("</td>");
            html.Append("</tr>");
        }
        html.Append("</tbody></table></div>");
        return html.ToString();
    }

    private DataTable ExecutarProcedureTabela(string procedure, params SqlParameter[] parametros)
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            using (SqlCommand cmd = new SqlCommand(procedure, banco.oCon2))
            {
                cmd.CommandType = CommandType.StoredProcedure;
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

    private string Pill(string label, string value)
    {
        return "<span class=\"semi-pill\"><b>" + label + "</b> " + Html(String.IsNullOrWhiteSpace(value) ? "-" : value) + "</span>";
    }

    private string StatusBadge(string status)
    {
        status = String.IsNullOrWhiteSpace(status) ? "NO_PATIO" : status.ToUpperInvariant();
        string classe = "semi-status";
        if (status == "BAIXADO" || status == "VENDIDO") classe += " is-baixado";
        else if (status == "PENDENTE" || status == "AGUARDANDO_RETIRADA" || status == "AGUARDANDO_DOCUMENTACAO") classe += " is-alerta";
        return "<span class=\"" + classe + "\">" + Html(StatusTexto(status)) + "</span>";
    }

    private string StatusTexto(string status)
    {
        status = (status ?? "").ToUpperInvariant();
        if (status == "PREPARACAO") return "Prepara\u00e7\u00e3o";
        if (status == "AGUARDANDO_DOCUMENTACAO") return "Aguardando documenta\u00e7\u00e3o";
        if (status == "AGUARDANDO_RETIRADA") return "Aguardando retirada";
        if (status == "PENDENTE") return "Pendente";
        if (status == "VENDIDO") return "Vendido";
        if (status == "BAIXADO") return "Baixado";
        return "No p\u00e1tio";
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
        return data.ToString("dd/MM/yyyy HH:mm");
    }

    private string Html(string valor)
    {
        return HttpUtility.HtmlEncode(valor ?? "");
    }
}
