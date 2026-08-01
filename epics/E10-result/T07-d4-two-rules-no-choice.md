# E10/T07 — D4 — two rules, and no choice between them

| | |
|---|---|
| **Epic** | E10 — The result screen |
| **Branch** | `epic/10-result` (shared) |
| **Commit** | `feat(result): print both rules when two are equally specific` |
| **Depends on** | T01 (`AmbiguityDisplay`), T05 (the citation each rule carries) |
| **Size** | M |
| **Spec** | `SPEC.md` §5.1 point 3, §4.1 "Ambiguity handling", §7.3 step 4, §6 dialogs D4 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-dialogs-and-surfaces` | Owns the shell: `barrierDismissible: false`, a typed result, equal-weight actions, focus capture and restore, no elevation or radius |
| `catchlaw-verdict-contract` | Rule 6 — ambiguity is shown in full and never resolved; no `reduce`, no `sort`, no "strictest wins", no `.first` |
| `catchlaw-rule-engine` | Rule 6 and the tie matrix — what makes two rules a genuine tie, and that expiry is not a tie-breaker |
| `lonja-verdict-and-status` | Why no stamp is struck for an ambiguity, and that both citations are printed |
| `accessibility-as-code` | Rules 1, 8, 9: every action labelled, ≥ 44 dp, traversal order authored rather than inherited |
| `catchlaw-conventions-index` | Invariant 2 and 3 — both statements are facts, and each carries its own citation |
| `i18n-rtl-l10n` | Directional barrier insets and an action row that reverses itself under `ar` rather than being hand-swapped |
| `async-safety` | The `mounted` guard after `await showDialog`, and never dropping the returned future |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §5.1 point 3 | "It refuses to resolve genuine legal ambiguity… An advice product would pick one" |
| `SPEC.md` | §4.1 "Ambiguity handling" | The acceptance condition: never silently reports the more permissive rule |
| `SPEC.md` | §7.3 step 4 | Equal specificity plus disagreement returns both and renders D4 |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "The tie matrix" | The five tie rows, including "equal specificity, one expired → `Ambiguous`" |
| `.claude/skills/lonja-dialogs-and-surfaces/references/modal-decision-matrix.md` | §3, §4, §6, §7 | Barrier policy, focus capture and return, typed results, and the ambiguity presentation contract |
| `.claude/skills/lonja-dialogs-and-surfaces/examples/lonja_ambiguity_dialog.dart` | whole | The worked shell: `showDialog<AmbiguityChoice>`, the sealed result, `EqualAction`, the `null` tear-down case |
| `.claude/skills/lonja-dialogs-and-surfaces/references/surfaces-and-plates.md` | §1, §2, §3 | Zero elevation, zero radius, rule weights, the flat barrier wash per theme |
| `.claude/skills/catchlaw-verdict-contract/references/the-five-part-carve-out.md` | Part 3 | The banned resolutions, all of which are advice, and the testable assertion |
| `.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh` | checks 1–5 | Why the file must be named `*_dialog.dart`, and the banned button literals |

## What this delivers

- `app/lib/ui/result/widgets/result_ambiguity_dialog.dart` — `showResultAmbiguityDialog`,
  `ResultAmbiguityDialog`, and the sealed `AmbiguityChoice` with `AppliedInstrument` and
  `DeferredToBoth`. Both rules printed as equal-weight plates in source order, each with its full
  citation; `barrierDismissible: false`; focus captured and restored.
- `app/lib/ui/result/widgets/result_ambiguity_block.dart` — the inline both-rules block on the
  result surface, rendered in the slot where the stamp would otherwise be struck.
- `app/test/ui/result/result_ambiguity_dialog_test.dart`,
  `app/test/ui/result/result_ambiguity_block_test.dart`.

## Why it is built this way

**The refusal is one of the five arguments for the carve-out.** §5.1 point 3 lists it beside the
statement-of-fact wording and the citation: "It refuses to resolve genuine legal ambiguity. Where two
equally specific rules apply, D4 shows both. An advice product would pick one." Choosing between two
live instruments is the advisory act — and picking the stricter one is still picking. §4.1's
acceptance condition is stated as a negative for the same reason: *never silently reports the more
permissive rule*.

**No stamp is struck.** A stamp states one category, and there is no one category here. The
ambiguity block takes the stamp's slot and prints "Two rules of equal standing apply here." followed
by both statements, each with its own citation footnote marker. Striking a stamp for either rule
would be the silent pick the spec forbids, dressed as layout.

**Source order, and no ranking anywhere in the app.** The engine returns `Ambiguous(rules: [...])`
with the rows in the order they came out of the resolution pipeline. The display does not sort, does
not put the stricter first, does not put the non-expired first, and does not mark one "recommended".
The test that proves it feeds rules whose minima are 40 mm then 38 mm — descending — so any
"helpful" sort would visibly reorder them.

**Expiry does not break the tie.** The tie matrix is explicit: equal specificity, outcomes differ,
one expired → `Ambiguous(both)`. So the block can carry the stale bar from T06 above it and still
print two rules, one of which is stale. That combination is a test row, because it is the case where
a developer is most tempted to let the fresh rule win.

**A modal here is earned; almost nothing else on this screen is.** `modal-decision-matrix.md` §2
lists "Two equally specific rules apply" as one of the four surfaces that genuinely block, with
`barrierDismissible: false` and an `AmbiguityChoice` result. The user cannot usefully proceed without
deciding which instrument he is going to work to — but the app records that decision without
endorsing it, and `DeferredToBoth` is a first-class outcome rather than a cancel.

**A typed result, because `bool?` loses a case.** Three outcomes — applied instrument A, applied
instrument B, deferred — plus the `null` of a route tear-down. `bool?` collapses them into two and a
null the caller treats as "no", and on this screen "no" would silently mean "use whichever rule the
layout happened to put first".

**Rejected — `candidates.reduce((a, b) => a.minLengthCm > b.minLengthCm ? a : b)`.** Named as an
anti-pattern in three skills. "We chose the stricter one" is still choosing, and it produces a
verdict no instrument supports.

**Rejected — a "recommended" badge, an autofocused primary action, or a colour difference between
the two plates.** `modal-decision-matrix.md` §7: no default, no `autofocus` on either instrument
action, no colour distinction. The presentation must not leak a preference the wording refuses to
state.

**Rejected — rendering one rule with an "another rule may apply" footnote.** Listed among the banned
resolutions in `the-five-part-carve-out.md` Part 3. It is the silent pick with a disclaimer attached.

**Rejected — `barrierDismissible: true`.** A stray wet-hand tap outside would resolve a question with
legal weight, and the caller could not distinguish it from a deliberate decline.

## Tests first

Write every row before touching `result_ambiguity_dialog.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ResultAmbiguityBlock prints both rule statements` | 2 rules | both sentences on screen | §7.3 step 4; the baseline of the whole task |
| 2 | `ResultAmbiguityBlock prints a citation for each rule` | 2 rules, 2 citations | both instruments and both articles found | Each statement is a quotation and needs its own source |
| 3 | `ResultAmbiguityBlock preserves source order when the minima descend` | minima `[40 mm, 38 mm]` | rendered in that order | Any sort would visibly reorder these; the test is designed to catch one |
| 4 | `ResultAmbiguityBlock strikes no verdict stamp` | ambiguous display | no `ResultVerdictPanel` in the tree | A stamp states one category, and there is no one category here |
| 5 | `ResultAmbiguityBlock renders both rules when one of them is expired` | one rival expired | both statements present, the bar above | Expiry is not a tie-breaker — the tempting shortcut, named in the tie matrix |
| 6 | `ResultAmbiguityBlock renders the same visual weight for both rules` | 2 rules | identical text styles and identical plate decorations | A weight difference is a recommendation the wording refuses to make |
| 7 | `ResultAmbiguityDialog sets barrierDismissible to false` | open | the dialog route's `barrierDismissible` is false | A stray barrier tap must not resolve a legally weighted question |
| 8 | `ResultAmbiguityDialog returns AppliedInstrument with the tapped instrument id` | tap action 2 | `AppliedInstrument('rak-local-2019-art7')` | The typed contract, and the id the caller acts on |
| 9 | `ResultAmbiguityDialog returns DeferredToBoth from the third action` | tap defer | `DeferredToBoth()` | Deferring is a first-class outcome, not a cancel |
| 10 | `ResultAmbiguityDialog writes nothing when it is torn down` | pop the route | no state change, no repository call | `bool?`'s null path is where a destructive default hides |
| 11 | `ResultAmbiguityDialog autofocuses neither instrument action` | open | no action has `autofocus: true` | An autofocused action is a default, and a default is a recommendation |
| 12 | `ResultAmbiguityDialog offers exactly N+1 equal-weight actions for N rules` | 2 rules | 3 actions, none styled as primary | The presentation contract in `modal-decision-matrix.md` §7 |
| 13 | `ResultAmbiguityDialog restores focus to the opener after it pops` | open, choose, close | the pre-open focus node holds focus again | Without the restore, TalkBack drops the cursor to the top of the route |
| 14 | `ResultAmbiguityDialog contains no OK, Cancel, Yes or No literal` | open | none of the four labels present | Every label names its own effect, or it is confirmed by reflex |
| 15 | `ResultAmbiguityDialog renders with zero elevation and zero radius` | open | no `BoxShadow`, no `BorderRadius.circular`, `elevation: 0` | A shadow claims the surface floats; the Lonja document is printed and flat |
| 16 | `ResultAmbiguityDialog states a fact in its title` | open | title is "Two rules of equal standing apply here." | Not a question, not "Which rule applies?" — the app does not ask him to adjudicate |
| 17 | `ResultSection leaves both rules on screen after DeferredToBoth` | defer | the inline block is unchanged | Deferring means both stay visible, not that the dialog was dismissed |
| 18 | `ResultSection marks the chosen instrument without hiding the other` | apply instrument A | A is marked as applied; B is still printed with its citation | Applying a rule for the reader's own working purposes is not the app resolving the conflict |
| 19 | `RTL - ResultAmbiguityDialog reverses the action row` | locale `ar` | actions laid out from the start edge | Hand-swapping children by locale is the bug this test forbids |
| 20 | `ResultAmbiguityDialog keeps every action at least 56 dp in glove mode` | glove on | every action height ≥ 56 | §4.9's glove floor on a surface tapped with wet hands |

```dart
// app/test/ui/result/result_ambiguity_dialog_test.dart
import 'package:catchlaw/ui/result/widgets/result_ambiguity_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../harness.dart';

