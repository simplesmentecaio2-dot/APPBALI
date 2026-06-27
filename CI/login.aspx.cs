using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;

public partial class ci_login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString["sair"] == "1")
        {
            RegistrarAuditoriaLoginCI("LOGOUT_CI", "Sessao encerrada pelo usuario.");
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

                RegistrarAuditoriaLoginCI("LOGIN_CI", "Login realizado com sucesso.");
                RedirecionarVolta();
                return;
            }
        }
        catch
        {
        }

        txtUsuario.Value = "";
        txtSenha.Value = "";
        RegistrarAuditoriaLoginCI("LOGIN_INVALIDO_CI", "Tentativa invalida para usuario informado: " + usuarioInformado, usuarioInformado);
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
            || url.StartsWith("auditoria.aspx", StringComparison.OrdinalIgnoreCase)
            || url.StartsWith("erros.aspx", StringComparison.OrdinalIgnoreCase)
            || url.StartsWith("/CI/", StringComparison.OrdinalIgnoreCase);
    }

    private void MostrarMensagem(string mensagem)
    {
        pnlMensagem.Visible = true;
        litMensagem.Text = Server.HtmlEncode(mensagem);
    }

    private void RegistrarAuditoriaLoginCI(string acao, string detalhe, string usuarioTentativa = "")
    {
        try
        {
            string connectionString = ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("dbo.ci_auditoria_registrar", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 30;
                cmd.Parameters.Add("@usuario_id", SqlDbType.NVarChar, 80).Value = ValorBanco(usuarioTentativa.Length > 0 ? usuarioTentativa : Convert.ToString(Session["id"] ?? ""));
                cmd.Parameters.Add("@usuario_nome", SqlDbType.NVarChar, 160).Value = ValorBanco(Convert.ToString(Session["usuario"] ?? usuarioTentativa));
                cmd.Parameters.Add("@usuario_tipo", SqlDbType.NVarChar, 80).Value = ValorBanco(Convert.ToString(Session["tipo"] ?? ""));
                cmd.Parameters.Add("@usuario_email", SqlDbType.NVarChar, 180).Value = ValorBanco(Convert.ToString(Session["email"] ?? ""));
                cmd.Parameters.Add("@empresa", SqlDbType.NVarChar, 120).Value = ValorBanco(Convert.ToString(Session["empresa"] ?? ""));
                cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 80).Value = ValorBanco(Request.UserHostAddress ?? "");
                cmd.Parameters.Add("@url", SqlDbType.NVarChar, 500).Value = ValorBanco(Request.RawUrl ?? "");
                cmd.Parameters.Add("@acao", SqlDbType.NVarChar, 80).Value = acao;
                cmd.Parameters.Add("@id_ci", SqlDbType.Int).Value = DBNull.Value;
                cmd.Parameters.Add("@codigo_ci", SqlDbType.NVarChar, 30).Value = DBNull.Value;
                cmd.Parameters.Add("@detalhe", SqlDbType.NVarChar).Value = ValorBanco(detalhe);
                cmd.Parameters.Add("@dados_antes", SqlDbType.NVarChar).Value = DBNull.Value;
                cmd.Parameters.Add("@dados_depois", SqlDbType.NVarChar).Value = DBNull.Value;
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
        }
    }

    private object ValorBanco(string valor)
    {
        string texto = (valor ?? "").Trim();
        return texto.Length == 0 ? (object)DBNull.Value : texto;
    }
}
