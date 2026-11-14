import 'dart:io';

import 'package:dayflow/data/task_repository.dart';
import 'package:dayflow/models/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory directory;
  late TaskRepository repository;

  setUpAll(sqfliteFfiInit);
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('dayflow_test_');
    repository = TaskRepository(
      factory: databaseFactoryFfiNoIsolate,
      databasePath: p.join(directory.path, 'dayflow.db'),
    );
  });
  tearDown(() async {
    await repository.close();
    await directory.delete(recursive: true);
  });

  test('cria os quatro exemplos e não duplica ao reabrir o banco', () async {
    expect(await repository.getAll(), hasLength(4));
    await repository.close();
    expect(await repository.getAll(), hasLength(4));
  });

  test('cria, atualiza e preserva dados em uma nova conexão', () async {
    final created = await repository.save(
      Task(
        title: 'Entregar projeto',
        description: 'Demonstração da persistência SQLite.',
        dueDate: DateTime(2026, 11, 20),
        priority: TaskPriority.high,
      ),
    );
    expect(created.id, isNotNull);
    await repository.save(
      created.copyWith(title: 'Projeto entregue', completed: true),
    );
    await repository.close();

    final reopened = TaskRepository(
      factory: databaseFactoryFfiNoIsolate,
      databasePath: repository.databasePath,
    );
    try {
      final saved = (await reopened.getAll()).singleWhere(
        (task) => task.id == created.id,
      );
      expect(saved.title, 'Projeto entregue');
      expect(saved.description, created.description);
      expect(saved.dueDate, DateTime(2026, 11, 20));
      expect(saved.priority, TaskPriority.high);
      expect(saved.completed, isTrue);
    } finally {
      await reopened.close();
    }
  });

  test('excluir todas as tarefas mantém o banco vazio após reinício', () async {
    for (final task in await repository.getAll()) {
      await repository.delete(task.id!);
    }
    await repository.close();
    expect(await repository.getAll(), isEmpty);
  });

  test('rejeita título vazio e alteração de registro inexistente', () async {
    final task = Task(
      title: ' ',
      description: '',
      dueDate: DateTime(2026, 11, 20),
    );
    await expectLater(repository.save(task), throwsArgumentError);
    await expectLater(
      repository.save(task.copyWith(id: 999, title: 'Teste')),
      throwsStateError,
    );
    await expectLater(repository.delete(999), throwsStateError);
  });
}
