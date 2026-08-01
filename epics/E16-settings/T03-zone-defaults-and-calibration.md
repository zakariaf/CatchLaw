# E16/T03 — Zone defaults, and the way in to calibration

| | |
|---|---|
| **Epic** | E16 — Settings |
| **Branch** | `epic/16-settings` (shared) |
| **Commit** | `feat(settings): show the active zone and open calibration from S14` |
| **Depends on** | T02 (the screen shell and `SettingsRow`), E09 (S4 exists), E11 (S9 exists) |
| **Size** | S |
| **Spec** | `SPEC.md` §6 S14 (zone defaults, ruler calibration), §6 S1 (the "Choose your area" state), §6 S4, §4.2 ("re-calibratable from Settings"), §4.4 (saved zones), §9.5 (dates are locale-formatted) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-measurement-ruler` | Rule 8 and the plausibility band: re-entering S4 must not clear a stored calibration before a new one is judged, and a rejected calibration leaves the previous value untouched |
| `lonja-lists-and-tables` | Two navigation rows: the whole row is one tap target, the chevron is inert decoration, the value slot is mono |
| `lonja-buttons` | The `Re-calibrate with a card` label is in the approved corpus; a noun label (`Calibration`) is banned, and this screen has no primary |
| `catchlaw-conventions-index` | Routing: the zone picker is a route, not a modal, and `lib/ui/` never queries a DAO |
| `navigation-and-routing` | Pushing S9 and S4 as routes and handling the value they pop |
| `state-management-riverpod` | Reading the two zone columns and the two calibration columns from one provider |
| `i18n-rtl-l10n` | The locale-formatted calibration date, directional chevrons, and the ARB keys in six locales |
| `accessibility-as-code` | The row's accessible name must include the current value, not only the label |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S14 | "zone defaults · ruler calibration" — the two rows this task adds |
| `SPEC.md` | §6 S1, Error state | "With no jurisdiction set the zone chip reads 'Choose your area' → S9" — the wording this row reuses rather than inventing a second one |
| `SPEC.md` | §6 S4, Error state | "result outside a plausible range → rejected with an explanation, not saved" — what happens when the user re-runs calibration from here and it fails |
| `SPEC.md` | §4.2, Calibration row | "stored as px-per-mm; re-calibratable from Settings" — this task is the sentence's second half |
| `SPEC.md` | §9.5, Dates | "`intl`, locale-formatted. Season windows read '1 March – 30 April', never `2026-03-01`" — the calibration date follows the same rule |
| `.claude/skills/catchlaw-measurement-ruler/SKILL.md` | Rule 8; rule 9 | An implausible scale is rejected and never stored; manual entry works before any calibration exists, so this row is never a gate |
| `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md` | "Plausibility band"; "Manual entry is the ground floor"; Procedure step 5 | The four-row band table, that recalibration replaces the single row, and that the manual path stays enabled in every case |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | Rules 1, 8, 11 | The whole row is the target; a row states and never instructs; slot order is fixed |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The settings row" | 58 dp / 68 dp, serif key, sans sub-line, value slot after a `Spacer()` |
| `.claude/skills/lonja-buttons/references/button-anatomy.md` | "Label wording" | `Re-calibrate with a card` is verbatim in the approved corpus; `Calibration` as a noun and `Retry` are both listed as failures |
| `.claude/skills/lonja-dialogs-and-surfaces/references/modal-decision-matrix.md` | §2, the matrix | "Zone picker — Ras Al Khaimah / Rias Baixas — no — route or inline panel": this is not a modal |
| `epics/DECISIONS.md` | D-3, D-8 | Six locales for the new ARB keys; directional geometry is grep-gated |
| `epics/CONVENTIONS.md` | §5 | Test naming |

## What this delivers

- `app/lib/ui/settings/widgets/settings_zone_row.dart` — `SettingsZoneRow`: key, the active
  jurisdiction and zone as the value, whole row taps into S9.
- `app/lib/ui/settings/widgets/settings_calibration_row.dart` — `SettingsCalibrationRow`: key, the
  calibration state as the value, whole row taps into S4.
- Both rows wired into `SettingsScreen`'s zone-defaults section, in the §6 S14 order.
- ARB keys in all six locales: `settingsSectionZone`, `settingsActiveZoneLabel`,
  `settingsRulerCalibrationLabel`, `settingsRulerNotCalibrated`, `settingsRulerCalibratedOn`,
  `settingsRulerManualAlwaysAvailable`.
- `app/test/ui/settings/settings_zone_row_test.dart`,
  `app/test/ui/settings/settings_calibration_row_test.dart`.

**Reused, not re-authored:** the "Choose your area" string already exists as an ARB key from E12's S1
zone chip (`SPEC.md` §6 S1), and `Re-calibrate with a card` already exists from E09. This task adds
neither. Two ARB keys holding the same sentence drift within one translation round.

## Why it is built this way

**Both are rows, not modals.** `modal-decision-matrix.md` §2 answers the zone case directly: the zone
picker is a route or an inline panel, never a modal, because the user can keep doing something useful
while it is on screen. The calibration surface is a full screen (S4) for the same reason plus a
physical one — it needs the whole display to lay a card against.

**The whole row is the target.** `lonja-lists-and-tables` rule 1: a chevron carries no gesture. A 15 dp
chevron hit box on a wet deck means the row does nothing and the user taps twice more and gives up.
The value slot — `Rias Baixas · ES-GA`, `Calibrated 14 July 2026` — is inert text inside that target.

**The unset state reuses S1's sentence.** When `active_jurisdiction` is `NULL` the value slot reads the
same "Choose your area" the S1 zone chip shows. `SPEC.md` §6 S1 fixes that wording; a second phrasing
here would mean the app calls the same absent fact two different things on two screens.

**The calibration row is never a gate, and never disabled.** `catchlaw-measurement-ruler` rule 9 and
`ruler-and-calibration.md`'s "Manual entry is the ground floor" table: with `calibration == null` only
the *ruler tab* is disabled — the measure step, the keypad and the verdict are all still reachable. So
this row's uncalibrated state is a statement of fact plus a sub-line saying manual entry is available;
it is not an error, not ochre, and not a blocked control.

**Re-running S4 must not pre-clear the stored value.** `catchlaw-measurement-ruler` rule 8: an
implausible measurement returns `CalibrationImplausible` and "the previous `RulerCalibration` survives
untouched". The naive implementation of a "re-calibrate" entry point — null the column, push S4, let
S4 write — loses a good calibration the moment the user backs out or mis-drags. This row pushes S4 and
writes nothing at all. Row 6 is the test.

**This task writes no calibration column.** One column, one writer (T01): `ruler_px_per_mm` and
`ruler_calibrated_at` are E09's, and this row only reads them. The zone columns are this repository's,
but they are written by S9 on pop — this row does not write them either, it just routes. The only
write S14 ever makes to `active_jurisdiction` / `active_zone_code` is the one S9 already makes, so
there is no second path to keep consistent. **Rejected: a settings-local zone dropdown** duplicating
S9's country → region → sub-zone tree, its "Use my location" affordance and its
`has_zone_polygons = 0` handling (`SPEC.md` §4.4, §6 S9).

**The date is locale-formatted.** `SPEC.md` §9.5: `intl`, locale-formatted, never an ISO string on
screen. `2026-07-14` is stored; `14 July 2026` / `14 de julio de 2026` / `١٤ يوليو ٢٠٢٦` is rendered,
through the same numeral system T02 set.

## Tests first

Write every row before touching either widget. Run them. **They must fail.** These are widget tests
over `FakeSettingsRepository` behind a `ProviderScope` override, with a recording router; none opens a
database.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SettingsZoneRow shows the jurisdiction and the zone code` | `ES-GA` / `RIAS-BAIXAS` | both appear in the value slot | A zone code without its jurisdiction resolves against the wrong rule set (T01 row 5); the row must never show one alone |
| 2 | `SettingsZoneRow shows the S1 unset wording when activeJurisdiction is null` | both columns `null` | the S1 "Choose your area" key renders | Reuse, not re-authoring: two keys with one sentence diverge on the next translation round |
| 3 | `SettingsZoneRow opens S9 when the row's start edge is tapped` | tap at the start edge | one push of the S9 route | `lonja-lists-and-tables` rule 1 — the whole rect is the target, and the start edge is the part a chevron-only implementation leaves inert |
| 4 | `SettingsCalibrationRow states the calibration date when rulerPxPerMm is set` | `6.31`, `2026-07-14` | a locale-formatted date, not `2026-07-14` | `SPEC.md` §9.5; an ISO string on screen is the defect this catches |
| 5 | `SettingsCalibrationRow states that manual entry is available when rulerPxPerMm is null` | `null` | the not-calibrated key plus the manual-entry sub-line | `catchlaw-measurement-ruler` rule 9: an uncalibrated device is not a blocked device, and the row must say so |
| 6 | `SettingsCalibrationRow writes nothing when it opens S4` | tap the row | zero setter calls on the fake | Rule 8: pre-clearing the column would destroy a good calibration when the user backs out of S4 |
| 7 | `SettingsCalibrationRow keeps the stored calibration when S4 returns CalibrationImplausible` | push S4, pop an implausible outcome | `rulerPxPerMm` unchanged | The end-to-end half of rule 8, asserted from the settings entry point rather than only inside E09 |
| 8 | `ar - SettingsCalibrationRow renders the date in the active numeral system` | `ar`, `numeralSystem: arab` | `١٤` appears in the value slot | The T02 setting has to reach every figure on the screen, dates included |
| 9 | `RTL - SettingsZoneRow places the chevron at the end edge` | `ar` locale | chevron's start edge exceeds the value slot's | `Icons.chevron_right` points away from the destination in Arabic (`row-and-table-anatomy.md`) |
| 10 | `glove - SettingsCalibrationRow measures 68 dp` | `gloveMode: true` | height ≥ 68 | The density switch must reach rows added after T02, not only the three it shipped with |

