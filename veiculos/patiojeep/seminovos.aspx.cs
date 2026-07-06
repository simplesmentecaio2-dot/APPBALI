using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class veiculos_patio_seminovos : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] == null)
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        usuarioLogado.Text = Html(Convert.ToString(Session["usuario"]));

        if (!IsPostBack)
        {
            CarregarLojas();
            LimparRegistro(false);
            LimparTransferencia(false);

            string aba = Request.QueryString["aba"];
            AtivarAba(String.IsNullOrWhiteSpace(aba) ? "registrar" : aba);

            if (String.Equals(hfAbaAtual.Value, "transferir", StringComparison.OrdinalIgnoreCase))
            {
                string busca = Request.QueryString["busca"];
                if (!String.IsNullOrWhiteSpace(busca))
                {
                    txtTransferenciaBusca.Text = busca;
                    BuscarTransferencia(false);
                }
            }
        }
    }

    protected void Aba_Click(object sender, EventArgs e)
    {
        LinkButton botao = sender as LinkButton;
        AtivarAba(botao != null ? botao.CommandArgument : "registrar");
    }

    protected void btnPesquisarRegistro_Click(object sender, EventArgs e)
    {
        AtivarAba("registrar");
        CarregarRegistroPorBusca(true);
    }

    protected void btnSalvarRegistro_Click(object sender, EventArgs e)
    {
        AtivarAba("registrar");

        int veiculo;
        int loja;
        if (!Int32.TryParse(hfRegistroVeNr.Value, out veiculo))
        {
            if (!CarregarRegistroPorBusca(false) || !Int32.TryParse(hfRegistroVeNr.Value, out veiculo))
            {
                return;
            }
        }

        if (!Int32.TryParse(ddlRegistroLoja.SelectedValue, out loja) || loja <= 0)
        {
            MostrarMensagem("warning", "Selecione a loja", "Escolha a loja inicial onde o seminovo est\u00e1 localizado.");
            ddlRegistroLoja.Focus();
            return;
        }

        DataTable resposta = ExecutarProcedureTabela(
            "dbo.veiculos_patio_seminovos_registrar",
            Param("@ve_nr", SqlDbType.Int, veiculo),
            Param("@loja", SqlDbType.Int, loja),
            Param("@fun_cad", SqlDbType.VarChar, UsuarioAtual()),
            Param("@observacao", SqlDbType.VarChar, TextoOuDbNull(txtRegistroObservacao.Text))
        );

        string resultado = resposta.Rows.Count > 0 ? Valor(resposta.Rows[0], "resultado") : "";
        if (resultado == "s")
        {
            RegistrarAuditoria("REGISTRO_SALVO", veiculo, hfRegistroReferencia.Value, "Loja inicial=" + loja);
            MostrarMensagem("success", "Registro salvo", "Seminovo registrado no p\u00e1tio com sucesso.");
            txtRegistroBusca.Text = "";
            txtRegistroObservacao.Text = "";
            LimparRegistro(false);
            return;
        }

        if (resultado == "n")
        {
            RegistrarAuditoria("REGISTRO_DUPLICADO_BLOQUEADO", veiculo, hfRegistroReferencia.Value, "Procedure retornou duplicidade ativa.");
            MostrarMensagem("warning", "Registro j\u00e1 existente", "Este seminovo j\u00e1 est\u00e1 ativo no p\u00e1tio. Use a aba Transferir para movimentar.");
            return;
        }

        RegistrarAuditoria("REGISTRO_ERRO", veiculo, hfRegistroReferencia.Value, "Procedure retornou resultado=" + resultado);
        MostrarMensagem("error", "N\u00e3o foi poss\u00edvel salvar", "O ve\u00edculo n\u00e3o foi localizado novamente no sistema interno. Pesquise e tente salvar outra vez.");
    }

    private bool CarregarRegistroPorBusca(bool exibirMensagemSucesso)
    {
        string busca = NormalizarBusca(txtRegistroBusca.Text);
        LimparRegistro(false);
        txtRegistroBusca.Text = busca;

        if (busca.Length < 4)
        {
            RegistrarAuditoria("REGISTRO_BUSCA_INVALIDA", null, busca, "Busca com menos de 4 caracteres.");
            MostrarMensagem("warning", "Informe mais dados", "Digite chassi completo, placa ou Renavam antes de pesquisar.");
            txtRegistroBusca.Focus();
            return false;
        }

        DataRow veiculo = ConsultarVeiculoDealernet(busca);
        if (veiculo == null)
        {
            RegistrarAuditoria("REGISTRO_NAO_ENCONTRADO", null, busca, "Nenhum seminovo retornado pela consulta.");
            MostrarMensagem("warning", "Ve\u00edculo n\u00e3o encontrado", "N\u00e3o localizei esse chassi, placa ou Renavam no sistema interno. Confira o valor informado.");
            txtRegistroBusca.Focus();
            return false;
        }

        string codigoVeiculo = Valor(veiculo, "ve_nr");
        DataRow jaRegistrado = LocalizarSeminovo(codigoVeiculo);
        if (jaRegistrado != null)
        {
            btnSalvarRegistro.Enabled = false;
            hfRegistroVeNr.Value = "";
            litRegistroVeiculo.Text = RenderVeiculoCard(jaRegistrado, "warning", "Seminovo j\u00e1 registrado", "Local atual: " + Valor(jaRegistrado, "loja_atual"));
            RegistrarAuditoria("REGISTRO_DUPLICADO", ToIntNullable(codigoVeiculo), busca, "Tentativa de registrar veiculo ja ativo.");
            MostrarMensagem("warning", "Registro j\u00e1 existente", "Este seminovo j\u00e1 est\u00e1 registrado no p\u00e1tio. Para mudar a loja, use a aba Transferir.");
            return false;
        }

        hfRegistroVeNr.Value = codigoVeiculo;
        hfRegistroReferencia.Value = busca;
        btnSalvarRegistro.Enabled = true;
        litRegistroVeiculo.Text = RenderVeiculoCard(veiculo, "success", "Ve\u00edculo encontrado", "Confira a loja inicial e salve o registro.");
        RegistrarAuditoria("REGISTRO_BUSCA_SUCESSO", ToIntNullable(codigoVeiculo), busca, "Veiculo encontrado para registro.");
        if (exibirMensagemSucesso)
        {
            MostrarMensagem("success", "Dados carregados", "Confira as informa\u00e7\u00f5es do seminovo, selecione a loja inicial e clique em Salvar registro.");
            ddlRegistroLoja.Focus();
        }
        return true;
    }

    protected void btnConsultar_Click(object sender, EventArgs e)
    {
        hfConsultaPagina.Value = "1";
        AtivarAba("consultar");
    }

    protected void btnLimparConsulta_Click(object sender, EventArgs e)
    {
        txtConsultaBusca.Text = "";
        hfConsultaPagina.Value = "1";
        ddlConsultaTamanho.SelectedValue = "50";
        if (ddlConsultaLoja.Items.Count > 0)
        {
            ddlConsultaLoja.SelectedValue = "0";
        }
        AtivarAba("consultar");
    }

    protected void btnConsultaAnterior_Click(object sender, EventArgs e)
    {
        int pagina = PaginaConsulta();
        hfConsultaPagina.Value = Math.Max(1, pagina - 1).ToString();
        AtivarAba("consultar");
    }

    protected void btnConsultaProxima_Click(object sender, EventArgs e)
    {
        hfConsultaPagina.Value = (PaginaConsulta() + 1).ToString();
        AtivarAba("consultar");
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

        int seminovoId;
        int destino;
        if (!Int32.TryParse(hfTransferenciaId.Value, out seminovoId))
        {
            MostrarMensagem("warning", "Pesquise o seminovo", "Localize um seminovo ativo antes de transferir.");
            return;
        }

        if (!Int32.TryParse(ddlTransferenciaDestino.SelectedValue, out destino) || destino <= 0)
        {
            MostrarMensagem("warning", "Selecione o destino", "Escolha a loja destino para concluir a transfer\u00eancia.");
            ddlTransferenciaDestino.Focus();
            return;
        }

        if (!LojaAtiva(destino))
        {
            MostrarMensagem("warning", "Loja inativa", "A loja destino selecionada n\u00e3o est\u00e1 ativa. Atualize a tela e escolha outra loja.");
            return;
        }

        if (!chkConfirmarTransferencia.Checked)
        {
            MostrarMensagem("warning", "Confirma\u00e7\u00e3o obrigat\u00f3ria", "Marque a confirma\u00e7\u00e3o informando que voc\u00ea est\u00e1 movendo o seminovo para a loja correta.");
            return;
        }

        DataTable resposta = ExecutarProcedureTabela(
            "dbo.veiculos_patio_seminovos_transferir",
            Param("@seminovo_id", SqlDbType.Int, seminovoId),
            Param("@lojaDestino", SqlDbType.Int, destino),
            Param("@fun_cad", SqlDbType.VarChar, UsuarioAtual())
        );

        string resultado = resposta.Rows.Count > 0 ? Valor(resposta.Rows[0], "resultado") : "";
        if (resultado == "s")
        {
            RegistrarAuditoria("TRANSFERENCIA_SALVA", null, txtTransferenciaBusca.Text, "SeminovoId=" + seminovoId + "; Destino=" + destino);
            MostrarMensagem("success", "Transfer\u00eancia conclu\u00edda", "A localiza\u00e7\u00e3o do seminovo foi atualizada com sucesso.");
            BuscarTransferencia(false);
            return;
        }

        if (resultado == "i")
        {
            MostrarMensagem("warning", "Origem e destino iguais", "Selecione uma loja diferente da localiza\u00e7\u00e3o atual.");
            return;
        }

        RegistrarAuditoria("TRANSFERENCIA_ERRO", null, txtTransferenciaBusca.Text, "SeminovoId=" + seminovoId + "; Resultado=" + resultado);
        MostrarMensagem("error", "N\u00e3o foi poss\u00edvel transferir", "O seminovo n\u00e3o est\u00e1 mais ativo no p\u00e1tio ou os dados foram alterados. Pesquise novamente.");
    }

    protected void btnAtualizarRelatorio_Click(object sender, EventArgs e)
    {
        AtivarAba("relatorios");
        MostrarMensagem("success", "BI atualizado", "Relat\u00f3rio carregado com os dados atuais de seminovos.");
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
        pnlConsultar.Visible = aba == "consultar";
        pnlTransferir.Visible = aba == "transferir";
        pnlRelatorios.Visible = aba == "relatorios";

        tabRegistrar.CssClass = ClasseAba(aba, "registrar");
        tabConsultar.CssClass = ClasseAba(aba, "consultar");
        tabTransferir.CssClass = ClasseAba(aba, "transferir");
        tabRelatorios.CssClass = ClasseAba(aba, "relatorios");

        btnSalvarRegistro.Enabled = !String.IsNullOrWhiteSpace(hfRegistroVeNr.Value);
        btnTransferir.Enabled = !String.IsNullOrWhiteSpace(hfTransferenciaId.Value);

        if (aba == "consultar")
        {
            CarregarConsulta();
        }
        else if (aba == "relatorios")
        {
            CarregarRelatorio();
        }
    }

    private string NormalizarAba(string aba)
    {
        aba = (aba ?? "").Trim().ToLowerInvariant();
        if (aba == "consultar" || aba == "transferir" || aba == "relatorios")
        {
            return aba;
        }
        return "registrar";
    }

    private string ClasseAba(string atual, string aba)
    {
        return "semi-tab" + (atual == aba ? " is-active" : "");
    }

    private void CarregarLojas()
    {
        DataTable lojas = ExecutarSqlTabela(@"
SELECT id, ds
FROM dbo.veiculos_patio_loja
WHERE ISNULL(ativo, 1) = 1
ORDER BY ds;");

        BindLojas(ddlRegistroLoja, lojas, false);
        BindLojas(ddlTransferenciaDestino, lojas, true);
        BindLojas(ddlConsultaLoja, lojas, true);
    }

    private void BindLojas(DropDownList lista, DataTable lojas, bool incluirTodas)
    {
        lista.Items.Clear();
        if (incluirTodas)
        {
            lista.Items.Add(new ListItem(lista == ddlConsultaLoja ? "Todas as lojas" : "Selecione a loja", "0"));
        }

        foreach (DataRow loja in lojas.Rows)
        {
            lista.Items.Add(new ListItem(Valor(loja, "ds"), Valor(loja, "id")));
        }
    }

    private void CarregarConsulta()
    {
        int loja;
        Int32.TryParse(ddlConsultaLoja.SelectedValue, out loja);
        string busca = NormalizarBusca(txtConsultaBusca.Text);
        int total;
        int pagina = PaginaConsulta();
        int tamanho = TamanhoConsulta();

        DataTable tabela = ListarSeminovosConsulta(loja, busca, tamanho, pagina, out total);

        int detalheId = 0;
        DataRow detalhe = null;
        if (!IsPostBack && Int32.TryParse(Request.QueryString["detalhe"], out detalheId))
        {
            detalhe = LocalizarSeminovoPorId(detalheId);
        }
        else if (busca.Length >= 4 && tabela.Rows.Count == 1)
        {
            detalhe = tabela.Rows[0];
            Int32.TryParse(Valor(detalhe, "id"), out detalheId);
        }

        litConsultaDetalhe.Text = detalhe == null ? "" : RenderConsultaDetalhe(detalhe);
        litConsultaTabela.Text = RenderConsulta(tabela, detalheId);
        litConsultaPaginacao.Text = RenderConsultaPaginacao(total, pagina, tamanho);
        btnConsultaAnterior.Enabled = pagina > 1;
        btnConsultaProxima.Enabled = (pagina * tamanho) < total;
    }

    private int PaginaConsulta()
    {
        int pagina;
        return Int32.TryParse(hfConsultaPagina.Value, out pagina) && pagina > 0 ? pagina : 1;
    }

    private int TamanhoConsulta()
    {
        int tamanho;
        if (!Int32.TryParse(ddlConsultaTamanho.SelectedValue, out tamanho)) tamanho = 50;
        if (tamanho != 25 && tamanho != 50 && tamanho != 100) tamanho = 50;
        return tamanho;
    }

    private string RenderConsultaPaginacao(int total, int pagina, int tamanho)
    {
        int inicio = total == 0 ? 0 : ((pagina - 1) * tamanho) + 1;
        int fim = Math.Min(total, pagina * tamanho);
        int paginas = total == 0 ? 1 : (int)Math.Ceiling(total / (double)tamanho);
        return "<span class=\"semi-pager-info\">P&aacute;gina " + pagina + " de " + paginas + " &middot; " + inicio + "-" + fim + " de " + total + " seminovo(s)</span>";
    }

    private void CarregarRelatorio()
    {
        DataTable resumo = ExecutarSqlTabela(@"
SELECT
    COUNT(1) AS total_ativos,
    COUNT(DISTINCT COALESCE(NULLIF(loja_atual_id, 0), loja_id)) AS lojas_com_veiculos,
    SUM(CASE WHEN dt_cad >= CONVERT(date, GETDATE()) THEN 1 ELSE 0 END) AS entradas_hoje,
    SUM(CASE WHEN dt_cad >= DATEADD(day, -7, GETDATE()) THEN 1 ELSE 0 END) AS entradas_7_dias,
    MAX(dt_cad) AS ultima_entrada
FROM dbo.veiculos_patio_seminovos_locacao WITH (NOLOCK)
WHERE ativo = 1;");

        DataTable transferencias = ExecutarSqlTabela(@"
SELECT
    COUNT(1) AS transferencias_mes,
    MAX(dt_transf) AS ultima_transferencia
FROM dbo.veiculos_patio_seminovos_transferencia WITH (NOLOCK)
WHERE dt_transf >= DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0);");

        litResumo.Text = RenderResumo(resumo, transferencias);

        litEstoquePorLoja.Text = RenderBarras(ExecutarSqlTabela(@"
SELECT TOP 12 COALESCE(l.ds, 'Sem loja') AS label, COUNT(1) AS total
FROM dbo.veiculos_patio_seminovos_locacao p WITH (NOLOCK)
LEFT JOIN dbo.veiculos_patio_loja l WITH (NOLOCK)
    ON l.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
WHERE p.ativo = 1
GROUP BY COALESCE(l.ds, 'Sem loja')
ORDER BY COUNT(1) DESC, COALESCE(l.ds, 'Sem loja');"), "Nenhum seminovo ativo no p&aacute;tio.");

        litEntradasDia.Text = RenderBarras(ExecutarSqlTabela(@"
SELECT CONVERT(varchar(10), CONVERT(date, dt_cad), 103) AS label, COUNT(1) AS total
FROM dbo.veiculos_patio_seminovos_locacao WITH (NOLOCK)
WHERE ativo = 1
  AND dt_cad >= DATEADD(day, -13, CONVERT(date, GETDATE()))
GROUP BY CONVERT(date, dt_cad)
ORDER BY CONVERT(date, dt_cad);"), "Nenhuma entrada nos &uacute;ltimos 14 dias.");

        litMovimentacoesDia.Text = RenderBarras(ExecutarSqlTabela(@"
SELECT CONVERT(varchar(10), CONVERT(date, dt_transf), 103) AS label, COUNT(1) AS total
FROM dbo.veiculos_patio_seminovos_transferencia WITH (NOLOCK)
WHERE dt_transf >= DATEADD(day, -13, CONVERT(date, GETDATE()))
GROUP BY CONVERT(date, dt_transf)
ORDER BY CONVERT(date, dt_transf);"), "Nenhuma transfer&ecirc;ncia nos &uacute;ltimos 14 dias.");

        litUltimosCadastros.Text = RenderConsulta(ExecutarProcedureTabela(
            "dbo.veiculos_patio_seminovos_listar",
            Param("@loja", SqlDbType.Int, 0),
            Param("@busca", SqlDbType.VarChar, "")
        ));

        litAuditoria.Text = RenderAuditoria(ExecutarSqlTabela(@"
SELECT TOP 20 dt, acao, usuario, ve_nr, referencia, detalhe, ip
FROM dbo.veiculos_patio_seminovos_auditoria WITH (NOLOCK)
ORDER BY dt DESC, id DESC;"));
    }

    private void BuscarTransferencia(bool exibirMensagemNaoEncontrado)
    {
        LimparTransferencia(false);
        string busca = NormalizarBusca(txtTransferenciaBusca.Text);
        txtTransferenciaBusca.Text = busca;

        if (busca.Length < 4)
        {
            MostrarMensagem("warning", "Informe mais dados", "Digite c\u00f3digo do ve\u00edculo, chassi, placa ou Renavam antes de pesquisar.");
            txtTransferenciaBusca.Focus();
            return;
        }

        DataRow seminovo = LocalizarSeminovo(busca);
        if (seminovo == null)
        {
            RegistrarAuditoria("TRANSFERENCIA_NAO_ENCONTRADO", null, busca, "Nenhum seminovo ativo encontrado.");
            if (exibirMensagemNaoEncontrado)
            {
                MostrarMensagem("warning", "Seminovo n\u00e3o encontrado", "N\u00e3o existe seminovo ativo no p\u00e1tio para esse c\u00f3digo, chassi, placa ou Renavam.");
            }
            return;
        }

        hfTransferenciaId.Value = Valor(seminovo, "id");
        btnTransferir.Enabled = true;
        chkConfirmarTransferencia.Checked = false;
        litConfirmacaoTransferencia.Text = "Estou movendo o seminovo " + Html(Valor(seminovo, "ve_ds")) + " de " + Html(Valor(seminovo, "loja_atual")) + " para a loja selecionada.";
        litTransferenciaVeiculo.Text = RenderVeiculoCard(seminovo, "success", "Seminovo localizado", "Local atual: " + Valor(seminovo, "loja_atual"));

        int id;
        if (Int32.TryParse(hfTransferenciaId.Value, out id))
        {
            litTransferenciaHistorico.Text = RenderHistorico(id);
        }

        string lojaAtual = Valor(seminovo, "loja_atual_id");
        SelecionarDestinoDiferente(lojaAtual);
        RegistrarAuditoria("TRANSFERENCIA_BUSCA_SUCESSO", ToIntNullable(Valor(seminovo, "ve_nr")), busca, "Seminovo ativo localizado para transferencia.");
    }

    private void SelecionarDestinoDiferente(string lojaAtual)
    {
        if (ddlTransferenciaDestino.Items.Count == 0)
        {
            return;
        }

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

    private DataRow ConsultarVeiculoDealernet(string busca)
    {
        DataTable tabela = ExecutarProcedureTabela(
            "dbo.veiculos_patio_seminovos_consultar_veiculo",
            Param("@busca", SqlDbType.VarChar, busca)
        );
        return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
    }

    private DataRow LocalizarSeminovo(string busca)
    {
        DataTable tabela = ExecutarProcedureTabela(
            "dbo.veiculos_patio_seminovos_localizar",
            Param("@busca", SqlDbType.VarChar, busca)
        );
        return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
    }

    private DataTable ListarSeminovosConsulta(int loja, string busca, int tamanhoPagina, int pagina, out int total)
    {
        string valor = NormalizarBusca(busca);
        int inicio = ((Math.Max(1, pagina) - 1) * Math.Max(1, tamanhoPagina)) + 1;
        int fim = inicio + Math.Max(1, tamanhoPagina) - 1;

        string baseSql = @"
;WITH filtrado AS
(
    SELECT
        p.id,
        p.ve_nr,
        p.ve_ds,
        p.ve_chassi,
        p.ve_placa,
        p.ve_renavam,
        p.cor_ds,
        p.numeronf,
        COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) AS loja_atual_id,
        COALESCE(l.ds, 'Sem loja') AS loja_atual,
        p.fun_cad,
        p.dt_cad,
        p.observacao
    FROM dbo.veiculos_patio_seminovos_locacao p WITH (NOLOCK)
    LEFT JOIN dbo.veiculos_patio_loja l WITH (NOLOCK)
        ON l.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
    WHERE p.ativo = 1
      AND (@loja = 0 OR COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) = @loja)
      AND (
            @valor = ''
         OR CONVERT(varchar(20), p.ve_nr) = @valor
         OR CONVERT(varchar(20), p.id) = @valor
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(p.ve_placa, '')), '-', ''), ' ', ''), '.', '') LIKE @valorLike
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(p.ve_chassi, '')), '-', ''), ' ', ''), '.', '') LIKE @valorLike
         OR REPLACE(REPLACE(REPLACE(UPPER(ISNULL(p.ve_renavam, '')), '-', ''), ' ', ''), '.', '') LIKE @valorLike
         OR UPPER(ISNULL(p.ve_ds, '')) LIKE @valorLike
      )
)";

        DataTable totalTabela = ExecutarSqlTabela(baseSql + @"
SELECT COUNT(1) AS total
FROM filtrado;",
            Param("@loja", SqlDbType.Int, loja),
            Param("@valor", SqlDbType.VarChar, valor),
            Param("@valorLike", SqlDbType.VarChar, "%" + valor + "%"));

        total = totalTabela.Rows.Count > 0 ? ToInt(Valor(totalTabela.Rows[0], "total")) : 0;

        return ExecutarSqlTabela(baseSql + @"
, numerado AS
(
    SELECT ROW_NUMBER() OVER (ORDER BY dt_cad DESC, id DESC) AS rn, *
    FROM filtrado
)
SELECT *
FROM numerado
WHERE rn BETWEEN @inicio AND @fim
ORDER BY rn;",
            Param("@loja", SqlDbType.Int, loja),
            Param("@valor", SqlDbType.VarChar, valor),
            Param("@valorLike", SqlDbType.VarChar, "%" + valor + "%"),
            Param("@inicio", SqlDbType.Int, inicio),
            Param("@fim", SqlDbType.Int, fim));
    }

    private DataRow LocalizarSeminovoPorId(int id)
    {
        DataTable tabela = ExecutarSqlTabela(@"
SELECT TOP 1
    p.id,
    p.ve_nr,
    p.ve_ds,
    p.ve_chassi,
    p.ve_placa,
    p.ve_renavam,
    p.cor_ds,
    p.codnf,
    p.numeronf,
    p.loja_id,
    COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id) AS loja_atual_id,
    COALESCE(l.ds, 'Sem loja') AS loja_atual,
    p.fun_cad,
    p.dt_cad,
    p.observacao
FROM dbo.veiculos_patio_seminovos_locacao p WITH (NOLOCK)
LEFT JOIN dbo.veiculos_patio_loja l WITH (NOLOCK)
    ON l.id = COALESCE(NULLIF(p.loja_atual_id, 0), p.loja_id)
WHERE p.ativo = 1
  AND p.id = @id;",
            Param("@id", SqlDbType.Int, id));

        return tabela.Rows.Count > 0 ? tabela.Rows[0] : null;
    }

    private string RenderVeiculoCard(DataRow row, string tipo, string titulo, string subtitulo)
    {
        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"semi-vehicle-card\">");
        html.Append("<div class=\"semi-vehicle-main\">");
        html.Append("<div><strong>").Append(Html(Valor(row, "ve_ds"))).Append("</strong>");
        html.Append("<small>").Append(Html(subtitulo)).Append("</small></div>");
        html.Append("<span class=\"semi-pill\"><i class=\"fa fa-car\"></i> C&oacute;d. ").Append(Html(Valor(row, "ve_nr"))).Append("</span>");
        html.Append("</div>");
        html.Append("<div class=\"semi-pill-list\">");
        html.Append(Pill("Chassi", Valor(row, "ve_chassi")));
        html.Append(Pill("Placa", Valor(row, "ve_placa")));
        html.Append(Pill("Renavam", Valor(row, "ve_renavam")));
        html.Append(Pill("Cor", Valor(row, "cor_ds")));
        html.Append(Pill("NF", Valor(row, "numeronf")));
        if (row.Table.Columns.Contains("loja_atual"))
        {
            html.Append(Pill("Loja atual", Valor(row, "loja_atual")));
        }
        html.Append("</div>");
        html.Append("</div>");
        return html.ToString();
    }

    private string RenderConsulta(DataTable tabela)
    {
        return RenderConsulta(tabela, 0);
    }

    private string RenderConsulta(DataTable tabela, int detalheId)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"semi-empty\">Nenhum seminovo encontrado neste filtro.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"semi-table\"><thead><tr>");
        html.Append("<th>A&ccedil;&otilde;es</th><th>Ve&iacute;culo</th><th>Chassi</th><th>Placa</th><th>Renavam</th><th>Cor</th><th>Loja atual</th><th>Cadastro</th>");
        html.Append("</tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            string busca = HttpUtility.UrlEncode(Valor(row, "ve_chassi"));
            string id = Valor(row, "id");
            bool selecionado = detalheId > 0 && id == Convert.ToString(detalheId);
            html.Append("<tr>");
            html.Append("<td data-label=\"A&ccedil;&otilde;es\"><span class=\"semi-row-actions\">");
            html.Append("<a class=\"semi-mini-action\" href=\"seminovos.aspx?aba=consultar&amp;detalhe=").Append(HttpUtility.UrlEncode(id)).Append("\"><i class=\"fa fa-history\"></i>").Append(selecionado ? "Selecionado" : "Hist&oacute;rico").Append("</a>");
            html.Append("<a class=\"semi-mini-action\" href=\"seminovos.aspx?aba=transferir&amp;busca=").Append(busca).Append("\"><i class=\"fa fa-exchange-alt\"></i>Transferir</a>");
            html.Append("</span></td>");
            html.Append("<td data-label=\"Ve&iacute;culo\"><strong>").Append(Html(Valor(row, "ve_ds"))).Append("</strong><small>C&oacute;d. ").Append(Html(Valor(row, "ve_nr"))).Append("</small></td>");
            html.Append("<td data-label=\"Chassi\">").Append(Html(Valor(row, "ve_chassi"))).Append("</td>");
            html.Append("<td data-label=\"Placa\">").Append(Html(Valor(row, "ve_placa"))).Append("</td>");
            html.Append("<td data-label=\"Renavam\">").Append(Html(Valor(row, "ve_renavam"))).Append("</td>");
            html.Append("<td data-label=\"Cor\">").Append(Html(Valor(row, "cor_ds"))).Append("</td>");
            html.Append("<td data-label=\"Loja atual\"><span class=\"semi-location-pill\"><i class=\"fa fa-map-marker-alt\"></i>").Append(Html(Valor(row, "loja_atual"))).Append("</span></td>");
            html.Append("<td data-label=\"Cadastro\">").Append(DataCurta(row, "dt_cad")).Append("<small>").Append(Html(Valor(row, "fun_cad"))).Append("</small></td>");
            html.Append("</tr>");
        }
        html.Append("</tbody></table>");
        return html.ToString();
    }

    private string RenderConsultaDetalhe(DataRow row)
    {
        int id;
        Int32.TryParse(Valor(row, "id"), out id);

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"semi-detail-panel\">");
        html.Append("<div class=\"semi-detail-header\">");
        html.Append("<div><small>Localiza&ccedil;&atilde;o atual</small><strong>").Append(Html(Valor(row, "ve_ds"))).Append("</strong>");
        html.Append("<span>Cadastro realizado em ").Append(DataCurta(row, "dt_cad")).Append(" por ").Append(Html(Valor(row, "fun_cad"))).Append("</span></div>");
        html.Append("<span class=\"semi-location-pill\"><i class=\"fa fa-map-marker-alt\"></i>").Append(Html(Valor(row, "loja_atual"))).Append("</span>");
        html.Append("</div>");
        html.Append("<div class=\"semi-pill-list\">");
        html.Append(Pill("C&oacute;digo", Valor(row, "ve_nr")));
        html.Append(Pill("Chassi", Valor(row, "ve_chassi")));
        html.Append(Pill("Placa", Valor(row, "ve_placa")));
        html.Append(Pill("Renavam", Valor(row, "ve_renavam")));
        html.Append(Pill("Cor", Valor(row, "cor_ds")));
        html.Append(Pill("NF", Valor(row, "numeronf")));
        if (!String.IsNullOrWhiteSpace(Valor(row, "observacao")))
        {
            html.Append(Pill("Obs.", Valor(row, "observacao")));
        }
        html.Append("</div>");
        html.Append("<div class=\"semi-history-title\"><span><i class=\"fa fa-route\"></i> Hist&oacute;rico de transfer&ecirc;ncias</span>");
        html.Append("<a class=\"semi-mini-action\" href=\"seminovos.aspx?aba=transferir&amp;busca=").Append(HttpUtility.UrlEncode(Valor(row, "ve_chassi"))).Append("\"><i class=\"fa fa-exchange-alt\"></i>Transferir este carro</a></div>");
        html.Append("<div class=\"semi-table-wrap\">").Append(RenderHistorico(id)).Append("</div>");
        html.Append("</div>");
        return html.ToString();
    }

    private string RenderHistorico(int seminovoId)
    {
        DataTable tabela = ExecutarProcedureTabela(
            "dbo.veiculos_patio_seminovos_historico",
            Param("@seminovo_id", SqlDbType.Int, seminovoId)
        );

        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"semi-empty\">Nenhuma movimenta&ccedil;&atilde;o registrada para este seminovo.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"semi-table\"><thead><tr>");
        html.Append("<th>Data</th><th>Movimento</th><th>Origem</th><th>Destino</th><th>Usu&aacute;rio</th>");
        html.Append("</tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td data-label=\"Data\">").Append(DataCurta(row, "data_movimento")).Append("</td>");
            html.Append("<td data-label=\"Movimento\">").Append(Html(Valor(row, "movimento"))).Append("</td>");
            html.Append("<td data-label=\"Origem\">").Append(Html(String.IsNullOrWhiteSpace(Valor(row, "origem")) ? "-" : Valor(row, "origem"))).Append("</td>");
            html.Append("<td data-label=\"Destino\"><span class=\"semi-pill\">").Append(Html(Valor(row, "destino"))).Append("</span></td>");
            html.Append("<td data-label=\"Usu&aacute;rio\">").Append(Html(Valor(row, "usuario"))).Append("</td>");
            html.Append("</tr>");
        }
        html.Append("</tbody></table>");
        return html.ToString();
    }

    private string RenderResumo(DataTable resumo, DataTable transferencias)
    {
        DataRow r = resumo.Rows.Count > 0 ? resumo.Rows[0] : null;
        DataRow t = transferencias.Rows.Count > 0 ? transferencias.Rows[0] : null;

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"semi-kpis\">");
        html.Append(Kpi("Ativos", Numero(r, "total_ativos"), "seminovos no p&aacute;tio"));
        html.Append(Kpi("Lojas", Numero(r, "lojas_com_veiculos"), "com estoque ativo"));
        html.Append(Kpi("Hoje", Numero(r, "entradas_hoje"), "entradas no dia"));
        html.Append(Kpi("7 dias", Numero(r, "entradas_7_dias"), "entradas recentes"));
        html.Append(Kpi("Transfer&ecirc;ncias", Numero(t, "transferencias_mes"), "no m&ecirc;s atual"));
        html.Append("</div>");
        return html.ToString();
    }

    private string RenderBarras(DataTable tabela, string vazio)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"semi-empty\">" + vazio + "</div>";
        }

        int maior = 1;
        foreach (DataRow row in tabela.Rows)
        {
            maior = Math.Max(maior, ToInt(Valor(row, "total")));
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class=\"semi-bar-list\">");
        foreach (DataRow row in tabela.Rows)
        {
            int total = ToInt(Valor(row, "total"));
            int largura = Math.Max(4, (int)Math.Round((total * 100.0) / maior));
            html.Append("<div class=\"semi-bar-row\">");
            html.Append("<div class=\"semi-bar-label\" title=\"").Append(Html(Valor(row, "label"))).Append("\">").Append(Html(Valor(row, "label"))).Append("</div>");
            html.Append("<div class=\"semi-bar-track\"><span style=\"width:").Append(largura).Append("%\"></span></div>");
            html.Append("<div class=\"semi-bar-value\">").Append(total).Append("</div>");
            html.Append("</div>");
        }
        html.Append("</div>");
        return html.ToString();
    }

    private string RenderAuditoria(DataTable tabela)
    {
        if (tabela.Rows.Count == 0)
        {
            return "<div class=\"semi-empty\">Nenhuma a&ccedil;&atilde;o registrada ainda.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class=\"semi-table\"><thead><tr>");
        html.Append("<th>Data</th><th>A&ccedil;&atilde;o</th><th>Usu&aacute;rio</th><th>Ref.</th><th>Detalhe</th>");
        html.Append("</tr></thead><tbody>");
        foreach (DataRow row in tabela.Rows)
        {
            html.Append("<tr>");
            html.Append("<td data-label=\"Data\">").Append(DataCurta(row, "dt")).Append("</td>");
            html.Append("<td data-label=\"A&ccedil;&atilde;o\">").Append(Html(Valor(row, "acao"))).Append("</td>");
            html.Append("<td data-label=\"Usu&aacute;rio\">").Append(Html(Valor(row, "usuario"))).Append("</td>");
            html.Append("<td data-label=\"Ref.\">").Append(Html(Valor(row, "referencia"))).Append("</td>");
            html.Append("<td data-label=\"Detalhe\">").Append(Html(Valor(row, "detalhe"))).Append("</td>");
            html.Append("</tr>");
        }
        html.Append("</tbody></table>");
        return html.ToString();
    }

    private string Pill(string label, string value)
    {
        return "<span class=\"semi-pill\"><b>" + Html(label) + "</b> " + Html(String.IsNullOrWhiteSpace(value) ? "-" : value) + "</span>";
    }

    private string Kpi(string label, string valor, string detalhe)
    {
        return "<div class=\"semi-kpi\"><small>" + label + "</small><strong>" + valor + "</strong><span>" + detalhe + "</span></div>";
    }

    private void LimparRegistro(bool limparBusca)
    {
        hfRegistroVeNr.Value = "";
        hfRegistroReferencia.Value = "";
        litRegistroVeiculo.Text = "";
        btnSalvarRegistro.Enabled = false;
        if (limparBusca)
        {
            txtRegistroBusca.Text = "";
            txtRegistroObservacao.Text = "";
        }
    }

    private void LimparTransferencia(bool limparBusca)
    {
        hfTransferenciaId.Value = "";
        litTransferenciaVeiculo.Text = "";
        litTransferenciaHistorico.Text = "";
        chkConfirmarTransferencia.Checked = false;
        litConfirmacaoTransferencia.Text = "Pesquise um seminovo para gerar a confirma&ccedil;&atilde;o.";
        btnTransferir.Enabled = false;
        if (limparBusca)
        {
            txtTransferenciaBusca.Text = "";
        }
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
                foreach (SqlParameter parametro in parametros)
                {
                    cmd.Parameters.Add(parametro);
                }
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(tabela);
                }
            }
        }
        finally
        {
            banco.FecharConexao2();
        }
        return tabela;
    }

    private DataTable ExecutarSqlTabela(string sql)
    {
        DataTable tabela = new DataTable();
        Jeep banco = new Jeep();
        try
        {
            banco.Conexao2();
            using (SqlCommand cmd = new SqlCommand(sql, banco.oCon2))
            {
                cmd.CommandTimeout = 30;
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(tabela);
                }
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
                foreach (SqlParameter parametro in parametros)
                {
                    cmd.Parameters.Add(parametro);
                }
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(tabela);
                }
            }
        }
        finally
        {
            banco.FecharConexao2();
        }
        return tabela;
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

    private bool UsuarioTemAcesso(int acessoId)
    {
        string cacheKey = "patio_acesso_" + acessoId;
        if (Session[cacheKey] != null)
        {
            return Session[cacheKey].ToString() == "s";
        }

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

    private SqlParameter Param(string nome, SqlDbType tipo, object valor)
    {
        SqlParameter parametro = new SqlParameter(nome, tipo);
        parametro.Value = valor ?? DBNull.Value;
        return parametro;
    }

    private object TextoOuDbNull(string valor)
    {
        valor = (valor ?? "").Trim();
        return valor.Length == 0 ? (object)DBNull.Value : valor;
    }

    private void RegistrarAuditoria(string acao, int? veNr, string referencia, string detalhe)
    {
        try
        {
            ExecutarProcedureTabela(
                "dbo.veiculos_patio_seminovos_auditoria_registrar",
                Param("@acao", SqlDbType.VarChar, acao),
                Param("@usuario", SqlDbType.VarChar, UsuarioAtual()),
                Param("@ve_nr", SqlDbType.Int, veNr.HasValue ? (object)veNr.Value : DBNull.Value),
                Param("@referencia", SqlDbType.VarChar, referencia ?? ""),
                Param("@detalhe", SqlDbType.VarChar, detalhe ?? ""),
                Param("@ip", SqlDbType.VarChar, IpUsuario())
            );
        }
        catch
        {
            try
            {
                PatioJeepAuditoria.Registrar("SEMINOVOS_" + acao, Session["usuario"], referencia, detalhe);
            }
            catch { }
        }
    }

    private void MostrarMensagem(string tipo, string titulo, string texto)
    {
        string classe = "semi-alert";
        if (tipo == "success") classe += " is-success";
        else if (tipo == "warning") classe += " is-warning";
        else if (tipo == "error") classe += " is-error";

        pnlMensagem.CssClass = classe;
        pnlMensagem.Visible = true;
        litMensagem.Text = "<strong>" + Html(titulo) + "</strong><span>" + Html(texto) + "</span>";
    }

    private string NormalizarBusca(string valor)
    {
        valor = (valor ?? "").Trim().ToUpperInvariant();
        StringBuilder limpo = new StringBuilder();
        foreach (char caractere in valor)
        {
            if (Char.IsLetterOrDigit(caractere))
            {
                limpo.Append(caractere);
            }
        }
        return limpo.ToString();
    }

    private string UsuarioAtual()
    {
        return Convert.ToString(Session["usuario"]);
    }

    private string IpUsuario()
    {
        return Request.ServerVariables["HTTP_X_FORWARDED_FOR"] ?? Request.UserHostAddress ?? "";
    }

    private string Html(string valor)
    {
        return HttpUtility.HtmlEncode(valor ?? "");
    }

    private string Valor(DataRow row, string coluna)
    {
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value)
        {
            return "";
        }
        return Convert.ToString(row[coluna]);
    }

    private string DataCurta(DataRow row, string coluna)
    {
        DateTime data;
        if (row == null || !row.Table.Columns.Contains(coluna) || row[coluna] == DBNull.Value || !DateTime.TryParse(Convert.ToString(row[coluna]), out data))
        {
            return "-";
        }
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

    private int? ToIntNullable(string valor)
    {
        int numero;
        return Int32.TryParse(valor, out numero) ? (int?)numero : null;
    }
}
