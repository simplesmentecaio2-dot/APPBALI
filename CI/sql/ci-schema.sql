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

IF OBJECT_ID('dbo.ci_ciencias', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ci_ciencias (
        id_ciencia INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        id_ci INT NOT NULL,
        setor NVARCHAR(120) NOT NULL,
        responsavel NVARCHAR(160) NOT NULL,
        observacao NVARCHAR(500) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_ci_ciencias_ativo DEFAULT (1),
        dt_ciencia DATETIME NOT NULL CONSTRAINT DF_ci_ciencias_dt_ciencia DEFAULT (GETDATE())
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ci_ciencias_ci' AND object_id = OBJECT_ID('dbo.ci_ciencias'))
BEGIN
    CREATE INDEX IX_ci_ciencias_ci ON dbo.ci_ciencias (id_ci, ativo, dt_ciencia DESC);
END
GO

IF OBJECT_ID('dbo.ci_anexo_registrar', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.ci_anexo_registrar;
END
GO

IF OBJECT_ID('dbo.ci_anexo_listar', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.ci_anexo_listar;
END
GO

IF OBJECT_ID('dbo.ci_anexo_excluir', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.ci_anexo_excluir;
END
GO

IF OBJECT_ID('dbo.ci_anotacoes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ci_anotacoes (
        id_anotacao INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        titulo NVARCHAR(160) NOT NULL,
        categoria NVARCHAR(80) NULL,
        tags NVARCHAR(300) NULL,
        conteudo NVARCHAR(MAX) NOT NULL,
        criado_por NVARCHAR(160) NULL,
        favorito BIT NOT NULL CONSTRAINT DF_ci_anotacoes_favorito DEFAULT (0),
        qtde_usos INT NOT NULL CONSTRAINT DF_ci_anotacoes_qtde_usos DEFAULT (0),
        dt_ultimo_uso DATETIME NULL,
        ativo BIT NOT NULL CONSTRAINT DF_ci_anotacoes_ativo DEFAULT (1),
        dt_cadastro DATETIME NOT NULL CONSTRAINT DF_ci_anotacoes_dt_cadastro DEFAULT (GETDATE()),
        dt_alteracao DATETIME NULL
    );
END
GO

IF COL_LENGTH('dbo.ci_anotacoes', 'tags') IS NULL
BEGIN
    ALTER TABLE dbo.ci_anotacoes ADD tags NVARCHAR(300) NULL;
END
GO

IF COL_LENGTH('dbo.ci_anotacoes', 'favorito') IS NULL
BEGIN
    ALTER TABLE dbo.ci_anotacoes
        ADD favorito BIT NOT NULL CONSTRAINT DF_ci_anotacoes_favorito DEFAULT (0);
END
GO

IF COL_LENGTH('dbo.ci_anotacoes', 'qtde_usos') IS NULL
BEGIN
    ALTER TABLE dbo.ci_anotacoes
        ADD qtde_usos INT NOT NULL CONSTRAINT DF_ci_anotacoes_qtde_usos DEFAULT (0);
END
GO

IF COL_LENGTH('dbo.ci_anotacoes', 'dt_ultimo_uso') IS NULL
BEGIN
    ALTER TABLE dbo.ci_anotacoes ADD dt_ultimo_uso DATETIME NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ci_anotacoes_busca' AND object_id = OBJECT_ID('dbo.ci_anotacoes'))
BEGIN
    CREATE INDEX IX_ci_anotacoes_busca ON dbo.ci_anotacoes (ativo, favorito, categoria, titulo, dt_alteracao);
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

CREATE OR ALTER PROCEDURE dbo.ci_anotacao_listar
    @termo NVARCHAR(160) = NULL,
    @categoria NVARCHAR(80) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @termo = NULLIF(LTRIM(RTRIM(ISNULL(@termo, ''))), '');
    SET @categoria = NULLIF(LTRIM(RTRIM(ISNULL(@categoria, ''))), '');

    SELECT TOP 300
        id_anotacao,
        titulo,
        ISNULL(categoria, '') AS categoria,
        ISNULL(tags, '') AS tags,
        LEFT(REPLACE(REPLACE(conteudo, CHAR(13), ' '), CHAR(10), ' '), 220) AS resumo,
        ISNULL(criado_por, '') AS criado_por,
        favorito,
        qtde_usos,
        dt_ultimo_uso,
        dt_cadastro,
        dt_alteracao,
        ISNULL(dt_alteracao, dt_cadastro) AS dt_referencia
    FROM dbo.ci_anotacoes
    WHERE ativo = 1
      AND (@categoria IS NULL OR categoria = @categoria)
      AND (
            @termo IS NULL
            OR titulo COLLATE Latin1_General_CI_AI LIKE ('%' + @termo + '%') COLLATE Latin1_General_CI_AI
            OR categoria COLLATE Latin1_General_CI_AI LIKE ('%' + @termo + '%') COLLATE Latin1_General_CI_AI
            OR tags COLLATE Latin1_General_CI_AI LIKE ('%' + @termo + '%') COLLATE Latin1_General_CI_AI
            OR conteudo COLLATE Latin1_General_CI_AI LIKE ('%' + @termo + '%') COLLATE Latin1_General_CI_AI
            OR criado_por COLLATE Latin1_General_CI_AI LIKE ('%' + @termo + '%') COLLATE Latin1_General_CI_AI
          )
    ORDER BY favorito DESC, qtde_usos DESC, ISNULL(dt_alteracao, dt_cadastro) DESC, titulo;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_anotacao_categorias
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT categoria
    FROM dbo.ci_anotacoes
    WHERE ativo = 1
      AND NULLIF(LTRIM(RTRIM(ISNULL(categoria, ''))), '') IS NOT NULL
    ORDER BY categoria;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_anotacao_obter
    @id_anotacao INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_anotacao,
        titulo,
        ISNULL(categoria, '') AS categoria,
        ISNULL(tags, '') AS tags,
        conteudo,
        ISNULL(criado_por, '') AS criado_por,
        favorito,
        qtde_usos,
        dt_ultimo_uso,
        dt_cadastro,
        dt_alteracao
    FROM dbo.ci_anotacoes
    WHERE id_anotacao = @id_anotacao
      AND ativo = 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_anotacao_salvar
    @id_anotacao INT = NULL,
    @titulo NVARCHAR(160),
    @categoria NVARCHAR(80) = NULL,
    @tags NVARCHAR(300) = NULL,
    @conteudo NVARCHAR(MAX),
    @criado_por NVARCHAR(160) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @titulo = LTRIM(RTRIM(ISNULL(@titulo, '')));
    SET @categoria = NULLIF(LTRIM(RTRIM(ISNULL(@categoria, ''))), '');
    SET @tags = NULLIF(LTRIM(RTRIM(ISNULL(@tags, ''))), '');
    SET @conteudo = LTRIM(RTRIM(ISNULL(@conteudo, '')));
    SET @criado_por = NULLIF(LTRIM(RTRIM(ISNULL(@criado_por, ''))), '');

    IF @titulo = '' OR @conteudo = ''
    BEGIN
        DECLARE @erro_anotacao_obrigatoria NVARCHAR(200);
        SET @erro_anotacao_obrigatoria = N'Informe o nome da anota' + NCHAR(231) + NCHAR(227) + N'o e o texto padr' + NCHAR(227) + N'o.';
        RAISERROR(@erro_anotacao_obrigatoria, 16, 1);
        RETURN;
    END

    IF ISNULL(@id_anotacao, 0) = 0
    BEGIN
        INSERT INTO dbo.ci_anotacoes (titulo, categoria, tags, conteudo, criado_por)
        VALUES (@titulo, @categoria, @tags, @conteudo, @criado_por);

        SET @id_anotacao = CONVERT(INT, SCOPE_IDENTITY());
    END
    ELSE
    BEGIN
        UPDATE dbo.ci_anotacoes
        SET titulo = @titulo,
            categoria = @categoria,
            tags = @tags,
            conteudo = @conteudo,
            criado_por = @criado_por,
            dt_alteracao = GETDATE()
        WHERE id_anotacao = @id_anotacao
          AND ativo = 1;

        IF @@ROWCOUNT = 0
        BEGIN
            DECLARE @erro_anotacao_inexistente NVARCHAR(200);
            SET @erro_anotacao_inexistente = N'N' + NCHAR(227) + N'o foi poss' + NCHAR(237) + N'vel salvar: anota' + NCHAR(231) + NCHAR(227) + N'o inexistente ou exclu' + NCHAR(237) + N'da.';
            RAISERROR(@erro_anotacao_inexistente, 16, 1);
            RETURN;
        END
    END

    EXEC dbo.ci_anotacao_obter @id_anotacao = @id_anotacao;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_anotacao_alternar_favorito
    @id_anotacao INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ci_anotacoes
    SET favorito = CASE WHEN favorito = 1 THEN 0 ELSE 1 END,
        dt_alteracao = GETDATE()
    WHERE id_anotacao = @id_anotacao
      AND ativo = 1;

    EXEC dbo.ci_anotacao_obter @id_anotacao = @id_anotacao;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_anotacao_registrar_uso
    @id_anotacao INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ci_anotacoes
    SET qtde_usos = ISNULL(qtde_usos, 0) + 1,
        dt_ultimo_uso = GETDATE()
    WHERE id_anotacao = @id_anotacao
      AND ativo = 1;

    EXEC dbo.ci_anotacao_obter @id_anotacao = @id_anotacao;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_anotacao_excluir
    @id_anotacao INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ci_anotacoes
    SET ativo = 0,
        dt_alteracao = GETDATE()
    WHERE id_anotacao = @id_anotacao;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_ciencia_registrar
    @id_ci INT,
    @setor NVARCHAR(120),
    @responsavel NVARCHAR(160),
    @observacao NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @setor = LTRIM(RTRIM(ISNULL(@setor, '')));
    SET @responsavel = LTRIM(RTRIM(ISNULL(@responsavel, '')));
    SET @observacao = NULLIF(LTRIM(RTRIM(ISNULL(@observacao, ''))), '');

    IF @setor = '' OR @responsavel = ''
    BEGIN
        RAISERROR(N'Informe setor e responsavel para registrar ciencia.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.ci_comunicacoes WHERE id_ci = @id_ci)
    BEGIN
        RAISERROR(N'CI nao encontrada para registrar ciencia.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.ci_ciencias (id_ci, setor, responsavel, observacao)
    VALUES (@id_ci, @setor, @responsavel, @observacao);
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_ciencia_listar
    @id_ci INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_ciencia,
        id_ci,
        setor,
        responsavel,
        ISNULL(observacao, '') AS observacao,
        dt_ciencia
    FROM dbo.ci_ciencias
    WHERE id_ci = @id_ci
      AND ativo = 1
    ORDER BY dt_ciencia DESC, id_ciencia DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_ciencia_excluir
    @id_ciencia INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ci_ciencias
    SET ativo = 0
    WHERE id_ciencia = @id_ciencia;
END
GO

CREATE OR ALTER PROCEDURE dbo.ci_comunicacao_bi
    @dt_inicio DATE = NULL,
    @dt_fim DATE = NULL,
    @origem_marca NVARCHAR(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @origem_marca = NULLIF(LTRIM(RTRIM(ISNULL(@origem_marca, ''))), '');

    SELECT
        id_ci,
        ano,
        numero,
        data_documento,
        origem_marca,
        origem_area,
        destino_area,
        destinatario,
        categoria,
        prioridade,
        criado_por,
        CASE WHEN ativo = 0 THEN 'Cancelada' ELSE ISNULL(NULLIF(status_ci, ''), 'Emitida') END AS status
    INTO #ci_bi_base
    FROM dbo.ci_comunicacoes
    WHERE (@dt_inicio IS NULL OR data_documento >= @dt_inicio)
      AND (@dt_fim IS NULL OR data_documento <= @dt_fim)
      AND (@origem_marca IS NULL OR origem_marca = @origem_marca);

    SELECT
        COUNT(1) AS total_cis,
        SUM(CASE WHEN status = 'Emitida' THEN 1 ELSE 0 END) AS emitidas,
        SUM(CASE WHEN status = 'Rascunho' THEN 1 ELSE 0 END) AS rascunhos,
        SUM(CASE WHEN status = 'Revisada' THEN 1 ELSE 0 END) AS revisadas,
        SUM(CASE WHEN status = 'Cancelada' THEN 1 ELSE 0 END) AS canceladas,
        (SELECT COUNT(1) FROM dbo.ci_ciencias c INNER JOIN #ci_bi_base b ON b.id_ci = c.id_ci WHERE c.ativo = 1) AS ciencias
    FROM #ci_bi_base;

    SELECT TOP 12 origem_marca AS rotulo, COUNT(1) AS total
    FROM #ci_bi_base
    GROUP BY origem_marca
    ORDER BY total DESC, origem_marca;

    SELECT TOP 12 categoria AS rotulo, COUNT(1) AS total
    FROM #ci_bi_base
    GROUP BY categoria
    ORDER BY total DESC, categoria;

    SELECT TOP 12 prioridade AS rotulo, COUNT(1) AS total
    FROM #ci_bi_base
    GROUP BY prioridade
    ORDER BY total DESC, prioridade;

    SELECT CONVERT(VARCHAR(10), data_documento, 103) AS rotulo, COUNT(1) AS total
    FROM #ci_bi_base
    GROUP BY data_documento
    ORDER BY data_documento;

    SELECT TOP 10 destino_area AS rotulo, COUNT(1) AS total
    FROM #ci_bi_base
    GROUP BY destino_area
    ORDER BY total DESC, destino_area;

    SELECT TOP 10 ISNULL(NULLIF(criado_por, ''), 'Não informado') AS rotulo, COUNT(1) AS total
    FROM #ci_bi_base
    GROUP BY ISNULL(NULLIF(criado_por, ''), 'Não informado')
    ORDER BY total DESC, rotulo;

    SELECT TOP 12 status AS rotulo, COUNT(1) AS total
    FROM #ci_bi_base
    GROUP BY status
    ORDER BY total DESC, status;

    SELECT TOP 12 origem_area AS rotulo, COUNT(1) AS total
    FROM #ci_bi_base
    GROUP BY origem_area
    ORDER BY total DESC, origem_area;

    SELECT TOP 12
        'CI-' + CAST(b.ano AS VARCHAR(4)) + '-' + RIGHT('0000' + CAST(b.numero AS VARCHAR(10)), 4) + ' - ' + ISNULL(NULLIF(b.destinatario, ''), 'Sem destinatario') AS rotulo,
        1 AS total
    FROM #ci_bi_base b
    WHERE b.status <> 'Cancelada'
      AND NOT EXISTS (
            SELECT 1
            FROM dbo.ci_ciencias c
            WHERE c.id_ci = b.id_ci
              AND c.ativo = 1
      )
    ORDER BY b.data_documento DESC, b.id_ci DESC;

    DROP TABLE #ci_bi_base;
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

        IF @@ROWCOUNT = 0
        BEGIN
            DECLARE @erro_modelo_inexistente NVARCHAR(200);
            SET @erro_modelo_inexistente = N'N' + NCHAR(227) + N'o foi poss' + NCHAR(237) + N'vel salvar: modelo inexistente ou exclu' + NCHAR(237) + N'do.';
            RAISERROR(@erro_modelo_inexistente, 16, 1);
            RETURN;
        END
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

CREATE OR ALTER PROCEDURE dbo.ci_comunicacao_localizar
    @termo NVARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @codigo NVARCHAR(60) = UPPER(LTRIM(RTRIM(ISNULL(@termo, ''))));
    SET @codigo = REPLACE(REPLACE(REPLACE(REPLACE(@codigo, ' ', ''), '_', '-'), '/', '-'), '.', '-');

    DECLARE @codigo_sem_ci NVARCHAR(60) = @codigo;
    IF LEFT(@codigo_sem_ci, 3) = 'CI-'
    BEGIN
        SET @codigo_sem_ci = SUBSTRING(@codigo_sem_ci, 4, 60);
    END

    DECLARE @numero_informado INT = NULL;
    IF @codigo_sem_ci <> '' AND @codigo_sem_ci NOT LIKE '%[^0-9]%'
    BEGIN
        SET @numero_informado = CONVERT(INT, @codigo_sem_ci);
    END

    DECLARE @ano_informado INT = NULL;
    DECLARE @sequencia_informada INT = NULL;
    IF LEN(@codigo_sem_ci) > 5 AND SUBSTRING(@codigo_sem_ci, 5, 1) = '-'
    BEGIN
        DECLARE @ano_texto NVARCHAR(4) = LEFT(@codigo_sem_ci, 4);
        DECLARE @sequencia_texto NVARCHAR(20) = SUBSTRING(@codigo_sem_ci, 6, 20);
        IF @ano_texto NOT LIKE '%[^0-9]%' AND @sequencia_texto NOT LIKE '%[^0-9]%'
        BEGIN
            SET @ano_informado = CONVERT(INT, @ano_texto);
            SET @sequencia_informada = CONVERT(INT, @sequencia_texto);
        END
    END

    SELECT TOP 1
        id_ci,
        'CI-' + CAST(ano AS VARCHAR(4)) + '-' + RIGHT('0000' + CAST(numero AS VARCHAR(10)), 4) AS codigo_ci,
        ano,
        numero
    FROM dbo.ci_comunicacoes
    WHERE UPPER('CI-' + CAST(ano AS VARCHAR(4)) + '-' + RIGHT('0000' + CAST(numero AS VARCHAR(10)), 4)) = @codigo
       OR (CAST(ano AS VARCHAR(4)) + '-' + RIGHT('0000' + CAST(numero AS VARCHAR(10)), 4)) = @codigo_sem_ci
       OR (@ano_informado IS NOT NULL AND @sequencia_informada IS NOT NULL AND ano = @ano_informado AND numero = @sequencia_informada)
       OR (@numero_informado IS NOT NULL AND id_ci = @numero_informado)
       OR (@numero_informado IS NOT NULL AND numero = @numero_informado)
    ORDER BY
        CASE
            WHEN UPPER('CI-' + CAST(ano AS VARCHAR(4)) + '-' + RIGHT('0000' + CAST(numero AS VARCHAR(10)), 4)) = @codigo THEN 0
            WHEN @ano_informado IS NOT NULL AND @sequencia_informada IS NOT NULL AND ano = @ano_informado AND numero = @sequencia_informada THEN 1
            WHEN @numero_informado IS NOT NULL AND id_ci = @numero_informado THEN 2
            ELSE 3
        END,
        ano DESC,
        numero DESC,
        id_ci DESC;
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

    IF @status_ci NOT IN ('Rascunho', 'Emitida', 'Revisada')
    BEGIN
        SET @status_ci = 'Emitida';
    END

    IF @status_ci = 'Rascunho'
    BEGIN
        IF @origem_area = '' SET @origem_area = N'A definir';
        IF @origem_responsavel = '' SET @origem_responsavel = N'A definir';
        IF @destino_area = '' SET @destino_area = N'A definir';
        IF @destinatario = '' SET @destinatario = N'A definir';
        IF @assunto = '' SET @assunto = N'Rascunho de CI';
        IF @categoria = '' SET @categoria = N'Comunicado';
        IF @prioridade = '' SET @prioridade = N'Normal';
        IF @corpo = '' SET @corpo = N'Texto a definir.';
    END

    DECLARE @erro_obrigatorios NVARCHAR(200);
    SET @erro_obrigatorios = N'Preencha todos os campos obrigat' + NCHAR(243) + N'rios da CI.';

    IF @data_documento IS NULL OR @origem_marca = '' OR @origem_area = '' OR @origem_responsavel = ''
        OR @destino_area = '' OR @destinatario = '' OR @assunto = '' OR @categoria = ''
        OR @prioridade = '' OR @corpo = ''
    BEGIN
        RAISERROR(@erro_obrigatorios, 16, 1);
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
