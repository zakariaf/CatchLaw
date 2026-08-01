# E14/T04 — The decision trail

| | |
|---|---|
| **Epic** | E14 — The identification key |
| **Branch** | `epic/14-identify` (shared) |
| **Commit** | `feat(identify): keep a tappable decision trail with back one step and start over` |
| **Depends on** | T01 (traversal), T03 (the trail must be present on both terminal states, so both must exist) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.3 row "Decision trail", §5.2 reason 2, §6 S7 elements |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-navigation-chrome` | The trail and its two controls are chrome above the state body. Rule 5 (directional geometry only), rule 6 (the mirrored, translated back affordance) and rule 4 (every chrome string through `AppLocalizations`) bind all of it |
| `lonja-buttons` | `Back one step` is verbatim in the approved label corpus. Rule 1 decides that neither control is the screen's primary; the ladder decides which is `secondary` and which is `quiet` |
| `lonja-icons-and-plates` | The separator between trail entries is a stroked glyph with `mirrorInRtl`, never `Icons.chevron_right` |
| `state-management-riverpod` | The trail is ViewModel state, not route state. Auto-dispose is what makes re-entering S7 start clean, and that is a deliberate product behaviour, not a side effect |
| `navigation-and-routing` | The reason this is **not** a `Navigator` stack, stated once so nobody re-derives it |
| `accessibility-as-code` | Trail entries are tappable controls: labels, target size and the announcement of "you are here" |
| `widget-golden-and-a11y-testing` | The RTL lane for the mirrored separator |
| `catchlaw-conventions-index` | Invariant 2 — every trail entry is a statement of what was answered, never an instruction |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.3 row "Decision trail" | "The answers that led here, each tappable to go back"; "Why am I here?" is answerable at every node |
| `SPEC.md` | §5.2 reason 2 | The audit argument: the user can see why the key landed where it did and can back out one step. The trail **is** that argument |
| `SPEC.md` | §6 S7 elements | Element order: one couplet, breadcrumb of answers, `Back one step`, `Start over`, live candidate count |
| `SPEC.md` | §4.5 | What the app records — trips and catches. An identification attempt is not among them |
| `.claude/skills/lonja-navigation-chrome/SKILL.md` | rules 4, 5, 6 | Translated chrome strings, directional geometry, the mirrored 44dp/56dp back affordance |
| `.claude/skills/lonja-navigation-chrome/references/nav-anatomy-and-states.md` | "Back affordance" | The measured values and `Transform.flip` under RTL |
| `.claude/skills/lonja-buttons/references/button-anatomy.md` | "Label wording", "Action rows" | `Back one step` in the approved corpus; stacked column gaps 8dp / 12dp glove |
| `.claude/skills/lonja-icons-and-plates/SKILL.md` | rule 1, anti-patterns | One authored family; `Icons.adaptive.arrow_back` is the general-Flutter answer and is not this app's |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "Numeric alignment and RTL mirroring" | The mirroring table — chevrons, borders, padding, swipe direction |
| `FLUTTER_GUIDE.md` | §5.2, §5.3 | The read path; Riverpod 3 filters updates with `==`, so `KeyPath` needs real value equality |
| `FLUTTER_GUIDE.md` | §8.1, §6.1 | Widget classes rather than helper methods; test naming |
| `epics/DECISIONS.md` | D-3, D-8 | Six locales for both control labels; the directional-geometry ban is a grep gate, not a lint |

## What this delivers

- `app/lib/domain/models/key_path.dart` — `KeyStep(nodeId, questionKey, chosenOptionIndex,
  chosenLabelKey)` and `KeyPath`, an immutable value with `push`, `backOne`, `rewindTo(int)`,
  `isEmpty` and `length`. Pure Dart, real `==` and `hashCode`, no Flutter import.
- `app/lib/ui/identify/view_models/identify_state.dart` — every variant carries the current `KeyPath`,
  including both terminal states.
- `app/lib/ui/identify/view_models/identify_view_model.dart` — `backOneStep()`, `startOver()`,
  `rewindTo(int stepIndex)`; `choose` pushes a step before it moves.
- `app/lib/ui/identify/widgets/decision_trail.dart` — the breadcrumb: one entry per answered couplet,
  each a tap target, separated by a mirrored stroked glyph, followed by the two controls.
- `app/lib/l10n/app_{ar,en,es,gl,ca,pt_BR}.arb` — `actionBackOneStep`, `actionStartOver`,
  `identifyTrailSemanticLabel`.
- Tests: `app/test/domain/key_path_test.dart`,
  `app/test/ui/identify/decision_trail_test.dart`, and additions to
  `app/test/ui/identify/identify_view_model_test.dart`.

## Why it is built this way

**The trail is the product feature that replaces the classifier.** §5.2's second reason for excluding
photo-AI is not that a key is more accurate — it is that a key is *auditable*: "the user can see why
the key landed where it did and can back out one step". Everything below follows from taking that
literally rather than treating the breadcrumb as navigation garnish. A trail that cannot be read back,
or a terminal state that cannot be backed out of, would leave the exclusion in §5.2 unearned.

**Rejected: a `Navigator` route per couplet.** It is the obvious way to get `Back one step` for free,
and it fails on three counts. The trail must render as *data* — a breadcrumb showing the chosen answer
at each level, on screens that are themselves terminal states with no couplet route to pop. Tapping
the second of five entries must be one state change, not four pops animating four transitions. And the
route stack is shared with the rest of the app, so a deep key would bury S1 under six entries that
`maybePop()` walks one at a time. The state lives in the ViewModel; the router holds exactly one entry
for S7.

**The trail states the answers, not the questions.** §4.3 says "the answers that led here". A
breadcrumb of questions — "Body shape?", "Barbels?" — reads back as a form the user filled in, and
cannot be checked against the fish. A breadcrumb of chosen labels — "Deep-bodied", "No barbels",
"Forked tail" — is a description of the specimen, which is exactly what "Why am I here?" means. Each
entry still knows its `nodeId`, so tapping it re-opens the couplet where that answer was given.

**`rewindTo(i)` drops step `i` and everything after it.** The semantics are chosen so that tapping a
trail entry re-opens the couplet that produced it, with that answer *unmade*. The alternative —
keeping step `i` and re-opening the next node — would leave the user staring at a couplet he has
already answered with no visible way to change the answer, which is the opposite of the feature.

**Neither control is the screen's primary.** The couplet options are the actions on a couplet screen,
and on the dead end the primary is already `Browse by shape` (T03). `Back one step` is `secondary`,
`Start over` is `quiet` — the escape route, per the ladder. Both sit with the trail *above* the state
body rather than joining each state's own action row, so the dead end does not end up with two
competing action groups.

**Auto-dispose is the product behaviour.** The provider is auto-disposing, so leaving S7 discards the
path and re-entering starts at the taxon-group entry points. This is deliberate: a half-finished key
from the previous fish, silently resumed, is a trap — the user answers couplet four about a specimen
whose first three couplets described a different animal. Starting over is cheap; a wrong resumption is
not.

**Rejected: persisting the trail in `user.db`.** §4.5 defines what the app records — trips, catches,
tallies. An identification attempt is a transient hypothesis about a fish in a hand, not a record of
anything, and writing it would put content-shaped rows into the one database that is irreplaceable
(`catchlaw-reference-database` rule 1). It would also have to be migrated forever.

**Rejected: `Icons.adaptive.arrow_forward` as the separator.** It is the correct general-Flutter
answer and the wrong one here: `lonja-icons-and-plates` rule 1 admits one authored family and its
anti-pattern list names this exact substitution. The separator is a `LonjaGlyph` with
`mirrorInRtl: true`.

## Tests first

Write every row before touching a production file. Run them. **They must fail.** A row that passes
before the implementation exists is testing nothing.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `KeyPath.backOne removes the last step` | path of 3 | path of 2, first two unchanged | The core operation behind `Back one step` |
| 2 | `KeyPath.backOne on an empty path returns an empty path` | empty path | empty path, no throw | The boundary the entry-point screen hits every time |
| 3 | `KeyPath.rewindTo drops the step it names and every step after it` | path of 4, `rewindTo(1)` | path of 1 | Tapping a trail entry unmakes that answer, not the one after it |
| 4 | `KeyPath.rewindTo(0) returns an empty path` | path of 4 | empty path | Tapping the first entry is `Start over` by another route; both must agree |
| 5 | `KeyPath equality holds for two paths with the same steps` | two identical paths | `==` is true | Riverpod 3 filters updates with `==`; a path without value equality rebuilds S7 on every tap |
| 6 | `IdentifyViewModel.backOneStep re-opens the previous couplet from a candidate list` | at candidates after 3 couplets | couplet 3 shown, path length 2 | Backing out of a terminal state is the §5.2 audit claim |
| 7 | `IdentifyViewModel.backOneStep re-opens the previous couplet from a dead end` | at a dead end | the couplet that offered the dead-end option | T03 left the dead end with two routes out of the key; this is the route back into it |
| 8 | `IdentifyViewModel.backOneStep at the entry points leaves the entry points shown` | path empty | state unchanged, no throw | The boundary; a crash here is a crash on the first tap of the screen |
| 9 | `IdentifyViewModel.startOver returns to the taxon_group entry points` | at candidates | state is `IdentifyEntryPoints`, path empty | §6 S7's `Start over` |
| 10 | `IdentifyViewModel.rewindTo re-opens the couplet at the named step` | path of 4, `rewindTo(1)` | couplet of step 1, path length 1 | "Each tappable to go back" (§4.3) |
| 11 | `DecisionTrail renders one entry per answered couplet` | path of 3 | 3 entries | The breadcrumb is the trail, not a summary of it |
| 12 | `DecisionTrail states the chosen option label` | step chose "No barbels" | that label on screen, not the question | §4.3 says the answers; a trail of questions cannot be checked against the fish |
| 13 | `DecisionTrail entry tapped rewinds to that couplet` | tap entry 1 of 3 | `rewindTo(1)` observed on the view model | The tappability is the feature, not the rendering |
| 14 | `DecisionTrail is present on the $state terminal state` (loop: `candidates`, `deadEnd`) | each terminal state | trail rendered | "Why am I here?" must be answerable at every node, terminal ones included |
| 15 | `RTL - DecisionTrail mirrors the separator glyph` | `ar`, path of 2 | separator flipped | An unmirrored chevron points back into the text it is meant to leave |
| 16 | `IdentifyViewModel opens at the entry points after the provider is disposed` | walk 3 couplets, dispose, rebuild | `IdentifyEntryPoints` | A silently resumed path describes the previous fish |

```dart
// app/test/domain/key_path_test.dart
import 'package:catchlaw/domain/models/key_path.dart';
import 'package:test/test.dart';

