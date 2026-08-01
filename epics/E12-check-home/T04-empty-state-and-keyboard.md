# E12/T04 — The empty state, and the keyboard that does not appear

| | |
|---|---|
| **Epic** | E12 — Check home and the navigation shell |
| **Branch** | `epic/12-check-home` (shared) |
| **Commit** | `feat(check): author the no-recents state and leave the search field unfocused` |
| **Depends on** | T02 (the strip and the search field exist) |
| **Size** | S |
| **Spec** | `SPEC.md` §6 S1 "Empty state", §4.3 (S7 reachable from three places) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | Owns the four states and the authored-empty-state rule; the plate, headline, body and action anatomy come from here. |
| `lonja-design-tokens` | The empty state carries no semantic colour — an empty list is not a verdict — and its gaps are spine steps. |
| `catchlaw-conventions-index` | Invariant 2 applies to empty-state copy as much as to a verdict; "Browse by shape" is a label, "Browse for it" would be an instruction. |
| `lonja-navigation-chrome` | The strip stays visible and un-hidden whatever the keyboard does; this task proves the keyboard never comes up unasked. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S1, "Empty state" | First launch with no recents — search field ready but **not auto-focused, so the keyboard does not cover the screen**; Browse and Identify emphasised |
| `SPEC.md` | §6 S1, "Error state" | None possible — the empty state is not an error and must not read as one |
| `SPEC.md` | §4.3, "Entry points" row | S7 is reachable from S1, from S5's empty state and from S6; this was a defect in the first draft |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Precedence", "Empty" | Empty is a body, not a bar; the plate/headline/body/action anatomy; the banned copy list |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Golden coverage matrix", lanes 6 and 7 | The two lanes reviewers skip, and the reason to assert on the headline text rather than only on pixels |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rule 6 | `SizedBox.shrink()` or a bare `Center(child: Text('No data'))` is a defect and fails the gate |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "The 4pt spacing spine" | `s5` between blocks, `s6` between sections |
| `epics/CONVENTIONS.md` | §6 | Golden files live next to their test file; `flutter_test_config.dart` loads the fonts |
| `epics/DECISIONS.md` | D-3 | Six locales; the `ar` lane is the RTL lane, and it is the only one |

## What this delivers

- `app/lib/ui/check/widgets/check_empty_state.dart` — the authored no-recents state.
- Changes to `app/lib/ui/check/check_screen.dart` — the empty branch of the `AsyncValue` switch, and
  `autofocus: false` stated explicitly on the search field with the reason in a doc comment.
- `app/lib/l10n/app_*.arb` × 6 — `checkNoRecentsHeadline`, `checkNoRecentsBody`.
- `app/test/ui/check/check_empty_state_test.dart`.
- `app/test/ui/check/goldens/check_empty_en.png`, `app/test/ui/check/goldens/check_empty_ar.png`.

## Why it is built this way

**The keyboard is the whole point.** A search field that takes focus on the first frame raises the
software keyboard, which on a 640 dp screen covers roughly the bottom 280 dp — exactly the bottom third
where §4.9 puts the primary actions, and exactly where Browse by shape and Identify this fish sit. A
first-time user with no recents would see a keyboard and a field, and the two actions that are the
answer for someone who cannot name the fish would be hidden behind it. `SPEC.md` §6 S1 states the rule
and states the reason; this task makes it a test so that a later "polish" commit cannot quietly add
`autofocus: true`.

**The empty state is not an error.** §6 S1 says no error state is possible on this screen. Zero recents
on first launch is the expected condition, so the state uses no semantic colour, no warning glyph and
no apology. `the-four-states.md` bans "Oops", exclamation marks and mascots outright, and the headline
states the absence as a fact.

**Two emphasised actions, and why that is not a rule violation.**
`the-four-states.md` requires an empty state to carry exactly one primary action and calls two a
defect. `SPEC.md` §6 S1 emphasises **two**: Browse by shape and Identify this fish. SPEC is
authoritative for the product, and the skill's rule binds a **list's** empty body — the state that
replaces rows. S1's empty state is the screen's, not a list's, and the two actions are not competing:
they are the two answers to the two reasons a fisher has no recents, which is that they have never used
the app or that they cannot name what is in the bin. This is stated here rather than resolved silently;
if the reading is wrong it belongs in `DECISIONS.md` as a new entry, not in a task file.

