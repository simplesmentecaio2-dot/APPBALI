using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;

public static class PatioJeepAuditoria
{
    private static readonly object ArquivoLock = new object();

    public static void Registrar(string acao, object usuario, object serie, string detalhes)
    {
        try
        {
            HttpContext contexto = HttpContext.Current;
            if (contexto == null)
            {
                return;
            }

            string pasta = contexto.Server.MapPath("~/App_Data");
            Directory.CreateDirectory(pasta);

            string linha = String.Join("\t", new string[]
            {
                DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
                Limpar(acao),
                Limpar(usuario),
                Limpar(serie),
                Limpar(detalhes),
                Limpar(contexto.Request.UserHostAddress),
                Limpar(contexto.Request.RawUrl)
            });

            lock (ArquivoLock)
            {
                File.AppendAllText(Path.Combine(pasta, "patio-jeep-auditoria.log"), linha + Environment.NewLine, Encoding.UTF8);
            }

            RegistrarBanco(
                Limpar(acao),
                Limpar(usuario),
                Limpar(serie),
                Limpar(detalhes),
                Limpar(contexto.Request.UserHostAddress),
                Limpar(contexto.Request.RawUrl));
        }
        catch
        {
        }
    }

    private static void RegistrarBanco(string acao, string usuario, string serie, string detalhes, string ip, string url)
    {
        try
        {
            Jeep banco = new Jeep();
            try
            {
                banco.Conexao2();
                using (SqlCommand cmd = new SqlCommand("dbo.veiculos_patio_auditoria_registrar", banco.oCon2))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 10;
                    cmd.Parameters.Add("@origem", SqlDbType.VarChar, 20).Value = Origem(acao);
                    cmd.Parameters.Add("@ve_nr", SqlDbType.VarChar, 50).Value = serie == "-" ? (object)DBNull.Value : serie;
                    cmd.Parameters.Add("@acao", SqlDbType.VarChar, 80).Value = acao;
                    cmd.Parameters.Add("@usuario", SqlDbType.VarChar, 100).Value = usuario == "-" ? (object)DBNull.Value : usuario;
                    cmd.Parameters.Add("@detalhe", SqlDbType.VarChar, 1000).Value = detalhes == "-" ? (object)DBNull.Value : detalhes;
                    cmd.Parameters.Add("@ip", SqlDbType.VarChar, 60).Value = ip == "-" ? (object)DBNull.Value : ip;
                    cmd.Parameters.Add("@url", SqlDbType.VarChar, 300).Value = url == "-" ? (object)DBNull.Value : url;
                    cmd.ExecuteNonQuery();
                }
            }
            finally
            {
                banco.FecharConexao2();
            }
        }
        catch
        {
        }
    }

    private static string Origem(string acao)
    {
        if (String.IsNullOrWhiteSpace(acao)) return "GERAL";
        string texto = acao.ToUpperInvariant();
        if (texto.IndexOf("SEMINOVO") >= 0) return "SEMINOVO";
        if (texto.IndexOf("NOVO") >= 0 || texto.IndexOf("REGISTRAR") >= 0 || texto.IndexOf("TRANSFERIR") >= 0) return "NOVO";
        if (texto.IndexOf("LOJA") >= 0) return "LOJA";
        return "GERAL";
    }

    private static string Limpar(object valor)
    {
        string texto = Convert.ToString(valor);
        if (String.IsNullOrWhiteSpace(texto))
        {
            return "-";
        }

        return texto.Replace("\r", " ").Replace("\n", " ").Replace("\t", " ").Trim();
    }
}
