USE APP;
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'baixado_venda') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD baixado_venda bit NOT NULL
            CONSTRAINT DF_veiculos_patio_locacao_baixado_venda DEFAULT (0) WITH VALUES;
END;
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'dt_baixa_venda') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD dt_baixa_venda datetime NULL;
END;
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'chassi_baixa') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD chassi_baixa varchar(30) NULL;
END;
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'baixa_origem') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD baixa_origem varchar(50) NULL;
END;
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'baixa_observacao') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD baixa_observacao varchar(200) NULL;
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_baixa_venda_log', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.veiculos_patio_baixa_venda_log
    (
        id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_veiculos_patio_baixa_venda_log PRIMARY KEY,
        ve_nr varchar(50) NOT NULL,
        chassi varchar(30) NULL,
        usuario varchar(100) NULL,
        origem varchar(50) NULL,
        observacao varchar(200) NULL,
        dt_baixa datetime NOT NULL CONSTRAINT DF_veiculos_patio_baixa_venda_log_dt DEFAULT (GETDATE())
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_baixa_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_baixa_dt
        ON dbo.veiculos_patio_locacao(baixado_venda, dt_cad)
        INCLUDE (ve_nr, loja_id, loja_atual_id, fun_cad, dt_baixa_venda, chassi_baixa);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_baixa_loja' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_baixa_loja
        ON dbo.veiculos_patio_locacao(baixado_venda, loja_atual_id, loja_id)
        INCLUDE (ve_nr, dt_cad, fun_cad);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_baixa_venda_log_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_baixa_venda_log'))
BEGIN
    CREATE INDEX IX_veiculos_patio_baixa_venda_log_dt
        ON dbo.veiculos_patio_baixa_venda_log(dt_baixa DESC)
        INCLUDE (ve_nr, chassi, usuario, origem);
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_sincronizar_baixas_venda', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.veiculos_patio_sincronizar_baixas_venda;
END;
GO

CREATE PROCEDURE dbo.veiculos_patio_sincronizar_baixas_venda
(
    @usuario varchar(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #ativos
    (
        ve_nr varchar(50) NOT NULL PRIMARY KEY,
        chassi varchar(30) NOT NULL
    );

    INSERT INTO #ativos (ve_nr, chassi)
    SELECT
        l.ve_nr,
        MAX(LTRIM(RTRIM(v.Veiculo_Chassi COLLATE DATABASE_DEFAULT))) AS chassi
    FROM dbo.veiculos_patio_locacao l
    INNER JOIN GrupoBali_DealernetWF.dbo.Veiculo v
        ON ISNUMERIC(l.ve_nr) = 1
       AND CAST(l.ve_nr AS int) = v.Veiculo_Codigo
    WHERE l.baixado_venda = 0
      AND NULLIF(LTRIM(RTRIM(v.Veiculo_Chassi COLLATE DATABASE_DEFAULT)), '') IS NOT NULL
    GROUP BY l.ve_nr;

    CREATE INDEX IX_ativos_chassi ON #ativos(chassi);

    DECLARE @baixados TABLE
    (
        ve_nr varchar(50) NOT NULL PRIMARY KEY,
        chassi varchar(30) NULL
    );

    INSERT INTO @baixados (ve_nr, chassi)
    SELECT DISTINCT
        a.ve_nr,
        a.chassi
    FROM #ativos a
    INNER JOIN
    (
        SELECT DISTINCT
            LTRIM(RTRIM(Veiculo_Chassi COLLATE DATABASE_DEFAULT)) AS chassi
        FROM GrupoBali_DealernetWF.dbo.VendasVeiculos
        WHERE NULLIF(LTRIM(RTRIM(Veiculo_Chassi COLLATE DATABASE_DEFAULT)), '') IS NOT NULL
    ) vv
        ON vv.chassi = a.chassi;

    UPDATE l
       SET l.baixado_venda = 1,
           l.dt_baixa_venda = GETDATE(),
           l.chassi_baixa = b.chassi,
           l.baixa_origem = 'VendasVeiculos',
           l.baixa_observacao = 'Baixa automatica por venda'
    FROM dbo.veiculos_patio_locacao l
    INNER JOIN @baixados b
        ON b.ve_nr = l.ve_nr;

    INSERT INTO dbo.veiculos_patio_baixa_venda_log
        (ve_nr, chassi, usuario, origem, observacao)
    SELECT
        b.ve_nr,
        b.chassi,
        COALESCE(NULLIF(@usuario, ''), 'SISTEMA_RELATORIO'),
        'VendasVeiculos',
        'Baixa automatica por venda'
    FROM @baixados b;

    SELECT
        (SELECT COUNT(1) FROM @baixados) AS baixados_agora,
        (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WHERE baixado_venda = 0) AS ativos_patio,
        (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WHERE baixado_venda = 1) AS baixados_total;
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_selectTranferir', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.veiculos_patio_selectTranferir;
END;
GO

CREATE PROCEDURE dbo.veiculos_patio_selectTranferir
(
    @chassi varchar(7)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.Veiculo_Codigo AS ve_nr,
        SUBSTRING(v.Veiculo_Descricao, 1, 20) AS ve_ds,
        v.Veiculo_Chassi AS ve_chassi,
        c.Cor_Descricao AS cor_ds,
        COALESCE(NULLIF(l.loja_atual_id, 0), l.loja_id) AS loja_id,
        lj.ds
    FROM GrupoBali_DealernetWF.dbo.Veiculo v
    INNER JOIN GrupoBali_DealernetWF.dbo.Cor c
        ON v.Veiculo_CorCodExterna = c.Cor_Codigo
    INNER JOIN dbo.veiculos_patio_locacao l
        ON ISNUMERIC(l.ve_nr) = 1
       AND CAST(l.ve_nr AS int) = v.Veiculo_Codigo
       AND l.baixado_venda = 0
    INNER JOIN dbo.veiculos_patio_loja lj
        ON COALESCE(NULLIF(l.loja_atual_id, 0), l.loja_id) = lj.id
    WHERE v.Veiculo_ChassiSerie = @chassi;
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_insert_locacao', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.veiculos_patio_insert_locacao;
END;
GO

CREATE PROCEDURE dbo.veiculos_patio_insert_locacao
(
    @ve_nr int,
    @fun_cad varchar(100),
    @loja int,
    @numeronf varchar(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM GrupoBali_DealernetWF.dbo.Veiculo v
        INNER JOIN GrupoBali_DealernetWF.dbo.VendasVeiculos vv
            ON LTRIM(RTRIM(vv.Veiculo_Chassi COLLATE DATABASE_DEFAULT)) = LTRIM(RTRIM(v.Veiculo_Chassi COLLATE DATABASE_DEFAULT))
        WHERE v.Veiculo_Codigo = @ve_nr
    )
    BEGIN
        UPDATE l
           SET l.baixado_venda = 1,
               l.dt_baixa_venda = COALESCE(l.dt_baixa_venda, GETDATE()),
               l.chassi_baixa = v.Veiculo_Chassi COLLATE DATABASE_DEFAULT,
               l.baixa_origem = 'VendasVeiculos',
               l.baixa_observacao = 'Baixa automatica por venda'
        FROM dbo.veiculos_patio_locacao l
        INNER JOIN GrupoBali_DealernetWF.dbo.Veiculo v
            ON ISNUMERIC(l.ve_nr) = 1
           AND CAST(l.ve_nr AS int) = v.Veiculo_Codigo
        WHERE l.ve_nr = CONVERT(varchar(50), @ve_nr)
          AND l.baixado_venda = 0;

        SELECT 'v' AS resultado;
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.veiculos_patio_locacao
        WHERE ve_nr = CONVERT(varchar(50), @ve_nr)
          AND baixado_venda = 0
    )
    BEGIN
        SELECT 'n' AS resultado;
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.veiculos_patio_locacao
        WHERE ve_nr = CONVERT(varchar(50), @ve_nr)
          AND baixado_venda = 1
    )
    BEGIN
        SELECT 'v' AS resultado;
        RETURN;
    END;

    INSERT INTO dbo.veiculos_patio_locacao
        (ve_nr, fun_cad, loja_id, dt_cad, baixado_venda)
    VALUES
        (@ve_nr, @fun_cad, @loja, GETDATE(), 0);

    SELECT 's' AS resultado;
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_insert_tranferencia', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.veiculos_patio_insert_tranferencia;
END;
GO

CREATE PROCEDURE dbo.veiculos_patio_insert_tranferencia
(
    @ve_nr int,
    @fun_cad varchar(100),
    @lojaOrigem int,
    @lojaDestino int
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.veiculos_patio_locacao
        WHERE ve_nr = CONVERT(varchar(50), @ve_nr)
          AND baixado_venda = 0
    )
    BEGIN
        SELECT 'n' AS resultado;
        RETURN;
    END;

    UPDATE dbo.veiculos_patio_locacao
       SET loja_id = @lojaDestino
    WHERE ve_nr = CONVERT(varchar(50), @ve_nr)
      AND baixado_venda = 0;

    INSERT dbo.veiculos_patio_transferencia
        (ve_nr, loja_orig, loja_dest, fun_cad, dt_transf)
    VALUES
        (@ve_nr, @lojaOrigem, @lojaDestino, @fun_cad, GETDATE());

    SELECT 's' AS resultado;
END;
GO
