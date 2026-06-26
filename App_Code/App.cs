using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// Summary description for App
/// </summary>
public class App : Dao
{
    

	public void login(string id, string senha, out string usuario, out string tipo, out string email, out string ramal, out string celular, out string empresa ) 
	{
        LoginComSenhaLocalOuLegado(id, senha, "app..app_proc_login", true, out usuario, out tipo, out email, out ramal, out celular, out empresa);
	}

    public void loginBI(string id, string senha, out string usuario, out string tipo, out string email, out string ramal, out string celular, out string empresa)
    {
        LoginComSenhaLocalOuLegado(id, senha, "app..app_proc_loginBI", false, out usuario, out tipo, out email, out ramal, out celular, out empresa);
    }

    public bool AlterarSenhaLocal(string id, string senhaAtual, string novaSenha, string origem, out string mensagem)
    {
        mensagem = "";
        id = (id ?? "").Trim();
        senhaAtual = senhaAtual ?? "";
        novaSenha = novaSenha ?? "";

        if (id.Length == 0)
        {
            mensagem = "Informe o usuário.";
            return false;
        }

        if (senhaAtual.Length == 0)
        {
            mensagem = "Informe a senha atual.";
            return false;
        }

        if (novaSenha.Length < 6)
        {
            mensagem = "A nova senha deve ter pelo menos 6 caracteres.";
            return false;
        }

        if (String.Equals(senhaAtual, novaSenha, StringComparison.Ordinal))
        {
            mensagem = "A nova senha precisa ser diferente da senha atual.";
            return false;
        }

        string usuario, tipo, email, ramal, celular, empresa;
        bool existeSenhaLocal = AppSenhaLocal.ExisteSenhaLocalAtiva(id);

        if (existeSenhaLocal)
        {
            if (!AppSenhaLocal.ValidarSenha(id, senhaAtual))
            {
                AppSenhaLocal.RegistrarFalha(id, origem, HttpContext.Current, "senha atual local incorreta");
                mensagem = "Senha atual inválida.";
                return false;
            }

            if (!BuscarUsuarioAtivoSemSenha(id, true, out usuario, out tipo, out email, out ramal, out celular, out empresa))
            {
                AppSenhaLocal.RegistrarFalha(id, origem, HttpContext.Current, "usuario inativo na origem");
                mensagem = "Usuário inativo ou desligado na base de origem.";
                return false;
            }
        }
        else
        {
            LoginLegado("app..app_proc_login", id, senhaAtual, out usuario, out tipo, out email, out ramal, out celular, out empresa);
            if (usuario == "N")
            {
                mensagem = "Senha atual inválida ou usuário inativo.";
                return false;
            }
        }

        AppSenhaLocal.SalvarSenha(id, novaSenha, origem, HttpContext.Current);
        mensagem = "Senha alterada com sucesso. Use a nova senha no próximo acesso.";
        return true;
    }

    private void LoginComSenhaLocalOuLegado(string id, string senha, string procedureLegada, bool incluirUsuarioWf, out string usuario, out string tipo, out string email, out string ramal, out string celular, out string empresa)
    {
        PreencherLoginNegado(out usuario, out tipo, out email, out ramal, out celular, out empresa);

        id = (id ?? "").Trim();
        senha = senha ?? "";

        bool existeSenhaLocal = false;
        try
        {
            existeSenhaLocal = AppSenhaLocal.ExisteSenhaLocalAtiva(id);
        }
        catch
        {
            existeSenhaLocal = false;
        }

        if (existeSenhaLocal)
        {
            bool senhaLocalValida;
            try
            {
                senhaLocalValida = AppSenhaLocal.ValidarSenha(id, senha);
            }
            catch
            {
                senhaLocalValida = false;
            }

            if (!senhaLocalValida)
            {
                AppSenhaLocal.RegistrarFalha(id, "login", HttpContext.Current, "senha local incorreta");
                return;
            }

            bool usuarioAtivo;
            try
            {
                usuarioAtivo = BuscarUsuarioAtivoSemSenha(id, incluirUsuarioWf, out usuario, out tipo, out email, out ramal, out celular, out empresa);
            }
            catch
            {
                usuarioAtivo = false;
            }

            if (usuarioAtivo)
            {
                AppSenhaLocal.RegistrarLoginOk(id, "login", HttpContext.Current);
                return;
            }

            AppSenhaLocal.RegistrarFalha(id, "login", HttpContext.Current, "usuario inativo na origem");
            PreencherLoginNegado(out usuario, out tipo, out email, out ramal, out celular, out empresa);
            return;
        }

        LoginLegado(procedureLegada, id, senha, out usuario, out tipo, out email, out ramal, out celular, out empresa);
    }

