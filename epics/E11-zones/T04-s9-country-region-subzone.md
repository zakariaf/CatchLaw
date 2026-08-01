# E11/T04 — S9: country, region, sub-zone

| | |
|---|---|
| **Epic** | E11 — Zones and point-in-polygon |
| **Branch** | `epic/11-zones` (shared) |
| **Commit** | `feat(zones): build the S9 picker as three ruled levels over jurisdiction and zone` |
| **Depends on** | E05/T09 (`ReferenceRepository`, `SettingsRepository`, `DataFailure`), E06 (six ARB files, the `content_string` resolver), E07 (`LonjaTokens`, `LonjaType`, the density switch) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.4 (jurisdiction picker: country → region → sub-zone, set once, changeable in two taps; fresh vs salt), §6 S9 (every element and the error state), §7.1 (`jurisdiction`, `zone`), §7.2 (`user_profile.active_jurisdiction`, `active_zone_code`), §9.2 (which tier a name comes from) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | Owns every row on this screen: rule 1 (the whole row is one tap target at 64 dp, 76 dp glove), rule 2 (hairline, never a card gap), rule 3 (`ListTile` and `DataTable` are banned), rule 6 (an authored empty state), rule 12 (glove raises, never re-lays out) |
| `lonja-navigation-chrome` | Rules 4, 5, 6 and 9: every chrome string through `AppLocalizations`, directional geometry only, a mirrored 44/56 dp back affordance, and the zone chip's contract — a zone is chosen, never inferred, and this screen is what it opens |
| `state-management-riverpod` | Rules 1, 2, 5 and 7 and the ownership table: the drill path is a reversible in-session value on one `Notifier`, the profile and the level lists are projections, and the write goes through the repository |
| `error-handling-typed-results` | Rule 4: the `DataFailure` switch at the view-model boundary is exhaustive, and the failure `code` maps to an ARB key at the presentation edge |
| `catchlaw-reference-database` | Rule 3 and the ownership matrix: the level lists are read-only content, the selection is the only thing written, and it goes to `user.db` |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.4, "Jurisdiction picker" and "Saved zones" | Country → region → sub-zone; set once, changeable in two taps |
| `SPEC.md` | §4.4, "Fresh vs salt" | Where a jurisdiction splits them, the zone carries the water type |
| `SPEC.md` | §6 S9 | The element list in full, the error state, and the note that a jurisdiction with no polygons shows no sub-zone level |
| `SPEC.md` | §7.1, `jurisdiction` | `country_iso2`, `name_key`, `has_freshwater`, `has_saltwater`, `has_zone_polygons`, `default_locale` |
| `SPEC.md` | §7.1, `zone` | `parent_zone_id`, `code`, `name_key`, `water_type`, `zone_kind`, and `idx_zone_juris` |
| `SPEC.md` | §7.2, `user_profile` | `active_jurisdiction` and `active_zone_code`, both nullable — the unset state is representable by design |
| `SPEC.md` | §9.2, "Tier 2 — bundled content" | "jurisdiction and zone names" are `content_string`; the country label is not in that list and is therefore tier 1 (ARB) |
| `SPEC.md` | §9.2, "Fallback chain" | requested locale → jurisdiction `default_locale` → `en` → scientific name; E06 already implements it and this screen must not re-implement it |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rules 1, 2, 3, 6, 11, 12 | Row anatomy, the ban list, and the mandatory authored empty state |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The settings row", "The divider ladder", "Density: paper, glove, sunlight", "Choosing a container" | 58/68 dp settings row, the four rule weights, `LonjaSegmented` as a value slot, and `ListView.builder` over `Column`-in-a-scroll-view |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Precedence", "Empty" | Error > loading > empty > data, and an empty state that names the absence and offers exactly one action |
| `.claude/skills/lonja-navigation-chrome/references/nav-anatomy-and-states.md` | "Back affordance", "Masthead anatomy" (pushed routes) | The 44/56 dp mirrored back button and the bar row a pushed route swaps the wordmark for |
| `.claude/skills/lonja-navigation-chrome/references/chips-and-currency.md` | "Zone chip content", "Copy rules" | `Ras Al Khaimah · Gulf, salt` — the zone name plus the water qualifier — and the forbidden copy list |
| `.claude/skills/state-management-riverpod/references/ownership-and-lifecycle.md` | "The ownership table", "family", "Minimalism check" | Which shape owns what, why the drill path is a value and not four providers |
| `.claude/skills/state-management-riverpod/references/reads-and-side-effects.md` | "The split", "The stale-closure hole", "Action-path methods return `void`" | `watch` to show, `read` to act; pass the zone **code**, never the row, into an `onTap` |
| `FLUTTER_GUIDE.md` | §1.4 | Repositories own app-wide lifecycle state — the active zone is exactly that |
| `FLUTTER_GUIDE.md` | §5.2 | The vertical slice: `StreamProvider` over a repository stream, and no `await for` in a notifier |
| `FLUTTER_GUIDE.md` | §5.3 | The `==` rebuild trap: `List.==` is identity, so the level list rebuilds on every re-query unless the consumer narrows with `.select` |
| `epics/DECISIONS.md` | D-3 | Six ARB files exactly: `ar`, `en`, `es`, `gl`, `ca`, `pt_BR` |
| `epics/DECISIONS.md` | D-8 | `EdgeInsets.only(left:` is banned by `tools/gates/no_directional_geometry.sh`, not by a lint |

