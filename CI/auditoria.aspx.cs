using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ci_auditoria : System.Web.UI.Page
{
    private const string ViewStateCookieName = "BaliViewStateKey";
    private const int TimeoutSqlSegundos = 60;
    private static readonly CultureInfo CulturaBrasil = new CultureInfo("pt-BR");

    public string TituloPagina = "Logs da CI";

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
        if (!UsuarioCIAutenticado())
        {
            RedirecionarLoginCI();
            return;
        }

        if (!IsPostBack)
        {
            CarregarAuditoria();
        }
    }

    protected void gvLinhaTempo_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;

        int limite = Math.Min(gvLinhaTempo.Columns.Count, e.Row.Cells.Count);
        for (int i = 0; i < limite; i++)
        {
            e.Row.Cells[i].Attributes["data-label"] = Server.HtmlDecode(gvLinhaTempo.Columns[i].HeaderText);
        }

        if (e.Row.Cells.Count > 1)
        {
            string fonte = Server.HtmlEncode(Server.HtmlDecode(e.Row.Cells[1].Text));
            e.Row.Cells[1].Text = "<span class=\"audit-event-source\">" + fonte + "</span>";
        }
    }

    private void CarregarAuditoria()
    {
        int id;
        if (!Int32.TryParse(Request.QueryString["id"], out id) || id <= 0)
        {
            MostrarErro("Informe uma CI v\u00e1lida para consultar os logs.");
            return;
        }

        DataTable dados = ExecutarTabela("dbo.ci_comunicacao_obter", Param("@id_ci", SqlDbType.Int, id));
        if (dados.Rows.Count == 0)
        {
            MostrarErro("CI n\u00e3o encontrada para auditoria.");
            return;
        }

        DataRow row = dados.Rows[0];
        string codigo = Convert.ToString(row["codigo_ci"]);
        TituloPagina = codigo + " - Logs";

        PreencherResumo(row);
        DataTable timeline = MontarLinhaTempo(id, row);
        gvLinhaTempo.DataSource = timeline;
        gvLinhaTempo.DataBind();
        litResumoTimeline.Text = timeline.Rows.Count == 0
            ? "Nenhuma movimenta\u00e7\u00e3o foi localizada para esta CI."
            : "Exibindo " + timeline.Rows.Count.ToString(CultureInfo.InvariantCulture) + " movimenta\u00e7\u00f5es registradas em ordem cronol\u00f3gica.";

        pnlConteudo.Visible = true;
        RegistrarAuditoriaCI("ABRIR_LOGS_CI", id, codigo, "Tela de auditoria da CI aberta.");
    }

    private void PreencherResumo(DataRow row)
    {
        string codigo = Convert.ToString(row["codigo_ci"]);
        string status = Convert.ToString(row["status"]);
        string criadoPor = Convert.ToString(row["criado_por"]);

        litTitulo.Text = Server.HtmlEncode("Logs da " + codigo);
        litSubtitulo.Text = Server.HtmlEncode("Auditoria completa da comunica\u00e7\u00e3o interna, incluindo cria\u00e7\u00e3o, edi\u00e7\u00f5es, impress\u00f5es, cancelamentos e hist\u00f3rico de campos.");
        litResumo.Text = Server.HtmlEncode(CorrigirAcentosQuebrados(Convert.ToString(row["assunto"])));
        litCodigo.Text = Server.HtmlEncode(codigo);
        litStatus.Text = Server.HtmlEncode(status);
        litCriadaEm.Text = Server.HtmlEncode(FormatarDataHora(row["dt_cadastro"]));
        litAlteradaEm.Text = Server.HtmlEncode(FormatarDataHora(row["dt_alteracao"]));
        litCriadoPor.Text = Server.HtmlEncode(String.IsNullOrWhiteSpace(criadoPor) ? "N\u00e3o informado" : criadoPor);
        lnkImprimir.NavigateUrl = "print.aspx?id=" + Convert.ToString(row["id_ci"], CultureInfo.InvariantCulture);

        StringBuilder html = new StringBuilder();
        html.Append("<dl>");
        AdicionarItemDadosAtuais(html, "Marca", row["origem_marca"]);
        AdicionarItemDadosAtuais(html, "Data da CI", FormatarData(row["data_documento"]));
        AdicionarItemDadosAtuais(html, "Origem", Convert.ToString(row["origem_area"]) + " / " + Convert.ToString(row["origem_responsavel"]));
        AdicionarItemDadosAtuais(html, "Destino", Convert.ToString(row["destino_area"]) + " / " + Convert.ToString(row["destinatario"]));
        AdicionarItemDadosAtuais(html, "Categoria", row["categoria"]);
        AdicionarItemDadosAtuais(html, "Prioridade", row["prioridade"]);
        AdicionarItemDadosAtuais(html, "Assunto", row["assunto"]);
        AdicionarItemDadosAtuais(html, "Ativa", Convert.ToBoolean(row["ativo"]) ? "Sim" : "N\u00e3o");
        html.Append("</dl>");
        litDadosAtuais.Text = html.ToString();
    }

    private void AdicionarItemDadosAtuais(StringBuilder html, string titulo, object valor)
    {
        html.Append("<div><dt>")
            .Append(Server.HtmlEncode(titulo))
            .Append("</dt><dd>")
            .Append(Server.HtmlEncode(CorrigirAcentosQuebrados(Convert.ToString(valor ?? ""))))
            .Append("</dd></div>");
    }

    private DataTable MontarLinhaTempo(int id, DataRow ci)
    {
        DataTable timeline = CriarTabelaTimeline();

        AdicionarLinhaTimeline(timeline,
            DataHora(ci["dt_cadastro"]),
            "Cadastro",
            "Cadastro inicial",
            Convert.ToString(ci["criado_por"]),
            "CI registrada no banco de dados.",
            "",
            ResumoDaCI(ci),
            "",
            1);

        DataTable auditoria = ExecutarTabela("dbo.ci_auditoria_ci_listar", Param("@id_ci", SqlDbType.Int, id));
        foreach (DataRow row in auditoria.Rows)
        {
            AdicionarLinhaTimeline(timeline,
                DataHora(row["dt_evento"]),
                "Sistema",
                NomeAcao(Convert.ToString(row["acao"])),
                UsuarioAuditoria(row),
                Convert.ToString(row["detalhe"]),
                Convert.ToString(row["dados_antes"]),
                Convert.ToString(row["dados_depois"]),
                Convert.ToString(row["ip"]),
                2);
        }

        DataTable historico = ExecutarTabela("dbo.ci_comunicacao_historico_listar", Param("@id_ci", SqlDbType.Int, id));
        foreach (DataRow row in historico.Rows)
        {
            AdicionarLinhaTimeline(timeline,
                DataHora(row["dt_evento"]),
                "Vers\u00e3o",
                CorrigirAcentosQuebrados(Convert.ToString(row["acao"])),
                Convert.ToString(row["criado_por"]),
                "Vers\u00e3o anterior preservada para auditoria.",
                ResumoHistorico(row),
                "",
                "",
                3);
        }

        DataTable campos = ExecutarTabela("dbo.ci_comunicacao_historico_campos_listar", Param("@id_ci", SqlDbType.Int, id));
        foreach (DataRow row in campos.Rows)
        {
            AdicionarLinhaTimeline(timeline,
                DataHora(row["dt_evento"]),
                "Campo",
                "Campo alterado: " + CorrigirAcentosQuebrados(Convert.ToString(row["campo"])),
                Convert.ToString(row["usuario"]),
                "Valor alterado no cadastro da CI.",
                Convert.ToString(row["valor_antigo"]),
                Convert.ToString(row["valor_novo"]),
                "",
                4);
        }

        DataView view = timeline.DefaultView;
        view.Sort = "dt_ordem ASC, prioridade ASC, acao ASC";
        return view.ToTable();
    }

    private DataTable CriarTabelaTimeline()
    {
        DataTable tabela = new DataTable();
        tabela.Columns.Add("dt_ordem", typeof(DateTime));
        tabela.Columns.Add("prioridade", typeof(int));
        tabela.Columns.Add("data_hora", typeof(string));
        tabela.Columns.Add("fonte", typeof(string));
        tabela.Columns.Add("acao", typeof(string));
        tabela.Columns.Add("usuario", typeof(string));
        tabela.Columns.Add("detalhe", typeof(string));
        tabela.Columns.Add("dados_antes", typeof(string));
        tabela.Columns.Add("dados_depois", typeof(string));
        tabela.Columns.Add("ip", typeof(string));
        return tabela;
    }

    private void AdicionarLinhaTimeline(DataTable tabela, DateTime data, string fonte, string acao, string usuario, string detalhe, string antes, string depois, string ip, int prioridade)
    {
        DataRow row = tabela.NewRow();
        row["dt_ordem"] = data;
        row["prioridade"] = prioridade;
        row["data_hora"] = data == DateTime.MinValue ? "" : data.ToString("dd/MM/yyyy HH:mm:ss", CulturaBrasil);
        row["fonte"] = TextoTabela(fonte);
        row["acao"] = TextoTabela(acao);
        row["usuario"] = TextoTabela(String.IsNullOrWhiteSpace(usuario) ? "N\u00e3o informado" : usuario);
        row["detalhe"] = TextoTabela(detalhe);
        row["dados_antes"] = TextoTabela(antes);
        row["dados_depois"] = TextoTabela(depois);
        row["ip"] = TextoTabela(ip);
        tabela.Rows.Add(row);
    }

    private string UsuarioAuditoria(DataRow row)
    {
        string usuario = Convert.ToString(row["usuario_nome"]);
        string id = Convert.ToString(row["usuario_id"]);
        if (!String.IsNullOrWhiteSpace(usuario)) return usuario;
        if (!String.IsNullOrWhiteSpace(id)) return id;
        return "N\u00e3o informado";
    }

    private string NomeAcao(string acao)
    {
        string valor = (acao ?? "").Trim().ToUpperInvariant();
        switch (valor)
        {
            case "CRIAR_CI": return "CI criada";
            case "CRIAR_RASCUNHO_CI": return "Rascunho criado";
            case "EDITAR_CI": return "CI editada";
            case "EDITAR_RASCUNHO_CI": return "Rascunho editado";
            case "ABRIR_EDICAO_CI": return "Edi\u00e7\u00e3o aberta";
            case "CANCELAR_CI": return "CI cancelada";
            case "RESTAURAR_HISTORICO_CI": return "Vers\u00e3o restaurada";
            case "IMPRIMIR_CI": return "Impress\u00e3o aberta";
            case "DUPLICAR_CI": return "CI duplicada";
            case "DUPLICAR_CI_MARCA": return "CI duplicada para outra marca";
            case "REGISTRAR_CIENCIA_CI": return "Ci\u00eancia registrada";
            case "EXCLUIR_CIENCIA_CI": return "Ci\u00eancia exclu\u00edda";
            case "ABRIR_LOGS_CI": return "Logs consultados";
            default: return CorrigirAcentosQuebrados((acao ?? "").Replace("_", " "));
        }
    }

    private string ResumoDaCI(DataRow row)
    {
        StringBuilder resumo = new StringBuilder();
        resumo.Append("Codigo=").Append(Convert.ToString(row["codigo_ci"])).Append("; ");
        resumo.Append("Status=").Append(Convert.ToString(row["status"])).Append("; ");
        resumo.Append("Marca=").Append(Convert.ToString(row["origem_marca"])).Append("; ");
        resumo.Append("Assunto=").Append(TextoPlano(Convert.ToString(row["assunto"]))).Append("; ");
        resumo.Append("Criado por=").Append(Convert.ToString(row["criado_por"]));
        return resumo.ToString();
    }

    private string ResumoHistorico(DataRow row)
    {
        StringBuilder resumo = new StringBuilder();
        resumo.Append("Codigo=").Append(Convert.ToString(row["codigo_ci"])).Append("; ");
        resumo.Append("Status anterior=").Append(Convert.ToString(row["status_ci"])).Append("; ");
        resumo.Append("Marca=").Append(Convert.ToString(row["origem_marca"])).Append("; ");
        resumo.Append("Assunto anterior=").Append(TextoPlano(Convert.ToString(row["assunto"])));
        return resumo.ToString();
    }

    private string TextoTabela(string valor)
    {
        string texto = TextoPlano(valor);
        if (texto.Length == 0) return "";
        return texto.Length > 900 ? texto.Substring(0, 900) + "...(truncado)" : texto;
    }

    private string TextoPlano(string valor)
    {
        string texto = HttpUtility.HtmlDecode(valor ?? "");
        texto = Regex.Replace(texto, "<br\\s*/?>", "\n", RegexOptions.IgnoreCase);
        texto = Regex.Replace(texto, "</p\\s*>", "\n", RegexOptions.IgnoreCase);
        texto = Regex.Replace(texto, "<[^>]+>", " ");
        texto = texto.Replace("\r", " ").Replace("\n", " ").Replace("\t", " ");
        while (texto.Contains("  "))
        {
            texto = texto.Replace("  ", " ");
        }
        return CorrigirAcentosQuebrados(texto.Trim());
    }

    private string CorrigirAcentosQuebrados(string valor)
    {
        if (String.IsNullOrEmpty(valor)) return "";
        if (valor.IndexOf('\u00c3') < 0 && valor.IndexOf('\u00c2') < 0) return valor;

        try
        {
            byte[] bytes = Encoding.GetEncoding("ISO-8859-1").GetBytes(valor);
            string corrigido = Encoding.UTF8.GetString(bytes);
            if (corrigido.IndexOf('\uFFFD') < 0) return corrigido;
        }
        catch
        {
        }

        return valor;
    }

    private DateTime DataHora(object valor)
    {
        if (valor == null || valor == DBNull.Value) return DateTime.MinValue;
        DateTime data;
        return DateTime.TryParse(Convert.ToString(valor), out data) ? data : DateTime.MinValue;
    }

    private string FormatarDataHora(object valor)
    {
        DateTime data = DataHora(valor);
        return data == DateTime.MinValue ? "N\u00e3o registrado" : data.ToString("dd/MM/yyyy HH:mm", CulturaBrasil);
    }

    private string FormatarData(object valor)
    {
        DateTime data = DataHora(valor);
        return data == DateTime.MinValue ? "" : data.ToString("dd/MM/yyyy", CulturaBrasil);
    }

    private bool UsuarioCIAutenticado()
    {
        return Session["ci_autenticado"] != null
            && Session["usuario"] != null
            && Convert.ToString(Session["usuario"]).Trim().Length > 0;
    }

    private void RedirecionarLoginCI()
    {
        string voltar = Request.RawUrl ?? "auditoria.aspx";
        if (voltar.StartsWith("/CI/", StringComparison.OrdinalIgnoreCase))
        {
            voltar = voltar.Substring(4);
        }

        Response.Redirect("login.aspx?voltar=" + HttpUtility.UrlEncode(voltar), false);
        Context.ApplicationInstance.CompleteRequest();
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

    private SqlParameter Param(string nome, SqlDbType tipo, object valor, int tamanho = 0)
    {
        SqlParameter parametro = tamanho > 0 ? new SqlParameter(nome, tipo, tamanho) : new SqlParameter(nome, tipo);
        parametro.Value = valor ?? DBNull.Value;
        return parametro;
    }

    private void RegistrarAuditoriaCI(string acao, int idCi, string codigoCi, string detalhe)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand("dbo.ci_auditoria_registrar", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = TimeoutSqlSegundos;
                cmd.Parameters.Add("@usuario_id", SqlDbType.NVarChar, 80).Value = ValorBanco(Convert.ToString(Session["id"] ?? ""));
                cmd.Parameters.Add("@usuario_nome", SqlDbType.NVarChar, 160).Value = ValorBanco(Convert.ToString(Session["usuario"] ?? ""));
                cmd.Parameters.Add("@usuario_tipo", SqlDbType.NVarChar, 80).Value = ValorBanco(Convert.ToString(Session["tipo"] ?? ""));
                cmd.Parameters.Add("@usuario_email", SqlDbType.NVarChar, 180).Value = ValorBanco(Convert.ToString(Session["email"] ?? ""));
                cmd.Parameters.Add("@empresa", SqlDbType.NVarChar, 120).Value = ValorBanco(Convert.ToString(Session["empresa"] ?? ""));
                cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 80).Value = ValorBanco(Request.UserHostAddress ?? "");
                cmd.Parameters.Add("@url", SqlDbType.NVarChar, 500).Value = ValorBanco(Request.RawUrl ?? "");
                cmd.Parameters.Add("@acao", SqlDbType.NVarChar, 80).Value = acao;
                cmd.Parameters.Add("@id_ci", SqlDbType.Int).Value = idCi;
                cmd.Parameters.Add("@codigo_ci", SqlDbType.NVarChar, 30).Value = ValorBanco(codigoCi);
                cmd.Parameters.Add("@detalhe", SqlDbType.NVarChar).Value = ValorBanco(detalhe);
                cmd.Parameters.Add("@dados_antes", SqlDbType.NVarChar).Value = DBNull.Value;
                cmd.Parameters.Add("@dados_depois", SqlDbType.NVarChar).Value = DBNull.Value;
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
        }
    }

    private object ValorBanco(string valor)
    {
        string texto = (valor ?? "").Trim();
        return texto.Length == 0 ? (object)DBNull.Value : texto;
    }

    private void MostrarErro(string mensagem)
    {
        pnlMensagem.Visible = true;
        pnlConteudo.Visible = false;
        litMensagem.Text = Server.HtmlEncode(mensagem);
    }
}
