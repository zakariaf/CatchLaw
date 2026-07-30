---
name: catchlaw-verdict-contract
description: >-
  Governs every word CATCHLAW prints about a rule — the five-part carve-out keeping it a reference
  tool and not legal advice, covering statements of fact never instructions, the banned imperatives
  keep, return, release and throw it back, no second person or permission verbs, the numeric margin
  plus a named method of total length, fork length or shell length, a mandatory Citation of
  instrument, article, publishedOn and checkedOn, both instruments printed when equally specific
  rules collide, the unsoftened no-rule-recorded wording, a ban on edibility, toxin and ciguatera
  claims, a stale-pack notice instead of a withheld verdict, and a non-dismissable disclaimer naming
  the authority to verify with. Use when writing a verdict
  string, authoring verdict keys in app_en.arb or app_ar.arb, adding a Verdict or Citation field,
  wording a missing-rule or expired-pack case, wiring the ambiguity dialog, or reviewing any
  user-facing sentence in a diff.
---

# Catchlaw Verdict Contract

CATCHLAW is **a printed regulations booklet with a ruler on the back cover**. A booklet quotes; it
never counsels. This skill owns what the app may SAY — sentence grammar, the banned lexicon, the
citation quadruple, the ambiguity refusal, the no-rule wording, the stale notice and the disclaimer
text. It does NOT own how a verdict is set (`lonja-verdict-and-status`), computed
(`catchlaw-rule-engine`), or compiled (`i18n-rtl-l10n`).

Read the reference for the task at hand:
- `references/the-five-part-carve-out.md` — the brief clause, the five parts, per-part tests, the
  authority table, edge cases, what voids the carve-out.
- `references/verdict-copy-rules.md` — sentence skeleton, per-category wording, BAD -> GOOD pairs
  in English and Arabic, the grep lexicon, ARB authoring rules, the six locales, numbers and dates.
- `examples/verdict_strings_test.dart` — the worked file behind every snippet below: the banned
  lexicon as const lists, swept over the copy table, every `app_*.arb` and the rendered surface.

Run `scripts/check_verdict_contract.sh` before a PR.

`lonja-verdict-and-status` owns how the verdict is SET — stamp geometry, glyphs, the ochre bar, the
citation footnote slot; this skill owns what it may SAY. Every rule here is traceable to the clause
admitting this app only "as a reference/logging tool with no advisory function".

## Non-negotiable rules

1. **Every finding is a statement of fact, never an instruction.** The shape is `state — measured,
   threshold (method)`: "Below the minimum — 38 cm measured, minimum 45 cm (total length)". NEVER an
   imperative — keep, return, release, throw it back, put it back, retain, land, discard. An
   instruction is advice, advice is the advisory function the brief auto-rejects, and the AED 3,000
   lands on Khalid while the liability lands on the publisher.

2. **No SECOND PERSON survives in any verdict string.** No "you", "your", "you may", "you can",
   "you must" — in `lib/` or in any `app_*.arb` value, in any of the six locales. The second person
   addresses the reader with a directive posture even in the indicative; "You may keep this" is an
   authorisation, and authorising a catch is the one act a booklet with a ruler cannot perform.

3. **The numeric margin is ALWAYS printed, never a bare conclusion.** Measured value, threshold and
   unit in one sentence — "34 mm measured, minimum 38 mm"; "Too small", "Undersize" and "Not
   allowed" are banned alone. Without the number the app has published its own conclusion instead of
   quoting a rule, and the reference function — the whole basis of the carve-out — has disappeared.

4. **The measurement method is NAMED beside the number.** Spell it out: "total length", "fork
   length", "carapace width", "shell length" — never bare `TL`, `FL`, `CW` or `SHL` in user copy.
   Kanaad is 65 cm FORK length and Hamour 45 cm TOTAL length; an unnamed method turns a correct
   number into a wrong verdict stated with full confidence, measured to the wrong point on the fish.

5. **A finding is unconstructable without its Citation quadruple.** `Citation({required instrument,
   required article, required publishedOn, required checkedOn})` — "Ministerial Decision 580/2015,
   Art. 3 · published 2015-11-03 · checked 2026-07-14". Never `Citation?`, never `?? 'Local
   rules'`. An uncited finding is opinion, and the carve-out holds only while the app READS.

6. **Genuine ambiguity is SHOWN in full, never resolved.** Two rules of equal specificity produce
   `ConflictingRules(rules)` and a dialog printing BOTH statements with BOTH citations in source
   order — no `reduce`, no `sort`, no "strictest wins", no "recommended" badge, no silent `.first`.
   Choosing between two live instruments is the act an adviser performs; the conflict is the reader's.

