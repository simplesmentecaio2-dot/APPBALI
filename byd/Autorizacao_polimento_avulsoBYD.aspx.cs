public partial class byd_Autorizacao_polimento_avulso : PolimentoAvulsoBase
{
    protected override string MarcaPolimento { get { return "BYD"; } }
    protected override string EmpresaDocumento { get { return "BALI AUTO ELETRICS LTDA"; } }
    protected override string LoginRetorno { get { return "./loginAppcontrato.aspx"; } }
}
