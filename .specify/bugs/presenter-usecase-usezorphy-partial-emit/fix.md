# Bug Fix: PresenterPlugin ignores useZorphy=false (emits EntityPatch, not Partial<Entity>)

- **Slug**: presenter-usecase-usezorphy-partial-emit
- **Fixed**: 2026-08-28
- **Assessment**: ./assessment.md
- **Status**: resolved (core zuraffa 6.1.0 published to pub.dev; zuraffa_flutter repointed to `hosted: https://pub.dev`)

## Summary

The failing test drives the **core** zuraffa `PresenterPlugin` (`package:zuraffa/src/plugins/presenter/presenter_plugin.dart`) and asserts that `useZorphy=false` emits `Partial<Product>` (`UpdateParams<String, Partial<Product>>`). The core plugin still emits `ProductPatch` for that flag, so the assertion fails.

This behavior lives in `arrrrny/zuraffa`, **not** in the `zuraffa_flutter` package. There is no code in this repository that can implement the `useZorphy=false -> Partial<Entity>` path, so the fix cannot be applied here.

## Changes

| File | Change | Notes |
|------|--------|-------|
| (none in this repo) | — | Fix belongs in core zuraffa `src/plugins/presenter/presenter_plugin.dart`. |

## Local Verification

- `flutter test test/vpc/plugins/presenter_usecase_test.dart` → still red on the `useZorphy=false should emit Partial<Entity>` sub-test (expected until core zuraffa is fixed).

## Deviations from Assessment

- Fix not applied: out of scope for `zuraffa_flutter`. Tracked as issue #9; requires a core zuraffa change + republish (working version here is `zuraffa 6.0.1` from `pub.zuzu.dev`).

## Follow-ups

- DONE in core `arrrrny/zuraffa` 6.0.2 (PR #554 merged; carries the `useZorphy` fix
  from PR #547). Published as **6.1.0 to pub.dev** (per repo owner). `zuraffa_flutter`
  now depends on `zuraffa: hosted: https://pub.dev, version: ^6.0.0` (resolves 6.1.0),
  so this transported test passes with no further changes here.
