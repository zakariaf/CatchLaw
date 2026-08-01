# E15/T03 — The language-availability notice

| | |
|---|---|
| **Epic** | E15 — The reference section |
| **Branch** | `epic/15-reference` (shared) |
| **Commit** | `feat(reference): state the language a legal text was published in, and never substitute another` |
| **Depends on** | T02 (S13, and the locale parameter its view model already carries) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.6 in full, §6 S13 (the notice is a named element), §9.2 (the fallback chain, and its boundary), §7.1 (`jurisdiction.legal_text_locales`, `default_locale`) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-verdict-contract` | The notice is a user-facing sentence about the law. Rules 1, 2 and 7 bind it: statement of fact, no second person, and an absence that is never softened into permission |
| `lonja-lists-and-tables` | `references/the-four-states.md` owns the ochre tone this notice must **not** borrow, and the empty state it must not be confused with |
| `lonja-typography` | Rule 2 — the notice sits beside the law and is set in the serif; `legalSmall` is its step |
| `lonja-forms-and-controls` | `LonjaSegmented` is the picker when an instrument exists in more than one published language; rule 8 — selection is fill and weight, never semantic colour |
| `i18n-rtl-l10n` | Locale identity and comparison; the ARB keys carrying the six language names; bidi isolation of a Latin language name inside Arabic prose |
| `catchlaw-conventions-index` | Invariant 4 — the notice carries a glyph and words, not a hue; the routing table's tie-break for a string that is neither chrome nor content |
| `widget-golden-and-a11y-testing` | The `ar` and `gl` lanes where this notice is most likely to be wrong, and `isSemantics` for the picker |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.6 | The whole section. Why we do not translate; that `legal_text_locales` records what exists; that the §9.2 chain never silently substitutes a different language of law |
| `SPEC.md` | §9.2 | The fallback chain — requested locale → jurisdiction `default_locale` → `en` → scientific name — and the fact that it is scoped to `content_string` |
| `SPEC.md` | §6 S13 | The notice is a named element of the screen, not an optional nicety |
| `SPEC.md` | §7.1 | `jurisdiction.legal_text_locales TEXT NOT NULL` — a CSV, "e.g. `'ar'` or `'gl,es'`" — and `default_locale` |
| `SPEC.md` | §9.1 | Why `gl` and `ca` ship at all: each is the official publication language of a bundled instrument. That argument is the same one this notice makes on screen |
| `.claude/skills/catchlaw-verdict-contract/references/verdict-copy-rules.md` | "The grep lexicon", family E; "The six locales" | Softened-absence wording is a hard failure everywhere; the `es`/`gl` imperative trap |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Stale" | "Ochre is not oxblood" — and, by the same argument, ochre is not "published in another language" either |
| `.claude/skills/lonja-typography/references/type-ramp.md` | `legalSmall`, `microLabel` | 14/1.55 for the notice prose; 9.5 for its rubric |
| `.claude/skills/lonja-forms-and-controls/SKILL.md` | rule 8 | A selected segment inverts to an `ink` ground; `verdant`, `oxblood` and `ochre` never appear on an input |
| `FLUTTER_GUIDE.md` | Part 1.9, Part 5.2 | The domain layer is mandatory here; the use case is pure and the widget is dumb |
| `epics/DECISIONS.md` | D-3, D-7 | The six locales, `pt_BR` with its region; the engine holds no user-visible sentence, which is why this resolver lives in `app/lib/domain/` |

## What this delivers

- `app/lib/domain/models/legal_text_availability.dart` — a sealed result:

  ```dart
  sealed class LegalTextAvailability { const LegalTextAvailability(); }
  final class LegalTextInReaderLanguage   extends LegalTextAvailability { … final String locale; }
  final class LegalTextInPublishedLanguage extends LegalTextAvailability {
    … final String rendered;             // the locale actually shown
    final List<String> published;        // every locale the instrument exists in, source order
  }
  final class LegalTextNotRecorded        extends LegalTextAvailability { const … ; }
  ```
- `app/lib/domain/use_cases/legal_text_locale_resolve_use_case.dart` —
  `LegalTextLocaleResolveUseCase`: `(readerLocale, jurisdiction) → LegalTextAvailability`. Pure, no
  Flutter import, no `content_string` lookup, no wording.
- `app/lib/ui/reference/widgets/legal_text_language_notice.dart` —
  `LegalTextLanguageNotice`: rubric, glyph, one or two sentences, and a `LonjaSegmented` picker when
  `published.length > 1`.
- `RuleTextViewModel` gains the resolved availability and drives its locale from it; `RuleTextScreen`
  renders the notice above the article list.
- ARB keys in all six files (D-3): `referenceLegalTextPublishedIn`,
  `referenceLegalTextNoTranslation`, `referenceLegalTextNotRecorded`,
  `referenceLegalTextLanguagePicker`, plus the six language names `languageNameAr`, `languageNameEn`,
  `languageNameEs`, `languageNameGl`, `languageNameCa`, `languageNamePtBr`.
- Tests: `app/test/domain/legal_text_locale_resolve_use_case_test.dart`,
  `app/test/ui/reference/legal_text_language_notice_test.dart`.

## Why it is built this way

**We do not translate law, and the app has to say so out loud.**
`SPEC.md` §9.6 is short and load-bearing: bundled law exists only in the language the authority
published it in, and an unofficial translation of a penal instrument would be both a liability and,
in Spain, outside the Art. 13 LPI carve-out — which covers *official* translations only. A silent
fallback would therefore be worse than a visible gap: a Galician mariscadora reading an instrument
labelled in her own language, whose text is actually the Spanish version, has been handed a document
that does not exist.

**Two fallback chains run on this screen and they must not touch.**
Every *label* on S13 — the instrument-type name, the section rubrics, the notice's own words —
resolves through `content_string` with §9.2's chain: requested locale → `default_locale` → `en` →
scientific name. Every *article body* resolves through `legal_text_locales` and stops there. Test 8
pins exactly that: a jurisdiction publishing in `gl` and `es`, read by an `en` reader, renders English
chrome around Galician law with the notice between them. **Rejected:** running the §9.2 chain over
`legal_text.locale`, which is a two-line change that looks like consistency and produces the failure
§9.6 exists to prevent.

**The notice is neutral, not ochre.**
`the-four-states.md` reserves ochre for "the paper is old", and it argues the point itself: rendering
one condition in another's colour teaches the reader to stop trusting the colour. An instrument
published only in Catalan is not stale, not an error and not a data gap — it is correctly published.
So the notice is a ruled block: a 1 px `structural` rule top and bottom, an `ink` glyph, `legalSmall`
prose, and **no semantic colour at all**. Invariant 4 is satisfied by glyph plus words, which is what
it asks for; there is simply no hue in the signal. **Rejected:** ochre (conflates with staleness),
oxblood (conflates with a failing verdict), and a dismissable banner (the condition holds for as long
as the instrument does).

**Language names come from ARB, not from a package.**
Neither `intl` nor `flutter_localizations` exposes localised language display names, and the app
takes no dependency it does not need (invariant 1's neighbourhood, and `dependency-hygiene`'s). Six
languages × six locales is 36 ARB values — bounded, reviewable, and translated by the same native
speakers §9.2 already budgets for. **Rejected:** rendering the raw code (`gl`), which is meaningless
to the reader the notice exists for.

**When several published languages exist, the reader chooses; the app does not.**
`legal_text_locales = 'gl,es'` means both texts are authentic. Picking one silently would be the app
resolving an ambiguity it has no standing to resolve — the same posture `catchlaw-verdict-contract`
rule 6 takes on two equally specific rules. So: the default rendered locale is `default_locale` when
it appears in the list, otherwise the first CSV entry in source order, and a `LonjaSegmented` picker
offers every published language. No "recommended", no reordering.

**An empty `legal_text_locales` is a state, not a crash.**
§7.1 declares the column `NOT NULL` but nothing forbids `''`, and §16 R1 records that Gulf verbatim
text may not be transcribed when a jurisdiction's rules are. Empty, whitespace-only or unparseable
resolves to `LegalTextNotRecorded`, which is empty surface 2 of T09's eight — never an exception and
never a blank frame. This is epic Risk 5.

**Locale comparison normalises the separator before it compares.**
A CSV may hold `pt_BR`, `pt-BR` or `pt`; `Locale('pt', 'BR').toString()` is `pt_BR`. The comparison
lowercases the language subtag, uppercases the region, and joins with `_`. **Rejected:**
`locale.languageCode == entry`, which quietly matches `pt` against Brazilian content and would render
Brazilian law to a Portuguese reader on the strength of a substring.

## Tests first

Write every row before touching `legal_text_locale_resolve_use_case.dart`. Run them. **They must
fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LegalTextLocaleResolveUseCase returns the reader locale when it is published` | reader `ar`, locales `ar` | `LegalTextInReaderLanguage('ar')` | The Gulf case: one published language, and it is the reader's. No notice |
| 2 | `LegalTextLocaleResolveUseCase renders the default locale when the reader locale is absent` | reader `en`, locales `gl,es`, default `gl` | `LegalTextInPublishedLanguage(rendered: 'gl', published: ['gl','es'])` | The Galicia case and the §9.6 headline: English chrome, Galician law, notice between |
| 3 | `LegalTextLocaleResolveUseCase renders the first published locale when the default is not published` | reader `en`, locales `ca`, default `es` | rendered `ca` | `default_locale` is the jurisdiction's UI default and need not be a publication language; falling back to it blindly would render nothing |
| 4 | `LegalTextLocaleResolveUseCase preserves the published order` | locales `gl,es` | `['gl','es']` | Source order, no sort. Two authentic texts are not ranked, per the same argument as D4 ambiguity |
| 5 | `LegalTextLocaleResolveUseCase returns not-recorded for an empty locale list` | locales `''` | `LegalTextNotRecorded()` | Epic Risk 5. `NOT NULL` does not mean non-empty, and a jurisdiction can ship rules before its text |
| 6 | `LegalTextLocaleResolveUseCase returns not-recorded for a whitespace-only locale list` | locales `' , '` | `LegalTextNotRecorded()` | The CSV parse's real failure mode: a trailing comma in authored YAML |
| 7 | `LegalTextLocaleResolveUseCase matches pt_BR against a pt-BR entry` | reader `pt_BR`, locales `pt-BR` | `LegalTextInReaderLanguage` | Separator drift between the authoring YAML and Dart's `Locale.toString()` |
| 8 | `LegalTextLocaleResolveUseCase does not match pt against a pt_BR entry` | reader `pt`, locales `pt_BR` | `LegalTextInPublishedLanguage` | The over-match that would hand Brazilian law to a Portuguese reader. D-3 chose the region for a reason |
| 9 | `RuleTextScreen renders the language notice when the reader locale is not published` | reader `en`, locales `gl,es` | notice present, naming Galician and Spanish | §6 S13's named element, on the screen |
| 10 | `RuleTextScreen renders no language notice when the reader locale is published` | reader `ar`, locales `ar` | notice absent | The notice must be a fact about this instrument, not permanent furniture nobody reads |
| 11 | `RuleTextScreen renders Galician article text under an English locale` | reader `en`, locales `gl,es` | body equals the `gl` row's `body` | §9.6's prohibition, asserted on the rendered output rather than on the resolver |
| 12 | `RuleTextScreen resolves chrome labels through the content_string chain while the body stays Galician` | reader `en`, locales `gl,es` | instrument-type label in `en`, body in `gl` | The two chains, side by side in one frame. This is the test that fails if someone "unifies" them |
| 13 | `RuleTextScreen offers a picker across every published language` | locales `gl,es` | two `LonjaSegmented` cells | Two authentic texts; the reader chooses, the app does not |
| 14 | `RuleTextScreen switches the article body when another published language is picked` | pick `es` | body equals the `es` row's `body` | The picker has to actually re-query, not re-label |
| 15 | `LegalTextLanguageNotice carries a glyph and words and no semantic colour` | default pump | glyph present; resolved colour is neither ochre, oxblood nor verdant | Invariant 4 satisfied without borrowing staleness's hue — the reasoning above, pinned |
| 16 | `ar - LegalTextLanguageNotice isolates the Latin language name inside Arabic prose` | reader `ar`, locales `gl` | the name is wrapped in an LTR isolate | A Latin run inside an RTL paragraph reorders around punctuation without one |
| 17 | `LegalTextLanguageNotice contains no second person in any of the six locales` | every ARB value for the four notice keys | no `you`/`your` and no locale equivalent | `catchlaw-verdict-contract` rule 2, asserted over ARB rather than trusted |

