<%@ Application Language="C#" %>

<script runat="server">
    private const int TempoSessaoMinutos = 15;

    void Application_PreRequestHandlerExecute(object sender, EventArgs e)
    {
        try
        {
            if (Context == null) return;
            if (DeveIgnorarTimerSessao()) return;
            if (Session == null) return;
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
        if (Context == null) return;
        if (SessaoUnica.DeveIgnorarValidacao(Context)) return;
        if (Session == null) return;
        if (Session["usuario"] == null || Convert.ToString(Session["usuario"]).Trim().Length == 0) return;

        Session.Timeout = TempoSessaoMinutos;

        AppPermissoes.RegistrarUsuarioAtual(Context);
        if (!AppPermissoes.ValidarAcessoAtual(Context))
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Redirect(AppPermissoes.UrlAcessoNegado(Context), false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

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
        if (EhErroDeValidacaoRequest(erro) && EhPaginaConsultaQrCode())
        {
            Server.ClearError();
            Response.Clear();
            Response.Redirect(VirtualPathUtility.ToAbsolute("~/qrcode-veiculo/consulta.aspx"), false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        if (EhErroDeValidacaoRequest(erro))
        {
            RenderizarErroSeguro("Requisição inválida", "Confira os dados informados e tente novamente.");
            return;
        }

        if (EhPaginaLogin())
        {
            RenderizarErroLoginSeguro();
            return;
        }

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

    void Application_PreSendRequestHeaders(object sender, EventArgs e)
    {
        try
        {
            if (!EhPaginaConsultaQrCode() && !EhPaginaLogin()) return;

            if (EhPaginaConsultaQrCode())
            {
                Response.Headers["Content-Security-Policy"] = "default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'";
            }
            else
            {
                Response.Headers["Content-Security-Policy"] = "base-uri 'self'; form-action 'self'; frame-ancestors 'none'";
            }

            Response.Headers["Referrer-Policy"] = "no-referrer";
            Response.Headers["X-Content-Type-Options"] = "nosniff";
            Response.Headers["X-Frame-Options"] = "DENY";
            Response.Headers.Remove("X-AspNet-Version");
            Response.Headers.Remove("X-Powered-By");
        }
        catch
        {
        }
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

    private bool EhErroDeValidacaoRequest(Exception erro)
    {
        for (Exception atual = erro; atual != null; atual = atual.InnerException)
        {
            if (atual is HttpRequestValidationException)
            {
                return true;
            }
        }

        return false;
    }

    private bool EhPaginaConsultaQrCode()
    {
        string caminho = Request.AppRelativeCurrentExecutionFilePath ?? "";
        return caminho.Equals("~/qrcode-veiculo/consulta.aspx", StringComparison.OrdinalIgnoreCase);
    }

    private bool EhPaginaLogin()
    {
        string caminho = Request.AppRelativeCurrentExecutionFilePath ?? "";
        string nome = System.IO.Path.GetFileName(caminho).ToLowerInvariant();
        return nome == "login.aspx"
            || nome == "loginapp.aspx"
            || nome == "loginappcontrato.aspx"
            || nome == "loginbi.aspx"
            || nome == "loginbiwf.aspx";
    }

    private void RenderizarErroLoginSeguro()
    {
        RenderizarErroSeguro("Não foi possível processar o login", "Confira os dados informados e tente novamente.");
    }

    private void RenderizarErroSeguro(string titulo, string mensagem)
    {
        Server.ClearError();
        Response.Clear();
        Response.TrySkipIisCustomErrors = true;
        Response.StatusCode = 400;
        Response.ContentType = "text/html; charset=utf-8";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.Write("<!doctype html><html lang=\"pt-BR\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><title>Requisição inválida</title></head><body style=\"font-family:Arial,sans-serif;background:#f5f7fb;color:#111827;padding:32px\"><main style=\"max-width:520px;margin:60px auto;background:#fff;border:1px solid #dbe3ee;border-radius:10px;padding:28px;text-align:center\"><h1 style=\"margin:0 0 12px;font-size:22px\">" + HttpUtility.HtmlEncode(titulo) + "</h1><p style=\"margin:0 0 20px;color:#475569\">" + HttpUtility.HtmlEncode(mensagem) + "</p><button type=\"button\" onclick=\"history.back()\" style=\"border:0;border-radius:8px;background:#111827;color:#fff;padding:11px 18px;font-weight:700;cursor:pointer\">Voltar</button></main></body></html>");
        Context.ApplicationInstance.CompleteRequest();
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
