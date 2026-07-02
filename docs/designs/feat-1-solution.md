---
title: "Solution Walkthrough — Feature #1: Configure Reference Frame"
platform: flutter
issue_id: 1
created: "2026-07-02"
---

# Solution Walkthrough: Feature #1 — Configure Reference Frame

## Overview

Implements RFC 9179 Section 2.1 Reference Frame container in a Flutter desktop application using SQLite persistence, MVVM architecture, and TDD discipline.

## Architecture

```
app_flutter/
  lib/
    domain/
      reference_frame.dart           — Immutable data class
      reference_frame_validator.dart — Validation logic (20 ACs)
      validation_result.dart         — Sealed result type
      feature_flags.dart             — Feature flag resolver
    data/
      reference_frame_repository.dart        — Abstract interface
      sqlite_reference_frame_repository.dart — SQLite implementation
    features/
      reference_frame/
        reference_frame_viewmodel.dart — ChangeNotifier ViewModel (MVVM)
        reference_frame_form.dart      — UI form widget
    app.dart    — MaterialApp root widget
    main.dart   — Bootstrap, SQLite init, DI wiring
  test/
    domain/
      reference_frame_test.dart          — 12 tests
      reference_frame_validator_test.dart — 24 tests
    data/
      sqlite_reference_frame_repository_test.dart — 8 tests
    features/
      reference_frame/
        reference_frame_viewmodel_test.dart — 14 tests
        reference_frame_form_test.dart       — 3 tests
```

## Code Realization Table

| Spec Component | Source File | Class/Method |
|---|---|---|
| ReferenceFrame container | `lib/domain/reference_frame.dart` | `ReferenceFrame` class, `fromJson()`, `toJson()`, `copyWith()` |
| astronomical-body validation | `lib/domain/reference_frame_validator.dart` | `ReferenceFrameValidator.validate()`, `_validateAstronomicalBody()` |
| alternate-system gating | `lib/domain/reference_frame_validator.dart` | `_validateAlternateSystem()` |
| Uppercase normalization | `lib/domain/reference_frame_validator.dart` | `normalize()` — lowercase conversion |
| Leading "the" stripping | `lib/domain/reference_frame_validator.dart` | `normalize()` — `startsWith('the ')` check |
| Control character rejection | `lib/domain/reference_frame_validator.dart` | `_containsControlCharacter()` |
| Non-ASCII rejection | `lib/domain/reference_frame_validator.dart` | `_containsNonAscii()` |
| READ reference frame | `lib/data/sqlite_reference_frame_repository.dart` | `get()` |
| WRITE/UPDATE reference frame | `lib/data/sqlite_reference_frame_repository.dart` | `save()` |
| DELETE reference frame | `lib/data/sqlite_reference_frame_repository.dart` | `delete()` |
| UI form | `lib/features/reference_frame/reference_frame_form.dart` | `ReferenceFrameForm` widget |
| State management | `lib/features/reference_frame/reference_frame_viewmodel.dart` | `ReferenceFrameViewModel` (ChangeNotifier) |

## Acceptance Criteria Verification

| AC | Description | Test File | Status |
|---|---|---|---|
| AC-01 | Default Earth | `reference_frame_validator_test.dart` | PASS |
| AC-02 | Custom body "mars" | `reference_frame_validator_test.dart` | PASS |
| AC-03 | Alternate system with flag | `reference_frame_validator_test.dart` | PASS |
| AC-04 | Read full state | `sqlite_reference_frame_repository_test.dart` | PASS |
| AC-05 | Alternate rejected when disabled | `reference_frame_validator_test.dart` | PASS |
| AC-06 | Valid pattern "67p/churyumov-gerasimenko" | `reference_frame_validator_test.dart` | PASS |
| AC-07 | Control char (BEL) rejected | `reference_frame_validator_test.dart` | PASS |
| AC-08 | DEL rejected | `reference_frame_validator_test.dart` | PASS |
| AC-09 | Valid ASCII "1p/halley" | `reference_frame_validator_test.dart` | PASS |
| AC-10 | Uppercase → lowercase | `reference_frame_validator_test.dart` | PASS |
| AC-11 | Leading "the" stripped | `reference_frame_validator_test.dart` | PASS |
| AC-12 | "The Moon" → "moon" | `reference_frame_validator_test.dart` | PASS |
| AC-13 | Delete when no children | `sqlite_reference_frame_repository_test.dart` | PASS |
| AC-14 | Delete rejected with children | (Repository-level — Feature #3+) | DEFERRED |
| AC-15 | Location write without ref frame | (Repository-level — Feature #3+) | DEFERRED |
| AC-16 | Update preserves unmodified | `reference_frame_test.dart` (copyWith) | PASS |
| AC-17 | Full PUT replacement | `sqlite_reference_frame_repository_test.dart` | PASS |
| AC-18 | Non-ASCII rejected | `reference_frame_validator_test.dart` | PASS |
| AC-19 | No alt system = natural universe | `reference_frame_validator_test.dart` | PASS |
| AC-20 | Orientation out of scope | Specification note (no code) | N/A |

## Test Evidence

```
flutter test — 61/61 PASS (0 failures)
flutter analyze — 0 errors, 0 warnings
Contamination audit — CLEAN
```

## Manual Testing Instructions

1. Build and run: `cd app_flutter && flutter run -d macos`
2. The app displays "Reference Frame Configuration" with two fields:
   - **Astronomical Body** — Enter any value (e.g. "mars", "67p/churyumov-gerasimenko")
   - **Alternate System** — When feature flag is disabled, any value in this field shows error "alternate-systems feature is not enabled"
3. Click **Save** — value persists in SQLite
4. Close and reopen the app — previously saved value is restored
5. Enter a control character (e.g. paste a tab) — validation error displayed
6. Enter "Earth" (uppercase E) and Save — value is normalized to "earth"
7. Click **Delete** → confirm → reference frame is removed
8. Verify SQLite database: `app_flutter/pipeline.db` contains single-row `reference_frame` table

## Known Deferred Items

- AC-14 (delete rejection with child location data): Requires Feature #3 (Ellipsoid Location) to be implemented
- AC-15 (location write without reference frame): Requires Feature #3
- Firestore adapter: Interface exists, implementation deferred pending Firebase emulator setup

## Dependencies

- `sqflite_common_ffi` — SQLite for desktop
- `path_provider` — Application documents directory
- `flutter_test` — Unit/widget testing
- `meta` — Immutable annotation
