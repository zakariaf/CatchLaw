# E05/T10 — Mappers: drift rows never escape `data/`

| | |
|---|---|
| **Epic** | E05 — Data layer: two drift databases |
| **Branch** | `epic/05-data-layer` (shared) |
| **Commit** | `feat(data): confine row-to-domain mapping to data/model/ and gate the boundary` |
| **Depends on** | T09 (the repositories whose signatures this completes and enforces) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.1, §7.2 (the rows being mapped); §7.3 (the shape the engine takes); §12 (the export format the domain types must survive into) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `persistence-drift` | Rule 1 — `package:drift` and `package:sqlite3` are imported nowhere but the data layer, enforced by a grep gate — and the row → value-object mapping the DAOs and repositories hand off to |
| `catchlaw-conventions-index` | Rule 6, the one-way layer map: `packages/rule_engine/` → `lib/data/` → `lib/ui/`, and `lib/ui/` never queries a DAO |
| `catchlaw-reference-database` | Rule 11: the engine receives plain Dart values read from the DAOs; a `Verdict` is composed in memory and written back as literals |
| `error-handling-typed-results` | Mapping is total: a row with an unknown enum string is an explicit outcome, never a throw from inside a mapper |
| `testing-strategy` | Rule 3: every conversion gets a round-trip test, and a gate over an empty directory is the failure mode to test for first |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `FLUTTER_GUIDE.md` | §2.5 | Rule 1 (no widget imports from `data/`), rule 2 (no ViewModel imports from `data/services/`), rule 6 (domain models immutable; **drift row classes never escape `data/`**), and the `data/model/` directory that owns the mapping |
| `FLUTTER_GUIDE.md` | §1.9 | The domain layer is mandatory for us — the reason the mapped types exist at all |
| `FLUTTER_GUIDE.md` | §3.7 | API design rules the domain value types follow |
| `$FLUTTER_SKILLS/persistence-drift/SKILL.md` | rule 1; "Confining Drift to one layer" | The banned-import boundary and why it also blocks testing everything above it |
| `$FLUTTER_SKILLS/persistence-drift/scripts/check-drift-confinement.sh` | whole | The executable form: any file importing drift or sqlite3 outside `lib/data/` is a violation, `sqflite` is banned outright, and a missing target prints `SKIP` and exits 0 |
| `$FLUTTER_SKILLS/persistence-drift/references/schema-and-daos.md` | "DAOs vs repositories", "Column type discipline" | Where the mapping sits, and that formatting never happens here |
| `.claude/skills/catchlaw-conventions-index/SKILL.md` | rule 6; "The layer map is a one-way street" | The engine takes plain values and returns a sealed verdict; it never sees a `Color`, a `BuildContext` or a DAO |
| `.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh` | usage and `TARGET` handling | Exits 2 on a missing directory, which is why every invocation names `app/lib` |
| `SPEC.md` | §7.3 | The candidate-rule shape the engine consumes: numbers, enums, a `Citation`, and dates |
| `SPEC.md` | §12 | The export format the domain types must be able to produce without touching a row class |
| `epics/DECISIONS.md` | D-7 | The engine returns types; the app owns every word. Mappers carry `*_key` strings, never rendered sentences |

## What this delivers

- `app/lib/data/model/` — the complete mapper set, one file per row family, each a set of top-level
  functions rather than methods on a row class:
  `species_mapper.dart` · `rule_mapper.dart` · `zone_mapper.dart` · `citation_mapper.dart` ·
  `content_string_mapper.dart` · `legal_text_mapper.dart` · `catch_mapper.dart` · `trip_mapper.dart` ·
  `species_recent_mapper.dart` · `saved_zone_mapper.dart` · `user_profile_mapper.dart`.
- `app/lib/domain/models/` — the immutable domain types the mappers produce, for everything §7.2 owns:
  `catch_record.dart` · `trip.dart` · `species_tally.dart` · `saved_zone.dart` · `user_profile.dart` ·
  `recent_species.dart`. Reference-side rows map into the engine's existing types from E03 (`Citation`,
  the candidate-rule record of §7.3) plus `species.dart` and `zone.dart` for the parts the engine has no
  opinion about.
