DD<%@ Page Language="C#" AutoEventWireup="true" CodeFile="dashboard_evento.aspx.cs" Inherits="veiculos_contrato" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <title></title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <!-- STYLE MARCIO       ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
    <script src="./assets/jquery-1.9.1.min.js"></script>
    <script src="./assets/jquery.dataTables.min.js"></script>
    <link href="./assets/dataTables.bootstrap4.min.css" rel="stylesheet" />
    <script src="./assets/dataTables.bootstrap4.min.js"></script>
    <script src="./assets/dataTables.responsive.min.js"></script>
    <link href="./main.css" rel="stylesheet" />
    <script src="./ChartJS.js"></script>
    <link href="./assets/all.min.css" rel="stylesheet" />
    <script type="text/javascript" src="./assets/toastr.min.js"></script>

</head>

<body>
    <form id="form1" class="needs-validation" runat="server" novalidate="novalidate">
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="gerencia_vendedor2" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="prospeccao_evento" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource7" runat="server" ConnectionString="<%$ ConnectionStrings:APPConnectionString %>" SelectCommand="gerencia_vendedor2" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
        <asp:ScriptManager ID="ScriptManager1" EnableScriptGlobalization="true" runat="server"></asp:ScriptManager>
        <div class="app-container app-theme-white body-tabs-shadow fixed-sidebar fixed-header">
            <div class="app-header header-shadow">
                <div class="app-header__logo">
                    <div class="logo-src"></div>
                    <div class="header__pane ml-auto">
                        <div>
                            <button type="button" class="hamburger close-sidebar-btn hamburger--elastic" data-class="closed-sidebar">
                                <span class="hamburger-box">
                                    <span class="hamburger-inner"></span>
                                </span>
                            </button>
                        </div>
                    </div>
                </div>
                <div class="app-header__mobile-menu">

                    <div>
                        <button type="button" class="hamburger hamburger--elastic mobile-toggle-nav">
                            <span class="hamburger-box">
                                <span class="hamburger-inner"></span>
                            </span>
                        </button>
                    </div>
                </div>
                <div class="app-header__menu">
                    <span>
                        <button type="button" class="btn-icon btn-icon-only btn btn-primary btn-sm mobile-toggle-header-nav">
                            <span class="btn-icon-wrapper">
                                <i class="fa fa-ellipsis-v fa-w-6"></i>
                            </span>
                        </button>
                    </span>
                </div>
                <div class="app-header__content">
                    <div class="app-header-left">
                    </div>
                    <div class="app-header-right">
                        <div class="header-btn-lg pr-0">
                            <div class="widget-content p-0">
                                <div class="widget-content-wrapper">
                                    <div class="widget-content-left">
                                        <div class="btn-group">
                                            <a data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" class="p-0 btn">
                                                <img width="42" class="rounded-circle" src="assets/images/avatars/1.jpg" alt="">
                                                <i class="">
                                                    <asp:Literal ID="usuarioLogado" runat="server"></asp:Literal>
                                                </i>
                                            </a>

                                        </div>
                                    </div>
                                    <div class="widget-content-left  ml-3 header-user-info">
                                    </div>
                                    <div class="widget-content-right header-user-info ml-3">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="app-main">
                <div class="app-sidebar sidebar-shadow">
                    <div class="app-header__logo">
                        <div class="logo-src"></div>
                        <div class="header__pane ml-auto">
                            <div>
                                <button type="button" class="hamburger close-sidebar-btn hamburger--elastic" data-class="closed-sidebar">
                                    <span class="hamburger-box">
                                        <span class="hamburger-inner"></span>
                                    </span>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="app-header__mobile-menu">
                        <div>
                            <button type="button" class="hamburger hamburger--elastic mobile-toggle-nav">
                                <span class="hamburger-box">
                                    <span class="hamburger-inner"></span>
                                </span>
                            </button>
                        </div>
                    </div>
                    <div class="app-header__menu">
                        <span>
                            <button type="button" class="btn-icon btn-icon-only btn btn-primary btn-sm mobile-toggle-header-nav">
                                <span class="btn-icon-wrapper">
                                    <i class="fa fa-ellipsis-v fa-w-6"></i>
                                </span>
                            </button>
                        </span>
                    </div>
                    <div class="scrollbar-sidebar">
                        <div class="app-sidebar__inner">
                             <ul class="vertical-nav-menu">
                                <li class="app-sidebar__heading"></li>
                                <li>
                                    <a href="./prospeccao.aspx">
                                        <i class="metismenu-icon fas fa-home"></i>
                                        Prospecção
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">Dashboards</li>
                                <li>
                                    <a href="./dashboard_lojas.aspx">
                                        <i class="metismenu-icon pe-7s-bookmarks "></i>
                                        Dashboard Lojas
                                    </a>
                                </li>
                                <li>

                                    <a href="./dashboard_evento.aspx" class="mm-active">
                                        <i class="metismenu-icon fas fa-chart-bar"></i>
                                        Dashboard Evento
                                    </a>
                                </li>
                                 <li>

                                    <a href="./dashboard_resultado.aspx">
                                        <i class="metismenu-icon fas fa-chalkboard"></i>
                                        Dashboard Resultado
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">__________________________________</li>
                                <li>

                                    <a href="./criar_fluxo.aspx">
                                        <i class="metismenu-icon fas fa-user-plus"></i>
                                        Criar Fluxo Sem QrCode
                                    </a>
                                </li>
                                 <li>

                                    <a href="./criar_venda.aspx">
                                        <i class="metismenu-icon fas fa-plus"></i>
                                        Criar Venda
                                    </a>
                                </li>
                                <li class="app-sidebar__heading">__________________________________</li>
                                 <li>

                                    <a href="./criar_avaliacao.aspx" >
                                        <i class="metismenu-icon fas fa-dollar-sign"></i>
                                        Criar Avaliação
                                    </a>
                                </li><li>

                                    <a href="./consultar_avaliacao.aspx">
                                        <i class="metismenu-icon fas fa-search-dollar"></i>
                                        Consultar Avaliaçao
                                    </a>
                                </li>
                                 <li class="app-sidebar__heading">__________________________________</li>
                                <li>
                                    <a href="./Default.aspx">
                                        <i class="metismenu-icon fas fa-car-alt"></i>
                                        Veículos
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="app-main__outer">
                    <asp:UpdatePanel ID="updatePanelEvt" runat="server">
                        <ContentTemplate>
                            <div class="app-main__inner">
                                <div class="app-page-title">
                                    <div class="page-title-wrapper">
                                        <div class="page-title-heading">
                                            <div class="page-title-icon">
                                                <i class="pe-7s-car icon-gradient bg-dark"></i>
                                            </div>
                                            <div>
                                                <b>Dashboard Evento</b>

                                                <div class="page-title-subheading">
                                                </div>
                                            </div>
                                        </div>
                                        <div class="page-title-actions">
                                            <label for="ddlEventoDashEvt">Evento:</label>
                                            <select id="ddlEventoDashEvt" name="ddlEventoDashEvt" class="btn-shadow mr-3 btn btn-dark text-uppercase" runat="server" datasourceid="SqlDataSource2" datatextfield="nome" datavaluefield="nome">
                                            </select>
                                            <label for="ddlLojaDashEvt">Loja:</label>
                                            <select id="ddlLojaDashEvt" name="ddlLojaDashEvt" class="btn-shadow mr-3 btn btn-info text-uppercase" runat="server">
                                                <option value="SIA"></option>
                                                <option value="SAAN"></option>
                                                <option value="SCIA"></option>
                                            </select>

                                            <button class="btn btn-primary" runat="server" id="btnAtualizaDash" onclick="btnShowData">
                                                <i class="fas fa-sync-alt"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 col-xl-3">
                                        <div class="card mb-3 widget-content bg-night-sky">
                                            <div class="widget-content-wrapper text-white">
                                                <div class="widget-content-left">
                                                    <div class="widget-heading">Fluxo</div>
                                                    <div class="widget-subheading">Total de fluxos confirmados</div>
                                                </div>
                                                <div class="widget-content-right">
                                                    <div class="widget-numbers text-white">
                                                        <span>
                                                            <asp:Literal ID="txtTotalFluxo" runat="server"></asp:Literal></span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6 col-xl-2">
                                        <div class="card mb-3 widget-content bg-night-sky">
                                            <div class="widget-content-wrapper text-white">
                                                <div class="widget-content-left">
                                                    <div class="widget-heading">Vendas</div>
                                                    <div class="widget-subheading">Total de vendas</div>
                                                </div>
                                                <div class="widget-content-right">
                                                    <div class="widget-numbers text-white">
                                                        <span>
                                                            <asp:Literal ID="txtTotalVendas" runat="server"></asp:Literal></span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-7 col-xl-4">
                                        <div class="card mb-3 widget-content bg-dark">
                                            <div class="widget-content-wrapper text-white">
                                                <div class="widget-content-left">
                                                    <div class="widget-heading">Conversão</div>
                                                    <div class="widget-subheading">Conversão de fluxo em venda.<span><asp:Literal ID="literalConversaoPerc" runat="server"></asp:Literal></span></div>
                                                </div>
                                                <div class="widget-content-right">
                                                    <div class="widget-numbers text-white">
                                                        <span>
                                                            <asp:Literal ID="literalFluxoVenda" runat="server"></asp:Literal></span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-5 col-xl-3">
                                        <div class="card mb-3 widget-content bg-royal">
                                            <div class="widget-content-wrapper text-white">
                                                <div class="widget-content-left">
                                                    <div class="widget-heading">Percentual</div>
                                                    <div class="widget-subheading">Percentual atingido da meta.</div>
                                                </div>
                                                <div class="widget-content-right">
                                                    <div class="widget-numbers text-white">
                                                        <div class="progress-bar-sm progress-bar-animated-alt progress" style="height: 2px;">
                                                            <asp:Literal ID="txtPercentualEvtProgressBar" runat="server"></asp:Literal>
                                                        </div>
                                                        <span>
                                                            <asp:Literal ID="txtPercentualEvt" runat="server"></asp:Literal></span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>


                                    <div class="col-md-4 col-xl-2">
                                        <div class="card mb-3 widget-content " style="background-color:yellow;">

                                            <div class="widget-content-wrapper text-dark">
                                                <div class="widget-content-right">
                                                    <div class="widget-numbers text-dark">
                                                        <span>
                                                            <asp:Literal ID="literalAmarela" runat="server"></asp:Literal></span><span class="h6"> Vendas</span>
                                                    </div>
                                                </div>
                                            </div>

                                        </div>
                                    </div><div class="col-md-4 col-xl-2">
                                        <div class="card mb-3 widget-content bg-primary">
                                            <div class="widget-content-wrapper text-white">
                                                <div class="widget-content-right">
                                                    <div class="widget-numbers text-white">
                                                        <span>
                                                            <asp:Literal ID="literalAzul" runat="server"></asp:Literal></span><span class="h6"> Vendas</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div><div class="col-md-4 col-xl-2">
                                        <div class="card mb-3 widget-content" style="background-color:orange;">
                                            <div class="widget-content-wrapper text-white">
                                                <div class="widget-content-right">
                                                    <div class="widget-numbers text-white">
                                                        <span>
                                                            <asp:Literal ID="literalLaranja" runat="server"></asp:Literal></span><span class="h6"> Vendas</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div><div class="col-md-4 col-xl-2">
                                        <div class="card mb-3 widget-content bg-success">
                                            <div class="widget-content-wrapper text-white">
                                                <div class="widget-content-right">
                                                    <div class="widget-numbers text-white">
                                                        <span>
                                                            <asp:Literal ID="literalVerde" runat="server"></asp:Literal></span><span class="h6"> Vendas</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div><div class="col-md-4 col-xl-2">
                                        <div class="card mb-3 widget-content " style="background-color:red;">
                                            <div class="widget-content-wrapper text-white">
                                                <div class="widget-content-right">
                                                    <div class="widget-numbers text-white">
                                                        <span>
                                                            <asp:Literal ID="literalVermelha" runat="server"></asp:Literal> </span><span class="h6"> Vendas</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-7 col-lg-8">
                                        <div class="mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header">
                                                <div class="card-header-title">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    Ranking
                                       
                                                </div>
                                            </div>
                                            <div class="card-body">
                                                <div class="tab-content">
                                                    <div class="tab-pane fade show active" id="tabs-eg-77">
                                                        <div class="card mb-3 widget-chart widget-chart2 text-left w-100">
                                                            <div class="widget-chat-wrapper-outer">
                                                                <div class="widget-chart-wrapper widget-chart-wrapper-lg opacity-10 m-0">
                                                                    <asp:Literal ID="equipesRanking" runat="server"></asp:Literal>
                                                                    <canvas id="bar" width="100%" responsive="true"></canvas>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header">
                                                <div class="card-header-title">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    Timeline
                                       
                                                </div>
                                            </div>
                                            <div class="card-body">
                                                <div class="tab-content">
                                                    <div class="tab-pane fade show active" id="Div1">
                                                        <div class="card mb-3 widget-chart widget-chart2 text-left w-100">
                                                            <div class="widget-chat-wrapper-outer">
                                                                <div class="widget-chart-wrapper widget-chart-wrapper-lg opacity-10 m-0">
                                                                    <canvas id="line" width="100%" responsive="true"></canvas>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-5 col-lg-4">
                                        <div class="mb-3 card">
                                            <div class="card-header-tab card-header-tab-animation card-header">
                                                <div class="card-header-title">
                                                    <i class="header-icon lnr-apartment icon-gradient bg-love-kiss"></i>
                                                    Top Prospectores
                                       
                                                </div>
                                                <ul class="nav">
                                                    <li class="nav-item">
                                                        <span >convite <i class="fas fa-arrow-right"></i> venda</span>
                                                    </li>
                                                </ul>
                                            </div>
                                            <div class="card-body">
                                                <div class="tab-content">
                                                    <div class="tab-pane fade show active" id="Div2">


                                                        <ul class="rm-list-borders rm-list-borders-scroll list-group list-group-flush">
                                                            <asp:Literal ID="txtTopProspector" runat="server"></asp:Literal>
                                                        </ul>
                                                    </div>

                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12 col-lg-12">
                                        
                                    </div>
                                </div>
                            </div>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="timeUpdatePanelEvt" EventName="Tick" />
                        </Triggers>
                    </asp:UpdatePanel>
                    <asp:Timer ID="timeUpdatePanelEvt" runat="server" OnTick="btnAtualizaDashClick" Interval="5000"></asp:Timer>
                    <div class="app-wrapper-footer">
                        <div class="app-footer">
                            <div class="app-footer__inner">
                                <div class="app-footer-left">
                                    <ul class="nav">
                                        <li class="nav-item"></li>
                                    </ul>
                                </div>
                                <div class="app-footer-right">
                                    <ul class="nav">
                                        <li class="nav-item"></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
    </form>

    <script>
        function changeLabel(cod) {
            lbl = document.getElementById('cod');
            // Assign HTML codes along with text values using innerHTML.
            lbl.innerHTML = cod;
        }

    </script>
    <script src="./assets/popper.min.js"></script>
    <script src="./assets/bootstrap.min.js"></script>
    <script src="./assets/jspdf.min.js"></script>
    <script src="./assets/scripts/main.js"></script>
    <script>
        function convertBase64ToFile(image) {
            const byteString = atob(image.split(',')[1]);
            const ab = new ArrayBuffer(byteString.length);
            const ia = new Uint8Array(ab);
            for (let i = 0; i < byteString.length; i += 1) {
                ia[i] = byteString.charCodeAt(i);
            }
            const newBlob = new Blob([ab], {
                type: 'image/jpeg',
            });
        return newBlob;
        }

        function downloadURI(uri, name) {
            var link = document.createElement("a");

            link.download = name;
            link.href = uri;
            document.body.appendChild(link);
            link.click();
            document.body.appendChild(link).removeChild;
        }

        function DownloadAsImage(nomeArquivo) {
            var element = $("#conviteQrCodeLead")[0];
            html2canvas(element).then(function(canvas) {
                var myImage = canvas.toDataURL();
                downloadURI(myImage, nomeArquivo + '.png');
            });
        }

        function htmlToBase64Image(nameFile, idElement) {
            var element = $("#" + idElement)[0];
            var stringBase64 = html2canvas(element).then(function(canvas) {
                return canvas.toDataURL();

            });
            return stringBase64;
        }
        'use strict';

        function sleep(delay) {
            return new Promise(resolve => {
                setTimeout(resolve, delay);
        });
        }

        function logText(message, isError) {
            if (isError)
                console.error(message);
            else
                console.log(message);

            const p = document.createElement('p');
            if (isError)
                p.setAttribute('class', 'error');
            document.querySelector('#output').appendChild(p);
            p.appendChild(document.createTextNode(message));
        }

        function logError(message) {
            logText(message, true);
        }

        function checkboxChanged(e) {
            const checkbox = e.target;
            const textfield = document.querySelector('#' + checkbox.id.split('_')[0]);

            textfield.disabled = !checkbox.checked;
            if (!checkbox.checked)
                textfield.value = '';
        }

        async function testWebShare() {


            if (navigator.share === undefined) {
                DownloadAsImage(document.querySelector('#txtClienteQrLead').textContent);
                return;
            }


            try {
                if (window.navigator.canShare && window.navigator.canShare({
                    files: [new File([convertBase64ToFile(document.querySelector('#qrLeadImg').src)], "invoice.png", {
                    type: "image/png",
                    mimeType: 'image/png'
                })]
                })) {
                    window.navigator.share({
                        files: [new File([convertBase64ToFile(document.querySelector('#qrLeadImg').src)], "invoice.png", {
                            type: "image/png"
                        })],
                    }).then(() => console.log('Share was successful.'))
                        .catch((error) => console.log(error, error));
                } else {

                }
            } catch (error) {
                alert('Erro: ' + error);
                logError('Error sharing: ' + error);
            }
        }


        async function testWebShareDelay() {
            await sleep(6000);
            testWebShare();
        }

        function onLoad() {
            document.querySelector('#share').addEventListener('click', testWebShare);

            if (navigator.share === undefined) {
                if (window.location.protocol === 'http:') {
                    // navigator.share() is only available in secure contexts.
                    window.location.replace(window.location.href.replace(/^http:/, 'https:'));
                } else {
                    logError('Error: You need to use a browser that supports this draft ' +
                        'proposal.');
                }
            }
        }




        window.addEventListener('load', onLoad);

        function dataURLtoFile(dataurl, filename) {
            var arr = dataurl.split(','),
                mime = arr[0].match(/:(.*?);/)[1],
                bstr = atob(arr[1]),
                n = bstr.length,
                u8arr = new Uint8Array(n);
            while (n--) {
                u8arr[n] = bstr.charCodeAt(n);
            }
            return new File([u8arr], filename, {
                type: mime
            });
        }

        //Usage example:
        var file = dataURLtoFile('data:text/plain;base64,aGVsbG8gd29ybGQ=', 'hello.txt');

    </script>
</body>

</html>