## What this delivers

- `app/lib/ui/zones/zone_picker_screen.dart` — S9. A pushed route with the bar row of
  `nav-anatomy-and-states.md`, three stacked levels, and `ZonePickerScreen.routeName` for E12 to
  register.
- `app/lib/ui/zones/view_models/zone_picker_state.dart` — the immutable state: `selectedCountry`,
  `selectedJurisdictionCode`, `selectedZoneCode`, `levels`, and the `DataFailure?` arm.
- `app/lib/ui/zones/view_models/zone_picker_view_model.dart` — `ZonePickerNotifier extends
  AsyncNotifier<ZonePickerState>` with `void selectCountry(String iso2)`,
  `void selectJurisdiction(String code)`, `void selectZone(String code)` and
  `void confirmSelection()`. Every one returns `void` and owns its own `unawaited`.
- `app/lib/ui/zones/view_models/zone_providers.dart` — `activeZoneProvider` (a `StreamProvider` over
  `SettingsRepository.watchProfile()` narrowed to the two codes), `shippedCountriesProvider`,
  `jurisdictionsInCountryProvider` and `subZonesOfProvider`, the last two `FutureProvider.family` keyed
  by a `String`.
- `app/lib/ui/zones/widgets/zone_level.dart` — `ZoneLevel`, a `LonjaSectionLabel` plus a
  `ListView.builder` of `ZoneRow`; and `ZoneRow`, one `InkWell` over the full rect at
  `l.density.rowMinHeight` with a hairline bottom border, the name, a mono end slot and an inert
  mirrored chevron.
- `app/lib/ui/zones/widgets/water_type_toggle.dart` — `WaterTypeToggle`, a `LonjaSegmented` rendered
  only when the jurisdiction carries both `has_freshwater` and `has_saltwater`.
- `app/lib/ui/zones/widgets/zone_picker_empty.dart` — the authored empty state for a country with no
  bundled jurisdiction.
- `app/lib/l10n/app_*.arb` × 6 — `zonePickerTitle`, `zoneLevelCountry`, `zoneLevelRegion`,
  `zoneLevelSubZone`, `zoneWaterSalt`, `zoneWaterFresh`, `zoneWaterBoth`, `zonePickerEmptyHeadline`,
  `zonePickerEmptyBody`, `zonePickerLoadFailed`, and `countryName` as an ICU `select` over the shipped
  `country_iso2` values.
- `app/test/ui/zones/zone_picker_screen_test.dart`,
  `app/test/ui/zones/zone_level_test.dart`,
  `app/test/ui/zones/water_type_toggle_test.dart`,
  `app/test/ui/zones/view_models/zone_picker_view_model_test.dart`.

## Why it is built this way

