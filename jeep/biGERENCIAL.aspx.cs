using System;
using System.Web.UI;

public partial class veiculos_contrato : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //Veiculos ovec = new Veiculos();
        //string tabelaR; 
        //string tabelaVUR;
        //ovec.select_Tab_Consultadragon(out tabelaR);
        //ovec.select_Tab_ConsultaVUdragon(out tabelaVUR);

        //tabela = tabelaR;
        //tabelaVU = tabelaVUR ;

        if (Session["usuario"] == null || Session["usuario"].ToString().Equals(""))
        {
            Response.Redirect("./loginBI.aspx");
        }
        else
        {
            lblUsuario.Text = Session["usuario"].ToString();
        }
    }
    public string tabela;
    public string tabelaVU;
}


