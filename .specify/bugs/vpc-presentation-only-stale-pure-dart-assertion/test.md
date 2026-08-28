# Bug Test: VPC presentation_only_workflow test asserts pure-Dart skip on a Flutter fixture

- **Slug**: vpc-presentation-only-stale-pure-dart-assertion
- **Verified**: 2026-08-28
- **Result**: verified
- **Assessment**: ./assessment.md
- **Fix**: ./fix.md

## Reproduction

`flutter test test/vpc/integration/presentation_only_workflow_test.dart`

## Outcome

Passed. The test now writes a Flutter fixture and correctly asserts the generated view, presenter, and controller exist (`isTrue`). The `profile_state.dart` `isTrue` check and all domain/data/mock/di `isFalse` checks still hold.

```
All tests passed!
```
