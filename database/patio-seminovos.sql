SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.veiculos_patio_seminovos_locacao', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.veiculos_patio_seminovos_locacao
    (
        id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_veiculos_patio_seminovos_locacao PRIMARY KEY,
        ve_nr int NOT NULL,
        ve_ds varchar(120) NULL,
        ve_chassi varchar(30) NULL,
        ve_placa varchar(12) NULL,
        ve_renavam varchar(30) NULL,
        cor_ds varchar(80) NULL,
        codnf int NULL,
        numeronf varchar(50) NULL,
        loja_id int NULL,
        loja_atual_id int NULL,
        fun_cad varchar(100) NULL,
        dt_cad datetime NOT NULL CONSTRAINT DF_veiculos_patio_seminovos_locacao_dt DEFAULT (GETDATE()),
        ativo bit NOT NULL CONSTRAINT DF_veiculos_patio_seminovos_locacao_ativo DEFAULT (1),
        observacao varchar(250) NULL
    );
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_seminovos_transferencia', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.veiculos_patio_seminovos_transferencia
    (
        id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_veiculos_patio_seminovos_transferencia PRIMARY KEY,
        seminovo_id int NOT NULL,
        ve_nr int NOT NULL,
        loja_orig int NULL,
        loja_dest int NULL,
        fun_cad varchar(100) NULL,
        dt_transf datetime NOT NULL CONSTRAINT DF_veiculos_patio_seminovos_transferencia_dt DEFAULT (GETDATE())
    );
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_seminovos_auditoria', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.veiculos_patio_seminovos_auditoria
    (
        id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_veiculos_patio_seminovos_auditoria PRIMARY KEY,
        acao varchar(60) NOT NULL,
        usuario varchar(100) NULL,
        ve_nr int NULL,
        referencia varchar(60) NULL,
        detalhe varchar(500) NULL,
        ip varchar(60) NULL,
        dt datetime NOT NULL CONSTRAINT DF_veiculos_patio_seminovos_auditoria_dt DEFAULT (GETDATE())
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_veiculos_patio_seminovos_locacao_ve_nr_ativo' AND object_id = OBJECT_ID('dbo.veiculos_patio_seminovos_locacao'))
BEGIN
    CREATE UNIQUE INDEX UX_veiculos_patio_seminovos_locacao_ve_nr_ativo
    ON dbo.veiculos_patio_seminovos_locacao(ve_nr)
    WHERE ativo = 1;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_seminovos_locacao_busca' AND object_id = OBJECT_ID('dbo.veiculos_patio_seminovos_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_seminovos_locacao_busca
    ON dbo.veiculos_patio_seminovos_locacao(ativo, ve_chassi, ve_placa, ve_renavam);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_seminovos_locacao_loja_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_seminovos_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_seminovos_locacao_loja_dt
    ON dbo.veiculos_patio_seminovos_locacao(ativo, loja_atual_id, loja_id, dt_cad DESC);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_seminovos_transferencia_veiculo_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_seminovos_transferencia'))
BEGIN
    CREATE INDEX IX_veiculos_patio_seminovos_transferencia_veiculo_dt
    ON dbo.veiculos_patio_seminovos_transferencia(seminovo_id, dt_transf DESC);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_seminovos_auditoria_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_seminovos_auditoria'))
BEGIN
    CREATE INDEX IX_veiculos_patio_seminovos_auditoria_dt
    ON dbo.veiculos_patio_seminovos_auditoria(dt DESC);
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_seminovos_consultar_veiculo', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.veiculos_patio_seminovos_consultar_veiculo AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.veiculos_patio_seminovos_consultar_veiculo
(
    @busca varchar(40)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @valor varchar(40);
    SET @valor = UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(@busca, ''))), '-', ''), ' ', ''), '.', ''));

    SELECT TOP (1)
        v.Veiculo_Codigo AS ve_nr,
        SUBSTRING(m.ModeloVeiculo_Descricao, 1, 80) AS ve_ds,
        v.Veiculo_Chassi AS ve_chassi,
        ISNULL(v.Veiculo_Placa, '') AS ve_placa,
        ISNULL(v.Veiculo_NroRenavam, '') AS ve_renavam,
        c.Cor_Descricao AS cor_ds,
        nfinfo.NotaFiscal_Codigo AS codnf,
        nfinfo.NotaFiscal_Numero AS numeronf
    FROM GrupoBali_DealernetWF.dbo.Veiculo v
    INNER JOIN GrupoBali_DealernetWF.dbo.Cor c
        ON v.Veiculo_CorCodExterna = c.Cor_Codigo
    INNER JOIN GrupoBali_DealernetWF.dbo.ModeloVeiculo m
        ON m.ModeloVeiculo_Codigo = v.Veiculo_ModeloVeiculoCod
    OUTER APPLY
    (
        SELECT TOP (1)
            i.NotaFiscal_Codigo,
            nf.NotaFiscal_Numero
        FROM GrupoBali_DealernetWF.dbo.NotaFiscalItem i
        INNER JOIN GrupoBali_DealernetWF.dbo.NotaFiscal nf
            ON nf.NotaFiscal_Codigo = i.NotaFiscal_Codigo
        WHERE i.NotaFiscalItem_VeiculoCod = v.Veiculo_Codigo
        ORDER BY nf.NotaFiscal_DataEmissao DESC, i.NotaFiscal_Codigo DESC
    ) nfinfo
    WHERE @valor <> ''
      AND (
            REPLACE(REPLACE(REPLACE(UPPER(ISNULL(v.Veiculo_Placa, '')), '-', ''), ' ', ''), '.', '') = @valor
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(v.Veiculo_Chassi, '')), '-', ''), ' ', ''), '.', '') = @valor
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(v.Veiculo_NroRenavam, '')), '-', ''), ' ', ''), '.', '') = @valor
      )
    ORDER BY v.Veiculo_Codigo DESC;
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_seminovos_registrar', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.veiculos_patio_seminovos_registrar AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.veiculos_patio_seminovos_registrar
(
    @ve_nr int,
    @loja int,
    @fun_cad varchar(100),
    @observacao varchar(250) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.veiculos_patio_seminovos_locacao WHERE ve_nr = @ve_nr AND ativo = 1)
    BEGIN
        SELECT 'n' AS resultado, NULL AS id;
        RETURN;
    END;

    INSERT INTO dbo.veiculos_patio_seminovos_locacao
        (ve_nr, ve_ds, ve_chassi, ve_placa, ve_renavam, cor_ds, codnf, numeronf, loja_id, loja_atual_id, fun_cad, dt_cad, ativo, observacao)
    SELECT TOP (1)
        v.Veiculo_Codigo,
        SUBSTRING(m.ModeloVeiculo_Descricao, 1, 80),
        v.Veiculo_Chassi,
        ISNULL(v.Veiculo_Placa, ''),
        ISNULL(v.Veiculo_NroRenavam, ''),
        c.Cor_Descricao,
        nfinfo.NotaFiscal_Codigo,
        CONVERT(varchar(50), nfinfo.NotaFiscal_Numero),
        @loja,
        @loja,
        @fun_cad,
        GETDATE(),
        1,
        @observacao
    FROM GrupoBali_DealernetWF.dbo.Veiculo v
    INNER JOIN GrupoBali_DealernetWF.dbo.Cor c
        ON v.Veiculo_CorCodExterna = c.Cor_Codigo
    INNER JOIN GrupoBali_DealernetWF.dbo.ModeloVeiculo m
        ON m.ModeloVeiculo_Codigo = v.Veiculo_ModeloVeiculoCod
    OUTER APPLY
    (
        SELECT TOP (1)
            i.NotaFiscal_Codigo,
            nf.NotaFiscal_Numero
        FROM GrupoBali_DealernetWF.dbo.NotaFiscalItem i
        INNER JOIN GrupoBali_DealernetWF.dbo.NotaFiscal nf
            ON nf.NotaFiscal_Codigo = i.NotaFiscal_Codigo
        WHERE i.NotaFiscalItem_VeiculoCod = v.Veiculo_Codigo
        ORDER BY nf.NotaFiscal_DataEmissao DESC, i.NotaFiscal_Codigo DESC
    ) nfinfo
    WHERE v.Veiculo_Codigo = @ve_nr;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT 'x' AS resultado, NULL AS id;
        RETURN;
    END;

    SELECT 's' AS resultado, CONVERT(int, SCOPE_IDENTITY()) AS id;
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_seminovos_localizar', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.veiculos_patio_seminovos_localizar AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.veiculos_patio_seminovos_localizar
(
    @busca varchar(40)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @valor varchar(40);
    SET @valor = UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(@busca, ''))), '-', ''), ' ', ''), '.', ''));

    SELECT TOP (1)
        p.id,
        p.ve_nr,
        p.ve_ds,
        p.ve_chassi,
        p.ve_placa,
        p.ve_renavam,
        p.cor_ds,
        p.codnf,
        p.numeronf,
        p.loja_id,
        COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) AS loja_atual_id,
        lj.ds AS loja_atual,
        p.fun_cad,
        p.dt_cad,
        p.observacao
    FROM dbo.veiculos_patio_seminovos_locacao p
    LEFT JOIN dbo.veiculos_patio_loja lj
        ON lj.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
    WHERE p.ativo = 1
      AND @valor <> ''
      AND (
            CONVERT(varchar(20), p.ve_nr) = @valor
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(p.ve_placa, '')), '-', ''), ' ', ''), '.', '') = @valor
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(p.ve_chassi, '')), '-', ''), ' ', ''), '.', '') = @valor
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(p.ve_renavam, '')), '-', ''), ' ', ''), '.', '') = @valor
      )
    ORDER BY p.dt_cad DESC, p.id DESC;
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_seminovos_listar', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.veiculos_patio_seminovos_listar AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.veiculos_patio_seminovos_listar
(
    @loja int = NULL,
    @busca varchar(40) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @valor varchar(40);
    SET @valor = UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(@busca, ''))), '-', ''), ' ', ''), '.', ''));

    SELECT TOP (250)
        p.id,
        p.ve_nr,
        p.ve_ds,
        p.ve_chassi,
        p.ve_placa,
        p.ve_renavam,
        p.cor_ds,
        p.numeronf,
        COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) AS loja_atual_id,
        COALESCE(l.ds, 'Sem loja') AS loja_atual,
        p.fun_cad,
        p.dt_cad,
        p.observacao
    FROM dbo.veiculos_patio_seminovos_locacao p
    LEFT JOIN dbo.veiculos_patio_loja l
        ON l.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
    WHERE p.ativo = 1
      AND (@loja IS NULL OR @loja = 0 OR COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) = @loja)
      AND (
            @valor = ''
         OR CONVERT(varchar(20), p.ve_nr) = @valor
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(p.ve_placa, '')), '-', ''), ' ', ''), '.', '') LIKE '%' + @valor + '%'
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(p.ve_chassi, '')), '-', ''), ' ', ''), '.', '') LIKE '%' + @valor + '%'
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(p.ve_renavam, '')), '-', ''), ' ', ''), '.', '') LIKE '%' + @valor + '%'
         OR UPPER(ISNULL(p.ve_ds, '')) LIKE '%' + @valor + '%'
      )
    ORDER BY p.dt_cad DESC, p.id DESC;
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_seminovos_transferir', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.veiculos_patio_seminovos_transferir AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.veiculos_patio_seminovos_transferir
(
    @seminovo_id int,
    @lojaDestino int,
    @fun_cad varchar(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ve_nr int;
    DECLARE @lojaOrigem int;

    SELECT TOP (1)
        @ve_nr = ve_nr,
        @lojaOrigem = COALESCE(NULLIF(loja_atual_id, 0), loja_id)
    FROM dbo.veiculos_patio_seminovos_locacao
    WHERE id = @seminovo_id
      AND ativo = 1;

    IF @ve_nr IS NULL
    BEGIN
        SELECT 'n' AS resultado;
        RETURN;
    END;

    IF ISNULL(@lojaOrigem, 0) = ISNULL(@lojaDestino, 0)
    BEGIN
        SELECT 'i' AS resultado;
        RETURN;
    END;

    UPDATE dbo.veiculos_patio_seminovos_locacao
       SET loja_atual_id = @lojaDestino
    WHERE id = @seminovo_id
      AND ativo = 1;

    INSERT INTO dbo.veiculos_patio_seminovos_transferencia
        (seminovo_id, ve_nr, loja_orig, loja_dest, fun_cad, dt_transf)
    VALUES
        (@seminovo_id, @ve_nr, @lojaOrigem, @lojaDestino, @fun_cad, GETDATE());

    SELECT 's' AS resultado;
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_seminovos_historico', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.veiculos_patio_seminovos_historico AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.veiculos_patio_seminovos_historico
(
    @seminovo_id int
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.dt_cad AS data_movimento,
        'REGISTRO' AS movimento,
        NULL AS origem,
        l.ds AS destino,
        p.fun_cad AS usuario
    FROM dbo.veiculos_patio_seminovos_locacao p
    LEFT JOIN dbo.veiculos_patio_loja l ON l.id = p.loja_id
    WHERE p.id = @seminovo_id

    UNION ALL

    SELECT
        t.dt_transf AS data_movimento,
        'TRANSFERENCIA' AS movimento,
        lo.ds AS origem,
        ld.ds AS destino,
        t.fun_cad AS usuario
    FROM dbo.veiculos_patio_seminovos_transferencia t
    LEFT JOIN dbo.veiculos_patio_loja lo ON lo.id = t.loja_orig
    LEFT JOIN dbo.veiculos_patio_loja ld ON ld.id = t.loja_dest
    WHERE t.seminovo_id = @seminovo_id
    ORDER BY data_movimento DESC;
END;
GO

IF OBJECT_ID('dbo.veiculos_patio_seminovos_auditoria_registrar', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.veiculos_patio_seminovos_auditoria_registrar AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.veiculos_patio_seminovos_auditoria_registrar
(
    @acao varchar(60),
    @usuario varchar(100) = NULL,
    @ve_nr int = NULL,
    @referencia varchar(60) = NULL,
    @detalhe varchar(500) = NULL,
    @ip varchar(60) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.veiculos_patio_seminovos_auditoria
        (acao, usuario, ve_nr, referencia, detalhe, ip, dt)
    VALUES
        (@acao, @usuario, @ve_nr, @referencia, @detalhe, @ip, GETDATE());
END;
GO