**Three levels, read from two tables.** §4.4 says country → region → sub-zone and §7.1 gives no
`country` table, so the levels map like this: **country** is `jurisdiction.country_iso2`, grouped;
**region** is the `jurisdiction` row itself (`ES-GA` Galicia, `AE-RK` Ras Al Khaimah, `BR-SP`), labelled
from `jurisdiction.name_key`; **sub-zone** is the `zone` rows whose `parent_zone_id` resolves to that
jurisdiction's `region`-kind zone, labelled from `zone.name_key`. This is the same shape
`catchlaw-rule-engine/references/resolution-algorithm.md` shows as `zonePath: ['AE', 'AE-RK',
'AE-RK-KHOR-KHWAIR']`, root first, and it is why the picker can hand a `zonePath` to `resolve()` without
inventing one.

**The `zonePath` is built from `parent_zone_id`, not from geometry.** T02 can report which zones
geometrically contain a point, and that is a fine thing to show a fisher. It is not ancestry. A bank
whose ring overruns its region's coastline by fifty metres would acquire a different parent under a
geometric reading, and §7.3's step 2 — "keep rows whose `zone_id` is NULL, equals the zone, or is an
**ancestor** of the zone" — is a statement about the schema. One source of ancestry, and it is the
column.

**Country labels are ARB; every other name is `content_string`.** §9.2's tier-2 list is explicit and
names "jurisdiction and zone names". It does not name country names, and a country name is not quoted
from any instrument — it is chrome that happens to be data-driven. So `countryName` is an ICU `select`
in the six ARB files over the `country_iso2` values that actually ship, and the E06 CI check that fails
on a key missing from any locale covers it. Jurisdiction and zone names go through E06's resolver with
§9.2's fallback chain, which this screen calls and does not re-implement: a second fallback chain would
disagree with the first the day a Galician string is missing.

**The picker opens at the current selection, and that is what makes two taps possible.** §4.4's
acceptance condition is "set once, changeable in two taps". Tap one is the zone chip (E12); tap two must
land on a sibling. So `build()` reads `activeZoneProvider` and seeds the drill path from it, scrolling
the sub-zone level to the selected row — not resetting to a blank country list, which would make a
change four taps. The starred saved-zone strip that makes the two taps literal for a fisher with several
grounds is T07's; this task lands the state it needs.

**The drill path is one value on one notifier, not four providers.** `ownership-and-lifecycle.md`'s
minimalism check asks whether a field would do before a provider is added. The path is three nullable
strings that change together and are reversible in-session — exactly the "reversible in-session edits
stay in the value" row. Splitting them into three `Notifier`s would let a country change land before its
jurisdiction clears and render a Galician sub-zone under Brazil for one frame.

**Every row is one `InkWell` over the full rect.** `lonja-lists-and-tables` rule 1, with the reason
stated there: a wet neoprene finger at 05:40 against a 15 dp chevron hit box silently does nothing. The
chevron is inert decoration and mirrors under `Directionality`; `ListTile` is banned outright by rule 3
because it hardcodes Material's paddings and its column maths does not mirror.

**The selection is written once, on confirm, through `SettingsRepository`.** `FLUTTER_GUIDE.md` §1.4's
May-2026 addition puts app-wide session state on a repository rather than in a global view model, and
§7.2 puts the durable copy in `user_profile`. The write is one transaction, the `Future` resolves after
the commit, and the profile stream re-emits — no `state =`, no optimistic republish
(`persistence-drift` rule 4, `state-management-riverpod` rule 5). T07 is what makes the re-emission
visibly re-evaluate the current species.

**A country with no bundled jurisdiction gets an authored empty state.** `lonja-lists-and-tables` rule 6
makes this mandatory and `the-four-states.md` fixes its parts: engraved plate, a headline stating the
absence as a fact, a body saying what *is* held, and exactly one action. A `SizedBox.shrink()` here is a
blank frame that reads as a crash to a fisher with no signal, and it fails `check_lonja_lists.sh`.

**The water-type toggle appears on a rule, not on a hunch.** It is rendered when and only when the
jurisdiction row carries `has_freshwater = 1` **and** `has_saltwater = 1`. §4.4's condition is "where a
jurisdiction splits them"; the two columns are that condition, already in §7.1, already authored by the
content builder. Showing it everywhere would ask a Gulf fisher a question the Gulf instruments do not
pose. What the toggle *means* to resolution — that a freshwater zone never shows marine rules — is T08's.

