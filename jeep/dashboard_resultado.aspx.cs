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
        txtPercentualEvt.Text = getPercentualMeta(qtdeFluxo) + "%";


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
        getVendas(sender,e);
        txtTotalVendas.Text = getQuantidadeVenda() + "";
        btnProcessar_Click();
        string qtdequente, qtdefrio, qtdetotal, qtdeseminteresse, chartquantidade, qtdefluxo, qtdevendacarro, qtdeLigacoes, qtdeDescartes, qtdepassantes, qtdeFluxoConvites;
        vec.select_prospeccao_quente(ddlEventoDashEvt.Value, ddlLojaDashEvt.Value, out qtdequente);
        vec.select_prospeccao_total(ddlEventoDashEvt.Value, ddlLojaDashEvt.Value, out qtdetotal);
        vec.select_prospeccao_fluxo(ddlEventoDashEvt.Value, ddlLojaDashEvt.Value, out qtdefluxo);
        vec.select_prospeccao_total_ligacoes(ddlEventoDashEvt.Value, ddlLojaDashEvt.Value, out qtdeLigacoes);
        vec.select_prospeccao_passantes(ddlEventoDashEvt.Value, ddlLojaDashEvt.Value, out qtdepassantes);
        vec.select_prospeccao_fluxoConvite(ddlEventoDashEvt.Value, ddlLojaDashEvt.Value, out qtdeFluxoConvites);
        txtTotalLigacoes.Text = qtdeLigacoes;
        txtTotalConvites.Text = qtdetotal;
        txtTotalPassantes.Text = qtdepassantes;
        txtTotalFluxoConvites.Text = qtdeFluxoConvites;



        String loja;

        if (ddlLojaDashEvt.Value == "" || ddlLojaDashEvt.Value == null)
        {
            loja = "";
        }
        else
        {
            loja = "and loja = '" + ddlLojaDashEvt.Value + "'";
        }

        string myQuery = "SELECT loja, equipe, count(*) as qtde FROM [APP].[dbo].[veiculos_prospeccao] " +
            " where nome_evento = '" + ddlEventoDashEvt.Value + "' " + loja + "and Fluxo = 's'  group by loja,equipe order by qtde desc";

        vec.Conexao();

        System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = myQuery;
        oCmd.CommandType = CommandType.Text;
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
            chart += "]},options: { title: { display: false,text: 'Ranking'},animation: {duration: 0}, scales: {  yAxes : [{ticks:{beginAtZero: true}}], xAxes: [{ ticks: { beginAtZero:true }" +
                "}],xAxes: [{ticks: {fontSize: 12}}]} }"; // Chart title
            chart += "});";





        }
        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", chart + getTimeline(ddlLojaDashEvt.Value, ddlEventoDashEvt.Value) + "$('#tablelvd').DataTable({responsive: true }); $(function () { $('[data-toggle=\"tooltip\"]').tooltip()});", true);
    }

    private String getTopProspectores()
    {
        List<TopProspectores> topProspectores = new List<TopProspectores>();
        String retorno = "";
        string myQuery = "select vendedor, equipe, COUNT(*) as qtde from [APP].[dbo].veiculos_prospeccao where loja = '" + ddlLojaDashEvt.Value + "' and nome_evento = '" + ddlEventoDashEvt.Value + "' and fluxo = 's' group by vendedor,equipe order by qtde desc";

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
            retorno += "<li class=\"list-group-item\">" +
                            "<div class=\"widget-content p-0\">" +
                                 "<div class=\"widget-content-wrapper\">" +
                                    "<div class=\"widget-content-left mr-3\">" +
                                          "<span class=\"fas fa-circle fa-2x\" style='color:" + color + "'></span>" +
                                     "</div>" +
                                      "<div class=\"widget-content-left\">" +
                                          " <div class=\"widget-heading\">" + topProspectores[i].vendedor + "</div>" +
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
                + "],borderWidth: 1}]}, options: {animation: false, scales: { yAxes : [{ticks:{beginAtZero: true}}],xAxes: [{type: 'time',time: { unit: 'minute'}}]}}});";

        }
        catch
        { }
        finally
        {
            vec.FecharConexao();
        }

        return chart;
    }

    protected void btnProcessar_Click()
    {
        Veiculos vec = new Veiculos();
        try
        {

            vec.Conexao();

            System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
            oCmd.Connection = vec.oCon;
            oCmd.CommandText = "APP..prospeccao_relatorio_prospectores";
            oCmd.CommandType = CommandType.StoredProcedure;
            oCmd.Parameters.Add("@loja", SqlDbType.VarChar).Value = ddlLojaDashEvt.Value;
            oCmd.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEventoDashEvt.Value;
            System.Data.SqlClient.SqlDataReader odr = oCmd.ExecuteReader();
            string head = "";
            head = @"<table id='tablelvd' class='table table-striped table-bordered dt-responsive nowrap' style='width:100%' id='tblprospeccao'>
                        <thead >
                            <tr>
                                <td>Vendedor</td>
                                <td>Equipe</td>
                                <td>Quente</td>
                                <td>Manual</td>
                                <td>Fluxo</td>
                                <td>Fluxo Lista</td>
                                <td>Fluxo Manual</td>
                                <td>Vendas Lista</td>
                                <td>Vendas Manual</td>
                                </tr>
                        </thead>";
            string body = "";
            body = "<tbody>";
            // a quantidade de colunas(tfoot) deve se a mesma quantidade de colunas da tabela do banco.
            string foot = "";
            foot = @"</tbody></table>";
            while (odr.Read())
            {
                body += @"<tr><td>" + odr["vendedor"].ToString() +
                               "</td><td>" + odr["equipe"].ToString() +
                               "</td><td>" + odr["quente"].ToString() +
                               "</td><td>" + odr["manual"].ToString() +
                               "</td><td>" + odr["Fluxo"].ToString() +
                               "</td><td>" + odr["FluxoLista"].ToString() +
                               "</td><td>" + odr["FluxoManual"].ToString() +
                               "</td><td>" + getQuantidadeVendaPorProspector(ddlEventoDashEvt.Value, ddlLojaDashEvt.Value, odr["vendedor"].ToString(), odr["equipe"].ToString()) +
                               "</td><td>" + getQuantidadeVendaPorProspectorManual(ddlEventoDashEvt.Value, ddlLojaDashEvt.Value, odr["vendedor"].ToString(), odr["equipe"].ToString()) +





                               "</td></tr>";
            }
            tableLeadsVendedor.Text = "";
            tableLeadsVendedor.Text = head + body + foot;
        }
        catch
        {
            tableLeadsVendedor.Text = "<i class='text-danger h3'>SEM DADOS<i/>";
        }
        finally { vec.FecharConexao(); }




    }
    public int getQuantidadeVenda()
    {

        Veiculos veiculos = new Veiculos();

        veiculos.Conexao();
        SqlCommand oCmd1 = new SqlCommand();
        oCmd1.Connection = veiculos.oCon;
        oCmd1.CommandText = "APP..veiculos_prospeccao_select_venda";
        oCmd1.CommandType = CommandType.StoredProcedure;
        oCmd1.Parameters.Add("@loja", SqlDbType.VarChar).Value = ddlLojaDashEvt.Value;
        oCmd1.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEventoDashEvt.Value;
        SqlDataReader odr1 = oCmd1.ExecuteReader();
        odr1.Read();
        int qtde = (int)odr1["qtde"];
        veiculos.FecharConexao();
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
    public int getQuantidadeVendaPorProspector(String evento, String loja, String vendedor, String equipe)
    {
        Veiculos veiculos = new Veiculos();
        int qtde = 0;
        try
        {

            string myQuery = @"select count(*) as qtde from app..veiculos_prospeccao p
                            inner join app..veiculos_prospeccao_venda v on p.id = v.cliente_id
                            where (manual is null or manual = 0) and p.loja = '" + loja + "' and p.nome_evento = '" + evento + "' and p.vendedor = '" + vendedor + "'";

            veiculos.Conexao();

            System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
            oCmd.Connection = veiculos.oCon;
            oCmd.CommandText = myQuery;
            oCmd.CommandType = CommandType.Text;
            System.Data.SqlClient.SqlDataReader odr1 = oCmd.ExecuteReader();
            odr1.Read();
            qtde = (int)odr1["qtde"];


        }
        catch { }
        finally { veiculos.FecharConexao(); }
        return qtde;
    }public int getQuantidadeVendaPorProspectorManual(String evento, String loja, String vendedor, String equipe)
    {
        Veiculos veiculos = new Veiculos();
        int qtde = 0;
        try
        {

            string myQuery = @"select count(*) as qtde from app..veiculos_prospeccao p
                            inner join app..veiculos_prospeccao_venda v on p.id = v.cliente_id
                            where p.manual = 1 and p.loja = '" + loja + "' and p.nome_evento = '" + evento + "' and p.vendedor = '" + vendedor + "'";

            veiculos.Conexao();

            System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
            oCmd.Connection = veiculos.oCon;
            oCmd.CommandText = myQuery;
            oCmd.CommandType = CommandType.Text;
            System.Data.SqlClient.SqlDataReader odr1 = oCmd.ExecuteReader();
            odr1.Read();
            qtde = (int)odr1["qtde"];


        }
        catch { }
        finally { veiculos.FecharConexao(); }
        return qtde;
    }
    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Response.Redirect("./loginApp.aspx");
    }
}

public class TopProspectores
{
    public String vendedor { set; get; }
    public String equipe { set; get; }
    public int qtde { set; get; }
}
