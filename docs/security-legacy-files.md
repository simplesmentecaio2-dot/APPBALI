# Inventario de backups e arquivos legados

Data da auditoria: 2026-07-05

Objetivo desta rodada: classificar arquivos antigos sem apagar nada do servidor. A decisao foi proteger e documentar, porque alguns arquivos podem ter relacao historica ou operacional.

## Classificacao

### Ativo

Arquivos e pastas em uso atual ou recentemente trabalhados:

- `Default.aspx`, `login.aspx`
- `intranet/` e `Intranet/`
- `veiculos/`, `jeep/`, `byd/` nas centrais, contratos, recibos e paginas principais
- `CI/`
- `RAMAIS/`
- `qrcode-veiculo/`
- `veiculos/patiojeep/` nas telas atuais: `default.aspx`, `registrar.aspx`, `transferir.aspx`, `historico.aspx`, `lojas.aspx`, `relatorios.aspx`, `barcode-logs.aspx`
- `tecnologia/` nas telas atuais de usuarios, permissoes, sessoes e centrais
- `admfinanceiro/Recibo/recibo.aspx` e recibos atuais

### Backup necessario

Arquivos com indicio claro de backup/copia historica. Nao foram removidos. Devem ficar protegidos e migrados para uma pasta fora do webroot quando houver janela segura:

- `BKPlogin.aspx`
- `veiculos/BKPprospeccao.aspx`
- `jeep/BKPprospeccao.aspx`
- `byd/BKPprospeccao.aspx`
- `veiculos/contratoBKP-11_08.aspx`
- `veiculos/contratodragonBKP.aspx`
- `jeep/contratodragonBKP.aspx`
- `byd/contratodragonBKP.aspx`
- `Print-Contrato*dragonBKP.aspx`
- `Copy of dashboard_evento.aspx`
- `gerador-assinatura/Copy of default-bkp.aspx`

### Morto/removivel, mas ainda preservado

Arquivos que parecem sobra de teste, editor ou copia local. Eles nao devem ser usados em producao. Nesta rodada, ficaram bloqueados/protegidos em vez de excluidos:

- `teste.aspx`, `teste.aspx.cs`, `teste.css`
- `App_Code/teste.cs`
- arquivos `~RF*.TMP`
- `Default1.aspx`
- `Registrar1.aspx`
- `registrar - Copia.aspx`
- `registrar.aspx - Copia.cs`
- `registrar_agendamento.aspx`
- `consultar_agendamento.aspx`
- `homolog.aspx`

### Precisa migrar

Pastas ou familias de tela que parecem legadas, mas podem conter regra antiga ou referencia operacional. Melhor migrar com analise individual:

- `veiculos/patio/`
- `jeep/patio/`
- `byd/patio/`
- `veiculos/VendasSab/`
- `admfinanceiro/Comissao/` com ReportViewer 11
- telas antigas de `Folder.aspx`
- paginas de dashboard/evento antigas

## Protecoes aplicadas nesta rodada

- Bloqueio 404 no pipeline ASP.NET para extensoes sensiveis: `.config`, `.cs`, `.asax`, `.sql`, `.log`, `.bak`, `.backup`, `.old`, `.orig`, `.tmp`, `.zip`, `.rar`, `.7z`, `.md`, `.user`, `.suo`, `.vb`, `.csproj`, `.secrets`.
- Bloqueio 404 no pipeline ASP.NET para arquivos iniciando com `teste`.
- Exigencia de login para paginas legadas com nomes como `BKP`, `Copy`, `Copia`, `Default1`, `Registrar1`, `homolog`, `registrar_agendamento` e `consultar_agendamento`.
- Nenhum arquivo foi apagado nesta rodada.

Observacao: alguns arquivos estaticos podem ser servidos diretamente pelo IIS antes do ASP.NET. O arquivo `teste.css` foi conferido e nao contem dados sensiveis, mas deve ser movido para fora do webroot em uma limpeza futura.

## Recomendacao de limpeza futura

1. Criar pasta fora do webroot para arquivo historico.
2. Mover primeiro somente arquivos classificados como backup necessario.
3. Monitorar por 30 dias se alguem acessa esses arquivos.
4. Depois mover os mortos/removiveis.
5. Somente excluir apos backup externo e validacao operacional.
