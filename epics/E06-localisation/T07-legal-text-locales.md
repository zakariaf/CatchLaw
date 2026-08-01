# E06/T07 — Legal text is single-locale, and the app says so

| | |
|---|---|
| **Epic** | E06 — Localisation infrastructure |
| **Branch** | `epic/06-localisation` (shared) |
| **Commit** | `feat(l10n): state the language a verbatim legal text exists in` |
| **Depends on** | T03 (the fallback chain must exist before this task can say where it does **not** apply) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.6 in full; §7.1 `jurisdiction.legal_text_locales` and `legal_text.locale`; §6 S13; §5.1 the legal-advice carve-out; §8 licence basis per jurisdiction |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | Invariant 2 — the notice is a statement of fact about the data and must not instruct. `references/product-invariants.md` carries the banned lexicon this task's six new ARB values are measured against |
| `catchlaw-verdict-contract` | Owns the wording law: what a statement of fact reads like, and the banned-imperative list in Dart and in all six ARB files |
| `i18n-rtl-l10n` | `references/arb-and-icu.md` for ICU `select`, which is how one ARB key names six languages in six languages without concatenation |
| `catchlaw-reference-database` | The `jurisdiction` and `legal_text` tables and their read-only contract |
| `testing-strategy` | Rule 5 — a bare-`implements` spy is how "the resolver was never consulted" becomes an assertion rather than a claim |
| `naming-conventions` | A pure-Dart type with no Flutter import; booleans read as assertions (`hasNotice`, not `notice`) |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | **§9.6, in full** | Bundled law exists only in the language(s) the authority published it in; we do not translate legal text; an unofficial translation of a penal instrument is a liability and, in Spain, outside the Art. 13 carve-out, which covers *official* translations only |
| `SPEC.md` | §9.6, last sentence | `jurisdiction.legal_text_locales` records what exists; S13 renders the notice; **the §9.2 fallback chain applies to `content_string` only and never silently substitutes a different language of law** |
| `SPEC.md` | §7.1 | `legal_text_locales TEXT NOT NULL` — CSV, e.g. `'ar'` or `'gl,es'`; `legal_text.locale`; `jurisdiction.default_locale` |
| `SPEC.md` | §6, S13 | Where the notice renders — not this task; this task delivers the rule and the string |
| `SPEC.md` | §5.1 | Why this matters beyond tidiness: the app quotes law and does not advise on it |
| `SPEC.md` | §8 | The per-jurisdiction licence basis, which attaches to the *original* text and not to any translation of it |
| `SPEC.md` | §9.2 | The chain this task is drawing a boundary around |
| `epics/DECISIONS.md` | D-3 | The six locale codes the `select` branches cover |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §2 | The banned lexicon, applied to six new ARB values |
| `.claude/skills/i18n-rtl-l10n/references/arb-and-icu.md` | "ICU — always, never concatenation", "Placeholder typing" | `select` keys are case-sensitive; pass canonical lowercase keys; interpolated free text is a typed `String` placeholder |

## What this delivers

- `app/lib/domain/models/legal_text_availability.dart`
  - `LegalTextAvailability` — an immutable value: `Locale textLocale`, `bool hasNotice`.
  - `static LegalTextAvailability resolve({required String legalTextLocales, required String defaultLocale, required Locale requested})`
    — pure, no Flutter widget import, no I/O.
- `app/lib/l10n/app_*.arb` — two keys in all six files:
  - `legalTextLanguageNotice` — one `{language}` `String` placeholder.
  - `languageName` — an ICU `select` over the six shipped locale codes, so the language can be named
    *in the reader's own language*.
- `app/test/domain/legal_text_availability_test.dart`,
  `app/test/l10n/legal_text_notice_test.dart`.

## Why it is built this way

**The fallback chain stops at the door.** `SPEC.md` §9.2 gives `content_string` a four-step chain
ending in the scientific name. §9.6 says that chain applies to `content_string` **only** and never
substitutes a different language of law. Those two sentences are three files apart in the codebase, and
the way they get reconciled wrongly is obvious: someone writes one "resolve any localised string"
helper, points it at `legal_text`, and the app quietly shows a Galician fisher the Spanish version of a
Galician order. Row 9 is a spy that fails the moment `ContentStringResolver` is called on a legal-text
path.

