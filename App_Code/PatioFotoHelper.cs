using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;

public class PatioFotoResultado
{
    public bool Sucesso { get; set; }
    public bool SemFoto { get; set; }
    public string Mensagem { get; set; }
    public string Url { get; set; }
    public long Bytes { get; set; }
}

public static class PatioFotoHelper
{
    private const int MaxDataUrlLength = 5000000;
    private const int MaxSide = 900;
    private const long JpegQuality = 45L;
    private static readonly object EstruturaLock = new object();
    private static bool EstruturaVerificada = false;

    public static void GarantirEstrutura()
    {
        if (EstruturaVerificada) return;

        lock (EstruturaLock)
        {
            if (EstruturaVerificada) return;

            Jeep banco = new Jeep();
            try
            {
                banco.Conexao2();
                using (SqlCommand cmd = new SqlCommand(@"
IF OBJECT_ID('dbo.veiculos_patio_foto', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.veiculos_patio_foto
    (
        id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_veiculos_patio_foto PRIMARY KEY,
        tipo varchar(20) NOT NULL,
        ve_nr varchar(50) NULL,
        seminovo_id int NULL,
        caminho varchar(260) NOT NULL,
        tamanho_bytes int NULL,
        largura int NULL,
        altura int NULL,
        usuario varchar(100) NULL,
        dt_cad datetime NOT NULL CONSTRAINT DF_veiculos_patio_foto_dt DEFAULT (GETDATE()),
        ativo bit NOT NULL CONSTRAINT DF_veiculos_patio_foto_ativo DEFAULT (1),
        dt_remocao datetime NULL,
        motivo_remocao varchar(100) NULL
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_foto_ativo_tipo_ve' AND object_id = OBJECT_ID('dbo.veiculos_patio_foto'))
BEGIN
    CREATE INDEX IX_veiculos_patio_foto_ativo_tipo_ve
        ON dbo.veiculos_patio_foto(ativo, tipo, ve_nr, dt_cad DESC)
        INCLUDE (caminho, seminovo_id, tamanho_bytes, largura, altura);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_foto_ativo_seminovo' AND object_id = OBJECT_ID('dbo.veiculos_patio_foto'))
BEGIN
    CREATE INDEX IX_veiculos_patio_foto_ativo_seminovo
        ON dbo.veiculos_patio_foto(ativo, tipo, seminovo_id, dt_cad DESC)
        INCLUDE (caminho, ve_nr, tamanho_bytes, largura, altura);
END;", banco.oCon2))
                {
                    cmd.CommandTimeout = 60;
                    cmd.ExecuteNonQuery();
                }

                EstruturaVerificada = true;
            }
            finally
            {
                banco.FecharConexao2();
            }
        }
    }

    public static PatioFotoResultado SalvarFotoBase64(HttpContext contexto, string tipo, string veNr, int? seminovoId, string dataUrl, string usuario)
    {
        PatioFotoResultado vazio = new PatioFotoResultado { Sucesso = true, SemFoto = true, Mensagem = "" };
        if (String.IsNullOrWhiteSpace(dataUrl)) return vazio;

        try
        {
            GarantirEstrutura();

            if (EhUrlTemporaria(dataUrl))
            {
                return ConfirmarFotoTemporaria(contexto, tipo, veNr, seminovoId, dataUrl, usuario);
            }

            if (dataUrl.Length > MaxDataUrlLength)
            {
                return Falha("A foto ficou grande demais. Tire outra foto um pouco mais distante ou escolha uma imagem menor.");
            }

            int virgula = dataUrl.IndexOf(',');
            if (virgula < 0 || !dataUrl.Substring(0, Math.Min(30, dataUrl.Length)).StartsWith("data:image/", StringComparison.OrdinalIgnoreCase))
            {
                return Falha("A imagem enviada nao parece ser uma foto valida.");
            }

            byte[] origem = Convert.FromBase64String(dataUrl.Substring(virgula + 1));
            if (origem.Length == 0) return vazio;

            string tipoSeguro = ApenasSeguro(tipo, "PATIO");
            string refSeguro = ApenasSeguro(!String.IsNullOrWhiteSpace(veNr) ? veNr : Convert.ToString(seminovoId.GetValueOrDefault()), "SEMREF");
            string nome = tipoSeguro + "_" + refSeguro + "_" + DateTime.Now.ToString("yyyyMMddHHmmssfff") + ".jpg";
            string caminhoFisico = Path.Combine(PastaFisica(contexto, DateTime.Now), nome);
            int largura;
            int altura;
            SalvarBytesComoJpeg(origem, caminhoFisico, out largura, out altura);

            FileInfo arquivo = new FileInfo(caminhoFisico);
            string url = CaminhoVirtual(DateTime.Now, nome);
            List<string> fotosAnteriores = BuscarFotosAtivas(tipoSeguro, veNr, seminovoId);
            DesativarFotosAtivas(tipoSeguro, veNr, seminovoId, "SUBSTITUIDA");
            RemoverArquivos(contexto, fotosAnteriores);
            InserirFoto(tipoSeguro, veNr, seminovoId, url, arquivo.Length, largura, altura, usuario);

            return new PatioFotoResultado { Sucesso = true, SemFoto = false, Mensagem = "Foto salva e comprimida.", Url = url };
        }
        catch (Exception ex)
        {
            PatioJeepAuditoria.Registrar("PATIO_FOTO_ERRO", usuario, veNr ?? Convert.ToString(seminovoId.GetValueOrDefault()), ex.Message);
            return Falha("O registro foi salvo, mas nao consegui gravar a foto. Tente anexar a foto novamente depois.");
        }
    }

    public static PatioFotoResultado SalvarFotoTemporariaBase64(HttpContext contexto, string dataUrl, string usuario)
    {
        if (String.IsNullOrWhiteSpace(dataUrl))
        {
            return Falha("Nenhuma foto foi enviada.");
        }

        try
        {
            if (dataUrl.Length > MaxDataUrlLength)
            {
                return Falha("A foto ficou grande demais. Tire outra foto ou escolha uma imagem menor.");
            }

            int virgula = dataUrl.IndexOf(',');
            if (virgula < 0 || !dataUrl.Substring(0, Math.Min(30, dataUrl.Length)).StartsWith("data:image/", StringComparison.OrdinalIgnoreCase))
            {
                return Falha("A imagem enviada nao parece ser uma foto valida.");
            }

            byte[] origem = Convert.FromBase64String(dataUrl.Substring(virgula + 1));
            string nome = "TEMP_" + Guid.NewGuid().ToString("N") + ".jpg";
            DateTime agora = DateTime.Now;
            string caminhoFisico = Path.Combine(PastaTemporariaFisica(contexto, agora), nome);
            int largura;
            int altura;
            SalvarBytesComoJpeg(origem, caminhoFisico, out largura, out altura);
            LimparTemporariasAntigas(contexto);

            FileInfo arquivo = new FileInfo(caminhoFisico);
            return new PatioFotoResultado
            {
                Sucesso = true,
                SemFoto = false,
                Mensagem = "Foto temporaria salva.",
                Url = CaminhoTemporarioVirtual(agora, nome),
                Bytes = arquivo.Length
            };
        }
        catch (Exception ex)
        {
            PatioJeepAuditoria.Registrar("PATIO_FOTO_TEMP_ERRO", usuario, "TEMP", ex.Message);
            return Falha("Nao consegui preparar a foto agora. Tente novamente.");
        }
    }

    public static void RemoverFotosDoVeiculo(HttpContext contexto, string tipo, string veNr, int? seminovoId, string motivo, string usuario)
    {
        try
        {
            GarantirEstrutura();
            List<string> caminhos = BuscarFotosAtivas(tipo, veNr, seminovoId);
            DesativarFotosAtivas(tipo, veNr, seminovoId, motivo);
            RemoverArquivos(contexto, caminhos);
        }
        catch (Exception ex)
        {
            PatioJeepAuditoria.Registrar("PATIO_FOTO_LIMPEZA_ERRO", usuario, veNr ?? Convert.ToString(seminovoId.GetValueOrDefault()), ex.Message);
        }
    }

    public static int LimparFotosBaixadas(HttpContext contexto, string usuario)
    {
        try
        {
            GarantirEstrutura();
            DataTable tabela = ExecutarTabela(@"
SELECT f.id, f.caminho
FROM dbo.veiculos_patio_foto f WITH (NOLOCK)
WHERE f.ativo = 1
  AND (
        (f.tipo = 'NOVO' AND EXISTS (
            SELECT 1
            FROM dbo.veiculos_patio_locacao p WITH (NOLOCK)
            WHERE CONVERT(varchar(50), p.ve_nr) = f.ve_nr
              AND ISNULL(p.baixado_venda, 0) = 1
        ))
     OR (f.tipo = 'SEMINOVO' AND EXISTS (
            SELECT 1
            FROM dbo.veiculos_patio_seminovos_locacao s WITH (NOLOCK)
            WHERE s.id = f.seminovo_id
              AND ISNULL(s.ativo, 0) = 0
        ))
  );");

            if (tabela.Rows.Count == 0) return 0;

            List<int> ids = new List<int>();
            List<string> caminhos = new List<string>();
            foreach (DataRow row in tabela.Rows)
            {
                int id;
                if (Int32.TryParse(Convert.ToString(row["id"]), out id)) ids.Add(id);
                caminhos.Add(Convert.ToString(row["caminho"]));
            }

            MarcarIdsRemovidos(ids, "BAIXA");
            RemoverArquivos(contexto, caminhos);
            return ids.Count;
        }
        catch (Exception ex)
        {
            PatioJeepAuditoria.Registrar("PATIO_FOTO_LIMPEZA_BAIXA_ERRO", usuario, "FOTOS", ex.Message);
            return 0;
        }
    }

    private static PatioFotoResultado Falha(string mensagem)
    {
        return new PatioFotoResultado { Sucesso = false, SemFoto = false, Mensagem = mensagem };
    }

    private static PatioFotoResultado ConfirmarFotoTemporaria(HttpContext contexto, string tipo, string veNr, int? seminovoId, string tempUrl, string usuario)
    {
        string origemFisica = FisicoSeguroDaUrl(contexto, tempUrl);
        if (String.IsNullOrWhiteSpace(origemFisica) || !File.Exists(origemFisica))
        {
            return Falha("A foto temporaria expirou ou nao foi encontrada. Escolha a foto novamente.");
        }

        string tipoSeguro = ApenasSeguro(tipo, "PATIO");
        string refSeguro = ApenasSeguro(!String.IsNullOrWhiteSpace(veNr) ? veNr : Convert.ToString(seminovoId.GetValueOrDefault()), "SEMREF");
        string nome = tipoSeguro + "_" + refSeguro + "_" + DateTime.Now.ToString("yyyyMMddHHmmssfff") + ".jpg";
        string destinoFisico = Path.Combine(PastaFisica(contexto, DateTime.Now), nome);
        Directory.CreateDirectory(Path.GetDirectoryName(destinoFisico));

        int largura = 0;
        int altura = 0;
        using (Image imagem = Image.FromFile(origemFisica))
        {
            largura = imagem.Width;
            altura = imagem.Height;
        }

        List<string> fotosAnteriores = BuscarFotosAtivas(tipoSeguro, veNr, seminovoId);
        DesativarFotosAtivas(tipoSeguro, veNr, seminovoId, "SUBSTITUIDA");
        RemoverArquivos(contexto, fotosAnteriores);

        if (File.Exists(destinoFisico)) File.Delete(destinoFisico);
        File.Move(origemFisica, destinoFisico);

        FileInfo arquivo = new FileInfo(destinoFisico);
        string url = CaminhoVirtual(DateTime.Now, nome);
        InserirFoto(tipoSeguro, veNr, seminovoId, url, arquivo.Length, largura, altura, usuario);
        return new PatioFotoResultado { Sucesso = true, SemFoto = false, Mensagem = "Foto confirmada.", Url = url, Bytes = arquivo.Length };
    }

    private static void SalvarBytesComoJpeg(byte[] origem, string caminhoFisico, out int largura, out int altura)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(caminhoFisico));

        using (MemoryStream entrada = new MemoryStream(origem))
        using (Image imagem = Image.FromStream(entrada, true, true))
        {
            CorrigirOrientacao(imagem);
            Size tamanho = TamanhoReduzido(imagem.Width, imagem.Height);
            largura = tamanho.Width;
            altura = tamanho.Height;

            using (Bitmap destino = new Bitmap(tamanho.Width, tamanho.Height))
            using (Graphics g = Graphics.FromImage(destino))
            {
                g.Clear(Color.White);
                g.CompositingQuality = CompositingQuality.HighSpeed;
                g.InterpolationMode = InterpolationMode.HighQualityBilinear;
                g.SmoothingMode = SmoothingMode.HighSpeed;
                g.DrawImage(imagem, 0, 0, tamanho.Width, tamanho.Height);

                ImageCodecInfo codec = ImageCodecInfo.GetImageEncoders().FirstOrDefault(c => c.FormatID == ImageFormat.Jpeg.Guid);
                if (codec == null)
                {
                    destino.Save(caminhoFisico, ImageFormat.Jpeg);
                }
                else
                {
                    EncoderParameters parametros = new EncoderParameters(1);
                    parametros.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, JpegQuality);
                    destino.Save(caminhoFisico, codec, parametros);
                }
            }
        }
    }

    private static void InserirFoto(string tipo, string veNr, int? seminovoId, string url, long bytes, int largura, int altura, string usuario)
    {
        ExecutarSemRetorno(@"
INSERT INTO dbo.veiculos_patio_foto (tipo, ve_nr, seminovo_id, caminho, tamanho_bytes, largura, altura, usuario)
VALUES (@tipo, @ve_nr, @seminovo_id, @caminho, @tamanho_bytes, @largura, @altura, @usuario);",
            Param("@tipo", SqlDbType.VarChar, tipo),
            Param("@ve_nr", SqlDbType.VarChar, String.IsNullOrWhiteSpace(veNr) ? (object)DBNull.Value : veNr),
            Param("@seminovo_id", SqlDbType.Int, seminovoId.HasValue ? (object)seminovoId.Value : DBNull.Value),
            Param("@caminho", SqlDbType.VarChar, url),
            Param("@tamanho_bytes", SqlDbType.Int, bytes > Int32.MaxValue ? Int32.MaxValue : (int)bytes),
            Param("@largura", SqlDbType.Int, largura),
            Param("@altura", SqlDbType.Int, altura),
            Param("@usuario", SqlDbType.VarChar, usuario ?? ""));
    }

    private static void DesativarFotosAtivas(string tipo, string veNr, int? seminovoId, string motivo)
    {
        ExecutarSemRetorno(@"
UPDATE dbo.veiculos_patio_foto
   SET ativo = 0,
       dt_remocao = GETDATE(),
       motivo_remocao = @motivo
 WHERE ativo = 1
   AND tipo = @tipo
   AND (
        (@seminovo_id IS NOT NULL AND seminovo_id = @seminovo_id)
        OR (@seminovo_id IS NULL AND ISNULL(ve_nr, '') = ISNULL(@ve_nr, ''))
   );",
            Param("@tipo", SqlDbType.VarChar, tipo),
            Param("@ve_nr", SqlDbType.VarChar, String.IsNullOrWhiteSpace(veNr) ? (object)DBNull.Value : veNr),
            Param("@seminovo_id", SqlDbType.Int, seminovoId.HasValue ? (object)seminovoId.Value : DBNull.Value),
            Param("@motivo", SqlDbType.VarChar, motivo ?? "REMOVIDA"));
    }

    private static List<string> BuscarFotosAtivas(string tipo, string veNr, int? seminovoId)
    {
        DataTable tabela = ExecutarTabela(@"
SELECT caminho
FROM dbo.veiculos_patio_foto WITH (NOLOCK)
WHERE ativo = 1
  AND tipo = @tipo
  AND (
        (@seminovo_id IS NOT NULL AND seminovo_id = @seminovo_id)
        OR (@seminovo_id IS NULL AND ISNULL(ve_nr, '') = ISNULL(@ve_nr, ''))
  );",
            Param("@tipo", SqlDbType.VarChar, tipo),
            Param("@ve_nr", SqlDbType.VarChar, String.IsNullOrWhiteSpace(veNr) ? (object)DBNull.Value : veNr),
            Param("@seminovo_id", SqlDbType.Int, seminovoId.HasValue ? (object)seminovoId.Value : DBNull.Value));

        List<string> caminhos = new List<string>();
        foreach (DataRow row in tabela.Rows) caminhos.Add(Convert.ToString(row["caminho"]));
        return caminhos;
    }

    private static void MarcarIdsRemovidos(List<int> ids, string motivo)
    {
        if (ids == null || ids.Count == 0) return;

        string lista = String.Join(",", ids.Select(i => i.ToString()).ToArray());
        ExecutarSemRetorno(@"
UPDATE dbo.veiculos_patio_foto
   SET ativo = 0,
       dt_remocao = GETDATE(),
       motivo_remocao = @motivo
 WHERE id IN (" + lista + ");",
            Param("@motivo", SqlDbType.VarChar, motivo ?? "REMOVIDA"));
    }

    private static void RemoverArquivos(HttpContext contexto, IEnumerable<string> caminhos)
    {
        if (caminhos == null) return;

        string raiz = PastaRaizFisica(contexto);
        string raizCompleta = Path.GetFullPath(raiz).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;

        foreach (string caminho in caminhos)
        {
            if (String.IsNullOrWhiteSpace(caminho)) continue;
            string relativo = caminho.TrimStart('/', '\\').Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
            string fisico = Path.GetFullPath(Path.Combine(AppRoot(contexto), relativo));
            if (!fisico.StartsWith(raizCompleta, StringComparison.OrdinalIgnoreCase)) continue;
            if (File.Exists(fisico)) File.Delete(fisico);
        }
    }

    private static void CorrigirOrientacao(Image imagem)
    {
        const int OrientationId = 0x0112;
        if (!imagem.PropertyIdList.Contains(OrientationId)) return;

        try
        {
            PropertyItem item = imagem.GetPropertyItem(OrientationId);
            int orientacao = BitConverter.ToUInt16(item.Value, 0);
            switch (orientacao)
            {
                case 3:
                    imagem.RotateFlip(RotateFlipType.Rotate180FlipNone);
                    break;
                case 6:
                    imagem.RotateFlip(RotateFlipType.Rotate90FlipNone);
                    break;
                case 8:
                    imagem.RotateFlip(RotateFlipType.Rotate270FlipNone);
                    break;
            }
            imagem.RemovePropertyItem(OrientationId);
        }
        catch
        {
        }
    }

    private static Size TamanhoReduzido(int largura, int altura)
    {
        if (largura <= 0 || altura <= 0) return new Size(MaxSide, MaxSide);
        int maior = Math.Max(largura, altura);
        if (maior <= MaxSide) return new Size(largura, altura);
        double escala = (double)MaxSide / maior;
        return new Size(Math.Max(1, (int)Math.Round(largura * escala)), Math.Max(1, (int)Math.Round(altura * escala)));
    }

    private static string PastaFisica(HttpContext contexto, DateTime data)
    {
        return Path.Combine(PastaRaizFisica(contexto), data.ToString("yyyy"), data.ToString("MM"));
    }

    private static string PastaTemporariaFisica(HttpContext contexto, DateTime data)
    {
        return Path.Combine(PastaRaizFisica(contexto), "temp", data.ToString("yyyy"), data.ToString("MM"));
    }

    private static string PastaRaizFisica(HttpContext contexto)
    {
        return Path.Combine(AppRoot(contexto), "veiculos", "patiojeep", "uploads", "fotos");
    }

    private static string AppRoot(HttpContext contexto)
    {
        if (contexto != null && contexto.Server != null)
        {
            return contexto.Server.MapPath("~/");
        }
        return HttpRuntime.AppDomainAppPath;
    }

    private static string CaminhoVirtual(DateTime data, string nome)
    {
        return "/veiculos/patiojeep/uploads/fotos/" + data.ToString("yyyy") + "/" + data.ToString("MM") + "/" + nome;
    }

    private static string CaminhoTemporarioVirtual(DateTime data, string nome)
    {
        return "/veiculos/patiojeep/uploads/fotos/temp/" + data.ToString("yyyy") + "/" + data.ToString("MM") + "/" + nome;
    }

    private static bool EhUrlTemporaria(string valor)
    {
        return !String.IsNullOrWhiteSpace(valor)
            && valor.Trim().StartsWith("/veiculos/patiojeep/uploads/fotos/temp/", StringComparison.OrdinalIgnoreCase)
            && valor.Trim().EndsWith(".jpg", StringComparison.OrdinalIgnoreCase);
    }

    private static string FisicoSeguroDaUrl(HttpContext contexto, string url)
    {
        if (String.IsNullOrWhiteSpace(url)) return "";
        string normalizada = url.Trim();
        if (!normalizada.StartsWith("/veiculos/patiojeep/uploads/fotos/", StringComparison.OrdinalIgnoreCase)) return "";

        string relativo = normalizada.TrimStart('/', '\\').Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
        string fisico = Path.GetFullPath(Path.Combine(AppRoot(contexto), relativo));
        string raiz = Path.GetFullPath(PastaRaizFisica(contexto)).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
        if (!fisico.StartsWith(raiz, StringComparison.OrdinalIgnoreCase)) return "";
        return fisico;
    }

    private static void LimparTemporariasAntigas(HttpContext contexto)
    {
        try
        {
            string pasta = Path.Combine(PastaRaizFisica(contexto), "temp");
            if (!Directory.Exists(pasta)) return;

            DateTime limite = DateTime.Now.AddDays(-2);
            foreach (string arquivo in Directory.GetFiles(pasta, "*.jpg", SearchOption.AllDirectories))
            {
                try
                {
                    FileInfo info = new FileInfo(arquivo);
                    if (info.LastWriteTime < limite) info.Delete();
                }
                catch
                {
                }
            }
        }
        catch
        {
        }
    }

    private static string ApenasSeguro(string valor, string fallback)
    {
        if (String.IsNullOrWhiteSpace(valor)) return fallback;
        StringBuilder sb = new StringBuilder();
        foreach (char c in valor)
        {
            if (Char.IsLetterOrDigit(c) || c == '-' || c == '_') sb.Append(c);
        }
        return sb.Length == 0 ? fallback : sb.ToString();
    }

    private static DataTable ExecutarTabela(string sql, params SqlParameter[] parametros)
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            using (SqlCommand cmd = new SqlCommand(sql, banco.oCon2))
            {
                cmd.CommandTimeout = 60;
                foreach (SqlParameter parametro in parametros) cmd.Parameters.Add(parametro);
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd)) adapter.Fill(tabela);
            }
        }
        finally
        {
            banco.FecharConexao2();
        }
        return tabela;
    }

    private static void ExecutarSemRetorno(string sql, params SqlParameter[] parametros)
    {
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            using (SqlCommand cmd = new SqlCommand(sql, banco.oCon2))
            {
                cmd.CommandTimeout = 60;
                foreach (SqlParameter parametro in parametros) cmd.Parameters.Add(parametro);
                cmd.ExecuteNonQuery();
            }
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private static SqlParameter Param(string nome, SqlDbType tipo, object valor)
    {
        SqlParameter parametro = new SqlParameter(nome, tipo);
        if (tipo == SqlDbType.VarChar) parametro.Size = 500;
        parametro.Value = valor ?? DBNull.Value;
        return parametro;
    }
}
