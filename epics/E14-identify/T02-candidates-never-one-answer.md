# E14/T02 — Candidates: one or more, never one confident answer

| | |
|---|---|
| **Epic** | E14 — The identification key |
| **Branch** | `epic/14-identify` (shared) |
| **Commit** | `feat(identify): return a counted candidate list, never a single confident answer` |
| **Depends on** | T01 (traversal must reach a leaf before a leaf can be rendered) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.3 row "Candidate list", §5.2 reason 2, §6 S7 terminal states, §7.1 `key_leaf_species`, §6 S5 (the one-word hint a row may show) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | The candidate list is a ruled register of species rows. Rule 1 (the whole row is one tap target), rule 3 (`ListTile` and `DataTable` banned), rule 8 (a row states, never instructs) and rule 11 (the fixed slot order) are all binding here |
| `lonja-icons-and-plates` | Rule 7 and `references/engraved-plates.md` decide silhouette versus plate per row; T07 uses the same rule for protected and look-alike candidates |
| `lonja-buttons` | Rule 1 — one primary per screen — is the reason this screen has **no** primary action: a promoted button would rank one candidate above the others |
| `catchlaw-reference-database` | `key_leaf_species` joins `species` inside `reference.db` only; rule 11 forbids reaching across into `user.db` for anything |
| `catchlaw-conventions-index` | Invariant 2 (state a fact, never instruct) and invariant 3 (the citation contract) — this task must decide what a candidate row may claim, and it decides it downwards |
| `state-management-riverpod` | The candidate state is one more variant of the sealed state the `AsyncNotifier` already emits |
| `navigation-and-routing` | Tapping a candidate pushes S2 with a species id — the same destination the other three species paths use |
| `widget-golden-and-a11y-testing` | Row semantics and the tap-target assertions in the widget tests below |
| `testing-strategy` | Repository row-ordering tests belong at the data level; "no verdict is rendered" belongs at the widget level |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.3 row "Candidate list" | "Returns **one or more** candidates, never a single confident answer", backed by `key_leaf_species`, with the count visible |
| `SPEC.md` | §5.2 reason 2 | Why: a key is auditable and a classifier is not; a wrong confident classification on a protected species is the worst failure this app could have |
| `SPEC.md` | §6 S7 "Terminal states" | "candidate list (1..n species) → tap through to S2" |
| `SPEC.md` | §6 S5 | The precedent for what a species row may state: local name, silhouette, and a **one-word hint** (`45 cm` / `protected` / `closed`) |
| `SPEC.md` | §7.1 `key_leaf_species` | `PRIMARY KEY (node_id, species_id)`, `rank INTEGER NOT NULL DEFAULT 0` — ties are the normal case, not the exception |
| `SPEC.md` | §4.1 row "Species picker" | "Four paths land on the same species detail" — the key is the fourth |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rules 1, 3, 8, 9, 11 | Row anatomy and what an end slot may say |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The species row — slot table" | The six slots and their fixed order; slot 5 is the end slot, `TextAlign.end` |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Precedence" | Why a candidate list can never be empty, and what happens if it is (T03 owns that path) |
| `.claude/skills/lonja-icons-and-plates/references/engraved-plates.md` | "When a plate is REQUIRED" | Search-result rows: plate for protected and look-alike members, silhouette for ordinary species |
| `.claude/skills/lonja-buttons/SKILL.md` | rule 1 | One primary per screen — here, zero |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariants 2 and 3 | The banned lexicon and the citation contract, which bind what a row may claim |
| `FLUTTER_GUIDE.md` | §5.2, §8.1, §6.1 | The read path, widget classes rather than helper methods, test naming |
| `epics/DECISIONS.md` | D-3, D-7 | Six locales for the count string; no user-visible sentence in the engine |

## What this delivers

- `app/lib/domain/models/key_candidate.dart` — `KeyCandidate(speciesId, scientificName,
  silhouetteAsset, isProtected, hasLookAlike, rank)`. Immutable, const constructor.
- `app/lib/data/services/key_dao.dart` — one added query: `key_leaf_species` joined to `species`,
  `ORDER BY rank, species_id`.
- `app/lib/data/repositories/key_repository.dart` (+ `_drift.dart`) — `candidatesFor(int nodeId)`.
- `app/lib/ui/identify/view_models/identify_state.dart` — the `IdentifyCandidates` variant carrying
  the candidate list and the node it came from.
- `app/lib/ui/identify/view_models/identify_view_model.dart` — `choose` resolves a leaf into
  `IdentifyCandidates` instead of a couplet.
- `app/lib/ui/identify/widgets/candidate_list.dart` — the count header plus the rows, built from
  E08's species row.
- `app/lib/l10n/app_{ar,en,es,gl,ca,pt_BR}.arb` — `identifyCandidateCount`, an **ICU plural** with all
  six categories in `ar`, `one`/`many`/`other` in `es`, `ca` and `pt_BR`, `one`/`other` in `gl` and
  `en` (§9.5). T05 reuses this key for the live count during traversal; do not add a second one.
