using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class veiculos_Seminovos : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Veiculos vec = new Veiculos();
        estoqueVU = vec.select_estoque_VU();
    }

    public string estoqueVU;
}