# Performance SQL - Contratos

Este documento registra os índices recomendados para melhorar a performance das abas Consulta Novo, Consulta Usado, Venda Direta e BI das páginas de contrato.

As páginas filtram principalmente por `tipo`, intervalo de `data` e ordenam por `data desc, id desc`. Por isso, o melhor ganho tende a vir de um índice composto por marca.

## Tabelas

- `APP.dbo.veiculos_contrato_venda`
- `APP.dbo.veiculos_contrato_vendaJEEP`
- `APP.dbo.veiculos_contrato_vendaBYD`

## Índice recomendado

Executar somente em janela de manutenção e após revisar nomes de índices existentes:

```sql
CREATE INDEX IX_veiculos_contrato_venda_tipo_data_id
ON APP.dbo.veiculos_contrato_venda (tipo, [data] DESC, id DESC)
INCLUDE (cliente, cpfcnpj, RGIE, tel_residencial, tel_comercial, tel_celular, email, vendedor, valorveiculo, modalidade_pagamento);

CREATE INDEX IX_veiculos_contrato_vendaJEEP_tipo_data_id
ON APP.dbo.veiculos_contrato_vendaJEEP (tipo, [data] DESC, id DESC)
INCLUDE (cliente, cpfcnpj, RGIE, tel_residencial, tel_comercial, tel_celular, email, vendedor, valorveiculo, modalidade_pagamento);

CREATE INDEX IX_veiculos_contrato_vendaBYD_tipo_data_id
ON APP.dbo.veiculos_contrato_vendaBYD (tipo, [data] DESC, id DESC)
INCLUDE (cliente, cpfcnpj, RGIE, tel_residencial, tel_comercial, tel_celular, email, vendedor, valorveiculo, modalidade_pagamento);
```

## Observações

- Antes de criar, verificar se já existe índice equivalente.
- Após criar, medir novamente as consultas de período e BI.
- Se a tabela crescer muito, considerar paginação real no servidor para as consultas.
- O cache curto das páginas foi mantido em 45 segundos para reduzir chamadas repetidas sem esconder atualizações por muito tempo.
