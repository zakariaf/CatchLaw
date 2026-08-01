# E06/T08 — The golden harness, with a font that has Arabic glyphs

| | |
|---|---|
| **Epic** | E06 — Localisation infrastructure |
| **Branch** | `epic/06-localisation` (shared) |
| **Commit** | `test(l10n): load a Naskh font for goldens and pin the lane to Linux` |
| **Depends on** | T01 (six locales), T04 (the numeral lever and its symbol guard), T06 (a way to pin the locale) |
| **Size** | L |
| **Spec** | `SPEC.md` §9.3 last bullet (goldens render every screen in `ar` and assert no overflow); §8 fonts row; §13 accessibility row |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `widget-golden-and-a11y-testing` | Owns the golden doctrine. `references/golden-two-lanes.md` — goldens earn their keep only for glyph shaping, mirroring and numeral rendering; `references/harness-and-mediaquery.md` — `physicalSize` is physical pixels, `MediaQuery` above `MaterialApp`, `addTearDown(view.reset)` |
| `testing-strategy` | Rule 11 — a suite that costs minutes gets skipped. The matrix budget is a design constraint, not a preference |
| `i18n-rtl-l10n` | Rendering RTL or numeral goldens with the default test font is a named anti-pattern; bundle fonts covering every shipped script, with no runtime fetch |
| `lonja-typography` | `references/arabic-and-scripts.md` — the Naskh stack, zero tracking, and the fact that Arabic-Indic digits have no tabular-figure coverage. This task lands the faces E07's ramp will consume |
| `catchlaw-offline-guarantee` | `google_fonts` fetches at runtime and is banned; fonts are bundled assets or they do not exist |
| `ci-pipeline-and-gates` | Two lanes, tags, and blocking accidental `--update-goldens` |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `FLUTTER_GUIDE.md` | §6.4, "Two hard-won golden points" | **Point 1:** `flutter test` uses a test font with no Arabic coverage, so an `ar` golden is indistinguishable from an `en` golden and the test is worthless. **Point 2:** goldens are host-platform-dependent — generate and verify on one platform (Linux CI) |
| `FLUTTER_GUIDE.md` | §6.3 | The tooling verdicts: `golden_toolkit` is **dead**; `alchemist` is a **bad fit for Arabic goldens** because its CI mode replaces glyphs with blocks; goldens in 2026 are built-in `matchesGoldenFile` plus a ~60-line harness |
| `FLUTTER_GUIDE.md` | §6.2 | `flutter_test_config.dart` is directory-scoped and scanned upward — this is where font loading goes. Golden files live next to their test file; `**/failures/` is already ignored |
| `SPEC.md` | §9.3, last bullet | "Golden tests render every screen in `ar` and assert no overflow" — the eventual target. This task builds the harness; E20 renders the screens |
| `SPEC.md` | §8, Fonts row | Noto Sans + **Noto Naskh Arabic**, SIL OFL 1.1, ~8 MB subset in `assets/fonts/`, the files are not renamed and the OFL text ships in S17 |
| `epics/CONVENTIONS.md` | §6 | Keep the golden **matrix** small — 4–6 screens × 6 locales × 2 themes, generated and verified on Linux CI only; helpers must not end in `_test.dart` |
| `epics/DECISIONS.md` | D-3 | RTL golden lanes: `ar` only. There is one RTL locale in this product |
| `.claude/skills/widget-golden-and-a11y-testing/references/golden-two-lanes.md` | "Two lanes", "Setup", "RTL goldens pump under Directionality", "Discipline" | The lane split, the `flutter_test_config.dart` shape, tagging, and blocking `--update-goldens` |
| `.claude/skills/widget-golden-and-a11y-testing/references/harness-and-mediaquery.md` | "Device presets", "The four load-bearing lines" | `view.physicalSize = logicalSize * dpr`; `addTearDown(view.reset)`; `MediaQuery.of(context).copyWith`, never a bare `MediaQueryData()` |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Numerals", "Line-height headroom" | Why an `ar` golden at a Latin-tuned line height clips, and why numeral columns are pinned |

## What this delivers

- `app/assets/fonts/NotoNaskhArabic-Regular.ttf`, `app/assets/fonts/NotoSans-Regular.ttf`,
  `app/assets/fonts/OFL.txt` — SIL OFL 1.1, filenames unchanged, licence text shipped (`SPEC.md` §8).
