# E08/T02 — The view model and the two result groups

| | |
|---|---|
| **Epic** | E08 — Species: search, browse and the static detail |
| **Branch** | `epic/08-species` (shared) |
| **Commit** | `feat(species): group search results by zone and give each row a one-word hint` |
| **Depends on** | T01 (the query and `SpeciesSearchHit`) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S5 "Elements", §7.3 (finding precedence, zone matching), §9.5 (units, dates), §13 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `state-management-riverpod` | This is the ViewModel. Owns the one-immutable-state rule, `void` intent methods, the stale-closure hole, and rule 10 — no `DateTime.now()`, `now` arrives through `clockProvider` |
| `persistence-drift` | The zone-membership and rule-fact reads are two more indexed DAO queries; keeps drift symbols inside `app/lib/data/` |
| `catchlaw-reference-database` | Rule 11: the active zone lives in `user.db` and the rules live in `reference.db`, so the join is Dart, never SQL |
| `lonja-lists-and-tables` | `references/row-and-table-anatomy.md` slot 5 — what the end slot may contain, and rule 8: a row states, it never instructs |
| `catchlaw-conventions-index` | Invariant 2 (statement, never instruction), invariant 3 (a required `Citation`), invariant 5 (an expired rule still produces its hint) |
| `catchlaw-measurement-ruler` | Owns units and rounding. This task authors `LengthDisplay` against §9.5 and E09 consumes it rather than writing a second one |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S5 "Elements" | The two group headings verbatim in intent, and the three hint shapes: `45 cm` / `protected` / `closed` |
| `SPEC.md` | §7.3 steps 1–3 | Zone matching (`NULL`, equal, or ancestor) and that expiry does **not** filter; finding precedence, which the hint's precedence copies |
| `SPEC.md` | §7.1 `rule`, `closed_season`, `zone` | `is_protected`, `min_size_mm`, `bag_limit`, `specificity`, `parent_zone_id`, and the annual/fixed recurrence shape |
| `SPEC.md` | §9.5 "Units" and "Dates" | Stored as integer millimetres, conversion is display-only; season windows read "1 March – 30 April" |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The species row — slot table" | Slot 5 is mono 12 tabular, `TextAlign.end`, `flex: none`; slot 4 is the rule line |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Precedence" and "Stale" | `stale` is orthogonal and composes with `data` and `empty`; the exclusive three are `error`, `loading`, `empty` |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | Invariants 2, 3 and 5 | The banned lexicon, "make the field required, not asserted", and the stale-versus-absent matrix |
| `Flutter-Skills: state-management-riverpod/references/reads-and-side-effects.md` | whole | watch to show, read to act, listen to react; `void` intent methods; the stale-closure hole |
| `Flutter-Skills: state-management-riverpod/references/ownership-and-lifecycle.md` | "The ownership table", "autoDispose" | Which provider shape this is, and why it is `autoDispose` |
| `FLUTTER_GUIDE.md` | §1.3 | What a ViewModel may and may not do; `UnmodifiableListView` for the exposed lists |
| `FLUTTER_GUIDE.md` | §5.3 | `List.==` is identity, so the state value must carry real value equality |
| `epics/DECISIONS.md` | D-7 | The engine returns types; every word on a row comes from ARB or `content_string` |

## What this delivers

- `app/lib/domain/models/species_row_facts.dart` — the per-species facts a row needs:
  `inActiveZone` (bool), `hint` (a sealed `SpeciesHint`), and a **required, non-nullable**
  `Citation`.
- `app/lib/domain/models/species_hint.dart` — `sealed class SpeciesHint` with
  `ProtectedHint`, `ClosedSeasonHint`, `MinimumSizeHint(int millimetres, MeasurementMethodCode)`
  and `NoHint`. Numbers and enums only — no sentence, in any language (D-7 applied one layer up).
- `app/lib/domain/models/length_display.dart` — `LengthDisplay.format(int millimetres, LengthUnit)`,
  the single conversion point named in `epic.md` risk 3.
- `app/lib/domain/models/species_search_state.dart` — the one immutable state value:
  `query`, `inZone` (`UnmodifiableListView<SpeciesRow>`), `elsewhere`, `jurisdictionSpeciesCount`,
  `isPackExpired`.
- `app/lib/data/repositories/species_rule_facts_repository.dart` (+ `_drift.dart`) —
  `Future<Result<Map<int, SpeciesRowFacts>>> factsFor({required List<int> speciesIds, required
  JurisdictionRef jurisdiction, required ZoneRef zone, required DateTime on})`.
