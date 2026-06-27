USE APPWF;

IF OBJECT_ID('dbo.appbali_senhas_locais', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.appbali_senhas_locais (
        id_senha_local INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        id_usuario NVARCHAR(120) NOT NULL,
        id_usuario_chave NVARCHAR(120) NOT NULL,
        senha_hash VARBINARY(64) NOT NULL,
        senha_salt VARBINARY(64) NOT NULL,
        iteracoes INT NOT NULL CONSTRAINT DF_appbali_senhas_locais_iteracoes DEFAULT (120000),
        algoritmo NVARCHAR(40) NOT NULL CONSTRAINT DF_appbali_senhas_locais_algoritmo DEFAULT ('PBKDF2-SHA1'),
        ativo BIT NOT NULL CONSTRAINT DF_appbali_senhas_locais_ativo DEFAULT (1),
        tentativas_invalidas INT NOT NULL CONSTRAINT DF_appbali_senhas_locais_tentativas DEFAULT (0),
        dt_criacao DATETIME NOT NULL CONSTRAINT DF_appbali_senhas_locais_dt_criacao DEFAULT (GETDATE()),
        dt_alteracao DATETIME NULL,
        dt_ultimo_login DATETIME NULL,
        dt_ultima_tentativa DATETIME NULL,
        origem_criacao NVARCHAR(160) NULL,
        origem_alteracao NVARCHAR(160) NULL
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_appbali_senhas_locais_usuario'
      AND object_id = OBJECT_ID('dbo.appbali_senhas_locais')
)
BEGIN
    CREATE UNIQUE INDEX UX_appbali_senhas_locais_usuario
        ON dbo.appbali_senhas_locais (id_usuario_chave);
END;

IF OBJECT_ID('dbo.appbali_senhas_locais_auditoria', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.appbali_senhas_locais_auditoria (
        id_auditoria INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        id_usuario NVARCHAR(120) NOT NULL,
        acao NVARCHAR(60) NOT NULL,
        origem NVARCHAR(160) NULL,
        ip NVARCHAR(60) NULL,
        user_agent NVARCHAR(300) NULL,
        detalhe NVARCHAR(300) NULL,
        dt_evento DATETIME NOT NULL CONSTRAINT DF_appbali_senhas_locais_auditoria_dt DEFAULT (GETDATE())
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_appbali_senhas_locais_auditoria_usuario'
      AND object_id = OBJECT_ID('dbo.appbali_senhas_locais_auditoria')
)
BEGIN
    CREATE INDEX IX_appbali_senhas_locais_auditoria_usuario
        ON dbo.appbali_senhas_locais_auditoria (id_usuario, dt_evento DESC);
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_appbali_senhas_locais_auditoria_data'
      AND object_id = OBJECT_ID('dbo.appbali_senhas_locais_auditoria')
)
BEGIN
    CREATE INDEX IX_appbali_senhas_locais_auditoria_data
        ON dbo.appbali_senhas_locais_auditoria (dt_evento DESC, id_auditoria DESC)
        INCLUDE (id_usuario, acao, origem, ip);
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_appbali_senhas_locais_auditoria_acao'
      AND object_id = OBJECT_ID('dbo.appbali_senhas_locais_auditoria')
)
BEGIN
    CREATE INDEX IX_appbali_senhas_locais_auditoria_acao
        ON dbo.appbali_senhas_locais_auditoria (acao, dt_evento DESC, id_auditoria DESC)
        INCLUDE (id_usuario, origem, ip);
END;
