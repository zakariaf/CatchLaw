# E10/T06 — The stale bar, and D3

| | |
|---|---|
| **Epic** | E10 — The result screen |
| **Branch** | `epic/10-result` (shared) |
| **Commit** | `feat(result): show the ochre stale bar without gating the verdict` |
| **Depends on** | T01 (`StaleDisplay`), T02 (the stamp the bar must not change) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.7 "Expiry warning (D3)", §7.3 step 1, §6 dialogs D3, §14 "Expiry test — this is a correctness test, not a cosmetic one" |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-verdict-and-status` | Rule 5 and the bar's anatomy — ochre, under the app bar, `flex: none`, no dismiss, no retry |
| `catchlaw-conventions-index` | Invariant 5 in full, and `check_app_invariants.sh` check 6, which fails on expiry used as a gate |
| `catchlaw-rule-engine` | Rule 1 — expiry is tagged, never filtered, and the boundary day is inclusive |
| `catchlaw-verdict-contract` | Rule 10 — the bar's own copy is a statement of fact too; never "Update the app", never "Check again later" |
| `lonja-dialogs-and-surfaces` | The modal decision matrix, which rules the stale notice inline rather than modal |
| `state-management-riverpod` | The per-session dismissal of the detail: an in-memory `Notifier`, never persisted |
| `accessibility-as-code` | Rule 2 and rule 6 — the warning glyph is labelled, and amber is not the only signal |
| `i18n-rtl-l10n` | The bar is full-bleed and directional; the date inside Arabic text is bidi-isolated |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.7 "Expiry warning (D3)" | Persistent amber bar, and the rule is still evaluated; "amber, never blocking. A stale rule beats nothing at sea" |
| `SPEC.md` | §7.3 step 1 and the paragraph after step 4 | Why `valid_to` is not a filter: the day an *orden de vedas* lapses, every rule it carried would vanish |
| `SPEC.md` | §6 "Dialogs" D3 | The screen inventory's wording, "amber, dismissable per session" — reconciled below |
| `SPEC.md` | §14 expiry bullet | The device test: the bar appears **and** that rule still produces a finding with its numbers intact |
| `.claude/skills/lonja-verdict-and-status/references/verdict-anatomy.md` | "The ochre stale bar" | Ground `#E8E0C6`, 1 dp `#8A6A16` rules, 17 dp glyph, `flex: none`, no dismiss control and no retry |
| `.claude/skills/lonja-verdict-and-status/references/states-and-signals.md` | "Staleness is an axis, not a fifth category" | The four-by-two matrix, and the second footnote marker naming the pack |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | "5 — Stale beats absent" | The fresh/expired matrix and the three edge cases (no `validUntil`, clock behind, two packs) |
| `.claude/skills/lonja-dialogs-and-surfaces/references/modal-decision-matrix.md` | §2 the matrix | "Stale-data notice — blocks? no — inline `ochre` panel on result" |
| `.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh` | check 6 | The exact shapes that fail the build, including the ternary-to-`*Expired*` widget |

## What this delivers

- `app/lib/ui/result/widgets/stale_rule_bar.dart` — `StaleRuleBar`, taking a `StaleDisplay`;
  full-bleed, ochre, directly under the app bar, above the plate, with no dismiss control and no
  retry affordance. Contains the private `_StaleRuleDetail`.
- `app/lib/ui/result/view_models/stale_detail_session.dart` — `StaleDetailSession`, an in-memory
  `Notifier<Set<String>>` of pack ids whose detail has been closed for this app session.
- The second citation footnote marker naming the pack and its validity date, added to T05's row.
- `app/test/ui/result/stale_rule_bar_test.dart`,
  `app/test/ui/result/stale_verdict_unchanged_test.dart`.

## Why it is built this way

