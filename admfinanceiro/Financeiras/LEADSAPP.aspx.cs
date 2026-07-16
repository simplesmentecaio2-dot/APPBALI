using System;
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

        GridView1.Visible = true;
        GridView1.AllowPaging = false;
        GridView1.DataBind();
        ExportGridToExcel(GridView1, "BYDST");
    }

    protected void GridView1_DataBound(object sender, EventArgs e)
    {
        AtualizarResumo();
    }

    public void ExportGridToExcel(GridView grdGridView, string fileName)
    {
        Response.Clear();
        Response.Buffer = true;
        Response.ContentEncoding = Encoding.UTF8;
        Response.Charset = "utf-8";
        Response.AddHeader("content-disposition", String.Format("attachment;filename={0}.xls", fileName));
        Response.ContentType = "application/vnd.ms-excel";
        Response.Write("\uFEFF");

        using (StringWriter stringWrite = new StringWriter(CulturaBr))
        using (HtmlTextWriter htmlWrite = new HtmlTextWriter(stringWrite))
        {
            grdGridView.RenderControl(htmlWrite);
            Response.Write(stringWrite.ToString());
        }

        Response.End();
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
}
