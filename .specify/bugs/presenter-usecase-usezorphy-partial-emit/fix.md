# Bug Fix: PresenterPlugin ignores useZorphy=false (emits EntityPatch, not Partial<Entity>)

- **Slug**: presenter-usecase-usezorphy-partial-emit
- **Fixed**: 2026-08-28
- **Assessment**: ./assessment.md
- **Status**: fixed-upstream (core zuraffa 6.0.2 — PR #554 merged; awaiting pub.dev publish)

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

- DONE in core `arrrrny/zuraffa` 6.0.2 (PR #554 merged; it carries the `useZorphy` fix
  already on `master` via PR #547). Verified end-to-end: pointing `zuraffa_flutter`
  at `master` makes `presenter_usecase_test` pass (both sub-tests green).
- Next (repo owner): publish `6.0.2` to **pub.dev only** (not the zuzu mirror), then
  point `zuraffa_flutter` at `hosted: https://pub.dev` so this transported test goes green.
