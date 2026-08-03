# E11/T03 — The hundred-millisecond budget

| | |
|---|---|
| **Epic** | E11 — Zones and point-in-polygon |
| **Release** | **v2 — deferred.** Not built for v1; see `epics/RELEASES.md` |
| **Branch** | `epic/11-zones` (shared) |
| **Commit** | `feat(data): assemble the zone lookup and hold it to the 100 ms budget by test` |
| **Depends on** | T02 (`ZoneLocator`, `ZoneGeometry`), E05/T07 (`ZoneDao`), E05/T09 (`ReferenceRepository`, `DataFailure`) |
| **Size** | M |
| **Spec** | `SPEC.md` §13 ("Point-in-polygon zone match — < 100 ms across all bundled zones — Indexed bbox prefilter, then ray-casting only on survivors"), §8 (the polygon byte budget the corpus is sized from), §7.1 (`idx_zone_bbox`), §13 (low-end device: 2 GB RAM, Android 7) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `persistence-drift` | Rules 1, 7 and 8: drift symbols stop at `lib/data/`, the repository owns the cross-table assembly and the row → value-object mapping, and reads are scoped rather than app-wide |
| `catchlaw-reference-database` | Rules 3 and 11: every query here runs on the read-only connection, and the engine receives plain Dart values — a `ZoneGeometry` is built in `data/model/`, never handed a drift row |
| `catchlaw-rule-engine` | Rule 2: the locator is pure and the use-case is the only thing that touches both it and a database |
| `error-handling-typed-results` | Rules 4, 5 and 6: convert at the boundary, log the original `(e, st)` before returning a typed failure, no `default:` on a sealed switch, and no bare catch |
| `catchlaw-conventions-index` | Rule 6, the one-way layer map: `domain/use_cases/` is the only place reference data and the engine meet |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §13, "Point-in-polygon zone match" | The budget and the mechanism, in one row: < 100 ms across all bundled zones, indexed bbox prefilter, ray casting only on survivors |
| `SPEC.md` | §13, "Low-end devices" | 2 GB RAM, Android 7 — the reason no process-lifetime cache of every bundled ring is proposed |
| `SPEC.md` | §8, the three zone-polygon rows | ~1 MB Galicia + ~2 MB Brazil + 0 Gulf: the byte budget the synthetic corpus is sized from |
| `SPEC.md` | §7.1, `idx_zone_bbox` | The index the prefilter rides; the plan assertion is E05/T07's and is not repeated here |
| `.claude/skills/persistence-drift/SKILL.md` | rules 1, 7, 8; "DAO + repository: one transaction, mapped to value objects" | The DAO/repository split and the value-object boundary the mapper enforces |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "Ownership matrix", "The ATTACH ban" | 214 zones in pack `v2026.07.14+3` — the zone count the synthetic corpus is run at — and the rule that the engine takes plain Dart values |
| `.claude/skills/error-handling-typed-results/references/result-failure-spine.md` | "Convert-at-the-boundary" | Log `(e, st)` first, then return a typed, string-free failure |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | rule 2 | Passing a drift row into pure code pins the package to the database package |
| `FLUTTER_GUIDE.md` | §1.4 | Repository vs Service; the repository owns caching and mapping, and a join across two data types goes in a use-case |
| `FLUTTER_GUIDE.md` | §2.5 | Rules 1, 5 and 6: no widget imports `data/`, every repository method returns `Future<Result<T>>` or `Stream<T>`, drift rows never escape `data/` |
| `epics/E05-data-layer/T07-reference-daos.md` | "Why it is built this way", the plan paragraph | The precedent this task extends: assert the property that makes the budget reachable, and do not assert milliseconds that measure the CI runner — with the exception argued below |
| `epics/CONVENTIONS.md` | §7 | A gate that scans an empty tree reports success; the same trap applies to a budget test over an empty corpus |

## What this delivers

- `app/lib/data/model/zone_mapper.dart` — `ZoneGeometry` built from a `zone` row plus its `zone_ring`
  rows, calling T01's `decodeZoneRing`. The only place a `Uint8List` from the BLOB column is
  interpreted.
