using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Text;

public partial class veiculos_contrato : System.Web.UI.Page
{
    private const string TabelaContratosBI = "APP.dbo.veiculos_contrato_vendaBYD";
    private const string MarcaContrato = "BYD";
    private const int DiasMaximosBI = 370;
    private const int DiasMaximosConsulta = 370;
    private const int TimeoutConsultaSegundos = 60;

    protected void Page_Load(object sender, EventArgs e)
    {


        if (Session["usuario"] == null || Session["usuario"].ToString().Equals(""))
        {
            Response.Redirect("./loginAppcontrato.aspx");
        }
        else
        {
            lblUsuario.Text = Session["usuario"].ToString();
        }

        InicializarPeriodoConsulta();
        InicializarPeriodoBI();
        if (!IsPostBack)
        {
            CarregarBI();
        }
        auditoriaHtml = MontarHtmlAuditoriaContrato();
        if (String.IsNullOrEmpty(historicoHtml))
        {
            historicoHtml = "<div class='contract-audit-empty'>Informe o ID de um contrato para consultar o histórico de alterações e ocorrências.</div>";
        }

    }
    public string tabela;
    public string tabelaVU;
    public string tabelaVD;
    public string biHtml;
    public string auditoriaHtml;
    public string historicoHtml;

    private static readonly CultureInfo CulturaBrasil = new CultureInfo("pt-BR");

    private void InicializarPeriodoConsulta()
    {
        DateTime inicio = DateTime.Today.AddDays(-2);
        DateTime fim = DateTime.Today;

        if (txtDtInicialVN.Text.Length == 0) txtDtInicialVN.Text = inicio.ToString("dd/MM/yyyy");
        if (txtDtFinalVN.Text.Length == 0) txtDtFinalVN.Text = fim.ToString("dd/MM/yyyy");
        if (txtDtInicialVU.Text.Length == 0) txtDtInicialVU.Text = inicio.ToString("dd/MM/yyyy");
        if (txtDtFinalVU.Text.Length == 0) txtDtFinalVU.Text = fim.ToString("dd/MM/yyyy");
    }

    private void ExibirAlerta(string mensagem)
    {
        string script = "alert('" + HttpUtility.JavaScriptStringEncode(mensagem) + "');";
        ScriptManager.RegisterStartupScript(this, this.GetType(), Guid.NewGuid().ToString("N"), script, true);
    }

    private string UsuarioAtual()
    {
        return Session["usuario"] == null ? "sem usuario" : Session["usuario"].ToString();
    }

    private string LimparLog(string valor)
    {
        return (valor ?? "").Replace("\r", " ").Replace("\n", " ").Replace("\t", " ").Trim();
    }

    private void RegistrarContratoOperacao(string acao, string detalhe)
    {
        try
        {
            string pasta = Server.MapPath("~/App_Data");
            Directory.CreateDirectory(pasta);
            string contexto = "";
            try
            {
                contexto = "Pagina=" + Request.AppRelativeCurrentExecutionFilePath + "; IP=" + Request.UserHostAddress + "; ";
            }
            catch
            {
            }

            string linha = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss", CulturaBrasil)
                + "\t" + MarcaContrato
                + "\t" + LimparLog(UsuarioAtual())
                + "\t" + LimparLog(acao)
                + "\t" + LimparLog(contexto + detalhe);

            File.AppendAllText(Path.Combine(pasta, "contrato-operacoes.log"), linha + Environment.NewLine, Encoding.UTF8);
        }
        catch
        {
        }
    }

    private string DetalheContratoNovo(string tipo)
    {
        return "Tipo=" + tipo
            + "; Cliente=" + txtCliente.Text
            + "; CPF/CNPJ=" + txtCPFCNPJ.Text
            + "; Chassi/Placa=" + txtChassiPlaca.Text
            + "; Modelo=" + txtModelo.Text
            + "; Vendedor=" + ddlVendedor.Text
            + "; Valor=" + txtValoVeiculo.Text;
    }

    private string DetalheContratoEdicao()
    {
        return "Contrato=" + txtContrato.Text
            + "; Cliente=" + txtEdCliente.Text
            + "; CPF/CNPJ=" + txtEdCPF.Text
            + "; Chassi/Placa=" + txtEdChassi.Text
            + "; Modelo=" + txtEdModelo.Text
            + "; Vendedor=" + txtEdVendedor.Text
            + "; Valor=" + txtEdValorVeic.Text;
    }

    private void RegistrarValidacaoContrato(string acao, string detalheContrato, string mensagem)
    {
        RegistrarContratoOperacao(acao, detalheContrato + "; Pendencias=" + (mensagem ?? "").Replace("\n", " | "));
    }

    private bool RetornoProcedureDuplicidade(string obs, string codigo)
    {
        return String.Equals(obs, "N", StringComparison.OrdinalIgnoreCase) && !String.IsNullOrEmpty(codigo);
    }

    private string MensagemDuplicidadeProcedure(string codigo)
    {
        return "Possível duplicidade: já existe um contrato semelhante. Código: " + codigo + ". Confira CPF/CNPJ, chassi/placa, modelo e valor antes de tentar gravar novamente.";
    }

    private string MensagemErroProcedure(string obs, string codigo)
    {
        string retorno = String.IsNullOrEmpty(obs) ? "sem retorno" : obs;
        string contrato = String.IsNullOrEmpty(codigo) ? "sem código" : codigo;
        return "Não foi possível gravar o contrato. Retorno do banco: " + retorno + " (" + contrato + "). Confira campos obrigatórios, valores e vendedor.";
    }

    private string NormalizarChave(string valor)
    {
        StringBuilder texto = new StringBuilder();
        foreach (char caractere in (valor ?? "").ToUpperInvariant())
        {
            if (Char.IsLetterOrDigit(caractere))
            {
                texto.Append(caractere);
            }
        }
        return texto.ToString();
    }

