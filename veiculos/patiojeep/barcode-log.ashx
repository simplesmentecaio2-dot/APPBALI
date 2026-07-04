<%@ WebHandler Language="C#" Class="PatioBarcodeLog" %>

using System;
using System.IO;
using System.Text;
using System.Web;
using System.Web.SessionState;

public class PatioBarcodeLog : IHttpHandler, IReadOnlySessionState
{
    private static readonly object ArquivoLock = new object();

    public bool IsReusable
    {
        get { return false; }
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";

        if (!String.Equals(context.Request.HttpMethod, "POST", StringComparison.OrdinalIgnoreCase))
        {
            context.Response.StatusCode = 405;
            context.Response.Write("{\"ok\":false}");
            return;
        }

        if (context.Session == null || context.Session["id"] == null)
        {
            context.Response.StatusCode = 401;
            context.Response.Write("{\"ok\":false}");
            return;
        }

        try
        {
            string pasta = context.Server.MapPath("~/App_Data");
            Directory.CreateDirectory(pasta);

            string detalhes = String.Join("; ", new string[]
            {
                "origem=" + Limpar(context.Request.Form["origem"], 40),
                "motor=" + Limpar(context.Request.Form["motor"], 40),
                "camera=" + Limpar(context.Request.Form["camera"], 140),
                "tempoMs=" + Limpar(context.Request.Form["tempoMs"], 20),
                "detalhe=" + Limpar(context.Request.Form["detalhe"], 260)
            });

            string linha = String.Join("\t", new string[]
            {
                DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
                Limpar(context.Request.Form["evento"], 80),
                Limpar(context.Session["usuario"], 80),
                Limpar(context.Request.Form["serie"], 40),
                detalhes,
                Limpar(context.Request.UserHostAddress, 60),
                Limpar(context.Request.UserAgent, 180),
                Limpar(context.Request.Form["url"], 180)
            });

            lock (ArquivoLock)
            {
                File.AppendAllText(Path.Combine(pasta, "patio-barcode-leituras.log"), linha + Environment.NewLine, Encoding.UTF8);
            }

            context.Response.Write("{\"ok\":true}");
        }
        catch
        {
            context.Response.StatusCode = 500;
            context.Response.Write("{\"ok\":false}");
        }
    }

    private static string Limpar(object valor, int tamanhoMaximo)
    {
        string texto = Convert.ToString(valor);
        if (String.IsNullOrWhiteSpace(texto))
        {
            return "-";
        }

        texto = texto.Replace("\r", " ").Replace("\n", " ").Replace("\t", " ").Trim();
        if (texto.Length > tamanhoMaximo)
        {
            texto = texto.Substring(0, tamanhoMaximo);
        }

        return texto;
    }
}
