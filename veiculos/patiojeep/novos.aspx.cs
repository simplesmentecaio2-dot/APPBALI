using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class veiculos_patio_novos : System.Web.UI.Page
{
    private const string SessaoUltimosAcessados = "patio_novos_ultimos_acessados";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] == null)
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        usuarioLogado.Text = Html(Convert.ToString(Session["usuario"]));
        ScriptManager scriptManager = ScriptManager.GetCurrent(Page);
        if (scriptManager != null)
        {
            scriptManager.RegisterPostBackControl(btnTodosExportar);
        }

        if (!IsPostBack)
        {
            CarregarLojas();
            InicializarRelatorio();
            LimparRegistro(false);
            LimparTransferencia(false);

            string aba = Request.QueryString["aba"];
            AtivarAba(String.IsNullOrWhiteSpace(aba) ? "registrar" : aba);

            string buscaGlobal = Request.QueryString["buscar"];
            if (!String.IsNullOrWhiteSpace(buscaGlobal))
            {
                txtGlobalBusca.Text = buscaGlobal;
                btnGlobalBuscar_Click(btnGlobalBuscar, EventArgs.Empty);
            }

            string serie = Request.QueryString["serie"];
            if (!String.IsNullOrWhiteSpace(serie))
            {
                txtTransferenciaSerie.Text = serie;
                AtivarAba("transferir");
                BuscarTransferencia(false);
            }

            string historico = Request.QueryString["historico"];
            if (!String.IsNullOrWhiteSpace(historico))
            {
                AtivarAba("consultar");
                AbrirHistorico(historico);
            }

            string operTipo = Request.QueryString["operTipo"];
            string operBusca = Request.QueryString["operBusca"];
            if (!String.IsNullOrWhiteSpace(operTipo) && !String.IsNullOrWhiteSpace(operBusca))
            {
                if (ddlOperTipo.Items.FindByValue(operTipo.ToUpperInvariant()) != null)
                {
                    ddlOperTipo.SelectedValue = operTipo.ToUpperInvariant();
                }
                txtOperBusca.Text = operBusca;
                AtivarAba("todos");
                BuscarOperacional(false);
            }
        }

        RenderizarBase();
    }

    protected void Aba_Click(object sender, EventArgs e)
    {
        LinkButton botao = sender as LinkButton;
        LimparMensagem();
        AtivarAba(botao != null ? botao.CommandArgument : "registrar");
    }

    protected void btnGlobalBuscar_Click(object sender, EventArgs e)
    {
        string busca = NormalizarBusca(txtGlobalBusca.Text);
        txtGlobalBusca.Text = busca;
        litGlobalResultado.Text = "";
        litResumoFixo.Text = "";

        if (busca.Length < 4)
        {
            MostrarMensagem("warning", "Informe mais dados", "Digite ao menos 4 caracteres para buscar por s\u00e9rie, chassi, placa, Renavam ou c\u00f3digo.");
            return;
        }

        DataRow novo = LocalizarNovoNoPatio(busca);
        if (novo != null)
        {
            litGlobalResultado.Text = RenderVeiculoCard(novo, "Novo localizado", "Ve\u00edculo novo ativo no p\u00e1tio em " + Valor(novo, "loja_atual"), "novo");
            litResumoFixo.Text = RenderResumoFixo(novo, "Novo");
            AdicionarUltimoAcessado("Novo", novo);
            MostrarMensagem("success", "Ve\u00edculo localizado", "Encontrei este ve\u00edculo no p\u00e1tio de novos.");
            return;
        }

        DataRow seminovo = LocalizarSeminovoNoPatio(busca);
        if (seminovo != null)
        {
            litGlobalResultado.Text = RenderVeiculoCard(seminovo, "Seminovo localizado", "Ve\u00edculo seminovo ativo no p\u00e1tio em " + Valor(seminovo, "loja_atual"), "seminovo");
            litResumoFixo.Text = RenderResumoFixo(seminovo, "Seminovo");
            AdicionarUltimoAcessado("Seminovo", seminovo);
            MostrarMensagem("success", "Seminovo localizado", "Encontrei este ve\u00edculo no p\u00e1tio de seminovos.");
            return;
        }

        DataRow dealernet = LocalizarDealernet(busca);
        if (dealernet != null)
        {
            litGlobalResultado.Text = RenderVeiculoCard(dealernet, "Existe no sistema interno", "Ainda n\u00e3o encontrei este ve\u00edculo registrado no p\u00e1tio.", "dealernet");
            litResumoFixo.Text = RenderResumoFixo(dealernet, "N\u00e3o registrado");
            MostrarMensagem("warning", "N\u00e3o registrado no p\u00e1tio", "O ve\u00edculo existe no sistema interno, mas n\u00e3o est\u00e1 ativo em Novos ou Seminovos.");
            return;
        }

        MostrarMensagem("warning", "Nada encontrado", "N\u00e3o encontrei esse valor no p\u00e1tio nem no sistema interno. Confira chassi, placa, Renavam ou c\u00f3digo.");
        litGlobalResultado.Text = "<div class=\"novos-empty\">Nenhum ve&iacute;culo encontrado para esta busca.</div>";
    }

    protected void btnPesquisarRegistro_Click(object sender, EventArgs e)
    {
        AtivarAba("registrar");
        string serie = NormalizarSerie(txtRegistroSerie.Text);
        txtRegistroSerie.Text = serie;
        LimparRegistro(false);

        if (serie.Length != 7)
        {
            RenderStepper(1);
            MostrarMensagem("warning", "S\u00e9rie inv\u00e1lida", "Para registrar um ve\u00edculo novo, informe exatamente os 7 \u00faltimos caracteres do chassi ou cole o chassi completo.");
            return;
        }

        DataRow registrado = LocalizarNovoNoPatio(serie);
        if (registrado != null)
        {
            litRegistroVeiculo.Text = RenderVeiculoCard(registrado, "Ve\u00edculo j\u00e1 registrado", "Local atual: " + Valor(registrado, "loja_atual"), "novo");
            litResumoFixo.Text = RenderResumoFixo(registrado, "Novo");
            AdicionarUltimoAcessado("Novo", registrado);
            RenderStepper(2);
            MostrarMensagem("warning", "Ve\u00edculo j\u00e1 est\u00e1 no p\u00e1tio", "Este ve\u00edculo j\u00e1 est\u00e1 registrado em " + Valor(registrado, "loja_atual") + ". Use a aba Transferir para alterar a loja.");
            return;
        }

        DataRow veiculo = ConsultarRegistroDealernet(serie);
        if (veiculo == null)
        {
            RenderStepper(1);
            MostrarMensagem("warning", "N\u00e3o encontrei no Dealernet", "N\u00e3o localizei essa s\u00e9rie no sistema interno. Confira os 7 caracteres finais do chassi.");
            return;
        }

        hfRegistroVeNr.Value = Valor(veiculo, "ve_nr");
        hfRegistroSerie.Value = serie;
        hfRegistroNf.Value = Valor(veiculo, "numeronf");
        btnSalvarRegistro.Enabled = true;
        btnMobileSalvar.Enabled = true;
        litRegistroVeiculo.Text = RenderVeiculoCard(veiculo, "Ve\u00edculo encontrado", "Confira os dados e selecione a loja inicial.", "dealernet");
        litResumoFixo.Text = RenderResumoFixo(veiculo, "Pronto para registro");
        RenderStepper(3);
        MostrarMensagem("success", "Dados carregados", "Ve\u00edculo encontrado. Agora selecione a loja inicial e salve o registro.");
    }

    protected void btnSalvarRegistro_Click(object sender, EventArgs e)
    {
        AtivarAba("registrar");

        int veiculo;
        int loja;
        if (!Int32.TryParse(hfRegistroVeNr.Value, out veiculo))
        {
            RenderStepper(1);
            MostrarMensagem("warning", "Pesquise antes de salvar", "Busque a s\u00e9rie do ve\u00edculo para carregar os dados antes de gravar.");
            return;
        }

        if (!Int32.TryParse(ddlRegistroLoja.SelectedValue, out loja) || loja <= 0)
        {
            RenderStepper(3);
            MostrarMensagem("warning", "Selecione a loja", "Escolha a loja inicial onde o ve\u00edculo est\u00e1 localizado.");
            return;
        }

        if (!LojaAtiva(loja))
        {
            MostrarMensagem("warning", "Loja inativa", "A loja selecionada n\u00e3o est\u00e1 ativa para receber ve\u00edculos. Atualize a tela e selecione outra loja.");
            return;
        }

        DataRow duplicado = LocalizarNovoNoPatio(Convert.ToString(veiculo));
        if (duplicado != null)
        {
            MostrarMensagem("warning", "Registro j\u00e1 existente", "Este ve\u00edculo j\u00e1 est\u00e1 no p\u00e1tio em " + Valor(duplicado, "loja_atual") + ". Use Transferir para movimentar.");
            return;
        }

        DataTable resposta = ExecutarProcedureTabela(
            "APP..veiculos_patio_insert_locacao",
            Param("@ve_nr", SqlDbType.Int, veiculo),
            Param("@fun_cad", SqlDbType.VarChar, UsuarioAtual()),
            Param("@loja", SqlDbType.Int, loja),
            Param("@numeronf", SqlDbType.VarChar, hfRegistroNf.Value)
        );

        string resultado = resposta.Rows.Count > 0 ? Valor(resposta.Rows[0], "resultado") : "";
        if (resultado == "s")
        {
            PatioJeepAuditoria.Registrar("NOVOS_REGISTRO_SALVO", Session["usuario"], veiculo, "Loja=" + loja);
            MostrarMensagem("success", "Registro salvo", "Ve\u00edculo novo registrado no p\u00e1tio com sucesso.");
            txtRegistroSerie.Text = "";
            LimparRegistro(false);
            RenderStepper(4);
            CarregarConsulta();
            return;
        }

        if (resultado == "n")
        {
            MostrarMensagem("warning", "Registro duplicado", "Este ve\u00edculo j\u00e1 est\u00e1 ativo no p\u00e1tio. Use Transferir para alterar a loja.");
            return;
        }

        if (resultado == "v")
        {
            MostrarMensagem("warning", "Ve\u00edculo vendido", "O sistema identificou que este ve\u00edculo j\u00e1 consta como vendido. Ele n\u00e3o ser\u00e1 registrado no p\u00e1tio.");
            return;
        }

        MostrarMensagem("error", "N\u00e3o foi poss\u00edvel salvar", "O banco n\u00e3o confirmou a grava\u00e7\u00e3o. Pesquise novamente e tente salvar outra vez.");
    }

    protected void btnBuscarTransferencia_Click(object sender, EventArgs e)
    {
        AtivarAba("transferir");
        BuscarTransferencia(true);
    }

    protected void btnTransferir_Click(object sender, EventArgs e)
    {
        AtivarAba("transferir");

        if (!UsuarioTemAcesso(2))
        {
            MostrarMensagem("error", "Acesso restrito", "Seu usu\u00e1rio n\u00e3o tem permiss\u00e3o para transferir ve\u00edculos no p\u00e1tio.");
            return;
        }

        int veiculo;
        int origem;
        int destino;
        if (!Int32.TryParse(hfTransferenciaVeNr.Value, out veiculo) || !Int32.TryParse(hfTransferenciaOrigem.Value, out origem))
        {
            MostrarMensagem("warning", "Pesquise o ve\u00edculo", "Localize um ve\u00edculo ativo antes de transferir.");
            return;
        }

        if (!Int32.TryParse(ddlTransferenciaDestino.SelectedValue, out destino) || destino <= 0)
        {
            MostrarMensagem("warning", "Selecione o destino", "Escolha a loja destino da transfer\u00eancia.");
            return;
        }

        if (!LojaAtiva(destino))
        {
            MostrarMensagem("warning", "Loja inativa", "A loja destino selecionada n\u00e3o est\u00e1 ativa. Atualize a tela e escolha outra loja.");
            return;
        }

        if (origem == destino)
        {
            MostrarMensagem("warning", "Loja igual", "Selecione uma loja diferente da atual para concluir a transfer\u00eancia.");
            return;
        }

        if (!chkConfirmarTransferencia.Checked)
        {
            MostrarMensagem("warning", "Confirma\u00e7\u00e3o obrigat\u00f3ria", "Marque a confirma\u00e7\u00e3o informando que voc\u00ea est\u00e1 movendo o ve\u00edculo para a loja correta.");
            return;
        }

        DataTable resposta = ExecutarProcedureTabela(
            "APP..veiculos_patio_insert_tranferencia",
            Param("@ve_nr", SqlDbType.Int, veiculo),
            Param("@fun_cad", SqlDbType.VarChar, UsuarioAtual()),
            Param("@lojaOrigem", SqlDbType.Int, origem),
            Param("@lojaDestino", SqlDbType.Int, destino)
        );

        string resultado = resposta.Rows.Count > 0 ? Valor(resposta.Rows[0], "resultado") : "s";
        if (resultado == "n")
        {
            MostrarMensagem("warning", "Ve\u00edculo n\u00e3o est\u00e1 ativo", "N\u00e3o encontrei este ve\u00edculo ativo no p\u00e1tio. Pesquise novamente.");
            return;
        }

        PatioJeepAuditoria.Registrar("NOVOS_TRANSFERENCIA_SALVA", Session["usuario"], veiculo, "Origem=" + origem + "; Destino=" + destino);
        MostrarMensagem("success", "Transfer\u00eancia conclu\u00edda", "Ve\u00edculo transferido com sucesso.");
        BuscarTransferencia(false);
        CarregarConsulta();
    }

    protected void btnConsultar_Click(object sender, EventArgs e)
    {
        AtivarAba("consultar");
    }

    protected void btnLimparConsulta_Click(object sender, EventArgs e)
    {
        txtConsultaBusca.Text = "";
        if (ddlConsultaLoja.Items.Count > 0) ddlConsultaLoja.SelectedValue = "0";
        AtivarAba("consultar");
    }

    protected void btnTodosConsultar_Click(object sender, EventArgs e)
    {
        AtivarAba("todos");
        MostrarMensagem("success", "Filtros aplicados", "A vis\u00e3o unificada foi atualizada com os filtros selecionados.");
    }

    protected void btnTodosLimpar_Click(object sender, EventArgs e)
    {
        ddlTodosTipo.SelectedValue = "";
        ddlTodosStatus.SelectedValue = "";
        if (ddlTodosLoja.Items.Count > 0) ddlTodosLoja.SelectedValue = "0";
        txtTodosBusca.Text = "";
        AtivarAba("todos");
    }

    protected void btnTodosExportar_Click(object sender, EventArgs e)
    {
        ExportarTodos();
    }

    protected void btnOperBuscar_Click(object sender, EventArgs e)
    {
        AtivarAba("todos");
        BuscarOperacional(true);
    }

    protected void btnOperAtualizar_Click(object sender, EventArgs e)
    {
        AtivarAba("todos");

        if (String.IsNullOrWhiteSpace(hfOperTipo.Value) || String.IsNullOrWhiteSpace(hfOperVeNr.Value))
        {
            MostrarMensagem("warning", "Localize o ve\u00edculo", "Pesquise um ve\u00edculo antes de salvar status ou observa\u00e7\u00e3o.");
            return;
        }

        DataTable resposta = ExecutarProcedureTabela(
            "dbo.veiculos_patio_operacional_atualizar",
            Param("@tipo", SqlDbType.VarChar, hfOperTipo.Value),
            Param("@ve_nr", SqlDbType.VarChar, hfOperVeNr.Value),
            Param("@status", SqlDbType.VarChar, ddlOperStatus.SelectedValue),
            Param("@observacao", SqlDbType.VarChar, txtOperObservacao.Text),
            Param("@usuario", SqlDbType.VarChar, UsuarioAtual()),
            Param("@ip", SqlDbType.VarChar, IpAtual()),
            Param("@url", SqlDbType.VarChar, Request.RawUrl)
        );

        string resultado = resposta.Rows.Count > 0 ? Valor(resposta.Rows[0], "resultado") : "n";
        if (resultado == "s")
        {
            MostrarMensagem("success", "Status salvo", "Status e observa\u00e7\u00e3o operacional atualizados com sucesso.");
            PatioJeepAuditoria.Registrar("PATIO_STATUS_OPERACIONAL", Session["usuario"], hfOperVeNr.Value, hfOperTipo.Value + "; Status=" + ddlOperStatus.SelectedValue);
            BuscarOperacional(false);
            CarregarTodos();
            return;
        }

        MostrarMensagem("warning", "Ve\u00edculo n\u00e3o atualizado", "N\u00e3o encontrei este ve\u00edculo ativo para atualizar. Refa\u00e7a a busca.");
    }

    protected void btnOperBaixar_Click(object sender, EventArgs e)
    {
        AtivarAba("todos");

        if (String.IsNullOrWhiteSpace(hfOperTipo.Value) || String.IsNullOrWhiteSpace(hfOperVeNr.Value))
        {
            MostrarMensagem("warning", "Localize o ve\u00edculo", "Pesquise um ve\u00edculo antes de dar baixa manual.");
            return;
        }

        if (txtOperSenha.Text != "@bali2025")
        {
            MostrarMensagem("error", "Senha incorreta", "A baixa manual exige a senha de manuten\u00e7\u00e3o.");
            txtOperSenha.Text = "";
            return;
        }

        if (String.IsNullOrWhiteSpace(txtOperMotivoBaixa.Text))
        {
            MostrarMensagem("warning", "Informe o motivo", "Descreva o motivo da baixa manual para manter a auditoria clara.");
            return;
        }

        DataTable resposta = ExecutarProcedureTabela(
            "dbo.veiculos_patio_baixa_manual",
            Param("@tipo", SqlDbType.VarChar, hfOperTipo.Value),
            Param("@ve_nr", SqlDbType.VarChar, hfOperVeNr.Value),
            Param("@motivo", SqlDbType.VarChar, txtOperMotivoBaixa.Text),
            Param("@usuario", SqlDbType.VarChar, UsuarioAtual()),
            Param("@ip", SqlDbType.VarChar, IpAtual()),
            Param("@url", SqlDbType.VarChar, Request.RawUrl)
        );

        string resultado = resposta.Rows.Count > 0 ? Valor(resposta.Rows[0], "resultado") : "n";
        txtOperSenha.Text = "";

        if (resultado == "s")
        {
            PatioJeepAuditoria.Registrar("PATIO_BAIXA_MANUAL", Session["usuario"], hfOperVeNr.Value, hfOperTipo.Value + "; Motivo=" + txtOperMotivoBaixa.Text);
            MostrarMensagem("success", "Baixa registrada", "A baixa manual foi gravada e auditada.");
            LimparOperacional();
            CarregarTodos();
            return;
        }

        if (resultado == "m")
        {
            MostrarMensagem("warning", "Motivo obrigat\u00f3rio", "Informe um motivo para concluir a baixa manual.");
            return;
        }

        MostrarMensagem("warning", "Baixa n\u00e3o aplicada", "O ve\u00edculo n\u00e3o est\u00e1 ativo ou j\u00e1 foi baixado.");
    }

    protected void btnAtualizarRelatorio_Click(object sender, EventArgs e)
    {
        AtivarAba("relatorios");
        MostrarMensagem("success", "Relat\u00f3rio atualizado", "Dados do p\u00e1tio de novos carregados com sucesso.");
    }

    protected void FiltroRelatorio_Click(object sender, EventArgs e)
    {
        LinkButton botao = sender as LinkButton;
        string filtro = botao != null ? botao.CommandArgument : "mes";
        DefinirPeriodo(filtro);
        AtivarAba("relatorios");
    }

    protected void btnFecharHistorico_Click(object sender, EventArgs e)
    {
        pnlHistoricoModal.Visible = false;
        hfHistoricoVeNr.Value = "";
        AtivarAba("consultar");
    }

    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Session.Abandon();
        Response.Redirect("./login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void AtivarAba(string aba)
    {
        aba = NormalizarAba(aba);
        hfAbaAtual.Value = aba;

        pnlRegistrar.Visible = aba == "registrar";
        pnlTransferir.Visible = aba == "transferir";
        pnlConsultar.Visible = aba == "consultar";
        pnlRelatorios.Visible = aba == "relatorios";
        pnlTodos.Visible = aba == "todos";

        tabRegistrar.CssClass = ClasseAba(aba, "registrar");
        tabTransferir.CssClass = ClasseAba(aba, "transferir");
        tabConsultar.CssClass = ClasseAba(aba, "consultar");
        tabRelatorios.CssClass = ClasseAba(aba, "relatorios");
        tabTodos.CssClass = ClasseAba(aba, "todos");

        btnSalvarRegistro.Enabled = !String.IsNullOrWhiteSpace(hfRegistroVeNr.Value);
        btnMobileSalvar.Enabled = btnSalvarRegistro.Enabled;
        btnTransferir.Enabled = !String.IsNullOrWhiteSpace(hfTransferenciaVeNr.Value);

        if (aba == "registrar") RenderStepper(String.IsNullOrWhiteSpace(hfRegistroVeNr.Value) ? 1 : 3);
        if (aba == "consultar") CarregarConsulta();
        if (aba == "relatorios") CarregarRelatorio();
        if (aba == "todos") CarregarTodos();
    }

    private string NormalizarAba(string aba)
    {
        aba = (aba ?? "").Trim().ToLowerInvariant();
        if (aba == "transferir" || aba == "consultar" || aba == "relatorios" || aba == "todos") return aba;
        return "registrar";
    }

    private string ClasseAba(string atual, string aba)
    {
        return "novos-tab" + (atual == aba ? " is-active" : "");
    }

    private void RenderizarBase()
    {
        litIndicadores.Text = RenderIndicadores();
        litUltimosAcessados.Text = RenderUltimosAcessados();
        litRelatorioPeriodo.Text = Html(PeriodoAtualTexto());
    }

    private void CarregarLojas()
    {
        DataTable lojas = ExecutarSqlTabela(@"
SELECT id, ds
FROM dbo.veiculos_patio_loja WITH (NOLOCK)
WHERE ISNULL(ativo, 1) = 1
ORDER BY ds;");

        BindLojas(ddlRegistroLoja, lojas, false);
        BindLojas(ddlTransferenciaDestino, lojas, true);
        BindLojas(ddlConsultaLoja, lojas, true);
        BindLojas(ddlRelatorioLoja, lojas, true);
        BindLojas(ddlTodosLoja, lojas, true);
    }

    private void BindLojas(DropDownList lista, DataTable lojas, bool incluirTodas)
    {
        lista.Items.Clear();
        if (incluirTodas)
        {
            lista.Items.Add(new ListItem(lista == ddlTransferenciaDestino ? "Selecione a loja" : "Todas as lojas", "0"));
        }

        foreach (DataRow loja in lojas.Rows)
        {
            lista.Items.Add(new ListItem(Valor(loja, "ds"), Valor(loja, "id")));
        }
    }

    private void RenderStepper(int etapa)
    {
        string[] labels = { "Buscar ve\u00edculo", "Conferir dados", "Selecionar loja", "Salvar" };
        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"novos-stepper\">");
        for (int i = 0; i < labels.Length; i++)
        {
            int numero = i + 1;
            string classe = "novos-step" + (numero < etapa ? " is-done" : "") + (numero == etapa ? " is-current" : "");
            html.Append("<div class=\"").Append(classe).Append("\"><b>").Append(numero < etapa ? "<i class=\"fa fa-check\"></i>" : numero.ToString()).Append("</b><span>").Append(Html(labels[i])).Append("</span></div>");
        }
        html.Append("</div>");
        litRegistroStepper.Text = html.ToString();
    }

    private void BuscarTransferencia(bool exibirMensagem)
    {
        LimparTransferencia(false);
        string busca = NormalizarBusca(txtTransferenciaSerie.Text);
        txtTransferenciaSerie.Text = busca;

        if (busca.Length < 4)
        {
            MostrarMensagem("warning", "Informe mais dados", "Digite c\u00f3digo, s\u00e9rie, chassi, placa ou Renavam para localizar o ve\u00edculo.");
            return;
        }

        DataRow veiculo = LocalizarNovoNoPatio(busca);
        if (veiculo == null)
        {
            if (exibirMensagem)
            {
                MostrarMensagem("warning", "Ve\u00edculo n\u00e3o encontrado no p\u00e1tio", "N\u00e3o encontrei este ve\u00edculo ativo no p\u00e1tio de novos. Se for entrada inicial, use a aba Registrar.");
            }
            return;
        }

        hfTransferenciaVeNr.Value = Valor(veiculo, "ve_nr");
        hfTransferenciaOrigem.Value = Valor(veiculo, "loja_atual_id");
        hfTransferenciaSerie.Value = Valor(veiculo, "ve_serie");
        btnTransferir.Enabled = true;
        chkConfirmarTransferencia.Checked = false;
        litTransferenciaVeiculo.Text = RenderVeiculoCard(veiculo, "Ve\u00edculo localizado", "Local atual: " + Valor(veiculo, "loja_atual"), "novo");
        litResumoFixo.Text = RenderResumoFixo(veiculo, "Novo");
        litConfirmacaoTransferencia.Text = "Estou movendo o ve&iacute;culo " + Html(Valor(veiculo, "ve_ds")) + " de " + Html(Valor(veiculo, "loja_atual")) + " para a loja selecionada.";
        SelecionarDestinoDiferente(Valor(veiculo, "loja_atual_id"));
        AdicionarUltimoAcessado("Novo", veiculo);
    }

    private void SelecionarDestinoDiferente(string lojaAtual)
    {
        if (ddlTransferenciaDestino.Items.Count == 0) return;
        ddlTransferenciaDestino.SelectedIndex = 0;
        foreach (ListItem item in ddlTransferenciaDestino.Items)
        {
            if (item.Value != "0" && item.Value != lojaAtual)
            {
                ddlTransferenciaDestino.SelectedValue = item.Value;
                return;
            }
        }
    }

    private void CarregarConsulta()
    {
        int loja;
        Int32.TryParse(ddlConsultaLoja.SelectedValue, out loja);
        DataTable tabela = ListarNovos(loja, NormalizarBusca(txtConsultaBusca.Text), 250);
        litConsultaTabela.Text = RenderConsulta(tabela);
    }

    private void CarregarTodos()
    {
        int loja;
        Int32.TryParse(ddlTodosLoja.SelectedValue, out loja);

        DataTable tabela = ListarTodos(
            ddlTodosTipo.SelectedValue,
            loja,
            ddlTodosStatus.SelectedValue,
            txtTodosBusca.Text,
            350);

        litTodosAlertas.Text = RenderAlertasTodos(tabela);
        litTodosTabela.Text = RenderTodos(tabela);
    }

    private void BuscarOperacional(bool exibirMensagem)
    {
        string tipo = (ddlOperTipo.SelectedValue ?? "NOVO").ToUpperInvariant();
        string busca = NormalizarBusca(txtOperBusca.Text);
        txtOperBusca.Text = busca;

        if (busca.Length < 4)
        {
            LimparOperacional();
            MostrarMensagem("warning", "Informe mais dados", "Digite ao menos 4 caracteres para localizar o ve\u00edculo operacional.");
            return;
        }

        DataTable tabela = ListarTodos(tipo, 0, "", busca, 1);
        if (tabela.Rows.Count == 0)
        {
            LimparOperacional();
            if (exibirMensagem)
            {
                MostrarMensagem("warning", "Ve\u00edculo n\u00e3o encontrado", "N\u00e3o encontrei este ve\u00edculo ativo na base de " + (tipo == "SEMINOVO" ? "seminovos" : "novos") + ".");
            }
            return;
        }

        DataRow row = tabela.Rows[0];
        hfOperTipo.Value = tipo;
        hfOperVeNr.Value = Valor(row, "ve_nr");
        txtOperObservacao.Text = Valor(row, "observacao");

        string status = Valor(row, "status_operacional");
        if (ddlOperStatus.Items.FindByValue(status) != null)
        {
            ddlOperStatus.SelectedValue = status;
        }

        litOperVeiculo.Text =
            RenderVeiculoCard(row, tipo == "SEMINOVO" ? "Seminovo localizado" : "Novo localizado", "Manuten\u00e7\u00e3o operacional do p\u00e1tio.", tipo == "SEMINOVO" ? "seminovo" : "novo") +
            "<div class=\"novos-alert is-success\" style=\"margin-top:1rem;\"><i class=\"fa fa-link mt-1\"></i><div><strong>Link interno do ve&iacute;culo</strong><span>" +
            Html(Request.Url.GetLeftPart(UriPartial.Authority) + ResolveUrl("~/veiculos/patiojeep/novos.aspx?aba=todos&operTipo=" + tipo + "&operBusca=" + HttpUtility.UrlEncode(Valor(row, "ve_nr")))) +
            "</span></div></div>";

        AdicionarUltimoAcessado(tipo == "SEMINOVO" ? "Seminovo" : "Novo", row);
        if (exibirMensagem)
        {
            MostrarMensagem("success", "Ve\u00edculo localizado", "Agora voc\u00ea pode salvar status, observa\u00e7\u00e3o ou dar baixa manual com senha.");
        }
    }

    private void LimparOperacional()
    {
        hfOperTipo.Value = "";
        hfOperVeNr.Value = "";
        litOperVeiculo.Text = "";
        txtOperObservacao.Text = "";
        txtOperSenha.Text = "";
        txtOperMotivoBaixa.Text = "";
        if (ddlOperStatus.Items.FindByValue("NO_PATIO") != null) ddlOperStatus.SelectedValue = "NO_PATIO";
    }

    private void InicializarRelatorio()
    {
        if (ViewState["rel_ini"] == null || ViewState["rel_fim"] == null)
        {
            DateTime hoje = DateTime.Today;
            ViewState["rel_ini"] = new DateTime(hoje.Year, hoje.Month, 1);
            ViewState["rel_fim"] = hoje;
        }
    }

    private void DefinirPeriodo(string filtro)
    {
        DateTime hoje = DateTime.Today;
        if (filtro == "hoje")
        {
            ViewState["rel_ini"] = hoje;
            ViewState["rel_fim"] = hoje;
        }
        else if (filtro == "7dias")
        {
            ViewState["rel_ini"] = hoje.AddDays(-6);
            ViewState["rel_fim"] = hoje;
        }
        else if (filtro == "todos")
        {
            ViewState["rel_ini"] = new DateTime(2020, 1, 1);
            ViewState["rel_fim"] = hoje;
        }
        else
        {
            ViewState["rel_ini"] = new DateTime(hoje.Year, hoje.Month, 1);
            ViewState["rel_fim"] = hoje;
        }
    }

    private DateTime RelInicio()
    {
        InicializarRelatorio();
        return Convert.ToDateTime(ViewState["rel_ini"]);
    }

    private DateTime RelFim()
    {
        InicializarRelatorio();
        return Convert.ToDateTime(ViewState["rel_fim"]);
    }

    private string PeriodoAtualTexto()
    {
        return RelInicio().ToString("dd/MM/yyyy") + " a " + RelFim().ToString("dd/MM/yyyy");
    }

    private void CarregarRelatorio()
    {
        DateTime inicio = RelInicio();
        DateTime fimExclusivo = RelFim().Date.AddDays(1);
        int loja;
        Int32.TryParse(ddlRelatorioLoja.SelectedValue, out loja);
        string usuario = (txtRelatorioUsuario.Text ?? "").Trim();

        DataTable resumo = ExecutarSqlTabela(@"
SELECT
    (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE baixado_venda = 0) AS ativos,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE baixado_venda = 0 AND dt_cad >= @inicio AND dt_cad < @fim AND (@loja = 0 OR COALESCE(NULLIF(loja_atual_id, 0), loja_id) = @loja) AND (@usuario = '' OR fun_cad LIKE @usuarioLike)) AS entradas_periodo,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_transferencia WITH (NOLOCK) WHERE dt_transf >= @inicio AND dt_transf < @fim AND (@usuario = '' OR fun_cad LIKE @usuarioLike)) AS transferencias_periodo,
    (SELECT COUNT(DISTINCT COALESCE(NULLIF(loja_atual_id, 0), loja_id)) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE baixado_venda = 0) AS lojas
;",
            Param("@inicio", SqlDbType.DateTime, inicio),
            Param("@fim", SqlDbType.DateTime, fimExclusivo),
            Param("@loja", SqlDbType.Int, loja),
            Param("@usuario", SqlDbType.VarChar, usuario),
            Param("@usuarioLike", SqlDbType.VarChar, "%" + usuario + "%"));

        litResumoRelatorio.Text = RenderResumoRelatorio(resumo);

        litEstoquePorLoja.Text = RenderBarras(ExecutarSqlTabela(@"
SELECT TOP 12 COALESCE(lj.ds, 'Sem loja') AS label, COUNT(1) AS total
FROM dbo.veiculos_patio_locacao p WITH (NOLOCK)
LEFT JOIN dbo.veiculos_patio_loja lj WITH (NOLOCK) ON lj.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
WHERE p.baixado_venda = 0
  AND (@loja = 0 OR COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) = @loja)
GROUP BY COALESCE(lj.ds, 'Sem loja')
ORDER BY COUNT(1) DESC, COALESCE(lj.ds, 'Sem loja');",
            Param("@loja", SqlDbType.Int, loja)), "Nenhum ve&iacute;culo ativo encontrado.");

        litEntradasDia.Text = RenderBarras(ExecutarSqlTabela(@"
SELECT CONVERT(varchar(10), CONVERT(date, dt_cad), 103) AS label, COUNT(1) AS total
FROM dbo.veiculos_patio_locacao WITH (NOLOCK)
WHERE baixado_venda = 0
  AND dt_cad >= @inicio AND dt_cad < @fim
  AND (@loja = 0 OR COALESCE(NULLIF(loja_atual_id, 0), loja_id) = @loja)
  AND (@usuario = '' OR fun_cad LIKE @usuarioLike)
GROUP BY CONVERT(date, dt_cad)
ORDER BY CONVERT(date, dt_cad);",
            Param("@inicio", SqlDbType.DateTime, inicio),
            Param("@fim", SqlDbType.DateTime, fimExclusivo),
            Param("@loja", SqlDbType.Int, loja),
            Param("@usuario", SqlDbType.VarChar, usuario),
            Param("@usuarioLike", SqlDbType.VarChar, "%" + usuario + "%")), "Nenhuma entrada encontrada no per&iacute;odo.");

        litUltimasTransferencias.Text = RenderTransferencias(ExecutarSqlTabela(@"
SELECT TOP 30 t.dt_transf, t.ve_nr, t.fun_cad, lo.ds AS origem, ld.ds AS destino
FROM dbo.veiculos_patio_transferencia t WITH (NOLOCK)
LEFT JOIN dbo.veiculos_patio_loja lo WITH (NOLOCK) ON lo.id = t.loja_orig
LEFT JOIN dbo.veiculos_patio_loja ld WITH (NOLOCK) ON ld.id = t.loja_dest
WHERE t.dt_transf >= @inicio AND t.dt_transf < @fim
  AND (@usuario = '' OR t.fun_cad LIKE @usuarioLike)
ORDER BY t.dt_transf DESC, t.id DESC;",
            Param("@inicio", SqlDbType.DateTime, inicio),
            Param("@fim", SqlDbType.DateTime, fimExclusivo),
            Param("@usuario", SqlDbType.VarChar, usuario),
            Param("@usuarioLike", SqlDbType.VarChar, "%" + usuario + "%")));
    }

    private string RenderIndicadores()
    {
        string cacheKey = "patio_novos_indicadores_v3";
        object cache = HttpRuntime.Cache[cacheKey];
        if (cache != null) return Convert.ToString(cache);

        try
        {
            DataTable tabela = ExecutarSqlTabela(@"
SELECT
    (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE baixado_venda = 0) AS novos_ativos,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_seminovos_locacao WITH (NOLOCK) WHERE ativo = 1) AS seminovos_ativos,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_transferencia WITH (NOLOCK) WHERE dt_transf >= CONVERT(date, GETDATE())) +
    (SELECT COUNT(1) FROM dbo.veiculos_patio_seminovos_transferencia WITH (NOLOCK) WHERE dt_transf >= CONVERT(date, GETDATE())) AS transferencias_hoje,
    (SELECT COUNT(1) FROM dbo.veiculos_patio_locacao WITH (NOLOCK) WHERE baixado_venda = 0 AND dt_cad >= CONVERT(date, GETDATE())) AS entradas_hoje;");

            DataRow row = tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
            StringBuilder html = new StringBuilder();
            html.Append("<div class=\"novos-kpis\">");
            html.Append(Kpi("Novos", Numero(row, "novos_ativos"), "ativos no p&aacute;tio"));
            html.Append(Kpi("Seminovos", Numero(row, "seminovos_ativos"), "ativos no p&aacute;tio"));
            html.Append(Kpi("Transfer&ecirc;ncias hoje", Numero(row, "transferencias_hoje"), "novos + seminovos"));
            html.Append(Kpi("Entradas hoje", Numero(row, "entradas_hoje"), "ve&iacute;culos novos"));
            html.Append("</div>");
            string resultado = html.ToString();
            HttpRuntime.Cache.Insert(cacheKey, resultado, null, DateTime.Now.AddSeconds(60), System.Web.Caching.Cache.NoSlidingExpiration);
            return resultado;
        }
        catch
        {
            return "";
        }
    }

    private string RenderConsulta(DataTable tabela)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"novos-empty\">Nenhum ve&iacute;culo encontrado neste filtro.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"novos-table\"><thead><tr>");
        html.Append("<th>A&ccedil;&otilde;es</th><th>Ve&iacute;culo</th><th>Chassi</th><th>Placa</th><th>Renavam</th><th>Cor</th><th>Loja atual</th><th>Cadastro</th>");
        html.Append("</tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            string veNr = Valor(row, "ve_nr");
            string serie = Valor(row, "ve_serie");
            string chassi = Valor(row, "ve_chassi");
            html.Append("<tr>");
            html.Append("<td data-label=\"A&ccedil;&otilde;es\"><span class=\"novos-row-actions\">");
            html.Append("<a class=\"novos-mini-action\" href=\"novos.aspx?aba=transferir&amp;serie=").Append(HttpUtility.UrlEncode(serie)).Append("\"><i class=\"fa fa-exchange-alt\"></i>Transferir</a>");
            html.Append("<a class=\"novos-mini-action\" href=\"novos.aspx?aba=consultar&amp;historico=").Append(HttpUtility.UrlEncode(veNr)).Append("\"><i class=\"fa fa-history\"></i>Hist&oacute;rico</a>");
            html.Append("<a class=\"novos-mini-action\" href=\"#\" data-copy=\"").Append(Html(chassi)).Append("\"><i class=\"far fa-copy\"></i>Copiar chassi</a>");
            html.Append("<a class=\"novos-mini-action\" href=\"novos.aspx?aba=relatorios\"><i class=\"fa fa-chart-line\"></i>Relat&oacute;rio</a>");
            html.Append("</span></td>");
            html.Append("<td data-label=\"Ve&iacute;culo\"><strong>").Append(Html(Valor(row, "ve_ds"))).Append("</strong><small>C&oacute;d. ").Append(Html(veNr)).Append(" | S&eacute;rie ").Append(Html(serie)).Append("</small></td>");
            html.Append("<td data-label=\"Chassi\">").Append(Html(chassi)).Append("</td>");
            html.Append("<td data-label=\"Placa\">").Append(Html(Valor(row, "ve_placa"))).Append("</td>");
            html.Append("<td data-label=\"Renavam\">").Append(Html(Valor(row, "ve_renavam"))).Append("</td>");
            html.Append("<td data-label=\"Cor\">").Append(Html(Valor(row, "cor_ds"))).Append("</td>");
            html.Append("<td data-label=\"Loja atual\"><span class=\"novos-pill\">").Append(Html(Valor(row, "loja_atual"))).Append("</span></td>");
            html.Append("<td data-label=\"Cadastro\">").Append(DataCurta(row, "dt_cad")).Append("<small>").Append(Html(Valor(row, "fun_cad"))).Append("</small></td>");
            html.Append("</tr>");
        }
        html.Append("</tbody></table>");
        return html.ToString();
    }

    private string RenderTodos(DataTable tabela)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"novos-empty\">Nenhum ve&iacute;culo ativo encontrado para estes filtros.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"novos-table\"><thead><tr>");
        html.Append("<th>A&ccedil;&otilde;es</th><th>Tipo</th><th>Ve&iacute;culo</th><th>Chassi</th><th>Placa</th><th>Loja atual</th><th>Status</th><th>Parado</th><th>Observa&ccedil;&atilde;o</th><th>Cadastro</th>");
        html.Append("</tr></thead><tbody>");

        foreach (DataRow row in tabela.Rows)
        {
            string tipo = Valor(row, "tipo");
            string veNr = Valor(row, "ve_nr");
            string chassi = Valor(row, "ve_chassi");
            string serie = Valor(row, "ve_serie");
            int dias = ToInt(Valor(row, "dias_parado"));
            bool alerta = dias >= 15;

            html.Append("<tr>");
            html.Append("<td data-label=\"A&ccedil;&otilde;es\"><span class=\"novos-row-actions\">");
            html.Append("<a class=\"novos-mini-action\" href=\"novos.aspx?aba=todos&amp;operTipo=").Append(HttpUtility.UrlEncode(tipo)).Append("&amp;operBusca=").Append(HttpUtility.UrlEncode(veNr)).Append("\"><i class=\"fa fa-tools\"></i>Operar</a>");
            if (tipo == "NOVO")
            {
                html.Append("<a class=\"novos-mini-action\" href=\"novos.aspx?aba=transferir&amp;serie=").Append(HttpUtility.UrlEncode(serie)).Append("\"><i class=\"fa fa-exchange-alt\"></i>Transferir</a>");
                html.Append("<a class=\"novos-mini-action\" href=\"novos.aspx?aba=consultar&amp;historico=").Append(HttpUtility.UrlEncode(veNr)).Append("\"><i class=\"fa fa-history\"></i>Hist&oacute;rico</a>");
            }
            else
            {
                html.Append("<a class=\"novos-mini-action\" href=\"seminovos.aspx?aba=transferir&amp;busca=").Append(HttpUtility.UrlEncode(chassi)).Append("\"><i class=\"fa fa-car-side\"></i>Seminovos</a>");
            }
            html.Append("<a class=\"novos-mini-action\" href=\"auditoria.aspx?origem=").Append(HttpUtility.UrlEncode(tipo)).Append("&amp;veiculo=").Append(HttpUtility.UrlEncode(veNr)).Append("\"><i class=\"fa fa-shield-alt\"></i>Auditoria</a>");
            html.Append("<a class=\"novos-mini-action\" href=\"#\" data-copy=\"").Append(Html(chassi)).Append("\"><i class=\"far fa-copy\"></i>Copiar</a>");
            html.Append("</span></td>");
            html.Append("<td data-label=\"Tipo\"><span class=\"novos-pill\"><i class=\"fa ").Append(tipo == "SEMINOVO" ? "fa-car-side" : "fa-car").Append("\"></i>").Append(Html(tipo == "SEMINOVO" ? "Seminovo" : "Novo")).Append("</span></td>");
            html.Append("<td data-label=\"Ve&iacute;culo\"><strong>").Append(Html(Valor(row, "ve_ds"))).Append("</strong><small>C&oacute;d. ").Append(Html(veNr)).Append(" | Ref. ").Append(Html(Valor(row, "codigo_origem"))).Append("</small></td>");
            html.Append("<td data-label=\"Chassi\">").Append(Html(chassi)).Append("</td>");
            html.Append("<td data-label=\"Placa\">").Append(Html(Valor(row, "ve_placa"))).Append("</td>");
            html.Append("<td data-label=\"Loja atual\"><span class=\"novos-pill\">").Append(Html(Valor(row, "loja_atual"))).Append("</span></td>");
            html.Append("<td data-label=\"Status\">").Append(StatusBadge(Valor(row, "status_operacional"))).Append("</td>");
            html.Append("<td data-label=\"Parado\"><span class=\"novos-status ").Append(alerta ? "is-alerta" : "is-ok").Append("\">").Append(dias).Append(" dia(s)</span><small>").Append(DataCurta(row, "ultima_movimentacao")).Append("</small></td>");
            html.Append("<td data-label=\"Observa&ccedil;&atilde;o\">").Append(Html(Valor(row, "observacao"))).Append("</td>");
            html.Append("<td data-label=\"Cadastro\">").Append(DataCurta(row, "dt_cad")).Append("<small>").Append(Html(Valor(row, "fun_cad"))).Append("</small></td>");
            html.Append("</tr>");
        }

        html.Append("</tbody></table>");
        return html.ToString();
    }

    private string RenderAlertasTodos(DataTable tabela)
    {
        int parados = 0;
        int pendentes = 0;
        foreach (DataRow row in tabela.Rows)
        {
            if (ToInt(Valor(row, "dias_parado")) >= 15) parados++;
            string status = Valor(row, "status_operacional");
            if (status == "PENDENTE" || status == "AGUARDANDO_RETIRADA") pendentes++;
        }

        if (parados == 0 && pendentes == 0) return "";

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"novos-alert is-warning\" style=\"margin-top:1rem;\"><i class=\"fa fa-exclamation-triangle mt-1\"></i><div>");
        html.Append("<strong>Aten&ccedil;&atilde;o operacional</strong><span>");
        if (parados > 0) html.Append(parados).Append(" ve&iacute;culo(s) parado(s) h&aacute; 15 dias ou mais. ");
        if (pendentes > 0) html.Append(pendentes).Append(" ve&iacute;culo(s) com status pendente ou aguardando retirada.");
        html.Append("</span></div></div>");
        return html.ToString();
    }

    private string StatusBadge(string status)
    {
        status = String.IsNullOrWhiteSpace(status) ? "NO_PATIO" : status.ToUpperInvariant();
        string classe = "novos-status";
        if (status == "BAIXADO" || status == "VENDIDO") classe += " is-baixado";
        else if (status == "PENDENTE" || status == "AGUARDANDO_RETIRADA") classe += " is-alerta";
        else classe += " is-ok";

        return "<span class=\"" + classe + "\">" + Html(StatusTexto(status)) + "</span>";
    }

    private string StatusTexto(string status)
    {
        switch ((status ?? "").ToUpperInvariant())
        {
            case "PREPARACAO": return "Prepara\u00e7\u00e3o";
            case "AGUARDANDO_RETIRADA": return "Aguardando retirada";
            case "PENDENTE": return "Pendente";
            case "VENDIDO": return "Vendido";
            case "TRANSFERIDO": return "Transferido";
            case "BAIXADO": return "Baixado";
            default: return "No p\u00e1tio";
        }
    }

    private string RenderVeiculoCard(DataRow row, string titulo, string subtitulo, string origem)
    {
        StringBuilder html = new StringBuilder();
        string veNr = Valor(row, "ve_nr");
        string serie = Valor(row, "ve_serie");
        string chassi = Valor(row, "ve_chassi");
        html.Append("<div class=\"novos-vehicle-card\">");
        html.Append("<div class=\"novos-vehicle-main\">");
        html.Append("<div><strong>").Append(Html(Valor(row, "ve_ds"))).Append("</strong>");
        html.Append("<small>").Append(Html(subtitulo)).Append("</small></div>");
        html.Append("<span class=\"novos-pill\"><i class=\"fa fa-car\"></i> ").Append(Html(titulo)).Append("</span>");
        html.Append("</div><div class=\"novos-pill-list\">");
        html.Append(Pill("C&oacute;digo", veNr));
        html.Append(Pill("S&eacute;rie", serie));
        html.Append(Pill("Chassi", chassi));
        html.Append(Pill("Placa", Valor(row, "ve_placa")));
        html.Append(Pill("Renavam", Valor(row, "ve_renavam")));
        html.Append(Pill("Cor", Valor(row, "cor_ds")));
        if (row.Table.Columns.Contains("loja_atual")) html.Append(Pill("Loja", Valor(row, "loja_atual")));
        if (row.Table.Columns.Contains("ultima_movimentacao")) html.Append(Pill("&Uacute;ltima mov.", DataCurta(row, "ultima_movimentacao")));
        html.Append("</div><div class=\"novos-actions\">");
        if (origem == "novo")
        {
            html.Append("<a class=\"novos-btn novos-btn-light\" href=\"novos.aspx?aba=transferir&amp;serie=").Append(HttpUtility.UrlEncode(serie)).Append("\"><i class=\"fa fa-exchange-alt\"></i>Transferir</a>");
            html.Append("<a class=\"novos-btn novos-btn-light\" href=\"novos.aspx?aba=consultar&amp;historico=").Append(HttpUtility.UrlEncode(veNr)).Append("\"><i class=\"fa fa-history\"></i>Ver hist&oacute;rico</a>");
        }
        else if (origem == "seminovo")
        {
            html.Append("<a class=\"novos-btn novos-btn-light\" href=\"seminovos.aspx?aba=transferir&amp;busca=").Append(HttpUtility.UrlEncode(Valor(row, "ve_chassi"))).Append("\"><i class=\"fa fa-car-side\"></i>Abrir em Seminovos</a>");
        }
        else if (origem == "dealernet")
        {
            html.Append("<a class=\"novos-btn novos-btn-light\" href=\"novos.aspx?aba=registrar\"><i class=\"fa fa-folder-plus\"></i>Registrar em Novos</a>");
        }
        if (!String.IsNullOrWhiteSpace(chassi)) html.Append("<a class=\"novos-btn novos-btn-light\" href=\"#\" data-copy=\"").Append(Html(chassi)).Append("\"><i class=\"far fa-copy\"></i>Copiar chassi</a>");
        html.Append("</div></div>");
        return html.ToString();
    }

    private string RenderResumoFixo(DataRow row, string tipo)
    {
        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"novos-sticky-summary\">");
        html.Append("<div class=\"novos-pill-list\">");
        html.Append("<span class=\"novos-pill\"><i class=\"fa fa-thumbtack\"></i> ").Append(Html(tipo)).Append("</span>");
        html.Append(Pill("Modelo", Valor(row, "ve_ds")));
        html.Append(Pill("Chassi", Valor(row, "ve_chassi")));
        html.Append(Pill("Cor", Valor(row, "cor_ds")));
        if (row.Table.Columns.Contains("loja_atual")) html.Append(Pill("Loja atual", Valor(row, "loja_atual")));
        if (row.Table.Columns.Contains("ultima_movimentacao")) html.Append(Pill("&Uacute;ltima mov.", DataCurta(row, "ultima_movimentacao")));
        html.Append("</div></div>");
        return html.ToString();
    }

    private void AbrirHistorico(string busca)
    {
        DataRow veiculo = LocalizarNovoNoPatio(busca);
        int veNr;
        if (veiculo == null || !Int32.TryParse(Valor(veiculo, "ve_nr"), out veNr))
        {
            MostrarMensagem("warning", "Hist\u00f3rico n\u00e3o encontrado", "N\u00e3o encontrei um ve\u00edculo ativo para exibir o hist\u00f3rico.");
            return;
        }

        DataTable historico = ExecutarProcedureTabela("APP..veiculos_patio_select_historico", Param("@ve_nr", SqlDbType.Int, veNr));
        litHistoricoModal.Text = RenderHistorico(historico, veiculo);
        pnlHistoricoModal.Visible = true;
        hfHistoricoVeNr.Value = Convert.ToString(veNr);
        AdicionarUltimoAcessado("Novo", veiculo);
    }

    private string RenderHistorico(DataTable tabela, DataRow veiculo)
    {
        StringBuilder html = new StringBuilder();
        html.Append(RenderVeiculoCard(veiculo, "Hist&oacute;rico", "Linha do tempo operacional do p&aacute;tio.", "historico"));
        if (tabela.Rows.Count == 0)
        {
            html.Append("<div class=\"novos-empty\">Nenhum movimento encontrado.</div>");
            return html.ToString();
        }

        html.Append("<table class=\"novos-table\"><thead><tr><th>Data</th><th>Movimento</th><th>Origem</th><th>Destino</th><th>Usu&aacute;rio</th></tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td data-label=\"Data\">").Append(DataCurta(row, "dt_transf")).Append("</td>");
            html.Append("<td data-label=\"Movimento\">").Append(Html(Valor(row, "origem") == "CADASTRADO" ? "Cadastro" : "Transfer\u00eancia")).Append("</td>");
            html.Append("<td data-label=\"Origem\">").Append(Html(Valor(row, "origem"))).Append("</td>");
            html.Append("<td data-label=\"Destino\">").Append(Html(Valor(row, "destino"))).Append("</td>");
            html.Append("<td data-label=\"Usu&aacute;rio\">").Append(Html(Valor(row, "fun_cad"))).Append("</td>");
            html.Append("</tr>");
        }
        html.Append("</tbody></table>");
        return html.ToString();
    }

    private string RenderResumoRelatorio(DataTable tabela)
    {
        DataRow row = tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"novos-kpis\" style=\"margin-top:1rem;\">");
        html.Append(Kpi("Ativos", Numero(row, "ativos"), "novos no p&aacute;tio"));
        html.Append(Kpi("Entradas", Numero(row, "entradas_periodo"), "no per&iacute;odo"));
        html.Append(Kpi("Transfer&ecirc;ncias", Numero(row, "transferencias_periodo"), "no per&iacute;odo"));
        html.Append(Kpi("Lojas", Numero(row, "lojas"), "com ve&iacute;culos ativos"));
        html.Append("</div>");
        return html.ToString();
    }

    private string RenderBarras(DataTable tabela, string vazio)
    {
        if (tabela.Rows.Count == 0) return "<div class=\"novos-empty\">" + vazio + "</div>";

        int maior = 1;
        foreach (DataRow row in tabela.Rows) maior = Math.Max(maior, ToInt(Valor(row, "total")));

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"novos-bar-list\">");
        foreach (DataRow row in tabela.Rows)
        {
            int total = ToInt(Valor(row, "total"));
            int largura = Math.Max(4, (int)Math.Round((total * 100.0) / maior));
            html.Append("<div class=\"novos-bar-row\">");
            html.Append("<div class=\"novos-bar-label\" title=\"").Append(Html(Valor(row, "label"))).Append("\">").Append(Html(Valor(row, "label"))).Append("</div>");
            html.Append("<div class=\"novos-bar-track\"><span style=\"width:").Append(largura).Append("%\"></span></div>");
            html.Append("<div class=\"novos-bar-value\">").Append(total).Append("</div>");
            html.Append("</div>");
        }
        html.Append("</div>");
        return html.ToString();
    }

    private string RenderTransferencias(DataTable tabela)
    {
        if (tabela.Rows.Count == 0) return "<div class=\"novos-empty\">Nenhuma transfer&ecirc;ncia encontrada no per&iacute;odo.</div>";
        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"novos-table\"><thead><tr><th>Data</th><th>Ve&iacute;culo</th><th>Origem</th><th>Destino</th><th>Usu&aacute;rio</th></tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td data-label=\"Data\">").Append(DataCurta(row, "dt_transf")).Append("</td>");
            html.Append("<td data-label=\"Ve&iacute;culo\">").Append(Html(Valor(row, "ve_nr"))).Append("</td>");
            html.Append("<td data-label=\"Origem\">").Append(Html(Valor(row, "origem"))).Append("</td>");
            html.Append("<td data-label=\"Destino\">").Append(Html(Valor(row, "destino"))).Append("</td>");
            html.Append("<td data-label=\"Usu&aacute;rio\">").Append(Html(Valor(row, "fun_cad"))).Append("</td>");
            html.Append("</tr>");
        }
        html.Append("</tbody></table>");
        return html.ToString();
    }

    private DataRow ConsultarRegistroDealernet(string serie)
    {
        DataTable tabela = ExecutarProcedureTabela("APP..veiculos_patio_selectRegistrar", Param("@chassi", SqlDbType.VarChar, serie));
        return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
    }

    private DataRow LocalizarNovoNoPatio(string busca)
    {
        DataTable tabela = ListarNovos(0, busca, 1);
        return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
    }

    private DataTable ListarNovos(int loja, string busca, int limite)
    {
        string valor = NormalizarBusca(busca);
        return ExecutarSqlTabela(@"
SELECT TOP (@limite)
    p.ve_nr,
    SUBSTRING(COALESCE(NULLIF(v.Veiculo_Descricao, ''), 'Veiculo'), 1, 80) AS ve_ds,
    v.Veiculo_Chassi AS ve_chassi,
    ISNULL(v.Veiculo_ChassiSerie, '') AS ve_serie,
    ISNULL(v.Veiculo_Placa, '') AS ve_placa,
    ISNULL(CONVERT(varchar(40), v.Veiculo_NroRenavam), '') AS ve_renavam,
    c.Cor_Descricao AS cor_ds,
    COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) AS loja_atual_id,
    COALESCE(lj.ds, 'Sem loja') AS loja_atual,
    p.fun_cad,
    p.dt_cad,
    (SELECT MAX(t.dt_transf) FROM dbo.veiculos_patio_transferencia t WITH (NOLOCK) WHERE t.ve_nr = p.ve_nr) AS ultima_movimentacao
FROM dbo.veiculos_patio_locacao p WITH (NOLOCK)
INNER JOIN GrupoBali_DealernetWF.dbo.Veiculo v WITH (NOLOCK)
    ON ISNUMERIC(p.ve_nr) = 1 AND CAST(p.ve_nr AS int) = v.Veiculo_Codigo
LEFT JOIN GrupoBali_DealernetWF.dbo.Cor c WITH (NOLOCK)
    ON v.Veiculo_CorCodExterna = c.Cor_Codigo
LEFT JOIN dbo.veiculos_patio_loja lj WITH (NOLOCK)
    ON lj.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
WHERE p.baixado_venda = 0
  AND (@loja = 0 OR COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) = @loja)
  AND (
        @busca = ''
     OR CONVERT(varchar(50), p.ve_nr) = @busca
     OR UPPER(ISNULL(v.Veiculo_ChassiSerie, '')) = @busca
     OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(v.Veiculo_Chassi, '')), '-', ''), ' ', ''), '.', '') = @busca
     OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(v.Veiculo_Placa, '')), '-', ''), ' ', ''), '.', '') = @busca
     OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(CONVERT(varchar(40), v.Veiculo_NroRenavam), '')), '-', ''), ' ', ''), '.', '') = @busca
     OR UPPER(ISNULL(v.Veiculo_Descricao, '')) LIKE @buscaLike
  )
