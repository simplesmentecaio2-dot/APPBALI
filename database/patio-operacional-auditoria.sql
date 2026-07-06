USE APP;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

SET NOCOUNT ON;
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'observacao') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD observacao varchar(500) NULL;
END
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'status_operacional') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD status_operacional varchar(30) NOT NULL
            CONSTRAINT DF_veiculos_patio_locacao_status_operacional DEFAULT ('NO_PATIO');
END
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'dt_status_operacional') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD dt_status_operacional datetime NULL;
END
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'usuario_status_operacional') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD usuario_status_operacional varchar(100) NULL;
END
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'dt_baixa_manual') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD dt_baixa_manual datetime NULL;
END
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'usuario_baixa_manual') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD usuario_baixa_manual varchar(100) NULL;
END
GO

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'motivo_baixa_manual') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao
        ADD motivo_baixa_manual varchar(500) NULL;
END
GO

IF COL_LENGTH('dbo.veiculos_patio_seminovos_locacao', 'status_operacional') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_seminovos_locacao
        ADD status_operacional varchar(30) NOT NULL
            CONSTRAINT DF_veiculos_patio_seminovos_locacao_status_operacional DEFAULT ('NO_PATIO');
END
GO

IF COL_LENGTH('dbo.veiculos_patio_seminovos_locacao', 'dt_status_operacional') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_seminovos_locacao
        ADD dt_status_operacional datetime NULL;
END
GO

IF COL_LENGTH('dbo.veiculos_patio_seminovos_locacao', 'usuario_status_operacional') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_seminovos_locacao
        ADD usuario_status_operacional varchar(100) NULL;
END
GO

IF COL_LENGTH('dbo.veiculos_patio_seminovos_locacao', 'dt_baixa_manual') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_seminovos_locacao
        ADD dt_baixa_manual datetime NULL;
END
GO

IF COL_LENGTH('dbo.veiculos_patio_seminovos_locacao', 'usuario_baixa_manual') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_seminovos_locacao
        ADD usuario_baixa_manual varchar(100) NULL;
END
GO

IF COL_LENGTH('dbo.veiculos_patio_seminovos_locacao', 'motivo_baixa_manual') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_seminovos_locacao
        ADD motivo_baixa_manual varchar(500) NULL;
END
GO