    private void LoginLegado(string procedure, string id, string senha, out string usuario, out string tipo, out string email, out string ramal, out string celular, out string empresa)
    {
        PreencherLoginNegado(out usuario, out tipo, out email, out ramal, out celular, out empresa);
        Conexao();

        try
        {
            SqlCommand oCmd = new SqlCommand();
            oCmd.Connection = oCon;
            oCmd.CommandText = procedure;
            oCmd.CommandType = CommandType.StoredProcedure;
            oCmd.Parameters.Add("@id_usuario", SqlDbType.VarChar).Value = id;
            oCmd.Parameters.Add("@senha", SqlDbType.VarChar).Value = senha;
            SqlDataReader odr = oCmd.ExecuteReader();
            if (odr.Read())
            {
                usuario = odr["usuario"].ToString();
                tipo = odr["tipo"].ToString();
                email = odr["email"].ToString();
                ramal = odr["fun_ramal"].ToString();
                celular = odr["fun_radio"].ToString();
                empresa = odr["emp"].ToString();
            }
        }
        finally
        {
            FecharConexao();
        }
    }

    private bool BuscarUsuarioAtivoSemSenha(string id, bool incluirUsuarioWf, out string usuario, out string tipo, out string email, out string ramal, out string celular, out string empresa)
    {
        PreencherLoginNegado(out usuario, out tipo, out email, out ramal, out celular, out empresa);
        Conexao();

        try
        {
            SqlCommand oCmd = new SqlCommand();
            oCmd.Connection = oCon;
            oCmd.CommandType = CommandType.Text;
            oCmd.CommandText = @"
                IF (SELECT COUNT(1)
                      FROM app..app_tab_usuario u
                      INNER JOIN fiatnet_prod..tab_fun f ON u.id_usuario = f.fun_email
                      INNER JOIN fiatnet_prod..tab_funemp femp ON f.fun_cd = femp.fun_cd AND funemp_default = 'S'
                     WHERE u.id_usuario = @id_usuario
                       AND f.fun_dtsai IS NULL) > 0
                BEGIN
                    SELECT TOP 1 u.id_usuario,
                           f.fun_nmguerra usuario,
                           u.tipo,
                           LOWER(f.fun_email) email,
                           f.fun_ramal,
                           f.fun_radio,
                           CASE femp.emp_cd
                                WHEN '01' THEN 'SIA'
                                WHEN '02' THEN 'SCIA'
                                WHEN '03' THEN 'SAAN'
                                WHEN '04' THEN 'AERO'
                                ELSE 'N'
                           END emp
                      FROM app..app_tab_usuario u
                      INNER JOIN fiatnet_prod..tab_fun f ON u.id_usuario = f.fun_email
                      INNER JOIN fiatnet_prod..tab_funemp femp ON f.fun_cd = femp.fun_cd AND funemp_default = 'S'
                     WHERE u.id_usuario = @id_usuario
                       AND f.fun_dtsai IS NULL;
                END
                ELSE IF (SELECT COUNT(1)
                           FROM fiatnet_prod..tab_fun
                          WHERE fun_nmguerra = @id_usuario
                            AND fun_dtsai IS NULL) > 0
                BEGIN
                    SELECT TOP 1 fun_nmguerra AS usuario,
                           'USUÁRIO' AS tipo,
                           'N' AS email,
                           'N' AS fun_ramal,
                           'N' AS fun_radio,
                           'N' AS emp
                      FROM fiatnet_prod..tab_fun
                     WHERE fun_nmguerra = @id_usuario
                       AND fun_dtsai IS NULL;
                END
                ELSE IF (SELECT COUNT(1)
                           FROM app..app_tab_usuario
                          WHERE id_usuario = @id_usuario
                            AND ISNULL(ativo, 'S') = 'S') > 0
                BEGIN
                    SELECT TOP 1 id_usuario,
                           usuario,
                           tipo,
                           id_usuario AS email,
                           'N' AS fun_ramal,
                           'N' AS fun_radio,
                           'N' AS emp
                      FROM app..app_tab_usuario
                     WHERE id_usuario = @id_usuario
                       AND ISNULL(ativo, 'S') = 'S';
                END
                ELSE IF @incluir_usuario_wf = 1
                    AND (SELECT COUNT(1)
                           FROM app..usuariowf
                          WHERE usuario_identificador = @id_usuario
                            AND Usuario_DataDemissao IS NULL) > 0
                BEGIN
                    SELECT TOP 1 usuario_identificador AS usuario,
                           'USUÁRIO' AS tipo,
                           'N' AS email,
                           'N' AS fun_ramal,
                           'N' AS fun_radio,
                           'N' AS emp
                      FROM app..usuariowf
                     WHERE usuario_identificador = @id_usuario
                       AND Usuario_DataDemissao IS NULL;
                END
                ELSE
                BEGIN
                    SELECT 'N' AS id_usuario,
                           'N' AS usuario,
                           'N' AS tipo,
                           'N' AS email,
                           'N' AS fun_ramal,
                           'N' AS fun_radio,
                           'N' AS emp;
                END";
            oCmd.Parameters.Add("@id_usuario", SqlDbType.VarChar, 50).Value = id;
            oCmd.Parameters.Add("@incluir_usuario_wf", SqlDbType.Bit).Value = incluirUsuarioWf;

            SqlDataReader odr = oCmd.ExecuteReader();
            if (!odr.Read()) return false;

            usuario = odr["usuario"].ToString();
            tipo = odr["tipo"].ToString();
            email = odr["email"].ToString();
            ramal = odr["fun_ramal"].ToString();
            celular = odr["fun_radio"].ToString();
            empresa = odr["emp"].ToString();
            return usuario != "N";
        }
        finally
        {
            FecharConexao();
        }
    }

