# E06/T02 — CI: every key everywhere, and the right plural categories

| | |
|---|---|
| **Epic** | E06 — Localisation infrastructure |
| **Branch** | `epic/06-localisation` (shared) |
| **Commit** | `ci(l10n): fail the build on a missing ARB key or a wrong plural category` |
| **Depends on** | T01 (six ARB files with one plural message must exist) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.5 plurals; §13 "Localisation completeness"; §14 static checklist row 5 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `i18n-rtl-l10n` | Ships `scripts/check_arb_parity.sh` — the key/placeholder gate this task **reuses rather than reimplements**, and `references/arb-and-icu.md` for why a missing category is a release blocker, not a cosmetic gap |
| `catchlaw-conventions-index` | Rule 10: a general rule is never forked into this repo. Key parity is a general rule and stays in the plugin; the CLDR category table is app law and lands here |
| `testing-strategy` | Rule 3 — assert the invariant, not the example. The checker itself is code and gets its own fixtures; the toolchain's CLDR data gets a live interrogation |
| `naming-conventions` | The helper file must not end in `_test.dart`; `lowerCamelCase` for the category constants |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.5 "Plurals" | The whole rule, including both corrections: `ar` needs all six; `es`, `ca` and `pt` each carry `many`; only `gl` is `one`/`other`. Cite it, do not re-derive it |
| `SPEC.md` | §13, "Localisation completeness" row | "CI fails on any ARB key missing from any locale, and on any `ar` plural missing a category" — the requirement in one line |
| `SPEC.md` | §14, static row 5 | The same requirement as a release gate |
| `epics/CONVENTIONS.md` | §7 | A gate that scans an empty tree reports success — the failure mode that makes a gate worse than none |
| `epics/DECISIONS.md` | D-1 | Gates take an explicit target directory or they exit 2 |
| `epics/DECISIONS.md` | D-3 | Which six locales the category table has rows for |
| `.claude/skills/i18n-rtl-l10n/references/arb-and-icu.md` | "ICU — always, never concatenation", "Step-by-step" | `=0`/`=1` are exact-value matches that win over categories and are legal extras; a missing category is a release blocker |
| `.claude/skills/i18n-rtl-l10n/scripts/check_arb_parity.sh` | whole | What it already covers — message keys and placeholder names — so this task covers only what it does not |

## What this delivers

- `app/test/l10n/arb_rules.dart` — the pure checker. Helper, **not** `_test.dart`
  (`CONVENTIONS.md` §6, `FLUTTER_GUIDE.md` §6.2: a helper ending in `_test.dart` is executed as an
  empty suite and fails the run).
  - `Set<String> requiredCategoriesFor(String locale)` — the CLDR-48 table from `SPEC.md` §9.5.
  - `List<ArbFinding> missingCategories(Map<String, String> arbByLocale)`.
  - `List<ArbFinding> unexpectedCategories(Map<String, String> arbByLocale)`.
- `app/test/l10n/arb_rules_test.dart` — the checker's own unit tests, over fixtures.
- `app/test/l10n/arb_plural_categories_test.dart` — the live assertion over `app/lib/l10n`, plus the
  `Intl.plural` interrogation of the toolchain's own CLDR data.
- `app/test/l10n/fixtures/` — small deliberately-broken ARB sets (`missing_many_es/`,
  `ar_from_es/`, `gl_with_few/`, `exact_zero_branch/`).
- `.github/workflows/validate.yml` — two steps added to the job E01 created for the Flutter app:
  `check_arb_parity.sh app/lib/l10n`, and `flutter test test/l10n`. If E01 named that job something
  other than what this task assumes, the steps go wherever `flutter analyze` already runs.

## Why it is built this way

**Two mechanisms, because there are two different rules.** Key and placeholder parity is a general
Flutter rule: every locale carries the template's keys with the same `{placeholder}` names. That rule
already has a maintained implementation in `i18n-rtl-l10n/scripts/check_arb_parity.sh`, and
`catchlaw-conventions-index` rule 10 forbids forking it into this repo — a forked rule drifts from its
origin within two PRs. So parity is *wired*, not written.

The plural-category table is different. It is not general Flutter practice; it is a per-locale CLDR
fact that `SPEC.md` §9.5 records for exactly the six locales this product ships, twice corrected. No
plugin script checks it. That is the part this task writes.

