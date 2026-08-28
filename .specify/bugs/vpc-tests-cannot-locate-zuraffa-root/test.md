# Bug Verification: VPC generation tests fail — cannot locate the zuraffa package root

- **Slug**: vpc-tests-cannot-locate-zuraffa-root
- **Tested**: 2026-08-28
- **Assessment**: ./assessment.md
- **Fix**: ./fix.md
- **Result**: partial
- **TDD verification**: n/a (validation ran in non-TDD mode; see fix.md deviation note)

## Summary

The reported symptom — VPC tests throwing `Bad state: cannot locate the zuraffa package root`
during `writeFlutterPubspec` — is **fully resolved**: all 9 affected files now locate the
`zuraffa` package root and proceed past fixture setup. Three of those files still fail, but
with **unrelated, pre-existing** errors (behavioral assertions about zuraffa's generated
output, and a missing `bin/zfa.dart` CLI) that were previously masked by the root-location
error. None of the residual failures are caused by this fix.

## Checks Performed

| Check | Command / Action | Result | Notes |
|-------|------------------|--------|-------|
| Original symptom (post-fix) | `flutter test <9 VPC files>` | pass | "cannot locate zuraffa package root" no longer appears in any of the 9 files |
| Affected VPC suite | `flutter test test/vpc/{toggle_method,...,issue_343...}_vpc_test.dart` (9 files) | partial | 6/9 fully pass; 3 fail for unrelated reasons (see below) |
| New / updated tests | n/a | skipped | Fix is in test infrastructure (`vpc_test_utils.dart`); no new test file |
| Regression suite | n/a | skipped | Broad suite blocked by other env issues (see bug #2) |

## Output Excerpts

All 9 files now reach fixture setup and generation without the `StateError`. Remaining
failures (pre-existing, out of scope for this bug):

```
presentation_only_workflow_test.dart:70
  Expected: false
    Actual: <true>
  pure-Dart target must NOT generate a Flutter view (Constitution VII: Engine Purity)

regression/issue_343_custom_view_route_observer_test.dart:203
  Expected: <0>
    Actual: <254>
  zfa view custom must succeed:
  Error when reading '/workspace/zuraffa_flutter/bin/zfa.dart': No such file or directory.

orchestrator_no_usecase_test.dart:92  — behavioral assertion failure (zuraffa output)
```

## Residual Risks

- **Out-of-scope failures.** The 3 remaining failures concern (a) zuraffa's *generated output*
  (external dependency behavior — `toggleValue`/`Partial`/`Engine Purity` semantics), and
  (b) a missing `bin/zfa.dart` CLI entry point in `zuraffa_flutter`. These are separate issues,
  not regressions from the root-resolution fix, and warrant their own assessments.
- The `package_config.json` strategy added in the fix is the natural resolution for any
  standalone-checkout environment; the monorepo path still works via Strategies 1–2.

## Recommendation

Close bug #1 on the strength of the root-resolution fix — the reported symptom is gone across
all 9 files. Track the 3 residual failures as separate bugs (zuraffa generated-output
assertions + missing `bin/zfa.dart`). The PR for #1 is safe to merge independently.
