# E11/T07 — Saved zones and instant re-evaluation

| | |
|---|---|
| **Epic** | E11 — Zones and point-in-polygon |
| **Branch** | `epic/11-zones` (shared) |
| **Commit** | `feat(zones): star several zones and re-evaluate the current species when one is chosen` |
| **Depends on** | T04 (the picker and `activeZoneProvider`), E05/T08 (`SavedZoneDao`), E05/T09 (`SettingsRepository`), E10 (the result display the re-evaluation is visible in) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.4 ("Saved zones": several named zones with quick-switch; switching re-evaluates the current species instantly), §4.4 ("Jurisdiction picker": changeable in two taps), §6 S9 ("saved zones with a star"), §7.2 (`saved_zone`, `species_recent`), §7.3 (what a zone change changes about resolution), §13 (rule evaluation < 10 ms) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `state-management-riverpod` | Rules 1, 3, 4, 5 and 6, and the ownership table: the active zone is a projection of the database, not a mirrored field; the committed write re-emits and nothing republishes by hand |
| `persistence-drift` | Rules 4, 7 and 8: one transaction per mutation with every query awaited, the repository as the single write path, and scoped `.watch()` streams |
| `lonja-lists-and-tables` | Rules 1, 9, 10 and 12: the whole row is one target, status is glyph + word + colour, a destructive row action needs `confirmDismiss` **and** an undo, and glove raises rather than re-lays out |
| `error-handling-typed-results` | Rule 11 (never lose hand-entered data — a saved zone is hand-entered) and rule 4 (the failure switch is exhaustive) |
| `catchlaw-rule-engine` | `references/resolution-algorithm.md`'s request table: `zonePath` and `waterType` are what a zone change actually changes, and both are inputs rather than things `resolve()` looks up |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.4, "Saved zones" | "Several named zones with quick-switch. Switching re-evaluates the current species instantly" |
| `SPEC.md` | §4.4, "Jurisdiction picker" | "Set once, changeable in two taps" — the acceptance condition this task completes |
| `SPEC.md` | §6 S9 | "saved zones with a star" as an element of the screen |
| `SPEC.md` | §7.2, `saved_zone` | `jurisdiction_code`, `zone_code`, nullable `label`, `sort_order`, and `UNIQUE (jurisdiction_code, zone_code)` |
| `SPEC.md` | §7.2, `species_recent` | The primary key `(species_id, jurisdiction_code, zone_code)` — why the scope must carry both codes |
| `SPEC.md` | §7.3 | The resolution inputs a zone change moves: `zone_id` matching NULL / equal / ancestor, and the specificity sort |
| `SPEC.md` | §13, "Rule evaluation" | < 10 ms over ≤ 20 candidate rows — the budget "instantly" cashes out to |
| `SPEC.md` | §13, "Crash safety" | Every write transactional; no in-memory-only state that matters |
| `.claude/skills/state-management-riverpod/references/ownership-and-lifecycle.md` | "The ownership table", "Derive-don't-store", "autoDispose" | Which shape owns the active zone, and why the evaluation scope is a projection rather than a cached field |
| `.claude/skills/state-management-riverpod/references/reads-and-side-effects.md` | "The stale-closure hole", "Action-path methods return `void`" | Pass the zone **code** into `onTap`, never the saved-zone row |
| `.claude/skills/state-management-riverpod/SKILL.md` | rules 4, 5, 6 | Derive don't store, single write path, unidirectional flow |
| `.claude/skills/persistence-drift/SKILL.md` | rules 4, 7, 8 | One transaction, awaited; the repository is the write path; scoped watches |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rules 1, 9, 10, 12 | Row target, `LonjaPill` status, `confirmDismiss` + undo, glove density |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Empty" | The saved-zone strip's empty contract: name the absence, one action |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "The request" | `zonePath` root-first with the active zone last, and `waterType` as a parameter |
| `FLUTTER_GUIDE.md` | §1.4 | "Repositories own app-wide session state" — the active zone is the canonical example |
| `FLUTTER_GUIDE.md` | §5.2 | "Writes need no state at all": the insert marks the table dirty, drift re-runs the watching query, the `StreamProvider` emits, the widget rebuilds |
| `FLUTTER_GUIDE.md` | §5.3 | The `==` rebuild trap and its mitigations — mitigation 2, `.select` at the consumer, is what stops a zone change rebuilding the whole result screen |
| `FLUTTER_GUIDE.md` | §5.4 | Riverpod pauses providers whose consumers are not visible, and drift re-runs exactly one fresh query on resume |
| `epics/CONVENTIONS.md` | §9, invariant 5 | Switching zone must not gate on expiry: a stale ruleset in the new zone still evaluates |

