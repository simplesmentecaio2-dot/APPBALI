using System;
using System.Configuration;
using System.Collections.Generic;
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
        form1.Enctype = "multipart/form-data";

        if (!UsuarioRamaisAutenticado())
        {
            RedirecionarLoginRamais();
            return;
        }

        PreencherCabecalhoSessao();

        if (!IsPostBack)
        {
            string tela = ObterTelaAtual();
            CarregarTudo();
            AplicarTela(tela);
            MostrarAvisoViewStateExpirado();
            RegistrarAuditoriaRamais("ACESSAR_RAMAIS", null, "", "Tela=" + tela);
        }
    }

    protected void btnSair_Click(object sender, EventArgs e)
    {
        RegistrarAuditoriaRamais("SAIR_RAMAIS", null, "", "Sessao encerrada pelo usuario.");
        Response.Redirect("/logout.aspx?voltar=/RAMAIS/login.aspx");
    }

    private bool UsuarioRamaisAutenticado()
    {
        return Session["ramais_autenticado"] != null
            && Session["usuario"] != null
            && Convert.ToString(Session["usuario"]).Trim().Length > 0;
    }

    private void RedirecionarLoginRamais()
    {
        string destino = "login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl ?? "default.aspx?view=consulta");
        Response.Redirect(destino, false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void PreencherCabecalhoSessao()
    {
        litUsuarioSessao.Text = Server.HtmlEncode(Convert.ToString(Session["usuario"]));
        litCodigoSessao.Text = Session["usuario_codigo"] == null ? "-" : Server.HtmlEncode(Convert.ToString(Session["usuario_codigo"]));
    }

    protected void btnFiltrar_Click(object sender, EventArgs e)
    {
        CarregarRamais();
        AplicarTela("consulta");
        RegistrarAuditoriaRamais("FILTRAR_RAMAIS", null, "", ResumoFiltrosRamais());
    }

    protected void btnLimparFiltros_Click(object sender, EventArgs e)
    {
        ddlFiltroLoja.SelectedValue = "0";
        ddlFiltroSetor.SelectedValue = "0";
        txtBusca.Text = "";
        chkSomenteAtivos.Checked = true;
        CarregarRamais();
        AplicarTela("consulta");
        RegistrarAuditoriaRamais("LIMPAR_FILTROS_RAMAIS", null, "", "Filtros da consulta limpos.");
    }

    protected void btnExportar_Click(object sender, EventArgs e)
    {
        DataTable ramais = ExecutarTabela("dbo.ramais_ramal_listar",
            Param("@id_loja", SqlDbType.Int, ValorCombo(ddlFiltroLoja)),
            Param("@id_setor", SqlDbType.Int, ValorCombo(ddlFiltroSetor)),
            Param("@termo", SqlDbType.NVarChar, txtBusca.Text.Trim(), 160),
            Param("@somente_ativos", SqlDbType.Bit, chkSomenteAtivos.Checked));

        ramais = OrdenarTabela(ramais, gvConsulta);
        RegistrarAuditoriaRamais("EXPORTAR_RAMAIS", null, "", ResumoFiltrosRamais() + "; Registros=" + ramais.Rows.Count.ToString());

        Response.Clear();
        Response.ContentType = "application/vnd.ms-excel";
        Response.ContentEncoding = Encoding.UTF8;
        Response.AddHeader("Content-Disposition", "attachment; filename=ramais-" + DateTime.Now.ToString("yyyyMMdd-HHmm") + ".xls");
        Response.BinaryWrite(Encoding.UTF8.GetPreamble());
        Response.Write("<html><head><meta charset=\"utf-8\" /></head><body><table border=\"1\">");
        Response.Write("<tr><th>Nome</th><th>Ramal</th><th>Loja</th><th>Setor</th><th>Status</th></tr>");

        foreach (DataRow row in ramais.Rows)
        {
            Response.Write("<tr><td>");
            Response.Write(Server.HtmlEncode(Convert.ToString(row["nome"])));
            Response.Write("</td><td>");
            Response.Write(Server.HtmlEncode(Convert.ToString(row["ramal"])));
            Response.Write("</td><td>");
            Response.Write(Server.HtmlEncode(Convert.ToString(row["loja"])));
            Response.Write("</td><td>");
            Response.Write(Server.HtmlEncode(Convert.ToString(row["setor"])));
            Response.Write("</td><td>");
            Response.Write(Server.HtmlEncode(Convert.ToString(row["status"])));
            Response.Write("</td></tr>");
        }

        Response.Write("</table></body></html>");
        HttpContext.Current.ApplicationInstance.CompleteRequest();
    }

    protected void btnBaixarModeloImportacao_Click(object sender, EventArgs e)
    {
        RegistrarAuditoriaRamais("BAIXAR_MODELO_IMPORTACAO_RAMAIS", null, "", "Modelo CSV de importacao baixado.");
        Response.Clear();
        Response.ContentType = "text/csv";
        Response.ContentEncoding = Encoding.UTF8;
        Response.AddHeader("Content-Disposition", "attachment; filename=modelo-importacao-ramais.csv");
        Response.BinaryWrite(Encoding.UTF8.GetPreamble());
        Response.Write("Nome;Ramal;Loja;Setor;Ativo\r\n");
        Response.Write("Maria Silva;1234;Bali Fiat SIA;Vendas;Sim\r\n");
        Response.Write("Joao Souza;2345;Bali Jeep;Financeiro;Sim\r\n");
        HttpContext.Current.ApplicationInstance.CompleteRequest();
    }

    protected void btnGerarImpressao_Click(object sender, EventArgs e)
    {
        CarregarImpressao();
        AplicarTela("impressao");
        RegistrarAuditoriaRamais("GERAR_IMPRESSAO_RAMAIS", null, "", "Loja=" + TextoComboSelecionado(ddlImpressaoLoja));
    }

    protected void btnImportarRamais_Click(object sender, EventArgs e)
    {
        try
        {
            if (!fuImportarRamais.HasFile)
            {
                MostrarMensagem("Selecione um arquivo CSV para importar.", true);
                AplicarTela("ramais");
                return;
            }

            string extensao = Path.GetExtension(fuImportarRamais.FileName).ToLowerInvariant();
            if (extensao != ".csv" && extensao != ".txt")
            {
                MostrarMensagem("Para importar do Excel, salve a planilha como CSV e envie novamente.", true);
                AplicarTela("ramais");
                return;
            }

            string conteudo;
            using (StreamReader reader = new StreamReader(fuImportarRamais.FileContent, Encoding.Default, true))
            {
                conteudo = reader.ReadToEnd();
            }

            ResultadoImportacao resultado = ImportarRamaisCsv(conteudo);
            CarregarTudo();
            AplicarTela("ramais");
            RegistrarAuditoriaRamais("IMPORTAR_RAMAIS", null, "", "Arquivo=" + fuImportarRamais.FileName + "; Processadas=" + resultado.Processadas.ToString() + "; Sucessos=" + resultado.Sucessos.ToString() + "; Falhas=" + resultado.Falhas.ToString());

            if (resultado.Erros.Count > 0)
            {
                string detalhe = String.Join(" | ", resultado.Erros.ToArray());
                if (resultado.Falhas > resultado.Erros.Count)
                {
                    detalhe += " | +" + (resultado.Falhas - resultado.Erros.Count).ToString() + " pend\u00eancia" + (resultado.Falhas - resultado.Erros.Count == 1 ? "" : "s") + ".";
                }

                MostrarMensagem("Importa\u00e7\u00e3o conclu\u00edda: " + resultado.Processadas.ToString() + " linha" + (resultado.Processadas == 1 ? "" : "s") + " processada" + (resultado.Processadas == 1 ? "" : "s") + ", " + resultado.Sucessos.ToString() + " " + TextoRamalPlural(resultado.Sucessos) + " salvo" + (resultado.Sucessos == 1 ? "" : "s") + " e " + resultado.Falhas.ToString() + " pend\u00eancia" + (resultado.Falhas == 1 ? "" : "s") + ". " + detalhe, true);
            }
            else
            {
                MostrarMensagem("Importa\u00e7\u00e3o conclu\u00edda: " + resultado.Processadas.ToString() + " linha" + (resultado.Processadas == 1 ? "" : "s") + " processada" + (resultado.Processadas == 1 ? "" : "s") + " e " + resultado.Sucessos.ToString() + " " + TextoRamalPlural(resultado.Sucessos) + " salvo" + (resultado.Sucessos == 1 ? "" : "s") + ".", false);
            }
        }
        catch (Exception ex)
        {
            RegistrarErro("Importar ramais", ex);
            MostrarMensagem(FormatarErro(ex), true);
            AplicarTela("ramais");
        }
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

            int idLoja = Convert.ToInt32(ddlRamalLoja.SelectedValue);
            int idSetor = Convert.ToInt32(ddlRamalSetor.SelectedValue);
            if (ExisteRamalDuplicadoNaLoja(txtRamal.Text, idLoja, idAtual))
            {
                MostrarMensagem("J\u00e1 existe um ramal ativo com esse n\u00famero nesta loja. Revise antes de salvar.", true);
                AplicarTela("ramais");
                return;
            }

            DataRow antes = idAtual > 0 ? ObterRamalHistorico(idAtual) : null;
            DataTable salvo = ExecutarTabela("dbo.ramais_ramal_salvar",
                Param("@id_ramal", SqlDbType.Int, idAtual > 0 ? (object)idAtual : DBNull.Value),
                Param("@nome", SqlDbType.NVarChar, txtNome.Text, 160),
                Param("@ramal", SqlDbType.NVarChar, txtRamal.Text, 30),
                Param("@id_loja", SqlDbType.Int, idLoja),
                Param("@id_setor", SqlDbType.Int, idSetor),
                Param("@ativo", SqlDbType.Bit, chkRamalAtivo.Checked));

            DataRow depois = salvo.Rows.Count > 0 ? salvo.Rows[0] : null;
            RegistrarHistoricoRamal(idAtual > 0 ? "Alteracao" : "Inclusao", antes, depois);
            RegistrarAuditoriaRamais(
                idAtual > 0 ? "EDITAR_RAMAL" : "CRIAR_RAMAL",
                ObterIdRamalAuditoria(depois, idAtual),
                ValorHistorico(depois, "ramal"),
                "Ramal salvo pelo formulario.",
                ResumoRamalHistorico(antes),
                ResumoRamalHistorico(depois));

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
                RegistrarAuditoriaRamais("ABRIR_EDICAO_RAMAL", id, "", "Ramal carregado para edicao.");
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

                DataRow antes = ObterRamalHistorico(id);
                ExecutarSemRetorno("dbo.ramais_ramal_excluir", Param("@id_ramal", SqlDbType.Int, id));
                RegistrarHistoricoRamal("Exclusao", antes, null);
                RegistrarAuditoriaRamais("EXCLUIR_RAMAL", id, ValorHistorico(antes, "ramal"), "Ramal inativado.", ResumoRamalHistorico(antes), "");
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
            string rotulo = Server.HtmlDecode(grid.Columns[i].HeaderText);
            e.Row.Cells[i].Attributes["data-label"] = rotulo;

            if (String.Equals(rotulo, "Status", StringComparison.OrdinalIgnoreCase))
            {
                AplicarStatusVisual(e.Row.Cells[i]);
            }
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

            int idLojaAtual = ObterIdNumerico(hfLojaId.Value);
            DataTable lojaSalva = ExecutarTabela("dbo.ramais_loja_salvar",
                Param("@id_loja", SqlDbType.Int, ObterId(hfLojaId.Value)),
                Param("@nome", SqlDbType.NVarChar, txtLojaNome.Text.Trim(), 120),
                Param("@ativo", SqlDbType.Bit, chkLojaAtiva.Checked));
            RegistrarAuditoriaRamais(idLojaAtual > 0 ? "EDITAR_LOJA_RAMAL" : "CRIAR_LOJA_RAMAL", null, "", "Loja=" + ResumoLinhaCadastro(lojaSalva, "id_loja"));

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
                    RegistrarAuditoriaRamais("ABRIR_EDICAO_LOJA_RAMAL", null, "", "Loja=" + ValorHistorico(row, "nome") + "; ID=" + id.ToString());
                    MostrarMensagem("Loja carregada para edi\u00e7\u00e3o.", false);
                    AplicarTela("lojas");
                }
            }
            else if (e.CommandName == "ExcluirLoja")
            {
                string resumoLoja = "ID=" + id.ToString();
                ExecutarSemRetorno("dbo.ramais_loja_excluir", Param("@id_loja", SqlDbType.Int, id));
                RegistrarAuditoriaRamais("EXCLUIR_LOJA_RAMAL", null, "", resumoLoja);
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

            int idSetorAtual = ObterIdNumerico(hfSetorId.Value);
            DataTable setorSalvo = ExecutarTabela("dbo.ramais_setor_salvar",
                Param("@id_setor", SqlDbType.Int, ObterId(hfSetorId.Value)),
                Param("@nome", SqlDbType.NVarChar, txtSetorNome.Text.Trim(), 120),
                Param("@ativo", SqlDbType.Bit, chkSetorAtivo.Checked));
            RegistrarAuditoriaRamais(idSetorAtual > 0 ? "EDITAR_SETOR_RAMAL" : "CRIAR_SETOR_RAMAL", null, "", "Setor=" + ResumoLinhaCadastro(setorSalvo, "id_setor"));

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
                    RegistrarAuditoriaRamais("ABRIR_EDICAO_SETOR_RAMAL", null, "", "Setor=" + ValorHistorico(row, "nome") + "; ID=" + id.ToString());
                    MostrarMensagem("Setor carregado para edi\u00e7\u00e3o.", false);
                    AplicarTela("setores");
                }
            }
            else if (e.CommandName == "ExcluirSetor")
            {
                string resumoSetor = "ID=" + id.ToString();
                ExecutarSemRetorno("dbo.ramais_setor_excluir", Param("@id_setor", SqlDbType.Int, id));
                RegistrarAuditoriaRamais("EXCLUIR_SETOR_RAMAL", null, "", resumoSetor);
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
        CarregarHistoricoRamais();
    }

    private ResultadoImportacao ImportarRamaisCsv(string conteudo)
    {
        ResultadoImportacao resultado = new ResultadoImportacao();
        if (String.IsNullOrWhiteSpace(conteudo))
        {
            resultado.AdicionarErro("arquivo vazio");
            return resultado;
        }

        DataTable lojas = ExecutarTabela("dbo.ramais_loja_listar", Param("@somente_ativas", SqlDbType.Bit, true));
        DataTable setores = ExecutarTabela("dbo.ramais_setor_listar", Param("@somente_ativos", SqlDbType.Bit, true));
        Dictionary<string, int> mapaLojas = CriarMapaPorNome(lojas, "id_loja");
        Dictionary<string, int> mapaSetores = CriarMapaPorNome(setores, "id_setor");

        string[] linhas = conteudo.Replace("\r\n", "\n").Replace("\r", "\n").Split('\n');
        int inicio = 0;
        if (linhas.Length > 0 && linhas[0].ToLowerInvariant().Contains("nome") && linhas[0].ToLowerInvariant().Contains("ramal"))
        {
            inicio = 1;
        }

        for (int i = inicio; i < linhas.Length; i++)
        {
            string linha = (linhas[i] ?? "").Trim();
            if (linha.Length == 0) continue;

            if (resultado.Processadas >= 300)
            {
                resultado.AdicionarErro("limite de 300 linhas por importa\u00e7\u00e3o atingido");
                break;
            }

            resultado.Processadas++;
            string[] colunas = SepararLinhaCsv(linha);
            if (colunas.Length < 4)
            {
                resultado.AdicionarErro("linha " + (i + 1).ToString() + ": informe Nome, Ramal, Loja e Setor");
                continue;
            }

            string nome = TextoCurto(colunas[0]);
            string ramal = TextoCurto(colunas[1]);
            string loja = TextoCurto(colunas[2]);
            string setor = TextoCurto(colunas[3]);
            bool ativo = colunas.Length < 5 || ValorAtivoImportacao(colunas[4]);

            if (nome.Length == 0 || ramal.Length == 0 || loja.Length == 0 || setor.Length == 0)
            {
                resultado.AdicionarErro("linha " + (i + 1).ToString() + ": campos obrigat\u00f3rios vazios");
                continue;
            }

            string chaveLoja = ChaveNormalizada(loja);
            string chaveSetor = ChaveNormalizada(setor);
            if (!mapaLojas.ContainsKey(chaveLoja))
            {
                resultado.AdicionarErro("linha " + (i + 1).ToString() + ": loja n\u00e3o encontrada");
                continue;
            }

            if (!mapaSetores.ContainsKey(chaveSetor))
            {
                resultado.AdicionarErro("linha " + (i + 1).ToString() + ": setor n\u00e3o encontrado");
                continue;
            }

            int idLoja = mapaLojas[chaveLoja];
            int idSetor = mapaSetores[chaveSetor];
            if (ExisteRamalDuplicadoNaLoja(ramal, idLoja, 0))
            {
                resultado.AdicionarErro("linha " + (i + 1).ToString() + ": ramal duplicado na loja");
                continue;
            }

            DataTable salvo = ExecutarTabela("dbo.ramais_ramal_salvar",
                Param("@id_ramal", SqlDbType.Int, DBNull.Value),
                Param("@nome", SqlDbType.NVarChar, nome, 160),
                Param("@ramal", SqlDbType.NVarChar, ramal, 30),
                Param("@id_loja", SqlDbType.Int, idLoja),
                Param("@id_setor", SqlDbType.Int, idSetor),
                Param("@ativo", SqlDbType.Bit, ativo));

            RegistrarHistoricoRamal("Importacao", null, salvo.Rows.Count > 0 ? salvo.Rows[0] : null);
            resultado.Sucessos++;
        }

        return resultado;
    }

    private Dictionary<string, int> CriarMapaPorNome(DataTable dados, string colunaId)
    {
        Dictionary<string, int> mapa = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
        foreach (DataRow row in dados.Rows)
        {
            string nome = ChaveNormalizada(Convert.ToString(row["nome"]));
            int id;
            if (nome.Length > 0 && Int32.TryParse(Convert.ToString(row[colunaId]), out id) && !mapa.ContainsKey(nome))
            {
                mapa.Add(nome, id);
            }
        }

        return mapa;
    }

    private string[] SepararLinhaCsv(string linha)
    {
        char separador = linha.IndexOf(';') >= 0 ? ';' : ',';
        List<string> partes = new List<string>();
        StringBuilder atual = new StringBuilder();
        bool aspas = false;

        for (int i = 0; i < linha.Length; i++)
        {
            char c = linha[i];
            if (c == '"')
            {
                if (aspas && i + 1 < linha.Length && linha[i + 1] == '"')
                {
                    atual.Append('"');
                    i++;
                }
                else
                {
                    aspas = !aspas;
                }
            }
            else if (c == separador && !aspas)
            {
                partes.Add(atual.ToString());
                atual.Length = 0;
            }
            else
            {
                atual.Append(c);
            }
        }

        partes.Add(atual.ToString());
        return partes.ToArray();
    }

    private bool ValorAtivoImportacao(string valor)
    {
        string texto = ChaveNormalizada(valor);
        return texto.Length == 0 || texto == "1" || texto == "sim" || texto == "s" || texto == "ativo" || texto == "true";
    }

    private bool ExisteRamalDuplicadoNaLoja(string ramal, int idLoja, int idIgnorar)
    {
        DataTable dados = ExecutarTabela("dbo.ramais_ramal_listar",
            Param("@id_loja", SqlDbType.Int, idLoja),
            Param("@id_setor", SqlDbType.Int, DBNull.Value),
            Param("@termo", SqlDbType.NVarChar, TextoCurto(ramal), 160),
            Param("@somente_ativos", SqlDbType.Bit, true));

        foreach (DataRow row in dados.Rows)
        {
            int id;
            Int32.TryParse(Convert.ToString(row["id_ramal"]), out id);
            if (id != idIgnorar && String.Equals(TextoCurto(Convert.ToString(row["ramal"])), TextoCurto(ramal), StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }

        return false;
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
        AtualizarResumoConsultaRamais(ramais);
    }

    private void AtualizarResumoConsultaRamais(DataTable ramais)
    {
        if (ramais == null || ramais.Rows.Count == 0)
        {
            litResumoConsultaRamais.Text = "";
            return;
        }

        int ativos = 0;
        int inativos = 0;
        HashSet<string> lojas = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        HashSet<string> setores = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (DataRow row in ramais.Rows)
        {
            string status = ValorLinha(row, "status");
            if (status.Equals("Inativo", StringComparison.OrdinalIgnoreCase)) inativos++;
            else ativos++;

            string loja = ValorLinha(row, "loja");
            string setor = ValorLinha(row, "setor");
            if (loja.Length > 0) lojas.Add(loja);
            if (setor.Length > 0) setores.Add(setor);
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"ramais-result-summary\" aria-label=\"Resumo da consulta de ramais\">");
        html.Append(ResumoChip("Total", ramais.Rows.Count, "is-total"));
        html.Append(ResumoChip("Ativos", ativos, "is-active"));
        html.Append(ResumoChip("Inativos", inativos, "is-inactive"));
        html.Append(ResumoChip("Lojas", lojas.Count, "is-store"));
        html.Append(ResumoChip("Setores", setores.Count, "is-sector"));
        html.Append("</div>");
        litResumoConsultaRamais.Text = html.ToString();
    }

    private string ResumoChip(string rotulo, int total, string classe)
    {
        return "<span class=\"ramais-summary-chip " + classe + "\"><strong>" +
            total.ToString() +
            "</strong> " +
            Server.HtmlEncode(rotulo) +
            "</span>";
    }

    private void AplicarStatusVisual(TableCell celula)
    {
        string status = Server.HtmlDecode(celula.Text ?? "").Trim();
        if (status.Length == 0 || status == "&nbsp;") status = "Ativo";
        string classe = status.Equals("Inativo", StringComparison.OrdinalIgnoreCase)
            ? "ramal-status-inactive"
            : "ramal-status-active";
        celula.CssClass = (celula.CssClass + " status-cell").Trim();
        celula.Text = "<span class=\"ramal-status-badge " + classe + "\">" + Server.HtmlEncode(status) + "</span>";
    }

    private string ValorLinha(DataRow row, string coluna)
    {
        if (row == null || row.Table.Columns.IndexOf(coluna) < 0 || row[coluna] == DBNull.Value) return "";
        return Convert.ToString(row[coluna]).Trim();
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

    private int? ObterIdRamalAuditoria(DataRow row, int idFallback)
    {
        int id = ObterIdNumerico(ValorHistorico(row, "id_ramal"));
        if (id > 0) return id;
        return idFallback > 0 ? (int?)idFallback : null;
    }

    private string TextoComboSelecionado(DropDownList combo)
    {
        if (combo == null || combo.SelectedItem == null) return "";
        string texto = (combo.SelectedItem.Text ?? "").Trim();
        return texto.Length == 0 ? combo.SelectedValue : texto;
    }

    private string ResumoFiltrosRamais()
    {
        return "Loja=" + TextoComboSelecionado(ddlFiltroLoja) +
            "; Setor=" + TextoComboSelecionado(ddlFiltroSetor) +
            "; Busca=" + TextoCurto(txtBusca.Text) +
            "; SomenteAtivos=" + (chkSomenteAtivos.Checked ? "Sim" : "Nao");
    }

    private string ResumoLinhaCadastro(DataTable dados, string colunaId)
    {
        if (dados == null || dados.Rows.Count == 0) return "";
        DataRow row = dados.Rows[0];
        return "ID=" + ValorHistorico(row, colunaId) +
            "; Nome=" + ValorHistorico(row, "nome") +
            "; Status=" + ValorHistorico(row, "status");
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

    private DataRow ObterRamalHistorico(int id)
    {
        if (id <= 0) return null;
        DataTable dados = ExecutarTabela("dbo.ramais_ramal_obter", Param("@id_ramal", SqlDbType.Int, id));
        return dados.Rows.Count > 0 ? dados.Rows[0] : null;
    }

    private void RegistrarHistoricoRamal(string acao, DataRow antes, DataRow depois)
    {
        try
        {
            string pasta = Server.MapPath("~/App_Data");
            if (!Directory.Exists(pasta))
            {
                Directory.CreateDirectory(pasta);
            }

            string usuario = UsuarioSessaoRamais();

            string linha = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") +
                " | " + acao +
                " | usuario=" + usuario +
                " | antes=" + ResumoRamalHistorico(antes) +
                " | depois=" + ResumoRamalHistorico(depois) +
                Environment.NewLine;

            File.AppendAllText(Path.Combine(pasta, "ramais-historico.log"), linha, Encoding.UTF8);
        }
        catch
        {
        }
    }

    private string ResumoRamalHistorico(DataRow row)
    {
        if (row == null) return "";
        return ("id=" + ValorHistorico(row, "id_ramal") +
            ";nome=" + ValorHistorico(row, "nome") +
            ";ramal=" + ValorHistorico(row, "ramal") +
            ";loja=" + ValorHistorico(row, "loja") +
            ";setor=" + ValorHistorico(row, "setor") +
            ";status=" + ValorHistorico(row, "status")).Replace("\r", " ").Replace("\n", " ");
    }

    private string ValorHistorico(DataRow row, string coluna)
    {
        if (row == null || row.Table.Columns.IndexOf(coluna) < 0 || row[coluna] == DBNull.Value) return "";
        return Convert.ToString(row[coluna]);
    }

    private void CarregarHistoricoRamais()
    {
        string caminho = Server.MapPath("~/App_Data/ramais-historico.log");
        if (!File.Exists(caminho))
        {
            litHistoricoRamais.Text = "<p class=\"empty-history\">Nenhuma altera\u00e7\u00e3o registrada ainda.</p>";
            return;
        }

        string[] linhas = File.ReadAllLines(caminho, Encoding.UTF8);
        int inicio = Math.Max(0, linhas.Length - 8);
        StringBuilder html = new StringBuilder();
        html.Append("<ol class=\"history-list\">");
        for (int i = linhas.Length - 1; i >= inicio; i--)
        {
            if (String.IsNullOrWhiteSpace(linhas[i])) continue;
            html.Append("<li>");
            html.Append(Server.HtmlEncode(linhas[i]));
            html.Append("</li>");
        }
        html.Append("</ol>");
        litHistoricoRamais.Text = html.ToString();
    }

    private string TextoCurto(string valor)
    {
        string texto = (valor ?? "").Trim();
        if (texto.Length == 0) return "";
        return String.Join(" ", texto.Split((char[])null, StringSplitOptions.RemoveEmptyEntries));
    }

    private string TextoRamalPlural(int total)
    {
        return total == 1 ? "ramal" : "ramais";
    }

    private string ChaveNormalizada(string valor)
    {
        return TextoCurto(valor).ToLowerInvariant();
    }

    protected string Atributo(object valor)
    {
        return HttpUtility.HtmlAttributeEncode(Convert.ToString(valor ?? ""));
    }

    private class ResultadoImportacao
    {
        public int Processadas { get; set; }
        public int Sucessos { get; set; }
        public int Falhas { get; private set; }
        public List<string> Erros { get; private set; }

        public ResultadoImportacao()
        {
            Erros = new List<string>();
        }

        public void AdicionarErro(string erro)
        {
            Falhas++;
            if (Erros.Count < 6)
            {
                Erros.Add(erro);
            }
        }
    }

    private SqlParameter Param(string nome, SqlDbType tipo, object valor, int tamanho = 0)
    {
        SqlParameter parametro = tamanho > 0 ? new SqlParameter(nome, tipo, tamanho) : new SqlParameter(nome, tipo);
        parametro.Value = valor == null ? DBNull.Value : valor;
        return parametro;
    }

    private string IdUsuarioSessaoRamais()
    {
        return Convert.ToString(Session["id"] ?? "").Trim();
    }

    private string UsuarioSessaoRamais()
    {
        string usuario = Convert.ToString(Session["usuario"] ?? "").Trim();
        if (usuario.Length > 0) return usuario;

        usuario = Convert.ToString(Session["id"] ?? "").Trim();
        return usuario.Length > 0 ? usuario : "anonimo";
    }

    private string LimitarAuditoria(string valor)
    {
        string texto = (valor ?? "").Replace("\r", " ").Replace("\n", " ").Replace("\t", " ").Trim();
        while (texto.Contains("  "))
        {
            texto = texto.Replace("  ", " ");
        }
        return texto.Length > 12000 ? texto.Substring(0, 12000) + "...(truncado)" : texto;
    }

    private void RegistrarAuditoriaRamais(string acao, int? idRamal = null, string ramal = "", string detalhe = "", string dadosAntes = "", string dadosDepois = "")
    {
        try
        {
            ExecutarSemRetorno("dbo.ramais_auditoria_registrar",
                Param("@usuario_id", SqlDbType.NVarChar, IdUsuarioSessaoRamais(), 80),
                Param("@usuario_nome", SqlDbType.NVarChar, UsuarioSessaoRamais(), 160),
                Param("@usuario_tipo", SqlDbType.NVarChar, Convert.ToString(Session["tipo"] ?? ""), 80),
                Param("@usuario_email", SqlDbType.NVarChar, Convert.ToString(Session["email"] ?? ""), 180),
                Param("@empresa", SqlDbType.NVarChar, Convert.ToString(Session["empresa"] ?? ""), 120),
                Param("@ip", SqlDbType.NVarChar, Request.UserHostAddress ?? "", 80),
                Param("@url", SqlDbType.NVarChar, Request.RawUrl ?? "", 500),
                Param("@acao", SqlDbType.NVarChar, acao, 80),
                Param("@id_ramal", SqlDbType.Int, idRamal.HasValue ? (object)idRamal.Value : DBNull.Value),
                Param("@ramal", SqlDbType.NVarChar, ramal, 30),
                Param("@detalhe", SqlDbType.NVarChar, LimitarAuditoria(detalhe)),
                Param("@dados_antes", SqlDbType.NVarChar, LimitarAuditoria(dadosAntes)),
                Param("@dados_depois", SqlDbType.NVarChar, LimitarAuditoria(dadosDepois)));
        }
        catch
        {
        }
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

            string usuario = UsuarioSessaoRamais();

            string linha = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") +
                " | " + origem +
                " | usuario=" + usuario +
                " | url=" + Request.RawUrl +
                " | erro=" + (ex.Message ?? "").Replace("\r", " ").Replace("\n", " ") +
                Environment.NewLine;

            File.AppendAllText(Path.Combine(pasta, "ramais-erros.log"), linha, Encoding.UTF8);
            RegistrarAuditoriaRamais("ERRO_RAMAIS", null, "", origem + ": " + (ex.Message ?? "").Replace("\r", " ").Replace("\n", " "));
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
