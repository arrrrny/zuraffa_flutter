# Bug Test: PresenterPlugin ignores useZorphy=false (emits EntityPatch, not Partial<Entity>)

- **Slug**: presenter-usecase-usezorphy-partial-emit
- **Verified**: 2026-08-28
- **Result**: verified (green)
- **Assessment**: ./assessment.md
- **Fix**: ./fix.md (status: resolved)

## Reproduction

`flutter test test/vpc/plugins/presenter_usecase_test.dart`

## Outcome

**Green.** With `zuraffa_flutter` depending on `zuraffa: hosted: https://pub.dev,
^6.0.0` (resolves core **6.1.0**, which carries the `useZorphy` fix), both sub-tests pass:

```
00:00 +2: All tests passed!
```

The regression from core issue #431 / `zuraffa_flutter` #9 is closed. No code change
was needed in this repo — only the dependency repoint to the published 6.1.0.
