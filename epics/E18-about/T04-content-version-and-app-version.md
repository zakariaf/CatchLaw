# E18/T04 — Content version per jurisdiction, and the app version

| | |
|---|---|
| **Epic** | E18 — About and attributions |
| **Branch** | `epic/18-about` (shared) |
| **Commit** | `feat(about): show content version per jurisdiction beside the app and build versions` |
| **Depends on** | T02 (the `AboutScreen` scaffold) |
| **Size** | S |
| **Spec** | `SPEC.md` §6 S17 (*content version per jurisdiction · app version*), §7.1 (`jurisdiction.content_version`, `published_on`, `checked_on`, `valid_until`; `content_meta`), §4.7 (trust and currency), §7.3 (expiry does not delete) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | The version block is a ledger `Table` with `label` and `numeric` column classes (rule 3 bans `DataTable`), rule 4 for the end-aligned mono version column, and `references/the-four-states.md` for the ochre stale bar that rides above data instead of replacing it |
| `lonja-typography` | Rule 3: a version, a date and a build number are comparable numerals, so they are mono with `tabularFigures`. `references/arabic-and-scripts.md` decides which of these stay Western-digit and why |
| `catchlaw-conventions-index` | Invariant 5 — an expired ruleset is still shown. This is the screen where a reader checks *how* expired, so hiding a row here breaks the invariant more quietly than anywhere else |
| `i18n-rtl-l10n` | Rule 6 (store canonical, project at render) and the numeral-system machinery: `published_on` is a quoted record and must not be re-rendered in Arabic-Indic digits |
| `accessibility-as-code` | Rule 6: the stale state carries a glyph and a word, never ochre alone |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.1, the `jurisdiction` table | `content_version`, `published_on`, `checked_on`, `valid_until` — the four columns this section reads |
| `SPEC.md` | §7.1, `content_meta` | `key TEXT PRIMARY KEY, value TEXT NOT NULL` with `'schema_version'`, `'build_date'`, `'generator_commit'` |
| `SPEC.md` | §4.7 | *"Rules as published on \<date\>, checked \<date\>" per jurisdiction* — the wording this section is the long form of |
| `SPEC.md` | §7.3 | Expiry tags a result, it does not delete it. The same rule applied to a version row |
| `SPEC.md` | §9.5, "Dates" | Season windows are locale-formatted; the split from a quoted publication record is argued below |
| `SPEC.md` | §10 | `package_info_plus` is on the stack for version display |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Numerals" item 5 | *"Dates in citations stay Western-digit ISO in every locale, because they are quoting a publication record, not presenting a number to read"* |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Stale", "Error" | Ochre ground, 1px ochre rules, glyph + label + detail, never dismissable, never blocking; and that a list error here is always local |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The ledger table — column classes" | `label` start / `numeric` end, `FlexColumnWidth`, tone overrides are semantic only |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | "5 — Stale beats absent" | The fresh/expired matrix, and the edge cases: no `valid_until` is valid, a clock behind `published_on` is a clock problem |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 1 — the banned package table" | `package_info_plus` is listed as allowed, *"listed only to stop the reflex ban"* |
| `FLUTTER_GUIDE.md` | §5.2 | The repository takes no `Ref` and imports no Riverpod; the provider returns the future and the widget switches exhaustively |
| `epics/DECISIONS.md` | D-6 | The shipped `reference.db` is extracted then opened `readOnly: true`; this section reads the extracted copy, which is the one the engine evaluated |

## What this delivers

- `app/lib/domain/models/about_versions.dart` — `AboutVersions` (app version, build number,
  `contentSchemaVersion`, `contentBuildDate`, `generatorCommit`) and `JurisdictionVersion`
  (`code`, `nameKey`, `contentVersion`, `publishedOn`, `checkedOn`, `validUntil`). Immutable, `const`.
- `app/lib/data/repositories/about_repository.dart` + `about_repository_drift.dart` — one query over
  `jurisdiction` ordered by `code`, one over `content_meta`.
- `app/lib/data/services/app_version_service.dart` — the single `package_info_plus` call site.
- `app/lib/ui/about/widgets/versions_section.dart` — the ledger.
- `app/testing/fakes/fake_about_repository.dart`, `app/testing/models/k_about_versions.dart`.
- ARB keys in all six files (D-3): `aboutVersionsHeading`, `aboutAppVersionLabel`,
  `aboutContentBuildLabel`, `aboutJurisdictionColumn`, `aboutContentVersionColumn`,
  `aboutPublishedLabel`, `aboutCheckedLabel`, `aboutVersionsUnavailableHeadline`,
  `aboutVersionsUnavailableBody`.
- `app/test/ui/about/about_versions_test.dart`.

## Why it is built this way

