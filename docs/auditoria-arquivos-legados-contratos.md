# Auditoria segura de arquivos legados - contratos

Data: 2026-06-24

Este documento registra a auditoria inicial para limpeza e modernizacao sem risco nas telas de contrato. A regra operacional e simples: nenhum arquivo legado deve ser removido sem commit proprio, validacao HTTP das telas afetadas e possibilidade clara de retorno pelo GitHub.

## Escopo ativo nesta etapa

Arquivos considerados ativos para a rotina principal de contratos:

- `veiculos/contrato.aspx` e `veiculos/contrato.aspx.cs`
- `jeep/contrato.aspx` e `jeep/contrato.aspx.cs`
- `byd/contrato.aspx` e `byd/contrato.aspx.cs`
- `css/bali-contract.css`
- `js/bali-contract.js`
- paginas de impressao chamadas pelas consultas de contratos

Esses arquivos devem continuar recebendo melhorias em commits pequenos e validados.

## Arquivos modificados fora desta rodada

- `veiculos/central-links.json`

Este arquivo ja aparece modificado no ambiente e nao deve ser misturado com commits de contrato sem uma solicitacao explicita.

## Candidatos a backup ou legado

Foram encontrados arquivos com nomes tipicos de backup ou copia manual, por exemplo:

- `veiculos/contratoBKP-11_08.aspx`
- `veiculos/contratoBKP-11_08.aspx.cs`
- `veiculos/contratodragonBKP.aspx`
- `veiculos/Print-ContratoVNdragonBKP.aspx`
- `veiculos/Print-ContratoVUdragonBKP.aspx`
- `jeep/Print-ContratoVNdragonBKP.aspx`
- `jeep/Print-ContratoVUdragonBKP.aspx`
- `byd/Print-ContratoVNdragonBKP.aspx`
- `byd/Print-ContratoVUdragonBKP.aspx`
- arquivos com prefixo `BKP`
- arquivos com nome `Copy of`
- arquivos `.zip` usados como backup local
- imagens `bkp` dentro de `img` e subpastas antigas

Esses arquivos devem ser classificados antes de qualquer remocao.

## Classificacao recomendada

Ativo:
Arquivos acessados por links reais, code-behind em uso, paginas de login, paginas de impressao e recursos compartilhados carregados por CSS ou JavaScript.

Backup necessario:
Arquivos que ainda servem como referencia de regra de negocio, layout antigo de contrato ou impressao, mas nao sao acessados diretamente pelo usuario.

Morto/removivel:
Copias antigas que possuem equivalente versionado no GitHub, arquivos com `Copy of`, backups duplicados e pacotes `.zip` ja substituidos por versionamento.

Precisa migrar:
Paginas antigas que ainda funcionam, mas usam CSS/JS inline, queries antigas, controles WebForms sem padrao visual ou fluxos importantes ainda fora dos componentes modernos.

## Processo seguro para limpeza futura

1. Mapear referencias com `rg` antes de remover.
2. Remover apenas um grupo pequeno por commit.
3. Validar as paginas afetadas com HTTP 200.
4. Conferir `git status` para evitar arquivos nao relacionados.
5. Fazer commit e push.
6. Testar no navegador antes de seguir para o proximo grupo.

## Prioridade sugerida

1. Manter o foco nas tres telas de contrato ate concluir UX, validacoes e performance.
2. Depois classificar backups de impressao de contrato por marca.
3. Em seguida revisar copias antigas de prospeccao e dashboards.
4. Por ultimo, limpar imagens e pacotes de backup locais.

