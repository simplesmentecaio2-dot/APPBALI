<%@ WebHandler Language="C#" Class="IntranetManutencaoLinks" %>

using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

public class IntranetManutencaoLinks : IHttpHandler
{
    private const string SenhaManutencao = "@bali2025";
    private const int TamanhoMaximoAviso = 8 * 1024 * 1024;
    private static readonly Encoding Utf8SemBom = new UTF8Encoding(false);

    public bool IsReusable
    {
        get { return false; }
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.ContentEncoding = Utf8SemBom;
        context.Response.TrySkipIisCustomErrors = true;
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        context.Response.Cache.SetNoStore();
        context.Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));

        try
        {
            if (context.Request.HttpMethod.Equals("GET", StringComparison.OrdinalIgnoreCase))
            {
                LerManutencao(context);
                return;
            }

            if (context.Request.HttpMethod.Equals("POST", StringComparison.OrdinalIgnoreCase))
            {
                string modo = Limpar(context.Request.Form["mode"]);
                if (modo.Equals("notice", StringComparison.OrdinalIgnoreCase))
                {
                    GravarAviso(context);
                    return;
                }

                GravarAtalhos(context);
                return;
            }

            context.Response.StatusCode = 405;
            EscreverJson(context, new { ok = false, message = "Método não permitido." });
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            EscreverJson(context, new { ok = false, message = "Erro ao processar manutenção.", detail = ex.Message });
        }
    }

    private void LerManutencao(HttpContext context)
    {
        bool existe;
        string atualizadoEm;
        List<Atalho> atalhos = CarregarAtalhos(context, out existe, out atualizadoEm);
        EscreverJson(context, new
        {
            ok = true,
            exists = existe,
            shortcuts = atalhos,
            updatedAt = atualizadoEm,
            notice = CarregarAviso(context)
        });
    }

    private void GravarAtalhos(HttpContext context)
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = int.MaxValue;

        string body;
        using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
        {
            body = reader.ReadToEnd();
        }

        PedidoGravacao pedido = serializer.Deserialize<PedidoGravacao>(body);

        if (pedido == null || !SenhaManutencao.Equals(pedido.password))
        {
            context.Response.StatusCode = 403;
            EscreverJson(context, new { ok = false, message = "Senha inválida." });
            return;
        }

        List<Atalho> atalhos = pedido.shortcuts ?? new List<Atalho>();
        List<Atalho> atalhosLimpos = new List<Atalho>();

        for (int i = 0; i < atalhos.Count; i++)
        {
            Atalho item = atalhos[i];
            if (item == null)
            {
                continue;
            }

            string titulo = Limpar(item.title);
            string secao = Limpar(item.section);

            if (titulo.Length == 0 || !SecaoValida(secao))
            {
                continue;
            }

            string icone = Limpar(item.icon);
            if (!IconeValido(icone))
            {
                icone = "bi-grid-1x2-fill";
            }

            atalhosLimpos.Add(new Atalho
            {
                id = Limpar(item.id).Length == 0 ? "atalho-" + i.ToString() : Limpar(item.id),
                section = secao,
                title = titulo,
                badge = Limpar(item.badge).Length == 0 ? "Atalho" : Limpar(item.badge),
                url = Limpar(item.url),
                image = Limpar(item.image),
                icon = icone
            });
        }

        GarantirPastaDados(context);

        AvisoConfig aviso = CarregarAviso(context);
        string arquivo = CaminhoArquivoAtalhos(context);
        string json = serializer.Serialize(new { ok = true, exists = true, shortcuts = atalhosLimpos, updatedAt = DataAtual(), notice = aviso });
        File.WriteAllText(arquivo, json, Utf8SemBom);

        EscreverJson(context, new { ok = true, count = atalhosLimpos.Count });
    }

    private void GravarAviso(HttpContext context)
    {
        string senha = context.Request.Form["password"];
        if (!SenhaManutencao.Equals(senha))
        {
            context.Response.StatusCode = 403;
            EscreverJson(context, new { ok = false, message = "Senha inválida." });
            return;
        }

        AvisoConfig aviso = CarregarAviso(context);
        aviso.autoOpen = ValorBooleano(context.Request.Form["autoOpen"]);

        HttpPostedFile arquivoEnviado = context.Request.Files["noticeImageFile"];
        if (arquivoEnviado != null && arquivoEnviado.ContentLength > 0)
        {
            if (arquivoEnviado.ContentLength > TamanhoMaximoAviso)
            {
                context.Response.StatusCode = 400;
                EscreverJson(context, new { ok = false, message = "Imagem muito grande. Use um arquivo de até 8 MB." });
                return;
            }

            string extensao = Path.GetExtension(arquivoEnviado.FileName).ToLowerInvariant();
            if (!ExtensaoPermitida(extensao))
            {
                context.Response.StatusCode = 400;
                EscreverJson(context, new { ok = false, message = "Formato de imagem não permitido." });
                return;
            }

            string pastaImagens = context.Server.MapPath("~/intranet/resources/imagens");
            if (!Directory.Exists(pastaImagens))
            {
                Directory.CreateDirectory(pastaImagens);
            }

            string nomeArquivo = "aviso-intranet" + extensao;
            string destino = Path.Combine(pastaImagens, nomeArquivo);
            arquivoEnviado.SaveAs(destino);
            aviso.image = "resources/imagens/" + nomeArquivo;
        }

        aviso.updatedAt = DataAtual();
        SalvarAviso(context, aviso);
        EscreverJson(context, new { ok = true, notice = aviso });
    }

    private List<Atalho> CarregarAtalhos(HttpContext context, out bool existe, out string atualizadoEm)
    {
        existe = false;
        atualizadoEm = String.Empty;
        string arquivo = CaminhoArquivoAtalhos(context);

        if (!File.Exists(arquivo))
        {
            return new List<Atalho>();
        }

        existe = true;
        string json = File.ReadAllText(arquivo, Encoding.UTF8);
        if (Limpar(json).Length == 0)
        {
            return new List<Atalho>();
        }

        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = int.MaxValue;

        try
        {
            EnvelopeAtalhos envelope = serializer.Deserialize<EnvelopeAtalhos>(json);
            if (envelope != null && envelope.shortcuts != null)
            {
                atualizadoEm = Limpar(envelope.updatedAt);
                return envelope.shortcuts;
            }
        }
        catch
        {
        }

        try
        {
            List<Atalho> lista = serializer.Deserialize<List<Atalho>>(json);
            if (lista != null)
            {
                return lista;
            }
        }
        catch
        {
        }

        return new List<Atalho>();
    }

    private AvisoConfig CarregarAviso(HttpContext context)
    {
        string arquivo = CaminhoArquivoAviso(context);
        AvisoConfig padrao = AvisoPadrao();

        if (!File.Exists(arquivo))
        {
            return padrao;
        }

        string json = File.ReadAllText(arquivo, Encoding.UTF8);
        if (Limpar(json).Length == 0)
        {
            return padrao;
        }

        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = int.MaxValue;

        try
        {
            AvisoConfig aviso = serializer.Deserialize<AvisoConfig>(json);
            if (aviso == null)
            {
                return padrao;
            }

            aviso.image = Limpar(aviso.image).Length == 0 ? padrao.image : Limpar(aviso.image);
            return aviso;
        }
        catch
        {
            return padrao;
        }
    }

    private void SalvarAviso(HttpContext context, AvisoConfig aviso)
    {
        GarantirPastaDados(context);

        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = int.MaxValue;
        string json = serializer.Serialize(aviso);
        File.WriteAllText(CaminhoArquivoAviso(context), json, Utf8SemBom);
    }

    private AvisoConfig AvisoPadrao()
    {
        return new AvisoConfig
        {
            image = "resources/imagens/AVISOIMPORTANTE2.jpg",
            autoOpen = false,
            updatedAt = String.Empty
        };
    }

    private void GarantirPastaDados(HttpContext context)
    {
        string pasta = context.Server.MapPath("~/intranet/resources/data");
        if (!Directory.Exists(pasta))
        {
            Directory.CreateDirectory(pasta);
        }
    }

    private string CaminhoArquivoAtalhos(HttpContext context)
    {
        return context.Server.MapPath("~/intranet/resources/data/shortcuts.json");
    }

    private string CaminhoArquivoAviso(HttpContext context)
    {
        return context.Server.MapPath("~/intranet/resources/data/notice.json");
    }

    private string DataAtual()
    {
        return DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
    }

    private bool ValorBooleano(string valor)
    {
        string limpo = Limpar(valor).ToLowerInvariant();
        return limpo == "true" || limpo == "1" || limpo == "on" || limpo == "sim";
    }

    private bool ExtensaoPermitida(string extensao)
    {
        return extensao == ".jpg" || extensao == ".jpeg" || extensao == ".png" || extensao == ".gif" || extensao == ".webp";
    }

    private bool SecaoValida(string secao)
    {
        return secao == "bali" || secao == "jeep" || secao == "byd" || secao == "bancos" || secao == "tecnologia";
    }

    private bool IconeValido(string icone)
    {
        if (icone.Length == 0 || !icone.StartsWith("bi-"))
        {
            return false;
        }

        for (int i = 0; i < icone.Length; i++)
        {
            char c = icone[i];
            bool valido = (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-';
            if (!valido)
            {
                return false;
            }
        }

        return true;
    }

    private string Limpar(string valor)
    {
        return (valor ?? String.Empty).Trim();
    }

    private void EscreverJson(HttpContext context, object resposta)
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = int.MaxValue;
        context.Response.Write(serializer.Serialize(resposta));
    }

    public class PedidoGravacao
    {
        public string password { get; set; }
        public List<Atalho> shortcuts { get; set; }
    }

    public class EnvelopeAtalhos
    {
        public bool ok { get; set; }
        public bool exists { get; set; }
        public List<Atalho> shortcuts { get; set; }
        public string updatedAt { get; set; }
        public AvisoConfig notice { get; set; }
    }

    public class Atalho
    {
        public string id { get; set; }
        public string section { get; set; }
        public string title { get; set; }
        public string badge { get; set; }
        public string url { get; set; }
        public string image { get; set; }
        public string icon { get; set; }
    }

    public class AvisoConfig
    {
        public string image { get; set; }
        public bool autoOpen { get; set; }
        public string updatedAt { get; set; }
    }
}
