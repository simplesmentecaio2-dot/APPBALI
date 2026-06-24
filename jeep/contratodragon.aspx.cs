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
        Veiculos ovec = new Veiculos();
        string tabelaR; 
        string tabelaVUR;
        ovec.select_Tab_Consultadragon(out tabelaR);
        ovec.select_Tab_ConsultaVUdragon(out tabelaVUR);

        tabela = tabelaR;
        tabelaVU = tabelaVUR ;


      
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

        string contrato = txtContrato.Text; string cliente; string endereco; string cep; string bairro; string cidade; string UF;
        string cpfcnpj; string RGIE; string nascimento; string tel_residencial; string tel_comercial;
        string tel_celular; string email; string marca; string modelo; string cor_ext; string chassiplaca;
        string anomodelo; string opcinonais; string modalidade_pagamento; string financeira; string valorveiculo;
        string emp_trans; string entrada; string formaspagamento; string carrousado; string modmarcavu;
        string palcavu; string financiamento; string qtdeparcelas; string vlparcelas; string planofinanciamento;
        string cortesias; string obs; string previsaoentrega; string vendedor; string tipo; string data; string multa; string vlutilizadoavaliacao; string vlquitacao; string vlsaldoavaliacao; string anomodeloVU;
        Veiculos vec = new Veiculos();
        vec.select_contrato_venda(contrato,
        out  cliente, out endereco, out cep, out bairro, out cidade
        , out UF, out cpfcnpj, out RGIE, out nascimento, out tel_residencial
        , out tel_comercial, out tel_celular, out email, out marca, out modelo
        , out cor_ext, out chassiplaca, out anomodelo, out opcinonais, out modalidade_pagamento
        , out financeira, out valorveiculo, out emp_trans, out entrada
        , out formaspagamento, out carrousado, out modmarcavu, out palcavu, out anomodeloVU, out financiamento
        , out qtdeparcelas, out vlparcelas, out planofinanciamento, out cortesias
        , out obs, out previsaoentrega, out vendedor, out tipo, out data, out multa, out vlutilizadoavaliacao, out vlquitacao, out vlsaldoavaliacao);

        txtEdCliente.Text = cliente; txtEdEndereco.Text = endereco; txtEdCep.Text = cep; txtEdBairro.Text = bairro; txtEdCidade.Text = cidade; txtEdUF.Text = UF; txtEdCPF.Text = cpfcnpj; txtEdRG.Text = RGIE; txtEdNascimento.Text = nascimento;
        txtEdTelRes.Text = tel_residencial; txtEdComercial.Text = tel_comercial; txtEdCelular.Text = tel_celular; txtEdEmail.Text = email; txtEdMarca.Text = marca; txtEdModelo.Text = modelo; txtEdCorExt.Text = cor_ext; txtEdChassi.Text = chassiplaca;
        txtEdAnomodelo.Text = anomodelo; txtEdOpcionais.Text = opcinonais; txtEdFinanceira.Text = financeira; txtEdValorVeic.Text = valorveiculo; txtEdTAXAS.Text = emp_trans; txtEdEntrada.Text = entrada; txtEdFormasPagamento.Text = formaspagamento;
        txtEdValorUSADO.Text = carrousado; txtEdModMarcaUSADO.Text = modmarcavu; txtEdAnoMOdUSADO.Text = modmarcavu; txtEdPlacaUSADO.Text = palcavu; txtEdFinanciamento.Text = financiamento; txtEdNumeroParcelas.Text = qtdeparcelas; txtEdValorParcela.Text = vlparcelas; txtEdPlanoFinanciamento.Text = planofinanciamento;
        txtEdCortesias.Text = cortesias; txtEdObs.Text = obs; txtEdPrevisao.Text = previsaoentrega; txtEdVendedor.Text = vendedor; txtEdVALORUSADOAVAILACAO.Text = vlutilizadoavaliacao; txtEdQuitacao.Text = vlquitacao; txtEdSaldoAvaliacao.Text = vlsaldoavaliacao; txtEdAnoMOdUSADO.Text = anomodeloVU;
        
     


    }

  protected void btnEditareGravar_Click(object sender, EventArgs e)
  {



      string modpag = "";
      string tipo = "";
       
      Veiculos vec = new Veiculos();
      string contrato = vec.update_contrato_venda(Convert.ToInt16(txtContrato.Text), txtEdCliente.Text, txtEdEndereco.Text, txtEdCep.Text, txtEdBairro.Text, txtEdCidade.Text,
                txtEdUF.Text, txtEdCPF.Text, txtEdRG.Text, txtEdNascimento.Text, txtEdTelRes.Text,
                txtEdComercial.Text, txtEdCelular.Text, txtEdEmail.Text, txtEdMarca.Text, txtEdModelo.Text, txtEdCorExt.Text,
                txtEdChassi.Text, txtEdAnomodelo.Text, txtEdOpcionais.Text, modpag, txtEdFinanceira.Text,Convert.ToString(txtEdSaldoAvaliacao.Text),
                txtEdTAXAS.Text, txtEdEntrada.Text, txtEdFormasPagamento.Text,
                txtEdValorUSADO.Text, txtEdModMarcaUSADO.Text, txtEdPlacaUSADO.Text, txtEdAnoMOdUSADO.Text, txtEdFinanciamento.Text,
                txtEdNumeroParcelas.Text, txtEdValorParcela.Text, txtEdPlanoFinanciamento.Text, txtEdCortesias.Text,
                txtEdObs.Text, txtEdPrevisao.Text, txtEdVendedor.Text,  txtEdVALORUSADOAVAILACAO.Text, txtEdQuitacao.Text, txtEdSaldoAvaliacao.Text);

     
          Response.Redirect("contrato.aspx" );
     
  }
      }



    


