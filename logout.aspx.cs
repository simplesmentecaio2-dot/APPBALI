using System;
using System.Web;

public partial class logout : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string voltar = Request.QueryString["voltar"];
        if (!UrlLocalSegura(voltar))
        {
            voltar = "/login.aspx";
        }

        try
        {
            Session.Clear();
            Session.Abandon();

            HttpCookie sessionCookie = new HttpCookie("ASP.NET_SessionId", "");
            sessionCookie.Expires = DateTime.Now.AddDays(-1);
            sessionCookie.Path = "/";
            Response.Cookies.Add(sessionCookie);
        }
        catch
        {
        }

        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.Redirect(voltar, false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private bool UrlLocalSegura(string url)
    {
        if (String.IsNullOrWhiteSpace(url)) return false;

        url = url.Trim();
        if (url.StartsWith("http:", StringComparison.OrdinalIgnoreCase)) return false;
        if (url.StartsWith("https:", StringComparison.OrdinalIgnoreCase)) return false;
        if (url.StartsWith("//")) return false;
        if (url.IndexOf('\r') >= 0 || url.IndexOf('\n') >= 0) return false;

        return url.StartsWith("/", StringComparison.Ordinal)
            || url.StartsWith("./", StringComparison.Ordinal)
            || url.StartsWith("../", StringComparison.Ordinal);
    }
}
