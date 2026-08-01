# E14/T01 — Traversing the key

| | |
|---|---|
| **Epic** | E14 — The identification key |
| **Branch** | `epic/14-identify` (shared) |
| **Commit** | `feat(identify): traverse key_node one couplet at a time from a taxon_group root` |
| **Depends on** | — (first task of the epic; needs E05's read-only `reference.db` and E06's `content_string` resolver, both merged) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.3 "Morphological key", §6 S7, §7.1 `key_node` / `key_option`, §9.2 Tier 2 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | The `key_*` tables live in `reference.db`. Rule 3 (`readOnly: true`, no migration surface) and rule 2 (nothing awaited before `runApp`) constrain every line of the DAO and the executor this task reads through |
| `catchlaw-conventions-index` | The one-way layer map (rule 6): the DAO is `data/`, the mapping happens once in `data/model/`, and no widget touches a DAO. Also the routing tie-break when a change looks like it belongs to two skills |
| `lonja-icons-and-plates` | `key_option.figure_asset` is engraved line art. Rule 4 (four sizes only), rule 2 (stroked, never filled) and rule 10 (no illustration in a terminal state) bind what an option card may draw |
| `lonja-buttons` | An option is a committing action. The variant ladder, the 56dp/66dp glove floor and the "verb phrase naming what happens" label rule decide what a couplet option is built from |
| `lonja-navigation-chrome` | S7 is a pushed route: the back affordance, its mirroring and its translated tooltip are this skill's, and `check_lonja_nav.sh` scans every file under `app/lib` for hardcoded chrome strings |
| `state-management-riverpod` | The traversal is user-driven state held in an `AsyncNotifier`; provider scoping, auto-dispose and the `==` rebuild behaviour are owned here |
| `persistence-drift` | DAO shape, `customSelect` and query construction for `key_node` / `key_option` |
| `navigation-and-routing` | S7 is a route; T06 wires the three entry points into it, and this task must not invent a second routing mechanism |
| `testing-strategy` | Which level each row of the test table belongs at — repository tests against a fixture database, view-model tests against the fake, widget tests against neither |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.3 row "Morphological key" | The key is deterministic and per family group; the six-couplet ceiling it must never exceed (asserted in T05) |
| `SPEC.md` | §6 S7 | The screen's element list: one couplet at a time, two large illustrated options, breadcrumb, back, start over, live count |
| `SPEC.md` | §7.1 `key_node`, `key_option` | The exact columns. `question_key` is NULL on a leaf; `option_index` is unique per node; `next_node_id` is nullable |
| `SPEC.md` | §9.2 Tier 2 | "key questions and options" are named explicitly as `content_string` rows, so they resolve through E06's resolver and never through ARB |
| `FLUTTER_GUIDE.md` | §2.5 + its eight review rules | Where each file goes; rules 1, 2, 6 and 7 (no widget imports `data/`, no ViewModel imports `data/services/`, drift rows never escape `data/`, databases open lazily) |
| `FLUTTER_GUIDE.md` | §5.2 | The vertical slice: repository takes no `Ref`, providers are the entire read path, the widget switches exhaustively over `AsyncValue` |
| `FLUTTER_GUIDE.md` | §8.1 | Private `StatelessWidget` classes in the same file, never `Widget _buildOption()` — mechanism 2 is decisive with six locales |
| `FLUTTER_GUIDE.md` | §6.1 | Test naming, with the receipts |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rules 2, 3, 11 | Read-only open, nothing awaited before `runApp`, no `ATTACH` and no cross-database join |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "Ownership matrix" | `reference.db` is content and disposable; nothing this task writes may land in it |
| `.claude/skills/catchlaw-conventions-index/SKILL.md` | rule 6, routing table | The layer map, and which skill owns the couplet card versus the route |
| `.claude/skills/lonja-icons-and-plates/SKILL.md` | rules 2, 4, 10 | Stroked line art on the 24 grid; the 16/22/30/44 size scale; no illustration in a terminal state |
| `.claude/skills/lonja-buttons/references/button-anatomy.md` | "The printed box", "Label wording" | 56dp regular / 66dp glove, radius 0, no elevation; and the approved label corpus, which already contains `Back one step` and `Skip this couplet` |
| `.claude/skills/lonja-navigation-chrome/references/nav-anatomy-and-states.md` | "Back affordance" | 44dp / 56dp glove, `Transform.flip` under RTL, `l10n.backTooltip`, `maybePop()` |
| `epics/DECISIONS.md` | D-1, D-2, D-3, D-6, D-7 | Paths; theme location; the six locales; extraction and read-only open; the engine holds no user-visible string |

