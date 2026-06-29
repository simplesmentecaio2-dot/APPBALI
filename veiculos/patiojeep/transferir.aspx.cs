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
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
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
                btnRegistrar.Visible = false;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('O n\\u00famero de s\\u00e9rie deve conter 7 d\\u00edgitos.')", true);
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
                        btnRegistrar.Visible = false;
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Dados não encontrados!')", true);

                    }

                }
                catch
                {
                    btnRegistrar.Visible = false;
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('N\\u00e3o foi poss\\u00edvel carregar os dados do ve\\u00edculo agora.')", true);
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
            btnRegistrar.Visible = false;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Informe a s\\u00e9rie antes de pesquisar.')", true);
        }
    }

    public void btnRegistrar_Click(object sender, EventArgs e)
    {
        
        if (Session["usuario"] == null || Session["usuario"].Equals(""))
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
        }
        else
        {
            int codVeiculo;
            int lojaOrigem;
            int lojaDestino;
            if (!int.TryParse(txtCodVec.Text, out codVeiculo) || !int.TryParse(ddlOrigem.Value, out lojaOrigem) || !int.TryParse(ddlDestino.Value, out lojaDestino))
            {
                PatioJeepAuditoria.Registrar("TRANSFERIR_VALIDACAO", Session["usuario"], txtSerie.Text, "Dados obrigatorios ausentes antes da transferencia");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Pesquise a série e selecione a loja de destino antes de transferir.');", true);
                return;
            }

            if (ddlDestino.Value == ddlOrigem.Value)
            {
                PatioJeepAuditoria.Registrar("TRANSFERIR_ORIGEM_DESTINO_IGUAIS", Session["usuario"], txtSerie.Text, "Origem=" + ddlOrigem.Value + "; Destino=" + ddlDestino.Value);
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
                    oCmd.Parameters.Add("@ve_nr", SqlDbType.Int).Value = codVeiculo;
                    oCmd.Parameters.Add("@fun_cad", SqlDbType.VarChar).Value = Session["usuario"];
                    oCmd.Parameters.Add("@lojaOrigem", SqlDbType.Int).Value = lojaOrigem;
                    oCmd.Parameters.Add("@lojaDestino", SqlDbType.Int).Value = lojaDestino;
                    SqlDataReader odr = oCmd.ExecuteReader();

                    txtChassi.Text = "";
                    txtModelo.Text = "";
                    txtCor.Text = "";
                    txtCodVec.Text = "";
                    PatioJeepAuditoria.Registrar("TRANSFERIR_SUCESSO", Session["usuario"], txtSerie.Text, "Origem=" + ddlOrigem.Value + "; Destino=" + ddlDestino.Value);
                    txtSerie.Text = "";
                    btnRegistrar.Visible = false;
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Transferência realizada com sucesso.')", true);



                }
                catch
                {
                    PatioJeepAuditoria.Registrar("TRANSFERIR_ERRO", Session["usuario"], txtSerie.Text, "Erro ao gravar dados no banco");
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
        Session.Clear();
        Session.Abandon();
        Response.Redirect("./login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }
    public String getAcesso(int acesso_id)
    {
        Veiculos veiculos = new Veiculos();
        String retorno = "";
        string cacheKey = "patio_acesso_" + acesso_id;

        if (Session[cacheKey] != null)
        {
            return Session[cacheKey].ToString();
        }

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


            if (odr.Read())
            {
                retorno = odr["resultado"].ToString();
                Session[cacheKey] = retorno;
            }

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
