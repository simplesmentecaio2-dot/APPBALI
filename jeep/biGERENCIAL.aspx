<%@ Page Language="C#" AutoEventWireup="true" CodeFile="biGERENCIAL.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../css/estilo.css" rel="stylesheet" />
    <script src="../js/jquery-1.10.2.js"></script>
    <script src="../js/js.js"></script>
    <script src="../js/jquery.maskMoney.js"></script>
    <script src="../js/maskMin.js"></script>
    <script src="../js/maskPhone.js"></script>

    <script src="http://code.jquery.com/jquery-1.9.1.min.js" type="text/javascript"></script>
    <script src="http://code.highcharts.com/highcharts.js" type="text/javascript"></script>
    <script src="http://code.highcharts.com/modules/exporting.js"></script>

    <script src="../tables/js/jquery.dataTables.min.js"></script>
    <link href="../tables/estilo/jquery-ui-1.8.4.custom.css" rel="stylesheet" />
    <link href="../tables/estilo/table.css" rel="stylesheet" />
    <link href="../tables/estilo/table_jui.css" rel="stylesheet" />



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
             <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text="" visible="false"></asp:Label>

            <iframe title="JEEP" width="1300" height="900" src="https://app.powerbi.com/view?r=eyJrIjoiYzUzMWRhODgtMmVhNS00NWE5LThiYjAtNGFmOWZiNzI4MWQ2IiwidCI6IjlhOTY3ZDk0LWM2YWItNGZkZS05OTUyLTY4NDI1YWM3M2VmNiJ9" frameborder="0" allowFullScreen="true"></iframe>
            

       
          
             </div>

    </form>

    <div align="center">
        </div>
</body>
</html>
