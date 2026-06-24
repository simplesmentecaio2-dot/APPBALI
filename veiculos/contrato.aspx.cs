using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows.Forms;
using System.Drawing;
using System.Data.SqlClient;
using System.Data;

public partial class veiculos_contrato : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["usuario"] == null || Session["usuario"].ToString().Equals(""))
        {
            Response.Redirect("./loginAppcontrato.aspx");
        }
        else
        {
            lblUsuario.Text = Session["usuario"].ToString();
        }
        if (txtDtFinalVU.Text.Length == 0 && txtDtInicialVU.Text.Length == 0)
        {
            txtDtInicialVU.Text = DateTime.Now.AddDays(-2).ToShortDateString();
            txtDtFinalVU.Text = DateTime.Now.ToShortDateString();
        }
        if (txtDtFinalVN.Text.Length == 0 && txtDtInicialVN.Text.Length == 0)
        {
            txtDtInicialVN.Text = DateTime.Now.AddDays(-2).ToShortDateString();
            txtDtFinalVN.Text = DateTime.Now.ToShortDateString();
        }
        if (txtDtFinalVD.Text.Length == 0 && txtDtInicialVD.Text.Length == 0)
        {
            txtDtInicialVD.Text = DateTime.Now.AddDays(-2).ToShortDateString();
            txtDtFinalVD.Text = DateTime.Now.ToShortDateString();
        }



    }
    public string tabela;
    public string tabelaVU;
    public string tabelaVD;

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
    protected void rbtnVD_CheckedChanged(object sender, EventArgs e)
    {
        if (rbtnVD.Checked == true)
        {
            lblEmpTrans.Text = "EMPLACAMENTO:";
            Panel1.Visible = true;

        }
    }
    protected void btnGravar_Click(object sender, EventArgs e)
    {
        calcula();

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
            if (rbtnVD.Checked)
            {
                tipo = "VD";
            }


            try
            {
                Veiculos vec = new Veiculos();
                string obs;
                string codigo;
                insert_contrato_venda
                (
                    txtCliente.Text, txtEndereco.Text, txtCEP.Text, txtBairro.Text, txtCidade.Text,
                    txtUF.Text, txtCPFCNPJ.Text, txtRGIE.Text, txtNascimento.Text, txtTelREsidencial.Text,
                    txtTelCom.Text, txtCelular.Text, txtEmail.Text, txtMarca.Text, txtModelo.Text, txtCorExterna.Text,
                    txtChassiPlaca.Text, txtAnoMod.Text, txtOpcionais.Text, modpag, txtFinanceira.Text, txtValoVeiculo.Text,
                    txtEmplacamento.Text, txtEntrada.Text, txtFormasPagamento.Text,
                    txtCarroUsado.Text, txtModMarca.Text, txtPlacaVU.Text, txtAnoModelo.Text, txtVlFinanciamento.Text,
                    txtNrParcelas.Text, txtVlParcelas.Text, txtPlano.Text, txtCortesias.Text,
                    txtObs.Text, txtPrevisao.Text, ddlVendedor.Text, tipo, txtVlUtilzadoAvaliacao.Text, txtQuitacao.Text, txtSaldoAvaliacao.Text, out codigo, out obs
                );
                if (obs.Equals("S"))
                {
                    if (tipo == "VN")
                    {
                        Response.Redirect("Print-ContratoVN.aspx?contrato=" + codigo);
                    }
                    else if (tipo == "VU")
                    {
                        Response.Redirect("Print-ContratoVU.aspx?contrato=" + codigo);
                    }
                    else if (tipo == "VD")
                    {
                        Response.Redirect("Print-ContratoVD.aspx?contrato=" + codigo);
                    }
                }
                else if (obs.Equals("N") && codigo != null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Duplicidade! O contrato já existe. Código: " + codigo + "');", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Preencha todos os campos corretamente!!1');", true);
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Preencha todos os campos corretamente!!2');", true);
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
            oVeiculos.select_financiamento(txtValoVeiculo.Text, txtEntrada.Text, txtVlUtilzadoAvaliacao.Text, txtCarroUsado.Text, txtQuitacao.Text, out total, out total2);
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
            if (txtEdValorVeic.Text == "") { txtEdValorVeic.Text = "0"; }
            if (txtEdEntrada.Text == "") { txtEdEntrada.Text = "0"; }
            if (txtEdVALORUSADOAVAILACAO.Text == "") { txtEdVALORUSADOAVAILACAO.Text = "0"; }
            if (txtEdValorUSADO.Text == "") { txtEdValorUSADO.Text = "0"; }
            if (txtEdQuitacao.Text == "") { txtEdQuitacao.Text = "0"; }



            txtVlFinanciamento.Text = (Convert.ToDouble(txtValoVeiculo.Text) - Convert.ToDouble(txtEntrada.Text) - Convert.ToDouble(txtVlUtilzadoAvaliacao.Text)).ToString();
            txtSaldoAvaliacao.Text = (Convert.ToDouble(txtCarroUsado.Text) - Convert.ToDouble(txtVlUtilzadoAvaliacao.Text) - Convert.ToDouble(txtQuitacao.Text)).ToString();
            txtEdFinanciamento.Text = (Convert.ToDouble(txtEdValorVeic.Text) - Convert.ToDouble(txtEdEntrada.Text) - Convert.ToDouble(txtEdVALORUSADOAVAILACAO.Text)).ToString();
            txtEdSaldoAvaliacao.Text = (Convert.ToDouble(txtEdValorUSADO.Text) - Convert.ToDouble(txtEdVALORUSADOAVAILACAO.Text) - Convert.ToDouble(txtEdQuitacao.Text)).ToString();
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
        vec.select_contrato_venda2(contrato,
        out cliente, out endereco, out cep, out bairro, out cidade
        , out UF, out cpfcnpj, out RGIE, out nascimento, out tel_residencial
        , out tel_comercial, out tel_celular, out email, out marca, out modelo
        , out cor_ext, out chassiplaca, out anomodelo, out opcinonais, out modalidade_pagamento
        , out financeira, out valorveiculo, out emp_trans, out entrada
        , out formaspagamento, out carrousado, out modmarcavu, out palcavu, out anomodeloVU, out financiamento
        , out qtdeparcelas, out vlparcelas, out planofinanciamento, out cortesias
        , out obs, out previsaoentrega, out vendedor, out tipo, out data, out multa, out vlutilizadoavaliacao, out vlquitacao, out vlsaldoavaliacao);

        txtEdCliente.Text = cliente; txtEdEndereco.Text = endereco; txtEdCep.Text = cep; txtEdBairro.Text = bairro; txtEdCidade.Text = cidade; txtEdUF.Text = UF; txtEdCPF.Text = cpfcnpj; txtEdRG.Text = RGIE; txtEdNascimento.Text = nascimento;
        txtEdTelRes.Text = tel_residencial; txtEdComercial.Text = tel_comercial; txtEdCelular.Text = tel_celular; txtEdEmail.Text = email; txtEdMarca.Text = marca; txtEdModelo.Text = modelo; txtEdCorExt.Text = cor_ext; txtEdChassi.Text = chassiplaca;
        txtAnoModelo.Text = anomodelo; txtEdOpcionais.Text = opcinonais; txtEdFinanceira.Text = financeira; txtEdValorVeic.Text = valorveiculo; txtEdTAXAS.Text = emp_trans; txtEdEntrada.Text = entrada; txtEdFormasPagamento.Text = formaspagamento;
        txtEdValorUSADO.Text = carrousado; txtEdAnoMOdUSADO.Text = modmarcavu; txtEdPlacaUSADO.Text = palcavu; txtEdFinanciamento.Text = financiamento; txtEdNumeroParcelas.Text = qtdeparcelas; txtEdValorParcela.Text = vlparcelas; txtEdPlanoFinanciamento.Text = planofinanciamento;
        txtEdCortesias.Text = cortesias; txtEdObs.Text = obs; txtEdPrevisao.Text = previsaoentrega; txtEdVendedor.Text = vendedor; txtEdVALORUSADOAVAILACAO.Text = vlutilizadoavaliacao; txtEdQuitacao.Text = vlquitacao; txtEdSaldoAvaliacao.Text = vlsaldoavaliacao; txtEdAnoMOdUSADO.Text = anomodeloVU;

    }

    protected void btnEditareGravar_Click(object sender, EventArgs e)
    {

        try
        {
            calcula();
            string modpag = "";
            if (rbtnEdAVISTA.Checked)
            {
                modpag = "A";
            }
            if (rbtnEdAprazo.Checked)
            {
                modpag = "F";
            }
           

            Veiculos vec = new Veiculos();
            string contrato = vec.update_contrato_venda(Convert.ToInt32(txtContrato.Text), txtEdCliente.Text, txtEdEndereco.Text, txtEdCep.Text, txtEdBairro.Text, txtEdCidade.Text,
                txtEdUF.Text, txtEdCPF.Text, txtEdRG.Text, txtEdNascimento.Text, txtEdTelRes.Text,
                txtEdComercial.Text, txtEdCelular.Text, txtEdEmail.Text, txtEdMarca.Text, txtEdModelo.Text, txtEdCorExt.Text,
                txtEdChassi.Text, txtEdAnomodelo.Text, txtEdOpcionais.Text, modpag, txtEdFinanceira.Text, Convert.ToString(txtEdValorVeic.Text),
                txtEdTAXAS.Text, txtEdEntrada.Text, txtEdFormasPagamento.Text,
                txtEdValorUSADO.Text, txtEdModMarcaUSADO.Text, txtEdPlacaUSADO.Text, txtEdAnoMOdUSADO.Text, txtEdFinanciamento.Text,
                txtEdNumeroParcelas.Text, txtEdValorParcela.Text, txtEdPlanoFinanciamento.Text, txtEdCortesias.Text,
                txtEdObs.Text, txtEdPrevisao.Text, txtEdVendedor.Text, txtEdVALORUSADOAVAILACAO.Text, txtEdQuitacao.Text, txtEdSaldoAvaliacao.Text);

            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                      "alert('Contrato Alterado');", true);



        }

        catch (Exception)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                  "alert('Informe os valores CORRETOS!!');", true);
        }

    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        string tabelaR;
        select_Tab_Consulta(txtDtInicialVN.Text,txtDtFinalVN.Text, out tabelaR);
        tabela = tabelaR;
    }
    protected void Button2_Click(object sender, EventArgs e)
    {
        string tabelaVUR;

        select_Tab_ConsultaVU(txtDtInicialVU.Text,txtDtFinalVU.Text, out tabelaVUR);

        tabelaVU = tabelaVUR;
    }
    protected void ButtonVD_Click(object sender, EventArgs e)
    {
        string tabelaVDR;
        select_Tab_ConsultaVD(txtDtInicialVD.Text, txtDtFinalVD.Text, out tabelaVDR);

        tabelaVD = tabelaVDR;
    }






    public void insert_contrato_venda
        (
              string cliente
            , string endereco
            , string cep
            , string bairro
            , string cidade
            , string UF
            , string cpfcnpj
            , string RGIE
            , string nascimento
            , string tel_residencial
            , string tel_comercial
            , string tel_celular
            , string email
            , string marca
            , string modelo
            , string cor_ext
            , string chassiplaca
            , string anomodelo
            , string opcinonais
            , string modalidade_pagamento
            , string financeira
            , string valorveiculo
            , string emp_trans
            , string entrada
            , string formaspagamento
            , string carrousado
            , string modmarcavu
            , string palcavu
            , string anomodeloVU
            , string financiamento
            , string qtdeparcelas
            , string vlparcelas
            , string planofinanciamento
            , string cortesias
            , string obs
            , string previsaoentrega
            , string vendedor
            , string tipo
            , string vlutilizadoavaliacao
            , string vlquitacao
            , string vlsaldoavaliacao
            , out string codigoResponse
            , out string obsResponse
        )
    {
        codigoResponse = "";
        obsResponse = "N";

        Veiculos vec = new Veiculos();
        if (valorveiculo == "") { valorveiculo = "0"; }
        if (emp_trans == "") { emp_trans = "0"; }
        if (entrada == "") { entrada = "0"; }
        if (carrousado == "") { carrousado = "0"; }
        if (financiamento == "") { financiamento = "0"; }
        if (vlparcelas == "") { vlparcelas = "0"; }
        try
        {
            vec.Conexao();

            SqlCommand oCmd = new SqlCommand();
            oCmd.Connection = vec.oCon;
            oCmd.CommandText = "APP..veiculos_insert_contrato_venda";
            oCmd.CommandType = CommandType.StoredProcedure;
            oCmd.Parameters.Add("@cliente", SqlDbType.VarChar).Value = cliente;
            oCmd.Parameters.Add("@endereco", SqlDbType.VarChar).Value = endereco;
            oCmd.Parameters.Add("@cep", SqlDbType.VarChar).Value = cep;
            oCmd.Parameters.Add("@bairro", SqlDbType.VarChar).Value = bairro;
            oCmd.Parameters.Add("@cidade", SqlDbType.VarChar).Value = cidade;
            oCmd.Parameters.Add("@UF", SqlDbType.VarChar).Value = UF;
            oCmd.Parameters.Add("@cpfcnpj", SqlDbType.VarChar).Value = cpfcnpj;
            oCmd.Parameters.Add("@RGIE", SqlDbType.VarChar).Value = RGIE;
            oCmd.Parameters.Add("@nascimento", SqlDbType.VarChar).Value = nascimento;
            oCmd.Parameters.Add("@tel_residencial", SqlDbType.VarChar).Value = tel_residencial;
            oCmd.Parameters.Add("@tel_comercial", SqlDbType.VarChar).Value = tel_comercial;
            oCmd.Parameters.Add("@tel_celular", SqlDbType.VarChar).Value = tel_celular;
            oCmd.Parameters.Add("@email", SqlDbType.VarChar).Value = email;
            oCmd.Parameters.Add("@marca", SqlDbType.VarChar).Value = marca;
            oCmd.Parameters.Add("@modelo", SqlDbType.VarChar).Value = modelo;
            oCmd.Parameters.Add("@cor_ext", SqlDbType.VarChar).Value = cor_ext;
            oCmd.Parameters.Add("@chassiplaca", SqlDbType.VarChar).Value = chassiplaca;
            oCmd.Parameters.Add("@anomodelo", SqlDbType.VarChar).Value = anomodelo;
            oCmd.Parameters.Add("@opcinonais", SqlDbType.VarChar).Value = opcinonais;
            oCmd.Parameters.Add("@modalidade_pagamento", SqlDbType.VarChar).Value = modalidade_pagamento;
            oCmd.Parameters.Add("@financeira", SqlDbType.VarChar).Value = financeira;
            oCmd.Parameters.Add("@valorveiculo", SqlDbType.Float).Value = Convert.ToDouble(valorveiculo);
            oCmd.Parameters.Add("@emp_trans", SqlDbType.Float).Value = Convert.ToDouble(emp_trans);
            oCmd.Parameters.Add("@entrada", SqlDbType.Float).Value = Convert.ToDouble(entrada);
            oCmd.Parameters.Add("@formaspagamento", SqlDbType.VarChar).Value = formaspagamento;
            oCmd.Parameters.Add("@carrousado", SqlDbType.Float).Value = Convert.ToDouble(carrousado);
            oCmd.Parameters.Add("@modmarcavu", SqlDbType.VarChar).Value = modmarcavu;
            oCmd.Parameters.Add("@palcavu", SqlDbType.VarChar).Value = palcavu;
            oCmd.Parameters.Add("@anomodeloVU", SqlDbType.VarChar).Value = anomodeloVU;
            oCmd.Parameters.Add("@financiamento", SqlDbType.Float).Value = Convert.ToDouble(financiamento);
            oCmd.Parameters.Add("@qtdeparcelas", SqlDbType.VarChar).Value = qtdeparcelas;
            oCmd.Parameters.Add("@vlparcelas", SqlDbType.Float).Value = Convert.ToDouble(vlparcelas);
            oCmd.Parameters.Add("@planofinanciamento", SqlDbType.VarChar).Value = planofinanciamento;
            oCmd.Parameters.Add("@cortesias", SqlDbType.VarChar).Value = cortesias;
            oCmd.Parameters.Add("@obs", SqlDbType.VarChar).Value = obs;
            oCmd.Parameters.Add("@previsaoentrega", SqlDbType.VarChar).Value = previsaoentrega;
            oCmd.Parameters.Add("@vendedor", SqlDbType.VarChar).Value = vendedor;
            oCmd.Parameters.Add("@tipo", SqlDbType.VarChar).Value = tipo;
            oCmd.Parameters.Add("@vlutilizadoavaliacao", SqlDbType.Float).Value = Convert.ToDouble(vlutilizadoavaliacao);
            oCmd.Parameters.Add("@vlquitacao", SqlDbType.Float).Value = Convert.ToDouble(vlquitacao);
            oCmd.Parameters.Add("@vlsaldoavaliacao", SqlDbType.Float).Value = Convert.ToDouble(vlsaldoavaliacao);

            SqlDataReader odr = oCmd.ExecuteReader();
            odr.Read();
            codigoResponse = odr["id"].ToString();
            obsResponse = odr["obs"].ToString();
        }
        catch
        {
            obsResponse = "E";
        }
        finally
        {
            vec.FecharConexao();
        }
    }
    public void select_Tab_ConsultaVU(string dtInicio, string dtFim, out string tabelaVU)
    {
        Veiculos vec = new Veiculos();
        vec.Conexao();

        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = "APP..veiculos_select_tab_consultaVU";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@dtInicio", SqlDbType.Date).Value = dtInicio;
        oCmd.Parameters.Add("@dtFim", SqlDbType.Date).Value = dtFim;
        SqlDataReader odr = oCmd.ExecuteReader();
        string head = @"<table cellpadding='0' cellspacing='0' border='0' id='tblConsultaProcesso2' class='display' style='font-family:arial;'>
                        <thead >
                            <tr>
                                <td style='text-align:center; font-size:12px;'>ID</td>
                                <td style='text-align:center; font-size:12px;'>Cliente</td>
                                <td style='text-align:center; font-size:12px;'>CPF</td>                                
                                <td style='text-align:center; font-size:12px;'>Telefone1</td>
                                <td style='text-align:center; font-size:12px;'>Telefone2</td>
                                <td style='text-align:center; font-size:12px;'>Telefone3</td>
                                <td style='text-align:center; font-size:12px;'>email</td>
                                <td style='text-align:center; font-size:12px;'>vendedor</td>
                                </tr>
                        </thead>";
        string body = "<tbody>";
        // a quantidade de colunas(tfoot) deve se a mesma quantidade de colunas da tabela do banco.
        string foot = @"</tbody></table>";
        while (odr.Read())
        {
            body = body + @"<tr> 
                           <td style='text-align:center; font-size:12px;'>" + odr["id"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cliente"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cpfcnpj"].ToString() +                          
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_residencial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_comercial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_celular"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["email"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["vendedor"].ToString() +
                           "</td></tr>";
        }

        tabelaVU = head + body + foot;
        vec.FecharConexao();
    }

    public void select_Tab_ConsultaVD(string dtInicio, string dtFim, out string tabelaVU)
    {
        Veiculos vec = new Veiculos();
        vec.Conexao();

        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = "APP..veiculos_select_tab_consulta_vd";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@dtInicio", SqlDbType.Date).Value = dtInicio;
        oCmd.Parameters.Add("@dtFim", SqlDbType.Date).Value = dtFim;
        SqlDataReader odr = oCmd.ExecuteReader();
        string head = @"<table cellpadding='0' cellspacing='0' border='0' id='tblConsultaProcesso2' class='display' style='font-family:arial;'>
                        <thead >
                            <tr>
                                <td style='text-align:center; font-size:12px;'>ID</td>
                                <td style='text-align:center; font-size:12px;'>Cliente</td>
                                <td style='text-align:center; font-size:12px;'>CPF</td>                                
                                <td style='text-align:center; font-size:12px;'>Telefone1</td>
                                <td style='text-align:center; font-size:12px;'>Telefone2</td>
                                <td style='text-align:center; font-size:12px;'>Telefone3</td>
                                <td style='text-align:center; font-size:12px;'>email</td>
                                <td style='text-align:center; font-size:12px;'>vendedor</td>
                                </tr>
                        </thead>";
        string body = "<tbody>";
        // a quantidade de colunas(tfoot) deve se a mesma quantidade de colunas da tabela do banco.
        string foot = @"</tbody></table>";
        while (odr.Read())
        {
            body = body + @"<tr> 
                           <td style='text-align:center; font-size:12px;'>" + odr["id"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cliente"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cpfcnpj"].ToString() +                           
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_residencial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_comercial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_celular"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["email"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["vendedor"].ToString() +
                           "</td></tr>";
        }

        tabelaVU = head + body + foot;
        vec.FecharConexao();
    }
    public void select_Tab_Consulta(string dtInicio, string dtFim,out string tabela)
    {
        Veiculos vec = new Veiculos();
        vec.Conexao();

        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = vec.oCon;
        oCmd.CommandText = "APP..veiculos_select_tab_consulta";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@dtInicio", SqlDbType.Date).Value = dtInicio;
        oCmd.Parameters.Add("@dtFim", SqlDbType.Date).Value = dtFim;
        SqlDataReader odr = oCmd.ExecuteReader();
        string head = @"<table cellpadding='0' cellspacing='0' border='0' id='tblConsultaProcesso' class='display' style='font-family:arial;'>
                        <thead >
                            <tr>
                                <td style='text-align:center; font-size:12px;'>ID</td>
                                <td style='text-align:center; font-size:12px;'>Cliente</td>
                                <td style='text-align:center; font-size:12px;'>CPF</td>                                
                                <td style='text-align:center; font-size:12px;'>Telefone1</td>
                                <td style='text-align:center; font-size:12px;'>Telefone2</td>
                                <td style='text-align:center; font-size:12px;'>Telefone3</td>
                                <td style='text-align:center; font-size:12px;'>email</td>
                                <td style='text-align:center; font-size:12px;'>vendedor</td>                               
                                </tr>
                        </thead>";
        string body = "<tbody>";
        // a quantidade de colunas(tfoot) deve se a mesma quantidade de colunas da tabela do banco.
        string foot = @"</tbody></table>";
        while (odr.Read())
        {
            //valor = Convert.ToDouble(odr["Valor"]);
            //<span title="<%# Eval("Numero") %>" onclick="consultaChamadoAberto(this)"><%# Eval("Numero") %></span>
            body = body + @"<tr> 
                           <td style='text-align:center; font-size:12px;'>" + odr["id"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cliente"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["cpfcnpj"].ToString() +                           
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_residencial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_comercial"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["tel_celular"].ToString() +
                           "</td><td style='text-align:center; font-size:12px;'>" + odr["email"].ToString() +
                          "</td><td style='text-align:center; font-size:12px;'>" + odr["vendedor"].ToString() +
                           "</td></tr>";
        }

        tabela = head + body + foot;
        vec.FecharConexao();
    }



}