**Rejected: a map.** §10 bans `google_maps_flutter` and `flutter_map` outright, and
`nav-anatomy-and-states.md` records `Map` as a permanently rejected destination: no location service, no
tiles offline. Tiles would also be tens of megabytes against §8's 55–70 MB bundle and licence-encumbered
in every jurisdiction that matters. The question is "which zone", and a list answers it.

**Rejected: a searchable flat list of every zone.** It is fewer taps for somebody who already knows the
zone's name and worse for everybody else, and it deletes the hierarchy that §7.3 step 2's ancestry rule
depends on the fisher understanding — a rule that applies "in Rías Baixas" is not visible when Rías
Baixas is one row among four hundred. The hierarchy is the explanation, not the navigation.

**Rejected: auto-selecting the only jurisdiction in a country.** It saves one tap and makes the second
tap unpredictable — sometimes a region, sometimes a sub-zone. `lonja-navigation-chrome` rule 1's
argument about thumb memory applies to a drill path as much as to a nav bar.

## Tests first

Write every row before touching `zone_picker_screen.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ZonePickerScreen renders a country level, a region level and a sub-zone level` | fixture with ES and BR | three `ZoneLevel` widgets | §4.4's three levels, present before anything else is argued about |
| 2 | `ZonePickerScreen lists one country row per distinct country_iso2` | 3 jurisdictions across 2 countries | 2 country rows | §7.1 has no country table; the grouping is the level |
| 3 | `ZonePickerScreen lists the jurisdictions of the selected country only` | ES selected | `ES-GA` present, `BR-SP` absent | The drill path filters; a flat list would defeat the ancestry §7.3 step 2 relies on |
| 4 | `ZonePickerScreen lists the sub-zones whose parent is the selected region` | `ES-GA` selected | Rías Baixas present, a Brazilian basin absent | Ancestry is `parent_zone_id`, and it is read here |
| 5 | `ZonePickerScreen opens with the active selection already drilled` | profile holds `ES-GA` / `rias-baixas` | all three levels show that path selected | "Changeable in two taps" is false if the picker opens blank |
| 6 | `ZonePickerScreen writes the selection through SettingsRepository on confirm` | tap a sub-zone, confirm | one `setActiveZone('ES-GA', 'rias-baixas')` call | The single write path; §7.2 holds the durable copy |
| 7 | `ZonePickerScreen writes nothing while the fisher is still drilling` | tap a country, then a region | zero repository writes | A half-drilled path written to `user_profile` is an active zone nobody chose |
| 8 | `ZonePickerNotifier.selectCountry clears the jurisdiction and zone selection` | ES → BR | both downstream fields null | One value changing together; three notifiers would render a Galician sub-zone under Brazil |
| 9 | `ZoneRow fires its callback when tapped at its start edge` | tap 4 dp from the start | callback fires | `lonja-lists-and-tables` rule 1: the whole row is the target, not the chevron |
| 10 | `ZoneRow measures at least 64 dp, and 76 dp in glove mode` | both densities | heights match | Rule 12: glove raises, never re-lays out |
| 11 | `ZoneRow separates siblings with a hairline and no card` | two rows | a token `BorderSide`, no `Card`, no `elevation`, no `BorderRadius` | Rule 2 — a register, not a stack of floating screens |
| 12 | `ZonePickerScreen contains no ListTile and no DataTable` | rendered | neither found | Rule 3; both override every Lonja type role and neither mirrors |
| 13 | `ZonePickerScreen renders an authored empty state for a country with no bundled jurisdiction` | country with zero rows | headline and exactly one action found | Rule 6, and `the-four-states.md`'s empty contract |
| 14 | `ZonePickerScreen renders the failure line when the reference read fails` | fixture in its failing env | the ARB failure line, and no exception | `the-four-states.md`'s precedence: error replaces the body, and the `code` maps to a key here |
| 15 | `WaterTypeToggle renders when the jurisdiction has both fresh and salt water` | `has_freshwater = 1`, `has_saltwater = 1` | present | §4.4's condition, expressed as the two §7.1 columns |
| 16 | `WaterTypeToggle is absent when the jurisdiction has salt water only` | `has_freshwater = 0` | absent | Asking a Gulf fisher a question his instruments do not pose |
| 17 | `ZonePickerScreen resolves a zone name through content_string` | `zone.name_key` present in `gl` | the Galician string, not the key | §9.2 tier 2; a raw key on screen is the failure the build is supposed to prevent |
| 18 | `ZonePickerScreen falls back through the jurisdiction default locale` | key missing in `ca`, present in `gl` | the Galician string | §9.2's chain, called and not re-implemented |
| 19 | `ar - ZonePickerScreen renders every level label from AppLocalizations` | locale `ar` | no Latin literal in a level label | `lonja-navigation-chrome` rule 4; a hardcoded label ships English chrome into the Arabic build |
| 20 | `RTL - ZoneRow places the chevron at the end edge` | locale `ar` | chevron rect end > name rect end | D-8's geometry ban is a grep; this is the behaviour it protects |
| 21 | `ZonePickerScreen survives a 200% text scale with no overflow` | `textScaler: 2.0`, 5-inch viewport | no overflow exception | §4.9's stated target |
| 22 | `ZonePickerScreen builds its level lists lazily` | 400 sub-zones | `ListView.builder`, not a `Column` in a scroll view | `row-and-table-anatomy.md`'s container table; an eager build of 400 rows is a dropped frame per drill |

