<%@ WebHandler Language="C#" Class="PatioPhotoTempUpload" %>

using System;
using System.Web;
using System.Web.SessionState;

public class PatioPhotoTempUpload : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;

        if (context.Session == null || context.Session["id"] == null)
        {
            context.Response.StatusCode = 401;
            Escrever(context, false, "", 0, "Sessao expirada.");
            return;
        }

        if (!String.Equals(context.Request.HttpMethod, "POST", StringComparison.OrdinalIgnoreCase))
        {
            context.Response.StatusCode = 405;
            Escrever(context, false, "", 0, "Metodo nao permitido.");
            return;
        }

        string foto = context.Request.Form["foto"];
        if (String.IsNullOrWhiteSpace(foto))
        {
            context.Response.StatusCode = 400;
            Escrever(context, false, "", 0, "Nenhuma foto recebida.");
            return;
        }

        string usuario = Convert.ToString(context.Session["usuario"]);
        PatioFotoResultado resultado = PatioFotoHelper.SalvarFotoTemporariaBase64(context, foto, usuario);
        if (!resultado.Sucesso)
        {
            context.Response.StatusCode = 400;
            Escrever(context, false, "", 0, resultado.Mensagem);
            return;
        }

        Escrever(context, true, resultado.Url, resultado.Bytes, "Foto pronta.");
    }

    public bool IsReusable
    {
        get { return false; }
    }

    private static void Escrever(HttpContext context, bool ok, string url, long bytes, string mensagem)
    {
        context.Response.Write("{\"ok\":" + (ok ? "true" : "false") +
            ",\"url\":\"" + Json(url) +
            "\",\"bytes\":" + bytes.ToString(System.Globalization.CultureInfo.InvariantCulture) +
            ",\"message\":\"" + Json(mensagem) + "\"}");
    }

    private static string Json(string valor)
    {
        return (valor ?? "")
            .Replace("\\", "\\\\")
            .Replace("\"", "\\\"")
            .Replace("\r", " ")
            .Replace("\n", " ");
    }
}
