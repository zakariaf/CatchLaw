# E22/T09 — Zone polygons, and where Natural Earth substitutes

| | |
|---|---|
| **Epic** | E22 — Content authoring at scale |
| **Branch** | `epic/22-content/T09-zone-polygons` (cut from a current `main`) |
| **Commit** | `feat(content): author the zone polygons and assert their provenance (A15)` |
| **Depends on** | T04 (the Iberian jurisdictions and their zones), T05 (the Brazilian ones) |
| **Size** | M |
| **Spec** | `SPEC.md` §8 the three zone-polygon rows, §7.1 `zone` and `zone_ring`, §4.4, §13 (point-in-polygon < 100 ms) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rule 12's provenance discipline applied to geometry: a boundary is sourced or it does not exist, and `references/licence-provenance.md`'s carve-out table is what says whether a coordinate annex is covered |
| `catchlaw-rule-engine` | Rule 5 — the specificity ladder is a closed integer table on `ZoneScope`, exclusion 40 · reserve 30 · bank 20 · subzone 10 · region 0 — so an authored `zone_kind` **is** a precedence decision |
| `catchlaw-reference-database` | The read-only asset's shape: `zone_ring.coords` is a packed blob, and a malformed one is a wrong answer rather than a crash |
| `catchlaw-conventions-index` | Invariant 3's neighbourhood — a zone override is *visibly marked as an exception with its own citation* (§4.4) — and rule 9's routing away from E11's runtime algorithm |
| `testing-strategy` | Property-style checks over real geometry: envelope, closure, winding, range. Not a golden, and not a widget test |
| `dependency-hygiene` | Rings are parsed from authored coordinate lists with `dart:typed_data`; a GIS package for four checks is not warranted, and Natural Earth is an input file rather than a dependency |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, "Zone polygons — Galicia" | Coordinate annexes to the Orde, under Art. 13 LPI, ✅ verified, ~1 MB, via the build script |
| `SPEC.md` | §8, "Zone polygons — Brazil" | IBGE malha territorial and ANA Base Hidrográfica are ⚠ **NOT covered by Lei 9.610 art. 8** — cartographic products, not annexes to a portaria — each cleared under its own reuse terms **or** substituted with **Natural Earth (public domain, no attribution required)**; unresolved, Natural Earth is the safe default |
| `SPEC.md` | §8, "Zone polygons — Gulf" | Emirate maritime boundaries are **not published as coordinate polygons**; `has_zone_polygons = 0`; rules apply jurisdiction-wide; **we do not invent boundaries** |
| `SPEC.md` | §7.1, `zone` and `zone_ring` | `geometry_source TEXT -- attribution key; NULL when no polygon`; the four bbox columns and `idx_zone_bbox`; `coords BLOB` as **packed little-endian Float64 [lat,lon] pairs**, with `ring_index`, `is_hole` and `point_count` |
| `SPEC.md` | §4.4 | Bank / reserve / exclusion overrides — Galician shellfish banks, Brazilian dam exclusion radii, Gulf marine reserves — *visibly marked as exceptions with their own citation*; and the no-polygon row |
| `SPEC.md` | §13 | Point-in-polygon < 100 ms across all bundled zones via an **indexed bbox prefilter, then ray-casting only on survivors** — which is why a wrong bbox is a wrong answer, not a slow one |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "The statutory carve-outs, and their edges" | Spain's Art. 13 covers the whole *disposición* including annexes and schedules; Brazil's art. 8 IV covers *os textos* only — the same distinction T04 and T05 use, applied to coordinates |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rule 5 and its anti-pattern | The closed ladder, and why `zoneId.split('/').length` as specificity hands the permissive rule to a fisher standing where the strict one applies |
| `epics/E22-content/T03-gulf-rule-rows-and-verbatim-text.md` | "Why it is built this way" | The Gulf `has_zone_polygons = 0` decision this task turns into an assertion for every jurisdiction |
| `FLUTTER_GUIDE.md` | §6.1, §6.4 | Test naming with receipts, and the budget: geometry validity is pure Dart; the runtime point-in-polygon test belongs to E11 |

## What this delivers

- `content/es-ga/zones.yaml` and `content/es-*/zones.yaml` — the coordinate annexes to each *orde* or
  *orden*, transcribed, with `geometry_source: art13-lpi` and the citation of the annex they came from.
