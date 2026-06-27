using System;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["usuario"] == null || Session["usuario"].ToString().Trim().Length == 0)
        {
            Response.Redirect("./login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        lblUsuario.Text = Session["usuario"].ToString();
        lblTipo.Text = Session["tipo"] == null ? "-" : Session["tipo"].ToString();
    }
}
