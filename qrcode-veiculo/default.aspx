<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="qrcode_veiculo_default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Gerador de QR Code de Ve&iacute;culo | Grupo Bali</title>
    <link href="../css/qrcode-veiculo.css?v=20260701-01" rel="stylesheet" />
</head>
<body class="qr-page qr-generator-page">
    <form id="form1" runat="server">
        <header class="qr-topbar">
            <a class="qr-back" href="../tecnologia/Default.aspx">Voltar</a>
            <div class="qr-user">
                <span>Usu&aacute;rio: <asp:Label ID="lblUsuario" runat="server" /></span>
                <span>C&oacute;digo: <asp:Label ID="lblCodigo" runat="server" /></span>
            </div>
        </header>

        <main class="qr-shell">
            <section class="qr-hero">
                <div>
                    <span class="qr-eyebrow">Estoque &middot; QR Code</span>
                    <h1>Gerador de QR Code de ve&iacute;culo</h1>
                    <p>Informe a placa ou o chassi para gerar uma arte pronta para impress&atilde;o. O QR Code leva o cliente para a consulta exclusiva desse carro.</p>
                </div>
            </section>

            <section class="qr-workspace">
                <article class="qr-form-card">
                    <div class="qr-section-title">
                        <span>01</span>
                        <div>
                            <h2>Buscar ve&iacute;culo</h2>
                            <p>Digite a placa ou o chassi cadastrado no estoque.</p>
                        </div>
                    </div>

                    <div class="qr-search-row">
                        <asp:TextBox ID="txtBusca" runat="server" CssClass="qr-input" MaxLength="40" placeholder="Ex.: ABC1D23 ou 9BD..." autocomplete="off" />
                        <asp:Button ID="btnGerar" runat="server" CssClass="qr-primary-button" Text="Gerar QR Code" OnClick="btnGerar_Click" />
                    </div>
                    <asp:Literal ID="litMensagem" runat="server" />
                </article>

                <asp:Panel ID="pnlResultado" runat="server" CssClass="qr-result" Visible="false">
                    <article class="qr-print-card" aria-label="QR Code para impress&atilde;o">
                        <div class="qr-print-header">
                            <img src="../img/logobali.png" alt="Grupo Bali" />
                            <span>Consulta digital do ve&iacute;culo</span>
                        </div>
                        <div class="qr-print-body">
                            <div class="qr-print-copy">
                                <span class="qr-print-kicker">Aponte a c&acirc;mera do celular</span>
                                <h2>Consulte os dados desse carro aqui</h2>
                                <p>Veja loja, modelo, ano, cor, quilometragem e valores atualizados deste ve&iacute;culo.</p>
                            </div>
                            <div class="qr-code-box">
                                <asp:Image ID="imgQrCode" runat="server" AlternateText="QR Code de consulta do ve&iacute;culo" />
                            </div>
                        </div>
                        <div class="qr-print-footer">
                            <strong><asp:Label ID="lblPrintModelo" runat="server" /></strong>
                            <span><asp:Label ID="lblPrintIdentificador" runat="server" /></span>
                        </div>
                    </article>

                    <div class="qr-actions">
                        <button type="button" class="qr-secondary-button" onclick="window.print()">Imprimir ou salvar PDF</button>
                        <asp:HyperLink ID="lnkConsulta" runat="server" CssClass="qr-link-button" Target="_blank">Abrir consulta</asp:HyperLink>
                    </div>

                    <section class="qr-preview-card">
                        <div class="qr-section-title">
                            <span>02</span>
                            <div>
                                <h2>Pr&eacute;via do ve&iacute;culo</h2>
                                <p>Confira se o QR Code pertence ao carro correto antes de imprimir.</p>
                            </div>
                        </div>
                        <div class="qr-preview-grid">
                            <div><span>Loja</span><strong><asp:Label ID="lblLoja" runat="server" /></strong></div>
                            <div><span>Fabricante</span><strong><asp:Label ID="lblFabricante" runat="server" /></strong></div>
                            <div><span>Modelo</span><strong><asp:Label ID="lblModelo" runat="server" /></strong></div>
                            <div><span>Ano/Modelo</span><strong><asp:Label ID="lblAno" runat="server" /></strong></div>
                            <div><span>Placa</span><strong><asp:Label ID="lblPlaca" runat="server" /></strong></div>
                            <div><span>Chassi</span><strong><asp:Label ID="lblChassi" runat="server" /></strong></div>
                            <div><span>Cor</span><strong><asp:Label ID="lblCor" runat="server" /></strong></div>
                            <div><span>Valor</span><strong><asp:Label ID="lblValor" runat="server" /></strong></div>
                        </div>
                        <div class="qr-url-copy">
                            <span>Link gerado</span>
                            <asp:TextBox ID="txtLinkGerado" runat="server" ReadOnly="true" CssClass="qr-url-input" />
                        </div>
                    </section>
                </asp:Panel>
            </section>
        </main>
    </form>
</body>
</html>
