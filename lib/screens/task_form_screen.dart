import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/task_widgets.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({required this.controller, this.task, super.key});
  final TaskController controller;
  final Task? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _date;
  late TaskPriority _priority;
  bool _saving = false;

  bool get _editing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    _date = TextEditingController(
      text: task == null ? '' : formatTaskDate(task.dueDate),
    );
    _priority = task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final selected = await showDatePicker(
      context: context,
      initialDate:
          parseTaskDate(_date.text) ?? DateUtils.dateOnly(DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Selecione a data da tarefa',
    );
    if (selected != null && mounted) _date.text = formatTaskDate(selected);
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final task = Task(
      id: widget.task?.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      dueDate: parseTaskDate(_date.text)!,
      priority: _priority,
      completed: widget.task?.completed ?? false,
    );
    final success = await widget.controller.save(task);
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      // Retorna ao início, como o fluxo do protótipo.
      Navigator.of(context).popUntil((route) => route.isFirst);
      showTaskMessage(
        context,
        _editing ? 'Tarefa atualizada.' : 'Tarefa criada.',
      );
    } else {
      showTaskMessage(
        context,
        widget.controller.error ?? 'Aguarde a operação atual.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_editing ? 'Editar Tarefa' : 'Nova Tarefa')),
    body: SafeArea(
      top: false,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 36),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            SectionKicker(_editing ? 'ATUALIZE OS DADOS' : 'ORGANIZE SEU DIA'),
            const SizedBox(height: 4),
            Text(
              _editing ? 'Edite sua tarefa' : 'O que precisa ser feito?',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 26),
            const _FieldLabel('Título'),
            TextFormField(
              key: const ValueKey('title-field'),
              controller: _title,
              enabled: !_saving,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Ex.: Revisar conteúdo da aula',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe o título da tarefa.'
                  : null,
            ),
            const SizedBox(height: 19),
            const _FieldLabel('Descrição'),
            TextFormField(
              key: const ValueKey('description-field'),
              controller: _description,
              enabled: !_saving,
              minLines: 4,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Adicione detalhes sobre a tarefa',
              ),
            ),
            const SizedBox(height: 19),
            const _FieldLabel('Data'),
            TextFormField(
              key: const ValueKey('date-field'),
              controller: _date,
              enabled: !_saving,
              keyboardType: TextInputType.datetime,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'DD/MM/AAAA',
                suffixIcon: IconButton(
                  tooltip: 'Escolher data no calendário',
                  onPressed: _saving ? null : _pickDate,
                  icon: const Icon(
                    Icons.event,
                    size: 20,
                    color: AppColors.muted,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a data da tarefa.';
                }
                if (parseTaskDate(value) == null) {
                  return 'Use uma data válida: DD/MM/AAAA.';
                }
                return null;
              },
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 19),
            const _FieldLabel('Prioridade'),
            Row(
              children: [
                for (final priority in TaskPriority.values) ...[
                  if (priority != TaskPriority.low) const SizedBox(width: 9),
                  Expanded(
                    child: Semantics(
                      selected: _priority == priority,
                      child: OutlinedButton(
                        key: ValueKey('priority-${priority.name}'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _priority == priority
                              ? AppColors.blue50
                              : Colors.white,
                          foregroundColor: _priority == priority
                              ? AppColors.blue
                              : AppColors.muted,
                          side: BorderSide(
                            color: _priority == priority
                                ? AppColors.blue
                                : AppColors.line,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _saving
                            ? null
                            : () => setState(() => _priority = priority),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PriorityDot(priority),
                            const SizedBox(width: 7),
                            Flexible(child: Text(priority.label)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              key: const ValueKey('save-task'),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, size: 20),
              label: Text(_saving ? 'Salvando...' : 'Salvar Tarefa'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
  );
}
