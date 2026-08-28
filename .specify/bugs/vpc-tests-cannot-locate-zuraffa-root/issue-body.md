## Symptom

All VPC-layer tests that generate a Flutter fixture via `vpc_test_utils.writeFlutterPubspec`
throw `Bad state: cannot locate the zuraffa package root` during setup, instead of
generating code. Expected: fixtures are generated and assertions run.

## Reproduction

1. `flutter test test/vpc/toggle_method_vpc_test.dart`
2. Test setup calls `writeFlutterPubspec` → `_packageRoot('zuraffa')`.
3. `_walkToRoot` walks up from CWD and finds `zuraffa_flutter`'s pubspec (name
   `zuraffa_flutter`), not `zuraffa`.
4. The stack-trace strategy rejects pub-cache frames (path contains `/zuraffa-6.0.0/`, not
   `/zuraffa/`).
5. `_packageRoot` throws `StateError: cannot locate the zuraffa package root`.

## Suspected Code Paths

- `test/vpc/vpc_test_utils.dart:67` — `_packageRoot` throws.
- `test/vpc/vpc_test_utils.dart:133` — `writeFlutterPubspec` calls `_packageRoot('zuraffa')`.
- `test/vpc/vpc_test_utils.dart` — `_stackTraceSourcePath` only matches `/zuraffa/` or
  `/zuraffa_flutter/`, ignoring pub-cache installs.

## Root Cause Hypothesis

The VPC fixtures expect `zuraffa` as a local path dependency (monorepo layout). Here
`zuraffa` is only in the pub cache, so `_packageRoot('zuraffa')` cannot locate a pubspec
named `zuraffa`. Confidence: high.

## Severity: medium

Blocks the VPC generation test suite in non-monorepo environments; product code unaffected.

## Affected test files (9)

- `test/vpc/full_entity_workflow_vpc_test.dart`
- `test/vpc/integration/orchestrator_no_usecase_test.dart`
- `test/vpc/integration/presentation_only_workflow_test.dart`
- `test/vpc/issue_294_entity_without_id_vpc_test.dart`
- `test/vpc/issue_302_toggle_param_collision_vpc_test.dart`
- `test/vpc/orchestrator_no_usecase_vpc_test.dart`
- `test/vpc/presentation_only_workflow_vpc_test.dart`
- `test/vpc/regression/issue_343_custom_view_route_observer_test.dart`
- `test/vpc/toggle_method_vpc_test.dart`

Assessment: .specify/bugs/vpc-tests-cannot-locate-zuraffa-root/assessment.md
