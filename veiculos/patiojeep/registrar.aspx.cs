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
using System.Threading;

public partial class veiculos_contrato : System.Web.UI.Page
{
    private Jeep oJeep = new Jeep();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] != null)
        {
            //if (getAcesso(1).Equals("s"))
            //{
                usuarioLogado.Text = Session["usuario"].ToString();
                txtSerie.Focus();
                if (!IsPostBack)
                {
                    btnRegistrar.Visible = false;

                    try
                    {
                        if (Request.QueryString["serie"] != null)
                        {
                            string serieLida = ExtrairSerieCodigoBarras(Request.QueryString["serie"].ToString());
                            if (serieLida.Equals(""))
                            {
                                throw new InvalidOperationException("Serie invalida");
                            }

                            txtSerie.Text = serieLida;
                            serieOnTextChanged(sender, e);
                        }
                    }
                    catch
                    {
                        btnRegistrar.Visible = false;
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('C\\u00f3digo de barras n\\u00e3o se refere a um chassi.')", true);
                    }
                }
                txtCor.Enabled = false;
                txtModelo.Enabled = false;
                txtChassi.Enabled = false;
                txtCodVec.Enabled = false;
            //}
            //else
            //{
            //    Response.Redirect("./restrito.aspx");
            //}
        }
        else
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
        }

    }

    private string SomenteDigitos(string valor)
    {
        if (String.IsNullOrWhiteSpace(valor))
        {
            return "";
        }

        List<char> digitos = new List<char>();
        foreach (char caractere in valor)
        {
            if (Char.IsDigit(caractere))
            {
                digitos.Add(caractere);
            }
        }

        return new String(digitos.ToArray());
    }

    private string NormalizarSerieFormulario(string valor)
    {
        string digitos = SomenteDigitos(valor);

        if (digitos.Length >= 17)
        {
            return digitos.Substring(10, 7);
        }

        return digitos;
    }

    private string ExtrairSerieCodigoBarras(string valor)
    {
        string serie = NormalizarSerieFormulario(valor);
        return serie.Length == 7 ? serie : "";
    }

    public void serieOnTextChanged(object sender, EventArgs e)
    {
        txtSerie.Text = NormalizarSerieFormulario(txtSerie.Text);

        if (!txtSerie.Text.Equals(""))
        {
            if (txtSerie.Text.Length != 7)
            {
                txtChassi.Text = "";
                txtModelo.Text = "";
                txtCor.Text = "";
                txtCodVec.Text = "";
                txtNUMERONF.Text = "";
                btnRegistrar.Visible = false;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('O n\\u00famero de s\\u00e9rie deve conter 7 d\\u00edgitos.');$('#myModal').modal('show');", true);
                txtSerie.Focus();
            }
            else
            {
                try
                {
                    oJeep.Conexao2();
                    SqlCommand oCmd = new SqlCommand();
                    oCmd.Connection = oJeep.oCon2;
                    oCmd.CommandText = "APP..veiculos_patio_selectRegistrar";
                    oCmd.CommandType = CommandType.StoredProcedure;
                    oCmd.Parameters.Add("@chassi", SqlDbType.VarChar).Value = txtSerie.Text;

                    SqlDataReader odr = oCmd.ExecuteReader();

                    if (odr.Read())
                    {
                        txtChassi.Text = odr["ve_chassi"].ToString();
                        txtModelo.Text = odr["ve_ds"].ToString();
                        txtCor.Text = odr["cor_ds"].ToString();
                        txtCodVec.Text = odr["ve_nr"].ToString();
                        txtNUMERONF.Text = odr["numeronf"].ToString();
                        btnRegistrar.Visible = true;
                        ddlLoja.Focus();
                    }
                    else
                    {
                        txtChassi.Text = "";
                        txtModelo.Text = "";
                        txtCor.Text = "";
                        txtCodVec.Text = "";
                        txtNUMERONF.Text = "";
                        btnRegistrar.Visible = false;
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Dados não encontrados!')", true);

                    }

                }
                catch
                {
                    btnRegistrar.Visible = false;
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('N\\u00e3o foi poss\\u00edvel carregar os dados do ve\\u00edculo agora.')", true);
                }
                finally
                {
                    oJeep.FecharConexao2();
                }
            }
        }
        else
        {
            txtChassi.Text = "";
            txtModelo.Text = "";
            txtCor.Text = "";
            txtCodVec.Text = "";
            txtNUMERONF.Text = "";
            btnRegistrar.Visible = false;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Informe a s\\u00e9rie antes de pesquisar.')", true);
        }
    }

    public void btnRegistrar_Click(object sender, EventArgs e)
    {
        if (Session["usuario"] == null || Session["usuario"].Equals("")) 
        {
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
        }
        else
        {
            int codVeiculo;
            int loja;
            int numeroNota;
            if (!int.TryParse(txtCodVec.Text, out codVeiculo) || !int.TryParse(ddlLoja.Value, out loja) || !int.TryParse(txtNUMERONF.Text, out numeroNota))
            {
                PatioJeepAuditoria.Registrar("REGISTRAR_VALIDACAO", Session["usuario"], txtSerie.Text, "Dados obrigatorios ausentes antes da gravacao");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Pesquise a série, confira os dados do veículo e selecione a loja antes de salvar.');", true);
                return;
            }

            try
            {
                oJeep.Conexao2();
                SqlCommand oCmd = new SqlCommand();
                oCmd.Connection = oJeep.oCon2;
                oCmd.CommandText = "APP..veiculos_patio_insert_locacao";
                oCmd.CommandType = CommandType.StoredProcedure;
                oCmd.Parameters.Add("@ve_nr", SqlDbType.Int).Value = codVeiculo;
                oCmd.Parameters.Add("@fun_cad", SqlDbType.VarChar).Value = Session["usuario"];
                oCmd.Parameters.Add("@loja", SqlDbType.Int).Value = loja;
                oCmd.Parameters.Add("@numeronf", SqlDbType.Int).Value = numeroNota;



                SqlDataReader odr = oCmd.ExecuteReader();
                odr.Read();
                if (odr["resultado"].ToString().Equals("n"))
                {
                    PatioJeepAuditoria.Registrar("REGISTRAR_DUPLICADO", Session["usuario"], txtSerie.Text, "Veiculo ja cadastrado");
                    txtChassi.Text = "";
                    txtModelo.Text = "";
                    txtCor.Text = "";
                    txtCodVec.Text = "";
                    txtNUMERONF.Text = "";
                    btnRegistrar.Visible = false;
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Veículo já cadastrado!')", true);
                }
                else
                {
                    PatioJeepAuditoria.Registrar("REGISTRAR_SUCESSO", Session["usuario"], txtSerie.Text, "Loja=" + ddlLoja.Value + "; Veiculo=" + txtCodVec.Text);
                    txtChassi.Text = "";
                    txtModelo.Text = "";
                    txtCor.Text = "";
                    txtCodVec.Text = "";
                    txtNUMERONF.Text = "";
                    txtSerie.Text = "";
                    btnRegistrar.Visible = false;
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Dados gravados com sucesso.')", true);

                }

            }
            catch
            {
                PatioJeepAuditoria.Registrar("REGISTRAR_ERRO", Session["usuario"], txtSerie.Text, "Erro ao gravar dados no banco");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", "alert('Erro ao gravar dados no banco!')", true);
            }
            finally
            {
                oJeep.FecharConexao2();
            }
        }
    }
    public void btnSair_Click(object sender, EventArgs e)
    {
        SessaoUnica.EncerrarSessaoAtual("LOGOUT_LOCAL");
        Session.Clear();
        Session.Abandon();
        Response.Redirect("./login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    public String getAcesso(int acesso_id)
    {
        Veiculos veiculos = new Veiculos();
        String retorno = "";

        try
        {
            oJeep.Conexao2();
            SqlCommand oCmd = new SqlCommand();
            oCmd.Connection = veiculos.oCon;
            oCmd.CommandText = "APP..veiculos_patio_verificar_acesso";
            oCmd.CommandType = CommandType.StoredProcedure;
            oCmd.Parameters.Add("@fun_cad", SqlDbType.VarChar).Value = Session["usuario"];
            oCmd.Parameters.Add("@acesso_id", SqlDbType.Int).Value = acesso_id;


            SqlDataReader odr = oCmd.ExecuteReader();


            odr.Read();
            retorno = odr["resultado"].ToString();

        }
        catch
        {

        }
        finally
        {
            oJeep.FecharConexao2();
        }
        return retorno;
    }

}
