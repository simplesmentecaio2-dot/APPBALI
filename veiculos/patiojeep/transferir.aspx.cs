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
        if (Session["usuario"] != null)
        {
            if (getAcesso(2).Equals("s"))
            {
                usuarioLogado.Text = Session["usuario"].ToString();
                txtSerie.Focus();
                btnRegistrar.Visible = false;
                txtCor.Enabled = false;
                txtModelo.Enabled = false;
                txtChassi.Enabled = false;
                txtCodVec.Enabled = false;
                ddlOrigem.Disabled = true;
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
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('O número de série deve conter 7 digitos!')", true);
                txtSerie.Focus();
            }
            else
            {
                try
                {
                    oJeep.Conexao2();
                    SqlCommand oCmd = new SqlCommand();
                    oCmd.Connection = oJeep.oCon2;
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
                        ddlOrigem.Value = odr["loja_id"].ToString();
                        btnRegistrar.Visible = true;
                        ddlDestino.Focus();
                    }
                    else
                    {
                        txtChassi.Text = "";
                        txtModelo.Text = "";
                        txtCor.Text = "";
                        txtCodVec.Text = "";
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

            if (ddlDestino.Value == ddlOrigem.Value)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Origem e destino iguais!')", true);
                btnRegistrar.Visible = true;
            }
            else
            {

                try
                {
                    oJeep.Conexao2();
                    SqlCommand oCmd = new SqlCommand();
                    oCmd.Connection = oJeep.oCon2;
                    oCmd.CommandText = "APP..veiculos_patio_insert_tranferencia";
                    oCmd.CommandType = CommandType.StoredProcedure;
                    oCmd.Parameters.Add("@ve_nr", SqlDbType.Int).Value = Convert.ToInt32(txtCodVec.Text);
                    oCmd.Parameters.Add("@fun_cad", SqlDbType.VarChar).Value = Session["usuario"];
                    oCmd.Parameters.Add("@lojaOrigem", SqlDbType.Int).Value = Convert.ToInt32(ddlOrigem.Value);
                    oCmd.Parameters.Add("@lojaDestino", SqlDbType.Int).Value = Convert.ToInt32(ddlDestino.Value);
                    SqlDataReader odr = oCmd.ExecuteReader();

                    txtChassi.Text = "";
                    txtModelo.Text = "";
                    txtCor.Text = "";
                    txtCodVec.Text = "";
                    txtSerie.Text = "";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Transferência realizada com sucesso.')", true);



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
}
