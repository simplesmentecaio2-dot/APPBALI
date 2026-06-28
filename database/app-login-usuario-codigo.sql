USE APP;
GO

CREATE OR ALTER PROCEDURE dbo.app_proc_login
    @id_usuario VARCHAR(50),
    @senha VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret_id_usuario VARCHAR(50) = 'N',
            @ret_usuario VARCHAR(60) = 'N',
            @ret_tipo NVARCHAR(30) = N'N',
            @ret_email VARCHAR(150) = 'N',
            @ret_fun_ramal VARCHAR(50) = 'N',
            @ret_fun_radio VARCHAR(50) = 'N',
            @ret_emp VARCHAR(10) = 'N',
            @lookup_identificador VARCHAR(60) = NULL,
            @lookup_email VARCHAR(150) = NULL,
            @lookup_matricula VARCHAR(20) = NULL,
            @usuario_codigo INT = 0;

    IF EXISTS (
        SELECT 1
        FROM app_tab_usuario u
        INNER JOIN fiatnet_prod..tab_fun f ON u.id_usuario = f.fun_email
        INNER JOIN fiatnet_prod..tab_funemp femp ON f.fun_cd = femp.fun_cd AND funemp_default = 'S'
        WHERE u.id_usuario = @id_usuario
          AND u.senha = @senha
          AND f.fun_dtsai IS NULL
    )
    BEGIN
        SELECT TOP 1
            @ret_id_usuario = u.id_usuario,
            @ret_usuario = f.fun_nmguerra,
            @ret_tipo = u.tipo,
            @ret_email = LOWER(f.fun_email),
            @ret_fun_ramal = f.fun_ramal,
            @ret_fun_radio = f.fun_radio,
            @ret_emp = CASE femp.emp_cd
                            WHEN '01' THEN 'SIA'
                            WHEN '02' THEN 'SCIA'
                            WHEN '03' THEN 'SAAN'
                            WHEN '04' THEN 'AERO'
                            ELSE 'N'
                        END,
            @lookup_identificador = f.fun_nmguerra,
            @lookup_email = f.fun_email,
            @lookup_matricula = f.fun_cd
        FROM app_tab_usuario u
        INNER JOIN fiatnet_prod..tab_fun f ON u.id_usuario = f.fun_email
        INNER JOIN fiatnet_prod..tab_funemp femp ON f.fun_cd = femp.fun_cd AND funemp_default = 'S'
        WHERE u.id_usuario = @id_usuario
          AND u.senha = @senha
          AND f.fun_dtsai IS NULL;
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM fiatnet_prod..tab_fun
        WHERE fun_nmguerra = @id_usuario
          AND fun_cpf = @senha
          AND fun_dtsai IS NULL
    )
    BEGIN
        SELECT TOP 1
            @ret_id_usuario = fun_nmguerra,
            @ret_usuario = fun_nmguerra,
            @ret_tipo = N'USU' + NCHAR(193) + N'RIO',
            @ret_email = 'N',
            @ret_fun_ramal = 'N',
            @ret_fun_radio = 'N',
            @ret_emp = 'N',
            @lookup_identificador = fun_nmguerra,
            @lookup_matricula = fun_cd
        FROM fiatnet_prod..tab_fun
        WHERE fun_nmguerra = @id_usuario
          AND fun_cpf = @senha
          AND fun_dtsai IS NULL;
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM app_tab_usuario
        WHERE id_usuario = @id_usuario
          AND senha = @senha
    )
    BEGIN
        SELECT TOP 1
            @ret_id_usuario = id_usuario,
            @ret_usuario = usuario,
            @ret_tipo = tipo,
            @ret_email = id_usuario,
            @ret_fun_ramal = 'N',
            @ret_fun_radio = 'N',
            @ret_emp = 'N',
            @lookup_identificador = usuario,
            @lookup_email = id_usuario
        FROM app_tab_usuario
        WHERE id_usuario = @id_usuario
          AND senha = @senha;
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM usuariowf
        WHERE usuario_identificador = @id_usuario
          AND cpf = @senha
          AND Usuario_DataDemissao IS NULL
    )
    BEGIN
        SELECT TOP 1
            @ret_id_usuario = usuario_identificador,
            @ret_usuario = usuario_identificador,
            @ret_tipo = N'USU' + NCHAR(193) + N'RIO',
            @ret_email = 'N',
            @ret_fun_ramal = 'N',
            @ret_fun_radio = 'N',
            @ret_emp = 'N',
            @lookup_identificador = usuario_identificador
        FROM usuariowf
        WHERE usuario_identificador = @id_usuario
          AND cpf = @senha
          AND Usuario_DataDemissao IS NULL;
    END

    IF @ret_usuario <> 'N'
    BEGIN
        BEGIN TRY
            SELECT TOP 1 @usuario_codigo = ISNULL(wu.Usuario_Codigo, 0)
            FROM WORKFLOW.GrupoBali_DealernetWF.dbo.Usuario wu
            WHERE wu.Usuario_Ativo = 1
              AND wu.Usuario_DataDemissao IS NULL
              AND (
                    (@lookup_identificador IS NOT NULL
                     AND UPPER(LTRIM(RTRIM(wu.Usuario_Identificador))) COLLATE SQL_Latin1_General_CP1_CI_AS =
                         UPPER(LTRIM(RTRIM(@lookup_identificador))) COLLATE SQL_Latin1_General_CP1_CI_AS)
                 OR (@lookup_email IS NOT NULL
                     AND LOWER(LTRIM(RTRIM(wu.Usuario_Email))) COLLATE SQL_Latin1_General_CP1_CI_AS =
                         LOWER(LTRIM(RTRIM(@lookup_email))) COLLATE SQL_Latin1_General_CP1_CI_AS)
                 OR (@lookup_matricula IS NOT NULL
                     AND LTRIM(RTRIM(wu.Usuario_Matricula)) COLLATE SQL_Latin1_General_CP1_CI_AS =
                         LTRIM(RTRIM(@lookup_matricula)) COLLATE SQL_Latin1_General_CP1_CI_AS)
                  )
            ORDER BY
                CASE
                    WHEN @lookup_identificador IS NOT NULL
                         AND UPPER(LTRIM(RTRIM(wu.Usuario_Identificador))) COLLATE SQL_Latin1_General_CP1_CI_AS =
                             UPPER(LTRIM(RTRIM(@lookup_identificador))) COLLATE SQL_Latin1_General_CP1_CI_AS THEN 1
                    WHEN @lookup_email IS NOT NULL
                         AND LOWER(LTRIM(RTRIM(wu.Usuario_Email))) COLLATE SQL_Latin1_General_CP1_CI_AS =
                             LOWER(LTRIM(RTRIM(@lookup_email))) COLLATE SQL_Latin1_General_CP1_CI_AS THEN 2
                    WHEN @lookup_matricula IS NOT NULL
                         AND LTRIM(RTRIM(wu.Usuario_Matricula)) COLLATE SQL_Latin1_General_CP1_CI_AS =
                             LTRIM(RTRIM(@lookup_matricula)) COLLATE SQL_Latin1_General_CP1_CI_AS THEN 3
                    ELSE 4
                END;
        END TRY
        BEGIN CATCH
            SET @usuario_codigo = 0;
        END CATCH;
    END

    SELECT
        @ret_id_usuario AS id_usuario,
        @ret_usuario AS usuario,
        @ret_tipo AS tipo,
        @ret_email AS email,
        @ret_fun_ramal AS fun_ramal,
        @ret_fun_radio AS fun_radio,
        @ret_emp AS emp,
        ISNULL(@usuario_codigo, 0) AS usuario_codigo;