7. **The no-rule wording is FIXED and may not be softened.** "No rule recorded for this species
   here. This does not mean it is legal." Both sentences, always, in every locale — never "No
   restrictions found", never an empty screen, never `VerdictCategory.meets` by default. Silence in
   the sources read as permission is the costliest misreading this app can cause; sentence two blocks it.

8. **The app NEVER interprets, infers or reasons by analogy.** Banned in copy and in comments that
   become copy: "probably", "likely", "should be", "appears to", "similar to", "counts as", "we
   think", "typically", "usually", "close enough". A hedged inference is legal advice with a
   qualifier bolted on, and the qualifier is what gets read back as evidence of awareness.

9. **NO health, edibility, toxin or safety claim, in any string, ever.** Banned: "safe to eat",
   "edible", "poisonous", "toxic", "venomous", "ciguatera", "scombroid", "histamine", "mercury",
   "allergen", "do not consume". Food safety is a different regulated domain with a bodily
   consequence, sourced from nothing in the shipped DB, and one such string voids the whole carve-out.

10. **An expired ruleset is EVALUATED and shown, never withheld.** The engine runs unchanged, the
    verdict prints at full strength, and an ochre notice states "Rule data expired 2026-06-30 —
    still shown, verify before relying on it". Never `Verdict.unavailable()`, never a blocking
    dialog. Withholding is itself advice — deciding the fisher is better off with nothing.

11. **The disclaimer is permanent, on-screen, and NAMES the authority.** Rendered structurally:
    "CatchLaw quotes published instruments. It is not legal advice and does not authorise any catch.
    Verify with the Ministry of Climate Change and Environment before relying on it." No "Got it",
    no "Do not show again", no ⓘ. A dismissable disclaimer is, in the record, one never shown.

12. **Every verdict string lives in ARB with the constraint in its @description.** Keys are prefixed
    `verdict*`, `finding*`, `citation*` or `disclaimer*`, every number is a placeholder, and each
    `@key.description` opens "STATEMENT OF FACT. No imperative mood, no second person, no permission
    verb." A translator asked for natural Arabic returns أعِدْه إلى البحر — an imperative no
    English-language grep will ever catch — so the constraint must ship with the key.

## The sentence grammar of a finding

One shape, filled from the engine's numbers, with nothing appended. State, margin, threshold, method
— no verb the reader is expected to obey and no adjective the app invented.

```dart
// WRONG — an instruction, no number, no method: a conclusion with advice attached.
Text('Too small — throw it back');

// RIGHT — state, measured, threshold, method. Nothing else in the sentence.
String finding(Finding f) =>
    '${f.state} — ${f.measured} ${f.unit} measured, minimum ${f.minimum} ${f.unit} (${f.method})';
// 'Below the minimum — 38 cm measured, minimum 45 cm (total length)'    Hamour
// 'Meets the minimum — 70 cm measured, minimum 65 cm (fork length)'     Kanaad
// 'Below the minimum — 34 mm measured, minimum 38 mm (shell length)'    Ameixa babosa
// 'Closed season — 1 March to 30 April. In force today, day 14 of 61.'  Sha'ri, no measurement
// 'Protected species — taking prohibited.'                              no measurement line
```

## The citation quadruple is part of the sentence

A finding without its source is an oracle pronouncing. Make the quadruple structurally required.

```dart
// WRONG — nullable citation plus a friendly fallback that names a nonexistent instrument.
final class Verdict { const Verdict({this.citation}); final Citation? citation; }
Text(v.citation?.label ?? 'Local fisheries rules');

// RIGHT — unconstructable without the quadruple; the statement is a quotation with a source.
final class Citation {
  const Citation({required this.instrument, required this.article,
      required this.publishedOn, required this.checkedOn});
  final String instrument;    // 'Ministerial Decision 580/2015'
  final String article;       // 'Art. 3'
  final DateTime publishedOn; // 2015-11-03
  final DateTime checkedOn;   // 2026-07-14
}
final class Verdict {
  const Verdict({required this.statement, required this.citation});
  final String statement;
  final Citation citation; // non-null, no default, no fallback, no Citation.unknown()
}
```

## Refusing to resolve ambiguity

Two equally specific instruments over one catch is a fact about the law, not an engine defect. The
app reports the conflict, does not adjudicate it, and does not lean strict to feel safe.

