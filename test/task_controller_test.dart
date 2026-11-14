import 'package:dayflow/controllers/task_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_task_repository.dart';

void main() {
  test(
    'uma falha de gravação preserva o estado e permite tentar novamente',
    () async {
      final repository = MemoryTaskRepository();
      final controller = TaskController(repository);
      addTearDown(controller.dispose);
      await controller.load();
      final task = controller.tasks.first;
      repository.failWrites = true;
      expect(await controller.toggle(task), isFalse);
      expect(controller.tasks.first.completed, isFalse);
      expect(controller.busy, isFalse);
      expect(controller.error, isNotNull);
      repository.failWrites = false;
      expect(await controller.toggle(task), isTrue);
      expect(controller.tasks.first.completed, isTrue);
      expect(controller.error, isNull);
    },
  );

  test(
    'uma falha de leitura pode ser recuperada sem reiniciar o app',
    () async {
      final repository = MemoryTaskRepository()..failReads = true;
      final controller = TaskController(repository);
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.loadFailed, isTrue);
      expect(controller.loading, isFalse);
      repository.failReads = false;
      await controller.load();
      expect(controller.loadFailed, isFalse);
      expect(controller.tasks, hasLength(4));
    },
  );
}
