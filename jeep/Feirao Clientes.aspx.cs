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
        Veiculos ovec = new Veiculos();
        string tabelaR; 
        string tabelaVUR;
        ovec.select_Tab_Consulta(out tabelaR);
        ovec.select_Tab_ConsultaVU(out tabelaVUR);

        tabela = tabelaR;
        tabelaVU = tabelaVUR ;


      
    }
    public string tabela;
    public string tabelaVU;

    protected void btnGravar_Click(object sender, EventArgs e)
    {

    }
}
   
    
    

    