```dart
// WRONG — the stricter rule silently wins. The app has just given legal advice.
final rule = candidates.reduce((a, b) => a.minLengthCm > b.minLengthCm ? a : b);

// RIGHT — equal specificity is reported, in source order, with neither ranked.
sealed class Finding { const Finding(); }
final class SingleRule extends Finding { const SingleRule(this.rule); final Rule rule; }
final class ConflictingRules extends Finding {
  const ConflictingRules(this.rules); // 2+, SOURCE order — no sort, no 'recommended', no primary
  final List<Rule> rules;
}
// Printed by the ambiguity dialog, both plates at identical weight, no primary action:
//   'Two rules of equal standing apply here.'
//   '45 cm total length — Ministerial Decision 580/2015, Art. 3 · checked 2026-07-14'
//   '50 cm total length — Ras Al Khaimah Local Order 4/2019, Art. 7 · checked 2026-07-14'
```

## The absence of a rule, and the wording that may not be softened

An untranscribed species is a gap in the reference database, not a permission. It gets one wording,
both sentences, and still cites what was searched and when that source was last checked.

```dart
// WRONG — three flavours of reading silence as permission.
if (rules.isEmpty) return const Verdict.meets();                       // default-allow
if (rules.isEmpty) return const Text('No restrictions found');         // softened
if (rules.isEmpty) return const SizedBox.shrink();                     // nothing at all

// RIGHT — the fixed wording, never abbreviated to its first sentence, still cited.
// 'No rule recorded for this species here. This does not mean it is legal.'
if (rules.isEmpty) {
  return NoRuleRecorded(statement: l10n.verdictNoRuleRecorded, searched: searchedInstrument);
}
```

## ARB authoring: the constraint travels with the key

The English string is not the artefact — the key plus its `@description` is. Every number is a
placeholder so no translator restates a measurement, and the constraint ships with the key.

```dart
// WRONG — natural-sounding copy plus a description that carries no constraint at all.
// "verdictBelowMinimum": "Too small, put it back",
// "@verdictBelowMinimum": {"description": "Shown when the fish is under the minimum"}

// RIGHT — fact-shaped, fully placeholdered, constraint stated to the translator.
// "verdictBelowMinimum": "Below the minimum — {measured} {unit} measured, minimum {min} {unit} ({method})",
// "@verdictBelowMinimum": {
//   "description": "STATEMENT OF FACT. No imperative mood, no second person, no permission verb.
//                   The reader is never told what to do. All four placeholders are required.",
//   "placeholders": {"measured": {}, "unit": {}, "min": {}, "method": {}}
// }
final s = l10n.verdictBelowMinimum('38', 'cm', '45', l10n.methodTotalLength);
// ar: 'دون الحد الأدنى — 38 سم مُقاسة، الحد الأدنى 45 سم (الطول الكلي)' — indicative, no imperative
```

## Stale is shown; withholding is itself advice

Expiry changes nothing about the evaluation and nothing about the finding's wording — it adds one
more dated fact to the page. The app never decides for the reader that nothing is better.

```dart
// WRONG — the app decides he is better off with no answer. That decision is advisory.
if (pack.validUntil.isBefore(today)) return const Verdict.unavailable();

// RIGHT — evaluate unchanged, print unchanged, state the staleness as another dated fact.
return VerdictSurface(
  finding: engine.evaluate(landed, pack), // expiry is not an input to the evaluation
  // 'Rule data expired 2026-06-30 — still shown, verify before relying on it'
  staleNotice: pack.isExpired ? l10n.verdictPackExpired(pack.validUntil) : null,
);
// NEVER greyed, blurred, gated behind a dialog, or replaced by 'Check again later'.
```

## The disclaimer names the authority to verify with

A generic "not legal advice" is a shrug. Naming the body that publishes the instrument makes the app
legible as a reader of that body's text, and it tells Khalid where to go next.

```dart
// WRONG — dismissable, unnamed, and one tap from never having been shown.
if (!seenDisclaimer) messenger.showSnackBar(SnackBar(content: const Text('Not legal advice'),
    action: SnackBarAction(label: 'Got it', onPressed: dismiss)));

// RIGHT — a structural const child, no flag, no dismiss, authority resolved from the zone.
const LonjaDisclaimer(); // fixed slot on the result surface — see lonja-verdict-and-status
// en (UAE): 'CatchLaw quotes published instruments. It is not legal advice and does not authorise
//            any catch. Verify with the Ministry of Climate Change and Environment before relying
//            on it.'   gl: Consellería do Mar · pt: IBAMA — authority table in the reference.
```