- `app/lib/data/repositories/reference_repository.dart` gains two methods on the existing abstract
  interface: `Future<Result<List<ZoneSummary>, DataFailure>> zoneBboxCandidates(LatLon point)` and
  `Future<Result<List<ZoneRing>, DataFailure>> zoneRingsFor(String zoneCode)`, implemented in
  `reference_repository_drift.dart` over E05/T07's `ZoneDao.bboxCandidates` and `ZoneDao.ringsFor`, and
  in `reference_repository_fixture.dart` over an in-memory corpus.
- `app/lib/domain/use_cases/locate_zone.dart` — `LocateZone`, taking a `ReferenceRepository` and a
  `ZoneLocator`, with `Future<Result<ZoneLookup, DataFailure>> call(LatLon point)`. This is the only
  code in the app that reads zones and calls the engine in one breath.
- `app/lib/domain/models/zone_lookup.dart` — `ZoneLookup`, an immutable pair of the engine's
  `ZoneSuggestion` and `List<SkippedZone> skipped`, where `SkippedZone(zoneCode, code)` names a zone
  dropped for a malformed ring so it is visible to the caller rather than silently absent.
- `app/testing/fakes/counting_reference_repository.dart` — wraps any `ReferenceRepository` and counts
  `zoneBboxCandidates` and `zoneRingsFor` calls per zone code.
- `app/testing/fixtures/zone_corpus.dart` — `synthesiseZoneCorpus({required int zones, required int
  totalPoints})`, which builds non-overlapping rectangles totalling `totalPoints` vertices.
- `app/test/domain/use_cases/locate_zone_test.dart` — the work-bound tests.
- `app/test/domain/use_cases/locate_zone_budget_test.dart` — the two wall-clock tests.

## Why it is built this way

**A budget is a property of the whole path, so the task that measures it is the task that assembles
it.** `ZoneDao.bboxCandidates` exists (E05/T07), `decodeZoneRing` exists (T01) and `ZoneLocator` exists
(T02); until they are wired there is nothing to time, and wiring them in a later UI task would mean the
first measurement happens after the design is already load-bearing.

**Two assertions, because only one of them is hardware-independent.**

1. **The work bound.** `LocateZone` calls `zoneRingsFor` **once per bbox survivor and never for a zone
   the bbox rejected**, and decodes each survivor's rings exactly once per call. That is deterministic,
   identical on every machine, and it is the failure mode that actually blows the budget: someone
   removes the prefilter, or moves the ring load above the filter for tidiness, and every query starts
   materialising ~3 MB of coordinates. A counting fake proves it.

2. **The wall clock, against §13's own ceiling.** E05/T07 argued — correctly — that
   `expect(elapsed, lessThan(50))` on a CI runner measures the runner. This task takes the ceiling
   anyway, and the reason is the headroom: the bbox prefilter reduces a 214-zone corpus to a handful,
   and the survivors' rings are a few thousand vertices of scalar arithmetic. The realistic cost is two
   orders of magnitude under 100 ms, so the only way this assertion fails on any plausible runner is an
   algorithm that changed shape — the prefilter bypassed, the corpus loaded eagerly, a decode moved
   inside the point loop. It is a shape assertion wearing a stopwatch, and the failure message says so.
   The measurement that means anything about a Snapdragon 665 is E21's, on hardware.

**The corpus is sized from §8's bytes, not from a number somebody liked.** §8 budgets ~1 MB of Galician
zone polygons and ~2 MB of Brazilian ones, and 0 for the Gulf. At 16 bytes per lat/lon pair (two
Float64, T01) that is **~187,500 pairs**. The zone count is 214, which
`catchlaw-reference-database/references/two-database-contract.md` records for pack `v2026.07.14+3`. The
synthetic corpus is run at exactly those two numbers.