**The reason is not tidiness.** §9.6: an unofficial translation of a penal instrument is a liability,
and in Spain it falls outside the Art. 13 LPI carve-out, which covers *official* translations only. §8
attaches each jurisdiction's licence basis to the text as published. A translated law is a different
work with a different licence position and a different legal status, and the app's entire posture
(§5.1) is that it quotes law rather than interpreting it.

**The notice states a fact.** "The verbatim text of this instrument exists only in Arabic." Not "Switch
to Arabic to read it", not "Change your language" — invariant 2 has no exemption for a helpful hint, a
tooltip or an onboarding screen (`product-invariants.md` §2). Row 11 runs the banned lexicon over the
new values in all six locales, because a translator writing natural Spanish will reach for an
imperative unless the `@description` tells them not to.

**`languageName` is an ICU `select`, not six keys and not a lookup table.** The notice must name
Galician *in Arabic* and Arabic *in Galician* — a 6×6 matrix. One `select` key per ARB file gives 36
cells in six files with the key parity gate (T02) watching every one, and `arb-and-icu.md` is explicit
that `select` keys are case-sensitive canonical lowercase. Building the sentence by concatenating a
language name onto a template would break word order in `ar` and is banned by the same reference.

**The tie-break `SPEC.md` does not state.** §9.6 says a notice appears when the reader's locale is not
among `legal_text_locales`, but not *which* text to show when the CSV holds two — `'gl,es'` is a real
value from the Galicia rows. This task defines it: **`default_locale` when it appears in the list,
otherwise the first CSV entry.** It is deterministic, it is content-authored rather than alphabetical,
and the lever for changing it is the CSV order in the authored YAML — no code change. Alphabetical
order was rejected because it would make `es` beat `gl` in Galicia, which inverts the §9.1 argument for
shipping Galician at all.

**An empty `legal_text_locales` throws.** The column is `NOT NULL` (§7.1) and E04's build asserts the
content is complete (§8). An empty string reaching this function means a database we did not build, and
the alternative — silently showing English — is the exact substitution §9.6 forbids.

**Rejected: falling back to `en` when the reader's locale is absent.** That is what the `content_string`
chain does and it is precisely what §9.6 rules out for law. `en` is a language no bundled instrument is
published in (§9.2 point 2 — *English has no such source*), so an English legal text does not exist to
fall back to.

**Rejected: hiding the text when the reader cannot read it.** A fisher who cannot read Arabic can still
show the article to an inspector who can, and `SPEC.md` §14's dynamic checklist requires the citation to
expand into S13 and copy to the clipboard. Withholding it would repeat the invariant-5 mistake in a new
place: stale-or-foreign beats absent.

**Rejected: a `translated_text` column "for convenience, marked unofficial".** §9.6 forecloses it, and
a column that exists gets rendered eventually.

**Rejected: implementing S13.** The screen is E15's. This task delivers the rule, the value type and
the strings the screen will read.

## Tests first

