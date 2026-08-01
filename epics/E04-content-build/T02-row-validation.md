# E04/T02 — Row validation: the build errors

| | |
|---|---|
| **Epic** | E04 — Content builder and the Galicia seed |
| **Branch** | `epic/04-content-build` (shared) |
| **Commit** | `feat(content_builder): fail the build on a rule row that violates a §7.1 constraint` |
| **Depends on** | T01 (the loader, the `Failure` type and the assertion registry) |
| **Size** | M |
| **Spec** | `SPEC.md` §8 bullet 1, §7.1 (every `CHECK` constraint) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rules 2 and 3, and `references/build-assertions.md` §"A1 — the required-when matrix", which is the authority on what is required *conditionally* rather than optionally |
| `catchlaw-rule-engine` | Rule 12 — a measurement is compared only against its own method, which is why the size/method pair is inseparable rather than validated after the fact |
| `catchlaw-reference-database` | The emitted file is content, never migrated; a row that violates a `CHECK` cannot be repaired later, so it must not be written |
| `testing-strategy` | One behaviour per test, and the table-driven loop naming rule |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.1 | Every `CHECK (… IN (…))` and the `max_size_mm >= min_size_mm` constraint, verbatim column names, and the nine measurement codes |
| `SPEC.md` | §8, bullet 1 | "a rule with `min_size_mm` and no `measurement_method_id` is a build error" |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | A1 row, "rules.yaml schema", "A1 — the required-when matrix", "Edge cases already caught" | The matrix, the mm-not-cm rule, the year-wrapping closure, the leap-day rejection |
| `.claude/skills/catchlaw-content-pipeline/SKILL.md` | Rule 3, "A size is a number AND a method" | The 6–9 cm TL/FL gap on a Kanaad — the reason this is an error and not a default |
| `.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh` | check 5 | The gate recognises only `TL`, `FL`, `CW`, `SHL`; the build must recognise all nine of §7.1 |
| `epics/CONVENTIONS.md` | §4, §7 | A missing rule is a gap to record, not a local convention to invent; a gate is a floor, not proof |

## What this delivers

- `tools/content_builder/lib/src/assert/a01_row_schema.dart` — `RowSchemaAssertion`, registered first
  in `ContentSource.assertions`.
- `tools/content_builder/lib/src/model/enums.dart` — the closed sets from `SPEC.md` §7.1 as Dart
  enums with their SQL spellings: `water_type`, `zone_kind`, `taxon_group`, `bag_limit_unit`,
  `bag_limit_period`, `gender`, `recurrence`, and the nine measurement codes.
- `tools/content_builder/test/assert/a01_row_schema_test.dart`.
- `tools/content_builder/testing/fixtures/yaml_fixtures.dart` — extended with the negative rows.
- A `GAPS` section in `content/README.md` recording the gate's four-code limitation.

## Why it is built this way

**`SPEC.md` §8 bullet 1 names one rule and means every constraint in §7.1.** The bullet says a rule
with `min_size_mm` and no `measurement_method_id` is a build error. The reason —
`catchlaw-content-pipeline` rule 3 — is that TL and FL differ by 6–9 cm on a *Scomberomorus
commerson*, so an inferred method turns a legal fish into a fine and a fine into a false acquittal.
Exactly the same argument applies to `water_type`, `zone_kind`, `bag_limit_period` and the rest: a
value outside the `CHECK` set either aborts the insert at emit time with a message about SQLite rather
than about the row, or — worse — is silently coerced by a lenient author. So A1 validates **every**
`CHECK` in §7.1 at authoring time, where the message can carry the file and line.

**Validation at load, not at insert.** SQLite would reject a bad `water_type` too. It would reject it
after every earlier row was written, with `CHECK constraint failed: zone` and no line number, and it
would reject only the first one. A1 collects **all** failures and sorts them, so one build round-trip
tells the author everything wrong with the corpus.

**The required-when matrix is data, not a chain of `if`s.** `build-assertions.md` publishes it as a
table; it is implemented as a table — `const _requiredWhen = <RuleKind, Set<String>>{…}` — so a new
rule kind adds a row rather than an `else if`. **Rejected:** one validator function per kind. Six
functions that each re-derive "does this row have a size" is how the protected-plus-size case gets
missed in exactly one of them.

**The mm range check backs up the unit rule.** `build-assertions.md` records a `min_size: 45`
intended as centimetres: A1's type check passes, because 45 is a valid integer. The recorded
mitigation is a range check — a finfish `min_size_mm` under 100 is flagged. It stays a **failure**,
not a warning, and the author clears a genuine sub-100 mm finfish rule by authoring
`min_size_mm_confirmed: true` on that row. That keeps the check fatal while leaving an audit trail;
`catchlaw-content-pipeline` rule 2 has no warning tier to put it in.

