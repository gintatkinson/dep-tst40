import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipeline_app/data/reference_frame_repository.dart';
import 'package:pipeline_app/domain/feature_flags.dart';
import 'package:pipeline_app/domain/reference_frame.dart';
import 'package:pipeline_app/domain/reference_frame_validator.dart';
import 'package:pipeline_app/features/reference_frame/reference_frame_form.dart';
import 'package:pipeline_app/features/reference_frame/reference_frame_viewmodel.dart';

class _FakeRepo implements ReferenceFrameRepository {
  ReferenceFrame? _frame;
  @override
  Future<ReferenceFrame?> get() async => _frame;
  @override
  Future<void> save(ReferenceFrame frame) async => _frame = frame;
  @override
  Future<void> delete() async => _frame = null;
  @override
  Future<bool> exists() async => _frame != null;
  @override
  Stream<ReferenceFrame?> watch() => Stream.value(_frame);
}

Widget createTestApp(ReferenceFrameViewModel vm) {
  return MaterialApp(
    home: Scaffold(body: ReferenceFrameForm(viewModel: vm)),
  );
}

void main() {
  testWidgets('ReferenceFrameForm renders astronomical body field', (tester) async {
    final vm = ReferenceFrameViewModel(
      repository: _FakeRepo(),
      validator: const ReferenceFrameValidator(),
      featureFlags: const FeatureFlags(),
    );

    await tester.pumpWidget(createTestApp(vm));

    expect(find.text('Astronomical Body'), findsOneWidget);
    expect(find.text('Alternate System'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('ReferenceFrameForm shows validation error on invalid input', (tester) async {
    final vm = ReferenceFrameViewModel(
      repository: _FakeRepo(),
      validator: const ReferenceFrameValidator(),
      featureFlags: const FeatureFlags(),
    );

    await tester.pumpWidget(createTestApp(vm));
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();

    expect(find.text('astronomical-body is required'), findsOneWidget);
  });

  testWidgets('Save button disabled when invalid', (tester) async {
    final vm = ReferenceFrameViewModel(
      repository: _FakeRepo(),
      validator: const ReferenceFrameValidator(),
      featureFlags: const FeatureFlags(),
    );

    await tester.pumpWidget(createTestApp(vm));
    await tester.enterText(find.byType(TextField).first, '\x00');
    await tester.pump();

    final saveButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));
    expect(saveButton.onPressed, isNull);
  });
}
