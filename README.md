# FastLap

Aplicativo Flutter para organizacao e otimizacao de rotas de delivery.

Agora o app possui:
- alternancia global de tema claro/escuro (padrao: claro)
- autenticacao local com login e cadastro salvos no dispositivo

## Estrutura

- lib/app: configuracao principal do app
- lib/features/auth: feature de autenticacao (login)
- src/img: imagens e logos

## Rodar o projeto

1. Instale o Flutter SDK.
2. No terminal, execute:

   flutter pub get
   flutter run

## Autenticacao Local

Cadastro e login funcionam sem internet e sem backend.
Os dados de usuario (nome, nome de usuario, e-mail e senha) sao armazenados localmente no dispositivo.

## Observacao

A tela de login usa a imagem em `src/img/logo.jpg`.
