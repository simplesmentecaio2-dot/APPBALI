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
            ddlVendedor.Value = Session["usuario"].ToString();
            ddlVendedorDescarte.Value = Session["usuario"].ToString();


        }
        //vec.chartqtde(ddlEvento2.SelectedValue.ToString(), ddlLojadashboard.SelectedValue.ToString(), out chartquantidade);


        //chartqtdediv = chartquantidade;

    }
    public string tabela2;
    public string tabelaVU;

    protected void btnGravarDescarte_Click(object sender, EventArgs e)
    {
        if (ddlEventoDescarte.Value.Equals("SEM EVENTO") || ddlEventoDescarte.Value.Equals(""))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Não há eventos disponíveis para criação de descarte!');", true);
        }
        else
        {
            try
            {
                if (ddlVendedorDescarte.Value == "" || ddlLojaDescarte.Value == "" || ddlEquipeConviteDescarte.Value == "")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                               "alert('Favor preencher corretamente os campos!');", true);

                }
                else
                {
                    Veiculos vec = new Veiculos();
                    string prospecao = vec.insert_prospeccao("", "", "", "Descarte", ddlVendedorDescarte.Value, ddlLojaDescarte.Value, ddlEventoDescarte.Value, ddlEquipeConviteDescarte.Value);

                    //EnviaEmail emailenvia = new EnviaEmail();
                    //string email = txtEmail.Text;
                    //string cliente = txtCliente.Text;
                    //string vendedor = ddlVendedor.Text;
                    //string evento = ddlEvento.Text;
                    //string corpo = "<html><body><img src='../img/logobali.png' /><br><br>" +
                    //             "<b>Teste Email...</b><br><br>" +
                    //            "Mais alguma coisa.....<br></body></html>";
                    //emailenvia.sendconvite(email, cliente, evento, vendedor);


                    txtCliente.Value = "";
                    txtTelefone.Value = "";
                    txtEmail.Value = "";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                               "alert('Descarte gravado com sucasso.');", true);
                }



            }
            catch
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                       "alert('Erro ao gravar descarte!');", true);
                txtCliente.Value = "";
                txtTelefone.Value = "";
                txtEmail.Value = "";
            }
        }
    }
    protected void btnGravar_Click(object sender, EventArgs e)
    {

        if (ddlEvento.Value.Equals("SEM EVENTO") || ddlEvento.Value.Equals(""))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Não há eventos disponíveis para criação de convite!');", true);
        }
        else
        {
            try
            {
                if (txtCliente.Value == "" || txtTelefone.Value == "" || ddlClassificacao.Value == "" || ddlEvento.Value == "" || ddlVendedor.Value == "" || ddlLoja.Value == "" || ddlequipe.Value == "")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                               "alert('Favor preencher corretamente os campos!');", true);

                }
                else
                {
                    Veiculos vec = new Veiculos();
                    string prospecao = vec.insert_prospeccao(txtCliente.Value, txtTelefone.Value, txtEmail.Value, ddlClassificacao.Value, ddlVendedor.Value, ddlLoja.Value, ddlEvento.Value, ddlequipe.Value);

                    //EnviaEmail emailenvia = new EnviaEmail();
                    //string email = txtEmail.Text;
                    //string cliente = txtCliente.Text;
                    //string vendedor = ddlVendedor.Text;
                    //string evento = ddlEvento.Text;
                    //string corpo = "<html><body><img src='../img/logobali.png' /><br><br>" +
                    //             "<b>Teste Email...</b><br><br>" +
                    //            "Mais alguma coisa.....<br></body></html>";
                    //emailenvia.sendconvite(email, cliente, evento, vendedor);


                    txtCliente.Value = "";
                    txtTelefone.Value = "";
                    txtEmail.Value = "";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                               "alert('Dados gravados com sucasso.');", true);
                }



            }
            catch
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                       "alert('Erro ao gravar!');", true);
                txtCliente.Value = "";
                txtTelefone.Value = "";
                txtEmail.Value = "";
            }

        }

        //string arquivo = @"c:\imagem.jpg";



        //MailMessage message = new MailMessage("emailRemetente@algo.com.br", "destinatario@algo.com.br");
        //message.Subject = "Contato";
        //message.Body = corpo;
        //message.IsBodyHtml = true;

        //Attachment attachment = new Attachment(arquivo);
        //message.Attachments.Add(attachment);

        //SmtpClient mailClient = new SmtpClient("smtp.algo.com.br");

        //mailClient.Send(message); 

    }

    protected void btnProcessar_Click(object sender, EventArgs e)
    {
        try
        {
            Veiculos vec1 = new Veiculos();

            try
            {
                vec1.Conexao();

                SqlCommand oCmd1 = new SqlCommand();
                oCmd1.Connection = vec1.oCon;
                oCmd1.CommandText = "APP..prospeccao_relatorio_projecao";
                oCmd1.CommandType = CommandType.StoredProcedure;
                oCmd1.Parameters.Add("@loja", SqlDbType.VarChar).Value = ddlLojadashboard.Value;
                oCmd1.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEvento2.Value;
                oCmd1.Parameters.Add("@dtInicio", SqlDbType.Date).Value = txtDtInicial.Text;
                oCmd1.Parameters.Add("@dtFim", SqlDbType.Date).Value = txtDtFinal.Text;
                SqlDataReader odr1 = oCmd1.ExecuteReader();
                odr1.Read();
                lblQtdeLigacoes.Text = odr1["total_realizado"].ToString();
                lblvendacarro.Text = ((Convert.ToInt32(odr1["quente"].ToString()) * 0.1) * 0.3) + ""; ;
                lblquentes.Text = (Convert.ToInt32(odr1["quente"].ToString()) + Convert.ToInt32(odr1["manual"].ToString())) + "";
                lblfrios.Text = odr1["frio"].ToString();
                lblqtde.Text = (Convert.ToInt32(odr1["quente"].ToString()) + Convert.ToInt32(odr1["manual"].ToString()) + Convert.ToInt32(odr1["frio"].ToString())) + ""; ;
                lblFluxo.Text = (Convert.ToInt32(odr1["quente"].ToString()) * 0.1) + "";
                lblDescarte.Text = odr1["descarte"].ToString(); ;

                lblPercConfirmado.Text = ((Convert.ToInt32(odr1["quente"].ToString()) + Convert.ToInt32(odr1["manual"].ToString()) + Convert.ToInt32(odr1["frio"].ToString())) * 100 / Convert.ToInt32(lblQtdeLigacoes.Text)) + "%";
                lblPercDescarte.Text = ((Convert.ToInt32(lblDescarte.Text) * 100) / Convert.ToInt32(lblQtdeLigacoes.Text)) + "%";
                lblPercFrios.Text = ((Convert.ToInt32(lblfrios.Text) * 100) / Convert.ToInt32(lblQtdeLigacoes.Text)) + "%";
                lblPercQuentes.Text = ((Convert.ToInt32(lblquentes.Text) * 100) / Convert.ToInt32(lblQtdeLigacoes.Text)) + "%";
            }
            catch { }
            finally { vec1.FecharConexao(); }
            Veiculos vec = new Veiculos();

            vec.Conexao();

            SqlCommand oCmd = new SqlCommand();
            oCmd.Connection = vec.oCon;
            oCmd.CommandText = "APP..prospeccao_relatorio_prospectores";
            oCmd.CommandType = CommandType.StoredProcedure;
            oCmd.Parameters.Add("@loja", SqlDbType.VarChar).Value = ddlLojadashboard.Value;
            oCmd.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEvento2.Value;
            oCmd.Parameters.Add("@dtInicio", SqlDbType.Date).Value = txtDtInicial.Text;
            oCmd.Parameters.Add("@dtFim", SqlDbType.Date).Value = txtDtFinal.Text;
            SqlDataReader odr = oCmd.ExecuteReader();
            string head = "";
            head = @"<table id='tablelvd' class='table table-striped table-bordered dt-responsive nowrap' style='width:100%' id='tblprospeccao'>
                        <thead >
                            <tr>
                                <td>Vendedor</td>
                                <td>Pendente</td>
                                <td>Recontato</td>
                                <td>Quente</td>
                                <td>Frio</td>
                                <td>Manual</td>
                                <td>Descarte</td>
                                <td>Total Finalizado</td>
                                <td>Total Ligações</td>
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
                               "</td><td>" + odr["pendente"].ToString() +
                               "</td><td>" + odr["recontato"].ToString() +
                               "</td><td>" + odr["quente"].ToString() +
                               "</td><td>" + odr["frio"].ToString() +
                               "</td><td>" + odr["manual"].ToString() +
                               "</td><td>" + odr["descarte"].ToString() +
                               "</td><td>" + (Convert.ToInt32(odr["quente"].ToString()) + Convert.ToInt32(odr["frio"].ToString()) + Convert.ToInt32(odr["descarte"].ToString())) +
                               "</td><td>" + (Convert.ToInt32(odr["quente"].ToString()) + Convert.ToInt32(odr["frio"].ToString()) + Convert.ToInt32(odr["descarte"].ToString()) + Convert.ToInt32(odr["recontato"].ToString())) +




                               "</td></tr>";
            }
            tableLeadsVendedor.Text = "";
            tableLeadsVendedor.Text = head + body + foot;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",

                                                   "$('#tablelvd').DataTable({responsive: true }); $(function () { $('[data-toggle=\"tooltip\"]').tooltip()});gerarFunil(" + lblQtdeLigacoes.Text + ", " + lblqtde.Text + ", " + lblFluxo.Text + ", " + lblvendacarro.Text + ");", true);
        }
        catch (Exception ex)
        {

            lblQtdeLigacoes.Text = "0";
            lblvendacarro.Text = "0";
            lblquentes.Text = "0";
            lblfrios.Text = "0";
            lblqtde.Text = "0";
            lblFluxo.Text = "0";
            lblDescarte.Text = "0";

            lblPercConfirmado.Text = "0%";
            lblPercDescarte.Text = "0%";
            lblPercFrios.Text = "0%";
            lblPercQuentes.Text = "0%";
            tableLeadsVendedor.Text = "<i class='text-danger h3'>SEM DADOS<i/>";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('" + ex.Message + "');", true);
        }
        finally { vec.oCon.Close(); }




    }
    public void select_Tab_Consultaprospeccao(out string tabela)
    {
        vec.Conexao();

        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = "APP..prospeccao_selecttabela";

        oCmd.Parameters.Add("@usuario", SqlDbType.VarChar).Value = Session["usuario"];
        oCmd.CommandType = CommandType.StoredProcedure;
        SqlDataReader odr = oCmd.ExecuteReader();
        string head = @"<table class='table table-striped table-bordered dt-responsive' style='width:100%' id='tblprospeccao'>
                        <thead >
                            <tr>
                                <td>+</td>
                                <td>ID</td>
                                <td>Cliente</td>
                                <td>fone 1</td>
                                <td>fone 2</td>
                                <td>fone 3</td>
                                <td>vendedor</td>
                                <td>loja</td>
                                <td>equipe</td>
                                <td>classificacao</td>
                                </tr>
                        </thead>";
        string body = "<tbody>";
        // a quantidade de colunas(tfoot) deve se a mesma quantidade de colunas da tabela do banco.
        string foot = @"</tbody></table>";
        while (odr.Read())
        {
            //valor = Convert.ToDouble(odr["Valor"]);
            //<span title="<%# Eval("Numero") %>" onclick="consultaChamadoAberto(this)"><%# Eval("Numero") %></span>
            body = body + @"<tr> <td><label class='btn btn-success fas fa-plus'></label></td>
                           <td><button type='button' onClick='GetConviteQrCode(" + odr["id"] + ")' class='btn btn-primary' data-toggle='modal' data-target='#qrcode'><i class='fas fa-qrcode mr-1'></button>" +
                           "</td><td>" + odr["cliente"].ToString() +
                           "</td><td>" + odr["telefone"].ToString() +
                           "</td><td>" + odr["fone2"].ToString() +
                           "</td><td>" + odr["fone3"].ToString() +
                           "</td><td>" + odr["vendedor"].ToString() +
                           "</td><td>" + odr["loja"].ToString() +
                           "</td><td>" + odr["equipe"].ToString() +
                           "</td><td>" + odr["classificacao"].ToString() +
                           "</td></tr>";
        }

        tabela = head + body + foot;
        vec.FecharConexao();
    }

    protected void btnequipes_Click(object sender, EventArgs e)
    {

    }
    protected void btnProcessar4_Click(object sender, EventArgs e)
    {

    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        Veiculos vec = new Veiculos();
        string tabela;
        select_Tab_Consultaprospeccao(out tabela);
        tabela2 = tabela;
        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                           "$('#tblprospeccao').DataTable({responsive: true });", true);


    }

    //marcio



    protected void btnShowData(object sender, EventArgs e)
    {
        Veiculos vec = new Veiculos();
        try
        {
            equipesRanking.Text = "<div class='text-danger m-5'>SEM DADOS</div>";

            vec.Conexao();

            SqlCommand oCmd = new SqlCommand();
            oCmd.Connection = vec.oCon;
            oCmd.CommandText = "APP..prospeccao_relatorio_ranking_confirmados";
            oCmd.CommandType = CommandType.StoredProcedure;
            // oCmd.Parameters.Add("@loja", SqlDbType.VarChar).Value = ddlLojaRanking.Value;
            oCmd.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEventoRanking.Value;
            oCmd.Parameters.Add("@dtInicio", SqlDbType.Date).Value = txtDtInicialRanking.Text;
            oCmd.Parameters.Add("@dtFim", SqlDbType.Date).Value = txtDtFinalRanking.Text;
            SqlDataReader odr = oCmd.ExecuteReader();

            List<String> equipes = new List<String>();
            List<int> convites = new List<int>();
            List<String> lojas = new List<String>();





            while (odr.Read())
            {

                lojas.Add(odr["loja"].ToString());
                equipes.Add(odr["equipe"].ToString());
                convites.Add(Convert.ToInt32(odr["qtde"]));
            }

            if (equipes.Count != 0)
            {
                String eqpRnk = "";
                String chart = "";
                chart += "new Chart(document.getElementById(\"bar\"), { type: '" + tipoGrafico.Value + "', data: {labels: ['";
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
                        case "AMARELO":
                            eqpRnk += "<div class=\"col-md-6\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(236, 244, 0, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                            color += "'rgba(236, 244, 0, 0.9)',";
                            border += "'rgba(236, 244, 0, 0.9)',";
                            break;

                        case "ARGO":
                            eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(40,167,69, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                            color += "'rgba(40,167,69, 0.9)',";
                            border += "'rgba(40,167,69, 0.9)',";
                            break;
                        case "TORO":
                            eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(0, 123, 255, 0.9)\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                            color += "'rgba(0, 123, 255, 0.9)',";
                            border += "'rgba(0, 123, 255, 0.9)',";
                            break;
                        case "STRADA":
                            eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(255, 0, 0, 0.9\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                            color += "'rgba(255, 0, 0, 0.9)',";
                            border += "'rgba(255, 0, 0, 0.9)',";
                            break;
                        case "VERMELHO":
                            eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(255, 0, 0, 0.9\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                            color += "'rgba(255, 0, 0, 0.9)',";
                            border += "'rgba(255, 0, 0, 0.9)',";
                            break;
                        case "APOIO":
                            eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(0, 0, 0, 0.9\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
                            color += "'rgba(0, 0, 0, 0.9)',";
                            border += "'rgba(0, 0, 0, 0.9)',";
                            break;
                        case "LARANJA":
                            eqpRnk += "<div class=\"col-md-6 text-white\"><div class=\"card mb-3 ml-3 widget-content\" style=\"background-color:rgba(255, 165, 0, 0.9\" widget-content-wrapper=\"\" text-white\"=\"\"><div class=\"widget-content-left\"><div class=\"widget-heading\">" + equipes[i] + "</div><div class=\"widget-subheading\">Loja: " + lojas[i] + "</div></div><div class=\"widget-content-right\"><div class=\"widget-numbers text-white\"><span>" + convites[i] + "</span></div></div></div></div>";
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
                chart += "]},options: { title: { display: false,text: 'Ranking'} }"; // Chart title
                chart += "});";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", chart, true);

                equipesRanking.Text = eqpRnk;
            }


        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('" + ex.Message + "');", true);
            equipesRanking.Text = "<div class='text-danger m-5 h3'>SEM DADOS</div>";
        }
        finally
        {
            vec.oCon.Close();
        }
    }

    [System.Web.Services.WebMethod]
    public static ConviteQrCode GetConviteQrCode(int id)
    {
        string imgQR = "";
        QRCodeGenerator qrGenerator = new QRCodeGenerator();
        QRCodeGenerator.QRCode qrcode = qrGenerator.CreateQrCode("http://app.bali.com.br/veiculos/confirmafluxo.aspx?id=" + id, QRCodeGenerator.ECCLevel.Q);
        System.Web.UI.WebControls.Image imgQRcode = new System.Web.UI.WebControls.Image();
        imgQRcode.Height = 200;
        imgQRcode.Width = 200;

        using (Bitmap bitmap = qrcode.GetGraphic(20))
        {
            using (MemoryStream ms = new MemoryStream())
            {
                bitmap.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
                byte[] byteimage = ms.ToArray();
                imgQR = "data:image/png;base64," + Convert.ToBase64String(byteimage);
            }
        }
        string cliente, vendedor, loja, equipe, evento, data;
        Veiculos vec = new Veiculos();
        string code = "" + id;
        vec.select_prospeccao_qrcode(code, out cliente, out vendedor, out loja, out equipe, out evento, out data);
        ConviteQrCode qr = new ConviteQrCode { Cliente = cliente, QrCode = imgQR, Vendedor = vendedor, Loja = loja, Equipe = equipe, Evento = evento, Data = data.Substring(0, 10) };
        return qr;
    }

    public void gerarLead()
    {
        Veiculos vec = new Veiculos();
        vec.Conexao();
        if (Session["usuario"] != null)
        {
            campoLead.Visible = true;
            no_lead.Visible = false;
            no_logado.Visible = false;
            error_lead.Visible = false;
            try
            {

                SqlCommand oCmd = new SqlCommand();
                oCmd.Connection = vec.oCon;
                oCmd.CommandText = "APP..prospeccao_gerar_lead";
                oCmd.CommandType = CommandType.StoredProcedure;
                oCmd.Parameters.Add("@vendedor", SqlDbType.VarChar).Value = Session["usuario"].ToString();
                oCmd.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEventoGeraLead.Value;
                SqlDataReader odr = oCmd.ExecuteReader();
                if (odr.Read())
                {

                    txtIdLead.Text = odr["id"].ToString();
                    txtNomeLead.Text = odr["nome"].ToString();
                    labelContadorLigacaoLead.Text = (Convert.ToInt32(odr["descarte_cont"].ToString()) + 1) + "º Ligação.";
                    txtTelLead.Text = odr["telefone"].ToString();
                    linkTel.HRef = "tel:" + odr["telefone"].ToString();
                    txtTelLead2.Text = odr["fone2"].ToString();
                    linkTel2.HRef = "tel:" + odr["fone2"].ToString();
                    txtTelLead3.Text = odr["fone3"].ToString();
                    linkTel3.HRef = "tel:" + odr["fone3"].ToString();
                    txtCarroLead.Text = odr["carro"].ToString();
                    txtQtdePendentes.InnerText = odr["pendentes"].ToString();
                    txtQtdeRealizados.InnerText = odr["realizados"].ToString();
                    txtEmailLead.Text = odr["email"].ToString();
                    linkEmailLead.HRef = "mailto:" + odr["email"].ToString();
                    String id = odr["id"].ToString();
                    //ocultando div de equipes caso evento não temha equipes
                    if (odr["div_por_equipe"].Equals("não"))
                    {
                        divEquipeLead.Visible = false;
                    }
                    else
                    {
                        divEquipeLead.Visible = true;
                    }
                    vec.FecharConexao();
                    vec.Conexao();
                    //mudando estado do lead para aberto
                    SqlCommand oCmd1 = new SqlCommand();
                    oCmd1.Connection = vec.oCon;
                    oCmd1.CommandText = "APP..prospeccao_alterar_status";
                    oCmd1.CommandType = CommandType.StoredProcedure;
                    oCmd1.Parameters.Add("@id", SqlDbType.VarChar).Value = id;
                    oCmd1.Parameters.Add("@status", SqlDbType.VarChar).Value = "aberto";
                    SqlDataReader odr1 = oCmd1.ExecuteReader();



                }
                else
                {
                    vec.FecharConexao();
                    vec.Conexao();
                    //mudando estado do lead para aberto
                    SqlCommand oCmd2 = new SqlCommand();
                    oCmd2.Connection = vec.oCon;
                    oCmd2.CommandText = "APP..prospeccao_qtde_realizados";
                    oCmd2.CommandType = CommandType.StoredProcedure;
                    oCmd2.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEventoGeraLead.Value;
                    oCmd2.Parameters.Add("@vendedor", SqlDbType.VarChar).Value = Session["usuario"];
                    SqlDataReader odr2 = oCmd2.ExecuteReader();
                    if (odr2.Read())
                    {
                        txtQtdePendentes.InnerText = odr2["pendentes"].ToString();
                        txtQtdeRealizados.InnerText = odr2["realizados"].ToString();
                    }


                    campoLead.Visible = false;
                    no_lead.Visible = true;
                    no_logado.Visible = false;
                    error_lead.Visible = false;

                }

            }
            catch (Exception e)
            {
                campoLead.Visible = false;
                no_lead.Visible = false;
                no_logado.Visible = false;
                error_lead.Visible = true;
                erroMessage.Text = e.Message;

            }
            finally
            {
                vec.FecharConexao();

            }
        }
        else
        {
            campoLead.Visible = false;
            no_lead.Visible = false;
            no_logado.Visible = true;
            error_lead.Visible = false;
        }
    }
    public void btnWhats_Click(object sender, EventArgs e)
    {

        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Você será redirecionado :)');window.open('" + "http://wa.me/55" + txtTelLead.Text + "','_blank');", true);

    }

    public void btnWhats_Click2(object sender, EventArgs e)
    {

        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Você será redirecionado :)');window.open('" + "http://wa.me/55" + txtTelLead2.Text + "','_blank');", true);

    }
    public void btnWhats_Click3(object sender, EventArgs e)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Você será redirecionado :)');window.open('" + "http://wa.me/55" + txtTelLead3.Text + "','_blank');", true);

    }
    public void btnSalvarLead_Click(object sender, EventArgs e)
    {
        if (ddlEquipeLead.Value == "" || ddlEquipeLead.Value == null)
        {
            ddlEquipeLead.Focus();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Favor selecionar a equipe!');", true);
        }
        else if (!ddlClassificacaoLead.Value.Equals("QUENTE") && !ddlClassificacaoLead.Value.Equals("FRIO"))
        {
            ddlClassificacaoLead.Focus();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Favor selecionar uma Classificação igual a \"QUENTE\" ou \"FRIO\" para confirmar!');", true);
        }
        else
        {
            ConviteQrCode qr = new ConviteQrCode();
            vec.Conexao();
            SqlCommand oCmd1 = new SqlCommand();
            oCmd1.Connection = vec.oCon;
            oCmd1.CommandText = "APP..prospeccao_lead_sucesso";
            oCmd1.CommandType = CommandType.StoredProcedure;
            oCmd1.Parameters.Add("@id", SqlDbType.VarChar).Value = txtIdLead.Text;
            oCmd1.Parameters.Add("@classificacao", SqlDbType.VarChar).Value = ddlClassificacaoLead.Value;
            oCmd1.Parameters.Add("@equipe", SqlDbType.VarChar).Value = ddlEquipeLead.Value;
            SqlDataReader odr1 = oCmd1.ExecuteReader();
            odr1.Read();
            qr = GetConviteQrCode((int)odr1["id"]);
            vec.FecharConexao();
            txtClienteQrLead.InnerText = qr.Cliente;
            imgQrLead.InnerHtml = "<img class=\"img-fluid\" src=\"" + qr.QrCode + "\" />";
            txtEventoQrLead.InnerText = qr.Evento;
            txtVendedorQrLead.InnerText = qr.Vendedor;
            txtLojaQrLead.InnerText = qr.Loja;
            txtDataQrLead.InnerText = qr.Data.Substring(0, 10);
            gerarLead();
            if (!qr.Equipe.Equals("SEM EQUIPE"))
            {
                txtEquipeQrLead.InnerText = qr.Equipe;
            }
            gerarLead();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "$(\"#myModal\").modal(); ", true);
        }

    }

    public void btnDescartaLead_Click(object sender, EventArgs e)
    {
        vec.Conexao();
        SqlCommand oCmd1 = new SqlCommand();
        oCmd1.Connection = vec.oCon;
        oCmd1.CommandText = "APP..prospeccao_lead_descarte";
        oCmd1.CommandType = CommandType.StoredProcedure;
        oCmd1.Parameters.Add("@id", SqlDbType.VarChar).Value = txtIdLead.Text;
        SqlDataReader odr1 = oCmd1.ExecuteReader();
        vec.FecharConexao();
        gerarLead();
    }
    public void btnDescartaLeadLixo_Click(object sender, EventArgs e)
    {
        try
        {
            if (!ddlClassificacaoLead.Value.Equals("QUENTE") && !ddlClassificacaoLead.Value.Equals("FRIO"))
            {
                vec.Conexao();
                SqlCommand oCmd1 = new SqlCommand();
                oCmd1.Connection = vec.oCon;
                oCmd1.CommandText = "APP..prospeccao_lead_descarte_lixo";
                oCmd1.CommandType = CommandType.StoredProcedure;
                oCmd1.Parameters.Add("@id", SqlDbType.VarChar).Value = txtIdLead.Text;
                oCmd1.Parameters.Add("@classificacao", SqlDbType.VarChar).Value = ddlClassificacaoLead.Value;
                SqlDataReader odr1 = oCmd1.ExecuteReader();
                vec.FecharConexao();
                gerarLead();
            }
            else
            {
                ddlClassificacaoLead.Focus();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Favor selecionar uma Classificação diferente de \"QUENTE\" e \"FRIO\" para descartar!');", true);
            }
        }
        catch
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro ao Descartar contato!');", true);
        }
    }
    public void btnAtualizaLead_Click(object sender, EventArgs e)
    {
        gerarLead();
    }
    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session["id"] = null;
        Session["usuario"] = null;
        Session["tipo"] = null;
        Session["email"] = null;
        Session["ramal"] = null;
        Session["celular"] = null;
        Session["empresa"] = null;
        Response.Redirect("./loginApp.aspx");
    }
    public void teste(object sender, EventArgs e)
    {

        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "$(\"#myModal\").modal(); alert('asasas');", true);
    }
}
