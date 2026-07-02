import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'data/reference_frame_repository.dart';
import 'features/layout/console_shell.dart';

class PipelineApp extends StatelessWidget {
  final ReferenceFrameRepository repository;
  final AppTheme themeController;

  const PipelineApp({
    super.key,
    required this.repository,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final consoleVm = ConsoleViewModel(repository: repository);

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Systems Console',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeController.mode,
          home: ConsoleShell(
            viewModel: consoleVm,
            themeController: themeController,
          ),
        );
      },
    );
  }
}
