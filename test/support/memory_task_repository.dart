import 'package:dayflow/data/demo_tasks.dart';
import 'package:dayflow/data/task_repository.dart';
import 'package:dayflow/models/task.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Isola os testes de interface; os testes do repositório usam SQLite real.
class MemoryTaskRepository extends TaskRepository {
  MemoryTaskRepository({bool empty = false})
    : super(factory: databaseFactoryFfiNoIsolate, databasePath: ':memory:') {
    if (!empty) {
      _tasks = [for (final task in demoTasks) task.copyWith(id: _nextId++)];
    }
  }

  List<Task> _tasks = [];
  int _nextId = 1;
  bool failWrites = false;
  bool failReads = false;

  @override
  Future<List<Task>> getAll() async {
    if (failReads) throw StateError('Falha simulada de leitura.');
    return [..._tasks];
  }

  @override
  Future<Task> save(Task task) async {
    if (failWrites) throw StateError('Falha simulada de escrita.');
    final saved = task.copyWith(id: task.id ?? _nextId++);
    final index = _tasks.indexWhere((item) => item.id == saved.id);
    if (index < 0) {
      _tasks.add(saved);
    } else {
      _tasks[index] = saved;
    }
    return saved;
  }

  @override
  Future<void> delete(int id) async {
    if (failWrites) throw StateError('Falha simulada de escrita.');
    _tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<void> close() async {}
}
