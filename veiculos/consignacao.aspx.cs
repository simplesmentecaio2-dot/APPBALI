using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows.Forms;
using System.Drawing;

public partial class veiculos_contrato : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //Veiculos ovec = new Veiculos();
        //string tabelaR; 
        //string tabelaVUR;
        //ovec.select_Tab_Consultadragon(out tabelaR);
        //ovec.select_Tab_ConsultaVUdragon(out tabelaVUR);

        //tabela = tabelaR;
        //tabelaVU = tabelaVUR ;


      
    }
    public string tabela;
    public string tabelaVU;

    protected void rbtnVU_CheckedChanged(object sender, EventArgs e)
    {
        if (rbtnVU.Checked == true)
        {
            lblEmpTrans.Text = "TRANSFERÊNCIA:";
            Panel1.Visible = true;
        }
    }
    protected void rbtnVN_CheckedChanged(object sender, EventArgs e)
    {
        if (rbtnVN.Checked == true)
        {
            lblEmpTrans.Text = "EMPLACAMENTO:";
            Panel1.Visible = true;
            
        }
    }
    protected void btnGravar_Click(object sender, EventArgs e)
    {

        if (rBtnModPagFinanciamento.Checked || rBtnModPagVista.Checked)
        {

            string modpag = "";
            string tipo = "";
            if (rBtnModPagVista.Checked)
            {
                modpag = "A";
            }
            if (rBtnModPagFinanciamento.Checked)
            {
                modpag = "F";
            }

            if (rbtnVN.Checked)
            {
                tipo = "VN";
            }
            if (rbtnVU.Checked)
            {
                tipo = "VU";
            }
            

            
            try
            {
            Veiculos vec = new Veiculos();
            string contrato = vec.insert_contrato_vendadragon(txtCliente.Text, txtEndereco.Text, txtCEP.Text, txtBairro.Text, txtCidade.Text,
                txtUF.Text, txtCPFCNPJ.Text, txtRGIE.Text, txtNascimento.Text, txtTelREsidencial.Text,
                txtTelCom.Text, txtCelular.Text, txtEmail.Text, txtMarca.Text, txtModelo.Text, txtCorExterna.Text,
                txtChassiPlaca.Text, txtAnoMod.Text, txtOpcionais.Text, modpag, txtFinanceira.Text, txtValoVeiculo.Text,
                txtEmplacamento.Text, txtEntrada.Text, txtFormasPagamento.Text,
                txtCarroUsado.Text, txtModMarca.Text, txtPlacaVU.Text,txtAnoModelo.Text, txtVlFinanciamento.Text,
                txtNrParcelas.Text, txtVlParcelas.Text, txtPlano.Text, txtCortesias.Text,
                txtObs.Text, txtPrevisao.Text, txtVendedor.Text, tipo, txtVlUtilzadoAvaliacao.Text, txtQuitacao.Text, txtSaldoAvaliacao.Text);

            if(tipo == "VN")
            {
            Response.Redirect("Print-ContratoVNdragon.aspx?contrato=" + contrato);
            }
            if (tipo == "VU")
            {
              Response.Redirect("Print-ContratoVUdragon.aspx?contrato=" + contrato);
            }
                }
            catch
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                   "alert('Preencha todos os campos corretamente!!');", true);
            }

        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                   "alert('Informe a modalidade de pagamento!');", true);
        
        }
    }
    protected void ibtnDadosCliente_Click(object sender, ImageClickEventArgs e)
    {
       try 
                      
           {
           Veiculos oVeiculos = new Veiculos();
           string total; string total2;
        oVeiculos.select_financiamento(txtValoVeiculo.Text, txtEntrada.Text, txtVlUtilzadoAvaliacao.Text,txtCarroUsado.Text,txtQuitacao.Text, out total, out total2);
        txtVlFinanciamento.Text = total;
        txtSaldoAvaliacao.Text = total2;
          }
         catch
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                   "alert('Informe os valores CORRETOS!!');", true);
        
        }
    }
    protected void calcula()
    {

     
        try
        {
            if (txtValoVeiculo.Text == "") { txtValoVeiculo.Text = "0"; }
            if (txtEntrada.Text == "") { txtEntrada.Text = "0"; }
            if (txtVlUtilzadoAvaliacao.Text == "") { txtVlUtilzadoAvaliacao.Text = "0"; }
            if (txtQuitacao.Text == "") { txtQuitacao.Text = "0"; }
            if (txtCarroUsado.Text == "") { txtCarroUsado.Text = "0"; }

            

            txtVlFinanciamento.Text = (Convert.ToDouble(txtValoVeiculo.Text) - Convert.ToDouble(txtEntrada.Text) - Convert.ToDouble(txtVlUtilzadoAvaliacao.Text)).ToString();
            txtSaldoAvaliacao.Text = (Convert.ToDouble(txtCarroUsado.Text) - Convert.ToDouble(txtVlUtilzadoAvaliacao.Text) - Convert.ToDouble(txtQuitacao.Text)).ToString();
        }
        catch (Exception)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                  "alert('Informe os valores CORRETOS!!');", true);
        }  

    }

    protected void txtCarroUsado_TextChanged(object sender, EventArgs e)
    {
        calcula();
    }
  protected void ImageButton1_Click(object sender, ImageClickEventArgs e)
    {

        


    }

  protected void btnEditareGravar_Click(object sender, EventArgs e)
  {



  
  }
      }



    


