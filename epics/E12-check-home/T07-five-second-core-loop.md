# E12/T07 — The five-second core loop

| | |
|---|---|
| **Epic** | E12 — Check home and the navigation shell |
| **Branch** | `epic/12-check-home` (shared) |
| **Commit** | `test(check): walk the five-second core loop end to end on device` |
| **Depends on** | T02, T03, T04, T05, T06 (the loop needs the whole screen and the launch path) |
| **Size** | L |
| **Spec** | `SPEC.md` §3 (the five steps), §15 step 10 ("first point at which the 5-second target is testable"), §4.2 (manual entry before calibration), §14 (dynamic rows 3 and the `ar` row) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | The loop crosses every layer; invariants 2, 3 and 5 are all asserted at the end of it, and this skill is where the invariant text lives. |
| `lonja-navigation-chrome` | The verdict route suppresses the strip, so the walk must exit by the back affordance and the test must know that is deliberate. |
| `lonja-lists-and-tables` | The recents tile is the first tap; its whole-rect target is what makes the tap survive a wet glove. |
| `state-management-riverpod` | The tally increment after `+ Add to today` arrives through a drift stream, so the test must pump rather than poll. |
| `flutter-performance` | Interpreting the measured elapsed time: what part is frame budget and what part is I/O. |
| `app-startup-and-bootstrap` | The walk starts at a cold launch, so it inherits T06's launch path and must not re-time it differently. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §3, all five steps | The exact walk: open → species → length → result → add to today, one thumb, in sunlight, wearing wet gloves, in under five seconds |
| `SPEC.md` | §15 step 10 | "First point at which the 5-second target is testable" — the sentence this task exists to honour |
| `SPEC.md` | §4.2, "Manual entry" row | Works **before** calibration, so the core loop is complete on first launch |
| `SPEC.md` | §4.1, "Result display" and "Expired-rule handling" rows | A statement of fact plus the numeric margin; an expired rule still evaluates behind the amber bar |
| `SPEC.md` | §14, dynamic row 3 | Complete the full core loop in airplane mode, then repeat with manual entry before ever calibrating |
| `SPEC.md` | §14, final dynamic row | The whole loop in `ar` with RTL: no overflow, the ruler still reads left to right |
| `SPEC.md` | §4.5, "Today's tally" row | The tally is visible on Check without navigating away — which is how the loop closes |
| `.claude/skills/lonja-navigation-chrome/references/nav-anatomy-and-states.md` | "Verdict takeover" | The result route sets `bottomNavigationBar: null`; back is the only exit and must be visible without scrolling |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariants 2, 3, 5 | The banned lexicon; the required `Citation`; expiry adds a bar and nothing else |
| `epics/CONVENTIONS.md` | §5, §6 | Test naming, and that `app/integration_test/` holds device happy paths while helpers must not end in `_test.dart` |
| `epics/DECISIONS.md` | D-3, D-7 | `ar` is the one RTL locale; the engine holds no sentence, so every word in the walk comes from ARB or `content_string` |

## What this delivers

- `app/integration_test/five_second_loop_test.dart` — the walk, in `en` and in `ar`.
- `app/integration_test/harness.dart` — the seeding and driving helper. Not `_test.dart`, per
  `CONVENTIONS.md` §6.
- `app/testing/models/k_loop_fixture.dart` — the fixture: one recent species with a known minimum size,
  one expired rule for the expiry row, and a zone with a bag limit.
- Any wiring defect the walk exposes, fixed in this same commit and named in the commit body.

Nothing else. This task adds a test that can only be written now, and the reason it is an L rather than
an S is that the first honest run of it usually finds one screen too many.

## Why it is built this way

**Measured, not asserted.** Five seconds is a human-factors number: it counts a thumb finding a target
in sunlight, a wet glove sliding, and a person reading a sentence. A driver taps instantly and reads
nothing, so a synthetic five-second assertion would either always pass and prove nothing, or fail on a
loaded CI machine and get deleted. So the test **records** wall-clock elapsed time from the first frame
to the tally increment through `binding.reportData`, and **asserts** the two things a machine can
honestly judge:

1. **Interaction count.** From the first frame to the tally increment the walk takes at most seven
   pointer interactions: the recents tile, `Type instead`, three digit taps, the confirm, and
   `+ Add to today`. With the ruler instead of manual entry it is two taps and one drag. Seven is the
   budget; the actual count is reported. A regression that inserts a confirmation sheet between the
   result and the tally shows up here as an eighth tap, which is exactly the kind of change that
   reviews wave through.
2. **Screen count.** No screen appears between two steps of §3 that §3 does not name. Tapping a recents
   tile lands on the species with its measurement-method diagram; it does not land on a disambiguation
   list first.

**The walk starts cold.** It begins at launch, not at a pumped `CheckScreen`, because §3 step 1 is part
of the loop and because T06's launch path is what makes step 1 free. Anything that regresses the launch
shows up as elapsed time here even though the assertion lives in T06.

