## [6.2.1] - 2026-09-07

### Added
- ZuraffaSkinApp forwards initialRoute (#1165)
- ZuraffaSkinApp — contract-consuming shell (stage 2b of #1111) (#1165)

### Fixed
- Drop the hide workaround — zuraffa core deleted its widget copies (#1179)
- Hide zuraffa-master widget re-exports from the barrel and state test (#1165)
- Resolve zuraffa from pub.dev 6.1.0 and create entity stub in vpc_records_test

### Changed
- Bump v5 references to v6 in README and presenter test
- Adapt README from core zuraffa and fix install

### Chores
- Refresh pubspec.lock for 6.1.0
- Dev pubspec — resolve zuraffa from pub.dev, keep dev overrides

## [6.1.0] - 2026-08-28

### Change
- Release 6.1.0, synced with `zuraffa` core 6.1.0. `zuraffa` dependency now resolves
  from pub.dev (`^6.1.0`). Dev-only `dependency_overrides` (analyzer/meta) are stripped
  for publishing.