**And the real corpus is measured too, with an emptiness guard in front of it.** At this point in the
order only Galicia is authored — E04 seeds it and E22 adds the rest — so the built `reference.db` holds
a smaller zone set than ships. Both tests run: the real one catches an integration mistake the synthetic
one cannot (a wrong column, a missing index, a BLOB that does not decode), and the synthetic one catches
a scaling mistake the real one cannot. Before either asserts a duration, test 6 asserts the corpus is
non-empty and prints its size. `CONVENTIONS.md` §7 names this exact trap for gates — a scan over an
empty tree reports success — and a budget test over zero zones passes in nanoseconds while proving
nothing.

**A malformed ring drops its zone and nothing else.** T01 returns `GeometryFailure` as a value rather
than throwing precisely so this decision is available: if `banco-de-cambados` has a truncated BLOB,
`ria-de-arousa` must still match. `LocateZone` skips the zone, records `SkippedZone(zoneCode, code)` on
the result and logs `(e, st)` locally, and answers over the rest. Failing the whole lookup would turn
one content bug into "no zone anywhere", which on this app is a fisher with no rules at all.

**No cache, deliberately.** The obvious optimisation — decode every bundled ring once at startup and
hold it — would put ~3 MB of `double`s in memory for the life of the process on a device §13 sizes at
2 GB, to avoid work the prefilter already avoids. It would also move the decode onto the launch path,
where §13 gives 1.2 s and `catchlaw-reference-database` rule 2 forbids an await before `runApp`. Rings
are read for survivors only, per query, and the query happens when a fisher presses a button.

**Rejected: a benchmark harness (`package:benchmark_harness`).** It measures throughput over thousands
of iterations, which is the wrong question — §13 asks whether one lookup fits in one interaction. A
median of 50 timed calls after 5 warm-ups answers that, needs no dependency, and does not have to be
excluded from the §14 allowlist diff.

**Rejected: asserting the query plan again here.** E05/T07 already asserts `idx_zone_bbox` is used and
that no `SCAN zone` appears. Re-asserting it would be a second copy of one fact, and the two copies
would disagree the first time the index is renamed.

**Rejected: running the budget test in `integration_test/`.** It needs no device: the whole path is
SQLite plus arithmetic, and `flutter test` runs both. Putting it on a device would make it slow, flaky
and skipped.

## Tests first

Write every row before touching `locate_zone.dart`. Run them. **They must fail** — a use-case that does
not exist cannot load a ring, and a timing test on a missing method cannot pass.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LocateZone loads rings only for zones whose bbox contains the point` | 214-zone synthetic corpus, 1 containing | `zoneRingsFor` called once, for that zone code | The whole budget rests on this; §13 says "only on survivors" and this is the only place it is checkable |
| 2 | `LocateZone loads no rings when no bbox contains the point` | point in the open Atlantic | `zoneRingsFor` never called | The common case at sea outside a bundled jurisdiction, and the cheapest possible answer |
| 3 | `LocateZone issues one bbox query per call` | any point | `zoneBboxCandidates` called once | A per-zone query loop is the other way to blow the budget, and it hides behind a passing behaviour test |
| 4 | `LocateZone decodes each survivor ring exactly once per call` | 1 survivor with 3 rings | 3 decodes | A decode inside the point loop is a 187,500-fold amplification that no behaviour test notices |
| 5 | `LocateZone returns the engine's suggestion unchanged` | survivor containing the point | `ZoneMatched` with that zone code | The use-case composes; it must not re-decide what T02 decided |
| 6 | `the bundled zone corpus holds at least one zone and one ring` | the real built `reference.db` | counts ≥ 1, both printed in the failure message | `CONVENTIONS.md` §7's empty-scan trap, applied to a budget test |
| 7 | `LocateZone completes under 100 ms over the bundled zone corpus` | real `reference.db`, 5 warm-ups then median of 50 | median < 100 ms | §13's ceiling against the data that actually ships today |
| 8 | `LocateZone completes under 100 ms at the SPEC 8 polygon budget of 214 zones and 187,500 points` | synthetic corpus | median < 100 ms | The size the app will ship at once E22 lands, measured before it does |
| 9 | `LocateZone skips a zone whose ring fails to decode and still matches another zone` | 2 zones, 1 with a truncated blob | `ZoneMatched` on the good zone | One content bug must not become "no zone anywhere" |
| 10 | `LocateZone reports the skipped zone's failure code` | the same setup | `SkippedZone('banco-de-cambados', 'geo.ring_byte_length_mismatch')` | A silently absent zone is indistinguishable from a zone that does not contain the point |
| 11 | `LocateZone returns a typed DataFailure when the reference read fails` | fixture repository in its failing env | `Err(DataStoreUnavailable())` | The convert-at-the-boundary rule; a `SqliteException` must not reach a view model |
| 12 | `LocateZone reads no user database` | static | `locate_zone.dart` imports no user DAO, repository or table | Two repositories never call each other (`FLUTTER_GUIDE.md` §2.5 rule 3); a zone lookup has no business near the catch log |

