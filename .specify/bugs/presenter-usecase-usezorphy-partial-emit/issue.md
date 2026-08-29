# Bug Issue: PresenterPlugin ignores useZorphy=false (emits EntityPatch, not Partial<Entity>)

- **Slug**: presenter-usecase-usezorphy-partial-emit
- **Fetched**: 2026-08-29
- **Issue**: 9
- **URL**: https://github.com/arrrrny/zuraffa_flutter/issues/9
- **State**: closed (closed 2026-08-29 via gh issue close; fix shipped in core zuraffa 6.1.0, zuraffa_flutter master depends on `zuraffa: ^6.1.0` from pub.dev, test green)
- **Severity**: unknown
- **Author**: arrrrny
- **Labels**: (none)

## Body

**Bug**: `test/vpc/plugins/presenter_usecase_test.dart` (`useZorphy=false should emit Partial<Entity>`) fails. Driving core `PresenterPlugin` with `useZorphy: false` and `methods: ['update']` still emits `ProductPatch` (`UpdateParams<String, ProductPatch>`) instead of `Partial<Product>` (`UpdateParams<String, Partial<Product>>`).

**Expected**: `useZorphy=false` emits `Partial<Entity>` for update params.
**Actual**: emits `EntityPatch`; `expect(content.contains('UpdateParams<String, Partial<Product>>'), isTrue)` => Actual: false.

**Root cause**: core zuraffa `PresenterPlugin` does not implement the `useZorphy=false -> Partial<Entity>` path. This is **core generator behavior in `arrrrny/zuraffa`**, NOT fixable in `zuraffa_flutter`. The test was transported from core zuraffa issue #431.

**Action**: fix `src/plugins/presenter/presenter_plugin.dart` in `arrrrny/zuraffa` so `useZorphy=false` emits `Partial<Entity>`; republish. This `zuraffa_flutter` test stays red until then. See `.specify/bugs/presenter-usecase-usezorphy-partial-emit/assessment.md`.

## Comments

None.
