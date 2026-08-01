# E10/T02 — The verdict panel

| | |
|---|---|
| **Epic** | E10 — The result screen |
| **Branch** | `epic/10-result` (shared) |
| **Commit** | `feat(result): strike the verdict stamp between double rules and announce it once` |
| **Depends on** | T01 (the display model), E07 (`LonjaTokens`, `LonjaType`, three themes) |
| **Size** | L |
| **Spec** | `SPEC.md` §6 S2 "result banner", §5.1 point 1, §4.9 (live region, colour independence, haptics, 200% scale) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-verdict-and-status` | Owns the surface: stamp geometry, the double rules, the four signal sets, the semantics tree, the sunlight reversal, the ban on `Card`/elevation |
| `lonja-typography` | Rules 1–4: every style from `LonjaType.of(context)`, the serif for anything quoting law, mono tabular figures on the sub-line, no `copyWith` beyond colour |
| `catchlaw-verdict-contract` | Rule 1 and rule 6 of `lonja-verdict-and-status` are its lint — the panel renders the sentence T01 built and never composes one |
| `accessibility-as-code` | Rules 2, 5, 6: the glyph is excluded or labelled, no `FittedBox`/ellipsis/clamp to make the headline fit, colour never the only channel |
| `catchlaw-conventions-index` | Invariants 2 and 4, and the routing tie-break that puts result widgets in this feature rather than in `ui/core/` |
| `widget-composition` | Private `const` widget classes in the same file, never `Widget _buildStamp()` |
| `state-management-riverpod` | The panel watches a `select`-narrowed display model so an unchanged verdict does not re-announce |
| `i18n-rtl-l10n` | Rule 5: directional geometry only, so the glyph precedes the headline in reading order under `ar` |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `.claude/skills/lonja-verdict-and-status/references/verdict-anatomy.md` | "The vertical order", "Stamp geometry", "Sunlight reversal", "Semantics tree" | Slot order, 48 dp plate-to-stamp, the `-0.0096` tilt, the double-rule construction, the one-node semantics rule |
| `.claude/skills/lonja-verdict-and-status/references/states-and-signals.md` | "The signal matrix", "Why protected cannot be below-minimum in another shade" | Which glyph, which word and which structural third each category spends |
| `.claude/skills/lonja-verdict-and-status/examples/lonja_verdict_panel.dart` | whole | The worked shape of `_VerdictStamp`, `_DoubleRule` and the signals record — do not diverge from it silently |
| `.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh` | checks 4 and 6 | Why the panel's file must mention `citation`, and why the signals file must carry `Icons.` beside its colours |
| `SPEC.md` | §4.9 | Live region, colour independence, haptics, 200% text scale, 56 dp glove targets |
| `FLUTTER_GUIDE.md` | §8.1 | Why a private `StatelessWidget` and not a helper method — inherited-widget scoping, measured |
| `FLUTTER_GUIDE.md` | §1.2 | The exhaustive allow-list for what a View may contain |
| `epics/CONVENTIONS.md` | §9 invariants 2 and 4 | The two this widget can break without failing a build |

## What this delivers

- `app/lib/ui/result/widgets/result_verdict_panel.dart` — `ResultVerdictPanel`, taking a
  `VerdictStampDisplay` and a required non-nullable `CitationDisplay`, with private `_VerdictStamp`
  and `_DoubleRule` in the same file.
- `app/lib/ui/result/widgets/result_verdict_signals.dart` — `kVerdictSignals`, a
  `Map<VerdictCategory, VerdictSignals>` holding glyph, semantic-ink token and the `measured` flag
  as one value per category, so glyph and colour cannot drift apart.
- `app/lib/ui/result/widgets/result_haptics.dart` — `ResultHaptics.announce(VerdictCategory)`.
- `app/lib/ui/result/widgets/result_section.dart` — the fixed vertical order of the result half of
  S2, mounted into E08's `SpeciesDetailScreen` at its empty slot. Later tasks fill its remaining
  slots; this task lands it with the stamp, a placeholder-free structure and the T09 slot reserved.
- `app/test/ui/result/result_verdict_panel_test.dart`,
  `app/test/ui/result/result_verdict_panel_semantics_test.dart`,
  `app/test/ui/result/result_haptics_test.dart`.

## Why it is built this way

**A verdict is a printed judgement, not a notification.** `lonja-verdict-and-status` rule 1 bans
`Card`, `elevation`, `BorderRadius`, `BoxShadow` and any fill outside the sunlight reversal, and
`check_lonja_dialogs.sh` check 5 enforces exactly that on any file matching `*_panel.dart` — which
this file does, deliberately. A card reads as something the reader may swipe away; this screen is a
judgement already printed against a published instrument.

**The panel never re-derives the category.** It receives `VerdictStampDisplay` from T01 and switches
over `VerdictCategory` exhaustively with no `default:` arm. A `default:` would render a future
category as the previous one instead of failing the build, and re-deriving from `measuredCm` inside
`build()` puts a second, untested copy of the law on the screen — the day a minimum changes, the
screen and the engine disagree and only one of them has tests.

**Three signals, and none of them may be hue.** Protected and below-minimum both print in oxblood
`#7A2320`, so colour carries zero information between them. They are separated by `Icons.block`
against `Icons.close`, by the headline words, and structurally: protected prints no measurement
sub-line at all. A reader who takes only the colour otherwise reads "too small" and reaches for a
bigger one of the same protected species. The signals live in one record per category rather than a
colour map here and a glyph map there, because two maps drift.

