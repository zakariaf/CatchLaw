# E11/T02 — Bbox prefilter, ray casting, and holes

| | |
|---|---|
| **Epic** | E11 — Zones and point-in-polygon |
| **Release** | **v2 — deferred.** Not built for v1; see `epics/RELEASES.md` |
| **Branch** | `epic/11-zones` (shared) |
| **Commit** | `feat(rule_engine): match a point to a zone by bbox prefilter then half-open ray casting` |
| **Depends on** | T01 (`ZoneRing`, `LatLon`, `GeometryFailure`) |
| **Size** | L |
| **Spec** | `SPEC.md` §13 ("Indexed bbox prefilter, then ray-casting only on survivors"), §7.1 (`zone.min_lat`/`min_lon`/`max_lat`/`max_lon`, `idx_zone_bbox`, `zone_ring.is_hole`, `zone.zone_kind`), §4.4 (bank / reserve / exclusion overrides) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rules 5 and 6 are the two decisions this task must not re-derive: the specificity ladder is a closed table on `ZoneScope`, and a tie that disagrees is returned rather than broken. Its `references/resolution-algorithm.md` holds the ladder's integers |
| `catchlaw-reference-database` | Rule 11 and the two-database contract: this code receives plain Dart values, so the bbox arrives as four doubles from the `zone` row and never as a drift row |
| `error-handling-typed-results` | Rules 4 and 7: pure logic is total and returns a value for every input; the sealed `ZoneSuggestion` switch has no `default:` |
| `catchlaw-conventions-index` | Rule 6, the one-way layer map, and D-7 — this file produces zone codes and enums, never a sentence |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §13, "Point-in-polygon zone match" | The two-stage shape in one line: indexed bbox prefilter, then ray-casting **only on survivors**, under 100 ms across all bundled zones |
| `SPEC.md` | §7.1, `CREATE TABLE zone` | `min_lat REAL, min_lon REAL, max_lat REAL, max_lon REAL` live on the zone row, and `idx_zone_bbox` is the index over all four |
| `SPEC.md` | §7.1, `CREATE TABLE zone_ring` | `is_hole`, `ring_index`, and the absence of any polygon-grouping column |
| `SPEC.md` | §7.1, `zone.zone_kind` | The closed set `region`/`subzone`/`bank`/`basin`/`reserve`/`exclusion` this task maps onto `ZoneScope` |
| `SPEC.md` | §4.4, "Bank / reserve / exclusion overrides" | Why specificity matters here: an exclusion drawn inside a bank is the case that must not lose |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "Zone ancestry and specificity", "The tie matrix" | exclusion 40 · reserve 30 · bank 20 · subzone 10 · region 0, and the row that says equal specificity plus differing outcomes is returned as an ambiguity |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | rules 5, 6; "A tie is reported, not broken" | Never re-derive specificity from path depth; never `.first` after the sort |
| `.claude/skills/error-handling-typed-results/SKILL.md` | rules 4, 7 | Total pure functions, exhaustive sealed switches |
| `FLUTTER_GUIDE.md` | §2.5 | Where it goes and the zero-Flutter guarantee |
| `epics/DECISIONS.md` | D-7 | The engine returns types; the picker turns a `ZoneSuggestion` into words |
| `epics/CONVENTIONS.md` | §5 | Test naming |

## What this delivers

- `packages/rule_engine/lib/src/geo/zone_bbox.dart` — `ZoneBbox`, a `const` value type over the four
  `zone` columns, with `bool contains(LatLon)`.
- `packages/rule_engine/lib/src/geo/point_in_polygon.dart` — `bool ringContains(ZoneRing ring, LatLon
  point)`, the half-open crossing-number test, and nothing else.
- `packages/rule_engine/lib/src/geo/zone_geometry.dart` — `ZoneGeometry`, holding `zoneCode`, `scope`
  (`ZoneScope`, from E03), `bbox` and `List<ZoneRing> rings`, with `bool contains(LatLon)` implementing
  *inside any outer ring and inside no hole ring*.
- `packages/rule_engine/lib/src/geo/zone_locator.dart` — `ZoneLocator`:
  `List<ZoneGeometry> bboxSurvivors(Iterable<ZoneGeometry>, LatLon)` and
  `ZoneSuggestion locate(Iterable<ZoneGeometry>, LatLon)`, plus the sealed `ZoneSuggestion` family —
  `ZoneMatched(zone, containing)`, `ZoneAmbiguous(zones)`, `NoZoneMatched()`.
