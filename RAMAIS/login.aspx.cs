using System;

public partial class ramais_login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("default.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    protected void btnEntrar_Click(object sender, EventArgs e)
    {
        Response.Redirect("default.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }
}
