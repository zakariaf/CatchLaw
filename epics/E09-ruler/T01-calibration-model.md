# E09/T01 — The calibration model

| | |
|---|---|
| **Epic** | E09 — Ruler and calibration |
| **Branch** | `epic/09-ruler` (shared) |
| **Commit** | `feat(ruler): measure px-per-mm against the ID-1 card and reject an implausible scale` |
| **Depends on** | — (first task of the epic; E05's `user_profile` row and E07's theme already exist) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.2 (calibration row), §7.2 (`user_profile.ruler_px_per_mm`, `ruler_calibrated_at`), §9.5 (integer millimetres) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-measurement-ruler` | Owns the ID-1 constants, the plausibility band, the one-rounding rule and the "an implausible scale is never stored" contract — rules 1, 7, 8, 11 |
| `value-objects-money-and-units` | The canonical-unit principle: an integer canonical field, rounding `.from` factories, edge-only `to<Unit>()` getters, and an injected `Clock` instead of `DateTime.now()` |
| `catchlaw-conventions-index` | Invariant 6, the one-way layer map — this is app-side domain, and it may not reach into `lib/ui/` or leak a drift row |
| `testing-strategy` | Which tier each test belongs at: pure Dart for the band and the rounding, `NativeDatabase.memory()` for the repository, never a mocked DAO |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.2 "Calibration" row | ID-1 at 85.60 × 53.98 mm, stored as px-per-mm, re-calibratable from Settings |
| `SPEC.md` | §7.2 `user_profile` | The two columns this writes: `ruler_px_per_mm REAL`, `ruler_calibrated_at TEXT`. No schema change is permitted here |
| `SPEC.md` | §9.5 "Units" | Everything is stored as integer millimetres; conversion is display-only |
| `.claude/skills/catchlaw-measurement-ruler/SKILL.md` | rules 1, 7, 8, 11, 12 | Integer millimetres, the card and nothing but the card, the rejection contract, the single rounding, accuracy is measured not asserted |
| `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md` | "The card is the ruler", "Procedure", "Plausibility band" | The five constants with their homes, the four-row verdict table, and why the rejection never falls back to the nominal |
| `.claude/skills/catchlaw-measurement-ruler/examples/ruler_painter.dart` | header comment + `RulerScene` | The shape an immutable, `==`-comparable value type takes in this subsystem |
| `.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh` | checks 1 and 5, and the header | Why the band constants carry `// measurement-ok` and nothing else in the file may |
| `.claude/skills/value-objects-money-and-units/references/canonical-storage.md` | "Physical value objects", "Injected Clock" | The `.from`/`to()` shape and the `Clock.fixed` test idiom |
| `FLUTTER_GUIDE.md` | §2.5, rules 4 and 6 | Every repository gets an abstract interface and a fake in `testing/fakes/`; drift row classes never escape `data/` |
| `epics/DECISIONS.md` | D-1 | Paths: the app is under `app/`, so every path below starts there |

## What this delivers

- `app/lib/domain/models/id1_card.dart` — the five measured constants, each with its source in a doc
  comment: `kId1WidthMm` 85.60, `kId1HeightMm` 53.98, `kId1CornerRadiusMm` 3.18,
  `kNominalPxPerMm` 6.299, `kMinPxPerMm` 4.50, `kMaxPxPerMm` 9.00.
- `app/lib/domain/models/ruler_calibration.dart` — `RulerCalibration`, `@immutable`, value equality,
  fields `double pxPerMm` and `DateTime capturedOn` (UTC). It carries the **one shared transform**
  this subsystem has: `int millimetresFor(double px)` and `double pixelsForMillimetres(int mm)`.
- `app/lib/domain/use_cases/calibrate_ruler_use_case.dart` — sealed `CalibrationOutcome` with
  `CalibrationAccepted(RulerCalibration)` and `CalibrationImplausible(double measuredPxPerMm)`, and
  `CalibrateRulerUseCase(Clock clock)` whose `call(double cardWidthPx)` divides, judges, and either
  builds a calibration stamped with `clock.now().toUtc()` or refuses.
- `app/lib/data/repositories/calibration_repository.dart` — the abstract interface:
  `Future<RulerCalibration?> read()`, `Future<void> save(RulerCalibration)`, `Future<void> clear()`.
- `app/lib/data/repositories/calibration_repository_drift.dart` — the implementation over the
  `user_profile` DAO E05 delivered. It writes `ruler_px_per_mm` and `ruler_calibrated_at` and touches
  no other column.
