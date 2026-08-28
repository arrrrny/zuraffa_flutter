# Bug Assessment: issue_343 regression test invokes bin/zfa.dart CLI absent in standalone package

- **Slug**: vpc-issue343-zfa-cli-missing
- **Created**: 2026-08-28
- **Source**: pasted text (flutter test failure)
- **Verdict**: valid
- **Severity**: low

## Report (verbatim or summarized)

`flutter test` failure:

```
test/vpc/regression/issue_343_custom_view_route_observer_test.dart:
  issue #343 — custom view constructor must not forward routeObserver
  `zfa view custom` (stateful) generates a compiling view
    exitCode != 0 (bin/zfa.dart missing)
```

## Symptom

The first sub-test of the issue #343 regression test runs `dart bin/zfa.dart view custom Splash` via `Process.run`. This standalone `zuraffa_flutter` package has no `bin/zfa.dart` (the `zfa` CLI lives in the core `arrrrny/zuraffa` monorepo root). The test therefore fails because the CLI binary does not exist.

## Reproduction

1. `cd /workspace/zuraffa_flutter`
2. `flutter test test/vpc/regression/issue_343_custom_view_route_observer_test.dart`
3. The CLI-invocation sub-test fails (no `bin/zfa.dart`); the two non-CLI sub-tests (custom capability + CleanView `routeObserver`) run fine.

## Suspected Code Paths

- `test/vpc/regression/issue_343_custom_view_route_observer_test.dart:40-95` — `_resolveZfaRoot` walks up from CWD looking for `bin/zfa.dart`; in a standalone checkout it never finds it and falls back to CWD, so `_dartZfaArgs` points at a non-existent binary.
- Root cause: the test was transported from core zuraffa (issue #343) and assumes the monorepo layout.

## Root Cause Hypothesis

Monorepo assumption baked into a transported test. The CLI-driven sub-test cannot run in `zuraffa_flutter` because the `zfa` executable is not part of this package. The actual regression coverage (custom views must not forward `routeObserver`) is fully exercisable via `ViewPlugin`/`CustomViewCapability` directly, which the other two sub-tests already do. Confidence: high.

## Proposed Remediation

**Preferred**: Guard the CLI-invocation sub-test so it `markTestSkipped` when `bin/zfa.dart` is absent (i.e. when `_resolveZfaRoot` did not actually locate the CLI). This keeps the suite green in the standalone package while preserving the real regression coverage from the two `ViewPlugin`/`CustomViewCapability` sub-tests, and still runs the CLI path unchanged when the test is executed inside the core zuraffa monorepo (where `bin/zfa.dart` exists).

**Alternatives**:
- Delete the CLI sub-test entirely. Rejected: it still provides value inside the core zuraffa repo and is a faithful transport of issue #343.

**Files likely to change**:
- `test/vpc/regression/issue_343_custom_view_route_observer_test.dart`

**Tests to add or update**:
- Add a guard/`markTestSkipped` around the `zfa view custom` sub-test.

## Risks & Considerations

- None beyond test-only change. The `routeObserver` regression is still covered by the two non-CLI sub-tests.

## Open Questions

- None.
