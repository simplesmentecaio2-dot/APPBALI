using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;

public partial class tecnologia_sessoes : System.Web.UI.Page
{
    private const int TempoSessaoMinutos = 15;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        lblUsuario.Text = Convert.ToString(Session["usuario"]);
        lblTipo.Text = Session["usuario_codigo"] == null ? "-" : Convert.ToString(Session["usuario_codigo"]);

        if (!IsPostBack)
        {
            CarregarSessoes();
        }
    }

    protected void btnAtualizar_Click(object sender, EventArgs e)
    {
        if (!UsuarioTecnologiaValido())
        {
            return;
        }

        CarregarSessoes();
    }

    private void CarregarSessoes()
    {
        ExpirarSessoesAntigas();

        DataTable sessoes = ConsultarSessoesAtivas();
        rptSessoes.DataSource = sessoes;
        rptSessoes.DataBind();
        pnlSemSessoes.Visible = sessoes.Rows.Count == 0;

        litTotalAtivas.Text = sessoes.Rows.Count.ToString();
        litUsuariosDistintos.Text = ContarUsuariosDistintos(sessoes).ToString();
        litMaiorTempo.Text = MaiorTempo(sessoes);
        litUltimaAtividade.Text = UltimaAtividade(sessoes);
        litAtualizadoEm.Text = "Atualizado em " + DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
    }

    private DataTable ConsultarSessoesAtivas()
    {
        string sql = @"
SELECT
    id_sessao,
    usuario_id,
    usuario_codigo,
    usuario_nome,
    usuario_tipo,
    usuario_email,
    empresa,
    session_id,
    ip,
    user_agent,
    url_login,
    data_login,
    ultimo_acesso,
    DATEDIFF(SECOND, data_login, SYSDATETIME()) AS segundos_logado,
    DATEDIFF(SECOND, ultimo_acesso, SYSDATETIME()) AS segundos_inativo,
    CASE
        WHEN (@timeout_segundos - DATEDIFF(SECOND, ultimo_acesso, SYSDATETIME())) < 0 THEN 0
        ELSE (@timeout_segundos - DATEDIFF(SECOND, ultimo_acesso, SYSDATETIME()))
    END AS segundos_restantes
FROM dbo.app_sessao_usuario WITH (READPAST)
WHERE ativo = 1
  AND ultimo_acesso >= DATEADD(MINUTE, -@timeout_minutos, SYSDATETIME())
ORDER BY ultimo_acesso DESC, data_login DESC;";

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString))
        using (SqlCommand cmd = new SqlCommand(sql, con))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = 20;
            cmd.Parameters.Add("@timeout_minutos", SqlDbType.Int).Value = TempoSessaoMinutos;
            cmd.Parameters.Add("@timeout_segundos", SqlDbType.Int).Value = TempoSessaoMinutos * 60;
            DataTable tabela = new DataTable();
            adapter.Fill(tabela);
            return tabela;
        }
    }

    private void ExpirarSessoesAntigas()
    {
        string sql = @"
UPDATE dbo.app_sessao_usuario
   SET ativo = 0,
       data_encerramento = COALESCE(data_encerramento, SYSDATETIME()),
       motivo_encerramento = N'TIMEOUT_SESSAO'
 WHERE ativo = 1
   AND ultimo_acesso < DATEADD(MINUTE, -@timeout_minutos, SYSDATETIME());";

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["APPWFConnectionString"].ConnectionString))
        using (SqlCommand cmd = new SqlCommand(sql, con))
        {
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = 20;
            cmd.Parameters.Add("@timeout_minutos", SqlDbType.Int).Value = TempoSessaoMinutos;
            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    protected string Html(object valor)
    {
        string texto = Convert.ToString(valor);
        return HttpUtility.HtmlEncode(String.IsNullOrWhiteSpace(texto) ? "-" : texto.Trim());
    }

    protected string DataHora(object valor)
    {
        if (valor == null || valor == DBNull.Value) return "-";
        DateTime data;
        if (!DateTime.TryParse(Convert.ToString(valor), out data)) return "-";
        return data.ToString("dd/MM/yyyy HH:mm:ss");
    }

    protected string Duracao(object valor)
    {
        int segundos;
        if (valor == null || valor == DBNull.Value || !Int32.TryParse(Convert.ToString(valor), out segundos) || segundos < 0)
        {
            segundos = 0;
        }

        TimeSpan duracao = TimeSpan.FromSeconds(segundos);
        if (duracao.TotalDays >= 1)
        {
            return String.Format("{0}d {1:00}h {2:00}m", (int)duracao.TotalDays, duracao.Hours, duracao.Minutes);
        }

        if (duracao.TotalHours >= 1)
        {
            return String.Format("{0:00}h {1:00}m", (int)duracao.TotalHours, duracao.Minutes);
        }

        return String.Format("{0:00}m {1:00}s", duracao.Minutes, duracao.Seconds);
    }

    protected string Origem(object valor)
    {
        string url = Convert.ToString(valor);
        if (String.IsNullOrWhiteSpace(url)) return "-";

        url = url.Trim();
        string lower = url.ToLowerInvariant();
        if (lower.IndexOf("/ci/") >= 0) return "CI";
        if (lower.IndexOf("/ramais/") >= 0) return "Ramais";
        if (lower.IndexOf("/tecnologia/") >= 0) return "Tecnologia";
        if (lower.IndexOf("/admfinanceiro/") >= 0) return "Adm. Financeiro";
        if (lower.IndexOf("/byd/") >= 0) return "BYD";
        if (lower.IndexOf("/jeep/") >= 0) return "Jeep";
        if (lower.IndexOf("/veiculos/") >= 0) return "Fiat";
        if (lower.IndexOf("/diretoria/") >= 0) return "Diretoria";

        return HttpUtility.HtmlEncode(url);
    }

    private int ContarUsuariosDistintos(DataTable tabela)
    {
        DataView view = new DataView(tabela);
        DataTable distintos = view.ToTable(true, "usuario_id");
        return distintos.Rows.Count;
    }

    private string MaiorTempo(DataTable tabela)
    {
        int maior = 0;
        foreach (DataRow row in tabela.Rows)
        {
            int segundos;
            if (Int32.TryParse(Convert.ToString(row["segundos_logado"]), out segundos) && segundos > maior)
            {
                maior = segundos;
            }
        }

        return Duracao(maior);
    }

    private string UltimaAtividade(DataTable tabela)
    {
        DateTime ultima = DateTime.MinValue;
        foreach (DataRow row in tabela.Rows)
        {
            if (row["ultimo_acesso"] == DBNull.Value) continue;
            DateTime data = Convert.ToDateTime(row["ultimo_acesso"]);
            if (data > ultima)
            {
                ultima = data;
            }
        }

        return ultima == DateTime.MinValue ? "-" : ultima.ToString("HH:mm:ss");
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
