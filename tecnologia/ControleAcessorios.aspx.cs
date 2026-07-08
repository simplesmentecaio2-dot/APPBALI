using System;
using System.Data;
using System.Globalization;
using System.Web;

public partial class tecnologia_ControleAcessorios : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        lblUsuario.Text = Convert.ToString(Session["usuario"]);
        lblCodigo.Text = Session["usuario_codigo"] == null ? "-" : Convert.ToString(Session["usuario_codigo"]);

        if (!IsPostBack)
        {
            CarregarDados("", false);
        }
    }

    protected void btnAtualizar_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;
        CarregarDados("Listagem atualizada com os dados em aberto do sistema.", true);
    }

    protected void btnMarcarEmitidas_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;

        string[] chaves = Request.Form.GetValues("acessorioSelecionado");
        int total = ControleAcessoriosDados.MarcarEmitidas(chaves, UsuarioCodigo(), UsuarioNome(), Context);

        if (total == 0)
        {
            CarregarDados("Selecione pelo menos uma linha para marcar como NF emitida.", false);
            return;
        }

        CarregarDados(total.ToString() + " registro(s) marcado(s) como NF emitida.", true);
    }

    protected void btnDesmarcarEmitidas_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido()) return;

        string[] chaves = Request.Form.GetValues("acessorioSelecionado");
        int total = ControleAcessoriosDados.DesmarcarEmitidas(chaves, UsuarioCodigo(), UsuarioNome(), Context);

        if (total == 0)
        {
            CarregarDados("Selecione pelo menos uma linha para desmarcar.", false);
            return;
        }

        CarregarDados(total.ToString() + " registro(s) desmarcado(s).", true);
    }

    private void CarregarDados(string mensagem, bool sucesso)
    {
        try
        {
            DataTable dados = ControleAcessoriosDados.ListarAbertos();
            rptAcessorios.DataSource = dados;
            rptAcessorios.DataBind();
            pnlSemDados.Visible = dados.Rows.Count == 0;

            int emitidos = 0;
            int pendentes = 0;
            decimal saldoPendente = 0;
            DateTime menorVencimento = DateTime.MinValue;

            foreach (DataRow row in dados.Rows)
            {
                bool emitido = EstaEmitido(row["Emitido"]);
                if (emitido)
                {
                    emitidos++;
                }
                else
                {
                    pendentes++;
                    saldoPendente += DecimalValor(row["Saldo"]);

                    DateTime vencimento;
                    if (DateTime.TryParse(Convert.ToString(row["DataVencimentoValor"]), out vencimento))
                    {
                        if (menorVencimento == DateTime.MinValue || vencimento < menorVencimento)
                        {
                            menorVencimento = vencimento;
                        }
                    }
                }
            }

            litTotal.Text = dados.Rows.Count.ToString();
            litEmitidos.Text = emitidos.ToString();
            litPendentes.Text = pendentes.ToString();
            litSaldoPendente.Text = Moeda(saldoPendente);
            litPrimeiroVencimento.Text = menorVencimento == DateTime.MinValue ? "-" : menorVencimento.ToString("dd/MM/yyyy");
            litAtualizacao.Text = "Atualizado em " + DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");

            MostrarMensagem(mensagem, sucesso);
        }
        catch
        {
            rptAcessorios.DataSource = null;
            rptAcessorios.DataBind();
            pnlSemDados.Visible = true;
            litTotal.Text = "0";
            litEmitidos.Text = "0";
            litPendentes.Text = "0";
            litSaldoPendente.Text = "R$ 0,00";
            litPrimeiroVencimento.Text = "-";
            litAtualizacao.Text = "Falha ao atualizar";
            MostrarMensagem("N\u00e3o foi poss\u00edvel carregar o controle de acess\u00f3rios agora. Tente novamente em alguns instantes.", false);
        }
    }

    private void MostrarMensagem(string mensagem, bool sucesso)
    {
        if (String.IsNullOrWhiteSpace(mensagem))
        {
            litMensagem.Text = "";
            return;
        }

        string classe = sucesso ? "accessory-alert is-success" : "accessory-alert is-error";
        litMensagem.Text = "<div class=\"" + classe + "\">" + HttpUtility.HtmlEncode(mensagem) + "</div>";
    }

    protected string Html(object valor)
    {
        string texto = Convert.ToString(valor);
        return HttpUtility.HtmlEncode(String.IsNullOrWhiteSpace(texto) ? "-" : texto.Trim());
    }

    protected string Chave(object valor)
    {
        string texto = Convert.ToString(valor);
        return HttpUtility.HtmlAttributeEncode(String.IsNullOrWhiteSpace(texto) ? "" : texto.Trim());
    }

    protected string LinhaClasse(object emitido)
    {
        return EstaEmitido(emitido) ? "accessory-row is-issued" : "accessory-row";
    }

    protected string StatusClasse(object emitido)
    {
        return EstaEmitido(emitido) ? "accessory-status is-issued" : "accessory-status is-pending";
    }

    protected string StatusTexto(object emitido)
    {
        return EstaEmitido(emitido) ? "NF emitida" : "Pendente";
    }

    protected string Moeda(object valor)
    {
        decimal numero = DecimalValor(valor);
        return numero.ToString("C", new CultureInfo("pt-BR"));
    }

    protected string Marcacao(object emitido, object usuario, object data)
    {
        if (!EstaEmitido(emitido)) return "-";

        string usuarioTexto = Convert.ToString(usuario);
        string dataTexto = Convert.ToString(data);

        if (String.IsNullOrWhiteSpace(usuarioTexto)) usuarioTexto = "Usu\u00e1rio n\u00e3o identificado";
        if (String.IsNullOrWhiteSpace(dataTexto)) return HttpUtility.HtmlEncode(usuarioTexto);

        return HttpUtility.HtmlEncode(usuarioTexto.Trim()) + "<small>" + HttpUtility.HtmlEncode(dataTexto.Trim()) + "</small>";
    }

    private bool EstaEmitido(object valor)
    {
        if (valor == null || valor == DBNull.Value) return false;
        bool booleano;
        if (Boolean.TryParse(Convert.ToString(valor), out booleano)) return booleano;
        return Convert.ToString(valor) == "1";
    }

    private decimal DecimalValor(object valor)
    {
        if (valor == null || valor == DBNull.Value) return 0;
        decimal numero;
        if (Decimal.TryParse(Convert.ToString(valor), NumberStyles.Any, CultureInfo.InvariantCulture, out numero)) return numero;
        if (Decimal.TryParse(Convert.ToString(valor), NumberStyles.Any, new CultureInfo("pt-BR"), out numero)) return numero;
        return 0;
    }

    private string UsuarioCodigo()
    {
        return Session["usuario_codigo"] == null ? "" : Convert.ToString(Session["usuario_codigo"]).Trim();
    }

    private string UsuarioNome()
    {
        return Session["usuario"] == null ? "" : Convert.ToString(Session["usuario"]).Trim();
    }

    private bool UsuarioTecnologiaValido()
    {
        if (Session["id"] == null)
        {
            RedirecionarLogin();
            return false;
        }

        App oApp = new App();
        int permissao = oApp.verificaPermissaoSistema(Convert.ToString(Session["id"]), "TECNOLOGIA");
        if (permissao != 1)
        {
            RedirecionarLogin();
            return false;
        }

        return true;
    }

    private void RedirecionarLogin()
    {
        Response.Redirect("../Login.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }
}
