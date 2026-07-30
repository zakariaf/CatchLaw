---
name: lonja-verdict-and-status
description: >-
  Enforces the CatchLaw result surface — the letterpress verdict stamp struck between 4dp double
  rules 48dp beneath the engraved plate, the four categories meets, below-minimum, closed-season and
  protected, three non-colour signals per category so glyph and word survive greyscale and glare,
  protected separated from below-minimum by mark and wording because both take oxblood 7A2320, the
  non-blocking ochre StaleRuleBar under the app bar, a citation footnote carrying instrument,
  article, published and checked dates, and a permanent non-dismissable disclaimer. Use when
  building the result screen, adding a VerdictCategory, styling LonjaVerdictPanel or
  CitationFootnote or LonjaDisclaimer, wiring rule-pack expiry, tuning sunlight mode where every
  grey is deleted, auditing colour-only status encoding, checking app_ar.arb for imperative verdict
  strings, or reviewing verdict_panel.dart in a diff.
---

# Lonja Verdict and Status

A verdict is a **printed judgement, not a notification**: it is struck into the sheet between double
rules, it cites the instrument it quotes, and it carries a disclaimer nobody can switch off. This
skill owns how the result surface is SET — stamp geometry, the four categories and their non-colour
signals, the ochre stale bar, the citation footnote and the permanent disclaimer. It does not own
the wording (`catchlaw-verdict-contract`) or the evaluation (`catchlaw-rule-engine`).

Read the reference for the task at hand:
- `references/verdict-anatomy.md` — screen order, stamp geometry, double-rule construction, citation
  footnote, disclaimer block, sunlight reversal, glove deltas.
- `references/states-and-signals.md` — the four categories, the signal matrix, the stale axis,
  precedence when several rules fail, the banned-imperative lexicon, greyscale proof.

Run `scripts/check_lonja_verdict.sh` before a PR.

The sentence a fisher reads is a legal contract owned by `catchlaw-verdict-contract`; this skill
governs only how that sentence is set, marked and framed — and enforces at the widget that it is
never an imperative.

## Non-negotiable rules

1. **The verdict is struck, never carded.** Two 4dp double rules above and below the stamp in
   `currentColor`, `Transform.rotate(angle: -0.0096)` (-0.55 degrees), 48dp below the plate; no
   `Card`, no `elevation`, no `BorderRadius`, no `BoxShadow`, no fill outside sunlight mode.
   **WHY:** a card reads as a dismissable notification; this screen is a judgement already printed.

2. **Four categories, and the surface never invents a fifth.** `VerdictCategory.meets`,
   `.belowMinimum`, `.closedSeason`, `.protected`, switched exhaustively with NO `default:` arm and
   no nullable category. The engine hands the category down (`catchlaw-rule-engine`); the widget
   NEVER re-derives it from `measuredCm` or from a date. **WHY:** a screen that recomputes the law
   drifts silently from the engine that is actually tested.

3. **EVERY category carries three non-colour signals.** Glyph, headline word, and a structural third
   — sub-line kind, meta line or stamp fill — enumerated in `references/states-and-signals.md` and
   identical in all three themes. The never-colour-alone floor is owned by `accessibility-as-code`;
   this skill fixes WHICH three signals each category spends. **WHY:** dawn glare, a wet screen and
   a greyscale golden each delete hue first.

4. **Protected is not below-minimum in another shade.** Both are printed in oxblood `#7A2320`, so
   hue separates nothing: `Icons.block` against `Icons.close`, "Protected species — taking
   prohibited" against "Below the minimum", and protected carries NO measurement sub-line at all —
   its meta reads "Protection · no size or season applies". **WHY:** a fisher reading only the red
   treats a protected sawfish as a short grouper and lands it.

5. **The stale bar is ochre, non-blocking and never modal.** `StaleRuleBar` sits under the app bar:
   1dp `#8A6A16` rules top and bottom on `#E8E0C6`, warning glyph, "Rule data expired 2026-06-30 —
   still shown, verify before relying on it." It never gates, greys, blurs or delays the verdict
   beneath it. **WHY:** offline a stale rule beats no rule, and an interstitial burns the whole
   ten-second budget.

6. **The result surface NEVER renders an imperative.** No keep, return, release, discard, throw it
   back, put it back, land or retain — in a Dart literal or in any `app_*.arb` value. State the fact
   and the shortfall: "38 cm measured · minimum 45 cm · total length". The wording is owned by
   `catchlaw-verdict-contract`; this rule is its lint, and `scripts/check_lonja_verdict.sh` fails
   the build. **WHY:** an instruction is advice, advice is liability, and the AED 3,000 lands on him.

