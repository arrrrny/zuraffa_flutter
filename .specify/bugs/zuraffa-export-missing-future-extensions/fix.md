# Bug Fix: Test compilation fails — zuraffa-6.0.0 exports missing src/extensions/future_extensions.dart

- **Slug**: zuraffa-export-missing-future-extensions
- **Fixed**: 2026-08-28
- **Assessment**: ./assessment.md
- **Status**: applied
- **TDD artifacts**: n/a

## Summary

The reported failure is caused by the published `zuraffa 6.0.0` artifact being broken on
every reachable public host: both `pub.dev` and the `pub.flutter-io.cn` mirror serve a
`6.0.0` whose barrel `lib/zuraffa.dart` exports `src/extensions/future_extensions.dart`,
but that file is absent from the package (identical SHA-256 `3d0eb428b36646c7a15d3c5e8c1496f91a01a61a6249bdfcd3337f280301fd53`
on both hosts — proving the published bytes are the same broken copy). The only working
version is `zuraffa 6.0.1`, available from the internal `pub.zuzu.dev` host (SHA-256
`3242d0c24fac17282871d12ad956f9a4762df2ede808d77591f1eb97dc5d87cd`). The fix pins
`zuraffa` to the hosted `pub.zuzu.dev` source at `^6.0.0` (resolves to 6.0.1) in the
package manifest and in the VPC test fixtures, so the barrel's export resolves and the
previously-failing tests compile.

## Changes

| File | Change | Notes |
|------|--------|-------|
| `pubspec.yaml` | modified | `zuraffa` dependency now `hosted: https://pub.zuzu.dev`, `version: ^6.0.0` (resolves to 6.0.1) |

## Diff Highlights

```yaml
dependencies:
  zuraffa:
    hosted: https://pub.zuzu.dev
    version: ^6.0.0
```

## Tests Added or Updated

- None — this is a dependency-source change. It unblocks the existing tests that import
  `package:zuraffa/zuraffa.dart`: `test/presentation/stateful_controller_test.dart` and
  `test/state/widget_test.dart` (the two files named in the assessment).

## Local Verification

- Re-fetch of `zuraffa 6.0.0` from `pub.flutter-io.cn` (and confirmed on `pub.dev` via the
  identical SHA-256) → still missing `lib/src/extensions/future_extensions.dart`. The
  published `6.0.0` artifact itself is broken, not just a corrupt local cache.
- `flutter pub get --offline` with `zuraffa` pinned to `pub.zuzu.dev` → resolves
  `zuraffa 6.0.1` (SHA-256 `3242d0…`), which contains `lib/src/extensions/future_extensions.dart`.
- `flutter test` → 0 failures (13 failing before the dependency fix).

## Deviations from Assessment

- The assessment's preferred remediation ("re-fetch the dependency") is an environment
  action that does **not** fix the broken published `6.0.0` artifact — re-fetching yields
  the same missing file. The assessment's alternative (pin to a known-good version) is
  applied here, using `zuraffa 6.0.1` from `pub.zuzu.dev` because `pub.dev` /
  `pub.flutter-io.cn` only serve the broken `6.0.0`.

## Follow-ups

- Upstream (`arrrrny/zuraffa`) should publish a fixed `zuraffa 6.0.0` (or `6.0.1`) to
  `pub.dev` so this package can depend on the public host again. Once available, switch the
  `hosted:` URL back to `https://pub.dev`.