- `app/lib/data/model/enum_codecs.dart` — the total string ↔ enum conversions for every `CHECK`ed column
  of §7.1 and §7.2, each with an explicit unknown case.
- `app/test/data/model/` — one round-trip test file per mapper.
- `app/test/data/drift_boundary_test.dart` — the boundary assertion.
- A CI step running `check-drift-confinement.sh app/lib`, added to `.github/workflows/validate.yml`.

## Why it is built this way

**The defect this task prevents is a widget importing `CatchRow`.** It has not happened yet — there are
no widgets. That is exactly why the guard lands now: `FLUTTER_GUIDE.md` §2.5 rule 6 is a rule about what
E08 through E18 are allowed to do, and a rule with no enforcement is a rule that is broken in the epic
where somebody is in a hurry. Once a `CatchRow` is on a screen, every widget test above it needs a
database, `flutter test` slows by an order of magnitude, and the generated class becomes public API that
a schema change cannot move.

**The mapping happens in `data/model/`, called by the repositories.** `persistence-drift` rule 1 asks
DAOs to return value objects; `FLUTTER_GUIDE.md` §2.5 puts the mapping in `data/model/` and bans row
classes from leaving `data/`. Both are satisfied by mapping one layer up from the DAO: the boundary that
matters — nothing above `data/` sees a row class — is identical, and the mappers can compose several
tables into one engine input, which a single-table DAO structurally cannot. T07 stated this once; this
task is where it is enforced, so the two readings cannot drift.

**Mappers are top-level functions, not extension methods on row classes.** An extension on `CatchRow`
lives wherever `CatchRow` is visible, which is precisely the thing being constrained; a top-level
`CatchRecord catchRecordFromRow(CatchRow row)` in `data/model/` has one import site and shows up in a
grep. They are also pure and synchronous, so their tests need no database at all.

**Enum decoding is total and never throws.** A `CHECK` guarantees the column holds one of a fixed set —
but only for rows this build wrote. `reference.db` is generated by a tool that may ship a new
`zone_kind` before the app knows it, and `SPEC.md` §7.1's enumerated columns are content. So every codec
returns an explicit unknown variant rather than throwing: `error-handling-typed-results` rule 7 keeps
pure logic total, and a `FormatException` thrown from inside a mapper on a boat is a screen that renders
nothing where it could have rendered most things. The unknown variant is a value the UI can decide to
skip; an exception is not.

**Round-trip tests, because a mapper is a conversion.** `testing-strategy` rule 3: every conversion has a
`decode(encode(x)) == x` test. For the user-side types this is literal — `catchRecordFromRow(toRow(x))
== x` — and it is the test that catches a field silently dropped when a column is added, which for
`catch` means a verdict that cannot restate itself. The reference-side mappers are one-way and get
per-field assertions instead, including the `*_key` columns, which must arrive as keys and not as
resolved text.

**Mappers carry keys, never sentences.** D-7: `packages/rule_engine/` holds no user-visible string in any
language, and `content_string` resolution is E06's fallback chain. `species_mapper` carries
`name_key`; it does not look up the localised name. A mapper that resolves text is a mapper that needs a
locale, and then every test above it needs one too.

**Nothing here formats.** `schema-and-daos.md` is explicit that formatting happens at the presentation
edge. `length_mm` stays an `int` of millimetres through the domain type; cm, mm and inches are the
ruler's and the settings' concern (E09, E16), and the numeral system is §9.3's.

**Rejected: `freezed` for the domain models.** They are small, hand-written `final class`es with `const`
constructors, `==` and `copyWith` where a copy is genuinely used. `FLUTTER_GUIDE.md` §7.3 measures what
codegen costs, and adding a generator for eleven value types is a build step every contributor pays for
on every clone. `==` matters here for a real reason — `FLUTTER_GUIDE.md` §5.3's rebuild filter compares
provider values with `==` — so it is written and tested, not generated.

**Rejected: exposing `Insertable`/`Companion` types from a repository.** They are drift types. A
repository takes a domain draft and builds the companion inside `data/model/`; the write direction gets
the same boundary as the read direction, or the boundary only holds half the time.

