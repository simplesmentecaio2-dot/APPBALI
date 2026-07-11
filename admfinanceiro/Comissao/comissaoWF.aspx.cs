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
        gViewListarVendedores.DataBind();
     

    }
    protected void Button5_Click(object sender, EventArgs e)
    {
        gViewListarVendedoresVD.DataBind();

    }

    protected void Button8_Click(object sender, EventArgs e)
    {
        sqldsListarVendedoresEmplac.DataBind();
        gViewListarVendedoresEMPLACAMENTO.DataBind();
    }

    protected void Button6_Click(object sender, EventArgs e)
    {
        sqldsListarVendedoresPrem.DataBind();
        gViewListarVendedoresPREMIACAO.DataBind();

    }
    protected void gViewListarVendedores_SelectedIndexChanged(object sender, EventArgs e)
    {

        lblLoja.Text = gViewListarVendedores.SelectedRow.Cells[0].Text;
        lblCodVend.Text = gViewListarVendedores.SelectedRow.Cells[1].Text;
        lblNomeVendedor.Text = gViewListarVendedores.SelectedRow.Cells[2].Text;
        
        double zero = 0;
        string qtdeVN, qtdeVU, comissaoVU, totalComissaoVN, totalLiquido, margemComissao, totalLb,qtdeEMPL,comissaoEMPL; 
        AdmFinanceiroWF adm = new AdmFinanceiroWF();
        adm.select_Tab_Comissao_VU(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), gViewListarVendedores.SelectedRow.Cells[1].Text, out tabelaVU, out qtdeVU, out comissaoVU);
        txtQtdeVU.Text = qtdeVU;
        txtComissaoVU.Text = comissaoVU;
        adm.select_Tab_Comissao_VN(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), gViewListarVendedores.SelectedRow.Cells[1].Text, out tabelaVN, out qtdeVN, Convert.ToInt16(qtdeVU), out totalComissaoVN, out totalLiquido, out margemComissao, out totalLb);
        txtQtdeTotal.Text = (Convert.ToInt16(qtdeVN) + Convert.ToInt16(qtdeVU)).ToString();
        txtQtdeVN.Text = qtdeVN;
        txtLb2.Text = "0";

        adm.select_Tab_Comissao_EMPLACAMENTO(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), gViewListarVendedores.SelectedRow.Cells[1].Text, out tabelaEMPL, out qtdeEMPL, out comissaoEMPL);

        txtlb.Text = comissaoEMPL;
        txtComissaoVN.Text = totalComissaoVN;

        
        txtTotalLiquido.Text = totalLiquido;
        txtQtdeVD.Text = zero.ToString();
        txtComissaoVD.Text = zero.ToString("N2");
        txtDif1.Text = zero.ToString("N2");


        string comissaoLB;
        int faixa;
        int qtde = Convert.ToInt32(qtdeVN) + Convert.ToInt32(qtdeVU);
        adm.CalcularComissaoLB(gViewListarVendedores.SelectedRow.Cells[1].Text, qtde, Convert.ToDouble(totalLb), gViewListarVendedores.SelectedRow.Cells[2].Text, out comissaoLB, out faixa);
        ddlistMargem.SelectedValue = faixa.ToString();

        
        txtComissaoTotal.Text = (Convert.ToDouble(comissaoVU) + Convert.ToDouble(totalComissaoVN) + Convert.ToDouble(txtComissaoVD.Text)).ToString("N2");

        //ddlistMargem.SelectedValue = margemComissao;
        //adm.CalcularComissaoLB(conver
        
    }

    protected void gViewListarVendedores_SelectedIndexChangedVD(object sender, EventArgs e)
    {

        lblLojaVD.Text = gViewListarVendedoresVD.SelectedRow.Cells[0].Text;
        lblcodVD.Text = gViewListarVendedoresVD.SelectedRow.Cells[1].Text;
        lblVendVD.Text = gViewListarVendedoresVD.SelectedRow.Cells[2].Text;

      

    }

    protected void gViewListarVendedores_SelectedIndexChangedEMPL(object sender, EventArgs e)
    {

        lblLojaempl.Text = gViewListarVendedoresEMPLACAMENTO.SelectedRow.Cells[0].Text;
        lblCodempl.Text = gViewListarVendedoresEMPLACAMENTO.SelectedRow.Cells[1].Text;
         lblVendempl.Text = gViewListarVendedoresEMPLACAMENTO.SelectedRow.Cells[2].Text;
        string comissaoEMPL, qtdeEMPL;
        AdmFinanceiroWF adm = new AdmFinanceiroWF();
        adm.select_Tab_Comissao_EMPLACAMENTO(Convert.ToDateTime(txtDtinicialEmpl.Text), Convert.ToDateTime(txtDtfinalEmpl.Text),
            gViewListarVendedoresEMPLACAMENTO.SelectedRow.Cells[1].Text, out tabelaEMPL, out qtdeEMPL, out comissaoEMPL);
   
        txtEmplacamento.Text = comissaoEMPL;

    }

    protected void gViewListarVendedores_SelectedIndexChangedPREM(object sender, EventArgs e)
    {

        lblLojaPrem.Text = gViewListarVendedoresPREMIACAO.SelectedRow.Cells[0].Text;
        lblCodPrem.Text = gViewListarVendedoresPREMIACAO.SelectedRow.Cells[1].Text;
        lblVendedorPrem.Text = gViewListarVendedoresPREMIACAO.SelectedRow.Cells[2].Text;

        string premioprodutivo, premiometa, retorno, mvp, avulsos, chequebonus, qtdeEMPL, comissaoEMPL;
        AdmFinanceiroWF adm = new AdmFinanceiroWF();
        adm.select_dadosprem(Convert.ToDateTime(txtdtInicialPremiacao.Text), Convert.ToDateTime(txtdtFinalPremiacao.Text), gViewListarVendedoresPREMIACAO.SelectedRow.Cells[1].Text, out premioprodutivo, out premiometa, out retorno, out chequebonus, out mvp, out avulsos);

        
        txtRetorno.Text = retorno;
        txtCheque.Text = chequebonus;
        txtPremioProd.Text = premioprodutivo;
        txtPremioMeta.Text = premiometa;
        txtmvp.Text = mvp;
        txtavulsos.Text = avulsos;
        

    }
    public string tabelaVN;
    public string tabelaVU;
    public string tabelaEMPL;


    protected void ddlistMargem_SelectedIndexChanged(object sender, EventArgs e)
    {
        string faixa;
        faixa = ddlistMargem.SelectedValue.ToString();
        txtComissaoLB.Text = "0,00";
        string aaa = "";
        if (faixa == "0.4")
        {
            //txtComissaoLB.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 5 / 100).ToString("N2");
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.4 / 100).ToString("N2");
            txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.4 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }
        if (faixa == "0.5")
        {
            //txtComissaoLB.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 5 / 100).ToString("N2");
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.5 / 100).ToString("N2");
            txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.5 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }
        if (faixa == "0.6")
        {

            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.6 / 100).ToString("N2");
            txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.6 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }

   
}
    protected void btnREcalcularTotal_Click(object sender, EventArgs e)
    {
        string comissaoatual,dif;
        comissaoatual = txtQtdeVN.Text;
        double zero = 0;

        //------------------------JEEP SAAN------------------------//

        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text)  <= 4 && lblLoja.Text == "JEEP SAAN")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.4 / 100).ToString("N2");
            txtDif1.Text = zero.ToString("N2");
        }

        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text)  <= 10 && Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text)  >= 5 && lblLoja.Text == "JEEP SAAN")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.5 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), gViewListarVendedores.SelectedRow.Cells[1].Text, Convert.ToInt16(txtQtdeVU.Text), out dif);
            txtDif1.Text = dif;
        }

        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text) >= 11 && lblLoja.Text == "JEEP SAAN")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.6 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), gViewListarVendedores.SelectedRow.Cells[1].Text, Convert.ToInt16(txtQtdeVU.Text), out dif);
            txtDif1.Text = dif;
        }

        //------------------------PARK SUL ------------------------//

        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text) <= 4 && lblLoja.Text == "PARK SUL")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.4 / 100).ToString("N2");
            txtDif1.Text = zero.ToString("N2");
        }

        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text)  <= 10 && Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text) >= 5  && lblLoja.Text == "PARK SUL")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.5 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), gViewListarVendedores.SelectedRow.Cells[1].Text, Convert.ToInt16(txtQtdeVU.Text), out dif);
            txtDif1.Text = dif;
        }

        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text)  >= 11 && lblLoja.Text == "PARK SUL")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.6 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), gViewListarVendedores.SelectedRow.Cells[1].Text, Convert.ToInt16(txtQtdeVU.Text), out dif);
            txtDif1.Text = dif;
        }

        //------------------------BALI SIA------------------------//



        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text) <= 6 && lblLoja.Text == "FIAT SIA")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.4 / 100).ToString("N2");
            txtDif1.Text = zero.ToString("N2");
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }

        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text)  >= 8 && lblLoja.Text == "FIAT SIA")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.5 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), gViewListarVendedores.SelectedRow.Cells[1].Text, Convert.ToInt16(txtQtdeVU.Text), out dif);
            txtDif1.Text = dif;
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }

        //------------------------BALI SCIA------------------------//
        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text)  < 7 && lblLoja.Text == "FIAT SCIA")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.4 / 100).ToString("N2");
            txtDif1.Text = zero.ToString("N2");
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }

        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text)  >= 6 && lblLoja.Text == "FIAT SCIA")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.5 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), gViewListarVendedores.SelectedRow.Cells[1].Text, Convert.ToInt16(txtQtdeVU.Text), out dif);
            txtDif1.Text = dif;
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }

        //------------------------BALI SAAN------------------------//

        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text)  < 7 && lblLoja.Text == "FIAT SAAN")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.4 / 100).ToString("N2");
            txtDif1.Text = zero.ToString("N2");
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }

        if (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVD.Text)  >= 8 && lblLoja.Text == "FIAT SAAN")
        {
            txtComissaoVN.Text = (Convert.ToDouble(txtTotalLiquido.Text) * 0.5 / 100).ToString("N2");
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.select_dif(Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text), gViewListarVendedores.SelectedRow.Cells[1].Text, Convert.ToInt16(txtQtdeVU.Text), out dif);
            txtDif1.Text = dif;
            //txtComissaoTotal.Text = ((Convert.ToDouble(txtTotalLiquido.Text) * 0.7 / 100) + Convert.ToDouble(txtComissaoVU.Text)).ToString("N2");
        }
        
        txtQtdeTotal.Text = (Convert.ToInt16(txtQtdeVN.Text) + Convert.ToInt16(txtQtdeVU.Text) + Convert.ToInt16(txtQtdeVD.Text)).ToString();
        txtComissaoTotal.Text = (Convert.ToDouble(txtComissaoVN.Text) + Convert.ToDouble(txtComissaoVU.Text) + Convert.ToDouble(txtComissaoVD.Text)).ToString("N2");
        
    }
    protected void btnSalvar_Click(object sender, EventArgs e)
    {
        try
        {
            
            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.insert_comissao(lblCodVend.Text, lblLoja.Text,lblNomeVendedor.Text, Convert.ToDateTime(txtDtInicial.Text), Convert.ToDateTime(txtDtFinal.Text),
                              Convert.ToInt16(txtQtdeTotal.Text), Convert.ToDouble(txtComissaoVU.Text), Convert.ToDouble(txtComissaoVN.Text), Convert.ToDouble(txtComissaoTotal.Text), Convert.ToDouble(txtComissaoVD.Text), Convert.ToDouble(txtDif1.Text), ddlistMargem.SelectedItem.Text, Convert.ToDouble(txtlb.Text));

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
        catch (SystemException ex)
        {
            sqldsListarVendedores.DataBind();
            gViewListarVendedores.DataBind();
            MostrarMensagem("Comissão já cadastrada ou não foi possível salvar. Confira o período e o vendedor.");
        }
        sqldsListarVendedores.DataBind();
        gViewListarVendedores.DataBind();
    }

    protected void btnSalvarVD_Click(object sender, EventArgs e)
    {
        try
        {

            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.update_comissao(Convert.ToDateTime(txtDtinicialPrem.Text), Convert.ToDateTime(txtDtfinalPrem.Text), lblcodVD.Text, gViewListarVendedoresVD.SelectedRow.Cells[0].Text,
            lblVendVD.Text, Convert.ToDouble(txtcomissaoVD2.Text));
            sqldsListarVendedoresPrem.DataBind();
            gViewListarVendedoresVD.DataBind();
            lblcodVD.Text = "";
            lblVendVD.Text = "";
            lblLojaVD.Text = "";
            txtcomissaoVD2.Text = "";
            MostrarMensagem("Comissão salva com sucesso.");
           
        }
        catch (SystemException ex)
        {
            sqldsListarVendedoresPrem.DataBind();
            gViewListarVendedoresVD.DataBind();
            MostrarMensagem("Comissão já cadastrada ou não foi possível salvar. Confira o período e o vendedor.");
        }

       
    }
    protected void btnSalvarEmpl_Click(object sender, EventArgs e)
    {
        try
        {

            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.update_comissaoEMPL(Convert.ToDateTime(txtDtinicialEmpl.Text), Convert.ToDateTime(txtDtfinalEmpl.Text), lblCodempl.Text, gViewListarVendedoresEMPLACAMENTO.SelectedRow.Cells[0].Text,
            lblVendempl.Text, Convert.ToDouble(txtEmplacamento.Text));
            sqldsListarVendedoresEmplac.DataBind();
            gViewListarVendedoresEMPLACAMENTO.DataBind();
            txtEmplacamento.Text = "";
            
            MostrarMensagem("Emplacamento salvo com sucesso.");

        }
        catch (SystemException ex)
        {
            sqldsListarVendedoresPrem.DataBind();
            gViewListarVendedoresVD.DataBind();
            MostrarMensagem("Emplacamento já cadastrado ou não foi possível salvar. Confira o período e o vendedor.");
        }


    }

    protected void btnSalvarPREM_Click(object sender, EventArgs e)
    {
        try
        {

            AdmFinanceiroWF adm = new AdmFinanceiroWF();
            adm.update_comissaoPREM(Convert.ToDateTime(txtdtInicialPremiacao.Text), Convert.ToDateTime(txtdtFinalPremiacao.Text), lblCodPrem.Text,
                                lblVendedorPrem.Text, Convert.ToDouble(txtPremioProd.Text), Convert.ToDouble(txtPremioMeta.Text), Convert.ToDouble(txtRetorno.Text), Convert.ToDouble(txtCheque.Text), 
                                Convert.ToDouble(txtmvp.Text), Convert.ToDouble(txtavulsos.Text), gViewListarVendedoresPREMIACAO.SelectedRow.Cells[0].Text);
            gViewListarVendedoresPREMIACAO.DataBind();
            sqldsListarVendedoresPremiacao.DataBind();
            lblcodVD.Text = "";
            lblVendVD.Text = "";
            MostrarMensagem("Premiação salva com sucesso.");

        }
        catch (SystemException ex)
        {
            sqldsListarVendedoresPrem.DataBind();
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
        ReportViewer1.LocalReport.ReportPath = @"admfinanceiro\Comissao\Report2.rdlc";
        sqldsComissaoRV.SelectParameters["dtInicial"].DefaultValue = TextBox1.Text;
        sqldsComissaoRV.SelectParameters["dtFinal"].DefaultValue = TextBox2.Text;
        ReportViewer1.LocalReport.Refresh();
    }


    protected void Button3_Click(object sender, EventArgs e)
    {
        ReportViewer2.LocalReport.ReportPath = @"admfinanceiro\Comissao\Report3.rdlc";
        sqldsComissaoRV2.SelectParameters["dtInicial"].DefaultValue = TextBox5.Text;
        sqldsComissaoRV2.SelectParameters["dtFinal"].DefaultValue = TextBox6.Text;
        ReportViewer2.LocalReport.Refresh();
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

    private string ValorSessao(string chave, string padrao)
    {
        if (Session[chave] == null) return padrao;
        string valor = Convert.ToString(Session[chave]).Trim();
        return valor.Length == 0 ? padrao : valor;
    }

    private void MostrarMensagem(string mensagem)
    {
        string texto = HttpUtility.JavaScriptStringEncode(mensagem ?? "");
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), "alert('" + texto + "');", true);
    }


}
