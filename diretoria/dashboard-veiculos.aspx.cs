using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class diretoria_dashboard_veiculos : System.Web.UI.Page
{
    public string data = DateTime.Now.ToShortDateString().ToString();
    //public string hora = DateTime.Now.ToString("hh:mm");// .ToShortTimeString("hh:mm:ss").ToString();
    Diretoria oDiretoria = new Diretoria();

    public string qtdeDiferenca;
    public string margemDiferenca;
    public double vlDiferenca;
    public double vlTotalPeriodo;
    public string vlmargemDiferenca;
    public double lucroPerido;
    public double lucroAtual;
    public string lucroDiferenca;
    public string qtdeTotalAno;
    public string qtdeColor;
    public string vlColor;
    public string margemColor;
    //dia
    public int qtde;
    public double vl;
    public double margem;

    //VARIAVEIS ATUAL PARA O NOVO METODO
    //mês atual
    public int  qtdeSIAVN; public int qtdeSIAVU;  public int  qtdeSIAVD;
    public int qtdeSCIAVN; public int qtdeSCIAVU; public int qtdeSCIAVD;
    public int qtdeSAANVN; public int qtdeSAANVU; public int qtdeSAANVD;
    public int qtdeAEROVN; public int qtdeAEROVU; public int qtdeAEROVD;
    public double  vlSIAVN; public double vlSIAVU; public double  vlSIAVD;
    public double vlSCIAVN; public double vlSCIAVU; public double vlSCIAVD;
    public double vlSAANVN; public double vlSAANVU; public double vlSAANVD;
    public double vlAEROVN; public double vlAEROVU; public double vlAEROVD;
    public string qtdeTotalMesAtual;
    public string qtdeTotalSIA;
    public string qtdeTotalSCIA;
    public string qtdeTotalSAAN;
    public string qtdeTotalAERO;
    public string vlTotalSIA;
    public string vlTotalSCIA;
    public string vlTotalSAAN;
    public string vlTotalAERO;
    public string vlTotalMesAtual;
    public double margemSIAVN;
    public double margemSIAVU;
    public double margemSCIAVN;
    public double margemSCIAVU;
    public double margemSAANVN;
    public double margemSAANVU;
    public double margemAEROVN;
    public double margemAEROVU;
    

    //mês anterior
    public int qtdeSIAVNAnterior; public int qtdeSIAVUAnterior; public int qtdeSIAVDAnterior;
    public int qtdeSCIAVNAnterior; public int qtdeSCIAVUAnterior; public int qtdeSCIAVDAnterior;
    public int qtdeSAANVNAnterior; public int qtdeSAANVUAnterior; public int qtdeSAANVDAnterior;
    public int qtdeAEROVNAnterior; public int qtdeAEROVUAnterior; public int qtdeAEROVDAnterior;
    public double vlSIAVNAnterior; public double vlSIAVUAnterior; public double vlSIAVDAnterior;
    public double vlSCIAVNAnterior; public double vlSCIAVUAnterior; public double vlSCIAVDAnterior;
    public double vlSAANVNAnterior; public double vlSAANVUAnterior; public double vlSAANVDAnterior;
    public double vlAEROVNAnterior; public double vlAEROVUAnterior; public double vlAEROVDAnterior;
    public string qtdeTotalMesAnterior;
    public string qtdeTotalSIAAnterior;
    public string qtdeTotalSCIAAnterior;
    public string qtdeTotalSAANAnterior;
    public string qtdeTotalAEROAnterior;
    public string vlTotalSIAAnterior;
    public string vlTotalSCIAAnterior;
    public string vlTotalSAANAnterior;
    public string vlTotalAEROAnterior;
    public string vlTotalMesAnterior;
    public string qtdeTotalAnteriorVN;
    public string qtdeTotalAnteriorVU;
    public string qtdeTotalAnteriorVD;

    //mês periodo
    public int qtdeSIAVNPeriodo; public int qtdeSIAVUPeriodo; public int qtdeSIAVDPeriodo;
    public int qtdeSCIAVNPeriodo; public int qtdeSCIAVUPeriodo; public int qtdeSCIAVDPeriodo;
    public int qtdeSAANVNPeriodo; public int qtdeSAANVUPeriodo; public int qtdeSAANVDPeriodo;
    public int qtdeAEROVNPeriodo; public int qtdeAEROVUPeriodo; public int qtdeAEROVDPeriodo;
    public double vlSIAVNPeriodo; public double vlSIAVUPeriodo; public double vlSIAVDPeriodo;
    public double vlSCIAVNPeriodo; public double vlSCIAVUPeriodo; public double vlSCIAVDPeriodo;
    public double vlSAANVNPeriodo; public double vlSAANVUPeriodo; public double vlSAANVDPeriodo;
    public double vlAEROVNPeriodo; public double vlAEROVUPeriodo; public double vlAEROVDPeriodo;
    public string qtdeTotalMesPeriodo;
    public string qtdeTotalSIAPeriodo;
    public string qtdeTotalSCIAPeriodo;
    public string qtdeTotalSAANPeriodo;
    public string qtdeTotalAEROPeriodo;
    public string vlTotalSIAPeriodo;
    public string vlTotalSCIAPeriodo;
    public string vlTotalSAANPeriodo;
    public string vlTotalAEROPeriodo;
    public string vlTotalMesPeriodo;
    public string qtdeTotalPeriodoVN;
    public string qtdeTotalPeriodoVU;
    public string qtdeTotalPeriodoVD;
    public double margemSIAVNPeriodo;
    public double margemSIAVUPeriodo;
    public double margemSCIAVNPeriodo;
    public double margemSCIAVUPeriodo;
    public double margemSAANVNPeriodo;
    public double margemSAANVUPeriodo;
    public double margemAEROVNPeriodo;
    public double margemAEROVUPeriodo;

    //Televendas
    public int qtdeAtualTV;
    public double vlAtualTV;
    public double margemAtualTV;
   

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["usuario"] == null || Session["usuario"].ToString().Equals(""))
        {
            Response.Redirect("./loginApp.aspx");
        }
        else
        {
            lblUsuario.Text = Session["usuario"].ToString();
        }
        try
        {

            oDiretoria.faturamento_qtde_Atual(
            out  qtdeSIAVN, out  qtdeSIAVU, out  qtdeSIAVD,
            out qtdeSCIAVN, out qtdeSCIAVU, out qtdeSCIAVD,
            out qtdeSAANVN, out qtdeSAANVU, out qtdeSAANVD,
            out qtdeAEROVN, out qtdeAEROVU, out qtdeAEROVD,
            out  vlSIAVN, out  vlSIAVU, out  vlSIAVD,
            out vlSCIAVN, out vlSCIAVU, out vlSCIAVD,
            out vlSAANVN, out vlSAANVU, out vlSAANVD,
            out vlAEROVN, out vlAEROVU, out vlAEROVD,
            out margemSIAVN, out  margemSIAVU,
            out margemSCIAVN, out margemSCIAVU,
            out margemSAANVN, out margemSAANVU,
            out margemAEROVN, out margemAEROVU
            );
            qtdeTotalMesAtual = (qtdeSIAVN + qtdeSIAVU + qtdeSIAVD + qtdeSCIAVN + qtdeSCIAVU + qtdeSCIAVD + qtdeSAANVN + qtdeSAANVU + qtdeSAANVD + qtdeAEROVN + qtdeAEROVU + qtdeAEROVD).ToString();
            qtdeTotalSIA = (qtdeSIAVN + qtdeSIAVU + qtdeSIAVD).ToString();
            qtdeTotalSCIA = (qtdeSCIAVN + qtdeSCIAVU + qtdeSCIAVD).ToString();
            qtdeTotalSAAN = (qtdeSAANVN + qtdeSAANVU + qtdeSAANVD).ToString();
            qtdeTotalAERO = (qtdeAEROVN + qtdeAEROVU + qtdeAEROVD).ToString();
            vlTotalSIA = (vlSIAVN + vlSIAVU /* + vlSIAVD*/).ToString("C2");
            vlTotalSCIA = (vlSCIAVN + vlSCIAVU /* + vlSCIAVD*/).ToString("C2");
            vlTotalSAAN = (vlSAANVN + vlSAANVU /* + vlSAANVD*/).ToString("C2");
            vlTotalAERO = (vlAEROVN + vlAEROVU /*+ vlAEROVD*/).ToString("C2");
            vlTotalMesAtual = (vlSIAVN + vlSIAVU + vlSCIAVN + vlSCIAVU + vlSAANVN + vlSAANVU + vlAEROVN + vlAEROVU).ToString("C2");

            //Mês anterior
            oDiretoria.faturamento_qtde_anterior(
            out  qtdeSIAVNAnterior, out  qtdeSIAVUAnterior, out  qtdeSIAVDAnterior,
            out qtdeSCIAVNAnterior, out qtdeSCIAVUAnterior, out qtdeSCIAVDAnterior,
            out qtdeSAANVNAnterior, out qtdeSAANVUAnterior, out qtdeSAANVDAnterior,
            out qtdeAEROVNAnterior, out qtdeAEROVUAnterior, out qtdeAEROVDAnterior,
            out  vlSIAVNAnterior, out  vlSIAVUAnterior, out  vlSIAVDAnterior,
            out vlSCIAVNAnterior, out vlSCIAVUAnterior, out vlSCIAVDAnterior,
            out vlSAANVNAnterior, out vlSAANVUAnterior, out vlSAANVDAnterior,
            out vlAEROVNAnterior, out vlAEROVUAnterior, out vlAEROVDAnterior
            );
            qtdeTotalMesAnterior = (qtdeSIAVNAnterior + qtdeSIAVUAnterior + qtdeSIAVDAnterior + qtdeSCIAVNAnterior + qtdeSCIAVUAnterior + qtdeSCIAVDAnterior + qtdeSAANVNAnterior + qtdeSAANVUAnterior + qtdeSAANVDAnterior + qtdeAEROVNAnterior + qtdeAEROVUAnterior + qtdeAEROVDAnterior).ToString();
            qtdeTotalSIAAnterior = (qtdeSIAVNAnterior + qtdeSIAVUAnterior + qtdeSIAVDAnterior).ToString();
            qtdeTotalSCIAAnterior = (qtdeSCIAVNAnterior + qtdeSCIAVUAnterior + qtdeSCIAVDAnterior).ToString();
            qtdeTotalSAANAnterior = (qtdeSAANVNAnterior + qtdeSAANVUAnterior + qtdeSAANVDAnterior).ToString();
            qtdeTotalAEROAnterior = (qtdeAEROVNAnterior + qtdeAEROVUAnterior + qtdeAEROVDAnterior).ToString();
            vlTotalSIAAnterior = (vlSIAVNAnterior + vlSIAVUAnterior).ToString("C2");
            vlTotalSCIAAnterior = (vlSCIAVNAnterior + vlSCIAVUAnterior).ToString("C2");
            vlTotalSAANAnterior = (vlSAANVNAnterior + vlSAANVUAnterior).ToString("C2");
            vlTotalAEROAnterior = (vlAEROVNAnterior + vlAEROVUAnterior).ToString("C2");
            vlTotalMesAnterior = (vlSIAVNAnterior + vlSIAVUAnterior + vlSCIAVNAnterior + vlSCIAVUAnterior + vlSAANVNAnterior + vlSAANVUAnterior + vlAEROVNAnterior + vlAEROVUAnterior).ToString("C2");
            qtdeTotalAnteriorVN = (qtdeSIAVNAnterior + qtdeSCIAVNAnterior + qtdeSAANVNAnterior + qtdeAEROVNAnterior).ToString("N0");
            qtdeTotalAnteriorVU = (qtdeSIAVUAnterior + qtdeSCIAVUAnterior + qtdeSAANVUAnterior + qtdeAEROVUAnterior).ToString("N0");
            qtdeTotalAnteriorVD = (qtdeSIAVDAnterior + qtdeSCIAVDAnterior + qtdeSAANVDAnterior + qtdeAEROVDAnterior).ToString("N0");

            //periodo
            oDiretoria.faturamento_qtde_periodo(
            out  qtdeSIAVNPeriodo, out  qtdeSIAVUPeriodo, out  qtdeSIAVDPeriodo,
            out qtdeSCIAVNPeriodo, out qtdeSCIAVUPeriodo, out qtdeSCIAVDPeriodo,
            out qtdeSAANVNPeriodo, out qtdeSAANVUPeriodo, out qtdeSAANVDPeriodo,
            out qtdeAEROVNPeriodo, out qtdeAEROVUPeriodo, out qtdeAEROVDPeriodo,
            out  vlSIAVNPeriodo, out  vlSIAVUPeriodo, out  vlSIAVDPeriodo,
            out vlSCIAVNPeriodo, out vlSCIAVUPeriodo, out vlSCIAVDPeriodo,
            out vlSAANVNPeriodo, out vlSAANVUPeriodo, out vlSAANVDPeriodo,
            out vlAEROVNPeriodo, out vlAEROVUPeriodo, out vlAEROVDPeriodo,
            out margemSIAVNPeriodo, out  margemSIAVUPeriodo,
            out margemSCIAVNPeriodo, out margemSCIAVUPeriodo,
            out margemSAANVNPeriodo, out margemSAANVUPeriodo,
            out margemAEROVNPeriodo, out margemAEROVUPeriodo
            );
            qtdeTotalMesPeriodo = (qtdeSIAVNPeriodo + qtdeSIAVUPeriodo + qtdeSIAVDPeriodo + qtdeSCIAVNPeriodo + qtdeSCIAVUPeriodo + qtdeSCIAVDPeriodo + qtdeSAANVNPeriodo + qtdeSAANVUPeriodo + qtdeSAANVDPeriodo + qtdeAEROVNPeriodo + qtdeAEROVUPeriodo + qtdeAEROVDPeriodo).ToString();
            qtdeTotalSIAPeriodo = (qtdeSIAVNPeriodo + qtdeSIAVUPeriodo + qtdeSIAVDPeriodo).ToString();
            qtdeTotalSCIAPeriodo = (qtdeSCIAVNPeriodo + qtdeSCIAVUPeriodo + qtdeSCIAVDPeriodo).ToString();
            qtdeTotalSAANPeriodo = (qtdeSAANVNPeriodo + qtdeSAANVUPeriodo + qtdeSAANVDPeriodo).ToString();
            qtdeTotalAEROPeriodo = (qtdeAEROVNPeriodo + qtdeAEROVUPeriodo + qtdeAEROVDPeriodo).ToString();
            vlTotalSIAPeriodo = (vlSIAVNPeriodo + vlSIAVUPeriodo).ToString("C2");
            vlTotalSCIAPeriodo = (vlSCIAVNPeriodo + vlSCIAVUPeriodo).ToString("C2");
            vlTotalSAANPeriodo = (vlSAANVNPeriodo + vlSAANVUPeriodo).ToString("C2");
            vlTotalAEROPeriodo = (vlAEROVNPeriodo + vlAEROVUPeriodo).ToString("C2");
            vlTotalMesPeriodo = (vlSIAVNPeriodo + vlSIAVUPeriodo + vlSCIAVNPeriodo + vlSCIAVUPeriodo + vlSAANVNPeriodo + vlSAANVUPeriodo + vlAEROVNPeriodo + vlAEROVUPeriodo).ToString("C2");
            qtdeTotalPeriodoVN = (qtdeSIAVNPeriodo + qtdeSCIAVNPeriodo + qtdeSAANVNPeriodo + qtdeAEROVNPeriodo).ToString("N0");
            qtdeTotalPeriodoVU = (qtdeSIAVUPeriodo + qtdeSCIAVUPeriodo + qtdeSAANVUPeriodo + qtdeAEROVUPeriodo).ToString("N0");
            qtdeTotalPeriodoVD = (qtdeSIAVDPeriodo + qtdeSCIAVDPeriodo + qtdeSAANVDPeriodo + qtdeAEROVDPeriodo).ToString("N0");

            qtdeDiferenca = (Convert.ToDouble(qtdeTotalMesAtual) - Convert.ToDouble(qtdeTotalMesPeriodo)).ToString("N0");
            if (Convert.ToInt16(qtdeDiferenca) < 0)
            {
                imgQtdeDiferenca.ImageUrl = "../img/down.png";
                qtdeColor = "color:red; font-size:30px; margin-top:30px;";
            }
            else
            {
                if (Convert.ToInt16(qtdeDiferenca) > 0)
                {
                    imgQtdeDiferenca.ImageUrl = "../img/up.png";
                    qtdeColor = "color:#4cff00; font-size:30px; margin-top:20px;";
                }
                else
                {
                    imgQtdeDiferenca.ImageUrl = "../img/neutro.png";
                    qtdeColor = "color:#fcff00; font-size:30px; margin-top:20px;";
                }
            }



            if (qtdeTotalMesPeriodo != "0")
            {
                margemDiferenca = ((Convert.ToDouble(qtdeDiferenca) * 100) / Convert.ToDouble(qtdeTotalMesPeriodo)).ToString("N0") + "%";
            }
            else
            {
                margemDiferenca = ((Convert.ToDouble(qtdeDiferenca) * 100) / Convert.ToDouble(1)).ToString("N0") + "%";
            }


            vlDiferenca = (vlSIAVN + vlSIAVU + vlSCIAVN + vlSCIAVU + vlSAANVN + vlSAANVU + vlAEROVN + vlAEROVU) - (vlSIAVNPeriodo + vlSIAVUPeriodo + vlSCIAVNPeriodo + vlSCIAVUPeriodo + vlSAANVNPeriodo + vlSAANVUPeriodo + vlAEROVNPeriodo + vlAEROVUPeriodo);
            vlTotalPeriodo = (vlSIAVNPeriodo + vlSIAVUPeriodo + vlSCIAVNPeriodo + vlSCIAVUPeriodo + vlSAANVNPeriodo + vlSAANVUPeriodo + vlAEROVNPeriodo + vlAEROVUPeriodo);
            if (vlDiferenca < 0)
            {
                imgVlDiferenca.ImageUrl = "../img/down.png";
                vlColor = "color:red; font-size:30px; margin-top:20px;";
            }

            else
            {
                if (vlDiferenca > 0)
                {
                    imgVlDiferenca.ImageUrl = "../img/up.png";
                    vlColor = "color:#4cff00; font-size:30px; margin-top:20px;";
                }
                else
                {
                    imgVlDiferenca.ImageUrl = "../img/neutro.png";
                    vlColor = "color:#fcff00; font-size:30px; margin-top:20px;";
                }
            }

            if (vlDiferenca != 0)
            {
                vlmargemDiferenca = ((vlDiferenca * 100) / vlTotalPeriodo).ToString("N0") + "%";
            }
            else
            {
                vlmargemDiferenca = (((vlDiferenca * 100) / 1)).ToString("N0") + "%";
            }


            lucroPerido = (margemSIAVNPeriodo + margemSIAVUPeriodo + margemSCIAVNPeriodo + margemSCIAVUPeriodo + margemSAANVNPeriodo + margemSAANVUPeriodo + margemAEROVNPeriodo + margemAEROVUPeriodo);
            lucroAtual = (margemSIAVN + margemSIAVU + margemSCIAVN + margemSCIAVU + margemSAANVN + margemSAANVU + margemAEROVN + margemAEROVU);
            if ((lucroAtual - lucroPerido) < 0)
            {
                imgMargemDiferenca.ImageUrl = "../img/down.png";
                margemColor = "color:red; font-size:30px; margin-top:20px;";
            }

            else
            {
                if ((lucroAtual - lucroPerido) > 0)
                {
                    imgMargemDiferenca.ImageUrl = "../img/up.png";
                    margemColor = "color:#4cff00; font-size:30px; margin-top:20px;";
                }
                else
                {
                    imgMargemDiferenca.ImageUrl = "../img/neutro.png";
                    margemColor = "color:#fcff00; font-size:30px; margin-top:20px;";
                }
            }

            if ((lucroAtual - lucroPerido) != 0)
            {
                lucroDiferenca = (((lucroAtual - lucroPerido) * 100) / lucroAtual).ToString("N0") + "%";
            }
            else
            {
                lucroDiferenca = ((((lucroAtual - lucroPerido) * 100) / 1)).ToString("N0") + "%";
            }


            //dia
            oDiretoria.faturamento_dia(out qtde, out vl, out margem);


            // Televendas

            oDiretoria.qtdeTotalAtualTV(out qtdeAtualTV, out vlAtualTV, out margemAtualTV);
        }
        catch { }
    //Fim Load
    }
    
}