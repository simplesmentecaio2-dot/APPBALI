<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ultimofeirao2018.aspx.cs" Inherits="veiculos_Recibo_desconto" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="refresh" content="600" />
    <title>BI-FIAT</title>
    <link href="../css/estilo.css" rel="stylesheet" />
    <script src="../../js/jquery-1.10.2.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.js"></script>
    <script src="../../jsPrice/jquery.price_format.1.7.min.js"></script>
    <script src="../../js/js.js"></script>
</head>
<body>
  <script>
         function aguarde() {
             document.getElementById('ag').style.visibility = 'visible';
         }
    </script>



   
    <form id="form1" runat="server">
        <div align="center">
            <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>

       
            <iframe title="GRAFICO" width="1300" height="900" src="https://app.powerbi.com/view?r=eyJrIjoiOGIyNWIzYmQtNjFiZS00NTE3LTg5YzUtNTkxNjczMzJjM2RmIiwidCI6IjlhOTY3ZDk0LWM2YWItNGZkZS05OTUyLTY4NDI1YWM3M2VmNiJ9" frameborder="0" allowFullScreen="true"></iframe>
        </div>

    </form>

    <div align="center">
        </div>
</body>
</html>


