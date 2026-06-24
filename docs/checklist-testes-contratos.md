# Checklist de testes - contratos

Data: 2026-06-24

Escopo:

- `veiculos/contrato.aspx`
- `jeep/contrato.aspx`
- `byd/contrato.aspx`

Use este roteiro antes de liberar mudancas nas telas de contrato.

## Acesso

- Abrir a tela de contrato da marca.
- Confirmar que a pagina carrega sem erro.
- Confirmar que a aba inicial e `BI`.
- Confirmar que o usuario logado aparece no cabecalho.

## BI

- Conferir se a data inicial e final abrem com o mes atual.
- Clicar em `Atualizar BI`.
- Conferir se os cards nao estouram texto ou valor.
- Conferir graficos de tipo, pagamento, vendedor, valor por tipo e evolucao diaria.
- Testar periodo maior que 12 meses e confirmar mensagem de limite.

## Novo contrato

- Abrir a aba `Novo +`.
- Selecionar `NOVO`.
- Confirmar que o formulario aparece em etapas.
- Preencher cliente, CPF/CNPJ, dados do veiculo, valores e vendedor.
- Avancar etapa por etapa.
- Deixar um campo obrigatorio vazio e confirmar mensagem clara no campo.
- Conferir calculo de financiamento e saldo avaliacao.
- Marcar checklist final.
- Testar aviso de contrato semelhante quando houver duplicidade.

## Usado

- Abrir a aba `Novo +`.
- Selecionar `USADO`.
- Repetir os testes do formulario.
- Confirmar que os campos de avaliacao, quitacao e saldo funcionam.
- Confirmar que valor negativo exibe mensagem antes de gravar.

## Venda direta - Fiat

- Na tela Fiat, selecionar `VENDA DIRETA` quando disponivel.
- Repetir validacoes principais.
- Conferir se a consulta VD abre a impressao correta.

## Consulta Novo

- Abrir `Consulta Novo`.
- Usar periodo do mes atual.
- Confirmar que o calendario abre completo.
- Confirmar que o filtro de periodo nao tem fundo da marca.
- Clicar em `Processar VN`.
- Confirmar tabela com paginacao, busca e botao `Imprimir`.
- Abrir um contrato pelo ID/botao e confirmar que direciona para impressao.

## Consulta Usado

- Abrir `Consulta Usado`.
- Usar periodo do mes atual.
- Confirmar que o calendario abre completo.
- Confirmar que o filtro de periodo nao tem fundo da marca.
- Clicar em `Processar VU`.
- Confirmar tabela com paginacao, busca e botao `Imprimir`.
- Abrir um contrato pelo ID/botao e confirmar que direciona para impressao.

## Editar contrato

- Abrir `Editar Contrato`.
- Informar um ID valido.
- Confirmar que os dados carregam.
- Alterar um campo simples.
- Conferir painel `Alteracoes da edicao`.
- Tentar gravar sem checklist e confirmar bloqueio.
- Marcar checklist e gravar.
- Conferir mensagem de sucesso.
- Consultar o historico/auditoria e confirmar registro da alteracao.

## Mobile

- Abrir as tres marcas em largura de celular.
- Confirmar rolagem ate o final da pagina.
- Confirmar que etapas do formulario ficam uma por vez.
- Confirmar que filtros de consulta ficam empilhados.
- Confirmar que tabelas de consulta viram cards legiveis.
- Confirmar que calendario abre completo e permite selecionar o dia.

## Auditoria

- Abrir a aba de auditoria/ocorrencias.
- Filtrar por contrato, usuario ou texto.
- Filtrar por tipo de ocorrencia.
- Confirmar que eventos de validacao, gravacao e edicao aparecem.

## Regressao visual

- Conferir se os cabecalhos mantem a cor da marca.
- Conferir se os cards internos nao ficam estourados.
- Conferir se botoes e textos cabem no mobile.
- Conferir se nao ha fundo vermelho, verde ou azul nos cards de filtro de consulta.