- `app/testing/fakes/fake_calibration_repository.dart` — `FakeCalibrationRepository implements
  CalibrationRepository`, bare `implements` so an interface change is a compile error. Every later
  task in this epic pumps against it.
- Tests: `app/test/domain/ruler_calibration_test.dart`,
  `app/test/domain/calibrate_ruler_use_case_test.dart`,
  `app/test/data/calibration_repository_drift_test.dart`.

No schema migration. No new dependency. No UI.

## Why it is built this way

**The scale is measured, never derived.** Flutter cannot tell you a panel's physical DPI.
`devicePixelRatio` is a logical-to-physical ratio and no arithmetic on it yields millimetres, so
`devicePixelRatioOf(context) * 160 / 25.4` is a guess wearing four decimal places. The ID-1 card is
the one precisely-dimensioned object every fisher already carries — 85.60 × 53.98 mm by ISO/IEC 7810,
identical in every wallet on every quay. Check 5 of `check_measurement.sh` exists to catch exactly the
rejected alternative, so the ban is executable rather than advisory.

**The band is a gate, not a clamp.** `4.50 ≤ pxPerMm ≤ 9.00` brackets the nominal 6.299 (160 logical
dp per inch ÷ 25.4) by roughly ±40%. Outside it, `CalibrationImplausible` is returned and **nothing is
written** — the previous calibration, or none at all, survives untouched. *Rejected:* clamping the
measured value into the band, and falling back to `kNominalPxPerMm`. Both produce a plausible-looking
wrong scale, and every reading taken afterwards is confidently wrong with nothing on screen to signal
it. No calibration is a state the app already handles (T06); a 40%-wrong calibration is not.

**One rounding, and it lives here.** `millimetresFor` is `(px / pxPerMm).round()` and it is the only
place a length is ever rounded. `pixelsForMillimetres` is its inverse and is what the painter (T03)
and the drag handler (T05) both call, which is `custom-canvas-and-gestures` rule 3 — one transform,
read by the painter and the hit-tester, never re-derived from `size`. *Rejected:* a `double lengthCm`
anywhere in the chain. 44.9999 rounds under the 45 cm minimum on one device and over it on another,
and no test tells you which.

**`pxPerMm` is a `double` and that is deliberate.** It is a scale factor, not a length; it is the only
`double` in the subsystem, and `check_measurement.sh` check 1 is scoped to names containing `length`
so it does not fight this one. The band constants trip check 5's
`pxPerMm[[:space:]]*=[[:space:]]*[0-9]` pattern and therefore carry a trailing `// measurement-ok` —
the script's own header names them as the one deliberate exemption. Nothing else in the file gets one.

**Time is injected.** `capturedOn` comes from `package:clock`, so the "calibrated on" line and any
future staleness rule are deterministic in a test. *Rejected:* `DateTime.now()` inside the use case —
banned by `value-objects-money-and-units` rule 13 and by `testing-strategy` rule 2, and it would make
the repository round-trip test a wall-clock race.

**Why a repository and not a direct DAO call.** `FLUTTER_GUIDE.md` §2.5 rule 4: every repository has
an abstract interface and a fake, so T02, T05, T06 and T07 can all pump a screen against
`FakeCalibrationRepository` without a database. If E05 already published a repository covering the
`user_profile` row, extend it rather than adding a second owner of the same row — two repositories
over one row is two facts that will disagree.

## Tests first