IF OBJECT_ID('dbo.veiculos_patio_auditoria_geral', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.veiculos_patio_auditoria_geral
    (
        id bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_veiculos_patio_auditoria_geral PRIMARY KEY,
        origem varchar(20) NOT NULL,
        ve_nr varchar(50) NULL,
        acao varchar(80) NOT NULL,
        usuario varchar(100) NULL,
        detalhe varchar(1000) NULL,
        ip varchar(60) NULL,
        url varchar(300) NULL,
        dt datetime NOT NULL CONSTRAINT DF_veiculos_patio_auditoria_geral_dt DEFAULT (GETDATE())
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_auditoria_geral_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_auditoria_geral'))
BEGIN
    CREATE INDEX IX_veiculos_patio_auditoria_geral_dt
        ON dbo.veiculos_patio_auditoria_geral(dt DESC, id DESC)
        INCLUDE (origem, ve_nr, acao, usuario);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_auditoria_geral_veiculo' AND object_id = OBJECT_ID('dbo.veiculos_patio_auditoria_geral'))
BEGIN
    CREATE INDEX IX_veiculos_patio_auditoria_geral_veiculo
        ON dbo.veiculos_patio_auditoria_geral(origem, ve_nr, dt DESC, id DESC)
        INCLUDE (acao, usuario, detalhe);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_status_loja' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_status_loja
        ON dbo.veiculos_patio_locacao(baixado_venda, status_operacional, loja_atual_id, loja_id)
        INCLUDE (ve_nr, fun_cad, dt_cad, observacao);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_seminovos_status_loja' AND object_id = OBJECT_ID('dbo.veiculos_patio_seminovos_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_seminovos_status_loja
        ON dbo.veiculos_patio_seminovos_locacao(ativo, status_operacional, loja_atual_id, loja_id)
        INCLUDE (ve_nr, ve_chassi, ve_placa, fun_cad, dt_cad, observacao);
END
GO

IF OBJECT_ID('dbo.veiculos_patio_auditoria_registrar', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.veiculos_patio_auditoria_registrar AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.veiculos_patio_auditoria_registrar
    @origem varchar(20),
    @ve_nr varchar(50) = NULL,
    @acao varchar(80),
    @usuario varchar(100) = NULL,
    @detalhe varchar(1000) = NULL,
    @ip varchar(60) = NULL,
    @url varchar(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.veiculos_patio_auditoria_geral
        (origem, ve_nr, acao, usuario, detalhe, ip, url)
    VALUES
        (LEFT(ISNULL(@origem, 'GERAL'), 20), LEFT(@ve_nr, 50), LEFT(ISNULL(@acao, 'EVENTO'), 80),
         LEFT(@usuario, 100), LEFT(@detalhe, 1000), LEFT(@ip, 60), LEFT(@url, 300));
END
GO

IF OBJECT_ID('dbo.veiculos_patio_operacional_atualizar', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.veiculos_patio_operacional_atualizar AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.veiculos_patio_operacional_atualizar
    @tipo varchar(20),
    @ve_nr varchar(50),
    @status varchar(30),
    @observacao varchar(500) = NULL,
    @usuario varchar(100) = NULL,
    @ip varchar(60) = NULL,
    @url varchar(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @resultado varchar(1) = 'n';
    DECLARE @tipoNormalizado varchar(20) = UPPER(LTRIM(RTRIM(ISNULL(@tipo, ''))));
    DECLARE @statusNormalizado varchar(30) = UPPER(LTRIM(RTRIM(ISNULL(@status, 'NO_PATIO'))));
    DECLARE @id int = NULL;
    DECLARE @idBig bigint = NULL;

    IF @ve_nr NOT LIKE '%[^0-9]%' AND LEN(@ve_nr) BETWEEN 1 AND 10
    BEGIN
        SET @idBig = CONVERT(bigint, @ve_nr);
        IF @idBig <= 2147483647
            SET @id = CONVERT(int, @idBig);
    END

    IF @statusNormalizado NOT IN ('NO_PATIO','PREPARACAO','AGUARDANDO_RETIRADA','VENDIDO','TRANSFERIDO','BAIXADO','PENDENTE')
        SET @statusNormalizado = 'NO_PATIO';

    IF @tipoNormalizado = 'NOVO'
    BEGIN
        UPDATE dbo.veiculos_patio_locacao
           SET status_operacional = @statusNormalizado,
               observacao = NULLIF(LEFT(ISNULL(@observacao, ''), 500), ''),
               dt_status_operacional = GETDATE(),
               usuario_status_operacional = LEFT(@usuario, 100)
         WHERE ve_nr = @ve_nr
           AND baixado_venda = 0;

        IF @@ROWCOUNT > 0 SET @resultado = 's';
    END

    IF @tipoNormalizado = 'SEMINOVO'
    BEGIN
        UPDATE dbo.veiculos_patio_seminovos_locacao
           SET status_operacional = @statusNormalizado,
               observacao = NULLIF(LEFT(ISNULL(@observacao, ''), 500), ''),
               dt_status_operacional = GETDATE(),
               usuario_status_operacional = LEFT(@usuario, 100)
         WHERE ativo = 1
           AND (
                id = @id
                OR ve_nr = @id
                OR ve_chassi = @ve_nr
                OR ve_placa = @ve_nr
                OR ve_renavam = @ve_nr
           );

        IF @@ROWCOUNT > 0 SET @resultado = 's';
    END

    IF @resultado = 's'
    BEGIN
        EXEC dbo.veiculos_patio_auditoria_registrar
            @origem = @tipoNormalizado,
            @ve_nr = @ve_nr,
            @acao = 'STATUS_OBSERVACAO',
            @usuario = @usuario,
            @detalhe = @statusNormalizado,
            @ip = @ip,
            @url = @url;
    END

    SELECT @resultado AS resultado;
END
GO

IF OBJECT_ID('dbo.veiculos_patio_baixa_manual', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.veiculos_patio_baixa_manual AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.veiculos_patio_baixa_manual
    @tipo varchar(20),
    @ve_nr varchar(50),
    @motivo varchar(500),
    @usuario varchar(100) = NULL,
    @ip varchar(60) = NULL,
    @url varchar(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @resultado varchar(1) = 'n';
    DECLARE @tipoNormalizado varchar(20) = UPPER(LTRIM(RTRIM(ISNULL(@tipo, ''))));
    DECLARE @id int = NULL;
    DECLARE @idBig bigint = NULL;
    DECLARE @motivoLimpo varchar(500) = LEFT(LTRIM(RTRIM(ISNULL(@motivo, ''))), 500);

    IF @ve_nr NOT LIKE '%[^0-9]%' AND LEN(@ve_nr) BETWEEN 1 AND 10
    BEGIN
        SET @idBig = CONVERT(bigint, @ve_nr);
        IF @idBig <= 2147483647
            SET @id = CONVERT(int, @idBig);
    END

    IF @motivoLimpo = ''
    BEGIN
        SELECT 'm' AS resultado;
        RETURN;
    END

    IF @tipoNormalizado = 'NOVO'
    BEGIN
        UPDATE dbo.veiculos_patio_locacao
           SET baixado_venda = 1,
               dt_baixa_venda = GETDATE(),
               baixa_origem = 'BaixaManual',
               baixa_observacao = LEFT(@motivoLimpo, 200),
               status_operacional = 'BAIXADO',
               dt_status_operacional = GETDATE(),
               usuario_status_operacional = LEFT(@usuario, 100),
               dt_baixa_manual = GETDATE(),
               usuario_baixa_manual = LEFT(@usuario, 100),
               motivo_baixa_manual = @motivoLimpo
         WHERE ve_nr = @ve_nr
           AND baixado_venda = 0;

        IF @@ROWCOUNT > 0 SET @resultado = 's';
    END

    IF @tipoNormalizado = 'SEMINOVO'
    BEGIN
        UPDATE dbo.veiculos_patio_seminovos_locacao
           SET ativo = 0,
               status_operacional = 'BAIXADO',
               dt_status_operacional = GETDATE(),
               usuario_status_operacional = LEFT(@usuario, 100),
               dt_baixa_manual = GETDATE(),
               usuario_baixa_manual = LEFT(@usuario, 100),
               motivo_baixa_manual = @motivoLimpo
         WHERE ativo = 1
           AND (
                id = @id
                OR ve_nr = @id
                OR ve_chassi = @ve_nr
                OR ve_placa = @ve_nr
                OR ve_renavam = @ve_nr
           );

        IF @@ROWCOUNT > 0 SET @resultado = 's';
    END

    IF @resultado = 's'
    BEGIN
        EXEC dbo.veiculos_patio_auditoria_registrar
            @origem = @tipoNormalizado,
            @ve_nr = @ve_nr,
            @acao = 'BAIXA_MANUAL',
            @usuario = @usuario,
            @detalhe = @motivoLimpo,
            @ip = @ip,
            @url = @url;
    END

    SELECT @resultado AS resultado;
END
GO
