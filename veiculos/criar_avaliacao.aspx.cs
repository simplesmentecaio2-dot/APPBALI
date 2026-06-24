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
    protected void btnSalvarAvaliacao(object sender, EventArgs e)
    {
        
            if (txtPlaca.Value.Equals("") || txtValor.Value.Equals(""))
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
                    oCmd1.CommandText = "APP..prospeccao_insert_avaliacao";
                    oCmd1.CommandType = CommandType.StoredProcedure;
                    oCmd1.Parameters.Add("@placa", SqlDbType.VarChar).Value = txtPlaca.Value;
                    oCmd1.Parameters.Add("@valor", SqlDbType.VarChar).Value = txtValor.Value;
                    oCmd1.Parameters.Add("@usuario", SqlDbType.VarChar).Value = Session["usuario"];
                    SqlDataReader odr1 = oCmd1.ExecuteReader();
                    odr1.Read();
                    if (odr1["resultado"].Equals("s"))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Avaliação gravado com sucesso!');", true);
                        txtPlaca.Value = "";
                        txtValor.Value = "";
                    }
                    else if (odr1["resultado"].Equals("a"))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Avaliação atualizada!');", true);
                        txtPlaca.Value = "";
                        txtValor.Value = "";
                    }
                }
                catch
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro ao gravar dados!');", true);
                    txtPlaca.Value = "";
                    txtValor.Value = "";
                }
                finally
                {
                    vec.FecharConexao();
                }
            }

        
    }

}