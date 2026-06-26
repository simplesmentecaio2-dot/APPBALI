using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Web;

public class AppSenhaLocal
{
    private const int IteracoesPadrao = 120000;
    private const int TamanhoSalt = 32;
    private const int TamanhoHash = 32;

    private static string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString; }
    }

    public static bool ExisteSenhaLocalAtiva(string idUsuario)
    {
        string chave = ChaveUsuario(idUsuario);
        if (chave.Length == 0) return false;

        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
            SELECT COUNT(1)
            FROM dbo.appbali_senhas_locais
            WHERE id_usuario_chave = @id_usuario_chave
              AND ativo = 1;", con))
        {
            cmd.Parameters.Add("@id_usuario_chave", SqlDbType.NVarChar, 120).Value = chave;
            con.Open();
            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    public static bool ValidarSenha(string idUsuario, string senha)
    {
        RegistroSenhaLocal registro = ObterRegistro(idUsuario);
        if (registro == null || !registro.Ativo) return false;

        byte[] hashInformado = GerarHash(senha ?? "", registro.Salt, registro.Iteracoes, registro.Hash.Length);
        return CompararBytes(hashInformado, registro.Hash);
    }

    public static void SalvarSenha(string idUsuario, string senha, string origem, HttpContext contexto)
    {
        string id = TextoCurto(idUsuario);
        string chave = ChaveUsuario(idUsuario);
        if (id.Length == 0 || chave.Length == 0)
        {
            throw new InvalidOperationException("Informe o usuário para alterar a senha.");
        }

        byte[] salt = CriarSalt();
        byte[] hash = GerarHash(senha ?? "", salt, IteracoesPadrao, TamanhoHash);

        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
            UPDATE dbo.appbali_senhas_locais
               SET id_usuario = @id_usuario,
                   senha_hash = @senha_hash,
                   senha_salt = @senha_salt,
                   iteracoes = @iteracoes,
                   algoritmo = @algoritmo,
                   ativo = 1,
                   tentativas_invalidas = 0,
                   dt_alteracao = GETDATE(),
                   origem_alteracao = @origem
             WHERE id_usuario_chave = @id_usuario_chave;

            IF @@ROWCOUNT = 0
            BEGIN
                INSERT INTO dbo.appbali_senhas_locais
                    (id_usuario, id_usuario_chave, senha_hash, senha_salt, iteracoes, algoritmo, ativo, origem_criacao)
                VALUES
                    (@id_usuario, @id_usuario_chave, @senha_hash, @senha_salt, @iteracoes, @algoritmo, 1, @origem);
            END;", con))
        {
            cmd.Parameters.Add("@id_usuario", SqlDbType.NVarChar, 120).Value = id;
            cmd.Parameters.Add("@id_usuario_chave", SqlDbType.NVarChar, 120).Value = chave;
            cmd.Parameters.Add("@senha_hash", SqlDbType.VarBinary, 64).Value = hash;
            cmd.Parameters.Add("@senha_salt", SqlDbType.VarBinary, 64).Value = salt;
            cmd.Parameters.Add("@iteracoes", SqlDbType.Int).Value = IteracoesPadrao;
            cmd.Parameters.Add("@algoritmo", SqlDbType.NVarChar, 40).Value = "PBKDF2-SHA1";
            cmd.Parameters.Add("@origem", SqlDbType.NVarChar, 160).Value = (object)TextoCurto(origem) ?? DBNull.Value;
            con.Open();
            cmd.ExecuteNonQuery();
        }

        RegistrarAuditoria(id, "SENHA_LOCAL_SALVA", origem, contexto, "");
    }

    public static void RegistrarLoginOk(string idUsuario, string origem, HttpContext contexto)
    {
        string chave = ChaveUsuario(idUsuario);
        if (chave.Length == 0) return;

        try
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                UPDATE dbo.appbali_senhas_locais
                   SET dt_ultimo_login = GETDATE(),
                       tentativas_invalidas = 0
                 WHERE id_usuario_chave = @id_usuario_chave;", con))
            {
                cmd.Parameters.Add("@id_usuario_chave", SqlDbType.NVarChar, 120).Value = chave;
                con.Open();
                cmd.ExecuteNonQuery();
            }

            RegistrarAuditoria(idUsuario, "LOGIN_LOCAL_OK", origem, contexto, "");
        }
        catch
        {
        }
    }

    public static void RegistrarFalha(string idUsuario, string origem, HttpContext contexto, string detalhe)
    {
        string chave = ChaveUsuario(idUsuario);
        if (chave.Length == 0) return;

        try
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                UPDATE dbo.appbali_senhas_locais
                   SET tentativas_invalidas = tentativas_invalidas + 1,
                       dt_ultima_tentativa = GETDATE()
                 WHERE id_usuario_chave = @id_usuario_chave;", con))
            {
                cmd.Parameters.Add("@id_usuario_chave", SqlDbType.NVarChar, 120).Value = chave;
                con.Open();
                cmd.ExecuteNonQuery();
            }

            RegistrarAuditoria(idUsuario, "LOGIN_LOCAL_FALHA", origem, contexto, detalhe);
        }
        catch
        {
        }
    }

    private static RegistroSenhaLocal ObterRegistro(string idUsuario)
    {
        string chave = ChaveUsuario(idUsuario);
        if (chave.Length == 0) return null;

        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 1 senha_hash, senha_salt, iteracoes, ativo
            FROM dbo.appbali_senhas_locais
            WHERE id_usuario_chave = @id_usuario_chave;", con))
        {
            cmd.Parameters.Add("@id_usuario_chave", SqlDbType.NVarChar, 120).Value = chave;
            con.Open();
            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                if (!reader.Read()) return null;
                return new RegistroSenhaLocal
                {
                    Hash = (byte[])reader["senha_hash"],
                    Salt = (byte[])reader["senha_salt"],
                    Iteracoes = Convert.ToInt32(reader["iteracoes"]),
                    Ativo = Convert.ToBoolean(reader["ativo"])
                };
            }
        }
    }

    private static void RegistrarAuditoria(string idUsuario, string acao, string origem, HttpContext contexto, string detalhe)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO dbo.appbali_senhas_locais_auditoria
                    (id_usuario, acao, origem, ip, user_agent, detalhe)
                VALUES
                    (@id_usuario, @acao, @origem, @ip, @user_agent, @detalhe);", con))
            {
                cmd.Parameters.Add("@id_usuario", SqlDbType.NVarChar, 120).Value = TextoCurto(idUsuario);
                cmd.Parameters.Add("@acao", SqlDbType.NVarChar, 60).Value = TextoCurto(acao);
                cmd.Parameters.Add("@origem", SqlDbType.NVarChar, 160).Value = ValorOuDbNull(origem);
                cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 60).Value = contexto == null ? (object)DBNull.Value : ValorOuDbNull(contexto.Request.UserHostAddress);
                cmd.Parameters.Add("@user_agent", SqlDbType.NVarChar, 300).Value = contexto == null ? (object)DBNull.Value : ValorOuDbNull(contexto.Request.UserAgent);
                cmd.Parameters.Add("@detalhe", SqlDbType.NVarChar, 300).Value = ValorOuDbNull(detalhe);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
        }
    }

    private static byte[] CriarSalt()
    {
        byte[] salt = new byte[TamanhoSalt];
        using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
        {
            rng.GetBytes(salt);
        }

        return salt;
    }

    private static byte[] GerarHash(string senha, byte[] salt, int iteracoes, int tamanhoHash)
    {
        using (Rfc2898DeriveBytes pbkdf2 = new Rfc2898DeriveBytes(senha ?? "", salt, iteracoes))
        {
            return pbkdf2.GetBytes(tamanhoHash);
        }
    }

    private static bool CompararBytes(byte[] a, byte[] b)
    {
        if (a == null || b == null || a.Length != b.Length) return false;

        int diferenca = 0;
        for (int i = 0; i < a.Length; i++)
        {
            diferenca |= a[i] ^ b[i];
        }

        return diferenca == 0;
    }

    private static string ChaveUsuario(string idUsuario)
    {
        return TextoCurto(idUsuario).ToLowerInvariant();
    }

    private static string TextoCurto(string valor)
    {
        string texto = (valor ?? "").Trim();
        if (texto.Length == 0) return "";
        return String.Join(" ", texto.Split((char[])null, StringSplitOptions.RemoveEmptyEntries));
    }

    private static object ValorOuDbNull(string valor)
    {
        string texto = TextoCurto(valor);
        return texto.Length == 0 ? (object)DBNull.Value : texto;
    }

    private class RegistroSenhaLocal
    {
        public byte[] Hash { get; set; }
        public byte[] Salt { get; set; }
        public int Iteracoes { get; set; }
        public bool Ativo { get; set; }
    }
}