## What this delivers

- `app/lib/domain/models/key_node.dart` — `TaxonGroup` (the eight §7.1 values), `KeyNode`,
  `KeyOption`, `KeyCouplet`. Immutable, const constructors, no drift and no Flutter import.
- `app/lib/domain/models/key_entry_point.dart` — `KeyEntryPoint(TaxonGroup group, int rootNodeId)`.
- `app/lib/data/services/key_dao.dart` — the drift accessor over `key_node` and `key_option` on the
  existing read-only `ReferenceDatabase`.
- `app/lib/data/model/key_mapper.dart` — the only place a `key_node` / `key_option` row becomes a
  domain value, including the closed mapping of `taxon_group` text to `TaxonGroup`.
- `app/lib/data/repositories/key_repository.dart` — the abstract interface:
  `entryPoints()`, `rootFor(TaxonGroup)`, `couplet(int nodeId)`.
- `app/lib/data/repositories/key_repository_drift.dart` — `DriftKeyRepository`.
- `app/lib/ui/identify/view_models/identify_state.dart` — the sealed state:
  `IdentifyEntryPoints`, `IdentifyCouplet`. (`IdentifyCandidates` arrives in T02,
  `IdentifyDeadEnd` in T03.)
- `app/lib/ui/identify/view_models/identify_view_model.dart` — `@riverpod class IdentifyViewModel`,
  auto-disposing, with `start(TaxonGroup)` and `choose(KeyOption)`.
- `app/lib/ui/identify/widgets/identify_screen.dart` — S7's scaffold and the exhaustive switch.
- `app/lib/ui/identify/widgets/key_entry_points.dart`, `couplet_view.dart`, `key_option_card.dart`.
- `app/lib/l10n/app_{ar,en,es,gl,ca,pt_BR}.arb` — `identifyTitle`, `identifyChooseGroup` and the eight
  `taxonGroup*` labels, in all six files (D-3).
- `app/testing/fakes/fake_key_repository.dart`, `app/testing/models/key_fixtures.dart`
  (`kKeyFinfishRoot`, `kKeyCoupletBarbels`, `kKeyOptionDeadEnd`, …).
- Tests: `app/test/data/key_repository_test.dart`,
  `app/test/ui/identify/identify_view_model_test.dart`,
  `app/test/ui/identify/identify_screen_test.dart`.

## Why it is built this way

**The traversal edge is `key_option.next_node_id`, not `key_node.parent_node_id`.** §7.1 gives both.
`parent_node_id` is a back-pointer that makes the authored tree printable; `next_node_id` is the edge
the user walks. They should agree, and content that lets them disagree is a defect — but this task
never asks `parent_node_id` where the user is going. It is used for exactly one thing: finding a root,
which is `parent_node_id IS NULL`. T05 pins the same choice for the candidate count with a fixture
where the two disagree.

**Entry points are derived, not enumerated.** §7.1 constrains `species.taxon_group` to eight values and
leaves `key_node.taxon_group` as bare `TEXT NOT NULL`. Eight hardcoded buttons would ship six dead ones
against the seed content, and a typo in authored content would produce a root nobody can reach. So
`entryPoints()` returns the distinct `taxon_group` of parentless nodes, in the enum's declared order,
and an unmapped value is a **typed failure** rather than a silently dropped row: a key nobody can
reach is worse than a screen that says the read failed. The missing `CHECK` constraint is recorded in
the epic's Risks; do not add one from here.

