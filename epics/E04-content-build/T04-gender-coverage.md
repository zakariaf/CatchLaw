# E04/T04 — Gender is non-NULL in every gendered locale

| | |
|---|---|
| **Epic** | E04 — Content builder and the Galicia seed |
| **Branch** | `epic/04-content-build` (shared) |
| **Commit** | `feat(content_builder): fail the build on a null gender in ar, es, gl, ca or pt_BR` |
| **Depends on** | T03 (`kShippedLocales`) |
| **Size** | S |
| **Spec** | `SPEC.md` §8 bullet 3, §9.5 "Gender", §7.1 `species_name` |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rule 5 and `references/build-assertions.md` A3 — the gendered-locale set, the failure message, and the one-preferred-name-per-locale rule that rides with it |
| `catchlaw-conventions-index` | Rule 12, six locales in one PR; and the register argument — a document that reads machine-translated is not believed when it states a prohibition |
| `testing-strategy` | The locale loop must interpolate the locale into the description or `--plain-name` is useless |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, bullet 3 | "assert every `species_name` row in a gendered locale (`ar`, `es`, `gl`, `ca`, `pt_BR`) has a non-NULL `gender`" |
| `SPEC.md` | §9.5, "Gender" | Why the field exists at all, and the first draft's defect: ICU `select` specified on a field that existed nowhere in the schema |
| `SPEC.md` | §7.1, `species_name` | The column and its `CHECK (gender IN ('m','f','n'))`, and `is_primary` |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | A3 row, "A2 and A3 — locale coverage and gender" | The failure shape, and "Exactly one `is_preferred: true` per (species, locale)" |
| `.claude/skills/catchlaw-content-pipeline/SKILL.md` | Rule 5 | "la mero" — the register failure this prevents |
| `epics/DECISIONS.md` | D-3 | Catalan is gendered and ships; Urdu does not exist here |

## What this delivers

- `tools/content_builder/lib/src/locales.dart` — extended with
  `const kGenderedLocales = <String>{'ar', 'ca', 'es', 'gl', 'pt_BR'};`
- `tools/content_builder/lib/src/assert/a03_gender.dart` — `GenderAssertion`.
- `tools/content_builder/test/assert/a03_gender_test.dart`.
- `content/shared/vernacular.yaml` — the authored shape carrying `gender` and `is_primary`.

## Why it is built this way

**Five of six locales, and `en` is the exception rather than the rule.** `SPEC.md` §8 bullet 3 lists
`ar`, `es`, `gl`, `ca` and `pt_BR`. `kGenderedLocales` is therefore
`kShippedLocales.toSet().difference({'en'})` in meaning but is written out literally, because a set
derived by subtraction silently absorbs whatever the seventh locale turns out to be. A new locale
should force a decision about its grammar, not inherit one.

**The field is asserted, not defaulted.** `SPEC.md` §9.5 records the first draft's defect precisely:
ICU `select` was specified on a gender field that existed nowhere in the schema. The correction is
that the column exists **and** is guaranteed populated, because a `select` on a null argument renders
the `other` branch, which in Spanish is one of the two genders and is therefore wrong half the time.
**Rejected:** defaulting to `m`. "La lubina" is feminine; a default that is right 50 % of the time
across ~2,400 vernacular names (`SPEC.md` §8) is roughly 1,200 wrong articles, and
`catchlaw-content-pipeline` rule 5 states the consequence — a document that reads machine-translated
is not believed when it states a prohibition.

**`n` is legal and Spanish will never use it.** `SPEC.md` §7.1 permits `m`, `f` and `n`. A3 checks
membership in that set, not in `{m, f}`: the schema is authoritative, and a locale added later may
need the neuter. A value outside the three is a failure with the offending string quoted.

**`is_primary` uniqueness lives here, not in T02.** `build-assertions.md` puts it under A3, and the
reason is the same reason gender is here: both are properties of a `species_name` row that only bite
when the app renders a name. Exactly one `is_primary` per `(species_id, locale)` — zero means S5's
result row has no name to print, two means the result screen and the species list print different
names for the same fish, which reads as two species.

**`en` carrying a gender is not an error.** The Catalogue of Life vernacular extension is the sole
source for English (`SPEC.md` §9.2 step 2) and does not supply gender, so English rows will not carry
one; but a row that does carry a valid value is harmless and failing it would be a rule with no
victim. A3 checks the *value* on every row and the *presence* only on gendered locales.

## Tests first

