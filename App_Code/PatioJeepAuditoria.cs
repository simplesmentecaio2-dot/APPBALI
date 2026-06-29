using System;
using System.IO;
using System.Text;
using System.Web;

public static class PatioJeepAuditoria
{
    private static readonly object ArquivoLock = new object();

    public static void Registrar(string acao, object usuario, object serie, string detalhes)
    {
        try
        {
            HttpContext contexto = HttpContext.Current;
            if (contexto == null)
            {
                return;
            }

            string pasta = contexto.Server.MapPath("~/App_Data");
            Directory.CreateDirectory(pasta);

            string linha = String.Join("\t", new string[]
            {
                DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
                Limpar(acao),
                Limpar(usuario),
                Limpar(serie),
                Limpar(detalhes),
                Limpar(contexto.Request.UserHostAddress),
                Limpar(contexto.Request.RawUrl)
            });

            lock (ArquivoLock)
            {
                File.AppendAllText(Path.Combine(pasta, "patio-jeep-auditoria.log"), linha + Environment.NewLine, Encoding.UTF8);
            }
        }
        catch
        {
        }
    }

    private static string Limpar(object valor)
    {
        string texto = Convert.ToString(valor);
        if (String.IsNullOrWhiteSpace(texto))
        {
            return "-";
        }

        return texto.Replace("\r", " ").Replace("\n", " ").Replace("\t", " ").Trim();
    }
}