```dart
// app/test/ui/settings/settings_calibration_row_test.dart
import 'package:catchlaw/ui/settings/widgets/settings_calibration_row.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/harness.dart';

void main() {
  testWidgets('SettingsCalibrationRow states that manual entry is available '
      'when rulerPxPerMm is null', (tester) async {
    await tester.pumpWidget(
      settingsHarness(settings: kDefaultSettings.copyWith(rulerPxPerMm: null)),
    );
    expect(find.text('Not calibrated'), findsOneWidget);
    expect(find.text('Length can still be typed in.'), findsOneWidget);
  });

  testWidgets('SettingsCalibrationRow writes nothing when it opens S4', (tester) async {
    final repo = FakeSettingsRepository();
    final router = RecordingRouter();
    await tester.pumpWidget(settingsHarness(repository: repo, router: router));
    await tester.tap(find.byType(SettingsCalibrationRow));
    await tester.pumpAndSettle();
    expect(router.pushed, ['/calibration']);
    expect(repo.writes, isEmpty); // rule 8: the previous calibration survives untouched
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/ui/settings/settings_zone_row_test.dart
test/ui/settings/settings_calibration_row_test.dart` → 10 failures. If any passes now, the test is
wrong.

## Implementation outline

Only after the tests are red.

1. `settings_zone_row.dart` — a `SettingsRow` whose value slot is mono text built from
   `activeJurisdiction` and `activeZoneCode`, falling back to E12's existing "Choose your area" key
   when the jurisdiction is `null`. `onTap` pushes S9's route. The chevron is a `LonjaGlyph`, inert.