- `app/pubspec.yaml` — the `flutter: fonts:` declaration for both families.
- `app/test/flutter_test_config.dart` — loads both faces through `FontLoader` before any test runs, and
  guards `numberFormatSymbols` around the whole file.
- `app/test/support/golden.dart` — the ~60-line harness (`FLUTTER_GUIDE.md` §6.3). Helper, **not**
  `_test.dart`: `Device` presets, `useDevice`, `pumpLocalised(locale, {textScaler})`, `goldenPath(...)`.
- `app/test/l10n/golden/numeral_specimen_test.dart` — tagged `@Tags(['golden'])`.
- `app/test/l10n/golden/goldens/` — the blessed PNGs, next to their test file.
- `app/test/l10n/golden/font_coverage_test.dart` — the non-golden proof that the Arabic font loaded.
- `app/test/l10n/golden/golden_hygiene_test.dart` — tag, matrix-size and CI-lane assertions.
- `.github/workflows/validate.yml` — the golden job: `ubuntu-latest`, `flutter test --tags golden`; the
  everyday job gains `--exclude-tags golden`; neither passes `--update-goldens`.

**What is goldened, and what is not.** `golden-two-lanes.md`: golden the i18n **primitives**
exhaustively and *sample* representative screens. There are no screens yet — E08 onward builds them and
E20 owns the screen matrix. So this task goldens one specimen widget: the digits 0–9 and `1 234 567,89`
rendered per locale, plus `ar` again under `NumeralSystem.arab`. Seven images. The ceiling is asserted.

## Why it is built this way

**Point 1 of `FLUTTER_GUIDE.md` §6.4 is the entire reason this task exists.** `flutter test` runs with
a test font whose every glyph is an identical box and no Arabic coverage at all. An `ar` golden taken
under it is byte-identical to the `en` golden of the same widget — the test passes, it will keep
passing through any amount of broken Arabic shaping, and it is worthless. `i18n-rtl-l10n` lists it as a
named anti-pattern. Row 1 below is the direct countermeasure: render the `ar` specimen and the `en`
specimen and assert the **bytes differ**. That single assertion is what makes every later `ar` golden
in this repository mean something.

**Built-in `matchesGoldenFile` and a hand-written harness.** `FLUTTER_GUIDE.md` §6.3 settles the
tooling by reading the packages: `golden_toolkit` is discontinued with an SDK constraint that cannot
resolve on Dart 3, and `alchemist` — whose `loadAppFonts` the golden reference otherwise recommends —
is a **bad fit for Arabic goldens** because its CI mode replaces glyphs with coloured blocks. Blocks
are exactly the failure this task exists to prevent. Where `golden-two-lanes.md` and
`FLUTTER_GUIDE.md` §6.3 disagree about the package, the guide wins: it is authoritative for how code is
written here, and it checked the package's state. The *doctrine* in `golden-two-lanes.md` — narrow
goldens, real fonts, one pinned host, blocked blessing — is adopted in full.

**One lane, not two, and that is a deliberate narrowing.** `golden-two-lanes.md` splits an Ahem
geometry lane from a real-font lane. The geometry half of its job — overflow, fit, mirroring — is done
better by computed geometry (`getRect`, `getSize`, the overflow matrix), which fails with a sentence
instead of a picture; that machinery is E19's. What is left for pixels is shaping and digits, which
needs the real font. Running an Ahem lane as well would double the matrix to prove something no golden
should be proving.

**The fonts land here rather than in E07.** E07 owns the Lonja type ramp and the ~8 MB subset
(`SPEC.md` §8). But a golden harness with no Arabic glyphs is not a harness, and E07 sits *after* this
epic in `epics/README.md`. So T08 lands the two regular faces and the `flutter:` declaration; E07
extends the family with the weights the ramp needs and owns the subsetting. Subsetting changes
rasterisation, so the goldens will be regenerated exactly once, in one titled commit on the Linux lane
— named in the definition of done so the hand-off is not folklore.

**`numberFormatSymbols` is guarded at file scope.** T04's finding point 6: the swap is process-wide and
*will silently corrupt golden tests sharing an isolate*. The per-test `setUp`/`tearDown` pair covers a
disciplined test; `flutter_test_config.dart` covers the undisciplined one, by snapshotting the `ar`
entry before `testMain()` and asserting it pristine afterwards. A file that leaks then fails **in that
file**, which is the difference between ten minutes and a day.

**The matrix has a ceiling and the ceiling is asserted.** `CONVENTIONS.md` §6 budgets 4–6 screens × 6
locales × 2 themes for the *whole product*. Seven images for the numeral primitive is inside it; the
way that budget dies is one image at a time. Row 8 caps the directory, so growing it is a decision
someone has to make in a diff.

