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
        if (Session["id"] != null)
        {
            usuarioLogado.Text = Session["usuario"].ToString();

        }
        else
        {
            Response.Redirect("./loginApp.aspx");
        }  
    }

    public void transferir(object sender, EventArgs e)
    {
        try
        {
            vec.Conexao();
            SqlCommand oCmd1 = new SqlCommand();
            oCmd1.Connection = vec.oCon;
            oCmd1.CommandText = "APP..prospeccao_tranferir_lead";
            oCmd1.CommandType = CommandType.StoredProcedure;
            oCmd1.Parameters.Add("@quantidade", SqlDbType.Int).Value = Convert.ToInt32(txtQuantidade.Value);
            oCmd1.Parameters.Add("@loja", SqlDbType.VarChar).Value = ddlLoja.Value;
            oCmd1.Parameters.Add("@vendOrigem", SqlDbType.VarChar).Value = ddlVendOrigem.SelectedItem.Value;
            oCmd1.Parameters.Add("@vendDestino", SqlDbType.VarChar).Value = ddlVendDestino.Value;
            oCmd1.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEvento2.Value;
            oCmd1.Parameters.Add("@usuario", SqlDbType.VarChar).Value = Session["usuario"].ToString();
            SqlDataReader odr1 = oCmd1.ExecuteReader();

            if (odr1.Read() && odr1["resultado"].Equals("s"))
            {
                if (odr1["qtde"].ToString() == "0") 
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro, Não foi transferido nenhum Lead, \"Favor verificar a Loja.\"!')", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Sucesso, foram tranferidos " + odr1["qtde"] + " leads de " + ddlVendOrigem.SelectedItem.Value + " para " + ddlVendDestino.Value + "!')", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro, Tranferencia não realizada!!')", true);
            }
        }
        catch
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro, Tranferencia não realizada!')", true);
        }
        finally
        {
            vec.FecharConexao(); getQuantidadeDisponivel(sender, e);
        }
    }
    public void getQuantidadeDisponivel(object sender, EventArgs e)
    {
        Veiculos veiculos = new Veiculos();
        try
        {
            veiculos.Conexao();
            SqlCommand oCmd1 = new SqlCommand();
            oCmd1.Connection = veiculos.oCon;
            oCmd1.CommandText = "APP..prospeccao_select_quantidade_disponivel";
            oCmd1.CommandType = CommandType.StoredProcedure;
            oCmd1.Parameters.Add("@vendedor", SqlDbType.VarChar).Value = ddlVendOrigem.SelectedValue;
            oCmd1.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEvento2.Value;
            SqlDataReader odr1 = oCmd1.ExecuteReader();
            if (odr1.Read())
                literalQtdeDisponivel.Text = odr1["qtde"].ToString();

            
        }
        catch { ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro ao carregar dados!')", true); }
        finally { veiculos.FecharConexao(); }
    }

}

public class TopProspectores
{
    public String vendedor { set; get; }
    public String equipe { set; get; }
    public int qtde { set; get; }
}
