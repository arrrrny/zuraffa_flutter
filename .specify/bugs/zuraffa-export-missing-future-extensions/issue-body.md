## Symptom

`flutter test` fails to compile any test that imports `package:zuraffa/zuraffa.dart`
(e.g. `test/presentation/stateful_controller_test.dart`, `test/state/widget_test.dart`)
with an export-resolution error. Expected: tests compile and run.

## Reproduction

1. `flutter test test/presentation/stateful_controller_test.dart`
2. Compilation resolves `package:zuraffa/zuraffa.dart`.
3. `zuraffa.dart:333` `export 'src/extensions/future_extensions.dart';` fails — the file is absent.

## Suspected Code Paths

- `.../zuraffa-6.0.0/lib/zuraffa.dart:333` — `export 'src/extensions/future_extensions.dart';`
  referencing a missing file.
- The installed package's `lib/src/` has `cli, commands, config, core, dda, domain,
  generator, graphql, mcp, migration` — but **no `extensions/` directory**.

## Root Cause Hypothesis

The installed `zuraffa` 6.0.0 package in the pub cache is missing `lib/src/extensions/`
(including `future_extensions.dart`), so the `export` in `zuraffa.dart` cannot be resolved.
Most likely a corrupted/partial pub-cache download rather than a `zuraffa_flutter` defect.
Confidence: medium (needs `dart pub cache repair` / clean re-fetch to confirm).

## Severity: high

Blocks compilation of any test importing zuraffa in a broken-cache environment.

## Affected test files (2)

- `test/presentation/stateful_controller_test.dart`
- `test/state/widget_test.dart`

Assessment: .specify/bugs/zuraffa-export-missing-future-extensions/assessment.md
