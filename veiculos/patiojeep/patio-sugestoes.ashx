<%@ WebHandler Language="C#" Class="PatioSugestoesHandler" %>

using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.SessionState;

public class PatioSugestoesHandler : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.ContentEncoding = Encoding.UTF8;

        if (context.Session == null || context.Session["id"] == null)
        {
            context.Response.StatusCode = 401;
            context.Response.Write("[]");
            return;
        }

        string busca = Normalizar(context.Request.QueryString["q"]);
        if (busca.Length < 3)
        {
            context.Response.Write("[]");
            return;
        }

        DataTable tabela = Consultar(busca);
        context.Response.Write(Json(tabela));
    }

    public bool IsReusable
    {
        get { return false; }
    }

    private DataTable Consultar(string busca)
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            using (SqlCommand cmd = new SqlCommand(@"
;WITH base AS
(
    SELECT
        'NOVO' AS tipo,
        CONVERT(varchar(50), p.ve_nr) AS veNr,
        COALESCE(m.ModeloVeiculo_Descricao, 'Veiculo novo') AS modelo,
        COALESCE(v.Veiculo_Chassi, '') AS chassi,
        COALESCE(lj.ds, 'Sem loja') AS loja,
        p.dt_cad AS ordenacao
    FROM dbo.veiculos_patio_locacao p WITH (NOLOCK)
    LEFT JOIN GrupoBali_DealernetWF..Veiculo v WITH (NOLOCK)
        ON ISNUMERIC(p.ve_nr) = 1 AND CAST(p.ve_nr AS int) = v.Veiculo_Codigo
    LEFT JOIN GrupoBali_DealernetWF..ModeloVeiculo m WITH (NOLOCK)
        ON m.ModeloVeiculo_Codigo = v.Veiculo_ModeloVeiculoCod
    LEFT JOIN dbo.veiculos_patio_loja lj WITH (NOLOCK)
        ON lj.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
    WHERE ISNULL(p.baixado_venda, 0) = 0
      AND (
            CONVERT(varchar(50), p.ve_nr) = @busca
         OR RIGHT('0000000' + CONVERT(varchar(50), p.ve_nr), 7) = @busca
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(v.Veiculo_Chassi, '')), '-', ''), ' ', ''), '.', '') LIKE @buscaLike
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(v.Veiculo_Placa, '')), '-', ''), ' ', ''), '.', '') LIKE @buscaLike
         OR UPPER(ISNULL(m.ModeloVeiculo_Descricao, '')) LIKE @textoLike
         OR UPPER(ISNULL(lj.ds, '')) LIKE @textoLike
      )

    UNION ALL

    SELECT
        'SEMINOVO' AS tipo,
        CONVERT(varchar(50), s.id) AS veNr,
        ISNULL(s.ve_ds, 'Seminovo') AS modelo,
        ISNULL(s.ve_chassi, '') AS chassi,
        COALESCE(lj.ds, 'Sem loja') AS loja,
        s.dt_cad AS ordenacao
    FROM dbo.veiculos_patio_seminovos_locacao s WITH (NOLOCK)
    LEFT JOIN dbo.veiculos_patio_loja lj WITH (NOLOCK)
        ON lj.id = COALESCE(NULLIF(s.loja_atual_id, 0), s.loja_id)
    WHERE ISNULL(s.ativo, 1) = 1
      AND (
            CONVERT(varchar(50), s.id) = @busca
         OR CONVERT(varchar(50), s.ve_nr) = @busca
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(s.ve_chassi, '')), '-', ''), ' ', ''), '.', '') LIKE @buscaLike
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(s.ve_placa, '')), '-', ''), ' ', ''), '.', '') LIKE @buscaLike
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(s.ve_renavam, '')), '-', ''), ' ', ''), '.', '') LIKE @buscaLike
         OR UPPER(ISNULL(s.ve_ds, '')) LIKE @textoLike
         OR UPPER(ISNULL(lj.ds, '')) LIKE @textoLike
      )
)
SELECT TOP 8 tipo, veNr, modelo, chassi, loja
FROM base
ORDER BY ordenacao DESC;", banco.oCon2))
            {
                cmd.CommandTimeout = 12;
                cmd.Parameters.Add("@busca", SqlDbType.VarChar, 80).Value = busca;
                cmd.Parameters.Add("@buscaLike", SqlDbType.VarChar, 90).Value = "%" + busca + "%";
                cmd.Parameters.Add("@textoLike", SqlDbType.VarChar, 120).Value = "%" + busca + "%";
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd)) adapter.Fill(tabela);
            }
        }
        finally
        {
            banco.FecharConexao2();
        }
        return tabela;
    }

    private string Json(DataTable tabela)
    {
        StringBuilder json = new StringBuilder();
        json.Append("[");
        for (int i = 0; i < tabela.Rows.Count; i++)
        {
            if (i > 0) json.Append(",");
            DataRow row = tabela.Rows[i];
            json.Append("{");
            json.Append("\"tipo\":\"").Append(Escape(row, "tipo")).Append("\",");
            json.Append("\"veNr\":\"").Append(Escape(row, "veNr")).Append("\",");
            json.Append("\"modelo\":\"").Append(Escape(row, "modelo")).Append("\",");
            json.Append("\"chassi\":\"").Append(Escape(row, "chassi")).Append("\",");
            json.Append("\"loja\":\"").Append(Escape(row, "loja")).Append("\"");
            json.Append("}");
        }
        json.Append("]");
        return json.ToString();
    }

    private string Escape(DataRow row, string coluna)
    {
        string valor = row.Table.Columns.Contains(coluna) && row[coluna] != DBNull.Value ? Convert.ToString(row[coluna]) : "";
        return HttpUtility.JavaScriptStringEncode(valor);
    }

    private string Normalizar(string valor)
    {
        valor = (valor ?? "").Trim().ToUpperInvariant();
        StringBuilder limpo = new StringBuilder();
        foreach (char caractere in valor)
        {
            if (Char.IsLetterOrDigit(caractere)) limpo.Append(caractere);
            else if (Char.IsWhiteSpace(caractere)) limpo.Append(' ');
        }
        return limpo.ToString();
    }
}
