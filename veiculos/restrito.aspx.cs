using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class login : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {

        string localizacaoSCIA = "https://goo.gl/maps/mbPyhrqaTDUJCYER7";
        string localizacaoSIA = "https://goo.gl/maps/XjMsM7CJkvrwFD5Q7";
        string localizacaoSAAN = "https://goo.gl/maps/SwUC4MXLP8qiGraN7";
        string id = "";
        titulo.Visible = true;
        erro_titulo.Visible = false;
        if (Request.QueryString["id"] != null)
        {
            try
            {
                id = Request.QueryString["id"].ToString();
                Veiculos vec = new Veiculos();
                string cliente, telefone, email, classificacao, vendedor, loja, nome_evento, equipe;
                DateTime data_cadastro;
                vec.select_prospeccao_confirmafluxo(id, out cliente, out telefone, out email, out classificacao, out vendedor, out loja, out nome_evento, out equipe, out data_cadastro);

                literalCliente.Text = cliente;
                literalImageConvite.Text = "<img src=\"./images/" + nome_evento + "_" + loja + ".jpg\" class=\"img-fluid mb-2\" />";
                if (loja.Equals("SIA") || loja.Equals("sia"))
                { literalLocalizacao.Text = "<a href=\""+localizacaoSIA+"\" class=\"btn btn-primary\"><span class=\"fa fa-map-marker fa-4x\"></span><br /> Obter localização</a>"; }
                else if (loja.Equals("SCIA") || loja.Equals("scia"))
                { literalLocalizacao.Text = "<a href=\"" + localizacaoSCIA + "\" class=\"btn btn-primary\"><span class=\"fa fa-map-marker fa-4x\"></span><br /> Obter localização</a>"; } 
                if (loja.Equals("SAAN") || loja.Equals("saan"))
                { literalLocalizacao.Text = "<a href=\"" + localizacaoSAAN + "\" class=\"btn btn-primary\"><span class=\"fa fa-map-marker fa-4x\"></span><br /> Obter localização</a>"; }
            }
            catch (Exception)
            {
                titulo.Visible = false;
                erro_titulo.Visible = true;
            }
        }
        else
        {
            titulo.Visible = false;
            erro_titulo.Visible = true;
        }
    }

}