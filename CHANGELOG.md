## [7.2.0] - 2026-10-20

### Change
- Release 7.2.0

## [7.1.0] - 2026-10-12

### Changed
- Tracks `zuraffa` core 7.1.0 — `--force`/`--revert` no longer duplicate provider
  members (#1719), VPC usecase references are consistently PascalCase with no
  suffix doubling and dry-run detects existing usecases (#1720), the route-table
  404 probe attaches the route (#1721), plus the "Built with Zuraffa" showcase
  (#1727).
- `zuraffa_ui` bumped to `^0.4.0` (UINode layer; `ShadListSection.sticky`
  opt-out).
- `go_router` bumped to `^18.0.2`, `yaml` to `^3.1.4`, `meta` to `^1.19.0`.
- The dev-only `dependency_overrides` block (`analyzer`, `meta`) is gone. The
  resolution graph now picks `analyzer 14.5.0` without a pin, so the block no
  longer has to be stripped at publish time.

### Fixed
- Corrected the two transported presentation-only VPC tests to the real
  contract (#417/#770): `generateMock` is on by default, so the mock lane is
  emitted and `MockBuilder` scaffolds the `DataSource` interface its mock
  datasource implements. Those three artifacts are now asserted present, while
  the repository / remote-datasource / domain-and-data DI assertions still hold.
  The temporary skip workaround is gone (traced and closed in
  arrrrny/zuraffa#1733; the test fix is arrrrny/zuraffa_flutter#19).

## [7.0.1] - 2026-09-23

### Change
- Release 7.0.1

## [7.0.0] - 2026-09-18

### Change
- Breaking: heavy integrations are now opt-in companion packages (graphql/storage/observability); lean core

## [6.3.0] - 2026-09-14

### Change
- Release 6.3.0

## [6.2.2] - 2026-09-08

### Changed
- Release 6.2.2, synced with `zuraffa` core 6.2.2. `zuraffa` dependency now resolves
  from pub.dev (`^6.2.2`). Dev-only `dependency_overrides` (zuraffa git override) are
  stripped for publishing.

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
