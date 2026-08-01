# E19/T06 — Haptics that differ

| | |
|---|---|
| **Epic** | E19 — Accessibility, sunlight and glove modes |
| **Branch** | `epic/19-accessibility` (shared) |
| **Commit** | `feat(a11y): make the pass and fail haptics provably different, and fire them once` |
| **Depends on** | T01 (the registry); E10/T02 (`ResultHaptics.announce`, and the 120 ms figure) |
| **Size** | S |
| **Spec** | `SPEC.md` §4.9 "Haptics" row (*distinct patterns for pass and fail; usable without looking*), §3 step 4 (colour **and haptic** reinforcement) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `accessibility-as-code` | Rule 10 — honour `boldText`, and **keep haptics through reduced motion**; and "Pair visual feedback with a haptic so confirmation survives reduced motion and low vision" |
| `lonja-verdict-and-status` | Rule 4 and `references/states-and-signals.md` — why protected and below-minimum are not separated by a third channel here either, and why the screen carries that distinction instead |
| `catchlaw-conventions-index` | Invariant 2 — a haptic is a signal about a statement of fact; a vocabulary of buzzes the fisher has to interpret is an instruction with no words to check |
| `service-boundary-and-native` | Rule 2 — *abstract only what cannot run in `flutter test`* — which is the whole argument for there being no `HapticsService` port in this task |
| `testing-strategy` | Rule 5 (fakes over mocks for code you own) and rule 10 (drive timers with `fakeAsync`, never `pumpAndSettle`) |
| `widget-golden-and-a11y-testing` | `references/harness-and-mediaquery.md` — `disableAnimations` is only meaningful if the app reads it, and `pump(Duration)` rather than `pumpAndSettle` |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.9 "Haptics" row | *Distinct patterns for pass and fail* — and the done condition, *usable without looking* |
| `SPEC.md` | §3 step 4 | The haptic is one of the three reinforcements of the result, alongside the words and the colour |
| `epics/E10-result/T02-the-verdict-panel.md` | "Haptics", rows 19–21 | The patterns already chosen: one `lightImpact` for `.meets`, two `heavyImpact` separated by 120 ms for every adverse category, nothing when there is no stamp. **Cited, not re-argued** |
| `.claude/skills/accessibility-as-code/SKILL.md` | rule 10; "Never state through color alone" | Haptics survive reduced motion; a haptic is a channel independent of sight |
| `.claude/skills/lonja-verdict-and-status/references/states-and-signals.md` | "Why protected cannot be below-minimum in another shade" | The precedent for refusing a third signal: the distinction is legal, and it is carried by words |
| `.claude/skills/widget-golden-and-a11y-testing/references/harness-and-mediaquery.md` | "Driving MediaQuery flags" | `disableAnimations` asserts nothing unless the app reads it — so this task asserts the app does **not** read it for haptics |
| `epics/CONVENTIONS.md` | §9 invariant 2 | A verdict states a fact and never instructs — which constrains what a haptic may encode |

## What this delivers

- `app/test/a11y/support/haptic_log.dart` — `HapticLog`, which installs a mock handler on
  `SystemChannels.platform`, records every `HapticFeedback.vibrate` argument in order, and removes
  itself in `addTearDown`.
- `app/test/a11y/haptics_test.dart` — the distinctness, coverage, reduce-motion, once-per-finding
  and no-stray-haptics rows.
- If row 7 fails: a one-line narrowing in `app/lib/ui/result/` from `select((d) => d.stamp)` to
  `select((d) => d.stamp.category)` on the listener that fires the haptic. The panel's own
  `select` stays as E10 wrote it — the two subscriptions want different granularity and that is the
  finding.

## Why it is built this way

