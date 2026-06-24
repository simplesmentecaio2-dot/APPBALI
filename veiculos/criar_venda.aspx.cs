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
        if (Session["id"] != null && (Session["id"].Equals("CAIO") || Session["usuario"].Equals("CAIO") || Session["id"].Equals("caio@bali.com.br") || Session["usuario"].Equals("caio@bali.com.br") || Session["id"].Equals("PASSANTE") || Session["usuario"].Equals("PASSANTE") || Session["id"].Equals("passante") || Session["usuario"].Equals("passante") || Session["id"].Equals("natalia") || Session["usuario"].Equals("NATALIA")))
        {

        }
        else
        {
            Response.Redirect("./restrito.aspx");
        }

     
    }
    public void getClientes(object sender, EventArgs e) 
    {
        Veiculos veiculos = new Veiculos();
        try
        {
            veiculos.Conexao();
            SqlCommand oCmd1 = new SqlCommand();
            oCmd1.Connection = veiculos.oCon;
            oCmd1.CommandText = "APP..veiculos_prospeccao_select_cliente_fluxo";
            oCmd1.CommandType = CommandType.StoredProcedure;
            oCmd1.Parameters.Add("@loja", SqlDbType.VarChar).Value = ddlLoja.SelectedValue;
            oCmd1.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEvento.SelectedValue;
            SqlDataReader odr1 = oCmd1.ExecuteReader();
            ddlCliente.Items.Clear();
            while (odr1.Read())
            {
                ddlCliente.Items.Add(new ListItem(odr1["cliente"].ToString() + " - Cod.: " + odr1["id"].ToString(), odr1["id"].ToString()));
            }


        }
        catch
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro ao gravar dados!');", true);
        }
        finally
        {
            veiculos.FecharConexao();
        }
    }
    protected void btnSalvar_Click(object sender, EventArgs e)
    {
        if (ddlEvento.SelectedValue.Equals("SEM EVENTO") || ddlEvento.SelectedValue.Equals("")) 
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Não há eventos disponíveis para criação de venda!');", true);
        }
        else
        {
            if (ddlCliente.Value != null && ddlCliente.Value != "")
            {
                Veiculos veiculos = new Veiculos();
                try
                {
                    veiculos.Conexao();
                    SqlCommand oCmd1 = new SqlCommand();
                    oCmd1.Connection = veiculos.oCon;
                    oCmd1.CommandText = "APP..veiculos_prospeccao_insert_venda";
                    oCmd1.CommandType = CommandType.StoredProcedure;
                    oCmd1.Parameters.Add("@cliente_id", SqlDbType.Int).Value = ddlCliente.Value;
                    oCmd1.Parameters.Add("@vendedor", SqlDbType.VarChar).Value = ddlVendedor.SelectedValue;
                    oCmd1.Parameters.Add("@fun_cad", SqlDbType.VarChar).Value = Session["usuario"].ToString();
                    SqlDataReader odr1 = oCmd1.ExecuteReader();
                    odr1.Read();
                    if (odr1["resultado"].ToString().Equals("s"))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Venda gravada com sucesso!');", true);
                    }
                    else 
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Venda não gravada, já foi registrada!');", true);
                    }
                }
                catch
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro ao gravar dados!');", true);
                }
                finally
                {
                    veiculos.FecharConexao();
                }
            }
            else 
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Nenhum cliente encontrado!');", true);
            }

        }
    }

}