- `packages/rule_engine/lib/rule_engine.dart` — four new exports.
- `packages/rule_engine/test/geo/point_in_polygon_test.dart`,
  `packages/rule_engine/test/geo/zone_locator_test.dart`.
- `packages/rule_engine/testing/models/ring_fixtures.dart` gains `kZoneRiasBaixas` (region, 0),
  `kZoneBancoDeCambados` (bank, 20, drawn inside it), `kZoneBancoDoO` (a second bank, 20, overlapping
  the first at one point so the tie case is reachable), `kZoneCambadosExclusion` (exclusion, 40, drawn
  inside the bank), `kZoneWithHole` (one outer ring, one hole), `kZoneTwoOuterRings`, `kBoundaryProbes`
  (the eleven points cases 4–11 probe, so the closed-ring equivalence test can loop them) and
  `CountingZoneGeometry`, a wrapper that counts `contains` calls for test 24.

## Why it is built this way

**Two stages, because the first one is an index and the second one is not.** §13 states the shape
literally: an indexed bbox prefilter, then ray casting only on survivors. The index is `idx_zone_bbox`
over `zone(min_lat, max_lat, min_lon, max_lon)` and lives in SQL — E05/T07's
`ZoneDao.bboxCandidates(lat, lon)` already issues that query and already asserts its query plan. What
this task owns is the invariant on the Dart side: `locate` **never touches a ring for a zone whose bbox
rejects the point**. That is the property the budget rests on, and T03 asserts it with a counting fake
rather than with a comment.

**`bboxSurvivors` re-tests in Dart even though SQL already filtered.** The two are not redundant: the
locator is a pure function the content builder also calls over authored rings with no database anywhere,
and a bbox test is four `double` comparisons against a ring load that is thousands. Keeping the test in
the engine is what lets T03 measure the prefilter and lets E04/E22 assert a zone's stored bbox actually
encloses its own rings.

**The crossing-number test is half-open, and the half is the whole point.** The standard ray cast
(`(yi > y) != (yj > y) && x < (xj-xi)*(y-yi)/(yj-yi) + xi`) gives an answer on the boundary that most
write-ups call "undefined". It is not undefined; it is *asymmetric*, and the asymmetry is what makes
abutting zones tile. With this comparison a point on a ring's **minimum-latitude** edge or
**minimum-longitude** edge is inside, and a point on the **maximum-latitude** or **maximum-longitude**
edge is outside. Two zones sharing a boundary therefore claim a point on that boundary exactly once —
never twice, never neither. Tests 6 to 11 pin all four edges and both diagonal corners, so a refactor
that "tidies" a `>` into a `>=` fails loudly instead of turning a shared coastline into a double claim.

**Holes subtract from the whole zone, because §7.1 gives them nothing smaller to subtract from.**
`zone_ring` carries `ring_index` and `is_hole` and no column saying which outer ring a hole belongs to.
Containment is therefore *inside at least one `is_hole = 0` ring, and inside no `is_hole = 1` ring*. For
every geometry that can actually be authored this is identical to the grouped model — a hole cannot lie
inside two disjoint outer rings — but it is a property of the schema rather than of the algorithm, and it
is stated here so nobody has to rediscover it from a wrong answer. Ring order is irrelevant to the
result, and test 14 proves it by shuffling `ring_index`.

**The ring is closed implicitly.** T01 stores exactly the points the BLOB held, and the Galician
coordinate annexes are printed both with and without a repeated final vertex. The loop wraps from the
last point to the first (`for (var i = 0; i < n; j = i++)`), so a ring with an explicit closing point and
the same ring without one give the same answer — test 12. Normalising in the decoder would have made the
builder's round trip lossy; normalising here would cost a copy of every ring on every query.

**A tie is returned, not broken.** If two zones at the same specificity both contain the point — a
genuine overlap, not a shared edge — `locate` returns `ZoneAmbiguous(zones)`. This is
`catchlaw-rule-engine` rule 6 applied one layer earlier: choosing silently produces a suggestion no
instrument supports, and the picker can show two rows and let the fisher pick the one he is standing in.
Zones at *different* specificities are not a tie: an exclusion drawn inside a bank drawn inside a region
yields `ZoneMatched(zone: exclusion, containing: [region, bank, exclusion])`, ordered ascending, because
§4.4 says an override is an override and `resolution-algorithm.md` fixes the ladder that says so.

