# Bug Verification: Test compilation fails — zuraffa-6.0.0 exports missing src/extensions/future_extensions.dart

- **Slug**: zuraffa-export-missing-future-extensions
- **Tested**: 2026-08-28
- **Assessment**: ./assessment.md
- **Fix**: ./fix.md
- **Result**: verified
- **TDD verification**: n/a

## Summary

The originally-reported symptom (compilation error in `test/presentation/stateful_controller_test.dart`
and `test/state/widget_test.dart` because `package:zuraffa/zuraffa.dart` could not resolve the missing
`src/extensions/future_extensions.dart` export) no longer reproduces. The fix pins `zuraffa` to the hosted
`pub.zuzu.dev` source at `^6.0.0` (which resolves to the working `6.0.1`), whose barrel export resolves
correctly. Both named tests now compile and pass.

## Checks Performed

| Check | Command / Action | Result | Notes |
|-------|------------------|--------|-------|
| Reproduction (post-fix) | `flutter test test/state/widget_test.dart test/presentation/stateful_controller_test.dart` | pass | both compile and pass |
| Regression suite | `flutter test` (full) | 4 remaining failures, none are this bug | see Residual Risks |
| Dependency resolution | `flutter pub get --offline` with `zuraffa` → `pub.zuzu.dev` | pass | resolves `6.0.1` (SHA `3242d0…`) |

## Output Excerpts

```
02:47 +184 -4: .../test/state/widget_test.dart: SignalBuilder renders initial value ...
02:47 +190 -4: .../test/state/widget_test.dart: ControlledWidget calls onInit on mount ...
02:48 +191 -4: Some tests failed.
```

(The 4 remaining failures are unrelated VPC integration/regression tests — see Residual Risks.)

## Residual Risks

- `pub.dev` and the `pub.flutter-io.cn` mirror only publish a **broken** `zuraffa 6.0.0`
  (missing `lib/src/extensions/future_extensions.dart`; identical SHA-256 on both hosts). The working
  `6.0.1` lives only on the internal `pub.zuzu.dev` host. Until upstream publishes a fixed `6.0.0`/`6.0.1`
  to `pub.dev`, this package depends on `pub.zuzu.dev`. CI must have access to that host (or a pre-seeded
  cache) for `flutter pub get` to succeed.
- Three **other** VPC tests still fail, but for reasons unrelated to this bug (tracked separately under
  the VPC bug): `orchestrator_no_usecase_test.dart` and `presentation_only_workflow_test.dart` carry stale
  pure-Dart expectations while their fixture is now a Flutter target; `issue_343_custom_view_route_observer_test.dart`
  invokes `bin/zfa.dart` (the core `zuraffa` CLI), which does not exist in this standalone package.

## Recommendation

Close the bug — the reported compilation failure is verified fixed. Follow up upstream to publish a working
`zuraffa` to `pub.dev`, then switch the `hosted:` URL back to `https://pub.dev`.
