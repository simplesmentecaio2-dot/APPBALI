<%@ Page Language="C#" AutoEventWireup="true" CodeFile="consulta.aspx.cs" Inherits="qrcode_veiculo_consulta" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="robots" content="noindex,nofollow" />
    <title>Consulta de Ve&iacute;culo | Grupo Bali</title>
    <link href="../css/qrcode-veiculo.css?v=20260701-05" rel="stylesheet" />
</head>
<body class="qr-page qr-public-page">
    <form id="form1" runat="server">
        <main class="vehicle-public-shell">
            <asp:Panel ID="pnlNaoEncontrado" runat="server" CssClass="vehicle-empty" Visible="false">
                <img src="../img/logobali.png" alt="Grupo Bali" />
                <h1>Ve&iacute;culo n&atilde;o encontrado</h1>
                <p>N&atilde;o localizamos um carro em estoque para este QR Code. Procure um consultor da loja para confirmar as informa&ccedil;&otilde;es.</p>
            </asp:Panel>

            <asp:Panel ID="pnlVeiculo" runat="server" Visible="false">
                <section class="vehicle-hero">
                    <div class="vehicle-hero-top">
                        <div class="vehicle-brand">
                            <strong>GRUPO BALI</strong>
                            <div class="vehicle-brand-logos" aria-label="Marcas do Grupo Bali">
                                <img class="vehicle-logo-fiat" src="../img/logoBaliFiat.png" alt="Bali Fiat" />
                                <img class="vehicle-logo-jeep" src="../intranet/resources/imagens/logojeep.png" alt="Bali Jeep" />
                                <img class="vehicle-logo-byd" src="../intranet/resources/imagens/BYD.png" alt="Bali BYD" />
                            </div>
                        </div>
                        <span><asp:Label ID="lblLojaHero" runat="server" /></span>
                    </div>
                    <div class="vehicle-hero-content">
                        <span class="vehicle-eyebrow"><asp:Label ID="lblFabricanteHero" runat="server" /></span>
                        <h1><asp:Label ID="lblModeloHero" runat="server" /></h1>
                        <p><asp:Label ID="lblResumoHero" runat="server" /></p>
                        <div class="vehicle-quick-facts" aria-label="Resumo r&aacute;pido do ve&iacute;culo">
                            <span><strong>Placa</strong><asp:Label ID="lblChipPlaca" runat="server" /></span>
                            <span><strong>Ano</strong><asp:Label ID="lblChipAno" runat="server" /></span>
                            <span><strong>KM</strong><asp:Label ID="lblChipKm" runat="server" /></span>
                        </div>
                    </div>
                    <div class="vehicle-price-panel">
                        <div class="vehicle-price-card is-featured">
                            <span>Valor anunciado</span>
                            <strong><asp:Label ID="lblValorPromocao" runat="server" /></strong>
                        </div>
                        <div class="vehicle-price-card">
                            <span>Valor normal</span>
                            <strong><asp:Label ID="lblValorNormal" runat="server" /></strong>
                        </div>
                        <small><asp:Label ID="lblValorObservacao" runat="server" /></small>
                    </div>
                </section>

                <section class="vehicle-data-card vehicle-values-card">
                    <div class="vehicle-section-title">
                        <span>Valores</span>
                        <h2>Valores do ve&iacute;culo</h2>
                    </div>
                    <div class="vehicle-data-grid vehicle-values-grid">
                        <div><span>Valor atual</span><strong><asp:Label ID="lblValorAtualDetalhe" runat="server" /></strong></div>
                        <div><span>Valor normal</span><strong><asp:Label ID="lblValorNormalDetalhe" runat="server" /></strong></div>
                        <div><span>Valor usado</span><strong><asp:Label ID="lblValorUsado" runat="server" /></strong></div>
                        <div><span>Promo&ccedil;&atilde;o</span><strong><asp:Label ID="lblValorPromocaoDetalhe" runat="server" /></strong></div>
                        <div><span>Tabela novo</span><strong><asp:Label ID="lblValorNovoTabela" runat="server" /></strong></div>
                    </div>
                </section>

                <section class="vehicle-data-card">
                    <div class="vehicle-section-title">
                        <span>Dados principais</span>
                        <h2>Informa&ccedil;&otilde;es do carro</h2>
                    </div>
                    <div class="vehicle-data-grid">
                        <div><span>Loja</span><strong><asp:Label ID="lblLoja" runat="server" /></strong></div>
                        <div><span>Estoque</span><strong><asp:Label ID="lblEstoque" runat="server" /></strong></div>
                        <div><span>Fabricante</span><strong><asp:Label ID="lblFabricante" runat="server" /></strong></div>
                        <div><span>Modelo</span><strong><asp:Label ID="lblModelo" runat="server" /></strong></div>
                        <div><span>Ano/Modelo</span><strong><asp:Label ID="lblAno" runat="server" /></strong></div>
                        <div><span>KM</span><strong><asp:Label ID="lblKm" runat="server" /></strong></div>
                        <div><span>Combust&iacute;vel</span><strong><asp:Label ID="lblCombustivel" runat="server" /></strong></div>
                        <div><span>Cor</span><strong><asp:Label ID="lblCor" runat="server" /></strong></div>
                    </div>
                </section>

                <section class="vehicle-data-card">
                    <div class="vehicle-section-title">
                        <span>Identifica&ccedil;&atilde;o</span>
                        <h2>Registro do ve&iacute;culo</h2>
                    </div>
                    <div class="vehicle-data-grid is-technical">
                        <div><span>Placa</span><strong><asp:Label ID="lblPlaca" runat="server" /></strong></div>
                        <div><span>Chassi</span><strong><asp:Label ID="lblChassi" runat="server" /></strong></div>
                        <div><span>Renavam</span><strong><asp:Label ID="lblRenavam" runat="server" /></strong></div>
                        <div><span>C&oacute;digo do ve&iacute;culo</span><strong><asp:Label ID="lblCodigoVeiculo" runat="server" /></strong></div>
                        <div><span>Data de entrada</span><strong><asp:Label ID="lblDataEntrada" runat="server" /></strong></div>
                        <div><span>Nota fiscal</span><strong><asp:Label ID="lblNotaFiscal" runat="server" /></strong></div>
                    </div>
                </section>

                <footer class="vehicle-footer">
                    <strong>GRUPO BALI</strong>
                    <span>Informa&ccedil;&otilde;es atualizadas diretamente do estoque.</span>
                </footer>
            </asp:Panel>
        </main>
    </form>
</body>
</html>
