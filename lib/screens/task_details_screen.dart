import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/task_widgets.dart';
import 'task_actions.dart';

class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({
    required this.controller,
    required this.taskId,
    super.key,
  });
  final TaskController controller;
  final int taskId;

  Future<void> _delete(BuildContext context, Task task) async {
    final deleted = await confirmTaskDeletion(context, controller, task);
    if (deleted && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      showTaskMessage(context, 'Tarefa excluída.');
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final task = controller.find(taskId);
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Tarefa')),
        body: task == null
            ? const Center(child: Text('Tarefa não encontrada.'))
            : SafeArea(
                top: false,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 29, 20, 36),
                  children: [
                    const SectionKicker('TAREFA'),
                    const SizedBox(height: 4),
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: task.completed
                              ? AppColors.greenSoft
                              : AppColors.amberSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          task.completed ? 'Concluída' : 'Pendente',
                          style: TextStyle(
                            color: task.completed
                                ? AppColors.green
                                : AppColors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 23),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'Data',
                            child: Text(formatTaskDate(task.dueDate)),
                          ),
                          const Divider(),
                          _DetailRow(
                            label: 'Prioridade',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PriorityDot(task.priority),
                                const SizedBox(width: 7),
                                Text(task.priority.label),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Descrição',
                                  style: _detailLabelStyle,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  task.description.isEmpty
                                      ? 'Nenhuma descrição adicionada.'
                                      : task.description,
                                  style: const TextStyle(
                                    color: Color(0xFF455268),
                                    height: 1.55,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Material(
                      color: AppColors.blue50,
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: controller.busy
                            ? null
                            : () => toggleTask(context, controller, task),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 9,
                          ),
                          child: Row(
                            children: [
                              TaskCheckBox(
                                checked: task.completed,
                                onChanged: controller.busy
                                    ? null
                                    : () =>
                                          toggleTask(context, controller, task),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  task.completed
                                      ? 'Tarefa concluída'
                                      : 'Marcar como concluída',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.busy
                                ? null
                                : () => openTaskForm(
                                    context,
                                    controller,
                                    task: task,
                                  ),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Editar'),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              foregroundColor: AppColors.red,
                              backgroundColor: AppColors.redSoft,
                              minimumSize: const Size(0, 48),
                            ),
                            onPressed: controller.busy
                                ? null
                                : () => _delete(context, task),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Excluir'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      );
    },
  );
}

const _detailLabelStyle = TextStyle(
  color: AppColors.muted,
  fontSize: 12,
  fontWeight: FontWeight.w700,
);

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Text(label, style: _detailLabelStyle),
        const SizedBox(width: 20),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              child: child,
            ),
          ),
        ),
      ],
    ),
  );
}
