import 'package:flutter_test/flutter_test.dart';
import 'package:pipeline_app/data/reference_frame_repository.dart';
import 'package:pipeline_app/domain/feature_flags.dart';
import 'package:pipeline_app/domain/reference_frame.dart';
import 'package:pipeline_app/domain/reference_frame_validator.dart';
import 'package:pipeline_app/domain/validation_result.dart';
import 'package:pipeline_app/features/reference_frame/reference_frame_viewmodel.dart';

class FakeReferenceFrameRepository implements ReferenceFrameRepository {
  ReferenceFrame? _frame;

  @override
  Future<ReferenceFrame?> get() async => _frame;

  @override
  Future<void> save(ReferenceFrame frame) async {
    _frame = frame;
  }

  @override
  Future<void> delete() async {
    _frame = null;
  }

  @override
  Future<bool> exists() async => _frame != null;

  @override
  Stream<ReferenceFrame?> watch() {
    return Stream.value(_frame);
  }
}

void main() {
  group('ReferenceFrameViewModel', () {
    late FakeReferenceFrameRepository repository;
    late ReferenceFrameViewModel viewModel;

    setUp(() {
      repository = FakeReferenceFrameRepository();
      viewModel = ReferenceFrameViewModel(
        repository: repository,
        validator: const ReferenceFrameValidator(),
        featureFlags: const FeatureFlags(),
      );
    });

    test('initial state has default values and is valid', () {
      expect(viewModel.astronomicalBody, 'earth');
      expect(viewModel.alternateSystem, isNull);
      expect(viewModel.isValid, isTrue);
      expect(viewModel.errors, isEmpty);
    });

    test('load populates fields from repository', () async {
      await repository.save(
        ReferenceFrame(astronomicalBody: 'mars', alternateSystem: 'holodeck'),
      );

      await viewModel.load();

      expect(viewModel.astronomicalBody, 'mars');
      expect(viewModel.alternateSystem, 'holodeck');
    });

    test('load with null repository result keeps defaults', () async {
      await viewModel.load();

      expect(viewModel.astronomicalBody, 'earth');
    });

    test('updateAstronomicalBody updates field and re-validates', () {
      viewModel.updateAstronomicalBody('mars');
      expect(viewModel.astronomicalBody, 'mars');
      expect(viewModel.isValid, isTrue);
    });

    test('updateAstronomicalBody with control character sets invalid', () {
      viewModel.updateAstronomicalBody('test\x07');
      expect(viewModel.isValid, isFalse);
      expect(viewModel.errors, isNotEmpty);
    });

    test('updateAstronomicalBody with empty string sets invalid', () {
      viewModel.updateAstronomicalBody('');
      expect(viewModel.isValid, isFalse);
    });

    test('updateAlternateSystem updates field', () {
      viewModel.updateAlternateSystem('stargate-grid');

      expect(viewModel.alternateSystem, 'stargate-grid');
    });

    test('save persists through repository', () async {
      viewModel.updateAstronomicalBody('titan');
      await viewModel.save();

      final rf = await repository.get();
      expect(rf!.astronomicalBody, 'titan');
    });

    test('save normalizes before persisting', () async {
      viewModel.updateAstronomicalBody('Earth');
      await viewModel.save();

      final rf = await repository.get();
      expect(rf!.astronomicalBody, 'earth');
    });

    test('save fails when invalid', () async {
      viewModel.updateAstronomicalBody('\x00');

      expect(() => viewModel.save(), throwsA(isA<StateError>()));
    });

    test('delete removes from repository', () async {
      await repository.save(ReferenceFrame(astronomicalBody: 'ceres'));
      await viewModel.load();
      await viewModel.delete();

      final exists = await repository.exists();
      expect(exists, isFalse);
    });

    test('clearAlternateSystem sets it to null', () {
      viewModel.updateAlternateSystem('test-sys');
      viewModel.clearAlternateSystem();

      expect(viewModel.alternateSystem, isNull);
    });

    test('alternateSystem rejected when feature flag disabled', () {
      viewModel.updateAlternateSystem('test');

      expect(viewModel.isValid, isFalse);
      expect(viewModel.errors.any((e) => e.type == ValidationErrorType.alternateSystemDisabled), isTrue);
    });

    test('alternateSystem accepted when feature flag enabled', () {
      final vm = ReferenceFrameViewModel(
        repository: repository,
        validator: const ReferenceFrameValidator(),
        featureFlags: const FeatureFlags(alternateSystemsEnabled: true),
      );
      vm.updateAlternateSystem('test');

      expect(vm.isValid, isTrue);
    });
  });
}
