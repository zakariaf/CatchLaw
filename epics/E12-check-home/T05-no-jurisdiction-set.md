# E12/T05 — No jurisdiction set

| | |
|---|---|
| **Epic** | E12 — Check home and the navigation shell |
| **Branch** | `epic/12-check-home` (shared) |
| **Commit** | `feat(check): read Choose your area on the zone chip when no jurisdiction is set` |
| **Depends on** | T02 (the chips exist and are wired) |
| **Size** | S |
| **Spec** | `SPEC.md` §6 S1 "Error state", §6 S9, §4.4 (jurisdiction picker), §4.7 (content currency) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-navigation-chrome` | Owns both chips: the zone chip states place and nothing else, and the currency ladder has an explicit "unknown" rung that this state lands on. |
| `catchlaw-conventions-index` | Invariant 4 (the word changes as well as the colour) and invariant 5 (nothing blocks) are what make an unset jurisdiction a statement rather than an error. |
| `lonja-design-tokens` | `verdictWarn` is `ochre47` at 3.97:1 — legal as a border and a glyph, never as the word. |
| `state-management-riverpod` | The unset state is a null on the profile provider, not a separate screen; the switch must be exhaustive. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S1, "Error state" | None possible. With no jurisdiction set the zone chip reads "Choose your area" → S9 |
| `SPEC.md` | §6 S9 | Where the chip goes: country → region → sub-zone, "Use my location", saved zones, water-type toggle |
| `SPEC.md` | §4.4 | Set once, changeable in two taps; a jurisdiction with no polygons hides the sub-zone level |
| `SPEC.md` | §7.2, `user_profile` | `active_jurisdiction` and `active_zone_code` are both nullable — the unset state is representable by design |
| `SPEC.md` | §6 S5, "Empty state" | Search covers the active jurisdiction only; with none set there is nothing to search |
| `.claude/skills/lonja-navigation-chrome/references/chips-and-currency.md` | "The currency ladder" | The Unknown rung: no `checked_at` → ochre, "Check date unknown — verify locally", chip plus band, never blocking |
| `.claude/skills/lonja-navigation-chrome/references/chips-and-currency.md` | "Copy rules", "Chip metrics" | `Detecting location…` and `Zone: nearest` are forbidden; 38/56 dp min height either way |
| `.claude/skills/lonja-navigation-chrome/SKILL.md` | rules 8, 9 | The zone chip states place and nothing else; the currency chip never blocks |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariants 4 and 5 | Colour never moves alone; stale — and unknown — beats absent |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "Measured contrast — paper theme" | `ochre47` 3.97:1: a mark only, so the word stays `onSurface` |
| `epics/DECISIONS.md` | D-3 | Six locales for both new keys |

## What this delivers

- Changes to `app/lib/ui/core/ui/lonja_zone_chip.dart` — the unset label and the unchanged destination.
- Changes to `app/lib/ui/core/ui/lonja_currency_chip.dart` — the Unknown rung of the ladder.
- Changes to `app/lib/ui/check/check_screen.dart` — the unset branch of the profile switch, which
  changes two chips and nothing else.
- `app/lib/l10n/app_*.arb` × 6 — `zoneChipUnset` ("Choose your area"),
  `currencyCheckDateUnknown` ("Check date unknown — verify locally").
- `app/test/ui/core/ui/lonja_zone_chip_test.dart`,
  `app/test/ui/core/ui/lonja_currency_chip_test.dart`,
  additions to `app/test/ui/check/check_screen_test.dart`.

## Why it is built this way

**No jurisdiction is a value, not a failure.** `user_profile.active_jurisdiction` is nullable in
`SPEC.md` §7.2, so the unset state is representable from the first launch onwards. §6 S1 says no error
state is possible on this screen, and it is right: the app cannot fail to know where the user is,
because it never tried to find out. The chip states what is true — no area chosen — and offers the one
control that changes it.

**The chip's destination does not change.** Set or unset, tapping the zone chip opens S9. A user who
learns one gesture on day one must not find it does something else on day two, and a second destination
for a second state doubles the routes for one control. Only the words change.

**The currency chip lands on the Unknown rung.** `chips-and-currency.md` already has this case: no
`checked_at` gives ochre plus "Check date unknown — verify locally". It is not a new state and it is
not an invention. Crucially the **words** change and not only the hue, which is invariant 4 — a
greyscale render must still say the date is unknown. The word itself stays `onSurface`, because
`token-tables.md` measures `ochre47` at 3.97:1 against paper, which clears the non-text floor for a
border and a glyph and fails 4.5:1 as text.

**Nothing is gated.** Browse by shape and Identify this fish need a species list, not a jurisdiction —
`SPEC.md` §4.3's key is morphological and works without a legal instrument. Disabling them would be the
mistake invariant 5 forbids in its other form: withholding what still works because something else is
missing. The tally bar renders with no counts, because there are no catches in a zone that has not been
chosen.

**Rejected: a first-run zone dialog.** §3 step 1 forbids onboarding, and D5 in §6's dialog list is a
*language* confirmation, not a zone one. A modal on first launch costs the one tap the whole product is
budgeted around, and it appears at the worst moment — the first time someone opens the app is often the
first time they need it.

**Rejected: inferring a jurisdiction from GPS.** §4.4 is explicit that GPS suggests and never
auto-switches, and `chips-and-currency.md` bans "Zone: nearest" and "Detecting location…" outright. Zone
is a chosen jurisdiction, not a sensor reading; a chip that animates implies a lookup that never
happens.

**Rejected: hiding the currency chip when there is no content version.** An absent trust signal reads
as a fresh one. The chip stays and states that the date is unknown.

## Tests first

Write every row before touching the chips. Run them. **They must fail.** If a chip already renders
"Choose your area", it is rendering a fallback string rather than the ARB key — fix the source before
writing the state.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LonjaZoneChip reads Choose your area when no jurisdiction is set` | profile with null jurisdiction | `l10n.zoneChipUnset` | The literal instruction in §6 S1 |
| 2 | `LonjaZoneChip routes to the zone picker when no jurisdiction is set` | tap the unset chip | location is S9 | One control, one destination, in both states |
| 3 | `LonjaZoneChip keeps its pin glyph and chevron when no jurisdiction is set` | unset | glyph and mirrored chevron present | It is the same chip, not a different affordance |
| 4 | `glove - LonjaZoneChip measures 56 dp tall when unset` | glove density | 56 dp | The unset chip is the same target; §4.9 does not relax for an empty value |
| 5 | `LonjaZoneChip states no location activity when unset` | unset | no spinner, no "detecting", no signal glyph | `chips-and-currency.md` bans it; there is no lookup to report |
| 6 | `LonjaCurrencyChip states the check date is unknown when no jurisdiction is set` | no `checked_at` | `l10n.currencyCheckDateUnknown` | The Unknown rung of the currency ladder |
| 7 | `LonjaCurrencyChip changes its words as well as its colour on the unknown rung` | fresh vs unknown | both label and tone differ | Invariant 4 — a greyscale render must still read as unknown |
| 8 | `sunlight - LonjaCurrencyChip states the unknown check date without relying on ochre` | sunlight theme | word present, still legible | Sunlight collapses the neutrals; the word carries the state |
| 9 | `LonjaCurrencyChip blocks nothing on the unknown rung` | unset | no modal, no barrier, chip is not disabled | Invariant 5 — nothing gates a screen that still works |
| 10 | `CheckScreen renders no error state when no jurisdiction is set` | unset profile | no error body, no `verdictFail` | §6 S1: no error state is possible |
| 11 | `CheckScreen keeps Browse by shape and Identify this fish enabled when no jurisdiction is set` | unset | both hit-testable and routing | Identification is morphological and needs no instrument |
| 12 | `CheckScreen shows the no-recents state when no jurisdiction is set` | unset | T04's authored state | Recents are per-zone; no zone means no recents, not a blank screen |
| 13 | `CheckScreen shows the tally bar with no counts when no jurisdiction is set` | unset | the authored no-catches line | The null zone code must not throw on the count query |
| 14 | `ar - LonjaZoneChip reads the Choose your area label from app_ar.arb` | locale `ar` | Arabic label | D-3 |