import '../../testing/models/key_fixtures.dart';

void main() {
  group('KeyPath', () {
    test('.backOne removes the last step', () {
      final path = kKeyPathThreeSteps;

      expect(path.backOne().length, 2);
      expect(path.backOne().steps, orderedEquals(kKeyPathThreeSteps.steps.take(2)));
    });

    test('.backOne on an empty path returns an empty path', () {
      expect(const KeyPath.empty().backOne(), const KeyPath.empty());
    });

    test('.rewindTo drops the step it names and every step after it', () {
      expect(kKeyPathFourSteps.rewindTo(1).length, 1);
    });
  });
}
```

```dart
// app/test/ui/identify/decision_trail_test.dart
void main() {
  for (final terminal in <String>['candidates', 'deadEnd']) {
    testWidgets('DecisionTrail is present on the $terminal terminal state', (tester) async {
      await tester.pumpWidget(harness(
        child: IdentifyScreen(initialState: terminalStateFixture(terminal)),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DecisionTrail), findsOneWidget);
    });
  }

  testWidgets('DecisionTrail entry tapped rewinds to that couplet', (tester) async {
    final viewModel = RecordingIdentifyViewModel(path: kKeyPathThreeSteps);
    await tester.pumpWidget(harness(viewModel: viewModel, child: const IdentifyScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DecisionTrailEntry).at(1));

    expect(viewModel.rewoundTo, 1);
  });
}
```

**Run:** `cd app && flutter test test/domain/key_path_test.dart test/ui/identify/` → 17 failures
(row 14 expands to two). If any passes now, that test is wrong.

## Implementation outline

1. `KeyPath` and `KeyStep` in `app/lib/domain/models/key_path.dart`: immutable, const, an unmodifiable
   `List<KeyStep>`, real `==`/`hashCode`. No Flutter import — this file is unit-testable with
   `package:test`, not `flutter_test`.
2. Thread the path through every variant of the sealed state, terminal ones included. A terminal state
   without a path is how "answerable at every node" gets lost in a refactor.
3. `choose` pushes the step *before* resolving the next node, so a dead end still carries the answer
   that produced it.
4. `backOneStep`, `startOver`, `rewindTo` on the view model; each re-resolves the couplet for the node
   the path now ends at, or emits `IdentifyEntryPoints` when the path is empty.
5. `DecisionTrail` — a `Wrap` of `DecisionTrailEntry` widgets separated by a mirrored `LonjaGlyph`,
   then the two controls in a stacked action group. All geometry `EdgeInsetsDirectional` (D-8).
6. Add the three ARB keys to all six files.
7. Re-run the whole `app/` suite: T03's tests must now also see a trail, so update them in this commit
   rather than leaving them asserting the old tree.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 tests pass, and each failed first.
- [ ] `key_path.dart` is at **100% branch coverage** and imports nothing from Flutter.
- [ ] The trail renders on the couplet state and on **both** terminal states — this closes the
      temporary gap T03's definition of done recorded.
- [ ] `Back one step` and `Start over` are `secondary` and `quiet`; neither is a primary, in any state.
- [ ] No `Navigator.push` per couplet exists; S7 occupies exactly one route entry.
- [ ] Nothing about a traversal is written to `user.db`.
- [ ] `grep -rn 'EdgeInsets.only(' app/lib/ui/identify/` returns nothing, and
      `no_directional_geometry.sh app/lib` is clean (D-8).
- [ ] `Icons.` appears nowhere in the trail; the separator is a `LonjaGlyph` with `mirrorInRtl: true`.
- [ ] The provider is auto-disposing and a test proves re-entry starts at the entry points.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh          app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh         app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh           app/lib
tools/gates/no_directional_geometry.sh                                     app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(identify): keep a tappable decision trail with back one step and start over

SPEC §5.2 excludes photo-AI because a key is auditable and a classifier is
not — the user can see why the key landed where it did and can back out one
step. The trail is that claim made real, so it renders on the couplet state
and on both terminal states, and rewindTo drops the step it names so tapping
an entry unmakes that answer rather than stranding the user on a couplet he
has already answered.

The path is ViewModel state, not a Navigator stack: the breadcrumb has to
render as data on screens with no couplet route to pop, tapping the second
of five entries has to be one state change rather than four animated pops,
and a deep key must not bury S1 under six stack entries.

The trail states the answers, not the questions — "Deep-bodied · No barbels
· Forked tail" describes the fish in the hand, which is what "Why am I
here?" means. The provider auto-disposes, so re-entering S7 starts clean
rather than silently resuming a path that described the previous fish.

Task: E14/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
