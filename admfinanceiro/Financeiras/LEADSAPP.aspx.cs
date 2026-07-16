using System;
using System.Collections;
using System.Data;
using System.Globalization;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class admfinanceiro_Financeiras_Financeiras : System.Web.UI.Page
{
    private static readonly CultureInfo CulturaBr = new CultureInfo("pt-BR");

    protected void Page_Load(object sender, EventArgs e)
    {
        lblUsuario.Text = Session["usuario"] == null ? "-" : Convert.ToString(Session["usuario"]);
        lblTipo.Text = Session["usuario_codigo"] == null
            ? (Session["tipo"] == null ? "-" : Convert.ToString(Session["tipo"]))
            : Convert.ToString(Session["usuario_codigo"]);

        if (!IsPostBack)
        {
            DateTime hoje = DateTime.Today;
            txtDtInicial.Text = new DateTime(hoje.Year, hoje.Month, 1).ToString("yyyy-MM-dd");
            txtDtFinal.Text = hoje.ToString("yyyy-MM-dd");
            GridView1.Visible = false;
            AtualizarResumo();
        }
    }

    protected void GerarArquivo_Click(object sender, EventArgs e)
    {
        if (!PeriodoValido()) return;

        GridView1.PageIndex = 0;
        GridView1.Visible = true;
        GridView1.DataBind();
        AtualizarResumo();
    }

    protected void BtnExcel_Click(object sender, EventArgs e)
    {
        if (!PeriodoValido()) return;

        AtualizarResumo();
        DataTable dados = ObterDadosExportacao();
        ExportarTabelaPremium(dados, "BYDST");
    }

    protected void GridView1_DataBound(object sender, EventArgs e)
    {
        AtualizarResumo();
    }

    public void ExportGridToExcel(GridView grdGridView, string fileName)
    {
        ExportarTabelaPremium(ObterDadosExportacao(), fileName);
    }

    public override void VerifyRenderingInServerForm(Control control)
    {
        return;
    }

    private bool PeriodoValido()
    {
        DateTime inicio;
        DateTime fim;

        if (!LerData(txtDtInicial.Text, out inicio) || !LerData(txtDtFinal.Text, out fim))
        {
            MostrarMensagem("Informe data inicial e data final v\u00e1lidas.");
            return false;
        }

        if (inicio > fim)
        {
            MostrarMensagem("A data inicial n\u00e3o pode ser maior que a data final.");
            return false;
        }

        txtDtInicial.Text = inicio.ToString("yyyy-MM-dd");
        txtDtFinal.Text = fim.ToString("yyyy-MM-dd");
        MostrarMensagem("");
        return true;
    }

    private bool LerData(string valor, out DateTime data)
    {
        string texto = (valor ?? "").Trim();
        string[] formatos = { "yyyy-MM-dd", "dd/MM/yyyy", "d/M/yyyy" };
        return DateTime.TryParseExact(texto, formatos, CulturaBr, DateTimeStyles.None, out data)
            || DateTime.TryParse(texto, CulturaBr, DateTimeStyles.None, out data);
    }

    private void AtualizarResumo()
    {
        lblTotalRegistros.Text = GridView1 == null ? "0" : GridView1.Rows.Count.ToString("N0", CulturaBr);

        DateTime inicio;
        DateTime fim;
        if (LerData(txtDtInicial.Text, out inicio) && LerData(txtDtFinal.Text, out fim))
        {
            lblResumoPeriodo.Text = inicio.ToString("dd/MM/yyyy") + " a " + fim.ToString("dd/MM/yyyy");
        }
        else
        {
            lblResumoPeriodo.Text = "-";
        }

        lblUltimaAtualizacao.Text = DateTime.Now.ToString("dd/MM/yyyy HH:mm", CulturaBr);
    }

    private void MostrarMensagem(string texto)
    {
        lblMensagem.Text = HttpUtility.HtmlEncode(texto ?? "");
        lblMensagem.Style["display"] = String.IsNullOrWhiteSpace(texto) ? "none" : "block";
    }

    private DataTable ObterDadosExportacao()
    {
        IEnumerable resultado = SqlDsTalison.Select(DataSourceSelectArguments.Empty);
        DataView view = resultado as DataView;
        if (view != null) return view.ToTable();

        DataTable tabela = new DataTable("RelatorioFiscal");
        if (resultado == null) return tabela;

        foreach (object item in resultado)
        {
            DataRowView rowView = item as DataRowView;
            if (rowView == null) continue;
            if (tabela.Columns.Count == 0)
            {
                foreach (DataColumn coluna in rowView.Row.Table.Columns)
                {
                    tabela.Columns.Add(coluna.ColumnName, coluna.DataType);
                }
            }

            DataRow novaLinha = tabela.NewRow();
            foreach (DataColumn coluna in rowView.Row.Table.Columns)
            {
                novaLinha[coluna.ColumnName] = rowView.Row[coluna.ColumnName];
            }
            tabela.Rows.Add(novaLinha);
        }

        return tabela;
    }

    private void ExportarTabelaPremium(DataTable tabela, string fileName)
    {
        string nomeArquivo = String.Format("{0}_{1}.xls", LimparNomeArquivo(fileName), DateTime.Now.ToString("yyyyMMdd_HHmm"));
        StringBuilder html = new StringBuilder();
        int colunas = Math.Max(1, tabela == null ? 1 : tabela.Columns.Count);

        html.Append("<html><head><meta charset=\"utf-8\" />");
        html.Append("<style>");
        html.Append("body{font-family:Arial,Helvetica,sans-serif;color:#172033;background:#ffffff;}");
        html.Append("table{border-collapse:collapse;width:100%;}");
        html.Append(".title{background:#172033;color:#ffffff;font-size:22px;font-weight:800;text-align:left;padding:16px 18px;}");
        html.Append(".subtitle{background:#edf3fb;color:#334155;font-size:12px;font-weight:700;padding:8px 18px;}");
        html.Append(".meta td{background:#f8fafc;color:#475569;border:1px solid #d8e2ef;font-size:11px;font-weight:700;padding:7px 9px;}");
        html.Append(".meta strong{color:#172033;}");
        html.Append("th{background:#263b5e;color:#ffffff;border:1px solid #1b2d49;font-size:11px;font-weight:800;padding:8px 9px;text-align:left;white-space:nowrap;}");
        html.Append("td{border:1px solid #d8e2ef;font-size:11px;padding:7px 9px;vertical-align:top;}");
        html.Append(".row-alt td{background:#f8fbff;}");
        html.Append(".num{text-align:right;mso-number-format:'#,##0.00';}");
        html.Append(".text{mso-number-format:'\\@';}");
        html.Append(".footer{background:#f8fafc;color:#64748b;font-size:10px;font-weight:700;padding:9px;border:1px solid #d8e2ef;}");
        html.Append("</style></head><body>");
        html.Append("<table>");
        html.Append("<tr><td class=\"title\" colspan=\"").Append(colunas).Append("\">GRUPO BALI - Relat&oacute;rio fiscal de notas e tributos</td></tr>");
        html.Append("<tr><td class=\"subtitle\" colspan=\"").Append(colunas).Append("\">Arquivo gerado pelo Adm. Financeiro &middot; Conferir per&iacute;odo e dados antes de uso externo.</td></tr>");
        html.Append("</table>");

        html.Append("<table class=\"meta\" style=\"margin-top:10px;margin-bottom:14px;\">");
        html.Append("<tr>");
        html.Append("<td><strong>Per&iacute;odo:</strong> ").Append(Html(lblResumoPeriodo.Text)).Append("</td>");
        html.Append("<td><strong>Gerado em:</strong> ").Append(DateTime.Now.ToString("dd/MM/yyyy HH:mm", CulturaBr)).Append("</td>");
        html.Append("<td><strong>Usu&aacute;rio:</strong> ").Append(Html(lblUsuario.Text)).Append("</td>");
        html.Append("<td><strong>Total de linhas:</strong> ").Append((tabela == null ? 0 : tabela.Rows.Count).ToString("N0", CulturaBr)).Append("</td>");
        html.Append("</tr>");
        html.Append("</table>");

        html.Append("<table>");
        if (tabela == null || tabela.Columns.Count == 0)
        {
            html.Append("<tr><th>Resultado</th></tr>");
            html.Append("<tr><td>Nenhum registro encontrado para o per&iacute;odo informado.</td></tr>");
        }
        else
        {
            html.Append("<tr>");
            foreach (DataColumn coluna in tabela.Columns)
            {
                html.Append("<th>").Append(Html(NomeColunaExcel(coluna.ColumnName))).Append("</th>");
            }
            html.Append("</tr>");

            for (int i = 0; i < tabela.Rows.Count; i++)
            {
                DataRow row = tabela.Rows[i];
                html.Append("<tr");
                if (i % 2 == 1) html.Append(" class=\"row-alt\"");
                html.Append(">");

                foreach (DataColumn coluna in tabela.Columns)
                {
                    string css = ColunaNumerica(coluna) ? "num" : "text";
                    html.Append("<td class=\"").Append(css).Append("\">")
                        .Append(Html(FormatarValorExcel(row[coluna], coluna)))
                        .Append("</td>");
                }

                html.Append("</tr>");
            }
        }

        html.Append("</table>");
        html.Append("<table style=\"margin-top:12px;\"><tr><td class=\"footer\" colspan=\"").Append(colunas).Append("\">TI - GRUPO BALI</td></tr></table>");
        html.Append("</body></html>");

        Response.Clear();
        Response.Buffer = true;
        Response.ContentEncoding = Encoding.UTF8;
        Response.Charset = "utf-8";
        Response.AddHeader("content-disposition", "attachment;filename=" + nomeArquivo);
        Response.ContentType = "application/vnd.ms-excel";
        Response.Write("\uFEFF");
        Response.Write(html.ToString());
        Response.Flush();
        Response.End();
    }

    private string NomeColunaExcel(string coluna)
    {
        switch (coluna)
        {
            case "notafiscal_numero": return "Nota fiscal";
            case "NotaFiscal_DataEmissao": return "Data de emiss\u00e3o";
            case "NotaFiscal_DataMovimento": return "Data de movimento";
            case "Estabelecimento_Nome": return "Loja";
            case "CNPJ Forcenedor": return "CNPJ fornecedor";
            case "Natureza Op": return "Natureza da opera\u00e7\u00e3o";
            case "Item da NF": return "Item da NF";
            case "Cod do Prod. no WF": return "C\u00f3digo do produto no WF";
            case "Referencia": return "Refer\u00eancia";
            case "Valor Unitario": return "Valor unit\u00e1rio";
            case "Valor Total": return "Valor total";
            case "Procedencia": return "Proced\u00eancia";
            case "ValorBaseICMS": return "Base ICMS";
            case "ValorICMS": return "Valor ICMS";
            case "aliquotaicmsnf": return "Al\u00edquota ICMS";
            case "ValorBaseICMSST": return "Base ICMS ST";
            case "ValorICMSST": return "Valor ICMS ST";
            case "AliquotaICMSST": return "Al\u00edquota ICMS ST";
            case "ValorBaseIPI": return "Base IPI";
            case "ValorIPI": return "Valor IPI";
            case "AliquotaIPI": return "Al\u00edquota IPI";
            case "ValorBasePIS": return "Base PIS";
            case "ValorPIS": return "Valor PIS";
            case "AliquotaPIS": return "Al\u00edquota PIS";
            case "ValorBasePISRetido": return "Base PIS retido";
            case "ValorPISRetido": return "Valor PIS retido";
            case "AliquotaPISRetido": return "Al\u00edquota PIS retido";
            case "ValorBaseIRRF": return "Base IRRF";
            case "ValorIRRF": return "Valor IRRF";
            case "AliquotaIRRF": return "Al\u00edquota IRRF";
            case "ValorBaseCSLL": return "Base CSLL";
            case "ValorCSLL": return "Valor CSLL";
            case "AliquotaCSLL": return "Al\u00edquota CSLL";
            default: return coluna.Replace("_", " ");
        }
    }

    private string FormatarValorExcel(object valor, DataColumn coluna)
    {
        if (valor == null || valor == DBNull.Value) return "";

        DateTime data;
        if (valor is DateTime) return ((DateTime)valor).ToString("dd/MM/yyyy", CulturaBr);
        if (DateTime.TryParse(Convert.ToString(valor), CulturaBr, DateTimeStyles.None, out data)
            && coluna.ColumnName.IndexOf("Data", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return data.ToString("dd/MM/yyyy", CulturaBr);
        }

        decimal numero;
        if (ColunaNumerica(coluna)
            && Decimal.TryParse(Convert.ToString(valor), NumberStyles.Any, CulturaBr, out numero))
        {
            return numero.ToString("N2", CulturaBr);
        }

        return Convert.ToString(valor);
    }

    private bool ColunaNumerica(DataColumn coluna)
    {
        string nome = coluna.ColumnName.ToUpperInvariant();
        return nome.Contains("VALOR")
            || nome.Contains("ALIQUOTA")
            || nome == "QTDE";
    }

    private string LimparNomeArquivo(string nome)
    {
        string texto = String.IsNullOrWhiteSpace(nome) ? "relatorio" : nome.Trim();
        foreach (char c in Path.GetInvalidFileNameChars())
        {
            texto = texto.Replace(c, '_');
        }
        return texto;
    }

    private string Html(string valor)
    {
        return HttpUtility.HtmlEncode(valor ?? "");
    }
}
