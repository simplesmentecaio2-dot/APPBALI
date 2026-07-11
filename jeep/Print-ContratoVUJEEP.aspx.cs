using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class veiculos_Pint_Contrato : System.Web.UI.Page
{
    private const string MarcaContrato = "Jeep";
    private const string TipoContrato = "VU";
    private const string PaginaContrato = "Print-ContratoVUJEEP.aspx";

    private bool TryObterContrato(out string contrato)
    {
        contrato = "";
        string valor = Convert.ToString(Request.QueryString["contrato"]);
        if (String.IsNullOrEmpty(valor)) return false;

        int numeroContrato;
        if (!Int32.TryParse(valor.Trim(), out numeroContrato) || numeroContrato <= 0) return false;

        contrato = numeroContrato.ToString();
        return true;
    }

    private string LimparLog(string valor)
    {
        return (valor ?? "").Replace("\r", " ").Replace("\n", " ").Replace("\t", " ").Trim();
    }

    private void RegistrarErroImpressao(string contrato, Exception ex)
    {
        try
        {
            string pasta = Server.MapPath("~/App_Data");
            if (!Directory.Exists(pasta)) Directory.CreateDirectory(pasta);

            string linha = DateTime.Now.ToString("s")
                + "\tERRO_IMPRESSAO_CONTRATO"
                + "\tMarca=" + MarcaContrato
                + "\tTipo=" + TipoContrato
                + "\tContrato=" + LimparLog(contrato)
                + "\tUsuario=" + LimparLog(Convert.ToString(Session["usuario"]))
                + "\tErro=" + LimparLog(ex.Message);

            File.AppendAllText(Path.Combine(pasta, "contrato-operacoes.log"), linha + Environment.NewLine, Encoding.UTF8);
        }
        catch
        {
        }
    }

    private void ExibirContratoNaoLocalizado()
    {
        string retorno = ResolveUrl("./contrato.aspx");
        Response.Clear();
        Response.StatusCode = 404;
        Response.TrySkipIisCustomErrors = true;
        Response.Write("<!DOCTYPE html><html lang=\"pt-BR\"><head><meta charset=\"utf-8\" /><title>Contrato não localizado</title><style>body{margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;background:#eef2f7;font-family:Arial,sans-serif;color:#0f172a}.card{width:min(520px,calc(100vw - 32px));background:#fff;border:1px solid #dbe3ef;border-radius:14px;box-shadow:0 18px 45px rgba(15,23,42,.14);padding:28px;text-align:center}.tag{display:inline-flex;padding:6px 10px;border-radius:999px;background:#fee2e2;color:#991b1b;font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.04em}h1{margin:14px 0 8px;font-size:24px}p{margin:0 0 20px;color:#475569;line-height:1.45}.acoes{display:flex;gap:10px;justify-content:center;flex-wrap:wrap}.btn{border:0;border-radius:9px;padding:11px 16px;background:#0f172a;color:#fff;font-weight:700;text-decoration:none;cursor:pointer}.btn.sec{background:#e2e8f0;color:#0f172a}</style></head><body><main class=\"card\"><span class=\"tag\">Impressão de contrato</span><h1>Contrato não localizado</h1><p>Verifique o código do contrato e tente novamente. Caso o problema continue, acione a TI.</p><div class=\"acoes\"><a class=\"btn\" href=\"" + retorno + "\">Voltar para contratos</a><button class=\"btn sec\" onclick=\"if(history.length>1){history.back();return false;}location.href='" + retorno + "';\">Voltar</button></div></main></body></html>");
        Response.End();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["usuario"] == null || Session["usuario"].ToString().Equals(""))
        {
            Response.Redirect("./loginAppcontrato.aspx");
            return;
        }
        else
        {
            lblUsuario.Text = Session["usuario"].ToString();
        }

        string contrato;
        if (!TryObterContrato(out contrato))
        {
            ExibirContratoNaoLocalizado();
            return;
        }

        ContratoAuditoria.Registrar(MarcaContrato, TipoContrato, contrato, Convert.ToString(Session["id"] ?? ""), Convert.ToString(Session["usuario"] ?? ""), Request.UserHostAddress ?? "", Request.RawUrl ?? "", "IMPRIMIR_CONTRATO", "Contrato=" + contrato + "; Tipo=" + TipoContrato + "; Marca=" + MarcaContrato + "; Pagina=" + PaginaContrato, "", "");

        string cliente; string endereco;        string cep;        string bairro;        string cidade;        string UF;
        string cpfcnpj;        string RGIE;        string nascimento;        string tel_residencial;        string tel_comercial;
        string tel_celular;        string email;        string marca;        string modelo;        string cor_ext;        string chassiplaca;
        string anomodelo;        string opcinonais;        string modalidade_pagamento;        string financeira;        string valorveiculo;
        string emp_trans;        string entrada;        string formaspagamento;        string carrousado;        string modmarcavu;
        string palcavu;        string financiamento;        string qtdeparcelas;        string vlparcelas;        string planofinanciamento;
        string cortesias; string obs; string previsaoentrega; string vendedor; string tipo; string data; string multa; string vlutilizadoavaliacao; string vlquitacao; string vlsaldoavaliacao; string anomodeloVU;
        Veiculos vec = new Veiculos();
        try
        {
            vec.select_contrato_vendajeep(contrato,
            out  cliente            , out endereco            , out cep            , out bairro            , out cidade
            , out UF            , out cpfcnpj            , out RGIE            , out nascimento            , out tel_residencial
            , out tel_comercial            , out tel_celular            , out email            , out marca            , out modelo
            , out cor_ext            , out chassiplaca            , out anomodelo            , out opcinonais            , out modalidade_pagamento
            , out financeira            , out valorveiculo            , out emp_trans            , out entrada
            , out formaspagamento            , out carrousado            , out modmarcavu            , out palcavu            , out anomodeloVU,  out financiamento
            , out qtdeparcelas            , out vlparcelas            , out planofinanciamento            , out cortesias
            , out obs            , out previsaoentrega            , out vendedor            , out tipo, out data, out multa, out vlutilizadoavaliacao, out vlquitacao, out vlsaldoavaliacao );
        }
        catch (Exception ex)
        {
            RegistrarErroImpressao(contrato, ex);
            ExibirContratoNaoLocalizado();
            return;
        }

        if (modalidade_pagamento == "A")
        {
            rBtnModPagVista.Checked = true;
            rBtnModPagVista2.Checked = true;
            rBtnModPagVista3.Checked = true;
        }
        else
        {
            rBtnModPagFinanciamento.Checked = true;
            rBtnModPagFinanciamento2.Checked = true;
            rBtnModPagFinanciamento3.Checked = true;
        }
        txtCliente.Text = cliente; txtEndereco.Text = endereco; txtCEP.Text = cep; txtBairro.Text = bairro; txtCidade.Text = cidade; txtUF.Text = UF;
        txtCPFCNPJ.Text = cpfcnpj; txtRGIE.Text = RGIE; txtNascimento.Text = nascimento; txtTelREsidencial.Text = tel_residencial; txtTelCom.Text = tel_comercial;
        txtCelular.Text = tel_celular; txtEmail.Text = email; txtMarca.Text = marca; txtModelo.Text = modelo; txtCorExterna.Text = cor_ext; txtChassiPlaca.Text = chassiplaca;
        txtAnoMod.Text = anomodelo; txtOpcionais.Text = opcinonais; txtFinanceira.Text = financeira; txtValoVeiculo.Text = valorveiculo;
        txtEmplacamento.Text = emp_trans; txtEntrada.Text = entrada; txtFormasPagamento.Text = formaspagamento; txtCarroUsado.Text = carrousado; txtModMarca.Text = modmarcavu;
        txtPlacaVU.Text = palcavu; txtVlFinanciamento.Text = financiamento; txtNrParcelas.Text = qtdeparcelas; txtVlParcelas.Text = vlparcelas; txtPlano.Text = planofinanciamento;
        txtCortesias.Text = cortesias; txtObs.Text = obs; txtPrevisao.Text = previsaoentrega; lblVendedor.Text = vendedor;
        lblPlaca.Text = palcavu; lblVencimentoPromissoria.Text = data; lblDiaPromissoria.Text = data; lblDataEmissao.Text = data; lblNomeEmitente.Text = cliente;
        lblBairroEmitente.Text = bairro; lblCidadeEmitente.Text = bairro; lblCPFEmitente.Text = cpfcnpj; lblEnderecoEmitente.Text = endereco;
        lblDataEmitente.Text = data; lblDataVendedor.Text = data; lblValorPromissoria.Text = multa; lblMulta.Text = multa; lblNomeEmitente.Text = cliente;
        lblCPFEmitente.Text = cpfcnpj; lblEnderecoEmitente.Text = endereco; lblBairroEmitente.Text = bairro; lblCidadeEmitente.Text = cidade; txtVlusadoAvaliacao.Text = vlutilizadoavaliacao;
        txtvlQuitacao.Text = vlquitacao; txtSaldoAvaliacao.Text = vlsaldoavaliacao; lblAssinatura.Text = cliente; txtAnoModelo.Text = anomodeloVU; lblAssinatura4.Text = cliente;


        txtCliente2.Text = cliente; txtEndereco2.Text = endereco; txtCEP2.Text = cep; txtBairro2.Text = bairro; txtCidade2.Text = cidade; txtUF2.Text = UF;
        txtCPFCNPJ2.Text = cpfcnpj; txtRGIE2.Text = RGIE; txtNascimento2.Text = nascimento; txtTelResidencial2.Text = tel_residencial; txtTelCom2.Text = tel_comercial;
        txtCelular2.Text = tel_celular; txtEmail2.Text = email; txtMarca2.Text = marca; txtModelo2.Text = modelo; txtCorExterna2.Text = cor_ext; txtChassiPlaca2.Text = chassiplaca;
        txtAnoModelo2.Text = anomodelo; txtOpcionais2.Text = opcinonais; txtFinanceira2.Text = financeira; txtValoVeiculo2.Text = valorveiculo;
        txtEmplacamento2.Text = emp_trans; txtEntrada2.Text = entrada; txtFormasPagamento2.Text = formaspagamento; txtCarroUsado2.Text = carrousado; txtModMarca2.Text = modmarcavu;
        txtPlacaVU2.Text = palcavu; txtVlFinanciamento2.Text = financiamento; txtNrParcelas2.Text = qtdeparcelas; txtVlParcelas2.Text = vlparcelas; txtPlano2.Text = planofinanciamento;
        txtCortesias2.Text = cortesias; txtObs2.Text = obs; txtPrevisao2.Text = previsaoentrega; lblVendedor2.Text = vendedor;
        lblPlaca2.Text = palcavu; lblVencimentoPromissoria2.Text = data; lblDiaPromissoria2.Text = data; lblDataEmissao2.Text = data; lblNomeEmitente2.Text = cliente;
        lblBairroEmitente2.Text = bairro; lblCidadeEmitente2.Text = bairro; lblCPFEmitente2.Text = cpfcnpj; lblEnderecoEmitente2.Text = endereco;
        lblDataEmitente2.Text = data; lblDataVendedor2.Text = data; lblValorPromissoria2.Text = multa; lblMulta2.Text = multa; lblNomeEmitente2.Text = cliente;
        lblCPFEmitente2.Text = cpfcnpj; lblEnderecoEmitente2.Text = endereco; lblBairroEmitente2.Text = bairro; lblCidadeEmitente2.Text = cidade; txtVlAvaliacao2.Text = vlutilizadoavaliacao;
        txtVlQuitacao2.Text = vlquitacao; txtSaldoAvaliacao2.Text = vlsaldoavaliacao; lblAssinatura2.Text = cliente; txtAnoModelo4.Text = anomodeloVU; lblAssinatura5.Text = cliente;


        txtCliente3.Text = cliente; txtEndereco3.Text = endereco; txtCEP3.Text = cep; txtBairro3.Text = bairro; txtCidade3.Text = cidade; txtUF3.Text = UF;
        txtCPFCNPJ3.Text = cpfcnpj; txtRGIE3.Text = RGIE; txtNascimento3.Text = nascimento; txtTelResidencial3.Text = tel_residencial; txtTelCom3.Text = tel_comercial;
        txtCelular3.Text = tel_celular; txtEmail3.Text = email; txtMarca3.Text = marca; txtModelo3.Text = modelo; txtCorExterna3.Text = cor_ext; txtChassiPlaca3.Text = chassiplaca;
        txtAnoModelo3.Text = anomodelo; txtOpcionais3.Text = opcinonais; txtFinanceira3.Text = financeira; txtValoVeiculo3.Text = valorveiculo;
        txtEmplacamento3.Text = emp_trans; txtEntrada3.Text = entrada; txtFormasPagamento3.Text = formaspagamento; txtCarroUsado3.Text = carrousado; txtModMarca3.Text = modmarcavu;
        txtPlacaVU3.Text = palcavu; txtVlFinanciamento3.Text = financiamento; txtNrParcelas3.Text = qtdeparcelas; txtVlParcelas3.Text = vlparcelas; txtPlano3.Text = planofinanciamento;
        txtCortesias3.Text = cortesias; txtObs3.Text = obs; txtPrevisao3.Text = previsaoentrega; lblVendedor3.Text = vendedor;
        lblPlaca3.Text = palcavu; lblVencimentoPromissoria3.Text = data; lblDiaPromissoria3.Text = data; lblDataEmissao3.Text = data; lblNomeEmitente3.Text = cliente;
        lblBairroEmitente3.Text = bairro; lblCidadeEmitente3.Text = bairro; lblCPFEmitente3.Text = cpfcnpj; lblEnderecoEmitente3.Text = endereco;
        lblDataEmitente3.Text = data; lblDataVendedor3.Text = data; lblValorPromissoria3.Text = multa; lblMulta3.Text = multa; lblNomeEmitente3.Text = cliente;
        lblCPFEmitente3.Text = cpfcnpj; lblEnderecoEmitente3.Text = endereco; lblBairroEmitente3.Text = bairro; lblCidadeEmitente3.Text = cidade; txtVlAvaliacao3.Text = vlutilizadoavaliacao;
        txtVlQuitacao3.Text = vlquitacao; txtSaldoAvaliacao3.Text = vlsaldoavaliacao; lblAssinatura3.Text = cliente; TextBox62.Text = anomodeloVU; lblAssinatura6.Text = cliente;

        txtdespachanteNOME.Text = cliente; txtdespachanteRG.Text = RGIE; txtdespachanteEMAIL.Text = email; txtdespachanteENDERECO.Text = endereco; txtdespachanteCEP.Text = cep; txtdespachanteFONE.Text = tel_celular; txtdespachanteCPF.Text = cpfcnpj;
        txtdespachanteCHASSI.Text = chassiplaca; txtdespachanteANOMODELO.Text = anomodelo; txtdespachanteMODELO.Text = modelo;
        
        lbldeclaracaocliente.Text = cliente; lbldeclaracaodata.Text = data; lbldeclaracaocliente1.Text = cliente; lbldeclaracaocpf2.Text = cpfcnpj;
       if(!String.IsNullOrEmpty(txtModMarca3.Text))
           {
               guiadocomprador.Visible = true;
           }


       

    }
}
