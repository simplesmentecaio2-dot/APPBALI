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
    private Veiculos vec = new Veiculos();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["id"] != null)
        {
            if (getAcesso(1).Equals("s"))
            {
                usuarioLogado.Text = Session["usuario"].ToString();
                txtSerie.Focus();

                txtCor.Enabled = false;
                txtModelo.Enabled = false;
                txtChassi.Enabled = false;
                txtCodVec.Enabled = false;
                txtLocal.Enabled = false;
                txtPedido.Enabled = false;
                string serie = "";
                try
                {
                    if (Request.QueryString["serie"] != null)
                    {

                        serie = Request.QueryString["serie"].ToString();
                        txtSerie.Text = serie.Substring(10, 7);
                        serieOnTextChanged(sender, e);

                    }
                }
                catch
                {
                    this.executarJavaScript("alert('Codigo de barras não se refere a um chassi!'); ");
                }
            }
            else
            {
                Response.Redirect("./restrito.aspx");
            }
        }
        else
        {
            Response.Redirect("./login.aspx");
        }

    }

    public void serieOnTextChanged(object sender, EventArgs e)
    {
        if (!txtSerie.Text.Equals(""))
        {
            if (txtSerie.Text.Length != 7)
            {
                this.limpaCampos();
                btnRegistrar.Visible = false;
                this.executarJavaScript("alert('O número de série deve conter 7 digitos!'); ");
                txtSerie.Focus();
            }
            else
            {
                try
                {
                    vec.Conexao();
                    SqlCommand oCmd = new SqlCommand();
                    oCmd.Connection = vec.oCon;
                    oCmd.CommandText = "APP..veiculos_patio_selectRegistrarAgend";
                    oCmd.CommandType = CommandType.StoredProcedure;
                    oCmd.Parameters.Add("@chassi", SqlDbType.VarChar).Value = txtSerie.Text;

                    SqlDataReader odr = oCmd.ExecuteReader();

                    if (odr.Read())
                    {
                        txtChassi.Text = odr["ve_chassi"].ToString();
                        txtModelo.Text = odr["ve_ds"].ToString();
                        txtCor.Text = odr["cor_ds"].ToString();
                        txtCodVec.Text = odr["ve_nr"].ToString();
                        txtLocal.Text = odr["locacao"].ToString();
                        txtPedido.Text = odr["prop_nrpedido"].ToString();
                        btnRegistrar.Visible = true;
                        ddlLoja.Focus();
                        this.executarJavaScript(" ");

                    }
                    else
                    {
                        this.limpaCampos();
                        this.executarJavaScript("alert('Não há pedido para o chassi!'); ");

                    }

                }
                catch
                {
                    this.executarJavaScript("alert('Erro ao carregar dados!'); ");
                }
                finally
                {
                    vec.FecharConexao();
                }
            }
        }
        else
        {
            this.limpaCampos();
            this.executarJavaScript("alert('Campo série Obrigatório!'); ");
        }
    }

    public void btnRegistrar_Click(object sender, EventArgs e)
    {
        if (Session["usuario"] == null || Session["usuario"].Equals(""))
        {
            Response.Redirect("./login.aspx");
        }
        else
        {
            int codVeiculo;
            int loja;
            string dt = Request.Form[dtAgendamento.UniqueID];
            DateTime dataAgendamento;
            if (!int.TryParse(txtCodVec.Text, out codVeiculo) || !int.TryParse(ddlLoja.Value, out loja) || String.IsNullOrWhiteSpace(dt) || !DateTime.TryParse(dt, out dataAgendamento))
            {
                PatioJeepAuditoria.Registrar("AGENDAR_VALIDACAO", Session["usuario"], txtSerie.Text, "Dados obrigatorios ausentes antes do agendamento");
                this.executarJavaScript("alert('Pesquise a série, selecione a loja e informe uma data válida antes de agendar.'); ");
                return;
            }

            try
            {
                vec.Conexao();
                SqlCommand oCmd = new SqlCommand();
                oCmd.Connection = vec.oCon;
                oCmd.CommandText = "APP..veiculos_patio_insert_agendamento";
                oCmd.CommandType = CommandType.StoredProcedure;
                oCmd.Parameters.Add("@ve_nr", SqlDbType.Int).Value = codVeiculo;
                oCmd.Parameters.Add("@fun_cad", SqlDbType.VarChar).Value = Session["usuario"];
                oCmd.Parameters.Add("@loja", SqlDbType.Int).Value = loja;
                oCmd.Parameters.Add("@dt_agend", SqlDbType.DateTime).Value = dataAgendamento;


                SqlDataReader odr = oCmd.ExecuteReader();
                odr.Read();
                if (odr["resultado"].ToString().Equals("n"))
                {
                    PatioJeepAuditoria.Registrar("AGENDAR_DUPLICADO", Session["usuario"], txtSerie.Text, "Veiculo ja tem agendamento registrado");
                    this.limpaCampos();
                    this.executarJavaScript("alert('Veículo já tem agendamento registrado!'); ");
                }
                else
                {
                    PatioJeepAuditoria.Registrar("AGENDAR_SUCESSO", Session["usuario"], txtSerie.Text, "Loja=" + ddlLoja.Value + "; Data=" + dt);
                    this.limpaCampos();
                    this.executarJavaScript("alert('Veículo agendado com sucesso.'); ");

                }
            }
            catch
            {
                PatioJeepAuditoria.Registrar("AGENDAR_ERRO", Session["usuario"], txtSerie.Text, "Erro ao gravar dados no banco");
                this.executarJavaScript("alert('Erro ao gravar dados no banco!'); ");
            }
            finally
            {
                vec.FecharConexao();
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
            veiculos.Conexao();
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
            veiculos.FecharConexao();
        }
        return retorno;
    }

    private void limpaCampos()
    {
        this.txtChassi.Text = "";
        this.txtModelo.Text = "";
        this.txtCor.Text = "";
        this.txtCodVec.Text = "";
        this.dtAgendamento.Text = "";
        this.txtPedido.Text = "";
        this.txtLocal.Text = "";
        this.txtSerie.Text = "";
    }

    private void executarJavaScript(String script)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", script + "$(\"#dtAgendamento\").datetimepicker({ format: 'yyyy-mm-dd hh:ii', autoclose: true });", true);
    }

}
