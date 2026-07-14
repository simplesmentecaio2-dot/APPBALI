using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Web;

public static class PatioBaixaVendaSincronizador
{
    private static readonly object EstruturaLock = new object();
    private static bool EstruturaVerificada = false;

    public static DataRow Sincronizar(string usuario)
    {
        GarantirEstrutura(usuario);

        Stopwatch tempo = Stopwatch.StartNew();
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();

        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"
SET NOCOUNT ON;

DECLARE @baixados TABLE
(
    ve_nr varchar(50) NOT NULL,
    chassi varchar(30) NULL
);

DECLARE @ativos TABLE
(
    ve_nr varchar(50) NOT NULL PRIMARY KEY,
    veiculo_codigo int NOT NULL
);

DECLARE @vendidos TABLE
(
    veiculo_codigo int NOT NULL PRIMARY KEY,
    chassi varchar(30) NULL
);

INSERT INTO @ativos (ve_nr, veiculo_codigo)
SELECT DISTINCT CONVERT(varchar(50), p.ve_nr), CAST(p.ve_nr AS int)
FROM dbo.veiculos_patio_locacao p WITH (NOLOCK)
WHERE ISNULL(p.baixado_venda, 0) = 0
  AND ISNUMERIC(p.ve_nr) = 1;

INSERT INTO @vendidos (veiculo_codigo, chassi)
SELECT vv.veiculo_codigo,
       MAX(LEFT(ISNULL(vv.veiculo_chassi, ''), 30)) AS chassi
FROM GrupoBali_DealernetWF.dbo.VendasVeiculos vv WITH (NOLOCK)
INNER JOIN @ativos a
    ON a.veiculo_codigo = vv.veiculo_codigo
GROUP BY vv.veiculo_codigo;

UPDATE p
   SET baixado_venda = 1,
       dt_baixa_venda = GETDATE(),
       chassi_baixa = v.chassi,
       baixa_origem = 'VENDAS_DEALERNET',
       baixa_observacao = 'Baixa automatica por venda no Dealernet'
OUTPUT CONVERT(varchar(50), inserted.ve_nr), inserted.chassi_baixa
  INTO @baixados(ve_nr, chassi)
FROM dbo.veiculos_patio_locacao p WITH (UPDLOCK, ROWLOCK, READPAST)
INNER JOIN @vendidos v
    ON v.veiculo_codigo = CASE WHEN ISNUMERIC(p.ve_nr) = 1 THEN CAST(p.ve_nr AS int) ELSE -1 END
WHERE ISNULL(p.baixado_venda, 0) = 0
  AND ISNUMERIC(p.ve_nr) = 1;

INSERT INTO dbo.veiculos_patio_baixa_venda_log (ve_nr, chassi, usuario, origem, observacao)
SELECT b.ve_nr,
       b.chassi,
       @usuario,
       'VENDAS_DEALERNET',
       'Baixa automatica por venda no Dealernet'
FROM @baixados b;

SELECT
    (SELECT COUNT(1) FROM @baixados) AS baixados_agora,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE ISNULL(baixado_venda, 0) = 0) AS ativos_patio,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE ISNULL(baixado_venda, 0) = 1) AS baixados_total,
    (SELECT MAX(dt_baixa) FROM dbo.veiculos_patio_baixa_venda_log WITH (NOLOCK)) AS ultima_baixa,
    CAST(1 AS bit) AS sucesso,
    CAST(NULL AS varchar(200)) AS erro;", banco.oCon2);
            cmd.CommandTimeout = 45;
            cmd.Parameters.Add("@usuario", SqlDbType.VarChar, 100).Value = usuario ?? "";

            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            adapter.Fill(tabela);
            tempo.Stop();
            AdicionarDuracao(tabela, tempo.ElapsedMilliseconds);
            AdicionarFotosRemovidas(tabela, PatioFotoHelper.LimparFotosBaixadas(HttpContext.Current, usuario));
        }
        catch (Exception ex)
        {
            tempo.Stop();
            PatioJeepAuditoria.Registrar("PATIO_BAIXA_VENDA_ERRO", usuario, "SINCRONIZACAO", ex.Message);
            tabela = CriarResultadoErro(tempo.ElapsedMilliseconds);
        }
        finally
        {
            banco.FecharConexao2();
        }

        return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
    }

    private static void AdicionarDuracao(DataTable tabela, long duracaoMs)
    {
        if (!tabela.Columns.Contains("duracao_ms"))
        {
            tabela.Columns.Add("duracao_ms", typeof(long));
        }

        foreach (DataRow row in tabela.Rows)
        {
            row["duracao_ms"] = duracaoMs;
        }
    }

    private static void AdicionarFotosRemovidas(DataTable tabela, int fotosRemovidas)
    {
        if (!tabela.Columns.Contains("fotos_removidas"))
        {
            tabela.Columns.Add("fotos_removidas", typeof(int));
        }

        foreach (DataRow row in tabela.Rows)
        {
            row["fotos_removidas"] = fotosRemovidas;
        }
    }

    private static DataTable CriarResultadoErro(long duracaoMs)
    {
        DataTable tabela = new DataTable();
        tabela.Columns.Add("baixados_agora", typeof(int));
        tabela.Columns.Add("ativos_patio", typeof(int));
        tabela.Columns.Add("baixados_total", typeof(int));
        tabela.Columns.Add("ultima_baixa", typeof(DateTime));
        tabela.Columns.Add("sucesso", typeof(bool));
        tabela.Columns.Add("erro", typeof(string));
        tabela.Columns.Add("duracao_ms", typeof(long));

        DataRow row = tabela.NewRow();
        row["baixados_agora"] = 0;
        row["ativos_patio"] = 0;
        row["baixados_total"] = 0;
        row["sucesso"] = false;
        row["erro"] = "Nao foi possivel sincronizar o patio com as vendas agora.";
        row["duracao_ms"] = duracaoMs;
        tabela.Rows.Add(row);

        return tabela;
    }

    public static void GarantirEstrutura(string usuario)
    {
        if (EstruturaVerificada)
        {
            return;
        }

        lock (EstruturaLock)
        {
            if (EstruturaVerificada)
            {
                return;
            }

            Jeep banco = new Jeep();
            try
            {
                banco.Conexao2();
                SqlCommand cmd = new SqlCommand(@"
IF COL_LENGTH('dbo.veiculos_patio_locacao', 'baixado_venda') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao ADD baixado_venda bit NOT NULL CONSTRAINT DF_veiculos_patio_locacao_baixado_venda DEFAULT (0) WITH VALUES;
END;

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'dt_baixa_venda') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao ADD dt_baixa_venda datetime NULL;
END;

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'chassi_baixa') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao ADD chassi_baixa varchar(30) NULL;
END;

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'baixa_origem') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao ADD baixa_origem varchar(50) NULL;
END;

IF COL_LENGTH('dbo.veiculos_patio_locacao', 'baixa_observacao') IS NULL
BEGIN
    ALTER TABLE dbo.veiculos_patio_locacao ADD baixa_observacao varchar(200) NULL;
END;

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

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_baixa_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_baixa_dt ON dbo.veiculos_patio_locacao(baixado_venda, dt_cad) INCLUDE (ve_nr, loja_id, loja_atual_id, fun_cad, dt_baixa_venda, chassi_baixa);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_baixa_loja' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_baixa_loja ON dbo.veiculos_patio_locacao(baixado_venda, loja_atual_id, loja_id) INCLUDE (ve_nr, dt_cad, fun_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_baixa_venda_log_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_baixa_venda_log'))
BEGIN
    CREATE INDEX IX_veiculos_patio_baixa_venda_log_dt ON dbo.veiculos_patio_baixa_venda_log(dt_baixa DESC) INCLUDE (ve_nr, chassi, usuario, origem);
END;", banco.oCon2);
                cmd.CommandTimeout = 60;
                cmd.ExecuteNonQuery();
                EstruturaVerificada = true;
            }
            catch (Exception ex)
            {
                PatioJeepAuditoria.Registrar("PATIO_BAIXA_VENDA_ESTRUTURA_ERRO", usuario, "SINCRONIZACAO", ex.Message);
            }
            finally
            {
                banco.FecharConexao2();
            }
        }
    }
}
