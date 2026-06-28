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
    private Jeep oJeep = new Jeep();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] != null)
        {
            //if (getAcesso(1).Equals("s"))
            //{
                usuarioLogado.Text = Session["usuario"].ToString();
                txtSerie.Focus();
                //btnRegistrar.Visible = false;
                txtCor.Enabled = false;
                txtModelo.Enabled = false;
                txtChassi.Enabled = false;
                txtCodVec.Enabled = false;
                string serie = "";
                try
                {
                    if (Request.QueryString["serie"] != null)
                    {

                        serie = Request.QueryString["serie"].ToString();
                        txtSerie.Text = serie.Substring(10, 7);
                        serieOnTextChanged( sender, e);

                    }
                }
                catch
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Codigo de barras não se refere a um chassi!')", true);
                }
            //}
            //else
            //{
            //    Response.Redirect("./restrito.aspx");
            //}
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
                txtChassi.Text = "";
                txtModelo.Text = "";
                txtCor.Text = "";
                txtCodVec.Text = "";
                txtNUMERONF.Text = "";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('O número de série deve conter 7 digitos!');$('#myModal').modal('show');", true);
                txtSerie.Focus();
            }
            else
            {
                try
                {
                    oJeep.Conexao2();
                    SqlCommand oCmd = new SqlCommand();
                    oCmd.Connection = oJeep.oCon2;
                    oCmd.CommandText = "APP..veiculos_patio_selectRegistrar";
                    oCmd.CommandType = CommandType.StoredProcedure;
                    oCmd.Parameters.Add("@chassi", SqlDbType.VarChar).Value = txtSerie.Text;

                    SqlDataReader odr = oCmd.ExecuteReader();

                    if (odr.Read())
                    {
                        txtChassi.Text = odr["ve_chassi"].ToString();
                        txtModelo.Text = odr["ve_ds"].ToString();
                        txtCor.Text = odr["cor_ds"].ToString();
                        txtCodVec.Text = odr["ve_nr"].ToString();
                        txtNUMERONF.Text = odr["numeronf"].ToString();
                        btnRegistrar.Visible = true;
                        ddlLoja.Focus();
                    }
                    else
                    {
                        txtChassi.Text = "";
                        txtModelo.Text = "";
                        txtCor.Text = "";
                        txtCodVec.Text = "";
                        txtNUMERONF.Text = "";
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Dados não encontrados!')", true);

                    }

                }
                catch
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro ao carregar dados!')", true);
                }
                finally
                {
                    oJeep.FecharConexao2();
                }
            }
        }
        else
        {
            txtChassi.Text = "";
            txtModelo.Text = "";
            txtCor.Text = "";
            txtCodVec.Text = "";
            txtNUMERONF.Text = "";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Campo série Obrigatório!')", true);
        }
    }

    public void btnRegistrar_Click(object sender, EventArgs e)
    {
        if (Session["usuario"] == null || Session["usuario"].Equals("")) 
        {
            Response.Redirect("./login.aspx");
        }
        else
        {

            try
            {
                oJeep.Conexao2();
                SqlCommand oCmd = new SqlCommand();
                oCmd.Connection = oJeep.oCon2;
                oCmd.CommandText = "APP..veiculos_patio_insert_locacao";
                oCmd.CommandType = CommandType.StoredProcedure;
                oCmd.Parameters.Add("@ve_nr", SqlDbType.Int).Value = Convert.ToInt32(txtCodVec.Text);
                oCmd.Parameters.Add("@fun_cad", SqlDbType.VarChar).Value = Session["usuario"];
                oCmd.Parameters.Add("@loja", SqlDbType.Int).Value = Convert.ToInt32(ddlLoja.Value);
                oCmd.Parameters.Add("@numeronf", SqlDbType.Int).Value = Convert.ToInt32(txtNUMERONF.Text);



                SqlDataReader odr = oCmd.ExecuteReader();
                odr.Read();
                if (odr["resultado"].ToString().Equals("n"))
                {
                    txtChassi.Text = "";
                    txtModelo.Text = "";
                    txtCor.Text = "";
                    txtCodVec.Text = "";
                    txtNUMERONF.Text = "";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Veículo já cadastrado!')", true);
                }
                else
                {
                    txtChassi.Text = "";
                    txtModelo.Text = "";
                    txtCor.Text = "";
                    txtCodVec.Text = "";
                    txtNUMERONF.Text = "";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Dados gravados com sucesso.')", true);

                }

            }
            catch
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro ao gravar dados no banco!')", true);
            }
            finally
            {
                oJeep.FecharConexao2();
            }
        }
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
        Response.Redirect("./login.aspx");
    }

    public String getAcesso(int acesso_id)
    {
        Veiculos veiculos = new Veiculos();
        String retorno = "";

        try
        {
            oJeep.Conexao2();
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
            oJeep.FecharConexao2();
        }
        return retorno;
    }

}
