# Bug Test: PresenterPlugin ignores useZorphy=false (emits EntityPatch, not Partial<Entity>)

- **Slug**: presenter-usecase-usezorphy-partial-emit
- **Verified**: 2026-08-28
- **Result**: failed
- **Assessment**: ./assessment.md
- **Fix**: ./fix.md (status: not-applied)

## Reproduction

`flutter test test/vpc/plugins/presenter_usecase_test.dart`

## Outcome

Still red on the `useZorphy=false should emit Partial<Entity>` sub-test:

```
Expected: true
  Actual: <false>
useZorphy=false should emit Partial<Entity> for update params
```

The fix belongs in core `arrrrny/zuraffa` (`PresenterPlugin`); it cannot be applied in `zuraffa_flutter`. Tracked as issue #9. This test remains a legitimate in-repo guard for the core behavior until core zuraffa is fixed and republished.