7. **Every verdict widget takes a REQUIRED, non-null citation.** `VerdictPanel({required Citation
   citation})` carrying instrument, article, `publishedOn` and `checkedOn` — never `Citation?`,
   never a default, never `citation ?? Citation.unknown()`. **WHY:** an uncited verdict is an
   opinion, and the one moment it matters is standing in front of an inspector.

8. **The disclaimer is a structural child, never a conditional.** `const LonjaDisclaimer()` occupies
   a fixed slot in the panel — no `if`, no `Visibility`, no `showDisclaimer` flag, no dismiss
   callback, no "do not show again", no `Opacity`. **WHY:** a disclaimer behind a conditional is a
   disclaimer a hotfix turns off, and the screen with legal exposure is the one it was on.

9. **Semantic ink means; harbour never votes.** Verdant `#2E5E3A`, oxblood `#7A2320` and ochre
   `#8A6A16` appear ONLY where a rule state is stated; harbour `#1B4D5E` is chrome and never enters
   the stamp, the rule table's verdict cells, or the stale bar. **WHY:** once the accent can look
   like a verdict, no colour on the screen is evidence any more.

10. **Sunlight mode deletes every grey and leaves ONE colour.** `ink-muted`, `ink-faint` and `rule`
    collapse to `#000000`, rules double in weight, verdant and ochre collapse to `#000000`, and the
    stamp reverses out: solid ground (`#8E0F0C` when adverse, else `#000000`), `#FFFFFF` ink, tilt
    0, borders removed. **WHY:** at 05:40 in direct sun a 3.5:1 grey is not dim, it is absent.

11. **The citation is the LAST printed block and never behind a tap.** A 44%-width hairline rule,
    superscript mono marker, serif 12/1.5 in `ink-muted`, small-caps jurisdiction, set below the
    rule table and above the disclaimer — never in an `ExpansionTile`, `Tooltip`, bottom sheet or
    "More info" route. **WHY:** a citation he has to go looking for is not evidence at the counter.

12. **The stamp announces once, category word FIRST.** `MergeSemantics` + `Semantics(header: true)`
    with one label reading category, then measurement, then unit: "Below the minimum. 38 centimetres
    measured, minimum 45, total length." Never three sibling nodes, never the glyph's own label
    (depth: `accessibility-as-code`). **WHY:** three nodes read in three orders is three chances to
    hear the number without the verdict.

## The stamp, struck between double rules

The stamp is the only tilted element on the sheet, and the tilt is what makes it read as struck
rather than laid out. It is drawn in `currentColor`, and the rules are hairlines, not a border box.

```dart
// WRONG — a Card is a dismissable notification; this is a printed judgement.
Card(elevation: 2, child: ListTile(title: Text(signals.headline)));

// RIGHT — struck between double rules, tilted like a hand stamp, no fill and no shadow.
Transform.rotate(
  angle: -0.0096, // -0.55 degrees; the press is never quite square
  child: Padding(
    padding: const EdgeInsets.only(top: 48), // 48dp — plate to stamp
    child: DefaultTextStyle.merge(
      style: TextStyle(color: tone.ink), // currentColor for glyph, rules and text alike
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DoubleRule(),            // 1dp + 1.5dp gap + 1dp
          Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: stampBody),
          const DoubleRule(),
        ],
      ),
    ),
  ),
);
```

Full worked file: `examples/lonja_verdict_panel.dart`.

## Signals: glyph, word, and a third that is not colour

Each category resolves to one record of signals, never a colour looked up here and a glyph there,
which is how the two drift. Protected and below-minimum share oxblood, so their third signal is
structural: protected prints no measurement line at all.

```dart
// WRONG — hue is the whole encoding; greyscale and sunlight erase the verdict.
Text(signals.headline, style: TextStyle(color: category.tint));

// RIGHT — glyph, word and a structural third (does this category print a measurement?) as one value.
const kSignals = <VerdictCategory, VerdictSignals>{
  VerdictCategory.meets: VerdictSignals(Icons.check, 'Meets the minimum', measured: true),
  VerdictCategory.belowMinimum: VerdictSignals(Icons.close, 'Below the minimum', measured: true),
  VerdictCategory.closedSeason:
      VerdictSignals(Icons.event_busy, 'Closed season — 1 March to 30 April', measured: false),
  VerdictCategory.protected:
      VerdictSignals(Icons.block, 'Protected species — taking prohibited', measured: false),
};
// The meta line of each category is fixed in references/states-and-signals.md.
```