**Linux only, and `--update-goldens` is blocked.** `FLUTTER_GUIDE.md` §6.4 point 2 and
`golden-two-lanes.md`: font rasterisation, subpixel positioning and antialiasing differ per host and
per engine revision, so one environment is the source of truth or the files churn on every macOS
machine. And a CI step that blesses turns the suite into a ratchet that approves whatever shipped;
regeneration is a deliberate, reviewed, local act with a titled commit.

**Rejected: `google_fonts`.** It fetches at runtime. `catchlaw-offline-guarantee` bans it, invariant 1
bans it, and `check_i18n_bans.sh` check 5 and `check_lonja_type.sh` check 3 both grep for it. There is
no configuration under which it is acceptable here.

**Rejected: goldening a screen.** There are none. Fabricating one to golden would create a widget whose
only consumer is a test.

**Rejected: `pumpAndSettle` anywhere in this harness.** It carries a 10-minute timeout, truncates its
stack trace, and hangs forever on an indefinite indicator. `pump()` for state changes, `pump(Duration)`
for timers.

## Tests first

Write every row before `flutter_test_config.dart` exists. Run them. **They must fail.** Row 1 fails
first as a compile error, then — once the config exists but before the font is declared — as two
*identical* byte streams. That second failure is the one worth seeing: it is precisely the worthless
`ar` golden `FLUTTER_GUIDE.md` §6.4 warns about, reproduced on purpose.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ar - the numeral specimen renders different pixels from the en specimen` | both specimens, same widget | byte streams differ | **The load-bearing row.** Without a real Arabic font the two are byte-identical and every `ar` golden in this repo is worthless (`FLUTTER_GUIDE.md` §6.4 point 1) |
| 2 | `NumeralSpecimen matches its golden for $locale` | loop over the six locales | matches | The primitive lane. Locale interpolated so `--plain-name` can select one (`CONVENTIONS.md` §5) |
| 3 | `ar - NumeralSpecimen matches its golden under NumeralSystem.arab` | `ar` + `arab` | matches | The only image in the matrix that shows U+0660–0669. If T04's lever regresses, this is what says so in pixels |
| 4 | `pumpLocalised resolves TextDirection.rtl for ar` | `Locale('ar')` | `rtl` | The harness itself must be right, or every golden below it is measuring the wrong tree |
| 5 | `useDevice sets physicalSize to the logical size multiplied by the device pixel ratio` | `small_360` | `Size(1080, 2400)` at DPR 3.0 | `physicalSize` is in **physical** pixels. `Size(320,640)` at DPR 3.0 is a 107×213 logical surface — a documented trap that silently makes every test pass |
| 6 | `useDevice restores the view after the test` | pump, then read | view back at its default | A leaked view size poisons every later test in the file, and the failure lands in a file nobody edited |
| 7 | `NumberSymbolsGuard.check throws when numberFormatSymbols['ar'] was replaced` | swap without restoring | throws | The guard `flutter_test_config.dart` installs. Tested directly rather than by staging a corrupted run |
| 8 | `the l10n golden lane holds at most 12 images` | count `*.png` | ≤ 12 | `CONVENTIONS.md` §6's budget dies one image at a time. A ceiling makes growth a decision in a diff |
| 9 | `every test file under test/l10n/golden carries the golden tag` | source scan | `@Tags(['golden'])` present | An untagged golden runs in the everyday lane on macOS and churns on font rasterisation |
| 10 | `the ci workflow runs the golden lane on ubuntu only` | read the workflow | `--tags golden` job is `runs-on: ubuntu-*` | `FLUTTER_GUIDE.md` §6.4 point 2: one host is the source of truth or the files never stop moving |
| 11 | `the ci workflow never passes --update-goldens` | read the workflow | no occurrence | A blessing step turns the suite into a ratchet that approves whatever shipped |
| 12 | `OFL.txt ships beside the font files` | `assets/fonts/` | file exists, non-empty | `SPEC.md` §8: bundling is permitted **because** the files are not renamed and the OFL text ships. A licence obligation, not a nicety |

```dart
// app/test/flutter_test_config.dart
// Directory-scoped and scanned upward (FLUTTER_GUIDE.md §6.2). Everything under
// app/test/ runs through here.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'support/golden.dart';
import '../testing/l10n/number_symbols_guard.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Without this the test font has no Arabic coverage and an ar golden is
  // byte-identical to an en golden (FLUTTER_GUIDE.md §6.4, point 1).
  await loadCatchlawFonts();

  // The numeral lever mutates a process-wide map (FLUTTER_GUIDE.md Part 9.1).
  // A file that forgets its tearDown fails HERE rather than in a later golden.
  captureNumberSymbols();
  await testMain();
  assertNumberSymbolsPristine();
}
```

```dart
// app/test/support/golden.dart  — helper, must not end in _test.dart
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Device {
  const Device(this.name, this.logicalSize, this.dpr);
  final String name;
  final Size logicalSize;
  final double dpr;

  static const small = Device('small_360', Size(360, 800), 3.0);
}

