# E10/T05 — The citation row

| | |
|---|---|
| **Epic** | E10 — The result screen |
| **Branch** | `epic/10-result` (shared) |
| **Commit** | `feat(result): print the citation footnote with copy and an in-app rule-text route` |
| **Depends on** | T01 (the `CitationDisplay`), E05 (`legal_text` in the reference DB) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.6 "Citation per finding", §5.3 fifth bullet, §5.1 point 2, §6 S13, §14 "Tapping a citation expands S13 and copies to clipboard. No browser opens." |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-verdict-and-status` | Rule 11 and the footnote anatomy — the citation is the last printed block and is never itself behind a tap |
| `catchlaw-verdict-contract` | Rule 5 — the citation quadruple is structurally required, and `Citation?` is a defect |
| `catchlaw-conventions-index` | Invariant 1 and the `url_launcher` allow-list: `mailto:`/`tel:` on the about screen only, never `https:` |
| `lonja-typography` | The serif footnote, the mono superscript marker, ISO dates never truncated |
| `accessibility-as-code` | Rules 1 and 8: the tap target is `Semantics(button: true)` and ≥ 44 dp, ≥ 56 dp in glove mode |
| `i18n-rtl-l10n` | The footnote rule starts at the start edge; the Latin instrument name inside Arabic text is bidi-isolated |
| `catchlaw-rule-engine` | Where `Citation` comes from and why it is non-nullable on every finding |
| `state-management-riverpod` | The rule-text query is a `StreamProvider`/`FutureProvider` over a repository, read in a callback with `ref.read` |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.6 "Citation per finding" | The five parts, that `source_url` is selectable text, and that tapping expands S13 and offers copy — and does not open a browser |
| `SPEC.md` | §5.3 final bullet | Why: an `ACTION_VIEW` intent causes a fetch under the browser's own permission and defeats the Android guarantee |
| `SPEC.md` | §7.1 `citation` and `legal_text` DDL | The four printed fields, `source_url`, and the `legal_text` rows keyed by `citation_id` |
| `SPEC.md` | §6 S13 | What the full reader eventually holds, so this task's minimal reader does not grow into it |
| `SPEC.md` | §9.6 | Verbatim law is single-locale — this task prints it as bundled and never translates it |
| `.claude/skills/lonja-verdict-and-status/references/verdict-anatomy.md` | "The citation footnote" | Rule width 44%, superscript mono marker, small-caps jurisdiction, the ISO date order, the worked example |
| `.claude/skills/catchlaw-verdict-contract/references/the-five-part-carve-out.md` | Part 2 | Why each of the four fields is not optional |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | Invariant 1 "Allowed" list | The exact boundary of what may touch a URL, and that it is not this screen |

## What this delivers

- `app/lib/ui/result/widgets/result_citation_row.dart` — `ResultCitationRow`, taking a required
  non-nullable `CitationDisplay` and a required `onOpenRuleText` callback. Prints the footnote rule,
  the superscript marker, the small-caps jurisdiction, the instrument, the article, `published
  YYYY-MM-DD` and `checked YYYY-MM-DD`; renders `source_url` as `SelectableText` with no gesture;
  offers a copy action.
- `app/lib/ui/reference/widgets/rule_text_screen.dart` — the minimal destination for the tap: one
  indexed query on `legal_text` by `citation_id`, the body verbatim in the serif at the legal
  measure, the citation header and the checked-on date. Its `///` names **E15** as the owner that
  replaces it with the full S13.
- `app/lib/data/repositories/legal_text_repository.dart` + `_drift.dart` — one method,
  `Future<List<LegalTextRow>> byCitation(int citationId)`.
- The route registered once in `app/lib/routing/`.
- `app/test/ui/result/result_citation_row_test.dart`,
  `app/test/ui/reference/rule_text_screen_test.dart`.

## Why it is built this way

**Nothing hands a URL to a browser, and the reason is architectural rather than stylistic.** §5.3 is
explicit: an `ACTION_VIEW` intent causes the fetch under the *browser's* permission, so the Android
guarantee — a release manifest that does not grant `INTERNET`, enforced by the kernel — is defeated
by an app that never opens a socket itself. `source_url` is therefore `SelectableText`: the reader
can long-press, copy it, and type it into a browser on his own account, which is a different act with
a different actor. `launchUrl`, `url_launcher`, `AndroidIntent` and `ACTION_VIEW` are all on §14's
static grep list and on `check_app_invariants.sh`'s check 1.

**Printed always, and additionally tappable.** `lonja-verdict-and-status` rule 11 says the citation
is never behind a tap: no `ExpansionTile`, no tooltip, no "More info" route. §4.6 says tapping the
citation row expands the bundled verbatim text in S13. These are the same design read from two
sides — the *citation* is printed unconditionally as the last block, and the *full article text* is
one tap away. What rule 11 forbids is hiding the four fields; what §4.6 requires is a route to the
wording behind them. The row therefore renders all four fields with no interaction required, and the
whole block is additionally a `Semantics(button: true)` target that pushes the rule-text route.