Full worked file: `examples/lonja_verdict_panel.dart`.

## The ochre stale bar, under the app bar and blocking nothing

Rule-pack expiry is an axis, not a category: any of the four verdicts can be stale. It is announced
once, in ochre, above the plate, and the verdict below it renders at full strength.

```dart
// WRONG — a modal about data he cannot refresh, in front of the answer he needs in ten seconds.
if (pack.isExpired) {
  showDialog(context: context, builder: (_) => const AlertDialog(title: Text('Rule data expired')));
}

// RIGHT — an ochre bar that states and does not gate.
Container(
  decoration: const BoxDecoration(
    color: Color(0xFFE8E0C6), // ochre-t
    border: Border.symmetric(horizontal: BorderSide(color: Color(0xFF8A6A16))),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  child: Row(children: [
    const Icon(Icons.warning_amber, size: 17, color: Color(0xFF8A6A16)),
    const SizedBox(width: 9),
    Expanded(child: Text('Rule data expired $expiredOn — still shown, verify before relying on it')),
  ]),
);
```

Full worked file: `examples/lonja_verdict_panel.dart`.

## The citation footnote and the fixed disclaimer

The citation is set like a printed footnote: hairline rule, superscript marker, small-caps
jurisdiction, instrument, article, publication date, last-checked date. The disclaimer sits below
it, always, as a `const` child with no flag anywhere near it.

```dart
// WRONG — nullable citation and a flagged disclaimer: an uncited verdict is one refactor away.
class VerdictPanel extends StatelessWidget {
  const VerdictPanel({this.citation, this.showDisclaimer = true, super.key});
  final Citation? citation;
  final bool showDisclaimer;

// RIGHT — required citation, unconditional disclaimer, both in fixed slots.
class VerdictPanel extends StatelessWidget {
  const VerdictPanel({required this.citation, required this.stamp, required this.table, super.key});
  final Citation citation; // instrument, article, publishedOn, checkedOn — all non-null
  final Widget stamp;
  final Widget table;

  @override
  Widget build(BuildContext context) => Column(children: [
        stamp,
        table,
        CitationFootnote(citation: citation), // rule above, LAST printed block
        const LonjaDisclaimer(),              // no if, no Visibility, no dismiss
      ]);
}
```

Full worked file: `examples/lonja_verdict_panel.dart`.

## Sunlight mode: one colour left on the screen

Sunlight is a third theme, not dark mode inverted, and the result screen is where it is most
extreme: every grey gone, every rule black and doubled, and the stamp reversed out as a solid field
so the verdict is the largest coloured area on a white sheet.

```dart
// WRONG — two themes assumed; the greys survive and the stamp stays a hairline in glare.
final ink = Theme.of(context).brightness == Brightness.dark ? paperInk : nightInk;

// RIGHT — three themes; sunlight deletes grey and reverses the stamp out.
StampStyle resolveStamp(LonjaTheme theme, VerdictCategory category) => switch (theme) {
      LonjaTheme.paper || LonjaTheme.night => StampStyle(
          ink: category.semanticInk, // verdant / oxblood / ochre
          ground: null,
          ruleWidth: 1.0,
          tilt: -0.0096),
      LonjaTheme.sunlight => StampStyle(
          ink: const Color(0xFFFFFFFF),
          ground: category.isAdverse
              ? const Color(0xFF8E0F0C) // the single surviving colour
              : const Color(0xFF000000),
          ruleWidth: 0.0,
          tilt: 0.0),
    };
```

Full worked file: `examples/lonja_verdict_panel.dart`.

## Anti-patterns

- **`Card(elevation: 2)` around the verdict** — turns a printed judgement into a notification and
  adds a shadow the Lonja sheet has nowhere else.
- **`Text('Throw it back')` or an ARB value ending "keep it"** — an imperative on the result
  surface; it is advice, advice is liability, and `check_lonja_verdict.sh` fails on it.
- **`Citation? citation`** — the first panel built without one ships an uncited verdict, and nobody
  finds out until an inspector asks.
