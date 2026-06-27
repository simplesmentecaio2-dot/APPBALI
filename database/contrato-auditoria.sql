USE APPWF;
GO

IF OBJECT_ID('dbo.contrato_auditoria', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.contrato_auditoria (
        id_auditoria INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        dt_evento DATETIME NOT NULL CONSTRAINT DF_contrato_auditoria_dt_evento DEFAULT (GETDATE()),
        marca NVARCHAR(30) NOT NULL,
        tipo NVARCHAR(10) NULL,
        contrato_id NVARCHAR(40) NULL,
        usuario_id NVARCHAR(80) NULL,
        usuario_nome NVARCHAR(160) NULL,
        ip NVARCHAR(80) NULL,
        url NVARCHAR(500) NULL,
        acao NVARCHAR(100) NOT NULL,
        detalhe NVARCHAR(MAX) NULL,
        dados_antes NVARCHAR(MAX) NULL,
        dados_depois NVARCHAR(MAX) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_contrato_auditoria_contrato' AND object_id = OBJECT_ID('dbo.contrato_auditoria'))
BEGIN
    CREATE INDEX IX_contrato_auditoria_contrato
        ON dbo.contrato_auditoria (marca, contrato_id, dt_evento DESC, id_auditoria DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_contrato_auditoria_data' AND object_id = OBJECT_ID('dbo.contrato_auditoria'))
BEGIN
    CREATE INDEX IX_contrato_auditoria_data
        ON dbo.contrato_auditoria (dt_evento DESC, marca, acao);
END
GO

CREATE OR ALTER PROCEDURE dbo.contrato_auditoria_registrar
    @marca NVARCHAR(30),
    @tipo NVARCHAR(10) = NULL,
    @contrato_id NVARCHAR(40) = NULL,
    @usuario_id NVARCHAR(80) = NULL,
    @usuario_nome NVARCHAR(160) = NULL,
    @ip NVARCHAR(80) = NULL,
    @url NVARCHAR(500) = NULL,
    @acao NVARCHAR(100),
    @detalhe NVARCHAR(MAX) = NULL,
    @dados_antes NVARCHAR(MAX) = NULL,
    @dados_depois NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.contrato_auditoria (
        marca, tipo, contrato_id, usuario_id, usuario_nome,
        ip, url, acao, detalhe, dados_antes, dados_depois
    )
    VALUES (
        NULLIF(LTRIM(RTRIM(ISNULL(@marca, ''))), ''),
        NULLIF(LTRIM(RTRIM(ISNULL(@tipo, ''))), ''),
        NULLIF(LTRIM(RTRIM(ISNULL(@contrato_id, ''))), ''),
        NULLIF(LTRIM(RTRIM(ISNULL(@usuario_id, ''))), ''),
        NULLIF(LTRIM(RTRIM(ISNULL(@usuario_nome, ''))), ''),
        NULLIF(LTRIM(RTRIM(ISNULL(@ip, ''))), ''),
        NULLIF(LTRIM(RTRIM(ISNULL(@url, ''))), ''),
        NULLIF(LTRIM(RTRIM(ISNULL(@acao, ''))), ''),
        NULLIF(@detalhe, ''),
        NULLIF(@dados_antes, ''),
        NULLIF(@dados_depois, '')
    );
END
GO

CREATE OR ALTER PROCEDURE dbo.contrato_auditoria_listar
    @marca NVARCHAR(30),
    @contrato_id NVARCHAR(40),
    @tipo NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 500
        id_auditoria,
        dt_evento,
        ISNULL(marca, '') AS marca,
        ISNULL(tipo, '') AS tipo,
        ISNULL(contrato_id, '') AS contrato_id,
        ISNULL(usuario_id, '') AS usuario_id,
        ISNULL(usuario_nome, '') AS usuario_nome,
        ISNULL(ip, '') AS ip,
        ISNULL(url, '') AS url,
        acao,
        ISNULL(detalhe, '') AS detalhe,
        ISNULL(dados_antes, '') AS dados_antes,
        ISNULL(dados_depois, '') AS dados_depois
    FROM dbo.contrato_auditoria
    WHERE marca = @marca
      AND contrato_id = @contrato_id
      AND (
          @tipo IS NULL
          OR @tipo = ''
          OR tipo IS NULL
          OR tipo = ''
          OR tipo = @tipo
      )
    ORDER BY dt_evento ASC, id_auditoria ASC;
END
GO
