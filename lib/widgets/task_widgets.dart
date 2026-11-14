import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';

class SectionKicker extends StatelessWidget {
  const SectionKicker(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.blue,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.3,
    ),
  );
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge(this.priority, {super.key});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.priorityBackground(priority),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PriorityDot(priority),
        const SizedBox(width: 6),
        Text(
          priority.label,
          style: TextStyle(
            color: AppColors.priority(priority),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class PriorityDot extends StatelessWidget {
  const PriorityDot(this.priority, {super.key});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) => Container(
    width: 7,
    height: 7,
    decoration: BoxDecoration(
      color: AppColors.priority(priority),
      shape: BoxShape.circle,
    ),
  );
}

class TaskCheckBox extends StatelessWidget {
  const TaskCheckBox({
    required this.checked,
    required this.onChanged,
    super.key,
  });
  final bool checked;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: checked,
    button: true,
    label: checked ? 'Marcar como pendente' : 'Marcar como concluída',
    child: InkResponse(
      onTap: onChanged,
      radius: 24,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 23,
            height: 23,
            decoration: BoxDecoration(
              color: checked ? AppColors.blue : Colors.white,
              border: Border.all(
                color: checked ? AppColors.blue : const Color(0xFFB8C2D0),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: checked
                ? const Icon(Icons.check, size: 17, color: Colors.white)
                : null,
          ),
        ),
      ),
    ),
  );
}

enum TaskCardAction { details, edit, toggle, delete }

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onOpen,
    required this.onToggle,
    required this.onAction,
    this.enabled = true,
    super.key,
  });
  final Task task;
  final VoidCallback onOpen;
  final VoidCallback onToggle;
  final ValueChanged<TaskCardAction> onAction;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.line.withValues(alpha: 0.8)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12172B4D),
          blurRadius: 24,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onOpen : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(7, 14, 6, 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskCheckBox(
                key: ValueKey('toggle-${task.id}'),
                checked: task.completed,
                onChanged: enabled ? onToggle : null,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: task.completed
                              ? AppColors.muted
                              : AppColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 11),
                      Wrap(
                        spacing: 9,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.event,
                                size: 16,
                                color: AppColors.muted,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                formatTaskDate(task.dueDate),
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          PriorityBadge(task.priority),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 34,
                height: 34,
                child: PopupMenuButton<TaskCardAction>(
                  tooltip: 'Opções da tarefa',
                  enabled: enabled,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, color: AppColors.muted),
                  onSelected: onAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: TaskCardAction.details,
                      child: Text('Ver detalhes'),
                    ),
                    const PopupMenuItem(
                      value: TaskCardAction.edit,
                      child: Text('Editar'),
                    ),
                    PopupMenuItem(
                      value: TaskCardAction.toggle,
                      child: Text(
                        task.completed ? 'Marcar como pendente' : 'Concluir',
                      ),
                    ),
                    const PopupMenuItem(
                      value: TaskCardAction.delete,
                      child: Text(
                        'Excluir',
                        style: TextStyle(color: AppColors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class TaskEmptyState extends StatelessWidget {
  const TaskEmptyState({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 12),
    child: Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.blue100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.assignment, color: AppColors.blue),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nenhuma tarefa por aqui',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        const Text(
          'Altere o filtro ou adicione uma nova tarefa.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      ],
    ),
  );
}

class NewTaskButton extends StatelessWidget {
  const NewTaskButton({required this.onPressed, super.key});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 58,
    height: 58,
    child: FloatingActionButton(
      tooltip: 'Nova tarefa',
      onPressed: onPressed,
      child: const Icon(Icons.add, size: 26),
    ),
  );
}

void showTaskMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
