using System;
using System.Web;
using System.Web.UI;

public partial class login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && Request.QueryString["sair"] == "1")
        {
            SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOGIN");
            Session.Clear();
            Session.Abandon();
        }

        if (!IsPostBack)
        {
            SessaoUnica.MostrarAvisoSessaoEncerrada(this);
        }
    }

    protected void LinkButton1_Click(object sender, EventArgs e)
    {
        string usuarioInformado = (txtUsuario.Value ?? "").Trim();
        string senhaInformada = (txtSenha.Value ?? "").Trim();

        if (usuarioInformado.Length == 0 || senhaInformada.Length == 0)
        {
            txtUsuario.Value = "";
            txtSenha.Value = "";
            txtUsuario.Focus();
            ExibirMensagem("Informe seu usu\u00e1rio e senha.");
            return;
        }

        App oLogin = new App();
        string usuario, tipo, email, ramal, celular, empresa;
        oLogin.login(usuarioInformado, senhaInformada, out usuario, out tipo, out email, out ramal, out celular, out empresa);

        if (usuario != "N")
        {
            Session["id"] = usuarioInformado;
            Session["usuario"] = usuario;
            Session["tipo"] = tipo;
            Session["email"] = email;
            Session["ramal"] = ramal;
            Session["celular"] = celular;
            Session["empresa"] = empresa;
            SessaoUnica.RegistrarLoginAtual();
            Response.Redirect(DestinoAposLogin(), false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        txtUsuario.Value = "";
        txtSenha.Value = "";
        txtUsuario.Focus();
        ExibirMensagem("Usu\u00e1rio ou senha inv\u00e1lida.");
    }

    private void ExibirMensagem(string mensagem)
    {
        string texto = HttpUtility.JavaScriptStringEncode(mensagem);
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), "alert('" + texto + "');", true);
    }

    private string DestinoAposLogin()
    {
        string voltar = Request.QueryString["voltar"];
        return UrlLocalSegura(voltar) ? voltar.Trim() : "default.aspx";
    }

    private bool UrlLocalSegura(string url)
    {
        if (String.IsNullOrWhiteSpace(url)) return false;

        url = url.Trim();
        if (url.StartsWith("http:", StringComparison.OrdinalIgnoreCase)) return false;
        if (url.StartsWith("https:", StringComparison.OrdinalIgnoreCase)) return false;
        if (url.StartsWith("//")) return false;
        if (url.IndexOf('\r') >= 0 || url.IndexOf('\n') >= 0) return false;

        return url.StartsWith("/", StringComparison.Ordinal)
            || url.StartsWith("./", StringComparison.Ordinal)
            || url.StartsWith("../", StringComparison.Ordinal);
    }
}
