IF OBJECT_ID('dbo.app_sessao_usuario', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.app_sessao_usuario
    (
        id_sessao BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_app_sessao_usuario PRIMARY KEY,
        usuario_id NVARCHAR(120) NOT NULL,
        usuario_codigo NVARCHAR(50) NULL,
        usuario_nome NVARCHAR(160) NULL,
        usuario_tipo NVARCHAR(80) NULL,
        usuario_email NVARCHAR(180) NULL,
        empresa NVARCHAR(120) NULL,
        session_id NVARCHAR(120) NOT NULL,
        login_token UNIQUEIDENTIFIER NOT NULL,
        ip NVARCHAR(80) NULL,
        user_agent NVARCHAR(500) NULL,
        url_login NVARCHAR(500) NULL,
        data_login DATETIME2(0) NOT NULL CONSTRAINT DF_app_sessao_usuario_data_login DEFAULT (SYSDATETIME()),
        ultimo_acesso DATETIME2(0) NOT NULL CONSTRAINT DF_app_sessao_usuario_ultimo_acesso DEFAULT (SYSDATETIME()),
        data_encerramento DATETIME2(0) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_app_sessao_usuario_ativo DEFAULT (1),
        motivo_encerramento NVARCHAR(200) NULL
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_app_sessao_usuario_usuario_ativo' AND object_id = OBJECT_ID('dbo.app_sessao_usuario'))
BEGIN
    CREATE UNIQUE INDEX UX_app_sessao_usuario_usuario_ativo
        ON dbo.app_sessao_usuario(usuario_id)
        WHERE ativo = 1;
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_app_sessao_usuario_usuario_token' AND object_id = OBJECT_ID('dbo.app_sessao_usuario'))
BEGIN
    CREATE INDEX IX_app_sessao_usuario_usuario_token
        ON dbo.app_sessao_usuario(usuario_id, login_token, ativo)
        INCLUDE (ultimo_acesso, session_id);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_app_sessao_usuario_ultimo_acesso' AND object_id = OBJECT_ID('dbo.app_sessao_usuario'))
BEGIN
    CREATE INDEX IX_app_sessao_usuario_ultimo_acesso
        ON dbo.app_sessao_usuario(ativo, ultimo_acesso);
END;