```dart
// app/test/ui/core/ui/lonja_zone_chip_test.dart
import 'package:catchlaw/routing/routes.dart' as routes;
import 'package:catchlaw/ui/core/ui/lonja_zone_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/harness.dart';

void main() {
  testWidgets('LonjaZoneChip reads Choose your area when no jurisdiction is set', (tester) async {
    await pumpLonja(tester, const LonjaZoneChip(zone: null));

    expect(find.text(l10nEn.zoneChipUnset), findsOneWidget);
  });

  testWidgets('LonjaZoneChip routes to the zone picker when no jurisdiction is set', (tester) async {
    final app = await pumpCheck(tester, zone: null);

    await tester.tap(find.byType(LonjaZoneChip));
    await tester.pumpAndSettle();

    expect(app.router.location, routes.zonePickerPath);
  });

  testWidgets('LonjaZoneChip states no location activity when unset', (tester) async {
    await pumpLonja(tester, const LonjaZoneChip(zone: null));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    final copy = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? '').join(' ');
    for (final banned in const ['Detecting', 'Locating', 'nearest', 'GPS']) {
      expect(copy, isNot(contains(banned)));
    }
  });
}
```

```dart
// app/test/ui/core/ui/lonja_currency_chip_test.dart
testWidgets('LonjaCurrencyChip changes its words as well as its colour on the unknown rung',
    (tester) async {
  await pumpLonja(tester, const LonjaCurrencyChip(checkedOn: null));
  final unknownWords = tester.widget<Text>(find.byKey(const ValueKey('currency.label'))).data;
  final unknownTone = toneOf(tester, const ValueKey('currency.chip'));

  await pumpLonja(tester, LonjaCurrencyChip(checkedOn: DateTime.utc(2026, 7, 14)));
  final freshWords = tester.widget<Text>(find.byKey(const ValueKey('currency.label'))).data;
  final freshTone = toneOf(tester, const ValueKey('currency.chip'));

  expect(unknownWords, isNot(freshWords));
  expect(unknownTone, isNot(freshTone));
});
```