**No `HapticsService` port, and that is the deliberate choice.** `service-boundary-and-native` rule 2
is explicit: abstract only what cannot run in `flutter test`. `HapticFeedback.mediumImpact()` posts a
`MethodCall` on `SystemChannels.platform`, which the test binding intercepts, records and returns
null for — it is inert in a test and fully observable. So an interface plus a live impl plus a fake
would be three files standing between the test and the thing it is asserting, and the test would
then prove that a fake recorded a call rather than that the platform received one. The mock handler
captures the real messages, which is a stronger assertion for less code. `/simplify` would delete the
port; this task never builds it.

**Distinctness is a property, not two examples.** E10/T02 already asserts that `.meets` fires one
`lightImpact` and that an adverse category fires two `heavyImpact`s. Both of those can be true while
the two sequences are identical — a refactor that made `.meets` fire two light impacts would pass
E10's rows one at a time. §4.9 asks for *distinct patterns*, so this task asserts the two sequences
**differ**, and differ **in count** as well as in weight, because weight is the axis a neoprene glove
is worst at resolving and count is the axis it is best at.

**Every category gets a sequence, or a fifth one is silent.** The verdict categories are a sealed set
today. When a fifth arrives — and `lonja-verdict-and-status` rule 2 bans a `default:` arm precisely
so that it fails the build rather than rendering as the previous one — the haptic switch is the one
place a `default: return;` would compile and be invisible. The loop over `VerdictCategory.values`
asserting a non-empty sequence for each is the guard.

**Three adverse categories, one pattern, on purpose.** Protected, closed season and below minimum
are three different legal situations and they share one haptic. A three-way buzz vocabulary would ask
the fisher to *interpret* a pattern with no words attached and nothing to check it against, which is
an instruction in everything but grammar (invariant 2). It is the same argument
`states-and-signals.md` makes for hue: both adverse verdicts print in oxblood, and the distinction
is carried by the glyph, the headline and the table. The haptic says *look at the screen*; the screen
says what happened.

**Once per finding, not once per rebuild.** E09's ruler emits a measurement several times a second.
A listener keyed on the whole stamp fires on every millimetre — 38.1, 38.2, 38.3 — and a buzz per
millimetre is a battery cost, a distraction, and a signal that has stopped meaning anything by the
time the category actually changes. The haptic is therefore keyed on the **category**, which changes
exactly when the answer changes. The panel's own `select` is a different subscription with a
different granularity: it re-renders the number, which is correct, and must not re-announce.

**Reduce motion must not silence it.** `accessibility-as-code` rule 10 says haptics are kept through
reduced motion, and the reason is the product's: a user who turns animations off is often a user for
whom the haptic is doing more work, not less. So the row asserts the pulses still fire under
`disableAnimations: true`, and the 120 ms gap is a fixed `Duration` rather than a value passed
through the motion-token resolution — the one place in this app where a duration is deliberately not
reduced.

**Rejected — re-choosing the pattern.** E10/T02 fixed `lightImpact` × 1 against `heavyImpact` × 2 at
120 ms and said in writing that it is a design choice rather than a measurement. This task asserts
those numbers hold; it does not replace them. Whether 120 ms is felt as two pulses through a wet
neoprene glove cannot be settled by any widget test and is named in the epic's Risks for the E21
device pass.

**Rejected — `HapticFeedback.vibrate()` as the fail pattern.** On Android it is a single long buzz
that is indistinguishable from a notification, which is precisely the confusion the fisher does not
need at 05:40. Count and weight, not duration.

**Rejected — a haptic on the stale bar, on a nav change, or on `+ Add to today`.** The sweep in row
9 exists to keep it that way. A second haptic anywhere on the path teaches the hand that a buzz
means "something happened", after which the verdict buzz means nothing in particular.

## Tests first

