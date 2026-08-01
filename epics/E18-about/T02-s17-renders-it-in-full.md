# E18/T02 — S17 renders `ATTRIBUTIONS.md` in full

| | |
|---|---|
| **Epic** | E18 — About and attributions |
| **Branch** | `epic/18-about` (shared) |
| **Commit** | `feat(about): render ATTRIBUTIONS.md in full on the About screen` |
| **Depends on** | T01 (the emitted asset and its committed bytes) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S17, §8 (the plate ledger the screen must show), §4.7 (the full disclaimer lives here), §9.4 (the shared fold the filter reuses), §13 (200% text scale) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-typography` | Rule 2 (quoted law is serif), rule 8 (**never truncate** `legal`, `legalSmall` or `citation` — the whole reason "in full" is testable), rule 7 (the reading measure scales with `textScaler`), and the Arabic zero-tracking rule for the localised headings |
| `lonja-lists-and-tables` | The plate ledger is a `Table` with fixed column classes, not a `DataTable` (rule 3); rule 4 for the end-aligned death-year column; rule 6 for the authored empty state the filter needs |
| `i18n-rtl-l10n` | The document body is English inside a possibly-RTL page. Rule 8 and `references/rtl-and-bidi.md` decide isolate-vs-`textDirection`, and rule 5's directional geometry keeps the ledger mirroring by construction |
| `accessibility-as-code` | Rule 5 (no `FittedBox`, no `ellipsis` to make a label fit — the same prohibition typography states, from the other side), rule 1 (the filter field is an interactive node and needs `Semantics`), and the 200% scale floor |
| `catchlaw-conventions-index` | The routing tie-break: a screen crossing type, lists and i18n. Invariant 2 binds every string added here |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S17 | The element list, in order, and the words *"`ATTRIBUTIONS.md` rendered in full"* |
| `SPEC.md` | §4.7, disclaimer row | The one-line disclaimer sits on the result screen; the **full statement** is S17's |
| `SPEC.md` | §9.4 | The ordered fold the filter reuses, including step 6 (Arabic-Indic digits → ASCII) |
| `SPEC.md` | §9.6 | Why the quoted body is not translated, and why the availability of a language is stated rather than substituted |
| `.claude/skills/lonja-typography/references/type-ramp.md` | the ramp table, "Measures" | `legal` 16/1.62 for prose, `citation` 12 mono for the ledger, `LonjaMeasure.legal` 500 px × the live scale, `LonjaMeasure.digitColumn` 92 px |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Numerals" items 1, 2 and 5 | Arabic-Indic digits have no tabular coverage, so a numeral column is pinned; quoted publication records stay Western-digit |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The ledger table — column classes", "The divider ladder" | `label` / `numeric` classes, `FlexColumnWidth`, `hairlineDotted`, `ledgerHead`, and `LonjaSectionLabel` as the gazette section device |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Precedence", "Empty" | `error` > `loading` > `empty` > `data`; the empty state names the absence and offers exactly one action |
| `.claude/skills/i18n-rtl-l10n/references/rtl-and-bidi.md` | "Bidi isolation", "Direction is a locale consequence" | Isolates are for inline runs; a standalone block sets `textDirection` on the widget instead. Never a root `Directionality` |
| `FLUTTER_GUIDE.md` | §2.1, §2.2, §2.5 | `ui/<feature>/{view_models,widgets}`, `<feature>_screen.dart` → `<Feature>Screen`, `<feature>_viewmodel.dart` in `view_models/` |
| `FLUTTER_GUIDE.md` | §5.2 | Return the stream / future from the provider; the widget switches exhaustively over `AsyncValue`; no `await` before `runApp` |
| `epics/DECISIONS.md` | D-3, D-2 | Six locales for the headings; the theme lives at `app/lib/theme/` |

## What this delivers

- `app/lib/ui/about/widgets/about_screen.dart` — `AboutScreen`, the S17 scaffold. Section order
  follows `SPEC.md` §6 S17: full disclaimer → data sources and licences per jurisdiction →
  attributions in full → *(T03 fonts)* → *(T04 versions)* → *(T05 collection)* → *(T06 backups)*.
  Each later task adds one section and touches nothing else.
- `app/lib/ui/about/widgets/attributions_section.dart` — the parsed document, rendered.
- `app/lib/ui/about/widgets/attributions_filter_field.dart` — the filter.
- `app/lib/ui/about/view_models/about_viewmodel.dart` — holds the query and exposes the filtered
  block list.
- `app/lib/domain/models/attributions_block.dart` — a sealed `AttributionsBlock`:
  `HeadingBlock`, `ProseBlock`, `ListBlock`, `TableBlock`.
- `app/lib/data/repositories/attributions_repository.dart` + `attributions_repository_asset.dart` —
  reads `assets/legal/ATTRIBUTIONS.md` through `rootBundle` and parses the closed subset T01 emits.
- `app/testing/fakes/fake_attributions_repository.dart`.
- ARB keys in all six files (D-3): `aboutTitle`, `aboutDisclaimerHeading`, `aboutDisclaimerBody`,
  `aboutSourcesHeading`, `aboutAttributionsHeading`, `aboutFilterLabel`,
  `aboutFilterNoMatchHeadline`, `aboutFilterNoMatchBody`, `aboutFilterClear`.
- `app/test/ui/about/about_screen_attributions_test.dart`.
- A route to `AboutScreen` from S14's *about* row (E16 already renders the row).

## Why it is built this way

**"In full" is the requirement, so the code must have no way to shorten it.** `SPEC.md` §6 S17 says
the file is *rendered in full*, and §8 explains why: the plate ledger is the evidence for a licence
claim. A "show more" affordance, a `maxLines`, a `TextOverflow.ellipsis` or a `FittedBox` on the
document body each turn a checkable claim into a summary. `lonja-typography` rule 8 already bans all
of them on `legal`, `legalSmall`, `citation` and `verdict`, and `accessibility-as-code` rule 5 bans
them again from the accessibility side. Test 3 asserts it directly so a future "it overflows on a
small phone" fix cannot quietly reintroduce one — the page scrolls instead.

**A closed Markdown subset, parsed by us.** T01 emits four block kinds and nothing else. The parser
accepts exactly those and throws on anything else, so a change to the emitter that the renderer cannot
draw fails a test rather than rendering as raw `|` characters on a phone at sea. **Rejected:** a
Markdown package — `dependency-hygiene`'s weigh-and-usually-refuse list covers it ("a few hundred
lines of first-party Dart"), and every dependency added to this app has to survive the §14 transitive
audit for a document whose grammar we already control. **Rejected:** a `WebView` — banned outright by
`SPEC.md` §10 and by `catchlaw-offline-guarantee` rule 1.

**The body is not translated; the headings are.** `ATTRIBUTIONS.md` quotes licences and statutes.
§9.6 refuses to translate a quoted instrument, and `licence-provenance.md` gives the two reasons — an
unofficial rendering of a penal instrument is a liability, and a translation we commission is a new
derivative outside Spain's Art. 13 carve-out. Both arguments transfer to a licence text unchanged. So
the section headings come from the six ARB files (tier 1, §9.2) and the document body stays as
authored. That makes the `ar` case a **direction** problem, not a translation problem.

**Direction: a standalone block sets its own `textDirection`; isolates are for inline runs.**
`rtl-and-bidi.md` is explicit — inline mixed-script runs take FSI/PDI, a standalone strong-LTR field
sets `textDirection: TextDirection.ltr` on the widget. An English licence paragraph inside an Arabic
page is the standalone case. **Rejected:** wrapping the section in `Directionality(TextDirection.ltr)`
— that would flip the section's padding and the ledger's column order back to physical LTR, so the
Arabic chrome around it would stop mirroring. **Rejected:** splicing isolate characters into the
asset — isolates must never reach storage, and the asset is storage.

**The filter reuses `normalise()` from `packages/rule_engine/`.** A `toLowerCase().contains()` filter
fails for a user typing `١٧٩٩` on an Arabic keyboard, because §9.4 step 6 is what maps Arabic-Indic
digits to ASCII. Reusing the shared fold is the same argument the content pipeline makes for
`search_norm` (rule 9): a second normaliser means the index and the query disagree. The engine is pure
Dart and returns no sentence, so calling `normalise()` from the app respects D-7.

**The filter is a filter, not FTS.** It runs over the parsed blocks in memory. It does not touch
`reference.db`, `legal_text_fts` or the < 200 ms FTS budget in §13, and it has no query language. A
plate ledger with one row per bundled plate is unreadable on a phone without one; that is the whole
justification, and it is recorded as this epic's reading of S17 rather than the spec's word.

**Off the launch path.** S17 is reached from S14. The asset is read when the screen opens, not in
`main()`, so §13's < 1.2 s cold-start budget is untouched — `FLUTTER_GUIDE.md` §5.2's rule that
nothing is awaited before `runApp` is not even in play here, but the provider still returns the future
rather than awaiting it, so the first frame paints a skeleton.

**The four states are authored, and three of them are reachable here.** `error` when the asset is
missing or unparseable — a local failure with a diagnostic code, never "check your connection"
(`the-four-states.md`). `loading` as a ruled skeleton, never a spinner. `empty` when the filter matches
nothing. `stale` does not apply: this document has no validity window; T04's version rows do.

## Tests first

Write every row before touching `about_screen.dart`. Run them. **They must fail** — `AboutScreen` does
not exist. If one passes early, it is asserting against a widget that is not the one under test.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `AboutScreen renders every plate row from the bundled ATTRIBUTIONS.md` | fake repo, 3 plate rows | 3 rows found | "In full" is the requirement; a renderer that drops rows is a screen that attributes fewer plates than are bundled |
| 2 | `AboutScreen renders the illustrator death year on every plate row` | Bloch, d. 1799 | `1799` present | The death year is the only evidence a reader can check the licence claim against |
| 3 | `AboutScreen renders the attributions document with no maxLines and no ellipsis` | long prose block | every `Text` under the section has `maxLines == null` and `overflow != ellipsis` | The specific regression: a future "fix an overflow" commit truncates a licence and nobody notices |
| 4 | `AboutScreen scrolls to the last block of the attributions document` | 60 blocks | `scrollUntilVisible` finds the last | Rendering in full is worthless if the tail is unreachable |
| 5 | `ar - AboutScreen renders the document body left-to-right` | locale `ar` | body `Text` carries `textDirection: TextDirection.ltr` | English licence text reordered by an RTL paragraph is unreadable, and the ledger's `|` columns scramble |
| 6 | `ar - AboutScreen pins the death-year column to LonjaMeasure.digitColumn` | locale `ar` | the numeric cell has that width | Arabic-Indic digits have no tabular coverage, so figure widths cannot hold the column |
| 7 | `AboutScreen filters the document to blocks matching the query` | query `Bloch` | only matching blocks remain | The filter is the reason the ledger is usable on a phone at all |
| 8 | `ar - AboutScreen matches the death year 1799 when the query is ١٧٩٩` | Arabic-Indic query | the Bloch row remains | §9.4 step 6 — and the reason the shared fold is reused instead of `toLowerCase` |
| 9 | `AboutScreen shows the authored empty state when no block matches the query` | query `zzzz` | headline and exactly one action | `lonja-lists-and-tables` rule 6: a blank frame reads as a crash to a fisher with no signal |
| 10 | `AboutScreen renders the attributions section at TextScaler.linear(2.0) with no overflow` | scale 2.0, 5-inch viewport | no overflow exception | `SPEC.md` §13: layouts hold at 200% text scale |
| 11 | `AboutScreen filter field exposes a Semantics label` | default | `isSemantics(label: …, textField: true)` | `accessibility-as-code` rule 1 — an unlabelled field locks out every screen-reader and switch user |
| 12 | `AboutScreen shows the local error state with a diagnostic code when the asset cannot be parsed` | repo throws | headline plus a mono code, no network wording | `the-four-states.md`: a list error here is always local, never "check your connection" |

```dart
// app/test/ui/about/about_screen_attributions_test.dart
import 'package:catchlaw/ui/about/widgets/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_attributions_repository.dart';
import '../harness.dart'; // pumpAbout(tester, {locale, textScaler, repository})

