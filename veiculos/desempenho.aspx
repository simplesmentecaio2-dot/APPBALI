<%@ Page Language="C#" AutoEventWireup="true" CodeFile="desempenho.aspx.cs" Inherits="gerencia_veiculos" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<title></title>
    
    <link href="../css/estilo.css" rel="stylesheet" />
    <script src="../js/jquery-1.10.2.js"></script>
    <script src="http://code.jquery.com/jquery-1.9.1.min.js" type="text/javascript"></script>  
    <script src="http://code.highcharts.com/highcharts.js" type="text/javascript"></script>
    <script src="http://code.highcharts.com/modules/exporting.js"></script>
    <script src="../js/js.js"></script>
    
</head>
<body>
    <form id="form1" runat="server">
        
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <%-- <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                <ContentTemplate>--%>
    <div id="topo">
            <table id="table-menu">
                <tr>
                    <td id="table-menu-logo" ><font id="logo" style="font-family:Arial black; font-size:32px;  font-style:italic; color:white; margin-left:13px;"><a href="../../Default.aspx" class="linkHome">BALI</a></font><font style="font-family:Calibri; font-size:14px; margin-left:5px;  font-style:italic; color:white;">APP</font><%--<img src="img/logo4.png" style="margin-left:13px; margin-top:-10px; height: 78px; width: 161px;" />--%></td>
                    <td id="table-menu-usuario" class="idUser">Usuário: <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text=""></asp:Label>   Perfil: <asp:Label ID="lblTipo" CssClass="idUser" runat="server" style="margin-right:13px;" Text=""></asp:Label></td>
                </tr>
            </table>
        </div>
        
        <div id="linha-branca"></div>
        <div id="menu-topo">
            
        </div>
        <div id="menu">
            <div id="openMenuUp" class="menu-top" onmouseover="escondeMenuLeft()" onclick="escondeMenuLeft()">
                MENU >>
            </div>
            <div style="text-align:right; margin-right:15px;" >
                <asp:Label ID="lblFrmID" runat="server" Text="Analise de Consultor"></asp:Label>
            </div>
        </div>
        <img id="openMenu" src="../../img/openMenu.png" style="height: 68px; width: 68px; position:absolute; z-index:200; top:60px; left:10px; display:none;" />
        <div id="menu-left">
            <div class="item-menu"  style="padding-left:80px; height:50px; line-height:60px;" onclick="escondeMenuLeft()">
                MENU <<
            </div>
            <div class="item-menu-select"><a class="links" href="Default.aspx">Inicio</a></div>
            
           
            <div id="completa-menu-left"></div>
            </div>
        
        <div id="Cont" onmouseover="esconderMenuLeftMouse()">
           

                
             <table style="width:100%;padding:13px; text-align:left;" align="center">
                <tr style="width:100%; ">
                    <td style="width:100%; background-color:white;">
                        <div style="background-color: white; width: 100%;">
                            <table cellspacing="3" style=" margin-left:5px; ">
                                <tr>
                                    <td></td>
                                    <td></td>
                                    <td>Data Inicial:</td>
                                    <td>Data Final:</td>
                                    <td>Vendedor:</td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:DropDownList ID="ddlistLoja" Height="25px" runat="server" AutoPostBack="True" Visible="false">
                                            <asp:ListItem Selected="True" Value="00">-- Loja --</asp:ListItem>
                                            <asp:ListItem Value="01">SIA</asp:ListItem>
                                            <asp:ListItem Value="02">SCIA</asp:ListItem>
                                            <asp:ListItem Value="03">SAAN</asp:ListItem>
                                            <asp:ListItem Value="04">AERO</asp:ListItem>
                                        </asp:DropDownList>
                                   </td>

                                    <td>
                                        <asp:DropDownList ID="ddlistSetor" Height="25px"  Width="150px" runat="server" DataSourceID="sqldsSetor" DataTextField="setor" DataValueField="id_setor" AutoPostBack="True" Visible="false">
                                            
                                        </asp:DropDownList>
                                        
                                    </td>
                                    
                                    <td>
                                        <asp:TextBox ID="txtDtInicio" Width="120px" Height="19px"  runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="txtDtInicio_CalendarExtender" runat="server" Enabled="True" TargetControlID="txtDtInicio">
                                                </asp:CalendarExtender> 
                                    </td>
                                     <td>
                                          <asp:TextBox ID="txtDtFim" Width="120px" Height="19px"  runat="server"></asp:TextBox>
                                                <asp:CalendarExtender ID="txtDtFim_CalendarExtender" runat="server" Enabled="True" TargetControlID="txtDtFim">
                                                </asp:CalendarExtender>
                                     </td>
                                    <td>
                                        <asp:DropDownList ID="ddlVendedor" Width="250px" Height="25px" runat="server" DataSourceID="sqldsVendedor" DataTextField="fun_nm" DataValueField="fun_cd" AutoPostBack="True" OnSelectedIndexChanged="ddlVendedor_SelectedIndexChanged"></asp:DropDownList>
                                    </td>
                                    <td>
                                        <asp:Button ID="Button1" runat="server" Text="Atualizar" OnClick="Button1_Click" />
                                        <%--<asp:ImageButton ID="ibtnAtualizar" ImageUrl="~/img/atualizar.png" style="width:30px;" runat="server" />--%>
                                    </td>
                                </tr>
                                
                            </table>
                            <div style="width:99%; height:1px; margin:auto; margin-top:15px; margin-bottom:15px; background-color:silver;"></div>  
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  
                            <img src="../img/imprimir.png" style="width: 30px; cursor: pointer;" onclick="javascript: imprimePanel()" />
                            <asp:TabContainer ID="TabContainerVendedor" CssClass="tabPanelConsultar" style="margin:auto;" Width="98%" runat="server" ActiveTabIndex="0">
                                
                                <%--<asp:TabPanel ID="TabPanelDesempenho" Style="padding: 20px;" runat="server" HeaderText="">
                                    <HeaderTemplate>
                                        Desempenho
                                    </HeaderTemplate>
                                    <ContentTemplate>
                                        
                                        
                                        <table style="width:100%;">
                                            <tr>
                                                <td style="width:100%;">
                                                    
                                                </td>
                                            </tr>
                                        </table>
                                        
                                    </ContentTemplate>
                                </asp:TabPanel>--%>
                                <asp:TabPanel ID="TabPanelNumeros" Style="padding: 20px;" runat="server" HeaderText="">
                                    <HeaderTemplate>
                                        Números
                                    </HeaderTemplate>
                                    <ContentTemplate>
                                        <table style="width:100%;">
                                            <tr>
                                                <td style="width:50%;"><asp:Label ID="lblVendedorNumeros" runat="server" Font-Bold="true" ForeColor="#cc0000"  Font-Size="16px" Text=""></asp:Label></td>
                                                <td style="width:50%; text-align:right;"><asp:Label ID="lblLoja" runat="server" Font-Bold="true" ForeColor="#cc0000"  Font-Size="16px" Text=""></asp:Label> - <asp:Label ID="lblSetor" runat="server" Font-Bold="true" ForeColor="#cc0000"  Font-Size="16px" Text=""></asp:Label></td>
                                            </tr>
                                        </table>
                                        <div style="width:100%; background-color:gray; margin-top:3px; margin-bottom:3px; height:2px;"></div>
                                        
                                        <table cellspacing="8" >
                                            <tr>
                                                <td><b>Quantidade:</b> <%=qtdeTotal %></td>
                                                <td><b>Faturado:</b> <%=vlTotal.ToString("C2") %></td>
                                                <td rowspan="5" style="width:20px;" ></td>
                                                <td rowspan="5" valign="top"><%=tableVendidos %></td>
                                            </tr>
                                            <tr>
                                                <td><b>Lucro Bruto:</b> <%=margemTotal.ToString("C2") %></td>
                                                <td><b>Margem:</b> <%=((margemTotal * 100) / vlTotal).ToString("C2") %>%</td>
                                            </tr>
                                            <tr>
                                                <td><b>Acessório Cobrado:</b> <%=acessorioCobrado.ToString("C2") %></td>
                                                <td><b>Acessório Custo: </b><%=acessorioCusto.ToString("N2") %></td>
                                            </tr>
                                            <tr>
                                                <td><b>Emplacamento Cobrado:</b> <%=emplacamentoCobrado.ToString("C2") %></td>
                                                <td><b>Emplacamento Custo: </b><%=emplacamentoCusto.ToString("N2") %></td>
                                            </tr>
                                            <tr>
                                                <td><b>Transf. Cobrado:</b> <%=transfCobrado.ToString("C2") %></td>
                                                <td><b>Transf. Custo: </b><%=transfCusto.ToString("N2") %></td>
                                            </tr>
                                        </table>
                                        <%--<asp:Label ID="lblVendedor" runat="server" Text=""></asp:Label>--%>
                                         <div style="width:100%; background-color:gray; margin-top:3px; margin-bottom:3px; height:2px;"></div>
                                        <div id="desempenho"></div>
                                       
                                        
                                        
                                    </ContentTemplate>
                                </asp:TabPanel>
                                <asp:TabPanel ID="TabPanelDetalhes" Style="padding: 20px;" runat="server" HeaderText="">
                                    <HeaderTemplate>
                                        Detalhes
                                    </HeaderTemplate>
                                    <ContentTemplate>
                                        <div style="width:100%;  background-color:white;">
                                 <table style="width:100%; ">
                                     <tr>
                                         <td colspan="2">
                                            
                                         </td>
                                     </tr>
                                     <tr>
                                         <td style="width:30%;" valign="top" >
                                             <asp:GridView ID="GridViewVendas" Width="100%" Font-Size="14px" Font-Names="Arial" runat="server" AutoGenerateColumns="False" BackColor="White" BorderColor="#CCCCCC" BorderStyle="None" BorderWidth="1px" CellPadding="4" DataSourceID="sqldsVendas" ForeColor="Black" GridLines="Horizontal" AllowPaging="True" PageSize="20">
                                        <Columns>
                                            <asp:CommandField SelectText="Detalhar" ShowSelectButton="True" />
                                            <asp:BoundField DataField="NF" HeaderText="NF" ReadOnly="True" SortExpression="NF" />
                                            <asp:BoundField DataField="pedido" HeaderText="pedido" ReadOnly="True" SortExpression="pedido" />
                                            <asp:BoundField DataField="estoque" HeaderText="estoque" ReadOnly="True" SortExpression="estoque" />
                                        </Columns>
                                        <FooterStyle BackColor="#CCCC99" ForeColor="Black" />
                                        <HeaderStyle BackColor="#3E3E42" Font-Bold="True" ForeColor="White" />
                                        <PagerStyle BackColor="White" ForeColor="Black" HorizontalAlign="Right" />
                                        <SelectedRowStyle BackColor="#CC3333" Font-Bold="True" ForeColor="White" />
                                        <SortedAscendingCellStyle BackColor="#F7F7F7" />
                                        <SortedAscendingHeaderStyle BackColor="#4B4B4B" />
                                        <SortedDescendingCellStyle BackColor="#E5E5E5" />
                                        <SortedDescendingHeaderStyle BackColor="#242121" />
                                    </asp:GridView>
                                         </td>
                                         <td style="width:70%;">
                                         </td>
                                     </tr>
                                 </table>
                                                                 
                                   
                                    <asp:SqlDataSource ID="sqldsVendas" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="gerencia_select_vendas_vendedor" SelectCommandType="StoredProcedure">
                                        <SelectParameters>
                                            <asp:ControlParameter ControlID="txtDtInicio" DbType="Date" Name="dtInicio" PropertyName="Text" />
                                            <asp:ControlParameter ControlID="txtDtFim" DbType="Date" Name="dtfinal" PropertyName="Text" />
                                            <asp:ControlParameter ControlID="ddlVendedor" DefaultValue="0" Name="fun_cd" PropertyName="SelectedValue" Type="String" />
                                        </SelectParameters>
                                    </asp:SqlDataSource>
                                   
                                </div>
                                    </ContentTemplate>
                                </asp:TabPanel>
                            </asp:TabContainer>
                            
                             
                             
                         </div>
                      </td>
                    </tr>
                 </table>
                       
        </div>
        <asp:SqlDataSource ID="sqldsSetor" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="gerencia_select_setor" SelectCommandType="StoredProcedure">
            <SelectParameters>
                <asp:ControlParameter ControlID="ddlistLoja" DefaultValue="00" Name="loja" PropertyName="SelectedValue" Type="String" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="sqldsVendedor" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="gerencia_vendedor" SelectCommandType="StoredProcedure">
            <SelectParameters>
                <asp:ControlParameter ControlID="ddlistSetor" DefaultValue=" " Name="id_setor" PropertyName="SelectedValue" Type="String" />
            </SelectParameters>
        </asp:SqlDataSource>
       <%-- </ContentTemplate>
            </asp:UpdatePanel> --%>
        
    </form>
