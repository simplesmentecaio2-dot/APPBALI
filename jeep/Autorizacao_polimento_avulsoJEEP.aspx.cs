public partial class jeep_Autorizacao_polimento_avulso : PolimentoAvulsoBase
{
    protected override string MarcaPolimento { get { return "Jeep"; } }
    protected override string EmpresaDocumento { get { return "BALI MOTORS LTDA"; } }
    protected override string LoginRetorno { get { return "./loginAppcontrato.aspx"; } }
}
