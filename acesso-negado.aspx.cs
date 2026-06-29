using System;
using System.Web;

public partial class acesso_negado : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string recurso = Convert.ToString(Request.QueryString["recurso"]);
        string voltar = Convert.ToString(Request.QueryString["voltar"]);

        litRecurso.Text = Server.HtmlEncode(String.IsNullOrWhiteSpace(recurso) ? "Recurso n\u00e3o informado" : recurso);
        lnkVoltar.NavigateUrl = UrlSegura(voltar);
    }

    private string UrlSegura(string url)
    {
        if (String.IsNullOrWhiteSpace(url))
        {
            return "/Default.aspx";
        }

        url = HttpUtility.UrlDecode(url).Trim();
        if (!url.StartsWith("/", StringComparison.Ordinal) || url.StartsWith("//", StringComparison.Ordinal))
        {
            return "/Default.aspx";
        }

        if (url.IndexOf("acesso-negado.aspx", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return "/Default.aspx";
        }

        return url;
    }
}