Write every row before touching `id1_card.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `RulerCalibration.millimetresFor rounds to the nearest millimetre` | 2834.6 px at 6.299 | `450` | The worked row in `measurement-methods.md`; 449.99 mm must land on the 45 cm minimum, not below it |
| 2 | `RulerCalibration.millimetresFor rounds down below the half-millimetre` | 2828.3 px at 6.299 | `449` | The adjacent row. One millimetre either side of the limit is the whole legal exposure |
| 3 | `RulerCalibration.pixelsForMillimetres inverts millimetresFor for 1..3000 mm` | fuzz, seed `0xCA11B` | round-trip equals the input | `custom-canvas-and-gestures` rule 3: painter and hit-tester share one transform, so its inverse must be exact or taps land off the tick |
| 4 | `RulerCalibration compares equal with the same pxPerMm and capturedOn` | two instances | `==` and equal `hashCode` | `shouldRepaint` in T03 is one value compare; without `==` the ruler repaints every frame |
| 5 | `CalibrateRulerUseCase accepts a card measured at 539.2 px` | 539.2 px | `CalibrationAccepted`, `pxPerMm` ≈ 6.299 | The nominal case: 85.60 mm at 160 dp/inch |
| 6 | `CalibrateRulerUseCase accepts pxPerMm at the 4.50 floor` | 385.2 px | `CalibrationAccepted` | The band is inclusive; a boundary written as `<` instead of `<=` rejects a legitimate low-density tablet |
| 7 | `CalibrateRulerUseCase accepts pxPerMm at the 9.00 ceiling` | 770.4 px | `CalibrationAccepted` | The same boundary at the other end |
| 8 | `CalibrateRulerUseCase rejects pxPerMm below 4.50` | 384.0 px | `CalibrationImplausible(measured: ~4.486)` | The card-under-a-thick-case failure mode from the skill's field notes |
| 9 | `CalibrateRulerUseCase rejects pxPerMm above 9.00` | 800.0 px | `CalibrationImplausible` | A handle dragged past the card edge |
| 10 | `CalibrateRulerUseCase rejects a zero card width` | 0.0 | `CalibrationImplausible(measured: 0)` | Division yields 0, not a throw; the outcome must be a value, not an exception into the UI |
| 11 | `CalibrateRulerUseCase rejects a non-finite card width` | `double.nan`, `double.infinity` | `CalibrationImplausible` | `nan` fails every `<` and `>` comparison, so a naive band check accepts it |
| 12 | `CalibrateRulerUseCase rejects a negative card width` | -539.2 | `CalibrationImplausible` | A drag that crosses the origin |
| 13 | `CalibrateRulerUseCase stamps capturedOn from the injected clock` | fixed clock 2026-08-01T05:40Z | `capturedOn` equals that instant, in UTC | Determinism, and the "calibrated on" line E16 renders |
| 14 | `CalibrationRepositoryDrift.save writes ruler_px_per_mm and ruler_calibrated_at` | accepted calibration | both columns set, no other column changed | The row also carries `sunlight_mode`, `glove_mode` and the unit; a blind row replace would wipe them |
| 15 | `CalibrationRepositoryDrift.read returns null on a virgin profile` | fresh in-memory DB | `null` | The virgin-install state T06 depends on; a non-null default here would silently enable a wrong ruler |
| 16 | `CalibrationRepositoryDrift.read round-trips a saved calibration` | save then read | equal `pxPerMm` and `capturedOn` | REAL/TEXT storage must survive the trip; a locale-formatted date would not |
| 17 | `CalibrationRepositoryDrift.save leaves the previous row intact when nothing is saved` | save, then an implausible outcome that is not saved | the first calibration still reads back | Proves the rejection path at the layer that actually persists — the contract is "previous survives" |

```dart
// app/test/domain/calibrate_ruler_use_case_test.dart
import 'package:catchlaw/domain/models/id1_card.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/domain/use_cases/calibrate_ruler_use_case.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at0540 = DateTime.utc(2026, 8, 1, 5, 40);
  CalibrateRulerUseCase subject() =>
      CalibrateRulerUseCase(Clock.fixed(at0540));

  group('CalibrateRulerUseCase', () {
    test('accepts a card measured at 539.2 px', () {
      final outcome = subject()(kId1WidthMm * kNominalPxPerMm);
      expect(outcome, isA<CalibrationAccepted>());
      expect((outcome as CalibrationAccepted).calibration.pxPerMm,
          closeTo(kNominalPxPerMm, 1e-9));
    });

    test('accepts pxPerMm at the 4.50 floor', () {
      expect(subject()(kId1WidthMm * kMinPxPerMm), isA<CalibrationAccepted>());
    });

    test('rejects a non-finite card width', () {
      for (final px in <double>[double.nan, double.infinity]) {
        expect(subject()(px), isA<CalibrationImplausible>(),
            reason: 'cardWidthPx=$px'); // its own minimal repro
      }
    });

    test('stamps capturedOn from the injected clock', () {
      final outcome =
          subject()(kId1WidthMm * kNominalPxPerMm) as CalibrationAccepted;
      expect(outcome.calibration.capturedOn, at0540);
      expect(outcome.calibration.capturedOn.isUtc, isTrue);
    });
  });
}
```

```dart
// app/test/domain/ruler_calibration_test.dart
import 'dart:math';

