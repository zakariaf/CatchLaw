# E11 — Zones and point-in-polygon

| | |
|---|---|
| **Branch** | `epic/11-zones` |
| **After** | E05 merged (hard dependency); in the published order the branch is cut once E10 has merged |
| **Tasks** | 8 |
| **Spec** | `SPEC.md` §4.4 in full, §6 S9, §7.1 (`zone`, `zone_ring`), §8 (the four polygon rows, including the Gulf row), §11 (single-shot GPS, no background location), §13 (< 100 ms point-in-polygon) |
| **Guide** | `FLUTTER_GUIDE.md` Part 1.4, 1.5, 5.2 |
| **Packages** | `packages/rule_engine/` (T01–T03), `app/` (T04–T08) |
| **Decisions** | D-1 (paths), D-3 (six locales), D-5 (Riverpod 3.4.1, drift 2.34.2), D-7 (no sentence in the engine), D-8 (the directional-geometry grep gate) |

## What this epic achieves

When this merges the app knows where the rules come from. A fisher opens S9, drills country → region →
sub-zone, stars the two or three grounds he actually works, and switches between them in two taps; the
species he was looking at is re-evaluated against the new zone before he can look up. He may instead
press **Use my location**, which takes one GPS fix, matches it on-device against the bundled rings by
bbox prefilter and then ray casting, and **offers** a zone — it never switches for him. If he denies the
permission, the picker is exactly as usable as it was and one line says why nothing was suggested.
Where an authority publishes no coordinate boundaries the picker shows no sub-zone level at all and
states that the rules apply across the whole jurisdiction, because we do not draw boundaries a decision
never printed. Freshwater zones stop showing marine rules. From here E12 can put a zone chip on Check
and E13 can stamp a zone code on every catch.

## Where we are now

The hard dependency is **E05**: T01 decodes bytes that only `reference.db` holds, and T04 reads tables
only the data layer can reach. In the published order the branch is cut once **E10** has merged, so
`main` also carries E06–E10 and the UI half of this epic has themes, ARB wiring and a result screen to
land against. What already exists and is used here:

- **E02, E03** — `packages/rule_engine/`: the §7.3 resolution algorithm, the sealed `Verdict`/`Finding`
  types with their required `Citation`, the specificity ladder, and
  `packages/rule_engine/lib/src/failure.dart` — the `Result`/`Failure` spine T01's geometry failures
  join. `EvaluationRequest` already carries `waterType` and `zonePath`; nothing yet fills them from a
  user choice.
- **E04** — `tools/content_builder/`, which writes `zone`, `zone_ring` and the Galician coordinate
  annexes into `reference.db`. It is the only producer of the packed BLOB T01 reads.
- **E05** — `app/lib/data/`: `ZoneDao` with `byJurisdiction(int)`, `byCode(int, String)`,
  `bboxCandidates(double lat, double lon)` and `ringsFor(int zoneId)`; `SavedZoneDao` with
  `watchAll()`, `save(...)`, `remove(int)`, `reorder(...)`; `UserProfileDao` with `watchProfile()` and
  `updateProfile(...)`; `AppMetaDao` with `read`/`write`/`readAll`; `ReferenceRepository` and
  `SettingsRepository` behind abstract interfaces with fakes under `app/testing/fakes/`.
  `ZoneDao.ringsFor` returns `coords` as raw bytes and deliberately does not interpret them — E05/T07's
  own definition of done says the Float64 unpacking is E11's.
- **E06** — six ARB files (D-3) with the CI check that fails on a key missing from any of them, and the
  `content_string` resolver with §9.2's fallback chain, which is how a `zone.name_key` becomes a name.
- **E07** — `app/lib/theme/` (D-2): the three Lonja themes and `LonjaTokens` with its `density` field.
- **E10** — `app/lib/ui/result/`: S2 complete. Its display provider is what T07 makes re-emit.

What does not exist: `app/lib/ui/zones/` (E12's epic file already names it as this epic's deliverable),
any geometry code anywhere, `app/lib/data/services/location_service.dart`, and any writer of
`user_profile.active_jurisdiction` or `user_profile.active_zone_code` — both are nullable in §7.2 and
have been null since first launch.

