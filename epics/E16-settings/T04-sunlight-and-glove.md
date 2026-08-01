# E16/T04 — Sunlight and glove

| | |
|---|---|
| **Epic** | E16 — Settings |
| **Branch** | `epic/16-settings` (shared) |
| **Commit** | `feat(settings): add the sunlight theme and glove density switches` |
| **Depends on** | T02 (the screen shell and `SettingsRow`), E07 (three themes and the density switch), E10 (the result screen long-press) |
| **Size** | S |
| **Spec** | `SPEC.md` §6 S14 (sunlight mode, glove mode), §4.9 (glove ≥ 56 dp with ≥ 8 dp separation; sunlight is a third theme toggled in S14 **and** by long-press on the result), §11 Both ("sunlight mode is a third theme, not a variant of either"), §13 (contrast ≥ 7:1 in sunlight; targets ≥ 56 dp in glove) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-forms-and-controls` | Rule 11 — a `LonjaSwitch` is a 20 px square whose state is a **word**, with no track, no knob and no travel animation; and rule 3, targets read `LonjaTargets` and never a literal |
| `lonja-lists-and-tables` | The settings row envelope these two switches sit in, and what glove mode does to it (58 → 68 dp) without re-laying it out |
| `catchlaw-conventions-index` | Invariant 4: colour is never the only signal, which is exactly what a bare filled square would be |
| `state-management-riverpod` | `select` at the `MaterialApp` so a theme change rebuilds the tree and a coordinate-capture change does not |
| `accessibility-as-code` | The `Semantics` toggled state, the 44 dp floor these controls clear at 56, and the greyscale proof |
| `widget-golden-and-a11y-testing` | Six lanes per control: three themes × two densities, doubled by `ar` |
| `design-system-structure` | How the `ThemeExtension` resolves, since this task chooses which theme and which density the app hands it |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S14 | "sunlight mode · glove mode" — two entries, two independent columns |
| `SPEC.md` | §4.9, Glove mode and Sunlight mode rows | "All primary targets ≥ 56 dp with ≥ 8 dp separation"; "A third theme (not a dark-mode variant): maximum contrast, monochrome plus result colour. Toggle in S14 **and by long-press on the result**" |
| `SPEC.md` | §11 Both | "Dark mode supported; sunlight mode is a third theme, not a variant of either" |
| `SPEC.md` | §13, Accessibility row | Contrast ≥ 4.5:1, ≥ 7:1 in sunlight; targets ≥ 48 dp, ≥ 56 dp in glove |
| `FLUTTER_GUIDE.md` | Part 5.3 | `select()` at the consumer — the `MaterialApp` watches three fields, not the whole record |
| `FLUTTER_GUIDE.md` | Part 5.5 | `ref.read` in a callback, never `ref.watch` |
| `.claude/skills/lonja-forms-and-controls/SKILL.md` | Rule 3, rule 8, rule 11; "Targets, separation and glove mode" | The square toggle with its state as a word; `LonjaTargets.control` 56 / `gloveControl` 66 / `separation` 8; glove read from the token extension, never from `MediaQuery.sizeOf` |
| `.claude/skills/lonja-forms-and-controls/references/control-anatomy.md` | "Targets and density"; "Sunlight re-encoding" | The token table, and that glove is orthogonal to theme — three themes × two densities = six lanes per control |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "Density: paper, glove, sunlight" | Settings row 58 → 68 dp; separation 8 → 12 dp; sunlight deletes every grey and leaves slot order and type roles identical |
| `.claude/skills/lonja-dialogs-and-surfaces/references/surfaces-and-plates.md` | §3, Fills per theme; §8 | Sunlight is a real third theme, not a contrast tweak: every grey collapses to `sun-ink` on `sun-paper` and only the semantic verdict survives; glove changes spacing and target size only |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §4 | Three signals per state, at most one of which may be hue |
| `epics/CONVENTIONS.md` | §5, §9 | Test naming with the `sunlight - ` and `glove - ` prefixes; the invariants |

## What this delivers

- `app/lib/ui/settings/widgets/settings_display_rows.dart` — `SettingsSunlightRow` and
  `SettingsGloveRow`, each a `SettingsRow` whose value slot is a `LonjaSwitch`.
- Both wired into `SettingsScreen`'s display section, in the §6 S14 order.
- Changes to the `MaterialApp` owner (`CatchlawApp`): theme resolution reads `sunlightMode`, density
  reads `gloveMode`, both through one `select`.
- The E10 result-screen long-press re-pointed at `SettingsRepository.setSunlightMode` if it writes the
  column any other way — see below.
- ARB keys in all six locales: `settingsSectionDisplay`, `settingsSunlightLabel`,
  `settingsSunlightDetail`, `settingsGloveLabel`, `settingsGloveDetail`, `settingsSwitchOn`,
  `settingsSwitchOff`.
- `app/test/ui/settings/settings_display_rows_test.dart`,
  `app/test/ui/settings/sunlight_write_path_test.dart`.

## Why it is built this way

**Sunlight is a third theme, not a brightness.** `SPEC.md` §11 Both and §4.9 both say it, and
`surfaces-and-plates.md` §3 shows why it cannot be modelled as a dark variant: sunlight deletes every
grey — `ink-muted`, `ink-faint` and `rule` all collapse to `sun-ink` `#000000` on `sun-paper`
`#FFFFFF` — and leaves exactly one hue, the semantic verdict. A `ThemeMode.dark` plus a
`highContrast` flag cannot express "delete `harbour`", because `harbour` is chrome and survives in
both of the other two. So the resolution is: `sunlight_mode == 1` selects the sunlight theme outright,
regardless of platform brightness; otherwise `ThemeMode.system` chooses between paper and night.
**Rejected: `ThemeMode.dark` + a high-contrast flag**, and **rejected: a `MediaQuery.highContrastOf`
derivation**, which would make the setting untestable and un-toggleable at sea.

