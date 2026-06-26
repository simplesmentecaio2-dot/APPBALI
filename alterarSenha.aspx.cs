using System;
using System.Web;
using System.Web.UI;

public partial class alterarSenha : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtUsuario.Text = (Request.QueryString["usuario"] ?? "").Trim();
        }

        lnkVoltar.HRef = ObterVoltarSeguro();
    }

    protected void btnAlterar_Click(object sender, EventArgs e)
    {
        string usuario = (txtUsuario.Text ?? "").Trim();
        string senhaAtual = txtSenhaAtual.Text ?? "";
        string novaSenha = txtNovaSenha.Text ?? "";
        string confirmarSenha = txtConfirmarSenha.Text ?? "";

        if (usuario.Length == 0)
        {
            MostrarMensagem("Informe o usuário.", true);
            txtUsuario.Focus();
            return;
        }

        if (senhaAtual.Length == 0)
        {
            MostrarMensagem("Informe a senha atual.", true);
            txtSenhaAtual.Focus();
            return;
        }

        if (novaSenha.Length < 6)
        {
            MostrarMensagem("A nova senha deve ter pelo menos 6 caracteres.", true);
            txtNovaSenha.Focus();
            return;
        }

        if (!String.Equals(novaSenha, confirmarSenha, StringComparison.Ordinal))
        {
            MostrarMensagem("A confirmação da nova senha não confere.", true);
            txtConfirmarSenha.Focus();
            return;
        }

        try
        {
            App app = new App();
            string mensagem;
            bool alterou = app.AlterarSenhaLocal(usuario, senhaAtual, novaSenha, "alterarSenha.aspx", out mensagem);

            MostrarMensagem(mensagem, !alterou);
            if (alterou)
            {
                txtSenhaAtual.Text = "";
                txtNovaSenha.Text = "";
                txtConfirmarSenha.Text = "";
            }
        }
        catch (Exception ex)
        {
            MostrarMensagem("Não foi possível alterar a senha agora. Detalhe: " + ex.Message, true);
        }
    }

    private void MostrarMensagem(string mensagem, bool erro)
    {
        pnlMensagem.Visible = true;
        pnlMensagem.CssClass = erro ? "password-message error" : "password-message success";
        litMensagem.Text = HttpUtility.HtmlEncode(mensagem);
    }

    private string ObterVoltarSeguro()
    {
        string voltar = (Request.QueryString["voltar"] ?? "").Trim();
        if (voltar.Length == 0) return "/";
        if (!voltar.StartsWith("/", StringComparison.Ordinal)) return "/";
        if (voltar.StartsWith("//", StringComparison.Ordinal)) return "/";
        if (voltar.IndexOf("://", StringComparison.Ordinal) >= 0) return "/";
        return voltar;
    }
}
