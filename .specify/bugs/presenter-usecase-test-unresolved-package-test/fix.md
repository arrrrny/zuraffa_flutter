# Bug Fix: presenter_usecase_test fails to load — cannot resolve package:test/test.dart

- **Slug**: presenter-usecase-test-unresolved-package-test
- **Fixed**: 2026-08-28
- **Assessment**: ./assessment.md
- **Status**: applied
- **TDD artifacts**: n/a (TDD mode bypassed — see Deviations)

## Summary

Changed the import in `test/vpc/plugins/presenter_usecase_test.dart` from
`package:test/test.dart` to `package:flutter_test/flutter_test.dart`. The `test`
package was never a declared dependency, so the test failed to load; `flutter_test`
is declared and re-exports the same `setUp` / `tearDown` / `test` / `expect` /
`isTrue` / `isFalse` API the test uses.

## Changes

| File | Change | Notes |
|------|--------|-------|
| `test/vpc/plugins/presenter_usecase_test.dart` | modified | line 3 import swapped to `package:flutter_test/flutter_test.dart` |

## Diff Highlights

```dart
- import 'package:test/test.dart';
+ import 'package:flutter_test/flutter_test.dart';
```

## Tests Added or Updated

- `test/vpc/plugins/presenter_usecase_test.dart` itself is the regression guard: it now
  loads and runs. No new test file was needed — the file's existing assertions cover the
  presenter usecase generation behavior.

## Local Verification

- Command: `flutter test test/vpc/plugins/presenter_usecase_test.dart` → see `test.md`.

## Deviations from Assessment

- **TDD mode bypassed.** `bug-config.yml` has `tdd_enabled: true`, but `.specify/memory/tdd-profile.md`
  does not exist (TDD setup was never run), and the remediation is a single, precisely-specified
  import swap already pinned by the existing test. Driving a full red-green TDD loop would add no
  signal here, so the fix was applied directly. The existing test serves as the guard.

## Follow-ups

- None. Consider adding `test` to `dev_dependencies` only if a future test genuinely needs it;
  otherwise `flutter_test` should remain the single test framework for this package.