    private void PreencherLoginNegado(out string usuario, out string tipo, out string email, out string ramal, out string celular, out string empresa)
    {
        usuario = "N";
        tipo = "N";
        email = "N";
        ramal = "N";
        celular = "N";
        empresa = "N";
    }

    public int verificaPermissaoSistema(string id_isuario, string sistema)
    {
        Conexao();

        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = oCon;
        oCmd.CommandText = "app..app_verifica_permissao_sistema";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@id_usuario", SqlDbType.VarChar).Value = id_isuario;
        oCmd.Parameters.Add("@sistema", SqlDbType.VarChar).Value = sistema;
        SqlDataReader odr = oCmd.ExecuteReader();
        odr.Read();
        int permissao = Convert.ToInt16(odr["permissao"]);
        FecharConexao();
        return permissao;
    }

    public void InsertUsuario(string id_usuario, string usuario, string senha, string ativo, string tipo, out string obs)
    {
        Conexao();
        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = oCon;
        oCmd.CommandText = "app..app_insert_usuario";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@id_usuario", SqlDbType.VarChar).Value = id_usuario;
        oCmd.Parameters.Add("@usuario", SqlDbType.VarChar).Value = usuario;
        oCmd.Parameters.Add("@senha", SqlDbType.VarChar).Value = senha;
        oCmd.Parameters.Add("@ativo", SqlDbType.VarChar).Value = ativo;
        oCmd.Parameters.Add("@tipo", SqlDbType.VarChar).Value = tipo;
        SqlDataReader odr = oCmd.ExecuteReader();
        odr.Read();
        obs = odr["obs"].ToString();
        FecharConexao();
    }

    public void UpdateUsuario(string id_usuario, string usuario, string ativo, string tipo, out string obs)
    {
        Conexao();
        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = oCon;
        oCmd.CommandText = "app..app_update_usuario";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@id_usuario", SqlDbType.VarChar).Value = id_usuario;
        oCmd.Parameters.Add("@usuario", SqlDbType.VarChar).Value = usuario;
        oCmd.Parameters.Add("@ativo", SqlDbType.VarChar).Value = ativo;
        oCmd.Parameters.Add("@tipo", SqlDbType.VarChar).Value = tipo;
        SqlDataReader odr = oCmd.ExecuteReader();
        odr.Read();
        obs = odr["obs"].ToString();
        FecharConexao();
    }

    public void UpdateUsuarioSistema(string id_usuario, int id_sistema, int condicao)
    {
        Conexao();
        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = oCon;
        oCmd.CommandText = "app..app_update_usuario_sistema";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@id_usuario", SqlDbType.VarChar).Value = id_usuario;
        oCmd.Parameters.Add("@id_sistema", SqlDbType.Int).Value = id_sistema;
        oCmd.Parameters.Add("@condicao", SqlDbType.Int).Value = condicao;
        SqlDataReader odr = oCmd.ExecuteReader();
        FecharConexao();
    }

