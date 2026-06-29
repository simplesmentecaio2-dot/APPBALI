using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;

public static class AppPermissoes
{
    private const string SessionRegistroKey = "app_permissoes_registro_usuario";
    private static readonly object EstruturaLock = new object();
    private static bool estruturaGarantida = false;

    public static void RegistrarUsuarioAtual(HttpContext contexto)
    {
        if (contexto == null || contexto.Session == null) return;

        string usuarioNome = ValorSessao(contexto, "usuario");
        if (usuarioNome.Length == 0 || usuarioNome == "N") return;

        DateTime ultima;
        object ultimoRegistro = contexto.Session[SessionRegistroKey];
        if (ultimoRegistro is DateTime)
        {
            ultima = (DateTime)ultimoRegistro;
            if ((DateTime.Now - ultima).TotalMinutes < 5)
            {
                return;
            }
        }

        string usuarioCodigo = NormalizarCodigo(ValorSessao(contexto, "usuario_codigo"));
        string usuarioId = Limitar(ValorSessao(contexto, "id"), 120);
        if (usuarioCodigo.Length == 0 && usuarioId.Length == 0) return;

        try
        {
            GarantirEstrutura();

            using (SqlConnection con = new SqlConnection(ConnectionString()))
            using (SqlCommand cmd = new SqlCommand(@"
DECLARE @id_usuario_local INT;

SELECT TOP 1 @id_usuario_local = id_usuario_local
FROM dbo.app_usuario_local
WHERE (@usuario_codigo <> N'' AND usuario_codigo = @usuario_codigo)
   OR (@usuario_codigo = N'' AND @usuario_id <> N'' AND usuario_id = @usuario_id)
ORDER BY atualizado_em DESC;

IF @id_usuario_local IS NULL
BEGIN
    INSERT INTO dbo.app_usuario_local
    (
        usuario_codigo,
        usuario_id,
        usuario_nome,
        usuario_email,
        usuario_tipo,
        empresa,
        origem,
        primeiro_login,
        ultimo_login,
        ativo_origem,
        criado_em,
        atualizado_em
    )
    VALUES
    (
        NULLIF(@usuario_codigo, N''),
        NULLIF(@usuario_id, N''),
        NULLIF(@usuario_nome, N''),
        NULLIF(@usuario_email, N''),
        NULLIF(@usuario_tipo, N''),
        NULLIF(@empresa, N''),
        N'LOGIN',
        SYSDATETIME(),
        SYSDATETIME(),
        1,
        SYSDATETIME(),
        SYSDATETIME()
    );
END
ELSE
BEGIN
    UPDATE dbo.app_usuario_local
       SET usuario_codigo = COALESCE(NULLIF(@usuario_codigo, N''), usuario_codigo),
           usuario_id = COALESCE(NULLIF(@usuario_id, N''), usuario_id),
           usuario_nome = COALESCE(NULLIF(@usuario_nome, N''), usuario_nome),
           usuario_email = COALESCE(NULLIF(@usuario_email, N''), usuario_email),
           usuario_tipo = COALESCE(NULLIF(@usuario_tipo, N''), usuario_tipo),
           empresa = COALESCE(NULLIF(@empresa, N''), empresa),
           ultimo_login = SYSDATETIME(),
           ativo_origem = 1,
           atualizado_em = SYSDATETIME()
     WHERE id_usuario_local = @id_usuario_local;
END;", con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 20;
                cmd.Parameters.Add("@usuario_codigo", SqlDbType.NVarChar, 50).Value = usuarioCodigo;
                cmd.Parameters.Add("@usuario_id", SqlDbType.NVarChar, 120).Value = usuarioId;
                cmd.Parameters.Add("@usuario_nome", SqlDbType.NVarChar, 180).Value = Limitar(usuarioNome, 180);
                cmd.Parameters.Add("@usuario_email", SqlDbType.NVarChar, 180).Value = Limitar(ValorSessao(contexto, "email"), 180);
                cmd.Parameters.Add("@usuario_tipo", SqlDbType.NVarChar, 80).Value = Limitar(ValorSessao(contexto, "tipo"), 80);
                cmd.Parameters.Add("@empresa", SqlDbType.NVarChar, 120).Value = Limitar(ValorSessao(contexto, "empresa"), 120);

                con.Open();
                cmd.ExecuteNonQuery();
            }

            contexto.Session[SessionRegistroKey] = DateTime.Now;
        }
        catch
        {
            // Permissao local nunca deve impedir o login quando a base auxiliar falhar.
        }
    }

    public static bool ValidarAcessoAtual(HttpContext contexto)
    {
        if (contexto == null || contexto.Session == null || contexto.Request == null) return true;
        if (DeveIgnorarAcesso(contexto)) return true;

        string usuarioCodigo = NormalizarCodigo(ValorSessao(contexto, "usuario_codigo"));
        string usuarioId = Limitar(ValorSessao(contexto, "id"), 120);
        if (usuarioCodigo.Length == 0 && usuarioId.Length == 0) return true;

        string recurso = RecursoAtual(contexto);
        if (recurso.Length == 0) return true;

        string recursoArea = RecursoArea(recurso);

        try
        {
            GarantirEstrutura();

            using (SqlConnection con = new SqlConnection(ConnectionString()))
            using (SqlCommand cmd = new SqlCommand(@"
SELECT TOP 1
    id_permissao,
    bloqueado,
    permitido,
    recurso,
    acao
FROM dbo.app_permissao_usuario WITH (READPAST)
WHERE ativo = 1
  AND ((@usuario_codigo <> N'' AND usuario_codigo = @usuario_codigo)
       OR (@usuario_id <> N'' AND usuario_id = @usuario_id))
  AND recurso IN (@recurso, @recurso_area, N'*')
  AND acao IN (N'VISUALIZAR', N'*')
ORDER BY
    CASE WHEN recurso = @recurso THEN 0 WHEN recurso = @recurso_area THEN 1 ELSE 2 END,
    CASE WHEN acao = N'VISUALIZAR' THEN 0 ELSE 1 END,
    atualizado_em DESC,
    id_permissao DESC;", con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 15;
                cmd.Parameters.Add("@usuario_codigo", SqlDbType.NVarChar, 50).Value = usuarioCodigo;
                cmd.Parameters.Add("@usuario_id", SqlDbType.NVarChar, 120).Value = usuarioId;
                cmd.Parameters.Add("@recurso", SqlDbType.NVarChar, 260).Value = recurso;
                cmd.Parameters.Add("@recurso_area", SqlDbType.NVarChar, 260).Value = recursoArea;

                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) return true;

                    bool bloqueado = dr["bloqueado"] != DBNull.Value && Convert.ToBoolean(dr["bloqueado"]);
                    if (!bloqueado) return true;
                }
            }

            RegistrarAuditoria("ACESSO_NEGADO", 0, usuarioCodigo, usuarioId, ValorSessao(contexto, "usuario"), recurso, "VISUALIZAR", false, true, "Acesso bloqueado por regra ativa.", contexto);
            return false;
        }
        catch
        {
            return true;
        }
    }

