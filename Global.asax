<%@ Application Language="C#" %>

<script runat="server">
    private const int TempoSessaoMinutos = 15;
    private static readonly object ErroLogLock = new object();

    void Application_BeginRequest(object sender, EventArgs e)
    {
        try
        {
            if (DeveBloquearRecursoSensivel())
            {
                BloquearRecursoSensivel();
            }
        }
        catch
        {
        }
    }

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

            pagina.PreInit += AplicarProtecaoViewState;
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
        bool usuarioLogado = UsuarioLogado();

        if (DeveExigirLoginCentral() && !usuarioLogado)
        {
            RedirecionarLoginCentral();
            return;
        }

        if (EhPaginaLegadaRestrita() && !usuarioLogado)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Redirect(VirtualPathUtility.ToAbsolute("~/login.aspx"), false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        if (!usuarioLogado) return;

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
        RegistrarErroInterno(erro);
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
            RenderizarErroSeguro("Requisi\u00e7\u00e3o inv\u00e1lida", "Confira os dados informados e tente novamente.");
            return;
        }

        if (EhPaginaLogin())
        {
            RenderizarErroLoginSeguro();
            return;
        }

        if (EhErroDeViewState(erro) && EhPaginaProtegidaContraViewState())
        {
            Server.ClearError();

            string destino = Request.Url.AbsolutePath + Request.Url.Query;
            destino += destino.IndexOf("?", StringComparison.Ordinal) >= 0 ? "&" : "?";
            destino += "viewstate=expired";

            Response.Redirect(destino, false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        RenderizarErroSeguro("N\u00e3o foi poss\u00edvel processar a solicita\u00e7\u00e3o", "Tente novamente em instantes. Se o problema continuar, acione a TI.", 500);
    }

    private void AplicarProtecaoViewState(object sender, EventArgs e)
    {
        System.Web.UI.Page pagina = sender as System.Web.UI.Page;
        if (pagina == null || Session == null) return;
        if (Session["usuario"] == null || Convert.ToString(Session["usuario"]).Trim().Length == 0) return;

        string usuarioChave = Convert.ToString(Session["usuario_codigo"]);
        if (String.IsNullOrWhiteSpace(usuarioChave))
        {
            usuarioChave = Convert.ToString(Session["usuario"]);
        }

        if (String.IsNullOrWhiteSpace(usuarioChave)) return;

        pagina.ViewStateUserKey = Session.SessionID + "|" + usuarioChave;
    }

    void Application_PreSendRequestHeaders(object sender, EventArgs e)
    {
        try
        {
            if (EhPaginaConsultaQrCode())
            {
                Response.Headers["Content-Security-Policy"] = "default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'";
                Response.Headers["X-Frame-Options"] = "DENY";
            }
            else if (EhPaginaLogin())
            {
                Response.Headers["Content-Security-Policy"] = "base-uri 'self'; form-action 'self'; frame-ancestors 'none'";
                Response.Headers["X-Frame-Options"] = "DENY";
            }
            else
            {
                Response.Headers["X-Frame-Options"] = "SAMEORIGIN";
            }

            if (Request != null && Request.IsSecureConnection)
            {
                Response.Headers["Strict-Transport-Security"] = "max-age=15552000";
            }

            Response.Headers["Referrer-Policy"] = EhPaginaConsultaQrCode() || EhPaginaLogin() ? "no-referrer" : "strict-origin-when-cross-origin";
            Response.Headers["X-Content-Type-Options"] = "nosniff";
            Response.Headers["X-Download-Options"] = "noopen";
            Response.Headers["X-Permitted-Cross-Domain-Policies"] = "none";
            Response.Headers["Cross-Origin-Resource-Policy"] = "same-origin";
            Response.Headers["Permissions-Policy"] = EhPaginaLeitorCodigoBarras() ? "camera=(self), microphone=(), geolocation=()" : "camera=(), microphone=(), geolocation=()";
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

    private bool DeveBloquearRecursoSensivel()
    {
        if (Request == null) return false;

        string caminho = Request.AppRelativeCurrentExecutionFilePath ?? "";
        string caminhoLower = caminho.ToLowerInvariant();
        string nomeLower = System.IO.Path.GetFileName(caminhoLower);

        if (caminhoLower.IndexOf("/.git", StringComparison.OrdinalIgnoreCase) >= 0 ||
            caminhoLower.IndexOf("/.github", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return true;
        }

        if (nomeLower.StartsWith("teste", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        if (nomeLower.IndexOf("bkp", StringComparison.OrdinalIgnoreCase) >= 0 ||
            nomeLower.IndexOf("backup", StringComparison.OrdinalIgnoreCase) >= 0 ||
            nomeLower.IndexOf("copy", StringComparison.OrdinalIgnoreCase) >= 0 ||
            nomeLower.IndexOf("copia", StringComparison.OrdinalIgnoreCase) >= 0 ||
            nomeLower.IndexOf("c\u00f3pia", StringComparison.OrdinalIgnoreCase) >= 0 ||
            nomeLower.IndexOf("homolog", StringComparison.OrdinalIgnoreCase) >= 0 ||
            nomeLower == "default1.aspx" ||
            nomeLower == "registrar1.aspx" ||
            nomeLower == "registrar_agendamento.aspx" ||
            nomeLower == "consultar_agendamento.aspx")
        {
            return true;
        }

        string extensao = System.IO.Path.GetExtension(caminhoLower);
        switch (extensao)
        {
            case ".7z":
            case ".asax":
            case ".bak":
            case ".backup":
            case ".config":
            case ".cs":
            case ".csproj":
            case ".log":
            case ".md":
            case ".old":
            case ".orig":
            case ".rar":
            case ".secrets":
            case ".sql":
            case ".suo":
            case ".tmp":
            case ".user":
            case ".vb":
            case ".zip":
                return true;
        }

        return false;
    }

    private void BloquearRecursoSensivel()
    {
        Response.Clear();
        Response.TrySkipIisCustomErrors = true;
        Response.StatusCode = 404;
        Response.ContentType = "text/plain; charset=utf-8";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.Write("Recurso nao encontrado.");
        Context.ApplicationInstance.CompleteRequest();
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

    private bool EhPaginaLeitorCodigoBarras()
    {
        string caminho = Request.AppRelativeCurrentExecutionFilePath ?? "";
        return caminho.Equals("~/veiculos/patiojeep/registrar.aspx", StringComparison.OrdinalIgnoreCase) ||
            caminho.Equals("~/veiculos/patiojeep/novos.aspx", StringComparison.OrdinalIgnoreCase);
    }

    private bool UsuarioLogado()
    {
        return Session != null
            && Session["usuario"] != null
            && Convert.ToString(Session["usuario"]).Trim().Length > 0;
    }

    private bool DeveExigirLoginCentral()
    {
        if (Request == null) return false;

        string caminho = Request.AppRelativeCurrentExecutionFilePath ?? "";
        if (!caminho.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase)) return false;
        if (EhPaginaPublicaSemLogin(caminho)) return false;

        // CI e Ramais possuem login proprio com auditoria especifica do modulo.
        if (caminho.StartsWith("~/CI/", StringComparison.OrdinalIgnoreCase)) return false;
        if (caminho.StartsWith("~/RAMAIS/", StringComparison.OrdinalIgnoreCase) ||
            caminho.StartsWith("~/Ramais/", StringComparison.OrdinalIgnoreCase)) return false;

        return true;
    }

    private bool EhPaginaPublicaSemLogin(string caminho)
    {
        string nome = System.IO.Path.GetFileName(caminho).ToLowerInvariant();
        if (nome == "erro.aspx") return true;
        if (nome == "sessao-renovar.aspx") return true;

        return caminho.Equals("~/qrcode-veiculo/default.aspx", StringComparison.OrdinalIgnoreCase) ||
            caminho.Equals("~/qrcode-veiculo/consulta.aspx", StringComparison.OrdinalIgnoreCase);
    }

    private void RedirecionarLoginCentral()
    {
        string rawUrl = Request == null ? "/" : (Request.RawUrl ?? "/");
        string destino = VirtualPathUtility.ToAbsolute("~/login.aspx") + "?voltar=" + HttpUtility.UrlEncode(rawUrl);

        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.Redirect(destino, false);
        Context.ApplicationInstance.CompleteRequest();
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
        RenderizarErroSeguro("N\u00e3o foi poss\u00edvel processar o login", "Confira os dados informados e tente novamente.");
    }

    private void RenderizarErroSeguro(string titulo, string mensagem)
    {
        RenderizarErroSeguro(titulo, mensagem, 400);
    }

    private void RenderizarErroSeguro(string titulo, string mensagem, int statusCode)
    {
        Server.ClearError();
        Response.Clear();
        Response.TrySkipIisCustomErrors = true;
        Response.StatusCode = statusCode;
        Response.ContentType = "text/html; charset=utf-8";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.Write("<!doctype html><html lang=\"pt-BR\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><title>Requisi&ccedil;&atilde;o inv&aacute;lida</title></head><body style=\"font-family:Arial,sans-serif;background:#f5f7fb;color:#111827;padding:32px\"><main style=\"max-width:520px;margin:60px auto;background:#fff;border:1px solid #dbe3ee;border-radius:10px;padding:28px;text-align:center\"><h1 style=\"margin:0 0 12px;font-size:22px\">" + HttpUtility.HtmlEncode(titulo) + "</h1><p style=\"margin:0 0 20px;color:#475569\">" + HttpUtility.HtmlEncode(mensagem) + "</p><button type=\"button\" onclick=\"history.back()\" style=\"border:0;border-radius:8px;background:#111827;color:#fff;padding:11px 18px;font-weight:700;cursor:pointer\">Voltar</button></main></body></html>");
        Context.ApplicationInstance.CompleteRequest();
    }

    private void RegistrarErroInterno(Exception erro)
    {
        if (erro == null || Context == null) return;

        try
        {
            string pasta = Server.MapPath("~/App_Data/logs");
            if (!System.IO.Directory.Exists(pasta))
            {
                System.IO.Directory.CreateDirectory(pasta);
            }

            string arquivo = System.IO.Path.Combine(pasta, "security-errors.log");
            string usuario = Session == null || Session["usuario"] == null ? "-" : Convert.ToString(Session["usuario"]);
            string codigo = Session == null || Session["usuario_codigo"] == null ? "-" : Convert.ToString(Session["usuario_codigo"]);
            string ip = Request == null ? "-" : Convert.ToString(Request.UserHostAddress);
            string metodo = Request == null ? "-" : Convert.ToString(Request.HttpMethod);
            string url = Request == null ? "-" : Convert.ToString(Request.RawUrl);
            string agente = Request == null ? "-" : Convert.ToString(Request.UserAgent);

            System.Text.StringBuilder log = new System.Text.StringBuilder();
            log.AppendLine("================================================================================");
            log.AppendLine("Data: " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
            log.AppendLine("Usuario: " + usuario + " | Codigo: " + codigo);
            log.AppendLine("IP: " + ip + " | Metodo: " + metodo);
            log.AppendLine("URL: " + url);
            log.AppendLine("User-Agent: " + agente);
            log.AppendLine("Erro:");
            log.AppendLine(erro.ToString());

            lock (ErroLogLock)
            {
                System.IO.File.AppendAllText(arquivo, log.ToString(), new System.Text.UTF8Encoding(false));
            }
        }
        catch
        {
        }
    }

    private bool EhPaginaProtegidaContraViewState()
    {
        string caminho = Request.AppRelativeCurrentExecutionFilePath ?? "";
        return caminho.StartsWith("~/CI/", StringComparison.OrdinalIgnoreCase) ||
            caminho.StartsWith("~/Ramais/", StringComparison.OrdinalIgnoreCase);
    }

    private bool EhPaginaLegadaRestrita()
    {
        string caminho = Request.AppRelativeCurrentExecutionFilePath ?? "";
        string nome = System.IO.Path.GetFileName(caminho).ToLowerInvariant();
        string caminhoLower = caminho.ToLowerInvariant();
        return nome.StartsWith("teste", StringComparison.OrdinalIgnoreCase)
            || nome == "default1.aspx"
            || nome == "registrar1.aspx"
            || nome == "registrar_agendamento.aspx"
            || nome == "consultar_agendamento.aspx"
            || nome.IndexOf("bkp", StringComparison.OrdinalIgnoreCase) >= 0
            || nome.IndexOf("copy", StringComparison.OrdinalIgnoreCase) >= 0
            || nome.IndexOf("copia", StringComparison.OrdinalIgnoreCase) >= 0
            || nome.IndexOf("c\u00f3pia", StringComparison.OrdinalIgnoreCase) >= 0
            || nome.IndexOf("homolog", StringComparison.OrdinalIgnoreCase) >= 0
            || caminhoLower.IndexOf("/bkp", StringComparison.OrdinalIgnoreCase) >= 0
            || caminhoLower.IndexOf("backup", StringComparison.OrdinalIgnoreCase) >= 0
            || caminhoLower.IndexOf("copy of", StringComparison.OrdinalIgnoreCase) >= 0
            || caminhoLower.IndexOf("prospeccaobkp", StringComparison.OrdinalIgnoreCase) >= 0;
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
