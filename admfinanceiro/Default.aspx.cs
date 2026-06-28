using System;

public partial class admfinanceiro_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        lblIp.Text = Request.UserHostAddress;

        if (Session["usuario"] == null || Session["usuario"].ToString().Trim().Length == 0)
        {
            Response.Redirect("../login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        lblUsuario.Text = Session["usuario"].ToString();
        lblPerfil.Text = Session["usuario_codigo"] == null ? "-" : Session["usuario_codigo"].ToString();
    }
}