- `app/lib/data/services/dao/species_rule_facts_dao.dart` — one statement over `rule` joined to
  `closed_season` and `citation`, filtered by `idx_rule_lookup`.
- `app/lib/ui/species/view_models/species_search_view_model.dart` — an
  `AsyncNotifierProvider.autoDispose` exposing `SpeciesSearchState`, with a `void search(String)`
  intent and a `void clear()` intent.
- `app/testing/fakes/fake_species_rule_facts_repository.dart`.
- Tests: `app/test/domain/models/length_display_test.dart`,
  `app/test/data/repositories/species_rule_facts_repository_test.dart`,
  `app/test/ui/species/view_models/species_search_view_model_test.dart`.

## Why it is built this way

**Two groups, one zone predicate, and it is not SQL across two files.** A species is *in your zone*
when a `rule` row exists for it whose `zone_id` is `NULL`, equals the active zone, or is an ancestor
of it — §7.3 step 2, exactly. The active zone lives in `user_profile.active_zone_code` in `user.db`;
the rules live in `reference.db`. `catchlaw-reference-database` rule 11 bans `ATTACH` because a
wholesale content swap leaves any statement spanning both files pointing at an unlinked inode. So
the repository takes the resolved zone and its ancestor chain as plain arguments, and the SQL runs
inside `reference.db` alone. The ancestor chain is walked once per zone change, not once per query.

**Expiry does not filter, here either.** §7.3 step 1 is explicit that `valid_to` is not a filter,
and invariant 5 says a stale ruleset is still evaluated and still shown. The facts query therefore
selects on `valid_from <= :on` and never on `valid_to`; `isPackExpired` is a flag on the state, and
T03 renders it as the non-blocking ochre bar. A species whose only rule expired last season still
appears in **in your zone** with its hint intact. Getting this wrong is not cosmetic: it is the
failure §7.3 spends four paragraphs describing, where a Spanish *orden de vedas* expiring at
midnight empties the whole list.

**The hint's precedence copies the finding precedence.** §7.3 ends with
`is_protected → closed season → max_size_mm → min_size_mm → bag limit → vessel limit`. The one-word
hint takes the first three that can be said in one word: `protected`, then `closed`, then the
minimum size. A max-size rule, a bag limit and a vessel limit produce `NoHint` — they need two
numbers or a period to mean anything, and slot 5 is one mono line. Using a *different* precedence
here would mean the row and the result screen disagree about which fact matters most, and the row is
what the fisher reads first.

**The hint is a fact, so it carries a citation.** Invariant 3 says every result carries a required,
non-nullable `Citation`, and `product-invariants.md`'s review checklist says to *make the field
required, not asserted*. `protected` and `45 cm` are read straight off a `rule` row that has a
`NOT NULL citation_id`, so `SpeciesRowFacts.citation` is non-nullable and the row model cannot be
constructed without it. The 64 dp row does not *render* it — there is no room, and slot 5 is a
single mono line — but the value travels with the row into S2, where E10 renders it. Making the
field optional "because the row does not show it" is exactly how an uncited fact reaches a screen.

**Rejected: computing the hint in the widget.** `FLUTTER_GUIDE.md` §1.2's allow-list for a View is
simple `if`s on a ViewModel flag, animation, layout-from-device-info and simple routing. Choosing
between three hint shapes is none of those, and §1.2 gives the reason that decides it for this app:
a View with logic multiplies the golden matrix by the number of its branches, and T08 already runs
eleven lanes per list screen.

**Rejected: a `StreamNotifier` over a live query.** `ownership-and-lifecycle.md` puts a
`StreamNotifier` where the feature state *is* a live projection of the database. Search is not: it
is a one-shot read driven by keystrokes, and `reference.db` is opened read-only and never written,
so there is nothing to re-emit. An `AsyncNotifier` over one immutable value is the right shape, and
it is `.autoDispose` so leaving S5 drops the results rather than holding 40 rows for the session.

**`now` is injected.** The closed-season test needs a date, and `state-management-riverpod` rule 10
bans `DateTime.now()` in state logic — "now" arrives through `clockProvider`. This is not
ceremony here: §14's dynamic checklist requires setting the device clock *past* a `valid_to` and
*backwards two years* and asserting the behaviour, and a hard-wired `DateTime.now()` makes both of
those untestable anywhere but on a device.

**One place converts millimetres.** §9.5 stores every length as integer millimetres and calls
conversion display-only. `LengthDisplay.format` is that conversion and nothing else does it, because
`epic.md` risk 3 records a live disagreement about whether a Galician shell length renders as
`38 mm` or `3,8 cm`. When `catchlaw-measurement-ruler` and E09 settle it, one function changes.

