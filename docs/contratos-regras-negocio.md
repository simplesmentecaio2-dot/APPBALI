# Contratos - Regras de Negócio

Este documento registra as regras principais das páginas:

- `/veiculos/contrato.aspx`
- `/jeep/contrato.aspx`
- `/byd/contrato.aspx`

## Tipos de contrato

- `VN`: veículo novo.
- `VU`: veículo usado.
- `VD`: venda direta, disponível na Fiat.

Importante: mesmo quando o usuário seleciona contrato novo, ele pode informar um veículo usado como troca. Isso é esperado no negócio e não deve ser bloqueado por validação automática.

## Campos principais

- Cliente, CPF/CNPJ, marca, modelo, chassi/placa, vendedor e valor do veículo são campos essenciais.
- CPF/CNPJ aceita 11 ou 14 números e pode ser salvo formatado.
- Chassi/placa precisa ter pelo menos 7 letras ou números.
- Telefone é opcional, mas quando preenchido deve ter DDD + número.
- E-mail é opcional, mas quando preenchido precisa ter formato válido.

## Cálculos

- Financiamento = valor do veículo - entrada - valor utilizado da avaliação.
- Saldo avaliação = avaliação do usado - valor utilizado da avaliação - quitação.
- Financiamento negativo indica que entrada + avaliação utilizada superam o valor do veículo.
- Saldo avaliação negativo indica que quitação + valor utilizado superam a avaliação do usado.

## Modalidade de pagamento

- À vista: o usuário deve conferir entrada e formas de pagamento.
- Financiamento: o usuário deve conferir financeira, quantidade de parcelas e valor da parcela.
- Quantidade de parcelas deve estar entre 1 e 120.
- Valor da parcela deve ser maior que zero quando houver financiamento.

## Duplicidade

A validação de duplicidade considera contrato semelhante recente quando:

- há chassi/placa igual; ou
- há CPF/CNPJ igual, modelo igual e valor muito próximo.

Um mesmo cliente pode ter mais de um contrato ao longo do tempo. Por isso a duplicidade não deve bloquear automaticamente toda compra do mesmo CPF/CNPJ. Quando o sistema encontra contrato semelhante recente, o usuário pode confirmar ciência de duplicidade para seguir.

## Fluxo de gravação

1. O navegador valida campos principais e mostra mensagens por campo.
2. O servidor normaliza documentos, telefones, chassi/placa, CEP, UF, e-mail e valores.
3. O servidor valida regras principais novamente.
4. O checklist final precisa estar confirmado.
5. A procedure de gravação retorna sucesso, duplicidade ou erro.
6. Em sucesso, a página redireciona para a impressão do contrato.

## Auditoria

As operações são registradas em `App_Data/contrato-operacoes.log` com:

- data/hora;
- marca;
- usuário;
- ação;
- detalhe com página, IP, contrato, tipo, CPF/CNPJ, chassi/placa e motivo quando disponível.
