# E11/T01 — Decoding `zone_ring`

| | |
|---|---|
| **Epic** | E11 — Zones and point-in-polygon |
| **Branch** | `epic/11-zones` (shared) |
| **Commit** | `feat(rule_engine): decode zone_ring as little-endian Float64 lat/lon pairs` |
| **Depends on** | E05/T07 (`ZoneDao.ringsFor` returns `coords` as raw bytes and interprets nothing) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.1 (`zone_ring`: `is_hole`, `point_count`, `coords BLOB`, and the comment that fixes the wire format), §8 (the four zone-polygon rows and the byte budget), §13 (< 100 ms — the reason this must be allocation-cheap) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 2: this code lands in the pure package, so `dart:typed_data` is allowed and `package:flutter`, `dart:ui` and `package:drift` are compile errors. Rule 10's argument — one function, two callers, never a near-copy — is the reason the decoder sits here and not in `app/lib/data/` |
| `catchlaw-reference-database` | Rule 11 and the two-database contract: the engine receives plain Dart values read from `ReferenceDao`. This decoder takes `Uint8List` and an `int`, never a drift row |
| `error-handling-typed-results` | Rules 1, 3, 4, 7: a malformed BLOB is a recoverable failure and therefore a value; the failure family is sealed, carries a stable code and typed params, and pure code stays total |
| `catchlaw-conventions-index` | Rule 6, the one-way layer map, and D-7: coordinates are numbers, so nothing here is a user-visible sentence in any language |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.1, `CREATE TABLE zone_ring` and its trailing comment | The wire format in full: `-- packed little-endian Float64 [lat,lon] pairs`, plus `is_hole`, `point_count` and `UNIQUE (zone_id, ring_index)` |
| `SPEC.md` | §7.1, `CREATE TABLE zone` | `min_lat`/`min_lon`/`max_lat`/`max_lon` are `REAL` columns on the zone, not derived from the rings — T02 uses them, T01 must not recompute them |
| `SPEC.md` | §8, the three zone-polygon rows | The payload budget the decoder is sized against: ~1 MB Galicia, ~2 MB Brazil, 0 for the Gulf |
| `SPEC.md` | §13, "Point-in-polygon zone match" | < 100 ms across all bundled zones; the decode is on that path, so it allocates once per ring and not once per point |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | rules 2, 10; "Anti-patterns" | No Flutter in the pure package (`package:meta`, never `package:flutter/foundation.dart` for `@immutable`); one function rather than a drifting second copy |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "The ATTACH ban", closing paragraph | "The rule engine takes plain Dart values… `ReferenceDao` reads rows, maps them to `rule_engine` records" |
| `.claude/skills/error-handling-typed-results/SKILL.md` | rules 1, 3, 4, 7 | Failures as values, one sealed family per boundary, no `default:` on a sealed switch, pure logic total |
| `.claude/skills/error-handling-typed-results/references/result-failure-spine.md` | "Why `F extends Failure`", "Failure taxonomy per boundary" | The typed error arm and the `code` + typed-params shape `GeometryFailure` follows |
| `FLUTTER_GUIDE.md` | §2.5 | Where the file goes: `packages/rule_engine/lib/src/`, and rule 8 — zero `package:flutter` imports guaranteed by the pubspec |
| `FLUTTER_GUIDE.md` | §2.6 | One barrel only, `packages/rule_engine/lib/rule_engine.dart`; the new geo types are exported from it |
| `epics/DECISIONS.md` | D-7 | The engine returns types; no user-visible sentence lives here, in any language |
| `epics/CONVENTIONS.md` | §5 | Test naming — subject first, no `should`, no given/when/then |

## What this delivers

- `packages/rule_engine/lib/src/geo/lat_lon.dart` — `LatLon`, an immutable `const` value type with
  `final double lat` and `final double lon`, value equality, and a `toString` that prints both to six
  decimal places.
- `packages/rule_engine/lib/src/geo/zone_ring.dart` — `ZoneRing`, holding `ringIndex`, `isHole` and an
  unmodifiable `List<LatLon> points`.
- `packages/rule_engine/lib/src/geo/zone_ring_codec.dart` —
  `Result<ZoneRing, GeometryFailure> decodeZoneRing(Uint8List coords, {required int ringIndex, required
  int pointCount, required bool isHole})` and `Uint8List encodeZoneRing(List<LatLon> points)`, the
  encoder being what `tools/content_builder/` calls so the two sides cannot drift.
