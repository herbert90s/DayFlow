enum TaskPriority {
  low('Baixa'),
  medium('Média'),
  high('Alta');

  const TaskPriority(this.label);
  final String label;
}

/// Uma tarefa. O id é atribuído pelo SQLite ao inserir o registro.
class Task {
  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.completed = false,
  });

  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool completed;

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? completed,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate ?? this.dueDate,
    priority: priority ?? this.priority,
    completed: completed ?? this.completed,
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    // Data civil, sem fuso horário: o dia não muda entre dispositivos.
    'due_date':
        '${dueDate.year.toString().padLeft(4, '0')}-'
        '${dueDate.month.toString().padLeft(2, '0')}-'
        '${dueDate.day.toString().padLeft(2, '0')}',
    'priority': priority.name,
    'completed': completed ? 1 : 0,
  };

  factory Task.fromMap(Map<String, Object?> map) => Task(
    id: map['id'] as int,
    title: map['title'] as String,
    description: map['description'] as String,
    dueDate: DateTime.parse(map['due_date'] as String),
    priority: TaskPriority.values.byName(map['priority'] as String),
    completed: map['completed'] == 1,
  );
}

String formatTaskDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year.toString().padLeft(4, '0')}';

/// DateTime normaliza 31/02 para março; a comparação impede essa aceitação.
DateTime? parseTaskDate(String value) {
  final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value.trim());
  if (match == null) return null;
  final day = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final year = int.parse(match[3]!);
  if (year < 1900 || year > 2100) return null;
  final date = DateTime(year, month, day);
  return date.day == day && date.month == month && date.year == year
      ? date
      : null;
}
