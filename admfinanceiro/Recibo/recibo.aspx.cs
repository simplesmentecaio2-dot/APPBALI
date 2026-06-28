using System;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Web.UI;

public partial class admfinanceiro_Comissao_geral : System.Web.UI.Page
{
    private static readonly CultureInfo PtBr = new CultureInfo("pt-BR");
    private const string EmpresaPadrao = "BALI BRAS\u00cdLIA AUTOM\u00d3VEIS LTDA";

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentEncoding = System.Text.Encoding.UTF8;
        Response.Charset = "utf-8";

        if (!IsPostBack)
        {
            PreencherUsuario();
            SelecionarMesAtual();
            txtTextoRecibo.Text = ModeloPadrao(true);
            lbldtAtual.Text = DataPorExtenso(DateTime.Now);
        }
        else
        {
            PreencherUsuario();
        }
    }

    protected void btnGerarRecibo_Click(object sender, EventArgs e)
    {
        decimal valor;
        string favorecido = (txtFavorecido.Text ?? "").Trim();
        string textoBase = (txtTextoRecibo.Text ?? "").Trim();

        LimparMensagem();

        if (!TryParseMoeda(txtValor.Text, out valor) || valor <= 0)
        {
            ExibirMensagem("Informe um valor maior que zero.");
            pnlImpressao.Visible = false;
            receiptEmptyPreview.Visible = true;
            return;
        }

        if (favorecido.Length < 3)
        {
            ExibirMensagem("Informe o nome do favorecido.");
            pnlImpressao.Visible = false;
            receiptEmptyPreview.Visible = true;
            return;
        }

        if (textoBase.Length == 0)
        {
            textoBase = ModeloPadrao(rBtnVendas.Checked);
            txtTextoRecibo.Text = textoBase;
        }

        string valorFormatado = valor.ToString("C", PtBr);
        string textoFinal = AplicarVariaveis(textoBase, valor, favorecido);

        lblValorRecibo.Text = valorFormatado;
        lblFavorecido.Text = favorecido.ToUpper(PtBr);
        lbldtAtual.Text = DataPorExtenso(DateTime.Now);
        litTextoRecibo.Text = textoFinal;
        pnlImpressao.Visible = true;
        receiptEmptyPreview.Visible = false;

        ScriptManager.RegisterStartupScript(this, GetType(), "reciboGerado", "window.reciboFinanceiroAfterGenerate && window.reciboFinanceiroAfterGenerate();", true);
    }

    private void PreencherUsuario()
    {
        lblUsuario.Text = Session["usuario"] == null ? "-" : Convert.ToString(Session["usuario"]);
        lblTipo.Text = Session["usuario_codigo"] == null ? "-" : Convert.ToString(Session["usuario_codigo"]);
    }

    private void SelecionarMesAtual()
    {
        string mes = DateTime.Now.Month.ToString(PtBr);
        if (ddListMes.Items.FindByValue(mes) != null)
        {
            ddListMes.SelectedValue = mes;
        }
    }

    private string ModeloPadrao(bool vendas)
    {
        string tipo = vendas ? "PREMIA\u00c7\u00c3O DE VENDAS" : "SUPERVIS\u00c3O DE VENDAS";
        return "Recebi da {empresa}, a quantia de {valor} ({valor_extenso}), referente \u00e0 " + tipo + " do m\u00eas de {mes}.";
    }

    private string AplicarVariaveis(string texto, decimal valor, string favorecido)
    {
        string tipo = rBtnVendas.Checked ? "PREMIA\u00c7\u00c3O DE VENDAS" : "SUPERVIS\u00c3O DE VENDAS";
        string valorFormatado = valor.ToString("C", PtBr);
        string valorExtenso = ValorExtenso(valor);

        texto = TrocarVariavel(texto, "empresa", EmpresaPadrao);
        texto = TrocarVariavel(texto, "valor", valorFormatado);
        texto = TrocarVariavel(texto, "valor_extenso", valorExtenso);
        texto = TrocarVariavel(texto, "mes", ddListMes.SelectedItem.Text);
        texto = TrocarVariavel(texto, "tipo", tipo);
        texto = TrocarVariavel(texto, "favorecido", favorecido);
        texto = TrocarVariavel(texto, "data", DataPorExtenso(DateTime.Now));

        return texto;
    }

    private string TrocarVariavel(string texto, string nome, string valor)
    {
        return Regex.Replace(texto ?? "", "\\{" + Regex.Escape(nome) + "\\}", valor ?? "", RegexOptions.IgnoreCase);
    }

    private bool TryParseMoeda(string texto, out decimal valor)
    {
        valor = 0;
        texto = (texto ?? "").Trim();
        if (texto.Length == 0) return false;

        texto = texto.Replace("R$", "").Trim();
        return Decimal.TryParse(texto, NumberStyles.Number | NumberStyles.AllowCurrencySymbol, PtBr, out valor);
    }

    private string DataPorExtenso(DateTime data)
    {
        return data.ToString("dd 'de' MMMM 'de' yyyy", PtBr);
    }

    private void ExibirMensagem(string mensagem)
    {
        lblMensagem.Text = mensagem;
        lblMensagem.CssClass = "receipt-message is-visible";
    }

    private void LimparMensagem()
    {
        lblMensagem.Text = "";
        lblMensagem.CssClass = "receipt-message";
    }

    private string ValorExtenso(decimal valor)
    {
        long reais = (long)Math.Floor(valor);
        int centavos = (int)Math.Round((valor - reais) * 100, MidpointRounding.AwayFromZero);

        if (centavos == 100)
        {
            reais++;
            centavos = 0;
        }

        string extenso = reais == 0 ? "" : NumeroExtenso(reais) + (reais == 1 ? " real" : " reais");

        if (centavos > 0)
        {
            string centavosTexto = NumeroExtenso(centavos) + (centavos == 1 ? " centavo" : " centavos");
            extenso = extenso.Length > 0 ? extenso + " e " + centavosTexto : centavosTexto;
        }

        if (extenso.Length == 0)
        {
            extenso = "zero real";
        }

        return Char.ToUpper(extenso[0], PtBr) + extenso.Substring(1);
    }

    private string NumeroExtenso(long numero)
    {
        if (numero == 0) return "zero";

        string[] singular = { "", " mil", " milh\u00e3o", " bilh\u00e3o" };
        string[] plural = { "", " mil", " milh\u00f5es", " bilh\u00f5es" };
        string resultado = "";
        int grupo = 0;

        while (numero > 0)
        {
            int parte = (int)(numero % 1000);
            if (parte > 0)
            {
                string textoParte = CentenaExtenso(parte);
                if (grupo == 1 && parte == 1)
                {
                    textoParte = "mil";
                }
                else
                {
                    textoParte += parte == 1 ? singular[grupo] : plural[grupo];
                }

                resultado = resultado.Length == 0 ? textoParte : textoParte + " e " + resultado;
            }

            numero /= 1000;
            grupo++;
        }

        return resultado;
    }

    private string CentenaExtenso(int numero)
    {
        string[] unidades = { "", "um", "dois", "tr\u00eas", "quatro", "cinco", "seis", "sete", "oito", "nove" };
        string[] especiais = { "dez", "onze", "doze", "treze", "quatorze", "quinze", "dezesseis", "dezessete", "dezoito", "dezenove" };
        string[] dezenas = { "", "", "vinte", "trinta", "quarenta", "cinquenta", "sessenta", "setenta", "oitenta", "noventa" };
        string[] centenas = { "", "cento", "duzentos", "trezentos", "quatrocentos", "quinhentos", "seiscentos", "setecentos", "oitocentos", "novecentos" };

        if (numero == 100) return "cem";
        if (numero < 10) return unidades[numero];
        if (numero < 20) return especiais[numero - 10];
        if (numero < 100)
        {
            int dezena = numero / 10;
            int unidade = numero % 10;
            return unidade == 0 ? dezenas[dezena] : dezenas[dezena] + " e " + unidades[unidade];
        }

        int centena = numero / 100;
        int resto = numero % 100;
        return resto == 0 ? centenas[centena] : centenas[centena] + " e " + CentenaExtenso(resto);
    }
}
