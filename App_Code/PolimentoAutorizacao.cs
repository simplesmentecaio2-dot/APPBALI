using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Web;

public static class PolimentoAutorizacao
{
    private const int TimeoutSqlSegundos = 30;
    private static readonly object EstruturaLock = new object();
    private static bool estruturaGarantida;

    private static string ConnectionString
    {
        get
        {
            ConnectionStringSettings cfg = ConfigurationManager.ConnectionStrings["APPWFConnectionString"];
            if (cfg != null) return cfg.ConnectionString;
            return ConfigurationManager.ConnectionStrings["APPWFConnectionString2"].ConnectionString;
        }
    }

    public static void GarantirEstrutura()
    {
        if (estruturaGarantida) return;

        lock (EstruturaLock)
        {
            if (estruturaGarantida) return;

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
IF OBJECT_ID('dbo.polimento_autorizacao_log','U') IS NULL
BEGIN
    CREATE TABLE dbo.polimento_autorizacao_log
    (
        id_polimento BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_polimento_autorizacao_log PRIMARY KEY,
        marca NVARCHAR(20) NOT NULL,
        pedido NVARCHAR(20) NOT NULL,
        loja NVARCHAR(10) NOT NULL,
        unidade NVARCHAR(80) NULL,
        proposta_codigo NVARCHAR(40) NULL,
        nota_fiscal NVARCHAR(40) NULL,
        cliente NVARCHAR(180) NULL,
        veiculo NVARCHAR(240) NULL,
        chassi NVARCHAR(60) NULL,
        placa NVARCHAR(20) NULL,
        cor NVARCHAR(80) NULL,
        ano_modelo NVARCHAR(40) NULL,
        valor DECIMAL(18,2) NULL,
        vendedor NVARCHAR(160) NULL,
        usuario_codigo NVARCHAR(50) NULL,
        usuario_nome NVARCHAR(160) NULL,
        ip NVARCHAR(80) NULL,
        pagina NVARCHAR(260) NULL,
        total_geracoes INT NOT NULL CONSTRAINT DF_polimento_autorizacao_log_total DEFAULT(1),
        gerado_em DATETIME2(0) NOT NULL CONSTRAINT DF_polimento_autorizacao_log_gerado DEFAULT(SYSDATETIME()),
        ultima_geracao_em DATETIME2(0) NOT NULL CONSTRAINT DF_polimento_autorizacao_log_ultima DEFAULT(SYSDATETIME()),
        atualizado_em DATETIME2(0) NOT NULL CONSTRAINT DF_polimento_autorizacao_log_atualizado DEFAULT(SYSDATETIME())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_polimento_autorizacao_log_marca_data_cor' AND object_id = OBJECT_ID('dbo.polimento_autorizacao_log'))
    CREATE INDEX IX_polimento_autorizacao_log_marca_data_cor ON dbo.polimento_autorizacao_log (marca, gerado_em, cor) INCLUDE (loja, unidade, pedido, chassi);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_polimento_autorizacao_log_chassi' AND object_id = OBJECT_ID('dbo.polimento_autorizacao_log'))
    CREATE INDEX IX_polimento_autorizacao_log_chassi ON dbo.polimento_autorizacao_log (chassi) INCLUDE (marca, pedido, loja, cor, gerado_em);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_polimento_autorizacao_log_pedido' AND object_id = OBJECT_ID('dbo.polimento_autorizacao_log'))
    CREATE INDEX IX_polimento_autorizacao_log_pedido ON dbo.polimento_autorizacao_log (marca, pedido, loja) INCLUDE (proposta_codigo, chassi, cor, gerado_em);
", con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = TimeoutSqlSegundos;
                con.Open();
                cmd.ExecuteNonQuery();
            }

            estruturaGarantida = true;
        }
    }

