# FastLap

Aplicativo Flutter para organizacao e otimizacao de rotas de delivery.

Agora o app possui:
- alternancia global de tema claro/escuro (padrao: claro)
- autenticacao local com login e cadastro salvos no dispositivo
- rotas, veiculos, historico e relatorios salvos localmente no app

## Estrutura

- lib/app: configuracao principal do app
- lib/features/auth: feature de autenticacao (login)
- lib/shared/data/local_app_store.dart: armazenamento local persistente
- src/img: imagens e logos

## Rodar o projeto

1. Instale o Flutter SDK.
2. No terminal, execute:

   flutter pub get
   flutter run

## Autenticacao Local

Cadastro e login funcionam sem internet e sem backend.
Os dados de usuario (nome, nome de usuario, e-mail e senha) sao armazenados localmente no dispositivo.
Rotas, veiculos, historico e relatorios tambem ficam no armazenamento local do app, separados por usuario.

## Observacao

A tela de login usa a imagem em `src/img/logo.jpg`.