**The search field stays on screen in the empty state.** §6 S1 says "search field ready". Ready means
present, tappable and hinted — a user who *does* know the name must not have to find a different
control. Only the focus is withheld.

**Rejected: rendering nothing when recents are empty.** That is the exact defect
`lonja-lists-and-tables` rule 6 exists to kill, and the one `check_lonja_lists.sh` check 3 looks for. A
blank frame at sea is indistinguishable from a crash, and the next move is a reinstall that destroys a
trip log held on no other device.

**Rejected: an onboarding sheet on first launch.** §3 step 1 forbids it in as many words: no splash, no
login, no onboarding, no what's-new. The empty state *is* the onboarding, and it costs no taps.

**Rejected: keeping the empty state after the first species is used.** It is a state, not a mode. One
test asserts the strip returns.

## Tests first

Write every row before touching `check_empty_state.dart`. Run them. **They must fail.** If the
"does not focus" row passes before the field is authored, the finder is not finding the field — fix the
finder first.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `CheckScreen shows the no-recents state when the recents query returns zero rows` | fake returns `[]` | headline and body present | The state exists at all; rule 6's defect is rendering nothing |
| 2 | `CheckScreen keeps the search field visible in the no-recents state` | zero rows | field found and hit-testable | "Search field ready" means present, not merely defined |
| 3 | `CheckScreen leaves the search field unfocused on the first frame` | zero rows, one `pump` | `primaryFocus` is not the field's node | The headline rule of this task |
| 4 | `CheckScreen leaves the software keyboard closed on the first frame` | zero rows, one `pump` | `tester.testTextInput.isVisible` is false | The keyboard covers the bottom third where Browse and Identify live |
| 5 | `CheckScreen focuses the search field when the user taps it` | tap the field | field's node has focus, keyboard visible | Proves row 3 is a decision and not a broken field |
| 6 | `CheckScreen emphasises Browse by shape and Identify this fish in the no-recents state` | zero rows | both rendered as primary actions | §6 S1's empty state names both |
| 7 | `CheckScreen keeps Browse and Identify in the bottom third in the no-recents state` | 360×640, zero rows | centres below `height * 2 / 3` | The empty-state block must not push them up out of thumb reach |
| 8 | `CheckScreen shows no error styling in the no-recents state` | zero rows | no `verdictFail`, no warning glyph | §6 S1: no error state is possible here |
| 9 | `CheckScreen shows the recents strip again once a species has been used` | `[]` then one row | strip replaces the empty state | It is a state, not a mode |
| 10 | `CheckScreen states the absence without an imperative or an exclamation mark` | zero rows | copy free of the banned lexicon and of `!` | Invariant 2, and `the-four-states.md`'s copy ban |
| 11 | `ar - CheckScreen renders the no-recents headline from app_ar.arb` | locale `ar` | Arabic headline | D-3; a missing key falls back to English inside the one screen a first-time user reads |
| 12 | `CheckScreen matches the no-recents golden` | `en`, paper theme | golden | Lane 6 — the lane reviewers skip, where an unauthored state renders as a blank frame |
| 13 | `ar - CheckScreen matches the no-recents golden` | `ar`, paper theme | golden | Lane 7 — RTL, and the only RTL locale in this product (D-3) |