**One root per group, enforced.** §4.3 says "a deterministic dichotomous key per family group". The
schema permits two parentless nodes in one group; the product does not. `rootFor` fails typed on the
second one rather than picking the lowest id, because picking silently produces a key that is
deterministic per launch and different per content build.

**Every option renders, however many there are.** §6 S7 says two options and §4.3 calls the key
dichotomous, but `key_option.option_index` is an integer with a `UNIQUE (node_id, option_index)`
constraint and nothing caps it at two. Rendering exactly two would hide a third authored option — a
content defect made invisible by the UI. So the card list renders every row in `option_index` order,
and the "dichotomous" assertion belongs to the content build, not to a widget.

**`ORDER BY option_index` is not decoration.** SQLite returns rows in whatever order the query plan
produces. Without the explicit order, "if the fish has barbels" and "if the fish has no barbels" can
swap places between two builds of the same database, and the user learns a muscle memory that lies.

**Rejected: a `Navigator` push per couplet.** It is the obvious way to get `Back one step` for free.
It is rejected because T04 needs the trail as *data* — rendered as a breadcrumb, truncatable to an
arbitrary index, and still present on the terminal states where there is no couplet route to pop.
Popping to an arbitrary index means popping n times and animating n transitions. The state lives in
the ViewModel; the route stack holds exactly one entry for S7.

**Rejected: caching the whole key graph in memory at start-up.** It would make traversal a pure
function over an in-memory tree, which is tempting. It is rejected because it puts a full-table read on
a path §13 budgets at < 1.2 s cold start for a screen most sessions never open, and because
`catchlaw-reference-database` rule 2 exists precisely to keep work off that path. One query per
couplet, on a table with an integer primary key, is cheaper than the read that would avoid it.

**Rejected: ARB keys for the questions.** §9.2 names "key questions and options" as Tier-2 content, and
they are per content pack, per jurisdiction's authoring, and reviewed by a native-speaking fisher
(§9.2 point 3). Putting them in ARB would fork the content pipeline and break the §9.2 fallback chain.
Chrome around them — the screen title, the group labels, the back tooltip — is Tier 1 and goes in all
six ARB files.

## Tests first

Write every row before touching a production file. Run them. **They must fail.** A row that passes
before the implementation exists is testing nothing — fix the test, then write the code.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `KeyRepository.rootFor returns the parentless node for taxon_group finfish` | fixture DB, one finfish root plus two children | the root's id | Entry-point resolution must not depend on insertion order or row id |
| 2 | `KeyRepository.rootFor fails with KeyContentDefect when a taxon_group has two parentless nodes` | two roots for `finfish` | typed failure naming both node ids | §4.3 says one key per group; picking silently ships a different key per build |
| 3 | `KeyRepository.entryPoints omits a taxon_group with no root node` | roots for `finfish` and `cephalopod` only | exactly those two, in enum order | Eight buttons against seed content is six dead buttons |
| 4 | `KeyRepository.entryPoints fails with KeyContentDefect on an unmapped taxon_group` | a row reading `finfsh` | typed failure naming the value | The missing `CHECK` on `key_node.taxon_group` (epic Risk 3); a dropped row is an unreachable key |
| 5 | `KeyRepository.couplet returns options ordered by option_index` | options inserted 2, 0, 1 | `[0, 1, 2]` | SQLite guarantees no order without `ORDER BY`; option order is what the user memorises |
| 6 | `KeyRepository.couplet returns no options when question_key is null` | a leaf node | empty option list, `questionKey` null | §7.1: "a leaf is a node with no question"; leaf detection is a property of the node, not a separate flag |
| 7 | `KeyOption.nextNodeId is nullable on the mapped value` | option row with NULL `next_node_id` | `nextNodeId == null` | T03 renders this as a terminal state; a non-null default here would erase the dead end at the mapper |
| 8 | `IdentifyViewModel.start opens the root couplet for taxon_group finfish` | fake repository | state is `IdentifyCouplet` at the root node | The entry into the key |
| 9 | `IdentifyViewModel.choose advances to key_option.next_node_id` | at the root, choose option 1 | state is `IdentifyCouplet` at that node id | The traversal step itself |
| 10 | `IdentifyScreen renders every option of a three-option node` | node with `option_index` 0, 1, 2 | three option cards | Rendering exactly two would hide an authored third option and mask a content defect |
| 11 | `IdentifyScreen renders a label-only option when figure_asset is null` | one option, null figure | card renders, no figure slot, no overflow | `figure_asset` is nullable and the seed may not carry art (epic Risk 5) |
| 12 | `RTL - IdentifyScreen places the option figure at the start edge` | `ar`, one option with a figure | figure's start edge is the card's start edge | `EdgeInsetsDirectional` compliance; a physical `left` inset breaks in exactly one of six locales |
| 13 | `ar - IdentifyScreen renders the question from content_string` | `ar` locale, fake resolver | the `ar` value, not the key and not English | §9.2 Tier 2 and its fallback chain; a raw key on screen is the failure mode |