**`containing` is not the `zonePath`.** `EvaluationRequest.zonePath` is materialised from
`zone.parent_zone_id` and is a schema fact; `containing` is a geometric coincidence. They agree when the
polygons are drawn correctly and diverge when they are not, and the one that must win is the schema —
otherwise a bank whose ring overruns its region's coastline by fifty metres silently acquires a different
ancestry. T04 builds the `zonePath` from `parent_zone_id`. This task's `containing` list exists so the
picker can show *why* a zone was suggested, and so the content builder can assert the two agree.

**Rejected: the winding-number algorithm.** It is more robust for self-intersecting polygons and it
costs an `atan2`-free but branch-heavier inner loop. Nothing in §8's sources is self-intersecting — these
are coordinate annexes to a published order — and the crossing-number test's boundary asymmetry is a
feature here, not a defect to engineer around. If a bundled ring ever does self-intersect, that is a
content bug for the builder to reject, not an algorithm to swap.

**Rejected: `vector_math`, which `SPEC.md` §10 lists against "Point-in-polygon and bbox maths".** The
inner loop is four `double` comparisons and one division; `Vector2` allocates, and a matrix type buys
nothing. §14's first static check diffs the checked-in direct-dependency allowlist, so an import that
earns nothing still costs an allowlist entry, and `/simplify` would flag it on sight. The epic's Risks
section records this as an open divergence from §10 and names what would resolve it; no task adds the
dependency quietly.