</body>
</html>
<script>
    $(function () {

        $('#desempenho').highcharts({
            chart: {
                type: 'line'
            },
            credits: {
                enabled: 0
            },
            title: {
                text: '<b>Veículos vendidos nos ultimos 12 meses.</b>'
            },
            subtitle: {
                //text: 'Source: <a href="http://en.wikipedia.org/wiki/List_of_cities_proper_by_population">Wikipedia</a>'
            },
            xAxis: {
                type: 'category',
                labels: {
                    rotation: -45,
                    align: 'right',
                    style: {
                        fontSize: '10px',
                        fontFamily: 'Verdana, sans-serif'

                    }

                }
            },
            yAxis: {
                //min: 0,
                title: {
                    text: 'Quantidade'
                }
            },
            legend: {
                enabled: false
            },
            tooltip: {
                pointFormat: 'Quantidade: <b>{point.y}</b>',
            },
            //legend: {
            //    layout: 'vertical',
            //    align: 'center',
            //    verticalAlign: 'bottom',
            //    borderWidth: 0
            //},
         


         series: [{
            //color: 'blue',
             name: 'Mês/Ano',
             data: [
                     <%=desempenho %>
                         ],
      
                         dataLabels: {
                             enabled: true,
                             //rotation: -90,
                             color: 'black',
                             //align: 'right',
                             align: 'center',
                             x: 0,
                             y: -10,
                             style: {
                                 fontSize: '10px',
                                 fontFamily: 'Verdana, sans-serif',
                                 // textShadow: '0 0 3px black'
                             }
                         }
                     }]
                 });
             });
    </script>
<script language="javascript" type="text/jscript">
    function imprimePanel() {
        var printContent = document.getElementById("<%=TabContainerVendedor.ClientID%>");
        var windowUrl = 'formPadrao.aspx';
        var uniqueName = new Date();
        var windowName = 'Processos Enviados ao Despachante';//'Print' + uniqueName.getTime();
        var printWindow = window.open(windowUrl, windowName, 'left=50000,top=50000,width=0,height=0');

        printWindow.document.write(printContent.innerHTML);
        printWindow.document.close();
        printWindow.focus();
        printWindow.print();
        printWindow.close();
    }

</script>