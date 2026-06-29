<%@ Page Language="C#" AutoEventWireup="true" CodeFile="acesso-negado.aspx.cs" Inherits="acesso_negado" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Acesso bloqueado | Grupo Bali</title>
    <link href="/css/bali-tecnologia.css?v=20260629-permissoes01" rel="stylesheet" />
</head>
<body class="bali-tech-page">
    <form id="form1" runat="server">
        <main class="tech-main">
            <section class="tech-panel access-denied-panel">
                <div class="tech-panel-head">
                    <div>
                        <span class="tech-panel-kicker">Permiss&otilde;es</span>
                        <h1>Acesso bloqueado</h1>
                        <p>Seu usu&aacute;rio n&atilde;o possui libera&ccedil;&atilde;o para acessar esta p&aacute;gina neste momento.</p>
                    </div>
                </div>

                <div class="access-denied-box">
                    <span>Recurso</span>
                    <strong><asp:Literal ID="litRecurso" runat="server" /></strong>
                    <p>Procure a equipe de TI ou o gestor respons&aacute;vel caso precise deste acesso.</p>
                </div>

                <div class="tech-actions-row">
                    <asp:HyperLink ID="lnkVoltar" runat="server" CssClass="tech-button">Voltar</asp:HyperLink>
                    <asp:HyperLink ID="lnkInicio" runat="server" CssClass="tech-button tech-button-secondary" NavigateUrl="/Default.aspx">P&aacute;gina inicial</asp:HyperLink>
                </div>
            </section>
        </main>
    </form>
</body>
</html>
