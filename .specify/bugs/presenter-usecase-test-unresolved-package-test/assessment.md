# Bug Assessment: presenter_usecase_test fails to load — cannot resolve package:test/test.dart

- **Slug**: presenter-usecase-test-unresolved-package-test
- **Created**: 2026-08-28
- **Source**: pasted text (flutter test output)
- **Verdict**: valid
- **Severity**: medium

## Report (verbatim or summarized)

From `flutter test test/vpc/plugins/presenter_usecase_test.dart`:

```
Error: Couldn't resolve the package 'test' in 'package:test/test.dart'.
  test/vpc/plugins/presenter_usecase_test.dart:3:8: Error: Not found: 'package:test/test.dart'
  import 'package:test/test.dart';
         ^
  test/vpc/plugins/presenter_usecase_test.dart:12:3: Error: Method not found: 'setUp'.
  ...
```

## Symptom

`flutter test test/vpc/plugins/presenter_usecase_test.dart` fails to load because it
imports `package:test/test.dart`, which the test runner cannot resolve. Every other test in
the suite imports `package:flutter_test/flutter_test.dart`, which is declared. Expected:
the test loads and runs.

## Reproduction

1. `flutter test test/vpc/plugins/presenter_usecase_test.dart`
2. Import `package:test/test.dart` cannot be resolved → `setUp`/`tearDown`/`test`/`expect`
   are all "not found".

## Suspected Code Paths

- `test/vpc/plugins/presenter_usecase_test.dart:3` — `import 'package:test/test.dart';`
- `pubspec.yaml` `dev_dependencies` — only `flutter_test`, `flutter_lints`, `analyzer`,
  `path` are declared; the `test` package is **not** a dependency.

## Root Cause Hypothesis

The test imports the `test` package directly, but `test` is not a (dev_)dependency of the
package, so the test runner cannot resolve it. All sibling tests import
`package:flutter_test/flutter_test.dart`, which is declared. Confidence: high.

## Proposed Remediation

**Preferred**: Change the import in `test/vpc/plugins/presenter_usecase_test.dart` from
`package:test/test.dart` to `package:flutter_test/flutter_test.dart` to match the rest of
the suite (the APIs used — `setUp`, `tearDown`, `test`, `expect`, `isTrue`, `isFalse` —
are all available from `flutter_test`).

**Alternatives**:
- Add `test: ^1.0.0` to `dev_dependencies` in `pubspec.yaml` and run `flutter pub get`.

**Files likely to change**:
- `test/vpc/plugins/presenter_usecase_test.dart` (import line)

**Tests to add or update**:
- The file itself becomes the regression guard once it loads and runs.

## Affected test files (1)

- `test/vpc/plugins/presenter_usecase_test.dart`

## Risks & Considerations

- Trivial, localized fix; no API breakage or migration risk.
- If choosing the `flutter_test` import, confirm no `test`-only API is used (it is not, per
  the error list).

## Open Questions

- None.
