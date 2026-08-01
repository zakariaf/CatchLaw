# E14/T05 — The candidate count and the six-couplet ceiling

| | |
|---|---|
| **Epic** | E14 — The identification key |
| **Branch** | `epic/14-identify` (shared) |
| **Commit** | `feat(identify): show the live candidate count and assert the six-couplet ceiling` |
| **Depends on** | T01 (traversal), T02 (`identifyCandidateCount` and the candidate query) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.3 rows "Morphological key" and "Candidate list", §6 S7 elements, §7.1 `key_node` / `key_option` / `key_leaf_species`, §9.5 plurals, §13 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | The subtree counts are one recursive read of `reference.db`. Rules 2 and 3 (nothing awaited before `runApp`, read-only open) constrain when and how it runs |
| `catchlaw-conventions-index` | Rule 6, the layer map: the graph walk is domain logic over plain values, not a widget concern and not a DAO concern |
| `lonja-lists-and-tables` | The count line sits above a ruled list; `references/row-and-table-anatomy.md` fixes tabular figures and `TextAlign.end` for every numeric |
| `lonja-typography` | The count is a numeral rendered in six locales; the mono role and tabular figures come from here |
| `state-management-riverpod` | Where the memoised counts live so that a tap re-reads nothing |
| `persistence-drift` | The recursive query and `customSelect` |
| `accessibility-as-code` | The count is announced; it is text, never a colour-coded badge |
| `testing-strategy` | Which of these rows is a pure-Dart unit test, which needs a fixture database, and which needs the built one |
| `widget-golden-and-a11y-testing` | The `ar` plural lane; six ICU categories are easy to author and easy to get wrong |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.3 row "Morphological key" | "Never more than 6 couplets to a candidate list" — the ceiling this task asserts |
| `SPEC.md` | §4.3 row "Candidate list" | The candidate count is visible |
| `SPEC.md` | §6 S7 elements | "live candidate count" — live means it narrows as the key narrows, not only at the leaf |
| `SPEC.md` | §7.1 `key_node`, `key_option`, `key_leaf_species` | `parent_node_id` versus `next_node_id`; the composite primary key that lets one species appear at two leaves |
| `SPEC.md` | §9.5 | Arabic needs all six ICU categories; `es`, `ca` and `pt_BR` carry `many`; only `gl` is `one`/`other` |
| `SPEC.md` | §13 | The published targets — search < 50 ms at 400 species / 2,400 names, rule evaluation < 10 ms, cold start < 1.2 s. **None of them covers the key**, which is why this task designs against a structure rather than a number |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rules 2, 3 | Lazy open, read-only, no work on the launch path |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "Ownership matrix" | `reference.db` is generated content; a derived count is never written back into it |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "Numeric alignment and RTL mirroring" | Tabular figures always, `TextAlign.end` never `TextAlign.right`, locale `NumberFormat` never `'$n'` |
| `.claude/skills/catchlaw-conventions-index/SKILL.md` | rule 6 | The graph walk belongs in `domain/`, above the repository and below the widget |
| `FLUTTER_GUIDE.md` | §1.9 | Why a domain layer is mandatory here, and that ours is a boundary the official docs do not cover |
| `FLUTTER_GUIDE.md` | §6.1, §6.4 | Test naming with interpolated loop parameters; the coverage budget |
| `epics/DECISIONS.md` | D-3, D-6 | Six locales; the extracted read-only database this task reads |

## What this delivers

- `app/lib/domain/use_cases/key_depth.dart` — `keyDepth(KeyGraph)`, a pure function returning the
  longest couplet path from a root, or a `KeyCycleDetected` failure. No Flutter import.
- `app/lib/domain/use_cases/key_subtree_count.dart` — `KeySubtreeCount`, the distinct-species count
  reachable from each node through `next_node_id` edges.
- `app/lib/domain/models/key_graph.dart` — the plain-value graph both functions walk: node id →
  option edges, node id → leaf species ids.
- `app/lib/data/services/key_dao.dart` — one added query returning the whole key graph for a
  `taxon_group` (node ids, option edges, leaf species ids). One read per S7 session.
