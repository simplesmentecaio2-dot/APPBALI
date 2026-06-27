using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public static class ContratoAuditoria
{
    private const int TimeoutSqlSegundos = 45;

    private static string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString; }
    }

    public static void Registrar(string marca, string tipo, string contratoId, string usuarioId, string usuarioNome, string ip, string url, string acao, string detalhe, string dadosAntes, string dadosDepois)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand("dbo.contrato_auditoria_registrar", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = TimeoutSqlSegundos;
                cmd.Parameters.Add("@marca", SqlDbType.NVarChar, 30).Value = ValorBanco(marca);
                cmd.Parameters.Add("@tipo", SqlDbType.NVarChar, 10).Value = ValorBanco(tipo);
                cmd.Parameters.Add("@contrato_id", SqlDbType.NVarChar, 40).Value = ValorBanco(contratoId);
                cmd.Parameters.Add("@usuario_id", SqlDbType.NVarChar, 80).Value = ValorBanco(usuarioId);
                cmd.Parameters.Add("@usuario_nome", SqlDbType.NVarChar, 160).Value = ValorBanco(usuarioNome);
                cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 80).Value = ValorBanco(ip);
                cmd.Parameters.Add("@url", SqlDbType.NVarChar, 500).Value = ValorBanco(url);
                cmd.Parameters.Add("@acao", SqlDbType.NVarChar, 100).Value = ValorBanco(acao);
                cmd.Parameters.Add("@detalhe", SqlDbType.NVarChar).Value = ValorBanco(Limitar(detalhe, 12000));
                cmd.Parameters.Add("@dados_antes", SqlDbType.NVarChar).Value = ValorBanco(Limitar(dadosAntes, 12000));
                cmd.Parameters.Add("@dados_depois", SqlDbType.NVarChar).Value = ValorBanco(Limitar(dadosDepois, 12000));
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
        }
    }

    public static DataTable Listar(string marca, string contratoId, string tipo)
    {
        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand("dbo.contrato_auditoria_listar", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add("@marca", SqlDbType.NVarChar, 30).Value = ValorBanco(marca);
            cmd.Parameters.Add("@contrato_id", SqlDbType.NVarChar, 40).Value = ValorBanco(contratoId);
            cmd.Parameters.Add("@tipo", SqlDbType.NVarChar, 10).Value = ValorBanco(tipo);

            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    public static string ExtrairCampoDetalhe(string detalhe, string campo)
    {
        if (String.IsNullOrWhiteSpace(detalhe) || String.IsNullOrWhiteSpace(campo)) return "";
        string prefixo = campo.Trim() + "=";
        string[] partes = detalhe.Split(';');
        foreach (string parte in partes)
        {
            string texto = (parte ?? "").Trim();
            if (texto.StartsWith(prefixo, StringComparison.OrdinalIgnoreCase))
            {
                return texto.Substring(prefixo.Length).Trim();
            }
        }

        return "";
    }

    public static string Limitar(string valor, int maximo)
    {
        string texto = (valor ?? "").Replace("\r", " ").Replace("\n", " ").Replace("\t", " ").Trim();
        while (texto.Contains("  "))
        {
            texto = texto.Replace("  ", " ");
        }

        return texto.Length > maximo ? texto.Substring(0, maximo) + "...(truncado)" : texto;
    }

    private static object ValorBanco(string valor)
    {
        string texto = (valor ?? "").Trim();
        return texto.Length == 0 ? (object)DBNull.Value : texto;
    }
}
