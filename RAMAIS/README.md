# Sistema de Ramais

Modulo interno para consulta, cadastro, manutencao e impressao dos ramais do Grupo Bali.

## Paginas e views

- `default.aspx?view=consulta`: consulta de ramais por loja, setor, termo e status.
- `default.aspx?view=impressao`: grade de impressao em A4 retrato, agrupada por setor e filtrada por loja.
- `default.aspx?view=ramais`: cadastro, edicao e inativacao de ramais.
- `default.aspx?view=lojas`: cadastro e inativacao de lojas.
- `default.aspx?view=setores`: cadastro e inativacao de setores.
- `login.aspx`: login legado do modulo.

## Banco de dados

Banco: `APPWF`

Objetos principais:

- `dbo.ramais`: tabela principal de ramais.
- `dbo.ramais_lojas`: cadastro de lojas.
- `dbo.ramais_setores`: cadastro de setores.
- `dbo.ramais_resumo`: indicadores do painel.
- `dbo.ramais_ramal_listar`: consulta e impressao.
- `dbo.ramais_ramal_salvar`: inclusao e alteracao.
- `dbo.ramais_ramal_excluir`: inativacao logica.
- `dbo.ramais_loja_*`: procedures de loja.
- `dbo.ramais_setor_*`: procedures de setor.

O script versionado fica em `sql/ramais-schema.sql`.

## Regras operacionais

- A consulta fica liberada.
- Editar ou excluir ramais exige senha: `@bali2025`.
- Lojas e setores nao podem ser excluidos se houver ramal ativo vinculado.
- A impressao mostra somente ramais ativos.
- A grade de impressao deve sair em retrato para aproveitar melhor o papel.
- O ViewState usa `machineKey` fixo no `Web.config` e cookie HttpOnly `BaliViewStateKey`, evitando falha de MAC quando a sessao do usuario muda.
- Posts com ViewState antigo em Ramais sao redirecionados para a mesma tela com aviso amigavel.

## UX implementada

- Views separadas para consulta, impressao, ramais, lojas e setores.
- Impressao filtrada por loja e agrupada por setor.
- Tabelas com paginacao, ordenacao e layout responsivo no mobile.
- Exportacao CSV da consulta.
- Indicadores de ramais ativos, inativos, lojas, setores e lojas com ramais.
- Menu lateral com item ativo e link de acessibilidade para pular ao conteudo.

## Logs

Erros tratados no code-behind sao registrados em:

`App_Data/ramais-erros.log`
