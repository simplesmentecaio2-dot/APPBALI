<%@ Page Language="C#" AutoEventWireup="true" CodeFile="dashboard-veiculos.aspx.cs" Inherits="diretoria_dashboard_veiculos" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    
    <link href="../css/estilo-diretoria.css" rel="stylesheet" />
    <script src="../js/jquery-1.10.2.js"></script>
   <script type="text/javascript">
       function toggleFullScreen() {
           if ((document.fullScreenElement && document.fullScreenElement !== null) ||
            (!document.mozFullScreen && !document.webkitIsFullScreen)) {
               if (document.documentElement.requestFullScreen) {
                   document.documentElement.requestFullScreen();
               } else if (document.documentElement.mozRequestFullScreen) {
                   document.documentElement.mozRequestFullScreen();
               } else if (document.documentElement.webkitRequestFullScreen) {
                   document.documentElement.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);
               }
           } else {
               if (document.cancelFullScreen) {
                   document.cancelFullScreen();
               } else if (document.mozCancelFullScreen) {
                   document.mozCancelFullScreen();
               } else if (document.webkitCancelFullScreen) {
                   document.webkitCancelFullScreen();
               }
           }
       }

    </script>
   
</head>
<body>
    <form id="form1" style="height:100%;" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <asp:UpdatePanel ID="UpdatePanel1" style="height:100%;" runat="server">
            <ContentTemplate>
                <asp:Timer ID="Timer1" runat="server" Interval="10000"></asp:Timer>
            
    <table style="width:100%; height:100%; bottom:0; color:white;" cellspacing="7" align="center" >
        <tr>
             <td class="bg-box"  style="width:20%; height:33%; vertical-align:top; ">
                <div style="font-size:25px;">
                   Veículos <input id="Button1" type="button" value="Tela Inteira" onclick="toggleFullScreen()" />
                    <asp:Label ID="lblUsuario" CssClass="idUser" runat="server" Text="" visible="false"></asp:Label>
                <div class="linha" style="margin-bottom:5px;"></div>
                </div>
                <span style="font-size:30px; margin-left:10px;" id="tempo"></span>
                 <br />
                <div style="font-size:40px;  margin-left:10px;">
                    
                    <%=data %>
                </div>
                 <div style="font-size:25px; margin-left:10px; margin-top:10px;">
                     <%=qtde.ToString("N0") %><br />
                    <font style="color:#4cff00;"> <%=vl.ToString("C2") %><br /></font>
                     <%=margem.ToString("C2") %>
                    
                 </div>
            </td>
            <td class="bg-box"  style="width:20%; height:33%;  vertical-align:top; ">
                <div style="font-size:25px;">
                   SIA
                <div class="linha"></div>
                </div>
                <div style="font-size:100px; margin-top:5px; margin-left:10px;">
                    <%=qtdeTotalSIA %>
                </div>
                <div style="font-size:25px;  margin-top:5px; margin-left:10px; color:#4cff00;">
                    <%=vlTotalSIA %><br />
                   <font style="color:white;"><%=(margemSIAVN +  margemSIAVU + margemAtualTV).ToString("C2") %></font>
                 </div>

            </td>
            <td class="bg-box"  style="width:20%; height:33%;   vertical-align:top;">
                <div style="font-size:25px;">
                   SCIA
                <div class="linha"></div>
                </div>
                <div style="font-size:100px; margin-top:5px; margin-left:10px;">
                    <%=qtdeTotalSCIA %>
                </div>
                <div style="font-size:25px;  margin-top:5px; margin-left:10px; color:#4cff00;">
                    <%=vlTotalSCIA %><br />
                    <font style="color:white;"><%=(margemSCIAVN +  margemSCIAVU).ToString("C2") %></font>
                </div>
            </td>
            <td class="bg-box"  style="width:20%; height:33%;  vertical-align:top;">
                <div style="font-size:25px;">
                   SAAN
                <div class="linha"></div>
                </div>
                <div style="font-size:100px; margin-top:5px; margin-left:10px;">
                    <%=qtdeTotalSAAN %>
                </div>
                <div style="font-size:25px;  margin-top:5px; margin-left:10px; color:#4cff00;">
                    <%=vlTotalSAAN %><br />
                   <font style="color:white;"> <%=(margemSAANVN +  margemSAANVU).ToString("C2") %></font>
                </div>
            </td>
            <td class="bg-box"  style="width:20%; height:33%; vertical-align:top;">
                <div style="font-size:25px;">
                   JEEP
                <div class="linha"></div>
                </div>
                <div style="font-size:100px; margin-top:5px; margin-left:10px;">
                    <%=qtdeTotalAERO %>
                </div>
                <div style="font-size:25px;  margin-top:5px; margin-left:10px; color:#4cff00;">
                    <%=vlTotalAERO %><br />
                   <font style="color:white;"> <%=(margemAEROVN +  margemAEROVU).ToString("C2") %></font>
                </div>
            </td>
        </tr>
        <tr>
            <td class="bg-box"  style="width:20%; height:33%; vertical-align:top;">
                <div style="font-size:25px;">
                   Mês Anterior
                <div class="linha"></div>
                </div>
                <div style="font-size:100px; font-size:40px; margin-left:10px;">
                    <%=qtdeTotalMesPeriodo %>
                </div>
                <div style="font-size:20px; margin-left:10px; color:#4cff00;">
                   <%=vlTotalMesPeriodo %> <br />
                     <font style="color:white;">
                        <%=(margemSIAVNPeriodo + margemSIAVUPeriodo + margemSCIAVNPeriodo + margemSCIAVUPeriodo + margemSAANVNPeriodo + margemSAANVUPeriodo + margemAEROVNPeriodo +  margemAEROVUPeriodo).ToString("C2") %>
                    </font>
                </div>
                 <table style="width:100%; margin-left:5px; vertical-align:top;">
                    <tr>
                        <td style="width:40%; vertical-align:top;">
                            <table>
                                <tr>
                                    <td>SIA</td><td><%=qtdeTotalSIAPeriodo %></td>
                                </tr>
                                <tr>
                                    <td>SCIA</td><td><%=qtdeTotalSCIAPeriodo %></td>
                                </tr>
                                <tr>
                                    <td>SAAN</td><td><%=qtdeTotalSAANPeriodo %></td>
                                </tr>
                                <tr>
                                    <td>JEEP</td><td><%=qtdeTotalAEROPeriodo %></td>
                                </tr>
            
                            </table>
                        </td>
                        <td style="width:60%; vertical-align:top;">
                            <table>
                                <tr>
                                    <td>Novos</td><td><%=qtdeTotalPeriodoVN %></td>
                                </tr>
                                <tr>
                                    <td>Seminovos</td><td><%=qtdeTotalPeriodoVU %></td>
                                </tr>
                                <tr>
                                    <td>Venda Direta</td><td><%=qtdeTotalPeriodoVD %></td>
                                </tr>
                                <tr>
                                    <td>Televendas*</td><td></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
            <td class="bg-box"  style="width:40%; vertical-align:top;" colspan="2" rowspan="2" >
                <div style="font-size:25px;">
                 TOTAL
                <div class="linha"></div>
                </div>
                <div style="font-size:150px; margin-top:10px; margin-left:10px;">
                   <%=qtdeTotalMesAtual %>
                </div>
                <div style="font-size:50px;  margin-top:0px; margin-left:20px; color:#4cff00;">
                   <%=vlTotalMesAtual %>
                    <br />
                     <font style="color:white;">
                        <%=(margemSIAVN + margemSIAVU + margemSCIAVN + margemSCIAVU + margemSAANVN + margemSAANVU + margemAEROVN +  margemAEROVU + margemAtualTV).ToString("C2") %>
                   </font>
                </div>
                <div style='<%=qtdeColor%>'>
                    <asp:Image ID="imgQtdeDiferenca" runat="server" style="width:25px; margin-left:20px;" />
                    
                    <%=qtdeDiferenca %>

                    <span style="font-size:20px;"> <%=margemDiferenca %></span>
                    <br />
                    <span style='<%=vlColor %>'>
                        <asp:Image ID="imgVlDiferenca" runat="server" Style="width: 25px; margin-left: 20px;" />
                        <%=vlDiferenca.ToString("C2") %>
                        <span style="font-size: 20px;"><%=vlmargemDiferenca %></span>
                    </span><br />
                     <span style='<%=margemColor %>'>
                        <asp:Image ID="imgMargemDiferenca" runat="server" Style="width: 25px; margin-left: 20px;" />
                        <%=(lucroAtual - lucroPerido).ToString("C2") %>
                        <span style="font-size: 20px;"><%=lucroDiferenca %></span>
                    </span>

                </div>
                                
            </td>
            <td class="bg-box"  style="width:20%; height:33%;  vertical-align:top;">
                <div style="font-size:25px; font-style:italic;">
                   SIA
                <div class="linha" ></div>
                </div>
                <br />
                <table style="width:100%; vertical-align:top;">
                    <tr>
                        <td style="width:50%; vertical-align:top;">Novos<span> (<%=qtdeSIAVN.ToString() %>)<br /><font style="color:#4cff00"><%=vlSIAVN.ToString("N2") %></font><br /> <%=margemSIAVN.ToString("N2") %></span></td>
                        <td style="width:50%; vertical-align:top;">Seminovos <span>(<%=qtdeSIAVU.ToString() %>)<br /><font style="color:#4cff00"><%=vlSIAVU.ToString("N2") %></font><br /> <%=margemSIAVU.ToString("N2") %> </span></td>
                    </tr>
                    <tr>
                        <td style="height:15px;"></td>
                    </tr>
                    <tr>
                        <td style="width:50%; vertical-align:top;">Venda Direta <span>(<%=qtdeSIAVD.ToString() %>)<br /><font style="color:#4cff00"><%=vlSIAVD.ToString("N2") %></font></span></td>
                        <td style="width:50%; vertical-align:top;">Televendas <span>(<%=qtdeAtualTV.ToString()%>)*<br /><font style="color:#4cff00"><%=vlAtualTV.ToString("N2") %>*</font><br /><%=margemAtualTV.ToString("N2") %>*</span></td>
                    </tr>
                    <tr>
                        <td style="height:15px;"></td>
                    </tr>
                    <tr>
                        <td style="width:50%; vertical-align:top;">Bali Móvel*<br /><span style="color:#4cff00;"></span></td>
                        <td style="width:50%; vertical-align:top;"></td>
                    </tr>
                </table>

            </td>
            <td class="bg-box"  style="width:20%; height:33%;  vertical-align:top;">
                <div style="font-size:25px; font-style:italic;">
                   SCIA
                <div class="linha"></div>
                </div>
                <br />
                <table style="width:100%; vertical-align:top;">
                    <tr>
                        <td style="width:50%; vertical-align:top;">Novos <span>(<%=qtdeSCIAVN.ToString() %>)<br /><font style="color:#4cff00"><%=vlSCIAVN.ToString("N2") %></font><br /> <%=margemSCIAVN.ToString("N2") %></span></td>
                        <td style="width:50%; vertical-align:top;">Seminovos <span>(<%=qtdeSCIAVU.ToString() %>)<br /><font style="color:#4cff00"><%=vlSCIAVU.ToString("N2") %></font><br /> <%=margemSCIAVU.ToString("N2") %></span></td>
                    </tr>
                    <tr>
                        <td style="height:15px;"></td>
                    </tr>
                    <tr>
                        <td style="width:50%; vertical-align:top;">Venda Direta <span>(<%=qtdeSCIAVD.ToString() %>)<br /><font style="color:#4cff00"><%=vlSCIAVU.ToString("N2") %></font></span></td>
                        <td style="width:50%; vertical-align:top;"></td>
                    </tr>
                </table>

            </td>
        </tr>
        <tr>
            <td class="bg-box"  style="width:20%; height:33%;  vertical-align:top;">
                <div style="font-size:25px;">
                   Total Mês Anterior
                <div class="linha"></div>
                </div>
                <div style="font-size:100px; font-size:40px;   margin-left:10px;">
                    <%=qtdeTotalMesAnterior %>
                </div>
                <div style="font-size:20px; margin-left:10px; color:#4cff00;">
                    <%=vlTotalMesAnterior %>
                </div>
                 <table style="width:100%; margin-left:5px; vertical-align:top;">
                    <tr>
                        <td style="width:40%; vertical-align:top;">
                            <table>
                                <tr>
                                    <td>SIA</td><td><%=qtdeTotalSIAAnterior %></td>
                                </tr>
                                <tr>
                                    <td>SCIA</td><td><%=qtdeTotalSCIAAnterior %></td>
                                </tr>
                                <tr>
                                    <td>SAAN</td><td><%=qtdeTotalSAANAnterior %></td>
                                </tr>
                                <tr>
                                    <td>JEEP</td><td><%=qtdeTotalAEROAnterior %></td>
                                </tr>
                            </table>
                        </td>
                        <td style="width:60%; vertical-align:top;">
                            <table>
                                <tr>
                                    <td>Novos</td><td><%=qtdeTotalAnteriorVN %></td>
                                </tr>
                                <tr>
                                    <td>Seminovos</td><td><%=qtdeTotalAnteriorVU %></td>
                                </tr>
                                <tr>
                                    <td>Venda Direta</td><td><%=qtdeTotalAnteriorVD %></td>
                                </tr>
                                <tr>
                                    <td>Televendas*</td><td></td>
                                </tr>
                                <tr>
                                    <td>Bali Móvel*</td><td></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
            <td class="bg-box" style="width:20%; height:33%;  vertical-align:top;">
                <div style="font-size:25px; font-style:italic;">
                   SAAN
                <div class="linha"></div>
                </div>
                <br />
                <table style="width:100%; vertical-align:top;">
                    <tr>
                        <td style="width:50%;  vertical-align:top;">Novos <span>(<%=qtdeSAANVN.ToString() %>)<br /><font style="color:#4cff00"><%=vlSAANVN.ToString("N2") %></font><br /> <%=margemSAANVN.ToString("N2") %></span></td>
                        <td style="width:50%;  vertical-align:top;">Seminovos <span>(<%=qtdeSAANVU.ToString() %>)<br /><font style="color:#4cff00"><%=vlSAANVU.ToString("N2") %></font><br /> <%=margemSAANVU.ToString("N2") %></span></td>
                    </tr>
                    <tr>
                        <td style="height:15px;"></td>
                    </tr>
                    <tr>
                        <td style="width:50%;  vertical-align:top;">Venda Direta <span>(<%=qtdeSAANVD.ToString() %>)<br /><font style="color:#4cff00"><%=vlSAANVD.ToString("N2") %></font></span></td>
                        <td style="width:50%;  vertical-align:top;"></td>
                    </tr>
                </table>

            </td>
            <td class="bg-box" style="width:20%; height:33%; vertical-align:top;">
                <div style="font-size:25px; font-style:italic;">
                   JEEP
                <div class="linha"></div>
                </div>
                <br />
                <table style="width:100%;  vertical-align:top;">
                    <tr>
                        <td style="width:50%; vertical-align:top;">Novos <span>(<%=qtdeAEROVN.ToString() %>)<br /><font style="color:#4cff00"><%=vlAEROVN.ToString("N2") %></font><br /> <%=margemAEROVN.ToString("N2") %></span></td>
                        <td style="width:50%; vertical-align:top;">Seminovos <span>(<%=qtdeAEROVU.ToString() %>)<br /><font style="color:#4cff00"><%=vlAEROVU.ToString("N2") %></font><br /> <%=margemAEROVU.ToString("N2") %></span></td>
                    </tr>
                    <tr>
                        <td style="height:15px;"></td>
                    </tr>
                    <tr>
                        <td style="width:50%; vertical-align:top;">Venda Direta <span>(<%=qtdeAEROVD.ToString() %>)<br /><font style="color:#4cff00"><%=vlAEROVD.ToString("N2") %></font></span></td>
                        <td style="width:50%; vertical-align:top;"></td>
                    </tr>
                </table>

            </td>
        </tr>
    </table>
                </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
<script>
    /*
    Horas Atuais
*/

    // Utiliza o script depois da página estar totalmente carregada
    window.onload = function () {
         //Define a função a ser chamada e o intervalo de tempo
        setInterval(horaDeAgora, 1);
    }
    // Função com o objeto e a variável de tempo
    function horaDeAgora() {
        // Cria o objeto do tipo Date
        var intervalo = new Date();

        var hora = intervalo.getHours();
        if (hora < 10) {
            hora = '0' + hora;
        }
        
        var minuto = intervalo.getMinutes();
        if (minuto < 10) {
            minuto = '0' + minuto;
        }

        var segundo = intervalo.getSeconds();
        if (segundo < 10) {
            segundo = '0' + segundo;
        }
        // Cria a variável que receberá as informações que serão apresentadas
        var tempo = hora + ":" + minuto + ":" + segundo;
        // Utiliza o elemento HTML com id tempo para apresentar os valores da variável tempo
        document.getElementById("tempo").innerHTML = tempo;
    }
</script>