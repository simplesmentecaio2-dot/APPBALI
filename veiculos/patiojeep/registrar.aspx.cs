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
using System.Text;

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
                    AtualizarBotaoSalvar(false);
                    pnlFeedback.Visible = false;
                    pnlNovaLeitura.Visible = false;
                    pnlVeiculoEncontrado.Visible = false;

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
                        AtualizarBotaoSalvar(false);
                        PatioJeepAuditoria.Registrar("REGISTRAR_CODIGO_BARRAS_INVALIDO", Session["usuario"], Request.QueryString["serie"], "Codigo recebido pela URL fora do padrao esperado");
                        MostrarMensagem("error", "C\u00f3digo inv\u00e1lido", "C\u00f3digo de barras n\u00e3o se refere a um chassi.");
                    }
                }
                txtCor.Enabled = false;
                txtModelo.Enabled = false;
                txtChassi.Enabled = false;
                txtCodVec.Enabled = false;
                RenderizarHistoricoRecente();
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

    private class RegistroRecente
    {
        public string Serie { get; set; }
        public string Modelo { get; set; }
        public string Cor { get; set; }
        public string Loja { get; set; }
        public DateTime Data { get; set; }
    }

    private string NormalizarCaracteresSerie(string valor)
    {
        if (String.IsNullOrWhiteSpace(valor))
        {
            return "";
        }

        List<char> caracteres = new List<char>();
        foreach (char caractere in valor)
        {
            if (Char.IsLetterOrDigit(caractere))
            {
                caracteres.Add(Char.ToUpperInvariant(caractere));
            }
        }

        return new String(caracteres.ToArray());
    }

    private string NormalizarSerieFormulario(string valor)
    {
        string caracteres = NormalizarCaracteresSerie(valor);

        if (caracteres.Length >= 17)
        {
            return caracteres.Substring(10, 7);
        }

        return caracteres;
    }

    private string ExtrairSerieCodigoBarras(string valor)
    {
        string serie = NormalizarSerieFormulario(valor);
        return serie.Length == 7 ? serie : "";
    }

    public void serieOnTextChanged(object sender, EventArgs e)
    {
        pnlNovaLeitura.Visible = false;
        txtSerie.Text = NormalizarSerieFormulario(txtSerie.Text);
        ResetarEstadoLoja();

        if (!txtSerie.Text.Equals(""))
        {
            if (txtSerie.Text.Length != 7)
            {
                txtChassi.Text = "";
                txtModelo.Text = "";
                txtCor.Text = "";
                txtCodVec.Text = "";
                txtNUMERONF.Text = "";
                AtualizarBotaoSalvar(false);
                pnlVeiculoEncontrado.Visible = false;
                PatioJeepAuditoria.Registrar("REGISTRAR_SERIE_INVALIDA", Session["usuario"], txtSerie.Text, "Serie informada com tamanho diferente de 7 caracteres");
                MostrarMensagem("error", "S\u00e9rie inv\u00e1lida", "O n\u00famero de s\u00e9rie deve conter exatamente 7 caracteres.");
                ExecutarScript("$('#myModal').modal('show');");
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
                        odr.Close();

                        string lojaAtual;
                        if (VeiculoJaRegistrado(txtSerie.Text, out lojaAtual))
                        {
                            AtualizarBotaoSalvar(false);
                            PreencherCardVeiculo("warning", "Ve\u00edculo j\u00e1 registrado", "Local atual: " + lojaAtual, "J\u00e1 cadastrado");
                            MostrarMensagem("warning", "Ve\u00edculo j\u00e1 cadastrado", "A s\u00e9rie " + txtSerie.Text + " j\u00e1 est\u00e1 registrada no p\u00e1tio. Se precisar movimentar, use a tela Transferir.");
                            PatioJeepAuditoria.Registrar("REGISTRAR_DUPLICADO_PREVIO", Session["usuario"], txtSerie.Text, "Local atual=" + lojaAtual);
                        }
                        else
                        {
                            AtualizarBotaoSalvar(true);
                            PreencherCardVeiculo("success", "Ve\u00edculo encontrado", "Confira os dados e selecione a loja antes de salvar.", "Pronto para salvar");
                            MostrarMensagem("success", "Ve\u00edculo encontrado", "Dados carregados. Confira a loja e toque em Salvar registro.");
                            ddlLoja.Focus();
                        }
                    }
                    else
                    {
                        txtChassi.Text = "";
                        txtModelo.Text = "";
                        txtCor.Text = "";
                        txtCodVec.Text = "";
                        txtNUMERONF.Text = "";
                        AtualizarBotaoSalvar(false);
                        pnlVeiculoEncontrado.Visible = false;
                        PatioJeepAuditoria.Registrar("REGISTRAR_SERIE_NAO_ENCONTRADA", Session["usuario"], txtSerie.Text, "Nenhum veiculo retornado pela procedure veiculos_patio_selectRegistrar");
                        MostrarMensagem("warning", "S\u00e9rie n\u00e3o encontrada", "S\u00e9rie " + txtSerie.Text + " n\u00e3o encontrada no sistema. Confira a etiqueta, tente ler novamente ou digite os 7 caracteres manualmente.");

                    }

                }
                catch (Exception ex)
                {
                    AtualizarBotaoSalvar(false);
                    pnlVeiculoEncontrado.Visible = false;
                    PatioJeepAuditoria.Registrar("REGISTRAR_SERIE_ERRO_CONSULTA", Session["usuario"], txtSerie.Text, ex.Message);
                    MostrarMensagem("error", "Erro na consulta", "N\u00e3o foi poss\u00edvel carregar os dados do ve\u00edculo agora. Tente novamente em instantes.");
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
            AtualizarBotaoSalvar(false);
            pnlVeiculoEncontrado.Visible = false;
            PatioJeepAuditoria.Registrar("REGISTRAR_SERIE_VAZIA", Session["usuario"], txtSerie.Text, "Pesquisa acionada sem informar a serie");
            MostrarMensagem("warning", "Informe a s\u00e9rie", "Digite a s\u00e9rie ou use o leitor antes de pesquisar.");
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
            pnlNovaLeitura.Visible = false;
            ResetarEstadoLoja();

            int codVeiculo;
            int loja;
            int numeroNota;
            if (!int.TryParse(txtCodVec.Text, out codVeiculo) || !int.TryParse(ddlLoja.Value, out loja) || !int.TryParse(txtNUMERONF.Text, out numeroNota))
            {
                MarcarLojaComErro();
                PatioJeepAuditoria.Registrar("REGISTRAR_VALIDACAO", Session["usuario"], txtSerie.Text, "Dados obrigatorios ausentes antes da gravacao");
                MostrarMensagem("error", "Dados obrigat\u00f3rios", "Pesquise a s\u00e9rie, confira os dados do ve\u00edculo e selecione a loja antes de salvar.");
                return;
            }

            string lojaAtual;
            if (VeiculoJaRegistrado(txtSerie.Text, out lojaAtual))
            {
                AtualizarBotaoSalvar(false);
                PreencherCardVeiculo("warning", "Ve\u00edculo j\u00e1 registrado", "Local atual: " + lojaAtual, "J\u00e1 cadastrado");
                PatioJeepAuditoria.Registrar("REGISTRAR_DUPLICADO_BLOQUEADO_ANTES_INSERT", Session["usuario"], txtSerie.Text, "Local atual=" + lojaAtual);
                MostrarMensagem("warning", "Registro j\u00e1 existente", "Este ve\u00edculo j\u00e1 est\u00e1 registrado no p\u00e1tio em " + lojaAtual + ". Use Transferir para alterar a localiza\u00e7\u00e3o.");
                return;
            }

            try
            {
                string serieRegistrada = txtSerie.Text;
                string modeloRegistrado = txtModelo.Text;
                string corRegistrada = txtCor.Text;
                string lojaRegistrada = ddlLoja.Items.Count > 0 && ddlLoja.SelectedIndex >= 0 ? ddlLoja.Items[ddlLoja.SelectedIndex].Text : ddlLoja.Value;

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
                string resultado = odr["resultado"].ToString();
                if (resultado.Equals("n"))
                {
                    PatioJeepAuditoria.Registrar("REGISTRAR_DUPLICADO", Session["usuario"], txtSerie.Text, "Veiculo ja cadastrado");
                    txtChassi.Text = "";
                    txtModelo.Text = "";
                    txtCor.Text = "";
                    txtCodVec.Text = "";
                    txtNUMERONF.Text = "";
                    AtualizarBotaoSalvar(false);
                    pnlVeiculoEncontrado.Visible = false;
                    MostrarMensagem("warning", "Ve\u00edculo j\u00e1 cadastrado", "Este ve\u00edculo j\u00e1 estava cadastrado no p\u00e1tio. Use a tela Transferir para alterar a localiza\u00e7\u00e3o.");
                }
                else if (resultado.Equals("v"))
                {
                    PatioJeepAuditoria.Registrar("REGISTRAR_VEICULO_VENDIDO", Session["usuario"], txtSerie.Text, "Veiculo encontrado em VendasVeiculos e bloqueado no patio");
                    txtChassi.Text = "";
                    txtModelo.Text = "";
                    txtCor.Text = "";
                    txtCodVec.Text = "";
                    txtNUMERONF.Text = "";
                    AtualizarBotaoSalvar(false);
                    pnlVeiculoEncontrado.Visible = false;
                    MostrarMensagem("warning", "Ve\u00edculo j\u00e1 vendido", "Este ve\u00edculo consta como vendido no sistema interno e foi baixado do p\u00e1tio automaticamente.");
                }
                else
                {
                    PatioJeepAuditoria.Registrar("REGISTRAR_SUCESSO", Session["usuario"], txtSerie.Text, "Loja=" + ddlLoja.Value + "; Veiculo=" + txtCodVec.Text);
                    AdicionarRegistroRecente(serieRegistrada, modeloRegistrado, corRegistrada, lojaRegistrada);
                    txtChassi.Text = "";
                    txtModelo.Text = "";
                    txtCor.Text = "";
                    txtCodVec.Text = "";
                    txtNUMERONF.Text = "";
                    txtSerie.Text = "";
                    AtualizarBotaoSalvar(false);
                    pnlVeiculoEncontrado.Visible = false;
                    litNovaLeitura.Text = "Ve\u00edculo " + Html(serieRegistrada) + " registrado em " + Html(lojaRegistrada) + ".";
                    pnlNovaLeitura.Visible = true;
                    MostrarMensagem("success", "Dados gravados", "Registro salvo com sucesso. Voc\u00ea j\u00e1 pode iniciar uma nova leitura.");
                    RenderizarHistoricoRecente();

                }

            }
            catch (Exception ex)
            {
                PatioJeepAuditoria.Registrar("REGISTRAR_ERRO", Session["usuario"], txtSerie.Text, "Erro ao gravar dados no banco: " + ex.Message);
                MostrarMensagem("error", "Erro ao gravar", "Erro ao gravar dados no banco. Confira a conex\u00e3o e tente novamente.");
            }
            finally
            {
                oJeep.FecharConexao2();
            }
        }
    }

    private void AtualizarBotaoSalvar(bool visivel)
    {
        btnRegistrar.Visible = visivel;
        btnRegistrarMobile.Visible = visivel;
        pnlMobileAction.Visible = visivel;
    }

    private void PreencherCardVeiculo(string tipo, string titulo, string subtitulo, string status)
    {
        pnlVeiculoEncontrado.Visible = true;
        pnlVeiculoEncontrado.CssClass = tipo == "warning" ? "patio-found-card is-warning" : "patio-found-card";
        litVeiculoTitulo.Text = Html(titulo);
        litVeiculoSubtitulo.Text = Html(subtitulo);
        litVeiculoStatus.Text = Html(status);
        litResumoSerie.Text = Html(txtSerie.Text);
        litResumoChassi.Text = Html(txtChassi.Text);
        litResumoModelo.Text = Html(txtModelo.Text);
        litResumoCor.Text = Html(txtCor.Text);
        litResumoNf.Text = Html(txtNUMERONF.Text);
    }

    private bool VeiculoJaRegistrado(string serie, out string lojaAtual)
    {
        lojaAtual = "";
        if (String.IsNullOrWhiteSpace(serie) || serie.Length != 7)
        {
            return false;
        }

        Jeep consulta = new Jeep();
        try
        {
            consulta.Conexao2();
            SqlCommand oCmd = new SqlCommand();
            oCmd.Connection = consulta.oCon2;
            oCmd.CommandText = "APP..veiculos_patio_selectTranferir";
            oCmd.CommandType = CommandType.StoredProcedure;
            oCmd.Parameters.Add("@chassi", SqlDbType.VarChar).Value = serie;
            SqlDataReader odr = oCmd.ExecuteReader();
            if (odr.Read())
            {
                lojaAtual = odr["ds"].ToString();
                return true;
            }
        }
        catch (Exception ex)
        {
            PatioJeepAuditoria.Registrar("REGISTRAR_DUPLICIDADE_ERRO", Session["usuario"], serie, ex.Message);
        }
        finally
        {
            consulta.FecharConexao2();
        }

        return false;
    }

    private void MostrarMensagem(string tipo, string titulo, string mensagem)
    {
        pnlFeedback.Visible = true;
        pnlFeedback.CssClass = "patio-operation-alert patio-operation-alert-" + tipo;
        feedbackIcon.Attributes["class"] = tipo == "success" ? "fa fa-check-circle" : tipo == "warning" ? "fa fa-exclamation-triangle" : tipo == "error" ? "fa fa-times-circle" : "fa fa-info-circle";
        litFeedbackTitulo.Text = Html(titulo);
        litFeedbackMensagem.Text = Html(mensagem);

        string toastTipo = tipo == "success" ? "success" : tipo == "warning" ? "warning" : tipo == "error" ? "error" : "info";
        string script = "if(window.patioToast){window.patioToast('" + Js(mensagem) + "','" + toastTipo + "');}";
        ExecutarScript(script);
    }

    private void ExecutarScript(string script)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), Guid.NewGuid().ToString("N"), script, true);
    }

    private string Html(object valor)
    {
        return HttpUtility.HtmlEncode(Convert.ToString(valor));
    }

    private string Js(string valor)
    {
        return HttpUtility.JavaScriptStringEncode(valor ?? "");
    }

    private void ResetarEstadoLoja()
    {
        ddlLoja.Attributes["class"] = "form-control";
    }

    private void MarcarLojaComErro()
    {
        ddlLoja.Attributes["class"] = "form-control patio-field-error";
        ExecutarScript("setTimeout(function(){var loja=document.getElementById('" + ddlLoja.ClientID + "'); if(loja){loja.focus();}},80);");
    }

    private void AdicionarRegistroRecente(string serie, string modelo, string cor, string loja)
    {
        List<RegistroRecente> registros = Session["patio_registros_recentes"] as List<RegistroRecente>;
        if (registros == null)
        {
            registros = new List<RegistroRecente>();
        }

        registros.Insert(0, new RegistroRecente
        {
            Serie = serie,
            Modelo = modelo,
            Cor = cor,
            Loja = loja,
            Data = DateTime.Now
        });

        Session["patio_registros_recentes"] = registros.Take(5).ToList();
    }

    private void RenderizarHistoricoRecente()
    {
        List<RegistroRecente> registros = Session["patio_registros_recentes"] as List<RegistroRecente>;
        if (registros == null || registros.Count == 0)
        {
            pnlHistoricoRecente.Visible = false;
            litHistoricoRecente.Text = "";
            return;
        }

        StringBuilder html = new StringBuilder();
        html.Append("<ul class=\"patio-recent-list\">");
        foreach (RegistroRecente registro in registros.Take(5))
        {
            html.Append("<li>");
            html.Append("<span><small>S\u00e9rie</small><br/>" + Html(registro.Serie) + "</span>");
            html.Append("<span><small>Modelo</small><br/>" + Html(registro.Modelo) + "</span>");
            html.Append("<span><small>Loja</small><br/>" + Html(registro.Loja) + "</span>");
            html.Append("<span><small>Hora</small><br/>" + registro.Data.ToString("HH:mm") + "</span>");
            html.Append("</li>");
        }
        html.Append("</ul>");

        litHistoricoRecente.Text = html.ToString();
        pnlHistoricoRecente.Visible = true;
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
