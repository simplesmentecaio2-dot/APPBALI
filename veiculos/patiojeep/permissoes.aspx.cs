using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class veiculos_patio_permissoes : System.Web.UI.Page
{
    private const string SenhaTela = "@CPD2020";
    private const string SessionLiberado = "patio_permissoes_liberado";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] == null)
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        usuarioLogado.Text = Html(Session["usuario"]);

        if (!IsPostBack)
        {
            AtualizarVisibilidade();
            if (TelaLiberada())
            {
                GarantirEstrutura();
                LimparFormulario();
                CarregarTela();
            }
        }
    }

    protected void btnDesbloquear_Click(object sender, EventArgs e)
    {
        if (!String.Equals(txtSenhaAcesso.Text, SenhaTela, StringComparison.Ordinal))
        {
            txtSenhaAcesso.Text = "";
            Session.Remove(SessionLiberado);
            AtualizarVisibilidade();
            MostrarMensagem("error", "Senha incorreta", "A senha informada n\u00e3o libera a tela de permiss\u00f5es.");
            return;
        }

        txtSenhaAcesso.Text = "";
        Session[SessionLiberado] = "s";
        AtualizarVisibilidade();
        GarantirEstrutura();
        LimparFormulario();
        CarregarTela();
        RegistrarAuditoria("ABRIR_TELA", "", null, null, null, null, "Tela de permiss\u00f5es liberada.");
        MostrarMensagem("success", "Tela liberada", "Permiss\u00f5es carregadas com seguran\u00e7a.");
    }

    protected void btnBloquearTela_Click(object sender, EventArgs e)
    {
        RegistrarAuditoria("BLOQUEAR_TELA", "", null, null, null, null, "Tela bloqueada manualmente.");
        Session.Remove(SessionLiberado);
        LimparFormulario();
        AtualizarVisibilidade();
        MostrarMensagem("info", "Tela bloqueada", "Informe a senha novamente para alterar permiss\u00f5es.");
    }

    protected void btnSalvar_Click(object sender, EventArgs e)
    {
        if (!GarantirLiberado()) return;

        string usuario = NormalizarUsuario(txtUsuario.Text);
        if (usuario.Length == 0)
        {
            MostrarMensagem("error", "Informe o usu\u00e1rio", "Digite exatamente o nome usado no login do p\u00e1tio.");
            txtUsuario.Focus();
            CarregarTela();
            return;
        }

        PermissaoInfo anterior = BuscarPermissao(usuario);
        PermissaoInfo novo = new PermissaoInfo
        {
            Usuario = usuario,
            Registrar = chkRegistrar.Checked,
            Transferir = chkTransferir.Checked
        };

        SalvarPermissao(usuario, novo.Registrar, novo.Transferir);
        RegistrarAuditoria("SALVAR", usuario, anterior.Registrar, novo.Registrar, anterior.Transferir, novo.Transferir, "Permiss\u00f5es atualizadas pela tela.");
        LimparCacheSeForUsuarioAtual(usuario);
        LimparFormulario();
        CarregarTela();
        MostrarMensagem("success", "Permiss\u00f5es salvas", "Usu\u00e1rio " + usuario + " atualizado com sucesso.");
    }

    protected void btnLimpar_Click(object sender, EventArgs e)
    {
        if (!GarantirLiberado()) return;

        LimparFormulario();
        CarregarTela();
        MostrarMensagem("info", "Formul\u00e1rio limpo", "Digite um usu\u00e1rio ou edite um registro da lista.");
    }

    protected void btnFiltrar_Click(object sender, EventArgs e)
    {
        if (!GarantirLiberado()) return;

        CarregarTela();
    }

    protected void gridPermissoes_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (!GarantirLiberado()) return;

        string usuario = NormalizarUsuario(Convert.ToString(e.CommandArgument));
        if (usuario.Length == 0)
        {
            MostrarMensagem("error", "Usu\u00e1rio inv\u00e1lido", "N\u00e3o foi poss\u00edvel identificar o usu\u00e1rio selecionado.");
            CarregarTela();
            return;
        }

        if (e.CommandName == "EditarUsuario")
        {
            CarregarUsuarioParaEdicao(usuario);
            CarregarTela();
            return;
        }

        if (e.CommandName == "RevogarUsuario")
        {
            PermissaoInfo anterior = BuscarPermissao(usuario);
            SalvarPermissao(usuario, false, false);
            RegistrarAuditoria("REVOGAR", usuario, anterior.Registrar, false, anterior.Transferir, false, "Todas as permiss\u00f5es foram revogadas.");
            LimparCacheSeForUsuarioAtual(usuario);
            LimparFormulario();
            CarregarTela();
            MostrarMensagem("success", "Permiss\u00f5es revogadas", "Usu\u00e1rio " + usuario + " ficou sem acessos de p\u00e1tio.");
        }
    }

    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Session.Abandon();
        Response.Redirect("./login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private bool TelaLiberada()
    {
        return Convert.ToString(Session[SessionLiberado]) == "s";
    }

    private bool GarantirLiberado()
    {
        if (TelaLiberada()) return true;

        AtualizarVisibilidade();
        MostrarMensagem("error", "Tela bloqueada", "Informe a senha de libera\u00e7\u00e3o antes de alterar permiss\u00f5es.");
        return false;
    }

    private void AtualizarVisibilidade()
    {
        bool liberada = TelaLiberada();
        pnlBloqueio.Visible = !liberada;
        pnlConteudo.Visible = liberada;
    }

    private void CarregarUsuarioParaEdicao(string usuario)
    {
        PermissaoInfo permissao = BuscarPermissao(usuario);
        txtUsuario.Text = permissao.Usuario;
        hfUsuarioOriginal.Value = permissao.Usuario;
        chkRegistrar.Checked = permissao.Registrar;
        chkTransferir.Checked = permissao.Transferir;
        MostrarMensagem("info", "Editando permiss\u00f5es", "Ajuste os acessos de " + permissao.Usuario + " e clique em Salvar.");
        txtUsuario.Focus();
    }

    private void SalvarPermissao(string usuario, bool registrar, bool transferir)
    {
        Jeep banco = new Jeep();
        SqlTransaction transacao = null;
        try
        {
            banco.Conexao2();
            transacao = banco.oCon2.BeginTransaction();

            SqlCommand limpar = new SqlCommand(@"
DELETE FROM dbo.veiculos_patio_usuario_acesso
WHERE UPPER(LTRIM(RTRIM(fun_cad))) = @usuario;", banco.oCon2, transacao);
            limpar.Parameters.Add("@usuario", SqlDbType.VarChar, 100).Value = usuario;
            limpar.ExecuteNonQuery();

            if (registrar)
            {
                InserirAcesso(banco.oCon2, transacao, usuario, 1);
            }

            if (transferir)
            {
                InserirAcesso(banco.oCon2, transacao, usuario, 2);
            }

            transacao.Commit();
        }
        catch
        {
            if (transacao != null) transacao.Rollback();
            throw;
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private void InserirAcesso(SqlConnection conexao, SqlTransaction transacao, string usuario, int acessoId)
    {
        SqlCommand inserir = new SqlCommand(@"
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.veiculos_patio_usuario_acesso
    WHERE UPPER(LTRIM(RTRIM(fun_cad))) = @usuario
      AND acesso_id = @acesso_id
)
BEGIN
    INSERT INTO dbo.veiculos_patio_usuario_acesso (fun_cad, acesso_id)
    VALUES (@fun_cad, @acesso_id);
END;", conexao, transacao);
        inserir.Parameters.Add("@usuario", SqlDbType.VarChar, 100).Value = usuario;
        inserir.Parameters.Add("@fun_cad", SqlDbType.VarChar, 100).Value = usuario;
        inserir.Parameters.Add("@acesso_id", SqlDbType.Int).Value = acessoId;
        inserir.ExecuteNonQuery();
    }

    private PermissaoInfo BuscarPermissao(string usuario)
    {
        PermissaoInfo permissao = new PermissaoInfo { Usuario = usuario };
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"
SELECT
    UPPER(LTRIM(RTRIM(fun_cad))) AS fun_cad,
    MAX(CASE WHEN acesso_id = 1 THEN 1 ELSE 0 END) AS registrar,
    MAX(CASE WHEN acesso_id = 2 THEN 1 ELSE 0 END) AS transferir
FROM dbo.veiculos_patio_usuario_acesso WITH (NOLOCK)
WHERE UPPER(LTRIM(RTRIM(fun_cad))) = @usuario
GROUP BY UPPER(LTRIM(RTRIM(fun_cad)));", banco.oCon2);
            cmd.Parameters.Add("@usuario", SqlDbType.VarChar, 100).Value = usuario;
            SqlDataReader reader = cmd.ExecuteReader();
            if (reader.Read())
            {
                permissao.Usuario = Convert.ToString(reader["fun_cad"]);
                permissao.Registrar = Convert.ToInt32(reader["registrar"]) == 1;
                permissao.Transferir = Convert.ToInt32(reader["transferir"]) == 1;
            }
        }
        finally
        {
            banco.FecharConexao2();
        }

        return permissao;
    }

    private DataTable ObterPermissoes()
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"
SELECT
    UPPER(LTRIM(RTRIM(fun_cad))) AS fun_cad,
    CONVERT(bit, MAX(CASE WHEN acesso_id = 1 THEN 1 ELSE 0 END)) AS registrar,
    CONVERT(bit, MAX(CASE WHEN acesso_id = 2 THEN 1 ELSE 0 END)) AS transferir
FROM dbo.veiculos_patio_usuario_acesso WITH (NOLOCK)
WHERE (@filtro = '' OR fun_cad LIKE @filtroLike)
GROUP BY UPPER(LTRIM(RTRIM(fun_cad)))
ORDER BY UPPER(LTRIM(RTRIM(fun_cad)));", banco.oCon2);
            string filtro = (txtFiltro.Text ?? "").Trim();
            cmd.Parameters.Add("@filtro", SqlDbType.VarChar, 100).Value = filtro;
            cmd.Parameters.Add("@filtroLike", SqlDbType.VarChar, 120).Value = "%" + filtro + "%";
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            adapter.Fill(tabela);
        }
        finally
        {
            banco.FecharConexao2();
        }

        return tabela;
    }

    private void CarregarTela()
    {
        DataTable permissoes = ObterPermissoes();
        gridPermissoes.DataSource = permissoes;
        gridPermissoes.DataBind();
        RenderizarResumo(permissoes);
        RenderizarLogs();
        AtualizarVisibilidade();
    }

    private void RenderizarResumo(DataTable permissoes)
    {
        int usuarios = permissoes.Rows.Count;
        int registrar = 0;
        int transferir = 0;

        foreach (DataRow row in permissoes.Rows)
        {
            if (Convert.ToBoolean(row["registrar"])) registrar++;
            if (Convert.ToBoolean(row["transferir"])) transferir++;
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"perm-summary\">");
        html.Append(CardResumo("Usu\u00e1rios", usuarios.ToString()));
        html.Append(CardResumo("Podem registrar", registrar.ToString()));
        html.Append(CardResumo("Podem transferir", transferir.ToString()));
        html.Append("</div>");
        litResumo.Text = html.ToString();
    }

    private string CardResumo(string titulo, string valor)
    {
        return "<div class=\"perm-card\"><small>" + Html(titulo) + "</small><strong>" + Html(valor) + "</strong></div>";
    }

    private void RenderizarLogs()
    {
        GarantirEstrutura();
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"
SELECT TOP 30 dt, acao, usuario_alvo, registrar_anterior, registrar_novo,
       transferir_anterior, transferir_novo, usuario_responsavel, detalhe, ip
FROM dbo.veiculos_patio_permissao_auditoria WITH (NOLOCK)
ORDER BY dt DESC, id DESC;", banco.oCon2);
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            adapter.Fill(tabela);
        }
        finally
        {
            banco.FecharConexao2();
        }

        if (tabela.Rows.Count == 0)
        {
            litLogs.Text = "<div class=\"alert alert-light mb-0\">Nenhuma altera&ccedil;&atilde;o registrada at&eacute; agora.</div>";
            return;
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"table table-striped table-hover perm-table\"><thead><tr>");
        html.Append("<th>Data</th><th>A&ccedil;&atilde;o</th><th>Usu&aacute;rio alterado</th><th>Antes</th><th>Depois</th><th>Respons&aacute;vel</th><th>Detalhe</th><th>IP</th>");
        html.Append("</tr></thead><tbody>");

        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td>" + Html(FormatarData(row["dt"])) + "</td>");
            html.Append("<td><span class=\"perm-badge perm-badge-on\">" + Html(row["acao"]) + "</span></td>");
            html.Append("<td>" + Html(row["usuario_alvo"]) + "</td>");
            html.Append("<td>" + Html(ResumoPermissao(row["registrar_anterior"], row["transferir_anterior"])) + "</td>");
            html.Append("<td>" + Html(ResumoPermissao(row["registrar_novo"], row["transferir_novo"])) + "</td>");
            html.Append("<td>" + Html(row["usuario_responsavel"]) + "</td>");
            html.Append("<td>" + Html(row["detalhe"]) + "</td>");
            html.Append("<td>" + Html(row["ip"]) + "</td>");
            html.Append("</tr>");
        }

        html.Append("</tbody></table>");
        litLogs.Text = html.ToString();
    }

    private string ResumoPermissao(object registrar, object transferir)
    {
        if (registrar == DBNull.Value && transferir == DBNull.Value)
        {
            return "-";
        }

        return "Registrar: " + (ToBool(registrar) ? "sim" : "n\u00e3o") + " | Transferir: " + (ToBool(transferir) ? "sim" : "n\u00e3o");
    }

    private bool ToBool(object valor)
    {
        if (valor == DBNull.Value || valor == null) return false;
        return Convert.ToBoolean(valor);
    }

    private void RegistrarAuditoria(string acao, string usuarioAlvo, bool? registrarAnterior, bool? registrarNovo, bool? transferirAnterior, bool? transferirNovo, string detalhe)
    {
        GarantirEstrutura();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"
INSERT INTO dbo.veiculos_patio_permissao_auditoria
(usuario_alvo, acao, registrar_anterior, registrar_novo, transferir_anterior, transferir_novo, usuario_responsavel, detalhe, ip)
VALUES
(@usuario_alvo, @acao, @registrar_anterior, @registrar_novo, @transferir_anterior, @transferir_novo, @usuario_responsavel, @detalhe, @ip);", banco.oCon2);
            cmd.Parameters.Add("@usuario_alvo", SqlDbType.VarChar, 100).Value = TextoOuDbNull(usuarioAlvo);
            cmd.Parameters.Add("@acao", SqlDbType.VarChar, 40).Value = acao;
            cmd.Parameters.Add("@registrar_anterior", SqlDbType.Bit).Value = registrarAnterior.HasValue ? (object)registrarAnterior.Value : DBNull.Value;
            cmd.Parameters.Add("@registrar_novo", SqlDbType.Bit).Value = registrarNovo.HasValue ? (object)registrarNovo.Value : DBNull.Value;
            cmd.Parameters.Add("@transferir_anterior", SqlDbType.Bit).Value = transferirAnterior.HasValue ? (object)transferirAnterior.Value : DBNull.Value;
            cmd.Parameters.Add("@transferir_novo", SqlDbType.Bit).Value = transferirNovo.HasValue ? (object)transferirNovo.Value : DBNull.Value;
            cmd.Parameters.Add("@usuario_responsavel", SqlDbType.VarChar, 100).Value = Convert.ToString(Session["usuario"]);
            cmd.Parameters.Add("@detalhe", SqlDbType.VarChar, 300).Value = detalhe;
            cmd.Parameters.Add("@ip", SqlDbType.VarChar, 60).Value = Request.UserHostAddress ?? "";
            cmd.ExecuteNonQuery();

            PatioJeepAuditoria.Registrar("PATIO_PERMISSAO_" + acao, Session["usuario"], usuarioAlvo, detalhe);
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private void GarantirEstrutura()
    {
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"
IF OBJECT_ID('dbo.veiculos_patio_permissao_auditoria', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.veiculos_patio_permissao_auditoria
    (
        id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_veiculos_patio_permissao_auditoria PRIMARY KEY,
        usuario_alvo varchar(100) NULL,
        acao varchar(40) NOT NULL,
        registrar_anterior bit NULL,
        registrar_novo bit NULL,
        transferir_anterior bit NULL,
        transferir_novo bit NULL,
        usuario_responsavel varchar(100) NULL,
        detalhe varchar(300) NULL,
        ip varchar(60) NULL,
        dt datetime NOT NULL CONSTRAINT DF_veiculos_patio_permissao_auditoria_dt DEFAULT (GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_usuario_acesso_fun_acesso' AND object_id = OBJECT_ID('dbo.veiculos_patio_usuario_acesso'))
BEGIN
    CREATE INDEX IX_veiculos_patio_usuario_acesso_fun_acesso ON dbo.veiculos_patio_usuario_acesso(fun_cad, acesso_id);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_permissao_auditoria_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_permissao_auditoria'))
BEGIN
    CREATE INDEX IX_veiculos_patio_permissao_auditoria_dt ON dbo.veiculos_patio_permissao_auditoria(dt DESC);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_permissao_auditoria_usuario_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_permissao_auditoria'))
BEGIN
    CREATE INDEX IX_veiculos_patio_permissao_auditoria_usuario_dt ON dbo.veiculos_patio_permissao_auditoria(usuario_alvo, dt DESC);
END;", banco.oCon2);
            cmd.ExecuteNonQuery();
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private void LimparFormulario()
    {
        hfUsuarioOriginal.Value = "";
        txtUsuario.Text = "";
        chkRegistrar.Checked = false;
        chkTransferir.Checked = false;
    }

    private void LimparCacheSeForUsuarioAtual(string usuario)
    {
        if (String.Equals(NormalizarUsuario(Convert.ToString(Session["usuario"])), usuario, StringComparison.OrdinalIgnoreCase))
        {
            Session.Remove("patio_acesso_1");
            Session.Remove("patio_acesso_2");
        }
    }

    private string NormalizarUsuario(string valor)
    {
        return (valor ?? "").Trim().ToUpperInvariant();
    }

    private object TextoOuDbNull(string valor)
    {
        valor = (valor ?? "").Trim();
        return valor.Length == 0 ? (object)DBNull.Value : valor;
    }

    private string FormatarData(object valor)
    {
        DateTime data;
        if (valor != null && DateTime.TryParse(valor.ToString(), out data))
        {
            return data.ToString("dd/MM/yyyy HH:mm");
        }

        return Convert.ToString(valor);
    }

    private void MostrarMensagem(string tipo, string titulo, string texto)
    {
        pnlMensagem.Visible = true;
        pnlMensagem.CssClass = "perm-message perm-message-" + tipo;
        iconeMensagem.Attributes["class"] = tipo == "success" ? "fa fa-check-circle" : tipo == "error" ? "fa fa-times-circle" : "fa fa-info-circle";
        litMensagemTitulo.Text = Html(titulo);
        litMensagemTexto.Text = Html(texto);

        string toastTipo = tipo == "success" ? "success" : tipo == "error" ? "error" : "info";
        ScriptManager.RegisterStartupScript(this, this.GetType(), Guid.NewGuid().ToString("N"), "if(window.patioToast){window.patioToast('" + Js(texto) + "','" + toastTipo + "');}", true);
    }

    private string Html(object valor)
    {
        return HttpUtility.HtmlEncode(Convert.ToString(valor));
    }

    private string Js(string valor)
    {
        return HttpUtility.JavaScriptStringEncode(valor ?? "");
    }

    private class PermissaoInfo
    {
        public string Usuario { get; set; }
        public bool Registrar { get; set; }
        public bool Transferir { get; set; }
    }
}
