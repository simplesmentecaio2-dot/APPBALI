using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

public static class SessaoUnica
{
    private const string TokenKey = "sessao_unica_token";
    private const string UsuarioIdKey = "sessao_unica_usuario_id";
    private const string UltimaValidacaoKey = "sessao_unica_ultima_validacao";
    private const string FalhaRegistroKey = "sessao_unica_falha_registro";
    private const int IntervaloValidacaoSegundos = 15;
    private const int ToleranciaFalhaRegistroMinutos = 10;

    public static void RegistrarLoginAtual()
    {
        HttpContext contexto = HttpContext.Current;
        if (contexto == null || contexto.Session == null) return;

        string usuarioId = ValorSessao(contexto, "id");
        string usuarioNome = ValorSessao(contexto, "usuario");
        if (usuarioId.Length == 0 || usuarioNome.Length == 0 || usuarioNome == "N") return;

        string token = Guid.NewGuid().ToString("D");
        string usuarioCodigo = ValorSessao(contexto, "usuario_codigo");
        string usuarioTipo = ValorSessao(contexto, "tipo");
        string usuarioEmail = ValorSessao(contexto, "email");
        string empresa = ValorSessao(contexto, "empresa");
        string sessionId = contexto.Session.SessionID ?? "";
        string ip = contexto.Request.UserHostAddress ?? "";
        string userAgent = contexto.Request.UserAgent ?? "";
        string urlLogin = contexto.Request.RawUrl ?? "";

        try
        {
            using (SqlConnection con = new SqlConnection(ConnectionString()))
            using (SqlCommand cmd = new SqlCommand(@"
SET XACT_ABORT ON;
BEGIN TRAN;

DECLARE @lockResult INT;
DECLARE @lockResource NVARCHAR(255) = N'app_sessao_usuario:' + @usuario_id;

EXEC @lockResult = sys.sp_getapplock
    @Resource = @lockResource,
    @LockMode = 'Exclusive',
    @LockOwner = 'Transaction',
    @LockTimeout = 10000;

IF @lockResult < 0
BEGIN
    ROLLBACK;
    RAISERROR(N'Nao foi possivel bloquear a sessao do usuario para login.', 16, 1);
    RETURN;
END;

UPDATE dbo.app_sessao_usuario
   SET ativo = 0,
       data_encerramento = SYSDATETIME(),
       motivo_encerramento = N'SUBSTITUIDA_NOVO_LOGIN'
 WHERE usuario_id = @usuario_id
   AND ativo = 1;

INSERT INTO dbo.app_sessao_usuario
(
    usuario_id,
    usuario_codigo,
    usuario_nome,
    usuario_tipo,
    usuario_email,
    empresa,
    session_id,
    login_token,
    ip,
    user_agent,
    url_login,
    data_login,
    ultimo_acesso,
    ativo
)
VALUES
(
    @usuario_id,
    @usuario_codigo,
    @usuario_nome,
    @usuario_tipo,
    @usuario_email,
    @empresa,
    @session_id,
    @login_token,
    @ip,
    @user_agent,
    @url_login,
    SYSDATETIME(),
    SYSDATETIME(),
    1
);

COMMIT;", con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 30;
                cmd.Parameters.Add("@usuario_id", SqlDbType.NVarChar, 120).Value = usuarioId;
                cmd.Parameters.Add("@usuario_codigo", SqlDbType.NVarChar, 50).Value = ValorBanco(usuarioCodigo);
                cmd.Parameters.Add("@usuario_nome", SqlDbType.NVarChar, 160).Value = ValorBanco(usuarioNome);
                cmd.Parameters.Add("@usuario_tipo", SqlDbType.NVarChar, 80).Value = ValorBanco(usuarioTipo);
                cmd.Parameters.Add("@usuario_email", SqlDbType.NVarChar, 180).Value = ValorBanco(usuarioEmail);
                cmd.Parameters.Add("@empresa", SqlDbType.NVarChar, 120).Value = ValorBanco(empresa);
                cmd.Parameters.Add("@session_id", SqlDbType.NVarChar, 120).Value = sessionId;
                cmd.Parameters.Add("@login_token", SqlDbType.UniqueIdentifier).Value = new Guid(token);
                cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 80).Value = ValorBanco(ip);
                cmd.Parameters.Add("@user_agent", SqlDbType.NVarChar, 500).Value = ValorBanco(Limitar(userAgent, 500));
                cmd.Parameters.Add("@url_login", SqlDbType.NVarChar, 500).Value = ValorBanco(Limitar(urlLogin, 500));

                con.Open();
                cmd.ExecuteNonQuery();
            }

            contexto.Session[TokenKey] = token;
            contexto.Session[UsuarioIdKey] = usuarioId;
            contexto.Session.Remove(UltimaValidacaoKey);
            contexto.Session.Remove(FalhaRegistroKey);
        }
        catch
        {
            contexto.Session.Remove(TokenKey);
            contexto.Session.Remove(UsuarioIdKey);
            contexto.Session.Remove(UltimaValidacaoKey);
            contexto.Session[FalhaRegistroKey] = DateTime.Now;
        }
    }

