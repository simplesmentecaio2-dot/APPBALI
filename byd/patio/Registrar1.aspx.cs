using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class veiculos_patio_Registrar : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void btnRegistrar_Click(object sender, EventArgs e)
    {
        try
        {
            Veiculos oVeiculos = new Veiculos();
            oVeiculos.Insertlocacao(txtChassi.Text, txtChassiRegistrar.Text, txtVeiculo.Text, txtCor.Text, ddlLoja.SelectedValue);


            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                               "alert('CHASSI CADASTRADO COM SUCESSO!');", true);
        }
        catch
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                               "alert('O VEÍCULO PROVAVELMENTE JÁ ESTÁ ALOCADO, SE DESEJA TRANSFERIR VÁ PARA A ABA DE TRANSFERÊNCIA');", true);
        }
    }
    protected void btnBuscar_Click1(object sender, EventArgs e)
    {
        try
        {
            Veiculos oVeiculos = new Veiculos();
            string chassi, codigo, cor, veiculo;

            oVeiculos.select_chassi_veiculo(txtChassiRegistrar.Text, out  codigo, out  veiculo, out  chassi, out  cor);

            txtCodigo.Text = codigo;
            txtVeiculo.Text = veiculo;
            txtChassi.Text = chassi;
            txtCor.Text = cor;
        }
        catch
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                               "alert('CHASSI INVÁLIDO!!');", true);
        }
    }
   
}