import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../task_repository.dart';

Future<TaskRepository> createTaskRepository() async => TaskRepository(
  factory: databaseFactory,
  databasePath: p.join(await getDatabasesPath(), 'dayflow.db'),
);
