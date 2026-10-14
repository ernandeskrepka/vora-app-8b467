# Subir o sistema na Netlify (passo a passo)

O objetivo e sair com um link funcionando, sem terminal. Sao tres passos seus
(uns 5 minutos) e o resto fica automatico: cada push no `main` gera um deploy
novo.

## 1. Criar o site a partir do repositorio

Abra o link abaixo e confirme:

<https://app.netlify.com/start/deploy?repository=https://github.com/ernandeskrepka/vora-app>

Se ele pedir, autorize a Netlify a ler o GitHub e escolha o repositorio
`ernandeskrepka/vora-app`. Nao mude nada no build: o `netlify.toml` do
repositorio ja traz o comando certo, o plugin do Next e os padroes seguros
(`META_DRY_RUN=true`, `WHATSAPP_MODE=log`).

> **Por que nao dar "Link repository" num site que ja existe?** A Netlify so
> deixa ligar um repositorio a um site que ja teve um deploy de producao
> ("Site must have a production deploy before linking a repository"). Criar o
> site ja a partir do Git resolve isso porque o primeiro deploy sai no mesmo
> fluxo.

Esse primeiro deploy sobe o site sem banco e sem segredos - e esperado. O build
foi feito para nao quebrar nesse estado: ele avisa que nao achou banco e segue.

## 2. Criar o banco

No painel do site: **Project configuration -> Database** (ou **Extensions ->
Netlify DB**) e crie o Postgres. A Netlify injeta a variavel `NETLIFY_DB_URL`,
que o app usa como `DATABASE_URL` quando essa nao existe.

As tabelas sao criadas pelas migrations em `netlify/database/migrations/`,
aplicadas pela Netlify no deploy. O script `scripts/preparar-hospedagem.mjs`
pula `prisma db push` na Netlify: criar as tabelas durante o build entraria em
conflito com as migrations da plataforma.

A migration inicial aceita enums, tabelas, indices e chaves estrangeiras ja
existentes, preservando os dados de bancos preparados anteriormente pelo
script. Novas alteracoes do schema Prisma precisam de novas migrations SQL
nesse diretorio; nao use `prisma db push` para atualizar o banco da Netlify.

## 3. Variaveis do site

Em **Project configuration -> Environment variables**, o minimo e:

| Variavel | Valor |
| --- | --- |
| `APP_URL` | o endereco final do site (entra nos links de aprovacao) |
| `ENCRYPTION_KEY` | 32 bytes em base64 (`openssl rand -base64 32`) |
| `AGENDA_TOKEN` | um segredo qualquer; protege `/api/agenda` |
| `ADMIN_EMAIL` | e-mail do primeiro login |
| `ADMIN_SENHA` | senha do primeiro login (10+ caracteres) |

O resto (`QUEUE_DRIVER=none`, `STORAGE_DRIVER=netlify`, `META_DRY_RUN=true`,
`WHATSAPP_MODE=log`, `INTERNAL_NOTIFY_CHANNEL=log`, `APP_TIMEZONE`) ja vem do
`netlify.toml`.

Depois de mexer nas variaveis, rode **Deploys -> Trigger deploy -> Clear cache
and deploy site** (ou espere o proximo push).

## 4. Entrar

Abra `/login`. Se o banco estiver vazio, a propria tela cria o primeiro usuario
com `ADMIN_EMAIL` e `ADMIN_SENHA` - depois disso essas variaveis sao ignoradas.

## O que roda no lugar do worker

`netlify/functions/agenda.mts` chama `/api/agenda` de minuto em minuto com o
`AGENDA_TOKEN`. E essa rota que publica o que venceu, marca `POST_SEM_RESPOSTA`
e manda lembrete. Tudo idempotente: rodar de novo nao duplica nada.

## Antes de ligar na Meta de verdade

1. Trocar a `ENCRYPTION_KEY` por uma definitiva e guardada (trocar invalida os
   links de aprovacao em aberto).
2. `META_DRY_RUN=false` so depois do App Review e das contas conectadas.
3. `WHATSAPP_MODE=cloud_api` so depois dos templates aprovados.