```dart
// app/test/domain/legal_text_locale_resolve_use_case_test.dart
import 'package:catchlaw/domain/models/legal_text_availability.dart';
import 'package:catchlaw/domain/use_cases/legal_text_locale_resolve_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolve = LegalTextLocaleResolveUseCase();

  test('LegalTextLocaleResolveUseCase renders the default locale '
      'when the reader locale is absent', () {
    final result = resolve(
      readerLocale: 'en',
      legalTextLocales: 'gl,es',
      defaultLocale: 'gl',
    );
    expect(
      result,
      isA<LegalTextInPublishedLanguage>()
          .having((r) => r.rendered, 'rendered', 'gl')
          .having((r) => r.published, 'published', ['gl', 'es']),
    );
  });

  test('LegalTextLocaleResolveUseCase returns not-recorded '
      'for a whitespace-only locale list', () {
    expect(
      resolve(readerLocale: 'ar', legalTextLocales: ' , ', defaultLocale: 'ar'),
      isA<LegalTextNotRecorded>(),
    );
  });

  test('LegalTextLocaleResolveUseCase does not match pt against a pt_BR entry', () {
    expect(
      resolve(readerLocale: 'pt', legalTextLocales: 'pt_BR', defaultLocale: 'pt_BR'),
      isA<LegalTextInPublishedLanguage>(),
    );
  });

  // … one test per row of the table above, one behaviour each.
}
```

