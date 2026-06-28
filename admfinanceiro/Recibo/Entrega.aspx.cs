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
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                               "alert('Não existe autorização para este pedido!');", true);
        }

    }
}
