<%@ WebHandler Language="C#" Class="ReciboLogHandler" %>

using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.SessionState;

public class ReciboLogHandler : IHttpHandler, IRequiresSessionState
{
    public bool IsReusable
    {
        get { return false; }
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        if (context.Session == null || context.Session["usuario"] == null || String.IsNullOrWhiteSpace(context.Session["usuario"].ToString()))
        {
            context.Response.StatusCode = 401;
            context.Response.Write("{\"ok\":false}");
            return;
        }

        string acao = Limpar(context.Request["acao"], 24);
        string pedido = LimparNumero(context.Request["pedido"], 12);
        string loja = LimparNumero(context.Request["loja"], 3);

        if (String.IsNullOrWhiteSpace(acao) || String.IsNullOrWhiteSpace(pedido) || String.IsNullOrWhiteSpace(loja))
        {
            context.Response.StatusCode = 400;
            context.Response.Write("{\"ok\":false}");
            return;
        }

        string usuario = Limpar(context.Session["usuario"].ToString(), 80);
        string codigoUsuario = context.Session["usuario_codigo"] == null ? "-" : Limpar(context.Session["usuario_codigo"].ToString(), 30);
        string marca = Limpar(context.Request["marca"], 30);
        string tipo = Limpar(context.Request["tipo"], 60);
        string cliente = Limpar(context.Request["cliente"], 120);
        string veiculo = Limpar(context.Request["veiculo"], 120);
        string pagina = Limpar(context.Request["pagina"], 180);
        string ip = Limpar(context.Request.UserHostAddress, 45);

        string linha = String.Join("\t", new string[]
        {
            DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
            acao,
            marca,
            tipo,
            pedido,
            loja,
            usuario,
            codigoUsuario,
            cliente,
            veiculo,
            pagina,
            ip
        });

        string diretorio = context.Server.MapPath("~/App_Data");
        Directory.CreateDirectory(diretorio);
        File.AppendAllText(Path.Combine(diretorio, "recibo-geracoes.log"), linha + Environment.NewLine, Encoding.UTF8);

        context.Response.Write("{\"ok\":true}");
    }

    private static string LimparNumero(string valor, int maximo)
    {
        valor = valor == null ? "" : valor.Trim();
        valor = Regex.Replace(valor, "[^0-9]", "");
        if (valor.Length > maximo) valor = valor.Substring(0, maximo);
        return valor;
    }

    private static string Limpar(string valor, int maximo)
    {
        valor = valor == null ? "" : valor.Trim();
        valor = Regex.Replace(valor, @"[\r\n\t]+", " ");
        valor = Regex.Replace(valor, @"[^\p{L}\p{N}\p{P}\p{Zs}/@._-]+", "");
        if (valor.Length > maximo) valor = valor.Substring(0, maximo);
        return valor;
    }
}
