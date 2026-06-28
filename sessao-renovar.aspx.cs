using System;
using System.Web;

public partial class sessao_renovar : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "application/json; charset=utf-8";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();

        if (Session["usuario"] == null || Convert.ToString(Session["usuario"]).Trim().Length == 0)
        {
            Response.StatusCode = 401;
            Response.Write("{\"ok\":false,\"message\":\"sessao_expirada\"}");
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        Session["sessao_timer_renovado_em"] = DateTime.Now;
        int timeoutSegundos = (Session.Timeout > 0 ? Session.Timeout : 15) * 60;

        Response.Write("{\"ok\":true,\"timeoutSeconds\":" + timeoutSegundos.ToString(System.Globalization.CultureInfo.InvariantCulture) + "}");
        Context.ApplicationInstance.CompleteRequest();
    }
}