- Tests: `app/test/data/key_candidates_test.dart`,
  `app/test/ui/identify/candidate_list_test.dart`, and additions to
  `app/test/ui/identify/identify_view_model_test.dart`.

## Why it is built this way

**The count is rendered at n = 1.** This is the whole task in one sentence. A leaf holding a single
species is exactly where the temptation to say "this is a spangled emperor" lives, and taking it
converts the key into the classifier §5.2 rejected. So the header states "1 candidate" and the species
sits in a list of one, on the same row widget as a list of five. The user reads a hypothesis, not an
answer, and the hypothesis is his to accept.

**Rejected: auto-navigating to S2 when a leaf holds exactly one candidate.** It saves a tap and it is
wrong twice over. It presents a single candidate as a conclusion, which is the §5.2 objection stated
verbatim; and it destroys the ability to back out one step, because by the time the user sees anything
he is on a different screen with a different back stack. §5.2's second reason — "the user can see why
the key landed where it did and can back out one step" — is not a nicety. It is the argument for
excluding a classifier at all.

**Rejected: a primary action on the candidate screen.** `lonja-buttons` rule 1 allows one primary per
screen, and the obvious candidate is "Choose the first one". There is no primary here, deliberately:
the rows are the targets and they are equals. A promoted button would rank one candidate above the
rest with the app's own visual authority, which is the confident answer wearing a different hat. The
screen's actions are `Back one step` and `Start over` (T04), which are `secondary` and `quiet`.

**The row states a hint, not a verdict.** §6 S5 already establishes what a species row may carry: the
local name, the silhouette, and a one-word hint — `45 cm`, `protected`, `closed`. That is a category
label, not a rule statement, so invariant 3's citation contract is not engaged: the cited statement is
made on S2, one tap away, where a measurement and a zone exist. The key has neither, so it cannot
produce a verdict and does not try. T07 orders the rows by the strictness behind those hints; it does
not promote the hint into a sentence.

**Rejected: a bespoke candidate row.** E08 already ships the species row that S5 and S6 use, with the
slot order `lonja-lists-and-tables` rule 11 freezes. A second row type for candidates would reset the
five-second recognition the user has built on every other list, and would double the golden lanes.
The candidate list reuses it and passes a different end slot.

**`ORDER BY rank, species_id` — both columns.** `key_leaf_species.rank` has `DEFAULT 0`, so authored
content that never sets it produces an all-ties list. Without the `species_id` tie-break, the same leaf
renders in a different order on two devices with the same database file, and a user comparing notes
with a neighbour sees two different lists. T07 keeps the same tie-break underneath its strictness sort.

**The candidate set is never filtered by jurisdiction.** The key is morphological: `key_node` carries
no `jurisdiction_id`, and the fish in the hand does not know which zone chip is set. Dropping a
candidate because it has no rule row in the active jurisdiction would collapse §4.1's careful
distinction between "no rule exists" and "we have not transcribed this species" into an absence the
user cannot see. T07 sorts those candidates last and labels them; this task does not remove them.

## Tests first

Write every row before touching a production file. Run them. **They must fail.** A row that passes
before the implementation exists is testing nothing.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `KeyRepository.candidatesFor orders candidates by rank then species id` | leaf with ranks 1, 0, 0 | rank 0 rows first, ordered by species id | `rank` defaults to 0, so ties are normal; an unstable order changes the list between devices |
| 2 | `KeyRepository.candidatesFor returns one candidate for a single-species leaf` | leaf with one row | a list of length 1 | The n = 1 case is a candidate list, not a special case |
| 3 | `KeyRepository.candidatesFor returns every row of a five-species leaf` | leaf with five rows | all five | Truncating a candidate list is how a protected look-alike disappears |
| 4 | `IdentifyViewModel.choose emits candidates when the next node has no question` | option pointing at a leaf | state is `IdentifyCandidates` | Leaf detection drives the terminal state; §7.1 defines a leaf as a question-less node |
| 5 | `CandidateList states the candidate count with 1 candidate` | one candidate | the header states 1 | The rule that makes this task exist: never a single confident answer |
| 6 | `CandidateList states the candidate count with 5 candidates` | five candidates | the header states 5 | The count is a permanent element, not an n > 1 affordance |
| 7 | `CandidateList renders a row for every candidate` | five candidates | five rows | The list renders what the leaf holds, without a cap |
| 8 | `CandidateList builds no primary action` | five candidates | no primary-variant button in the tree | A promoted action ranks one candidate with the app's own authority |
| 9 | `CandidateList renders no verdict for any candidate` | a candidate whose species has a rule | no verdict stamp in the tree | The key has no measurement and no zone; it identifies, it never judges |
| 10 | `CandidateList row opens species detail with the candidate species id` | tap row 2 | S2 pushed with that species id | §4.1: four paths land on the same species detail |
| 11 | `CandidateList row target covers the whole row rect` | tap the row's start edge | the row callback fires | `lonja-lists-and-tables` rule 1 — a chevron-sized target is a silent dead row in wet gloves |
| 12 | `glove - CandidateList rows measure 76dp` | glove density on | row min height 76 | Rule 12: glove raises rows and changes nothing else |

