import '../models/task.dart';

/// Os mesmos quatro exemplos do protótipo, inseridos só ao criar o banco.
List<Task> get demoTasks => [
  Task(
    title: 'Trabalho de Flutter',
    description:
        'Desenvolver as telas do aplicativo DayFlow e testar o funcionamento.',
    dueDate: DateTime(2026, 9, 25),
    priority: TaskPriority.high,
  ),
  Task(
    title: 'Estudar banco de dados',
    description: 'Revisar os conceitos de banco de dados local.',
    dueDate: DateTime(2026, 9, 26),
    completed: true,
  ),
  Task(
    title: 'Preparar apresentação',
    description: 'Organizar os slides para a apresentação do projeto.',
    dueDate: DateTime(2026, 9, 28),
    priority: TaskPriority.low,
  ),
  Task(
    title: 'Exercícios',
    description: 'Finalizar os exercícios da disciplina.',
    dueDate: DateTime(2026, 9, 30),
  ),
];