import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final nominal = RulerCalibration(
      pxPerMm: 6.299, capturedOn: DateTime.utc(2026, 8, 1));

  group('RulerCalibration', () {
    test('.millimetresFor rounds to the nearest millimetre', () {
      expect(nominal.millimetresFor(2834.6), 450);
    });

    test('.pixelsForMillimetres inverts millimetresFor for 1..3000 mm', () {
      final rng = Random(0xCA11B);
      for (var seed = 0; seed < 500; seed++) {
        final mm = rng.nextInt(3000) + 1;
        expect(nominal.millimetresFor(nominal.pixelsForMillimetres(mm)), mm,
            reason: 'seed=$seed mm=$mm');
      }
    });
  });
}
```

```dart
// app/test/data/calibration_repository_drift_test.dart
import 'package:catchlaw/data/repositories/calibration_repository_drift.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late UserDatabase db;
  setUp(() => db = UserDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('CalibrationRepositoryDrift.read returns null on a virgin profile',
      () async {
    expect(await CalibrationRepositoryDrift(db).read(), isNull);
  });

  test('CalibrationRepositoryDrift.read round-trips a saved calibration',
      () async {
    final repository = CalibrationRepositoryDrift(db);
    final saved = RulerCalibration(
        pxPerMm: 6.31, capturedOn: DateTime.utc(2026, 8, 1, 5, 40));
    await repository.save(saved);
    expect(await repository.read(), saved);
  });
}
```

**Run:** `cd app && flutter test test/domain test/data/calibration_repository_drift_test.dart`
→ 17 failures. If any passes now, the test is wrong — fix the test before writing any production code.

## Implementation outline

1. `id1_card.dart`: six top-level `const double`s with `///` doc comments naming ISO/IEC 7810 and the
   160-dp-per-inch derivation. Append `// measurement-ok` to `kNominalPxPerMm`, `kMinPxPerMm` and
   `kMaxPxPerMm` — those three match check 5's grep.
2. `ruler_calibration.dart`: `@immutable final class RulerCalibration` with a const constructor,
   `operator ==`, `hashCode`, the two transform methods, and an assert that `pxPerMm` is finite and
   positive (a programmer error at this layer; the *user* path is judged in step 3).
3. `calibrate_ruler_use_case.dart`: `sealed class CalibrationOutcome` with the two subclasses; the use
   case divides `cardWidthPx / kId1WidthMm`, then judges with
   `!value.isFinite || value < kMinPxPerMm || value > kMaxPxPerMm`. Order matters — the finite check
   comes first, because `nan` fails both comparisons.
4. `calibration_repository.dart` + `_drift.dart`: read the single `user_profile` row with `id = 1`,
   map `(ruler_px_per_mm, ruler_calibrated_at)` to `RulerCalibration?`, and write with a partial
   `UPDATE` companion so the other nine columns are untouched. ISO-8601 UTC in the TEXT column.
5. `testing/fakes/fake_calibration_repository.dart`: a settable `RulerCalibration?` field plus a
   `saveCount`, so a test can assert that a rejected calibration produced no write at all.
6. Re-run the whole suite, not just these files.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 tests pass, and each failed first.
- [ ] Branch coverage on `calibrate_ruler_use_case.dart` and `ruler_calibration.dart` is 100% — these
      are `testing-strategy` rule 9 files: a gap here is a silently wrong scale.
- [ ] No `double` or `String` field whose name contains `length` exists in the diff.
- [ ] `check_measurement.sh app/lib` is clean, and the only `// measurement-ok` hatches in the diff
      are the three band constants.
- [ ] The `user_profile` row's other columns are provably untouched by `save()` (test 14).
- [ ] `app/lib/domain/` imports nothing from `app/lib/ui/` and no drift row type escapes
      `app/lib/data/`.
- [ ] No `DateTime.now()` anywhere in the diff.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(ruler): measure px-per-mm against the ID-1 card and reject an implausible scale

Flutter cannot report a panel's physical DPI — devicePixelRatio is a
logical-to-physical ratio and no arithmetic on it yields millimetres. So the
scale is measured against an ISO/IEC 7810 ID-1 card at 85.60 mm and judged
against a 4.50–9.00 px/mm band before it is allowed to exist. Outside the band
nothing is written and the previous calibration survives: a plausible-looking
wrong scale is worse than no ruler, because every reading after it is
confidently wrong and nothing on screen says so.

millimetresFor is the single rounding site in the subsystem and
pixelsForMillimetres is its exact inverse, so the painter and the drag handler
share one transform instead of deriving two.

Task: E09/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
