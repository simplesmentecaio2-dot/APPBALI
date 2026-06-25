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
        status_ci NVARCHAR(20) NOT NULL CONSTRAINT DF_ci_comunicacoes_status_ci DEFAULT ('Emitida'),
        ativo BIT NOT NULL CONSTRAINT DF_ci_comunicacoes_ativo DEFAULT (1),
        dt_cadastro DATETIME NOT NULL CONSTRAINT DF_ci_comunicacoes_dt_cadastro DEFAULT (GETDATE()),
        dt_alteracao DATETIME NULL
    );
END
GO

IF COL_LENGTH('dbo.ci_comunicacoes', 'status_ci') IS NULL
BEGIN
    ALTER TABLE dbo.ci_comunicacoes
        ADD status_ci NVARCHAR(20) NOT NULL
            CONSTRAINT DF_ci_comunicacoes_status_ci DEFAULT ('Emitida');
END
GO

UPDATE dbo.ci_comunicacoes
SET status_ci = CASE WHEN ativo = 0 THEN 'Cancelada' ELSE ISNULL(NULLIF(status_ci, ''), 'Emitida') END
WHERE status_ci IS NULL
   OR status_ci = ''
   OR (ativo = 0 AND status_ci <> 'Cancelada');
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ci_comunicacoes_filtros' AND object_id = OBJECT_ID('dbo.ci_comunicacoes'))
BEGIN
    CREATE INDEX IX_ci_comunicacoes_filtros ON dbo.ci_comunicacoes (ativo, data_documento, origem_marca, ano, numero);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ci_comunicacoes_status' AND object_id = OBJECT_ID('dbo.ci_comunicacoes'))
BEGIN
    CREATE INDEX IX_ci_comunicacoes_status ON dbo.ci_comunicacoes (status_ci, categoria, prioridade, data_documento);
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
        status_ci NVARCHAR(20) NULL,
        ativo BIT NULL,
        dt_evento DATETIME NOT NULL CONSTRAINT DF_ci_comunicacoes_historico_dt_evento DEFAULT (GETDATE())
    );
END
GO

IF COL_LENGTH('dbo.ci_comunicacoes_historico', 'status_ci') IS NULL
BEGIN
    ALTER TABLE dbo.ci_comunicacoes_historico
        ADD status_ci NVARCHAR(20) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ci_comunicacoes_historico_ci' AND object_id = OBJECT_ID('dbo.ci_comunicacoes_historico'))
BEGIN
    CREATE INDEX IX_ci_comunicacoes_historico_ci ON dbo.ci_comunicacoes_historico (id_ci, dt_evento DESC);
END
GO

