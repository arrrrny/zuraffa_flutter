# Bug Issue: VPC generation tests fail — cannot locate the zuraffa package root

- **Slug**: vpc-tests-cannot-locate-zuraffa-root
- **Reported**: 2026-08-28
- **Issue**: 1
- **URL**: https://github.com/arrrrny/zuraffa_flutter/issues/1
- **Severity**: medium

Filed GitHub issue covering all 9 VPC-layer tests that throw `cannot locate the zuraffa package root` during fixture setup (test-infra expects `zuraffa` as a path dependency; only in pub cache here). `severity:medium` label was dropped because it does not exist on the repo; only `bug` was applied.
