# E20/T02 — Arabic plural categories, asserted on the shipped strings

| | |
|---|---|
| **Epic** | E20 — RTL and locale hardening |
| **Branch** | `epic/20-rtl-hardening` (shared) |
| **Commit** | `test(l10n): assert every ICU plural category against the shipped ARB values` |
| **Depends on** | — (independent of T01; runs on the six ARB files E06/T01 created) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.5 "Plurals", §13 "Localisation completeness — enforced", §14 static checklist |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `i18n-rtl-l10n` | Owns ICU authoring: `references/arb-and-icu.md` carries the six-category contract for Arabic and the rule that a missing category is a release blocker, not a cosmetic gap |
| `testing-strategy` | Rule 1 (cheapest tier — this needs no widget tree) and rule 3 (assert against an **independent oracle**, which is what `Intl.pluralLogic` is here) |
| `catchlaw-conventions-index` | Rule 12 and invariant 2 — six locales ship together, and none of these strings may instruct |
| `lonja-typography` | Rule 10: eyebrow and label case arrives from the ARB. A plural branch is content and is never `.toUpperCase()`-d in a widget |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.5, "Plurals" | The rule and its correction: Arabic needs all six; `es`, `ca` and `pt` each carry a `many`; only `gl` is `one`/`other`. The first draft asserted `one`/`other` for all four |
| `SPEC.md` | §13, "Localisation completeness" | "CI fails on any ARB key missing from any locale, and on any `ar` plural missing a category" — the check E06 built, which this task is *not* a copy of |
| `SPEC.md` | §14, static checklist, last item | Same requirement stated as a release gate |
| `SPEC.md` | §6, S5 · S7 · S8 · S14 | Where the count-bearing strings actually live: search result counts, the live candidate count, the per-species tally, the bulk photo purge |
| `.claude/skills/i18n-rtl-l10n/references/arb-and-icu.md` | "ICU — always, never concatenation" | Branch shapes must be identical across locales while bodies differ; `=0`/`=1` are exact-value matches that win over the category branches |
| `.claude/skills/i18n-rtl-l10n/SKILL.md` | rules 2, 3 | Key + placeholder parity; a two-way ternary cannot hold Arabic `few`/`many` |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariant 2 | The banned lexicon applies to every ARB value in all six files, plural branches included |
| `epics/DECISIONS.md` | D-3, D-18 | Six languages in seven files: the Brazilian text is `app_pt_BR.arb`, `app_pt.arb` is the base `gen-l10n` requires beside it, and `app_ur.arb` does not exist |

## What this delivers

- `app/test/l10n/plural_categories_test.dart` — the whole task. Pure `flutter_test`, no widget pumped.
- No new ARB key. If a shipped key is found to be missing a category, or to be carrying a dead one,
  the ARB value is corrected **in this commit** and the correction is named in the body.
- No change to `app/lib/` Dart source.

## Why it is built this way

**The keys are discovered, not listed.** The test scans `app/lib/l10n/app_en.arb` for every message
whose value contains `, plural,` and runs the battery over each discovered key. Writing a fixed list
here would go stale the first time E22 or a late fix adds a count-bearing string, and a plural key that
no test knows about is exactly the one that ships with three branches. The scan itself is guarded: if
it discovers zero keys the test fails, because `CONVENTIONS.md` §7 records that a gate scanning an
empty tree reporting success is the failure mode that makes a gate worse than no gate. From `SPEC.md`
§6 the discovered set is expected to include the per-species tally (S8), the live candidate count (S7),
the search result count (S5) and the bulk photo purge count (S14) — but the test asserts the *battery*,
not the list.

**`Intl.pluralLogic` is the oracle, and it is independent of the thing under test.** The question
"which categories does this locale actually reach?" is answered by CLDR, and `intl` carries CLDR's
tables. Hardcoding "Arabic `many` starts at 11" or "Spanish `many` is 10^6" into an assertion would be
encoding somebody's memory of a specification into a test — `testing-strategy` rule 3 calls that
checking a function against itself. Instead the test probes `Intl.pluralLogic` with sentinel branch
strings across a candidate count list and records which category each count selects. The reachable set
that comes back is what the ARB is then held to.

**Three layers, because each catches a different defect.**

