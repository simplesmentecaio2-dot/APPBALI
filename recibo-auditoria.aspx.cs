using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

public partial class ReciboAuditoria : System.Web.UI.Page
{
    private const int MaxLinhasLog = 10000;

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentEncoding = Encoding.UTF8;

        if (Session["usuario"] == null || String.IsNullOrWhiteSpace(Session["usuario"].ToString()))
        {
            Response.Redirect("/login.aspx?voltar=/recibo-auditoria.aspx");
            return;
        }

        lblUsuario.Text = Session["usuario"].ToString();
        lblCodigo.Text = Session["usuario_codigo"] == null ? "-" : Session["usuario_codigo"].ToString();

        if (!IsPostBack)
        {
            txtDataInicial.Text = DateTime.Today.AddDays(-7).ToString("yyyy-MM-dd");
            txtDataFinal.Text = DateTime.Today.ToString("yyyy-MM-dd");
            Carregar();
        }
    }

    protected void btnFiltrar_Click(object sender, EventArgs e)
    {
        gvLogs.PageIndex = 0;
        Carregar();
    }

    protected void btnLimpar_Click(object sender, EventArgs e)
    {
        txtDataInicial.Text = DateTime.Today.AddDays(-7).ToString("yyyy-MM-dd");
        txtDataFinal.Text = DateTime.Today.ToString("yyyy-MM-dd");
        ddlMarca.SelectedValue = "";
        ddlAcao.SelectedValue = "";
        txtPedido.Text = "";
        txtLoja.Text = "";
        txtUsuario.Text = "";
        txtBusca.Text = "";
        gvLogs.PageIndex = 0;
        Carregar();
    }

    protected void btnExportar_Click(object sender, EventArgs e)
    {
        List<ReciboLogItem> itens = Filtrar(LerLogs());
        StringBuilder csv = new StringBuilder();
        csv.AppendLine("Data;Acao;Marca;Tipo;Pedido;Loja;Usuario;CodigoUsuario;Cliente;Veiculo;Pagina;IP;Mensagem");

        foreach (ReciboLogItem item in itens)
        {
            csv.AppendLine(String.Join(";", new string[]
            {
                Csv(item.Data),
                Csv(item.Acao),
                Csv(item.Marca),
                Csv(item.Tipo),
                Csv(item.Pedido),
                Csv(item.Loja),
                Csv(item.Usuario),
                Csv(item.CodigoUsuario),
                Csv(item.Cliente),
                Csv(item.Veiculo),
                Csv(item.Pagina),
                Csv(item.Ip),
                Csv(item.Mensagem)
            }));
        }

        Response.Clear();
        Response.ContentEncoding = Encoding.UTF8;
        Response.ContentType = "text/csv";
        Response.AddHeader("Content-Disposition", "attachment; filename=auditoria-recibos.csv");
        Response.BinaryWrite(Encoding.UTF8.GetPreamble());
        Response.Write(csv.ToString());
        Response.End();
    }

    protected void btnHoje_Click(object sender, EventArgs e)
    {
        DefinirPeriodo(DateTime.Today, DateTime.Today);
    }

    protected void btnSeteDias_Click(object sender, EventArgs e)
    {
        DefinirPeriodo(DateTime.Today.AddDays(-6), DateTime.Today);
    }

    protected void btnMesAtual_Click(object sender, EventArgs e)
    {
        DefinirPeriodo(new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1), DateTime.Today);
    }

    protected void gvLogs_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvLogs.PageIndex = e.NewPageIndex;
        Carregar();
    }

    protected void gvLogs_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;

        ReciboLogItem item = e.Row.DataItem as ReciboLogItem;
        if (item == null) return;

        if (Igual(item.Acao, "erro")) e.Row.CssClass = "is-error-row";
        else if (Igual(item.Acao, "impressao")) e.Row.CssClass = "is-print-row";
        else if (Igual(item.Acao, "gerado")) e.Row.CssClass = "is-generated-row";
    }

    private void Carregar()
    {
        List<ReciboLogItem> itens = Filtrar(LerLogs());
        gvLogs.DataSource = itens;
        gvLogs.DataBind();

        pnlMensagem.Visible = itens.Count == 0;
        litTotal.Text = itens.Count.ToString();
        litGerados.Text = itens.Count(i => Igual(i.Acao, "gerado")).ToString();
        litImpressoes.Text = itens.Count(i => Igual(i.Acao, "impressao")).ToString();
        litErros.Text = itens.Count(i => Igual(i.Acao, "erro")).ToString();
        litUsuarios.Text = itens.Select(i => i.Usuario).Where(i => !String.IsNullOrWhiteSpace(i)).Distinct(StringComparer.OrdinalIgnoreCase).Count().ToString();
        litFiat.Text = itens.Count(i => Igual(i.Marca, "Fiat")).ToString();
        litJeep.Text = itens.Count(i => Igual(i.Marca, "Jeep")).ToString();
        litByd.Text = itens.Count(i => Igual(i.Marca, "BYD")).ToString();
    }

    private List<ReciboLogItem> LerLogs()
    {
        string caminho = Server.MapPath("~/App_Data/recibo-geracoes.log");
        List<ReciboLogItem> itens = new List<ReciboLogItem>();

        if (!File.Exists(caminho)) return itens;

        string[] linhas = File.ReadAllLines(caminho, Encoding.UTF8);
        IEnumerable<string> linhasRecentes = linhas.Length > MaxLinhasLog ? linhas.Skip(linhas.Length - MaxLinhasLog) : linhas;

        foreach (string linha in linhasRecentes)
        {
            if (String.IsNullOrWhiteSpace(linha)) continue;
            string[] partes = linha.Split('\t');
            if (partes.Length < 12) continue;

            ReciboLogItem item = new ReciboLogItem();
            item.Data = partes[0];
            item.Acao = partes[1];
            item.Marca = partes[2];
            item.Tipo = partes[3];
            item.Pedido = partes[4];
            item.Loja = partes[5];
            item.Usuario = partes[6];
            item.CodigoUsuario = partes[7];
            item.Cliente = partes[8];
            item.Veiculo = partes[9];
            item.Pagina = partes[10];
            item.Ip = partes[11];
            item.Mensagem = partes.Length > 12 ? partes[12] : "";
            itens.Add(item);
        }

        return itens.OrderByDescending(i => ParseData(i.Data)).ToList();
    }

    private void DefinirPeriodo(DateTime inicio, DateTime fim)
    {
        txtDataInicial.Text = inicio.ToString("yyyy-MM-dd");
        txtDataFinal.Text = fim.ToString("yyyy-MM-dd");
        gvLogs.PageIndex = 0;
        Carregar();
    }

    private List<ReciboLogItem> Filtrar(List<ReciboLogItem> itens)
    {
        DateTime dataInicial;
        DateTime dataFinal;
        bool temDataInicial = DateTime.TryParseExact(txtDataInicial.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dataInicial);
        bool temDataFinal = DateTime.TryParseExact(txtDataFinal.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dataFinal);
        if (temDataFinal) dataFinal = dataFinal.Date.AddDays(1).AddTicks(-1);

        string marca = ddlMarca.SelectedValue;
        string acao = ddlAcao.SelectedValue;
        string pedido = txtPedido.Text.Trim();
        string loja = txtLoja.Text.Trim();
        string usuario = txtUsuario.Text.Trim();
        string busca = txtBusca.Text.Trim();

        return itens.Where(delegate(ReciboLogItem item)
        {
            DateTime data = ParseData(item.Data);
            if (temDataInicial && data < dataInicial.Date) return false;
            if (temDataFinal && data > dataFinal) return false;
            if (!String.IsNullOrWhiteSpace(marca) && !Igual(item.Marca, marca)) return false;
            if (!String.IsNullOrWhiteSpace(acao) && !Igual(item.Acao, acao)) return false;
            if (!Contem(item.Pedido, pedido)) return false;
            if (!Contem(item.Loja, loja)) return false;
            if (!Contem(item.Usuario, usuario)) return false;
            if (!BuscaGeral(item, busca)) return false;
            return true;
        }).ToList();
    }

    private static DateTime ParseData(string valor)
    {
        DateTime data;
        if (DateTime.TryParseExact(valor, "yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture, DateTimeStyles.None, out data)) return data;
        if (DateTime.TryParse(valor, out data)) return data;
        return DateTime.MinValue;
    }

    private static bool Igual(string a, string b)
    {
        return String.Equals(a ?? "", b ?? "", StringComparison.OrdinalIgnoreCase);
    }

    private static bool Contem(string valor, string busca)
    {
        if (String.IsNullOrWhiteSpace(busca)) return true;
        return (valor ?? "").IndexOf(busca, StringComparison.OrdinalIgnoreCase) >= 0;
    }

    private static bool BuscaGeral(ReciboLogItem item, string busca)
    {
        if (String.IsNullOrWhiteSpace(busca)) return true;

        string texto = String.Join(" ", new string[]
        {
            item.Data,
            item.Acao,
            item.Marca,
            item.Tipo,
            item.Pedido,
            item.Loja,
            item.Usuario,
            item.CodigoUsuario,
            item.Cliente,
            item.Veiculo,
            item.Pagina,
            item.Ip,
            item.Mensagem
        });

        return texto.IndexOf(busca, StringComparison.OrdinalIgnoreCase) >= 0;
    }

    private static string Csv(string valor)
    {
        valor = valor ?? "";
        valor = valor.Replace("\"", "\"\"");
        return "\"" + valor + "\"";
    }

    public class ReciboLogItem
    {
        public string Data { get; set; }
        public string Acao { get; set; }
        public string Marca { get; set; }
        public string Tipo { get; set; }
        public string Pedido { get; set; }
        public string Loja { get; set; }
        public string Usuario { get; set; }
        public string CodigoUsuario { get; set; }
        public string Cliente { get; set; }
        public string Veiculo { get; set; }
        public string Pagina { get; set; }
        public string Ip { get; set; }
        public string Mensagem { get; set; }
    }
}
