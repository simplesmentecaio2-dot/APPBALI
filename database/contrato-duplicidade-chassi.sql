USE [APP];
GO

/*
  Ajuste de duplicidade em contratos.

  Regra:
  - Mesmo cliente/CPF/modelo com o MESMO chassi continua sendo duplicidade bloqueante.
  - Mesmo cliente/CPF/modelo com chassi diferente deve ser permitido, pois pode ser
    uma nova venda legitima para o mesmo cliente.

  Este script documenta a alteracao aplicada em:
  - dbo.veiculos_insert_contrato_venda
  - dbo.veiculos_insert_contrato_vendajeep
  - dbo.veiculos_insert_contrato_vendaBYD
*/

DECLARE @sql nvarchar(max);

SELECT @sql = OBJECT_DEFINITION(OBJECT_ID('dbo.veiculos_insert_contrato_venda'));
SET @sql = REPLACE(@sql, 'CREATE procedure', 'ALTER procedure');
SET @sql = REPLACE(@sql,
'if (select COUNT(*) from veiculos_contrato_venda where cliente = @cliente  and cpfcnpj = @cpfcnpj and modelo = @modelo and tipo = @tipo) > 0 begin
		select id, ''N'' as obs from veiculos_contrato_venda where cliente = @cliente and cpfcnpj = @cpfcnpj and modelo = @modelo',
'if (select COUNT(*) from veiculos_contrato_venda where cliente = @cliente  and cpfcnpj = @cpfcnpj and modelo = @modelo and tipo = @tipo and upper(replace(replace(replace(replace(isnull(chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', '''')) = upper(replace(replace(replace(replace(isnull(@chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''))) > 0 begin
		select top 1 id, ''N'' as obs from veiculos_contrato_venda where cliente = @cliente and cpfcnpj = @cpfcnpj and modelo = @modelo and tipo = @tipo and upper(replace(replace(replace(replace(isnull(chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', '''')) = upper(replace(replace(replace(replace(isnull(@chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', '''')) order by id desc');
EXEC sp_executesql @sql;

SELECT @sql = OBJECT_DEFINITION(OBJECT_ID('dbo.veiculos_insert_contrato_vendajeep'));
SET @sql = REPLACE(@sql, 'CREATE procedure', 'ALTER procedure');
SET @sql = REPLACE(@sql,
'if (select COUNT(*) from veiculos_contrato_vendaJEEP where cliente = @cliente  and cpfcnpj = @cpfcnpj and modelo = @modelo) > 0 begin
		select id, ''N'' as obs from veiculos_contrato_vendaJEEP where cliente = @cliente and cpfcnpj = @cpfcnpj and modelo = @modelo',
'if (select COUNT(*) from veiculos_contrato_vendaJEEP where cliente = @cliente  and cpfcnpj = @cpfcnpj and modelo = @modelo and upper(replace(replace(replace(replace(isnull(chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', '''')) = upper(replace(replace(replace(replace(isnull(@chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''))) > 0 begin
		select top 1 id, ''N'' as obs from veiculos_contrato_vendaJEEP where cliente = @cliente and cpfcnpj = @cpfcnpj and modelo = @modelo and upper(replace(replace(replace(replace(isnull(chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', '''')) = upper(replace(replace(replace(replace(isnull(@chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', '''')) order by id desc');
EXEC sp_executesql @sql;

SELECT @sql = OBJECT_DEFINITION(OBJECT_ID('dbo.veiculos_insert_contrato_vendaBYD'));
SET @sql = REPLACE(@sql, 'CREATE procedure', 'ALTER procedure');
SET @sql = REPLACE(@sql,
'if (select COUNT(*) from veiculos_contrato_vendaBYD where cliente = @cliente  and cpfcnpj = @cpfcnpj and modelo = @modelo) > 0 begin
		select id, ''N'' as obs from veiculos_contrato_vendaBYD where cliente = @cliente and cpfcnpj = @cpfcnpj and modelo = @modelo',
'if (select COUNT(*) from veiculos_contrato_vendaBYD where cliente = @cliente  and cpfcnpj = @cpfcnpj and modelo = @modelo and upper(replace(replace(replace(replace(isnull(chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', '''')) = upper(replace(replace(replace(replace(isnull(@chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''))) > 0 begin
		select top 1 id, ''N'' as obs from veiculos_contrato_vendaBYD where cliente = @cliente and cpfcnpj = @cpfcnpj and modelo = @modelo and upper(replace(replace(replace(replace(isnull(chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', '''')) = upper(replace(replace(replace(replace(isnull(@chassiplaca, ''''), '' '', ''''), ''-'', ''''), ''.'', ''''), ''/'', '''')) order by id desc');
EXEC sp_executesql @sql;
