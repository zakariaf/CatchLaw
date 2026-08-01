# E14/T07 — Multi-candidate ordering

| | |
|---|---|
| **Epic** | E14 — The identification key |
| **Branch** | `epic/14-identify` (shared) |
| **Commit** | `feat(identify): order multi-candidate results strictest applicable rule first` |
| **Depends on** | T02 (the candidate list), T05 (the count line the ordered list sits beneath) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.3 row "Candidate list", §5.1 point 3, §6 S5 (the one-word hint), §7.3 (finding precedence, ambiguity, expiry) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | Invariants 2, 3, 4 and 5 all land on this screen at once: what a row may state, whether a citation is owed, colour never alone, and an expired rule still counting |
| `lonja-icons-and-plates` | Rule 7 and `references/engraved-plates.md`: a protected species or either member of a look-alike pair gets the full engraved **plate**, inline at column width — a silhouette is a hint and this is where a hint is not enough |
| `lonja-lists-and-tables` | Rules 8, 9 and 11: the row states, never instructs; status is glyph **and** word **and** colour; the slot order does not move for this screen |
| `catchlaw-reference-database` | Rule 11 — the engine takes plain Dart values; no query spans the two databases to build this ordering |
| `state-management-riverpod` | The ordered list is derived state that must re-derive when the active zone changes |
| `accessibility-as-code` | The never-colour-alone floor the `sunlight -` row below proves |
| `widget-golden-and-a11y-testing` | The greyscale/sunlight lane |
| `testing-strategy` | The ordering is a pure function and belongs in unit tests; the plate-versus-silhouette choice is a widget test |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.3 row "Candidate list" | "multi-candidate results show the **strictest applicable rule first**, with the candidate count visible" |
| `SPEC.md` | §7.3 "Finding precedence" | The order this task encodes verbatim: `is_protected` → closed season → `max_size_mm` → `min_size_mm` → bag limit → vessel limit |
| `SPEC.md` | §7.3 steps 1–4 | Expiry does not delete and is tagged, not filtered; two equally specific rules return **both** and the app never silently reports the more permissive one |
| `SPEC.md` | §5.1 point 3 | "It refuses to resolve genuine legal ambiguity… An advice product would pick one" |
| `SPEC.md` | §4.1 rows "Unknown species", "No-rule-vs-no-data" | A species with no transcribed rule is an explicit state that does **not** imply legality, and it is distinct from "no limit exists" |
| `SPEC.md` | §6 S5 | The one-word hint a species row may carry: `45 cm` / `protected` / `closed` |
| `SPEC.md` | §13 | Rule evaluation < 10 ms over ≤ 20 candidate rows — the budget this task spends once per candidate |
| `.claude/skills/lonja-icons-and-plates/references/engraved-plates.md` | "Silhouette versus plate", "When a plate is REQUIRED" | The table: search-result row + protected → plate; + look-alike member → plate; ordinary → silhouette. And what each drawing *claims* |
| `.claude/skills/lonja-icons-and-plates/SKILL.md` | rules 7, 12 | A plate is evidence and a silhouette is a hint; a mark is never the only signal |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rules 8, 9 | The end slot states rather than instructs; `LonjaPill` carries glyph, word and colour together |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariants 3, 4, 5 | The citation contract, the three-signal table, and "stale beats absent" |
| `FLUTTER_GUIDE.md` | §1.9 | Use-cases are mandatory here: this one merges two repositories, and repositories may not know each other |
| `FLUTTER_GUIDE.md` | §2.5 rule 3 | Joins between reference data and rules go in `domain/use_cases/`, nowhere else |
| `FLUTTER_GUIDE.md` | §6.1 | Test naming, including the `sunlight - ` axis prefix |
| `epics/DECISIONS.md` | D-7 | The engine returns types and holds no user-visible sentence; the strictness rank is derived in the app from what E03 already returns |

## What this delivers

- `app/lib/domain/models/candidate_strictness.dart` — `CandidateStrictness`, an ordered enum whose
  members are §7.3's finding precedence and nothing else: `protected`, `closedSeason`, `maximumSize`,
  `minimumSize`, `bagLimit`, `vesselLimit`, `noRestriction`, `noRuleRecorded`.
- `app/lib/domain/use_cases/order_key_candidates.dart` — `OrderKeyCandidates`, which takes the
  candidates T02 produced plus the active `(jurisdiction, zone, water type, date)` and returns them
  ordered, each carrying its strictness and its §6 S5 hint.
