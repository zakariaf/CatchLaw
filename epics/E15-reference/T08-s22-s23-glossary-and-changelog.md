# E15/T08 — S22 and S23, glossary and changelog

| | |
|---|---|
| **Epic** | E15 — The reference section |
| **Branch** | `epic/15-reference` (shared) |
| **Commit** | `feat(reference): add S22 and S23, the glossary and the per-jurisdiction changelog` |
| **Depends on** | T04 (`ReferenceScreenHeader`), T05 (`matchesFoldedQuery`) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.6 (glossary, changelog), §6 S22, S23 and the shared S18–S23 line, §6 S1 (the content-currency chip routes to S23), §7.1 (`glossary_term`, `content_change`), §4.7 (per-jurisdiction changelog), §8 (the builder emits the diff into `content_change`) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | Two lists, both sliver-built, both with the four states; the section device and the divider ladder |
| `lonja-typography` | The serif term / `legalSmall` definition pairing; the mono `citation` step the version pair and the change date use |
| `lonja-navigation-chrome` | `references/chips-and-currency.md` fixes the date formats and says S23 is where the currency chip goes when it is stale |
| `lonja-forms-and-controls` | The search field on both screens |
| `catchlaw-verdict-contract` | A definition explains a term; it never advises. A changelog entry states what changed; it never tells the reader to do anything about it |
| `i18n-rtl-l10n` | Bidi isolation of the two version strings, mirroring of the transition glyph, and the reason `String.compareTo` cannot sort this list |
| `catchlaw-conventions-index` | Invariant 5 — an expired jurisdiction still lists its terms and its changes |
| `widget-golden-and-a11y-testing` | The `ar` lane, where the version pair either reads correctly or scrambles |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.6 | "Glossary (S22) — domain terms per locale — backed by `glossary_term`"; "Changelog (S23) — what changed between content versions, per jurisdiction — backed by `content_change`, emitted by the build tool" |
| `SPEC.md` | §6 S22, S23 and the S18–S23 line | The shared contract for all six list screens |
| `SPEC.md` | §6 S1 | "content-currency chip (top-right, → S23)" — the route E12 already points at |
| `SPEC.md` | §4.7 | The content-version banner and the per-jurisdiction changelog as the trust surface |
| `SPEC.md` | §7.1 | `glossary_term(jurisdiction_id NULLABLE, term_key, definition_key, sort_order)` — NULL means global; `content_change(jurisdiction_id, from_version, to_version, summary_key, detail_key, changed_on)` |
| `SPEC.md` | §8 | "emit the per-jurisdiction diff into `content_change`" — the builder writes these rows, which is why the first shipped version has none |
| `.claude/skills/lonja-navigation-chrome/references/chips-and-currency.md` | "Date formatting", "The currency ladder" | ISO `yyyy-MM-dd`, mono tabular, Western digits in every locale including Arabic, because these are quoted record identifiers |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "Choosing a container", "The divider ladder" | Slivers with interleaved section labels; `LonjaSectionLabel`'s trailing rule |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Empty" | The authored empty state's parts; "exactly ONE `LonjaButton.primary`" — and the case this task exposes, where the right number is zero |
| `.claude/skills/i18n-rtl-l10n/references/rtl-and-bidi.md` | "Icons: mirror the directional", "Bidi isolation" | Mirror a direction-implying glyph; isolate strong-LTR technical runs; never let isolate characters reach storage |
| `.claude/skills/lonja-typography/references/type-ramp.md` | `subtitle`, `legalSmall`, `citation` | The steps a term, its definition and a version pair use |
| `FLUTTER_GUIDE.md` | Part 5.2 | The vertical slice |
| `epics/DECISIONS.md` | D-1, D-3 | Paths; the six locales |

## What this delivers

- `app/lib/data/daos/glossary_dao.dart` — `GlossaryDao.watchTerms({jurisdictionId})`, matching
  `jurisdiction_id IS NULL OR jurisdiction_id = :j`, ordered `sort_order ASC, id ASC`.
- `app/lib/data/daos/content_change_dao.dart` — `ContentChangeDao.watchChanges({jurisdictionId})`,
  ordered `changed_on DESC, id DESC`.
- `app/lib/domain/models/glossary_entry.dart` — `GlossaryEntry`: `termKey`, `definitionKey`,
  `sortOrder`, `isGlobal`.
