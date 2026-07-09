using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;

public static class EntregaVeiculoHelper
{
    public static string DataAtual()
    {
        return DateTime.Now.ToString("dd/MM/yyyy");
    }

    public static bool TryValidateConsulta(string pedido, string loja, out string pedidoLimpo, out string lojaLimpa, out string mensagem)
    {
        pedidoLimpo = SomenteNumeros(pedido, 12);
        lojaLimpa = SomenteNumeros(loja, 3);
        mensagem = "";

        if (String.IsNullOrWhiteSpace(pedidoLimpo))
        {
            mensagem = "Informe o número do pedido.";
            return false;
        }

        if (String.IsNullOrWhiteSpace(lojaLimpa))
        {
            mensagem = "Informe o código da loja.";
            return false;
        }

        long pedidoNumero;
        if (!long.TryParse(pedidoLimpo, out pedidoNumero) || pedidoNumero <= 0)
        {
            mensagem = "O pedido deve conter apenas números e ser maior que zero.";
            return false;
        }

        int lojaNumero;
        if (!int.TryParse(lojaLimpa, out lojaNumero) || lojaNumero <= 0)
        {
            mensagem = "O código da loja deve conter apenas números e ser maior que zero.";
            return false;
        }

        if (lojaLimpa.Length == 1)
        {
            lojaLimpa = "0" + lojaLimpa;
        }

        return true;
    }

    public static void Feedback(Page page, string key, string message, string type)
    {
        if (page == null) return;

        string safeMessage = HttpUtility.JavaScriptStringEncode(message ?? "");
        string safeType = HttpUtility.JavaScriptStringEncode(type ?? "info");
        string script = "if (window.baliUtilityFeedback) { window.baliUtilityFeedback('" + safeMessage + "', '" + safeType + "'); } else { alert('" + safeMessage + "'); }";
        ScriptManager.RegisterStartupScript(page, page.GetType(), key, script, true);
    }

    public static void RegistrarEventoServidor(HttpContext context, string acao, string marca, string pedido, string loja, string mensagem)
    {
        try
        {
            if (context == null) return;

            string pasta = context.Server.MapPath("~/App_Data");
            Directory.CreateDirectory(pasta);

            string usuario = context.Session != null && context.Session["usuario"] != null ? context.Session["usuario"].ToString() : "-";
            string codigo = context.Session != null && context.Session["usuario_codigo"] != null ? context.Session["usuario_codigo"].ToString() : "-";
            string ip = context.Request != null ? context.Request.UserHostAddress : "-";

            string linha = String.Join("\t", new string[]
            {
                DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
                LimparCampo(acao, 40),
                LimparCampo(marca, 30),
                LimparCampo(pedido, 12),
                LimparCampo(loja, 3),
                LimparCampo(usuario, 80),
                LimparCampo(codigo, 30),
                LimparCampo(ip, 45),
                LimparCampo(mensagem, 240)
            });

            File.AppendAllText(Path.Combine(pasta, "recibo-entrega-servidor.log"), linha + Environment.NewLine, Encoding.UTF8);
        }
        catch
        {
            // Log nunca deve interromper a geração do documento.
        }
    }

    public static string MarcaDaPagina(HttpRequest request)
    {
        string path = request == null ? "" : (request.AppRelativeCurrentExecutionFilePath ?? request.Path ?? "").ToLowerInvariant();
        if (path.IndexOf("byd") >= 0) return "BYD";
        if (path.IndexOf("jeep") >= 0) return "Jeep";
        return "Fiat";
    }

    private static string SomenteNumeros(string valor, int maximo)
    {
        valor = valor == null ? "" : valor.Trim();
        valor = Regex.Replace(valor, "[^0-9]", "");
        if (valor.Length > maximo) valor = valor.Substring(0, maximo);
        return valor;
    }

    private static string LimparCampo(string valor, int maximo)
    {
        valor = valor == null ? "" : valor.Trim();
        valor = Regex.Replace(valor, @"[\r\n\t]+", " ");
        if (valor.Length > maximo) valor = valor.Substring(0, maximo);
        return valor;
    }
}