IF OBJECT_ID('dbo.ci_comunicacoes_historico_campos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ci_comunicacoes_historico_campos (
        id_historico_campo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        id_ci INT NOT NULL,
        campo NVARCHAR(80) NOT NULL,
        valor_antigo NVARCHAR(MAX) NULL,
        valor_novo NVARCHAR(MAX) NULL,
        usuario NVARCHAR(160) NULL,
        dt_evento DATETIME NOT NULL CONSTRAINT DF_ci_comunicacoes_historico_campos_dt_evento DEFAULT (GETDATE())
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ci_comunicacoes_historico_campos_ci' AND object_id = OBJECT_ID('dbo.ci_comunicacoes_historico_campos'))
BEGIN
    CREATE INDEX IX_ci_comunicacoes_historico_campos_ci ON dbo.ci_comunicacoes_historico_campos (id_ci, dt_evento DESC);
END
GO

IF OBJECT_ID('dbo.ci_modelos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ci_modelos (
        id_modelo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        nome NVARCHAR(120) NOT NULL,
        origem_marca NVARCHAR(40) NULL,
        categoria NVARCHAR(60) NOT NULL,
        prioridade NVARCHAR(20) NOT NULL CONSTRAINT DF_ci_modelos_prioridade DEFAULT ('Normal'),
        assunto NVARCHAR(200) NOT NULL,
        corpo NVARCHAR(MAX) NOT NULL,
        providencias NVARCHAR(MAX) NULL,
        observacoes NVARCHAR(MAX) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_ci_modelos_ativo DEFAULT (1),
        dt_cadastro DATETIME NOT NULL CONSTRAINT DF_ci_modelos_dt_cadastro DEFAULT (GETDATE()),
        dt_alteracao DATETIME NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ci_modelos_ativos' AND object_id = OBJECT_ID('dbo.ci_modelos'))
BEGIN
    CREATE INDEX IX_ci_modelos_ativos ON dbo.ci_modelos (ativo, nome);
END
GO

IF OBJECT_ID('dbo.ci_anexos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ci_anexos (
        id_anexo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        id_ci INT NOT NULL,
        nome_original NVARCHAR(260) NOT NULL,
        nome_arquivo NVARCHAR(260) NOT NULL,
        caminho_relativo NVARCHAR(400) NOT NULL,
        content_type NVARCHAR(120) NULL,
        tamanho_bytes BIGINT NOT NULL,
        ativo BIT NOT NULL CONSTRAINT DF_ci_anexos_ativo DEFAULT (1),
        dt_upload DATETIME NOT NULL CONSTRAINT DF_ci_anexos_dt_upload DEFAULT (GETDATE())
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ci_anexos_ci' AND object_id = OBJECT_ID('dbo.ci_anexos'))
BEGIN
    CREATE INDEX IX_ci_anexos_ci ON dbo.ci_anexos (id_ci, ativo, dt_upload DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ci_modelos WHERE ativo = 1)
BEGIN
    INSERT INTO dbo.ci_modelos (nome, categoria, prioridade, assunto, corpo, providencias)
    VALUES
    (N'Comunicado interno', N'Comunicado', N'Normal', N'Comunicado interno',
     N'Comunicamos que [descreva a informação principal], com validade a partir de [data].' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + N'Solicitamos que todos os envolvidos tomem ciência e sigam as orientações descritas nesta CI.',
     N'Divulgar aos envolvidos, registrar ciência e acompanhar o cumprimento das orientações.'),
    (N'Solicitação interna', N'Solicitação', N'Normal', N'Solicitação interna',
     N'Solicitamos [descreva a solicitação] para atendimento até [data ou prazo].' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + N'Motivo: [descreva o motivo ou contexto].',
     N'Avaliar a solicitação, executar as ações necessárias e retornar ao responsável.'),
    (N'Procedimento interno', N'Procedimento', N'Normal', N'Procedimento interno',
     N'A partir de [data], o procedimento para [tema] deverá seguir as etapas abaixo:' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + N'1. [Etapa 1]' + CHAR(13) + CHAR(10) + N'2. [Etapa 2]' + CHAR(13) + CHAR(10) + N'3. [Etapa 3]' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + N'Em caso de dúvida, procurar o responsável pela origem desta CI.',
     N'Orientar a equipe, aplicar o novo procedimento e reportar eventuais inconsistências.');
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
        SUM(CASE WHEN ativo = 1 AND status_ci = 'Rascunho' THEN 1 ELSE 0 END) AS cis_rascunho,
        SUM(CASE WHEN ativo = 1 AND status_ci = 'Emitida' THEN 1 ELSE 0 END) AS cis_emitidas,
        SUM(CASE WHEN ativo = 1 AND status_ci = 'Revisada' THEN 1 ELSE 0 END) AS cis_revisadas,
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
    @categoria NVARCHAR(60) = NULL,
    @prioridade NVARCHAR(20) = NULL,
    @status_ci NVARCHAR(20) = NULL,
    @origem_area NVARCHAR(120) = NULL,
    @destino_area NVARCHAR(120) = NULL,
    @criado_por NVARCHAR(160) = NULL,
    @termo NVARCHAR(160) = NULL,
    @somente_ativas BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SET @origem_marca = NULLIF(LTRIM(RTRIM(ISNULL(@origem_marca, ''))), '');
    SET @categoria = NULLIF(LTRIM(RTRIM(ISNULL(@categoria, ''))), '');
    SET @prioridade = NULLIF(LTRIM(RTRIM(ISNULL(@prioridade, ''))), '');
    SET @status_ci = NULLIF(LTRIM(RTRIM(ISNULL(@status_ci, ''))), '');
    SET @origem_area = NULLIF(LTRIM(RTRIM(ISNULL(@origem_area, ''))), '');
    SET @destino_area = NULLIF(LTRIM(RTRIM(ISNULL(@destino_area, ''))), '');
    SET @criado_por = NULLIF(LTRIM(RTRIM(ISNULL(@criado_por, ''))), '');
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
        CASE WHEN ativo = 0 THEN 'Cancelada' ELSE ISNULL(NULLIF(status_ci, ''), 'Emitida') END AS status,
        ISNULL(NULLIF(status_ci, ''), CASE WHEN ativo = 1 THEN 'Emitida' ELSE 'Cancelada' END) AS status_ci,
        ativo,
        dt_cadastro
    FROM dbo.ci_comunicacoes
    WHERE (@dt_inicio IS NULL OR data_documento >= @dt_inicio)
      AND (@dt_fim IS NULL OR data_documento <= @dt_fim)
      AND (@origem_marca IS NULL OR origem_marca = @origem_marca)
      AND (@categoria IS NULL OR categoria = @categoria)
      AND (@prioridade IS NULL OR prioridade = @prioridade)
      AND (@status_ci IS NULL OR (CASE WHEN ativo = 0 THEN 'Cancelada' ELSE ISNULL(NULLIF(status_ci, ''), 'Emitida') END) = @status_ci)
      AND (@origem_area IS NULL OR origem_area LIKE '%' + @origem_area + '%')
      AND (@destino_area IS NULL OR destino_area LIKE '%' + @destino_area + '%')
      AND (@criado_por IS NULL OR criado_por LIKE '%' + @criado_por + '%')
      AND (@somente_ativas = 0 OR ativo = 1)
      AND (
            @termo IS NULL
            OR ('CI-' + CAST(ano AS VARCHAR(4)) + '-' + RIGHT('0000' + CAST(numero AS VARCHAR(10)), 4)) LIKE '%' + @termo + '%'
            OR CAST(numero AS VARCHAR(10)) LIKE '%' + @termo + '%'
            OR assunto LIKE '%' + @termo + '%'
            OR origem_area LIKE '%' + @termo + '%'
            OR origem_responsavel LIKE '%' + @termo + '%'
            OR destino_area LIKE '%' + @termo + '%'
            OR destinatario LIKE '%' + @termo + '%'
            OR categoria LIKE '%' + @termo + '%'
            OR criado_por LIKE '%' + @termo + '%'
            OR corpo LIKE '%' + @termo + '%'
          )
    ORDER BY data_documento DESC, id_ci DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_anexo_registrar
    @id_ci INT,
    @nome_original NVARCHAR(260),
    @nome_arquivo NVARCHAR(260),
    @caminho_relativo NVARCHAR(400),
    @content_type NVARCHAR(120) = NULL,
    @tamanho_bytes BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.ci_comunicacoes WHERE id_ci = @id_ci)
    BEGIN
        RAISERROR(N'CI nao encontrada para vincular o anexo.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.ci_anexos
        (id_ci, nome_original, nome_arquivo, caminho_relativo, content_type, tamanho_bytes)
    VALUES
        (@id_ci, @nome_original, @nome_arquivo, @caminho_relativo, @content_type, @tamanho_bytes);
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_anexo_listar
    @id_ci INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_anexo,
        id_ci,
        nome_original,
        nome_arquivo,
        caminho_relativo,
        ISNULL(content_type, '') AS content_type,
        tamanho_bytes,
        CAST(CASE
            WHEN tamanho_bytes >= 1048576 THEN CAST(CAST(tamanho_bytes / 1048576.0 AS DECIMAL(10,2)) AS NVARCHAR(30)) + N' MB'
            ELSE CAST(CAST(tamanho_bytes / 1024.0 AS DECIMAL(10,2)) AS NVARCHAR(30)) + N' KB'
        END AS NVARCHAR(40)) AS tamanho_formatado,
        dt_upload
    FROM dbo.ci_anexos
    WHERE id_ci = @id_ci
      AND ativo = 1
    ORDER BY dt_upload DESC, id_anexo DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_anexo_excluir
    @id_anexo INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ci_anexos
    SET ativo = 0
    WHERE id_anexo = @id_anexo;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_modelo_listar
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_modelo,
        nome,
        ISNULL(origem_marca, '') AS origem_marca,
        categoria,
        prioridade,
        assunto,
        dt_alteracao,
        dt_cadastro
    FROM dbo.ci_modelos
    WHERE ativo = 1
    ORDER BY nome;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_modelo_obter
    @id_modelo INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_modelo,
        nome,
        ISNULL(origem_marca, '') AS origem_marca,
        categoria,
        prioridade,
        assunto,
        corpo,
        ISNULL(providencias, '') AS providencias,
        ISNULL(observacoes, '') AS observacoes
    FROM dbo.ci_modelos
    WHERE id_modelo = @id_modelo
      AND ativo = 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_modelo_salvar
    @id_modelo INT = NULL,
    @nome NVARCHAR(120),
    @origem_marca NVARCHAR(40) = NULL,
    @categoria NVARCHAR(60),
    @prioridade NVARCHAR(20),
    @assunto NVARCHAR(200),
    @corpo NVARCHAR(MAX),
    @providencias NVARCHAR(MAX) = NULL,
    @observacoes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @nome = LTRIM(RTRIM(ISNULL(@nome, '')));
    SET @origem_marca = NULLIF(LTRIM(RTRIM(ISNULL(@origem_marca, ''))), '');
    SET @categoria = LTRIM(RTRIM(ISNULL(@categoria, '')));
    SET @prioridade = LTRIM(RTRIM(ISNULL(@prioridade, 'Normal')));
    SET @assunto = LTRIM(RTRIM(ISNULL(@assunto, '')));
    SET @corpo = LTRIM(RTRIM(ISNULL(@corpo, '')));

    IF @nome = '' OR @categoria = '' OR @prioridade = '' OR @assunto = '' OR @corpo = ''
    BEGIN
        RAISERROR(N'Informe nome, categoria, prioridade, assunto e texto para salvar o modelo.', 16, 1);
        RETURN;
    END

    IF ISNULL(@id_modelo, 0) = 0
    BEGIN
        INSERT INTO dbo.ci_modelos
            (nome, origem_marca, categoria, prioridade, assunto, corpo, providencias, observacoes)
        VALUES
            (@nome, @origem_marca, @categoria, @prioridade, @assunto, @corpo, NULLIF(@providencias, ''), NULLIF(@observacoes, ''));

        SET @id_modelo = CONVERT(INT, SCOPE_IDENTITY());
    END
    ELSE
    BEGIN
        UPDATE dbo.ci_modelos
        SET nome = @nome,
            origem_marca = @origem_marca,
            categoria = @categoria,
            prioridade = @prioridade,
            assunto = @assunto,
            corpo = @corpo,
            providencias = NULLIF(@providencias, ''),
            observacoes = NULLIF(@observacoes, ''),
            dt_alteracao = GETDATE()
        WHERE id_modelo = @id_modelo
          AND ativo = 1;
    END

    EXEC dbo.ci_modelo_obter @id_modelo = @id_modelo;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_modelo_excluir
    @id_modelo INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ci_modelos
    SET ativo = 0,
        dt_alteracao = GETDATE()
    WHERE id_modelo = @id_modelo;
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
        ISNULL(NULLIF(status_ci, ''), CASE WHEN ativo = 1 THEN 'Emitida' ELSE 'Cancelada' END) AS status_ci,
        ativo,
        CASE WHEN ativo = 0 THEN 'Cancelada' ELSE ISNULL(NULLIF(status_ci, ''), 'Emitida') END AS status,
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
    @status_ci NVARCHAR(20) = 'Emitida',
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
    SET @status_ci = LTRIM(RTRIM(ISNULL(@status_ci, 'Emitida')));
    SET @corpo = LTRIM(RTRIM(ISNULL(@corpo, '')));

    DECLARE @erro_obrigatorios NVARCHAR(200);
    SET @erro_obrigatorios = N'Preencha todos os campos obrigat' + NCHAR(243) + N'rios da CI.';

    IF @data_documento IS NULL OR @origem_marca = '' OR @origem_area = '' OR @origem_responsavel = ''
        OR @destino_area = '' OR @destinatario = '' OR @assunto = '' OR @categoria = ''
        OR @prioridade = '' OR @corpo = ''
    BEGIN
        RAISERROR(@erro_obrigatorios, 16, 1);
        RETURN;
    END

    IF @status_ci NOT IN ('Rascunho', 'Emitida', 'Revisada')
    BEGIN
        SET @status_ci = 'Emitida';
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
            categoria, prioridade, status_ci, corpo, providencias, observacoes, criado_por
        )
        VALUES
        (
            @ano, @numero, @data_documento, @origem_marca, @origem_area,
            @origem_responsavel, @destino_area, @destinatario, @assunto,
            @categoria, @prioridade, @status_ci, @corpo, NULLIF(@providencias, ''),
            NULLIF(@observacoes, ''), NULLIF(@criado_por, '')
        );

        SET @id_ci = CONVERT(INT, SCOPE_IDENTITY());
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        DECLARE @usuario_historico NVARCHAR(160) = NULLIF(@criado_por, '');

        INSERT INTO dbo.ci_comunicacoes_historico
        (
            id_ci, acao, ano, numero, data_documento, origem_marca, origem_area,
            origem_responsavel, destino_area, destinatario, assunto, categoria,
            prioridade, corpo, providencias, observacoes, criado_por, status_ci, ativo
        )
        SELECT
            id_ci, N'Altera' + NCHAR(231) + NCHAR(227) + N'o', ano, numero, data_documento, origem_marca, origem_area,
            origem_responsavel, destino_area, destinatario, assunto, categoria,
            prioridade, corpo, providencias, observacoes, criado_por, status_ci, ativo
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci
          AND ativo = 1;

        INSERT INTO dbo.ci_comunicacoes_historico_campos (id_ci, campo, valor_antigo, valor_novo, usuario)
        SELECT @id_ci, N'Data da CI', CONVERT(NVARCHAR(30), data_documento, 103), CONVERT(NVARCHAR(30), @data_documento, 103), @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(CONVERT(NVARCHAR(30), data_documento, 23), '') <> ISNULL(CONVERT(NVARCHAR(30), @data_documento, 23), '')
        UNION ALL
        SELECT @id_ci, N'Marca', origem_marca, @origem_marca, @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(origem_marca, '') <> ISNULL(@origem_marca, '')
        UNION ALL
        SELECT @id_ci, N'Area de origem', origem_area, @origem_area, @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(origem_area, '') <> ISNULL(@origem_area, '')
        UNION ALL
        SELECT @id_ci, N'Responsavel', origem_responsavel, @origem_responsavel, @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(origem_responsavel, '') <> ISNULL(@origem_responsavel, '')
        UNION ALL
        SELECT @id_ci, N'Area de destino', destino_area, @destino_area, @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(destino_area, '') <> ISNULL(@destino_area, '')
        UNION ALL
        SELECT @id_ci, N'Destinatario', destinatario, @destinatario, @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(destinatario, '') <> ISNULL(@destinatario, '')
        UNION ALL
        SELECT @id_ci, N'Assunto', assunto, @assunto, @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(assunto, '') <> ISNULL(@assunto, '')
        UNION ALL
        SELECT @id_ci, N'Categoria', categoria, @categoria, @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(categoria, '') <> ISNULL(@categoria, '')
        UNION ALL
        SELECT @id_ci, N'Prioridade', prioridade, @prioridade, @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(prioridade, '') <> ISNULL(@prioridade, '')
        UNION ALL
        SELECT @id_ci, N'Status', status_ci, @status_ci, @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(status_ci, '') <> ISNULL(@status_ci, '')
        UNION ALL
        SELECT @id_ci, N'Texto', corpo, @corpo, @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(corpo, '') <> ISNULL(@corpo, '')
        UNION ALL
        SELECT @id_ci, N'Providencias', ISNULL(providencias, ''), ISNULL(@providencias, ''), @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(providencias, '') <> ISNULL(@providencias, '')
        UNION ALL
        SELECT @id_ci, N'Observacoes', ISNULL(observacoes, ''), ISNULL(@observacoes, ''), @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(observacoes, '') <> ISNULL(@observacoes, '')
        UNION ALL
        SELECT @id_ci, N'Criado por', ISNULL(criado_por, ''), ISNULL(@criado_por, ''), @usuario_historico
        FROM dbo.ci_comunicacoes
        WHERE id_ci = @id_ci AND ativo = 1 AND ISNULL(criado_por, '') <> ISNULL(@criado_por, '');

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
            status_ci = @status_ci,
            corpo = @corpo,
            providencias = NULLIF(@providencias, ''),
            observacoes = NULLIF(@observacoes, ''),
            criado_por = NULLIF(@criado_por, ''),
            dt_alteracao = GETDATE()
        WHERE id_ci = @id_ci
          AND ativo = 1;

        IF @@ROWCOUNT = 0
        BEGIN
            DECLARE @erro_cancelada NVARCHAR(200);
            SET @erro_cancelada = N'N' + NCHAR(227) + N'o foi poss' + NCHAR(237) + N'vel salvar: CI inexistente ou cancelada.';
            RAISERROR(@erro_cancelada, 16, 1);
            RETURN;
        END
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
        status_ci,
        ativo,
        dt_evento
    FROM dbo.ci_comunicacoes_historico
    WHERE id_ci = @id_ci
    ORDER BY dt_evento DESC, id_historico DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_comunicacao_historico_campos_listar
    @id_ci INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 100
        id_historico_campo,
        id_ci,
        campo,
        valor_antigo,
        valor_novo,
        ISNULL(usuario, '') AS usuario,
        dt_evento
    FROM dbo.ci_comunicacoes_historico_campos
    WHERE id_ci = @id_ci
    ORDER BY dt_evento DESC, id_historico_campo DESC;
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
        prioridade, corpo, providencias, observacoes, criado_por, status_ci, ativo
    )
    SELECT
        id_ci, N'Cancelamento', ano, numero, data_documento, origem_marca, origem_area,
        origem_responsavel, destino_area, destinatario, assunto, categoria,
        prioridade, corpo, providencias, observacoes, criado_por, status_ci, ativo
    FROM dbo.ci_comunicacoes
    WHERE id_ci = @id_ci
      AND ativo = 1;

    UPDATE dbo.ci_comunicacoes
    SET ativo = 0,
        status_ci = 'Cancelada',
        dt_alteracao = GETDATE()
    WHERE id_ci = @id_ci;
END
GO