## Why this epic exists here in the order

It cannot come earlier. `zone_ring.coords` is a BLOB produced by `tools/content_builder/` (E04) and read
through `ZoneDao.ringsFor` (E05); with neither in place T01 has nothing to decode and T03 has no corpus
to measure. T04 writes `user_profile.active_zone_code`, which E05/T04 created and E05/T09's
`SettingsRepository` owns.

It must not come later. `epics/README.md` puts E11 in the **After** column of E12, and `SPEC.md` §15
step 10 gives Check home the dependency list `[6, 8, 9]` — step 9 is this epic. S1's zone chip routes to
S9 and its Recents strip is keyed by `(species_id, jurisdiction_code, zone_code)`, so a Check screen
built first would have a chip with no destination and a recents query with no key. E13 stamps
`jurisdiction_code` and `zone_code` onto every `catch` row (§4.5), which requires an active zone to
exist.

T01–T03 touch only `packages/rule_engine/` and depend on nothing after E05. If a second pair of hands is
available they are the parallelisable half of this epic.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | Decoding `zone_ring` | `T01-decoding-zone-ring.md` | M | — |
| T02 | Bbox prefilter, ray casting, and holes | `T02-bbox-prefilter-ray-casting-holes.md` | L | T01 |
| T03 | The hundred-millisecond budget | `T03-hundred-millisecond-budget.md` | M | T02 |
| T04 | S9 — country, region, sub-zone | `T04-s9-country-region-subzone.md` | M | E05/T09, E06, E07 |
| T05 | No polygons means no sub-zone level | `T05-no-polygons-no-subzone-level.md` | S | T04 |
| T06 | GPS suggests, and a denied permission costs nothing | `T06-gps-suggests-denied-costs-nothing.md` | M | T03, T04 |
| T07 | Saved zones and instant re-evaluation | `T07-saved-zones-instant-re-evaluation.md` | M | T04, E10 |
| T08 | Water type belongs to the zone | `T08-water-type-belongs-to-the-zone.md` | S | T04, T07 |

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once the epic is whole:

- [ ] All 8 tasks committed, one commit each, every `Task: E11/T<nn>` trailer present.
- [ ] `cd packages/rule_engine && dart test` green with **100% branch coverage on `lib/src/geo/`**;
      `cd app && flutter test` green; `dart format --set-exit-if-changed .` and `flutter analyze` clean
      at the workspace root.
- [ ] A point is located across the whole bundled zone set in **under 100 ms** (§13), and the same
      assertion holds at the §8-scale synthetic corpus of ~3 MB of packed coordinates (~187,500
      lat/lon pairs at 16 bytes per pair).
- [ ] `ZoneDao.ringsFor` is never called for a zone the bbox prefilter rejected — proved by a counting
      fake, not by reading the code.
- [ ] `packages/rule_engine/` still declares no `flutter` dependency, imports no `dart:ui`, and holds no
      user-visible sentence in any language (D-7). Every word S9 renders comes from ARB or
      `content_string`.
- [ ] GPS never writes `user_profile.active_zone_code`. A test drives a successful fix to completion and
      asserts the active zone is unchanged until the suggestion row is tapped.
- [ ] With location denied, every level of S9 is present and interactive, and exactly one line states
      why nothing was suggested. The same holds for services-off and for a 20 s timeout.
- [ ] No `getPositionStream`, no `getLastKnownPosition`, no geocoding symbol, no map widget and no
      network symbol anywhere in `app/lib/ui/zones/` or `app/lib/data/services/location_service*.dart`.
- [ ] The built release Android manifest declares no background-location permission and `Info.plist`
      declares no `NSLocationAlwaysAndWhenInUseUsageDescription` (§11, §14). `geolocator` appears in the
      checked-in direct-dependency allowlist in the same commit that adds it.
- [ ] A jurisdiction with `has_zone_polygons = 0` renders two levels and no third, states the fact in
      all six locales, and its rules resolve jurisdiction-wide.
- [ ] A zone whose `water_type` is `fresh` produces no finding sourced from a `salt` rule row, and the
      reverse.
