using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class login : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)

    {
        SessaoUnica.MostrarAvisoSessaoEncerrada(this);

        if (!String.IsNullOrEmpty(Convert.ToString(Session["usuario"])))
        {
            Redirecionar(DestinoAposLogin());
        }
    }
    protected void btnLogin_Click(object sender, EventArgs e)
    {


    }
    protected void LinkButton1_Click(object sender, EventArgs e)
    {
        if (txtUsuario.Value != "" && txtSenha.Value != "")
        {
            App oLogin = new App();
            string usuario, tipo, email, ramal, celular, empresa;
            try
            {
                oLogin.login(txtUsuario.Value, txtSenha.Value, out usuario, out tipo, out email, out ramal, out celular, out empresa);
                if (usuario != "N")
                {
                    Session["id"] = txtUsuario.Value;
                    Session["usuario"] = usuario;
                    Session["tipo"] = tipo;
                    Session["email"] = email;
                    Session["ramal"] = ramal;
                    Session["celular"] = celular;
                    Session["empresa"] = empresa;
                    SessaoUnica.RegistrarLoginAtual();
                    Redirecionar(DestinoAposLogin());
                }

                else
                {
                    txtUsuario.Value = "";
                    txtSenha.Value = "";
                    txtUsuario.Focus();
                    ExibirMensagem("Usu\u00e1rio ou senha inv\u00e1lida.");
                }
            }
            catch
            {
                ExibirMensagem("N\u00e3o foi poss\u00edvel entrar agora. Tente novamente.");
            }
        }

    }

    private string DestinoAposLogin()
    {
        string voltar = Request.QueryString["voltar"];
        if (UrlLocalSegura(voltar))
        {
            return voltar.Trim();
        }

        return "./";
    }

    private bool UrlLocalSegura(string url)
    {
        if (String.IsNullOrWhiteSpace(url))
        {
            return false;
        }

        string destino = url.Trim();
        if (destino.IndexOf('\r') >= 0 || destino.IndexOf('\n') >= 0)
        {
            return false;
        }

        if (destino.IndexOf("login.aspx", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return false;
        }

        if (destino.StartsWith("http:", StringComparison.OrdinalIgnoreCase) ||
            destino.StartsWith("https:", StringComparison.OrdinalIgnoreCase) ||
            destino.StartsWith("//", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        return destino.StartsWith("./") || destino.StartsWith("/") || destino.StartsWith("?");
    }

    private void Redirecionar(string url)
    {
        Response.Redirect(url, false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void ExibirMensagem(string mensagem)
    {
        string texto = HttpUtility.JavaScriptStringEncode(mensagem);
        executarJavaScript("alert('" + texto + "');");
    }

    private void executarJavaScript(String script)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", script, true);
    }
}
