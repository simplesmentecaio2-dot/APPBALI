# Inventario de dependencias front-end legadas

Data da auditoria: 2026-07-05

Objetivo desta rodada: mapear bibliotecas antigas e registrar a estrategia segura de atualizacao. Nenhuma biblioteca global foi substituida nesta rodada, porque o projeto usa ASP.NET WebForms legado, scripts inline, postbacks e plugins antigos que podem quebrar se jQuery/Bootstrap/DataTables forem trocados de uma vez.

## Resumo executivo

| Dependencia | Locais principais | Risco | Acao segura agora | Proximo passo recomendado |
| --- | --- | --- | --- | --- |
| jQuery 1.6.x / 1.9.1 / 1.10.2 | `scripts/`, `js/`, `veiculos/assets/`, `jeep/assets/`, `byd/assets/`, `tables/` | Alto: versoes antigas e duplicadas, risco de plugins dependentes e bugs conhecidos | Manter paginas atras de login, headers de seguranca e evitar CDN externo | Migrar por modulo: contratos, centrais, patio, financeiro |
| jQuery 3.2.1 / 3.3.1 | `vendor/jquery/`, `Intranet/resources/js/` | Medio: melhor que 1.x, mas ainda antigo | Manter isolado por pasta/modulo | Atualizar junto com Bootstrap da mesma tela |
| Bootstrap 4.1.x / 4.2.x / 5.x | raiz, `vendor/bootstrap/`, `Intranet/resources/js/` | Medio: versoes diferentes podem conflitar visualmente | Nao misturar assets entre modulos | Padronizar por familia de telas |
| DataTables | `tables/`, `veiculos/assets/`, `jeep/assets/`, `byd/assets/`, `tecnologia/` | Medio: plugins antigos e inicializacoes especificas | Manter somente em paginas autenticadas | Atualizar primeiro onde ha tabelas criticas e testes visuais |
| Moment / daterangepicker / datepicker | patios, VendasSab, assets das marcas | Medio: biblioteca antiga, risco em parsing de datas | Validacao de datas no servidor e limite de periodo nos BIs | Substituir gradualmente por flatpickr/date-fns ou componente atual |
| Select2 | `vendor/select2/` das marcas e patios | Medio | Isolar por modulo | Atualizar quando a tela for revisada |
| Quagga / barcode scanner | `veiculos/patiojeep/assets/js/` e copias antigas | Medio: permissao de camera e biblioteca antiga | Header liberando camera somente em `registrar.aspx`; logs de leitura ativos | Manter somente versao ativa e arquivar copias antigas depois de homologar |
| Chart.js / ChartJS.js | `scripts/`, marcas | Medio | Usar dados validados no servidor | Consolidar em uma unica versao por modulo BI |
| ReportViewer 11 | `admfinanceiro/Comissao/`, Web.config | Medio/alto por ser componente antigo | Manter paginas atras de login | Avaliar substituicao por geracao PDF/HTML moderna apenas quando necessario |
| AjaxControlToolkit | Web.config | Medio | Manter por compatibilidade | Remover quando paginas antigas forem migradas |

## Regras de atualizacao segura

1. Nao atualizar jQuery/Bootstrap globalmente.
2. Atualizar uma familia de paginas por vez.
3. Antes de trocar biblioteca, registrar print/HTML atual e principais fluxos.
4. Apos troca, testar login, postback, calendario, mascara, tabela, impressao e modal.
5. Se uma tela usar WebForms com `UpdatePanel`, `ScriptManager` ou controles ASP.NET antigos, testar com mais cuidado.
6. Evitar CDN externo. Preferir assets locais versionados.
7. Remover duplicatas somente depois de confirmar que nenhuma pagina referencia o arquivo.

## Acoes feitas nesta rodada

- Mantida a compatibilidade operacional.
- Aplicados headers de seguranca no pipeline ASP.NET.
- Mantida CSP estrita somente em pagina publica de QR Code, onde ela e segura.
- Mantida CSP moderada em telas de login.
- Camera bloqueada por padrao e liberada somente no leitor de codigo de barras do patio.

## Riscos que continuam documentados

- Existem copias antigas de jQuery 1.x ainda usadas por telas antigas.
- Existem assets duplicados por marca.
- Existem bibliotecas de calendario antigas em modulos de patio e vendas.
- Existem componentes WebForms antigos que devem ser substituidos apenas quando a tela for modernizada.