**The check is a Dart test, not a shell script.** ICU messages need parsing — `{count, plural, few{…}
many{…} other{…}}` cannot be greped without producing either false positives on the word `many` inside
a translation or false negatives on a nested placeholder. D-8's precedent (a grep gate in
`tools/gates/`) applies to geometry, where a regex is genuinely sufficient. Here it is not, and calling
a parser a grep would be the same small inaccuracy D-8 exists to avoid.

**The checker gets fixtures because the checker is the gate.** `CONVENTIONS.md` §7 records the failure
that makes a gate worse than no gate: a scan over an empty tree reports success. The equivalent here is
a checker that returns `[]` because its ICU regex never matched anything. Four broken fixture sets,
each red for a different reason, is what stops that.

**The toolchain's CLDR data is interrogated directly.** `SPEC.md` §9.5's table is a document, and a
document cannot tell you what `intl` will actually select at runtime. So the live rows call
`Intl.plural` for `ar` at 0, 2, 3, 11 and 100 and for `es` and `gl` at 1 000 000. If the resolved
`intl` carries older plural rules than CLDR 48, a `many` branch in `app_es.arb` compiles, ships and is
never selected — and only these rows would notice.

**Unexpected categories fail too, not just missing ones.** A `few` branch in `app_es.arb` is inert:
CLDR `es` has no `few`, so that translation can never render. It is also a fingerprint — it means the
translator worked from `app_ar.arb`, which means the *other* branches are suspect too. Flagging it
turns a silent dead branch into a review prompt.

**`=0` and `=1` are allowed extras.** `arb-and-icu.md`: exact-value matches win over category branches
and exist for special copy ("No results" versus "0 results"). A checker that treats them as unexpected
categories would ban a documented feature.

**Rejected: `untranslated-messages-file` as the gate.** `gen-l10n` can emit a JSON list of untranslated
messages, but it is a *report*, not an exit code, and it says nothing about plural categories. A gate
whose failure mode is "an artefact nobody opened" is not a gate.

**Rejected: a coverage-style percentage ("95% of keys translated").** `SPEC.md` §14 is pass/fail and
`catchlaw-conventions-index` rule 12 is blunt: six locales ship together or the feature does not ship.
A missing `ar` key falls back to English inside a legal statement, which is the one place a fisher
cannot guess the meaning.

**Rejected: checking `gender` here.** `SPEC.md` §9.5's gender rule lives on `species_name.gender` in
`reference.db` and is asserted by the **content build** (§8, E04), not by ARB. Adding it here would put
one rule in two places.

## Tests first

