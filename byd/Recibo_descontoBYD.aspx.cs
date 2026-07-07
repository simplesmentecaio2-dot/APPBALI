using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class veiculos_Recibo_desconto : System.Web.UI.Page
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
            lblTipo.Text = Session["usuario_codigo"] == null ? "-" : Session["usuario_codigo"].ToString();
        }

    }
   protected void btnGerar_Click(object sender, EventArgs e)
    {
        
       try
        {
            Jeep oJeep = new Jeep();
            string veiculo, chassi, cor, cliente, placa, ano, nota, vendedor;
            double valor;
            oJeep.select_dadosentrega(txtPedido.Text, txtLoja.Text, out cliente, out veiculo, out chassi, out cor, out placa, out vendedor, out valor, out ano, out nota);
            lblCliente.Text = cliente;
            lblValor.Text = valor.ToString("N2");
            lblVeículo.Text = veiculo;
            lblChassi.Text = chassi;
            lblCor.Text = cor;
            lblAno.Text = ano;
            lblNota.Text = nota;
                        lblextenso.Text = valorpoextenso(valor.ToString("N2"));

        }
        catch
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "reciboNaoEncontrado",
                                                               "if (window.baliUtilityFeedback) { window.baliUtilityFeedback('Pedido não encontrado para essa loja. Confira o número do pedido e o código da loja.', 'error'); } else { alert('Pedido não encontrado para essa loja.'); }", true);
        }



    }

 public string valorpoextenso(string wvalor)
    {
        string[] wunidade = { "", " e um", " e dois", " e trez", " e quatro", " e cinco", " e seis", " e sete", " e oito", " e nove" };
        string[] wdezes = { "", " e onze", " e doze", " e treze", " e quatorze", " e quinze", " e dezesseis", " e dezessete", " e dezoito", " e dezenove" };
        string[] wdezenas = { "", " e dez", " e vinte", " e trinta", " e quarenta", " e cinquenta", " e sessenta", " e setenta", " e oitenta", " e noventa" };
        string[] wcentenas = { "", " e cento", " e duzentos", " e trezentos", " e quatrocentos", " e quinhentos", " e seiscentos", " e setecentos", " e oitocentos", " e novecentos" };
        string[] wplural = { " bilhões", " milhões", " mil", "" };
        string[] wsingular = { " bilhão", " milhão", " mil", "" };
        string wextenso = "";
        string wfracao;
        wvalor = wvalor.Replace("R$", "");
        string wnumero = wvalor.Replace(",", "").Trim();
        wnumero = wnumero.Replace(".", "").PadLeft(14, '0');
        if (Int64.Parse(wnumero.Substring(0, 12)) > 0)
        {
            for (int i = 0; i < 4; i++)
            {
                wfracao = wnumero.Substring(i * 3, 3);
                if (int.Parse(wfracao) != 0)
                {
                    if (int.Parse(wfracao.Substring(0, 3)) == 100) wextenso += " e cem";
                    else
                    {
                        wextenso += wcentenas[int.Parse(wfracao.Substring(0, 1))];
                        if (int.Parse(wfracao.Substring(1, 2)) > 10 && int.Parse(wfracao.Substring(1, 2)) < 20) wextenso += wdezes[int.Parse(wfracao.Substring(2, 1))];
                        else
                        {
                            wextenso += wdezenas[int.Parse(wfracao.Substring(1, 1))];
                            wextenso += wunidade[int.Parse(wfracao.Substring(2, 1))];
                        }
                    }
                    if (int.Parse(wfracao) > 1) wextenso += wplural[i];
                    else wextenso += wplural[i];
                }
            }
            if (Int64.Parse(wnumero.Substring(0, 12)) > 1) wextenso += " reais";
            else wextenso += " real";
        }
        wfracao = wnumero.Substring(12, 2);
        if (int.Parse(wfracao) > 0)
        {
            if (int.Parse(wfracao.Substring(0, 2)) > 10 && int.Parse(wfracao.Substring(0, 2)) < 20) wextenso = wextenso + wdezes[int.Parse(wfracao.Substring(1, 1))];
            else
            {
                wextenso += wdezenas[int.Parse(wfracao.Substring(0, 1))];
                wextenso += wunidade[int.Parse(wfracao.Substring(1, 1))];
            }
            if (int.Parse(wfracao) > 1) wextenso += " centavos";
            else wextenso += " centavo";
        }
        if (wextenso != "") wextenso = wextenso.Substring(3, 1).ToUpper() + wextenso.Substring(4);
        else wextenso = "Nada";
        return wextenso;
    }

}
