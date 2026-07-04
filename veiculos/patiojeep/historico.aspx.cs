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
using System.Threading;

public partial class veiculos_contrato : System.Web.UI.Page
{
    private Jeep vec = new Jeep();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] != null)
        {
            usuarioLogado.Text = Session["usuario"].ToString();
            txtSerie.Focus();
            txtCor.Enabled = false;
            txtModelo.Enabled = false;
            txtChassi.Enabled = false;
            txtCodVec.Enabled = false;
        }
        else
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
        }
        
      

    }

    public void serieOnTextChanged(object sender, EventArgs e)
    {
        if (!txtSerie.Text.Equals(""))
        {
            if (txtSerie.Text.Length != 7)
            {
                limpaCampos();
                executarJavaScript("alert('O n\\u00famero de s\\u00e9rie deve conter 7 d\\u00edgitos.')");
                txtSerie.Focus();
            }
            else
            {
                try
                {
                    vec.Conexao2();
                    SqlCommand oCmd = new SqlCommand();
                    oCmd.Connection = vec.oCon2;
                    oCmd.CommandText = "APP..veiculos_patio_selectTranferir";
                    oCmd.CommandType = CommandType.StoredProcedure;
                    oCmd.Parameters.Add("@chassi", SqlDbType.VarChar).Value = txtSerie.Text;

                    SqlDataReader odr = oCmd.ExecuteReader();

                    if (odr.Read())
                    {
                        txtChassi.Text = odr["ve_chassi"].ToString();
                        txtModelo.Text = odr["ve_ds"].ToString();
                        txtCor.Text = odr["cor_ds"].ToString();
                        txtCodVec.Text = odr["ve_nr"].ToString();
                        listaHistorico.Text = getHistorico(Convert.ToInt32(odr["ve_nr"].ToString()));
                        txtLojaAtual.Text = "<i class=\"badge badge-success col-md-4\"><i class=\"h2\">" + getLojaAtual(txtSerie.Text) + "</i></i>";


                    }
                    else
                    {
                        limpaCampos();
                        executarJavaScript("alert('Dados n\\u00e3o encontrados!')");

                    }

                }
                catch
                {
                    executarJavaScript("alert('N\\u00e3o foi poss\\u00edvel carregar os dados do ve\\u00edculo agora.')");
                }
                finally
                {
                    vec.FecharConexao2();
                }
            }
        }
        else
        {
            limpaCampos();
            executarJavaScript("alert('Informe a s\\u00e9rie antes de pesquisar.')");
        }
    }

    
    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Session.Abandon();
        Response.Redirect("./login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    public String getHistorico(int vec_nr)
    {
        Jeep veiculos = new Jeep();
        System.Text.StringBuilder retorno = new System.Text.StringBuilder();
        try
        {
            veiculos.Conexao2();
            SqlCommand oCmd = new SqlCommand();
            oCmd.Connection = veiculos.oCon2;
            oCmd.CommandText = "APP..veiculos_patio_select_historico";
            oCmd.CommandType = CommandType.StoredProcedure;
            oCmd.Parameters.Add("@ve_nr", SqlDbType.Int).Value = vec_nr;
            SqlDataReader odr = oCmd.ExecuteReader();

            while (odr.Read())
            {
                string usuario = Html(odr["fun_cad"]);
                string data = FormatarDataHora(odr["dt_transf"]);
                string origem = Html(odr["origem"]);
                string destino = Html(odr["destino"]);

                retorno.Append("<li class=\"list-group-item patio-history-item\">");
                retorno.Append("<div class=\"widget-content p-0\"><div class=\"widget-content-outer\"><div class=\"widget-content-wrapper\">");
                retorno.Append("<div class=\"widget-content-left\">");
                retorno.Append("<div class=\"widget-heading\"><i class=\"fa fa-user mr-2\"></i>" + usuario + "</div>");
                retorno.Append("<div class=\"widget-subheading\"><i class=\"fa fa-calendar mr-2\"></i><b>" + data + "</b></div>");
                retorno.Append("</div>");
                retorno.Append("<div class=\"widget-content-right\">");
                retorno.Append("<div class=\"widget-numbers\"><i class=\"badge badge-danger\">" + origem + "</i><i class=\"fa fa-arrow-right ml-2 mr-2 text-info\"></i><i class=\"badge badge-success\">" + destino + "</i></div>");
                retorno.Append("</div>");
                retorno.Append("</div></div></div>");
                retorno.Append("</li>");

            }

        }
        catch
        {
            
        }
        finally
        {
            veiculos.FecharConexao2();
        }
        return retorno.ToString();
    }
    public String getLojaAtual( String chassi)
    {
        String retorno = "";
        Jeep veiculos = new Jeep();
        try
        {
            veiculos.Conexao2();
            SqlCommand oCmd = new SqlCommand();
            oCmd.Connection = veiculos.oCon2;
            oCmd.CommandText = "APP..veiculos_patio_selectTranferir";
            oCmd.CommandType = CommandType.StoredProcedure;
            oCmd.Parameters.Add("@chassi", SqlDbType.VarChar).Value = chassi;
            SqlDataReader odr = oCmd.ExecuteReader();
            odr.Read();
            retorno = odr["ds"].ToString();
        }
        catch { }
        finally { veiculos.FecharConexao2();}
        return retorno;
    }

    private string Html(object valor)
    {
        return HttpUtility.HtmlEncode(Convert.ToString(valor));
    }

    private string FormatarDataHora(object valor)
    {
        DateTime data;
        if (valor != null && DateTime.TryParse(valor.ToString(), out data))
        {
            return data.ToString("dd/MM/yyyy HH:mm");
        }

        return Html(valor);
    }

    private void limpaCampos()
    {
        this.txtSerie.Text = "";
        this.txtChassi.Text = "";
        this.txtModelo.Text = "";
        this.txtCor.Text = "";
        this.txtCodVec.Text = "";
        this.listaHistorico.Text = "";
        this.txtLojaAtual.Text = "";
    }
    private void executarJavaScript(String script)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", script, true);
    }

}