```dart
// app/test/ui/check/check_empty_state_test.dart
import 'package:catchlaw/ui/check/check_screen.dart';
import 'package:catchlaw/ui/check/widgets/check_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/harness.dart';

void main() {
  testWidgets('CheckScreen leaves the search field unfocused on the first frame', (tester) async {
    await pumpCheck(tester, recents: const []);
    await tester.pump();

    final node = Focus.of(tester.element(find.byKey(const ValueKey('check.search'))));
    expect(node.hasFocus, isFalse);
    expect(WidgetsBinding.instance.focusManager.primaryFocus?.hasFocus ?? false, isFalse);
  });

  testWidgets('CheckScreen leaves the software keyboard closed on the first frame', (tester) async {
    await pumpCheck(tester, recents: const []);
    await tester.pump();

    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('CheckScreen focuses the search field when the user taps it', (tester) async {
    await pumpCheck(tester, recents: const []);
    await tester.tap(find.byKey(const ValueKey('check.search')));
    await tester.pump();

    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('CheckScreen states the absence without an imperative or an exclamation mark',
      (tester) async {
    await pumpCheck(tester, recents: const []);

    final copy = tester
        .widgetList<Text>(find.descendant(
            of: find.byType(CheckEmptyState), matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .join(' ');
    expect(copy, isNot(contains('!')));
    for (final banned in const ['keep', 'return', 'release', 'discard', 'throw']) {
      expect(copy.toLowerCase(), isNot(contains(banned)));
    }
  });

  testWidgets('CheckScreen matches the no-recents golden', (tester) async {
    await pumpCheck(tester, recents: const [], locale: const Locale('en'));

    await expectLater(
      find.byType(CheckScreen),
      matchesGoldenFile('goldens/check_empty_en.png'),
    );
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/ui/check/check_empty_state_test.dart` → 13 failures. If any
passes now, the test is wrong. Generate the two goldens only after the widget exists and the other
eleven rows are green — a golden written against an unauthored state records a blank frame and passes
review far too easily.

## Implementation outline

1. `check_empty_state.dart`: engraved plate, serif headline, `onSurfaceMuted` body, then the two
   actions. No semantic colour anywhere in the subtree.
2. `check_screen.dart`: in the `AsyncValue` switch, `AsyncData(:final value) when value.isEmpty` maps
   to `CheckEmptyState` and the search field stays above it (`FLUTTER_GUIDE.md` Part 5.2's exhaustive
   switch).
3. State `autofocus: false` on the field explicitly, with a one-line doc comment naming §6 S1. The
   default is already false; writing it down is what stops it being changed by someone who thinks it
   was an oversight.
4. Add `checkNoRecentsHeadline` and `checkNoRecentsBody` to all six ARB files. Copy states the absence:
   the headline names what is not there, the body says the recents strip fills as species are checked
   and that nothing is fetched.
5. Run the eleven behaviour rows green, then generate the two goldens on Linux CI
   (`CONVENTIONS.md` §6: the matrix is generated and verified on Linux only).

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 13 tests pass, and each of the eleven behaviour rows failed first.
- [ ] `autofocus: false` appears explicitly on the search field with the spec reference beside it.
- [ ] No `SizedBox.shrink()` and no bare `Center(child: Text(...))` on the empty path.
- [ ] The empty state carries no `verdictPass`/`verdictFail`/`verdictWarn` and no warning glyph.
- [ ] Both goldens are committed next to the test file, and both assert the headline text as well as
      the pixels.
- [ ] The two ARB keys exist in all six locales (D-3).
- [ ] `check_lonja_lists.sh` reports no missing empty state for `check_screen.dart`.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh  app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh    app/lib
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
feat(check): author the no-recents state and leave the search field unfocused

A field that takes focus on the first frame raises the keyboard over roughly
the bottom 280 dp of a 640 dp screen — exactly where SPEC.md §4.9 puts the
primary actions, and exactly where Browse by shape and Identify this fish sit.
For the one user who has no recents, that hides the two actions that are the
answer to not being able to name the fish. §6 S1 states the rule and its
reason; autofocus: false is now written down and tested so it cannot be
"fixed" later.

The state itself is authored, not blank: a plate, a headline that states the
absence as a fact, a body, and the two actions §6 S1 emphasises. It carries no
semantic colour and no warning glyph, because §6 S1 says no error state is
possible on this screen.

Two emphasised actions is a deliberate departure from the one-action rule in
the-four-states.md, which binds a list's empty body rather than a screen's;
the reasoning is in the task file rather than left implicit.

Task: E12/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
