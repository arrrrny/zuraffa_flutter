# Bug Assessment: VPC orchestrator_no_usecase test asserts pure-Dart skip on a Flutter fixture

- **Slug**: vpc-orchestrator-stale-pure-dart-assertion
- **Created**: 2026-08-28
- **Source**: pasted text (flutter test failure)
- **Verdict**: valid
- **Severity**: low

## Report (verbatim or summarized)

`flutter test` failure:

```
test/vpc/integration/orchestrator_no_usecase_test.dart: generates presenter with multiple usecases directly when usecase plugin is disabled
  Expected: false
    Actual: <true>
  pure-Dart target must NOT generate a Flutter presenter (Constitution VII: Engine Purity)
```

## Symptom

The test writes a fixture via `writeFlutterPubspec` (which declares a `flutter:` SDK) and then asserts the generated presenter and controller files do NOT exist, claiming "pure-Dart target must NOT generate a Flutter presenter". Because the fixture actually declares `flutter:`, the VPC generators detect a Flutter target and DO emit the presenter/controller, so the `expect(...existsSync(), isFalse)` assertions fail.

## Reproduction

1. `cd /workspace/zuraffa_flutter`
2. `flutter test test/vpc/integration/orchestrator_no_usecase_test.dart`
3. Observe the two `existsSync()` `isFalse` assertions fail (presenter/controller exist).

## Suspected Code Paths

- `test/vpc/integration/orchestrator_no_usecase_test.dart:80-109` — stale comments + `isFalse` assertions for presenter/controller existence.
- `test/vpc/helpers/vpc_test_utils.dart:85-109` — `writeFlutterPubspec` declares `flutter:` SDK, so the fixture is a Flutter target and VPC output is emitted (by design, see header note lines 8-15).

## Root Cause Hypothesis

Stale test assertion. When the VPC fixtures were switched from a pure-Dart pubspec to a `flutter:` pubspec (so the presentation-layer generators run on their intended target — PR #5 / issue #435), these two integration tests were not updated; their comments still describe the old pure-Dart Engine-Purity skip behavior. Confidence: high.

## Proposed Remediation

**Preferred**: Update the assertions in `orchestrator_no_usecase_test.dart` to expect the presenter and controller files to BE generated (`isTrue`) for the Flutter fixture, and correct the now-misleading "pure-Dart target must NOT generate" comments. Keep the usecase-skip checks (`generateUseCase: false` → no `permissions_usecase.dart`).

**Alternatives**:
- Change the test to call a pure-Dart pubspec helper (no `flutter:`) to preserve the original Engine-Purity skip coverage. Rejected: the test name ("generates presenter ... when usecase plugin is disabled") describes generation, so it should verify generation on the Flutter target; the pure-Dart skip is covered elsewhere.

**Files likely to change**:
- `test/vpc/integration/orchestrator_no_usecase_test.dart`

**Tests to add or update**:
- Flip presenter/controller existence assertions to `isTrue`; fix comments.

## Risks & Considerations

- None beyond test-only change. No production code affected.

## Open Questions

- None.