**Manual entry before calibration is a separate lane, not a variant.** §4.2 states the requirement and
§14 makes it a dynamic release check: the loop must be complete on a virgin install, before anyone has
held a bank card against the screen. Running it as its own lane is what stops the ruler becoming a
silent prerequisite.

**The expiry lane belongs here.** E10 tested the stale bar on the result screen in isolation. The
loop-level question is different and is the one §14 calls a correctness test rather than a cosmetic
one: with the device clock past a rule's `valid_to`, does the walk still produce a verdict with its
numbers intact, with the amber bar added and nothing else removed? A "no rule recorded" result here is
a failure of invariant 5.

**Back is the exit from the result.** The verdict route suppresses the strip
(`nav-anatomy-and-states.md`), so the walk returns to Check by the back affordance. The test asserts
back is visible without scrolling at `textScaler` 1.0 — the mitigation that makes the takeover
acceptable.

**Rejected: `flutter drive` with a timeline summary as the primary artefact.** It measures frames, not
the job. The frame budget is real and T06 owns it; what this task needs to know is whether a person can
finish the job, and that is taps and screens.

**Rejected: asserting elapsed time against a fixed millisecond budget.** On what device, at what
thermal state, with what else running? The number is recorded per run so a trend is visible; a
threshold would be a fiction with a decimal point.

**Rejected: running the whole matrix of six locales here.** `CONVENTIONS.md` §6 keeps the integration
layer thin, and E20 owns the locale matrix. This task runs `en` and `ar`, because `ar` is the one RTL
locale (D-3) and RTL is the axis that breaks a walk rather than a pixel.

## Tests first

Write every row before touching the harness. Run them. **They must fail** — on a
`five_second_loop_test.dart` with no harness they fail to compile, which counts, but each row must then
fail for its own reason before it passes. If the expiry row passes on the first run, check the fixture:
a rule with no `valid_to` is treated as valid and proves nothing.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `Core loop reaches the species from a cold launch in one tap` | recents seeded | species screen for that id | §3 steps 1–2; the launch target and the first path |
| 2 | `Core loop shows the measurement-method diagram for the species` | on the species screen | the method diagram for the active jurisdiction's rule row | §3 step 3: the diagram is for *this* species, from *this* jurisdiction |
| 3 | `Core loop accepts a manual length before the ruler is calibrated` | `ruler_px_per_mm` null | length accepted, result produced | §4.2 and §14: the loop is complete on a virgin install |
| 4 | `Core loop states the verdict as a fact with the numeric margin` | 38 cm against a 45 cm minimum | the factual statement, both numbers, no imperative | Invariant 2; §5.1 is why the wording is load-bearing |
| 5 | `Core loop shows a citation on the result` | as row 4 | instrument, article, published and checked dates | Invariant 3: an uncited verdict is an opinion |
| 6 | `Core loop adds the catch to today in one tap from the result` | tap `+ Add to today` | a `catch` row written | §3 step 5 |
| 7 | `Core loop increments the tally bar on Check after Add to today` | back to Check | total up by one | §4.5: the count is visible without navigating away — the loop closes |
| 8 | `Core loop exits the result by the back affordance without scrolling` | on the result | back hit-testable at `textScaler` 1.0 without scrolling | The takeover removes four one-tap exits; this is the stated mitigation |
| 9 | `Core loop performs at most seven pointer interactions from the first frame to the tally increment` | full walk | count ≤ 7 | The assertable half of the five-second target |
| 10 | `Core loop reaches the result without a screen SPEC §3 does not name` | full walk | the visited route list equals the expected list | Catches an interstitial that a review would wave through |
| 11 | `Core loop records the elapsed time from the first frame to the tally increment` | full walk | a number in `binding.reportData` | Measured rather than asserted; §15 step 10's target made visible |
| 12 | `Core loop completes with the ruler instead of manual entry` | calibrated fixture | result from a drag, two taps total | Both measurement paths in §3 step 3 |
| 13 | `Core loop shows the amber bar and still produces a verdict when the rule is expired` | clock past `valid_to` | verdict with numbers intact, plus the bar | Invariant 5; §14 calls this a correctness test, not a cosmetic one |
| 14 | `ar - Core loop completes with the app in Arabic` | locale `ar` | every step reachable, no overflow | §14's final dynamic row; `ar` is the one RTL locale (D-3) |
| 15 | `ar - Core loop reads the verdict from app_ar.arb and content_string` | locale `ar` | no English string on the result | D-7: the engine holds no sentence, so this is the proof the app assembled it |
| 16 | `glove - Core loop completes with every target at 56 dp` | glove density | every tapped target ≥ 56 dp | §4.9; the loop must survive the density switch, not just look right |
| 17 | `Core loop completes with no jurisdiction set and reaches the zone picker instead` | unset profile | the walk redirects at the zone chip, nothing crashes | T05's state is on the loop's path for a first-time user |

