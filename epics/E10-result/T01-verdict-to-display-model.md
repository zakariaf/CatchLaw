# E10/T01 — Verdict to display model

| | |
|---|---|
| **Epic** | E10 — The result screen |
| **Branch** | `epic/10-result` (shared) |
| **Commit** | `feat(result): map a resolution to a localised display model` |
| **Depends on** | E03 (sealed `Resolution`), E06 (ARB + `content_string` resolver), E09 (a measurement) |
| **Size** | M |
| **Spec** | `SPEC.md` §5.1 points 1–4, §4.1 "Result display", §7.3 finding precedence, §9.2 two-tier translation |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-verdict-contract` | Owns the sentence. Rules 1–5 fix the slot order, the mandatory numeric margin and the spelled-out method; rule 12 fixes the ARB key prefixes this task creates |
| `catchlaw-rule-engine` | Owns what arrives: `Resolution`, `RuleFinding`, `FindingKind`, `isExpired`, and the three distinct no-rule variants this task must keep distinct |
| `lonja-verdict-and-status` | Rule 2 — the four `VerdictCategory` values, and the ban on the surface re-deriving a category from a measurement |
| `catchlaw-conventions-index` | The one-way layer map: this is `lib/ui/`, it reads engine types and repository values, and it never touches a DAO |
| `i18n-rtl-l10n` | Rules 1–3: every string through gen-l10n, key and placeholder parity, ICU rather than concatenation |
| `state-management-riverpod` | Where the presenter is bound: a plain `Provider` for the collaborator, a derived provider for the display value; no `BuildContext` in the mapping |
| `naming-conventions` | The role suffixes and file names below |
| `dartdoc-conventions` | The display types are a public surface for four later tasks; each needs a `///` that says why, not what |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §5.1 points 1–4 | Why a statement of fact, why the citation, why ambiguity is not resolved, why nothing is interpreted |
| `SPEC.md` | §4.1 "Result display", "Unknown species", "No-rule-vs-no-data" | The two visually distinct absence states, and the wording that may not be softened |
| `SPEC.md` | §7.3 last paragraph | Finding precedence, and that the first failure headlines while the rest are secondary |
| `SPEC.md` | §9.2 | Which strings are tier 1 (ARB) and which are tier 2 (`content_string`), and the fallback chain |
| `.claude/skills/catchlaw-verdict-contract/references/verdict-copy-rules.md` | "The sentence skeleton", "Per-state wording", "Numbers, units and dates" | The four slots in order, the per-state phrases, and the rule that the unit follows the instrument |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "Finding precedence", "Edge cases" | The six `FindingKind`s, and that `indeterminate` never prints as a pass |
| `.claude/skills/lonja-verdict-and-status/references/states-and-signals.md` | "The signal matrix", "The absence of a rule is not a verdict" | Which categories carry a measurement sub-line, and that absence is stamped as nothing |
| `FLUTTER_GUIDE.md` | §1.3 | A ViewModel transforms data for presentation, exposes no mutable state, holds no `BuildContext` |
| `epics/DECISIONS.md` | D-7, D-3 | The engine holds no sentence; the six locale filenames |

## What this delivers

- `app/lib/ui/result/view_models/result_display.dart` — the immutable display value types:
  `ResultDisplay`, `VerdictStampDisplay`, `FindingDisplay`, `RuleFactRow`, `CitationDisplay`,
  `NoteDisplay`, `AmbiguityDisplay`, `StaleDisplay`. Every string on them is already localised;
  nothing downstream formats a number or looks up a key.
- `app/lib/ui/result/view_models/verdict_presenter.dart` — `VerdictPresenter`, a pure class taking
  `AppLocalizations` and the `ContentStrings` resolver, with one method
  `ResultDisplay present(Resolution resolution, Measurement? reading, ResultContext context)`.