    public static bool RegistrarGeracao(string marca, string pedido, string loja, DataRow dados, HttpContext contexto)
    {
        try
        {
            GarantirEstrutura();

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
DECLARE @id_polimento BIGINT;

SELECT TOP (1) @id_polimento = id_polimento
FROM dbo.polimento_autorizacao_log WITH (UPDLOCK, HOLDLOCK)
WHERE marca = @marca
  AND pedido = @pedido
  AND loja = @loja
  AND ISNULL(proposta_codigo, N'') = ISNULL(@proposta_codigo, N'')
  AND ISNULL(chassi, N'') = ISNULL(@chassi, N'');

IF @id_polimento IS NULL
BEGIN
    INSERT INTO dbo.polimento_autorizacao_log
    (
        marca, pedido, loja, unidade, proposta_codigo, nota_fiscal, cliente, veiculo, chassi, placa,
        cor, ano_modelo, valor, vendedor, usuario_codigo, usuario_nome, ip, pagina,
        total_geracoes, gerado_em, ultima_geracao_em, atualizado_em
    )
    VALUES
    (
        @marca, @pedido, @loja, NULLIF(@unidade, N''), NULLIF(@proposta_codigo, N''), NULLIF(@nota_fiscal, N''),
        NULLIF(@cliente, N''), NULLIF(@veiculo, N''), NULLIF(@chassi, N''), NULLIF(@placa, N''),
        NULLIF(@cor, N''), NULLIF(@ano_modelo, N''), @valor, NULLIF(@vendedor, N''),
        NULLIF(@usuario_codigo, N''), NULLIF(@usuario_nome, N''), NULLIF(@ip, N''), NULLIF(@pagina, N''),
        1, SYSDATETIME(), SYSDATETIME(), SYSDATETIME()
    );
END
ELSE
BEGIN
    UPDATE dbo.polimento_autorizacao_log
       SET unidade = NULLIF(@unidade, N''),
           nota_fiscal = NULLIF(@nota_fiscal, N''),
           cliente = NULLIF(@cliente, N''),
           veiculo = NULLIF(@veiculo, N''),
           placa = NULLIF(@placa, N''),
           cor = NULLIF(@cor, N''),
           ano_modelo = NULLIF(@ano_modelo, N''),
           valor = @valor,
           vendedor = NULLIF(@vendedor, N''),
           usuario_codigo = NULLIF(@usuario_codigo, N''),
           usuario_nome = NULLIF(@usuario_nome, N''),
           ip = NULLIF(@ip, N''),
           pagina = NULLIF(@pagina, N''),
           total_geracoes = ISNULL(total_geracoes, 0) + 1,
           ultima_geracao_em = SYSDATETIME(),
           atualizado_em = SYSDATETIME()
     WHERE id_polimento = @id_polimento;
END;", con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = TimeoutSqlSegundos;
                cmd.Parameters.Add("@marca", SqlDbType.NVarChar, 20).Value = Limitar(marca, 20);
                cmd.Parameters.Add("@pedido", SqlDbType.NVarChar, 20).Value = Limitar(pedido, 20);
                cmd.Parameters.Add("@loja", SqlDbType.NVarChar, 10).Value = Limitar(loja, 10);
                cmd.Parameters.Add("@unidade", SqlDbType.NVarChar, 80).Value = Limitar(Valor(dados, "Unidade"), 80);
                cmd.Parameters.Add("@proposta_codigo", SqlDbType.NVarChar, 40).Value = Limitar(Valor(dados, "Proposta_Codigo"), 40);
                cmd.Parameters.Add("@nota_fiscal", SqlDbType.NVarChar, 40).Value = Limitar(Valor(dados, "Nota Fiscal"), 40);
                cmd.Parameters.Add("@cliente", SqlDbType.NVarChar, 180).Value = Limitar(Valor(dados, "Cliente"), 180);
                cmd.Parameters.Add("@veiculo", SqlDbType.NVarChar, 240).Value = Limitar(Valor(dados, "Ve\u00edculo"), 240);
                cmd.Parameters.Add("@chassi", SqlDbType.NVarChar, 60).Value = Limitar(Valor(dados, "Chassi"), 60);
                cmd.Parameters.Add("@placa", SqlDbType.NVarChar, 20).Value = Limitar(Valor(dados, "Placa"), 20);
                cmd.Parameters.Add("@cor", SqlDbType.NVarChar, 80).Value = Limitar(NormalizarCor(Valor(dados, "Cor")), 80);
                cmd.Parameters.Add("@ano_modelo", SqlDbType.NVarChar, 40).Value = Limitar(Valor(dados, "Ano / Modelo"), 40);
                cmd.Parameters.Add("@valor", SqlDbType.Decimal).Value = ValorDecimal(dados, "Valor");
                cmd.Parameters["@valor"].Precision = 18;
                cmd.Parameters["@valor"].Scale = 2;
                cmd.Parameters.Add("@vendedor", SqlDbType.NVarChar, 160).Value = Limitar(Valor(dados, "Vendedor"), 160);
                cmd.Parameters.Add("@usuario_codigo", SqlDbType.NVarChar, 50).Value = Limitar(ValorSessao(contexto, "usuario_codigo"), 50);
                cmd.Parameters.Add("@usuario_nome", SqlDbType.NVarChar, 160).Value = Limitar(ValorSessao(contexto, "usuario"), 160);
                cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 80).Value = Limitar(Ip(contexto), 80);
                cmd.Parameters.Add("@pagina", SqlDbType.NVarChar, 260).Value = Limitar(Pagina(contexto), 260);

                con.Open();
                cmd.ExecuteNonQuery();
                return true;
            }
        }
        catch (Exception ex)
        {
            RegistrarFalhaLocal(ex);
            return false;
        }
    }

    public static DataTable ResumoPorCor(string marca, DateTime inicio, DateTime fim)
    {
        GarantirEstrutura();

        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
SELECT
    CONVERT(char(7), gerado_em, 120) AS Mes,
    ISNULL(NULLIF(cor, N''), N'SEM COR') AS Cor,
    COUNT(1) AS Quantidade,
    CONVERT(varchar(10), MAX(ultima_geracao_em), 103) + ' ' + CONVERT(varchar(5), MAX(ultima_geracao_em), 108) AS [UltimaGeracao]
FROM dbo.polimento_autorizacao_log
WHERE marca = @marca
  AND gerado_em >= @inicio
  AND gerado_em < @fim
GROUP BY CONVERT(char(7), gerado_em, 120), ISNULL(NULLIF(cor, N''), N'SEM COR')
ORDER BY Mes DESC, Quantidade DESC, Cor ASC;", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add("@marca", SqlDbType.NVarChar, 20).Value = Limitar(marca, 20);
            cmd.Parameters.Add("@inicio", SqlDbType.DateTime2).Value = inicio.Date;
            cmd.Parameters.Add("@fim", SqlDbType.DateTime2).Value = fim.Date.AddDays(1);

            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    public static DataTable Detalhes(string marca, DateTime inicio, DateTime fim)
    {
        GarantirEstrutura();

        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
SELECT TOP (200)
    CONVERT(varchar(10), gerado_em, 103) + ' ' + CONVERT(varchar(5), gerado_em, 108) AS [GeradoEm],
    pedido AS [Pedido],
    loja AS [Loja],
    ISNULL(NULLIF(cor, N''), N'SEM COR') AS [Cor],
    veiculo AS [Veiculo],
    chassi AS [Chassi],
    cliente AS [Cliente],
    usuario_nome AS [Usuario],
    total_geracoes AS [Geracoes]
FROM dbo.polimento_autorizacao_log
WHERE marca = @marca
  AND gerado_em >= @inicio
  AND gerado_em < @fim
ORDER BY gerado_em DESC, id_polimento DESC;", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add("@marca", SqlDbType.NVarChar, 20).Value = Limitar(marca, 20);
            cmd.Parameters.Add("@inicio", SqlDbType.DateTime2).Value = inicio.Date;
            cmd.Parameters.Add("@fim", SqlDbType.DateTime2).Value = fim.Date.AddDays(1);

            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    public static int Total(DataTable resumo)
    {
        int total = 0;
        if (resumo == null) return total;
        foreach (DataRow row in resumo.Rows)
        {
            int qtd;
            if (Int32.TryParse(Convert.ToString(row["Quantidade"]), out qtd)) total += qtd;
        }
        return total;
    }

    public static string TopCor(DataTable resumo)
    {
        if (resumo == null || resumo.Rows.Count == 0) return "-";

        string cor = "";
        int quantidade = -1;
        foreach (DataRow row in resumo.Rows)
        {
            int atual;
            Int32.TryParse(Convert.ToString(row["Quantidade"]), out atual);
            if (atual > quantidade)
            {
                quantidade = atual;
                cor = Convert.ToString(row["Cor"]);
            }
        }

        return String.IsNullOrWhiteSpace(cor) ? "-" : cor + " (" + quantidade.ToString(CultureInfo.InvariantCulture) + ")";
    }

    private static string Valor(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value) return "";
        return Convert.ToString(row[coluna]).Trim();
    }

    private static object ValorDecimal(DataRow row, string coluna)
    {
        string texto = Valor(row, coluna);
        decimal valor;
        if (Decimal.TryParse(texto, NumberStyles.Any, new CultureInfo("pt-BR"), out valor)) return valor;
        if (Decimal.TryParse(texto, NumberStyles.Any, CultureInfo.InvariantCulture, out valor)) return valor;
        return DBNull.Value;
    }

    private static string NormalizarCor(string cor)
    {
        cor = (cor ?? "").Trim();
        while (cor.Contains("  ")) cor = cor.Replace("  ", " ");
        return cor.ToUpper(new CultureInfo("pt-BR"));
    }

    private static string ValorSessao(HttpContext contexto, string chave)
    {
        if (contexto == null || contexto.Session == null || contexto.Session[chave] == null) return "";
        return Convert.ToString(contexto.Session[chave]).Trim();
    }

    private static string Ip(HttpContext contexto)
    {
        if (contexto == null || contexto.Request == null) return "";
        string encaminhado = Convert.ToString(contexto.Request.ServerVariables["HTTP_X_FORWARDED_FOR"]);
        if (!String.IsNullOrWhiteSpace(encaminhado))
        {
            string[] partes = encaminhado.Split(',');
            if (partes.Length > 0) return partes[0].Trim();
        }

        return Convert.ToString(contexto.Request.ServerVariables["REMOTE_ADDR"]).Trim();
    }

    private static string Pagina(HttpContext contexto)
    {
        if (contexto == null || contexto.Request == null) return "";
        return Convert.ToString(contexto.Request.RawUrl).Trim();
    }

    private static string Limitar(string valor, int tamanho)
    {
        valor = (valor ?? "").Trim();
        return valor.Length <= tamanho ? valor : valor.Substring(0, tamanho);
    }

    private static void RegistrarFalhaLocal(Exception ex)
    {
        try
        {
            string pasta = HttpContext.Current != null ? HttpContext.Current.Server.MapPath("~/App_Data") : AppDomain.CurrentDomain.BaseDirectory;
            string linha = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture) + " | polimento | " + ex.Message;
            File.AppendAllText(Path.Combine(pasta, "polimento-autorizacao-erros.log"), linha + Environment.NewLine);
        }
        catch
        {
        }
    }
}