## Anti-patterns

- **`Text('Throw it back')`** — an imperative on the result surface converts a quotation into
  counsel, and `check_verdict_contract.sh` fails the build on it in Dart and in every ARB locale.
- **`'You may keep this fish'`** — second person plus a permission verb; the app has authorised a
  catch it has no standing to authorise.
- **`'Too small'` with no number, or `'minimum 65 cm'` with no method named** — a conclusion with no
  quotable rule behind it; Kanaad is 65 cm FORK length, and measured as total length the reader
  lands an undersized fish while reading a verdict that says he did not.
- **`Citation? citation`** — the first path built without one ships an uncited verdict, and the one
  moment it matters is standing in front of an inspector.
- **`candidates.reduce((a, b) => a.minLengthCm > b.minLengthCm ? a : b)`** — silently adjudicates
  between two live instruments; "we chose the stricter one" is still choosing.
- **`'No restrictions found for this species'`** — softens a gap in the reference DB into permission
  and drops the second sentence that is the entire point of the wording.
- **`'This is probably an Epinephelus coioides'`** — an inference the app is not entitled to make;
  the hedge does not reduce the liability, it documents it.
- **`'Safe to eat once bled'` or any ciguatera note** — a food-safety claim sourced from nothing in
  the shipped DB, and it voids the reference-tool carve-out for the whole product.
- **`if (pack.isExpired) return const Verdict.unavailable()`, or a dismissable disclaimer** — the
  first withholds the last verified wording at sea, the second was never shown at all.
- **`"@verdictProtected": {"description": "Protected species message"}`** — the constraint does not
  travel with the key, and the Arabic translator produces a fluent imperative nobody greps for.

## Definition of done

- [ ] `scripts/check_verdict_contract.sh` is clean over `lib/`.
- [ ] No imperative verb and no second person appears in any Dart verdict literal or any `app_*.arb`
      value, `app_ar.arb` and `app_pt.arb` included (rules 1, 2, 12).
- [ ] Every finding string prints measured value, threshold, unit and a spelled-out measurement
      method in one sentence (rules 3, 4).
- [ ] `Citation` is non-nullable on `Verdict` and `NoRuleRecorded`, with no `??` instrument-name
      fallback anywhere (rule 5).
- [ ] Two equally specific rules produce `ConflictingRules` with both citations in source order and
      no sort, no primary action and no "recommended" affordance (rule 6).
- [ ] The no-rule case prints both sentences verbatim in all six locales and cites what was searched
      (rule 7).
- [ ] `grep -rniE 'edible|ciguatera|toxic|safe to eat|mercury'` over `lib/` and `**/*.arb` returns
      nothing (rules 8, 9).
- [ ] An expired pack still renders a full verdict plus the dated notice, and the disclaimer renders
      unconditionally with a named authority and no dismiss affordance (rules 10, 11).
- [ ] `examples/verdict_strings_test.dart` runs green in CI as a blocking gate, not a smoke test.

## Related skills

- See `lonja-verdict-and-status` for how the sentence is SET — stamp geometry, the four categories,
  non-colour signals, the ochre bar and the citation footnote slot.
- See `catchlaw-rule-engine` for how the category, the shortfall, the closure dates and the
  equal-specificity conflict are computed before any wording exists.
- See `catchlaw-reference-database` for the instrument, article, `publishedOn` and `checkedOn`
  columns in the read-only asset DB.
- See `catchlaw-content-pipeline` for how a transcribed instrument acquires its citation quadruple.
- See `catchlaw-measurement-ruler` for TL, FL, CW and SHL and the unit that follows the instrument.
- See `catchlaw-offline-guarantee` for why an expired pack is shipped, evaluated and shown.
- See `lonja-dialogs-and-surfaces` for the ambiguity dialog shell and `barrierDismissible: false`.
- See `i18n-rtl-l10n` for ARB mechanics, gen-l10n, ICU plurals, bidi isolation and numeral systems
  the verdict strings are compiled through.

## References

- Flutter docs — Internationalizing Flutter apps: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- ARB — Application Resource Bundle specification: https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification
- Dart language — Class modifiers and sealed classes: https://dart.dev/language/class-modifiers
- Flutter API — Semantics: https://api.flutter.dev/flutter/widgets/Semantics-class.html
- Flutter docs — Testing Flutter apps: https://docs.flutter.dev/testing/overview
- Unicode — UAX #9 Bidirectional Algorithm: https://www.unicode.org/reports/tr9/
