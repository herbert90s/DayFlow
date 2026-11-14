import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/task_widgets.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';

Future<void> openTaskForm(
  BuildContext context,
  TaskController controller, {
  Task? task,
}) => Navigator.of(context).push<void>(
  MaterialPageRoute(
    builder: (_) => TaskFormScreen(controller: controller, task: task),
  ),
);

Future<void> openTaskDetails(
  BuildContext context,
  TaskController controller,
  Task task,
) => Navigator.of(context).push<void>(
  MaterialPageRoute(
    builder: (_) => TaskDetailsScreen(controller: controller, taskId: task.id!),
  ),
);

Future<void> toggleTask(
  BuildContext context,
  TaskController controller,
  Task task,
) async {
  final success = await controller.toggle(task);
  if (!success && context.mounted) {
    showTaskMessage(context, controller.error ?? 'Aguarde a operação atual.');
  }
}

Future<bool> confirmTaskDeletion(
  BuildContext context,
  TaskController controller,
  Task task,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Excluir tarefa?'),
      content: Text('A tarefa “${task.title}” será excluída.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.red),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;
  final success = await controller.delete(task);
  if (!success && context.mounted) {
    showTaskMessage(context, controller.error ?? 'Aguarde a operação atual.');
  }
  return success;
}

Future<void> handleTaskAction(
  BuildContext context,
  TaskController controller,
  Task task,
  TaskCardAction action,
) async {
  switch (action) {
    case TaskCardAction.details:
      await openTaskDetails(context, controller, task);
    case TaskCardAction.edit:
      await openTaskForm(context, controller, task: task);
    case TaskCardAction.toggle:
      await toggleTask(context, controller, task);
    case TaskCardAction.delete:
      await confirmTaskDeletion(context, controller, task);
  }
}
