# E21/T04 — The clock moved forward past `valid_to`

| | |
|---|---|
| **Epic** | E21 — Offline verification and release readiness |
| **Branch** | `epic/21-release` (shared) |
| **Commit** | `test(check): keep the finding intact when the device clock passes valid_to` |
| **Depends on** | T02 (the integration harness and the exercise script) |
| **Size** | M |
| **Spec** | `SPEC.md` §14 dynamic row 16; §7.3 (expiry does not delete); §4.7; §6 S2 and D3 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | Invariant 5 in `references/product-invariants.md` — the stale-versus-absent matrix, which is precisely what this row tests, plus the edge cases table |
| `catchlaw-reference-database` | Rule 8: the catch row denormalises `citation_text` and `content_version`, so a finding recorded under an expired rule must keep its own numbers rather than re-derive them |
| `service-boundary-and-native` | Rule 8: "now" has exactly one source, injected via `clockProvider`; a `DateTime.now()` reachable from a view or notifier makes this test unwritable |
| `testing-strategy` | Rule 1 and rule 2: assert at the cheapest tier that can carry the behaviour, and pin time with `withClock(Clock.fixed(…))` rather than by sleeping |
| `catchlaw-offline-guarantee` | Rule 11: there is no refresh, no "check for updates" and no retry. The expiry surface may not grow one, and this test is where that would first be attempted |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §14 dynamic row 16 | Both assertions, and the sentence that a "no rule recorded" result is a failure |
| `SPEC.md` | §7.3 | The resolution algorithm: `valid_to` is **not** filtered on; `is_expired = (valid_to IS NOT NULL AND valid_to < date)`; and the paragraph explaining that the first draft's filter made every annual instrument vanish on its expiry day |
| `SPEC.md` | §7.1 | The `rule.valid_to` column and its comment — expiry does not delete |
| `SPEC.md` | §4.7 | Trust and currency: a verdict plus a warning, never a withheld verdict |
| `SPEC.md` | §6 S2, "Dialogs" | The result banner and the amber expiry bar on S2; D3 is a separate, per-session-dismissable dialog and is not the bar |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | "5 — Stale beats absent", "Review checklist" item 5 | The fresh/expired matrix column by column, the bar copy, and the three edge cases |
| `.claude/skills/catchlaw-conventions-index/SKILL.md` | rule 5, "Stale beats absent" | Expiry is a flag on the pack, never a branch in the flow |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rule 8 | Why the recorded catch keeps its own numbers |
| `service-boundary-and-native` → `SKILL.md` (Flutter-Skills plugin) | rule 8 | `clockProvider`, `Clock.fixed`, and the ban on `DateTime.now()` |
| `epics/CONVENTIONS.md` | §9 invariant 5 | The invariant no task may weaken |
| `epics/DECISIONS.md` | D-7 | The engine returns `isExpired` as a flag; the app owns the bar's wording |

## What this delivers

- `app/integration_test/expiry_clock_forward_test.dart` — the device-tier case: a species whose
  governing rule carries a `valid_to`, evaluated with the app's clock pinned past that date, asserting
  the bar **and** the finding **and** the numbers.
- `app/test/features/result/expired_rule_finding_test.dart` — the same behaviour at the widget tier,
  where it is cheap enough to run on every commit (`testing-strategy` rule 1). The integration case
  exists because §14 requires it on hardware; the widget case exists so a regression is caught in CI
  rather than at the next release.
- `app/integration_test/harness/clock.dart` — the helper that pins the app's `clockProvider` for an
  integration run. Not `_test.dart` (`CONVENTIONS.md` §6).
- `docs/release/clock-tests.md` — the manual device procedure, shared with T05: which rule id is used,
  how to move the system clock, what to observe, and how to restore automatic time afterwards.
- `docs/release/<version>/evidence/expiry-forward.png` — the screenshot the checklist row points at.

## Why it is built this way

**This is the row that fails silently if it is written the obvious way.** The obvious test asserts that
an amber bar appeared. That assertion passes on a build where the resolver filtered the expired rule
out, the species fell through to "no rule recorded", and the bar rendered anyway because the pack is
stale. §14 anticipates that exact outcome and calls it a failure. So the test asserts three things
together: the bar is present, a finding for **that rule** is present, and the finding's numbers are the
ones the rule carries.

**"Numbers intact" is asserted as literal values, not as "a number is shown".** §7.3's finding
precedence puts `min_size_mm` in the headline for a size rule, so the assertion is on the measured
length and the minimum — both, as they appear. A test that asserts "some digits are visible" passes on
a screen showing the wrong minimum, which is the failure that would cost a fisher a fine.

**The verdict wording must be byte-identical to the fresh-pack run.** `product-invariants.md`'s matrix
is explicit: on an expired pack the verdict stamp is "shown, unchanged wording and colour", and the only
added chrome is the bar. So the test evaluates the same species and length twice — once with the clock
before `valid_to`, once after — and asserts the rendered statement string is equal. That converts
"unchanged" from a claim into an assertion, and it catches the plausible regression where somebody
softens the wording on an expired rule to be helpful.

