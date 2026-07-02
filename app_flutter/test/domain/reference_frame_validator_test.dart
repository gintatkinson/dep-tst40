import 'package:flutter_test/flutter_test.dart';
import 'package:pipeline_app/domain/feature_flags.dart';
import 'package:pipeline_app/domain/reference_frame.dart';
import 'package:pipeline_app/domain/reference_frame_validator.dart';
import 'package:pipeline_app/domain/validation_result.dart';

void main() {
  group('ReferenceFrameValidator', () {
    late ReferenceFrameValidator validator;

    setUp(() {
      validator = const ReferenceFrameValidator();
    });

    group('astronomicalBody validation', () {
      test('AC-01: default astronomical body "earth" is valid', () {
        final rf = ReferenceFrame();
        final result = validator.validate(rf, const FeatureFlags());

        expect(result, isA<ValidationValid>());
      });

      test('AC-02: custom astronomical body "mars" is valid', () {
        final rf = ReferenceFrame(astronomicalBody: 'mars');
        final result = validator.validate(rf, const FeatureFlags());

        expect(result, isA<ValidationValid>());
        expect(rf.astronomicalBody, 'mars');
      });

      test('AC-06: valid pattern "67p/churyumov-gerasimenko"', () {
        final rf = ReferenceFrame(astronomicalBody: '67p/churyumov-gerasimenko');
        final result = validator.validate(rf, const FeatureFlags());

        expect(result, isA<ValidationValid>());
      });

      test('AC-07: control character (ASCII 0x07 BEL) rejected', () {
        final rf = ReferenceFrame(astronomicalBody: 'test\x07');
        final result = validator.validate(rf, const FeatureFlags());

        expect(result, isA<ValidationInvalid>());
        final errors = (result as ValidationInvalid).errors;
        expect(errors.any((e) => e.type == ValidationErrorType.controlCharacter), isTrue);
      });

      test('AC-08: DEL character rejected', () {
        final rf = ReferenceFrame(astronomicalBody: 'earth\x7F');
        final result = validator.validate(rf, const FeatureFlags());

        expect(result, isA<ValidationInvalid>());
        final errors = (result as ValidationInvalid).errors;
        expect(errors.any((e) => e.type == ValidationErrorType.controlCharacter), isTrue);
      });

      test('AC-09: valid ASCII range "1p/halley"', () {
        final rf = ReferenceFrame(astronomicalBody: '1p/halley');
        final result = validator.validate(rf, const FeatureFlags());

        expect(result, isA<ValidationValid>());
      });

      test('AC-18: non-ASCII Unicode rejected', () {
        final rf = ReferenceFrame(astronomicalBody: 'titan\xE9');
        final result = validator.validate(rf, const FeatureFlags());

        expect(result, isA<ValidationInvalid>());
        final errors = (result as ValidationInvalid).errors;
        expect(errors.any((e) => e.type == ValidationErrorType.nonAsciiCharacter), isTrue);
      });

      test('backtick is valid (ASCII 96 in range 91-126)', () {
        final rf = ReferenceFrame(astronomicalBody: 'earth`planet');
        final result = validator.validate(rf, const FeatureFlags());

        expect(result, isA<ValidationValid>());
      });

      test('curly brace is valid (ASCII 123 in range 91-126)', () {
        final rf = ReferenceFrame(astronomicalBody: 'earth{planet}');
        final result = validator.validate(rf, const FeatureFlags());

        expect(result, isA<ValidationValid>());
      });

      test('uppercase letter is valid but will be normalized', () {
        final rf = ReferenceFrame(astronomicalBody: 'EARTH');
        final result = validator.validate(rf, const FeatureFlags());

        expect(result, isA<ValidationValid>());
      });

      test('empty string is invalid', () {
        final rf = ReferenceFrame(astronomicalBody: '');
        final result = validator.validate(rf, const FeatureFlags());

        expect(result, isA<ValidationInvalid>());
      });
    });

    group('normalization', () {
      test('AC-10: uppercase normalized to lowercase', () {
        final rf = ReferenceFrame(astronomicalBody: 'Earth');
        final normalized = validator.normalize(rf);

        expect(normalized.astronomicalBody, 'earth');
      });

      test('AC-11: leading "the" stripped', () {
        final rf = ReferenceFrame(astronomicalBody: 'the moon');
        final normalized = validator.normalize(rf);

        expect(normalized.astronomicalBody, 'moon');
      });

      test('AC-12: leading "The" stripped and lowercased', () {
        final rf = ReferenceFrame(astronomicalBody: 'The Moon');
        final normalized = validator.normalize(rf);

        expect(normalized.astronomicalBody, 'moon');
      });

      test('normalization does not modify already normal value', () {
        final rf = ReferenceFrame(astronomicalBody: 'earth');
        final normalized = validator.normalize(rf);

        expect(normalized.astronomicalBody, 'earth');
      });

      test('normalization strips leading "the " case-insensitively', () {
        final rf = ReferenceFrame(astronomicalBody: 'THE mars');
        final normalized = validator.normalize(rf);

        expect(normalized.astronomicalBody, 'mars');
      });

      test('normalization does not strip "the" when not at start', () {
        final rf = ReferenceFrame(astronomicalBody: 'planet the');
        final normalized = validator.normalize(rf);

        expect(normalized.astronomicalBody, 'planet the');
      });

      test('normalization lowercases entire string', () {
        final rf = ReferenceFrame(astronomicalBody: 'ENCELADUS');
        final normalized = validator.normalize(rf);

        expect(normalized.astronomicalBody, 'enceladus');
      });
    });

    group('alternateSystem validation', () {
      test('AC-03: alternate system accepted when flag enabled', () {
        final rf = ReferenceFrame(
          astronomicalBody: 'earth',
          alternateSystem: 'holodeck-alpha',
        );
        final result = validator.validate(
          rf,
          const FeatureFlags(alternateSystemsEnabled: true),
        );

        expect(result, isA<ValidationValid>());
      });

      test('AC-05: alternate system rejected when flag disabled', () {
        final rf = ReferenceFrame(
          astronomicalBody: 'earth',
          alternateSystem: 'some-system',
        );
        final result = validator.validate(
          rf,
          const FeatureFlags(alternateSystemsEnabled: false),
        );

        expect(result, isA<ValidationInvalid>());
        final errors = (result as ValidationInvalid).errors;
        expect(
          errors.any((e) => e.type == ValidationErrorType.alternateSystemDisabled),
          isTrue,
        );
      });

      test('no alternate system is always valid regardless of flag', () {
        final rf = ReferenceFrame(astronomicalBody: 'earth');
        final result = validator.validate(
          rf,
          const FeatureFlags(alternateSystemsEnabled: false),
        );

        expect(result, isA<ValidationValid>());
      });

      test('AC-04: alternate system "virtual-orrery" with "enceladus"', () {
        final rf = ReferenceFrame(
          astronomicalBody: 'enceladus',
          alternateSystem: 'virtual-orrery',
        );
        final result = validator.validate(
          rf,
          const FeatureFlags(alternateSystemsEnabled: true),
        );

        expect(result, isA<ValidationValid>());
      });
    });

    group('combined validation', () {
      test('invalid body + valid alternate system → returns body errors only', () {
        final rf = ReferenceFrame(
          astronomicalBody: '',
          alternateSystem: 'valid-system',
        );
        final result = validator.validate(
          rf,
          const FeatureFlags(alternateSystemsEnabled: true),
        );

        expect(result, isA<ValidationInvalid>());
        final errors = (result as ValidationInvalid).errors;
        expect(errors.any((e) => e.field == 'astronomicalBody'), isTrue);
      });

      test('invalid body + invalid alternate system → returns both errors', () {
        final rf = ReferenceFrame(
          astronomicalBody: '\x00',
          alternateSystem: 'bad-system',
        );
        final result = validator.validate(
          rf,
          const FeatureFlags(alternateSystemsEnabled: false),
        );

        expect(result, isA<ValidationInvalid>());
        final errors = (result as ValidationInvalid).errors;
        expect(errors.length, greaterThanOrEqualTo(2));
      });
    });
  });
}