```dart
// app/test/data/key_repository_test.dart
import 'package:catchlaw/data/repositories/key_repository.dart';
import 'package:catchlaw/data/repositories/key_repository_drift.dart';
import 'package:catchlaw/domain/models/key_node.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/models/key_fixtures.dart';

void main() {
  late DriftKeyRepository repository;

  setUp(() async {
    repository = DriftKeyRepository(await openKeyFixtureDao());
  });

  group('KeyRepository', () {
    test('.rootFor returns the parentless node for taxon_group finfish', () async {
      final result = await repository.rootFor(TaxonGroup.finfish);
      expect(result.valueOrNull?.node.id, kKeyFinfishRoot.id);
    });

    test('.couplet returns options ordered by option_index', () async {
      final result = await repository.couplet(kKeyCoupletBarbels.id);
      expect(
        result.valueOrNull!.options.map((o) => o.optionIndex),
        orderedEquals(<int>[0, 1, 2]),
      );
    });

    test('.entryPoints fails with KeyContentDefect on an unmapped taxon_group', () async {
      final result = await repository.entryPoints();
      expect(result.failureOrNull, isA<KeyContentDefect>());
    });

    // … one test per row above, one behaviour each
  });
}
```

```dart
// app/test/ui/identify/identify_screen_test.dart
import 'package:catchlaw/ui/identify/widgets/identify_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_key_repository.dart';
import '../../utils/harness.dart';

void main() {
  testWidgets('IdentifyScreen renders every option of a three-option node', (tester) async {
    await tester.pumpWidget(harness(
      repository: FakeKeyRepository.withCouplet(kKeyCoupletBarbels),
      child: const IdentifyScreen(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(KeyOptionCard), findsNWidgets(3));
  });

  testWidgets('RTL - IdentifyScreen places the option figure at the start edge', (tester) async {
    await tester.pumpWidget(harness(
      locale: const Locale('ar'),
      repository: FakeKeyRepository.withCouplet(kKeyCoupletBarbels),
      child: const IdentifyScreen(),
    ));
    await tester.pumpAndSettle();

    final card = tester.getRect(find.byType(KeyOptionCard).first);
    final figure = tester.getRect(find.byType(KeyOptionFigure).first);
    expect(figure.right, closeTo(card.right - 16, 0.5)); // start edge under RTL
  });
}
```

**Run:** `cd app && flutter test test/data/key_repository_test.dart test/ui/identify/` → 13 failures.
If any passes now, that test is wrong.

## Implementation outline