- [ ] `check_app_invariants.sh app/lib`, `check_lonja_lists.sh app/lib`, `check_lonja_nav.sh app/lib`,
      `check_lonja_tokens.sh app/lib`, `check_no_network.sh app/lib`, `check_rule_engine.sh
      packages/rule_engine/lib` and `tools/gates/no_directional_geometry.sh app/lib` all clean.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted.

## Risks and the things that will bite

**1. Endianness is stated in the schema and read by the host.** `SPEC.md` §7.1 comments `zone_ring` as
"packed little-endian Float64 [lat,lon] pairs". The fast way to read it — `Float64List.view(bytes.buffer)`
— uses **host** byte order, not little-endian, and every device this ships to is little-endian, so the
bug is invisible until it is not. `Float64List.view` additionally throws when the `Uint8List` that
sqlite handed back has a non-zero `offsetInBytes` or a length that is not a multiple of 8. T01 therefore
reads through `ByteData.getFloat64(offset, Endian.little)` with the endianness written out, and its
tests build the byte buffer by hand from known bytes so the assertion is about the wire format rather
than about the machine running the test.

**2. The pair order is `[lat, lon]`, and every geo format the builder's author has ever used is
`[lon, lat]`.** GeoJSON, WKT and PostGIS all put longitude first. §7.1 puts latitude first. A swap
produces coordinates that are still valid doubles, still inside a plausible bbox for some other part of
the world, and silently wrong. T01 pins it with a fixture whose latitude and longitude cannot be
confused (Galicia: 42.6, −8.9) and T02 asserts a point that is inside only under the correct order.

**3. §7.1 has no polygon grouping, so a hole subtracts from the whole zone.** `zone_ring` carries
`ring_index` and `is_hole` and nothing that says which outer ring a hole belongs to. T02 therefore
defines containment as *inside any outer ring AND inside no hole ring*. For every geometry that can
actually be authored this is equivalent to the grouped model, because a hole cannot lie inside two
disjoint outer rings — but it is a real property of the schema and it is written down in T02 rather than
discovered later. **What would resolve it:** a `polygon_index` column on `zone_ring`, which is an E04/E05
schema change and is out of scope here.

**4. `SPEC.md` §10 lists `vector_math ^2.1` against "Point-in-polygon and bbox maths"; this epic imports
nothing.** Ray casting and a bbox test are scalar `double` comparisons; `Vector2` and the matrix types
buy no correctness and no speed, and §14's first static check diffs the direct-dependency allowlist, so
a dependency that earns nothing still costs an allowlist entry and a review argument. T02 states the
choice and `/simplify` would delete the import if it appeared. **What would resolve it:** a
`DECISIONS.md` entry naming the geometry dependency. Until that entry exists this paragraph is the
record; no task adds `vector_math` quietly, and if a builder decides to, the allowlist entry lands in
the same commit.

**5. `geolocator` is a new direct dependency and its Android manifest is merged into ours.** §14 fails
the build on an allowlist diff, so T06's commit carries the entry. Separately, §11 forbids background
location and §14 asserts the **built** manifest declares none — a manifest merged from a transitive
library is exactly the way one arrives without anybody typing it. T06 wires the assertion and, if the
merged manifest does contribute one, removes it with the `tools:node="remove"` form §11 already
documents for `INTERNET`. Nothing here can prove the merge output on a developer machine; the
`aapt2 dump xmltree` step on a real AAB is E21's.

**6. The 100 ms budget is specified on hardware this epic does not have.** §13 names a Snapdragon 665.
A `dart test` wall clock measures the CI runner. T03 therefore asserts two things: a **hardware-
independent** work bound — rings are loaded and vertices are cast only for bbox survivors, counted
exactly — and the §13 ceiling itself over a median of repeated runs, whose only realistic failure mode
is an algorithm that changed shape rather than a slow runner. The device measurement stays E21's. Do not
invent a CI-specific number.