ORDER BY p.dt_cad DESC, p.ve_nr DESC;",
            Param("@limite", SqlDbType.Int, limite),
            Param("@loja", SqlDbType.Int, loja),
            Param("@busca", SqlDbType.VarChar, valor),
            Param("@buscaLike", SqlDbType.VarChar, "%" + valor + "%"));
    }

    private DataTable ListarTodos(string tipo, int loja, string status, string busca, int limite)
    {
        string buscaNormalizada = NormalizarBusca(busca);
        string texto = (busca ?? "").Trim().ToUpperInvariant();

        return ExecutarSqlTabela(@"
SELECT TOP (@limite) *
FROM
(
    SELECT
        'NOVO' AS tipo,
        CONVERT(varchar(50), p.ve_nr) AS ve_nr,
        CONVERT(varchar(50), p.ve_nr) AS codigo_origem,
        SUBSTRING(COALESCE(NULLIF(v.Veiculo_Descricao, ''), 'Veiculo'), 1, 90) AS ve_ds,
        v.Veiculo_Chassi AS ve_chassi,
        ISNULL(v.Veiculo_ChassiSerie, '') AS ve_serie,
        ISNULL(v.Veiculo_Placa, '') AS ve_placa,
        ISNULL(CONVERT(varchar(40), v.Veiculo_NroRenavam), '') AS ve_renavam,
        ISNULL(c.Cor_Descricao, '') AS cor_ds,
        COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) AS loja_atual_id,
        COALESCE(lj.ds, 'Sem loja') AS loja_atual,
        ISNULL(p.fun_cad, '') AS fun_cad,
        p.dt_cad,
        COALESCE((SELECT MAX(t.dt_transf) FROM dbo.veiculos_patio_transferencia t WITH (NOLOCK) WHERE t.ve_nr = p.ve_nr), p.dt_cad) AS ultima_movimentacao,
        ISNULL(p.status_operacional, 'NO_PATIO') AS status_operacional,
        ISNULL(p.observacao, '') AS observacao,
        DATEDIFF(day, COALESCE((SELECT MAX(t.dt_transf) FROM dbo.veiculos_patio_transferencia t WITH (NOLOCK) WHERE t.ve_nr = p.ve_nr), p.dt_cad), GETDATE()) AS dias_parado
    FROM dbo.veiculos_patio_locacao p WITH (NOLOCK)
    INNER JOIN GrupoBali_DealernetWF.dbo.Veiculo v WITH (NOLOCK)
        ON ISNUMERIC(p.ve_nr) = 1 AND CAST(p.ve_nr AS int) = v.Veiculo_Codigo
    LEFT JOIN GrupoBali_DealernetWF.dbo.Cor c WITH (NOLOCK)
        ON v.Veiculo_CorCodExterna = c.Cor_Codigo
    LEFT JOIN dbo.veiculos_patio_loja lj WITH (NOLOCK)
        ON lj.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
    WHERE p.baixado_venda = 0

    UNION ALL

    SELECT
        'SEMINOVO' AS tipo,
        CONVERT(varchar(50), s.id) AS ve_nr,
        CONVERT(varchar(50), s.ve_nr) AS codigo_origem,
        SUBSTRING(COALESCE(NULLIF(s.ve_ds, ''), 'Seminovo'), 1, 90) AS ve_ds,
        ISNULL(s.ve_chassi, '') AS ve_chassi,
        RIGHT(ISNULL(s.ve_chassi, ''), 7) AS ve_serie,
        ISNULL(s.ve_placa, '') AS ve_placa,
        ISNULL(s.ve_renavam, '') AS ve_renavam,
        ISNULL(s.cor_ds, '') AS cor_ds,
        COALESCE(NULLIF(s.loja_atual_id, 0), s.loja_id) AS loja_atual_id,
        COALESCE(lj.ds, 'Sem loja') AS loja_atual,
        ISNULL(s.fun_cad, '') AS fun_cad,
        s.dt_cad,
        COALESCE((SELECT MAX(t.dt_transf) FROM dbo.veiculos_patio_seminovos_transferencia t WITH (NOLOCK) WHERE t.seminovo_id = s.id), s.dt_cad) AS ultima_movimentacao,
        ISNULL(s.status_operacional, 'NO_PATIO') AS status_operacional,
        ISNULL(s.observacao, '') AS observacao,
        DATEDIFF(day, COALESCE((SELECT MAX(t.dt_transf) FROM dbo.veiculos_patio_seminovos_transferencia t WITH (NOLOCK) WHERE t.seminovo_id = s.id), s.dt_cad), GETDATE()) AS dias_parado
    FROM dbo.veiculos_patio_seminovos_locacao s WITH (NOLOCK)
    LEFT JOIN dbo.veiculos_patio_loja lj WITH (NOLOCK)
        ON lj.id = COALESCE(NULLIF(s.loja_atual_id, 0), s.loja_id)
    WHERE s.ativo = 1
) patio
WHERE (@tipo = '' OR patio.tipo = @tipo)
  AND (@loja = 0 OR patio.loja_atual_id = @loja)
  AND (@status = '' OR patio.status_operacional = @status)
  AND (
        @busca = ''
     OR patio.ve_nr = @busca
     OR patio.codigo_origem = @busca
     OR UPPER(patio.ve_serie) = @busca
     OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(patio.ve_chassi, '')), '-', ''), ' ', ''), '.', '') = @busca
     OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(patio.ve_placa, '')), '-', ''), ' ', ''), '.', '') = @busca
     OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(patio.ve_renavam, '')), '-', ''), ' ', ''), '.', '') = @busca
     OR UPPER(ISNULL(patio.ve_ds, '')) LIKE @textoLike
     OR UPPER(ISNULL(patio.fun_cad, '')) LIKE @textoLike
     OR UPPER(ISNULL(patio.loja_atual, '')) LIKE @textoLike
  )
