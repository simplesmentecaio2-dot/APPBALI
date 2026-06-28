using System;
using System.Web.UI;
using System.Data;
using System.Data.SqlClient;

public partial class veiculos_contrato : System.Web.UI.Page
{
    private Veiculos vec = new Veiculos();

    protected void Page_Load(object sender, EventArgs e)
    {

        if (Session["id"] != null)
        {
            if (getAcesso(1).Equals("s"))
            {
                usuarioLogado.Text = Session["usuario"].ToString();
                txtSerie.Focus();

                string serie = "";
                try
                {
                    if (Request.QueryString["serie"] != null)
                    {

                        serie = Request.QueryString["serie"].ToString();
                        txtSerie.Text = serie.Substring(10, 7);
                        btnProcessar_Click(sender, e);

                    }
                }
                catch
                {
                    this.executarJavaScript("alert('Codigo de barras não se refere a um chassi!'); ");
                }
            }
            else
            {
                Response.Redirect("./restrito.aspx");
            }
        }
        else
        {
            Response.Redirect("./login.aspx");
        }

        btnProcessar_Click(sender, e);

    }

    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Response.Redirect("./login.aspx");
    }

    public String getAcesso(int acesso_id)
    {
        Veiculos veiculos = new Veiculos();
        String retorno = "";

        try
        {
            veiculos.Conexao();
            SqlCommand oCmd = new SqlCommand();
            oCmd.Connection = veiculos.oCon;
            oCmd.CommandText = "APP..veiculos_patio_verificar_acesso";
            oCmd.CommandType = CommandType.StoredProcedure;
            oCmd.Parameters.Add("@fun_cad", SqlDbType.VarChar).Value = Session["usuario"];
            oCmd.Parameters.Add("@acesso_id", SqlDbType.Int).Value = acesso_id;


            SqlDataReader odr = oCmd.ExecuteReader();


            odr.Read();
            retorno = odr["resultado"].ToString();

        }
        catch
        {

        }
        finally
        {
            veiculos.FecharConexao();
        }
        return retorno;
    }

    private void limpaCampos()
    {
        this.dtAgendamento.Text = "";
        this.txtSerie.Text = "";
    }

    private void executarJavaScript(String script)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", script + "$(\"#dtAgendamento\").datetimepicker({ format: 'yyyy-mm-dd', autoclose: true, language: 'pt-BR' });$('#tablelvd').DataTable();", true);
    }

    protected void btnProcessar_Click(object sender, EventArgs e)
    {
        string dt = Request.Form[dtAgendamento.UniqueID];
        if (dt == null || dt.Equals(""))
        {
            DateTime localDate = DateTime.Now;
            dtAgendamento.Text = localDate.ToString("yyyy-MM-dd");
            dt = localDate.ToString("yyyy-MM-dd");
        }
        Veiculos vec = new Veiculos();
        try
        {

            vec.Conexao();

            System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
            oCmd.Connection = vec.oCon;
            oCmd.CommandType = CommandType.StoredProcedure;
            if (ddlTipoPesquisa.Value != null && ddlTipoPesquisa.Value.Equals("Data"))
            {
                oCmd.CommandText = "APP..veiculos_patio_select_agendamento_por_data";
                oCmd.Parameters.Add("@loja", SqlDbType.Int).Value = ddlLoja.Value;
                oCmd.Parameters.Add("@dt_agend", SqlDbType.DateTime).Value = Convert.ToDateTime(dt);
            }
            else if (ddlTipoPesquisa.Value != null && ddlTipoPesquisa.Value.Equals("Serie"))
            {
                oCmd.CommandText = "APP..veiculos_patio_select_agendamento_por_data";
            }
            System.Data.SqlClient.SqlDataReader odr = oCmd.ExecuteReader();
            string head = "";
            head = @"<table class='table table-striped table-bordered dt-responsive nowrap' style='width:100%' id='tablelvd'>
                        <thead >
                            <tr>
                                <td>Data</td>
                                <td>Serie</td>
                                <td>Modelo</td>
                                <td>Cor</td>
                                <td>Pedido</td>
                                <td>Vendedor</td>
                                </tr>
                        </thead>";
            string body = "";
            body = "<tbody>";
            // a quantidade de colunas(tfoot) deve se a mesma quantidade de colunas da tabela do banco.
            string foot = "";
            foot = @"</tbody></table>";
            while (odr.Read())
            {
                body += @"<tr><td>" + odr["dt_agend"].ToString() +
                               "</td><td>" + odr["ve_chassiserie"].ToString() +
                               "</td><td>" + odr["mod_ds"].ToString() +
                               "</td><td>" + odr["cor_ds"].ToString() +
                               "</td><td>" + odr["prop_nrpedido"].ToString() +
                               "</td><td>" + odr["fun_nmguerra"].ToString() +
                               "</td></tr>";
            }
            tableAgendamentos.Text = "";
            tableAgendamentos.Text = head + body + foot;
            dtAgendamento.Text = dt;
        }
        catch
        {
            tableAgendamentos.Text = "<div class=\"col-12 text-center h3\">SEM DADOS <i class=\"far fa-calendar-times ml-2\"></i><div>";
        }
        finally
        {
            vec.FecharConexao(); executarJavaScript("");// }
        }
    }

}