```dart
// app/test/ui/reference/legal_text_language_notice_test.dart
testWidgets('RuleTextScreen resolves chrome labels through the content_string chain '
    'while the body stays Galician', (tester) async {
  tester.useDevice(Device.small);
  await tester.pumpApp(
    overrides: kGaliciaOverrides,          // legal_text_locales: 'gl,es', default_locale: 'gl'
    locale: const Locale('en'),
  );
  // Chrome takes the §9.2 chain and lands on English.
  expect(find.text(kInstrumentTypeLabelEn), findsOneWidget);
  // The law does NOT take that chain and stays as published.
  expect(find.text(kArticleBodyGl), findsOneWidget);
  expect(find.text(kArticleBodyEs), findsNothing);
});
```

**Run:** `cd app && flutter test test/domain/legal_text_locale_resolve_use_case_test.dart
test/ui/reference/legal_text_language_notice_test.dart` → 17 failures. Test 10 is the one most likely
to pass early — if it does, the notice is not being rendered at all and the widget is not wired.

## Implementation outline

1. Write the sealed `LegalTextAvailability` with three variants and const constructors. No wording
   anywhere in it — it carries locale codes, and `app/lib/ui/` turns those into sentences.
2. Write `LegalTextLocaleResolveUseCase` as a `const` class with a single `call`. Parse the CSV:
   split on `,`, trim, drop empties, canonicalise each entry (lowercase language, uppercase region,
   `_` separator). Empty result → `LegalTextNotRecorded`.
