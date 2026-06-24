using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class gerencia_veiculos : System.Web.UI.Page
{
    Gerencia oGerencia = new Gerencia();
    public string desempenho;
    public string tableVendidos;
    public int qtdeTotal;
    public double vlTotal;
    public double margemTotal;
    public double acessorioCusto = 0;
    public double acessorioCobrado = 0;
    public double emplacamentoCusto = 0;
    public double emplacamentoCobrado = 0;
    public double transfCusto = 0;
    public double transfCobrado = 0;

    public void Chart_Desempenho()
    {
        oGerencia.desempenhoVendedor(ddlVendedor.SelectedValue.ToString(), out desempenho);
    }
    public void nomevendedor()
    {
        //lblVendedor.Text = ddlVendedor.SelectedItem.Text;
        //lblLoja.Text = ddlistLoja.SelectedItem.Text;
        lblVendedorNumeros.Text = ddlVendedor.SelectedItem.Text;
        //lblSetor.Text = ddlistSetor.SelectedItem.Text;
    }

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
    }


    protected void Button1_Click(object sender, EventArgs e)
    {
        Chart_Desempenho();
        nomevendedor();
        TabContainerVendedor.ActiveTabIndex = 0;
        TableVendidos();
        AceossrioVendedor();


    }
    protected void ddlVendedor_SelectedIndexChanged(object sender, EventArgs e)
    {
        Chart_Desempenho();
        nomevendedor();
        TabContainerVendedor.ActiveTabIndex = 0;
        TableVendidos();
        AceossrioVendedor();

    }

    protected void TableVendidos() {
        oGerencia.TableVendidosVEndedor( Convert.ToDateTime(txtDtInicio.Text), Convert.ToDateTime(txtDtFim.Text),
                                        ddlVendedor.SelectedValue.ToString(), out tableVendidos, out qtdeTotal, out vlTotal, out margemTotal);
    }

    protected void AceossrioVendedor()
    {
        oGerencia.VendedorAcessorio(Convert.ToDateTime(txtDtInicio.Text), Convert.ToDateTime(txtDtFim.Text), ddlVendedor.SelectedValue.ToString(),
                                        out acessorioCusto, out acessorioCobrado, out emplacamentoCusto, out emplacamentoCobrado,
                                        out transfCusto, out transfCobrado);
                                        
                                    
    }


}