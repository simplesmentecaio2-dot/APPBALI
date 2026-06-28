using System;

public partial class tecnologia_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        lblUsuario.Text = Convert.ToString(Session["usuario"]);
        lblTipo.Text = Session["usuario_codigo"] == null ? "-" : Convert.ToString(Session["usuario_codigo"]);
    }

    private bool UsuarioTecnologiaValido()
    {
        if (Session["id"] == null)
        {
            RedirecionarLogin();
            return false;
        }

        App oApp = new App();
        int permissao = oApp.verificaPermissaoSistema(Convert.ToString(Session["id"]), "TECNOLOGIA");
        if (permissao != 1)
        {
            RedirecionarLogin();
            return false;
        }

        return true;
    }

    private void RedirecionarLogin()
    {
        Response.Redirect("../Login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }
}
