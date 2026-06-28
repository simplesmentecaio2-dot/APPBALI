<%@ Application Language="C#" %>

<script runat="server">
    private const int TempoSessaoMinutos = 15;

    void Application_PreRequestHandlerExecute(object sender, EventArgs e)
    {
        try
        {
            if (Context == null || Session == null) return;
            if (DeveIgnorarTimerSessao()) return;
            if (Session["usuario"] == null || Convert.ToString(Session["usuario"]).Trim().Length == 0) return;

            Session.Timeout = TempoSessaoMinutos;

            System.Web.UI.Page pagina = Context.CurrentHandler as System.Web.UI.Page;
            if (pagina == null) return;

            pagina.PreRenderComplete += RegistrarTimerSessao;
        }
        catch
        {
        }
    }

    void Application_AcquireRequestState(object sender, EventArgs e)
    {
        if (Context == null || Session == null) return;
        if (SessaoUnica.DeveIgnorarValidacao(Context)) return;
        if (Session["usuario"] == null || Convert.ToString(Session["usuario"]).Trim().Length == 0) return;

        Session.Timeout = TempoSessaoMinutos;

        if (SessaoUnica.ValidarSessaoAtual(Context))
        {
            return;
        }

        string destino = SessaoUnica.UrlLoginSessaoEncerrada(Context);

        try
        {
            Session.Clear();
            Session.Abandon();
        }
        catch
        {
        }

        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.Redirect(destino, false);
        Context.ApplicationInstance.CompleteRequest();
    }

    void Application_Error(object sender, EventArgs e)
    {
        Exception erro = Server.GetLastError();
        if (!EhErroDeViewState(erro) || !EhPaginaProtegidaContraViewState())
        {
            return;
        }

        Server.ClearError();

        string destino = Request.Url.AbsolutePath + Request.Url.Query;
        destino += destino.IndexOf("?", StringComparison.Ordinal) >= 0 ? "&" : "?";
        destino += "viewstate=expired";

        Response.Redirect(destino, false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private bool EhErroDeViewState(Exception erro)
    {
        for (Exception atual = erro; atual != null; atual = atual.InnerException)
        {
            string tipo = atual.GetType().FullName ?? "";
            string mensagem = atual.Message ?? "";
            if (tipo.IndexOf("ViewStateException", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return true;
            }

            if (mensagem.IndexOf("MAC de estado de exibi", StringComparison.OrdinalIgnoreCase) >= 0 ||
                mensagem.IndexOf("Validation of viewstate MAC failed", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return true;
            }
        }

        return false;
    }

    private bool EhPaginaProtegidaContraViewState()
    {
        string caminho = Request.AppRelativeCurrentExecutionFilePath ?? "";
        return caminho.StartsWith("~/CI/", StringComparison.OrdinalIgnoreCase) ||
            caminho.StartsWith("~/Ramais/", StringComparison.OrdinalIgnoreCase);
    }

    private void RegistrarTimerSessao(object sender, EventArgs e)
    {
        System.Web.UI.Page pagina = sender as System.Web.UI.Page;
        if (pagina == null || Session == null) return;
        if (Session["usuario"] == null || Convert.ToString(Session["usuario"]).Trim().Length == 0) return;

        string contentType = Response.ContentType ?? "";
        if (contentType.Length > 0 && contentType.IndexOf("text/html", StringComparison.OrdinalIgnoreCase) < 0)
        {
            return;
        }

        Session.Timeout = TempoSessaoMinutos;

        int timeoutMinutos = TempoSessaoMinutos;
        int timeoutSegundos = timeoutMinutos * 60;
        long expiraEm = (long)(DateTime.UtcNow.AddSeconds(timeoutSegundos) - new DateTime(1970, 1, 1)).TotalMilliseconds;
        string loginUrl = SessaoUnica.UrlLoginSessaoEncerrada(Context);
        int queryIndex = loginUrl.IndexOf("?", StringComparison.Ordinal);
        if (queryIndex >= 0)
        {
            loginUrl = loginUrl.Substring(0, queryIndex);
        }

        string scriptUrl = pagina.ResolveUrl("~/js/bali-session-timer.js?v=20260628-15min");
        string renovarUrl = pagina.ResolveUrl("~/sessao-renovar.aspx");
        string init = String.Format(
            "window.BaliSessionTimer&&window.BaliSessionTimer.init({{timeoutSeconds:{0},expiresAt:{1},loginUrl:'{2}',renewUrl:'{3}'}});",
            timeoutSegundos,
            expiraEm,
            HttpUtility.JavaScriptStringEncode(loginUrl),
            HttpUtility.JavaScriptStringEncode(renovarUrl)
        );

        try
        {
            System.Web.UI.ScriptManager.RegisterClientScriptInclude(pagina, pagina.GetType(), "bali-session-timer-js", scriptUrl);
            System.Web.UI.ScriptManager.RegisterStartupScript(pagina, pagina.GetType(), "bali-session-timer-init", init, true);
        }
        catch
        {
            try
            {
                pagina.ClientScript.RegisterClientScriptInclude(pagina.GetType(), "bali-session-timer-js", scriptUrl);
                pagina.ClientScript.RegisterStartupScript(pagina.GetType(), "bali-session-timer-init", init, true);
            }
            catch
            {
            }
        }
    }

    private bool DeveIgnorarTimerSessao()
    {
        if (Context == null || Request == null) return true;
        if (SessaoUnica.DeveIgnorarValidacao(Context)) return true;

        string caminho = Request.AppRelativeCurrentExecutionFilePath ?? "";
        string nome = System.IO.Path.GetFileName(caminho).ToLowerInvariant();
        return nome == "sessao-renovar.aspx";
    }
</script>
