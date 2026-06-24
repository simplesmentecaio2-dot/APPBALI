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

        string json = File.ReadAllText(arquivo, Encoding.UTF8);
        context.Response.Write(json);
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

        string pasta = context.Server.MapPath("~/intranet/resources/data");
        if (!Directory.Exists(pasta))
        {
            Directory.CreateDirectory(pasta);
        }

        string arquivo = CaminhoArquivo(context);
        string json = serializer.Serialize(new { ok = true, exists = true, shortcuts = atalhosLimpos, updatedAt = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") });
        File.WriteAllText(arquivo, json, Encoding.UTF8);

        EscreverJson(context, new { ok = true, count = atalhosLimpos.Count });
    }

    private string CaminhoArquivo(HttpContext context)
    {
        return context.Server.MapPath("~/intranet/resources/data/shortcuts.json");
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
}
