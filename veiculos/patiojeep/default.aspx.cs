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
    private Veiculos vec = new Veiculos();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] != null)
        {
            usuarioLogado.Text = Session["usuario"].ToString();
        }
        else
        {
            Response.Redirect("./login.aspx");
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

}
