<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ultimofeirao2018.aspx.cs" Inherits="veiculos_Recibo_desconto" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>
<meta http-equiv="refresh" content="100000">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
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
        <div>
            <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
            

        </div>

        <asp:gridview runat="server" AllowSorting="True" BackColor="White" BorderColor="#3366CC" BorderStyle="None" BorderWidth="1px" CellPadding="4" DataSourceID="SqlDataSource2">
            <FooterStyle BackColor="#99CCCC" ForeColor="#003399" />
            <HeaderStyle BackColor="#003399" Font-Bold="True" ForeColor="#CCCCFF" />
            <PagerStyle BackColor="#99CCCC" ForeColor="#003399" HorizontalAlign="Left" />
            <RowStyle BackColor="White" ForeColor="#003399" />
            <SelectedRowStyle BackColor="#009999" Font-Bold="True" ForeColor="#CCFF99" />
            <sortedascendingcellstyle backcolor="#EDF6F6" />
            <sortedascendingheaderstyle backcolor="#0D4AC4" />
            <sorteddescendingcellstyle backcolor="#D6DFDF" />
            <sorteddescendingheaderstyle backcolor="#002876" />
        </asp:gridview>

        <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:fiatnet_jeepConnectionString %>" SelectCommand="md_estoque_veiculos" SelectCommandType="StoredProcedure">
            <SelectParameters>
                <asp:Parameter DefaultValue="VU" Name="Codigo_Estoque" Type="String" />
                <asp:Parameter DefaultValue="0" Name="Dias_Estoque" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>

        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:fiatnet_jeepConnectionString %>" SelectCommand="SELECT [ve_ds]
      ,[est_cd]   
	  ,[ve_placa] 
      ,[ve_nr]
      ,[ve_chassi]
            
      ,[emp_compra]
      ,[dias]
      
  FROM [fiatnet_jeep].[dbo].[estoque_caio]
  where est_cd = 'VU' order by dias "></asp:SqlDataSource>
    </form>

    <div align="center">
        </div>
</body>
</html>