ORDER BY patio.ultima_movimentacao DESC, patio.dt_cad DESC, patio.ve_nr DESC;",
            Param("@limite", SqlDbType.Int, limite),
            Param("@tipo", SqlDbType.VarChar, (tipo ?? "").ToUpperInvariant()),
            Param("@loja", SqlDbType.Int, loja),
            Param("@status", SqlDbType.VarChar, (status ?? "").ToUpperInvariant()),
            Param("@busca", SqlDbType.VarChar, buscaNormalizada),
            Param("@textoLike", SqlDbType.VarChar, "%" + texto + "%"));
    }

    private void ExportarTodos()
    {
        int loja;
        Int32.TryParse(ddlTodosLoja.SelectedValue, out loja);
        DataTable tabela = ListarTodos(ddlTodosTipo.SelectedValue, loja, ddlTodosStatus.SelectedValue, txtTodosBusca.Text, 5000);

        Response.Clear();
        Response.Buffer = true;
        Response.ContentType = "application/vnd.ms-excel";
        Response.ContentEncoding = Encoding.UTF8;
        Response.AddHeader("Content-Disposition", "attachment; filename=patio-todos-" + DateTime.Now.ToString("yyyyMMdd-HHmm") + ".xls");
        Response.Write("\uFEFF");
        Response.Write("<table border='1'><thead><tr>");
        string[] colunas = { "tipo", "ve_nr", "codigo_origem", "ve_ds", "ve_chassi", "ve_placa", "ve_renavam", "cor_ds", "loja_atual", "status_operacional", "observacao", "dias_parado", "fun_cad", "dt_cad", "ultima_movimentacao" };
        string[] titulos = { "Tipo", "Codigo", "Referencia", "Veiculo", "Chassi", "Placa", "Renavam", "Cor", "Loja atual", "Status", "Observacao", "Dias parado", "Usuario cadastro", "Data cadastro", "Ultima movimentacao" };
        for (int i = 0; i < titulos.Length; i++) Response.Write("<th>" + Html(titulos[i]) + "</th>");
        Response.Write("</tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            Response.Write("<tr>");
            foreach (string coluna in colunas)
            {
                Response.Write("<td>" + Html(Valor(row, coluna)) + "</td>");
            }
            Response.Write("</tr>");
        }
        Response.Write("</tbody></table>");
        Response.Flush();
        Context.ApplicationInstance.CompleteRequest();
    }

    private DataRow LocalizarSeminovoNoPatio(string busca)
    {
        DataTable tabela = ExecutarProcedureTabela("dbo.veiculos_patio_seminovos_localizar", Param("@busca", SqlDbType.VarChar, busca));
        return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
    }

    private DataRow LocalizarDealernet(string busca)
    {
        string serie = NormalizarSerie(busca);
        if (serie.Length == 7)
        {
            DataRow novo = ConsultarRegistroDealernet(serie);
            if (novo != null) return novo;
        }

        DataTable tabela = ExecutarProcedureTabela("dbo.veiculos_patio_seminovos_consultar_veiculo", Param("@busca", SqlDbType.VarChar, busca));
        return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
    }

    private bool UsuarioTemAcesso(int acessoId)
    {
        string cacheKey = "patio_acesso_" + acessoId;
        if (Session[cacheKey] != null) return Session[cacheKey].ToString() == "s";

        try
        {
            DataTable tabela = ExecutarProcedureTabela(
                "APP..veiculos_patio_verificar_acesso",
                Param("@fun_cad", SqlDbType.VarChar, UsuarioAtual()),
                Param("@acesso_id", SqlDbType.Int, acessoId));

            string retorno = tabela.Rows.Count > 0 ? Valor(tabela.Rows[0], "resultado") : "n";
            Session[cacheKey] = retorno;
            return retorno == "s";
        }
        catch
        {
            return false;
        }
    }

    private bool LojaAtiva(int lojaId)
    {
        if (lojaId <= 0) return false;

        DataTable tabela = ExecutarSqlTabela(@"
SELECT TOP 1 id
FROM dbo.veiculos_patio_loja WITH (NOLOCK)
WHERE id = @id
  AND ISNULL(ativo, 1) = 1;",
            Param("@id", SqlDbType.Int, lojaId));

        return tabela.Rows.Count > 0;
    }

    private string IpAtual()
    {
        return Request.UserHostAddress ?? "";
    }

    private DataTable ExecutarProcedureTabela(string procedure, params SqlParameter[] parametros)
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            using (SqlCommand cmd = new SqlCommand(procedure, banco.oCon2))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 30;
                foreach (SqlParameter parametro in parametros) cmd.Parameters.Add(parametro);
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd)) adapter.Fill(tabela);
            }
        }
        finally
        {
            banco.FecharConexao2();
        }
        return tabela;
    }

    private DataTable ExecutarSqlTabela(string sql, params SqlParameter[] parametros)
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            using (SqlCommand cmd = new SqlCommand(sql, banco.oCon2))
            {
                cmd.CommandTimeout = 30;
                foreach (SqlParameter parametro in parametros) cmd.Parameters.Add(parametro);
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd)) adapter.Fill(tabela);
            }
        }
        finally
        {
            banco.FecharConexao2();
        }
        return tabela;
    }

    private SqlParameter Param(string nome, SqlDbType tipo, object valor)
    {
        SqlParameter parametro = new SqlParameter(nome, tipo);
        if (tipo == SqlDbType.VarChar) parametro.Size = 500;
        parametro.Value = valor ?? DBNull.Value;
        return parametro;
    }

    private void LimparRegistro(bool limparBusca)
    {
        hfRegistroVeNr.Value = "";
        hfRegistroSerie.Value = "";
        hfRegistroNf.Value = "";
        litRegistroVeiculo.Text = "";
        btnSalvarRegistro.Enabled = false;
        btnMobileSalvar.Enabled = false;
        if (limparBusca) txtRegistroSerie.Text = "";
        RenderStepper(1);
    }

    private void LimparTransferencia(bool limparBusca)
    {
        hfTransferenciaVeNr.Value = "";
        hfTransferenciaOrigem.Value = "";
        hfTransferenciaSerie.Value = "";
        litTransferenciaVeiculo.Text = "";
        litConfirmacaoTransferencia.Text = "Pesquise um ve&iacute;culo para gerar a confirma&ccedil;&atilde;o.";
        chkConfirmarTransferencia.Checked = false;
        btnTransferir.Enabled = false;
        if (limparBusca) txtTransferenciaSerie.Text = "";
    }

    private void MostrarMensagem(string tipo, string titulo, string texto)
    {
        string classe = "novos-alert";
        if (tipo == "success") classe += " is-success";
        else if (tipo == "warning") classe += " is-warning";
        else if (tipo == "error") classe += " is-error";

        pnlMensagem.CssClass = classe;
        pnlMensagem.Visible = true;
        litMensagem.Text = "<strong>" + Html(titulo) + "</strong><span>" + Html(texto) + "</span>";
    }

    private void LimparMensagem()
    {
        pnlMensagem.Visible = false;
        litMensagem.Text = "";
    }

    private void AdicionarUltimoAcessado(string tipo, DataRow row)
    {
        List<string> itens = Session[SessaoUltimosAcessados] as List<string>;
        if (itens == null) itens = new List<string>();

        string item = tipo + "|" + Valor(row, "ve_nr") + "|" + Valor(row, "ve_ds") + "|" + Valor(row, "ve_chassi") + "|" + (row.Table.Columns.Contains("loja_atual") ? Valor(row, "loja_atual") : "");
        itens.RemoveAll(delegate(string atual) { return atual.Split('|')[1] == Valor(row, "ve_nr") && atual.StartsWith(tipo + "|"); });
        itens.Insert(0, item);
        while (itens.Count > 6) itens.RemoveAt(itens.Count - 1);
        Session[SessaoUltimosAcessados] = itens;
        litUltimosAcessados.Text = RenderUltimosAcessados();
    }

    private string RenderUltimosAcessados()
    {
        List<string> itens = Session[SessaoUltimosAcessados] as List<string>;
        if (itens == null || itens.Count == 0) return "<div class=\"novos-empty\">Nenhum ve&iacute;culo acessado nesta sess&atilde;o ainda.</div>";

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"novos-pill-list\">");
        foreach (string item in itens)
        {
            string[] partes = item.Split('|');
            string tipo = partes.Length > 0 ? partes[0] : "";
            string veNr = partes.Length > 1 ? partes[1] : "";
            string modelo = partes.Length > 2 ? partes[2] : "";
            string loja = partes.Length > 4 ? partes[4] : "";
            html.Append("<a class=\"novos-pill\" href=\"novos.aspx?aba=consultar&amp;historico=").Append(HttpUtility.UrlEncode(veNr)).Append("\"><i class=\"fa fa-clock\"></i> ");
            html.Append(Html(tipo)).Append(" - ").Append(Html(modelo)).Append(" <small>").Append(Html(loja)).Append("</small></a>");
        }
        html.Append("</div>");
        return html.ToString();
    }

    private string NormalizarBusca(string valor)
    {
        valor = (valor ?? "").Trim().ToUpperInvariant();
        StringBuilder limpo = new StringBuilder();
        foreach (char caractere in valor)
        {
            if (Char.IsLetterOrDigit(caractere)) limpo.Append(caractere);
        }
        return limpo.ToString();
    }

    private string NormalizarSerie(string valor)
    {
        string limpo = NormalizarBusca(valor);
        if (limpo.Length >= 17) return limpo.Substring(10, 7);
        return limpo;
    }

    private string Kpi(string label, string valor, string detalhe)
    {
        return "<div class=\"novos-kpi\"><small>" + label + "</small><strong>" + valor + "</strong><span>" + detalhe + "</span></div>";
    }

    private string Pill(string label, string value)
    {
        return "<span class=\"novos-pill\"><b>" + label + "</b> " + Html(String.IsNullOrWhiteSpace(value) ? "-" : value) + "</span>";
    }

    private string Html(string valor)
    {
        return HttpUtility.HtmlEncode(valor ?? "");
    }

    private string Valor(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value) return "";
        return Convert.ToString(row[coluna]);
    }

    private string DataCurta(DataRow row, string coluna)
    {
        DateTime data;
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value || !DateTime.TryParse(Convert.ToString(row[coluna]), out data)) return "-";
        return data.ToString("dd/MM/yyyy HH:mm");
    }

    private string Numero(DataRow row, string coluna)
    {
        return ToInt(Valor(row, coluna)).ToString();
    }

    private int ToInt(string valor)
    {
        int numero;
        return Int32.TryParse(valor, out numero) ? numero : 0;
    }

    private string UsuarioAtual()
    {
        return Convert.ToString(Session["usuario"]);
    }
}