- `app/lib/ui/result/view_models/result_providers.dart` — `verdictPresenterProvider` (plain
  `Provider`, built from the active `Locale` via the generated `lookupAppLocalizations`) and
  `resultDisplayProvider` (family keyed by species id + reading).
- `app/lib/l10n/app_{ar,en,es,gl,ca,pt_BR}.arb` — the `verdict*` and `finding*` keys for all nine
  states, every number a placeholder, every `@description` opening `STATEMENT OF FACT.`
- `app/testing/models/result_fixtures.dart` — `kResolutionHamourBelowMinimum`,
  `kResolutionShariClosedSeason`, `kResolutionSawfishProtected`, `kResolutionAmeixaExpired`,
  `kResolutionNoRuleFound`, `kResolutionAmbiguousBank`, `kCitationMd580`, `kCitationXunta`.
- `app/test/ui/result/verdict_presenter_test.dart`.

No engine file is touched. No widget is written in this task.

## Why it is built this way

**D-7 is the whole shape of this task.** `packages/rule_engine/` returns numbers, enums, a required
`Citation` and an `isExpired` flag, and holds no user-visible sentence in any language. Something has
to turn `RuleFinding(kind: minSize, thresholdMm: 450, methodCode: 'TL', …)` plus a reading of 380 mm
into *"Below the minimum — 38 cm measured, minimum 45 cm (total length)"* in six languages. That
something is this file, and it is a plain Dart class rather than a widget so the sentence can be
asserted in all six locales without pumping a widget tree — six `expect`s instead of six
`pumpWidget`s.

**Three sources, assembled here and nowhere else.** The ARB carries the skeleton with placeholders
(`verdictBelowMinimum`). `content_string` carries the bundled-content words: the spelled-out
measurement method from `measurement_method.name_key`, the localised instrument-type label from
`citation.instrument_type_key`, the authority from `jurisdiction.authority_key`, rule notes from
`notes_key`. The engine carries the numbers. §9.2 draws that line and the content build already
fails on any `*_key` missing from any shipped locale (§8), so a missing tier-2 string is a build
error upstream rather than a runtime fallback here.

**The category selects the signal set; the finding kind selects the sentence.**
`lonja-verdict-and-status` rule 2 fixes four `VerdictCategory` values and forbids a fifth;
`SPEC.md` §7.3 names six `FindingKind`s. Mapping `FindingKind.maxSize` onto `VerdictCategory
.belowMinimum` and letting the headline follow the category prints *"Below the minimum"* over a
122 cm fish that failed a slot rule — a confident, wrong, legally distinct statement. So the mapping
is split: the category chooses ink, glyph and whether a measurement sub-line is printed at all; the
ARB key is chosen by `FindingKind`. `maxSize`, `minSize`, `bagLimit` and `vesselLimit` share the
adverse-measurement signal set and each keep their own sentence.

**Three absences stay three absences.** `NoRuleFound` prints the fixed two-sentence wording and the
citations of what *was* searched. `NoLimitInInstrument` prints a cited positive statement — the
instrument was read and records no limit — and is not `.meets`, because stamping "meets the minimum"
when only the size rule was addressed states that every rule is satisfied. `Ambiguous` prints no
stamp at all. In all three cases `VerdictStampDisplay?` is null and `NoteDisplay?` carries the serif
note, which is what `states-and-signals.md` means by "silence in the sources is not permission".

**The unit follows the instrument.** `verdict-copy-rules.md` is explicit: a Galician shell length
stays in mm on an Arabic phone. The presenter converts the measured millimetres into the unit the
threshold is stated in, so both numbers in one sentence are comparable; `user_profile.length_unit`
governs the ruler readout (E09), not the quoted rule. The measured value is the user's own number
echoed back — no silent rounding here; rounding belongs to E09.

**Rejected — a `String statement` field on the engine's `Verdict`.** It would put user-visible
sentences into `packages/rule_engine/`, which D-7 forbids, and it would make the pure-Dart package
depend on an ARB, breaking the `dart run content_builder:build` compile that shares it.

