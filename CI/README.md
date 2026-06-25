# Comunicacao Interna (CI)

Modulo interno para cadastrar, consultar, editar, cancelar e imprimir Comunicacoes Internas do Grupo Bali.

## Paginas

- `default.aspx?view=consulta`: consulta, filtros, exportacao CSV, duplicacao de CI e historico de alteracoes.
- `default.aspx?view=nova`: cadastro e edicao de CI.
- `default.aspx?view=bi`: indicadores de CIs por periodo, marca, categoria, prioridade, destino e criador.
- `default.aspx?view=anotacoes`: textos padrao para consulta e copia em novas CIs.
- `print.aspx`: impressao da CI em layout A4, com logos por marca e destaque para documentos cancelados.
- `erros.aspx`: consulta protegida dos erros registrados em `App_Data/ci-erros.log`.

## Banco de dados

Banco: `APPWF`

Objetos principais:

- `dbo.ci_comunicacoes`: tabela principal das CIs.
- `dbo.ci_comunicacoes_historico`: snapshots de alteracoes e cancelamentos.
- `dbo.ci_comunicacao_resumo`: indicadores do painel.
- `dbo.ci_comunicacao_listar`: consulta filtrada, incluindo busca por codigo da CI, numero, responsavel e criador.
- `dbo.ci_comunicacao_obter`: detalhe para edicao/impressao.
- `dbo.ci_comunicacao_salvar`: inclusao e alteracao.
- `dbo.ci_comunicacao_cancelar`: cancelamento logico.
- `dbo.ci_comunicacao_historico_listar`: historico exibido na edicao.
- `dbo.ci_modelos`: modelos editaveis usados no cadastro.
- `dbo.ci_anotacoes`: textos padrao reutilizaveis.
- `dbo.ci_ciencias`: registros de ciencia por setor/responsavel.

O script versionado fica em `sql/ci-schema.sql`.

## Seguranca operacional

- Edicao, cancelamento e logs exigem senha simples: `@bali2025`.
- A senha fica validada no servidor em `default.aspx.cs`.
- O ViewState usa cookie HttpOnly estavel (`BaliViewStateKey`) e `machineKey` fixo.
- CIs canceladas nao exibem acoes de editar/cancelar na listagem.
- A procedure de salvar bloqueia alteracao de CI inexistente ou cancelada.
- As procedures de modelos/anotacoes bloqueiam falso sucesso quando o registro foi excluido.
- O cadastro bloqueia trechos de modelo nao revisados, como `[data]` ou `[descreva...]`.
- Campos longos possuem limites no navegador e no servidor para evitar impressao ruim.
- Posts com ViewState antigo em CI sao redirecionados para a mesma tela com aviso amigavel.

## UX implementada

- Filtros por periodo, marca, busca e status ativo.
- BI carrega somente quando a aba e aberta.
- Atalhos de periodo: este mes, ultimos 30 dias, hoje e limpar.
- Ordenacao por cabecalho.
- Paginacao configuravel: 12, 25 ou 50 linhas.
- Exportacao CSV dos filtros atuais.
- Acoes da tabela em formato de comandos compactos.
- Modelos editaveis para comunicado, solicitacao, procedimento e outros textos internos.
- Anotacoes para textos padrao que podem ser copiados para CIs.
- Rascunho local manual no navegador.
- Rascunho automatico no navegador quando ha conteudo digitado.
- Aviso ao sair com formulario alterado e nao salvo.
- Textareas com altura automatica.
- Tabelas responsivas em formato de card no mobile.
- Impressao com status, horario de geracao, marca d'agua para CI cancelada e retorno direto para consulta/nova CI.
- Menu lateral com estado ativo para BI, consulta, nova CI, anotacoes e logs.
- Painel protegido para consulta de logs da CI, com busca, ordenacao, paginacao e atualizacao manual.

## Logs

Erros tratados no code-behind sao registrados em:

`App_Data/ci-erros.log`

O log guarda data/hora, origem, usuario, URL e mensagem resumida.
