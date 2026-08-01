# E10/T09 — The disclaimer that cannot be dismissed

| | |
|---|---|
| **Epic** | E10 — The result screen |
| **Branch** | `epic/10-result` (shared) |
| **Commit** | `feat(result): render the non-dismissable disclaimer naming the authority` |
| **Depends on** | T01 (the authority resolved from `jurisdiction.authority_key`) |
| **Size** | S |
| **Spec** | `SPEC.md` §5.1 point 5, §4.7 "Disclaimer", §6 S2 "disclaimer line", §6 S17 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-verdict-contract` | Rule 11 — permanent, on-screen, names the authority; no "Got it", no "Do not show again", no ⓘ |
| `lonja-verdict-and-status` | Rule 8 and the disclaimer block's anatomy, including the contractual line that makes its absence legible |
| `lonja-dialogs-and-surfaces` | Rule 11 — the disclaimer never migrates into a dialog, a tooltip or an info route |
| `lonja-typography` | Rule 2 — the disclaimer is set in the serif, because it is part of the document rather than app chrome |
| `accessibility-as-code` | Rule 2 — the info glyph is decorative and excluded; the disclaimer itself is never `ExcludeSemantics` |
| `catchlaw-conventions-index` | The routing tie-break: wording is `catchlaw-verdict-contract`, setting is `lonja-verdict-and-status` |
| `i18n-rtl-l10n` | The `{authority}` placeholder and its parity across all six ARB files |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §5.1 point 5 | "A non-dismissable disclaimer sits on the result screen itself, naming the authority to verify with" |
| `SPEC.md` | §4.7 "Disclaimer" row | The single line, the full statement's home in S17, and "On the result itself, not buried" |
| `SPEC.md` | §7.1 `jurisdiction` DDL | `authority_key`, which resolves through `content_string` per jurisdiction |
| `.claude/skills/catchlaw-verdict-contract/references/the-five-part-carve-out.md` | Part 5 and its authority table | MOCCAE, Consellería do Mar, IBAMA — and the testable assertion for a structural `const` child |
| `.claude/skills/lonja-verdict-and-status/references/verdict-anatomy.md` | "The permanent disclaimer" | Ground, borders, glyph size, the serif setting, and the mono line stating that it cannot be dismissed |
| `.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh` | check 5 | The exact patterns that fail the build: `showDisclaimer`, a ternary, a `Visibility` wrapper |
| `epics/CONVENTIONS.md` | §9 | The invariants; this widget is where invariant 2's "reference tool" claim is printed |

## What this delivers

- `app/lib/ui/result/widgets/result_disclaimer.dart` — `ResultDisclaimer`, taking the resolved
  authority name and nothing else. No `bool` parameter, no callback, no key that could hide it.
- The `disclaimerResult` ARB key with an `{authority}` placeholder and a constraint-carrying
  `@description`, in all six locales.
- `ResultDisclaimer` occupying a fixed, unconditional slot at the foot of `ResultSection`.
- `app/test/ui/result/result_disclaimer_test.dart`.

## Why it is built this way

**It is the fifth argument for the carve-out, not a footer.** §5.1 lists five structural commitments
that keep this a reference tool rather than an advisory one, and point 5 is this widget. §4.7 adds
the placement: "On the result itself, not buried" — the full statement lives in S17, one line lives
here, and the line is the one an inspector or a court would see.

**It names the authority, because a generic disclaimer is a shrug.** "Not legal advice" tells the
reader nothing about what to do next. "Verify with the Consellería do Mar before relying on it" makes
the app legible as a reader of that body's text and tells the fisher where to go. The authority comes
from `jurisdiction.authority_key` through `content_string`, so it is per-jurisdiction and translated
with the rest of the bundled content, while the sentence around it is an ARB key with an
`{authority}` placeholder.

**Structural, not conditional — and the gate enforces it.**
`check_lonja_verdict.sh` check 5 fails the build on `showDisclaimer`, on
`disclaimerDismissed`, on `if (...) ResultDisclaimer`, on `? ResultDisclaimer` and on
`Visibility(... Disclaimer)`. A disclaimer behind a flag is a disclaimer a hotfix turns off, and the
screen it would be turned off on is the one carrying the exposure. `the-five-part-carve-out.md`
states the assertion plainly: there is no "Got it", "I understand", "Do not show again", ⓘ button,
tooltip or one-time splash anywhere in its call chain.

**On const-ness.** `lonja-verdict-and-status` rule 8 writes the slot as `const LonjaDisclaimer()`.
The authority is resolved at runtime, so the call site here is not `const`. That is not a weakening:
what rule 8 protects is the absence of a flag, a conditional and a dismiss path, and the constructor
takes exactly one `String`. The tests below assert the property the rule is about — the disclaimer is
present on all nine result states, including the ones a developer might think do not need it.

**It is not `ExcludeSemantics`.** `verdict-anatomy.md`'s semantics tree: the citation is one node read
verbatim, the disclaimer is one node and is never excluded. A screen reader user gets the same
disclaimer a sighted user does, which is the whole basis for calling it "shown".

**The mono line beneath it is contractual.** "SHOWN ON EVERY RESULT · CANNOT BE DISMISSED" tells the
reader the disclaimer is structural, which is what makes its absence legible. Without it, a missing
disclaimer looks like a screen that simply did not have one.

**Rejected — an ⓘ button opening the full S17 statement.** `lonja-dialogs-and-surfaces` rule 11 bans
it by name: a disclaimer behind a tap was not shown. S17 remains reachable through Settings; the line
here is not a link.

**Rejected — a one-time acceptance screen at first run.** `catchlaw-verdict-contract` rule 11: "A
dismissable disclaimer is, in the record, one never shown." D5 is a language confirmation, not a
legal acknowledgement, and adding one would also put a gate in front of the five-second core loop.

**Rejected — rendering it only when a verdict was produced.** The no-rule and ambiguous states are
exactly where a reader is most likely to draw his own conclusion, so they are the states that need it
most. The slot is unconditional in `ResultSection`.

## Tests first

Write every row before touching `result_disclaimer.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ResultDisclaimer names the authority for the active jurisdiction` | `ES-GA` | text contains `Consellería do Mar` | A generic "not legal advice" tells the reader nothing about what to do next |
| 2 | `ResultDisclaimer names a different authority in a second jurisdiction` | `AE-RK` | text contains the UAE ministry, not the Galician one | The authority is per-jurisdiction, resolved from `authority_key` |
| 3 | `ResultDisclaimer states that it is not legal advice and authorises nothing` | any | both clauses present | §5.1 point 5's substance, not just its presence |
| 4 | `ResultDisclaimer carries no dismiss affordance` | any | no button, no close icon, no `Got it` text | A dismissable disclaimer is, in the record, one never shown |
| 5 | `ResultSection renders the disclaimer for each of the nine result states` | loop over the nine displays | found once in every state, with the state name in the description | The no-rule and ambiguous states are where a reader most needs it |
| 6 | `ResultSection renders the disclaimer with the ruleset expired` | expired display | found once | Expiry adds a bar; it removes nothing |
| 7 | `ResultDisclaimer is not excluded from the semantics tree` | any | one semantics node reads the full sentence | A screen-reader user gets the same disclaimer a sighted user does |
| 8 | `ResultDisclaimer prints the line stating that it cannot be dismissed` | any | the mono line is present | It makes the disclaimer's absence legible in a screenshot |
| 9 | `ResultDisclaimer excludes the info glyph from the semantics tree` | any | the icon has no label | The glyph is decoration; a labelled one is read before the sentence |
| 10 | `ResultDisclaimer survives a 200% text scale with no overflow` | `textScaler: 2.0` | no overflow exception | The block most likely to be given a fixed height |
| 11 | `ResultDisclaimer is not truncated at the smallest supported text scale` | `textScaler: 0.85` | no `maxLines`, no ellipsis | `the-five-part-carve-out.md`'s stated golden condition |
| 12 | `ar - ResultDisclaimer renders the Arabic sentence with the authority isolated` | locale `ar` | the Latin authority run is FSI/PDI wrapped | An unisolated Latin name reorders the Arabic sentence around it |
| 13 | `RTL - ResultDisclaimer places the glyph at the start edge` | locale `ar` | glyph rect start < text rect start | Directional geometry on a block with a leading icon |
| 14 | `sunlight - ResultDisclaimer renders with no grey` | sunlight theme | resolved colours are black or white only | Sunlight deletes every grey, and `ink-muted` is this block's default |

```dart
// app/test/ui/result/result_disclaimer_test.dart
import 'package:catchlaw/ui/result/widgets/result_disclaimer.dart';
import 'package:catchlaw/ui/result/widgets/result_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../harness.dart';