**Rejected — assembling the sentence in `build()`.** `FLUTTER_GUIDE.md` §1.2 allows a View only
simple flag checks, animation, layout and routing. It also costs six widget pumps per string instead
of six function calls, and `check_verdict_contract.sh` would then be sweeping a file whose strings
are built by interpolation across three call sites rather than declared in one.

**Rejected — a `String? statement` with a `?? 'No rule'` fallback.** Every anti-pattern list in
`catchlaw-verdict-contract` names the nullable-plus-fallback shape; the fallback is the string that
ships when a case is missed.

## Tests first

Write every row before touching `verdict_presenter.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `VerdictPresenter.present states the shortfall with both numbers and the method` | Hamour, 380 mm TL, min 450 mm TL | `Below the minimum — 38 cm measured, minimum 45 cm (total length)` | The §5.1 point-1 headline case; it is the sentence the whole product prints |
| 2 | `VerdictPresenter.present names the method for a fork-length rule` | Kanaad, 700 mm FL, min 650 mm FL | sentence contains `(fork length)` and not `(total length)` | 65 cm fork length is not 65 cm total length; an unnamed method is a wrong verdict stated confidently |
| 3 | `VerdictPresenter.present keeps the instrument's unit with a millimetre rule` | Ameixa babosa, 34 mm SHL, min 38 mm SHL | `34 mm measured, minimum 38 mm (shell length)` | The unit follows the instrument, never the locale or the user's cm preference |
| 4 | `VerdictPresenter.present echoes the measured value unchanged` | 386 mm against a 450 mm rule | the sentence carries `38.6`, not `39` | Rounding here would put a number on screen the ruler never showed |
| 5 | `VerdictPresenter.present selects verdictAboveMaximum for a maxSize failure` | 1 220 mm TL against max 1 200 mm | headline key is `verdictAboveMaximum`, category is the adverse signal set | The seam this task exists to get right — four categories, six finding kinds |
| 6 | `VerdictPresenter.present prints no measurement sub-line when the category is protected` | protected sawfish, reading present | `stamp.subLine` is null | A measurement beside a prohibition implies a threshold that does not exist |
| 7 | `VerdictPresenter.present prints no measurement sub-line when the category is closedSeason` | Sha'ri, 520 mm, 14 March | `stamp.subLine` is null, headline names both dates and day 14 of 61 | A closure applies to all sizes; a size number would suggest otherwise |
| 8 | `VerdictPresenter.present headlines the protected finding when a size rule also fails` | protected species, 380 mm, min 450 mm | headline kind is `protected`, `minSize` is present in `secondary` | §7.3 precedence, and the failure it prevents: a protected sawfish headlined as a short grouper |
| 9 | `VerdictPresenter.present keeps the engine's secondary order` | secondary `[minSize, bagLimit]` | display secondary is `[minSize, bagLimit]` | The engine ranks once; a second sort in the app is a second, untested opinion |
| 10 | `VerdictPresenter.present emits both sentences of the no-rule wording` | `NoRuleFound` | text contains `This does not mean it is legal.` and the searched citations | Losing the second sentence turns a gap in the reference DB into a permission |
| 11 | `VerdictPresenter.present distinguishes NoLimitInInstrument from NoRuleFound` | `NoLimitInInstrument(citation:)` | a different key, a non-null citation, and no stamp | §4.1's "two visually distinct states"; they are legally miles apart |
| 12 | `VerdictPresenter.present emits no stamp for an ambiguous resolution` | `Ambiguous([a, b])` | `stamp` is null, `ambiguity.rules.length` is 2 in source order | The app never picks; a stamp would be a pick |
| 13 | `VerdictPresenter.present carries isExpired without altering the finding text` | the same `Decided` fresh and expired | the two sentences are equal; only `stale` differs | Invariant 5, and the §14 expiry check in unit-test form |
| 14 | `VerdictPresenter.present marks a size finding indeterminate when the reading is null` | species picked, no measurement | the size finding is indeterminate, never a pass | "Cannot be evaluated" is a safe statement of fact; a pass is not |
| 15 | `VerdictPresenter.present reports methodMismatch without comparing the numbers` | 700 mm TL against a 650 mm FL rule | a mismatch finding, and no "meets"/"below" sentence | Crossing methods manufactures a pass at the centimetre that costs AED 3,000 |
| 16 | `ar - VerdictPresenter.present builds the below-minimum sentence in the indicative` | Hamour, 380 mm, locale `ar` | text starts `دون الحد الأدنى`, and contains none of `احتفظ أعِدْه يمكنك` | The Arabic imperative is one fluent word and invisible to every English-language grep |
| 17 | `VerdictPresenter.present resolves the method name through content_string` | method row `name_key: 'method.tl'` | the sentence uses the resolver's value, not a Dart constant | §9.2 tier 2; a hardcoded "total length" is untranslated in five locales |
| 18 | `VerdictPresenter.present builds a citation display with all four fields` | `kCitationMd580` | instrument, article, published `2015-11-03`, checked `2026-07-14`, all non-null | Invariant 3, and the ISO dates that can be compared against a printed instrument by eye |
| 19 | `VerdictPresenter.present includes the closed-season dates as day and month` | closure 1 Mar – 30 Apr | text contains `1 March` and `30 April`, not `2026-03-01` | §9.5 dates rule; an ISO date in prose is unreadable to the man holding the fish |
| 20 | `VerdictPresenter.present names the authority from the active jurisdiction` | `ES-GA` | the disclaimer authority is the `content_string` value for `authority_key` | The disclaimer is per-jurisdiction; a generic one is a shrug (T09 renders it) |

