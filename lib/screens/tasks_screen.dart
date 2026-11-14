import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/task_widgets.dart';
import 'task_actions.dart';

enum TaskFilter {
  all('Todas'),
  pending('Pendentes'),
  completed('Concluídas');

  const TaskFilter(this.label);
  final String label;

  bool matches(Task task) => switch (this) {
    all => true,
    pending => !task.completed,
    completed => task.completed,
  };
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({required this.controller, super.key});
  final TaskController controller;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskFilter _filter = TaskFilter.all;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final tasks = controller.tasks.where(_filter.matches).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Minhas Tarefas')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 110),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDF3),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    for (final filter in TaskFilter.values)
                      Expanded(
                        child: Semantics(
                          selected: _filter == filter,
                          child: TextButton(
                            key: ValueKey('filter-${filter.name}'),
                            style: TextButton.styleFrom(
                              backgroundColor: _filter == filter
                                  ? Colors.white
                                  : null,
                              foregroundColor: _filter == filter
                                  ? AppColors.blue
                                  : AppColors.muted,
                              padding: const EdgeInsets.symmetric(
                                vertical: 11,
                                horizontal: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => setState(() => _filter = filter),
                            child: Text(
                              filter.label,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 21, 2, 12),
              child: Text(
                '${tasks.length} ${tasks.length == 1 ? 'tarefa' : 'tarefas'}',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (tasks.isEmpty) const TaskEmptyState(),
            for (final task in tasks)
              Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: TaskCard(
                  key: ValueKey('task-${task.id}'),
                  task: task,
                  enabled: !controller.busy,
                  onOpen: () => openTaskDetails(context, controller, task),
                  onToggle: () => toggleTask(context, controller, task),
                  onAction: (action) =>
                      handleTaskAction(context, controller, task, action),
                ),
              ),
          ],
        ),
        floatingActionButton: NewTaskButton(
          onPressed: controller.busy
              ? null
              : () => openTaskForm(context, controller),
        ),
      );
    },
  );
}
