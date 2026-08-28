# Bug Assessment: PresenterPlugin ignores useZorphy=false (emits EntityPatch, not Partial<Entity>)

- **Slug**: presenter-usecase-usezorphy-partial-emit
- **Created**: 2026-08-28
- **Source**: pasted text (flutter test failure)
- **Verdict**: valid
- **Severity**: medium

## Report (verbatim or summarized)

`flutter test` failure:

```
test/vpc/plugins/presenter_usecase_test.dart: useZorphy flag for update method in presenter
  presenter emits Partial<Entity> when useZorphy=false
    Expected: true
      Actual: <false>
    useZorphy=false should emit Partial<Entity> for update params
```

## Symptom

`PresenterPlugin` (core zuraffa) is driven with `useZorphy: false` and `methods: ['update']`. The test expects the generated presenter's update params to be `UpdateParams<String, Partial<Product>>` (i.e. it emits `Partial<Product>`). The plugin instead emits `ProductPatch` (`UpdateParams<String, ProductPatch>`), so the `Partial<Product>` assertion fails.

## Reproduction

1. `cd /workspace/zuraffa_flutter`
2. `flutter test test/vpc/plugins/presenter_usecase_test.dart`
3. The `useZorphy=false should emit Partial<Entity>` sub-test fails.

## Suspected Code Paths

- `package:zuraffa/src/plugins/presenter/presenter_plugin.dart` — the `useZorphy` flag is not honored for `useZorphy=false`; the update params always use the `EntityPatch` variant regardless of the flag.
- `test/vpc/plugins/presenter_usecase_test.dart:62-96` — the failing sub-test (transported from core zuraffa issue #431; documents the intended behavior).

## Root Cause Hypothesis

The core zuraffa `PresenterPlugin` does not implement the `useZorphy=false → Partial<Entity>` path. The `true` (default) branch emitting `EntityPatch` works; the `false` branch still emits `EntityPatch`. This is **core generator behavior** that lives in `arrrrny/zuraffa`, not in this `zuraffa_flutter` package. Confidence: high (the failing assertion directly pins the emitted `UpdateParams<String, Partial<Product>>` string).

## Proposed Remediation

**Preferred**: Fix `PresenterPlugin` in the core `arrrrny/zuraffa` repository so that `useZorphy=false` emits `Partial<Entity>` (e.g. `UpdateParams<String, Partial<Product>>`) for update params, while `useZorphy=true` (default) keeps `EntityPatch`. This is **out of scope for `zuraffa_flutter`** — the test here is a transported regression test that cannot pass until core zuraffa is fixed.

**Alternatives**:
- None actionable in this repo. Updating the test to assert the current (buggy) behavior would mask a real intended behavior and is rejected.

**Files likely to change** (in core zuraffa, NOT this repo):
- `src/plugins/presenter/presenter_plugin.dart`

**Tests to add or update**:
- `test/vpc/plugins/presenter_usecase_test.dart` (this repo) already covers it once core is fixed.

## Risks & Considerations

- Cannot be fixed in `zuraffa_flutter`; requires a change in `arrrrny/zuraffa` and a republish (the working version here is `zuraffa 6.0.1` from `pub.zuzu.dev`).
- Until then, this test remains red. It is a legitimate in-repo guard for the core behavior.

## Open Questions

- Does core zuraffa have an existing issue for `useZorphy=false → Partial`? If not, file one there and link it.
