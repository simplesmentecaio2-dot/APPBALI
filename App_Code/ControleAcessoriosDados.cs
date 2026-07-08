using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;

public static class ControleAcessoriosDados
{
    private const int TimeoutSqlSegundos = 45;
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
IF OBJECT_ID('dbo.controle_acessorios_nf','U') IS NULL
BEGIN
    CREATE TABLE dbo.controle_acessorios_nf
    (
        id_controle BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_controle_acessorios_nf PRIMARY KEY,
        chave_controle NVARCHAR(180) NOT NULL,
        lancamento BIGINT NOT NULL,
        numero_titulo NVARCHAR(60) NULL,
        loja NVARCHAR(120) NULL,
        fornecedor NVARCHAR(220) NULL,
        data_emissao DATE NULL,
        data_vencimento DATE NULL,
        titulo_valor DECIMAL(18,2) NULL,
        saldo DECIMAL(18,2) NULL,
        veiculo_chassi NVARCHAR(60) NULL,
        veiculo NVARCHAR(160) NULL,
        emitido BIT NOT NULL CONSTRAINT DF_controle_acessorios_nf_emitido DEFAULT(1),
        marcado_em DATETIME2(0) NULL,
        marcado_usuario_codigo NVARCHAR(50) NULL,
        marcado_usuario_nome NVARCHAR(160) NULL,
        desmarcado_em DATETIME2(0) NULL,
        desmarcado_usuario_codigo NVARCHAR(50) NULL,
        desmarcado_usuario_nome NVARCHAR(160) NULL,
        observacao NVARCHAR(300) NULL,
        ip NVARCHAR(80) NULL,
        pagina NVARCHAR(260) NULL,
        atualizado_em DATETIME2(0) NOT NULL CONSTRAINT DF_controle_acessorios_nf_atualizado DEFAULT(SYSDATETIME())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_controle_acessorios_nf_chave' AND object_id = OBJECT_ID('dbo.controle_acessorios_nf'))
    CREATE UNIQUE INDEX UX_controle_acessorios_nf_chave ON dbo.controle_acessorios_nf (chave_controle);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_controle_acessorios_nf_emitido' AND object_id = OBJECT_ID('dbo.controle_acessorios_nf'))
    CREATE INDEX IX_controle_acessorios_nf_emitido ON dbo.controle_acessorios_nf (emitido, atualizado_em DESC) INCLUDE (lancamento, numero_titulo, loja, veiculo_chassi);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_controle_acessorios_nf_chassi' AND object_id = OBJECT_ID('dbo.controle_acessorios_nf'))
    CREATE INDEX IX_controle_acessorios_nf_chassi ON dbo.controle_acessorios_nf (veiculo_chassi) INCLUDE (emitido, lancamento, loja, atualizado_em);

IF COL_LENGTH('dbo.controle_acessorios_nf', 'observacao') IS NULL
    ALTER TABLE dbo.controle_acessorios_nf ADD observacao NVARCHAR(300) NULL;

IF OBJECT_ID('dbo.controle_acessorios_nf_log','U') IS NULL
BEGIN
    CREATE TABLE dbo.controle_acessorios_nf_log
    (
        id_log BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_controle_acessorios_nf_log PRIMARY KEY,
        chave_controle NVARCHAR(180) NOT NULL,
        lancamento BIGINT NULL,
        acao NVARCHAR(40) NOT NULL,
        usuario_codigo NVARCHAR(50) NULL,
        usuario_nome NVARCHAR(160) NULL,
        observacao NVARCHAR(300) NULL,
        ip NVARCHAR(80) NULL,
        pagina NVARCHAR(260) NULL,
        criado_em DATETIME2(0) NOT NULL CONSTRAINT DF_controle_acessorios_nf_log_criado DEFAULT(SYSDATETIME())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_controle_acessorios_nf_log_chave' AND object_id = OBJECT_ID('dbo.controle_acessorios_nf_log'))
    CREATE INDEX IX_controle_acessorios_nf_log_chave ON dbo.controle_acessorios_nf_log (chave_controle, criado_em DESC);

IF COL_LENGTH('dbo.controle_acessorios_nf_log', 'observacao') IS NULL
    ALTER TABLE dbo.controle_acessorios_nf_log ADD observacao NVARCHAR(300) NULL;

IF OBJECT_ID('dbo.controle_acessorios_nf_relatorio','U') IS NULL
BEGIN
    CREATE TABLE dbo.controle_acessorios_nf_relatorio
    (
        id_relatorio BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_controle_acessorios_nf_relatorio PRIMARY KEY,
        usuario_codigo NVARCHAR(50) NULL,
        usuario_nome NVARCHAR(160) NULL,
        total_itens INT NOT NULL,
        valor_total DECIMAL(18,2) NOT NULL,
        ip NVARCHAR(80) NULL,
        pagina NVARCHAR(260) NULL,
        gerado_em DATETIME2(0) NOT NULL CONSTRAINT DF_controle_acessorios_nf_relatorio_gerado DEFAULT(SYSDATETIME())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_controle_acessorios_nf_relatorio_usuario_data' AND object_id = OBJECT_ID('dbo.controle_acessorios_nf_relatorio'))
    CREATE INDEX IX_controle_acessorios_nf_relatorio_usuario_data ON dbo.controle_acessorios_nf_relatorio (usuario_codigo, gerado_em DESC) INCLUDE (usuario_nome, total_itens, valor_total);

IF OBJECT_ID('dbo.controle_acessorios_nf_relatorio_item','U') IS NULL
BEGIN
    CREATE TABLE dbo.controle_acessorios_nf_relatorio_item
    (
        id_item BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_controle_acessorios_nf_relatorio_item PRIMARY KEY,
        id_relatorio BIGINT NOT NULL,
        chave_controle NVARCHAR(180) NOT NULL,
        lancamento BIGINT NOT NULL,
        numero_titulo NVARCHAR(60) NULL,
        loja NVARCHAR(120) NULL,
        veiculo_chassi NVARCHAR(60) NULL,
        valor_nf DECIMAL(18,2) NOT NULL,
        criado_em DATETIME2(0) NOT NULL CONSTRAINT DF_controle_acessorios_nf_relatorio_item_criado DEFAULT(SYSDATETIME())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_controle_acessorios_nf_relatorio_item_relatorio' AND object_id = OBJECT_ID('dbo.controle_acessorios_nf_relatorio_item'))
    CREATE INDEX IX_controle_acessorios_nf_relatorio_item_relatorio ON dbo.controle_acessorios_nf_relatorio_item (id_relatorio, lancamento);

IF COL_LENGTH('dbo.controle_acessorios_nf_relatorio_item', 'loja') IS NULL
    ALTER TABLE dbo.controle_acessorios_nf_relatorio_item ADD loja NVARCHAR(120) NULL;
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

    public static DataTable ListarAbertos()
    {
        GarantirEstrutura();

        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
SELECT
    cr.Titulo_Codigo AS Lancamento,
    CONVERT(NVARCHAR(60), cr.titulo_numero) AS NumeroTitulo,
    cr.empresa_nomefantasia AS Loja,
    cr.pessoa_nome AS Fornecedor,
    CAST(cr.Titulo_DataEmissao AS DATE) AS DataEmissaoValor,
    CONVERT(VARCHAR(10), cr.Titulo_DataEmissao, 103) AS DataEmissao,
    CAST(ti.Titulo_DataVencimento AS DATE) AS DataVencimentoValor,
    CONVERT(VARCHAR(10), ti.Titulo_DataVencimento, 103) AS DataVencimento,
    CAST(cr.titulo_valor AS DECIMAL(18,2)) AS TituloValor,
    CAST(ti.titulo_saldo AS DECIMAL(18,2)) AS Saldo,
    v.Veiculo_Chassi,
    SUBSTRING(v.Veiculo_Descricao, 1, 25) AS Veiculo,
    chave.ChaveControle,
    CAST(ISNULL(ctrl.emitido, 0) AS BIT) AS Emitido,
    ctrl.marcado_usuario_nome AS MarcadoUsuario,
    ctrl.marcado_usuario_codigo AS MarcadoCodigo,
    CASE WHEN ctrl.marcado_em IS NULL THEN NULL ELSE CONVERT(VARCHAR(10), ctrl.marcado_em, 103) + ' ' + CONVERT(VARCHAR(5), ctrl.marcado_em, 108) END AS MarcadoEm,
    ctrl.observacao AS Observacao,
    ctrl.atualizado_em AS AtualizadoEm
FROM [GrupoBali_DealernetWF].[dbo].RFN_ContasAPagar cr WITH (NOLOCK)
INNER JOIN [GrupoBali_DealernetWF].[dbo].titulo ti WITH (NOLOCK)
    ON ti.Titulo_Codigo = cr.Titulo_Codigo
   AND ti.Titulo_EmpresaCod = cr.Titulo_EmpresaCod
INNER JOIN [GrupoBali_DealernetWF].[dbo].veiculo v WITH (NOLOCK)
    ON v.veiculo_Codigo = ti.Titulo_VeiculoCod
CROSS APPLY
(
    SELECT CONVERT(NVARCHAR(40), cr.Titulo_Codigo) + N'|' + ISNULL(CONVERT(NVARCHAR(60), cr.titulo_numero), N'') + N'|' + ISNULL(v.Veiculo_Chassi, N'') AS ChaveControle
) chave
LEFT JOIN dbo.controle_acessorios_nf ctrl WITH (NOLOCK)
    ON ctrl.chave_controle = chave.ChaveControle
WHERE cr.titulo_status = 'AUT'
  AND cr.titulo_pessoacod = 219982
ORDER BY ISNULL(ctrl.emitido, 0), ti.Titulo_DataVencimento, cr.Titulo_Codigo;", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    public static ControleAcessoriosRelatorioResumo MarcarEmitidas(IEnumerable<string> chaves, string usuarioCodigo, string usuarioNome, string observacao, HttpContext contexto)
    {
        return MarcarEmitidasComRelatorio(chaves, usuarioCodigo, usuarioNome, observacao, contexto);
    }

    public static int DesmarcarEmitidas(IEnumerable<string> chaves, string usuarioCodigo, string usuarioNome, string observacao, HttpContext contexto)
    {
        return AlterarMarcacao(chaves, false, usuarioCodigo, usuarioNome, observacao, contexto);
    }

    public static DataTable ListarItensRelatorio(long idRelatorio)
    {
        GarantirEstrutura();

        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
SELECT
    lancamento AS Lancamento,
    numero_titulo AS NumeroTitulo,
    ISNULL(loja, N'') AS Loja,
    veiculo_chassi AS VeiculoChassi,
    valor_nf AS ValorNF
FROM dbo.controle_acessorios_nf_relatorio_item WITH (NOLOCK)
WHERE id_relatorio = @id_relatorio
ORDER BY lancamento, numero_titulo;", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add("@id_relatorio", SqlDbType.BigInt).Value = idRelatorio;
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    public static DataRow ObterRelatorio(long idRelatorio)
    {
        GarantirEstrutura();

        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
SELECT TOP (1)
    id_relatorio AS IdRelatorio,
    usuario_codigo AS UsuarioCodigo,
    usuario_nome AS UsuarioNome,
    total_itens AS TotalItens,
    valor_total AS ValorTotal,
    gerado_em AS GeradoEm
FROM dbo.controle_acessorios_nf_relatorio WITH (NOLOCK)
WHERE id_relatorio = @id_relatorio;", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add("@id_relatorio", SqlDbType.BigInt).Value = idRelatorio;
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela.Rows.Count == 0 ? null : tabela.Rows[0];
        }
    }

    public static DataTable ListarItensMarcadosNoDia(string usuarioCodigo, string usuarioNome, DateTime data)
    {
        GarantirEstrutura();

        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
SELECT
    lancamento AS Lancamento,
    numero_titulo AS NumeroTitulo,
    loja AS Loja,
    veiculo_chassi AS VeiculoChassi,
    saldo AS ValorNF,
    marcado_em AS MarcadoEm,
    marcado_usuario_nome AS UsuarioNome,
    observacao AS Observacao
FROM dbo.controle_acessorios_nf WITH (NOLOCK)
WHERE emitido = 1
  AND marcado_em >= @inicio
  AND marcado_em < @fim
  AND (
        NULLIF(@usuario_codigo, N'') IS NULL
        OR marcado_usuario_codigo = @usuario_codigo
        OR (NULLIF(marcado_usuario_codigo, N'') IS NULL AND marcado_usuario_nome = @usuario_nome)
      )
ORDER BY marcado_em, lancamento, numero_titulo;", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add("@inicio", SqlDbType.DateTime2).Value = data.Date;
            cmd.Parameters.Add("@fim", SqlDbType.DateTime2).Value = data.Date.AddDays(1);
            cmd.Parameters.Add("@usuario_codigo", SqlDbType.NVarChar, 50).Value = Limitar(usuarioCodigo, 50);
            cmd.Parameters.Add("@usuario_nome", SqlDbType.NVarChar, 160).Value = Limitar(usuarioNome, 160);
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    public static DataTable ListarRelatoriosDoDia(string usuarioCodigo, string usuarioNome, DateTime data)
    {
        GarantirEstrutura();

        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
SELECT
    id_relatorio AS IdRelatorio,
    usuario_nome AS UsuarioNome,
    total_itens AS TotalItens,
    valor_total AS ValorTotal,
    gerado_em AS GeradoEm
FROM dbo.controle_acessorios_nf_relatorio WITH (NOLOCK)
WHERE gerado_em >= @inicio
  AND gerado_em < @fim
  AND (
        NULLIF(@usuario_codigo, N'') IS NULL
        OR usuario_codigo = @usuario_codigo
        OR (NULLIF(usuario_codigo, N'') IS NULL AND usuario_nome = @usuario_nome)
      )
ORDER BY gerado_em DESC, id_relatorio DESC;", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add("@inicio", SqlDbType.DateTime2).Value = data.Date;
            cmd.Parameters.Add("@fim", SqlDbType.DateTime2).Value = data.Date.AddDays(1);
            cmd.Parameters.Add("@usuario_codigo", SqlDbType.NVarChar, 50).Value = Limitar(usuarioCodigo, 50);
            cmd.Parameters.Add("@usuario_nome", SqlDbType.NVarChar, 160).Value = Limitar(usuarioNome, 160);
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    public static DataTable ListarHistorico(string chaveControle)
    {
        GarantirEstrutura();

        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
SELECT TOP (100)
    criado_em AS DataHora,
    acao AS Acao,
    usuario_nome AS UsuarioNome,
    usuario_codigo AS UsuarioCodigo,
    observacao AS Observacao,
    ip AS Ip,
    CAST(NULL AS BIGINT) AS IdRelatorio
FROM dbo.controle_acessorios_nf_log WITH (NOLOCK)
WHERE chave_controle = @chave_controle
UNION ALL
SELECT TOP (100)
    r.gerado_em AS DataHora,
    N'RELATORIO_GERADO' AS Acao,
    r.usuario_nome AS UsuarioNome,
    r.usuario_codigo AS UsuarioCodigo,
    N'Relat' + NCHAR(243) + N'rio #' + CONVERT(NVARCHAR(30), r.id_relatorio) AS Observacao,
    r.ip AS Ip,
    r.id_relatorio AS IdRelatorio
FROM dbo.controle_acessorios_nf_relatorio_item i WITH (NOLOCK)
INNER JOIN dbo.controle_acessorios_nf_relatorio r WITH (NOLOCK)
    ON r.id_relatorio = i.id_relatorio
WHERE i.chave_controle = @chave_controle
ORDER BY DataHora DESC;", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add("@chave_controle", SqlDbType.NVarChar, 180).Value = Limitar(chaveControle, 180);
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    private static ControleAcessoriosRelatorioResumo MarcarEmitidasComRelatorio(IEnumerable<string> chaves, string usuarioCodigo, string usuarioNome, string observacao, HttpContext contexto)
    {
        HashSet<string> selecionadas = NormalizarChaves(chaves);
        if (selecionadas.Count == 0) return new ControleAcessoriosRelatorioResumo();

        DataTable abertos = ListarAbertos();
        DataTable itensRelatorio = CriarTabelaItensRelatorio();
        int total = 0;

        foreach (DataRow row in abertos.Rows)
        {
            string chave = Valor(row, "ChaveControle");
            if (!selecionadas.Contains(chave)) continue;

            SalvarMarcacao(row, true, usuarioCodigo, usuarioNome, observacao, contexto);
            AdicionarItemRelatorio(itensRelatorio, row);
            total++;
        }

        if (total == 0) return new ControleAcessoriosRelatorioResumo();

        return CriarRelatorio(itensRelatorio, usuarioCodigo, usuarioNome, contexto);
    }

    private static int AlterarMarcacao(IEnumerable<string> chaves, bool emitido, string usuarioCodigo, string usuarioNome, string observacao, HttpContext contexto)
    {
        HashSet<string> selecionadas = NormalizarChaves(chaves);
        if (selecionadas.Count == 0) return 0;

        DataTable abertos = ListarAbertos();
        int total = 0;

        foreach (DataRow row in abertos.Rows)
        {
            string chave = Valor(row, "ChaveControle");
            if (!selecionadas.Contains(chave)) continue;

            SalvarMarcacao(row, emitido, usuarioCodigo, usuarioNome, observacao, contexto);
            total++;
        }

        return total;
    }

    private static ControleAcessoriosRelatorioResumo CriarRelatorio(DataTable itens, string usuarioCodigo, string usuarioNome, HttpContext contexto)
    {
        ControleAcessoriosRelatorioResumo resumo = new ControleAcessoriosRelatorioResumo();
        if (itens == null || itens.Rows.Count == 0) return resumo;

        decimal total = 0;
        foreach (DataRow row in itens.Rows)
        {
            total += DecimalValor(row["ValorNF"]);
        }

        using (SqlConnection con = new SqlConnection(ConnectionString))
        {
            con.Open();
            using (SqlTransaction transacao = con.BeginTransaction())
            {
                try
                {
                    long idRelatorio;
                    using (SqlCommand cmd = new SqlCommand(@"
INSERT INTO dbo.controle_acessorios_nf_relatorio
(
    usuario_codigo, usuario_nome, total_itens, valor_total, ip, pagina
)
OUTPUT INSERTED.id_relatorio
VALUES
(
    NULLIF(@usuario_codigo, N''), NULLIF(@usuario_nome, N''), @total_itens, @valor_total, NULLIF(@ip, N''), NULLIF(@pagina, N'')
);", con, transacao))
                    {
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandTimeout = TimeoutSqlSegundos;
                        cmd.Parameters.Add("@usuario_codigo", SqlDbType.NVarChar, 50).Value = Limitar(usuarioCodigo, 50);
                        cmd.Parameters.Add("@usuario_nome", SqlDbType.NVarChar, 160).Value = Limitar(usuarioNome, 160);
                        cmd.Parameters.Add("@total_itens", SqlDbType.Int).Value = itens.Rows.Count;
                        cmd.Parameters.Add("@valor_total", SqlDbType.Decimal).Value = total;
                        cmd.Parameters["@valor_total"].Precision = 18;
                        cmd.Parameters["@valor_total"].Scale = 2;
                        cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 80).Value = Limitar(Ip(contexto), 80);
                        cmd.Parameters.Add("@pagina", SqlDbType.NVarChar, 260).Value = Limitar(Pagina(contexto), 260);
                        idRelatorio = Convert.ToInt64(cmd.ExecuteScalar());
                    }

                    foreach (DataRow row in itens.Rows)
                    {
                        using (SqlCommand cmdItem = new SqlCommand(@"
INSERT INTO dbo.controle_acessorios_nf_relatorio_item
(
    id_relatorio, chave_controle, lancamento, numero_titulo, loja, veiculo_chassi, valor_nf
)
VALUES
(
    @id_relatorio, @chave_controle, @lancamento, NULLIF(@numero_titulo, N''), NULLIF(@loja, N''), NULLIF(@veiculo_chassi, N''), @valor_nf
);", con, transacao))
                        {
                            cmdItem.CommandType = CommandType.Text;
                            cmdItem.CommandTimeout = TimeoutSqlSegundos;
                            cmdItem.Parameters.Add("@id_relatorio", SqlDbType.BigInt).Value = idRelatorio;
                            cmdItem.Parameters.Add("@chave_controle", SqlDbType.NVarChar, 180).Value = Limitar(Valor(row, "ChaveControle"), 180);
                            cmdItem.Parameters.Add("@lancamento", SqlDbType.BigInt).Value = ConverterLong(row, "Lancamento");
                            cmdItem.Parameters.Add("@numero_titulo", SqlDbType.NVarChar, 60).Value = Limitar(Valor(row, "NumeroTitulo"), 60);
                            cmdItem.Parameters.Add("@loja", SqlDbType.NVarChar, 120).Value = Limitar(Valor(row, "Loja"), 120);
                            cmdItem.Parameters.Add("@veiculo_chassi", SqlDbType.NVarChar, 60).Value = Limitar(Valor(row, "VeiculoChassi"), 60);
                            cmdItem.Parameters.Add("@valor_nf", SqlDbType.Decimal).Value = DecimalValor(row["ValorNF"]);
                            cmdItem.Parameters["@valor_nf"].Precision = 18;
                            cmdItem.Parameters["@valor_nf"].Scale = 2;
                            cmdItem.ExecuteNonQuery();
                        }
                    }

                    transacao.Commit();

                    resumo.IdRelatorio = idRelatorio;
                    resumo.TotalItens = itens.Rows.Count;
                    resumo.ValorTotal = total;
                    return resumo;
                }
                catch
                {
                    transacao.Rollback();
                    throw;
                }
            }
        }
    }

    private static DataTable CriarTabelaItensRelatorio()
    {
        DataTable tabela = new DataTable();
        tabela.Columns.Add("ChaveControle", typeof(string));
        tabela.Columns.Add("Lancamento", typeof(long));
        tabela.Columns.Add("NumeroTitulo", typeof(string));
        tabela.Columns.Add("Loja", typeof(string));
        tabela.Columns.Add("VeiculoChassi", typeof(string));
        tabela.Columns.Add("ValorNF", typeof(decimal));
        return tabela;
    }

    private static void AdicionarItemRelatorio(DataTable tabela, DataRow origem)
    {
        DataRow item = tabela.NewRow();
        item["ChaveControle"] = Valor(origem, "ChaveControle");
        item["Lancamento"] = ConverterLong(origem, "Lancamento");
        item["NumeroTitulo"] = Valor(origem, "NumeroTitulo");
        item["Loja"] = Valor(origem, "Loja");
        item["VeiculoChassi"] = Valor(origem, "Veiculo_Chassi");
        item["ValorNF"] = DecimalValor(origem["Saldo"]);
        tabela.Rows.Add(item);
    }

    private static void SalvarMarcacao(DataRow row, bool emitido, string usuarioCodigo, string usuarioNome, string observacao, HttpContext contexto)
    {
        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
DECLARE @id_controle BIGINT;

SELECT TOP (1) @id_controle = id_controle
FROM dbo.controle_acessorios_nf WITH (UPDLOCK, HOLDLOCK)
WHERE chave_controle = @chave_controle;

IF @id_controle IS NULL
BEGIN
    INSERT INTO dbo.controle_acessorios_nf
    (
        chave_controle, lancamento, numero_titulo, loja, fornecedor, data_emissao, data_vencimento,
        titulo_valor, saldo, veiculo_chassi, veiculo, emitido,
        marcado_em, marcado_usuario_codigo, marcado_usuario_nome,
        desmarcado_em, desmarcado_usuario_codigo, desmarcado_usuario_nome,
        observacao, ip, pagina, atualizado_em
    )
    VALUES
    (
        @chave_controle, @lancamento, NULLIF(@numero_titulo, N''), NULLIF(@loja, N''), NULLIF(@fornecedor, N''),
        @data_emissao, @data_vencimento, @titulo_valor, @saldo, NULLIF(@veiculo_chassi, N''), NULLIF(@veiculo, N''),
        @emitido,
        CASE WHEN @emitido = 1 THEN SYSDATETIME() ELSE NULL END,
        CASE WHEN @emitido = 1 THEN NULLIF(@usuario_codigo, N'') ELSE NULL END,
        CASE WHEN @emitido = 1 THEN NULLIF(@usuario_nome, N'') ELSE NULL END,
        CASE WHEN @emitido = 0 THEN SYSDATETIME() ELSE NULL END,
        CASE WHEN @emitido = 0 THEN NULLIF(@usuario_codigo, N'') ELSE NULL END,
        CASE WHEN @emitido = 0 THEN NULLIF(@usuario_nome, N'') ELSE NULL END,
        NULLIF(@observacao, N''), NULLIF(@ip, N''), NULLIF(@pagina, N''), SYSDATETIME()
    );
END
ELSE
BEGIN
    UPDATE dbo.controle_acessorios_nf
       SET lancamento = @lancamento,
           numero_titulo = NULLIF(@numero_titulo, N''),
           loja = NULLIF(@loja, N''),
           fornecedor = NULLIF(@fornecedor, N''),
           data_emissao = @data_emissao,
           data_vencimento = @data_vencimento,
           titulo_valor = @titulo_valor,
           saldo = @saldo,
           veiculo_chassi = NULLIF(@veiculo_chassi, N''),
           veiculo = NULLIF(@veiculo, N''),
           emitido = @emitido,
           marcado_em = CASE WHEN @emitido = 1 THEN SYSDATETIME() ELSE marcado_em END,
           marcado_usuario_codigo = CASE WHEN @emitido = 1 THEN NULLIF(@usuario_codigo, N'') ELSE marcado_usuario_codigo END,
           marcado_usuario_nome = CASE WHEN @emitido = 1 THEN NULLIF(@usuario_nome, N'') ELSE marcado_usuario_nome END,
           desmarcado_em = CASE WHEN @emitido = 0 THEN SYSDATETIME() ELSE desmarcado_em END,
           desmarcado_usuario_codigo = CASE WHEN @emitido = 0 THEN NULLIF(@usuario_codigo, N'') ELSE desmarcado_usuario_codigo END,
           desmarcado_usuario_nome = CASE WHEN @emitido = 0 THEN NULLIF(@usuario_nome, N'') ELSE desmarcado_usuario_nome END,
           observacao = NULLIF(@observacao, N''),
           ip = NULLIF(@ip, N''),
           pagina = NULLIF(@pagina, N''),
           atualizado_em = SYSDATETIME()
     WHERE id_controle = @id_controle;
END;

INSERT INTO dbo.controle_acessorios_nf_log
(
    chave_controle, lancamento, acao, usuario_codigo, usuario_nome, observacao, ip, pagina
)
VALUES
(
    @chave_controle, @lancamento, CASE WHEN @emitido = 1 THEN N'MARCAR_NF_EMITIDA' ELSE N'DESMARCAR_NF_EMITIDA' END,
    NULLIF(@usuario_codigo, N''), NULLIF(@usuario_nome, N''), NULLIF(@observacao, N''), NULLIF(@ip, N''), NULLIF(@pagina, N'')
);", con))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add("@chave_controle", SqlDbType.NVarChar, 180).Value = Limitar(Valor(row, "ChaveControle"), 180);
            cmd.Parameters.Add("@lancamento", SqlDbType.BigInt).Value = ConverterLong(row, "Lancamento");
            cmd.Parameters.Add("@numero_titulo", SqlDbType.NVarChar, 60).Value = Limitar(Valor(row, "NumeroTitulo"), 60);
            cmd.Parameters.Add("@loja", SqlDbType.NVarChar, 120).Value = Limitar(Valor(row, "Loja"), 120);
            cmd.Parameters.Add("@fornecedor", SqlDbType.NVarChar, 220).Value = Limitar(Valor(row, "Fornecedor"), 220);
            cmd.Parameters.Add("@data_emissao", SqlDbType.Date).Value = ConverterDataOuNulo(row, "DataEmissaoValor");
            cmd.Parameters.Add("@data_vencimento", SqlDbType.Date).Value = ConverterDataOuNulo(row, "DataVencimentoValor");
            cmd.Parameters.Add("@titulo_valor", SqlDbType.Decimal).Value = ConverterDecimalOuNulo(row, "TituloValor");
            cmd.Parameters["@titulo_valor"].Precision = 18;
            cmd.Parameters["@titulo_valor"].Scale = 2;
            cmd.Parameters.Add("@saldo", SqlDbType.Decimal).Value = ConverterDecimalOuNulo(row, "Saldo");
            cmd.Parameters["@saldo"].Precision = 18;
            cmd.Parameters["@saldo"].Scale = 2;
            cmd.Parameters.Add("@veiculo_chassi", SqlDbType.NVarChar, 60).Value = Limitar(Valor(row, "Veiculo_Chassi"), 60);
            cmd.Parameters.Add("@veiculo", SqlDbType.NVarChar, 160).Value = Limitar(Valor(row, "Veiculo"), 160);
            cmd.Parameters.Add("@emitido", SqlDbType.Bit).Value = emitido;
            cmd.Parameters.Add("@usuario_codigo", SqlDbType.NVarChar, 50).Value = Limitar(usuarioCodigo, 50);
            cmd.Parameters.Add("@usuario_nome", SqlDbType.NVarChar, 160).Value = Limitar(usuarioNome, 160);
            cmd.Parameters.Add("@observacao", SqlDbType.NVarChar, 300).Value = Limitar(observacao, 300);
            cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 80).Value = Limitar(Ip(contexto), 80);
            cmd.Parameters.Add("@pagina", SqlDbType.NVarChar, 260).Value = Limitar(Pagina(contexto), 260);

            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private static HashSet<string> NormalizarChaves(IEnumerable<string> chaves)
    {
        HashSet<string> retorno = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        if (chaves == null) return retorno;

        foreach (string chave in chaves)
        {
            string valor = (chave ?? "").Trim();
            if (valor.Length > 0 && valor.Length <= 180)
            {
                retorno.Add(valor);
            }
        }

        return retorno;
    }

    private static string Valor(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value) return "";
        return Convert.ToString(row[coluna]).Trim();
    }

    private static string Limitar(string valor, int tamanho)
    {
        valor = (valor ?? "").Trim();
        return valor.Length <= tamanho ? valor : valor.Substring(0, tamanho);
    }

    private static long ConverterLong(DataRow row, string coluna)
    {
        long valor;
        if (Int64.TryParse(Valor(row, coluna), out valor)) return valor;
        return 0;
    }

    private static object ConverterDataOuNulo(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value) return DBNull.Value;
        DateTime data;
        if (DateTime.TryParse(Convert.ToString(row[coluna]), out data)) return data.Date;
        return DBNull.Value;
    }

    private static object ConverterDecimalOuNulo(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value) return DBNull.Value;

        object valorOriginal = row[coluna];
        if (valorOriginal is decimal) return (decimal)valorOriginal;
        if (valorOriginal is int || valorOriginal is long || valorOriginal is short || valorOriginal is byte)
        {
            return Convert.ToDecimal(valorOriginal, CultureInfo.InvariantCulture);
        }

        if (valorOriginal is double || valorOriginal is float)
        {
            return Convert.ToDecimal(valorOriginal, CultureInfo.InvariantCulture);
        }

        string texto = Convert.ToString(valorOriginal).Trim();
        if (texto.Length == 0) return DBNull.Value;

        decimal valor;
        CultureInfo ptBr = new CultureInfo("pt-BR");

        bool temVirgula = texto.IndexOf(',') >= 0;
        bool temPonto = texto.IndexOf('.') >= 0;

        if (temVirgula && (!temPonto || texto.LastIndexOf(',') > texto.LastIndexOf('.')))
        {
            if (Decimal.TryParse(texto, NumberStyles.Any, ptBr, out valor)) return valor;
        }

        if (Decimal.TryParse(texto, NumberStyles.Any, CultureInfo.InvariantCulture, out valor)) return valor;
        if (Decimal.TryParse(texto, NumberStyles.Any, ptBr, out valor)) return valor;
        return DBNull.Value;
    }

    private static decimal DecimalValor(object valorOriginal)
    {
        if (valorOriginal == null || valorOriginal == DBNull.Value) return 0;
        if (valorOriginal is decimal) return (decimal)valorOriginal;
        if (valorOriginal is int || valorOriginal is long || valorOriginal is short || valorOriginal is byte)
        {
            return Convert.ToDecimal(valorOriginal, CultureInfo.InvariantCulture);
        }

        if (valorOriginal is double || valorOriginal is float)
        {
            return Convert.ToDecimal(valorOriginal, CultureInfo.InvariantCulture);
        }

        string texto = Convert.ToString(valorOriginal).Trim();
        if (texto.Length == 0) return 0;

        decimal valor;
        CultureInfo ptBr = new CultureInfo("pt-BR");
        bool temVirgula = texto.IndexOf(',') >= 0;
        bool temPonto = texto.IndexOf('.') >= 0;

        if (temVirgula && (!temPonto || texto.LastIndexOf(',') > texto.LastIndexOf('.')))
        {
            if (Decimal.TryParse(texto, NumberStyles.Any, ptBr, out valor)) return valor;
        }

        if (Decimal.TryParse(texto, NumberStyles.Any, CultureInfo.InvariantCulture, out valor)) return valor;
        if (Decimal.TryParse(texto, NumberStyles.Any, ptBr, out valor)) return valor;
        return 0;
    }

    private static string Ip(HttpContext contexto)
    {
        if (contexto == null || contexto.Request == null) return "";
        string forwarded = contexto.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
        if (!String.IsNullOrWhiteSpace(forwarded)) return forwarded.Split(',')[0].Trim();
        return contexto.Request.UserHostAddress ?? "";
    }

    private static string Pagina(HttpContext contexto)
    {
        if (contexto == null || contexto.Request == null) return "";
        return contexto.Request.RawUrl ?? "";
    }

    public class ControleAcessoriosRelatorioResumo
    {
        public long IdRelatorio { get; set; }
        public int TotalItens { get; set; }
        public decimal ValorTotal { get; set; }
    }
}
