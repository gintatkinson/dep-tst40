import 'feature_flags.dart';
import 'reference_frame.dart';
import 'validation_result.dart';

class ReferenceFrameValidator {
  static const _allowedPattern = r'^[ -@A-Z\[-\^_-~]*$';
  static final _patternRegex = RegExp(_allowedPattern);

  const ReferenceFrameValidator();

  ValidationResult validate(ReferenceFrame frame, FeatureFlags flags) {
    final errors = <ValidationError>[];

    _validateAstronomicalBody(frame.astronomicalBody, errors);
    _validateAlternateSystem(frame.alternateSystem, flags, errors);

    if (errors.isEmpty) {
      return const ValidationValid();
    }
    return ValidationInvalid(errors);
  }

  void _validateAstronomicalBody(
    String body,
    List<ValidationError> errors,
  ) {
    if (body.isEmpty) {
      errors.add(
        const ValidationError(
          field: 'astronomicalBody',
          message: 'astronomical-body is required',
          type: ValidationErrorType.patternViolation,
        ),
      );
      return;
    }

    if (_containsControlCharacter(body)) {
      errors.add(
        const ValidationError(
          field: 'astronomicalBody',
          message: 'astronomical-body contains invalid control characters',
          type: ValidationErrorType.controlCharacter,
        ),
      );
    }

    if (_containsNonAscii(body)) {
      errors.add(
        const ValidationError(
          field: 'astronomicalBody',
          message:
              'astronomical-body violates pattern [ -@\\[-\\^_-~]*',
          type: ValidationErrorType.nonAsciiCharacter,
        ),
      );
    }

    if (!_patternRegex.hasMatch(body)) {
      errors.add(
        const ValidationError(
          field: 'astronomicalBody',
          message:
              'astronomical-body violates pattern [ -@\\[-\\^_-~]*',
          type: ValidationErrorType.patternViolation,
        ),
      );
    }
  }

  void _validateAlternateSystem(
    String? alternateSystem,
    FeatureFlags flags,
    List<ValidationError> errors,
  ) {
    if (alternateSystem != null && !flags.alternateSystemsEnabled) {
      errors.add(
        const ValidationError(
          field: 'alternateSystem',
          message: 'alternate-systems feature is not enabled',
          type: ValidationErrorType.alternateSystemDisabled,
        ),
      );
    }
  }

  bool _containsControlCharacter(String value) {
    return value.codeUnits.any((c) => c < 32 || c == 127);
  }

  bool _containsNonAscii(String value) {
    return value.codeUnits.any((c) => c > 127);
  }

  ReferenceFrame normalize(ReferenceFrame frame) {
    var body = frame.astronomicalBody.toLowerCase();

    if (body.startsWith('the ')) {
      body = body.substring(4);
    }

    final normalizedAlternate = frame.alternateSystem?.toLowerCase();

    return ReferenceFrame(
      astronomicalBody: body,
      alternateSystem: normalizedAlternate ?? frame.alternateSystem,
    );
  }
}
