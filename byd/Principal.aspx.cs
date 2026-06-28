using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class veiculos_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        lblIp.Text = Request.UserHostAddress;
        if (Session["usuario"] == null || Session["usuario"].ToString().Equals(""))
        {
            Response.Redirect("./loginAppcontrato.aspx");
        }
        else
        {
            lblUsuario.Text = Session["usuario"].ToString();
            lblPerfil.Text = Session["usuario_codigo"] == null ? "-" : Session["usuario_codigo"].ToString();
        }
    }
}
