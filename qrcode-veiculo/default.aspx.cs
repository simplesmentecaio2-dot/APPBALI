using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Text;
using System.Web;
using QRCoder;

public partial class qrcode_veiculo_default : System.Web.UI.Page
{
    private static readonly CultureInfo CulturaBrasil = new CultureInfo("pt-BR");

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UsuarioLogado())
        {
            Response.Redirect("../login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        lblUsuario.Text = Convert.ToString(Session["usuario"]);
        lblCodigo.Text = Session["usuario_codigo"] == null ? "-" : Convert.ToString(Session["usuario_codigo"]);
    }

    protected void btnGerar_Click(object sender, EventArgs e)
    {
        string busca = NormalizarBusca(txtBusca.Text);
        if (busca.Length < 3)
        {
            ExibirMensagem("Informe uma placa ou chassi v\u00e1lido para gerar o QR Code.", true);
            pnlResultado.Visible = false;
            return;
        }

        try
        {
            VeiculoQrDados veiculo = ConsultarVeiculo(busca);
            if (veiculo == null)
            {
                ExibirMensagem("Nenhum ve\u00edculo encontrado no estoque para a placa ou chassi informado.", true);
                pnlResultado.Visible = false;
                return;
            }

            string identificador = !String.IsNullOrWhiteSpace(veiculo.Chassi) ? veiculo.Chassi : veiculo.Placa;
            string consultaUrl = MontarUrlConsulta(identificador);
            RenderizarResultado(veiculo, consultaUrl);
            ExibirMensagem("QR Code gerado com sucesso. Confira a pr\u00e9via antes de imprimir.", false);
        }
        catch (Exception ex)
        {
            ExibirMensagem("N\u00e3o foi poss\u00edvel gerar o QR Code agora. Detalhe t\u00e9cnico: " + HttpUtility.HtmlEncode(ex.Message), true);
            pnlResultado.Visible = false;
        }
    }

    private bool UsuarioLogado()
    {
        return Session["id"] != null || Session["usuario"] != null;
    }

    private void RenderizarResultado(VeiculoQrDados veiculo, string consultaUrl)
    {
        pnlResultado.Visible = true;
        imgQrCode.ImageUrl = GerarImagemQrCode(consultaUrl);
        lnkConsulta.NavigateUrl = consultaUrl;
        txtLinkGerado.Text = consultaUrl;

        lblPrintModelo.Text = Texto(veiculo.Fabricante + " " + veiculo.Modelo);
        lblPrintIdentificador.Text = Texto("Placa " + ValorOuTraco(veiculo.Placa) + " | Chassi " + ValorOuTraco(veiculo.Chassi));

        lblLoja.Text = Texto(veiculo.Loja);
        lblFabricante.Text = Texto(veiculo.Fabricante);
        lblModelo.Text = Texto(veiculo.Modelo);
        lblAno.Text = Texto(veiculo.AnoModelo);
        lblPlaca.Text = Texto(ValorOuTraco(veiculo.Placa));
        lblChassi.Text = Texto(ValorOuTraco(veiculo.Chassi));
        lblCor.Text = Texto(veiculo.Cor);
        lblValor.Text = Texto(FormatarValor(veiculo.ValorPromocao, veiculo.ValorVendaNormal));
    }

    private string GerarImagemQrCode(string url)
    {
        QRCodeGenerator qrGenerator = new QRCodeGenerator();
        QRCodeGenerator.QRCode qrCode = qrGenerator.CreateQrCode(url, QRCodeGenerator.ECCLevel.Q);

        using (Bitmap bitmap = qrCode.GetGraphic(18))
        {
            using (MemoryStream stream = new MemoryStream())
            {
                bitmap.Save(stream, System.Drawing.Imaging.ImageFormat.Png);
                return "data:image/png;base64," + Convert.ToBase64String(stream.ToArray());
            }
        }
    }

    private string MontarUrlConsulta(string identificador)
    {
        return "https://app.bali.com.br/qrcode-veiculo/consulta.aspx?v=" + HttpUtility.UrlEncode(identificador ?? "");
    }

    private VeiculoQrDados ConsultarVeiculo(string buscaNormalizada)
    {
        string connectionString = ConfigurationManager.ConnectionStrings["GrupoBali_DealernetWFConnectionString"].ConnectionString;
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            using (SqlCommand command = new SqlCommand(QueryVeiculo(), connection))
            {
                command.CommandType = CommandType.Text;
                command.CommandTimeout = 60;
                command.Parameters.Add("@busca", SqlDbType.VarChar, 40).Value = buscaNormalizada;

                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        return null;
                    }

                    return MapearVeiculo(reader);
                }
            }
        }
    }

    private VeiculoQrDados MapearVeiculo(SqlDataReader reader)
    {
        return new VeiculoQrDados
        {
            Loja = LerTexto(reader, "Loja"),
            Estoque = LerTexto(reader, "Estoque_Descricao"),
            Fabricante = LerTexto(reader, "Fabricante"),
            Modelo = LerTexto(reader, "Modelo"),
            Km = LerDecimal(reader, "KM"),
            Combustivel = LerTexto(reader, "Comb"),
            DataEntrada = LerTexto(reader, "Data_Ent"),
            NotaFiscal = LerTexto(reader, "Nota_Fiscal"),
            AnoModelo = LerTexto(reader, "Ano_Mod"),
            CodigoVeiculo = LerTexto(reader, "Veiculo_Codigo"),
            Placa = LerTexto(reader, "Placa"),
            Chassi = LerTexto(reader, "Chassi"),
            Renavam = LerTexto(reader, "Renavam"),
            Cor = LerTexto(reader, "Cor"),
            ValorVendaNormal = LerDecimal(reader, "Valor_Venda_Normal"),
            ValorPromocao = LerDecimal(reader, "Valor_Promocao")
        };
    }

    private string QueryVeiculo()
    {
        return @"
SELECT TOP 1
    CASE VecEst.VeiculoEstoque_EmpresaCod
        WHEN '01' THEN 'JEEP SAAN'
        WHEN '02' THEN 'PARK SUL'
        WHEN '03' THEN 'BALI BYD'
        WHEN '04' THEN 'RAM'
        WHEN '05' THEN 'FIAT SIA'
        WHEN '06' THEN 'FIAT SCIA'
        WHEN '07' THEN 'FIAT SAAN'
    END AS Loja,
    dbo.Estoque.Estoque_Descricao,
    Marca_Descricao AS Fabricante,
    ModeloVeiculo_Descricao AS Modelo,
    Veiculo.Veiculo_Km AS KM,
    Combustivel_Descricao AS Comb,
    CONVERT(CHAR(10), NFCompra.NotaFiscal_DataMovimento, 103) AS Data_Ent,
    NFCompra.NotaFiscal_Numero AS Nota_Fiscal,
    VeiculoAno.VeiculoAno_Exibicao AS Ano_Mod,
    dbo.Veiculo.Veiculo_Codigo AS Veiculo_Codigo,
    ISNULL(Veiculo.Veiculo_Placa, '') AS Placa,
    Veiculo.Veiculo_Chassi AS Chassi,
    Veiculo.Veiculo_NroRenavam AS Renavam,
    Cor.Cor_Descricao AS Cor,
    COALESCE(PrecoEmpresa.ModeloVeiculoPrecoEmpresa_ValorVenda, PrecoGeral.ModeloVeiculoPreco_ValorVenda, 0) AS Valor_Venda_Normal,
    COALESCE(Promo.VeiculoPromocao_Valor, PrecoEmpresa.ModeloVeiculoPrecoEmpresa_ValorVenda, PrecoGeral.ModeloVeiculoPreco_ValorVenda, 0) AS Valor_Promocao
FROM dbo.fn_EstoqueVeiculos(GETDATE()) VecEst
JOIN dbo.Estoque ON dbo.Estoque.Estoque_Codigo = VecEst.VeiculoEstoque_EstoqueCod
JOIN dbo.Veiculo ON dbo.Veiculo.Veiculo_Codigo = VecEst.VeiculoEstoque_VeiculoCod
JOIN dbo.Cor ON dbo.Cor.Cor_Codigo = dbo.Veiculo.Veiculo_CorCodExterna
JOIN dbo.FamiliaVeiculo ON dbo.FamiliaVeiculo.FamiliaVeiculo_Codigo = VecEst.VeiculoEstoque_FamiliaVeiculoCod
JOIN dbo.ModeloVeiculo ON dbo.ModeloVeiculo.ModeloVeiculo_Codigo = dbo.Veiculo.Veiculo_ModeloVeiculoCod
JOIN dbo.Combustivel ON dbo.Combustivel.Combustivel_Codigo = dbo.ModeloVeiculo.ModeloVeiculo_CombustivelCod
JOIN dbo.VeiculoAno ON dbo.VeiculoAno.VeiculoAno_Codigo = dbo.Veiculo.VeiculoAno_Codigo
JOIN dbo.Marca ON dbo.Marca.Marca_Codigo = dbo.ModeloVeiculo.ModeloVeiculo_MarcaCod
JOIN dbo.NotaFiscalItem NFICompra
    ON NFICompra.NotaFiscal_Codigo = VecEst.VeiculoEstoque_NotaFiscalCodCompra
   AND NFICompra.NotaFiscalItem_VeiculoCod = VecEst.VeiculoEstoque_VeiculoCod
JOIN dbo.NotaFiscal NFCompra ON NFCompra.NotaFiscal_Codigo = NFICompra.NotaFiscal_Codigo
OUTER APPLY (
    SELECT TOP 1 MVPE.ModeloVeiculoPrecoEmpresa_ValorVenda
    FROM dbo.ModeloVeiculoPrecoEmpresa MVPE WITH (NOLOCK)
    WHERE MVPE.ModeloVeiculo_Codigo = dbo.Veiculo.Veiculo_ModeloVeiculoCod
      AND MVPE.ModeloVeiculoPrecoEmpresa_EmpresaCod = VecEst.VeiculoEstoque_EmpresaCod
      AND MVPE.ModeloVeiculoPrecoEmpresa_AnoModelo = VeiculoAno.VeiculoAno_Modelo
      AND MVPE.ModeloVeiculoPrecoEmpresa_Data <= GETDATE()
      AND MVPE.ModeloVeiculoPrecoEmpresa_ValorVenda <> 0
    ORDER BY MVPE.ModeloVeiculoPrecoEmpresa_Data DESC
) PrecoEmpresa
OUTER APPLY (
    SELECT TOP 1 MVP.ModeloVeiculoPreco_ValorVenda
    FROM dbo.ModeloVeiculoPreco MVP WITH (NOLOCK)
    WHERE MVP.ModeloVeiculo_Codigo = dbo.Veiculo.Veiculo_ModeloVeiculoCod
      AND MVP.ModeloVeiculoPreco_AnoModelo = VeiculoAno.VeiculoAno_Modelo
      AND MVP.ModeloVeiculoPreco_Data <= GETDATE()
      AND MVP.ModeloVeiculoPreco_ValorVenda <> 0
    ORDER BY MVP.ModeloVeiculoPreco_Data DESC
) PrecoGeral
OUTER APPLY (
    SELECT TOP 1
        VP.VeiculoPromocao_Codigo,
        VP.VeiculoPromocao_Valor,
        VP.VeiculoPromocao_DataInicial,
        VP.VeiculoPromocao_DataFinal,
        VP.VeiculoPromocao_Status
    FROM dbo.VeiculoPromocao VP WITH (NOLOCK)
    WHERE VP.VeiculoPromocao_Status = 'AUT'
      AND VP.VeiculoPromocao_DataInicial <= GETDATE()
      AND VP.VeiculoPromocao_DataFinal >= GETDATE()
      AND VP.VeiculoPromocao_VeiculoCod = dbo.Veiculo.Veiculo_Codigo
    ORDER BY VP.VeiculoPromocao_DataInicial DESC, VP.VeiculoPromocao_Codigo DESC
) Promo
WHERE VecEst.Transito = 0
  AND (
        UPPER(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(Veiculo.Veiculo_Chassi, ''), ' ', ''), '-', ''), '.', ''), '/', '')) = @busca
        OR UPPER(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(Veiculo.Veiculo_Placa, ''), ' ', ''), '-', ''), '.', ''), '/', '')) = @busca
      )