## Tests first

Write every row before touching a mapper. Run them. **They must fail.** Row 1 is the one to watch: a
boundary test over a directory that does not exist reports success, so it asserts the file list is
non-empty before it asserts anything about imports — the exact failure mode `CONVENTIONS.md` §7 warns
about and E01/T08 already guards for the gate scripts.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `no file outside lib/data imports package:drift or package:sqlite3` | scan `app/lib`, excluding `lib/data/` | no match, and the scanned file list is non-empty | The rule E08–E18 will break. A scan of an empty tree reports success |
| 2 | `no repository signature mentions a generated drift row type` | read the three interface sources | no `Row`, `Companion`, `Data` type name | The read boundary and the write boundary must hold together |
| 3 | `catchRecordFromRow round-trips through catchRowFrom` | a fully populated `CatchRecord` | equal | A field dropped on a column addition is a verdict that cannot restate itself |
| 4 | `catchRecordFromRow round-trips a record with every nullable field null` | minimal record | equal | The quick-add with no trip, no photo, no coordinates — §4.5's normal case |
| 5 | `catchRecordFromRow preserves outcome_detail verbatim` | text with an em dash and Arabic | identical | §7.2 stores "the factual finding text as shown"; a mapper that trims it changes the record |
| 6 | `tripFromRow round-trips through tripRowFrom` | open trip, `ended_at` null | equal | The open-trip case, which is the one the tally reads |
| 7 | `userProfileFromRow round-trips through userProfileRowFrom` | every field set | equal | Eleven settings columns; the one that silently drops is the one nobody set |
| 8 | `userProfileFromRow maps locale_override to one of the six shipped locales` | `pt_BR` | `pt_BR` | D-3: never `ur`, never bare `pt` |
| 9 | `speciesFromRow carries name_key rather than a resolved name` | row with `name_key` | the key | D-7 and §9.2's two-tier translation: resolution is E06's |
| 10 | `ruleFromRow maps every SPEC 7.3 input field` | fully populated rule | each field present, `valid_to` preserved when set | The engine's input. A dropped `valid_to` deletes expiry, which invariant 5 depends on |
| 11 | `ruleFromRow preserves a null valid_to as null` | no expiry | `null`, not a sentinel date | A sentinel makes an eternal rule expire on a date nobody chose |
| 12 | `citationFromRow produces a Citation with every required field` | full row | non-null instrument, article, published, checked | Invariant 3: a nullable `Citation` makes an uncited verdict representable |
| 13 | `decodeWaterType returns unknown for a value this build does not know` | `'brackish'` | `WaterType.unknown`, no throw | Content can ship an enum value before the app knows it; a throw here renders nothing |
| 14 | `decodeZoneKind round-trips every known value` | all six §7.1 values | equal | The codec's own conservation test |
| 15 | `decodeOutcome returns unknown rather than throwing on an unexpected value` | `'ok'` | `Outcome.unknown` | Same argument, on the user side, where the row was written by an older build |
| 16 | `zoneFromRow returns ring coordinates as bytes` | zone with rings | `Uint8List`, unmodified | Float64 unpacking is E11's; a mapper that decodes here duplicates it |
| 17 | `no mapper resolves a content_string key` | scan `lib/data/model/` | no reference to `ContentStringDao` | A mapper that resolves text needs a locale, and then so does every test above it |
| 18 | `every domain model is immutable and implements ==` | construct two equal instances | `==` true, all fields `final` | `FLUTTER_GUIDE.md` §5.3: Riverpod filters updates with `==`, so a missing one is a rebuild storm |

```dart
// app/test/data/drift_boundary_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no file outside lib/data imports package:drift or package:sqlite3', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('${Platform.pathSeparator}data${Platform.pathSeparator}'))
        .toList();

    expect(files, isNotEmpty,
        reason: 'a scan of an empty tree reports success — CONVENTIONS 7, and E01/T08 says the same');

    for (final file in files) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains("import 'package:drift/")),
          reason: '${file.path} imports drift: a row class has escaped data/, and every widget test '
              'above it now needs a database');
      expect(source, isNot(contains("import 'package:sqlite3/")), reason: file.path);
    }
  });
}
```