Write the fixtures and every row before `arb_rules.dart` exists. Run them. **They must fail.** A row
that goes green early means the fixture is not actually broken — fix the fixture, not the checker.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `requiredCategoriesFor returns all six ICU categories for ar` | `'ar'` | `{zero, one, two, few, many, other}` | `SPEC.md` §9.5 headline. `ar` is the moat (§16 R1) and the reason this gate exists |
| 2 | `requiredCategoriesFor returns one, many and other for es` | `'es'` | `{one, many, other}` | The CLDR-48 correction. The first draft asserted `one`/`other` and would have shipped a locale short a category |
| 3 | `requiredCategoriesFor returns one, many and other for ca` | `'ca'` | `{one, many, other}` | Same correction, and `ca` is the locale most likely to be assumed a clone of `es` |
| 4 | `requiredCategoriesFor returns one, many and other for pt_BR` | `'pt_BR'` | `{one, many, other}` | The region-suffixed key must resolve; a table keyed only on `pt` returns nothing and the locale goes unchecked |
| 5 | `requiredCategoriesFor returns one and other for gl` | `'gl'` | `{one, other}` | The **only** two-category Latin locale here. Guards the opposite over-correction — adding `many` to `gl` because `es` has it |
| 6 | `requiredCategoriesFor returns one and other for en` | `'en'` | `{one, other}` | The template's own row, so the checker's baseline is not implicit |
| 7 | `requiredCategoriesFor throws ArgumentError for an unshipped locale` | `'ur'` | throws | D-3. A silent empty set would mean an unshipped locale passes every check |
| 8 | `missingCategories reports many when app_es.arb omits it` | fixture `missing_many_es/` | one finding: `es`/`searchResultCount`/`many` | The exact defect row 2 predicts |
| 9 | `missingCategories reports zero, two and few when app_ar.arb carries only one, many and other` | fixture `ar_from_es/` | three categories in one finding | What a translator working from the Spanish file produces. The failure this whole task exists to catch |
| 10 | `missingCategories ignores a key with no plural argument` | `appTitle` in every fixture | no finding | The false-positive guard: a plain key must never be reported, or the gate gets disabled |
| 11 | `missingCategories accepts an =0 branch alongside the required categories` | fixture `exact_zero_branch/` | no finding | `=0`/`=1` are exact-value matches and are documented, legal extras |
| 12 | `missingCategories reports every offending locale, not only the first` | fixture with `es` and `ar` both broken | two findings | A checker that returns on first failure hides five locales behind one message |
| 13 | `unexpectedCategories reports few when app_gl.arb carries it` | fixture `gl_with_few/` | one finding | An inert branch that can never render, and a fingerprint that the file was copied from `ar` |
| 14 | `missingCategories returns no finding for the shipped app/lib/l10n tree` | real files | empty | The live assertion — the one that will actually fail in CI one day |
| 15 | `missingCategories fails when it is handed a directory with no ARB files` | empty temp dir | throws | `CONVENTIONS.md` §7: a gate that scans nothing must not report success |
| 16 | `Intl.plural selects zero for ar at 0` | 0, `ar` | the `zero` branch | Toolchain reality, not documentation |
| 17 | `Intl.plural selects two for ar at 2` | 2, `ar` | the `two` branch | The category no Latin locale has, and the one an English-speaking author forgets first |
| 18 | `Intl.plural selects few for ar at 3` | 3, `ar` | the `few` branch | CLDR `ar`: 3–10 is `few` |
| 19 | `Intl.plural selects many for ar at 11` | 11, `ar` | the `many` branch | CLDR `ar`: 11–99 is `many`. Together with 16–18 and 20, proves the resolved `intl` implements the six-way split at all |
| 20 | `Intl.plural selects other for ar at 100` | 100, `ar` | the `other` branch | The upper boundary |
| 21 | `Intl.plural selects many for es at 1000000` | 1000000, `es` | the `many` branch | Proves `es` really has `many` in the resolved `intl` — the fact `SPEC.md` §9.5 corrected |
| 22 | `Intl.plural selects other for gl at 1000000` | 1000000, `gl` | the `other` branch | The inverse: `gl` has no `many`, so a `many` branch there would be dead code |
| 23 | `ci workflow invokes check_arb_parity.sh with app/lib/l10n` | read the workflow | the literal path present | D-1: a gate invoked with a bare default aborts with exit 2 at this repo root instead of scanning |

```dart
// app/test/l10n/arb_rules_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'arb_rules.dart';

void main() {
  group('requiredCategoriesFor', () {
    test('returns all six ICU categories for ar', () {
      expect(requiredCategoriesFor('ar'),
          {'zero', 'one', 'two', 'few', 'many', 'other'});
    });

    test('returns one, many and other for es', () {
      expect(requiredCategoriesFor('es'), {'one', 'many', 'other'});
    });

    test('returns one and other for gl', () {
      expect(requiredCategoriesFor('gl'), {'one', 'other'});
    });

    test('throws ArgumentError for an unshipped locale', () {
      expect(() => requiredCategoriesFor('ur'), throwsArgumentError);
    });
  });

  group('missingCategories', () {
    test('reports zero, two and few when app_ar.arb carries only one, many and other', () {
      final findings = missingCategories(loadArbDir('test/l10n/fixtures/ar_from_es'));
      expect(findings, hasLength(1));
      expect(findings.single.locale, 'ar');
      expect(findings.single.key, 'searchResultCount');
      expect(findings.single.categories, {'zero', 'two', 'few'});
    });

    test('accepts an =0 branch alongside the required categories', () {
      expect(missingCategories(loadArbDir('test/l10n/fixtures/exact_zero_branch')), isEmpty);
    });

    test('reports every offending locale, not only the first', () {
      final findings = missingCategories(loadArbDir('test/l10n/fixtures/two_broken'));
      expect(findings.map((f) => f.locale), containsAll(<String>['ar', 'es']));
    });

    test('fails when it is handed a directory with no ARB files', () {
      expect(() => loadArbDir('test/l10n/fixtures/empty'), throwsStateError);
    });
  });
}
```

