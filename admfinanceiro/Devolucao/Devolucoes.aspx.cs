using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;

public partial class admfinanceiro_Devolucao_Devolucoes : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] != null)
        {
            lblUsuario.Text = Session["usuario"].ToString();
            lblTipo.Text = Session["tipo"].ToString();


        }
        else
        {
            Response.Redirect("../../Login.aspx");
        }
    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        if (txtDtInicial.Text != "" && txtDtFinal.Text != "")
        {
            try
            {
                AdmFinanceiro adm = new AdmFinanceiro();
                adm.select_Tab_Devolucao_Venda(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), out tabelaDevolucaoVenda);
                adm.select_Tab_Devolucao_Devolucao(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), out tabelaDevolucaoDevolucao);
                
                //btnExcel.Visible = true;
            }
            catch
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                   @"alert('Não foi possível processar a devolução agora.');", true);
            }
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                   @"alert('Preecha os campos!');", true);
        }
        


    }
    public string tabelaDevolucaoVenda;
    public string tabelaDevolucaoDevolucao;

   
}
