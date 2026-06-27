<%@ WebHandler Language="C#" Class="ReciboModelosHandler" %>

using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

public class ReciboModelosHandler : IHttpHandler
{
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
                LerModelos(context);
                return;
            }

            if (context.Request.HttpMethod.Equals("POST", StringComparison.OrdinalIgnoreCase))
            {
                GravarModelos(context);
                return;
            }

            context.Response.StatusCode = 405;
            EscreverJson(context, new { ok = false, message = "Metodo nao permitido." });
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            EscreverJson(context, new { ok = false, message = "Erro ao processar modelos.", detail = ex.Message });
        }
    }

    private void LerModelos(HttpContext context)
    {
        string arquivo = CaminhoArquivo(context);
        if (!File.Exists(arquivo))
        {
            EscreverJson(context, new { ok = true, exists = false, templates = ModelosPadrao() });
            return;
        }

        context.Response.Write(File.ReadAllText(arquivo, Encoding.UTF8));
    }

    private void GravarModelos(HttpContext context)
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = int.MaxValue;

        string body;
        using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
        {
            body = reader.ReadToEnd();
        }

        PedidoModelos pedido = serializer.Deserialize<PedidoModelos>(body);
        List<Modelo> modelos = LimparModelos(pedido == null ? null : pedido.templates);
        if (modelos.Count == 0)
        {
            modelos = ModelosPadrao();
        }

        string json = serializer.Serialize(new { ok = true, exists = true, templates = modelos, updatedAt = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") });
        File.WriteAllText(CaminhoArquivo(context), json, Encoding.UTF8);
        EscreverJson(context, new { ok = true, count = modelos.Count });
    }

    private List<Modelo> LimparModelos(List<Modelo> modelos)
    {
        List<Modelo> limpos = new List<Modelo>();
        if (modelos == null) return limpos;

        for (int i = 0; i < modelos.Count; i++)
        {
            Modelo modelo = modelos[i];
            if (modelo == null) continue;

            string nome = Limpar(modelo.name);
            string conteudo = Limpar(modelo.content);
            if (nome.Length == 0 || conteudo.Length == 0) continue;

            limpos.Add(new Modelo
            {
                id = Slug(Limpar(modelo.id).Length == 0 ? nome : modelo.id),
                name = nome.Length > 80 ? nome.Substring(0, 80) : nome,
                content = conteudo.Length > 4000 ? conteudo.Substring(0, 4000) : conteudo
            });
        }

        return limpos;
    }

    private List<Modelo> ModelosPadrao()
    {
        return new List<Modelo>
        {
            new Modelo
            {
                id = "premiacao-vendas",
                name = "Premia\u00e7\u00e3o de vendas",
                content = "Recebi da {empresa}, a quantia de {valor} ({valor_extenso}), referente \u00e0 PREMIA\u00c7\u00c3O DE VENDAS do m\u00eas de {mes}."
            },
            new Modelo
            {
                id = "supervisao-vendas",
                name = "Supervis\u00e3o de vendas",
                content = "Recebi da {empresa}, a quantia de {valor} ({valor_extenso}), referente \u00e0 SUPERVIS\u00c3O DE VENDAS do m\u00eas de {mes}."
            },
            new Modelo
            {
                id = "ajuda-custo",
                name = "Ajuda de custo",
                content = "Recebi da {empresa}, a quantia de {valor} ({valor_extenso}), referente \u00e0 ajuda de custo do m\u00eas de {mes}."
            }
        };
    }

    private string CaminhoArquivo(HttpContext context)
    {
        return context.Server.MapPath("~/admfinanceiro/Recibo/recibo-modelos.json");
    }

    private string Limpar(string valor)
    {
        return (valor ?? String.Empty).Trim();
    }

    private string Slug(string valor)
    {
        valor = (valor ?? String.Empty).Trim().ToLowerInvariant();
        StringBuilder slug = new StringBuilder();
        for (int i = 0; i < valor.Length; i++)
        {
            char c = valor[i];
            if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9'))
            {
                slug.Append(c);
            }
            else if (c == '-' || c == '_' || Char.IsWhiteSpace(c))
            {
                slug.Append('-');
            }
        }

        string texto = slug.ToString().Trim('-');
        return texto.Length == 0 ? "modelo-" + DateTime.Now.Ticks.ToString() : texto;
    }

    private void EscreverJson(HttpContext context, object resposta)
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = int.MaxValue;
        context.Response.Write(serializer.Serialize(resposta));
    }

    public class PedidoModelos
    {
        public List<Modelo> templates { get; set; }
    }

    public class Modelo
    {
        public string id { get; set; }
        public string name { get; set; }
        public string content { get; set; }
    }
}
