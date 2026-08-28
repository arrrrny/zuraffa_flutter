# Bug Issue: presenter_usecase_test fails to load — cannot resolve package:test/test.dart

- **Slug**: presenter-usecase-test-unresolved-package-test
- **Reported**: 2026-08-28
- **Issue**: 3
- **URL**: https://github.com/arrrrny/zuraffa_flutter/issues/3
- **Severity**: medium

Filed GitHub issue for `test/vpc/plugins/presenter_usecase_test.dart` failing to load because it imports `package:test/test.dart`, which is not a declared dependency (all other tests use `flutter_test`). `severity:medium` label dropped (does not exist on repo); only `bug` applied.
