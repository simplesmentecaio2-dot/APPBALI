using System;
using System.Web.UI;
using System.Data;
using System.Data.SqlClient;

public partial class veiculos_contrato : System.Web.UI.Page
{
    String ve_nr = "";

    protected void Page_Load(object sender, EventArgs e)
    {

        if (Session["id"] != null)
        {
            if (getAcesso(1).Equals("s"))
            {
                usuarioLogado.Text = Session["usuario"].ToString();
                try
                {
                    if (Request.QueryString["ve_nr"] != null)
                    {

                        ve_nr = Request.QueryString["ve_nr"].ToString();
                        btnProcessar_Click(sender, e);

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
            Response.Redirect("./login.aspx?voltar=" + Server.UrlEncode(Request.RawUrl));
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
        this.dtAgendamento.Text = "";
        this.txtSerie.Text = "";
    }

    private void executarJavaScript(String script)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "javascript", script +
            "$(\"#dtAgendamento\").datetimepicker({ format: 'yyyy-mm-dd', autoclose: true, language: 'pt-BR' });$('#tablelvd').DataTable();", true);
    }

    protected void btnProcessar_Click(object sender, EventArgs e)
    {
        string dt = Request.Form[dtAgendamento.UniqueID];

        Veiculos vec = new Veiculos();
        try
        {

            vec.Conexao();

            System.Data.SqlClient.SqlCommand oCmd = new System.Data.SqlClient.SqlCommand();
            oCmd.Connection = vec.oCon;
            oCmd.CommandType = CommandType.StoredProcedure;
            oCmd.CommandText = "APP..veiculos_patio_select_acompanhamento_status";
            oCmd.Parameters.Add("@ve_nr", SqlDbType.VarChar).Value = this.ve_nr;
            System.Data.SqlClient.SqlDataReader odr = oCmd.ExecuteReader();

            if (odr.Read())
            {
                mostrarDivVeiculoAgendado();

                if (!(odr["dt_agend"].ToString() == null) && !(odr["dt_agend"].ToString().Equals(""))) {
                    this.literalDataAgendamento.Text = odr["dt_agend"].ToString();
                    this.literalLojaAgendamento.Text = odr["local_agend"].ToString();


                    //DIV LOCALIZAÇÃO
                    if(!(odr["localizacao"] == null))
                    {
                        this.literaLocalizacao.Text = odr["localizacao"].ToString();
                        if (odr["local_agend"].ToString().Equals(odr["localizacao"])) 
                        {
                            this.statusLocalizacaoConcluido.Visible = true;
                            this.statusLocalizacaoPendante.Visible = false;
                        } 
                        else 
                        {
                            this.statusLocalizacaoConcluido.Visible = false;
                            this.statusLocalizacaoPendante.Visible = true;
                        }
                    }
                    else
                    {
                        this.literaLocalizacao.Text = "SEM LOCALIZAÇÃO";
                        this.statusLocalizacaoConcluido.Visible = false;
                        this.statusLocalizacaoPendante.Visible = true;
                    }

                    //DIV REVISÃO
                    if(!(odr["dt_ini_rev"] == null) && !(odr["dt_ini_rev"].ToString().Equals("")))
                    {
                        if (!(odr["dt_fim_rev"] == null) && !(odr["dt_fim_rev"].ToString().Equals("")))
                        {
                            revisaoConcluida();

                            this.literalRevisaoInicio.Text = odr["dt_ini_rev"].ToString();
                            this.literalRevisaoFim.Text = odr["dt_fim_rev"].ToString();
                        }
                        else
                        {
                            revisaoIniciada();

                            this.literalRevisaoInicio.Text = odr["dt_ini_rev"].ToString();
                        }
                    }
                    else 
                    {
                        revisaoNaoIniciada();
                    }


                    //DIV REQUISIÇÃO DE ACESSÓRIOS
                    if(!(odr["requisicoes"] == null))
                    {
                        mostrarDivRequisicoes();
                        literalAcessoriosRequisitados.Text = odr["requisicoes"].ToString();
                    }
                    else
                    {
                        mostrarDivSemRequisicoes();
                    }

                    //DIV INSTALAÇÃO DE ACESSÓRIO


                    //DIV SERVICOS DE TERCEIROS
                    //DIV ENTREGADOR

                }
                else
                {
                    this.mostrarDivNaoVeiculoAgendado();
                }
            }
            else 
            {
                this.mostrarDivNaoVeiculoAgendado();
            }
        }
        catch
        {
            this.mostrarDivNaoVeiculoAgendado();
        }
        finally
        {
            vec.FecharConexao(); 
            executarJavaScript("");
        }
    }

    private void mostrarDivSemRequisicoes()
    {
        this.divAcessorioNaoRequisitado.Visible = true;
        this.divAcessorioRequisitado.Visible = false;
        this.statusRequisicaoAcessorioConcluido.Visible = false;
        this.statusRequisicaoAcessorioPendente.Visible = true;
    }

    private void mostrarDivRequisicoes()
    {
        this.divAcessorioNaoRequisitado.Visible = false;
        this.divAcessorioRequisitado.Visible = true;
        this.statusRequisicaoAcessorioConcluido.Visible = true;
        this.statusRequisicaoAcessorioPendente.Visible = false;
    }

    private void revisaoConcluida()
    {
        this.divRevisaoIniciada.Visible = true;
        this.divRevisaoNãoIniciada.Visible = false;
        this.statusRevisaoConcluido.Visible = true;
        this.statusRevisaoEmAndamento.Visible = false;
        this.statusRevisaoPendente.Visible = false;
        this.literalRevisaoFim.Visible = true;
    }
    private void revisaoIniciada()
    {
        this.literalRevisaoFim.Visible = false;
        this.divRevisaoIniciada.Visible = true;
        this.divRevisaoNãoIniciada.Visible = false;
        this.statusRevisaoConcluido.Visible = false;
        this.statusRevisaoEmAndamento.Visible = true;
        this.statusRevisaoPendente.Visible = false;
    }
    private void mostrarDivVeiculoAgendado()
    {
        this.divVeiculoAgendado.Visible = true;
        this.divVeiculoNaoAgendado.Visible = false;
    }
    private void mostrarDivNaoVeiculoAgendado()
    {
        this.divVeiculoAgendado.Visible = false;
        this.divVeiculoNaoAgendado.Visible = true;
    }
    private void revisaoNaoIniciada()
    {
        this.divRevisaoIniciada.Visible = false;
        this.divRevisaoNãoIniciada.Visible = true;
        this.statusRevisaoConcluido.Visible = false;
        this.statusRevisaoEmAndamento.Visible = false;
        this.statusRevisaoPendente.Visible = true;
    } 

}
