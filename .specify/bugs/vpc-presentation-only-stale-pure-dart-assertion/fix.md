# Bug Fix: VPC presentation_only_workflow test asserts pure-Dart skip on a Flutter fixture

- **Slug**: vpc-presentation-only-stale-pure-dart-assertion
- **Fixed**: 2026-08-28
- **Assessment**: ./assessment.md
- **Status**: applied

## Summary

The fixture written by `writeFlutterPubspec` declares a `flutter:` SDK, so the VPC generators emit the view, presenter, and controller for this Flutter target. The test's `isFalse` assertions (and their "pure-Dart must NOT generate" comments) were stale. Updated them to `isTrue` to match the Flutter fixture's actual behavior; the `profile_state.dart` `isTrue` check and all domain/data/mock/di `isFalse` checks are unchanged.

## Changes

| File | Change | Notes |
|------|--------|-------|
| `test/vpc/integration/presentation_only_workflow_test.dart` | modified | view/presenter/controller existence assertions flipped `isFalse`→`isTrue`; comments corrected. |

## Diff Highlights

```dart
expect(File('$outputDir/presentation/pages/profile/profile_view.dart').existsSync(),
    isTrue, reason: 'Flutter target must generate a Flutter view ...');
expect(File('$outputDir/presentation/pages/profile/profile_presenter.dart').existsSync(),
    isTrue, reason: 'Flutter target must generate a Flutter presenter ...');
expect(File('$outputDir/presentation/pages/profile/profile_controller.dart').existsSync(),
    isTrue, reason: 'Flutter target must generate a Flutter controller ...');
```

## Tests Added or Updated

- `test/vpc/integration/presentation_only_workflow_test.dart` — now asserts the generated view/presenter/controller exist for the Flutter fixture.

## Local Verification

- Command run: `flutter test test/vpc/integration/presentation_only_workflow_test.dart` (pending — see test.md).

## Deviations from Assessment

- TDD loop skipped: test-assertion correction, not new behavior.

## Follow-ups

- None.
