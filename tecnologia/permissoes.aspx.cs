using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI.WebControls;

public partial class tecnologia_permissoes : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        AppPermissoes.RegistrarUsuarioAtual(HttpContext.Current);

        lblUsuario.Text = Convert.ToString(Session["usuario"]);
        lblCodigo.Text = Session["usuario_codigo"] == null ? "-" : Convert.ToString(Session["usuario_codigo"]);

        if (!IsPostBack)
        {
            CarregarTela();
        }
    }

    protected void btnSalvarRegra_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        int idUsuarioLocal;
        if (!Int32.TryParse(ddlUsuarioLocal.SelectedValue, out idUsuarioLocal) || idUsuarioLocal <= 0)
        {
            ExibirMensagem("Selecione um usu\u00e1rio para aplicar a regra.");
            return;
        }

        string recurso = txtRecursoManual.Text.Trim();
        if (recurso.Length == 0)
        {
            recurso = ddlRecurso.SelectedValue;
        }

        recurso = AppPermissoes.NormalizarRecurso(recurso);
        if (recurso.Length == 0)
        {
            ExibirMensagem("Informe um recurso v\u00e1lido.");
            return;
        }

        bool bloquear = ddlTipoRegra.SelectedValue == "bloquear";
        if (bloquear && UsuarioSelecionadoEhAtual(idUsuarioLocal) && String.Equals(recurso, "/tecnologia/permissoes.aspx", StringComparison.OrdinalIgnoreCase))
        {
            ExibirMensagem("Por seguran\u00e7a, n\u00e3o bloqueei seu pr\u00f3prio acesso \u00e0 tela de permiss\u00f5es.");
            return;
        }

        try
        {
            AppPermissoes.SalvarRegra(idUsuarioLocal, recurso, ddlAcao.SelectedValue, bloquear, txtMotivo.Text, HttpContext.Current);
            txtMotivo.Text = "";
            txtRecursoManual.Text = "";
            ExibirMensagem(bloquear ? "Bloqueio salvo com sucesso." : "Libera\u00e7\u00e3o salva com sucesso.");
            CarregarTela();
        }
        catch (Exception ex)
        {
            ExibirMensagem("N\u00e3o foi poss\u00edvel salvar a regra: " + ex.Message);
        }
    }

    protected void btnAtualizar_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        CarregarTela();
        ExibirMensagem("Tela atualizada.");
    }

    protected void rptPermissoes_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        if (e.CommandName != "remover")
        {
            return;
        }

        int idPermissao;
        if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out idPermissao) || idPermissao <= 0)
        {
            ExibirMensagem("Regra inv\u00e1lida.");
            return;
        }

        try
        {
            AppPermissoes.RemoverRegra(idPermissao, HttpContext.Current);
            ExibirMensagem("Regra removida. O acesso volta ao padr\u00e3o liberado.");
            CarregarTela();
        }
        catch (Exception ex)
        {
            ExibirMensagem("N\u00e3o foi poss\u00edvel remover a regra: " + ex.Message);
        }
    }

    private void CarregarTela()
    {
        CarregarUsuarios();
        CarregarResumo();
        CarregarPermissoes();
        CarregarAuditoria();
    }

    private void CarregarUsuarios()
    {
        DataTable usuarios = Consultar(@"
SELECT
    id_usuario_local,
    LTRIM(RTRIM(
        COALESCE(NULLIF(usuario_nome, N''), N'Usuário sem nome')
        + N' | '
        + COALESCE(NULLIF(usuario_id, N''), N'login sem id')
        + CASE WHEN COALESCE(NULLIF(usuario_codigo, N''), N'') <> N'' THEN N' | cód. ' + usuario_codigo ELSE N'' END
    )) AS texto
FROM dbo.app_usuario_local WITH (READPAST)
ORDER BY COALESCE(NULLIF(usuario_nome, N''), usuario_id), usuario_id;");

        ddlUsuarioLocal.DataSource = usuarios;
        ddlUsuarioLocal.DataTextField = "texto";
        ddlUsuarioLocal.DataValueField = "id_usuario_local";
        ddlUsuarioLocal.DataBind();

        if (ddlUsuarioLocal.Items.Count == 0)
        {
            ddlUsuarioLocal.Items.Add(new ListItem("Nenhum usu\u00e1rio espelhado ainda", "0"));
        }
    }

    private void CarregarResumo()
    {
        DataTable resumo = Consultar(@"
SELECT
    (SELECT COUNT(1) FROM dbo.app_usuario_local) AS usuarios,
    (SELECT COUNT(1) FROM dbo.app_permissao_usuario WHERE ativo = 1 AND bloqueado = 1) AS bloqueios,
    (SELECT COUNT(1) FROM dbo.app_permissao_usuario WHERE ativo = 1 AND permitido = 1 AND bloqueado = 0) AS liberacoes,
    (SELECT COUNT(1) FROM dbo.app_permissao_auditoria WHERE evento = N'ACESSO_NEGADO' AND criado_em >= DATEADD(DAY, -7, SYSDATETIME())) AS negados;");

        if (resumo.Rows.Count == 0)
        {
            litUsuariosLocais.Text = "0";
            litBloqueiosAtivos.Text = "0";
            litLiberacoesAtivas.Text = "0";
            litAcessosNegados.Text = "0";
            return;
        }

        DataRow row = resumo.Rows[0];
        litUsuariosLocais.Text = Numero(row["usuarios"]);
        litBloqueiosAtivos.Text = Numero(row["bloqueios"]);
        litLiberacoesAtivas.Text = Numero(row["liberacoes"]);
        litAcessosNegados.Text = Numero(row["negados"]);
    }

    private void CarregarPermissoes()
    {
        DataTable permissoes = Consultar(@"
SELECT TOP 200
    p.id_permissao,
    COALESCE(NULLIF(u.usuario_nome, N''), NULLIF(p.usuario_id, N''), N'Usuário') AS usuario_nome,
    COALESCE(p.usuario_codigo, u.usuario_codigo) AS usuario_codigo,
    COALESCE(p.usuario_id, u.usuario_id) AS usuario_id,
    p.recurso,
    p.acao,
    p.permitido,
    p.bloqueado,
    p.motivo,
    p.atualizado_por,
    p.atualizado_em
FROM dbo.app_permissao_usuario p WITH (READPAST)
LEFT JOIN dbo.app_usuario_local u WITH (READPAST) ON u.id_usuario_local = p.id_usuario_local
WHERE p.ativo = 1
ORDER BY p.atualizado_em DESC, p.id_permissao DESC;");

        rptPermissoes.DataSource = permissoes;
        rptPermissoes.DataBind();
        pnlSemPermissoes.Visible = permissoes.Rows.Count == 0;
    }

    private void CarregarAuditoria()
    {
        DataTable auditoria = Consultar(@"
SELECT TOP 80
    evento,
    COALESCE(NULLIF(usuario_nome, N''), NULLIF(usuario_id, N''), N'Usuário') AS usuario_nome,
    recurso,
    acao,
    detalhes,
    operador,
    ip,
    criado_em
FROM dbo.app_permissao_auditoria WITH (READPAST)
ORDER BY criado_em DESC, id_auditoria DESC;");

        rptAuditoria.DataSource = auditoria;
        rptAuditoria.DataBind();
        pnlSemAuditoria.Visible = auditoria.Rows.Count == 0;
    }

    private DataTable Consultar(string sql)
    {
        AppPermissoes.GarantirEstrutura();

        using (SqlConnection con = new SqlConnection(ConnectionString()))
        using (SqlCommand cmd = new SqlCommand(sql, con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = 20;
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    private bool UsuarioSelecionadoEhAtual(int idUsuarioLocal)
    {
        string codigoAtual = Convert.ToString(Session["usuario_codigo"]).Trim();
        string idAtual = Convert.ToString(Session["id"]).Trim();

        using (SqlConnection con = new SqlConnection(ConnectionString()))
        using (SqlCommand cmd = new SqlCommand(@"
SELECT COUNT(1)
FROM dbo.app_usuario_local
WHERE id_usuario_local = @id_usuario_local
  AND ((@codigo <> N'' AND usuario_codigo = @codigo)
       OR (@id <> N'' AND usuario_id = @id));", con))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = 15;
            cmd.Parameters.Add("@id_usuario_local", SqlDbType.Int).Value = idUsuarioLocal;
            cmd.Parameters.Add("@codigo", SqlDbType.NVarChar, 50).Value = codigoAtual == "0" ? "" : codigoAtual;
            cmd.Parameters.Add("@id", SqlDbType.NVarChar, 120).Value = idAtual;
            con.Open();
            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    protected string Html(object valor)
    {
        string texto = Convert.ToString(valor);
        return Server.HtmlEncode(String.IsNullOrWhiteSpace(texto) ? "-" : texto.Trim());
    }

    protected string DataHora(object valor)
    {
        if (valor == null || valor == DBNull.Value) return "-";
        DateTime data;
        if (!DateTime.TryParse(Convert.ToString(valor), out data)) return "-";
        return data.ToString("dd/MM/yyyy HH:mm:ss");
    }

    protected string IdentificadorUsuario(object codigo, object id)
    {
        string codigoTexto = Convert.ToString(codigo).Trim();
        string idTexto = Convert.ToString(id).Trim();
        if (codigoTexto.Length > 0 && idTexto.Length > 0)
        {
            return "C\u00f3d. " + codigoTexto + " | " + idTexto;
        }
        if (codigoTexto.Length > 0) return "C\u00f3d. " + codigoTexto;
        return idTexto.Length > 0 ? idTexto : "-";
    }

    protected string StatusRegra(object bloqueado)
    {
        return ValorBool(bloqueado) ? "Bloqueado" : "Liberado";
    }

    protected string CssRegra(object bloqueado)
    {
        return ValorBool(bloqueado) ? "permission-status is-blocked" : "permission-status is-allowed";
    }

    private bool ValorBool(object valor)
    {
        if (valor == null || valor == DBNull.Value) return false;
        return Convert.ToBoolean(valor);
    }

    private string Numero(object valor)
    {
        int numero;
        if (!Int32.TryParse(Convert.ToString(valor), out numero))
        {
            numero = 0;
        }
        return numero.ToString("N0");
    }

    private void ExibirMensagem(string mensagem)
    {
        pnlMensagem.Visible = true;
        litMensagem.Text = Server.HtmlEncode(mensagem);
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

    private string ConnectionString()
    {
        ConnectionStringSettings cfg = ConfigurationManager.ConnectionStrings["APPWFConnectionString"];
        if (cfg != null) return cfg.ConnectionString;
        return ConfigurationManager.ConnectionStrings["APPWFConnectionString2"].ConnectionString;
    }
}
