# E04/T06 — The plate test: illustrator, death year, eighty years

| | |
|---|---|
| **Epic** | E04 — Content builder and the Galicia seed |
| **Branch** | `epic/04-content-build` (shared) |
| **Commit** | `feat(content_builder): clear plates on the illustrator death year, not the publication date` |
| **Depends on** | T02 (`Failure`, the registry) |
| **Size** | M |
| **Spec** | `SPEC.md` §8 "The public-domain test for plates — corrected", §8 bullet 6, §7.1 `species.plate_asset` |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rules 7 and 8, and `references/licence-provenance.md` — the term ladder per jurisdiction, the plate ledger fields and the drop rules |
| `catchlaw-conventions-index` | Rule 9, routing: the licence question belongs to the content pipeline, and the rendering of a cleared plate belongs to `lonja-icons-and-plates` and E18 |
| `testing-strategy` | Boundary-value tests are the whole content of this task; one behaviour per test |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, "The public-domain test for plates — corrected" | The two `require(...)` lines verbatim, the 80-year term, the Jordan & Evermann exclusion, and "Any plate whose artist cannot be identified is dropped" |
| `SPEC.md` | §8, bundled-data table, "Detailed plates (optional)" | Bloch (d. 1799), Cuvier (d. 1832), Valenciennes (d. 1865); ~25 MB; `assets/plate/`; per-image clearance required |
| `SPEC.md` | §7.1, `species` | `plate_asset TEXT` — nullable, "optional; cleared per §8". A dropped plate is a NULL, not a placeholder |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "Plates: the illustrator death-year test", "Worked decisions", "`plates.yaml` required fields", "Drop rules" | The term ladder, the four worked decisions, the eleven ledger fields, and the four drop rules |
| `.claude/skills/catchlaw-content-pipeline/SKILL.md` | Rules 7, 8; "Plates: the death-year test, not the publication-date test" | `termFor` and `clearToBundle` in the shape the build must implement |
| `.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh` | checks 3 and 7 | The awk block scan over `*plate*.yaml`, its treatment of `unknown`/`unidentified`/`TBD`, and the ban on a publication-date comparison anywhere in the tree |
| `epics/CONVENTIONS.md` | §7 | The gate is a heuristic floor; this assertion is the proof |

## What this delivers

- `tools/content_builder/lib/src/assert/a06_plate_licence.dart` — `PlateLicenceAssertion`, with
  `int termFor(int deathYear)` and `bool clearToBundle(PlateSpec, int buildYear)`.
- `tools/content_builder/lib/src/model/plate_spec.dart` — the eleven ledger fields from
  `licence-provenance.md`, with `origin` as an enum (`publicDomain`, `originated`).
- `content/shared/plates.yaml` — the ledger, one block per plate.
- `content/ATTRIBUTIONS/plates.md` — **generated** from `plates.yaml` on every build: plate id,
  species, illustrator, death year, source work and year, licence, cleared on, cleared by. E18
  assembles the full `ATTRIBUTIONS.md` and renders S17; this is its plate section, generated so it
  cannot drift from the data it describes.
- `tools/content_builder/test/assert/a06_plate_licence_test.dart`.

## Why it is built this way

**The first draft's test was the American one, and this app ships nowhere the American rule applies.**
`SPEC.md` §8 says it outright: *"pre-1930 = public domain" is the US rule and is the wrong test for
every market this app ships to.* Publication date is irrelevant. The test runs from the illustrator's
death, and the term is the longest among the jurisdictions in the bundle:

| Jurisdiction | Term | Source |
|---|---|---|
| Spain, author died before 1987-12-07 | life + **80** | TRLPI transitional regime — the longest we ship into |
| EU, including Galicia within Spain | life + 70 | Directive 2006/116/EC |
| Brazil | life + 70 | Lei 9.610/1998 art. 41 |
| UAE | life + 50 | Berne minimum |

