# E07/T07 — The button variant ladder, and the confirm that cannot be skipped

| | |
|---|---|
| **Epic** | E07 — Lonja design system foundation |
| **Branch** | `epic/07-lonja-theme` (shared) |
| **Commit** | `feat(theme): add the primary, secondary and destructive button rungs and the typed confirm` |
| **Depends on** | T04 (targets come from the density set), T05 (labels take a ramp step), T06 (the confirm is built on a ruled surface) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.9 (glove mode: all primary targets ≥ 56 dp with ≥ 8 dp separation; colour independence), §13 (targets ≥ 48 dp, ≥ 56 dp glove), §5.1 (the legal-advice carve-out — why no control ever instructs the fisher) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-buttons` | Owns the ladder, the six-state matrix, the two slots, label wording and the destructive hand-off. Rules 1–12 are this task's specification |
| `lonja-dialogs-and-surfaces` | Owns the confirmation surface: barrier policy, the typed result, focus capture and restore, and rule 3 — a confirm label names its consequence |
| `lonja-design-tokens` | Owns every value the style resolves: the slots, the four rule weights, the radius ceiling, the density targets. The button widget contains zero hex |
| `lonja-typography` | Owns the label step: sans `ui` at standard density, `uiLarge` in glove mode, and the rule that a measurement inside a label is set in mono with tabular figures |
| `catchlaw-verdict-contract` | Owns the banned lexicon. A label that instructs the fisher about the fish is a legal exposure, not a copy nit |
| `accessibility-as-code` | Owns the tap-target floor these clear, `Semantics(button: true)`, and the never-colour-alone rule the ladder's non-colour grading satisfies |
| `async-safety` | Owns the dropped-`Future` half of the busy latch: `onPressed: () => vm.record(fish)` discards the future and skips the guard |
| `widget-composition` | `LonjaButton` is a widget class; the style is a function returning a `ButtonStyle`, not a widget-returning helper |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `.claude/skills/lonja-buttons/references/variant-ladder-and-states.md` | "The ladder", "Deciding the rung" | What earns each rung, and the per-screen maxima: one primary, one destructive |
| `.claude/skills/lonja-buttons/references/variant-ladder-and-states.md` | "The six-state matrix", "Theme resolution", "Disabled", "Busy" | Every cell: field, rule and label per state; the sunlight stress test; the disabled reason as part of the state; the busy latch |
| `.claude/skills/lonja-buttons/references/button-anatomy.md` | "The printed box", "The two slots", "Label wording" | Geometry, the leading-glyph-and-label slot pair, the banned-label table and the approved corpus |
| `.claude/skills/lonja-buttons/SKILL.md` | Rules 1–12 | One primary per screen; a verb phrase naming the consequence; never an instruction about the fish; no elevation or ripple; hierarchy is field plus rule weight, never colour alone; the busy latch; destructive always confirms |
| `.claude/skills/lonja-buttons/examples/lonja_buttons.dart` | whole file | The worked shape: `TextButton` as the *unstyled base* with every pixel authored in the `ButtonStyle`, and the `resolveWith` blocks for side and overlay. Its `Color` constants, its 66 dp and its 1.5 dp stand in for tokens — the header says so |
| `.claude/skills/lonja-buttons/examples/result_actions.dart` | whole file | The latched handler, the disabled reason as adjacent prose, and the destructive hand-off. **Do not copy its `icon: Icons.check`** — `lonja-icons-and-plates` rule 1 bans the Material family outright |
| `.claude/skills/lonja-dialogs-and-surfaces/references/modal-decision-matrix.md` | §1–§6 | The single question; the barrier table (`false` for every class, back → `dismissed`); focus capture and return, including **never autofocus the destructive action**; the destructive label table; and typed results, where a `null` result never falls through to a write |
| `.claude/skills/lonja-dialogs-and-surfaces/SKILL.md` | Rules 2, 3, 4, 7, 12 | Typed results never `bool`; the confirm names its consequence; `barrierDismissible: false`; focus restored to the opener; no spinner over a barrier |
| `.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh` | Checks 1–7 | Where a raw Material button is legal (`/(theme|ui/core)/`), the one-primary-per-file count, the icon-label check, the two label greps, and the ban on `FloatingActionButton` and `CircularProgressIndicator` **anywhere** in the target |
| `.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh` | Checks 1, 4, 5, 6, 7, 10 | Why the `ButtonStyle` lives under `lib/theme/`: `Colors.transparent`, `RoundedRectangleBorder`, numeric `EdgeInsets`, literal stroke widths, `fontSize:` and literal `Duration(` are all illegal outside `/theme/` |
| `epics/DECISIONS.md` | D-2 | The `/theme/` path fragment is what makes that split work |

## What this delivers

- `app/lib/theme/lonja_button_style.dart` — `LonjaButtonStyles.resolve({required LonjaTokens
  tokens, required LonjaTypeScale type, required LonjaButtonVariant variant})`, returning a
  `ButtonStyle` whose every cell is a `WidgetStateProperty`: background, foreground, side, overlay,
  `elevation: WidgetStatePropertyAll(0)`, transparent `shadowColor`, square
  `RoundedRectangleBorder`, `minimumSize: Size.fromHeight(tokens.density.tapMin)`, horizontal
  padding `LonjaSpace.s4`, `splashFactory: NoSplash.splashFactory`, and the label step.
- `app/lib/ui/core/ui/lonja_button.dart` — `enum LonjaButtonVariant { primary, secondary,
  destructive }` and `LonjaButton` with three named constructors. `label` arrives already
  localised. A `leading` `Widget?` slot exists and stays empty until the icon family lands. The
  busy latch, the disabled reason and the destructive hand-off live here.
- `app/lib/ui/core/ui/lonja_confirm_dialog.dart` — `enum LonjaConfirmOutcome { confirmed, declined,
  dismissed }` and `Future<LonjaConfirmOutcome> showLonjaConfirm(BuildContext context, {required
  String title, required String body, required String confirmLabel, required String cancelLabel})`:
  `barrierDismissible: false`, a `LonjaPanel` shell, focus captured before opening and restored
  after popping, and a typed result in which a system-back pop is `dismissed` and not `declined`.
- `app/test/ui/core/lonja_button_test.dart`, `lonja_button_states_test.dart`,
  `lonja_confirm_dialog_test.dart`.

**Not** delivered here: the `quiet` and `link` rungs, `LonjaIconButton`, and the 250 ms busy-rule
deferral. See "Why it is built this way".

## Why it is built this way

**The style lives in `lib/theme/` and the widget in `lib/ui/core/ui/`, and the gates decide that
split.** `check_lonja_tokens.sh` fails `RoundedRectangleBorder` (check 4), a numeric `EdgeInsets`
(check 5), a literal stroke width (check 6), `fontSize:` (check 7) and `Colors.transparent` (check 1)
anywhere outside `/theme/` — and a `ButtonStyle` is made of exactly those constructs.
`check_lonja_buttons.sh` check 1 allows a raw Material button constructor in both `/theme/` and
`/ui/core/`. So the values and the shapes are authored in the theme, and the widget is a thin thing
that names a variant. That is D-2's rule of thumb again: where prose and an executable gate disagree
about a path, the gate wins.

**Targets come from `LonjaTokens.density`, at 48 dp and 56 dp.** `SPEC.md` §13 states the product
floor as "≥ 48 dp (≥ 56 dp glove mode)" and §4.9 restates 56 dp with 8 dp of separation.
`lonja-buttons/references/button-anatomy.md` publishes a different set — 56 / 46 / 66 with 12 dp gaps
— which is over-provision above the same floor. This epic takes the density set, because
`lonja-design-tokens` owns values, its own worked example binds a button to `t.density.tapMin`, and a
button that reads the token cannot drift from the rows, panels and chips that read the same token.
The unreconciled numbers are recorded in the epic's risk 1; they are not re-argued here.

**The rungs are graded by field, outline and rule weight — never by hue.** Primary is the only
*filled* box at `LonjaRules.rule`; secondary is the only *outlined* box; destructive is filled and
framed at `LonjaRules.strong`. That grading survives the two places hue does not: sunlight, where
`accent` collapses to `black00` and only the verdict pigments keep a colour, and greyscale, where the
primary field (`harbour30`, L\* 30.28) and the destructive field (`oxblood28`, L\* 27.96) are **2.3
L\* apart** — visually the same box. T08's greyscale lane is the proof; this task's job is to give it
something to prove. Framing the destructive rung at `strong` rather than at `stamp` (3.0) keeps the
verdict's stamp weight reserved, per `token-tables.md`.

**A destructive button cannot be built without its confirmation.** `LonjaButton.destructive` takes
the confirmation copy as required parameters and opens `showLonjaConfirm` itself; there is no
`onPressed` on that constructor. The accept button's label **is** the button's own label, so rule
12's "the accept button repeats the verb" is structural rather than remembered. `bool` is not
expressible as a result: three outcomes — confirmed, declined, and dismissed by a system-back pop —
are three enum values, because collapsing them into `bool?` is how a caller's `if (ok == true)` turns
a stray dismissal into silence and, in the mirror case, a null into a delete.

**The cancel rung reads `Back one step`, not `Keep it`.** `lonja-dialogs-and-surfaces` rule 3
prescribes `Keep it`, and `modal-decision-matrix.md` §5 gives a whole cancel column built the same
way — `Keep it`, `Keep the entry`, `Keep my catches`, `Keep Ras Al Khaimah` — on the principle that
a cancel label should name the *preservation* rather than the abstention. Every one of those fails
check 3 of `check_app_invariants.sh`, whose pattern matches a quoted string beginning `Keep` and the
substring `keep it`, in Dart **and in every ARB file**, with no exemption anywhere; invariant 2 bans
the lexicon outright. This epic ships the *mechanism*, not a screen's copy: `cancelLabel` is a
required parameter, and E07's own tests pass `Back one step` from the approved corpus in
`button-anatomy.md`. The screens that own real confirmations — E13, E16, E17 — need either a
corrected rule or wording that names the preservation without the banned verb. Recorded in the
epic's risk 2; not re-argued here.

**The disabled state cannot exist without its reason.** Rule 9 says a disabled control states its
reason in adjacent prose — "Select a zone first" — because a dead grey control with no explanation
reads as a broken app, and a fisher who believes the app is broken keeps the undersized fish. So
`LonjaButton` asserts `onPressed != null || disabledReason != null` and renders the reason as a
sibling in the same column. A rule that a widget can enforce structurally should not be left to a
review checklist.

**Busy is a latch, and the latch is the correctness half.** Two taps in the 90 ms it takes wet
fingers to bounce must not write two rows to `user.db`. The guard is `if (_busy) return;` **before**
the first `await`, cleared in a `finally` gated on `mounted`. The visual is a consequence: the label
and the box do not change, and a bottom-edge rule appears while the latch is held. There is never a
`CircularProgressIndicator` — check 7 of `check_lonja_buttons.sh` fails one anywhere in `app/lib` —
because a spinner implies a network round trip in an app that has none and teaches the user to
distrust an instant answer.

**Deferred: the 250 ms deferral on the busy rule.** `lonja-buttons` rule 10 draws the bottom rule
only past 250 ms. Implementing that needs a 250 ms duration token, and `token-tables.md` publishes
three motion values — `none`, `quick` 90 ms, `page` 140 ms — none of which is it; inventing a fourth
here would fork a table this epic does not own (`CONVENTIONS.md` §4). Nothing in the app can yet
exceed 250 ms either: both databases are local and §13 budgets rule evaluation at < 10 ms and search
at < 50 ms. The rule is drawn for the whole duration of the latch, and the deferral lands with the
first operation that could plausibly outrun it — E13's catch write or E17's export — together with
the token row it needs.

**Deferred: `quiet`, `link` and `LonjaIconButton`.** The ladder has five rungs and this task names
three. A rung with no caller is a widget no golden covers and `/simplify` correctly deletes; the
first screen that earns one adds it — the ruler's *Reset to screen default* (E09) is the likely
first `quiet`. `LonjaIconButton` needs a `semanticLabel` **and** a glyph, and the authored icon
family does not exist yet (epic risk 5); a Material `Icons.` glyph is banned outright by
`lonja-icons-and-plates` rule 1, so shipping the widget now would mean shipping it empty.

**Rejected: a `ButtonStyle` assembled at the call site.** It invents an untested sixth variant and
hardcodes one theme's hex into a feature file. **Rejected: `FloatingActionButton`.** It floats, it
casts, it is round, and check 7 fails it. **Rejected: `Opacity(opacity: 0.4)` as the disabled
state** — it halves contrast on an already low-chroma palette and still explains nothing.

## Tests first

Write every row before touching `lonja_button.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | loop × 3 — `LonjaButton.primary fills its box with the accent slot in the <theme> theme` | each theme | `harbour30` / `harbour69` / `black00` | The one filled rung, resolved per theme. In sunlight it is a black box, which is correct and is why the ladder is not graded by hue |
| 2 | `LonjaButton.secondary draws no field and frames itself in ruleBearing` | paper | transparent background, `ink30` side | The only outlined rung. `lonja-design-tokens` rule 6 puts a control frame on `ruleBearing`; the ladder table's `#16201C` is the same decision one slot darker |
| 3 | `LonjaButton.destructive fills with verdictFail and frames at LonjaRules.strong` | paper | `oxblood28`, width `2.0` | The non-colour signal that separates it from `primary` in greyscale, where their fields are 2.3 L\* apart |
| 4 | loop × 3 — `LonjaButton.<variant> stands at least 48 dp tall` | standard density | `size.height >= 48` | `SPEC.md` §13's standard floor, measured with `tester.getSize` rather than read off the style |
| 5 | loop × 3 — `glove - LonjaButton.<variant> stands at least 56 dp tall` | glove density | `size.height >= 56` | `SPEC.md` §4.9. The number that decides whether a wet, gloved thumb hits the right control |
| 6 | loop × 3 — `LonjaButton.<variant> reports zero elevation and a transparent shadow` | each variant | `0`, alpha `0` | A stamp is pressed onto paper; one elevated button reframes the screen as an app |
| 7 | loop × 3 — `LonjaButton.<variant> draws square corners` | each variant | `BorderRadius.zero` | The design language has one rounded thing and it is not a button |
| 8 | `LonjaButton.primary doubles its rule weight when focused` | focused | `LonjaRules.strong` | The state matrix's non-colour signal for focus is that the rule weight doubles; `stamp` stays reserved for the verdict |
| 9 | `LonjaButton.primary washes its field when pressed and never ripples` | pressed | overlay `onSurface` at alpha 0.10, `NoSplash.splashFactory` | Paper does not ripple, and a wash is a state change that moves nothing |
| 10 | `LonjaButton.primary sinks to surfaceSunk with an onSurfaceFaint label when disabled` | `onPressed: null` | those two slots | The disabled cell of the matrix, and the reason `Opacity` was rejected |
| 11 | `LonjaButton.primary states its reason beside itself when disabled` | disabled with a reason | the reason text is in the tree | A dead control with no explanation reads as a broken app |
| 12 | `LonjaButton.primary asserts when it is disabled with no reason` | `onPressed: null`, no reason | `AssertionError` | The rule is enforced by the constructor instead of by a review checklist |
| 13 | `LonjaButton.primary invokes its action once for two taps 90 ms apart` | two taps | callback count `1` | Two rows in `user.db` and two tally marks is the failure this prevents; 90 ms is the bounce of a wet finger |
| 14 | `LonjaButton.primary draws a bottom rule while the latch is held` | busy | a rule at the bottom edge, no spinner | The only legal busy affordance; a spinner implies a network this app does not have |
| 15 | `LonjaButton.primary renders its label verbatim` | `Record another` | exactly that string | No case transform: `.toUpperCase()` is a no-op on Arabic, hazardous in Turkish, and shouts |
| 16 | `LonjaButton.primary sets its label in the sans ui step` | standard | `LonjaTypeScale.ui` | A button is chrome; the serif is reserved for anything quoting the law |
| 17 | `glove - LonjaButton.primary sets its label in the uiLarge step` | glove | `LonjaTypeScale.uiLarge` | The one type change glove mode makes; it never touches `legal`, `verdict` or `citation` |
| 18 | `LonjaButton.destructive opens a confirmation before invoking its action` | tap | the confirm surface is on screen, action not yet called | Destructive means a row leaves `user.db`; the confirmation is structural, not conventional |
| 19 | `LonjaButton.destructive leaves its action uninvoked when the confirmation is declined` | decline | callback count `0` | The declined branch is the one a `bool?` collapses into the same value as a dismissal |
| 20 | `showLonjaConfirm labels its accept action with the verb from the button` | `Delete this trip` | accept label is that string | Rule 12: the accept button repeats the verb, so nobody confirms an unnamed action |
| 21 | `showLonjaConfirm ignores a tap on the barrier` | tap outside | the surface is still on screen | Wet hands on a six-inch phone generate stray barrier taps constantly, and a legally weighted question must not resolve by accident |
| 22 | `showLonjaConfirm returns dismissed when the route pops without a choice` | system back | `LonjaConfirmOutcome.dismissed` | Three outcomes, three values. A `bool?` makes a dismissal indistinguishable from a decline |
| 23 | `showLonjaConfirm restores focus to the opener after it pops` | opener focused | the opener holds focus again | Without the restore, TalkBack and VoiceOver drop the cursor to the top of the route and the user re-reads the whole screen |
| 24 | `showLonjaConfirm autofocuses the cancel action rather than the destructive one` | opened | cancel holds focus | `modal-decision-matrix.md` §4: a stray Enter on a hardware keyboard would otherwise confirm a delete that nobody read |

```dart
// app/test/ui/core/lonja_button_states_test.dart
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

void main() {
  testWidgets('LonjaButton.primary invokes its action once for two taps 90 ms apart',
      (WidgetTester tester) async {
    int calls = 0;
    await pumpLonja(
      tester,
      LonjaButton.primary(
        label: 'Record another',
        onPressed: () async {
          calls++;
          await Future<void>.delayed(LonjaMotion.page);
        },
      ),
    );

    await tester.tap(find.byType(LonjaButton));
    await tester.pump(const Duration(milliseconds: 90));
    await tester.tap(find.byType(LonjaButton));
    await tester.pumpAndSettle();

    expect(calls, 1);
  });

  testWidgets('LonjaButton.primary asserts when it is disabled with no reason',
      (WidgetTester tester) async {
    expect(
      () => LonjaButton.primary(label: 'End trip', onPressed: null),
      throwsAssertionError,
    );
  });

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/ui/core/lonja_confirm_dialog_test.dart
testWidgets('showLonjaConfirm returns dismissed when the route pops without a choice',
    (WidgetTester tester) async {
  late BuildContext opener;
  await pumpLonja(tester, Builder(builder: (BuildContext context) {
    opener = context;
    return const SizedBox.shrink();
  }));

  final Future<LonjaConfirmOutcome> pending = showLonjaConfirm(
    opener,
    title: 'Delete this trip',
    body: 'The trip and its 8 catches leave this phone.',
    confirmLabel: 'Delete this trip',
    cancelLabel: 'Back one step',
  );
  await tester.pumpAndSettle();

  await tester.binding.handlePopRoute();          // system back, no choice made
  await tester.pumpAndSettle();

  expect(await pending, LonjaConfirmOutcome.dismissed);
});
```

**Run:** `cd app && flutter test test/ui/core/` → 24 named rows, of which five are loops of 3, so 34
failures. If any passes before `lonja_button.dart` exists, the test is wrong.

## Implementation outline

1. `LonjaButtonVariant` and `LonjaButtonStyles.resolve` in `lib/theme/lonja_button_style.dart`. One
   `switch` over the variant selects field, label and rule tone; the six states are resolved in
   `WidgetStateProperty.resolveWith`, never in local `setState`. Every value comes from the passed
   `LonjaTokens` and `LonjaTypeScale` — the function takes no `BuildContext`.
2. `LonjaButton` as a `StatefulWidget` (the latch is state). `build` reads
   `LonjaTokens.of(context)` and `LonjaType.of(context)`, resolves a style, and returns a
   **`TextButton`** carrying it — legal here per check 1's `/ui/core/` allowance. `TextButton` is
   the unstyled base the worked example uses precisely because it brings no field, no elevation and
   no shape of its own to argue with; `FilledButton` and `OutlinedButton` each ship defaults the
   style would then have to overwrite. The label and the empty `leading` slot go in its child.
3. The latch: `if (_busy) return;` before the first `await`, `setState` to raise it, `finally` gated
   on `mounted` to clear it. `onPressed` is `null` while it is held, so the framework also refuses
   the tap.
4. The disabled reason: an `assert` in the constructor, and a `Column` with the reason as a sibling
   in `onSurfaceMuted` at the `uiSmall` step, separated by `density.tapGap`.
5. `showLonjaConfirm` in `lib/ui/core/ui/lonja_confirm_dialog.dart`: capture
   `FocusManager.instance.primaryFocus`, `showDialog<LonjaConfirmOutcome>` with
   `barrierDismissible: false` and a flat barrier wash from `onSurface` (never a gradient, never a
   blur), a `LonjaPanel` shell holding title, body and an action row of destructive-accept plus
   secondary-cancel. `autofocus` goes on the **cancel** action — never on the destructive one, or a
   stray Enter confirms a delete. Then `opener?.requestFocus()` behind an
   `if (!context.mounted) return;` guard, and map a `null` result to `dismissed`.
6. `LonjaButton.destructive` wires the confirmation itself: no `onPressed` parameter, an
   `onConfirmed` callback, and `confirmLabel` fixed to the button's own `label`.
7. Re-run the suite; then all four gates. Check 2 of `check_lonja_buttons.sh` counts primaries per
   file and exempts `/ui/core/`, so the definition here is not a violation — but a test file that
   builds two is fine, because the gate scans `app/lib` only.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 23 named tests pass, including the five loops, and each failed first.
- [ ] Every rung measures ≥ 48 dp standard and ≥ 56 dp glove, measured with `getSize`.
- [ ] The three rungs differ in field, outline and rule weight, so the ladder holds with hue removed.
- [ ] `LonjaButton.destructive` has no `onPressed` parameter and cannot be built without its
      confirmation copy; the accept label is the button's own label.
- [ ] `showLonjaConfirm` returns `LonjaConfirmOutcome`, sets `barrierDismissible: false` explicitly,
      and maps a `null` pop to `dismissed`.
- [ ] No label in this task or its tests is `OK`, `Yes`, `Submit`, `Continue`, `Done`, `Confirm`,
      `Keep`, `Keep it` or `Return`; every label is from the approved corpus.
- [ ] `grep -rn "CircularProgressIndicator\|FloatingActionButton" app/lib` returns nothing.
- [ ] `grep -rnE "RoundedRectangleBorder|Colors\.|fontSize:" app/lib/ui` returns nothing — those
      constructs live in `lib/theme/lonja_button_style.dart`.
- [ ] `check_lonja_buttons.sh app/lib` and `check_lonja_dialogs.sh app/lib` both clean.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh app/lib
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
feat(theme): add the primary, secondary and destructive button rungs and the typed confirm

The ButtonStyle lives under lib/theme/ and the widget under lib/ui/core/ui/,
because a ButtonStyle is made of exactly the constructs check_lonja_tokens.sh
bans outside /theme/ — RoundedRectangleBorder, numeric EdgeInsets, literal
stroke widths, fontSize and Colors.transparent — while check_lonja_buttons.sh
allows a raw Material button constructor in both directories.

The rungs are graded by field, outline and rule weight rather than by hue,
because hue is exactly what is missing in the two places that matter: sunlight
collapses accent to black, and in greyscale the primary field and the
destructive field are 2.3 L* apart — the same box. Destructive frames at
LonjaRules.strong; stamp stays reserved for the verdict.

A destructive button cannot be built without its confirmation: the constructor
takes the copy, opens the surface itself, and uses its own label as the accept
label, so "the accept button repeats the verb" is structural. The result is a
three-valued enum, because a bool? makes a system-back dismissal
indistinguishable from a decline on a path where a row leaves user.db. The
cancel rung reads "Back one step": lonja-dialogs-and-surfaces rule 3 asks for
"Keep it", which check 3 of check_app_invariants.sh fails in Dart and in every
ARB file, with no exemption.

Disabled asserts on a missing reason and renders it as a sibling. Busy is a
latch guarded before the first await, so two taps 90ms apart write one row;
there is no spinner anywhere, because there is no network to wait for.

Targets come from LonjaTokens.density at 48 and 56dp, which are SPEC.md §13's
and §4.9's numbers. quiet, link and LonjaIconButton are deliberately absent:
a rung with no caller is a widget no golden covers, and an icon button needs
the authored glyph family, which does not exist yet.

Task: E07/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