## What this delivers

- `app/lib/data/repositories/settings_repository.dart` gains `Stream<List<SavedZone>> watchSavedZones()`,
  `Future<Result<void, DataFailure>> saveZone(SavedZoneDraft)`,
  `Future<Result<void, DataFailure>> removeSavedZone(int id)`,
  `Future<Result<void, DataFailure>> restoreSavedZone(SavedZone)` and
  `Future<Result<void, DataFailure>> reorderSavedZones(List<int> idsInOrder)`, over E05/T08's
  `SavedZoneDao`; mirrored in `settings_repository_drift.dart` and in the fake.
- `app/lib/domain/models/evaluation_scope.dart` — `EvaluationScope`, an immutable value with
  `jurisdictionCode`, `zoneCode`, `zonePath` and `waterType`, with value equality.
- `app/lib/domain/use_cases/watch_evaluation_scope.dart` — `WatchEvaluationScope`, joining
  `SettingsRepository.watchProfile()` with `ReferenceRepository` lookups for the `parent_zone_id` chain
  and the zone's `water_type`. The join lives in a use-case because the two repositories may never call
  each other (`FLUTTER_GUIDE.md` §2.5 rule 3).
- `app/lib/ui/zones/view_models/zone_providers.dart` gains `savedZonesProvider` (a `StreamProvider`) and
  `evaluationScopeProvider` (a `StreamProvider` over `WatchEvaluationScope`).
- `app/lib/ui/zones/widgets/saved_zone_strip.dart` — the starred rows at the top of S9, each one tap to
  the active zone, each `Dismissible` with `confirmDismiss` and a `LonjaUndoBar`.
- `app/lib/ui/zones/widgets/star_this_zone_action.dart` — stars or unstars the confirmed selection.
- Change to `app/lib/ui/result/view_models/` — the result display provider watches
  `evaluationScopeProvider` instead of reading the profile directly, so a zone change re-enters
  resolution through the one path.
- `app/lib/l10n/app_*.arb` × 6 — `zoneSavedHeadline`, `zoneSavedEmptyHeadline`, `zoneSavedEmptyBody`,
  `zoneStarThis`, `zoneUnstarThis`, `zoneRemoveSavedHeadline`, `zoneRemoveSavedBody`,
  `zoneSavedRemovedUndo`.
- `app/test/ui/zones/saved_zone_strip_test.dart`,
  `app/test/domain/use_cases/watch_evaluation_scope_test.dart`,
  `app/test/ui/result/result_reevaluates_on_zone_change_test.dart`.

## Why it is built this way

**"Instantly" is a data-flow property, not an animation.** §4.4's acceptance condition is that switching
zone re-evaluates the current species. The mechanism is the one `FLUTTER_GUIDE.md` §5.2 already
prescribes and nothing else: the write commits, drift marks `user_profile` dirty, the watching query
re-runs, `evaluationScopeProvider` emits a new `EvaluationScope`, the result display provider — which
watches it — recomputes, and the widget rebuilds. There is no `state =`, no `invalidate`, no manual
refresh and no navigation trick. `state-management-riverpod` rule 5 names the alternative — an
optimistic pre-commit republish — as showing a fact the disk never held, which here would be a verdict
for a zone the fisher is not in.