**Glove is orthogonal, and it is a density, not a theme.** `control-anatomy.md`'s "Targets and density"
is explicit: paper, night and sunlight each have a glove and a standard density, giving six lanes per
control. So `gloveMode` feeds the density extension and nothing else. It raises
`LonjaTargets.control` 56 → 66, the settings row 58 → 68 and separation 8 → 12
(`row-and-table-anatomy.md`), and it changes no colour, no rule weight and no type role
(`surfaces-and-plates.md` §8). **Rejected: inferring glove from screen width** — the skill names it
directly: "a phone in a pocket is not a glove".

**One writer, two entry points.** `SPEC.md` §4.9 says sunlight is toggled "in S14 and by long-press on
the result". Those are two gestures on one column. If E10's long-press writes it through any path other
than `SettingsRepository.setSunlightMode` — a local notifier, a second companion write, a theme
provider holding its own bool — this task re-points it, in this commit. That is a two-file change and
it belongs here rather than in a follow-up, because a second writer of one column is precisely the
defect this task exists to prevent: the two entry points would disagree the first time both were used
in one session, and the one the user reached last would lose.

**The switch state is a word.** `lonja-forms-and-controls` rule 11: a 20 px square that fills solid
`ink` when on, beside a sans label reading the state in words. No track, no knob, no travel animation.
This is also how invariant 4 is satisfied — the filled square is the hue-adjacent signal, the word is
the second, and the label above it is the third. **Rejected: Material's `Switch`**, whose state is a
knob position, which is a picture of a switch and is unreadable at a glance through spray.

**`select`, not a bare `watch`, at the `MaterialApp`.** `FLUTTER_GUIDE.md` §5.3: watching the whole
`UserSettings` at the root means a `capture_coordinates` toggle rebuilds every widget in the app. The
root watches a three-field record — `(localeOverride, sunlightMode, gloveMode)` — and Dart 3 records
compare structurally, so the filter is real.

**Turning sunlight on does not change any stored figure.** It is a rendering choice. Nothing about the
verdict wording, the citation or the numbers moves; `product-invariants.md` §4 requires every state to
survive greyscale, and sunlight is close to that already.

## Tests first

Write every row before touching either widget. Run them. **They must fail.** If the write-path test
(row 9) passes before the re-point, E10 already routes through the repository — verify that by reading
E10's code, do not assume it.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SettingsSunlightRow renders its state as a word` | `sunlightMode: false` | the `off` word is present | Invariant 4 and `lonja-forms-and-controls` rule 11: a filled square alone is colour-as-only-signal |
| 2 | `SettingsSunlightRow writes true when the switch is tapped` | tap | `setSunlightMode(true)` once | The write path |
| 3 | `SettingsGloveRow writes true when the switch is tapped` | tap | `setGloveMode(true)` once | The write path for the second, independent column |
| 4 | `SettingsGloveRow leaves sunlightMode unchanged` | sunlight on, then glove on | both `true` | The orthogonality claim, asserted rather than assumed; a shared "display mode" enum would fail here |
| 5 | `sunlight - CatchlawApp resolves the sunlight theme when sunlightMode is true` | `sunlightMode: true`, platform brightness light | the sunlight theme, not paper | The third-theme decision; a `ThemeMode` mapping cannot express it |
| 6 | `sunlight - CatchlawApp resolves the sunlight theme when the platform brightness is dark` | `sunlightMode: true`, platform dark | still sunlight | Sunlight overrides both, which is the whole point of it not being a variant |
| 7 | `CatchlawApp resolves the night theme from the platform when sunlightMode is false` | `sunlightMode: false`, platform dark | night | The negative case: sunlight must not have replaced dark mode |
| 8 | `glove - SettingsSunlightRow measures 66 dp` | `gloveMode: true` | switch target height ≥ 66 | `LonjaTargets.gloveControl`; `SPEC.md` §4.9's 56 dp floor is the product minimum and 66 is the over-provision |
| 9 | `SettingsSunlightRow and the result-screen long-press write the same column` | toggle from S14, then long-press on S2 | both calls land on `setSunlightMode`, and the emitted `UserSettings` agree | Two gestures, one column; a second writer disagrees the first session both are used |
| 10 | `CatchlawApp does not rebuild when captureCoordinates changes` | flip `captureCoordinates` | the root's build count is unchanged | The `select` from `FLUTTER_GUIDE.md` §5.3; without it every settings write rebuilds the whole app |
| 11 | `glove - SettingsRow separation measures 12 dp` | `gloveMode: true` | gap ≥ 12 | `row-and-table-anatomy.md`: separation 8 → 12; `SPEC.md` §4.9's floor is 8 dp and glove raises it |
| 12 | `sunlight - SettingsGloveRow draws no grey` | sunlight theme | no `ink-muted` or `ink-faint` value in the row's painted colours | `surfaces-and-plates.md` §3: every grey collapses to `sun-ink`; a surviving grey is invisible on an open deck |
| 13 | `ar - SettingsSunlightRow places the switch square at the end edge` | `ar` locale | square's start edge exceeds the label's | Directional geometry (D-8); a physical-left placement reads correctly in `en` and lands under the label in `ar` |