```dart
// app/test/l10n/arb_plural_categories_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'arb_rules.dart';

String _category(num n, String locale) => Intl.plural(
      n,
      locale: locale,
      zero: 'zero', one: 'one', two: 'two',
      few: 'few', many: 'many', other: 'other',
    );

void main() {
  test('missingCategories returns no finding for the shipped app/lib/l10n tree', () {
    expect(missingCategories(loadArbDir('lib/l10n')), isEmpty);
  });

  test('unexpectedCategories returns no finding for the shipped app/lib/l10n tree', () {
    expect(unexpectedCategories(loadArbDir('lib/l10n')), isEmpty);
  });

  // The toolchain's own CLDR data, not SPEC.md's table. A document cannot tell
  // you which branch intl will select.
  test('Intl.plural selects zero for ar at 0', () => expect(_category(0, 'ar'), 'zero'));
  test('Intl.plural selects two for ar at 2', () => expect(_category(2, 'ar'), 'two'));
  test('Intl.plural selects few for ar at 3', () => expect(_category(3, 'ar'), 'few'));
  test('Intl.plural selects many for ar at 11', () => expect(_category(11, 'ar'), 'many'));
  test('Intl.plural selects other for ar at 100', () => expect(_category(100, 'ar'), 'other'));
  test('Intl.plural selects many for es at 1000000',
      () => expect(_category(1000000, 'es'), 'many'));
  test('Intl.plural selects other for gl at 1000000',
      () => expect(_category(1000000, 'gl'), 'other'));

  test('ci workflow invokes check_arb_parity.sh with app/lib/l10n', () {
    final workflow = File('../.github/workflows/validate.yml').readAsStringSync();
    expect(workflow, contains('check_arb_parity.sh app/lib/l10n'));
  });
}
```

**Run:** `cd app && flutter test test/l10n/` → 23 rows red. Any row green before `arb_rules.dart`
exists is a broken fixture, not a passing checker.

## Implementation outline

1. Build the four fixture directories. Each is a complete six-file ARB set — a partial set would fail
   for the wrong reason and teach the checker nothing.
2. Write `arb_rules.dart`:
   - `requiredCategoriesFor(String locale)` — a `switch` over the six shipped locale keys, `ar` first,
     `ArgumentError` in the default arm. The table's only source is `SPEC.md` §9.5.
   - `loadArbDir(String path)` — reads `app_*.arb`, throws `StateError` when it finds none
     (`CONVENTIONS.md` §7).
   - `missingCategories` / `unexpectedCategories` — locate `plural` arguments in each message, collect
     the branch names, subtract exact-value branches (`=0`, `=1`, `=n`), and diff against the table.
     Accumulate across **all** locales and **all** keys before returning; never return early.
3. Make rows 1–15 green. Then write `arb_plural_categories_test.dart` and make 16–23 green.
4. Add the two CI steps. Both take explicit paths (D-1). Confirm the parity script is on `PATH` from
   the plugin checkout the workflow already uses; if it is not, the step calls it by its full
   `.claude/skills/…` path exactly as `CONVENTIONS.md` §7 writes it.
5. Break one ARB file on purpose, run the gate, watch it fail with the locale and key named, restore it.
   A gate nobody has seen fail is a gate nobody trusts.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 23 rows pass, and each failed first.
- [ ] `check_arb_parity.sh app/lib/l10n` runs in CI with the path written out.
- [ ] `flutter test test/l10n` runs in CI.
- [ ] The plural-category table exists in exactly one place — `arb_rules.dart` — and cites
      `SPEC.md` §9.5 in a doc comment rather than restating the argument.
- [ ] Key parity is **not** reimplemented anywhere in this repo (rule 10, no forked general rules).
- [ ] A deliberately broken ARB has been observed failing the gate, and the failure names the locale
      and the key.
- [ ] `arb_rules.dart` does not end in `_test.dart` and is not executed as a suite.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/i18n-rtl-l10n/scripts/check_arb_parity.sh                  app/lib/l10n
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
ci(l10n): fail the build on a missing ARB key or a wrong plural category

SPEC.md §14 makes both a release gate and §13 makes them a build failure.
Key and placeholder parity is a general Flutter rule with a maintained gate
in the i18n-rtl-l10n plugin, so it is wired, not rewritten — forking it would
drift from the origin within two PRs.

The plural-category table is app law and lands here: ar needs all six ICU
categories, es/ca/pt_BR each carry many, and only gl is one/other
(SPEC.md §9.5, corrected against CLDR 48). An unexpected category fails too:
a `few` branch in Galician can never render, and it means the file was copied
from Arabic.

The categories are also checked against Intl.plural directly, at ar 0/2/3/11/
100 and es/gl 1000000. A table in a document cannot tell you which branch the
resolved intl will select.

Task: E06/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
