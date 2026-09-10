# Gestão Simples

Aplicativo Flutter offline-first criado como protótipo acadêmico para apoiar
microempreendedores locais na organização de clientes, serviços e
agendamentos.

## Tecnologias

- Flutter e Dart
- Material 3
- Hive e Hive Flutter para persistência local
- Formatação de datas e valores no padrão brasileiro

Não há login, Firebase, backend ou dependência de internet. Os dados ficam
salvos somente no aparelho.

## Funcionalidades

- Dashboard com totais e próximos atendimentos
- Cadastro, edição, detalhes e exclusão de clientes
- Cadastro, edição e exclusão de serviços
- Agenda com filtro por data e organização por status
- Criação e edição de agendamentos
- Ações para concluir, cancelar ou excluir um agendamento
- Limpeza completa dos dados locais mediante confirmação

## Como rodar

1. Tenha o Flutter configurado com suporte ao Android.
2. Na raiz do projeto, execute `flutter pub get`.
3. Conecte um aparelho ou abra um emulador.
4. Execute `flutter run`.

O aplicativo inicia vazio e abre diretamente na tela principal.
