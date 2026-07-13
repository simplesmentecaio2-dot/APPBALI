public partial class veiculos_Autorizacao_polimento_avulso : PolimentoAvulsoBase
{
    protected override string MarcaPolimento { get { return "Fiat"; } }
    protected override string EmpresaDocumento { get { return "BALI BRASILIA AUTOMOVEIS LTDA"; } }
    protected override string LoginRetorno { get { return "./loginAppcontrato.aspx"; } }
}
