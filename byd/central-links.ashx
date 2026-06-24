<%@ WebHandler Language="C#" Class="BydCentralLinksHandler" %>

using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

public class BydCentralLinksHandler : IHttpHandler
{
    private const string SenhaManutencao = "@bali2025";

    public bool IsReusable
    {
        get { return false; }
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.ContentEncoding = Encoding.UTF8;

        try
        {
            if (context.Request.HttpMethod.Equals("GET", StringComparison.OrdinalIgnoreCase))
            {
                LerAtalhos(context);
                return;
            }

            if (context.Request.HttpMethod.Equals("POST", StringComparison.OrdinalIgnoreCase))
            {
                GravarAtalhos(context);
                return;
            }

            context.Response.StatusCode = 405;
            EscreverJson(context, new { ok = false, message = "Metodo nao permitido." });
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            EscreverJson(context, new { ok = false, message = "Erro ao processar manutencao.", detail = ex.Message });
        }
    }

    private void LerAtalhos(HttpContext context)
    {
        string arquivo = CaminhoArquivo(context);
        if (!File.Exists(arquivo))
        {
            EscreverJson(context, new { ok = true, exists = false, shortcuts = new List<Atalho>() });
            return;
        }

        context.Response.Write(File.ReadAllText(arquivo, Encoding.UTF8));
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
            EscreverJson(context, new { ok = false, message = "Senha invalida." });
            return;
        }

        List<Atalho> atalhos = LimparAtalhos(pedido.shortcuts);
        string json = serializer.Serialize(new { ok = true, exists = true, shortcuts = atalhos, updatedAt = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") });
        File.WriteAllText(CaminhoArquivo(context), json, Encoding.UTF8);
        EscreverJson(context, new { ok = true, count = atalhos.Count });
    }

    private List<Atalho> LimparAtalhos(List<Atalho> atalhos)
    {
        List<Atalho> limpos = new List<Atalho>();
        if (atalhos == null) return limpos;

        for (int i = 0; i < atalhos.Count; i++)
        {
            Atalho item = atalhos[i];
            if (item == null) continue;

            string titulo = Limpar(item.title);
            string url = Limpar(item.url);
            if (titulo.Length == 0 || url.Length == 0) continue;

            limpos.Add(new Atalho
            {
                id = Limpar(item.id).Length == 0 ? "atalho-" + i.ToString() : Limpar(item.id),
                title = titulo,
                caption = Limpar(item.caption).Length == 0 ? "Atalho" : Limpar(item.caption),
                url = url,
                icon = IconeValido(Limpar(item.icon)) ? Limpar(item.icon) : ""
            });
        }

        return limpos;
    }

    private string CaminhoArquivo(HttpContext context)
    {
        return context.Server.MapPath("~/byd/central-links.json");
    }

    private bool IconeValido(string icone)
    {
        if (icone.Length == 0) return true;
        for (int i = 0; i < icone.Length; i++)
        {
            char c = icone[i];
            bool valido = (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-';
            if (!valido) return false;
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

    public class Atalho
    {
        public string id { get; set; }
        public string title { get; set; }
        public string caption { get; set; }
        public string url { get; set; }
        public string icon { get; set; }
    }
}
