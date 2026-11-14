import 'package:sqflite/sqflite.dart';

import '../models/task.dart';
import 'demo_tasks.dart';

/// Toda leitura e escrita de tarefas passa por esta classe.
class TaskRepository {
  TaskRepository({
    required this.factory,
    required this.databasePath,
    this.seedDemoTasks = true,
  });

  final DatabaseFactory factory;
  final String databasePath;
  final bool seedDemoTasks;
  Future<Database>? _opening;

  Future<Database> _database() async {
    try {
      return await (_opening ??= factory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL CHECK(length(trim(title)) > 0),
                description TEXT NOT NULL DEFAULT '',
                due_date TEXT NOT NULL,
                priority TEXT NOT NULL CHECK(priority IN ('low', 'medium', 'high')),
                completed INTEGER NOT NULL DEFAULT 0 CHECK(completed IN (0, 1))
              )
            ''');
            if (seedDemoTasks) {
              final batch = db.batch();
              for (final task in demoTasks) {
                batch.insert('tasks', task.toMap());
              }
              await batch.commit(noResult: true);
            }
          },
        ),
      ));
    } catch (_) {
      // Uma nova tentativa poderá abrir o banco após uma falha de inicialização.
      _opening = null;
      rethrow;
    }
  }

  Future<List<Task>> getAll() async {
    final db = await _database();
    final rows = await db.query('tasks', orderBy: 'id ASC');
    return rows.map(Task.fromMap).toList();
  }

  Future<Task> save(Task task) async {
    if (task.title.trim().isEmpty) {
      throw ArgumentError('O título é obrigatório.');
    }
    final db = await _database();
    if (task.id == null) {
      final id = await db.insert('tasks', task.toMap());
      return task.copyWith(id: id);
    }
    final values = task.toMap()..remove('id');
    final updated = await db.update(
      'tasks',
      values,
      where: 'id = ?',
      whereArgs: [task.id],
    );
    if (updated != 1) throw StateError('Tarefa não encontrada.');
    return task;
  }

  Future<void> delete(int id) async {
    final db = await _database();
    final deleted = await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    if (deleted != 1) throw StateError('Tarefa não encontrada.');
  }

  Future<void> close() async {
    final opening = _opening;
    if (opening != null) await (await opening).close();
    _opening = null;
  }
}
