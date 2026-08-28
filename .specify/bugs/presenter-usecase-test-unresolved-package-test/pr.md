# Bug Fix PR: Fix presenter_usecase_test: use flutter_test instead of unresolved package:test

- **Slug**: presenter-usecase-test-unresolved-package-test
- **Opened**: 2026-08-28
- **PR**: 4
- **URL**: https://github.com/arrrrny/zuraffa_flutter/pull/4
- **Branch**: fix/presenter-usecase-test-unresolved-package-test
- **Issue**: 3

Single-import fix so `test/vpc/plugins/presenter_usecase_test.dart` loads and runs. The
reported load failure (`package:test` unresolved) is resolved. Verification is `partial`:
one unrelated assertion (zuraffa-generated `Partial<Product>` output) still fails and concerns
the external `zuraffa` dependency, not this fix — it needs its own assessment. PR is safe to
merge independently.
