# Bug Test: issue_343 regression test invokes bin/zfa.dart CLI absent in standalone package

- **Slug**: vpc-issue343-zfa-cli-missing
- **Verified**: 2026-08-28
- **Result**: verified
- **Assessment**: ./assessment.md
- **Fix**: ./fix.md

## Reproduction

`flutter test test/vpc/regression/issue_343_custom_view_route_observer_test.dart`

## Outcome

Passed (with one skip). The CLI-invocation sub-test (`zfa view custom Splash`) now `markTestSkipped`s because `bin/zfa.dart` is absent in this standalone package. The two non-CLI sub-tests (custom capability + entity-backed `CleanView` `routeObserver`) still run and pass, preserving the real regression coverage.

```
00:12 +4 ~1: All tests passed!
  bin/zfa.dart CLI not present in this standalone package   (skipped)
```