```dart
// app/test/ui/result/verdict_presenter_test.dart
import 'package:catchlaw/l10n/app_localizations.dart';
import 'package:catchlaw/ui/result/view_models/verdict_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart';

import '../../../testing/models/result_fixtures.dart';

void main() {
  late VerdictPresenter en;

  setUp(() {
    en = VerdictPresenter(
      l10n: lookupAppLocalizations(const Locale('en')),
      content: FakeContentStrings(kSeedStrings),
    );
  });

  group('VerdictPresenter', () {
    test('.present states the shortfall with both numbers and the method', () {
      final display = en.present(kResolutionHamourBelowMinimum,
          const Measurement.mm(380, MeasurementMethod.tl), kContextRasAlKhaimah);

      expect(display.stamp!.headline,
          'Below the minimum — 38 cm measured, minimum 45 cm (total length)');
    });

    test('.present prints no measurement sub-line when the category is protected', () {
      final display = en.present(kResolutionSawfishProtected,
          const Measurement.mm(1800, MeasurementMethod.tl), kContextRasAlKhaimah);

      expect(display.stamp!.category, VerdictCategory.protected);
      expect(display.stamp!.subLine, isNull);
    });

    test('.present carries isExpired without altering the finding text', () {
      final fresh = en.present(kResolutionAmeixaFresh, kAmeixaReading, kContextCambados);
      final stale = en.present(kResolutionAmeixaExpired, kAmeixaReading, kContextCambados);

      expect(stale.stamp!.headline, fresh.stamp!.headline);
      expect(stale.stale, isNotNull);
      expect(fresh.stale, isNull);
    });

    test('.present emits no stamp for an ambiguous resolution', () {
      final display = en.present(kResolutionAmbiguousBank, kAmeixaReading, kContextCambados);

      expect(display.stamp, isNull);
      expect(display.ambiguity!.rules.map((r) => r.minimum).toList(), <String>['38 mm', '40 mm']);
    });

    test('ar - .present builds the below-minimum sentence in the indicative', () {
      final ar = VerdictPresenter(
        l10n: lookupAppLocalizations(const Locale('ar')),
        content: FakeContentStrings(kSeedStrings),
      );
      final headline = ar
          .present(kResolutionHamourBelowMinimum,
              const Measurement.mm(380, MeasurementMethod.tl), kContextRasAlKhaimah)
          .stamp!
          .headline;

      expect(headline, startsWith('دون الحد الأدنى'));
      for (final banned in const <String>['احتفظ', 'أعِدْه', 'يمكنك']) {
        expect(headline.contains(banned), isFalse, reason: 'imperative in an ar verdict');
      }
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/ui/result/verdict_presenter_test.dart` → 20 failures. If any
passes now, the test is wrong — fix the test before writing the presenter.