```dart
// app/test/ui/zones/zone_picker_screen_test.dart
import 'package:catchlaw/ui/zones/zone_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_settings_repository.dart';
import '../../../testing/models/zone_fixtures.dart';
import '../harness.dart';

void main() {
  testWidgets('ZonePickerScreen opens with the active selection already drilled', (tester) async {
    final settings = FakeSettingsRepository(profile: kProfileRiasBaixas);

    await tester.pumpZonePicker(settings: settings, reference: kReferenceGaliciaAndSaoPaulo);

    expect(find.text('España'), findsOneWidget);
    expect(tester.widget<ZoneRow>(find.byKey(const ValueKey('zone-row-ES-GA'))).selected, isTrue);
    expect(tester.widget<ZoneRow>(find.byKey(const ValueKey('zone-row-rias-baixas'))).selected, isTrue);
  });

  testWidgets('ZonePickerScreen writes nothing while the fisher is still drilling', (tester) async {
    final settings = FakeSettingsRepository();

    await tester.pumpZonePicker(settings: settings, reference: kReferenceGaliciaAndSaoPaulo);
    await tester.tap(find.byKey(const ValueKey('zone-row-ES')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('zone-row-ES-GA')));
    await tester.pumpAndSettle();

    expect(settings.setActiveZoneCalls, isEmpty,
        reason: 'a half-drilled path written to user_profile is an active zone nobody chose');
  });

  testWidgets('ZonePickerScreen contains no ListTile and no DataTable', (tester) async {
    await tester.pumpZonePicker(reference: kReferenceGaliciaAndSaoPaulo);

    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(DataTable), findsNothing);
  });

  // … one test per remaining row above, one behaviour each
}
```

```dart
// app/test/ui/zones/view_models/zone_picker_view_model_test.dart
void main() {
  test('ZonePickerNotifier.selectCountry clears the jurisdiction and zone selection', () async {
    final container = ProviderContainer.test(overrides: kZoneFixtureOverrides);
    final notifier = container.read(zonePickerProvider.notifier);

    notifier.selectCountry('ES');
    notifier.selectJurisdiction('ES-GA');
    notifier.selectZone('rias-baixas');
    notifier.selectCountry('BR');
    await container.pump();

    final state = container.read(zonePickerProvider).requireValue;
    expect(state.selectedJurisdictionCode, isNull);
    expect(state.selectedZoneCode, isNull);
  });
}
```

**Run:** `cd app && flutter test test/ui/zones/` → 22 failures. If any passes now, the test is wrong.

## Implementation outline

1. `zone_providers.dart`: `activeZoneProvider` as a `StreamProvider` over
   `SettingsRepository.watchProfile()` mapped with `.select` to a `(String?, String?)` record, so
   `FLUTTER_GUIDE.md` §5.3's `List.==` trap never reaches the level lists.
   `shippedCountriesProvider`, `jurisdictionsInCountryProvider(String iso2)` and
   `subZonesOfProvider(String jurisdictionCode)` as `FutureProvider`s over `ReferenceRepository`; the
   last two `.family`-keyed by a `String`, which is a stable equatable value.
