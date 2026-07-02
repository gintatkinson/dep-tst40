import 'package:flutter/foundation.dart';
import '../../data/reference_frame_repository.dart';
import '../../domain/feature_flags.dart';
import '../../domain/reference_frame.dart';
import '../../domain/reference_frame_validator.dart';
import '../../domain/validation_result.dart';

class ReferenceFrameViewModel extends ChangeNotifier {
  final ReferenceFrameRepository _repository;
  final ReferenceFrameValidator _validator;
  final FeatureFlags _featureFlags;

  String _astronomicalBody = 'earth';
  String? _alternateSystem;
  List<ValidationError> _errors = [];
  bool _isValid = true;

  ReferenceFrameViewModel({
    required ReferenceFrameRepository repository,
    required ReferenceFrameValidator validator,
    required FeatureFlags featureFlags,
  })  : _repository = repository,
        _validator = validator,
        _featureFlags = featureFlags;

  String get astronomicalBody => _astronomicalBody;
  String? get alternateSystem => _alternateSystem;
  List<ValidationError> get errors => List.unmodifiable(_errors);
  bool get isValid => _isValid;

  Future<void> load() async {
    final frame = await _repository.get();
    if (frame != null) {
      _astronomicalBody = frame.astronomicalBody;
      _alternateSystem = frame.alternateSystem;
      notifyListeners();
    }
  }

  void updateAstronomicalBody(String value) {
    _astronomicalBody = value;
    _validate();
    notifyListeners();
  }

  void updateAlternateSystem(String? value) {
    _alternateSystem = value;
    _validate();
    notifyListeners();
  }

  void clearAlternateSystem() {
    _alternateSystem = null;
    _validate();
    notifyListeners();
  }

  Future<void> save() async {
    if (!_isValid) {
      throw StateError('Cannot save: reference frame is invalid');
    }
    final frame = ReferenceFrame(
      astronomicalBody: _astronomicalBody,
      alternateSystem: _alternateSystem,
    );
    final normalized = _validator.normalize(frame);
    await _repository.save(normalized);
  }

  Future<void> delete() async {
    await _repository.delete();
    _astronomicalBody = 'earth';
    _alternateSystem = null;
    _errors = [];
    _isValid = true;
    notifyListeners();
  }

  void _validate() {
    final result = _validator.validate(
      ReferenceFrame(
        astronomicalBody: _astronomicalBody,
        alternateSystem: _alternateSystem,
      ),
      _featureFlags,
    );
    if (result is ValidationValid) {
      _errors = [];
      _isValid = true;
    } else if (result is ValidationInvalid) {
      _errors = result.errors;
      _isValid = false;
    }
  }
}
