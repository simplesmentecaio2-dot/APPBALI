<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ContaGerencial.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Conta Gerencial | Jeep</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/estilo.css" rel="stylesheet" />
    <link href="../tables/estilo/table.css" rel="stylesheet" />
    <link href="../css/bali-gerencial.css?v=20260626-logout01" rel="stylesheet" />
    <script src="../js/jquery-1.10.2.js"></script>
    <script src="../tables/js/jquery.dataTables.min.js"></script>
    <script src="../js/bali-gerencial.js?v=20260624-1"></script>
</head>
<body class="gerencial-page">
    <form id="form1" runat="server">
        <main class="gerencial-shell">
            <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
            <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text="" Visible="false"></asp:Label>

            <section class="gerencial-header">
                <div>
                    <span class="gerencial-kicker">Financeiro</span>
                    <h1>Conta Gerencial Jeep</h1>
                    <p>Consulta de fornecedores vinculados às contas gerenciais, com filtro rápido, ordenação por coluna e paginação.</p>
                </div>
                <div class="gerencial-actions">
                    <a class="gerencial-back" href="principal.aspx">Voltar</a>
                    <a class="gerencial-back gerencial-logout" href="/logout.aspx?voltar=/jeep/loginAppcontrato.aspx">Sair</a>
                </div>
            </section>

            <section class="gerencial-card">
                <div class="gerencial-table-wrap">
                    <asp:GridView ID="GridViewcontagerencial" runat="server" AutoGenerateColumns="False" CellPadding="0" DataSourceID="Sqlcontagerencial" GridLines="None" CssClass="gerencial-table">
                        <Columns>
                            <asp:BoundField DataField="Fornecedor" HeaderText="Fornecedor" SortExpression="Fornecedor"></asp:BoundField>
                            <asp:BoundField DataField="ContaGerencial" HeaderText="Conta Gerencial" SortExpression="ContaGerencial"></asp:BoundField>
                            <asp:BoundField DataField="Usuário" HeaderText="Usuário" SortExpression="Usuário"></asp:BoundField>
                        </Columns>
                    </asp:GridView>
                </div>
            </section>
        </main>
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