**The number behind "instantly" is §13's 10 ms.** Rule evaluation is budgeted at < 10 ms over ≤ 20
candidate rows, and a zone change re-runs exactly that plus one indexed candidate query
(`idx_rule_lookup`, `idx_rule_zone`). What is asserted here is the shape rather than the milliseconds,
for the reason E05/T07 already recorded and T03 re-argued: **one** candidate query per zone change, not
two and not one per finding. A naive wiring that watches the profile *and* the water type separately
fires twice, evaluates twice and — worse — renders the intermediate state where the zone has changed and
the water type has not. Test 9 is that assertion.

**The scope is one value, so a zone change is one event.** `EvaluationScope` carries the jurisdiction
code, the zone code, the `zonePath` and the water type together, and it has value equality. Riverpod 3
filters provider updates with `==` (`FLUTTER_GUIDE.md` §5.3), so re-emitting an identical scope produces
no rebuild at all — which matters because E09's ruler emits several times a second above this and E10's
live region re-announces on every semantic update.

**The join is a use-case, because it crosses two repositories.** The active zone lives in `user.db`; the
`parent_zone_id` chain and the zone's `water_type` live in `reference.db`. `FLUTTER_GUIDE.md` §2.5 rule
3 forbids `ReferenceRepository` and `MeasurementRepository`/`SettingsRepository` from referencing each
other and sends the join to `domain/use_cases/`, and `catchlaw-reference-database` rule 11 forbids doing
it in SQL. `WatchEvaluationScope` is that use-case, and it is testable with two fakes and no database.

**Two taps, literally.** §4.4's condition is "changeable in two taps". Tap one is the zone chip on Check
(E12); tap two is a starred row in this strip, which sets the active zone directly without drilling. T04
made the picker open already drilled so a change is *reachable*; this task makes it two taps for a
fisher who works three grounds. The strip sits above the country level for exactly that reason.

**Removing a saved zone is confirmed, soft and undoable — and it does not change where the fisher is.**
`lonja-lists-and-tables` rule 10 requires `confirmDismiss` plus an undo, with the reason stated there: a
swipe across a wet screen is indistinguishable from a scroll and there is no second copy of this data
anywhere. On top of that, removing the *active* zone's shortcut must leave `user_profile.active_zone_code`
untouched — the fisher is still in Rías Baixas; he has only stopped keeping a shortcut to it. Conflating
the two would silently drop him into "no zone set" in the middle of a trip, and §7.2 makes that state
representable precisely so it can be entered deliberately.

**The undo re-inserts rather than clearing a flag, because §7.2 gives `saved_zone` no `is_deleted`.**
`error-handling-typed-results` rule 11 asks for a reversible delete behind a single shared filter, and
that shape is right for a `catch` — a record of something that happened. A saved zone is a shortcut,
fully reconstructible from two codes and a label, so `removeSavedZone` deletes the row and
`restoreSavedZone` writes the captured value back. Adding an `is_deleted` column to §7.2 for a shortcut
would be a forward-only migration in an epic that does not own the schema, and it would leave tombstones
in an export §12 has to round-trip. The undo window is the `LonjaUndoBar`'s and the captured row lives in
the notifier's state for its duration.

**`saved_zone` is keyed `UNIQUE (jurisdiction_code, zone_code)`, so starring twice is an update.** §7.2
put the constraint there; the repository uses an upsert so a double tap on the star cannot raise a
constraint violation the UI would have to explain. The `label` stays nullable and falls back to the
zone's `content_string` name, because a fisher who never renames anything should still see
"Banco de Cambados" and not a blank row.

**The scope carries both codes because `species_recent` is keyed by both.** §7.2's primary key is
`(species_id, jurisdiction_code, zone_code)` and §4.1 says recents are per-zone, ordered by frequency
then recency. E12 builds the Recents strip; this task guarantees the two codes it needs travel together
in one value, so E12 cannot key a query on a zone code that has already moved on.