**The numbers come out of the database, not out of a generated constant.** D-6 decides extraction by
comparing a generated Dart constant against `app_meta.content_build_date` — but that constant
describes the asset the binary *carries*, and this screen has to describe the database the engine
*evaluated*. Those diverge on exactly the path D-6 was designed for: a partial extraction leaves a
temp file, the marker is not written, and the old `reference.db` is still the one being queried. A
screen that read the constant would then report a content version no rule on the result screen came
from. **Rejected:** reading the constant, for that reason.

**Per jurisdiction, because there is no single content version.** §7.1 puts `content_version` on the
`jurisdiction` row, and §8's authoring reality is that jurisdictions are authored and re-checked
independently — E22 runs in parallel from E04 onward. One global number would be either the newest,
which overstates every other jurisdiction, or the oldest, which understates them. §4.7 already says
the banner is per jurisdiction; this is its long form.

**`published_on` and `checked_on` stay Western-digit ISO in every locale.** §9.5 says dates are
locale-formatted, and `arabic-and-scripts.md` item 5 says citation dates stay Western-digit ISO. Both
are right about different things, and the split is: a **season window** is a number presented to the
reader (`1 March – 30 April`), while a **publication record** is quoted from an instrument
(`2015-11-03`). This section is entirely the second kind — it exists so a fisher can match what the
app says against what the gazette says, and re-rendering `٢٠١٥-١١-٠٣` breaks that match. The
jurisdiction *name* localises through `content_string`; the record does not.
**Rejected:** running these through the locale `DateFormat` for consistency with the catch log.

**An expired jurisdiction keeps its row.** Invariant 5, and §7.3's headline: expiry tags, it does not
delete. The row stays, in the same order, with the same type, and gains a `LonjaPill` reading
`STALE DATA` in ochre plus the `valid_until` date. Ochre, not oxblood — oxblood means the *fish*
fails the rule (`the-four-states.md`). And glyph plus word plus hue, never hue alone (invariant 4).
**Rejected:** filtering expired jurisdictions out, greying the row, or moving it to a second table.
Any of those turns "your Galicia pack expired on 30 June" into "Galicia is not in this app".

**A missing or unopenable database is the error state, not the empty state.**
`the-four-states.md` gives the precedence and the copy rules: a headline stating the fact, a mono
diagnostic line, and no network wording — there is no network, so "check your connection" would be
both wrong and alarming. `reference.db` always ships with at least one jurisdiction, so a zero-row
result means the read failed, not that the content is empty.

**One `package_info_plus` call site.** `four-layers.md` lists the package as allowed and says it is
listed only to stop the reflex ban; `dependency-gate-and-audit.md` allows an identifier-adjacent
package "only with a named, shipped use". This is the named, shipped use, and confining it to
`app_version_service.dart` keeps that true and greppable.

## Tests first

Write every row before touching `versions_section.dart`. Run them. **They must fail** — the section,
the model and the repository do not exist. A test that passes early is finding some other screen's
text.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `AboutScreen lists one version row for each jurisdiction in reference.db` | fake with `ES-GA`, `BR-SP`, `AE-RK` | 3 rows | §7.1 puts the version on the jurisdiction row; a single global number misreports every jurisdiction but one |
| 2 | `AboutScreen shows content_version, published_on and checked_on on every jurisdiction row` | same | all three per row | §4.7's *"published on \<date\>, checked \<date\>"*, in full — a version with no dates cannot be matched against a gazette |
| 3 | `AboutScreen shows the app version and build number` | fake `2.4.1 (318)` | both present | §6 S17 names the app version; without the build number a screenshot cannot be tied to a build |
| 4 | `AboutScreen shows content_meta build_date and generator_commit` | fake `content_meta` | both present | §7.1 defines the three keys; the commit is what ties a shipped database to the content that produced it |
| 5 | `AboutScreen marks a jurisdiction whose valid_until has passed with the ochre STALE DATA pill` | `valid_until` yesterday | pill present, ochre, with a glyph and the word | Invariant 5, and invariant 4: hue alone says nothing in sunlight mode |
| 6 | `AboutScreen keeps an expired jurisdiction row in place with its version and dates intact` | same | row present, values unchanged, not disabled | §7.3: expiry tags, it does not delete. The regression is a "tidy" filter that removes the row |
| 7 | `AboutScreen treats a jurisdiction with a null valid_until as current` | `valid_until` null | no pill | `product-invariants.md`: a pack with no validity window is valid, never expired |
| 8 | `ar - AboutScreen renders published_on as Western-digit ISO` | locale `ar` | `2015-11-03`, not `٢٠١٥-١١-٠٣` | It quotes a publication record; Arabic-Indic digits break the match against the gazette |
| 9 | `ar - AboutScreen end-aligns the content version column` | locale `ar` | `TextAlign.end` on the numeric cell | `TextAlign.right` pins the figure to the start edge in Arabic, landing it under its own label |
| 10 | `AboutScreen shows the local error state with a diagnostic code when reference.db cannot be read` | repo throws | headline, mono code, no network wording | A read failure here is always local; "check your connection" is wrong in an app with no network |