    private bool ExisteContratoSemelhante(string tipo, out string contratoEncontrado)
    {
        contratoEncontrado = "";
        string cpf = NormalizarChave(txtCPFCNPJ.Text);
        string chassi = NormalizarChave(txtChassiPlaca.Text);
        string modelo = (txtModelo.Text ?? "").Trim().ToUpperInvariant();

        if (cpf.Length == 0 && chassi.Length == 0)
        {
            return false;
        }

        Veiculos vec = new Veiculos();
        try
        {
            vec.Conexao();
            using (SqlCommand oCmd = new SqlCommand())
            {
                oCmd.Connection = vec.oCon;
                oCmd.CommandTimeout = TimeoutConsultaSegundos;
                oCmd.CommandText = @"select top 1 id, [data], cliente, modelo, vendedor, valorveiculo
                                     from " + TabelaContratosBI + @"
                                     where [data] >= dateadd(day, -30, getdate())
                                       and tipo = @tipo
                                       and (
                                            (@chassi <> '' and upper(replace(replace(replace(replace(isnull(chassiplaca, ''), ' ', ''), '-', ''), '.', ''), '/', '')) = @chassi)
                                            or
                                            (@cpf <> '' and upper(replace(replace(replace(replace(isnull(cpfcnpj, ''), '.', ''), '-', ''), '/', ''), ' ', '')) = @cpf
                                             and @modelo <> '' and upper(ltrim(rtrim(isnull(modelo, '')))) = @modelo
                                             and abs(isnull(valorveiculo, 0) - @valor) <= 1)
                                           )
                                     order by [data] desc, id desc";
                oCmd.CommandType = CommandType.Text;
                oCmd.Parameters.Add("@tipo", SqlDbType.VarChar).Value = tipo ?? "";
                oCmd.Parameters.Add("@cpf", SqlDbType.VarChar).Value = cpf;
                oCmd.Parameters.Add("@chassi", SqlDbType.VarChar).Value = chassi;
                oCmd.Parameters.Add("@modelo", SqlDbType.VarChar).Value = modelo;
                oCmd.Parameters.Add("@valor", SqlDbType.Float).Value = Convert.ToDouble(LerMoeda(txtValoVeiculo.Text));

                using (SqlDataReader reader = oCmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        string data = reader["data"] == DBNull.Value ? "" : Convert.ToDateTime(reader["data"]).ToString("dd/MM/yyyy");
                        decimal valor = reader["valorveiculo"] == DBNull.Value ? 0M : Convert.ToDecimal(reader["valorveiculo"]);
                        contratoEncontrado = "Contrato " + reader["id"]
                            + (data.Length > 0 ? ", data " + data : "")
                            + ", cliente " + Convert.ToString(reader["cliente"])
                            + ", modelo " + Convert.ToString(reader["modelo"])
                            + ", vendedor " + Convert.ToString(reader["vendedor"])
                            + ", valor " + valor.ToString("C", CulturaBrasil);
                        return true;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            RegistrarContratoOperacao("ERRO_CONSULTA_DUPLICIDADE", ex.Message);
        }
        finally
        {
            vec.FecharConexao();
        }

        return false;
    }

    private bool ValidarChecklistFinalNovo(string tipo, out string mensagem)
    {
        List<string> erros = new List<string>();

        if (!chkConfereDocumento.Checked) erros.Add("Confirme que o documento do cliente foi conferido.");
        if (!chkConfereValores.Checked) erros.Add("Confirme que os valores foram conferidos.");
        if (!chkConferePagamento.Checked) erros.Add("Confirme que a forma de pagamento foi conferida.");

        string contratoSemelhante;
        if (erros.Count == 0 && ExisteContratoSemelhante(tipo, out contratoSemelhante))
        {
            if (!chkConfirmarDuplicidade.Checked)
            {
                erros.Add("Existe um contrato semelhante recente: " + contratoSemelhante + ". Se for uma nova compra legítima do mesmo cliente, marque a ciência de duplicidade para continuar.");
            }
            else
            {
                RegistrarContratoOperacao("DUPLICIDADE_CONFIRMADA", "Contrato semelhante=" + contratoSemelhante + "; CPF/CNPJ=" + txtCPFCNPJ.Text + "; Chassi/Placa=" + txtChassiPlaca.Text + "; Tipo=" + tipo);
            }
        }

        if (erros.Count > 0)
        {
            mensagem = "Revise antes de gravar:\n- " + String.Join("\n- ", erros.ToArray());
            return false;
        }

        mensagem = "";
        return true;
    }

    private Dictionary<string, string> CamposEdicao()
    {
        Dictionary<string, string> campos = new Dictionary<string, string>();
        campos["Cliente"] = txtEdCliente.Text;
        campos["Endereco"] = txtEdEndereco.Text;
        campos["CEP"] = txtEdCep.Text;
        campos["Bairro"] = txtEdBairro.Text;
        campos["Cidade"] = txtEdCidade.Text;
        campos["UF"] = txtEdUF.Text;
        campos["CPF/CNPJ"] = txtEdCPF.Text;
        campos["RG/IE"] = txtEdRG.Text;
        campos["Data nascimento"] = txtEdNascimento.Text;
        campos["Telefone residencial"] = txtEdTelRes.Text;
        campos["Telefone comercial"] = txtEdComercial.Text;
        campos["Celular"] = txtEdCelular.Text;
        campos["Email"] = txtEdEmail.Text;
        campos["Marca"] = txtEdMarca.Text;
        campos["Modelo"] = txtEdModelo.Text;
        campos["Cor externa"] = txtEdCorExt.Text;
        campos["Chassi/Placa"] = txtEdChassi.Text;
        campos["Ano/modelo"] = txtEdAnomodelo.Text;
        campos["Opcionais"] = txtEdOpcionais.Text;
        campos["Financeira"] = txtEdFinanceira.Text;
        campos["Valor veículo"] = txtEdValorVeic.Text;
        campos["Taxas"] = txtEdTAXAS.Text;
        campos["Entrada"] = txtEdEntrada.Text;
        campos["Formas pagamento"] = txtEdFormasPagamento.Text;
        campos["Avaliação usada"] = txtEdValorUSADO.Text;
        campos["Modelo/marca usado"] = txtEdModMarcaUSADO.Text;
        campos["Ano/modelo usado"] = txtEdAnoMOdUSADO.Text;
        campos["Placa usado"] = txtEdPlacaUSADO.Text;
        campos["Valor utilizado avaliação"] = txtEdVALORUSADOAVAILACAO.Text;
        campos["Quitação"] = txtEdQuitacao.Text;
        campos["Saldo avaliação"] = txtEdSaldoAvaliacao.Text;
        campos["Financiamento"] = txtEdFinanciamento.Text;
        campos["Nº parcelas"] = txtEdNumeroParcelas.Text;
        campos["Valor parcela"] = txtEdValorParcela.Text;
        campos["Plano financiamento"] = txtEdPlanoFinanciamento.Text;
        campos["Cortesias"] = txtEdCortesias.Text;
        campos["Observações"] = txtEdObs.Text;
        campos["Vendedor"] = txtEdVendedor.Text;
        campos["Previsão"] = txtEdPrevisao.Text;
        campos["Modalidade"] = rbtnEdAVISTA.Checked ? "A vista" : (rbtnEdAprazo.Checked ? "Financiamento" : "");
        return campos;
    }

    private string MontarSnapshot(Dictionary<string, string> campos)
    {
        StringBuilder snapshot = new StringBuilder();
        foreach (KeyValuePair<string, string> campo in campos)
        {
            snapshot.Append(campo.Key).Append("=").Append(LimparLog(campo.Value)).Append("\n");
        }
        return snapshot.ToString();
    }

    private Dictionary<string, string> LerSnapshot(string snapshot)
    {
        Dictionary<string, string> campos = new Dictionary<string, string>();
        string[] linhas = (snapshot ?? "").Split(new char[] { '\n' }, StringSplitOptions.RemoveEmptyEntries);
        foreach (string linha in linhas)
        {
            int posicao = linha.IndexOf("=");
            if (posicao > 0)
            {
                campos[linha.Substring(0, posicao)] = linha.Substring(posicao + 1);
            }
        }
        return campos;
    }

    private void GuardarSnapshotEdicao()
    {
        ViewState["ContratoSnapshot"] = MontarSnapshot(CamposEdicao());
    }

    private void RegistrarHistoricoEdicao(string contrato)
    {
        Dictionary<string, string> anterior = LerSnapshot(Convert.ToString(ViewState["ContratoSnapshot"]));
        Dictionary<string, string> atual = CamposEdicao();
        List<string> mudancas = new List<string>();

        foreach (KeyValuePair<string, string> campo in atual)
        {
            string valorAnterior = anterior.ContainsKey(campo.Key) ? anterior[campo.Key] : "";
            string valorAtual = LimparLog(campo.Value);
            if (!String.Equals(valorAnterior, valorAtual, StringComparison.Ordinal))
            {
                mudancas.Add(campo.Key + " de [" + valorAnterior + "] para [" + valorAtual + "]");
            }
        }

        if (mudancas.Count > 0)
        {
            RegistrarContratoOperacao("EDICAO_ALTERACOES", "Contrato=" + contrato + "; Campos alterados=" + mudancas.Count + "; " + String.Join(" | ", mudancas.Take(60).ToArray()));
        }
        else
        {
            RegistrarContratoOperacao("EDICAO_SEM_ALTERACAO", "Contrato=" + contrato);
        }
    }

    private decimal LerMoeda(string valor)
    {
        string texto = (valor ?? "").Replace("R$", "").Trim().Replace(" ", "");
        if (texto.Length == 0) return 0M;

        decimal convertido;
        int ultimoPonto = texto.LastIndexOf(".");
        bool priorizarBrasil = texto.IndexOf(",") >= 0
            || (ultimoPonto >= 0 && texto.IndexOf(".") == ultimoPonto && texto.Length - ultimoPonto - 1 == 3);

        if (priorizarBrasil && decimal.TryParse(texto, NumberStyles.Number, CulturaBrasil, out convertido)) return convertido;
        if (decimal.TryParse(texto, NumberStyles.Number, CultureInfo.InvariantCulture, out convertido)) return convertido;
        if (decimal.TryParse(texto, NumberStyles.Number, CulturaBrasil, out convertido)) return convertido;

        throw new FormatException("Valor inválido: " + valor);
    }

    private string FormatarMoedaSistema(decimal valor)
    {
        return valor.ToString("0.00", CultureInfo.CurrentCulture);
    }

    private void NormalizarCampoMoeda(TextBox campo)
    {
        if (campo != null)
        {
            campo.Text = FormatarMoedaSistema(LerMoeda(campo.Text));
        }
    }

    private void NormalizarCamposMonetarios()
    {
        TextBox[] campos = new TextBox[]
        {
            txtValoVeiculo, txtEmplacamento, txtEntrada, txtCarroUsado, txtVlUtilzadoAvaliacao,
            txtQuitacao, txtSaldoAvaliacao, txtVlFinanciamento, txtVlParcelas, txtEdValorVeic,
            txtEdTAXAS, txtEdEntrada, txtEdValorUSADO, txtEdVALORUSADOAVAILACAO, txtEdQuitacao,
            txtEdSaldoAvaliacao, txtEdFinanciamento, txtEdValorParcela
        };

        foreach (TextBox campo in campos)
        {
            NormalizarCampoMoeda(campo);
        }
    }

    private bool CampoVazio(string valor)
    {
        return (valor ?? "").Trim().Length == 0;
    }

    private string SomenteDigitos(string valor)
    {
        StringBuilder digitos = new StringBuilder();
        foreach (char caractere in (valor ?? ""))
        {
            if (Char.IsDigit(caractere))
            {
                digitos.Append(caractere);
            }
        }
        return digitos.ToString();
    }

    private string SomenteLetrasNumeros(string valor)
    {
        StringBuilder texto = new StringBuilder();
        foreach (char caractere in (valor ?? ""))
        {
            if (Char.IsLetterOrDigit(caractere))
            {
                texto.Append(caractere);
            }
        }
        return texto.ToString();
    }

    private bool ChassiPlacaValido(string valor)
    {
        return SomenteLetrasNumeros(valor).Length >= 7;
    }

    private bool NumeroParcelasValido(string valor)
    {
        int parcelas;
        string digitos = SomenteDigitos(valor);
        return Int32.TryParse(digitos, out parcelas) && parcelas > 0 && parcelas <= 120;
    }

    private void NormalizarCep(TextBox campo)
    {
        if (campo == null) return;
        string digitos = SomenteDigitos(campo.Text);
        if (digitos.Length == 8)
        {
            campo.Text = digitos.Substring(0, 5) + "-" + digitos.Substring(5, 3);
        }
    }

    private void NormalizarCpfCnpj(TextBox campo)
    {
        if (campo == null) return;
        string digitos = SomenteDigitos(campo.Text);
        if (digitos.Length == 11)
        {
            campo.Text = digitos.Substring(0, 3) + "." + digitos.Substring(3, 3) + "." + digitos.Substring(6, 3) + "-" + digitos.Substring(9, 2);
        }
        else if (digitos.Length == 14)
        {
            campo.Text = digitos.Substring(0, 2) + "." + digitos.Substring(2, 3) + "." + digitos.Substring(5, 3) + "/" + digitos.Substring(8, 4) + "-" + digitos.Substring(12, 2);
        }
    }

    private void NormalizarTelefone(TextBox campo)
    {
        if (campo == null) return;
        string digitos = SomenteDigitos(campo.Text);
        if (digitos.Length == 10)
        {
            campo.Text = "(" + digitos.Substring(0, 2) + ") " + digitos.Substring(2, 4) + "-" + digitos.Substring(6, 4);
        }
        else if (digitos.Length == 11)
        {
            campo.Text = "(" + digitos.Substring(0, 2) + ") " + digitos.Substring(2, 5) + "-" + digitos.Substring(7, 4);
        }
    }

    private void NormalizarChassiPlaca(TextBox campo)
    {
        if (campo == null) return;
        campo.Text = SomenteLetrasNumeros(campo.Text).ToUpperInvariant();
    }

    private void NormalizarFormatosNovo()
    {
        txtUF.Text = (txtUF.Text ?? "").Trim().ToUpperInvariant();
        txtEmail.Text = (txtEmail.Text ?? "").Trim().ToLowerInvariant();
        NormalizarCpfCnpj(txtCPFCNPJ);
        NormalizarCep(txtCEP);
        NormalizarTelefone(txtTelREsidencial);
        NormalizarTelefone(txtTelCom);
        NormalizarTelefone(txtCelular);
        NormalizarChassiPlaca(txtChassiPlaca);
        NormalizarChassiPlaca(txtPlacaVU);
    }

    private void NormalizarFormatosEdicao()
    {
        txtEdUF.Text = (txtEdUF.Text ?? "").Trim().ToUpperInvariant();
        txtEdEmail.Text = (txtEdEmail.Text ?? "").Trim().ToLowerInvariant();
        NormalizarCpfCnpj(txtEdCPF);
        NormalizarCep(txtEdCep);
        NormalizarTelefone(txtEdTelRes);
        NormalizarTelefone(txtEdComercial);
        NormalizarTelefone(txtEdCelular);
        NormalizarChassiPlaca(txtEdChassi);
        NormalizarChassiPlaca(txtEdPlacaUSADO);
    }

    private bool CpfCnpjValido(string valor)
    {
        string digitos = SomenteDigitos(valor);
        return digitos.Length == 11 || digitos.Length == 14;
    }

    private bool CepValido(string valor)
    {
        return SomenteDigitos(valor).Length == 8;
    }

    private bool UfValida(string valor)
    {
        string uf = (valor ?? "").Trim().ToUpperInvariant();
        return uf.Length == 2 && uf.All(Char.IsLetter);
    }

    private bool EmailValido(string valor)
    {
        string email = (valor ?? "").Trim();
        int arroba = email.IndexOf("@");
        int ultimoPonto = email.LastIndexOf(".");
        return email.IndexOf(" ") < 0 && arroba > 0 && ultimoPonto > arroba + 1 && ultimoPonto < email.Length - 1;
    }

    private bool DataValida(string valor)
    {
        DateTime data;
        return DateTime.TryParseExact((valor ?? "").Trim(), "dd/MM/yyyy", CulturaBrasil, DateTimeStyles.None, out data);
    }

    private bool TelefoneValido(string valor)
    {
        string digitos = SomenteDigitos(valor);
        return digitos.Length >= 10 && digitos.Length <= 11;
    }

    private void ValidarFormatoOpcional(List<string> erros, string valor, Func<string, bool> validador, string mensagem)
    {
        if (!CampoVazio(valor) && !validador(valor))
        {
            erros.Add(mensagem);
        }
    }

    private void ValidarFormatosNovo(List<string> erros)
    {
        ValidarFormatoOpcional(erros, txtCPFCNPJ.Text, CpfCnpjValido, "CPF/CNPJ deve ter 11 ou 14 números.");
        ValidarFormatoOpcional(erros, txtCEP.Text, CepValido, "CEP deve ter 8 números. Exemplo: 01001-000.");
        ValidarFormatoOpcional(erros, txtUF.Text, UfValida, "UF deve ter 2 letras. Exemplo: SP.");
        ValidarFormatoOpcional(erros, txtEmail.Text, EmailValido, "Informe um e-mail válido. Exemplo: cliente@email.com.");
        ValidarFormatoOpcional(erros, txtNascimento.Text, DataValida, "Data de nascimento deve estar no formato dd/mm/aaaa.");
        ValidarFormatoOpcional(erros, txtTelREsidencial.Text, TelefoneValido, "Telefone residencial deve ter DDD + número.");
        ValidarFormatoOpcional(erros, txtTelCom.Text, TelefoneValido, "Telefone comercial deve ter DDD + número.");
        ValidarFormatoOpcional(erros, txtCelular.Text, TelefoneValido, "Celular deve ter DDD + número.");
    }

    private void ValidarFormatosEdicao(List<string> erros)
    {
        ValidarFormatoOpcional(erros, txtEdCPF.Text, CpfCnpjValido, "CPF/CNPJ deve ter 11 ou 14 números.");
        ValidarFormatoOpcional(erros, txtEdCep.Text, CepValido, "CEP deve ter 8 números. Exemplo: 01001-000.");
        ValidarFormatoOpcional(erros, txtEdUF.Text, UfValida, "UF deve ter 2 letras. Exemplo: SP.");
        ValidarFormatoOpcional(erros, txtEdEmail.Text, EmailValido, "Informe um e-mail válido. Exemplo: cliente@email.com.");
        ValidarFormatoOpcional(erros, txtEdNascimento.Text, DataValida, "Data de nascimento deve estar no formato dd/mm/aaaa.");
        ValidarFormatoOpcional(erros, txtEdTelRes.Text, TelefoneValido, "Telefone residencial deve ter DDD + número.");
        ValidarFormatoOpcional(erros, txtEdComercial.Text, TelefoneValido, "Telefone comercial deve ter DDD + número.");
        ValidarFormatoOpcional(erros, txtEdCelular.Text, TelefoneValido, "Celular deve ter DDD + número.");
    }

    private bool ValidarContratoNovo(string modalidadePagamento, string tipo, out string mensagem)
    {
        List<string> erros = new List<string>();
        NormalizarFormatosNovo();

        if (CampoVazio(txtCliente.Text)) erros.Add("Informe o cliente.");
        if (CampoVazio(txtCPFCNPJ.Text)) erros.Add("Informe o CPF/CNPJ.");
        if (CampoVazio(txtMarca.Text)) erros.Add("Informe a marca.");
        if (CampoVazio(txtModelo.Text)) erros.Add("Informe o modelo.");
        if (CampoVazio(txtChassiPlaca.Text)) erros.Add("Informe chassi/placa.");
        else if (!ChassiPlacaValido(txtChassiPlaca.Text)) erros.Add("Chassi/placa deve ter pelo menos 7 letras ou números.");
        if (CampoVazio(tipo)) erros.Add("Selecione se o contrato é novo ou usado.");
        if (CampoVazio(ddlVendedor.Text)) erros.Add("Selecione o vendedor.");
        if (LerMoeda(txtValoVeiculo.Text) <= 0) erros.Add("Valor do veículo deve ser maior que zero. Exemplo: 150000,00.");
        ValidarFormatosNovo(erros);

        if (modalidadePagamento == "F")
        {
            if (CampoVazio(txtNrParcelas.Text)) erros.Add("Informe a quantidade de parcelas do financiamento.");
            else if (!NumeroParcelasValido(txtNrParcelas.Text)) erros.Add("Quantidade de parcelas deve ser um número entre 1 e 120.");
            if (LerMoeda(txtVlParcelas.Text) <= 0) erros.Add("Valor da parcela deve ser maior que zero para financiamento.");
        }

        if (LerMoeda(txtVlFinanciamento.Text) < 0) erros.Add("Financiamento ficou negativo: entrada + avaliação utilizada superam o valor do veículo.");
        if (LerMoeda(txtSaldoAvaliacao.Text) < 0) erros.Add("Saldo da avaliação ficou negativo: quitação + valor utilizado superam a avaliação do usado.");

        if (erros.Count > 0)
        {
            mensagem = "Revise o contrato antes de gravar:\n- " + String.Join("\n- ", erros.ToArray());
            return false;
        }

        mensagem = "";
        return true;
    }

    private bool ValidarContratoEdicao(string modalidadePagamento, out string mensagem)
    {
        List<string> erros = new List<string>();
        int contrato;
        NormalizarFormatosEdicao();

        if (!Int32.TryParse((txtContrato.Text ?? "").Trim(), out contrato) || contrato <= 0) erros.Add("Informe um número de contrato válido para edição.");
        if (CampoVazio(txtEdCliente.Text)) erros.Add("Informe o cliente.");
        if (CampoVazio(txtEdCPF.Text)) erros.Add("Informe o CPF/CNPJ.");
        if (CampoVazio(txtEdMarca.Text)) erros.Add("Informe a marca.");
        if (CampoVazio(txtEdModelo.Text)) erros.Add("Informe o modelo.");
        if (CampoVazio(txtEdChassi.Text)) erros.Add("Informe chassi/placa.");
        else if (!ChassiPlacaValido(txtEdChassi.Text)) erros.Add("Chassi/placa deve ter pelo menos 7 letras ou números.");
        if (CampoVazio(modalidadePagamento)) erros.Add("Selecione a modalidade de pagamento.");
        if (CampoVazio(txtEdVendedor.Text)) erros.Add("Informe o vendedor.");
        if (LerMoeda(txtEdValorVeic.Text) <= 0) erros.Add("Valor do veículo deve ser maior que zero. Exemplo: 150000,00.");
        ValidarFormatosEdicao(erros);

        if (modalidadePagamento == "F")
        {
            if (CampoVazio(txtEdNumeroParcelas.Text)) erros.Add("Informe a quantidade de parcelas do financiamento.");
            else if (!NumeroParcelasValido(txtEdNumeroParcelas.Text)) erros.Add("Quantidade de parcelas deve ser um número entre 1 e 120.");
            if (LerMoeda(txtEdValorParcela.Text) <= 0) erros.Add("Valor da parcela deve ser maior que zero para financiamento.");
        }

        if (LerMoeda(txtEdFinanciamento.Text) < 0) erros.Add("Financiamento ficou negativo: entrada + avaliação utilizada superam o valor do veículo.");
        if (LerMoeda(txtEdSaldoAvaliacao.Text) < 0) erros.Add("Saldo da avaliação ficou negativo: quitação + valor utilizado superam a avaliação do usado.");

        if (erros.Count > 0)
        {
            mensagem = "Revise a edição antes de gravar:\n- " + String.Join("\n- ", erros.ToArray());
            return false;
        }

        mensagem = "";
        return true;
    }

    protected void btnAtualizarBI_Click(object sender, EventArgs e)
    {
        InicializarPeriodoBI();
        CarregarBI();
        TabContainerProcesso.ActiveTabIndex = 0;
    }

    private void InicializarPeriodoBI()
    {
        DateTime inicioMes = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
        DateTime fimMes = inicioMes.AddMonths(1).AddDays(-1);

        if (txtBiDtInicial.Text.Length == 0)
        {
            txtBiDtInicial.Text = inicioMes.ToString("dd/MM/yyyy");
        }

        if (txtBiDtFinal.Text.Length == 0)
        {
            txtBiDtFinal.Text = fimMes.ToString("dd/MM/yyyy");
        }
    }

    private void CarregarBI()
    {
        DateTime inicio;
        DateTime fim;
        ObterPeriodoBI(out inicio, out fim);

        if ((fim.Date - inicio.Date).TotalDays > DiasMaximosBI)
        {
            biHtml = "<div class='contract-bi-empty'>Selecione um período de até 12 meses para manter o BI rápido e confiável.</div>";
            return;
        }

        try
        {
            List<ContratoBIItem> contratos = BuscarContratosBI(inicio, fim);
            biHtml = MontarHtmlBI(contratos, inicio, fim);
        }
        catch (Exception)
        {
            biHtml = "<div class='contract-bi-empty'>Não foi possível carregar o BI agora. Tente novamente ou reduza o período pesquisado.</div>";
        }
    }

    private void ObterPeriodoBI(out DateTime inicio, out DateTime fim)
    {
        CultureInfo cultura = new CultureInfo("pt-BR");
        DateTime inicioPadrao = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
        DateTime fimPadrao = inicioPadrao.AddMonths(1).AddDays(-1);

        if (!DateTime.TryParse(txtBiDtInicial.Text, cultura, DateTimeStyles.None, out inicio))
        {
            inicio = inicioPadrao;
        }

        if (!DateTime.TryParse(txtBiDtFinal.Text, cultura, DateTimeStyles.None, out fim))
        {
            fim = fimPadrao;
        }

        if (fim < inicio)
        {
            DateTime troca = inicio;
            inicio = fim;
            fim = troca;
        }

        txtBiDtInicial.Text = inicio.ToString("dd/MM/yyyy");
        txtBiDtFinal.Text = fim.ToString("dd/MM/yyyy");
    }

    private List<ContratoBIItem> BuscarContratosBI(DateTime inicio, DateTime fim)
    {
        string cacheKey = "contrato-bi:" + MarcaContrato + ":" + inicio.ToString("yyyyMMdd") + ":" + fim.ToString("yyyyMMdd");
        List<ContratoBIItem> contratosCache = HttpRuntime.Cache[cacheKey] as List<ContratoBIItem>;
        if (contratosCache != null) return contratosCache;

        List<ContratoBIItem> contratos = new List<ContratoBIItem>();
        Veiculos vec = new Veiculos();

        try
        {
            vec.Conexao();
            using (SqlCommand oCmd = new SqlCommand())
            {
                oCmd.Connection = vec.oCon;
                oCmd.CommandTimeout = TimeoutConsultaSegundos;
                oCmd.CommandText = @"select id,
                                            isnull(vendedor, '') vendedor,
                                            isnull(tipo, '') tipo,
                                            cast([data] as date) data,
                                            isnull(valorveiculo, 0) valorveiculo,
                                            isnull(modalidade_pagamento, '') modalidade_pagamento
                                     from " + TabelaContratosBI + @"
                                     where [data] >= @inicio
                                       and [data] < dateadd(day, 1, @fim)
                                       and tipo in ('VN', 'VU', 'VD')
                                     order by [data] asc, id asc";
                oCmd.CommandType = CommandType.Text;
                oCmd.Parameters.Add("@inicio", SqlDbType.Date).Value = inicio;
                oCmd.Parameters.Add("@fim", SqlDbType.Date).Value = fim;

                using (SqlDataReader odr = oCmd.ExecuteReader())
                {
                    while (odr.Read())
                    {
                        contratos.Add(new ContratoBIItem
                        {
                            Vendedor = odr["vendedor"].ToString(),
                            Tipo = odr["tipo"].ToString(),
                            Data = Convert.ToDateTime(odr["data"]),
                            Valor = ConverterDecimal(odr["valorveiculo"]),
                            Pagamento = odr["modalidade_pagamento"].ToString()
                        });
                    }
                }
            }
        }
        finally
        {
            vec.FecharConexao();
        }

        HttpRuntime.Cache.Insert(cacheKey, contratos, null, DateTime.Now.AddMinutes(2), System.Web.Caching.Cache.NoSlidingExpiration);
        return contratos;
    }

    private string MontarHtmlBI(List<ContratoBIItem> contratos, DateTime inicio, DateTime fim)
    {
        int total = contratos.Count;
        int totalVN = contratos.Count(x => x.Tipo == "VN");
        int totalVU = contratos.Count(x => x.Tipo == "VU");
        int totalVD = contratos.Count(x => x.Tipo == "VD");
        decimal valorTotal = contratos.Sum(x => x.Valor);
        int diasPeriodo = Math.Max(1, (fim.Date - inicio.Date).Days + 1);
        decimal ticketMedio = total > 0 ? valorTotal / total : 0M;
        decimal mediaDiaria = total > 0 ? Convert.ToDecimal(total) / Convert.ToDecimal(diasPeriodo) : 0M;
        string topVendedor = contratos.GroupBy(x => (x.Vendedor ?? "").Trim().Length == 0 ? "Não informado" : x.Vendedor)
            .OrderByDescending(x => x.Count())
            .ThenBy(x => x.Key)
            .Select(x => x.Key + " (" + x.Count() + ")")
            .FirstOrDefault() ?? "-";

        StringBuilder html = new StringBuilder();
        html.Append("<div class='contract-bi-period'>Período analisado: ");
        html.Append(HttpUtility.HtmlEncode(inicio.ToString("dd/MM/yyyy")));
        html.Append(" a ");
        html.Append(HttpUtility.HtmlEncode(fim.ToString("dd/MM/yyyy")));
        html.Append("</div>");

        html.Append("<div class='contract-bi-cards'>");
        html.Append(BiCard("Total", total.ToString(), "Contratos no período"));
        html.Append(BiCard("Novos", totalVN.ToString(), "Contratos VN"));
        html.Append(BiCard("Usados", totalVU.ToString(), "Contratos VU"));
        html.Append(BiCard("Venda direta", totalVD.ToString(), "Contratos VD"));
        html.Append(BiCard("Valor total", valorTotal.ToString("C0", new CultureInfo("pt-BR")), "Soma dos veículos"));
        html.Append(BiCard("Ticket médio", ticketMedio.ToString("C0", new CultureInfo("pt-BR")), "Valor médio por contrato"));
        html.Append(BiCard("Média/dia", mediaDiaria.ToString("N1", new CultureInfo("pt-BR")), "Contratos por dia"));
        html.Append(BiCard("Top vendedor", topVendedor, "Maior volume no período"));
        html.Append("</div>");

        if (total == 0)
        {
            html.Append("<div class='contract-bi-empty'>Sem contratos encontrados no período selecionado.</div>");
            return html.ToString();
        }

        Dictionary<string, int> porVendedor = AgruparPorTexto(contratos, "vendedor");
        Dictionary<string, int> porTipo = AgruparPorTexto(contratos, "tipo");
        Dictionary<string, int> porPagamento = AgruparPorTexto(contratos, "pagamento");
        Dictionary<string, decimal> valorPorTipo = AgruparValorPorTexto(contratos, "tipo");
        SortedDictionary<DateTime, int> porDia = AgruparPorDia(contratos, inicio, fim);

        html.Append("<div class='contract-bi-layout'>");
        html.Append("<section class='contract-bi-chart wide'><h3>Evolução diária</h3>");
        html.Append(MontarGraficoDias(porDia));
        html.Append("</section>");
        html.Append("<section class='contract-bi-chart'><h3>Contratos por vendedor</h3>");
        html.Append(MontarBarras(porVendedor, true));
        html.Append("</section>");
        html.Append("<section class='contract-bi-chart'><h3>Tipos de contrato</h3>");
        html.Append(MontarBarras(porTipo, false));
        html.Append("</section>");
        html.Append("<section class='contract-bi-chart'><h3>Forma de pagamento</h3>");
        html.Append(MontarBarras(porPagamento, false));
        html.Append("</section>");
        html.Append("<section class='contract-bi-chart'><h3>Valor por tipo</h3>");
        html.Append(MontarBarrasValor(valorPorTipo));
        html.Append("</section>");
        html.Append("</div>");

        return html.ToString();
    }

    private string BiCard(string label, string value, string caption)
    {
        return "<article><span>" + HttpUtility.HtmlEncode(label) + "</span><strong>"
            + HttpUtility.HtmlEncode(value) + "</strong><small>" + HttpUtility.HtmlEncode(caption) + "</small></article>";
    }

    private Dictionary<string, int> AgruparPorTexto(List<ContratoBIItem> contratos, string campo)
    {
        Dictionary<string, int> grupo = new Dictionary<string, int>();

        foreach (ContratoBIItem contrato in contratos)
        {
            string chave = "";
            if (campo == "vendedor") chave = contrato.Vendedor;
            if (campo == "tipo") chave = NomeTipo(contrato.Tipo);
            if (campo == "pagamento") chave = NomePagamento(contrato.Pagamento);
            if (chave.Trim().Length == 0) chave = "Não informado";

            if (!grupo.ContainsKey(chave)) grupo[chave] = 0;
            grupo[chave]++;
        }

        return grupo;
    }

    private SortedDictionary<DateTime, int> AgruparPorDia(List<ContratoBIItem> contratos, DateTime inicio, DateTime fim)
    {
        SortedDictionary<DateTime, int> grupo = new SortedDictionary<DateTime, int>();
        for (DateTime dia = inicio.Date; dia <= fim.Date; dia = dia.AddDays(1))
        {
            grupo[dia] = 0;
        }

        foreach (ContratoBIItem contrato in contratos)
        {
            DateTime dia = contrato.Data.Date;
            if (!grupo.ContainsKey(dia)) grupo[dia] = 0;
            grupo[dia]++;
        }

        return grupo;
    }

    private Dictionary<string, decimal> AgruparValorPorTexto(List<ContratoBIItem> contratos, string campo)
    {
        Dictionary<string, decimal> grupo = new Dictionary<string, decimal>();

        foreach (ContratoBIItem contrato in contratos)
        {
            string chave = "";
            if (campo == "tipo") chave = NomeTipo(contrato.Tipo);
            if (campo == "vendedor") chave = contrato.Vendedor;
            if (chave.Trim().Length == 0) chave = "Não informado";

            if (!grupo.ContainsKey(chave)) grupo[chave] = 0M;
            grupo[chave] += contrato.Valor;
        }

        return grupo;
    }

    private string MontarBarras(Dictionary<string, int> dados, bool limitar)
    {
        if (dados.Count == 0) return "<p class='contract-bi-muted'>Sem dados para exibir.</p>";
        List<KeyValuePair<string, int>> ordenados = dados.OrderByDescending(x => x.Value).ThenBy(x => x.Key).ToList();
        if (limitar) ordenados = ordenados.Take(12).ToList();

        int max = ordenados.Max(x => x.Value);
        StringBuilder html = new StringBuilder();
        html.Append("<div class='contract-bi-bars'>");

        foreach (KeyValuePair<string, int> item in ordenados)
        {
            int porcentagem = max == 0 ? 0 : Convert.ToInt32(Math.Round((item.Value * 100.0) / max));
            html.Append("<div class='contract-bi-bar'><div class='contract-bi-bar-head'><span>");
            html.Append(HttpUtility.HtmlEncode(item.Key));
            html.Append("</span><strong>");
            html.Append(item.Value);
            html.Append("</strong></div><div class='contract-bi-track'><span style='width:");
            html.Append(porcentagem);
            html.Append("%'></span></div></div>");
        }

        html.Append("</div>");
        return html.ToString();
    }

    private string MontarBarrasValor(Dictionary<string, decimal> dados)
    {
        if (dados.Count == 0) return "<p class='contract-bi-muted'>Sem dados para exibir.</p>";
        List<KeyValuePair<string, decimal>> ordenados = dados.OrderByDescending(x => x.Value).ThenBy(x => x.Key).ToList();

        decimal max = ordenados.Max(x => x.Value);
        StringBuilder html = new StringBuilder();
        html.Append("<div class='contract-bi-bars'>");

        foreach (KeyValuePair<string, decimal> item in ordenados)
        {
            int porcentagem = max == 0 ? 0 : Convert.ToInt32(Math.Round((item.Value * 100M) / max));
            html.Append("<div class='contract-bi-bar'><div class='contract-bi-bar-head'><span>");
            html.Append(HttpUtility.HtmlEncode(item.Key));
            html.Append("</span><strong>");
            html.Append(item.Value.ToString("C0", new CultureInfo("pt-BR")));
            html.Append("</strong></div><div class='contract-bi-track'><span style='width:");
            html.Append(porcentagem);
            html.Append("%'></span></div></div>");
        }

        html.Append("</div>");
        return html.ToString();
    }

    private string MontarGraficoDias(SortedDictionary<DateTime, int> dados)
    {
        int max = dados.Count == 0 ? 0 : dados.Max(x => x.Value);
        StringBuilder html = new StringBuilder();
        html.Append("<div class='contract-bi-days'>");

        foreach (KeyValuePair<DateTime, int> item in dados)
        {
            int altura = max == 0 ? 0 : Convert.ToInt32(Math.Round((item.Value * 100.0) / max));
            if (item.Value > 0 && altura < 12) altura = 12;
            html.Append("<div class='contract-bi-day' title='");
            html.Append(HttpUtility.HtmlEncode(item.Key.ToString("dd/MM/yyyy") + " - " + item.Value + " contratos"));
            html.Append("'><span style='height:");
            html.Append(altura);
            html.Append("%'></span><small>");
            html.Append(HttpUtility.HtmlEncode(item.Key.ToString("dd/MM")));
            html.Append("</small></div>");
        }

        html.Append("</div>");
        return html.ToString();
    }

    private string NomeTipo(string tipo)
    {
        if (tipo == "VN") return "Novo";
        if (tipo == "VU") return "Usado";
        if (tipo == "VD") return "Venda direta";
        return "Não informado";
    }

    private string NomePagamento(string pagamento)
    {
        if (pagamento == "A") return "À vista";
        if (pagamento == "F") return "Financiamento";
        return "Não informado";
    }

    private decimal ConverterDecimal(object valor)
    {
        if (valor == null || valor == DBNull.Value) return 0;
        try
        {
            return Convert.ToDecimal(valor);
        }
        catch
        {
            decimal convertido;
            if (decimal.TryParse(valor.ToString(), NumberStyles.Any, new CultureInfo("pt-BR"), out convertido)) return convertido;
            if (decimal.TryParse(valor.ToString(), NumberStyles.Any, CultureInfo.InvariantCulture, out convertido)) return convertido;
            return 0;
        }
    }

    private List<ContratoLogItem> LerLogsContrato()
    {
        List<ContratoLogItem> logs = new List<ContratoLogItem>();
        try
        {
            string caminho = Server.MapPath("~/App_Data/contrato-operacoes.log");
            if (!File.Exists(caminho)) return logs;

            string[] linhas = File.ReadAllLines(caminho, Encoding.UTF8);
            int inicio = Math.Max(0, linhas.Length - 1500);
            for (int i = inicio; i < linhas.Length; i++)
            {
                string[] partes = linhas[i].Split('\t');
                if (partes.Length < 5) continue;
                if (!String.Equals(partes[1], MarcaContrato, StringComparison.OrdinalIgnoreCase)) continue;

                DateTime data;
                DateTime.TryParse(partes[0], CulturaBrasil, DateTimeStyles.None, out data);
                logs.Add(new ContratoLogItem
                {
                    Data = data,
                    Usuario = partes[2],
                    Acao = partes[3],
                    Detalhe = partes[4]
                });
            }
        }
        catch
        {
        }

        return logs.OrderByDescending(x => x.Data).ToList();
    }

    private string AuditCard(string label, string value, string caption)
    {
        return "<article><span>" + HttpUtility.HtmlEncode(label) + "</span><strong>"
            + HttpUtility.HtmlEncode(value) + "</strong><small>" + HttpUtility.HtmlEncode(caption) + "</small></article>";
    }

    private bool AcaoComAtencao(string acao)
    {
        acao = (acao ?? "").ToUpperInvariant();
        return acao.StartsWith("ERRO") || acao.StartsWith("VALIDACAO") || acao.StartsWith("CHECKLIST") || acao.IndexOf("DUPLICIDADE") >= 0;
    }

    private string MontarHtmlAuditoriaContrato()
    {
        List<ContratoLogItem> logs = LerLogsContrato();
        if (logs.Count == 0) return "<div class='contract-audit-empty'>Nenhuma ocorrência de contrato registrada para esta marca.</div>";

        DateTime limite = DateTime.Today.AddDays(-30);
        List<ContratoLogItem> recentes = logs.Where(x => x.Data >= limite).ToList();
        if (recentes.Count == 0) recentes = logs.Take(60).ToList();

        int atencoes = recentes.Count(x => AcaoComAtencao(x.Acao));
        int sucessos = recentes.Count(x => x.Acao == "GRAVACAO_SUCESSO" || x.Acao == "EDICAO_SUCESSO");
        int edicoes = recentes.Count(x => x.Acao.StartsWith("EDICAO"));

        StringBuilder html = new StringBuilder();
        html.Append("<div class='contract-audit-cards'>");
        html.Append(AuditCard("Ocorrências", recentes.Count.ToString(), "Últimos registros analisados"));
        html.Append(AuditCard("Atenção", atencoes.ToString(), "Validações, erros e duplicidades"));
        html.Append(AuditCard("Sucessos", sucessos.ToString(), "Gravações e edições concluídas"));
        html.Append(AuditCard("Edições", edicoes.ToString(), "Alterações registradas"));
        html.Append("</div>");

        html.Append("<div class='contract-audit-grid'>");
        html.Append("<section class='contract-audit-box'><h3>Principais ocorrências</h3><div class='contract-audit-bars'>");
        foreach (var grupo in recentes.GroupBy(x => x.Acao).OrderByDescending(x => x.Count()).ThenBy(x => x.Key).Take(8))
        {
            html.Append("<div><span>").Append(HttpUtility.HtmlEncode(grupo.Key)).Append("</span><strong>").Append(grupo.Count()).Append("</strong></div>");
        }
        html.Append("</div></section>");

        html.Append("<section class='contract-audit-box'><h3>Últimos registros</h3><div class='contract-audit-list'>");
        foreach (ContratoLogItem item in logs.Take(10))
        {
            html.Append("<article><strong>").Append(HttpUtility.HtmlEncode(item.Acao)).Append("</strong><span>")
                .Append(HttpUtility.HtmlEncode(item.Data == DateTime.MinValue ? "" : item.Data.ToString("dd/MM/yyyy HH:mm")))
                .Append(" · ").Append(HttpUtility.HtmlEncode(item.Usuario)).Append("</span><small>")
                .Append(HttpUtility.HtmlEncode(item.Detalhe)).Append("</small></article>");
        }
        html.Append("</div></section></div>");
        return html.ToString();
    }

    private bool DetalhePossuiContrato(string detalhe, string contrato)
    {
        foreach (string parte in (detalhe ?? "").Split(';'))
        {
            string texto = parte.Trim();
            if (texto.StartsWith("Contrato=", StringComparison.OrdinalIgnoreCase)
                && texto.Substring("Contrato=".Length).Trim() == contrato)
            {
                return true;
            }
        }
        return false;
    }

    private string MontarHistoricoContrato(string contrato)
    {
        contrato = (contrato ?? "").Trim();
        if (contrato.Length == 0) return "<div class='contract-audit-empty'>Informe o ID de um contrato para consultar o histórico.</div>";

        List<ContratoLogItem> logs = LerLogsContrato()
            .Where(x => DetalhePossuiContrato(x.Detalhe, contrato))
            .Take(80)
            .ToList();

        if (logs.Count == 0) return "<div class='contract-audit-empty'>Nenhuma ocorrência encontrada para o contrato " + HttpUtility.HtmlEncode(contrato) + ".</div>";

        StringBuilder html = new StringBuilder();
        html.Append("<section class='contract-audit-history'><h3>Histórico do contrato ")
            .Append(HttpUtility.HtmlEncode(contrato)).Append("</h3>");
        foreach (ContratoLogItem item in logs)
        {
            html.Append("<article><strong>").Append(HttpUtility.HtmlEncode(item.Acao)).Append("</strong><span>")
                .Append(HttpUtility.HtmlEncode(item.Data == DateTime.MinValue ? "" : item.Data.ToString("dd/MM/yyyy HH:mm")))
                .Append(" · ").Append(HttpUtility.HtmlEncode(item.Usuario)).Append("</span><p>")
                .Append(HttpUtility.HtmlEncode(item.Detalhe)).Append("</p></article>");
        }
        html.Append("</section>");
        return html.ToString();
    }

    protected void btnConsultarHistoricoContrato_Click(object sender, EventArgs e)
    {
        auditoriaHtml = MontarHtmlAuditoriaContrato();
        historicoHtml = MontarHistoricoContrato(txtAuditoriaContrato.Text);
    }

    private class ContratoLogItem
    {
        public DateTime Data { get; set; }
        public string Usuario { get; set; }
        public string Acao { get; set; }
        public string Detalhe { get; set; }
    }

    private class ContratoBIItem
    {
        public string Vendedor { get; set; }
        public string Tipo { get; set; }
        public DateTime Data { get; set; }
        public decimal Valor { get; set; }
        public string Pagamento { get; set; }
    }


    protected void rbtnVU_CheckedChanged(object sender, EventArgs e)
    {
        if (rbtnVU.Checked == true)
        {
            lblEmpTrans.Text = "TRANSFERÊNCIA:";
            Panel1.Visible = true;
        }
    }
    protected void rbtnVN_CheckedChanged(object sender, EventArgs e)
    {
        if (rbtnVN.Checked == true)
        {
            lblEmpTrans.Text = "EMPLACAMENTO:";
            Panel1.Visible = true;

        }
    }


    protected void btnGravar_Click(object sender, EventArgs e)
    {
        calcula();

        if (rBtnModPagFinanciamento.Checked || rBtnModPagVista.Checked)
        {

            string modpag = "";
            string tipo = "";
            if (rBtnModPagVista.Checked)
            {
                modpag = "A";
            }
            if (rBtnModPagFinanciamento.Checked)
            {
                modpag = "F";
            }

            if (rbtnVN.Checked)
            {
                tipo = "VN";
            }
            if (rbtnVU.Checked)
            {
                tipo = "VU";
            }

            string mensagemValidacao;
            try
            {
                if (!ValidarContratoNovo(modpag, tipo, out mensagemValidacao))
                {
                    RegistrarValidacaoContrato("VALIDACAO_NOVO", DetalheContratoNovo(tipo), mensagemValidacao);
                    ExibirAlerta(mensagemValidacao);
                    return;
                }
            }
      catch (FormatException)
      {
          RegistrarContratoOperacao("VALIDACAO_NOVO_VALOR", DetalheContratoNovo(tipo));
          ExibirAlerta("Revise os campos de valor. Use apenas números no formato 150000,00.");
          return;
      }

      if (!ValidarChecklistFinalNovo(tipo, out mensagemValidacao))
      {
          RegistrarValidacaoContrato("CHECKLIST_NOVO", DetalheContratoNovo(tipo), mensagemValidacao);
          ExibirAlerta(mensagemValidacao);
          return;
      }


            try
            {
                Veiculos vec = new Veiculos();
                string obs;
                string codigo;
                vec.insert_contrato_vendabyd(txtCliente.Text, txtEndereco.Text, txtCEP.Text, txtBairro.Text, txtCidade.Text,
                    txtUF.Text, txtCPFCNPJ.Text, txtRGIE.Text, txtNascimento.Text, txtTelREsidencial.Text,
                    txtTelCom.Text, txtCelular.Text, txtEmail.Text, txtMarca.Text, txtModelo.Text, txtCorExterna.Text,
                    txtChassiPlaca.Text, txtAnoMod.Text, txtOpcionais.Text, modpag, txtFinanceira.Text, txtValoVeiculo.Text,
                    txtEmplacamento.Text, txtEntrada.Text, txtFormasPagamento.Text,
                    txtCarroUsado.Text, txtModMarca.Text, txtPlacaVU.Text, txtAnoModelo.Text, txtVlFinanciamento.Text,
                    txtNrParcelas.Text, txtVlParcelas.Text, txtPlano.Text, txtCortesias.Text,
                    txtObs.Text, txtPrevisao.Text, ddlVendedor.Text, tipo, txtVlUtilzadoAvaliacao.Text, txtQuitacao.Text, txtSaldoAvaliacao.Text, out codigo, out obs);

                if (String.Equals(obs, "S", StringComparison.OrdinalIgnoreCase))
                {
                    RegistrarContratoOperacao("GRAVACAO_SUCESSO", DetalheContratoNovo(tipo) + "; Contrato=" + codigo);
                    if (tipo == "VN")
                    {
                        Response.Redirect("Print-ContratoVNBYD.aspx?contrato=" + codigo);
                    }
                    if (tipo == "VU")
                    {
                        Response.Redirect("Print-ContratoVUBYD.aspx?contrato=" + codigo);
                    }
                }
                else if (RetornoProcedureDuplicidade(obs, codigo))
                {
                    RegistrarContratoOperacao("DUPLICIDADE_BLOQUEADA_PROCEDURE", "Contrato semelhante=" + codigo + "; CPF/CNPJ=" + txtCPFCNPJ.Text + "; Chassi/Placa=" + txtChassiPlaca.Text + "; Tipo=" + tipo);
                    ExibirAlerta(MensagemDuplicidadeProcedure(codigo));
                }
                else
                {
                    RegistrarContratoOperacao("ERRO_GRAVACAO", "Retorno procedure=" + obs + "; Código=" + codigo);
                    ExibirAlerta(MensagemErroProcedure(obs, codigo));

                }
            }
            catch (Exception ex)
            {
                RegistrarContratoOperacao("ERRO_GRAVACAO", ex.Message);
                ExibirAlerta("Não foi possível gravar o contrato. Revise valores como valor do veículo, entrada, avaliação, quitação e parcelas.");
            }

        }
        else
        {
            RegistrarContratoOperacao("VALIDACAO_NOVO", DetalheContratoNovo("") + "; Pendencias=Modalidade de pagamento nao selecionada");
            ExibirAlerta("Selecione a modalidade de pagamento: à vista ou financiamento.");

        }
    }
    protected void ibtnDadosCliente_Click(object sender, ImageClickEventArgs e)
    {
       try

           {
           Veiculos oVeiculos = new Veiculos();
           string total; string total2;
        oVeiculos.select_financiamento(txtValoVeiculo.Text, txtEntrada.Text, txtVlUtilzadoAvaliacao.Text,txtCarroUsado.Text,txtQuitacao.Text, out total, out total2);
        txtVlFinanciamento.Text = total;
        txtSaldoAvaliacao.Text = total2;
          }
         catch
        {
            ExibirAlerta("Não foi possível calcular. Use valores no formato 150000,00 e confira entrada, avaliação utilizada e quitação.");

        }
    }
    protected void calcula()
    {


        try
        {
            NormalizarCamposMonetarios();

            decimal financiamento = LerMoeda(txtValoVeiculo.Text) - LerMoeda(txtEntrada.Text) - LerMoeda(txtVlUtilzadoAvaliacao.Text);
            decimal saldoAvaliacao = LerMoeda(txtCarroUsado.Text) - LerMoeda(txtVlUtilzadoAvaliacao.Text) - LerMoeda(txtQuitacao.Text);
            decimal financiamentoEdicao = LerMoeda(txtEdValorVeic.Text) - LerMoeda(txtEdEntrada.Text) - LerMoeda(txtEdVALORUSADOAVAILACAO.Text);
            decimal saldoAvaliacaoEdicao = LerMoeda(txtEdValorUSADO.Text) - LerMoeda(txtEdVALORUSADOAVAILACAO.Text) - LerMoeda(txtEdQuitacao.Text);

            txtVlFinanciamento.Text = FormatarMoedaSistema(financiamento);
            txtSaldoAvaliacao.Text = FormatarMoedaSistema(saldoAvaliacao);
            txtEdFinanciamento.Text = FormatarMoedaSistema(financiamentoEdicao);
            txtEdSaldoAvaliacao.Text = FormatarMoedaSistema(saldoAvaliacaoEdicao);
        }
        catch (Exception)
        {
            ExibirAlerta("Não consegui calcular os valores. Use números no formato 150000,00 e evite letras nos campos de valor.");
        }

    }

    protected void txtCarroUsado_TextChanged(object sender, EventArgs e)
    {
        calcula();
    }
  protected void ImageButton1_Click(object sender, ImageClickEventArgs e)
    {

        string contrato = txtContrato.Text; string cliente; string endereco; string cep; string bairro; string cidade; string UF;
        string cpfcnpj; string RGIE; string nascimento; string tel_residencial; string tel_comercial;
        string tel_celular; string email; string marca; string modelo; string cor_ext; string chassiplaca;
        string anomodelo; string opcinonais; string modalidade_pagamento; string financeira; string valorveiculo;
        string emp_trans; string entrada; string formaspagamento; string carrousado; string modmarcavu;
        string palcavu; string financiamento; string qtdeparcelas; string vlparcelas; string planofinanciamento;
        string cortesias; string obs; string previsaoentrega; string vendedor; string tipo; string data; string multa; string vlutilizadoavaliacao; string vlquitacao; string vlsaldoavaliacao; string anomodeloVU;
        Veiculos vec = new Veiculos();
        vec.select_contrato_vendabyd(contrato,
        out  cliente, out endereco, out cep, out bairro, out cidade
        , out UF, out cpfcnpj, out RGIE, out nascimento, out tel_residencial
        , out tel_comercial, out tel_celular, out email, out marca, out modelo
        , out cor_ext, out chassiplaca, out anomodelo, out opcinonais, out modalidade_pagamento
        , out financeira, out valorveiculo, out emp_trans, out entrada
        , out formaspagamento, out carrousado, out modmarcavu, out palcavu, out anomodeloVU, out financiamento
        , out qtdeparcelas, out vlparcelas, out planofinanciamento, out cortesias
        , out obs, out previsaoentrega, out vendedor, out tipo, out data, out multa, out vlutilizadoavaliacao, out vlquitacao, out vlsaldoavaliacao);

        txtEdCliente.Text = cliente; txtEdEndereco.Text = endereco; txtEdCep.Text = cep; txtEdBairro.Text = bairro; txtEdCidade.Text = cidade; txtEdUF.Text = UF; txtEdCPF.Text = cpfcnpj; txtEdRG.Text = RGIE; txtEdNascimento.Text = nascimento;
        txtEdTelRes.Text = tel_residencial; txtEdComercial.Text = tel_comercial; txtEdCelular.Text = tel_celular; txtEdEmail.Text = email; txtEdMarca.Text = marca; txtEdModelo.Text = modelo; txtEdCorExt.Text = cor_ext; txtEdChassi.Text = chassiplaca;
        txtEdAnomodelo.Text = anomodelo; txtEdOpcionais.Text = opcinonais; txtEdFinanceira.Text = financeira; txtEdValorVeic.Text = valorveiculo; txtEdTAXAS.Text = emp_trans; txtEdEntrada.Text = entrada; txtEdFormasPagamento.Text = formaspagamento;
        txtEdValorUSADO.Text = carrousado; txtEdModMarcaUSADO.Text = modmarcavu; txtEdPlacaUSADO.Text = palcavu; txtEdFinanciamento.Text = financiamento; txtEdNumeroParcelas.Text = qtdeparcelas; txtEdValorParcela.Text = vlparcelas; txtEdPlanoFinanciamento.Text = planofinanciamento;
        txtEdCortesias.Text = cortesias; txtEdObs.Text = obs; txtEdPrevisao.Text = previsaoentrega; txtEdVendedor.Text = vendedor; txtEdVALORUSADOAVAILACAO.Text = vlutilizadoavaliacao; txtEdQuitacao.Text = vlquitacao; txtEdSaldoAvaliacao.Text = vlsaldoavaliacao; txtEdAnoMOdUSADO.Text = anomodeloVU;
        rbtnEdAVISTA.Checked = modalidade_pagamento == "A";
        rbtnEdAprazo.Checked = modalidade_pagamento == "F";
        chkConfereEdicao.Checked = false;
        GuardarSnapshotEdicao();

    }

  protected void btnEditareGravar_Click(object sender, EventArgs e)
  {

      try
        {
      calcula();

      string modpag = "";
      string tipo = "";
      if (rbtnEdAVISTA.Checked)
      {
          modpag = "A";
      }
      if (rbtnEdAprazo.Checked)
      {
          modpag = "F";
      }

      string mensagemValidacao;
      try
      {
          if (!ValidarContratoEdicao(modpag, out mensagemValidacao))
          {
              RegistrarValidacaoContrato("VALIDACAO_EDICAO", DetalheContratoEdicao(), mensagemValidacao);
              ExibirAlerta(mensagemValidacao);
              return;
          }
      }
      catch (FormatException)
      {
          RegistrarContratoOperacao("VALIDACAO_EDICAO_VALOR", DetalheContratoEdicao());
          ExibirAlerta("Revise os campos de valor. Use apenas números no formato 150000,00.");
          return;
      }

      if (!chkConfereEdicao.Checked)
      {
          RegistrarContratoOperacao("CHECKLIST_EDICAO", DetalheContratoEdicao() + "; Pendencias=Confirme o checklist da edicao");
          ExibirAlerta("Confirme o checklist da edição antes de gravar.");
          return;
      }

      Veiculos vec = new Veiculos();
           string contrato = vec.update_contrato_vendabyd(Convert.ToInt16(txtContrato.Text), txtEdCliente.Text, txtEdEndereco.Text, txtEdCep.Text, txtEdBairro.Text, txtEdCidade.Text,
                txtEdUF.Text, txtEdCPF.Text, txtEdRG.Text, txtEdNascimento.Text, txtEdTelRes.Text,
                txtEdComercial.Text, txtEdCelular.Text, txtEdEmail.Text, txtEdMarca.Text, txtEdModelo.Text, txtEdCorExt.Text,
                txtEdChassi.Text, txtEdAnomodelo.Text, txtEdOpcionais.Text, modpag, txtEdFinanceira.Text, Convert.ToString(txtEdValorVeic.Text),
                txtEdTAXAS.Text, txtEdEntrada.Text, txtEdFormasPagamento.Text,
                txtEdValorUSADO.Text, txtEdModMarcaUSADO.Text, txtEdPlacaUSADO.Text, txtEdAnoMOdUSADO.Text, txtEdFinanciamento.Text,
                txtEdNumeroParcelas.Text, txtEdValorParcela.Text, txtEdPlanoFinanciamento.Text, txtEdCortesias.Text,
                txtEdObs.Text, txtEdPrevisao.Text, txtEdVendedor.Text, txtEdVALORUSADOAVAILACAO.Text, txtEdQuitacao.Text, txtEdSaldoAvaliacao.Text);

        RegistrarHistoricoEdicao(txtContrato.Text);
        RegistrarContratoOperacao("EDICAO_SUCESSO", DetalheContratoEdicao());
        GuardarSnapshotEdicao();
        chkConfereEdicao.Checked = false;
        ExibirAlerta("Contrato alterado com sucesso.");



        }

       catch (Exception ex)
        {
            RegistrarContratoOperacao("ERRO_EDICAO", ex.Message);
            ExibirAlerta("Não foi possível alterar o contrato. Revise valores, modalidade de pagamento, parcelas e vendedor.");
        }

  }

  protected void Button1_Click(object sender, EventArgs e)
  {
      string tabelaR;
      DateTime dtInicio;
      DateTime dtFim;
      if (!PrepararPeriodoConsulta(txtDtInicialVN, txtDtFinalVN, "novos", out dtInicio, out dtFim))
      {
          return;
      }

      try
      {
          select_Tab_ConsultaPeriodo("Print-ContratoVNBYD.aspx", "VN", dtInicio, dtFim, out tabelaR);
      }
      catch (Exception ex)
      {
          RegistrarContratoOperacao("ERRO_CONSULTA", "Tipo=VN; Inicio=" + dtInicio.ToString("dd/MM/yyyy") + "; Fim=" + dtFim.ToString("dd/MM/yyyy") + "; Erro=" + ex.Message);
          tabelaR = ConsultaErroHtml("contratos novos");
      }

      tabela = tabelaR;
  }
  protected void Button2_Click(object sender, EventArgs e)
  {
      string tabelaVUR;
      DateTime dtInicio;
      DateTime dtFim;

      if (!PrepararPeriodoConsulta(txtDtInicialVU, txtDtFinalVU, "usados", out dtInicio, out dtFim))
      {
          return;
      }

      try
      {
          select_Tab_ConsultaPeriodo("Print-ContratoVUBYD.aspx", "VU", dtInicio, dtFim, out tabelaVUR);
      }
      catch (Exception ex)
      {
          RegistrarContratoOperacao("ERRO_CONSULTA", "Tipo=VU; Inicio=" + dtInicio.ToString("dd/MM/yyyy") + "; Fim=" + dtFim.ToString("dd/MM/yyyy") + "; Erro=" + ex.Message);
          tabelaVUR = ConsultaErroHtml("contratos usados");
      }

      tabelaVU = tabelaVUR;
  }

  private bool ObterPeriodoConsulta(string inicioTexto, string fimTexto, out DateTime inicio, out DateTime fim)
  {
      bool inicioOk = DateTime.TryParse(inicioTexto, CulturaBrasil, DateTimeStyles.None, out inicio);
      bool fimOk = DateTime.TryParse(fimTexto, CulturaBrasil, DateTimeStyles.None, out fim);

      if (!inicioOk || !fimOk)
      {
          return false;
      }

      if (fim < inicio)
      {
          DateTime troca = inicio;
          inicio = fim;
          fim = troca;
      }

      return true;
  }

  private bool PrepararPeriodoConsulta(TextBox campoInicio, TextBox campoFim, string descricao, out DateTime inicio, out DateTime fim)
  {
      if (!ObterPeriodoConsulta(campoInicio.Text, campoFim.Text, out inicio, out fim))
      {
          ExibirAlerta("Informe uma data inicial e uma data final válidas para consultar contratos " + descricao + ".");
          return false;
      }

      if ((fim.Date - inicio.Date).TotalDays > DiasMaximosConsulta)
      {
          RegistrarContratoOperacao("CONSULTA_PERIODO_EXTENSO", "Filtro=" + descricao + "; Inicio=" + inicio.ToString("dd/MM/yyyy") + "; Fim=" + fim.ToString("dd/MM/yyyy"));
          ExibirAlerta("Para manter a consulta rápida, selecione um período de até 12 meses para contratos " + descricao + ".");
          return false;
      }

      campoInicio.Text = inicio.ToString("dd/MM/yyyy");
      campoFim.Text = fim.ToString("dd/MM/yyyy");
      return true;
  }

  private string ConsultaErroHtml(string descricao)
  {
      return "<div class='contract-query-empty'><strong>Não foi possível carregar a consulta.</strong><small>Revise o período e tente novamente. Se continuar, acione a TI informando: "
          + HttpUtility.HtmlEncode(descricao) + ".</small></div>";
  }

  private string ConsultaCell(object valor)
  {
      return "<td style='text-align:center; font-size:12px;'>" + HttpUtility.HtmlEncode(Convert.ToString(valor)) + "</td>";
  }

  private void select_Tab_ConsultaPeriodo(string paginaImpressao, string tipo, DateTime dtInicio, DateTime dtFim, out string tabelaHtml)
  {
      string cacheKey = "contrato-consulta:" + MarcaContrato + ":" + tipo + ":" + dtInicio.ToString("yyyyMMdd") + ":" + dtFim.ToString("yyyyMMdd");
      string tabelaCache = HttpRuntime.Cache[cacheKey] as string;
      if (!String.IsNullOrEmpty(tabelaCache))
      {
          tabelaHtml = tabelaCache;
          return;
      }

      string tableId = tipo == "VN" ? "tblConsultaProcesso" : "tblConsultaProcesso2";
      StringBuilder html = new StringBuilder();
      html.Append("<table cellpadding='0' cellspacing='0' border='0' id='")
          .Append(tableId)
          .Append(@"' class='display' style='font-family:arial;'>
                        <thead>
                            <tr>
                                <td style='text-align:center; font-size:12px;'>ID</td>
                                <td style='text-align:center; font-size:12px;'>Cliente</td>
                                <td style='text-align:center; font-size:12px;'>CPF</td>
                                <td style='text-align:center; font-size:12px;'>RG</td>
                                <td style='text-align:center; font-size:12px;'>Telefone1</td>
                                <td style='text-align:center; font-size:12px;'>Telefone2</td>
                                <td style='text-align:center; font-size:12px;'>Telefone3</td>
                                <td style='text-align:center; font-size:12px;'>email</td>
                                <td style='text-align:center; font-size:12px;'>vendedor</td>
                            </tr>
                        </thead><tbody>");

      Veiculos vec = new Veiculos();
      try
      {
          vec.Conexao();
          using (SqlCommand oCmd = new SqlCommand())
          {
              oCmd.Connection = vec.oCon;
              oCmd.CommandTimeout = TimeoutConsultaSegundos;
              oCmd.CommandText = @"select id,
                                          isnull(cliente, '') cliente,
                                          isnull(cpfcnpj, '') cpfcnpj,
                                          isnull(RGIE, '') RGIE,
                                          isnull(tel_residencial, '') tel_residencial,
                                          isnull(tel_comercial, '') tel_comercial,
                                          isnull(tel_celular, '') tel_celular,
                                          isnull(email, '') email,
                                          isnull(vendedor, '') vendedor
                                   from " + TabelaContratosBI + @"
                                   where tipo = @tipo
                                     and [data] >= @dtInicio
                                     and [data] < dateadd(day, 1, @dtFim)
                                   order by [data] desc, id desc";
              oCmd.CommandType = CommandType.Text;
              oCmd.Parameters.Add("@tipo", SqlDbType.VarChar).Value = tipo;
              oCmd.Parameters.Add("@dtInicio", SqlDbType.Date).Value = dtInicio;
              oCmd.Parameters.Add("@dtFim", SqlDbType.Date).Value = dtFim;

              int totalLinhas = 0;
              using (SqlDataReader odr = oCmd.ExecuteReader())
              {
                  while (odr.Read())
                  {
                      totalLinhas++;
                      string id = Convert.ToString(odr["id"]);
                      html.Append("<tr>");
                      html.Append("<td style='text-align:center; font-size:12px;'><a href='")
                          .Append(HttpUtility.HtmlAttributeEncode(paginaImpressao))
                          .Append("?contrato=")
                          .Append(HttpUtility.UrlEncode(id))
                          .Append("'>")
                          .Append(HttpUtility.HtmlEncode(id))
                          .Append("</a></td>");
                      html.Append(ConsultaCell(odr["cliente"]));
                      html.Append(ConsultaCell(odr["cpfcnpj"]));
                      html.Append(ConsultaCell(odr["RGIE"]));
                      html.Append(ConsultaCell(odr["tel_residencial"]));
                      html.Append(ConsultaCell(odr["tel_comercial"]));
                      html.Append(ConsultaCell(odr["tel_celular"]));
                      html.Append(ConsultaCell(odr["email"]));
                      html.Append(ConsultaCell(odr["vendedor"]));
                      html.Append("</tr>");
                  }
              }

              if (totalLinhas == 0)
              {
                  html.Append("<tr class='contract-empty-row'><td colspan='9'><strong>Nenhum contrato encontrado neste período.</strong><small>Revise as datas ou tente um período maior.</small></td></tr>");
              }
          }
      }
      finally
      {
          vec.FecharConexao();
      }

      html.Append("</tbody></table>");
      tabelaHtml = html.ToString();
      HttpRuntime.Cache.Insert(cacheKey, tabelaHtml, null, DateTime.Now.AddSeconds(45), System.Web.Caching.Cache.NoSlidingExpiration);
  }



}