## Implementation outline

1. Declare the display types in `result_display.dart`. All `final`, all const constructors, value
   equality (`==`/`hashCode`) so Riverpod's `==` filter can drop identical rebuilds
   (`FLUTTER_GUIDE.md` §5.3). `CitationDisplay` has four non-nullable fields; `ResultDisplay.stamp`,
   `.note`, `.ambiguity` and `.stale` are nullable and exactly one of `stamp`/`note`/`ambiguity` is
   non-null.
2. Add the ARB keys to `app_en.arb` first, with placeholders and constraint-carrying descriptions,
   then mirror key-for-key into the other five (D-3). Nine states plus the secondary-finding labels.
3. Write `_categoryFor(FindingKind)` — total, exhaustive, no `default:`. `protected → .protected`,
   `closedSeason → .closedSeason`, the four measurement kinds → the adverse signal set, no failure →
   `.meets`.
4. Write `_headlineKeyFor(FindingKind)` — a separate total function, so a new `FindingKind` fails to
   compile in two places rather than silently inheriting a neighbour's sentence.
5. Write `present()` as one `switch` over the sealed `Resolution` with no `default:` arm. `Decided`
   builds the stamp from the headline finding and the secondary list in arrival order;
   `NoLimitInInstrument` and `NoRuleFound` build a `NoteDisplay`; `Ambiguous` builds
   `AmbiguityDisplay` with the rules in source order.
6. Format numbers through the E06 locale-aware formatter; format citation dates as unlocalised ISO.
   Convert the reading into the threshold's unit; never into the device unit.
7. Bind it in `result_providers.dart`: `verdictPresenterProvider` is a plain `Provider` reading the
   locale provider and the content-string resolver; `resultDisplayProvider` is a family that watches
   the engine result and the presenter. No `BuildContext` in either.
8. Re-run the suite. All 20 green, and every E08/E09 test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 tests pass, and each failed first.
- [ ] `check_verdict_contract.sh app/lib` is clean, including the ARB passes over all six files.
- [ ] Every display type that carries a finding has a required, non-nullable `CitationDisplay`.
- [ ] `_categoryFor` and `_headlineKeyFor` are exhaustive switches with no `default:` arm.
- [ ] No `BuildContext`, no widget import and no DAO reference anywhere in `view_models/`.
- [ ] The presenter contains no `DateTime.now()`; today's date arrives on `ResultContext`.
- [ ] `app_en.arb` and the five others carry an identical key set and identical placeholder names.
- [ ] Every public display type and `present()` carry a `///` that states why, not what.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh      app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(result): map a resolution to a localised display model

The engine returns numbers, enums and a citation and holds no sentence in
any language (D-7), so the sentence has to be assembled somewhere. It is
assembled here, from the ARB skeleton, the content_string words and the
engine's numbers, in a plain Dart class rather than a widget — six locales
are then six expects instead of six widget pumps.

The four VerdictCategory values choose the signal set and the six
FindingKinds choose the sentence. Collapsing them would print "Below the
minimum" over a 122 cm fish that failed a slot rule.

Task: E10/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