**The rule is evaluated behind the bar; that is the whole feature.** §7.3 step 1 says "Do not filter
on `valid_to`", and the paragraph after step 4 says why: the first draft filtered on
`date < valid_to`, so on the day a Spanish annual *orden de vedas* or a Brazilian piracema portaria
expired, every rule sourced from it vanished and every species fell through to "no rule recorded".
Those annual instruments are exactly the rows that carry a `valid_to`. §14 states the acceptance
condition as a correctness test rather than a cosmetic one: set the clock past a rule's `valid_to`,
and assert both that the bar appears **and** that the rule still produces a finding with its numbers
intact. A "no rule recorded" result there is a failure.

**Non-blocking is enforced by a gate, not by intent.** `check_app_invariants.sh` check 6 fails the
build on `if (…isExpired…) return`, on `isExpired ? SomethingExpired(…)`, on
`enabled: !isExpired` and on `onPressed: isExpired ? null`. The bar is therefore rendered as a
collection element — `if (display.stale != null) StaleRuleBar(stale: display.stale!)` inside a
children list — which adds a widget and returns nothing. The widget is named `StaleRuleBar` and not
`RulePackExpiredBar` for the same reason: the gate's ternary pattern matches any widget name
containing `Expired`.

**D3 is an inline surface, not a modal, and the bar is not dismissable.** `SPEC.md` §6 lists D3 among
the dialogs and calls it "amber, dismissable per session". Three other authorities disagree about the
shape: §4.7 calls it a **persistent** amber bar; `CONVENTIONS.md` §9 invariant 5 forbids gating;
`lonja-verdict-and-status` rule 5 says the bar "carries no dismiss control and no retry"; and
`modal-decision-matrix.md` §2 rules the stale-data notice explicitly non-blocking and inline. A modal
would also fail `lonja-dialogs-and-surfaces` rule 1, since there is no decision to resolve — there is
nothing to retry on a device with no network by design.

The reconciliation this task implements, satisfying every line of all four sources:

| Element | Persistent? | Dismissable? | Authority |
|---|---|---|---|
| `StaleRuleBar` — one line, the expiry date, "still shown, verify before relying on it" | yes, `flex: none`, never scrolls away | **no** | §4.7, invariant 5, rule 5 |
| `_StaleRuleDetail` — the pack id, its validity date, the last-verified-wording sentence | expands from the bar | **yes, per session** | §6 D3 |
| The verdict, table, findings and citation beneath | unchanged in both states | — | §7.3, §14 |

Closing the detail never removes the bar, and the bar is what the invariant protects. If a future
task asks for a dismiss control **on the bar itself**, that weakens invariant 5 and the task is
wrong — say so rather than complying.

**The dismissal is per session and is never persisted.** `StaleDetailSession` is an in-memory
`Notifier` holding pack ids; nothing is written to `user.db`. Persisting it would make "dismissed for
this session" into "dismissed forever", and the fisher who closed it once in April would not see it
again in the September when the numbers actually matter.