- `content/br*/zones.yaml` — Brazilian administrative and basin boundaries with
  `geometry_source: natural-earth`, plus the dam exclusion radii as `zone_kind: exclusion`.
- `content/shared/geometry_sources.yaml` — the permitted source keys, each with its licence basis and
  its status, and `ibge` and `ana` present as **rejected** entries carrying the reason.
- `tools/content_builder/lib/src/assert/a15_zone_geometry.dart` — `ZoneGeometryAssertion`.
- `tools/content_builder/lib/src/geo/ring.dart` — ring parsing, closure, envelope and the packed
  little-endian Float64 encoding §7.1 specifies.
- `content/ATTRIBUTIONS/geometry.md` — generated: one row per `geometry_source` actually used, with
  its basis, so E18 can state where the boundaries came from even where no attribution is required.
- `tools/content_builder/test/geo/ring_test.dart`, `test/assert/a15_zone_geometry_test.dart`,
  `test/content/zone_corpus_test.dart`.

## Why it is built this way

**Three jurisdictions, three different answers, and only one of them is "draw a boundary".**
`SPEC.md` §8 gives each row its own status and they do not generalise:

| Jurisdiction | Source | Basis | What this task does |
|---|---|---|---|
| Galicia and the other CCAAs | the coordinate annex printed in the order itself | Art. 13 LPI covers the whole *disposición*, annexes included | transcribe the coordinates, cite the annex |
| Brazil | Natural Earth | public domain, no attribution required | substitute; IBGE and ANA are **not** covered by art. 8 and are unresolved |
| Gulf | none exists | — | `has_zone_polygons = 0`, rules jurisdiction-wide, **no boundary invented** |

Encoding that as three prose paragraphs would leave the fourth jurisdiction to guess. It is encoded as
a `geometry_source` allowlist in `content/shared/geometry_sources.yaml`, and A15 fails any zone whose
source is not in it.

**`ibge` and `ana` are rejected by name, with the reason.** §8 marks them ⚠ *NOT covered by Lei 9.610
art. 8 — these are IBGE/ANA cartographic products, not annexes to a portaria*, each needing clearance
under its own reuse terms. They are the obvious datasets: IBGE's malha is the canonical Brazilian
administrative boundary and ANA's is the canonical basin set, and somebody will reach for them. So
they exist in the allowlist file as rejected entries carrying the reason and the condition that would
un-reject them — a written clearance under their own terms — in the same pattern this epic uses for
`--force`, FAOLEX and ASFIS. **Rejected:** leaving them out of the file, which produces a generic
"unknown source" error and no explanation of a licence question that took a paragraph of §8 to state.

**Natural Earth is the safe default, and it is recorded even though it need not be attributed.** §8:
*public domain, no attribution required*. §7.1 gives `zone.geometry_source` as an attribution key
anyway, and the reason to fill it in is provenance rather than obligation — three years from now,
"where did this boundary come from" has to be answerable, and `NULL` answers it only for zones with no
polygon at all. `content/ATTRIBUTIONS/geometry.md` lists the sources actually used; whether S17 renders
a credit for a public-domain dataset is E18's decision, not this task's.

**No jurisdiction gets an invented boundary, and A15 is what makes that structural.** §8's Gulf row
says it in four words — *We do not invent boundaries* — and §4.4 gives the behaviour that replaces
one: rules apply jurisdiction-wide and the picker hides the sub-zone level. A15 asserts the pair in
both directions: `has_zone_polygons = 0` requires zero `zone_ring` rows for that jurisdiction and a
NULL `zone_id` on every rule; `has_zone_polygons = 1` requires at least one zone with rings. The
failure mode this prevents is real and sympathetic — an author with a coastline shapefile and seven
emirates to separate, producing a boundary that is 90 % right and wrong exactly where a fisher is
standing when he checks.

**A stored bbox that does not contain its rings is a wrong answer, not a slow one.** §13's target is
met by an *indexed bbox prefilter, then ray-casting only on survivors*, so a zone whose bbox is too
small is silently never tested and never matches. A15 recomputes the envelope from the rings and
requires the four stored columns to equal it exactly. **Rejected:** authoring the bbox by hand and
checking it loosely — the loose check passes the case it exists to catch.