    public static bool ValidarSessaoAtual(HttpContext contexto)
    {
        if (contexto == null || contexto.Session == null) return true;
        if (DeveIgnorarValidacao(contexto)) return true;

        string usuarioId = ValorSessao(contexto, "id");
        string usuarioNome = ValorSessao(contexto, "usuario");
        if (usuarioId.Length == 0 || usuarioNome.Length == 0) return true;

        string token = ValorSessao(contexto, TokenKey);
        if (token.Length == 0)
        {
            return HouveFalhaRecenteDeRegistro(contexto);
        }

        DateTime ultimaValidacao;
        object valorUltimaValidacao = contexto.Session[UltimaValidacaoKey];
        if (valorUltimaValidacao is DateTime)
        {
            ultimaValidacao = (DateTime)valorUltimaValidacao;
            if ((DateTime.Now - ultimaValidacao).TotalSeconds < IntervaloValidacaoSegundos)
            {
                return true;
            }
        }

        try
        {
            using (SqlConnection con = new SqlConnection(ConnectionString()))
            using (SqlCommand cmd = new SqlCommand(@"
UPDATE dbo.app_sessao_usuario
   SET ultimo_acesso = SYSDATETIME()
 WHERE usuario_id = @usuario_id
   AND login_token = @login_token
   AND ativo = 1;", con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 15;
                cmd.Parameters.Add("@usuario_id", SqlDbType.NVarChar, 120).Value = usuarioId;
                cmd.Parameters.Add("@login_token", SqlDbType.UniqueIdentifier).Value = new Guid(token);

                con.Open();
                int linhas = cmd.ExecuteNonQuery();
                contexto.Session[UltimaValidacaoKey] = DateTime.Now;
                return linhas > 0;
            }
        }
        catch
        {
            return true;
        }
    }

    public static void EncerrarSessaoAtual(string motivo)
    {
        HttpContext contexto = HttpContext.Current;
        if (contexto == null || contexto.Session == null) return;

        string usuarioId = ValorSessao(contexto, "id");
        string token = ValorSessao(contexto, TokenKey);
        if (usuarioId.Length == 0 || token.Length == 0) return;

        try
        {
            using (SqlConnection con = new SqlConnection(ConnectionString()))
            using (SqlCommand cmd = new SqlCommand(@"
UPDATE dbo.app_sessao_usuario
   SET ativo = 0,
       data_encerramento = COALESCE(data_encerramento, SYSDATETIME()),
       motivo_encerramento = @motivo
 WHERE usuario_id = @usuario_id
   AND login_token = @login_token
   AND ativo = 1;", con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 15;
                cmd.Parameters.Add("@motivo", SqlDbType.NVarChar, 200).Value = ValorBanco(motivo);
                cmd.Parameters.Add("@usuario_id", SqlDbType.NVarChar, 120).Value = usuarioId;
                cmd.Parameters.Add("@login_token", SqlDbType.UniqueIdentifier).Value = new Guid(token);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
        }
    }

    public static bool DeveIgnorarValidacao(HttpContext contexto)
    {
        if (contexto == null || contexto.Request == null) return true;

        string caminho = contexto.Request.AppRelativeCurrentExecutionFilePath ?? "";
        if (!caminho.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase)) return true;

        string nome = System.IO.Path.GetFileName(caminho).ToLowerInvariant();
        return nome == "login.aspx"
            || nome == "loginapp.aspx"
            || nome == "loginappcontrato.aspx"
            || nome == "loginbi.aspx"
            || nome == "loginbiwf.aspx"
            || nome == "logout.aspx"
            || nome == "alterarsenha.aspx";
    }

    public static string UrlLoginSessaoEncerrada(HttpContext contexto)
    {
        string caminho = contexto == null || contexto.Request == null ? "" : (contexto.Request.AppRelativeCurrentExecutionFilePath ?? "");
        string rawUrl = contexto == null || contexto.Request == null ? "/" : (contexto.Request.RawUrl ?? "/");
        string login = "/login.aspx";

        if (caminho.StartsWith("~/CI/", StringComparison.OrdinalIgnoreCase)) login = "/CI/login.aspx";
        else if (caminho.StartsWith("~/RAMAIS/", StringComparison.OrdinalIgnoreCase) || caminho.StartsWith("~/Ramais/", StringComparison.OrdinalIgnoreCase)) login = "/RAMAIS/login.aspx";
        else if (caminho.StartsWith("~/veiculos/patiojeep/", StringComparison.OrdinalIgnoreCase)) login = "/veiculos/patiojeep/login.aspx";
        else if (caminho.StartsWith("~/veiculos/patio/", StringComparison.OrdinalIgnoreCase)) login = "/veiculos/patio/login.aspx";
        else if (caminho.StartsWith("~/veiculos/VendasSab/", StringComparison.OrdinalIgnoreCase)) login = "/veiculos/VendasSab/login.aspx";
        else if (caminho.StartsWith("~/veiculos/", StringComparison.OrdinalIgnoreCase)) login = "/veiculos/loginAppcontrato.aspx";
        else if (caminho.StartsWith("~/jeep/patio/", StringComparison.OrdinalIgnoreCase)) login = "/jeep/patio/login.aspx";
        else if (caminho.StartsWith("~/jeep/", StringComparison.OrdinalIgnoreCase)) login = "/jeep/loginAppcontrato.aspx";
        else if (caminho.StartsWith("~/byd/patio/", StringComparison.OrdinalIgnoreCase)) login = "/byd/patio/login.aspx";
        else if (caminho.StartsWith("~/byd/", StringComparison.OrdinalIgnoreCase)) login = "/byd/loginAppcontrato.aspx";
        else if (caminho.StartsWith("~/diretoria/", StringComparison.OrdinalIgnoreCase)) login = "/diretoria/loginApp.aspx";

        return login + "?sessao=encerrada&voltar=" + HttpUtility.UrlEncode(rawUrl);
    }

    public static void MostrarAvisoSessaoEncerrada(Page pagina)
    {
        if (pagina == null || pagina.Request == null) return;
        string motivo = pagina.Request.QueryString["sessao"];
        if (!String.Equals(motivo, "encerrada", StringComparison.OrdinalIgnoreCase)) return;

        string script = "alert('Sua sessao foi encerrada porque este usuario acessou o sistema em outro dispositivo.');";
        try
        {
            ScriptManager.RegisterStartupScript(pagina, pagina.GetType(), "sessao-unica-encerrada", script, true);
        }
        catch
        {
            pagina.ClientScript.RegisterStartupScript(pagina.GetType(), "sessao-unica-encerrada", script, true);
        }
    }

    private static string ConnectionString()
    {
        return ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString;
    }

    private static bool HouveFalhaRecenteDeRegistro(HttpContext contexto)
    {
        object valorFalha = contexto.Session[FalhaRegistroKey];
        if (!(valorFalha is DateTime)) return false;

        DateTime falha = (DateTime)valorFalha;
        return (DateTime.Now - falha).TotalMinutes <= ToleranciaFalhaRegistroMinutos;
    }

    private static string ValorSessao(HttpContext contexto, string chave)
    {
        if (contexto == null || contexto.Session == null || contexto.Session[chave] == null) return "";
        return Convert.ToString(contexto.Session[chave]).Trim();
    }

    private static object ValorBanco(string valor)
    {
        valor = (valor ?? "").Trim();
        return valor.Length == 0 ? (object)DBNull.Value : valor;
    }

    private static string Limitar(string valor, int tamanho)
    {
        valor = valor ?? "";
        return valor.Length <= tamanho ? valor : valor.Substring(0, tamanho);
    }
}