**Nothing here gates on expiry.** Invariant 5 and `catchlaw-rule-engine` rule 1: switching into a zone
whose ruleset has lapsed produces a verdict plus the ochre bar E10 already renders, never an empty state
and never a block. Test 14 switches into an expired-pack zone and asserts a finding still arrives with
its numbers intact — the same correctness test §14 runs with the device clock.

**Rejected: an in-memory "current zone" held by a view model.** It is the shape
`state-management-riverpod` rule 1 calls two facts that will disagree — the profile row and the field —
and §13's crash-safety row bans in-memory-only state that matters. The active zone survives a force-quit
because it is a row.

**Rejected: `ref.invalidate(resultProvider)` after the write.** It works, and it means the result screen
is refreshed by something outside itself, so every future writer of the profile has to remember to do
it. Watching the scope makes the dependency structural: a new writer gets the re-evaluation for free and
cannot forget.

**Rejected: capturing the `SavedZone` row in the row's `onTap` closure.**
`reads-and-side-effects.md`'s stale-closure hole: after a reorder or a rename the closure acts on the
previous entity and no lint catches it. The callback carries the zone **code**, and the notifier resolves
now.

**Rejected: an "auto-switch when I move" preference.** It is one settings toggle away from the
auto-switching §4.4 forbids, and there is no background location to drive it (§11). A saved zone is a
shortcut, not a trigger.

## Tests first

Write every row before touching `saved_zone_strip.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SavedZoneStrip renders one row per saved zone in sort_order` | 3 saved zones, shuffled ids | 3 rows in `sort_order` | §6 S9's "saved zones with a star"; the order is the fisher's, not the database's |
| 2 | `SavedZoneStrip sets the active zone in one tap` | tap a starred row | one `setActiveZone` call with that pair | Tap two of §4.4's two taps |
| 3 | `SavedZoneStrip falls back to the zone name when label is null` | `label: null` | the `content_string` name | §7.2 makes `label` nullable; a blank row is a shortcut nobody can identify |
| 4 | `StarThisZoneAction saves the confirmed selection` | confirm then star | one `saveZone` with both codes | The entry point; without it the strip is empty forever |
| 5 | `StarThisZoneAction starring twice writes one row` | star the same zone twice | one row, no constraint failure | §7.2's `UNIQUE (jurisdiction_code, zone_code)`; a double tap is a double tap, not an error dialog |
| 6 | `SavedZoneStrip requires a confirmation before removing a saved zone` | swipe end-to-start, dismiss the confirm | the row is still present, no repository call | `lonja-lists-and-tables` rule 10: a swipe across a wet screen is a scroll |
| 7 | `SavedZoneStrip offers an undo after removing a saved zone` | swipe, confirm | `LonjaUndoBar` shown, and undo calls `restoreSavedZone` | The other half of rule 10 |
| 8 | `SavedZoneStrip removing the active zone leaves the active zone unchanged` | remove the starred row for the active zone | zero `setActiveZone` calls | A shortcut is not a location; dropping the fisher into "no zone set" mid-trip is silent data loss of a different kind |
| 9 | `EvaluationScope emits once per zone change` | change the active zone | exactly one new `EvaluationScope`, one candidate query | Two watches fire twice and render an intermediate state where the zone moved and the water type did not |
| 10 | `EvaluationScope does not emit when the profile re-emits unchanged` | identical profile row twice | no second emission | Riverpod filters on `==`; without value equality the ruler's rebuilds cascade into re-evaluation |
| 11 | `EvaluationScope carries the jurisdiction code and the zone code together` | any zone | both present on one value | `species_recent`'s primary key is both, and E12 must not key a query on a code that has moved |
| 12 | `EvaluationScope carries the zonePath root first with the active zone last` | Rías Baixas / Banco de Cambados | `['ES', 'es-ga', 'rias-baixas', 'banco-de-cambados']` | The engine's request contract; a reversed path silently loses every ancestor rule |
| 13 | `the result display re-emits with the new zone when the active zone changes` | species on screen, zone switched | a new display model naming the new zone's rule | §4.4's acceptance condition, end to end |
| 14 | `the result display still produces a finding when the new zone's ruleset has expired` | switch into an expired-pack zone | a finding with its numbers, plus the stale bar | Invariant 5 and `catchlaw-rule-engine` rule 1; §14 runs this with the device clock |
| 15 | `switching zone writes nothing but the profile` | switch | no `catch`, `trip` or `species_recent` write | A zone change is not an event in the log; §7.2's history is the fisher's, not the app's |
| 16 | `SavedZoneStrip renders an authored empty state with no saved zones` | none saved | headline plus exactly one action | `lonja-lists-and-tables` rule 6 |
| 17 | `SavedZoneStrip rows measure at least 64 dp, and 76 dp in glove mode` | both densities | heights match | Rule 12; a shortcut a gloved thumb misses is not a shortcut |
| 18 | `RTL - SavedZoneStrip dismisses end to start` | locale `ar` | `DismissDirection.endToStart`, mirrored | `row-and-table-anatomy.md`: `.rightToLeft` becomes the scroll direction in Arabic |
| 19 | `reorderSavedZones persists sort_order in one transaction` | reorder 3 | one transaction, 3 rows updated | `persistence-drift` rule 4; a half-applied reorder is an order nobody chose |