```dart
// app/test/ui/identify/candidate_list_test.dart
import 'package:catchlaw/ui/identify/widgets/candidate_list.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/key_fixtures.dart';
import '../../utils/harness.dart';

void main() {
  testWidgets('CandidateList states the candidate count with 1 candidate', (tester) async {
    await tester.pumpWidget(harness(
      child: CandidateList(candidates: [kCandidateLethrinusNebulosus]),
    ));

    expect(find.text('1 candidate'), findsOneWidget);
  });

  testWidgets('CandidateList renders no verdict for any candidate', (tester) async {
    await tester.pumpWidget(harness(
      child: CandidateList(candidates: kCandidatesFiveEmperors),
    ));

    expect(find.byType(LonjaVerdictStamp), findsNothing);
  });

  testWidgets('CandidateList builds no primary action', (tester) async {
    await tester.pumpWidget(harness(
      child: CandidateList(candidates: kCandidatesFiveEmperors),
    ));

    final primaries = tester
        .widgetList<LonjaButton>(find.byType(LonjaButton))
        .where((b) => b.variant == LonjaButtonVariant.primary);
    expect(primaries, isEmpty);
  });
}
```

```dart
// app/test/data/key_candidates_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../../testing/models/key_fixtures.dart';

void main() {
  group('KeyRepository', () {
    test('.candidatesFor orders candidates by rank then species id', () async {
      final repository = DriftKeyRepository(await openKeyFixtureDao());

      final result = await repository.candidatesFor(kKeyLeafEmperors.id);

      expect(
        result.valueOrNull!.map((c) => c.speciesId),
        orderedEquals(<int>[kSpeciesLentjan, kSpeciesNebulosus, kSpeciesHarak]),
      );
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/data/key_candidates_test.dart test/ui/identify/` → 12 failures.
If any passes now, that test is wrong.

## Implementation outline

1. `KeyCandidate` in `app/lib/domain/models/key_candidate.dart`. `isProtected` and `hasLookAlike` come
   from the joined `species` and `lookalike` rows — they are needed here only to choose plate versus
   silhouette (`lonja-icons-and-plates` rule 7); T07 uses them again for ordering.
2. Add the join to `key_dao.dart`: `key_leaf_species` → `species`, `ORDER BY rank, species_id`. The
   order lives in SQL, not in a Dart `sort`, so the test in row 1 pins the query rather than a
   comparator that a later refactor can quietly drop.
3. `candidatesFor` on the repository, returning `Future<Result<List<KeyCandidate>>>`.
4. Extend the sealed state with `IdentifyCandidates`; make `choose` branch on whether the target node
   has a `questionKey`. A question-less node with zero candidates is not this task's problem — T03
   catches it, and until T03 lands it is an unhandled state the analyser will flag on the exhaustive
   switch. That is the correct ordering: the switch is exhaustive from the first commit.
5. `CandidateList` — a count header over `ListView.builder` of E08's species row. Never
   `SingleChildScrollView(child: Column(...))` (`lonja-lists-and-tables` anti-pattern), even at n = 5.
6. Add `identifyCandidateCount` to all six ARB files with the correct plural categories per §9.5: six
   for `ar`, `one`/`many`/`other` for `es`, `ca`, `pt_BR`, `one`/`other` for `gl` and `en`.
7. `dart run build_runner build --delete-conflicting-outputs`; commit generated files.
8. Re-run the whole `app/` suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 tests pass, and each failed first.
- [ ] The candidate count renders at n = 1 as well as at n > 1, in every locale.
- [ ] No `LonjaButtonVariant.primary` is built on the candidate state.
- [ ] No verdict type, verdict widget or `Citation` is constructed anywhere under
      `app/lib/ui/identify/`.
- [ ] The list is built with `ListView.builder`; `grep -rn 'ListTile\|DataTable' app/lib/ui/identify/`
      returns nothing.
- [ ] `identifyCandidateCount` exists in all six ARB files and `ar` carries all six plural categories
      (§9.5, D-3).
- [ ] The candidate list reuses E08's species row; no second species-row widget exists in
      `app/lib/ui/identify/`.
- [ ] No candidate is dropped for any reason — the repository returns every `key_leaf_species` row for
      the node.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh         app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh         app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh           app/lib
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
feat(identify): return a counted candidate list, never a single confident answer

A leaf holding one species is where the key is most tempted to state a
conclusion, so that is exactly where the count is rendered: "1 candidate",
in a list of one, on the same row as a list of five. SPEC §5.2 excludes
photo-AI because a key is auditable and a classifier is not — collapsing a
single-candidate leaf straight through to the species detail would rebuild
the classifier out of a key and remove the one step the user can back out of.

The screen has no primary action on purpose. The rows are equals, and a
promoted button would rank one of them with the app's own authority. Rows
carry the SPEC §6 S5 one-word hint rather than a rule statement, so the
citation contract stays where the statement is made, on S2.

Task: E14/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
