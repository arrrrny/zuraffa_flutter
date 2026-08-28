# Bug Assessment: VPC generation tests fail — cannot locate the zuraffa package root

- **Slug**: vpc-tests-cannot-locate-zuraffa-root
- **Created**: 2026-08-28
- **Source**: pasted text (flutter test output)
- **Verdict**: valid
- **Severity**: medium

## Report (verbatim or summarized)

From `flutter test`:

```
Bad state: cannot locate the zuraffa package root (CWD=/workspace/zuraffa_flutter)
  test/vpc/vpc_test_utils.dart 67:3                     _packageRoot
  test/vpc/vpc_test_utils.dart 133:20                   writeFlutterPubspec
  test/vpc/<...>_test.dart 33:11                        main.<fn>
```

This error is thrown for every VPC-layer test that builds a Flutter fixture.

## Symptom

All VPC-layer tests that generate a Flutter fixture via `vpc_test_utils.writeFlutterPubspec`
throw `Bad state: cannot locate the zuraffa package root` during setup, instead of
generating code and running assertions. Expected: fixtures are generated and the
generated-output assertions execute.

## Reproduction

1. `flutter test test/vpc/toggle_method_vpc_test.dart` (or any VPC test below).
2. Test setup calls `writeFlutterPubspec` → `_packageRoot('zuraffa')`.
3. `_walkToRoot` walks up from CWD (`/workspace/zuraffa_flutter`) and finds the
   `zuraffa_flutter` pubspec (name `zuraffa_flutter`), not `zuraffa`.
4. The stack-trace strategy (`_stackTraceSourcePath`) rejects pub-cache frames
   because the path contains `/zuraffa-6.0.0/`, not `/zuraffa/` or `/zuraffa_flutter/`.
5. `_packageRoot` throws `StateError: cannot locate the zuraffa package root`.

## Suspected Code Paths

- `test/vpc/vpc_test_utils.dart:67` — `_packageRoot` throws the StateError.
- `test/vpc/vpc_test_utils.dart:133` — `writeFlutterPubspec` calls `_packageRoot('zuraffa')`
  and `_packageRoot('zuraffa_flutter')`.
- `test/vpc/vpc_test_utils.dart` — `_stackTraceSourcePath` only matches paths containing
  `/zuraffa/` or `/zuraffa_flutter/`, so pub-cache installs of `zuraffa` are ignored.

## Root Cause Hypothesis

The VPC fixtures require `zuraffa` to be resolvable as a **local path dependency**
(the monorepo layout where `zuraffa` and `zuraffa_flutter` are sibling packages). In this
environment `zuraffa` is only available from the pub cache, so `_packageRoot('zuraffa')`
cannot find a `pubspec.yaml` whose `name:` is `zuraffa` by walking up from CWD or from
pub-cache stack frames. The helper was written assuming the monorepo layout.
Confidence: high.

## Proposed Remediation

**Preferred**: Make `vpc_test_utils._packageRoot` also resolve a package installed from the
pub cache by reading `.dart_tool/package_config.json` and mapping the package name to its
resolved root URI, instead of only walking the filesystem. This keeps the tests runnable
both in the monorepo and in a standalone checkout.

**Alternatives**:
- Document that VPC tests require the monorepo layout (a path override for `zuraffa` in
  `pubspec.yaml` / `dependency_overrides`), at the cost of not running in CI without it.

**Files likely to change**:
- `test/vpc/vpc_test_utils.dart`

**Tests to add or update**:
- Add a unit test for `_packageRoot` resolving a pub-cache-installed package name.

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

## Risks & Considerations

- Product code is unaffected; this is test-infrastructure only.
- Environment-dependent: passes in the monorepo/CI layout, fails in a standalone checkout.

## Open Questions

- [NEEDS CLARIFICATION: is the monorepo layout an intended hard requirement for VPC tests, or should they run standalone?]