**One semantics node, category word first.** §4.9 requires the result announced as a live region.
`MergeSemantics` + `Semantics(header: true, liveRegion: true, label: …)` produces one node reading
category, then measurement, then unit; the glyph is `ExcludeSemantics` because it repeats the
headline. Three sibling nodes would be read in three orders — three chances to hear "38 centimetres"
without hearing "below the minimum".

**The live region is narrowed, not removed.** `liveRegion: true` re-announces whenever the node
updates, and E09's ruler emits several times a second. The panel therefore watches
`resultDisplayProvider.select((d) => d.stamp)`, so an unchanged stamp produces no rebuild and no
re-announcement. Removing the live region to stop the chatter would break §4.9 outright.

**Haptics.** §4.9 requires "distinct patterns for pass and fail" and gives no numbers, so the pattern
is fixed here: `.meets` fires one `HapticFeedback.lightImpact()`; every adverse category fires
`HapticFeedback.heavyImpact()` twice separated by 120 ms. The distinction is count and weight, not
duration, because a single long buzz is indistinguishable from a notification through a glove. This
is a design choice, not a measurement — it is in the epic's Risks, and E19 owns confirming it on a
device.

**Rejected — `Widget _buildStamp()`.** `FLUTTER_GUIDE.md` §8.1 measured it: a helper method uses the
caller's `BuildContext`, so `LonjaType.of(context)` and `AppLocalizations.of(context)` register the
*parent* element as the dependent and the whole screen rebuilds on a locale change. With six locales
and an RTL flip that is not academic.

**Rejected — putting the panel in `app/lib/ui/core/ui/`.** The routing table makes `lib/ui/core/`
the home of shared Lonja widgets, and exactly one screen renders a verdict. Lifting it now is
speculative generality that `/simplify` should flag; `StaleRuleBar` is the one piece with a second
consumer on the horizon (S13, E15) and it moves when that consumer exists, not before.

**Rejected — `MediaQuery.withClampedTextScaling` around the headline.** `accessibility-as-code`
rule 4 bans it and rule 5 bans `FittedBox` and `TextOverflow.ellipsis` for fit. The headline steps
from 26 to 21 when it wraps to two lines, per `verdict-anatomy.md`, and the page scrolls.

## Tests first

