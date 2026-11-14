# DayFlow — Flutter / Dart

Aplicativo de organização de tarefas convertido do projeto `DayFlow-main.zip`, exportado pelo Figma Make. A interface foi reimplementada com widgets Flutter, preservando as cores, os textos, os cartões e os quatro fluxos do protótipo.

## O que está pronto

- Início com resumo de pendentes/concluídas e as quatro primeiras tarefas.
- Lista completa com filtros Todas, Pendentes e Concluídas.
- Cadastro e edição com título, descrição, data e prioridade.
- Detalhes, conclusão/reabertura e exclusão com confirmação.
- Menu de opções funcional nos cartões.
- Validação do título e de datas reais no formato DD/MM/AAAA.
- Calendário em português do Brasil.
- Banco de dados SQLite local: as tarefas permanecem salvas ao fechar o app.
- Ícone DayFlow e layout adaptado para celular.

Os quatro exemplos do Figma são inseridos **apenas na criação do banco**. Depois de excluídos, eles não voltam ao reabrir o aplicativo. As datas originais dos exemplos foram mantidas. O rótulo “HOJE” do início também foi mantido; a lista do início mostra as primeiras quatro tarefas cadastradas, sem filtrar pela data, conforme o protótipo.

## Requisitos

- Flutter **3.47.0 ou superior** e Dart **3.13.0 ou superior**. Ambiente usado na conversão: Flutter 3.47.4 / Dart 3.13.3.
- Android Studio com Android SDK e emulador, ou celular Android com depuração USB, para execução no Android.
- Google Chrome para execução alternativa no navegador.
- Internet na primeira instalação das dependências. Depois de instalado no Android, o gerenciamento de tarefas funciona sem conexão.

## Abrir e executar no Windows

1. Extraia o ZIP e abra a pasta **DayFlow_Flutter**, que contém o arquivo `pubspec.yaml`, no VS Code ou Android Studio.
2. Abra o terminal nessa pasta e execute:

```powershell
flutter pub get
flutter devices
```

3. Inicie um emulador Android ou conecte seu celular e execute:

```powershell
flutter run
```

Se houver vários dispositivos, o Flutter permitirá escolher. Também é possível informar o identificador listado por `flutter devices` usando `flutter run -d IDENTIFICADOR`.

Para apresentar no Chrome, sem depender de um emulador:

```powershell
flutter run -d chrome --web-port 8080
```

Os arquivos do SQLite Web (`web/sqlite3.wasm` e `web/sqflite_sw.js`) já acompanham o projeto. No navegador, os dados ficam no armazenamento local daquele navegador e endereço. Use sempre a mesma porta; limpar os dados do site apaga as tarefas. Os dados do Chrome e do Android são independentes.

## Gerar o APK para demonstração

Com o Android SDK configurado:

```powershell
flutter build apk --debug
```

O instalador será gerado em `build/app/outputs/flutter-apk/app-debug.apk`. É um APK de desenvolvimento para demonstração acadêmica. O pacote entregue contém o código-fonte; não inclui um APK pré-compilado.

## Organização do código

| Arquivo / pasta | Responsabilidade |
| --- | --- |
| `lib/main.dart` | Inicia o aplicativo. |
| `lib/app.dart` | Configura tema, idioma e inicialização do banco. |
| `lib/models/task.dart` | Modelo da tarefa, prioridades e validação de datas. |
| `lib/data/task_repository.dart` | Cria a tabela SQLite e executa inserção, consulta, atualização e exclusão. |
| `lib/data/demo_tasks.dart` | Exemplos do protótipo para a primeira abertura. |
| `lib/data/platform/` | Seleciona o SQLite nativo ou a implementação para navegador. |
| `lib/controllers/task_controller.dart` | Mantém as tarefas em memória e atualiza a interface após gravar no banco. |
| `lib/screens/` | Início, lista, formulário, detalhes e navegação. |
| `lib/widgets/task_widgets.dart` | Cartões, checkbox, prioridades e estado vazio. |
| `lib/theme/app_theme.dart` | Cores e estilos correspondentes ao projeto original. |
| `test/` | Testes do banco, da validação, do controlador e dos fluxos da interface. |

O fluxo é: a tela recebe a ação → o controlador solicita a gravação → o repositório grava no SQLite → o controlador notifica as telas. A interface só confirma a alteração após a gravação concluir. Não há servidor ou conta de usuário.

## Banco local

O banco `dayflow.db` possui uma tabela `tasks`:

| Coluna | Conteúdo |
| --- | --- |
| `id` | Identificador inteiro, gerado pelo SQLite. |
| `title` | Título obrigatório. |
| `description` | Descrição opcional, armazenada como texto. |
| `due_date` | Data no formato AAAA-MM-DD, exibida como DD/MM/AAAA. |
| `priority` | `low`, `medium` ou `high`, exibidos como Baixa, Média e Alta. |
| `completed` | 0 para pendente e 1 para concluída. |

No Android/iOS, utiliza `sqflite`. No navegador, usa SQLite em WebAssembly com persistência em IndexedDB por meio de `sqflite_common_ffi_web`. A inclusão do banco local permite demonstrar Flutter com persistência de dados, além da reprodução das telas.

## Verificação

A conversão foi verificada com análise estática, 12 testes automatizados e compilação Web em modo release. As telas também foram renderizadas e revisadas em larguras de 390 e 320 pixels.

```powershell
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
```

Para regenerar os arquivos do SQLite Web após atualizar as dependências:

```powershell
dart run sqflite_common_ffi_web:setup --force
```

As pastas Android, iOS e Web foram geradas pelo Flutter. A compilação Android exige o Android SDK; a compilação iOS exige macOS/Xcode e a configuração de assinatura do próprio grupo. Não foram compilados instaladores Android/iOS nesta conversão.

## Roteiro curto para apresentação

1. Apresente o objetivo: organizar tarefas de forma simples e local.
2. Mostre os cartões e os totais de pendentes e concluídas.
3. Crie uma tarefa com título, data e prioridade; abra seus detalhes.
4. Conclua a tarefa e mostre o filtro de concluídas.
5. Edite os dados e demonstre a confirmação de exclusão.
6. Feche e reabra o app para mostrar que o SQLite preservou os dados.
7. Explique a separação entre tela, controlador, modelo e banco usando a tabela de arquivos acima.

## Referências técnicas

- Flutter e SQLite: https://docs.flutter.dev/cookbook/persistence/sqlite
- Plugin SQLite nativo: https://pub.dev/packages/sqflite
- Implementação SQLite Web: https://pub.dev/packages/sqflite_common_ffi_web