```dart
// app/test/ui/settings/sunlight_write_path_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/harness.dart';

void main() {
  testWidgets('SettingsSunlightRow and the result-screen long-press write the same column',
      (tester) async {
    final repo = FakeSettingsRepository();

    await tester.pumpWidget(settingsHarness(repository: repo));
    await tester.tap(find.byType(SettingsSunlightRow));
    await tester.pump();

    await tester.pumpWidget(resultHarness(repository: repo, species: kSpeciesHamour));
    await tester.longPress(find.byType(VerdictPanel));
    await tester.pump();

    // Two gestures, one column, one writer.
    expect(repo.sunlightWrites, [true, false]);
    expect((await repo.watch().first).sunlightMode, isFalse);
  });
}
```

**Run:** `cd app && flutter test test/ui/settings/settings_display_rows_test.dart
test/ui/settings/sunlight_write_path_test.dart` → 13 failures. If any passes now, the test is wrong.

## Implementation outline

Only after the tests are red.

1. `settings_display_rows.dart` — two `SettingsRow`s, each with a `LonjaSwitch` in the value slot and
   the state word beside the square. Heights come from the density extension; no numeric literal in
   the file (`lonja-forms-and-controls` rule 3).
2. `CatchlawApp` — replace the theme wiring with:
   `ref.watch(userSettingsProvider.select((s) => (s.valueOrNull?.localeOverride,
   s.valueOrNull?.sunlightMode ?? false, s.valueOrNull?.gloveMode ?? false)))`, then
   `theme:` / `darkTheme:` / `themeMode:` for the non-sunlight case and an outright sunlight theme
   otherwise. The density flag goes into the token extension E07 owns.
3. Read E10's long-press. If it writes anything other than
   `ref.read(settingsRepositoryProvider).setSunlightMode(...)`, re-point it here and delete whatever
   local state it held. Do not leave both.
4. Six ARB files, seven new keys, one commit (D-3).
5. Re-run the whole suite. E10's result-screen tests must still be green; if one asserted against the
   old local state, update the assertion in this commit and say so in the body.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 13 rows pass, and each failed first.
- [ ] `grep -rn "setSunlightMode" app/lib` shows exactly two call sites — S14 and the S2 long-press —
      and one implementation.
- [ ] `grep -rn "MediaQuery.sizeOf\|MediaQuery.of(context).size" app/lib/theme app/lib/ui/settings`
      returns nothing: glove is never inferred from width.
- [ ] `grep -rnE "(56|66|58|68|12)\b" app/lib/ui/settings/widgets/settings_display_rows.dart` returns
      nothing — every metric resolves through `LonjaTargets` or the density extension.
- [ ] Six golden lanes per switch: paper / night / sunlight × standard / glove, plus the `ar` lane
      (`control-anatomy.md`, Targets and density).
- [ ] The greyscale golden of both rows distinguishes on from off (`product-invariants.md` §4).
- [ ] `SettingsScreen` still builds zero `LonjaButtonVariant.primary`.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh   app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh        app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh               app/lib
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
feat(settings): add the sunlight theme and glove density switches

Sunlight is resolved as a third theme rather than as a dark-mode variant,
because it deletes every grey and every chrome hue and leaves only the
semantic verdict — a ThemeMode plus a contrast flag cannot express that
(SPEC 11 Both, SPEC 4.9). Glove feeds the density extension and nothing
else: 56 to 66 dp targets, 58 to 68 dp rows, 8 to 12 dp separation, and no
colour, rule weight or type role changes. A test asserts the two columns
are independent, because a single "display mode" enum is the obvious wrong
model here.

Both switches carry their state as a word beside the filled square. A
square alone is colour as the only signal, and a Material Switch's knob
position is unreadable through spray.

The result screen's long-press now writes through
SettingsRepository.setSunlightMode, the same path as this row. Two gestures
on one column with two writers disagree the first session both are used.

Task: E16/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
