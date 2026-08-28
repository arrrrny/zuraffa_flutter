## Summary

VPC generation tests threw `Bad state: cannot locate the zuraffa package root` during fixture
setup because the fixture wired `zuraffa` in as a **path dependency** resolved from the
package root — which only works inside the `zuraffa`/`zuraffa_flutter` monorepo. In a
standalone checkout that consumes `zuraffa` from pub there is no local `zuraffa` path to find.

The fix declares `zuraffa: ^6.0.0` as a **hosted** dependency in both VPC fixture generators
(`test/vpc/vpc_test_utils.dart` and `test/vpc/helpers/vpc_test_utils.dart`), so the package is
resolved from pub everywhere — exactly like the app's own `pubspec.yaml`. No filesystem root
lookup is needed for `zuraffa` anymore. `zuraffa_flutter` stays a **local path** dependency so
local `zuraffa_flutter` changes are still exercised by the fixtures.

## Changes

| File | Change | Notes |
|------|--------|-------|
| `test/vpc/vpc_test_utils.dart` | modified | `writeFlutterPubspec`: `zuraffa` → hosted `^6.0.0`; dropped the unused `_packageRoot('zuraffa')` lookup |
| `test/vpc/helpers/vpc_test_utils.dart` | modified | `writeFlutterPubspec`: `zuraffa` → hosted `^6.0.0` |

## Local Verification

- `flutter test test/vpc/toggle_method_vpc_test.dart test/vpc/plugins/presenter_plugin_test.dart`
  → all tests pass (covers both `vpc_test_utils.dart` copies).
- The reported "cannot locate root" symptom is gone from all 9 affected VPC files.
- **Partial (pre-existing, out of scope):** 3 of those files still fail for unrelated reasons
  (zuraffa generated-output behavioral assertions + a missing `bin/zfa.dart` CLI). See
  `.specify/bugs/vpc-tests-cannot-locate-zuraffa-root/test.md`.

## Assessment

`.specify/bugs/vpc-tests-cannot-locate-zuraffa-root/assessment.md`

Closes #1.
