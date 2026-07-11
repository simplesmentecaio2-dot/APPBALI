using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows.Forms;
using System.Drawing;
using System.Data;
using QRCoder;
using System.IO;
using System.Data.SqlClient;

public partial class veiculos_contrato : System.Web.UI.Page
{
    private Veiculos vec = new Veiculos();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] != null && (Session["id"].Equals("CAIO") || Session["usuario"].Equals("CAIO") || Session["id"].Equals("caio@bali.com.br") || Session["usuario"].Equals("caio@bali.com.br") || Session["id"].Equals("PASSANTE") || Session["usuario"].Equals("PASSANTE") || Session["id"].Equals("passante") || Session["usuario"].Equals("passante")))
        {
            usuarioLogado.Text = Session["usuario"].ToString();
        }
        else
        {
            Response.Redirect("./restrito.aspx");
        }
        int qtdeFluxo = getQuantidadeFluxo(ddlEventoDashEvt.Value, ddlLojaDashEvt.Value);
        double percentualFluxo = getPercentualMeta(qtdeFluxo);

        txtTotalFluxo.Text = qtdeFluxo.ToString();
        txtPercentualEvt.Text = percentualFluxo + "%";
        txtPercentualEvtProgressBar.Text = "<div class=\"progress-bar bg-danger\" role=\"progressbar\" aria-valuenow=\"63\" aria-valuemin=\"0\" aria-valuemax=\"100\" style=\"width: " +
            percentualFluxo + "%;\"></div>";
        btnShowData(sender, e);
        //usuarioLogado.Text = Session["usuario"].ToString();
    }

    protected void btnAtualizaDashClick(object sender, EventArgs e)
    {
        int qtdeFluxo = getQuantidadeFluxo(ddlEventoDashEvt.Value, ddlLojaDashEvt.Value);
        txtTotalFluxo.Text = qtdeFluxo.ToString();
        txtTotalVendas.Text = getQuantidadeVenda(ddlEventoDashEvt.Value,ddlLojaDashEvt.Value)+"";
        literalFluxoVenda.Text = "" + ((Convert.ToInt32(txtTotalVendas.Text) * 100) / Convert.ToInt32(txtTotalFluxo.Text)) + "%";
        txtPercentualEvt.Text = getPercentualMeta(qtdeFluxo) + "%";


    }

    public int getQuantidadeFluxo(String evento, String loja)
    {
        string lojaSelecionada = (loja ?? "").Trim();

        String myQuery = "select COUNT(*) as qtde from APP.dbo.veiculos_prospeccao where Fluxo = 'S' and nome_evento = @evento and (@loja = '' or loja = @loja)";
        vec.Conexao();

        System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = myQuery;
        oCmd.CommandType = CommandType.Text;
        oCmd.Parameters.Add("@evento", SqlDbType.VarChar).Value = evento;
        oCmd.Parameters.Add("@loja", SqlDbType.VarChar).Value = lojaSelecionada;
        System.Data.SqlClient.SqlDataReader odr = oCmd.ExecuteReader();
        odr.Read();
        int qtde = (int)odr["qtde"];
        vec.FecharConexao();
        return qtde;
    }
    public int getQuantidadeVenda(String evento, String loja)
    {
        
        Veiculos veiculos = new Veiculos();
        veiculos.Conexao();
        SqlCommand oCmd1 = new SqlCommand();
        oCmd1.Connection = veiculos.oCon;
        oCmd1.CommandText = "APP..veiculos_prospeccao_select_venda";
        oCmd1.CommandType = CommandType.StoredProcedure;
        oCmd1.Parameters.Add("@loja", SqlDbType.VarChar).Value = loja;
        oCmd1.Parameters.Add("@evento", SqlDbType.VarChar).Value = evento;
        SqlDataReader odr1 = oCmd1.ExecuteReader();
        odr1.Read();
        int qtde = (int)odr1["qtde"];
        veiculos.FecharConexao();
        return qtde;
    }
    public int getQuantidadeVendaPorProspector(String evento, String loja, String vendedor, String equipe)
    {
        Veiculos veiculos = new Veiculos();
        int qtde = 0;
        try
        {

            string myQuery = @"select count(*) as qtde from app..veiculos_prospeccao p
                            inner join app..veiculos_prospeccao_venda v on p.id = v.cliente_id
                            where p.loja = @loja and p.nome_evento = @evento and p.vendedor = @vendedor and p.equipe = @equipe";

            veiculos.Conexao();

            System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
            oCmd.Connection = veiculos.oCon;
            oCmd.CommandText = myQuery;
            oCmd.CommandType = CommandType.Text;
            oCmd.Parameters.Add("@loja", SqlDbType.VarChar).Value = loja;
            oCmd.Parameters.Add("@evento", SqlDbType.VarChar).Value = evento;
            oCmd.Parameters.Add("@vendedor", SqlDbType.VarChar).Value = vendedor;
            oCmd.Parameters.Add("@equipe", SqlDbType.VarChar).Value = equipe;
            System.Data.SqlClient.SqlDataReader odr1 = oCmd.ExecuteReader();
            odr1.Read();
            qtde = (int)odr1["qtde"];


        }
        catch { }
        finally { veiculos.FecharConexao(); }
        return qtde;
    }
    public void getVendas(object sender, EventArgs e)
    {
        Veiculos veiculos = new Veiculos();
        try
        {


            veiculos.Conexao();

            System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
            oCmd.Connection = veiculos.oCon;
            oCmd.CommandText = "APP..prospeccao_select_vendas_por_equipe";
            oCmd.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEventoDashEvt.Value;
            oCmd.Parameters.Add("@loja", SqlDbType.VarChar).Value = ddlLojaDashEvt.Value;
            oCmd.CommandType = CommandType.StoredProcedure;
            System.Data.SqlClient.SqlDataReader odr1 = oCmd.ExecuteReader();
            odr1.Read();




            literalAmarela.Text = odr1["amarela"].ToString();
            literalAzul.Text = odr1["azul"].ToString();
            literalLaranja.Text = odr1["laranja"].ToString();
            literalVerde.Text = odr1["verde"].ToString();
            literalVermelha.Text = odr1["vermelha"].ToString();


        }
        catch { }
        finally { veiculos.FecharConexao(); }
    }
    public double getPercentualMeta(int qtdFluxo)
    {
        if (ddlLojaDashEvt.Value.Equals("SIA"))
        {
            return (qtdFluxo * 100) / 92;
        }
        else if (ddlLojaDashEvt.Value.Equals("SAAN"))
        {
            return (qtdFluxo * 100) / 36;
        }
        else
        {
            return (qtdFluxo * 100) / 32;
        }
        return 0;
    }

    protected void btnShowData(object sender, EventArgs e)
    {
        txtTopProspector.Text = "";
        string lojaSelecionada = (ddlLojaDashEvt.Value ?? "").Trim();

        string myQuery = "SELECT loja, equipe, count(*) as qtde FROM [APP].[dbo].[veiculos_prospeccao] " +
            " where nome_evento = @evento and (@loja = '' or loja = @loja) and Fluxo = 's'  group by loja,equipe order by qtde desc";

        vec.Conexao();

        System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = myQuery;
        oCmd.CommandType = CommandType.Text;
        oCmd.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEventoDashEvt.Value;
        oCmd.Parameters.Add("@loja", SqlDbType.VarChar).Value = lojaSelecionada;
        System.Data.SqlClient.SqlDataReader odr = oCmd.ExecuteReader();

        List<String> equipes = new List<String>();
        List<int> convites = new List<int>();
        List<String> lojas = new List<String>();
        String eqpRnk = "";
        String chart = "";
        String eqp = "";
        while (odr.Read())
        {
            lojas.Add(odr["loja"].ToString());
            equipes.Add(odr["equipe"].ToString());
            convites.Add(Convert.ToInt32(odr["qtde"]));
        }
        vec.FecharConexao();
        if (equipes.Count != 0)
        {
            
            chart += "new Chart(document.getElementById(\"bar\"), { type: 'bar', data: {labels: ['";

            // more detais
            for (int i = 0; i < equipes.Count; i++)
                eqp += Js(equipes[i] + " (" + convites[i] + ")") + "','";
            eqp = eqp.Substring(0, eqp.Length - 3);
            chart += eqp;
            chart += "'],datasets: [{ data: [";
            // get data from database and add to chart
            String value = "";
            for (int i = 0; i < convites.Count; i++)
            {
                value += convites[i].ToString() + ",";
            }
            value = value.Substring(0, value.Length - 1);
            chart += value;
            chart += "], backgroundColor: [";
            // get colors of bars
            String color = "";
            String border = "";
            for (int i = 0; i < equipes.Count; i++)
            {
                switch (equipes[i].ToString())
                {
                    case "BRANCA":
                        eqpRnk += "<div class=\"col-md-6\"><div class=\"card mb-3 ml-3 widget-content text-white\" style=\"background-color:rgba(128, 128, 128, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                        color += "'rgba(128, 128, 128, 0.9)',";
                        border += "'rgba(128, 128, 128, 0.9)',";
                        break;
                    case "AMARELA":
                        eqpRnk += "<div class=\"col-md-6\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(236, 244, 0, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                        color += "'rgba(236, 244, 0, 0.9)',";
                        border += "'rgba(236, 244, 0, 0.9)',";
                        break;
                    case "AMARELO":
                        eqpRnk += "<div class=\"col-md-6\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(236, 244, 0, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                        color += "'rgba(236, 244, 0, 0.9)',";
                        border += "'rgba(236, 244, 0, 0.9)',";
                        break;
                    case "VERDE":
                        eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(40,167,69, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                        color += "'rgba(40,167,69, 0.9)',";
                        border += "'rgba(40,167,69, 0.9)',";
                        break;
                    case "AZUL":
                        eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(0, 123, 255, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                        color += "'rgba(0, 123, 255, 0.9)',";
                        border += "'rgba(0, 123, 255, 0.9)',";
                        break;
                    case "APOIO":
                        eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(0, 0, 0, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                        color += "'rgba(0, 0, 0, 0.9)',";
                        border += "'rgba(0, 0, 0, 0.9)',";
                        break;
                    case "VERMELHA":
                        eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(255, 0, 0, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                        color += "'rgba(255, 0, 0, 0.9)',";
                        border += "'rgba(255, 0, 0, 0.9)',";
                        break;
                    case "VERMELHO":
                        eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(255, 0, 0, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                        color += "'rgba(255, 0, 0, 0.9)',";
                        border += "'rgba(255, 0, 0, 0.9)',";
                        break;
                    case "LARANJA":
                        eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(255, 165, 0, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                        color += "'rgba(255, 165, 0, 0.9)',";
                        border += "'rgba(255, 165, 0, 0.9)',";
                        break;
                    default:
                        eqpRnk += "<div class=\"col-md-6\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(63, 191, 191, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                        color += "'rgba(63, 191, 191, 0.9)',";
                        border += "'rgba(128, 128, 128, 0.9)',";
                        break;
                }
            }
            color = color.Substring(0, color.Length - 1);
            border = border.Substring(0, border.Length - 1);
            chart += color;
            chart += "],label: 'Convites',borderColor: [" + border + "], borderWidth: 1,fill: true}"; // Chart color
            chart += "]},options: { title: { display: false,text: 'Ranking'},animation: {duration: 0}, scales: { yAxes : [{ticks:{beginAtZero: true}}], xAxes: [{ ticks: { beginAtZero:true }" +
                "}],xAxes: [{ticks: {fontSize: 12}}]} }"; // Chart title
            chart += "});";
            txtTopProspector.Text = getTopProspectores();
            getVendas(sender, e);


        }
        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", chart + getTimeline(ddlLojaDashEvt.Value,ddlEventoDashEvt.Value), true);
    }

    private String getTopProspectores()
    {
        List<TopProspectores> topProspectores = new List<TopProspectores>();
        String retorno = "";
        string myQuery = "select vendedor, equipe, COUNT(*) as qtde from [APP].[dbo].veiculos_prospeccao where loja = @loja and nome_evento = @evento and fluxo = 's' group by vendedor,equipe order by qtde desc";

        vec.Conexao();

        System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = myQuery;
        oCmd.CommandType = CommandType.Text;
        oCmd.Parameters.Add("@loja", SqlDbType.VarChar).Value = ddlLojaDashEvt.Value;
        oCmd.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEventoDashEvt.Value;
        System.Data.SqlClient.SqlDataReader odr = oCmd.ExecuteReader();



        while (odr.Read())
        {
            topProspectores.Add
            (
                new TopProspectores
                {
                    vendedor = odr["vendedor"].ToString(),
                    equipe = odr["equipe"].ToString(),
                    qtde = (int)odr["qtde"]
                }
            );
        }
        vec.FecharConexao();
        for (int i = 0; i < topProspectores.Count; i++)
        {
            string color = "";
            switch (topProspectores[i].equipe)
            {
                case "BRANCA":
                    color = "rgba(128, 128, 128, 0.9)";
                    break;
                case "AMARELA":
                    color = "rgba(236, 244, 0, 0.9)";
                    break;
                case "AMARELO":
                    color = "rgba(236, 244, 0, 0.9)";
                    break;
                case "VERDE":
                    color = "rgba(40,167,69, 0.9)";
                    break;
                case "AZUL":
                    color = "rgba(0, 123, 255, 0.9)";
                    break;
                case "APOIO":
                    color = "rgba(0, 0, 0, 0.9)";
                    break;
                case "VERMELHA":
                    color = "rgba(255, 0, 0, 0.9)";
                    break;
                case "VERMELHO":
                    color = "rgba(255, 0, 0, 0.9)";
                    break;
                case "LARANJA":
                    color = "rgba(255, 165, 0, 0.9)";
                    break;
                default:
                    color = "rgba(63, 191, 191, 0.9)";
                    break;
            }
            retorno += "<li class=\"list-group-item\">" +
                            "<div class=\"widget-content p-0\">" +
                                 "<div class=\"widget-content-wrapper\">" +
                                    "<div class=\"widget-content-left mr-3\">" +
                                          "<span class=\"fas fa-circle fa-2x\" style='color:" + color + "'></span>" +
                                     "</div>" +
                                      "<div class=\"widget-content-left\">" +
                                          " <div class=\"widget-heading\">" + Html(topProspectores[i].vendedor) + "</div>" +
                                          " <div class=\"widget-subheading\" >" + Html(topProspectores[i].equipe) + "</div>" +
                                      "</div>" +
                                      "<div class=\"widget-content-right\">" +
                                          " <div class=\"font-size-xlg text-muted\">" +
                                                "<span>" + topProspectores[i].qtde + "</span>" + " <i class=\"fas fa-arrow-right\"></i> <span>" + getQuantidadeVendaPorProspector(ddlEventoDashEvt.Value, ddlLojaDashEvt.Value, topProspectores[i].vendedor, topProspectores[i].equipe) + "</span>" +
                                                "<small class=\"text-warning pl-2\">" +
                                                "</small>" +
                                           "</div>" +
                                      "</div>" +
                                   " </div>" +
                               " </div>" +
                       "  </li>";
        }

        return retorno;
    }
    public string getTimeline(string loja, string evento)
    {
        string chart = "";
        string labels = "";
        string dados = "";
        string color = "";
        string borderColor = "";
        string labelsVendas = "";
        string dadosVendas = "";
        string colorVendas = "";
        string borderColorVendas = "";
        try
        {
            vec.Conexao();
            SqlCommand oCmd1 = new SqlCommand();
            oCmd1.Connection = vec.oCon;
            oCmd1.CommandText = "APP..prospeccao_timeline";
            oCmd1.CommandType = CommandType.StoredProcedure;
            oCmd1.Parameters.Add("@loja", SqlDbType.VarChar).Value = loja;
            oCmd1.Parameters.Add("@evento", SqlDbType.VarChar).Value = evento;
            SqlDataReader odr1 = oCmd1.ExecuteReader();
            while (odr1.Read())
            {
                labels += "new Date(\"" + odr1["data"].ToString() + "\").toLocaleString(),";
                dados += "{ t: new Date(\"" + odr1["data"].ToString() + "\"),y: " + odr1["qtde"].ToString() + "  },";
                color += "'rgba(255, 99, 132, 0.2)',";
                borderColor += "'rgba(255,99,132,1)',";
            }
            labels = labels.Substring(0, labels.Length - 1);
            dados = dados.Substring(0, dados.Length - 1);
            color = color.Substring(0, color.Length - 1);
            borderColor = borderColor.Substring(0, borderColor.Length - 1);
            vec.FecharConexao();

            vec.Conexao();
            SqlCommand oCmd2 = new SqlCommand();
            oCmd2.Connection = vec.oCon;
            oCmd2.CommandText = "APP..prospeccao_timeline_venda";
            oCmd2.CommandType = CommandType.StoredProcedure;
            oCmd2.Parameters.Add("@loja", SqlDbType.VarChar).Value = loja;
            oCmd2.Parameters.Add("@evento", SqlDbType.VarChar).Value = evento;
            SqlDataReader odr2 = oCmd2.ExecuteReader();
            while (odr2.Read())
            {
                labelsVendas += "new Date(\"" + odr2["data"].ToString() + "\").toLocaleString(),";
                dadosVendas += "{ t: new Date(\"" + odr2["data"].ToString() + "\"),y: " + odr2["qtde"].ToString() + "  },";
                colorVendas += "'rgba(32, 25, 230, 0.2)',";
                borderColorVendas += "'rgba(32, 25, 230, 1)',";
            }
            labelsVendas = labelsVendas.Substring(0, labelsVendas.Length - 1);
            dadosVendas = dadosVendas.Substring(0, dadosVendas.Length - 1);
            colorVendas = colorVendas.Substring(0, colorVendas.Length - 1);
            borderColorVendas = borderColorVendas.Substring(0, borderColorVendas.Length - 1);

            chart = "var ctx = document.getElementById(\"line\").getContext(\"2d\");var myChart = new Chart(ctx, { type: 'line',  data: {  datasets: [{label: 'Visitas', data: [" + dados
                + "], backgroundColor: [" + color
                + "],borderColor: [" + borderColor
                + "],borderWidth: 1},{label: 'Vendas', data: [" + dadosVendas
                + "], backgroundColor: [" + colorVendas
                + "],borderColor: [" + borderColorVendas
                + "],borderWidth: 1}]}, options: {animation: false, scales: {yAxes : [{ticks:{beginAtZero: true}}],xAxes: [{type: 'time',time: { unit: 'minute'}}]}}});";

        }
        catch
        { }
        finally
        {
            vec.FecharConexao();
        }

        return chart;
    }

    private string Js(string valor)
    {
        return HttpUtility.JavaScriptStringEncode(valor ?? "");
    }

    private string Html(string valor)
    {
        return HttpUtility.HtmlEncode(valor ?? "");
    }
}

public class TopProspectores
{
    public String vendedor { set; get; }
    public String equipe { set; get; }
    public int qtde { set; get; }
}