So `termFor(deathYear) => deathYear <= 1987 ? 80 : 70`, and
`clearToBundle(p, y) => p.illustrator != null && p.illustratorDeathYear != null && y >
p.illustratorDeathYear! + termFor(p.illustratorDeathYear!)`. For a 2026 build the illustrator must
have died in **1945 or earlier**; 1946 fails. The test ratchets: a 2027 build clears 1946 with no code
change, because the build year is input (T01's `--build-date`).

**The build year is input, not `DateTime.now().year`.** `licence-provenance.md` says the build year is
`DateTime.now().year` at build time. This epic takes it from `--build-date` instead, for two reasons
that both matter here: T10 requires a byte-identical rebuild from identical input, and a plate that
re-clears itself at midnight on 1 January produces a different database from the same corpus with no
diff to show for it. The audit property `licence-provenance.md` actually wants — an old `.db` can be
audited against the year it was made — is preserved, because the build date is recorded in
`content_meta`. **Rejected:** reading the clock; **rejected:** a separate `--build-year`, because two
sources for one fact will disagree.

**An unattributable plate is deleted from `plates.yaml`, not flagged.**
`catchlaw-content-pipeline` rule 8: `licence: unknown` and `review: later` are states that ship. A6
therefore fails on a block whose `illustrator` is absent **or** is the literal `unknown`,
`unidentified` or `TBD` — the same three strings `check_content_pipeline.sh` check 3 looks for, so the
build is never laxer than the grep. The failure message is the instruction:
`A6 content/shared/plates.yaml:56 illustrator unidentified — DROP the plate`.

**Jordan & Evermann are named in the fixture, because the spec names them.** `SPEC.md` §8: Jordan
(d. 1931) and Evermann (d. 1932) clear the test, but they are the **authors**; the plates were drawn
by staff illustrators who are a separate question the first draft simply missed. A6 tests the
illustrator field and nothing else, and one test row encodes exactly that trap — a block whose
`illustrator` has been filled in with the author's name and death year is *not* detectable by code,
so the defence is the ledger review and the wording of the field name. What code can do is refuse a
block with no illustrator at all, and that is what it does.

**`origin: originated` skips the death-year test and keeps the ledger.** Our commissioned SVG art —
the silhouettes, the measurement diagrams, and every diagram for a Brazilian rule, because Lei 9.610
art. 8 IV covers only *os textos* — has no death year to test. It still needs `licence` (the
work-for-hire agreement id), `cleared_on` and `cleared_by`, because S17 renders the whole ledger. A6
checks the ledger fields on every block and the death-year test only on `origin: public_domain`.

**A dropped plate leaves `species.plate_asset` NULL.** `SPEC.md` §7.1 marks the column nullable and
"cleared per §8". A6 additionally fails when a `species` row names a `plate_asset` that has no cleared
ledger block, which is the path by which a dropped plate leaves a dangling asset reference behind.
The Galicia seed is expected to ship with zero cleared plates; that is a valid corpus and case 12
proves it.

**No publication-date comparison may exist anywhere in the tree.**
`check_content_pipeline.sh` check 7 greps for `published_year < 1930` and its variants across Dart and
YAML. `source_year` stays in the ledger as **evidence about the artist** and is never compared to a
threshold. A test greps the package's own source for such a comparison, so the ban is proved by the
suite and not only by the gate.

## Tests first

Write every row before touching `a06_plate_licence.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `termFor returns 80 for a death year of 1987` | `1987` | `80` | The TRLPI transitional boundary, on the boundary |
| 2 | `termFor returns 70 for a death year of 1988` | `1988` | `70` | The other side of the same boundary |
| 3 | `clearToBundle clears an illustrator who died in 1945 for a 2026 build` | d. 1945, y. 2026 | `true` | `1945 + 80 = 2025`, and `2026 > 2025` — the last year that clears |
| 4 | `clearToBundle rejects an illustrator who died in 1946 for a 2026 build` | d. 1946, y. 2026 | `false` | `1946 + 80 = 2026`, and `2026 > 2026` is false — the off-by-one that would ship a plate a year early |
| 5 | `clearToBundle clears an illustrator who died in 1946 for a 2027 build` | d. 1946, y. 2027 | `true` | The ratchet works, and it works because the year is input |
| 6 | `clearToBundle clears Bloch, died 1799` | d. 1799, y. 2026 | `true` | `licence-provenance.md`'s worked bundled decision |
| 7 | `clearToBundle rejects an illustrator who died in 1958` | d. 1958, y. 2026 | `false` | The worked rejected decision — still in term in the EU and Brazil in 2028 |
| 8 | `PlateLicenceAssertion reports A6 when illustrator is absent` | no `illustrator` | one `A6`, message ends `DROP the plate` | Rule 8; the message is the instruction |
| 9 | `PlateLicenceAssertion reports A6 when illustrator is $value` (loop over `unknown`, `unidentified`, `TBD`) | `illustrator: $value` | one `A6` per case | The three strings the gate looks for; the build must not be laxer than the grep |
| 10 | `PlateLicenceAssertion reports A6 when illustrator_death_year is absent` | named illustrator, no year | one `A6` | An unknown death year is not an early one |
| 11 | `PlateLicenceAssertion reports A6 when a public_domain plate is still in term` | d. 1958 | one `A6` quoting the death year | The commonest real rejection: a credited 20th-century artist |
| 12 | `PlateLicenceAssertion accepts a corpus with no plates at all` | empty `plates.yaml` | no failures | The Galicia seed ships zero cleared plates and must still build |
| 13 | `PlateLicenceAssertion skips the death-year test for origin originated` | in-house diagram, no death year | no failures | Commissioned art has no death year to test |
| 14 | `PlateLicenceAssertion reports A6 when an originated plate has no licence id` | `origin: originated`, no `licence` | one `A6` | The ledger row is mandatory for originated art too — S17 renders it |
| 15 | `PlateLicenceAssertion reports A6 when a ledger field is missing` (loop over `species_id`, `source_work`, `source_year`, `source_url`, `cleared_on`, `cleared_by`) | block missing `$field` | one `A6` per case | Six of the eleven fields; an incomplete ledger is an unanswerable S17 row |
| 16 | `PlateLicenceAssertion reports A6 when a species names a plate_asset with no cleared block` | `plate_asset` set, plate dropped | one `A6` at the species line | The dangling reference a drop leaves behind |
| 17 | `PlateLicenceAssertion accepts a species with a null plate_asset` | `plate_asset` absent | no failures | §7.1 makes it optional; the seed relies on that |
| 18 | `content_builder declares no publication-year licence comparison` | the package's own `lib/` and `content/` | no match | `check_content_pipeline.sh` check 7, proved by the suite as well as by the gate |
| 19 | `PlateLicenceAssertion writes the plate ledger with every cleared plate` | two cleared plates | `content/ATTRIBUTIONS/plates.md` lists both with illustrator and death year | `SPEC.md` §8: every plate's illustrator and death year is recorded and rendered in S17 |

```dart
// tools/content_builder/test/assert/a06_plate_licence_test.dart
import 'package:content_builder/src/assert/a06_plate_licence.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('clearToBundle', () {
    test('clears an illustrator who died in 1945 for a 2026 build', () {
      expect(clearToBundle(kPlateDied(1945), 2026), isTrue);
    });

    test('rejects an illustrator who died in 1946 for a 2026 build', () {
      expect(clearToBundle(kPlateDied(1946), 2026), isFalse);
    });

    test('clears an illustrator who died in 1946 for a 2027 build', () {
      expect(clearToBundle(kPlateDied(1946), 2027), isTrue);
    });
  });

  group('PlateLicenceAssertion', () {
    for (final value in const ['unknown', 'unidentified', 'TBD']) {
      test('reports A6 when illustrator is $value', () {
        final source = contentSourceWithPlate(illustrator: value);
        final failures = const PlateLicenceAssertion(buildYear: 2026).run(source).toList();

        expect(failures, hasLength(1));
        expect(failures.single.render(), endsWith('illustrator unidentified — DROP the plate'));
      });
    }

    test('accepts a corpus with no plates at all', () {
      expect(const PlateLicenceAssertion(buildYear: 2026).run(kEmptyPlateSource), isEmpty);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/assert/a06_plate_licence_test.dart)` → every
case red. If any passes now — particularly case 4, which a naive `>=` makes pass — the test is not
wrong; the *implementation you have not written yet* would already be wrong. Check that the fixture
really is 1946 against a 2026 build before touching anything.

## Implementation outline

1. `PlateSpec` with the eleven fields from `licence-provenance.md`, `origin` as an enum, all fields
   nullable at parse time so A6 can report which one is missing rather than crashing on load.
2. `termFor` and `clearToBundle` as top-level functions with the exact shape the skill publishes —
   they are quoted in two places and must be greppable in one.
3. `PlateLicenceAssertion(buildYear:)`, constructed from `options.buildDate.year` in `run.dart`.
4. Ledger-field completeness first, then the illustrator checks, then the term test. A block missing
   six fields reports six failures, because the author is going to fix all six.
5. The species cross-check: every `plate_asset` names a plate id that is present and cleared.
6. Ledger emission into `content/ATTRIBUTIONS/plates.md`, sorted by species id then plate id, written
   only when the whole build has no failures (T01's four-phase contract).
7. Register after A5.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 rows pass, and each failed first.
- [ ] 100 % branch coverage on `lib/src/assert/a06_plate_licence.dart`, including both sides of the
      1987 term boundary and both sides of the `> deathYear + term` boundary.
- [ ] `grep -rniE 'published_?year|publication_?year|pre-?1930' tools/content_builder/lib content`
      finds no comparison against a threshold.
- [ ] `content/ATTRIBUTIONS/plates.md` is generated, committed, and regenerating it produces no diff.
- [ ] The Galicia seed builds with zero cleared plates and every `species.plate_asset` NULL.
- [ ] The `plates.yaml` documentation in `content/README.md` names the Jordan & Evermann trap in the
      words `SPEC.md` §8 uses: the authors clear the test, the staff illustrators are a separate
      question.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content_builder): clear plates on the illustrator death year, not the publication date

SPEC.md §8 corrects the first draft in one line: "pre-1930 = public domain" is
the US rule and is the wrong test for every market this app ships to. The test
runs from the illustrator's death, against the longest term in the bundle —
Spain's TRLPI transitional regime gives 80 years pma to authors who died
before 7 December 1987, which outlives the EU's and Brazil's 70 and the UAE's
50. For a 2026 build the artist must have died in 1945 or earlier; 1946 fails
by one year and clears in 2027.

The build year comes from --build-date rather than the clock. A plate that
re-clears itself at midnight on 1 January produces a different database from
the same corpus with no diff to show for it, and T10 requires a byte-identical
rebuild.

An unattributable plate is deleted from plates.yaml, never flagged: `licence:
unknown` and `review: later` are states that ship. The build rejects the same
three strings the gate greps for, so it can never be laxer than the grep.
Jordan & Evermann are documented as the named trap — the authors clear the
test and the staff illustrators are a separate question no code can answer.

origin: originated skips the death-year test and keeps the full ledger row,
because S17 renders it. content/ATTRIBUTIONS/plates.md is generated from the
ledger so it cannot drift from what actually shipped.

Task: E04/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