- `app/lib/domain/models/ordered_candidate.dart` — `OrderedCandidate(KeyCandidate candidate,
  CandidateStrictness strictness, bool isAmbiguous, bool isExpired)`.
- `app/lib/ui/identify/widgets/candidate_list.dart` — updated to render the ordered list, the
  plate-or-silhouette choice, and the status pill.
- `app/lib/ui/identify/view_models/identify_view_model.dart` — the candidate state holds ordered
  candidates and re-derives when the active zone changes.
- Tests: `app/test/domain/order_key_candidates_test.dart` and additions to
  `app/test/ui/identify/candidate_list_test.dart`.

## Why it is built this way

**The ordering exists so an ambiguous identification never reads more permissively than its safest
candidate.** A five-candidate list is a statement that the app does not know which fish this is. If the
first row says `45 cm` and the third says `protected`, a user who reads the first row and stops has
been told something false by the *arrangement*, not by any sentence on the screen. §5.1 point 3 says
the app refuses to resolve genuine ambiguity and §7.3 step 4 says it never silently reports the more
permissive rule; ordering is how those two commitments survive contact with a list.

**The rank is §7.3's finding precedence, unchanged.** `is_protected` → closed season → `max_size_mm`
→ `min_size_mm` → bag limit → vessel limit. Inventing a second severity scale for this screen would
put two orderings in the product that disagree the first time §7.3 is amended. The enum is that line
of the spec and nothing else, and its doc comment cites it.

**Ordering never filters.** The candidate set comes from `key_leaf_species` and is morphological;
the rules are jurisdictional. A candidate with no rule row in the active jurisdiction is not more
permissive, it is unknown — §4.1 keeps "no rule recorded" and "not transcribed" as distinct states
precisely because neither means legal. Such candidates sort **last** and are labelled, never dropped.
Dropping one would delete the protected look-alike the fisher most needs to see the moment a
jurisdiction's transcription is incomplete, which is most jurisdictions until E22 finishes.

**An ambiguous candidate is ranked by its stricter rule.** §7.3 step 4 returns both rules and renders
D4. For *ordering*, the candidate takes the stricter of the two — because the alternative is choosing
the more permissive one to decide a position, which is the thing §7.3 step 4 exists to forbid. The row
is marked ambiguous; resolving the ambiguity remains S2's job and the app still refuses to choose.

**An expired rule ranks exactly as an unexpired one.** Invariant 5 and §7.3 step 1: expiry sets a flag
and never filters. A protected species whose instrument expired last month is still protected as far
as the last verified text is concerned, and demoting it down the list would be the same defect as
hiding it — the amber bar states the staleness, the ordering does not.

**Tie-breaks are `key_leaf_species.rank`, then species id.** The authored rank is the content author's
opinion about which candidate is most likely; it is the right tie-break and the wrong primary sort,
because likelihood is not strictness. Species id underneath makes the list identical on two devices
holding the same database.

**The row states a hint, not a sentence.** §6 S5 establishes that a species row may carry a one-word
hint — `45 cm`, `protected`, `closed` — and that is what this list renders, in the `LonjaPill` that
carries glyph, word and colour together. No `Citation` is constructed here and invariant 3 is not
weakened: no rule statement is made on this screen, and the cited statement is one tap away on S2,
where a measurement and a zone exist.

**A protected or look-alike candidate is drawn as a plate.** `engraved-plates.md` is explicit — a
silhouette claims "this is roughly the shape you have"; a plate claims "these are the characters that
identify this specimen" — and its table requires a plate in a search-result row for a protected species
or either member of a look-alike pair. This screen is where that matters most: an ambiguous list
containing a protected species is exactly the case where a smudge of outline cannot separate two
emperors, and the fisher carries the fine.

**This task adds nothing to `packages/rule_engine/`.** The strictness rank is derived in
`app/lib/domain/` from the findings E03's engine already returns (D-7: the engine returns types, the
app owns every word). The use case lives in `domain/use_cases/` because it merges the key repository
with the rule repository and repositories may not know each other (`FLUTTER_GUIDE.md` §2.5 rule 3);
§1.9 says a domain layer is mandatory here for exactly this reason.

**Rejected: ordering by the candidate's authored rank alone.** It is one column and no query. It is
rejected because `rank` is a likelihood judgement made by a content author who did not know the user's
zone or the date, and the whole point of the ordering is that it is computed against the rules that
actually apply today, where he is standing.

