using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ci_default : System.Web.UI.Page
{
    private const string SenhaEdicao = "@ci*2026";
    private const int TimeoutSqlSegundos = 60;

    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString; }
    }

    protected void Page_Init(object sender, EventArgs e)
    {
        if (Session != null)
        {
            ViewStateUserKey = Session.SessionID;
        }
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
            AplicarTela(ObterTelaAtual());
        }
    }

    protected void btnFiltrar_Click(object sender, EventArgs e)
    {
        gvCis.PageIndex = 0;
        CarregarLista();
        AplicarTela("consulta");
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
        AplicarTela("consulta");
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        int tamanho;
        if (!Int32.TryParse(ddlPageSize.SelectedValue, out tamanho) || tamanho <= 0)
        {
            tamanho = 12;
        }

        gvCis.PageSize = tamanho;
        gvCis.PageIndex = 0;
        CarregarLista();
        AplicarTela("consulta");
    }

    protected void btnExportar_Click(object sender, EventArgs e)
    {
        DataTable dados = ObterListaFiltrada();
        AplicarOrdenacao(dados);

        Response.Clear();
        Response.ContentType = "text/csv";
        Response.ContentEncoding = Encoding.UTF8;
        Response.AddHeader("Content-Disposition", "attachment; filename=cis-" + DateTime.Now.ToString("yyyyMMdd-HHmm") + ".csv");
        Response.BinaryWrite(Encoding.UTF8.GetPreamble());

        Response.Write("Codigo;Data;Marca;Origem;Destino;Destinatario;Assunto;Categoria;Prioridade;Status\r\n");
        foreach (DataRow row in dados.Rows)
        {
            Response.Write(Csv(row["codigo_ci"]));
            Response.Write(";");
            Response.Write(Csv(Convert.ToDateTime(row["data_documento"]).ToString("dd/MM/yyyy")));
            Response.Write(";");
            Response.Write(Csv(row["origem_marca"]));
            Response.Write(";");
            Response.Write(Csv(row["origem_area"]));
            Response.Write(";");
            Response.Write(Csv(row["destino_area"]));
            Response.Write(";");
            Response.Write(Csv(row["destinatario"]));
            Response.Write(";");
            Response.Write(Csv(row["assunto"]));
            Response.Write(";");
            Response.Write(Csv(row["categoria"]));
            Response.Write(";");
            Response.Write(Csv(row["prioridade"]));
            Response.Write(";");
            Response.Write(Csv(row["status"]));
            Response.Write("\r\n");
        }

        HttpContext.Current.ApplicationInstance.CompleteRequest();
    }

    protected void btnNova_Click(object sender, EventArgs e)
    {
        LimparFormulario();
        AplicarTela("nova");
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
                    AplicarTela("nova");
                    return;
                }

                AutorizarEdicaoCI(id);
            }

            DateTime dataDocumento;
            if (!ObterData(txtData.Text, out dataDocumento))
            {
                MostrarMensagem("Informe a data da CI no formato correto.", true);
                AplicarTela("nova");
                return;
            }

            string erro = ValidarCampos();
            if (erro.Length > 0)
            {
                MostrarMensagem(erro, true);
                AplicarTela("nova");
                return;
            }

            NormalizarFormulario();

            DataTable salvo = ExecutarTabela("dbo.ci_comunicacao_salvar",
                Param("@id_ci", SqlDbType.Int, id > 0 ? (object)id : DBNull.Value),
                Param("@data_documento", SqlDbType.Date, dataDocumento),
                Param("@origem_marca", SqlDbType.NVarChar, TextoCurto(ddlMarca.SelectedValue), 40),
                Param("@origem_area", SqlDbType.NVarChar, TextoCurto(txtOrigemArea.Text), 120),
                Param("@origem_responsavel", SqlDbType.NVarChar, TextoCurto(txtOrigemResponsavel.Text), 160),
                Param("@destino_area", SqlDbType.NVarChar, TextoCurto(txtDestinoArea.Text), 120),
                Param("@destinatario", SqlDbType.NVarChar, TextoCurto(txtDestinatario.Text), 160),
                Param("@assunto", SqlDbType.NVarChar, TextoCurto(txtAssunto.Text), 200),
                Param("@categoria", SqlDbType.NVarChar, ddlCategoria.SelectedValue, 60),
                Param("@prioridade", SqlDbType.NVarChar, ddlPrioridade.SelectedValue, 20),
                Param("@corpo", SqlDbType.NVarChar, TextoLongoEntrada(txtCorpo.Text)),
                Param("@providencias", SqlDbType.NVarChar, TextoLongoEntrada(txtProvidencias.Text)),
                Param("@observacoes", SqlDbType.NVarChar, TextoLongoEntrada(txtObservacoes.Text)),
                Param("@criado_por", SqlDbType.NVarChar, TextoCurto(txtCriadoPor.Text), 160));

            string codigo = salvo.Rows.Count > 0 ? salvo.Rows[0]["codigo_ci"].ToString() : "CI";
            int idSalvo = salvo.Rows.Count > 0 ? Convert.ToInt32(salvo.Rows[0]["id_ci"]) : 0;
            LimparAutorizacaoEdicaoCI(id);
            LimparFormulario();
            CarregarTudo();
            AplicarTela("consulta");
            if (idSalvo > 0)
            {
                MostrarMensagemHtml(Server.HtmlEncode(codigo) + " salva com sucesso. <a href=\"print.aspx?id=" + idSalvo.ToString() + "\" target=\"_blank\" rel=\"noopener\">Imprimir agora</a>.", false);
            }
            else
            {
                MostrarMensagem(codigo + " salva com sucesso.", false);
            }
        }
        catch (Exception ex)
        {
            RegistrarErro("Salvar CI", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("nova");
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
                    AplicarTela("consulta");
                    return;
                }

                AutorizarEdicaoCI(id);
                CarregarCI(id);
                AplicarTela("nova");
                MostrarMensagem("CI carregada para edi\u00e7\u00e3o.", false);
            }
            else if (e.CommandName == "DuplicarCI")
            {
                CarregarCIDuplicada(id);
                AplicarTela("nova");
                MostrarMensagem("CI duplicada como novo rascunho. Revise os dados antes de salvar.", false);
            }
            else if (e.CommandName == "CancelarCI")
            {
                if (!SenhaInformada())
                {
                    MostrarMensagem("Informe a senha correta para cancelar a CI.", true);
                    AplicarTela("consulta");
                    return;
                }

                ExecutarSemRetorno("dbo.ci_comunicacao_cancelar", Param("@id_ci", SqlDbType.Int, id));
                LimparAutorizacaoEdicaoCI(id);
                LimparFormulario();
                CarregarTudo();
                AplicarTela("consulta");
                MostrarMensagem("CI cancelada com sucesso.", false);
            }
        }
        catch (Exception ex)
        {
            RegistrarErro("A\u00e7\u00e3o na lista de CI", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("consulta");
        }
    }

    protected void gvCis_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvCis.PageIndex = e.NewPageIndex;
        CarregarLista();
        AplicarTela("consulta");
    }

    protected void gvCis_Sorting(object sender, GridViewSortEventArgs e)
    {
        string direcaoAtual = Convert.ToString(ViewState["CiSortDirection"]);
        string campoAtual = Convert.ToString(ViewState["CiSortExpression"]);
        string novaDirecao = (campoAtual == e.SortExpression && direcaoAtual == "ASC") ? "DESC" : "ASC";

        ViewState["CiSortExpression"] = e.SortExpression;
        ViewState["CiSortDirection"] = novaDirecao;
        gvCis.PageIndex = 0;
        CarregarLista();
        AplicarTela("consulta");
    }

    protected void gvCis_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;

        AplicarRotulosMobile(gvCis, e.Row);

        string status = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "status"));
        if (e.Row.Cells.Count > 5)
        {
            e.Row.Cells[5].CssClass = status.Equals("Cancelada", StringComparison.OrdinalIgnoreCase) ? "ci-status-canceled" : "ci-status-active";
        }

        if (status.Equals("Cancelada", StringComparison.OrdinalIgnoreCase))
        {
            LinkButton editar = e.Row.FindControl("lnkEditar") as LinkButton;
            LinkButton cancelar = e.Row.FindControl("lnkCancelar") as LinkButton;
            if (editar != null) editar.Visible = false;
            if (cancelar != null) cancelar.Visible = false;
        }
    }

    protected void gvHistorico_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        AplicarRotulosMobile(gvHistorico, e.Row);
    }

    private void CarregarTudo()
    {
        CarregarResumo();
        CarregarLista();
    }

    private string ObterTelaAtual()
    {
        string tela = (Request.QueryString["view"] ?? "").Trim().ToLowerInvariant();
        return tela == "nova" || tela == "cadastro" ? "nova" : "consulta";
    }

    private void AplicarTela(string tela)
    {
        bool mostrarCadastro = String.Equals(tela, "nova", StringComparison.OrdinalIgnoreCase) ||
            String.Equals(tela, "cadastro", StringComparison.OrdinalIgnoreCase);

        pnlConsulta.Visible = !mostrarCadastro;
        pnlCadastro.Visible = mostrarCadastro;
        ViewState["CiTela"] = mostrarCadastro ? "nova" : "consulta";
    }

    private void CarregarResumo()
    {
        DataTable resumo = ExecutarTabela("dbo.ci_comunicacao_resumo");
        if (resumo.Rows.Count == 0) return;

        litTotal.Text = resumo.Rows[0]["total_cis"].ToString();
        litAtivas.Text = resumo.Rows[0]["cis_ativas"].ToString();
        litRecentes.Text = resumo.Rows[0]["ultimos_30_dias"].ToString();
        litMesAtual.Text = ValorResumo(resumo.Rows[0], "mes_atual");
        litCanceladas.Text = ValorResumo(resumo.Rows[0], "cis_canceladas");
        litFiat.Text = ValorResumo(resumo.Rows[0], "fiat_ativas");
        litJeep.Text = ValorResumo(resumo.Rows[0], "jeep_ativas");
        litByd.Text = ValorResumo(resumo.Rows[0], "byd_ativas");
    }

    private string ValorResumo(DataRow row, string coluna)
    {
        if (row.Table.Columns.IndexOf(coluna) < 0 || row[coluna] == DBNull.Value) return "0";
        return row[coluna].ToString();
    }

    private void CarregarLista()
    {
        DataTable dados = ObterListaFiltrada();
        AplicarOrdenacao(dados);
        AjustarPaginaConsulta(dados.Rows.Count);
        gvCis.DataSource = dados;
        gvCis.DataBind();
        AtualizarResumoConsulta(dados.Rows.Count, Convert.ToString(ViewState["CiAvisoConsulta"] ?? ""));
        ViewState["CiAvisoConsulta"] = "";
    }

    private DataTable ObterListaFiltrada()
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

        ViewState["CiAvisoConsulta"] = avisoConsulta;

        object dtInicio = inicioValido ? (object)inicio : DBNull.Value;
        object dtFim = fimValido ? (object)fim : DBNull.Value;

        return ExecutarTabela("dbo.ci_comunicacao_listar",
            Param("@dt_inicio", SqlDbType.Date, dtInicio),
            Param("@dt_fim", SqlDbType.Date, dtFim),
            Param("@origem_marca", SqlDbType.NVarChar, ddlFiltroMarca.SelectedValue, 40),
            Param("@termo", SqlDbType.NVarChar, txtBusca.Text.Trim(), 160),
            Param("@somente_ativas", SqlDbType.Bit, chkSomenteAtivas.Checked));
    }

    private void AplicarOrdenacao(DataTable dados)
    {
        if (dados == null || dados.Rows.Count == 0) return;

        string campo = Convert.ToString(ViewState["CiSortExpression"]);
        string direcao = Convert.ToString(ViewState["CiSortDirection"]);
        if (campo.Length == 0 || dados.Columns.IndexOf(campo) < 0) return;
        if (direcao != "ASC" && direcao != "DESC") direcao = "ASC";

        DataView view = dados.DefaultView;
        view.Sort = campo + " " + direcao;
        DataTable ordenado = view.ToTable();

        dados.Clear();
        foreach (DataRow row in ordenado.Rows)
        {
            dados.ImportRow(row);
        }
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

    private void AplicarRotulosMobile(GridView grid, GridViewRow row)
    {
        int limite = Math.Min(grid.Columns.Count, row.Cells.Count);
        for (int i = 0; i < limite; i++)
        {
            row.Cells[i].Attributes["data-label"] = Server.HtmlDecode(grid.Columns[i].HeaderText);
        }
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
        CarregarHistorico(id);
    }

    private void CarregarCIDuplicada(int id)
    {
        DataTable dados = ExecutarTabela("dbo.ci_comunicacao_obter", Param("@id_ci", SqlDbType.Int, id));
        if (dados.Rows.Count == 0) return;

        DataRow row = dados.Rows[0];
        LimparAutorizacaoEdicaoCI(ObterIdAtual());
        hfCiId.Value = "";
        Selecionar(ddlMarca, row["origem_marca"].ToString());
        txtData.Text = DateTime.Today.ToString("yyyy-MM-dd");
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
        litTituloForm.Text = "Nova CI baseada em " + row["codigo_ci"].ToString();
        pnlHistorico.Visible = false;
        gvHistorico.DataSource = null;
        gvHistorico.DataBind();
    }

    private void CarregarHistorico(int id)
    {
        DataTable historico = ExecutarTabela("dbo.ci_comunicacao_historico_listar", Param("@id_ci", SqlDbType.Int, id));
        pnlHistorico.Visible = true;
        gvHistorico.DataSource = historico;
        gvHistorico.DataBind();
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
        pnlHistorico.Visible = false;
        gvHistorico.DataSource = null;
        gvHistorico.DataBind();
    }

    private string ValidarCampos()
    {
        if (!ValorPermitido(ddlMarca, ddlMarca.SelectedValue)) return "Selecione uma marca v\u00e1lida.";
        if (!ValorPermitido(ddlCategoria, ddlCategoria.SelectedValue)) return "Selecione uma categoria v\u00e1lida.";
        if (!ValorPermitido(ddlPrioridade, ddlPrioridade.SelectedValue)) return "Selecione uma prioridade v\u00e1lida.";
        if (TextoCurto(txtOrigemArea.Text).Length == 0) return "Informe a \u00e1rea de origem.";
        if (TextoCurto(txtOrigemResponsavel.Text).Length == 0) return "Informe o respons\u00e1vel pela origem.";
        if (TextoCurto(txtDestinoArea.Text).Length == 0) return "Informe a \u00e1rea de destino.";
        if (TextoCurto(txtDestinatario.Text).Length == 0) return "Informe o destinat\u00e1rio.";
        if (TextoCurto(txtAssunto.Text).Length == 0) return "Informe o assunto.";
        if (TextoLongoEntrada(txtCorpo.Text).Length == 0) return "Informe o texto da comunica\u00e7\u00e3o.";
        if (TextoCurto(txtOrigemArea.Text).Length > 120) return "A \u00e1rea de origem deve ter at\u00e9 120 caracteres.";
        if (TextoCurto(txtOrigemResponsavel.Text).Length > 160) return "O respons\u00e1vel deve ter at\u00e9 160 caracteres.";
        if (TextoCurto(txtDestinoArea.Text).Length > 120) return "A \u00e1rea de destino deve ter at\u00e9 120 caracteres.";
        if (TextoCurto(txtDestinatario.Text).Length > 160) return "O destinat\u00e1rio deve ter at\u00e9 160 caracteres.";
        if (TextoCurto(txtAssunto.Text).Length > 200) return "O assunto deve ter at\u00e9 200 caracteres.";
        if (TextoCurto(txtCriadoPor.Text).Length > 160) return "O campo criado por deve ter at\u00e9 160 caracteres.";
        if (ContemMarcadorModelo(txtAssunto.Text) ||
            ContemMarcadorModelo(txtCorpo.Text) ||
            ContemMarcadorModelo(txtProvidencias.Text) ||
            ContemMarcadorModelo(txtObservacoes.Text))
        {
            return "Substitua os trechos entre colchetes antes de salvar a CI.";
        }

        return "";
    }

    private void NormalizarFormulario()
    {
        txtOrigemArea.Text = TextoCurto(txtOrigemArea.Text);
        txtOrigemResponsavel.Text = TextoCurto(txtOrigemResponsavel.Text);
        txtDestinoArea.Text = TextoCurto(txtDestinoArea.Text);
        txtDestinatario.Text = TextoCurto(txtDestinatario.Text);
        txtAssunto.Text = TextoCurto(txtAssunto.Text);
        txtCorpo.Text = TextoLongoEntrada(txtCorpo.Text);
        txtProvidencias.Text = TextoLongoEntrada(txtProvidencias.Text);
        txtObservacoes.Text = TextoLongoEntrada(txtObservacoes.Text);
        txtCriadoPor.Text = TextoCurto(txtCriadoPor.Text);
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

    private bool ValorPermitido(DropDownList combo, string valor)
    {
        return combo.Items.FindByValue(valor) != null;
    }

    private string TextoCurto(string valor)
    {
        string texto = (valor ?? "").Trim();
        if (texto.Length == 0) return "";
        return String.Join(" ", texto.Split((char[])null, StringSplitOptions.RemoveEmptyEntries));
    }

    private string TextoLongoEntrada(string valor)
    {
        string texto = (valor ?? "").Replace("\r\n", "\n").Replace("\r", "\n").Trim();
        while (texto.Contains("\n\n\n"))
        {
            texto = texto.Replace("\n\n\n", "\n\n");
        }

        return texto.Replace("\n", "\r\n");
    }

    private bool ContemMarcadorModelo(string valor)
    {
        string texto = valor ?? "";
        int abre = texto.IndexOf("[", StringComparison.Ordinal);
        int fecha = texto.IndexOf("]", StringComparison.Ordinal);
        return abre >= 0 && fecha > abre;
    }

    private SqlParameter Param(string nome, SqlDbType tipo, object valor, int tamanho = 0)
    {
        SqlParameter parametro = tamanho > 0 ? new SqlParameter(nome, tipo, tamanho) : new SqlParameter(nome, tipo);
        parametro.Value = valor == null ? DBNull.Value : valor;
        return parametro;
    }

    private string Csv(object valor)
    {
        string texto = Convert.ToString(valor ?? "");
        texto = texto.Replace("\"", "\"\"");
        return "\"" + texto + "\"";
    }

    private DataTable ExecutarTabela(string procedure, params SqlParameter[] parametros)
    {
        using (SqlConnection con = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(procedure, con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandTimeout = TimeoutSqlSegundos;
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
            cmd.CommandTimeout = TimeoutSqlSegundos;
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

    private void MostrarMensagemHtml(string html, bool erro)
    {
        pnlMensagem.Visible = true;
        pnlMensagem.CssClass = erro ? "form-message error" : "form-message success";
        litMensagem.Text = html;
    }

    private void RegistrarErro(string origem, Exception ex)
    {
        try
        {
            string pasta = Server.MapPath("~/App_Data");
            if (!Directory.Exists(pasta))
            {
                Directory.CreateDirectory(pasta);
            }

            string usuario = Context != null && Context.User != null && Context.User.Identity != null && Context.User.Identity.IsAuthenticated
                ? Context.User.Identity.Name
                : "anonimo";

            string linha = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") +
                " | " + origem +
                " | usuario=" + usuario +
                " | url=" + Request.RawUrl +
                " | erro=" + (ex.Message ?? "").Replace("\r", " ").Replace("\n", " ") +
                Environment.NewLine;

            File.AppendAllText(Path.Combine(pasta, "ci-erros.log"), linha, Encoding.UTF8);
        }
        catch
        {
        }
    }

    private string FormatarErro(Exception ex)
    {
        string mensagem = CorrigirAcentosQuebrados(ex.Message);
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

    private string CorrigirAcentosQuebrados(string mensagem)
    {
        return (mensagem ?? "")
            .Replace("\u00c3\u00a1", "\u00e1")
            .Replace("\u00c3\u00a0", "\u00e0")
            .Replace("\u00c3\u00a2", "\u00e2")
            .Replace("\u00c3\u00a3", "\u00e3")
            .Replace("\u00c3\u00a9", "\u00e9")
            .Replace("\u00c3\u00aa", "\u00ea")
            .Replace("\u00c3\u00ad", "\u00ed")
            .Replace("\u00c3\u00b3", "\u00f3")
            .Replace("\u00c3\u00b4", "\u00f4")
            .Replace("\u00c3\u00b5", "\u00f5")
            .Replace("\u00c3\u00ba", "\u00fa")
            .Replace("\u00c3\u00a7", "\u00e7")
            .Replace("\u00c3\u0081", "\u00c1")
            .Replace("\u00c3\u0080", "\u00c0")
            .Replace("\u00c3\u0082", "\u00c2")
            .Replace("\u00c3\u0083", "\u00c3")
            .Replace("\u00c3\u0089", "\u00c9")
            .Replace("\u00c3\u008a", "\u00ca")
            .Replace("\u00c3\u008d", "\u00cd")
            .Replace("\u00c3\u0093", "\u00d3")
            .Replace("\u00c3\u0094", "\u00d4")
            .Replace("\u00c3\u0095", "\u00d5")
            .Replace("\u00c3\u009a", "\u00da")
            .Replace("\u00c3\u0087", "\u00c7")
            .Replace("\u00c2", "");
    }
}
