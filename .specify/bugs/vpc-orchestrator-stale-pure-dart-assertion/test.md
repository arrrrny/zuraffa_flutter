# Bug Test: VPC orchestrator_no_usecase test asserts pure-Dart skip on a Flutter fixture

- **Slug**: vpc-orchestrator-stale-pure-dart-assertion
- **Verified**: 2026-08-28
- **Result**: verified
- **Assessment**: ./assessment.md
- **Fix**: ./fix.md

## Reproduction

`flutter test test/vpc/integration/orchestrator_no_usecase_test.dart`

## Outcome

Passed. The test now writes a Flutter fixture (`writeFlutterPubspec` declares `flutter:`) and correctly asserts the generated presenter and controller exist (`isTrue`). The usecase-skip check (`generateUseCase: false` → no `permissions_usecase.dart`) still holds.

```
00:04 +2: ...orchestrator_no_usecase_test.dart: generates presenter with multiple usecases directly when usecase plugin is disabled
All tests passed!
```
