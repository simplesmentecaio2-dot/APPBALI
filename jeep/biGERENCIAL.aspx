<%@ Page Language="C#" AutoEventWireup="true" CodeFile="biGERENCIAL.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BI Gerencial | Jeep</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/estilo.css" rel="stylesheet" />
    <link href="../css/bali-bi-frame.css?v=20260624-1" rel="stylesheet" />
</head>
<body class="bi-frame-page bi-brand-jeep">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text="" Visible="false"></asp:Label>

        <main class="bi-frame-shell">
            <section class="bi-frame-header">
                <div>
                    <span class="bi-frame-kicker">Indicadores</span>
                    <h1>BI Gerencial Jeep</h1>
                    <p>Painel gerencial incorporado do Power BI, com visual responsivo e carregamento leve.</p>
                </div>
                <div class="bi-frame-actions">
                    <a class="bi-frame-action" href="principal.aspx">Voltar</a>
                    <a class="bi-frame-action primary" href="https://app.powerbi.com/view?r=eyJrIjoiYzUzMWRhODgtMmVhNS00NWE5LThiYjAtNGFmOWZiNzI4MWQ2IiwidCI6IjlhOTY3ZDk0LWM2YWItNGZkZS05OTUyLTY4NDI1YWM3M2VmNiJ9" target="_blank" rel="noopener">Abrir BI</a>
                </div>
            </section>

            <section class="bi-frame-card">
                <iframe title="BI Gerencial Jeep" src="https://app.powerbi.com/view?r=eyJrIjoiYzUzMWRhODgtMmVhNS00NWE5LThiYjAtNGFmOWZiNzI4MWQ2IiwidCI6IjlhOTY3ZDk0LWM2YWItNGZkZS05OTUyLTY4NDI1YWM3M2VmNiJ9" allowfullscreen="true"></iframe>
            </section>
        </main>
    </form>
</body>
</html>