**7. At this point in the order only Galicia's polygons are authored.** §8 budgets ~1 MB for Galicia,
~2 MB for Brazil and 0 for the Gulf; E04 seeds Galicia and E22 is the long pole that adds the rest. So
"across all bundled zones" in T03 is measured over a smaller corpus than the app will ship. T03 covers
the gap with a synthetic corpus sized from §8's byte budget, and it asserts the real corpus is non-empty
first — a budget test that scans nothing reports success, which is the failure mode `CONVENTIONS.md` §7
warns about for gates.

**8. §4.4 says the catch carries the water type it was evaluated under; §7.2's `catch` table has no such
column.** The row carries `zone_code`, and the zone carries the water type — but `reference.db` is
replaced wholesale and a zone's `water_type` can change between packs, which is precisely the
immutability problem §7.2's closing paragraph and `catchlaw-reference-database` rule 8 exist to prevent.
T08 therefore derives the water type, puts it on the domain draft that E13's writer consumes, and stops
there: adding a column to `user.db` is a forward-only migration that belongs to its owning epic, not to a
UI epic that happens to notice the gap. **What would resolve it:** a `DECISIONS.md` entry, or an E13
migration step adding `catch.water_type` with the fixture test E05/T05's ritual requires.

**9. `user_profile` has nowhere to record the water type of a `both` zone.** §7.2 gives it
`active_jurisdiction` and `active_zone_code` and no third field. When the active zone's `water_type` is
`'both'` the fisher's choice has to live somewhere, and T08 puts it in `user.db`'s `app_meta` key/value
table under `active_water_type` because that table already exists and needs no migration. It is a
deliberate second-best. **What would resolve it:** the same `DECISIONS.md` entry as risk 8, adding
`user_profile.active_water_type`.

**10. The engine's water-type enum and §7.1's `CHECK` constraint list different values.**
`catchlaw-rule-engine/references/resolution-algorithm.md` types the request field as
`.marine` / `.brackish` / `.fresh`; `SPEC.md` §7.1 constrains `zone.water_type`, `rule.water_type` and
`licence_type.water_type` to `'salt' | 'fresh' | 'both'`. Nothing in the schema can store a brackish
value, so if E03 shipped that variant it is unreachable from any bundled row. T08's mapper covers the
three values the database can hold and switches exhaustively over the enum in the reverse direction, so
a variant added later breaks the build at the mapper rather than silently selecting nothing. **What
would resolve it:** a `DECISIONS.md` entry naming §7.1's three values as the product's water-type set.
No task renames an engine enum from a UI epic.

## PR description

### What changed

Point-in-polygon zone matching, the S9 picker, and GPS as a suggestion.

`packages/rule_engine/lib/src/geo/` — a decoder for `zone_ring.coords` that reads packed little-endian
Float64 `[lat, lon]` pairs with the endianness written out rather than inherited from the host, honours
`point_count` and `is_hole`, and returns a typed `GeometryFailure` on a byte-length mismatch or an
out-of-range coordinate instead of throwing. On top of it: a bbox containment test, a half-open
crossing-number ray cast whose answer on a vertex and on an edge is pinned by test rather than left to
the algorithm, hole rings that subtract, and a locator that runs the cast **only** on bbox survivors and
returns every match at the top specificity rather than choosing between two.

`app/lib/ui/zones/` — S9. Country → region → sub-zone, saved zones starred at the top so a change is two
taps, the water-type toggle where a jurisdiction splits fresh and salt, and **Use my location**. A
jurisdiction whose authority publishes no coordinate boundaries shows no sub-zone level and says so.

`app/lib/data/services/location_service.dart` — a value-typed interface returning a sealed outcome, one
`geolocator` implementation behind it taking a single fix with a 20 s timeout, and a fake driven by an
enum over the five ways the world breaks. The fix produces a row the fisher taps; nothing switches by
itself.

### Why

The geographic question this app asks is small: which zone am I in. Point-in-polygon answers it from
bundled rings, which is why there are no map tiles — tiles would be tens of megabytes against a 55–70 MB
budget (§8), licence-encumbered, and would answer a question nobody asked.

