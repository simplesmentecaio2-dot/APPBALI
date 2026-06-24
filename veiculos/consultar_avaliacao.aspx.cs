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
        
    }
    protected void btnBuscarAvaliacao(object sender, EventArgs e)
    {
        
            if (txtPlaca.Value.Equals(""))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Favor preencher a placa!');", true);
                txtPlaca.Value = "";
                txtValor.Value = "";
            }
            else
            {
                try
                {
                    vec.Conexao();
                    SqlCommand oCmd1 = new SqlCommand();
                    oCmd1.Connection = vec.oCon;
                    oCmd1.CommandText = "APP..prospeccao_select_avaliacao";
                    oCmd1.CommandType = CommandType.StoredProcedure;
                    oCmd1.Parameters.Add("@placa", SqlDbType.VarChar).Value = txtPlaca.Value;
                    SqlDataReader odr1 = oCmd1.ExecuteReader();

                    if (odr1.Read())
                    {
                        txtValor.Disabled = true;
                        txtValor.Value = odr1["valor"].ToString();
                    }
                    else
                    {
                        txtPlaca.Value = "";
                        txtValor.Value = "";
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Nenhum dado encontrado!');", true);
                    }
                }
                catch
                {
                    txtPlaca.Value = "";
                    txtValor.Value = "";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro ao buscar dados!');", true);
                }
                finally
                {
                    vec.FecharConexao();
                }
            }

        
    }

}