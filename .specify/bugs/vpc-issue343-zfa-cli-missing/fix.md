# Bug Fix: issue_343 regression test invokes bin/zfa.dart CLI absent in standalone package

- **Slug**: vpc-issue343-zfa-cli-missing
- **Fixed**: 2026-08-28
- **Assessment**: ./assessment.md
- **Status**: applied

## Summary

Guarded the CLI-invocation sub-test (`zfa view custom Splash`) so it `markTestSkipped`s when `bin/zfa.dart` is absent (i.e. in this standalone `zuraffa_flutter` package). The two non-CLI sub-tests (`CustomViewCapability` + entity-backed `CleanView` `routeObserver`) still run and preserve the real regression coverage. Inside the core zuraffa monorepo, where `bin/zfa.dart` exists, the CLI path runs unchanged.

## Changes

| File | Change | Notes |
|------|--------|-------|
| `test/vpc/regression/issue_343_custom_view_route_observer_test.dart` | modified | added `markTestSkipped` guard at the start of the `zfa view custom` sub-test when `bin/zfa.dart` is missing. |

## Diff Highlights

```dart
if (!File(p.join(_zfaRoot, 'bin', 'zfa.dart')).existsSync()) {
  markTestSkipped('bin/zfa.dart CLI not present in this standalone package');
  return;
}
```

## Tests Added or Updated

- `test/vpc/regression/issue_343_custom_view_route_observer_test.dart` — CLI sub-test skips in standalone checkout; regression still covered by the two `ViewPlugin`/`CustomViewCapability` sub-tests.

## Local Verification

- Command run: `flutter test test/vpc/regression/issue_343_custom_view_route_observer_test.dart` (pending — see test.md).

## Deviations from Assessment

- TDD loop skipped: test-only guard, not new behavior.

## Follow-ups

- None.