END
GO

CREATE OR ALTER PROCEDURE dbo.app_proc_loginBI
    @id_usuario VARCHAR(50),
    @senha VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret_id_usuario VARCHAR(50) = 'N',
            @ret_usuario VARCHAR(60) = 'N',
            @ret_tipo NVARCHAR(30) = N'N',
            @ret_email VARCHAR(150) = 'N',
            @ret_fun_ramal VARCHAR(50) = 'N',
            @ret_fun_radio VARCHAR(50) = 'N',
            @ret_emp VARCHAR(10) = 'N',
            @lookup_identificador VARCHAR(60) = NULL,
            @lookup_email VARCHAR(150) = NULL,
            @lookup_matricula VARCHAR(20) = NULL,
            @usuario_codigo INT = 0;

    IF EXISTS (
        SELECT 1
        FROM app_tab_usuario u
        INNER JOIN fiatnet_prod..tab_fun f ON u.id_usuario = f.fun_email
        INNER JOIN fiatnet_prod..tab_funemp femp ON f.fun_cd = femp.fun_cd AND funemp_default = 'S'
        WHERE u.id_usuario = @id_usuario
          AND u.senha = @senha
          AND f.fun_dtsai IS NULL
    )
    BEGIN
        SELECT TOP 1
            @ret_id_usuario = u.id_usuario,
            @ret_usuario = f.fun_nmguerra,
            @ret_tipo = u.tipo,
            @ret_email = LOWER(f.fun_email),
            @ret_fun_ramal = f.fun_ramal,
            @ret_fun_radio = f.fun_radio,
            @ret_emp = CASE femp.emp_cd
                            WHEN '01' THEN 'SIA'
                            WHEN '02' THEN 'SCIA'
                            WHEN '03' THEN 'SAAN'
                            WHEN '04' THEN 'AERO'
                            ELSE 'N'
                        END,
            @lookup_identificador = f.fun_nmguerra,
            @lookup_email = f.fun_email,
            @lookup_matricula = f.fun_cd
        FROM app_tab_usuario u
        INNER JOIN fiatnet_prod..tab_fun f ON u.id_usuario = f.fun_email
        INNER JOIN fiatnet_prod..tab_funemp femp ON f.fun_cd = femp.fun_cd AND funemp_default = 'S'
        WHERE u.id_usuario = @id_usuario
          AND u.senha = @senha
          AND f.fun_dtsai IS NULL;
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM fiatnet_prod..tab_fun
        WHERE fun_nmguerra = @id_usuario
          AND fun_cpf = @senha
          AND fun_dtsai IS NULL
    )
    BEGIN
        SELECT TOP 1
            @ret_id_usuario = fun_nmguerra,
            @ret_usuario = fun_nmguerra,
            @ret_tipo = N'USU' + NCHAR(193) + N'RIO',
            @ret_email = 'N',
            @ret_fun_ramal = 'N',
            @ret_fun_radio = 'N',
            @ret_emp = 'N',
            @lookup_identificador = fun_nmguerra,
            @lookup_matricula = fun_cd
        FROM fiatnet_prod..tab_fun
        WHERE fun_nmguerra = @id_usuario
          AND fun_cpf = @senha
          AND fun_dtsai IS NULL;
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM app_tab_usuario
        WHERE id_usuario = @id_usuario
          AND senha = @senha
    )
    BEGIN
        SELECT TOP 1
            @ret_id_usuario = id_usuario,
            @ret_usuario = usuario,
            @ret_tipo = tipo,
            @ret_email = id_usuario,
            @ret_fun_ramal = 'N',
            @ret_fun_radio = 'N',
            @ret_emp = 'N',
            @lookup_identificador = usuario,
            @lookup_email = id_usuario
        FROM app_tab_usuario
        WHERE id_usuario = @id_usuario
          AND senha = @senha;
    END

    IF @ret_usuario <> 'N'
    BEGIN
        BEGIN TRY
            SELECT TOP 1 @usuario_codigo = ISNULL(wu.Usuario_Codigo, 0)
            FROM WORKFLOW.GrupoBali_DealernetWF.dbo.Usuario wu
            WHERE wu.Usuario_Ativo = 1
              AND wu.Usuario_DataDemissao IS NULL
              AND (
                    (@lookup_identificador IS NOT NULL
                     AND UPPER(LTRIM(RTRIM(wu.Usuario_Identificador))) COLLATE SQL_Latin1_General_CP1_CI_AS =
                         UPPER(LTRIM(RTRIM(@lookup_identificador))) COLLATE SQL_Latin1_General_CP1_CI_AS)
                 OR (@lookup_email IS NOT NULL
                     AND LOWER(LTRIM(RTRIM(wu.Usuario_Email))) COLLATE SQL_Latin1_General_CP1_CI_AS =
                         LOWER(LTRIM(RTRIM(@lookup_email))) COLLATE SQL_Latin1_General_CP1_CI_AS)
                 OR (@lookup_matricula IS NOT NULL
                     AND LTRIM(RTRIM(wu.Usuario_Matricula)) COLLATE SQL_Latin1_General_CP1_CI_AS =
                         LTRIM(RTRIM(@lookup_matricula)) COLLATE SQL_Latin1_General_CP1_CI_AS)
                  )
            ORDER BY
                CASE
                    WHEN @lookup_identificador IS NOT NULL
                         AND UPPER(LTRIM(RTRIM(wu.Usuario_Identificador))) COLLATE SQL_Latin1_General_CP1_CI_AS =
                             UPPER(LTRIM(RTRIM(@lookup_identificador))) COLLATE SQL_Latin1_General_CP1_CI_AS THEN 1
                    WHEN @lookup_email IS NOT NULL
                         AND LOWER(LTRIM(RTRIM(wu.Usuario_Email))) COLLATE SQL_Latin1_General_CP1_CI_AS =
                             LOWER(LTRIM(RTRIM(@lookup_email))) COLLATE SQL_Latin1_General_CP1_CI_AS THEN 2
                    WHEN @lookup_matricula IS NOT NULL
                         AND LTRIM(RTRIM(wu.Usuario_Matricula)) COLLATE SQL_Latin1_General_CP1_CI_AS =
                             LTRIM(RTRIM(@lookup_matricula)) COLLATE SQL_Latin1_General_CP1_CI_AS THEN 3
                    ELSE 4
                END;
        END TRY
        BEGIN CATCH
            SET @usuario_codigo = 0;
        END CATCH;
    END

    SELECT
        @ret_id_usuario AS id_usuario,
        @ret_usuario AS usuario,
        @ret_tipo AS tipo,
        @ret_email AS email,
        @ret_fun_ramal AS fun_ramal,
        @ret_fun_radio AS fun_radio,
        @ret_emp AS emp,
        ISNULL(@usuario_codigo, 0) AS usuario_codigo;
END
GO
