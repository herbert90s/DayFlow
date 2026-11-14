import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/task_controller.dart';
import 'data/database.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class DayFlowApp extends StatefulWidget {
  const DayFlowApp({this.controller, super.key});

  /// Injetado nos testes; no aplicativo real, o SQLite é aberto automaticamente.
  final TaskController? controller;

  @override
  State<DayFlowApp> createState() => _DayFlowAppState();
}

class _DayFlowAppState extends State<DayFlowApp> {
  late Future<TaskController> _initialization;
  TaskController? _ownedController;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<TaskController> _initialize() async {
    if (widget.controller != null) return widget.controller!;
    final repository = await createTaskRepository();
    final controller = TaskController(repository);
    await controller.load();
    if (!mounted) {
      controller.dispose();
      await repository.close();
      throw StateError('Aplicativo encerrado durante a inicialização.');
    }
    _ownedController = controller;
    return controller;
  }

  @override
  void dispose() {
    final controller = _ownedController;
    if (controller != null) {
      controller.dispose();
      unawaited(controller.repository.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DayFlow',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    builder: (context, child) => ColoredBox(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ClipRect(child: child!),
        ),
      ),
    ),
    home: FutureBuilder<TaskController>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                      color: AppColors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Não foi possível iniciar o DayFlow.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          setState(() => _initialization = _initialize()),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return HomeScreen(controller: snapshot.data!);
      },
    ),
  );
}
