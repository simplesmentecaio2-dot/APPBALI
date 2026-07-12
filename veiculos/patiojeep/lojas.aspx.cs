using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class veiculos_patio_lojas : System.Web.UI.Page
{
    private const string SenhaTela = "@CPD2020";
    private const string SessionLiberado = "patio_lojas_liberado";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] == null)
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        usuarioLogado.Text = Convert.ToString(Session["usuario"]);
        ConfigurarAntiAutoFill();
        AtualizarVisibilidade();
        GarantirTabelaAuditoria();

        if (!IsPostBack)
        {
            LimparFormulario();
            if (TelaLiberada())
            {
                CarregarTela();
            }
            else
            {
                LimparConteudoBloqueado();
            }
        }
    }

    protected void btnDesbloquear_Click(object sender, EventArgs e)
    {
        if (!String.Equals(txtSenhaAcesso.Text, SenhaTela, StringComparison.Ordinal))
        {
            PatioJeepAuditoria.Registrar("LOJA_SENHA_INVALIDA", Session["usuario"], "TELA", "Tentativa de abertura da tela de lojas.");
            txtSenhaAcesso.Text = "";
            Session.Remove(SessionLiberado);
            AtualizarVisibilidade();
            LimparConteudoBloqueado();
            MostrarMensagem("error", "Senha incorreta", "A senha informada n\u00e3o libera a manuten\u00e7\u00e3o de lojas.");
            return;
        }

        txtSenhaAcesso.Text = "";
        Session[SessionLiberado] = "s";
        AtualizarVisibilidade();
        LimparFormulario();
        CarregarTela();
        RegistrarAuditoria(0, "ABRIR_TELA", null, null, null, null, "Tela de lojas liberada.");
        MostrarMensagem("success", "Tela liberada", "Manuten\u00e7\u00e3o de lojas carregada com seguran\u00e7a.");
    }

    protected void btnBloquearTela_Click(object sender, EventArgs e)
    {
        RegistrarAuditoria(0, "BLOQUEAR_TELA", null, null, null, null, "Tela de lojas bloqueada manualmente.");
        Session.Remove(SessionLiberado);
        LimparFormulario();
        LimparConteudoBloqueado();
        AtualizarVisibilidade();
        MostrarMensagem("info", "Tela bloqueada", "Informe a senha novamente para alterar lojas.");
    }

    protected void btnSalvar_Click(object sender, EventArgs e)
    {
        if (!GarantirLiberado()) return;

        string descricao = NormalizarDescricao(txtDescricao.Text);
        if (descricao.Equals(""))
        {
            MostrarMensagem("error", "Informe a loja", "Digite o nome da loja antes de salvar.");
            txtDescricao.Focus();
            CarregarTela();
            return;
        }

        int lojaId;
        if (Int32.TryParse(hfLojaId.Value, out lojaId) && lojaId > 0)
        {
            AtualizarLoja(lojaId, descricao);
        }
        else
        {
            InserirLoja(descricao);
        }

        CarregarTela();
    }

    protected void btnCancelar_Click(object sender, EventArgs e)
    {
        if (!GarantirLiberado()) return;

        LimparFormulario();
        MostrarMensagem("info", "Edi\u00e7\u00e3o cancelada", "O formul\u00e1rio foi limpo para um novo cadastro.");
        CarregarTela();
    }

    protected void btnNovo_Click(object sender, EventArgs e)
    {
        if (!GarantirLiberado()) return;

        LimparFormulario();
        MostrarMensagem("info", "Nova loja", "Digite o nome da loja e clique em Salvar.");
        CarregarTela();
    }

    protected void btnFiltrar_Click(object sender, EventArgs e)
    {
        if (!GarantirLiberado()) return;

        CarregarTela();
    }

    protected void gridLojas_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (!GarantirLiberado()) return;

        int lojaId;
        if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out lojaId))
        {
            MostrarMensagem("error", "A\u00e7\u00e3o inv\u00e1lida", "N\u00e3o foi poss\u00edvel identificar a loja selecionada.");
            CarregarTela();
            return;
        }

        if (e.CommandName == "EditarLoja")
        {
            CarregarLojaParaEdicao(lojaId);
            CarregarTela();
            return;
        }

        if (e.CommandName == "AtivarLoja")
        {
            AlterarSituacao(lojaId, true);
            CarregarTela();
            return;
        }

        if (e.CommandName == "DesativarLoja")
        {
            AlterarSituacao(lojaId, false);
            CarregarTela();
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

    private void InserirLoja(string descricao)
    {
        LojaInfo existente = BuscarLojaPorDescricao(descricao);
        if (existente != null)
        {
            MostrarMensagem("error", "Loja j\u00e1 existe", "J\u00e1 existe uma loja cadastrada com esse nome. Use Editar ou Ativar caso ela esteja inativa.");
            PatioJeepAuditoria.Registrar("LOJA_INSERIR_DUPLICADA", Session["usuario"], existente.Id, "Descricao=" + descricao);
            return;
        }

        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"INSERT INTO dbo.veiculos_patio_loja (ds, ativo)
VALUES (@ds, 1);
SELECT CONVERT(int, SCOPE_IDENTITY());", banco.oCon2);
            cmd.Parameters.Add("@ds", SqlDbType.VarChar, 50).Value = descricao;
            int novoId = Convert.ToInt32(cmd.ExecuteScalar());

            RegistrarAuditoria(novoId, "INSERIR", null, descricao, null, true, "Loja criada pela tela de manuten\u00e7\u00e3o.");
            MostrarMensagem("success", "Loja cadastrada", "Loja " + descricao + " cadastrada e ativada com sucesso.");
            LimparFormulario();
        }
        catch (Exception ex)
        {
            MostrarMensagem("error", "Erro ao cadastrar", "N\u00e3o foi poss\u00edvel cadastrar a loja agora.");
            PatioJeepAuditoria.Registrar("LOJA_INSERIR_ERRO", Session["usuario"], descricao, ex.Message);
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private void AtualizarLoja(int lojaId, string descricao)
    {
        LojaInfo atual = BuscarLojaPorId(lojaId);
        if (atual == null)
        {
            MostrarMensagem("error", "Loja n\u00e3o encontrada", "A loja selecionada n\u00e3o existe mais no cadastro.");
            LimparFormulario();
            return;
        }

        LojaInfo duplicada = BuscarLojaPorDescricao(descricao);
        if (duplicada != null && duplicada.Id != lojaId)
        {
            MostrarMensagem("error", "Nome j\u00e1 cadastrado", "Outra loja j\u00e1 usa esse nome. Escolha uma descri\u00e7\u00e3o diferente.");
            return;
        }

        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand("UPDATE dbo.veiculos_patio_loja SET ds = @ds WHERE id = @id;", banco.oCon2);
            cmd.Parameters.Add("@ds", SqlDbType.VarChar, 50).Value = descricao;
            cmd.Parameters.Add("@id", SqlDbType.Int).Value = lojaId;
            cmd.ExecuteNonQuery();

            RegistrarAuditoria(lojaId, "EDITAR", atual.Descricao, descricao, atual.Ativo, atual.Ativo, "Descri\u00e7\u00e3o da loja alterada.");
            MostrarMensagem("success", "Loja atualizada", "Loja " + descricao + " atualizada com sucesso.");
            LimparFormulario();
        }
        catch (Exception ex)
        {
            MostrarMensagem("error", "Erro ao editar", "N\u00e3o foi poss\u00edvel editar a loja agora.");
            PatioJeepAuditoria.Registrar("LOJA_EDITAR_ERRO", Session["usuario"], lojaId, ex.Message);
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private void AlterarSituacao(int lojaId, bool ativar)
    {
        LojaInfo atual = BuscarLojaPorId(lojaId);
        if (atual == null)
        {
            MostrarMensagem("error", "Loja n\u00e3o encontrada", "A loja selecionada n\u00e3o existe mais no cadastro.");
            return;
        }

        if (atual.Ativo == ativar)
        {
            MostrarMensagem("info", "Nada alterado", "A loja j\u00e1 est\u00e1 " + (ativar ? "ativa." : "inativa."));
            return;
        }

        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand("UPDATE dbo.veiculos_patio_loja SET ativo = @ativo WHERE id = @id;", banco.oCon2);
            cmd.Parameters.Add("@ativo", SqlDbType.Bit).Value = ativar;
            cmd.Parameters.Add("@id", SqlDbType.Int).Value = lojaId;
            cmd.ExecuteNonQuery();

            RegistrarAuditoria(lojaId, ativar ? "ATIVAR" : "DESATIVAR", atual.Descricao, atual.Descricao, atual.Ativo, ativar, ativar ? "Loja reativada." : "Loja desativada.");
            MostrarMensagem("success", ativar ? "Loja ativada" : "Loja desativada", "Loja " + atual.Descricao + " " + (ativar ? "ativada" : "desativada") + " com sucesso.");
            LimparFormulario();
        }
        catch (Exception ex)
        {
            MostrarMensagem("error", "Erro ao alterar situa\u00e7\u00e3o", "N\u00e3o foi poss\u00edvel alterar a situa\u00e7\u00e3o da loja agora.");
            PatioJeepAuditoria.Registrar("LOJA_SITUACAO_ERRO", Session["usuario"], lojaId, ex.Message);
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private void CarregarLojaParaEdicao(int lojaId)
    {
        LojaInfo loja = BuscarLojaPorId(lojaId);
        if (loja == null)
        {
            MostrarMensagem("error", "Loja n\u00e3o encontrada", "N\u00e3o foi poss\u00edvel carregar a loja selecionada.");
            return;
        }

        hfLojaId.Value = loja.Id.ToString();
        txtDescricao.Text = loja.Descricao;
        MostrarMensagem("info", "Editando loja", "Altere o nome da loja e clique em Salvar.");
        txtDescricao.Focus();
    }

    private void CarregarTela()
    {
        if (!TelaLiberada())
        {
            LimparConteudoBloqueado();
            return;
        }

        DataTable lojas = ObterLojas();
        gridLojas.DataSource = lojas;
        gridLojas.DataBind();
        RenderizarResumo(lojas);
        RenderizarLogs();
    }

    private DataTable ObterLojas()
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"SELECT id, ds, ISNULL(ativo, 0) AS ativo
FROM dbo.veiculos_patio_loja
WHERE (@mostrarInativas = 1 OR ISNULL(ativo, 0) = 1)
  AND (@filtro = '' OR ds LIKE @filtroLike OR CONVERT(varchar(20), id) LIKE @filtroLike)
ORDER BY ISNULL(ativo, 0) DESC, ds;", banco.oCon2);
            string filtro = (txtFiltro.Text ?? "").Trim();
            cmd.Parameters.Add("@mostrarInativas", SqlDbType.Bit).Value = chkInativas.Checked;
            cmd.Parameters.Add("@filtro", SqlDbType.VarChar, 60).Value = filtro;
            cmd.Parameters.Add("@filtroLike", SqlDbType.VarChar, 70).Value = "%" + filtro + "%";
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            adapter.Fill(tabela);
        }
        finally
        {
            banco.FecharConexao2();
        }

        return tabela;
    }

    private LojaInfo BuscarLojaPorId(int lojaId)
    {
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand("SELECT TOP 1 id, ds, ISNULL(ativo, 0) AS ativo FROM dbo.veiculos_patio_loja WHERE id = @id;", banco.oCon2);
            cmd.Parameters.Add("@id", SqlDbType.Int).Value = lojaId;
            SqlDataReader reader = cmd.ExecuteReader();
            if (reader.Read())
            {
                return new LojaInfo
                {
                    Id = Convert.ToInt32(reader["id"]),
                    Descricao = Convert.ToString(reader["ds"]),
                    Ativo = Convert.ToBoolean(reader["ativo"])
                };
            }
        }
        finally
        {
            banco.FecharConexao2();
        }

        return null;
    }

    private LojaInfo BuscarLojaPorDescricao(string descricao)
    {
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand("SELECT TOP 1 id, ds, ISNULL(ativo, 0) AS ativo FROM dbo.veiculos_patio_loja WHERE UPPER(LTRIM(RTRIM(ds))) = UPPER(@ds);", banco.oCon2);
            cmd.Parameters.Add("@ds", SqlDbType.VarChar, 50).Value = descricao;
            SqlDataReader reader = cmd.ExecuteReader();
            if (reader.Read())
            {
                return new LojaInfo
                {
                    Id = Convert.ToInt32(reader["id"]),
                    Descricao = Convert.ToString(reader["ds"]),
                    Ativo = Convert.ToBoolean(reader["ativo"])
                };
            }
        }
        finally
        {
            banco.FecharConexao2();
        }

        return null;
    }

    private void RenderizarResumo(DataTable lojasFiltradas)
    {
        int ativos = 0;
        int inativos = 0;
        int totalFiltrado = lojasFiltradas.Rows.Count;

        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"SELECT
SUM(CASE WHEN ISNULL(ativo, 0) = 1 THEN 1 ELSE 0 END) AS ativos,
SUM(CASE WHEN ISNULL(ativo, 0) = 0 THEN 1 ELSE 0 END) AS inativos
FROM dbo.veiculos_patio_loja;", banco.oCon2);
            SqlDataReader reader = cmd.ExecuteReader();
            if (reader.Read())
            {
                ativos = reader["ativos"] == DBNull.Value ? 0 : Convert.ToInt32(reader["ativos"]);
                inativos = reader["inativos"] == DBNull.Value ? 0 : Convert.ToInt32(reader["inativos"]);
            }
        }
        finally
        {
            banco.FecharConexao2();
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"lojas-summary\">");
        html.Append(CardResumo("Ativas", ativos.ToString()));
        html.Append(CardResumo("Inativas", inativos.ToString()));
        html.Append(CardResumo("Listadas", totalFiltrado.ToString()));
        html.Append("</div>");
        litResumo.Text = html.ToString();
    }

    private string CardResumo(string titulo, string valor)
    {
        return "<div class=\"lojas-card\"><small>" + Html(titulo) + "</small><strong>" + Html(valor) + "</strong></div>";
    }

    private void RenderizarLogs()
    {
        GarantirTabelaAuditoria();
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"SELECT TOP 30 a.dt, a.acao, a.usuario, a.loja_id, a.descricao_anterior, a.descricao_nova,
a.ativo_anterior, a.ativo_novo, a.detalhe, a.ip
FROM dbo.veiculos_patio_loja_auditoria a
ORDER BY a.dt DESC, a.id DESC;", banco.oCon2);
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
        html.Append("<table class=\"table table-striped table-hover lojas-table\"><thead><tr>");
        html.Append("<th>Data</th><th>A&ccedil;&atilde;o</th><th>Usu&aacute;rio</th><th>Loja</th><th>Antes</th><th>Depois</th><th>Detalhe</th><th>IP</th>");
        html.Append("</tr></thead><tbody>");

        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td>" + Html(FormatarData(row["dt"])) + "</td>");
            html.Append("<td><span class=\"lojas-badge " + ClasseAcao(row["acao"]) + "\">" + Html(row["acao"]) + "</span></td>");
            html.Append("<td>" + Html(row["usuario"]) + "</td>");
            html.Append("<td>#" + Html(row["loja_id"]) + "</td>");
            html.Append("<td>" + Html(DescricaoLog(row["descricao_anterior"], row["ativo_anterior"])) + "</td>");
            html.Append("<td>" + Html(DescricaoLog(row["descricao_nova"], row["ativo_novo"])) + "</td>");
            html.Append("<td>" + Html(row["detalhe"]) + "</td>");
            html.Append("<td>" + Html(row["ip"]) + "</td>");
            html.Append("</tr>");
        }

        html.Append("</tbody></table>");
        litLogs.Text = html.ToString();
    }

    private string ClasseAcao(object acao)
    {
        string texto = Convert.ToString(acao).ToUpperInvariant();
        if (texto.Contains("DESATIVAR"))
        {
            return "lojas-badge-inactive";
        }

        return "lojas-badge-active";
    }

    private string DescricaoLog(object descricao, object ativo)
    {
        string texto = Convert.ToString(descricao);
        if (String.IsNullOrWhiteSpace(texto))
        {
            texto = "-";
        }

        if (ativo == DBNull.Value || ativo == null)
        {
            return texto;
        }

        return texto + " (" + (Convert.ToBoolean(ativo) ? "ativa" : "inativa") + ")";
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

    private void RegistrarAuditoria(int lojaId, string acao, string descricaoAnterior, string descricaoNova, bool? ativoAnterior, bool? ativoNovo, string detalhe)
    {
        GarantirTabelaAuditoria();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"INSERT INTO dbo.veiculos_patio_loja_auditoria
(loja_id, acao, usuario, descricao_anterior, descricao_nova, ativo_anterior, ativo_novo, detalhe, ip)
VALUES (@loja_id, @acao, @usuario, @descricao_anterior, @descricao_nova, @ativo_anterior, @ativo_novo, @detalhe, @ip);", banco.oCon2);
            cmd.Parameters.Add("@loja_id", SqlDbType.Int).Value = lojaId;
            cmd.Parameters.Add("@acao", SqlDbType.VarChar, 40).Value = acao;
            cmd.Parameters.Add("@usuario", SqlDbType.VarChar, 100).Value = Convert.ToString(Session["usuario"]);
            cmd.Parameters.Add("@descricao_anterior", SqlDbType.VarChar, 50).Value = (object)descricaoAnterior ?? DBNull.Value;
            cmd.Parameters.Add("@descricao_nova", SqlDbType.VarChar, 50).Value = (object)descricaoNova ?? DBNull.Value;
            cmd.Parameters.Add("@ativo_anterior", SqlDbType.Bit).Value = ativoAnterior.HasValue ? (object)ativoAnterior.Value : DBNull.Value;
            cmd.Parameters.Add("@ativo_novo", SqlDbType.Bit).Value = ativoNovo.HasValue ? (object)ativoNovo.Value : DBNull.Value;
            cmd.Parameters.Add("@detalhe", SqlDbType.VarChar, 300).Value = detalhe;
            cmd.Parameters.Add("@ip", SqlDbType.VarChar, 60).Value = Request.UserHostAddress ?? "";
            cmd.ExecuteNonQuery();

            PatioJeepAuditoria.Registrar("LOJA_" + acao, Session["usuario"], lojaId, detalhe + " Antes=" + descricaoAnterior + "; Depois=" + descricaoNova);
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private void GarantirTabelaAuditoria()
    {
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            SqlCommand cmd = new SqlCommand(@"
IF OBJECT_ID('dbo.veiculos_patio_loja_auditoria', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.veiculos_patio_loja_auditoria
    (
        id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_veiculos_patio_loja_auditoria PRIMARY KEY,
        loja_id int NOT NULL,
        acao varchar(40) NOT NULL,
        usuario varchar(100) NULL,
        descricao_anterior varchar(50) NULL,
        descricao_nova varchar(50) NULL,
        ativo_anterior bit NULL,
        ativo_novo bit NULL,
        detalhe varchar(300) NULL,
        ip varchar(60) NULL,
        dt datetime NOT NULL CONSTRAINT DF_veiculos_patio_loja_auditoria_dt DEFAULT (GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_loja_auditoria_loja_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_loja_auditoria'))
BEGIN
    CREATE INDEX IX_veiculos_patio_loja_auditoria_loja_dt ON dbo.veiculos_patio_loja_auditoria(loja_id, dt DESC);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_loja_auditoria_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_loja_auditoria'))
BEGIN
    CREATE INDEX IX_veiculos_patio_loja_auditoria_dt ON dbo.veiculos_patio_loja_auditoria(dt DESC);
END;", banco.oCon2);
            cmd.ExecuteNonQuery();
        }
        finally
        {
            banco.FecharConexao2();
        }
    }

    private bool TelaLiberada()
    {
        return Convert.ToString(Session[SessionLiberado]) == "s";
    }

    private bool GarantirLiberado()
    {
        if (TelaLiberada()) return true;

        AtualizarVisibilidade();
        LimparConteudoBloqueado();
        MostrarMensagem("error", "Tela bloqueada", "Informe a senha de libera\u00e7\u00e3o antes de alterar lojas.");
        return false;
    }

    private void AtualizarVisibilidade()
    {
        bool liberada = TelaLiberada();
        pnlBloqueio.Visible = !liberada;
        pnlConteudo.Visible = liberada;
    }

    private void LimparConteudoBloqueado()
    {
        litResumo.Text = "";
        litLogs.Text = "";
        gridLojas.DataSource = null;
        gridLojas.DataBind();
    }

    private void ConfigurarAntiAutoFill()
    {
        txtSenhaAcesso.Attributes["autocomplete"] = "new-password";
        txtSenhaAcesso.Attributes["data-lpignore"] = "true";
        txtSenhaAcesso.Attributes["data-form-type"] = "other";

        txtDescricao.Attributes["autocomplete"] = "off";
        txtDescricao.Attributes["data-lpignore"] = "true";
        txtDescricao.Attributes["data-form-type"] = "other";

        txtFiltro.Attributes["autocomplete"] = "off";
        txtFiltro.Attributes["data-lpignore"] = "true";
        txtFiltro.Attributes["data-form-type"] = "other";
    }

    private string NormalizarDescricao(string valor)
    {
        return (valor ?? "").Trim().ToUpperInvariant();
    }

    private void LimparFormulario()
    {
        hfLojaId.Value = "";
        txtDescricao.Text = "";
    }

    private void MostrarMensagem(string tipo, string titulo, string texto)
    {
        pnlMensagem.Visible = true;
        pnlMensagem.CssClass = "lojas-message lojas-message-" + tipo;
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

    private class LojaInfo
    {
        public int Id { get; set; }
        public string Descricao { get; set; }
        public bool Ativo { get; set; }
    }
}