```dart
// app/test/data/model/catch_mapper_test.dart
import 'package:catchlaw/data/model/catch_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/user_fixtures.dart';

void main() {
  test('catchRecordFromRow round-trips through catchRowFrom', () {
    final original = kCatchRecordCentolla;

    final round = catchRecordFromRow(catchRowFrom(original));

    expect(round, original,
        reason: 'a field dropped here is a catch that can no longer restate what it was judged under');
  });

  test('catchRecordFromRow preserves outcome_detail verbatim', () {
    final original = kCatchRecordCentolla.copyWith(
      outcomeDetail: 'Below the minimum — 38 cm, minimum 45 cm (total length)',
    );

    expect(catchRecordFromRow(catchRowFrom(original)).outcomeDetail, original.outcomeDetail);
  });

  test('decodeOutcome returns unknown rather than throwing on an unexpected value', () {
    expect(decodeOutcome('ok'), Outcome.unknown);
  });
}
```

## Implementation outline

1. Write `app/lib/domain/models/` — six `final class`es with `const` constructors, `final` fields, `==`,
   `hashCode` and `copyWith` only where a copy is used. No `freezed`.
2. Write `enum_codecs.dart`: one `decodeX` / `encodeX` pair per `CHECK`ed column of §7.1 and §7.2, each
   `decodeX` returning an explicit `unknown` variant for a value it does not recognise, and each
   `encodeX` total over the enum.
3. Write the eleven mapper files as top-level functions. Reference-side mappers produce the engine's
   types (`Citation`, the §7.3 candidate record) and the two app-side reference types; user-side mappers
   are bidirectional and produce companions for the write path.
4. Change the three repository implementations from T09 to call the mappers rather than mapping inline,
   and re-check every public signature for a drift type. Anything that leaked becomes a domain type here.
5. Write `drift_boundary_test.dart` with the non-empty assertion first.
6. Add `check-drift-confinement.sh app/lib` to `.github/workflows/validate.yml`, with the target
   explicit — the script prints `SKIP` and exits **0** on a missing directory, so a defaulted path would
   pass forever.
7. Re-run the suite. 18 green, and every earlier task's tests still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] No file outside `app/lib/data/` imports `package:drift` or `package:sqlite3`; asserted in a test
      **and** gated in CI, with the file list proved non-empty.
- [ ] No public repository signature mentions a generated row, data or companion type.
- [ ] Every row → domain conversion lives in `app/lib/data/model/`; no mapping remains inline in a
      repository or a DAO.
- [ ] Every mapper is a top-level function; no extension method on a drift row class exists.
- [ ] Every enum codec is total and returns an explicit unknown variant; no mapper throws.
- [ ] Every user-side mapper has a round-trip test, including one with every nullable field null.
- [ ] No mapper resolves a `content_string` key or formats a number, a date or a unit.
- [ ] Every domain model is immutable and implements `==`.
- [ ] `check-drift-confinement.sh app/lib` runs in CI with an explicit target.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-drift-confinement.sh       app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh        app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): confine row-to-domain mapping to data/model/ and gate the boundary

Eleven mappers as top-level functions in data/model/, the immutable domain
types they produce, and total enum codecs that return an explicit unknown
variant instead of throwing — reference.db is content, so a pack can ship a
zone_kind this build has never heard of, and a FormatException from inside a
mapper on a boat renders nothing where it could have rendered most things.

The defect this prevents has not happened yet: there are no widgets. That is
why the guard lands now. Once a CatchRow reaches a screen, every widget test
above it needs a database and the generated class becomes public API a
schema change cannot move. The boundary is asserted in a test and gated in
CI with an explicit app/lib target, because check-drift-confinement.sh
prints SKIP and exits 0 on a missing directory — a defaulted path would pass
forever.

User-side mappers round-trip, including with every nullable field null: a
field silently dropped when a column is added is a catch that can no longer
restate what it was judged under.

Task: E05/T10
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