**Bivalves and crustaceans are exempt from the range check, and that is not a loophole.** *Venerupis
corrugata* is 38 mm shell length — a legitimate two-digit millimetre value. The check is scoped by
`species.taxon_group`, which §7.1 already requires.

**Rejected: silently accepting a `02-29` season boundary.** `build-assertions.md` rejects it outright
and tells the author to write `02-28` or `03-01`. Three years in four a leap-day boundary is a date
that does not exist, and a closure that silently shifts by a day in three years out of four is the
kind of defect nobody finds.

**Recorded gap, per `CONVENTIONS.md` §4.** `check_content_pipeline.sh` check 5 matches
`measurement_method:[[:space:]]*(TL|FL|CW|SHL)`, but `SPEC.md` §7.1 declares nine codes and Galicia
needs `CL` for *Maja squinado*. A row authored with `CL` is correct and still trips the gate, and
check 5 does not honour `content-pipeline-ok`. This task does **not** invent a local workaround: the
gap is written into `content/README.md`, the build tool validates against the full §7.1 list and is
authoritative, and widening the gate's regex is a skill edit outside this epic.

## Tests first

Write every row before touching `a01_row_schema.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `RowSchemaAssertion reports A1 when min_size_mm has no measurement_method_id` | rule row, `min_size_mm: 450`, no method | one `A1` at that line | The headline case, `SPEC.md` §8 bullet 1 |
| 2 | `RowSchemaAssertion reports A1 when max_size_mm has no measurement_method_id` | `max_size_mm: 1200`, no method | one `A1` | A slot rule's upper bound needs a method just as much as its lower one |
| 3 | `RowSchemaAssertion accepts a rule with min_size_mm and a measurement_method_id` | `min_size_mm: 450`, `measurement_method_id: TL` | no failures | The passing case — an assertion with no green path fails everything |
| 4 | `RowSchemaAssertion reports A1 when max_size_mm is below min_size_mm` | `min 500`, `max 450` | one `A1` | The one `CHECK` in §7.1 that is an inequality rather than a set |
| 5 | `RowSchemaAssertion reports A1 when a protected row carries a size threshold` | `is_protected: 1`, `min_size_mm: 450` | one `A1` | A measurement implies a threshold that does not exist; the ladder headlines `protected` and the size would never be read |
| 6 | `RowSchemaAssertion reports A1 when water_type is outside the §7.1 set` (loop over `salt`, `fresh`, `both`, `marine`) | `water_type: $value` | failure only for `marine` | `marine` is what a careful author writes and §7.1 does not accept |
| 7 | `RowSchemaAssertion reports A1 when zone_kind is outside the §7.1 set` | `zone_kind: sector` | one `A1` | Six kinds drive the specificity ladder; a seventh has no rank |
| 8 | `RowSchemaAssertion reports A1 when taxon_group is outside the §7.1 set` | `taxon_group: mollusc` | one `A1` | §7.1 splits molluscs into bivalve, gastropod and cephalopod; the collapse loses the identification key's entry point |
| 9 | `RowSchemaAssertion reports A1 when a bag_limit has no unit` | `bag_limit: 5`, no `bag_limit_unit` | one `A1` | "5" per what — count or kg |
| 10 | `RowSchemaAssertion reports A1 when a bag_limit has no period` | `bag_limit: 5`, `bag_limit_unit: count`, no period | one `A1` | Per day, per trip and per season are three different limits |
| 11 | `RowSchemaAssertion reports A1 when a closed_season has no start or end` | `recurrence: annual`, no `start_month` | one `A1` | A closure with no window applies for zero days or for ever, and both are wrong |
| 12 | `RowSchemaAssertion reports A1 when a closed_season starts on 02-29` | `start_month: 2, start_day: 29` | one `A1` | A boundary that exists in one year of four shifts silently in the other three |
| 13 | `RowSchemaAssertion reports A1 when an annual closure wraps the year without wraps_year` | `11-01` to `02-28` | one `A1` | A wrapping closure is legal and must be declared, not inferred from `end < start` |
| 14 | `RowSchemaAssertion accepts a wrapping closure with wraps_year true` | same row plus `wraps_year: true` | no failures | The declared form must actually be shippable |
| 15 | `RowSchemaAssertion reports A1 when valid_from is after valid_to` | `2026-05-01` to `2025-05-01` | one `A1` | A dead validity window is always a typo, and the engine would resolve nothing for that lineage |
| 16 | `RowSchemaAssertion reports A1 when a finfish min_size_mm is under 100` | `taxon_group: finfish`, `min_size_mm: 45` | one `A1` | 45 cm typed as 45 mm; the row validates and the verdict is wrong by a factor of ten |
| 17 | `RowSchemaAssertion accepts a bivalve min_size_mm of 38` | `taxon_group: bivalve`, `min_size_mm: 38` | no failures | *Venerupis corrugata* is genuinely 38 mm shell length — the range check must be scoped by taxon group |
| 18 | `RowSchemaAssertion accepts a finfish min_size_mm under 100 with min_size_mm_confirmed` | `min_size_mm: 90`, `min_size_mm_confirmed: true` | no failures | The audited escape; without it the check would eventually be deleted rather than answered |
| 19 | `RowSchemaAssertion accepts every §7.1 measurement code` (loop over the nine) | `measurement_method_id: $code` | no failures for any | The build is authoritative over the gate's four-code grep |
| 20 | `RowSchemaAssertion reports every failure in one pass, sorted by file then line` | three broken rows in two files | three failures in file-then-line order | One build round-trip must tell the author everything; SQLite would report only the first |

```dart
// tools/content_builder/test/assert/a01_row_schema_test.dart
import 'package:content_builder/src/assert/a01_row_schema.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('RowSchemaAssertion', () {
    test('reports A1 when min_size_mm has no measurement_method_id', () {
      final source = YamlSource.fromString(
        kMinSizeWithoutMethodYaml,
        displayPath: 'content/es-ga/rules.yaml',
      );
      final failures = const RowSchemaAssertion().run(source).toList();

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A1');
      expect(failures.single.render(),
          'A1 content/es-ga/rules.yaml:4 min_size_mm without measurement_method_id');
    });

    for (final value in const ['salt', 'fresh', 'both', 'marine']) {
      test('reports A1 when water_type is outside the §7.1 set (water_type:$value)', () {
        final source = YamlSource.fromString(
          kRuleWithWaterType(value),
          displayPath: 'content/es-ga/rules.yaml',
        );
        final failures = const RowSchemaAssertion().run(source).toList();

        expect(failures, value == 'marine' ? hasLength(1) : isEmpty);
      });
    }

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/assert/a01_row_schema_test.dart)` → 20 failing
tests (the loops counted per interpolated case). If any passes now, the test is wrong.

## Implementation outline

1. `lib/src/model/enums.dart` — one enum per closed set, each carrying its SQL spelling. Read the
   spellings out of `SPEC.md` §7.1, not out of memory.
2. `RowSchemaAssertion.run(ContentSource) sync* → Iterable<Failure>`, one `yield` per violation. No
   early return: a row with two problems reports two failures.
3. The required-when matrix as a `const` map keyed by rule kind, mirroring
   `build-assertions.md`'s table row for row.
4. Set membership checked through the enums, so an unknown value is a lookup miss with the offending
   string in the message and the legal set listed after it.
5. The inequality checks — `max >= min`, `valid_from <= valid_to`, the wrapping closure — after the
   set checks, so a row with a bad `water_type` does not also report a spurious range error.
6. The taxon-scoped range check last, since it needs the species join.
7. Register the assertion in `ContentSource.assertions`; `main` sorts the whole list by path then
   line before printing (T01's contract).
8. Add the gate limitation to `content/README.md` under `GAPS`.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 tests pass, and each failed first.
- [ ] 100 % branch coverage on `lib/src/assert/a01_row_schema.dart`.
- [ ] Every `CHECK` constraint printed in `SPEC.md` §7.1 has a test above that trips it.
- [ ] A build over a fixture corpus with one A1 failure exits 1 and writes no `.db`.
- [ ] No failure path prints a stack trace; every one is one line of `A1 <file>:<line> <message>`.
- [ ] `content/README.md` records the `check_content_pipeline.sh` check-5 gap and names the build tool
      as authoritative.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content_builder): fail the build on a rule row that violates a §7.1 constraint

SPEC.md §8 names one build error — min_size_mm with no measurement_method_id —
and the argument behind it covers every CHECK in §7.1. TL and FL differ by
6-9 cm on a Kanaad, so an inferred method turns a legal fish into a fine; a
water_type of 'marine' or a taxon_group of 'mollusc' fails the same way, later
and more quietly.

Validation runs at load rather than at insert. SQLite would reject the row
too, after writing every earlier one, with no line number and only the first
offender named. A1 collects every failure and sorts them by file and line, so
one build round-trip tells the author everything wrong with the corpus.

The sub-100 mm finfish range check stays fatal: a min_size of 45 typed as
millimetres validates cleanly and is wrong by a factor of ten. A genuine
sub-100 mm rule is cleared with min_size_mm_confirmed, which leaves an audit
trail; there is no warning tier to put it in.

check_content_pipeline.sh check 5 recognises only TL, FL, CW and SHL while
§7.1 declares nine codes. Recorded in content/README.md as a gap rather than
worked around locally.

Task: E04/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
