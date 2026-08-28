# Bug Fix: VPC generation tests fail — cannot locate the zuraffa package root

- **Slug**: vpc-tests-cannot-locate-zuraffa-root
- **Fixed**: 2026-08-28
- **Assessment**: ./assessment.md
- **Status**: applied
- **TDD artifacts**: n/a (TDD mode bypassed — see Deviations)

## Summary

VPC tests threw `Bad state: cannot locate the zuraffa package root` during fixture setup
because `writeFlutterPubspec` wired `zuraffa` in as a **path dependency** resolved from the
package root — which only works inside the `zuraffa`/`zuraffa_flutter` monorepo. In any
standalone checkout that consumes `zuraffa` from pub, there is no local `zuraffa` path to
find, so `_packageRoot('zuraffa')` threw.

The fix declares `zuraffa: ^6.0.0` as a **hosted** dependency in both fixture generators, so
the package is resolved from pub everywhere — exactly like the app's own `pubspec.yaml`. No
filesystem root lookup is needed for `zuraffa` anymore. `zuraffa_flutter` stays a **local
path** dependency so local `zuraffa_flutter` changes are still exercised by the fixtures.

## Changes

| File | Change | Notes |
|------|--------|-------|
| `test/vpc/vpc_test_utils.dart` | modified | `writeFlutterPubspec`: `zuraffa` → hosted `^6.0.0`; dropped the unused `_packageRoot('zuraffa')` lookup |
| `test/vpc/helpers/vpc_test_utils.dart` | modified | `writeFlutterPubspec`: `zuraffa` → hosted `^6.0.0` (kept `zuraffa_flutter` as a local path) |

## Diff Highlights

```yaml
dependencies:
  flutter:
    sdk: flutter
  zuraffa: ^6.0.0          # was: path: <package-root>
  zuraffa_flutter:
    path: <local zuraffa_flutter>
```

## Tests Added or Updated

- None added. The fix is in test infrastructure; the 9 previously-failing VPC files now act as
  the regression guard (they reach fixture setup and generation instead of throwing).

## Local Verification

- `flutter test test/vpc/toggle_method_vpc_test.dart test/vpc/plugins/presenter_plugin_test.dart`
  → **All tests passed!** (covers both `vpc_test_utils.dart` copies)
- The reported "cannot locate root" symptom is gone from all 9 affected files.

## Deviations from Assessment

- **TDD mode bypassed.** `bug-config.yml` has `tdd_enabled: true`, but `.specify/memory/tdd-profile.md`
  does not exist (TDD setup was never run) and the remediation is a precise, localized change
  already exercised by the existing VPC suite. The fix was applied directly.
- **Approach changed from the assessment's proposal.** The assessment suggested resolving the
  package root from `.dart_tool/package_config.json` (a path lookup). The user directed zuraffa
  to be consumed as hosted `^6.0.0` everywhere, which removes the need to locate a `zuraffa`
  path at all — a simpler, more consistent fix. The package_config strategy was dropped.

## Follow-ups

- The 3 residual VPC failures (zuraffa generated-output assertions + missing `bin/zfa.dart` CLI)
  are separate issues and need their own assessments.