Write every row before touching `result_verdict_panel.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ResultVerdictPanel renders the glyph, the headline and the meta line for VerdictCategory.meets` | meets display | `Icons.check`, headline text, meta text all found | The baseline: three signals present, not one |
| 2 | `ResultVerdictPanel renders Icons.block for VerdictCategory.protected` | protected | `Icons.block` found, `Icons.close` absent | Reusing `close` collapses two legally distinct offences into one mark |
| 3 | `ResultVerdictPanel omits the measurement sub-line for VerdictCategory.protected` | protected, sub-line supplied | sub-line text not found | The structural third signal; a measurement implies a threshold that does not exist |
| 4 | `ResultVerdictPanel omits the measurement sub-line for VerdictCategory.closedSeason` | closed season | sub-line text not found | A closure applies to all sizes |
| 5 | `ResultVerdictPanel renders the measurement sub-line for VerdictCategory.belowMinimum` | below minimum | `38 cm measured · minimum 45 cm · total length` found | Without the number the app published a conclusion instead of quoting a rule |
| 6 | `ResultVerdictPanel distinguishes protected from belowMinimum by glyph and sub-line` | both, compared | glyph differs and sub-line presence differs | The greyscale-survivability property, asserted structurally until E19's golden |
| 7 | `ResultVerdictPanel announces the verdict as a live region` | any | exactly one node with `liveRegion: true` in the stamp subtree | §4.9's screen-reader requirement, stated as a testable fact |
| 8 | `ResultVerdictPanel announces the category before the measurement` | below minimum | the merged label index of the category word < index of the number | Three orders of reading is three chances to hear the number without the verdict |
| 9 | `ResultVerdictPanel excludes the glyph from the semantics tree` | any | no semantics node labels the icon | The glyph repeats the headline; two nodes read it twice |
| 10 | `ResultVerdictPanel emits one semantics update when rebuilt with an identical display` | pump twice, same model | the semantics label is announced once | The ruler-driven re-announcement hazard named in the epic Risks |
| 11 | `ResultVerdictPanel contains no Card, elevation or BoxShadow in the paper theme` | any | no `Card`, no `Material` with elevation > 0, no `BoxShadow` in the subtree | A shadow turns a printed judgement into a dismissable overlay |
| 12 | `ResultVerdictPanel tilts the stamp by -0.0096 radians` | any | the `Transform` matrix matches the fixed tilt | The tilt is what makes it read as struck rather than laid out; a drifted value is invisible in review |
| 13 | `ResultVerdictPanel strikes a double rule above and below the stamp body` | any | two `_DoubleRule` instances found | The double rules are the frame; losing one leaves a hanging line |
| 14 | `sunlight - ResultVerdictPanel reverses the stamp out with no tilt` | sunlight theme, adverse | tilt 0, solid ground, white ink | At 05:40 in direct sun a hairline stamp is absent, not dim |
| 15 | `sunlight - ResultVerdictPanel renders no grey in the stamp subtree` | sunlight theme | every resolved colour is black, white or the single adverse chroma | Sunlight deletes every grey; a surviving `ink-muted` is unreadable |
| 16 | `RTL - ResultVerdictPanel places the glyph at the start edge` | locale `ar` | glyph rect start < headline rect start under RTL | Physical `left` padding compiles and silently breaks in the one locale that is the moat |
| 17 | `ar - ResultVerdictPanel renders the Arabic headline without truncation` | locale `ar`, long headline | no `TextOverflow.ellipsis`, no `FittedBox`, text wraps | Truncating a verdict removes the half that carries the threshold |
| 18 | `ResultVerdictPanel survives a 200% text scale with no overflow` | `textScaler: 2.0`, 5-inch viewport | no overflow exception | §4.9's stated target, and the failure mode a clamp would hide |
| 19 | `ResultHaptics.announce fires one light impact for VerdictCategory.meets` | meets | one `HapticFeedback.lightImpact` platform call | "Usable without looking" needs a pass pattern that is not the fail pattern |
| 20 | `ResultHaptics.announce fires two heavy impacts for an adverse category` | below minimum | two `HapticFeedback.heavyImpact` platform calls | Count and weight are the distinction; duration is not felt through a glove |
| 21 | `ResultHaptics.announce fires nothing when the display carries no stamp` | `NoRuleFound` | no platform call | A buzz for "no rule recorded" would read as a verdict |
| 22 | `ResultVerdictPanel requires a non-nullable citation` | compile-time | `CitationDisplay` is a required positional field | `check_lonja_verdict.sh` check 4, and invariant 3 |

```dart
// app/test/ui/result/result_verdict_panel_semantics_test.dart
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_verdict_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../harness.dart';

void main() {
  group('ResultVerdictPanel', () {
    testWidgets('announces the verdict as a live region', (tester) async {
      await tester.pumpApp(ResultVerdictPanel(
        stamp: kStampBelowMinimum,
        citation: kCitationDisplayMd580,
      ));

      final handle = tester.ensureSemantics();
      final live = find.bySemanticsLabel(RegExp('Below the minimum'));
      expect(tester.getSemantics(live).hasFlag(SemanticsFlag.isLiveRegion), isTrue);
      handle.dispose();
    });

    testWidgets('announces the category before the measurement', (tester) async {
      await tester.pumpApp(ResultVerdictPanel(
        stamp: kStampBelowMinimum,
        citation: kCitationDisplayMd580,
      ));

      final handle = tester.ensureSemantics();
      final label = tester.getSemantics(find.byType(ResultVerdictPanel)).label;
      expect(label.indexOf('Below the minimum'), lessThan(label.indexOf('38')));
      handle.dispose();
    });

    testWidgets('omits the measurement sub-line for VerdictCategory.protected', (tester) async {
      await tester.pumpApp(ResultVerdictPanel(
        stamp: kStampProtected,
        citation: kCitationDisplayMd580,
      ));

      expect(find.textContaining('measured'), findsNothing);
      expect(find.byIcon(Icons.block), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    // … one test per row above, one behaviour each
  });
}
```

