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
    private const string SenhaEdicao = "@bali2025";
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
            DateTime hoje = DateTime.Today;
            DateTime inicioMes = new DateTime(hoje.Year, hoje.Month, 1);
            txtFiltroInicio.Text = hoje.AddDays(-30).ToString("yyyy-MM-dd");
            txtFiltroFim.Text = hoje.ToString("yyyy-MM-dd");
            txtBiInicio.Text = inicioMes.ToString("yyyy-MM-dd");
            txtBiFim.Text = hoje.ToString("yyyy-MM-dd");
            txtData.Text = hoje.ToString("yyyy-MM-dd");
            string tela = ObterTelaAtual();
            CarregarTelaInicial(tela);
            AplicarTela(tela);
            MostrarAvisoViewStateExpirado();
        }
    }

    protected void btnAtualizarBi_Click(object sender, EventArgs e)
    {
        try
        {
            CarregarBi();
            AplicarTela("bi");
        }
        catch (Exception ex)
        {
            RegistrarErro("Atualizar BI da CI", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("bi");
        }
    }

    protected void btnFiltrar_Click(object sender, EventArgs e)
    {
        gvCis.PageIndex = 0;
        CarregarLista();
        AplicarTela("consulta");
    }

    protected void btnAbrirCodigoRapido_Click(object sender, EventArgs e)
    {
        string termo = TextoCurto(txtCodigoRapido.Text);
        if (termo.Length == 0)
        {
            MostrarMensagem("Informe o c\u00f3digo, ano/n\u00famero ou n\u00famero da CI.", true);
            AplicarTela("consulta");
            return;
        }

        try
        {
            DataTable dados = ExecutarTabela("dbo.ci_comunicacao_localizar",
                Param("@termo", SqlDbType.NVarChar, termo, 60));

            if (dados.Rows.Count == 0)
            {
                MostrarMensagem("Nenhuma CI encontrada para " + termo + ".", true);
                AplicarTela("consulta");
                return;
            }

            int id = Convert.ToInt32(dados.Rows[0]["id_ci"]);
            CarregarCI(id);
            AplicarTela("nova");
            MostrarMensagem("CI localizada. Para alterar, informe a senha quando salvar.", false);
        }
        catch (Exception ex)
        {
            RegistrarErro("Abrir CI pelo c\u00f3digo", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("consulta");
        }
    }

    protected void btnFiltrarAnotacoes_Click(object sender, EventArgs e)
    {
        CarregarAnotacoes();
        AplicarTela("anotacoes");
    }

    protected void btnLimparAnotacoes_Click(object sender, EventArgs e)
    {
        txtAnotacaoBusca.Text = "";
        ddlAnotacaoCategoriaFiltro.SelectedValue = "";
        CarregarAnotacoes();
        AplicarTela("anotacoes");
    }

    protected void btnNovaAnotacao_Click(object sender, EventArgs e)
    {
        LimparAnotacao();
        AplicarTela("anotacoes");
    }

    protected void btnSalvarAnotacao_Click(object sender, EventArgs e)
    {
        try
        {
            string titulo = TextoCurto(txtAnotacaoTitulo.Text);
            string categoria = TextoCurto(txtAnotacaoCategoria.Text);
            string tags = TextoCurto(txtAnotacaoTags.Text);
            string conteudo = TextoLongoEntrada(txtAnotacaoConteudo.Text);
            string criadoPor = TextoCurto(txtAnotacaoCriadoPor.Text);

            if (titulo.Length == 0)
            {
                MostrarMensagem("Informe o nome do texto padr\u00e3o.", true);
                AplicarTela("anotacoes");
                return;
            }

            if (conteudo.Length == 0)
            {
                MostrarMensagem("Informe o conte\u00fado da anota\u00e7\u00e3o.", true);
                AplicarTela("anotacoes");
                return;
            }

            if (titulo.Length > 160 || categoria.Length > 80 || tags.Length > 300 || criadoPor.Length > 160)
            {
                MostrarMensagem("Revise o tamanho dos campos da anota\u00e7\u00e3o.", true);
                AplicarTela("anotacoes");
                return;
            }

            int idAtual = ObterIdAnotacaoAtual();
            DataTable salvo = ExecutarTabela("dbo.ci_anotacao_salvar",
                Param("@id_anotacao", SqlDbType.Int, idAtual > 0 ? (object)idAtual : DBNull.Value),
                Param("@titulo", SqlDbType.NVarChar, titulo, 160),
                Param("@categoria", SqlDbType.NVarChar, categoria, 80),
                Param("@tags", SqlDbType.NVarChar, tags, 300),
                Param("@conteudo", SqlDbType.NVarChar, conteudo),
                Param("@criado_por", SqlDbType.NVarChar, criadoPor, 160));

            CarregarCategoriasAnotacoes();
            CarregarAnotacoes();
            if (salvo.Rows.Count > 0)
            {
                PreencherAnotacao(salvo.Rows[0]);
            }

            MostrarMensagem("Anota\u00e7\u00e3o salva com sucesso.", false);
            AplicarTela("anotacoes");
        }
        catch (Exception ex)
        {
            RegistrarErro("Salvar anota\u00e7\u00e3o de CI", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("anotacoes");
        }
    }

    protected void btnLimpar_Click(object sender, EventArgs e)
    {
        txtFiltroInicio.Text = "";
        txtFiltroFim.Text = "";
        ddlFiltroMarca.SelectedValue = "";
        ddlFiltroStatus.SelectedValue = "";
        ddlFiltroCategoria.SelectedValue = "";
        ddlFiltroPrioridade.SelectedValue = "";
        txtFiltroOrigem.Text = "";
        txtFiltroDestino.Text = "";
        txtFiltroCriadoPor.Text = "";
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

    protected void btnAplicarModeloBanco_Click(object sender, EventArgs e)
    {
        int idModelo;
        if (!Int32.TryParse(ddlModelosCI.SelectedValue, out idModelo) || idModelo <= 0)
        {
            MostrarMensagem("Selecione um modelo para aplicar.", true);
            AplicarTela("nova");
            return;
        }

        try
        {
            if (!AplicarModelo(idModelo))
            {
                AplicarTela("nova");
                return;
            }

            AplicarTela("nova");
            MostrarMensagem("Modelo aplicado. Revise os dados antes de salvar a CI.", false);
        }
        catch (Exception ex)
        {
            RegistrarErro("Aplicar modelo de CI", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("nova");
        }
    }

    protected void lnkSalvarModelo_Click(object sender, EventArgs e)
    {
        if (!SenhaInformada())
        {
            MostrarMensagem("Informe a senha correta para salvar modelos de CI.", true);
            AplicarTela("nova");
            return;
        }

        try
        {
            string nomeModelo = TextoCurto(txtModeloNome.Text);
            if (nomeModelo.Length == 0)
            {
                MostrarMensagem("Informe o nome do modelo antes de salvar.", true);
                AplicarTela("nova");
                return;
            }

            if (TextoCurto(txtAssunto.Text).Length == 0 || TextoLongoEntrada(txtCorpo.Text).Length == 0)
            {
                MostrarMensagem("Preencha assunto e texto para transformar esta CI em modelo.", true);
                AplicarTela("nova");
                return;
            }

            int idModelo;
            object idParametro = Int32.TryParse(ddlModelosCI.SelectedValue, out idModelo) && idModelo > 0
                ? (object)idModelo
                : DBNull.Value;

            DataTable modelo = ExecutarTabela("dbo.ci_modelo_salvar",
                Param("@id_modelo", SqlDbType.Int, idParametro),
                Param("@nome", SqlDbType.NVarChar, nomeModelo, 120),
                Param("@origem_marca", SqlDbType.NVarChar, ddlMarca.SelectedValue, 40),
                Param("@categoria", SqlDbType.NVarChar, ddlCategoria.SelectedValue, 60),
                Param("@prioridade", SqlDbType.NVarChar, ddlPrioridade.SelectedValue, 20),
                Param("@assunto", SqlDbType.NVarChar, TextoCurto(txtAssunto.Text), 200),
                Param("@corpo", SqlDbType.NVarChar, TextoLongoEntrada(txtCorpo.Text)),
                Param("@providencias", SqlDbType.NVarChar, TextoLongoEntrada(txtProvidencias.Text)),
                Param("@observacoes", SqlDbType.NVarChar, TextoLongoEntrada(txtObservacoes.Text)));

            CarregarModelos();
            if (modelo.Rows.Count > 0)
            {
                Selecionar(ddlModelosCI, modelo.Rows[0]["id_modelo"].ToString());
            }

            AplicarTela("nova");
            MostrarMensagem("Modelo salvo com sucesso.", false);
        }
        catch (Exception ex)
        {
            RegistrarErro("Salvar modelo de CI", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("nova");
        }
    }

    protected void lnkExcluirModelo_Click(object sender, EventArgs e)
    {
        if (!SenhaInformada())
        {
            MostrarMensagem("Informe a senha correta para excluir modelos de CI.", true);
            AplicarTela("nova");
            return;
        }

        int idModelo;
        if (!Int32.TryParse(ddlModelosCI.SelectedValue, out idModelo) || idModelo <= 0)
        {
            MostrarMensagem("Selecione um modelo para excluir.", true);
            AplicarTela("nova");
            return;
        }

        try
        {
            ExecutarSemRetorno("dbo.ci_modelo_excluir", Param("@id_modelo", SqlDbType.Int, idModelo));
            txtModeloNome.Text = "";
            CarregarModelos();
            AplicarTela("nova");
            MostrarMensagem("Modelo exclu\u00eddo com sucesso.", false);
        }
        catch (Exception ex)
        {
            RegistrarErro("Excluir modelo de CI", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("nova");
        }
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
                Param("@status_ci", SqlDbType.NVarChar, ddlStatusCI.SelectedValue, 20),
                Param("@corpo", SqlDbType.NVarChar, TextoLongoEntrada(txtCorpo.Text)),
                Param("@providencias", SqlDbType.NVarChar, TextoLongoEntrada(txtProvidencias.Text)),
                Param("@observacoes", SqlDbType.NVarChar, TextoLongoEntrada(txtObservacoes.Text)),
                Param("@criado_por", SqlDbType.NVarChar, TextoCurto(txtCriadoPor.Text), 160));

            string codigo = salvo.Rows.Count > 0 ? salvo.Rows[0]["codigo_ci"].ToString() : "CI";
            int idSalvo = salvo.Rows.Count > 0 ? Convert.ToInt32(salvo.Rows[0]["id_ci"]) : 0;
            LimparAutorizacaoEdicaoCI(id);
            LimparFormulario();
            CarregarConsultaEssencial();
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

    protected void btnSalvarRascunhoBanco_Click(object sender, EventArgs e)
    {
        try
        {
            Selecionar(ddlStatusCI, "Rascunho");
            PrepararRascunhoParcial();
            btnSalvar_Click(sender, e);
        }
        catch (Exception ex)
        {
            RegistrarErro("Salvar rascunho de CI", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("nova");
        }
    }

    protected void gvCis_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string argumento = Convert.ToString(e.CommandArgument);
        int id;
        string marcaDuplicacao = "";

        if (e.CommandName == "DuplicarMarcaCI")
        {
            string[] partes = argumento.Split('|');
            if (partes.Length < 2 || !Int32.TryParse(partes[0], out id)) return;
            marcaDuplicacao = partes[1];
        }
        else
        {
            if (!Int32.TryParse(argumento, out id)) return;
        }

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
                CarregarCIDuplicada(id, "");
                AplicarTela("nova");
                MostrarMensagem("CI duplicada como novo rascunho. Revise os dados antes de salvar.", false);
            }
            else if (e.CommandName == "DuplicarMarcaCI")
            {
                CarregarCIDuplicada(id, marcaDuplicacao);
                AplicarTela("nova");
                MostrarMensagem("CI duplicada como rascunho para " + marcaDuplicacao + ". Revise os dados antes de salvar.", false);
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
                CarregarConsultaEssencial();
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
            string classe = "ci-status-active";
            if (status.Equals("Cancelada", StringComparison.OrdinalIgnoreCase)) classe = "ci-status-canceled";
            else if (status.Equals("Rascunho", StringComparison.OrdinalIgnoreCase)) classe = "ci-status-draft";
            else if (status.Equals("Revisada", StringComparison.OrdinalIgnoreCase)) classe = "ci-status-reviewed";
            e.Row.Cells[5].CssClass = "status-cell";
            e.Row.Cells[5].Text = "<span class=\"status-badge " + classe + "\">" + Server.HtmlEncode(status) + "</span>";
        }

        if (status.Equals("Cancelada", StringComparison.OrdinalIgnoreCase))
        {
            LinkButton editar = e.Row.FindControl("lnkEditar") as LinkButton;
            LinkButton cancelar = e.Row.FindControl("lnkCancelar") as LinkButton;
            if (editar != null) editar.Visible = false;
            if (cancelar != null) cancelar.Visible = false;
        }
    }

    protected void gvAnotacoes_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id;
        if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id) || id <= 0) return;

        try
        {
            if (e.CommandName == "AbrirAnotacao")
            {
                CarregarAnotacao(id);
                AplicarTela("anotacoes");
                MostrarMensagem("Anota\u00e7\u00e3o carregada. Use o bot\u00e3o copiar texto quando precisar reutilizar.", false);
            }
            else if (e.CommandName == "UsarAnotacaoCI")
            {
                UsarAnotacaoNaCI(id);
                AplicarTela("nova");
                MostrarMensagem("Anota\u00e7\u00e3o aplicada na nova CI como rascunho. Revise os campos antes de salvar.", false);
            }
            else if (e.CommandName == "DuplicarAnotacao")
            {
                DuplicarAnotacao(id);
                AplicarTela("anotacoes");
                MostrarMensagem("Anota\u00e7\u00e3o duplicada no bloco. Revise e salve como novo texto padr\u00e3o.", false);
            }
            else if (e.CommandName == "FavoritarAnotacao")
            {
                ExecutarTabela("dbo.ci_anotacao_alternar_favorito", Param("@id_anotacao", SqlDbType.Int, id));
                CarregarCategoriasAnotacoes();
                CarregarAnotacoes();
                AplicarTela("anotacoes");
                MostrarMensagem("Favorito atualizado.", false);
            }
            else if (e.CommandName == "ExcluirAnotacao")
            {
                ExecutarSemRetorno("dbo.ci_anotacao_excluir", Param("@id_anotacao", SqlDbType.Int, id));
                if (ObterIdAnotacaoAtual() == id)
                {
                    LimparAnotacao();
                }

                CarregarCategoriasAnotacoes();
                CarregarAnotacoes();
                AplicarTela("anotacoes");
                MostrarMensagem("Anota\u00e7\u00e3o exclu\u00edda com sucesso.", false);
            }
        }
        catch (Exception ex)
        {
            RegistrarErro("A\u00e7\u00e3o em anota\u00e7\u00f5es de CI", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("anotacoes");
        }
    }

    protected void gvAnotacoes_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        AplicarRotulosMobile(gvAnotacoes, e.Row);
        TruncarCelulaLonga(e.Row, 4, 140);

        bool favorito = false;
        object valorFavorito = DataBinder.Eval(e.Row.DataItem, "favorito");
        if (valorFavorito != DBNull.Value && valorFavorito != null)
        {
            favorito = Convert.ToBoolean(valorFavorito);
        }

        if (favorito)
        {
            e.Row.CssClass = (e.Row.CssClass + " is-favorite-row").Trim();
        }

        LinkButton favoritar = e.Row.FindControl("lnkFavoritarAnotacao") as LinkButton;
        if (favoritar != null)
        {
            favoritar.Text = favorito ? "Remover favorito" : "Favoritar";
        }
    }

    protected void gvHistorico_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        AplicarRotulosMobile(gvHistorico, e.Row);
    }

    protected void btnRegistrarCiencia_Click(object sender, EventArgs e)
    {
        int idCi = ObterIdAtual();
        if (idCi <= 0)
        {
            MostrarMensagem("Salve a CI antes de registrar ci\u00eancia.", true);
            AplicarTela("nova");
            return;
        }

        string setor = TextoCurto(txtCienciaSetor.Text);
        string responsavel = TextoCurto(txtCienciaResponsavel.Text);
        if (setor.Length == 0 || responsavel.Length == 0)
        {
            MostrarMensagem("Informe setor e respons\u00e1vel para registrar ci\u00eancia.", true);
            AplicarTela("nova");
            return;
        }

        try
        {
            ExecutarSemRetorno("dbo.ci_ciencia_registrar",
                Param("@id_ci", SqlDbType.Int, idCi),
                Param("@setor", SqlDbType.NVarChar, setor, 120),
                Param("@responsavel", SqlDbType.NVarChar, responsavel, 160),
                Param("@observacao", SqlDbType.NVarChar, TextoCurto(txtCienciaObservacao.Text), 500));

            txtCienciaSetor.Text = "";
            txtCienciaResponsavel.Text = "";
            txtCienciaObservacao.Text = "";
            CarregarCiencias(idCi);
            AplicarTela("nova");
            MostrarMensagem("Ci\u00eancia registrada com sucesso.", false);
        }
        catch (Exception ex)
        {
            RegistrarErro("Registrar ci\u00eancia de CI", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("nova");
        }
    }

    protected void gvCiencias_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "ExcluirCiencia") return;

        if (!SenhaInformada())
        {
            MostrarMensagem("Informe a senha correta para excluir ci\u00eancias da CI.", true);
            AplicarTela("nova");
            return;
        }

        int idCiencia;
        if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out idCiencia) || idCiencia <= 0)
        {
            MostrarMensagem("Registro de ci\u00eancia inv\u00e1lido para exclus\u00e3o.", true);
            AplicarTela("nova");
            return;
        }

        try
        {
            ExecutarSemRetorno("dbo.ci_ciencia_excluir", Param("@id_ciencia", SqlDbType.Int, idCiencia));
            int idCi = ObterIdAtual();
            if (idCi > 0) CarregarCiencias(idCi);
            AplicarTela("nova");
            MostrarMensagem("Registro de ci\u00eancia removido.", false);
        }
        catch (Exception ex)
        {
            RegistrarErro("Excluir ci\u00eancia de CI", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("nova");
        }
    }

    protected void gvCiencias_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        AplicarRotulosMobile(gvCiencias, e.Row);
    }

    protected void gvHistoricoCampos_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        AplicarRotulosMobile(gvHistoricoCampos, e.Row);
        TruncarCelulaLonga(e.Row, 2, 160);
        TruncarCelulaLonga(e.Row, 3, 160);
    }

    private void CarregarConsultaEssencial()
    {
        CarregarResumo();
        CarregarLista();
    }

    private void CarregarTelaInicial(string tela)
    {
        CarregarResumo();

        if (String.Equals(tela, "bi", StringComparison.OrdinalIgnoreCase))
        {
            CarregarBi();
            return;
        }

        if (String.Equals(tela, "nova", StringComparison.OrdinalIgnoreCase))
        {
            CarregarModelos();
            return;
        }

        if (String.Equals(tela, "anotacoes", StringComparison.OrdinalIgnoreCase))
        {
            CarregarCategoriasAnotacoes();
            CarregarAnotacoes();
            return;
        }

        CarregarLista();
    }

    private string ObterTelaAtual()
    {
        string tela = (Request.QueryString["view"] ?? "").Trim().ToLowerInvariant();
        if (tela == "nova" || tela == "cadastro") return "nova";
        if (tela == "bi") return "bi";
        if (tela == "anotacoes" || tela == "anotacao") return "anotacoes";
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
        bool mostrarCadastro = String.Equals(tela, "nova", StringComparison.OrdinalIgnoreCase) ||
            String.Equals(tela, "cadastro", StringComparison.OrdinalIgnoreCase);
        bool mostrarBi = String.Equals(tela, "bi", StringComparison.OrdinalIgnoreCase);
        bool mostrarAnotacoes = String.Equals(tela, "anotacoes", StringComparison.OrdinalIgnoreCase) ||
            String.Equals(tela, "anotacao", StringComparison.OrdinalIgnoreCase);

        pnlBi.Visible = mostrarBi;
        pnlAnotacoes.Visible = mostrarAnotacoes;
        pnlConsulta.Visible = !mostrarCadastro && !mostrarBi && !mostrarAnotacoes;
        pnlCadastro.Visible = mostrarCadastro;
        ViewState["CiTela"] = mostrarCadastro ? "nova" : (mostrarBi ? "bi" : (mostrarAnotacoes ? "anotacoes" : "consulta"));
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
        litRascunhos.Text = ValorResumo(resumo.Rows[0], "cis_rascunho");
        litRevisadas.Text = ValorResumo(resumo.Rows[0], "cis_revisadas");
        litFiat.Text = ValorResumo(resumo.Rows[0], "fiat_ativas");
        litJeep.Text = ValorResumo(resumo.Rows[0], "jeep_ativas");
        litByd.Text = ValorResumo(resumo.Rows[0], "byd_ativas");
    }

    private void CarregarBi()
    {
        DateTime inicio;
        DateTime fim;
        bool inicioValido = ObterData(txtBiInicio.Text, out inicio);
        bool fimValido = ObterData(txtBiFim.Text, out fim);

        if (inicioValido && fimValido && inicio > fim)
        {
            DateTime troca = inicio;
            inicio = fim;
            fim = troca;
            txtBiInicio.Text = inicio.ToString("yyyy-MM-dd");
            txtBiFim.Text = fim.ToString("yyyy-MM-dd");
        }

        object dtInicio = inicioValido ? (object)inicio : DBNull.Value;
        object dtFim = fimValido ? (object)fim : DBNull.Value;

        DataSet dados = ExecutarDataSet("dbo.ci_comunicacao_bi",
            Param("@dt_inicio", SqlDbType.Date, dtInicio),
            Param("@dt_fim", SqlDbType.Date, dtFim),
            Param("@origem_marca", SqlDbType.NVarChar, ddlBiMarca.SelectedValue, 40));

        if (dados.Tables.Count == 0 || dados.Tables[0].Rows.Count == 0)
        {
            LimparBi();
            return;
        }

        DataRow resumo = dados.Tables[0].Rows[0];
        litBiTotal.Text = ValorResumo(resumo, "total_cis");
        litBiEmitidas.Text = ValorResumo(resumo, "emitidas");
        litBiRascunhos.Text = ValorResumo(resumo, "rascunhos");
        litBiRevisadas.Text = ValorResumo(resumo, "revisadas");
        litBiCanceladas.Text = ValorResumo(resumo, "canceladas");
        litBiCiencias.Text = ValorResumo(resumo, "ciencias");

        litBiMarcas.Text = RenderizarBarrasBi(TabelaBi(dados, 1));
        litBiCategorias.Text = RenderizarBarrasBi(TabelaBi(dados, 2));
        litBiPrioridades.Text = RenderizarBarrasBi(TabelaBi(dados, 3));
        litBiDias.Text = RenderizarBarrasBi(TabelaBi(dados, 4));
        litBiDestinos.Text = RenderizarBarrasBi(TabelaBi(dados, 5));
        litBiCriadores.Text = RenderizarBarrasBi(TabelaBi(dados, 6));

        string marca = ddlBiMarca.SelectedValue.Length > 0 ? " | " + ddlBiMarca.SelectedValue : "";
        string periodo = (inicioValido ? inicio.ToString("dd/MM/yyyy") : "sem in\u00edcio") +
            " a " +
            (fimValido ? fim.ToString("dd/MM/yyyy") : "sem fim") +
            marca;
        litBiPeriodo.Text = "Per\u00edodo analisado: " + Server.HtmlEncode(periodo) + ".";
    }

    private DataTable TabelaBi(DataSet dados, int indice)
    {
        return dados.Tables.Count > indice ? dados.Tables[indice] : new DataTable();
    }

    private void LimparBi()
    {
        litBiTotal.Text = "0";
        litBiEmitidas.Text = "0";
        litBiRascunhos.Text = "0";
        litBiRevisadas.Text = "0";
        litBiCanceladas.Text = "0";
        litBiCiencias.Text = "0";
        string vazio = "<p class=\"empty-bi\">Nenhum dado encontrado no per&iacute;odo.</p>";
        litBiMarcas.Text = vazio;
        litBiCategorias.Text = vazio;
        litBiPrioridades.Text = vazio;
        litBiDias.Text = vazio;
        litBiDestinos.Text = vazio;
        litBiCriadores.Text = vazio;
    }

    private string RenderizarBarrasBi(DataTable dados)
    {
        if (dados == null || dados.Rows.Count == 0)
        {
            return "<p class=\"empty-bi\">Nenhum dado encontrado.</p>";
        }

        int maior = 0;
        foreach (DataRow row in dados.Rows)
        {
            int total;
            if (Int32.TryParse(Convert.ToString(row["total"]), out total) && total > maior)
            {
                maior = total;
            }
        }

        if (maior <= 0) maior = 1;

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"bar-list\">");
        foreach (DataRow row in dados.Rows)
        {
            string rotulo = Server.HtmlEncode(Convert.ToString(row["rotulo"] ?? ""));
            int total;
            if (!Int32.TryParse(Convert.ToString(row["total"]), out total)) total = 0;
            int largura = Math.Max(4, (int)Math.Round((total * 100.0) / maior));

            html.Append("<div class=\"bar-row\">");
            html.Append("<div class=\"bar-meta\"><span>");
            html.Append(rotulo.Length > 0 ? rotulo : "N\u00e3o informado");
            html.Append("</span><strong>");
            html.Append(total.ToString());
            html.Append("</strong></div><div class=\"bar-track\"><span style=\"width:");
            html.Append(largura.ToString(CultureInfo.InvariantCulture));
            html.Append("%\"></span></div></div>");
        }
        html.Append("</div>");
        return html.ToString();
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
            Param("@categoria", SqlDbType.NVarChar, ddlFiltroCategoria.SelectedValue, 60),
            Param("@prioridade", SqlDbType.NVarChar, ddlFiltroPrioridade.SelectedValue, 20),
            Param("@status_ci", SqlDbType.NVarChar, ddlFiltroStatus.SelectedValue, 20),
            Param("@origem_area", SqlDbType.NVarChar, TextoCurto(txtFiltroOrigem.Text), 120),
            Param("@destino_area", SqlDbType.NVarChar, TextoCurto(txtFiltroDestino.Text), 120),
            Param("@criado_por", SqlDbType.NVarChar, TextoCurto(txtFiltroCriadoPor.Text), 160),
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
        CarregarModelos();
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
        Selecionar(ddlStatusCI, row["status_ci"].ToString());
        txtCorpo.Text = row["corpo"].ToString();
        txtProvidencias.Text = row["providencias"].ToString();
        txtObservacoes.Text = row["observacoes"].ToString();
        txtCriadoPor.Text = row["criado_por"].ToString();
        LimparChecklistFinal();
        litTituloForm.Text = "Editar " + row["codigo_ci"].ToString();
        CarregarCiencias(id);
        CarregarHistorico(id);
    }

    private void CarregarCIDuplicada(int id, string marcaDestino)
    {
        CarregarModelos();
        DataTable dados = ExecutarTabela("dbo.ci_comunicacao_obter", Param("@id_ci", SqlDbType.Int, id));
        if (dados.Rows.Count == 0) return;

        DataRow row = dados.Rows[0];
        LimparAutorizacaoEdicaoCI(ObterIdAtual());
        hfCiId.Value = "";
        Selecionar(ddlMarca, marcaDestino.Length > 0 ? marcaDestino : row["origem_marca"].ToString());
        txtData.Text = DateTime.Today.ToString("yyyy-MM-dd");
        txtOrigemArea.Text = row["origem_area"].ToString();
        txtOrigemResponsavel.Text = row["origem_responsavel"].ToString();
        txtDestinoArea.Text = row["destino_area"].ToString();
        txtDestinatario.Text = row["destinatario"].ToString();
        txtAssunto.Text = row["assunto"].ToString();
        Selecionar(ddlCategoria, row["categoria"].ToString());
        Selecionar(ddlPrioridade, row["prioridade"].ToString());
        ddlStatusCI.SelectedValue = "Rascunho";
        txtCorpo.Text = row["corpo"].ToString();
        txtProvidencias.Text = row["providencias"].ToString();
        txtObservacoes.Text = row["observacoes"].ToString();
        txtCriadoPor.Text = row["criado_por"].ToString();
        LimparChecklistFinal();
        litTituloForm.Text = "Nova CI baseada em " + row["codigo_ci"].ToString();
        pnlCiencia.Visible = false;
        gvCiencias.DataSource = null;
        gvCiencias.DataBind();
        pnlHistorico.Visible = false;
        gvHistorico.DataSource = null;
        gvHistorico.DataBind();
        gvHistoricoCampos.DataSource = null;
        gvHistoricoCampos.DataBind();
    }

    private void CarregarHistorico(int id)
    {
        DataTable historico = ExecutarTabela("dbo.ci_comunicacao_historico_listar", Param("@id_ci", SqlDbType.Int, id));
        DataTable historicoCampos = ExecutarTabela("dbo.ci_comunicacao_historico_campos_listar", Param("@id_ci", SqlDbType.Int, id));
        pnlHistorico.Visible = true;
        gvHistorico.DataSource = historico;
        gvHistorico.DataBind();
        gvHistoricoCampos.DataSource = historicoCampos;
        gvHistoricoCampos.DataBind();
    }

    private void CarregarModelos()
    {
        DataTable modelos = ExecutarTabela("dbo.ci_modelo_listar");
        ddlModelosCI.DataSource = modelos;
        ddlModelosCI.DataTextField = "nome";
        ddlModelosCI.DataValueField = "id_modelo";
        ddlModelosCI.DataBind();
        ddlModelosCI.Items.Insert(0, new ListItem("Selecione um modelo", ""));
    }

    private bool AplicarModelo(int idModelo)
    {
        DataTable modelo = ExecutarTabela("dbo.ci_modelo_obter", Param("@id_modelo", SqlDbType.Int, idModelo));
        if (modelo.Rows.Count == 0)
        {
            MostrarMensagem("Modelo n\u00e3o encontrado ou inativo.", true);
            return false;
        }

        DataRow row = modelo.Rows[0];
        if (row["origem_marca"].ToString().Length > 0)
        {
            Selecionar(ddlMarca, row["origem_marca"].ToString());
        }

        Selecionar(ddlCategoria, row["categoria"].ToString());
        Selecionar(ddlPrioridade, row["prioridade"].ToString());
        txtAssunto.Text = row["assunto"].ToString();
        txtCorpo.Text = row["corpo"].ToString();
        txtProvidencias.Text = row["providencias"].ToString();
        txtObservacoes.Text = row["observacoes"].ToString();
        txtModeloNome.Text = row["nome"].ToString();
        return true;
    }

    private void CarregarCiencias(int id)
    {
        DataTable ciencias = ExecutarTabela("dbo.ci_ciencia_listar", Param("@id_ci", SqlDbType.Int, id));
        pnlCiencia.Visible = true;
        gvCiencias.DataSource = ciencias;
        gvCiencias.DataBind();
    }

    private void CarregarCategoriasAnotacoes()
    {
        string categoriaAtual = ddlAnotacaoCategoriaFiltro.SelectedValue;
        DataTable categorias = ExecutarTabela("dbo.ci_anotacao_categorias");
        ddlAnotacaoCategoriaFiltro.Items.Clear();
        ddlAnotacaoCategoriaFiltro.Items.Add(new ListItem("Todas", ""));
        foreach (DataRow row in categorias.Rows)
        {
            string categoria = Convert.ToString(row["categoria"]);
            if (categoria.Length > 0)
            {
                ddlAnotacaoCategoriaFiltro.Items.Add(new ListItem(categoria, categoria));
            }
        }

        if (ddlAnotacaoCategoriaFiltro.Items.FindByValue(categoriaAtual) != null)
        {
            ddlAnotacaoCategoriaFiltro.SelectedValue = categoriaAtual;
        }
    }

    private void CarregarAnotacoes()
    {
        DataTable anotacoes = ExecutarTabela("dbo.ci_anotacao_listar",
            Param("@termo", SqlDbType.NVarChar, TextoCurto(txtAnotacaoBusca.Text), 160),
            Param("@categoria", SqlDbType.NVarChar, ddlAnotacaoCategoriaFiltro.SelectedValue, 80));

        gvAnotacoes.DataSource = anotacoes;
        gvAnotacoes.DataBind();
        AtualizarResumoAnotacoes(anotacoes.Rows.Count);
    }

    private void AtualizarResumoAnotacoes(int total)
    {
        if (total == 0)
        {
            litResultadoAnotacoes.Text = "Nenhuma anota\u00e7\u00e3o encontrada. Cadastre um texto padr\u00e3o para reutilizar nas CIs.";
            return;
        }

        litResultadoAnotacoes.Text = total == 1
            ? "1 anota\u00e7\u00e3o dispon\u00edvel."
            : total.ToString() + " anota\u00e7\u00f5es dispon\u00edveis.";
    }

    private void CarregarAnotacao(int id)
    {
        DataTable dados = ExecutarTabela("dbo.ci_anotacao_obter", Param("@id_anotacao", SqlDbType.Int, id));
        if (dados.Rows.Count == 0)
        {
            MostrarMensagem("Anota\u00e7\u00e3o n\u00e3o encontrada.", true);
            return;
        }

        PreencherAnotacao(dados.Rows[0]);
    }

    private void UsarAnotacaoNaCI(int id)
    {
        DataTable dados = ExecutarTabela("dbo.ci_anotacao_registrar_uso", Param("@id_anotacao", SqlDbType.Int, id));
        if (dados.Rows.Count == 0)
        {
            MostrarMensagem("Anota\u00e7\u00e3o n\u00e3o encontrada para usar na CI.", true);
            return;
        }

        DataRow row = dados.Rows[0];
        CarregarModelos();
        LimparFormulario();
        hfCiId.Value = "";
        txtData.Text = DateTime.Today.ToString("yyyy-MM-dd");
        txtAssunto.Text = row["titulo"].ToString();
        txtCorpo.Text = row["conteudo"].ToString();
        ddlStatusCI.SelectedValue = "Rascunho";
        Selecionar(ddlCategoria, row["categoria"].ToString());
        LimparChecklistFinal();
        litTituloForm.Text = "Nova CI baseada em anota\u00e7\u00e3o";
    }

    private void DuplicarAnotacao(int id)
    {
        DataTable dados = ExecutarTabela("dbo.ci_anotacao_obter", Param("@id_anotacao", SqlDbType.Int, id));
        if (dados.Rows.Count == 0)
        {
            MostrarMensagem("Anota\u00e7\u00e3o n\u00e3o encontrada para duplicar.", true);
            return;
        }

        DataRow row = dados.Rows[0];
        hfAnotacaoId.Value = "";
        txtAnotacaoTitulo.Text = "C\u00f3pia de " + row["titulo"].ToString();
        txtAnotacaoCategoria.Text = row["categoria"].ToString();
        txtAnotacaoTags.Text = row["tags"].ToString();
        txtAnotacaoConteudo.Text = row["conteudo"].ToString();
        txtAnotacaoCriadoPor.Text = row["criado_por"].ToString();
        litTituloAnotacao.Text = "Nova anota\u00e7\u00e3o baseada em " + row["titulo"].ToString();
        litAnotacaoUso.Text = "";
    }

    private void PreencherAnotacao(DataRow row)
    {
        hfAnotacaoId.Value = row["id_anotacao"].ToString();
        txtAnotacaoTitulo.Text = row["titulo"].ToString();
        txtAnotacaoCategoria.Text = row["categoria"].ToString();
        txtAnotacaoTags.Text = row["tags"].ToString();
        txtAnotacaoConteudo.Text = row["conteudo"].ToString();
        txtAnotacaoCriadoPor.Text = row["criado_por"].ToString();
        litTituloAnotacao.Text = "Editar " + row["titulo"].ToString();
        litAnotacaoUso.Text = MontarResumoUsoAnotacao(row);
    }

    private void LimparAnotacao()
    {
        hfAnotacaoId.Value = "";
        txtAnotacaoTitulo.Text = "";
        txtAnotacaoCategoria.Text = "";
        txtAnotacaoTags.Text = "";
        txtAnotacaoConteudo.Text = "";
        txtAnotacaoCriadoPor.Text = "";
        litTituloAnotacao.Text = "Nova anota\u00e7\u00e3o";
        litAnotacaoUso.Text = "";
    }

    private string MontarResumoUsoAnotacao(DataRow row)
    {
        int usos = 0;
        if (row.Table.Columns.Contains("qtde_usos") && row["qtde_usos"] != DBNull.Value)
        {
            Int32.TryParse(row["qtde_usos"].ToString(), out usos);
        }

        string texto = "<span class=\"note-usage\">" + usos.ToString() + " uso" + (usos == 1 ? "" : "s");
        if (row.Table.Columns.Contains("dt_ultimo_uso") && row["dt_ultimo_uso"] != DBNull.Value)
        {
            texto += " | &uacute;ltimo uso em " + Convert.ToDateTime(row["dt_ultimo_uso"]).ToString("dd/MM/yyyy HH:mm");
        }

        texto += "</span>";
        return texto;
    }

    private int ObterIdAnotacaoAtual()
    {
        int id;
        return Int32.TryParse(hfAnotacaoId.Value, out id) ? id : 0;
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
        ddlStatusCI.SelectedValue = "Emitida";
        txtCorpo.Text = "";
        txtProvidencias.Text = "";
        txtObservacoes.Text = "";
        txtCriadoPor.Text = "";
        txtModeloNome.Text = "";
        LimparChecklistFinal();
        txtCienciaSetor.Text = "";
        txtCienciaResponsavel.Text = "";
        txtCienciaObservacao.Text = "";
        pnlCiencia.Visible = false;
        gvCiencias.DataSource = null;
        gvCiencias.DataBind();
        litTituloForm.Text = "Nova CI";
        pnlHistorico.Visible = false;
        gvHistorico.DataSource = null;
        gvHistorico.DataBind();
        gvHistoricoCampos.DataSource = null;
        gvHistoricoCampos.DataBind();
    }

    private void TruncarCelulaLonga(GridViewRow row, int indice, int limite)
    {
        if (row.Cells.Count <= indice) return;
        string texto = Server.HtmlDecode(row.Cells[indice].Text ?? "").Trim();
        if (texto.Length <= limite) return;
        row.Cells[indice].ToolTip = texto;
        row.Cells[indice].Text = Server.HtmlEncode(texto.Substring(0, limite) + "...");
    }

    private string ValidarCampos()
    {
        if (!ValorPermitido(ddlMarca, ddlMarca.SelectedValue)) return "Selecione uma marca v\u00e1lida.";
        if (!ValorPermitido(ddlCategoria, ddlCategoria.SelectedValue)) return "Selecione uma categoria v\u00e1lida.";
        if (!ValorPermitido(ddlPrioridade, ddlPrioridade.SelectedValue)) return "Selecione uma prioridade v\u00e1lida.";
        if (!ValorPermitido(ddlStatusCI, ddlStatusCI.SelectedValue)) return "Selecione um status v\u00e1lido para a CI.";
        bool rascunho = String.Equals(ddlStatusCI.SelectedValue, "Rascunho", StringComparison.OrdinalIgnoreCase);
        if (!rascunho)
        {
            if (TextoCurto(txtOrigemArea.Text).Length == 0) return "Informe a \u00e1rea de origem.";
            if (TextoCurto(txtOrigemResponsavel.Text).Length == 0) return "Informe o respons\u00e1vel pela origem.";
            if (TextoCurto(txtDestinoArea.Text).Length == 0) return "Informe a \u00e1rea de destino.";
            if (TextoCurto(txtDestinatario.Text).Length == 0) return "Informe o destinat\u00e1rio.";
            if (TextoCurto(txtAssunto.Text).Length == 0) return "Informe o assunto.";
            if (TextoLongoEntrada(txtCorpo.Text).Length == 0) return "Informe o texto da comunica\u00e7\u00e3o.";
            if (!ChecklistFinalConfirmado()) return "Confirme o checklist final antes de emitir ou revisar a CI.";
        }

        if (TextoCurto(txtOrigemArea.Text).Length > 120) return "A \u00e1rea de origem deve ter at\u00e9 120 caracteres.";
        if (TextoCurto(txtOrigemResponsavel.Text).Length > 160) return "O respons\u00e1vel deve ter at\u00e9 160 caracteres.";
        if (TextoCurto(txtDestinoArea.Text).Length > 120) return "A \u00e1rea de destino deve ter at\u00e9 120 caracteres.";
        if (TextoCurto(txtDestinatario.Text).Length > 160) return "O destinat\u00e1rio deve ter at\u00e9 160 caracteres.";
        if (TextoCurto(txtAssunto.Text).Length > 200) return "O assunto deve ter at\u00e9 200 caracteres.";
        if (TextoCurto(txtCriadoPor.Text).Length > 160) return "O campo criado por deve ter at\u00e9 160 caracteres.";
        if (TextoLongoEntrada(txtCorpo.Text).Length > 6000) return "Reduza o texto da comunica\u00e7\u00e3o para at\u00e9 6000 caracteres.";
        if (TextoLongoEntrada(txtProvidencias.Text).Length > 2500) return "Reduza as provid\u00eancias solicitadas para at\u00e9 2500 caracteres.";
        if (TextoLongoEntrada(txtObservacoes.Text).Length > 1800) return "Reduza as observa\u00e7\u00f5es para at\u00e9 1800 caracteres.";
        if (!rascunho &&
            (ContemMarcadorModelo(txtAssunto.Text) ||
             ContemMarcadorModelo(txtCorpo.Text) ||
             ContemMarcadorModelo(txtProvidencias.Text) ||
             ContemMarcadorModelo(txtObservacoes.Text)))
        {
            return "Substitua os trechos entre colchetes antes de salvar a CI.";
        }

        return "";
    }

    private void PrepararRascunhoParcial()
    {
        if (TextoCurto(txtData.Text).Length == 0)
        {
            txtData.Text = DateTime.Today.ToString("yyyy-MM-dd");
        }

        if (TextoCurto(txtOrigemArea.Text).Length == 0) txtOrigemArea.Text = "A definir";
        if (TextoCurto(txtOrigemResponsavel.Text).Length == 0) txtOrigemResponsavel.Text = "A definir";
        if (TextoCurto(txtDestinoArea.Text).Length == 0) txtDestinoArea.Text = "A definir";
        if (TextoCurto(txtDestinatario.Text).Length == 0) txtDestinatario.Text = "A definir";
        if (TextoCurto(txtAssunto.Text).Length == 0) txtAssunto.Text = "Rascunho de CI";
        if (TextoLongoEntrada(txtCorpo.Text).Length == 0) txtCorpo.Text = "Texto a definir.";
    }

    private bool ChecklistFinalConfirmado()
    {
        return chkChecklistDocumento.Checked && chkChecklistDestino.Checked && chkChecklistTexto.Checked;
    }

    private void LimparChecklistFinal()
    {
        chkChecklistDocumento.Checked = false;
        chkChecklistDestino.Checked = false;
        chkChecklistTexto.Checked = false;
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

    private DataSet ExecutarDataSet(string procedure, params SqlParameter[] parametros)
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

            DataSet dados = new DataSet();
            adapter.Fill(dados);
            return dados;
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
