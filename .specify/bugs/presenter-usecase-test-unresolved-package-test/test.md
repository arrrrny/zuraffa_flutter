# Bug Verification: presenter_usecase_test fails to load — cannot resolve package:test/test.dart

- **Slug**: presenter-usecase-test-unresolved-package-test
- **Tested**: 2026-08-28
- **Assessment**: ./assessment.md
- **Fix**: ./fix.md
- **Result**: partial
- **TDD verification**: n/a (validation ran in non-TDD mode; see fix.md deviation note)

## Summary

The reported symptom — `presenter_usecase_test.dart` failing to **load** with
`Couldn't resolve the package 'test' in 'package:test/test.dart'` — is **resolved**: the
test now compiles, loads, and runs. However, the test file still ends red because a
**separate, unrelated** assertion fails. That assertion checks zuraffa's generated
presenter output (`useZorphy=false` should emit `Partial<Product>`), which is behavior of the
external `zuraffa` dependency, not of `zuraffa_flutter` and not part of this bug's scope.

## Checks Performed

| Check | Command / Action | Result | Notes |
|-------|------------------|--------|-------|
| Reproduction (post-fix) | `flutter test test/vpc/plugins/presenter_usecase_test.dart` | partial | Test loads & runs; 1/2 cases pass, 1 assertion fails |
| Original load failure | same run | pass | `package:test` resolution error is gone |
| New / updated tests | same run | fail (1 assertion) | Unrelated to the import fix — see below |
| Regression suite | n/a | skipped | Single-file fix; full suite blocked by env issues (see other bugs) |
| Lint / type-check | `dart analyze test/vpc/plugins/presenter_usecase_test.dart` | not-run | Not executed this round |

## Output Excerpts

```
00:00 +1 -1: ... presenter emits Partial<Entity> when useZorphy=false [E]
  Expected: true
    Actual: <false>
  useZorphy=false should emit Partial<Entity> for update params
  test/vpc/plugins/presenter_usecase_test.dart 86:7
```

The passing case (`useZorphy=true` → emits `EntityPatch`, not `Partial`) confirms the test
now exercises the plugin. The failing case expects `useZorphy=false` to emit
`UpdateParams<String, Partial<Product>>`, but the generated content does not contain it.

## Residual Risks

- **Out-of-scope assertion failure.** The `PresenterPlugin` (and the `useZorphy` /
  `UpdateParams` / `Partial` logic) lives in the external `zuraffa` package
  (`.pub-cache/.../zuraffa-*/lib/src/plugins/presenter/presenter_plugin.dart`), not in
  `zuraffa_flutter`. Whether the missing `Partial<Product>` emission is a real `zuraffa`
  product bug or a wrong test expectation cannot be determined from this repo and is **not**
  part of bug #3. It should get its own assessment/issue if it is a genuine defect.
- The import fix is correct and complete for its stated bug; it does not cause the remaining
  failure.

## Recommendation

Close bug #3 on the strength of the import fix (the load failure is fixed). Open a **separate**
assessment for the `useZorphy=false → Partial<Product>` assertion failure, since it concerns
the external `zuraffa` dependency or the test expectation, not `zuraffa_flutter`. The PR for
#3 is safe to merge independently of that separate issue.