void main() {
  group('ResultAmbiguityDialog', () {
    testWidgets('sets barrierDismissible to false', (tester) async {
      await tester.pumpApp(const _Opener());
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final route = ModalRoute.of(tester.element(find.byType(ResultAmbiguityDialog)))!;
      expect(route.barrierDismissible, isFalse);
    });

    testWidgets('offers exactly N+1 equal-weight actions for N rules', (tester) async {
      await tester.pumpApp(const ResultAmbiguityDialog(candidates: kAmbiguousPairCambados));

      final actions = tester.widgetList<OutlinedButton>(find.byType(OutlinedButton)).toList();
      expect(actions, hasLength(3));
      expect(actions.map((a) => a.style).toSet(), hasLength(1)); // no primary
      expect(find.byWidgetPredicate((w) => w is Focus && w.autofocus), findsNothing);
    });

    testWidgets('renders both rules when one of them is expired', (tester) async {
      await tester.pumpApp(const ResultAmbiguityDialog(candidates: kAmbiguousPairOneExpired));

      expect(find.textContaining('minimum 38 mm'), findsOneWidget);
      expect(find.textContaining('minimum 40 mm'), findsOneWidget);
    });

    testWidgets('preserves source order when the minima descend', (tester) async {
      await tester.pumpApp(const ResultAmbiguityDialog(candidates: kAmbiguousPairDescending));

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      expect(texts.indexWhere((s) => s.contains('40 mm')),
          lessThan(texts.indexWhere((s) => s.contains('38 mm'))));
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/ui/result/` → 20 new failures. If any passes now, the test is
wrong.

## Implementation outline

1. `result_ambiguity_dialog.dart` — the filename matters: `check_lonja_dialogs.sh` check 1 only
   permits `showDialog` inside `/core/` or a `*_dialog.dart`.
2. Declare `sealed class AmbiguityChoice` with `final class AppliedInstrument` (carrying the
   instrument id) and `final class DeferredToBoth`. No `bool` anywhere.
3. `showResultAmbiguityDialog`: capture `FocusManager.instance.primaryFocus`, call
   `showDialog<AmbiguityChoice>` with `barrierDismissible: false` and a flat barrier wash from the
   theme, then `opener?.requestFocus()` after the await, guarded by `if (!context.mounted) return;`.
4. `ResultAmbiguityDialog`: `Dialog(elevation: 0, surfaceTintColor: Colors.transparent, shape:
   RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: …))`, a `FocusScope`, the title, one
   ruled plate per candidate in source order, then N+1 identical outlined actions. No `autofocus`
   anywhere; no action styled differently from another.
5. `result_ambiguity_block.dart`: the inline surface. It renders in the stamp's slot, prints the same
   title, both statements and both citation markers, and offers a single labelled target that opens
   the dialog. When a choice has been applied, the applied rule is marked and the other stays
   printed in full.
6. Wire `ResultSection` so `AmbiguityDisplay != null` selects the block instead of the stamp, and so
   the dialog's result updates only the block's "applied" marker — never the set of rules shown.
7. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 tests pass, and each failed first.
- [ ] `grep -rn "reduce\|sort\|firstWhere" app/lib/ui/result` finds nothing that touches an ambiguity
      rule list.
- [ ] No `showDialog<bool>` and no `Navigator.pop(context, true/false)` anywhere in the feature.
- [ ] `barrierDismissible: false` is passed explicitly, never left to the Flutter default.
- [ ] No `OK`, `Cancel`, `Yes`, `No`, `Confirm` or `Dismiss` literal in any `*_dialog.dart` or ARB.
- [ ] Both rules are printed with identical styles and identical plate decoration.
- [ ] `check_lonja_dialogs.sh app/lib` and `check_verdict_contract.sh app/lib` are clean.
- [ ] Focus returns to the opener, verified by the test and once by hand under TalkBack.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh    app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh      app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
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
feat(result): print both rules when two are equally specific

SPEC §5.1 point 3 makes the refusal one of the five arguments that keep
this a reference tool: an advice product picks one, and picking the
stricter is still picking. So no stamp is struck for an ambiguity — a
stamp states one category and there is no one category — and the block
takes its slot, printing both statements in source order with both
citations at identical weight.

The dialog returns a sealed AmbiguityChoice rather than a bool, because
bool? collapses applied-A, applied-B and deferred into two values and a
null the caller reads as "no", which on this screen would silently mean
"use whichever rule the layout put first". Expiry does not break the tie.

Task: E10/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