- `packages/rule_engine/lib/src/geo/geometry_failure.dart` — the sealed `GeometryFailure` family:
  `RingByteLengthMismatch` (`geo.ring_byte_length_mismatch`, params `int expectedBytes, int actualBytes`),
  `RingTooFewPoints` (`geo.ring_too_few_points`, param `int pointCount`),
  `RingCoordinateOutOfRange` (`geo.ring_coordinate_out_of_range`, params `int pointIndex, double lat,
  double lon`).
- `packages/rule_engine/lib/rule_engine.dart` — three new exports.
- `packages/rule_engine/test/geo/zone_ring_codec_test.dart`.
- `packages/rule_engine/testing/models/ring_fixtures.dart` — `kRingRiaDeArousa` (a four-point outer ring
  in Galician waters), `kRingRiaDeArousaHole`, and `bytesOf(List<LatLon>)`, a hand-rolled little-endian
  writer used **only** by the tests so the assertions do not depend on the production encoder.

## Why it is built this way

**The endianness is written out, because the fast way to read it is the wrong way.** `SPEC.md` §7.1
fixes the format as *packed little-endian Float64*. The obvious decode —
`Float64List.view(coords.buffer)` — reads **host** byte order, not little-endian. Every device this
ships to is little-endian, so a host-order read is correct on every machine anybody will test it on and
wrong on the one that is not. It also throws outright when the `Uint8List` sqlite handed back has a
non-zero `offsetInBytes` (a view into a larger buffer, which is exactly what a BLOB column can be) or a
length that is not a multiple of 8. The decoder therefore goes through
`ByteData.sublistView(coords).getFloat64(offset, Endian.little)`, where the byte order is a named
argument a reviewer can see and a test can pin against bytes written by hand.

**Latitude comes first, and everything else in the world puts longitude first.** GeoJSON, WKT and
PostGIS are all `[lon, lat]`. §7.1's comment is `[lat,lon]`. A swap yields two doubles that are still
finite, still plausible, and silently point at the wrong hemisphere. The fixture is Galician — latitude
≈ 42.6, longitude ≈ −8.9 — so the two values cannot be confused with each other, and the round-trip test
asserts the byte offsets directly rather than only that `encode(decode(x)) == x`, which a consistent
swap would pass.

**A malformed BLOB is a value, not an exception.** `error-handling-typed-results` rule 1 puts
recoverable failures in the type; rule 7 keeps pure logic total. A `point_count` that disagrees with the
byte length is a content bug — the builder wrote one thing and the column says another — and the caller
that can do something about it is the content build (E04/E22), which wants a code and two integers, not
a stack trace. Returning `Result` also means T02's locator can skip a bad ring and still answer, rather
than taking the whole zone lookup down with it.

**Coordinates are range-checked here, once.** A latitude outside [−90, 90] or a longitude outside
[−180, 180] cannot be a real position and is the signature of a swapped pair or a wrong scale factor.
Checking at decode gives the content builder a single assertion to call over every authored ring before
`reference.db` ships, which is what §8's pipeline section asks of every other field ("validate every rule
row against a schema… fail otherwise"). Checking later, inside the ray cast, would mean checking once
per query for the life of the app.

**`point_count` is honoured, and it is not the same as the byte length.** The column exists so the
decoder can allocate the exact list length and so a truncated BLOB is detectable at all. The required
length is `pointCount * 2 * 8` bytes — two Float64 per point, 16 bytes per pair. Trusting the byte length
instead would make a BLOB with a trailing byte decode as a shorter ring with no complaint.

**`is_hole` is carried, not applied.** The decoder records the flag on `ZoneRing` and does nothing with
it. Subtraction is a property of the whole zone's ring set and belongs to T02; a decoder that started
returning "outer rings only" would be making a containment decision one layer too low, where it cannot
see the other rings.

**Two points is the floor, not three.** `RingTooFewPoints` fires below three, because a ring with fewer
than three distinct points encloses no area and the crossing count in T02 is meaningless. A
two-point "ring" would ray-cast without error and always answer false, which is a silent wrong answer
rather than a loud one.

**The ring is not required to be closed.** §7.1 says nothing about repeating the first point at the end,
and the Galician annexes are printed both ways. The decoder stores exactly the points it was given; T02
closes the ring implicitly by wrapping from the last vertex to the first, and asserts that a ring with an
explicit closing point gives the same answer. Normalising here — silently dropping a duplicate final
point — would make `encode(decode(x))` lossy and break the builder's round trip.

