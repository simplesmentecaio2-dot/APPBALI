# Auditoria - Contratos

As páginas de contrato registram operações em `App_Data/contrato-operacoes.log`.

Formato atual do log:

```text
data_hora	marca	usuario	acao	detalhe
```

## Ações principais

- `GRAVACAO_SUCESSO`: contrato gravado e redirecionado para impressão.
- `ERRO_GRAVACAO`: falha ao gravar o contrato.
- `VALIDACAO_NOVO`: bloqueio antes da gravação de contrato novo.
- `CHECKLIST_NOVO`: checklist final não confirmado.
- `DUPLICIDADE_CONFIRMADA`: usuário confirmou possível duplicidade e seguiu com a gravação.
- `DUPLICIDADE_BLOQUEADA_PROCEDURE`: procedure retornou contrato semelhante e bloqueou a gravação.
- `EDICAO_ALTERACOES`: edição gravada com resumo dos campos alterados.
- `EDICAO_SEM_ALTERACAO`: tentativa de edição sem mudança real.
- `ERRO_EDICAO`: falha ao salvar edição.
- `ERRO_CONSULTA`: falha em consulta/listagem.
- `CONSULTA_PERIODO_EXTENSO`: consulta feita com período grande.

## Uso operacional

- A aba Auditoria mostra os registros da marca atual.
- O filtro permite localizar por contrato, usuário, texto ou tipo de ocorrência.
- O botão `Copiar visíveis` copia somente os registros filtrados para encaminhamento interno.

## Evolução segura

Quando houver janela para banco, a evolução recomendada é criar uma tabela em `APPWF` para persistir a auditoria com colunas separadas:

```sql
CREATE TABLE APPWF.dbo.ContratoAuditoria (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DataHora DATETIME NOT NULL,
    Marca VARCHAR(20) NOT NULL,
    Usuario VARCHAR(100) NULL,
    Acao VARCHAR(80) NOT NULL,
    Detalhe NVARCHAR(MAX) NULL,
    Contrato VARCHAR(30) NULL,
    CriadoEm DATETIME NOT NULL DEFAULT GETDATE()
);
```

Depois disso, o log em arquivo pode continuar como fallback, mas a aba Auditoria deve consultar a tabela para filtros mais rápidos e relatórios por usuário/campo.