Write every row before touching `app/lib/`. Run them. **They must fail** — rows 1, 2, 4, 7 and 9
have no implementation behind them, and rows 3, 5 and 6 fail until the log helper exists. If row 3
passes immediately, that is expected: E10 built it. Rows 1, 2 and 7 are the ones that must be red.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ResultHaptics.announce fires a different sequence for meets than for belowMinimum` | both categories | the two recorded sequences differ | §4.9 asks for *distinct* patterns; E10's rows assert each pattern separately and both can be true while the two are identical |
| 2 | `ResultHaptics.announce fires a different number of pulses for meets than for an adverse category` | both | 1 versus 2 | Weight is the axis a wet neoprene glove resolves worst and count is the one it resolves best — the distinction has to survive the glove, not the bench |
| 3 ×3 | `ResultHaptics.announce fires the adverse sequence for ${category}` | belowMinimum, closedSeason, protected | two `HapticFeedbackType.heavyImpact` calls, identical for all three | Three legal situations, one pattern: a three-way buzz vocabulary is an instruction with no words to check it against (invariant 2) |
| 4 | `ResultHaptics.announce emits a sequence for every VerdictCategory value` | the enum | every value produces at least one call | The haptic switch is the one place a `default: return;` compiles and is silent; a fifth category must not arrive mute |
| 5 | `ResultHaptics.announce separates the two adverse pulses by 120 ms` | belowMinimum, `fakeAsync` | one call, then the second only after 120 ms elapse | A refactor to a 0 ms gap is felt as one pulse and passes every other row here |
| 6 | `ResultHaptics.announce still fires when disableAnimations is true` | adverse, reduce motion on | two calls | `accessibility-as-code` rule 10: haptics are kept through reduced motion, and a user who turned animations off may be relying on this channel more, not less |
| 7 | `Result screen fires no haptic when the measurement changes within the same category` | 38.1 cm → 38.4 cm, both below minimum | zero further calls | The ruler emits several times a second; a buzz per millimetre is a signal that has stopped meaning anything by the time the answer changes |
| 8 | `Result screen fires no haptic when only the theme changes` | same finding, paper → sunlight | zero further calls | The sunlight toggle is one tap from this screen (§4.9); it changes the light, not the law |
| 9 ×27 | `${s.id} ${s.name} fires no haptic on first paint` | every surface except S2 | no `HapticFeedback.vibrate` call | One buzz on the whole path means one thing. A second anywhere teaches the hand that a buzz means "something happened" |

```dart
// app/test/a11y/support/haptic_log.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures the real platform messages `HapticFeedback` posts, rather than a
/// fake's record of a call. The test binding swallows them and returns null, so
/// nothing here needs a service seam.
final class HapticLog {
  HapticLog._(this._calls);

  final List<String> _calls;

  /// The `HapticFeedbackType.*` arguments, in the order they were posted.
  List<String> get pulses => List<String>.unmodifiable(_calls);

  void clear() => _calls.clear();

  static HapticLog install() {
    final List<String> calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add(call.arguments as String);
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    return HapticLog._(calls);
  }
}
```

```dart
// app/test/a11y/haptics_test.dart
import 'package:catchlaw/ui/result/widgets/result_haptics.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/a11y/audited_surfaces.dart';
import '../utils/harness.dart';
import 'support/haptic_log.dart';