void main() {
  group('ResultDisclaimer', () {
    testWidgets('carries no dismiss affordance', (tester) async {
      await tester.pumpApp(const ResultDisclaimer(authority: 'Consellería do Mar'));

      expect(find.byType(ButtonStyleButton), findsNothing);
      expect(find.byType(IconButton), findsNothing);
      expect(find.textContaining('Got it'), findsNothing);
      expect(find.textContaining('Do not show'), findsNothing);
    });

    // The loop interpolates the state name, so --plain-name can select one.
    for (final entry in kAllNineResultStates.entries) {
      testWidgets('ResultSection renders the disclaimer for the ${entry.key} state',
          (tester) async {
        await tester.pumpApp(ResultSection(display: entry.value));

        expect(find.byType(ResultDisclaimer), findsOneWidget);
      });
    }

    testWidgets('is not excluded from the semantics tree', (tester) async {
      await tester.pumpApp(const ResultDisclaimer(authority: 'Consellería do Mar'));

      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.byType(ResultDisclaimer)).label,
        contains('not legal advice'),
      );
      handle.dispose();
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/ui/result/result_disclaimer_test.dart` → 14 failures (test 5
expands to nine). If any passes now, the test is wrong.

## Implementation outline

1. Add `disclaimerResult` to `app_en.arb` with an `{authority}` placeholder and a `@description`
   opening `STATEMENT OF FACT.`, then mirror it into the other five ARB files (D-3).
2. `ResultDisclaimer({required this.authority})` — one `String` field, no `bool`, no callback, no
   nullable anything.
3. Build the block per `verdict-anatomy.md`: `paper-sunk` ground, a 2 dp solid `ink` top border and a
   1 dp `rule` bottom border, `EdgeInsetsDirectional` padding, a 15 dp `Icons.info_outline` wrapped
   in `ExcludeSemantics`, the sentence in the serif small step with the lead clause weighted, and the
   mono "shown on every result · cannot be dismissed" line beneath it.
4. Place it as the last child of `ResultSection`, unconditionally, with no `if` and no ternary
   anywhere near it.
5. Resolve the authority in T01's presenter, not in this widget — the widget receives a `String` and
   performs no lookup.
6. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 tests pass, and each failed first.
- [ ] `check_lonja_verdict.sh app/lib` is clean, check 5 included.
- [ ] `ResultDisclaimer` has no `bool` parameter and no callback of any kind.
- [ ] `grep -rn "Disclaimer" app/lib` shows no `if`, no ternary, no `Visibility` and no `Opacity`
      adjacent to it.
- [ ] The disclaimer renders in all nine result states and in the expired variant of each.
- [ ] The `{authority}` placeholder name is identical in all six ARB files.
- [ ] The block is set in the serif, not in the UI sans.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh      app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
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
feat(result): render the non-dismissable disclaimer naming the authority

SPEC §5.1 point 5 makes this widget one of the five structural commitments
that keep the app a reference tool, and §4.7 fixes its placement: on the
result itself, not buried in the about screen. It names the body that
publishes the instrument — Consellería do Mar, MOCCAE, IBAMA — because a
generic "not legal advice" is a shrug that tells the reader nothing about
where to go next.

The constructor takes one String and nothing else: no flag, no callback,
no dismiss path. check_lonja_verdict.sh check 5 fails the build on a
showDisclaimer field, a ternary or a Visibility wrapper, because a
disclaimer behind a conditional is one a hotfix turns off on exactly the
screen that carries the exposure.

Task: E10/T09
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