Future<void> loadCatchlawFonts() async {
  for (final family in const <String, String>{
    'NotoSans': 'assets/fonts/NotoSans-Regular.ttf',
    'NotoNaskhArabic': 'assets/fonts/NotoNaskhArabic-Regular.ttf',
  }.entries) {
    final loader = FontLoader(family.key)
      ..addFont(rootBundle.load(family.value));
    await loader.load();
  }
}

extension GoldenHarness on WidgetTester {
  void useDevice(Device d) {
    view.devicePixelRatio = d.dpr;
    view.physicalSize = d.logicalSize * d.dpr; // physical px — multiply by DPR
    addTearDown(view.reset);                    // one call; nothing forgotten
  }

  Future<void> pumpLocalised(Widget child, Locale locale) async {
    await pumpWidget(CatchlawApp(locale: locale, home: child));
    await pump(); // one frame; never pumpAndSettle
  }
}
```

```dart
// app/test/l10n/golden/font_coverage_test.dart
@Tags(['golden'])
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden.dart';
import 'numeral_specimen.dart';

Future<Uint8List> _render(WidgetTester tester, Locale locale) async {
  tester.useDevice(Device.small);
  await tester.pumpLocalised(const NumeralSpecimen(), locale);
  final image = await tester.binding
      .runAsync(() => (find.byType(NumeralSpecimen).evaluate().single.renderObject!
          as RenderRepaintBoundary)
          .toImage());
  final data = await image!.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void main() {
  // THE row. Under the default test font these two are byte-identical, and every
  // ar golden in this repository would be worthless (FLUTTER_GUIDE.md §6.4).
  testWidgets('ar - the numeral specimen renders different pixels from the en specimen',
      (tester) async {
    final ar = await _render(tester, const Locale('ar'));
    final en = await _render(tester, const Locale('en'));
    expect(ar, isNot(equals(en)),
        reason: 'no Arabic glyph coverage — is FontLoader running in '
            'flutter_test_config.dart?');
  });
}
```

```dart
// app/test/l10n/golden/numeral_specimen_test.dart
@Tags(['golden'])
library;

import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/l10n/number_symbols_guard.dart';
import '../../support/golden.dart';
import 'numeral_specimen.dart';

void main() {
  setUp(captureNumberSymbols);
  tearDown(restoreNumberSymbols);

  for (final locale in const <Locale>[
    Locale('ar'), Locale('en'), Locale('es'),
    Locale('gl'), Locale('ca'), Locale('pt', 'BR'),
  ]) {
    final tag = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    testWidgets('NumeralSpecimen matches its golden for $tag', (tester) async {
      tester.useDevice(Device.small);
      await tester.pumpLocalised(const NumeralSpecimen(), locale);
      await expectLater(find.byType(NumeralSpecimen),
          matchesGoldenFile('goldens/numeral_specimen_$tag.png'));
    });
  }

  testWidgets('ar - NumeralSpecimen matches its golden under NumeralSystem.arab',
      (tester) async {
    applyNumeralSystem(NumeralSystem.arab);
    tester.useDevice(Device.small);
    await tester.pumpLocalised(const NumeralSpecimen(), const Locale('ar'));
    await expectLater(find.byType(NumeralSpecimen),
        matchesGoldenFile('goldens/numeral_specimen_ar_arab.png'));
  });
}
```

**Run:** `cd app && flutter test --tags golden` → 12 rows red (18 tests after row 2's loop). Row 1's
second failure mode — two identical byte streams — must be observed at least once before the font is
declared, because that is the exact state `FLUTTER_GUIDE.md` §6.4 warns a green suite can be in.

## Implementation outline

1. Add the two OFL font files and `OFL.txt` under `app/assets/fonts/`. Do **not** rename them — §8's
   licence position depends on it. Declare both families under `flutter: fonts:` in `app/pubspec.yaml`.
2. Write `app/test/support/golden.dart`: `Device`, `loadCatchlawFonts`, `useDevice`, `pumpLocalised`.
   Four load-bearing lines from `harness-and-mediaquery.md` — `physicalSize = logicalSize * dpr`,
   `addTearDown(view.reset)`, `MediaQuery.of(context).copyWith` when a scale axis is added later, and
   `pump()` rather than `pumpAndSettle`.
3. Write `app/test/flutter_test_config.dart` exactly as above. Make rows 4–7 green.
4. Write `numeral_specimen.dart` — the widget under test. A `RepaintBoundary` around a column of the
   digits 0–9 and `numberFormatFor(locale).format(1234567.89)`, using only `numberFormatFor` (T04) and
   no theme, because `LonjaType` is E07's.
5. Run row 1 **before** wiring `loadCatchlawFonts` into the config and watch it fail with identical
   bytes. Then wire it and watch it pass. That is the demonstration; skipping it means trusting the
   mechanism instead of having seen it.
6. Generate the seven goldens on the Linux lane, review the PNGs by eye — Arabic must be joined, not
   letter-separated (`arabic-and-scripts.md`, zero tracking) — and commit them next to their test file.
7. Split the CI test steps: everyday job `flutter test --exclude-tags golden`; a new
   `ubuntu-latest` job `flutter test --tags golden`. Neither carries `--update-goldens`. Make rows
   8–11 green.
8. Re-run the full suite twice in a row. A leaked symbol map or a leaked view size is order-dependent
   and will only show on the second pass.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 rows pass, and each failed first.
- [ ] Row 1 has been observed failing with identical bytes before the font was wired in.
- [ ] `app/test/flutter_test_config.dart` loads both faces and guards `numberFormatSymbols`.
- [ ] `app/test/support/golden.dart` does not end in `_test.dart` and is not executed as a suite.
- [ ] The golden directory holds exactly seven PNGs and the ceiling of 12 is asserted.
- [ ] Every file under `test/l10n/golden/` opens with `@Tags(['golden'])`.
- [ ] CI has two test jobs; the golden one is `ubuntu-latest`; neither passes `--update-goldens`.
- [ ] `**/failures/` is ignored (E01 added it; confirm, do not re-add).
- [ ] `google_fonts` appears nowhere — `check_i18n_bans.sh` and `check_lonja_type.sh` both clean.
- [ ] `OFL.txt` ships and the font filenames are unrenamed (`SPEC.md` §8).
- [ ] The commit body names the hand-off: whichever epic subsets the fonts regenerates all goldens in
      one titled commit on the Linux lane.
- [ ] The full suite passes twice in a row and with the file order reversed.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze
cd app && flutter test --exclude-tags golden
cd app && flutter test --tags golden          # Linux only; on macOS expect rasterisation diffs
.claude/skills/i18n-rtl-l10n/scripts/check_i18n_bans.sh                  app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh              app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
tools/gates/no_directional_geometry.sh                                   app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(l10n): load a Naskh font for goldens and pin the lane to Linux

flutter test runs with a test font that has no Arabic coverage, so an ar
golden is byte-identical to the en golden of the same widget: the test
passes, keeps passing through any amount of broken shaping, and proves
nothing (FLUTTER_GUIDE.md §6.4, point 1). FontLoader in
flutter_test_config.dart fixes it, and one non-golden row asserts the ar and
en specimens differ in bytes — which is what makes every later ar golden in
this repository mean anything.

Built-in matchesGoldenFile and a hand-written harness, per §6.3:
golden_toolkit is discontinued and cannot resolve on Dart 3, and alchemist's
CI mode replaces glyphs with coloured blocks, which is the exact failure this
task exists to prevent. The doctrine from golden-two-lanes.md is adopted
whole; only the package is refused.

One lane rather than two. The Ahem lane's job — geometry, overflow, mirroring
— is done better by computed assertions that fail with a sentence, and that
machinery is E19's. What is left for pixels is shaping and digits.

Seven images: six locales plus ar under NumeralSystem.arab. The ceiling of
twelve is asserted, because a golden budget dies one image at a time.

The two OFL faces land here rather than in E07 because a harness with no
Arabic glyphs is not a harness. E07 owns the ramp, the extra weights and the
~8 MB subset; subsetting changes rasterisation, so it regenerates all goldens
in one titled commit on the Linux lane.

Task: E06/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