    public void UpdateUsuarioPerfil(string id_usuario, int id_sistema, string perfil)
    {
        Conexao();
        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = oCon;
        oCmd.CommandText = "app..app_update_usuario_perfil";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@id_usuario", SqlDbType.VarChar).Value = id_usuario;
        oCmd.Parameters.Add("@id_sistema", SqlDbType.Int).Value = id_sistema;
        oCmd.Parameters.Add("@perfil", SqlDbType.VarChar).Value = perfil;
        SqlDataReader odr = oCmd.ExecuteReader();
        FecharConexao();
    }

    public void UpdateUsuarioSenha(string id_usuario, string senha, out string obs)
    {
        Conexao();
        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = oCon;
        oCmd.CommandText = "app..app_update_usuario_senha";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@id_usuario", SqlDbType.VarChar).Value = id_usuario;
        oCmd.Parameters.Add("@senha", SqlDbType.VarChar).Value = senha;
        SqlDataReader odr = oCmd.ExecuteReader();
        odr.Read();
        obs = odr["obs"].ToString();
        FecharConexao();
    }

    public void InsertUsuarioSistema(string id_usuario, int sistema)
    {
        Conexao();
        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = oCon;
        oCmd.CommandText = "app..app_insert_usuario_sistema";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@id_usuario", SqlDbType.VarChar).Value = id_usuario;
        oCmd.Parameters.Add("@id_sistema", SqlDbType.Int).Value = sistema;
        SqlDataReader odr = oCmd.ExecuteReader();
        //odr.Read();
        FecharConexao();
    }

    public void select_usuario(string id_usuario, out string usuario, out string senha, out string ativo, out string tipo)
    {
        Conexao();
        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = oCon;
        oCmd.CommandText = "app..app_select_usuario";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@id_usuario", SqlDbType.VarChar).Value = id_usuario;
        
        SqlDataReader odr = oCmd.ExecuteReader();
        odr.Read();
        usuario = odr["usuario"].ToString();
        senha = odr["senha"].ToString();
        ativo = odr["ativo"].ToString();
        tipo = odr["tipo"].ToString();

        FecharConexao();
    }

    public void select_sistema_usuario_alterar(string id_usuario, int id_sistema, out int sistema)
    {
        Conexao();
        SqlCommand oCmd = new SqlCommand();
        oCmd.Connection = oCon;
        oCmd.CommandText = "app..app_select_sistemas_usuario_alterar";
        oCmd.CommandType = CommandType.StoredProcedure;
        oCmd.Parameters.Add("@id_usuario", SqlDbType.VarChar).Value = id_usuario;
        oCmd.Parameters.Add("@id_sistema", SqlDbType.Int).Value = id_sistema;
        SqlDataReader odr = oCmd.ExecuteReader();
        odr.Read();
        sistema = Convert.ToInt16(odr["id_sistema"]);
                
        FecharConexao();

    }

    //public void select_permissao(string perfil, string janela, CheckBoxList list)
    //{
    //    Conexao();

    //    SqlCommand oCmd = new SqlCommand();
    //    oCmd.Connection = oCon;
    //    oCmd.CommandText = "select_acesso";
    //    oCmd.CommandType = CommandType.StoredProcedure;

    //    oCmd.Parameters.Add("@perfil", SqlDbType.VarChar).Value = perfil;
    //    oCmd.Parameters.Add("@janela", SqlDbType.VarChar).Value = janela;

    //    SqlDataReader odr = oCmd.ExecuteReader();
    //    int i = 0;
    //    while (odr.Read())
    //    {
    //        if (odr["acesso"].ToString() == "")
    //        {
    //            list.Items.Add(odr["descricao"].ToString());
    //            list.Items[i].Value = odr["obj"].ToString();
    //            list.Items[i].Selected = true;
    //            i++;

    //        }

    //        else
    //        {
    //            list.Items.Add(odr["descricao"].ToString());
    //            list.Items[i].Value = odr["obj"].ToString();
    //            list.Items[i].Selected = false;
    //            i++;
    //        }

    //    }

    //    //senhaR = odr["senha"].ToString();
    //    //perfil = odr["fun_perfil"].ToString();

    //    FecharConexao();
    //}

   
}