void main() {
  testWidgets('ResultHaptics.announce fires a different sequence for meets than for '
      'belowMinimum', (WidgetTester tester) async {
    final HapticLog log = HapticLog.install();

    await ResultHaptics.announce(VerdictCategory.meets);
    final List<String> pass = log.pulses;
    log.clear();

    await ResultHaptics.announce(VerdictCategory.belowMinimum);
    final List<String> fail = log.pulses;

    expect(pass, isNot(equals(fail)),
        reason: 'the pass and fail patterns are identical — "usable without '
            'looking" is not satisfied by one pattern fired twice');
    expect(pass.length, isNot(fail.length),
        reason: 'the sequences differ only in weight; count is what survives a glove');
  });

  testWidgets('ResultHaptics.announce emits a sequence for every VerdictCategory value',
      (WidgetTester tester) async {
    final HapticLog log = HapticLog.install();
    for (final VerdictCategory category in VerdictCategory.values) {
      log.clear();
      await ResultHaptics.announce(category);
      expect(log.pulses, isNotEmpty, reason: '${category.name} is silent');
    }
  });

  testWidgets('Result screen fires no haptic when the measurement changes within the '
      'same category', (WidgetTester tester) async {
    final HapticLog log = HapticLog.install();
    await pumpResultSurface(tester, stamp: kStampBelowMinimumAt(381));
    log.clear();

    await pumpResultSurface(tester, stamp: kStampBelowMinimumAt(384));
    expect(log.pulses, isEmpty,
        reason: 'the haptic is keyed on the stamp rather than on the category, so the '
            'ruler buzzes on every millimetre');
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/a11y/haptics_test.dart` → 1 + 1 + 1 + 1 + 27 failures, with
rows 3, 5 and 6 green once the log helper compiles because E10 built the pattern. If row 1 passes
before anything changes, read the sequences it captured: two identical patterns satisfy both of
E10's rows and neither of §4.9's.

## Implementation outline

1. Write `haptic_log.dart`. Use `addTearDown` to remove the handler — a trailing removal is skipped
   when an `expect` throws, and a leaked mock handler silently swallows the next test's platform
   calls.
2. Write every row. Run. Expect rows 1, 2, 4, 7 and 9 red.
3. Row 4: if a category is silent, add it to the switch in `result_haptics.dart` **exhaustively**,
   with no `default:` arm, so the next category fails the build rather than the test.
4. Row 7: narrow the listener that fires the haptic from `select((d) => d.stamp)` to
   `select((d) => d.stamp.category)`. Leave the panel's own `select` alone — it must still re-render
   38.1 → 38.4, and E10/T02's row 10 asserts it does not re-announce while doing so.
5. Row 9: if a surface fires a haptic on first paint, remove the call rather than allow-listing the
   surface. `HapticFeedback.selectionClick()` on a nav tap is a defensible product decision and it is
   not this product's — one buzz on the path means one thing.
6. Confirm the 120 ms gap is a plain `Duration` and is not routed through the reduced-motion
   resolution (`LonjaMotion.none` would make it zero, and row 5 would then fail for the right
   reason).
7. Re-run the whole `app` suite, including E10's `result_haptics_test.dart`, which must stay green
   unchanged.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 9 rows pass (3 and 9 generated), and rows 1, 2, 4, 7 and 9 failed first.
- [ ] The pass and fail sequences differ in count, not only in weight.
- [ ] The `VerdictCategory` switch in `result_haptics.dart` has no `default:` arm.
- [ ] Exactly one surface in the app fires a haptic, and it is S2.
- [ ] The haptic listener is keyed on the category; the panel's own `select` is unchanged.
- [ ] The 120 ms gap is a literal `Duration`, not a motion token resolved for reduced motion, and a
      comment says why in one line.
- [ ] No `HapticsService`, no provider, no fake — the platform messages are captured directly.
- [ ] E10/T02's `result_haptics_test.dart` still passes without modification.
- [ ] Nothing under `packages/rule_engine/` changed.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh    app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(a11y): make the pass and fail haptics provably different, and fire them once

E10/T02 asserts that meets fires one light impact and that an adverse
category fires two heavy ones. Both rows can be green while the two
sequences are identical, so §4.9's "distinct patterns" is now asserted as a
property: the sequences differ, and they differ in COUNT as well as weight,
because count is the axis a wet neoprene glove resolves and weight is the
one it does not.

The three adverse categories keep one pattern between them. A three-way
buzz vocabulary asks the fisher to interpret a signal with no words
attached, which is an instruction in everything but grammar; the glyph, the
headline and the table carry that distinction, as they do for the hue the
two adverse categories also share.

The haptic listener is keyed on the category rather than the stamp: the
ruler emits several times a second, and a buzz per millimetre has stopped
meaning anything by the time the answer changes. Reduce motion does not
silence it, and a sweep asserts no other surface buzzes at all.

Task: E19/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
