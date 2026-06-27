IF OBJECT_ID('dbo.app_select_sistemas_usuario_alterar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.app_select_sistemas_usuario_alterar;
GO

CREATE PROCEDURE dbo.app_select_sistemas_usuario_alterar
(
    @id_usuario VARCHAR(50),
    @id_sistema INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CASE
               WHEN EXISTS
                    (
                        SELECT 1
                          FROM dbo.app_tab_usuario_sistema
                         WHERE id_usuario = @id_usuario
                           AND id_sistema = @id_sistema
                    )
               THEN 1
               ELSE 0
           END AS id_sistema;
END;
GO
