import 'package:flutter_test/flutter_test.dart';
import 'package:pipeline_app/domain/reference_frame.dart';

void main() {
  group('ReferenceFrame', () {
    test('default construction sets astronomicalBody to earth and alternateSystem to null', () {
      final rf = ReferenceFrame();

      expect(rf.astronomicalBody, 'earth');
      expect(rf.alternateSystem, isNull);
    });

    test('custom construction sets both fields', () {
      final rf = ReferenceFrame(astronomicalBody: 'mars', alternateSystem: 'stargate-grid-7');

      expect(rf.astronomicalBody, 'mars');
      expect(rf.alternateSystem, 'stargate-grid-7');
    });

    test('construction without alternateSystem sets it to null', () {
      final rf = ReferenceFrame(astronomicalBody: 'enceladus');

      expect(rf.astronomicalBody, 'enceladus');
      expect(rf.alternateSystem, isNull);
    });

    test('fromJson parses full reference frame', () {
      final rf = ReferenceFrame.fromJson({
        'astronomical_body': 'mars',
        'alternate_system': 'holodeck-alpha',
      });

      expect(rf.astronomicalBody, 'mars');
      expect(rf.alternateSystem, 'holodeck-alpha');
    });

    test('fromJson parses without alternateSystem', () {
      final rf = ReferenceFrame.fromJson({
        'astronomical_body': 'earth',
      });

      expect(rf.astronomicalBody, 'earth');
      expect(rf.alternateSystem, isNull);
    });

    test('fromJson defaults astronomicalBody to earth when absent', () {
      final rf = ReferenceFrame.fromJson({});

      expect(rf.astronomicalBody, 'earth');
      expect(rf.alternateSystem, isNull);
    });

    test('toJson serializes both fields', () {
      final rf = ReferenceFrame(astronomicalBody: 'ceres', alternateSystem: 'vr-grid');

      final json = rf.toJson();
      expect(json['astronomical_body'], 'ceres');
      expect(json['alternate_system'], 'vr-grid');
    });

    test('toJson omits alternateSystem when null', () {
      final rf = ReferenceFrame(astronomicalBody: 'earth');

      final json = rf.toJson();
      expect(json['astronomical_body'], 'earth');
      expect(json.containsKey('alternate_system'), isFalse);
    });

    test('copyWith preserves unmodified fields', () {
      final rf = ReferenceFrame(astronomicalBody: 'ceres', alternateSystem: 'vr-grid');
      final updated = rf.copyWith(astronomicalBody: 'mars');

      expect(updated.astronomicalBody, 'mars');
      expect(updated.alternateSystem, 'vr-grid');
    });

    test('copyWith clears alternateSystem when null passed', () {
      final rf = ReferenceFrame(astronomicalBody: 'ceres', alternateSystem: 'vr-grid');
      final updated = rf.copyWith(alternateSystem: null);

      expect(updated.astronomicalBody, 'ceres');
      expect(updated.alternateSystem, isNull);
    });

    test('equality compares by value', () {
      final a = ReferenceFrame(astronomicalBody: 'mars');
      final b = ReferenceFrame(astronomicalBody: 'mars');
      final c = ReferenceFrame(astronomicalBody: 'earth');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent with equality', () {
      final a = ReferenceFrame(astronomicalBody: 'mars');
      final b = ReferenceFrame(astronomicalBody: 'mars');

      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
