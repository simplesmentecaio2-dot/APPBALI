# Configuracao local segura

Este projeto usa arquivos locais em `App_Data` para manter segredos fora do Git.

Arquivos esperados no servidor:

- `connectionStrings.local.config`
- `machineKey.local.config`
- `appSettings.secrets.config`

Esses arquivos nao devem ser enviados ao GitHub. Eles contem conexoes de banco,
machineKey e configuracoes privadas de SMTP.

Em novo servidor, crie esses arquivos antes de publicar o `Web.config`.
