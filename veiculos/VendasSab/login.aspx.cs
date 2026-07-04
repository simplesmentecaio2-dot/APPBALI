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

        if (Session["usuario"] != null && Session["usuario"] != "")
        {
            Response.Redirect("./");
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
                    Response.Redirect("./");
                }

                else
                {
                    txtUsuario.Value = "";
                    txtSenha.Value = "";
                    txtUsuario.Focus();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Usuário ou Senha Inválida!');", true);
                }
            }
            catch
            {
                txtUsuario.Value = "";
                txtSenha.Value = "";
                txtUsuario.Focus();
                executarJavaScript("alert('N\\u00e3o foi poss\\u00edvel entrar agora. Tente novamente.');");
            }
        }

    }
    private void executarJavaScript(String script)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", script, true);
    }
}
