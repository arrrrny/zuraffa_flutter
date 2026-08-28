# Bug Assessment: VPC presentation_only_workflow test asserts pure-Dart skip on a Flutter fixture

- **Slug**: vpc-presentation-only-stale-pure-dart-assertion
- **Created**: 2026-08-28
- **Source**: pasted text (flutter test failure)
- **Verdict**: valid
- **Severity**: low

## Report (verbatim or summarized)

`flutter test` failure:

```
test/vpc/integration/presentation_only_workflow_test.dart: generates only presentation layer when requested
  Expected: false
    Actual: <true>
  pure-Dart target must NOT generate a Flutter view (Constitution VII: Engine Purity)
```

## Symptom

The test writes a fixture via `writeFlutterPubspec` (declares `flutter:`) and asserts the view, presenter, and controller files do NOT exist, claiming "pure-Dart target must NOT generate a Flutter view". The fixture is a Flutter target, so the VPC generators emit those artifacts and the `isFalse` assertions fail.

## Reproduction

1. `cd /workspace/zuraffa_flutter`
2. `flutter test test/vpc/integration/presentation_only_workflow_test.dart`
3. Observe the view/presenter/controller `existsSync()` `isFalse` assertions fail.

## Suspected Code Paths

- `test/vpc/integration/presentation_only_workflow_test.dart:62-96` — stale comments + `isFalse` assertions for view/presenter/controller existence.
- `test/vpc/helpers/vpc_test_utils.dart:85-109` — `writeFlutterPubspec` declares `flutter:` SDK; VPC output is emitted for Flutter targets.

## Root Cause Hypothesis

Stale test assertion (same root cause as `vpc-orchestrator-stale-pure-dart-assertion`). The fixture is Flutter, so presentation-layer artifacts are generated; the test still encodes the old pure-Dart skip expectation. Confidence: high.

## Proposed Remediation

**Preferred**: Update the assertions in `presentation_only_workflow_test.dart` to expect the view, presenter, and controller files to BE generated (`isTrue`) for the Flutter fixture, and correct the misleading "pure-Dart target must NOT generate" comments. Keep the `profile_state.dart` `isTrue` check and all domain/data/mock/di `isFalse` checks (no data layer requested).

**Alternatives**:
- Switch to a pure-Dart pubspec helper to preserve Engine-Purity skip coverage. Rejected for the same reason as the orchestrator test: this test verifies presentation-only generation, which requires a Flutter target.

**Files likely to change**:
- `test/vpc/integration/presentation_only_workflow_test.dart`

**Tests to add or update**:
- Flip view/presenter/controller existence assertions to `isTrue`; fix comments.

## Risks & Considerations

- None beyond test-only change.

## Open Questions

- None.
