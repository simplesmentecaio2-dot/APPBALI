<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ContaGerencial.aspx.cs" Inherits="veiculos_contrato" %>

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

            

       
          
             </div>

    <div align="center">
        </div>
        <asp:GridView ID="GridViewcontagerencial" runat="server" AutoGenerateColumns="False" CellPadding="4" DataSourceID="Sqlcontagerencial" ForeColor="#333333" GridLines="None" align="center">
            <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
            <Columns>
                <asp:BoundField DataField="Fornecedor" HeaderText="Fornecedor" SortExpression="Fornecedor"></asp:BoundField>
                <asp:BoundField DataField="ContaGerencial" HeaderText="ContaGerencial" SortExpression="ContaGerencial"></asp:BoundField>
                <asp:BoundField DataField="Usuário" HeaderText="Usuário" SortExpression="Usuário"></asp:BoundField>
            </Columns>
            <EditRowStyle BackColor="#999999" />
            <FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
            <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
            <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
            <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
            <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
            <sortedascendingcellstyle backcolor="#E9E7E2" />
            <sortedascendingheaderstyle backcolor="#506C8C" />
            <sorteddescendingcellstyle backcolor="#FFFDF8" />
            <sorteddescendingheaderstyle backcolor="#6F8DAE" />
        </asp:GridView>
        <asp:SqlDataSource ID="Sqlcontagerencial" runat="server" ConnectionString="<%$ ConnectionStrings:GrupoBali_DealernetWFConnectionString %>" SelectCommand="            select p.Pessoa_Nome Fornecedor,cg.ContaGerencial_Descricao ContaGerencial,u.Usuario_Nome Usuário from PessoaRegraUso pru

inner join pessoa p on p.Pessoa_Codigo = pru.Pessoa_Codigo
inner join ContaGerencial cg on cg.ContaGerencial_Codigo = PessoaRegraUso_Chave
inner join Usuario u on u.Usuario_Codigo = pru.PessoaRegraUso_UsuCodCriacao
where PessoaRegraUso_Tipo = 'CGE' and p.pessoa_nome not like '%bali%'
and p.pessoa_nome not  
in(
'MARCELO TEXEIRA GALLERANI','FCA FIAT CHRYSLER AUTOMOVEIS BRASIL LTDA (57)','ACT PARTS COMERCIO DE DISTRIBUIÇÃO DE AUTOPEÇAS LTDA','STELLANTIS AUTOMOVEIS BRASIL LTDA','LUIS GUSTAVO FREITAS DA SILVA','STELLANTIS AUTOMOVEIS BRASIL LTDA - PE')
order by p.pessoa_nome"></asp:SqlDataSource>

    </form>

    </body>
</html>
