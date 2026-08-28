# Bug Assessment: Test compilation fails — zuraffa-6.0.0 exports missing src/extensions/future_extensions.dart

- **Slug**: zuraffa-export-missing-future-extensions
- **Created**: 2026-08-28
- **Source**: pasted text (flutter test output)
- **Verdict**: valid
- **Severity**: high

## Report (verbatim or summarized)

From `flutter test test/presentation/stateful_controller_test.dart` (and `test/state/widget_test.dart`):

```
/home/agent/.pub-cache/hosted/pub.flutter-io.cn/zuraffa-6.0.0/lib/zuraffa.dart:333:1:
Error: Error when reading
'/home/agent/.pub-cache/hosted/pub.flutter-io.cn/zuraffa-6.0.0/lib/src/extensions/future_extensions.dart':
No such file or directory
  export 'src/extensions/future_extensions.dart';
  ^
```

## Symptom

`flutter test` fails to compile any test that imports `package:zuraffa/zuraffa.dart`
(e.g. `test/presentation/stateful_controller_test.dart`, `test/state/widget_test.dart`)
with the export-resolution error above. Expected: tests compile and run.

## Reproduction

1. `flutter test test/presentation/stateful_controller_test.dart`
2. Compilation resolves `package:zuraffa/zuraffa.dart`.
3. `zuraffa.dart:333` `export 'src/extensions/future_extensions.dart';` fails — the file is absent.

## Suspected Code Paths

- `/home/agent/.pub-cache/hosted/pub.flutter-io.cn/zuraffa-6.0.0/lib/zuraffa.dart:333` —
  `export 'src/extensions/future_extensions.dart';` referencing a missing file.
- The installed package's `lib/src/` contains `cli, commands, config, core, dda, domain,
  generator, graphql, mcp, migration` — but **no `extensions/` directory** at all.

## Root Cause Hypothesis

The installed `zuraffa` 6.0.0 package in the pub cache is missing `lib/src/extensions/`
(including `future_extensions.dart`), so the `export` in `zuraffa.dart` cannot be resolved.
This is most likely a corrupted/partial pub-cache download of `zuraffa` rather than a defect
in `zuraffa_flutter` source. Confidence: medium — needs `dart pub cache repair` / a clean
re-fetch to confirm; if it reproduces on a clean machine, it would indicate a broken
published `zuraffa` artifact (an upstream issue, not in this repo).

## Proposed Remediation

**Preferred**: Re-fetch the dependency (`dart pub cache repair`, or delete the cached
`zuraffa-6.0.0` directory and re-run `flutter pub get`). If the published artifact is
genuinely broken, pin `zuraffa` to a known-good version (or add a `dependency_overrides`
entry) until upstream ships a fix. No source change in `zuraffa_flutter` itself is required
to make the tests compile once the dependency is correct.

**Alternatives**:
- Temporarily depend on `zuraffa` via a git/path reference to a fixed revision.

**Files likely to change**:
- `pubspec.yaml` (version pin / `dependency_overrides` for `zuraffa`), if the artifact is broken.

**Tests to add or update**:
- Ensure CI performs a clean `flutter pub get` (or `dart pub cache repair`) before the test
  step so a corrupt cache is detected early.

## Affected test files (2)

- `test/presentation/stateful_controller_test.dart`
- `test/state/widget_test.dart`

## Risks & Considerations

- Blocks compilation of any test importing `zuraffa` in a broken-cache environment.
- If the published `zuraffa` artifact is truly broken, this is an upstream issue; the
  workaround (version pin) should be removed once upstream is fixed.

## Open Questions

- [NEEDS CLARIFICATION: does a clean `dart pub cache repair` resolve it here, or is the published zuraffa-6.0.0 artifact itself broken?]
