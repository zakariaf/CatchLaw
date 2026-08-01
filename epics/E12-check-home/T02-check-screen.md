# E12/T02 — S1, the Check screen

| | |
|---|---|
| **Epic** | E12 — Check home and the navigation shell |
| **Branch** | `epic/12-check-home` (shared) |
| **Commit** | `feat(check): add S1 with the zone chip, recents strip and four species entry points` |
| **Depends on** | T01 (the shell holds S1) |
| **Size** | L |
| **Spec** | `SPEC.md` §3 steps 1–2, §6 S1, §4.1 (species picker, local-name search), §4.9 (one-handed reach) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-navigation-chrome` | Owns the masthead, the zone chip and the content-currency chip — their metrics, their copy rules, and the fact that they wrap rather than scroll. |
| `lonja-lists-and-tables` | The Recents strip is a row of species tiles; slot order, the whole-tile tap target, and the ban on a spinner as a loading body all come from here. |
| `lonja-design-tokens` | Every gap on this screen is a `LonjaSpace` step and every target size comes from `LonjaTokens.density`. |
| `catchlaw-conventions-index` | Routing: this screen crosses `data/`, `domain/` and `ui/`, and the one-way layer map decides where the recents query may live. |
| `state-management-riverpod` | The recents strip is a `StreamProvider` over drift; the pause/resume behaviour when the user leaves Check is the reason it is a stream and not a future. |
| `navigation-and-routing` | Four of the six taps on this screen are navigations; the route constants and the push-versus-branch decision belong there. |
| `flutter-performance` | `const` tiles, `.select` scoping on the zone, and sized decode of the six silhouettes — this screen is on the cold-start path measured by T06. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S1, "Elements" | The exact element list: zone chip → S9, currency chip → S23, Recents (6), search → S5, Browse by shape → S6, Identify this fish → S7, tally bar, bottom nav |
| `SPEC.md` | §3 steps 1–2 | Launches straight to Check with the last-used zone selected; four ways to the species, all one tap |
| `SPEC.md` | §4.1, "Species picker" row | Done looks like: four paths land on the same species detail; recents are per-zone, ordered by frequency then recency |
| `SPEC.md` | §7.2, `species_recent` | `(species_id, jurisdiction_code, zone_code, use_count, last_used_at)`, `WITHOUT ROWID`, primary key is the lookup index |
| `SPEC.md` | §7.1, `species` and `species_name` | `silhouette_asset`, `is_primary`, the locale column — what the tile renders |
| `SPEC.md` | §4.9 | Primary actions in the bottom third; 56 dp glove targets with 8 dp separation |
| `.claude/skills/lonja-navigation-chrome/references/chips-and-currency.md` | "Chip taxonomy", "Chip metrics", "Zone chip content", "RTL behaviour" | Zone chip 1 dp `harbour` border, 38/56 dp min height, the `name · water, salt` qualifier, the mirrored chevron, the ISO date island |
| `.claude/skills/lonja-navigation-chrome/references/nav-anatomy-and-states.md` | "Masthead anatomy" | The chip row is a `Wrap` at 8 dp spacing, never a horizontal scroller |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rules 1, 3, 9, 11 | The whole tile is one target; `ListTile` is banned; the slot order is fixed |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Loading skeleton" | No spinner, no "Loading…"; a ruled skeleton of the real tile |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "Choosing a container" | Fewer than 8 items fixed at build → a `Column`/`Row` of const children, never a builder |
| `FLUTTER_GUIDE.md` | Part 1.1, 1.3 | View knows one ViewModel; the ViewModel never navigates and never holds a `BuildContext` |
| `FLUTTER_GUIDE.md` | Part 5.2 | Return the stream, never `await for`; writes need no state |
| `FLUTTER_GUIDE.md` | Part 5.4 | Leaving Check genuinely stops the SQL; coming back runs exactly one fresh query |
| `epics/DECISIONS.md` | D-1, D-3, D-6, D-7 | Paths; six locales; two database files; the engine holds no sentence |

## What this delivers

- `app/lib/ui/check/check_screen.dart` — the View. Logic limited to the allow-list in
  `FLUTTER_GUIDE.md` Part 1.2.
- `app/lib/ui/check/view_models/check_view_model.dart` — `recentSpeciesProvider` (stream, capped at 6),
  `activeZoneProvider`, `contentCurrencyProvider`.
- `app/lib/ui/check/widgets/recents_strip.dart` — six tiles, each a single tap target.
- `app/lib/ui/check/widgets/species_entry_points.dart` — the search field, Browse by shape, Identify
  this fish, laid out in the bottom third.
- `app/lib/ui/core/ui/lonja_masthead.dart` — the masthead with the chip row.
- `app/lib/ui/core/ui/lonja_zone_chip.dart`, `app/lib/ui/core/ui/lonja_currency_chip.dart` — lifted out
  of `app/lib/ui/result/` if E10 left them private to the verdict takeover. Lifted, never forked.
- `app/lib/data/repositories/recents_repository.dart` + `recents_repository_drift.dart`.
- `app/testing/fakes/fake_recents_repository.dart`, `app/testing/models/k_recent_species.dart`.
- `app/lib/l10n/app_*.arb` × 6 — `checkSearchHint`, `checkBrowseByShape`, `checkIdentifyThisFish`,
  `checkRecentsLabel`.
- `app/test/ui/check/check_screen_test.dart`, `app/test/ui/check/widgets/recents_strip_test.dart`,
  `app/test/data/repositories/recents_repository_test.dart`.

Filenames matter: `check_lonja_nav.sh` selects chrome files by name (`*nav*`, `*app_bar*`, `*masthead*`,
`*chrome*`, `*chip*`, `*shell*`). `lonja_masthead.dart`, `lonja_zone_chip.dart` and
`lonja_currency_chip.dart` are inside the gate's scan set because of what they are called.

## Why it is built this way

**The screen is the four paths.** `SPEC.md` §4.1's acceptance condition is that four paths land on the
same species detail. Everything else on S1 exists to make one of those four reachable without a scroll:
Recents for the species picked yesterday, search for the one with a name, Browse by shape for the one
without, Identify for the one nobody recognises. The layout is therefore driven by reach, not by
information density — §4.9 puts primary actions in the bottom third because the thumb holding the phone
is the only free hand, and a test asserts it at 360 × 640.

**Recents are scoped and ordered by the database, not by Dart.** §4.1 says per-zone, frequency then
recency. `species_recent`'s primary key is `(species_id, jurisdiction_code, zone_code)` and the table
is `WITHOUT ROWID` (§7.2), so the zone-scoped read is an index range scan, and the ordering is
`ORDER BY use_count DESC, last_used_at DESC LIMIT 6`. Sorting six rows in Dart would work and would
also hide the fact that the query is the thing on the cold-start budget in T06.

**Six tiles are a `Row` in a horizontal scroller, not a `ListView.builder`.** The count is fixed at six
by §6 S1. `row-and-table-anatomy.md` puts fewer than eight fixed items in a `Column`/`Row` of const
children: a builder buys laziness that six items do not need and costs the `const` subtree
short-circuit that `FLUTTER_GUIDE.md` Part 8.2 measures.

**A `StreamProvider`, so leaving Check stops the query.** `FLUTTER_GUIDE.md` Part 5.4: Riverpod 3
pauses providers whose consumers are not visible, and drift's `QueryStream` invalidates rather than
buffers, so exactly one fresh query runs on return. A `FutureProvider` would need a manual invalidate
on every pop, and that invalidate is the line somebody forgets.

**Zone chip start, currency chip end.** §6 S1 says top-left and top-right. Those are physical
directions in an English mock-up; under `Directionality` they are start and end, and `chips-and-currency.md`
requires directional insets throughout. In `ar` the zone chip is top-right. The chips sit in a `Wrap`
at 8 dp: a chip the user cannot see is a trust signal that does not exist, so they never collapse
behind an overflow button and never scroll.

**Rejected: auto-focusing the search field.** Covered in full by T04; it is called out here because the
temptation is at its strongest while building the field.

**Rejected: a `CircularProgressIndicator` while the recents query is in flight.** `the-four-states.md`
bans it outright — a spinner is network language in an app with no network, and the honest loading body
is a ruled skeleton of the real tile. In practice the query resolves inside one frame; the skeleton
exists for the cold open on a five-year-old Android.

**Rejected: forking the currency chip.** E10 needed it for the verdict takeover
(`nav-anatomy-and-states.md`, "Verdict takeover" — currency chip present, always). If it landed as a
private widget inside the result feature, this task moves it to `app/lib/ui/core/ui/` and updates the
one import. Two chips that drift apart would state two different checked dates for one rule pack.

## Tests first

Write every row before touching `check_screen.dart`. Run them. **They must fail.** A routing test that
passes before the screen exists is finding some other widget — fix the finder before writing code.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `CheckScreen is the location the app opens at` | fresh router | location is `routes.checkPath` | §3 step 1: no splash, no login, no onboarding, no what's-new |
| 2 | `CheckScreen states the last-used zone on the zone chip` | profile with `active_zone_code` | chip shows the zone name and its water qualifier | §3 step 1; the qualifier is why salt and fresh do not share rules |
| 3 | `CheckScreen routes the zone chip to the zone picker in one tap` | tap chip | location is S9 | §6 S1; the chip is the only way to the picker from here |
| 4 | `CheckScreen routes the currency chip to the changelog in one tap` | tap chip | location is S23 | §6 S1; an undated legal statement is unverifiable |
| 5 | `CheckScreen shows six recent species` | fake returns 8 | 6 tiles | §6 S1 fixes the count; the cap belongs in the query, not the layout |
| 6 | `CheckScreen orders recents by use count then last used` | 3 rows, mixed | order asserted | §4.1: frequency then recency, in that order |
| 7 | `CheckScreen scopes recents to the active zone` | rows in two zones | only the active zone's tiles | §4.1: recents are per-zone |
| 8 | `CheckScreen replaces the recents strip when the zone changes` | switch zone | new tile set, no stale row | §4.4: switching re-evaluates instantly |
| 9 | `CheckScreen routes a recents tile to the species result in one tap` | tap tile 0 | location is S2 for that species id | Path 1 of the four in §4.1 |
| 10 | `CheckScreen routes the search field to species search in one tap` | tap field | location is S5 | Path 2 |
| 11 | `CheckScreen routes Browse by shape to the silhouette grid in one tap` | tap action | location is S6 | Path 3 |
| 12 | `CheckScreen routes Identify this fish to the identification key in one tap` | tap action | location is `routes.identifyPath` | Path 4; §4.3 records that S7 being unreachable from S1 was a defect in the first draft |
| 13 | `CheckScreen taps a recents tile from its start edge` | tap tile rect's start edge | route fires | Lists rule 1: a wet neoprene finger lands anywhere on the tile, not on a glyph |
| 14 | `CheckScreen places the search field, Browse and Identify in the bottom third at 360x640` | surface 360×640 | each centre below `height * 2 / 3` | §4.9 one-handed reach; the tally bar must not push them up |
| 15 | `glove - CheckScreen sizes every primary target at 56 dp with 8 dp separation` | glove density | measured | §4.9; `LonjaDensity.glove` is `tapMin` 56, `tapGap` 8 |
| 16 | `CheckScreen shows a ruled skeleton and no spinner while recents load` | provider pending | 6 skeleton tiles, no `CircularProgressIndicator` | A spinner is network language in an app with no network |
| 17 | `RTL - CheckScreen places the zone chip at the start edge and the currency chip at the end edge` | `ar` | zone chip right, currency chip left | §6 S1's "top-left" is a direction, not a coordinate |
| 18 | `ar - CheckScreen renders the search hint from app_ar.arb` | locale `ar` | Arabic hint | D-3; six locales ship together |
| 19 | `RecentsRepository.watchForZone caps the result at six rows` | 20 rows seeded | 6 emitted | The cap is in SQL because T06 measures this query |
| 20 | `RecentsRepository.watchForZone emits again when a species is used` | insert then bump | second emission | §4.5's "live" applies to recents as well as to the tally |

```dart
// app/test/ui/check/check_screen_test.dart
import 'package:catchlaw/routing/routes.dart' as routes;
import 'package:catchlaw/ui/check/check_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/k_recent_species.dart';
import '../../utils/harness.dart';