**Rejected: decoding into a `Float64List` and indexing it as pairs.** It is faster and it is what the
budget in §13 tempts you toward, but it reintroduces the host-order and alignment problems the first
paragraph exists to close, and T03 shows the budget has roughly two orders of magnitude of headroom
without it. If a measurement on real hardware ever says otherwise, the change is a byte-order-checked
fast path behind the same signature and the same tests — not a different decode.

**Rejected: putting the decoder in `app/lib/data/model/`.** `tools/content_builder/` writes these bytes
and the app reads them. Two implementations of one wire format is the same failure `catchlaw-rule-engine`
rule 10 records for normalisation: the index holds keys the query can never produce. The pub workspace
(D-1) exists precisely so both callers can import one function, and this package is the only one both of
them already depend on.

**Rejected: `@immutable` from `package:flutter/foundation.dart`.** It is the listed anti-pattern in
`catchlaw-rule-engine`: it drags Flutter into the shared package and breaks the CLI content build. Use
`package:meta`.

## Tests first

Write every row before touching `zone_ring_codec.dart`. Run them. **They must fail.** If one passes now,
the test is wrong — a decoder that does not exist cannot decode.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `decodeZoneRing reads a latitude and a longitude from sixteen bytes` | one pair written little-endian by hand | `LatLon(42.6, -8.9)` | The baseline wire-format assertion, against bytes rather than against the encoder |
| 2 | `decodeZoneRing reads lat before lon` | bytes for `[42.6, -8.9]` | `lat` is 42.6 and `lon` is −8.9 | GeoJSON, WKT and PostGIS are all `[lon, lat]`; §7.1 is not, and a swap is still two valid doubles |
| 3 | `decodeZoneRing reads little-endian regardless of host order` | the same value written big-endian | not equal to 42.6 | Names the bug: `Float64List.view` would pass this test on a little-endian host and hide it forever |
| 4 | `decodeZoneRing decodes a ring whose bytes start at a non-zero offsetInBytes` | `Uint8List.sublistView` of a larger buffer | the same four points as case 5 | `Float64List.view` throws here; a BLOB from sqlite can arrive exactly this way |
| 5 | `decodeZoneRing returns point_count points` | 4-point ring, `pointCount: 4` | `points.length == 4` | The column is the allocation size and the truncation detector |
| 6 | `decodeZoneRing fails with RingByteLengthMismatch when the blob is short` | `pointCount: 4`, 48 bytes | `Err(RingByteLengthMismatch(expectedBytes: 64, actualBytes: 48))` | A truncated BLOB must be named, not decoded into a shorter ring |
| 7 | `decodeZoneRing fails with RingByteLengthMismatch when the blob has a trailing byte` | `pointCount: 4`, 65 bytes | `Err(RingByteLengthMismatch(expectedBytes: 64, actualBytes: 65))` | Trusting the byte length instead of `point_count` would silently accept this |
| 8 | `decodeZoneRing fails with RingTooFewPoints for a two-point ring` | `pointCount: 2` | `Err(RingTooFewPoints(pointCount: 2))` | A two-point ring ray-casts cleanly and always answers false — a silent wrong answer |
| 9 | `decodeZoneRing fails with RingCoordinateOutOfRange for a latitude above 90` | lat 142.6 | `Err(RingCoordinateOutOfRange(pointIndex: 0, …))` | The signature of a swapped pair or a wrong scale factor, caught once at the edge |
| 10 | `decodeZoneRing fails with RingCoordinateOutOfRange for a longitude below -180` | lon −190.0 | `Err(RingCoordinateOutOfRange(pointIndex: 2, …))` | The failure names which point, so the content builder can print the offending row |
| 11 | `decodeZoneRing reports pointIndex of the first out-of-range point` | points 0 and 2 both bad | `pointIndex` is 0 | A failure that names the last bad point sends the author to the wrong line |
| 12 | `decodeZoneRing carries is_hole onto the ring` | `isHole: true` | `ring.isHole` is true | The flag is transported, not applied; T02 owns subtraction |
| 13 | `decodeZoneRing carries ring_index onto the ring` | `ringIndex: 3` | `ring.ringIndex == 3` | `UNIQUE (zone_id, ring_index)` is the ordering contract E05's DAO preserves |
| 14 | `decodeZoneRing preserves an explicit closing point` | 5 bytes-pairs, last equal to first | `points.length == 5` | Silently dropping it would make the builder's round trip lossy |
| 15 | `decodeZoneRing accepts an empty ring only as a failure` | `pointCount: 0`, zero bytes | `Err(RingTooFewPoints(pointCount: 0))` | The boundary an off-by-one length check gets wrong first |
| 16 | `encodeZoneRing writes sixteen bytes per point` | 4 points | 64 bytes | 16 bytes per pair is the arithmetic §8's byte budget and T03's corpus size are both built on |
| 17 | `encodeZoneRing then decodeZoneRing returns the original points` | `kRingRiaDeArousa` | equal, point for point | The builder writes and the app reads; one broken side is invisible without this |
| 18 | `encodeZoneRing writes little-endian` | one point | byte 0 of the first double matches the hand-written little-endian fixture | The encoder has the same host-order trap as the decoder and needs the same pin |
| 19 | `LatLon compares equal by value` | two identical instances | `==` and `hashCode` agree | `ZoneRing` lists are compared in T02's tests and in the builder's assertions |