- **`if (showDisclaimer) const LonjaDisclaimer()`** — a disclaimer behind a flag is a disclaimer a
  hotfix turns off on the exact screen that carries the exposure.
- **`Icon(Icons.error, color: oxblood)` as the entire signal** — a generic glyph plus hue cannot
  separate protected from below-minimum, which are different offences with different penalties.
- **Reusing `Icons.close` for `.protected`** — collapses two legally distinct states into one mark
  the moment the screen is read in greyscale.
- **`showDialog` or a blocking banner for expired rule data** — spends the ten-second budget on
  something he cannot fix offline, and hides the last verified wording he does have.
- **`Colors.red` / `Colors.green` on the stamp, or `harbour` in a verdict cell** — screen-bright RGB
  on a bone sheet, and the accent voting on the law; only the printed semantic inks may state a rule.
- **A `default:` arm in the category switch** — a new category silently renders as the previous one
  instead of failing the build.
- **Recomputing the verdict from `measuredCm` inside `build()`** — the screen and the rule engine
  disagree the day a minimum changes, and only one of them has tests.

## Definition of done

- [ ] `scripts/check_lonja_verdict.sh` is clean over `lib/`.
- [ ] The stamp renders between double rules with no `Card`, `elevation`, `BorderRadius` or
      `BoxShadow` in any theme except the sunlight reversal (rules 1, 10).
- [ ] All four `VerdictCategory` values are switched exhaustively with no `default:` arm, and no
      widget re-derives the category (rule 2).
- [ ] A greyscale screenshot of each of the four results is unambiguous from glyph, headline and the
      structural third alone, and `.protected` differs from `.belowMinimum` in all three (rules 3, 4).
- [ ] The stale bar is ochre, sits under the app bar, and no code path hides, blurs or gates the
      verdict behind it (rule 5).
- [ ] No imperative verdict string exists in `lib/` or in any `app_*.arb` value (rule 6).
- [ ] `Citation` is a required non-null parameter on every verdict widget and is printed with its
      footnote rule above the disclaimer (rules 7, 11).
- [ ] `LonjaDisclaimer` is an unconditional `const` child, and the sunlight golden of the result
      screen contains no grey pixel and exactly one chromatic value (rules 8, 10).

## Related skills

- See `catchlaw-verdict-contract` for the wording itself — sentence grammar, the banned imperative
  lexicon and the statement-of-fact contract this surface only typesets.
- See `catchlaw-rule-engine` for how the category, the shortfall and the closure dates are evaluated
  before they are handed to the panel.
- See `lonja-design-tokens` for the verdant, oxblood, ochre and harbour token values, the three
  themes, glove mode, and the raw-hex gate this skill's colours must go through.
- See `lonja-typography` for the serif, mono and Arabic roles plus the tabular-figure rule the stamp
  sub-line, the rule table and the citation depend on.
- See `lonja-icons-and-plates` for the engraved species plate above the stamp and the verdict glyph
  set the signal matrix draws from.
- See `catchlaw-offline-guarantee` for why an expired rule pack is shown rather than withheld and
  why no sync, cloud or refresh affordance may appear on this screen.
- See `accessibility-as-code` for the never-colour-alone floor, target sizes and text scaling this
  skill's signal matrix is built to satisfy.
- See `i18n-rtl-l10n` for ARB and gen-l10n, bidi isolation of the Arabic verdict strings, and the
  numeral system the mono measurements use.
- See `widget-golden-and-a11y-testing` for the golden lanes — greyscale, sunlight and RTL — that
  prove the signal matrix instead of asserting it.

## References

- Flutter API — `Transform.rotate`: https://api.flutter.dev/flutter/widgets/Transform/Transform.rotate.html
- Flutter API — `BoxDecoration.border`: https://api.flutter.dev/flutter/painting/BoxDecoration/border.html
- Flutter API — `MergeSemantics`: https://api.flutter.dev/flutter/widgets/MergeSemantics-class.html
- Flutter API — `Semantics`: https://api.flutter.dev/flutter/widgets/Semantics-class.html
- Flutter API — `FontFeature.tabularFigures`: https://api.flutter.dev/flutter/dart-ui/FontFeature/FontFeature.tabularFigures.html
- Flutter API — `ThemeExtension`: https://api.flutter.dev/flutter/material/ThemeExtension-class.html
- Dart language — patterns and exhaustive switch: https://dart.dev/language/patterns
- W3C WAI — Use of Color (WCAG 2.2, 1.4.1): https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html
