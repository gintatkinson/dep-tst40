enum ValidationErrorType {
  controlCharacter,
  patternViolation,
  alternateSystemDisabled,
  nonAsciiCharacter,
}

class ValidationError {
  final String field;
  final String message;
  final ValidationErrorType type;

  const ValidationError({
    required this.field,
    required this.message,
    required this.type,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationError &&
        other.field == field &&
        other.message == message &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(field, message, type);

  @override
  String toString() => 'ValidationError($field: $message)';
}

sealed class ValidationResult {
  const ValidationResult();
}

class ValidationValid extends ValidationResult {
  const ValidationValid();
}

class ValidationInvalid extends ValidationResult {
  final List<ValidationError> errors;

  const ValidationInvalid(this.errors);
}
