# Comunicacao Interna (CI)

Modulo interno para cadastrar, consultar, editar, cancelar e imprimir Comunicacoes Internas do Grupo Bali.

## Paginas

- `default.aspx`: cadastro, consulta, filtros, exportacao CSV, duplicacao de CI e historico de alteracoes.
- `print.aspx`: impressao da CI em layout A4, com logos por marca e destaque para documentos cancelados.
- `erros.aspx`: consulta protegida dos erros registrados em `App_Data/ci-erros.log`.

## Banco de dados

Banco: `APPWF`

Objetos principais:

- `dbo.ci_comunicacoes`: tabela principal das CIs.
- `dbo.ci_comunicacoes_historico`: snapshots de alteracoes e cancelamentos.
- `dbo.ci_comunicacao_resumo`: indicadores do painel.
- `dbo.ci_comunicacao_listar`: consulta filtrada.
- `dbo.ci_comunicacao_obter`: detalhe para edicao/impressao.
- `dbo.ci_comunicacao_salvar`: inclusao e alteracao.
- `dbo.ci_comunicacao_cancelar`: cancelamento logico.
- `dbo.ci_comunicacao_historico_listar`: historico exibido na edicao.

O script versionado fica em `sql/ci-schema.sql`.

## Seguranca operacional

- Edicao e cancelamento exigem senha simples: `@ci*2026`.
- A senha fica validada no servidor em `default.aspx.cs`.
- O ViewState e vinculado a sessao do usuario.
- CIs canceladas nao exibem acoes de editar/cancelar na listagem.
- A procedure de salvar bloqueia alteracao de CI inexistente ou cancelada.

## UX implementada

- Filtros por periodo, marca, busca e status ativo.
- Atalhos de periodo: este mes, ultimos 30 dias, hoje e limpar.
- Ordenacao por cabecalho.
- Paginacao configuravel: 12, 25 ou 50 linhas.
- Exportacao CSV dos filtros atuais.
- Modelos rapidos para comunicado, solicitacao e procedimento.
- Rascunho local manual no navegador.
- Aviso ao sair com formulario alterado e nao salvo.
- Textareas com altura automatica.
- Tabelas responsivas em formato de card no mobile.
- Impressao com status, horario de geracao e marca d'agua para CI cancelada.
- Painel protegido para consulta de logs da CI.

## Logs

Erros tratados no code-behind sao registrados em:

`App_Data/ci-erros.log`

O log guarda data/hora, origem, usuario, URL e mensagem resumida.