**Rejected: caching decoded rings on the zone.** A `ZoneGeometry` is constructed from rings the caller
already decoded, so there is nothing to cache: rings are loaded only for bbox survivors (T03), which is
a handful per query. A process-lifetime cache of every bundled ring would hold ~3 MB of `double`s
(§8's polygon budget) on a device §13 sizes at 2 GB RAM, to save work that is already not being done.

**Rejected: tolerance-based boundary handling ("within 1 mm of the edge counts as inside").** A tolerance
turns one deterministic answer into a band where two adjacent zones both match, which is the ambiguity
case with extra steps — and the picker already handles a genuine ambiguity honestly. A GPS fix good to
five metres does not need a decoder good to a millimetre.

## Tests first

Write every row before touching `point_in_polygon.dart`. Run them. **They must fail.** The fixtures are
axis-aligned rectangles on purpose: an axis-aligned ring is the one shape where the expected answer on
every edge and every corner can be written down without argument.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ZoneBbox.contains accepts a point inside the box` | centre of `kZoneRiasBaixas` | true | The prefilter's happy path |
| 2 | `ZoneBbox.contains rejects a point north of the box` | lat above `maxLat` | false | The prefilter must actually reject, or every ring is cast on every query |
| 3 | `ZoneBbox.contains accepts a point on the minimum edge` | lat == `minLat` | true | Same half-open convention as the ring test; a bbox that disagrees with its ring drops a legitimate survivor |
| 4 | `ringContains accepts a point in the middle of a rectangle` | centre | true | The baseline crossing count |
| 5 | `ringContains rejects a point outside a rectangle` | well outside | false | The other baseline |
| 6 | `ringContains accepts a point on the minimum-longitude edge` | lon == west edge | true | Half-open toward increasing longitude — pinned so a `<` never becomes `<=` |
| 7 | `ringContains rejects a point on the maximum-longitude edge` | lon == east edge | false | The other half of the same rule; together they make abutting zones tile |
| 8 | `ringContains accepts a point on the minimum-latitude edge` | lat == south edge | true | Half-open toward increasing latitude |
| 9 | `ringContains rejects a point on the maximum-latitude edge` | lat == north edge | false | Completes the four edges |
| 10 | `ringContains accepts the minimum-latitude minimum-longitude vertex` | the SW corner | true | A vertex is where a naive ray cast double-counts; the `>` comparison is what stops it |
| 11 | `ringContains rejects the maximum-latitude maximum-longitude vertex` | the NE corner | false | The diagonally opposite corner must be the opposite answer, or the convention is not a convention |
| 12 | `ringContains gives the same answer for a ring with an explicit closing point` | the same rectangle, first point repeated | identical for all of cases 4–11 | The BLOB may or may not repeat the first vertex; the answer may not depend on that |
| 13 | `ringContains rejects every point of a degenerate collinear ring` | three collinear points | false everywhere tested | A zero-area ring must answer false rather than divide by zero |
| 14 | `ZoneGeometry.contains rejects a point inside a hole` | `kZoneWithHole`, point in the hole | false | Holes subtract; a marine reserve cut out of a bank is exactly this shape |
| 15 | `ZoneGeometry.contains accepts a point inside the outer ring and outside the hole` | same zone, point beside the hole | true | The other half of case 14; a hole that subtracts everything is as wrong as one that subtracts nothing |
| 16 | `ZoneGeometry.contains gives the same answer when ring_index order is reversed` | rings shuffled | identical | §7.1 has no polygon grouping, so the result must not depend on ring order |
| 17 | `ZoneGeometry.contains accepts a point in the second outer ring` | `kZoneTwoOuterRings` | true | A multi-part zone (two rías) is one zone; `any outer` is the contract |
| 18 | `ZoneLocator.bboxSurvivors returns only zones whose bbox contains the point` | 3 zones, 1 containing | 1 | The stage §13 names, in the engine where the content builder can call it too |
| 19 | `ZoneLocator.locate returns the highest-specificity containing zone` | region 0, bank 20, exclusion 40, all containing | `ZoneMatched(zone: exclusion)` | §4.4's overrides. A depth heuristic would rank the bank above the no-take area drawn inside it |
| 20 | `ZoneLocator.locate orders containing ascending by specificity` | the same three | `[region, bank, exclusion]` | The picker shows why a zone was suggested; root-first is the order the fisher reads |
| 21 | `ZoneLocator.locate returns ZoneAmbiguous for two zones at equal specificity` | two banks overlapping at the point | both, no choice made | `catchlaw-rule-engine` rule 6, one layer earlier: a silent pick is a suggestion no instrument supports |
| 22 | `ZoneLocator.locate returns NoZoneMatched when no bbox survives` | point in the Atlantic | `NoZoneMatched` | The Gulf case and the open-sea case; "no match" is a state, never an error |
| 23 | `ZoneLocator.locate returns NoZoneMatched when a bbox survives but no ring contains the point` | point in the bbox corner outside the ring | `NoZoneMatched` | The prefilter is a prefilter, not an answer — a bbox is always bigger than its ring |
| 24 | `ZoneLocator.locate casts no ring for a zone the bbox rejected` | instrumented `ZoneGeometry` counting `contains` calls | count is 0 for rejected zones | The invariant the 100 ms budget rests on, asserted here and measured in T03 |
| 25 | `ZoneLocator.locate is total for a zone carrying no rings` | `has_zone_polygons = 0` shape: bbox present, `rings` empty | `NoZoneMatched` | The Gulf row of §8 reaches this code path; it must answer, not throw |

```dart
// packages/rule_engine/test/geo/point_in_polygon_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/ring_fixtures.dart';

void main() {
  // kRingRiaDeArousa is the axis-aligned rectangle
  // lat 42.48 .. 42.60, lon -8.95 .. -8.80.
  final ring = ZoneRing(ringIndex: 0, isHole: false, points: kRingRiaDeArousa);

  group('ringContains', () {
    test('accepts a point on the minimum-longitude edge', () {
      expect(ringContains(ring, const LatLon(42.54, -8.95)), isTrue,
          reason: 'half-open toward increasing longitude: the west edge belongs to this ring');
    });

    test('rejects a point on the maximum-longitude edge', () {
      expect(ringContains(ring, const LatLon(42.54, -8.80)), isFalse,
          reason: 'the east edge belongs to the neighbour, so a shared boundary is claimed once');
    });

    test('accepts the minimum-latitude minimum-longitude vertex', () {
      expect(ringContains(ring, const LatLon(42.48, -8.95)), isTrue);
    });

    test('rejects the maximum-latitude maximum-longitude vertex', () {
      expect(ringContains(ring, const LatLon(42.60, -8.80)), isFalse);
    });

    test('gives the same answer for a ring with an explicit closing point', () {
      final closed = ZoneRing(
        ringIndex: 0,
        isHole: false,
        points: [...kRingRiaDeArousa, kRingRiaDeArousa.first],
      );
      for (final p in kBoundaryProbes) {
        expect(ringContains(closed, p), ringContains(ring, p), reason: 'probe $p');
      }
    });

    // … one test per remaining row above, one behaviour each
  });
}
```

```dart
// packages/rule_engine/test/geo/zone_locator_test.dart
void main() {
  test('ZoneLocator.locate returns ZoneAmbiguous for two zones at equal specificity', () {
    const point = LatLon(42.52, -8.88);

    final suggestion = const ZoneLocator().locate(
      [kZoneBancoDeCambados, kZoneBancoDoO],
      point,
    );

    switch (suggestion) {
      case ZoneMatched(:final zone):
        fail('two banks at specificity 20 must not be silently resolved to ${zone.zoneCode}');
      case ZoneAmbiguous(:final zones):
        expect(zones.map((z) => z.zoneCode), containsAll(<String>['banco-de-cambados', 'banco-do-o']));
      case NoZoneMatched():
        fail('both zones contain the point');
    }
  });

  test('ZoneLocator.locate casts no ring for a zone the bbox rejected', () {
    final counted = CountingZoneGeometry(kZoneRiasBaixas);

    const ZoneLocator().locate([counted], const LatLon(10.0, 10.0));

    expect(counted.containsCalls, 0,
        reason: 'SPEC 13: ray-casting runs only on bbox survivors — this is the budget');
  });
}
```

**Run:** `cd packages/rule_engine && dart test test/geo/` → 25 failures on the new rows, T01's 19 still
green. If any new one passes now, the test is wrong.

## Implementation outline

1. `zone_bbox.dart`: `final class ZoneBbox` with four `final double`s, a `const` constructor and
   `bool contains(LatLon p) => p.lat >= minLat && p.lat < maxLat && p.lon >= minLon && p.lon < maxLon;`
   — the same half-open convention as the ring, so a bbox never rejects a point its own ring accepts.
2. `point_in_polygon.dart`: one top-level function. The loop is
   `for (var i = 0, j = pts.length - 1; i < pts.length; j = i++)`, and the body is the crossing test
   written out with a comment naming which edge each comparison owns. No early return, no tolerance,
   no `abs()`.
3. `zone_geometry.dart`: `contains` folds twice —
   `rings.where((r) => !r.isHole).any(...) && !rings.where((r) => r.isHole).any(...)` — expressed as one
   pass over `rings` so the hole rings are not walked when no outer ring matched.
4. `zone_locator.dart`: `bboxSurvivors` filters on `bbox.contains`; `locate` calls `contains` on the
   survivors **only**, groups the matches by `scope.specificity`, takes the maximum, and returns
   `ZoneAmbiguous` when that group holds more than one and `ZoneMatched` otherwise, with `containing`
   sorted ascending by specificity.
5. Export from `packages/rule_engine/lib/rule_engine.dart`. Doc comment every public member; the
   half-open convention gets a `///` paragraph on `ringContains`, because it is the thing a reader will
   otherwise assume.
6. Re-run the whole engine suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 25 tests pass, and each failed first.
- [ ] Branch coverage on `packages/rule_engine/lib/src/geo/` is 100%.
- [ ] `ringContains` and `ZoneBbox.contains` use the same half-open convention, and a test asserts a
      point on a shared edge between two abutting zones is claimed exactly once.
- [ ] `locate` never calls `contains` on a zone whose bbox rejected the point — proved by the counting
      fixture, not by inspection.
- [ ] The `ZoneSuggestion` switch has no `default:` arm anywhere, in `lib/` or in `test/`.
- [ ] Specificity is read from `ZoneScope` (E03) and is not re-derived from `zone_kind` strings or from
      path depth (`catchlaw-rule-engine` rule 5).
- [ ] `locate` throws on **no** input — not on an empty candidate list, not on a zone with no rings, not
      on a zone whose rings are all holes. Every one of those returns `NoZoneMatched`.
- [ ] `grep -rn 'vector_math' packages/rule_engine` returns nothing, and
      `packages/rule_engine/pubspec.yaml` gained no dependency.
- [ ] `packages/rule_engine/` still imports no `package:flutter` and no `dart:ui`.

## Gates

```bash
cd packages/rule_engine && dart format --set-exit-if-changed . && dart analyze && dart test
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh  packages/rule_engine/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh  packages/rule_engine/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(rule_engine): match a point to a zone by bbox prefilter then half-open ray casting

SPEC 13 states the shape literally — an indexed bbox prefilter, then
ray-casting only on survivors. The index is idx_zone_bbox and lives in SQL;
what lands here is the invariant that makes the budget hold: locate never
touches a ring for a zone whose bbox rejected the point, and a counting
fixture proves it rather than a comment.

The crossing-number test is half-open, and the half is the point. A point on
a ring's minimum-latitude or minimum-longitude edge is inside; on the
maximum edges it is outside. Two zones sharing a boundary therefore claim a
point on it exactly once — never twice, never neither. All four edges and
both diagonal corners are pinned so a tidied `<` cannot turn a shared
coastline into a double claim.

zone_ring carries is_hole and nothing that says which outer ring a hole
belongs to, so containment is "inside any outer ring and inside no hole
ring", zone-wide and order-independent. Two zones at equal specificity that
both contain the point are returned as ZoneAmbiguous rather than resolved:
catchlaw-rule-engine rule 6, one layer earlier.

Task: E11/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
