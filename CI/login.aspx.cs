using System;
using System.Web;

public partial class ci_login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString["sair"] == "1")
        {
            Session.Remove("ci_autenticado");
            Session.Remove("ci_login_em");
            MostrarMensagem("Sessao da CI encerrada com sucesso.");
            return;
        }

        if (!IsPostBack && UsuarioCIAutenticado())
        {
            RedirecionarVolta();
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        string usuarioInformado = (txtUsuario.Value ?? "").Trim();
        string senhaInformada = (txtSenha.Value ?? "").Trim();

        if (usuarioInformado.Length == 0 || senhaInformada.Length == 0)
        {
            MostrarMensagem("Informe usuario e senha para acessar a CI.");
            txtUsuario.Focus();
            return;
        }

        try
        {
            App login = new App();
            string usuario, tipo, email, ramal, celular, empresa;
            login.login(usuarioInformado, senhaInformada, out usuario, out tipo, out email, out ramal, out celular, out empresa);

            if (usuario != "N")
            {
                Session["id"] = usuarioInformado;
                Session["usuario"] = usuario;
                Session["tipo"] = tipo;
                Session["email"] = email;
                Session["ramal"] = ramal;
                Session["celular"] = celular;
                Session["empresa"] = empresa;
                Session["ci_autenticado"] = true;
                Session["ci_login_em"] = DateTime.Now;

                RedirecionarVolta();
                return;
            }
        }
        catch
        {
        }

        txtUsuario.Value = "";
        txtSenha.Value = "";
        MostrarMensagem("Usuario desativado ou senha invalida.");
        txtUsuario.Focus();
    }

    private bool UsuarioCIAutenticado()
    {
        return Session["ci_autenticado"] != null
            && Session["usuario"] != null
            && Convert.ToString(Session["usuario"]).Trim().Length > 0;
    }

    private void RedirecionarVolta()
    {
        string voltar = Request.QueryString["voltar"];
        if (!UrlLocalSegura(voltar))
        {
            voltar = "default.aspx?view=consulta";
        }

        Response.Redirect(voltar, false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private bool UrlLocalSegura(string url)
    {
        if (String.IsNullOrWhiteSpace(url)) return false;
        url = url.Trim();
        if (url.StartsWith("http:", StringComparison.OrdinalIgnoreCase)) return false;
        if (url.StartsWith("https:", StringComparison.OrdinalIgnoreCase)) return false;
        if (url.StartsWith("//")) return false;
        return url.StartsWith("default.aspx", StringComparison.OrdinalIgnoreCase)
            || url.StartsWith("print.aspx", StringComparison.OrdinalIgnoreCase)
            || url.StartsWith("erros.aspx", StringComparison.OrdinalIgnoreCase)
            || url.StartsWith("/CI/", StringComparison.OrdinalIgnoreCase);
    }

    private void MostrarMensagem(string mensagem)
    {
        pnlMensagem.Visible = true;
        litMensagem.Text = Server.HtmlEncode(mensagem);
    }
}