2. `zone_picker_state.dart`: a `final class` with `copyWith`, value equality and no derived fields —
   the levels are computed from the selection, never stored twice.
3. `zone_picker_view_model.dart`: `build()` seeds the path from `activeZoneProvider`. Each intent
   method returns `void` and, where it touches the repository, owns its own
   `unawaited(_run().catchError(_record))` — the arrow-callback Future-drop hole is closed by
   construction (`reads-and-side-effects.md`).
4. `zone_level.dart`: `LonjaSectionLabel` + `ListView.builder`. `ZoneRow` is a `const`-constructible
   private-free `StatelessWidget`, one `InkWell`, `BoxConstraints(minHeight: l.density.rowMinHeight)`,
   `EdgeInsetsDirectional` padding, `BorderDirectional(bottom: l.rules.hairlineDotted)`, an inert
   chevron flipped under RTL.
5. `water_type_toggle.dart`: `LonjaSegmented` over the two or three permitted values, rendered behind
   the `has_freshwater && has_saltwater` guard. It writes nothing in this task — T08 wires its meaning.
6. `zone_picker_empty.dart`: plate, headline, body, one action, per `the-four-states.md`.
7. `zone_picker_screen.dart`: the bar row (back button, translated tooltip, mirrored glyph, 44/56 dp),
   then a `CustomScrollView` of the three levels and the toggle. `switch` over the `AsyncValue`
   exhaustively; `switch` over `DataFailure` exhaustively, mapping `code` to an ARB key.
8. Add the eleven ARB keys to all six files (D-3) and run E06's completeness check.
9. Re-run the whole app suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 22 tests pass, and each failed first.
- [ ] Every string on the screen resolves through `AppLocalizations` or `content_string`; a literal
      fails `check_lonja_nav.sh`.
- [ ] All eleven ARB keys exist in all six locales (D-3) and E06's CI check is green.
- [ ] No `ListTile`, `DataTable`, `Card`, `elevation` or `BorderRadius` anywhere in `app/lib/ui/zones/`.
- [ ] Every level list is a `.builder`; no `Column` of rows inside a scroll view.
- [ ] `no_directional_geometry.sh app/lib` clean — no `EdgeInsets.only(left:` or `right:` (D-8).
- [ ] The picker writes to `SettingsRepository` exactly once per confirmed selection, and never while
      drilling.
- [ ] The `AsyncValue` switch and the `DataFailure` switch both have no `default:` arm.
- [ ] The country level is labelled from ARB and every jurisdiction and zone name from `content_string`
      through E06's resolver — no second fallback chain in `app/lib/ui/zones/`.
- [ ] `app/lib/ui/zones/` imports nothing from `app/lib/data/services/`
      (`FLUTTER_GUIDE.md` §2.5 rule 2).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh         app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh          app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh           app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
tools/gates/no_directional_geometry.sh                                     app/lib
$FLUTTER_SKILLS/state-management-riverpod/scripts/ban-legacy-providers.sh  app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(zones): build the S9 picker as three ruled levels over jurisdiction and zone

SPEC 7.1 has no country table, so the three levels of SPEC 4.4 map onto two:
country is jurisdiction.country_iso2 grouped, region is the jurisdiction row
itself, and sub-zone is the zone rows whose parent_zone_id resolves to that
jurisdiction's region-kind zone. That is the same shape as the engine's
zonePath, root first, so the picker can hand resolve() an ancestry it read
from parent_zone_id rather than one it inferred from geometry — a bank whose
ring overruns its region by fifty metres must not acquire a different parent.

The picker opens already drilled to the active selection, because "set once,
changeable in two taps" is false if tap two lands on a blank country list.
The drill path is one immutable value on one notifier: three nullable
strings that change together, so a country change can never land before its
jurisdiction clears and render a Galician sub-zone under Brazil.

Country labels are ARB — SPEC 9.2's tier-2 list names jurisdiction and zone
names and not countries, and no instrument names a country. Every other name
goes through E06's content_string resolver and its fallback chain; a second
chain here would disagree with the first the day a Galician string is
missing. Rows are one InkWell over the full 64 dp rect, hairline-separated,
with no ListTile and no Card anywhere.

Task: E11/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
