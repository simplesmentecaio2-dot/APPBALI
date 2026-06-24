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
        if (Session["id"] != null && (Session["id"].Equals("CAIO") || Session["usuario"].Equals("CAIO") || Session["id"].Equals("caio@bali.com.br") || Session["usuario"].Equals("caio@bali.com.br") || Session["id"].Equals("PASSANTE") || Session["usuario"].Equals("PASSANTE") || Session["id"].Equals("passante") || Session["usuario"].Equals("passante")))
        {

        }
        else
        {
            Response.Redirect("./restrito.aspx");
        }

    }
    protected void btnSalvarPassante_Click(object sender, EventArgs e)
    {
        literalEvento.Text = "";
        literalId.Text = "";
        literalNome.Text = "";
        literalLoja.Text = "";
        literalTelefone.Text = "";
        if (ddlEvento.Value.Equals("SEM EVENTO") || ddlEvento.Value.Equals("")) 
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Não há eventos disponíveis para criação de fluxo!');", true);
        }
        else
        {
            if (txtCliente.Value.Equals("") || txtTelefone.Value.Equals(""))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Favor preencher todos os campos!');", true);
            }
            else
            {
                try
                {
                    vec.Conexao();
                    SqlCommand oCmd1 = new SqlCommand();
                    oCmd1.Connection = vec.oCon;
                    oCmd1.CommandText = "APP..prospeccao_criar_passante";
                    oCmd1.CommandType = CommandType.StoredProcedure;
                    oCmd1.Parameters.Add("@nome", SqlDbType.VarChar).Value = txtCliente.Value;
                    oCmd1.Parameters.Add("@fone", SqlDbType.VarChar).Value = txtTelefone.Value;
                    oCmd1.Parameters.Add("@loja", SqlDbType.VarChar).Value = ddlLoja.Value;
                    oCmd1.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEvento.Value;
                    oCmd1.Parameters.Add("@vendedor", SqlDbType.VarChar).Value = Session["usuario"];
                    SqlDataReader odr1 = oCmd1.ExecuteReader();
                    odr1.Read();
                    if (odr1["resultado"].Equals("s"))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Fluxo gravado com sucesso, ID: "+odr1["id"].ToString()+"');", true);
                        literalEvento.Text = ddlEvento.Value;
                        literalId.Text = odr1["id"].ToString();
                        literalNome.Text = txtCliente.Value;
                        literalLoja.Text = ddlLoja.Value;
                        literalTelefone.Text = txtTelefone.Value;

                        txtCliente.Value = "";
                        txtTelefone.Value = "";
                    }
                    else if (odr1["resultado"].Equals("n"))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Cliente já cadastrado, favor acessar a lista QrCode!');", true);
                    }
                }
                catch
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro ao gravar dados!');", true);
                }
                finally
                {
                    vec.FecharConexao();
                }
            }

        }
    }

}