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
            Response.Redirect("./login.aspx");
        }
        
      

    }

    public void serieOnTextChanged(object sender, EventArgs e)
    {
        if (!txtSerie.Text.Equals(""))
        {
            if (txtSerie.Text.Length != 7)
            {
                limpaCampos();
                executarJavaScript("alert('O número de série deve conter 7 digitos!')");
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
                        executarJavaScript("alert('Dados não encontrados!')");

                    }

                }
                catch
                {
                    executarJavaScript("alert('Erro ao carregar dados!')");
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
            executarJavaScript("alert('Campo série Obrigatório!')");
        }
    }

    
    public void btnSair_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Response.Redirect("./login.aspx");
    }

    public String getHistorico(int vec_nr)
    {
        Jeep veiculos = new Jeep();
        String retorno = "";
        String lojaAtual = "";
        int cont = 0;
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
                cont++;
                retorno += "<li class=\"list-group-item\">" +
                                                   " <div class=\"widget-content p-0\">" +
                                                       " <div class=\"widget-content-outer\">" +
                                                           " <div class=\"widget-content-wrapper\">" +
                                                              "  <div class=\"widget-content-left\">" +
                                                                 "   <div class=\"widget-heading\"><i class=\"fa fa-user mr-2\"></i>"+odr["fun_cad"].ToString()+"</div>" +
                                                                  "  <div class=\"widget-subheading\"><i class=\"fa fa-calendar mr-2\"></i><b>" + odr["dt_transf"].ToString() + "</b></div>" +
                                                               " </div>" +
                                                                "<div class=\"widget-content-right\">" +
                                                                 "   <div class=\"widget-numbers\"><i class=\"badge badge-danger\">" + odr["origem"].ToString() + "</i><i class=\"fa fa-arrow-right ml-2 mr-2 text-info\"></i><i class=\"badge badge-success\">" + odr["destino"].ToString() + "</i></div>" +
                                                                "</div>" +
                                                            "</div>" +
                                                       " </div>" +
                                                   " </div>" +
                                               " </li>";
                

            }

        }
        catch
        {
            
        }
        finally
        {
            veiculos.FecharConexao2();
        }
        return retorno;
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