Write every row before `legal_text_availability.dart` exists. Run them. **They must fail.** Row 6 is
the one to watch: written loosely it can pass by accident on a fixture that happens to have no `en`
row — assert it over a jurisdiction that *does* have `en` content strings, so the only way to pass is
to have skipped the chain deliberately.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LegalTextAvailability.resolve returns ar with no notice when the requested locale is ar` | `'ar'`, requested `ar` | `ar`, `hasNotice: false` | The Gulf base case: the reader and the law share a language, and no chrome is added |
| 2 | `LegalTextAvailability.resolve returns ar with a notice when the requested locale is en` | `'ar'`, requested `en` | `ar`, `hasNotice: true` | The expat angler in RAK (`SPEC.md` §9.1, `en` row). The text is still shown — withholding it would repeat the invariant-5 mistake |
| 3 | `LegalTextAvailability.resolve returns gl with no notice when the requested locale is gl` | `'gl,es'`, requested `gl` | `gl`, `hasNotice: false` | Galicia's mariscadora reading a Galician order in Galician — the §9.1 argument, at the row level |
| 4 | `LegalTextAvailability.resolve returns es with no notice when the requested locale is es` | `'gl,es'`, requested `es` | `es`, `hasNotice: false` | Both languages are official publications here; neither is a substitution |
| 5 | `LegalTextAvailability.resolve returns the default_locale when the requested locale is absent and default_locale is in the list` | `'gl,es'`, default `gl`, requested `ar` | `gl`, `hasNotice: true` | The tie-break's first arm. Alphabetical order would have picked `es` and inverted §9.1 |
| 6 | `LegalTextAvailability.resolve returns the first CSV entry when default_locale is not in the list` | `'gl,es'`, default `en`, requested `ca` | `gl`, `hasNotice: true` | The tie-break's second arm; the lever is the authored CSV order, not code |
| 7 | `LegalTextAvailability.resolve never returns en unless en is in legal_text_locales` | seeded loop over CSVs without `en`, every requested locale | never `en` | §9.6's headline, asserted as a universal. `en` is a language no bundled instrument is published in |
| 8 | `LegalTextAvailability.resolve tolerates whitespace in the CSV` | `'gl, es'` | `gl` | The column is hand-authored YAML upstream (§8); a space is not a content error and must not become an unknown locale |
| 9 | `LegalTextAvailability.resolve throws when legal_text_locales is empty` | `''` | throws | `NOT NULL` in §7.1 and asserted by the §8 build. An empty value means a database we did not build, and the graceful path would be the substitution §9.6 forbids |
| 10 | `ContentStringResolver is not consulted when a legal text is resolved` | spy resolver | zero calls | The boundary between §9.2 and §9.6, asserted rather than assumed. The one-helper-for-every-string refactor dies here |
| 11 | `$locale - legalTextLanguageNotice contains no imperative` | loop over six locales | no banned lexeme | Invariant 2 has no exemption for a helpful notice (`product-invariants.md` §2) |
| 12 | `$locale - languageName resolves all six shipped language codes` | loop 6 locales × 6 codes | non-empty, distinct | 36 cells. A missing `select` branch renders the ICU `other` fallback, which reads as a bug in exactly one language pair |
| 13 | `ar - legalTextLanguageNotice names Galician in Arabic` | `ar`, language `gl` | the Arabic word, not `gl` | The concrete cell that proves the `select` is wired end to end rather than passing the raw code through |
| 14 | `legalTextLanguageNotice declares language as a typed String placeholder` | template ARB | `placeholders.language.type == 'String'` | An untyped placeholder generates `Object` and lets a raw `Locale` be spliced in, which prints `gl` |

```dart
// app/test/domain/legal_text_availability_test.dart
import 'package:catchlaw/domain/models/legal_text_availability.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

LegalTextAvailability _resolve(
  String csv, {
  required String defaultLocale,
  required String requested,
}) =>
    LegalTextAvailability.resolve(
      legalTextLocales: csv,
      defaultLocale: defaultLocale,
      requested: Locale(requested),
    );

void main() {
  group('LegalTextAvailability', () {
    test('.resolve returns ar with a notice when the requested locale is en', () {
      final result = _resolve('ar', defaultLocale: 'ar', requested: 'en');
      expect(result.textLocale, const Locale('ar'));
      expect(result.hasNotice, isTrue);
    });

    // SPEC.md §9.6 gives no tie-break for a two-entry CSV. This is it, and the
    // lever for changing it is the authored CSV order, not code.
    test('.resolve returns the default_locale when the requested locale is absent '
        'and default_locale is in the list', () {
      expect(_resolve('gl,es', defaultLocale: 'gl', requested: 'ar').textLocale,
          const Locale('gl'));
    });

    test('.resolve returns the first CSV entry when default_locale is not in the list', () {
      expect(_resolve('gl,es', defaultLocale: 'en', requested: 'ca').textLocale,
          const Locale('gl'));
    });

    // §9.6: the §9.2 chain applies to content_string only.
    test('.resolve never returns en unless en is in legal_text_locales', () {
      const csvs = <String>['ar', 'gl,es', 'ca', 'pt_BR', 'es'];
      const requested = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR'];
      for (final csv in csvs) {
        for (final locale in requested) {
          final result = _resolve(csv, defaultLocale: csv.split(',').first,
              requested: locale);
          expect(result.textLocale.languageCode, isNot('en'),
              reason: 'csv=$csv requested=$locale');
        }
      }
    });

    test('.resolve tolerates whitespace in the CSV', () {
      expect(_resolve('gl, es', defaultLocale: 'gl', requested: 'gl').textLocale,
          const Locale('gl'));
    });

    test('.resolve throws when legal_text_locales is empty', () {
      expect(() => _resolve('', defaultLocale: 'gl', requested: 'gl'),
          throwsArgumentError);
    });
  });
}
```

```dart
// app/test/l10n/legal_text_notice_test.dart
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _locales = <Locale>[
  Locale('ar'), Locale('en'), Locale('es'),
  Locale('gl'), Locale('ca'), Locale('pt', 'BR'),
];
const _codes = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR'];

