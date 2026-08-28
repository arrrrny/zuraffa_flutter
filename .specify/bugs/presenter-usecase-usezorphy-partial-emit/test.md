# Bug Test: PresenterPlugin ignores useZorphy=false (emits EntityPatch, not Partial<Entity>)

- **Slug**: presenter-usecase-usezorphy-partial-emit
- **Verified**: 2026-08-28
- **Result**: fixed-upstream (core zuraffa 6.0.2; pending pub.dev publish + zuraffa_flutter repoint)
- **Assessment**: ./assessment.md
- **Fix**: ./fix.md (status: not-applied)

## Reproduction

`flutter test test/vpc/plugins/presenter_usecase_test.dart`

## Outcome

Still red on `master`'s published `6.0.1`, but **fixed upstream**: core `arrrrny/zuraffa`
PR #547 (shipped in the 6.0.2 release, PR #554) makes `PresenterPlugin` honor
`useZorphy: false`. Verified by pointing `zuraffa_flutter` at core `master` —
both sub-tests pass:

```
00:00 +2: All tests passed!
```

Remaining steps: publish core `6.0.2` to **pub.dev only**, then repoint
`zuraffa_flutter`'s `zuraffa` dependency to `hosted: https://pub.dev`. After that
this transported test goes green without further changes here.