```dart
// app/test/domain/use_cases/watch_evaluation_scope_test.dart
void main() {
  test('EvaluationScope emits once per zone change', () async {
    final settings = FakeSettingsRepository(profile: kProfileRiasBaixas);
    final reference = CountingReferenceRepository(kReferenceGalicia);
    final scopes = <EvaluationScope>[];
    final sub = WatchEvaluationScope(settings: settings, reference: reference)()
        .listen(scopes.add);
    addTearDown(sub.cancel);

    await settings.setActiveZone('ES-GA', 'banco-de-cambados');
    await pumpEventQueue();

    expect(scopes, hasLength(2), reason: 'the initial scope and exactly one more');
    expect(scopes.last.zonePath,
        <String>['ES', 'es-ga', 'rias-baixas', 'banco-de-cambados']);
  });

  test('EvaluationScope does not emit when the profile re-emits unchanged', () async {
    final settings = FakeSettingsRepository(profile: kProfileRiasBaixas);
    final scopes = <EvaluationScope>[];
    final sub = WatchEvaluationScope(settings: settings, reference: FakeReferenceRepository())()
        .listen(scopes.add);
    addTearDown(sub.cancel);

    settings.reemitProfileUnchanged();
    await pumpEventQueue();

    expect(scopes, hasLength(1),
        reason: 'Riverpod filters on ==; without value equality the ruler cascades into '
            're-evaluation several times a second');
  });
}
```

```dart
// app/test/ui/zones/saved_zone_strip_test.dart
void main() {
  testWidgets('SavedZoneStrip removing the active zone leaves the active zone unchanged',
      (tester) async {
    final settings = FakeSettingsRepository(
      profile: kProfileRiasBaixas,
      savedZones: [kSavedRiasBaixas, kSavedCambados],
    );

    await tester.pumpZonePicker(settings: settings);
    await tester.drag(find.byKey(const ValueKey('saved-rias-baixas')), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-remove')));
    await tester.pumpAndSettle();

    expect(settings.setActiveZoneCalls, isEmpty,
        reason: 'a shortcut is not a location — removing the star must not drop him into '
            '"no zone set" in the middle of a trip');
    expect(settings.removeSavedZoneCalls, hasLength(1));
  });
}
```

**Run:** `cd app && flutter test test/ui/zones/ test/domain/use_cases/ test/ui/result/` → 19 new
failures, every earlier test still green. If any new one passes now, the test is wrong.

## Implementation outline

1. Extend the `SettingsRepository` interface, the drift implementation and the fake together, in that
   order. `saveZone` is one `transaction` with an upsert on `(jurisdiction_code, zone_code)`;
   `reorderSavedZones` is one `transaction` with every update awaited.
2. `evaluation_scope.dart`: a `final class` with `copyWith`, `==` and `hashCode`. No derived fields; the
   `zonePath` is built once by the use-case and stored, because it is an input to the engine rather than
   a projection of the state.