```dart
// app/integration_test/five_second_loop_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Core loop performs at most seven pointer interactions from the first frame to the '
      'tally increment', (tester) async {
    final loop = await LoopHarness.coldLaunch(tester, fixture: kLoopFixtureRasAlKhaimah);

    await loop.tapRecent(kHamourId);          // 1
    await loop.tapTypeInstead();              // 2
    await loop.typeLength('38');              // 3, 4
    await loop.confirmLength();               // 5
    await loop.tapAddToToday();               // 6

    expect(loop.interactions, lessThanOrEqualTo(7));
  });

  testWidgets('Core loop records the elapsed time from the first frame to the tally increment',
      (tester) async {
    final loop = await LoopHarness.coldLaunch(tester, fixture: kLoopFixtureRasAlKhaimah);
    final stopwatch = Stopwatch()..start();

    await loop.walkToTallyIncrement();
    stopwatch.stop();

    binding.reportData = <String, dynamic>{
      ...?binding.reportData,
      'coreLoopMillis': stopwatch.elapsedMilliseconds,
      'coreLoopInteractions': loop.interactions,
    };
    expect(loop.tallyTotal, 1); // the assertion is that the loop closed, not that it was fast
  });

  testWidgets('Core loop reaches the result without a screen SPEC §3 does not name', (tester) async {
    final loop = await LoopHarness.coldLaunch(tester, fixture: kLoopFixtureRasAlKhaimah);

    await loop.walkToResult();

    expect(loop.visitedRoutes, <String>[
      routes.checkPath,
      routes.speciesPath(kHamourId),
      routes.resultPath(kHamourId),
    ]);
  });

  testWidgets('Core loop shows the amber bar and still produces a verdict when the rule is expired',
      (tester) async {
    final loop = await LoopHarness.coldLaunch(tester, fixture: kLoopFixtureExpiredRule);

    await loop.walkToResult();

    expect(loop.findStaleBar(), findsOneWidget);
    expect(loop.verdictText, contains('45'));   // the minimum is still stated
    expect(loop.verdictText, isNot(contains(l10nEn.noRuleRecorded)));
  });

  // … one test per row above, one behaviour each
}
```

```dart
// app/integration_test/harness.dart  — a helper, deliberately not *_test.dart
class LoopHarness {
  /// Launches the app from a cold start with [fixture] already written to user.db,
  /// counting every pointer interaction and every route the walk visits.
  static Future<LoopHarness> coldLaunch(WidgetTester tester, {required LoopFixture fixture}) async {
    await seedUserDatabase(fixture);
    await app.main();
    await tester.pumpAndSettle();
    return LoopHarness._(tester);
  }

  int get interactions => _interactions;
  List<String> get visitedRoutes => List.unmodifiable(_visited);
}
```

**Run:** on a device, `cd app && flutter test integration_test/five_second_loop_test.dart` → 17
failures. Then with airplane mode on, which is where §14 requires it to pass.

## Implementation outline

1. `k_loop_fixture.dart`: three fixtures — the ordinary walk, the expired rule, and the uncalibrated
   ruler. Each is a set of `user.db` rows plus the reference ids they point at. `k`-prefixed, in
   `app/testing/models/` (`CONVENTIONS.md` §6).
2. `harness.dart`: `coldLaunch`, one method per step of §3, an interaction counter incremented by every
   `tester.tap`/`drag` the harness performs, and a route observer collecting `visitedRoutes`.
3. Write the seventeen rows. Run them. Read the failures — the interesting ones are rows 9 and 10,
   because they are the two that fail when the app works but the loop is longer than §3 says.
4. Fix what the walk exposes, in this commit, and name it in the commit body. If the fix belongs to a
   merged epic, say which one.
5. Report the measured numbers in the PR body: elapsed milliseconds and interaction count for the `en`
   and `ar` lanes.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 rows pass on a physical device, and each failed first.
- [ ] The full walk passes with airplane mode on, Wi-Fi off and cellular off (§14 dynamic row 3).
- [ ] The manual-entry lane passes with `ruler_px_per_mm` null.
- [ ] The expiry lane produces a verdict with its numbers intact plus the amber bar — never a
      "no rule recorded" state.
- [ ] `binding.reportData` carries `coreLoopMillis` and `coreLoopInteractions` for both lanes, and both
      figures are in the PR body.
- [ ] `harness.dart` does not end in `_test.dart` and is not picked up as a test file.
- [ ] No defect the walk exposed is left for a follow-up commit.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
cd app && flutter test integration_test/five_second_loop_test.dart      # on a device
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh   app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh  app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(check): walk the five-second core loop end to end on device

SPEC.md §15 step 10 calls this the first point at which the five-second target
is testable. Five seconds counts a thumb finding a target in sunlight and a
person reading a sentence, and a driver does neither — so the walk measures
elapsed time and reports it, and asserts the two things a machine can judge
honestly: at most seven pointer interactions from the first frame to the tally
increment, and no screen between two steps of §3 that §3 does not name. An
interstitial added later shows up as an eighth tap instead of slipping through
review.

The walk starts at a cold launch because step 1 is part of the loop. It runs
in en and in ar, with manual entry before calibration as its own lane per §4.2
and §14, and with the clock past a rule's valid_to to prove invariant 5 at the
loop level rather than only on the result screen.

Task: E12/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
