using System;
using System.IO;
using System.Text;
using System.Web.UI;

public static class ContratoImpressao
{
    public static bool TryObterContrato(Page pagina, out string contrato)
    {
        contrato = "";
        string valor = Convert.ToString(pagina.Request.QueryString["contrato"]);
        if (String.IsNullOrEmpty(valor)) return false;

        int numeroContrato;
        if (!Int32.TryParse(valor.Trim(), out numeroContrato) || numeroContrato <= 0) return false;

        contrato = numeroContrato.ToString();
        return true;
    }

    public static void RegistrarErro(Page pagina, string marca, string tipo, string contrato, Exception ex)
    {
        try
        {
            string pasta = pagina.Server.MapPath("~/App_Data");
            if (!Directory.Exists(pasta)) Directory.CreateDirectory(pasta);

            string linha = DateTime.Now.ToString("s")
                + "\tERRO_IMPRESSAO_CONTRATO"
                + "\tMarca=" + LimparLog(marca)
                + "\tTipo=" + LimparLog(tipo)
                + "\tContrato=" + LimparLog(contrato)
                + "\tUsuario=" + LimparLog(Convert.ToString(pagina.Session["usuario"]))
                + "\tErro=" + LimparLog(ex.Message);

            File.AppendAllText(Path.Combine(pasta, "contrato-operacoes.log"), linha + Environment.NewLine, Encoding.UTF8);
        }
        catch
        {
        }
    }

    public static void ExibirContratoNaoLocalizado(Page pagina, string retornoRelativo)
    {
        string retorno = pagina.ResolveUrl(retornoRelativo);
        pagina.Response.Clear();
        pagina.Response.StatusCode = 404;
        pagina.Response.TrySkipIisCustomErrors = true;
        pagina.Response.Write("<!DOCTYPE html><html lang=\"pt-BR\"><head><meta charset=\"utf-8\" /><title>Contrato n&atilde;o localizado</title><style>body{margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;background:#eef2f7;font-family:Arial,sans-serif;color:#0f172a}.card{width:min(520px,calc(100vw - 32px));background:#fff;border:1px solid #dbe3ef;border-radius:14px;box-shadow:0 18px 45px rgba(15,23,42,.14);padding:28px;text-align:center}.tag{display:inline-flex;padding:6px 10px;border-radius:999px;background:#fee2e2;color:#991b1b;font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.04em}h1{margin:14px 0 8px;font-size:24px}p{margin:0 0 20px;color:#475569;line-height:1.45}.acoes{display:flex;gap:10px;justify-content:center;flex-wrap:wrap}.btn{border:0;border-radius:9px;padding:11px 16px;background:#0f172a;color:#fff;font-weight:700;text-decoration:none;cursor:pointer}.btn.sec{background:#e2e8f0;color:#0f172a}</style></head><body><main class=\"card\"><span class=\"tag\">Impress&atilde;o de contrato</span><h1>Contrato n&atilde;o localizado</h1><p>Verifique o c&oacute;digo do contrato e tente novamente. Caso o problema continue, acione a TI.</p><div class=\"acoes\"><a class=\"btn\" href=\"" + retorno + "\">Voltar para contratos</a><button class=\"btn sec\" onclick=\"if(history.length>1){history.back();return false;}location.href='" + retorno + "';\">Voltar</button></div></main></body></html>");
        pagina.Response.End();
    }

    private static string LimparLog(string valor)
    {
        return (valor ?? "").Replace("\r", " ").Replace("\n", " ").Replace("\t", " ").Trim();
    }
}