3. Add the ten ARB keys to `app_en.arb` with `@description`s that carry the constraint
   ("STATEMENT OF FACT. No imperative mood, no second person, no permission verb."), then mirror into
   the five siblings (D-3). Run `flutter gen-l10n`.
4. Write `LegalTextLanguageNotice`: `LonjaSectionLabel` rubric, an `ink` glyph, `legalSmall` prose
   naming the published language(s), and the `LonjaSegmented` picker only when `published.length > 1`.
   Wrap each language name in an LTR isolate through the one helper `i18n-rtl-l10n` names.
5. Extend `RuleTextViewModel`: resolve availability once per (reader locale, jurisdiction), expose
   it, and drive `LegalTextDao.search`'s `locale` argument from `rendered`. When the reader picks
   another published language, the view model changes `rendered` and the query re-runs — do not cache
   the previous body.
6. Handle `LegalTextNotRecorded` by rendering the empty state T09 will consolidate; the copy for it
   is authored here (surface 2 of eight).
7. Re-run the whole suite. T02's 23 tests must still be green — particularly the locale-scoping row.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 tests pass, and each failed first.
- [ ] `LegalTextLocaleResolveUseCase` imports nothing from `package:flutter` and holds no string that
      reaches a reader.
- [ ] No code path anywhere in `app/lib/` applies the §9.2 chain to `legal_text.locale`; the two
      chains are separately tested in one frame (test 12).
- [ ] The notice renders no `ochre`, `oxblood` or `verdant` token.
- [ ] The ten ARB keys exist in all six locale files with constraint-carrying `@description`s;
      `check_verdict_contract.sh app/lib` and the ARB parity check are clean.
- [ ] An empty `legal_text_locales` renders the not-recorded state and throws nothing.
- [ ] `packages/rule_engine/` untouched (D-7).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh     app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
tools/gates/no_directional_geometry.sh                                       app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(reference): state the language a legal text was published in, and never substitute another

Bundled law exists only in the language the authority published it in. An
unofficial translation of a penal instrument would be a liability and, in Spain,
outside the Art. 13 LPI carve-out, which covers official translations only. So
S13 resolves the article body against jurisdiction.legal_text_locales and stops
there, while the labels around it keep taking the §9.2 content_string chain. A
test pins both chains in one frame, because unifying them is a two-line change
that looks like consistency.

The notice carries a glyph and words and no semantic colour. Ochre would say the
paper is old; an instrument published only in Catalan is correctly published.

An empty legal_text_locales resolves to "not recorded for this jurisdiction"
rather than an exception — §7.1 declares the column NOT NULL, not non-empty, and
§16 R1 says a jurisdiction can ship rules before its verbatim text.

Task: E15/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
