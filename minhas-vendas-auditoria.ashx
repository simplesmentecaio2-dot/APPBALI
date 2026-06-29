<%@ WebHandler Language="C#" Class="MinhasVendasAuditoria" %>

using System;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.SessionState;

public class MinhasVendasAuditoria : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";

        string acao = (context.Request.Form["acao"] ?? "").Trim().ToLowerInvariant();
        if (acao != "impressao-pdf")
        {
            context.Response.StatusCode = 400;
            context.Response.Write("{\"ok\":false}");
            return;
        }

        try
        {
            string caminho = context.Server.MapPath("~/App_Data/minhas-vendas-auditoria.log");
            string linha = String.Format(
                CultureInfo.InvariantCulture,
                "{0:yyyy-MM-dd HH:mm:ss} | acao={1} | usuario={2} | codigo={3} | marca={4} | url={5} | ip={6}{7}",
                DateTime.Now,
                acao,
                Convert.ToString(context.Session["usuario"]),
                Convert.ToString(context.Session["usuario_codigo"]),
                Limitar(context.Request.Form["marca"], 40),
                Limitar(context.Request.Form["url"], 300),
                ObterIpCliente(context),
                Environment.NewLine);
            System.IO.File.AppendAllText(caminho, linha, Encoding.UTF8);
        }
        catch
        {
        }

        context.Response.Write("{\"ok\":true}");
    }

    public bool IsReusable
    {
        get { return false; }
    }

    private static string Limitar(string valor, int tamanho)
    {
        valor = (valor ?? "").Trim();
        return valor.Length <= tamanho ? valor : valor.Substring(0, tamanho);
    }

    private static string ObterIpCliente(HttpContext context)
    {
        string encaminhado = Convert.ToString(context.Request.ServerVariables["HTTP_X_FORWARDED_FOR"]);
        if (!String.IsNullOrWhiteSpace(encaminhado))
        {
            string[] partes = encaminhado.Split(',');
            if (partes.Length > 0)
            {
                return partes[0].Trim();
            }
        }

        return Convert.ToString(context.Request.ServerVariables["REMOTE_ADDR"]);
    }
}