- `app/lib/domain/models/content_change_entry.dart` — `ContentChangeEntry`: `fromVersion`,
  `toVersion`, `summaryKey`, `detailKey`, `changedOn`.
- `app/lib/data/repositories/glossary_repository.dart` + `_drift.dart` + a fake.
- `app/lib/data/repositories/content_change_repository.dart` + `_drift.dart` + a fake.
- `app/lib/ui/reference/glossary_screen.dart` — `GlossaryScreen` (S22).
- `app/lib/ui/reference/changelog_screen.dart` — `ChangelogScreen` (S23).
- `app/lib/ui/reference/widgets/glossary_entry_block.dart`,
  `app/lib/ui/reference/widgets/content_change_row.dart`.
- Two view models under `app/lib/ui/reference/view_models/`.
- ARB keys in all six files (D-3): `referenceGlossaryTitle`, `referenceGlossarySectionJurisdiction`,
  `referenceGlossarySectionGlobal`, `referenceGlossaryEmptyHeadline`, `referenceGlossaryEmptyBody`,
  `referenceChangelogTitle`, `referenceChangelogVersionPair`, `referenceChangelogEmptyHeadline`,
  `referenceChangelogEmptyBody`.
- Tests: `app/test/data/glossary_dao_test.dart`, `app/test/data/content_change_dao_test.dart`,
  `app/test/ui/reference/glossary_screen_test.dart`,
  `app/test/ui/reference/changelog_screen_test.dart`.

## Why it is built this way

**The glossary is ordered by `sort_order`, and `String.compareTo` is not an alternative.**
Dart's `String.compareTo` is UTF-16 code-unit order. It sorts `Ñ` after `Z`, so a Galician glossary
comes out with `nécora` in the wrong place, and it sorts every Arabic term after every Latin one, so a
bilingual glossary renders as two blocks with no relationship. Dart ships no ICU collator and this app
takes no dependency it does not need. §7.1 put `sort_order` on the table for exactly this reason, so
the query orders by `sort_order ASC, id ASC` and nothing in `app/lib/` ever compares two localised
strings. **Rejected:** `terms.sort((a, b) => a.term.compareTo(b.term))`, which looks correct in
English and is wrong in four of the six shipped locales. **The residual risk, from the epic's Risk 6:**
if a jurisdiction's authored `sort_order` is all zeros the list silently falls back to insertion order,
so test 4 asserts the committed Galicia seed's terms are not all-zero. That makes the failure a red
test rather than a quiet one.

**A term may appear twice, and that is the information.**
`glossary_term.jurisdiction_id` is nullable: NULL is a global term, non-NULL is one recorded for a
jurisdiction. When the same `term_key` exists in both, the reader sees the jurisdiction's definition
first, under a section label naming the jurisdiction, and the global one second under its own label.
That is not a duplicate — a term whose meaning differs by jurisdiction is precisely what a glossary is
for. **Rejected:** deduplicating by `term_key` and keeping the more specific one, which silently
deletes the general meaning the reader may actually have in mind.

