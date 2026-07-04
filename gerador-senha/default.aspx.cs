using System;
using System.Configuration;
using System.Net;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

public partial class gerador_senha_default : System.Web.UI.Page
{
    private const int TamanhoSenha = 12;
    private const string Maiusculas = "ABCDEFGHJKLMNPQRSTUVWXYZ";
    private const string Minusculas = "abcdefghijkmnopqrstuvwxyz";
    private const string Numeros = "23456789";
    private const string Especiais = "*@";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        lblUsuario.Text = Convert.ToString(Session["usuario"]);
        lblCodigo.Text = Session["usuario_codigo"] == null ? "-" : Convert.ToString(Session["usuario_codigo"]);
    }

    protected void GerarSenha_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        MailAddress destinatario;
        if (!EmailValido(txtEmail.Text, out destinatario))
        {
            ExibirMensagem("Informe um e-mail v\u00e1lido para receber a senha.", true);
            txtEmail.Focus();
            return;
        }

        try
        {
            string senha = CriarSenha();
            EnviarEmail(destinatario, senha);
            txtEmail.Text = "";
            ExibirMensagem("Senha gerada e enviada para " + destinatario.Address + ".", false);
        }
        catch (Exception ex)
        {
            ExibirMensagem("N\u00e3o foi poss\u00edvel gerar ou enviar a senha agora. Detalhe: " + ex.Message, true);
        }
    }

    private string CriarSenha()
    {
        StringBuilder senha = new StringBuilder(TamanhoSenha);
        senha.Append(Sortear(Maiusculas));
        senha.Append(Sortear(Minusculas));
        senha.Append(Sortear(Numeros));
        senha.Append(Sortear(Especiais));

        string todos = Maiusculas + Minusculas + Numeros + Especiais;
        while (senha.Length < TamanhoSenha)
        {
            senha.Append(Sortear(todos));
        }

        return Embaralhar(senha.ToString());
    }

    private char Sortear(string caracteres)
    {
        byte[] buffer = new byte[4];
        using (RandomNumberGenerator rng = RandomNumberGenerator.Create())
        {
            rng.GetBytes(buffer);
        }

        uint valor = BitConverter.ToUInt32(buffer, 0);
        return caracteres[(int)(valor % (uint)caracteres.Length)];
    }

    private string Embaralhar(string valor)
    {
        char[] caracteres = valor.ToCharArray();
        using (RandomNumberGenerator rng = RandomNumberGenerator.Create())
        {
            for (int i = caracteres.Length - 1; i > 0; i--)
            {
                byte[] buffer = new byte[4];
                rng.GetBytes(buffer);
                int j = (int)(BitConverter.ToUInt32(buffer, 0) % (uint)(i + 1));
                char temp = caracteres[i];
                caracteres[i] = caracteres[j];
                caracteres[j] = temp;
            }
        }

        return new string(caracteres);
    }

    private void EnviarEmail(MailAddress destinatario, string senha)
    {
        string host = Config("GeradorSenha:SmtpHost", "smtp.skymail.net.br");
        int porta = ConfigInt("GeradorSenha:SmtpPort", 587);
        string usuario = Config("GeradorSenha:SmtpUser", "gerasenha@bali.com.br");
        string senhaSmtp = Config("GeradorSenha:SmtpPassword", "");
        string remetente = Config("GeradorSenha:From", usuario);
        bool ssl = ConfigBool("GeradorSenha:SmtpSsl", false);

        if (String.IsNullOrWhiteSpace(senhaSmtp))
        {
            throw new InvalidOperationException("SMTP do gerador de senha n\u00e3o configurado.");
        }

        using (MailMessage message = new MailMessage())
        {
            message.To.Add(destinatario);
            message.Subject = "Senha tempor\u00e1ria | APP Bali";
            message.From = new MailAddress(remetente, "Tecnologia Grupo Bali");
            message.IsBodyHtml = true;
            message.BodyEncoding = Encoding.UTF8;
            message.SubjectEncoding = Encoding.UTF8;
            message.Body = MontarCorpoEmail(senha);

            using (SmtpClient smtp = new SmtpClient(host, porta))
            {
                smtp.EnableSsl = ssl;
                smtp.Credentials = new NetworkCredential(usuario, senhaSmtp);
                smtp.Send(message);
            }
        }
    }

    private string MontarCorpoEmail(string senha)
    {
        string senhaSegura = HttpUtility.HtmlEncode(senha);
        return @"
<div style=""font-family:Arial,Helvetica,sans-serif;color:#17202a;font-size:14px;line-height:1.5"">
  <p>Ol&aacute;,</p>
  <p>Sua senha tempor&aacute;ria foi gerada pela equipe de Tecnologia do Grupo Bali.</p>
  <p style=""font-size:20px;margin:18px 0""><strong>" + senhaSegura + @"</strong></p>
  <p>Use esta senha apenas no primeiro acesso e altere assim que poss&iacute;vel.</p>
  <p style=""color:#667085;font-size:12px"">TI - GRUPO BALI | (61) 3362-6208 | ti@bali.com.br</p>
</div>";
    }

    private bool EmailValido(string email, out MailAddress endereco)
    {
        endereco = null;
        email = (email ?? "").Trim();
        if (email.Length == 0 || email.Length > 180) return false;

        try
        {
            endereco = new MailAddress(email);
            return String.Equals(endereco.Address, email, StringComparison.OrdinalIgnoreCase);
        }
        catch
        {
            return false;
        }
    }

    private void ExibirMensagem(string mensagem, bool erro)
    {
        pnlMensagem.Visible = true;
        pnlMensagem.CssClass = erro
            ? "tech-alert password-generator-alert is-error"
            : "tech-alert password-generator-alert is-success";
        litMensagem.Text = Server.HtmlEncode(mensagem);
    }

    private bool UsuarioTecnologiaValido()
    {
        if (Session["id"] == null)
        {
            RedirecionarLogin();
            return false;
        }

        App app = new App();
        int permissao = app.verificaPermissaoSistema(Convert.ToString(Session["id"]), "TECNOLOGIA");
        if (permissao != 1)
        {
            RedirecionarLogin();
            return false;
        }

        return true;
    }

    private void RedirecionarLogin()
    {
        Response.Clear();
        Response.Redirect("../login.aspx?voltar=/gerador-senha/default.aspx", false);
        Response.SuppressContent = true;
        Context.ApplicationInstance.CompleteRequest();
    }

    private string Config(string chave, string padrao)
    {
        string valorAmbiente = Environment.GetEnvironmentVariable("APPBALI_" + Regex.Replace(chave.ToUpperInvariant(), "[^A-Z0-9]+", "_"));
        if (!String.IsNullOrWhiteSpace(valorAmbiente))
        {
            return valorAmbiente.Trim();
        }

        string valor = ConfigurationManager.AppSettings[chave];
        return String.IsNullOrWhiteSpace(valor) ? padrao : valor.Trim();
    }

    private int ConfigInt(string chave, int padrao)
    {
        int valor;
        return Int32.TryParse(Config(chave, ""), out valor) ? valor : padrao;
    }

    private bool ConfigBool(string chave, bool padrao)
    {
        bool valor;
        return Boolean.TryParse(Config(chave, ""), out valor) ? valor : padrao;
    }
}