```dart
// packages/rule_engine/test/geo/zone_ring_codec_test.dart
import 'dart:typed_data';

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/ring_fixtures.dart';

void main() {
  group('decodeZoneRing', () {
    test('reads lat before lon', () {
      // Written by hand, little-endian, lat first — deliberately NOT via encodeZoneRing,
      // because a consistent [lon, lat] swap in both directions round-trips perfectly.
      final bytes = bytesOf(kRingRiaDeArousa);

      final result = decodeZoneRing(
        bytes,
        ringIndex: 0,
        pointCount: kRingRiaDeArousa.length,
        isHole: false,
      );

      switch (result) {
        case Ok(:final value):
          expect(value.points.first.lat, closeTo(42.60, 1e-9));
          expect(value.points.first.lon, closeTo(-8.95, 1e-9));
        case Err(:final failure):
          fail('a well-formed four-point ring must decode: ${failure.code}');
      }
    });

    test('reads little-endian regardless of host order', () {
      final big = ByteData(16)
        ..setFloat64(0, 42.6, Endian.big)
        ..setFloat64(8, -8.9, Endian.big);
      final bytes = big.buffer.asUint8List();

      final result = decodeZoneRing(
        Uint8List.fromList([...bytes, ...bytes, ...bytes]),
        ringIndex: 0,
        pointCount: 3,
        isHole: false,
      );

      switch (result) {
        case Ok(:final value):
          expect(value.points.first.lat, isNot(closeTo(42.6, 1e-9)),
              reason: 'a big-endian double read as little-endian must not equal the original — '
                  'Float64List.view would pass this on every device we ship to');
        case Err(:final failure):
          expect(failure, isA<RingCoordinateOutOfRange>());
      }
    });

    test('decodes a ring whose bytes start at a non-zero offsetInBytes', () {
      final packed = bytesOf(kRingRiaDeArousa);
      final padded = Uint8List(packed.length + 3)..setRange(3, 3 + packed.length, packed);
      final view = Uint8List.sublistView(padded, 3);

      final result = decodeZoneRing(
        view,
        ringIndex: 0,
        pointCount: kRingRiaDeArousa.length,
        isHole: false,
      );

      expect(result, isA<Ok<ZoneRing, GeometryFailure>>());
    });

    test('fails with RingByteLengthMismatch when the blob is short', () {
      final short = Uint8List.sublistView(bytesOf(kRingRiaDeArousa), 0, 48);

      final result = decodeZoneRing(short, ringIndex: 0, pointCount: 4, isHole: false);

      switch (result) {
        case Ok():
          fail('a 48-byte blob cannot hold 4 points');
        case Err(:final failure):
          expect(failure, isA<RingByteLengthMismatch>());
          expect((failure as RingByteLengthMismatch).expectedBytes, 64);
          expect(failure.actualBytes, 48);
          expect(failure.code, 'geo.ring_byte_length_mismatch');
      }
    });

    // … one test per remaining row above, one behaviour each
  });
}
```

```dart
// packages/rule_engine/testing/models/ring_fixtures.dart — helpers, never shipped
import 'dart:typed_data';

import 'package:rule_engine/rule_engine.dart';

/// Four corners in the Ria de Arousa. Latitude and longitude cannot be confused
/// with each other here, which is the point: a [lon, lat] swap is visible.
const kRingRiaDeArousa = <LatLon>[
  LatLon(42.60, -8.95),
  LatLon(42.60, -8.80),
  LatLon(42.48, -8.80),
  LatLon(42.48, -8.95),
];

/// A hand-rolled little-endian writer. The tests must not depend on the
/// production encoder, or a byte-order bug in one hides a byte-order bug
/// in the other.
Uint8List bytesOf(List<LatLon> points) {
  final data = ByteData(points.length * 16);
  for (var i = 0; i < points.length; i++) {
    data.setFloat64(i * 16, points[i].lat, Endian.little);
    data.setFloat64(i * 16 + 8, points[i].lon, Endian.little);
  }
  return data.buffer.asUint8List();
}
```

