## Summary

`test/vpc/plugins/presenter_usecase_test.dart` failed to **load** with
`Couldn't resolve the package 'test' in 'package:test/test.dart'`, so the whole file was
dead. It imported `package:test/test.dart`, which is **not** a declared dependency of this
package. Every other test imports `package:flutter_test/flutter_test.dart`, which re-exports
the same `setUp` / `tearDown` / `test` / `expect` / `isTrue` / `isFalse` API.

The fix swaps that one import to `package:flutter_test/flutter_test.dart`. The test now
compiles, loads, and runs.

## Changes

| File | Change | Notes |
|------|--------|-------|
| `test/vpc/plugins/presenter_usecase_test.dart` | modified | line 3 import swapped to `package:flutter_test/flutter_test.dart` |

## Local Verification

- `flutter test test/vpc/plugins/presenter_usecase_test.dart` → the load failure is gone; the
  test now runs. See `.specify/bugs/presenter-usecase-test-unresolved-package-test/test.md`.
- **Partial**: one assertion in that file still fails, but it is **unrelated** to this fix. It
  asserts that zuraffa's generated presenter emits `Partial<Product>` when `useZorphy=false`;
  the `PresenterPlugin` lives in the external `zuraffa` dependency, not in `zuraffa_flutter`,
  so that failure is out of scope for this repo/bug and should get its own assessment.

## Assessment

`.specify/bugs/presenter-usecase-test-unresolved-package-test/assessment.md`

Closes #3.
