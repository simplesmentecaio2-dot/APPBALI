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
        if (Session["usuario"] == null || Session["usuario"].ToString().Equals(""))
        {
            Response.Redirect("./loginApp.aspx");
        }
        else
        {
            usuarioLogado.Text = Session["usuario"].ToString();
        }



        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", btnShowDataSia(sender, e) + btnShowDataAero(sender, e) + btnShowDataSaan(sender, e) + btnShowDataScia(sender, e), true);
        //usuarioLogado.Text = Session["usuario"].ToString();
    }

    protected void btnAtualizaDashClick(object sender, EventArgs e)
    {
        atualizarDsh.Interval = 30000;
        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",  btnShowDataSia(sender, e)+btnShowDataAero(sender, e)+btnShowDataSaan(sender, e)+  btnShowDataScia(sender, e), true);
    }

    public int getQuantidadeFluxo(String evento, String loja)
    {
        String sqlLoja = "";
        if (loja != null && loja != "")
        {
            sqlLoja = " and loja = '" + loja + "'";
        }

        String myQuery = "select COUNT(*) as qtde from APP.dbo.veiculos_prospeccao where Fluxo = 'S' and nome_evento = '" + evento + "' " + sqlLoja;
        vec.Conexao();

        System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = myQuery;
        oCmd.CommandType = CommandType.Text;
        System.Data.SqlClient.SqlDataReader odr = oCmd.ExecuteReader();
        odr.Read();
        int qtde = (int)odr["qtde"];
        vec.FecharConexao();
        return qtde;
    }

    public double getPercentualMeta(int qtdFluxo)
    {
        return (qtdFluxo * 100) / 200;
    }
    
    protected String btnShowDataSia(object sender, EventArgs e)
    {
        string myQuery = "SELECT loja, equipe, count(*) as qtde FROM [APP].[dbo].[veiculos_prospeccao] " +
            " where nome_evento = '" + ddlEventoDashEvt.Value + "' and loja = 'SIA' and classificacao is not null  group by loja,equipe order by qtde desc";

        vec.Conexao();

        System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = myQuery;
        oCmd.CommandType = CommandType.Text;
        System.Data.SqlClient.SqlDataReader odr = oCmd.ExecuteReader();

        List<String> equipes = new List<String>();
        List<int> convites = new List<int>();
        List<String> lojas = new List<String>();

        while (odr.Read())
        {
            lojas.Add(odr["loja"].ToString());
            equipes.Add(odr["equipe"].ToString());
            convites.Add(Convert.ToInt32(odr["qtde"]));
        }
        vec.FecharConexao();
        if (equipes.Count != 0)
        {
            String eqpRnk = "";
            String chart = "";
            chart += "new Chart(document.getElementById(\"barSia\"), { type: 'bar', data: {labels: ['";
            String eqp = "";
            // more detais
            for (int i = 0; i < equipes.Count; i++)
                eqp += equipes[i] + "','";
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
            chart += "]},options: { title: { display: false,text: 'Ranking'},animation: {duration: 0}, scales: { yAxes: [{ ticks: { beginAtZero:true }" +
                "}],yAxes: [{ticks: {fontSize: 12}}], xAxes: [{ ticks: { beginAtZero:true }" +
                "}],xAxes: [{ticks: {fontSize: 12}}]} }"; // Chart title
            chart += "});";
            txtTopProspectorSia.Text = getTopProspectores("SIA");
            return chart;
            


        }
        return "";
    }
    protected String btnShowDataSaan(object sender, EventArgs e)
    {
        string myQuery = "SELECT loja, equipe, count(*) as qtde FROM [APP].[dbo].[veiculos_prospeccao] " +
            " where nome_evento = '" + ddlEventoDashEvt.Value + "' and loja = 'SAAN'  and classificacao is not null  group by loja,equipe order by qtde desc";

        vec.Conexao();

        System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = myQuery;
        oCmd.CommandType = CommandType.Text;
        System.Data.SqlClient.SqlDataReader odr = oCmd.ExecuteReader();

        List<String> equipes = new List<String>();
        List<int> convites = new List<int>();
        List<String> lojas = new List<String>();

        while (odr.Read())
        {
            lojas.Add(odr["loja"].ToString());
            equipes.Add(odr["equipe"].ToString());
            convites.Add(Convert.ToInt32(odr["qtde"]));
        }
        vec.FecharConexao();
        if (equipes.Count != 0)
        {
            String eqpRnk = "";
            String chart = "";
            chart += "new Chart(document.getElementById(\"barSaan\"), { type: 'bar', data: {labels: ['";
            String eqp = "";
            // more detais
            for (int i = 0; i < equipes.Count; i++)
                eqp += equipes[i] + "','";
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
            chart += "]},options: { title: { display: false,text: 'Ranking'},animation: {duration: 0}, scales: { yAxes: [{ ticks: { beginAtZero:true }" +
                "}],yAxes: [{ticks: {fontSize: 12}}], xAxes: [{ ticks: { beginAtZero:true }" +
                "}],xAxes: [{ticks: {fontSize: 12}}]} }"; // Chart title
            chart += "});";
            txtTopProspectorSaan.Text = getTopProspectores("SAAN");
            return chart;


        }
        return "";
    }
    protected String btnShowDataAero(object sender, EventArgs e)
    {
        string myQuery = "SELECT loja, equipe, count(*) as qtde FROM [APP].[dbo].[veiculos_prospeccao] " +
            " where nome_evento = '" + ddlEventoDashEvt.Value + "' and loja = 'AERO'  and classificacao is not null  group by loja,equipe order by qtde desc";

        vec.Conexao();

        System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = myQuery;
        oCmd.CommandType = CommandType.Text;
        System.Data.SqlClient.SqlDataReader odr = oCmd.ExecuteReader();

        List<String> equipes = new List<String>();
        List<int> convites = new List<int>();
        List<String> lojas = new List<String>();

        while (odr.Read())
        {
            lojas.Add(odr["loja"].ToString());
            equipes.Add(odr["equipe"].ToString());
            convites.Add(Convert.ToInt32(odr["qtde"]));
        }
        vec.FecharConexao();
        if (equipes.Count != 0)
        {
            String eqpRnk = "";
            String chart = "";
            chart += "new Chart(document.getElementById(\"barAero\"), { type: 'bar', data: {labels: ['";
            String eqp = "";
            // more detais
            for (int i = 0; i < equipes.Count; i++)
                eqp += equipes[i] + "','";
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
            chart += "]},options: { title: { display: false,text: 'Ranking'},animation: {duration: 0}, scales: { yAxes: [{ ticks: { beginAtZero:true }" +
                "}],yAxes: [{ticks: {fontSize: 12}}], xAxes: [{ ticks: { beginAtZero:true }" +
                "}],xAxes: [{ticks: {fontSize: 12}}]} }"; // Chart title
            chart += "});";
            txtTopProspectorAero.Text = getTopProspectores("AERO");
            return chart;


        }
        return "";
    }
    protected String btnShowDataScia(object sender, EventArgs e)
    {
        string myQuery = "SELECT loja, equipe, count(*) as qtde FROM [APP].[dbo].[veiculos_prospeccao] " +
            " where nome_evento = '" + ddlEventoDashEvt.Value + "' and loja = 'SCIA'  and classificacao is not null  group by loja,equipe order by qtde desc";

        vec.Conexao();

        System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = myQuery;
        oCmd.CommandType = CommandType.Text;
        System.Data.SqlClient.SqlDataReader odr = oCmd.ExecuteReader();

        List<String> equipes = new List<String>();
        List<int> convites = new List<int>();
        List<String> lojas = new List<String>();

        while (odr.Read())
        {
            lojas.Add(odr["loja"].ToString());
            equipes.Add(odr["equipe"].ToString());
            convites.Add(Convert.ToInt32(odr["qtde"]));
        }
        vec.FecharConexao();
        if (equipes.Count != 0)
        {
            String eqpRnk = "";
            String chart = "";
            chart += "new Chart(document.getElementById(\"barScia\"), { type: 'bar', data: {labels: ['";
            String eqp = "";
            // more detais
            for (int i = 0; i < equipes.Count; i++)
                eqp += equipes[i] + "','";
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
            chart += "]},options: { title: { display: false,text: 'Ranking'},animation: {duration: 0}, scales: { yAxes: [{ ticks: { beginAtZero:true }" +
                "}],yAxes: [{ticks: {fontSize: 12}}], xAxes: [{ ticks: { beginAtZero:true }" +
                "}],xAxes: [{ticks: {fontSize: 12}}]} }"; // Chart title
            chart += "});";
            txtTopProspectorScia.Text = getTopProspectores("SCIA");
            return chart;


        }
        return "";
    }
    private String getTopProspectores(String loja)
    {
        List<TopProspectores> topProspectores = new List<TopProspectores>();
        String retorno = "";
        string myQuery = "select vendedor, equipe, COUNT(*) as qtde from [APP].[dbo].veiculos_prospeccao where nome_evento = '"+ddlEventoDashEvt.Value+"' and loja = '"+loja+"' group by vendedor,equipe order by qtde desc";

        vec.Conexao();

        System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = myQuery;
        oCmd.CommandType = CommandType.Text;
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
                default:
                    color = "rgba(63, 191, 191, 0.9)";
                    break;
            }
            if (i < 10)
            {
                retorno += "<li class=\"list-group-item\">" +
                                "<div class=\"widget-content p-0\">" +
                                     "<div class=\"widget-content-wrapper\">" +
                                        "<div class=\"widget-content-left mr-3\">" +
                                              "<span class=\"fas fa-circle fa-2x\" style='color:" + color + "'></span>" +
                                         "</div>" +
                                          "<div class=\"widget-content-left\">" +
                                              " <div class=\"widget-heading\">" + (i + 1) + "º " + topProspectores[i].vendedor + "</div>" +
                                              " <div class=\"widget-subheading\" >" + topProspectores[i].equipe + "</div>" +
                                          "</div>" +
                                          "<div class=\"widget-content-right\">" +
                                              " <div class=\"font-size-xlg text-muted\">" +
                                                    "<span>" + topProspectores[i].qtde + "</span>" +
                                                    "<small class=\"text-warning pl-2\">" +
                                                    "</small>" +
                                               "</div>" +
                                          "</div>" +
                                       " </div>" +
                                   " </div>" +
                           "  </li>";
            }
        }

        return retorno;
    }
}

public class TopProspectores
{
    public String vendedor { set; get; }
    public String equipe { set; get; }
    public int qtde { set; get; }
}