## Tests first

Write every row before touching the view model. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SpeciesRuleFactsRepository.factsFor marks a species with a jurisdiction-wide rule as in the active zone` | `rule.zone_id` is `NULL` | `inActiveZone` true | §7.3 step 2's first arm — the Gulf case, where `has_zone_polygons = 0` and every rule is jurisdiction-wide |
| 2 | `SpeciesRuleFactsRepository.factsFor marks a species with a rule on the active zone as in the active zone` | `zone_id == active` | `inActiveZone` true | The exact-match arm |
| 3 | `SpeciesRuleFactsRepository.factsFor marks a species with a rule on an ancestor zone as in the active zone` | rule on the parent region, active zone is a bank | `inActiveZone` true | §7.3's ancestor arm; a Galician bank inherits its ría's rules |
| 4 | `SpeciesRuleFactsRepository.factsFor marks a species with a rule on a sibling zone as elsewhere` | rule on another ría | `inActiveZone` false | The negative case that makes group two non-empty; without it every result lands in group one |
| 5 | `SpeciesRuleFactsRepository.factsFor includes a species whose only rule has expired` | `valid_to` yesterday | present, hint intact | Invariant 5 and §7.3's headline correctness fix — a filtered `valid_to` empties the list on the day an annual instrument lapses |
| 6 | `SpeciesRuleFactsRepository.factsFor carries the citation of the rule that produced the hint` | any hinted species | `citation.instrumentRef` equals the rule's | Invariant 3: the field is required, so the only way to break it is to pass the wrong one |
| 7 | `SpeciesRuleFactsRepository.factsFor uses idx_rule_lookup` | `EXPLAIN QUERY PLAN` | plan contains `idx_rule_lookup` | This query runs on every keystroke behind the 50 ms budget; a scan here is invisible until the content grows |
| 8 | `SpeciesHint resolves to protected when is_protected is set` | protected + a min size + a closed season | `ProtectedHint` | §7.3's precedence: protection outranks everything, and shipping a size for a protected species is the worst hint this screen can give |
| 9 | `SpeciesHint resolves to closed when a season is in force on the date` | closed 1 Mar – 30 Apr, `on` = 12 Mar | `ClosedSeasonHint` | The second rank, and the case §14 tests by moving the device clock |
| 10 | `SpeciesHint resolves to a minimum size when no season is in force on the date` | same rule, `on` = 12 Jun | `MinimumSizeHint(450, TL)` | The same row must change its own hint with the date — proof the clock is injected and read |
| 11 | `SpeciesHint resolves to a minimum size across an annual season that wraps the year end` | closed 1 Dec – 31 Jan, `on` = 15 Jul | `MinimumSizeHint` | The wrap-around arithmetic every seasonal implementation gets wrong once |
| 12 | `SpeciesHint resolves to closed inside an annual season that wraps the year end` | same rule, `on` = 15 Jan | `ClosedSeasonHint` | The other side of the wrap; one test alone would pass on a broken comparison |
| 13 | `SpeciesHint resolves to none when the rule carries only a bag limit` | `bag_limit` 5, nothing else | `NoHint` | A bag limit needs today's tally to mean anything, and the tally is E13 — a bare `5` in slot 5 would be a number with no unit |
| 14 | `LengthDisplay.format renders 450 mm as 45 cm in cm` | 450, `cm` | `45 cm` | The Hamour worked value from `type-ramp.md`; §9.5's stored-as-millimetres rule made visible |
| 15 | `LengthDisplay.format renders 650 mm as 65 cm in cm` | 650, `cm` | `65 cm` | The Kanaad value; two cases pin that the divisor is not applied twice |
| 16 | `LengthDisplay.format renders 38 mm as 38 mm in mm` | 38, `mm` | `38 mm` | The Galician bivalve, and the unit named in `epic.md` risk 3 |
| 17 | `LengthDisplay.format renders 450 mm with the locale decimal separator in es` | 455, `cm`, `es` | `45,5 cm` | §9.5: "locale decimal separator (`45,5 cm` in es/pt_BR/gl/ca)" — a hardcoded `.` is wrong in four of six locales |
| 18 | `SpeciesSearchViewModel splits results into in-zone and elsewhere groups` | 3 in zone, 2 elsewhere | `inZone.length == 3`, `elsewhere.length == 2` | The headline of §6 S5's Elements line |
| 19 | `SpeciesSearchViewModel preserves the query order inside each group` | ranked ids `[7,3,9]`, 3 and 9 in zone | `inZone` is `[3,9]` | T01 spent an `ORDER BY` on that order; regrouping must not silently re-sort it |
| 20 | `SpeciesSearchViewModel exposes an empty elsewhere group when every result is in the active zone` | all in zone | `elsewhere` empty, not null | T03 renders the second heading conditionally, and a null here is a crash on the happiest path |
| 21 | `SpeciesSearchViewModel exposes the jurisdiction species count for the empty state` | 214 species seeded | `jurisdictionSpeciesCount == 214` | The empty state's jurisdiction note quotes a real count; the-four-states.md's sample copy quotes one, and a hardcoded number would be a lie in every other jurisdiction |
| 22 | `SpeciesSearchViewModel flags an expired pack without emptying the results` | expired jurisdiction, 4 hits | `isPackExpired` true, 4 rows | Invariant 5, at the state level, before any widget can get it wrong |
| 23 | `SpeciesSearchViewModel clears both groups when the query is cleared` | search then `clear()` | both empty, `query` empty | The trailing clear affordance in `search-field-and-keypad.md` must return the screen to the recents state, not to stale rows |
| 24 | `SpeciesSearchViewModel emits a new state value on every transition` | two searches | `identical(first, second)` is false | `FLUTTER_GUIDE.md` §5.3 plus Riverpod rule 3 — a mutated-in-place value is filtered by `==` and the UI silently stales |
| 25 | `SpeciesSearchViewModel exposes an error state when the repository fails` | failing fake | `AsyncError` | `the-four-states.md` ranks `error` above everything; T03 cannot render a branch the state cannot express |
| 26 | `SpeciesSearchState exposes its groups as unmodifiable lists` | mutate the exposed list | throws | `FLUTTER_GUIDE.md` §1.3's explicit rule: a ViewModel must not expose mutable state |

```dart
// app/test/ui/species/view_models/species_search_view_model_test.dart
import 'package:catchlaw/ui/species/view_models/species_search_view_model.dart';
import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/fake_species_rule_facts_repository.dart';
import '../../../../testing/fakes/fake_species_search_repository.dart';
import '../../../../testing/models/k_species.dart';