void main() {
  testWidgets('CheckScreen routes a recents tile to the species result in one tap', (tester) async {
    final app = await pumpCheck(tester, recents: kRecentsRasAlKhaimah);

    await tester.tap(find.byKey(ValueKey('recent.${kRecentsRasAlKhaimah.first.speciesId}')));
    await tester.pumpAndSettle();

    expect(app.router.location, routes.speciesPath(kRecentsRasAlKhaimah.first.speciesId));
  });

  testWidgets('CheckScreen places the search field, Browse and Identify in the bottom third at '
      '360x640', (tester) async {
    await pumpCheck(tester, surfaceSize: const Size(360, 640), recents: kRecentsRasAlKhaimah);

    const boundary = 640 * 2 / 3;
    for (final key in const ['check.search', 'check.browse', 'check.identify']) {
      expect(tester.getCenter(find.byKey(ValueKey(key))).dy, greaterThan(boundary),
          reason: '$key must sit within one thumb of the bottom edge');
    }
  });

  testWidgets('CheckScreen shows a ruled skeleton and no spinner while recents load',
      (tester) async {
    await pumpCheck(tester, recents: null); // provider left pending
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(RecentsSkeletonTile), findsNWidgets(6));
  });

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/data/repositories/recents_repository_test.dart
test('RecentsRepository.watchForZone caps the result at six rows', () async {
  final db = await openTestUserDatabase();
  await seedRecents(db, count: 20, zoneCode: 'RAK-GULF');
  final repo = DriftRecentsRepository(db.recentsDao);

  final first = await repo.watchForZone(jurisdiction: 'AE-RK', zone: 'RAK-GULF').first;

  expect(first, hasLength(6));
});
```

**Run:** `cd app && flutter test test/ui/check test/data/repositories/recents_repository_test.dart`
→ 20 failures. If any passes now, the test is wrong.

## Implementation outline

1. `recents_repository.dart`: the abstract interface —
   `Stream<List<RecentSpecies>> watchForZone({required String jurisdiction, required String zone})`
   and `Future<void> markUsed(int speciesId, {...})`. No `Ref`, no Riverpod import
   (`FLUTTER_GUIDE.md` Part 5.2).
2. `recents_repository_drift.dart`: the DAO call, ordered and capped in SQL, joined to `species` and
   `species_name` for the display name and silhouette. Two statements — one per database file, because
   `species_recent` is in `user.db` and the names are in `reference.db` (§7, D-6). T06 owns the budget
   for both.
3. `fake_recents_repository.dart` in `app/testing/fakes/`, plus `kRecentsRasAlKhaimah` in
   `app/testing/models/`.
4. `check_view_model.dart`: `@riverpod` stream provider over the repository, `.select`-scoped to the
   active zone so a locale change does not re-query.
5. `lonja_zone_chip.dart` and `lonja_currency_chip.dart`: move from `app/lib/ui/result/` if they are
   there; otherwise author them from `chips-and-currency.md`'s metrics table.
6. `lonja_masthead.dart`: `PreferredSizeWidget`, flat at every scroll offset, 2 dp bottom rule, the two
   chips in a `Wrap(spacing: 8, runSpacing: 8)`.
7. `recents_strip.dart`: a horizontal `SingleChildScrollView` over a `Row` of six const tiles, each a
   single `InkWell` at `density.tapMin`.
8. `species_entry_points.dart`: the search field (a tap target that routes to S5, not an inline search),
   then Browse by shape and Identify this fish, all inside the bottom third.
9. `check_screen.dart`: masthead, recents, the tally bar slot T03 fills, entry points, and the strip
   from T01 supplied by `AppShell`.
10. Add the four ARB keys to all six locales, run `gen-l10n`, re-run the suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 tests pass, and each failed first.
- [ ] All four paths in `SPEC.md` §4.1 are one tap from the first frame, each with its own test.
- [ ] `check_screen.dart` contains no data logic — only the allow-list in `FLUTTER_GUIDE.md` Part 1.2.
- [ ] The recents cap and ordering are in SQL, not in Dart.
- [ ] Picking a species raises `species_recent.use_count`; if no epic wrote that row before this one,
      the single repository method that does is added here (epic risk 2).
- [ ] `LonjaCurrencyChip` exists in exactly one place in `app/lib/` and both S1 and S2 import it.
- [ ] The four ARB keys exist in all six locales (D-3).
- [ ] No `ListTile`, no `Card`, no `elevation:`, no `BorderRadius` above `LonjaRadii.hair`.
- [ ] `app/lib/ui/check/` imports nothing from `app/lib/data/services/`.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh   app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh  app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh    app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
tools/gates/no_directional_geometry.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(check): add S1 with the zone chip, recents strip and four species entry points

SPEC.md §4.1's acceptance condition is that four paths land on the same
species detail. Recents, search, Browse by shape and Identify this fish are
each one tap from the first frame, and each has a test that asserts its
destination route rather than its label.

Recents are scoped and ordered in SQL — per zone, use_count then last_used_at,
limited to six — because species_recent is WITHOUT ROWID with that exact
primary key, and because T06 measures this query against the cold-start
budget. Six fixed tiles are a Row of const children rather than a builder:
laziness buys nothing at six and costs the const subtree short-circuit.

The search field, Browse and Identify sit in the bottom third and are asserted
there at 360x640 — one thumb, in sunlight, wearing wet gloves.

Task: E12/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