3. `watch_evaluation_scope.dart`: `Stream<EvaluationScope> call()` — one
   `SettingsRepository.watchProfile()` stream, `.distinct()` on the two codes, `asyncMap` to the
   reference lookups, and one emission per distinct pair. Never `await for` inside a notifier
   (`FLUTTER_GUIDE.md` §5.2, `state-management-riverpod` anti-patterns).
4. `zone_providers.dart`: `savedZonesProvider` as a plain `StreamProvider` (app-scope, so no
   `autoDispose`), `evaluationScopeProvider` likewise — the result screen, Check and the catch log all
   read it, and an `autoDispose` here would tear it down between routes.
5. `saved_zone_strip.dart`: a `ListView.builder` under a `LonjaSectionLabel`, each row a `Dismissible`
   with `direction: DismissDirection.endToStart`, a typed `confirmDismiss`, a soft remove and a
   `LonjaUndoBar`. `onTap` carries the zone **code**.
6. `star_this_zone_action.dart`: a `LonjaButton` whose label toggles between `zoneStarThis` and
   `zoneUnstarThis` from `savedZonesProvider`, with a `void` intent method.
7. Change E10's result display provider to `ref.watch(evaluationScopeProvider)`, narrowed with
   `.select` where it only needs one field (`FLUTTER_GUIDE.md` §5.3 mitigation 2).
8. Add the eight ARB keys to all six files and run E06's completeness check.
9. Re-run the whole app suite, including E10's.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first.
- [ ] A zone change produces exactly one `EvaluationScope` emission and exactly one candidate query.
- [ ] `EvaluationScope` has value equality, and an identical scope produces no rebuild.
- [ ] No `state =`, no `ref.invalidate` and no manual refresh anywhere on the zone-change path — the
      committed write is what re-emits.
- [ ] `WatchEvaluationScope` is the only place `SettingsRepository` and `ReferenceRepository` are read
      together; neither repository imports the other.
- [ ] Every `Dismissible` over a saved zone has both `confirmDismiss` and a working undo.
- [ ] Removing a saved zone performs zero writes to `user_profile`.
- [ ] `saveZone` is an upsert and starring twice raises no constraint failure.
- [ ] `reorderSavedZones` is one transaction with every query awaited.
- [ ] The eight ARB keys exist in all six locales (D-3).
- [ ] Switching into an expired-pack zone still produces a finding with its numbers (invariant 5).
- [ ] `check_lonja_lists.sh app/lib` and `ban-legacy-providers.sh app/lib` are clean.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh         app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh          app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh           app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
tools/gates/no_directional_geometry.sh                                     app/lib
$FLUTTER_SKILLS/state-management-riverpod/scripts/ban-legacy-providers.sh  app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh        app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh   app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(zones): star several zones and re-evaluate the current species when one is chosen

SPEC 4.4 asks for several named zones with quick-switch and for switching to
re-evaluate the current species instantly. "Instantly" is a data-flow
property here, not an animation: the write commits, drift marks user_profile
dirty, the watching query re-runs, evaluationScopeProvider emits a new
EvaluationScope, and the result display recomputes because it watches it.
No state =, no invalidate, no manual refresh — an optimistic republish would
show a verdict for a zone the fisher is not in.

The scope is one value carrying jurisdiction code, zone code, zonePath and
water type together, with value equality, so a zone change is one event
rather than two. Two separate watches would fire twice and render the
intermediate frame where the zone moved and the water type had not. The join
across user.db and reference.db lives in a use-case, because the two
repositories may never reference each other.

Removing a saved zone is confirmed, soft and undoable, and it leaves
user_profile.active_zone_code alone: a shortcut is not a location, and
dropping the fisher into "no zone set" mid-trip because he tidied a list is
not a tidy-up. saved_zone is UNIQUE on (jurisdiction_code, zone_code), so
starring twice upserts rather than raising a constraint the UI would have to
explain.

Task: E11/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
