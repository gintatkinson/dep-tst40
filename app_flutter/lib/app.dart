import 'package:flutter/material.dart';
import 'data/reference_frame_repository.dart';
import 'domain/feature_flags.dart';
import 'domain/reference_frame_validator.dart';
import 'features/reference_frame/reference_frame_form.dart';
import 'features/reference_frame/reference_frame_viewmodel.dart';

class PipelineApp extends StatelessWidget {
  final ReferenceFrameRepository repository;
  final FeatureFlags featureFlags;

  const PipelineApp({
    super.key,
    required this.repository,
    this.featureFlags = const FeatureFlags(),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pipeline App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    final viewModel = ReferenceFrameViewModel(
      repository: repository,
      validator: const ReferenceFrameValidator(),
      featureFlags: featureFlags,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reference Frame Configuration'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: ReferenceFrameForm(viewModel: viewModel),
          ),
        ),
      ),
    );
  }
}
