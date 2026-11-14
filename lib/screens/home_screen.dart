import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/task_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/task_widgets.dart';
import 'task_actions.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.controller, super.key});
  final TaskController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Column(
          children: [
            _HomeHeader(controller: controller),
            Expanded(child: _buildContent(context)),
          ],
        ),
        floatingActionButton: controller.loading || controller.loadFailed
            ? null
            : NewTaskButton(
                onPressed: controller.busy
                    ? null
                    : () => openTaskForm(context, controller),
              ),
      ),
    ),
  );

  Widget _buildContent(BuildContext context) {
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.loadFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: controller.load,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    final tasks = controller.tasks.take(4).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 110),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionKicker('HOJE'),
                  const SizedBox(height: 4),
                  Text(
                    'Minhas tarefas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => TasksScreen(controller: controller),
                ),
              ),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 17),
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
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.controller});
  final TaskController controller;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.blue700, AppColors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.check, color: AppColors.blue700),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAYFLOW',
                        style: TextStyle(
                          color: Color(0xC7FFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Suas tarefas. Seu ritmo.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 14,
              runSpacing: 8,
              children: [
                _SummaryCount(
                  count: controller.pendingCount,
                  label: controller.pendingCount == 1
                      ? 'pendente'
                      : 'pendentes',
                ),
                Container(width: 1, height: 16, color: const Color(0x4DFFFFFF)),
                _SummaryCount(
                  count: controller.completedCount,
                  label: controller.completedCount == 1
                      ? 'concluída'
                      : 'concluídas',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _SummaryCount extends StatelessWidget {
  const _SummaryCount({required this.count, required this.label});
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '$count ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextSpan(text: label),
      ],
    ),
    style: const TextStyle(color: Color(0xD9FFFFFF), fontSize: 13),
  );
}
