<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Seminovos.aspx.cs" Inherits="veiculos_Seminovos" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="../scripts/js.js"></script>
    <%--<link href="../css/estilo.css" rel="stylesheet" />--%>
    <link href="DataTableCSS.css" rel="stylesheet" />
    <script src="jquery.js"></script>
    <script src="DataTables.js"></script>
    <style type="text/css">
        #tblSeminovos {
            width:100%;
            font-size:14px;
        }
        #saibamais {
            margin:0 auto;
            padding:0;
            position:fixed;
            z-index:100;
            left:0;
            top:0;
            width:100%;
            height:100%;
            background-color:rgba(255, 255, 255, 0.75);
            display:none;
        }
        #formsaibamais {
           
           padding:0;
           width:270px;
           height:410px;
           position:fixed;
           background-color:pink;
           z-index:1000;
           left:50%;
           top:50%;
           margin-left:-135px;
           margin-top:-205px;
        }
       
    </style>
    
    
    <script type="text/javascript">
        $(document).ready(function () {
            oTable = $('#tblSeminovos').dataTable({ //example é o ID da tabela
                "bPaginate": true,
                //"bJQueryUI": true,
                "ordering": false,
                "paging": true,
                //"scrollY": "500px",
                //"scrollCollapse": true,
                "sPaginationType": "full_numbers"
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server"  style="width:940px;   margin:0 auto; padding:0;">
       
    <%=estoqueVU %>
    <div id="saibamais">
        <form id="from2" action="#">
            <div id="formsaibamais"></div>
        </form>
    </div>
    </form>
    
</body>
</html>