- `app/lib/data/repositories/key_repository.dart` (+ `_drift.dart`) — `graphFor(TaxonGroup)`.
- `app/lib/ui/identify/view_models/identify_view_model.dart` — the graph and its derived counts are
  loaded once in `start` and held in state; `choose` reads the count from memory.
- `app/lib/ui/identify/widgets/candidate_count_line.dart` — the live count, above the couplet and
  above the candidate list, using the `identifyCandidateCount` plural T02 added.
- Tests: `app/test/domain/key_depth_test.dart`, `app/test/domain/key_subtree_count_test.dart`,
  `app/test/data/key_graph_reference_test.dart`, and additions to
  `app/test/ui/identify/identify_screen_test.dart`.

## Why it is built this way

**Reachability follows `next_node_id`, not `parent_node_id`.** §7.1 gives both edges. `parent_node_id`
is a back-pointer that makes the authored tree printable; `next_node_id` is the edge the user walks,
and it is the only one that can be null. A count computed over `parent_node_id` would include nodes
the user cannot reach from where he is standing and would count a dead-end branch's subtree as if it
were still in play. The two should agree, and content that lets them disagree is a defect — but the
count must be right *first*, so a fixture where they disagree pins the choice (row 2).

**The count is distinct species, not leaf rows.** `key_leaf_species` has
`PRIMARY KEY (node_id, species_id)`, so one species may legitimately appear at two leaves — a key
often reaches the same fish by two routes. Counting rows would tell the user there are 9 candidates
where there are 7, and the number would grow every time content added a second route to a species
already listed.

**A dead-end option contributes zero.** An option with a null `next_node_id` reaches nothing, so it
adds nothing to its parent's count. This is the arithmetic that makes the live count honest: as the
user narrows, the number must fall, and a branch that leads nowhere must not inflate the number he
sees before he takes it.

**One read per session, memoised.** The count changes on every tap, so the naive implementation is a
query per tap. `SPEC.md` §13 publishes targets for search, rule evaluation, point-in-polygon and FTS
and **none for the key**, so there is no number to hold this to — which is exactly why the structure
has to be right rather than measured. One recursive read at `start`, held in state, and every
subsequent count is a map lookup. This also keeps the read off the launch path entirely
(`catchlaw-reference-database` rule 2): S7 is opened by choice, and a session that never opens it
never runs the query.

**Rejected: a `candidate_count` column materialised by the content build.** It is faster and it is
the wrong place. The count is a function of the graph, so a stored column can disagree with the graph
after any content edit — and the failure is silent, because a wrong number looks exactly like a right
one. Deriving it at run time from the same rows the traversal walks makes disagreement impossible.
`reference.db` is also never written by the app (`catchlaw-reference-database` rule 3), so the column
would have to be authored, reviewed and re-derived for every jurisdiction E22 adds.

**The six-couplet ceiling is asserted, not assumed.** §4.3 states it as an acceptance condition —
"Never more than 6 couplets to a candidate list" — and an acceptance condition nobody executes is a
sentence. `keyDepth` computes the longest path per root, and the test in row 9 runs it against the
**built** `reference.db` so that content authored in E22 trips it rather than a fixture that will
always pass. See the epic's Risk 2: confirm E05 left a reusable built-database fixture before writing
that row. If it did not, the assertion moves to `tools/content_builder` and this task keeps rows 6–8
only — record which of the two happened in the commit body.

**Cycle detection is not defensive programming.** A `next_node_id` pointing at an ancestor is a
plausible authoring mistake, and its consequences are severe in both directions: the depth walk never
terminates, and the traversal lets the user loop forever answering the same three couplets. `keyDepth`
returns a typed `KeyCycleDetected` naming the node rather than recursing until the stack ends.

**The count is a numeral in six locales.** It goes through the `identifyCandidateCount` plural T02
added — six ICU categories in `ar`, `one`/`many`/`other` in `es`, `ca` and `pt_BR`,
`one`/`other` in `gl` and `en` (§9.5) — and through the locale `NumberFormat`, never `'$n'`. Do not
add a second count key here.