```dart
// app/test/domain/use_cases/locate_zone_test.dart
import 'package:catchlaw/domain/use_cases/locate_zone.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart';

import '../../../testing/fakes/counting_reference_repository.dart';
import '../../../testing/fixtures/zone_corpus.dart';

void main() {
  test('LocateZone loads rings only for zones whose bbox contains the point', () async {
    // SPEC 8: ~3 MB of packed coordinates at 16 bytes per lat/lon pair -> ~187,500 pairs.
    // 214 zones is the count two-database-contract.md records for pack v2026.07.14+3.
    final repository = CountingReferenceRepository(
      synthesiseZoneCorpus(zones: 214, totalPoints: 187500),
    );
    final locate = LocateZone(repository: repository, locator: const ZoneLocator());

    await locate(const LatLon(42.54, -8.88));

    expect(repository.ringsForCalls, hasLength(1),
        reason: 'SPEC 13: ray-casting runs only on bbox survivors, so only a survivor is loaded');
    expect(repository.bboxCandidatesCalls, 1);
  });

  test('LocateZone skips a zone whose ring fails to decode and still matches another zone', () async {
    final repository = CountingReferenceRepository(
      corpusWithTruncatedRing(zoneCode: 'banco-de-cambados'),
    );
    final locate = LocateZone(repository: repository, locator: const ZoneLocator());

    final result = await locate(const LatLon(42.54, -8.88));

    switch (result) {
      case Ok(:final value):
        expect(value.suggestion, isA<ZoneMatched>());
        expect(value.skipped.single.code, 'geo.ring_byte_length_mismatch');
      case Err(:final failure):
        fail('one malformed ring must not fail the whole lookup: ${failure.code}');
    }
  });
}
```

```dart
// app/test/domain/use_cases/locate_zone_budget_test.dart
void main() {
  test('LocateZone completes under 100 ms at the SPEC 8 polygon budget '
      'of 214 zones and 187,500 points', () async {
    final locate = LocateZone(
      repository: ReferenceRepositoryFixture(synthesiseZoneCorpus(zones: 214, totalPoints: 187500)),
      locator: const ZoneLocator(),
    );
    const point = LatLon(42.54, -8.88);

    for (var i = 0; i < 5; i++) {
      await locate(point); // warm-up: first call pays for lazy opens and JIT
    }

    final samples = <int>[];
    for (var i = 0; i < 50; i++) {
      final sw = Stopwatch()..start();
      await locate(point);
      samples.add(sw.elapsedMicroseconds);
    }
    samples.sort();
    final medianMs = samples[samples.length ~/ 2] / 1000;

    expect(medianMs, lessThan(100),
        reason: 'SPEC 13 budgets 100 ms on a Snapdragon 665. This runner is not one, and the '
            'expected cost here is two orders of magnitude lower — so a failure means the '
            'algorithm changed shape (prefilter bypassed, corpus loaded eagerly, decode moved '
            'inside the point loop), not that CI was slow. The device measurement is E21.');
  });
}
```

**Run:** `cd app && flutter test test/domain/use_cases/` → 12 failures. If any passes now, the test is
wrong.

## Implementation outline

