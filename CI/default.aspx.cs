using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ci_default : System.Web.UI.Page
{
    private const string SenhaEdicao = "@ci*2026";

    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DateTime hoje = DateTime.Today;
            txtFiltroInicio.Text = hoje.AddDays(-30).ToString("yyyy-MM-dd");
            txtFiltroFim.Text = hoje.ToString("yyyy-MM-dd");
            txtData.Text = hoje.ToString("yyyy-MM-dd");
            CarregarTudo();
        }
    }

    protected void btnFiltrar_Click(object sender, EventArgs e)
    {
        gvCis.PageIndex = 0;
        CarregarLista();
    }

    protected void btnLimpar_Click(object sender, EventArgs e)
    {
        txtFiltroInicio.Text = "";
        txtFiltroFim.Text = "";
        ddlFiltroMarca.SelectedValue = "";
        txtBusca.Text = "";
        chkSomenteAtivas.Checked = true;
        gvCis.PageIndex = 0;
        CarregarLista();
    }

    protected void btnNova_Click(object sender, EventArgs e)
    {
        LimparFormulario();
    }

    protected void btnSalvar_Click(object sender, EventArgs e)
    {
        try
        {
            int id = ObterIdAtual();
            if (id > 0 && !EdicaoCIAutorizada(id))
            {
                if (!SenhaInformada())
                {
                    MostrarMensagem("Informe a senha correta para editar a CI.", true);
                    return;
                }

                AutorizarEdicaoCI(id);
            }

            DateTime dataDocumento;
            if (!ObterData(txtData.Text, out dataDocumento))
            {
                MostrarMensagem("Informe a data da CI no formato correto.", true);
                return;
            }

            string erro = ValidarCampos();
            if (erro.Length > 0)
            {
                MostrarMensagem(erro, true);
                return;
            }

            DataTable salvo = ExecutarTabela("dbo.ci_comunicacao_salvar",
                Param("@id_ci", SqlDbType.Int, id > 0 ? (object)id : DBNull.Value),
                Param("@data_documento", SqlDbType.Date, dataDocumento),
                Param("@origem_marca", SqlDbType.NVarChar, ddlMarca.SelectedValue, 40),
                Param("@origem_area", SqlDbType.NVarChar, txtOrigemArea.Text.Trim(), 120),
                Param("@origem_responsavel", SqlDbType.NVarChar, txtOrigemResponsavel.Text.Trim(), 160),
                Param("@destino_area", SqlDbType.NVarChar, txtDestinoArea.Text.Trim(), 120),
                Param("@destinatario", SqlDbType.NVarChar, txtDestinatario.Text.Trim(), 160),
                Param("@assunto", SqlDbType.NVarChar, txtAssunto.Text.Trim(), 200),
                Param("@categoria", SqlDbType.NVarChar, ddlCategoria.SelectedValue, 60),
                Param("@prioridade", SqlDbType.NVarChar, ddlPrioridade.SelectedValue, 20),
                Param("@corpo", SqlDbType.NVarChar, txtCorpo.Text.Trim()),
                Param("@providencias", SqlDbType.NVarChar, txtProvidencias.Text.Trim()),
                Param("@observacoes", SqlDbType.NVarChar, txtObservacoes.Text.Trim()),
                Param("@criado_por", SqlDbType.NVarChar, txtCriadoPor.Text.Trim(), 160));

            string codigo = salvo.Rows.Count > 0 ? salvo.Rows[0]["codigo_ci"].ToString() : "CI";
            LimparAutorizacaoEdicaoCI(id);
            LimparFormulario();
            CarregarTudo();
            MostrarMensagem(codigo + " salva com sucesso.", false);
        }
        catch (Exception ex)
        {
            MostrarMensagem(FormatarErro(ex), true);
        }
    }

    protected void gvCis_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id;
        if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id)) return;

        try
        {
            if (e.CommandName == "EditarCI")
            {
                if (!SenhaInformada())
                {
                    MostrarMensagem("Informe a senha correta para editar a CI.", true);
                    return;
                }

                AutorizarEdicaoCI(id);
                CarregarCI(id);
                MostrarMensagem("CI carregada para edi\u00e7\u00e3o.", false);
            }
            else if (e.CommandName == "CancelarCI")
            {
                if (!SenhaInformada())
                {
                    MostrarMensagem("Informe a senha correta para cancelar a CI.", true);
                    return;
                }

                ExecutarSemRetorno("dbo.ci_comunicacao_cancelar", Param("@id_ci", SqlDbType.Int, id));
                LimparAutorizacaoEdicaoCI(id);
                LimparFormulario();
                CarregarTudo();
                MostrarMensagem("CI cancelada com sucesso.", false);
            }
        }
        catch (Exception ex)
        {
            MostrarMensagem(FormatarErro(ex), true);
        }
    }

    protected void gvCis_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvCis.PageIndex = e.NewPageIndex;
        CarregarLista();
    }

    protected void gvCis_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;

        string status = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "status"));
        if (e.Row.Cells.Count > 5)
        {
            e.Row.Cells[5].CssClass = status.Equals("Cancelada", StringComparison.OrdinalIgnoreCase) ? "ci-status-canceled" : "ci-status-active";
        }
    }

    private void CarregarTudo()
    {
        CarregarResumo();
        CarregarLista();
    }

    private void CarregarResumo()
    {
        DataTable resumo = ExecutarTabela("dbo.ci_comunicacao_resumo");
        if (resumo.Rows.Count == 0) return;

        litTotal.Text = resumo.Rows[0]["total_cis"].ToString();
        litAtivas.Text = resumo.Rows[0]["cis_ativas"].ToString();
        litRecentes.Text = resumo.Rows[0]["ultimos_30_dias"].ToString();
    }

    private void CarregarLista()
    {
        DateTime inicio;
        DateTime fim;
        bool inicioValido = ObterData(txtFiltroInicio.Text, out inicio);
        bool fimValido = ObterData(txtFiltroFim.Text, out fim);
        string avisoConsulta = "";

        if (inicioValido && fimValido && inicio > fim)
        {
            DateTime troca = inicio;
            inicio = fim;
            fim = troca;
            txtFiltroInicio.Text = inicio.ToString("yyyy-MM-dd");
            txtFiltroFim.Text = fim.ToString("yyyy-MM-dd");
            avisoConsulta = "Per\u00edodo ajustado automaticamente: a data inicial era maior que a data final.";
        }

        object dtInicio = inicioValido ? (object)inicio : DBNull.Value;
        object dtFim = fimValido ? (object)fim : DBNull.Value;

        DataTable dados = ExecutarTabela("dbo.ci_comunicacao_listar",
            Param("@dt_inicio", SqlDbType.Date, dtInicio),
            Param("@dt_fim", SqlDbType.Date, dtFim),
            Param("@origem_marca", SqlDbType.NVarChar, ddlFiltroMarca.SelectedValue, 40),
            Param("@termo", SqlDbType.NVarChar, txtBusca.Text.Trim(), 160),
            Param("@somente_ativas", SqlDbType.Bit, chkSomenteAtivas.Checked));

        AjustarPaginaConsulta(dados.Rows.Count);
        gvCis.DataSource = dados;
        gvCis.DataBind();
        AtualizarResumoConsulta(dados.Rows.Count, avisoConsulta);
    }

    private void AjustarPaginaConsulta(int total)
    {
        if (total <= 0)
        {
            gvCis.PageIndex = 0;
            return;
        }

        int ultimaPagina = (total - 1) / gvCis.PageSize;
        if (gvCis.PageIndex > ultimaPagina)
        {
            gvCis.PageIndex = ultimaPagina;
        }
    }

    private void AtualizarResumoConsulta(int total, string aviso = "")
    {
        string prefixo = aviso.Length > 0 ? aviso + " " : "";

        if (total == 0)
        {
            litResultadoConsulta.Text = prefixo + "Nenhuma CI encontrada para os filtros selecionados.";
            return;
        }

        int primeira = total == 0 ? 0 : (gvCis.PageIndex * gvCis.PageSize) + 1;
        int ultima = Math.Min(total, primeira + gvCis.PageSize - 1);
        litResultadoConsulta.Text = prefixo + "Exibindo " + primeira.ToString() + " a " + ultima.ToString() + " de " + total.ToString() + " CI" + (total == 1 ? "." : "s.");
    }

    private void CarregarCI(int id)
    {
        DataTable dados = ExecutarTabela("dbo.ci_comunicacao_obter", Param("@id_ci", SqlDbType.Int, id));
        if (dados.Rows.Count == 0) return;

        DataRow row = dados.Rows[0];
        hfCiId.Value = row["id_ci"].ToString();
        Selecionar(ddlMarca, row["origem_marca"].ToString());
        txtData.Text = Convert.ToDateTime(row["data_documento"]).ToString("yyyy-MM-dd");
        txtOrigemArea.Text = row["origem_area"].ToString();
        txtOrigemResponsavel.Text = row["origem_responsavel"].ToString();
        txtDestinoArea.Text = row["destino_area"].ToString();
        txtDestinatario.Text = row["destinatario"].ToString();
        txtAssunto.Text = row["assunto"].ToString();
        Selecionar(ddlCategoria, row["categoria"].ToString());
        Selecionar(ddlPrioridade, row["prioridade"].ToString());
        txtCorpo.Text = row["corpo"].ToString();
        txtProvidencias.Text = row["providencias"].ToString();
        txtObservacoes.Text = row["observacoes"].ToString();
        txtCriadoPor.Text = row["criado_por"].ToString();
        litTituloForm.Text = "Editar " + row["codigo_ci"].ToString();
    }

    private void LimparFormulario()
    {
        LimparAutorizacaoEdicaoCI(ObterIdAtual());
        hfCiId.Value = "";
        ddlMarca.SelectedValue = "Bali Fiat";
        txtData.Text = DateTime.Today.ToString("yyyy-MM-dd");
        txtOrigemArea.Text = "";
        txtOrigemResponsavel.Text = "";
        txtDestinoArea.Text = "";
        txtDestinatario.Text = "";
        txtAssunto.Text = "";
        ddlCategoria.SelectedValue = "Comunicado";
        ddlPrioridade.SelectedValue = "Normal";
        txtCorpo.Text = "";
        txtProvidencias.Text = "";
        txtObservacoes.Text = "";
        txtCriadoPor.Text = "";
        litTituloForm.Text = "Nova CI";
    }

    private string ValidarCampos()
    {
        if (txtOrigemArea.Text.Trim().Length == 0) return "Informe a \u00e1rea de origem.";
        if (txtOrigemResponsavel.Text.Trim().Length == 0) return "Informe o respons\u00e1vel pela origem.";
        if (txtDestinoArea.Text.Trim().Length == 0) return "Informe a \u00e1rea de destino.";
        if (txtDestinatario.Text.Trim().Length == 0) return "Informe o destinat\u00e1rio.";
        if (txtAssunto.Text.Trim().Length == 0) return "Informe o assunto.";
        if (txtCorpo.Text.Trim().Length == 0) return "Informe o texto da comunica\u00e7\u00e3o.";
        return "";
    }

    private int ObterIdAtual()
    {
        int id;
        return Int32.TryParse(hfCiId.Value, out id) ? id : 0;
    }

    private bool SenhaInformada()
    {
        bool autorizada = String.Equals((hfSenhaEdicao.Value ?? "").Trim(), SenhaEdicao, StringComparison.Ordinal);
        hfSenhaEdicao.Value = "";
        return autorizada;
    }

    private string ChaveEdicaoCI(int id)
    {
        return "ci_edicao_autorizada_" + id.ToString();
    }

    private void AutorizarEdicaoCI(int id)
    {
        if (id > 0)
        {
            Session[ChaveEdicaoCI(id)] = true;
        }
    }

    private bool EdicaoCIAutorizada(int id)
    {
        return id <= 0 || Session[ChaveEdicaoCI(id)] != null;
    }

    private void LimparAutorizacaoEdicaoCI(int id)
    {
        if (id > 0)
        {
            Session.Remove(ChaveEdicaoCI(id));
        }
    }

    private bool ObterData(string valor, out DateTime data)
    {
        if (DateTime.TryParseExact(valor, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out data))
        {
            return true;
        }

        return DateTime.TryParseExact(valor, "dd/MM/yyyy", new CultureInfo("pt-BR"), DateTimeStyles.None, out data);
    }

    private void Selecionar(DropDownList combo, string valor)
    {
        if (combo.Items.FindByValue(valor) != null)
        {
            combo.SelectedValue = valor;
        }
    }

    private SqlParameter Param(string nome, SqlDbType tipo, object valor, int tamanho = 0)
    {
        SqlParameter parametro = tamanho > 0 ? new SqlParameter(nome, tipo, tamanho) : new SqlParameter(nome, tipo);
        parametro.Value = valor == null ? DBNull.Value : valor;
        return parametro;
    }

    private DataTable ExecutarTabela(string procedure, params SqlParameter[] parametros)
    {
        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(procedure, con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parametros != null)
            {
                cmd.Parameters.AddRange(parametros);
            }

            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    private void ExecutarSemRetorno(string procedure, params SqlParameter[] parametros)
    {
        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(procedure, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parametros != null)
            {
                cmd.Parameters.AddRange(parametros);
            }

            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private void MostrarMensagem(string mensagem, bool erro)
    {
        pnlMensagem.Visible = true;
        pnlMensagem.CssClass = erro ? "form-message error" : "form-message success";
        litMensagem.Text = Server.HtmlEncode(mensagem);
    }

    private string FormatarErro(Exception ex)
    {
        string mensagem = ex.Message;
        mensagem = mensagem.Replace("Ja ", "J\u00e1 ");
        mensagem = mensagem.Replace("Nao ", "N\u00e3o ");
        mensagem = mensagem.Replace("nao ", "n\u00e3o ");
        mensagem = mensagem.Replace("possivel", "poss\u00edvel");
        mensagem = mensagem.Replace("numero", "n\u00famero");
        mensagem = mensagem.Replace("obrigatorios", "obrigat\u00f3rios");
        mensagem = mensagem.Replace("obrigatorio", "obrigat\u00f3rio");
        mensagem = mensagem.Replace("alteracao", "altera\u00e7\u00e3o");
        mensagem = mensagem.Replace("informacao", "informa\u00e7\u00e3o");
        mensagem = mensagem.Replace("comunicacao", "comunica\u00e7\u00e3o");
        mensagem = mensagem.Replace("exclusao", "exclus\u00e3o");
        return mensagem;
    }
}
