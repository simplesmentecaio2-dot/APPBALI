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
        divBtnConfirmaFluxo.Visible = true;
        divFluxoConfirmado.Visible = false;
        fluxoErro.Visible = false;

        if (Session["id"] != null && (Session["id"].Equals("CAIO") || Session["id"].Equals("gabrielle") || Session["id"].Equals("PASSANTE") || Session["id"].Equals("Passante") || Session["usuario"].Equals("CAIO") || Session["id"].Equals("caio@bali.com.br") || Session["usuario"].Equals("caio@bali.com.br") || Session["id"].Equals("PASSANTE") || Session["usuario"].Equals("PASSANTE") || Session["id"].Equals("passante") || Session["usuario"].Equals("passante") || Session["usuario"].Equals("REBECA") || Session["usuario"].Equals("rebeca")))
        {

        }
        else
        {

            if (Request.QueryString["id"] == null || Request.QueryString["id"].ToString().Equals(""))
            {
                Response.Redirect("./restrito.aspx");
            }
            else
            {
                Response.Redirect("./restrito.aspx");
            }
        }

        string id = "";
        if (Request.QueryString["id"] != null)
        {
            try
            {
                id = Request.QueryString["id"].ToString();
                Veiculos vec = new Veiculos();
                string cliente, telefone, email, classificacao, vendedor, loja, nome_evento, equipe;
                DateTime data_cadastro;
                vec.select_prospeccao_confirmafluxo(id, out cliente, out telefone, out email, out classificacao, out vendedor, out loja, out nome_evento, out equipe, out data_cadastro);
                labelId.InnerText = id;
                labelCliente.InnerText = cliente;
                labelTelefone.InnerText = telefone;
                labelVendedor.InnerText = vendedor;
                labelLoja.InnerText = loja;
                labelEquipe.InnerText = equipe;
                labelEvento.InnerText = nome_evento;
                divFluxoConfirmado.Visible = false;
                //if (DateTime.Now.Date == data_cadastro.Date)
                //{
                //    fluxoCorreto.Visible = false;
                //    fluxoErro.Visible = true;
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Cliente cadastrado hoje, confirmação de fluxo não permitida');", true);
                //}
            }
            catch (Exception)
            {
                fluxoCorreto.Visible = false;
                fluxoErro.Visible = true;
            }
        }
        else
        {
            fluxoCorreto.Visible = false;
            fluxoErro.Visible = true;
            Response.Write("Cliente não localizado!");
        }




    }





    protected void btnProcessar_Click(object sender, EventArgs e)
    {

    }

    protected void btnequipes_Click(object sender, EventArgs e)
    {

    }
    protected void btnProcessar4_Click(object sender, EventArgs e)
    {

    }
    protected void ibtnDadosCliente_Click(object sender, EventArgs e)
    {
        string id = "";
        id = Request.QueryString["id"].ToString();
        Veiculos vec = new Veiculos();
        vec.update_fluxoprospeccao(id);
        divBtnConfirmaFluxo.Visible = false;
        divFluxoConfirmado.Visible = true;
        // ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
        // "alert('FLUXO CONFIRMADO COM SUCESSO!! ');", true);

    }
}
   
    
    

    


