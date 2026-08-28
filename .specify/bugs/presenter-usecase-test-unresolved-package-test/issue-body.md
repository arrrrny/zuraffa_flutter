## Symptom

`flutter test test/vpc/plugins/presenter_usecase_test.dart` fails to load because it imports
`package:test/test.dart`, which the test runner cannot resolve. Every other test in the
suite imports `package:flutter_test/flutter_test.dart`, which is declared. Expected: the
test loads and runs.

## Reproduction

1. `flutter test test/vpc/plugins/presenter_usecase_test.dart`
2. Import `package:test/test.dart` cannot be resolved → `setUp`/`tearDown`/`test`/`expect`
   are all "not found".

## Suspected Code Paths

- `test/vpc/plugins/presenter_usecase_test.dart:3` — `import 'package:test/test.dart';`
- `pubspec.yaml` `dev_dependencies` — only `flutter_test`, `flutter_lints`, `analyzer`,
  `path` are declared; `test` is not a dependency.

## Root Cause Hypothesis

The test imports the `test` package directly, but `test` is not a dependency of the
package, so the runner cannot resolve it. All sibling tests import `flutter_test`, which is
declared. Confidence: high.

## Severity: medium

One test file cannot run; easy, localized fix.

## Affected test files (1)

- `test/vpc/plugins/presenter_usecase_test.dart`

Assessment: .specify/bugs/presenter-usecase-test-unresolved-package-test/assessment.md
