using System;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class tecnologia_usuarios : System.Web.UI.Page
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

    protected void btnSalvar_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        string nome = txtNomeUsuario.Text.Trim();
        string email = txtEmail.Text.Trim();
        string senha = txtSenha.Text;
        string confirmacao = txtConfirmacao.Text;

        if (!IdentificadorUsuarioValido(email))
        {
            ExibirMensagem("Informe um login válido para o usuário.");
            return;
        }

        if (String.IsNullOrWhiteSpace(nome) || String.IsNullOrWhiteSpace(email) || String.IsNullOrWhiteSpace(senha) || String.IsNullOrWhiteSpace(confirmacao))
        {
            ExibirMensagem("Preencha nome, e-mail, senha e confirmação.");
            return;
        }

        if (ddlTipo.SelectedIndex <= 0)
        {
            ExibirMensagem("Selecione o tipo do usuário.");
            return;
        }

        if (!SenhaValida(senha, confirmacao))
        {
            ExibirMensagem("A senha e a confirmação devem ser iguais e conter no mínimo 4 caracteres.");
            return;
        }

        string ativo = rbtnAtivo.Checked ? "S" : "N";
        string obs;
        App oApp = new App();
        oApp.InsertUsuario(email, nome, senha, ativo, ddlTipo.SelectedItem.Text.Trim(), out obs);

        if (OperacaoSucesso(obs, "cadastrado"))
        {
            foreach (ListItem item in CheckBoxListSistemas.Items)
            {
                if (item.Selected)
                {
                    oApp.InsertUsuarioSistema(email, Convert.ToInt16(item.Value));
                }
            }

            LimparCadastro();
            gvConsultaUsuarios.DataBind();
            TabContainerUsuarios.ActiveTabIndex = 0;
        }

        ExibirMensagem(NormalizarMensagem(obs));
    }

    protected void gvConsultaUsuarios_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        if (gvConsultaUsuarios.SelectedDataKey == null)
        {
            ExibirMensagem("Selecione um usuário válido para alterar.");
            return;
        }

        string idUsuario = HttpUtility.HtmlDecode(Convert.ToString(gvConsultaUsuarios.SelectedDataKey.Value)).Trim();
        if (String.IsNullOrWhiteSpace(idUsuario))
        {
            ExibirMensagem("Não foi possível identificar o usuário selecionado.");
            return;
        }

        try
        {
            CarregarUsuario(idUsuario);
            TabContainerUsuarios.ActiveTabIndex = 2;
        }
        catch (Exception)
        {
            ExibirMensagem("Não foi possível carregar este usuário. Atualize a consulta e tente novamente.");
        }
    }

    protected void btnDesativarSelecionados_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        int selecionados = 0;
        int desativados = 0;
        int jaInativos = 0;
        int protegidos = 0;
        int falhas = 0;
        StringBuilder detalhesFalhas = new StringBuilder();
        string usuarioAtual = Convert.ToString(Session["id"]).Trim();
        App oApp = new App();

        foreach (GridViewRow row in gvConsultaUsuarios.Rows)
        {
            if (row.RowType != DataControlRowType.DataRow)
            {
                continue;
            }

            CheckBox check = row.FindControl("chkSelecionarUsuario") as CheckBox;
            if (check == null || !check.Checked)
            {
                continue;
            }

            selecionados++;
            string login = ValorDataKey(row, "Login");
            string nome = ValorDataKey(row, "Nome");
            string tipo = ValorDataKey(row, "tipo");
            string ativoAtual = ValorDataKey(row, "Ativo");

            if (!IdentificadorUsuarioValido(login))
            {
                falhas++;
                AdicionarFalha(detalhesFalhas, login, "identificador vazio ou inválido");
                continue;
            }

            if (String.Equals(login, usuarioAtual, StringComparison.OrdinalIgnoreCase))
            {
                protegidos++;
                continue;
            }

            if (UsuarioJaInativo(ativoAtual))
            {
                jaInativos++;
                continue;
            }

            try
            {
                string obs;
                oApp.UpdateUsuario(login, nome, "N", tipo, out obs);
                if (OperacaoSucesso(obs, "alterado"))
                {
                    desativados++;
                }
                else
                {
                    falhas++;
                    AdicionarFalha(detalhesFalhas, login, NormalizarMensagem(obs));
                }
            }
            catch (Exception ex)
            {
                falhas++;
                AdicionarFalha(detalhesFalhas, login, ex.Message);
            }
        }

        gvConsultaUsuarios.DataBind();
        TabContainerUsuarios.ActiveTabIndex = 0;
        ExibirMensagem(MontarResumoInativacao(selecionados, desativados, jaInativos, protegidos, falhas, detalhesFalhas.ToString()));
    }

    protected void btnAlterar_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        string nome = txtNomeAlterar.Text.Trim();
        string email = txtEmailAlterar.Text.Trim();

        if (!IdentificadorUsuarioValido(email))
        {
            ExibirMensagem("Selecione um usuário válido na aba Consulta antes de alterar.");
            return;
        }

        if (String.IsNullOrWhiteSpace(nome))
        {
            ExibirMensagem("Informe o nome do usuário.");
            return;
        }

        if (ddlTipoAlterar.SelectedIndex <= 0)
        {
            ExibirMensagem("Selecione o tipo do usuário.");
            return;
        }

        string ativo = rbtnAtivoAlterar.Checked ? "S" : "N";
        string obs;
        App oApp = new App();
        oApp.UpdateUsuario(email, nome, ativo, ddlTipoAlterar.SelectedItem.Text.Trim(), out obs);

        if (OperacaoSucesso(obs, "alterado"))
        {
            foreach (ListItem item in CheckBoxListSistemasAlterar.Items)
            {
                int condicao = item.Selected ? 1 : 0;
                oApp.UpdateUsuarioSistema(email, Convert.ToInt16(item.Value), condicao);
            }

            ddlUsuarioSistema.DataBind();
            ddlSistemaperfil.DataBind();
            dlPerfilSistemas.DataBind();
            gvConsultaUsuarios.DataBind();
            LimparSenhaAlterar();
        }

        ExibirMensagem(NormalizarMensagem(obs));
    }

    protected void btnAlterarPerfil_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        string email = txtEmailAlterarPerfil.Text.Trim();
        int idSistema;

        if (!IdentificadorUsuarioValido(email))
        {
            ExibirMensagem("Selecione um usuário válido na aba Consulta antes de alterar o perfil.");
            return;
        }

        if (!Int32.TryParse(ddlUsuarioSistema.SelectedValue, out idSistema) || idSistema <= 0)
        {
            ExibirMensagem("Selecione um sistema válido para alterar o perfil.");
            return;
        }

        if (ddlSistemaperfil.SelectedItem == null || String.IsNullOrWhiteSpace(ddlSistemaperfil.SelectedItem.Text))
        {
            ExibirMensagem("Selecione um perfil válido para o sistema.");
            return;
        }

        App oApp = new App();
        oApp.UpdateUsuarioPerfil(email, idSistema, ddlSistemaperfil.SelectedItem.Text.Trim());
        dlPerfilSistemas.DataBind();
        ExibirMensagem("Perfil atualizado com sucesso.");
    }

    protected void btnAlterarSenha_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        string email = txtEmailAlterar.Text.Trim();
        string senha = txtSenhaAlterar.Text;
        string confirmacao = txtConfirmacaoAlterar.Text;

        if (!IdentificadorUsuarioValido(email))
        {
            ExibirMensagem("Selecione um usuário válido na aba Consulta antes de alterar a senha.");
            return;
        }

        if (!SenhaValida(senha, confirmacao))
        {
            ExibirMensagem("A senha e a confirmação devem ser iguais e conter no mínimo 4 caracteres.");
            return;
        }

        App oApp = new App();
        string obs;
        oApp.UpdateUsuarioSenha(email, senha, out obs);
        LimparSenhaAlterar();
        ExibirMensagem(NormalizarMensagem(obs));
    }

    private void CarregarUsuario(string idUsuario)
    {
        ddlSistemaperfil.Items.Clear();
        CheckBoxListSistemasAlterar.DataBind();
        CheckBoxListSistemasAlterar.ClearSelection();

        App oApp = new App();
        string usuario, senhaIgnorada, ativo, tipo;
        oApp.select_usuario(idUsuario, out usuario, out senhaIgnorada, out ativo, out tipo);

        txtNomeAlterar.Text = usuario;
        txtNomePerfil.Text = usuario;
        txtEmailAlterar.Text = idUsuario;
        txtEmailAlterarPerfil.Text = idUsuario;
        LimparSenhaAlterar();
        SelecionarItem(ddlTipoAlterar, tipo);

        rbtnAtivoAlterar.Checked = ativo == "S";
        rbtnInativoAlterar.Checked = ativo != "S";

        foreach (ListItem item in CheckBoxListSistemasAlterar.Items)
        {
            int sistema = 0;
            oApp.select_sistema_usuario_alterar(idUsuario, Convert.ToInt16(item.Value), out sistema);
            item.Selected = sistema == 1;
        }

        ddlUsuarioSistema.DataBind();
        ddlSistemaperfil.DataBind();
        dlPerfilSistemas.DataBind();
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

    private bool IdentificadorUsuarioValido(string identificador)
    {
        if (String.IsNullOrWhiteSpace(identificador))
        {
            return false;
        }

        string valor = identificador.Trim();
        return valor.Length <= 120
            && valor.IndexOf('<') < 0
            && valor.IndexOf('>') < 0
            && valor.IndexOf('"') < 0
            && valor.IndexOf('\'') < 0;
    }

    private bool SenhaValida(string senha, string confirmacao)
    {
        return senha == confirmacao && !String.IsNullOrWhiteSpace(senha) && senha.Length >= 4;
    }

    private bool OperacaoSucesso(string mensagem, string palavra)
    {
        return !String.IsNullOrWhiteSpace(mensagem)
            && mensagem.IndexOf(palavra, StringComparison.OrdinalIgnoreCase) >= 0
            && mensagem.IndexOf("já", StringComparison.OrdinalIgnoreCase) < 0
            && mensagem.IndexOf("erro", StringComparison.OrdinalIgnoreCase) < 0;
    }

    private string NormalizarMensagem(string mensagem)
    {
        if (String.IsNullOrWhiteSpace(mensagem))
        {
            return "Operação finalizada.";
        }

        return mensagem
            .Replace("suscesso", "sucesso")
            .Replace("Suscesso", "Sucesso")
            .Trim();
    }

    private void SelecionarItem(DropDownList lista, string valor)
    {
        lista.ClearSelection();
        foreach (ListItem item in lista.Items)
        {
            if (String.Equals(item.Text.Trim(), Convert.ToString(valor).Trim(), StringComparison.OrdinalIgnoreCase))
            {
                item.Selected = true;
                return;
            }
        }
    }

    private void LimparCadastro()
    {
        txtNomeUsuario.Text = "";
        txtEmail.Text = "";
        txtSenha.Text = "";
        txtConfirmacao.Text = "";
        CheckBoxListSistemas.ClearSelection();
        ddlTipo.ClearSelection();
        rbtnAtivo.Checked = true;
        rbtnInativo.Checked = false;
    }

    private void LimparSenhaAlterar()
    {
        txtSenhaAlterar.Text = "";
        txtConfirmacaoAlterar.Text = "";
        txtSenhaAlterar.Attributes["value"] = "";
        txtConfirmacaoAlterar.Attributes["value"] = "";
    }

    private string ValorDataKey(GridViewRow row, string campo)
    {
        if (gvConsultaUsuarios.DataKeys == null || row.RowIndex < 0 || row.RowIndex >= gvConsultaUsuarios.DataKeys.Count)
        {
            return "";
        }

        object valor = gvConsultaUsuarios.DataKeys[row.RowIndex].Values[campo];
        return HttpUtility.HtmlDecode(Convert.ToString(valor)).Trim();
    }

    private bool UsuarioJaInativo(string ativo)
    {
        string valor = RemoverAcentos(Convert.ToString(ativo)).Trim().ToUpperInvariant();
        return valor == "N"
            || valor == "NAO"
            || valor == "INATIVO"
            || valor == "0"
            || valor == "FALSE";
    }

    private void AdicionarFalha(StringBuilder detalhes, string login, string motivo)
    {
        if (detalhes.Length > 0)
        {
            detalhes.Append(Environment.NewLine);
        }

        detalhes.Append(String.IsNullOrWhiteSpace(login) ? "Usuário sem login" : login);
        detalhes.Append(": ");
        detalhes.Append(String.IsNullOrWhiteSpace(motivo) ? "não foi possível inativar" : motivo);
    }

    private string MontarResumoInativacao(int selecionados, int desativados, int jaInativos, int protegidos, int falhas, string detalhesFalhas)
    {
        if (selecionados == 0)
        {
            return "Selecione pelo menos um usuário para inativar.";
        }

        StringBuilder resumo = new StringBuilder();
        resumo.Append(desativados);
        resumo.Append(" usuário(s) inativado(s) com sucesso.");

        if (jaInativos > 0)
        {
            resumo.Append(Environment.NewLine);
            resumo.Append(jaInativos);
            resumo.Append(" usuário(s) já estavam inativos.");
        }

        if (protegidos > 0)
        {
            resumo.Append(Environment.NewLine);
            resumo.Append(protegidos);
            resumo.Append(" registro(s) ignorado(s) para proteger o usuário logado.");
        }

        if (falhas > 0)
        {
            resumo.Append(Environment.NewLine);
            resumo.Append(falhas);
            resumo.Append(" usuário(s) não foram inativados.");
            if (!String.IsNullOrWhiteSpace(detalhesFalhas))
            {
                resumo.Append(Environment.NewLine);
                resumo.Append(detalhesFalhas);
            }
        }

        return resumo.ToString();
    }

    private string RemoverAcentos(string texto)
    {
        if (String.IsNullOrEmpty(texto))
        {
            return "";
        }

        string normalizado = texto.Normalize(NormalizationForm.FormD);
        StringBuilder sb = new StringBuilder();
        foreach (char c in normalizado)
        {
            if (System.Globalization.CharUnicodeInfo.GetUnicodeCategory(c) != System.Globalization.UnicodeCategory.NonSpacingMark)
            {
                sb.Append(c);
            }
        }

        return sb.ToString().Normalize(NormalizationForm.FormC);
    }

    private void ExibirMensagem(string mensagem)
    {
        string segura = EscaparUnicodeJavascript(HttpUtility.JavaScriptStringEncode(mensagem));
        ScriptManager.RegisterStartupScript(this, GetType(), "mensagemTecnologia", "alert('" + segura + "');", true);
    }

    private string EscaparUnicodeJavascript(string texto)
    {
        if (String.IsNullOrEmpty(texto))
        {
            return "";
        }

        StringBuilder sb = new StringBuilder(texto.Length);
        foreach (char c in texto)
        {
            if (c > 127)
            {
                sb.Append("\\u");
                sb.Append(((int)c).ToString("x4"));
            }
            else
            {
                sb.Append(c);
            }
        }

        return sb.ToString();
    }
}