## Tests first

Write every row before touching a production file. Run them. **They must fail.** A row that passes
before the implementation exists is testing nothing.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `KeySubtreeCount.of counts distinct species reachable through next_node_id edges` | 3-level graph, 7 species | 7 at the root | The headline behaviour |
| 2 | `KeySubtreeCount.of ignores parent_node_id when it disagrees with next_node_id` | a node whose `parent_node_id` claims a subtree its options do not reach | the `next_node_id` answer | The two edges can disagree; only one is the edge the user walks (epic Risk 7) |
| 3 | `KeySubtreeCount.of counts a species listed at two leaves once` | same species at two leaves | counted once | `PRIMARY KEY (node_id, species_id)` allows it; counting rows overstates the list |
| 4 | `KeySubtreeCount.of counts zero for a dead-end option` | option with null `nextNodeId` | 0 | A branch that leads nowhere must not inflate the number before the user takes it |
| 5 | `KeySubtreeCount.of on a leaf equals its key_leaf_species row count` | leaf with 3 species | 3 | The terminal case must agree with what T02's list renders |
| 6 | `keyDepth returns 6 for a six-couplet path` | a chain of six couplets | 6 | The ceiling's boundary — the value that must pass, not fail |
| 7 | `keyDepth returns 7 for a seven-couplet path` | a chain of seven | 7 | The value the §4.3 assertion must catch; a depth function that saturates at 6 hides the defect |
| 8 | `keyDepth returns the longest path when two branches differ in length` | branches of 2 and 5 | 5 | The ceiling is about the worst path, not the average |
| 9 | `keyDepth reports a cycle when next_node_id points at an ancestor` | node 3 → node 1 | `KeyCycleDetected(nodeId: 1)`, no stack overflow | An authoring mistake that hangs the walk and loops the user forever |
| 10 | `reference.db key graph reaches every candidate list within 6 couplets` | the **built** database | every root's depth ≤ 6 | §4.3's acceptance condition, executed against real content (epic Risk 2) |
| 11 | `IdentifyScreen states the candidate count at the taxon_group entry points` | finfish root, 7 species | 7 stated | "Live" starts before the first couplet, not at the leaf |
| 12 | `IdentifyScreen states a smaller candidate count after an option is chosen` | choose the branch holding 3 of 7 | 3 stated | The number narrowing is the feedback that the key is working |
| 13 | `IdentifyViewModel reads the key graph once per session` | walk 4 couplets | the fake records exactly 1 `graphFor` call | A query per tap on a five-year-old Android, for a number with no §13 budget |
| 14 | `ar - IdentifyScreen states the candidate count with $n candidates` (loop: 1, 2, 3, 11) | `ar` locale | the correct ICU category each time | Arabic has six plural categories and three of these four select different ones (§9.5) |

```dart
// app/test/domain/key_depth_test.dart
import 'package:catchlaw/domain/use_cases/key_depth.dart';
import 'package:test/test.dart';

import '../../testing/models/key_fixtures.dart';

void main() {
  group('keyDepth', () {
    test('returns 6 for a six-couplet path', () {
      expect(keyDepth(kKeyGraphSixCouplets).valueOrNull, 6);
    });

    test('returns 7 for a seven-couplet path', () {
      expect(keyDepth(kKeyGraphSevenCouplets).valueOrNull, 7);
    });

    test('reports a cycle when next_node_id points at an ancestor', () {
      expect(keyDepth(kKeyGraphCyclic).failureOrNull, isA<KeyCycleDetected>());
    });
  });
}
```

```dart
// app/test/data/key_graph_reference_test.dart
void main() {
  test('reference.db key graph reaches every candidate list within 6 couplets', () async {
    final repository = DriftKeyRepository(await openBuiltReferenceKeyDao());

    for (final entry in (await repository.entryPoints()).valueOrNull!) {
      final graph = (await repository.graphFor(entry.group)).valueOrNull!;
      expect(
        keyDepth(graph).valueOrNull,
        lessThanOrEqualTo(6),
        reason: 'SPEC 4.3: never more than 6 couplets — ${entry.group.name}',
      );
    }
  });
}
```

