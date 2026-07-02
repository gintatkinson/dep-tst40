import 'package:meta/meta.dart';

@immutable
class ReferenceFrame {
  final String astronomicalBody;
  final String? alternateSystem;

  const ReferenceFrame({
    this.astronomicalBody = 'earth',
    this.alternateSystem,
  });

  factory ReferenceFrame.fromJson(Map<String, dynamic> json) {
    return ReferenceFrame(
      astronomicalBody: (json['astronomical_body'] as String?) ?? 'earth',
      alternateSystem: json['alternate_system'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'astronomical_body': astronomicalBody,
    };
    if (alternateSystem != null) {
      map['alternate_system'] = alternateSystem;
    }
    return map;
  }

  ReferenceFrame copyWith({
    String? astronomicalBody,
    Object? alternateSystem = _sentinel,
  }) {
    return ReferenceFrame(
      astronomicalBody: astronomicalBody ?? this.astronomicalBody,
      alternateSystem: identical(alternateSystem, _sentinel)
          ? this.alternateSystem
          : alternateSystem as String?,
    );
  }

  static const _sentinel = Object();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReferenceFrame &&
        other.astronomicalBody == astronomicalBody &&
        other.alternateSystem == alternateSystem;
  }

  @override
  int get hashCode => Object.hash(astronomicalBody, alternateSystem);

  @override
  String toString() =>
      'ReferenceFrame(astronomicalBody: $astronomicalBody, alternateSystem: $alternateSystem)';
}