**The lat/lon order is fixed by §7.1 and checked, because the swap is the classic bug.** The blob is
packed little-endian Float64 **[lat, lon]** pairs. A GeoJSON export is [lon, lat]; transcribing one
into the other puts a Galician ría in the Indian Ocean, and every point-in-polygon test then returns
false with no error anywhere. A15 range-checks latitude to ±90 and longitude to ±180, and additionally
requires every ring to fall inside a per-country sanity envelope declared beside the jurisdiction — so
a swap that happens to stay in range still fails.

**A ring is closed, has at least four points, and a hole is declared.** §7.1 carries `is_hole` and
`point_count` explicitly. Three points is a triangle only if it closes; an unclosed ring makes a
ray-casting implementation give different answers depending on where the ray is cast from. `point_count`
must equal the actual number of pairs in the blob, because E11 will trust it to size a read.

**`zone_kind` is a precedence decision, not a label.** `catchlaw-rule-engine` rule 5: the ladder is a
closed integer table — exclusion 40, reserve 30, bank 20, subzone 10, region 0 — declared once and
never re-derived from path depth. Authoring a Brazilian dam exclusion radius as `zone_kind: subzone`
does not merely mislabel it; it ranks it below a bank drawn around it and hands the permissive rule to
a fisher inside a no-take area. A15 does not check intent, but the corpus test asserts that every zone
whose rule is an override carries an override kind, and `content/AUTHORING.md` states the consequence
in the ladder's own terms.

## Tests first

Write every row before transcribing a coordinate or touching `ring.dart`. Run them.
**They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `Ring.pack encodes little-endian Float64 lat lon pairs` | two points | 32 bytes, lat first | §7.1's stated encoding; E11 decodes it and a byte-order mistake is undetectable at read time |
| 2 | `Ring.pack round-trips through unpack` | a ten-point ring | identical coordinates | The only cheap proof the encoding is symmetrical |
| 3 | `Ring.envelope returns the exact bounding box` | a ring | min/max lat and lon | The value A15 compares the stored bbox against |
| 4 | `ZoneGeometryAssertion reports A15 when the stored bbox does not contain the ring` | bbox one degree too small | one `A15` naming the zone | §13's prefilter silently drops the zone; there is no error to notice |
| 5 | `ZoneGeometryAssertion reports A15 when the stored bbox is larger than the envelope` | bbox padded | one `A15` | A padded bbox costs ray-casting on every near miss and hides a transcription error |
| 6 | `ZoneGeometryAssertion reports A15 when a ring is not closed` | first point ≠ last | one `A15` | Ray casting gives different answers by ray direction on an open ring |
| 7 | `ZoneGeometryAssertion reports A15 when a ring has fewer than four points` | three pairs | one `A15` | A closed polygon needs three distinct vertices plus the repeat |
| 8 | `ZoneGeometryAssertion reports A15 when point_count disagrees with the blob` | count 10, blob 9 | one `A15` | E11 sizes its read from the column and would read past the end or drop a vertex |
| 9 | `ZoneGeometryAssertion reports A15 for a latitude outside ±90` | `lat: 91` | one `A15` | The lat/lon swap, in its detectable form |
| 10 | `ZoneGeometryAssertion reports A15 when a ring falls outside its country envelope` | Galician zone at 12°N | one `A15` naming the jurisdiction | The swap that stays in range — a ría in the Indian Ocean passes every other check |
| 11 | `ZoneGeometryAssertion reports A15 for a geometry_source outside the allowlist` | `geometry_source: osm` | one `A15` | Silence is not permission for geometry either |
| 12 | `ZoneGeometryAssertion rejects geometry_source $value by name` (loop over `ibge`, `ana`) | `$value` | one `A15` quoting "not covered by Lei 9.610 art. 8" | §8's ⚠; these are the obvious datasets and the message has to carry the argument |
| 13 | `ZoneGeometryAssertion accepts geometry_source natural-earth` | `natural-earth` | no failures | §8's safe default for Brazil |
| 14 | `ZoneGeometryAssertion accepts geometry_source art13-lpi with an annex citation` | Galician zone | no failures | Art. 13 covers the annex; the citation is what says which annex |
| 15 | `ZoneGeometryAssertion reports A15 when an art13-lpi zone cites no annex` | source set, `citation_id` absent | one `A15` | The carve-out attaches to a *disposición*; a coordinate list with no instrument is not covered by anything |
| 16 | `ZoneGeometryAssertion reports A15 when has_zone_polygons is 0 and a ring exists` | Gulf jurisdiction with a ring | one `A15` | The invented boundary, caught structurally rather than by review |
| 17 | `ZoneGeometryAssertion reports A15 when has_zone_polygons is 0 and a rule names a zone` | Gulf rule with `zone_id` | one `A15` | The other half: a zone reference with no geometry behind it |
| 18 | `ZoneGeometryAssertion reports A15 when has_zone_polygons is 1 and no zone has a ring` | flag set, no rings | one `A15` | S9 offers a sub-zone level that resolves nothing |
| 19 | `Zone corpus declares has_zone_polygons 0 for every Gulf jurisdiction` (loop over the Gulf codes) | `jurisdiction.yaml` | `0` | §8 and §4.4, asserted against the real corpus after T03 |
| 20 | `Zone corpus sources every Brazilian polygon from natural-earth` | `content/br*/zones.yaml` | every `geometry_source` is `natural-earth` | Until IBGE or ANA is cleared in writing, the safe default is the only default |
| 21 | `Zone corpus gives every override zone an override kind` | bank, reserve and exclusion zones | `zone_kind` in `bank`, `reserve`, `exclusion` | Rule 5's ladder; a mislabelled exclusion ranks below the bank drawn around it |