**Run:** `cd app && flutter test test/ui/core/ui test/ui/check/check_screen_test.dart` → 14 failures.
If any passes now, the test is wrong.

## Implementation outline

1. `lonja_zone_chip.dart`: make `zone` nullable and switch on it — label from the zone name plus its
   water qualifier, or `l10n.zoneChipUnset`. The `onTap` is unchanged and unconditional.
2. `lonja_currency_chip.dart`: add the Unknown rung — null `checkedOn` gives
   `l10n.currencyCheckDateUnknown`, the ochre border and seal glyph, and the label in `onSurface`.
3. `check_screen.dart`: the profile provider's null case changes the two chips' inputs. It must not
   introduce a second screen body, a barrier or a disabled control.
4. Add both ARB keys to all six locales. The English values are the exact strings in §6 S1 and in the
   currency ladder; the other five are translations of those, not paraphrases.
5. Re-run the whole suite, including T02's routing tests and T03's tally tests with a null zone code.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 tests pass, and each failed first.
- [ ] The zone chip's destination is identical in both states — one `onTap`, no branch.
- [ ] No error body, barrier, modal or disabled control exists on any path where the jurisdiction is
      null.
- [ ] The unknown currency state changes the words as well as the hue, proved by a test that compares
      both against the fresh state.
- [ ] The ochre tone is a border and a glyph; the word is `onSurface`.
- [ ] The count query tolerates a null zone code and returns zero rows rather than throwing.
- [ ] Both ARB keys exist in all six locales (D-3).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh   app/lib
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
feat(check): read Choose your area on the zone chip when no jurisdiction is set

user_profile.active_jurisdiction is nullable by design (SPEC.md §7.2), so the
unset state exists from the first launch. §6 S1 says no error state is
possible on this screen and it is right: the app cannot fail to know where the
user is, because it never tried to find out. The chip states the absence and
offers the one control that changes it, and its destination is identical set
or unset — a user who learns one gesture must not find it does something else
the next day.

The currency chip lands on the ladder's existing Unknown rung: the words
change as well as the hue, so a greyscale render still reads as unknown, and
the word stays onSurface because ochre47 measures 3.97:1 on paper.

Nothing is gated. Browse by shape and Identify this fish need a species list,
not a legal instrument.

Task: E12/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
