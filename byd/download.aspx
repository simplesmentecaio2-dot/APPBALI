<%@ Page Language="C#" AutoEventWireup="true" CodeFile="download.aspx.cs" Inherits="rafael" %>

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
    <form id="form1" runat="server">
    <div>
       
        Data Inicial: <asp:textbox id="txtdtInicial" runat="server" AutoPostBack="True" ></asp:textbox>
        Data Final: <asp:textbox id="txtdtFinal" runat="server" AutoPostBack="True"></asp:textbox>
        <asp:Button ID="Button1" runat="server" Text="Gerar" OnClick="btnGerar_Click"  CssClass="btns" />
        <asp:gridview runat="server" AutoGenerateColumns="False" DataKeyNames="proposta_codigo" DataSourceID="SqlDataSource1" AllowPaging="True" AllowSorting="True">
            <Columns>
                <asp:CommandField ShowSelectButton="True"></asp:CommandField>
                <asp:BoundField DataField="loja" HeaderText="loja" ReadOnly="True" SortExpression="loja"></asp:BoundField>
                <asp:BoundField DataField="estoque" HeaderText="estoque" ReadOnly="True" SortExpression="estoque"></asp:BoundField>
                <asp:BoundField DataField="qtde" HeaderText="qtde" ReadOnly="True" SortExpression="qtde"></asp:BoundField>
                <asp:BoundField DataField="Atendimento_UsuarioCod" HeaderText="Atendimento_UsuarioCod" SortExpression="Atendimento_UsuarioCod"></asp:BoundField>
                <asp:BoundField DataField="Usuario_Nome" HeaderText="Usuario_Nome" SortExpression="Usuario_Nome"></asp:BoundField>
                <asp:BoundField DataField="NotaFiscal_Numero" HeaderText="NotaFiscal_Numero" SortExpression="NotaFiscal_Numero"></asp:BoundField>
                <asp:BoundField DataField="proposta_precopublico" HeaderText="proposta_precopublico" SortExpression="proposta_precopublico"></asp:BoundField>
                <asp:BoundField DataField="NotaFiscal_ValorTotal" HeaderText="NotaFiscal_ValorTotal" SortExpression="NotaFiscal_ValorTotal"></asp:BoundField>
                <asp:BoundField DataField="NotaFiscalItem_ValorLucroBruto" HeaderText="NotaFiscalItem_ValorLucroBruto" SortExpression="NotaFiscalItem_ValorLucroBruto"></asp:BoundField>
                <asp:BoundField DataField="cliente" HeaderText="cliente" SortExpression="cliente"></asp:BoundField>
                <asp:BoundField DataField="proposta_codigo" HeaderText="proposta_codigo" InsertVisible="False" ReadOnly="True" SortExpression="proposta_codigo"></asp:BoundField>
                <asp:BoundField DataField="Proposta_VeiculoValor" HeaderText="Proposta_VeiculoValor" SortExpression="Proposta_VeiculoValor"></asp:BoundField>
                <asp:BoundField DataField="Proposta_ModeloVeiculoDes" HeaderText="Proposta_ModeloVeiculoDes" ReadOnly="True" SortExpression="Proposta_ModeloVeiculoDes"></asp:BoundField>
                <asp:BoundField DataField="Proposta_ValorCustoOperacional" HeaderText="Proposta_ValorCustoOperacional" SortExpression="Proposta_ValorCustoOperacional"></asp:BoundField>
            </Columns>
        </asp:gridview>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:APPWFConnectionString %>" SelectCommand="vendasJEEP" SelectCommandType="StoredProcedure">
            <SelectParameters>
                <asp:ControlParameter ControlID="txtdtInicial" DbType="Date" Name="dtInicial" PropertyName="Text"  />
                <asp:ControlParameter ControlID="txtdtFinal" DbType="Date" Name="dtFinal" PropertyName="Text" />
            </SelectParameters>
        </asp:SqlDataSource>
      <%--  <asp:Table ID="Table1" runat="server"></asp:Table>
        <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
        <asp:GridView ID="GridView1" runat="server"></asp:GridView>--%>
    </div>
    </form>
</body>
</html>
