<%@ Application Language="C#" %>

<script runat="server">
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
</script>
