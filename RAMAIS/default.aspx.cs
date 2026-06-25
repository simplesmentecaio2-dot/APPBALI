using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

public partial class ramais_default : System.Web.UI.Page
{
    private const string SenhaManutencaoRamais = "@bali2025";
    private const string ViewStateCookieName = "BaliViewStateKey";
    private const int TimeoutSqlSegundos = 60;

    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString; }
    }

    protected void Page_Init(object sender, EventArgs e)
    {
        ViewStateUserKey = ObterChaveViewState();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            CarregarTudo();
            AplicarTela(ObterTelaAtual());
            MostrarAvisoViewStateExpirado();
        }
    }

    protected void btnSair_Click(object sender, EventArgs e)
    {
        Response.Redirect("../Intranet/index.html");
    }

    protected void btnFiltrar_Click(object sender, EventArgs e)
    {
        CarregarRamais();
        AplicarTela("consulta");
    }

    protected void btnLimparFiltros_Click(object sender, EventArgs e)
    {
        ddlFiltroLoja.SelectedValue = "0";
        ddlFiltroSetor.SelectedValue = "0";
        txtBusca.Text = "";
        chkSomenteAtivos.Checked = true;
        CarregarRamais();
        AplicarTela("consulta");
    }

    protected void btnExportar_Click(object sender, EventArgs e)
    {
        DataTable ramais = ExecutarTabela("dbo.ramais_ramal_listar",
            Param("@id_loja", SqlDbType.Int, ValorCombo(ddlFiltroLoja)),
            Param("@id_setor", SqlDbType.Int, ValorCombo(ddlFiltroSetor)),
            Param("@termo", SqlDbType.NVarChar, txtBusca.Text.Trim(), 160),
            Param("@somente_ativos", SqlDbType.Bit, chkSomenteAtivos.Checked));

        ramais = OrdenarTabela(ramais, gvConsulta);

        Response.Clear();
        Response.ContentType = "text/csv";
        Response.ContentEncoding = Encoding.UTF8;
        Response.AddHeader("Content-Disposition", "attachment; filename=ramais-" + DateTime.Now.ToString("yyyyMMdd-HHmm") + ".csv");
        Response.BinaryWrite(Encoding.UTF8.GetPreamble());
        Response.Write("Nome;Ramal;Loja;Setor;Status\r\n");

        foreach (DataRow row in ramais.Rows)
        {
            Response.Write(Csv(row["nome"]));
            Response.Write(";");
            Response.Write(Csv(row["ramal"]));
            Response.Write(";");
            Response.Write(Csv(row["loja"]));
            Response.Write(";");
            Response.Write(Csv(row["setor"]));
            Response.Write(";");
            Response.Write(Csv(row["status"]));
            Response.Write("\r\n");
        }

        HttpContext.Current.ApplicationInstance.CompleteRequest();
    }

    protected void btnGerarImpressao_Click(object sender, EventArgs e)
    {
        CarregarImpressao();
        AplicarTela("impressao");
    }

    protected void btnSalvarRamal_Click(object sender, EventArgs e)
    {
        try
        {
            int idAtual = ObterIdNumerico(hfRamalId.Value);
            if (idAtual > 0 && !EdicaoRamalAutorizada(idAtual))
            {
                MostrarMensagem("Para salvar altera\u00e7\u00e3o em ramal existente, clique em Editar e informe a senha de manuten\u00e7\u00e3o.", true);
                AplicarTela("ramais");
                return;
            }

            NormalizarFormularioRamal();

            if (txtNome.Text.Trim().Length == 0)
            {
                MostrarMensagem("Informe o nome do colaborador.", true);
                AplicarTela("ramais");
                return;
            }

            if (txtRamal.Text.Trim().Length == 0)
            {
                MostrarMensagem("Informe o ramal.", true);
                AplicarTela("ramais");
                return;
            }

            if (txtNome.Text.Trim().Length > 160 || txtRamal.Text.Trim().Length > 30)
            {
                MostrarMensagem("Revise nome e ramal: o nome deve ter at\u00e9 160 caracteres e o ramal at\u00e9 30.", true);
                AplicarTela("ramais");
                return;
            }

            if (ddlRamalLoja.SelectedValue == "0" || ddlRamalSetor.SelectedValue == "0")
            {
                MostrarMensagem("Selecione loja e setor para salvar o ramal.", true);
                AplicarTela("ramais");
                return;
            }

            ExecutarTabela("dbo.ramais_ramal_salvar",
                Param("@id_ramal", SqlDbType.Int, idAtual > 0 ? (object)idAtual : DBNull.Value),
                Param("@nome", SqlDbType.NVarChar, txtNome.Text, 160),
                Param("@ramal", SqlDbType.NVarChar, txtRamal.Text, 30),
                Param("@id_loja", SqlDbType.Int, Convert.ToInt32(ddlRamalLoja.SelectedValue)),
                Param("@id_setor", SqlDbType.Int, Convert.ToInt32(ddlRamalSetor.SelectedValue)),
                Param("@ativo", SqlDbType.Bit, chkRamalAtivo.Checked));

            LimparAutorizacaoEdicaoRamal(idAtual);
            LimparRamal();
            CarregarTudo();
            MostrarMensagem("Ramal salvo com sucesso.", false);
            AplicarTela("ramais");
        }
        catch (Exception ex)
        {
            RegistrarErro("Salvar ramal", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("ramais");
        }
    }

    protected void btnNovoRamal_Click(object sender, EventArgs e)
    {
        LimparRamal();
        AplicarTela("ramais");
    }

    protected void gvRamais_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id;
        if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id)) return;

        try
        {
            if (e.CommandName == "EditarRamal")
            {
                if (!SenhaManutencaoInformada())
                {
                    AplicarTela("consulta");
                    return;
                }

                AutorizarEdicaoRamal(id);
                CarregarRamal(id);
                MostrarMensagem("Ramal carregado para edi\u00e7\u00e3o.", false);
                AplicarTela("ramais");
            }
            else if (e.CommandName == "ExcluirRamal")
            {
                if (!SenhaManutencaoInformada())
                {
                    AplicarTela("ramais");
                    return;
                }

                ExecutarSemRetorno("dbo.ramais_ramal_excluir", Param("@id_ramal", SqlDbType.Int, id));
                LimparAutorizacaoEdicaoRamal(id);
                LimparRamal();
                CarregarTudo();
                MostrarMensagem("Ramal inativado com sucesso.", false);
                AplicarTela("ramais");
            }
        }
        catch (Exception ex)
        {
            RegistrarErro("A\u00e7\u00e3o em ramal", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("ramais");
        }
    }

    protected void Grid_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;

        GridView grid = sender as GridView;
        if (grid == null) return;

        int limite = Math.Min(grid.Columns.Count, e.Row.Cells.Count);
        for (int i = 0; i < limite; i++)
        {
            e.Row.Cells[i].Attributes["data-label"] = Server.HtmlDecode(grid.Columns[i].HeaderText);
        }
    }

    protected void Grid_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        GridView grid = sender as GridView;
        if (grid == null) return;

        grid.PageIndex = e.NewPageIndex;

        if (grid == gvConsulta)
        {
            CarregarRamais();
            AplicarTela("consulta");
        }
        else if (grid == gvRamais)
        {
            CarregarRamais();
            AplicarTela("ramais");
        }
        else if (grid == gvLojas)
        {
            CarregarLojas();
            AplicarTela("lojas");
        }
        else if (grid == gvSetores)
        {
            CarregarSetores();
            AplicarTela("setores");
        }
    }

    protected void Grid_Sorting(object sender, GridViewSortEventArgs e)
    {
        GridView grid = sender as GridView;
        if (grid == null) return;

        string campoAtual = Convert.ToString(ViewState[grid.ID + "_SortExpression"]);
        string direcaoAtual = Convert.ToString(ViewState[grid.ID + "_SortDirection"]);
        string novaDirecao = (campoAtual == e.SortExpression && direcaoAtual == "ASC") ? "DESC" : "ASC";

        ViewState[grid.ID + "_SortExpression"] = e.SortExpression;
        ViewState[grid.ID + "_SortDirection"] = novaDirecao;
        grid.PageIndex = 0;

        if (grid == gvConsulta)
        {
            CarregarRamais();
            AplicarTela("consulta");
        }
        else if (grid == gvRamais)
        {
            CarregarRamais();
            AplicarTela("ramais");
        }
        else if (grid == gvLojas)
        {
            CarregarLojas();
            AplicarTela("lojas");
        }
        else if (grid == gvSetores)
        {
            CarregarSetores();
            AplicarTela("setores");
        }
    }

    protected void btnSalvarLoja_Click(object sender, EventArgs e)
    {
        try
        {
            txtLojaNome.Text = TextoCurto(txtLojaNome.Text);

            if (txtLojaNome.Text.Trim().Length == 0)
            {
                MostrarMensagem("Informe o nome da loja.", true);
                AplicarTela("lojas");
                return;
            }

            if (txtLojaNome.Text.Trim().Length > 120)
            {
                MostrarMensagem("O nome da loja deve ter at\u00e9 120 caracteres.", true);
                AplicarTela("lojas");
                return;
            }

            ExecutarTabela("dbo.ramais_loja_salvar",
                Param("@id_loja", SqlDbType.Int, ObterId(hfLojaId.Value)),
                Param("@nome", SqlDbType.NVarChar, txtLojaNome.Text.Trim(), 120),
                Param("@ativo", SqlDbType.Bit, chkLojaAtiva.Checked));

            LimparLoja();
            CarregarTudo();
            MostrarMensagem("Loja salva com sucesso.", false);
            AplicarTela("lojas");
        }
        catch (Exception ex)
        {
            RegistrarErro("Salvar loja", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("lojas");
        }
    }

    protected void btnNovaLoja_Click(object sender, EventArgs e)
    {
        LimparLoja();
        AplicarTela("lojas");
    }

    protected void gvLojas_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id;
        if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id)) return;

        try
        {
            if (e.CommandName == "EditarLoja")
            {
                DataTable loja = ExecutarTabela("dbo.ramais_loja_obter", Param("@id_loja", SqlDbType.Int, id));
                if (loja.Rows.Count > 0)
                {
                    DataRow row = loja.Rows[0];
                    hfLojaId.Value = row["id_loja"].ToString();
                    txtLojaNome.Text = row["nome"].ToString();
                    chkLojaAtiva.Checked = Convert.ToBoolean(row["ativo"]);
                    MostrarMensagem("Loja carregada para edi\u00e7\u00e3o.", false);
                    AplicarTela("lojas");
                }
            }
            else if (e.CommandName == "ExcluirLoja")
            {
                ExecutarSemRetorno("dbo.ramais_loja_excluir", Param("@id_loja", SqlDbType.Int, id));
                LimparLoja();
                CarregarTudo();
                MostrarMensagem("Loja inativada com sucesso.", false);
                AplicarTela("lojas");
            }
        }
        catch (Exception ex)
        {
            RegistrarErro("A\u00e7\u00e3o em loja", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("lojas");
        }
    }

    protected void btnSalvarSetor_Click(object sender, EventArgs e)
    {
        try
        {
            txtSetorNome.Text = TextoCurto(txtSetorNome.Text);

            if (txtSetorNome.Text.Trim().Length == 0)
            {
                MostrarMensagem("Informe o nome do setor.", true);
                AplicarTela("setores");
                return;
            }

            if (txtSetorNome.Text.Trim().Length > 120)
            {
                MostrarMensagem("O nome do setor deve ter at\u00e9 120 caracteres.", true);
                AplicarTela("setores");
                return;
            }

            ExecutarTabela("dbo.ramais_setor_salvar",
                Param("@id_setor", SqlDbType.Int, ObterId(hfSetorId.Value)),
                Param("@nome", SqlDbType.NVarChar, txtSetorNome.Text.Trim(), 120),
                Param("@ativo", SqlDbType.Bit, chkSetorAtivo.Checked));

            LimparSetor();
            CarregarTudo();
            MostrarMensagem("Setor salvo com sucesso.", false);
            AplicarTela("setores");
        }
        catch (Exception ex)
        {
            RegistrarErro("Salvar setor", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("setores");
        }
    }

    protected void btnNovoSetor_Click(object sender, EventArgs e)
    {
        LimparSetor();
        AplicarTela("setores");
    }

    protected void gvSetores_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id;
        if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id)) return;

        try
        {
            if (e.CommandName == "EditarSetor")
            {
                DataTable setor = ExecutarTabela("dbo.ramais_setor_obter", Param("@id_setor", SqlDbType.Int, id));
                if (setor.Rows.Count > 0)
                {
                    DataRow row = setor.Rows[0];
                    hfSetorId.Value = row["id_setor"].ToString();
                    txtSetorNome.Text = row["nome"].ToString();
                    chkSetorAtivo.Checked = Convert.ToBoolean(row["ativo"]);
                    MostrarMensagem("Setor carregado para edi\u00e7\u00e3o.", false);
                    AplicarTela("setores");
                }
            }
            else if (e.CommandName == "ExcluirSetor")
            {
                ExecutarSemRetorno("dbo.ramais_setor_excluir", Param("@id_setor", SqlDbType.Int, id));
                LimparSetor();
                CarregarTudo();
                MostrarMensagem("Setor inativado com sucesso.", false);
                AplicarTela("setores");
            }
        }
        catch (Exception ex)
        {
            RegistrarErro("A\u00e7\u00e3o em setor", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("setores");
        }
    }

    private void CarregarTudo()
    {
        CarregarCombos();
        CarregarResumo();
        CarregarRamais();
        CarregarLojas();
        CarregarSetores();
        CarregarImpressao();
    }

    private string ObterTelaAtual()
    {
        string tela = (Request.QueryString["view"] ?? "").Trim().ToLowerInvariant();
        if (tela == "ramais" || tela == "lojas" || tela == "setores" || tela == "impressao")
        {
            return tela;
        }

        return "consulta";
    }

    private void MostrarAvisoViewStateExpirado()
    {
        if (String.Equals(Request.QueryString["viewstate"], "expired", StringComparison.OrdinalIgnoreCase))
        {
            MostrarMensagem("A tela foi atualizada porque o formul\u00e1rio anterior expirou. Preencha novamente e salve.", true);
        }
    }

    private void AplicarTela(string tela)
    {
        tela = (tela ?? "consulta").ToLowerInvariant();
        bool ramais = tela == "ramais";
        bool lojas = tela == "lojas";
        bool setores = tela == "setores";
        bool impressao = tela == "impressao";

        pnlConsulta.Visible = !ramais && !lojas && !setores && !impressao;
        pnlImpressao.Visible = impressao;
        pnlRamais.Visible = ramais;
        pnlCadastrosAuxiliares.Visible = lojas || setores;
        pnlLojas.Visible = lojas;
        pnlSetores.Visible = setores;
    }

    private void CarregarCombos()
    {
        DataTable lojas = ExecutarTabela("dbo.ramais_loja_listar", Param("@somente_ativas", SqlDbType.Bit, true));
        DataTable setores = ExecutarTabela("dbo.ramais_setor_listar", Param("@somente_ativos", SqlDbType.Bit, true));

        PopularCombo(ddlFiltroLoja, lojas, "Todas as lojas", "0");
        PopularCombo(ddlRamalLoja, lojas, "Selecione a loja", "0");
        PopularCombo(ddlImpressaoLoja, lojas, "Todas as lojas", "0");
        PopularCombo(ddlFiltroSetor, setores, "Todos os setores", "0");
        PopularCombo(ddlRamalSetor, setores, "Selecione o setor", "0");
    }

    private void PopularCombo(DropDownList combo, DataTable dados, string textoPadrao, string valorPadrao)
    {
        string valorAtual = combo.SelectedValue;
        combo.Items.Clear();
        combo.DataSource = dados;
        combo.DataTextField = "nome";
        combo.DataValueField = dados.Columns.Contains("id_loja") ? "id_loja" : "id_setor";
        combo.DataBind();
        combo.Items.Insert(0, new ListItem(textoPadrao, valorPadrao));

        if (combo.Items.FindByValue(valorAtual) != null)
        {
            combo.SelectedValue = valorAtual;
        }
        else
        {
            combo.SelectedValue = valorPadrao;
        }
    }

    private void CarregarResumo()
    {
        DataTable resumo = ExecutarTabela("dbo.ramais_resumo");
        if (resumo.Rows.Count == 0) return;

        litTotalRamais.Text = resumo.Rows[0]["total_ramais"].ToString();
        litTotalLojas.Text = resumo.Rows[0]["total_lojas"].ToString();
        litTotalSetores.Text = resumo.Rows[0]["total_setores"].ToString();
        litRamaisInativos.Text = ValorResumo(resumo.Rows[0], "ramais_inativos");
        litLojasComRamais.Text = ValorResumo(resumo.Rows[0], "lojas_com_ramais");
    }

    private string ValorResumo(DataRow row, string coluna)
    {
        if (row.Table.Columns.IndexOf(coluna) < 0 || row[coluna] == DBNull.Value) return "0";
        return row[coluna].ToString();
    }

    private void CarregarRamais()
    {
        DataTable ramais = ExecutarTabela("dbo.ramais_ramal_listar",
            Param("@id_loja", SqlDbType.Int, ValorCombo(ddlFiltroLoja)),
            Param("@id_setor", SqlDbType.Int, ValorCombo(ddlFiltroSetor)),
            Param("@termo", SqlDbType.NVarChar, txtBusca.Text.Trim(), 160),
            Param("@somente_ativos", SqlDbType.Bit, chkSomenteAtivos.Checked));

        gvConsulta.DataSource = OrdenarTabela(ramais.Copy(), gvConsulta);
        gvConsulta.DataBind();

        gvRamais.DataSource = OrdenarTabela(ramais.Copy(), gvRamais);
        gvRamais.DataBind();
    }

    private void CarregarLojas()
    {
        DataTable lojas = ExecutarTabela("dbo.ramais_loja_listar", Param("@somente_ativas", SqlDbType.Bit, false));
        gvLojas.DataSource = OrdenarTabela(lojas, gvLojas);
        gvLojas.DataBind();
    }

    private void CarregarSetores()
    {
        DataTable setores = ExecutarTabela("dbo.ramais_setor_listar", Param("@somente_ativos", SqlDbType.Bit, false));
        gvSetores.DataSource = OrdenarTabela(setores, gvSetores);
        gvSetores.DataBind();
    }

    private DataTable OrdenarTabela(DataTable dados, GridView grid)
    {
        if (dados == null || dados.Rows.Count == 0 || grid == null) return dados;

        string campo = Convert.ToString(ViewState[grid.ID + "_SortExpression"]);
        string direcao = Convert.ToString(ViewState[grid.ID + "_SortDirection"]);
        if (campo.Length == 0 || dados.Columns.IndexOf(campo) < 0) return dados;
        if (direcao != "ASC" && direcao != "DESC") direcao = "ASC";

        DataView view = dados.DefaultView;
        view.Sort = campo + " " + direcao;
        return view.ToTable();
    }

    private void CarregarImpressao()
    {
        DataTable ramais = ExecutarTabela("dbo.ramais_ramal_listar",
            Param("@id_loja", SqlDbType.Int, ValorCombo(ddlImpressaoLoja)),
            Param("@id_setor", SqlDbType.Int, DBNull.Value),
            Param("@termo", SqlDbType.NVarChar, "", 160),
            Param("@somente_ativos", SqlDbType.Bit, true));

        string lojaSelecionada = ddlImpressaoLoja.SelectedValue == "0" ? "Todas as lojas" : ddlImpressaoLoja.SelectedItem.Text;
        litImpressaoResumo.Text = Server.HtmlEncode(lojaSelecionada + " - " + ramais.Rows.Count.ToString() + " ramal" + (ramais.Rows.Count == 1 ? "" : "s") + " ativo" + (ramais.Rows.Count == 1 ? "" : "s") + ".");
        litGradeImpressao.Text = MontarGradeImpressao(ramais, lojaSelecionada);
    }

    private string MontarGradeImpressao(DataTable ramais, string lojaSelecionada)
    {
        StringBuilder html = new StringBuilder();
        html.Append("<section class=\"print-directory\">");
        html.Append("<header class=\"print-directory-header\">");
        html.Append("<div><span>Grupo Bali</span><h2>Grade de Ramais</h2>");
        html.Append("<p>Loja: ");
        html.Append(Server.HtmlEncode(lojaSelecionada));
        html.Append(" | Gerado em ");
        html.Append(DateTime.Now.ToString("dd/MM/yyyy HH:mm"));
        html.Append("</p></div>");
        html.Append("</header>");

        if (ramais.Rows.Count == 0)
        {
            html.Append("<div class=\"print-empty\">Nenhum ramal ativo encontrado para o filtro selecionado.</div>");
            html.Append("</section>");
            return html.ToString();
        }

        string setorAtual = "";
        bool tabelaAberta = false;

        foreach (DataRow row in ramais.Rows)
        {
            string setor = row["setor"].ToString();
            if (!String.Equals(setorAtual, setor, StringComparison.OrdinalIgnoreCase))
            {
                if (tabelaAberta)
                {
                    html.Append("</tbody></table></section>");
                }

                setorAtual = setor;
                tabelaAberta = true;
                html.Append("<section class=\"print-sector\">");
                html.Append("<h3>");
                html.Append(Server.HtmlEncode(setorAtual));
                html.Append("</h3>");
                html.Append("<table class=\"print-ramais-table\"><thead><tr>");
                html.Append("<th>Nome</th><th>Ramal</th><th>Loja</th>");
                html.Append("</tr></thead><tbody>");
            }

            html.Append("<tr><td>");
            html.Append(Server.HtmlEncode(row["nome"].ToString()));
            html.Append("</td><td class=\"ramal-number\">");
            html.Append(Server.HtmlEncode(row["ramal"].ToString()));
            html.Append("</td><td>");
            html.Append(Server.HtmlEncode(row["loja"].ToString()));
            html.Append("</td></tr>");
        }

        if (tabelaAberta)
        {
            html.Append("</tbody></table></section>");
        }

        html.Append("</section>");
        return html.ToString();
    }

    private void CarregarRamal(int id)
    {
        DataTable ramal = ExecutarTabela("dbo.ramais_ramal_obter", Param("@id_ramal", SqlDbType.Int, id));
        if (ramal.Rows.Count == 0) return;

        DataRow row = ramal.Rows[0];
        hfRamalId.Value = row["id_ramal"].ToString();
        txtNome.Text = row["nome"].ToString();
        txtRamal.Text = row["ramal"].ToString();
        chkRamalAtivo.Checked = Convert.ToBoolean(row["ativo"]);
        SelecionarValor(ddlRamalLoja, row["id_loja"].ToString());
        SelecionarValor(ddlRamalSetor, row["id_setor"].ToString());
    }

    private void SelecionarValor(DropDownList combo, string valor)
    {
        if (combo.Items.FindByValue(valor) != null)
        {
            combo.SelectedValue = valor;
        }
    }

    private object ValorCombo(DropDownList combo)
    {
        int id;
        if (Int32.TryParse(combo.SelectedValue, out id) && id > 0)
        {
            return id;
        }

        return DBNull.Value;
    }

    private object ObterId(string valor)
    {
        int id;
        if (Int32.TryParse(valor, out id) && id > 0)
        {
            return id;
        }

        return DBNull.Value;
    }

    private int ObterIdNumerico(string valor)
    {
        int id;
        return Int32.TryParse(valor, out id) && id > 0 ? id : 0;
    }

    private bool SenhaManutencaoInformada()
    {
        bool autorizada = String.Equals((hfSenhaManutencao.Value ?? "").Trim(), SenhaManutencaoRamais, StringComparison.Ordinal);
        hfSenhaManutencao.Value = "";

        if (!autorizada)
        {
            MostrarMensagem("Senha incorreta. Para editar ou excluir ramais, informe a senha de manuten\u00e7\u00e3o.", true);
        }

        return autorizada;
    }

    private string ObterChaveViewState()
    {
        HttpCookie cookie = Request.Cookies[ViewStateCookieName];
        string chave = cookie != null ? (cookie.Value ?? "").Trim() : "";
        if (!ChaveViewStateValida(chave))
        {
            chave = Guid.NewGuid().ToString("N");
        }

        HttpCookie resposta = new HttpCookie(ViewStateCookieName, chave);
        resposta.HttpOnly = true;
        resposta.Secure = Request.IsSecureConnection;
        resposta.Path = "/";
        resposta.Expires = DateTime.UtcNow.AddYears(2);
        Response.Cookies.Set(resposta);
        return chave;
    }

    private bool ChaveViewStateValida(string chave)
    {
        if (chave == null || chave.Length != 32) return false;
        for (int i = 0; i < chave.Length; i++)
        {
            char c = chave[i];
            bool hexadecimal = (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
            if (!hexadecimal) return false;
        }

        return true;
    }

    private string ChaveEdicaoRamal(int id)
    {
        return "ramais_edicao_autorizada_" + id.ToString();
    }

    private void AutorizarEdicaoRamal(int id)
    {
        Session[ChaveEdicaoRamal(id)] = true;
    }

    private bool EdicaoRamalAutorizada(int id)
    {
        return id <= 0 || Session[ChaveEdicaoRamal(id)] != null;
    }

    private void LimparAutorizacaoEdicaoRamal(int id)
    {
        if (id > 0)
        {
            Session.Remove(ChaveEdicaoRamal(id));
        }
    }

    private void LimparRamal()
    {
        LimparAutorizacaoEdicaoRamal(ObterIdNumerico(hfRamalId.Value));
        hfRamalId.Value = "";
        txtNome.Text = "";
        txtRamal.Text = "";
        chkRamalAtivo.Checked = true;
        SelecionarValor(ddlRamalLoja, "0");
        SelecionarValor(ddlRamalSetor, "0");
    }

    private void LimparLoja()
    {
        hfLojaId.Value = "";
        txtLojaNome.Text = "";
        chkLojaAtiva.Checked = true;
    }

    private void LimparSetor()
    {
        hfSetorId.Value = "";
        txtSetorNome.Text = "";
        chkSetorAtivo.Checked = true;
    }

    private void NormalizarFormularioRamal()
    {
        txtNome.Text = TextoCurto(txtNome.Text);
        txtRamal.Text = TextoCurto(txtRamal.Text);
    }

    private string TextoCurto(string valor)
    {
        string texto = (valor ?? "").Trim();
        if (texto.Length == 0) return "";
        return String.Join(" ", texto.Split((char[])null, StringSplitOptions.RemoveEmptyEntries));
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

            File.AppendAllText(Path.Combine(pasta, "ramais-erros.log"), linha, Encoding.UTF8);
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