**The bar is not the D3 dialog.** §6's dialog inventory lists D3 "Content expired (amber, dismissable
per session)". `product-invariants.md` says the `StaleRuleBar` is **not** dismissable, "because it is a
fact about the data, not a notice". These are two different surfaces and E10 built both; this task
asserts the bar, and asserts separately that dismissing D3 does not remove the bar. Conflating them
would let a per-session dismissal hide the permanent fact.

**Time is injected, never slept.** `service-boundary-and-native` rule 8 puts "now" behind
`clockProvider`, so the widget tier pins it with `Clock.fixed` and the integration tier overrides the
provider. The **manual** row is the one that moves the real system clock, because that is what §14 asks
for and because an injected clock cannot catch a code path that reached `DateTime.now()` directly. The
two are complementary: the automated tests catch regressions cheaply, and the device run is the only
thing that proves no such direct call survives.

**Rejected: asserting only the bar.** Named here because it is what this task will decay into if the
reason is not written down. §14 spells the failure out; so does §7.3's paragraph about the first draft.

**Rejected: faking the resolver.** A stub that returns an expired finding would make every assertion
pass while testing the stub. The test drives the real `reference.db` content shipped in the build, and
names the rule id it depends on so the content authoring in E22 cannot retire it without failing here.

**Rejected: computing the pinned date from `DateTime.now()`.** The test would change behaviour with the
calendar. The pinned instants are absolute and derived from the chosen rule's `valid_to`, which is a
literal in the shipped content.

## Tests first

Write every row before touching the harness. Run them. **They must fail** — the widget rows because
`expired_rule_finding_test.dart` has no harness to build the screen with a pinned clock, the integration
rows because `harness/clock.dart` does not exist. If row 2 passes now, the test is wrong: the most
likely cause is that it is asserting on a `Finding` object rather than on rendered text, which would
pass on a screen that never displays it.

`kRuleWithValidTo` is the fixture constant naming the chosen rule id, in `app/testing/models/`
(`CONVENTIONS.md` §6).

| # | Test name | Tier | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `Result screen shows the stale rule bar when the clock is past valid_to` | widget | bar present | §14 row 16 clause (a). Necessary but nowhere near sufficient |
| 2 | `Result screen shows the finding when the clock is past valid_to` | widget | finding row rendered | §14 row 16 clause (b). This is the assertion that fails on a build that filtered the rule out — the whole point of the task |
| 3 | `Result screen states the measured length and the minimum when the clock is past valid_to` | widget | both literals present | "Numbers intact" means these numbers. A finding with the wrong minimum still renders as a finding |
| 4 | `Result screen renders no empty state when the clock is past valid_to` | widget | the "no rule recorded" string absent | The failure §14 names by name. Asserting its absence is not redundant with row 2 — a screen can show both a finding and a fall-through message |
| 5 | `Result screen keeps the verdict wording identical before and after valid_to` | widget | strings equal | `product-invariants.md`: unchanged wording and colour. Catches a well-meaning softening of the statement on an expired rule |
| 6 | `Result screen carries its citation when the clock is past valid_to` | widget | citation footnote present | Invariant 3: every result carries a required `Citation`. Expiry is exactly where a nullable slot would first show up |
| 7 | `Result screen keeps the stale rule bar after D3 is dismissed` | widget | bar still present | §6 makes D3 dismissable per session; `product-invariants.md` makes the bar non-dismissable. One must not take the other with it |
| 8 | `Result screen disables no control when the clock is past valid_to` | widget | every action still enabled | Invariant 5 forbids gating, disabling and erroring. A disabled "add to tally" would be a silent amputation of the core loop |
| 9 | `Result screen offers no refresh or update action when the clock is past valid_to` | widget | no such affordance | `catchlaw-offline-guarantee` rule 11. Expiry is the one screen where somebody will want to add "Update the app" |
| 10 | `Check flow produces a finding with intact numbers when the device clock is past valid_to` | integration | finding and both literals | §14 row 16 end to end on hardware, through the real `reference.db` |
| 11 | `ar - Result screen shows the stale rule bar and the finding when the clock is past valid_to` | integration | both present | The bar's copy carries a date, and dates are the surface where §9.3's numeral resolution breaks first. E20 hardened RTL; this is the expiry lane through it |

