using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Reporting;
using Microsoft.Reporting.WebForms;
using Microsoft.ReportingServices;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Runtime.CompilerServices;


public partial class admfinanceiro_Comissao_comissao : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
   {
        if (Session["id"] == null)
        {
            Response.Redirect("../../Login.aspx?voltar=/admfinanceiro/Comissao/comissaoWF.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        lblUsuario.Text = ValorSessao("usuario", "-");
        lblTipo.Text = ValorSessao("usuario_codigo", ValorSessao("tipo", "-"));

        if (!IsPostBack)
        {
            PreencherDatasPadrao();
        }
    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtDtInicial, txtDtFinal, out dataInicial, out dataFinal)) return;
        gViewListarVendedores.DataBind();


    }
    protected void Button5_Click(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtDtinicialPrem, txtDtfinalPrem, out dataInicial, out dataFinal)) return;
        gViewListarVendedoresVD.DataBind();

    }

    protected void Button8_Click(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtDtinicialEmpl, txtDtfinalEmpl, out dataInicial, out dataFinal)) return;
        sqldsListarVendedoresEmplac.DataBind();
        gViewListarVendedoresEMPLACAMENTO.DataBind();
    }

    protected void Button6_Click(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtdtInicialPremiacao, txtdtFinalPremiacao, out dataInicial, out dataFinal)) return;
        sqldsListarVendedoresPremiacao.DataBind();
        gViewListarVendedoresPREMIACAO.DataBind();

    }
    protected void gViewListarVendedores_SelectedIndexChanged(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtDtInicial, txtDtFinal, out dataInicial, out dataFinal)) return;
        if (!GarantirLinhaSelecionada(gViewListarVendedores, "Selecione um vendedor na lista para calcular a comissão.")) return;

        try
        {
            lblLoja.Text = TextoCelula(gViewListarVendedores, 0);
            lblCodVend.Text = TextoCelula(gViewListarVendedores, 1);
            lblNomeVendedor.Text = TextoCelula(gViewListarVendedores, 2);

            double zero = 0;
            string qtdeVN, qtdeVU, comissaoVU, totalComissaoVN, totalLiquido, margemComissao, totalLb, qtdeEMPL, comissaoEMPL;
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_Tab_Comissao_VU(dataInicial, dataFinal, lblCodVend.Text, out tabelaVU, out qtdeVU, out comissaoVU);
            txtQtdeVU.Text = ValorInteiroTexto(qtdeVU);
            txtComissaoVU.Text = ValorDecimalTexto(comissaoVU);
            adm.select_Tab_Comissao_VN(dataInicial, dataFinal, lblCodVend.Text, out tabelaVN, out qtdeVN, Inteiro(qtdeVU), out totalComissaoVN, out totalLiquido, out margemComissao, out totalLb);
            txtQtdeTotal.Text = (Inteiro(qtdeVN) + Inteiro(qtdeVU)).ToString();
            txtQtdeVN.Text = ValorInteiroTexto(qtdeVN);
            txtLb2.Text = "0";

            adm.select_Tab_Comissao_EMPLACAMENTO(dataInicial, dataFinal, lblCodVend.Text, out tabelaEMPL, out qtdeEMPL, out comissaoEMPL);

            txtlb.Text = ValorDecimalTexto(comissaoEMPL);
            txtComissaoVN.Text = ValorDecimalTexto(totalComissaoVN);
            txtTotalLiquido.Text = ValorDecimalTexto(totalLiquido);
            txtQtdeVD.Text = zero.ToString();
            txtComissaoVD.Text = zero.ToString("N2");
            txtDif1.Text = zero.ToString("N2");

            string comissaoLB;
            int faixa;
            int qtde = Inteiro(qtdeVN) + Inteiro(qtdeVU);
            adm.CalcularComissaoLB(lblCodVend.Text, qtde, Numero(totalLb), lblNomeVendedor.Text, out comissaoLB, out faixa);
            SelecionarMargem(faixa);

            txtComissaoTotal.Text = (Numero(comissaoVU) + Numero(totalComissaoVN) + Numero(txtComissaoVD.Text)).ToString("N2");
        }
        catch (Exception ex)
        {
            RegistrarErro(ex, "Selecionar comissão geral");
            MostrarMensagem("Não foi possível calcular esta comissão agora. Confira o período e tente selecionar o vendedor novamente.");
        }
    }

    protected void gViewListarVendedores_SelectedIndexChangedVD(object sender, EventArgs e)
    {
        if (!GarantirLinhaSelecionada(gViewListarVendedoresVD, "Selecione um vendedor na lista de venda direta.")) return;

        lblLojaVD.Text = TextoCelula(gViewListarVendedoresVD, 0);
        lblcodVD.Text = TextoCelula(gViewListarVendedoresVD, 1);
        lblVendVD.Text = TextoCelula(gViewListarVendedoresVD, 2);
    }

    protected void gViewListarVendedores_SelectedIndexChangedEMPL(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtDtinicialEmpl, txtDtfinalEmpl, out dataInicial, out dataFinal)) return;
        if (!GarantirLinhaSelecionada(gViewListarVendedoresEMPLACAMENTO, "Selecione um vendedor na lista de emplacamento.")) return;

        try
        {
            lblLojaempl.Text = TextoCelula(gViewListarVendedoresEMPLACAMENTO, 0);
            lblCodempl.Text = TextoCelula(gViewListarVendedoresEMPLACAMENTO, 1);
            lblVendempl.Text = TextoCelula(gViewListarVendedoresEMPLACAMENTO, 2);
            string comissaoEMPL, qtdeEMPL;
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_Tab_Comissao_EMPLACAMENTO(dataInicial, dataFinal, lblCodempl.Text, out tabelaEMPL, out qtdeEMPL, out comissaoEMPL);

            txtEmplacamento.Text = ValorDecimalTexto(comissaoEMPL);
        }
        catch (Exception ex)
        {
            RegistrarErro(ex, "Selecionar emplacamento");
            MostrarMensagem("Não foi possível carregar o emplacamento deste vendedor. Confira o período e tente novamente.");
        }
    }

    protected void gViewListarVendedores_SelectedIndexChangedPREM(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtdtInicialPremiacao, txtdtFinalPremiacao, out dataInicial, out dataFinal)) return;
        if (!GarantirLinhaSelecionada(gViewListarVendedoresPREMIACAO, "Selecione um vendedor na lista de premiação.")) return;

        try
        {
            lblLojaPrem.Text = TextoCelula(gViewListarVendedoresPREMIACAO, 0);
            lblCodPrem.Text = TextoCelula(gViewListarVendedoresPREMIACAO, 1);
            lblVendedorPrem.Text = TextoCelula(gViewListarVendedoresPREMIACAO, 2);

            string premioprodutivo, premiometa, retorno, mvp, avulsos, chequebonus;
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dadosprem(dataInicial, dataFinal, lblCodPrem.Text, out premioprodutivo, out premiometa, out retorno, out chequebonus, out mvp, out avulsos);

            txtRetorno.Text = ValorDecimalTexto(retorno);
            txtCheque.Text = ValorDecimalTexto(chequebonus);
            txtPremioProd.Text = ValorDecimalTexto(premioprodutivo);
            txtPremioMeta.Text = ValorDecimalTexto(premiometa);
            txtmvp.Text = ValorDecimalTexto(mvp);
            txtavulsos.Text = ValorDecimalTexto(avulsos);
        }
        catch (Exception ex)
        {
            RegistrarErro(ex, "Selecionar premiação");
            MostrarMensagem("Não foi possível carregar a premiação deste vendedor. Confira o período e tente novamente.");
        }
    }
    public string tabelaVN;
    public string tabelaVU;
    public string tabelaEMPL;


    protected void ddlistMargem_SelectedIndexChanged(object sender, EventArgs e)
    {
        string faixa;
        faixa = ddlistMargem.SelectedValue.ToString();
        txtComissaoLB.Text = "0,00";
        if (!GarantirComissaoGeralCarregada()) return;

        double totalLiquido = Numero(txtTotalLiquido.Text);
        double comissaoVU = Numero(txtComissaoVU.Text);
        if (faixa == "0.4")
        {
            //txtComissaoLB.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 5 / 100).ToString("N2");
            txtComissaoVN.Text = (totalLiquido * 0.4 / 100).ToString("N2");
            txtComissaoTotal.Text = ((totalLiquido * 0.4 / 100) + comissaoVU).ToString("N2");
        }
        if (faixa == "0.5")
        {
            //txtComissaoLB.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 5 / 100).ToString("N2");
            txtComissaoVN.Text = (totalLiquido * 0.5 / 100).ToString("N2");
            txtComissaoTotal.Text = ((totalLiquido * 0.5 / 100) + comissaoVU).ToString("N2");
        }
        if (faixa == "0.6")
        {

            txtComissaoVN.Text = (totalLiquido * 0.6 / 100).ToString("N2");
            txtComissaoTotal.Text = ((totalLiquido * 0.6 / 100) + comissaoVU).ToString("N2");
        }


}
    protected void btnREcalcularTotal_Click(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtDtInicial, txtDtFinal, out dataInicial, out dataFinal)) return;
        if (!GarantirComissaoGeralCarregada()) return;
        NormalizarCamposComissaoGeral();

        string comissaoatual,dif;
        comissaoatual = txtQtdeVN.Text;
        double zero = 0;
        int qtdeVN = Inteiro(txtQtdeVN.Text);
        int qtdeVU = Inteiro(txtQtdeVU.Text);
        int qtdeVD = Inteiro(txtQtdeVD.Text);
        double totalLiquido = Numero(txtTotalLiquido.Text);
        double comissaoVU = Numero(txtComissaoVU.Text);
        double comissaoVD = Numero(txtComissaoVD.Text);

        //------------------------JEEP SAAN------------------------//

        if (qtdeVN + qtdeVD <= 4 && lblLoja.Text == "JEEP SAAN")
        {
            txtComissaoVN.Text = (totalLiquido * 0.4 / 100).ToString("N2");
            txtDif1.Text = zero.ToString("N2");
        }

        if (qtdeVN + qtdeVD <= 10 && qtdeVN + qtdeVD >= 5 && lblLoja.Text == "JEEP SAAN")
        {
            txtComissaoVN.Text = (totalLiquido * 0.5 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(dataInicial, dataFinal, lblCodVend.Text, qtdeVU, out dif);
            txtDif1.Text = dif;
        }

        if (qtdeVN + qtdeVD >= 11 && lblLoja.Text == "JEEP SAAN")
        {
            txtComissaoVN.Text = (totalLiquido * 0.6 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(dataInicial, dataFinal, lblCodVend.Text, qtdeVU, out dif);
            txtDif1.Text = dif;
        }

        //------------------------PARK SUL ------------------------//

        if (qtdeVN + qtdeVD <= 4 && lblLoja.Text == "PARK SUL")
        {
            txtComissaoVN.Text = (totalLiquido * 0.4 / 100).ToString("N2");
            txtDif1.Text = zero.ToString("N2");
        }

        if (qtdeVN + qtdeVD <= 10 && qtdeVN + qtdeVD >= 5 && lblLoja.Text == "PARK SUL")
        {
            txtComissaoVN.Text = (totalLiquido * 0.5 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(dataInicial, dataFinal, lblCodVend.Text, qtdeVU, out dif);
            txtDif1.Text = dif;
        }

        if (qtdeVN + qtdeVD >= 11 && lblLoja.Text == "PARK SUL")
        {
            txtComissaoVN.Text = (totalLiquido * 0.6 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(dataInicial, dataFinal, lblCodVend.Text, qtdeVU, out dif);
            txtDif1.Text = dif;
        }

        //------------------------BALI SIA------------------------//



        if (qtdeVN + qtdeVD <= 6 && lblLoja.Text == "FIAT SIA")
        {
            txtComissaoVN.Text = (totalLiquido * 0.4 / 100).ToString("N2");
            txtDif1.Text = zero.ToString("N2");
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }

        if (qtdeVN + qtdeVD >= 8 && lblLoja.Text == "FIAT SIA")
        {
            txtComissaoVN.Text = (totalLiquido * 0.5 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(dataInicial, dataFinal, lblCodVend.Text, qtdeVU, out dif);
            txtDif1.Text = dif;
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }

        //------------------------BALI SCIA------------------------//
        if (qtdeVN + qtdeVD < 7 && lblLoja.Text == "FIAT SCIA")
        {
            txtComissaoVN.Text = (totalLiquido * 0.4 / 100).ToString("N2");
            txtDif1.Text = zero.ToString("N2");
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }

        if (qtdeVN + qtdeVD >= 6 && lblLoja.Text == "FIAT SCIA")
        {
            txtComissaoVN.Text = (totalLiquido * 0.5 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(dataInicial, dataFinal, lblCodVend.Text, qtdeVU, out dif);
            txtDif1.Text = dif;
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }

        //------------------------BALI SAAN------------------------//

        if (qtdeVN + qtdeVD < 7 && lblLoja.Text == "FIAT SAAN")
        {
            txtComissaoVN.Text = (totalLiquido * 0.4 / 100).ToString("N2");
            txtDif1.Text = zero.ToString("N2");
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }

        if (qtdeVN + qtdeVD >= 8 && lblLoja.Text == "FIAT SAAN")
        {
            txtComissaoVN.Text = (totalLiquido * 0.5 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(dataInicial, dataFinal, lblCodVend.Text, qtdeVU, out dif);
            txtDif1.Text = dif;
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }
        
        txtQtdeTotal.Text = (qtdeVN + qtdeVU + qtdeVD).ToString();
        txtComissaoTotal.Text = (Numero(txtComissaoVN.Text) + comissaoVU + comissaoVD).ToString("N2");
        
    }
    protected void btnSalvar_Click(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtDtInicial, txtDtFinal, out dataInicial, out dataFinal)) return;
        if (!GarantirComissaoGeralCarregada()) return;
        NormalizarCamposComissaoGeral();

        try
        {

            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.insert_comissao(lblCodVend.Text, lblLoja.Text, lblNomeVendedor.Text, dataInicial, dataFinal,
                              Inteiro(txtQtdeTotal.Text), Numero(txtComissaoVU.Text), Numero(txtComissaoVN.Text), Numero(txtComissaoTotal.Text), Numero(txtComissaoVD.Text), Numero(txtDif1.Text), ddlistMargem.SelectedItem.Text, Numero(txtlb.Text));

            sqldsListarVendedores.DataBind();
            gViewListarVendedores.DataBind();
            lblCodVend.Text = "";
            lblNomeVendedor.Text = "";
            txtQtdeTotal.Text = "";
            txtQtdeVN.Text = "";
            txtQtdeVU.Text = "";
            txtComissaoVU.Text = "";
            txtComissaoVN.Text = "";
            txtComissaoTotal.Text = "";
            txtComissaoVD.Text = "";
            txtDif1.Text = "";
            txtLb2.Text = "";
            txtlb.Text = "";
            txtTotalLiquido.Text = "";
            MostrarMensagem("Comissão salva com sucesso.");
           
        }
        catch (Exception ex)
        {
            RegistrarErro(ex, "Salvar comissão geral");
            sqldsListarVendedores.DataBind();
            gViewListarVendedores.DataBind();
            MostrarMensagem("Comissão já cadastrada ou não foi possível salvar. Confira o período e o vendedor.");
        }
    }

    protected void btnSalvarVD_Click(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtDtinicialPrem, txtDtfinalPrem, out dataInicial, out dataFinal)) return;
        if (String.IsNullOrWhiteSpace(lblcodVD.Text))
        {
            MostrarMensagem("Selecione um vendedor antes de salvar a comissão de venda direta.");
            return;
        }

        try
        {

            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.update_comissao(dataInicial, dataFinal, lblcodVD.Text, lblLojaVD.Text,
            lblVendVD.Text, Numero(txtcomissaoVD2.Text));
            sqldsListarVendedoresPrem.DataBind();
            gViewListarVendedoresVD.DataBind();
            lblcodVD.Text = "";
            lblVendVD.Text = "";
            lblLojaVD.Text = "";
            txtcomissaoVD2.Text = "";
            MostrarMensagem("Comissão salva com sucesso.");
           
        }
        catch (Exception ex)
        {
            RegistrarErro(ex, "Salvar venda direta");
            sqldsListarVendedoresPrem.DataBind();
            gViewListarVendedoresVD.DataBind();
            MostrarMensagem("Comissão já cadastrada ou não foi possível salvar. Confira o período e o vendedor.");
        }

       
    }
    protected void btnSalvarEmpl_Click(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtDtinicialEmpl, txtDtfinalEmpl, out dataInicial, out dataFinal)) return;
        if (String.IsNullOrWhiteSpace(lblCodempl.Text))
        {
            MostrarMensagem("Selecione um vendedor antes de salvar o emplacamento.");
            return;
        }

        try
        {

            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.update_comissaoEMPL(dataInicial, dataFinal, lblCodempl.Text, lblLojaempl.Text,
            lblVendempl.Text, Numero(txtEmplacamento.Text));
            sqldsListarVendedoresEmplac.DataBind();
            gViewListarVendedoresEMPLACAMENTO.DataBind();
            txtEmplacamento.Text = "";
            
            MostrarMensagem("Emplacamento salvo com sucesso.");

        }
        catch (Exception ex)
        {
            RegistrarErro(ex, "Salvar emplacamento");
            sqldsListarVendedoresEmplac.DataBind();
            gViewListarVendedoresEMPLACAMENTO.DataBind();
            MostrarMensagem("Emplacamento já cadastrado ou não foi possível salvar. Confira o período e o vendedor.");
        }


    }

    protected void btnSalvarPREM_Click(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodo(txtdtInicialPremiacao, txtdtFinalPremiacao, out dataInicial, out dataFinal)) return;
        if (String.IsNullOrWhiteSpace(lblCodPrem.Text))
        {
            MostrarMensagem("Selecione um vendedor antes de salvar a premiação.");
            return;
        }

        try
        {

            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.update_comissaoPREM(dataInicial, dataFinal, lblCodPrem.Text,
                                lblVendedorPrem.Text, Numero(txtPremioProd.Text), Numero(txtPremioMeta.Text), Numero(txtRetorno.Text), Numero(txtCheque.Text),
                                Numero(txtmvp.Text), Numero(txtavulsos.Text), lblLojaPrem.Text);
            gViewListarVendedoresPREMIACAO.DataBind();
            sqldsListarVendedoresPremiacao.DataBind();
            lblCodPrem.Text = "";
            lblVendedorPrem.Text = "";
            lblLojaPrem.Text = "";
            MostrarMensagem("Premiação salva com sucesso.");

        }
        catch (Exception ex)
        {
            RegistrarErro(ex, "Salvar premiação");
            sqldsListarVendedoresPremiacao.DataBind();
            gViewListarVendedoresPREMIACAO.DataBind();
            MostrarMensagem("Premiação já cadastrada ou não foi possível salvar. Confira o período e o vendedor.");
        }


    }
    //protected void btnListar_Click(object sender, EventArgs e)
    //{
    //    dlComissao.DataBind();

    //    lblDtInicio.Text = txtDtinicialListar.Text;
    //    lblDtFinal.Text = txtDtinicialListar.Text;
    //    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
    //                                                                       "mostraresconderDiv('#title-rel');", true);
    //}


    protected void Button2_Click(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodoMaximo(TextBox1, TextBox2, 62, "O relatório de comissões", out dataInicial, out dataFinal)) return;

        try
        {
            string inicial = dataInicial.ToString("dd/MM/yyyy");
            string final = dataFinal.ToString("dd/MM/yyyy");
            ReportViewer1.LocalReport.ReportPath = @"admfinanceiro\Comissao\Report2.rdlc";
            ReportViewer1.LocalReport.DisplayName = "Comissoes_" + dataInicial.ToString("yyyyMMdd") + "_" + dataFinal.ToString("yyyyMMdd");
            sqldsComissaoRV.SelectParameters["dtInicial"].DefaultValue = inicial;
            sqldsComissaoRV.SelectParameters["dtFinal"].DefaultValue = final;
            ReportViewer1.LocalReport.Refresh();
            lblRelatorioComissaoStatus.Text = "Gerado de " + inicial + " a " + final;
        }
        catch (Exception ex)
        {
            RegistrarErro(ex, "Gerar relatório de comissões");
            lblRelatorioComissaoStatus.Text = "Não foi possível gerar agora";
            MostrarMensagem("Não foi possível gerar o relatório de comissões agora. Confira o período e tente novamente.");
        }
    }


    protected void Button3_Click(object sender, EventArgs e)
    {
        DateTime dataInicial, dataFinal;
        if (!ValidarPeriodoMaximo(TextBox5, TextBox6, 62, "O relatório de premiações", out dataInicial, out dataFinal)) return;

        try
        {
            string inicial = dataInicial.ToString("dd/MM/yyyy");
            string final = dataFinal.ToString("dd/MM/yyyy");
            ReportViewer2.LocalReport.ReportPath = @"admfinanceiro\Comissao\Report3.rdlc";
            ReportViewer2.LocalReport.DisplayName = "Premiacoes_" + dataInicial.ToString("yyyyMMdd") + "_" + dataFinal.ToString("yyyyMMdd");
            sqldsComissaoRV2.SelectParameters["dtInicial"].DefaultValue = inicial;
            sqldsComissaoRV2.SelectParameters["dtFinal"].DefaultValue = final;
            ReportViewer2.LocalReport.Refresh();
            lblRelatorioPremiacaoStatus.Text = "Gerado de " + inicial + " a " + final;
        }
        catch (Exception ex)
        {
            RegistrarErro(ex, "Gerar relatório de premiações");
            lblRelatorioPremiacaoStatus.Text = "Não foi possível gerar agora";
            MostrarMensagem("Não foi possível gerar o relatório de premiações agora. Confira o período e tente novamente.");
        }
    }

    private void PreencherDatasPadrao()
    {
        DateTime hoje = DateTime.Today;
        DateTime inicioMes = new DateTime(hoje.Year, hoje.Month, 1);
        string inicial = inicioMes.ToString("dd/MM/yyyy");
        string final = hoje.ToString("dd/MM/yyyy");

        DefinirDataSeVazia(txtDtInicial, inicial);
        DefinirDataSeVazia(txtDtFinal, final);
        DefinirDataSeVazia(txtDtinicialPrem, inicial);
        DefinirDataSeVazia(txtDtfinalPrem, final);
        DefinirDataSeVazia(txtDtinicialEmpl, inicial);
        DefinirDataSeVazia(txtDtfinalEmpl, final);
        DefinirDataSeVazia(txtdtInicialPremiacao, inicial);
        DefinirDataSeVazia(txtdtFinalPremiacao, final);
        DefinirDataSeVazia(TextBox1, inicial);
        DefinirDataSeVazia(TextBox2, final);
        DefinirDataSeVazia(TextBox3, inicial);
        DefinirDataSeVazia(TextBox4, final);
        DefinirDataSeVazia(TextBox5, inicial);
        DefinirDataSeVazia(TextBox6, final);
    }

    private void DefinirDataSeVazia(TextBox campo, string valor)
    {
        if (campo != null && String.IsNullOrWhiteSpace(campo.Text))
        {
            campo.Text = valor;
        }
    }

    private bool ValidarPeriodo(TextBox campoInicial, TextBox campoFinal, out DateTime dataInicial, out DateTime dataFinal)
    {
        dataInicial = DateTime.MinValue;
        dataFinal = DateTime.MinValue;

        if (!TentarData(campoInicial == null ? "" : campoInicial.Text, out dataInicial))
        {
            MostrarMensagem("Informe uma data inicial válida no formato dd/mm/aaaa.");
            if (campoInicial != null) campoInicial.Focus();
            return false;
        }

        if (!TentarData(campoFinal == null ? "" : campoFinal.Text, out dataFinal))
        {
            MostrarMensagem("Informe uma data final válida no formato dd/mm/aaaa.");
            if (campoFinal != null) campoFinal.Focus();
            return false;
        }

        if (dataInicial > dataFinal)
        {
            MostrarMensagem("A data inicial não pode ser maior que a data final.");
            if (campoInicial != null) campoInicial.Focus();
            return false;
        }

        if (campoInicial != null) campoInicial.Text = dataInicial.ToString("dd/MM/yyyy");
        if (campoFinal != null) campoFinal.Text = dataFinal.ToString("dd/MM/yyyy");
        return true;
    }

    private bool TentarData(string texto, out DateTime data)
    {
        texto = (texto ?? "").Trim();
        CultureInfo cultura = CultureInfo.GetCultureInfo("pt-BR");
        return DateTime.TryParseExact(texto, "dd/MM/yyyy", cultura, DateTimeStyles.None, out data)
            || DateTime.TryParse(texto, cultura, DateTimeStyles.None, out data);
    }

    private bool ValidarPeriodoMaximo(TextBox campoInicial, TextBox campoFinal, int diasMaximos, string nomeRotina, out DateTime dataInicial, out DateTime dataFinal)
    {
        if (!ValidarPeriodo(campoInicial, campoFinal, out dataInicial, out dataFinal)) return false;

        int dias = (dataFinal.Date - dataInicial.Date).Days + 1;
        if (dias > diasMaximos)
        {
            MostrarMensagem((nomeRotina ?? "Este relatório") + " permite no máximo " + diasMaximos.ToString(CultureInfo.InvariantCulture) + " dias por geração. Reduza o período para manter a tela rápida.");
            if (campoInicial != null) campoInicial.Focus();
            return false;
        }

        return true;
    }

    private bool GarantirLinhaSelecionada(GridView grid, string mensagem)
    {
        if (grid == null || grid.SelectedRow == null)
        {
            MostrarMensagem(mensagem);
            return false;
        }

        return true;
    }

    private string TextoCelula(GridView grid, int indice)
    {
        if (grid == null || grid.SelectedRow == null || grid.SelectedRow.Cells.Count <= indice) return "";
        return HttpUtility.HtmlDecode(grid.SelectedRow.Cells[indice].Text ?? "").Replace("&nbsp;", "").Trim();
    }

    private bool GarantirComissaoGeralCarregada()
    {
        if (String.IsNullOrWhiteSpace(lblCodVend.Text))
        {
            MostrarMensagem("Selecione um vendedor na aba Comissão antes de recalcular ou salvar.");
            return false;
        }

        return true;
    }

    private void NormalizarCamposComissaoGeral()
    {
        txtQtdeVN.Text = ValorInteiroTexto(txtQtdeVN.Text);
        txtQtdeVU.Text = ValorInteiroTexto(txtQtdeVU.Text);
        txtQtdeVD.Text = ValorInteiroTexto(txtQtdeVD.Text);
        txtQtdeTotal.Text = ValorInteiroTexto(txtQtdeTotal.Text);
        txtComissaoVN.Text = ValorDecimalTexto(txtComissaoVN.Text);
        txtComissaoVU.Text = ValorDecimalTexto(txtComissaoVU.Text);
        txtComissaoVD.Text = ValorDecimalTexto(txtComissaoVD.Text);
        txtComissaoTotal.Text = ValorDecimalTexto(txtComissaoTotal.Text);
        txtTotalLiquido.Text = ValorDecimalTexto(txtTotalLiquido.Text);
        txtDif1.Text = ValorDecimalTexto(txtDif1.Text);
        txtlb.Text = ValorDecimalTexto(txtlb.Text);
        txtLb2.Text = ValorDecimalTexto(txtLb2.Text);
    }

    private double Numero(TextBox campo)
    {
        return campo == null ? 0 : Numero(campo.Text);
    }

    private double Numero(string valor)
    {
        valor = (valor ?? "").Trim();
        if (valor.Length == 0) return 0;

        valor = valor.Replace("R$", "").Replace("%", "").Trim();
        CultureInfo cultura = CultureInfo.GetCultureInfo("pt-BR");
        double numero;
        if (Double.TryParse(valor, NumberStyles.Any, cultura, out numero)) return numero;

        string normalizado = valor.Replace(".", "").Replace(",", ".");
        if (Double.TryParse(normalizado, NumberStyles.Any, CultureInfo.InvariantCulture, out numero)) return numero;

        return 0;
    }

    private int Inteiro(string valor)
    {
        return Convert.ToInt32(Math.Round(Numero(valor), 0));
    }

    private string ValorDecimalTexto(string valor)
    {
        return Numero(valor).ToString("N2");
    }

    private string ValorInteiroTexto(string valor)
    {
        return Inteiro(valor).ToString();
    }

    private void SelecionarMargem(int faixa)
    {
        string valor = faixa.ToString(CultureInfo.InvariantCulture);
        if (faixa > 1)
        {
            valor = "0." + valor;
        }

        if (ddlistMargem.Items.FindByValue(valor) != null)
        {
            ddlistMargem.SelectedValue = valor;
        }
    }

    private string ValorSessao(string chave, string padrao)
    {
        if (Session[chave] == null) return padrao;
        string valor = Convert.ToString(Session[chave]).Trim();
        return valor.Length == 0 ? padrao : valor;
    }

    private void RegistrarErro(Exception ex, string contexto)
    {
        try
        {
            string pasta = Server.MapPath("~/App_Data/logs");
            Directory.CreateDirectory(pasta);
            string arquivo = Path.Combine(pasta, "comissao-wf-erros.log");
            string usuario = ValorSessao("login", "sem-login");
            string codigo = ValorSessao("codigo_usuario", ValorSessao("usuariocodigo", "sem-codigo"));
            string ip = Request.UserHostAddress ?? "";
            string mensagem = String.Format(CultureInfo.InvariantCulture,
                "{0:yyyy-MM-dd HH:mm:ss};usuario={1};codigo={2};ip={3};contexto={4};erro={5};stack={6}{7}",
                DateTime.Now,
                usuario.Replace(";", ","),
                codigo.Replace(";", ","),
                ip.Replace(";", ","),
                (contexto ?? "").Replace(";", ","),
                (ex == null ? "" : ex.Message).Replace(";", ",").Replace(Environment.NewLine, " "),
                (ex == null ? "" : ex.ToString()).Replace(Environment.NewLine, " "),
                Environment.NewLine);

            File.AppendAllText(arquivo, mensagem);
        }
        catch
        {
            // Nunca deixa uma falha no log quebrar a tela operacional.
        }
    }

    private void MostrarMensagem(string mensagem)
    {
        string texto = HttpUtility.JavaScriptStringEncode(mensagem ?? "");
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"),
            "if(window.BaliComissao&&window.BaliComissao.toast){window.BaliComissao.toast('" + texto + "');}else{alert('" + texto + "');}", true);
    }


}
