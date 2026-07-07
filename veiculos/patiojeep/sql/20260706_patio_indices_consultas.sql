SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NOCOUNT ON;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_consulta_novos' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_consulta_novos
        ON dbo.veiculos_patio_locacao(baixado_venda, loja_atual_id, loja_id, dt_cad DESC)
        INCLUDE (ve_nr, fun_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_locacao_ve_nr_lookup' AND object_id = OBJECT_ID('dbo.veiculos_patio_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_locacao_ve_nr_lookup
        ON dbo.veiculos_patio_locacao(ve_nr)
        INCLUDE (baixado_venda, loja_id, loja_atual_id, dt_cad, fun_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_transferencia_ve_nr_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_transferencia'))
BEGIN
    CREATE INDEX IX_veiculos_patio_transferencia_ve_nr_dt
        ON dbo.veiculos_patio_transferencia(ve_nr, dt_transf DESC)
        INCLUDE (loja_orig, loja_dest, fun_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_seminovos_locacao_consulta' AND object_id = OBJECT_ID('dbo.veiculos_patio_seminovos_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_seminovos_locacao_consulta
        ON dbo.veiculos_patio_seminovos_locacao(ativo, loja_atual_id, loja_id, dt_cad DESC)
        INCLUDE (id, ve_nr, ve_chassi, ve_placa, ve_renavam, ve_ds, cor_ds, numeronf, fun_cad, observacao);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_seminovos_locacao_busca' AND object_id = OBJECT_ID('dbo.veiculos_patio_seminovos_locacao'))
BEGIN
    CREATE INDEX IX_veiculos_patio_seminovos_locacao_busca
        ON dbo.veiculos_patio_seminovos_locacao(ativo, ve_nr, id)
        INCLUDE (loja_id, loja_atual_id, ve_chassi, ve_placa, ve_renavam, ve_ds, dt_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_seminovos_transferencia_id_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_seminovos_transferencia'))
BEGIN
    CREATE INDEX IX_veiculos_patio_seminovos_transferencia_id_dt
        ON dbo.veiculos_patio_seminovos_transferencia(seminovo_id, dt_transf DESC)
        INCLUDE (loja_orig, loja_dest, fun_cad);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_seminovos_auditoria_ref_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_seminovos_auditoria'))
BEGIN
    CREATE INDEX IX_veiculos_patio_seminovos_auditoria_ref_dt
        ON dbo.veiculos_patio_seminovos_auditoria(referencia, dt DESC)
        INCLUDE (acao, usuario, ve_nr, detalhe, ip);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_veiculos_patio_auditoria_geral_veiculo_dt' AND object_id = OBJECT_ID('dbo.veiculos_patio_auditoria_geral'))
BEGIN
    CREATE INDEX IX_veiculos_patio_auditoria_geral_veiculo_dt
        ON dbo.veiculos_patio_auditoria_geral(ve_nr, origem, dt DESC)
        INCLUDE (acao, usuario, detalhe, ip);
END;
