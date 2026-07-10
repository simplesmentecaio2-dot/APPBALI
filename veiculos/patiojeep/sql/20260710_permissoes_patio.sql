USE APP;
GO

ALTER PROCEDURE dbo.veiculos_patio_verificar_acesso
(
    @fun_cad varchar(100),
    @acesso_id int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @usuario varchar(100);
    SET @usuario = UPPER(LTRIM(RTRIM(ISNULL(@fun_cad, ''))));

    IF EXISTS
    (
        SELECT 1
        FROM dbo.veiculos_patio_usuario_acesso WITH (READPAST)
        WHERE UPPER(LTRIM(RTRIM(fun_cad))) = @usuario
          AND acesso_id = @acesso_id
    )
    BEGIN
        SELECT 's' AS resultado;
        RETURN;
    END;

    SELECT 'n' AS resultado;
END;
GO