void main() {
  for (final locale in _locales) {
    final tag = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';

    test('$tag - languageName resolves all six shipped language codes', () async {
      final l10n = await AppLocalizations.delegate.load(locale);
      final names = <String>[for (final code in _codes) l10n.languageName(code)];
      expect(names.toSet(), hasLength(6), reason: 'names=$names');
      expect(names.any((n) => _codes.contains(n)), isFalse,
          reason: 'a raw code means a missing select branch: $names');
    });

    // Invariant 2 — product-invariants.md §2. No exemption for a helpful notice.
    test('$tag - legalTextLanguageNotice contains no imperative', () async {
      const banned = <String>['keep', 'return', 'release', 'switch to', 'change your'];
      final l10n = await AppLocalizations.delegate.load(locale);
      final notice = l10n.legalTextLanguageNotice(l10n.languageName('ar')).toLowerCase();
      for (final word in banned) {
        expect(notice, isNot(contains(word)), reason: '$tag: "$word"');
      }
    });
  }
}
```

**Run:** `cd app && flutter test test/domain/legal_text_availability_test.dart test/l10n/legal_text_notice_test.dart`
→ 14 rows red (26 tests after the loops expand).

## Implementation outline

1. Write `LegalTextAvailability` as an immutable value with a `const` constructor and a `resolve`
   factory. Parse the CSV once: split, trim, drop empties, `ArgumentError` if nothing remains.
2. Resolution order, and it is short: requested locale in the list → it, no notice. Otherwise
   `default_locale` if it is in the list, else the first entry, with `hasNotice: true`. There is no
   third branch and no `en` branch — that is the point of the type.
3. Make rows 1–9 green.
4. Add `legalTextLanguageNotice` and `languageName` to `app_en.arb` with `@description` blocks. The
   descriptions carry the constraint the translator needs: *this is a statement about the data; it must
   not tell the reader to do anything.* Then mirror both keys into the other five files with the same
   `select` branch shapes and different branch bodies.
5. `flutter gen-l10n`; make rows 11–14 green. T02's parity and category gates are live and will catch a
   missed file immediately.
6. Row 10: the spy. Give it the `ContentStringRepository` interface from T03 with a call counter, wire
   it wherever a legal-text path could reach it, and assert zero.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 rows pass, and each failed first.
- [ ] `LegalTextAvailability` has no path that returns `en` unless `en` is in `legal_text_locales`.
- [ ] `ContentStringResolver` is unreachable from any legal-text code path (row 10).
- [ ] The two new ARB keys exist in all six files; `check_arb_parity.sh app/lib/l10n` is clean.
- [ ] No new ARB value contains an imperative from `product-invariants.md` §2, in any of the six
      locales.
- [ ] The `{language}` placeholder is typed `String` in the template's `@` metadata.
- [ ] The tie-break for a multi-entry CSV is documented in the type's doc comment, with the note that
      the lever is the authored CSV order.
- [ ] `packages/rule_engine/` is untouched (D-7).
- [ ] S13 is **not** implemented here; the commit body names E15 as its owner.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/i18n-rtl-l10n/scripts/check_arb_parity.sh                    app/lib/l10n
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
```

`check_verdict_contract.sh` scans `app/lib` and `app/lib/l10n` for exactly the imperative ban this
task's new ARB values must satisfy (D-7 explains why it scans the app and not the engine).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(l10n): state the language a verbatim legal text exists in

SPEC.md §9.6: bundled law exists only in the language the authority published
it in, and the §9.2 fallback chain applies to content_string only. The two
sentences live three files apart, and the way they get reconciled wrongly is
one "resolve any localised string" helper pointed at legal_text — after which
a Galician fisher reads the Spanish version of a Galician order. A spy on the
content-string resolver asserts zero calls on the legal-text path.

The reason is not tidiness: an unofficial translation of a penal instrument
is a liability and, in Spain, falls outside the Art. 13 LPI carve-out, which
covers official translations only. §8 attaches each jurisdiction's licence
basis to the text as published.

§9.6 gives no tie-break for a two-language CSV like 'gl,es'. Defined here as
default_locale when present, else the first entry — deterministic, authored,
and changeable by reordering the CSV rather than the code. Alphabetical would
have put es ahead of gl in Galicia, which inverts §9.1.

The notice names the language, in the reader's own language, through one ICU
select with six branches per file. It states a fact and never instructs: no
"switch to", no "change your language" (invariant 2, no exemption for a
helpful hint).

S13 renders it; that screen is E15's.

Task: E06/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