## Tests first

Write every row before touching a production file. Run them. **They must fail.** A row that passes
before the implementation exists is testing nothing.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `OrderKeyCandidates places a protected candidate before a size-limited candidate` | one protected, one with `min_size_mm` | protected first | The headline case, and the one that costs a fine |
| 2 | `OrderKeyCandidates places a closed-season candidate before a minimum-size candidate` | one in a closed season today, one sized | closed season first | §7.3's precedence, second rung |
| 3 | `OrderKeyCandidates places a maximum-size candidate before a minimum-size candidate` | one of each | max first | §7.3 orders `max_size_mm` above `min_size_mm`; a rank that collapses them is a different scale |
| 4 | `OrderKeyCandidates places a candidate with no recorded rule last` | two ruled, one unruled | unruled last, still present | Absence is not permissiveness (§4.1), and it is not a reason to hide a species |
| 5 | `OrderKeyCandidates keeps every candidate when ordering` | five in, mixed | five out | Ordering is not filtering; this is the row that stops a later "tidy-up" dropping one |
| 6 | `OrderKeyCandidates orders two equally strict candidates by key_leaf_species rank` | two protected, ranks 1 and 0 | rank 0 first | The authored tie-break, kept from T02 |
| 7 | `OrderKeyCandidates orders two candidates of equal rank by species id` | two protected, both rank 0 | ascending species id | Two devices with one database file must render one order |
| 8 | `OrderKeyCandidates ranks an ambiguous candidate by its stricter rule` | two equally specific rules, one protected | ranked protected, marked ambiguous | §7.3 step 4 and §5.1 point 3 — never the more permissive one |
| 9 | `OrderKeyCandidates ranks an expired protected rule as protected` | `valid_to` in the past, `is_protected` | ranked protected, marked expired | Invariant 5: expiry flags, it never filters or demotes |
| 10 | `OrderKeyCandidates re-orders when the active zone changes` | same candidates, two zones | two different orders | Rules are zone-specific (§7.3 step 2); an order computed for the wrong zone is worse than none |
| 11 | `CandidateList renders a plate for a protected candidate` | protected candidate | a plate, not a silhouette | `engraved-plates.md`: a silhouette cannot separate two emperors, and the fisher carries the fine |
| 12 | `CandidateList renders a plate for a look-alike pair member` | candidate with `lookAlikeOf` | a plate | Both members of a pair carry a plate; this is the second half of the same rule |
| 13 | `CandidateList renders a silhouette for an ordinary candidate` | unprotected, no look-alike | a silhouette | The negative case — a plate on every row makes the plate mean nothing |
| 14 | `sunlight - CandidateList distinguishes the protected candidate without colour` | sunlight theme | glyph and word present, order unchanged | Invariant 4: sunlight deletes every grey and oxblood carries two different states |

```dart
// app/test/domain/order_key_candidates_test.dart
import 'package:catchlaw/domain/models/candidate_strictness.dart';
import 'package:catchlaw/domain/use_cases/order_key_candidates.dart';
import 'package:test/test.dart';

import '../../testing/models/key_fixtures.dart';

void main() {
  group('OrderKeyCandidates', () {
    test('places a protected candidate before a size-limited candidate', () {
      final ordered = orderKeyCandidates(
        candidates: [kCandidateSizeLimited, kCandidateProtected],
        rulesBySpecies: kRulesGaliciaToday,
      );

      expect(ordered.first.candidate.speciesId, kCandidateProtected.speciesId);
      expect(ordered.first.strictness, CandidateStrictness.protected);
    });

    test('places a candidate with no recorded rule last', () {
      final ordered = orderKeyCandidates(
        candidates: [kCandidateNoRule, kCandidateSizeLimited, kCandidateProtected],
        rulesBySpecies: kRulesGaliciaToday,
      );

      expect(ordered.last.strictness, CandidateStrictness.noRuleRecorded);
      expect(ordered, hasLength(3));
    });

    test('ranks an expired protected rule as protected', () {
      final ordered = orderKeyCandidates(
        candidates: [kCandidateSizeLimited, kCandidateProtectedExpired],
        rulesBySpecies: kRulesGaliciaToday,
      );

      expect(ordered.first.strictness, CandidateStrictness.protected);
      expect(ordered.first.isExpired, isTrue);
    });

    // … one test per row above, one behaviour each
  });
}
```

