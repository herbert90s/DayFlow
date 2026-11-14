import 'package:dayflow/app.dart';
import 'package:dayflow/controllers/task_controller.dart';
import 'package:dayflow/models/task.dart';
import 'package:dayflow/widgets/task_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_task_repository.dart';

void main() {
  late TaskController controller;

  setUp(() async {
    controller = TaskController(MemoryTaskRepository());
    await controller.load();
  });
  tearDown(() => controller.dispose());

  Future<void> start(
    WidgetTester tester, {
    Size size = const Size(430, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(DayFlowApp(controller: controller));
    await tester.pumpAndSettle();
  }

  Future<void> tapSave(WidgetTester tester) async {
    final button = find.byKey(const ValueKey('save-task'));
    await tester.scrollUntilVisible(
      button,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('cria uma tarefa, valida os campos e retorna ao início', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('DAYFLOW'), findsOneWidget);
    expect(find.byType(TaskCard), findsNWidgets(4));
    await tester.tap(find.byTooltip('Nova tarefa'));
    await tester.pumpAndSettle();
    await tapSave(tester);
    expect(find.text('Informe o título da tarefa.'), findsOneWidget);
    expect(find.text('Informe a data da tarefa.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('title-field')),
      'Entregar DayFlow',
    );
    await tester.enterText(
      find.byKey(const ValueKey('date-field')),
      '31/02/2026',
    );
    await tapSave(tester);
    expect(find.text('Use uma data válida: DD/MM/AAAA.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('date-field')),
      '20/11/2026',
    );
    await tester.tap(find.byKey(const ValueKey('priority-high')));
    await tapSave(tester);
    expect(find.text('DAYFLOW'), findsOneWidget);
    expect(controller.tasks, hasLength(5));
    expect(controller.tasks.last.title, 'Entregar DayFlow');
    expect(controller.tasks.last.priority, TaskPriority.high);
    await tester.tap(find.text('Ver todas'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Entregar DayFlow'), 180);
    expect(find.text('Entregar DayFlow'), findsOneWidget);
  });

  testWidgets('conclui, edita sem perder o status e confirma exclusão', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('Trabalho de Flutter'));
    await tester.pumpAndSettle();
    expect(find.text('Detalhes da Tarefa'), findsOneWidget);
    await tester.tap(find.byType(TaskCheckBox));
    await tester.pumpAndSettle();
    expect(find.text('Concluída'), findsOneWidget);
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('title-field')),
      'Flutter pronto',
    );
    await tapSave(tester);
    expect(controller.tasks.first.completed, isTrue);
    await tester.tap(find.text('Flutter pronto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(controller.tasks, hasLength(4));
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Excluir'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('DAYFLOW'), findsOneWidget);
    expect(controller.tasks, hasLength(3));
    expect(
      controller.tasks.any((task) => task.title == 'Flutter pronto'),
      isFalse,
    );
  });

  testWidgets('filtra tarefas e usa o menu de opções', (tester) async {
    await start(tester);
    await tester.tap(find.text('Ver todas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('filter-completed')));
    await tester.pumpAndSettle();
    expect(find.byType(TaskCard), findsOneWidget);
    expect(find.text('Estudar banco de dados'), findsOneWidget);
    await tester.tap(find.byTooltip('Opções da tarefa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marcar como pendente'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma tarefa por aqui'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('filter-pending')));
    await tester.pumpAndSettle();
    expect(find.byType(TaskCard), findsNWidgets(4));
  });

  testWidgets('abre o calendário em português', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('Nova tarefa'));
    await tester.pumpAndSettle();
    final calendar = find.byTooltip('Escolher data no calendário');
    await tester.ensureVisible(calendar);
    await tester.tap(calendar);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final input = tester.widget<TextFormField>(
      find.byKey(const ValueKey('date-field')),
    );
    expect(parseTaskDate(input.controller!.text), isNotNull);
  });

  testWidgets('mantém as telas utilizáveis em uma tela estreita', (
    tester,
  ) async {
    await start(tester, size: const Size(320, 640));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Nova tarefa'));
    await tester.pumpAndSettle();
    await tapSave(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver todas'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