**The bar's own copy is a statement of fact.** Rule 10 of `catchlaw-verdict-contract` and invariant 2
apply to the bar as much as to the stamp: "Rule data expired 2026-06-30 — still shown, verify before
relying on it". Never "Update the app" (there is nothing to update from), never "Check again later"
(§14's own banned example), never "Out of date" alone without the date.

**The boundary day is inclusive.** `resolution-algorithm.md`'s expiry axis: `valid_to` equal to the
evaluation date is **not** expired — the last day counts. A test pins it, because an off-by-one here
puts an amber bar on a rule that is in force.

**Rejected — `showDialog` on first render of an expired pack.** Named as an anti-pattern in
`lonja-verdict-and-status`: it spends the ten-second budget on something he cannot fix offline and
hides the last verified wording he does have.

**Rejected — greying, blurring or dimming the verdict beneath the bar.** `states-and-signals.md`:
nothing is greyed, blurred, hidden or gated. A dimmed verdict is a soft version of withholding it,
and withholding is itself advice — deciding the fisher is better off with nothing.

**Rejected — a "Refresh rules" affordance.** There is no network by design; the button could only
ever fail, and its presence tells the reader a network exists.

## Tests first

Write every row before touching `stale_rule_bar.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `StaleRuleBar renders when the resolution is tagged expired` | `isExpired` true, `expiredOn 2026-06-30` | the bar and the date are on screen | The §4.7 baseline |
| 2 | `StaleRuleBar is absent when the ruleset is current` | `isExpired` false | no bar | An amber bar on a live rule destroys the signal's meaning |
| 3 | `StaleRuleBar is absent when valid_to equals the evaluation date` | `valid_to == on` | no bar | The boundary is inclusive — the last day counts |
| 4 | `ResultSection renders an identical verdict sentence with the ruleset expired` | one `Decided`, fresh and expired | the stamp headline and sub-line strings are equal | The §14 correctness test in widget form |
| 5 | `ResultSection renders identical rule-facts values with the ruleset expired` | same | every table value string is equal | "With its numbers intact" means every number, not just the headline |
| 6 | `ResultSection enables every control with the ruleset expired` | same | no widget has `onPressed: null` or `enabled: false` | Invariant 5's "never disables a control", asserted rather than assumed |
| 7 | `ResultSection shows no dialog when the ruleset is expired` | expired | no route pushed, no barrier | A modal spends the ten-second budget on something he cannot fix |
| 8 | `ResultSection renders no "no rule recorded" state when the ruleset is expired` | expired `Decided` | the no-rule wording is absent | The exact regression §7.3 records from the first draft |
| 9 | `StaleRuleBar carries no dismiss control` | expired | no close icon, no dismiss button in the bar subtree | The bar is the invariant; only its detail may be closed |
| 10 | `StaleRuleBar carries no retry or refresh affordance` | expired | no button whose label mentions refresh, retry or update | There is nothing to retry on a device with no network by design |
| 11 | `_StaleRuleDetail closes for the session and leaves the bar in place` | expand, close | the detail is gone, the bar remains | The §6 D3 half of the reconciliation |
| 12 | `StaleDetailSession does not persist a dismissal` | close, rebuild a fresh container | the detail is available again | "Per session" is not "forever"; the September reader must still see it |
| 13 | `StaleRuleBar pairs the warning glyph with the word and the date` | expired | an `Icon` and text carrying the date | Amber alone is invisible in greyscale and to 8% of readers |
| 14 | `StaleRuleBar states a fact and never an instruction` | expired | the copy contains none of the banned lexicon | Invariant 2 applies to the bar too; "Update the app" is an instruction |
| 15 | `ResultCitationRow prints a second marker naming the pack when the ruleset is expired` | expired | marker 2 names the pack and its validity date | `states-and-signals.md`: the citation gains a pack-provenance footnote |
| 16 | `StaleRuleBar does not scroll away with the result body` | expired, scroll to the bottom | the bar is still on screen | `flex: none` — the fact must not be scrollable out of sight |
| 17 | `RTL - StaleRuleBar places the glyph at the start edge` | locale `ar` | glyph rect start < text rect start | Directional geometry on a full-bleed bar |
| 18 | `ar - StaleRuleBar isolates the ISO date` | locale `ar` | the date run is FSI/PDI wrapped | An unisolated `2026-06-30` breaks apart in an RTL paragraph |
| 19 | `sunlight - StaleRuleBar renders with no grey` | sunlight theme | every resolved colour is black or white | Sunlight deletes every grey, ochre included |

```dart
// app/test/ui/result/stale_verdict_unchanged_test.dart
// The §14 expiry check, executed as a widget test: same resolution, two packs.
import 'package:catchlaw/ui/result/widgets/result_section.dart';
import 'package:catchlaw/ui/result/widgets/stale_rule_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../harness.dart';

void main() {
  List<String> renderedText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data)
      .whereType<String>()
      .toList();

  group('ResultSection', () {
    testWidgets('renders an identical verdict sentence with the ruleset expired', (tester) async {
      await tester.pumpApp(ResultSection(display: kDisplayAmeixaFresh));
      final fresh = renderedText(tester);

      await tester.pumpApp(ResultSection(display: kDisplayAmeixaExpired));
      final stale = renderedText(tester);

      expect(find.byType(StaleRuleBar), findsOneWidget);
      // Every string the fresh render printed is still printed, with its numbers intact.
      expect(stale, containsAll(fresh));
      expect(find.textContaining('No rule recorded'), findsNothing);
    });

    testWidgets('enables every control with the ruleset expired', (tester) async {
      await tester.pumpApp(ResultSection(display: kDisplayAmeixaExpired));

      for (final button in tester.widgetList<ButtonStyleButton>(find.byType(ButtonStyleButton))) {
        expect(button.onPressed, isNotNull, reason: 'expiry may never disable a control');
      }
    });

    testWidgets('shows no dialog when the ruleset is expired', (tester) async {
      await tester.pumpApp(ResultSection(display: kDisplayAmeixaExpired));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(ModalBarrier), findsNothing);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/ui/result/` → 19 new failures. If any passes now, the test is
wrong — in particular, test 4 passing early means the fixtures are identical and prove nothing.

## Implementation outline

1. Confirm T01's `StaleDisplay` carries `expiredOn` (ISO string), `packId` and the already-localised
   bar sentence. Nothing about expiry is computed in this widget.
2. `StaleRuleBar({required this.stale})`: a `DecoratedBox` with the ochre-tint ground and 1 dp ochre
   rules top and bottom, `EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10)`, a 17 dp
   `Icons.warning_amber` with a `semanticLabel`, and the sentence in the small sans step.
3. Place it in `ResultSection` as a non-scrolling child above the scroll view, so it cannot scroll
   away. Render it as `if (display.stale != null) StaleRuleBar(...)` in a children list — never a
   ternary into a widget whose name contains `Expired`, which `check_app_invariants.sh` matches.
4. `_StaleRuleDetail`: expands beneath the bar when the pack id is not in `StaleDetailSession`; a
   labelled close target that names its effect ("Close this note") removes it for the session. The
   close writes to the `Notifier`, never to `user.db`.
5. Extend T05's `ResultCitationRow` with the optional second marker naming the pack and its validity
   date, present only when `display.stale != null`.
6. Re-run the whole suite. T02's and T03's tests must still pass unchanged — if any of them now
   fails, the bar has altered the verdict beneath it, which is the bug this task exists to prevent.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first.
- [ ] `check_app_invariants.sh app/lib` is clean, check 6 included.
- [ ] No `return`, `throw`, `enabled:`, `onPressed: null` or error widget is guarded by `isExpired`
      anywhere in `app/lib`.
- [ ] The bar has no dismiss, refresh or retry control; only `_StaleRuleDetail` can be closed.
- [ ] The dismissal state is in memory only — no `user.db` write, no `SharedPreferences` key.
- [ ] The bar's copy contains no imperative and names the date.
- [ ] The verdict, findings, table and citation render byte-identically fresh and expired.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh      app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh    app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
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
feat(result): show the ochre stale bar without gating the verdict

SPEC §7.3 refuses to filter on valid_to because the day a Spanish orden de
vedas or a Brazilian piracema portaria lapses, filtering would wipe every
rule it carried and drop every species to "no rule recorded" — turning a
defensible frozen snapshot into a de facto live-data product. The bar is
therefore additive: the same evaluation runs, the same numbers print, and
one ochre line states the date.

The bar is persistent and carries no dismiss, no refresh and no retry;
§6's "dismissable per session" is implemented as the expandable detail
beneath it, which can be closed for the session in memory and never
persisted. Closing the detail never removes the bar, because the bar is
what invariant 5 protects.

Task: E10/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
