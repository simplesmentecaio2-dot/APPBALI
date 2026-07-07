using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class admfinanceiro_Recibo_Entrega : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["usuario"] != null)
        {
            lblUsuario.Text = Session["usuario"].ToString();
            lblTipo.Text = Session["usuario_codigo"] == null ? "-" : Session["usuario_codigo"].ToString();
        }

        //if (Session["id"] != null)
        //{
        //    lblUsuario.Text = Session["usuario"].ToString();
        //    lblTipo.Text = Session["tipo"].ToString();


        //}
        //else
        //{
        //    Response.Redirect("../../Login.aspx");
        //}

    }
    protected void btnGerar_Click(object sender, EventArgs e)
    {
        long pedidoNumero;
        int lojaNumero;
        if (String.IsNullOrWhiteSpace(txtpedido.Text) || String.IsNullOrWhiteSpace(txtLoja.Text) ||
            !long.TryParse(txtpedido.Text.Trim(), out pedidoNumero) || !int.TryParse(txtLoja.Text.Trim(), out lojaNumero) ||
            txtpedido.Text.Trim().Length > 12 || txtLoja.Text.Trim().Length > 3)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "entregaValidacao",
                                                               "if (window.baliUtilityFeedback) { window.baliUtilityFeedback('Informe pedido e loja usando apenas números.', 'error'); } else { alert('Informe pedido e loja usando apenas números.'); }", true);
            return;
        }

    try
        {
        if (txtpedido.Text != "")
           {

            Jeep oJeep = new Jeep();

            string cliente,chassi,placa,cor,vendedor,veiculo,pendencias,banco,observacao;
            double valor;

                oJeep.select_dadosentrega_jeep(txtpedido.Text, txtLoja.Text, out cliente, out chassi,
                out placa, out cor, out vendedor,out veiculo, out pendencias, out valor,
                out banco, out observacao);

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
           }
         }
  catch
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "entregaNaoEncontrada",
                                                               "if (window.baliUtilityFeedback) { window.baliUtilityFeedback('Autorização de entrega não encontrada para esse pedido e loja.', 'error'); } else { alert('Autorização de entrega não encontrada.'); }", true);
        }

    }
}