2. `settings_calibration_row.dart` — the same shape. Value slot: the not-calibrated key, or the
   locale-formatted `ruler_calibrated_at`. Sub-line: the manual-entry statement when uncalibrated.
   `onTap` pushes S4's route and writes nothing.
3. Both into `SettingsScreen`'s zone-defaults section, in the §6 S14 order, under one
   `LonjaSectionLabel`.
4. Six ARB files, six new keys, one commit (D-3).
5. Re-run the whole suite, including E09's calibration tests — this task must not have changed the
   behaviour they cover.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 10 rows pass, and each failed first.
- [ ] `grep -rn "setRulerPxPerMm\|rulerCalibratedAt\s*=" app/lib/ui/settings` returns nothing — this
      task writes no calibration column.
- [ ] The six new ARB keys exist in all six locales, and no key added here duplicates E12's
      "Choose your area" or E09's `Re-calibrate with a card`.
- [ ] No `Icons.chevron_right` in the diff (`row-and-table-anatomy.md`, RTL mirroring).
- [ ] Both rows are one tap target each, verified by tapping the start edge (row 3).
- [ ] `SettingsScreen` still builds zero `LonjaButtonVariant.primary`.
- [ ] Golden lanes: `en` paper, `ar` paper, `ar` paper glove for both rows, in the calibrated **and**
      uncalibrated states.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh    app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh        app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh               app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
tools/gates/no_directional_geometry.sh                                    app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(settings): show the active zone and open calibration from S14

Both are rows that route, not modals: the zone picker is browsable, so the
modal decision matrix puts it on a route. The rows carry the whole tap
target and the chevron is inert, because a 15 dp chevron hit box on a wet
deck reads as a dead row.

The calibration row writes nothing when it opens S4. The obvious
implementation — clear the column, push, let S4 write — destroys a good
calibration the moment the user backs out or mis-drags, and the
measurement skill's rule 8 requires the previous value to survive an
implausible result untouched.

The uncalibrated state is a statement plus a sub-line saying length can
still be typed in. An uncalibrated device is not a blocked device: manual
entry is the ground floor and always was.

Task: E16/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
