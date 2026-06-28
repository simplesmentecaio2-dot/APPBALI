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
        if (Session["usuario"] != null)
        {
            lblUsuario.Text = Session["usuario"].ToString();
            lblTipo.Text = Session["usuario_codigo"] == null ? "-" : Session["usuario_codigo"].ToString();
        }
    }
  
 

}