1. `zone_mapper.dart`: `ZoneSummary` from a `zone` row (code, `ZoneScope` from `zone_kind`, `ZoneBbox`
   from the four `REAL` columns, `waterType`, `nameKey`, `parentZoneCode`), and
   `List<ZoneRing> ringsFrom(Iterable<ZoneRingRow>)` folding `decodeZoneRing` over the rows in
   `ring_index` order. A `GeometryFailure` becomes a `SkippedZone`, not a throw.
2. Extend the `ReferenceRepository` interface, the drift implementation and the fixture implementation
   together, in that order, so the fixture cannot lag the interface.
3. `locate_zone.dart`: one `call` method —
   `zoneBboxCandidates` → for each survivor `zoneRingsFor` → map → `ZoneLocator.locate`. It holds no
   state, keeps no cache and takes both collaborators by constructor (`FLUTTER_GUIDE.md` §5.2: the
   repository takes no `Ref` and imports no Riverpod; the same is true of a use-case).
4. `counting_reference_repository.dart`: `implements ReferenceRepository`, delegates, records call
   counts and zone codes. `implements`, never `extends`, so a new interface method breaks the build
   (`service-boundary-and-native` rule 7).
5. `zone_corpus.dart`: lay out `zones` non-overlapping rectangles on a grid inside the Galician bbox,
   distributing `totalPoints` vertices evenly, and place one of them over the probe point. Return the
   corpus as decoded `ZoneGeometry` for the fixture repository and as encoded BLOBs (via T01's
   `encodeZoneRing`) for the drift path, so both are exercised.
6. Re-run the whole app suite and the engine suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 tests pass, and each failed first.
- [ ] `zoneRingsFor` is never called for a zone the bbox rejected, proved by count and not by reading.
- [ ] Both budget tests take the median of 50 runs after 5 warm-ups, and both name §13 and the reason
      the failure is a shape failure in their `reason:` string.
- [ ] The emptiness guard runs before the real-corpus budget assertion and prints the zone and ring
      counts it found.
- [ ] `synthesiseZoneCorpus` is called with `zones: 214, totalPoints: 187500`, and the arithmetic
      (~3 MB ÷ 16 bytes per pair) is in a comment beside it.
- [ ] `LocateZone` holds no cache and no mutable field.
- [ ] No `package:drift` symbol appears outside `app/lib/data/`; `zone_mapper.dart` is the only file that
      touches the `coords` bytes.
- [ ] `locate_zone.dart` imports nothing from `data/services/` and nothing from the user database
      (`FLUTTER_GUIDE.md` §2.5 rules 2 and 3).
- [ ] Every failure path logs `(e, st)` before returning; no bare catch; no `default:` on the
      `ZoneSuggestion` or `GeometryFailure` switches.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-drift-confinement.sh       app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh        app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): assemble the zone lookup and hold it to the 100 ms budget by test

A budget is a property of the whole path, so the commit that measures it is
the commit that wires it: ZoneDao.bboxCandidates -> ZoneDao.ringsFor ->
decodeZoneRing -> ZoneLocator.locate, behind one LocateZone use-case.

Two assertions, because only one is hardware-independent. The work bound is
deterministic: rings are loaded once per bbox survivor and never for a zone
the bbox rejected, and each survivor's rings are decoded once per call — a
counting fake proves all three. The wall clock takes SPEC 13's own 100 ms
ceiling over a median of 50 runs, because the prefilter leaves roughly two
orders of magnitude of headroom, so the only realistic failure is an
algorithm that changed shape. The measurement that means something about a
Snapdragon 665 is E21's, on hardware.

The corpus is sized from SPEC 8's bytes — ~3 MB of packed coordinates at 16
bytes per lat/lon pair is ~187,500 pairs — across the 214 zones the
two-database contract records for pack v2026.07.14+3. The real built
reference.db is measured too, behind a guard that asserts the corpus is not
empty first: a budget test over zero zones passes in nanoseconds.

A ring that fails to decode drops its own zone and nothing else, so one
truncated blob in Cambados cannot become "no zone anywhere".

Task: E11/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
