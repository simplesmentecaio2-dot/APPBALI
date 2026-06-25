USE APPWF;
GO

IF OBJECT_ID('dbo.ci_comunicacoes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ci_comunicacoes (
        id_ci INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ano INT NOT NULL,
        numero INT NOT NULL,
        data_documento DATE NOT NULL,
        origem_marca NVARCHAR(40) NOT NULL,
        origem_area NVARCHAR(120) NOT NULL,
        origem_responsavel NVARCHAR(160) NOT NULL,
        destino_area NVARCHAR(120) NOT NULL,
        destinatario NVARCHAR(160) NOT NULL,
        assunto NVARCHAR(200) NOT NULL,
        categoria NVARCHAR(60) NOT NULL,
        prioridade NVARCHAR(20) NOT NULL,
        corpo NVARCHAR(MAX) NOT NULL,
        providencias NVARCHAR(MAX) NULL,
        observacoes NVARCHAR(MAX) NULL,
        criado_por NVARCHAR(160) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_ci_comunicacoes_ativo DEFAULT (1),
        dt_cadastro DATETIME NOT NULL CONSTRAINT DF_ci_comunicacoes_dt_cadastro DEFAULT (GETDATE()),
        dt_alteracao DATETIME NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ci_comunicacoes_filtros' AND object_id = OBJECT_ID('dbo.ci_comunicacoes'))
BEGIN
    CREATE INDEX IX_ci_comunicacoes_filtros ON dbo.ci_comunicacoes (ativo, data_documento, origem_marca, ano, numero);
END
GO

IF OBJECT_ID('dbo.ci_comunicacoes_historico', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ci_comunicacoes_historico (
        id_historico INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        id_ci INT NOT NULL,
        acao NVARCHAR(40) NOT NULL,
        ano INT NULL,
        numero INT NULL,
        data_documento DATE NULL,
        origem_marca NVARCHAR(40) NULL,
        origem_area NVARCHAR(120) NULL,
        origem_responsavel NVARCHAR(160) NULL,
        destino_area NVARCHAR(120) NULL,
        destinatario NVARCHAR(160) NULL,
        assunto NVARCHAR(200) NULL,
        categoria NVARCHAR(60) NULL,
        prioridade NVARCHAR(20) NULL,
        corpo NVARCHAR(MAX) NULL,
        providencias NVARCHAR(MAX) NULL,
        observacoes NVARCHAR(MAX) NULL,
        criado_por NVARCHAR(160) NULL,
        ativo BIT NULL,
        dt_evento DATETIME NOT NULL CONSTRAINT DF_ci_comunicacoes_historico_dt_evento DEFAULT (GETDATE())
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ci_comunicacoes_historico_ci' AND object_id = OBJECT_ID('dbo.ci_comunicacoes_historico'))
BEGIN
    CREATE INDEX IX_ci_comunicacoes_historico_ci ON dbo.ci_comunicacoes_historico (id_ci, dt_evento DESC);
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_comunicacao_resumo
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(1) AS total_cis,
        SUM(CASE WHEN ativo = 1 THEN 1 ELSE 0 END) AS cis_ativas,
        SUM(CASE WHEN ativo = 0 THEN 1 ELSE 0 END) AS cis_canceladas,
        SUM(CASE WHEN data_documento >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE)) AND ativo = 1 THEN 1 ELSE 0 END) AS ultimos_30_dias,
        SUM(CASE WHEN data_documento >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) AND ativo = 1 THEN 1 ELSE 0 END) AS mes_atual,
        SUM(CASE WHEN origem_marca LIKE '%Fiat%' AND ativo = 1 THEN 1 ELSE 0 END) AS fiat_ativas,
        SUM(CASE WHEN origem_marca LIKE '%Jeep%' AND ativo = 1 THEN 1 ELSE 0 END) AS jeep_ativas,
        SUM(CASE WHEN origem_marca LIKE '%BYD%' AND ativo = 1 THEN 1 ELSE 0 END) AS byd_ativas
    FROM dbo.ci_comunicacoes;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_comunicacao_listar
    @dt_inicio DATE = NULL,
    @dt_fim DATE = NULL,
    @origem_marca NVARCHAR(40) = NULL,
    @termo NVARCHAR(160) = NULL,
    @somente_ativas BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SET @origem_marca = NULLIF(LTRIM(RTRIM(ISNULL(@origem_marca, ''))), '');
    SET @termo = NULLIF(LTRIM(RTRIM(ISNULL(@termo, ''))), '');

    SELECT TOP 300
        id_ci,
        ano,
        numero,
        'CI-' + CAST(ano AS VARCHAR(4)) + '-' + RIGHT('0000' + CAST(numero AS VARCHAR(10)), 4) AS codigo_ci,
        data_documento,
        origem_marca,
        origem_area,
        destino_area,
        destinatario,
        assunto,
        categoria,
        prioridade,
        CASE WHEN ativo = 1 THEN 'Ativa' ELSE 'Cancelada' END AS status,
        ativo,
        dt_cadastro
    FROM dbo.ci_comunicacoes
    WHERE (@dt_inicio IS NULL OR data_documento >= @dt_inicio)
      AND (@dt_fim IS NULL OR data_documento <= @dt_fim)
      AND (@origem_marca IS NULL OR origem_marca = @origem_marca)
      AND (@somente_ativas = 0 OR ativo = 1)
      AND (
            @termo IS NULL
            OR assunto LIKE '%' + @termo + '%'
            OR origem_area LIKE '%' + @termo + '%'
            OR destino_area LIKE '%' + @termo + '%'
            OR destinatario LIKE '%' + @termo + '%'
            OR corpo LIKE '%' + @termo + '%'
          )
    ORDER BY data_documento DESC, id_ci DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_comunicacao_obter
    @id_ci INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_ci,
        ano,
        numero,
        'CI-' + CAST(ano AS VARCHAR(4)) + '-' + RIGHT('0000' + CAST(numero AS VARCHAR(10)), 4) AS codigo_ci,
        data_documento,
        origem_marca,
        origem_area,
        origem_responsavel,
        destino_area,
        destinatario,
        assunto,
        categoria,
        prioridade,
        corpo,
        ISNULL(providencias, '') AS providencias,
        ISNULL(observacoes, '') AS observacoes,
        ISNULL(criado_por, '') AS criado_por,
        ativo,
        CASE WHEN ativo = 1 THEN 'Ativa' ELSE 'Cancelada' END AS status,
        dt_cadastro,
        dt_alteracao
    FROM dbo.ci_comunicacoes
    WHERE id_ci = @id_ci;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_comunicacao_salvar
    @id_ci INT = NULL,
    @data_documento DATE,
    @origem_marca NVARCHAR(40),
    @origem_area NVARCHAR(120),
    @origem_responsavel NVARCHAR(160),
    @destino_area NVARCHAR(120),
    @destinatario NVARCHAR(160),
    @assunto NVARCHAR(200),
    @categoria NVARCHAR(60),
    @prioridade NVARCHAR(20),
    @corpo NVARCHAR(MAX),
    @providencias NVARCHAR(MAX) = NULL,
    @observacoes NVARCHAR(MAX) = NULL,
    @criado_por NVARCHAR(160) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @origem_marca = LTRIM(RTRIM(ISNULL(@origem_marca, '')));
    SET @origem_area = LTRIM(RTRIM(ISNULL(@origem_area, '')));
    SET @origem_responsavel = LTRIM(RTRIM(ISNULL(@origem_responsavel, '')));
    SET @destino_area = LTRIM(RTRIM(ISNULL(@destino_area, '')));
    SET @destinatario = LTRIM(RTRIM(ISNULL(@destinatario, '')));
    SET @assunto = LTRIM(RTRIM(ISNULL(@assunto, '')));
    SET @categoria = LTRIM(RTRIM(ISNULL(@categoria, '')));
    SET @prioridade = LTRIM(RTRIM(ISNULL(@prioridade, '')));
    SET @corpo = LTRIM(RTRIM(ISNULL(@corpo, '')));

    IF @data_documento IS NULL OR @origem_marca = '' OR @origem_area = '' OR @origem_responsavel = ''
        OR @destino_area = '' OR @destinatario = '' OR @assunto = '' OR @categoria = ''
        OR @prioridade = '' OR @corpo = ''
    BEGIN
        RAISERROR(N'Preencha todos os campos obrigatórios da CI.', 16, 1);
        RETURN;
    END

    IF ISNULL(@id_ci, 0) = 0
    BEGIN
        DECLARE @ano INT = YEAR(@data_documento);
        DECLARE @numero INT;

        BEGIN TRANSACTION;

        SELECT @numero = ISNULL(MAX(numero), 0) + 1
        FROM dbo.ci_comunicacoes WITH (UPDLOCK, HOLDLOCK)
        WHERE ano = @ano;

        INSERT INTO dbo.ci_comunicacoes
        (
            ano, numero, data_documento, origem_marca, origem_area,
            origem_responsavel, destino_area, destinatario, assunto,
            categoria, prioridade, corpo, providencias, observacoes, criado_por
        )
        VALUES
        (
            @ano, @numero, @data_documento, @origem_marca, @origem_area,
            @origem_responsavel, @destino_area, @destinatario, @assunto,
            @categoria, @prioridade, @corpo, NULLIF(@providencias, ''),
            NULLIF(@observacoes, ''), NULLIF(@criado_por, '')
        );

        SET @id_ci = CONVERT(INT, SCOPE_IDENTITY());
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.ci_comunicacoes_historico
        (
            id_ci, acao, ano, numero, data_documento, origem_marca, origem_area,
            origem_responsavel, destino_area, destinatario, assunto, categoria,
            prioridade, corpo, providencias, observacoes, criado_por, ativo
        )
        SELECT
            id_ci, N'Alteração', ano, numero, data_documento, origem_marca, origem_area,
            origem_responsavel, destino_area, destinatario, assunto, categoria,
            prioridade, corpo, providencias, observacoes, criado_por, ativo
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci
          AND ativo = 1;

        UPDATE dbo.ci_comunicacoes
        SET data_documento = @data_documento,
            origem_marca = @origem_marca,
            origem_area = @origem_area,
            origem_responsavel = @origem_responsavel,
            destino_area = @destino_area,
            destinatario = @destinatario,
            assunto = @assunto,
            categoria = @categoria,
            prioridade = @prioridade,
            corpo = @corpo,
            providencias = NULLIF(@providencias, ''),
            observacoes = NULLIF(@observacoes, ''),
            criado_por = NULLIF(@criado_por, ''),
            dt_alteracao = GETDATE()
        WHERE id_ci = @id_ci
          AND ativo = 1;
    END

    EXEC dbo.ci_comunicacao_obter @id_ci = @id_ci;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_comunicacao_historico_listar
    @id_ci INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 50
        id_historico,
        id_ci,
        acao,
        'CI-' + CAST(ano AS VARCHAR(4)) + '-' + RIGHT('0000' + CAST(numero AS VARCHAR(10)), 4) AS codigo_ci,
        data_documento,
        origem_marca,
        assunto,
        criado_por,
        ativo,
        dt_evento
    FROM dbo.ci_comunicacoes_historico
    WHERE id_ci = @id_ci
    ORDER BY dt_evento DESC, id_historico DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_comunicacao_cancelar
    @id_ci INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ci_comunicacoes_historico
    (
        id_ci, acao, ano, numero, data_documento, origem_marca, origem_area,
        origem_responsavel, destino_area, destinatario, assunto, categoria,
        prioridade, corpo, providencias, observacoes, criado_por, ativo
    )
    SELECT
        id_ci, N'Cancelamento', ano, numero, data_documento, origem_marca, origem_area,
        origem_responsavel, destino_area, destinatario, assunto, categoria,
        prioridade, corpo, providencias, observacoes, criado_por, ativo
    FROM dbo.ci_comunicacoes
    WHERE id_ci = @id_ci
      AND ativo = 1;

    UPDATE dbo.ci_comunicacoes
    SET ativo = 0,
        dt_alteracao = GETDATE()
    WHERE id_ci = @id_ci;
END
GO