1. *Reachability* — which categories CLDR selects for this locale, from `Intl.pluralLogic`.
2. *Structure* — which branches the ARB value declares, from parsing the ARB JSON. A branch that is
   reachable but undeclared silently ships the template language inside a sentence a fisher cannot
   guess (`i18n-rtl-l10n` rule 2). A branch that is declared but unreachable is dead copy a translator
   maintains forever.
3. *Distinctness* — the six `ar` branch **bodies**, with the placeholder token stripped, must be
   pairwise distinct. This is the assertion that matters most. E06's CI check verifies that six
   category names are present; the cheapest way to satisfy a name check is to paste the `other` body
   into all six, which passes E06's gate, passes `flutter analyze`, renders, and is grammatically wrong
   in five of the six cases. Stripping `{count}` before comparing is what stops the interpolated
   number from making six identical bodies look different.

**Rejected: asserting rendered output for `es`, `ca` and `pt_BR` distinctness.** Their `many` category
is reachable only at counts no catch log will ever hold, and its body is often legitimately identical
to `other`. Demanding six distinct strings there would force a translator to invent a difference that
the language does not have. Those three get reachability plus structure; only `ar` gets distinctness,
because Arabic genuinely inflects all six differently.

**Rejected: re-implementing E06's parity check.** `SPEC.md` §13 and §14 already put key-and-category
parity in CI, and E06 built it. Copying it here would give two gates that disagree within a month
(`CONVENTIONS.md` §4, and the "cite, never restate" rule). This task asserts what a JSON scan cannot:
that the declared branches match what the language reaches, and that their bodies are real.

**Rejected: pumping a widget.** `AppLocalizations.delegate.load(locale)` returns the localisations
object directly. `testing-strategy` rule 1 — anything expressible as `f(input) -> output` is a unit
test, never a `pumpWidget`.

## Tests first

Write every row before touching a single ARB value. Run them. **They must fail** — on the ARB files as
they stand, at minimum the distinctness rows, because nothing has ever checked a branch body. If a row
passes now, read it again: a reachability row that passes trivially usually means the candidate list is
wrong.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `PluralAudit discovers at least one count-bearing key in app_en.arb` | `app/lib/l10n/app_en.arb` | discovered set is non-empty | `CONVENTIONS.md` §7: a scan of nothing reports success, which is worse than no scan at all |
| 2 | `Intl.pluralLogic reaches all six categories for ar` | counts 0, 1, 2, 3, 11, 100 | `{zero, one, two, few, many, other}` | Pins the oracle itself. If `intl`'s `ar` tables ever changed, every row below would move silently |
| 3 | `Intl.pluralLogic reaches many for es` | the candidate count list | `many` present, `few` and `two` absent | `SPEC.md` §9.5's correction — the first draft asserted `one`/`other` for Spanish |
| 4 | `Intl.pluralLogic reaches many for ca` | same | `many` present | Catalan ships (D-3) and carries the same category as Spanish |
| 5 | `Intl.pluralLogic reaches many for pt_BR` | same | `many` present | The file is `app_pt_BR.arb`; the plural rules are Portuguese's |
| 6 | `Intl.pluralLogic reaches only one and other for gl` | same | exactly `{one, other}` | Galician is the single locale §9.5 leaves at two categories; a `many` here would be dead copy |
| 7 | `ar - <key> declares every category Intl.pluralLogic reaches` (loop, one per discovered key) | `app_ar.arb` value | declared branches ⊇ reachable set | A missing Arabic category falls back to English inside a legal statement — the one place a fisher cannot guess the meaning |
| 8 | `ar - <key> declares no branch Intl.pluralLogic never reaches` (loop) | same | declared ⊆ reachable ∪ `{=0, =1}` | A dead branch is copy a translator maintains forever and nobody ever sees |
| 9 | `ar - <key> gives six pairwise distinct branch bodies` (loop) | branch bodies with `{count}` stripped | 6 distinct strings | The real defect: pasting the `other` body into all six satisfies E06's name check, analyzes clean, renders, and is wrong in five cases |
| 10 | `es - <key> declares a many branch` (loop) | `app_es.arb` | `many` declared | §9.5, applied per key rather than per locale |
| 11 | `ca - <key> declares a many branch` (loop) | `app_ca.arb` | `many` declared | Same, for Catalan |
| 12 | `pt_BR - <key> declares a many branch` (loop) | `app_pt_BR.arb` | `many` declared | Same, for Brazilian Portuguese |
| 13 | `gl - <key> declares one and other and nothing else` (loop) | `app_gl.arb` | exactly `{one, other}` (plus any `=n`) | Guards the other direction: a translator copying the `es` skeleton into `gl` adds a branch CLDR will never select |
| 14 | `AppLocalizations renders six distinct strings for <key> in ar at 0, 1, 2, 3, 11 and 100` (loop) | the loaded `ar` localisations | 6 distinct rendered strings | Structure is not behaviour. This is the row that proves the generated Dart actually branches, not just that the JSON looked right |
| 15 | `AppLocalizations renders a non-empty string for <key> in every locale at count 3` (loop over 6 locales × keys) | each locale | non-empty, and not equal to the raw key | The fallback failure mode: gen-l10n emitting the key name, or an empty widget, in the one locale nobody reads |