Write every row before touching `a03_gender.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `GenderAssertion reports A3 when gender is null for $locale` (loop over the five gendered locales) | a `species_name` row in `$locale` with no `gender` | one `A3` naming `$locale` | Five locales, five chances to be wrong; a loop naming only `es` proves nothing about `ca` |
| 2 | `GenderAssertion accepts a null gender for en` | an `en` row with no `gender` | no failures | English has no gendered source and must not be forced to invent one |
| 3 | `GenderAssertion accepts m, f and n` (loop over the three) | `gender: $value` in `es` | no failures for any | `SPEC.md` §7.1's `CHECK` set, not the skill's narrower `m|f` |
| 4 | `GenderAssertion reports A3 when gender is outside the §7.1 set` | `gender: fem` | one `A3` quoting `fem` | The value an author writes when copying from a dictionary |
| 5 | `GenderAssertion reports A3 when a species has no is_primary name for $locale` (loop over the six) | two names, both `is_primary: false` | one `A3` | S5 has no name to print, in a locale nobody tested |
| 6 | `GenderAssertion reports A3 when a species has two is_primary names for one locale` | two names, both true | one `A3` naming both lines | The result screen prints one and the species list prints the other, and the fisher sees two fish |
| 7 | `GenderAssertion accepts exactly one is_primary name per species and locale` | one true, two false | no failures | The green path |
| 8 | `GenderAssertion reports one failure per offending row, not per species` | three bad rows on one species | three `A3` failures | An author fixing a paste of thirty names needs all thirty lines, not one |
| 9 | `kGenderedLocales holds exactly ar, ca, es, gl and pt_BR` | — | the five | D-3 plus `SPEC.md` §8 bullet 3, pinned so `ur` cannot return and `en` cannot be added |

```dart
// tools/content_builder/test/assert/a03_gender_test.dart
import 'package:content_builder/src/assert/a03_gender.dart';
import 'package:content_builder/src/locales.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('GenderAssertion', () {
    for (final locale in kGenderedLocales) {
      test('reports A3 when gender is null for $locale', () {
        final source = contentSourceWithName(locale: locale, gender: null);
        final failures = const GenderAssertion().run(source).toList();

        expect(failures, hasLength(1));
        expect(failures.single.id, 'A3');
        expect(failures.single.message, 'gender null for locale $locale');
      });
    }

    test('accepts a null gender for en', () {
      final source = contentSourceWithName(locale: 'en', gender: null);
      expect(const GenderAssertion().run(source), isEmpty);
    });

    test('reports A3 when a species has two is_primary names for one locale', () {
      final source = contentSourceWithPrimaryCount(locale: 'gl', primaries: 2);
      final failures = const GenderAssertion().run(source).toList();

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('is_primary'));
    });

    test('kGenderedLocales holds exactly ar, ca, es, gl and pt_BR', () {
      expect(kGenderedLocales.toList()..sort(), ['ar', 'ca', 'es', 'gl', 'pt_BR']);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/assert/a03_gender_test.dart)` → every case red.
If any passes now, the test is wrong.

## Implementation outline

1. Add `kGenderedLocales` to `lib/src/locales.dart`, written out literally, with a comment naming
   `SPEC.md` §8 bullet 3 and D-3.
2. `GenderAssertion.run(ContentSource) sync*`: one pass over `speciesNames`, yielding a failure per
   offending row rather than per species.
3. Presence check gated on `kGenderedLocales.contains(row.locale)`; value check on every row that
   carries one.
4. Group by `(speciesId, locale)` for the `is_primary` count; zero and two-or-more are separate
   messages, because the fixes are different.
5. Register after A2 in `ContentSource.assertions`.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 9 rows pass, and each failed first.
- [ ] 100 % branch coverage on `lib/src/assert/a03_gender.dart`.
- [ ] `kGenderedLocales` contains no `ur` and no `en`.
- [ ] A fixture corpus with one null `ca` gender exits 1 and writes no `.db`.
- [ ] No code path anywhere in `tools/content_builder/` supplies a default gender.

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
feat(content_builder): fail the build on a null gender in ar, es, gl, ca or pt_BR

SPEC.md §9.5 records the first draft's defect exactly: ICU select was
specified on a gender field that existed nowhere in the schema. The column now
exists and is guaranteed populated, because select on a null argument renders
the `other` branch — in Spanish that is one of the two genders, so it is wrong
half the time.

A default of `m` was rejected. "La lubina" is feminine, and at the ~2,400
vernacular names §8 sizes the corpus at, a 50% default is roughly 1,200 wrong
articles. A document that reads machine-translated is not believed when it
states a prohibition.

`n` is accepted because §7.1's CHECK permits it; the schema is authoritative
over the skill's narrower m|f. `en` may omit gender — the Catalogue of Life
vernacular extension is its only source (§9.2 step 2) and supplies none.

The one-is_primary-per-(species, locale) rule rides here for the same reason:
zero leaves S5 with no name to print, two make the result screen and the
species list disagree about what the fish is called.

Task: E04/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
