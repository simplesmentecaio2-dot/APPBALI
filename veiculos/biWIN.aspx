<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ultimofeirao2018.aspx.cs" Inherits="veiculos_Recibo_desconto" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BI | Fiat</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="refresh" content="600" />
    <link href="../css/estilo.css" rel="stylesheet" />
    <link href="../css/bali-bi-frame.css?v=20260624-1" rel="stylesheet" />
</head>
<body class="bi-frame-page bi-brand-fiat">
    <form id="form1" runat="server">
        <main class="bi-frame-shell">
            <section class="bi-frame-header">
                <div>
                    <span class="bi-frame-kicker">Indicadores</span>
                    <h1>BI Fiat</h1>
                    <p>Painel Fiat incorporado do Power BI, com atualização automática e visual responsivo.</p>
                </div>
                <div class="bi-frame-actions">
                    <a class="bi-frame-action" href="default.aspx">Voltar</a>
                    <a class="bi-frame-action primary" href="https://app.powerbi.com/view?r=eyJrIjoiOGIyNWIzYmQtNjFiZS00NTE3LTg5YzUtNTkxNjczMzJjM2RmIiwidCI6IjlhOTY3ZDk0LWM2YWItNGZkZS05OTUyLTY4NDI1YWM3M2VmNiJ9" target="_blank" rel="noopener">Abrir BI</a>
                </div>
            </section>

            <section class="bi-frame-card">
                <iframe title="BI Fiat" src="https://app.powerbi.com/view?r=eyJrIjoiOGIyNWIzYmQtNjFiZS00NTE3LTg5YzUtNTkxNjczMzJjM2RmIiwidCI6IjlhOTY3ZDk0LWM2YWItNGZkZS05OTUyLTY4NDI1YWM3M2VmNiJ9" allowfullscreen="true"></iframe>
            </section>
        </main>
    </form>
</body>
</html>