void main() {
  testWidgets('AboutScreen renders every plate row from the bundled ATTRIBUTIONS.md',
      (tester) async {
    await pumpAbout(tester, repository: FakeAttributionsRepository.threePlates());
    expect(find.byType(PlateLedgerRow), findsNWidgets(3));
  });

  testWidgets('AboutScreen renders the attributions document with no maxLines and no ellipsis',
      (tester) async {
    await pumpAbout(tester, repository: FakeAttributionsRepository.threePlates());
    for (final text in tester.widgetList<Text>(
        find.descendant(of: find.byType(AttributionsSection), matching: find.byType(Text)))) {
      expect(text.maxLines, isNull);
      expect(text.overflow, isNot(TextOverflow.ellipsis));
    }
  });

  testWidgets('ar - AboutScreen matches the death year 1799 when the query is ١٧٩٩',
      (tester) async {
    await pumpAbout(tester,
        locale: const Locale('ar'), repository: FakeAttributionsRepository.threePlates());
    await tester.enterText(find.byType(AttributionsFilterField), '١٧٩٩');
    await tester.pumpAndSettle();
    expect(find.textContaining('Bloch'), findsOneWidget);
  });

  testWidgets('AboutScreen shows the authored empty state when no block matches the query',
      (tester) async {
    await pumpAbout(tester, repository: FakeAttributionsRepository.threePlates());
    await tester.enterText(find.byType(AttributionsFilterField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.byType(LonjaEmptyState), findsOneWidget);
    expect(find.byType(LonjaButton), findsOneWidget); // exactly one action
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/ui/about/about_screen_attributions_test.dart` → 12 failures.
If any passes now, the test is wrong.

## Implementation outline

1. Create `app/lib/ui/about/{view_models,widgets}/` — a feature folder of its own, per
   `FLUTTER_GUIDE.md` §2.1. Not `ui/settings/about/`: S17 has its own ViewModel and its own route.
2. Add the sealed `AttributionsBlock` in `domain/models/`. Immutable, `const` constructors.
3. Write the parser in `attributions_repository_asset.dart`. Accept the four block kinds; throw a
   typed failure on anything else. Drift models never escape `data/` (`FLUTTER_GUIDE.md` §2.5 rule 6);
   the parser returns domain blocks.
4. Write the fake in `app/testing/fakes/`, with named constructors for the fixtures the tests need.
5. `AboutScreen`: a `CustomScrollView` of slivers — `LonjaSectionLabel` per section, then the blocks.
   `TableBlock` renders through `LonjaLedgerTable` with the `label` and `numeric` column classes.
   `EdgeInsetsDirectional` everywhere; `TextAlign.end` on the numeric column.
6. Wrap prose in `ConstrainedBox(maxWidth: LonjaMeasure.legal * MediaQuery.textScalerOf(context).scale(1))`
   — the measure is a character count, so it scales (`lonja-typography` rule 7).
7. Set `textDirection: TextDirection.ltr` on each body block's `Text`. Do **not** wrap the section in
   a `Directionality`.
8. The ViewModel holds the query; the filter runs `normalise()` from `package:rule_engine` over the
   block's plain text and over the query.
9. The full disclaimer renders from ARB in `t.legal`, above everything else, per §6 S17's order.
10. Route from S14's *about* row.
11. Re-run the suite. All 12 green, and every E15 reference-screen test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 tests pass, and each failed first.
- [ ] No `maxLines`, `TextOverflow.ellipsis` or `FittedBox` anywhere under `app/lib/ui/about/`.
- [ ] `grep -rn "ListTile\|DataTable\|Directionality(" app/lib/ui/about/` returns nothing.
- [ ] The filter calls the same `normalise()` the species search calls — not a copy.
- [ ] Every new ARB key exists in all six files (D-3) and `ar` carries no positive `letterSpacing`.
- [ ] Nothing in `app/lib/ui/about/` is awaited before `runApp`, and the asset read happens on screen
      open (`FLUTTER_GUIDE.md` §5.2).
- [ ] `app/assets/legal/ATTRIBUTIONS.md` is read through `rootBundle`, never through a file path.

## Gates

```bash
# from the repository root
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
cd -
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh      app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh               app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh        app/lib
```

Every invocation names `app/lib` explicitly. The scripts exit 2 on a missing directory and a bare
default resolves to `lib/`, which does not exist at this repository root (D-1).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(about): render ATTRIBUTIONS.md in full on the About screen

SPEC.md §6 S17 requires the file rendered in full, and §8 says why: the plate
ledger is the evidence behind a licence claim, so a summary is not a smaller
version of it — it is a different claim. The section therefore has no
maxLines, no ellipsis and no "show more", and a test asserts that so a future
overflow fix cannot quietly add one; the page scrolls instead.

The document body stays in the language it was authored in, because §9.6
refuses to translate a quoted instrument, which makes the ar case a direction
problem: each body block sets textDirection: ltr on itself rather than wrapping
the section in a Directionality that would stop the surrounding chrome
mirroring. The filter reuses normalise() from the rule engine so ١٧٩٩ typed on
an Arabic keyboard finds the death year 1799 (§9.4 step 6).

Task: E18/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