GPS suggests and never switches because a zone is a chosen jurisdiction, not a sensor reading
(`lonja-navigation-chrome` rule 9), and because the fix that arrives on a boat under a steel wheelhouse
is exactly the fix that lands in the wrong zone. §6 S9's error state is explicit that the manual list
stays fully usable with one line saying why, and §14's dynamic checklist tests it with the permission
denied.

Where §8 records that Emirate maritime boundaries are not published as coordinate polygons in MD
580/2015 or its successors, `jurisdiction.has_zone_polygons` is 0, the picker hides the sub-zone level,
and rules apply jurisdiction-wide. We do not invent boundaries.

### How it was verified

- The wire format is asserted against a byte buffer built by hand, so the test is about little-endian
  `[lat, lon]` and not about the machine running it.
- A point exactly on a vertex, on a horizontal edge, on a vertical edge and on a sloped edge each has a
  pinned expected answer, so a refactor cannot flip one silently.
- Holes subtract, and a point in a second outer ring is still contained.
- Locating a point over the bundled corpus and over a §8-scale synthetic corpus (~187,500 pairs) stays
  under §13's 100 ms, and a counting fake proves rings are loaded only for bbox survivors.
- With the permission denied, denied-forever, services off, and a 20 s timeout, S9 renders every level,
  every level is tappable, and exactly one line states the reason.
- A successful fix leaves `user_profile.active_zone_code` unchanged until the suggestion is tapped.
- Switching zone re-runs resolution exactly once and re-emits the result screen's display model.
- `ar` widget tests for the picker, the toggle and the suggestion row; `no_directional_geometry.sh`
  clean over `app/lib`.

### Product invariants touched

- **Invariant 1 (no network).** `geolocator` is added to the allowlist and opens no socket; no geocoding
  API is called, no map tile is fetched, no URL is launched. `check_no_network.sh app/lib` is a gate on
  this epic.
- **Invariant 2 (a statement of fact, never an instruction).** Every line this epic adds — the denied-
  permission line, the no-polygons line, the no-match line — states what is true and offers no
  imperative. There is deliberately no route to the system settings screen: `url_launcher` and
  `AndroidIntent` are grep-banned by §14 and the fisher is told the fact, not told what to do about it.
- **Invariant 4 (colour is never the only signal).** The starred saved zone, the active zone and the
  suggested zone are distinguished by glyph and word before hue.
- **Invariant 5 (stale beats absent).** Nothing here gates on expiry. Switching zone re-evaluates and
  the ochre bar E10 owns rides above the result unchanged.

### Follow-ups deliberately not in this PR

- **The zone chip on Check.** `lonja-navigation-chrome` rules 8 and 9 own the chip; E12/T02 and E12/T05
  place it and give it the unset "Choose your area" label. This epic delivers the destination.
- **`catch.water_type`.** T08 carries the water type on the domain draft; the column and its migration
  belong to E13, and the gap is recorded in Risks 8.
- **Zone filtering in history.** §4.5's "filter by species, zone, date range" reads `idx_catch_zone`,
  which E05 indexed and E13 queries.
- **`licence_type` by zone and water type.** S21 is E15's; T08 delivers the water type the query is
  scoped by.
- **Bank, reserve and exclusion overrides marked as exceptions with their own citation** (§4.4). The
  specificity ladder that ranks them is E03's and already merged; the visible "this is an exception"
  treatment on the result screen belongs to E10's findings list.
- **The on-device measurement of §13's 100 ms.** E21, on a Snapdragon 665, with the rest of §14's
  dynamic checklist.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start E12.

**Gate paths used throughout this epic.** In-repo gates are invoked from the repository root as
`.claude/skills/<name>/scripts/check_*.sh <target>` with the target always written out — they exit 2 on
a missing directory, and a bare default would abort the run at this repository root where `lib/` does
not exist (`CONVENTIONS.md` §7, D-1). The general Flutter skills live in the separate plugin named in
`CONVENTIONS.md` §4; their scripts are written below as
`$FLUTTER_SKILLS/<skill>/scripts/<script>.sh app/lib`, where `$FLUTTER_SKILLS` is that plugin's
`skills/` directory. Passing the target explicitly matters there too, because several of them print
`SKIP` and exit 0 when the target is missing.