1. `app/lib/domain/models/key_node.dart` — `TaxonGroup` with the eight §7.1 values in schema order,
   `KeyNode`, `KeyOption`, `KeyCouplet`. Const constructors, `==` and `hashCode` (Riverpod 3 filters
   updates with `==`, `FLUTTER_GUIDE.md` §5.3).
2. `app/lib/data/services/key_dao.dart` — a drift accessor with three queries: parentless nodes; one
   node by id; that node's options `ORDER BY option_index`. Read-only; no write method exists on it.
3. `app/lib/data/model/key_mapper.dart` — rows to domain values. The `taxon_group` string maps through
   a closed lookup that returns a `Result`; an unmapped value produces `KeyContentDefect`.
4. `app/lib/data/repositories/key_repository.dart` + `_drift.dart` — the interface returns
   `Future<Result<T>>` (`FLUTTER_GUIDE.md` §2.5 rule 5); the implementation takes the DAO, not a `Ref`.
5. `app/lib/ui/identify/view_models/identify_state.dart` — sealed, two variants for now.
6. `app/lib/ui/identify/view_models/identify_view_model.dart` — `@riverpod` (auto-disposing:
   re-entering S7 must start at the entry points, not resume yesterday's fish),
   `build()` loads `entryPoints()`, `start` and `choose` set state from the repository.
7. `app/lib/ui/identify/widgets/` — `IdentifyScreen` switches exhaustively over the sealed state and
   over `AsyncValue`; `KeyEntryPoints`, `CoupletView` and `KeyOptionCard` are private-or-public widget
   **classes**, never helper methods (`FLUTTER_GUIDE.md` §8.1).
8. Add the ARB keys to all six files. If E08 or E12 already added a key with the same meaning, reuse
   it — a second key with the same value is a translation bill paid twice and a divergence waiting.
9. `dart run build_runner build --delete-conflicting-outputs` and commit the generated files
   (`FLUTTER_GUIDE.md` §7.4).
10. Re-run the whole `app/` suite, not just the new files.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 13 tests pass, and each failed first.
- [ ] No widget file imports anything from `app/lib/data/`; no drift row type appears outside
      `app/lib/data/` (`FLUTTER_GUIDE.md` §2.5 rules 1 and 6).
- [ ] `key_node` and `key_option` are read through the **read-only** `ReferenceDatabase` only; no
      statement in this task writes to `reference.db` and no `ATTACH` exists.
- [ ] `identifyTitle`, `identifyChooseGroup` and the eight `taxonGroup*` keys exist in all six ARB
      files, `ar` included (D-3).
- [ ] No question or option label is a Dart string literal — every one resolves through
      `content_string` (§9.2).
- [ ] The option list is ordered by `option_index` in SQL, not in Dart, and a test proves it.
- [ ] `packages/rule_engine/` is untouched by this commit.
- [ ] No `Icons.` or `CupertinoIcons.` reaches an option card (`lonja-icons-and-plates` rule 1).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh           app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh         app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh          app/lib
tools/gates/no_directional_geometry.sh                                     app/lib
```

Every gate is invoked with an explicit target directory: they exit 2 on a missing directory, and at
this repository root `lib/` does not exist (D-1).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(identify): traverse key_node one couplet at a time from a taxon_group root

The key walks key_option.next_node_id, not key_node.parent_node_id — the
back-pointer makes the authored tree printable, the option edge is what the
user actually follows, and content that lets them disagree is a defect T05
pins rather than something the traversal should paper over.

Entry points are derived from the parentless nodes rather than enumerated
from the eight taxon groups, because key_node.taxon_group carries no CHECK
constraint: eight hardcoded buttons would ship six dead ones against the
seed content, and a typo would produce a root nobody can reach. An unmapped
group is a typed failure, not a dropped row.

Every option renders in option_index order, however many there are. Drawing
exactly two would hide an authored third option and make a content defect
invisible.

Task: E14/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
