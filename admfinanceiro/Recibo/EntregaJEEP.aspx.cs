using System;
using System.Globalization;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class admfinanceiro_Recibo_Entrega : System.Web.UI.Page
{
    private decimal totalServicosAdicionais;
    private decimal totalPendencias;

    protected void Page_Load(object sender, EventArgs e)
    {
        PreencherDataAtual();

        if (Session["usuario"] != null)
        {
            lblUsuario.Text = Session["usuario"].ToString();
            lblTipo.Text = Session["usuario_codigo"] == null ? "-" : Session["usuario_codigo"].ToString();
        }
    }

    private void PreencherDataAtual()
    {
        string dataAtual = EntregaVeiculoHelper.DataAtual();
        lblDataGerencia.Text = dataAtual;
        lblDataPortaria.Text = dataAtual;
        lblDataFinal.Text = dataAtual;
    }

    private void LimparDocumento()
    {
        lblCliente.Text = "";
        lblClienteEntreg.Text = "";
        lblVeiculo.Text = "";
        lblVeiculoEntreg.Text = "";
        lblChassi.Text = "";
        lblChassiEntreg.Text = "";
        lblPlaca.Text = "";
        lblCor.Text = "";
        lblVendedor.Text = "";
        lblVendedorEntreg.Text = "";
        lblPedidoPrint.Text = "";
        lblLojaPrint.Text = "";
    }

    protected void btnLimpar_Click(object sender, EventArgs e)
    {
        txtpedido.Text = "";
        txtLoja.Text = "";
        LimparDocumento();
        EntregaVeiculoHelper.Feedback(this, "entregaLimpa", "Consulta limpa. Informe pedido e loja para gerar uma nova prévia.", "info");
    }

    protected void btnGerar_Click(object sender, EventArgs e)
    {
        string pedido;
        string loja;
        string mensagem;
        string marca = EntregaVeiculoHelper.MarcaDaPagina(Request);

        if (!EntregaVeiculoHelper.TryValidateConsulta(txtpedido.Text, txtLoja.Text, out pedido, out loja, out mensagem))
        {
            LimparDocumento();
            EntregaVeiculoHelper.RegistrarEventoServidor(Context, "validacao", marca, pedido, loja, mensagem);
            EntregaVeiculoHelper.Feedback(this, "entregaValidacao", mensagem, "error");
            return;
        }

        txtpedido.Text = pedido;
        txtLoja.Text = loja;
        lblPedidoPrint.Text = pedido;
        lblLojaPrint.Text = loja;

        try
        {
            Jeep oJeep = new Jeep();

            string cliente, chassi, placa, cor, vendedor, veiculo, pendencias, banco, observacao;
            double valor;

            oJeep.select_dadosentrega_jeep(txtpedido.Text, txtLoja.Text, out cliente, out chassi,
                out placa, out cor, out vendedor, out veiculo, out pendencias, out valor,
                out banco, out observacao);

            if (String.IsNullOrWhiteSpace(cliente) && String.IsNullOrWhiteSpace(veiculo) && String.IsNullOrWhiteSpace(chassi))
            {
                throw new InvalidOperationException("Pedido sem dados retornados.");
            }

            lblCliente.Text = cliente;
            lblClienteEntreg.Text = cliente;
            lblVeiculo.Text = veiculo;
            lblVeiculoEntreg.Text = veiculo;
            lblChassi.Text = chassi;
            lblChassiEntreg.Text = chassi;
            lblPlaca.Text = placa;
            lblCor.Text = cor;
            lblVendedor.Text = vendedor;
            lblVendedorEntreg.Text = vendedor;

            EntregaVeiculoHelper.RegistrarEventoServidor(Context, "consulta_ok", marca, pedido, loja, "Prévia carregada.");
        }
        catch (Exception ex)
        {
            LimparDocumento();
            EntregaVeiculoHelper.RegistrarEventoServidor(Context, "consulta_erro", marca, pedido, loja, ex.Message);
            EntregaVeiculoHelper.Feedback(this, "entregaNaoEncontrada", "Pedido não encontrado para essa loja. Confira o número do pedido e o código da loja.", "error");
        }
    }

    protected void GridView2_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        AplicarTotalTabela(e, ref totalServicosAdicionais, 3);
    }

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        AplicarTotalTabela(e, ref totalPendencias, 5);
    }

    private void AplicarTotalTabela(GridViewRowEventArgs e, ref decimal total, int quantidadeColunas)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {
            total = 0m;
            return;
        }

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            total += ValorMonetario(DataBinder.Eval(e.Row.DataItem, "Valor"));
            return;
        }

        if (e.Row.RowType != DataControlRowType.Footer) return;

        e.Row.CssClass = "delivery-total-row";
        if (e.Row.Cells.Count < quantidadeColunas) return;

        e.Row.Cells[0].Text = "Total";
        e.Row.Cells[1].Text = FormatarMoeda(total);
        for (int i = 2; i < e.Row.Cells.Count; i++)
        {
            e.Row.Cells[i].Text = "";
        }
    }

    private decimal ValorMonetario(object valor)
    {
        if (valor == null || valor == DBNull.Value) return 0m;

        if (valor is decimal) return (decimal)valor;
        if (valor is double || valor is float || valor is int || valor is long)
        {
            return Convert.ToDecimal(valor, CultureInfo.InvariantCulture);
        }

        string texto = Convert.ToString(valor).Trim();
        if (String.IsNullOrWhiteSpace(texto)) return 0m;

        string limpo = "";
        foreach (char caractere in texto)
        {
            if (Char.IsDigit(caractere) || caractere == ',' || caractere == '.' || caractere == '-')
            {
                limpo += caractere;
            }
        }

        decimal resultado;
        if (limpo.Contains(","))
        {
            limpo = limpo.Replace(".", "").Replace(",", ".");
        }

        return Decimal.TryParse(limpo, NumberStyles.Number, CultureInfo.InvariantCulture, out resultado) ? resultado : 0m;
    }

    private string FormatarMoeda(decimal valor)
    {
        return valor.ToString("C", new CultureInfo("pt-BR"));
    }
}