```dart
// tools/content_builder/test/assert/a15_zone_geometry_test.dart
import 'package:content_builder/src/assert/a15_zone_geometry.dart';
import 'package:content_builder/testing/fixtures/zone_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('ZoneGeometryAssertion', () {
    test('reports A15 when the stored bbox does not contain the ring', () {
      final source = contentSourceWithZone(bbox: kTooSmallBbox, ring: kRiaRing);
      final failures = const ZoneGeometryAssertion().run(source).toList();

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A15');
      expect(failures.single.message, contains('bbox'));
    });

    for (final value in const ['ibge', 'ana']) {
      test('rejects geometry_source $value by name', () {
        final source = contentSourceWithZone(geometrySource: value, ring: kBasinRing);

        expect(
          const ZoneGeometryAssertion().run(source).single.message,
          contains('not covered by Lei 9.610 art. 8'),
        );
      });
    }

    test('reports A15 when has_zone_polygons is 0 and a ring exists', () {
      final source = contentSourceWithZone(jurisdiction: 'AE-RK', hasZonePolygons: 0, ring: kInventedRing);

      expect(const ZoneGeometryAssertion().run(source).single.message, contains('AE-RK'));
    });

    // … one test per row above, one behaviour each
  });
}
```

```dart
// tools/content_builder/test/geo/ring_test.dart
import 'dart:typed_data';
import 'package:content_builder/src/geo/ring.dart';
import 'package:test/test.dart';

void main() {
  group('Ring', () {
    test('.pack encodes little-endian Float64 lat lon pairs', () {
      final bytes = Ring.pack(const [(42.6, -8.9), (42.7, -8.8)]);
      final view = ByteData.sublistView(bytes);

      expect(bytes, hasLength(32));
      expect(view.getFloat64(0, Endian.little), 42.6);
      expect(view.getFloat64(8, Endian.little), -8.9);
    });

    test('.envelope returns the exact bounding box', () {
      expect(
        Ring.envelope(const [(42.6, -8.9), (42.7, -8.8), (42.6, -8.9)]),
        const (minLat: 42.6, maxLat: 42.7, minLon: -8.9, maxLon: -8.8),
      );
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/geo/ test/assert/a15_zone_geometry_test.dart
test/content/zone_corpus_test.dart)` → 21 failures. Case 19 will pass early because T03 already
shipped `has_zone_polygons = 0` for the Gulf — that is the correct state and the test exists to keep
it, so say so in the commit body rather than weakening it into a failure.

## Implementation outline

1. `Ring` — parse authored coordinate lists, close-check, envelope, and pack to the §7.1 encoding with
   `ByteData` and `Endian.little`, explicitly, never the platform default.
2. `content/shared/geometry_sources.yaml` — `art13-lpi`, `natural-earth`, `originated` as permitted;
   `ibge` and `ana` as rejected, each with the §8 reason and the condition that would un-reject it.
