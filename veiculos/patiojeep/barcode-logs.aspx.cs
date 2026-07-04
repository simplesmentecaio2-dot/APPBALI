using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;

public partial class veiculos_patio_barcode_logs : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] == null)
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        usuarioLogado.Text = Convert.ToString(Session["usuario"]);

        if (!IsPostBack)
        {
            CarregarLogs();
        }
    }

    protected void btnAtualizar_Click(object sender, EventArgs e)
    {
        CarregarLogs();
    }

    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Session.Abandon();
        Response.Redirect("./login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void CarregarLogs()
    {
        string caminho = Server.MapPath("~/App_Data/patio-barcode-leituras.log");
        List<LogLeitura> logs = LerLogs(caminho).OrderByDescending(l => l.DataOrdenacao).Take(300).ToList();

        RenderizarResumo(logs, File.Exists(caminho));
        RenderizarTabela(logs);
    }

    private List<LogLeitura> LerLogs(string caminho)
    {
        List<LogLeitura> logs = new List<LogLeitura>();
        if (!File.Exists(caminho))
        {
            return logs;
        }

        using (FileStream stream = new FileStream(caminho, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
        using (StreamReader reader = new StreamReader(stream, Encoding.UTF8, true))
        {
            string linha;
            while ((linha = reader.ReadLine()) != null)
            {
                LogLeitura log = ParseLinha(linha);
                if (log != null)
                {
                    logs.Add(log);
                }
            }
        }

        return logs;
    }

    private LogLeitura ParseLinha(string linha)
    {
        if (String.IsNullOrWhiteSpace(linha))
        {
            return null;
        }

        string[] partes = linha.Split('\t');
        if (partes.Length < 8)
        {
            return null;
        }

        DateTime data;
        DateTime.TryParse(partes[0], out data);

        return new LogLeitura
        {
            Data = partes[0],
            DataOrdenacao = data == DateTime.MinValue ? DateTime.Now.AddYears(-10) : data,
            Evento = partes[1],
            Usuario = partes[2],
            Serie = partes[3],
            Detalhes = partes[4],
            Ip = partes[5],
            Navegador = partes[6],
            Url = partes[7]
        };
    }

    private void RenderizarResumo(List<LogLeitura> logs, bool arquivoExiste)
    {
        int total = logs.Count;
        int sucesso = logs.Count(l => l.Evento.IndexOf("serie_aceita", StringComparison.OrdinalIgnoreCase) >= 0);
        int falhasCamera = logs.Count(l => l.Evento.IndexOf("camera_falhou", StringComparison.OrdinalIgnoreCase) >= 0 || l.Evento.IndexOf("camera_nativa_falhou", StringComparison.OrdinalIgnoreCase) >= 0);
        int manual = logs.Count(l => l.Detalhes.IndexOf("manual", StringComparison.OrdinalIgnoreCase) >= 0 || l.Evento.IndexOf("manual", StringComparison.OrdinalIgnoreCase) >= 0);

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"barcode-log-summary\">");
        html.Append(Card("Eventos", total.ToString()));
        html.Append(Card("Leituras aceitas", sucesso.ToString()));
        html.Append(Card("Falhas de c\u00e2mera", falhasCamera.ToString()));
        html.Append(Card("Uso manual", manual.ToString()));
        html.Append("</div>");

        if (!arquivoExiste)
        {
            html.Append("<div class=\"alert alert-info mt-3\">Ainda n\u00e3o h\u00e1 logs do leitor. Eles ser\u00e3o criados assim que algu\u00e9m usar a c\u00e2mera ou enviar diagn\u00f3stico.</div>");
        }

        litResumo.Text = html.ToString();
    }

    private string Card(string titulo, string valor)
    {
        return "<div class=\"barcode-log-card\"><small>" + Html(titulo) + "</small><strong>" + Html(valor) + "</strong></div>";
    }

    private void RenderizarTabela(List<LogLeitura> logs)
    {
        if (logs.Count == 0)
        {
            litTabela.Text = "<div class=\"alert alert-light mb-0\">Nenhuma leitura registrada at\u00e9 agora.</div>";
            return;
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table id=\"barcodeLogTable\" class=\"table table-striped table-hover barcode-log-table\">");
        html.Append("<thead><tr><th>Data</th><th>Evento</th><th>Usu\u00e1rio</th><th>S\u00e9rie</th><th>Detalhes</th><th>IP</th><th>Navegador</th></tr></thead><tbody>");

        foreach (LogLeitura log in logs)
        {
            string eventoClass = log.Evento.IndexOf("falhou", StringComparison.OrdinalIgnoreCase) >= 0 || log.Evento.IndexOf("invalida", StringComparison.OrdinalIgnoreCase) >= 0 ? " is-error" :
                log.Evento.IndexOf("aceita", StringComparison.OrdinalIgnoreCase) >= 0 ? " is-success" : "";

            html.Append("<tr>");
            html.Append("<td>" + Html(log.Data) + "</td>");
            html.Append("<td><span class=\"barcode-log-event" + eventoClass + "\">" + Html(log.Evento) + "</span></td>");
            html.Append("<td>" + Html(log.Usuario) + "</td>");
            html.Append("<td>" + Html(log.Serie) + "</td>");
            html.Append("<td>" + Html(log.Detalhes) + "</td>");
            html.Append("<td>" + Html(log.Ip) + "</td>");
            html.Append("<td title=\"" + Html(log.Navegador) + "\">" + Html(Resumir(log.Navegador, 90)) + "</td>");
            html.Append("</tr>");
        }

        html.Append("</tbody></table>");
        litTabela.Text = html.ToString();
    }

    private string Html(object valor)
    {
        return HttpUtility.HtmlEncode(Convert.ToString(valor));
    }

    private string Resumir(string valor, int tamanho)
    {
        if (String.IsNullOrEmpty(valor) || valor.Length <= tamanho)
        {
            return valor;
        }

        return valor.Substring(0, tamanho) + "...";
    }

    private class LogLeitura
    {
        public string Data { get; set; }
        public DateTime DataOrdenacao { get; set; }
        public string Evento { get; set; }
        public string Usuario { get; set; }
        public string Serie { get; set; }
        public string Detalhes { get; set; }
        public string Ip { get; set; }
        public string Navegador { get; set; }
        public string Url { get; set; }
    }
}
