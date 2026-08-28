# Bug Fix PR: Fix VPC tests: resolve package roots from package_config.json

- **Slug**: vpc-tests-cannot-locate-zuraffa-root
- **Opened**: 2026-08-28
- **PR**: 5
- **URL**: https://github.com/arrrrny/zuraffa_flutter/pull/5
- **Branch**: fix/vpc-tests-cannot-locate-zuraffa-root
- **Issue**: 1

Adds a `.dart_tool/package_config.json` resolution strategy to `vpc_test_utils._packageRoot`
so VPC fixture setup locates `zuraffa` (and any pub-cache-installed package) in standalone
checkouts, not just the monorepo. The reported "cannot locate the zuraffa package root"
symptom is gone from all 9 affected files. Verification is `partial`: 3 of those files still
fail for unrelated, pre-existing reasons (zuraffa generated-output assertions + missing
`bin/zfa.dart` CLI); they need their own assessments. PR is safe to merge independently.