```dart
// app/test/l10n/plural_categories_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:catchlaw/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

/// D-3. `pt_BR` carries its region: the content is Brazilian, not Iberian.
const _locales = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR'];

/// Counts chosen to span every CLDR cardinal category any shipped locale defines.
/// 1000000 is a probe for the es/ca/pt `many`, not an assertion about it.
const _probeCounts = <int>[0, 1, 2, 3, 11, 100, 1000000];

const _categories = <String>['zero', 'one', 'two', 'few', 'many', 'other'];

/// Independent oracle: ask intl's own CLDR tables which category a count selects.
String _categoryOf(int n, String locale) => Intl.pluralLogic<String>(
      n,
      zero: 'zero', one: 'one', two: 'two',
      few: 'few', many: 'many', other: 'other',
      locale: locale,
    );

Set<String> _reachable(String locale) =>
    {for (final n in _probeCounts) _categoryOf(n, locale)};

Map<String, String> _arb(String locale) =>
    (jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync()) as Map)
        .cast<String, dynamic>()
        .entries
        .where((e) => !e.key.startsWith('@') && e.value is String)
        .fold(<String, String>{}, (m, e) => m..[e.key] = e.value as String);

/// Branch bodies out of an ICU plural message: {count, plural, one{…} other{…}}.
Map<String, String> _branches(String icu) {
  final out = <String, String>{};
  for (final name in [..._categories, '=0', '=1', '=2']) {
    final at = icu.indexOf('$name{');
    if (at < 0) continue;
    var depth = 0, i = at + name.length;
    final start = i + 1;
    for (; i < icu.length; i++) {
      if (icu[i] == '{') depth++;
      if (icu[i] == '}' && --depth == 0) break;
    }
    out[name] = icu.substring(start, i);
  }
  return out;
}

void main() {
  final template = _arb('en');
  final pluralKeys = template.entries
      .where((e) => e.value.contains(', plural,'))
      .map((e) => e.key)
      .toList()
    ..sort();

  test('PluralAudit discovers at least one count-bearing key in app_en.arb', () {
    expect(pluralKeys, isNotEmpty,
        reason: 'the scan found no ICU plural in the template — a gate that scans '
            'nothing reports success (CONVENTIONS.md §7)');
  });

  test('Intl.pluralLogic reaches all six categories for ar', () {
    expect(_reachable('ar'), unorderedEquals(_categories));
  });

  test('Intl.pluralLogic reaches only one and other for gl', () {
    expect(_reachable('gl'), unorderedEquals(<String>['one', 'other']));
  });

  for (final locale in ['es', 'ca', 'pt_BR']) {
    test('Intl.pluralLogic reaches many for $locale', () {
      expect(_reachable(locale), contains('many'),
          reason: 'SPEC.md §9.5 corrected against CLDR 48: $locale carries a many category');
    });
  }

  final arb = {for (final l in _locales) l: _arb(l)};

  for (final key in pluralKeys) {
    test('ar - $key declares every category Intl.pluralLogic reaches', () {
      final declared = _branches(arb['ar']![key]!).keys.toSet();
      expect(declared, containsAll(_reachable('ar')),
          reason: '$key is missing ${_reachable('ar').difference(declared)} in app_ar.arb');
    });

    test('ar - $key gives six pairwise distinct branch bodies', () {
      final bodies = _branches(arb['ar']![key]!)
          .entries
          .where((e) => _categories.contains(e.key))
          .map((e) => e.value.replaceAll(RegExp(r'\{\w+\}'), ''))
          .toList();
      expect(bodies.toSet().length, bodies.length,
          reason: 'two ar branches of $key carry the same body — the other body was '
              'pasted across the categories to satisfy a name check');
    });

    test('AppLocalizations renders six distinct strings for $key in ar '
        'at 0, 1, 2, 3, 11 and 100', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
      final rendered = <String>{
        for (final n in [0, 1, 2, 3, 11, 100]) renderPlural(l10n, key, n),
      };
      expect(rendered.length, 6);
    });
  }
}
```