```dart
// app/test/ui/identify/candidate_list_test.dart  (additions)
testWidgets('CandidateList renders a plate for a protected candidate', (tester) async {
  await tester.pumpWidget(harness(
    child: CandidateList(candidates: [kOrderedProtected, kOrderedOrdinary]),
  ));

  expect(find.byType(LonjaPlate), findsOneWidget);
  expect(find.byType(LonjaSilhouette), findsOneWidget);
});

testWidgets('sunlight - CandidateList distinguishes the protected candidate without colour',
    (tester) async {
  await tester.pumpWidget(harness(
    theme: LonjaThemeMode.sunlight,
    child: CandidateList(candidates: [kOrderedProtected, kOrderedOrdinary]),
  ));

  final pill = tester.widget<LonjaPill>(find.byType(LonjaPill).first);
  expect(pill.glyph, isNotNull);
  expect(pill.label, isNotEmpty);
});
```

**Run:** `cd app && flutter test test/domain/order_key_candidates_test.dart test/ui/identify/` → 14
failures. If any passes now, that test is wrong.

## Implementation outline

1. `CandidateStrictness` — the enum in §7.3's order, with a doc comment naming §7.3 as its source and
   a note that a change to §7.3 changes this enum and nothing else.
2. `orderKeyCandidates` — a pure function over plain values: candidates in, resolved rules in, ordered
   candidates out. No repository, no `Ref`, no Flutter import, so it unit-tests with `package:test`.
3. `OrderKeyCandidates` use case — the thin layer that fetches from both repositories and calls the
   pure function. This is the only place the key repository and the rule repository meet
   (`FLUTTER_GUIDE.md` §2.5 rule 3).
4. Map each candidate's resolved findings to a strictness: the **highest-precedence** finding that
   applies. Ambiguous rules contribute their stricter side. An expired rule contributes normally and
   sets `isExpired`. No resolved rule at all yields `noRuleRecorded`.
5. Sort by `(strictness.index, rank, speciesId)`. Use a stable sort and assert the tie-breaks rather
   than relying on the input order.
6. `CandidateList` — resolve the art per row through the same guard `lonja-icons-and-plates` prescribes
   (`isProtected || lookAlikeOf != null` → plate), and render the §6 S5 hint in a `LonjaPill` with
   glyph, word and colour.
7. Re-run the whole `app/` suite; T02's tests still apply unchanged and must stay green — in
   particular, "renders no verdict" and "builds no primary action".

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 tests pass, and each failed first.
- [ ] `order_key_candidates.dart` and `candidate_strictness.dart` are at **100% branch coverage** and
      import nothing from Flutter or drift.
- [ ] `CandidateStrictness`'s member order is §7.3's finding precedence, and its doc comment says so.
- [ ] The ordered list contains exactly the candidates the leaf holds — no filter, in any code path.
- [ ] An expired rule ranks identically to an unexpired one (invariant 5).
- [ ] Every protected candidate and every look-alike pair member renders a `LonjaPlate`; ordinary
      candidates render a silhouette.
- [ ] Every status is glyph **and** word **and** colour, and the `sunlight -` test proves it survives
      with colour deleted (invariant 4).
- [ ] No `Citation` and no verdict type is constructed under `app/lib/ui/identify/` (invariant 3 is
      satisfied by making no rule statement here).
- [ ] `packages/rule_engine/` is untouched by this commit (D-7).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh         app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh         app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh           app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
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
feat(identify): order multi-candidate results strictest applicable rule first

A five-candidate list already says the app does not know which fish this is.
If the first row reads 45 cm and the third reads protected, the arrangement
has told the fisher something false that no sentence on the screen ever said.
SPEC §5.1 point 3 and §7.3 step 4 both forbid silently reporting the more
permissive rule, so the order is computed from §7.3's finding precedence
unchanged — protected, closed season, max size, min size, bag limit, vessel
limit — with key_leaf_species.rank and then species id underneath, so two
devices holding one database render one order.

Ordering never filters. A candidate with no transcribed rule sorts last and
stays, because SPEC §4.1 keeps "no rule recorded" distinct from "not
transcribed" and neither means legal. An ambiguous candidate takes the
stricter of its two rules for position only; S2 still refuses to choose. An
expired rule ranks exactly as a live one — expiry flags, it never demotes.

Protected candidates and look-alike pair members render the engraved plate
rather than a silhouette: a silhouette claims roughly this shape, a plate
claims these are the identifying characters, and this list is where the
difference is the fine.

Task: E14/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
