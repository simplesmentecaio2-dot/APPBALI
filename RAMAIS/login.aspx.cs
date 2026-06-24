using System;

public partial class ramais_login : System.Web.UI.Page
{
    private const string SenhaRamais = "@bali2025";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && Session["ramais_auth"] != null)
        {
            Response.Redirect(ObterRetornoSeguro());
        }
    }

    protected void btnEntrar_Click(object sender, EventArgs e)
    {
        if (txtSenha.Text == SenhaRamais)
        {
            Session["ramais_auth"] = true;
            Response.Redirect(ObterRetornoSeguro());
            return;
        }

        pnlMensagem.Visible = true;
        litMensagem.Text = "Senha incorreta. Tente novamente.";
    }

    private string ObterRetornoSeguro()
    {
        string retorno = Request.QueryString["returnUrl"];

        if (String.IsNullOrWhiteSpace(retorno))
        {
            return "default.aspx";
        }

        retorno = Server.UrlDecode(retorno);

        if (retorno.IndexOf("://", StringComparison.OrdinalIgnoreCase) >= 0 || retorno.StartsWith("//"))
        {
            return "default.aspx";
        }

        return retorno;
    }
}