```dart
// app/test/ui/identify/identify_screen_test.dart  (additions)
for (final n in <int>[1, 2, 3, 11]) {
  testWidgets('ar - IdentifyScreen states the candidate count with $n candidates', (tester) async {
    await tester.pumpWidget(harness(
      locale: const Locale('ar'),
      repository: FakeKeyRepository.withCandidateCount(n),
      child: const IdentifyScreen(),
    ));
    await tester.pumpAndSettle();

    expect(find.text(arCandidateCount(n)), findsOneWidget);
  });
}
```

**Run:** `cd app && flutter test test/domain/ test/data/key_graph_reference_test.dart
test/ui/identify/` → 17 failures (row 14 expands to four). If any passes now, that test is wrong.

## Implementation outline

1. `KeyGraph` in `app/lib/domain/models/key_graph.dart`: `Map<int, List<int?>> edges` (null = dead
   end) and `Map<int, Set<int>> leafSpecies`, plus the root ids. Plain values, no drift types.
2. `key_depth.dart`: an iterative depth-first walk with an explicit visited set on the current path,
   returning `Result<int, KeyCycleDetected>`. Iterative rather than recursive so that a deep authored
   key cannot end the isolate before the cycle check reports.
3. `key_subtree_count.dart`: one post-order pass producing `Map<int, int>` of node id → distinct
   species count. Union of child sets, not a sum, so a species reachable twice is counted once; the
   intermediate sets are discarded, only the counts are kept.
4. `key_dao.dart`: one query per `taxon_group` returning nodes, option edges and leaf species rows.
   A recursive CTE over `key_option` is fine; so are three flat selects assembled in
   `key_mapper.dart`. Pick the one that reads plainly and keep the mapping in `data/model/`.
5. The view model loads `graphFor` in `start`, derives the counts once, and holds both in state.
   `choose` looks the count up; it never calls the repository for a number.
6. `CandidateCountLine` — one `Text` through the `identifyCandidateCount` plural, mono tabular
   figures, `TextAlign.end`, locale `NumberFormat`.
7. Confirm the epic's Risk 2 before writing row 10, and record the outcome in the commit body.
8. Re-run the whole `app/` suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 tests pass, and each failed first.
- [ ] `key_depth.dart` and `key_subtree_count.dart` are at **100% branch coverage** and import nothing
      from Flutter or drift.
- [ ] Every root in the built `reference.db` reaches its candidate lists in ≤ 6 couplets — or, if the
      epic's Risk 2 resolved the other way, the commit body names where that assertion now lives.
- [ ] The count falls as the key narrows and is stated at the entry points, on every couplet, and
      above the candidate list.
- [ ] Exactly one `graphFor` call per S7 session, proved by the fake's call log.
- [ ] The count uses the single `identifyCandidateCount` plural from T02; no second count key exists,
      and `ar` still carries all six categories (§9.5, D-3).
- [ ] No `'$n'` string interpolation renders the number, and no `TextAlign.right` appears.
- [ ] `reference.db` is not written to, and no derived count is persisted anywhere.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh         app/lib
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
feat(identify): show the live candidate count and assert the six-couplet ceiling

The count follows key_option.next_node_id rather than key_node.parent_node_id
— the back-pointer makes the authored tree printable, the option edge is what
the user walks — and it counts distinct species rather than key_leaf_species
rows, because the composite primary key lets one fish be reached by two
routes and counting rows would report 9 candidates where there are 7. A
dead-end option contributes zero, so the number falls honestly as the key
narrows.

One recursive read per S7 session, memoised. SPEC §13 publishes no latency
target for the key — search, rule evaluation, point-in-polygon and FTS all
have one and this does not — so the structure has to be right rather than
measured, and a query per tap is not it.

SPEC §4.3 says never more than 6 couplets to a candidate list. keyDepth now
executes that against the built reference.db instead of leaving it as a
sentence, and reports a typed cycle instead of walking an authored loop
until the stack ends.

Task: E14/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