**A minimal reader now, the real S13 in E15.** §14's device checklist requires "tapping a citation
expands S13 and copies to clipboard" to pass, and E10 lands nine epics before E15. Shipping the tap
with nowhere to go would leave a dead affordance on the screen with the highest legal exposure. The
minimal reader is one query and one scrolling serif column; full-text search, article navigation and
the §9.6 language-availability notice are E15's and are deliberately absent here. The file's doc
comment names E15 so the replacement is not a discovery.

**Copy puts the citation line on the clipboard, not the verdict.** The line copied is exactly what
the footnote prints — `United Arab Emirates — Ministerial Decision 580/2015, Art. 3 · published
2015-11-03 · checked 2026-07-14` — because that is what a fisher reads to an inspector or types into
a message. Copying the verdict sentence instead would put a statement about a specific fish onto the
clipboard, detached from its source, which is the shape of every screenshot that gets quoted back at
the publisher.

**ISO dates, unlocalised, mono.** `verdict-copy-rules.md`: citation dates are ISO-8601 so
`published 2015-11-03 · checked 2026-07-14` is the same string in all six locales and can be compared
against a printed instrument by eye. `product-invariants.md` adds that citation digits stay Western
even in `ar`, because they are quoted from a printed instrument. Never relative — "2 weeks ago" is
not a citation.

**Rejected — `url_launcher` with a confirmation dialog first.** The dependency itself is the problem:
`check_app_invariants.sh` bans the symbol, and §14's static check greps for it. A confirmation
dialog does not change which process performs the fetch.

**Rejected — an `ExpansionTile` holding the verbatim text inline.** It puts the article text inside
the result's scroll and makes the citation itself collapsible, which rule 11 bans by name. The
verbatim text is also frequently long enough to bury the disclaimer below the fold.

**Rejected — building the full S13 here.** E15 owns it, it needs the Arabic FTS work over
`body_norm`, and doing it here would move roughly a third of E15 into an epic that has ten tasks
already.

## Tests first

Write every row before touching `result_citation_row.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ResultCitationRow prints the instrument, the article and both dates` | `kCitationDisplayMd580` | all four found on screen with no interaction | §5.1 point 2 and invariant 3 — an uncited verdict is an opinion |
| 2 | `ResultCitationRow prints the jurisdiction in small-caps ahead of the instrument` | any | jurisdiction precedes instrument in the rendered order | The footnote's content order, so a reader scans source before number |
| 3 | `ResultCitationRow prints both dates in unlocalised ISO form` | locale `es` | `published 2015-11-03`, not `03/11/2015` | The same string in six locales, comparable against a printed instrument by eye |
| 4 | `ar - ResultCitationRow prints Western digits in the dates` | locale `ar` | `2015-11-03` in Latin digits | The dates are quoted from a printed instrument, not formatted for the reader |
| 5 | `ResultCitationRow renders the citation without an expansion affordance` | any | no `ExpansionTile`, no `Tooltip`, no collapsed state | Rule 11: a citation the reader must go looking for is not evidence at the counter |
| 6 | `ResultCitationRow copies the printed citation line to the clipboard` | tap copy | clipboard holds the exact footnote line | What is copied must equal what is printed, or the two disagree in a message |
| 7 | `ResultCitationRow does not copy the verdict sentence` | tap copy | clipboard contains no verdict wording | A verdict on the clipboard is a statement about a fish detached from its source |
| 8 | `ResultCitationRow invokes onOpenRuleText with the citation id when tapped` | tap the row | callback fires once with the id | The §4.6 requirement, wired as a callback so the row holds no route knowledge |
| 9 | `ResultCitationRow renders source_url as selectable text` | citation with a URL | a `SelectableText` holding the URL | §5.3: selectable text only, so the reader is the actor |
| 10 | `ResultCitationRow attaches no gesture to source_url` | citation with a URL | the URL subtree has no tap recogniser that navigates | The failure mode is a helpful `onTap` added later; the test names it now |
| 11 | `ResultCitationRow omits the URL line when source_url is null` | citation with no URL | no empty line, no placeholder | `source_url` is nullable in §7.1; an empty ruled line reads as missing data |
| 12 | `ResultCitationRow exposes the row as a button of at least 48 dp` | any | semantics `button: true`, height ≥ 48 | An unlabelled tap target locks out every switch and screen-reader user |
| 13 | `glove - ResultCitationRow exposes the row at 56 dp` | glove mode on | height ≥ 56 | §4.9's stated glove floor |
| 14 | `RTL - ResultCitationRow starts the footnote rule at the start edge` | locale `ar` | the 44%-width rule begins at the start edge | A physically-left rule under RTL detaches the footnote from its text |
| 15 | `ar - ResultCitationRow isolates the Latin instrument name` | locale `ar` | the instrument run is FSI/PDI wrapped | Without isolation the trailing article number jumps to the wrong end of the line |
| 16 | `RuleTextScreen renders the verbatim article for the tapped citation` | citation id 4 | the `legal_text` body for id 4 is on screen | The other half of the §14 device check |
| 17 | `RuleTextScreen renders the checked-on date in the header` | citation id 4 | `checked 2026-07-14` present | The reader has to know how current the transcription is |
| 18 | `RuleTextScreen never truncates the article body` | long body, 200% scale | no `maxLines`, no ellipsis, the page scrolls | Truncating legal text removes the clause that makes the verdict defensible |
| 19 | `ResultCitationRow reaches no network symbol` | source grep over the feature | no `launchUrl`, `url_launcher`, `AndroidIntent`, `ACTION_VIEW` | §14's static list, asserted in the suite rather than only in CI |

