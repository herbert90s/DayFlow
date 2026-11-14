import 'package:flutter/foundation.dart';

import '../data/task_repository.dart';
import '../models/task.dart';

class TaskController extends ChangeNotifier {
  TaskController(this.repository);

  final TaskRepository repository;
  List<Task> _tasks = [];
  bool loading = true;
  bool loadFailed = false;
  bool busy = false;
  String? error;

  List<Task> get tasks => List.unmodifiable(_tasks);
  int get pendingCount => _tasks.where((task) => !task.completed).length;
  int get completedCount => _tasks.where((task) => task.completed).length;

  Task? find(int id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> load() async {
    loading = true;
    loadFailed = false;
    error = null;
    notifyListeners();
    try {
      _tasks = await repository.getAll();
    } catch (_) {
      loadFailed = true;
      error = 'Não foi possível carregar as tarefas. Tente novamente.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> save(Task task) => _mutate(() async {
    final saved = await repository.save(task);
    final index = _tasks.indexWhere((item) => item.id == saved.id);
    if (index < 0) {
      _tasks = [..._tasks, saved];
    } else {
      _tasks = [..._tasks]..[index] = saved;
    }
  });

  Future<bool> toggle(Task task) =>
      save(task.copyWith(completed: !task.completed));

  Future<bool> delete(Task task) => _mutate(() async {
    await repository.delete(task.id!);
    _tasks = _tasks.where((item) => item.id != task.id).toList();
  });

  Future<bool> _mutate(Future<void> Function() action) async {
    if (busy || loading) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (_) {
      error = 'Não foi possível salvar a alteração. Tente novamente.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
