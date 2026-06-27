using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI.WebControls;

public partial class contrato_auditoria : System.Web.UI.Page
{
    private const int TimeoutSqlSegundos = 60;
    private static readonly CultureInfo CulturaBrasil = new CultureInfo("pt-BR");

    public string TituloPagina = "Auditoria do contrato";
    public string ClasseMarca = "contrato-fiat";

    private string AppConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["APPConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        MarcaInfo marca = ObterMarca();
        if (!UsuarioAutenticado())
        {
            Response.Redirect(marca.LoginUrl, false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        if (!IsPostBack)
        {
            CarregarAuditoria(marca);
        }
    }

    protected void gvAuditoria_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;

        int limite = Math.Min(gvAuditoria.Columns.Count, e.Row.Cells.Count);
        for (int i = 0; i < limite; i++)
        {
            e.Row.Cells[i].Attributes["data-label"] = Server.HtmlDecode(gvAuditoria.Columns[i].HeaderText);
        }

        if (e.Row.Cells.Count > 1)
        {
            string origem = Server.HtmlEncode(Server.HtmlDecode(e.Row.Cells[1].Text));
            e.Row.Cells[1].Text = "<span class=\"contract-audit-source\">" + origem + "</span>";
        }
    }

    private void CarregarAuditoria(MarcaInfo marca)
    {
        string contrato = (Request.QueryString["contrato"] ?? "").Trim();
        string tipoInformado = NormalizarTipo(Request.QueryString["tipo"]);

        if (contrato.Length == 0 || !Regex.IsMatch(contrato, @"^\d{1,12}$"))
        {
            MostrarErro("Informe um contrato v\u00e1lido para consultar a auditoria.");
            return;
        }

        DataTable dadosContrato = ObterContratoAtual(marca, contrato);
        if (dadosContrato.Rows.Count == 0)
        {
            MostrarErro("Contrato " + Server.HtmlEncode(contrato) + " n\u00e3o encontrado na base " + Server.HtmlEncode(marca.Nome) + ".");
            return;
        }

        DataRow atual = dadosContrato.Rows[0];
        string tipo = NormalizarTipo(Convert.ToString(atual["tipo"]));
        if (tipoInformado.Length > 0) tipo = tipoInformado;

        ClasseMarca = marca.ClasseCss;
        TituloPagina = "Auditoria contrato " + contrato;
        litTitulo.Text = Server.HtmlEncode("Logs do contrato " + contrato);
        litSubtitulo.Text = Server.HtmlEncode("Auditoria completa do contrato " + contrato + " - " + marca.Nome + ".");
        litContrato.Text = Server.HtmlEncode(contrato);
        litMarca.Text = Server.HtmlEncode(marca.Nome);
        litTipo.Text = Server.HtmlEncode(NomeTipo(tipo));
        lnkVoltar.NavigateUrl = marca.ContratoUrl;
        lnkImprimir.NavigateUrl = UrlImpressao(marca, tipo, contrato);
        litDadosContrato.Text = MontarDadosAtuais(atual);

        DataTable timeline = MontarTimeline(marca, contrato, tipo, atual);
        gvAuditoria.DataSource = timeline;
        gvAuditoria.DataBind();

        litEventos.Text = timeline.Rows.Count.ToString(CulturaBrasil);
        litResumoTimeline.Text = timeline.Rows.Count == 0
            ? "Nenhuma ocorr\u00eancia foi localizada para este contrato."
            : "Exibindo " + timeline.Rows.Count.ToString(CulturaBrasil) + " evento(s) em ordem cronol\u00f3gica.";

        pnlConteudo.Visible = true;
        RegistrarAcesso(marca, contrato, tipo);
    }

    private DataTable ObterContratoAtual(MarcaInfo marca, string contrato)
    {
        using (SqlConnection con = new SqlConnection(AppConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 1
                id,
                [data],
                ISNULL(tipo, '') AS tipo,
                ISNULL(cliente, '') AS cliente,
                ISNULL(cpfcnpj, '') AS cpfcnpj,
                ISNULL(RGIE, '') AS RGIE,
                ISNULL(tel_celular, '') AS tel_celular,
                ISNULL(email, '') AS email,
                ISNULL(marca, '') AS marca_veiculo,
                ISNULL(modelo, '') AS modelo,
                ISNULL(chassiplaca, '') AS chassiplaca,
                ISNULL(vendedor, '') AS vendedor,
                ISNULL(valorveiculo, 0) AS valorveiculo,
                ISNULL(entrada, 0) AS entrada,
                ISNULL(modalidade_pagamento, '') AS modalidade_pagamento
            FROM " + marca.Tabela + @"
            WHERE CONVERT(VARCHAR(40), id) = @contrato;", con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = TimeoutSqlSegundos;
            cmd.Parameters.Add("@contrato", SqlDbType.VarChar, 40).Value = contrato;
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    private DataTable MontarTimeline(MarcaInfo marca, string contrato, string tipo, DataRow atual)
    {
        DataTable timeline = CriarTabelaTimeline();
        AdicionarLinha(timeline,
            DataHora(atual["data"]),
            "Contrato",
            "Contrato cadastrado",
            Convert.ToString(atual["vendedor"]),
            "Registro atual encontrado na tabela de contratos.",
            "",
            ResumoContrato(atual),
            "",
            1);

        HashSet<string> chavesBanco = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        DataTable banco = ContratoAuditoria.Listar(marca.Nome, contrato, tipo);
        foreach (DataRow row in banco.Rows)
        {
            string acao = Convert.ToString(row["acao"]);
            string detalhe = Convert.ToString(row["detalhe"]);
            chavesBanco.Add(ChaveEvento(acao, detalhe));
            AdicionarLinha(timeline,
                DataHora(row["dt_evento"]),
                "Banco",
                NomeAcao(acao),
                UsuarioAuditoria(row),
                detalhe,
                Convert.ToString(row["dados_antes"]),
                Convert.ToString(row["dados_depois"]),
                Convert.ToString(row["ip"]),
                2);
        }

        foreach (ContratoLogLegado legado in LerLogsLegados(marca.Nome, contrato))
        {
            if (chavesBanco.Contains(ChaveEvento(legado.Acao, legado.Detalhe))) continue;
            AdicionarLinha(timeline,
                legado.Data,
                "Legado",
                NomeAcao(legado.Acao),
                legado.Usuario,
                legado.Detalhe,
                "",
                "",
                ExtrairIp(legado.Detalhe),
                3);
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
        tabela.Columns.Add("origem", typeof(string));
        tabela.Columns.Add("acao", typeof(string));
        tabela.Columns.Add("usuario", typeof(string));
        tabela.Columns.Add("detalhe", typeof(string));
        tabela.Columns.Add("antes", typeof(string));
        tabela.Columns.Add("depois", typeof(string));
        tabela.Columns.Add("ip", typeof(string));
        return tabela;
    }

    private void AdicionarLinha(DataTable tabela, DateTime data, string origem, string acao, string usuario, string detalhe, string antes, string depois, string ip, int prioridade)
    {
        DataRow row = tabela.NewRow();
        row["dt_ordem"] = data == DateTime.MinValue ? DateTime.Now : data;
        row["prioridade"] = prioridade;
        row["data_hora"] = data == DateTime.MinValue ? "" : data.ToString("dd/MM/yyyy HH:mm:ss", CulturaBrasil);
        row["origem"] = TextoTabela(origem);
        row["acao"] = TextoTabela(acao);
        row["usuario"] = TextoTabela(String.IsNullOrWhiteSpace(usuario) ? "N\u00e3o informado" : usuario);
        row["detalhe"] = TextoTabela(detalhe);
        row["antes"] = TextoTabela(antes);
        row["depois"] = TextoTabela(depois);
        row["ip"] = TextoTabela(ip);
        tabela.Rows.Add(row);
    }

    private string MontarDadosAtuais(DataRow row)
    {
        StringBuilder html = new StringBuilder();
        html.Append("<dl>");
        ItemDados(html, "Data", FormatarData(row["data"]));
        ItemDados(html, "Cliente", row["cliente"]);
        ItemDados(html, "CPF/CNPJ", row["cpfcnpj"]);
        ItemDados(html, "Ve\u00edculo", Convert.ToString(row["marca_veiculo"]) + " " + Convert.ToString(row["modelo"]));
        ItemDados(html, "Chassi/placa", row["chassiplaca"]);
        ItemDados(html, "Vendedor", row["vendedor"]);
        ItemDados(html, "Valor", FormatarMoeda(row["valorveiculo"]));
        ItemDados(html, "Entrada", FormatarMoeda(row["entrada"]));
        ItemDados(html, "Pagamento", NomePagamento(Convert.ToString(row["modalidade_pagamento"])));
        ItemDados(html, "Contato", Convert.ToString(row["tel_celular"]) + " " + Convert.ToString(row["email"]));
        html.Append("</dl>");
        return html.ToString();
    }

    private void ItemDados(StringBuilder html, string titulo, object valor)
    {
        html.Append("<div><dt>")
            .Append(Server.HtmlEncode(titulo))
            .Append("</dt><dd>")
            .Append(Server.HtmlEncode(Convert.ToString(valor ?? "")))
            .Append("</dd></div>");
    }

    private string ResumoContrato(DataRow row)
    {
        return "Cliente=" + Convert.ToString(row["cliente"])
            + "; CPF/CNPJ=" + Convert.ToString(row["cpfcnpj"])
            + "; Modelo=" + Convert.ToString(row["modelo"])
            + "; Chassi/Placa=" + Convert.ToString(row["chassiplaca"])
            + "; Vendedor=" + Convert.ToString(row["vendedor"])
            + "; Valor=" + FormatarMoeda(row["valorveiculo"]);
    }

    private List<ContratoLogLegado> LerLogsLegados(string marca, string contrato)
    {
        List<ContratoLogLegado> logs = new List<ContratoLogLegado>();
        string caminho = Server.MapPath("~/App_Data/contrato-operacoes.log");
        if (!File.Exists(caminho)) return logs;

        string[] linhas = File.ReadAllLines(caminho, Encoding.UTF8);
        foreach (string linha in linhas)
        {
            string[] partes = (linha ?? "").Split('\t');
            if (partes.Length < 5) continue;
            if (!String.Equals(partes[1].Trim(), marca, StringComparison.OrdinalIgnoreCase)) continue;
            if (!String.Equals(ContratoAuditoria.ExtrairCampoDetalhe(partes[4], "Contrato"), contrato, StringComparison.OrdinalIgnoreCase)) continue;

            DateTime data;
            DateTime.TryParseExact(partes[0].Trim(), "yyyy-MM-dd HH:mm:ss", CulturaBrasil, DateTimeStyles.None, out data);
            logs.Add(new ContratoLogLegado
            {
                Data = data,
                Usuario = partes[2].Trim(),
                Acao = partes[3].Trim(),
                Detalhe = partes[4].Trim()
            });
        }

        return logs;
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
            case "GRAVACAO_SUCESSO": return "Contrato gravado";
            case "ERRO_GRAVACAO": return "Erro ao gravar";
            case "DUPLICIDADE_CONFIRMADA": return "Duplicidade confirmada";
            case "DUPLICIDADE_BLOQUEADA_PROCEDURE": return "Duplicidade bloqueada";
            case "VALIDACAO_NOVO": return "Valida\u00e7\u00e3o do novo contrato";
            case "VALIDACAO_NOVO_VALOR": return "Valida\u00e7\u00e3o de valores";
            case "CHECKLIST_NOVO": return "Checklist do novo contrato";
            case "CONTRATO_EDICAO_NAO_ENCONTRADO": return "Edi\u00e7\u00e3o n\u00e3o encontrada";
            case "ABRIR_EDICAO": return "Edi\u00e7\u00e3o aberta";
            case "EDICAO_ALTERACOES": return "Campos editados";
            case "EDICAO_SEM_ALTERACAO": return "Edi\u00e7\u00e3o sem altera\u00e7\u00e3o";
            case "EDICAO_SUCESSO": return "Contrato alterado";
            case "ERRO_EDICAO": return "Erro ao editar";
            case "CHECKLIST_EDICAO": return "Checklist da edi\u00e7\u00e3o";
            case "IMPRIMIR_CONTRATO": return "Impress\u00e3o aberta";
            case "ABRIR_LOG_CONTRATO": return "Log consultado";
            default: return (acao ?? "").Replace("_", " ");
        }
    }

    private void RegistrarAcesso(MarcaInfo marca, string contrato, string tipo)
    {
        ContratoAuditoria.Registrar(
            marca.Nome,
            tipo,
            contrato,
            Convert.ToString(Session["id"] ?? ""),
            Convert.ToString(Session["usuario"] ?? ""),
            Request.UserHostAddress ?? "",
            Request.RawUrl ?? "",
            "ABRIR_LOG_CONTRATO",
            "Contrato=" + contrato + "; Tipo=" + tipo + "; Marca=" + marca.Nome,
            "",
            "");
    }

    private MarcaInfo ObterMarca()
    {
        string marca = (Request.QueryString["marca"] ?? "Fiat").Trim().ToLowerInvariant();
        if (marca == "jeep")
        {
            return new MarcaInfo("Jeep", "APP.dbo.veiculos_contrato_vendaJEEP", "contrato-jeep", "/jeep/contrato.aspx", "/jeep/loginAppcontrato.aspx", "/img/logojeep.png");
        }
        if (marca == "byd")
        {
            return new MarcaInfo("BYD", "APP.dbo.veiculos_contrato_vendaBYD", "contrato-byd", "/byd/contrato.aspx", "/byd/loginAppcontrato.aspx", "/img/BYD.png");
        }

        return new MarcaInfo("Fiat", "APP.dbo.veiculos_contrato_venda", "contrato-fiat", "/veiculos/contrato.aspx", "/veiculos/loginAppcontrato.aspx", "/img/logobali.png");
    }

    private string UrlImpressao(MarcaInfo marca, string tipo, string contrato)
    {
        string pasta = marca.Nome == "Fiat" ? "/veiculos/" : "/" + marca.Nome.ToLowerInvariant() + "/";
        string pagina;
        if (marca.Nome == "Jeep")
        {
            pagina = tipo == "VU" ? "Print-ContratoVUJEEP.aspx" : "Print-ContratoVNJEEP.aspx";
        }
        else if (marca.Nome == "BYD")
        {
            pagina = tipo == "VU" ? "Print-ContratoVUBYD.aspx" : "Print-ContratoVNBYD.aspx";
        }
        else
        {
            pagina = tipo == "VU" ? "Print-ContratoVU.aspx" : (tipo == "VD" ? "Print-ContratoVD.aspx" : "Print-ContratoVN.aspx");
        }

        return pasta + pagina + "?contrato=" + HttpUtility.UrlEncode(contrato);
    }

    private bool UsuarioAutenticado()
    {
        return Session["usuario"] != null && Convert.ToString(Session["usuario"]).Trim().Length > 0;
    }

    private DateTime DataHora(object valor)
    {
        if (valor == null || valor == DBNull.Value) return DateTime.MinValue;
        DateTime data;
        return DateTime.TryParse(Convert.ToString(valor), out data) ? data : DateTime.MinValue;
    }

    private string FormatarData(object valor)
    {
        DateTime data = DataHora(valor);
        return data == DateTime.MinValue ? "" : data.ToString("dd/MM/yyyy", CulturaBrasil);
    }

    private string FormatarMoeda(object valor)
    {
        decimal numero;
        if (!Decimal.TryParse(Convert.ToString(valor), NumberStyles.Any, CultureInfo.InvariantCulture, out numero))
        {
            Decimal.TryParse(Convert.ToString(valor), NumberStyles.Any, CulturaBrasil, out numero);
        }

        return numero.ToString("C2", CulturaBrasil);
    }

    private string NomeTipo(string tipo)
    {
        tipo = NormalizarTipo(tipo);
        if (tipo == "VN") return "Novo";
        if (tipo == "VU") return "Usado";
        if (tipo == "VD") return "Venda direta";
        return "N\u00e3o informado";
    }

    private string NormalizarTipo(string tipo)
    {
        return (tipo ?? "").Trim().ToUpperInvariant();
    }

    private string NomePagamento(string valor)
    {
        valor = (valor ?? "").Trim().ToUpperInvariant();
        if (valor == "A") return "\u00c0 vista";
        if (valor == "F") return "Financiamento";
        return valor.Length == 0 ? "N\u00e3o informado" : valor;
    }

    private string TextoTabela(string valor)
    {
        string texto = HttpUtility.HtmlDecode(valor ?? "");
        texto = texto.Replace("\r", " ").Replace("\n", " ").Replace("\t", " ");
        while (texto.Contains("  "))
        {
            texto = texto.Replace("  ", " ");
        }

        texto = texto.Trim();
        return texto.Length > 1200 ? texto.Substring(0, 1200) + "...(truncado)" : texto;
    }

    private string ChaveEvento(string acao, string detalhe)
    {
        return ((acao ?? "").Trim() + "|" + (detalhe ?? "").Trim()).ToUpperInvariant();
    }

    private string ExtrairIp(string detalhe)
    {
        return ContratoAuditoria.ExtrairCampoDetalhe(detalhe, "IP");
    }

    private void MostrarErro(string mensagem)
    {
        pnlMensagem.Visible = true;
        pnlConteudo.Visible = false;
        litMensagem.Text = Server.HtmlEncode(mensagem);
    }

    private class MarcaInfo
    {
        public MarcaInfo(string nome, string tabela, string classeCss, string contratoUrl, string loginUrl, string logoUrl)
        {
            Nome = nome;
            Tabela = tabela;
            ClasseCss = classeCss;
            ContratoUrl = contratoUrl;
            LoginUrl = loginUrl;
            LogoUrl = logoUrl;
        }

        public string Nome { get; private set; }
        public string Tabela { get; private set; }
        public string ClasseCss { get; private set; }
        public string ContratoUrl { get; private set; }
        public string LoginUrl { get; private set; }
        public string LogoUrl { get; private set; }
    }

    private class ContratoLogLegado
    {
        public DateTime Data { get; set; }
        public string Usuario { get; set; }
        public string Acao { get; set; }
        public string Detalhe { get; set; }
    }
}
