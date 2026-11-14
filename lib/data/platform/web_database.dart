import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../task_repository.dart';

Future<TaskRepository> createTaskRepository() async =>
    TaskRepository(factory: databaseFactoryFfiWeb, databasePath: 'dayflow.db');