    public static string UrlAcessoNegado(HttpContext contexto)
    {
        string recurso = contexto == null ? "" : RecursoAtual(contexto);
        string voltar = contexto == null || contexto.Request == null ? "/" : (contexto.Request.RawUrl ?? "/");
        return "/acesso-negado.aspx?recurso=" + HttpUtility.UrlEncode(recurso) + "&voltar=" + HttpUtility.UrlEncode(voltar);
    }

    public static void SalvarRegra(int idUsuarioLocal, string recurso, string acao, bool bloquear, string motivo, HttpContext contexto)
    {
        recurso = NormalizarRecurso(recurso);
        acao = NormalizarAcao(acao);
        motivo = Limitar((motivo ?? "").Trim(), 300);
        if (idUsuarioLocal <= 0) throw new ArgumentException("Usuário inválido.");
        if (recurso.Length == 0) throw new ArgumentException("Recurso inválido.");

        GarantirEstrutura();

        using (SqlConnection con = new SqlConnection(ConnectionString()))
        using (SqlCommand cmd = new SqlCommand(@"
DECLARE @usuario_codigo NVARCHAR(50);
DECLARE @usuario_id NVARCHAR(120);
DECLARE @usuario_nome NVARCHAR(180);

SELECT
    @usuario_codigo = usuario_codigo,
    @usuario_id = usuario_id,
    @usuario_nome = usuario_nome
FROM dbo.app_usuario_local
WHERE id_usuario_local = @id_usuario_local;

IF @usuario_codigo IS NULL AND @usuario_id IS NULL
BEGIN
    RAISERROR(N'Usuário local não encontrado.', 16, 1);
    RETURN;
END;

DECLARE @id_permissao INT;
SELECT TOP 1 @id_permissao = id_permissao
FROM dbo.app_permissao_usuario
WHERE ativo = 1
  AND id_usuario_local = @id_usuario_local
  AND recurso = @recurso
  AND acao = @acao
ORDER BY id_permissao DESC;

IF @id_permissao IS NULL
BEGIN
    INSERT INTO dbo.app_permissao_usuario
    (
        id_usuario_local,
        usuario_codigo,
        usuario_id,
        recurso,
        acao,
        permitido,
        bloqueado,
        ativo,
        motivo,
        criado_por,
        criado_em,
        atualizado_por,
        atualizado_em
    )
    VALUES
    (
        @id_usuario_local,
        @usuario_codigo,
        @usuario_id,
        @recurso,
        @acao,
        @permitido,
        @bloqueado,
        1,
        NULLIF(@motivo, N''),
        @operador,
        SYSDATETIME(),
        @operador,
        SYSDATETIME()
    );
END
ELSE
BEGIN
    UPDATE dbo.app_permissao_usuario
       SET permitido = @permitido,
           bloqueado = @bloqueado,
           motivo = NULLIF(@motivo, N''),
           atualizado_por = @operador,
           atualizado_em = SYSDATETIME()
     WHERE id_permissao = @id_permissao;
END;

INSERT INTO dbo.app_permissao_auditoria
(
    evento,
    id_usuario_local,
    usuario_codigo,
    usuario_id,
    usuario_nome,
    recurso,
    acao,
    permitido,
    bloqueado,
    detalhes,
    operador,
    ip,
    criado_em
)
VALUES
(
    CASE WHEN @bloqueado = 1 THEN N'REGRA_BLOQUEIO' ELSE N'REGRA_LIBERACAO' END,
    @id_usuario_local,
    @usuario_codigo,
    @usuario_id,
    @usuario_nome,
    @recurso,
    @acao,
    @permitido,
    @bloqueado,
    NULLIF(@motivo, N''),
    @operador,
    @ip,
    SYSDATETIME()
);", con))
        {
            bool permitir = !bloquear;
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = 20;
            cmd.Parameters.Add("@id_usuario_local", SqlDbType.Int).Value = idUsuarioLocal;
            cmd.Parameters.Add("@recurso", SqlDbType.NVarChar, 260).Value = recurso;
            cmd.Parameters.Add("@acao", SqlDbType.NVarChar, 40).Value = acao;
            cmd.Parameters.Add("@permitido", SqlDbType.Bit).Value = permitir;
            cmd.Parameters.Add("@bloqueado", SqlDbType.Bit).Value = bloquear;
            cmd.Parameters.Add("@motivo", SqlDbType.NVarChar, 300).Value = motivo;
            cmd.Parameters.Add("@operador", SqlDbType.NVarChar, 160).Value = Operador(contexto);
            cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 80).Value = Ip(contexto);

            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    public static void RemoverRegra(int idPermissao, HttpContext contexto)
    {
        if (idPermissao <= 0) return;
        GarantirEstrutura();

        using (SqlConnection con = new SqlConnection(ConnectionString()))
        using (SqlCommand cmd = new SqlCommand(@"
DECLARE @id_usuario_local INT;
DECLARE @usuario_codigo NVARCHAR(50);
DECLARE @usuario_id NVARCHAR(120);
DECLARE @usuario_nome NVARCHAR(180);
DECLARE @recurso NVARCHAR(260);
DECLARE @acao NVARCHAR(40);
DECLARE @permitido BIT;
DECLARE @bloqueado BIT;

SELECT
    @id_usuario_local = p.id_usuario_local,
    @usuario_codigo = p.usuario_codigo,
    @usuario_id = p.usuario_id,
    @usuario_nome = u.usuario_nome,
    @recurso = p.recurso,
    @acao = p.acao,
    @permitido = p.permitido,
    @bloqueado = p.bloqueado
FROM dbo.app_permissao_usuario p
LEFT JOIN dbo.app_usuario_local u ON u.id_usuario_local = p.id_usuario_local
WHERE p.id_permissao = @id_permissao;

UPDATE dbo.app_permissao_usuario
   SET ativo = 0,
       atualizado_por = @operador,
       atualizado_em = SYSDATETIME()
 WHERE id_permissao = @id_permissao;

IF @@ROWCOUNT > 0
BEGIN
    INSERT INTO dbo.app_permissao_auditoria
    (
        evento,
        id_usuario_local,
        usuario_codigo,
        usuario_id,
        usuario_nome,
        recurso,
        acao,
        permitido,
        bloqueado,
        detalhes,
        operador,
        ip,
        criado_em
    )
    VALUES
    (
        N'REGRA_REMOVIDA',
        @id_usuario_local,
        @usuario_codigo,
        @usuario_id,
        @usuario_nome,
        @recurso,
        @acao,
        @permitido,
        @bloqueado,
        N'Regra removida pela tela de permissões.',
        @operador,
        @ip,
        SYSDATETIME()
    );
END;", con))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = 20;
            cmd.Parameters.Add("@id_permissao", SqlDbType.Int).Value = idPermissao;
            cmd.Parameters.Add("@operador", SqlDbType.NVarChar, 160).Value = Operador(contexto);
            cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 80).Value = Ip(contexto);

            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    public static string NormalizarRecurso(string recurso)
    {
        recurso = (recurso ?? "").Trim();
        if (recurso.Length == 0) return "";
        if (recurso == "*") return "*";

        recurso = recurso.Replace("\\", "/");
        if (recurso.StartsWith("~/", StringComparison.Ordinal)) recurso = recurso.Substring(1);
        if (!recurso.StartsWith("/", StringComparison.Ordinal)) recurso = "/" + recurso;

        int query = recurso.IndexOf("?", StringComparison.Ordinal);
        if (query >= 0) recurso = recurso.Substring(0, query);

        return Limitar(recurso.ToLowerInvariant(), 260);
    }

    public static string NormalizarAcao(string acao)
    {
        acao = (acao ?? "").Trim().ToUpperInvariant();
        if (acao.Length == 0) return "VISUALIZAR";
        return Limitar(acao, 40);
    }

    public static string RecursoAtual(HttpContext contexto)
    {
        if (contexto == null || contexto.Request == null) return "";
        return NormalizarRecurso(contexto.Request.AppRelativeCurrentExecutionFilePath ?? "");
    }

    public static bool DeveIgnorarAcesso(HttpContext contexto)
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
            || nome == "alterarsenha.aspx"
            || nome == "sessao-renovar.aspx"
            || nome == "acesso-negado.aspx";
    }

    public static void GarantirEstrutura()
    {
        if (estruturaGarantida) return;

        lock (EstruturaLock)
        {
            if (estruturaGarantida) return;

            using (SqlConnection con = new SqlConnection(ConnectionString()))
            using (SqlCommand cmd = new SqlCommand(@"
IF OBJECT_ID('dbo.app_usuario_local','U') IS NULL
BEGIN
    CREATE TABLE dbo.app_usuario_local
    (
        id_usuario_local INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_app_usuario_local PRIMARY KEY,
        usuario_codigo NVARCHAR(50) NULL,
        usuario_id NVARCHAR(120) NULL,
        usuario_nome NVARCHAR(180) NULL,
        usuario_email NVARCHAR(180) NULL,
        usuario_tipo NVARCHAR(80) NULL,
        empresa NVARCHAR(120) NULL,
        origem NVARCHAR(60) NOT NULL CONSTRAINT DF_app_usuario_local_origem DEFAULT(N'LOGIN'),
        primeiro_login DATETIME2(0) NOT NULL CONSTRAINT DF_app_usuario_local_primeiro DEFAULT(SYSDATETIME()),
        ultimo_login DATETIME2(0) NOT NULL CONSTRAINT DF_app_usuario_local_ultimo DEFAULT(SYSDATETIME()),
        ativo_origem BIT NULL,
        criado_em DATETIME2(0) NOT NULL CONSTRAINT DF_app_usuario_local_criado DEFAULT(SYSDATETIME()),
        atualizado_em DATETIME2(0) NOT NULL CONSTRAINT DF_app_usuario_local_atualizado DEFAULT(SYSDATETIME())
    );
END;

IF OBJECT_ID('dbo.app_permissao_usuario','U') IS NULL
BEGIN
    CREATE TABLE dbo.app_permissao_usuario
    (
        id_permissao INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_app_permissao_usuario PRIMARY KEY,
        id_usuario_local INT NULL,
        usuario_codigo NVARCHAR(50) NULL,
        usuario_id NVARCHAR(120) NULL,
        recurso NVARCHAR(260) NOT NULL,
        acao NVARCHAR(40) NOT NULL CONSTRAINT DF_app_permissao_usuario_acao DEFAULT(N'VISUALIZAR'),
        permitido BIT NOT NULL CONSTRAINT DF_app_permissao_usuario_permitido DEFAULT(0),
        bloqueado BIT NOT NULL CONSTRAINT DF_app_permissao_usuario_bloqueado DEFAULT(1),
        ativo BIT NOT NULL CONSTRAINT DF_app_permissao_usuario_ativo DEFAULT(1),
        motivo NVARCHAR(300) NULL,
        criado_por NVARCHAR(160) NULL,
        criado_em DATETIME2(0) NOT NULL CONSTRAINT DF_app_permissao_usuario_criado DEFAULT(SYSDATETIME()),
        atualizado_por NVARCHAR(160) NULL,
        atualizado_em DATETIME2(0) NOT NULL CONSTRAINT DF_app_permissao_usuario_atualizado DEFAULT(SYSDATETIME())
    );
END;

IF OBJECT_ID('dbo.app_permissao_auditoria','U') IS NULL
BEGIN
    CREATE TABLE dbo.app_permissao_auditoria
    (
        id_auditoria BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_app_permissao_auditoria PRIMARY KEY,
        evento NVARCHAR(60) NOT NULL,
        id_usuario_local INT NULL,
        usuario_codigo NVARCHAR(50) NULL,
        usuario_id NVARCHAR(120) NULL,
        usuario_nome NVARCHAR(180) NULL,
        recurso NVARCHAR(260) NULL,
        acao NVARCHAR(40) NULL,
        permitido BIT NULL,
        bloqueado BIT NULL,
        detalhes NVARCHAR(600) NULL,
        operador NVARCHAR(160) NULL,
        ip NVARCHAR(80) NULL,
        criado_em DATETIME2(0) NOT NULL CONSTRAINT DF_app_permissao_auditoria_criado DEFAULT(SYSDATETIME())
    );
END;", con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 30;
                con.Open();
                cmd.ExecuteNonQuery();
            }

            estruturaGarantida = true;
        }
    }

    private static string RecursoArea(string recurso)
    {
        recurso = NormalizarRecurso(recurso);
        if (recurso.Length == 0 || recurso == "*") return "";

        int segundoSeparador = recurso.IndexOf("/", 1, StringComparison.Ordinal);
        if (segundoSeparador <= 0) return "/*";

        return recurso.Substring(0, segundoSeparador) + "/*";
    }

    private static void RegistrarAuditoria(string evento, int idUsuarioLocal, string usuarioCodigo, string usuarioId, string usuarioNome, string recurso, string acao, bool permitido, bool bloqueado, string detalhes, HttpContext contexto)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnectionString()))
            using (SqlCommand cmd = new SqlCommand(@"
INSERT INTO dbo.app_permissao_auditoria
(
    evento,
    id_usuario_local,
    usuario_codigo,
    usuario_id,
    usuario_nome,
    recurso,
    acao,
    permitido,
    bloqueado,
    detalhes,
    operador,
    ip,
    criado_em
)
VALUES
(
    @evento,
    NULLIF(@id_usuario_local, 0),
    NULLIF(@usuario_codigo, N''),
    NULLIF(@usuario_id, N''),
    NULLIF(@usuario_nome, N''),
    NULLIF(@recurso, N''),
    NULLIF(@acao, N''),
    @permitido,
    @bloqueado,
    NULLIF(@detalhes, N''),
    @operador,
    @ip,
    SYSDATETIME()
);", con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 15;
                cmd.Parameters.Add("@evento", SqlDbType.NVarChar, 60).Value = Limitar(evento, 60);
                cmd.Parameters.Add("@id_usuario_local", SqlDbType.Int).Value = idUsuarioLocal;
                cmd.Parameters.Add("@usuario_codigo", SqlDbType.NVarChar, 50).Value = usuarioCodigo ?? "";
                cmd.Parameters.Add("@usuario_id", SqlDbType.NVarChar, 120).Value = usuarioId ?? "";
                cmd.Parameters.Add("@usuario_nome", SqlDbType.NVarChar, 180).Value = Limitar(usuarioNome, 180);
                cmd.Parameters.Add("@recurso", SqlDbType.NVarChar, 260).Value = NormalizarRecurso(recurso);
                cmd.Parameters.Add("@acao", SqlDbType.NVarChar, 40).Value = NormalizarAcao(acao);
                cmd.Parameters.Add("@permitido", SqlDbType.Bit).Value = permitido;
                cmd.Parameters.Add("@bloqueado", SqlDbType.Bit).Value = bloqueado;
                cmd.Parameters.Add("@detalhes", SqlDbType.NVarChar, 600).Value = Limitar(detalhes, 600);
                cmd.Parameters.Add("@operador", SqlDbType.NVarChar, 160).Value = Operador(contexto);
                cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 80).Value = Ip(contexto);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
        }
    }

    private static string ConnectionString()
    {
        ConnectionStringSettings cfg = ConfigurationManager.ConnectionStrings["APPWFConnectionString"];
        if (cfg != null) return cfg.ConnectionString;
        return ConfigurationManager.ConnectionStrings["APPWFConnectionString2"].ConnectionString;
    }

    private static string ValorSessao(HttpContext contexto, string chave)
    {
        if (contexto == null || contexto.Session == null || contexto.Session[chave] == null) return "";
        return Convert.ToString(contexto.Session[chave]).Trim();
    }

    private static string NormalizarCodigo(string valor)
    {
        valor = (valor ?? "").Trim();
        if (valor == "0" || valor == "-") return "";
        return Limitar(valor, 50);
    }

    private static string Operador(HttpContext contexto)
    {
        string usuario = ValorSessao(contexto, "usuario");
        string id = ValorSessao(contexto, "id");
        string codigo = ValorSessao(contexto, "usuario_codigo");
        string texto = usuario;
        if (codigo.Length > 0) texto += " (" + codigo + ")";
        if (texto.Trim().Length == 0) texto = id;
        return Limitar(texto, 160);
    }

    private static string Ip(HttpContext contexto)
    {
        if (contexto == null || contexto.Request == null) return "";
        string encaminhado = Convert.ToString(contexto.Request.ServerVariables["HTTP_X_FORWARDED_FOR"]);
        if (!String.IsNullOrWhiteSpace(encaminhado))
        {
            string[] partes = encaminhado.Split(',');
            if (partes.Length > 0) return Limitar(partes[0].Trim(), 80);
        }

        return Limitar(Convert.ToString(contexto.Request.ServerVariables["REMOTE_ADDR"]), 80);
    }

    private static string Limitar(string valor, int tamanho)
    {
        valor = (valor ?? "").Trim();
        if (valor.Length <= tamanho) return valor;
        return valor.Substring(0, tamanho);
    }
}