void main() {
  ProviderContainer containerWith({
    required FakeSpeciesSearchRepository search,
    required FakeSpeciesRuleFactsRepository facts,
    DateTime? now,
  }) {
    return ProviderContainer.test(
      overrides: [
        speciesSearchRepositoryProvider.overrideWithValue(search),
        speciesRuleFactsRepositoryProvider.overrideWithValue(facts),
        clockProvider.overrideWithValue(Clock.fixed(now ?? DateTime.utc(2026, 6, 12))),
      ],
    );
  }

  test('SpeciesSearchViewModel splits results into in-zone and elsewhere groups', () async {
    final container = containerWith(
      search: FakeSpeciesSearchRepository.returning([
        kSpeciesAmeixa, kSpeciesAmeixaFina, kSpeciesShari,
      ]),
      facts: FakeSpeciesRuleFactsRepository.inZone({kSpeciesAmeixa.id, kSpeciesAmeixaFina.id}),
    );

    container.read(speciesSearchViewModelProvider.notifier).search('ame');
    await container.pump();

    final state = container.read(speciesSearchViewModelProvider).requireValue;
    expect(state.inZone.map((r) => r.speciesId), [kSpeciesAmeixa.id, kSpeciesAmeixaFina.id]);
    expect(state.elsewhere.map((r) => r.speciesId), [kSpeciesShari.id]);
  });

  test('SpeciesSearchViewModel flags an expired pack without emptying the results', () async {
    final container = containerWith(
      search: FakeSpeciesSearchRepository.returning([kSpeciesAmeixa]),
      facts: FakeSpeciesRuleFactsRepository.expired(),
    );

    container.read(speciesSearchViewModelProvider.notifier).search('ame');
    await container.pump();

    final state = container.read(speciesSearchViewModelProvider).requireValue;
    expect(state.isPackExpired, isTrue);
    expect(state.inZone, hasLength(1)); // SPEC §7.3 — expiry does not delete
  });

  test('SpeciesHint resolves to closed when a season is in force on the date', () async {
    final container = containerWith(
      search: FakeSpeciesSearchRepository.returning([kSpeciesShari]),
      facts: FakeSpeciesRuleFactsRepository.closedSeason(from: (3, 1), to: (4, 30)),
      now: DateTime.utc(2026, 3, 12),
    );

    container.read(speciesSearchViewModelProvider.notifier).search('sha');
    await container.pump();

    final row = container.read(speciesSearchViewModelProvider).requireValue.inZone.single;
    expect(row.hint, isA<ClosedSeasonHint>());
  });

  // … one test per row in the table above, one behaviour each
}
```

**Run:** `cd app && flutter test test/ui/species/ test/domain/ test/data/repositories/species_rule_facts_repository_test.dart`
→ 26 failures. If test 5 or test 22 passes early, the facts query is filtering on `valid_to` and
invariant 5 is already broken.

## Implementation outline

1. `SpeciesHint` first — a sealed class with four variants and no strings. `dart3-idioms` patterns
   make the precedence a single `switch` over the rule row.
2. `LengthDisplay.format` next, with `NumberFormat` from `intl` for the decimal separator. It reads
   the locale, so it takes one as an argument rather than a `BuildContext` — a ViewModel may not
   hold a context (`FLUTTER_GUIDE.md` §1.3).
3. `SpeciesRuleFactsDao`: one statement selecting `rule` left-joined to `closed_season`, filtered
   `jurisdiction_id = ? AND species_id IN (…) AND water_type IN (?, 'both') AND valid_from <= ?`,
   ordered `specificity DESC`. No `valid_to` in the `WHERE`.
4. Resolve the zone-ancestor chain once in the repository from `zone.parent_zone_id`, and pass the
   id set into the statement. The chain is bounded by §7.1's four zone kinds, so recursion depth is
   not a concern; assert it terminates on a self-referencing row rather than looping.
5. Map to `SpeciesRowFacts` with the citation required by the constructor. Compute
   `isExpired = valid_to != null && valid_to < on` per §7.3 step 1 and fold it into
   `SpeciesSearchState.isPackExpired`.
6. Write the season predicate for both `recurrence` values, and make the annual one wrap: when
   `start` is after `end` in month/day order, the window spans the year boundary. Tests 11 and 12
   are the pair that pins it.
7. The view model: `AsyncNotifier` over `SpeciesSearchState`, `void search(String)` that starts the
   work inside the method and never returns a `Future` into a `VoidCallback`
   (`reads-and-side-effects.md`, "the silence bug"). Guard the `state =` write with `ref.mounted`.
8. Expose the groups as `UnmodifiableListView` and give the state value real value equality, so
   `AsyncValue.==` can filter a re-emitted identical state (`FLUTTER_GUIDE.md` §5.3).
9. Re-run the suite. All 26 green, T01's 24 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 26 tests pass, and each failed first.
- [ ] The facts query has no `valid_to` in its `WHERE` clause, and test 5 proves it.
- [ ] `SpeciesRowFacts.citation` is non-nullable — a `Citation?` anywhere in this task is a defect
      (invariant 3).
- [ ] No `SpeciesHint` variant carries a `String`; every word is resolved in the widget layer from
      ARB (D-7 applied one layer up).
- [ ] `grep -rn 'DateTime.now()' app/lib/ui/species/ app/lib/data/repositories/` is empty.
- [ ] The hint precedence is the first three ranks of §7.3's finding precedence, in that order.
- [ ] `LengthDisplay.format` is the only millimetre conversion in `app/lib/`.
- [ ] No `ATTACH`; the active zone and its ancestors enter as arguments.
- [ ] The view model holds no `BuildContext`, shows no `SnackBar` and performs no navigation
      (`FLUTTER_GUIDE.md` §1.3).
- [ ] `check_app_invariants.sh` check 6 (expiry that returns early, blocks, disables or errors) is
      clean.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
# from the Flutter-Skills plugin, per CONVENTIONS.md §4:
#   state-management-riverpod  scripts/ban-legacy-providers.sh     app/lib
#   persistence-drift          scripts/check-drift-confinement.sh  app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(species): group search results by zone and give each row a one-word hint

The facts query selects on valid_from and never on valid_to. Filtering the
expired rows out is the defect SPEC §7.3 was rewritten to prevent: on the day a
Spanish orden de vedas lapses, every species sourced from it would fall through
to "no rule recorded" and the list would empty itself. Expiry is a flag on the
state instead, and T03 draws it as a non-blocking ochre bar.

The hint's precedence is the first three ranks of §7.3's finding precedence —
protected, then closed, then the minimum size — so the row and the result screen
never disagree about which fact matters most. A bag limit produces no hint,
because a bare 5 in a one-line mono slot is a number with no unit.

SpeciesRowFacts.citation is non-nullable. The 64dp row has nowhere to draw it,
but a fact whose citation is optional is a fact that will one day be shown
without one.

Task: E08/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