ORDER BY VecEst.VeiculoEstoque_EmpresaCod, dbo.Veiculo.Veiculo_Codigo DESC";
    }

    private string NormalizarBusca(string valor)
    {
        StringBuilder texto = new StringBuilder();
        foreach (char caractere in (valor ?? "").ToUpperInvariant())
        {
            if (Char.IsLetterOrDigit(caractere))
            {
                texto.Append(caractere);
            }
        }

        return texto.ToString();
    }

    private string LerTexto(SqlDataReader reader, string coluna)
    {
        object valor = reader[coluna];
        return valor == DBNull.Value ? "" : Convert.ToString(valor).Trim();
    }

    private decimal LerDecimal(SqlDataReader reader, string coluna)
    {
        object valor = reader[coluna];
        if (valor == DBNull.Value) return 0M;
        return Convert.ToDecimal(valor, CulturaBrasil);
    }

    private string FormatarValor(decimal valorPromocao, decimal valorNormal)
    {
        decimal valor = valorPromocao > 0 ? valorPromocao : valorNormal;
        return valor > 0 ? valor.ToString("C", CulturaBrasil) : "Consulte a loja";
    }

    private string ValorOuTraco(string valor)
    {
        return String.IsNullOrWhiteSpace(valor) ? "-" : valor.Trim();
    }

    private string Texto(string valor)
    {
        return ValorOuTraco(valor);
    }

    private void ExibirMensagem(string mensagem, bool erro)
    {
        string classe = erro ? "qr-message is-error" : "qr-message is-success";
        litMensagem.Text = "<div class=\"" + classe + "\">" + mensagem + "</div>";
    }

    private class VeiculoQrDados
    {
        public string Loja { get; set; }
        public string Estoque { get; set; }
        public string Fabricante { get; set; }
        public string Modelo { get; set; }
        public decimal Km { get; set; }
        public string Combustivel { get; set; }
        public string DataEntrada { get; set; }
        public string NotaFiscal { get; set; }
        public string AnoModelo { get; set; }
        public string CodigoVeiculo { get; set; }
        public string Placa { get; set; }
        public string Chassi { get; set; }
        public string Renavam { get; set; }
        public string Cor { get; set; }
        public decimal ValorVendaNormal { get; set; }
        public decimal ValorPromocao { get; set; }
    }
}
