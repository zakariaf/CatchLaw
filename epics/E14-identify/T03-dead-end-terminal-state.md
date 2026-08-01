# E14/T03 — The dead end is a terminal state

| | |
|---|---|
| **Epic** | E14 — The identification key |
| **Branch** | `epic/14-identify` (shared) |
| **Commit** | `feat(identify): render a null next_node_id as a terminal state, not an error` |
| **Depends on** | T01 (the traversal), T02 (the sealed state's other terminal variant) |
| **Size** | S |
| **Spec** | `SPEC.md` §4.3 row "Dead ends", §6 S7 "Terminal states", §7.1 `key_option.next_node_id` |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | `references/the-four-states.md` owns the difference between an authored absence and an error. The dead end is neither `loading` nor `error`, and getting that wrong is the defect this task exists to prevent |
| `lonja-buttons` | Rule 1 (one primary per screen) against §6 S7's two routes — this task resolves that with the variant ladder, not with two primaries |
| `lonja-icons-and-plates` | Rule 10: a terminal state gets a rule, one 44 px mark and one sentence — never an illustration, never a mascot |
| `catchlaw-conventions-index` | Invariant 2 — the two actions are imperatives about the app's own behaviour, which is the approved register, and never about the fish |
| `state-management-riverpod` | The third variant of the sealed state, and why the exhaustive switch must already know about it |
| `accessibility-as-code` | The terminal state is announced; its two actions carry real labels and meet the target floor |
| `widget-golden-and-a11y-testing` | The lane that catches an unauthored empty state — a blank golden passes review far too easily |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.3 row "Dead ends" | "A couplet may legitimately lead nowhere"; `key_option.next_node_id` is nullable; S7 renders the dead-end state |
| `SPEC.md` | §6 S7 "Terminal states" | The exact sentence: "No match. Browse by shape or search by name." |
| `SPEC.md` | §7.1 `key_option` | The column comment in the schema itself: `next_node_id INTEGER REFERENCES key_node(id), -- NULL = dead end (S7 terminal state)` |
| `SPEC.md` | §6 S5, §6 S6 | The two screens the dead end routes to, and what they are called |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Precedence", "Empty", "Error" | `error` means the read failed; a dead end is a successful read. Empty-state anatomy: plate/mark, headline, body, exactly one primary |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rules 6, 7 | Every list that can be empty ships an authored state; a blank frame is the defect |
| `.claude/skills/lonja-buttons/SKILL.md` | rules 1, 2, 3 | One primary; verb phrases naming what happens; never an instruction about the fish |
| `.claude/skills/lonja-buttons/references/button-anatomy.md` | "Label wording" | The approved corpus, which already contains `Browse by shape` verbatim |
| `.claude/skills/lonja-icons-and-plates/SKILL.md` | rule 10 | One 44 px `LonjaIconSize.mark` glyph in `ink-faint`, no `assets/illustrations/` |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariant 2 | The banned lexicon is about the fish; app-behaviour verbs are not in it |
| `FLUTTER_GUIDE.md` | §7.2, §8.1, §6.1 | Sealed classes and the exhaustive switch; widget classes rather than helpers; test naming |
| `epics/DECISIONS.md` | D-3 | The headline, body and both labels land in all six ARB files |

## What this delivers

- `app/lib/ui/identify/view_models/identify_state.dart` — the `IdentifyDeadEnd` variant, which
  completes the sealed set and makes the screen's `switch` exhaustive without a `default`.
- `app/lib/ui/identify/view_models/identify_view_model.dart` — `choose` emits `IdentifyDeadEnd` on a
  null `next_node_id`, and on the content defect described below.
- `app/lib/ui/identify/widgets/key_dead_end.dart` — the authored terminal state: one 44 px mark, a
  headline, one body line, one `LonjaButton.primary` (`Browse by shape` → S6) and one
  `LonjaButton.secondary` (`Search by name` → S5).
- `app/lib/l10n/app_{ar,en,es,gl,ca,pt_BR}.arb` — `identifyNoMatchHeadline`, `identifyNoMatchBody`,
  `actionSearchByName`. `actionBrowseByShape` already exists from E08's S5 empty state — reuse it
  rather than adding a second key with the same value.
- Tests: `app/test/ui/identify/key_dead_end_test.dart` and additions to
  `app/test/ui/identify/identify_view_model_test.dart`.

## Why it is built this way

**A dead end is a successful read, so it is not the error state.** `the-four-states.md` is explicit:
`error` means the read failed — a corrupt asset database, a failed open — and it is drawn in oxblood
with a diagnostic code and a retry. A null `next_node_id` is none of those. The query succeeded, the
content is correct, and the honest answer is that this branch of the key does not resolve for the
specimen in hand. Drawing it in oxblood would tell the fisher the app is broken; offering him a
`Retry` would invite him to press a button that re-reads the same row and produces the same answer.
Neither is true and both cost trust the app cannot rebuild offline.

**Two routes, one primary.** §6 S7 offers "Browse by shape or search by name", and `lonja-buttons`
rule 1 allows one `primary` per screen — `the-four-states.md` goes further and calls two competing
actions in an empty state a defect. Both are satisfied by the variant ladder rather than by dropping a
route: `Browse by shape` is `primary` because a fish in the hand has a shape and no name, which is the
situation that got the user here; `Search by name` is `secondary`. Nothing is removed, and the eye
still lands on one thing.

**The dead end is not an error, and it is also not a trap.** This task gives it two ways out of the
key. T04 adds the third and most important one — `Back one step` — because §5.2's argument for a key
over a classifier is that the user can back out one step, and a terminal state that can only be left
by leaving the key entirely does not honour it. Until T04 lands, the system back gesture and the two
routes are the exits; the DoD below records that this is temporary.

**A question-less node with no candidates lands here too.** §7.1 defines a leaf as "a node with no
question and >= 1 candidate species". Content that produces a question-less node with zero
`key_leaf_species` rows violates that, and the UI's only two honest options are a blank frame or a
stated terminal state. `lonja-lists-and-tables` rule 6 forbids the first. So the same authored state
renders, and the content defect is caught by the content build rather than by a fisher looking at
nothing.

**Rejected: an oxblood banner or a diagnostic code.** Both were considered for the content-defect
path, on the grounds that it *is* a defect. Rejected because the fisher cannot act on it and cannot
report it — there is no network, and `catchlaw-conventions-index` rule 11 forbids inventing a channel.
The person who needs to know is the content author, and the place that tells them is the build.

**Rejected: an illustration.** `lonja-icons-and-plates` rule 10 bans spot art in a terminal state, and
the reason is specific to this product: the engraved plates are legal evidence for the identification a
verdict rests on, and spending that visual vocabulary decoratively on "no match" devalues it exactly
where it does real work. One 44 px mark, `ink-faint`, above a rule.

**On the copy.** The headline and both labels come from published sources: §6 S7 gives the sentence,
and `Browse by shape` is verbatim in the approved label corpus. The one body line that
`the-four-states.md` requires is **not** in `SPEC.md`. It ships as an ARB key and goes through the same
native-speaker review as every other Tier-1 string (§9.2 point 3); it is not invented at the keyboard
and no second sentence is added beyond it.

## Tests first

Write every row before touching a production file. Run them. **They must fail.** A row that passes
before the implementation exists is testing nothing.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `IdentifyViewModel.choose emits a dead end when next_node_id is null` | option with null `nextNodeId` | state is `IdentifyDeadEnd` | The §7.1 column comment made executable — this is the whole feature |
| 2 | `IdentifyViewModel.choose emits a dead end when a question-less node holds no candidates` | leaf node, zero `key_leaf_species` rows | state is `IdentifyDeadEnd` | A content defect must land on an authored state, never on a blank frame |
| 3 | `KeyDeadEnd states the no-match headline` | dead-end state | the §6 S7 headline is on screen | The state is authored, not empty; a blank golden passes review too easily |
| 4 | `KeyDeadEnd builds one primary action and one secondary action` | dead-end state | exactly one primary, exactly one secondary | §6 S7's two routes against `lonja-buttons` rule 1 |
| 5 | `KeyDeadEnd opens browse by shape from the primary action` | tap primary | S6 pushed | The route the fisher with a shape and no name actually needs |
| 6 | `KeyDeadEnd opens species search from the secondary action` | tap secondary | S5 pushed | The second route §6 S7 names |
| 7 | `KeyDeadEnd builds no retry action` | dead-end state | no retry label anywhere in the tree | A retry re-reads the same row for the same answer and implies the app failed |
| 8 | `KeyDeadEnd renders no oxblood tone` | dead-end state | no oxblood colour in the rendered tree | Oxblood means the fish fails a rule; here nothing failed but the branch |
| 9 | `KeyDeadEnd renders one mark and no illustration` | dead-end state | one 44 px glyph, no `Image` widget | `lonja-icons-and-plates` rule 10 — plates are evidence, not decoration |
| 10 | `ar - KeyDeadEnd states the no-match headline in ar` | `ar` locale | the `ar` ARB value | D-3: the state ships in six locales or it does not ship |

```dart
// app/test/ui/identify/key_dead_end_test.dart
import 'package:catchlaw/ui/identify/widgets/key_dead_end.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/harness.dart';

void main() {
  testWidgets('KeyDeadEnd builds one primary action and one secondary action', (tester) async {
    await tester.pumpWidget(harness(child: const KeyDeadEnd()));

    final buttons = tester.widgetList<LonjaButton>(find.byType(LonjaButton)).toList();
    expect(buttons.where((b) => b.variant == LonjaButtonVariant.primary), hasLength(1));
    expect(buttons.where((b) => b.variant == LonjaButtonVariant.secondary), hasLength(1));
  });

  testWidgets('KeyDeadEnd renders one mark and no illustration', (tester) async {
    await tester.pumpWidget(harness(child: const KeyDeadEnd()));

    expect(find.byType(LonjaIcon), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('ar - KeyDeadEnd states the no-match headline in ar', (tester) async {
    await tester.pumpWidget(harness(locale: const Locale('ar'), child: const KeyDeadEnd()));

    expect(find.text(arNoMatchHeadline), findsOneWidget);
  });
}
```

```dart
// app/test/ui/identify/identify_view_model_test.dart  (additions)
test('IdentifyViewModel.choose emits a dead end when next_node_id is null', () async {
  final container = harnessContainer(
    repository: FakeKeyRepository.withCouplet(kKeyCoupletTailShape),
  );
  final viewModel = container.read(identifyViewModelProvider.notifier);

  await viewModel.choose(kKeyOptionDeadEnd);

  expect(container.read(identifyViewModelProvider).valueOrNull, isA<IdentifyDeadEnd>());
});
```

**Run:** `cd app && flutter test test/ui/identify/` → 10 failures. If any passes now, that test is
wrong.

## Implementation outline

1. Add `IdentifyDeadEnd` to the sealed state. The screen's `switch` becomes exhaustive with no
   `default` clause — if the analyser stops complaining about a missing case before this task, a
   `default` was added somewhere and it must come out (`FLUTTER_GUIDE.md` §7.2).
2. In `choose`: a null `nextNodeId` short-circuits to `IdentifyDeadEnd` without a repository call —
   there is nothing to fetch. A question-less node whose `candidatesFor` returns an empty list takes
   the same branch.
3. `KeyDeadEnd` — a `StatelessWidget` class in its own file: `LonjaRule`, 24dp gap, one
   `ExcludeSemantics`-wrapped 44 px mark, headline, body, then the action column with 8dp separation
   (12dp in glove mode).
4. Wire the two routes through the same router E12 owns; do not push with a bare `Navigator` route
   built at the call site.
5. Add the three ARB keys to all six files. Check first whether E08 already added
   `actionBrowseByShape` for S5's empty state — reuse it.
6. Re-run the whole `app/` suite; the exhaustive switch means T01's and T02's screen tests must still
   pass unchanged.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 10 tests pass, and each failed first.
- [ ] The screen's state `switch` has no `default` clause and no `_` fall-through.
- [ ] The dead-end path constructs no `Failure`, logs nothing, and shows no diagnostic code.
- [ ] No oxblood token, no retry action and no `CircularProgressIndicator` appears in
      `key_dead_end.dart`.
- [ ] Exactly one primary and one secondary action; both labels are verb phrases from ARB, and neither
      says anything about the fish (invariant 2).
- [ ] `identifyNoMatchHeadline`, `identifyNoMatchBody` and `actionSearchByName` exist in all six ARB
      files (D-3), and no duplicate of `actionBrowseByShape` was introduced.
- [ ] **Known and temporary:** the dead end has no `Back one step` until T04 lands. T04's definition of
      done carries the assertion that it does; do not close this epic without it.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh         app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh         app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh           app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh          app/lib
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
feat(identify): render a null next_node_id as a terminal state, not an error

SPEC §7.1 writes the comment into the schema itself — NULL = dead end (S7
terminal state) — and SPEC §4.3 says a couplet may legitimately lead
nowhere. The read succeeded, so this is not the error state: no oxblood, no
diagnostic code, no retry that would re-read the same row for the same
answer and imply the app had failed.

SPEC §6 S7 offers two routes and lonja-buttons allows one primary, so the
ladder resolves it rather than dropping a route: Browse by shape is primary
because a fish in the hand has a shape and no name, Search by name is
secondary. A question-less node with no candidate rows takes the same state,
because the alternative is a blank frame and a blank frame reads as a crash
to a fisher with no signal.

Task: E14/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