```dart
// app/test/ui/result/result_haptics_test.dart — the platform-channel capture
void main() {
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add(call);
      return null;
    });
  });

  test('ResultHaptics.announce fires two heavy impacts for an adverse category', () async {
    await ResultHaptics.announce(VerdictCategory.belowMinimum);
    expect(calls.map((c) => c.arguments), <String>[
      'HapticFeedbackType.heavyImpact',
      'HapticFeedbackType.heavyImpact',
    ]);
  });
}
```

**Run:** `cd app && flutter test test/ui/result/` → 22 failures. If any passes now, the test is
wrong.

## Implementation outline

1. `result_verdict_signals.dart`: one `VerdictSignals` record per category — glyph, semantic-ink
   token name, `measured` flag. The file carries `Icons.` and the token lookups together, which is
   what `check_lonja_verdict.sh` check 6 tests for.
2. `result_verdict_panel.dart`: `ResultVerdictPanel({required this.stamp, required this.citation})`.
   `build()` resolves `LonjaType.of(context)` and `LonjaColors.of(context)` once and delegates to
   private `const`-able widget classes.
3. `_VerdictStamp`: `MergeSemantics` → `Semantics(header: true, liveRegion: true, label: …)` →
   `Padding(EdgeInsetsDirectional.fromSTEB(16, 48, 16, 0))` → `Transform.rotate(angle: -0.0096)` →
   `DefaultTextStyle.merge(style: TextStyle(color: ink))` → `Column` of `_DoubleRule`, the glyph row,
   the optional sub-line, the meta line, `_DoubleRule`.
4. `_DoubleRule`: 1 dp line, 1.5 dp gap, 1 dp line, drawn in the inherited colour so it cannot drift
   from the glyph.
5. Resolve the stamp style by theme: paper and night keep hairlines and the tilt; sunlight takes a
   solid ground, white ink, zero tilt and no borders. Switch over the three themes exhaustively.
6. `result_haptics.dart`: a static method returning `Future<void>`, awaited by the caller;
   `unawaited` is not used, and it is called from a `ref.listen` on the stamp, never from `build()`.
7. `result_section.dart`: the fixed vertical order from `verdict-anatomy.md` — stale bar slot, plate
   (E08), stamp, table slot, diagram slot, citation slot, disclaimer slot. Slots that later tasks
   fill are omitted from the tree in this commit rather than stubbed, so nothing renders a
   placeholder to a user.
8. Mount `ResultSection` in E08's `SpeciesDetailScreen`. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 22 tests pass, and each failed first.
- [ ] The `VerdictCategory` switch has no `default:` arm and no nullable category anywhere.
- [ ] No `TextStyle(`, `fontSize:` or `fontFamily:` literal in `app/lib/ui/result/`.
- [ ] `check_lonja_verdict.sh app/lib`, `check_lonja_type.sh app/lib` and
      `check_lonja_dialogs.sh app/lib` are clean.
- [ ] No `EdgeInsets.only(left:` or `right:` in the feature — `no_directional_geometry.sh` clean (D-8).
- [ ] Every `Icon` in the feature is either `ExcludeSemantics`-wrapped or carries a `semanticLabel`.
- [ ] The panel takes a required non-nullable `CitationDisplay` and its file mentions `citation`.
- [ ] Nothing in the panel calls `HapticFeedback` from `build()`.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh      app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh    app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
tools/gates/no_directional_geometry.sh                                      app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(result): strike the verdict stamp between double rules and announce it once

The stamp is drawn as printed matter — double rules, a -0.55 degree tilt,
no Card, no elevation, no fill outside the sunlight reversal — because a
card reads as a notification the reader may dismiss and this screen is a
judgement already printed against a published instrument.

Protected and below-minimum share oxblood, so hue separates nothing between
them: Icons.block against Icons.close, different headlines, and protected
prints no measurement sub-line at all. The whole stamp is one merged
semantics node with liveRegion set, category word first, and the panel
watches a select-narrowed model so an unchanged verdict does not
re-announce while the ruler is moving.

Task: E10/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