`renderPlural` is a small `switch` over the discovered key names living in the same file — the
generated `AppLocalizations` exposes one method per key, so a reflective lookup is not available and a
`switch` that fails to compile when a key is renamed is the better outcome.

**Run:** `cd app && flutter test test/l10n/plural_categories_test.dart` → red. If row 9 passes on the
first run, either the translator was unusually careful or `_branches` is not parsing — check by
printing one parsed map before believing it.

## Implementation outline

The tests are red. Then:

1. Read the failures. Each names a locale, a key and the exact category set that is missing or dead.
2. Fix the **ARB values**, not the test. A missing `ar` category is authored as a real Arabic branch,
   with the noun inflected for that category — `zero` and `two` are not decorations in Arabic.
3. For any `gl` key carrying a `many` branch, delete the branch. For any `es`/`ca`/`pt_BR` key missing
   one, add it; where the language gives no genuine difference from `other`, the body is legitimately
   the same sentence, and rows 10–12 assert declaration rather than distinctness for exactly that
   reason.
4. Keep placeholder names identical across all six files (`i18n-rtl-l10n` rule 2) — only the branch
   bodies differ.
5. Re-run `flutter gen-l10n` and `flutter analyze`. With `nullable-getter: false` a mistyped key is a
   compile error, so a green analyze is part of the evidence.
6. Re-run the whole suite: the ARB edits touch generated code that other tests read.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] Every row above passes, and each failed first.
- [ ] `app_ar.arb` declares `zero`, `one`, `two`, `few`, `many` and `other` on every discovered
      count-bearing key, with six distinct bodies.
- [ ] `app_es.arb`, `app_ca.arb` and `app_pt_BR.arb` each declare a `many` branch on every such key.
- [ ] `app_gl.arb` declares `one` and `other` and no category CLDR never selects.
- [ ] Placeholder names are identical across all six files for every discovered key.
- [ ] No ARB value gained an imperative — `check_app_invariants.sh` covers it, and the branch bodies
      are inside its scan (invariant 2, D-7: the app owns every word).
- [ ] No `.toUpperCase()` was added anywhere (`lonja-typography` rule 10 — a no-op on Arabic).
- [ ] `flutter gen-l10n` regenerated and the generated file is checked in (`FLUTTER_GUIDE.md` §7.4).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze
cd app && flutter test --exclude-tags golden
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh app/lib
```

The verdict-contract gate scans `app/lib` and `app/lib/l10n` (D-7) — ARB values are never exempt from
it (`CONVENTIONS.md` §7).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(l10n): assert every ICU plural category against the shipped ARB values

E06 wired the CI check SPEC.md §13 asks for: every ar plural must name all
six categories. The cheapest way to satisfy a name check is to paste the
other body into all six, which passes that gate, analyzes clean, renders,
and is grammatically wrong in five of the six cases. This asserts the
bodies.

Three layers per key, over every message in app_en.arb containing
", plural," — discovered rather than listed, so a count-bearing string
added later cannot escape. Reachability comes from Intl.pluralLogic, which
carries CLDR's own tables and is independent of the ARB under test;
structure comes from parsing the ARB; distinctness compares the six ar
branch bodies with the placeholder stripped.

es, ca and pt_BR are held to declaring a reachable many branch and no more
— their many is selected only at counts no catch log will hold, and forcing
a distinct body there would make a translator invent a difference the
language does not have. gl is held to one and other and to carrying no
branch CLDR never selects.

Task: E20/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