**The changelog's empty state is normal, and it is the one with no action.**
§8 says the build tool emits the per-jurisdiction diff into `content_change`. The **first** shipped
content version for a jurisdiction therefore has no rows — correctly, because nothing has changed yet.
The empty copy says that as a fact ("no changes recorded — this is the first content version bundled
for <jurisdiction>"), and it offers **no action**, because there is nothing the reader can do and
nowhere useful to go. `the-four-states.md` specifies "exactly ONE `LonjaButton.primary`" and does not
cover zero; this is the surface that proves zero is sometimes right, and it is the case T09's
component is shaped around. **Rejected:** an action routing back to the hub, which is a button whose
only effect is to undo the reader's own navigation.

**The version pair is two LTR runs and a glyph that mirrors.**
`2026.07.14+3` is a technical identifier: strong-LTR, and it scrambles inside an Arabic paragraph
unless isolated. Both versions go through the one FSI/PDI helper `i18n-rtl-l10n` owns, and the
transition glyph between them is direction-implying, so it mirrors — `Icons.adaptive.arrow_forward` or
a mirrored plate glyph, never `Icons.arrow_forward`. The pair is authored as an ARB message with two
placeholders, so a translator controls the word order around it. **Rejected:** `'$from → $to'` spliced
in Dart, which hard-codes both the order and the arrow direction.

**Dates stay ISO and Western-digit in every locale.**
`chips-and-currency.md` fixes this: `changed_on` is a quoted record identifier, not prose, so it
renders `2026-07-14` in mono tabular figures under `ar` exactly as under `en`, isolated so the hyphens
cannot reorder. The season-window rule is the opposite — those are prose and localise — and that
distinction is why both are written down.

**Both screens are searchable, through the one shared filter.**
`matchesFoldedQuery` from T05, applied to the resolved term and definition on S22 and to the resolved
summary on S23, with the query folded once by `package:rule_engine`.

## Tests first

Write every row before touching `glossary_dao.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `GlossaryDao.watchTerms includes a global term with a null jurisdiction_id` | one global term | included | §7.1: NULL means every jurisdiction, and most domain terms are global |
| 2 | `GlossaryDao.watchTerms excludes another jurisdiction's term` | two jurisdictions | only the active one and the globals | A Brazilian term rendered to a Galician reader is a wrong definition |
| 3 | `GlossaryDao.watchTerms orders by sort_order and never by the localised value` | terms whose `sort_order` contradicts alphabetical order | `sort_order` order | The Risk 6 decision, pinned. A reviewer's "helpful" `.sort()` fails here |
| 4 | `Galicia fixture records a non-zero sort_order on at least one glossary term` | the committed E04 fixture | at least one non-zero | Stops the ordering silently degrading to insertion order (epic Risk 6) |
| 5 | `GlossaryDao.watchTerms returns both definitions when a term_key exists globally and per jurisdiction` | same key, both scopes | 2 entries | The deliberate not-a-duplicate case |
| 6 | `GlossaryScreen groups jurisdiction terms before global terms` | mixed fixture | jurisdiction section first | A jurisdiction-specific meaning is the one the reader is standing in |
| 7 | `ar - GlossaryScreen keeps Arabic and Latin terms in one ordered list` | mixed-script fixture | `sort_order` order, not two blocks | What `String.compareTo` would break, asserted on the rendered list |
| 8 | `GlossaryScreen resolves every term and definition through content_string` | `gl` locale | the `gl` values, not the keys | The S18–S23 shared contract |
| 9 | `GlossaryScreen renders the not-recorded state when no term exists` | empty fixture | authored headline and body | Empty surface 7 of eight |
| 10 | `ContentChangeDao.watchChanges orders newest first` | rows out of order | `changed_on DESC` | A changelog read oldest-first hides what just changed |
| 11 | `ContentChangeDao.watchChanges excludes another jurisdiction` | two jurisdictions | only the active one | §4.7: the changelog is per jurisdiction |
| 12 | `ContentChangeDao.watchChanges returns an entry with a null detail_key` | detail null | included, detail absent | §7.1 makes `detail_key` nullable; a summary-only change is normal |
| 13 | `ChangelogScreen renders the version pair with both versions isolated` | one entry | both version strings present and each wrapped in an LTR isolate | A version scrambled inside Arabic prose is unreadable and unquotable |
| 14 | `RTL - ChangelogScreen mirrors the version transition glyph` | `Locale('ar')` | the adaptive glyph resolves to its mirrored form | A direction-implying glyph pointing the wrong way inverts the meaning of the pair |
| 15 | `ar - ChangelogScreen renders changed_on as a Western-digit ISO date` | `Locale('ar')` | `2026-07-14`, unchanged | `chips-and-currency.md`: quoted record identifiers do not localise |
| 16 | `ChangelogScreen renders the first-version empty state with no action` | empty fixture | authored headline and body, and zero `LonjaButton` | Empty surface 8 of eight — the one that proves an action is optional |
| 17 | `ChangelogScreen contains no imperative in any locale` | every ARB value for these two screens | none of families A or B | "Update the app" is the sentence a changelog attracts, and there is no network to update from |
| 18 | `ChangelogScreen is reachable from the content-currency chip route` | push the chip's route | `ChangelogScreen` renders | §6 S1's chip has pointed at an unresolved route since E12 |
| 19 | `GlossaryScreen shows the ochre stale bar above a full list when the pack is expired` | expired jurisdiction | bar present and every term present | Invariant 5 |

```dart
// app/test/data/glossary_dao_test.dart
test('GlossaryDao.watchTerms orders by sort_order and never by the localised value',
    () async {
  // sort_order deliberately contradicts alphabetical order in every locale.
  await seedReference(db, kGlossaryOrderFixture);
  final terms = await dao.watchTerms(jurisdictionId: kJurisdictionGalicia).first;
  expect(terms.map((t) => t.sortOrder), orderedEquals(const [10, 20, 30]));
});

test('Galicia fixture records a non-zero sort_order on at least one glossary term',
    () async {
  final terms = await committedGaliciaDao
      .watchTerms(jurisdictionId: kJurisdictionGalicia)
      .first;
  expect(terms.any((t) => t.sortOrder != 0), isTrue,
      reason: 'an all-zero sort_order degrades the glossary to insertion order');
});
```

```dart
// app/test/ui/reference/changelog_screen_test.dart
testWidgets('ChangelogScreen renders the first-version empty state with no action',
    (tester) async {
  tester.useDevice(Device.small);
  await tester.pumpApp(overrides: kNoContentChangeOverrides);
  expect(find.text(kChangelogEmptyHeadlineEn), findsOneWidget);
  // The one empty surface of eight where zero actions is correct: nothing the
  // reader can do changes it, and there is nowhere useful to go.
  expect(find.byType(LonjaButton), findsNothing);
});
```

**Run:** `cd app && flutter test test/data/glossary_dao_test.dart
test/data/content_change_dao_test.dart test/ui/reference/` → 19 failures. Test 4 is the one that will
look like a fixture problem when it fails; it is not — it is the guard described in epic Risk 6.

## Implementation outline

1. Write `GlossaryEntry` and `ContentChangeEntry` with const constructors. Neither carries a
   `Citation`: §7.1 gives neither table a `citation_id`, and inventing one would be data this app does
   not have. Invariant 3 binds *results* derived from a rule; a glossary definition and a content diff
   are neither.
2. Write `GlossaryDao` and `ContentChangeDao`, each one scoped `customSelect`, each mapping to its
   value object inside the DAO.
3. Write the two repositories, their drift implementations and their fakes.
4. Write `GlossaryEntryBlock`: serif term at `subtitle`, `legalSmall` definition, both through
   `content_string`. Group with `LonjaSectionLabel` — jurisdiction section first, then global.
5. Write `ContentChangeRow`: the ISO `changed_on` in the mono `citation` step, the version pair from
   an ARB message with two isolated placeholders and an adaptive mirrored glyph, the summary in the
   serif, and the detail when present.
6. Write both screens: header, search field through `matchesFoldedQuery`, sliver lists, four states.
7. Confirm the content-currency chip's route now resolves to `ChangelogScreen`; do not change the
   chip.
8. Author both empty-state copies (surfaces 7 and 8 of eight) inline; T09 consolidates them, and
   surface 8 is the one that makes the action nullable.
9. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first.
- [ ] `grep -rn 'compareTo' app/lib/ui/reference/ app/lib/data/daos/` returns nothing.
- [ ] Both version strings pass through the one bidi-isolation helper, and no isolate character
      (U+2066–U+2069) reaches a model, a query or a fixture.
- [ ] `changed_on` renders as a Western-digit ISO date in all six locales.
- [ ] The changelog's empty state renders zero buttons.
- [ ] The content-currency chip's route resolves; E12's own tests are unchanged.
- [ ] `check_lonja_lists.sh app/lib` and `check_verdict_contract.sh app/lib` are clean.
- [ ] `packages/rule_engine/` untouched (D-7).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh           app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh     app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
tools/gates/no_directional_geometry.sh                                       app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(reference): add S22 and S23, the glossary and the per-jurisdiction changelog

The glossary orders by glossary_term.sort_order and never compares two localised
strings. Dart's String.compareTo is UTF-16 code-unit order: it puts Ñ after Z and
every Arabic term after every Latin one, and Dart ships no ICU collator. A test
asserts the committed Galicia seed carries a non-zero sort_order, so an all-zero
column fails in CI instead of degrading to insertion order on a boat.

A term_key present both globally and per jurisdiction renders twice, jurisdiction
first. That is not a duplicate — a term whose meaning differs by jurisdiction is
what a glossary is for.

The changelog's empty state is normal: §8 says the build tool emits the diff, so
the first shipped version for a jurisdiction has no rows. It is also the one
empty surface of eight with no action, because nothing the reader can do changes
it — which is the case T09's component is shaped around.

Version strings are isolated LTR runs and the transition glyph mirrors; changed_on
stays a Western-digit ISO date in every locale, because it is a quoted record
identifier rather than prose.

Task: E15/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
