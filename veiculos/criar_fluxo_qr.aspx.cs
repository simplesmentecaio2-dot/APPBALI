using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows.Forms;
using System.Drawing;
using System.Data;
using QRCoder;
using System.IO;
using System.Data.SqlClient;

public partial class veiculos_contrato : System.Web.UI.Page
{
    private Veiculos vec = new Veiculos();

    protected void Page_Load(object sender, EventArgs e)

    {


        Response.Redirect("./criar_fluxo.aspx");

    }

    public void buscarCliente(object sender, EventArgs e)
    {
        Veiculos veiculos = new Veiculos();
        if (txtCliente.Value != "")
        {
            try
            {
                veiculos.Conexao();

                SqlCommand oCmd = new SqlCommand();
                oCmd.Connection = veiculos.oCon;
                oCmd.CommandText = "APP..prospeccao_selecttabela_por_cliente";
                oCmd.Parameters.Add("@evento", SqlDbType.VarChar).Value = ddlEvento.Value;
                oCmd.Parameters.Add("@cliente", SqlDbType.VarChar).Value = txtCliente.Value;
                oCmd.CommandType = CommandType.StoredProcedure;
                SqlDataReader odr = oCmd.ExecuteReader();
                string head = @"<table class='table table-striped table-bordered dt-responsive' style='width:100%' id='tblprospeccao'>
                        <thead >
                            <tr>
                                <td>Confirmar</td>
                                <td>ID</td>
                                <td>Cliente</td>
                                <td>fone 1</td>
                                <td>fone 2</td>
                                <td>fone 3</td>
                                <td>vendedor</td>
                                <td>loja</td>
                                <td>equipe</td>
                                <td>classificacao</td>
                                </tr>
                        </thead>";
                string body = "<tbody>";
                // a quantidade de colunas(tfoot) deve se a mesma quantidade de colunas da tabela do banco.
                string foot = @"</tbody></table>";
                while (odr.Read())
                {
                    //valor = Convert.ToDouble(odr["Valor"]);
                    //<span title="<%# Eval("Numero") %>" onclick="consultaChamadoAberto(this)"><%# Eval("Numero") %></span>
                    body = body + @"<tr> <td><a href='.\confirmafluxo.aspx?id=" + odr["id"] + "'><label class='btn btn-success fas fa-check'></label></a></td>" +
                              " <td class='text-'>" + odr["id"] +
                                   "</td><td>" + odr["cliente"].ToString() +
                                   "</td><td>" + odr["telefone"].ToString() +
                                   "</td><td>" + odr["fone2"].ToString() +
                                   "</td><td>" + odr["fone3"].ToString() +
                                   "</td><td>" + odr["vendedor"].ToString() +
                                   "</td><td>" + odr["loja"].ToString() +
                                   "</td><td>" + odr["equipe"].ToString() +
                                   "</td><td>" + odr["classificacao"].ToString() +
                                   "</td></tr>";
                }
                if (body.Equals("<tbody>"))
                {
                    tabelaPesquisa.Text = "Sem dados referente à: " + txtCliente.Value;
                }
                else
                {
                    string tabela = head + body + foot;
                    tabelaPesquisa.Text = tabela;


                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                                  @"var searchInput = $('#txtCliente');var strLength = searchInput.val().length * 2;
                                                                                    searchInput.focus();
                                                                                    searchInput[0].setSelectionRange(strLength, strLength);$('#tblprospeccao').DataTable({responsive: true });", true);
            }
            catch
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                                   "alert('Erro ao buscar dados!');", true);
            }
            finally { veiculos.FecharConexao(); }
        }
        else 
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript",
                                                                                   "alert('Favor informar nome do cliente!');", true);
        }
    }
}