3. `ZoneGeometryAssertion` — source allowlist, annex-citation requirement for `art13-lpi`, ring
   validity, envelope equality, coordinate range, the per-country sanity envelope, and the three
   `has_zone_polygons` consistency rules.
4. Declare the per-country sanity envelopes beside the jurisdiction entries, wide enough that a real
   boundary never trips them and tight enough that a lat/lon swap always does.
5. Register after A14. Add A15 to `content/README.md`'s assertion list.
6. **Then transcribe the geometry**: Galician and CCAA coordinate annexes from the orders themselves,
   each zone citing the annex it came from; Brazilian administrative and basin boundaries from Natural
   Earth; dam exclusion radii as `zone_kind: exclusion` with their own citation, per §4.4's
   requirement that an override is visibly marked as an exception.
7. Leave the Gulf alone. `has_zone_polygons = 0`, no `zones.yaml` beyond the jurisdiction row, and
   `content/AUTHORING.md` records why, so the next author does not read the absence as an omission.
8. Emit `content/ATTRIBUTIONS/geometry.md` from the sources actually used.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 21 rows pass, and each failed first except case 19, whose exception is stated in the commit
      body.
- [ ] 100 % branch coverage on `a15_zone_geometry.dart` and `ring.dart`, including both directions of
      the `has_zone_polygons` consistency rule.
- [ ] Every stored bbox equals the exact envelope of its zone's rings; every ring is closed, has ≥ 4
      points, and its `point_count` matches its blob.
- [ ] Every `geometry_source` is in the allowlist; no zone uses `ibge` or `ana`; every `art13-lpi`
      zone cites the annex it was transcribed from.
- [ ] Every Gulf jurisdiction has `has_zone_polygons = 0`, zero `zone_ring` rows and no rule naming a
      zone.
- [ ] Every Brazilian polygon is `natural-earth`, and the IBGE/ANA question is written into
      `content/AUTHORING.md` with what a clearance would have to say.
- [ ] Every bank, reserve and exclusion carries the matching `zone_kind` and its own citation.
- [ ] `content/ATTRIBUTIONS/geometry.md` is generated, committed, and regenerates with no diff.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
dart run content_builder:build --in content/ --out app/assets/db/reference.db \
  --build-date "$(date -u +%F)" --generator-commit "$(git rev-parse --short HEAD)" --check
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
```

The rule-engine gate runs because `zone_kind` feeds the specificity ladder: if this task pushed a new
kind into the engine's closed table to fit an authored zone, that is where it shows.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content): author the zone polygons and assert their provenance (A15)

SPEC.md §8 gives the three jurisdictions three different answers and they do
not generalise. Galicia and the other CCAAs print coordinate annexes inside the
order itself, and Art. 13 LPI covers the whole disposición including annexes,
so the coordinates are transcribed and cite the annex. Brazil's IBGE and ANA
products are cartographic works, not annexes to a portaria, and art. 8 IV does
not cover them — so Natural Earth, public domain and requiring no attribution,
is the safe default. The Gulf publishes no coordinate polygons at all, so
has_zone_polygons is 0, rules apply jurisdiction-wide, and we do not invent
boundaries.

ibge and ana are present in the allowlist file as rejected entries carrying the
reason and the condition that would un-reject them. They are the canonical
Brazilian datasets and somebody will reach for them; a generic "unknown source"
error would throw away a licence question that took a paragraph of §8 to state.

A15 makes the no-invented-boundary rule structural rather than editorial:
has_zone_polygons = 0 requires zero rings and a NULL zone_id on every rule, and
= 1 requires at least one zone with rings. The failure it prevents is
sympathetic — an author with a coastline shapefile and seven emirates to
separate, drawing a boundary that is 90 % right and wrong exactly where a fisher
is standing.

The stored bbox must equal the exact envelope of the rings. §13 meets its
100 ms target with an indexed bbox prefilter and ray casting only on survivors,
so a bbox one degree too small means the zone is never tested and never matches,
with no error anywhere. Coordinates are packed little-endian Float64 [lat, lon]
per §7.1 and are range-checked against a per-country envelope, because a
GeoJSON [lon, lat] transcription puts a Galician ría in the Indian Ocean and
every subsequent test returns false quietly.

Task: E22/T09
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
