USE APPWF;
GO

IF OBJECT_ID('dbo.ramais_lojas', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ramais_lojas (
        id_loja INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        nome NVARCHAR(120) NOT NULL,
        ativo BIT NOT NULL CONSTRAINT DF_ramais_lojas_ativo DEFAULT (1),
        dt_cadastro DATETIME NOT NULL CONSTRAINT DF_ramais_lojas_dt_cadastro DEFAULT (GETDATE()),
        dt_alteracao DATETIME NULL
    );
END
GO

IF OBJECT_ID('dbo.ramais_setores', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ramais_setores (
        id_setor INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        nome NVARCHAR(120) NOT NULL,
        ativo BIT NOT NULL CONSTRAINT DF_ramais_setores_ativo DEFAULT (1),
        dt_cadastro DATETIME NOT NULL CONSTRAINT DF_ramais_setores_dt_cadastro DEFAULT (GETDATE()),
        dt_alteracao DATETIME NULL
    );
END
GO

IF OBJECT_ID('dbo.ramais', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ramais (
        id_ramal INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        nome NVARCHAR(160) NOT NULL,
        ramal NVARCHAR(30) NOT NULL,
        id_loja INT NOT NULL,
        id_setor INT NOT NULL,
        ativo BIT NOT NULL CONSTRAINT DF_ramais_ativo DEFAULT (1),
        dt_cadastro DATETIME NOT NULL CONSTRAINT DF_ramais_dt_cadastro DEFAULT (GETDATE()),
        dt_alteracao DATETIME NULL,
        CONSTRAINT FK_ramais_lojas FOREIGN KEY (id_loja) REFERENCES dbo.ramais_lojas(id_loja),
        CONSTRAINT FK_ramais_setores FOREIGN KEY (id_setor) REFERENCES dbo.ramais_setores(id_setor)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ramais_filtros' AND object_id = OBJECT_ID('dbo.ramais'))
BEGIN
    CREATE INDEX IX_ramais_filtros ON dbo.ramais (ativo, id_loja, id_setor, nome, ramal);
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_resumo
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        (SELECT COUNT(1) FROM dbo.ramais WHERE ativo = 1) AS total_ramais,
        (SELECT COUNT(1) FROM dbo.ramais_lojas WHERE ativo = 1) AS total_lojas,
        (SELECT COUNT(1) FROM dbo.ramais_setores WHERE ativo = 1) AS total_setores;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_loja_listar
    @somente_ativas BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id_loja, nome, ativo,
           CASE WHEN ativo = 1 THEN 'Ativo' ELSE 'Inativo' END AS status,
           dt_cadastro, dt_alteracao
    FROM dbo.ramais_lojas
    WHERE (@somente_ativas = 0 OR ativo = 1)
    ORDER BY nome;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_loja_obter
    @id_loja INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id_loja, nome, ativo,
           CASE WHEN ativo = 1 THEN 'Ativo' ELSE 'Inativo' END AS status,
           dt_cadastro, dt_alteracao
    FROM dbo.ramais_lojas
    WHERE id_loja = @id_loja;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_loja_salvar
    @id_loja INT = NULL,
    @nome NVARCHAR(120),
    @ativo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET @nome = LTRIM(RTRIM(ISNULL(@nome, '')));

    IF @nome = ''
    BEGIN
        RAISERROR('Informe o nome da loja.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM dbo.ramais_lojas
        WHERE UPPER(LTRIM(RTRIM(nome))) = UPPER(@nome)
          AND ativo = 1
          AND (ISNULL(@id_loja, 0) = 0 OR id_loja <> @id_loja)
    )
    BEGIN
        RAISERROR('Já existe uma loja ativa com esse nome.', 16, 1);
        RETURN;
    END

    IF ISNULL(@id_loja, 0) = 0
    BEGIN
        INSERT INTO dbo.ramais_lojas (nome, ativo) VALUES (@nome, @ativo);
        SET @id_loja = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.ramais_lojas
        SET nome = @nome, ativo = @ativo, dt_alteracao = GETDATE()
        WHERE id_loja = @id_loja;
    END

    EXEC dbo.ramais_loja_obter @id_loja;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_loja_excluir
    @id_loja INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.ramais WHERE id_loja = @id_loja AND ativo = 1)
    BEGIN
        RAISERROR('Não foi possível excluir: existe ramal ativo vinculado a esta loja.', 16, 1);
        RETURN;
    END

    UPDATE dbo.ramais_lojas
    SET ativo = 0, dt_alteracao = GETDATE()
    WHERE id_loja = @id_loja;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_setor_listar
    @somente_ativos BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id_setor, nome, ativo,
           CASE WHEN ativo = 1 THEN 'Ativo' ELSE 'Inativo' END AS status,
           dt_cadastro, dt_alteracao
    FROM dbo.ramais_setores
    WHERE (@somente_ativos = 0 OR ativo = 1)
    ORDER BY nome;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_setor_obter
    @id_setor INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id_setor, nome, ativo,
           CASE WHEN ativo = 1 THEN 'Ativo' ELSE 'Inativo' END AS status,
           dt_cadastro, dt_alteracao
    FROM dbo.ramais_setores
    WHERE id_setor = @id_setor;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_setor_salvar
    @id_setor INT = NULL,
    @nome NVARCHAR(120),
    @ativo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET @nome = LTRIM(RTRIM(ISNULL(@nome, '')));

    IF @nome = ''
    BEGIN
        RAISERROR('Informe o nome do setor.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM dbo.ramais_setores
        WHERE UPPER(LTRIM(RTRIM(nome))) = UPPER(@nome)
          AND ativo = 1
          AND (ISNULL(@id_setor, 0) = 0 OR id_setor <> @id_setor)
    )
    BEGIN
        RAISERROR('Já existe um setor ativo com esse nome.', 16, 1);
        RETURN;
    END

    IF ISNULL(@id_setor, 0) = 0
    BEGIN
        INSERT INTO dbo.ramais_setores (nome, ativo) VALUES (@nome, @ativo);
        SET @id_setor = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.ramais_setores
        SET nome = @nome, ativo = @ativo, dt_alteracao = GETDATE()
        WHERE id_setor = @id_setor;
    END

    EXEC dbo.ramais_setor_obter @id_setor;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_setor_excluir
    @id_setor INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.ramais WHERE id_setor = @id_setor AND ativo = 1)
    BEGIN
        RAISERROR('Não foi possível excluir: existe ramal ativo vinculado a este setor.', 16, 1);
        RETURN;
    END

    UPDATE dbo.ramais_setores
    SET ativo = 0, dt_alteracao = GETDATE()
    WHERE id_setor = @id_setor;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_ramal_listar
    @id_loja INT = NULL,
    @id_setor INT = NULL,
    @termo NVARCHAR(160) = NULL,
    @somente_ativos BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET @termo = NULLIF(LTRIM(RTRIM(ISNULL(@termo, ''))), '');

    SELECT
        r.id_ramal, r.nome, r.ramal, r.id_loja, l.nome AS loja,
        r.id_setor, s.nome AS setor, r.ativo,
        CASE WHEN r.ativo = 1 THEN 'Ativo' ELSE 'Inativo' END AS status,
        r.dt_cadastro, r.dt_alteracao
    FROM dbo.ramais r
    INNER JOIN dbo.ramais_lojas l ON l.id_loja = r.id_loja
    INNER JOIN dbo.ramais_setores s ON s.id_setor = r.id_setor
    WHERE (@somente_ativos = 0 OR r.ativo = 1)
      AND (@id_loja IS NULL OR @id_loja = 0 OR r.id_loja = @id_loja)
      AND (@id_setor IS NULL OR @id_setor = 0 OR r.id_setor = @id_setor)
      AND (
            @termo IS NULL
            OR r.nome LIKE '%' + @termo + '%'
            OR r.ramal LIKE '%' + @termo + '%'
            OR l.nome LIKE '%' + @termo + '%'
            OR s.nome LIKE '%' + @termo + '%'
          )
    ORDER BY l.nome, s.nome, r.nome, r.ramal;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_ramal_obter
    @id_ramal INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.id_ramal, r.nome, r.ramal, r.id_loja, l.nome AS loja,
        r.id_setor, s.nome AS setor, r.ativo,
        CASE WHEN r.ativo = 1 THEN 'Ativo' ELSE 'Inativo' END AS status,
        r.dt_cadastro, r.dt_alteracao
    FROM dbo.ramais r
    INNER JOIN dbo.ramais_lojas l ON l.id_loja = r.id_loja
    INNER JOIN dbo.ramais_setores s ON s.id_setor = r.id_setor
    WHERE r.id_ramal = @id_ramal;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_ramal_salvar
    @id_ramal INT = NULL,
    @nome NVARCHAR(160),
    @ramal NVARCHAR(30),
    @id_loja INT,
    @id_setor INT,
    @ativo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET @nome = LTRIM(RTRIM(ISNULL(@nome, '')));
    SET @ramal = LTRIM(RTRIM(ISNULL(@ramal, '')));

    IF @nome = ''
    BEGIN
        RAISERROR('Informe o nome do colaborador.', 16, 1);
        RETURN;
    END

    IF @ramal = ''
    BEGIN
        RAISERROR('Informe o ramal.', 16, 1);
        RETURN;
    END

    IF ISNULL(@id_loja, 0) = 0 OR NOT EXISTS (SELECT 1 FROM dbo.ramais_lojas WHERE id_loja = @id_loja AND ativo = 1)
    BEGIN
        RAISERROR('Selecione uma loja ativa.', 16, 1);
        RETURN;
    END

    IF ISNULL(@id_setor, 0) = 0 OR NOT EXISTS (SELECT 1 FROM dbo.ramais_setores WHERE id_setor = @id_setor AND ativo = 1)
    BEGIN
        RAISERROR('Selecione um setor ativo.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM dbo.ramais
        WHERE ramal = @ramal
          AND id_loja = @id_loja
          AND id_setor = @id_setor
          AND ativo = 1
          AND (ISNULL(@id_ramal, 0) = 0 OR id_ramal <> @id_ramal)
    )
    BEGIN
        RAISERROR('Já existe um ramal ativo com esse número nesta loja e setor.', 16, 1);
        RETURN;
    END

    IF ISNULL(@id_ramal, 0) = 0
    BEGIN
        INSERT INTO dbo.ramais (nome, ramal, id_loja, id_setor, ativo)
        VALUES (@nome, @ramal, @id_loja, @id_setor, @ativo);

        SET @id_ramal = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.ramais
        SET nome = @nome,
            ramal = @ramal,
            id_loja = @id_loja,
            id_setor = @id_setor,
            ativo = @ativo,
            dt_alteracao = GETDATE()
        WHERE id_ramal = @id_ramal;
    END

    EXEC dbo.ramais_ramal_obter @id_ramal;
END
GO

CREATE OR ALTER PROCEDURE dbo.ramais_ramal_excluir
    @id_ramal INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ramais
    SET ativo = 0, dt_alteracao = GETDATE()
    WHERE id_ramal = @id_ramal;
END
GO