**Run:** `cd packages/rule_engine && dart test test/geo/zone_ring_codec_test.dart` → 19 failures. If any
passes now, the test is wrong.

## Implementation outline

1. `lat_lon.dart`: `final class LatLon` with a `const` constructor, two `final double` fields, `==`,
   `hashCode` and `toString`. `@immutable` from `package:meta`, never from Flutter.
2. `zone_ring.dart`: `final class ZoneRing` holding `ringIndex`, `isHole` and
   `List<LatLon> points`, stored as `List.unmodifiable`.
3. `geometry_failure.dart`: `sealed class GeometryFailure extends Failure` with the three `final class`
   subtypes, each `const`, each with a `code` getter and typed params. No strings beyond the codes.
4. `zone_ring_codec.dart`, in this order so the cheapest check fails first:
   a. `if (pointCount < 3) return Err(RingTooFewPoints(pointCount: pointCount));`
   b. `final expected = pointCount * 16; if (coords.lengthInBytes != expected) return
      Err(RingByteLengthMismatch(...));`
   c. `final data = ByteData.sublistView(coords);` — `sublistView`, so a non-zero `offsetInBytes`
      is respected rather than ignored.
   d. Loop `i` from 0 to `pointCount`, reading
      `data.getFloat64(i * 16, Endian.little)` and `data.getFloat64(i * 16 + 8, Endian.little)`,
      range-checking each pair and returning on the **first** out-of-range point.
   e. `return Ok(ZoneRing(...));`
5. `encodeZoneRing`: the mirror, `ByteData(points.length * 16)` with `setFloat64(..., Endian.little)`.
   It is the function `tools/content_builder/` calls; do not add a second one there.
6. Export the three files from `packages/rule_engine/lib/rule_engine.dart` with a doc comment on each
   public member per `CONVENTIONS.md` §8's last bullet.
7. Re-run the whole engine suite. 19 green, and every E02/E03 test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first.
- [ ] Branch coverage on `packages/rule_engine/lib/src/geo/` is 100% for the files this task adds.
- [ ] `Endian.little` appears at every `getFloat64` and every `setFloat64`; `grep -rn 'Float64List.view'
      packages/rule_engine/lib` returns nothing.
- [ ] `decodeZoneRing` returns `Result` on every path and throws on none — no `throw`, no `assert` on
      input, no `!` on a nullable derived from the blob.
- [ ] The `GeometryFailure` switch in the tests has no `default:` arm.
- [ ] No `GeometryFailure` subtype carries a user-facing string; each carries a stable `code` and typed
      params (D-7, and `error-handling-typed-results` rule 3).
- [ ] `packages/rule_engine/pubspec.yaml` is unchanged — `dart:typed_data` is in the SDK and needs no
      dependency.
- [ ] `packages/rule_engine/` still imports no `package:flutter` and no `dart:ui`.
- [ ] `bytesOf` lives in `testing/`, not in `lib/`, and does not end in `_test.dart`.

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
feat(rule_engine): decode zone_ring as little-endian Float64 lat/lon pairs

SPEC 7.1 fixes the wire format as packed little-endian Float64 [lat,lon]
pairs. The fast decode — Float64List.view(coords.buffer) — reads HOST byte
order, and throws outright when sqlite hands back a Uint8List with a
non-zero offsetInBytes. Both failures are invisible on every device we ship
to, so the decoder goes through ByteData.sublistView with Endian.little
named at every read, and the tests assert against bytes written by hand
rather than against our own encoder.

Latitude is first. GeoJSON, WKT and PostGIS are all [lon, lat], so a swap
yields two finite, plausible doubles pointing at the wrong hemisphere; the
fixture is Galician (42.6, -8.9) so the two values cannot be confused.

A short blob, a trailing byte, a ring under three points and a coordinate
outside [-90, 90] / [-180, 180] are typed GeometryFailure values with stable
codes, not throws — the caller that can act on them is the content build,
which wants a code and two integers. encodeZoneRing ships beside it so
tools/content_builder writes through the same function the app reads with.

Task: E11/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