```dart
// app/test/ui/about/about_versions_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_about_repository.dart';
import '../../../testing/models/k_about_versions.dart'; // kVersionsThreeJurisdictions
import '../harness.dart'; // pumpAbout(tester, {locale, textScaler, aboutRepository})

void main() {
  testWidgets('AboutScreen lists one version row for each jurisdiction in reference.db',
      (tester) async {
    await pumpAbout(tester,
        aboutRepository: FakeAboutRepository(kVersionsThreeJurisdictions));
    expect(find.byType(JurisdictionVersionRow), findsNWidgets(3));
  });

  testWidgets('AboutScreen keeps an expired jurisdiction row in place with its version and '
      'dates intact', (tester) async {
    await pumpAbout(tester, aboutRepository: FakeAboutRepository(kVersionsWithExpiredGalicia));
    expect(find.text('ES-GA'), findsOneWidget);
    expect(find.text('2026.2'), findsOneWidget);
    expect(find.byType(LonjaPill), findsOneWidget);
  });

  testWidgets('ar - AboutScreen renders published_on as Western-digit ISO', (tester) async {
    await pumpAbout(tester,
        locale: const Locale('ar'),
        aboutRepository: FakeAboutRepository(kVersionsThreeJurisdictions));
    expect(find.text('2015-11-03'), findsOneWidget);
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/ui/about/about_versions_test.dart` → 10 failures. If any passes
now, the test is wrong.

## Implementation outline

1. Add `AboutVersions` and `JurisdictionVersion` in `domain/models/`. Dates are stored as ISO strings
   because that is what §7.1 stores and what this section prints — parsing to `DateTime` and
   reformatting back to ISO would be a round trip with a locale in the middle, which is exactly the
   defect test 8 guards against. `validUntil` is nullable; nothing else is.
2. Add the abstract repository and the drift implementation. Two queries, ordered by
   `jurisdiction.code`, so the table order is stable across launches. Drift row classes never leave
   `data/` (`FLUTTER_GUIDE.md` §2.5 rule 6).
3. Add `AppVersionService` around `package_info_plus`. One call site; no other file imports it.
4. Add the fake and the `k`-prefixed fixtures in `app/testing/` (`CONVENTIONS.md` §6).
5. Provider: `@riverpod` returning `Future<AboutVersions>`; the widget switches exhaustively over
   `AsyncData` / `AsyncError` / `AsyncLoading` (`FLUTTER_GUIDE.md` §5.2). No `await for`.
6. `VersionsSection`: `LonjaLedgerTable`, header over `ledgerHead`, rows on `hairlineDotted`, jurisdiction
   name (`label`, start) and content version (`numeric`, end). The app/build/content-build lines sit
   above the table as a `pair`-class `Table`.
7. Expiry: compare `validUntil` against the device date. Non-null and past → `LonjaPill` with the
   ochre tone, the warn glyph and the word. Do not branch anything else on it.
8. Add the section to the `AboutScreen` scaffold in §6 S17's order — after the licences and
   attributions, before the collection statement.
9. Re-run the suite. All 10 green, and T02's and T03's still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 10 tests pass, and each failed first.
- [ ] The row count equals the `jurisdiction` row count in the extracted `reference.db`.
- [ ] No code path removes, disables, greys or reorders an expired jurisdiction row.
- [ ] `grep -rn "package_info" app/lib | grep -v app_version_service.dart` returns nothing.
- [ ] `published_on` and `checked_on` are printed as stored; no `DateFormat` touches them.
- [ ] Every numeric cell carries `FontFeature.tabularFigures()` from the ramp and `TextAlign.end`.
- [ ] Every new ARB key exists in all six files (D-3).
- [ ] `reference.db` is still opened `readOnly: true` (D-6); this task added no write.

## Gates

```bash
# from the repository root
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
cd -
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh        app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh               app/lib
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh      app/lib
```

`check_app_invariants.sh` check 5 (a status mapped to a `Color` in a file with no glyph) and check 6
(expiry that returns early or disables) both bite on this task specifically. Every invocation names
`app/lib`: the scripts exit 2 on a missing directory and the default `lib/` does not exist here (D-1).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(about): show content version per jurisdiction beside the app and build versions

The versions are read out of the extracted reference.db rather than from the
generated build constant, because the two diverge on exactly the path D-6 was
designed for: a partial extraction leaves the marker unwritten and the old
database is still the one being queried, so a screen reading the constant would
report a content version that no result on S2 came from.

Dates here are quoted publication records, not numbers presented to be read, so
published_on and checked_on stay Western-digit ISO in every locale including ar
— a fisher matching the app against the gazette needs the two strings to be the
same string. An expired jurisdiction keeps its row, its version and its dates,
and gains an ochre STALE DATA pill with a glyph and a word: §7.3 tags expiry, it
never deletes, and this is the screen where hiding a row would be quietest.

Task: E18/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