```dart
// app/test/features/result/expired_rule_finding_test.dart
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/rules.dart'; // kRuleWithValidTo

void main() {
  // One day after the rule's own valid_to, derived from the shipped content — never from now().
  final DateTime afterExpiry = kRuleWithValidTo.validTo!.add(const Duration(days: 1));
  final DateTime beforeExpiry = kRuleWithValidTo.validTo!.subtract(const Duration(days: 1));

  testWidgets('Result screen shows the finding when the clock is past valid_to', (WidgetTester t) async {
    await withClock(Clock.fixed(afterExpiry), () async {
      await t.pumpWidget(await resultHarness(rule: kRuleWithValidTo, lengthCm: 38));
      expect(find.byType(FindingRow), findsOneWidget);
    });
  });

  testWidgets('Result screen states the measured length and the minimum when the clock is past valid_to',
      (WidgetTester t) async {
    await withClock(Clock.fixed(afterExpiry), () async {
      await t.pumpWidget(await resultHarness(rule: kRuleWithValidTo, lengthCm: 38));
      expect(find.textContaining('38'), findsWidgets);
      expect(find.textContaining('45'), findsWidgets);
    });
  });

  testWidgets('Result screen renders no empty state when the clock is past valid_to', (WidgetTester t) async {
    await withClock(Clock.fixed(afterExpiry), () async {
      await t.pumpWidget(await resultHarness(rule: kRuleWithValidTo, lengthCm: 38));
      expect(find.byType(NoRuleRecorded), findsNothing);
    });
  });

  testWidgets('Result screen keeps the verdict wording identical before and after valid_to',
      (WidgetTester t) async {
    final String fresh = await withClock(Clock.fixed(beforeExpiry), () async {
      await t.pumpWidget(await resultHarness(rule: kRuleWithValidTo, lengthCm: 38));
      return statementText(t);
    });
    final String stale = await withClock(Clock.fixed(afterExpiry), () async {
      await t.pumpWidget(await resultHarness(rule: kRuleWithValidTo, lengthCm: 38));
      return statementText(t);
    });
    expect(stale, fresh, reason: 'an expired pack changes nothing but the bar');
  });

  // … rows 1, 6, 7, 8, 9
}
```

**Run:** `cd app && flutter test test/features/result/expired_rule_finding_test.dart` → 9 failures, and
`flutter test integration_test/expiry_clock_forward_test.dart -d <device>` → 2 failures. Any pass now is
a wrong test.

## Implementation outline

1. Pick the rule. It must carry a non-null `valid_to` in the shipped Galicia seed (E04) — an annual
   *orden de vedas* row is the natural choice, and §7.3 names those instruments as the ones that carry
   `valid_to`. Record the rule id and its `valid_to` in `app/testing/models/rules.dart` as
   `kRuleWithValidTo`, and in `docs/release/clock-tests.md`.
2. Write the widget harness `resultHarness({rule, lengthCm})` in `app/testing/` — it builds the real S2
   subtree over the real resolver with the real `reference.db` fixture, overriding only `clockProvider`.
3. Write `app/integration_test/harness/clock.dart`: an override that pins `clockProvider` for a driven
   run, plus a `restoreSystemClock` note in the doc for the manual pass.
4. Run all 11. They fail. Then, and only then, look at whether anything in `app/lib` needs changing —
   the expectation is that E03 and E10 already satisfy every row, and that this task adds tests rather
   than behaviour. **If a row cannot be made to pass without weakening invariant 5, stop and say so in
   this file rather than changing the invariant.**
5. Perform the manual device run: Settings → date and time → automatic off → set to the rule's
   `valid_to` plus one day. Observe the bar, the finding and both numbers. Screenshot to
   `docs/release/<version>/evidence/expiry-forward.png`. Restore automatic time immediately.
6. Write `docs/release/clock-tests.md` with the rule id, the date used, the two observations, and the
   warning that the clock tests never share a device session with the packet capture (moving a clock
   provokes system re-sync traffic that would contaminate T02's evidence).
7. Re-run the suite. All 11 green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 11 tests pass, and each failed first.
- [ ] Row 2 and row 4 are both present. Neither is a restatement of the other, and neither was dropped
      as redundant during `/simplify`.
- [ ] The literals asserted in row 3 are the rule's own numbers, read from the shipped content, and the
      rule id is named in `app/testing/models/rules.dart` and in `docs/release/clock-tests.md`.
- [ ] The manual device run happened on the physical Android device named in T08's checklist, and the
      screenshot is committed.
- [ ] Automatic time was restored on the device before any other §14 row was run.
- [ ] No production code path acquired a `DateTime.now()`; `flutter analyze --fatal-infos` is clean and
      `check_app_invariants.sh` is clean.
- [ ] Invariant 5 is unweakened: nothing in this task gates, disables, errors or returns early on
      expiry, and no refresh affordance was added.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze --fatal-infos && flutter test
cd app && flutter test integration_test/expiry_clock_forward_test.dart -d <device-id>
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh    app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(check): keep the finding intact when the device clock passes valid_to

SPEC §14 calls this a correctness test and not a cosmetic one, and the obvious
version of it is cosmetic: asserting that an amber bar appeared passes on a
build where the resolver filtered the expired rule out and the species fell
through to "no rule recorded" — the exact regression §7.3 was written to fix,
where every annual orden de vedas vanished on its own expiry day. So the bar,
the finding and both of the rule's numbers are asserted together, the absence of
the fall-through message is asserted separately, and the verdict wording is
compared byte for byte against the same evaluation one day earlier. Dismissing
D3 must not take the bar with it; the bar is a fact about the data.

Task: E21/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