```dart
// app/test/ui/result/result_citation_row_test.dart
import 'package:catchlaw/ui/result/widgets/result_citation_row.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../harness.dart';

void main() {
  group('ResultCitationRow', () {
    testWidgets('copies the printed citation line to the clipboard', (tester) async {
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String;
        }
        return null;
      });

      await tester.pumpApp(ResultCitationRow(
        citation: kCitationDisplayMd580,
        onOpenRuleText: (_) {},
      ));
      await tester.tap(find.byKey(const ValueKey('citation-copy')));
      await tester.pump();

      expect(
        copied,
        'United Arab Emirates — Ministerial Decision 580/2015, Art. 3 · '
        'published 2015-11-03 · checked 2026-07-14',
      );
    });

    testWidgets('attaches no gesture to source_url', (tester) async {
      await tester.pumpApp(ResultCitationRow(
        citation: kCitationDisplayWithUrl,
        onOpenRuleText: (_) {},
      ));

      final url = find.byKey(const ValueKey('citation-source-url'));
      expect(find.descendant(of: url, matching: find.byType(GestureDetector)), findsNothing);
      expect(find.descendant(of: url, matching: find.byType(InkWell)), findsNothing);
    });

    testWidgets('invokes onOpenRuleText with the citation id when tapped', (tester) async {
      final opened = <int>[];
      await tester.pumpApp(ResultCitationRow(
        citation: kCitationDisplayMd580,
        onOpenRuleText: opened.add,
      ));
      await tester.tap(find.byType(ResultCitationRow));

      expect(opened, <int>[kCitationDisplayMd580.id]);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/ui/result/result_citation_row_test.dart
test/ui/reference/rule_text_screen_test.dart` → 19 failures. If any passes now, the test is wrong.

## Implementation outline

1. `ResultCitationRow({required this.citation, required this.onOpenRuleText})`. `citation` is
   non-nullable and there is no default and no `?? Citation.unknown()`.
2. Build the footnote: `FractionallySizedBox(widthFactor: 0.44, alignment:
   AlignmentDirectional.centerStart)` over a 1 dp rule, then the marker, the jurisdiction, the body.
   Every style from `LonjaType.of(context)`; the dates and the marker take the mono steps.
3. Wrap the printed block in `Semantics(button: true, label: …)` + `InkWell` sized to at least 48 dp
   (56 dp with glove density from E07's token), calling `onOpenRuleText(citation.id)`.
4. The copy action is a separate labelled target keyed `citation-copy`, calling
   `Clipboard.setData(ClipboardData(text: citation.line))` where `citation.line` is the single
   getter both the footnote and the clipboard read.
5. `source_url`, when present, is a `SelectableText` keyed `citation-source-url` inside the block but
   outside the `InkWell`, so tapping the URL selects rather than navigates.
6. Add `LegalTextRepository` with one method; register `RuleTextScreen` on a named route and wire
   `onOpenRuleText` in `ResultSection` to `context.pushNamed(...)`. Guard the tail with
   `if (!context.mounted) return;`.
7. `RuleTextScreen`: reads the repository through a provider, renders the citation header and the
   body in `t.legal` inside a measure that multiplies by `MediaQuery.textScalerOf(context).scale(1)`,
   with no `maxLines` and no overflow handling. Doc comment names E15.
8. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first.
- [ ] `grep -rnE "launchUrl|url_launcher|AndroidIntent|ACTION_VIEW" app/lib` returns nothing.
- [ ] `CitationDisplay` is required and non-nullable on the row, with no fallback anywhere.
- [ ] The clipboard string and the printed footnote come from one getter.
- [ ] The citation renders with no interaction required, and is not inside any collapsible widget.
- [ ] The rule-text route is registered exactly once and its screen's `///` names E15 as its owner.
- [ ] `check_no_network.sh app/lib` and `check_app_invariants.sh app/lib` are clean.
- [ ] The marker indices printed here equal the ones T03 renders on the findings rows.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh       app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh      app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
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
feat(result): print the citation footnote with copy and an in-app rule-text route

The four fields are printed unconditionally as the last block — never in an
ExpansionTile, a tooltip or a "More info" route — and the block is
additionally a tap target that pushes the bundled verbatim text. Rule 11
forbids hiding the citation; §4.6 requires a route to the wording behind
it, and those are the same design read from two sides.

source_url is SelectableText with no gesture. An ACTION_VIEW intent would
perform the fetch under the browser's own permission, which defeats an
Android guarantee that rests on the release manifest not granting INTERNET.

The destination is deliberately minimal: one query on legal_text by
citation_id. Search, article navigation and the §9.6 language notice are
E15's, and the file says so.

Task: E10/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
